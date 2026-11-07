<?php
/**
 * «Крістал: основне» (фіча 019): контакти (NAP), месенджери й соцмережі, Telegram, антиспам.
 * Налаштування — oc_setting, code = module_kristal_core, store_id = 0 (ядро завантажує їх у $this->config).
 * Бібліотека: system/library/kristal/*. PHP 7.3+.
 */
class ControllerExtensionModuleKristalCore extends Controller {
	const CODE = 'module_kristal_core';
	const ROUTE = 'extension/module/kristal_core';
	const HOURS_ROWS = 3;

	private $error = array();

	private $text_fields = array(
		'name' => 128, 'legal_name' => 255, 'address' => 255, 'city' => 64, 'postcode' => 16, 'email' => 96,
		'geo_lat' => 16, 'geo_lng' => 16, 'hours_note' => 255,
		'telegram_username' => 255, 'instagram' => 255, 'facebook' => 255, 'tiktok' => 255, 'youtube' => 255,
		'tg_chat_id' => 64
	);

	private $social_fields = array('telegram_username' => 'telegram', 'instagram' => 'instagram', 'facebook' => 'facebook', 'tiktok' => 'tiktok', 'youtube' => 'youtube');

	private $defaults = array('spam_min_seconds' => 3, 'spam_rate_limit' => 10, 'spam_rate_window' => 3600);

	public function index() {
		$this->load->language(self::ROUTE);
		$this->document->setTitle($this->language->get('heading_title'));
		$this->load->model('setting/setting');

		$saved = $this->stripPrefix($this->model_setting_setting->getSetting(self::CODE));

		if ($this->request->server['REQUEST_METHOD'] == 'POST' && $this->validate()) {
			$settings = $this->buildSettings($this->request->post, $saved);

			$this->model_setting_setting->editSetting(self::CODE, $settings);
			$this->syncCore($settings);
			\Kristal\Cache_key::flush($this->cache);

			$this->session->data['success'] = $this->language->get('text_success');

			$this->response->redirect($this->url->link(self::ROUTE, 'user_token=' . $this->session->data['user_token'], true));
		}

		$data = array();

		// Повідомлення
		$data['error_warning'] = isset($this->error['warning']) ? $this->error['warning'] : '';
		$data['error'] = $this->error;

		if (isset($this->session->data['success'])) {
			$data['success'] = $this->session->data['success'];
			unset($this->session->data['success']);
		} else {
			$data['success'] = '';
		}

		$token = 'user_token=' . $this->session->data['user_token'];

		$data['breadcrumbs'] = array(
			array('text' => $this->language->get('text_home'), 'href' => $this->url->link('common/dashboard', $token, true)),
			array('text' => $this->language->get('text_extension'), 'href' => $this->url->link('marketplace/extension', $token . '&type=module', true)),
			array('text' => $this->language->get('heading_title'), 'href' => $this->url->link(self::ROUTE, $token, true))
		);

		$data['action'] = $this->url->link(self::ROUTE, $token, true);
		$data['cancel'] = $this->url->link('marketplace/extension', $token . '&type=module', true);
		$data['tg_test_url'] = str_replace('&amp;', '&', $this->url->link(self::ROUTE . '/telegramTest', $token, true));

		// Значення форми: POST з помилками → збережені → початкове заповнення з ядра
		$is_post = $this->request->server['REQUEST_METHOD'] == 'POST';
		$data['prefilled'] = !$is_post && empty($saved['saved']);
		$form = $is_post ? $this->request->post : ($data['prefilled'] ? $this->prefillFromCore($saved) : $saved);

		foreach (array_keys($this->text_fields) as $field) {
			$data[$field] = isset($form[$field]) && is_scalar($form[$field]) ? (string)$form[$field] : '';
		}

		foreach ($this->defaults as $field => $default) {
			$data[$field] = isset($form[$field]) && $form[$field] !== '' ? $form[$field] : $default;
		}

		$data['status'] = isset($form['status']) ? (int)$form['status'] : 1;
		$data['phones'] = $this->formPhones(isset($form['phones']) ? $form['phones'] : array());
		$data['hours'] = $this->formHours(isset($form['hours']) ? $form['hours'] : array());

		$data['days'] = array();

		foreach (\Kristal\Nap::dayCodes() as $code) {
			$data['days'][] = array('code' => $code, 'name' => $this->language->get('text_day_' . $code));
		}

		// Токен ніколи не віддаємо в шаблон повністю (AC-5)
		$saved_token = isset($saved['tg_token']) ? (string)$saved['tg_token'] : '';
		$data['tg_token_masked'] = \Kristal\Telegram::maskToken($saved_token);
		$data['text_tg_token_saved'] = $saved_token !== '' ? sprintf($this->language->get('text_tg_token_saved'), $data['tg_token_masked']) : '';

		// Превʼю JSON-LD — зі збережених налаштувань (AC-6)
		$data['jsonld'] = '';

		if (!empty($saved['saved'])) {
			$catalog = defined('HTTPS_CATALOG') && HTTPS_CATALOG ? HTTPS_CATALOG : HTTP_CATALOG;
			$logo = $this->config->get('config_logo') ? $catalog . 'image/' . $this->config->get('config_logo') : '';
			$jsonld = \Kristal\Jsonld::localBusiness(\Kristal\Nap::normalize($saved), $catalog, $logo);
			$data['jsonld'] = \Kristal\Jsonld::encode($jsonld, true);
		}

		$data['header'] = $this->load->controller('common/header');
		$data['column_left'] = $this->load->controller('common/column_left');
		$data['footer'] = $this->load->controller('common/footer');

		$this->response->setOutput($this->load->view(self::ROUTE, $data));
	}

