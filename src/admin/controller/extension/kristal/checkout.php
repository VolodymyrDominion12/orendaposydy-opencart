<?php
/**
 * Контролер адмінки «Крістал: кошик та оренда» (фіча 010).
 * Відображення блоку параметрів оренди на сторінці перегляду замовлення (sale/order/info).
 * PHP 7.3+.
 */
class ControllerExtensionKristalCheckout extends Controller {

	/**
	 * Подія admin/view/sale/order_info/after.
	 *
	 * @param string $route
	 * @param array  $data
	 * @param string $output
	 * @return void
	 */
	public function orderInfo(&$route, &$data, &$output) {
		if (!is_string($output) || empty($this->request->get['order_id'])) {
			return;
		}

		$order_id = (int)$this->request->get['order_id'];
		$this->load->model('extension/kristal/checkout');
		$rental = $this->model_extension_kristal_checkout->getRental($order_id);

		if (!$rental) {
			return;
		}

		$this->load->language('extension/kristal/checkout');

		$date_from = date('d.m.Y', strtotime($rental['date_from']));
		$date_to   = date('d.m.Y', strtotime($rental['date_to']));
		$days      = (int)$rental['rental_days'];

		$delivery_text = ($rental['delivery_type'] === 'pickup') ? 'Самовивіз зі складу (вул. Б. Хмельницького, 106)' : 'Доставка за адресою';
		if ($rental['delivery_type'] === 'delivery' && $rental['delivery_address'] !== '') {
			$delivery_text .= ': <strong>' . htmlspecialchars($rental['delivery_address'], ENT_QUOTES, 'UTF-8') . '</strong>';
		}

		$channel_labels = array(
			'viber'    => 'Viber',
			'telegram' => 'Telegram',
			'phone'    => 'Телефонний дзвінок',
			'email'    => 'Email'
		);
		$channel_key = strtolower(trim($rental['contact_channel']));
		$channel_text = isset($channel_labels[$channel_key]) ? $channel_labels[$channel_key] : htmlspecialchars($rental['contact_channel'], ENT_QUOTES, 'UTF-8');

		$company_html = '';
		if (!empty($rental['is_company'])) {
			$company_html = '<p style="margin-top:8px;"><strong>Реквізити юрособи:</strong><br>' .
				htmlspecialchars($rental['company_name'], ENT_QUOTES, 'UTF-8') .
				' (ЄДРПОУ: <code>' . htmlspecialchars($rental['edrpou'], ENT_QUOTES, 'UTF-8') . '</code>)</p>';
		}

		$panel_html = '
		<div class="panel panel-default" style="border-left: 4px solid #b89758; margin-bottom: 20px;">
			<div class="panel-heading" style="background: #fafafa;">
				<h3 class="panel-title" style="color: #8c6d37; font-weight: bold;"><i class="fa fa-calendar"></i> Параметри оренди події</h3>
			</div>
			<div class="panel-body">
				<div class="row">
					<div class="col-sm-4">
						<p><strong>Дати оренди:</strong><br>
						<span class="label label-primary" style="font-size: 13px; padding: 4px 8px; display: inline-block; margin-top: 4px;">' .
						$date_from . ' — ' . $date_to . ' (' . $days . ' ' . ($days === 1 ? 'доба' : ($days < 5 ? 'доби' : 'діб')) . ')</span></p>
					</div>
					<div class="col-sm-4">
						<p><strong>Отримання / доставка:</strong><br>' . $delivery_text . '</p>
					</div>
					<div class="col-sm-4">
						<p><strong>Зручний зв\'язок для клієнта:</strong><br>
						<span class="label label-info" style="font-size: 12px;">' . $channel_text . '</span></p>' .
						$company_html . '
					</div>
				</div>
			</div>
		</div>';

		$marker = '<table class="table table-bordered">';
		$pos = strpos($output, $marker);
		if ($pos !== false) {
			$output = substr_replace($output, $panel_html . $marker, $pos, strlen($marker));
		} else {
			// Якщо маркер не знайдено, додаємо перед закриттям container-fluid
			$container_end = '</div>' . "\n" . '</div>' . "\n" . '{{ footer }}';
			$pos = strrpos($output, '</div>');
			if ($pos !== false) {
				$output = substr_replace($output, $panel_html . '</div>', $pos, strlen('</div>'));
			}
		}
	}
}
