<?php
/**
 * Контролер адмінки «Крістал: комплекти» (фіча 007 kristal_kit).
 * PHP 7.3+.
 */
class ControllerExtensionKristalKit extends Controller {
	private $error = array();

	public function index() {
		$this->load->language('extension/kristal/kit');

		$this->document->setTitle($this->language->get('heading_title'));

		$this->load->model('extension/kristal/kit');

		$this->getList();
	}

	public function add() {
		$this->load->language('extension/kristal/kit');

		$this->document->setTitle($this->language->get('heading_title'));

		$this->load->model('extension/kristal/kit');

		if (($this->request->server['REQUEST_METHOD'] == 'POST') && $this->validateForm()) {
			$this->model_extension_kristal_kit->addKit($this->request->post);

			$this->session->data['success'] = $this->language->get('text_success');

			$url = '';
			if (isset($this->request->get['filter_event_type'])) {
				$url .= '&filter_event_type=' . urlencode(html_entity_decode($this->request->get['filter_event_type'], ENT_QUOTES, 'UTF-8'));
			}

			$this->response->redirect($this->url->link('extension/kristal/kit', 'user_token=' . $this->session->data['user_token'] . $url, true));
		}

		$this->getForm();
	}

	public function edit() {
		$this->load->language('extension/kristal/kit');

		$this->document->setTitle($this->language->get('heading_title'));

		$this->load->model('extension/kristal/kit');

		if (($this->request->server['REQUEST_METHOD'] == 'POST') && $this->validateForm()) {
			$this->model_extension_kristal_kit->editKit($this->request->get['kit_id'], $this->request->post);

			$this->session->data['success'] = $this->language->get('text_success');

			$url = '';
			if (isset($this->request->get['filter_event_type'])) {
				$url .= '&filter_event_type=' . urlencode(html_entity_decode($this->request->get['filter_event_type'], ENT_QUOTES, 'UTF-8'));
			}

			$this->response->redirect($this->url->link('extension/kristal/kit', 'user_token=' . $this->session->data['user_token'] . $url, true));
		}

		$this->getForm();
	}

	public function delete() {
		$this->load->language('extension/kristal/kit');

		$this->document->setTitle($this->language->get('heading_title'));

		$this->load->model('extension/kristal/kit');

		if (isset($this->request->post['selected']) && $this->validateDelete()) {
			foreach ($this->request->post['selected'] as $kit_id) {
				$this->model_extension_kristal_kit->deleteKit($kit_id);
			}

			$this->session->data['success'] = $this->language->get('text_success');

			$this->response->redirect($this->url->link('extension/kristal/kit', 'user_token=' . $this->session->data['user_token'], true));
		}

		$this->getList();
	}

