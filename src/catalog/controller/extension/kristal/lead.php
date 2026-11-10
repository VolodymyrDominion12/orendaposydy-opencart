<?php
/**
 * Контролер прийому лідів «Крістал: ліди» (009).
 * Обробка форм «Розрахунок за 15 хв», «1 клік», «Дзвінок», «B2B».
 * PHP 7.3+.
 */
class ControllerExtensionKristalLead extends Controller {

	/**
	 * Прийом та обробка заявки (AJAX POST).
	 */
	public function submit() {
		$this->load->language('extension/kristal/lead');

		$json = array();

		if ($this->request->server['REQUEST_METHOD'] !== 'POST') {
			$json['error'] = $this->language->get('error_post');
			$this->response->addHeader('Content-Type: application/json');
			$this->response->setOutput(json_encode($json));
			return;
		}

		// 1. Антиспам-перевірка
		$antispam = \Kristal\Antispam::fromConfig($this->config, $this->session->getId());
		$salt = (string)$this->config->get('module_kristal_core_salt');
		if ($salt === '') {
			$salt = defined('DIR_SYSTEM') ? md5(DIR_SYSTEM) : 'kristal_default_salt';
		}
		$rl = new \Kristal\Rate_limit($this->db, $salt);
		$ip = isset($this->request->server['REMOTE_ADDR']) ? (string)$this->request->server['REMOTE_ADDR'] : '';
		$spamCheck = $antispam->check('lead', $this->request->post, $ip, $rl);

		if (!$spamCheck['ok']) {
			$json['error'] = $this->language->get('error_spam');
			$this->response->addHeader('Content-Type: application/json');
			$this->response->setOutput(json_encode($json));
			return;
		}

		// 2. Валідація телефону
		$rawPhone = isset($this->request->post['phone']) ? trim((string)$this->request->post['phone']) : '';
		$phone = preg_replace('/[^\d+]/', '', $rawPhone);
		if (strpos($phone, '0') === 0) {
			$phone = '+38' . $phone;
		} elseif (strpos($phone, '380') === 0) {
			$phone = '+' . $phone;
		}

		if (!preg_match('/^\+380\d{9}$/', $phone)) {
			$json['error'] = $this->language->get('error_phone');
			$this->response->addHeader('Content-Type: application/json');
			$this->response->setOutput(json_encode($json));
			return;
		}

		// 3. Валідація дати події (якщо передано)
		$eventDate = isset($this->request->post['event_date']) ? trim((string)$this->request->post['event_date']) : '';
		if ($eventDate !== '') {
			$dt = DateTime::createFromFormat('Y-m-d', $eventDate);
			$today = new DateTime('today');
			if (!$dt || $dt->format('Y-m-d') !== $eventDate || $dt < $today) {
				$json['error'] = $this->language->get('error_date_past');
				$this->response->addHeader('Content-Type: application/json');
				$this->response->setOutput(json_encode($json));
				return;
			}
		} else {
			$eventDate = null;
		}

		// 4. Кількість гостей (якщо передано)
		$guests = isset($this->request->post['guests']) && (string)$this->request->post['guests'] !== '' ? (int)$this->request->post['guests'] : null;
		if ($guests !== null && $guests <= 0) {
			$json['error'] = $this->language->get('error_guests');
			$this->response->addHeader('Content-Type: application/json');
			$this->response->setOutput(json_encode($json));
			return;
		}

		// 5. Товар та кількість (для швидкого замовлення в 1 клік)
		$productId = isset($this->request->post['product_id']) && (int)$this->request->post['product_id'] > 0 ? (int)$this->request->post['product_id'] : null;
		$quantity = isset($this->request->post['quantity']) && (int)$this->request->post['quantity'] > 0 ? (int)$this->request->post['quantity'] : 1;

		$type = isset($this->request->post['type']) ? trim((string)$this->request->post['type']) : 'calc_15m';
		$validTypes = array('calc_15m', 'quick_order', 'callback', 'b2b');
		if (!in_array($type, $validTypes, true)) {
			$type = 'calc_15m';
		}

		$channel = isset($this->request->post['contact_channel']) ? trim((string)$this->request->post['contact_channel']) : 'viber';
		$name = isset($this->request->post['name']) ? trim((string)$this->request->post['name']) : '';
		$email = isset($this->request->post['email']) ? trim((string)$this->request->post['email']) : '';
		$comment = isset($this->request->post['comment']) ? trim((string)$this->request->post['comment']) : '';
		$sourceUrl = isset($this->request->post['source_url']) ? trim((string)$this->request->post['source_url']) : (isset($this->request->server['HTTP_REFERER']) ? (string)$this->request->server['HTTP_REFERER'] : '');

		// 6. Перевірка прикріпленого файлу (якщо є)
		$fileUploaded = false;
		$fileOrigName = '';
		$fileStoredName = '';
		$fileSize = 0;
		$fileMime = '';

		if (isset($this->request->files['file']) && !empty($this->request->files['file']['name'])) {
			$file = $this->request->files['file'];

			if ((int)$file['error'] === UPLOAD_ERR_OK) {
				// Ліміт 10 МБ
				if ($file['size'] > 10 * 1024 * 1024) {
					$json['error'] = $this->language->get('error_file_size');
					$this->response->addHeader('Content-Type: application/json');
					$this->response->setOutput(json_encode($json));
					return;
				}

				$ext = strtolower(pathinfo($file['name'], PATHINFO_EXTENSION));
				$allowedExts = array('pdf', 'doc', 'docx', 'xls', 'xlsx', 'jpg', 'jpeg', 'png', 'webp');

				if (!in_array($ext, $allowedExts, true)) {
					$json['error'] = $this->language->get('error_file_ext');
					$this->response->addHeader('Content-Type: application/json');
					$this->response->setOutput(json_encode($json));
					return;
				}

				$uploadDir = DIR_STORAGE . 'upload/';
				if (!is_dir($uploadDir)) {
					@mkdir($uploadDir, 0755, true);
				}

				// Безпечне унікальне ім'я файлу на диску
				$fileStoredName = 'lead_' . date('Ymd_His') . '_' . bin2hex(random_bytes(8)) . '.' . $ext;
				$targetPath = $uploadDir . $fileStoredName;

				if (move_uploaded_file($file['tmp_name'], $targetPath)) {
					$fileUploaded = true;
					$fileOrigName = $file['name'];
					$fileSize = (int)$file['size'];
					$fileMime = !empty($file['type']) ? (string)$file['type'] : 'application/octet-stream';
				} else {
					$json['error'] = $this->language->get('error_file_upload');
					$this->response->addHeader('Content-Type: application/json');
					$this->response->setOutput(json_encode($json));
					return;
				}
			} elseif ((int)$file['error'] !== UPLOAD_ERR_NO_FILE) {
				$json['error'] = $this->language->get('error_file_upload');
				$this->response->addHeader('Content-Type: application/json');
				$this->response->setOutput(json_encode($json));
				return;
			}
		}

		// 7. Збереження ліда в БД
		$this->load->model('extension/kristal/lead');

		$leadData = array(
			'type'            => $type,
			'status'          => 'new',
			'name'            => $name,
			'phone'           => $phone,
			'email'           => $email,
			'event_date'      => $eventDate,
			'guests'          => $guests,
			'product_id'      => $productId,
			'quantity'        => $quantity,
			'contact_channel' => $channel,
			'comment'         => $comment,
			'source_url'      => $sourceUrl,
			'utm_source'      => isset($this->request->post['utm_source']) ? (string)$this->request->post['utm_source'] : null,
			'utm_medium'      => isset($this->request->post['utm_medium']) ? (string)$this->request->post['utm_medium'] : null,
			'utm_campaign'    => isset($this->request->post['utm_campaign']) ? (string)$this->request->post['utm_campaign'] : null,
			'utm_content'     => isset($this->request->post['utm_content']) ? (string)$this->request->post['utm_content'] : null,
			'utm_term'        => isset($this->request->post['utm_term']) ? (string)$this->request->post['utm_term'] : null
		);

		$leadId = $this->model_extension_kristal_lead->addLead($leadData);

		if ($fileUploaded) {
			$this->model_extension_kristal_lead->addLeadFile($leadId, array(
				'filename_orig'   => $fileOrigName,
				'filename_stored' => $fileStoredName,
				'filesize'        => $fileSize,
				'mime_type'       => $fileMime
			));
		}

		// 8. Відправка сповіщення менеджерам
		$typeTitles = array(
			'calc_15m'    => $this->language->get('text_calc_15m'),
			'quick_order' => $this->language->get('text_quick_order'),
			'callback'    => $this->language->get('text_callback'),
			'b2b'         => $this->language->get('text_b2b')
		);

		$leadNotify = $leadData;
		$leadNotify['lead_id'] = $leadId;
		$leadNotify['type_title'] = isset($typeTitles[$type]) ? $typeTitles[$type] : 'Заявка на оренду';

		if ($productId) {
			$this->load->model('catalog/product');
			$prod = $this->model_catalog_product->getProduct($productId);
			if ($prod) {
				$leadNotify['comment'] = trim(($leadNotify['comment'] !== '' ? $leadNotify['comment'] . "\n" : '') . 'Товар: ' . $prod['name'] . ' × ' . $quantity . ' шт');
			}
		}

		if ($fileUploaded) {
			$leadNotify['comment'] = trim(($leadNotify['comment'] !== '' ? $leadNotify['comment'] . "\n" : '') . 'Прикріплено файл: ' . $fileOrigName);
		}

		$this->load->model('extension/kristal/notify');
		$this->model_extension_kristal_notify->sendLead($leadId, $leadNotify);

		$json['success'] = true;
		$json['lead_id'] = $leadId;
		$json['message'] = ($type === 'quick_order') ? $this->language->get('text_success_quick') : $this->language->get('text_success');

		$this->response->addHeader('Content-Type: application/json');
		$this->response->setOutput(json_encode($json));
	}
}
