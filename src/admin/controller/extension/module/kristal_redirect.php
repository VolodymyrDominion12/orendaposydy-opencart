<?php
class ControllerExtensionModuleKristalRedirect extends Controller {
	const ROUTE = 'extension/module/kristal_redirect';

	private $error = array();

	public function index() {
		$this->load->language(self::ROUTE);
		$this->document->setTitle($this->language->get('heading_title'));

		$this->load->model('extension/kristal/redirect');

		$token = $this->token();

		if (($this->request->server['REQUEST_METHOD'] == 'POST') && $this->validate()) {
			$action = isset($this->request->post['action']) ? $this->request->post['action'] : '';

			if ($action == 'add') {
				$old_path = isset($this->request->post['old_path']) ? trim($this->request->post['old_path']) : '';
				$new_path = isset($this->request->post['new_path']) ? trim($this->request->post['new_path']) : '';
				$code = isset($this->request->post['code']) ? (int)$this->request->post['code'] : 301;
				$status = isset($this->request->post['status']) ? (int)$this->request->post['status'] : 1;

				if ($old_path === '') {
					$this->error['old_path'] = $this->language->get('error_old_path');
				}
				if ($new_path === '') {
					$this->error['new_path'] = $this->language->get('error_new_path');
				}

				if (!$this->error) {
					$this->model_extension_kristal_redirect->addRedirect(array(
						'old_path' => $old_path,
						'new_path' => $new_path,
						'code'     => $code,
						'status'   => $status
					));

					$this->session->data['success'] = $this->language->get('text_success');
					$this->response->redirect($this->url->link(self::ROUTE, $token, true));
				}
			}
		}

		$data = array();

		$data['heading_title'] = $this->language->get('heading_title');
		$data['text_edit'] = $this->language->get('text_edit');
		$data['text_list'] = $this->language->get('text_list');
		$data['text_404_list'] = $this->language->get('text_404_list');
		$data['text_no_results'] = $this->language->get('text_no_results');
		$data['text_confirm'] = $this->language->get('text_confirm');
		$data['text_enabled'] = $this->language->get('text_enabled');
		$data['text_disabled'] = $this->language->get('text_disabled');

		$data['column_old_path'] = $this->language->get('column_old_path');
		$data['column_new_path'] = $this->language->get('column_new_path');
		$data['column_code'] = $this->language->get('column_code');
		$data['column_hits'] = $this->language->get('column_hits');
		$data['column_last_hit_at'] = $this->language->get('column_last_hit_at');
		$data['column_status'] = $this->language->get('column_status');
		$data['column_action'] = $this->language->get('column_action');
		$data['column_path'] = $this->language->get('column_path');
		$data['column_referer'] = $this->language->get('column_referer');
		$data['column_last_at'] = $this->language->get('column_last_at');

		$data['entry_old_path'] = $this->language->get('entry_old_path');
		$data['entry_new_path'] = $this->language->get('entry_new_path');
		$data['entry_code'] = $this->language->get('entry_code');
		$data['entry_status'] = $this->language->get('entry_status');

		$data['button_add_redirect'] = $this->language->get('button_add_redirect');
		$data['button_flush_cache'] = $this->language->get('button_flush_cache');
		$data['button_clear_404'] = $this->language->get('button_clear_404');
		$data['button_create_redirect'] = $this->language->get('button_create_redirect');
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

		if (isset($this->error['old_path'])) {
			$data['error_old_path'] = $this->error['old_path'];
		} else {
			$data['error_old_path'] = '';
		}

		if (isset($this->error['new_path'])) {
			$data['error_new_path'] = $this->error['new_path'];
		} else {
			$data['error_new_path'] = '';
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
		$data['flush_action'] = $this->url->link(self::ROUTE . '/flush', $token, true);
		$data['clear_404_action'] = $this->url->link(self::ROUTE . '/clear404', $token, true);

		// Prefill form if requested (e.g. from 404 log)
		$data['prefill_old_path'] = isset($this->request->get['prefill_old']) ? (string)$this->request->get['prefill_old'] : '';

		// Get redirects
		$redirects_raw = $this->model_extension_kristal_redirect->getRedirects(array(
			'sort'  => 'hits',
			'order' => 'DESC',
			'start' => 0,
			'limit' => 100
		));

		$data['redirects'] = array();
		foreach ($redirects_raw as $r) {
			$data['redirects'][] = array(
				'redirect_id' => $r['redirect_id'],
				'old_path'    => $r['old_path'],
				'new_path'    => $r['new_path'],
				'code'        => $r['code'],
				'hits'        => (int)$r['hits'],
				'last_hit_at' => $r['last_hit_at'] ? date('d.m.Y H:i', strtotime($r['last_hit_at'])) : '—',
				'status'      => $r['status'] ? $this->language->get('text_enabled') : $this->language->get('text_disabled'),
				'delete'      => $this->url->link(self::ROUTE . '/delete', $token . '&redirect_id=' . $r['redirect_id'], true)
			);
		}

		// Get 404 logs
		$logs_raw = $this->model_extension_kristal_redirect->getLogs404(array(
			'sort'  => 'hits',
			'order' => 'DESC',
			'start' => 0,
			'limit' => 50
		));

		$data['logs404'] = array();
		foreach ($logs_raw as $l) {
			$data['logs404'][] = array(
				'path'    => $l['path'],
				'hits'    => (int)$l['hits'],
				'referer' => $l['referer'] ? $l['referer'] : '—',
				'last_at' => date('d.m.Y H:i', strtotime($l['last_at'])),
				'create'  => $this->url->link(self::ROUTE, $token . '&prefill_old=' . urlencode($l['path']), true)
			);
		}

		$data['header'] = $this->load->controller('common/header');
		$data['column_left'] = $this->load->controller('common/column_left');
		$data['footer'] = $this->load->controller('common/footer');

		$this->response->setOutput($this->load->view(self::ROUTE, $data));
	}

	public function delete() {
		$this->load->language(self::ROUTE);

		if (!$this->validate()) {
			$this->session->data['error'] = $this->language->get('error_permission');
		} else {
			$redirect_id = isset($this->request->get['redirect_id']) ? (int)$this->request->get['redirect_id'] : 0;
			if ($redirect_id > 0) {
				$this->load->model('extension/kristal/redirect');
				$this->model_extension_kristal_redirect->deleteRedirect($redirect_id);
				$this->session->data['success'] = $this->language->get('text_success');
			}
		}

		$this->response->redirect($this->url->link(self::ROUTE, $this->token(), true));
	}

	public function clear404() {
		$this->load->language(self::ROUTE);

		if (!$this->validate()) {
			$this->session->data['error'] = $this->language->get('error_permission');
		} else {
			$this->load->model('extension/kristal/redirect');
			$this->model_extension_kristal_redirect->clear404();
			$this->session->data['success'] = $this->language->get('text_cleared_404');
		}

		$this->response->redirect($this->url->link(self::ROUTE, $this->token(), true));
	}

	public function flush() {
		$this->load->language(self::ROUTE);

		if (!$this->validate()) {
			$this->session->data['error'] = $this->language->get('error_permission');
		} else {
			$this->load->model('extension/kristal/redirect');
			$this->model_extension_kristal_redirect->flushCache();
			$this->session->data['success'] = $this->language->get('text_cache_flushed');
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
