<?php
/**
 * Контролер єдиної сторінки «Кошик події» (фіча 010 kristal_checkout).
 * Замінює застарілий sauco checkout/order.
 * PHP 7.3+.
 */
class ControllerCheckoutOrder extends Controller {

	public function index() {
		$this->load->language('checkout/order');
		$this->load->language('extension/kristal/catalog');

		$this->document->setTitle($this->language->get('heading_title'));
		$this->document->setDescription($this->language->get('text_description'));
		$this->config->set('kristal_noindex', true);

		$data['breadcrumbs'] = array();
		$data['breadcrumbs'][] = array(
			'text' => $this->language->get('text_home'),
			'href' => $this->url->link('common/home')
		);
		$data['breadcrumbs'][] = array(
			'text' => $this->language->get('text_cart'),
			'href' => $this->url->link('checkout/order')
		);

		if (!$this->cart->hasProducts()) {
			$data['empty'] = true;
			$data['hits'] = $this->getEmptyCartHits();
		} else {
			$data['empty'] = false;
			$cartData = $this->getCartData();
			$data = array_merge($data, $cartData);

			// Дати оренди за замовчуванням
			$tomorrow = date('Y-m-d', strtotime('+1 day'));
			$dateTo = date('Y-m-d', strtotime('+3 days')); // 2 доби
			$data['default_date_from'] = $tomorrow;
			$data['default_date_to'] = $dateTo;
			$data['min_date'] = $tomorrow;

			// Попереднє заповнення контактів
			$data['customer_name'] = $this->customer->isLogged() ? $this->customer->getFirstName() : '';
			$data['customer_phone'] = $this->customer->isLogged() ? $this->customer->getTelephone() : '';
			$data['customer_email'] = $this->customer->isLogged() ? $this->customer->getEmail() : '';

			// Антиспам токен
			$antispam = \Kristal\Antispam::fromConfig($this->config, $this->session->getId());
			$data['antispam'] = $antispam->fields('checkout');
		}

		$data['action_update'] = $this->url->link('checkout/order/update', '', true);
		$data['action_remove'] = $this->url->link('checkout/order/remove', '', true);
		$data['action_save']   = $this->url->link('checkout/order/save', '', true);
		$data['catalog_href']  = $this->url->link('common/home');

		$data['header'] = $this->load->controller('common/header');
		$data['footer'] = $this->load->controller('common/footer');

		$this->response->setOutput($this->load->view('checkout/order', $data));
	}

	/**
	 * AJAX оновлення кількості позиції в кошику.
	 */
	public function update() {
		$json = array();

		if ($this->request->server['REQUEST_METHOD'] === 'POST') {
			$cart_id = isset($this->request->post['cart_id']) ? (int)$this->request->post['cart_id'] : 0;
			$quantity = isset($this->request->post['quantity']) ? (int)$this->request->post['quantity'] : 1;

			if ($cart_id > 0 && $quantity > 0) {
				$this->cart->update($cart_id, $quantity);
				$json = $this->getCartData();
				$json['success'] = true;
			} else {
				$json['error'] = 'Invalid parameters';
			}
		}

		$this->response->addHeader('Content-Type: application/json');
		$this->response->setOutput(json_encode($json));
	}

	/**
	 * AJAX видалення позиції з кошика.
	 */
	public function remove() {
		$json = array();

		if ($this->request->server['REQUEST_METHOD'] === 'POST') {
			$cart_id = isset($this->request->post['cart_id']) ? (int)$this->request->post['cart_id'] : 0;

			if ($cart_id > 0) {
				$this->cart->remove($cart_id);

				if (!$this->cart->hasProducts()) {
					$json['empty'] = true;
					$json['redirect'] = $this->url->link('checkout/order');
				} else {
					$json = $this->getCartData();
					$json['success'] = true;
				}
			} else {
				$json['error'] = 'Invalid cart ID';
			}
		}

		$this->response->addHeader('Content-Type: application/json');
		$this->response->setOutput(json_encode($json));
	}

