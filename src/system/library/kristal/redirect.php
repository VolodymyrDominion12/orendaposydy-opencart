<?php
namespace Kristal;

/**
 * Бібліотека 301-редиректів та журналу 404.
 * Фіча 002, PHP 7.3+.
 */
class Redirect {
	/**
	 * Нормалізація шляху: початковий '/', без кінцевого '/' (крім кореня), нижній регістр.
	 *
	 * @param string $path
	 * @return string
	 */
	public static function normalize($path) {
		$parsed = parse_url((string)$path, PHP_URL_PATH);
		if ($parsed === null || $parsed === false) {
			$parsed = (string)$path;
		}

		$clean = urldecode($parsed);
		$clean = trim($clean);

		if ($clean === '' || $clean === '/') {
			return '/';
		}

		$clean = '/' . ltrim($clean, '/');
		$clean = rtrim($clean, '/');

		return mb_strtolower($clean, 'UTF-8');
	}

	/**
	 * Отримання списку активних правил редиректів з кешу.
	 *
	 * @param object $db
	 * @param object|null $cache
	 * @return array
	 */
	public static function getRules($db, $cache = null) {
		$cache_key = 'kristal.redirects';

		if ($cache) {
			$cached = $cache->get($cache_key);
			if (is_array($cached)) {
				return $cached;
			}
		}

		$rules = array();

		$query = $db->query("SELECT `redirect_id`, `old_path`, `new_path`, `code` FROM `" . DB_PREFIX . "kristal_redirect` WHERE `status` = '1'");

		foreach ($query->rows as $row) {
			$norm_old = self::normalize($row['old_path']);
			$rules[$norm_old] = array(
				'id'       => (int)$row['redirect_id'],
				'new_path' => (string)$row['new_path'],
				'code'     => (int)$row['code']
			);
		}

		if ($cache) {
			$cache->set($cache_key, $rules);
		}

		return $rules;
	}

	/**
	 * Фіксація спрацювання редиректу.
	 *
	 * @param object $db
	 * @param int $redirect_id
	 */
	public static function recordHit($db, $redirect_id) {
		$redirect_id = (int)$redirect_id;
		if ($redirect_id <= 0) {
			return;
		}

		$db->query("UPDATE `" . DB_PREFIX . "kristal_redirect` SET `hits` = `hits` + 1, `last_hit_at` = NOW() WHERE `redirect_id` = '" . $redirect_id . "'");
	}

	/**
	 * Запис 404 у журнал без персональних даних (ігноруючи статичні ресурси).
	 *
	 * @param object $db
	 * @param string $path
	 * @param string $referer
	 */
	public static function log404($db, $path, $referer = '') {
		$norm_path = self::normalize($path);

		if ($norm_path === '/' || strlen($norm_path) > 250) {
			return;
		}

		// Ігноруємо картинки, шрифти, стилі та скрипти
		$ext = strtolower(pathinfo($norm_path, PATHINFO_EXTENSION));
		$ignored_exts = array('png', 'jpg', 'jpeg', 'gif', 'webp', 'svg', 'ico', 'css', 'js', 'map', 'woff', 'woff2', 'ttf');
		if (in_array($ext, $ignored_exts)) {
			return;
		}

		$clean_referer = substr(strip_tags((string)$referer), 0, 255);

		$sql = "INSERT INTO `" . DB_PREFIX . "kristal_404_log`
				(`path`, `hits`, `referer`, `last_at`)
				VALUES (
					'" . $db->escape($norm_path) . "',
					1,
					'" . $db->escape($clean_referer) . "',
					NOW()
				)
				ON DUPLICATE KEY UPDATE
					`hits` = `hits` + 1,
					`last_at` = NOW(),
					`referer` = IF(VALUES(`referer`) != '', VALUES(`referer`), `referer`)";

		$db->query($sql);
	}
}
