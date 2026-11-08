<?php
/**
 * Каталог «Крістал» (фіча 005): дані оренди для шаблонів категорії й товару теми kristal.
 *
 * Події (міграція 0006_kristal_product_rental):
 *   view/product/category/before → category()   картки (ціна/добу, мінімум, знижка, «Хіт»), «від N ₴», чипи, сортування
 *   view/product/product/before  → product()    те саме + пороги, застава, биття, галерея, «З цим беруть»
 * Маршрут:
 *   extension/kristal/catalog/count             JSON {count} — позицій у кошику (лічильники після «До події»)
 *
 * Запити: 2 на сторінку (оренда+зображення+опис, знижки) пакетом IN (...) + 1 для фото товару; «від N ₴» — з кешу.
 * Зображення — WebP з srcset через model extension/kristal/media (фіча 020), без запитів.
 */
class ControllerExtensionKristalCatalog extends Controller {

	public function category(&$route, &$data) {
		if (!\Kristal\Theme::active($this->config) || empty($data['heading_title'])) {
			return null;
		}

		$this->load->language('extension/kristal/catalog');
		$this->load->model('extension/kristal/catalog');
		$this->load->model('extension/kristal/media');

		$products = isset($data['products']) ? $data['products'] : array();
		$ids = array_column($products, 'product_id');
		$rows = $this->model_extension_kristal_catalog->getProducts($ids);
		$discounts = $this->model_extension_kristal_catalog->getDiscounts($ids);

		foreach ($products as $i => $product) {
			$data['products'][$i]['k'] = $this->card($product, $rows, $discounts, $i < 2);
		}

		$path = isset($this->request->get['path']) ? explode('_', (string)$this->request->get['path']) : array();
		$category_id = (int)end($path);

		$min = $category_id ? $this->model_extension_kristal_catalog->getMinPrice($category_id) : 0;
		$data['kc_min_price'] = $min > 0 ? sprintf($this->language->get('kc_from'), \Kristal\Rental::money($min)) : '';

		$data['kc_chips'] = $this->chips($category_id, isset($data['categories']) ? $data['categories'] : array());
		$data['kc_sorts'] = $this->sorts(isset($data['sorts']) ? $data['sorts'] : array(), $data);

		return null;
	}