	/**
	 * Збереження замовлення (оформлення заявки / перехід на Fondy).
	 */
	public function save() {
		$this->load->language('checkout/order');
		$json = array();

		if ($this->request->server['REQUEST_METHOD'] !== 'POST') {
			$json['error']['general'] = 'Invalid request';
			$this->response->addHeader('Content-Type: application/json');
			$this->response->setOutput(json_encode($json));
			return;
		}

		if (!$this->cart->hasProducts()) {
			$json['error']['general'] = $this->language->get('error_cart_empty');
			$this->response->addHeader('Content-Type: application/json');
			$this->response->setOutput(json_encode($json));
			return;
		}

		// 1. Антиспам
		$antispam = \Kristal\Antispam::fromConfig($this->config, $this->session->getId());
		$salt = (string)$this->config->get('module_kristal_core_salt');
		if ($salt === '') {
			$salt = defined('DIR_SYSTEM') ? md5(DIR_SYSTEM) : 'kristal_default_salt';
		}
		$rl = new \Kristal\Rate_limit($this->db, $salt);
		$spamCheck = $antispam->check('checkout', $this->request->post, $this->request->server['REMOTE_ADDR'], $rl);

		if (!$spamCheck['ok']) {
			$json['error']['general'] = $this->language->get('error_antispam');
			$this->response->addHeader('Content-Type: application/json');
			$this->response->setOutput(json_encode($json));
			return;
		}

		// 2. Валідація полів
		$firstname = isset($this->request->post['firstname']) ? trim($this->request->post['firstname']) : '';
		$telephone = isset($this->request->post['telephone']) ? trim($this->request->post['telephone']) : '';
		$email     = isset($this->request->post['email']) ? trim($this->request->post['email']) : '';
		$date_from = isset($this->request->post['date_from']) ? trim($this->request->post['date_from']) : '';
		$date_to   = isset($this->request->post['date_to']) ? trim($this->request->post['date_to']) : '';
		$delivery_type = (isset($this->request->post['delivery_type']) && $this->request->post['delivery_type'] === 'pickup') ? 'pickup' : 'delivery';
		$delivery_address = isset($this->request->post['delivery_address']) ? trim($this->request->post['delivery_address']) : '';
		$contact_channel = isset($this->request->post['contact_channel']) ? trim($this->request->post['contact_channel']) : 'viber';
		$comment = isset($this->request->post['comment']) ? trim($this->request->post['comment']) : '';
		$is_company = !empty($this->request->post['is_company']) ? 1 : 0;
		$company_name = isset($this->request->post['company_name']) ? trim($this->request->post['company_name']) : '';
		$edrpou = isset($this->request->post['edrpou']) ? trim($this->request->post['edrpou']) : '';
		$payment_method = (isset($this->request->post['payment_method']) && $this->request->post['payment_method'] === 'oplata') ? 'oplata' : 'kristal_request';

		if (mb_strlen($firstname) < 2 || mb_strlen($firstname) > 64) {
			$json['error']['firstname'] = $this->language->get('error_name');
		}

		$phone_norm = \Kristal\Phone::normalize($telephone);
		if (!$phone_norm) {
			$json['error']['telephone'] = $this->language->get('error_phone');
		}

		$today = strtotime('today');
		$time_from = strtotime($date_from);
		$time_to = strtotime($date_to);

		if (!$time_from || !$time_to || $time_from < $today || $time_to < $time_from) {
			$json['error']['dates'] = $this->language->get('error_dates');
		}

		if ($delivery_type === 'delivery' && mb_strlen($delivery_address) < 3) {
			$json['error']['delivery_address'] = $this->language->get('error_address');
		}

		if ($is_company) {
			if (mb_strlen($company_name) < 2) {
				$json['error']['company_name'] = $this->language->get('error_company');
			}
			if (mb_strlen($edrpou) < 8 || mb_strlen($edrpou) > 12) {
				$json['error']['edrpou'] = $this->language->get('error_edrpou');
			}
		}

		if (!empty($json['error'])) {
			$this->response->addHeader('Content-Type: application/json');
			$this->response->setOutput(json_encode($json));
			return;
		}

		// 3. Розрахунок діб та вартості
		$days = max(1, (int)round(($time_to - $time_from) / 86400));
		$multiplier = $this->calculateDaysMultiplier($days);

		$cartData = $this->getCartData();
		$subtotal_day = (float)$cartData['total_day_raw'];
		$total_order = round($subtotal_day * $multiplier);

		// 4. Створення замовлення в ядрі oc_order
		$order_data = array();
		$order_data['invoice_prefix'] = $this->config->get('config_invoice_prefix');
		$order_data['store_id'] = (int)$this->config->get('config_store_id');
		$order_data['store_name'] = $this->config->get('config_name');
		$order_data['store_url'] = !empty($this->request->server['HTTPS']) ? HTTPS_SERVER : HTTP_SERVER;
		$order_data['customer_id'] = $this->customer->isLogged() ? (int)$this->customer->getId() : 0;
		$order_data['customer_group_id'] = $this->customer->isLogged() ? (int)$this->customer->getGroupId() : (int)$this->config->get('config_customer_group_id');
		$order_data['firstname'] = $firstname;
		$order_data['lastname'] = '';
		$order_data['email'] = $email !== '' ? $email : 'order@orendaposudu.com';
		$order_data['telephone'] = $phone_norm;
		$order_data['custom_field'] = array();

		// Payment info
		$order_data['payment_firstname'] = $firstname;
		$order_data['payment_lastname'] = '';
		$order_data['payment_company'] = $is_company ? $company_name : '';
		$order_data['payment_address_1'] = $delivery_type === 'pickup' ? 'Самовивіз' : $delivery_address;
		$order_data['payment_address_2'] = '';
		$order_data['payment_city'] = 'Львів';
		$order_data['payment_postcode'] = '';
		$order_data['payment_country'] = 'Україна';
		$order_data['payment_country_id'] = 220;
		$order_data['payment_zone'] = 'Львівська область';
		$order_data['payment_zone_id'] = 3491;
		$order_data['payment_address_format'] = '';
		$order_data['payment_custom_field'] = array();
		$order_data['payment_method'] = ($payment_method === 'oplata') ? $this->language->get('text_pay_online') : $this->language->get('text_pay_request');
		$order_data['payment_code'] = $payment_method;

		// Shipping info
		$order_data['shipping_firstname'] = $firstname;
		$order_data['shipping_lastname'] = '';
		$order_data['shipping_company'] = $is_company ? $company_name : '';
		$order_data['shipping_address_1'] = $delivery_type === 'pickup' ? 'м. Львів, вул. Богдана Хмельницького, 106' : $delivery_address;
		$order_data['shipping_address_2'] = '';
		$order_data['shipping_city'] = 'Львів';
		$order_data['shipping_postcode'] = '';
		$order_data['shipping_country'] = 'Україна';
		$order_data['shipping_country_id'] = 220;
		$order_data['shipping_zone'] = 'Львівська область';
		$order_data['shipping_zone_id'] = 3491;
		$order_data['shipping_address_format'] = '';
		$order_data['shipping_custom_field'] = array();
		$order_data['shipping_method'] = ($delivery_type === 'pickup') ? 'Самовивіз зі складу' : 'Доставка й вивезення';
		$order_data['shipping_code'] = $delivery_type;

		$order_data['comment'] = $comment;
		$order_data['total'] = $total_order;
		$order_data['affiliate_id'] = 0;
		$order_data['commission'] = 0.0;
		$order_data['marketing_id'] = 0;
		$order_data['tracking'] = '';
		$order_data['language_id'] = (int)$this->config->get('config_language_id');
		$order_data['currency_id'] = $this->currency->getId($this->session->data['currency']);
		$order_data['currency_code'] = $this->session->data['currency'];
		$order_data['currency_value'] = $this->currency->getValue($this->session->data['currency']);
		$order_data['ip'] = $this->request->server['REMOTE_ADDR'];
		$order_data['forwarded_ip'] = !empty($this->request->server['HTTP_X_FORWARDED_FOR']) ? $this->request->server['HTTP_X_FORWARDED_FOR'] : '';
		$order_data['user_agent'] = isset($this->request->server['HTTP_USER_AGENT']) ? $this->request->server['HTTP_USER_AGENT'] : '';
		$order_data['accept_language'] = isset($this->request->server['HTTP_ACCEPT_LANGUAGE']) ? $this->request->server['HTTP_ACCEPT_LANGUAGE'] : '';

		// Товари замовлення
		$order_data['products'] = array();
		foreach ($cartData['products'] as $p) {
			$order_data['products'][] = array(
				'product_id' => $p['product_id'],
				'name'       => $p['name'],
				'model'      => $p['model'],
				'option'     => array(),
				'download'   => array(),
				'quantity'   => $p['quantity'],
				'subtract'   => 0,
				'price'      => $p['unit_price_raw'],
				'total'      => $p['total_raw'],
				'tax'        => 0,
				'reward'     => 0
			);
		}

		// Підсумки
		$order_data['totals'] = array();
		$order_data['totals'][] = array(
			'code'       => 'sub_total',
			'title'      => 'Вартість оренди (' . $days . ' діб)',
			'value'      => $total_order,
			'sort_order' => 1
		);
		$order_data['totals'][] = array(
			'code'       => 'total',
			'title'      => 'Разом',
			'value'      => $total_order,
			'sort_order' => 9
		);

		$this->load->model('checkout/order');
		$order_id = $this->model_checkout_order->addOrder($order_data);

		// 5. Збереження специфічних орендних даних
		$this->load->model('extension/kristal/checkout');
		$rental_data = array(
			'date_from'        => $date_from,
			'date_to'          => $date_to,
			'rental_days'      => $days,
			'delivery_type'    => $delivery_type,
			'delivery_address' => $delivery_address,
			'contact_channel'  => $contact_channel,
			'is_company'       => $is_company,
			'company_name'     => $company_name,
			'edrpou'           => $edrpou
		);
		$this->model_extension_kristal_checkout->saveRental($order_id, $rental_data);

		$this->session->data['order_id'] = $order_id;

		// 6. Обробка способу оплати
		if ($payment_method === 'oplata') {
			// Fondy онлайн передоплата
			$fondy_url = $this->getFondyCheckoutUrl($order_id, $order_data);
			if ($fondy_url) {
				$this->cart->clear();
				$json['success'] = true;
				$json['redirect'] = $fondy_url;
			} else {
				// Якщо Fondy недоступний (локально без ключів), реєструємо як заявку
				$this->model_checkout_order->addOrderHistory($order_id, 1, 'Заявка без оплати (шлюз онлайн-оплати не відповів)', true);
				$this->cart->clear();
				$json['success'] = true;
				$json['redirect'] = $this->url->link('checkout/success');
			}
		} else {
			// Заявка без оплати (статус 1 = "Нове замовлення")
			$this->model_checkout_order->addOrderHistory($order_id, 1, 'Заявка без оплати (через сайт)', true);
			$this->cart->clear();
			$json['success'] = true;
			$json['redirect'] = $this->url->link('checkout/success');
		}

		$this->response->addHeader('Content-Type: application/json');
		$this->response->setOutput(json_encode($json));
	}

