<?php
namespace Kristal;

/**
 * Допоміжний клас для системи сповіщень (Telegram, Email, Webhook).
 * Безпека, валідація, HMAC-підписи, форматування та надсилання повідомлень.
 * Сумісний з PHP 7.3+.
 */
class Notify {

	/**
	 * Розбір списку Telegram chat_id (розділювачі: кома, пробіл, новий рядок, крапка з комою).
	 * Підтримує приватні чати (>0), групи та супергрупи/канали (<0, наприклад -100...).
	 *
	 * @param string|array $input
	 * @return array
	 */
	public static function parseChatIds($input) {
		if (is_array($input)) {
			$raw = implode("\n", $input);
		} else {
			$raw = (string)$input;
		}

		$parts = preg_split('/[\s,;]+/', trim($raw));
		$result = array();

		foreach ($parts as $part) {
			$part = trim($part);
			if ($part === '') {
				continue;
			}
			// Chat ID може бути числом, у тому числі від'ємним (-1001234567890)
			if (preg_match('/^-?\d{5,20}$/', $part)) {
				$result[] = $part;
			}
		}

		return array_values(array_unique($result));
	}

	/**
	 * Розбір списку email-адрес (розділювачі: кома, пробіл, новий рядок, крапка з комою).
	 *
	 * @param string|array $input
	 * @return array
	 */
	public static function parseEmails($input) {
		if (is_array($input)) {
			$raw = implode("\n", $input);
		} else {
			$raw = (string)$input;
		}

		$parts = preg_split('/[\s,;]+/', trim($raw));
		$result = array();

		foreach ($parts as $part) {
			$part = trim($part);
			if ($part === '') {
				continue;
			}
			if (filter_var($part, FILTER_VALIDATE_EMAIL)) {
				$result[] = strtolower($part);
			}
		}

		return array_values(array_unique($result));
	}

	/**
	 * Генерація HMAC-SHA256 підпису для тіла вебхука.
	 *
	 * @param string $payloadJson
	 * @param string $secret
	 * @return string
	 */
	public static function generateSignature($payloadJson, $secret) {
		return hash_hmac('sha256', (string)$payloadJson, (string)$secret);
	}

	/**
	 * Перевірка HMAC-підпису (захист від timing attacks).
	 *
	 * @param string $payloadJson
	 * @param string $secret
	 * @param string $signature
	 * @return bool
	 */
	public static function verifySignature($payloadJson, $secret, $signature) {
		$expected = self::generateSignature($payloadJson, $secret);
		return hash_equals($expected, (string)$signature);
	}

	/**
	 * Маскування секретних ключів або токенів для відображення в адмінці.
	 *
	 * @param string $secret
	 * @return string
	 */
	public static function maskSecret($secret) {
		$s = trim((string)$secret);
		$len = strlen($s);

		if ($len === 0) {
			return '';
		}
		if ($len <= 8) {
			return '***';
		}

		$start = substr($s, 0, 4);
		$end = substr($s, -3);

		return $start . '...' . $end;
	}

	/**
	 * Відправка сповіщення в один Telegram-чат.
	 *
	 * @param string $token
	 * @param string $chatId
	 * @param string $htmlText
	 * @param int $timeout
	 * @return array ['ok' => bool, 'error' => string]
	 */
	public static function sendTelegram($token, $chatId, $htmlText, $timeout = 5) {
		$tg = new Telegram($token, $timeout, 3);
		$res = $tg->send($chatId, $htmlText);

		return array(
			'ok' => !empty($res['ok']),
			'error' => !empty($res['error']) ? (string)$res['error'] : ''
		);
	}