	public function product(&$route, &$data) {
		if (!\Kristal\Theme::active($this->config) || empty($data['product_id'])) {
			return null;
		}

		$this->load->language('extension/kristal/catalog');
		$this->load->model('extension/kristal/catalog');
		$this->load->model('extension/kristal/media');

		$product_id = (int)$data['product_id'];
		$related = isset($data['products']) ? $data['products'] : array();
		$ids = array_merge(array($product_id), array_column($related, 'product_id'));

		$rows = $this->model_extension_kristal_catalog->getProducts($ids);
		$discounts = $this->model_extension_kristal_catalog->getDiscounts($ids);

		foreach ($related as $i => $product) {
			$data['products'][$i]['k'] = $this->card($product, $rows, $discounts, false);
		}

		if (!isset($rows[$product_id])) {
			return null;
		}

		$row = $rows[$product_id];
		$rental = \Kristal\Rental::normalize($row['unit'] === null ? null : $row);
		$price = (float)$row['price'];
		$minimum = max(1, (int)$row['minimum']);
		$product_discounts = isset($discounts[$product_id]) ? $discounts[$product_id] : array();
		$unit = \Kristal\Rental::unit($rental['unit']);

		$k = $this->card(array('product_id' => $product_id, 'name' => $data['heading_title'], 'href' => ''), $rows, $discounts, true);

		$k['sku'] = $row['sku'];
		$k['tiers'] = array();

		foreach (\Kristal\Rental::tierRows($minimum, $price, $product_discounts) as $tier) {
			$k['tiers'][] = array(
				'from'  => $tier['from'],
				'label' => $tier['to'] ? sprintf($this->language->get('kc_tier_range'), $tier['from'], $tier['to'], $unit) : sprintf($this->language->get('kc_tier_from'), $tier['from'], $unit),
				'price' => \Kristal\Rental::money($tier['price'])
			);
		}

		// Для JS: пороги [[від, ціна]] — та сама логіка, що в Kristal\Rental::unitPrice() і кошику ядра
		$js_tiers = array();

		foreach (\Kristal\Rental::tierRows($minimum, $price, $product_discounts) as $tier) {
			$js_tiers[] = array($tier['from'], $tier['price']);
		}

		$k['tiers_json'] = htmlspecialchars(json_encode($js_tiers), ENT_QUOTES, 'UTF-8');
		$k['deposit'] = $rental['deposit'] > 0 ? \Kristal\Rental::money($rental['deposit']) : '';
		$k['breakage'] = $rental['breakage_price'] > 0 ? \Kristal\Rental::money($rental['breakage_price']) : '';
		$k['washing'] = $rental['washing_included'];
		$k['sum'] = $this->sumText($minimum, $price, $product_discounts, $rental['unit']);
		$k['is_event'] = $rental['unit'] === 'event';

		// Галерея: головне фото + додаткові, розміри теми (квадрат)
		$k['images'] = array();
		$files = array_merge(array($row['image']), $this->model_extension_kristal_catalog->getImages($product_id));

		$files = array_values(array_unique(array_filter($files)));

		if (!$files) {
			$files = array('');
		}

		foreach ($files as $file) {
			$k['images'][] = array(
				'main'  => $this->model_extension_kristal_media->image($file, ModelExtensionKristalMedia::MAIN),
				'thumb' => $this->model_extension_kristal_media->image($file, ModelExtensionKristalMedia::THUMB)
			);
		}

		$data['kc'] = $k;

		// «Умови оренди»: сторінка з налаштування «Умови оформлення» (config_checkout_id); до 012 може бути будь-яка
		$terms_id = (int)$this->config->get('config_checkout_id');
		$data['kc_terms_href'] = $terms_id ? $this->url->link('information/information', 'information_id=' . $terms_id) : '';

		return null;
	}

	/**
	 * Картки товарів для інших сторінок (головна 004, комплекти 007): $this->load->controller('extension/kristal/catalog/cards', $ids).
	 * Той самий вигляд, що в категорії: [['product_id', 'name', 'href', 'k' => [...]], ...] у порядку $product_ids. 2 запити пакетом.
	 */
	public function cards($product_ids = array()) {
		$this->load->language('extension/kristal/catalog');
		$this->load->model('extension/kristal/catalog');
		$this->load->model('extension/kristal/media');

		$ids = array_values(array_filter(array_map('intval', (array)$product_ids)));
		$rows = $this->model_extension_kristal_catalog->getProducts($ids);
		$discounts = $this->model_extension_kristal_catalog->getDiscounts($ids);
		$cards = array();

		foreach ($ids as $id) {
			if (!isset($rows[$id])) {
				continue;
			}

			$product = array('product_id' => $id, 'name' => $rows[$id]['name'], 'href' => $this->url->link('product/product', 'product_id=' . $id));
			$product['k'] = $this->card($product, $rows, $discounts, false);
			$cards[] = $product;
		}

		return $cards;
	}

