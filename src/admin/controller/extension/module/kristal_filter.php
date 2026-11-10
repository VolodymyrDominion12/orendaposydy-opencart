<?php
/**
 * «Крістал: фільтри» (фіча 021): заповнення фільтрів ядра з атрибутів (план → запис → скасування),
 * масове призначення значень товарам категорії, SEO-сторінки фільтрів (білий список).
 * Групи й значення редагуються в ядрі: «Каталог → Фільтри»; значення товару — також у формі товару ядра (поле «Фільтри»).
 * Після кожного запису — \Kristal\Cache_key::flush() (індекси категорій вітрини kristal.filter.*).
 */
class ControllerExtensionModuleKristalFilter extends Controller {
	const CODE = 'module_kristal_filter';
	const ROUTE = 'extension/module/kristal_filter';
	const ASSIGN_LIMIT = 200;

	private $error = array();

	public function index() {
		$this->load->language(self::ROUTE);
		$this->document->setTitle($this->language->get('heading_title'));
		$this->load->model('extension/kristal/filter');

		$data = $this->common();
		$token = $this->token();

		// Заповнення з атрибутів
		$data['seed_preview'] = !empty($this->request->get['preview']);
		$data['seed_plan'] = array();
		$data['seed_pairs'] = 0;
		$data['seed_skipped'] = array();

		if ($data['seed_preview']) {
			$plan = $this->model_extension_kristal_filter->seedPlan();
			$data['seed_pairs'] = $plan['pairs'];

			foreach ($plan['groups'] as $group => $info) {
				$values = array();

				foreach ($info['values'] as $value => $vinfo) {
					$values[] = array('name' => $value, 'exists' => $vinfo['exists'], 'products' => count($vinfo['products']));
				}

				$data['seed_plan'][] = array('name' => $group, 'exists' => $info['exists'], 'values' => $values);
			}

			foreach ($plan['skipped'] as $attribute => $texts) {
				arsort($texts);
				$list = array();

				foreach (array_slice($texts, 0, 15, true) as $text => $n) {
					$list[] = $text . ($n > 1 ? ' ×' . $n : '');
				}

				$data['seed_skipped'][] = array('attribute' => $attribute, 'texts' => implode('; ', $list), 'more' => max(0, count($texts) - 15));
			}
		}

		$log = $this->model_extension_kristal_filter->seedLog();
		$data['seed_log'] = $log['groups'] || $log['values'] || $log['pairs'] ? sprintf($this->language->get('text_seed_log'), count($log['groups']), count($log['values']), count($log['pairs'])) : '';
		$data['seed_preview_href'] = $this->url->link(self::ROUTE, $token . '&preview=1', true);
		$data['seed_apply'] = $this->url->link(self::ROUTE . '/seed', $token, true);
		$data['seed_undo'] = $this->url->link(self::ROUTE . '/seedUndo', $token, true);

		// Значення фільтрів
		$groups = $this->model_extension_kristal_filter->getValues();
		$data['groups_count'] = count($groups);
		$data['values_count'] = 0;

		foreach ($groups as $group) {
			$data['values_count'] += count($group['values']);
		}

		$data['filters_href'] = $this->url->link('catalog/filter', $token, true);

		// SEO-сторінки
		$data['pages'] = array();

		foreach ($this->model_extension_kristal_filter->getPages() as $page) {
			$names = array();

			foreach (explode(',', $page['filter_ids']) as $fid) {
				$names[] = $this->valueName($groups, (int)$fid);
			}

			$data['pages'][] = array(
				'category' => $page['category'],
				'filters'  => implode(' + ', $names),
				'keyword'  => $page['keyword'],
				'h1'       => $page['h1'],
				'status'   => (int)$page['status'],
				'edit'     => $this->url->link(self::ROUTE . '/page', $token . '&filter_page_id=' . (int)$page['filter_page_id'], true),
				'delete'   => $this->url->link(self::ROUTE . '/deletePage', $token . '&filter_page_id=' . (int)$page['filter_page_id'], true)
			);
		}

		$data['page_add'] = $this->url->link(self::ROUTE . '/page', $token, true);

		// Масове призначення
		$data['categories'] = $this->model_extension_kristal_filter->getCategories();
		$data['assign_action'] = $this->url->link(self::ROUTE . '/assign', '', true);
		$data['user_token'] = $this->session->data['user_token'];

		$this->output('', $data);
	}

