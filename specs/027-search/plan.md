# 027 — План реалізації

Специфікація: `spec.md` (Approved 2026-11-09).

## Підхід
Власний словниковий індекс замість `LIKE '%…%'` по `product_description` (повний перебір, заборонено AGENTS §5) і замість FULLTEXT
(InnoDB не індексує слова < 3 символів — `27`, `см`; апострофи й префікси кирилицею поводяться непередбачувано; на хостингу не налаштувати `ft_min_token_size`).
Таблиця `kristal_search_word (word, type, item_id)` з PK `(word, type, item_id)`: кожне слово назви/артикулу — рядок; запит «біла тарі» →
`word LIKE 'біла%' OR word LIKE 'тарі%'` — діапазони по PK, `GROUP BY item_id HAVING` «знайдено всі слова запиту». Статус/магазин/дата перевіряються JOIN-ом у момент пошуку,
тож індекс не залежить від увімкнення товару.

Нормалізація, слова, розкладка, синоніми, ранжування — чисті функції `Kristal\Search` (тести в `tests/lib/search_test.php`), спільні для вітрини й адмінки.
Категорії шукаються в PHP по кешованому меню теми (003) — 0 запитів. Індекс оновлюють події адмінки (товар/категорія); повна перебудова — кнопкою в «Крістал: пошук»
і при встановленні модуля (після масового імпорту 022 — теж).

Сторінка результатів — власний маршрут `extension/kristal/search` (ЧПУ `/poshuk`), а не ядровий `product/search` (вимкнений, `core-keep.txt`; його запит —
`LIKE '%…%'` по назві й тегах). Картки — `extension/kristal/catalog/cards` (005) з готовими посиланнями, «Показати ще» і пагінація — як у категорії (той самий JS).

## Файли
| Файл | Новий / зміна | Що |
|---|---|---|
| `src/system/library/kristal/search.php` | новий | `normalize()`, `words()`, `tokens()` (+ відкидання останнього голосного для слів ≥ 5 літер), `layout()` (EN→UK розкладка), `synonyms()` (розбір списку), `variants()`, `rank()`, `likeEscape()` |
| `tests/lib/search_test.php` | новий | тести бібліотеки (AC-3, AC-4, AC-5) |
| `src/catalog/model/extension/kristal/search.php` | новий | `find($q)` — пошук з кешем, синонімами, повтором у розкладці; `log($q)`; `matchCategories()` по меню |
| `src/catalog/controller/extension/kristal/search.php` | новий | `index()` — сторінка результатів; `suggest()` — JSON підказок з лімітом частоти |
| `src/catalog/language/uk-ua/extension/kristal/search.php` | новий | тексти сторінки й підказок |
| `src/catalog/view/theme/kristal/template/extension/kristal/search.twig` | новий | сторінка результатів / «нічого не знайдено» |
| `src/catalog/view/theme/kristal/js/kristal-search.js` | новий | підказки: затримка 250 мс, `fetch` з `AbortController`, listbox, ↑/↓/Enter/Esc, виділення збігу через текстові вузли (без `innerHTML` даних) |
| `src/catalog/view/theme/kristal/js/kristal.js` | зміна | відкриття/закриття панелі пошуку, ліниве підключення `kristal-search.js` при першому відкритті/фокусі |
| `src/catalog/view/theme/kristal/stylesheet/kristal.css` | зміна | `.k-search` (панель, список, пункт), сторінка результатів |
| `src/catalog/view/theme/kristal/template/common/header.twig` | зміна | лупа в шапці (без JS — посилання на `/poshuk`), панель пошуку, поле в шторці меню |
| `src/catalog/controller/extension/kristal/theme.php` | зміна | `k_search_*` (адреса з кешу, без запиту на кожній сторінці), `extension/kristal/search` у `$noindex` |
| `src/catalog/controller/extension/kristal/catalog.php` | зміна | `cards()` приймає й `['ids' => …, 'hrefs' => …]` — без `url->link()` (запит `oc_seo_url`) на кожну картку |
| `src/catalog/language/uk-ua/extension/kristal/theme.php` | зміна | `k_search*` |
| `src/admin/controller/extension/module/kristal_search.php` | новий | «Модулі → Крістал: пошук»: синоніми, стан індексу, «Перебудувати індекс», журнал «не знайдено» + «Очистити»; `install()` будує індекс |
| `src/admin/model/extension/kristal/search.php` | новий | `indexProduct()`, `indexCategory()`, `deleteItem()`, `reindexAll()`, `stats()`, `getLog()`, `clearLog()` |
| `src/admin/controller/extension/kristal/search.php` | новий | обробники подій адмінки (товар/категорія → індекс + скидання `kristal.*`) |
| `src/admin/language/uk-ua/extension/module/kristal_search.php` | новий | тексти модуля |
| `src/admin/view/template/extension/module/kristal_search.twig` | новий | форма модуля |
| `db/migrations/0010_kristal_search.{up,down}.sql` | новий | таблиці, події, ЧПУ `poshuk` |
| `db/migrations/0011_mock_search.{up,down}.sql` | новий | мок-синоніми (`module_kristal_search_synonyms`) |
| `tests/smoke/urls.txt`, `tests/mobile/pages.txt` | зміна | `/poshuk?q=…` (є результати / немає), підказки JSON |
| `AGENTS.md` | зміна | §3: пошук — `Kristal\Search`, індекс, перебудова після імпорту |

