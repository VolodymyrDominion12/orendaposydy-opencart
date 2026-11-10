<?php
class ModelExtensionKristalSeo extends Model {
	public function getMeta($entity_type, $entity_id, $language_id = null) {
		if ($language_id === null) {
			$language_id = (int)$this->config->get('config_language_id');
		}

		$sql = "SELECT `h1`, `seo_text` FROM `" . DB_PREFIX . "kristal_seo_meta`
				WHERE `entity_type` = '" . $this->db->escape($entity_type) . "'
				AND `entity_id` = '" . (int)$entity_id . "'
				AND `language_id` = '" . (int)$language_id . "'
				LIMIT 1";

		try {
			$query = $this->db->query($sql);

			if ($query->num_rows) {
				return $query->row;
			}
		} catch (\Exception $e) {
			return array(
				'h1'       => '',
				'seo_text' => ''
			);
		}

		return array(
			'h1'       => '',
			'seo_text' => ''
		);
	}

	public function getCategoryMinPrice($category_id) {
		$sql = "SELECT MIN(p.price) AS min_price
				FROM `" . DB_PREFIX . "product` p
				JOIN `" . DB_PREFIX . "product_to_category` p2c ON (p.product_id = p2c.product_id)
				JOIN `" . DB_PREFIX . "product_to_store` p2s ON (p.product_id = p2s.product_id)
				WHERE p2c.category_id = '" . (int)$category_id . "'
				AND p2s.store_id = '" . (int)$this->config->get('config_store_id') . "'
				AND p.status = '1'
				AND p.price > 0";

		$query = $this->db->query($sql);

		if ($query->num_rows && $query->row['min_price'] !== null) {
			return (float)$query->row['min_price'];
		}

		return 0;
	}

	public function getSitemapCategories($store_id, $language_id) {
		$sql = "SELECT c.category_id, c.date_modified
				FROM `" . DB_PREFIX . "category` c
				JOIN `" . DB_PREFIX . "category_to_store` c2s ON (c.category_id = c2s.category_id)
				WHERE c2s.store_id = '" . (int)$store_id . "'
				AND c.status = '1'
				ORDER BY c.sort_order, c.category_id";

		$query = $this->db->query($sql);

		return $query->rows;
	}

	public function getSitemapProducts($store_id) {
		$sql = "SELECT p.product_id, p.date_modified
				FROM `" . DB_PREFIX . "product` p
				JOIN `" . DB_PREFIX . "product_to_store` p2s ON (p.product_id = p2s.product_id)
				WHERE p2s.store_id = '" . (int)$store_id . "'
				AND p.status = '1'
				ORDER BY p.product_id";

		$query = $this->db->query($sql);

		return $query->rows;
	}

	public function getSitemapFilterPages() {
		$table = DB_PREFIX . "kristal_filter_page";
		$check = $this->db->query("SHOW TABLES LIKE '" . $table . "'");

		if (!$check->num_rows) {
			return array();
		}

		$sql = "SELECT `category_id`, `keyword` FROM `" . $table . "`";
		$query = $this->db->query($sql);

		return $query->rows;
	}

	public function getSitemapInformation($store_id) {
		$sql = "SELECT i.information_id
				FROM `" . DB_PREFIX . "information` i
				JOIN `" . DB_PREFIX . "information_to_store` i2s ON (i.information_id = i2s.information_id)
				WHERE i2s.store_id = '" . (int)$store_id . "'
				AND i.status = '1'
				ORDER BY i.sort_order";

		$query = $this->db->query($sql);

		return $query->rows;
	}
}
