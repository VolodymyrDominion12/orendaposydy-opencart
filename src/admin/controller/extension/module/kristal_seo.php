<?php
class ControllerExtensionModuleKristalSeo extends Controller {
	const CODE = 'module_kristal_seo';
	const ROUTE = 'extension/module/kristal_seo';

	private $error = array();

	public function index() {
		$this->load->language(self::ROUTE);
		$this->document->setTitle($this->language->get('heading_title'));

		$this->load->model('setting/setting');

		if (($this->request->server['REQUEST_METHOD'] == 'POST') && $this->validate()) {
			$this->model_setting_setting->editSetting(self::CODE, $this->request->post);
			\Kristal\Cache_key::flush($this->cache);

			$this->session->data['success'] = $this->language->get('text_success');
			$this->response->redirect($this->url->link(self::ROUTE, $this->token(), true));
		}

		$data = array();

		$data['heading_title'] = $this->language->get('heading_title');
		$data['text_edit'] = $this->language->get('text_edit');
		$data['text_enabled'] = $this->language->get('text_enabled');
		$data['text_disabled'] = $this->language->get('text_disabled');
		$data['text_variables'] = $this->language->get('text_variables');

		$data['entry_status'] = $this->language->get('entry_status');
		$data['entry_category_title'] = $this->language->get('entry_category_title');
		$data['entry_category_description'] = $this->language->get('entry_category_description');
		$data['entry_product_title'] = $this->language->get('entry_product_title');
		$data['entry_product_description'] = $this->language->get('entry_product_description');

		$data['button_save'] = $this->language->get('button_save');
		$data['button_cancel'] = $this->language->get('button_cancel');
		$data['button_flush_cache'] = $this->language->get('button_flush_cache');

		$data['sitemap_url'] = HTTP_CATALOG . 'sitemap.xml';

		if (isset($this->session->data['success'])) {
			$data['success'] = $this->session->data['success'];
			unset($this->session->data['success']);
		} else {
			$data['success'] = '';
		}

		if (isset($this->error['warning'])) {
			$data['error_warning'] = $this->error['warning'];
		} else {
			$data['error_warning'] = '';
		}

		$data['breadcrumbs'] = array();
		$data['breadcrumbs'][] = array(
			'text' => $this->language->get('text_home'),
			'href' => $this->url->link('common/dashboard', $this->token(), true)
		);
		$data['breadcrumbs'][] = array(
			'text' => $this->language->get('text_extension'),
			'href' => $this->url->link('marketplace/extension', $this->token() . '&type=module', true)
		);
		$data['breadcrumbs'][] = array(
			'text' => $this->language->get('heading_title'),
			'href' => $this->url->link(self::ROUTE, $this->token(), true)
		);

		$data['action'] = $this->url->link(self::ROUTE, $this->token(), true);
		$data['cancel'] = $this->url->link('marketplace/extension', $this->token() . '&type=module', true);
		$data['flush_action'] = $this->url->link(self::ROUTE . '/flush', $this->token(), true);

		// Значення полів
		$fields = array(
			'module_kristal_seo_status'               => 1,
			'module_kristal_seo_category_title'       => '{name} у Львові — оренда та прокат | {store_name}',
			'module_kristal_seo_category_description' => 'Оренда {name} у Львові за вигідною ціною від {min_price} ₴/добу. Великий вибір посуду та обладнання для подій від «Крістал».',
			'module_kristal_seo_product_title'        => '{name} — оренда та прокат у Львові | {store_name}',
			'module_kristal_seo_product_description'  => 'Оренда {name} у Львові за ціною від {min_price} ₴/добу. Оренда посуду, меблів та декору від компанії «Крістал». Замовляйте онлайн!'
		);

		foreach ($fields as $key => $default) {
			if (isset($this->request->post[$key])) {
				$data[$key] = $this->request->post[$key];
			} elseif ($this->config->has($key)) {
				$data[$key] = $this->config->get($key);
			} else {
				$data[$key] = $default;
			}
		}

		$data['header'] = $this->load->controller('common/header');
		$data['column_left'] = $this->load->controller('common/column_left');
		$data['footer'] = $this->load->controller('common/footer');

		$this->response->setOutput($this->load->view(self::ROUTE, $data));
	}

	public function flush() {
		if (!$this->user->hasPermission('modify', self::ROUTE)) {
			$this->session->data['error'] = $this->language->get('error_permission');
		} else {
			$this->load->language(self::ROUTE);
			\Kristal\Cache_key::flush($this->cache);
			$this->session->data['success'] = $this->language->get('text_flush_success');
		}

		$this->response->redirect($this->url->link(self::ROUTE, $this->token(), true));
	}

	private function token() {
		return isset($this->session->data['user_token'])
			? 'user_token=' . $this->session->data['user_token']
			: 'token=' . $this->session->data['token'];
	}

	protected function validate() {
		if (!$this->user->hasPermission('modify', self::ROUTE)) {
			$this->error['warning'] = $this->language->get('error_permission');
		}

		return !$this->error;
	}
}
