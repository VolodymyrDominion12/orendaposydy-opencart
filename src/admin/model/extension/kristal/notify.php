<?php
/**
 * Модель адмінки для модуля сповіщень «Крістал: сповіщення» (023).
 * Журнал відправок, фільтри, повторні спроби.
 * PHP 7.3+.
 */
class ModelExtensionKristalNotify extends Model {

	public function getLogs(array $filter = array(), $start = 0, $limit = 50) {
		$sql = "SELECT * FROM `" . DB_PREFIX . "kristal_notify_log` WHERE 1=1";

		if (!empty($filter['status'])) {
			$sql .= " AND `status` = '" . $this->db->escape((string)$filter['status']) . "'";
		}

		if (!empty($filter['channel'])) {
			$sql .= " AND `channel` = '" . $this->db->escape((string)$filter['channel']) . "'";
		}

		if (!empty($filter['event_type'])) {
			$sql .= " AND `event_type` = '" . $this->db->escape((string)$filter['event_type']) . "'";
		}

		$sql .= " ORDER BY `log_id` DESC LIMIT " . (int)$start . ", " . (int)$limit;

		$query = $this->db->query($sql);

		return $query->rows;
	}

	public function getTotalLogs(array $filter = array()) {
		$sql = "SELECT COUNT(*) AS total FROM `" . DB_PREFIX . "kristal_notify_log` WHERE 1=1";

		if (!empty($filter['status'])) {
			$sql .= " AND `status` = '" . $this->db->escape((string)$filter['status']) . "'";
		}

		if (!empty($filter['channel'])) {
			$sql .= " AND `channel` = '" . $this->db->escape((string)$filter['channel']) . "'";
		}

		if (!empty($filter['event_type'])) {
			$sql .= " AND `event_type` = '" . $this->db->escape((string)$filter['event_type']) . "'";
		}

		$query = $this->db->query($sql);

		return (int)$query->row['total'];
	}

	public function getLog($logId) {
		$query = $this->db->query("SELECT * FROM `" . DB_PREFIX . "kristal_notify_log` WHERE `log_id` = '" . (int)$logId . "' LIMIT 1");
		return $query->row;
	}

	public function updateLogStatus($logId, $status, $error = '') {
		$sql = "UPDATE `" . DB_PREFIX . "kristal_notify_log` SET 
			`status` = '" . $this->db->escape((string)$status) . "',
			`attempts` = `attempts` + 1,
			`error` = " . ($error !== '' ? "'" . $this->db->escape(utf8_substr($error, 0, 255)) . "'" : "NULL") . ",
			`updated_at` = NOW()
			WHERE `log_id` = '" . (int)$logId . "'";

		$this->db->query($sql);
	}

	public function deleteOldLogs($days = 30) {
		$days = max(1, (int)$days);
		$this->db->query("DELETE FROM `" . DB_PREFIX . "kristal_notify_log` WHERE `created_at` < DATE_SUB(NOW(), INTERVAL " . $days . " DAY)");
	}
}
