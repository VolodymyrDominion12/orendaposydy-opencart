# 018 — Задачі

Кожен крок ≤ ~1 год. Відмічай `- [x]` одразу після перевірки. **[людина]** — крок виконує людина (агент без доступу до терміналу/інтернету).

## Підготовка
- [x] **T0.** Lint під 7.3 + 8.3, Dockerfile без ionCube, `vendor-src/` у `.gitignore` — *перевірка:* `bash -n` скриптів OK; `make build && make php-version` → немає ionCube (AC-1) **[людина]**.
- [x] **T1. [людина]** ~~`opencart-3.0.4.1.zip`~~ ✔; ще `opencart-3.0.3.2.zip` у `vendor-src/`; гілка `git switch -c feature/018-platform-upgrade` — *перевірка:* `ls vendor-src/`.
- [ ] **T2. [людина]** Зафіксувати «до»: `make db-profile URL=/ > specs/018-platform-upgrade/profile-before.txt` (+ `/posud/tarilky`, одна картка), `make test-smoke` — *перевірка:* файли є, smoke зелений.

## Реалізація
- [x] **T3a.** Аналіз пакета 3.0.4.1: схема, upgrade-скрипти, налаштування, події, мови, Twig/vendor, сторонні залишки — *перевірка:* знахідки в `plan.md` → «Знахідки аналізу».
- [x] **T4.** `tools/core-upgrade.sh` (report / apply / verify / package / prod-remove / rollback) + цілі `make core-*` — *перевірка:* `bash -n` OK; пісочниця агента: report класифікує 18 тестових файлів (KEEP/REMOVE/REVIEW), знаходить ручну правку ядра й `spaceless`; apply → verify = «ядро = 3.0.4.1, vendor на місці»; package — ZIP 12 МБ з `storage_kozak/vendor/autoload.php`, без config/install; rollback повертає 3.0.3.2, правку й tweak, зображення не чіпає.
- [x] **T5a.** Міграція `0002_core_3041` (`sort_order DEFAULT 0` + `sms_alert`) — *перевірка:* статична звірка з `db/schema.sql` і дампом.
- [x] **T5b. [людина]** `make migrate-down V=0003 && make migrate-down V=0002 && make migrate` (відкат — лише у зворотному порядку; закриває й відкат 0003 з T6c); `make migrate-status` — 0001–0003 застосовані; `make db-check` — без нових зауважень. ✔ 2026-11-06 21:58: відкат 0003 → 0002 і повторне застосування пройшли; `migrate-status` — 0001–0003 застосовані.
- [x] **T3b-1.** Перший звіт (без 3.0.3.2) розібрано: знайдено оформлення `sauco` (`checkout/order` + `simple_order`), ручну правку `seo_url.php`, зміни `header/footer/product/category` під тему, вимкнені перейменуванням контролери, сміття в кеші Twig. Скрипт доповнено: `core-keep.txt`, правила для файлів з «_», `*.php_original`, `admin/index1.php`; перевірка мовних маршрутів — за кодом 3.0.4.1; Twig-скан без кешу; `apply` без 3.0.3.2 відмовляється. Пісочниця: header-правку збережено, `checkout.php` не повернуто, `order`/`simple_order` на місці, verify OK, rollback OK.
- [x] **T3b-2.** Звіт з офіційним 3.0.3.2 розібрано (41 ручна правка ядра, 23 навмисно вимкнені файли, 952 до видалення, 6 REVIEW). Рішення — у «Замітки»; закладено в скрипт (`TAKE_NEW_CORE`, правила KEEP для перекладів, потрібних ядру, і зображень адмінки).
- [x] **T3b. [людина]** ~~`opencart-3.0.3.2.zip` у `vendor-src/`~~ ✔ → `make core-report` → надіслати агенту `specs/018-platform-upgrade/core-report.md` (розділи 1–3: ручні правки ядра, Twig 3, REVIEW) і `core-keep.txt`. Агент розбирає кожен пункт.
- [ ] **T6. [людина]** після розбору звіту: `make core-apply APPLY=1 && make migrate && make clear-cache-all && make refresh-mods && make core-verify` — *перевірка:* «ядро = 3.0.4.1, vendor на місці»; адмінка → версія 3.0.4.1 (AC-2).
- [x] **T6b.** Smoke після `core-apply` (людина, 20:59): 20 сторінок — 200 без PHP-помилок; падіння лише через «заглушку шаблону» з `config_script_after_body` (AddThis) → міграція `0003_remove_addthis` (бекап у `oc_kristal_setting_backup`, `down` повертає значення). Попередження «немає canonical» на `/` і `/oplata` — існуючий стан, → 011.
- [x] **T6c. [людина]** `make migrate && make clear-cache && make test-smoke` — *перевірка:* усі рядки OK; `make migrate-down V=0003 && make migrate` без помилок. Smoke ✔ (21:32): 23/23 OK, 2 попередження «немає canonical» на `/` і `/oplata` (існуючий стан → 011). Відкат 0003 ✔ (разом з T5b); smoke після повторного застосування — 23/23 OK (21:58).
- [x] **T7.** Оновити `AGENTS.md`, `README.md`, `docs/agents/testing.md` (3.0.4.1, lint 7.3 + 8.3) — *перевірка:* `grep -rn "3.0.3.2"` лише в історичних місцях. Зроблено 2026-11-06: + розділ «Twig 3» в `AGENTS.md` §3, пункти про `storage_kozak/vendor/` і `core-keep.txt` у README, підказки `make lint` у `make/quality.mk`. `grep` — 3.0.3.2 лишився тільки в `specs/018-*`, `make/quality.mk` (назва переходу 3.0.3.2 → 3.0.4.1) і README (стан проду до деплою).

