<?php
/**
 * Модель адмінки для оренди замовлення (фіча 010 kristal_checkout).
 * PHP 7.3+.
 */
class ModelExtensionKristalCheckout extends Model {
	/**
	 * Отримати параметри оренди замовлення.
	 *
	 * @param int $order_id
	 * @return array|null
	 */
	public function getRental($order_id) {
		$query = $this->db->query("SELECT * FROM `" . DB_PREFIX . "kristal_order_rental` WHERE `order_id` = '" . (int)$order_id . "' LIMIT 1");
		if ($query->num_rows) {
			return $query->row;
		}
		return null;
	}
}
