<?php
/**
 * Контролер готових комплектів для подій (фіча 007 kristal_kit та 006 kristal_pages).
 * Сторінки подій (весілля, фуршет, кейтеринг, корпоратив) та пакетне додавання в кошик.
 * PHP 7.3+.
 */
class ControllerExtensionKristalKit extends Controller {

	/**
	 * Сторінка події «Весілля» (ЧПУ: /vesillya).
	 */
	public function wedding() {
		$this->request->get['event'] = 'wedding';
		return $this->event();
	}

	/**
	 * Сторінка події «Фуршет і кава-брейк» (ЧПУ: /furshet).
	 */
	public function buffet() {
		$this->request->get['event'] = 'buffet';
		return $this->event();
	}

	/**
	 * Сторінка події «Кейтеринг» (ЧПУ: /keiterynh).
	 */
	public function catering() {
		$this->request->get['event'] = 'catering';
		return $this->event();
	}

	/**
	 * Сторінка події «Корпоратив» (ЧПУ: /korporatyv).
	 */
	public function corporate() {
		$this->request->get['event'] = 'corporate';
		return $this->event();
	}

	/**
	 * Універсальний обробник сторінки події.
	 */
	public function event() {
		$this->load->language('extension/kristal/kit');
		$this->load->model('extension/kristal/kit');

		$event_type = isset($this->request->get['event']) ? trim($this->request->get['event']) : 'wedding';
		$valid_events = array('wedding', 'buffet', 'catering', 'corporate');
		if (!in_array($event_type, $valid_events)) {
			$event_type = 'wedding';
		}

		$this->document->setTitle($this->language->get('meta_title_' . $event_type));
		$this->document->setDescription($this->language->get('meta_description_' . $event_type));

		// Canonical
		$slug_map = array(
			'wedding'   => 'vesillya',
			'buffet'    => 'furshet',
			'catering'  => 'keiterynh',
			'corporate' => 'korporatyv'
		);
		$slug = isset($slug_map[$event_type]) ? $slug_map[$event_type] : 'vesillya';
		$canonical = $this->url->link('extension/kristal/kit/' . $event_type);
		$this->document->addLink($canonical, 'canonical');
		$data['canonical'] = $canonical;

		// Хлібні крихти
		$data['breadcrumbs'] = array();
		$data['breadcrumbs'][] = array(
			'text' => $this->language->get('text_home'),
			'href' => $this->url->link('common/home')
		);
		$data['breadcrumbs'][] = array(
			'text' => $this->language->get('text_events'),
			'href' => $this->url->link('extension/kristal/kit/' . $event_type)
		);
		$data['breadcrumbs'][] = array(
			'text' => $this->language->get('text_' . $event_type),
			'href' => $canonical
		);

		// Тексти сторінки
		$data['text_hero_label']    = $this->language->get('text_hero_label_' . $event_type);
		$data['text_hero_title']    = $this->language->get('text_hero_title_' . $event_type);
		$data['text_hero_lead']     = $this->language->get('text_hero_lead_' . $event_type);
		$data['text_fact_price']    = $this->language->get('text_fact_price_' . $event_type);
		$data['text_fact_delivery'] = $this->language->get('text_fact_delivery');
		$data['text_fact_time']     = $this->language->get('text_fact_time');
		$data['text_btn_calc']      = $this->language->get('text_btn_calc_' . $event_type);
		$data['text_btn_view_sets'] = $this->language->get('text_btn_view_sets');

		$data['text_sets_label']    = $this->language->get('text_sets_label');
		$data['text_sets_title']    = $this->language->get('text_sets_title_' . $event_type);
		$data['text_guests']        = $this->language->get('text_guests');
		$data['text_custom_guests'] = $this->language->get('text_custom_guests');
		$data['text_per_guest']     = $this->language->get('text_per_guest');
		$data['text_btn_add_set']   = $this->language->get('text_btn_add_set');

		$data['text_addons_label']  = $this->language->get('text_addons_label_' . $event_type);
		$data['text_addons_title']  = $this->language->get('text_addons_title');
		$data['text_gallery_label'] = $this->language->get('text_gallery_label');
		$data['text_gallery_title'] = $this->language->get('text_gallery_title');
		$data['text_portfolio_link']= $this->language->get('text_portfolio_link');

		$data['text_faq_label']     = $this->language->get('text_faq_label');
		$data['text_faq_title']     = $this->language->get('text_faq_title_' . $event_type);

		// Завантаження комплектів
		$kits = $this->model_extension_kristal_kit->getKitsByEventType($event_type);
		$initial_guests = 100;

		foreach ($kits as &$kit) {
			$total_initial = $kit['price_per_guest_num'] * $initial_guests;
			$kit['initial_total'] = number_format($total_initial, 0, '.', ' ') . ' ₴';
			$kit['initial_guests_label'] = sprintf($this->language->get('text_per_day'), $initial_guests);
		}
		unset($kit);

		$data['kits'] = $kits;
		$data['initial_guests'] = $initial_guests;
		$data['action_add_kit'] = $this->url->link('extension/kristal/kit/add', '', true);
		$data['action_cart'] = $this->url->link('checkout/order');
		$data['calculator_url'] = $this->url->link('common/home') . '#lead';

		// Дані форми ліда
		$data['lead_action'] = $this->url->link('extension/kristal/lead/submit', '', true);
		$data['min_event_date'] = date('Y-m-d');

		// Додаткові позиції під конкретну подію («Все, крім гостей»)
		$data['addons'] = $this->getAddonsForEvent($event_type);

		// Відгук під конкретну подію
		$data['review'] = $this->getReviewForEvent($event_type);

		// FAQ під конкретну подію
		$data['faq'] = $this->getFaqForEvent($event_type);

		// Schema.org FAQPage JSON-LD
		$faq_schema = array(
			'@context'   => 'https://schema.org',
			'@type'      => 'FAQPage',
			'mainEntity' => array()
		);
		foreach ($data['faq'] as $f) {
			$faq_schema['mainEntity'][] = array(
				'@type'          => 'Question',
				'name'           => $f['q'],
				'acceptedAnswer' => array(
					'@type' => 'Answer',
					'text'  => $f['a']
				)
			);
		}
		$data['faq_schema_json'] = json_encode($faq_schema, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);

		$data['header'] = $this->load->controller('common/header');
		$data['footer'] = $this->load->controller('common/footer');

		$this->response->setOutput($this->load->view('extension/kristal/event', $data));
	}