## Перевірки (DoD) — [людина]
- [x] `make lint ALL=1` — 7.3 і 8.3 без помилок (AC-8): 2026-11-06 — «PHP-файлів для перевірки немає» (власного коду `kristal_*` ще немає; перевірка реально запрацює з 019/003)
- [x] `make db-check` — без нових зауважень. 21:33: 2 нові `id_not_indexed` у службових таблицях відкату (`kristal_setting_backup.store_id`, `kristal_mock_backup.entity_id`) — розібрано в `plan.md` → «db-check: свідомо прийняті», індекс не потрібен → прийнято `make db-check UPDATE=1`, 21:58 — «Нових зауважень немає», baseline 306 рядків (закомітити `db/db-check.baseline.tsv`)
- [x] `make db-schema-diff` = міграція 0002; потім `make db-schema-snapshot` (AC-3): знімок `db/schema.sql` уже містить 0002 (`oc_event.sort_order DEFAULT 0`) і службову таблицю 0003; 21:58 — «Схема збігається зі знімком»
- [ ] `make db-profile` до → після (/, /posud/tarilky, картка): 
- [x] `make test-smoke` — усі OK (AC-4): 23/23, 2 попередження canonical (→ 011)
- [ ] `make test-mobile` — не гірше стартового рівня
- [x] `make logs-php` — без Fatal/Warning/Notice за прохід smoke (21:23 і 21:32: лише access-лог, коди 200/404 як очікується)
- [ ] Тестове замовлення локально → Mailpit + Telegram (AC-5); Fondy тест (AC-6)
- [ ] Відкат локально (AC-10): `make migrate-down V=0003 && make migrate-down V=0002` → `make core-rollback BK=backups/core-018-20261106-205707.tar.gz APPLY=1` → `make clear-cache-all && make refresh-mods` → `make test-smoke` (3.0.3.2, без PHP-помилок; заглушка AddThis очікувана) → назад: `make core-apply APPLY=1 && make migrate && make clear-cache-all && make refresh-mods && make core-verify && make test-smoke` → `git status --short src` порожній

