<?php
/**
 * «Крістал: фільтри» (фіча 021), адмінка: SEO-сторінки фільтрів, масове призначення значень товарам категорії,
 * початкове заповнення фільтрів ядра з атрибутів (план → запис → скасування).
 * Групи/значення/призначення — таблиці ядра oc_filter*, oc_product_filter. Кеш вітрини kristal.* скидає контролер.
 */
class ModelExtensionKristalFilter extends Model {
	const SEED = 'module_kristal_filter_seed';

	/** Атрибути мок-каталогу → групи фільтрів: [назва атрибута => [група, вид, порядок групи]] */
	private static $seed_map = array(
		'Матеріал'      => array('Матеріал', 'material', 1),
		'Колір'         => array('Колір', 'split', 2),
		'Серія / стиль' => array('Серія / стиль', 'split', 3),
		'Розмір'        => array('Розмір', 'size', 4),
		"Об'єм"         => array("Об'єм", 'volume', 5),
		'Об’єм'         => array("Об'єм", 'volume', 5)
	);

	// --- Довідник значень --------------------------------------------------------------------------

	/** [group_id => ['name', 'values' => [filter_id => name]]] у порядку ядра */
	public function getValues() {
		$language_id = (int)$this->config->get('config_language_id');

		$query = $this->db->query("SELECT f.filter_id, f.filter_group_id, fd.name, fgd.name AS group_name
			FROM `" . DB_PREFIX . "filter_group` fg
			JOIN `" . DB_PREFIX . "filter_group_description` fgd ON (fgd.filter_group_id = fg.filter_group_id AND fgd.language_id = '" . $language_id . "')
			JOIN `" . DB_PREFIX . "filter` f ON (f.filter_group_id = fg.filter_group_id)
			JOIN `" . DB_PREFIX . "filter_description` fd ON (fd.filter_id = f.filter_id AND fd.language_id = '" . $language_id . "')
			ORDER BY fg.sort_order, LCASE(fgd.name), fg.filter_group_id, f.sort_order, LCASE(fd.name)");

		$groups = array();

		foreach ($query->rows as $row) {
			$gid = (int)$row['filter_group_id'];

			if (!isset($groups[$gid])) {
				$groups[$gid] = array('name' => $row['group_name'], 'values' => array());
			}

			$groups[$gid]['values'][(int)$row['filter_id']] = $row['name'];
		}

		return $groups;
	}

	// --- SEO-сторінки -----------------------------------------------------------------------------

	public function getPages() {
		$query = $this->db->query("SELECT p.filter_page_id, p.category_id, p.filter_ids, p.keyword, p.h1, p.status, cd.name AS category
			FROM `" . DB_PREFIX . "kristal_filter_page` p
			LEFT JOIN `" . DB_PREFIX . "category_description` cd ON (cd.category_id = p.category_id AND cd.language_id = '" . (int)$this->config->get('config_language_id') . "')
			ORDER BY cd.name, p.keyword LIMIT 500");

		return $query->rows;
	}

	public function getPage($filter_page_id) {
		$query = $this->db->query("SELECT * FROM `" . DB_PREFIX . "kristal_filter_page` WHERE filter_page_id = '" . (int)$filter_page_id . "'");

		return $query->row;
	}

	/**
	 * Перевірка перед збереженням. $data — POST (уже закодований Request ядра).
	 * @return array [поле => код помилки]
	 */
	public function validatePage($data, $filter_page_id = 0) {
		$errors = array();
		$category_id = isset($data['category_id']) ? (int)$data['category_id'] : 0;
		$keyword = isset($data['keyword']) ? (string)$data['keyword'] : '';
		$fids = $this->pageFilterIds($data);

		if (!$category_id || !$this->db->query("SELECT 1 FROM `" . DB_PREFIX . "category` WHERE category_id = '" . $category_id . "'")->num_rows) {
			$errors['category_id'] = 'error_category';
		}

		if (!$fids || count($fids) > 2) {
			$errors['filters'] = 'error_filters';
		} elseif (count($fids) !== (int)$this->db->query("SELECT COUNT(*) AS n FROM `" . DB_PREFIX . "filter` WHERE filter_id IN (" . implode(',', $fids) . ")")->row['n']) {
			$errors['filters'] = 'error_filters';
		}

		if (!preg_match('/^[a-z0-9]+(?:-[a-z0-9]+)*$/', $keyword) || strlen($keyword) > 64) {
			$errors['keyword'] = 'error_keyword';
		} elseif ($category_id) {
			// Унікальність у категорії; і не збігається з ЧПУ іншої сторінки (інакше seo_url знайде її раніше за нас)
			$dup = $this->db->query("SELECT 1 FROM `" . DB_PREFIX . "kristal_filter_page` WHERE category_id = '" . $category_id . "'
				AND keyword = '" . $this->db->escape($keyword) . "' AND filter_page_id <> '" . (int)$filter_page_id . "'");
			$seo = $this->db->query("SELECT 1 FROM `" . DB_PREFIX . "seo_url` WHERE store_id = '0' AND keyword = '" . $this->db->escape($keyword) . "'");

			if ($dup->num_rows || $seo->num_rows) {
				$errors['keyword'] = 'error_keyword_exists';
			}
		}

		if (!isset($errors['filters']) && !isset($errors['category_id'])) {
			$dup = $this->db->query("SELECT 1 FROM `" . DB_PREFIX . "kristal_filter_page` WHERE category_id = '" . $category_id . "'
				AND filter_ids = '" . $this->db->escape(implode(',', $fids)) . "' AND filter_page_id <> '" . (int)$filter_page_id . "'");

			if ($dup->num_rows) {
				$errors['filters'] = 'error_filters_exists';
			}
		}

		if (!isset($data['h1']) || utf8_strlen(trim((string)$data['h1'])) < 3 || utf8_strlen((string)$data['h1']) > 255) {
			$errors['h1'] = 'error_h1';
		}

		foreach (array('title', 'description') as $field) {
			if (isset($data[$field]) && utf8_strlen((string)$data[$field]) > 255) {
				$errors[$field] = 'error_long';
			}
		}

		return $errors;
	}

	public function savePage($data, $filter_page_id = 0) {
		$fields = "category_id = '" . (int)$data['category_id'] . "',
			filter_ids = '" . $this->db->escape(implode(',', $this->pageFilterIds($data))) . "',
			keyword = '" . $this->db->escape((string)$data['keyword']) . "',
			h1 = '" . $this->db->escape(trim((string)$data['h1'])) . "',
			title = '" . $this->db->escape(isset($data['title']) ? trim((string)$data['title']) : '') . "',
			description = '" . $this->db->escape(isset($data['description']) ? trim((string)$data['description']) : '') . "',
			`text` = '" . $this->db->escape(isset($data['text']) ? (string)$data['text'] : '') . "',
			status = '" . (!empty($data['status']) ? 1 : 0) . "',
			date_modified = NOW()";

		if ($filter_page_id) {
			$this->db->query("UPDATE `" . DB_PREFIX . "kristal_filter_page` SET " . $fields . " WHERE filter_page_id = '" . (int)$filter_page_id . "'");

			return (int)$filter_page_id;
		}

		$this->db->query("INSERT INTO `" . DB_PREFIX . "kristal_filter_page` SET " . $fields);

		return (int)$this->db->getLastId();
	}

	public function deletePage($filter_page_id) {
		$this->db->query("DELETE FROM `" . DB_PREFIX . "kristal_filter_page` WHERE filter_page_id = '" . (int)$filter_page_id . "'");
	}

	/** Відсортовані унікальні id значень сторінки з POST filters[] */
	public function pageFilterIds($data) {
		$fids = isset($data['filters']) && is_array($data['filters']) ? array_map('intval', $data['filters']) : array();
		$fids = array_values(array_unique(array_filter($fids)));
		sort($fids);

		return $fids;
	}

	// --- Масове призначення -----------------------------------------------------------------------

	public function getCategoryProducts($category_id, $limit = 200) {
		$query = $this->db->query("SELECT p.product_id, p.model, p.sku, p.status, pd.name, GROUP_CONCAT(pf.filter_id) AS fids
			FROM `" . DB_PREFIX . "product_to_category` p2c
			JOIN `" . DB_PREFIX . "product` p ON (p.product_id = p2c.product_id)
			LEFT JOIN `" . DB_PREFIX . "product_description` pd ON (pd.product_id = p.product_id AND pd.language_id = '" . (int)$this->config->get('config_language_id') . "')
			LEFT JOIN `" . DB_PREFIX . "product_filter` pf ON (pf.product_id = p.product_id)
			WHERE p2c.category_id = '" . (int)$category_id . "'
			GROUP BY p.product_id
			ORDER BY p.sort_order, pd.name
			LIMIT " . (int)$limit);

		$products = array();

		foreach ($query->rows as $row) {
			$row['filters'] = $row['fids'] !== null && $row['fids'] !== '' ? array_map('intval', explode(',', $row['fids'])) : array();
			$products[(int)$row['product_id']] = $row;
		}

		return $products;
	}

	/**
	 * Повністю замінює значення фільтрів у переданих товарах: [product_id => [filter_id, …]]. 2 запити на будь-яку кількість товарів.
	 * Невідомі filter_id відкидаються.
	 */
	public function saveAssignments(array $assign) {
		$ids = array_values(array_filter(array_map('intval', array_keys($assign))));

		if (!$ids) {
			return 0;
		}

		$known = array();

		foreach ($this->getValues() as $group) {
			foreach ($group['values'] as $fid => $name) {
				$known[$fid] = true;
			}
		}

		$rows = array();

		foreach ($assign as $product_id => $fids) {
			foreach (array_unique(array_map('intval', (array)$fids)) as $fid) {
				if (isset($known[$fid])) {
					$rows[] = "('" . (int)$product_id . "', '" . $fid . "')";
				}
			}
		}

		$this->db->query("DELETE FROM `" . DB_PREFIX . "product_filter` WHERE product_id IN (" . implode(',', $ids) . ")");

		foreach (array_chunk($rows, 500) as $chunk) {
			$this->db->query("INSERT IGNORE INTO `" . DB_PREFIX . "product_filter` (product_id, filter_id) VALUES " . implode(',', $chunk));
		}

		return count($rows);
	}

	public function getCategories() {
		$query = $this->db->query("SELECT cp.category_id, GROUP_CONCAT(cd.name ORDER BY cp.level SEPARATOR ' > ') AS name
			FROM `" . DB_PREFIX . "category_path` cp
			JOIN `" . DB_PREFIX . "category_description` cd ON (cd.category_id = cp.path_id AND cd.language_id = '" . (int)$this->config->get('config_language_id') . "')
			GROUP BY cp.category_id
			ORDER BY name
			LIMIT 1000");

		return $query->rows;
	}

	// --- Заповнення з атрибутів (AC-13) ----------------------------------------------------------

	/**
	 * План: які групи/значення з'являться і скільком товарам призначаться. Нічого не пише.
	 * @return array ['groups' => [назва => ['exists' => bool, 'sort' => n, 'values' => [назва => ['exists' => bool, 'sort' => n, 'products' => [id => true]]]]],
	 *                'pairs' => кількість нових призначень, 'skipped' => [атрибут => ['текст' => n]]]
	 */
	public function seedPlan() {
		$language_id = (int)$this->config->get('config_language_id');
		$names = array_keys(self::$seed_map);
		$escaped = array();

		foreach ($names as $name) {
			$escaped[] = "'" . $this->db->escape(htmlspecialchars($name, ENT_QUOTES, 'UTF-8')) . "'";
			$escaped[] = "'" . $this->db->escape($name) . "'";
		}

		$query = $this->db->query("SELECT pa.product_id, ad.name AS attribute, pa.text
			FROM `" . DB_PREFIX . "attribute_description` ad
			JOIN `" . DB_PREFIX . "product_attribute` pa ON (pa.attribute_id = ad.attribute_id AND pa.language_id = ad.language_id)
			WHERE ad.language_id = '" . $language_id . "' AND ad.name IN (" . implode(',', array_unique($escaped)) . ")");

		$existing = $this->existing();
		$current = $this->currentPairs();
		$plan = array('groups' => array(), 'pairs' => 0, 'skipped' => array());

		foreach ($query->rows as $row) {
			$attribute = html_entity_decode($row['attribute'], ENT_QUOTES, 'UTF-8');

			if (!isset(self::$seed_map[$attribute])) {
				continue;
			}

			list($group, $kind, $gsort) = self::$seed_map[$attribute];
			$text = html_entity_decode($row['text'], ENT_QUOTES, 'UTF-8');
			$values = array();

			if ($kind === 'split' || $kind === 'material') {
				foreach (\Kristal\Filter::splitValues($text, $kind === 'split') as $value) {
					$values[$value] = 0;
				}
			} else {
				$bucket = \Kristal\Filter::bucket($text, $kind);

				if ($bucket) {
					$values[$bucket['label']] = $bucket['sort'];
				} else {
					$plan['skipped'][$attribute][$text] = isset($plan['skipped'][$attribute][$text]) ? $plan['skipped'][$attribute][$text] + 1 : 1;
				}
			}

			foreach ($values as $value => $vsort) {
				$gkey = mb_strtolower($group, 'UTF-8');
				$vkey = mb_strtolower($value, 'UTF-8');

				if (!isset($plan['groups'][$group])) {
					$plan['groups'][$group] = array('exists' => isset($existing[$gkey]), 'sort' => $gsort, 'values' => array());
				}

				if (!isset($plan['groups'][$group]['values'][$value])) {
					$plan['groups'][$group]['values'][$value] = array(
						'exists'   => isset($existing[$gkey]['values'][$vkey]),
						'sort'     => $vsort,
						'products' => array()
					);
				}

				$pid = (int)$row['product_id'];
				$fid = isset($existing[$gkey]['values'][$vkey]) ? $existing[$gkey]['values'][$vkey] : 0;

				if (!isset($plan['groups'][$group]['values'][$value]['products'][$pid]) && !($fid && isset($current[$pid . ':' . $fid]))) {
					$plan['pairs']++;
				}

				$plan['groups'][$group]['values'][$value]['products'][$pid] = true;
			}
		}

		uasort($plan['groups'], function ($a, $b) {
			return $a['sort'] <=> $b['sort'];
		});

		foreach ($plan['groups'] as $group => $info) {
			uksort($plan['groups'][$group]['values'], function ($a, $b) use ($info) {
				$c = $info['values'][$a]['sort'] <=> $info['values'][$b]['sort'];

				return $c !== 0 ? $c : strcmp(mb_strtolower($a, 'UTF-8'), mb_strtolower($b, 'UTF-8'));
			});
		}

		return $plan;
	}

	/**
	 * Записати план: нові групи/значення + призначення (INSERT IGNORE). Що створено — у налаштуванні для скасування.
	 * @return array ['groups' => n, 'values' => n, 'pairs' => n]
	 */
	public function seedApply() {
		$plan = $this->seedPlan();
		$existing = $this->existing();
		$current = $this->currentPairs();
		$log = $this->seedLog();
		$languages = $this->db->query("SELECT language_id FROM `" . DB_PREFIX . "language`")->rows;
		$stats = array('groups' => 0, 'values' => 0, 'pairs' => 0);
		$rows = array();

		foreach ($plan['groups'] as $group => $info) {
			$gkey = mb_strtolower($group, 'UTF-8');

			if (isset($existing[$gkey])) {
				$gid = $existing[$gkey]['id'];
			} else {
				$this->db->query("INSERT INTO `" . DB_PREFIX . "filter_group` SET sort_order = '" . (int)$info['sort'] . "'");
				$gid = (int)$this->db->getLastId();

				foreach ($languages as $language) {
					$this->db->query("INSERT INTO `" . DB_PREFIX . "filter_group_description` SET filter_group_id = '" . $gid . "', language_id = '" . (int)$language['language_id'] . "',
						name = '" . $this->db->escape(htmlspecialchars($group, ENT_QUOTES, 'UTF-8')) . "'");
				}

				$existing[$gkey] = array('id' => $gid, 'values' => array());
				$log['groups'][] = $gid;
				$stats['groups']++;
			}

			$n = 0;

			foreach ($info['values'] as $value => $vinfo) {
				$vkey = mb_strtolower($value, 'UTF-8');
				$n++;

				if (isset($existing[$gkey]['values'][$vkey])) {
					$fid = $existing[$gkey]['values'][$vkey];
				} else {
					$this->db->query("INSERT INTO `" . DB_PREFIX . "filter` SET filter_group_id = '" . $gid . "', sort_order = '" . ($vinfo['sort'] ? (int)$vinfo['sort'] : 0) . "'");
					$fid = (int)$this->db->getLastId();

					foreach ($languages as $language) {
						$this->db->query("INSERT INTO `" . DB_PREFIX . "filter_description` SET filter_id = '" . $fid . "', language_id = '" . (int)$language['language_id'] . "',
							filter_group_id = '" . $gid . "', name = '" . $this->db->escape(htmlspecialchars($value, ENT_QUOTES, 'UTF-8')) . "'");
					}

					$existing[$gkey]['values'][$vkey] = $fid;
					$log['values'][] = $fid;
					$stats['values']++;
				}

				foreach ($vinfo['products'] as $pid => $on) {
					if (!isset($current[$pid . ':' . $fid])) {
						$current[$pid . ':' . $fid] = true;
						$rows[] = "('" . (int)$pid . "', '" . (int)$fid . "')";
						$log['pairs'][] = array((int)$pid, (int)$fid);
					}
				}
			}
		}

		foreach (array_chunk($rows, 500) as $chunk) {
			$this->db->query("INSERT IGNORE INTO `" . DB_PREFIX . "product_filter` (product_id, filter_id) VALUES " . implode(',', $chunk));
		}

		$stats['pairs'] = count($rows);
		$this->saveSeedLog($log);

		return $stats;
	}

	/** Скасувати заповнення: прибрати додані призначення, значення й групи (лише створені заповненням). */
	public function seedUndo() {
		$log = $this->seedLog();
		$stats = array('groups' => count($log['groups']), 'values' => count($log['values']), 'pairs' => count($log['pairs']));

		foreach (array_chunk($log['pairs'], 500) as $chunk) {
			$where = array();

			foreach ($chunk as $pair) {
				$where[] = "(product_id = '" . (int)$pair[0] . "' AND filter_id = '" . (int)$pair[1] . "')";
			}

			$this->db->query("DELETE FROM `" . DB_PREFIX . "product_filter` WHERE " . implode(' OR ', $where));
		}

		if ($log['values']) {
			$ids = implode(',', array_map('intval', $log['values']));
			$this->db->query("DELETE FROM `" . DB_PREFIX . "product_filter` WHERE filter_id IN (" . $ids . ")");
			$this->db->query("DELETE FROM `" . DB_PREFIX . "filter_description` WHERE filter_id IN (" . $ids . ")");
			$this->db->query("DELETE FROM `" . DB_PREFIX . "filter` WHERE filter_id IN (" . $ids . ")");
		}

		if ($log['groups']) {
			$ids = implode(',', array_map('intval', $log['groups']));
			// Значення, додані в ці групи вручну після заповнення, теж ідуть разом із групою
			$this->db->query("DELETE pf FROM `" . DB_PREFIX . "product_filter` pf JOIN `" . DB_PREFIX . "filter` f ON (f.filter_id = pf.filter_id) WHERE f.filter_group_id IN (" . $ids . ")");
			$this->db->query("DELETE FROM `" . DB_PREFIX . "filter_description` WHERE filter_group_id IN (" . $ids . ")");
			$this->db->query("DELETE FROM `" . DB_PREFIX . "filter` WHERE filter_group_id IN (" . $ids . ")");
			$this->db->query("DELETE FROM `" . DB_PREFIX . "filter_group_description` WHERE filter_group_id IN (" . $ids . ")");
			$this->db->query("DELETE FROM `" . DB_PREFIX . "filter_group` WHERE filter_group_id IN (" . $ids . ")");
		}

		$this->saveSeedLog(array('groups' => array(), 'values' => array(), 'pairs' => array()));

		return $stats;
	}

	public function seedLog() {
		$query = $this->db->query("SELECT value FROM `" . DB_PREFIX . "setting` WHERE store_id = '0' AND `key` = '" . self::SEED . "'");
		$log = $query->num_rows ? json_decode($query->row['value'], true) : null;

		if (!is_array($log)) {
			$log = array();
		}

		return array(
			'groups' => isset($log['groups']) ? (array)$log['groups'] : array(),
			'values' => isset($log['values']) ? (array)$log['values'] : array(),
			'pairs'  => isset($log['pairs']) ? (array)$log['pairs'] : array()
		);
	}

	private function saveSeedLog($log) {
		$this->db->query("DELETE FROM `" . DB_PREFIX . "setting` WHERE store_id = '0' AND `key` = '" . self::SEED . "'");

		if ($log['groups'] || $log['values'] || $log['pairs']) {
			// Окремий code: editSetting('module_kristal_filter') при встановленні модуля не має стерти журнал заповнення
			$this->db->query("INSERT INTO `" . DB_PREFIX . "setting` SET store_id = '0', `code` = 'kristal_filter_seed', `key` = '" . self::SEED . "',
				value = '" . $this->db->escape(json_encode($log)) . "', serialized = '1'");
		}
	}

	/** Наявні групи/значення за назвою (без регістру): [група => ['id', 'values' => [значення => filter_id]]] */
	private function existing() {
		$result = array();

		foreach ($this->getValues() as $gid => $group) {
			$key = mb_strtolower(html_entity_decode($group['name'], ENT_QUOTES, 'UTF-8'), 'UTF-8');
			$result[$key] = array('id' => $gid, 'values' => array());

			foreach ($group['values'] as $fid => $name) {
				$result[$key]['values'][mb_strtolower(html_entity_decode($name, ENT_QUOTES, 'UTF-8'), 'UTF-8')] = $fid;
			}
		}

		// Групи без жодного значення getValues() не бачить
		$query = $this->db->query("SELECT fg.filter_group_id, fgd.name FROM `" . DB_PREFIX . "filter_group` fg
			JOIN `" . DB_PREFIX . "filter_group_description` fgd ON (fgd.filter_group_id = fg.filter_group_id AND fgd.language_id = '" . (int)$this->config->get('config_language_id') . "')");

		foreach ($query->rows as $row) {
			$key = mb_strtolower(html_entity_decode($row['name'], ENT_QUOTES, 'UTF-8'), 'UTF-8');

			if (!isset($result[$key])) {
				$result[$key] = array('id' => (int)$row['filter_group_id'], 'values' => array());
			}
		}

		return $result;
	}

	private function currentPairs() {
		$pairs = array();

		foreach ($this->db->query("SELECT product_id, filter_id FROM `" . DB_PREFIX . "product_filter`")->rows as $row) {
			$pairs[$row['product_id'] . ':' . $row['filter_id']] = true;
		}

		return $pairs;
	}
}
