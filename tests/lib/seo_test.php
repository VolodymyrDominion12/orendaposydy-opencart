<?php
use Kristal\Seo;

test('Seo::renderTemplate: підстановка змінних та очищення від пробілів', function () {
	$tpl = '{name} у Львові — оренда від {min_price} ₴ | {store_name}';
	$vars = array(
		'name' => 'Тарілки',
		'min_price' => '15',
		'store_name' => 'Крістал'
	);

	$res = Seo::renderTemplate($tpl, $vars);
	assert_same('Тарілки у Львові — оренда від 15 ₴ | Крістал', $res);
});

test('Seo::renderTemplate: порожній шаблон повертає порожній рядок', function () {
	assert_same('', Seo::renderTemplate('', array('name' => 'test')));
});

test('Seo::isNoindexRoute: блокує службові сторінки і дозволяє вітрину', function () {
	assert_true(Seo::isNoindexRoute('checkout/cart'));
	assert_true(Seo::isNoindexRoute('checkout/order'));
	assert_true(Seo::isNoindexRoute('extension/kristal/search'));
	assert_true(Seo::isNoindexRoute('account/login'));
	assert_true(Seo::isNoindexRoute('error/not_found'));

	assert_false(Seo::isNoindexRoute('common/home'));
	assert_false(Seo::isNoindexRoute('product/category'));
	assert_false(Seo::isNoindexRoute('product/product'));
	assert_false(Seo::isNoindexRoute('information/information'));
});

test('Seo::cleanCanonical: видаляє UTM та трекінгові параметри, зберігаючи шлях', function () {
	$url = 'https://orendaposudu.com/posud/tarilky?utm_source=google&utm_medium=cpc&gclid=123';
	$clean = Seo::cleanCanonical($url);
	assert_same('https://orendaposudu.com/posud/tarilky', $clean);

	$url_with_page = 'https://orendaposudu.com/posud/tarilky?page=2&utm_source=fb';
	$clean_page = Seo::cleanCanonical($url_with_page);
	assert_same('https://orendaposudu.com/posud/tarilky?page=2', $clean_page);
});

test('Seo::buildSitemapXml: формує валідний sitemap з тегами loc, lastmod, changefreq, priority', function () {
	$urls = array(
		array(
			'loc' => 'https://orendaposudu.com/',
			'lastmod' => '2026-11-10 12:00:00',
			'changefreq' => 'daily',
			'priority' => '1.0'
		),
		array(
			'loc' => 'https://orendaposudu.com/posud',
			'lastmod' => '2026-11-09',
			'changefreq' => 'weekly',
			'priority' => '0.8'
		)
	);

	$xml = Seo::buildSitemapXml($urls);

	assert_true(strpos($xml, '<?xml version="1.0" encoding="UTF-8"?>') === 0);
	assert_true(strpos($xml, '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">') !== false);
	assert_true(strpos($xml, '<loc>https://orendaposudu.com/</loc>') !== false);
	assert_true(strpos($xml, '<lastmod>2026-11-10</lastmod>') !== false);
	assert_true(strpos($xml, '<changefreq>daily</changefreq>') !== false);
	assert_true(strpos($xml, '<priority>1.0</priority>') !== false);
});
