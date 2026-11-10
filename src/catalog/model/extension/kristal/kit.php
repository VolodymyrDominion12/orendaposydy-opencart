<?php
/**
 * Модель готових комплектів для подій (фіча 007 kristal_kit).
 * PHP 7.3+.
 */
class ModelExtensionKristalKit extends Model {

	/**
	 * Отримання списку активних комплектів для вказаного типу події
	 * з динамічним розрахунком ціни на гостя з актуальних цін товарів.
	 */
	public function getKitsByEventType($event_type) {
		$sql = "SELECT * FROM `" . DB_PREFIX . "kristal_kit`
			WHERE `event_type` = '" . $this->db->escape($event_type) . "'
			AND `status` = '1'
			ORDER BY `sort_order` ASC";

		try {
			$query = $this->db->query($sql);
		} catch (\Exception $e) {
			return array();
		}

		$kits = array();

		foreach ($query->rows as $row) {
			$kit = $row;
			$kit_id = (int)$row['kit_id'];

			// Розбір JSON features
			$features = array();
			if (!empty($row['features'])) {
				$decoded = json_decode($row['features'], true);
				if (is_array($decoded)) {
					$features = $decoded;
				}
			}
			$kit['features_list'] = $features;

			// Отримання товарів комплекту
			$items = $this->getKitItems($kit_id);
			$kit['items'] = $items;

			// Динамічний розрахунок ціни на гостя
			$per_guest_raw = 0;
			foreach ($items as $item) {
				$price = (float)$item['price'];
				$qty = (float)$item['qty_per_guest'];
				$per_guest_raw += $price * $qty;
			}

			$discount_pct = (float)$row['discount_pct'];
			if ($discount_pct > 0) {
				$per_guest_raw = $per_guest_raw * (1 - ($discount_pct / 100));
			}

			$kit['price_per_guest_raw'] = $per_guest_raw;
			$kit['price_per_guest'] = number_format(round($per_guest_raw), 0, '.', ' ') . ' ₴';
			$kit['price_per_guest_num'] = (int)round($per_guest_raw);

			$kits[] = $kit;
		}

		return $kits;
	}

	/**
	 * Отримання одного комплекту за ID або кодом.
	 */
	public function getKit($kit_id_or_code) {
		if (is_numeric($kit_id_or_code)) {
			$where = "`kit_id` = '" . (int)$kit_id_or_code . "'";
		} else {
			$where = "`code` = '" . $this->db->escape($kit_id_or_code) . "'";
		}

		$query = $this->db->query("SELECT * FROM `" . DB_PREFIX . "kristal_kit` WHERE " . $where . " AND `status` = '1'");

		if (!$query->num_rows) {
			return null;
		}

		$kit = $query->row;
		$kit_id = (int)$kit['kit_id'];

		$features = array();
		if (!empty($kit['features'])) {
			$decoded = json_decode($kit['features'], true);
			if (is_array($decoded)) {
				$features = $decoded;
			}
		}
		$kit['features_list'] = $features;
		$kit['items'] = $this->getKitItems($kit_id);

		$per_guest_raw = 0;
		foreach ($kit['items'] as $item) {
			$per_guest_raw += (float)$item['price'] * (float)$item['qty_per_guest'];
		}
		if ((float)$kit['discount_pct'] > 0) {
			$per_guest_raw = $per_guest_raw * (1 - ((float)$kit['discount_pct'] / 100));
		}
		$kit['price_per_guest_raw'] = $per_guest_raw;
		$kit['price_per_guest'] = number_format(round($per_guest_raw), 0, '.', ' ') . ' ₴';
		$kit['price_per_guest_num'] = (int)round($per_guest_raw);

		return $kit;
	}

	/**
	 * Отримання списку товарів у комплекті з їх цінами та назвами.
	 */
	public function getKitItems($kit_id) {
		$sql = "SELECT ki.*, p.price, p.minimum, p.image, pd.name
			FROM `" . DB_PREFIX . "kristal_kit_item` ki
			LEFT JOIN `" . DB_PREFIX . "product` p ON (p.product_id = ki.product_id)
			LEFT JOIN `" . DB_PREFIX . "product_description` pd ON (pd.product_id = p.product_id AND pd.language_id = '" . (int)$this->config->get('config_language_id') . "')
			WHERE ki.kit_id = '" . (int)$kit_id . "'
			ORDER BY ki.sort_order ASC";

		$query = $this->db->query($sql);
		return $query->rows;
	}

	/**
	 * Розрахунок конкретних кількостей товарів для вказаної кількості гостей.
	 * Повертає список для пакетного додавання в кошик.
	 */
	public function calculateKitItems($kit_id, $guests) {
		$guests = max(1, (int)$guests);
		$items = $this->getKitItems($kit_id);
		$result = array();

		foreach ($items as $item) {
			$qty_per_guest = (float)$item['qty_per_guest'];
			$qty_fixed = (int)$item['qty_fixed'];
			$minimum = max(1, (int)$item['minimum']);

			$calculated_qty = (int)round($qty_per_guest * $guests) + $qty_fixed;
			if ($calculated_qty < $minimum) {
				$calculated_qty = $minimum;
			}

			if ($calculated_qty > 0) {
				$result[] = array(
					'product_id' => (int)$item['product_id'],
					'quantity'   => $calculated_qty,
					'name'       => $item['name'],
					'price'      => (float)$item['price']
				);
			}
		}

		return $result;
	}
}
