<?php
/**
 * «Крістал: прайс» (фіча 022): вивантаження каталогу в CSV → завантаження зміненого файлу → перегляд змін → застосування,
 * журнал і скасування. Логіка плану — \Kristal\Price_import, CSV — \Kristal\Price_csv, запис — model extension/kristal/import.
 *
 * Завантажений файл — у DIR_UPLOAD (поза вебом), kristal-import-<key>.csv + .json (назва файлу); видаляється після
 * застосування, решта — через добу (AC-14). Повторне застосування того самого перегляду — файлу вже немає (AC-9).
 * Подія kristal_import_menu (міграція 0013): admin/view/common/column_left/before → menu() — «Каталог → Прайс (імпорт)».
 */
class ControllerExtensionModuleKristalImport extends Controller {
	const CODE = 'module_kristal_import';
	const ROUTE = 'extension/module/kristal_import';
	const PREFIX = 'kristal-import-';
	const TTL = 86400;
	const SHOW_CHANGES = 500;

	public function index() {
		$this->load->language(self::ROUTE);
		$this->load->model('extension/kristal/import');
		$this->cleanup();

		$data = $this->common();
		$data['log'] = $this->logRows();

		$this->render($data);
	}

	/** GET: CSV усього каталогу (AC-1…AC-3) */
	public function export() {
		$this->load->language(self::ROUTE);

		if (!$this->canModify()) {
			return $this->back($this->language->get('error_permission'));
		}

		$this->load->model('extension/kristal/import');
		$catalog = $this->model_extension_kristal_import->catalog();
		$csv = \Kristal\Price_csv::write($this->model_extension_kristal_import->exportRows($catalog));

		$this->response->addHeader('Content-Type: text/csv; charset=utf-8');
		$this->response->addHeader('Content-Disposition: attachment; filename="kristal-price-' . date('Y-m-d') . '.csv"');
		$this->response->addHeader('Cache-Control: no-store');
		$this->response->setOutput($csv);
	}

	/** POST multipart: перевірити й зберегти файл → перегляд */
	public function upload() {
		$this->load->language(self::ROUTE);

		if ($this->request->server['REQUEST_METHOD'] !== 'POST' || !$this->canModify()) {
			return $this->back($this->language->get('error_permission'));
		}

		$file = isset($this->request->files['file']) ? $this->request->files['file'] : null;

		if (!$file || !isset($file['error']) || (int)$file['error'] === UPLOAD_ERR_NO_FILE) {
			return $this->back($this->language->get('error_no_file'));
		}

		if ((int)$file['error'] === UPLOAD_ERR_INI_SIZE || (int)$file['error'] === UPLOAD_ERR_FORM_SIZE || (int)$file['size'] > \Kristal\Price_csv::MAX_BYTES) {
			return $this->back($this->language->get('error_read_too_big'));
		}

		if ((int)$file['error'] !== UPLOAD_ERR_OK || !is_uploaded_file($file['tmp_name'])) {
			return $this->back($this->language->get('error_upload'));
		}

		$name = html_entity_decode((string)$file['name'], ENT_QUOTES, 'UTF-8');

		if (preg_match('/\.(xlsx?|ods)$/i', $name)) {
			return $this->back($this->language->get('error_read_binary'));
		}

		$bytes = (string)file_get_contents($file['tmp_name']);
		$read = \Kristal\Price_csv::read($bytes);

		if ($read['error'] !== '') {
			return $this->back($this->language->get('error_read_' . $read['error']));
		}

		$key = bin2hex(random_bytes(16));
		file_put_contents(DIR_UPLOAD . self::PREFIX . $key . '.csv', $bytes);
		file_put_contents(DIR_UPLOAD . self::PREFIX . $key . '.json', json_encode(array('filename' => utf8_substr(basename($name), 0, 255), 'at' => time())));

		$this->response->redirect($this->url->link(self::ROUTE . '/preview', $this->token() . '&key=' . $key, true));
	}

