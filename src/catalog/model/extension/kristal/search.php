<?php
/**
 * Пошук «Крістал» на вітрині (фіча 027).
 *
 * Товари: словниковий індекс kristal_search_word (адмінка 027) — кожне слово запиту (з синонімами) має бути початком
 * якогося слова назви/артикулу; один запит з діапазонами по PK + JOIN статусу, магазину, оренди й ЧПУ.
 * Категорії: кешоване меню теми (003) — 0 запитів.
 * Нічого не знайдено, а в запиті латиниця → повтор в українській розкладці (AC-3).
 * Результат кешується: kristal.search.q.<store>.<lang>.<md5> (скидається з усім kristal.* при змінах в адмінці).
 */
class ModelExtensionKristalSearch extends Model {
	/** Найбільше знайдених товарів (сторінка результатів — 21 сторінка по 24) */
	const LIMIT = 500;

	/**
	 * @return array [
	 *   'query'      => запит, обрізаний до 64 символів (для показу),
	 *   'layout'     => рядок у перекладеній розкладці, якщо знайдено саме за ним, інакше '',
	 *   'products'   => [['product_id', 'name', 'price', 'image', 'unit', 'is_hit', 'href', 'rank'], ...] впорядковані (AC-5),
	 *   'categories' => [['category_id', 'name', 'href'], ...]
	 * ]
	 */
	public function find($query) {
		$query = \Kristal\Search::cut($query);
		$result = array('query' => $query, 'layout' => '', 'products' => array(), 'categories' => array());
		$normalized = \Kristal\Search::normalize($query);

		if (mb_strlen($normalized, 'UTF-8') < 2) {
			return $result;
		}

		$key = $this->key($normalized);
		$cached = $this->cache->get($key);

		if (is_array($cached)) {
			$cached['query'] = $query;

			return $cached;
		}

		$groups = \Kristal\Search::synonyms((string)$this->config->get('module_kristal_search_synonyms'));
		$found = $this->match($normalized, $groups);

		if (!$found['products'] && !$found['categories']) {
			$layout = \Kristal\Search::normalize(\Kristal\Search::layout($query));

			if ($layout !== '' && $layout !== $normalized) {
				$found = $this->match($layout, $groups);

				if ($found['products'] || $found['categories']) {
					$result['layout'] = $layout;
				}
			}
		}

		$result['products'] = $found['products'];
		$result['categories'] = $found['categories'];

		$this->cache->set($key, $result);

		return $result;
	}

	/** Чи є результат у кеші (ліміт частоти підказок рахує лише запити, що йдуть у базу — AC-10) */
	public function isCached($query) {
		$normalized = \Kristal\Search::normalize(\Kristal\Search::cut($query));

		return mb_strlen($normalized, 'UTF-8') < 2 || is_array($this->cache->get($this->key($normalized)));
	}

	/**
	 * Адреса сторінки пошуку: /poshuk (ЧПУ) або index.php?route=extension/kristal/search.
	 * Основа — з кешу kristal.search.href.* (url->link() = запит oc_seo_url, а шапка показує її на кожній сторінці).
	 * @param string $query запит (сирий текст) — додається як q; $page — номер або '{page}' для Pagination
	 */
	public function href($query = '', $page = null) {
		$key = 'kristal.search.href.' . (int)$this->config->get('config_store_id') . '.' . (int)$this->config->get('config_language_id') . '.' . (!empty($this->request->server['HTTPS']) ? 's' : 'h');
		$base = $this->cache->get($key);

		if (!is_string($base) || $base === '') {
			$base = str_replace('&amp;', '&', $this->url->link('extension/kristal/search'));
			$this->cache->set($key, $base);
		}

		$params = array();

		if ($query !== '') {
			$params[] = 'q=' . rawurlencode($query);
		}

		if ($page !== null) {
			$params[] = 'page=' . ($page === '{page}' ? '{page}' : (int)$page);
		}

		return $params ? $base . (strpos($base, '?') === false ? '?' : '&') . implode('&', $params) : $base;
	}

