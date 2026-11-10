<?php
namespace Kristal;

/**
 * План імпорту прайсу (фіча 022): рядки CSV (Price_csv::read) + каталог → що зміниться, що створиться, помилки, попередження.
 * Нічого не пише в БД — це робить модель адмінки extension/kristal/import за готовим планом.
 *
 * Каталог (модель адмінки → catalog()):
 *   products   [id => [id, sku, name, category, price, minimum, status, unit, deposit, breakage, washing, hit, discounts [кількість => ціна]]]
 *   categories [Price_import::pathKey('Посуд / Тарілки') => category_id]
 *
 * Правила (spec 022): ключ — ID, інакше Артикул (AC-5); порожня клітинка — не змінювати, «-» у Знижках — очистити (AC-6);
 * колонок, яких немає у файлі, не чіпаємо; Назва/Категорія — лише для нових (AC-7, AC-10); нові — завжди вимкнені.
 * Помилки й попередження — коди з аргументами; тексти — у мовному файлі адмінки (extension/module/kristal_import).
 * PHP 7.3+.
 */
class Price_import {
	/** Поля, що оновлюються в наявних товарах (порядок = порядок показу змін) */
	const FIELDS = array('sku', 'price', 'unit', 'minimum', 'discounts', 'deposit', 'breakage', 'washing', 'hit', 'status');

	/** Ціна змінилась більш ніж у стільки разів — попередження (AC-8) */
	const JUMP = 3;

	/** Скільки назв показувати в попередженнях-списках */
	const LIST_MAX = 20;

	public static function pathKey($path) {
		$parts = preg_split('#\s*[/>\\\\]\s*#u', trim((string)$path));
		$parts = array_filter(array_map(function ($p) {
			return preg_replace('/\s+/u', ' ', mb_strtolower(trim(html_entity_decode($p, ENT_QUOTES, 'UTF-8')), 'UTF-8'));
		}, $parts), 'strlen');

		return implode('/', $parts);
	}