	/** GET: перегляд змін — у базі нічого не змінюється (AC-4) */
	public function preview() {
		$this->load->language(self::ROUTE);
		$this->load->model('extension/kristal/import');

		$upload = $this->loadUpload(isset($this->request->get['key']) ? $this->request->get['key'] : '');

		if (!$upload) {
			return $this->back($this->language->get('error_expired'));
		}

		$read = \Kristal\Price_csv::read($upload['bytes']);

		if ($read['error'] !== '') {
			return $this->back($this->language->get('error_read_' . $read['error']));
		}

		$catalog = $this->model_extension_kristal_import->catalog();
		$plan = \Kristal\Price_import::plan($read, $catalog);

		$data = $this->common();
		$data['preview'] = true;
		$data['filename'] = $upload['meta']['filename'];
		$data['encoding'] = $read['encoding'];
		$data['delimiter'] = $read['delimiter'] === "\t" ? 'Tab' : $read['delimiter'];
		$data['columns'] = array();

		foreach ($read['columns'] as $col) {
			$data['columns'][] = \Kristal\Price_csv::COLUMNS[$col];
		}

		$data['counts'] = $plan['counts'];
		$data['errors'] = array();

		foreach ($plan['errors'] as $error) {
			$data['errors'][] = array('line' => $error['line'], 'text' => $this->message('error_row_', $error['code'], $error['args']));
		}

		$data['warnings'] = array();

		foreach ($plan['warnings'] as $warning) {
			$data['warnings'][] = $this->message('warning_', $warning['code'], $warning['args']);
		}

		$data['changes'] = array();

		foreach (array_slice($plan['changes'], 0, self::SHOW_CHANGES) as $change) {
			$data['changes'][] = array(
				'line' => $change['line'], 'id' => $change['id'], 'name' => $change['name'],
				'field' => $this->language->get('field_' . $change['field']),
				'old' => $this->formatValue($change['field'], $change['old']), 'new' => $this->formatValue($change['field'], $change['new'])
			);
		}

		$data['changes_hidden'] = max(0, count($plan['changes']) - self::SHOW_CHANGES);
		$data['creates'] = array();

		foreach ($plan['creates'] as $create) {
			$data['creates'][] = array('line' => $create['line'], 'sku' => $create['sku'], 'name' => $create['name'], 'category' => $create['category'],
				'price' => $this->formatValue('price', $create['price']), 'minimum' => $create['minimum']);
		}

		$data['can_apply'] = ($plan['updates'] || $plan['creates']) && $this->canModify();
		$data['apply'] = $this->url->link(self::ROUTE . '/apply', $this->token(), true);
		$data['key'] = $upload['key'];
		$data['hash'] = $plan['hash'];
		$data['log'] = $this->logRows();

		$this->render($data);
	}

	/** POST key, hash: застосувати той самий план, що в перегляді (AC-9) */
	public function apply() {
		$this->load->language(self::ROUTE);

		if ($this->request->server['REQUEST_METHOD'] !== 'POST' || !$this->canModify()) {
			return $this->back($this->language->get('error_permission'));
		}

		$key = isset($this->request->post['key']) ? (string)$this->request->post['key'] : '';
		$hash = isset($this->request->post['hash']) ? (string)$this->request->post['hash'] : '';
		$upload = $this->loadUpload($key);

		if (!$upload) {
			return $this->back($this->language->get('error_applied_or_expired'));
		}

		$this->load->model('extension/kristal/import');
		$read = \Kristal\Price_csv::read($upload['bytes']);
		$catalog = $this->model_extension_kristal_import->catalog();
		$plan = \Kristal\Price_import::plan($read, $catalog);

		if ($read['error'] !== '' || !hash_equals($plan['hash'], $hash)) {
			$this->session->data['kristal_import_error'] = $this->language->get('error_changed');
			$this->response->redirect($this->url->link(self::ROUTE . '/preview', $this->token() . '&key=' . $upload['key'], true));
			return;
		}

		// Файл прибираємо до запису: подвійний клік чи «назад» не застосують план удруге
		$this->removeUpload($upload['key']);

		try {
			$import_id = $this->model_extension_kristal_import->apply($plan, $catalog, array(
				'filename' => $upload['meta']['filename'],
				'user_id'  => $this->user->getId(),
				'username' => $this->user->getUserName()
			));
		} catch (\Exception $e) {
			$this->log->write('kristal_import: ' . $e->getMessage());

			return $this->back($this->language->get('error_apply_failed'));
		}

		$this->session->data['success'] = sprintf($this->language->get('text_applied'), $import_id, count($plan['updates']), count($plan['creates']), $plan['counts']['errors']);
		$this->response->redirect($this->url->link(self::ROUTE, $this->token(), true));
	}