	/** AJAX: тестове повідомлення в Telegram (AC-4). Токен у відповіді й лозі не з'являється. */
	public function telegramTest() {
		$this->load->language(self::ROUTE);

		$json = array();

		if (!$this->user->hasPermission('modify', self::ROUTE)) {
			$json['error'] = $this->language->get('error_permission');
		} else {
			$this->load->model('setting/setting');
			$saved = $this->stripPrefix($this->model_setting_setting->getSetting(self::CODE));

			$post_token = isset($this->request->post['tg_token']) ? trim((string)$this->request->post['tg_token']) : '';
			$post_chat = isset($this->request->post['tg_chat_id']) ? trim((string)$this->request->post['tg_chat_id']) : '';

			$token = $post_token !== '' ? $post_token : (isset($saved['tg_token']) ? (string)$saved['tg_token'] : '');
			$chat_id = $post_chat !== '' ? $post_chat : (isset($saved['tg_chat_id']) ? (string)$saved['tg_chat_id'] : '');

			$host = parse_url(HTTP_CATALOG, PHP_URL_HOST);
			$message = sprintf(
				$this->language->get('text_tg_test_message'),
				\Kristal\Telegram::escape($host ? $host : $this->config->get('config_name')),
				date('d.m.Y H:i:s')
			);

			$telegram = new \Kristal\Telegram($token);
			$result = $telegram->send($chat_id, $message);

			if ($result['ok']) {
				$json['success'] = $this->language->get('text_tg_sent');
			} else {
				if ($result['type'] == 'config') {
					$json['error'] = $this->language->get('error_tg_config');
				} elseif ($result['type'] == 'network') {
					$json['error'] = sprintf($this->language->get('error_tg_network'), $result['error']);
				} else {
					$json['error'] = sprintf($this->language->get('error_tg_api'), $result['error']);
				}

				$log = new \Kristal\Log();
				$log->write('kristal_core telegramTest: ' . $result['type'] . ': ' . $result['error']);
			}
		}

		$this->response->addHeader('Content-Type: application/json');
		$this->response->setOutput(json_encode($json));
	}

	public function install() {
		$this->load->model('setting/setting');

		$saved = $this->model_setting_setting->getSetting(self::CODE);

		if (empty($saved[self::CODE . '_salt'])) {
			$settings = array(
				self::CODE . '_status' => 1,
				self::CODE . '_saved'  => 0,
				self::CODE . '_salt'   => bin2hex(random_bytes(32))
			);

			foreach ($this->defaults as $key => $value) {
				$settings[self::CODE . '_' . $key] = $value;
			}

			$this->model_setting_setting->editSetting(self::CODE, $settings);
		}
	}

	public function uninstall() {
		$this->load->model('setting/setting');
		$this->model_setting_setting->deleteSetting(self::CODE);

		\Kristal\Cache_key::flush($this->cache);
	}

