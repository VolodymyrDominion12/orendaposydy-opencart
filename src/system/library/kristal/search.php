<?php
namespace Kristal;

/**
 * Пошук «Крістал» (фіча 027): чисті функції без БД — нормалізація тексту, слова для індексу, слова запиту,
 * англійська розкладка, синоніми, ранжування. Спільні для вітрини (пошук) і адмінки (індекс kristal_search_word).
 * Тести: tests/lib/search_test.php. PHP 7.3+, mbstring.
 *
 *   Search::words('Тарілка біла 27см')         → ['тарілка', 'біла', '27', 'см']      (індекс)
 *   Search::tokens('Тарілки БІЛ')               → ['тарілк', 'біл']                    (префікси запиту)
 *   Search::layout('nfhskrf')                   → 'тарілка'
 *   Search::variants('фуж', Search::synonyms("келих = фужер, бокал")) → ['фуж', 'келих', 'фужер', 'бокал']
 */
class Search {
	/** Найдовше слово в індексі (колонка word VARCHAR(32)) */
	const WORD_MAX = 32;
	/** Слів у запиті */
	const TOKENS_MAX = 6;
	/** Довжина запиту, далі обрізається (AC-10) */
	const QUERY_MAX = 64;

	/** Закінчення, яке відкидаємо в словах запиту від 5 літер: «тарілки» → «тарілк» знаходить «тарілка» */
	const ENDINGS = 'аеєиіїоуюяьй';

	/** Українська розкладка для латинських клавіш (стандартна ЙЦУКЕН) */
	private static $layout = array(
		'q' => 'й', 'w' => 'ц', 'e' => 'у', 'r' => 'к', 't' => 'е', 'y' => 'н', 'u' => 'г', 'i' => 'ш', 'o' => 'щ', 'p' => 'з', '[' => 'х', ']' => 'ї', '\\' => 'ґ',
		'a' => 'ф', 's' => 'і', 'd' => 'в', 'f' => 'а', 'g' => 'п', 'h' => 'р', 'j' => 'о', 'k' => 'л', 'l' => 'д', ';' => 'ж', "'" => 'є',
		'z' => 'я', 'x' => 'ч', 'c' => 'с', 'v' => 'м', 'b' => 'и', 'n' => 'т', 'm' => 'ь', ',' => 'б', '.' => 'ю', '`' => 'ʼ'
	);

	/** Абетка для сортування за назвою (порядок кодів Unicode ставить «і», «ї», «є», «ґ» після «я») */
	const ALPHABET = 'абвгґдеєжзиіїйклмнопрстуфхцчшщьюя';

	/**
	 * Текст → нижній регістр, без HTML-сутностей, апострофів і розділових знаків; цифри відокремлені від літер.
	 * «Стілець К’яварі (білий)» → «стілець кяварі білий»; «27см» → «27 см»; «MOCK-0001» → «mock 0001».
	 */
	public static function normalize($text) {
		$s = html_entity_decode((string)$text, ENT_QUOTES, 'UTF-8');
		$s = mb_strtolower($s, 'UTF-8');
		$s = str_replace(array("'", '’', 'ʼ', '`', '‘', '´', '"'), '', $s);
		$s = preg_replace('/[^\p{L}\p{N}]+/u', ' ', $s);
		$s = preg_replace('/(?<=\p{N})(?=\p{L})|(?<=\p{L})(?=\p{N})/u', ' ', $s);

		return trim(preg_replace('/\s+/u', ' ', $s));
	}

	/** Унікальні слова для індексу (обрізані до WORD_MAX), не більше $max. */
	public static function words($text, $max = 64) {
		$words = array();

		foreach (explode(' ', self::normalize($text)) as $word) {
			if ($word === '') {
				continue;
			}

			$word = mb_substr($word, 0, self::WORD_MAX, 'UTF-8');
			$words[$word] = $word;

			if (count($words) >= $max) {
				break;
			}
		}

		return array_values($words);
	}

	/** Запит клієнта: обрізаний до QUERY_MAX символів, без зайвих пробілів (для показу й журналу). */
	public static function cut($query) {
		$query = trim(preg_replace('/\s+/u', ' ', (string)$query));

		return mb_substr($query, 0, self::QUERY_MAX, 'UTF-8');
	}

	/** Префікс для слова запиту: від 5 літер відкидаємо останню голосну / «ь» / «й». */
	public static function stem($word) {
		$len = mb_strlen($word, 'UTF-8');

		if ($len >= 5 && mb_strpos(self::ENDINGS, mb_substr($word, -1, 1, 'UTF-8'), 0, 'UTF-8') !== false) {
			return mb_substr($word, 0, $len - 1, 'UTF-8');
		}

		return $word;
	}

	/** Слова запиту як префікси для пошуку: до TOKENS_MAX, без повторів і без слів, що є префіксом іншого слова запиту. */
	public static function tokens($query) {
		$tokens = array();

		foreach (self::words($query, self::TOKENS_MAX) as $word) {
			$tokens[] = self::stem($word);
		}

		$tokens = array_values(array_unique($tokens));

		// «тарі тарілк» → лише «тарілк»: коротший префікс нічого не додає до умови «всі слова знайдено»
		$result = array();

		foreach ($tokens as $i => $token) {
			$covered = false;

			foreach ($tokens as $j => $other) {
				if ($i !== $j && $other !== $token && mb_strpos($other, $token, 0, 'UTF-8') === 0) {
					$covered = true;
					break;
				}
			}

			if (!$covered) {
				$result[] = $token;
			}
		}

		return $result;
	}

