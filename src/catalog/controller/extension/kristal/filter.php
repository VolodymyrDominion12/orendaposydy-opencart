<?php
/**
 * Фільтри категорії і SEO-сторінки фільтрів (фіча 021). Ядро не змінюється — лише події (міграція 0014_kristal_filter):
 *
 *   controller/product/category/before            → before()    розбір `filter` / форми (fv[], pmin, pmax), 301/302 на канонічну адресу,
 *                                                                JSON для шторки (kf=json), стан у registry `kristal_filter`
 *   controller/error/not_found/before             → page()      /категорія/keyword SEO-сторінки → маршрут product/category
 *   model/catalog/product/getProducts/before      → products()  сторінка відфільтрованих товарів (getProduct() ядра — як робить ядро)
 *   model/catalog/product/getTotalProducts/before → total()     кількість
 *   view/product/category/before                  → view()      групи, лічильники, плашки, ціна, SEO-сторінка, посилання сторінок 2+
 *   view/common/header/before                     → header()    title/description SEO-сторінки, canonical, noindex
 *
 * Параметр адреси — `filter` ядра (ядро протягує його в сортування, пагінацію, «Показати ще»): kolir-bilyi_material-portseliana_tsina-10-40.
 * Без активного фільтра події нічого не роблять, крім даних для колонки (індекс категорії з кешу — 0 запитів на повтор).
 */
class ControllerExtensionKristalFilter extends Controller {
	const STATE = 'kristal_filter';
	const PAGE = 'kristal_filter_page';

	/** SEO-сторінка: startup/seo_url не знайшов останній сегмент, але path з попередніх уже є */
	public function page(&$route, &$data) {
		if (!\Kristal\Theme::active($this->config) || empty($this->request->get['_route_']) || empty($this->request->get['path'])
			|| !is_string($this->request->get['_route_']) || !is_string($this->request->get['path'])) {
			return null;
		}

		$parts = array_values(array_filter(explode('/', $this->request->get['_route_']), 'strlen'));
		$path = explode('_', $this->request->get['path']);
		$keyword = end($parts);

		if (count($parts) !== count($path) + 1 || !preg_match('/^[a-z0-9-]{1,64}$/', $keyword)) {
			return null;
		}

		$this->load->model('extension/kristal/filter');
		$page = $this->model_extension_kristal_filter->getPageByKeyword((int)end($path), $keyword);

		if (!$page) {
			return null;
		}

		$this->registry->set(self::PAGE, $page);
		$route = 'product/category';
		$this->request->get['route'] = 'product/category';

		// Подія controller/product/category/before уже не спрацює (роутер її викликав для error/not_found)
		return $this->before($route, $data);
	}