	protected function validate() {
		if (!$this->user->hasPermission('modify', self::ROUTE)) {
			$this->error['warning'] = $this->language->get('error_permission');

			return false;
		}

		$post = $this->request->post;
		$value = function ($key) use ($post) {
			return isset($post[$key]) && is_scalar($post[$key]) ? trim((string)$post[$key]) : '';
		};

		// Телефони (AC-2)
		$phones = isset($post['phones']) && is_array($post['phones']) ? $post['phones'] : array();

		for ($i = 0; $i < \Kristal\Nap::MAX_PHONES; $i++) {
			$number = isset($phones[$i]['number']) ? trim((string)$phones[$i]['number']) : '';

			if ($number !== '' && !\Kristal\Phone::isValid($number)) {
				$this->error['phone'][$i] = $this->language->get('error_phone');
			}
		}

		if ($value('email') !== '' && !filter_var($value('email'), FILTER_VALIDATE_EMAIL)) {
			$this->error['email'] = $this->language->get('error_email');
		}

		$lat = $value('geo_lat');
		$lng = $value('geo_lng');

		if (($lat !== '' || $lng !== '') && !\Kristal\Nap::geo(str_replace(',', '.', $lat), str_replace(',', '.', $lng))) {
			$this->error['geo'] = $this->language->get('error_geo');
		}

		// Графік: заповнений рядок має бути повним і правильним
		$hours = isset($post['hours']) && is_array($post['hours']) ? $post['hours'] : array();

		for ($i = 0; $i < self::HOURS_ROWS; $i++) {
			$row = isset($hours[$i]) && is_array($hours[$i]) ? $hours[$i] : array();
			$days = isset($row['days']) && is_array($row['days']) ? $row['days'] : array();
			$from = isset($row['from']) ? trim((string)$row['from']) : '';
			$to = isset($row['to']) ? trim((string)$row['to']) : '';

			if (!$days && $from === '' && $to === '') {
				continue;
			}

			$from = \Kristal\Nap::time($from);
			$to = \Kristal\Nap::time($to);

			if (!array_intersect(\Kristal\Nap::dayCodes(), $days) || $from === '' || $to === '' || strcmp($from, $to) >= 0) {
				$this->error['hours'][$i] = $this->language->get('error_hours');
			}
		}

		foreach ($this->social_fields as $field => $network) {
			if ($value($field) !== '' && \Kristal\Nap::socialUrl($network, $value($field)) === '') {
				$this->error[$field] = $this->language->get('error_social');
			}
		}

		if ($value('tg_token') !== '' && !\Kristal\Telegram::isValidToken($value('tg_token'))) {
			$this->error['tg_token'] = $this->language->get('error_tg_token');
		}

		if ($value('tg_chat_id') !== '' && !\Kristal\Telegram::isValidChatId($value('tg_chat_id'))) {
			$this->error['tg_chat_id'] = $this->language->get('error_tg_chat_id');
		}

		$ranges = array('spam_min_seconds' => array(0, 60), 'spam_rate_limit' => array(1, 1000), 'spam_rate_window' => array(60, 86400));

		foreach ($ranges as $field => $range) {
			$v = $value($field);

			if (!preg_match('/^\d+$/', $v) || (int)$v < $range[0] || (int)$v > $range[1]) {
				$this->error[$field] = $this->language->get('error_' . $field);
			}
		}

		if ($this->error) {
			$this->error['warning'] = $this->language->get('error_form');
		}

		return !$this->error;
	}

	/** POST → масив для editSetting (ключі з префіксом module_kristal_core_) */
	private function buildSettings($post, $saved) {
		$s = array();

		foreach ($this->text_fields as $field => $max) {
			$v = isset($post[$field]) && is_scalar($post[$field]) ? trim((string)$post[$field]) : '';
			$s[$field] = utf8_substr($v, 0, $max);
		}

		$s['geo_lat'] = str_replace(',', '.', $s['geo_lat']);
		$s['geo_lng'] = str_replace(',', '.', $s['geo_lng']);

		// Телефони: лише заповнені, у форматі E.164, у порядку форми
		$s['phones'] = array();
		$phones = isset($post['phones']) && is_array($post['phones']) ? $post['phones'] : array();

		for ($i = 0; $i < \Kristal\Nap::MAX_PHONES; $i++) {
			$number = isset($phones[$i]['number']) ? \Kristal\Phone::normalize($phones[$i]['number']) : '';

			if ($number === '') {
				continue;
			}

			$s['phones'][] = array(
				'number'   => $number,
				'label'    => utf8_substr(isset($phones[$i]['label']) ? trim((string)$phones[$i]['label']) : '', 0, 64),
				'viber'    => empty($phones[$i]['viber']) ? 0 : 1,
				'telegram' => empty($phones[$i]['telegram']) ? 0 : 1,
				'whatsapp' => empty($phones[$i]['whatsapp']) ? 0 : 1
			);
		}

		$hours = isset($post['hours']) && is_array($post['hours']) ? $post['hours'] : array();
		$s['hours'] = \Kristal\Nap::hours(array_slice($hours, 0, self::HOURS_ROWS));

		// Токен: порожнє поле — не змінювати (AC-5)
		$new_token = isset($post['tg_token']) ? trim((string)$post['tg_token']) : '';

		if (!empty($post['tg_token_clear'])) {
			$s['tg_token'] = '';
		} elseif ($new_token !== '') {
			$s['tg_token'] = $new_token;
		} else {
			$s['tg_token'] = isset($saved['tg_token']) ? (string)$saved['tg_token'] : '';
		}

		foreach (array_keys($this->defaults) as $field) {
			$s[$field] = (int)$post[$field];
		}

		$s['status'] = empty($post['status']) ? 0 : 1;
		$s['saved'] = 1;
		$s['salt'] = !empty($saved['salt']) ? $saved['salt'] : bin2hex(random_bytes(32));

		$result = array();

		foreach ($s as $key => $v) {
			$result[self::CODE . '_' . $key] = $v;
		}

		return $result;
	}

