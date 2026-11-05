<?php
namespace Kristal;

/**
 * Логер, який маскує телефони й email до запису (AGENTS.md §9).
 *
 *   $log = new \Kristal\Log();              // storage/logs/kristal.log
 *   $log->write('Заявка від +380671234567'); // → «Заявка від +38067*****67»
 *
 * Не реєструємо в $registry під ключем `log`, щоб не перезаписати ядровий логер.
 * Фіча 019, PHP 7.3+.
 */
class Log {
	private $log;

	public function __construct($filename = 'kristal.log') {
		$this->log = new \Log($filename);
	}

	public function write($message) {
		if (!is_string($message)) {
			$message = print_r($message, true);
		}

		$this->log->write(self::mask($message));
	}

	/** Маскує email і телефони в довільному тексті. */
	public static function mask($text) {
		$text = (string)$text;

		// email: ivan@example.com → i***@example.com
		$text = preg_replace_callback(
			'/([A-Za-z0-9._%+\-])[A-Za-z0-9._%+\-]*@([A-Za-z0-9\-]+(?:\.[A-Za-z0-9\-]+)*\.[A-Za-z]{2,})/u',
			function ($m) {
				return $m[1] . '***@' . $m[2];
			},
			$text
		);

		// Телефони: послідовності з 9–15 цифр із пробілами/дужками/дефісами між ними.
		$text = preg_replace_callback(
			'/(?<![\w*])\+?\(?\d[\d\s\(\)\-]{7,18}\d(?![\w*])/u',
			function ($m) {
				$candidate = $m[0];
				$digits = preg_replace('/\D+/', '', $candidate);
				$len = strlen($digits);

				if (Phone::isValid($candidate)) {
					return Phone::mask($candidate);
				}

				// Інші номери з «+» (іноземні) теж маскуємо; дати, суми, id — ні.
				if ($candidate[0] === '+' && $len >= 9 && $len <= 15) {
					return '+' . substr($digits, 0, 2) . str_repeat('*', $len - 4) . substr($digits, -2);
				}

				return $candidate;
			},
			$text
		);

		return $text;
	}
}
