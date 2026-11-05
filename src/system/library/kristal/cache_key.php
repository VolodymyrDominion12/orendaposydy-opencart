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

	public static function flush($cache) {
		$cache->delete(self::PREFIX);
	}
}