	/** Масове призначення: таблиця товарів категорії × групи */
	public function assign() {
		$this->load->language(self::ROUTE);
		$this->load->model('extension/kristal/filter');

		$category_id = isset($this->request->get['category_id']) ? (int)$this->request->get['category_id'] : 0;
		$token = $this->token();

		if ($this->request->server['REQUEST_METHOD'] == 'POST' && $this->validate()) {
			$products = $this->model_extension_kristal_filter->getCategoryProducts($category_id, self::ASSIGN_LIMIT);
			$posted = isset($this->request->post['pf']) && is_array($this->request->post['pf']) ? $this->request->post['pf'] : array();
			$assign = array();

			// Лише товари цієї категорії, показані у формі (решта не чіпається)
			foreach ($products as $pid => $product) {
				$fids = array();

				if (isset($posted[$pid]) && is_array($posted[$pid])) {
					foreach ($posted[$pid] as $group) {
						$fids = array_merge($fids, array_map('intval', (array)$group));
					}
				}

				$assign[$pid] = $fids;
			}

			$n = $this->model_extension_kristal_filter->saveAssignments($assign);
			\Kristal\Cache_key::flush($this->cache);

			$this->session->data['success'] = sprintf($this->language->get('text_assigned'), count($assign), $n);
			$this->response->redirect($this->url->link(self::ROUTE . '/assign', $token . '&category_id=' . $category_id, true));
		}

		$this->document->setTitle($this->language->get('text_assign'));
		$data = $this->common();

		$data['category_id'] = $category_id;
		$data['category_name'] = '';

		foreach ($this->model_extension_kristal_filter->getCategories() as $category) {
			if ((int)$category['category_id'] === $category_id) {
				$data['category_name'] = $category['name'];
			}
		}

		$data['groups'] = array();

		foreach ($this->model_extension_kristal_filter->getValues() as $gid => $group) {
			$data['groups'][] = array('id' => $gid, 'name' => $group['name'], 'values' => $group['values']);
		}

		$data['products'] = array();
		$products = $category_id ? $this->model_extension_kristal_filter->getCategoryProducts($category_id, self::ASSIGN_LIMIT) : array();

		foreach ($products as $pid => $product) {
			$data['products'][] = array(
				'id'      => $pid,
				'name'    => $product['name'],
				'model'   => $product['sku'] !== '' ? $product['sku'] : $product['model'],
				'status'  => (int)$product['status'],
				'filters' => array_flip($product['filters']),
				'edit'    => $this->url->link('catalog/product/edit', $token . '&product_id=' . $pid, true)
			);
		}

		$data['limit_note'] = count($products) >= self::ASSIGN_LIMIT ? sprintf($this->language->get('text_assign_limit'), self::ASSIGN_LIMIT) : '';
		$data['action'] = $this->url->link(self::ROUTE . '/assign', $token . '&category_id=' . $category_id, true);
		$data['cancel'] = $this->url->link(self::ROUTE, $token, true);

		$this->output('_assign', $data, $this->language->get('text_assign'));
	}

	/** Форма SEO-сторінки (додати / редагувати) */
	public function page() {
		$this->load->language(self::ROUTE);
		$this->load->model('extension/kristal/filter');

		$token = $this->token();
		$filter_page_id = isset($this->request->get['filter_page_id']) ? (int)$this->request->get['filter_page_id'] : 0;
		$errors = array();

		if ($this->request->server['REQUEST_METHOD'] == 'POST') {
			if ($this->validate()) {
				$errors = $this->model_extension_kristal_filter->validatePage($this->request->post, $filter_page_id);

				if (!$errors) {
					$this->model_extension_kristal_filter->savePage($this->request->post, $filter_page_id);
					\Kristal\Cache_key::flush($this->cache);

					$this->session->data['success'] = $this->language->get('text_page_saved');
					$this->response->redirect($this->url->link(self::ROUTE, $token, true));
				}
			}

			$page = $this->request->post;
			$page['filters'] = $this->model_extension_kristal_filter->pageFilterIds($this->request->post);
		} elseif ($filter_page_id) {
			$page = $this->model_extension_kristal_filter->getPage($filter_page_id);
			$page['filters'] = $page ? array_map('intval', explode(',', $page['filter_ids'])) : array();
		} else {
			$page = array();
		}

		$this->document->setTitle($this->language->get('text_page_form'));
		$data = $this->common();

		foreach (array('category_id' => 0, 'keyword' => '', 'h1' => '', 'title' => '', 'description' => '', 'text' => '', 'status' => 1) as $key => $default) {
			$data[$key] = isset($page[$key]) ? $page[$key] : $default;
		}

		$data['filters'] = isset($page['filters']) ? $page['filters'] : array();
		$data['errors'] = array();

		foreach ($errors as $field => $code) {
			$data['errors'][$field] = $this->language->get($code);
		}

		$data['categories'] = $this->model_extension_kristal_filter->getCategories();
		$data['groups'] = $this->model_extension_kristal_filter->getValues();
		$data['action'] = $this->url->link(self::ROUTE . '/page', $token . ($filter_page_id ? '&filter_page_id=' . $filter_page_id : ''), true);
		$data['cancel'] = $this->url->link(self::ROUTE, $token, true);

		// Текст — редактор ядра (summernote), як в описі категорії
		$this->document->addScript('view/javascript/summernote/summernote.js');
		$this->document->addScript('view/javascript/summernote/summernote-image-attributes.js');
		$this->document->addScript('view/javascript/summernote/opencart.js');
		$this->document->addStyle('view/javascript/summernote/summernote.css');

		$this->output('_page', $data, $this->language->get('text_page_form'));
	}

