<?php
use Kristal\Redirect;

test('Redirect::normalize: обробка слешів, регістру та URL-encoded символів', function () {
	assert_same('/', Redirect::normalize('/'));
	assert_same('/', Redirect::normalize(''));
	assert_same('/salati', Redirect::normalize('/salati/'));
	assert_same('/salati', Redirect::normalize('salati'));
	assert_same('/salati/bilij-posud', Redirect::normalize('/Salati/Bilij-Posud/'));
	assert_same('/posud/tarilky', Redirect::normalize('https://orendaposudu.com/posud/tarilky?utm_source=fb'));
	assert_same('/посуд', Redirect::normalize('/%D0%BF%D0%BE%D1%81%D1%83%D0%B4/'));
});

test('Redirect::log404: ігнорує статичні файли', function () {
	$dummy_db = new class {
		public $called = false;
		public function escape($s) { return addslashes($s); }
		public function query($sql) { $this->called = true; }
	};

	Redirect::log404($dummy_db, '/image/catalog/logo.png', '');
	assert_false($dummy_db->called, 'PNG files should not be logged');

	Redirect::log404($dummy_db, '/css/style.css.map', '');
	assert_false($dummy_db->called, 'MAP files should not be logged');
});
