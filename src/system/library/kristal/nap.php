<?php
namespace Kristal;

/**
 * Контакти компанії (Name, Address, Phone + месенджери, графік, соцмережі) з налаштувань модуля
 * «Крістал: основне» (`module_kristal_core_*` у $this->config — ядро вже завантажило їх, запитів до БД немає).
 *
 *   $nap = \Kristal\Nap::get($this->registry);
 *   $nap['phones'][0]['display']  // '+38 067 123 45 67'
 *   $nap['phones'][0]['tel']      // 'tel:+380671234567'
 *   $nap['phones'][0]['viber']    // 'viber://chat?number=%2B380671234567' або ''
 *
 * Порожні поля не вигадуються: '' / порожній масив. Кеш `kristal.nap` скидається при збереженні модуля.
 * Фіча 019, PHP 7.3+.
 */
class Nap {
	const MAX_PHONES = 3;

	/** Коди днів schema.org у порядку тижня */
	private static $days = array('Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su');

	private static $social = array(
		'instagram' => 'https://www.instagram.com/%s/',
		'facebook'  => 'https://www.facebook.com/%s',
		'tiktok'    => 'https://www.tiktok.com/@%s',
		'youtube'   => 'https://www.youtube.com/@%s',
		'telegram'  => 'https://t.me/%s'
	);

	public static function dayCodes() {
		return self::$days;
	}

	/** Нормалізовані контакти з кешем. */
	public static function get($registry) {
		$cache = $registry->get('cache');
		$nap = $cache ? $cache->get(Cache_key::NAP) : false;

		if (!is_array($nap)) {
			$nap = self::fromConfig($registry->get('config'));

			if ($cache) {
				$cache->set(Cache_key::NAP, $nap);
			}
		}

		return $nap;
	}

	public static function fromConfig($config) {
		$keys = array('name', 'legal_name', 'address', 'city', 'postcode', 'email', 'geo_lat', 'geo_lng',
			'phones', 'hours', 'hours_note', 'telegram_username', 'instagram', 'facebook', 'tiktok', 'youtube');

		$settings = array();

		foreach ($keys as $key) {
			$settings[$key] = $config->get('module_kristal_core_' . $key);
		}

		return self::normalize($settings);
	}

	/**
	 * @param array $s ключі без префікса module_kristal_core_ (phones/hours — масиви або JSON)
	 */
	public static function normalize($s) {
		$text = function ($key) use ($s) {
			return isset($s[$key]) && is_scalar($s[$key]) ? trim((string)$s[$key]) : '';
		};

		$nap = array(
			'name'       => $text('name'),
			'legal_name' => $text('legal_name'),
			'address'    => $text('address'),
			'city'       => $text('city'),
			'postcode'   => $text('postcode'),
			'email'      => filter_var($text('email'), FILTER_VALIDATE_EMAIL) ? $text('email') : '',
			'geo'        => self::geo($text('geo_lat'), $text('geo_lng')),
			'phones'     => self::phones(isset($s['phones']) ? $s['phones'] : array()),
			'hours'      => self::hours(isset($s['hours']) ? $s['hours'] : array()),
			'hours_note' => $text('hours_note'),
			'social'     => array()
		);

		$nap['primary_phone'] = $nap['phones'] ? $nap['phones'][0] : null;

		foreach (array_keys(self::$social) as $network) {
			$value = $network === 'telegram' ? $text('telegram_username') : $text($network);
			$url = self::socialUrl($network, $value);

			if ($url !== '') {
				$nap['social'][$network] = $url;
			}
		}

		return $nap;
	}

	public static function geo($lat, $lng) {
		if (!is_numeric($lat) || !is_numeric($lng)) {
			return null;
		}

		$lat = (float)$lat;
		$lng = (float)$lng;

		if ($lat < -90 || $lat > 90 || $lng < -180 || $lng > 180 || ($lat == 0 && $lng == 0)) {
			return null;
		}

		return array('lat' => $lat, 'lng' => $lng);
	}

	public static function phones($phones) {
		if (is_string($phones)) {
			$phones = json_decode($phones, true);
		}

		$result = array();

		if (!is_array($phones)) {
			return $result;
		}

		foreach ($phones as $phone) {
			if (!is_array($phone) || !isset($phone['number'])) {
				continue;
			}

			$e164 = Phone::normalize($phone['number']);

			if ($e164 === '') {
				continue;
			}

			$result[] = array(
				'number'   => $e164,
				'display'  => Phone::display($e164),
				'tel'      => 'tel:' . $e164,
				'label'    => isset($phone['label']) ? trim((string)$phone['label']) : '',
				'viber'    => !empty($phone['viber']) ? 'viber://chat?number=' . rawurlencode($e164) : '',
				'telegram' => !empty($phone['telegram']) ? 'https://t.me/' . $e164 : '',
				'whatsapp' => !empty($phone['whatsapp']) ? 'https://wa.me/' . substr($e164, 1) : ''
			);

			if (count($result) >= self::MAX_PHONES) {
				break;
			}
		}

		return $result;
	}

	/** [{days: ['Mo','Tu'], from: '09:00', to: '18:00'}]; рядки без днів або з невірним часом відкидаються. */
	public static function hours($hours) {
		if (is_string($hours)) {
			$hours = json_decode($hours, true);
		}

		$result = array();

		if (!is_array($hours)) {
			return $result;
		}

		foreach ($hours as $row) {
			if (!is_array($row) || empty($row['days']) || !is_array($row['days'])) {
				continue;
			}

			$from = isset($row['from']) ? self::time($row['from']) : '';
			$to = isset($row['to']) ? self::time($row['to']) : '';

			if ($from === '' || $to === '') {
				continue;
			}

			$days = array_values(array_intersect(self::$days, $row['days']));

			if (!$days) {
				continue;
			}

			$result[] = array('days' => $days, 'from' => $from, 'to' => $to);
		}

		return $result;
	}

	/** '9:00' → '09:00'; невірне → '' */
	public static function time($value) {
		if (!preg_match('/^([01]?\d|2[0-3]):([0-5]\d)$/', trim((string)$value), $m)) {
			return '';
		}

		return sprintf('%02d:%02d', (int)$m[1], (int)$m[2]);
	}

	/** URL як є (лише https/http) або @нік / нік → посилання соцмережі */
	public static function socialUrl($network, $value) {
		$value = trim((string)$value);

		if ($value === '') {
			return '';
		}

		if (preg_match('#^https?://#i', $value)) {
			return filter_var($value, FILTER_VALIDATE_URL) ? $value : '';
		}

		$nick = ltrim($value, '@');

		if (!isset(self::$social[$network]) || !preg_match('/^[A-Za-z0-9_.\-]{2,64}$/', $nick)) {
			return '';
		}

		return sprintf(self::$social[$network], $nick);
	}
}
