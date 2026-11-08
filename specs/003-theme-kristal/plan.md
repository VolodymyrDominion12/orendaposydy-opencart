# 003 — План реалізації

Посилання: `spec.md`. Погоджено 2026-11-08 («пропозиції агента» з відкритих питань 1–6). Розділ «Відхилення від чернетки» внизу —
що змінилось під час реалізації і чому.

## Підхід
Тема вмикається штатно: `theme_default_directory = kristal` (OpenCart шукає `catalog/view/theme/kristal/template/<route>.twig`,
а якщо шаблону немає — бере `default/`). Нової теми-розширення не пишемо. Дані для шапки й футера (NAP, меню, лічильник кошика)
додає подія `catalog/view/common/header/before` / `footer/before` → контролер `extension/kristal/theme`, тому шаблони не залежать
від правок ядра. Меню будується **одним** запитом (усі категорії з `top`/`status` + `category_description` + `category_to_store`),
збирається в дерево в PHP і кешується (`kristal.menu.<store>.<lang>`); кеш скидають події адмінки на додавання/зміну/видалення категорії.
CSS і JS переносяться з `design/assets/k-design.{css,js}` (вже на токенах брендбука) з розбиттям: каркас + компоненти — у тему,
стилі сторінок 01–06 — лишаються в `design/` до своїх фіч. Відкинуто: дочірня тема від `sauco` (тягне jQuery/Swiper і її N+1),
окремий модуль-налаштування теми (усе, що потрібно, вже є в `kristal_core`).

## Файли
| Файл | Новий / зміна | Що |
|---|---|---|
| `src/catalog/view/theme/kristal/template/common/header.twig` | новий | `<head>`, topbar, липка шапка, мегаменю, шторка `#menu`, SVG-спрайт іконок |
| `.../template/common/footer.twig` | новий | футер (4 колонки), карта за кліком, нижня панель `k-tabbar`, `<script defer>` |
| `.../template/error/not_found.twig` | новий | 404 (AC-10) |
| `.../template/information/information.twig` | новий | типографіка `k-prose`, крихти (AC-11) |
| `.../template/common/success.twig` | новий | «Дякуємо» (AC-12) |
| `.../template/kristal/styleguide.twig` + `catalog/controller/extension/kristal/styleguide.php` | новий | вітрина компонентів, лише якщо `config_maintenance` або локальне середовище (AC-13) |
| `.../stylesheet/kristal.css` | новий | токени (копія `docs/brandbook/tokens.css` без `@import`), `@font-face`, каркас, компоненти; ≤ 40 КБ |
| `.../js/kristal.js` | новий | шторка (фокус, Esc, блок прокрутки), мегаменю з клавіатури, карта за кліком; ванільний, ≤ 8 КБ |
| `.../fonts/*.woff2` | новий | Forum 400, Manrope 400/700 (або змінний), JetBrains Mono 500 — кирилиця+латиниця, ≤ 120 КБ разом |
| `.../image/emblem-96.webp`, `emblem-192.webp` | новий | логотип 44×44 @1x/@2x з `docs/brandbook/assets` |
| `src/catalog/controller/extension/kristal/theme.php` | новий | `header(&$route, &$data)`, `footer(&$route, &$data)`; NAP з `\Kristal\Nap`, меню з моделі, лічильник позицій |
| `src/catalog/model/extension/kristal/menu.php` | новий | `getTree()` — один запит + кеш |
| `src/catalog/language/uk-ua/extension/kristal/theme.php` | новий | усі тексти шапки/футера/панелі/404 |
| `src/admin/controller/extension/kristal/cache.php` | новий | `flushMenu()` для подій адмінки → `\Kristal\Cache_key::flush` |
| `src/catalog/controller/common/{header,footer,home,cart}.php` | **повернення до 3.0.4.1** | питання 1; прибрано з `core-keep.txt` |
| `src/catalog/controller/checkout/cart.php`, `catalog/view/javascript/common.js` | лишаються зміненими | `core-keep.txt`: кошик рендерить `checkout/order` (→ 010), getURLVar на ЧПУ (→ 011) |
| `src/system/library/kristal/theme.php` + `tests/lib/theme_test.php` | новий | `menuTree`, `hoursText`, `slug`, `icon` — чисті функції з тестом |
| `src/system/library/kristal/cache_key.php` | зміна | `Cache_key::MENU`, `menu($store, $lang)` |
| `tools/test-smoke.sh` | виправлення | 0 `h1` на сторінці обривав скрипт (`grep` + `pipefail`) |
| `tests/smoke/urls.txt`, `tests/mobile/pages.txt` | зміна | 404, інформаційна, «Дякуємо» — без `allow` |
| `AGENTS.md` §3, `docs/agents/mobile.md` | зміна | як користуватись макросами теми, де CSS |

