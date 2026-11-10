<?php
/**
 * Контролер блогу та статей (kristal_blog, 013).
 * Список статей (/blog) та окрема стаття (/blog/{slug} або ?post_id=X).
 */
class ControllerExtensionKristalBlog extends Controller {

	public function index() {
		if (isset($this->request->get['post_id'])) {
			return $this->info();
		}

		$this->load->language('extension/kristal/theme');
		$this->load->model('extension/kristal/blog');
		$this->load->model('tool/image');

		$category_id = isset($this->request->get['blog_category_id']) ? (int)$this->request->get['blog_category_id'] : 0;
		$page = isset($this->request->get['page']) ? (int)$this->request->get['page'] : 1;
		$limit = 9;

		$filter_data = array(
			'filter_category_id' => $category_id,
			'start'              => ($page - 1) * $limit,
			'limit'              => $limit
		);

		$total_posts = $this->model_extension_kristal_blog->getTotalPosts($filter_data);
		$results = $this->model_extension_kristal_blog->getPosts($filter_data);

		$data['posts'] = array();

		foreach ($results as $result) {
			if ($result['image'] && is_file(DIR_IMAGE . $result['image'])) {
				$image = $this->model_tool_image->resize($result['image'], 600, 380);
			} else {
				$image = $this->model_tool_image->resize('placeholder.png', 600, 380);
			}

			// Орієнтовний час читання (200 слів/хв)
			$word_count = count(preg_split('/\s+/u', strip_tags($result['content'])));
			$read_min = max(2, (int)ceil($word_count / 180));

			$data['posts'][] = array(
				'post_id'        => $result['post_id'],
				'title'          => $result['title'],
				'summary'        => $result['summary'],
				'author'         => $result['author'],
				'category_title' => $result['category_title'],
				'viewed'         => (int)$result['viewed'],
				'read_min'       => $read_min,
				'thumb'          => $image,
				'date_added'     => date('d.m.Y', strtotime($result['date_added'])),
				'href'           => $this->url->link('extension/kristal/blog/info', 'post_id=' . $result['post_id'])
			);
		}

		// Рубрики
		$data['categories'] = array();
		$data['categories'][] = array(
			'category_id' => 0,
			'title'       => 'Всі статті',
			'href'        => $this->url->link('extension/kristal/blog')
		);

		$cats = $this->model_extension_kristal_blog->getCategories();
		foreach ($cats as $c) {
			$data['categories'][] = array(
				'category_id' => $c['category_id'],
				'title'       => $c['title'],
				'href'        => $this->url->link('extension/kristal/blog', 'blog_category_id=' . $c['category_id'])
			);
		}

		$data['active_category'] = $category_id;

		// Крихти
		$data['breadcrumbs'] = array();
		$data['breadcrumbs'][] = array(
			'text' => 'Головна',
			'href' => $this->url->link('common/home')
		);
		$data['breadcrumbs'][] = array(
			'text' => 'Блог та поради',
			'href' => $this->url->link('extension/kristal/blog')
		);

		// Метатеги
		$this->document->setTitle('Блог про оренду посуду, норми та сервірування | «Крістал» Львів');
		$this->document->setDescription('Корисні статті та чек-листи від експертів оренди посуду «Крістал»: як розрахувати келихи на весілля, норми на фуршет, тренди декору столів 2026.');
		$this->document->addLink($this->url->link('extension/kristal/blog'), 'canonical');

		// Мікророзмітка
		$bc_items = array(
			array('name' => 'Головна', 'url' => $this->url->link('common/home')),
			array('name' => 'Блог та поради', 'url' => $this->url->link('extension/kristal/blog'))
		);
		$data['jsonld'] = \Kristal\Jsonld::render(\Kristal\Jsonld::breadcrumbs($bc_items));

		$data['column_left'] = $this->load->controller('common/column_left');
		$data['column_right'] = $this->load->controller('common/column_right');
		$data['content_top'] = $this->load->controller('common/content_top');
		$data['content_bottom'] = $this->load->controller('common/content_bottom');
		$data['footer'] = $this->load->controller('common/footer');
		$data['header'] = $this->load->controller('common/header');

		$this->response->setOutput($this->load->view('extension/kristal/blog_list', $data));
	}

