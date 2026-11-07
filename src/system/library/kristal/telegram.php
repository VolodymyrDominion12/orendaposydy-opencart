<?php
namespace Kristal;

/**
 * Мінімальний клієнт Telegram Bot API (sendMessage). Ніколи не кидає винятків назовні.
 *
 *   $tg = new \Kristal\Telegram($token);
 *   $r = $tg->send($chat_id, '<b>Нова заявка</b>' . "\n" . \Kristal\Telegram::escape($name));
 *   // $r = ['ok' => bool, 'type' => '' | 'config' | 'network' | 'api', 'error' => '…']
 *
 * Токен у тексті помилки замінюється на ***. Таймаут 5 с, з'єднання 3 с.
 * Кілька чатів, журнал, повтори — фіча 023. Фіча 019, PHP 7.3+.
 */
class Telegram {
	const API = 'https://api.telegram.org/bot';

	private $token;
	private $timeout;
	private $connect_timeout;

	public function __construct($token, $timeout = 5, $connect_timeout = 3) {
		$this->token = trim((string)$token);
		$this->timeout = (int)$timeout;
		$this->connect_timeout = (int)$connect_timeout;
	}

	public static function isValidToken($token) {
		return (bool)preg_match('/^\d{5,15}:[A-Za-z0-9_\-]{30,50}$/', trim((string)$token));
	}

	/** chat_id: число (у т.ч. від'ємне для груп) або @username каналу */
	public static function isValidChatId($chat_id) {
		return (bool)preg_match('/^(-?\d{1,20}|@[A-Za-z][A-Za-z0-9_]{4,31})$/', trim((string)$chat_id));
	}

	/** Екранування тексту для parse_mode=HTML */
	public static function escape($text) {
		return htmlspecialchars((string)$text, ENT_NOQUOTES, 'UTF-8');
	}

	/** Токен для показу в адмінці: лише останні 4 символи */
	public static function maskToken($token) {
		$token = (string)$token;

		if ($token === '') {
			return '';
		}

		return str_repeat('•', 8) . substr($token, -4);
	}

	public function send($chat_id, $html) {
		if (!self::isValidToken($this->token)) {
			return $this->result('config', 'invalid token');
		}

		if (!self::isValidChatId($chat_id)) {
			return $this->result('config', 'invalid chat_id');
		}

		$response = $this->request(self::API . $this->token . '/sendMessage', array(
			'chat_id'                  => trim((string)$chat_id),
			'text'                     => (string)$html,
			'parse_mode'               => 'HTML',
			'disable_web_page_preview' => 'true'
		));

		if ($response['error'] !== '') {
			return $this->result('network', $response['error']);
		}

		$json = json_decode($response['body'], true);

		if (!is_array($json)) {
			return $this->result('api', 'HTTP ' . $response['status']);
		}

		if (empty($json['ok'])) {
			$description = isset($json['description']) ? (string)$json['description'] : 'HTTP ' . $response['status'];

			return $this->result('api', $description);
		}

		return $this->result('', '');
	}

	/**
	 * HTTP POST. Окремий метод, щоб тести підміняли мережу.
	 * @return array ['status' => int, 'body' => string, 'error' => string]
	 */
	protected function request($url, $fields) {
		if (!function_exists('curl_init')) {
			return array('status' => 0, 'body' => '', 'error' => 'cURL недоступний');
		}

		$ch = curl_init($url);

		curl_setopt($ch, CURLOPT_POST, true);
		curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query($fields));
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
		curl_setopt($ch, CURLOPT_TIMEOUT, $this->timeout);
		curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, $this->connect_timeout);
		curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, true);

		$body = curl_exec($ch);
		$error = $body === false ? curl_error($ch) : '';
		$status = (int)curl_getinfo($ch, CURLINFO_HTTP_CODE);

		curl_close($ch);

		return array('status' => $status, 'body' => $body === false ? '' : (string)$body, 'error' => $error);
	}

	private function result($type, $error) {
		if ($this->token !== '') {
			$error = str_replace($this->token, '***', $error);
		}

		return array('ok' => $type === '', 'type' => $type, 'error' => $error);
	}
}
