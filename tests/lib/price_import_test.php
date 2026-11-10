<?php
use Kristal\Price_csv;
use Kristal\Price_import;

function pi_catalog() {
	$p = function ($id, $sku, $name, $price, $extra = array()) {
		return array_merge(array('id' => $id, 'sku' => $sku, 'name' => $name, 'category' => 'Посуд / Тарілки', 'price' => $price, 'minimum' => 1,
			'status' => 1, 'unit' => 'pcs', 'deposit' => 0.0, 'breakage' => 0.0, 'washing' => 0, 'hit' => 0, 'discounts' => array()), $extra);
	};

	return array(
		'products' => array(
			10 => $p(10, '', 'Тарілка 26 см', 0.0),
			11 => $p(11, 'T-27', 'Тарілка обідня 27 см', 14.0, array('minimum' => 20, 'discounts' => array(100 => 12.0, 300 => 10.5))),
			12 => $p(12, 'K-1', 'Келих', 9.0),
			13 => $p(13, '', 'Шатро', 0.0, array('status' => 0))
		),
		'categories' => array(Price_import::pathKey('Посуд / Тарілки') => 5, Price_import::pathKey('Шатри') => 7)
	);
}

function pi_plan($csv) {
	return Price_import::plan(Price_csv::read($csv), pi_catalog());
}

function pi_codes($plan) {
	return array_map(function ($e) { return $e['line'] . ':' . $e['code']; }, $plan['errors']);
}

test('оновлення за ID: лише змінені поля; порожня клітинка не змінює; Назва ігнорується', function () {
	$plan = pi_plan("ID;Назва;Ціна за добу;Застава;Мін. кількість\n10;Інша назва;14,5;200;\n11;;14;;20\n");

	assert_same(array(), $plan['errors']);
	assert_same(array(10 => array('line' => 2, 'fields' => array('price' => 14.5, 'deposit' => 200.0))), $plan['updates']);
	assert_same(1, $plan['counts']['changed']);
	assert_same(1, $plan['counts']['unchanged']);
	assert_same(array('price', 'deposit'), array_column($plan['changes'], 'field'));
	assert_same(0.0, $plan['changes'][0]['old']);
});

test('AC-5: за артикулом без ID, без регістру; новий артикул наявному товару', function () {
	$plan = pi_plan("ID;Артикул;Ціна за добу\n;t-27;15\n10;D-26;\n");

	assert_same(array(), $plan['errors']);
	assert_same(array('price' => 15.0), $plan['updates'][11]['fields']);
	assert_same(array('sku' => 'D-26'), $plan['updates'][10]['fields']);
});

test('AC-5: ID не знайдено, нечисловий ID, без ключа, два рядки на товар, чужий артикул, повтор артикула', function () {
	$plan = pi_plan("ID;Артикул;Ціна за добу\n999;;1\nабв;;1\n;;1\n12;;10\n;K-1;11\n10;T-27;\n13;N-1;\n;n-1;5\n");
	$codes = pi_codes($plan);

	foreach (array('2:not_found', '3:id_invalid', '4:no_key', '5:duplicate_product', '6:duplicate_product', '7:sku_taken', '8:sku_duplicate', '9:sku_duplicate') as $expected) {
		assert_true(in_array($expected, $codes, true), $expected . ' у ' . implode(' ', $codes));
	}

	assert_same(array(), $plan['updates']);
	assert_same(8, $plan['counts']['errors']);
});

test('AC-6: числа, мінімум, одиниця, так/ні — помилка рядка, решта файлу застосовується', function () {
	$plan = pi_plan("ID;Ціна за добу;Мін. кількість;Одиниця;Хіт\n10;abc;0;кг;може\n12;8;;;так\n");

	assert_same(array('2:bad_number', '2:bad_minimum', '2:bad_unit', '2:bad_bool'), pi_codes($plan));
	assert_same(array('price' => 8.0, 'hit' => 1), $plan['updates'][12]['fields']);
});