## Приймання
| AC | Як перевірити | Результат |
|---|---|---|
| AC-1 | `make php-version` | |
| AC-2 | адмінка → футер; `make core-diff` проти 3.0.4.1 = 0 відмінностей ядра | |
| AC-3 | `make db-schema-diff` | ✔ 2026-11-06 21:58 — збігається зі знімком (0002 + 0003) |
| AC-4 | `make test-smoke`, `make logs-php` | ✔ 2026-11-06 21:32 — 23/23 OK, логи чисті |
| AC-5 | замовлення → адмінка, Mailpit, Telegram | |
| AC-6 | оформлення з Fondy, тестовий режим | |
| AC-7 | `SELECT * FROM oc_event WHERE code='sms_alert'` → 0; файли зі списку відсутні | |
| AC-8 | `make lint ALL=1` | ✔ 2026-11-06 — нашого PHP-коду поки немає |
| AC-9 | прод: smoke, версія, PHP 7.3.33, замовлення «ТЕСТ 018» | |
| AC-10 | відкат локально (послідовність — у «Перевірки (DoD)») | |

## Замітки
### Рішення по ручних правках ядра (2026-11-06, звіт з 3.0.3.2)
Для кожного файла порівняно «розмір ручної правки» і «наскільки файл змінився в ядрі 3.0.3.2 → 3.0.4.1».
- **Беремо нове ядро (7):** `admin/index.php` (константа THEME_VERSION), `admin/controller/common/header.php` (назва магазину замість лого), `footer.php` (версія теми), `column_left.php` (перестановка меню, нових маршрутів немає), `dashboard.php` (лише пробіли), `admin/view/template/common/header.twig` (лого; **стара шапка підключає jquery-2.1.1, якого в 3.0.4.1 немає → адмінка впала б**), `admin/view/stylesheet/stylesheet.css` (клас `.d-none`; наслідок — у формі товару стануть видимі кілька прихованих полів, косметика).
- **Лишаємо старими (34), до 003/010/011:** форма й модель товару в адмінці (поля `sauco`: `description_excerpt`, `description_add`), налаштування (`config_custom_css`, `config_script_head/before_body/after_body`, `config_description` — нова форма стерла б їх при збереженні), замовлення в адмінці (`sale/order` + 4 шаблони), доставка/оплата (ядро не змінювалось), контролери вітрини `common/header|footer|home|cart`, `checkout/cart`, `product/product|category`, модулі `banner|category|featured`, `catalog/model/catalog/product.php`, `startup/seo_url.php`, `common.js`, `system/config/install.php`. Бібліотеки адмінки в 3.0.4.1 ті самі (Bootstrap 3, Font Awesome, Summernote, CodeMirror) — старі форми сумісні; Twig-скан — чисто.
- **Втрачені виправлення ядра в збережених файлах:** найбільші — `product/product.php` (88 рядків змін ядра), `sale/order_info.twig` (780), `setting/*` (≈530), `catalog/model/catalog/product.php` (16). Прийнятно тимчасово; повертаються з темою/модулями.
- **Навмисно вимкнені (23):** кроки стандартного оформлення, пошук, контакти, мапа сайту, порівняння, акції, мова/валюта, колонки, maintenance — не повертаємо (поведінка сайту як зараз). Відсутній пошук і сторінка контактів → 003/012.
- **REVIEW → KEEP:** 5 перекладів, які завантажує ядро 3.0.4.1, хоча `en-gb` для них у пакеті немає; `admin/view/image/payment/1.png`.
- Скрипт `apply` видаляє лише файли з `core-remove.txt`; REVIEW-файли не чіпає. Будь-який рядок `core-remove.txt` можна прибрати, щоб файл залишився.
- Інвентаризація 2026-11-06: в `oc_modification` 0 записів; сторонні розширення в `oc_extension` — `payment/oplata` (Fondy), `module/notifications_in_telegram`; нестандартна подія — лише `sms_alert` (мертва); зашифрованих ionCube файлів немає; ~40 осиротілих мовних файлів у `catalog/language/uk-ua/`.