	public static function plan(array $read, array $catalog) {
		$products = isset($catalog['products']) ? $catalog['products'] : array();
		$categories = isset($catalog['categories']) ? $catalog['categories'] : array();
		$present = array_flip(array_values(isset($read['columns']) ? $read['columns'] : array()));
		$rows = isset($read['rows']) ? $read['rows'] : array();

		$plan = array(
			'updates'  => array(),
			'changes'  => array(),
			'creates'  => array(),
			'errors'   => array(),
			'warnings' => array(),
			'counts'   => array('rows' => count($rows), 'matched' => 0, 'changed' => 0, 'unchanged' => 0, 'created' => 0, 'errors' => 0),
			'hash'     => ''
		);

		// Індекс артикулів каталогу (без регістру)
		$sku_index = array();

		foreach ($products as $id => $p) {
			$key = self::skuKey(isset($p['sku']) ? $p['sku'] : '');

			if ($key !== '') {
				$sku_index[$key] = (int)$id;
			}
		}

		$errors = array();     // line => [[code, args]]
		$parsed = array();     // line => [target_id|0, values]
		$by_product = array(); // id => [lines]

		foreach ($rows as $line => $cells) {
			$line = (int)$line;
			$row_errors = array();
			$target = 0;

			$id_raw = isset($cells['id']) ? trim($cells['id']) : '';
			$sku_raw = isset($cells['sku']) ? Price_csv::text($cells['sku']) : '';

			if ($id_raw !== '') {
				$id = Price_csv::integer($id_raw);

				if (!is_int($id) || $id <= 0) {
					$row_errors[] = array('id_invalid', array($id_raw));
				} elseif (!isset($products[$id])) {
					$row_errors[] = array('not_found', array($id));
				} else {
					$target = $id;
				}
			} elseif ($sku_raw !== '') {
				$key = self::skuKey($sku_raw);
				$target = isset($sku_index[$key]) ? $sku_index[$key] : 0;
			} else {
				$row_errors[] = array('no_key', array());
			}

			list($values, $value_errors) = self::parseRow($cells, $present);
			$row_errors = array_merge($row_errors, $value_errors);

			if ($target) {
				$by_product[$target][] = $line;
			}

			if ($row_errors) {
				$errors[$line] = $row_errors;
			} else {
				$parsed[$line] = array($target, $values, $sku_raw);
			}
		}

		// Два рядки на один товар — помилка в обох (AC-5)
		foreach ($by_product as $id => $lines) {
			if (count($lines) > 1) {
				foreach ($lines as $line) {
					$others = array_values(array_diff($lines, array($line)));
					$errors[$line][] = array('duplicate_product', array(implode(', ', $others)));
					unset($parsed[$line]);
				}
			}
		}

		// Нові артикули: зайняті іншим товаром або повторені у файлі
		$new_skus = array(); // key => [lines]

		foreach ($parsed as $line => $item) {
			list($target, $values, $sku_raw) = $item;
			$sku = $target ? (isset($values['sku']) ? $values['sku'] : null) : $sku_raw;

			if ($sku === null || $sku === '') {
				continue;
			}

			$key = self::skuKey($sku);

			if ($target && $key === self::skuKey($products[$target]['sku'])) {
				continue;
			}

			if ($target && isset($sku_index[$key]) && $sku_index[$key] !== $target) {
				$other = $products[$sku_index[$key]];
				$errors[$line][] = array('sku_taken', array($sku, $other['id'], $other['name']));
				unset($parsed[$line]);
				continue;
			}

			$new_skus[$key][] = $line;
		}

		foreach ($new_skus as $key => $lines) {
			if (count($lines) > 1) {
				foreach ($lines as $line) {
					$errors[$line][] = array('sku_duplicate', array($parsed[$line][0] ? $parsed[$line][1]['sku'] : $parsed[$line][2], implode(', ', array_diff($lines, array($line)))));
				}

				foreach ($lines as $line) {
					unset($parsed[$line]);
				}
			}
		}

		// Оновлення й нові
		$matched = array();

		foreach ($parsed as $line => $item) {
			list($target, $values, $sku_raw) = $item;

			if ($target) {
				$old = $products[$target];
				$matched[$target] = true;
				$new = $old;

				foreach ($values as $field => $value) {
					if (in_array($field, self::FIELDS, true)) {
						$new[$field] = $value;
					}
				}

				$discount_errors = isset($values['discounts']) ? self::checkDiscounts($values['discounts'], $new['price'], $new['minimum']) : array();

				if ($discount_errors) {
					$errors[$line] = $discount_errors;
					continue;
				}

				if (isset($values['discounts'])) {
					$new['discounts'] = self::map($values['discounts']);
				}

				$fields = array();

				foreach (self::FIELDS as $field) {
					if (array_key_exists($field, $values) && !self::same($field, $old[$field], $new[$field])) {
						$fields[$field] = $new[$field];
						$plan['changes'][] = array('line' => $line, 'id' => (int)$target, 'name' => $old['name'], 'field' => $field, 'old' => $old[$field], 'new' => $new[$field]);
					}
				}

				if ($fields) {
					$plan['updates'][(int)$target] = array('line' => $line, 'fields' => $fields);
					$plan['counts']['changed']++;
				} else {
					$plan['counts']['unchanged']++;
				}

				if (!isset($values['discounts']) && $old['discounts'] && self::checkDiscounts(self::pairs($old['discounts']), $new['price'], $new['minimum'])) {
					$plan['warnings'][] = array('code' => 'discounts_conflict', 'args' => array($old['name'], $line));
				}

				if ($old['price'] > 0 && $new['price'] > 0 && max($old['price'] / $new['price'], $new['price'] / $old['price']) > self::JUMP) {
					$plan['warnings'][] = array('code' => 'price_jump', 'args' => array($old['name'], $old['price'], $new['price'], $line));
				}

				$products[$target] = $new; // для підсумкового «без ціни»
				continue;
			}

			// Новий товар (AC-10)
			$name = isset($values['name']) ? $values['name'] : '';
			$path = isset($values['category']) ? $values['category'] : '';
			$missing = array();

			if ($name === '') { $missing[] = 'name'; }
			if ($path === '') { $missing[] = 'category'; }
			if (!isset($values['price'])) { $missing[] = 'price'; }

			if ($missing) {
				$errors[$line][] = array('create_missing', array($sku_raw, implode(',', $missing)));
				continue;
			}

			$path_key = self::pathKey($path);

			if (!isset($categories[$path_key])) {
				$errors[$line][] = array('category_not_found', array($path));
				continue;
			}

			$create = array(
				'line' => $line, 'sku' => $sku_raw, 'name' => $name, 'category' => $path, 'category_id' => (int)$categories[$path_key],
				'price' => $values['price'], 'unit' => 'pcs', 'minimum' => 1, 'discounts' => array(),
				'deposit' => 0.0, 'breakage' => 0.0, 'washing' => 0, 'hit' => 0, 'status' => 0
			);

			foreach (array('unit', 'minimum', 'deposit', 'breakage', 'washing', 'hit') as $field) {
				if (isset($values[$field])) {
					$create[$field] = $values[$field];
				}
			}

			if (isset($values['discounts'])) {
				$discount_errors = self::checkDiscounts($values['discounts'], $create['price'], $create['minimum']);

				if ($discount_errors) {
					$errors[$line] = $discount_errors;
					continue;
				}

				$create['discounts'] = self::map($values['discounts']);
			}

			if (!empty($values['status'])) {
				$plan['warnings'][] = array('code' => 'created_disabled', 'args' => array($name, $line));
			}

			$plan['creates'][] = $create;
		}

		// Помилки — за номером рядка
		ksort($errors);

		foreach ($errors as $line => $list) {
			foreach ($list as $error) {
				$plan['errors'][] = array('line' => (int)$line, 'code' => $error[0], 'args' => $error[1]);
			}
		}

		$plan['counts']['errors'] = count($errors);
		$plan['counts']['created'] = count($plan['creates']);
		$plan['counts']['matched'] = count($matched);

		// Попередження AC-8: невідомі колонки, увімкнені без ціни, товари не з файлу
		if (!empty($read['unknown'])) {
			array_unshift($plan['warnings'], array('code' => 'unknown_columns', 'args' => array(implode(', ', $read['unknown']))));
		}

		$no_price = array();
		$not_in_file = array();

		foreach ($products as $id => $p) {
			if ((int)$p['status'] === 1 && (float)$p['price'] <= 0) {
				$no_price[] = $p['name'];
			}

			if (!isset($by_product[$id])) {
				$not_in_file[] = $p['name'];
			}
		}

		if ($no_price) {
			$plan['warnings'][] = array('code' => 'no_price', 'args' => array(count($no_price), implode('; ', array_slice($no_price, 0, self::LIST_MAX))));
		}

		if ($not_in_file && $rows) {
			$plan['warnings'][] = array('code' => 'not_in_file', 'args' => array(count($not_in_file), implode('; ', array_slice($not_in_file, 0, self::LIST_MAX))));
		}

		$plan['hash'] = sha1(json_encode(array($plan['updates'], $plan['creates'])));

		return $plan;
	}

