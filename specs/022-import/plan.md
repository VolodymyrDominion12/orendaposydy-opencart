# 022 — План

Spec: `spec.md` (Approved 2026-11-09). Ядро не змінюється; нові товари створюються й видаляються моделлю ядра
`catalog/product` (`addProduct`/`deleteProduct`), тож події 005 (оренда) і 027 (індекс пошуку) спрацьовують самі.

## Шари

| Шар | Що | Файл |
|---|---|---|
| Бібліотека (чиста, з тестами) | CSV: кодування (BOM, UTF-8 / Windows-1251), роздільник (`;` `,` таб), заголовки → ключі, розбір клітинок (число з комою, так/ні, одиниця, знижки), запис CSV для Excel, екранування формул | `system/library/kristal/price_csv.php` |
| | План імпорту: зіставлення (ID → артикул), перевірки AC-5/6, диф «було → стане», нові товари, попередження AC-8, хеш плану | `system/library/kristal/price_import.php` |
| | ЧПУ з назви (транслітерація КМУ-2010, унікальність) | `system/library/kristal/slug.php` |
| Модель адмінки | Каталог одним набором запитів (товари + назви + шлях категорії + оренда + знижки), запис плану пакетами, знімок, скасування, журнал | `admin/model/extension/kristal/import.php` |
| Контролер адмінки | Сторінка модуля, вивантаження, завантаження, перегляд, застосування, скасування; пункт меню «Каталог → Прайс (імпорт)» подією | `admin/controller/extension/module/kristal_import.php` |
| Вигляд, тексти | Одна сторінка: журнал + форма; режим перегляду | `admin/view/template/extension/module/kristal_import.twig`, `admin/language/uk-ua/extension/module/kristal_import.php` |
| БД | Журнал імпортів + подія меню | міграція `0013_kristal_import` |

Номер міграції: `0013` — `0012` зайнятий міграцією 017 (`0012_kristal_security`, гілка `feature/017-security`), тож гілки зливаються в будь-якому порядку без перейменувань.

## Потік

```
Вивантажити ─GET export→ CSV (UTF-8+BOM, ;)
Завантажити ─POST upload→ перевірка (розмір, тип, читається) → файл у DIR_UPLOAD/kristal-import-<token>.csv → redirect preview&token
Перегляд    ─GET preview→ читання файлу + каталог → Price_import::plan() → таблиця змін, помилки, попередження, hash
Застосувати ─POST apply(token, hash)→ план наново; hash ≠ → «каталог змінився, перегляньте ще раз»;
              журнал: рядок status=applying + знімок → запис пакетами → status=applied → файл видалено
              виняток → відновлення зі знімка → status=failed
Скасувати   ─POST undo(id)→ лише останній applied; знімок назад, створені й досі вимкнені товари → deleteProduct
```
Повторний `apply` того ж токена: файлу вже немає → «цей перегляд уже застосовано» (AC-9). Файли старші за добу прибираються при відкритті сторінки (AC-14).

## Поля і куди пишуться

| Колонка | Ключ | Таблиця.колонка | Знімок |
|---|---|---|---|
| ID | id | ключ | — |
| Артикул | sku | `product.sku` | так |
| Ціна за добу | price | `product.price` | так |
| Мін. кількість | minimum | `product.minimum` | так |
| Увімкнено | status | `product.status` | так |
| Одиниця, Застава, Биття/втрата, Миття включено, Хіт | unit, deposit, breakage, washing, hit | `kristal_product_rental` (рядок цілком, `ON DUPLICATE KEY UPDATE`) | рядок цілком (або «не було») |
| Знижки | discounts | `product_discount` групи за замовчуванням (`config_customer_group_id`), `priority=1`, без дат | список цілком |
| Назва, Категорія | name, category | лише для нових товарів | — |

## Запити (на імпорт, не на сторінку)

