<?php
/**
 * Контролер «Ми можемо для Вас приготувати» (фіча 028 kristal_catering).
 * Оглядова сторінка (/gotuemo) та 4 міні-лендінги:
 *   /furshetni-stravy, /banketni-stravy, /kava-breik, /vesilne-meniu.
 * PHP 7.3+.
 */
class ControllerExtensionKristalCatering extends Controller {

	public function index() {
		$this->load->language('extension/kristal/catering');
		$this->load->model('extension/kristal/catering');

		$this->document->setTitle($this->language->get('text_hub_meta_title'));
		$this->document->setDescription($this->language->get('text_hub_meta_desc'));

		$canonical = $this->url->link('extension/kristal/catering');
		$this->document->addLink($canonical, 'canonical');
		$data['canonical'] = $canonical;

		$data['breadcrumbs'] = array(
			array(
				'text' => $this->language->get('text_home'),
				'href' => $this->url->link('common/home')
			),
			array(
				'text' => $this->language->get('text_catering_hub'),
				'href' => $canonical
			)
		);

		$data['pages'] = $this->model_extension_kristal_catering->getMenuPages();
		$data['min_event_date'] = date('Y-m-d');
		$data['jsonld'] = $this->buildBreadcrumbJsonld($data['breadcrumbs']);

		$data['header'] = $this->load->controller('common/header');
		$data['footer'] = $this->load->controller('common/footer');

		$this->response->setOutput($this->load->view('extension/kristal/catering_hub', $data));
	}

	public function buffet() {
		return $this->renderPage('buffet');
	}

	public function banquet() {
		return $this->renderPage('banquet');
	}

	public function coffeebreak() {
		return $this->renderPage('coffeebreak');
	}

	public function wedding() {
		return $this->renderPage('wedding');
	}

	private function renderPage($code) {
		$this->load->language('extension/kristal/catering');
		$this->load->model('extension/kristal/catering');
		$this->load->model('extension/kristal/media');

		$page = $this->model_extension_kristal_catering->getPageByCode($code);

		if (!$page) {
			return $this->index();
		}

		$title = $page['meta_title'] !== '' ? $page['meta_title'] : $page['title'];
		$desc = $page['meta_description'] !== '' ? $page['meta_description'] : $page['short_desc'];

		$this->document->setTitle($title);
		$this->document->setDescription($desc);
		$this->document->addLink($page['href'], 'canonical');

		$data['canonical'] = $page['href'];
		$data['hub_href'] = $this->url->link('extension/kristal/catering');

		$data['breadcrumbs'] = array(
			array(
				'text' => $this->language->get('text_home'),
				'href' => $this->url->link('common/home')
			),
			array(
				'text' => $this->language->get('text_catering_hub'),
				'href' => $data['hub_href']
			),
			array(
				'text' => $page['title'],
				'href' => $page['href']
			)
		);

		$data['page'] = $page;
		$data['all_pages'] = $this->model_extension_kristal_catering->getMenuPages();
		$data['hero_media'] = ($page['hero_image'] !== '' && is_file(DIR_IMAGE . $page['hero_image']))
			? $this->model_extension_kristal_media->image($page['hero_image'], \Kristal\Image::HERO)
			: null;

		$data['addons'] = $this->getAddonsForCode($code);
		$data['min_event_date'] = date('Y-m-d');

		// JSON-LD: BreadcrumbList + FAQPage
		$schemas = array();
		$schemas[] = $this->buildBreadcrumbJsonld($data['breadcrumbs']);

		if (!empty($page['faq'])) {
			$faq_items = array();
			foreach ($page['faq'] as $f) {
				if (!empty($f['q']) && !empty($f['a'])) {
					$faq_items[] = array(
						'@type'          => 'Question',
						'name'           => $f['q'],
						'acceptedAnswer' => array(
							'@type' => 'Answer',
							'text'  => $f['a']
						)
					);
				}
			}
			if ($faq_items) {
				$schemas[] = \Kristal\Jsonld::render(array(
					'@context'   => 'https://schema.org',
					'@type'      => 'FAQPage',
					'mainEntity' => $faq_items
				));
			}
		}

		$data['jsonld'] = implode("\n", $schemas);

		$data['header'] = $this->load->controller('common/header');
		$data['footer'] = $this->load->controller('common/footer');

		$this->response->setOutput($this->load->view('extension/kristal/catering', $data));
	}