	protected function getList() {
		$filter_event_type = isset($this->request->get['filter_event_type']) ? $this->request->get['filter_event_type'] : '';
		$filter_status     = isset($this->request->get['filter_status']) ? $this->request->get['filter_status'] : '';

		$url = '';
		if (isset($this->request->get['filter_event_type'])) {
			$url .= '&filter_event_type=' . urlencode(html_entity_decode($this->request->get['filter_event_type'], ENT_QUOTES, 'UTF-8'));
		}
		if (isset($this->request->get['filter_status'])) {
			$url .= '&filter_status=' . $this->request->get['filter_status'];
		}

		$data['breadcrumbs'] = array();
		$data['breadcrumbs'][] = array(
			'text' => $this->language->get('text_home'),
			'href' => $this->url->link('common/dashboard', 'user_token=' . $this->session->data['user_token'], true)
		);
		$data['breadcrumbs'][] = array(
			'text' => $this->language->get('heading_title'),
			'href' => $this->url->link('extension/kristal/kit', 'user_token=' . $this->session->data['user_token'] . $url, true)
		);

		$data['add'] = $this->url->link('extension/kristal/kit/add', 'user_token=' . $this->session->data['user_token'] . $url, true);
		$data['delete'] = $this->url->link('extension/kristal/kit/delete', 'user_token=' . $this->session->data['user_token'] . $url, true);

		$data['kits'] = array();

		$filter_data = array(
			'filter_event_type' => $filter_event_type,
			'filter_status'     => $filter_status
		);

		$results = $this->model_extension_kristal_kit->getKits($filter_data);

		foreach ($results as $result) {
			$data['kits'][] = array(
				'kit_id'       => $result['kit_id'],
				'code'         => $result['code'],
				'event_type'   => $this->language->get('text_event_' . $result['event_type']),
				'tier'         => $this->language->get('text_tier_' . $result['tier']),
				'name'         => $result['name'],
				'badge'        => $result['badge'],
				'total_items'  => $result['total_items'],
				'discount_pct' => $result['discount_pct'],
				'status'       => $result['status'] ? $this->language->get('text_enabled') : $this->language->get('text_disabled'),
				'sort_order'   => $result['sort_order'],
				'edit'         => $this->url->link('extension/kristal/kit/edit', 'user_token=' . $this->session->data['user_token'] . '&kit_id=' . $result['kit_id'] . $url, true)
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

		$data['filter_event_type'] = $filter_event_type;
		$data['filter_status'] = $filter_status;

		$data['header'] = $this->load->controller('common/header');
		$data['column_left'] = $this->load->controller('common/column_left');
		$data['footer'] = $this->load->controller('common/footer');

		$this->response->setOutput($this->load->view('extension/kristal/kit_list', $data));
	}

	protected function getForm() {
		$data['text_form'] = !isset($this->request->get['kit_id']) ? $this->language->get('text_add') : $this->language->get('text_edit');

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

		if (isset($this->error['code'])) {
			$data['error_code'] = $this->error['code'];
		} else {
			$data['error_code'] = '';
		}

		$url = '';
		if (isset($this->request->get['filter_event_type'])) {
			$url .= '&filter_event_type=' . urlencode(html_entity_decode($this->request->get['filter_event_type'], ENT_QUOTES, 'UTF-8'));
		}

		$data['breadcrumbs'] = array();
		$data['breadcrumbs'][] = array(
			'text' => $this->language->get('text_home'),
			'href' => $this->url->link('common/dashboard', 'user_token=' . $this->session->data['user_token'], true)
		);
		$data['breadcrumbs'][] = array(
			'text' => $this->language->get('heading_title'),
			'href' => $this->url->link('extension/kristal/kit', 'user_token=' . $this->session->data['user_token'] . $url, true)
		);

		if (!isset($this->request->get['kit_id'])) {
			$data['action'] = $this->url->link('extension/kristal/kit/add', 'user_token=' . $this->session->data['user_token'] . $url, true);
		} else {
			$data['action'] = $this->url->link('extension/kristal/kit/edit', 'user_token=' . $this->session->data['user_token'] . '&kit_id=' . $this->request->get['kit_id'] . $url, true);
		}

		$data['cancel'] = $this->url->link('extension/kristal/kit', 'user_token=' . $this->session->data['user_token'] . $url, true);

		if (isset($this->request->get['kit_id']) && ($this->request->server['REQUEST_METHOD'] != 'POST')) {
			$kit_info = $this->model_extension_kristal_kit->getKit($this->request->get['kit_id']);
		}

		$data['user_token'] = $this->session->data['user_token'];

		if (isset($this->request->post['code'])) {
			$data['code'] = $this->request->post['code'];
		} elseif (!empty($kit_info)) {
			$data['code'] = $kit_info['code'];
		} else {
			$data['code'] = '';
		}

		if (isset($this->request->post['name'])) {
			$data['name'] = $this->request->post['name'];
		} elseif (!empty($kit_info)) {
			$data['name'] = $kit_info['name'];
		} else {
			$data['name'] = '';
		}

		if (isset($this->request->post['event_type'])) {
			$data['event_type'] = $this->request->post['event_type'];
		} elseif (!empty($kit_info)) {
			$data['event_type'] = $kit_info['event_type'];
		} else {
			$data['event_type'] = 'wedding';
		}

		if (isset($this->request->post['tier'])) {
			$data['tier'] = $this->request->post['tier'];
		} elseif (!empty($kit_info)) {
			$data['tier'] = $kit_info['tier'];
		} else {
			$data['tier'] = 'standard';
		}

		if (isset($this->request->post['badge'])) {
			$data['badge'] = $this->request->post['badge'];
		} elseif (!empty($kit_info)) {
			$data['badge'] = $kit_info['badge'];
		} else {
			$data['badge'] = '';
		}

		if (isset($this->request->post['discount_pct'])) {
			$data['discount_pct'] = $this->request->post['discount_pct'];
		} elseif (!empty($kit_info)) {
			$data['discount_pct'] = $kit_info['discount_pct'];
		} else {
			$data['discount_pct'] = '0.00';
		}

		if (isset($this->request->post['features'])) {
			$data['features'] = $this->request->post['features'];
		} elseif (!empty($kit_info)) {
			$data['features'] = $kit_info['features'];
		} else {
			$data['features'] = '[]';
		}

		if (isset($this->request->post['sort_order'])) {
			$data['sort_order'] = $this->request->post['sort_order'];
		} elseif (!empty($kit_info)) {
			$data['sort_order'] = $kit_info['sort_order'];
		} else {
			$data['sort_order'] = 0;
		}

		if (isset($this->request->post['status'])) {
			$data['status'] = $this->request->post['status'];
		} elseif (!empty($kit_info)) {
			$data['status'] = $kit_info['status'];
		} else {
			$data['status'] = 1;
		}

		// Товари комплекту
		if (isset($this->request->post['items'])) {
			$data['items'] = $this->request->post['items'];
		} elseif (isset($this->request->get['kit_id'])) {
			$data['items'] = $this->model_extension_kristal_kit->getKitItems($this->request->get['kit_id']);
		} else {
			$data['items'] = array();
		}

		$data['header'] = $this->load->controller('common/header');
		$data['column_left'] = $this->load->controller('common/column_left');
		$data['footer'] = $this->load->controller('common/footer');

		$this->response->setOutput($this->load->view('extension/kristal/kit_form', $data));
	}

	protected function validateForm() {
		if (!$this->user->hasPermission('modify', 'extension/kristal/kit')) {
			$this->error['warning'] = $this->language->get('error_permission');
		}

		if ((utf8_strlen(trim($this->request->post['name'])) < 2) || (utf8_strlen(trim($this->request->post['name'])) > 128)) {
			$this->error['name'] = $this->language->get('error_name');
		}

		if ((utf8_strlen(trim($this->request->post['code'])) < 2) || (utf8_strlen(trim($this->request->post['code'])) > 32)) {
			$this->error['code'] = $this->language->get('error_code');
		}

		return !$this->error;
	}

	protected function validateDelete() {
		if (!$this->user->hasPermission('modify', 'extension/kristal/kit')) {
			$this->error['warning'] = $this->language->get('error_permission');
		}

		return !$this->error;
	}

	/**
	 * Автокомпліт для пошуку товарів при формуванні комплекту.
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
	 * Подія додавання пункту «Комплекти для подій» до меню «Каталог» в адмінці.
	 */
	public function menu(&$route, &$data) {
		if (!$this->user->hasPermission('access', 'extension/kristal/kit')) {
			return null;
		}

		$this->load->language('extension/kristal/kit');

		foreach ($data['menus'] as &$menu) {
			if (isset($menu['id']) && $menu['id'] === 'menu-catalog') {
				$menu['children'][] = array(
					'name'     => $this->language->get('heading_title'),
					'href'     => $this->url->link('extension/kristal/kit', 'user_token=' . $this->session->data['user_token'], true),
					'children' => array()
				);
				break;
			}
		}

		return null;
	}
}
