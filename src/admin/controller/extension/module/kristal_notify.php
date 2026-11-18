<?php
/**
 * Контролер адмінки «Крістал: сповіщення» (фіча 023).
 * Telegram, Email, Webhook, перевірка з'єднань, журнал відправок.
 * PHP 7.3+.
 */
class ControllerExtensionModuleKristalNotify extends Controller {
	const CODE = 'module_kristal_notify';
	const ROUTE = 'extension/module/kristal_notify';

	private $error = array();

	public function index() {
		$this->load->language(self::ROUTE);
		$this->document->setTitle($this->language->get('heading_title'));

		$this->load->model('setting/setting');
		$this->load->model('extension/kristal/notify');

		if ($this->request->server['REQUEST_METHOD'] == 'POST' && $this->validate()) {
			$post = $this->request->post;

			// Якщо токен порожній, залишаємо збережений (маскування)
			$saved = $this->model_setting_setting->getSetting(self::CODE);
			if (empty($post['module_kristal_notify_telegram_token']) && !empty($saved['module_kristal_notify_telegram_token'])) {
				$post['module_kristal_notify_telegram_token'] = $saved['module_kristal_notify_telegram_token'];
			}

			// Тека адмінки для посилань у сповіщеннях (на проді вона перейменована, 017)
			$post['module_kristal_notify_admin_dir'] = $this->adminDir();

			$this->model_setting_setting->editSetting(self::CODE, $post);

			// Самовідновлення подій: якщо міграцію не застосовували або подію видалили
			$this->registerEvents();

			$this->session->data['success'] = $this->language->get('text_success');
			$this->response->redirect($this->url->link(self::ROUTE, 'user_token=' . $this->session->data['user_token'], true));
		}

		$data = array();

		$data['heading_title'] = $this->language->get('heading_title');
		$data['text_edit'] = $this->language->get('text_edit');
		$data['text_enabled'] = $this->language->get('text_enabled');
		$data['text_disabled'] = $this->language->get('text_disabled');

		$token = 'user_token=' . $this->session->data['user_token'];

		$data['breadcrumbs'] = array(
			array('text' => $this->language->get('text_home'), 'href' => $this->url->link('common/dashboard', $token, true)),
			array('text' => $this->language->get('text_extension'), 'href' => $this->url->link('marketplace/extension', $token . '&type=module', true)),
			array('text' => $this->language->get('heading_title'), 'href' => $this->url->link(self::ROUTE, $token, true))
		);

		$data['action'] = $this->url->link(self::ROUTE, $token, true);
		$data['cancel'] = $this->url->link('marketplace/extension', $token . '&type=module', true);
		$data['user_token'] = $this->session->data['user_token'];

		$data['error_warning'] = isset($this->error['warning']) ? $this->error['warning'] : '';
		$data['error'] = $this->error;

		// Стан модуля для діагностики «тест є, а замовлення немає» (AC-12)
		$data['warn_master_off'] = !$this->config->get('module_kristal_notify_status');
		$data['event_registered'] = $this->isEventRegistered();
		$data['last_order_log'] = $this->getLastOrderLog();

		$data['text_warn_master_off'] = $this->language->get('text_warn_master_off');
		$data['text_warn_event_missing'] = $this->language->get('text_warn_event_missing');
		$data['text_module_state'] = $this->language->get('text_module_state');
		$data['text_state_master'] = $this->language->get('text_state_master');
		$data['text_state_event'] = $this->language->get('text_state_event');
		$data['text_state_last_order'] = $this->language->get('text_state_last_order');
		$data['text_state_no_orders'] = $this->language->get('text_state_no_orders');
		$data['text_state_yes'] = $this->language->get('text_state_yes');
		$data['text_state_no'] = $this->language->get('text_state_no');
		$data['text_state_event_ok'] = $this->language->get('text_state_event_ok');
		$data['text_state_event_missing'] = $this->language->get('text_state_event_missing');

		if (isset($this->session->data['success'])) {
			$data['success'] = $this->session->data['success'];
			unset($this->session->data['success']);
		} else {
			$data['success'] = '';
		}

		// Значення полів форми
		$fields = array(
			'module_kristal_notify_status' => 0,
			'module_kristal_notify_telegram_status' => 0,
			'module_kristal_notify_telegram_token' => '',
			'module_kristal_notify_telegram_chats' => '',
			'module_kristal_notify_email_status' => 0,
			'module_kristal_notify_email_to' => '',
			'module_kristal_notify_email_prefix' => '[Крістал Оренда]',
			'module_kristal_notify_webhook_status' => 0,
			'module_kristal_notify_webhook_url' => '',
			'module_kristal_notify_webhook_secret' => ''
		);

		foreach ($fields as $key => $default) {
			if (isset($this->request->post[$key])) {
				$data[$key] = $this->request->post[$key];
			} else {
				$val = $this->config->get($key);
				$data[$key] = ($val !== null) ? $val : $default;
			}
		}

		// Для відображення токена в полі (показуємо маску)
		$data['telegram_token_masked'] = \Kristal\Notify::maskSecret($data['module_kristal_notify_telegram_token']);
		$data['has_saved_token'] = !empty($data['module_kristal_notify_telegram_token']);

		// Перевірка наявності конфігурації старого модуля
		$legacyToken = $this->config->get('module_notifications_in_telegram_bot_token');
		$legacyStatus = $this->config->get('module_notifications_in_telegram_status');
		$data['legacy_available'] = (!empty($legacyToken) || !empty($legacyStatus));

		// Журнал відправок
		$filter_status = isset($this->request->get['filter_status']) ? (string)$this->request->get['filter_status'] : '';
		$filter_channel = isset($this->request->get['filter_channel']) ? (string)$this->request->get['filter_channel'] : '';
		$page = isset($this->request->get['page']) ? (int)$this->request->get['page'] : 1;
		$limit = 30;

		$filter_data = array(
			'status' => $filter_status,
			'channel' => $filter_channel
		);

		$total_logs = $this->model_extension_kristal_notify->getTotalLogs($filter_data);
		$logs = $this->model_extension_kristal_notify->getLogs($filter_data, ($page - 1) * $limit, $limit);

		$data['logs'] = array();
		foreach ($logs as $l) {
			$data['logs'][] = array(
				'log_id' => $l['log_id'],
				'channel' => $l['channel'],
				'event_type' => $l['event_type'],
				'entity_id' => $l['entity_id'],
				'recipient' => $l['recipient'],
				'status' => $l['status'],
				'attempts' => $l['attempts'],
				'error' => $l['error'],
				'summary' => $l['summary'],
				'created_at' => date('d.m.Y H:i:s', strtotime($l['created_at']))
			);
		}

		$pagination = new Pagination();
		$pagination->total = $total_logs;
		$pagination->page = $page;
		$pagination->limit = $limit;
		$pagination->url = $this->url->link(self::ROUTE, $token . '&page={page}' . ($filter_status ? '&filter_status=' . $filter_status : '') . ($filter_channel ? '&filter_channel=' . $filter_channel : ''), true);

		$data['pagination'] = $pagination->render();
		$data['filter_status'] = $filter_status;
		$data['filter_channel'] = $filter_channel;

		$data['header'] = $this->load->controller('common/header');
		$data['column_left'] = $this->load->controller('common/column_left');
		$data['footer'] = $this->load->controller('common/footer');

		$this->response->setOutput($this->load->view(self::ROUTE, $data));
	}

