<?php
use Kristal\Rate_limit;

function rate_limit_table_ready($db) {
	$q = $db->query("SHOW TABLES LIKE '" . $db->escape(DB_PREFIX . 'kristal_rate_limit') . "'");

	if (!$q->num_rows) {
		throw new Exception('немає таблиці ' . DB_PREFIX . 'kristal_rate_limit — виконайте make migrate (0004)');
	}
}

test('AC-7: 10 спроб дозволено, 11-та — ні; після зсуву вікна знову можна', function () {
	$db = test_db();
	rate_limit_table_ready($db);

	$rl = new Rate_limit($db, 'test-salt-' . uniqid('', true));
	$rl->setCleanupChance(0);
	$ip = '203.0.113.' . mt_rand(1, 254);
	$key = $rl->key('form:test', $ip);

	try {
		for ($i = 1; $i <= 10; $i++) {
			assert_true($rl->hit('form:test', $ip, 10, 3600), 'спроба ' . $i);
		}

		assert_false($rl->hit('form:test', $ip, 10, 3600), '11-та спроба');

		// інша дія з тієї ж IP рахується окремо
		$other = $rl->key('form:other', $ip);
		assert_true($rl->hit('form:other', $ip, 10, 3600), 'інша форма');

		// вікно минуло
		$db->query("UPDATE `" . DB_PREFIX . "kristal_rate_limit` SET `window_start` = NOW() - INTERVAL 3601 SECOND WHERE `key_hash` = '" . $db->escape($key) . "'");
		assert_true($rl->hit('form:test', $ip, 10, 3600), 'нове вікно');

		// порядок присвоєнь: hits скинуто в 1, а не 12 (інакше hits бачив би вже оновлене вікно)
		$q = $db->query("SELECT `hits`, `window_start` > NOW() - INTERVAL 5 SECOND AS fresh FROM `" . DB_PREFIX . "kristal_rate_limit` WHERE `key_hash` = '" . $db->escape($key) . "'");
		assert_same(1, (int)$q->row['hits'], 'hits після скидання');
		assert_same(1, (int)$q->row['fresh'], 'window_start оновлено');
	} finally {
		$db->query("DELETE FROM `" . DB_PREFIX . "kristal_rate_limit` WHERE `key_hash` IN ('" . $db->escape($key) . "', '" . $db->escape(isset($other) ? $other : '') . "')");
	}
});

test('IP не зберігається у відкритому вигляді', function () {
	$db = test_db();
	rate_limit_table_ready($db);

	$rl = new Rate_limit($db, 'test-salt-' . uniqid('', true));
	$rl->setCleanupChance(0);
	$ip = '198.51.100.' . mt_rand(1, 254);
	$key = $rl->key('form:test', $ip);

	try {
		$rl->hit('form:test', $ip, 10, 3600);
		$q = $db->query("SELECT COUNT(*) AS n FROM `" . DB_PREFIX . "kristal_rate_limit` WHERE `key_hash` = '" . $db->escape($ip) . "' OR `action` LIKE '%" . $db->escape($ip) . "%'");
		assert_same(0, (int)$q->row['n']);
		assert_same(40, strlen($key));
	} finally {
		$db->query("DELETE FROM `" . DB_PREFIX . "kristal_rate_limit` WHERE `key_hash` = '" . $db->escape($key) . "'");
	}
});

test('очищення старих записів (DELETE за idx_window_start)', function () {
	$db = test_db();
	rate_limit_table_ready($db);

	$rl = new Rate_limit($db, 'test-salt-' . uniqid('', true));
	$rl->setCleanupChance(0);
	$old = $rl->key('form:test', '192.0.2.1');
	$db->query("INSERT INTO `" . DB_PREFIX . "kristal_rate_limit` (`key_hash`, `action`, `hits`, `window_start`) VALUES ('" . $db->escape($old) . "', 'form:test', 3, NOW() - INTERVAL 2 DAY)");

	$rl->setCleanupChance(1); // кожен виклик
	$rl->hit('form:test', '192.0.2.2', 10, 3600);
	$new = $rl->key('form:test', '192.0.2.2');

	$q = $db->query("SELECT COUNT(*) AS n FROM `" . DB_PREFIX . "kristal_rate_limit` WHERE `key_hash` = '" . $db->escape($old) . "'");
	$db->query("DELETE FROM `" . DB_PREFIX . "kristal_rate_limit` WHERE `key_hash` IN ('" . $db->escape($old) . "', '" . $db->escape($new) . "')");

	assert_same(0, (int)$q->row['n']);
});
