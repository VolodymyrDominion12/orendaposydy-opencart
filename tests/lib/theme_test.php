<?php
use Kristal\Theme;

$GLOBALS['__day_names'] = array('everyday' => 'Щодня', 'Mo' => 'Пн', 'Tu' => 'Вт', 'We' => 'Ср', 'Th' => 'Чт', 'Fr' => 'Пт', 'Sa' => 'Сб', 'Su' => 'Нд');

test('меню: два рівні, порядок як у запиті', function () {
	$rows = array(
		array('category_id' => 1, 'parent_id' => 0, 'name' => 'Посуд'),
		array('category_id' => 2, 'parent_id' => 0, 'name' => 'Меблі'),
		array('category_id' => 11, 'parent_id' => 1, 'name' => 'Тарілки'),
		array('category_id' => 12, 'parent_id' => 1, 'name' => 'Салатниці'),
		array('category_id' => 21, 'parent_id' => 2, 'name' => 'Стільці'),
	);
	$tree = Theme::menuTree($rows);

	assert_same(2, count($tree));
	assert_same('Посуд', $tree[0]['name']);
	assert_same(array('Тарілки', 'Салатниці'), array_column($tree[0]['children'], 'name'));
	assert_same(21, $tree[1]['children'][0]['category_id']);
});

test('меню: сироти й третій рівень відкидаються', function () {
	$rows = array(
		array('category_id' => 1, 'parent_id' => 0, 'name' => 'Посуд'),
		array('category_id' => 11, 'parent_id' => 1, 'name' => 'Тарілки'),
		array('category_id' => 111, 'parent_id' => 11, 'name' => 'Обідні'),   // 3-й рівень
		array('category_id' => 99, 'parent_id' => 50, 'name' => 'Сирота'),    // батько вимкнений / не в меню
	);
	$tree = Theme::menuTree($rows);

	assert_same(1, count($tree));
	assert_same(array('Тарілки'), array_column($tree[0]['children'], 'name'));
});

test('меню: порожній список', function () {
	assert_same(array(), Theme::menuTree(array()));
});

test('slug і іконка з URL', function () {
	assert_same('posud', Theme::slug('http://localhost:8090/posud'));
	assert_same('tarilky', Theme::slug('https://orendaposudu.com/posud/tarilky/?page=2'));
	assert_same('', Theme::slug('http://localhost/index.php?route=product/category&path=5001'));
	assert_same('plate', Theme::icon('posud'));
	assert_same('box', Theme::icon('nevidoma'));
});

test('графік: щодня', function () {
	$hours = array(array('days' => array('Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'), 'from' => '09:00', 'to' => '20:00'));
	assert_same(array('Щодня 09:00–20:00'), Theme::hoursText($hours, $GLOBALS['__day_names']));
});

test('графік: будні + вихідні + окремий день', function () {
	$hours = array(
		array('days' => array('Mo', 'Tu', 'We', 'Th', 'Fr'), 'from' => '09:00', 'to' => '18:00'),
		array('days' => array('Sa', 'Su'), 'from' => '10:00', 'to' => '16:00'),
		array('days' => array('Mo', 'We', 'Th'), 'from' => '08:00', 'to' => '09:00'),
	);
	assert_same(
		array('Пн–Пт 09:00–18:00', 'Сб, Нд 10:00–16:00', 'Пн, Ср, Чт 08:00–09:00'),
		Theme::hoursText($hours, $GLOBALS['__day_names'])
	);
});

test('графік: порядок днів нормалізується, порожній рядок пропускається', function () {
	$hours = array(
		array('days' => array('Fr', 'Mo', 'We', 'Tu', 'Th'), 'from' => '09:00', 'to' => '18:00'),
		array('days' => array('Xx'), 'from' => '09:00', 'to' => '18:00'),
	);
	assert_same(array('Пн–Пт 09:00–18:00'), Theme::hoursText($hours, $GLOBALS['__day_names']));
});
