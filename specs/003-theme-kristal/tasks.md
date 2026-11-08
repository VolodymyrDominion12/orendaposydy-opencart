# 003 — Задачі

Кожен крок ≤ ~1 год. Відмічай `- [x]` одразу після перевірки. **[людина]** — крок виконує людина.
Старт — після статусу `Approved` у `spec.md` і відповідей на відкриті питання 1–6. ✔ 2026-11-08 («роби як пропонуєш»).

## Підготовка
- [x] **T0.** ✔ 2026-11-08 гілка `feature/003-theme-kristal`, профіль «до» — `profile-before.txt`: / 319, /posud/tarilky 400, /oplata 290, 404 286 запитів.

## Реалізація
- [x] **T1.** Каркас теми: `kristal.css` (токени без `@import`, компоненти з `design/`, доповнення теми), шрифти WOFF2, емблема WebP —
      ✔ CSS 31 КБ (≤ 40), шрифти 94 КБ (≤ 120, 3 файли), hex лише в блоці токенів.
- [x] **T2.** Модель `extension/kristal/menu` + `Kristal\Theme::menuTree` + `tests/lib/theme_test.php` — ✔ `make test-lib` 7/7 (7.4 і 7.3); `make db-explain` → «Замітки».
- [x] **T3.** Контролер `extension/kristal/theme`, мовний файл, міграція `0005_kristal_theme_events` + down — ✔ `make migrate`; 9 рядків `kristal%` в `oc_event`; `make lint` OK.
- [x] **T4.** `admin/.../extension/kristal/cache::flushMenu` — ✔ CLI-перевірка в контейнері: події `add/edit/deleteCategory/after` з `oc_event` скидають `kristal.menu.0.2` (3/3). Через форму адмінки — T13.
- [x] **T5.** `common/{header,footer,home,cart}.php` → 3.0.4.1, `core-keep.txt` оновлено — ✔ `make core-verify`: «ядро = 3.0.4.1». `checkout/cart.php` і `common.js` лишились (див. plan → «Відхилення»).
- [x] **T6.** `header.twig`: верхній рядок, липка шапка, мегаменю, SVG-спрайт, «Перейти до змісту» — ✔ AC-2, AC-4, AC-9 (знімки 360/1280).
- [x] **T7.** Шторка `#menu` + `kristal.js` — ✔ Playwright: фокус на «Закрити меню», `k-lock`, Esc закриває, фокус повертається на бургер (AC-5).
- [x] **T8.** `footer.twig` + нижня панель + карта за кліком + лічильник позицій — ✔ AC-6, AC-7 (50+100 шт → «2»), AC-8 (iframe до кліку — 0).
- [x] **T9.** Вітрина компонентів `extension/kristal/styleguide` (замість макросів — Twig без `include`) — ✔ AC-13, знімок 1280.
- [x] **T10.** `error/not_found`, `information/information`, `common/success` — ✔ AC-10 (404 + `noindex`), AC-11, AC-12; рівно один `h1`.
- [x] **T11.** Compat для маршрутів без шаблону `kristal`: jQuery+Bootstrap у `<head>` подією `view/*/after`, клас `k-compat`; `checkout/order` — шаблон `sauco` —
      ✔ категорія/товар отримують jQuery; AJAX `checkout/cart/add` працює; `/order` 200; на 404 jQuery немає (AC-17). Натискання кнопки на картці в браузері — T13.
- [x] **T12.** `tests/smoke/urls.txt` (+ `/success`, `/oplata` без allow), `tests/mobile/pages.txt` (3 сторінки теми без allow), `AGENTS.md` §0, §3, §9 — ✔ `make test-smoke` 24/24.
- [ ] **T13. [людина]** Адмінка → «Розширення → Теми → Тема за замовчуванням» → каталог `kristal` (локально вже перемкнено агентом); пройти AC-1…AC-8 руками
      з реальними контактами в «Крістал: основне»; змінити категорію в адмінці → меню оновилось; «До кошика» на картці; реальний телефон (Android + iPhone): шторка, панель, `tel:`, Viber.

## Перевірки (DoD)
- [x] `make lint ALL=1` — ✔ 19 файлів, PHP 7.3 і 8.3 OK, функцій 7.4+/8 немає
- [x] `make test-lib` — ✔ 41 OK (7.4, з БД); 38 OK + 3 SKIP (7.3, без БД)
- [x] `make db-check` — ✔ «Нових зауважень немає»
- [x] `make db-schema-diff` — ✔ «Схема збігається зі знімком» (схема не змінювалась)
- [x] `make migrate-down V=0005 && make migrate` — ✔ відкат: 0 подій `kristal%`, вітрина 200; повторне застосування OK
- [x] `make db-explain` (меню, лічильник кошика) — ✔ див. «Замітки» і plan.md
- [x] `make db-profile` до → після (`profile-before.txt` / `profile-after.txt`): **/ 319 → 110, /posud/tarilky 400 → 191, /oplata 290 → 81, 404 286 → 77**; найповільніший ≤ 1.1 мс.
      /oplata і 404 — у бюджеті; / і категорія ще понад 100 через шаблони default і `oc_seo_url` (→ 004/005/011)
