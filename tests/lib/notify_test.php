<?php
use Kristal\Notify;

test('parseChatIds: різні розділювачі, негативні ID, дублікати', function () {
	$input = "12345678, -100987654321; 12345678\n-100987654321, 555666777";
	$chats = Notify::parseChatIds($input);

	assert_same(3, count($chats));
	assert_same('12345678', $chats[0]);
	assert_same('-100987654321', $chats[1]);
	assert_same('555666777', $chats[2]);
});

test('parseChatIds: ігнорування сміття та невалідних значень', function () {
	$input = "abc, 12, 1234567, @mychannel, !!";
	$chats = Notify::parseChatIds($input);

	assert_same(1, count($chats));
	assert_same('1234567', $chats[0]);
});

test('parseEmails: валідація, регістр, дублікати', function () {
	$input = "Admin@kristal.lviv.ua, test@example.com; admin@kristal.lviv.ua\nnot-an-email";
	$emails = Notify::parseEmails($input);

	assert_same(2, count($emails));
	assert_same('admin@kristal.lviv.ua', $emails[0]);
	assert_same('test@example.com', $emails[1]);
});

test('HMAC сигнатура: генерація та валідація', function () {
	$payload = json_encode(array('event' => 'order.created', 'id' => 42));
	$secret = 'super-secret-key-123';

	$sig = Notify::generateSignature($payload, $secret);
	assert_true(strlen($sig) === 64);
	assert_true(Notify::verifySignature($payload, $secret, $sig));
	assert_false(Notify::verifySignature($payload, 'wrong-secret', $sig));
	assert_false(Notify::verifySignature($payload . 'x', $secret, $sig));
});

test('maskSecret: безпечне маскування токенів', function () {
	assert_same('', Notify::maskSecret(''));
	assert_same('***', Notify::maskSecret('123456'));
	assert_same('1234...890', Notify::maskSecret('1234567890:ABC-DEF1234ghIkl-zyx57W2v1u1234567890'));
});

test('formatOrderTelegram: HTML, екранування, товари, дати оренди', function () {
	$order = array(
		'order_id' => 105,
		'store_name' => 'Крістал <Оренда>',
		'firstname' => 'Олена',
		'lastname' => 'Коваль & Co',
		'telephone' => '+380501234567',
		'rental_date_from' => '2026-12-01',
		'rental_date_to' => '2026-12-03',
		'rental_days' => 2,
		'shipping_method' => 'Доставка по Львову',
		'payment_method' => 'Заявка без оплати',
		'total_formatted' => '2 400 ₴',
		'products' => array(
			array('name' => 'Тарілка <Біла> 27 см', 'quantity' => 50, 'total_formatted' => '1 500 ₴'),
			array('name' => 'Келих "Богемія"', 'quantity' => 50, 'total_formatted' => '900 ₴')
		)
	);

	$msg = Notify::formatOrderTelegram($order, 'https://orendaposudu.com/admin/order/105');

	assert_true(strpos($msg, 'Крістал &lt;Оренда&gt;') !== false);
	assert_true(strpos($msg, 'Коваль &amp; Co') !== false);
	assert_true(strpos($msg, '2026-12-01 — 2026-12-03 (2 діб)') !== false);
	assert_true(strpos($msg, 'Тарілка &lt;Біла&gt; 27 см × 50 = 1 500 ₴') !== false);
	assert_true(strpos($msg, 'https://orendaposudu.com/admin/order/105') !== false);
});

test('makeSummary: стислий опис без персональних даних', function () {
	$orderSummary = Notify::makeSummary('order', 105, array('total' => 1500, 'products' => array(1, 2, 3)));
	assert_same('Замовлення #105 (3 поз., 1500 ₴)', $orderSummary);

	$leadSummary = Notify::makeSummary('lead', 12, array('type' => 'call'));
	assert_same('Заявка #12 (call)', $leadSummary);
});
