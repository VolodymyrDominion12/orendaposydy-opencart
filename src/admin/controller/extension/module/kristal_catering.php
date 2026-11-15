<?php
/**
 * Контролер адмінки «Крістал: Ми можемо для Вас приготувати» (фіча 028 kristal_catering).
 * PHP 7.3+.
 */
class ControllerExtensionModuleKristalCatering extends Controller {
	const CODE = 'module_kristal_catering';
	const ROUTE = 'extension/module/kristal_catering';

	private $error = array();

	public function index() {
		$this->load->language(self::ROUTE);
		$this->document->setTitle($this->language->get('heading_title'));
		$this->load->model('setting/setting');
		$this->load->model('extension/kristal/catering');
		$this->load->model('tool/image');

		$active_tab = isset($this->request->get['tab']) ? preg_replace('/[^a-z0-9_\-]/', '', (string)$this->request->get['tab']) : 'general';

		if ($this->request->server['REQUEST_METHOD'] == 'POST' && $this->validate()) {
			$save_mode = isset($this->request->post['save_mode']) ? (string)$this->request->post['save_mode'] : 'settings';
			if (isset($this->request->post['active_tab'])) {
				$active_tab = preg_replace('/[^a-z0-9_\-]/', '', (string)$this->request->post['active_tab']);
			}

			if ($save_mode === 'page' && !empty($this->request->post['page_id'])) {
				$this->model_extension_kristal_catering->savePage((int)$this->request->post['page_id'], $this->request->post);
			} else {
				$settings = array(
					self::CODE . '_status'      => !empty($this->request->post['status']) ? 1 : 0,
					self::CODE . '_show_header' => !empty($this->request->post['show_header']) ? 1 : 0,
					self::CODE . '_show_home'   => !empty($this->request->post['show_home']) ? 1 : 0
				);
				$this->model_setting_setting->editSetting(self::CODE, $settings);
			}

			\Kristal\Cache_key::flush($this->cache);
			$this->session->data['success'] = $this->language->get('text_success');

			$this->response->redirect($this->url->link(self::ROUTE, 'user_token=' . $this->session->data['user_token'] . '&tab=' . $active_tab, true));
		}

		$token = 'user_token=' . $this->session->data['user_token'];
		$data = array();

		if (isset($this->error['warning'])) {
			$data['error_warning'] = $this->error['warning'];
		} elseif (isset($this->session->data['error_warning'])) {
			$data['error_warning'] = $this->session->data['error_warning'];
			unset($this->session->data['error_warning']);
		} else {
			$data['error_warning'] = '';
		}
		$data['success'] = isset($this->session->data['success']) ? $this->session->data['success'] : '';
		unset($this->session->data['success']);

		$data['breadcrumbs'] = array(
			array('text' => $this->language->get('text_home'), 'href' => $this->url->link('common/dashboard', $token, true)),
			array('text' => $this->language->get('text_extension'), 'href' => $this->url->link('marketplace/extension', $token . '&type=module', true)),
			array('text' => $this->language->get('heading_title'), 'href' => $this->url->link(self::ROUTE, $token, true))
		);

		$data['action'] = $this->url->link(self::ROUTE, $token, true);
		$data['cancel'] = $this->url->link('marketplace/extension', $token . '&type=module', true);
		$data['user_token'] = $this->session->data['user_token'];
		$data['active_tab'] = $active_tab;

		$saved = $this->model_setting_setting->getSetting(self::CODE);
		$data['status'] = isset($saved[self::CODE . '_status']) ? (int)$saved[self::CODE . '_status'] : 1;
		$data['show_header'] = isset($saved[self::CODE . '_show_header']) ? (int)$saved[self::CODE . '_show_header'] : 1;
		$data['show_home'] = isset($saved[self::CODE . '_show_home']) ? (int)$saved[self::CODE . '_show_home'] : 1;

		$data['placeholder'] = $this->model_tool_image->resize('no_image.png', 100, 100);

		$pages = $this->model_extension_kristal_catering->getPages();
		foreach ($pages as &$page) {
			$page['facts_text'] = implode("\n", $page['facts_list']);
			$img = (string)$page['hero_image'];
			$page['thumb'] = $this->model_tool_image->resize($img !== '' && is_file(DIR_IMAGE . $img) ? $img : 'no_image.png', 100, 100);

			foreach ($page['dishes_list'] as &$d) {
				$d['items_text'] = !empty($d['items']) && is_array($d['items']) ? implode("\n", $d['items']) : '';
			}
			unset($d);

			foreach ($page['kits'] as &$k) {
				$lines = array();
				foreach ($k['items_list'] as $it) {
					if (!empty($it['text'])) {
						$lines[] = (!empty($it['included']) ? '' : '- ') . $it['text'];
					}
				}
				$k['items_text'] = implode("\n", $lines);
				$k['delete_href'] = $this->url->link(
					self::ROUTE . '/deleteKit',
					$token . '&kit_id=' . (int)$k['kit_id'] . '&tab=page_' . (int)$page['page_id'],
					true
				);
			}
			unset($k);
		}
		unset($page);

		$data['pages'] = $pages;

		$data['header'] = $this->load->controller('common/header');
		$data['column_left'] = $this->load->controller('common/column_left');
		$data['footer'] = $this->load->controller('common/footer');

		$this->response->setOutput($this->load->view(self::ROUTE, $data));
	}

	public function deleteKit() {
		$this->load->language(self::ROUTE);

		if (!$this->user->hasPermission('modify', self::ROUTE)) {
			$this->session->data['error_warning'] = $this->language->get('error_permission');
		} elseif (!empty($this->request->get['kit_id'])) {
			$this->load->model('extension/kristal/catering');
			$this->model_extension_kristal_catering->deleteKit((int)$this->request->get['kit_id']);
			\Kristal\Cache_key::flush($this->cache);
			$this->session->data['success'] = $this->language->get('text_kit_deleted');
		}

		$tab = isset($this->request->get['tab']) ? preg_replace('/[^a-z0-9_\-]/', '', (string)$this->request->get['tab']) : 'general';
		$this->response->redirect($this->url->link(self::ROUTE, 'user_token=' . $this->session->data['user_token'] . '&tab=' . $tab, true));
	}

	public function install() {
		$this->load->model('setting/setting');
		if (!$this->model_setting_setting->getSetting(self::CODE)) {
			$this->model_setting_setting->editSetting(self::CODE, array(
				self::CODE . '_status'      => 1,
				self::CODE . '_show_header' => 1,
				self::CODE . '_show_home'   => 1
			));
		}
	}

	public function uninstall() {
		$this->load->model('setting/setting');
		$this->model_setting_setting->deleteSetting(self::CODE);
		\Kristal\Cache_key::flush($this->cache);
	}

	/**
	 * Подія додавання пункту «Ми можемо для Вас приготувати» до меню «Каталог» в адмінці.
	 */
	public function menu(&$route, &$data) {
		if (!$this->user->hasPermission('access', self::ROUTE)) {
			return null;
		}

		$this->load->language(self::ROUTE);

		foreach ($data['menus'] as &$menu) {
			if (isset($menu['id']) && $menu['id'] === 'menu-catalog') {
				$menu['children'][] = array(
					'name'     => $this->language->get('text_menu_catering'),
					'href'     => $this->url->link(self::ROUTE, 'user_token=' . $this->session->data['user_token'], true),
					'children' => array()
				);
				break;
			}
		}

		return null;
	}

	private function validate() {
		if (!$this->user->hasPermission('modify', self::ROUTE)) {
			$this->error['warning'] = $this->language->get('error_permission');
			return false;
		}

		return true;
	}
}
