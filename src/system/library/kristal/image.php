<?php
namespace Kristal;

/**
 * Зображення для вітрини (фіча 020): обрізання по центру до пропорції → зменшення → WebP (або JPEG/PNG без WebP у GD).
 * Кеш: DIR_IMAGE/cache/kristal/<шлях оригіналу без розширення>-<W>x<H>.<webp|jpg|png>; перегенерація — якщо оригінал новіший.
 * Ніколи не збільшує: якщо оригінал менший за потрібний розмір, результат — найбільший можливий з тією ж пропорцією.
 * Оригінал не змінюється. Ядро (model/tool/image) не використовується й не змінюється. PHP 7.3+, GD.
 *
 *   $r = \Kristal\Image::make(DIR_IMAGE, 'catalog/x.jpg', 720, 720);   // ['path' => 'cache/kristal/catalog/x-720x720.webp', 'width' => 720, 'height' => 720] або null
 */
class Image {
	const QUALITY = 80;

	/** Розміри теми, px (spec 020, питання 4): [1×, 2×] квадрат */
	const CARD = array(360, 720);
	const MAIN = array(720, 1440);
	const THUMB = array(120, 240);
	const TILE = array(480, 960);

	/** @var bool|null примусово вимкнути WebP (тести, сервер без WebP) */
	public static $webp = null;

	public static function webpSupported() {
		if (self::$webp !== null) {
			return self::$webp;
		}

		if (!function_exists('imagewebp') || !function_exists('gd_info')) {
			return false;
		}

		$info = gd_info();

		return !empty($info['WebP Support']);
	}

	/**
	 * @param string $dir_image  абсолютна тека зображень (DIR_IMAGE) зі слешем у кінці
	 * @param string $file       відносний шлях оригіналу (як у oc_product.image)
	 * @return array|null ['path', 'width', 'height'] — шлях відносно $dir_image; null — немає файлу / не зображення / замало пам'яті
	 */
	public static function make($dir_image, $file, $width, $height) {
		$width = (int)$width;
		$height = (int)$height;
		$source = $dir_image . $file;

		if ($width < 1 || $height < 1 || !self::inside($dir_image, $source) || !function_exists('imagecreatetruecolor')) {
			return null;
		}

		$info = @getimagesize($source);

		if (!$info || !in_array($info[2], array(IMAGETYPE_JPEG, IMAGETYPE_PNG, IMAGETYPE_GIF, IMAGETYPE_WEBP), true)) {
			return null;
		}

		list($src_w, $src_h, $type) = $info;

		// Область обрізання по центру з пропорцією цілі
		$ratio = $width / $height;

		if ($src_w / $src_h > $ratio) {
			$crop_h = $src_h;
			$crop_w = (int)round($src_h * $ratio);
		} else {
			$crop_w = $src_w;
			$crop_h = (int)round($src_w / $ratio);
		}

		$crop_x = (int)floor(($src_w - $crop_w) / 2);
		$crop_y = (int)floor(($src_h - $crop_h) / 2);

		// Не збільшуємо
		if ($crop_w < $width) {
			$width = $crop_w;
			$height = max(1, (int)round($crop_w / $ratio));
		}

		$extension = self::webpSupported() ? 'webp' : ($type === IMAGETYPE_PNG || $type === IMAGETYPE_GIF ? 'png' : 'jpg');
		$path = self::cachePath($file, $width, $height, $extension);
		$target = $dir_image . $path;

		if (is_file($target) && filemtime($target) >= filemtime($source)) {
			return array('path' => $path, 'width' => $width, 'height' => $height);
		}

		if (!self::enoughMemory($src_w, $src_h, $width, $height)) {
			return null;
		}

		$image = self::open($source, $type);

		if (!$image) {
			return null;
		}

		$out = imagecreatetruecolor($width, $height);
		$alpha = $extension !== 'jpg';

		if ($alpha) {
			imagealphablending($out, false);
			imagesavealpha($out, true);
			imagefill($out, 0, 0, imagecolorallocatealpha($out, 0, 0, 0, 127));
		}

		imagecopyresampled($out, $image, 0, 0, $crop_x, $crop_y, $width, $height, $crop_w, $crop_h);
		imagedestroy($image);

		if (!is_dir(dirname($target))) {
			@mkdir(dirname($target), 0777, true);
		}

		// Атомарно: тимчасовий файл → rename, щоб паралельний запит не віддав напівзаписаний
		$tmp = $target . '.' . getmypid() . '.tmp';

		if ($extension === 'webp') {
			$ok = imagewebp($out, $tmp, self::QUALITY);
		} elseif ($extension === 'png') {
			$ok = imagepng($out, $tmp, 9);
		} else {
			imageinterlace($out, true);
			$ok = imagejpeg($out, $tmp, self::QUALITY);
		}

		imagedestroy($out);

		if (!$ok || !@rename($tmp, $target)) {
			@unlink($tmp);
			return null;
		}

		return array('path' => $path, 'width' => $width, 'height' => $height);
	}

	public static function cachePath($file, $width, $height, $extension) {
		$file = str_replace('\\', '/', $file);
		$dot = strrpos($file, '.');
		$base = $dot !== false && $dot > strrpos($file, '/') ? substr($file, 0, $dot) : $file;

		return 'cache/kristal/' . ltrim($base, '/') . '-' . (int)$width . 'x' . (int)$height . '.' . $extension;
	}

	/** Файл існує й лежить усередині теки зображень (без ../) */
	private static function inside($dir_image, $path) {
		$real = realpath($path);
		$root = realpath($dir_image);

		return $real && $root && is_file($real) && strpos(str_replace('\\', '/', $real), rtrim(str_replace('\\', '/', $root), '/') . '/') === 0;
	}

	private static function open($source, $type) {
		switch ($type) {
			case IMAGETYPE_JPEG:
				return @imagecreatefromjpeg($source);
			case IMAGETYPE_PNG:
				return @imagecreatefrompng($source);
			case IMAGETYPE_GIF:
				return @imagecreatefromgif($source);
			case IMAGETYPE_WEBP:
				return function_exists('imagecreatefromwebp') ? @imagecreatefromwebp($source) : false;
		}

		return false;
	}

	/** ~5 байтів на піксель оригіналу + результату з запасом; -1 = без ліміту */
	private static function enoughMemory($src_w, $src_h, $width, $height) {
		$limit = self::bytes(ini_get('memory_limit'));

		if ($limit <= 0) {
			return true;
		}

		$need = ($src_w * $src_h + $width * $height) * 5 + 8 * 1024 * 1024;

		return memory_get_usage() + $need < $limit;
	}

	private static function bytes($value) {
		$value = trim((string)$value);

		if ($value === '' || $value === '-1') {
			return -1;
		}

		$number = (int)$value;
		$unit = strtolower(substr($value, -1));

		if ($unit === 'g') {
			$number *= 1024 * 1024 * 1024;
		} elseif ($unit === 'm') {
			$number *= 1024 * 1024;
		} elseif ($unit === 'k') {
			$number *= 1024;
		}

		return $number;
	}
}
