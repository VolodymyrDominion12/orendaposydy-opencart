<?php
use Kristal\Log;

test('AC-8: телефон і email у файлі замасковані', function () {
	$log = new Log('kristal.log');
	$log->write('Заявка: Іван, +380 67 123 45 67, ivan@example.com, сума 12500 грн');
	unset($log); // закрити файл

	$content = file_get_contents(DIR_LOGS . 'kristal.log');

	assert_contains('+38067*****67', $content);
	assert_contains('i***@example.com', $content);
	assert_contains('Заявка: Іван', $content);
	assert_contains('сума 12500 грн', $content);
	assert_not_contains('123 45 67', $content);
	assert_not_contains('ivan@', $content);
});

test('різні формати телефонів у тексті', function () {
	assert_same('тел. +38067*****67.', Log::mask('тел. 067-123-45-67.'));
	assert_same('(+38067*****67)', Log::mask('(+38 (067) 123-45-67)'));
	assert_same('a: +38067*****67, b: +38050*****11', Log::mask('a: 0671234567, b: +380501234511'));
});

test('іноземний номер з «+» маскується', function () {
	$masked = Log::mask('call +48 123 456 789 now');
	assert_not_contains('456', $masked);
	assert_contains('+48', $masked);
	assert_contains('89 now', $masked);
});

test('дати, id, суми й інший текст без змін', function () {
	foreach (array('order_id=12345', '2026-11-07 19:00', 'сума 1 250 грн', 'Telegram відповів: Unauthorized', 'HTTP 401') as $text) {
		assert_same($text, Log::mask($text));
	}
});

test('масив у лог — через print_r і теж маскується', function () {
	$log = new Log('kristal-array.log');
	$log->write(array('phone' => '0501112233', 'email' => 'olena.k@gmail.com'));
	unset($log);

	$content = file_get_contents(DIR_LOGS . 'kristal-array.log');
	assert_contains('+38050*****33', $content);
	assert_contains('o***@gmail.com', $content);
});
