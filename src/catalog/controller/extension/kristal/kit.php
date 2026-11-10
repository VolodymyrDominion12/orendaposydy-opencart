<?php
/**
 * Контролер готових комплектів для подій (фіча 007 kristal_kit).
 * Сторінка події (за макетом 04-event.html) та пакетне додавання в кошик.
 * PHP 7.3+.
 */
class ControllerExtensionKristalKit extends Controller {

	/**
	 * Сторінка події «Весілля» (ЧПУ: /vesillya).
	 */
	public function wedding() {
		$this->request->get['event'] = 'wedding';
		return $this->event();
	}

	/**
	 * Сторінка події (за замовчуванням wedding / vesillya).
	 */
	public function event() {
		$this->load->language('extension/kristal/kit');
		$this->load->model('extension/kristal/kit');

		$event_type = isset($this->request->get['event']) ? trim($this->request->get['event']) : 'wedding';
		if ($event_type !== 'wedding') {
			$event_type = 'wedding';
		}

		$this->document->setTitle($this->language->get('meta_title_wedding'));
		$this->document->setDescription($this->language->get('meta_description_wedding'));

		// Хлібні крихти
		$data['breadcrumbs'] = array();
		$data['breadcrumbs'][] = array(
			'text' => $this->language->get('text_home'),
			'href' => $this->url->link('common/home')
		);
		$data['breadcrumbs'][] = array(
			'text' => $this->language->get('text_events'),
			'href' => $this->url->link('extension/kristal/kit/event', 'event=wedding')
		);
		$data['breadcrumbs'][] = array(
			'text' => $this->language->get('text_wedding'),
			'href' => $this->url->link('extension/kristal/kit/event', 'event=wedding')
		);

		// Завантаження комплектів
		$kits = $this->model_extension_kristal_kit->getKitsByEventType($event_type);
		$initial_guests = 100;

		foreach ($kits as &$kit) {
			$total_initial = $kit['price_per_guest_num'] * $initial_guests;
			$kit['initial_total'] = number_format($total_initial, 0, '.', ' ') . ' ₴';
			$kit['initial_guests_label'] = sprintf($this->language->get('text_per_day'), $initial_guests);
		}
		unset($kit);

		$data['kits'] = $kits;
		$data['initial_guests'] = $initial_guests;
		$data['action_add_kit'] = $this->url->link('extension/kristal/kit/add', '', true);
		$data['action_cart'] = $this->url->link('checkout/order');
		$data['calculator_url'] = $this->url->link('common/home') . '#lead';

		// Дані форми ліда
		$data['lead_action'] = $this->url->link('extension/kristal/lead/submit', '', true);
		$data['min_event_date'] = date('Y-m-d');

		// Додаткові позиції («Все, крім гостей»)
		$data['addons'] = array(
			array(
				'name'  => 'Стільці Chiavari',
				'desc'  => 'білі й золоті · від ',
				'price' => '120 ₴',
				'href'  => $this->url->link('product/product', 'product_id=50068'),
				'icon'  => 'i-chair'
			),
			array(
				'name'  => 'Банкетні столи',
				'desc'  => 'круглі на 10 гостей · від ',
				'price' => '250 ₴',
				'href'  => $this->url->link('product/product', 'product_id=50065'),
				'icon'  => 'i-table'
			),
			array(
				'name'  => 'Шатро',
				'desc'  => 'з монтажем · від ',
				'price' => '1 500 ₴',
				'href'  => $this->url->link('product/product', 'product_id=50086'),
				'icon'  => 'i-tent'
			),
			array(
				'name'  => 'Офіціанти й бармени',
				'desc'  => 'ціна за запитом',
				'price' => '',
				'href'  => '#lead',
				'icon'  => 'i-people'
			)
		);

		// FAQ
		$data['faq'] = array(
			array(
				'q' => 'Скільки посуду потрібно на 100 гостей?',
				'a' => 'Для банкету — 3–4 тарілки, 3–4 прибори і 2–3 келихи на гостя, плюс 10% запасу. У наших готових комплектах цей розрахунок вже оптимізовано.',
				'open' => true
			),
			array(
				'q' => 'За скільки часу бронювати?',
				'a' => 'У сезон (травень–жовтень) рекомендуємо бронювати за 1–2 місяці. Позиції серії Royal та стільці Chiavari бронюють першими.',
				'open' => false
			),
			array(
				'q' => 'Чи можна поєднати елементи з різних комплектів?',
				'a' => 'Так: наприклад, базовий посуд Classic можна поєднати із золотими підставними тарілками чи золотими приборами Royal. Менеджер підкаже гармонійні комбінації.',
				'open' => false
			)
		);

		$data['header'] = $this->load->controller('common/header');
		$data['footer'] = $this->load->controller('common/footer');

		$this->response->setOutput($this->load->view('extension/kristal/event', $data));
	}

	/**
	 * AJAX додавання всього комплекту в кошик на N гостей.
	 */
	public function add() {
		$json = array();

		if ($this->request->server['REQUEST_METHOD'] === 'POST') {
			$this->load->language('extension/kristal/kit');
			$this->load->model('extension/kristal/kit');

			$kit_id = isset($this->request->post['kit_id']) ? (int)$this->request->post['kit_id'] : 0;
			$guests = isset($this->request->post['guests']) ? (int)$this->request->post['guests'] : 100;

			if ($guests < 1) {
				$guests = 1;
			}

			$kit = $this->model_extension_kristal_kit->getKit($kit_id);
			if (!$kit) {
				$json['error'] = $this->language->get('error_kit_not_found');
			} else {
				$items = $this->model_extension_kristal_kit->calculateKitItems($kit_id, $guests);

				if (empty($items)) {
					$json['error'] = $this->language->get('error_kit_not_found');
				} else {
					$added_count = 0;
					foreach ($items as $item) {
						$this->cart->add($item['product_id'], $item['quantity']);
						$added_count += $item['quantity'];
					}

					$json['success']     = true;
					$json['message']     = $this->language->get('text_added_success');
					$json['total_items'] = count($items);
					$json['cart_count']  = $this->cart->countProducts();
					$json['redirect']    = $this->url->link('checkout/order');
				}
			}
		} else {
			$json['error'] = 'Invalid request';
		}

		$this->response->addHeader('Content-Type: application/json');
		$this->response->setOutput(json_encode($json));
	}
}
