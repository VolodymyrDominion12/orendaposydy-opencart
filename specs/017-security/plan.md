# 017 — План

Spec: `spec.md` (Approved 2026-11-09). Ядро OpenCart не змінюється; OCMOD не потрібен.

## Механізми

| AC | Як | Де |
|---|---|---|
| 1–3 | `install/`, `index1.php`, `index.svg` прибираються з репозиторію (`git rm`); на проді — **переносяться** одною FTP-командою `RNFR/RNTO` у `~/kristal-trash/<дата>/` поза docroot (не рекурсивне видалення: сотні FTP-команд → хостинг блокує IP, див. `docs/03-deploy.md`). Людина видаляє смітник у File Manager, коли переконається, що все працює. `make deploy` (dry-run) і `make test-security` перевіряють, що `install/` на проді немає. | `tools/prod-security.sh cleanup`, `tools/deploy.sh` |
| 4–7 | Адмінка на проді перейменовується в `REMOTE_ADMIN_DIR` з `.env` (випадкова назва, у git не потрапляє). `tools/prod-security.sh rename-admin`: бекап бойового `admin/config.php` → у копії замінюються рівно 3 рядки (`HTTP_SERVER`, `HTTPS_SERVER`, `DIR_APPLICATION`) → показ диффу → `YES` → `RNFR admin RNTO <нова>` → заливка нового `config.php` → перевірка HTTP (нова — форма входу 200, стара — 404); не пройшло — автоматичний відкат (назад перейменувати, повернути конфіг). Локально тека лишається `src/admin/`; FTP-хелпери (`ftp_url`/`ftp_abs` у `tools/lib.sh`) самі підміняють `admin/…` → `$REMOTE_ADMIN_DIR/…`, тож `deploy`, `deploy-rollback`, бекап перед деплоєм, `ftp-rm`, `core-prod-remove` працюють без змін; `package` кладе файли адмінки в архів під новою назвою. | `tools/lib.sh`, `tools/prod-security.sh`, `tools/package-release.sh` |
| 8–9 | `src/.htaccess` стає **єдиним джерелом** для локалу й проду (бойовий = репозиторний мінус локалізація, звірено FTP 2026-11-09). Блок між `# kristal:prod BEGIN/END`: 301 з дзеркал (`www.orendaposudu.com`, `(www.)orendaposydy.com`) і з `http://orendaposudu.com` одразу на `https://orendaposudu.com%{REQUEST_URI}` (query додається сам), крім `/.well-known/`. Правила прив'язані до хостів, тому на `localhost` не спрацьовують — `tools/localize-htaccess.sh` блок пропускає. Старе правило хостингу `[R]` (302) прибирається. | `src/.htaccess`, `tools/localize-htaccess.sh` |
| 10 | `.htaccess`, `<IfModule mod_headers.c>`: `Header always set` для `X-Content-Type-Options`, `X-Frame-Options`, `Referrer-Policy`, `Strict-Transport-Security: max-age=86400` (за тиждень → `31536000`, задача в `tasks.md`); `Header always unset` + `Header unset X-Powered-By`. LiteSpeed ці директиви підтримує; якщо `X-Powered-By` лишиться — `expose_php = Off` у cPanel → MultiPHP INI Editor (людина). | `src/.htaccess` |
| 11 | Бібліотека `\Kristal\Cookie::harden(array $lines, $name, $https)` — чиста функція: з рядків `Set-Cookie:` прибирає в куки сесії атрибути `HttpOnly/Secure/SameSite` і додає правильні (HTTPS → `Secure; HttpOnly; SameSite=None`, HTTP → `HttpOnly; SameSite=Lax`); дублікати куки сесії зводить до останньої. `\Kristal\Cookie::apply()` бере `headers_list()`, робить `header_remove('Set-Cookie')` і віддає назад. Виклик — подіями `catalog/controller/*/before` і `admin/controller/*/before` (`extension/kristal/security/cookie`, один раз на запит): кука вже виставлена ядром (`startup/session` у вітрині, `framework.php` в адмінці), а події запускаються перед кожним маршрутом. | `system/library/kristal/cookie.php`, `{catalog,admin}/controller/extension/kristal/security.php`, міграція `0012_kristal_security` |
| 12–13 | Серверний скрипт `tools/server/kristal-backup.sh` (у `~/kristal-backup/` поза docroot, заливає `make backup-install`): доступи до БД читає з бойового `config.php` (не дублюємо пароль), `mysqldump --single-transaction | gzip` щодня (14 копій), `tar.gz` теки сайту щонеділі або якщо архіву нема/старший 6 днів (4 копії), журнал `backup.log`. Cron у cPanel ставить людина. `make backup-pull` забирає найновіший дамп у `dumps/` → `make import` (відновлення локально = AC-13). | `tools/server/`, `tools/backup.sh`, `docs/04-backup-restore.md` |
| 14 | `tools/test-security.sh` (`make test-security`, у `make verify`): локально дзеркала емулюються заголовком `Host:` до `localhost`; з `BASE=https://orendaposudu.com` — справжні адреси. Перевіряє службові шляхи (404/403), адмінку (на проді `/admin/` → 404, `REMOTE_ADMIN_DIR` → форма входу), 301 без ланцюжків, `.well-known` без редиректу, заголовки, куку. | `tools/test-security.sh`, `make/quality.mk`, `tools/verify.sh` |

