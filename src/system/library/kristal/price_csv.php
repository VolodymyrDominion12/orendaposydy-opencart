<?php
namespace Kristal;

/**
 * Прайс у CSV (фіча 022): читання файлу з Excel і запис файлу для Excel. Без БД — лише рядки.
 *
 * Читання: BOM / UTF-8 / Windows-1251 визначаються самі; роздільник — «;», «,» або таб (за першим рядком);
 * заголовки → ключі колонок (COLUMNS + синоніми); порожні рядки пропускаються; номер рядка — як в Excel (заголовок = 1).
 * Клітинки: number(), integer(), unit(), discounts() повертають null (порожньо = «не змінювати»),
 * false (не розібрано) або значення; bool() — null, true/false або 'invalid'.
 * Запис: UTF-8 з BOM, «;», \r\n, числа з комою; клітинки, що починаються з = + - @, екрануються апострофом (AC-3).
 * PHP 7.3+.
 */
class Price_csv {
	const MAX_BYTES = 2097152;
	const MAX_ROWS = 5000;

	/** Ключ → заголовок у файлі. Порядок = порядок колонок вивантаження (AC-2). */
	const COLUMNS = array(
		'id'        => 'ID',
		'sku'       => 'Артикул',
		'name'      => 'Назва',
		'category'  => 'Категорія',
		'price'     => 'Ціна за добу',
		'unit'      => 'Одиниця',
		'minimum'   => 'Мін. кількість',
		'discounts' => 'Знижки',
		'deposit'   => 'Застава',
		'breakage'  => 'Биття/втрата',
		'washing'   => 'Миття включено',
		'hit'       => 'Хіт',
		'status'    => 'Увімкнено'
	);

	/** Інші написання заголовків (після normalizeHeader) */
	private static $aliases = array(
		'id' => 'id', 'product_id' => 'id', 'код товару' => 'id',
		'артикул' => 'sku', 'sku' => 'sku', 'код' => 'sku',
		'назва' => 'name', 'найменування' => 'name', 'name' => 'name', 'товар' => 'name',
		'категорія' => 'category', 'розділ' => 'category', 'category' => 'category',
		'ціна' => 'price', 'ціна за добу' => 'price', 'ціна/доба' => 'price', 'price' => 'price', 'ціна, грн' => 'price',
		'одиниця' => 'unit', 'од' => 'unit', 'од.' => 'unit', 'unit' => 'unit',
		'мін. кількість' => 'minimum', 'мін кількість' => 'minimum', 'мінімум' => 'minimum', 'мінімальна кількість' => 'minimum', 'minimum' => 'minimum',
		'знижки' => 'discounts', 'знижки за обсяг' => 'discounts', 'discounts' => 'discounts',
		'застава' => 'deposit', 'deposit' => 'deposit',
		'биття/втрата' => 'breakage', 'биття' => 'breakage', 'відшкодування' => 'breakage', 'breakage' => 'breakage',
		'миття включено' => 'washing', 'миття' => 'washing', 'washing' => 'washing',
		'хіт' => 'hit', 'hit' => 'hit',
		'увімкнено' => 'status', 'статус' => 'status', 'status' => 'status', 'показувати' => 'status'
	);

	/**
	 * @param string $bytes вміст файлу
	 * @return array error ('' | empty | too_big | binary | no_header | no_key | too_many_rows), encoding, delimiter,
	 *               columns [індекс => ключ], unknown [заголовки], duplicate [ключі], rows [рядок Excel => [ключ => текст]]
	 */
	public static function read($bytes) {
		$result = array('error' => '', 'encoding' => '', 'delimiter' => '', 'columns' => array(), 'unknown' => array(), 'duplicate' => array(), 'rows' => array());
		$bytes = (string)$bytes;

		if (strlen($bytes) > self::MAX_BYTES) {
			$result['error'] = 'too_big';
			return $result;
		}

		if (trim($bytes) === '') {
			$result['error'] = 'empty';
			return $result;
		}

		// xlsx/ods/zip (PK\x03\x04), xls (OLE), будь-що з нуль-байтами — не CSV
		if (substr($bytes, 0, 2) === 'PK' || substr($bytes, 0, 4) === "\xD0\xCF\x11\xE0" || strpos($bytes, "\0") !== false) {
			$result['error'] = 'binary';
			return $result;
		}

		list($text, $result['encoding']) = self::toUtf8($bytes);
		$text = str_replace(array("\r\n", "\r"), "\n", $text);

		$first_line = strtok($text, "\n");
		$result['delimiter'] = self::delimiter((string)$first_line);

		$stream = fopen('php://temp', 'r+');
		fwrite($stream, $text);
		rewind($stream);

		$header = fgetcsv($stream, 0, $result['delimiter'], '"', "\0");

		if (!is_array($header) || count(array_filter($header, 'strlen')) === 0) {
			fclose($stream);
			$result['error'] = 'no_header';
			return $result;
		}

		foreach ($header as $i => $title) {
			$key = self::headerKey((string)$title);

			if ($key === '') {
				if (trim((string)$title) !== '') {
					$result['unknown'][] = trim((string)$title);
				}
			} elseif (in_array($key, $result['columns'], true)) {
				$result['duplicate'][] = $key;
			} else {
				$result['columns'][$i] = $key;
			}
		}

		if (!in_array('id', $result['columns'], true) && !in_array('sku', $result['columns'], true)) {
			fclose($stream);
			$result['error'] = 'no_key';
			return $result;
		}

		$line = 1;

		while (($cells = fgetcsv($stream, 0, $result['delimiter'], '"', "\0")) !== false) {
			$line++;

			if ($cells === array(null) || count(array_filter($cells, function ($c) { return trim((string)$c) !== ''; })) === 0) {
				continue;
			}

			if (count($result['rows']) >= self::MAX_ROWS) {
				fclose($stream);
				$result['error'] = 'too_many_rows';
				$result['rows'] = array();
				return $result;
			}

			$row = array();

			foreach ($result['columns'] as $i => $key) {
				$row[$key] = isset($cells[$i]) ? trim(str_replace("\xC2\xA0", ' ', (string)$cells[$i])) : '';
			}

			$result['rows'][$line] = $row;
		}

		fclose($stream);

		return $result;
	}

