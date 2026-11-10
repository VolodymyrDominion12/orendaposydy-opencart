<?php
/**
 * Контролер відгуків клієнтів (kristal_proof, 014).
 * Сторінка відгуків (/vidhuky) з реальною агрегованою оцінкою та розміткою AggregateRating.
 */
class ControllerExtensionKristalTestimonial extends Controller {

	public function index() {
		$this->load->language('extension/kristal/theme');
		$this->load->model('extension/kristal/testimonial');
		$this->load->model('tool/image');

		$filter_rating = isset($this->request->get['rating']) ? (int)$this->request->get['rating'] : 0;
		$page = isset($this->request->get['page']) ? (int)$this->request->get['page'] : 1;
		$limit = 20;

		$filter_data = array(
			'filter_rating' => $filter_rating,
			'start'         => ($page - 1) * $limit,
			'limit'         => $limit
		);

		$total_testimonials = $this->model_extension_kristal_testimonial->getTotalTestimonials($filter_data);
		$results = $this->model_extension_kristal_testimonial->getTestimonials($filter_data);
		$stats = $this->model_extension_kristal_testimonial->getStats();

		$data['stats'] = array(
			'count'      => $stats['count'],
			'avg_rating' => $stats['avg_rating']
		);

		$data['testimonials'] = array();
		$schema_reviews = array();

		foreach ($results as $result) {
			$data['testimonials'][] = array(
				'testimonial_id' => $result['testimonial_id'],
				'author_name'    => $result['author_name'],
				'author_role'    => $result['author_role'],
				'rating'         => (int)$result['rating'],
				'text'           => $result['text'],
				'event_title'    => $result['event_title'],
				'source'         => $result['source'],
				'source_url'     => $result['source_url'],
				'date_added'     => date('d.m.Y', strtotime($result['date_added']))
			);

			$schema_reviews[] = array(
				'author_name' => $result['author_name'],
				'text'        => $result['text'],
				'rating'      => (int)$result['rating'],
				'date_added'  => $result['date_added']
			);
		}

		$data['active_rating'] = $filter_rating;

		// Крихти
		$data['breadcrumbs'] = array();
		$data['breadcrumbs'][] = array(
			'text' => 'Головна',
			'href' => $this->url->link('common/home')
		);
		$data['breadcrumbs'][] = array(
			'text' => 'Відгуки клієнтів',
			'href' => $this->url->link('extension/kristal/testimonial')
		);

		// Метатеги
		$this->document->setTitle('Відгуки клієнтів про оренду посуду «Крістал» Львів | Рейтинг 5.0 Google');
		$this->document->setDescription('Реальні відгуки наречених, кейтерингових компаній та event-агенцій про прокат посуду «Крістал» у Львові. Відгуки з Google Maps та оцінки якості сервісу.');
		$this->document->addLink($this->url->link('extension/kristal/testimonial'), 'canonical');

		// JSON-LD мікророзмітка: LocalBusiness з AggregateRating та списком Review
		$bc_items = array(
			array('name' => 'Головна', 'url' => $this->url->link('common/home')),
			array('name' => 'Відгуки клієнтів', 'url' => $this->url->link('extension/kristal/testimonial'))
		);
		$bc_jsonld = \Kristal\Jsonld::breadcrumbs($bc_items);

		$nap = \Kristal\Nap::get($this->registry);
		$base_url = $this->url->link('common/home');
		$lb_data = \Kristal\Jsonld::localBusiness($nap, $base_url);

		if ($stats['count'] > 0) {
			$lb_data['aggregateRating'] = \Kristal\Jsonld::aggregateRating($stats['avg_rating'], $stats['count']);
			$reviews_ld = \Kristal\Jsonld::reviews($schema_reviews);
			if (!empty($reviews_ld)) {
				$lb_data['review'] = $reviews_ld;
			}
		}

		$data['jsonld'] = \Kristal\Jsonld::render($bc_jsonld) . "\n" . \Kristal\Jsonld::render($lb_data);

		$data['column_left'] = $this->load->controller('common/column_left');
		$data['column_right'] = $this->load->controller('common/column_right');
		$data['content_top'] = $this->load->controller('common/content_top');
		$data['content_bottom'] = $this->load->controller('common/content_bottom');
		$data['footer'] = $this->load->controller('common/footer');
		$data['header'] = $this->load->controller('common/header');

		$this->response->setOutput($this->load->view('extension/kristal/testimonial_list', $data));
	}
}
