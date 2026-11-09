<?php
/**
 * Індекс пошуку «Крістал» (фіча 027): kristal_search_word (слово → товар 'p' / категорія 'c') і журнал «не знайдено».
 * Слова — Kristal\Search::words() з назв усіх мов і артикулу. Статус/магазин не індексуються — їх перевіряє пошук на вітрині.
 */
class ModelExtensionKristalSearch extends Model {
	const BATCH = 500;

	/** Переіндексувати товар: 3 запити (DELETE за idx_item_type, SELECT назв, INSERT пачкою). */
	public function indexProduct($product_id) {
		$product_id = (int)$product_id;
		$this->deleteItem('p', $product_id);

		$query = $this->db->query("SELECT p.sku, pd.name
			FROM `" . DB_PREFIX . "product` p
			LEFT JOIN `" . DB_PREFIX . "product_description` pd ON (pd.product_id = p.product_id)
			WHERE p.product_id = '" . $product_id . "'");

		if (!$query->num_rows) {
			return 0;
		}

		$text = $query->row['sku'];

		foreach ($query->rows as $row) {
			$text .= ' ' . $row['name'];
		}

		return $this->insert('p', array($product_id => $text));
	}

	public function indexCategory($category_id) {
		$category_id = (int)$category_id;
		$this->deleteItem('c', $category_id);

		$query = $this->db->query("SELECT name FROM `" . DB_PREFIX . "category_description` WHERE category_id = '" . $category_id . "'");

		if (!$query->num_rows) {
			return 0;
		}

		return $this->insert('c', array($category_id => implode(' ', array_column($query->rows, 'name'))));
	}

	public function deleteItem($type, $item_id) {
		$this->db->query("DELETE FROM `" . DB_PREFIX . "kristal_search_word`
			WHERE item_id = '" . (int)$item_id . "' AND type = '" . ($type === 'c' ? 'c' : 'p') . "'");
	}

	/**
	 * Повна перебудова (встановлення модуля, кнопка, після масового імпорту 022).
	 * Товари пачками по 1000 за product_id; рядків індексу — INSERT по 500.
	 * @return array ['products' => N, 'categories' => N, 'words' => N]
	 */
	public function reindexAll() {
		$this->db->query("DELETE FROM `" . DB_PREFIX . "kristal_search_word`");

		$result = array('products' => 0, 'categories' => 0, 'words' => 0);
		$last = 0;

		do {
			$query = $this->db->query("SELECT p.product_id, p.sku, pd.name
				FROM `" . DB_PREFIX . "product` p
				LEFT JOIN `" . DB_PREFIX . "product_description` pd ON (pd.product_id = p.product_id)
				WHERE p.product_id > '" . (int)$last . "'
				AND p.product_id <= (SELECT MAX(product_id) FROM (SELECT product_id FROM `" . DB_PREFIX . "product` WHERE product_id > '" . (int)$last . "' ORDER BY product_id LIMIT 1000) t)
				ORDER BY p.product_id");

			$texts = array();

			foreach ($query->rows as $row) {
				$id = (int)$row['product_id'];
				$texts[$id] = (isset($texts[$id]) ? $texts[$id] : $row['sku']) . ' ' . $row['name'];
				$last = $id;
			}

			$result['products'] += count($texts);
			$result['words'] += $this->insert('p', $texts);
		} while ($query->num_rows);

		$query = $this->db->query("SELECT category_id, name FROM `" . DB_PREFIX . "category_description` ORDER BY category_id");
		$texts = array();

		foreach ($query->rows as $row) {
			$id = (int)$row['category_id'];
			$texts[$id] = (isset($texts[$id]) ? $texts[$id] . ' ' : '') . $row['name'];
		}

		$result['categories'] = count($texts);
		$result['words'] += $this->insert('c', $texts);

		return $result;
	}

	/** @return array ['products' => N, 'categories' => N, 'words' => N] */
	public function stats() {
		$query = $this->db->query("SELECT type, COUNT(DISTINCT item_id) AS items, COUNT(*) AS words
			FROM `" . DB_PREFIX . "kristal_search_word` GROUP BY type");

		$stats = array('products' => 0, 'categories' => 0, 'words' => 0);

		foreach ($query->rows as $row) {
			$stats[$row['type'] === 'c' ? 'categories' : 'products'] = (int)$row['items'];
			$stats['words'] += (int)$row['words'];
		}

		return $stats;
	}

	/** 50 найчастіших запитів без результатів за 90 днів (AC-8) */
	public function getLog($limit = 50) {
		$query = $this->db->query("SELECT query, hits, last_at FROM `" . DB_PREFIX . "kristal_search_log`
			WHERE last_at > NOW() - INTERVAL 90 DAY
			ORDER BY hits DESC, last_at DESC
			LIMIT " . max(1, (int)$limit));

		return $query->rows;
	}

	public function clearLog() {
		$this->db->query("DELETE FROM `" . DB_PREFIX . "kristal_search_log`");
	}

	/** [item_id => текст] → рядки індексу, INSERT IGNORE пачками. @return int кількість слів */
	private function insert($type, $texts) {
		$type = $type === 'c' ? 'c' : 'p';
		$values = array();
		$count = 0;

		foreach ($texts as $item_id => $text) {
			foreach (\Kristal\Search::words($text, 128) as $word) {
				$values[] = "('" . $this->db->escape($word) . "', '" . $type . "', '" . (int)$item_id . "')";
				$count++;

				if (count($values) >= self::BATCH) {
					$this->flush($values);
					$values = array();
				}
			}
		}

		if ($values) {
			$this->flush($values);
		}

		return $count;
	}

	private function flush($values) {
		$this->db->query("INSERT IGNORE INTO `" . DB_PREFIX . "kristal_search_word` (word, type, item_id) VALUES " . implode(',', $values));
	}
}