	/**
	 * Отримання URL для переходу на шлюз Fondy.
	 */
	private function getFondyCheckoutUrl($order_id, $order_data) {
		$merchant_id = $this->config->get('payment_oplata_merchant');
		$secret_key  = $this->config->get('payment_oplata_secretkey');

		if (!$merchant_id || !$secret_key) {
			return false;
		}

		$backref  = $this->url->link('extension/payment/oplata/response', '', true);
		$callback = $this->url->link('extension/payment/oplata/callback', '', true);
		$desc     = 'Замовлення оренди #' . $order_id;
		$currency = $this->session->data['currency'] ? $this->session->data['currency'] : 'UAH';

		// Оплата 50% передоплати або 100%
		$amount = round($order_data['total'] * 0.5 * 100);

		$args = array(
			'order_id'            => $order_id . '_' . time(),
			'merchant_id'         => $merchant_id,
			'order_desc'          => $desc,
			'amount'              => $amount,
			'currency'            => $currency,
			'response_url'        => $backref,
			'server_callback_url' => $callback,
			'lang'                => 'uk',
			'sender_email'        => $order_data['email']
		);

		// Підпис Fondy
		$filtered = array_filter($args, function ($var) {
			return $var !== '' && $var !== null;
		});
		ksort($filtered);
		$str = $secret_key;
		foreach ($filtered as $k => $v) {
			$str .= '|' . $v;
		}
		$args['signature'] = sha1($str);

		$ch = curl_init();
		curl_setopt($ch, CURLOPT_URL, 'https://api.fondy.eu/api/checkout/url/');
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
		curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-type: application/json'));
		curl_setopt($ch, CURLOPT_POST, true);
		curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode(array('request' => $args)));
		curl_setopt($ch, CURLOPT_TIMEOUT, 5);

