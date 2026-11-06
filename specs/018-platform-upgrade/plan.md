# 018 — План реалізації

Посилання: [`spec.md`](spec.md) (Approved 2026-11-06).

## Підхід
Оновлення ядра — **перезапис файлів офіційним пакетом 3.0.4.1** (стандартний шлях для мінорних релізів гілки 3.0)
плюс зміни схеми з офіційного upgrade-скрипта, оформлені нашою міграцією `0002_core_3041` з `down`.
Перед перезаписом порівнюємо `src/` з **оригінальним 3.0.3.2**: так знаходимо ручні правки ядра на поточному сайті,
які перезапис мовчки знищив би. Кожна знайдена правка — рішення: переносимо в OCMOD/подію або свідомо відкидаємо (запис у «Замітки»).
Усе робить скрипт `tools/core-upgrade.sh` (за замовчуванням dry-run), щоб той самий крок можна було повторити й перевірити.

### Знахідки аналізу пакета 3.0.4.1 (2026-11-06)
- **Twig 1 → Twig 3.8.** 3.0.3.2 тримає Twig 1.x у `system/library/template/Twig/`; 3.0.4.1 — Twig 3.8 у `DIR_STORAGE/vendor/`.
  На проді `DIR_STORAGE` = `storage_kozak/`, де зараз лише `scss.inc.php`. **Без `storage_kozak/vendor/` після оновлення падає весь сайт** →
  vendor їде окремо (у ZIP-пакеті під `storage_kozak/vendor/`). Шаблони `sauco` перевіряються на конструкції, прибрані в Twig 3
  (`spaceless`, `filter`-тег, `for … if`, `sameas`, `Twig_*`): 77 з ~120 перевірено агентом — чисто; решту перевіряє `core-report`.
- **Схема.** `db/schema.sql` проти `install/opencart.sql` 3.0.4.1: єдина реальна відмінність ядра — `oc_event.sort_order DEFAULT 0`.
  Решта — формат дампу (префіксні індекси `name(250)`, `DEFAULT NULL` у `text`) і колонки теми `sauco` в `product_description` (лишаються).
  Нових налаштувань і подій у чистій 3.0.4.1 немає.
- **Майстер `install/` не запускаємо:** upgrade-скрипт 1009 переписує `DIR_*` у `config.php` на `system/storage/` — зламав би `storage_kozak/`.
- **Мови.** Пакет містить лише `en-gb`. `uk-ua` — сторонній переклад під 3.0.3.2: переклади файлів ядра лишаються (для 27 нових файлів —
  невикористовувані платіжні модулі — OpenCart бере текст `en-gb`). `ru-ru` у `oc_language` не встановлена → прибираємо повністю.
- **Ручні правки ядра під тему `sauco`** (звіт 2026-11-06): у `src/` немає `checkout/checkout.php` (вимкнено перейменуванням у `_checkout.php`),
  а оформлення йде через сторонній `checkout/order.php` + `model/checkout/simple_order.php` (Fondy, Telegram). `common/header.php`, `footer.php`,
  `product/product.php`, `product/category.php` змінені під `sauco`. `seo_url.php` змінено (opencart-russia.ru): 301 з `?route=` на ЧПУ і ЧПУ для
  маршрутів — використовуються лише `checkout/order → /order`, `checkout/success → /success`; вхід за ними ядро 3.0.4.1 обробляє саме.
  **Рішення:** змінені файли ядра й навмисно вимкнені — у `core-keep.txt`, `apply` їх не чіпає; замінюються разом з темою в 003. Точний перелік —
  лише з `opencart-3.0.3.2.zip` (без нього `apply` відмовляється).
- **Залишки:** теки-копії з `_` (`catalog/controller/_account`, `_mail`, `_affiliate`, `extension/_module`, `_payment`…), `desktop.ini`,
  `error_log`, `*.bak`/`nppBackup`, файли ядра 3.0.3.2, яких немає в 3.0.4.1 (PayPal `pp_*`, jQuery 2.1.1), мовні файли видалених модулів.
  Правила класифікації — у `classify()` скрипта; результат — `core-report.md` і `core-remove.txt` (людина переглядає перед `apply`).

Відкинуто: запуск `install/` upgrade-майстра на проді (потребує теки `install/`, яку ми прибираємо в 017, і не дає `down`);
ручне копіювання через FileZilla (неповторювано).

## Файли
| Файл | Новий / зміна | Що |
|---|---|---|
| `tools/core-upgrade.sh` | новий ✔ | `report` (звіт + список до видалення), `apply` (бекап → ядро → vendor → видалення), `verify` (AC-2), `package` (ZIP для cPanel), `prod-remove` (FTP DELE), `rollback`. Без `APPLY=1` нічого не пише. Без rsync — лише `tar`/`cp`/`unzip` |
| `specs/018-platform-upgrade/core-report.md`, `core-remove.txt`, `core-keep.txt` | згенеровані | звіт, список до видалення, список файлів ядра, що НЕ перезаписуються; людина переглядає |
| `make/quality.mk` | зміна ✔ | цілі `core-report`, `core-apply`, `core-verify`, `core-package`, `core-prod-remove`, `core-rollback` |
| `db/migrations/0002_core_3041.{up,down}.sql` | новий ✔ | `oc_event.sort_order DEFAULT 0` + видалення події `sms_alert`; `down` повертає обидва |
| `tools/lint-php.sh` | зміна ✔ | синтаксис під 7.3 (прод) і 8.3 (наперед) |
| `tools/verify.sh` | зміна ✔ | назва кроку lint |
| `docker/Dockerfile` | зміна ✔ | прибрано ionCube Loader, оновлено коментарі про версії |
| `.gitignore` | зміна ✔ | `vendor-src/` |
| `src/**` (ядро) | зміна | файли ядра 3.0.4.1 |
| `src/system/tweak.ocmod.xml` та залишки | видалення | за `core-upgrade.remove.txt` |
| `AGENTS.md`, `README.md`, `docs/agents/testing.md` | зміна | версія 3.0.4.1, lint 7.3 + 8.3 |

