# 001 — Задачі

Статус: код готовий; лишилось застосувати й перевірити на локальній базі (кроки з позначкою **[локально]**).

## Реалізація
- [ ] **T1. [локально]** Зафіксувати базу до змін:
      `make db-check UPDATE=1 && make db-schema-snapshot && make db-profile URL=/ > specs/001-mock-catalog/profile-before.txt`
      — *перевірка:* baseline і `db/schema.sql` є, цифри профілю записані в «Замітки».
- [x] **T2.** Генератор `db/seed/generate_mock_catalog.py` + дані `db/seed/mock_catalog_data.py` → `db/migrations/0001_mock_catalog.{up,down}.sql`; службова таблиця `kristal_mock_backup`; перевірка конфліктів SEO-ключів у SQL (зупиняє міграцію з переліком ключів) — *перевірка:* статична звірка зі схемою дампа (див. «Замітки»), 0 помилок.
- [x] **T3.** 30 категорій (11 верхніх + 19 підкатегорій, id 5001–5039) з описами, meta, SEO-текстом, `category_path`, store/layout, ЧПУ.
- [x] **T4.** Група атрибутів «Характеристики» (500) і 7 атрибутів (500–506).
- [x] **T5.** 95 товарів (id 50001–50095, `sku` MOCK-0001…0095) з описами, ціною, мін. кількістю, атрибутами, ЧПУ, прив'язкою до підкатегорії й батьківської категорії; `subtract = 0` (оренда не зменшує склад).
- [x] **T6.** 37 знижок за обсяг для 28 товарів (id 500001+).
- [x] **T7.** Старі категорії: `status = 0`, `top = 0`, попередній стан — у `kristal_mock_backup`; статуси наявності — українською (з бекапом).
- [x] **T8.** `0001_mock_catalog.down.sql`: видалення за діапазонами, відновлення з бекапу, видалення службової таблиці.
- [x] **T9.** Заглушки зображень у фірмовому стилі: `src/image/catalog/kristal/mock/*.png` (11 шт., 800×800, генератор `db/seed/make_placeholders.cjs`); виняток у `.gitignore`; захист від деплою в `tools/lib.sh`.
- [x] **T10.** Smoke-URL (`tests/smoke/urls.txt`) і сторінки мобільного аудиту (`tests/mobile/pages.txt`) під новий каталог.
- [ ] **T11. [локально]** Застосувати: `make migrate && make clear-cache` — *перевірка:* `make migrate-status` → `[x] 0001_mock_catalog`; меню на http://localhost:8090/ показує 11 нових категорій.

## Перевірки (DoD) — [локально]
- [ ] `make lint` — (PHP не змінювався, очікується «PHP-файлів для перевірки немає»)
- [ ] `make db-check` — без нових зауважень (додається лише InnoDB-таблиця `oc_kristal_mock_backup` з PK)
- [ ] `make db-schema-diff` — диф = лише `oc_kristal_mock_backup` + `oc_kristal_migration`; потім `make db-schema-snapshot`
- [ ] `make db-profile URL=/posud/tarilky` — ≤ 100 запитів, ≤ 50 мс
- [ ] `make test-smoke` — усі рядки OK
- [ ] `make test-mobile` — сторінки відкриваються; цифри sauco записати як стартовий рівень
- [ ] `make migrate-print V=0001` → помилка «мок-дані» (AC-7)
- [ ] `make migrate-down V=0001 && make migrate` — відкат і повторне застосування без помилок (AC-6)

## Приймання
| AC | Як перевірити | Результат |
|---|---|---|
| AC-1 | меню вітрини + `SELECT COUNT(*) FROM oc_category WHERE status=1 AND category_id < 5000` = 0 | статично: 11 верхніх ✔; [локально] — |
| AC-2 | відкрити `/posud/tarilky` | статично: 6 товарів, title «Оренда тарілок у Львові — від 11 грн \| Крістал» ✔; [локально] — |
| AC-3 | `SELECT p.product_id, COUNT(pa.attribute_id) FROM oc_product p LEFT JOIN oc_product_attribute pa USING(product_id) WHERE p.sku LIKE 'MOCK-%' GROUP BY 1 HAVING COUNT(pa.attribute_id) < 3` → 0 рядків | статично: мін. 3 атрибути, відшкодування в 95/95, усі з ЧПУ ✔ |
| AC-4 | картка `/stilets-chiavari-bilyi` — блок цін від 50/100 шт. | статично: 28 товарів зі знижками ✔ |
| AC-5 | адмінка → Каталог → Категорії → будь-яка мок-категорія → SEO | статично: усі 30 мають meta_title, meta_description, текст ✔ |
| AC-6 | `make migrate-down V=0001`; `SELECT category_id, status, top FROM oc_category` = як до up; `SELECT COUNT(*) FROM oc_product` = 49 | [локально] — |
| AC-7 | `make migrate-print V=0001` | перевірено на імітації ✔; [локально] — |
| AC-8 | `make db-check`, `make db-profile URL=/posud/tarilky` | [локально] — |

## Замітки
- Статична перевірка SQL (без живої БД — у середовищі розробки MariaDB недоступна): кожен INSERT звірено зі схемою з `dumps/matusuni_kozak.sql` — таблиці й колонки існують, кількість значень = кількості колонок, довжини `VARCHAR` не перевищено, усі `NOT NULL` без `DEFAULT` заповнені, PK унікальні, посилання категорія↔товар↔атрибут цілісні. 0 помилок.
- Перевірка знайшла конфлікт ЧПУ `nozhi` (зайнятий `/salati/nozhi`) → підкатегорія «Ножі» отримала `stolovi-nozhi`. SQL-перевірка в міграції ловить такі конфлікти й на живій базі.
- Після `up` старі адреси категорій (`/salati`, `/orenda-prokat-mebliv`…) → 404 до фічі 002. Реальні 49 товарів доступні за своїми URL, але не в меню.
- Профіль до/після: 
