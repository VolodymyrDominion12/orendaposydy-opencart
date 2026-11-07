<?php
namespace Kristal;

/**
 * Українські телефонні номери: нормалізація до E.164, показ, маскування.
 *
 *   Phone::normalize('+38 (067) 123-45-67') → '+380671234567'
 *   Phone::display('+380671234567')         → '+38 067 123 45 67'
 *   Phone::mask('+380671234567')            → '+38067*****67'
 *
 * Невірний або не-український номер → '' (normalize) / false (isValid).
 * Фіча 019, PHP 7.3+.
 */
class Phone {
	public static function normalize($raw) {
		$raw = trim((string)$raw);

		if ($raw === '') {
			return '';
		}

		// Дозволені лише цифри, пробіли, дужки, дефіси, крапки і плюс на початку
		if (!preg_match('/^\+?[\d\s\(\)\.\-]+$/', $raw)) {
			return '';
		}

		$digits = preg_replace('/\D+/', '', $raw);
		$len = strlen($digits);

		if ($len == 12 && substr($digits, 0, 3) === '380') {
			$number = $digits;
		} elseif ($len == 11 && substr($digits, 0, 2) === '80') {
			$number = '3' . $digits;
		} elseif ($len == 10 && $digits[0] === '0') {
			$number = '38' . $digits;
		} elseif ($len == 9 && $raw[0] !== '+') {
			$number = '380' . $digits;
		} else {
			return '';
		}

		// Код оператора/міста не починається з 0
		if (!preg_match('/^380[1-9]\d{8}$/', $number)) {
			return '';
		}

		return '+' . $number;
	}

	public static function isValid($raw) {
		return self::normalize($raw) !== '';
	}

	/** '+380671234567' → '+38 067 123 45 67'; невірний номер повертається як є. */
	public static function display($raw) {
		$e164 = self::normalize($raw);

		if ($e164 === '') {
			return (string)$raw;
		}

		return '+38 ' . substr($e164, 3, 3) . ' ' . substr($e164, 6, 3) . ' ' . substr($e164, 9, 2) . ' ' . substr($e164, 11, 2);
	}

	/** Значення для href: 'tel:+380671234567' або '' */
	public static function tel($raw) {
		$e164 = self::normalize($raw);

		return $e164 === '' ? '' : 'tel:' . $e164;
	}

	/** '+380671234567' → '+38067*****67' (для логів). Невірний номер — усі цифри, крім 2 останніх, зірочками. */
	public static function mask($raw) {
		$e164 = self::normalize($raw);

		if ($e164 !== '') {
			return substr($e164, 0, 6) . '*****' . substr($e164, -2);
		}

		$digits = preg_replace('/\D+/', '', (string)$raw);

		if (strlen($digits) <= 2) {
			return str_repeat('*', strlen($digits));
		}

		return str_repeat('*', strlen($digits) - 2) . substr($digits, -2);
	}
}
