# 019 — План реалізації

Специфікація: `spec.md` (статус Approved 2026-11-07). Розбіжності з першою версією плану — у «Зміни під час реалізації» внизу.

## Підхід
Один модуль ядрового типу `module/kristal_core` (адмінка: налаштування, встановлення, тестове повідомлення) і бібліотека
`system/library/kristal/*` з класами в просторі імен `Kristal\`. Класи підвантажує автолоадер ядра (`system/startup.php` →
`library()` перетворює `Kristal\Antispam` на `library/kristal/antispam.php`), тому `$this->load->library()` не потрібен
і немає конфлікту з ядровими ключами реєстру (`log`, `cache`). Налаштування зберігаються в `oc_setting` з кодом
`module_kristal_core`, тому ядро вже завантажує їх у `$this->config` на кожному запиті, і на вітрині немає додаткових запитів.
Антиспам без запису в сесію: один підписаний токен форми (HMAC від сесії, назви форми й часу) дає одночасно CSRF і time-trap,
honeypot перевіряється окремо, ліміт частоти зберігається в окремій маленькій таблиці.

Відкинуті альтернативи:
- `$this->load->library('kristal/antispam')` реєструє об'єкт під `basename` (`antispam`), а для логера (`log`) це перезаписало б ядровий логер.
- Ліміт частоти у файловому кеші: `Cache\File` має один TTL на весь кеш (3600 с) і при кожному створенні робить `glob` по всіх файлах. Окремий ключ на IP засмітив би теку кешу.
- Ліміт частоти в сесії бот обходить, просто не надсилаючи cookie.
- reCAPTCHA/Turnstile: сторонній скрипт (мобільний бюджет, згода cookie). Відкладено, див. «Поза межами».

## Файли
| Файл | Новий / зміна | Що |
|---|---|---|
| `src/system/library/kristal/nap.php` | новий | `Kristal\Nap`: читає `module_kristal_core_*` з `Config`, віддає нормалізований масив (телефони з `tel:`-форматом, посилання Viber/Telegram/WhatsApp, соцмережі, графік), порожні поля прибирає |
| `src/system/library/kristal/phone.php` | новий | `Kristal\Phone`: `normalize('+38 (067) 123-45-67') → '+380671234567'`, `isValid()`, `display()` → `+38 067 123 45 67`, `mask()` |
| `src/system/library/kristal/antispam.php` | новий | `Kristal\Antispam`: `token($form)`, `fields($form)` (масив для twig: токен + honeypot), `check($form, $post, $ip)` → `['ok'=>bool,'reason'=>'honeypot'|'too_fast'|'token'|'expired'|'rate']` |
| `src/system/library/kristal/rate_limit.php` | новий | `Kristal\Rate_limit`: `hit($action, $ip, $limit, $window)`, 2 запити (див. нижче), ймовірнісне очищення |
| `src/system/library/kristal/telegram.php` | новий | `Kristal\Telegram`: `new Telegram($token)`, `send($chat_id, $html)` через cURL, таймаут 5 с (з'єднання 3 с), `parse_mode=HTML`, `escape()`; повертає `['ok'=>bool,'error'=>string]`, не кидає винятків; токен у помилках замінюється на `***` |
| `src/system/library/kristal/jsonld.php` | новий | `Kristal\Jsonld`: `localBusiness(array $nap, $url, $logo)` → масив; `render(array)` → `<script type="application/ld+json">` з `JSON_UNESCAPED_UNICODE \| JSON_UNESCAPED_SLASHES \| JSON_HEX_TAG` |
| `src/system/library/kristal/log.php` | новий | `Kristal\Log`: обгортка над ядровим `\Log('kristal.log')`, маскує телефони й email регулярними виразами до запису |
| `src/system/library/kristal/cache_key.php` | новий | `Kristal\Cache_key`: константи `kristal.nap` тощо, `flush(\Cache $cache)` → `delete('kristal')` (видаляє всі `cache.kristal.*`) |
| `src/admin/controller/extension/module/kristal_core.php` | новий | `index` (показ + збереження стандартним POST → redirect, як модулі ядра), `telegramTest` (AJAX), `install`, `uninstall`, `validate` |
| `src/admin/view/template/extension/module/kristal_core.twig` | новий | 5 вкладок (див. AC-1), повторюваний список телефонів (до 3), кнопка тесту Telegram, превʼю JSON-LD |
| `src/admin/language/uk-ua/extension/module/kristal_core.php` | новий | тексти |
| `src/admin/language/en-gb/extension/module/kristal_core.php` | новий | ті самі ключі англійською (мовний завантажувач ядра спершу читає `en-gb`) |
| `src/catalog/language/{uk-ua,en-gb}/extension/module/kristal_core.php` | новий | тексти відмови антиспаму для форм вітрини (`error_spam_<reason>`), щоб 009/010 не хардкодили |
| `db/migrations/0004_kristal_rate_limit.{up,down}.sql` | новий | таблиця частоти спроб |
| `tests/lib/run.php` + `tests/lib/*_test.php` | новий | мінітести бібліотеки без фреймворку (AC-7, AC-8, телефони, JSON-LD) |
| `tools/test-lib.sh` | новий | 2 проходи: `web`-контейнер з БД (tests копіюються в `/tmp`, бо `tests/` не змонтована) + `php:7.3-cli` без БД |
| `make/quality.mk` | зміна | ціль `test-lib` (`T=` — фільтр); додати в `tools/verify.sh` після `lint` |
| `tools/verify.sh` | зміна | крок `test-lib` |

Ядро OpenCart не змінюється. OCMOD і подій у 019 немає: вітрина нічого нового не виводить (AC-11).
| Механізм | Ціль | Навіщо |
|---|---|---|
| — | — | — |

### Налаштування (`oc_setting`, `code = module_kristal_core`, `store_id = 0`)
| Ключ | Тип | Примітка |
|---|---|---|
| `module_kristal_core_status` | 0/1 | обов'язковий для модулів OC3 |
| `module_kristal_core_name`, `_legal_name`, `_address`, `_city`, `_postcode`, `_geo_lat`, `_geo_lng`, `_email` | рядок | початкові значення з `config_name`, `config_address`, `config_email`, `config_geocode` |
| `module_kristal_core_phones` | JSON-масив `[{number, label, viber, telegram, whatsapp}]` | до 3; перший — основний |
| `module_kristal_core_hours` | JSON `[{days, from, to}]` + `_hours_note` | для `openingHoursSpecification`; початково `config_open` у `_hours_note` |
| `module_kristal_core_telegram_username`, `_instagram`, `_facebook`, `_tiktok`, `_youtube` | рядок (URL або @нік) | |
| `module_kristal_core_tg_token`, `_tg_chat_id` | рядок | токен ніколи не віддається в шаблон повністю (AC-5) |
| `module_kristal_core_spam_min_seconds` (3), `_spam_rate_limit` (10), `_spam_rate_window` (3600) | int | |
| `module_kristal_core_saved` | 0/1 | 0 після встановлення → форма заповнюється з ядра (AC-1); 1 після першого збереження |
| `module_kristal_core_salt` | рядок 64 hex | генерується в `install()` через `random_bytes(32)`, якщо її ще немає; після «Видалити» (AC-10) зникає разом з налаштуваннями — нова сіль лише інвалідує старі токени форм і лічильники |

Синхронізація в ядро (погоджено 2026-11-07): при збереженні `editSettingValue('config', …)` для
`config_telephone` (основний, у вигляді `+38 067 123 45 67`), `config_address` (поле «Адреса», без міста), `config_email`.
Порожні значення не синхронізуються (ядру потрібен email магазину для листів). Ядровий `editSetting('config')` не викликаємо:
він видалив би поля `sauco` (`config_custom_css` тощо), див. 018 → «Замітки».

### Токен форми (CSRF + time-trap)
`token = ts . '.' . substr(hash_hmac('sha256', session_id . '|' . form . '|' . ts, salt), 0, 32)`.
Перевірка: формат → HMAC через `hash_equals` → `now - ts >= min_seconds` (інакше `too_fast`) → `now - ts <= 7200` (інакше `expired`).
Honeypot: поле `k_website`, приховане CSS-класом (не `type=hidden`, бо такі боти пропускають); має бути порожнім.
Порядок перевірок: honeypot → token → rate. Частоту рахуємо лише для запитів, що пройшли перші перевірки,
щоб бот не «з'їдав» ліміт живого клієнта з тієї самої NAT-адреси мобільного оператора.

## Міграції БД
| Версія | Що | down |
|---|---|---|
| 0004_kristal_rate_limit | `CREATE TABLE IF NOT EXISTS {{PREFIX}}kristal_rate_limit` | `DROP TABLE IF EXISTS` |

```sql
CREATE TABLE IF NOT EXISTS `{{PREFIX}}kristal_rate_limit` (
  `key_hash`     CHAR(40)     CHARACTER SET ascii NOT NULL,  -- sha1(salt|action|ip)
  `action`       VARCHAR(32)  NOT NULL,                      -- 'lead', 'callback' … (для діагностики)
  `hits`         INT(11)      NOT NULL DEFAULT 0,
  `window_start` DATETIME     NOT NULL,
  PRIMARY KEY (`key_hash`),
  KEY `idx_window_start` (`window_start`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
```
IP-адреса в чистому вигляді не зберігається (AGENTS.md §9: персональні дані).

Чек-лист `docs/agents/db-schema-checklist.md`:
- [x] У plan описано таблицю, колонки, індекси й запити (нижче)
- [x] Аналогу в ядрі немає (`db/schema.sql`: немає таблиць лімітів/спроб)
- [x] Ядрові таблиці не змінюються
- [x] Назва `0004_kristal_rate_limit.{up,down}.sql`, `{{PREFIX}}`, `IF NOT EXISTS` / `IF EXISTS`
- [x] InnoDB, utf8mb4_general_ci, PK
- [x] `down` повністю повертає стан
- [x] Без FOREIGN KEY
- [x] Індекси: PK для гарячого запиту; `idx_window_start` для очищення; лівого префікса наявного не дублює
- [x] `status`-подібних самостійних індексів немає
- [ ] Після застосування: `make migrate`, `make db-check`, `make db-schema-diff` = лише ця таблиця, `make db-explain` для 3 запитів, `make migrate-down V=0004 && make migrate`, `make db-schema-snapshot`

## Запити та індекси
| Де викликається | Запит (скорочено) | Індекс | Очікуваний EXPLAIN |
|---|---|---|---|
| `Rate_limit::hit` (надсилання форми) | `INSERT … (key_hash, action, hits, window_start) VALUES (…, 1, NOW()) ON DUPLICATE KEY UPDATE hits = IF(window_start < NOW() - INTERVAL w SECOND, 1, hits + 1), window_start = IF(window_start < NOW() - INTERVAL w SECOND, NOW(), window_start)` | PRIMARY | вставка/оновлення за PK |
| `Rate_limit::hit` | `SELECT hits FROM … WHERE key_hash = '…'` | PRIMARY | `const`, rows 1 |
| `Rate_limit::hit`, 1 з 100 викликів | `DELETE FROM … WHERE window_start < NOW() - INTERVAL 1 DAY` | `idx_window_start` | `range` |
| `kristal_core::save` (адмінка) | `editSetting('module_kristal_core', …)` ядра | наявні | — |

Порядок присвоєнь в `ON DUPLICATE KEY UPDATE` важливий: MariaDB обчислює їх зліва направо, тому `hits` має стояти
перед `window_start` (інакше `hits` побачить уже оновлене вікно). Це покриває тест у `tests/lib/rate_limit_test.php`.

## Кешування
- `kristal.nap`: нормалізований масив контактів. Бере на себе `Kristal\Nap::get($registry)`; основний споживач — тема 003.
  Скидається `Cache_key::flush()` у `save()` (AC-9). Самі налаштування вже в `$this->config`, тому кеш прибирає тільки нормалізацію.
- Більше нічого не кешуємо.

## Вплив на швидкість і мобільний бюджет
- Вітрина: 0 нових запитів, 0 нових файлів CSS/JS/шрифтів (AC-11). `make db-profile` до/після на `/`, `/posud/tarilky`, картці — без змін.
- Надсилання форми (з 009): +2 запити за PK, +1 рідкісний DELETE.
- Telegram: до 5 с лише під час надсилання форми. У 023 переноситься після відповіді клієнту.
- Адмінка: стандартні Bootstrap 3 / jQuery ядра, без нових бібліотек.

## Ризики і відкат
| Ризик | Ймовірність | Що робимо |
|---|---|---|
| Хостинг блокує вихідні запити до `api.telegram.org` | Низька (зараз сторонній модуль працює) | Тестова кнопка покаже помилку cURL; запасний варіант — email у 023 |
| Мобільні оператори дають одну IP багатьом клієнтам → ліміт «з'їдає» живих | Середня | Ліміт рахуємо лише після honeypot+token; 5/год налаштовується; у тексті відмови — телефон |
| `session_id` змінюється між показом і надсиланням (вхід в акаунт) | Низька | Помилка `token` → форма показує «Оновіть сторінку»; у 009 перевіряємо сценарій входу |
| Ключі `module_kristal_core_*` обрізаються в `oc_setting.key` VARCHAR(128) | Немає | Найдовший ключ ~40 символів |
| Синхронізація в ядро затре поля `sauco` | Немає, якщо через `editSettingValue` | Тест: після збереження `config_custom_css` той самий |

Як відкотити: адмінка → Модулі → «Крістал: основне» → Видалити (налаштування прибрано) → `make migrate-down V=0004` →
видалити файли зі списку → `make clear-cache`.

## Зміни під час реалізації (2026-11-07)
- Збереження — стандартний POST + redirect (як `extension/module/html` ядра), а не AJAX: підсвітка полів (AC-2) без власного JS.
- `Kristal\Telegram` приймає токен у конструкторі; `send()` повертає `['ok', 'type' => config|network|api, 'error']`, тексти для людини — у мовному файлі адмінки.
- `Kristal\Nap`: `get($registry)` (з кешем), `fromConfig($config)`, `normalize(array)` (чиста функція для тестів і превʼю в адмінці).
- Графік — 3 рядки «дні + з/до», телефони — рівно 3 рядки у формі (без JS для додавання рядків).
- Перевірено в пісочниці агента (PHP 8.3 + Twig 3 з пакета 3.0.4.1, стаби реєстру): 24 сценарії контролера адмінки (AC-1…AC-6, AC-9, AC-10, XSS у полях) і 31 тест бібліотеки. Прогін під 7.3, тести з БД і ручне приймання — за людиною (`tasks.md`).
