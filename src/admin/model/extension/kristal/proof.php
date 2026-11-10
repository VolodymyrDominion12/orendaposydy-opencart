<?php
/**
 * Модель адмінки для портфоліо кейсів та відгуків (kristal_proof, 014).
 * Захищені запити для безпечної роботи до застосування міграцій.
 */
class ModelExtensionKristalProof extends Model {

	public function getCases() {
		try {
			$query = $this->db->query("SELECT * FROM `" . DB_PREFIX . "kristal_case` ORDER BY `sort_order` ASC, `date_added` DESC");

			return $query->rows;
		} catch (\Exception $e) {
			return array();
		}
	}

	public function getCase($case_id) {
		try {
			$query = $this->db->query("SELECT * FROM `" . DB_PREFIX . "kristal_case` WHERE `case_id` = '" . (int)$case_id . "'");

			return $query->row;
		} catch (\Exception $e) {
			return false;
		}
	}

	public function addCase($data) {
		try {
			$this->db->query("INSERT INTO `" . DB_PREFIX . "kristal_case` SET 
				`title` = '" . $this->db->escape($data['title']) . "',
				`slug` = '" . $this->db->escape($data['slug']) . "',
				`event_type` = '" . $this->db->escape($data['event_type']) . "',
				`guests` = '" . (int)$data['guests'] . "',
				`location` = '" . $this->db->escape($data['location']) . "',
				`date_event` = '" . $this->db->escape($data['date_event']) . "',
				`summary` = '" . $this->db->escape($data['summary']) . "',
				`description` = '" . $this->db->escape($data['description']) . "',
				`image` = '" . $this->db->escape($data['image']) . "',
				`sort_order` = '" . (int)$data['sort_order'] . "',
				`status` = '" . (int)$data['status'] . "',
				`date_added` = NOW()");

			$case_id = $this->db->getLastId();

			// SEO URL
			if (!empty($data['slug'])) {
				$this->db->query("INSERT INTO `" . DB_PREFIX . "seo_url` SET 
					`store_id` = 0, `language_id` = 2,
					`query` = 'case_id=" . (int)$case_id . "',
					`keyword` = '" . $this->db->escape($data['slug']) . "'");
			}

			return $case_id;
		} catch (\Exception $e) {
			return 0;
		}
	}

	public function editCase($case_id, $data) {
		try {
			$this->db->query("UPDATE `" . DB_PREFIX . "kristal_case` SET 
				`title` = '" . $this->db->escape($data['title']) . "',
				`slug` = '" . $this->db->escape($data['slug']) . "',
				`event_type` = '" . $this->db->escape($data['event_type']) . "',
				`guests` = '" . (int)$data['guests'] . "',
				`location` = '" . $this->db->escape($data['location']) . "',
				`date_event` = '" . $this->db->escape($data['date_event']) . "',
				`summary` = '" . $this->db->escape($data['summary']) . "',
				`description` = '" . $this->db->escape($data['description']) . "',
				`image` = '" . $this->db->escape($data['image']) . "',
				`sort_order` = '" . (int)$data['sort_order'] . "',
				`status` = '" . (int)$data['status'] . "'
				WHERE `case_id` = '" . (int)$case_id . "'");

			// Оновлення SEO URL
			$this->db->query("DELETE FROM `" . DB_PREFIX . "seo_url` WHERE `query` = 'case_id=" . (int)$case_id . "'");
			if (!empty($data['slug'])) {
				$this->db->query("INSERT INTO `" . DB_PREFIX . "seo_url` SET 
					`store_id` = 0, `language_id` = 2,
					`query` = 'case_id=" . (int)$case_id . "',
					`keyword` = '" . $this->db->escape($data['slug']) . "'");
			}
		} catch (\Exception $e) {
			// Ігноруємо якщо таблиць немає
		}
	}

	public function deleteCase($case_id) {
		try {
			$this->db->query("DELETE FROM `" . DB_PREFIX . "kristal_case` WHERE `case_id` = '" . (int)$case_id . "'");
			$this->db->query("DELETE FROM `" . DB_PREFIX . "kristal_case_image` WHERE `case_id` = '" . (int)$case_id . "'");
			$this->db->query("DELETE FROM `" . DB_PREFIX . "kristal_case_product` WHERE `case_id` = '" . (int)$case_id . "'");
			$this->db->query("DELETE FROM `" . DB_PREFIX . "seo_url` WHERE `query` = 'case_id=" . (int)$case_id . "'");
		} catch (\Exception $e) {
		}
	}

	public function getTestimonials() {
		try {
			$query = $this->db->query("SELECT * FROM `" . DB_PREFIX . "kristal_testimonial` ORDER BY `sort_order` ASC, `date_added` DESC");

			return $query->rows;
		} catch (\Exception $e) {
			return array();
		}
	}

	public function getTestimonial($testimonial_id) {
		try {
			$query = $this->db->query("SELECT * FROM `" . DB_PREFIX . "kristal_testimonial` WHERE `testimonial_id` = '" . (int)$testimonial_id . "'");

			return $query->row;
		} catch (\Exception $e) {
			return false;
		}
	}

	public function addTestimonial($data) {
		try {
			$this->db->query("INSERT INTO `" . DB_PREFIX . "kristal_testimonial` SET 
				`author_name` = '" . $this->db->escape($data['author_name']) . "',
				`author_role` = '" . $this->db->escape($data['author_role']) . "',
				`rating` = '" . (int)$data['rating'] . "',
				`text` = '" . $this->db->escape($data['text']) . "',
				`event_title` = '" . $this->db->escape($data['event_title']) . "',
				`source` = '" . $this->db->escape($data['source']) . "',
				`source_url` = '" . $this->db->escape($data['source_url']) . "',
				`avatar` = '" . $this->db->escape(isset($data['avatar']) ? $data['avatar'] : '') . "',
				`date_added` = '" . $this->db->escape(!empty($data['date_added']) ? $data['date_added'] : date('Y-m-d')) . "',
				`sort_order` = '" . (int)$data['sort_order'] . "',
				`status` = '" . (int)$data['status'] . "'");

			return $this->db->getLastId();
		} catch (\Exception $e) {
			return 0;
		}
	}

	public function editTestimonial($testimonial_id, $data) {
		try {
			$this->db->query("UPDATE `" . DB_PREFIX . "kristal_testimonial` SET 
				`author_name` = '" . $this->db->escape($data['author_name']) . "',
				`author_role` = '" . $this->db->escape($data['author_role']) . "',
				`rating` = '" . (int)$data['rating'] . "',
				`text` = '" . $this->db->escape($data['text']) . "',
				`event_title` = '" . $this->db->escape($data['event_title']) . "',
				`source` = '" . $this->db->escape($data['source']) . "',
				`source_url` = '" . $this->db->escape($data['source_url']) . "',
				`sort_order` = '" . (int)$data['sort_order'] . "',
				`status` = '" . (int)$data['status'] . "'
				WHERE `testimonial_id` = '" . (int)$testimonial_id . "'");
		} catch (\Exception $e) {
		}
	}

	public function deleteTestimonial($testimonial_id) {
		try {
			$this->db->query("DELETE FROM `" . DB_PREFIX . "kristal_testimonial` WHERE `testimonial_id` = '" . (int)$testimonial_id . "'");
		} catch (\Exception $e) {
		}
	}
}
