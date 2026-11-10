<?php
/**
 * Контролер портфоліо подій (kristal_proof, 014).
 * Список кейсів (/portfolio) та детальна сторінка події (/portfolio/{slug}).
 */
class ControllerExtensionKristalCase extends Controller {

	public function index() {
		// Якщо передано case_id, показуємо детальну сторінку
		if (isset($this->request->get['case_id'])) {
			return $this->info();
		}

		$this->load->language('extension/kristal/theme');
		$this->load->model('extension/kristal/case');
		$this->load->model('extension/kristal/testimonial');
		$this->load->model('tool/image');

		$filter_event_type = isset($this->request->get['type']) ? (string)$this->request->get['type'] : '';
		if ($filter_event_type === 'all') {
			$filter_event_type = '';
		}

		$page = isset($this->request->get['page']) ? (int)$this->request->get['page'] : 1;
		$limit = 12;

		$filter_data = array(
			'filter_event_type' => $filter_event_type,
			'start'             => ($page - 1) * $limit,
			'limit'             => $limit
		);

		$total_cases = $this->model_extension_kristal_case->getTotalCases($filter_data);
		$results = $this->model_extension_kristal_case->getCases($filter_data);

		$data['cases'] = array();

		foreach ($results as $result) {
			if ($result['image'] && is_file(DIR_IMAGE . $result['image'])) {
				$image = $this->model_tool_image->resize($result['image'], 600, 400);
			} else {
				$image = $this->model_tool_image->resize('placeholder.png', 600, 400);
			}

			$data['cases'][] = array(
				'case_id'     => $result['case_id'],
				'title'       => $result['title'],
				'event_type'  => $result['event_type'],
				'guests'      => (int)$result['guests'],
				'location'    => $result['location'],
				'date_event'  => $result['date_event'],
				'summary'     => $result['summary'],
				'thumb'       => $image,
				'href'        => $this->url->link('extension/kristal/case/info', 'case_id=' . $result['case_id'])
			);
		}

		// Відгуки для блоку довіри
		$data['testimonials'] = array();
		$testimonials_raw = $this->model_extension_kristal_testimonial->getTestimonials(array('limit' => 3));
		foreach ($testimonials_raw as $t) {
			$data['testimonials'][] = array(
				'author_name' => $t['author_name'],
				'author_role' => $t['author_role'],
				'rating'      => (int)$t['rating'],
				'text'        => $t['text'],
				'event_title' => $t['event_title'],
				'date_added'  => date('d.m.Y', strtotime($t['date_added']))
			);
		}

		$data['active_filter'] = $filter_event_type ? $filter_event_type : 'all';

		$data['filters'] = array(
			array('code' => 'all', 'title' => 'Всі події', 'href' => $this->url->link('extension/kristal/case')),
			array('code' => 'wedding', 'title' => 'Весілля', 'href' => $this->url->link('extension/kristal/case', 'type=wedding')),
			array('code' => 'buffet', 'title' => 'Фуршети', 'href' => $this->url->link('extension/kristal/case', 'type=buffet')),
			array('code' => 'catering', 'title' => 'Кейтеринг', 'href' => $this->url->link('extension/kristal/case', 'type=catering')),
			array('code' => 'corporate', 'title' => 'Корпоративи', 'href' => $this->url->link('extension/kristal/case', 'type=corporate'))
		);

		// Крихти
		$data['breadcrumbs'] = array();
		$data['breadcrumbs'][] = array(
			'text' => 'Головна',
			'href' => $this->url->link('common/home')
		);
		$data['breadcrumbs'][] = array(
			'text' => 'Портфоліо подій',
			'href' => $this->url->link('extension/kristal/case')
		);

		// Метатеги
		$this->document->setTitle('Портфоліо подій та кейси сервірування | Оренда посуду «Крістал» Львів');
		$this->document->setDescription('Фото та кейси оформлення весіль, фуршетів, корпоративів та кейтерингу посудом «Крістал». Реальні події у Львові та області, використаний посуд та текстиль.');
		$this->document->addLink($this->url->link('extension/kristal/case'), 'canonical');

		// JSON-LD мікророзмітка
		$bc_items = array(
			array('name' => 'Головна', 'url' => $this->url->link('common/home')),
			array('name' => 'Портфоліо подій', 'url' => $this->url->link('extension/kristal/case'))
		);
		$data['jsonld'] = \Kristal\Jsonld::render(\Kristal\Jsonld::breadcrumbs($bc_items));

		$data['column_left'] = $this->load->controller('common/column_left');
		$data['column_right'] = $this->load->controller('common/column_right');
		$data['content_top'] = $this->load->controller('common/content_top');
		$data['content_bottom'] = $this->load->controller('common/content_bottom');
		$data['footer'] = $this->load->controller('common/footer');
		$data['header'] = $this->load->controller('common/header');

		$this->response->setOutput($this->load->view('extension/kristal/case_list', $data));
	}

