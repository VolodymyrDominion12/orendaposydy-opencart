<?php
/**
 * Контролер адмінки «Крістал: ліди» (фіча 009).
 * Список заявок, фільтрація, перегляд, зміна статусів, експорт CSV.
 * PHP 7.3+.
 */
class ControllerExtensionKristalLead extends Controller {
	private $error = array();

	public function index() {
		$this->load->language('extension/kristal/lead');
		$this->document->setTitle($this->language->get('heading_title'));

		$this->load->model('extension/kristal/lead');

		$filter_type = isset($this->request->get['filter_type']) ? $this->request->get['filter_type'] : '';
		$filter_status = isset($this->request->get['filter_status']) ? $this->request->get['filter_status'] : '';
		$filter_phone = isset($this->request->get['filter_phone']) ? $this->request->get['filter_phone'] : '';
		$filter_date_added = isset($this->request->get['filter_date_added']) ? $this->request->get['filter_date_added'] : '';

		$sort = isset($this->request->get['sort']) ? $this->request->get['sort'] : 'lead_id';
		$order = isset($this->request->get['order']) ? $this->request->get['order'] : 'DESC';
		$page = isset($this->request->get['page']) ? (int)$this->request->get['page'] : 1;

		$url = '';
		if (!empty($filter_type)) $url .= '&filter_type=' . urlencode($filter_type);
		if (!empty($filter_status)) $url .= '&filter_status=' . urlencode($filter_status);
		if (!empty($filter_phone)) $url .= '&filter_phone=' . urlencode($filter_phone);
		if (!empty($filter_date_added)) $url .= '&filter_date_added=' . urlencode($filter_date_added);
		if (isset($this->request->get['sort'])) $url .= '&sort=' . $this->request->get['sort'];
		if (isset($this->request->get['order'])) $url .= '&order=' . $this->request->get['order'];
		if (isset($this->request->get['page'])) $url .= '&page=' . $this->request->get['page'];

		$token = 'user_token=' . $this->session->data['user_token'];

		$data['breadcrumbs'] = array(
			array('text' => $this->language->get('text_home'), 'href' => $this->url->link('common/dashboard', $token, true)),
			array('text' => $this->language->get('heading_title'), 'href' => $this->url->link('extension/kristal/lead', $token, true))
		);

		$filter_data = array(
			'filter_type'       => $filter_type,
			'filter_status'     => $filter_status,
			'filter_phone'      => $filter_phone,
			'filter_date_added' => $filter_date_added,
			'sort'              => $sort,
			'order'             => $order,
			'start'             => ($page - 1) * $this->config->get('config_limit_admin'),
			'limit'             => $this->config->get('config_limit_admin')
		);

		$lead_total = $this->model_extension_kristal_lead->getTotalLeads($filter_data);
		$results = $this->model_extension_kristal_lead->getLeads($filter_data);

		$data['leads'] = array();

		$type_labels = array(
			'calc_15m'    => $this->language->get('text_type_calc_15m'),
			'quick_order' => $this->language->get('text_type_quick_order'),
			'callback'    => $this->language->get('text_type_callback'),
			'b2b'         => $this->language->get('text_type_b2b')
		);

		$status_labels = array(
			'new'         => array('label' => $this->language->get('text_status_new'), 'class' => 'label-danger'),
			'in_progress' => array('label' => $this->language->get('text_status_in_progress'), 'class' => 'label-warning'),
			'completed'   => array('label' => $this->language->get('text_status_completed'), 'class' => 'label-success'),
			'canceled'    => array('label' => $this->language->get('text_status_canceled'), 'class' => 'label-default')
		);

		foreach ($results as $result) {
			$files = $this->model_extension_kristal_lead->getLeadFiles($result['lead_id']);

			$data['leads'][] = array(
				'lead_id'     => $result['lead_id'],
				'type'        => $result['type'],
				'type_text'   => isset($type_labels[$result['type']]) ? $type_labels[$result['type']] : $result['type'],
				'status'      => $result['status'],
				'status_info' => isset($status_labels[$result['status']]) ? $status_labels[$result['status']] : array('label' => $result['status'], 'class' => 'label-info'),
				'name'        => $result['name'],
				'phone'       => $result['phone'],
				'channel'     => strtoupper($result['contact_channel']),
				'event_date'  => $result['event_date'] ? date('d.m.Y', strtotime($result['event_date'])) : '—',
				'guests'      => $result['guests'] ? (int)$result['guests'] : '—',
				'has_files'   => count($files) > 0,
				'created_at'  => date('d.m.Y H:i', strtotime($result['created_at'])),
				'view'        => $this->url->link('extension/kristal/lead/info', $token . '&lead_id=' . $result['lead_id'] . $url, true)
			);
		}

		$data['user_token'] = $this->session->data['user_token'];
		$data['export'] = $this->url->link('extension/kristal/lead/exportCsv', $token . $url, true);

		$data['filter_type'] = $filter_type;
		$data['filter_status'] = $filter_status;
		$data['filter_phone'] = $filter_phone;
		$data['filter_date_added'] = $filter_date_added;

		$pagination = new Pagination();
		$pagination->total = $lead_total;
		$pagination->page = $page;
		$pagination->limit = $this->config->get('config_limit_admin');
		$pagination->url = $this->url->link('extension/kristal/lead', $token . $url . '&page={page}', true);

		$data['pagination'] = $pagination->render();
		$data['results'] = sprintf($this->language->get('text_pagination'), ($lead_total) ? (($page - 1) * $this->config->get('config_limit_admin')) + 1 : 0, ((($page - 1) * $this->config->get('config_limit_admin')) > ($lead_total - $this->config->get('config_limit_admin'))) ? $lead_total : ((($page - 1) * $this->config->get('config_limit_admin')) + $this->config->get('config_limit_admin')), $lead_total, ceil($lead_total / $this->config->get('config_limit_admin')));

		$data['header'] = $this->load->controller('common/header');
		$data['column_left'] = $this->load->controller('common/column_left');
		$data['footer'] = $this->load->controller('common/footer');

		$this->response->setOutput($this->load->view('extension/kristal/lead_list', $data));
	}

