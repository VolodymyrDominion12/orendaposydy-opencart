# 007 — Задачі («Крістал: комплекти», `kristal_kit`)

## Реалізація
- [x] **T1. Міграція БД 0018.** Створити `db/migrations/0018_kristal_kit.up.sql` та `.down.sql` (таблиці `oc_kristal_kit`, `oc_kristal_kit_item` зі складеними індексами `idx_event_tier`, `idx_product_id`, початкові дані 3 комплектів для весілля, SEO URL `vesillya`, подія меню). Застосувати міграцію, перевірити відкат та оновити знімок схеми `db/schema.sql`. — *перевірка:* `make migrate && make db-check && make migrate-down V=0018 && make migrate` (виконано, знімок синхронізовано).
- [x] **T2. Модель каталогу `catalog/model/extension/kristal/kit.php`.** Методи `getKitsByEventType($event_type)`, `getKit($kit_id)`, `calculateKitItems($kit_id, $guests)`. — *перевірка:* перевірка динамічного обчислення ціни на гостя з товарів (95 ₴, 139 ₴, 227 ₴).
- [x] **T3. Контролер каталогу `catalog/controller/extension/kristal/kit.php` та локалізація.** Маршрути `extension/kristal/kit/event` (сторінка весілля), `extension/kristal/kit/add` (AJAX додавання комплекту в кошик). — *перевірка:* відкриття сторінки `/vesillya` (200), тестування AJAX `add` (10 позицій додано до кошика).
- [x] **T4. Шаблон сторінки події та клієнтський JS:**
  - `src/catalog/view/theme/kristal/template/extension/kristal/event.twig`: секції Hero, Комплекти (`#sets`), Додаткові послуги, Галерея, Відгуки, FAQ, Форма ліда (`#lead`).
  - `src/catalog/view/theme/kristal/js/kristal-kit.js`: перемикання гостей та миттєвий перерахунок, AJAX додавання в кошик з індикацією.
  - `src/catalog/view/theme/kristal/stylesheet/kristal.css`: стилі для карток комплектів, перемикача гостей, фактів, сіток макету `04-event.html`. — *перевірка:* мобільний аудит 360px зелений (0 overflow, 0 tap_small).
- [x] **T5. Адмінка «Крістал: комплекти»:**
  - `src/admin/model/extension/kristal/kit.php`: вибірка, збереження, оновлення та видалення комплектів.
  - `src/admin/controller/extension/kristal/kit.php`: список `index()`, форма `form()`, автокомпліт пошуку товарів `autocomplete()`, меню `menu()`.
  - `src/admin/view/template/extension/kristal/kit_list.twig`, `kit_form.twig`.
  - Мовний файл `src/admin/language/uk-ua/extension/kristal/kit.php`. — *перевірка:* надано права адміністратора, меню та форма працюють.
- [x] **T6. Тести та якість:** `make lint`, `make test-lib`, `make test-smoke`, `make test-mobile`, `make verify`.

## Перевірки (DoD)
- [x] `make lint` — PHP 7.3 + 8.3 OK (14 файлів)
- [x] `make db-check` — чистий
- [x] `make db-schema-diff` / `make db-schema-snapshot` — знімок актуальний
- [x] `make db-profile URL=/vesillya` — 85 запитів (≤ 100), 7.6 мс (≤ 50 мс)
- [x] `make test-smoke` — сторінка `/vesillya` віддає 200 (38 тестів OK)
- [x] `make test-mobile` — 0 overflow, tap_small = 0 на всіх 12 сторінках
- [x] `make logs-php` — без помилок та попереджень

## Приймання
| AC | Як перевірено | Результат |
|---|---|---|
| AC-1 (БД комплектів) | Міграція 0018, перевірка таблиць та індексів | Створено `oc_kristal_kit`, `oc_kristal_kit_item` (OK) |
| AC-2 (Розрахунок вартості) | Перевірка розрахунку на 50, 100, 200 гостей | Динамічний розрахунок із цін каталогу без дублювання цін (OK) |
| AC-3 (Віджет на вітрині) | Перемикання гостей у віджеті без reload | Радіокнопки 50/100/200 миттєво оновлюють суми на картках (OK) |
| AC-4 (Пакетний кошик) | Додавання комплекту в кошик в 1 клік, перевірка рядків у `/order` | AJAX-додавання пакетно наповнює кошик 10 позиціями (OK) |
| AC-5 (Сторінка /vesillya) | Відкриття `/vesillya`, всі блоки за макетом 04-event.html | 200 OK, повна відповідність макету (OK) |
| AC-6 (Адмінка) | Список і редактор комплектів у розділі `extension/kristal/kit` | Пункт меню «Каталог → Комплекти для подій», редактор товарів з автокомплітом (OK) |