| Запит | Скільки | Індекс | EXPLAIN |
|---|---|---|---|
| Товари + назва (мова адмінки) | 1 | PK `product`, PK `product_description (product_id, language_id)` | ALL по `product` — навмисно, усі товари (≤ кілька тисяч) |
| Перша категорія товару + шлях | 2 (`product_to_category`, `category_path`⋈`category_description`) | PK, `category_path` PK | ALL — усі рядки |
| Оренда | 1 | PK `kristal_product_rental` | ALL — усі |
| Знижки групи | 1 | `product_discount.product_id` (індекс ядра) | ALL по групі |
| ЧПУ (зайняті keyword) | 1 | `seo_url.keyword` | лише для нових товарів |
| Запис: `UPDATE product SET … CASE product_id …` пачками по 500, `INSERT … ON DUPLICATE` оренди пачками, `DELETE … IN (…)` + `INSERT` знижок пачками | O(рядків / 500) | PK | — |
| Нові товари | ~12 на товар (`addProduct` ядра) | — | рідкісна дія; AC-15 — для оновлень |

Вітрина: запитів не додається (імпорт пише ті самі таблиці, які читає 005).

## Схема БД

```sql
CREATE TABLE {{PREFIX}}kristal_import_log (
  import_id   INT(11) AUTO_INCREMENT PRIMARY KEY,
  created_at  DATETIME NOT NULL,
  user_id     INT(11) NOT NULL, username VARCHAR(20) NOT NULL,
  filename    VARCHAR(255) NOT NULL,
  status      VARCHAR(16) NOT NULL,      -- applying | applied | failed | undone
  rows_total, changed, created, errors   INT(11) NOT NULL DEFAULT 0,
  snapshot    MEDIUMTEXT NOT NULL,       -- JSON: {product_id: {поле: старе значення}}, created: [id]
  summary     TEXT NOT NULL              -- JSON: перші 50 помилок і попереджень (для журналу)
) InnoDB utf8mb4
```
Без вторинних індексів (уточнено після `make db-explain`): імпортів — одиниці на місяць; «останній застосований»
(`WHERE status IN (…) ORDER BY import_id DESC LIMIT 1`) і список (`ORDER BY import_id DESC LIMIT 20`) ідуть по PRIMARY
у зворотному порядку без filesort. `user_id` лише записується (хто імпортував), запитів за ним немає →
`make db-check` `id_not_indexed user_id` прийнято свідомо (`UPDATE=1`).
```sql
```
Подія: `kristal_import_menu` — `admin/view/common/column_left/before` → `extension/module/kristal_import/menu`.

### Чек-лист схеми (`docs/agents/db-schema-checklist.md`)
- [ ] Нова таблиця `kristal_*`, InnoDB, utf8mb4, PK; id `INT(11)`; без FK на ядро
- [x] Запити журналу — по PRIMARY (`import_id DESC`), без filesort; `user_id` без індексу свідомо (запитів за ним немає)
- [ ] Ідемпотентно (`IF NOT EXISTS`, `DELETE` подій перед `INSERT`), `down` прибирає таблицю й подію
- [ ] `make db-check`, `db-schema-diff` = лише ця таблиця, `db-explain`, `migrate-down/up`, `db-schema-snapshot`

## Ризики
- **MyISAM без транзакцій** → знімок у журналі до запису + автоматичне відновлення; обірваний PHP — статус `applying` і кнопка «Відновити».
- **Ліміт PHP `upload_max_filesize`/`post_max_size`** на хостингу — файл 2 МБ проходить (php.ini проду: 999M).
- **Excel міняє вигляд чисел** (`10,5` → `10,50`, `1 440`) — парсер приймає всі варіанти; дати не використовуємо.
- **Кількість у знижках ≤ мінімуму** — помилка рядка (інакше на картці 005 рядок таблиці знижок недосяжний).

## Відкат фічі
`make migrate-down V=0013` (журнал і подія меню), вимкнути/видалити модуль у «Розширення → Модулі»; дані товарів, змінені імпортами, — «Скасувати» в журналі до відкату.
