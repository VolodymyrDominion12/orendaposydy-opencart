<?php
/**
 * Модель відгуків клієнтів (kristal_proof).
 * Захищені запити для безпечної роботи без помилок до застосування міграцій на проді.
 */
class ModelExtensionKristalTestimonial extends Model {

	public function getTestimonials($data = array()) {
		try {
			$sql = "SELECT * FROM `" . DB_PREFIX . "kristal_testimonial` WHERE `status` = 1";

			if (!empty($data['filter_rating'])) {
				$sql .= " AND `rating` = '" . (int)$data['filter_rating'] . "'";
			}

			$sql .= " ORDER BY `sort_order` ASC, `date_added` DESC";

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
		} catch (\Exception $e) {
			return array();
		}
	}

	public function getTotalTestimonials($data = array()) {
		try {
			$sql = "SELECT COUNT(*) AS total FROM `" . DB_PREFIX . "kristal_testimonial` WHERE `status` = 1";

			if (!empty($data['filter_rating'])) {
				$sql .= " AND `rating` = '" . (int)$data['filter_rating'] . "'";
			}

			$query = $this->db->query($sql);

			return (int)$query->row['total'];
		} catch (\Exception $e) {
			return 0;
		}
	}

	public function getStats() {
		try {
			$query = $this->db->query("SELECT COUNT(*) AS count, AVG(rating) AS avg_rating FROM `" . DB_PREFIX . "kristal_testimonial` WHERE `status` = 1");

			if ($query->num_rows && (int)$query->row['count'] > 0) {
				return array(
					'count'      => (int)$query->row['count'],
					'avg_rating' => round((float)$query->row['avg_rating'], 1)
				);
			}

			return array(
				'count'      => 0,
				'avg_rating' => 5.0
			);
		} catch (\Exception $e) {
			return array(
				'count'      => 0,
				'avg_rating' => 5.0
			);
		}
	}
}
