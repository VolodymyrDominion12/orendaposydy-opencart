# 017 — Задачі

Гілка `feature/017-security`. Позначки: **[агент]** — робить агент локально; **[людина]** — дія на проді або в адмінці.

## Кроки
- [x] **T0a. [агент, з дозволу людини]** `/.well-known.zip` (копія сайту з конфігами) → `~/kristal-trash/20261109-leak/` — *перевірка:* GET → 404 ✓ (2026-11-09).
- [ ] **T0b. [людина] ТЕРМІНОВО** cPanel → MySQL Databases → змінити пароль користувача БД сайту → той самий пароль у бойових `config.php` і `admin/config.php` (`DB_PASSWORD`, File Manager → Edit) → сайт і адмінка відкриваються. Після цього — видалити `~/kristal-trash/20261109-leak/`.
- [x] **T1. [агент]** `src/.htaccess`: блок `kristal:prod` (дзеркала → 301, http → 301, `.well-known` без редиректу) + заголовки безпеки; архіви/копії → 403 (AC-15); `localize-htaccess.sh` пропускає блок — *перевірка:* `make localize-htaccess` нічого не змінює; `curl -H 'Host: www.orendaposudu.com' localhost:8090/posud?x=1` → 301 на `https://orendaposudu.com/posud?x=1`; `curl -I localhost:8090/` — 4 заголовки, без `X-Powered-By`.
- [x] **T2. [агент]** `\Kristal\Cookie` + `tests/lib/cookie_test.php` — *перевірка:* `make test-lib T=cookie` зелений.
- [x] **T3. [агент]** Контролери `extension/kristal/security` (вітрина, адмінка) + міграція `0012_kristal_security` — *перевірка:* `make migrate`; `curl -I localhost:8090/` → рівно один `Set-Cookie: OCSESSID=…; HttpOnly; SameSite=Lax`; адмінка: вхід, товар, модулі працюють; `make migrate-down V=0012 && make migrate` без помилок.
- [x] **T4. [агент]** Прибрати `src/install/`, `src/index1.php`, `src/index.svg` з репозиторію — *перевірка:* `/install/`, `/index1.php` → 404 локально; smoke зелений.
- [x] **T5. [агент]** `REMOTE_ADMIN_DIR`: мапінг у `ftp_url/ftp_abs`, `package-release.sh`, `.env.example`; `make deploy HTACCESS=1` — *перевірка:* `make deploy FILES=admin/controller/extension/kristal/security.php` (dry-run) і функція `remote_rel` у тесті з різними значеннями.
- [x] **T6. [агент]** `tools/prod-security.sh` (`status`, `cleanup`, `rename-admin [--undo]`, `retire-online`, `restore`) з dry-run за замовчуванням + make-цілі `sec-*` — *перевірка:* `make sec-status` (лише читання) показує поточний стан проду; dry-run кожної команди друкує план без змін.
- [x] **T7. [агент]** Бекап: `tools/server/kristal-backup.sh`, `tools/backup.sh` (`install`, `pull`), make-цілі, `docs/04-backup-restore.md` — *перевірка:* скрипт прогнано в контейнері на локальній базі й копії `src/` → є `db/*.sql.gz`, `files/*.tar.gz`, ротація лишає 14/4; `make backup-pull` на локальному каталозі.
- [x] **T8. [агент]** `tools/test-security.sh` + `make test-security`, крок у `make verify` — *перевірка:* локально все OK; `BASE=https://orendaposudu.com` показує поточні FAIL проду (очікувано до T10–T13).
- [x] **T9. [агент]** Документація: `AGENTS.md` (§3, §9, §11), `docs/03-deploy.md`, `README.md` (основний домен), `BACKLOG.md`.
- [ ] **T10. [людина]** Прод, крок 1–5 «Порядку на проді» з `plan.md`: бекап бази → `make sec-cleanup APPLY=1` → SQL 0012 → `make deploy-apply` → `.htaccess` → `make test-security BASE=https://orendaposudu.com`.
- [ ] **T11. [людина]** `make sec-rename-admin APPLY=1` → адресу в менеджер паролів → вхід, «Оновити» на панелі стану.
- [ ] **T12. [людина]** `make sec-retire-online APPLY=1`; через тиждень без скарг — видалити `~/kristal-trash/` у File Manager.
- [ ] **T13. [людина]** `make backup-install` → рядок cron у cPanel → наступного дня `make backup-pull && make import` — сайт локально відкривається (AC-13), записати дату тут.
- [ ] **T14. [людина]** Через тиждень після T10: HSTS `max-age=31536000` (рядок у `src/.htaccess`, `make deploy-apply FILES=.htaccess HTACCESS=1`).
- [ ] **T15. [людина]** Тестова оплата Fondy на проді після T10 (повернення з оплати → «Дякуємо», кошик порожній).

## Приймання
- [x] `make lint` — 7.3 і 8.3 OK (3 PHP-файли)
- [x] `make test-lib` — 65 OK, 0 FAIL на 7.3 і 7.4 (нові: `cookie_test`, 8 тестів)
- [x] `make db-check` — без нових зауважень
- [x] `make db-schema-diff` — порожній (лише рядки в `event`)
- [x] `make db-profile` до → після: `/` 75 → 75 запитів (6.8 → 6.3 мс); `/posud/tarilky` 171 → 171 (перевищення бюджету відоме з 005 → 011/016)
- [x] `make test-smoke` — 28 OK, 0 FAIL
- [x] `make test-security` (локально) — 30 OK, 0 FAIL; на проді до T10: 11 OK / 18 FAIL (очікувано)
- [x] `make test-mobile` — усі 8 сторінок у бюджеті
- [x] `make logs-php` без Notice/Warning — 0 нових записів; адмінка (вхід, панель, товари, редагування, модифікатори, менеджер файлів) — 200 без помилок
- [ ] AC-1…AC-3, AC-4…AC-7, AC-8…AC-11 на проді — `make test-security BASE=https://orendaposudu.com` після T10–T11 — **[людина]**
- [ ] AC-12, AC-13 — T13 — **[людина]**

## Замітки
- 2026-11-09: `SameSite=None` замість `Lax` (AC-11 уточнено в spec): повернення з Fondy — POST з іншого домену.
- 2026-11-09: файли в бекапі — щотижня, а не щодня (AC-12 уточнено): квота хостингу; архів локальної копії — 142 МБ.
- 2026-11-09: `.well-known` у правилі 301 — через `THE_REQUEST`: після внутрішнього перезапису на `index.php` правила проходять удруге.
- 2026-11-09: подвійний `Set-Cookie` (ядро + наш) не лишається: `\Kristal\Cookie::apply()` збирає `headers_list()`, `header_remove()` і віддає один.
- Перевірено `tools/server/kristal-backup.sh` у контейнері `web` (локальна база + `src/`): дамп із «Dump completed», tar без кешу/сесій, ротація на KEEP 3/2, тижневий пропуск, невірний пароль → код 1 без напівфайлів.
- Перевірено dry-run на проді (лише читання): `make sec-status`, `make sec-cleanup`, `make sec-rename-admin` (3 рядки конфігу), `make sec-retire-online` (бойові конфіги на стару теку не посилаються), `make deploy` (зупиняється на `install/`).