		$res = curl_exec($ch);
		curl_close($ch);

		if ($res) {
			$result = json_decode($res);
			if (isset($result->response->checkout_url)) {
				return $result->response->checkout_url;
			}
		}

		return false;
	}

	/**
	 * Коефіцієнт тривалості оренди:
	 * 1 доба = 1.0, 2 доби = 1.5, 3 доби = 2.0 і т.д.
	 */
	private function calculateDaysMultiplier($days) {
		$days = max(1, (int)$days);
		if ($days === 1) {
			return 1.0;
		}
		return 1.0 + ($days - 1) * 0.5;
	}

	/**
	 * Збір та розрахунок усіх позицій кошика з урахуванням знижок за обсяг.
	 */
	private function getCartData() {
		$cart_products = $this->cart->getProducts();
		$product_ids = array();
		foreach ($cart_products as $p) {
			$product_ids[] = (int)$p['product_id'];
		}

		$this->load->model('extension/kristal/catalog');
		$this->load->model('extension/kristal/media');

		$rentals = $this->model_extension_kristal_catalog->getProducts($product_ids);
		$discounts = $this->model_extension_kristal_catalog->getDiscounts($product_ids);

		$products = array();
		$total_day = 0;
		$total_units = 0;

		foreach ($cart_products as $p) {
			$pid = (int)$p['product_id'];
			$rental = isset($rentals[$pid]) ? $rentals[$pid] : array();
			$itemDiscounts = isset($discounts[$pid]) ? $discounts[$pid] : array();

			$base_price = (float)$p['price'];
			$quantity = (int)$p['quantity'];
			$minimum = isset($rental['minimum']) ? max(1, (int)$rental['minimum']) : (isset($p['minimum']) ? (int)$p['minimum'] : 1);

			$unit_price = \Kristal\Rental::unitPrice($quantity, $base_price, $itemDiscounts);
			$line_total = $unit_price * $quantity;

			$total_day += $line_total;
			$total_units += $quantity;

			$image = $this->model_extension_kristal_media->image(isset($p['image']) ? $p['image'] : '', \Kristal\Image::THUMB);

			$unit_name = \Kristal\Rental::unit(isset($rental['unit']) ? $rental['unit'] : '');

			$products[] = array(
				'cart_id'        => $p['cart_id'],
				'product_id'     => $pid,
				'name'           => $p['name'],
				'model'          => isset($p['model']) ? $p['model'] : '',
				'sku'            => isset($rental['sku']) ? $rental['sku'] : (isset($p['model']) ? $p['model'] : ''),
				'quantity'       => $quantity,
				'minimum'        => $minimum,
				'unit'           => $unit_name,
				'unit_price_raw' => $unit_price,
				'unit_price'     => number_format($unit_price, 0, '.', ' ') . ' ₴',
				'total_raw'      => $line_total,
				'total'          => number_format($line_total, 0, '.', ' ') . ' ₴',
				'image'          => $image,
				'href'           => $this->url->link('product/product', 'product_id=' . $pid)
			);
		}

		return array(
			'products'          => $products,
			'count_positions'   => count($products),
			'total_units'       => $total_units,
			'total_day_raw'     => $total_day,
			'total_day'         => number_format($total_day, 0, '.', ' ') . ' ₴',
			'cart_count'        => count($products)
		);
	}

	/**
	 * Хіти для показу в порожньому кошику.
	 */
	private function getEmptyCartHits() {
		$query = $this->db->query("SELECT p.product_id FROM `" . DB_PREFIX . "product` p
			LEFT JOIN `" . DB_PREFIX . "kristal_product_rental` r ON (r.product_id = p.product_id)
			WHERE p.status = '1' AND (r.is_hit = '1' OR p.product_id > 0)
			ORDER BY r.is_hit DESC, p.sort_order ASC, p.product_id DESC
			LIMIT 4");

		$ids = array();
		foreach ($query->rows as $row) {
			$ids[] = (int)$row['product_id'];
		}

		if ($ids) {
			return $this->load->controller('extension/kristal/catalog/cards', $ids);
		}

		return '';
	}
}