<?php
/**
 * Модель сповіщень каталогу «Крістал: сповіщення» (023).
 * Відправка сповіщень про замовлення та ліди у Telegram, Email, Webhook.
 * PHP 7.3+.
 */
class ModelExtensionKristalNotify extends Model {

	/**
	 * Відправка сповіщень про замовлення.
	 *
	 * @param int $orderId
	 * @return bool
	 */
	public function sendOrder($orderId) {
		$orderId = (int)$orderId;
		if (!$orderId || !$this->config->get('module_kristal_notify_status')) {
			return false;
		}

		// Захист від дублювання: якщо це замовлення вже успішно надіслано в будь-який канал
		$check = $this->db->query("SELECT log_id FROM `" . DB_PREFIX . "kristal_notify_log` 
			WHERE `entity_id` = '" . $orderId . "' AND `event_type` = 'order' AND `status` = 'sent' LIMIT 1");
		if ($check->num_rows > 0) {
			return false;
		}

		$this->load->model('checkout/order');
		$order = $this->model_checkout_order->getOrder($orderId);
		if (!$order) {
			return false;
		}

		// Параметри оренди (010 kristal_checkout)
		$rentalQuery = $this->db->query("SELECT * FROM `" . DB_PREFIX . "kristal_order_rental` WHERE `order_id` = '" . $orderId . "' LIMIT 1");
		if ($rentalQuery->num_rows) {
			$order['rental_date_from'] = $rentalQuery->row['date_from'];
			$order['rental_date_to']   = $rentalQuery->row['date_to'];
			$order['rental_days']      = $rentalQuery->row['rental_days'];
			$order['delivery_type']    = $rentalQuery->row['delivery_type'];
			$order['delivery_address'] = $rentalQuery->row['delivery_address'];
			$order['contact_channel']  = $rentalQuery->row['contact_channel'];
			$order['is_company']       = $rentalQuery->row['is_company'];
			$order['company_name']     = $rentalQuery->row['company_name'];
			$order['edrpou']           = $rentalQuery->row['edrpou'];
		}

		// Товари замовлення
		$productQuery = $this->db->query("SELECT * FROM `" . DB_PREFIX . "order_product` WHERE `order_id` = '" . $orderId . "'");
		$order['products'] = array();
		foreach ($productQuery->rows as $p) {
			$order['products'][] = array(
				'name' => $p['name'],
				'quantity' => (int)$p['quantity'],
				'price' => (float)$p['price'],
				'total' => (float)$p['total'],
				'total_formatted' => number_format((float)$p['total'], 0, '.', ' ') . ' ₴'
			);
		}

		$order['total_formatted'] = number_format((float)$order['total'], 0, '.', ' ') . ' ₴';

		$summary = \Kristal\Notify::makeSummary('order', $orderId, $order);

		// 1. Telegram
		if ($this->config->get('module_kristal_notify_telegram_status')) {
			$token = (string)$this->config->get('module_kristal_notify_telegram_token');
			if ($token === '') {
				$token = (string)$this->config->get('module_kristal_core_tg_token');
			}

			$chats = \Kristal\Notify::parseChatIds($this->config->get('module_kristal_notify_telegram_chats'));
			if (!empty($chats) && $token !== '') {
				$adminUrl = HTTP_SERVER . 'admin/index.php?route=sale/order/info&order_id=' . $orderId;
				$text = \Kristal\Notify::formatOrderTelegram($order, $adminUrl);

				foreach ($chats as $chatId) {
					$res = \Kristal\Notify::sendTelegram($token, $chatId, $text);
					$status = $res['ok'] ? 'sent' : 'failed';
					\Kristal\Notify::logAttempt($this->db, 'telegram', 'order', $orderId, $chatId, $status, $res['error'], $summary);
				}
			}
		}

		// 2. Email
		if ($this->config->get('module_kristal_notify_email_status')) {
			$emails = \Kristal\Notify::parseEmails($this->config->get('module_kristal_notify_email_to'));
			if (empty($emails)) {
				$defEmail = (string)$this->config->get('config_email');
				if ($defEmail !== '') {
					$emails = array($defEmail);
				}
			}

			if (!empty($emails)) {
				$prefix = trim((string)$this->config->get('module_kristal_notify_email_prefix'));
				if ($prefix === '') {
					$prefix = '[Крістал Оренда]';
				}

				$subject = $prefix . ' Нове замовлення #' . $orderId . ' (' . $order['total_formatted'] . ')';

				$lines = array();
				$lines[] = 'Нове замовлення #' . $orderId;
				$lines[] = 'Клієнт: ' . $order['firstname'] . ' ' . $order['lastname'];
				$lines[] = 'Телефон: ' . $order['telephone'];
				$lines[] = 'Email: ' . $order['email'];
				if (!empty($order['shipping_method'])) {
					$lines[] = 'Спосіб доставки: ' . $order['shipping_method'];
				}
				if (!empty($order['payment_method'])) {
					$lines[] = 'Спосіб оплати: ' . $order['payment_method'];
				}
				$lines[] = '';
				$lines[] = 'Товари:';
				foreach ($order['products'] as $p) {
					$lines[] = '- ' . $p['name'] . ' x ' . $p['quantity'] . ' = ' . $p['total_formatted'];
				}
				$lines[] = '';
				$lines[] = 'Разом: ' . $order['total_formatted'];
				if (!empty($order['comment'])) {
					$lines[] = 'Коментар: ' . $order['comment'];
				}

				$body = implode("\n", $lines);

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
					$mail->setText($body);

					try {
						$mail->send();
						\Kristal\Notify::logAttempt($this->db, 'email', 'order', $orderId, $email, 'sent', '', $summary);
					} catch (Exception $e) {
						\Kristal\Notify::logAttempt($this->db, 'email', 'order', $orderId, $email, 'failed', $e->getMessage(), $summary);
					}
				}
			}
		}

		// 3. Webhook
		if ($this->config->get('module_kristal_notify_webhook_status')) {
			$url = trim((string)$this->config->get('module_kristal_notify_webhook_url'));
			$secret = trim((string)$this->config->get('module_kristal_notify_webhook_secret'));

			if ($url !== '') {
				$payload = array(
					'event' => 'order.created',
					'entity_id' => $orderId,
					'timestamp' => time(),
					'data' => array(
						'order_id' => $orderId,
						'firstname' => $order['firstname'],
						'lastname' => $order['lastname'],
						'telephone' => $order['telephone'],
						'email' => $order['email'],
						'total' => (float)$order['total'],
						'shipping_method' => $order['shipping_method'],
						'payment_method' => $order['payment_method'],
						'comment' => $order['comment'],
						'products' => $order['products']
					)
				);

				$res = \Kristal\Notify::sendWebhook($url, $payload, $secret);
				$status = $res['ok'] ? 'sent' : 'failed';
				\Kristal\Notify::logAttempt($this->db, 'webhook', 'order', $orderId, $url, $status, $res['error'], $summary);
			}
		}

		return true;
	}

