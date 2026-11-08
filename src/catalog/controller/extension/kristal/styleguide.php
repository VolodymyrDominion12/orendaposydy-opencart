<?php
/**
 * Вітрина компонентів теми «Крістал» (фіча 003, AC-13): index.php?route=extension/kristal/styleguide
 * Лише локально (localhost, 127.0.0.1, *.local, *.test) і лише з темою kristal; деінде — 404. Шаблон — noindex.
 * Це довідник HTML-зразків для фіч 004–012: Twig в OpenCart 3 рендерить без include/import, тому макросів немає.
 */
class ControllerExtensionKristalStyleguide extends Controller {
	public function index() {
		$host = isset($this->request->server['HTTP_HOST']) ? strtolower(preg_replace('/:\d+$/', '', $this->request->server['HTTP_HOST'])) : '';
		$local = in_array($host, array('localhost', '127.0.0.1'), true) || preg_match('/\.(local|test)$/', $host);

		$theme = $this->config->get('config_theme') === 'default' ? $this->config->get('theme_default_directory') : $this->config->get('config_theme');

		if (!$local || $theme !== 'kristal') {
			return new Action('error/not_found');
		}

		$this->load->language('extension/kristal/theme');

		$this->document->setTitle($this->language->get('k_sg_title'));

		$data['heading_title'] = $this->language->get('k_sg_title');

		$data['breadcrumbs'] = array(
			array('text' => $this->language->get('text_home'), 'href' => $this->url->link('common/home')),
			array('text' => $this->language->get('k_sg_title'), 'href' => $this->url->link('extension/kristal/styleguide'))
		);

		$data['header'] = $this->load->controller('common/header');
		$data['footer'] = $this->load->controller('common/footer');

		$this->response->setOutput($this->load->view('kristal/styleguide', $data));
	}
}