	public function deletePage() {
		$this->load->language(self::ROUTE);

		if ($this->request->server['REQUEST_METHOD'] == 'POST' && $this->validate()) {
			$this->load->model('extension/kristal/filter');
			$this->model_extension_kristal_filter->deletePage(isset($this->request->get['filter_page_id']) ? (int)$this->request->get['filter_page_id'] : 0);
			\Kristal\Cache_key::flush($this->cache);
			$this->session->data['success'] = $this->language->get('text_page_deleted');
		} else {
			$this->session->data['kristal_filter_error'] = $this->language->get('error_permission');
		}

		$this->response->redirect($this->url->link(self::ROUTE, $this->token(), true));
	}

	/** POST: записати заповнення з атрибутів */
	public function seed() {
		$this->load->language(self::ROUTE);

		if ($this->request->server['REQUEST_METHOD'] == 'POST' && $this->validate()) {
			$this->load->model('extension/kristal/filter');
			$stats = $this->model_extension_kristal_filter->seedApply();
			\Kristal\Cache_key::flush($this->cache);
			$this->session->data['success'] = sprintf($this->language->get('text_seeded'), $stats['groups'], $stats['values'], $stats['pairs']);
		} else {
			$this->session->data['kristal_filter_error'] = $this->language->get('error_permission');
		}

		$this->response->redirect($this->url->link(self::ROUTE, $this->token(), true));
	}

	/** POST: скасувати заповнення */
	public function seedUndo() {
		$this->load->language(self::ROUTE);

		if ($this->request->server['REQUEST_METHOD'] == 'POST' && $this->validate()) {
			$this->load->model('extension/kristal/filter');
			$stats = $this->model_extension_kristal_filter->seedUndo();
			\Kristal\Cache_key::flush($this->cache);
			$this->session->data['success'] = sprintf($this->language->get('text_seed_undone'), $stats['groups'], $stats['values'], $stats['pairs']);
		} else {
			$this->session->data['kristal_filter_error'] = $this->language->get('error_permission');
		}

		$this->response->redirect($this->url->link(self::ROUTE, $this->token(), true));
	}

	public function install() {
		$this->load->model('setting/setting');
		$this->model_setting_setting->editSetting(self::CODE, array(self::CODE . '_status' => 1));
		\Kristal\Cache_key::flush($this->cache);
	}

	/** Сторінки, значення й призначення лишаються (дані); таблицю прибирає migrate-down 0014. */
	public function uninstall() {
		$this->load->model('setting/setting');
		$this->model_setting_setting->deleteSetting(self::CODE);
		\Kristal\Cache_key::flush($this->cache);
	}

	// ------------------------------------------------------------------------------------------------

	private function token() {
		return 'user_token=' . $this->session->data['user_token'];
	}

	private function common() {
		$token = $this->token();
		$data = array();

		$data['error_warning'] = isset($this->error['warning']) ? $this->error['warning'] : '';

		if (!empty($this->session->data['kristal_filter_error'])) {
			$data['error_warning'] = $this->session->data['kristal_filter_error'];
		}

		unset($this->session->data['kristal_filter_error']);
		$data['success'] = isset($this->session->data['success']) ? $this->session->data['success'] : '';
		unset($this->session->data['success']);

		$data['breadcrumbs'] = array(
			array('text' => $this->language->get('text_home'), 'href' => $this->url->link('common/dashboard', $token, true)),
			array('text' => $this->language->get('text_extension'), 'href' => $this->url->link('marketplace/extension', $token . '&type=module', true)),
			array('text' => $this->language->get('heading_title'), 'href' => $this->url->link(self::ROUTE, $token, true))
		);

		$data['back'] = $this->url->link('marketplace/extension', $token . '&type=module', true);

		return $data;
	}

	private function output($suffix, $data, $crumb = '') {
		if ($crumb !== '') {
			$data['breadcrumbs'][] = array('text' => $crumb, 'href' => '');
		}

		$data['header'] = $this->load->controller('common/header');
		$data['column_left'] = $this->load->controller('common/column_left');
		$data['footer'] = $this->load->controller('common/footer');

		$this->response->setOutput($this->load->view(self::ROUTE . $suffix, $data));
	}

	private function valueName($groups, $fid) {
		foreach ($groups as $group) {
			if (isset($group['values'][$fid])) {
				return $group['name'] . ': ' . $group['values'][$fid];
			}
		}

		return '#' . $fid;
	}

	private function validate() {
		if (!$this->user->hasPermission('modify', self::ROUTE)) {
			$this->error['warning'] = $this->language->get('error_permission');
		}

		return !$this->error;
	}
}
