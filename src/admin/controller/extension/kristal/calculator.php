<?php
/**
 * Контролер адмінки «Крістал: норми калькулятора» (фіча 008 kristal_calculator).
 * PHP 7.3+.
 */
class ControllerExtensionKristalCalculator extends Controller {
	private $error = array();

	public function index() {
		$this->load->language('extension/kristal/calculator');

		$this->document->setTitle($this->language->get('heading_title'));

		$this->load->model('extension/kristal/calculator');

		$this->getList();
	}

	public function add() {
		$this->load->language('extension/kristal/calculator');

		$this->document->setTitle($this->language->get('heading_title'));

		$this->load->model('extension/kristal/calculator');

		if (($this->request->server['REQUEST_METHOD'] == 'POST') && $this->validateForm()) {
			$this->model_extension_kristal_calculator->addNorm($this->request->post);

			$this->session->data['success'] = $this->language->get('text_success');

			$url = '';
			if (isset($this->request->get['filter_category'])) {
				$url .= '&filter_category=' . urlencode(html_entity_decode($this->request->get['filter_category'], ENT_QUOTES, 'UTF-8'));
			}

			$this->response->redirect($this->url->link('extension/kristal/calculator', 'user_token=' . $this->session->data['user_token'] . $url, true));
		}

		$this->getForm();
	}

	public function edit() {
		$this->load->language('extension/kristal/calculator');

		$this->document->setTitle($this->language->get('heading_title'));

		$this->load->model('extension/kristal/calculator');

		if (($this->request->server['REQUEST_METHOD'] == 'POST') && $this->validateForm()) {
			$this->model_extension_kristal_calculator->editNorm($this->request->get['norm_id'], $this->request->post);

			$this->session->data['success'] = $this->language->get('text_success');

			$url = '';
			if (isset($this->request->get['filter_category'])) {
				$url .= '&filter_category=' . urlencode(html_entity_decode($this->request->get['filter_category'], ENT_QUOTES, 'UTF-8'));
			}

			$this->response->redirect($this->url->link('extension/kristal/calculator', 'user_token=' . $this->session->data['user_token'] . $url, true));
		}

		$this->getForm();
	}

	public function delete() {
		$this->load->language('extension/kristal/calculator');

		$this->document->setTitle($this->language->get('heading_title'));

		$this->load->model('extension/kristal/calculator');

		if (isset($this->request->post['selected']) && $this->validateDelete()) {
			foreach ($this->request->post['selected'] as $norm_id) {
				$this->model_extension_kristal_calculator->deleteNorm($norm_id);
			}

			$this->session->data['success'] = $this->language->get('text_success');

			$this->response->redirect($this->url->link('extension/kristal/calculator', 'user_token=' . $this->session->data['user_token'], true));
		}

		$this->getList();
	}

