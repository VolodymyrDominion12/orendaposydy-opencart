<?php
namespace Kristal;

/**
 * Атрибути куки сесії (фіча 017, AC-11), без правок ядра.
 *
 * Ядро OpenCart 3.0.4.1 ставить OCSESSID через setcookie() без HttpOnly/SameSite
 * (catalog/controller/startup/session.php, system/framework.php для адмінки).
 * Подія extension/kristal/security/cookie викликає apply() перед маршрутом: бере вже
 * виставлені заголовки, переписує лише куку сесії й віддає заголовки назад — один Set-Cookie.
 *
 *   HTTPS → Secure; HttpOnly; SameSite=None  (Fondy повертає покупця POST-запитом зі свого домену;
 *                                            з Lax браузер не надішле куку і сесія з кошиком загубиться)
 *   HTTP  → HttpOnly; SameSite=Lax            (локально: None без Secure браузер відкидає)
 *
 * PHP 7.3+.
 */
class Cookie {
	/**
	 * Переписати рядки заголовків: кука $name отримує правильні атрибути, повтори цієї куки
	 * зводяться до останнього (браузер однаково бере останній). Решта рядків — без змін, у тому ж порядку.
	 *
	 * @param string[] $lines   рядки виду "Set-Cookie: name=value; path=/" (як з headers_list())
	 * @param string   $name    ім'я куки сесії (session_name з конфігу)
	 * @param bool     $https   запит прийшов по HTTPS
	 * @return string[]         лише рядки Set-Cookie
	 */
	public static function harden(array $lines, $name, $https) {
		$out = array();
		$session_at = null;

		foreach ($lines as $line) {
			if (!preg_match('/^set-cookie\s*:\s*(.*)$/is', $line, $m)) {
				continue;
			}

			$cookie = trim($m[1]);

			if ($name !== '' && self::cookieName($cookie) === $name) {
				$line = 'Set-Cookie: ' . self::withAttributes($cookie, $https);

				if ($session_at !== null) {
					unset($out[$session_at]);
				}

				$out[] = $line;
				end($out);
				$session_at = key($out);
			} else {
				$out[] = 'Set-Cookie: ' . $cookie;
			}
		}

		return array_values($out);
	}

	/** Чи запит по HTTPS (як визначає ядро: $_SERVER['HTTPS']), + за проксі X-Forwarded-Proto. */
	public static function isHttps(array $server) {
		if (!empty($server['HTTPS']) && strtolower((string)$server['HTTPS']) !== 'off') {
			return true;
		}

		return !empty($server['HTTP_X_FORWARDED_PROTO']) && strtolower((string)$server['HTTP_X_FORWARDED_PROTO']) === 'https';
	}

	/**
	 * Застосувати до заголовків поточної відповіді. Нічого не робить, якщо заголовки вже відправлено
	 * або куки сесії серед них немає (тоді не чіпаємо чужі куки взагалі).
	 */
	public static function apply($name, $https) {
		if (headers_sent() || $name === '') {
			return false;
		}

		$current = array();
		$found = false;

		foreach (headers_list() as $line) {
			if (preg_match('/^set-cookie\s*:/i', $line)) {
				$current[] = $line;

				if (self::cookieName(trim(substr($line, strpos($line, ':') + 1))) === $name) {
					$found = true;
				}
			}
		}

		if (!$found) {
			return false;
		}

		header_remove('Set-Cookie');

		foreach (self::harden($current, $name, $https) as $line) {
			header($line, false);
		}

		return true;
	}

	private static function cookieName($cookie) {
		$pos = strpos($cookie, '=');

		return $pos === false ? '' : trim(substr($cookie, 0, $pos));
	}

	private static function withAttributes($cookie, $https) {
		$parts = array();

		foreach (explode(';', $cookie) as $i => $part) {
			$part = trim($part);

			if ($part === '') {
				continue;
			}

			if ($i > 0) {
				$attr = strtolower(trim(strtok($part, '=')));

				if (in_array($attr, array('secure', 'httponly', 'samesite'), true)) {
					continue;
				}
			}

			$parts[] = $part;
		}

		if ($https) {
			$parts[] = 'Secure';
			$parts[] = 'HttpOnly';
			$parts[] = 'SameSite=None';
		} else {
			$parts[] = 'HttpOnly';
			$parts[] = 'SameSite=Lax';
		}

		return implode('; ', $parts);
	}
}
