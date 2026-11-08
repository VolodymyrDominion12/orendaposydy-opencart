<?php
use Kristal\Image;

// Тестові зображення генеруються GD у тимчасовій теці; без GD (образ php:7.3-cli) тести пропускаються
function __img_dir() {
	$dir = sys_get_temp_dir() . '/kristal-image-test-' . getmypid() . '/';
	if (!is_dir($dir . 'catalog')) { mkdir($dir . 'catalog', 0777, true); }
	return $dir;
}

function __img_make($dir, $name, $w, $h, $type = 'jpg') {
	$im = imagecreatetruecolor($w, $h);
	imagefill($im, 0, 0, imagecolorallocate($im, 200, 30, 30));
	// смуги по краях іншого кольору — після обрізання по центру їх не має бути
	imagefilledrectangle($im, 0, 0, max(0, (int)($w * 0.1)), $h, imagecolorallocate($im, 0, 0, 255));
	$file = $dir . 'catalog/' . $name . '.' . $type;
	$type === 'png' ? imagepng($im, $file) : imagejpeg($im, $file, 90);
	imagedestroy($im);
	return 'catalog/' . $name . '.' . $type;
}

test('шлях кешу', function () {
	assert_same('cache/kristal/catalog/kristal/mock/posud-720x720.webp', Image::cachePath('catalog/kristal/mock/posud.png', 720, 720, 'webp'));
	assert_same('cache/kristal/catalog/a.b/c-10x10.jpg', Image::cachePath('catalog/a.b/c.jpeg', 10, 10, 'jpg'));
});

test('4:3 → квадрат по центру, WebP, без збільшення', function () {
	if (!function_exists('imagecreatetruecolor')) { skip('немає GD'); }
	Image::$webp = Image::webpSupported() ? null : false;
	$dir = __img_dir();
	$file = __img_make($dir, 'wide', 800, 600);
	$r = Image::make($dir, $file, 360, 360);
	assert_same(360, $r['width']);
	assert_same(360, $r['height']);
	$size = getimagesize($dir . $r['path']);
	assert_same(array(360, 360), array($size[0], $size[1]));
	if (Image::webpSupported()) { assert_same(IMAGETYPE_WEBP, $size[2]); }
	// Ліва синя смуга (10% ширини) обрізана: центр обрізання починається з x = 100
	$im = Image::webpSupported() ? imagecreatefromwebp($dir . $r['path']) : imagecreatefromjpeg($dir . $r['path']);
	$rgb = imagecolorsforindex($im, imagecolorat($im, 2, 180));
	assert_true($rgb['red'] > 150 && $rgb['blue'] < 100, 'край без синьої смуги');
	// 1440 з оригіналу 600 px по меншій стороні → 600×600
	$big = Image::make($dir, $file, 1440, 1440);
	assert_same(array(600, 600), array($big['width'], $big['height']));
	Image::$webp = null;
});

test('3:4 → квадрат; кеш перегенеровується, коли оригінал новіший', function () {
	if (!function_exists('imagecreatetruecolor')) { skip('немає GD'); }
	$dir = __img_dir();
	$file = __img_make($dir, 'tall', 600, 800);
	$r = Image::make($dir, $file, 300, 300);
	assert_same(array(300, 300), array($r['width'], $r['height']));
	$target = $dir . $r['path'];
	touch($target, time() - 100);
	touch($dir . $file, time());
	clearstatcache();
	Image::make($dir, $file, 300, 300);
	clearstatcache();
	assert_true(filemtime($target) >= filemtime($dir . $file), 'перегенеровано');
});

test('без WebP у GD → JPEG / PNG', function () {
	if (!function_exists('imagecreatetruecolor')) { skip('немає GD'); }
	Image::$webp = false;
	$dir = __img_dir();
	$jpg = Image::make($dir, __img_make($dir, 'a', 400, 400), 200, 200);
	$png = Image::make($dir, __img_make($dir, 'b', 400, 400, 'png'), 200, 200);
	Image::$webp = null;
	assert_contains('-200x200.jpg', $jpg['path']);
	assert_contains('-200x200.png', $png['path']);
	assert_same(IMAGETYPE_JPEG, getimagesize($dir . $jpg['path'])[2]);
});

test('відсутній файл, вихід за теку, не зображення → null', function () {
	if (!function_exists('imagecreatetruecolor')) { skip('немає GD'); }
	$dir = __img_dir();
	file_put_contents($dir . 'catalog/x.txt', 'not an image');
	assert_same(null, Image::make($dir, 'catalog/nema.jpg', 100, 100));
	assert_same(null, Image::make($dir, '../../etc/passwd', 100, 100));
	assert_same(null, Image::make($dir, 'catalog/x.txt', 100, 100));
});
