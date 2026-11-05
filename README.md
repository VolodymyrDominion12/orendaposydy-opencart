# orendaposydy-opencart

Локальне середовище й деплой для **https://orendaposydy.com/** (OpenCart
**3.0.3.2**, шаблон `sauco`). Зроблено за тим самим принципом, що й
`mrestus-opencart`: Docker локально, FTP на прод, жодних «залив через
FileZilla і сподіваюсь».

---

## Де лежить сайт (перевірено)

| Що | Значення |
|---|---|
| Хостинг | HOSTiQ, спільний хостинг, cPanel |
| Сервер | `eushared20.twinservers.net` = `31.131.26.121` |
| cPanel-акаунт | `matusuni` (тека `/home/matusuni/`) |
| Тека сайту | `/home/matusuni/orendaposydy.com` (у FTP: `orendaposydy.com/`) |
| База даних | `matusuni_kozak`, юзер `matusuni_kozak`, префікс `oc_` |
| Storage | `orendaposydy.com/storage_kozak/` (нестандартна тека!) |
| Версія OpenCart | **3.0.3.2** (з `index.php`), шаблон `sauco` |
| PHP | 7.3.33, LiteSpeed |
| SSH | **закритий** → деплой тільки через FTP / File Manager |

**Важливо:** FTP-акаунт бачить домашню теку акаунта `matusuni`, у якій поруч
лежать усі сайти: `orendaposydy.com/`, `public_html/` (це mrestus.com.ua),
`orendaposudu.online/`, `kuharkozak.top/` тощо. Тому в `.env`:

```ini
FTP_REMOTE_DIR=orendaposydy.com     # НЕ public_html
```

Один і той самий FTP-акаунт підходить і для mrestus, і для цього сайту —
різниця лише в `FTP_REMOTE_DIR`.

---

## Швидкий старт

```bash
cd ~/PycharmProjects/orendaposydy-opencart

make init        # створити .env (UID/GID підставляться самі)
make up          # підняти PHP + MariaDB + Adminer + Mailpit
```

Далі — **забрати файли й базу з хостингу** (докладно: [docs/01-import-from-hosting.md](docs/01-import-from-hosting.md)):

```bash
# 1. архів сайту з cPanel File Manager → розпакувати в src/
unzip -q ~/Завантаження/orendaposydy.zip -d src/

# 2. дамп бази з phpMyAdmin → dumps/
mv ~/Завантаження/matusuni_kozak.sql dumps/

# 3. імпорт + локалізація (пошта → Mailpit, платежі вимкнено, SSL вимкнено)
make import

# 4. локальний пароль адміністратора
make localize-admin
```

Готово: http://localhost:8090/ , адмінка http://localhost:8090/admin/ .

---

## Правила роботи (для людей і AI-агентів)

| Файл | Що |
|---|---|
| [`AGENTS.md`](AGENTS.md) | обов'язкові правила: SDD, код OpenCart, БД, запити, тести, мобільна версія, SEO, безпека, деплой |
| [`CLAUDE.md`](CLAUDE.md) | підключає `AGENTS.md` для Claude Code |
| [`specs/`](specs/README.md) | специфікації фіч (spec → plan → tasks), беклог `specs/BACKLOG.md` |
| [`docs/agents/`](docs/agents/) | чек-листи: схема БД, продуктивність запитів, мобільна версія, тестування |
| `db/` | міграції, знімок схеми, baseline аудиту |
| `tests/smoke/`, `tests/mobile/` | smoke-URL, редиректи, мобільні бюджети |

Перед «готово»: `make verify` (lint PHP 7.3, аудит БД, схема, міграції, smoke, мобільний аудит).
Перший запуск: `make db-check UPDATE=1`, `make db-schema-snapshot`, `make mobile-setup` — див. `db/README.md`.

---

## Структура

