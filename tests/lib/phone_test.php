<?php
use Kristal\Phone;

test('нормалізація 8 форматів до E.164', function () {
	$cases = array(
		'067 123 45 67'        => '+380671234567',
		'0671234567'           => '+380671234567',
		'+38 (067) 123-45-67'  => '+380671234567',
		'+380671234567'        => '+380671234567',
		'380671234567'         => '+380671234567',
		'38 067 123-45-67'     => '+380671234567',
		'8 067 123 45 67'      => '+380671234567',
		'(032) 245-67-89'      => '+380322456789',
	);

	foreach ($cases as $raw => $expected) {
		assert_same($expected, Phone::normalize($raw), $raw);
	}
});

test('9 цифр без коду країни', function () {
	assert_same('+380671234567', Phone::normalize('67 123 45 67'));
});

test('відмова: короткий, іноземний, сміття, порожній', function () {
	foreach (array('12345', '+48 123 456 789', '+1 202 555 0143', '067-ABC-45-67', '', '   ', '+380 01 234 56 78', '0671234567890') as $raw) {
		assert_same('', Phone::normalize($raw), export($raw));
		assert_false(Phone::isValid($raw), export($raw));
	}
});

test('display, tel, mask', function () {
	assert_same('+38 067 123 45 67', Phone::display('0671234567'));
	assert_same('tel:+380671234567', Phone::tel('+38 (067) 123-45-67'));
	assert_same('+38067*****67', Phone::mask('+380 67 123 45 67'));
	assert_same('', Phone::tel('123'));
	assert_same('***45', Phone::mask('12345'));
});