	public function testTelegram() {
		$this->load->language(self::ROUTE);

		$json = array('ok' => false, 'message' => '', 'warning' => '');

		if (!$this->user->hasPermission('modify', self::ROUTE)) {
			$json['message'] = $this->language->get('error_permission');
			$this->response->addHeader('Content-Type: application/json');
			$this->response->setOutput(json_encode($json));
			return;
		}

		$token = isset($this->request->post['token']) ? trim((string)$this->request->post['token']) : '';
		if ($token === '') {
			$token = (string)$this->config->get('module_kristal_notify_telegram_token');
		}

		$chatsRaw = isset($this->request->post['chats']) ? (string)$this->request->post['chats'] : '';
		if (trim($chatsRaw) === '') {
			$chatsRaw = (string)$this->config->get('module_kristal_notify_telegram_chats');
		}

		$chats = \Kristal\Notify::parseChatIds($chatsRaw);

		// Попередження, яких сам тест не виявляє: вимкнений модуль/канал або незбережені значення (AC-11)
		$savedToken = (string)$this->config->get('module_kristal_notify_telegram_token');
		$savedChats = \Kristal\Notify::parseChatIds($this->config->get('module_kristal_notify_telegram_chats'));
		$postedChats = $chats;
		sort($postedChats);
		sort($savedChats);

		$json['warning'] = $this->testWarnings('telegram', ($token !== $savedToken) || ($postedChats !== $savedChats));

		if ($token === '' || !\Kristal\Telegram::isValidToken($token)) {
			$json['message'] = 'Вкажіть коректний Telegram Bot Token!';
			$this->response->addHeader('Content-Type: application/json');
			$this->response->setOutput(json_encode($json));
			return;
		}

		if (empty($chats)) {
			$json['message'] = 'Вкажіть хоча б один Chat ID!';
			$this->response->addHeader('Content-Type: application/json');
			$this->response->setOutput(json_encode($json));
			return;
		}

		$text = "<b>Крістал — Тестове сповіщення</b>\n\nМодуль сповіщень налаштовано коректно! Час: " . date('d.m.Y H:i:s');

		$errors = array();
		$successCount = 0;

		foreach ($chats as $chatId) {
			$res = \Kristal\Notify::sendTelegram($token, $chatId, $text);
			$status = $res['ok'] ? 'sent' : 'failed';
			$error = $res['ok'] ? '' : $res['error'];

			\Kristal\Notify::logAttempt($this->db, 'telegram', 'test', 0, $chatId, $status, $error, 'Тест Telegram для ' . $chatId);

			if ($res['ok']) {
				$successCount++;
			} else {
				$errors[] = $chatId . ': ' . $res['error'];
			}
		}

		if ($successCount > 0 && empty($errors)) {
			$json['ok'] = true;
			$json['message'] = 'Тестове повідомлення успішно надіслано в ' . $successCount . ' чат(ів)!';
		} elseif ($successCount > 0) {
			$json['ok'] = true;
			$json['message'] = 'Надіслано в ' . $successCount . ' чат(ів), але виникли помилки: ' . implode('; ', $errors);
		} else {
			$json['ok'] = false;
			$json['message'] = 'Помилка надсилання: ' . implode('; ', $errors);
		}

		$this->response->addHeader('Content-Type: application/json');
		$this->response->setOutput(json_encode($json));
	}

