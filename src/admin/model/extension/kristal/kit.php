<?php
/**
 * Модель адмінки «Крістал: комплекти» (фіча 007 kristal_kit).
 * PHP 7.3+.
 */
class ModelExtensionKristalKit extends Model {

	public function getKits($data = array()) {
		$sql = "SELECT k.*,
			(SELECT COUNT(*) FROM `" . DB_PREFIX . "kristal_kit_item` ki WHERE ki.kit_id = k.kit_id) AS total_items
			FROM `" . DB_PREFIX . "kristal_kit` k";

		$implode = array();

		if (isset($data['filter_event_type']) && $data['filter_event_type'] !== '') {
			$implode[] = "k.event_type = '" . $this->db->escape($data['filter_event_type']) . "'";
		}

		if (isset($data['filter_status']) && $data['filter_status'] !== '') {
			$implode[] = "k.status = '" . (int)$data['filter_status'] . "'";
		}

		if ($implode) {
			$sql .= " WHERE " . implode(" AND ", $implode);
		}

		$sort_data = array(
			'k.sort_order',
			'k.name',
			'k.event_type',
			'k.tier',
			'k.status'
		);

		if (isset($data['sort']) && in_array($data['sort'], $sort_data)) {
			$sql .= " ORDER BY " . $data['sort'];
		} else {
			$sql .= " ORDER BY k.event_type ASC, k.sort_order ASC";
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

	public function getTotalKits($data = array()) {
		$sql = "SELECT COUNT(*) AS total FROM `" . DB_PREFIX . "kristal_kit` k";

		$implode = array();

		if (isset($data['filter_event_type']) && $data['filter_event_type'] !== '') {
			$implode[] = "k.event_type = '" . $this->db->escape($data['filter_event_type']) . "'";
		}

		if (isset($data['filter_status']) && $data['filter_status'] !== '') {
			$implode[] = "k.status = '" . (int)$data['filter_status'] . "'";
		}

		if ($implode) {
			$sql .= " WHERE " . implode(" AND ", $implode);
		}

		$query = $this->db->query($sql);

		return (int)$query->row['total'];
	}

	public function getKit($kit_id) {
		$query = $this->db->query("SELECT * FROM `" . DB_PREFIX . "kristal_kit` WHERE `kit_id` = '" . (int)$kit_id . "'");

		return $query->row;
	}

	public function getKitItems($kit_id) {
		$sql = "SELECT ki.*, pd.name, p.price, p.image
			FROM `" . DB_PREFIX . "kristal_kit_item` ki
			LEFT JOIN `" . DB_PREFIX . "product` p ON (p.product_id = ki.product_id)
			LEFT JOIN `" . DB_PREFIX . "product_description` pd ON (pd.product_id = p.product_id AND pd.language_id = '" . (int)$this->config->get('config_language_id') . "')
			WHERE ki.kit_id = '" . (int)$kit_id . "'
			ORDER BY ki.sort_order ASC";

		$query = $this->db->query($sql);

		return $query->rows;
	}

	public function addKit($data) {
		$this->db->query("INSERT INTO `" . DB_PREFIX . "kristal_kit` SET
			`code` = '" . $this->db->escape($data['code']) . "',
			`event_type` = '" . $this->db->escape($data['event_type']) . "',
			`tier` = '" . $this->db->escape($data['tier']) . "',
			`name` = '" . $this->db->escape($data['name']) . "',
			`badge` = '" . $this->db->escape($data['badge']) . "',
			`discount_pct` = '" . (float)$data['discount_pct'] . "',
			`features` = '" . $this->db->escape($data['features']) . "',
			`sort_order` = '" . (int)$data['sort_order'] . "',
			`status` = '" . (int)$data['status'] . "',
			`created_at` = NOW(),
			`updated_at` = NOW()");

		$kit_id = $this->db->getLastId();

		if (isset($data['items']) && is_array($data['items'])) {
			foreach ($data['items'] as $item) {
				if (!empty($item['product_id'])) {
					$this->db->query("INSERT INTO `" . DB_PREFIX . "kristal_kit_item` SET
						`kit_id` = '" . (int)$kit_id . "',
						`product_id` = '" . (int)$item['product_id'] . "',
						`qty_per_guest` = '" . (float)$item['qty_per_guest'] . "',
						`qty_fixed` = '" . (int)$item['qty_fixed'] . "',
						`sort_order` = '" . (int)$item['sort_order'] . "'");
				}
			}
		}

		return $kit_id;
	}

	public function editKit($kit_id, $data) {
		$this->db->query("UPDATE `" . DB_PREFIX . "kristal_kit` SET
			`code` = '" . $this->db->escape($data['code']) . "',
			`event_type` = '" . $this->db->escape($data['event_type']) . "',
			`tier` = '" . $this->db->escape($data['tier']) . "',
			`name` = '" . $this->db->escape($data['name']) . "',
			`badge` = '" . $this->db->escape($data['badge']) . "',
			`discount_pct` = '" . (float)$data['discount_pct'] . "',
			`features` = '" . $this->db->escape($data['features']) . "',
			`sort_order` = '" . (int)$data['sort_order'] . "',
			`status` = '" . (int)$data['status'] . "',
			`updated_at` = NOW()
			WHERE `kit_id` = '" . (int)$kit_id . "'");

		$this->db->query("DELETE FROM `" . DB_PREFIX . "kristal_kit_item` WHERE `kit_id` = '" . (int)$kit_id . "'");

		if (isset($data['items']) && is_array($data['items'])) {
			foreach ($data['items'] as $item) {
				if (!empty($item['product_id'])) {
					$this->db->query("INSERT INTO `" . DB_PREFIX . "kristal_kit_item` SET
						`kit_id` = '" . (int)$kit_id . "',
						`product_id` = '" . (int)$item['product_id'] . "',
						`qty_per_guest` = '" . (float)$item['qty_per_guest'] . "',
						`qty_fixed` = '" . (int)$item['qty_fixed'] . "',
						`sort_order` = '" . (int)$item['sort_order'] . "'");
				}
			}
		}
	}

	public function deleteKit($kit_id) {
		$this->db->query("DELETE FROM `" . DB_PREFIX . "kristal_kit` WHERE `kit_id` = '" . (int)$kit_id . "'");
		$this->db->query("DELETE FROM `" . DB_PREFIX . "kristal_kit_item` WHERE `kit_id` = '" . (int)$kit_id . "'");
	}
}
