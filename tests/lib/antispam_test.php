<?php
use Kristal\Antispam;

/** Фейковий ліміт: дозволяє $allowed спроб */
class FakeRateLimit {
	public $calls = 0;
	private $allowed;

	public function __construct($allowed) {
		$this->allowed = $allowed;
	}

	public function hit($action, $ip, $limit, $window) {
		$this->calls++;

		return $this->calls <= $this->allowed;
	}
}

function antispam_at($ts, $session = 'sess-1') {
	$a = new Antispam(str_repeat('ab', 32), $session, array('min_seconds' => 3, 'rate_limit' => 10));
	$a->setNow($ts);

	return $a;
}

test('AC-7: звичайний користувач через 10 с з токеном → прийнято', function () {
	$t0 = 1700000000;
	$token = antispam_at($t0)->token('lead');
	$r = antispam_at($t0 + 10)->check('lead', array('k_token' => $token, 'k_website' => ''), '1.2.3.4', new FakeRateLimit(10));

	assert_same(array('ok' => true, 'reason' => ''), $r);
});

test('AC-7: заповнена пастка → honeypot (ліміт не рахується)', function () {
	$t0 = 1700000000;
	$token = antispam_at($t0)->token('lead');
	$rl = new FakeRateLimit(10);
	$r = antispam_at($t0 + 10)->check('lead', array('k_token' => $token, 'k_website' => 'http://spam'), '1.2.3.4', $rl);

	assert_same('honeypot', $r['reason']);
	assert_same(0, $rl->calls);
});

test('AC-7: швидше ніж за 3 с → too_fast', function () {
	$t0 = 1700000000;
	$token = antispam_at($t0)->token('lead');
	$r = antispam_at($t0 + 2)->check('lead', array('k_token' => $token), '1.2.3.4');

	assert_same('too_fast', $r['reason']);
});

test('AC-7: без токена, підроблений, з іншої сесії чи іншої форми → token', function () {
	$t0 = 1700000000;
	$token = antispam_at($t0)->token('lead');
	$late = antispam_at($t0 + 10);

	assert_same('token', $late->check('lead', array(), '1.2.3.4')['reason']);
	assert_same('token', $late->check('lead', array('k_token' => 'abc'), '1.2.3.4')['reason']);
	assert_same('token', $late->check('lead', array('k_token' => ($t0 - 100) . substr($token, 10)), '1.2.3.4')['reason'], 'змінений час');
	assert_same('token', antispam_at($t0 + 10, 'sess-2')->check('lead', array('k_token' => $token), '1.2.3.4')['reason'], 'інша сесія');
	assert_same('token', $late->check('callback', array('k_token' => $token), '1.2.3.4')['reason'], 'інша форма');
});

test('застарілий токен (> 2 год) → expired', function () {
	$t0 = 1700000000;
	$token = antispam_at($t0)->token('lead');

	assert_same('expired', antispam_at($t0 + 7201)->check('lead', array('k_token' => $token), '1.2.3.4')['reason']);
});

test('AC-7: перевищено ліміт частоти → rate', function () {
	$t0 = 1700000000;
	$token = antispam_at($t0)->token('lead');
	$rl = new FakeRateLimit(10);
	$checker = antispam_at($t0 + 10);

	for ($i = 1; $i <= 10; $i++) {
		assert_true($checker->check('lead', array('k_token' => $token), '1.2.3.4', $rl)['ok'], 'спроба ' . $i);
	}

	assert_same('rate', $checker->check('lead', array('k_token' => $token), '1.2.3.4', $rl)['reason']);
});

test('без солі (модуль не встановлено) жоден токен не проходить', function () {
	$a = new Antispam('', 'sess-1');
	$a->setNow(1700000000);
	$token = $a->token('lead');
	$a->setNow(1700000010);

	assert_same('token', $a->check('lead', array('k_token' => $token), '1.2.3.4')['reason']);
});

test('fields() для twig', function () {
	$f = antispam_at(1700000000)->fields('lead');

	assert_same('k_token', $f['token_name']);
	assert_same('k_website', $f['honeypot_name']);
	assert_true((bool)preg_match('/^1700000000\.[a-f0-9]{32}$/', $f['token']));
});