	/** @return array [текст UTF-8 без BOM, 'utf-8' | 'utf-8-bom' | 'windows-1251'] */
	public static function toUtf8($bytes) {
		if (substr($bytes, 0, 3) === "\xEF\xBB\xBF") {
			return array(substr($bytes, 3), 'utf-8-bom');
		}

		if (preg_match('//u', $bytes)) {
			return array($bytes, 'utf-8');
		}

		$converted = function_exists('mb_convert_encoding') ? mb_convert_encoding($bytes, 'UTF-8', 'Windows-1251') : iconv('Windows-1251', 'UTF-8//IGNORE', $bytes);

		return array((string)$converted, 'windows-1251');
	}

	/** Роздільник за першим рядком (поза лапками): той, якого найбільше з «;», «,», табу; за рівності — «;» (Excel з українською локаллю). */
	public static function delimiter($line) {
		$line = preg_replace('/"[^"]*"/', '', (string)$line);
		$best = ';';
		$max = substr_count($line, ';');

		foreach (array("\t", ',') as $candidate) {
			$n = substr_count($line, $candidate);

			if ($n > $max) {
				$best = $candidate;
				$max = $n;
			}
		}

		return $best;
	}

	public static function headerKey($title) {
		$t = self::normalizeHeader($title);

		if ($t === '') {
			return '';
		}

		foreach (self::COLUMNS as $key => $label) {
			if (self::normalizeHeader($label) === $t) {
				return $key;
			}
		}

		return isset(self::$aliases[$t]) ? self::$aliases[$t] : '';
	}

	private static function normalizeHeader($title) {
		$t = mb_strtolower(trim(str_replace("\xC2\xA0", ' ', (string)$title)), 'UTF-8');
		$t = preg_replace('/^\x{FEFF}/u', '', $t);
		$t = str_replace(array('’', 'ʼ'), "'", $t);

		return preg_replace('/\s+/u', ' ', $t);
	}

	// ----------------------------------------------------------------- клітинки

	/** «14», «10,50», «1 440», «14 ₴», «14 грн», «1.440,50» → float; '' → null; інше → false. Від'ємні — false. */
	public static function number($raw) {
		$s = trim(str_replace(array("\xC2\xA0", "\xE2\x80\xAF", ' ', '₴', 'грн.', 'грн', 'uah', 'UAH'), '', (string)$raw));

		if ($s === '') {
			return null;
		}

		if (strpos($s, ',') !== false && strpos($s, '.') !== false) {
			// Останній із двох — десятковий, інший — тисячі
			if (strrpos($s, ',') > strrpos($s, '.')) {
				$s = str_replace('.', '', $s);
			} else {
				$s = str_replace(',', '', $s);
			}
		}

		$s = str_replace(',', '.', $s);

		if (!preg_match('/^\d+(\.\d+)?$/', $s)) {
			return false;
		}

		return round((float)$s, 4);
	}

	/** Ціле ≥ 0 («20», «20,0» з Excel) */
	public static function integer($raw) {
		$n = self::number(preg_replace('/\s*(шт|шт\.)$/u', '', trim((string)$raw)));

		if ($n === null || $n === false) {
			return $n;
		}

		return abs($n - round($n)) < 0.00001 ? (int)round($n) : false;
	}

