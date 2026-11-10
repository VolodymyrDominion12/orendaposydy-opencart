<?php
use Kristal\Filter;

/** Індекс як у ModelExtensionKristalFilter::getIndex(): Матеріал (1) і Колір (2) */
function filter_sample() {
	$values = array(
		10 => array('g' => 1, 'group' => 'Матеріал', 'name' => 'Порцеляна'),
		11 => array('g' => 1, 'group' => 'Матеріал', 'name' => 'Кераміка'),
		12 => array('g' => 1, 'group' => 'Матеріал', 'name' => 'Скло'),
		20 => array('g' => 2, 'group' => 'Колір', 'name' => 'Білий'),
		21 => array('g' => 2, 'group' => 'Колір', 'name' => 'Чорний')
	);

	foreach (Filter::slugs($values) as $fid => $slug) {
		$values[$fid]['slug'] = $slug;
	}

	$products = array(
		array('id' => 1, 'price' => 14.0, 'sort' => 2, 'name' => 'тарілка біла', 'f' => array(10, 20)),
		array('id' => 2, 'price' => 20.0, 'sort' => 1, 'name' => 'тарілка чорна', 'f' => array(10, 21)),
		array('id' => 3, 'price' => 9.0,  'sort' => 1, 'name' => 'миска біла', 'f' => array(11, 20)),
		array('id' => 4, 'price' => 0.0,  'sort' => 0, 'name' => 'келих', 'f' => array(12)),
		array('id' => 5, 'price' => 35.0, 'sort' => 3, 'name' => 'блюдо', 'f' => array())
	);

	return array($products, $values);
}

test('slugs: група + назва латиницею; збіг у групі → -id; група «Ціна» не займає tsina', function () {
	list(, $values) = filter_sample();
	assert_same('material-portseliana', $values[10]['slug']);
	assert_same('kolir-bilyi', $values[20]['slug']);

	$dup = Filter::slugs(array(
		5 => array('g' => 1, 'group' => 'Колір', 'name' => 'Білий'),
		6 => array('g' => 1, 'group' => 'Колір', 'name' => 'білий'),
		7 => array('g' => 9, 'group' => 'Ціна', 'name' => 'Дешево')
	));
	assert_same('kolir-bilyi-5', $dup[5]);
	assert_same('kolir-bilyi-6', $dup[6]);
	assert_same('tsina-9-deshevo', $dup[7]);
});

test('parse: токени, ціна, сміття, ліміт 20', function () {
	$p = Filter::parse('kolir-bilyi_material-portseliana_tsina-10-40');
	assert_same(array('kolir-bilyi', 'material-portseliana'), $p['slugs']);
	assert_same(array(10, 40), $p['price']);

	$p = Filter::parse("KOLIR-BILYI_<script>_'_kolir-bilyi__-x_tsina-50-10");
	assert_same(array('kolir-bilyi'), $p['slugs']);
	assert_same(array(10, 50), $p['price'], 'від > до міняються');

	$p = Filter::parse(implode('_', array_map(function ($i) { return 'v' . $i; }, range(1, 500))));
	assert_same(20, count($p['slugs']));

	assert_same(array('slugs' => array(), 'price' => null), Filter::parse(array('x')));
	assert_same(null, Filter::parse('tsina--')['price']);
});

test('price: нечислове, від\'ємне, велике, лише «до»', function () {
	assert_same(null, Filter::price('abc', ''));
	assert_same(null, Filter::price('0', ''));
	assert_same(array(0, 40), Filter::price('-5', '40'));
	assert_same(array(0, 40), Filter::price('', '40'));
	assert_same(array(10, 1000000), Filter::price('10', '99999999999'));
	assert_same(array(12, null), Filter::price('12,7', ''));
	assert_same(null, Filter::price(array(1), null));
	assert_same(null, Filter::price('abc', '-3'), '«до» ≤ 0 — без межі');
	assert_same(array(5, null), Filter::price('5', '0'));
});

test('resolve і canonical: невідоме ігнорується, порядок — як у довіднику, ціна остання', function () {
	list(, $values) = filter_sample();
	$map = array();
	foreach ($values as $fid => $v) { $map[$v['slug']] = $fid; }

	$sel = Filter::resolve(array('kolir-bilyi', 'nema-takoho', 'material-keramika', 'material-portseliana'), $map, $values);
	assert_same(array(2 => array(20 => true), 1 => array(11 => true, 10 => true)), $sel);
	assert_same('material-portseliana_material-keramika_kolir-bilyi_tsina-10-', Filter::canonical($sel, array(10, null), $values));
	assert_same('tsina--40', Filter::canonical(array(), array(0, 40), $values));
	assert_same('10,11,20', Filter::key($sel));
	assert_same(3, Filter::count($sel));
});

test('select: АБО в групі, І між групами, ціна відсікає товари без ціни', function () {
	list($products) = filter_sample();
	$sel = array(1 => array(10 => true, 11 => true), 2 => array(20 => true));
	assert_same(array(1, 3), Filter::select($products, $sel, null));
	assert_same(array(1), Filter::select($products, $sel, array(10, 30)));
	assert_same(array(1, 2, 3, 4, 5), Filter::select($products, array(), null));
	assert_same(array(1, 2, 3), Filter::select($products, array(), array(0, 30)));
});