	/**
	 * Відправка вебхука JSON з HMAC-підписом на зовнішній URL.
	 *
	 * @param string $url
	 * @param array $payload
	 * @param string $secret
	 * @param int $timeout
	 * @return array ['ok' => bool, 'http_code' => int, 'error' => string]
	 */
	public static function sendWebhook($url, array $payload, $secret = '', $timeout = 5) {
		$url = trim((string)$url);
		if (!filter_var($url, FILTER_VALIDATE_URL)) {
			return array('ok' => false, 'http_code' => 0, 'error' => 'Невірний URL вебхука');
		}

		$json = json_encode($payload, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
		if ($json === false) {
			return array('ok' => false, 'http_code' => 0, 'error' => 'Помилка кодування JSON');
		}

		$headers = array(
			'Content-Type: application/json',
			'User-Agent: Kristal-Notify/1.0 (OpenCart)'
		);

		if ($secret !== '') {
			$sig = self::generateSignature($json, $secret);
			$headers[] = 'X-Kristal-Signature: sha256=' . $sig;
		}

		$ch = curl_init();
		curl_setopt_array($ch, array(
			CURLOPT_URL => $url,
			CURLOPT_POST => true,
			CURLOPT_POSTFIELDS => $json,
			CURLOPT_HTTPHEADER => $headers,
			CURLOPT_RETURNTRANSFER => true,
			CURLOPT_CONNECTTIMEOUT => 3,
			CURLOPT_TIMEOUT => max(1, (int)$timeout),
			CURLOPT_SSL_VERIFYPEER => true
		));

		$res = curl_exec($ch);
		$err = curl_error($ch);
		$code = (int)curl_getinfo($ch, CURLINFO_HTTP_CODE);
		curl_close($ch);

		if ($err !== '') {
			return array('ok' => false, 'http_code' => $code, 'error' => 'Мережева помилка: ' . $err);
		}

		$ok = ($code >= 200 && $code < 300);
		return array(
			'ok' => $ok,
			'http_code' => $code,
			'error' => $ok ? '' : ('HTTP ' . $code . ($res ? ': ' . substr(strip_tags((string)$res), 0, 100) : ''))
		);
	}

	/**
	 * Запис спроби в журнал oc_kristal_notify_log.
	 *
	 * @param object $db
	 * @param string $channel
	 * @param string $eventType
	 * @param int $entityId
	 * @param string $recipient
	 * @param string $status
	 * @param string $error
	 * @param string $summary
	 * @return int ID створеного запису
	 */
	public static function logAttempt($db, $channel, $eventType, $entityId, $recipient, $status, $error = '', $summary = '') {
		$sql = "INSERT INTO `" . DB_PREFIX . "kristal_notify_log` SET 
			`channel` = '" . $db->escape(substr((string)$channel, 0, 16)) . "',
			`event_type` = '" . $db->escape(substr((string)$eventType, 0, 32)) . "',
			`entity_id` = '" . (int)$entityId . "',
			`recipient` = '" . $db->escape(substr((string)$recipient, 0, 191)) . "',
			`status` = '" . ($status === 'sent' ? 'sent' : 'failed') . "',
			`attempts` = 1,
			`error` = " . ($error !== '' ? "'" . $db->escape(substr((string)$error, 0, 255)) . "'" : "NULL") . ",
			`summary` = " . ($summary !== '' ? "'" . $db->escape(substr((string)$summary, 0, 255)) . "'" : "NULL") . ",
			`created_at` = NOW(),
			`updated_at` = NOW()";

		$db->query($sql);
		return (int)$db->getLastId();
	}

	/**
	 * Форматування повідомлення про замовлення для Telegram (HTML parse_mode).
	 *
	 * @param array $order
	 * @param string $adminUrl Посилання на замовлення в адмінці
	 * @return string
	 */
	public static function formatOrderTelegram(array $order, $adminUrl = '') {
		$orderId = isset($order['order_id']) ? (int)$order['order_id'] : 0;
		$storeName = isset($order['store_name']) && $order['store_name'] !== '' ? $order['store_name'] : 'Крістал';

		$name = trim((isset($order['firstname']) ? $order['firstname'] : '') . ' ' . (isset($order['lastname']) ? $order['lastname'] : ''));
		$phone = isset($order['telephone']) ? $order['telephone'] : '';
		$email = isset($order['email']) ? $order['email'] : '';
		$total = isset($order['total_formatted']) ? $order['total_formatted'] : (isset($order['total']) ? $order['total'] . ' ₴' : '');
		$shipping = isset($order['shipping_method']) ? $order['shipping_method'] : '';
		$payment = isset($order['payment_method']) ? $order['payment_method'] : '';
		$comment = isset($order['comment']) ? trim($order['comment']) : '';

		$lines = array();
		$lines[] = '<b>' . Telegram::escape($storeName) . ' — Нове замовлення #' . $orderId . '</b>';
		$lines[] = '';

		if ($name !== '') {
			$lines[] = '<b>Клієнт:</b> ' . Telegram::escape($name);
		}
		if ($phone !== '') {
			$lines[] = '<b>Телефон:</b> ' . Telegram::escape($phone);
		}
		if ($email !== '') {
			$lines[] = '<b>Email:</b> ' . Telegram::escape($email);
		}

		// Дати оренди (якщо передано)
		if (!empty($order['rental_date_from']) || !empty($order['rental_date_to'])) {
			$from = !empty($order['rental_date_from']) ? $order['rental_date_from'] : '—';
			$to = !empty($order['rental_date_to']) ? $order['rental_date_to'] : '—';
			$days = !empty($order['rental_days']) ? ' (' . (int)$order['rental_days'] . ' діб)' : '';
			$lines[] = '<b>Дати оренди:</b> ' . Telegram::escape($from . ' — ' . $to . $days);
		}

		if ($shipping !== '') {
			$lines[] = '<b>Доставка:</b> ' . Telegram::escape($shipping);
		}
		if ($payment !== '') {
			$lines[] = '<b>Оплата:</b> ' . Telegram::escape($payment);
		}

		// Товари
		if (!empty($order['products']) && is_array($order['products'])) {
			$lines[] = '';
			$lines[] = '<b>Позиції (' . count($order['products']) . '):</b>';
			foreach ($order['products'] as $p) {
				$pName = isset($p['name']) ? $p['name'] : '';
				$pQty = isset($p['quantity']) ? (int)$p['quantity'] : 1;
				$pTotal = isset($p['total_formatted']) ? $p['total_formatted'] : (isset($p['total']) ? $p['total'] . ' ₴' : '');

				$lines[] = '• ' . Telegram::escape($pName) . ' × ' . $pQty . ' = ' . Telegram::escape($pTotal);
			}
		}

		if ($total !== '') {
			$lines[] = '';
			$lines[] = '<b>Разом до сплати:</b> ' . Telegram::escape($total);
		}

		if ($comment !== '') {
			$lines[] = '';
			$lines[] = '<b>Коментар:</b> <i>' . Telegram::escape($comment) . '</i>';
		}

		if ($adminUrl !== '') {
			$lines[] = '';
			$lines[] = '<a href="' . htmlspecialchars($adminUrl, ENT_QUOTES, 'UTF-8') . '">Переглянути в адмінці →</a>';
		}

		return implode("\n", $lines);
	}

	/**
	 * Форматування сповіщення про лід (заявку) для Telegram.
	 *
	 * @param array $lead
	 * @param string $adminUrl
	 * @return string
	 */
	public static function formatLeadTelegram(array $lead, $adminUrl = '') {
		$typeTitle = isset($lead['type_title']) ? $lead['type_title'] : 'Заявка на оренду';
		$leadId = isset($lead['lead_id']) ? (int)$lead['lead_id'] : 0;

		$lines = array();
		$lines[] = '<b>' . Telegram::escape($typeTitle) . ($leadId ? ' #' . $leadId : '') . '</b>';
		$lines[] = '';

		if (!empty($lead['name'])) {
			$lines[] = '<b>Ім\'я:</b> ' . Telegram::escape($lead['name']);
		}
		if (!empty($lead['phone'])) {
			$lines[] = '<b>Телефон:</b> ' . Telegram::escape($lead['phone']);
		}
		if (!empty($lead['email'])) {
			$lines[] = '<b>Email:</b> ' . Telegram::escape($lead['email']);
		}
		if (!empty($lead['event_date'])) {
			$lines[] = '<b>Дата події:</b> ' . Telegram::escape($lead['event_date']);
		}
		if (!empty($lead['guests'])) {
			$lines[] = '<b>Кількість гостей:</b> ' . (int)$lead['guests'];
		}
		if (!empty($lead['comment'])) {
			$lines[] = '<b>Коментар:</b> <i>' . Telegram::escape($lead['comment']) . '</i>';
		}
		if (!empty($lead['source_url'])) {
			$lines[] = '<b>Сторінка:</b> ' . Telegram::escape($lead['source_url']);
		}

		if ($adminUrl !== '') {
			$lines[] = '';
			$lines[] = '<a href="' . htmlspecialchars($adminUrl, ENT_QUOTES, 'UTF-8') . '">Відкрити в адмінці →</a>';
		}

		return implode("\n", $lines);
	}

	/**
	 * Створення безпечного опису для журналу без персональних даних.
	 *
	 * @param string $eventType
	 * @param int $entityId
	 * @param array $data
	 * @return string
	 */
	public static function makeSummary($eventType, $entityId, array $data = array()) {
		$entityId = (int)$entityId;

		if ($eventType === 'order') {
			$count = !empty($data['products']) && is_array($data['products']) ? count($data['products']) : 0;
			$total = isset($data['total']) ? (float)$data['total'] : 0.0;
			return sprintf('Замовлення #%d (%d поз., %.0f ₴)', $entityId, $count, $total);
		}

		if ($eventType === 'lead') {
			$type = !empty($data['type']) ? (string)$data['type'] : 'lead';
			return sprintf('Заявка #%d (%s)', $entityId, $type);
		}

		if ($eventType === 'test') {
			return 'Тестове повідомлення перевірки каналу';
		}

		return sprintf('Подія %s #%d', (string)$eventType, $entityId);
	}
}
