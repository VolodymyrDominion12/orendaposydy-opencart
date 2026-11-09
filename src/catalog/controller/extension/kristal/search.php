<?php
/**
 * Пошук «Крістал» (фіча 027).
 *
 * Маршрути:
 *   extension/kristal/search          → index()    сторінка результатів (ЧПУ /poshuk?q=…, noindex — тема 003)
 *   extension/kristal/search/suggest  → suggest()  JSON підказок для шапки (kristal-search.js)
 *
 * Запит q з Request ядра вже закодований htmlspecialchars — декодуємо в сирий текст, шукаємо по ньому,
 * а в шаблоні виводимо через |e (AC-10). У JSON — сирий текст, браузер вставляє його як textContent.
 */
class ControllerExtensionKristalSearch extends Controller {
	const PER_PAGE = 24;
	const SUGGEST_PRODUCTS = 6;
	const SUGGEST_CATEGORIES = 3;
	/** Ліміт підказок, що йдуть у базу: 60 за хвилину з однієї IP */
	const RATE_LIMIT = 60;
	const RATE_WINDOW = 60;

	public function index() {
		$this->load->language('extension/kristal/search');
		$this->load->language('extension/kristal/catalog');
		$this->load->model('extension/kristal/search');

		$q = $this->query();
		$page = isset($this->request->get['page']) ? max(1, (int)$this->request->get['page']) : 1;
		$data = array();

		$data['ks_q'] = $q;
		$data['ks_action'] = $this->model_extension_kristal_search->href();
		$data['ks_hidden'] = $this->hiddenFields($data['ks_action']);

		$title = $q !== '' ? sprintf($this->language->get('ks_meta_title'), $q) : $this->language->get('ks_meta_title_empty');
		$this->document->setTitle(htmlspecialchars($title, ENT_QUOTES, 'UTF-8'));

		$data['breadcrumbs'] = array(
			array('text' => $this->language->get('text_home'), 'href' => $this->homeHref()),
			array('text' => $this->language->get('ks_crumb'), 'href' => $data['ks_action'])
		);

		$found = $this->model_extension_kristal_search->find($q);
		$total = count($found['products']);

		$data['ks_searched'] = \Kristal\Search::tokens($q) ? true : false;
		$data['ks_total'] = $total;
		$data['ks_layout'] = $found['layout'];
		$data['ks_categories'] = array();

		foreach (array_slice($found['categories'], 0, 12) as $category) {
			$data['ks_categories'][] = array('name' => $category['name'], 'href' => $category['href']);
		}

		// Сторінка товарів: 24 картки 005 з готовими посиланнями (без запиту oc_seo_url на кожну)
		$slice = array_slice($found['products'], ($page - 1) * self::PER_PAGE, self::PER_PAGE);
		$data['products'] = array();

		if ($slice) {
			$cards = $this->load->controller('extension/kristal/catalog/cards', array(
				'ids'   => array_column($slice, 'product_id'),
				'hrefs' => array_column($slice, 'href', 'product_id'),
				'eager' => $page === 1 ? 2 : 0
			));
			$data['products'] = is_array($cards) ? $cards : array();
		}

		$data['pagination'] = '';

		if ($total > self::PER_PAGE) {
			$pagination = new Pagination();
			$pagination->total = $total;
			$pagination->page = $page;
			$pagination->limit = self::PER_PAGE;
			$pagination->url = $this->model_extension_kristal_search->href($q, '{page}');
			$data['pagination'] = $pagination->render();
		}

		$data['ks_found_text'] = sprintf($this->language->get('ks_found'), $total);

		// Нічого не знайдено (або порожній/короткий запит): популярні розділи + контакт (AC-7)
		$data['ks_popular'] = array();

		if (!$total) {
			if ($data['ks_searched'] && !$found['categories']) {
				$this->model_extension_kristal_search->log($q);
			}

			$data['ks_popular'] = $this->popular();
		}

		$data['header'] = $this->load->controller('common/header');
		$data['footer'] = $this->load->controller('common/footer');

		$this->response->setOutput($this->load->view('extension/kristal/search', $data));
	}

