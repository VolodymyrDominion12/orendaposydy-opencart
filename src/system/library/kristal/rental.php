<?php
namespace Kristal;

/**
 * Оренда товару (фіча 005): одиниці, формат ціни, пороги знижок за обсяг.
 * Чисті функції без БД — тест tests/lib/rental_test.php. Логіка порогів повторює кошик ядра
 * (system/library/cart/cart.php: знижка з найбільшою quantity ≤ кількості), тож сума в картці = сума в кошику.
 * PHP 7.3+.
 */
class Rental {
	const DEFAULT_UNIT = 'pcs';

	/** код → [коротко, як у «14 ₴ / шт»] — порядок = порядок у списку адмінки */
	private static $units = array(
		'pcs'   => 'шт',
		'set'   => 'комплект',
		'm2'    => 'м²',
		'm'     => 'пог. м',
		'event' => 'подія'
	);

	public static function units() {
		return self::$units;
	}

	public static function unit($code) {
		return isset(self::$units[$code]) ? self::$units[$code] : self::$units[self::DEFAULT_UNIT];
	}

	public static function isUnit($code) {
		return isset(self::$units[(string)$code]);
	}

	/** 14 → «14 ₴», 10.5 → «10,50 ₴», 1440 → «1 440 ₴» (нерозривні пробіли) */
	public static function money($amount) {
		$amount = round((float)$amount, 2);
		$decimals = abs($amount - round($amount)) < 0.005 ? 0 : 2;

		return number_format($amount, $decimals, ',', "\xC2\xA0") . "\xC2\xA0₴";
	}

	/**
	 * Знижки ядра → упорядковані пороги [quantity => price] (лише quantity > 1, найменша ціна на однаковий поріг).
	 * @param array $discounts [['quantity' => 100, 'price' => 12.0], ...]
	 */
	public static function normalizeDiscounts($discounts) {
		$tiers = array();

		foreach ($discounts as $discount) {
			$quantity = (int)$discount['quantity'];
			$price = (float)$discount['price'];

			if ($quantity > 1 && (!isset($tiers[$quantity]) || $price < $tiers[$quantity])) {
				$tiers[$quantity] = $price;
			}
		}

		ksort($tiers);

		return $tiers;
	}

	/** Ціна одиниці для кількості: знижка з найбільшим порогом ≤ кількості, інакше базова. */
	public static function unitPrice($quantity, $base_price, $discounts) {
		$price = (float)$base_price;

		foreach (self::normalizeDiscounts($discounts) as $from => $tier_price) {
			if ((int)$quantity >= $from) {
				$price = $tier_price;
			}
		}

		return $price;
	}

	/**
	 * Рядки таблиці «кількість → ціна» для картки товару.
	 * @return array [['from' => 20, 'to' => 99, 'price' => 14.0], ['from' => 100, 'to' => 299, …], ['from' => 300, 'to' => 0, …]] (to = 0 — без верхньої межі)
	 */
	public static function tierRows($minimum, $base_price, $discounts) {
		$minimum = max(1, (int)$minimum);
		$tiers = self::normalizeDiscounts($discounts);
		$points = array($minimum => (float)$base_price);

		foreach ($tiers as $from => $price) {
			if ($from <= $minimum) {
				$points[$minimum] = $price; // поріг нижче мінімуму діє з самого мінімуму
			} else {
				$points[$from] = $price;
			}
		}

		ksort($points);

		$rows = array();
		$starts = array_keys($points);

		foreach ($starts as $i => $from) {
			$rows[] = array(
				'from'  => $from,
				'to'    => isset($starts[$i + 1]) ? $starts[$i + 1] - 1 : 0,
				'price' => $points[$from]
			);
		}

		return $rows;
	}

	/** Найвигідніший поріг (для рядка в картці списку «від 300 шт — 10,50 ₴») або null */
	public static function bestTier($minimum, $base_price, $discounts) {
		$rows = self::tierRows($minimum, $base_price, $discounts);

		if (count($rows) < 2) {
			return null;
		}

		return $rows[count($rows) - 1];
	}

	/** Рядок оренди з БД (або null) → значення з типами й значеннями за замовчуванням */
	public static function normalize($row) {
		return array(
			'unit'             => ($row && self::isUnit($row['unit'])) ? $row['unit'] : self::DEFAULT_UNIT,
			'deposit'          => $row ? max(0.0, (float)$row['deposit']) : 0.0,
			'breakage_price'   => $row ? max(0.0, (float)$row['breakage_price']) : 0.0,
			'washing_included' => $row ? (bool)$row['washing_included'] : false,
			'is_hit'           => $row ? (bool)$row['is_hit'] : false
		);
	}
}
