<?php
/**
 * Модель блогу та статей (kristal_blog, 013).
 * Захищені запити для безпечної роботи до застосування міграцій на проді.
 */
class ModelExtensionKristalBlog extends Model {

	public function getPosts($data = array()) {
		try {
			$sql = "SELECT p.*, c.title AS category_title, c.slug AS category_slug 
				FROM `" . DB_PREFIX . "kristal_blog_post` p
				LEFT JOIN `" . DB_PREFIX . "kristal_blog_post_to_category` p2c ON (p.post_id = p2c.post_id)
				LEFT JOIN `" . DB_PREFIX . "kristal_blog_category` c ON (p2c.category_id = c.category_id)
				WHERE p.`status` = 1";

			if (!empty($data['filter_category_id'])) {
				$sql .= " AND p2c.`category_id` = '" . (int)$data['filter_category_id'] . "'";
			}

			$sql .= " GROUP BY p.`post_id`";
			$sql .= " ORDER BY p.`sort_order` ASC, p.`date_added` DESC";

			if (isset($data['start']) || isset($data['limit'])) {
				if ($data['start'] < 0) {
					$data['start'] = 0;
				}

				if ($data['limit'] < 1) {
					$data['limit'] = 10;
				}

				$sql .= " LIMIT " . (int)$data['start'] . "," . (int)$data['limit'];
			}

			$query = $this->db->query($sql);

			return $query->rows;
		} catch (\Exception $e) {
			return array();
		}
	}

	public function getPost($post_id) {
		try {
			$query = $this->db->query("SELECT p.*, c.title AS category_title, c.slug AS category_slug, c.category_id 
				FROM `" . DB_PREFIX . "kristal_blog_post` p
				LEFT JOIN `" . DB_PREFIX . "kristal_blog_post_to_category` p2c ON (p.post_id = p2c.post_id)
				LEFT JOIN `" . DB_PREFIX . "kristal_blog_category` c ON (p2c.category_id = c.category_id)
				WHERE p.`post_id` = '" . (int)$post_id . "' AND p.`status` = 1");

			if ($query->num_rows) {
				$this->db->query("UPDATE `" . DB_PREFIX . "kristal_blog_post` SET `viewed` = `viewed` + 1 WHERE `post_id` = '" . (int)$post_id . "'");
			}

			return $query->row;
		} catch (\Exception $e) {
			return false;
		}
	}

	public function getPostBySlug($slug) {
		try {
			$query = $this->db->query("SELECT p.*, c.title AS category_title, c.slug AS category_slug, c.category_id 
				FROM `" . DB_PREFIX . "kristal_blog_post` p
				LEFT JOIN `" . DB_PREFIX . "kristal_blog_post_to_category` p2c ON (p.post_id = p2c.post_id)
				LEFT JOIN `" . DB_PREFIX . "kristal_blog_category` c ON (p2c.category_id = c.category_id)
				WHERE p.`slug` = '" . $this->db->escape($slug) . "' AND p.`status` = 1");

			if ($query->num_rows) {
				$this->db->query("UPDATE `" . DB_PREFIX . "kristal_blog_post` SET `viewed` = `viewed` + 1 WHERE `post_id` = '" . (int)$query->row['post_id'] . "'");
			}

			return $query->row;
		} catch (\Exception $e) {
			return false;
		}
	}

	public function getCategories() {
		try {
			$query = $this->db->query("SELECT * FROM `" . DB_PREFIX . "kristal_blog_category` WHERE `status` = 1 ORDER BY `sort_order` ASC, `title` ASC");

			return $query->rows;
		} catch (\Exception $e) {
			return array();
		}
	}

	public function getCategory($category_id) {
		try {
			$query = $this->db->query("SELECT * FROM `" . DB_PREFIX . "kristal_blog_category` WHERE `category_id` = '" . (int)$category_id . "' AND `status` = 1");

			return $query->row;
		} catch (\Exception $e) {
			return false;
		}
	}

	public function getPostRelatedProducts($post_id) {
		try {
			$lang_id = (int)$this->config->get('config_language_id');
			$sql = "SELECT p.product_id, p.image, p.price, pd.name, pr.unit, pr.deposit
				FROM `" . DB_PREFIX . "kristal_blog_post_related_product` rp
				INNER JOIN `" . DB_PREFIX . "product` p ON (rp.product_id = p.product_id)
				LEFT JOIN `" . DB_PREFIX . "product_description` pd ON (p.product_id = pd.product_id AND pd.language_id = '" . $lang_id . "')
				LEFT JOIN `" . DB_PREFIX . "kristal_product_rental` pr ON (p.product_id = pr.product_id)
				WHERE rp.post_id = '" . (int)$post_id . "' AND p.status = 1
				ORDER BY p.sort_order ASC, pd.name ASC";

			$query = $this->db->query($sql);

			return $query->rows;
		} catch (\Exception $e) {
			return array();
		}
	}

	public function getTotalPosts($data = array()) {
		try {
			$sql = "SELECT COUNT(DISTINCT p.post_id) AS total 
				FROM `" . DB_PREFIX . "kristal_blog_post` p
				LEFT JOIN `" . DB_PREFIX . "kristal_blog_post_to_category` p2c ON (p.post_id = p2c.post_id)
				WHERE p.`status` = 1";

			if (!empty($data['filter_category_id'])) {
				$sql .= " AND p2c.`category_id` = '" . (int)$data['filter_category_id'] . "'";
			}

			$query = $this->db->query($sql);

			return (int)$query->row['total'];
		} catch (\Exception $e) {
			return 0;
		}
	}
}
