# 03 — Деплой на прод

## Принцип

```
локально перевірили  →  побачили список файлів  →  підтвердили  →  залили
                                                       ↓
                                              автоматичний бекап прода
```

За замовчуванням `tools/deploy.sh` **нічого не змінює** — це dry-run.

---

## Крок 1. Основа: git

Деплой знає, що заливати, лише завдяки історії змін:

```bash
git status
git add -A && git commit -m "Виправлено висоту карток на планшетах"
make deploy           # подивитись, що поїде
make deploy-apply     # залити
```

Зручно позначати релізи тегами:

```bash
git tag v1.1
make deploy SINCE=v1.0     # усе, що змінилось від v1.0
```

Не хочете git — вкажіть файли вручну:

```bash
make deploy FILES="catalog/view/theme/sauco/stylesheet/custom.css"
```

---

## Крок 2. FTP (уже налаштовано)

У `.env`:

```ini
DEPLOY_METHOD=ftp
FTP_HOST=ftp.orendaposydy.com
FTP_PORT=21
FTP_USER=<ваш ftp-акаунт>
FTP_PASSWORD=<пароль>
FTP_REMOTE_DIR=orendaposydy.com     # тека сайту, НЕ public_html
FTP_TLS=no
```

Це той самий FTP-акаунт, що й для mrestus: він бачить домашню теку акаунта
`matusuni`, де `orendaposydy.com/` — корінь сайту.

Перевірка без ризику:

```bash
tools/ftp-get.sh index.php /tmp/test-index.php && echo "FTP працює"
```

---

## Крок 3. Що деплоїться, а що ні

Ніколи не заливаються (навіть якщо є в git):

| Шлях | Чому |
|---|---|
| `config.php`, `admin/config.php` | бойові доступи до БД; локальні вказують на `localhost` і зламають сайт |
| `system/storage/` | кеш, логи, сесії, згенеровані OCMOD |
| `image/cache/` | прев'ю, генеруються на місці |
| `.htaccess` | лише явно: `make deploy-apply FILES=.htaccess HTACCESS=1` (017: файл однаковий для локалу й проду) |
| `install/`, `*.sql` | небезпечно / виконується через phpMyAdmin |

---

## Крок 4. SQL-зміни

Структурні зміни (наприклад, нові налаштування в `oc_setting`) не заливаються
файлом — вони виконуються через phpMyAdmin:

```bash
make deploy-sql SQL=tools/sql/my-change.sql
```

Скрипт підставить реальний префікс (`oc_`) замість `{{PREFIX}}` і покладе
готовий файл у `backups/for-phpmyadmin-*.sql`. Далі: phpMyAdmin → ваша база →
SQL → вставити → Go.

**Перед виконанням** зробіть експорт бази на хостингу.

---

## Крок 5. Після заливки

- Правки `.twig`/CSS не видно → `make deploy-apply CLEAR_CACHE=1`
  (скидає `system/storage/cache` на проді) або в адмінці «Панель стану» →
  шестерня → «Оновити».
- Додали `.ocmod.xml` → він **не** заливається через FTP: адмінка →
  Розширення → Встановлення розширень → завантажити → Модифікатори → «Оновити».
- Перевірте сайт: `make test-smoke BASE=https://orendaposudu.com` і `make test-security BASE=https://orendaposudu.com`.

---

## Адмінка під іншою назвою (017)

На проді адмінка не в `admin/`, а в теці з `.env` → `REMOTE_ADMIN_DIR` (випадкова назва, у git її немає).
Локально нічого не змінюється: правите `src/admin/…`, а `make deploy`, бекап перед деплоєм, відкат і `make package`
самі кладуть файли в бойову теку (план деплою показує `admin/x.php → <тека>/x.php`).
Перейменування — один раз: `make sec-rename-admin` (план) → `make sec-rename-admin APPLY=1`; відкат — `UNDO=1 APPLY=1`.

## .htaccess (017)

`src/.htaccess` однаковий для локалу й проду: бойові правила (301 з дзеркал, заголовки безпеки) в блоці
`# kristal:prod BEGIN/END` прив'язані до доменів і на localhost не спрацьовують. Заливається лише явно:

```bash
make deploy-apply FILES=.htaccess HTACCESS=1
make test-security BASE=https://orendaposudu.com
```

Відкат — як будь-якого файлу: `make deploy-rollback DIR=backups/<дата>`.

## Прибирання на проді (017)

`make sec-status` — що лежить у корені сайту, чи є `install/`, архіви, стара тека, бекапи (лише читання).
`make sec-cleanup APPLY=1`, `make sec-retire-online APPLY=1` нічого не видаляють: переносять одною FTP-командою
в `~/kristal-trash/<дата>/` поза сайтом (рекурсивне видалення по FTP = сотні команд = блок IP). Повернути:
`make sec-restore P=kristal-trash/<дата>/site/<ім'я> APPLY=1`. Смітник видаляйте в File Manager, коли все перевірено.

Бекапи бази й файлів — `docs/04-backup-restore.md`.

## Відкат

Кожен `deploy-apply` спершу **скачує** поточні версії файлів із прода в
`backups/<дата>/`. Повернути як було:

```bash
make backup-list
make deploy-rollback DIR=backups/2026-11-05-1200
```

Скрипт заливає файли з бекапу назад (теж із підтвердженням).

---

## Якщо FTP заблокував IP

Хостинг блокує IP після серії дрібних FTP-команд (наприклад, рекурсивного
обходу тисяч файлів). Симптом: `Connection timed out` на порт 21, при цьому
сайт і cPanel працюють.

- зазвичай відпускає за 15–60 хвилин;
- швидше — чат підтримки HOSTiQ;
- для великих змін використовуйте `make package` (ZIP) і File Manager.
