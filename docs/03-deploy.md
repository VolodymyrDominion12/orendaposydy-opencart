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
| `.htaccess` | правила хостингу (є окремий прапорець `--include-htaccess`) |
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
- Перевірте сайт: https://orendaposydy.com/

---

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
