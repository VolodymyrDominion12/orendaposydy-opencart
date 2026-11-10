<?php
/**
 * Контролер вітрини: Калькулятор події (фіча 008 kristal_calculator).
 * PHP 7.3+.
 */
class ControllerExtensionKristalCalculator extends Controller {

	public function index() {
		$this->load->language('extension/kristal/calculator');
		$this->load->model('extension/kristal/calculator');

		$this->document->setTitle($this->language->get('meta_title'));
		$this->document->setDescription($this->language->get('meta_description'));

		$canonical = $this->url->link('extension/kristal/calculator');
		$this->document->addLink($canonical, 'canonical');

		$data['breadcrumbs'] = array();
		$data['breadcrumbs'][] = array(
			'text' => $this->language->get('text_home'),
			'href' => $this->url->link('common/home')
		);
		$data['breadcrumbs'][] = array(
			'text' => $this->language->get('text_calculator'),
			'href' => $canonical
		);

		// Початкові параметри за замовчуванням (як у макеті 06-calculator.html)
		$default_guests = 100;
		$default_format = 'banquet';
		$default_dishes = 3;
		$default_drinks = array('wine', 'champ');
		$default_series = 1;

		$calc_result = $this->model_extension_kristal_calculator->calculate(
			$default_guests,
			$default_format,
			$default_dishes,
			$default_drinks,
			$default_series
		);

		$data['initial_calc'] = $calc_result;
		$data['default_guests'] = $default_guests;
		$data['default_format'] = $default_format;
		$data['default_dishes'] = $default_dishes;
		$data['default_drinks'] = $default_drinks;
		$data['default_series'] = $default_series;

		// URL дій
		$data['calc_url'] = $this->url->link('extension/kristal/calculator/calculate', '', true);
		$data['add_url']  = $this->url->link('extension/kristal/calculator/add', '', true);
		$data['cart_url'] = $this->url->link('checkout/order');
		$data['lead_action'] = $this->url->link('extension/kristal/lead/submit', '', true);

		// Сирі норми для миттєвого клієнтського JS-розрахунку без затримок
		$norms_raw = $this->model_extension_kristal_calculator->getNorms();
		$client_norms = array();
		foreach ($norms_raw as $n) {
			$client_norms[] = array(
				'norm_id'            => (int)$n['norm_id'],
				'category'           => $n['category_type'],
				'name'               => $n['name'],
				'name_classic'       => !empty($n['name_classic']) ? $n['name_classic'] : $n['name'],
				'name_royal'         => !empty($n['name_royal']) ? $n['name_royal'] : $n['name'],
				'product_id_classic' => (int)$n['product_id_classic'],
				'product_id_royal'   => (int)$n['product_id_royal'],
				'price_classic'      => (float)$n['price_classic'],
				'price_royal'        => (float)$n['price_royal'],
				'min_classic'        => (int)$n['min_classic'],
				'min_royal'          => (int)$n['min_royal'],
				'norm_banquet'       => (float)$n['norm_banquet'],
				'norm_buffet'        => (float)$n['norm_buffet'],
				'norm_coffee'        => (float)$n['norm_coffee'],
				'dish_rule'          => $n['dish_rule'],
				'drink_filter'       => $n['drink_filter'],
				'pack_size'          => max(1, (int)$n['pack_size']),
				'sort_order'         => (int)$n['sort_order']
			);
		}
		$data['client_norms_json'] = json_encode($client_norms, JSON_UNESCAPED_UNICODE);

		$data['header'] = $this->load->controller('common/header');
		$data['footer'] = $this->load->controller('common/footer');

		$this->response->setOutput($this->load->view('extension/kristal/calculator', $data));
	}

	/**
	 * AJAX-ендпоінт перерахунку калькулятора.
	 */
	public function calculate() {
		$json = array();

		$this->load->model('extension/kristal/calculator');

		$guests = isset($this->request->request['guests']) ? (int)$this->request->request['guests'] : 100;
		$format = isset($this->request->request['fmt']) ? (string)$this->request->request['fmt'] : 'banquet';
		$dishes = isset($this->request->request['dishes']) ? (int)$this->request->request['dishes'] : 3;
		$series = isset($this->request->request['series']) ? (int)$this->request->request['series'] : 1;

		$drinks = array();
		if (!empty($this->request->request['wine'])) {
			$drinks[] = 'wine';
		}
		if (!empty($this->request->request['champ'])) {
			$drinks[] = 'champ';
		}
		if (!empty($this->request->request['strong'])) {
			$drinks[] = 'strong';
		}

		$result = $this->model_extension_kristal_calculator->calculate($guests, $format, $dishes, $drinks, $series);

		$this->response->addHeader('Content-Type: application/json');
		$this->response->setOutput(json_encode($result));
	}

	/**
	 * AJAX-ендпоінт пакетного додавання всього розрахованого комплекту до кошика.
	 */
	public function add() {
		$json = array();

		if ($this->request->server['REQUEST_METHOD'] === 'POST') {
			$this->load->language('extension/kristal/calculator');
			$this->load->model('extension/kristal/calculator');

			$guests = isset($this->request->post['guests']) ? (int)$this->request->post['guests'] : 100;
			$format = isset($this->request->post['fmt']) ? (string)$this->request->post['fmt'] : 'banquet';
			$dishes = isset($this->request->post['dishes']) ? (int)$this->request->post['dishes'] : 3;
			$series = isset($this->request->post['series']) ? (int)$this->request->post['series'] : 1;

			$drinks = array();
			if (!empty($this->request->post['wine'])) {
				$drinks[] = 'wine';
			}
			if (!empty($this->request->post['champ'])) {
				$drinks[] = 'champ';
			}
			if (!empty($this->request->post['strong'])) {
				$drinks[] = 'strong';
			}

			// Серверний розрахунок гарантує валідацію цін та товарів
			$calculated = $this->model_extension_kristal_calculator->calculate($guests, $format, $dishes, $drinks, $series);

			if (empty($calculated['items'])) {
				$json['error'] = $this->language->get('error_no_items');
			} else {
				$total_qty = 0;
				foreach ($calculated['items'] as $item) {
					if (!empty($item['product_id']) && $item['quantity'] > 0) {
						$this->cart->add($item['product_id'], $item['quantity']);
						$total_qty += $item['quantity'];
					}
				}

				$json['success']     = true;
				$json['message']     = $this->language->get('text_cart_added');
				$json['total_items'] = count($calculated['items']);
				$json['total_qty']   = $total_qty;
				$json['cart_count']  = $this->cart->countProducts();
				$json['redirect']    = $this->url->link('checkout/order');
			}
		} else {
			$json['error'] = $this->language->get('error_request');
		}

		$this->response->addHeader('Content-Type: application/json');
		$this->response->setOutput(json_encode($json));
	}
}