	/** так/ні → true/false; '' → null; не розібрано → 'invalid' (false тут — законне «ні») */
	public static function bool($raw) {
		$s = mb_strtolower(trim((string)$raw), 'UTF-8');

		if ($s === '') {
			return null;
		}

		if (in_array($s, array('так', 'да', '1', '+', 'yes', 'y', 'true', 'т', 'вкл', 'увімкнено'), true)) {
			return true;
		}

		if (in_array($s, array('ні', 'нет', '0', '-', 'no', 'n', 'false', 'н', 'викл', 'вимкнено'), true)) {
			return false;
		}

		return 'invalid';
	}

	/** Код одиниці з назви або коду: «шт», «комплект», «м²», «м2», «пог. м», «подія», «pcs»… */
	public static function unit($raw) {
		$s = mb_strtolower(trim((string)$raw), 'UTF-8');

		if ($s === '') {
			return null;
		}

		$s = rtrim(str_replace(array(' ', "\xC2\xA0"), '', $s), '.');
		$map = array(
			'шт' => 'pcs', 'штука' => 'pcs', 'pcs' => 'pcs',
			'комплект' => 'set', 'компл' => 'set', 'набір' => 'set', 'set' => 'set',
			'м²' => 'm2', 'м2' => 'm2', 'кв.м' => 'm2', 'м.кв' => 'm2', 'квм' => 'm2', 'm2' => 'm2',
			'пог.м' => 'm', 'п.м' => 'm', 'погм' => 'm', 'м' => 'm', 'm' => 'm',
			'подія' => 'event', 'захід' => 'event', 'event' => 'event'
		);

		return isset($map[$s]) ? $map[$s] : false;
	}

	/**
	 * «100:12; 300:10,50» → [[100, 12.0], [300, 10.5]] у порядку з файлу (повтори не прибираються — це перевіряє план);
	 * '' → null (не змінювати), «-» → [] (очистити), інше → false.
	 * Роздільники пар: «;», перенос рядка, «|»; всередині пари — «:» або «=», «шт» і «₴» дозволені.
	 */
	public static function discounts($raw) {
		$s = trim((string)$raw);

		if ($s === '') {
			return null;
		}

		if (in_array($s, array('-', '—', '–'), true)) {
			return array();
		}

		$pairs = array();

		foreach (preg_split('/[;|\n]+/u', $s) as $part) {
			$part = trim($part);

			if ($part === '') {
				continue;
			}

			if (!preg_match('/^(.+?)\s*[:=]\s*(.+)$/u', $part, $m)) {
				return false;
			}

			$qty = self::integer(preg_replace('/^від\s*/u', '', mb_strtolower(trim($m[1]), 'UTF-8')));
			$price = self::number($m[2]);

			if (!is_int($qty) || $price === null || $price === false) {
				return false;
			}

			$pairs[] = array($qty, $price);
		}

		return $pairs ? $pairs : false;
	}

	/** Назва з файлу: прибрати апостроф, яким вивантаження екранувало формулу */
	public static function text($raw) {
		$s = trim((string)$raw);

		return preg_match("/^'[=+\-@]/", $s) ? substr($s, 1) : $s;
	}

	// ----------------------------------------------------------------- запис

	public static function formatNumber($value) {
		$value = round((float)$value, 2);

		return abs($value - round($value)) < 0.005 ? (string)(int)round($value) : number_format($value, 2, ',', '');
	}

	public static function formatBool($value) {
		return $value ? 'так' : 'ні';
	}

	/** @param array $discounts [кількість => ціна] */
	public static function formatDiscounts(array $discounts) {
		ksort($discounts);
		$parts = array();

		foreach ($discounts as $qty => $price) {
			$parts[] = (int)$qty . ':' . self::formatNumber($price);
		}

		return implode('; ', $parts);
	}

	/** Захист від формул Excel (CSV-ін'єкція, AC-3) */
	public static function cell($value) {
		$value = (string)$value;

		return ($value !== '' && strpos("=+-@\t\r", $value[0]) !== false) ? "'" . $value : $value;
	}

	/**
	 * @param array $rows рядки [ключ => значення] (вже відформатовані); колонки — COLUMNS
	 * @return string CSV для Excel: UTF-8 з BOM, «;», \r\n
	 */
	public static function write(array $rows) {
		$stream = fopen('php://temp', 'r+');
		fputcsv($stream, array_values(self::COLUMNS), ';', '"', "\0");

		foreach ($rows as $row) {
			$cells = array();

			foreach (array_keys(self::COLUMNS) as $key) {
				$cells[] = self::cell(isset($row[$key]) ? $row[$key] : '');
			}

			fputcsv($stream, $cells, ';', '"', "\0");
		}

		rewind($stream);
		$csv = stream_get_contents($stream);
		fclose($stream);

		return "\xEF\xBB\xBF" . str_replace("\n", "\r\n", $csv);
	}
}