test('AC-6: знижки — формат, кількість ≤ мінімуму, ціна ≥ ціни, повтор; «-» очищає', function () {
	$plan = pi_plan("ID;Знижки\n11;\"100:12; 20:13; 300:15; 300:9\"\n12;50 шт\n");
	assert_same(array('2:discount_quantity', '2:discount_price', '2:discount_duplicate', '3:bad_discounts'), pi_codes($plan));

	$plan = pi_plan("ID;Знижки;Ціна за добу\n11;-;\n12;10:8;10\n");
	assert_same(array(), $plan['errors']);
	assert_same(array('discounts' => array()), $plan['updates'][11]['fields']);
	assert_same(array('price' => 10.0, 'discounts' => array(10 => 8.0)), $plan['updates'][12]['fields']);
});

test('знижки з тими самими порогами в іншому порядку — без змін', function () {
	$plan = pi_plan("ID;Знижки\n11;\"300:10,50; 100:12\"\n");
	assert_same(array(), $plan['updates']);
	assert_same(1, $plan['counts']['unchanged']);
});

test('AC-7: колонок немає у файлі — поля не чіпаються, навіть із таким самим товаром', function () {
	$plan = pi_plan("ID;Хіт\n11;так\n");
	assert_same(array('hit' => 1), $plan['updates'][11]['fields']);
});

test('AC-10: новий товар — вимкнений, категорія за шляхом, значення за замовчуванням; помилки створення', function () {
	$plan = pi_plan("Артикул;Назва;Категорія;Ціна за добу;Мін. кількість;Знижки;Увімкнено\nN-1;Шатро 5×10;шатри;2400;;;так\nN-2;Без категорії;Меблі;10;;;\nN-3;;Шатри;10;;;\nN-4;Нова;Шатри;10;5;3:9;\n");

	assert_same(1, count($plan['creates']));
	$c = $plan['creates'][0];
	assert_same(array('N-1', 'Шатро 5×10', 7, 2400.0, 0, 1, 'pcs'), array($c['sku'], $c['name'], $c['category_id'], $c['price'], $c['status'], $c['minimum'], $c['unit']));
	assert_same(array('3:category_not_found', '4:create_missing', '5:discount_quantity'), pi_codes($plan));
	assert_true(in_array('created_disabled', array_column($plan['warnings'], 'code'), true));
});

test('AC-8: попередження — без ціни, не у файлі, стрибок ціни, невідомі колонки, конфлікт знижок', function () {
	$plan = pi_plan("ID;Ціна за добу;Колір\n11;11;\n12;2;\n");
	$codes = array_column($plan['warnings'], 'code');

	foreach (array('unknown_columns', 'no_price', 'not_in_file', 'price_jump', 'discounts_conflict') as $code) {
		assert_true(in_array($code, $codes, true), $code . ' у ' . implode(' ', $codes));
	}

	$no_price = $plan['warnings'][array_search('no_price', $codes, true)];
	assert_same(1, $no_price['args'][0]); // лише увімкнений #10 (#13 вимкнений)

	$conflict = $plan['warnings'][array_search('discounts_conflict', $codes, true)];
	assert_same('Тарілка обідня 27 см', $conflict['args'][0]); // ціна 11, а знижка «від 100 — 12» дорожча за неї
});

test('hash: однаковий для того самого плану, різний для іншого', function () {
	$a = pi_plan("ID;Ціна за добу\n10;14\n");
	$b = pi_plan("ID;Ціна за добу\n10;14\n");
	$c = pi_plan("ID;Ціна за добу\n10;15\n");

	assert_same($a['hash'], $b['hash']);
	assert_true($a['hash'] !== $c['hash']);
});

test('pathKey: регістр, пробіли, «>» і «\\» як роздільники', function () {
	assert_same('посуд/тарілки', Price_import::pathKey(' Посуд  /Тарілки '));
	assert_same('посуд/тарілки', Price_import::pathKey('Посуд > Тарілки'));
	assert_same('посуд', Price_import::pathKey('Посуд'));
});
