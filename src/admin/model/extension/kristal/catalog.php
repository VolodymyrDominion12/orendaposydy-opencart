<?php
/** Умови оренди товару — таблиця kristal_product_rental (фіча 005). */
class ModelExtensionKristalCatalog extends Model {
	public function getRental($product_id) {
		$query = $this->db->query("SELECT * FROM `" . DB_PREFIX . "kristal_product_rental` WHERE product_id = '" . (int)$product_id . "'");

		return \Kristal\Rental::normalize($query->num_rows ? $query->row : null);
	}

	/** @param array $data unit, deposit, breakage_price, washing_included, is_hit (сирі значення з форми) */
	public function saveRental($product_id, $data) {
		$unit = isset($data['unit']) && \Kristal\Rental::isUnit($data['unit']) ? $data['unit'] : \Kristal\Rental::DEFAULT_UNIT;
		$deposit = isset($data['deposit']) ? max(0, (float)str_replace(',', '.', $data['deposit'])) : 0;
		$breakage = isset($data['breakage_price']) ? max(0, (float)str_replace(',', '.', $data['breakage_price'])) : 0;
		$washing = !empty($data['washing_included']) ? 1 : 0;
		$hit = !empty($data['is_hit']) ? 1 : 0;

		$this->db->query("INSERT INTO `" . DB_PREFIX . "kristal_product_rental` SET
			product_id = '" . (int)$product_id . "', unit = '" . $this->db->escape($unit) . "',
			deposit = '" . (float)$deposit . "', breakage_price = '" . (float)$breakage . "',
			washing_included = '" . $washing . "', is_hit = '" . $hit . "'
			ON DUPLICATE KEY UPDATE unit = VALUES(unit), deposit = VALUES(deposit), breakage_price = VALUES(breakage_price),
			washing_included = VALUES(washing_included), is_hit = VALUES(is_hit)");
	}

	public function deleteRental($product_id) {
		$this->db->query("DELETE FROM `" . DB_PREFIX . "kristal_product_rental` WHERE product_id = '" . (int)$product_id . "'");
	}

	/** Копія товару в ядрі (copyProduct) не повертає новий id — беремо найновіший товар з тим самим артикулом/моделлю. */
	public function copyRental($source_id) {
		$query = $this->db->query("SELECT p2.product_id FROM `" . DB_PREFIX . "product` p1
			JOIN `" . DB_PREFIX . "product` p2 ON (p2.model = p1.model AND p2.sku = p1.sku AND p2.product_id > p1.product_id)
			WHERE p1.product_id = '" . (int)$source_id . "' ORDER BY p2.product_id DESC LIMIT 1");

		if ($query->num_rows) {
			$rental = $this->getRental($source_id);
			$this->saveRental($query->row['product_id'], $rental);
		}
	}
}
