<?php
/**
 * Зображення вітрини з srcset (фіча 020). Без запитів до БД.
 *
 *   $img = $this->model_extension_kristal_media->image('catalog/x.jpg', array(360, 720));
 *   // ['src' => '…-360x360.webp', 'srcset' => '…-360x360.webp 360w, …-720x720.webp 720w', 'width' => 360, 'height' => 360]
 *
 * Квадрат (1:1) за замовчуванням; $ratio = ширина / висота для інших пропорцій. Немає файлу — заглушка placeholder.png;
 * не вдалося згенерувати (пам'ять, формат) — зображення через ядро (model/tool/image) того самого розміру.
 */
class ModelExtensionKristalMedia extends Model {
	/** Розміри теми — у \Kristal\Image (спільні з make images-warm) */
	const CARD = \Kristal\Image::CARD;
	const MAIN = \Kristal\Image::MAIN;
	const THUMB = \Kristal\Image::THUMB;
	const TILE = \Kristal\Image::TILE;

	public function image($file, $widths, $ratio = 1.0) {
		$file = (string)$file;

		if ($file === '' || !is_file(DIR_IMAGE . $file)) {
			$file = 'placeholder.png';
		}

		$base = $this->base();
		$items = array();

		foreach ($widths as $w) {
			$h = max(1, (int)round($w / $ratio));
			$made = \Kristal\Image::make(DIR_IMAGE, $file, $w, $h);

			if ($made) {
				// Менший за запит оригінал дає менший файл — однакові розміри в srcset не дублюємо
				$items[$made['width']] = array('url' => $base . str_replace(' ', '%20', $made['path']), 'width' => $made['width'], 'height' => $made['height']);
			}
		}

		if (!$items) {
			$this->load->model('tool/image');
			$w = (int)reset($widths);
			$h = max(1, (int)round($w / $ratio));

			return array('src' => (string)$this->model_tool_image->resize($file, $w, $h), 'srcset' => '', 'width' => $w, 'height' => $h);
		}

		ksort($items);
		$first = reset($items);
		$srcset = array();

		foreach ($items as $item) {
			$srcset[] = $item['url'] . ' ' . $item['width'] . 'w';
		}

		return array(
			'src'    => $first['url'],
			'srcset' => count($srcset) > 1 ? implode(', ', $srcset) : '',
			'width'  => $first['width'],
			'height' => $first['height']
		);
	}

	private function base() {
		return (!empty($this->request->server['HTTPS']) ? $this->config->get('config_ssl') : $this->config->get('config_url')) . 'image/';
	}
}
