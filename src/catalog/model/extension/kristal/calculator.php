<?php
/**
 * Модель калькулятора події (фіча 008 kristal_calculator).
 * PHP 7.3+.
 */
class ModelExtensionKristalCalculator extends Model {

	/**
	 * Отримання всіх активних норм із прив'язкою до актуальних цін та назв товарів.
	 */
	public function getNorms() {
		$lang_id = (int)$this->config->get('config_language_id');

		$sql = "SELECT n.*,
				pc.price AS price_classic, pc.minimum AS min_classic, pdc.name AS name_classic,
				pr.price AS price_royal, pr.minimum AS min_royal, pdr.name AS name_royal
			FROM `" . DB_PREFIX . "kristal_calc_norm` n
			LEFT JOIN `" . DB_PREFIX . "product` pc ON (pc.product_id = n.product_id_classic)
			LEFT JOIN `" . DB_PREFIX . "product_description` pdc ON (pdc.product_id = pc.product_id AND pdc.language_id = '" . $lang_id . "')
			LEFT JOIN `" . DB_PREFIX . "product` pr ON (pr.product_id = n.product_id_royal)
			LEFT JOIN `" . DB_PREFIX . "product_description` pdr ON (pdr.product_id = pr.product_id AND pdr.language_id = '" . $lang_id . "')
			WHERE n.status = '1'
			ORDER BY n.sort_order ASC";

		$query = $this->db->query($sql);
		return $query->rows;
	}

	/**
	 * Розрахунок списку позицій, кількостей та вартості за вказаними параметрами.
	 *
	 * @param int $guests Кількість гостей (10-300)
	 * @param string $format 'banquet' | 'buffet' | 'coffee'
	 * @param int $dishes 2 | 3 | 4
	 * @param array $drinks ['wine', 'champ', 'strong']
	 * @param int $series 1 (Classic) | 2 (Royal)
	 * @return array Розрахований список з розбивкою по групах та підсумком
	 */
	public function calculate($guests, $format, $dishes, $drinks = array(), $series = 1) {
		$guests = max(1, (int)$guests);
		if (!in_array($format, array('banquet', 'buffet', 'coffee'), true)) {
			$format = 'banquet';
		}
		$dishes = (int)$dishes;
		if ($dishes < 2) {
			$dishes = 2;
		}
		if (!is_array($drinks)) {
			$drinks = array();
		}
		$series = ((int)$series === 2) ? 2 : 1;

		$norms = $this->getNorms();

		$groups = array(
			'plates'  => array('title' => 'Посуд', 'items' => array()),
			'cutlery' => array('title' => 'Столові прибори', 'items' => array()),
			'glass'   => array('title' => 'Скло та келихи', 'items' => array())
		);

		$total = 0;
		$all_items = array();

		foreach ($norms as $norm) {
			// Перевірка фільтру напоїв
			if (!empty($norm['drink_filter'])) {
				if (!in_array($norm['drink_filter'], $drinks, true)) {
					continue;
				}
			}

			// Норма на гостя для обраного формату
			$per = 0.0;
			if ($format === 'banquet') {
				$per = (float)$norm['norm_banquet'];
			} elseif ($format === 'buffet') {
				$per = (float)$norm['norm_buffet'];
			} elseif ($format === 'coffee') {
				$per = (float)$norm['norm_coffee'];
			}

			if ($per <= 0.0) {
				continue;
			}

			// Спеціальні правила для страв
			if ($norm['dish_rule'] === 'extra_if_4_dishes' && $dishes >= 4) {
				$per += 1.0;
			} elseif ($norm['dish_rule'] === 'skip_if_2_dishes_non_banquet' && $dishes <= 2 && $format !== 'banquet') {
				continue;
			}

			// Розрахунок кількості: guests * per * 1.1 із запасом 10% та округленням до pack_size
			$pack_size = max(1, (int)$norm['pack_size']);
			$raw_qty = $guests * $per * 1.1;
			$qty = (int)(ceil($raw_qty / $pack_size) * $pack_size);

			if ($qty <= 0) {
				continue;
			}

			// Вибір товару та ціни відповідно до серії
			if ($series === 2 && !empty($norm['product_id_royal'])) {
				$product_id = (int)$norm['product_id_royal'];
				$item_name  = !empty($norm['name_royal']) ? $norm['name_royal'] : $norm['name'];
				$unit_price = (float)$norm['price_royal'];
				$min_qty    = (int)$norm['min_royal'];
			} else {
				$product_id = (int)$norm['product_id_classic'];
				$item_name  = !empty($norm['name_classic']) ? $norm['name_classic'] : $norm['name'];
				$unit_price = (float)$norm['price_classic'];
				$min_qty    = (int)$norm['min_classic'];
			}

			if ($min_qty > 0 && $qty < $min_qty) {
				$qty = $min_qty;
			}

			$line_total = round($qty * $unit_price, 2);
			$total += $line_total;

			$item_data = array(
				'norm_id'    => (int)$norm['norm_id'],
				'product_id' => $product_id,
				'name'       => $item_name,
				'display'    => $norm['name'],
				'href'       => $this->url->link('product/product', 'product_id=' . $product_id),
				'quantity'   => $qty,
				'price'      => $unit_price,
				'price_fmt'  => number_format($unit_price, 0, '.', ' ') . ' ₴',
				'total'      => $line_total,
				'total_fmt'  => number_format($line_total, 0, '.', ' ') . ' ₴'
			);

			$cat = $norm['category_type'];
			if (isset($groups[$cat])) {
				$groups[$cat]['items'][] = $item_data;
			}

			$all_items[] = $item_data;
		}

		$per_guest = $guests > 0 ? round($total / $guests, 1) : 0;

		return array(
			'guests'         => $guests,
			'format'         => $format,
			'dishes'         => $dishes,
			'drinks'         => $drinks,
			'series'         => $series,
			'groups'         => $groups,
			'items'          => $all_items,
			'total'          => $total,
			'total_fmt'      => number_format($total, 0, '.', ' ') . ' ₴',
			'per_guest'      => $per_guest,
			'per_guest_fmt'  => number_format($per_guest, 0, '.', ' ') . ' ₴'
		);
	}
}