	public function before(&$route, &$data) {
		if (!\Kristal\Theme::active($this->config) || empty($this->request->get['path']) || !is_string($this->request->get['path'])) {
			return null;
		}

		$path = implode('_', array_map('intval', explode('_', $this->request->get['path'])));
		$category_id = (int)substr(strrchr('_' . $path, '_'), 1);

		if (!$category_id) {
			return null;
		}

		$this->load->model('extension/kristal/filter');
		$index = $this->model_extension_kristal_filter->getIndex($category_id);
		$values = $index['values'];
		$get = $this->request->get;
		$seo_page = $this->registry->get(self::PAGE);
		$form = isset($get['fv']) || isset($get['pmin']) || isset($get['pmax']);

		if ($seo_page) {
			$selected = \Kristal\Filter::fromIds(explode(',', $seo_page['key']), $values);
			$price = null;
		} elseif ($form) {
			$fv = isset($get['fv']) && is_array($get['fv']) ? array_filter(array_slice($get['fv'], 0, 50), 'is_string') : array();
			$parsed = \Kristal\Filter::parse(implode(\Kristal\Filter::SEP, $fv));
			$selected = \Kristal\Filter::resolve($parsed['slugs'], $index['slugs'], $values);
			$price = \Kristal\Filter::price(isset($get['pmin']) ? $get['pmin'] : '', isset($get['pmax']) ? $get['pmax'] : '');
		} else {
			$parsed = \Kristal\Filter::parse(isset($get['filter']) ? $get['filter'] : '');
			$selected = \Kristal\Filter::resolve($parsed['slugs'], $index['slugs'], $values);
			$price = $parsed['price'];
		}

		$canon = \Kristal\Filter::canonical($selected, $price, $values);
		$base = $this->baseUrl($path);
		$target_page = $price ? null : $this->findPage($index, $selected);
		$keep = $this->keepParams(!$form);

		$state = array(
			'category_id' => $category_id,
			'path'        => $path,
			'base'        => $base,
			'index'       => $index,
			'selected'    => $selected,
			'price'       => $price,
			'canon'       => $canon,
			'page'        => $seo_page,
			'active'      => $canon !== '',
			'ids'         => $canon !== '' ? \Kristal\Filter::select($index['products'], $selected, $price) : array()
		);

		// Шторка: «Показати N товарів» і адреса, куди перейти
		if (isset($get['kf']) && $get['kf'] === 'json') {
			$total = $canon !== '' ? count($state['ids']) : count($index['products']);
			$this->load->language('extension/kristal/catalog');

			$this->response->addHeader('Content-Type: application/json');
			$this->response->addHeader('Cache-Control: no-store');
			$this->response->setOutput(json_encode(array(
				'total' => $total,
				'text'  => $this->showText($total),
				'url'   => html_entity_decode($this->stateUrl($base, $canon, $target_page, $keep), ENT_QUOTES, 'UTF-8')
			)));

			return true;
		}

		if ($form) {
			$this->response->redirect(html_entity_decode($this->stateUrl($base, $canon, $target_page, $keep), ENT_QUOTES, 'UTF-8'), 302);
		}

		if (!$seo_page && isset($get['filter'])) {
			$raw = is_string($get['filter']) ? $get['filter'] : '';

			if ($target_page || $raw !== $canon) {
				$this->response->redirect(html_entity_decode($this->stateUrl($base, $canon, $target_page, $keep), ENT_QUOTES, 'UTF-8'), 301);
			}
		}

		if ($canon !== '') {
			$this->request->get['filter'] = $canon;
		} else {
			unset($this->request->get['filter']);
		}

		$this->registry->set(self::STATE, $state);

		return null;
	}

	public function products(&$route, &$args) {
		$state = $this->activeFor($args);

		if (!$state) {
			return null;
		}

		$query = $args[0];
		$start = isset($query['start']) ? max(0, (int)$query['start']) : 0;
		$limit = isset($query['limit']) && (int)$query['limit'] > 0 ? (int)$query['limit'] : 20;

		$ids = \Kristal\Filter::sort($state['index']['products'], $state['ids'], isset($query['sort']) ? $query['sort'] : '', isset($query['order']) ? $query['order'] : 'ASC');
		$ids = array_slice($ids, $start, $limit);
		$result = array();

		if ($ids) {
			$this->load->model('catalog/product');

			foreach ($ids as $id) {
				$product = $this->model_catalog_product->getProduct($id);

				if ($product) {
					$result[$id] = $product;
				}
			}
		}

		if (!$result) {
			// Подія бере лише непорожній результат — інакше ядро повертає порожньо саме
			$args[0]['filter_filter'] = '-1';

			return null;
		}

		return $result;
	}

	public function total(&$route, &$args) {
		$state = $this->activeFor($args);

		if (!$state) {
			return null;
		}

		if ($state['ids']) {
			return count($state['ids']);
		}

		$args[0]['filter_filter'] = '-1';

		return null;
	}

