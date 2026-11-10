<?php
/**
 * Модель адмінки для блогу та статей (kristal_blog, 013).
 * Захищені запити для безпечної роботи до застосування міграцій.
 */
class ModelExtensionKristalBlog extends Model {

	public function getPosts() {
		try {
			$query = $this->db->query("SELECT p.*, c.title AS category_title 
				FROM `" . DB_PREFIX . "kristal_blog_post` p
				LEFT JOIN `" . DB_PREFIX . "kristal_blog_post_to_category` p2c ON (p.post_id = p2c.post_id)
				LEFT JOIN `" . DB_PREFIX . "kristal_blog_category` c ON (p2c.category_id = c.category_id)
				GROUP BY p.post_id
				ORDER BY p.sort_order ASC, p.date_added DESC");

			return $query->rows;
		} catch (\Exception $e) {
			return array();
		}
	}

	public function getPost($post_id) {
		try {
			$query = $this->db->query("SELECT * FROM `" . DB_PREFIX . "kristal_blog_post` WHERE `post_id` = '" . (int)$post_id . "'");

			return $query->row;
		} catch (\Exception $e) {
			return false;
		}
	}

	public function addPost($data) {
		try {
			$this->db->query("INSERT INTO `" . DB_PREFIX . "kristal_blog_post` SET 
				`title` = '" . $this->db->escape($data['title']) . "',
				`slug` = '" . $this->db->escape($data['slug']) . "',
				`summary` = '" . $this->db->escape($data['summary']) . "',
				`content` = '" . $this->db->escape($data['content']) . "',
				`image` = '" . $this->db->escape($data['image']) . "',
				`author` = '" . $this->db->escape($data['author']) . "',
				`sort_order` = '" . (int)$data['sort_order'] . "',
				`status` = '" . (int)$data['status'] . "',
				`date_added` = NOW(),
				`date_modified` = NOW()");

			$post_id = $this->db->getLastId();

			if (!empty($data['category_id'])) {
				$this->db->query("INSERT INTO `" . DB_PREFIX . "kristal_blog_post_to_category` SET `post_id` = '" . (int)$post_id . "', `category_id` = '" . (int)$data['category_id'] . "'");
			}

			// SEO URL
			if (!empty($data['slug'])) {
				$this->db->query("INSERT INTO `" . DB_PREFIX . "seo_url` SET 
					`store_id` = 0, `language_id` = 2,
					`query` = 'post_id=" . (int)$post_id . "',
					`keyword` = '" . $this->db->escape($data['slug']) . "'");
			}

			return $post_id;
		} catch (\Exception $e) {
			return 0;
		}
	}

	public function editPost($post_id, $data) {
		try {
			$this->db->query("UPDATE `" . DB_PREFIX . "kristal_blog_post` SET 
				`title` = '" . $this->db->escape($data['title']) . "',
				`slug` = '" . $this->db->escape($data['slug']) . "',
				`summary` = '" . $this->db->escape($data['summary']) . "',
				`content` = '" . $this->db->escape($data['content']) . "',
				`image` = '" . $this->db->escape($data['image']) . "',
				`author` = '" . $this->db->escape($data['author']) . "',
				`sort_order` = '" . (int)$data['sort_order'] . "',
				`status` = '" . (int)$data['status'] . "',
				`date_modified` = NOW()
				WHERE `post_id` = '" . (int)$post_id . "'");

			// Оновлення рубрики
			$this->db->query("DELETE FROM `" . DB_PREFIX . "kristal_blog_post_to_category` WHERE `post_id` = '" . (int)$post_id . "'");
			if (!empty($data['category_id'])) {
				$this->db->query("INSERT INTO `" . DB_PREFIX . "kristal_blog_post_to_category` SET `post_id` = '" . (int)$post_id . "', `category_id` = '" . (int)$data['category_id'] . "'");
			}

			// Оновлення SEO URL
			$this->db->query("DELETE FROM `" . DB_PREFIX . "seo_url` WHERE `query` = 'post_id=" . (int)$post_id . "'");
			if (!empty($data['slug'])) {
				$this->db->query("INSERT INTO `" . DB_PREFIX . "seo_url` SET 
					`store_id` = 0, `language_id` = 2,
					`query` = 'post_id=" . (int)$post_id . "',
					`keyword` = '" . $this->db->escape($data['slug']) . "'");
			}
		} catch (\Exception $e) {
		}
	}

	public function deletePost($post_id) {
		try {
			$this->db->query("DELETE FROM `" . DB_PREFIX . "kristal_blog_post` WHERE `post_id` = '" . (int)$post_id . "'");
			$this->db->query("DELETE FROM `" . DB_PREFIX . "kristal_blog_post_to_category` WHERE `post_id` = '" . (int)$post_id . "'");
			$this->db->query("DELETE FROM `" . DB_PREFIX . "kristal_blog_post_related_product` WHERE `post_id` = '" . (int)$post_id . "'");
			$this->db->query("DELETE FROM `" . DB_PREFIX . "seo_url` WHERE `query` = 'post_id=" . (int)$post_id . "'");
		} catch (\Exception $e) {
		}
	}

	public function getCategories() {
		try {
			$query = $this->db->query("SELECT * FROM `" . DB_PREFIX . "kristal_blog_category` ORDER BY `sort_order` ASC, `title` ASC");

			return $query->rows;
		} catch (\Exception $e) {
			return array();
		}
	}
}
