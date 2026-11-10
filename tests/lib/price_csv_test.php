<?php
use Kristal\Price_csv;

test('запис: BOM, «;», заголовки AC-2, \r\n, числа з комою', function () {
	$csv = Price_csv::write(array(array('id' => 989, 'name' => 'Дошка', 'price' => Price_csv::formatNumber(10.5), 'discounts' => Price_csv::formatDiscounts(array(300 => 10.5, 100 => 12)))));

	assert_same("\xEF\xBB\xBF", substr($csv, 0, 3));
	assert_contains("ID;Артикул;Назва;Категорія;\"Ціна за добу\";Одиниця;\"Мін. кількість\";Знижки;Застава;Биття/втрата;\"Миття включено\";Хіт;Увімкнено\r\n", $csv);
	assert_contains("989;;Дошка;;10,50;;;\"100:12; 300:10,50\";;;;;\r\n", $csv);
});

test('AC-3: формули екрануються, читання прибирає апостроф', function () {
	assert_same("'=HYPERLINK(1)", Price_csv::cell('=HYPERLINK(1)'));
	assert_same("'-5 знижка", Price_csv::cell('-5 знижка'));
	assert_same("'@x", Price_csv::cell('@x'));
	assert_same('Тарілка', Price_csv::cell('Тарілка'));
	assert_same('=HYPERLINK(1)', Price_csv::text("'=HYPERLINK(1)"));
	assert_same("O'Neil", Price_csv::text("O'Neil"));
});

test('читання власного вивантаження: колонки, рядки з номерами Excel, порожні пропускаються', function () {
	$csv = Price_csv::write(array(
		array('id' => '989', 'sku' => '', 'name' => 'Дошка 30*20', 'price' => '14', 'minimum' => '20', 'discounts' => '100:12; 300:10,50', 'washing' => 'так'),
		array(),
		array('id' => '990', 'price' => '1 440,50')
	));
	$r = Price_csv::read($csv);

	assert_same('', $r['error']);
	assert_same('utf-8-bom', $r['encoding']);
	assert_same(';', $r['delimiter']);
	assert_same(array_keys(Price_csv::COLUMNS), array_values($r['columns']));
	assert_same(array(2, 4), array_keys($r['rows']));
	assert_same('Дошка 30*20', $r['rows'][2]['name']);
	assert_same('100:12; 300:10,50', $r['rows'][2]['discounts']);
	assert_same('1 440,50', $r['rows'][4]['price']);
});

test('AC-4: Windows-1251 з «;» (Excel «CSV (розділювач — крапка з комою)»)', function () {
	$text = "ID;Ціна за добу;Застава\r\n989;14,5;200\r\n";
	$r = Price_csv::read(mb_convert_encoding($text, 'Windows-1251', 'UTF-8'));

	assert_same('', $r['error']);
	assert_same('windows-1251', $r['encoding']);
	assert_same(array(0 => 'id', 1 => 'price', 2 => 'deposit'), $r['columns']);
	assert_same(array('id' => '989', 'price' => '14,5', 'deposit' => '200'), $r['rows'][2]);
});

test('AC-4: UTF-8 без BOM з «,» і лапками; таб', function () {
	$r = Price_csv::read("id,price,discounts\n989,\"14,5\",\"100:12; 300:10\"\n");
	assert_same(',', $r['delimiter']);
	assert_same(array('id' => '989', 'price' => '14,5', 'discounts' => '100:12; 300:10'), $r['rows'][2]);

	$r = Price_csv::read("Артикул\tЦіна\nA-1\t14\n");
	assert_same("\t", $r['delimiter']);
	assert_same(array('sku' => 'A-1', 'price' => '14'), $r['rows'][2]);
});

