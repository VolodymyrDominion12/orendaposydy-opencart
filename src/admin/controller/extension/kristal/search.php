<?php
/**
 * Індекс пошуку після змін в адмінці (фіча 027).
 * Події kristal_search_index (міграція 0010_kristal_search):
 *   admin/model/catalog/product/{add,edit,delete}Product/after    → product()
 *   admin/model/catalog/category/{add,edit,delete}Category/after  → category()
 * addX/after: id нового запису — $output; editX/deleteX: $args[0].
 * copyProduct не потрібен: копія створюється вимкненою, увімкнення — це editProduct.
 * Після зміни — скинути kristal.* (кеш результатів пошуку).
 */
class ControllerExtensionKristalSearch extends Controller {
	public function product(&$route, &$args, &$output) {
		$this->apply('p', $route, $args, $output);

		return null;
	}

	public function category(&$route, &$args, &$output) {
		$this->apply('c', $route, $args, $output);

		return null;
	}

	private function apply($type, $route, $args, $output) {
		$id = (strpos($route, '/add') !== false) ? (int)$output : (isset($args[0]) ? (int)$args[0] : 0);

		if ($id <= 0) {
			return;
		}

		$this->load->model('extension/kristal/search');

		if (strpos($route, '/delete') !== false) {
			$this->model_extension_kristal_search->deleteItem($type, $id);
		} elseif ($type === 'p') {
			$this->model_extension_kristal_search->indexProduct($id);
		} else {
			$this->model_extension_kristal_search->indexCategory($id);
		}

		\Kristal\Cache_key::flush($this->cache);
	}
}
