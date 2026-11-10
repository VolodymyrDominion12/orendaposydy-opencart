<?php
use Kristal\Jsonld;
use Kristal\Nap;
use Kristal\Cache_key;

function sample_settings() {
	return array(
		'name'       => 'Крістал',
		'address'    => 'вул. Городоцька, 1',
		'city'       => 'Львів',
		'postcode'   => '',
		'email'      => 'info@example.com',
		'geo_lat'    => '49.8397',
		'geo_lng'    => '24.0297',
		'phones'     => array(
			array('number' => '067 123 45 67', 'label' => 'Менеджер', 'viber' => 1, 'telegram' => 0, 'whatsapp' => 1),
			array('number' => '12345', 'label' => 'невірний'),
			array('number' => '(032) 245-67-89', 'label' => 'Офіс')
		),
		'hours'      => json_encode(array(
			array('days' => array('Mo', 'Tu', 'We', 'Th', 'Fr'), 'from' => '9:00', 'to' => '18:00'),
			array('days' => array('Sa'), 'from' => '10:00', 'to' => '15:00'),
			array('days' => array(), 'from' => '10:00', 'to' => '15:00'),
			array('days' => array('Su'), 'from' => '25:00', 'to' => '15:00')
		)),
		'hours_note' => 'Неділя — за домовленістю',
		'telegram_username' => '@kristal_lviv',
		'instagram'  => 'kristal.lviv',
		'facebook'   => 'https://www.facebook.com/kristal',
		'tiktok'     => '',
		'youtube'    => 'javascript:alert(1)'
	);
}

test('Nap: телефони нормалізовані, невірні відкинуті, посилання месенджерів', function () {
	$nap = Nap::normalize(sample_settings());

	assert_same(2, count($nap['phones']));
	assert_same('+380671234567', $nap['primary_phone']['number']);
	assert_same('+38 067 123 45 67', $nap['phones'][0]['display']);
	assert_same('viber://chat?number=%2B380671234567', $nap['phones'][0]['viber']);
	assert_same('https://wa.me/380671234567', $nap['phones'][0]['whatsapp']);
	assert_same('', $nap['phones'][0]['telegram']);
	assert_same('Офіс', $nap['phones'][1]['label']);
});

test('Nap: графік і соцмережі', function () {
	$nap = Nap::normalize(sample_settings());

	assert_same(array(
		array('days' => array('Mo', 'Tu', 'We', 'Th', 'Fr'), 'from' => '09:00', 'to' => '18:00'),
		array('days' => array('Sa'), 'from' => '10:00', 'to' => '15:00')
	), $nap['hours']);
	assert_same(array(
		'instagram' => 'https://www.instagram.com/kristal.lviv/',
		'facebook'  => 'https://www.facebook.com/kristal',
		'telegram'  => 'https://t.me/kristal_lviv'
	), $nap['social']);
});

test('Nap: порожні налаштування → нічого не вигадано', function () {
	$nap = Nap::normalize(array());

	assert_same('', $nap['name']);
	assert_same(array(), $nap['phones']);
	assert_same(null, $nap['primary_phone']);
	assert_same(null, $nap['geo']);
	assert_same(array(), $nap['social']);
});

test('JSON-LD LocalBusiness: E.164, адреса, графік, sameAs, без порожніх полів', function () {
	$data = Jsonld::localBusiness(Nap::normalize(sample_settings()), 'https://orendaposydy.com/', '');

	assert_same('LocalBusiness', $data['@type']);
	assert_same('+380671234567', $data['telephone']);
	assert_same(array('@type' => 'PostalAddress', 'streetAddress' => 'вул. Городоцька, 1', 'addressLocality' => 'Львів', 'addressCountry' => 'UA'), $data['address']);
	assert_same(49.8397, $data['geo']['latitude']);
	assert_same(array('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'), $data['openingHoursSpecification'][0]['dayOfWeek']);
	assert_same('09:00', $data['openingHoursSpecification'][0]['opens']);
	assert_same(3, count($data['sameAs']));
	assert_false(isset($data['logo']), 'порожній logo');
	assert_false(isset($data['legalName']), 'порожній legalName');
});

test('JSON-LD з порожніх контактів — лише @context, @type, url', function () {
	$data = Jsonld::localBusiness(Nap::normalize(array()), 'https://orendaposydy.com/');

	assert_same(array('@context' => 'https://schema.org', '@type' => 'LocalBusiness', 'url' => 'https://orendaposydy.com/'), $data);
});

test('render: кирилиця без \u, </script> екрановано', function () {
	$html = Jsonld::render(array('@type' => 'LocalBusiness', 'name' => 'Крістал </script><b>'));

	$bs = chr(92);
	assert_contains('"name":"Крістал ' . $bs . 'u003C/script' . $bs . 'u003E' . $bs . 'u003Cb' . $bs . 'u003E"', $html);
	assert_same(1, substr_count($html, '</script>'));
	assert_same('', Jsonld::render(array()));
});

/** Кеш у пам'яті з тією ж логікою delete(), що Cache\File (префікс ключа) */
class MemCache {
	public $data = array();
	public function get($key) { return isset($this->data[$key]) ? $this->data[$key] : false; }
	public function set($key, $value) { $this->data[$key] = $value; }
	public function delete($key) {
		foreach (array_keys($this->data) as $k) {
			if ($k === $key || strpos($k, $key . '.') === 0) {
				unset($this->data[$k]);
			}
		}
	}
}

test('AC-9: Nap::get кешує kristal.nap, Cache_key::flush скидає', function () {
	$config = new \Config();
	$config->set('module_kristal_core_name', 'Крістал');
	$config->set('module_kristal_core_phones', array(array('number' => '0671234567')));
	$cache = new MemCache();
	$cache->set('product.1', 'чуже');
	$registry = new \Registry();
	$registry->set('config', $config);
	$registry->set('cache', $cache);

	assert_same('+380671234567', Nap::get($registry)['primary_phone']['number']);
	assert_true(isset($cache->data[Cache_key::NAP]));

	$config->set('module_kristal_core_phones', array(array('number' => '0501112233')));
	assert_same('+380671234567', Nap::get($registry)['primary_phone']['number'], 'з кешу');

	Cache_key::flush($cache);
	assert_same('+380501112233', Nap::get($registry)['primary_phone']['number'], 'після flush');
	assert_same('чуже', $cache->get('product.1'), 'інші ключі не зачеплено');
});

test('breadcrumbs: BreadcrumbList, декодування назв, останній без url, < 2 пунктів — порожньо', function () {
	$ld = Jsonld::breadcrumbs(array(
		array('name' => 'Головна', 'url' => 'https://orendaposudu.com/'),
		array('name' => 'Посуд &amp; прибори', 'url' => 'https://orendaposudu.com/posud?a=1&amp;b=2'),
		array('name' => '', 'url' => 'x'),
		array('name' => 'Оренда білих тарілок', 'url' => '')
	));
	assert_same('BreadcrumbList', $ld['@type']);
	assert_same(3, count($ld['itemListElement']));
	assert_same('Посуд & прибори', $ld['itemListElement'][1]['name']);
	assert_same('https://orendaposudu.com/posud?a=1&b=2', $ld['itemListElement'][1]['item']);
	assert_same(3, $ld['itemListElement'][2]['position']);
	assert_false(isset($ld['itemListElement'][2]['item']));
	assert_same(array(), Jsonld::breadcrumbs(array(array('name' => 'Головна', 'url' => '/'))));
});