Ядро OpenCart не змінюється.
| Механізм | Ціль | Навіщо |
|---|---|---|
| Подія | `admin/model/catalog/product/{add,edit}Product/after` | переіндексувати товар (`addProduct` — id у `$output`) |
| Подія | `admin/model/catalog/product/deleteProduct/after` | прибрати з індексу |
| Подія | `admin/model/catalog/category/{add,edit,delete}Category/after` | категорія в індексі (для 021/022; на вітрині категорії йдуть з меню) |
| Запис `oc_seo_url` | `poshuk` → `extension/kristal/search` | ЧПУ через наявний `startup/seo_url` (він уже вміє `route` → keyword) |

`copyProduct` подія не потрібна: копія створюється вимкненою, а увімкнення — це `editProduct`.

## Міграції БД
| Версія | Що | down |
|---|---|---|
| `0010_kristal_search` | `kristal_search_word`, `kristal_search_log`, 6 подій `kristal_search_index`, `oc_seo_url` `poshuk` для кожної мови магазину 0 (якщо ключ вільний) | DROP обох таблиць, видалити події й рядок ЧПУ |
| `0011_mock_search` | `oc_setting` `module_kristal_search_synonyms` (≈10 рядків) — лише якщо не задано | видалити, якщо значення = мок |

```
kristal_search_word
  word     VARCHAR(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin  — нормалізоване слово (нижній регістр уже в PHP; bin — щоб «і»/«ї»/«и» не зливались і LIKE 'x%' був точним префіксом)
  type     CHAR(1) ascii  — 'p' товар, 'c' категорія
  item_id  INT(11)
  PRIMARY KEY (word, type, item_id)        — пошук: діапазон word LIKE 'x%'
  KEY idx_type_item (type, item_id)        — DELETE слів одного товару при збереженні

kristal_search_log
  query    VARCHAR(64) utf8mb4_general_ci  — нормалізований запит (без IP і будь-чого про клієнта)
  hits     INT(11) NOT NULL DEFAULT 1
  last_at  DATETIME NOT NULL
  PRIMARY KEY (query)                       — INSERT … ON DUPLICATE KEY UPDATE
  KEY idx_last_at (last_at)                 — очищення > 90 днів і вибірка «за 90 днів»
```

Чек-лист `docs/agents/db-schema-checklist.md`:
- [x] У плані описано таблиці, індекси й запити.
- [x] У ядрі немає словникового індексу (`product/search` ядра — `LIKE '%…%'`).
- [x] Ядрові таблиці не змінюються (лише рядок у `oc_seo_url` і `oc_event`, `oc_setting` — дані).
- [ ] `0010_kristal_search.{up,down}.sql`, `{{PREFIX}}`, ідемпотентно (`IF NOT EXISTS`, `DELETE` перед `INSERT`, `NOT EXISTS` для ЧПУ).
- [ ] InnoDB, utf8mb4, PK, `kristal_*`; `item_id INT(11)` як `product_id` ядра; без FOREIGN KEY.
- [ ] Індекси: PK `(word, type, item_id)` — префіксний пошук; `idx_type_item` — видалення; `idx_last_at` — журнал. Ключ PK: 32×4+1+4 = 133 байти < 3072.
- [ ] `make migrate`, `make db-check`, `make db-schema-diff`, `make db-explain`, `make migrate-down V=0010 && make migrate`, `make db-schema-snapshot`.

