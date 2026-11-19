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
		'contact_channel' => 'viber',
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
	assert_true(strpos($msg, 'Канал зв\'язку:</b> Viber') !== false);
	assert_true(strpos($msg, '2026-12-01 — 2026-12-03 (2 доби)') !== false);
	assert_true(strpos($msg, 'Тарілка &lt;Біла&gt; 27 см × 50 = 1 500 ₴') !== false);
	assert_true(strpos($msg, 'https://orendaposudu.com/admin/order/105') !== false);
});

test('contactChannelLabel: людські назви каналів зв\'язку', function () {
	assert_same('Viber', Notify::contactChannelLabel('viber'));
	assert_same('Telegram', Notify::contactChannelLabel(' TELEGRAM '));
	assert_same('Телефонний дзвінок', Notify::contactChannelLabel('phone'));
	assert_same('Email', Notify::contactChannelLabel('email'));
	assert_same('WhatsApp', Notify::contactChannelLabel('whatsapp'));
	assert_same('', Notify::contactChannelLabel(''));
	assert_same('', Notify::contactChannelLabel('some-unknown-value'));
});

test('formatOrderTelegram: без каналу зв\'язку рядок не додається', function () {
	$order = array(
		'order_id' => 106,
		'firstname' => 'Іван',
		'telephone' => '+380501112233',
		'total_formatted' => '300 ₴'
	);

	$msg = Notify::formatOrderTelegram($order);

	assert_true(strpos($msg, 'Канал зв\'язку:') === false);
	assert_true(strpos($msg, 'Телефон:</b> +380501112233') !== false);
});

test('formatOrderTelegram: правильна форма «доба/доби/діб»', function () {
	$cases = array(
		1 => '1 доба',
		2 => '2 доби',
		5 => '5 діб',
		11 => '11 діб',
		21 => '21 доба'
	);

	foreach ($cases as $days => $expected) {
		$msg = Notify::formatOrderTelegram(array(
			'order_id' => 108,
			'firstname' => 'Іван',
			'rental_date_from' => '2026-12-01',
			'rental_date_to' => '2026-12-02',
			'rental_days' => $days
		));

		assert_true(strpos($msg, '(' . $expected . ')') !== false);
	}
});

test('formatLeadTelegram: канал зв\'язку з заявки', function () {
	$lead = array(
		'lead_id' => 12,
		'type_title' => 'Швидке замовлення',
		'name' => 'Ірина',
		'phone' => '+380671112233',
		'contact_channel' => 'telegram'
	);

	$msg = Notify::formatLeadTelegram($lead);

	assert_true(strpos($msg, 'Канал зв\'язку:</b> Telegram') !== false);
});

test('makeSummary: стислий опис без персональних даних', function () {
	$orderSummary = Notify::makeSummary('order', 105, array('total' => 1500, 'products' => array(1, 2, 3)));
	assert_same('Замовлення #105 (3 поз., 1500 ₴)', $orderSummary);

	$leadSummary = Notify::makeSummary('lead', 12, array('type' => 'call'));
	assert_same('Заявка #12 (call)', $leadSummary);
});

test('truncateTelegram: короткий текст не змінюється', function () {
	$text = '<b>Крістал</b> — тест';
	assert_same($text, \Kristal\Notify::truncateTelegram($text));
});

test('truncateTelegram: довгий текст ріжеться до ліміту з позначкою', function () {
	$text = str_repeat('а', 5000);
	$out = \Kristal\Notify::truncateTelegram($text);

	assert_true(mb_strlen($out, 'UTF-8') <= 4096);
	assert_true(strpos($out, 'повідомлення скорочено') !== false);
});

test('truncateTelegram: закриває відкриті HTML-теги', function () {
	$text = '<b>' . str_repeat('а', 5000) . '</b>';
	$out = \Kristal\Notify::truncateTelegram($text);

	assert_true(mb_strlen($out, 'UTF-8') <= 4096);
	assert_true(strpos($out, '<b>') === 0);
	assert_true(strpos($out, '</b>') !== false);
});

test('truncateTelegram: не розриває HTML-сутність', function () {
	$text = str_repeat('a', 4001) . '&amp;' . str_repeat('b', 200);
	$out = \Kristal\Notify::truncateTelegram($text);
	$body = str_replace("\n\n… (повідомлення скорочено)", '', $out);

	assert_true(mb_strlen($out, 'UTF-8') <= 4096);

	$amp = strrpos($body, '&');
	$semi = strrpos($body, ';');
	assert_true($amp === false || ($semi !== false && $semi > $amp));
});

test('truncateTelegram: не залишає обірваний тег', function () {
	$text = str_repeat('a', 4002) . '<b>жирний</b>';
	$out = \Kristal\Notify::truncateTelegram($text);
	$body = str_replace("\n\n… (повідомлення скорочено)", '', $out);

	assert_true(mb_strlen($out, 'UTF-8') <= 4096);

	$open = strrpos($body, '<');
	$close = strrpos($body, '>');
	assert_true($open === false || ($close !== false && $close > $open));
});

test('truncateTelegram: закриває посилання <a>', function () {
	$text = '<a href="https://x.test/?a=1&amp;b=2">' . str_repeat('а', 5000) . '</a>';
	$out = \Kristal\Notify::truncateTelegram($text);

	assert_true(mb_strlen($out, 'UTF-8') <= 4096);
	assert_true(strpos($out, '</a>') !== false);
});
