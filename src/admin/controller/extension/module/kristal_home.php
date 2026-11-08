<?php
/**
 * «Крістал: головна» (фіча 004): тексти й налаштування головної сторінки теми kristal.
 * Налаштування — oc_setting, code = module_kristal_home, store_id = 0 (ядро завантажує їх у $this->config вітрини).
 * Значення з форми ядро вже кодує htmlspecialchars (Request) — так і зберігаємо (вітрина виводить як є, як дані ядра);
 * у форму повертаємо декодованими й екранованими |e.
 */
class ControllerExtensionModuleKristalHome extends Controller {
	const CODE = 'module_kristal_home';
	const ROUTE = 'extension/module/kristal_home';
	const NUMBERS = 3;
	const FAQ = 6;

	private $error = array();

	/** поле => максимальна довжина */
	private $text_fields = array('h1' => 160, 'lead' => 400, 'hero_image' => 255, 'meta_title' => 120, 'meta_description' => 300);

	public function index() {
		$this->load->language(self::ROUTE);
		$this->document->setTitle($this->language->get('heading_title'));
		$this->load->model('setting/setting');
		$this->load->model('tool/image');

		if ($this->request->server['REQUEST_METHOD'] == 'POST' && $this->validate()) {
			$this->model_setting_setting->editSetting(self::CODE, $this->settings($this->request->post));
			\Kristal\Cache_key::flush($this->cache);

			$this->session->data['success'] = $this->language->get('text_success');
			$this->response->redirect($this->url->link(self::ROUTE, 'user_token=' . $this->session->data['user_token'], true));
		}

		$token = 'user_token=' . $this->session->data['user_token'];
		$data = array();

		$data['error_warning'] = isset($this->error['warning']) ? $this->error['warning'] : '';
		$data['error'] = $this->error;
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

		$is_post = $this->request->server['REQUEST_METHOD'] == 'POST';
		$saved = $this->model_setting_setting->getSetting(self::CODE);
		$value = function ($key, $default = '') use ($is_post, $saved) {
			if ($is_post) {
				return isset($this->request->post[$key]) ? $this->request->post[$key] : $default;
			}

			return isset($saved[self::CODE . '_' . $key]) ? $saved[self::CODE . '_' . $key] : $default;
		};
		$decode = function ($s) {
			return html_entity_decode((string)$s, ENT_QUOTES, 'UTF-8');
		};

		$data['status'] = (int)$value('status', 0);

		foreach (array_keys($this->text_fields) as $field) {
			$data[$field] = $decode($value($field));
		}

		$data['seo_text'] = $decode($value('seo_text'));

		$numbers = (array)$value('numbers', array());
		$data['numbers'] = array();

		for ($i = 0; $i < self::NUMBERS; $i++) {
			$data['numbers'][] = array(
				'value' => isset($numbers[$i]['value']) ? $decode($numbers[$i]['value']) : '',
				'label' => isset($numbers[$i]['label']) ? $decode($numbers[$i]['label']) : ''
			);
		}

		$faq = (array)$value('faq', array());
		$data['faq'] = array();

		for ($i = 0; $i < self::FAQ; $i++) {
			$data['faq'][] = array(
				'q' => isset($faq[$i]['q']) ? $decode($faq[$i]['q']) : '',
				'a' => isset($faq[$i]['a']) ? $decode($faq[$i]['a']) : ''
			);
		}

		$image = $data['hero_image'];
		$data['thumb'] = $this->model_tool_image->resize($image !== '' && is_file(DIR_IMAGE . $image) ? $image : 'no_image.png', 100, 100);
		$data['placeholder'] = $this->model_tool_image->resize('no_image.png', 100, 100);
		$data['summernote'] = $this->language->get('summernote');

		$data['header'] = $this->load->controller('common/header');
		$data['column_left'] = $this->load->controller('common/column_left');
		$data['footer'] = $this->load->controller('common/footer');

		$this->response->setOutput($this->load->view(self::ROUTE, $data));
	}

	/** Не перезаписує вже наявні налаштування (напр. з мок-міграції 0009 чи після повторного встановлення) */
	public function install() {
		$this->load->model('setting/setting');

		if (!$this->model_setting_setting->getSetting(self::CODE)) {
			$this->model_setting_setting->editSetting(self::CODE, array(self::CODE . '_status' => 1));
		}
	}

	public function uninstall() {
		$this->load->model('setting/setting');
		$this->model_setting_setting->deleteSetting(self::CODE);
		\Kristal\Cache_key::flush($this->cache);
	}

	/** Дані форми → налаштування (порожні рядки цифр/FAQ відкидаються) */
	private function settings($post) {
		$text = function ($key, $max) use ($post) {
			$value = isset($post[$key]) && is_scalar($post[$key]) ? trim((string)$post[$key]) : '';

			return utf8_substr($value, 0, $max);
		};

		$settings = array(self::CODE . '_status' => !empty($post['status']) ? 1 : 0);

		foreach ($this->text_fields as $field => $max) {
			$settings[self::CODE . '_' . $field] = $text($field, $max);
		}

		$settings[self::CODE . '_seo_text'] = isset($post['seo_text']) && is_scalar($post['seo_text']) ? (string)$post['seo_text'] : '';

		$numbers = array();

		foreach (isset($post['numbers']) && is_array($post['numbers']) ? array_slice($post['numbers'], 0, self::NUMBERS) : array() as $row) {
			$v = isset($row['value']) ? utf8_substr(trim((string)$row['value']), 0, 16) : '';
			$l = isset($row['label']) ? utf8_substr(trim((string)$row['label']), 0, 64) : '';

			if ($v !== '') {
				$numbers[] = array('value' => $v, 'label' => $l);
			}
		}

		$faq = array();

		foreach (isset($post['faq']) && is_array($post['faq']) ? array_slice($post['faq'], 0, self::FAQ) : array() as $row) {
			$q = isset($row['q']) ? utf8_substr(trim((string)$row['q']), 0, 200) : '';
			$a = isset($row['a']) ? utf8_substr(trim((string)$row['a']), 0, 1000) : '';

			if ($q !== '' && $a !== '') {
				$faq[] = array('q' => $q, 'a' => $a);
			}
		}

		$settings[self::CODE . '_numbers'] = $numbers;
		$settings[self::CODE . '_faq'] = $faq;

		return $settings;
	}

	private function validate() {
		if (!$this->user->hasPermission('modify', self::ROUTE)) {
			$this->error['warning'] = $this->language->get('error_permission');

			return false;
		}

		$image = isset($this->request->post['hero_image']) ? trim((string)$this->request->post['hero_image']) : '';

		if ($image !== '' && !is_file(DIR_IMAGE . html_entity_decode($image, ENT_QUOTES, 'UTF-8'))) {
			$this->error['hero_image'] = $this->language->get('error_image');
		}

		if ($this->error && !isset($this->error['warning'])) {
			$this->error['warning'] = $this->language->get('error_form');
		}

		return !$this->error;
	}
}
