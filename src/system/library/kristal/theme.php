<?php
namespace Kristal;

/**
 * Чисті функції теми `kristal` (фіча 003): дерево меню з плоского списку категорій,
 * графік роботи текстом, іконка категорії за ЧПУ. Без БД і без реєстру — тестуються в tests/lib/theme_test.php.
 * PHP 7.3+.
 */
class Theme {
	/** ЧПУ верхньої категорії → id символу в SVG-спрайті теми (мок-категорії 001). Невідома → 'box'. */
	private static $icons = array(
		'posud'                => 'plate',
		'stolovi-prybory'      => 'cutlery',
		'sklo-ta-kelykhy'      => 'glass',
		'kukhonne-obladnannia' => 'pot',
		'kavove-obladnannia'   => 'coffee',
		'barne-obladnannia'    => 'bar',
		'mebli'                => 'chair',
		'tekstyl'              => 'textile',
		'shatry'               => 'tent',
		'dekor'                => 'decor',
		'ekoposud'             => 'leaf'
	);

	/** Чи вибрано тему kristal (каталог теми «Тема за замовчуванням» або окрема тема). $config — \Config ядра або будь-що з get(). */
	public static function active($config) {
		if ($config->get('config_theme') === 'default') {
			return $config->get('theme_default_directory') === 'kristal';
		}

		return $config->get('config_theme') === 'kristal';
	}

	/**
	 * Дворівневе дерево меню.
	 *
	 * @param array $rows [['category_id', 'parent_id', 'name'], ...] уже відсортовані (parent_id, sort_order, name)
	 * @return array [['category_id', 'name', 'children' => [['category_id', 'name'], ...]], ...]
	 *               Верхній рівень — рядки з parent_id = 0; діти — лише прямі нащадки верхніх; глибші й «сироти» відкидаються.
	 */
	public static function menuTree($rows) {
		$tree = array();
		$index = array();

		foreach ($rows as $row) {
			if ((int)$row['parent_id'] === 0) {
				$id = (int)$row['category_id'];
				$index[$id] = count($tree);
				$tree[] = array('category_id' => $id, 'name' => (string)$row['name'], 'children' => array());
			}
		}

		foreach ($rows as $row) {
			$parent = (int)$row['parent_id'];

			if ($parent !== 0 && isset($index[$parent])) {
				$tree[$index[$parent]]['children'][] = array('category_id' => (int)$row['category_id'], 'name' => (string)$row['name']);
			}
		}

		return $tree;
	}

	/** Останній сегмент шляху URL: 'https://x/posud/tarilky?a=1' → 'tarilky'; 'index.php?route=…' → '' */
	public static function slug($url) {
		$path = (string)parse_url((string)$url, PHP_URL_PATH);
		$slug = basename(rtrim($path, '/'));

		return ($slug === 'index.php' || $slug === '.') ? '' : $slug;
	}

	public static function icon($slug) {
		return isset(self::$icons[$slug]) ? self::$icons[$slug] : 'box';
	}

	/**
	 * Графік з \Kristal\Nap::hours() → рядки для людей.
	 *   [{days: [Mo..Su], from: '09:00', to: '20:00'}] → ['Щодня 09:00–20:00']
	 *   [{days: [Mo..Fr]}, {days: [Sa, Su]}]           → ['Пн–Пт 09:00–18:00', 'Сб, Нд 10:00–16:00']
	 *
	 * @param array $hours
	 * @param array $names ['everyday' => 'Щодня', 'Mo' => 'Пн', … 'Su' => 'Нд']
	 */
	public static function hoursText($hours, $names) {
		$order = Nap::dayCodes();
		$result = array();

		foreach ($hours as $row) {
			$days = array_values(array_intersect($order, $row['days']));

			if (!$days) {
				continue;
			}

			$time = $row['from'] . '–' . $row['to'];

			if (count($days) === 7) {
				$result[] = $names['everyday'] . ' ' . $time;
				continue;
			}

			// Послідовні дні → діапазони: 3+ підряд «Пн–Пт», 2 підряд «Сб, Нд»
			$groups = array();
			$current = array($days[0]);

			for ($i = 1, $n = count($days); $i < $n; $i++) {
				if (array_search($days[$i], $order) === array_search($days[$i - 1], $order) + 1) {
					$current[] = $days[$i];
				} else {
					$groups[] = $current;
					$current = array($days[$i]);
				}
			}

			$groups[] = $current;
			$parts = array();

			foreach ($groups as $group) {
				$first = $names[$group[0]];
				$last = $names[$group[count($group) - 1]];

				if (count($group) >= 3) {
					$parts[] = $first . '–' . $last;
				} elseif (count($group) === 2) {
					$parts[] = $first . ', ' . $last;
				} else {
					$parts[] = $first;
				}
			}

			$result[] = implode(', ', $parts) . ' ' . $time;
		}

		return $result;
	}
}