## Запити та індекси
| Де викликається | Запит (скорочено) | Індекс | EXPLAIN type / rows |
|---|---|---|---|
| `find()` — підказки й сторінка (кеш на запит) | `SELECT m.item_id, pd.name, p.price, p.image, p.sort_order, r.unit, r.is_hit, su.keyword FROM (SELECT item_id FROM kristal_search_word WHERE type='p' AND (word LIKE 'тарі%' OR word LIKE 'біла%') GROUP BY item_id HAVING COUNT(DISTINCT CASE …) = 2 LIMIT 500) m JOIN product p … JOIN product_to_store … JOIN product_description … LEFT JOIN kristal_product_rental … LEFT JOIN seo_url su ON su.query = CONCAT('product_id=', p.product_id) …` | PK `kristal_search_word` (range); PK ядра для join; `seo_url.query` | заповнюється в T5 |
| `log()` — нуль результатів на сторінці | `INSERT … ON DUPLICATE KEY UPDATE hits = hits + 1, last_at = NOW()`; 1 з 100 — `DELETE WHERE last_at < NOW() - INTERVAL 90 DAY` | PK, `idx_last_at` | — |
| `suggest()` — промах кешу | `Kristal\Rate_limit::hit()` (019): INSERT + SELECT за PK | PK `kristal_rate_limit` | (019) |
| Адмінка: журнал | `SELECT query, hits, last_at FROM kristal_search_log WHERE last_at > NOW() - INTERVAL 90 DAY ORDER BY hits DESC LIMIT 50` | `idx_last_at` (range) + filesort по hits — таблиця мала, лише адмінка | заповнюється в T5 |
| Адмінка: індекс товару | `DELETE FROM kristal_search_word WHERE type='p' AND item_id=?`; `SELECT pd.name, p.sku …`; `INSERT … VALUES (…),(…)` | `idx_type_item` | заповнюється в T5 |
| Адмінка: повна перебудова | `TRUNCATE`; `SELECT product_id, name, sku` (усі мови) пачками; `INSERT` по 500 рядків | — | разова дія |

## Кешування
- `kristal.search.q.<store>.<lang>.<md5(нормалізований запит)>` — результат `find()`: впорядковані id, рядки для підказок (назва, ціна, фото, посилання), категорії, прапорець розкладки. Обмеження 500 id.
- `kristal.search.href.<store>.<lang>` — адреса сторінки пошуку для шапки (інакше `url->link()` = запит `oc_seo_url` на кожній сторінці).
- Скидаються разом із усім `kristal.*` (`Cache_key::flush`) — подіями адмінки на товар/категорію і збереженням «Крістал: пошук» (синоніми).
- Кеш ядра живе `cache_expire` (3600 с) — для пошуку достатньо.

## Вплив на швидкість і мобільний бюджет
- **Усі сторінки теми:** +0 запитів (адреса пошуку з кешу); HTML шапки +≈1 КБ (панель і поле в шторці); JS — +≈1 КБ у `kristal.js` (відкриття панелі й ліниве підключення).
  `kristal-search.js` (≈4 КБ) вантажиться лише після першого відкриття поля → у `make test-mobile` не потрапляє (AC-11).
- **Підказки:** новий запит — 2 (ліміт) + 1 (пошук) = 3; повтор — 0.
- **Сторінка результатів:** база шапки/футера (як `/` — ≈ 70) + пошук (1, з кешу 0) + картки (2) + 1 на пагінацію; посилання карток — з результатів пошуку, без `oc_seo_url` по одному →
  ціль ≤ 100 (категорія зараз 171 — через N+1 ядра, 011/016).
- 360 px: панель пошуку — під шапкою на всю ширину, список до 60vh з прокруткою; на ≥ 1024 — випадна під лупою, 480 px.

До (2026-11-09, після відновлення локальної бази): `/` — 75 запитів, `/posud/tarilky` — 171.

## Ризики і відкат
| Ризик | Ймовірність | Що робимо |
|---|---|---|
| Індекс порожній після прямого SQL-імпорту (мок 001, майбутній 022) — пошук нічого не знаходить | середня | `install()` модуля будує індекс; кнопка «Перебудувати»; 022 викликає `reindexAll()`; у tasks/AGENTS — крок після імпорту |
| Ключ `poshuk` уже зайнятий в `oc_seo_url` | низька | міграція вставляє лише якщо ключ вільний; без ЧПУ пошук працює за `index.php?route=…` (форма передає `route` прихованим полем) |
| Боти перебирають підказки | середня | ліміт 60/хв на IP лише для промахів кешу; відповідь — порожній JSON, не 500 |
| `utf8mb4_bin` у колонці при `general_ci` таблиці — `make db-check` | низька | колонку порівнюємо лише з нормалізованими в PHP рядками; пояснення тут |
| XSS через запит | — | `|e` у twig для всього, що прийшло з `q` (AC-10); у JS — лише `textContent` |

Як відкотити: «Модулі → Крістал: пошук» → видалити; `make migrate-down V=0011 && make migrate-down V=0010`; `git revert` комітів 027; `make clear-cache`.