- [x] `make test-smoke` — ✔ 24/24, 3 попередження canonical (/, /oplata, /success → 011)
- [x] `make test-mobile` — ✔ усі 6 у бюджеті; 3 сторінки теми **без allow**: LCP 656–676 мс, TBT 14–18 мс, JS 2 КБ, CSS 8 КБ, шрифти 93 КБ, 7 запитів, 0 тач-зон < 44.
      Було (sauco, 2026-11-07): TBT ≈ 400–424 мс, JS 368–395 КБ, 18 тач-зон < 44
- [ ] Реальний телефон (Android + iPhone) — **[людина]**, T13
- [x] `make logs-php` без Notice/Warning — ✔ `system/storage/logs` без нових записів після 2026-11-07
- [x] `make verify` — ✔ усі 7 кроків OK (2026-11-08)

## Приймання
| AC | Як перевірено | Результат |
|---|---|---|
| AC-1 | `theme_default_directory` kristal ↔ sauco, curl | ✔ kristal: лише `kristal.css` + `kristal.js`; sauco: 200, без PHP-помилок, без меню/телефонів (очікувано, питання 1) |
| AC-2 | тимчасовий NAP (2 телефони, Viber, графік, Instagram, Facebook, Telegram, адреса) → HTML і знімки; NAP повернуто як було | ✔ `tel:+380…`, Viber на номер з позначкою, «Щодня 09:00–20:00», порожні поля не виводяться |
| AC-3 | збереження «Крістал: основне» скидає `kristal.*` (019) | ◐ механізм з 019 (AC-9 там); руками — T13 |
| AC-4 | 1280 px: «Каталог» → 11 категорій; події адмінки скидають кеш | ✔ знімок мегаменю; CLI-перевірка подій 3/3; через форму адмінки — T13 |
| AC-5 | Playwright 360 px | ✔ фокус, Esc, блок прокрутки, повернення фокусу; категорії розгортаються `<details>` |
| AC-6 | 360 / 1280 px, `make test-mobile` | ✔ панель є / немає; 0 тач-зон < 44; Viber лише якщо є номер з Viber |
| AC-7 | AJAX `cart/add` 50 + 100 шт | ✔ «(2)» у шапці, «2» у панелі; порожній — без лічильника |
| AC-8 | HTML футера, Playwright | ✔ «Каталог», «Клієнтам», політика (`/politika-konfidencijnosti`), © 2026; iframe до кліку — 0. Позначки оплати — лише з увімкненим Fondy (зараз вимкнено) |
| AC-9 | `grep -c '<h1'` | ✔ /oplata, 404, /success — по 1 |
| AC-10 | curl | ✔ HTTP 404, `noindex, follow`, «До каталогу» → /posud, кнопка дзвінка |
| AC-11 | /oplata 360 і 1280 | ✔ крихти, `k-prose`, overflow 0 |
| AC-12 | /success | ✔ шаблон теми, 1 `h1`, «На головну» |
| AC-13 | `index.php?route=extension/kristal/styleguide` | ✔ локально; на інших хостах і з іншою темою — 404 |
| AC-14 | `make test-mobile` | ✔ без allow |
| AC-15 | `make db-profile` + журнал запитів | ✔ свої запити з теплим кешем — 2 (лічильник кошика, політика); меню — один запит лише на холодному кеші, кількість категорій не впливає |
| AC-16 | Playwright: перший Tab | ✔ «Перейти до змісту» з видимою рамкою; масштабування не заборонене (`viewport_bad` 0) |
| AC-17 | HTML 404 / /oplata / /success | ✔ без jQuery/Bootstrap, один `kristal.js` з `defer` |

## Замітки
- `make db-explain` меню: `oc_category` ALL 52 рядки, `Using temporary; Using filesort`; `category_description`, `category_to_store` — eq_ref. Допустимо (plan.md): лише холодний кеш.
- `make db-explain` лічильника: `oc_cart` ref за `cart_id`, rows 1, Using index.
- Локально тему перемкнено на `kristal` (`theme_default_directory`). На прод 003 окремо **не деплоїти** — лише разом із 004/005/010 через staging (питання 1).
- На compat-сторінках (категорія) іконки Font Awesome видно квадратами — не розбирався, сторінки переверстує 005.
- `tools/test-smoke.sh`: сторінка без `h1` обривала скрипт (`grep` + `pipefail`) — виправлено (`|| true`).