	public function testEmail() {
		$this->load->language(self::ROUTE);

		$json = array('ok' => false, 'message' => '', 'warning' => '');

		if (!$this->user->hasPermission('modify', self::ROUTE)) {
			$json['message'] = $this->language->get('error_permission');
			$this->response->addHeader('Content-Type: application/json');
			$this->response->setOutput(json_encode($json));
			return;
		}

		$emailsRaw = isset($this->request->post['emails']) ? (string)$this->request->post['emails'] : '';
		if (trim($emailsRaw) === '') {
			$emailsRaw = (string)$this->config->get('module_kristal_notify_email_to');
		}

		$emails = \Kristal\Notify::parseEmails($emailsRaw);

		$savedEmails = \Kristal\Notify::parseEmails($this->config->get('module_kristal_notify_email_to'));
		$postedEmails = $emails;
		sort($postedEmails);
		sort($savedEmails);
		$changed = (trim($emailsRaw) !== '' && $postedEmails !== $savedEmails);
		$json['warning'] = $this->testWarnings('email', $changed);

		if (empty($emails)) {
			$defaultEmail = (string)$this->config->get('config_email');
			if ($defaultEmail !== '') {
				$emails = array($defaultEmail);
			}
		}

		if (empty($emails)) {
			$json['message'] = 'Вкажіть хоча б одну коректну email-адресу!';
			$this->response->addHeader('Content-Type: application/json');
			$this->response->setOutput(json_encode($json));
			return;
		}

		$subject = '[Крістал] Тестове сповіщення пошти';
		$message = "Вітаємо!\n\nЦе тестове сповіщення від сайту «Крістал» (orendaposudu.com).\nПоштовий канал налаштовано успішно!\nЧас: " . date('d.m.Y H:i:s');

		$successCount = 0;
		$errors = array();

		foreach ($emails as $email) {
			$mail = new Mail($this->config->get('config_mail_engine'));
			$mail->parameter = $this->config->get('config_mail_parameter');
			$mail->smtp_hostname = $this->config->get('config_mail_smtp_hostname');
			$mail->smtp_username = $this->config->get('config_mail_smtp_username');
			$mail->smtp_password = html_entity_decode($this->config->get('config_mail_smtp_password'), ENT_QUOTES, 'UTF-8');
			$mail->smtp_port = $this->config->get('config_mail_smtp_port');
			$mail->smtp_timeout = $this->config->get('config_mail_smtp_timeout');

			$mail->setTo($email);
			$mail->setFrom($this->config->get('config_email'));
			$mail->setSender(html_entity_decode($this->config->get('config_name'), ENT_QUOTES, 'UTF-8'));
			$mail->setSubject($subject);
			$mail->setText($message);

			try {
				$mail->send();
				\Kristal\Notify::logAttempt($this->db, 'email', 'test', 0, $email, 'sent', '', 'Тест Email на ' . $email);
				$successCount++;
			} catch (Exception $e) {
				$errMsg = $e->getMessage();
				\Kristal\Notify::logAttempt($this->db, 'email', 'test', 0, $email, 'failed', $errMsg, 'Тест Email на ' . $email);
				$errors[] = $email . ': ' . $errMsg;
			}
		}

		if ($successCount > 0 && empty($errors)) {
			$json['ok'] = true;
			$json['message'] = 'Тестовий лист успішно надіслано на ' . implode(', ', $emails) . '!';
		} elseif ($successCount > 0) {
			$json['ok'] = true;
			$json['message'] = 'Частково надіслано, помилки: ' . implode('; ', $errors);
		} else {
			$json['ok'] = false;
			$json['message'] = 'Помилка надсилання: ' . implode('; ', $errors);
		}

		$this->response->addHeader('Content-Type: application/json');
		$this->response->setOutput(json_encode($json));
	}

