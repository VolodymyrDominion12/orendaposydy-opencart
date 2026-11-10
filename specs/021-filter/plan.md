# 021 — План реалізації

Специфікація: `spec.md` (Approved 2026-11-10: «погоджую» → пропозиції агента 1–6).

## Підхід
**Дані — ядро.** Групи й значення — `oc_filter_group*`, `oc_filter*`; призначення товарам — `oc_product_filter` (поле «Фільтри» у формі товару ядра).
Власне — лише SEO-сторінки (`kristal_filter_page`), відбір, лічильники, вигляд, адмінка масового призначення й заповнення.

**Чому не `filter_filter` ядра:** `getProducts()` ядра робить `pf.filter_id IN (…)` — АБО між **усіма** значеннями, без І між групами (AC-2),
і не вміє діапазон ціни. Ядро не змінюємо (AGENTS §1), тому:
- Подія `model/catalog/product/getProducts/before` і `…/getTotalProducts/before` (лише для категорії, на якій є активний фільтр) повертають
  результат самі: id товарів сторінки → `getProduct($id)` ядра, **рівно як робить ядро** (той самий N+1 ядра, кількість запитів як без фільтра; 016 розв'яже обидва).
  Порожній результат «не повернеш» (подія бере лише непорожній) → підставляємо `filter_filter = '-1'`, і ядро повертає 0 / `[]`.
- Відбір, лічильники й межі ціни рахуються в PHP по **індексу категорії** — компактний масив `[товар → ціна, порядок, назва, значення фільтрів]` +
  довідник значень + SEO-сторінки, кеш `kristal.filter.<store>.<lang>.<category>`. Промах кешу — 3 запити (товари з `GROUP_CONCAT` значень,
  довідник значень, SEO-сторінки), повтор — 0. Перебір масиву на 1000 товарів × 5 груп — < 5 мс; SQL з `HAVING` для лічильників кожного значення
  дав би запит на групу. (Уточнено в spec, «Нефункціональні».)
- Набір товарів — **як у ядра**: `product_to_category.category_id = X` (без підкатегорій, ядро в категорії `filter_sub_category` не ставить), увімкнені,
  `date_available <= NOW()`, магазин. Інакше лічильник розходився б зі списком.

**Адреса — параметр ядра `filter`.** Ядро вже протягує `filter` в усі свої посилання (сортування, пагінація, ліміт, «Показати ще»), тож вибір не губиться
без переписування цих посилань. Значення — `kolir-bilyi_material-porcelyana_tsina-10-40` (роздільник `_`: його не кодує `rawurlencode`, слаги — лише `a-z0-9-`).
Слаг значення = слаг групи + `-` + слаг назви (`\Kristal\Slug`, КМУ-2010); збіг у групі → `-<filter_id>`. Порядок токенів — канонічний (групи, потім значення
за `sort_order`), ціна — останньою. Уточнено в spec AC-7 (було `?f=…&price=…`).

**Без JS** форма шле `fv[]=…&pmin=&pmax=` → сервер 302 на канонічну адресу. Значення фільтрів — ще й посилання (`rel="nofollow"`, крім тих, що ведуть на SEO-сторінку):
без JS один клік — один перехід. **З JS:** десктоп — `fetch` форми (фінальна адреса після 302 = `r.url`), заміна блоку результатів і колонки, `history.pushState`;
мобільний — `…&kf=json` → `{total, url}` для «Показати N товарів», перехід за `url` після «Показати».

**SEO-сторінка `/posud/tarilky/bili`.** `startup/seo_url` (змінений, `core-keep.txt`) на невідомому останньому сегменті ставить `route=error/not_found`,
але `path` з попередніх сегментів уже заповнено. Подія `controller/error/not_found/before` знаходить сторінку за (`category_id`, keyword) і **підміняє `$route`
на `product/category`** (роутер передає маршрут за посиланням) + `filter` сторінки. Ключ унікальний у межах категорії (у `oc_seo_url` не пишемо: там ключ глобальний).
Посилання ядра на сторінки 2+ (`…/tarilky?filter=kolir-bilyi&page=2`) переписуються у view-події на `…/tarilky/bili?page=2`; пряма адреса з `filter` = комбінації SEO-сторінки → 301.

**Мета.** `title`/`description`/`canonical` — подія `view/common/header/before` (дані шапки вже зібрані). `noindex` — прапорець `kristal_noindex` у config,
який читає `ControllerExtensionKristalTheme::page()` (одна умова). Canonical фільтрованої — категорія без параметрів; SEO-сторінки — на себе (`?page=N` з 2-ї).

**Одна форма на обидва вигляди.** Шторка `k-sheet` (макет) на ≥ 1024 px стилями стає бічною колонкою — у DOM одна форма, без дублікатів `id`.

## Файли
| Файл | Новий / зміна | Що |
|---|---|---|
| `src/system/library/kristal/filter.php` | новий | чисті функції: `parse()`, `canonical()`, `slugs()`, `select()`, `counts()`, `bounds()`, `sort()`, `visibleGroups()`, `splitValues()`, `bucket()` |
| `src/system/library/kristal/slug.php` | з 022 | той самий файл (`git checkout feature/022-import -- …`), при злитті конфлікту немає |
| `src/system/library/kristal/jsonld.php` | зміна | `breadcrumbs($items)` |
| `tests/lib/filter_test.php`, `slug_test.php`, `jsonld_test.php` | новий / з 022 / зміна | тести |
| `src/catalog/model/extension/kristal/filter.php` | новий | `getIndex($category_id)` (кеш), `getPage($category_id, $keyword)` |
| `src/catalog/controller/extension/kristal/filter.php` | новий | події: `before`, `page`, `products`, `total`, `view`, `header` |
| `src/catalog/language/uk-ua/extension/kristal/catalog.php` | зміна | тексти `kf_*` (файл уже завантажено на категорії — без зайвого запиту `oc_translation`) |
| `src/catalog/view/theme/kristal/template/product/category.twig` | зміна | колонка/шторка, «Фільтри N», вибране плашками, порожній стан |
| `src/catalog/view/theme/kristal/js/kristal-filter.js` | новий | ≤ 6 КБ, лише на категоріях із фільтрами (`defer`) |
| `src/catalog/view/theme/kristal/js/kristal.js` | зміна | «Показати ще» — елементи шукаються під час кліку (після заміни блоку результатів) |
| `src/catalog/view/theme/kristal/stylesheet/kristal.css` | зміна | `.k-catalog`, `.k-fpanel`, `.k-fgroup`, `.k-check`, `.k-range`, `.k-sheet` з макета |
| `src/catalog/controller/extension/kristal/theme.php` | зміна | `noindex` за прапорцем `kristal_noindex` |
| `src/admin/controller/extension/module/kristal_filter.php` | новий | «Модулі → Крістал: фільтри»: SEO-сторінки, масове призначення, заповнення з атрибутів (перегляд → застосувати → скасувати) |
| `src/admin/model/extension/kristal/filter.php` | новий | сторінки (CRUD), товари категорії × групи, запис призначень пакетом, план/запис/відкат заповнення |
| `src/admin/language/uk-ua/extension/module/kristal_filter.php`, `src/admin/view/template/extension/module/kristal_filter{,_page,_assign}.twig` | новий | тексти, сторінка модуля, форма SEO-сторінки, таблиця призначення |
| `db/migrations/0014_kristal_filter.{up,down}.sql` | новий | таблиця, події |
| `tests/smoke/urls.txt`, `tests/mobile/pages.txt` | зміна | категорія з фільтром, SEO-сторінка, JSON |
| `AGENTS.md`, `specs/BACKLOG.md` | зміна | §3: фільтри; статус |

Номер міграції `0014`: `0012` — гілка 017, `0013` — гілка 022 (обидві ще не в `main`).

## Події (міграція 0014)
| Код | Тригер | Дія | Навіщо |
|---|---|---|---|
| `kristal_filter` | `catalog/controller/product/category/before` | `extension/kristal/filter/before` | розбір адреси, 301/302, JSON `kf=json`, стан у registry |
| `kristal_filter` | `catalog/controller/error/not_found/before` | `extension/kristal/filter/page` | SEO-сторінка → `product/category` |
| `kristal_filter` | `catalog/model/catalog/product/getProducts/before` | `extension/kristal/filter/products` | сторінка відфільтрованих товарів |
| `kristal_filter` | `catalog/model/catalog/product/getTotalProducts/before` | `extension/kristal/filter/total` | кількість |
| `kristal_filter` | `catalog/view/product/category/before` | `extension/kristal/filter/view` | групи, лічильники, плашки, SEO-сторінка (h1, текст, крихти), посилання сторінок 2+ |
| `kristal_filter` | `catalog/view/common/header/before` | `extension/kristal/filter/header` | title, description, canonical, noindex |
| `kristal_filter_flush` | `admin/model/catalog/product/{add,edit,delete}Product/after`, `admin/model/catalog/filter/{add,edit,delete}Filter/after` | `extension/kristal/cache/flushMenu` | скинути `kristal.*` (індекси фільтрів) |

## Міграції БД
| Версія | Що | down |
|---|---|---|
| `0014_kristal_filter` | `kristal_filter_page`, події `kristal_filter`, `kristal_filter_flush` | DROP таблиці, видалити події |

```
kristal_filter_page
  filter_page_id INT(11) AUTO_INCREMENT PK
  category_id    INT(11) NOT NULL
  filter_ids     VARCHAR(64) ascii NOT NULL  — відсортовані id через кому: '12' або '12,40' (1–2 значення, питання 6)
  keyword        VARCHAR(64) ascii NOT NULL  — останній сегмент адреси, a-z0-9-
  h1, title      VARCHAR(255), description VARCHAR(255), text MEDIUMTEXT
  status         TINYINT(1) NOT NULL DEFAULT 1
  date_modified  DATETIME NOT NULL
  UNIQUE uq_category_keyword (category_id, keyword)   — пошук сторінки за адресою; категорія — лівий префікс для списку сторінок категорії
  UNIQUE uq_category_filters (category_id, filter_ids) — одна комбінація — одна сторінка (AC-11)
```
Одна мова (uk-ua) — поля без `language_id`; друга мова — окрема фіча (план §7, фаза 6).

## Запити та індекси
| Запит | Де | Індекс | Очікуваний EXPLAIN |
|---|---|---|---|
| товари категорії + `GROUP_CONCAT(pf.filter_id)` | `getIndex`, промах кешу | `product_to_category.category_id` → `product` PK → `product_description` PK → `product_to_store` PK → `product_filter` PK | `ref` по `category_id`, решта `eq_ref`/`ref` |
| значення фільтрів за id (`IN`) з назвами груп | `getIndex` | `filter` PK, `filter_description` PK, `filter_group(_description)` PK | `range`/`eq_ref` |
| SEO-сторінки категорії | `getIndex` | `uq_category_keyword` (префікс `category_id`) | `ref` |
| товари категорії × значення (адмінка) | масове призначення | ті самі | `ref` |
| атрибути 500–504 з текстом (заповнення) | адмінка | `product_attribute` PK `(product_id, attribute_id, language_id)` | разовий, без бюджету |

EXPLAIN (2026-11-10): товари категорії — `p2c ref category_id`, решта `eq_ref`/`Using index`, але **`Using filesort`** — групування `GROUP BY p.product_id`
по рядках з індексу `category_id` (навіть з `ORDER BY NULL`); рядків — товари однієї категорії, лише на промах кешу → прийнято.
Довідник значень — `f range PRIMARY`, `Using temporary; Using filesort` через `ORDER BY` назв груп/значень, `filter_group(_description)` — 5 рядків (BNL) →
прийнято (крихітні таблиці, промах кешу). SEO-сторінки — `ref uq_category_keyword`, без зауважень.

## Ризики
| Ризик | Що робимо |
|---|---|
| Модуль/інша сторінка викликає `getProducts` з тим самим `filter_category_id` | подія спрацьовує лише в межах запиту, де `before` категорії поставив стан, і лише для `filter_category_id` = категорія |
| Порядок «за ціною» у фільтрі ≠ ядру (ядро враховує акції/знижки CASE-виразом) | сортуємо за `p.price` — це ціна/добу на картці; акцій на оренду немає |
| Порядок назв (`LCASE` MySQL vs PHP) для «і/ї/є» | `mb_strtolower` + `strcmp`; розбіжність лише в порядку однакових за сортуванням |
| Кеш застаріває (зміна товару без адмінки — 022, міграції) | події скидання + `Cache_key::flush` у 022; TTL ядра 1 год; `date_available` — у межах години |
| Ключ SEO-сторінки збігся з ЧПУ підкатегорії | адмінка не дає зберегти ключ, зайнятий у `oc_seo_url` |

## Відкат
`make migrate-down V=0014` — прибирає таблицю й події; категорія повертається до поточного вигляду (шаблон без даних фільтра показує сітку як зараз).
Значення фільтрів ядра й призначення лишаються (дані ядра); заповнення з атрибутів скасовується кнопкою в модулі.

## Чек-лист схеми (`docs/agents/db-schema-checklist.md`)
- [x] У плані описано таблиці, індекси й запити.
- [x] Групи/значення/призначення — таблиці ядра; власна лише `kristal_filter_page` (у ядрі немає).
- [x] Ядрові таблиці не змінюються (рядки в `oc_event`).
- [ ] `make migrate`, `db-check`, `db-schema-diff`, `db-explain`, `migrate-down` + `migrate`, `db-schema-snapshot` — у `tasks.md` → «Приймання».
