<?php
/**
 * «Крістал: пошук» (фіча 027): синоніми, стан індексу і його перебудова, журнал запитів без результатів.
 * Налаштування — oc_setting, code = module_kristal_search, store_id = 0 (вітрина читає з $this->config, 0 запитів).
 * Синоніми зберігаються так, як їх закодував Request ядра; Kristal\Search::synonyms() декодує.
 */
class ControllerExtensionModuleKristalSearch extends Controller {
	const CODE = 'module_kristal_search';
	const ROUTE = 'extension/module/kristal_search';
	const SYNONYMS_MAX = 10000;

	private $error = array();

	public function index() {
		$this->load->language(self::ROUTE);
		$this->document->setTitle($this->language->get('heading_title'));
		$this->load->model('setting/setting');
		$this->load->model('extension/kristal/search');

		$token = 'user_token=' . $this->session->data['user_token'];

		if ($this->request->server['REQUEST_METHOD'] == 'POST' && $this->validate()) {
			$synonyms = isset($this->request->post['synonyms']) && is_scalar($this->request->post['synonyms']) ? (string)$this->request->post['synonyms'] : '';

			$this->model_setting_setting->editSetting(self::CODE, array(
				self::CODE . '_status'   => 1,
				self::CODE . '_synonyms' => utf8_substr($synonyms, 0, self::SYNONYMS_MAX)
			));
			\Kristal\Cache_key::flush($this->cache);

			$this->session->data['success'] = $this->language->get('text_success');
			$this->response->redirect($this->url->link(self::ROUTE, $token, true));
		}

		$data = array();
		$data['error_warning'] = isset($this->error['warning']) ? $this->error['warning'] : '';

		if (!empty($this->session->data['kristal_search_error'])) {
			$data['error_warning'] = $this->session->data['kristal_search_error'];
		}

		unset($this->session->data['kristal_search_error']);
		$data['success'] = isset($this->session->data['success']) ? $this->session->data['success'] : '';
		unset($this->session->data['success']);

		$data['breadcrumbs'] = array(
			array('text' => $this->language->get('text_home'), 'href' => $this->url->link('common/dashboard', $token, true)),
			array('text' => $this->language->get('text_extension'), 'href' => $this->url->link('marketplace/extension', $token . '&type=module', true)),
			array('text' => $this->language->get('heading_title'), 'href' => $this->url->link(self::ROUTE, $token, true))
		);

		$data['action'] = $this->url->link(self::ROUTE, $token, true);
		$data['reindex'] = $this->url->link(self::ROUTE . '/reindex', $token, true);
		$data['clear_log'] = $this->url->link(self::ROUTE . '/clearLog', $token, true);
		$data['cancel'] = $this->url->link('marketplace/extension', $token . '&type=module', true);

		if ($this->request->server['REQUEST_METHOD'] == 'POST') {
			$synonyms = isset($this->request->post['synonyms']) ? (string)$this->request->post['synonyms'] : '';
		} else {
			$saved = $this->model_setting_setting->getSetting(self::CODE);
			$synonyms = isset($saved[self::CODE . '_synonyms']) ? (string)$saved[self::CODE . '_synonyms'] : '';
		}

		$data['synonyms'] = html_entity_decode($synonyms, ENT_QUOTES, 'UTF-8');
		$data['groups'] = count(\Kristal\Search::synonyms($synonyms));
		$data['stats'] = $this->model_extension_kristal_search->stats();
		$data['log'] = array();

		foreach ($this->model_extension_kristal_search->getLog(50) as $row) {
			$data['log'][] = array(
				'query'   => $row['query'],
				'hits'    => (int)$row['hits'],
				'last_at' => date($this->language->get('datetime_format'), strtotime($row['last_at']))
			);
		}

		$data['header'] = $this->load->controller('common/header');
		$data['column_left'] = $this->load->controller('common/column_left');
		$data['footer'] = $this->load->controller('common/footer');

		$this->response->setOutput($this->load->view(self::ROUTE, $data));
	}

	/** POST: перебудувати індекс повністю */
	public function reindex() {
		$this->load->language(self::ROUTE);

		if ($this->request->server['REQUEST_METHOD'] == 'POST' && $this->validate()) {
			$this->load->model('extension/kristal/search');
			$result = $this->model_extension_kristal_search->reindexAll();
			\Kristal\Cache_key::flush($this->cache);

			$this->session->data['success'] = sprintf($this->language->get('text_reindexed'), $result['products'], $result['categories'], $result['words']);
		} else {
			$this->session->data['kristal_search_error'] = $this->language->get('error_permission');
		}

		$this->response->redirect($this->url->link(self::ROUTE, 'user_token=' . $this->session->data['user_token'], true));
	}

	/** POST: очистити журнал «не знайдено» */
	public function clearLog() {
		$this->load->language(self::ROUTE);

		if ($this->request->server['REQUEST_METHOD'] == 'POST' && $this->validate()) {
			$this->load->model('extension/kristal/search');
			$this->model_extension_kristal_search->clearLog();
			$this->session->data['success'] = $this->language->get('text_log_cleared');
		} else {
			$this->session->data['kristal_search_error'] = $this->language->get('error_permission');
		}

		$this->response->redirect($this->url->link(self::ROUTE, 'user_token=' . $this->session->data['user_token'], true));
	}

	/** Не перезаписує синоніми (мок-міграція 0011 чи попереднє встановлення); будує індекс. */
	public function install() {
		$this->load->model('setting/setting');
		$this->load->model('extension/kristal/search');

		$saved = $this->model_setting_setting->getSetting(self::CODE);

		$this->model_setting_setting->editSetting(self::CODE, array(
			self::CODE . '_status'   => 1,
			self::CODE . '_synonyms' => isset($saved[self::CODE . '_synonyms']) ? $saved[self::CODE . '_synonyms'] : ''
		));

		$this->model_extension_kristal_search->reindexAll();
		\Kristal\Cache_key::flush($this->cache);
	}

	/** Синоніми видаляються разом із модулем; індекс і журнал лишаються (їх прибирає migrate-down 0010). */
	public function uninstall() {
		$this->load->model('setting/setting');
		$this->model_setting_setting->deleteSetting(self::CODE);
		\Kristal\Cache_key::flush($this->cache);
	}

	private function validate() {
		if (!$this->user->hasPermission('modify', self::ROUTE)) {
			$this->error['warning'] = $this->language->get('error_permission');
		}

		return !$this->error;
	}
}