	/** JSON: кількість позицій у кошику для лічильників теми */
	public function count() {
		$query = $this->db->query("SELECT COUNT(*) AS total FROM `" . DB_PREFIX . "cart`
			WHERE api_id = '" . (isset($this->session->data['api_id']) ? (int)$this->session->data['api_id'] : 0) . "'
			AND customer_id = '" . (int)$this->customer->getId() . "'
			AND session_id = '" . $this->db->escape($this->session->getId()) . "'");

		$this->response->addHeader('Content-Type: application/json');
		$this->response->addHeader('Cache-Control: no-store');
		$this->response->setOutput(json_encode(array('count' => (int)$query->row['total'])));
	}

	/** Дані картки для списку/«З цим беруть» */
	private function card($product, $rows, $discounts, $eager) {
		$id = (int)$product['product_id'];
		$row = isset($rows[$id]) ? $rows[$id] : null;

		$rental = \Kristal\Rental::normalize($row && $row['unit'] !== null ? $row : null);
		$price = $row ? (float)$row['price'] : 0.0;
		$minimum = $row ? max(1, (int)$row['minimum']) : 1;
		$product_discounts = isset($discounts[$id]) ? $discounts[$id] : array();
		$unit = \Kristal\Rental::unit($rental['unit']);
		$best = \Kristal\Rental::bestTier($minimum, $price, $product_discounts);

		$excerpt = $row ? trim(strip_tags(html_entity_decode((string)$row['description_excerpt'], ENT_QUOTES, 'UTF-8'))) : '';

		if (utf8_strlen($excerpt) > 90) {
			$excerpt = utf8_substr($excerpt, 0, 88) . '…';
		}

		return array(
			'price'     => $price > 0 ? \Kristal\Rental::money($price) : '',
			'price_raw' => $price,
			'per'       => $rental['unit'] === 'event' ? $this->language->get('kc_per_event') : sprintf($this->language->get('kc_per_day'), $unit),
			'unit'      => $unit,
			'minimum'   => $minimum,
			'min_text'  => $minimum > 1 ? sprintf($this->language->get('kc_min'), $minimum, $unit) : '',
			'min_hint'  => sprintf($this->language->get('kc_min_hint'), $minimum, $unit),
			'best'      => $best ? sprintf($this->language->get('kc_best'), $best['from'], $unit, \Kristal\Rental::money($best['price'])) : '',
			'is_hit'    => $rental['is_hit'],
			'excerpt'   => htmlspecialchars($excerpt, ENT_QUOTES, 'UTF-8'),
			'img'       => $this->model_extension_kristal_media->image($row ? $row['image'] : '', ModelExtensionKristalMedia::CARD),
			'eager'     => $eager
		);
	}

	private function sumText($quantity, $price, $discounts, $unit_code) {
		$unit_price = \Kristal\Rental::unitPrice($quantity, $price, $discounts);

		if ($unit_code === 'event') {
			return sprintf($this->language->get('kc_sum_event'), $quantity, \Kristal\Rental::money($unit_price), \Kristal\Rental::money($quantity * $unit_price));
		}

		return sprintf($this->language->get('kc_sum'), $quantity, \Kristal\Rental::unit($unit_code), \Kristal\Rental::money($unit_price), \Kristal\Rental::money($quantity * $unit_price));
	}

	/** Чипи: діти поточної категорії, а якщо їх немає — сусіди (з кешованого меню теми, 0 запитів) */
	private function chips($category_id, $children) {
		$chips = array();

		if ($children) {
			foreach ($children as $child) {
				$chips[] = array('name' => $child['name'], 'href' => $child['href'], 'current' => false);
			}

			return $chips;
		}

		$this->load->model('extension/kristal/menu');

		foreach ($this->model_extension_kristal_menu->getTree() as $top) {
			foreach ($top['children'] as $child) {
				if ((int)$child['category_id'] === $category_id) {
					$chips[] = array('name' => $this->language->get('kc_all'), 'href' => $top['href'], 'current' => false);

					foreach ($top['children'] as $sibling) {
						$chips[] = array('name' => $sibling['name'], 'href' => $sibling['href'], 'current' => (int)$sibling['category_id'] === $category_id);
					}

					return $chips;
				}
			}
		}

		return $chips;
	}

	/** 4 варіанти сортування з посилань ядра */
	private function sorts($core_sorts, $data) {
		$labels = array(
			'p.sort_order-ASC' => 'kc_sort_default',
			'p.price-ASC'      => 'kc_sort_cheap',
			'p.price-DESC'     => 'kc_sort_dear',
			'pd.name-ASC'      => 'kc_sort_name'
		);

		$current = (isset($data['sort']) ? $data['sort'] : 'p.sort_order') . '-' . (isset($data['order']) ? $data['order'] : 'ASC');
		$sorts = array();

		foreach ($core_sorts as $sort) {
			if (isset($labels[$sort['value']])) {
				$sorts[] = array('text' => $this->language->get($labels[$sort['value']]), 'href' => $sort['href'], 'selected' => $sort['value'] === $current);
			}
		}

		return $sorts;
	}
}
