<?php
namespace Kristal;

/**
 * Фільтри категорії (фіча 021): чисті функції без БД — розбір адреси, канонічний вигляд, відбір, лічильники, межі ціни, сортування,
 * а також розбір атрибутів для початкового заповнення (складені значення, діапазони розмірів/об'єму).
 *
 * Індекс категорії (готує ModelExtensionKristalFilter::getIndex()):
 *   products: [['id' => 12, 'price' => 14.0, 'sort' => 0, 'name' => 'тарілка…' (нижній регістр), 'f' => [filter_id, …]], …]
 *   values:   [filter_id => ['g' => group_id, 'name' => 'Білий', 'group' => 'Колір', 'slug' => 'kolir-bilyi'], …] у порядку показу
 * Вибір: [group_id => [filter_id => true]]; ціна: [від, до] (цілі, 0 = без межі знизу, null — без межі зверху) або null.
 * PHP 7.3+.
 */
class Filter {
	/** Роздільник токенів у параметрі `filter` — його не кодує rawurlencode, у слагах його немає */
	const SEP = '_';
	/** Токен ціни: tsina-10-40, tsina-10-, tsina--40 */
	const PRICE = 'tsina';
	const MAX_TOKENS = 20;
	const PRICE_MAX = 1000000;

	/**
	 * Слаги значень: слаг групи + '-' + слаг назви. Збіг у межах групи (Білий / білий) → обидва з '-<filter_id>'.
	 * Група зі слагом 'tsina' (зарезервовано під ціну) → 'tsina-<group_id>'.
	 * @param array $values [filter_id => ['g' => group_id, 'group' => назва групи, 'name' => назва значення]]
	 * @return array [filter_id => slug]
	 */
	public static function slugs(array $values) {
		$slugs = array();
		$seen = array();

		foreach ($values as $fid => $value) {
			$group = Slug::make($value['group']);

			if ($group === '' || $group === self::PRICE) {
				$group = ($group === '' ? 'g' : $group) . '-' . (int)$value['g'];
			}

			$name = Slug::make($value['name']);
			$slug = $group . '-' . ($name === '' ? (string)(int)$fid : $name);
			$slugs[(int)$fid] = $slug;
			$seen[$slug][] = (int)$fid;
		}

		foreach ($seen as $slug => $fids) {
			if (count($fids) > 1) {
				foreach ($fids as $fid) {
					$slugs[$fid] = $slug . '-' . $fid;
				}
			}
		}

		return $slugs;
	}

	/**
	 * Розбір параметра `filter`: токени a-z0-9-, без повторів, ≤ 20; ціна — окремо.
	 * @return array ['slugs' => [...], 'price' => [від, до]|null]
	 */
	public static function parse($param) {
		$result = array('slugs' => array(), 'price' => null);

		if (!is_string($param) || $param === '') {
			return $result;
		}

		$tokens = explode(self::SEP, strtolower(substr($param, 0, 2000)));

		foreach ($tokens as $token) {
			if (count($result['slugs']) >= self::MAX_TOKENS) {
				break;
			}

			if (preg_match('/^' . self::PRICE . '-(\d*)-(\d*)$/', $token, $m)) {
				$result['price'] = self::price($m[1], $m[2]);
				continue;
			}

			if ($token !== '' && strlen($token) <= 140 && preg_match('/^[a-z0-9][a-z0-9-]*$/', $token) && !in_array($token, $result['slugs'], true)) {
				$result['slugs'][] = $token;
			}
		}

		return $result;
	}

	/**
	 * Межі ціни з полів «від–до» / токена: цілі ≥ 0, не більше PRICE_MAX; «від > до» — міняються місцями;
	 * нечислове — без межі. Обидві порожні → null.
	 */
	public static function price($from, $to) {
		$from = self::bound($from);
		$to = self::bound($to);

		// «до 0» (у т.ч. від'ємне) — межі немає: інакше порожній список без пояснення
		if ($to === 0) {
			$to = null;
		}

		if ($from === null && $to === null) {
			return null;
		}

		if ($from !== null && $to !== null && $from > $to) {
			$tmp = $from;
			$from = $to;
			$to = $tmp;
		}

		if ((int)$from === 0 && $to === null) {
			return null;
		}

		return array((int)$from, $to);
	}

