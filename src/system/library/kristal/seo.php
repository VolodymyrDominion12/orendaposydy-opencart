<?php
namespace Kristal;

/**
 * Бібліотека SEO: meta-шаблони, sitemap.xml, кеш ЧПУ, noindex/canonical.
 * Фіча 011, PHP 7.3+.
 */
class Seo {
	/**
	 * Підстановка змінних у шаблони title/description.
	 *
	 * @param string $template Шаблон (наприклад, "{name} у Львові — оренда та прокат | Крістал")
	 * @param array $vars Масив змінних ['name' => 'Тарілки', 'min_price' => '15', 'city' => 'Львів']
	 * @return string
	 */
	public static function renderTemplate($template, array $vars) {
		$template = (string)$template;

		if ($template === '') {
			return '';
		}

		$search = array();
		$replace = array();

		foreach ($vars as $key => $val) {
			$search[] = '{' . $key . '}';
			$replace[] = trim(strip_tags((string)$val));
		}

		$result = str_replace($search, $replace, $template);
		// Прибираємо подвійні пробіли
		$result = preg_replace('/\s+/', ' ', $result);

		return trim($result);
	}

	/**
	 * Завантаження повної карти ЧПУ (query <=> keyword) з кешуванням.
	 * Зменшує кількість SQL-запитів з 250+ до 1 на сторінку.
	 *
	 * @param object $db Об'єкт бази даних ($this->db)
	 * @param int $store_id
	 * @param int $language_id
	 * @param object|null $cache Об'єкт кешу ($this->cache)
	 * @return array ['q2k' => [...], 'k2q' => [...]]
	 */
	public static function getSeoUrlMap($db, $store_id, $language_id, $cache = null) {
		$cache_key = 'kristal.seo_url.' . (int)$store_id . '.' . (int)$language_id;

		if ($cache) {
			$cached = $cache->get($cache_key);
			if (is_array($cached) && isset($cached['q2k']) && isset($cached['k2q'])) {
				return $cached;
			}
		}

		$q2k = array();
		$k2q = array();

		$sql = "SELECT `query`, `keyword` FROM `" . DB_PREFIX . "seo_url`
				WHERE `store_id` = '" . (int)$store_id . "'
				AND `language_id` = '" . (int)$language_id . "'";

		$query = $db->query($sql);

		foreach ($query->rows as $row) {
			$q = (string)$row['query'];
			$k = (string)$row['keyword'];

			if ($q !== '' && $k !== '') {
				$q2k[$q] = $k;
				$k2q[$k] = $q;
			}
		}

		$data = array(
			'q2k' => $q2k,
			'k2q' => $k2q
		);

		if ($cache) {
			$cache->set($cache_key, $data);
		}

		return $data;
	}

	/**
	 * Перевірка, чи має маршрут закриватися від індексації (noindex, follow).
	 *
	 * @param string $route
	 * @return bool
	 */
	public static function isNoindexRoute($route) {
		$route = trim((string)$route, '/');

		if ($route === '') {
			return false;
		}

		$patterns = array(
			'checkout/',
			'extension/kristal/search',
			'extension/payment/',
			'account/',
			'affiliate/',
			'error/not_found'
		);

		foreach ($patterns as $pattern) {
			if (strpos($route, $pattern) === 0 || $route === trim($pattern, '/')) {
				return true;
			}
		}

		return false;
	}

	/**
	 * Очищення URL для rel="canonical" від трекінгових параметрів.
	 *
	 * @param string $url
	 * @return string
	 */
	public static function cleanCanonical($url) {
		$parts = parse_url($url);

		if (!$parts || !isset($parts['host'])) {
			return $url;
		}

		$clean = (isset($parts['scheme']) ? $parts['scheme'] : 'https') . '://' . $parts['host'];

		if (isset($parts['port'])) {
			$clean .= ':' . $parts['port'];
		}

		if (isset($parts['path'])) {
			$clean .= $parts['path'];
		}

		if (isset($parts['query'])) {
			parse_str($parts['query'], $params);

			// Прибираємо UTM, gclid, fbclid, сортування, ліміти
			$strip = array('utm_source', 'utm_medium', 'utm_campaign', 'utm_term', 'utm_content', 'gclid', 'fbclid', '_route_');

			foreach ($strip as $s) {
				unset($params[$s]);
			}

			if (!empty($params)) {
				$clean .= '?' . http_build_query($params);
			}
		}

		return $clean;
	}

	/**
	 * Генерація XML для sitemap.
	 *
	 * @param array $urls Список URL: [['loc' => ..., 'lastmod' => ..., 'changefreq' => ..., 'priority' => ...], ...]
	 * @return string
	 */
	public static function buildSitemapXml(array $urls) {
		$out = '<?xml version="1.0" encoding="UTF-8"?>' . "\n";
		$out .= '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">' . "\n";

		foreach ($urls as $item) {
			if (empty($item['loc'])) {
				continue;
			}

			$loc = htmlspecialchars((string)$item['loc'], ENT_QUOTES, 'UTF-8');
			$lastmod = !empty($item['lastmod']) ? substr((string)$item['lastmod'], 0, 10) : '';
			$changefreq = !empty($item['changefreq']) ? (string)$item['changefreq'] : 'weekly';
			$priority = !empty($item['priority']) ? (string)$item['priority'] : '0.7';

			$out .= "  <url>\n";
			$out .= "    <loc>" . $loc . "</loc>\n";

			if ($lastmod !== '') {
				$out .= "    <lastmod>" . $lastmod . "</lastmod>\n";
			}

			$out .= "    <changefreq>" . $changefreq . "</changefreq>\n";
			$out .= "    <priority>" . $priority . "</priority>\n";
			$out .= "  </url>\n";
		}

		$out .= '</urlset>';

		return $out;
	}
}
