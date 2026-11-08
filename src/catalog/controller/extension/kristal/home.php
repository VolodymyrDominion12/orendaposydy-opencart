<?php
/**
 * Головна «Крістал» (фіча 004). Налаштування — «Модулі → Крістал: головна» (module_kristal_home_* у $this->config, 0 запитів).
 *
 * Події (міграція 0008_kristal_home):
 *   controller/common/header/before → meta()  title/description/canonical головної — до того, як шапка прочитає document
 *   view/common/home/before         → view()  дані шаблону: hero, плитки категорій з «від N ₴», хіти, кроки, цифри, FAQ, SEO-текст
 *
 * Запити: з теплим кешем — 0 (меню, мінімальні ціни, картки хітів — kristal.*); холодний — мін. ціни (1), хіти (1) + картки (2).
 */
class ControllerExtensionKristalHome extends Controller {
	const KEY = 'module_kristal_home_';

	public function meta(&$route, &$args) {
		if (!\Kristal\Theme::active($this->config) || !$this->isHome() || !$this->config->get(self::KEY . 'status')) {
			return null;
		}

		$title = trim((string)$this->config->get(self::KEY . 'meta_title'));
		$description = trim((string)$this->config->get(self::KEY . 'meta_description'));

		if ($title !== '') {
			$this->document->setTitle($title);
		}

		if ($description !== '') {
			$this->document->setDescription($description);
		}

		$links = $this->document->getLinks();
		$has_canonical = false;

		foreach ($links as $link) {
			if ($link['rel'] === 'canonical') {
				$has_canonical = true;
			}
		}

		if (!$has_canonical) {
			$this->document->addLink(!empty($this->request->server['HTTPS']) ? $this->config->get('config_ssl') : $this->config->get('config_url'), 'canonical');
		}

		return null;
	}

	public function view(&$route, &$data) {
		if (!\Kristal\Theme::active($this->config)) {
			return null;
		}

		$this->load->language('extension/kristal/home');
		$this->load->language('extension/kristal/catalog');
		$this->load->model('extension/kristal/menu');
		$this->load->model('extension/kristal/catalog');
		$this->load->model('extension/kristal/media');

		// Модуль вимкнено — лише тексти теми за замовчуванням, без цифр/FAQ/SEO-тексту з налаштувань
		$enabled = (bool)$this->config->get(self::KEY . 'status');

		$setting = function ($key) use ($enabled) {
			$value = $enabled ? $this->config->get(self::KEY . $key) : '';

			return is_string($value) ? trim($value) : $value;
		};

		$data['kh_h1_text'] = $setting('h1') ?: $this->language->get('kh_h1');
		$data['kh_lead_text'] = $setting('lead') ?: $this->language->get('kh_lead');

		// Hero: фото з налаштувань (WebP 480/960) або емблема
		$hero = $setting('hero_image');
		$data['kh_hero'] = ($hero && is_file(DIR_IMAGE . $hero)) ? $this->model_extension_kristal_media->image($hero, \Kristal\Image::TILE) : null;

		// Плитки категорій: меню (кеш 003) + мінімальні ціни одним запитом (кеш 005)
		$tree = $this->model_extension_kristal_menu->getTree();
		$prices = $this->model_extension_kristal_catalog->getMinPrices(array_column($tree, 'category_id'));
		$data['kh_cats'] = array();

		foreach ($tree as $top) {
			$price = isset($prices[$top['category_id']]) ? $prices[$top['category_id']] : 0;
			$data['kh_cats'][] = array(
				'name'  => $top['name'],
				'href'  => $top['href'],
				'icon'  => $top['icon'],
				'price' => $price > 0 ? sprintf($this->language->get('kh_cat_from'), \Kristal\Rental::money($price)) : ''
			);
		}

		$data['kh_catalog_href'] = $tree ? $tree[0]['href'] : '';

		// Хіти: картки 005 з кешу (ціни, посилання, зображення) — скидається збереженням товару (kristal.*)
		$key = 'kristal.home.hits.' . (int)$this->config->get('config_store_id') . '.' . (int)$this->config->get('config_language_id');
		$hits = $this->cache->get($key);

		if (!is_array($hits)) {
			$hits = $this->load->controller('extension/kristal/catalog/cards', $this->model_extension_kristal_catalog->getHitIds(8));
			$hits = is_array($hits) ? $hits : array();
			$this->cache->set($key, $hits);
		}

		$data['kh_hits'] = $hits;

		// Цифри (до 3) і FAQ (до 6) — масиви з налаштувань; порожні рядки пропускаємо
		$data['kh_numbers'] = array();

		foreach ((array)$setting('numbers') as $row) {
			if (is_array($row) && trim((string)(isset($row['value']) ? $row['value'] : '')) !== '') {
				$data['kh_numbers'][] = array('value' => $row['value'], 'label' => isset($row['label']) ? $row['label'] : '');
			}
		}

		$data['kh_faq'] = array();

		foreach ((array)$setting('faq') as $row) {
			if (is_array($row) && trim((string)(isset($row['q']) ? $row['q'] : '')) !== '' && trim((string)(isset($row['a']) ? $row['a'] : '')) !== '') {
				$data['kh_faq'][] = array('q' => $row['q'], 'a' => $row['a']);
			}
		}

		$data['kh_numbers'] = array_slice($data['kh_numbers'], 0, 3);
		$data['kh_faq'] = array_slice($data['kh_faq'], 0, 6);

		$seo = (string)$setting('seo_text');
		$data['kh_seo'] = $seo !== '' ? html_entity_decode($seo, ENT_QUOTES, 'UTF-8') : '';

		return null;
	}

	private function isHome() {
		$route = isset($this->request->get['route']) ? (string)$this->request->get['route'] : '';

		return $route === '' || $route === 'common/home';
	}
}