## Файли
- `src/.htaccess`, `src/install/` (видалити), `src/index1.php`, `src/index.svg` (видалити)
- `src/system/library/kristal/cookie.php`, `tests/lib/cookie_test.php`
- `src/catalog/controller/extension/kristal/security.php`, `src/admin/controller/extension/kristal/security.php`
- `db/migrations/0012_kristal_security.{up,down}.sql`
- `tools/lib.sh`, `tools/deploy.sh`, `tools/package-release.sh`, `tools/localize-htaccess.sh`, `tools/prod-security.sh` (новий), `tools/test-security.sh` (новий), `tools/backup.sh` (новий), `tools/server/kristal-backup.sh` (новий), `tools/verify.sh`
- `Makefile` / `make/quality.mk`, `.env.example`
- `AGENTS.md` (§3 таблиця бібліотеки, §9, §11), `docs/03-deploy.md`, `docs/04-backup-restore.md` (новий), `README.md` (основний домен)

## БД
Схема не змінюється — лише 2 рядки в `{{PREFIX}}event` (`kristal_security_cookie`). Запитів на сторінку не додається: події ядро читає одним запитом при старті, обробник БД не чіпає. Чек-лист `db-schema-checklist.md` не потрібен (схеми немає), `db-schema-diff` має бути порожнім.

| Запит | Індекс | EXPLAIN |
|---|---|---|
| — (нових запитів немає) | — | — |

## Порядок на проді (людина, після `make verify`)
1. Бекап бази (phpMyAdmin → Експорт).
2. `make sec-status` → `make sec-cleanup APPLY=1` (install/, index1.php, index.svg → смітник).
3. `make migrate-print V=0012 > /tmp/m.sql` → phpMyAdmin.
4. `make deploy-apply` (бібліотека, контролери) — до перейменування адмінки, щоб бекап і заливка йшли в стару теку, або після — однаково, мапінг у `lib.sh`.
5. `make deploy-apply FILES=.htaccess HTACCESS=1` → `make test-security BASE=https://orendaposudu.com`.
6. `make sec-rename-admin APPLY=1` → зберегти адресу в менеджері паролів → увійти → «Панель стану → Оновити».
7. `make sec-retire-online APPLY=1` (стара тека `orendaposudu.online` → смітник).
8. `make backup-install` → cPanel → Cron Jobs (рядок друкує команда) → наступного дня `make backup-pull && make import` (AC-13).
9. За тиждень — HSTS `max-age=31536000`.

## Ризики
- **Петля редиректів**, якщо LiteSpeed не виставляє `HTTPS=on` за проксі. Зараз `RewriteCond %{HTTPS} off` хостингу працює → `!=on` теж. Відкат — залити `backups/<дата>/.htaccess` (`make deploy-rollback`).
- **Подвійний `Set-Cookie`** при збої `header_remove` — браузер бере останній, тобто наш; гірше не стане.
- **Fondy**: `SameSite=None` поводиться як зараз (без атрибута Chrome трактує як `Lax` з 2-хвилинним винятком для POST) — тобто повернення з оплати стає надійнішим, а не гіршим.
- **Перейменування адмінки** під час роботи менеджера — він вилетить на вхід. Робити ввечері.
- **Квота диска** — бекап пише розмір і вільне місце в журнал; файли щотижня.

## Відкат
- `.htaccess`: `make deploy-rollback DIR=backups/<дата>` (бекап деплою містить попередній `.htaccess`).
- Кука: `make migrate-down V=0012` локально / SQL `down` на проді — події зникають, ядро ставить куку як раніше.
- Адмінка: `tools/prod-security.sh rename-admin --undo --apply` (назад у `admin/` + конфіг із бекапу).
- `install/`, `orendaposudu.online`: `tools/prod-security.sh restore <шлях у смітнику> --apply` (`RNFR/RNTO` назад).
- Бекапи: прибрати рядок cron.
