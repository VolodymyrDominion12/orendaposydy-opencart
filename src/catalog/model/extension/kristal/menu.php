<?php
/**
 * Меню каталогу для теми «Крістал» (фіча 003).
 * Один запит на холодному кеші; у кеш кладемо готові href, бо до 011 кожен url->link() = запит oc_seo_url.
 * Кеш kristal.menu.<store>.<lang> скидають події адмінки на категорії (extension/kristal/cache/flushMenu).
 */
class ModelExtensionKristalMenu extends Model {
	public function getTree() {
		$store_id = (int)$this->config->get('config_store_id');
		$language_id = (int)$this->config->get('config_language_id');
		$key = \Kristal\Cache_key::menu($store_id, $language_id);

		$tree = $this->cache->get($key);

		if (is_array($tree)) {
			return $tree;
		}

		$query = $this->db->query("SELECT c.category_id, c.parent_id, cd.name
			FROM `" . DB_PREFIX . "category` c
			JOIN `" . DB_PREFIX . "category_description` cd ON (cd.category_id = c.category_id AND cd.language_id = '" . $language_id . "')
			JOIN `" . DB_PREFIX . "category_to_store` c2s ON (c2s.category_id = c.category_id AND c2s.store_id = '" . $store_id . "')
			WHERE c.status = '1' AND ((c.parent_id = '0' AND c.top = '1') OR c.parent_id > '0')
			ORDER BY c.parent_id, c.sort_order, LCASE(cd.name)");

		$tree = \Kristal\Theme::menuTree($query->rows);

		foreach ($tree as &$top) {
			$top['href'] = $this->url->link('product/category', 'path=' . $top['category_id']);
			$top['icon'] = \Kristal\Theme::icon(\Kristal\Theme::slug($top['href']));

			foreach ($top['children'] as &$child) {
				$child['href'] = $this->url->link('product/category', 'path=' . $top['category_id'] . '_' . $child['category_id']);
			}
			unset($child);
		}
		unset($top);

		$this->cache->set($key, $tree);

		return $tree;
	}
}
