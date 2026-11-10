# 010 — Задачі реалізації (`kristal_checkout`)

Кожен крок ≤ ~1 год. Відмічай `- [x]` одразу після перевірки.

## Реалізація

- [x] **T1. Міграція 0016_kristal_checkout.** Створити `db/migrations/0016_kristal_checkout.up.sql` та `.down.sql` (таблиця `oc_kristal_order_rental`, реєстрація події `admin/view/sale/order_info/after`).
  - *Перевірка:* `make migrate` створив таблицю; `make db-check` OK; `make migrate-down V=0016` та повторний `make migrate` успішні; `make db-schema-snapshot` оновив `db/schema.sql`.
- [x] **T2. Модель каталогу для оренди замовлення.** Створити `src/catalog/model/extension/kristal/checkout.php` з методами збереження `saveRental($order_id, $data)` та читання `getRental($order_id)`.
  - *Перевірка:* перевірено запис та читання замовлення #941.
- [x] **T3. Контролер checkout/checkout (ліквідація 404) та оновлення посилань теми.**
  - Створити `src/catalog/controller/checkout/checkout.php` з 302-редиректом на `checkout/order`.
  - Оновити `k_cart_href` у `src/catalog/controller/extension/kristal/theme.php` на посилання `checkout/order`.
  - Додати 302-редирект зі застарілого `checkout/cart` на `checkout/order`.
  - *Перевірка:* `curl -s -I http://localhost:8090/index.php?route=checkout/checkout` віддає 302 на `/order` замість 404; `checkout/cart` віддає 302 на `/order`.
- [x] **T4. Контролер checkout/order — логіка кошика та розрахунків.**
  - Реалізувати `src/catalog/controller/checkout/order.php`:
    - `index()`: вибірка позицій кошика з розрахунком цін за порогами оренди (фіча 005 `\Kristal\Rental`), фото через `model_extension_kristal_media`, дати за замовчуванням, список хітів для порожнього кошика.
    - `update()`: AJAX-зміна кількості (POST `cart_id`, `quantity`), валідація мінімальної кількості товару, повернення JSON з оновленими сумами.
    - `remove()`: AJAX-видалення позиції з кошика (POST `cart_id`), повернення JSON.
  - Оновити мовний файл `src/catalog/language/uk-ua/checkout/order.php`.
  - *Перевірка:* зміна кількості з 20 на 100 одиниць через AJAX автоматично застосовує гуртову знижку з 14 ₴ до 12 ₴.
- [x] **T5. Шаблон кошика події та стилі теми kristal.**
  - Створити `src/catalog/view/theme/kristal/template/checkout/order.twig` на основі `design/pages/05-cart.html` (4 блоки: склад, дати й доставка, контакти, спосіб оплати + бічна панель підсумку).
  - Додати стилі кошика у `src/catalog/view/theme/kristal/stylesheet/kristal.css` за токенами бренду (жодних `k-compat`, Bootstrap чи сторонніх CSS).
  - Створити ванільний скрипт `src/catalog/view/theme/kristal/js/kristal-checkout.js` (AJAX перерахунок без перезавантаження сторінки, калькулятор діб за датами, перемикання доставки/самовивозу, показ полів юрособи).
  - *Перевірка:* `/order` відкривається у браузері без помилок консолі, без `k-compat`, усі інтерактивні елементи реагують миттєво.
- [x] **T6. Збереження замовлення та інтеграція зі сповіщеннями.**
  - Реалізувати метод `save()` у `checkout/order.php`:
    - Валідація: ім'я, телефон (`\Kristal\Phone::normalize()`), адреса (якщо обрано доставку), дати (не в минулому, `date_to >= date_from`), компанія/ЄДРПОУ (якщо увімкнено перемикач юрособи).
    - Запис замовлення у `oc_order` через `model_checkout_order->addOrder()`.
    - Запис у `oc_kristal_order_rental` через `model_extension_kristal_checkout->saveRental()`.
    - Зміна статусу на 1 («Нове замовлення») через `addOrderHistory()`.
    - Спрацьовування сповіщень `023 kristal_notify` (Telegram, Email, Webhook).
    - Очищення кошика та повернення `{ "success": true, "redirect": "/success" }`.
  - *Перевірка:* створено замовлення #941, `oc_kristal_order_rental` містить дати (11.11-13.11, 2 доби, доставка за адресою, Telegram, ФОП Тестовий, ЄДРПОУ 12345678). Лист надійшов у Mailpit.
- [x] **T7. Інтеграція онлайн-оплати Fondy.**
  - Якщо користувач обирає спосіб «Карткою онлайн»: створення замовлення та перенаправлення на шлюз `oplata` (Fondy).
  - Створення адаптованого шаблону `src/catalog/view/theme/kristal/template/extension/payment/oplata.twig` без jQuery (чиста форма перенаправлення на Fondy).
  - *Перевірка:* метод `getFondyCheckoutUrl()` формує запит із сумою 50% передоплати та підписом Fondy.