	/** POST import_id: скасувати останній або відновити обірваний (AC-11) */
	public function undo() {
		$this->load->language(self::ROUTE);

		if ($this->request->server['REQUEST_METHOD'] !== 'POST' || !$this->canModify()) {
			return $this->back($this->language->get('error_permission'));
		}

		$this->load->model('extension/kristal/import');
		$import_id = isset($this->request->post['import_id']) ? (int)$this->request->post['import_id'] : 0;
		$result = $this->model_extension_kristal_import->undo($import_id);

		if (is_string($result)) {
			return $this->back($this->language->get('error_undo_' . $result));
		}

		$text = sprintf($this->language->get('text_undone'), $import_id);

		if ($result) {
			$text .= ' ' . sprintf($this->language->get('text_undo_kept'), htmlspecialchars(implode('; ', $result), ENT_QUOTES, 'UTF-8'));
		}

		$this->session->data['success'] = $text;
		$this->response->redirect($this->url->link(self::ROUTE, $this->token(), true));
	}

	/** Подія admin/view/common/column_left/before: «Каталог → Прайс (імпорт)» (лише коли модуль встановлено й є право) */
	public function menu(&$route, &$data) {
		if (!$this->config->get(self::CODE . '_status') || !$this->user->hasPermission('access', self::ROUTE) || empty($data['menus'])) {
			return null;
		}

		$lang = $this->load->language(self::ROUTE);

		foreach ($data['menus'] as &$menu) {
			if (isset($menu['id']) && $menu['id'] === 'menu-catalog') {
				$menu['children'][] = array('name' => $lang['text_menu'], 'href' => $this->url->link(self::ROUTE, $this->token(), true), 'children' => array());
				break;
			}
		}

		unset($menu);

		return null;
	}

	public function install() {
		$this->load->model('setting/setting');
		$this->model_setting_setting->editSetting(self::CODE, array(self::CODE . '_status' => 1));
	}

	public function uninstall() {
		$this->load->model('setting/setting');
		$this->model_setting_setting->deleteSetting(self::CODE);
	}

	// ------------------------------------------------------------------ службове

	private function common() {
		$data = array();
		$token = $this->token();

		$data['error_warning'] = '';

		if (!empty($this->session->data['kristal_import_error'])) {
			$data['error_warning'] = $this->session->data['kristal_import_error'];
		}

		unset($this->session->data['kristal_import_error']);
		$data['success'] = isset($this->session->data['success']) ? $this->session->data['success'] : '';
		unset($this->session->data['success']);

		$data['breadcrumbs'] = array(
			array('text' => $this->language->get('text_home'), 'href' => $this->url->link('common/dashboard', $token, true)),
			array('text' => $this->language->get('text_extension'), 'href' => $this->url->link('marketplace/extension', $token . '&type=module', true)),
			array('text' => $this->language->get('heading_title'), 'href' => $this->url->link(self::ROUTE, $token, true))
		);

		$data['preview'] = false;
		$data['can_modify'] = $this->canModify();
		$data['export'] = $this->url->link(self::ROUTE . '/export', $token, true);
		$data['upload'] = $this->url->link(self::ROUTE . '/upload', $token, true);
		$data['undo'] = $this->url->link(self::ROUTE . '/undo', $token, true);
		$data['cancel'] = $this->url->link(self::ROUTE, $token, true);
		$data['back'] = $this->url->link('marketplace/extension', $token . '&type=module', true);
		$data['max_mb'] = round(\Kristal\Price_csv::MAX_BYTES / 1048576);
		$data['max_rows'] = \Kristal\Price_csv::MAX_ROWS;
		$data['columns_help'] = implode(' · ', array_values(\Kristal\Price_csv::COLUMNS));

		return $data;
	}

