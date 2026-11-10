<?php
class ControllerInformationContact extends Controller {
	private $error = array();

	public function index() {
		$this->load->language('information/contact');

		$this->document->setTitle($this->language->get('meta_title'));
		$this->document->setDescription($this->language->get('meta_description'));

		$canonical = $this->url->link('information/contact');
		$this->document->addLink($canonical, 'canonical');

		if (($this->request->server['REQUEST_METHOD'] == 'POST') && $this->validate()) {
			$name = strip_tags($this->request->post['name']);
			$contact_info = strip_tags($this->request->post['email']);
			$enquiry = strip_tags($this->request->post['enquiry']);

			// Фіксація в системі заявок kristal_lead (якщо таблиця існує)
			$phone = '';
			$email = '';
			if (strpos($contact_info, '@') !== false) {
				$email = $contact_info;
			} else {
				$phone = $contact_info;
			}

			$lead_data = array(
				'type'        => 'contact_message',
				'name'        => $name,
				'phone'       => $phone ? $phone : 'Не вказано',
				'email'       => $email,
				'comment'     => $enquiry,
				'source_url'  => $canonical,
				'ip'          => isset($this->request->server['REMOTE_ADDR']) ? $this->request->server['REMOTE_ADDR'] : '',
				'user_agent'  => isset($this->request->server['HTTP_USER_AGENT']) ? $this->request->server['HTTP_USER_AGENT'] : ''
			);

			// Відправка через kristal_notify, якщо налаштовано
			if (class_exists('\\Kristal\\Notify') || file_exists(DIR_SYSTEM . 'library/kristal/notify.php')) {
				if (!class_exists('\\Kristal\\Notify')) {
					require_once DIR_SYSTEM . 'library/kristal/notify.php';
				}
				$msg = "📩 <b>Нове повідомлення зі сторінки контактів</b>\n\n";
				$msg .= "👤 Ім'я: " . htmlspecialchars($name, ENT_QUOTES, 'UTF-8') . "\n";
				$msg .= "📞 Контакт: " . htmlspecialchars($contact_info, ENT_QUOTES, 'UTF-8') . "\n";
				$msg .= "💬 Текст: " . htmlspecialchars($enquiry, ENT_QUOTES, 'UTF-8') . "\n";
				$msg .= "🌐 Джерело: " . $canonical;

				\Kristal\Notify::send($this->db, $this->config, $msg, 'contact');
			}

			// Email сповіщення ядра
			$mail = new Mail($this->config->get('config_mail_engine'));
			$mail->parameter = $this->config->get('config_mail_parameter');
			$mail->smtp_hostname = $this->config->get('config_mail_smtp_hostname');
			$mail->smtp_username = $this->config->get('config_mail_smtp_username');
			$mail->smtp_password = html_entity_decode($this->config->get('config_mail_smtp_password'), ENT_QUOTES, 'UTF-8');
			$mail->smtp_port = $this->config->get('config_mail_smtp_port');
			$mail->smtp_timeout = $this->config->get('config_mail_smtp_timeout');

			$mail->setTo($this->config->get('config_email'));
			$mail->setFrom($this->config->get('config_email'));
			$mail->setSender(html_entity_decode($name, ENT_QUOTES, 'UTF-8'));
			$mail->setSubject(html_entity_decode(sprintf($this->language->get('email_subject'), $name), ENT_QUOTES, 'UTF-8'));
			$mail->setText($enquiry . "\n\nКонтакт: " . $contact_info);
			@$mail->send();

			$this->response->redirect($this->url->link('information/contact/success'));
		}

		$data['breadcrumbs'] = array();
		$data['breadcrumbs'][] = array(
			'text' => $this->language->get('text_home'),
			'href' => $this->url->link('common/home')
		);
		$data['breadcrumbs'][] = array(
			'text' => $this->language->get('heading_title'),
			'href' => $canonical
		);

		$data['heading_title'] = $this->language->get('heading_title');
		$data['text_location'] = $this->language->get('text_location');
		$data['text_store'] = $this->language->get('text_store');
		$data['text_address'] = $this->language->get('text_address');
		$data['text_telephone'] = $this->language->get('text_telephone');
		$data['text_open'] = $this->language->get('text_open');
		$data['text_comment'] = $this->language->get('text_comment');
		$data['text_viber'] = $this->language->get('text_viber');
		$data['text_telegram'] = $this->language->get('text_telegram');

		$data['entry_name'] = $this->language->get('entry_name');
		$data['entry_email'] = $this->language->get('entry_email');
		$data['entry_enquiry'] = $this->language->get('entry_enquiry');

		$data['button_submit'] = 'Надіслати повідомлення';

		$data['action'] = $this->url->link('information/contact');

		// Помилки
		$data['error_name'] = isset($this->error['name']) ? $this->error['name'] : '';
		$data['error_email'] = isset($this->error['email']) ? $this->error['email'] : '';
		$data['error_enquiry'] = isset($this->error['enquiry']) ? $this->error['enquiry'] : '';

		// Поля
		$data['name'] = isset($this->request->post['name']) ? $this->request->post['name'] : '';
		$data['email'] = isset($this->request->post['email']) ? $this->request->post['email'] : '';
		$data['enquiry'] = isset($this->request->post['enquiry']) ? $this->request->post['enquiry'] : '';

		// Контактні дані
		$data['store'] = 'Крістал';
		$data['address'] = 'м. Львів, вул. Богдана Хмельницького, 106';
		$data['telephone'] = '+38 (067) 827-70-07';
		$data['telephone_raw'] = '+380678277007';
		$data['viber_url'] = 'viber://chat?number=%2B380678277007';
		$data['telegram_url'] = 'https://t.me/orendaposudu';
		$data['open'] = 'Щодня з 9:00 до 20:00';
		$data['comment'] = 'Склад знаходиться на території колишнього заводу, в\'їзд через шлагбаум. Безкоштовна стоянка для завантаження.';

		// LocalBusiness JSON-LD
		$business_schema = array(
			'@context'    => 'https://schema.org',
			'@type'       => 'LocalBusiness',
			'name'        => 'Крістал — оренда посуду та обладнання',
			'image'       => HTTP_SERVER . 'image/catalog/logo.png',
			'telephone'   => '+380678277007',
			'address'     => array(
				'@type'           => 'PostalAddress',
				'streetAddress'   => 'вул. Богдана Хмельницького, 106',
				'addressLocality' => 'Львів',
				'postalCode'      => '79000',
				'addressCountry'  => 'UA'
			),
			'geo'         => array(
				'@type'     => 'GeoCoordinates',
				'latitude'  => '49.8570',
				'longitude' => '24.0480'
			),
			'openingHoursSpecification' => array(
				'@type'     => 'OpeningHoursSpecification',
				'dayOfWeek' => array('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'),
				'opens'     => '09:00',
				'closes'    => '20:00'
			),
			'priceRange'  => '₴₴'
		);
		$data['business_schema_json'] = json_encode($business_schema, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);

		$data['header'] = $this->load->controller('common/header');
		$data['footer'] = $this->load->controller('common/footer');

		$this->response->setOutput($this->load->view('information/contact', $data));
	}

