<?php
/**
 * Модель адмінки для керування нормами калькулятора (фіча 008 kristal_calculator).
 * PHP 7.3+.
 */
class ModelExtensionKristalCalculator extends Model {

	public function addNorm($data) {
		$this->db->query("INSERT INTO `" . DB_PREFIX . "kristal_calc_norm` SET
			`category_type`      = '" . $this->db->escape($data['category_type']) . "',
			`name`               = '" . $this->db->escape($data['name']) . "',
			`product_id_classic` = '" . (int)$data['product_id_classic'] . "',
			`product_id_royal`   = '" . (int)$data['product_id_royal'] . "',
			`norm_banquet`       = '" . (float)$data['norm_banquet'] . "',
			`norm_buffet`        = '" . (float)$data['norm_buffet'] . "',
			`norm_coffee`        = '" . (float)$data['norm_coffee'] . "',
			`dish_rule`          = " . (!empty($data['dish_rule']) ? "'" . $this->db->escape($data['dish_rule']) . "'" : "NULL") . ",
			`drink_filter`       = " . (!empty($data['drink_filter']) ? "'" . $this->db->escape($data['drink_filter']) . "'" : "NULL") . ",
			`pack_size`          = '" . max(1, (int)$data['pack_size']) . "',
			`sort_order`         = '" . (int)$data['sort_order'] . "',
			`status`             = '" . (int)$data['status'] . "'");

		return $this->db->getLastId();
	}

	public function editNorm($norm_id, $data) {
		$this->db->query("UPDATE `" . DB_PREFIX . "kristal_calc_norm` SET
			`category_type`      = '" . $this->db->escape($data['category_type']) . "',
			`name`               = '" . $this->db->escape($data['name']) . "',
			`product_id_classic` = '" . (int)$data['product_id_classic'] . "',
			`product_id_royal`   = '" . (int)$data['product_id_royal'] . "',
			`norm_banquet`       = '" . (float)$data['norm_banquet'] . "',
			`norm_buffet`        = '" . (float)$data['norm_buffet'] . "',
			`norm_coffee`        = '" . (float)$data['norm_coffee'] . "',
			`dish_rule`          = " . (!empty($data['dish_rule']) ? "'" . $this->db->escape($data['dish_rule']) . "'" : "NULL") . ",
			`drink_filter`       = " . (!empty($data['drink_filter']) ? "'" . $this->db->escape($data['drink_filter']) . "'" : "NULL") . ",
			`pack_size`          = '" . max(1, (int)$data['pack_size']) . "',
			`sort_order`         = '" . (int)$data['sort_order'] . "',
			`status`             = '" . (int)$data['status'] . "'
			WHERE `norm_id` = '" . (int)$norm_id . "'");
	}

	public function deleteNorm($norm_id) {
		$this->db->query("DELETE FROM `" . DB_PREFIX . "kristal_calc_norm` WHERE `norm_id` = '" . (int)$norm_id . "'");
	}

	public function getNorm($norm_id) {
		$query = $this->db->query("SELECT * FROM `" . DB_PREFIX . "kristal_calc_norm` WHERE `norm_id` = '" . (int)$norm_id . "'");
		return $query->row;
	}

	public function getNorms($data = array()) {
		$sql = "SELECT n.*,
				pdc.name AS name_classic,
				pdr.name AS name_royal
			FROM `" . DB_PREFIX . "kristal_calc_norm` n
			LEFT JOIN `" . DB_PREFIX . "product_description` pdc ON (pdc.product_id = n.product_id_classic AND pdc.language_id = '" . (int)$this->config->get('config_language_id') . "')
			LEFT JOIN `" . DB_PREFIX . "product_description` pdr ON (pdr.product_id = n.product_id_royal AND pdr.language_id = '" . (int)$this->config->get('config_language_id') . "')
			WHERE 1=1";

		if (!empty($data['filter_category'])) {
			$sql .= " AND n.category_type = '" . $this->db->escape($data['filter_category']) . "'";
		}

		if (isset($data['filter_status']) && $data['filter_status'] !== '') {
			$sql .= " AND n.status = '" . (int)$data['filter_status'] . "'";
		}

		$sort_data = array(
			'n.name',
			'n.category_type',
			'n.sort_order',
			'n.status'
		);

		if (isset($data['sort']) && in_array($data['sort'], $sort_data, true)) {
			$sql .= " ORDER BY " . $data['sort'];
		} else {
			$sql .= " ORDER BY n.category_type ASC, n.sort_order ASC";
		}

		if (isset($data['order']) && ($data['order'] == 'DESC')) {
			$sql .= " DESC";
		} else {
			$sql .= " ASC";
		}

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
	}

	public function getTotalNorms($data = array()) {
		$sql = "SELECT COUNT(*) AS total FROM `" . DB_PREFIX . "kristal_calc_norm` WHERE 1=1";

		if (!empty($data['filter_category'])) {
			$sql .= " AND `category_type` = '" . $this->db->escape($data['filter_category']) . "'";
		}

		if (isset($data['filter_status']) && $data['filter_status'] !== '') {
			$sql .= " AND `status` = '" . (int)$data['filter_status'] . "'";
		}

		$query = $this->db->query($sql);
		return (int)$query->row['total'];
	}
}
