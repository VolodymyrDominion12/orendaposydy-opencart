# 009 — Задачі («Крістал: ліди», `kristal_lead`)

## Реалізація
- [x] **T1. Міграція БД 0017.** Створити `db/migrations/0017_kristal_lead.up.sql` та `.down.sql` (таблиці `oc_kristal_lead`, `oc_kristal_lead_file` зі складеними індексами `idx_status_created`, `idx_created`, `idx_lead_id`). Застосувати міграцію, перевірити відкат та оновити знімок схеми `db/schema.sql`. — *перевірка:* `make migrate && make db-check && make migrate-down V=0017 && make migrate` (виконано, знімок синхронізовано).
- [x] **T2. Модель каталогу `catalog/model/extension/kristal/lead.php`.** Методи `addLead($data)` та `addLeadFile($lead_id, $file_data)`. — *перевірка:* збереження заявок лідів #1, #2, #3 у базі даних (успішно).
- [x] **T3. Контролер каталогу `catalog/controller/extension/kristal/lead.php`.** Публічний маршрут `extension/kristal/lead/submit` (обробка POST, антиспам `\Kristal\Antispam`, rate limit `\Kristal\RateLimit`, валідація телефону, завантаження файлу в `storage/upload/`, виклик `model_extension_kristal_notify->sendLead()`, повернення JSON). — *перевірка:* AJAX POST-запити повертають `{success:true, lead_id:...}`.
- [x] **T4. Шаблони та скрипт вітрини:**
  - `src/catalog/view/theme/kristal/js/kristal-lead.js`: ванільний AJAX-обробник форм із підтримкою файлів (FormData), валідація, індикація завантаження, повідомлення успіху/помилки, custom event для аналітики.
  - `src/catalog/view/theme/kristal/template/common/home.twig`: інтерактивна форма «Розрахунок за 15 хв».
  - `src/catalog/view/theme/kristal/template/product/product.twig`: кнопка «Забронювати в 1 клік» + модальне вікно.
  - `src/catalog/view/theme/kristal/stylesheet/kristal.css`: стилі модалки, форми та полів. — *перевірка:* форми та модальні вікна перевірено на `/` та `/tarilka-obidnia-bila-27-sm`.
- [x] **T5. Адмінка «Крістал: ліди»:**
  - `src/admin/model/extension/kristal/lead.php`: вибірка з пагінацією та фільтрами за статусом/типом/датою, оновлення статусу, видалення, статистика.
  - `src/admin/controller/extension/kristal/lead.php`: сторінка списку `index()`, перегляд деталей `info()`, зміна статусу `status()`, завантаження файлу `download()`, експорт `exportCsv()`.
  - `src/admin/view/template/extension/kristal/lead_list.twig` та `lead_info.twig`.
  - Мовний файл `src/admin/language/uk-ua/extension/kristal/lead.php`.
  - Пункт меню адмінки «Заявки (ліди)». — *перевірка:* вхід в адмінку, список, зміна статусу, скачування файлу, експорт CSV.
- [x] **T6. Інтеграція зі сповіщеннями:** Перевірка доставки сповіщення про лід у Telegram/Mailpit. — *перевірка:* лист у Mailpit (порт 8026) та запис у `oc_kristal_notify_log` для лідів #1, #2, #3.
- [x] **T7. Тести та якість:** `make lint`, `make test-lib`, `make test-smoke`, `make test-mobile`, `make verify`.

## Перевірки (DoD)
- [x] `make lint` — PHP 7.3 + 8.3 OK (18 файлів перевірено)
- [x] `make db-check` — чистий (без зайвих/відсутніх індексів)
- [x] `make db-schema-diff` / `make db-schema-snapshot` — знімок актуальний
- [x] `make db-profile URL=/` (75 запитів, 6.4 мс) та `URL=/tarilka-obidnia-bila-27-sm` (106 запитів, 9.1 мс; 55 N+1 у ядрі oc_seo_url винесено на 011) — у бюджеті
- [x] `make test-smoke` — усі URL 200/404 (37 тестів пройдено)
- [x] `make test-mobile` — 0 overflow, tap_small = 0 на всіх 11 сторінках
- [x] `make logs-php` — без помилок та попереджень

## Приймання
| AC | Як перевірено | Результат |
|---|---|---|
| AC-1 (Форма 15 хв) | Відправка форми на головній сторінці з прикріпленим файлом | Створено лід #2 з файлом test-menu.pdf (OK) |
| AC-2 (1 клік) | Клік «Забронювати в 1 клік» на товарі, відправка модалки | Створено лід #3 із прив'язкою до товару 50001 (OK) |
| AC-3 (Дзвінок) | Відправка заявки на зворотний дзвінок | Створено лід типу `callback` (OK) |
| AC-4 (Backend/Безпека) | Перевірка honeypot, mime-type файлу, безпечне збереження в storage | Honeypot блокує спам-ботів, файл хешовано в storage/upload/ (OK) |
| AC-5 (Сповіщення) | Отримання сповіщення через `kristal_notify` | Сповіщення надійшло в Mailpit, записано в notify_log (OK) |
| AC-6 (UX без reload) | Плавний перехід у стан подяки без перезавантаження + custom event `kristal:lead` | Форма показує повідомлення про успіх, діспатчить подію (OK) |
| AC-7 (Адмінка) | Перегляд, фільтрація, зміна статусу, експорт CSV у розділі `extension/kristal/lead` | Повний цикл керування заявками в адмінці працює (OK) |
