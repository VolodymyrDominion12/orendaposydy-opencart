<?php
/**
 * Фільтри категорії (фіча 021): індекс категорії для відбору й лічильників і SEO-сторінки фільтрів.
 *
 * getIndex() — 3 запити на промах кешу (товари з GROUP_CONCAT значень, довідник значень, SEO-сторінки), 0 на повтор.
 * Кеш kristal.filter.<store>.<language>.<category> скидається з усім kristal.* (події адмінки kristal_filter_flush, модуль «Крістал: фільтри»).
 * Набір товарів — як у getProducts() ядра для категорії: прив'язані саме до неї, увімкнені, date_available <= NOW(), у магазині.
 */
class ModelExtensionKristalFilter extends Model {
	/**
	 * @return array [
	 *   'products' => [['id', 'price', 'sort', 'name' (нижній регістр), 'f' => [filter_id…]], …],
	 *   'values'   => [filter_id => ['g', 'group', 'name', 'slug', 'gsort']] у порядку показу (група, значення),
	 *   'slugs'    => [slug => filter_id],
	 *   'pages'    => [['id', 'key' => '12,40', 'keyword', 'h1', 'title', 'description', 'text'], …] (увімкнені)
	 * ]
	 */
	public function getIndex($category_id) {
		$category_id = (int)$category_id;
		$store_id = (int)$this->config->get('config_store_id');
		$language_id = (int)$this->config->get('config_language_id');
		$key = 'kristal.filter.' . $store_id . '.' . $language_id . '.' . $category_id;

		$cached = $this->cache->get($key);

		if (is_array($cached) && isset($cached['products'])) {
			return $cached;
		}

		$index = array('products' => array(), 'values' => array(), 'slugs' => array(), 'pages' => array());

		// ORDER BY NULL — без сортування групування (порядок не потрібен, сортує Filter::sort); GROUP_CONCAT: id значень товару (≤ 1024 байти за замовчуванням — це > 100 значень на товар)
		$query = $this->db->query("SELECT p.product_id, p.price, p.sort_order, pd.name, GROUP_CONCAT(pf.filter_id) AS fids
			FROM `" . DB_PREFIX . "product_to_category` p2c
			JOIN `" . DB_PREFIX . "product` p ON (p.product_id = p2c.product_id)
			JOIN `" . DB_PREFIX . "product_description` pd ON (pd.product_id = p.product_id AND pd.language_id = '" . $language_id . "')
			JOIN `" . DB_PREFIX . "product_to_store` p2s ON (p2s.product_id = p.product_id AND p2s.store_id = '" . $store_id . "')
			LEFT JOIN `" . DB_PREFIX . "product_filter` pf ON (pf.product_id = p.product_id)
			WHERE p2c.category_id = '" . $category_id . "' AND p.status = '1' AND p.date_available <= NOW()
			GROUP BY p.product_id ORDER BY NULL");

		$used = array();

		foreach ($query->rows as $row) {
			$fids = $row['fids'] !== null && $row['fids'] !== '' ? array_map('intval', explode(',', $row['fids'])) : array();

			foreach ($fids as $fid) {
				$used[$fid] = true;
			}

			$index['products'][] = array(
				'id'    => (int)$row['product_id'],
				'price' => (float)$row['price'],
				'sort'  => (int)$row['sort_order'],
				'name'  => mb_strtolower(html_entity_decode($row['name'], ENT_QUOTES, 'UTF-8'), 'UTF-8'),
				'f'     => $fids
			);
		}

		if ($used) {
			$query = $this->db->query("SELECT f.filter_id, f.filter_group_id, fd.name, fgd.name AS group_name
				FROM `" . DB_PREFIX . "filter` f
				JOIN `" . DB_PREFIX . "filter_description` fd ON (fd.filter_id = f.filter_id AND fd.language_id = '" . $language_id . "')
				JOIN `" . DB_PREFIX . "filter_group` fg ON (fg.filter_group_id = f.filter_group_id)
				JOIN `" . DB_PREFIX . "filter_group_description` fgd ON (fgd.filter_group_id = f.filter_group_id AND fgd.language_id = '" . $language_id . "')
				WHERE f.filter_id IN (" . implode(',', array_keys($used)) . ")
				ORDER BY fg.sort_order, LCASE(fgd.name), f.filter_group_id, f.sort_order, LCASE(fd.name)");

			foreach ($query->rows as $row) {
				$index['values'][(int)$row['filter_id']] = array(
					'g'     => (int)$row['filter_group_id'],
					'group' => html_entity_decode($row['group_name'], ENT_QUOTES, 'UTF-8'),
					'name'  => html_entity_decode($row['name'], ENT_QUOTES, 'UTF-8')
				);
			}

			foreach (\Kristal\Filter::slugs($index['values']) as $fid => $slug) {
				$index['values'][$fid]['slug'] = $slug;
				$index['slugs'][$slug] = $fid;
			}

			// Значення видаленої групи/без опису — прибрати з товарів, щоб лічильники не рахували невидиме
			foreach ($index['products'] as $i => $product) {
				$index['products'][$i]['f'] = array_values(array_filter($product['f'], function ($fid) use ($index) {
					return isset($index['values'][$fid]);
				}));
			}
		}

		$query = $this->db->query("SELECT filter_page_id, filter_ids, keyword, h1, title, description, `text`
			FROM `" . DB_PREFIX . "kristal_filter_page`
			WHERE category_id = '" . $category_id . "' AND status = '1'");

		foreach ($query->rows as $row) {
			$index['pages'][] = array(
				'id'          => (int)$row['filter_page_id'],
				'key'         => $row['filter_ids'],
				'keyword'     => $row['keyword'],
				'h1'          => $row['h1'],
				'title'       => $row['title'],
				'description' => $row['description'],
				'text'        => $row['text']
			);
		}

		$this->cache->set($key, $index);

		return $index;
	}

	/** SEO-сторінка категорії за ключем адреси (з індексу категорії, без окремого запиту на повтор) */
	public function getPageByKeyword($category_id, $keyword) {
		foreach ($this->getIndex($category_id)['pages'] as $page) {
			if ($page['keyword'] === $keyword) {
				return $page;
			}
		}

		return null;
	}
}