	public function info() {
		$this->load->language('extension/kristal/lead');

		$lead_id = isset($this->request->get['lead_id']) ? (int)$this->request->get['lead_id'] : 0;

		$this->load->model('extension/kristal/lead');
		$lead = $this->model_extension_kristal_lead->getLead($lead_id);

		if (!$lead) {
			$this->response->redirect($this->url->link('extension/kristal/lead', 'user_token=' . $this->session->data['user_token'], true));
		}

		$this->document->setTitle($this->language->get('heading_title') . ' #' . $lead_id);

		$token = 'user_token=' . $this->session->data['user_token'];

		$data['breadcrumbs'] = array(
			array('text' => $this->language->get('text_home'), 'href' => $this->url->link('common/dashboard', $token, true)),
			array('text' => $this->language->get('heading_title'), 'href' => $this->url->link('extension/kristal/lead', $token, true)),
			array('text' => '#' . $lead_id, 'href' => $this->url->link('extension/kristal/lead/info', $token . '&lead_id=' . $lead_id, true))
		);

		$data['lead'] = $lead;
		$data['lead']['created_at_formatted'] = date('d.m.Y H:i:s', strtotime($lead['created_at']));
		$data['lead']['event_date_formatted'] = $lead['event_date'] ? date('d.m.Y', strtotime($lead['event_date'])) : '';

		// Товар (якщо є)
		$data['product'] = null;
		if (!empty($lead['product_id'])) {
			$this->load->model('catalog/product');
			$data['product'] = $this->model_catalog_product->getProduct($lead['product_id']);
		}

		// Файли
		$files = $this->model_extension_kristal_lead->getLeadFiles($lead_id);
		$data['files'] = array();
		foreach ($files as $f) {
			$data['files'][] = array(
				'file_id'   => $f['file_id'],
				'filename'  => $f['filename_orig'],
				'size'      => round($f['filesize'] / 1024, 1) . ' КБ',
				'download'  => $this->url->link('extension/kristal/lead/download', $token . '&file_id=' . $f['file_id'], true)
			);
		}

		$data['action_status'] = $this->url->link('extension/kristal/lead/updateStatus', $token, true);
		$data['back'] = $this->url->link('extension/kristal/lead', $token, true);
		$data['user_token'] = $this->session->data['user_token'];

		if (isset($this->session->data['success'])) {
			$data['success'] = $this->session->data['success'];
			unset($this->session->data['success']);
		} else {
			$data['success'] = '';
		}

		$data['header'] = $this->load->controller('common/header');
		$data['column_left'] = $this->load->controller('common/column_left');
		$data['footer'] = $this->load->controller('common/footer');

		$this->response->setOutput($this->load->view('extension/kristal/lead_info', $data));
	}

