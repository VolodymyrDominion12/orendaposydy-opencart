<?php
/**
 * Контролер подій сповіщень «Крістал: сповіщення» (023).
 * Слухає:
 *   - catalog/model/checkout/order/addOrderHistory/after (зміна статусу / оплата)
 *   - catalog/model/checkout/order/addOrder/after (створення замовлення в ядрі)
 *   - catalog/model/checkout/simple_order/addOrder/after (створення в темі sauco)
 * PHP 7.3+.
 */
class ControllerExtensionKristalNotify extends Controller {

	public function onOrderHistory(&$route, &$args, &$output) {
		if (!$this->config->get('module_kristal_notify_status')) {
			return null;
		}

		$orderId = isset($args[0]) ? (int)$args[0] : 0;
		$orderStatusId = isset($args[1]) ? (int)$args[1] : 0;

		// Сповіщення надсилаємо при призначенні робочого статусу замовлення (> 0)
		if ($orderId > 0 && $orderStatusId > 0) {
			$this->load->model('extension/kristal/notify');
			$this->model_extension_kristal_notify->sendOrder($orderId);
		}

		return null;
	}

	public function onOrder(&$route, &$args, &$output) {
		if (!$this->config->get('module_kristal_notify_status')) {
			return null;
		}

		// $output для addOrder — це створений order_id
		$orderId = (int)$output;

		if ($orderId > 0) {
			$this->load->model('extension/kristal/notify');
			$this->model_extension_kristal_notify->sendOrder($orderId);
		}

		return null;
	}
}