	private function getAddonsForEvent($event_type) {
		if ($event_type === 'buffet') {
			return array(
				array(
					'name'  => 'Коктейльні столи',
					'desc'  => 'високі фуршетні · від ',
					'price' => '200 ₴',
					'href'  => $this->url->link('product/product', 'product_id=50066'),
					'icon'  => 'i-table'
				),
				array(
					'name'  => 'Кавомашина Saeko',
					'desc'  => 'професійна · від ',
					'price' => '1 000 ₴',
					'href'  => $this->url->link('product/product', 'product_id=50051'),
					'icon'  => 'i-coffee'
				),
				array(
					'name'  => 'Термопот 5 л',
					'desc'  => 'постійний окріп · від ',
					'price' => '180 ₴',
					'href'  => $this->url->link('product/product', 'product_id=50053'),
					'icon'  => 'i-coffee'
				),
				array(
					'name'  => 'Діспенсери для лимонаду',
					'desc'  => 'скло 8 л з краном · від ',
					'price' => '150 ₴',
					'href'  => $this->url->link('product/product', 'product_id=50062'),
					'icon'  => 'i-glass'
				)
			);
		} elseif ($event_type === 'catering') {
			return array(
				array(
					'name'  => 'Чафінгдіші 9 л',
					'desc'  => 'підігрів на пальниках · від ',
					'price' => '450 ₴',
					'href'  => $this->url->link('product/product', 'product_id=50043'),
					'icon'  => 'i-pot'
				),
				array(
					'name'  => 'Термобокси 40 л',
					'desc'  => 'збереження температури · від ',
					'price' => '150 ₴',
					'href'  => $this->url->link('product/product', 'product_id=50050'),
					'icon'  => 'i-box'
				),
				array(
					'name'  => 'Гастроємності GN 1/1',
					'desc'  => 'нержавіюча сталь · від ',
					'price' => '40 ₴',
					'href'  => $this->url->link('product/product', 'product_id=50048'),
					'icon'  => 'i-pot'
				),
				array(
					'name'  => 'Каструлі 20 л',
					'desc'  => 'для супів і напоїв · від ',
					'price' => '120 ₴',
					'href'  => $this->url->link('product/product', 'product_id=50047'),
					'icon'  => 'i-pot'
				)
			);
		} elseif ($event_type === 'corporate') {
			return array(
				array(
					'name'  => 'Мобільна барна стійка',
					'desc'  => 'з підсвіткою 2 м · від ',
					'price' => '2 500 ₴',
					'href'  => $this->url->link('product/product', 'product_id=50056'),
					'icon'  => 'i-bar'
				),
				array(
					'name'  => 'Лаунж-меблі',
					'desc'  => 'дивани та крісла · від ',
					'price' => '700 ₴',
					'href'  => $this->url->link('product/product', 'product_id=50072'),
					'icon'  => 'i-chair'
				),
				array(
					'name'  => 'Шатро 5×10 м',
					'desc'  => 'з монтажем · від ',
					'price' => '1 500 ₴',
					'href'  => $this->url->link('product/product', 'product_id=50086'),
					'icon'  => 'i-tent'
				),
				array(
					'name'  => 'Бармени та офіціанти',
					'desc'  => 'обслуговування під ключ',
					'price' => '',
					'href'  => '#lead',
					'icon'  => 'i-people'
				)
			);
		}

		// За замовчуванням — весілля
		return array(
			array(
				'name'  => 'Стільці Chiavari',
				'desc'  => 'білі й золоті · від ',
				'price' => '120 ₴',
				'href'  => $this->url->link('product/product', 'product_id=50068'),
				'icon'  => 'i-chair'
			),
			array(
				'name'  => 'Банкетні столи',
				'desc'  => 'круглі на 10 гостей · від ',
				'price' => '250 ₴',
				'href'  => $this->url->link('product/product', 'product_id=50065'),
				'icon'  => 'i-table'
			),
			array(
				'name'  => 'Шатро',
				'desc'  => 'з монтажем · від ',
				'price' => '1 500 ₴',
				'href'  => $this->url->link('product/product', 'product_id=50086'),
				'icon'  => 'i-tent'
			),
			array(
				'name'  => 'Офіціанти й бармени',
				'desc'  => 'ціна за запитом',
				'price' => '',
				'href'  => '#lead',
				'icon'  => 'i-people'
			)
		);
	}