Ядро не змінюється (крім повернення до оригіналу — питання 1). Механізми:
| Механізм | Ціль | Навіщо |
|---|---|---|
| Подія `kristal_theme_header` | `catalog/view/common/header/before` → `extension/kristal/theme/header` | NAP, меню, лічильник у шаблон |
| Подія `kristal_theme_footer` | `catalog/view/common/footer/before` → `extension/kristal/theme/footer` | NAP, колонки футера, рік |
| Події `kristal_menu_flush` (×3) | `admin/model/catalog/category/{add,edit,delete}Category/after` → `extension/kristal/cache/flushMenu` | AC-4: меню без ручного скидання |
| Налаштування | `theme_default_directory = kristal` (адмінка) | перемикання / відкат (AC-1) |

## Міграції БД
| Версія | Що | down |
|---|---|---|
| `0005_kristal_theme_events` | `INSERT … oc_event` 9 рядків (7 кодів) з кодами `kristal_theme_*`, `kristal_menu_flush` (ідемпотентно: спершу `DELETE WHERE code IN (…)`) | `DELETE FROM oc_event WHERE code IN (…)` |

Схема не змінюється (лише рядки в `oc_event`) → `make db-schema-diff` має бути порожнім; `make db-check` без нових зауважень.

## Запити та індекси
| Де викликається | Запит (скорочено) | Індекс | EXPLAIN (очікується) |
|---|---|---|---|
| `model/extension/kristal/menu::getTree` (лише при холодному кеші) | `SELECT c.category_id, c.parent_id, c.sort_order, cd.name FROM oc_category c JOIN oc_category_description cd ON (cd.category_id=c.category_id AND cd.language_id=?) JOIN oc_category_to_store c2s ON (c2s.category_id=c.category_id AND c2s.store_id=?) WHERE c.status=1 AND (c.parent_id=0 AND c.top=1 OR c.parent_id>0) ORDER BY c.parent_id, c.sort_order, cd.name` | PK `category_description`, PK `category_to_store`; `oc_category` — < 100 рядків, `ALL` допустимий | ✔ `c` ALL 52 рядки + `Using temporary; Using filesort`; `cd`, `c2s` — eq_ref. Допустимо: таблиця < 1000 рядків, запит лише на холодному кеші (раз на годину або після зміни категорії) |
| посилання меню | `$this->url->link('product/category', 'path=…')` | — | **до 011** кожне посилання = запит `oc_seo_url` ядра; тому в кеш кладемо **готові URL**, а не id → з теплим кешем 0 запитів на меню |

| `extension/kristal/theme::cartPositions` (кожна сторінка) | `SELECT COUNT(*) FROM oc_cart WHERE api_id=? AND customer_id=? AND session_id=?` | `cart_id` (api_id, customer_id, session_id, …) | ✔ ref, rows 1, Using index |
| `extension/kristal/theme::footer` (кожна сторінка) | `getInformation(config_account_id)` — посилання на політику | PK | за PK |

