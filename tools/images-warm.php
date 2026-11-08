<?php
/**
 * Прогрів кешу зображень вітрини (фіча 020): усі розміри теми для увімкнених товарів і категорій.
 * Запуск: make images-warm (у контейнері web від www-data). На проді кеш генерується сам при першому показі
 * (SSH немає) — ця команда для локального стенда/staging перед показом і після імпорту прайсу (022).
 */
require '/var/www/html/config.php';
require DIR_SYSTEM . 'library/kristal/image.php';

$db = new mysqli(DB_HOSTNAME, DB_USERNAME, DB_PASSWORD, DB_DATABASE, (int)DB_PORT);
$db->set_charset('utf8mb4');

$files = array();
$res = $db->query("SELECT image FROM `" . DB_PREFIX . "product` WHERE status = 1 AND image <> ''
	UNION SELECT pi.image FROM `" . DB_PREFIX . "product_image` pi JOIN `" . DB_PREFIX . "product` p ON (p.product_id = pi.product_id AND p.status = 1) WHERE pi.image <> ''");
while ($row = $res->fetch_assoc()) {
	$files[$row['image']] = array_merge(\Kristal\Image::CARD, \Kristal\Image::MAIN, \Kristal\Image::THUMB);
}
$res = $db->query("SELECT image FROM `" . DB_PREFIX . "category` WHERE status = 1 AND image <> ''");
while ($row = $res->fetch_assoc()) {
	$files[$row['image']] = isset($files[$row['image']]) ? array_merge($files[$row['image']], \Kristal\Image::TILE) : \Kristal\Image::TILE;
}

$start = microtime(true);
$count = function () {
	$n = 0;
	if (is_dir(DIR_IMAGE . 'cache/kristal')) {
		foreach (new RecursiveIteratorIterator(new RecursiveDirectoryIterator(DIR_IMAGE . 'cache/kristal', FilesystemIterator::SKIP_DOTS)) as $f) {
			$n++;
		}
	}
	return $n;
};
$before = $count();
$missing = $failed = 0;

foreach ($files as $file => $sizes) {
	if (!is_file(DIR_IMAGE . $file)) {
		$missing++;
		continue;
	}
	foreach (array_unique($sizes) as $size) {
		if (!\Kristal\Image::make(DIR_IMAGE, $file, $size, $size)) {
			$failed++;
		}
	}
}

printf("  Оригіналів: %d (немає файлу: %d); нових файлів у кеші: %d; помилок генерації: %d; %.1f с; WebP: %s\n",
	count($files), $missing, $count() - $before, $failed, microtime(true) - $start, \Kristal\Image::webpSupported() ? 'так' : 'ні (JPEG/PNG)');
if ($missing) {
	echo "  Відсутні оригінали — фото не імпортовані з хостингу (make import) або видалені; на вітрині буде заглушка.\n";
}