	public function updateStatus() {
		$this->load->language('extension/kristal/lead');

		if ($this->request->server['REQUEST_METHOD'] === 'POST' && isset($this->request->post['lead_id'])) {
			$lead_id = (int)$this->request->post['lead_id'];
			$status = isset($this->request->post['status']) ? (string)$this->request->post['status'] : 'new';
			$note = isset($this->request->post['manager_note']) ? (string)$this->request->post['manager_note'] : '';

			$this->load->model('extension/kristal/lead');
			$this->model_extension_kristal_lead->updateLeadStatus($lead_id, $status, $note);

			$this->session->data['success'] = $this->language->get('text_success');
			$this->response->redirect($this->url->link('extension/kristal/lead/info', 'user_token=' . $this->session->data['user_token'] . '&lead_id=' . $lead_id, true));
		}
	}

	public function download() {
		$file_id = isset($this->request->get['file_id']) ? (int)$this->request->get['file_id'] : 0;

		$this->load->model('extension/kristal/lead');
		$file = $this->model_extension_kristal_lead->getFile($file_id);

		if (!$file) {
			$this->response->redirect($this->url->link('extension/kristal/lead', 'user_token=' . $this->session->data['user_token'], true));
			return;
		}

		$path = DIR_STORAGE . 'upload/' . $file['filename_stored'];
		if (!is_file($path)) {
			$this->response->redirect($this->url->link('extension/kristal/lead', 'user_token=' . $this->session->data['user_token'], true));
			return;
		}

		header('Content-Description: File Transfer');
		header('Content-Type: ' . ($file['mime_type'] ?: 'application/octet-stream'));
		header('Content-Disposition: attachment; filename="' . basename($file['filename_orig']) . '"');
		header('Expires: 0');
		header('Cache-Control: must-revalidate');
		header('Pragma: public');
		header('Content-Length: ' . filesize($path));
		readfile($path);
		exit;
	}

	public function exportCsv() {
		$this->load->model('extension/kristal/lead');

		$filter_data = array(
			'filter_type'       => isset($this->request->get['filter_type']) ? $this->request->get['filter_type'] : '',
			'filter_status'     => isset($this->request->get['filter_status']) ? $this->request->get['filter_status'] : '',
			'filter_phone'      => isset($this->request->get['filter_phone']) ? $this->request->get['filter_phone'] : '',
			'filter_date_added' => isset($this->request->get['filter_date_added']) ? $this->request->get['filter_date_added'] : '',
			'sort'              => 'lead_id',
			'order'             => 'DESC',
			'start'             => 0,
			'limit'             => 10000
		);

		$leads = $this->model_extension_kristal_lead->getLeads($filter_data);

		header('Content-Type: text/csv; charset=utf-8');
		header('Content-Disposition: attachment; filename="leads_' . date('Y-m-d_His') . '.csv"');

		$output = fopen('php://output', 'w');
		// UTF-8 BOM для правильного відображення в Excel
		fprintf($output, chr(0xEF).chr(0xBB).chr(0xBF));

		fputcsv($output, array('ID', 'Дата', 'Тип', 'Статус', 'Ім\'я', 'Телефон', 'Email', 'Дата події', 'Гостей', 'Канал', 'Коментар', 'Примітка менеджера', 'Джерело', 'UTM Source', 'UTM Campaign'), ';');

		foreach ($leads as $l) {
			fputcsv($output, array(
				$l['lead_id'],
				$l['created_at'],
				$l['type'],
				$l['status'],
				$l['name'],
				$l['phone'],
				$l['email'],
				$l['event_date'],
				$l['guests'],
				$l['contact_channel'],
				$l['comment'],
				$l['manager_note'],
				$l['source_url'],
				$l['utm_source'],
				$l['utm_campaign']
			), ';');
		}

		fclose($output);
		exit;
	}

	/**
	 * Подія admin/view/common/column_left/before: додавання пункту «Заявки (ліди)» у меню «Продажі».
	 */
	public function menu(&$route, &$data) {
		if (empty($data['menus'])) {
			return null;
		}

		$this->load->language('extension/kristal/lead');

		foreach ($data['menus'] as &$menu) {
			if (isset($menu['id']) && $menu['id'] === 'menu-sale') {
				$menu['children'][] = array(
					'name'     => $this->language->get('heading_title'),
					'href'     => $this->url->link('extension/kristal/lead', 'user_token=' . $this->session->data['user_token'], true),
					'children' => array()
				);
				break;
			}
		}

		unset($menu);
		return null;
	}
}
