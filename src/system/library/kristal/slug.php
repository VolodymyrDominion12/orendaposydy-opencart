<?php
namespace Kristal;

/**
 * ЧПУ латиницею з назви (фіча 022): «Тарілка обідня біла 27 см» → «tarilka-obidnia-bila-27-sm».
 * Транслітерація — офіційна українська (Постанова КМУ № 55, 2010), як у ЧПУ мок-каталогу 001:
 * «є ї й ю я» на початку слова — ye yi y yu ya, усередині — ie i i iu ia; «зг» → zgh; апостроф і м'який знак зникають.
 * PHP 7.3+.
 */
class Slug {
	const MAX = 64;

	private static $map = array(
		'а' => 'a', 'б' => 'b', 'в' => 'v', 'г' => 'h', 'ґ' => 'g', 'д' => 'd', 'е' => 'e', 'є' => 'ie', 'ж' => 'zh',
		'з' => 'z', 'и' => 'y', 'і' => 'i', 'ї' => 'i', 'й' => 'i', 'к' => 'k', 'л' => 'l', 'м' => 'm', 'н' => 'n',
		'о' => 'o', 'п' => 'p', 'р' => 'r', 'с' => 's', 'т' => 't', 'у' => 'u', 'ф' => 'f', 'х' => 'kh', 'ц' => 'ts',
		'ч' => 'ch', 'ш' => 'sh', 'щ' => 'shch', 'ю' => 'iu', 'я' => 'ia', 'ь' => '', '’' => '', "'" => '', 'ʼ' => '', '`' => '',
		// російські літери, що трапляються в старих назвах
		'ы' => 'y', 'э' => 'e', 'ё' => 'io', 'ъ' => ''
	);

	private static $initial = array('є' => 'ye', 'ї' => 'yi', 'й' => 'y', 'ю' => 'yu', 'я' => 'ya');

	/** Слаг без перевірки унікальності; порожній рядок, якщо латинських символів не лишилось. */
	public static function make($text) {
		$text = mb_strtolower(html_entity_decode((string)$text, ENT_QUOTES, 'UTF-8'), 'UTF-8');
		$text = str_replace('зг', 'zgh', $text);
		$text = str_replace(array('ø', 'Ø', '×', '*'), array('d', 'd', 'x', 'x'), $text);

		$out = '';
		$prev_letter = false;
		$len = mb_strlen($text, 'UTF-8');

		for ($i = 0; $i < $len; $i++) {
			$ch = mb_substr($text, $i, 1, 'UTF-8');

			if (isset(self::$initial[$ch]) && !$prev_letter) {
				$out .= self::$initial[$ch];
			} elseif (isset(self::$map[$ch])) {
				$out .= self::$map[$ch];
			} else {
				$out .= $ch;
			}

			// Апостроф усередині слова не розриває його («сім'я» → simia)
			$prev_letter = (bool)preg_match('/^[\p{L}\'’ʼ`]$/u', $ch);
		}

		$out = preg_replace('/[^a-z0-9]+/', '-', $out);
		$out = trim($out, '-');

		if (strlen($out) > self::MAX) {
			$out = rtrim(substr($out, 0, self::MAX), '-');
			$cut = strrpos($out, '-');

			if ($cut !== false && $cut > self::MAX / 2) {
				$out = substr($out, 0, $cut);
			}
		}

		return $out;
	}

	/**
	 * Унікальний слаг: якщо зайнятий — додаємо -2, -3…
	 * @param array $taken множина зайнятих keyword (ключі масиву); доповнюється новим значенням
	 */
	public static function unique($text, array &$taken, $fallback = 'tovar') {
		$base = self::make($text);

		if ($base === '') {
			$base = $fallback;
		}

		$slug = $base;

		for ($n = 2; isset($taken[$slug]); $n++) {
			$slug = $base . '-' . $n;
		}

		$taken[$slug] = true;

		return $slug;
	}
}
