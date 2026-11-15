<?php
/**
 * Модель «Ми можемо для Вас приготувати» (фіча 028 kristal_catering).
 * Кешовані запити сторінок та готових комплексів; ключі kristal.catering.*.
 * PHP 7.3+.
 */
class ModelExtensionKristalCatering extends Model {
	private static $icons = array(
		'buffet'      => 'glass',
		'banquet'     => 'plate',
		'coffeebreak' => 'coffee',
		'wedding'     => 'decor'
	);

	private static $routes = array(
		'buffet'      => 'extension/kristal/catering/buffet',
		'banquet'     => 'extension/kristal/catering/banquet',
		'coffeebreak' => 'extension/kristal/catering/coffeebreak',
		'wedding'     => 'extension/kristal/catering/wedding'
	);

	public function getMenuPages() {
		$store_id = (int)$this->config->get('config_store_id');
		$language_id = (int)$this->config->get('config_language_id');
		$key = 'kristal.catering.menu.' . $store_id . '.' . $language_id;

		$pages = $this->cache->get($key);

		if (is_array($pages)) {
			return $pages;
		}

		try {
			$query = $this->db->query("SELECT `page_id`, `code`, `slug`, `title`, `short_desc`
				FROM `" . DB_PREFIX . "kristal_catering_page`
				WHERE `status` = '1'
				ORDER BY `sort_order` ASC");
		} catch (\Exception $e) {
			return array();
		}

		$pages = array();

		foreach ($query->rows as $row) {
			$code = (string)$row['code'];
			$route = isset(self::$routes[$code]) ? self::$routes[$code] : 'extension/kristal/catering';
			$pages[] = array(
				'page_id'    => (int)$row['page_id'],
				'code'       => $code,
				'slug'       => (string)$row['slug'],
				'title'      => (string)$row['title'],
				'short_desc' => (string)$row['short_desc'],
				'icon'       => isset(self::$icons[$code]) ? self::$icons[$code] : 'chef',
				'href'       => $this->url->link($route)
			);
		}

		$this->cache->set($key, $pages);

		return $pages;
	}

	public function getPageByCode($code) {
		$store_id = (int)$this->config->get('config_store_id');
		$language_id = (int)$this->config->get('config_language_id');
		$cache_key = 'kristal.catering.page.' . preg_replace('/[^a-z0-9_]/', '', (string)$code) . '.' . $store_id . '.' . $language_id;

		$cached = $this->cache->get($cache_key);

		if (is_array($cached)) {
			return $cached;
		}

		try {
			$query = $this->db->query("SELECT * FROM `" . DB_PREFIX . "kristal_catering_page`
				WHERE `code` = '" . $this->db->escape($code) . "' AND `status` = '1' LIMIT 1");
		} catch (\Exception $e) {
			return null;
		}

		if (!$query->num_rows) {
			return null;
		}

		$row = $query->row;
		$page_id = (int)$row['page_id'];

		$facts = json_decode((string)$row['facts'], true);
		$dishes = json_decode((string)$row['dishes'], true);
		$faq = json_decode((string)$row['faq'], true);

		$kits_query = $this->db->query("SELECT * FROM `" . DB_PREFIX . "kristal_catering_kit`
			WHERE `page_id` = '" . $page_id . "' AND `status` = '1'
			ORDER BY `sort_order` ASC");

		$kits = array();
		foreach ($kits_query->rows as $k) {
			$items = json_decode((string)$k['items'], true);
			$kits[] = array(
				'kit_id'      => (int)$k['kit_id'],
				'tier'        => (string)$k['tier'],
				'name'        => (string)$k['name'],
				'badge'       => (string)$k['badge'],
				'subtitle'    => (string)$k['subtitle'],
				'price_label' => trim((string)$k['price_label']),
				'min_guests'  => (int)$k['min_guests'],
				'items'       => is_array($items) ? $items : array()
			);
		}

		$route = isset(self::$routes[$code]) ? self::$routes[$code] : 'extension/kristal/catering';

		$page = array(
			'page_id'          => $page_id,
			'code'             => (string)$row['code'],
			'slug'             => (string)$row['slug'],
			'title'            => (string)$row['title'],
			'short_desc'       => (string)$row['short_desc'],
			'hero_label'       => (string)$row['hero_label'],
			'hero_title'       => (string)$row['hero_title'],
			'hero_lead'        => (string)$row['hero_lead'],
			'hero_image'       => (string)$row['hero_image'],
			'facts'            => is_array($facts) ? $facts : array(),
			'dishes'           => is_array($dishes) ? $dishes : array(),
			'faq'              => is_array($faq) ? $faq : array(),
			'meta_title'       => (string)$row['meta_title'],
			'meta_description' => (string)$row['meta_description'],
			'icon'             => isset(self::$icons[$code]) ? self::$icons[$code] : 'chef',
			'href'             => $this->url->link($route),
			'kits'             => $kits
		);

		$this->cache->set($cache_key, $page);

		return $page;
	}
}
