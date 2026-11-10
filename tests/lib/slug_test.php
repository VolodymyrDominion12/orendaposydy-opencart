<?php
use Kristal\Slug;

test('як ЧПУ мок-каталогу 001 (× → x)', function () {
	assert_same('tarilka-obidnia-bila-27-sm', Slug::make('Тарілка обідня біла 27 см'));
	assert_same('stilets-chiavari-bilyi', Slug::make('Стілець Chiavari білий'));
	assert_same('shatro-5x10-m-na-50-hostei', Slug::make('Шатро 5×10 м на 50 гостей'));
});

test('КМУ-2010: є ї й ю я на початку слова й усередині, зг, апостроф', function () {
	assert_same('yizhak-yaroslav-yevropa-yuliia', Slug::make('Їжак Ярослав Європа Юлія'));
	assert_same('mokhnatyi-kraina', Slug::make('Мохнатий Країна'));
	assert_same('zghorany', Slug::make('Згорани'));
	assert_same('simia-pivden', Slug::make("Сім'я Південь"));
	assert_same('simia', Slug::make('Сім’я'));
});

test('розміри й символи зі старих назв', function () {
	assert_same('supnytsia-d-22-sm-300-ml', Slug::make('Супниця Ø 22 см. 300 мл.'));
	assert_same('tarilka-26-x-26-sm', Slug::make('Тарілка 26 * 26 см'));
	assert_same('dereviana-doshka-30x20', Slug::make('Дерев&#39;яна дошка 30x20'));
});

test('довжина ≤ 64, обрізання по слову; порожньо → fallback в unique', function () {
	$s = Slug::make(str_repeat('Тарілка ', 20));
	assert_true(strlen($s) <= 64, $s);
	assert_false(substr($s, -1) === '-');
	assert_same('', Slug::make('!!! ₴ —'));
	$taken = array();
	assert_same('tovar', Slug::unique('!!!', $taken));
});

test('unique: -2, -3, і доповнює зайняті', function () {
	$taken = array('tarilka' => true, 'tarilka-2' => true);
	assert_same('tarilka-3', Slug::unique('Тарілка', $taken));
	assert_same('tarilka-4', Slug::unique('тарілка', $taken));
	assert_true(isset($taken['tarilka-4']));
});
