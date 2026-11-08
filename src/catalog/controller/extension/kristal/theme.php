<?php
/**
 * Тема «Крістал» (фіча 003): дані для шапки/футера через події, без правок ядра.
 *
 * Події (міграція 0005_kristal_theme_events):
 *   view/common/header/before       → header()    NAP, меню, лічильник кошика
 *   view/common/footer/before       → footer()    NAP, колонки, політика, рік
 *   view/* /before (sort 600)       → template()  шаблон, якого немає ні в kristal, ні в default, береться з sauco (до 010)
 *   view/* /after                   → page()      заповнює <!--kristal:head--> у шапці: compat (jQuery/Bootstrap) для чужих шаблонів, noindex
 *   controller/common/menu/before   → skip()      меню ядра не будуємо (N+1) — у темі власне з кешу
 *   controller/common/cart/before   → skip()      випадний кошик ядра не потрібен (рахує підсумки) — у темі лише лічильник
 *
 * Усе вмикається лише коли вибрано каталог теми `kristal`; з `sauco` ці події нічого не роблять.
 */
class ControllerExtensionKristalTheme extends Controller {
	const PLACEHOLDER = '<!--kristal:head-->';

	/** Маршрути шаблонів, які не індексуються */
	private static $noindex = array('error/not_found', 'kristal/styleguide');

	/** Спільні дані шапки/футера за запит (контролер створюється заново на кожну подію) */
	private static $shared = null;

	public function header(&$route, &$data) {
		if (!$this->active()) {
			return null;
		}

		$data = array_merge($data, $this->shared());

		$data['k_placeholder'] = self::PLACEHOLDER;
		$data['k_css'] = $this->asset('stylesheet/kristal.css');
		$data['k_font'] = 'catalog/view/theme/kristal/fonts/manrope.woff2';

		return null;
	}

	public function footer(&$route, &$data) {
		if (!$this->active()) {
			return null;
		}

		$data = array_merge($data, $this->shared());

		$data['k_js'] = $this->asset('js/kristal.js');
		$data['k_year'] = date('Y');
		$data['k_fondy'] = (bool)$this->config->get('payment_oplata_status');
		$data['k_privacy_href'] = '';

		$privacy_id = (int)$this->config->get('config_account_id');

		if ($privacy_id) {
			$this->load->model('catalog/information');

			if ($this->model_catalog_information->getInformation($privacy_id)) {
				$data['k_privacy_href'] = $this->url->link('information/information', 'information_id=' . $privacy_id);
			}
		}

		// Карта: геокоординати з NAP, інакше адреса; без адреси — блоку немає
		$nap = $data['k_nap'];
		$query = $nap['geo'] ? $nap['geo']['lat'] . ',' . $nap['geo']['lng'] : trim($nap['city'] . ' ' . $nap['address']);

		$data['k_map_url'] = $query !== '' ? 'https://www.google.com/maps/search/?api=1&query=' . rawurlencode($query) : '';
		$data['k_map_embed'] = $query !== '' ? 'https://www.google.com/maps?q=' . rawurlencode($query) . '&output=embed' : '';

		return null;
	}

	/** Шаблон без варіанта в kristal і default (напр. checkout/order теми sauco) — тимчасово з sauco, до 010. */
	public function template(&$route, &$data) {
		if (!$this->active()) {
			return null;
		}

		$file = $route . '.twig';

		if (!is_file(DIR_TEMPLATE . 'kristal/template/' . $file) && !is_file(DIR_TEMPLATE . 'default/template/' . $file)
			&& is_file(DIR_TEMPLATE . 'sauco/template/' . $file)) {
			$this->config->set('template_directory', 'sauco/template/');
		}

		return null;
	}

	/** Головний шаблон сторінки відрендерено: вирішуємо, що вставити в <head> замість заглушки. */
	public function page(&$route, &$data, &$output) {
		if ($route === 'common/header' || !is_string($output) || strpos($output, self::PLACEHOLDER) === false) {
			return null;
		}

		$head = array();

		if (in_array($route, self::$noindex, true)) {
			$head[] = '<meta name="robots" content="noindex, follow">';
		}

		// Сторінка не з шаблону kristal (категорія, товар, кошик до 004/005/010) — їй потрібні jQuery і Bootstrap
		if ($this->config->get('template_directory') !== 'kristal/template/') {
			$head[] = '<link href="catalog/view/javascript/bootstrap/css/bootstrap.min.css" rel="stylesheet">';
			$head[] = '<link href="catalog/view/javascript/font-awesome/css/font-awesome.min.css" rel="stylesheet">';
			$head[] = '<script src="catalog/view/javascript/jquery/jquery-3.7.1.min.js"></script>';
			$head[] = '<script src="catalog/view/javascript/bootstrap/js/bootstrap.min.js"></script>';
			$head[] = '<script src="catalog/view/javascript/common.js"></script>';
			$output = str_replace('<body class="k-body">', '<body class="k-body k-compat">', $output);
		}

		// Сторінка з шаблону kristal: прибрати скрипти/стилі jQuery-плагінів, які контролери ядра додають у document
		// (напр. datetimepicker у product/product) — без jQuery вони лише падають і важать
		if ($this->config->get('template_directory') === 'kristal/template/') {
			$output = preg_replace('#<(?:script src|link href)="catalog/view/javascript/jquery/[^"]*"[^>]*>(?:</script>)?\s*#', '', $output);
		}

		$output = str_replace(self::PLACEHOLDER, implode("\n", $head), $output);

		return null;
	}

