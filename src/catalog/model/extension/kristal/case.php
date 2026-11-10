<?php
/**
 * Модель портфоліо кейсів подій (kristal_proof).
 * Захищені запити для безпечної роботи без помилок до застосування міграцій на проді.
 */
class ModelExtensionKristalCase extends Model {

	public function getCases($data = array()) {
		try {
			$sql = "SELECT c.* FROM `" . DB_PREFIX . "kristal_case` c WHERE c.`status` = 1";

			if (!empty($data['filter_event_type'])) {
				$sql .= " AND c.`event_type` = '" . $this->db->escape($data['filter_event_type']) . "'";
			}

			$sql .= " ORDER BY c.`sort_order` ASC, c.`date_added` DESC";

			if (isset($data['start']) || isset($data['limit'])) {
				if ($data['start'] < 0) {
					$data['start'] = 0;
				}

				if ($data['limit'] < 1) {
					$data['limit'] = 20;
				}

				$sql .= " LIMIT " . (int)$data['start'] . "," . (int)$data['limit'];
			}

			$query = $this->db->query($sql);

			return $query->rows;
		} catch (\Exception $e) {
			return array();
		}
	}

	public function getCase($case_id) {
		try {
			$query = $this->db->query("SELECT * FROM `" . DB_PREFIX . "kristal_case` WHERE `case_id` = '" . (int)$case_id . "' AND `status` = 1");

			return $query->row;
		} catch (\Exception $e) {
			return array();
		}
	}

	public function getCaseBySlug($slug) {
		try {
			$query = $this->db->query("SELECT * FROM `" . DB_PREFIX . "kristal_case` WHERE `slug` = '" . $this->db->escape($slug) . "' AND `status` = 1");

			return $query->row;
		} catch (\Exception $e) {
			return array();
		}
	}

	public function getCaseImages($case_id) {
		try {
			$query = $this->db->query("SELECT * FROM `" . DB_PREFIX . "kristal_case_image` WHERE `case_id` = '" . (int)$case_id . "' ORDER BY `sort_order` ASC, `image_id` ASC");

			return $query->rows;
		} catch (\Exception $e) {
			return array();
		}
	}

	public function getCaseProducts($case_id) {
		try {
			$lang_id = (int)$this->config->get('config_language_id');
			$sql = "SELECT p.product_id, p.image, p.price, pd.name, pr.unit, pr.deposit, pr.breakage_price
				FROM `" . DB_PREFIX . "kristal_case_product` cp
				INNER JOIN `" . DB_PREFIX . "product` p ON (cp.product_id = p.product_id)
				LEFT JOIN `" . DB_PREFIX . "product_description` pd ON (p.product_id = pd.product_id AND pd.language_id = '" . $lang_id . "')
				LEFT JOIN `" . DB_PREFIX . "kristal_product_rental` pr ON (p.product_id = pr.product_id)
				WHERE cp.case_id = '" . (int)$case_id . "' AND p.status = 1
				ORDER BY p.sort_order ASC, pd.name ASC";

			$query = $this->db->query($sql);

			return $query->rows;
		} catch (\Exception $e) {
			return array();
		}
	}

	public function getTotalCases($data = array()) {
		try {
			$sql = "SELECT COUNT(*) AS total FROM `" . DB_PREFIX . "kristal_case` WHERE `status` = 1";

			if (!empty($data['filter_event_type'])) {
				$sql .= " AND `event_type` = '" . $this->db->escape($data['filter_event_type']) . "'";
			}

			$query = $this->db->query($sql);

			return (int)$query->row['total'];
		} catch (\Exception $e) {
			return 0;
		}
	}
}
