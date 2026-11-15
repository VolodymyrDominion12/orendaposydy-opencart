<?php
/**
 * Адмін-модель «Ми можемо для Вас приготувати» (фіча 028 kristal_catering).
 * PHP 7.3+.
 */
class ModelExtensionKristalCatering extends Model {

	public function getPages() {
		$query = $this->db->query("SELECT * FROM `" . DB_PREFIX . "kristal_catering_page` ORDER BY `sort_order` ASC, `page_id` ASC");

		$pages = array();
		foreach ($query->rows as $row) {
			$facts = json_decode((string)$row['facts'], true);
			$dishes = json_decode((string)$row['dishes'], true);
			$faq = json_decode((string)$row['faq'], true);

			$row['facts_list'] = is_array($facts) ? $facts : array();
			$row['dishes_list'] = is_array($dishes) ? $dishes : array();
			$row['faq_list'] = is_array($faq) ? $faq : array();
			$row['kits'] = $this->getKitsByPage($row['page_id']);

			$pages[] = $row;
		}

		return $pages;
	}

	public function getKitsByPage($page_id) {
		$query = $this->db->query("SELECT * FROM `" . DB_PREFIX . "kristal_catering_kit`
			WHERE `page_id` = '" . (int)$page_id . "'
			ORDER BY `sort_order` ASC, `kit_id` ASC");

		$kits = array();
		foreach ($query->rows as $row) {
			$items = json_decode((string)$row['items'], true);
			$row['items_list'] = is_array($items) ? $items : array();
			$kits[] = $row;
		}

		return $kits;
	}

	public function savePage($page_id, $post) {
		$page_id = (int)$page_id;
		if ($page_id <= 0) {
			return;
		}

		$title = $this->cleanText($post, 'title', 160);
		$short_desc = $this->cleanText($post, 'short_desc', 280);
		$hero_label = $this->cleanText($post, 'hero_label', 120);
		$hero_title = $this->cleanText($post, 'hero_title', 160);
		$hero_lead = $this->cleanText($post, 'hero_lead', 500);
		$hero_image = $this->cleanText($post, 'hero_image', 255);
		$meta_title = $this->cleanText($post, 'meta_title', 160);
		$meta_description = $this->cleanText($post, 'meta_description', 300);
		$sort_order = isset($post['sort_order']) ? (int)$post['sort_order'] : 0;
		$status = !empty($post['status']) ? 1 : 0;

		// Факти у hero (рядки з textarea)
		$facts = array();
		$facts_raw = $this->decode(isset($post['facts_text']) ? $post['facts_text'] : '');
		foreach (preg_split('/\r\n|\r|\n/', $facts_raw) as $line) {
			$line = trim($line);
			if ($line !== '') {
				$facts[] = utf8_substr($line, 0, 100);
			}
		}

		// Групи страв
		$dishes = array();
		if (isset($post['dishes']) && is_array($post['dishes'])) {
			foreach ($post['dishes'] as $group) {
				if (!is_array($group)) {
					continue;
				}
				$g_title = utf8_substr(trim($this->decode(isset($group['title']) ? $group['title'] : '')), 0, 160);
				$g_desc = utf8_substr(trim($this->decode(isset($group['desc']) ? $group['desc'] : '')), 0, 280);
				$items_raw = $this->decode(isset($group['items_text']) ? $group['items_text'] : '');
				$g_items = array();
				foreach (preg_split('/\r\n|\r|\n/', $items_raw) as $line) {
					$line = trim($line);
					if ($line !== '') {
						$g_items[] = utf8_substr($line, 0, 200);
					}
				}
				if ($g_title !== '' && $g_items) {
					$dishes[] = array(
						'title' => $g_title,
						'desc'  => $g_desc,
						'items' => $g_items
					);
				}
			}
		}

		// FAQ
		$faq = array();
		if (isset($post['faq']) && is_array($post['faq'])) {
			foreach ($post['faq'] as $item) {
				if (!is_array($item)) {
					continue;
				}
				$q = utf8_substr(trim($this->decode(isset($item['q']) ? $item['q'] : '')), 0, 240);
				$a = utf8_substr(trim($this->decode(isset($item['a']) ? $item['a'] : '')), 0, 1000);
				if ($q !== '' && $a !== '') {
					$faq[] = array('q' => $q, 'a' => $a);
				}
			}
		}

		$this->db->query("UPDATE `" . DB_PREFIX . "kristal_catering_page` SET
			`title` = '" . $this->db->escape($title) . "',
			`short_desc` = '" . $this->db->escape($short_desc) . "',
			`hero_label` = '" . $this->db->escape($hero_label) . "',
			`hero_title` = '" . $this->db->escape($hero_title) . "',
			`hero_lead` = '" . $this->db->escape($hero_lead) . "',
			`hero_image` = '" . $this->db->escape($hero_image) . "',
			`facts` = '" . $this->db->escape(json_encode($facts, JSON_UNESCAPED_UNICODE)) . "',
			`dishes` = '" . $this->db->escape(json_encode($dishes, JSON_UNESCAPED_UNICODE)) . "',
			`faq` = '" . $this->db->escape(json_encode($faq, JSON_UNESCAPED_UNICODE)) . "',
			`meta_title` = '" . $this->db->escape($meta_title) . "',
			`meta_description` = '" . $this->db->escape($meta_description) . "',
			`sort_order` = '" . $sort_order . "',
			`status` = '" . $status . "',
			`updated_at` = NOW()
			WHERE `page_id` = '" . $page_id . "'");

		// Готові комплекси сторінки
		if (isset($post['kits']) && is_array($post['kits'])) {
			$allowed_tiers = array('basic', 'standard', 'premium');
			foreach ($post['kits'] as $kit) {
				if (!is_array($kit)) {
					continue;
				}
				$kit_id = isset($kit['kit_id']) ? (int)$kit['kit_id'] : 0;
				$name = utf8_substr(trim($this->decode(isset($kit['name']) ? $kit['name'] : '')), 0, 160);
				if ($name === '') {
					continue;
				}
				$tier = isset($kit['tier']) && in_array($kit['tier'], $allowed_tiers, true) ? $kit['tier'] : 'standard';
				$badge = utf8_substr(trim($this->decode(isset($kit['badge']) ? $kit['badge'] : '')), 0, 64);
				$subtitle = utf8_substr(trim($this->decode(isset($kit['subtitle']) ? $kit['subtitle'] : '')), 0, 160);
				$price_label = utf8_substr(trim($this->decode(isset($kit['price_label']) ? $kit['price_label'] : '')), 0, 80);
				$min_guests = max(1, isset($kit['min_guests']) ? (int)$kit['min_guests'] : 15);
				$kit_sort = isset($kit['sort_order']) ? (int)$kit['sort_order'] : 0;
				$kit_status = !empty($kit['status']) ? 1 : 0;

				$items = array();
				$items_raw = $this->decode(isset($kit['items_text']) ? $kit['items_text'] : '');
				foreach (preg_split('/\r\n|\r|\n/', $items_raw) as $line) {
					$line = trim($line);
					if ($line === '') {
						continue;
					}
					$included = true;
					if (strpos($line, '- ') === 0) {
						$included = false;
						$line = trim(substr($line, 2));
					} elseif (strpos($line, '+ ') === 0) {
						$line = trim(substr($line, 2));
					}
					if ($line !== '') {
						$items[] = array(
							'text'     => utf8_substr($line, 0, 200),
							'included' => $included
						);
					}
				}

				$items_json = json_encode($items, JSON_UNESCAPED_UNICODE);

				if ($kit_id > 0) {
					$this->db->query("UPDATE `" . DB_PREFIX . "kristal_catering_kit` SET
						`tier` = '" . $this->db->escape($tier) . "',
						`name` = '" . $this->db->escape($name) . "',
						`badge` = '" . $this->db->escape($badge) . "',
						`subtitle` = '" . $this->db->escape($subtitle) . "',
						`price_label` = '" . $this->db->escape($price_label) . "',
						`min_guests` = '" . $min_guests . "',
						`items` = '" . $this->db->escape($items_json) . "',
						`sort_order` = '" . $kit_sort . "',
						`status` = '" . $kit_status . "'
						WHERE `kit_id` = '" . $kit_id . "' AND `page_id` = '" . $page_id . "'");
				} else {
					$this->db->query("INSERT INTO `" . DB_PREFIX . "kristal_catering_kit` SET
						`page_id` = '" . $page_id . "',
						`tier` = '" . $this->db->escape($tier) . "',
						`name` = '" . $this->db->escape($name) . "',
						`badge` = '" . $this->db->escape($badge) . "',
						`subtitle` = '" . $this->db->escape($subtitle) . "',
						`price_label` = '" . $this->db->escape($price_label) . "',
						`min_guests` = '" . $min_guests . "',
						`items` = '" . $this->db->escape($items_json) . "',
						`sort_order` = '" . $kit_sort . "',
						`status` = '" . $kit_status . "'");
				}
			}
		}
	}

	public function deleteKit($kit_id) {
		$this->db->query("DELETE FROM `" . DB_PREFIX . "kristal_catering_kit` WHERE `kit_id` = '" . (int)$kit_id . "'");
	}

	private function cleanText($post, $key, $max) {
		$val = isset($post[$key]) && is_scalar($post[$key]) ? trim($this->decode($post[$key])) : '';
		return utf8_substr($val, 0, $max);
	}

	private function decode($s) {
		return html_entity_decode((string)$s, ENT_QUOTES, 'UTF-8');
	}
}