`cart->getProducts()` не використовуємо: він робить запит на кожну позицію.

## Кешування
- `kristal.menu.<store_id>.<language_id>` — дерево з готовими `href`. Скидається: події адмінки на категорію, збереження «Крістал: основне»
  (уже скидає `kristal.*`), `make clear-cache`. TTL — стандартний `cache_expire` (3600 с).
- NAP — `kristal.nap` (019).

## Вплив на швидкість і мобільний бюджет
- Сторінки: усі (шапка/футер). Власних запитів з теплим кешем: 0–1 (NAP і меню з кешу) — AC-15.
- Ресурси на сторінці `kristal`: CSS ≤ 40 КБ, JS ≤ 8 КБ, шрифти ≤ 120 КБ (preload лише Manrope 400), логотип ~9 КБ WebP. jQuery, Bootstrap, Swiper,
  Font Awesome `sauco` — не підключаються (зараз ≈ 370–395 КБ JS). Очікуємо TBT < 150 мс, запитів ≤ 15.
- Сторінки без шаблону `kristal` (категорія/товар до 005): тимчасово jQuery + `default`-JS (питання 2) → у `pages.txt` лишаються `allow` з номером 005.
- 360 px: шапка 56 px (бургер, логотип, дзвінок, кошик), панель 64 px + safe-area, без горизонтального скролу.

## Ризики і відкат
| Ризик | Ймовірність | Що робимо |
|---|---|---|
| Повернення ядрових файлів ламає `sauco` (питання 1) | висока, очікувано | 003+ не деплоїться на прод окремо; ціль `make deploy` перевіряє гілку; запуск — через staging (025) |
| Шаблони `default` без Bootstrap-стилів виглядають зламано | висока до 005 | питання 2: тимчасовий compat (jQuery + мінімальна сітка) лише на цих маршрутах |
| Шрифти не влазять у 120 КБ | середня | змінний Manrope + субсет; або Manrope 400/700 без 500 |
| Кеш меню не скидається при масовому імпорті (022) | низька зараз | 022 викликає `Cache_key::flush`; записати в її spec |
| Подія не спрацювала після `migrate` (кеш подій) | низька | `make clear-cache`; перевірка в T-кроці |

Як відкотити: адмінка → тема `sauco`; `make migrate-down V=0005`; `git revert` комітів 003 (повертає змінені файли ядра); `make clear-cache && make refresh-mods`.

## Відхилення від чернетки (2026-11-08)
- **Макросів немає.** Twig в OpenCart 3.0.4.1 рендерить через `ArrayLoader` — `include`/`import`/`extends` не працюють. SVG-спрайт вбудовано в `header.twig`,
  компоненти — HTML-зразками у вітрині `extension/kristal/styleguide` (AC-13). Записано в `AGENTS.md` §3.
- **Автоекранування Twig вимкнене** в OpenCart 3 — у `AGENTS.md` §9 було написано протилежне; виправлено.
- **Compat** реалізовано подією `view/*/after` (заглушка в `<head>` заповнюється, коли вже відомо, чий шаблон у сторінки) — header рендериться раніше за сторінку.
- **`checkout/cart.php` і `common.js` не повертались** до 3.0.4.1: без першого кошик падає (немає `checkout/checkout`), другий потрібен default-JS на ЧПУ.
- **Меню і кошик ядра вимкнено подіями** (`skip`): ванільний `common/menu` робить N+1 по категоріях, `common/cart` рахує підсумки — тема їх не виводить.
- **`sauco` після повернення ядра працює** (HTTP 200, без PHP-помилок), лише без даних, які давали правки ядра (меню, телефони) — відкат перемикачем теми можливий.
- **Шрифти** — по одному WOFF2 на родину через `text=` Google Fonts (кирилиця+латиниця+₴ №«»…), 94 КБ. У Forum і JetBrains Mono немає «₴» → у стек додано Manrope.
