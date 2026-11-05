<?php
namespace Kristal;

/**
 * Мікророзмітка JSON-LD (AGENTS.md §7): лише з реальних даних, порожні поля не виводяться.
 *
 *   $data = \Kristal\Jsonld::localBusiness(\Kristal\Nap::get($this->registry), $base_url, $logo_url);
 *   echo \Kristal\Jsonld::render($data);   // <script type="application/ld+json">…</script>
 *
 * Виведення на сторінки — фіча 011. Фіча 019, PHP 7.3+.
 */
class Jsonld {
	private static $day_names = array(
		'Mo' => 'Monday', 'Tu' => 'Tuesday', 'We' => 'Wednesday', 'Th' => 'Thursday',
		'Fr' => 'Friday', 'Sa' => 'Saturday', 'Su' => 'Sunday'
	);

	public static function localBusiness($nap, $url = '', $logo = '') {
		$data = array(
			'@context'  => 'https://schema.org',
			'@type'     => 'LocalBusiness',
			'name'      => isset($nap['name']) ? $nap['name'] : '',
			'legalName' => isset($nap['legal_name']) ? $nap['legal_name'] : '',
			'url'       => (string)$url,
			'logo'      => (string)$logo,
			'image'     => (string)$logo,
			'telephone' => !empty($nap['primary_phone']['number']) ? $nap['primary_phone']['number'] : '',
			'email'     => isset($nap['email']) ? $nap['email'] : ''
		);

		$street = isset($nap['address']) ? $nap['address'] : '';
		$city = isset($nap['city']) ? $nap['city'] : '';

		if ($street !== '' || $city !== '') {
			$data['address'] = array(
				'@type'           => 'PostalAddress',
				'streetAddress'   => $street,
				'addressLocality' => $city,
				'postalCode'      => isset($nap['postcode']) ? $nap['postcode'] : '',
				'addressCountry'  => 'UA'
			);
		}

		if (!empty($nap['geo'])) {
			$data['geo'] = array(
				'@type'     => 'GeoCoordinates',
				'latitude'  => $nap['geo']['lat'],
				'longitude' => $nap['geo']['lng']
			);
		}

		if (!empty($nap['hours'])) {
			$data['openingHoursSpecification'] = array();

			foreach ($nap['hours'] as $row) {
				$days = array();

				foreach ($row['days'] as $code) {
					if (isset(self::$day_names[$code])) {
						$days[] = self::$day_names[$code];
					}
				}

				$data['openingHoursSpecification'][] = array(
					'@type'     => 'OpeningHoursSpecification',
					'dayOfWeek' => $days,
					'opens'     => $row['from'],
					'closes'    => $row['to']
				);
			}
		}

		if (!empty($nap['social'])) {
			$data['sameAs'] = array_values($nap['social']);
		}

		return self::clean($data);
	}

	public static function encode($data, $pretty = false) {
		$flags = JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES | JSON_HEX_TAG;

		if ($pretty) {
			$flags |= JSON_PRETTY_PRINT;
		}

		return json_encode($data, $flags);
	}

	public static function render($data) {
		if (!$data) {
			return '';
		}

		return '<script type="application/ld+json">' . self::encode($data) . '</script>';
	}

	/** Прибирає '', null і порожні масиви рекурсивно; блоки з одним лише @type теж. */
	public static function clean($data) {
		$is_list = array_keys($data) === range(0, count($data) - 1);

		foreach ($data as $key => $value) {
			if (is_array($value)) {
				$value = self::clean($value);

				if (!$value || (count($value) == 1 && isset($value['@type']))) {
					unset($data[$key]);
					continue;
				}

				$data[$key] = $value;
			} elseif ($value === '' || $value === null) {
				unset($data[$key]);
			}
		}

		return $is_list ? array_values($data) : $data;
	}
}