	/** @return array [значення [поле => типізоване], помилки [[code, args]]] — лише для колонок, що є у файлі й непорожні */
	private static function parseRow(array $cells, array $present) {
		$values = array();
		$errors = array();

		$cell = function ($key) use ($cells, $present) {
			return isset($present[$key]) && isset($cells[$key]) ? trim($cells[$key]) : '';
		};

		if (($v = Price_csv::text($cell('sku'))) !== '') {
			if (mb_strlen($v, 'UTF-8') > 64) {
				$errors[] = array('bad_sku', array($v));
			} else {
				$values['sku'] = $v;
			}
		}

		if (($v = Price_csv::text($cell('name'))) !== '') {
			$values['name'] = mb_substr($v, 0, 255, 'UTF-8');
		}

		if (($v = $cell('category')) !== '') {
			$values['category'] = $v;
		}

		foreach (array('price', 'deposit', 'breakage') as $field) {
			$v = Price_csv::number($cell($field));

			if ($v === false) {
				$errors[] = array('bad_number', array($field, $cell($field)));
			} elseif ($v !== null) {
				$values[$field] = $v;
			}
		}

		$v = Price_csv::integer($cell('minimum'));

		if ($v === false || (is_int($v) && $v < 1)) {
			$errors[] = array('bad_minimum', array($cell('minimum')));
		} elseif ($v !== null) {
			$values['minimum'] = $v;
		}

		$v = Price_csv::unit($cell('unit'));

		if ($v === false) {
			$errors[] = array('bad_unit', array($cell('unit')));
		} elseif ($v !== null) {
			$values['unit'] = $v;
		}

		foreach (array('washing', 'hit', 'status') as $field) {
			$v = Price_csv::bool($cell($field));

			if ($v === 'invalid') {
				$errors[] = array('bad_bool', array($field, $cell($field)));
			} elseif ($v !== null) {
				$values[$field] = $v ? 1 : 0;
			}
		}

		$v = Price_csv::discounts($cell('discounts'));

		if ($v === false) {
			$errors[] = array('bad_discounts', array($cell('discounts')));
		} elseif ($v !== null) {
			$values['discounts'] = $v;
		}

		return array($values, $errors);
	}

	/**
	 * AC-6: кількість > мінімуму, ціна < ціни за добу, без повторів кількості.
	 * @param array $pairs [[кількість, ціна]] (з Price_csv::discounts) — після перевірки план зберігає [кількість => ціна]
	 */
	private static function checkDiscounts(array $pairs, $price, $minimum) {
		$errors = array();
		$seen = array();

		foreach ($pairs as $pair) {
			list($qty, $tier) = $pair;

			if (isset($seen[$qty])) {
				$errors[] = array('discount_duplicate', array($qty));
				continue;
			}

			$seen[$qty] = true;

			if ($qty <= (int)$minimum) {
				$errors[] = array('discount_quantity', array($qty, (int)$minimum));
			}

			if ($tier >= (float)$price) {
				$errors[] = array('discount_price', array($qty, $tier, (float)$price));
			}
		}

		return $errors;
	}

	private static function pairs(array $map) {
		$pairs = array();

		foreach ($map as $qty => $price) {
			$pairs[] = array((int)$qty, (float)$price);
		}

		return $pairs;
	}

	private static function map(array $pairs) {
		$map = array();

		foreach ($pairs as $pair) {
			$map[(int)$pair[0]] = round((float)$pair[1], 4);
		}

		ksort($map);

		return $map;
	}

	private static function same($field, $old, $new) {
		switch ($field) {
			case 'discounts':
				return self::map(self::pairs((array)$old)) == self::map(self::pairs((array)$new));
			case 'price':
			case 'deposit':
			case 'breakage':
				return abs((float)$old - (float)$new) < 0.00005;
			case 'sku':
				// Артикул зіставляється без регістру — «t-27» у файлі не перезаписує «T-27»
				return self::skuKey($old) === self::skuKey($new);
			case 'unit':
				return (string)$old === (string)$new;
			default:
				return (int)$old === (int)$new;
		}
	}

	private static function skuKey($sku) {
		return mb_strtolower(trim((string)$sku), 'UTF-8');
	}
}