- [x] **T8. Відображення параметрів оренди в адмінці.**
  - Створити `src/admin/controller/extension/kristal/checkout.php` та модель `src/admin/model/extension/kristal/checkout.php`.
  - Подія `admin/view/sale/order_info/after` вставляє інформаційний блок «Параметри оренди» (дати, тривалість, адреса доставки, канал зв'язку, ЄДРПОУ).
  - Створити мовний файл `src/admin/language/uk-ua/extension/kristal/checkout.php`.
  - *Перевірка:* сторінка замовлення #941 в адмінці містить блок «Параметри оренди події» із датами, адресою доставки та ЄДРПОУ.
- [x] **T9. Тестування мобільної версії (360px) та smoke.**
  - Додати `/order` до `tests/smoke/urls.txt` та `tests/mobile/pages.txt`.
  - Запустити `make test-smoke` та `make test-mobile`.
  - *Перевірка:* `make test-mobile` пройшов успішно для всіх 11 сторінок (LCP 672ms, 0 overflow, 0 tap_small); `make test-smoke` 37 OK, 0 помилок.
- [x] **T10. Загальна перевірка якості (DoD) та оновлення беклогу.**
  - `make lint` (PHP 7.3 та 8.3) — зелений.
  - `make test-lib` — зелений (109 OK).
  - `make db-check` та `make db-schema-diff` — зелені.
  - `make db-profile URL=/order` — 87 запитів, 9.0 мс (бюджет ≤ 100).
  - `make verify` — зелений.
  - Оновити статус фічі 010 у `specs/BACKLOG.md` та `specs/010-checkout/spec.md`.

---

## Перевірки (DoD)
- [x] `make lint` — 14 файлів PHP 7.3 (прод) + PHP 8.3 (наперед) OK
- [x] `make test-lib` — 109 OK, 0 FAIL, 7 SKIP
- [x] `make db-check` — 0 no_pk, 0 redundant_index, 0 not_utf8mb4, нових зауважень немає
- [x] `make db-schema-diff` / `make db-schema-snapshot` — знімок актуалізовано, diff чистий
- [x] `make db-profile URL=/order` — 87 запитів (9.0 мс), найповільніший 0.90 мс (бюджет ≤ 100)
- [x] `make test-smoke` — 37 перевірок пройдено, 0 помилок
- [x] `make test-mobile` — 11 сторінок у бюджеті (LCP 672ms, CLS 0, TBT 0, 95 KB, 0 overflow)
- [x] `make logs-php` без Notice/Warning — чисто
- [x] `make verify` зелений — всі 8 перевірок пройдені

---

## Приймання
| AC | Як перевірено | Результат |
|---|---|---|
| AC-1 | Перехід на `/order` та клік на кошик у шапці, відсутність `k-compat` | Сторінка відкривається у темі kristal, клас `k-compat` відсутній |
| AC-2 | Зміна кількості кнопками + / - та видалення позиції AJAX | Кількість оновлюється без перезавантаження, діють знижки за обсяг |
| AC-3 | Порожній кошик показує підказку та хіти каталогу | При порожньому кошику відображається текст, кнопка в каталог та картки хітів |
| AC-4 | Вибір дат оренди, блокування минулих дат, авторозрахунок діб | Дати валідуються (min=сьогодні), розраховуються доби (2 доби = коеф ×1.5) |
| AC-5 | Перемикання самовивозу та доставки з полем адреси | При самовивозі поле адреси приховується, при доставці стає обов'язковим |
| AC-6 | Валідація імені, телефону E.164, вибір месенджера | Ім'я (2-64 симв), телефон нормалізується `\Kristal\Phone`, вибір каналу (Viber, Telegram, Дзвінок, Email) |
| AC-7 | Перемикач юрособи та поля компанії/ЄДРПОУ | Чекбокс відкриває поля компанії та ЄДРПОУ з валідацією 8-12 знаків |
| AC-8 | Вибір «Заявка без оплати» або «Оплата карткою онлайн Fondy» | «Заявка без оплати» реєструє замовлення зі статусом 1; Fondy генерує платіжне посилання |
| AC-9 | Збереження в `oc_order` та `oc_kristal_order_rental`, сповіщення, редирект на `/success` | Замовлення #941 збережено у двох таблицях, сповіщення надіслано в Mailpit, редирект на `/success` |
| AC-10 | Блок «Параметри оренди» в картці замовлення адмінки | Панель з датами, адресою, каналом зв'язку та ЄДРПОУ відображається у `sale/order/info` |
| AC-11 | Мобільний аудит 360px `make test-mobile` у бюджеті | 95 KB, LCP 672ms, тач-зони ≥ 44px, без горизонтального скролу |

## Замітки
- Вирішено пункт беклогу #60 (ліквідовано 404 на `checkout/checkout` через 302-редирект на `/order`).
- Вирішено пункт беклогу #71 (видалено останній залишок теми sauco з кошика, відмова від jQuery/Bootstrap compat).
