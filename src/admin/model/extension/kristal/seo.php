<?php
class ModelExtensionKristalSeo extends Model {
	public function saveMeta($entity_type, $entity_id, $language_id, $h1, $seo_text) {
		$sql = "INSERT INTO `" . DB_PREFIX . "kristal_seo_meta`
				(`entity_type`, `entity_id`, `language_id`, `h1`, `seo_text`)
				VALUES (
					'" . $this->db->escape($entity_type) . "',
					'" . (int)$entity_id . "',
					'" . (int)$language_id . "',
					'" . $this->db->escape($h1) . "',
					'" . $this->db->escape($seo_text) . "'
				)
				ON DUPLICATE KEY UPDATE
					`h1` = VALUES(`h1`),
					`seo_text` = VALUES(`seo_text`)";

		$this->db->query($sql);
		\Kristal\Cache_key::flush($this->cache);
	}

	public function getMeta($entity_type, $entity_id, $language_id) {
		$sql = "SELECT `h1`, `seo_text` FROM `" . DB_PREFIX . "kristal_seo_meta`
				WHERE `entity_type` = '" . $this->db->escape($entity_type) . "'
				AND `entity_id` = '" . (int)$entity_id . "'
				AND `language_id` = '" . (int)$language_id . "'
				LIMIT 1";

		$query = $this->db->query($sql);

		if ($query->num_rows) {
			return $query->row;
		}

		return array(
			'h1'       => '',
			'seo_text' => ''
		);
	}
}
