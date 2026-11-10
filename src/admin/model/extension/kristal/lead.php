<?php
/**
 * Адмін-модель «Крістал: ліди» (009).
 * Вибірка, фільтрація, оновлення статусів, видалення та експорт заявок.
 * PHP 7.3+.
 */
class ModelExtensionKristalLead extends Model {

	/**
	 * Отримання списку лідів за фільтрами.
	 *
	 * @param array $data
	 * @return array
	 */
	public function getLeads(array $data = array()) {
		$sql = "SELECT * FROM `" . DB_PREFIX . "kristal_lead` WHERE 1";

		if (!empty($data['filter_type'])) {
			$sql .= " AND `type` = '" . $this->db->escape($data['filter_type']) . "'";
		}

		if (!empty($data['filter_status'])) {
			$sql .= " AND `status` = '" . $this->db->escape($data['filter_status']) . "'";
		}

		if (!empty($data['filter_phone'])) {
			$sql .= " AND `phone` LIKE '%" . $this->db->escape($data['filter_phone']) . "%'";
		}

		if (!empty($data['filter_date_added'])) {
			$sql .= " AND DATE(`created_at`) = DATE('" . $this->db->escape($data['filter_date_added']) . "')";
		}

		$sort_data = array(
			'lead_id',
			'type',
			'status',
			'name',
			'phone',
			'event_date',
			'created_at'
		);

		if (isset($data['sort']) && in_array($data['sort'], $sort_data, true)) {
			$sql .= " ORDER BY `" . $data['sort'] . "`";
		} else {
			$sql .= " ORDER BY `lead_id`";
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

	/**
	 * Загальна кількість лідів за фільтром.
	 *
	 * @param array $data
	 * @return int
	 */
	public function getTotalLeads(array $data = array()) {
		$sql = "SELECT COUNT(*) AS total FROM `" . DB_PREFIX . "kristal_lead` WHERE 1";

		if (!empty($data['filter_type'])) {
			$sql .= " AND `type` = '" . $this->db->escape($data['filter_type']) . "'";
		}

		if (!empty($data['filter_status'])) {
			$sql .= " AND `status` = '" . $this->db->escape($data['filter_status']) . "'";
		}

		if (!empty($data['filter_phone'])) {
			$sql .= " AND `phone` LIKE '%" . $this->db->escape($data['filter_phone']) . "%'";
		}

		if (!empty($data['filter_date_added'])) {
			$sql .= " AND DATE(`created_at`) = DATE('" . $this->db->escape($data['filter_date_added']) . "')";
		}

		$query = $this->db->query($sql);
		return (int)$query->row['total'];
	}

	/**
	 * Отримання деталей ліда.
	 *
	 * @param int $leadId
	 * @return array|false
	 */
	public function getLead($leadId) {
		$query = $this->db->query("SELECT * FROM `" . DB_PREFIX . "kristal_lead` WHERE `lead_id` = '" . (int)$leadId . "' LIMIT 1");
		return $query->num_rows ? $query->row : false;
	}

	/**
	 * Отримання прикріплених файлів ліда.
	 *
	 * @param int $leadId
	 * @return array
	 */
	public function getLeadFiles($leadId) {
		$query = $this->db->query("SELECT * FROM `" . DB_PREFIX . "kristal_lead_file` WHERE `lead_id` = '" . (int)$leadId . "' ORDER BY `file_id` ASC");
		return $query->rows;
	}

	/**
	 * Отримання файлу за file_id.
	 *
	 * @param int $fileId
	 * @return array|false
	 */
	public function getFile($fileId) {
		$query = $this->db->query("SELECT * FROM `" . DB_PREFIX . "kristal_lead_file` WHERE `file_id` = '" . (int)$fileId . "' LIMIT 1");
		return $query->num_rows ? $query->row : false;
	}

	/**
	 * Оновлення статусу та коментаря менеджера.
	 *
	 * @param int $leadId
	 * @param string $status
	 * @param string $managerNote
	 */
	public function updateLeadStatus($leadId, $status, $managerNote = '') {
		$leadId = (int)$leadId;
		$status = substr(trim((string)$status), 0, 32);
		$managerNote = trim((string)$managerNote);

		$sql = "UPDATE `" . DB_PREFIX . "kristal_lead` SET
			`status` = '" . $this->db->escape($status) . "',
			`manager_note` = " . ($managerNote !== '' ? "'" . $this->db->escape($managerNote) . "'" : "NULL") . ",
			`updated_at` = NOW()
			WHERE `lead_id` = '" . $leadId . "'";

		$this->db->query($sql);
	}

	/**
	 * Видалення ліда та його файлів.
	 *
	 * @param int $leadId
	 */
	public function deleteLead($leadId) {
		$leadId = (int)$leadId;

		$files = $this->getLeadFiles($leadId);
		foreach ($files as $file) {
			$path = DIR_STORAGE . 'upload/' . $file['filename_stored'];
			if (is_file($path)) {
				@unlink($path);
			}
		}

		$this->db->query("DELETE FROM `" . DB_PREFIX . "kristal_lead_file` WHERE `lead_id` = '" . $leadId . "'");
		$this->db->query("DELETE FROM `" . DB_PREFIX . "kristal_lead` WHERE `lead_id` = '" . $leadId . "'");
	}
}