test('AC-7, AC-13: невідомі колонки, без ключа, порожній, xlsx, завеликий, забагато рядків', function () {
	$r = Price_csv::read("ID;Колір;Ціна\n1;білий;2\n");
	assert_same(array('Колір'), $r['unknown']);
	assert_same(array(0 => 'id', 2 => 'price'), $r['columns']);

	assert_same('no_key', Price_csv::read("Назва;Ціна\nТарілка;14\n")['error']);
	assert_same('empty', Price_csv::read("  \n")['error']);
	assert_same('binary', Price_csv::read("PK\x03\x04xl/workbook.xml")['error']);
	assert_same('binary', Price_csv::read("\xD0\xCF\x11\xE0\xA1\xB1")['error']);
	assert_same('too_big', Price_csv::read(str_repeat('x', Price_csv::MAX_BYTES + 1))['error']);
	assert_same('too_many_rows', Price_csv::read("ID\n" . str_repeat("1\n", Price_csv::MAX_ROWS + 1))['error']);
	assert_same('', Price_csv::read("ID\n" . str_repeat("1\n", Price_csv::MAX_ROWS))['error']);
});

test('число: кома, крапка, пробіли, ₴, грн, тисячі; помилки', function () {
	$cases = array('14' => 14.0, '10,50' => 10.5, '10.5' => 10.5, '1 440' => 1440.0, "1\xC2\xA0440,5" => 1440.5, '14 ₴' => 14.0, '14 грн' => 14.0, '1.440,50' => 1440.5, '1,440.50' => 1440.5, '0' => 0.0);

	foreach ($cases as $raw => $expected) {
		assert_same($expected, Price_csv::number($raw), $raw);
	}

	assert_same(null, Price_csv::number('  '));

	foreach (array('-5', 'abc', '14 шт', '1,2,3x', '∞') as $raw) {
		assert_same(false, Price_csv::number($raw), $raw);
	}
});

test('ціле, так/ні, одиниця', function () {
	assert_same(20, Price_csv::integer('20'));
	assert_same(20, Price_csv::integer('20,0'));
	assert_same(20, Price_csv::integer('20 шт'));
	assert_same(false, Price_csv::integer('2,5'));
	assert_same(null, Price_csv::integer(''));

	foreach (array('так', 'Так', '1', '+', 'yes', 'ДА') as $raw) { assert_same(true, Price_csv::bool($raw), $raw); }
	foreach (array('ні', '0', '-', 'no', 'НІ') as $raw) { assert_same(false, Price_csv::bool($raw), $raw); }
	assert_same(null, Price_csv::bool(''));
	assert_same('invalid', Price_csv::bool('може'));

	$units = array('шт' => 'pcs', 'шт.' => 'pcs', 'Комплект' => 'set', 'м²' => 'm2', 'м2' => 'm2', 'пог. м' => 'm', 'подія' => 'event', 'pcs' => 'pcs');

	foreach ($units as $raw => $code) { assert_same($code, Price_csv::unit($raw), $raw); }
	assert_same(false, Price_csv::unit('кг'));
	assert_same(null, Price_csv::unit(''));
});

test('знижки: формати, очищення, помилки; запис назад', function () {
	assert_same(array(array(100, 12.0), array(300, 10.5)), Price_csv::discounts('100:12; 300:10,50'));
	assert_same(array(array(100, 12.0), array(300, 10.5)), Price_csv::discounts("від 100 шт: 12 ₴\n300=10,5"));
	assert_same(array(array(300, 10.0), array(300, 9.0)), Price_csv::discounts('300:10|300:9'));
	assert_same(array(), Price_csv::discounts('-'));
	assert_same(null, Price_csv::discounts(' '));

	foreach (array('100', '100:', 'сто:12', '100:-1', '2,5:10', '0') as $raw) {
		assert_same(false, Price_csv::discounts($raw), $raw);
	}

	assert_same('100:12; 300:10,50', Price_csv::formatDiscounts(array(300 => 10.5, 100 => 12.0)));
	assert_same('', Price_csv::formatDiscounts(array()));
	assert_same('так', Price_csv::formatBool(1));
});