	public function testWebhook() {
		$this->load->language(self::ROUTE);

		$json = array('ok' => false, 'message' => '', 'warning' => '');

		if (!$this->user->hasPermission('modify', self::ROUTE)) {
			$json['message'] = $this->language->get('error_permission');
			$this->response->addHeader('Content-Type: application/json');
			$this->response->setOutput(json_encode($json));
			return;
		}

		$url = isset($this->request->post['url']) ? trim((string)$this->request->post['url']) : '';
		if ($url === '') {
			$url = (string)$this->config->get('module_kristal_notify_webhook_url');
		}

		$secret = isset($this->request->post['secret']) ? trim((string)$this->request->post['secret']) : '';
		if ($secret === '') {
			$secret = (string)$this->config->get('module_kristal_notify_webhook_secret');
		}

		$savedUrl = (string)$this->config->get('module_kristal_notify_webhook_url');
		$savedSecret = (string)$this->config->get('module_kristal_notify_webhook_secret');
		$json['warning'] = $this->testWarnings('webhook', ($url !== $savedUrl) || ($secret !== $savedSecret));

		if ($url === '' || !filter_var($url, FILTER_VALIDATE_URL)) {
			$json['message'] = 'Вкажіть коректний URL вебхука!';
			$this->response->addHeader('Content-Type: application/json');
			$this->response->setOutput(json_encode($json));
			return;
		}

		$payload = array(
			'event' => 'test.ping',
			'timestamp' => time(),
			'date' => date('c'),
			'data' => array(
				'message' => 'Тестове повідомлення перевірки вебхука «Крістал»',
				'source' => 'admin_test'
			)
		);

		$res = \Kristal\Notify::sendWebhook($url, $payload, $secret);

		$status = $res['ok'] ? 'sent' : 'failed';
		\Kristal\Notify::logAttempt($this->db, 'webhook', 'test', 0, $url, $status, $res['error'], 'Тест Webhook ' . $url);

		if ($res['ok']) {
			$json['ok'] = true;
			$json['message'] = 'Вебхук успішно відправлено! Відповідь сервера: HTTP ' . $res['http_code'];
		} else {
			$json['ok'] = false;
			$json['message'] = 'Помилка вебхука: ' . $res['error'];
		}

		$this->response->addHeader('Content-Type: application/json');
		$this->response->setOutput(json_encode($json));
	}

