<?php
use Kristal\Cookie;

test('HTTPS: кука сесії отримує Secure, HttpOnly, SameSite=None; решта без змін', function () {
	$out = Cookie::harden(array(
		'Set-Cookie: OCSESSID=abc123; path=/',
		'Set-Cookie: language=uk-ua; expires=Wed, 09-Dec-2026 15:11:40 GMT; Max-Age=2592000; path=/',
		'Content-Type: text/html',
	), 'OCSESSID', true);

	assert_same(array(
		'Set-Cookie: OCSESSID=abc123; path=/; Secure; HttpOnly; SameSite=None',
		'Set-Cookie: language=uk-ua; expires=Wed, 09-Dec-2026 15:11:40 GMT; Max-Age=2592000; path=/',
	), $out);
});

test('HTTP (локально): HttpOnly, SameSite=Lax, без Secure', function () {
	$out = Cookie::harden(array('Set-Cookie: OCSESSID=abc; path=/'), 'OCSESSID', false);

	assert_same(array('Set-Cookie: OCSESSID=abc; path=/; HttpOnly; SameSite=Lax'), $out);
});

test('наявні атрибути не дублюються, будь-який регістр', function () {
	$out = Cookie::harden(array('set-cookie: OCSESSID=abc; path=/; secure; HTTPONLY; samesite=Strict'), 'OCSESSID', true);

	assert_same(array('Set-Cookie: OCSESSID=abc; path=/; Secure; HttpOnly; SameSite=None'), $out);
});

test('кілька Set-Cookie сесії → один, останній (адмінка: ядро ставить двічі)', function () {
	$out = Cookie::harden(array(
		'Set-Cookie: OCSESSID=old; path=/',
		'Set-Cookie: currency=UAH; path=/',
		'Set-Cookie: OCSESSID=new; path=/',
	), 'OCSESSID', true);

	assert_same(array(
		'Set-Cookie: currency=UAH; path=/',
		'Set-Cookie: OCSESSID=new; path=/; Secure; HttpOnly; SameSite=None',
	), $out);
});

test('кука з подібним іменем не чіпається', function () {
	$out = Cookie::harden(array('Set-Cookie: OCSESSID_X=1; path=/', 'Set-Cookie: XOCSESSID=2'), 'OCSESSID', true);

	assert_same(array('Set-Cookie: OCSESSID_X=1; path=/', 'Set-Cookie: XOCSESSID=2'), $out);
});

test('значення з «=» і дата expires зберігаються', function () {
	$out = Cookie::harden(array('Set-Cookie: OCSESSID=a=b==; expires=Wed, 09-Dec-2026 15:11:40 GMT; Max-Age=60; path=/; domain=.orendaposudu.com'), 'OCSESSID', false);

	assert_same(array('Set-Cookie: OCSESSID=a=b==; expires=Wed, 09-Dec-2026 15:11:40 GMT; Max-Age=60; path=/; domain=.orendaposudu.com; HttpOnly; SameSite=Lax'), $out);
});

test('isHttps: HTTPS=on/1, off, проксі', function () {
	assert_true(Cookie::isHttps(array('HTTPS' => 'on')));
	assert_true(Cookie::isHttps(array('HTTPS' => '1')));
	assert_false(Cookie::isHttps(array('HTTPS' => 'off')));
	assert_false(Cookie::isHttps(array()));
	assert_true(Cookie::isHttps(array('HTTP_X_FORWARDED_PROTO' => 'HTTPS')));
});

test('apply у CLI: заголовків немає → false, нічого не ламає', function () {
	assert_false(Cookie::apply('OCSESSID', true));
	assert_false(Cookie::apply('', true));
});
