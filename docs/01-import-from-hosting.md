# 01 — Як забрати файли й базу з хостингу

Мета: отримати **файли сайту** (у `src/`) і **дамп бази** (у `dumps/`).
Після цього `make import` зробить усе інше сам.

Доступ лише через cPanel: SSH на сервері закритий, тому працюємо через
**File Manager** (файли) і **phpMyAdmin** (база).

---

## Крок 0. Зайти в cPanel

Три способи, будь-який підходить:

1. **Панель клієнта HOSTiQ** (hostiq.ua → «Панель клієнта») → **Мої послуги**
   → рядок потрібної послуги → кнопка **CP** (автологін, пароль не потрібен).
2. Напряму: **https://orendaposydy.com:2083** — 5 секунд почекати, поки
   пройде перевірка «One moment, please…», далі логін **`matusuni`** і пароль
   cPanel.
3. Через сервер: `https://eushared20.twinservers.net:2083`.

> ⚠️ **Логін акаунта — `matusuni`.** `kuharkozak` — це один із доменів у
> цьому ж акаунті, а не користувач. Після 20 невдалих спроб хостинг блокує
> IP — тоді розблоковує тільки чат підтримки HOSTiQ.

Пароль забули: на сторінці входу cPanel → «Reset Password», або в панелі
клієнта в картці послуги → «Change Password».

---

## Крок 1. Файли сайту

### Варіант А — File Manager (рекомендовано)

1. cPanel → **File Manager** → тека **`orendaposydy.com`** (вона в домашній
   теці, поруч із `public_html`).
2. Переконайтесь, що бачите `index.php`, `admin/`, `catalog/`, `system/`,
   `config.php`. Це корінь сайту.
3. **Перед архівуванням виключіть зайве** (воно велике або непотрібне):
   - `image/catalog/` — картинки товарів (можна забрати пізніше, див. нижче);
   - `image/cache/` — прев'ю, генеруються на місці;
   - `storage_kozak/` — кеш, логи, сесії;
   - `install/` — тека інсталятора (на проді її взагалі варто прибрати);
   - `*.zip`, `error_log`, `index1.php` — сміття.
4. Виділіть усе → **Compress** → формат **Zip** → створити.
5. Дочекайтесь `orendaposydy.zip` → **Download**.
6. Розпакуйте локально:

```bash
cd ~/PycharmProjects/orendaposydy-opencart
unzip -q ~/Завантаження/orendaposydy.zip -d src/
ls src/     # index.php, admin, catalog, system, image
```

> Якщо архів вийшов завеликий і File Manager обривається — архівуйте частинами
> (`admin`+`system`+`catalog` окремо від `image/`).

### Варіант Б — FTP

FTP-акаунт у вас уже є (той самий, що для mrestus), він бачить усі сайти.

```bash
# перевірка, що доступ живий
cd ~/PycharmProjects/orendaposydy-opencart
tools/ftp-get.sh index.php /tmp/test-index.php && echo "FTP працює"
```

Далі FileZilla: хост `ftp.orendaposydy.com`, ваш FTP-логін/пароль, тека
`orendaposydy.com` → тягнете в `src/`.

> ⚠️ Не робіть рекурсивний обхід тисяч файлів частими FTP-командами: хостинг
> це сприймає як атаку й блокує FTP для вашої IP на 15–60 хвилин (перевірено).
> Один архів через File Manager — надійніше.

### Картинки товарів (`image/catalog/`)

Найбільша тека (сотні МБ). Локально без неї сайт працює, але товари
показують заглушки. Забирайте окремим архівом, коли знадобиться.

---

## Крок 2. Дамп бази

1. cPanel → **phpMyAdmin**.
2. Ліворуч виберіть базу **`matusuni_kozak`**.
3. Вкладка **Експорт** → спосіб **Швидкий**, формат **SQL**.
4. Увімкніть **«Додати DROP TABLE / IF NOT EXISTS»**.
5. Якщо база більша за 50 МБ — **стиснення gzip**.
6. **Експорт** → файл завантажиться.

```bash
mv ~/Завантаження/matusuni_kozak.sql* ~/PycharmProjects/orendaposydy-opencart/dumps/
```

Префікс таблиць визначати не треба — `make import` сам знайде його в дампі
(тут він `oc_`) і за потреби виправить `.env`.

---

## Крок 3. Перевірка перед імпортом

```bash
cd ~/PycharmProjects/orendaposydy-opencart
ls src/index.php src/admin/index.php src/system/    # файли на місці
ls -lh dumps/                                        # дамп на місці
make check                                           # контейнери здорові
```

Далі: `make import` → `make localize-admin` → http://localhost:8090/