	private static function bound($value) {
		if (!is_scalar($value)) {
			return null;
		}

		$value = trim(str_replace(array(' ', "\xC2\xA0", ','), array('', '', '.'), (string)$value));

		if ($value === '' || !is_numeric($value)) {
			return null;
		}

		return (int)min(self::PRICE_MAX, max(0, floor((float)$value)));
	}

	/**
	 * Слаги → вибір [group_id => [filter_id => true]]; невідомі слаги ігноруються.
	 * @param array $slug_map [slug => filter_id]
	 */
	public static function resolve(array $slugs, array $slug_map, array $values) {
		$selected = array();

		foreach ($slugs as $slug) {
			if (isset($slug_map[$slug])) {
				$fid = (int)$slug_map[$slug];

				if (isset($values[$fid])) {
					$selected[(int)$values[$fid]['g']][$fid] = true;
				}
			}
		}

		return $selected;
	}

	/** Вибір з id значень (SEO-сторінка, адмінка) */
	public static function fromIds(array $fids, array $values) {
		$selected = array();

		foreach ($fids as $fid) {
			$fid = (int)$fid;

			if (isset($values[$fid])) {
				$selected[(int)$values[$fid]['g']][$fid] = true;
			}
		}

		return $selected;
	}

	/** Відсортовані id вибраних значень: '12,40' — ключ SEO-сторінки */
	public static function key(array $selected) {
		$fids = array();

		foreach ($selected as $group) {
			foreach ($group as $fid => $on) {
				$fids[] = (int)$fid;
			}
		}

		sort($fids);

		return implode(',', $fids);
	}

	public static function count(array $selected) {
		$n = 0;

		foreach ($selected as $group) {
			$n += count($group);
		}

		return $n;
	}

	/**
	 * Канонічний параметр: значення в порядку показу ($values), ціна останньою. Порожній вибір → ''.
	 */
	public static function canonical(array $selected, $price, array $values) {
		$tokens = array();

		foreach ($values as $fid => $value) {
			if (isset($selected[(int)$value['g']][(int)$fid])) {
				$tokens[] = $value['slug'];
			}
		}

		if ($price) {
			$tokens[] = self::PRICE . '-' . ((int)$price[0] > 0 ? (int)$price[0] : '') . '-' . ($price[1] === null ? '' : (int)$price[1]);
		}

		return implode(self::SEP, $tokens);
	}

	/** Перемкнути значення у виборі (для посилань «один клік») */
	public static function toggle(array $selected, $fid, array $values) {
		$fid = (int)$fid;

		if (!isset($values[$fid])) {
			return $selected;
		}

		$gid = (int)$values[$fid]['g'];

		if (isset($selected[$gid][$fid])) {
			unset($selected[$gid][$fid]);

			if (!$selected[$gid]) {
				unset($selected[$gid]);
			}
		} else {
			$selected[$gid][$fid] = true;
		}

		return $selected;
	}

	/**
	 * Чи підходить товар: у кожній вибраній групі (крім $except_gid) є хоч одне вибране значення (АБО в групі, І між групами);
	 * ціна — якщо задана (товари без ціни при заданій ціні не підходять).
	 */
	public static function matches(array $product, array $selected, $price, $except_gid = null) {
		if ($price) {
			$p = (float)$product['price'];

			if ($p <= 0 || $p < $price[0] || ($price[1] !== null && $p > $price[1])) {
				return false;
			}
		}

		foreach ($selected as $gid => $fids) {
			if ($except_gid !== null && (int)$gid === (int)$except_gid) {
				continue;
			}

			$hit = false;

			foreach ($product['f'] as $fid) {
				if (isset($fids[$fid])) {
					$hit = true;
					break;
				}
			}

			if (!$hit) {
				return false;
			}
		}

		return true;
	}