test('counts: власна група не звужує, інші — так; 0 лишається', function () {
	list($products, $values) = filter_sample();
	$sel = array(2 => array(20 => true));
	$c = Filter::counts($products, $values, $sel, null);
	assert_same(1, $c[10], 'біла порцеляна');
	assert_same(1, $c[11], 'біла кераміка');
	assert_same(0, $c[12], 'білого скла немає');
	assert_same(2, $c[20], 'білий — без урахування вибраного в кольорі');
	assert_same(1, $c[21], 'чорний (з урахуванням матеріалу — без вибору)');

	$c = Filter::counts($products, $values, array(), array(15, null));
	assert_same(1, $c[10]);
	assert_same(0, $c[20]);
});

test('bounds і visibleGroups', function () {
	list($products, $values) = filter_sample();
	assert_same(array(9, 35), Filter::bounds($products, array()));
	assert_same(array(9, 14), Filter::bounds($products, array(2 => array(20 => true))));
	assert_same(array(0, 0), Filter::bounds($products, array(1 => array(12 => true))));

	assert_same(array(1 => true, 2 => true), Filter::visibleGroups($products, $values, array()));
	$one = array(array('id' => 1, 'price' => 1, 'sort' => 0, 'name' => 'a', 'f' => array(10, 20)));
	assert_same(array(), Filter::visibleGroups($one, $values, array()), 'одне значення — групу не показуємо');
	assert_same(array(2 => true), Filter::visibleGroups($one, $values, array(2 => array(20 => true))), 'вибрана — показуємо');
});

test('toggle', function () {
	list(, $values) = filter_sample();
	$sel = Filter::toggle(array(), 20, $values);
	assert_same(array(2 => array(20 => true)), $sel);
	assert_same(array(), Filter::toggle($sel, 20, $values));
	assert_same($sel, Filter::toggle($sel, 999, $values));
});

test('sort: як ядро — поле, далі назва в тому ж напрямку, невідоме → sort_order', function () {
	list($products) = filter_sample();
	$ids = array(1, 2, 3, 4, 5);
	assert_same(array(4, 3, 2, 1, 5), Filter::sort($products, $ids, 'p.sort_order', 'ASC'));
	assert_same(array(4, 3, 1, 2, 5), Filter::sort($products, $ids, 'p.price', 'ASC'));
	assert_same(array(5, 2, 1, 3, 4), Filter::sort($products, $ids, 'p.price', 'DESC'));
	assert_same(array(5, 4, 3, 1, 2), Filter::sort($products, $ids, 'pd.name', 'ASC'));
	assert_same(array(4, 3, 2, 1, 5), Filter::sort($products, $ids, 'rating', 'ASC'));
	assert_same(array(3, 1), Filter::sort($products, array(1, 3, 999), 'p.price', 'ASC'), 'невідомий id відкидається');
});

test('splitValues: кома/крапка з комою, лапки «…», регістр, повтори', function () {
	assert_same(array('Скло', 'Метал'), Filter::splitValues('Скло, метал'));
	assert_same(array('Сталь', 'PVD-покриття'), Filter::splitValues('Сталь, PVD-покриття'));
	assert_same(array('Тканина «Журавинка, люкс»', '100% поліестер'), Filter::splitValues('Тканина «Журавинка, люкс»; 100% поліестер'));
	assert_same(array('Білий'), Filter::splitValues('білий, Білий,  '));
	assert_same(array(), Filter::splitValues(''));
	assert_same(array('Сталь'), Filter::splitValues('Сталь, PVD-покриття', false));
	assert_same(array('Алюміній'), Filter::splitValues('Алюміній, антипригарне покриття', false));
	assert_same(array('Тканина «Журавинка»'), Filter::splitValues('Тканина «Журавинка», 100% поліестер', false));
	assert_same(array('Скло', 'Метал'), Filter::splitValues('Скло, метал', false));
	assert_same(array('ПВХ'), Filter::splitValues('ПВХ, алюмінієвий каркас', false));
});

test('bucket: розміри й об\'єм діапазонами; меблі й текстиль — ні', function () {
	assert_same('до 22 см', Filter::bucket('20 см', 'size')['label']);
	assert_same('до 22 см', Filter::bucket('Ø 22 см', 'size')['label']);
	assert_same('23–27 см', Filter::bucket('26×26 см', 'size')['label']);
	assert_same('23–27 см', Filter::bucket('26 * 26 см', 'size')['label']);
	assert_same('від 28 см', Filter::bucket('35×14 см', 'size')['label']);
	assert_same(null, Filter::bucket('180×80×75 см', 'size'));
	assert_same(null, Filter::bucket('160×260 см', 'size'));
	assert_same(null, Filter::bucket('10 м, 100 ламп', 'size'));
	assert_same('до 200 мл', Filter::bucket('150 мл', 'volume')['label']);
	assert_same('200–350 мл', Filter::bucket('300 мл', 'volume')['label']);
	assert_same('350 мл – 1 л', Filter::bucket('0,5 л', 'volume')['label']);
	assert_same('понад 1 л', Filter::bucket('9 л', 'volume')['label']);
	assert_same(4, Filter::bucket('9 л', 'volume')['sort']);
	assert_same(null, Filter::bucket('2 групи', 'volume'));
});