	private function getReviewForEvent($event_type) {
		if ($event_type === 'buffet') {
			return array(
				'stars'  => 5,
				'text'   => 'Брали в оренду коктейльні столики, келихи та кавомашину для презентації на 80 учасників. Посуд приїхав у ідеальному стані, доставка хвилина в хвилину. Дуже зручно, що не потрібно мити після заходу!',
				'author' => 'Марта В. · конференція, 80 учасників'
			);
		} elseif ($event_type === 'catering') {
			return array(
				'stars'  => 5,
				'text'   => 'Постійно співпрацюємо з «Крістал» для виїзних кейтерингів. Завжди виручають з великою кількістю чафінгдішів, термобоксів та гастроємностей. Надійний партнер для будь-якого виїзного банкету.',
				'author' => 'Андрій Шеф · виїзний кейтеринг, 250 гостей'
			);
		} elseif ($event_type === 'corporate') {
			return array(
				'stars'  => 5,
				'text'   => 'Організовували річницю компанії на 150 людей. Замовили посуд, барну стійку та лаунж-зону. Розрахунок за безготівкою з усіма бухгалтерськими документами отримали миттєво. Рекомендуємо!',
				'author' => 'IT-компанія SoftPeak · корпоратив, 150 осіб'
			);
		}

		return array(
			'stars'  => 5,
			'text'   => 'Замовляли посуд Royal та стільці Chiavari на весілля. Все приїхало ідеально чистим, у зручних боксах, вчасно. Менеджер дуже допоміг із розрахунком потрібної кількості келихів.',
			'author' => 'Оксана і Тарас · весілля, 110 гостей'
		);
	}