	/** id товарів, що підходять, у порядку індексу */
	public static function select(array $products, array $selected, $price) {
		$ids = array();

		foreach ($products as $product) {
			if (self::matches($product, $selected, $price)) {
				$ids[] = (int)$product['id'];
			}
		}

		return $ids;
	}

	/**
	 * Лічильники: для кожного значення — скільки товарів буде, якщо його додатково відмітити
	 * (вибране в інших групах і ціна враховуються, у власній групі — ні: АБО).
	 * @return array [filter_id => n]
	 */
	public static function counts(array $products, array $values, array $selected, $price) {
		$counts = array_fill_keys(array_keys($values), 0);
		$gids = array();

		foreach ($values as $value) {
			$gids[(int)$value['g']] = true;
		}

		foreach ($products as $product) {
			// Для кожної групи окремо: чи проходить товар решту умов
			$pass = array();

			foreach ($gids as $gid => $on) {
				$pass[$gid] = self::matches($product, $selected, $price, $gid);
			}

			foreach ($product['f'] as $fid) {
				if (isset($values[$fid]) && $pass[(int)$values[$fid]['g']]) {
					$counts[$fid]++;
				}
			}
		}

		return $counts;
	}

	/** Найменша й найбільша ціна > 0 серед товарів, що проходять вибір (без урахування ціни). [0, 0] — цін немає. */
	public static function bounds(array $products, array $selected) {
		$min = null;
		$max = null;

		foreach ($products as $product) {
			$p = (float)$product['price'];

			if ($p <= 0 || !self::matches($product, $selected, null)) {
				continue;
			}

			$min = $min === null ? $p : min($min, $p);
			$max = $max === null ? $p : max($max, $p);
		}

		return array($min === null ? 0 : (int)floor($min), $max === null ? 0 : (int)ceil($max));
	}

	/**
	 * Групи для показу: ≥ 2 різні значення серед товарів категорії або є вибране.
	 * @return array [group_id => true]
	 */
	public static function visibleGroups(array $products, array $values, array $selected) {
		$used = array();

		foreach ($products as $product) {
			foreach ($product['f'] as $fid) {
				if (isset($values[$fid])) {
					$used[(int)$values[$fid]['g']][$fid] = true;
				}
			}
		}

		$groups = array();

		foreach ($used as $gid => $fids) {
			if (count($fids) >= 2 || !empty($selected[$gid])) {
				$groups[$gid] = true;
			}
		}

		foreach ($selected as $gid => $fids) {
			if ($fids) {
				$groups[(int)$gid] = true;
			}
		}

		return $groups;
	}

	/** Значення, що трапляються в товарах категорії: [filter_id => true] */
	public static function usedValues(array $products) {
		$used = array();

		foreach ($products as $product) {
			foreach ($product['f'] as $fid) {
				$used[(int)$fid] = true;
			}
		}

		return $used;
	}

	/**
	 * Сортування id як у getProducts() ядра: p.sort_order / p.price / pd.name, далі назва в тому ж напрямку; останнім — id.
	 * Невідоме поле (rating, p.model…) → p.sort_order.
	 */
	public static function sort(array $products, array $ids, $sort, $order) {
		$field = array('p.price' => 'price', 'pd.name' => 'name', 'p.sort_order' => 'sort');
		$key = isset($field[$sort]) ? $field[$sort] : 'sort';
		$dir = strtoupper((string)$order) === 'DESC' ? -1 : 1;
		$by_id = array();

		foreach ($products as $product) {
			$by_id[(int)$product['id']] = $product;
		}

		$ids = array_values(array_filter($ids, function ($id) use ($by_id) {
			return isset($by_id[$id]);
		}));

		usort($ids, function ($a, $b) use ($by_id, $key, $dir) {
			$pa = $by_id[$a];
			$pb = $by_id[$b];

			if ($key !== 'name') {
				$c = $pa[$key] <=> $pb[$key];

				if ($c !== 0) {
					return $c * $dir;
				}
			}

			$c = strcmp($pa['name'], $pb['name']);

			if ($c !== 0) {
				return $c * $dir;
			}

			return $a <=> $b;
		});

		return $ids;
	}