	public function view(&$route, &$data) {
		$state = $this->registry->get(self::STATE);

		if (!$state || empty($data['heading_title'])) {
			return null;
		}

		// Тексти kf_* — у мовному файлі каталогу (005), його вже завантажила подія extension/kristal/catalog
		if ($this->language->get('kf_title') === 'kf_title') {
			$this->load->language('extension/kristal/catalog');
		}

		$index = $state['index'];
		$values = $index['values'];
		$selected = $state['selected'];
		$price = $state['price'];
		$base = $state['base'];
		$keep = $this->keepParams(false);
		$used = \Kristal\Filter::usedValues($index['products']);
		$visible = \Kristal\Filter::visibleGroups($index['products'], $values, $selected);
		$counts = \Kristal\Filter::counts($index['products'], $values, $selected, $price);

		$groups = array();
		$chips = array();

		foreach ($values as $fid => $value) {
			$gid = $value['g'];

			if (!isset($visible[$gid]) || (!isset($used[$fid]) && !isset($selected[$gid][$fid]))) {
				continue;
			}

			$checked = isset($selected[$gid][$fid]);
			$toggled = \Kristal\Filter::toggle($selected, $fid, $values);
			$page = $price ? null : $this->findPage($index, $toggled);
			$href = $this->stateUrl($base, \Kristal\Filter::canonical($toggled, $price, $values), $page, $keep);

			if (!isset($groups[$gid])) {
				$groups[$gid] = array('id' => $gid, 'name' => htmlspecialchars($value['group'], ENT_QUOTES, 'UTF-8'), 'open' => false, 'values' => array());
			}

			$groups[$gid]['values'][] = array(
				'slug'     => $value['slug'],
				'name'     => htmlspecialchars($value['name'], ENT_QUOTES, 'UTF-8'),
				'count'    => $counts[$fid],
				'checked'  => $checked,
				'disabled' => !$checked && $counts[$fid] === 0,
				'href'     => $href,
				'nofollow' => $page === null
			);

			if ($checked) {
				$groups[$gid]['open'] = true;
				$chips[] = array('name' => htmlspecialchars($value['name'], ENT_QUOTES, 'UTF-8'), 'href' => $href);
			}
		}

		// Перші дві групи розгорнуті; решта — якщо є вибране
		$n = 0;

		foreach ($groups as $gid => $group) {
			if ($n++ < 2) {
				$groups[$gid]['open'] = true;
			}
		}

		$bounds = \Kristal\Filter::bounds($index['products'], $selected);

		if ($price) {
			$chips[] = array(
				'name' => sprintf($this->language->get('kf_chip_price'), $price[0] > 0 ? $price[0] : $bounds[0], $price[1] !== null ? $price[1] : $bounds[1]),
				'href' => $this->stateUrl($base, \Kristal\Filter::canonical($selected, null, $values), $this->findPage($index, $selected), $keep)
			);
		}

		$has_filters = $groups || $bounds[1] > $bounds[0] || $price;

		$data['kf'] = $has_filters ? array(
			'groups'  => array_values($groups),
			'chips'   => $chips,
			'count'   => \Kristal\Filter::count($selected) + ($price ? 1 : 0),
			'active'  => $state['active'],
			'action'  => $base,
			'reset'   => $this->stateUrl($base, '', null, $keep),
			'hidden'  => $keep,
			'pmin'    => $price && $price[0] > 0 ? $price[0] : '',
			'pmax'    => $price && $price[1] !== null ? $price[1] : '',
			'bmin'    => $bounds[0],
			'bmax'    => $bounds[1],
			'price'   => $bounds[1] > 0 || $price,
			'total'   => isset($data['products']) && $state['active'] ? count($state['ids']) : count($index['products']),
			'js'      => $this->asset('js/kristal-filter.js')
		) : array();

		if ($has_filters) {
			$data['kf']['show'] = $this->showText($data['kf']['total']);
		}

		$data['kf_empty'] = $state['active'] && empty($data['products']);

		foreach (array('kf_title', 'kf_open', 'kf_close', 'kf_reset', 'kf_reset_all', 'kf_apply', 'kf_price', 'kf_from', 'kf_to', 'kf_selected',
			'kf_remove', 'kf_empty_title', 'kf_empty_text', 'kf_empty_reset', 'kf_empty_call') as $key) {
			$data[$key] = $this->language->get($key);
		}

		// Ядро протягує filter у посилання товарів і підкатегорій — там він зайвий (дублі адрес товарів)
		if (!empty($data['products'])) {
			foreach ($data['products'] as $i => $product) {
				$data['products'][$i]['href'] = $this->stripFilter($product['href']);
			}
		}

		foreach (array('categories', 'kc_chips') as $list) {
			if (!empty($data[$list])) {
				foreach ($data[$list] as $i => $item) {
					$data[$list][$i]['href'] = $this->stripFilter($item['href']);
				}
			}
		}

		$seo_page = $state['page'];

		if ($seo_page) {
			$url = $this->pageUrl($base, $seo_page);

			$data['heading_title'] = $seo_page['h1'] !== '' ? $seo_page['h1'] : $data['heading_title'];
			$data['description'] = html_entity_decode($seo_page['text'], ENT_QUOTES, 'UTF-8');
			$data['breadcrumbs'][] = array('text' => $data['heading_title'], 'href' => $url);

			// Посилання ядра на сторінки 2+ і сортування — base?filter=… → адреса SEO-сторінки
			$data['pagination'] = isset($data['pagination']) ? $this->seoize($data['pagination'], $base, $state['canon'], $url) : '';

			foreach (array('sorts', 'kc_sorts', 'limits') as $list) {
				if (!empty($data[$list])) {
					foreach ($data[$list] as $i => $item) {
						$data[$list][$i]['href'] = $this->seoize($item['href'], $base, $state['canon'], $url);
					}
				}
			}

			$crumbs = array();

			foreach ($data['breadcrumbs'] as $i => $crumb) {
				$crumbs[] = array('name' => $crumb['text'], 'url' => $i === count($data['breadcrumbs']) - 1 ? '' : $crumb['href']);
			}

			$data['kf_jsonld'] = \Kristal\Jsonld::render(\Kristal\Jsonld::breadcrumbs($crumbs));
		} else {
			$data['kf_jsonld'] = '';
		}

		return null;
	}