```
orendaposydy-opencart/
├── docker-compose.yml    4 сервіси (web, db, adminer, mailpit)
├── Makefile              усі команди (make help)
├── .env                  ваші налаштування (не в git)
├── src/                  ← ФАЙЛИ САЙТУ. Тут ви працюєте.
├── dumps/                дампи бази
├── backups/              бекапи перед деплоєм, копії бойових config.php
├── docker/
│   ├── Dockerfile        PHP 7.4 + Apache + розширення OpenCart + ionCube
│   ├── php-dev.ini       ліміти й режим розробки
│   ├── entrypoint.sh     створює каталоги, виставляє права
│   └── make-config.sh    генератор config.php
├── tools/
│   ├── lib.sh            спільні функції (FTP, SQL, захист шляхів)
│   ├── import-db.sh      імпорт дампа + визначення префікса + локалізація
│   ├── localize-db.sh    локалізація наявної бази
│   ├── make-config.sh    локальні config.php
│   ├── deploy.sh         деплой з бекапом і dry-run
│   ├── package-release.sh ZIP для файлового менеджера
│   ├── ftp-*.sh          FTP-операції
│   ├── clear-cache.sh    скидання кешу
│   ├── refresh-modifications.sh  OCMOD «Оновити»
│   ├── check-env.sh      діагностика
│   └── sql/              SQL-локалізація (01–04)
└── docs/
    ├── 01-import-from-hosting.md
    ├── 02-local-setup.md
    └── 03-deploy.md
```

---

## Команди

| Команда | Що робить |
|---|---|
| `make up` / `make down` | підняти / зупинити середовище |
| `make import` | імпорт найновішого дампа з `dumps/` + локалізація |
| `make localize` | повторно локалізувати базу |
| `make localize-admin` | + локальний пароль адміністратора |
| `make login-admin` | показати логін/пароль адміна |
| `make config` | перегенерувати `config.php` і локалізувати `.htaccess` |
| `make clear-cache` | скинути кеш (якщо правки `.twig`/CSS не видно) |
| `make refresh-mods` | застосувати OCMOD-модифікації |
| `make deploy` | **dry-run**: показати, що поїде на прод |
| `make deploy-apply` | залити на прод (бекап + підтвердження `YES`) |
| `make deploy-rollback DIR=backups/<дата>` | відкотити |
| `make deploy-sql SQL=tools/sql/x.sql` | підготувати SQL для phpMyAdmin |
| `make check` | перевірити, що середовище здорове |
| `make url` | показати локальні адреси |

---

## Що варто знати про цей сайт

1. **`install/` у корені прода.** В OpenCart тека `install/` після
   встановлення має бути видалена або закрита — інакше це ризик
   перевстановлення. Локально вона не потрібна, на проді її варто прибрати
   (після бекапу).
2. **Storage — `storage_kozak/`,** а не `system/storage/`. Локальний
   генератор `config.php` вказує на стандартний `system/storage/` (його
   створює entrypoint). Через це після імпорту може знадобитись
   `make refresh-mods` — кеш OCMOD із прода не переноситься.
3. **`src/storage_kozak/` у git не потрапляє** (кеш, логи, сесії).
4. **PHP на проді 7.3.33, локально 7.4** — сумісно для OpenCart 3; за
   потреби `PHP_VERSION=7.3` у `.env` (образ EOL).
5. **Замовлення й листи локально безпечні:** `make import` перемикає пошту на
   Mailpit (`http://localhost:8026`) і вимикає платіжні модулі
   (`tools/sql/03-disable-live-services.sql`).

---

## Деплой

```bash
make deploy                    # що поїде (нічого не змінює)
make deploy-apply              # залити; спитає YES, спершу зробить бекап
make deploy-rollback DIR=backups/2026-11-05-1200   # відкат
```

Що **ніколи** не деплоїться: `config.php`, `admin/config.php`,
`system/storage/`, `image/cache/`, `.htaccess`, `install/`, `*.sql`.
Докладно: [docs/03-deploy.md](docs/03-deploy.md).
