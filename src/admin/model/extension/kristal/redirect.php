<?php
class ModelExtensionKristalRedirect extends Model {
	public function getRedirects($data = array()) {
		$sql = "SELECT * FROM `" . DB_PREFIX . "kristal_redirect`";

		$sort_data = array(
			'old_path',
			'new_path',
			'code',
			'hits',
			'last_hit_at',
			'status'
		);

		if (isset($data['sort']) && in_array($data['sort'], $sort_data)) {
			$sql .= " ORDER BY `" . $data['sort'] . "`";
		} else {
			$sql .= " ORDER BY `hits`";
		}

		if (isset($data['order']) && ($data['order'] == 'ASC')) {
			$sql .= " ASC";
		} else {
			$sql .= " DESC";
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

	public function getTotalRedirects() {
		$query = $this->db->query("SELECT COUNT(*) AS total FROM `" . DB_PREFIX . "kristal_redirect`");

		return (int)$query->row['total'];
	}

	public function getRedirect($redirect_id) {
		$query = $this->db->query("SELECT * FROM `" . DB_PREFIX . "kristal_redirect` WHERE `redirect_id` = '" . (int)$redirect_id . "'");

		return $query->row;
	}

	public function addRedirect($data) {
		$old_path = \Kristal\Redirect::normalize($data['old_path']);
		$new_path = trim($data['new_path']);
		$code = isset($data['code']) ? (int)$data['code'] : 301;
		$status = isset($data['status']) ? (int)$data['status'] : 1;

		$this->db->query("INSERT INTO `" . DB_PREFIX . "kristal_redirect` 
			(`old_path`, `new_path`, `code`, `status`, `hits`) 
			VALUES (
				'" . $this->db->escape($old_path) . "', 
				'" . $this->db->escape($new_path) . "', 
				'" . (int)$code . "', 
				'" . (int)$status . "', 
				0
			)
			ON DUPLICATE KEY UPDATE 
				`new_path` = VALUES(`new_path`), 
				`code` = VALUES(`code`), 
				`status` = VALUES(`status`)");

		// Видаляємо з 404 логу, якщо такий шлях там був
		$this->delete404($old_path);

		$this->flushCache();

		return $this->db->getLastId();
	}

	public function editRedirect($redirect_id, $data) {
		$old_path = \Kristal\Redirect::normalize($data['old_path']);
		$new_path = trim($data['new_path']);
		$code = isset($data['code']) ? (int)$data['code'] : 301;
		$status = isset($data['status']) ? (int)$data['status'] : 1;

		$this->db->query("UPDATE `" . DB_PREFIX . "kristal_redirect` SET 
			`old_path` = '" . $this->db->escape($old_path) . "', 
			`new_path` = '" . $this->db->escape($new_path) . "', 
			`code` = '" . (int)$code . "', 
			`status` = '" . (int)$status . "' 
			WHERE `redirect_id` = '" . (int)$redirect_id . "'");

		$this->flushCache();
	}

	public function deleteRedirect($redirect_id) {
		$this->db->query("DELETE FROM `" . DB_PREFIX . "kristal_redirect` WHERE `redirect_id` = '" . (int)$redirect_id . "'");

		$this->flushCache();
	}

	public function getLogs404($data = array()) {
		$sql = "SELECT * FROM `" . DB_PREFIX . "kristal_404_log`";

		$sort_data = array(
			'path',
			'hits',
			'referer',
			'last_at'
		);

		if (isset($data['sort']) && in_array($data['sort'], $sort_data)) {
			$sql .= " ORDER BY `" . $data['sort'] . "`";
		} else {
			$sql .= " ORDER BY `hits` DESC, `last_at` DESC";
		}

		if (isset($data['order']) && ($data['order'] == 'ASC')) {
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

	public function getTotalLogs404() {
		$query = $this->db->query("SELECT COUNT(*) AS total FROM `" . DB_PREFIX . "kristal_404_log`");

		return (int)$query->row['total'];
	}

	public function clear404() {
		$this->db->query("TRUNCATE TABLE `" . DB_PREFIX . "kristal_404_log`");
	}

	public function delete404($path) {
		$norm_path = \Kristal\Redirect::normalize($path);
		$this->db->query("DELETE FROM `" . DB_PREFIX . "kristal_404_log` WHERE `path` = '" . $this->db->escape($norm_path) . "'");
	}

	public function flushCache() {
		$this->cache->delete('kristal.redirects');
	}
}