	/** Зупиняє контролер ядра (повертає непорожній рядок — ядро бере його як вивід). */
	public function skip(&$route, &$data) {
		return $this->active() ? ' ' : null;
	}

	private function active() {
		if ($this->config->get('config_theme') === 'default') {
			return $this->config->get('theme_default_directory') === 'kristal';
		}

		return $this->config->get('config_theme') === 'kristal';
	}

	private function shared() {
		if (self::$shared !== null) {
			return self::$shared;
		}

		$this->load->language('extension/kristal/theme');
		$this->load->model('extension/kristal/menu');

		$nap = \Kristal\Nap::get($this->registry);

		$names = array('everyday' => $this->language->get('k_everyday'));

		foreach (\Kristal\Nap::dayCodes() as $code) {
			$names[$code] = $this->language->get('k_day_' . $code);
		}

		$hours = \Kristal\Theme::hoursText($nap['hours'], $names);

		if (!$hours && $nap['hours_note'] !== '') {
			$hours = array($nap['hours_note']);
		}

		// Перший номер з Viber / Telegram (для кнопок месенджерів); Telegram — також нік із соцмереж
		$viber = '';
		$telegram = isset($nap['social']['telegram']) ? $nap['social']['telegram'] : '';

		foreach ($nap['phones'] as $phone) {
			if ($viber === '' && $phone['viber'] !== '') {
				$viber = $phone['viber'];
			}

			if ($telegram === '' && $phone['telegram'] !== '') {
				$telegram = $phone['telegram'];
			}
		}

		$social = $nap['social'];
		unset($social['telegram']);

		self::$shared = array(
			'k_nap'        => $nap,
			'k_phone'      => $nap['primary_phone'],
			'k_viber'      => $viber,
			'k_telegram'   => $telegram,
			'k_social'     => $social,
			'k_hours'      => $hours,
			'k_cats'       => $this->model_extension_kristal_menu->getTree(),
			'k_logo'       => 'catalog/view/theme/kristal/image/emblem-96.webp',
			// Корінь сайту замість index.php?route=common/home (ядро не має ЧПУ для головної)
			'k_home'       => !empty($this->request->server['HTTPS']) ? $this->config->get('config_ssl') : $this->config->get('config_url'),
			'k_cart_href'  => $this->url->link('checkout/cart'),
			'k_cart_count' => $this->cartPositions()
		);

		// Шаблонам сторінок (404, «Дякуємо») — через мовні дані: event/language ядра додає їх у кожен view
		$cats = self::$shared['k_cats'];
		$this->language->set('k_catalog_href', $cats ? $cats[0]['href'] : self::$shared['k_home']);
		$this->language->set('k_phone_tel', $nap['primary_phone'] ? $nap['primary_phone']['tel'] : '');
		$this->language->set('k_phone_display', $nap['primary_phone'] ? $nap['primary_phone']['display'] : '');
		$this->language->set('k_viber_href', $viber);
		$this->language->set('k_telegram_href', $telegram);
		$this->language->set('k_cart_url', self::$shared['k_cart_href']);

		return self::$shared;
	}

	/** Кількість позицій у кошику (рядків oc_cart), а не сума штук — AC-7. Один запит за індексом `cart_id`. */
	private function cartPositions() {
		$query = $this->db->query("SELECT COUNT(*) AS total FROM `" . DB_PREFIX . "cart`
			WHERE api_id = '" . (isset($this->session->data['api_id']) ? (int)$this->session->data['api_id'] : 0) . "'
			AND customer_id = '" . (int)$this->customer->getId() . "'
			AND session_id = '" . $this->db->escape($this->session->getId()) . "'");

		return (int)$query->row['total'];
	}

	/** Шлях до файлу теми з версією за часом зміни (скидання кешу браузера після деплою) */
	private function asset($path) {
		$file = DIR_TEMPLATE . 'kristal/' . $path;

		return 'catalog/view/theme/kristal/' . $path . (is_file($file) ? '?v=' . filemtime($file) : '');
	}
}