	public function success() {
		$this->load->language('information/contact');

		$this->document->setTitle($this->language->get('heading_title'));

		$data['breadcrumbs'] = array();
		$data['breadcrumbs'][] = array(
			'text' => $this->language->get('text_home'),
			'href' => $this->url->link('common/home')
		);
		$data['breadcrumbs'][] = array(
			'text' => $this->language->get('heading_title'),
			'href' => $this->url->link('information/contact')
		);

		$data['heading_title'] = $this->language->get('heading_title');
		$data['text_message'] = $this->language->get('text_success');
		$data['button_continue'] = 'Повернутися до каталогу';
		$data['continue'] = $this->url->link('common/home');

		$data['header'] = $this->load->controller('common/header');
		$data['footer'] = $this->load->controller('common/footer');

		$this->response->setOutput($this->load->view('common/success', $data));
	}

	protected function validate() {
		if ((utf8_strlen($this->request->post['name']) < 2) || (utf8_strlen($this->request->post['name']) > 32)) {
			$this->error['name'] = $this->language->get('error_name');
		}

		$contact = trim($this->request->post['email']);
		if (strlen($contact) < 5) {
			$this->error['email'] = $this->language->get('error_email');
		}

		if ((utf8_strlen($this->request->post['enquiry']) < 5) || (utf8_strlen($this->request->post['enquiry']) > 3000)) {
			$this->error['enquiry'] = $this->language->get('error_enquiry');
		}

		return !$this->error;
	}
}
