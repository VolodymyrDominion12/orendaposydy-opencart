# 02 — Локальне середовище

## Що потрібно

- **Docker** і **Docker Compose** (`docker --version && docker compose version`)
- `make`, `curl`, `git`, `zip`, `unzip` — є в системі за замовчуванням
- Місце на диску: ~2 ГБ на образи + розмір сайту (з картинками — кілька ГБ)

PHP і Composer локально не потрібні — усе в контейнерах.

---

## Сервіси

| Сервіс | Адреса | Що це |
|---|---|---|
| `web` | http://localhost:8090 | PHP 7.4 + Apache (аналог LiteSpeed на проді) |
| `db` | localhost:3308 | MariaDB 10.6 |
| `adminer` | http://localhost:8091 | заміна phpMyAdmin |
| `mailpit` | http://localhost:8026 | перехоплювач листів (SMTP на 1026) |

Порти зсунуті відносно `mrestus-opencart` (8080/8081/3307/8025), щоб обидва
проєкти можна було тримати піднятими одночасно.

---

## Перший запуск

```bash
make init     # .env + теки src/, dumps/, backups/
make up       # зібрати образ і підняти контейнери
make check    # перевірка здоров'я
```

Поки в `src/` немає файлів OpenCart, `web` віддасть 403/404 — це нормально,
entrypoint попередить: «у /var/www/html немає index.php».

---

## Конфіг OpenCart

`config.php` **ніколи не береться з прода** — він генерується локально:

```bash
make config
```

Генератор (`docker/make-config.sh`):

- ставить `HTTP_SERVER = SITE_URL` з `.env` (http://localhost:8090/);
- підставляє локальні доступи до БД;
- спершу **зберігає копію бойового** `config.php` у `backups/config/<дата>/`
  (саме з нього можна дізнатись реальний префікс таблиць);
- перевіряє синтаксис через `php -l`.

`.htaccess` із прода зазвичай примусово кидає на HTTPS — локально це
редирект у нікуди. `make config` викликає `tools/localize-htaccess.sh`, який
прибирає ці правила (ідемпотентно).

---

## Storage

На проді `DIR_STORAGE` = `/home/matusuni/orendaposydy.com/storage_kozak/`
(нестандартна тека всередині docroot). Локально генератор вказує на
стандартний `system/storage/`, який створює `entrypoint.sh`.

Наслідок: кеш OCMOD-модифікацій із прода не переноситься. Після імпорту:

```bash
make refresh-mods      # те саме, що «Оновити» в адмінці
```

---

## Типові проблеми

| Симптом | Причина / рішення |
|---|---|
| Біла сторінка, 500 | немає `src/config.php` → `make config`; дивіться `make logs-php` |
| Редирект на `https://orendaposydy.com` | не виконано `make config` (`.htaccess` + `config_secure`) |
| Правки `.twig`/CSS не видно | `make clear-cache` (Twig кеш) |
| «Incorrect integer value» при збереженні | локальна БД у строгому режимі — перевірте `sql-mode` у `docker-compose.yml` |
| Не видно модулів/правок після імпорту | `make refresh-mods` |
| Порт зайнятий | змініть `WEB_PORT`/`ADMINER_PORT`/`DB_PORT` у `.env` → `make restart` |
| Кирилиця «кракозябрами» | дамп імпортовано не в `utf8mb4` → перевірте `make db-tables` |

---

## Локальний адміністратор

```bash
make localize-admin     # ставить локальний пароль
make login-admin        # показує логін і пароль
```

Пароль бойового адміна після імпорту лишається дійсним — не використовуйте
його локально, щоб не звикнути до бойових creds.
