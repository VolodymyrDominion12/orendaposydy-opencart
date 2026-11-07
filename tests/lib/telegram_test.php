<?php
use Kristal\Telegram;

/** Клієнт без мережі: повертає заготовлену відповідь і запам'ятовує запит */
class FakeTelegram extends Telegram {
	public $response;
	public $last_url = '';
	public $last_fields = array();

	protected function request($url, $fields) {
		$this->last_url = $url;
		$this->last_fields = $fields;

		return $this->response;
	}
}

define('TG_TEST_TOKEN', '123456789:AAHdqTcvCH1vGWJxfSeofSAs0K5PALDsaw0');

test('escape для parse_mode=HTML', function () {
	assert_same('&lt;b&gt;Іван &amp; Ко&lt;/b&gt; "лапки"', Telegram::escape('<b>Іван & Ко</b> "лапки"'));
});

test('успішне надсилання', function () {
	$tg = new FakeTelegram(TG_TEST_TOKEN);
	$tg->response = array('status' => 200, 'body' => '{"ok":true,"result":{"message_id":1}}', 'error' => '');
	$r = $tg->send('-1001234567890', '<b>Тест</b>');

	assert_same(array('ok' => true, 'type' => '', 'error' => ''), $r);
	assert_same('HTML', $tg->last_fields['parse_mode']);
	assert_same('-1001234567890', $tg->last_fields['chat_id']);
});

test('AC-4: Unauthorized — без токена в тексті помилки', function () {
	$tg = new FakeTelegram(TG_TEST_TOKEN);
	$tg->response = array('status' => 401, 'body' => '{"ok":false,"error_code":401,"description":"Unauthorized"}', 'error' => '');
	$r = $tg->send('12345', 'x');

	assert_same('api', $r['type']);
	assert_same('Unauthorized', $r['error']);
});

test('помилка мережі з токеном в URL → токен замінено на ***', function () {
	$tg = new FakeTelegram(TG_TEST_TOKEN);
	$tg->response = array('status' => 0, 'body' => '', 'error' => 'Could not resolve host for https://api.telegram.org/bot' . TG_TEST_TOKEN . '/sendMessage');
	$r = $tg->send('12345', 'x');

	assert_same('network', $r['type']);
	assert_not_contains(TG_TEST_TOKEN, $r['error']);
	assert_contains('bot***/sendMessage', $r['error']);
});

test('невірні токен/chat_id — без запиту в мережу', function () {
	$tg = new FakeTelegram('not-a-token');
	$r = $tg->send('12345', 'x');
	assert_same('config', $r['type']);
	assert_same('', $tg->last_url);

	$tg = new FakeTelegram(TG_TEST_TOKEN);
	assert_same('config', $tg->send('abc def', 'x')['type']);
	assert_true(Telegram::isValidChatId('@kristal_orders'));
	assert_true(Telegram::isValidChatId('-1001234567890'));
});

test('відповідь не JSON (HTML від проксі) → api з кодом HTTP', function () {
	$tg = new FakeTelegram(TG_TEST_TOKEN);
	$tg->response = array('status' => 502, 'body' => '<html>Bad gateway</html>', 'error' => '');

	assert_same(array('ok' => false, 'type' => 'api', 'error' => 'HTTP 502'), $tg->send('12345', 'x'));
});

test('AC-5: маска токена — лише останні 4 символи', function () {
	$masked = Telegram::maskToken(TG_TEST_TOKEN);

	assert_same('saw0', substr($masked, -4));
	assert_not_contains('123456789', $masked);
	assert_same('', Telegram::maskToken(''));
});