	protected function getList() {
		$filter_category = isset($this->request->get['filter_category']) ? $this->request->get['filter_category'] : '';

		$url = '';
		if (isset($this->request->get['filter_category'])) {
			$url .= '&filter_category=' . urlencode(html_entity_decode($this->request->get['filter_category'], ENT_QUOTES, 'UTF-8'));
		}

		$data['breadcrumbs'] = array();
		$data['breadcrumbs'][] = array(
			'text' => $this->language->get('text_home'),
			'href' => $this->url->link('common/dashboard', 'user_token=' . $this->session->data['user_token'], true)
		);
		$data['breadcrumbs'][] = array(
			'text' => $this->language->get('heading_title'),
			'href' => $this->url->link('extension/kristal/calculator', 'user_token=' . $this->session->data['user_token'] . $url, true)
		);

		$data['add'] = $this->url->link('extension/kristal/calculator/add', 'user_token=' . $this->session->data['user_token'] . $url, true);
		$data['delete'] = $this->url->link('extension/kristal/calculator/delete', 'user_token=' . $this->session->data['user_token'] . $url, true);

		$filter_data = array(
			'filter_category' => $filter_category
		);

		$results = $this->model_extension_kristal_calculator->getNorms($filter_data);

		$data['norms'] = array();

		foreach ($results as $result) {
			$data['norms'][] = array(
				'norm_id'            => $result['norm_id'],
				'name'               => $result['name'],
				'category'           => $result['category_type'],
				'name_classic'       => !empty($result['name_classic']) ? $result['name_classic'] : '—',
				'name_royal'         => !empty($result['name_royal']) ? $result['name_royal'] : '—',
				'norm_banquet'       => $result['norm_banquet'],
				'norm_buffet'        => $result['norm_buffet'],
				'norm_coffee'        => $result['norm_coffee'],
				'pack_size'          => $result['pack_size'],
				'sort_order'         => $result['sort_order'],
				'status'             => $result['status'] ? $this->language->get('text_enabled') : $this->language->get('text_disabled'),
				'edit'               => $this->url->link('extension/kristal/calculator/edit', 'user_token=' . $this->session->data['user_token'] . '&norm_id=' . $result['norm_id'] . $url, true)
			);
		}

		$data['user_token'] = $this->session->data['user_token'];

		if (isset($this->error['warning'])) {
			$data['error_warning'] = $this->error['warning'];
		} else {
			$data['error_warning'] = '';
		}

		if (isset($this->session->data['success'])) {
			$data['success'] = $this->session->data['success'];
			unset($this->session->data['success']);
		} else {
			$data['success'] = '';
		}

		if (isset($this->request->post['selected'])) {
			$data['selected'] = (array)$this->request->post['selected'];
		} else {
			$data['selected'] = array();
		}

		$data['filter_category'] = $filter_category;

		$data['header'] = $this->load->controller('common/header');
		$data['column_left'] = $this->load->controller('common/column_left');
		$data['footer'] = $this->load->controller('common/footer');

		$this->response->setOutput($this->load->view('extension/kristal/calculator_list', $data));
	}

	protected function getForm() {
		$data['text_form'] = !isset($this->request->get['norm_id']) ? $this->language->get('text_add') : $this->language->get('text_edit');

		if (isset($this->error['warning'])) {
			$data['error_warning'] = $this->error['warning'];
		} else {
			$data['error_warning'] = '';
		}

		if (isset($this->error['name'])) {
			$data['error_name'] = $this->error['name'];
		} else {
			$data['error_name'] = '';
		}

		if (isset($this->error['product_classic'])) {
			$data['error_product_classic'] = $this->error['product_classic'];
		} else {
			$data['error_product_classic'] = '';
		}

		$data['breadcrumbs'] = array();
		$data['breadcrumbs'][] = array(
			'text' => $this->language->get('text_home'),
			'href' => $this->url->link('common/dashboard', 'user_token=' . $this->session->data['user_token'], true)
		);
		$data['breadcrumbs'][] = array(
			'text' => $this->language->get('heading_title'),
			'href' => $this->url->link('extension/kristal/calculator', 'user_token=' . $this->session->data['user_token'], true)
		);

		if (!isset($this->request->get['norm_id'])) {
			$data['action'] = $this->url->link('extension/kristal/calculator/add', 'user_token=' . $this->session->data['user_token'], true);
		} else {
			$data['action'] = $this->url->link('extension/kristal/calculator/edit', 'user_token=' . $this->session->data['user_token'] . '&norm_id=' . $this->request->get['norm_id'], true);
		}

		$data['cancel'] = $this->url->link('extension/kristal/calculator', 'user_token=' . $this->session->data['user_token'], true);

		if (isset($this->request->get['norm_id']) && ($this->request->server['REQUEST_METHOD'] != 'POST')) {
			$norm_info = $this->model_extension_kristal_calculator->getNorm($this->request->get['norm_id']);
		}

		$data['user_token'] = $this->session->data['user_token'];

		$fields = array(
			'category_type'      => 'plates',
			'name'               => '',
			'product_id_classic' => 0,
			'product_id_royal'   => 0,
			'norm_banquet'       => '1.00',
			'norm_buffet'        => '0.00',
			'norm_coffee'        => '0.00',
			'dish_rule'          => '',
			'drink_filter'       => '',
			'pack_size'          => 10,
			'sort_order'         => 0,
			'status'             => 1
		);

		foreach ($fields as $field => $default) {
			if (isset($this->request->post[$field])) {
				$data[$field] = $this->request->post[$field];
			} elseif (!empty($norm_info)) {
				$data[$field] = $norm_info[$field];
			} else {
				$data[$field] = $default;
			}
		}

		// Завантаження назв прив'язаних товарів
		$this->load->model('catalog/product');

		if ($data['product_id_classic']) {
			$prod_classic = $this->model_catalog_product->getProduct($data['product_id_classic']);
			$data['product_name_classic'] = $prod_classic ? $prod_classic['name'] : '';
		} else {
			$data['product_name_classic'] = '';
		}

		if ($data['product_id_royal']) {
			$prod_royal = $this->model_catalog_product->getProduct($data['product_id_royal']);
			$data['product_name_royal'] = $prod_royal ? $prod_royal['name'] : '';
		} else {
			$data['product_name_royal'] = '';
		}

		$data['header'] = $this->load->controller('common/header');
		$data['column_left'] = $this->load->controller('common/column_left');
		$data['footer'] = $this->load->controller('common/footer');

		$this->response->setOutput($this->load->view('extension/kristal/calculator_form', $data));
	}