	public function info() {
		$this->load->language('extension/kristal/theme');
		$this->load->model('extension/kristal/blog');
		$this->load->model('tool/image');

		$post_id = isset($this->request->get['post_id']) ? (int)$this->request->get['post_id'] : 0;
		$post_info = $this->model_extension_kristal_blog->getPost($post_id);

		if (!$post_info) {
			$this->response->redirect($this->url->link('extension/kristal/blog'));
			return;
		}

		$data['post_id'] = $post_info['post_id'];
		$data['title'] = $post_info['title'];
		$data['summary'] = $post_info['summary'];
		$data['content'] = html_entity_decode($post_info['content'], ENT_QUOTES, 'UTF-8');
		$data['author'] = $post_info['author'];
		$data['date_added'] = date('d.m.Y', strtotime($post_info['date_added']));
		$data['viewed'] = (int)$post_info['viewed'];
		$data['category_title'] = $post_info['category_title'];

		if ($post_info['image'] && is_file(DIR_IMAGE . $post_info['image'])) {
			$data['thumb'] = $this->model_tool_image->resize($post_info['image'], 900, 480);
			$data['image_url'] = HTTP_SERVER . 'image/' . $post_info['image'];
		} else {
			$data['thumb'] = $this->model_tool_image->resize('placeholder.png', 900, 480);
			$data['image_url'] = '';
		}

		// Пов'язані товари (посуд, згаданий у статті)
		$data['products'] = array();
		$products = $this->model_extension_kristal_blog->getPostRelatedProducts($post_id);
		foreach ($products as $prod) {
			if ($prod['image'] && is_file(DIR_IMAGE . $prod['image'])) {
				$p_image = $this->model_tool_image->resize($prod['image'], 260, 260);
			} else {
				$p_image = $this->model_tool_image->resize('placeholder.png', 260, 260);
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

		// Інші статті
		$data['related_posts'] = array();
		$other_posts = $this->model_extension_kristal_blog->getPosts(array('limit' => 3));
		foreach ($other_posts as $op) {
			if ($op['post_id'] == $post_id) {
				continue;
			}
			$data['related_posts'][] = array(
				'title'      => $op['title'],
				'summary'    => $op['summary'],
				'date_added' => date('d.m.Y', strtotime($op['date_added'])),
				'thumb'      => $op['image'] && is_file(DIR_IMAGE . $op['image']) ? $this->model_tool_image->resize($op['image'], 380, 220) : $this->model_tool_image->resize('placeholder.png', 380, 220),
				'href'       => $this->url->link('extension/kristal/blog/info', 'post_id=' . $op['post_id'])
			);
		}

		// Крихти
		$data['breadcrumbs'] = array();
		$data['breadcrumbs'][] = array(
			'text' => 'Головна',
			'href' => $this->url->link('common/home')
		);
		$data['breadcrumbs'][] = array(
			'text' => 'Блог',
			'href' => $this->url->link('extension/kristal/blog')
		);
		if (!empty($post_info['category_title']) && !empty($post_info['category_id'])) {
			$data['breadcrumbs'][] = array(
				'text' => $post_info['category_title'],
				'href' => $this->url->link('extension/kristal/blog', 'blog_category_id=' . $post_info['category_id'])
			);
		}
		$data['breadcrumbs'][] = array(
			'text' => $post_info['title'],
			'href' => $this->url->link('extension/kristal/blog/info', 'post_id=' . $post_id)
		);

		// Метатеги
		$this->document->setTitle($post_info['title'] . ' | Блог «Крістал»');
		$this->document->setDescription(mb_substr(strip_tags($post_info['summary']), 0, 160));
		$this->document->addLink($this->url->link('extension/kristal/blog/info', 'post_id=' . $post_id), 'canonical');

		// Мікророзмітка: Breadcrumbs + Article
		$bc_items = array(
			array('name' => 'Головна', 'url' => $this->url->link('common/home')),
			array('name' => 'Блог', 'url' => $this->url->link('extension/kristal/blog')),
			array('name' => $post_info['title'], 'url' => $this->url->link('extension/kristal/blog/info', 'post_id=' . $post_id))
		);
		$bc_jsonld = \Kristal\Jsonld::breadcrumbs($bc_items);

		$post_url = $this->url->link('extension/kristal/blog/info', 'post_id=' . $post_id);
		$article_data = array(
			'title'         => $post_info['title'],
			'summary'       => $post_info['summary'],
			'author'        => $post_info['author'],
			'date_added'    => date('Y-m-d', strtotime($post_info['date_added'])),
			'date_modified' => date('Y-m-d', strtotime($post_info['date_modified']))
		);
		$article_jsonld = \Kristal\Jsonld::article($article_data, $post_url, $data['image_url'], 'Крістал Львів');

		$data['jsonld'] = \Kristal\Jsonld::render($bc_jsonld) . "\n" . \Kristal\Jsonld::render($article_jsonld);

		$data['column_left'] = $this->load->controller('common/column_left');
		$data['column_right'] = $this->load->controller('common/column_right');
		$data['content_top'] = $this->load->controller('common/content_top');
		$data['content_bottom'] = $this->load->controller('common/content_bottom');
		$data['footer'] = $this->load->controller('common/footer');
		$data['header'] = $this->load->controller('common/header');

		$this->response->setOutput($this->load->view('extension/kristal/blog_info', $data));
	}
}
