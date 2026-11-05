<?php
namespace Kristal;

/**
 * Ліміт частоти спроб (фіксоване вікно) у таблиці {{PREFIX}}kristal_rate_limit (міграція 0004).
 *
 *   $rl = new \Kristal\Rate_limit($this->db, $salt);
 *   if (!$rl->hit('lead', $ip, 10, 3600)) { ... забагато спроб ... }
 *
 * IP у базі не зберігається — лише sha1(salt|action|ip).
 * Запити: 1 INSERT … ON DUPLICATE KEY UPDATE за PK, 1 SELECT за PK, рідко — DELETE за idx_window_start.
 * Фіча 019, PHP 7.3+.
 */
class Rate_limit {
	private $db;
	private $salt;
	private $prefix;
	private $cleanup_chance = 100;

	/**
	 * @param object $db     \DB ядра (query(), escape())
	 * @param string $salt   module_kristal_core_salt
	 * @param string $prefix префікс таблиць (типово DB_PREFIX)
	 */
	public function __construct($db, $salt, $prefix = null) {
		$this->db = $db;
		$this->salt = (string)$salt;

		if ($prefix === null) {
			$prefix = defined('DB_PREFIX') ? DB_PREFIX : 'oc_';
		}

		$this->prefix = $prefix;
	}

	/** 1 з N викликів прибирає старі записи; 0 — ніколи (для тестів). */
	public function setCleanupChance($n) {
		$this->cleanup_chance = (int)$n;
	}

	public function key($action, $ip) {
		return sha1($this->salt . '|' . $action . '|' . $ip);
	}

	/**
	 * Зарахувати спробу. true — у межах ліміту, false — перевищено.
	 */
	public function hit($action, $ip, $limit, $window) {
		$action = substr(preg_replace('/[^a-z0-9_\-:]/i', '', (string)$action), 0, 32);
		$key = $this->key($action, $ip);
		$window = max(1, (int)$window);
		$limit = max(1, (int)$limit);
		$table = '`' . $this->prefix . 'kristal_rate_limit`';

		// hits стоїть ПЕРЕД window_start: MariaDB обчислює присвоєння зліва направо,
		// тож hits ще бачить старе вікно (перевіряє tests/lib/rate_limit_test.php).
		$this->db->query("INSERT INTO " . $table . " (`key_hash`, `action`, `hits`, `window_start`)"
			. " VALUES ('" . $this->db->escape($key) . "', '" . $this->db->escape($action) . "', 1, NOW())"
			. " ON DUPLICATE KEY UPDATE"
			. " `hits` = IF(`window_start` < NOW() - INTERVAL " . $window . " SECOND, 1, `hits` + 1),"
			. " `window_start` = IF(`window_start` < NOW() - INTERVAL " . $window . " SECOND, NOW(), `window_start`)");

		$query = $this->db->query("SELECT `hits` FROM " . $table . " WHERE `key_hash` = '" . $this->db->escape($key) . "'");

		if ($this->cleanup_chance > 0 && mt_rand(1, $this->cleanup_chance) == 1) {
			$this->db->query("DELETE FROM " . $table . " WHERE `window_start` < NOW() - INTERVAL 1 DAY");
		}

		$hits = isset($query->row['hits']) ? (int)$query->row['hits'] : 1;

		return $hits <= $limit;
	}
}
