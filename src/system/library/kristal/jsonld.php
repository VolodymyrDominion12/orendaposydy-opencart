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

	/**
	 * BreadcrumbList (021, SEO-сторінки фільтрів): [['name' => 'Головна', 'url' => 'https://…'], …].
	 * Назви — як у крихтах (можуть бути закодовані ядром) → декодуємо; останній пункт без url — поточна сторінка.
	 */
	public static function breadcrumbs(array $items) {
		$list = array();
		$position = 1;

		foreach ($items as $item) {
			$name = trim(html_entity_decode(strip_tags((string)$item['name']), ENT_QUOTES, 'UTF-8'));

			if ($name === '') {
				continue;
			}

			$entry = array('@type' => 'ListItem', 'position' => $position++, 'name' => $name);

			if (!empty($item['url'])) {
				$entry['item'] = html_entity_decode((string)$item['url'], ENT_QUOTES, 'UTF-8');
			}

			$list[] = $entry;
		}

		if (count($list) < 2) {
			return array();
		}

		return array('@context' => 'https://schema.org', '@type' => 'BreadcrumbList', 'itemListElement' => $list);
	}

	/**
	 * AggregateRating (014): формується лише на основі реальних відгуків сайту.
	 */
	public static function aggregateRating($rating_value, $review_count, $best_rating = 5, $worst_rating = 1) {
		if ((int)$review_count < 1) {
			return array();
		}

		return array(
			'@type'       => 'AggregateRating',
			'ratingValue' => number_format((float)$rating_value, 1, '.', ''),
			'reviewCount' => (int)$review_count,
			'bestRating'  => (string)$best_rating,
			'worstRating' => (string)$worst_rating
		);
	}

	/**
	 * Review масив для мікророзмітки (014).
	 */
	public static function reviews(array $items) {
		$reviews = array();

		foreach ($items as $item) {
			if (empty($item['author_name']) || empty($item['text'])) {
				continue;
			}

			$reviews[] = array(
				'@type'         => 'Review',
				'author'        => array(
					'@type' => 'Person',
					'name'  => trim((string)$item['author_name'])
				),
				'datePublished' => !empty($item['date_added']) ? (string)$item['date_added'] : date('Y-m-d'),
				'reviewBody'    => trim(strip_tags((string)$item['text'])),
				'reviewRating'  => array(
					'@type'       => 'Rating',
					'ratingValue' => (string)(isset($item['rating']) ? (int)$item['rating'] : 5),
					'bestRating'  => '5',
					'worstRating' => '1'
				)
			);
		}

		return $reviews;
	}

	/**
	 * Article JSON-LD (013, блог): мікророзмітка статті з автором, датою та видавцем.
	 */
	public static function article(array $article, $url = '', $image = '', $publisher_name = 'Крістал', $publisher_logo = '') {
		$headline = !empty($article['title']) ? trim(strip_tags((string)$article['title'])) : '';
		if ($headline === '') {
			return array();
		}

		$data = array(
			'@context'         => 'https://schema.org',
			'@type'            => 'Article',
			'headline'         => $headline,
			'description'      => !empty($article['summary']) ? trim(strip_tags((string)$article['summary'])) : '',
			'url'              => (string)$url,
			'image'            => (string)$image,
			'datePublished'    => !empty($article['date_added']) ? (string)$article['date_added'] : date('Y-m-d'),
			'dateModified'     => !empty($article['date_modified']) ? (string)$article['date_modified'] : (!empty($article['date_added']) ? (string)$article['date_added'] : date('Y-m-d')),
			'author'           => array(
				'@type' => 'Person',
				'name'  => !empty($article['author']) ? trim((string)$article['author']) : $publisher_name
			),
			'publisher'        => array(
				'@type' => 'Organization',
				'name'  => $publisher_name,
				'logo'  => !empty($publisher_logo) ? array(
					'@type' => 'ImageObject',
					'url'   => $publisher_logo
				) : null
			),
			'mainEntityOfPage' => array(
				'@type' => 'WebPage',
				'@id'   => (string)$url
			)
		);

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
