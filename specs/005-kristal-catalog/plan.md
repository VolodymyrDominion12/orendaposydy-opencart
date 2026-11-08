# 005 — План реалізації

Посилання: `spec.md`. **Чернетка** разом зі spec (варіант «пропозиції агента» з відкритих питань 1–6); після `Approved` уточнюється.

## Підхід
Шаблони `product/category.twig` і `product/product.twig` з'являються в темі `kristal` — compat 003 для цих маршрутів вимикається сам.
Контролери ядра лишаються (після повернення до 3.0.4.1 — питання 4); дані оренди додає подія `view/product/{category,product}/before`:
бере `product_id` усіх карток сторінки (список, «З цим беруть») і одним запитом дістає оренду, другим — знижки (`IN (...)`).
Адмінка: подія `admin/view/catalog/product_form/after` вставляє вкладку «Оренда» й посилання на приховані вкладки «Атрибути»/«Знижки»
(їхні панелі в HTML форми вже є), події `admin/model/catalog/product/{add,edit,delete,copy}Product/after` зберігають/видаляють рядок оренди.
Відкинуто: атрибути для застави/биття (рядок тексту, без чисел для кошика 010 і JSON-LD 011); правка шаблону форми ядра; сторонні модулі.

## Файли
| Файл | Новий / зміна | Що |
|---|---|---|
| `catalog/view/theme/kristal/template/product/category.twig` | новий | `h1`, «від N ₴», чипи, сортування, сітка `k-card`, банер, пагінація, опис |
| `catalog/view/theme/kristal/template/product/product.twig` | новий | галерея, ціна, таблиця знижок, сума, застава/биття, атрибути, умови, «З цим беруть», липка панель |
| `catalog/view/theme/kristal/stylesheet/kristal.css` | зміна | галерея, таблиця знижок, липка панель, тулбар, чипи (з `design/` 02/03) |
| `catalog/view/theme/kristal/js/kristal.js` | зміна | «−/+», мінімум, AJAX «До події» (`checkout/cart/add`), лічильники, сума й активний поріг, галерея, липка панель |
| `catalog/controller/extension/kristal/catalog.php` | новий | події `category()`, `product()`; маршрут `count` (JSON кількість позицій для лічильників) |
| `catalog/model/extension/kristal/catalog.php` | новий | `getRental(ids)`, `getDiscounts(ids)`, `getMinPrice(category_id)` (кеш) |
| `system/library/kristal/rental.php` + `tests/lib/rental_test.php` | новий | чисті функції: ціна за кількістю з порогів, формат «14 ₴»/«10,50 ₴», рядки таблиці знижок, одиниці |
| `catalog/language/uk-ua/extension/kristal/catalog.php` | новий | тексти |
| `admin/controller/extension/kristal/catalog.php` + `admin/language/uk-ua/extension/kristal/catalog.php` | новий | вкладка «Оренда» (подія view after), збереження (події model after), скидання кешу |
| `admin/model/extension/kristal/catalog.php` | новий | get/save/delete рядка оренди |
| `catalog/controller/product/{category,product}.php` | **повернення до 3.0.4.1** | питання 4; `core-keep.txt` |
| `db/migrations/0006_kristal_product_rental.*` | новий | таблиця + події + ліміт 24 (з бекапом налаштування) |
| `db/migrations/0007_mock_rental.*` | новий | мок: оренда для 95 MOCK-товарів з атрибутів 505/506, 8 «Хітів»; атрибути 505/506 — у бекап |
| `tests/smoke/urls.txt`, `tests/mobile/pages.txt` | зміна | категорія й картка без `allow` |

| Механізм | Ціль | Навіщо |
|---|---|---|
| Подія `kristal_catalog_category` | `catalog/view/product/category/before` | оренда/знижки/короткий опис для карток, «від N ₴», чипи з меню 003 (0 запитів) |
| Подія `kristal_catalog_product` | `catalog/view/product/product/before` | те саме для товару й «З цим беруть», таблиця знижок, сума |
| Подія `kristal_catalog_admin_form` | `admin/view/catalog/product_form/after` | вкладки «Оренда», «Атрибути», «Знижки» |
| Події `kristal_catalog_admin_save` | `admin/model/catalog/product/{add,edit,copy,delete}Product/after` | зберегти/скопіювати/видалити оренду, скинути `kristal.catalog.*` |