	public function info() {
		$this->load->language('extension/kristal/theme');
		$this->load->model('extension/kristal/case');
		$this->load->model('tool/image');

		$case_id = isset($this->request->get['case_id']) ? (int)$this->request->get['case_id'] : 0;
		$case_info = $this->model_extension_kristal_case->getCase($case_id);

		if (!$case_info) {
			$this->response->redirect($this->url->link('extension/kristal/case'));
			return;
		}

		$data['case_id'] = $case_info['case_id'];
		$data['title'] = $case_info['title'];
		$data['event_type'] = $case_info['event_type'];
		$data['guests'] = (int)$case_info['guests'];
		$data['location'] = $case_info['location'];
		$data['date_event'] = $case_info['date_event'];
		$data['summary'] = $case_info['summary'];
		$data['description'] = html_entity_decode($case_info['description'], ENT_QUOTES, 'UTF-8');

		if ($case_info['image'] && is_file(DIR_IMAGE . $case_info['image'])) {
			$data['thumb'] = $this->model_tool_image->resize($case_info['image'], 800, 500);
			$data['popup'] = HTTP_SERVER . 'image/' . $case_info['image'];
		} else {
			$data['thumb'] = $this->model_tool_image->resize('placeholder.png', 800, 500);
			$data['popup'] = '';
		}

		// Галерея зображень кейсу
		$data['images'] = array();
		$images = $this->model_extension_kristal_case->getCaseImages($case_id);
		foreach ($images as $img) {
			if ($img['image'] && is_file(DIR_IMAGE . $img['image'])) {
				$data['images'][] = array(
					'popup' => HTTP_SERVER . 'image/' . $img['image'],
					'thumb' => $this->model_tool_image->resize($img['image'], 400, 300)
				);
			}
		}

		// Посуд, використаний на цій події
		$data['products'] = array();
		$products = $this->model_extension_kristal_case->getCaseProducts($case_id);
		foreach ($products as $prod) {
			if ($prod['image'] && is_file(DIR_IMAGE . $prod['image'])) {
				$p_image = $this->model_tool_image->resize($prod['image'], 300, 300);
			} else {
				$p_image = $this->model_tool_image->resize('placeholder.png', 300, 300);
			}

			$data['products'][] = array(
				'product_id' => $prod['product_id'],
				'name'       => $prod['name'],
				'price'      => round((float)$prod['price']),
				'unit'       => !empty($prod['unit']) ? $prod['unit'] : 'шт',
				'deposit'    => (float)$prod['deposit'],
				'thumb'      => $p_image,
				'href'       => $this->url->link('product/product', 'product_id=' . $prod['product_id'])
			);
		}

		// Сусідні/схожі кейси
		$data['related_cases'] = array();
		$other_cases = $this->model_extension_kristal_case->getCases(array('limit' => 3));
		foreach ($other_cases as $oc) {
			if ($oc['case_id'] == $case_id) {
				continue;
			}
			$data['related_cases'][] = array(
				'title'    => $oc['title'],
				'location' => $oc['location'],
				'guests'   => (int)$oc['guests'],
				'thumb'    => $oc['image'] && is_file(DIR_IMAGE . $oc['image']) ? $this->model_tool_image->resize($oc['image'], 400, 260) : $this->model_tool_image->resize('placeholder.png', 400, 260),
				'href'     => $this->url->link('extension/kristal/case/info', 'case_id=' . $oc['case_id'])
			);
		}

		// Крихти
		$data['breadcrumbs'] = array();
		$data['breadcrumbs'][] = array(
			'text' => 'Головна',
			'href' => $this->url->link('common/home')
		);
		$data['breadcrumbs'][] = array(
			'text' => 'Портфоліо подій',
			'href' => $this->url->link('extension/kristal/case')
		);
		$data['breadcrumbs'][] = array(
			'text' => $case_info['title'],
			'href' => $this->url->link('extension/kristal/case/info', 'case_id=' . $case_id)
		);

		// Метатеги
		$this->document->setTitle($case_info['title'] . ' | Кейси «Крістал»');
		$this->document->setDescription(mb_substr(strip_tags($case_info['summary']), 0, 160));
		$this->document->addLink($this->url->link('extension/kristal/case/info', 'case_id=' . $case_id), 'canonical');

		// Мікророзмітка
		$bc_items = array(
			array('name' => 'Головна', 'url' => $this->url->link('common/home')),
			array('name' => 'Портфоліо подій', 'url' => $this->url->link('extension/kristal/case')),
			array('name' => $case_info['title'], 'url' => $this->url->link('extension/kristal/case/info', 'case_id=' . $case_id))
		);
		$data['jsonld'] = \Kristal\Jsonld::render(\Kristal\Jsonld::breadcrumbs($bc_items));

		$data['column_left'] = $this->load->controller('common/column_left');
		$data['column_right'] = $this->load->controller('common/column_right');
		$data['content_top'] = $this->load->controller('common/content_top');
		$data['content_bottom'] = $this->load->controller('common/content_bottom');
		$data['footer'] = $this->load->controller('common/footer');
		$data['header'] = $this->load->controller('common/header');

		$this->response->setOutput($this->load->view('extension/kristal/case_info', $data));
	}
}