	public function retry() {
		$json = array('ok' => false, 'message' => '');

		if (!$this->user->hasPermission('modify', self::ROUTE)) {
			$json['message'] = $this->language->get('error_permission');
			$this->response->addHeader('Content-Type: application/json');
			$this->response->setOutput(json_encode($json));
			return;
		}

		$logId = isset($this->request->post['log_id']) ? (int)$this->request->post['log_id'] : 0;
		$this->load->model('extension/kristal/notify');
		$log = $this->model_extension_kristal_notify->getLog($logId);

		if (!$log) {
			$json['message'] = 'Запис у журналі не знайдено!';
			$this->response->addHeader('Content-Type: application/json');
			$this->response->setOutput(json_encode($json));
			return;
		}

		// Повторна відправка залежно від каналу та сутності
		$ok = false;
		$err = '';

		if ($log['channel'] === 'telegram') {
			$token = (string)$this->config->get('module_kristal_notify_telegram_token');
			if ($token === '') {
				$token = (string)$this->config->get('module_kristal_core_tg_token');
			}

			if ($log['event_type'] === 'order') {
				$this->load->model('sale/order');
				$order = $this->model_sale_order->getOrder($log['entity_id']);
				if ($order) {
					$order['products'] = $this->model_sale_order->getOrderProducts($log['entity_id']);
					$adminUrl = $this->url->link('sale/order/info', 'user_token=' . $this->session->data['user_token'] . '&order_id=' . $order['order_id'], true);
					$text = \Kristal\Notify::formatOrderTelegram($order, $adminUrl);
					$res = \Kristal\Notify::sendTelegram($token, $log['recipient'], $text);
					$ok = $res['ok'];
					$err = $res['error'];
				} else {
					$err = 'Замовлення не знайдено в базі';
				}
			} elseif ($log['event_type'] === 'test') {
				$res = \Kristal\Notify::sendTelegram($token, $log['recipient'], "<b>Крістал — Повторний тест</b>\nЧас: " . date('d.m.Y H:i:s'));
				$ok = $res['ok'];
				$err = $res['error'];
			}
		} elseif ($log['channel'] === 'webhook') {
			$url = $log['recipient'];
			$secret = (string)$this->config->get('module_kristal_notify_webhook_secret');
			$payload = array(
				'event' => $log['event_type'] . '.retry',
				'entity_id' => $log['entity_id'],
				'timestamp' => time()
			);
			$res = \Kristal\Notify::sendWebhook($url, $payload, $secret);
			$ok = $res['ok'];
			$err = $res['error'];
		}

		if ($ok) {
			$this->model_extension_kristal_notify->updateLogStatus($logId, 'sent', '');
			$json['ok'] = true;
			$json['message'] = 'Повторну відправку успішно виконано!';
		} else {
			$this->model_extension_kristal_notify->updateLogStatus($logId, 'failed', $err);
			$json['ok'] = false;
			$json['message'] = 'Повторна відправка невдала: ' . $err;
		}

		$this->response->addHeader('Content-Type: application/json');
		$this->response->setOutput(json_encode($json));
	}

	public function importLegacy() {
		$json = array('ok' => false, 'message' => '');

		if (!$this->user->hasPermission('modify', self::ROUTE)) {
			$json['message'] = $this->language->get('error_permission');
			$this->response->addHeader('Content-Type: application/json');
			$this->response->setOutput(json_encode($json));
			return;
		}

		$legacyToken = $this->config->get('module_notifications_in_telegram_bot_token');
		$legacyChat = $this->config->get('module_notifications_in_telegram_chat_id');

		if ($legacyToken !== null && $legacyToken !== '') {
			$this->load->model('setting/setting');

			$current = $this->model_setting_setting->getSetting(self::CODE);
			$current['module_kristal_notify_status'] = 1;
			$current['module_kristal_notify_telegram_status'] = 1;
			$current['module_kristal_notify_telegram_token'] = $legacyToken;
			$current['module_kristal_notify_telegram_chats'] = $legacyChat;

			$this->model_setting_setting->editSetting(self::CODE, $current);

			// Перестраховуємось, що події зареєстровані
			$this->registerEvents();

			// Вимикаємо старий модуль
			$this->model_setting_setting->editSettingValue('module_notifications_in_telegram', 'module_notifications_in_telegram_status', 0);

			$json['ok'] = true;
			$json['message'] = $this->language->get('text_imported');
		} else {
			$json['message'] = 'Дані старого модуля не знайдено!';
		}

		$this->response->addHeader('Content-Type: application/json');
		$this->response->setOutput(json_encode($json));
	}

	public function install() {
		$this->load->model('user/user_group');
		$this->model_user_user_group->addPermission($this->user->getGroupId(), 'access', self::ROUTE);
		$this->model_user_user_group->addPermission($this->user->getGroupId(), 'modify', self::ROUTE);

		// Реєструємо події (ідемпотентно)
		$this->registerEvents();
	}

	public function uninstall() {
		$this->load->model('setting/event');
		$this->model_setting_event->deleteEventByCode('kristal_notify');
	}