### Що не перезаписується ніколи
`config.php`, `admin/config.php`, `.htaccess`, `install/`, `image/` (окрім `image/` ядра, якщо такі є в пакеті — перевіряє `plan`),
`system/storage/`, `storage_kozak/`, `catalog/view/theme/sauco/`, файли модулів `oplata`, `notifications_in_telegram`.

### OCMOD / події
| Механізм | Ціль | Навіщо |
|---|---|---|
| — | — | Нових немає. Прибираємо `tweak.ocmod.xml` і мертву подію `sms_alert`. Після `apply` — `make refresh-mods`, щоб кеш модифікацій зібрався з OCMOD теми `sauco` на новому ядрі |

## Міграції БД
| Версія | Що | down |
|---|---|---|
| 0002_core_3041 | `ALTER TABLE oc_event MODIFY sort_order INT(3) NOT NULL DEFAULT 0`; `DELETE` події `sms_alert` | `sort_order` без DEFAULT; `INSERT … WHERE NOT EXISTS` події `sms_alert` з тими самими значеннями (новий id) |

Чек-лист `docs/agents/db-schema-checklist.md` — у `tasks.md`, крок T5.

## Запити та індекси
Нових запитів у нашому коді немає. Зміни запитів ядра — від розробників OpenCart; контроль — `make db-profile` до/після на `/`, `/posud/tarilky`, картці товару.

## Кешування
Після `apply`: `make clear-cache-all && make refresh-mods`.

## Вплив на швидкість і мобільний бюджет
Вітрина не змінюється (тема `sauco`). Очікування: кількість запитів ± 5 %; `make test-mobile` у межах стартового рівня з 001.

## Деплой на прод
Поштучний FTP (`make deploy`) для ~2 250 файлів ядра + ~1 460 файлів vendor надто повільний, тому для 018 — ZIP:
1. Локально все зелене (DoD). `make core-package` → `backups/018-core-3.0.4.1.zip` (ядро + `storage_kozak/vendor/`; без `config.php`, `admin/config.php`, `.htaccess`, `install/`, `robots.txt`, `php.ini`).
2. Бекап проду: cPanel → File Manager → тека сайту → Compress (без `image/catalog`) + phpMyAdmin → Export бази.
3. Перейменувати `index.php` → `index.php.off`, `index1.php` → `index.php` (сторінка «тимчасово недоступний»). *(клієнтів немає — можна пропустити)*
4. Завантажити ZIP у теку сайту → Extract з перезаписом.
5. `make core-prod-remove` (dry-run) → переглянути → `make core-prod-remove APPLY=1` (FTP DELE за `core-remove.txt`).
6. `make migrate-print V=0002` → phpMyAdmin.
7. Очистити `storage_kozak/cache/`; адмінка → Модифікатори → «Оновити»; повернути `index.php`.
8. `make test-smoke BASE=https://orendaposydy.com` + тестове замовлення «ТЕСТ 018» (AC-9).

## Ризики і відкат
| Ризик | Ймовірність | Що робимо |
|---|---|---|
| На сайті є ручні правки ядра, перезапис їх знищить | середня | `core-diff` проти 3.0.3.2 до перезапису; кожну правку розбираємо |
| OCMOD теми `sauco` не знаходить рядків у новому ядрі → частина вітрини без змін теми | середня | після `refresh-mods` переглянути журнал модифікацій; smoke + огляд головної, категорії, картки, оформлення |
| Модуль Fondy несумісний з новим ядром | низька | AC-6 локально до деплою |
| Збережені старі файли ядра (`core-keep.txt`) несумісні з новим ядром 3.0.4.1 | низька (гілка 3.0, ті самі API) | smoke + огляд головної, категорії, товару, оформлення; помилка → точкова правка цього файла з записом у «Замітки» |
| Шаблон `sauco` використовує конструкцію, прибрану в Twig 3 | низька (77/120 чисті) | розділ 2 `core-report.md`; правка — у шаблоні `sauco` як виняток (тема й так замінюється в 003), з записом у «Замітки» |
| На проді не розпакувався `storage_kozak/vendor/` → сайт лежить | низька | ZIP містить vendor; перевірка одразу після Extract: є `storage_kozak/vendor/autoload.php`; відкат — бекап із кроку 2 |
| Часткова заливка по FTP | низька | бекап + `make deploy-rollback`; вікно робіт будь-коли (клієнтів немає) |

Відкат локально: `make core-rollback BK=backups/core-018-<дата>.tar.gz APPLY=1` + `make migrate-down V=0002` + `make clear-cache-all && make refresh-mods` (перевірено в пісочниці агента; AC-10 — на локальному стенді).
Відкат на проді: розпакувати архів із кроку 2 деплою, `down`-SQL через phpMyAdmin, «Оновити» модифікатори.