	/**
	 * Основний телефон, адреса й email → налаштування магазину (листи й рахунки ядра).
	 * Лише editSettingValue: editSetting('config') стер би поля теми sauco (див. 018 → «Замітки»).
	 */
	private function syncCore($settings) {
		$phones = $settings[self::CODE . '_phones'];
		$sync = array(
			'config_telephone' => $phones ? \Kristal\Phone::display($phones[0]['number']) : '',
			'config_address'   => $settings[self::CODE . '_address'],
			'config_email'     => $settings[self::CODE . '_email']
		);

		foreach ($sync as $key => $value) {
			// порожнє не синхронізуємо: ядру потрібен email магазину для листів
			if ($value !== '') {
				$this->model_setting_setting->editSettingValue('config', $key, $value);
			}
		}
	}

	/** Перше відкриття: значення з налаштувань ядра (AC-1) */
	private function prefillFromCore($saved) {
		$form = $saved;
		$form['name'] = (string)$this->config->get('config_name');
		$form['address'] = (string)$this->config->get('config_address');
		$form['email'] = (string)$this->config->get('config_email');
		$form['hours_note'] = (string)$this->config->get('config_open');
		$form['phones'] = array();

		$telephone = trim((string)$this->config->get('config_telephone'));

		if ($telephone !== '') {
			$form['phones'][] = array('number' => $telephone, 'label' => '', 'viber' => 0, 'telegram' => 0, 'whatsapp' => 0);
		}

		$geocode = explode(',', (string)$this->config->get('config_geocode'));

		if (count($geocode) == 2 && \Kristal\Nap::geo(trim($geocode[0]), trim($geocode[1]))) {
			$form['geo_lat'] = trim($geocode[0]);
			$form['geo_lng'] = trim($geocode[1]);
		}

		return $form;
	}

	/** Рівно MAX_PHONES рядків для форми */
	private function formPhones($phones) {
		$rows = array();
		$phones = is_array($phones) ? array_values($phones) : array();

		for ($i = 0; $i < \Kristal\Nap::MAX_PHONES; $i++) {
			$p = isset($phones[$i]) && is_array($phones[$i]) ? $phones[$i] : array();
			$number = isset($p['number']) ? (string)$p['number'] : '';

			$rows[] = array(
				// збережене E.164 показуємо зручно; введене з помилкою — як є
				'number'   => \Kristal\Phone::isValid($number) ? \Kristal\Phone::display($number) : $number,
				'label'    => isset($p['label']) ? (string)$p['label'] : '',
				'viber'    => !empty($p['viber']),
				'telegram' => !empty($p['telegram']),
				'whatsapp' => !empty($p['whatsapp'])
			);
		}

		return $rows;
	}

	/** Рівно HOURS_ROWS рядків для форми */
	private function formHours($hours) {
		$rows = array();
		$hours = is_array($hours) ? array_values($hours) : array();

		for ($i = 0; $i < self::HOURS_ROWS; $i++) {
			$h = isset($hours[$i]) && is_array($hours[$i]) ? $hours[$i] : array();

			$rows[] = array(
				'days' => isset($h['days']) && is_array($h['days']) ? $h['days'] : array(),
				'from' => isset($h['from']) ? (string)$h['from'] : '',
				'to'   => isset($h['to']) ? (string)$h['to'] : ''
			);
		}

		return $rows;
	}

	private function stripPrefix($settings) {
		$result = array();
		$len = strlen(self::CODE) + 1;

		foreach ($settings as $key => $value) {
			if (strpos($key, self::CODE . '_') === 0) {
				$result[substr($key, $len)] = $value;
			}
		}

		return $result;
	}
}
