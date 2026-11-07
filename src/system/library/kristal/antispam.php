<?php
namespace Kristal;

/**
 * Захист форм без капчі: honeypot + підписаний токен (CSRF і time-trap одночасно) + ліміт частоти.
 *
 * Показ форми (контролер):
 *   $antispam = \Kristal\Antispam::fromConfig($this->config, $this->session->getId());
 *   $data['antispam'] = $antispam->fields('lead');
 *   // twig: <input type="hidden" name="{{ antispam.token_name }}" value="{{ antispam.token }}">
 *   //       <div class="k-hp" aria-hidden="true"><input type="text" name="{{ antispam.honeypot_name }}" tabindex="-1" autocomplete="off"></div>
 *
 * Надсилання:
 *   $rl = new \Kristal\Rate_limit($this->db, $this->config->get('module_kristal_core_salt'));
 *   $result = $antispam->check('lead', $this->request->post, $this->request->server['REMOTE_ADDR'], $rl);
 *   if (!$result['ok']) { ... $result['reason']: honeypot | token | too_fast | expired | rate ... }
 *
 * Тексти помилок для клієнта: catalog/language/*\/extension/module/kristal_core.php (error_spam_*).
 * Фіча 019, PHP 7.3+.
 */
class Antispam {
	const TOKEN_FIELD = 'k_token';
	const HONEYPOT_FIELD = 'k_website';

	private $salt;
	private $session_id;
	private $min_seconds;
	private $max_age;
	private $rate_limit;
	private $rate_window;
	private $now = null;

	public function __construct($salt, $session_id, $options = array()) {
		$this->salt = (string)$salt;
		$this->session_id = (string)$session_id;
		$this->min_seconds = isset($options['min_seconds']) ? max(0, (int)$options['min_seconds']) : 3;
		$this->max_age = isset($options['max_age']) ? max(60, (int)$options['max_age']) : 7200;
		$this->rate_limit = isset($options['rate_limit']) ? max(1, (int)$options['rate_limit']) : 10;
		$this->rate_window = isset($options['rate_window']) ? max(60, (int)$options['rate_window']) : 3600;
	}

	/** Налаштування з адмінки модуля «Крістал: основне». */
	public static function fromConfig($config, $session_id) {
		$options = array(
			'min_seconds' => $config->get('module_kristal_core_spam_min_seconds'),
			'rate_limit'  => $config->get('module_kristal_core_spam_rate_limit'),
			'rate_window' => $config->get('module_kristal_core_spam_rate_window'),
		);

		foreach ($options as $key => $value) {
			if ($value === null || $value === '') {
				unset($options[$key]);
			}
		}

		return new self($config->get('module_kristal_core_salt'), $session_id, $options);
	}

	/** Лише для тестів: зафіксувати «зараз». */
	public function setNow($timestamp) {
		$this->now = $timestamp === null ? null : (int)$timestamp;
	}

	private function now() {
		return $this->now === null ? time() : $this->now;
	}

	public function token($form) {
		$ts = (string)$this->now();

		return $ts . '.' . $this->sign($form, $ts);
	}

	public function fields($form) {
		return array(
			'token_name'    => self::TOKEN_FIELD,
			'token'         => $this->token($form),
			'honeypot_name' => self::HONEYPOT_FIELD
		);
	}

	/**
	 * @param string          $form назва форми ('lead', 'callback' …)
	 * @param array           $post $this->request->post
	 * @param string          $ip   REMOTE_ADDR
	 * @param Rate_limit|null $rate_limit null — частоту не перевіряти
	 * @return array ['ok' => bool, 'reason' => '' | 'honeypot' | 'token' | 'too_fast' | 'expired' | 'rate']
	 */
	public function check($form, $post, $ip, $rate_limit = null) {
		// 1. Пастка: живий клієнт поля не бачить
		if (isset($post[self::HONEYPOT_FIELD]) && trim((string)$post[self::HONEYPOT_FIELD]) !== '') {
			return $this->result('honeypot');
		}

		// 2. Токен: формат → підпис → час
		$token = isset($post[self::TOKEN_FIELD]) ? (string)$post[self::TOKEN_FIELD] : '';

		if (!preg_match('/^(\d{1,12})\.([a-f0-9]{32})$/', $token, $m)) {
			return $this->result('token');
		}

		if ($this->salt === '' || !hash_equals($this->sign($form, $m[1]), $m[2])) {
			return $this->result('token');
		}

		$age = $this->now() - (int)$m[1];

		if ($age < $this->min_seconds) {
			return $this->result('too_fast');
		}

		if ($age > $this->max_age) {
			return $this->result('expired');
		}

		// 3. Частота — лише для запитів, що пройшли 1–2 (бот не «з'їдає» ліміт живих клієнтів зі спільної IP)
		if ($rate_limit !== null && !$rate_limit->hit('form:' . $form, (string)$ip, $this->rate_limit, $this->rate_window)) {
			return $this->result('rate');
		}

		return $this->result('');
	}

	private function sign($form, $ts) {
		return substr(hash_hmac('sha256', $this->session_id . '|' . $form . '|' . $ts, $this->salt), 0, 32);
	}

	private function result($reason) {
		return array('ok' => $reason === '', 'reason' => $reason);
	}
}