	private function getFaqForEvent($event_type) {
		if ($event_type === 'buffet') {
			return array(
				array(
					'q' => 'Скільки келихів та тарілок потрібно на фуршет?',
					'a' => 'На фуршеті гості часто змінюють посуд, тому норма становить 1.5–2 келихи та 2 десертні тарілки на людину. Наші готові комплекти вже містять цей запас.',
					'open' => true
				),
				array(
					'q' => 'Чи надаєте ви обладнання для підігріву кави та чаю?',
					'a' => 'Так, у нас є професійні кавомашини Saeko, фільтрові кавоварки та термопоти на 5–10 літрів, які підтримують постійну температуру окропу.',
					'open' => false
				),
				array(
					'q' => 'Чи потрібно мити посуд після фуршету?',
					'a' => 'Ні! Базове миття входить у вартість оренди. Ви лише складаєте посуд назад у наші бокси, а ми миємо його у професійних посудомийних машинах.',
					'open' => false
				)
			);
		} elseif ($event_type === 'catering') {
			return array(
				array(
					'q' => 'Які умови співпраці для кейтерингових компаній?',
					'a' => 'Для постійних партнерів діє програма B2B зі спеціальними тарифами, бронюванням без застави за договором та пріоритетною доставкою.',
					'open' => true
				),
				array(
					'q' => 'Чи є у наявності великі обсяги однакового посуду?',
					'a' => 'Так, на нашому складі у Львові є від 500 до 2000 одиниць кожної позиції: тарілки, прибори, келихи, чафінгдіші та термобокси.',
					'open' => false
				),
				array(
					'q' => 'Як швидко можна дозамовити позиції у разі зміни кількості гостей?',
					'a' => 'За наявності на складі ми можемо доукомплектувати замовлення навіть у день виїзду або напередодні.',
					'open' => false
				)
			);
		} elseif ($event_type === 'corporate') {
			return array(
				array(
					'q' => 'Чи працюєте ви за безготівковим розрахунком з юрособами?',
					'a' => 'Так, ми укладаємо офіційний договір, виставляємо рахунок та надаємо повний пакет первинних документів (акт, видаткова накладна).',
					'open' => true
				),
				array(
					'q' => 'Чи входить монтаж меблів та шатрів у вартість?',
					'a' => 'Доставка та монтаж можуть бути включені в кошторис. Наша команда самостійно збере столи, розставить стільці та змонтує шатра.',
					'open' => false
				),
				array(
					'q' => 'Що відбувається у разі бою чи втрати предметів?',
					'a' => 'У кожному замовленні зафіксована фіксована вартість відшкодування за одиницю товару. Стягується лише собівартість розбитого предмета без додаткових штрафів.',
					'open' => false
				)
			);
		}

		return array(
			array(
				'q' => 'Скільки посуду потрібно на 100 гостей?',
				'a' => 'Для банкету — 3–4 тарілки, 3–4 прибори і 2–3 келихи на гостя, плюс 10% запасу. У наших готових комплектах цей розрахунок вже оптимізовано.',
				'open' => true
			),
			array(
				'q' => 'За скільки часу бронювати?',
				'a' => 'У сезон (травень–жовтень) рекомендуємо бронювати за 1–2 місяці. Позиції серії Royal та стільці Chiavari бронюють першими.',
				'open' => false
			),
			array(
				'q' => 'Чи можна поєднати елементи з різних комплектів?',
				'a' => 'Так: наприклад, базовий посуд Classic можна поєднати із золотими підставними тарілками чи золотими приборами Royal. Менеджер підкаже гармонійні комбінації.',
				'open' => false
			)
		);
	}

	/**
	 * AJAX додавання всього комплекту в кошик на N гостей.
	 */
	public function add() {
		$json = array();

		if ($this->request->server['REQUEST_METHOD'] === 'POST') {
			$this->load->language('extension/kristal/kit');
			$this->load->model('extension/kristal/kit');

			$kit_id = isset($this->request->post['kit_id']) ? (int)$this->request->post['kit_id'] : 0;
			$guests = isset($this->request->post['guests']) ? (int)$this->request->post['guests'] : 100;

			if ($guests < 1) {
				$guests = 1;
			}

			$kit = $this->model_extension_kristal_kit->getKit($kit_id);
			if (!$kit) {
				$json['error'] = $this->language->get('error_kit_not_found');
			} else {
				$items = $this->model_extension_kristal_kit->calculateKitItems($kit_id, $guests);

				if (empty($items)) {
					$json['error'] = $this->language->get('error_kit_not_found');
				} else {
					$added_count = 0;
					foreach ($items as $item) {
						$this->cart->add($item['product_id'], $item['quantity']);
						$added_count += $item['quantity'];
					}

					$json['success']     = true;
					$json['message']     = $this->language->get('text_added_success');
					$json['total_items'] = count($items);
					$json['cart_count']  = $this->cart->countProducts();
					$json['redirect']    = $this->url->link('checkout/order');
				}
			}
		} else {
			$json['error'] = 'Invalid request';
		}

		$this->response->addHeader('Content-Type: application/json');
		$this->response->setOutput(json_encode($json));
	}
}
