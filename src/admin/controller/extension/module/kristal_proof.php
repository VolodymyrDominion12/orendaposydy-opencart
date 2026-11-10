<?php
/**
 * Контролер модуля адмінки «Крістал: портфоліо та відгуки» (kristal_proof, 014).
 */
class ControllerExtensionModuleKristalProof extends Controller {
	const ROUTE = 'extension/module/kristal_proof';

	private $error = array();

	private function token() {
		return 'user_token=' . $this->session->data['user_token'];
	}

	public function index() {
		$this->load->language(self::ROUTE);
		$this->document->setTitle($this->language->get('heading_title'));

		$this->load->model('extension/kristal/proof');
		$this->load->model('setting/setting');

		$token = $this->token();

		if ($this->request->server['REQUEST_METHOD'] == 'POST' && $this->validate()) {
			$action = isset($this->request->post['action']) ? $this->request->post['action'] : '';

			if ($action == 'add_case') {
				$case_data = array(
					'title'       => trim($this->request->post['title']),
					'slug'        => trim($this->request->post['slug']),
					'event_type'  => trim($this->request->post['event_type']),
					'guests'      => (int)$this->request->post['guests'],
					'location'    => trim($this->request->post['location']),
					'date_event'  => trim($this->request->post['date_event']),
					'summary'     => trim($this->request->post['summary']),
					'description' => trim($this->request->post['description']),
					'image'       => trim($this->request->post['image']),
					'sort_order'  => (int)$this->request->post['sort_order'],
					'status'      => isset($this->request->post['status']) ? (int)$this->request->post['status'] : 1
				);

				$this->model_extension_kristal_proof->addCase($case_data);
				$this->session->data['success'] = $this->language->get('text_success_case');
				$this->response->redirect($this->url->link(self::ROUTE, $token, true));
				return;
			} elseif ($action == 'add_testimonial') {
				$t_data = array(
					'author_name' => trim($this->request->post['author_name']),
					'author_role' => trim($this->request->post['author_role']),
					'rating'      => (int)$this->request->post['rating'],
					'text'        => trim($this->request->post['text']),
					'event_title' => trim($this->request->post['event_title']),
					'source'      => trim($this->request->post['source']),
					'source_url'  => trim($this->request->post['source_url']),
					'sort_order'  => (int)$this->request->post['sort_order'],
					'status'      => isset($this->request->post['status']) ? (int)$this->request->post['status'] : 1
				);

				$this->model_extension_kristal_proof->addTestimonial($t_data);
				$this->session->data['success'] = $this->language->get('text_success_testimonial');
				$this->response->redirect($this->url->link(self::ROUTE, $token, true));
				return;
			}
		}

		if (isset($this->request->get['delete_case'])) {
			$this->model_extension_kristal_proof->deleteCase((int)$this->request->get['delete_case']);
			$this->session->data['success'] = $this->language->get('text_success_case_delete');
			$this->response->redirect($this->url->link(self::ROUTE, $token, true));
			return;
		}

		if (isset($this->request->get['delete_testimonial'])) {
			$this->model_extension_kristal_proof->deleteTestimonial((int)$this->request->get['delete_testimonial']);
			$this->session->data['success'] = $this->language->get('text_success_testimonial_delete');
			$this->response->redirect($this->url->link(self::ROUTE, $token, true));
			return;
		}

		$data = array();
		$data['heading_title'] = $this->language->get('heading_title');

		if (isset($this->session->data['success'])) {
			$data['success'] = $this->session->data['success'];
			unset($this->session->data['success']);
		} else {
			$data['success'] = '';
		}

		$data['action'] = $this->url->link(self::ROUTE, $token, true);
		$data['cancel'] = $this->url->link('marketplace/extension', $token . '&type=module', true);

		// Список кейсів
		$cases = $this->model_extension_kristal_proof->getCases();
		$data['cases'] = array();
		foreach ($cases as $c) {
			$data['cases'][] = array(
				'case_id'    => $c['case_id'],
				'title'      => $c['title'],
				'event_type' => $c['event_type'],
				'guests'     => $c['guests'],
				'location'   => $c['location'],
				'status'     => $c['status'],
				'delete'     => $this->url->link(self::ROUTE, $token . '&delete_case=' . $c['case_id'], true)
			);
		}

		// Список відгуків
		$testimonials = $this->model_extension_kristal_proof->getTestimonials();
		$data['testimonials'] = array();
		foreach ($testimonials as $t) {
			$data['testimonials'][] = array(
				'testimonial_id' => $t['testimonial_id'],
				'author_name'    => $t['author_name'],
				'author_role'    => $t['author_role'],
				'rating'         => $t['rating'],
				'source'         => $t['source'],
				'status'         => $t['status'],
				'delete'         => $this->url->link(self::ROUTE, $token . '&delete_testimonial=' . $t['testimonial_id'], true)
			);
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

		$data['header'] = $this->load->controller('common/header');
		$data['column_left'] = $this->load->controller('common/column_left');
		$data['footer'] = $this->load->controller('common/footer');

		$this->response->setOutput($this->load->view('extension/module/kristal_proof', $data));
	}

	protected function validate() {
		if (!$this->user->hasPermission('modify', self::ROUTE)) {
			$this->error['warning'] = $this->language->get('error_permission');
		}

		return !$this->error;
	}
}
