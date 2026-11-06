# 018 — Задачі

Кожен крок ≤ ~1 год. Відмічай `- [x]` одразу після перевірки. **[людина]** — крок виконує людина (агент без доступу до терміналу/інтернету).

## Підготовка
- [x] **T0.** Lint під 7.3 + 8.3, Dockerfile без ionCube, `vendor-src/` у `.gitignore` — *перевірка:* `bash -n` скриптів OK; `make build && make php-version` → немає ionCube (AC-1) **[людина]**.
- [ ] **T1. [людина]** ~~`opencart-3.0.4.1.zip`~~ ✔; ще `opencart-3.0.3.2.zip` у `vendor-src/`; гілка `git switch -c feature/018-platform-upgrade` — *перевірка:* `ls vendor-src/`.
- [ ] **T2. [людина]** Зафіксувати «до»: `make db-profile URL=/ > specs/018-platform-upgrade/profile-before.txt` (+ `/posud/tarilky`, одна картка), `make test-smoke` — *перевірка:* файли є, smoke зелений.

## Реалізація
- [x] **T3a.** Аналіз пакета 3.0.4.1: схема, upgrade-скрипти, налаштування, події, мови, Twig/vendor, сторонні залишки — *перевірка:* знахідки в `plan.md` → «Знахідки аналізу».
- [x] **T4.** `tools/core-upgrade.sh` (report / apply / verify / package / prod-remove / rollback) + цілі `make core-*` — *перевірка:* `bash -n` OK; пісочниця агента: report класифікує 18 тестових файлів (KEEP/REMOVE/REVIEW), знаходить ручну правку ядра й `spaceless`; apply → verify = «ядро = 3.0.4.1, vendor на місці»; package — ZIP 12 МБ з `storage_kozak/vendor/autoload.php`, без config/install; rollback повертає 3.0.3.2, правку й tweak, зображення не чіпає.
- [x] **T5a.** Міграція `0002_core_3041` (`sort_order DEFAULT 0` + `sms_alert`) — *перевірка:* статична звірка з `db/schema.sql` і дампом.
- [ ] **T5b. [людина]** `make migrate && make migrate-down V=0002 && make migrate`; `make db-check` — без нових зауважень.
- [x] **T3b-1.** Перший звіт (без 3.0.3.2) розібрано: знайдено оформлення `sauco` (`checkout/order` + `simple_order`), ручну правку `seo_url.php`, зміни `header/footer/product/category` під тему, вимкнені перейменуванням контролери, сміття в кеші Twig. Скрипт доповнено: `core-keep.txt`, правила для файлів з «_», `*.php_original`, `admin/index1.php`; перевірка мовних маршрутів — за кодом 3.0.4.1; Twig-скан без кешу; `apply` без 3.0.3.2 відмовляється. Пісочниця: header-правку збережено, `checkout.php` не повернуто, `order`/`simple_order` на місці, verify OK, rollback OK.
- [ ] **T3b. [людина]** `opencart-3.0.3.2.zip` у `vendor-src/` → `make core-report` → надіслати агенту `specs/018-platform-upgrade/core-report.md` (розділи 1–3: ручні правки ядра, Twig 3, REVIEW) і `core-keep.txt`. Агент розбирає кожен пункт.
- [ ] **T6. [людина]** після розбору звіту: `make core-apply APPLY=1 && make migrate && make clear-cache-all && make refresh-mods && make core-verify` — *перевірка:* «ядро = 3.0.4.1, vendor на місці»; адмінка → версія 3.0.4.1 (AC-2).
- [ ] **T7.** Оновити `AGENTS.md`, `README.md`, `docs/agents/testing.md` (3.0.4.1, lint 7.3 + 8.3) — *перевірка:* `grep -rn "3.0.3.2"` лише в історичних місцях.

## Перевірки (DoD) — [людина]
- [ ] `make lint ALL=1` — 7.3 і 8.3 без помилок (AC-8)
- [ ] `make db-check` — без нових зауважень
- [ ] `make db-schema-diff` = міграція 0002; потім `make db-schema-snapshot` (AC-3)
- [ ] `make db-profile` до → після (/, /posud/tarilky, картка): 
- [ ] `make test-smoke` — усі OK (AC-4)
- [ ] `make test-mobile` — не гірше стартового рівня
- [ ] `make logs-php` — без Fatal/Warning/Notice за прохід smoke
- [ ] Тестове замовлення локально → Mailpit + Telegram (AC-5); Fondy тест (AC-6)
- [ ] Відкат локально: `make migrate-down V=0002` + повернення файлів (AC-10)

## Приймання
| AC | Як перевірити | Результат |
|---|---|---|
| AC-1 | `make php-version` | |
| AC-2 | адмінка → футер; `make core-diff` проти 3.0.4.1 = 0 відмінностей ядра | |
| AC-3 | `make db-schema-diff` | |
| AC-4 | `make test-smoke`, `make logs-php` | |
| AC-5 | замовлення → адмінка, Mailpit, Telegram | |
| AC-6 | оформлення з Fondy, тестовий режим | |
| AC-7 | `SELECT * FROM oc_event WHERE code='sms_alert'` → 0; файли зі списку відсутні | |
| AC-8 | `make lint ALL=1` | |
| AC-9 | прод: smoke, версія, PHP 7.3.33, замовлення «ТЕСТ 018» | |
| AC-10 | відкат локально | |

## Замітки
- Скрипт `apply` видаляє лише файли з `core-remove.txt`; REVIEW-файли не чіпає. Будь-який рядок `core-remove.txt` можна прибрати, щоб файл залишився.
- Інвентаризація 2026-11-06: в `oc_modification` 0 записів; сторонні розширення в `oc_extension` — `payment/oplata` (Fondy), `module/notifications_in_telegram`; нестандартна подія — лише `sms_alert` (мертва); зашифрованих ionCube файлів немає; ~40 осиротілих мовних файлів у `catalog/language/uk-ua/`.