## Міграції БД
| Версія | Що | down |
|---|---|---|
| `0006_kristal_product_rental` | `CREATE TABLE {{PREFIX}}kristal_product_rental (product_id INT PK, unit VARCHAR(16) NOT NULL DEFAULT 'pcs', deposit DECIMAL(15,4) NOT NULL DEFAULT 0, breakage_price DECIMAL(15,4) NOT NULL DEFAULT 0, washing_included TINYINT(1) NOT NULL DEFAULT 0, is_hit TINYINT(1) NOT NULL DEFAULT 0, KEY idx_is_hit (is_hit))`; події; `theme_default_product_limit` 100 → 24 (старе значення — у `kristal_setting_backup`) | DROP таблиці, події, повернути ліміт |
| `0007_mock_rental` | INSERT для `sku LIKE 'MOCK-%'`: одиниця з атрибута 506, відшкодування — число з атрибута 505, застава = 2 × ціна (мок), «Хіт» — 8 товарів; атрибути 505/506 → бекап і видалення | відновити атрибути, видалити рядки оренди мок-товарів |

Чек-лист `docs/agents/db-schema-checklist.md` — у задачах (db-check, schema-diff, snapshot, explain, down/up).

## Запити та індекси
| Де | Запит (скорочено) | Індекс | EXPLAIN (очікується) |
|---|---|---|---|
| подія категорії/товару | `SELECT r.*, pd.description_excerpt FROM kristal_product_rental r RIGHT JOIN … WHERE product_id IN (…)` | PK `product_id` | range/eq_ref, rows = кількість карток |
| подія категорії/товару | `SELECT product_id, quantity, price FROM product_discount WHERE product_id IN (…) AND customer_group_id = ? AND quantity > 1 AND ((date_start = '0000-00-00' OR date_start < NOW()) AND (date_end …)) ORDER BY product_id, quantity` | `product_id` (ядро) | range |
| «від N ₴» (кеш `kristal.catalog.min.<cat>`) | `SELECT MIN(p.price) FROM product p JOIN product_to_category p2c … JOIN category_path cp … WHERE cp.path_id = ? AND p.status = 1 AND p.price > 0` | `category_path` PK, `product_to_category` PK | перевірити `make db-explain` |
| лічильник після «До події» | як у 003 (`cart_id`) | `cart_id` | ref |

## Кешування
- `kristal.catalog.min.<store>.<cat>` — мінімальна ціна категорії; скидається подіями збереження товару/категорії (весь `kristal.*`).
- Оренду й знижки сторінки не кешуємо — 2 запити за PK/індексом дешевші за інвалідацію.

## Вплив на швидкість і мобільний бюджет
- Категорія й картка більше не тягнуть jQuery, Bootstrap, Font Awesome (зараз JS 82 КБ, шрифти 168 КБ на цих сторінках) → очікуємо як сторінки 003: JS ≤ 10 КБ, шрифти 94 КБ.
- `kristal.js` росте до ~10 КБ; CSS — до ~40 КБ. Зображення мок-заглушок PNG 800×800 → у картці `resize` ядра до розмірів теми (WebP — 020).
- Запити: +2 на сторінку (оренда, знижки), +1 на холодному кеші («від»); N+1 немає. `oc_seo_url` ядра на кожне посилання лишається до 011.

## Ризики і відкат
| Ризик | Ймовірність | Що робимо |
|---|---|---|
| Вставка вкладок у HTML форми адмінки ламається після оновлення ядра | середня | вставка за стабільним маркером (`<ul class="nav nav-tabs">` / `id="tab-general"`); не знайшли — нічого не вставляємо + запис у лог |
| Повернення `product/*.php` ламає `sauco` | низька (тема вже `kristal`) | як у 003: на прод разом із темою |
| Знижки в кошику ≠ сума в картці | низька | обидва з `product_discount` ядра; перевірка AC-7 через кошик |
| Мінімум не перевіряється ядром при додаванні | висока (так у 3.0) | клієнтська перевірка + 010 перевіряє в кошику |

Відкат: `make migrate-down V=0007 && make migrate-down V=0006`, `git revert`, `make clear-cache`.
