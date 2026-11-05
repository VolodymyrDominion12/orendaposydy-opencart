<?php
/**
 * Мінімальний раннер тестів бібліотеки Kristal\* (фіча 019). Без фреймворків і Composer.
 *
 *   make test-lib                         # у контейнері web (PHP як локально, є БД)
 *   php tests/lib/run.php [фільтр]        # напряму; тести з БД пропускаються, якщо її немає
 *
 * Тест-файл — tests/lib/*_test.php:
 *   test('назва', function () { assert_same('+380671234567', \Kristal\Phone::normalize('067 123 45 67')); });
 *
 * БД (для rate_limit_test): змінні DB_HOSTNAME, DB_USERNAME, DB_PASSWORD, DB_DATABASE, DB_PREFIX
 * (у контейнері web вони вже є з docker-compose.yml).
 * Код виходу: 0 — усе зелене, 1 — є падіння.
 */

error_reporting(E_ALL);
ini_set('display_errors', '1');

// Будь-яке попередження — це падіння тесту (AGENTS.md §6: без Notice/Warning)
set_error_handler(function ($severity, $message, $file, $line) {
	throw new ErrorException($message, 0, $severity, $file, $line);
});

$src = getenv('KRISTAL_SRC') ?: __DIR__ . '/../../src';
$src = rtrim(realpath($src) ?: $src, '/') . '/';

if (!is_dir($src . 'system/library/kristal')) {
	fwrite(STDERR, "Не знайдено {$src}system/library/kristal — задайте KRISTAL_SRC\n");
	exit(1);
}

$logs = sys_get_temp_dir() . '/kristal-test-lib-' . getmypid() . '/';
@mkdir($logs, 0777, true);

define('DIR_SYSTEM', $src . 'system/');
define('DIR_LOGS', $logs);
define('DB_PREFIX', getenv('DB_PREFIX') ?: 'oc_');

// Registry ядро підключає явно (system/startup.php), не автолоадером
require_once DIR_SYSTEM . 'engine/registry.php';

// Той самий автолоадер, що в system/startup.php ядра
spl_autoload_register(function ($class) {
	$file = DIR_SYSTEM . 'library/' . str_replace('\\', '/', strtolower($class)) . '.php';

	if (is_file($file)) {
		include_once($file);
		return true;
	}

	return false;
});

// --- API для тестів ---------------------------------------------------------
$GLOBALS['__tests'] = array();

function test($name, $fn) {
	$GLOBALS['__tests'][] = array($GLOBALS['__file'], $name, $fn);
}

class TestSkipped extends Exception {}

function skip($reason) {
	throw new TestSkipped($reason);
}

function export($value) {
	return str_replace("\n", ' ', var_export($value, true));
}

function assert_same($expected, $actual, $message = '') {
	if ($expected !== $actual) {
		throw new Exception(($message !== '' ? $message . ': ' : '') . 'очікували ' . export($expected) . ', отримали ' . export($actual));
	}
}

function assert_true($value, $message = '') {
	assert_same(true, $value, $message);
}

function assert_false($value, $message = '') {
	assert_same(false, $value, $message);
}

function assert_contains($needle, $haystack, $message = '') {
	if (strpos((string)$haystack, (string)$needle) === false) {
		throw new Exception(($message !== '' ? $message . ': ' : '') . 'немає ' . export($needle) . ' у ' . export($haystack));
	}
}

function assert_not_contains($needle, $haystack, $message = '') {
	if (strpos((string)$haystack, (string)$needle) !== false) {
		throw new Exception(($message !== '' ? $message . ': ' : '') . 'не мало бути ' . export($needle) . ' у ' . export($haystack));
	}
}

/** \DB ядра або skip(), якщо бази немає */
function test_db() {
	static $db = null, $error = null;

	if ($db !== null) {
		return $db;
	}

	if ($error !== null) {
		skip($error);
	}

	$host = getenv('DB_HOSTNAME');

	if (!$host || !extension_loaded('mysqli')) {
		$error = 'немає БД (DB_HOSTNAME не задано) — запустіть make test-lib';
		skip($error);
	}

	try {
		mysqli_report(MYSQLI_REPORT_OFF);
		$db = new \DB('mysqli', $host, getenv('DB_USERNAME'), getenv('DB_PASSWORD'), getenv('DB_DATABASE'), getenv('DB_PORT') ?: '3306');
	} catch (Exception $e) {
		$error = 'БД недоступна: ' . $e->getMessage();
		skip($error);
	}

	return $db;
}

// --- Запуск -----------------------------------------------------------------
$filter = isset($argv[1]) ? $argv[1] : '';
$files = glob(__DIR__ . '/*_test.php');
sort($files);

foreach ($files as $file) {
	$GLOBALS['__file'] = basename($file, '.php');
	require $file;
}

$passed = 0;
$failed = 0;
$skipped = 0;
$tty = function_exists('posix_isatty') && posix_isatty(STDOUT);
$c = function ($code, $text) use ($tty) {
	return $tty ? "\033[" . $code . 'm' . $text . "\033[0m" : $text;
};

foreach ($GLOBALS['__tests'] as $t) {
	list($file, $name, $fn) = $t;

	if ($filter !== '' && strpos($file . ' ' . $name, $filter) === false) {
		continue;
	}

	try {
		$fn();
		$passed++;
		echo '  ' . $c('32', 'OK') . "   {$file}: {$name}\n";
	} catch (TestSkipped $e) {
		$skipped++;
		echo '  ' . $c('33', 'SKIP') . " {$file}: {$name} — " . $e->getMessage() . "\n";
	} catch (Throwable $e) {
		$failed++;
		echo '  ' . $c('31', 'FAIL') . " {$file}: {$name}\n       " . $e->getMessage()
			. ' (' . basename($e->getFile()) . ':' . $e->getLine() . ")\n";
	}
}

// прибрати тимчасові логи
foreach (glob($logs . '*') as $f) {
	@unlink($f);
}
@rmdir($logs);

echo "\n  Разом: {$passed} OK, {$failed} FAIL, {$skipped} SKIP (PHP " . PHP_VERSION . ")\n";

if ($passed + $failed == 0) {
	echo "  Жодного тесту не виконано\n";
	exit(1);
}

exit($failed > 0 ? 1 : 0);
