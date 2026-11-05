<?php
class ControllerExtensionModuleCategory extends Controller {
	public function index() {
		$this->load->language('extension/module/category');

        $this->load->model('tool/image');

		if (isset($this->request->get['path'])) {
			$parts = explode('_', (string)$this->request->get['path']);
		} else {
			$parts = array();
		}

        $this->document->addStyle('catalog/view/theme/sauco/js/swiper/swiper.min.css');
        $this->document->addScript('catalog/view/theme/sauco/js/swiper/swiper.min.js');

		if (isset($parts[0])) {
			$data['category_id'] = $parts[0];
		} else {
			$data['category_id'] = 0;
		}

		$this->load->model('catalog/category');

		$this->load->model('catalog/product');

		$data['categories'] = array();

		$categories = $this->model_catalog_category->getCategories(0);

		foreach ($categories as $category) {

			$filter_data = array(
				'filter_category_id'  => $category['category_id'],
				'filter_sub_category' => true
			);

            if ($category['image']) {
                $image = $this->model_tool_image->resize($category['image'], 100, 100);
            } else {
                $image = $this->model_tool_image->resize('placeholder.png', 100, 100);
            }

			$data['categories'][] = array(
				'category_id' => $category['category_id'],
				'name'        => $category['name'] . ($this->config->get('config_product_count') ? ' (' . $this->model_catalog_product->getTotalProducts($filter_data) . ')' : ''),
				'image'       => $image,
				'href'        => $this->url->link('product/category', 'path=' . $category['category_id'])
			);
		}

		return $this->load->view('extension/module/category', $data);
	}
}