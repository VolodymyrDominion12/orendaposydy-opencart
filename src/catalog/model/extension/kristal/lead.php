<?php
/**
 * Модель каталогу «Крістал: ліди» (009).
 * Збереження заявок та прикріплених файлів у БД.
 * PHP 7.3+.
 */
class ModelExtensionKristalLead extends Model {

	/**
	 * Додавання нової заявки (ліда).
	 *
	 * @param array $data
	 * @return int ID створеного ліда
	 */
	public function addLead(array $data) {
		$type = isset($data['type']) && $data['type'] !== '' ? substr(trim((string)$data['type']), 0, 32) : 'calc_15m';
		$status = isset($data['status']) && $data['status'] !== '' ? substr(trim((string)$data['status']), 0, 32) : 'new';
		$name = isset($data['name']) ? substr(trim((string)$data['name']), 0, 255) : '';
		$phone = isset($data['phone']) ? substr(trim((string)$data['phone']), 0, 32) : '';
		$email = isset($data['email']) ? substr(trim((string)$data['email']), 0, 255) : '';
		$channel = isset($data['contact_channel']) && $data['contact_channel'] !== '' ? substr(trim((string)$data['contact_channel']), 0, 32) : 'viber';
		$comment = isset($data['comment']) ? trim((string)$data['comment']) : '';
		$sourceUrl = isset($data['source_url']) ? substr(trim((string)$data['source_url']), 0, 512) : '';

		$eventDate = !empty($data['event_date']) && preg_match('/^\d{4}-\d{2}-\d{2}$/', $data['event_date']) ? "'" . $this->db->escape($data['event_date']) . "'" : "NULL";
		$guests = isset($data['guests']) && (int)$data['guests'] > 0 ? (int)$data['guests'] : "NULL";
		$productId = isset($data['product_id']) && (int)$data['product_id'] > 0 ? (int)$data['product_id'] : "NULL";
		$quantity = isset($data['quantity']) && (int)$data['quantity'] > 0 ? (int)$data['quantity'] : "NULL";

		$utmSource   = !empty($data['utm_source'])   ? "'" . $this->db->escape(substr((string)$data['utm_source'], 0, 255)) . "'" : "NULL";
		$utmMedium   = !empty($data['utm_medium'])   ? "'" . $this->db->escape(substr((string)$data['utm_medium'], 0, 255)) . "'" : "NULL";
		$utmCampaign = !empty($data['utm_campaign']) ? "'" . $this->db->escape(substr((string)$data['utm_campaign'], 0, 255)) . "'" : "NULL";
		$utmContent  = !empty($data['utm_content'])  ? "'" . $this->db->escape(substr((string)$data['utm_content'], 0, 255)) . "'" : "NULL";
		$utmTerm     = !empty($data['utm_term'])     ? "'" . $this->db->escape(substr((string)$data['utm_term'], 0, 255)) . "'" : "NULL";

		$ip = isset($this->request->server['REMOTE_ADDR']) ? substr((string)$this->request->server['REMOTE_ADDR'], 0, 45) : '';
		$userAgent = isset($this->request->server['HTTP_USER_AGENT']) ? substr((string)$this->request->server['HTTP_USER_AGENT'], 0, 255) : '';

		$sql = "INSERT INTO `" . DB_PREFIX . "kristal_lead` SET
			`type` = '" . $this->db->escape($type) . "',
			`status` = '" . $this->db->escape($status) . "',
			`name` = '" . $this->db->escape($name) . "',
			`phone` = '" . $this->db->escape($phone) . "',
			`email` = '" . $this->db->escape($email) . "',
			`event_date` = " . $eventDate . ",
			`guests` = " . $guests . ",
			`product_id` = " . $productId . ",
			`quantity` = " . $quantity . ",
			`contact_channel` = '" . $this->db->escape($channel) . "',
			`comment` = " . ($comment !== '' ? "'" . $this->db->escape($comment) . "'" : "NULL") . ",
			`source_url` = '" . $this->db->escape($sourceUrl) . "',
			`utm_source` = " . $utmSource . ",
			`utm_medium` = " . $utmMedium . ",
			`utm_campaign` = " . $utmCampaign . ",
			`utm_content` = " . $utmContent . ",
			`utm_term` = " . $utmTerm . ",
			`ip` = '" . $this->db->escape($ip) . "',
			`user_agent` = '" . $this->db->escape($userAgent) . "',
			`created_at` = NOW(),
			`updated_at` = NOW()";

		$this->db->query($sql);
		return (int)$this->db->getLastId();
	}

	/**
	 * Прикріплення файлу до заявки.
	 *
	 * @param int $leadId
	 * @param array $fileData
	 * @return int ID файлу
	 */
	public function addLeadFile($leadId, array $fileData) {
		$leadId = (int)$leadId;
		$origName = isset($fileData['filename_orig']) ? substr(trim((string)$fileData['filename_orig']), 0, 255) : '';
		$storedName = isset($fileData['filename_stored']) ? substr(trim((string)$fileData['filename_stored']), 0, 255) : '';
		$filesize = isset($fileData['filesize']) ? (int)$fileData['filesize'] : 0;
		$mimeType = isset($fileData['mime_type']) ? substr(trim((string)$fileData['mime_type']), 0, 128) : '';

		$sql = "INSERT INTO `" . DB_PREFIX . "kristal_lead_file` SET
			`lead_id` = '" . $leadId . "',
			`filename_orig` = '" . $this->db->escape($origName) . "',
			`filename_stored` = '" . $this->db->escape($storedName) . "',
			`filesize` = '" . $filesize . "',
			`mime_type` = '" . $this->db->escape($mimeType) . "',
			`created_at` = NOW()";

		$this->db->query($sql);
		return (int)$this->db->getLastId();
	}

	/**
	 * Отримання заявки за ID.
	 *
	 * @param int $leadId
	 * @return array|false
	 */
	public function getLead($leadId) {
		$query = $this->db->query("SELECT * FROM `" . DB_PREFIX . "kristal_lead` WHERE `lead_id` = '" . (int)$leadId . "' LIMIT 1");
		return $query->num_rows ? $query->row : false;
	}

	/**
	 * Отримання файлів заявки.
	 *
	 * @param int $leadId
	 * @return array
	 */
	public function getLeadFiles($leadId) {
		$query = $this->db->query("SELECT * FROM `" . DB_PREFIX . "kristal_lead_file` WHERE `lead_id` = '" . (int)$leadId . "' ORDER BY `file_id` ASC");
		return $query->rows;
	}
}
