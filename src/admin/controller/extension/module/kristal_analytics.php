<?php
class ControllerExtensionModuleKristalAnalytics extends Controller {
	const CODE = 'module_kristal_analytics';
	const ROUTE = 'extension/module/kristal_analytics';

	private $error = array();

	public function index() {
		$this->load->language(self::ROUTE);
		$this->document->setTitle($this->language->get('heading_title'));

		$this->load->model('setting/setting');

		$token = $this->token();

		if (($this->request->server['REQUEST_METHOD'] == 'POST') && $this->validate()) {
			$this->model_setting_setting->editSetting(self::CODE, $this->request->post);
			\Kristal\Cache_key::flush($this->cache);

			$this->session->data['success'] = $this->language->get('text_success');
			$this->response->redirect($this->url->link(self::ROUTE, $token, true));
		}

		$data = array();

		$data['heading_title'] = $this->language->get('heading_title');
		$data['text_edit'] = $this->language->get('text_edit');
		$data['text_enabled'] = $this->language->get('text_enabled');
		$data['text_disabled'] = $this->language->get('text_disabled');
		$data['text_info'] = $this->language->get('text_info');

		$data['entry_status'] = $this->language->get('entry_status');
		$data['entry_gtm_id'] = $this->language->get('entry_gtm_id');
		$data['entry_ga4_id'] = $this->language->get('entry_ga4_id');
		$data['entry_consent'] = $this->language->get('entry_consent');

		$data['help_gtm_id'] = $this->language->get('help_gtm_id');
		$data['help_ga4_id'] = $this->language->get('help_ga4_id');
		$data['help_consent'] = $this->language->get('help_consent');

		$data['button_save'] = $this->language->get('button_save');
		$data['button_cancel'] = $this->language->get('button_cancel');

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
			'href' => $this->url->link('common/dashboard', $token, true)
		);
		$data['breadcrumbs'][] = array(
			'text' => $this->language->get('text_extension'),
			'href' => $this->url->link('marketplace/extension', $token . '&type=module', true)
		);
		$data['breadcrumbs'][] = array(
			'text' => $this->language->get('heading_title'),
			'href' => $this->url->link(self::ROUTE, $token, true)
		);

		$data['action'] = $this->url->link(self::ROUTE, $token, true);
		$data['cancel'] = $this->url->link('marketplace/extension', $token . '&type=module', true);

		$fields = array(
			'module_kristal_analytics_status'  => 1,
			'module_kristal_analytics_gtm_id'  => '',
			'module_kristal_analytics_ga4_id'  => '',
			'module_kristal_analytics_consent' => 1
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
