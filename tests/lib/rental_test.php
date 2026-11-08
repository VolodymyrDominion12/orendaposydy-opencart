<?php
use Kristal\Rental;

$GLOBALS['__disc'] = array(array('quantity' => 300, 'price' => 10.5), array('quantity' => 100, 'price' => 12.0));

test('формат ціни: без копійок, з копійками, тисячі', function () {
	$nb = "\xC2\xA0";
	assert_same('14' . $nb . '₴', Rental::money(14));
	assert_same('10,50' . $nb . '₴', Rental::money(10.5));
	assert_same('1' . $nb . '440' . $nb . '₴', Rental::money(1440));
	assert_same('0' . $nb . '₴', Rental::money('0.0000'));
	assert_same('14' . $nb . '₴', Rental::money('14.0000'));
});

test('ціна за кількістю як у кошику ядра', function () {
	$d = $GLOBALS['__disc'];
	assert_same(14.0, Rental::unitPrice(20, 14, $d));
	assert_same(14.0, Rental::unitPrice(99, 14, $d));
	assert_same(12.0, Rental::unitPrice(100, 14, $d));
	assert_same(12.0, Rental::unitPrice(120, 14, $d));
	assert_same(10.5, Rental::unitPrice(300, 14, $d));
	assert_same(14.0, Rental::unitPrice(50, 14, array()));
});

test('рядки таблиці знижок', function () {
	$rows = Rental::tierRows(20, 14, $GLOBALS['__disc']);
	assert_same(array(
		array('from' => 20, 'to' => 99, 'price' => 14.0),
		array('from' => 100, 'to' => 299, 'price' => 12.0),
		array('from' => 300, 'to' => 0, 'price' => 10.5),
	), $rows);
	assert_same(array(array('from' => 10, 'to' => 0, 'price' => 35.0)), Rental::tierRows(10, 35, array()));
});

test('поріг не вище мінімуму діє з мінімуму; дублікати й quantity ≤ 1 відкидаються', function () {
	$d = array(array('quantity' => 10, 'price' => 13), array('quantity' => 100, 'price' => 12), array('quantity' => 100, 'price' => 11.5), array('quantity' => 1, 'price' => 1));
	assert_same(array(
		array('from' => 20, 'to' => 99, 'price' => 13.0),
		array('from' => 100, 'to' => 0, 'price' => 11.5),
	), Rental::tierRows(20, 14, $d));
});

test('найвигідніший поріг для картки списку', function () {
	assert_same(array('from' => 300, 'to' => 0, 'price' => 10.5), Rental::bestTier(20, 14, $GLOBALS['__disc']));
	assert_same(null, Rental::bestTier(20, 14, array()));
});

test('одиниці і нормалізація рядка оренди', function () {
	assert_same('шт', Rental::unit('pcs'));
	assert_same('м²', Rental::unit('m2'));
	assert_same('шт', Rental::unit('невідома'));
	$n = Rental::normalize(null);
	assert_same('pcs', $n['unit']);
	assert_false($n['is_hit']);
	$n = Rental::normalize(array('unit' => 'event', 'deposit' => '500.0000', 'breakage_price' => '-3', 'washing_included' => '1', 'is_hit' => '0'));
	assert_same('event', $n['unit']);
	assert_same(500.0, $n['deposit']);
	assert_same(0.0, $n['breakage_price']);
	assert_true($n['washing_included']);
});
