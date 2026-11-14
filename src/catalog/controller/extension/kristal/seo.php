<?php
class ControllerExtensionKristalSeo extends Controller {
	/**
	 * canonical категорії — повний шлях. Ядро product/category.php будує canonical
	 * за останнім category_id, тому /posud/tarilky отримував canonical /tarilky.
	 * Для фільтрів і SEO-сторінок фільтрів canonical дає extension/kristal/filter.
	 */
	public function headerView(&$route, &$data) {
		if (!\Kristal\Theme::active($this->config)) {
			return null;
		}

		$route_name = isset($this->request->get['route']) ? (string)$this->request->get['route'] : 'common/home';

		if ($route_name !== 'product/category' || empty($this->request->get['path']) || isset($this->request->get['filter'])
			|| $this->registry->get('kristal_filter_page')) {
			return null;
		}

		$path = preg_replace('/[^0-9_]/', '', (string)$this->request->get['path']);
		$page = isset($this->request->get['page']) ? (int)$this->request->get['page'] : 1;
		$canonical = $this->url->link('product/category', 'path=' . $path . ($page > 1 ? '&page=' . $page : ''));

		$links = array();

		foreach (isset($data['links']) ? $data['links'] : array() as $link) {
			if (in_array($link['rel'], array('canonical', 'prev', 'next'), true)) {
				continue;
			}

			$links[] = $link;
		}

		$links[] = array('href' => $canonical, 'rel' => 'canonical');
		$data['links'] = $links;

		return null;
	}

	public function sitemap() {
		$cache_key = 'kristal.sitemap';
		$xml = $this->cache->get($cache_key);

		if (!$xml) {
			$this->load->model('extension/kristal/seo');

			$store_id = (int)$this->config->get('config_store_id');
			$language_id = (int)$this->config->get('config_language_id');

			$urls = array();

			// Головна
			$base_url = $this->request->server['HTTPS'] ? HTTPS_SERVER : HTTP_SERVER;
			$urls[] = array(
				'loc'        => rtrim($base_url, '/') . '/',
				'lastmod'    => date('Y-m-d'),
				'changefreq' => 'daily',
				'priority'   => '1.0'
			);

			// Категорії
			$categories = $this->model_extension_kristal_seo->getSitemapCategories($store_id, $language_id);
			foreach ($categories as $cat) {
				$urls[] = array(
					'loc'        => $this->url->link('product/category', 'path=' . (!empty($cat['path']) ? $cat['path'] : $cat['category_id'])),
					'lastmod'    => !empty($cat['date_modified']) ? $cat['date_modified'] : '',
					'changefreq' => 'weekly',
					'priority'   => '0.8'
				);
			}

			// SEO-сторінки фільтрів (021)
			$filter_pages = $this->model_extension_kristal_seo->getSitemapFilterPages();
			foreach ($filter_pages as $fp) {
				$cat_url = $this->url->link('product/category', 'path=' . (!empty($fp['path']) ? $fp['path'] : $fp['category_id']));
				$urls[] = array(
					'loc'        => rtrim($cat_url, '/') . '/' . ltrim($fp['keyword'], '/'),
					'lastmod'    => date('Y-m-d'),
					'changefreq' => 'weekly',
					'priority'   => '0.8'
				);
			}

			// Товари
			$products = $this->model_extension_kristal_seo->getSitemapProducts($store_id);
			foreach ($products as $p) {
				$urls[] = array(
					'loc'        => $this->url->link('product/product', 'product_id=' . $p['product_id']),
					'lastmod'    => !empty($p['date_modified']) ? $p['date_modified'] : '',
					'changefreq' => 'weekly',
					'priority'   => '0.7'
				);
			}

			// Інформаційні сторінки
			$infos = $this->model_extension_kristal_seo->getSitemapInformation($store_id);
			foreach ($infos as $info) {
				$urls[] = array(
					'loc'        => $this->url->link('information/information', 'information_id=' . $info['information_id']),
					'changefreq' => 'monthly',
					'priority'   => '0.5'
				);
			}

			$xml = \Kristal\Seo::buildSitemapXml($urls);
			$this->cache->set($cache_key, $xml);
		}

		$this->response->addHeader('Content-Type: application/xml; charset=utf-8');
		$this->response->setOutput($xml);
	}

