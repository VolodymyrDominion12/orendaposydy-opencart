<?php
/**
 * Імпорт прайсу (фіча 022): каталог для плану й вивантаження, запис плану пакетами, знімок, відновлення, скасування, журнал.
 *
 * Таблиці товарів ядра — MyISAM, транзакцій немає. Тому: спершу журнал зі ЗНІМКОМ старих значень (status = applying),
 * потім запис; виняток → відновлення зі знімка (status = failed); PHP зупинився посередині → у журналі лишається
 * applying і кнопка «Відновити» (recover). Нові товари — моделлю ядра catalog/product (події 005 і 027 спрацьовують самі).
 *
 * Запити на імпорт (не на сторінку вітрини): каталог — 5; запис — O(товарів / CHUNK); новий товар — ~12 (addProduct ядра).
 */
class ModelExtensionKristalImport extends Model {
	const CHUNK = 500;

	/** Каталог для Kristal\Price_import::plan() і вивантаження */
	public function catalog() {
		$language_id = (int)$this->config->get('config_language_id');
		$group_id = $this->groupId();

		// Шлях кожної категорії «Посуд / Тарілки» і глибина
		$paths = array();
		$categories = array();
		$query = $this->db->query("SELECT cp.category_id, GROUP_CONCAT(cd.name ORDER BY cp.level SEPARATOR ' / ') AS path, MAX(cp.level) AS depth
			FROM `" . DB_PREFIX . "category_path` cp
			JOIN `" . DB_PREFIX . "category_description` cd ON (cd.category_id = cp.path_id AND cd.language_id = '" . $language_id . "')
			GROUP BY cp.category_id");

		foreach ($query->rows as $row) {
			$path = $this->decode($row['path']);
			$paths[(int)$row['category_id']] = array('path' => $path, 'depth' => (int)$row['depth']);
			$key = \Kristal\Price_import::pathKey($path);

			if (!isset($categories[$key])) {
				$categories[$key] = (int)$row['category_id'];
			}
		}

		$products = array();
		$query = $this->db->query("SELECT p.product_id, p.sku, p.price, p.minimum, p.status, pd.name
			FROM `" . DB_PREFIX . "product` p
			LEFT JOIN `" . DB_PREFIX . "product_description` pd ON (pd.product_id = p.product_id AND pd.language_id = '" . $language_id . "')");

		foreach ($query->rows as $row) {
			$id = (int)$row['product_id'];
			$products[$id] = array(
				'id' => $id, 'sku' => $this->decode($row['sku']), 'name' => $this->decode((string)$row['name']), 'category' => '', 'category_depth' => -1,
				'price' => round((float)$row['price'], 4), 'minimum' => max(1, (int)$row['minimum']), 'status' => (int)$row['status'],
				'unit' => \Kristal\Rental::DEFAULT_UNIT, 'deposit' => 0.0, 'breakage' => 0.0, 'washing' => 0, 'hit' => 0, 'discounts' => array(),
				'has_rental' => false
			);
		}

		// Категорія товару для вивантаження — найглибша (за рівністю — менший id)
		$query = $this->db->query("SELECT product_id, category_id FROM `" . DB_PREFIX . "product_to_category` ORDER BY category_id");

		foreach ($query->rows as $row) {
			$id = (int)$row['product_id'];
			$cid = (int)$row['category_id'];

			if (isset($products[$id]) && isset($paths[$cid]) && $paths[$cid]['depth'] > $products[$id]['category_depth']) {
				$products[$id]['category'] = $paths[$cid]['path'];
				$products[$id]['category_depth'] = $paths[$cid]['depth'];
			}
		}

		$query = $this->db->query("SELECT * FROM `" . DB_PREFIX . "kristal_product_rental`");

		foreach ($query->rows as $row) {
			$id = (int)$row['product_id'];

			if (isset($products[$id])) {
				$r = \Kristal\Rental::normalize($row);
				$products[$id]['unit'] = $r['unit'];
				$products[$id]['deposit'] = round((float)$r['deposit'], 4);
				$products[$id]['breakage'] = round((float)$r['breakage_price'], 4);
				$products[$id]['washing'] = (int)$r['washing_included'];
				$products[$id]['hit'] = (int)$r['is_hit'];
				$products[$id]['has_rental'] = true;
			}
		}

		$query = $this->db->query("SELECT product_id, quantity, price FROM `" . DB_PREFIX . "product_discount`
			WHERE customer_group_id = '" . $group_id . "' AND quantity > 1 ORDER BY product_id, quantity, priority, price");

		foreach ($query->rows as $row) {
			$id = (int)$row['product_id'];
			$qty = (int)$row['quantity'];

			if (isset($products[$id]) && !isset($products[$id]['discounts'][$qty])) {
				$products[$id]['discounts'][$qty] = round((float)$row['price'], 4);
			}
		}

		return array('products' => $products, 'categories' => $categories);
	}

	/** Рядки для Kristal\Price_csv::write(): за категорією й назвою */
	public function exportRows(array $catalog) {
		$products = array_values($catalog['products']);

		usort($products, function ($a, $b) {
			$c = strcmp(mb_strtolower($a['category'], 'UTF-8'), mb_strtolower($b['category'], 'UTF-8'));

			return $c ? $c : strcmp(mb_strtolower($a['name'], 'UTF-8'), mb_strtolower($b['name'], 'UTF-8'));
		});

		$units = \Kristal\Rental::units();
		$rows = array();

		foreach ($products as $p) {
			$rows[] = array(
				'id'        => $p['id'],
				'sku'       => $p['sku'],
				'name'      => $p['name'],
				'category'  => $p['category'],
				'price'     => \Kristal\Price_csv::formatNumber($p['price']),
				'unit'      => isset($units[$p['unit']]) ? $units[$p['unit']] : $p['unit'],
				'minimum'   => $p['minimum'],
				'discounts' => \Kristal\Price_csv::formatDiscounts($p['discounts']),
				'deposit'   => \Kristal\Price_csv::formatNumber($p['deposit']),
				'breakage'  => \Kristal\Price_csv::formatNumber($p['breakage']),
				'washing'   => \Kristal\Price_csv::formatBool($p['washing']),
				'hit'       => \Kristal\Price_csv::formatBool($p['hit']),
				'status'    => \Kristal\Price_csv::formatBool($p['status'])
			);
		}

		return $rows;
	}

	/**
	 * Записати план. Повертає import_id. Виняток — після відновлення зі знімка (status = failed) кидається далі.
	 * @param array $meta filename, user_id, username
	 */
	public function apply(array $plan, array $catalog, array $meta) {
		$snapshot = array('products' => array(), 'created' => array());

		foreach ($plan['updates'] as $id => $update) {
			$snapshot['products'][$id] = $this->snapshotOf($catalog['products'][$id]);
		}

		$summary = array('errors' => array_slice($plan['errors'], 0, 50), 'warnings' => array_slice($plan['warnings'], 0, 50));

		$this->db->query("INSERT INTO `" . DB_PREFIX . "kristal_import_log` SET created_at = NOW(),
			user_id = '" . (int)$meta['user_id'] . "', username = '" . $this->db->escape(utf8_substr((string)$meta['username'], 0, 20)) . "',
			filename = '" . $this->db->escape(utf8_substr((string)$meta['filename'], 0, 255)) . "', status = 'applying',
			rows_total = '" . (int)$plan['counts']['rows'] . "', changed = '" . count($plan['updates']) . "', created = 0,
			errors = '" . (int)$plan['counts']['errors'] . "',
			snapshot = '" . $this->db->escape(json_encode($snapshot)) . "', summary = '" . $this->db->escape(json_encode($summary)) . "'");

		$import_id = (int)$this->db->getLastId();

		try {
			$this->writeUpdates($plan['updates'], $catalog['products']);

			foreach ($plan['creates'] as $create) {
				$snapshot['created'][] = $this->createProduct($create);
				// Після кожного нового — у знімок: якщо PHP зупиниться, recover() їх знайде
				$this->saveSnapshot($import_id, $snapshot);
			}

			$this->db->query("UPDATE `" . DB_PREFIX . "kristal_import_log` SET status = 'applied', created = '" . count($snapshot['created']) . "'
				WHERE import_id = '" . $import_id . "'");
		} catch (\Exception $e) {
			$this->restore($snapshot, true);
			$this->db->query("UPDATE `" . DB_PREFIX . "kristal_import_log` SET status = 'failed' WHERE import_id = '" . $import_id . "'");
			$this->afterChange(array_keys($snapshot['products']));

			throw $e;
		}

		$this->afterChange($this->skuChanged($plan['updates']));

		return $import_id;
	}

	/**
	 * Скасувати імпорт (лише останній застосований) або відновити обірваний (status = applying).
	 * @return array|string попередження [назви товарів, які не видалено, бо їх увімкнули] або код помилки
	 */
	public function undo($import_id) {
		$log = $this->getImport($import_id);

		if (!$log) {
			return 'not_found';
		}

		if ($log['status'] === 'applied') {
			$latest = $this->db->query("SELECT import_id FROM `" . DB_PREFIX . "kristal_import_log` WHERE status IN ('applied', 'applying')
				ORDER BY import_id DESC LIMIT 1");

			if (!$latest->num_rows || (int)$latest->row['import_id'] !== (int)$import_id) {
				return 'not_latest';
			}

			$new_status = 'undone';
			$force = false;
		} elseif ($log['status'] === 'applying') {
			$new_status = 'failed';
			$force = true;
		} else {
			return 'not_applied';
		}

		$snapshot = json_decode($log['snapshot'], true);

		if (!is_array($snapshot)) {
			return 'bad_snapshot';
		}

		$kept = $this->restore($snapshot, $force);

		$this->db->query("UPDATE `" . DB_PREFIX . "kristal_import_log` SET status = '" . $this->db->escape($new_status) . "' WHERE import_id = '" . (int)$import_id . "'");
		$this->afterChange(array_keys(isset($snapshot['products']) ? $snapshot['products'] : array()));

		return $kept;
	}

	public function getImport($import_id) {
		$query = $this->db->query("SELECT * FROM `" . DB_PREFIX . "kristal_import_log` WHERE import_id = '" . (int)$import_id . "'");

		return $query->num_rows ? $query->row : null;
	}

	public function getLog($limit = 20) {
		$query = $this->db->query("SELECT import_id, created_at, username, filename, status, rows_total, changed, created, errors
			FROM `" . DB_PREFIX . "kristal_import_log` ORDER BY import_id DESC LIMIT " . (int)$limit);

		return $query->rows;
	}

	// ---------------------------------------------------------------- запис

	private function writeUpdates(array $updates, array $products) {
		$product_cols = array('sku' => 'sku', 'price' => 'price', 'minimum' => 'minimum', 'status' => 'status');
		$rental_fields = array('unit', 'deposit', 'breakage', 'washing', 'hit');
		$by_col = array();
		$rental = array();
		$discounts = array();
		$touched = array();

		foreach ($updates as $id => $update) {
			foreach ($update['fields'] as $field => $value) {
				if (isset($product_cols[$field])) {
					$by_col[$product_cols[$field]][$id] = $value;
					$touched[$id] = true;
				} elseif (in_array($field, $rental_fields, true)) {
					$rental[$id] = true;
				} elseif ($field === 'discounts') {
					$discounts[$id] = $value;
				}
			}
		}

		foreach ($by_col as $col => $values) {
			$this->updateColumn($col, $values);
		}

		// Оренда — рядок цілком: старі значення + нові
		$rows = array();

		foreach (array_keys($rental) as $id) {
			$p = array_merge($products[$id], $updates[$id]['fields']);
			$rows[$id] = array('unit' => $p['unit'], 'deposit' => $p['deposit'], 'breakage' => $p['breakage'], 'washing' => $p['washing'], 'hit' => $p['hit']);
		}

		$this->upsertRental($rows);
		$this->replaceDiscounts($discounts);

		$modified = array_keys($touched + $rental + $discounts);

		foreach (array_chunk($modified, self::CHUNK) as $chunk) {
			$this->db->query("UPDATE `" . DB_PREFIX . "product` SET date_modified = NOW() WHERE product_id IN (" . implode(',', array_map('intval', $chunk)) . ")");
		}
	}

	/** UPDATE product SET col = CASE product_id WHEN … END WHERE product_id IN (…) — пачками */
	private function updateColumn($col, array $values) {
		foreach (array_chunk($values, self::CHUNK, true) as $chunk) {
			$case = '';

			foreach ($chunk as $id => $value) {
				$case .= " WHEN '" . (int)$id . "' THEN " . $this->sqlValue($col, $value);
			}

			$this->db->query("UPDATE `" . DB_PREFIX . "product` SET `" . $col . "` = CASE product_id" . $case . " ELSE `" . $col . "` END
				WHERE product_id IN (" . implode(',', array_map('intval', array_keys($chunk))) . ")");
		}
	}

	private function sqlValue($col, $value) {
		switch ($col) {
			case 'sku':
				// Як форма ядра: Request кодує htmlspecialchars, catalog() декодує
				return "'" . $this->db->escape(htmlspecialchars((string)$value, ENT_COMPAT, 'UTF-8')) . "'";
			case 'price':
				return "'" . (float)$value . "'";
			default:
				return "'" . (int)$value . "'";
		}
	}

	/** @param array $rows [id => [unit, deposit, breakage, washing, hit]] */
	private function upsertRental(array $rows) {
		foreach (array_chunk($rows, self::CHUNK, true) as $chunk) {
			$values = array();

			foreach ($chunk as $id => $r) {
				$unit = \Kristal\Rental::isUnit($r['unit']) ? $r['unit'] : \Kristal\Rental::DEFAULT_UNIT;
				$values[] = "('" . (int)$id . "', '" . $this->db->escape($unit) . "', '" . (float)$r['deposit'] . "', '" . (float)$r['breakage'] . "', '"
					. ((int)$r['washing'] ? 1 : 0) . "', '" . ((int)$r['hit'] ? 1 : 0) . "')";
			}

			if ($values) {
				$this->db->query("INSERT INTO `" . DB_PREFIX . "kristal_product_rental` (product_id, unit, deposit, breakage_price, washing_included, is_hit)
					VALUES " . implode(', ', $values) . "
					ON DUPLICATE KEY UPDATE unit = VALUES(unit), deposit = VALUES(deposit), breakage_price = VALUES(breakage_price),
					washing_included = VALUES(washing_included), is_hit = VALUES(is_hit)");
			}
		}
	}

	/** Знижки групи за замовчуванням — список цілком: [id => [кількість => ціна]] */
	private function replaceDiscounts(array $discounts) {
		$group_id = $this->groupId();

		foreach (array_chunk($discounts, self::CHUNK, true) as $chunk) {
			$this->db->query("DELETE FROM `" . DB_PREFIX . "product_discount` WHERE customer_group_id = '" . $group_id . "'
				AND product_id IN (" . implode(',', array_map('intval', array_keys($chunk))) . ")");

			$values = array();

			foreach ($chunk as $id => $tiers) {
				foreach ((array)$tiers as $qty => $price) {
					$values[] = "('" . (int)$id . "', '" . $group_id . "', '" . (int)$qty . "', '1', '" . (float)$price . "', '0000-00-00', '0000-00-00')";
				}
			}

			if ($values) {
				$this->db->query("INSERT INTO `" . DB_PREFIX . "product_discount` (product_id, customer_group_id, quantity, priority, price, date_start, date_end)
					VALUES " . implode(', ', $values));
			}
		}
	}

	private function createProduct(array $c) {
		$this->load->model('catalog/product');
		$this->load->model('localisation/language');

		static $taken = null;

		if ($taken === null) {
			$taken = array();

			foreach ($this->db->query("SELECT keyword FROM `" . DB_PREFIX . "seo_url`")->rows as $row) {
				$taken[(string)$row['keyword']] = true;
			}
		}

		$slug = \Kristal\Slug::unique($c['name'], $taken);
		$name = htmlspecialchars($c['name'], ENT_COMPAT, 'UTF-8'); // як зберігає форма ядра (Request кодує)
		$description = array();
		$seo = array();

		foreach ($this->model_localisation_language->getLanguages() as $language) {
			$lid = (int)$language['language_id'];
			$description[$lid] = array('name' => $name, 'description' => '', 'description_excerpt' => '', 'description_add' => '',
				'tag' => '', 'meta_title' => $name, 'meta_description' => '', 'meta_keyword' => '');
			$seo[0][$lid] = $slug;
		}

		// Категорія з усіма батьківськими — як у товарів каталогу
		$category_ids = array();

		foreach ($this->db->query("SELECT path_id FROM `" . DB_PREFIX . "category_path` WHERE category_id = '" . (int)$c['category_id'] . "'")->rows as $row) {
			$category_ids[] = (int)$row['path_id'];
		}

		$discounts = array();

		foreach ($c['discounts'] as $qty => $price) {
			$discounts[] = array('customer_group_id' => $this->groupId(), 'quantity' => (int)$qty, 'priority' => 1, 'price' => (float)$price,
				'date_start' => '0000-00-00', 'date_end' => '0000-00-00');
		}

		$data = array(
			'model' => htmlspecialchars($c['sku'], ENT_COMPAT, 'UTF-8'), 'sku' => htmlspecialchars($c['sku'], ENT_COMPAT, 'UTF-8'), 'upc' => '', 'ean' => '', 'jan' => '', 'isbn' => '', 'mpn' => '', 'location' => '',
			'quantity' => 2000, 'minimum' => (int)$c['minimum'], 'subtract' => 0, 'stock_status_id' => (int)$this->config->get('config_stock_status_id'),
			'date_available' => date('Y-m-d'), 'manufacturer_id' => 0, 'shipping' => 1, 'price' => (float)$c['price'], 'points' => 0,
			'weight' => 0, 'weight_class_id' => (int)$this->config->get('config_weight_class_id'), 'length' => 0, 'width' => 0, 'height' => 0,
			'length_class_id' => (int)$this->config->get('config_length_class_id'), 'status' => 0, 'tax_class_id' => 0, 'sort_order' => 0,
			'product_description' => $description, 'product_store' => array(0), 'product_category' => $category_ids ? $category_ids : array((int)$c['category_id']),
			'product_discount' => $discounts, 'product_seo_url' => $seo
		);

		$product_id = (int)$this->model_catalog_product->addProduct($data);

		$this->upsertRental(array($product_id => array('unit' => $c['unit'], 'deposit' => $c['deposit'], 'breakage' => $c['breakage'],
			'washing' => $c['washing'], 'hit' => $c['hit'])));

		return $product_id;
	}

	// ---------------------------------------------------------------- знімок і відновлення

	private function snapshotOf(array $p) {
		return array(
			'sku' => $p['sku'], 'price' => $p['price'], 'minimum' => $p['minimum'], 'status' => $p['status'],
			'rental' => $p['has_rental'] ? array('unit' => $p['unit'], 'deposit' => $p['deposit'], 'breakage' => $p['breakage'], 'washing' => $p['washing'], 'hit' => $p['hit']) : null,
			'discounts' => $p['discounts']
		);
	}

	private function saveSnapshot($import_id, array $snapshot) {
		$this->db->query("UPDATE `" . DB_PREFIX . "kristal_import_log` SET snapshot = '" . $this->db->escape(json_encode($snapshot)) . "',
			created = '" . count($snapshot['created']) . "' WHERE import_id = '" . (int)$import_id . "'");
	}

	/**
	 * Повернути значення зі знімка; створені товари видалити ($force — завжди; інакше лише ще вимкнені).
	 * @return array назви створених товарів, які не видалено (їх уже увімкнули)
	 */
	private function restore(array $snapshot, $force) {
		$products = isset($snapshot['products']) ? $snapshot['products'] : array();
		$cols = array('sku' => array(), 'price' => array(), 'minimum' => array(), 'status' => array());
		$rental = array();
		$no_rental = array();
		$discounts = array();

		foreach ($products as $id => $old) {
			foreach (array_keys($cols) as $col) {
				$cols[$col][(int)$id] = $old[$col];
			}

			if (is_array($old['rental'])) {
				$rental[(int)$id] = $old['rental'];
			} else {
				$no_rental[] = (int)$id;
			}

			$discounts[(int)$id] = (array)$old['discounts'];
		}

		foreach ($cols as $col => $values) {
			if ($values) {
				$this->updateColumn($col, $values);
			}
		}

		$this->upsertRental($rental);

		foreach (array_chunk($no_rental, self::CHUNK) as $chunk) {
			$this->db->query("DELETE FROM `" . DB_PREFIX . "kristal_product_rental` WHERE product_id IN (" . implode(',', $chunk) . ")");
		}

		$this->replaceDiscounts($discounts);

		$kept = array();
		$created = isset($snapshot['created']) ? array_map('intval', $snapshot['created']) : array();

		if ($created) {
			$this->load->model('catalog/product');

			foreach ($created as $id) {
				$product = $this->model_catalog_product->getProduct($id);

				if (!$product) {
					continue;
				}

				if ($force || !(int)$product['status']) {
					$this->model_catalog_product->deleteProduct($id); // події 005/027 прибирають оренду й індекс
				} else {
					$kept[] = $this->decode($product['name']);
				}
			}
		}

		return $kept;
	}

	// ---------------------------------------------------------------- службове

	/** Кеш вітрини; індекс пошуку — для товарів зі зміненим артикулом (назви імпорт не змінює) */
	private function afterChange(array $reindex_ids) {
		\Kristal\Cache_key::flush($this->cache);
		$this->cache->delete('product');

		if ($reindex_ids) {
			$this->load->model('extension/kristal/search');

			foreach ($reindex_ids as $id) {
				$this->model_extension_kristal_search->indexProduct((int)$id);
			}
		}
	}

	private function skuChanged(array $updates) {
		$ids = array();

		foreach ($updates as $id => $update) {
			if (array_key_exists('sku', $update['fields'])) {
				$ids[] = (int)$id;
			}
		}

		return $ids;
	}

	private function groupId() {
		return (int)$this->config->get('config_customer_group_id');
	}

	private function decode($s) {
		return html_entity_decode((string)$s, ENT_QUOTES, 'UTF-8');
	}
}