	/** JSON підказок (AC-2). Ліміт частоти — лише для запитів, яких немає в кеші. */
	public function suggest() {
		$this->load->model('extension/kristal/search');

		$q = $this->query();
		$json = array('q' => $q, 'total' => 0, 'items' => array(), 'cats' => array(), 'layout' => '', 'all' => '');

		$this->response->addHeader('Content-Type: application/json; charset=utf-8');
		$this->response->addHeader('X-Robots-Tag: noindex');
		$this->response->addHeader('Cache-Control: private, max-age=60');

		if (!\Kristal\Search::tokens($q)) {
			$this->response->setOutput($this->json($json));

			return;
		}

		if (!$this->model_extension_kristal_search->isCached($q)) {
			$ip = isset($this->request->server['REMOTE_ADDR']) ? (string)$this->request->server['REMOTE_ADDR'] : '';
			$limiter = new \Kristal\Rate_limit($this->db, (string)$this->config->get('module_kristal_core_salt'));

			if (!$limiter->hit('search', $ip, self::RATE_LIMIT, self::RATE_WINDOW)) {
				$json['limited'] = true;
				$this->response->setOutput($this->json($json));

				return;
			}
		}

		$this->load->language('extension/kristal/catalog');
		$this->load->model('extension/kristal/media');

		$found = $this->model_extension_kristal_search->find($q);

		foreach (array_slice($found['products'], 0, self::SUGGEST_PRODUCTS) as $row) {
			$img = $this->model_extension_kristal_media->image($row['image'], ModelExtensionKristalMedia::THUMB);
			$per = $row['unit'] === 'event' ? $this->language->get('kc_per_event') : sprintf($this->language->get('kc_per_day'), \Kristal\Rental::unit($row['unit']));

			$json['items'][] = array(
				'name'   => $this->text($row['name']),
				'href'   => $row['href'],
				'img'    => $img['src'],
				'srcset' => $img['srcset'],
				'price'  => $row['price'] > 0 ? \Kristal\Rental::money($row['price']) . ' ' . $this->text($per) : ''
			);
		}

		foreach (array_slice($found['categories'], 0, self::SUGGEST_CATEGORIES) as $category) {
			$json['cats'][] = array('name' => $this->text($category['name']), 'href' => $category['href']);
		}

		$json['total'] = count($found['products']);
		$json['layout'] = $found['layout'];
		$json['all'] = $this->model_extension_kristal_search->href($q);

		$this->response->setOutput($this->json($json));
	}

	/** Сирий запит з ?q= (Request ядра закодував його htmlspecialchars), обрізаний до 64 символів */
	private function query() {
		$q = isset($this->request->get['q']) && is_scalar($this->request->get['q']) ? (string)$this->request->get['q'] : '';

		return \Kristal\Search::cut(html_entity_decode($q, ENT_QUOTES, 'UTF-8'));
	}

	/** Дані з БД закодовані ядром — для JSON потрібен звичайний текст */
	private function text($value) {
		return html_entity_decode((string)$value, ENT_QUOTES, 'UTF-8');
	}

	private function json($data) {
		return json_encode($data, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES | JSON_HEX_TAG | JSON_HEX_AMP);
	}

	/** Без ЧПУ форма GET втрачає ?route= з action — передаємо прихованими полями */
	private function hiddenFields($action) {
		$fields = array();
		$query = (string)parse_url($action, PHP_URL_QUERY);

		if ($query !== '') {
			parse_str($query, $params);

			foreach ($params as $name => $value) {
				if (is_scalar($value)) {
					$fields[] = array('name' => $name, 'value' => $value);
				}
			}
		}

		return $fields;
	}

	private function homeHref() {
		return !empty($this->request->server['HTTPS']) ? $this->config->get('config_ssl') : $this->config->get('config_url');
	}

	/** Плитки верхніх розділів меню з «від N ₴» — як на головній (кеш меню 003 + мінімальні ціни 005) */
	private function popular() {
		$this->load->model('extension/kristal/menu');
		$this->load->model('extension/kristal/catalog');

		$tree = $this->model_extension_kristal_menu->getTree();
		$prices = $this->model_extension_kristal_catalog->getMinPrices(array_column($tree, 'category_id'));
		$tiles = array();

		foreach ($tree as $top) {
			$price = isset($prices[$top['category_id']]) ? $prices[$top['category_id']] : 0;
			$tiles[] = array(
				'name'  => $top['name'],
				'href'  => $top['href'],
				'icon'  => $top['icon'],
				'price' => $price > 0 ? sprintf($this->language->get('ks_from'), \Kristal\Rental::money($price)) : ''
			);
		}

		return $tiles;
	}
}