	public function headerBefore(&$route, &$data) {
		$current_route = isset($this->request->get['route']) ? $this->request->get['route'] : 'common/home';

		// 1. Robots (noindex, follow)
		$is_noindex = \Kristal\Seo::isNoindexRoute($current_route) || $this->config->get('kristal_noindex');
		$data['k_noindex'] = $is_noindex;

		// 2. Canonical URL
		$server = isset($this->request->server['HTTPS']) && (($this->request->server['HTTPS'] == 'on') || ($this->request->server['HTTPS'] == '1')) ? HTTPS_SERVER : HTTP_SERVER;
		$req_uri = isset($this->request->server['REQUEST_URI']) ? $this->request->server['REQUEST_URI'] : '';
		$current_url = rtrim($server, '/') . $req_uri;
		$canonical = \Kristal\Seo::cleanCanonical($current_url);

		// Якщо сторінка фільтра без власної SEO-сторінки — canonical на категорію
		if (isset($this->request->get['filter']) && isset($this->request->get['path'])) {
			$canonical = $this->url->link('product/category', 'path=' . $this->request->get['path']);
		}

		$data['k_canonical'] = $canonical;


		// 3. JSON-LD LocalBusiness на головній
		$data['k_jsonld_localbusiness'] = '';
		if ($current_route === 'common/home' || $current_route === '') {
			$nap = \Kristal\Nap::get($this->registry);
			$logo = $server . 'image/' . $this->config->get('config_logo');
			$lb_data = \Kristal\Jsonld::localBusiness($nap, $server, $logo);
			$data['k_jsonld_localbusiness'] = \Kristal\Jsonld::render($lb_data);
		}

		// 4. Analytics & GTM
		if ($this->config->get('module_kristal_analytics_status')) {
			$data['k_gtm_id'] = (string)$this->config->get('module_kristal_analytics_gtm_id');
			$data['k_ga4_id'] = (string)$this->config->get('module_kristal_analytics_ga4_id');
		} else {
			$data['k_gtm_id'] = '';
			$data['k_ga4_id'] = '';
		}
	}

	public function categoryView(&$route, &$data) {
		$category_id = 0;
		if (isset($this->request->get['path'])) {
			$parts = explode('_', (string)$this->request->get['path']);
			$category_id = (int)end($parts);
		}

		if ($category_id > 0) {
			$this->load->model('extension/kristal/seo');
			$meta = $this->model_extension_kristal_seo->getMeta('category', $category_id);

			$data['k_h1'] = !empty($meta['h1']) ? $meta['h1'] : (isset($data['heading_title']) ? $data['heading_title'] : '');
			$data['k_seo_text'] = !empty($meta['seo_text']) ? html_entity_decode($meta['seo_text'], ENT_QUOTES, 'UTF-8') : '';

			// Шаблонізація title/description, якщо не задані індивідуально
			$min_price = $this->model_extension_kristal_seo->getCategoryMinPrice($category_id);
			$name = isset($data['heading_title']) ? $data['heading_title'] : '';

			$tpl_vars = array(
				'name'       => $name,
				'min_price'  => $min_price > 0 ? (string)$min_price : '10',
				'city'       => 'Львів',
				'store_name' => (string)$this->config->get('config_name')
			);

			$title_tpl = (string)$this->config->get('module_kristal_seo_category_title');
			if (!$title_tpl) {
				$title_tpl = '{name} у Львові — оренда та прокат | Крістал';
			}

			$desc_tpl = (string)$this->config->get('module_kristal_seo_category_description');
			if (!$desc_tpl) {
				$desc_tpl = 'Оренда {name} у Львові за вигідною ціною від {min_price} ₴/добу. Великий вибір посуду та обладнання для подій від «Крістал».';
			}

			$doc_title = $this->document->getTitle();
			if (!$doc_title || $doc_title === $name) {
				$this->document->setTitle(\Kristal\Seo::renderTemplate($title_tpl, $tpl_vars));
			}

			$doc_desc = $this->document->getDescription();
			if (!$doc_desc) {
				$this->document->setDescription(\Kristal\Seo::renderTemplate($desc_tpl, $tpl_vars));
			}
		}
	}

	public function productView(&$route, &$data) {
		$product_id = isset($this->request->get['product_id']) ? (int)$this->request->get['product_id'] : 0;

		if ($product_id > 0) {
			$this->load->model('extension/kristal/seo');
			$meta = $this->model_extension_kristal_seo->getMeta('product', $product_id);

			$data['k_h1'] = !empty($meta['h1']) ? $meta['h1'] : (isset($data['heading_title']) ? $data['heading_title'] : '');
			$data['k_seo_text'] = !empty($meta['seo_text']) ? html_entity_decode($meta['seo_text'], ENT_QUOTES, 'UTF-8') : '';

			// JSON-LD Product
			$server = isset($this->request->server['HTTPS']) && (($this->request->server['HTTPS'] == 'on') || ($this->request->server['HTTPS'] == '1')) ? HTTPS_SERVER : HTTP_SERVER;
			$price = isset($data['price']) ? preg_replace('/[^\d.]/', '', str_replace(',', '.', $data['price'])) : '0';

			$prod_json = array(
				'@context'    => 'https://schema.org',
				'@type'       => 'Product',
				'name'        => isset($data['heading_title']) ? $data['heading_title'] : '',
				'image'       => isset($data['thumb']) ? $data['thumb'] : '',
				'description' => isset($data['description']) ? trim(strip_tags(html_entity_decode($data['description'], ENT_QUOTES, 'UTF-8'))) : '',
				'offers'      => array(
					'@type'         => 'Offer',
					'price'         => $price,
					'priceCurrency' => 'UAH',
					'availability'  => 'https://schema.org/InStock',
					'url'           => $this->url->link('product/product', 'product_id=' . $product_id)
				)
			);

			$data['k_jsonld_product'] = \Kristal\Jsonld::render(\Kristal\Jsonld::clean($prod_json));
		}
	}

	public function flush(&$route, &$data) {
		\Kristal\Cache_key::flush($this->cache);
	}
}