	/** Шапка: title/description SEO-сторінки; canonical; noindex для звичайних комбінацій (тема читає прапорець) */
	public function header(&$route, &$data) {
		$state = $this->registry->get(self::STATE);

		if (!$state || (!$state['active'] && !$state['page'])) {
			return null;
		}

		$links = array();

		foreach (isset($data['links']) ? $data['links'] : array() as $key => $link) {
			if (!in_array($link['rel'], array('canonical', 'prev', 'next'), true)) {
				$links[$key] = $link;
			}
		}

		if ($state['page']) {
			$page = $state['page'];
			$url = $this->pageUrl($state['base'], $page);
			$n = isset($this->request->get['page']) ? (int)$this->request->get['page'] : 1;

			if ($page['title'] !== '') {
				$data['title'] = $page['title'];
			} elseif ($page['h1'] !== '') {
				$data['title'] = $page['h1'];
			}

			if ($page['description'] !== '') {
				$data['description'] = $page['description'];
			}

			$canonical = $n > 1 ? $url . '?page=' . $n : $url;
		} else {
			$canonical = $state['base'];
			$this->config->set('kristal_noindex', true);
		}

		$links[$canonical] = array('href' => $canonical, 'rel' => 'canonical');
		$data['links'] = $links;

		return null;
	}

	// ------------------------------------------------------------------------------------------------

	/** Адреса категорії без параметрів: url->link() — запит oc_seo_url на кожен рівень шляху, тому з кешем */
	private function baseUrl($path) {
		$https = !empty($this->request->server['HTTPS']) ? 1 : 0;
		$key = 'kristal.filter.url.' . (int)$this->config->get('config_store_id') . '.' . (int)$this->config->get('config_language_id') . '.' . $https . '.' . md5($path);
		$url = $this->cache->get($key);

		if (!is_string($url) || $url === '') {
			$url = $this->url->link('product/category', 'path=' . $path);
			$this->cache->set($key, $url);
		}

		return $url;
	}

	/** Стан, якщо виклик моделі — саме для відфільтрованої категорії поточної сторінки */
	private function activeFor($args) {
		$state = $this->registry->get(self::STATE);

		if (!$state || !$state['active'] || !isset($args[0]) || !is_array($args[0])) {
			return null;
		}

		if (!isset($args[0]['filter_category_id']) || (int)$args[0]['filter_category_id'] !== $state['category_id'] || !empty($args[0]['filter_sub_category'])
			|| !empty($args[0]['filter_name']) || !empty($args[0]['filter_tag'])) {
			return null;
		}

		return $state;
	}