	/**
	 * Відправка сповіщень про лід (заявку 009).
	 *
	 * @param int $leadId
	 * @param array $lead
	 * @return bool
	 */
	public function sendLead($leadId, array $lead) {
		$leadId = (int)$leadId;
		if (!$leadId || !$this->config->get('module_kristal_notify_status')) {
			return false;
		}

		$summary = \Kristal\Notify::makeSummary('lead', $leadId, $lead);

		// 1. Telegram
		if ($this->config->get('module_kristal_notify_telegram_status')) {
			$token = (string)$this->config->get('module_kristal_notify_telegram_token');
			if ($token === '') {
				$token = (string)$this->config->get('module_kristal_core_tg_token');
			}

			$chats = \Kristal\Notify::parseChatIds($this->config->get('module_kristal_notify_telegram_chats'));
			if (!empty($chats) && $token !== '') {
				$adminUrl = HTTP_SERVER . 'admin/index.php?route=extension/kristal/lead';
				$text = \Kristal\Notify::formatLeadTelegram($lead, $adminUrl);

				foreach ($chats as $chatId) {
					$res = \Kristal\Notify::sendTelegram($token, $chatId, $text);
					$status = $res['ok'] ? 'sent' : 'failed';
					\Kristal\Notify::logAttempt($this->db, 'telegram', 'lead', $leadId, $chatId, $status, $res['error'], $summary);
				}
			}
		}

		// 2. Email
		if ($this->config->get('module_kristal_notify_email_status')) {
			$emails = \Kristal\Notify::parseEmails($this->config->get('module_kristal_notify_email_to'));
			if (empty($emails)) {
				$defEmail = (string)$this->config->get('config_email');
				if ($defEmail !== '') {
					$emails = array($defEmail);
				}
			}

			if (!empty($emails)) {
				$prefix = trim((string)$this->config->get('module_kristal_notify_email_prefix'));
				if ($prefix === '') {
					$prefix = '[Крістал Оренда]';
				}

				$type = !empty($lead['type_title']) ? $lead['type_title'] : 'Нова заявка';
				$subject = $prefix . ' ' . $type . ' #' . $leadId;

				$lines = array();
				$lines[] = $type . ' #' . $leadId;
				if (!empty($lead['name'])) { $lines[] = 'Ім\'я: ' . $lead['name']; }
				if (!empty($lead['phone'])) { $lines[] = 'Телефон: ' . $lead['phone']; }
				if (!empty($lead['email'])) { $lines[] = 'Email: ' . $lead['email']; }
				if (!empty($lead['event_date'])) { $lines[] = 'Дата події: ' . $lead['event_date']; }
				if (!empty($lead['guests'])) { $lines[] = 'Гостей: ' . $lead['guests']; }
				if (!empty($lead['comment'])) { $lines[] = 'Коментар: ' . $lead['comment']; }
				if (!empty($lead['source_url'])) { $lines[] = 'Сторінка: ' . $lead['source_url']; }

				$body = implode("\n", $lines);

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
					$mail->setText($body);

					try {
						$mail->send();
						\Kristal\Notify::logAttempt($this->db, 'email', 'lead', $leadId, $email, 'sent', '', $summary);
					} catch (Exception $e) {
						\Kristal\Notify::logAttempt($this->db, 'email', 'lead', $leadId, $email, 'failed', $e->getMessage(), $summary);
					}
				}
			}
		}

		// 3. Webhook
		if ($this->config->get('module_kristal_notify_webhook_status')) {
			$url = trim((string)$this->config->get('module_kristal_notify_webhook_url'));
			$secret = trim((string)$this->config->get('module_kristal_notify_webhook_secret'));

			if ($url !== '') {
				$payload = array(
					'event' => 'lead.created',
					'entity_id' => $leadId,
					'timestamp' => time(),
					'data' => $lead
				);

				$res = \Kristal\Notify::sendWebhook($url, $payload, $secret);
				$status = $res['ok'] ? 'sent' : 'failed';
				\Kristal\Notify::logAttempt($this->db, 'webhook', 'lead', $leadId, $url, $status, $res['error'], $summary);
			}
		}

		return true;
	}
}
