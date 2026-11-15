# 028 — Задачі (`kristal_catering`)

## Реалізація
- [x] **T1.** Створити міграцію `0028_kristal_catering.{up,down}.sql`, застосувати `make migrate`, перевірити відкат (`make migrate-down V=0028 && make migrate`), `make db-check`, `make db-explain` та `make db-schema-snapshot`.
- [x] **T2.** Реалізувати модель і контролер каталогу (`ModelExtensionKristalCatering`, `ControllerExtensionKristalCatering`), мовний файл і шаблони `catering_hub.twig` + `catering.twig`.
- [x] **T3.** Додати видимість у шапці (`header.twig` + `theme.php`), на головній (`home.twig` + `home.php`), у футері (`footer.twig`), крос-лінк на сторінках подій (`event.twig` + `kit.php`) та включити сторінки в `/sitemap.xml` (`seo.php`).
- [x] **T4.** Додати стилі в `kristal.css` (випадаюче меню, сітка напрямків, блок страв, навігація форматів) та підтримку `[data-k-catering-select]` у `kristal-lead.js`.
- [x] **T5.** Реалізувати адмінку модуля `extension/module/kristal_catering` (контролер, модель, мова, шаблон, пункт у лівому меню) + оновити `db/restore_admin_permissions.sql`.
- [x] **T6.** Додати нові URL до `tests/smoke/urls.txt` та провести повний цикл перевірок.

## Перевірки (DoD)
- [x] `make lint` — OK (PHP 7.3 + 8.3 без помилок)
- [x] `make db-check` — OK (`no_pk: 0`, `redundant_index: 0`, `not_utf8mb4: 0`, нових зауважень немає)
- [x] `make db-schema-diff` / `make db-schema-snapshot` — OK (збігається з `db/schema.sql`, 169 таблиць)
- [x] `make db-profile URL=/` до (36 / 6.9мс) → після: **36 запитів / 6.2 мс** (найповільніший 1.0 мс, 0 нових запитів на теплому кеші)
- [x] `make db-profile URL=/gotuemo` — **28 запитів / 4.7 мс** (найповільніший 0.9 мс)
- [x] `make db-profile URL=/furshetni-stravy` — **28 запитів / 4.9 мс** (найповільніший 1.0 мс)
- [x] `make test-smoke` — OK (62/62 пройшло, 0 впало)
- [x] `make test-mobile URL=/` — OK (LCP 1060 мс, CLS 0, TBT 139 мс, overflow 0)
- [x] `make test-mobile URL=/gotuemo` — OK (LCP 860 мс, CLS 0, TBT 39 мс, overflow 0)
- [x] `make test-mobile URL=/furshetni-stravy` — OK (LCP 876 мс, CLS 0, TBT 77 мс, overflow 0)
- [x] `make verify` — OK (усі 8 етапів включно з `test-security` і 13 сторінками `test-mobile` зелені)
- [x] Логи PHP / Apache без нових Notice/Warning.

## Приймання
| AC | Як перевірено | Результат |
|---|---|---|
| AC-1 | `make test-smoke` + `curl /sitemap.xml` | 5 URL віддають HTTP 200, 1 `<h1>`, унікальні `title`/`description`/`canonical` |
| AC-2 | Playwright `1024×800`, `1280×800` + `header.twig` | Пункт «Ми можемо для Вас приготувати» у шапці й мобільній шторці з 4 підпунктами та `/gotuemo` |
| AC-3 | Playwright перевірка `/` | Секція `.k-catering-home` з 4 картками напрямків |
| AC-4 | Перевірка `/furshetni-stravy` та інших 3 міні-лендінгів | Hero, перемикач форматів, 3 комплекси («Розрахунок за запитом»), страви, оренда посуду, FAQ JSON-LD, форма ліда |
| AC-5 | Playwright клік `[data-k-catering-select]` на `/furshetni-stravy` | Відкривається `#k-lead-modal`, заголовок комплексу й коментар підставлено |
| AC-6 | Перевірка `footer.twig`, `/vesillya`, `/sitemap.xml` | 4-та колонка футера, банер на сторінках подій, 5 URL у sitemap |
| AC-7 | Playwright перевірка адмінки `/kristal_admin/` (`extension/module/kristal_catering`) | Пункт у меню «Каталог», 5 вкладок, 12 комплексів, 14 груп страв, 12 FAQ, без помилок |
| AC-8 | `make verify` + `make db-profile` | Усі перевірки пройдені в межах бюджетів |