	/**
	 * Запит, набраний в англійській розкладці → українська. Немає латинських літер → ''.
	 * «nfhskrf» → «тарілка»; «rtkb[» → «келих».
	 */
	public static function layout($query) {
		$query = mb_strtolower((string)$query, 'UTF-8');

		if (!preg_match('/[a-z]/', $query)) {
			return '';
		}

		return strtr($query, self::$layout);
	}

	/**
	 * Список синонімів з адмінки → групи слів. Рядок: «келих = фужер, бокал» або «келих, фужер, бокал».
	 * Порожні рядки, коментарі (#) і групи з одного слова пропускаються; кожен елемент — одне слово (перше).
	 * @return array [['келих', 'фужер', 'бокал'], ...]
	 */
	public static function synonyms($text) {
		$groups = array();
		$lines = preg_split('/\r\n|\r|\n/', html_entity_decode((string)$text, ENT_QUOTES, 'UTF-8'));

		foreach ($lines as $line) {
			$line = trim($line);

			if ($line === '' || $line[0] === '#') {
				continue;
			}

			$group = array();

			foreach (preg_split('/[=,;]/u', $line) as $item) {
				$words = self::words($item, 1);

				if ($words) {
					$group[$words[0]] = $words[0];
				}
			}

			if (count($group) > 1) {
				$groups[] = array_values($group);
			}

			if (count($groups) >= 200) {
				break;
			}
		}

		return $groups;
	}

	/**
	 * Префікси, будь-який з яких задовольняє слово запиту: саме слово + основи слів його групи синонімів.
	 * Група підходить, якщо її слово починається з префікса запиту (від 3 літер) або збігається з ним повністю.
	 */
	public static function variants($token, $groups) {
		$variants = array($token => $token);
		$long = mb_strlen($token, 'UTF-8') >= 3;

		foreach ($groups as $group) {
			$hit = false;

			foreach ($group as $word) {
				if ($word === $token || self::stem($word) === $token || ($long && mb_strpos($word, $token, 0, 'UTF-8') === 0)) {
					$hit = true;
					break;
				}
			}

			if ($hit) {
				foreach ($group as $word) {
					$stem = self::stem($word);
					$variants[$stem] = $stem;
				}
			}

			if (count($variants) >= 8) {
				break;
			}
		}

		return array_values($variants);
	}

	/**
	 * Ранг збігу (менше — вище, AC-5):
	 *   0 — назва починається із запиту; 1 — кожне слово запиту є початком слова назви; 2 — інше (артикул, синонім).
	 */
	public static function rank($name, $query, $tokens) {
		$name = self::normalize($name);
		$query = self::normalize($query);

		if ($query !== '' && mb_strpos($name, $query, 0, 'UTF-8') === 0) {
			return 0;
		}

		$words = explode(' ', $name);

		foreach ($tokens as $token) {
			$found = false;

			foreach ($words as $word) {
				if ($token !== '' && mb_strpos($word, $token, 0, 'UTF-8') === 0) {
					$found = true;
					break;
				}
			}

			if (!$found) {
				return 2;
			}
		}

		return 1;
	}

	/**
	 * Впорядкувати знайдене: ранг → «Хіт» → назва за українською абеткою.
	 * @param array $rows [['product_id', 'name', 'is_hit'], ...]
	 * @return array ті самі рядки з ключем 'rank'
	 */
	public static function sort($rows, $query, $tokens) {
		foreach ($rows as $i => $row) {
			$rows[$i]['rank'] = self::rank($row['name'], $query, $tokens);
			$rows[$i]['_key'] = self::sortKey($row['name']);
		}

		usort($rows, function ($a, $b) {
			if ($a['rank'] !== $b['rank']) {
				return $a['rank'] - $b['rank'];
			}

			$hit = (int)!empty($b['is_hit']) - (int)!empty($a['is_hit']);

			if ($hit !== 0) {
				return $hit;
			}

			$cmp = strcmp($a['_key'], $b['_key']);

			return $cmp !== 0 ? $cmp : (int)$a['product_id'] - (int)$b['product_id'];
		});

		foreach ($rows as $i => $row) {
			unset($rows[$i]['_key']);
		}

		return $rows;
	}

	/** Екранування для LIKE 'x%' (значення додатково проходить $db->escape()). */
	public static function likeEscape($value) {
		return addcslashes((string)$value, '\\%_');
	}

	/** Ключ сортування: літери української абетки → коди в її порядку (після цифр і латиниці). */
	private static function sortKey($name) {
		static $map = null;

		if ($map === null) {
			$map = array();
			$letters = preg_split('//u', self::ALPHABET, -1, PREG_SPLIT_NO_EMPTY);

			foreach ($letters as $i => $letter) {
				// 0x7F — після пробілу, цифр і латиниці; другий байт — місце в абетці
				$map[$letter] = chr(0x7F) . chr(0x41 + $i);
			}
		}

		return strtr(self::normalize($name), $map);
	}
}
