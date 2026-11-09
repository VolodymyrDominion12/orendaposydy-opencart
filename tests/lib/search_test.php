<?php
use Kristal\Search;

/** Чи знайде запит товар з такою назвою/артикулом — та сама умова, що в SQL моделі: кожне слово запиту (з варіантами) — префікс якогось слова індексу */
function __search_matches($query, $name, $sku = '', $groups = array()) {
	$words = Search::words($name . ' ' . $sku);
	$tokens = Search::tokens($query);

	if (!$tokens) {
		return false;
	}

	foreach ($tokens as $token) {
		$ok = false;

		foreach (Search::variants($token, $groups) as $variant) {
			foreach ($words as $word) {
				if (mb_strpos($word, $variant, 0, 'UTF-8') === 0) {
					$ok = true;
					break 2;
				}
			}
		}

		if (!$ok) {
			return false;
		}
	}

	return true;
}

test('normalize: регістр, апострофи, розділові знаки, цифри окремо', function () {
	assert_same('стілець кяварі білий', Search::normalize("Стілець К’яварі (БІЛИЙ)"));
	assert_same('стілець кяварі', Search::normalize("стілець к'яварі"));
	assert_same('стілець кяварі', Search::normalize('стілець кʼяварі'));
	assert_same('тарілка 27 см', Search::normalize('Тарілка, 27см!'));
	assert_same('mock 0001', Search::normalize('MOCK-0001'));
	assert_same('келих 200 мл', Search::normalize('Келих &quot;200&quot; мл'));
	assert_same('', Search::normalize('  --  '));
});

test('words: унікальні, обрізані до 32 символів', function () {
	assert_same(array('тарілка', 'біла'), Search::words('Тарілка біла тарілка'));
	assert_same(32, mb_strlen(Search::words(str_repeat('а', 40))[0], 'UTF-8'));
	assert_same(2, count(Search::words('а б в г', 2)));
});

test('tokens: множина, короткі слова, дублікати', function () {
	assert_same(array('тарілк'), Search::tokens('тарілки'));
	assert_same(array('тарілк'), Search::tokens('ТАРІЛКА'));
	assert_same(array('біла', 'тарі'), Search::tokens('біла тарі'));
	assert_same(array('тарілк'), Search::tokens('тарі тарілки'));
	assert_same(array('27', 'см', 'тарілк'), Search::tokens('27 см тарілка'));
	assert_same(6, count(Search::tokens('а б в г д е є ж')));
	assert_same(array(), Search::tokens('  '));
});

test('AC-3: «Тарілка біла обідня 27 см» знаходять усі варіанти запиту', function () {
	$name = 'Тарілка біла обідня 27 см';
	$sku = 'MOCK-0001';

	foreach (array('тарілка', 'ТАРІЛ', 'біла тарі', '27 см тарілка', 'тарілки', '  тарілка   біла ', 'MOCK-0001', 'mock 0001') as $q) {
		assert_true(__search_matches($q, $name, $sku), $q);
	}

	assert_true(__search_matches(Search::layout('nfhskrf'), $name, $sku), 'nfhskrf');
	assert_same(false, __search_matches('келих', $name, $sku));
	assert_same(false, __search_matches('тарілка чорна', $name, $sku));
});

test('AC-3: апостроф у запиті й у назві не важить', function () {
	assert_true(__search_matches("к'яварі", 'Стілець Кʼяварі білий'));
	assert_true(__search_matches('кяварі', "Стілець К'яварі білий"));
	assert_true(__search_matches('стілець к’яв', 'Стілець Кʼяварі білий'));
});

test('layout: англійська розкладка → українська', function () {
	assert_same('тарілка', Search::layout('nfhskrf'));
	assert_same('келих', Search::layout('rtkb['));
	assert_same('їжак', Search::layout('];fr'));
	assert_same('тарілка', Search::layout('NFHSKRF'));
	assert_same('', Search::layout('тарілка'));
	assert_same('', Search::layout('27'));
});

test('synonyms: розбір списку з адмінки', function () {
	$groups = Search::synonyms("келих = фужер, бокал\n\n# коментар\nшатро, намет; тент\nсамотнє\nвиделка = Вилка\r\n");
	assert_same(array(array('келих', 'фужер', 'бокал'), array('шатро', 'намет', 'тент'), array('виделка', 'вилка')), $groups);
	assert_same(array(), Search::synonyms(''));
});

test('AC-4: синоніми — «фужер» знаходить келихи, і навпаки', function () {
	$groups = Search::synonyms("келих = фужер, бокал");

	assert_true(__search_matches('фужер', 'Келих для вина 350 мл', '', $groups));
	assert_true(__search_matches('фужери', 'Келих для вина 350 мл', '', $groups));
	assert_true(__search_matches('фуж', 'Келих для вина 350 мл', '', $groups));
	assert_true(__search_matches('келих', 'Фужер кришталевий', '', $groups));
	assert_true(__search_matches('бокал вина', 'Келих для вина 350 мл', '', $groups));
	assert_same(false, __search_matches('фужер', 'Тарілка біла', '', $groups));
	assert_same(false, __search_matches('фу', 'Келих для вина', '', $groups), 'менше 3 літер — без синонімів');
});

test('AC-5: ранг — початок назви, усі слова в назві, інше', function () {
	$tokens = Search::tokens('тарілка біла');

	assert_same(0, Search::rank('Тарілка біла обідня', 'тарілка біла', $tokens));
	assert_same(1, Search::rank('Тарілка обідня біла', 'тарілка біла', $tokens));
	assert_same(1, Search::rank('Біла тарілка', 'тарілка біла', $tokens));
	assert_same(2, Search::rank('Блюдо', 'тарілка біла', $tokens));
});

test('AC-5: порядок — ранг, «Хіт», абетка (і після и, є після е)', function () {
	$rows = array(
		array('product_id' => 1, 'name' => 'Тарілка з бортиком біла', 'is_hit' => 0),
		array('product_id' => 2, 'name' => 'Біла тарілка', 'is_hit' => 1),
		array('product_id' => 3, 'name' => 'Тарілка біла обідня', 'is_hit' => 0),
		array('product_id' => 4, 'name' => 'Тарілка біла десертна', 'is_hit' => 0),
		array('product_id' => 5, 'name' => 'Біла їдальня тарілка', 'is_hit' => 0),
		array('product_id' => 6, 'name' => 'Біла иржава тарілка', 'is_hit' => 0),
	);
	$sorted = Search::sort($rows, 'тарілка біла', Search::tokens('тарілка біла'));

	assert_same(array(4, 3, 2, 6, 5, 1), array_column($sorted, 'product_id'));
	assert_same(0, $sorted[0]['rank']);
});

test('cut і likeEscape', function () {
	assert_same(64, mb_strlen(Search::cut(str_repeat('я', 100)), 'UTF-8'));
	assert_same('а б', Search::cut("  а \n  б "));
	assert_same('50\\% \\_x\\\\', Search::likeEscape('50% _x\\'));
});
