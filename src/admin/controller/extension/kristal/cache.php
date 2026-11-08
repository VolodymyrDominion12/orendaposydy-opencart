<?php
/**
 * Скидання кешу теми «Крістал» після змін в адмінці (фіча 003).
 * Події kristal_menu_flush: admin/model/catalog/category/{add,edit,delete}Category/after → flushMenu().
 * Скидаємо весь kristal.* (меню всіх магазинів і мов) — зміни категорій рідкісні, а ключ один на магазин+мову.
 */
class ControllerExtensionKristalCache extends Controller {
	public function flushMenu(&$route, &$args, &$output = null) {
		\Kristal\Cache_key::flush($this->cache);

		return null;
	}
}