	private function logRows() {
		$rows = array();
		$undo_marked = false;

		foreach ($this->model_extension_kristal_import->getLog(20) as $row) {
			$action = '';

			if ($row['status'] === 'applying') {
				$action = 'recover';
			} elseif ($row['status'] === 'applied' && !$undo_marked) {
				$action = 'undo';
			}

			if (in_array($row['status'], array('applied', 'applying'), true)) {
				$undo_marked = true; // скасувати можна лише найновіший
			}

			$rows[] = array(
				'import_id'  => (int)$row['import_id'],
				'created_at' => date($this->language->get('datetime_format'), strtotime($row['created_at'])),
				'username'   => $row['username'],
				'filename'   => $row['filename'],
				'status'     => $this->language->get('status_' . $row['status']),
				'counts'     => sprintf($this->language->get('text_log_counts'), $row['rows_total'], $row['changed'], $row['created'], $row['errors']),
				'action'     => $action
			);
		}

		return $rows;
	}

	private function render(array $data) {
		$this->document->setTitle($this->language->get('heading_title'));
		$data['header'] = $this->load->controller('common/header');
		$data['column_left'] = $this->load->controller('common/column_left');
		$data['footer'] = $this->load->controller('common/footer');

		$this->response->setOutput($this->load->view(self::ROUTE, $data));
	}

	private function message($prefix, $code, array $args) {
		foreach (array('bad_number', 'bad_bool') as $with_field) {
			if ($code === $with_field && isset($args[0])) {
				$args[0] = $this->language->get('field_' . $args[0]);
			}
		}

		if ($code === 'create_missing' && isset($args[1])) {
			$labels = array();

			foreach (explode(',', $args[1]) as $field) {
				$labels[] = $this->language->get('field_' . $field);
			}

			$args[1] = implode(', ', $labels);
		}

		if ($code === 'price_jump') {
			$args[1] = $this->formatValue('price', $args[1]);
			$args[2] = $this->formatValue('price', $args[2]);
		}

		$format = $this->language->get($prefix . $code);

		return vsprintf($format, array_map(function ($a) {
			return is_float($a) ? \Kristal\Price_csv::formatNumber($a) : (string)$a;
		}, $args));
	}

	private function formatValue($field, $value) {
		switch ($field) {
			case 'price':
			case 'deposit':
			case 'breakage':
				return \Kristal\Price_csv::formatNumber($value) . ' ₴';
			case 'unit':
				return \Kristal\Rental::unit($value);
			case 'washing':
			case 'hit':
			case 'status':
				return \Kristal\Price_csv::formatBool($value);
			case 'discounts':
				$text = \Kristal\Price_csv::formatDiscounts((array)$value);

				return $text === '' ? '—' : $text;
			default:
				return (string)$value === '' ? '—' : (string)$value;
		}
	}

	private function loadUpload($key) {
		$key = (string)$key;

		if (!preg_match('/^[a-f0-9]{32}$/', $key) || !is_file(DIR_UPLOAD . self::PREFIX . $key . '.csv')) {
			return null;
		}

		$meta = json_decode((string)@file_get_contents(DIR_UPLOAD . self::PREFIX . $key . '.json'), true);

		if (!is_array($meta) || (int)$meta['at'] < time() - self::TTL) {
			$this->removeUpload($key);
			return null;
		}

		return array('key' => $key, 'bytes' => (string)file_get_contents(DIR_UPLOAD . self::PREFIX . $key . '.csv'), 'meta' => $meta);
	}

	private function removeUpload($key) {
		foreach (array('.csv', '.json') as $ext) {
			if (is_file(DIR_UPLOAD . self::PREFIX . $key . $ext)) {
				unlink(DIR_UPLOAD . self::PREFIX . $key . $ext);
			}
		}
	}

	/** Файли старші за добу (AC-14) */
	private function cleanup() {
		foreach ((array)glob(DIR_UPLOAD . self::PREFIX . '*') as $file) {
			if (is_file($file) && filemtime($file) < time() - self::TTL) {
				unlink($file);
			}
		}
	}

	private function canModify() {
		return $this->user->hasPermission('modify', self::ROUTE);
	}

	private function back($error) {
		$this->session->data['kristal_import_error'] = $error;
		$this->response->redirect($this->url->link(self::ROUTE, $this->token(), true));
	}

	private function token() {
		return 'user_token=' . $this->session->data['user_token'];
	}
}