	/**
	 * Реєстрація подій OpenCart (ідемпотентно).
	 */
	private function registerEvents() {
		$this->load->model('setting/event');

		$this->model_setting_event->deleteEventByCode('kristal_notify');
		$this->model_setting_event->addEvent('kristal_notify', 'catalog/model/checkout/order/addOrderHistory/after', 'extension/kristal/notify/onOrderHistory', 1, 0);
		$this->model_setting_event->addEvent('kristal_notify', 'catalog/model/checkout/order/addOrder/after', 'extension/kristal/notify/onOrder', 1, 1);
		$this->model_setting_event->addEvent('kristal_notify', 'catalog/model/checkout/simple_order/addOrder/after', 'extension/kristal/notify/onOrder', 1, 2);
	}

	/**
	 * Чи зареєстровано основну подію замовлення.
	 *
	 * @return bool
	 */
	private function isEventRegistered() {
		$query = $this->db->query("SELECT COUNT(*) AS total FROM `" . DB_PREFIX . "event` 
			WHERE `code` = 'kristal_notify' 
			AND `trigger` = 'catalog/model/checkout/order/addOrderHistory/after' 
			AND `status` = '1'");

		return (int)$query->row['total'] > 0;
	}

	/**
	 * Останнє сповіщення про замовлення для панелі стану.
	 *
	 * @return array
	 */
	private function getLastOrderLog() {
		$query = $this->db->query("SELECT `channel`, `status`, `error`, `summary`, `created_at` 
			FROM `" . DB_PREFIX . "kristal_notify_log` 
			WHERE `event_type` = 'order' 
			ORDER BY `log_id` DESC LIMIT 1");

		if (!$query->num_rows) {
			return array();
		}

		$row = $query->row;

		return array(
			'channel' => $row['channel'],
			'status' => $row['status'],
			'error' => $row['error'],
			'summary' => $row['summary'],
			'created_at' => date('d.m.Y H:i:s', strtotime($row['created_at']))
		);
	}

	/**
	 * Тека адмінки відносно кореня сайту (на проді перейменована, 017).
	 *
	 * @return string
	 */
	private function adminDir() {
		$script = isset($this->request->server['PHP_SELF']) ? (string)$this->request->server['PHP_SELF'] : '';
		$dir = str_replace('\\', '/', dirname($script));
		$dir = trim($dir, '/');

		if ($dir === '.' || $dir === '') {
			return '';
		}

		return $dir;
	}

	/**
	 * Попередження до результату тесту каналу: тест не має вводити в оману (AC-11).
	 *
	 * @param string $channel
	 * @param bool $changed
	 * @return string
	 */
	private function testWarnings($channel, $changed) {
		$warnings = array();

		if (!$this->config->get('module_kristal_notify_status')) {
			$warnings[] = $this->language->get('text_warn_master_off');
		}

		if (!$this->config->get('module_kristal_notify_' . $channel . '_status')) {
			$warnings[] = sprintf($this->language->get('text_warn_channel_off'), $this->channelTitle($channel));
		}

		if ($changed) {
			$warnings[] = $this->language->get('text_warn_unsaved');
		}

		return implode(' ', $warnings);
	}

	/**
	 * Назва каналу для повідомлень.
	 *
	 * @param string $channel
	 * @return string
	 */
	private function channelTitle($channel) {
		if ($channel === 'telegram') {
			return $this->language->get('text_telegram');
		}

		if ($channel === 'email') {
			return $this->language->get('text_email');
		}

		if ($channel === 'webhook') {
			return $this->language->get('text_webhook');
		}

		return $channel;
	}

	private function validate() {
		if (!$this->user->hasPermission('modify', self::ROUTE)) {
			$this->error['warning'] = $this->language->get('error_permission');
		}

		$token = isset($this->request->post['module_kristal_notify_telegram_token']) ? trim((string)$this->request->post['module_kristal_notify_telegram_token']) : '';
		if ($token !== '' && !\Kristal\Telegram::isValidToken($token)) {
			$this->error['tg_token'] = $this->language->get('error_tg_token');
		}

		$hookUrl = isset($this->request->post['module_kristal_notify_webhook_url']) ? trim((string)$this->request->post['module_kristal_notify_webhook_url']) : '';
		if ($hookUrl !== '' && !filter_var($hookUrl, FILTER_VALIDATE_URL)) {
			$this->error['hook_url'] = $this->language->get('error_hook_url');
		}

		return !$this->error;
	}
}
