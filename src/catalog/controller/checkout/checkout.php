<?php
/**
 * Редирект checkout/checkout на checkout/order (фіча 010).
 * Запобігає 404 помилкам на посиланнях оформлення ядра.
 */
class ControllerCheckoutCheckout extends Controller {
	public function index() {
		$this->response->redirect($this->url->link('checkout/order', '', true));
	}
}