	protected function validateForm() {
		if (!$this->user->hasPermission('modify', 'extension/kristal/calculator')) {
			$this->error['warning'] = $this->language->get('error_permission');
		}

		if ((utf8_strlen($this->request->post['name']) < 2) || (utf8_strlen($this->request->post['name']) > 128)) {
			$this->error['name'] = $this->language->get('error_name');
		}

		if (empty($this->request->post['product_id_classic'])) {
			$this->error['product_classic'] = $this->language->get('error_product_classic');
		}

		return !$this->error;
	}

	protected function validateDelete() {
		if (!$this->user->hasPermission('modify', 'extension/kristal/calculator')) {
			$this->error['warning'] = $this->language->get('error_permission');
		}

		return !$this->error;
	}

	/**
	 * Автодоповнення пошуку товарів для форми
	 */
	public function autocomplete() {
		$json = array();

		if (isset($this->request->get['filter_name'])) {
			$this->load->model('catalog/product');

			$filter_data = array(
				'filter_name' => $this->request->get['filter_name'],
				'sort'        => 'pd.name',
				'order'       => 'ASC',
				'start'       => 0,
				'limit'       => 10
			);

			$results = $this->model_catalog_product->getProducts($filter_data);

			foreach ($results as $result) {
				$json[] = array(
					'product_id' => $result['product_id'],
					'name'       => strip_tags(html_entity_decode($result['name'], ENT_QUOTES, 'UTF-8')),
					'price'      => $result['price']
				);
			}
		}

		$this->response->addHeader('Content-Type: application/json');
		$this->response->setOutput(json_encode($json));
	}

	/**
	 * Подія додавання пункту «Норми калькулятора» до меню «Каталог» в адмінці.
	 */
	public function menu(&$route, &$data) {
		if (!$this->user->hasPermission('access', 'extension/kristal/calculator')) {
			return null;
		}

		$this->load->language('extension/kristal/calculator');

		foreach ($data['menus'] as &$menu) {
			if (isset($menu['id']) && $menu['id'] === 'menu-catalog') {
				$menu['children'][] = array(
					'name'     => $this->language->get('heading_title'),
					'href'     => $this->url->link('extension/kristal/calculator', 'user_token=' . $this->session->data['user_token'], true),
					'children' => array()
				);
				break;
			}
		}

		return null;
	}
}