	private function buildBreadcrumbJsonld($breadcrumbs) {
		$items = array();
		foreach ($breadcrumbs as $b) {
			$items[] = array('name' => $b['text'], 'url' => $b['href']);
		}

		return \Kristal\Jsonld::render(\Kristal\Jsonld::breadcrumbs($items));
	}

	private function getAddonsForCode($code) {
		if ($code === 'coffeebreak') {
			return array(
				array('name' => 'Кавомашина Saeko', 'desc' => 'професійна · від ', 'price' => '1 000 ₴', 'href' => $this->url->link('product/product', 'product_id=50051'), 'icon' => 'i-coffee'),
				array('name' => 'Термопот 5 л', 'desc' => 'постійний окріп · від ', 'price' => '180 ₴', 'href' => $this->url->link('product/product', 'product_id=50053'), 'icon' => 'i-coffee'),
				array('name' => 'Коктейльні столи', 'desc' => 'високі фуршетні · від ', 'price' => '200 ₴', 'href' => $this->url->link('product/product', 'product_id=50066'), 'icon' => 'i-bar'),
				array('name' => 'Чашки з блюдцем', 'desc' => 'білий фарфор · від ', 'price' => '15 ₴', 'href' => $this->url->link('product/product', 'product_id=50018'), 'icon' => 'i-plate')
			);
		}

		if ($code === 'banquet') {
			return array(
				array('name' => 'Чафінгдіші 9 л', 'desc' => 'підігрів страв · від ', 'price' => '450 ₴', 'href' => $this->url->link('product/product', 'product_id=50043'), 'icon' => 'i-pot'),
				array('name' => 'Тарілки серії Royal', 'desc' => 'золотий обідок · від ', 'price' => '22 ₴', 'href' => $this->url->link('product/product', 'product_id=50015'), 'icon' => 'i-plate'),
				array('name' => 'Келихи для вина', 'desc' => 'кришталеве скло · від ', 'price' => '16 ₴', 'href' => $this->url->link('product/product', 'product_id=50031'), 'icon' => 'i-glass'),
				array('name' => 'Банкетні столи', 'desc' => 'круглі на 10 гостей · від ', 'price' => '250 ₴', 'href' => $this->url->link('product/product', 'product_id=50065'), 'icon' => 'i-textile')
			);
		}

		if ($code === 'wedding') {
			return array(
				array('name' => 'Стільці Chiavari', 'desc' => 'білі й золоті · від ', 'price' => '120 ₴', 'href' => $this->url->link('product/product', 'product_id=50068'), 'icon' => 'i-chair'),
				array('name' => 'Шатро 5×10 м', 'desc' => 'з монтажем · від ', 'price' => '1 500 ₴', 'href' => $this->url->link('product/product', 'product_id=50086'), 'icon' => 'i-tent'),
				array('name' => 'Тарілки Royal', 'desc' => 'святковий фарфор · від ', 'price' => '22 ₴', 'href' => $this->url->link('product/product', 'product_id=50015'), 'icon' => 'i-plate'),
				array('name' => 'Келихи-флюте', 'desc' => 'для welcome-зони · від ', 'price' => '16 ₴', 'href' => $this->url->link('product/product', 'product_id=50035'), 'icon' => 'i-glass')
			);
		}

		// buffet (за замовчуванням)
		return array(
			array('name' => 'Коктейльні столи', 'desc' => 'високі фуршетні · від ', 'price' => '200 ₴', 'href' => $this->url->link('product/product', 'product_id=50066'), 'icon' => 'i-bar'),
			array('name' => 'Етажерки 3-ярусні', 'desc' => 'для канапе й солодкого · від ', 'price' => '140 ₴', 'href' => $this->url->link('product/product', 'product_id=50014'), 'icon' => 'i-decor'),
			array('name' => 'Діспенсери 8 л', 'desc' => 'скло з краном · від ', 'price' => '150 ₴', 'href' => $this->url->link('product/product', 'product_id=50062'), 'icon' => 'i-glass'),
			array('name' => 'Келихи-флюте', 'desc' => 'для ігристого · від ', 'price' => '16 ₴', 'href' => $this->url->link('product/product', 'product_id=50035'), 'icon' => 'i-glass')
		);
	}
}