	// --- Початкове заповнення з атрибутів (AC-13) ----------------------------------------------

	/**
	 * Складене значення атрибута → окремі значення фільтра: «Скло, метал» → [«Скло», «Метал»].
	 * Роздільники — кома й крапка з комою поза лапками «…»; перша літера велика; без повторів (без урахування регістру).
	 * $details = false (матеріал): частини-уточнення відкидаються — з цифрами/%, «покриття», «ручка», «кран», «каркас»
	 * («Сталь, PVD-покриття» → [«Сталь»], «Алюміній, антипригарне покриття» → [«Алюміній»]).
	 */
	public static function splitValues($text, $details = true) {
		$text = trim(preg_replace('/\s+/u', ' ', html_entity_decode((string)$text, ENT_QUOTES, 'UTF-8')));

		if ($text === '') {
			return array();
		}

		$parts = preg_split('/[,;](?![^«]*»)/u', $text);
		$result = array();
		$seen = array();

		foreach ($parts as $part) {
			$part = trim($part, " \t.");

			if ($part === '' || mb_strlen($part, 'UTF-8') > 64) {
				continue;
			}

			if (!$details && $result && preg_match('/\d|%|покритт|ручк|кран|каркас/iu', $part)) {
				continue;
			}

			$part = mb_strtoupper(mb_substr($part, 0, 1, 'UTF-8'), 'UTF-8') . mb_substr($part, 1, null, 'UTF-8');
			$lc = mb_strtolower($part, 'UTF-8');

			if (!isset($seen[$lc])) {
				$seen[$lc] = true;
				$result[] = $part;
			}
		}

		return $result;
	}

	/**
	 * Розмір / об'єм → діапазон (питання 3): ['label' => '23–27 см', 'sort' => 2] або null, якщо не розпізнано.
	 *   size:   одне число «23 см», «Ø 22 см» або два виміри ≤ 60 см («26×26 см») — за більшим; меблі й текстиль (більше вимірів / > 60) не беремо
	 *   volume: «300 мл», «0,5 л», «5 л»
	 */
	public static function bucket($text, $kind) {
		$text = mb_strtolower(trim(html_entity_decode((string)$text, ENT_QUOTES, 'UTF-8')), 'UTF-8');
		$text = str_replace(array('ø', '*', 'х', ','), array('', '×', '×', '.'), $text);
		$text = preg_replace('/\s+/u', ' ', $text);

		if ($kind === 'size') {
			if (preg_match('/^(\d+(?:\.\d+)?) ?см$/u', trim($text), $m)) {
				$cm = (float)$m[1];
			} elseif (preg_match('/^(\d+(?:\.\d+)?) ?[×x] ?(\d+(?:\.\d+)?) ?см$/u', trim($text), $m) && max($m[1], $m[2]) <= 60) {
				$cm = max((float)$m[1], (float)$m[2]);
			} else {
				return null;
			}

			if ($cm <= 0) {
				return null;
			}

			if ($cm <= 22) {
				return array('label' => 'до 22 см', 'sort' => 1);
			}

			if ($cm <= 27) {
				return array('label' => '23–27 см', 'sort' => 2);
			}

			return array('label' => 'від 28 см', 'sort' => 3);
		}

		if ($kind === 'volume') {
			if (!preg_match('/^(\d+(?:\.\d+)?) ?(мл|л)$/u', trim($text), $m)) {
				return null;
			}

			$ml = (float)$m[1] * ($m[2] === 'л' ? 1000 : 1);

			if ($ml <= 0) {
				return null;
			}

			if ($ml <= 200) {
				return array('label' => 'до 200 мл', 'sort' => 1);
			}

			if ($ml <= 350) {
				return array('label' => '200–350 мл', 'sort' => 2);
			}

			if ($ml <= 1000) {
				return array('label' => '350 мл – 1 л', 'sort' => 3);
			}

			return array('label' => 'понад 1 л', 'sort' => 4);
		}

		return null;
	}
}
