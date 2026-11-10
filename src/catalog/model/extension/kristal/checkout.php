<?php
/**
 * Модель параметрів оренди замовлення (фіча 010 kristal_checkout).
 */
class ModelExtensionKristalCheckout extends Model {
	/**
	 * Зберегти параметри оренди для замовлення.
	 *
	 * @param int   $order_id
	 * @param array $data
	 * @return void
	 */
	public function saveRental($order_id, array $data) {
		$order_id = (int)$order_id;
		if ($order_id <= 0) {
			return;
		}

		$date_from = !empty($data['date_from']) ? $this->db->escape(date('Y-m-d', strtotime($data['date_from']))) : date('Y-m-d');
		$date_to = !empty($data['date_to']) ? $this->db->escape(date('Y-m-d', strtotime($data['date_to']))) : $date_from;
		$rental_days = isset($data['rental_days']) ? max(1, (int)$data['rental_days']) : 1;
		$delivery_type = (isset($data['delivery_type']) && $data['delivery_type'] === 'pickup') ? 'pickup' : 'delivery';
		$delivery_address = isset($data['delivery_address']) ? $this->db->escape(trim($data['delivery_address'])) : '';
		$contact_channel = isset($data['contact_channel']) ? $this->db->escape(trim($data['contact_channel'])) : 'viber';
		$is_company = !empty($data['is_company']) ? 1 : 0;
		$company_name = isset($data['company_name']) ? $this->db->escape(trim($data['company_name'])) : '';
		$edrpou = isset($data['edrpou']) ? $this->db->escape(trim($data['edrpou'])) : '';

		$this->db->query("INSERT INTO `" . DB_PREFIX . "kristal_order_rental` SET
			`order_id` = '" . $order_id . "',
			`date_from` = '" . $date_from . "',
			`date_to` = '" . $date_to . "',
			`rental_days` = '" . $rental_days . "',
			`delivery_type` = '" . $delivery_type . "',
			`delivery_address` = '" . $delivery_address . "',
			`contact_channel` = '" . $contact_channel . "',
			`is_company` = '" . $is_company . "',
			`company_name` = '" . $company_name . "',
			`edrpou` = '" . $edrpou . "',
			`created_at` = NOW(),
			`updated_at` = NOW()
			ON DUPLICATE KEY UPDATE
			`date_from` = VALUES(`date_from`),
			`date_to` = VALUES(`date_to`),
			`rental_days` = VALUES(`rental_days`),
			`delivery_type` = VALUES(`delivery_type`),
			`delivery_address` = VALUES(`delivery_address`),
			`contact_channel` = VALUES(`contact_channel`),
			`is_company` = VALUES(`is_company`),
			`company_name` = VALUES(`company_name`),
			`edrpou` = VALUES(`edrpou`),
			`updated_at` = NOW()");
	}

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