	/** SEO-сторінка, комбінація якої точно дорівнює вибору (1–2 значення) */
	private function findPage($index, $selected) {
		$count = \Kristal\Filter::count($selected);

		if ($count < 1 || $count > 2 || !$index['pages']) {
			return null;
		}

		$key = \Kristal\Filter::key($selected);

		foreach ($index['pages'] as $page) {
			if ($page['key'] === $key) {
				return $page;
			}
		}

		return null;
	}

	private function pageUrl($base, $page) {
		return rtrim($base, '/') . '/' . $page['keyword'];
	}

	/** Параметри, які зберігаються при зміні фільтра: сортування, ліміт (+ сторінка — лише при канонізації адреси) */
	private function keepParams($with_page) {
		$keep = array();
		$names = $with_page ? array('sort', 'order', 'limit', 'page') : array('sort', 'order', 'limit');

		foreach ($names as $name) {
			if (isset($this->request->get[$name]) && is_scalar($this->request->get[$name]) && preg_match('/^[a-zA-Z0-9._]{1,32}$/', (string)$this->request->get[$name])) {
				if ($name === 'page' && (int)$this->request->get[$name] <= 1) {
					continue;
				}

				$keep[$name] = (string)$this->request->get[$name];
			}
		}

		return $keep;
	}

	/** Адреса стану (з &amp; для HTML): SEO-сторінка або база?filter=…; без url->link() (запит oc_seo_url) на кожне посилання */
	private function stateUrl($base, $canon, $page, $keep) {
		$params = array();

		if ($page) {
			$url = $this->pageUrl($base, $page);
		} else {
			$url = $base;

			if ($canon !== '') {
				$params[] = 'filter=' . rawurlencode($canon);
			}
		}

		foreach ($keep as $name => $value) {
			$params[] = $name . '=' . rawurlencode($value);
		}

		if (!$params) {
			return $url;
		}

		return $url . (strpos($url, '?') === false ? '?' : '&amp;') . implode('&amp;', $params);
	}

	private function stripFilter($href) {
		$href = preg_replace('/(\?|&amp;|&)filter=[a-z0-9_-]*(&amp;|&)?/', '$1', (string)$href);

		return preg_replace('/(\?|&amp;|&)$/', '', $href);
	}

	/** base?filter=CANON… → адреса SEO-сторінки (пагінація, сортування) */
	private function seoize($html, $base, $canon, $url) {
		$param = 'filter=' . rawurlencode($canon);

		return preg_replace_callback('#' . preg_quote($base, '#') . '\?([^"\'\s<>]*)#', function ($m) use ($param, $url) {
			$parts = preg_split('#&amp;|&#', $m[1]);
			$keep = array_values(array_filter($parts, function ($part) use ($param) {
				return $part !== $param && $part !== '';
			}));

			if (count($keep) === count(array_filter($parts, 'strlen'))) {
				return $m[0];
			}

			return $url . ($keep ? '?' . implode('&amp;', $keep) : '');
		}, (string)$html);
	}

	private function showText($total) {
		return sprintf($this->language->get('kf_show'), $total, $this->plural($total));
	}

	private function plural($n) {
		$n = abs((int)$n) % 100;
		$n1 = $n % 10;

		if ($n > 10 && $n < 20) {
			return $this->language->get('kf_items_5');
		}

		if ($n1 > 1 && $n1 < 5) {
			return $this->language->get('kf_items_2');
		}

		if ($n1 === 1) {
			return $this->language->get('kf_items_1');
		}

		return $this->language->get('kf_items_5');
	}

	private function asset($path) {
		$file = DIR_TEMPLATE . 'kristal/' . $path;

		return 'catalog/view/theme/kristal/' . $path . (is_file($file) ? '?v=' . filemtime($file) : '');
	}
}
