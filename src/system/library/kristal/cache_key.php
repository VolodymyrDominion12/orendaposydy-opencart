<?php
namespace Kristal;

/**
 * Ключі кешу модулів «Крістал». Усі починаються з `kristal.`, тож flush() прибирає їх разом
 * (Cache\File::delete('kristal') видаляє файли cache.kristal.*).
 * Фіча 019, PHP 7.3+.
 */
class Cache_key {
	const PREFIX = 'kristal';
	const NAP = 'kristal.nap';
	/** Меню теми (003): kristal.menu.<store_id>.<language_id> */
	const MENU = 'kristal.menu';

	public static function menu($store_id, $language_id) {
		return self::MENU . '.' . (int)$store_id . '.' . (int)$language_id;
	}

	public static function flush($cache) {
		$cache->delete(self::PREFIX);
	}
}