	/** Запит без результатів зі сторінки результатів → журнал (AC-8). Без IP; 1 з 100 — прибрати записи старші за 90 днів. */
	public function log($query) {
		$normalized = utf8_substr(\Kristal\Search::normalize($query), 0, \Kristal\Search::QUERY_MAX);

		if (utf8_strlen($normalized) < 2) {
			return;
		}

		$this->db->query("INSERT INTO `" . DB_PREFIX . "kristal_search_log` (query, hits, last_at)
			VALUES ('" . $this->db->escape($normalized) . "', 1, NOW())
			ON DUPLICATE KEY UPDATE hits = hits + 1, last_at = NOW()");

		if (mt_rand(1, 100) === 1) {
			$this->db->query("DELETE FROM `" . DB_PREFIX . "kristal_search_log` WHERE last_at < NOW() - INTERVAL 90 DAY");
		}
	}

	private function key($normalized) {
		return 'kristal.search.q.' . (int)$this->config->get('config_store_id') . '.' . (int)$this->config->get('config_language_id') . '.' . md5($normalized);
	}

	private function match($normalized, $groups) {
		$tokens = \Kristal\Search::tokens($normalized);

		if (!$tokens) {
			return array('products' => array(), 'categories' => array());
		}

		$variants = array();

		foreach ($tokens as $token) {
			$variants[] = \Kristal\Search::variants($token, $groups);
		}

		return array(
			'products'   => $this->products($normalized, $tokens, $variants),
			'categories' => $this->categories($normalized, $tokens, $variants)
		);
	}

	/** Один запит: індекс → увімкнені товари магазину з назвою, ціною, фото, орендою й ЧПУ */
	private function products($normalized, $tokens, $variants) {
		$store_id = (int)$this->config->get('config_store_id');
		$language_id = (int)$this->config->get('config_language_id');
		$conditions = array();

		foreach ($variants as $list) {
			$likes = array();

			foreach ($list as $variant) {
				$likes[] = "w.word LIKE '" . $this->db->escape(\Kristal\Search::likeEscape($variant)) . "%'";
			}

			$conditions[] = '(' . implode(' OR ', $likes) . ')';
		}

		$having = array();

		foreach ($conditions as $condition) {
			$having[] = 'MAX(' . $condition . ') = 1';
		}

		$query = $this->db->query("SELECT p.product_id, pd.name, p.price, p.image, r.unit, r.is_hit, su.keyword
			FROM (SELECT w.item_id FROM `" . DB_PREFIX . "kristal_search_word` w
				WHERE w.type = 'p' AND (" . implode(' OR ', $conditions) . ")
				GROUP BY w.item_id
				HAVING " . implode(' AND ', $having) . "
				LIMIT 2000) m
			JOIN `" . DB_PREFIX . "product` p ON (p.product_id = m.item_id)
			JOIN `" . DB_PREFIX . "product_to_store` p2s ON (p2s.product_id = p.product_id AND p2s.store_id = '" . $store_id . "')
			JOIN `" . DB_PREFIX . "product_description` pd ON (pd.product_id = p.product_id AND pd.language_id = '" . $language_id . "')
			LEFT JOIN `" . DB_PREFIX . "kristal_product_rental` r ON (r.product_id = p.product_id)
			LEFT JOIN `" . DB_PREFIX . "seo_url` su ON (su.query = CONCAT('product_id=', p.product_id) AND su.store_id = '" . $store_id . "' AND su.language_id = '" . $language_id . "')
			WHERE p.status = '1' AND p.date_available <= NOW()");

		$rows = array();

		foreach ($query->rows as $row) {
			$id = (int)$row['product_id'];

			if (isset($rows[$id])) {
				continue;
			}

			$rows[$id] = array(
				'product_id' => $id,
				'name'       => $row['name'],
				'price'      => (float)$row['price'],
				'image'      => (string)$row['image'],
				'unit'       => $row['unit'],
				'is_hit'     => (int)$row['is_hit'],
				'href'       => $this->productHref($id, (string)$row['keyword'])
			);
		}

		return array_slice(\Kristal\Search::sort(array_values($rows), $normalized, $tokens), 0, self::LIMIT);
	}

	/** Категорії меню теми (верхні й підкатегорії) — у PHP, з кешу меню */
	private function categories($normalized, $tokens, $variants) {
		$this->load->model('extension/kristal/menu');

		$found = array();

		foreach ($this->model_extension_kristal_menu->getTree() as $top) {
			$items = array_merge(array($top), $top['children']);

			foreach ($items as $item) {
				$words = \Kristal\Search::words($item['name']);
				$ok = true;

				foreach ($variants as $list) {
					if (!$this->anyPrefix($list, $words)) {
						$ok = false;
						break;
					}
				}

				if ($ok) {
					$found[] = array(
						'category_id' => (int)$item['category_id'],
						'name'        => $item['name'],
						'href'        => $item['href'],
						'rank'        => \Kristal\Search::rank($item['name'], $normalized, $tokens)
					);
				}
			}
		}

		usort($found, function ($a, $b) {
			return $a['rank'] - $b['rank'];
		});

		return $found;
	}

	private function anyPrefix($prefixes, $words) {
		foreach ($prefixes as $prefix) {
			foreach ($words as $word) {
				if (mb_strpos($word, $prefix, 0, 'UTF-8') === 0) {
					return true;
				}
			}
		}

		return false;
	}

	/** ЧПУ товару з того самого запиту (як rewrite у startup/seo_url: корінь сайту + keyword), інакше — url->link() */
	private function productHref($product_id, $keyword) {
		if ($keyword !== '' && $this->config->get('config_seo_url')) {
			$base = !empty($this->request->server['HTTPS']) ? $this->config->get('config_ssl') : $this->config->get('config_url');

			return rtrim($base, '/') . '/' . $keyword;
		}

		return $this->url->link('product/product', 'product_id=' . (int)$product_id);
	}
}
