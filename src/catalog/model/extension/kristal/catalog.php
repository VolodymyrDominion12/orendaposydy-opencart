<?php
/**
 * Дані оренди для вітрини (фіча 005). Усі запити — пакетом на сторінку (IN (...)), без N+1.
 */
class ModelExtensionKristalCatalog extends Model {
	/**
	 * Оренда, базова ціна, зображення й короткий опис для набору товарів — один запит.
	 * Короткий опис — поле `description_excerpt` (додане темою sauco, заповнюється формою товару в адмінці).
	 * @return array [product_id => row]
	 */
	public function getProducts($product_ids) {
		$ids = $this->ids($product_ids);

		if (!$ids) {
			return array();
		}

		$query = $this->db->query("SELECT p.product_id, p.sku, p.price, p.minimum, p.image, pd.description_excerpt,
				r.unit, r.deposit, r.breakage_price, r.washing_included, r.is_hit
			FROM `" . DB_PREFIX . "product` p
			LEFT JOIN `" . DB_PREFIX . "product_description` pd ON (pd.product_id = p.product_id AND pd.language_id = '" . (int)$this->config->get('config_language_id') . "')
			LEFT JOIN `" . DB_PREFIX . "kristal_product_rental` r ON (r.product_id = p.product_id)
			WHERE p.product_id IN (" . implode(',', $ids) . ")");

		$result = array();

		foreach ($query->rows as $row) {
			$result[(int)$row['product_id']] = $row;
		}

		return $result;
	}

	/**
	 * Знижки за обсяг (product_discount ядра) для набору товарів — один запит. Умови — як у кошику ядра.
	 * @return array [product_id => [['quantity' => 100, 'price' => 12.0], ...]]
	 */
	public function getDiscounts($product_ids) {
		$ids = $this->ids($product_ids);

		if (!$ids) {
			return array();
		}

		$customer_group_id = $this->customer->isLogged() ? (int)$this->customer->getGroupId() : (int)$this->config->get('config_customer_group_id');

		$query = $this->db->query("SELECT product_id, quantity, price
			FROM `" . DB_PREFIX . "product_discount`
			WHERE product_id IN (" . implode(',', $ids) . ")
			AND customer_group_id = '" . $customer_group_id . "'
			AND quantity > '1'
			AND ((date_start = '0000-00-00' OR date_start < NOW()) AND (date_end = '0000-00-00' OR date_end > NOW()))
			ORDER BY product_id, quantity, priority, price");

		$result = array();

		foreach ($query->rows as $row) {
			$result[(int)$row['product_id']][] = array('quantity' => (int)$row['quantity'], 'price' => (float)$row['price']);
		}

		return $result;
	}

	/** Додаткові фото товару (сирі шляхи для resize). */
	public function getImages($product_id) {
		$query = $this->db->query("SELECT image FROM `" . DB_PREFIX . "product_image`
			WHERE product_id = '" . (int)$product_id . "' ORDER BY sort_order LIMIT 12");

		return array_column($query->rows, 'image');
	}

	/** Найменша ціна > 0 серед увімкнених товарів категорії з підкатегоріями. Кеш kristal.catalog.min.<store>.<category>. */
	public function getMinPrice($category_id) {
		$store_id = (int)$this->config->get('config_store_id');
		$key = 'kristal.catalog.min.' . $store_id . '.' . (int)$category_id;

		$cached = $this->cache->get($key);

		if (is_array($cached)) {
			return $cached['price'];
		}

		$query = $this->db->query("SELECT MIN(p.price) AS price
			FROM `" . DB_PREFIX . "category_path` cp
			JOIN `" . DB_PREFIX . "product_to_category` p2c ON (p2c.category_id = cp.category_id)
			JOIN `" . DB_PREFIX . "product` p ON (p.product_id = p2c.product_id)
			JOIN `" . DB_PREFIX . "product_to_store` p2s ON (p2s.product_id = p.product_id AND p2s.store_id = '" . $store_id . "')
			WHERE cp.path_id = '" . (int)$category_id . "' AND p.status = '1' AND p.date_available <= NOW() AND p.price > '0'");

		$price = $query->row['price'] !== null ? (float)$query->row['price'] : 0.0;

		$this->cache->set($key, array('price' => $price));

		return $price;
	}

	private function ids($product_ids) {
		$ids = array();

		foreach ((array)$product_ids as $id) {
			if ((int)$id > 0) {
				$ids[(int)$id] = (int)$id;
			}
		}

		return array_values($ids);
	}
}
