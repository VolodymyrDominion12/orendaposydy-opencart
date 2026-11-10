<?php
/**
 * Контролер модуля адмінки «Крістал: Блог та статті» (kristal_blog, 013).
 */
class ControllerExtensionModuleKristalBlog extends Controller {
	const ROUTE = 'extension/module/kristal_blog';

	private $error = array();

	private function token() {
		return 'user_token=' . $this->session->data['user_token'];
	}

	public function index() {
		$this->load->language(self::ROUTE);
		$this->document->setTitle($this->language->get('heading_title'));

		$this->load->model('extension/kristal/blog');

		$token = $this->token();

		if ($this->request->server['REQUEST_METHOD'] == 'POST' && $this->validate()) {
			$action = isset($this->request->post['action']) ? $this->request->post['action'] : '';

			if ($action == 'add_post') {
				$post_data = array(
					'title'       => trim($this->request->post['title']),
					'slug'        => trim($this->request->post['slug']),
					'summary'     => trim($this->request->post['summary']),
					'content'     => trim($this->request->post['content']),
					'image'       => trim($this->request->post['image']),
					'author'      => trim($this->request->post['author']),
					'category_id' => (int)$this->request->post['category_id'],
					'sort_order'  => (int)$this->request->post['sort_order'],
					'status'      => isset($this->request->post['status']) ? (int)$this->request->post['status'] : 1
				);

				$this->model_extension_kristal_blog->addPost($post_data);
				$this->session->data['success'] = $this->language->get('text_success_post');
				$this->response->redirect($this->url->link(self::ROUTE, $token, true));
				return;
			}
		}

		if (isset($this->request->get['delete_post'])) {
			$this->model_extension_kristal_blog->deletePost((int)$this->request->get['delete_post']);
			$this->session->data['success'] = $this->language->get('text_success_delete');
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

		// Список статей
		$posts = $this->model_extension_kristal_blog->getPosts();
		$data['posts'] = array();
		foreach ($posts as $p) {
			$data['posts'][] = array(
				'post_id'        => $p['post_id'],
				'title'          => $p['title'],
				'category_title' => $p['category_title'],
				'author'         => $p['author'],
				'viewed'         => $p['viewed'],
				'status'         => $p['status'],
				'delete'         => $this->url->link(self::ROUTE, $token . '&delete_post=' . $p['post_id'], true)
			);
		}

		$data['categories'] = $this->model_extension_kristal_blog->getCategories();

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

		$this->response->setOutput($this->load->view('extension/module/kristal_blog', $data));
	}

	protected function validate() {
		if (!$this->user->hasPermission('modify', self::ROUTE)) {
			$this->error['warning'] = $this->language->get('error_permission');
		}

		return !$this->error;
	}
}
