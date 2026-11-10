# 023 — План реалізації (`kristal_notify`)

## 1. Архітектура і файли

### Файли для створення / зміни
```
src/
├── system/library/kristal/notify.php               # Служба сповіщень: форматування, надсилання в канали, HMAC, маскування
├── admin/controller/extension/module/kristal_notify.php # Адмінка: налаштування, тести, журнал, повтор
├── admin/model/extension/kristal/notify.php        # Робота з журналом, очищення старих записів, повтор
├── admin/view/template/extension/module/kristal_notify.twig # Вкладки: Канали, Налаштування, Журнал
├── admin/language/uk-ua/extension/module/kristal_notify.php # Мовний файл інтерфейсу
├── catalog/controller/extension/kristal/notify.php # Слухач подій ядра (addOrderHistory)
└── catalog/model/extension/kristal/notify.php      # Форматування даних замовлення/ліда
db/migrations/
├── 0015_kristal_notify.up.sql                      # Таблиця oc_kristal_notify_log + реєстрація події
└── 0015_kristal_notify.down.sql
tests/lib/
└── notify_test.php                                 # Тести бібліотеки: підпис HMAC, форматування, роутинг чатів
specs/023-notify/
├── spec.md
├── plan.md
└── tasks.md
```

## 2. База даних та міграція

Таблиця `{{PREFIX}}kristal_notify_log`:
```sql
CREATE TABLE IF NOT EXISTS `{{PREFIX}}kristal_notify_log` (
  `log_id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `channel` VARCHAR(16) NOT NULL COMMENT 'telegram, email, webhook',
  `event_type` VARCHAR(32) NOT NULL COMMENT 'order, lead, test',
  `entity_id` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'order_id або lead_id',
  `recipient` VARCHAR(191) NOT NULL COMMENT 'chat_id, email, url',
  `status` ENUM('sent', 'failed') NOT NULL DEFAULT 'sent',
  `attempts` TINYINT UNSIGNED NOT NULL DEFAULT 1,
  `error` VARCHAR(255) NULL,
  `summary` VARCHAR(255) NULL COMMENT 'короткий опис без персональних даних',
  `created_at` DATETIME NOT NULL,
  `updated_at` DATETIME NOT NULL,
  INDEX `idx_status_attempts` (`status`, `attempts`),
  INDEX `idx_created` (`created_at`),
  INDEX `idx_entity` (`event_type`, `entity_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
```

### Чек-лист схеми БД (згідно з `AGENTS.md` §4)
- [x] Лише міграція `0015_kristal_notify.up.sql` + `.down.sql`.
- [x] Ідемпотентна (`CREATE TABLE IF NOT EXISTS`, `DROP TABLE IF EXISTS`).
- [x] `ENGINE=InnoDB`, `utf8mb4_general_ci`, PK обов'язковий (`log_id`).
- [x] Усі `*_id` та поля `WHERE` / `ORDER BY` мають індекси.
- [x] Без зачіпання ядрових таблиць (лише запис у `oc_event`).

### Запити та індекси (EXPLAIN)
1. **Вибірка останніх записів журналу для адмінки:**
   `SELECT * FROM oc_kristal_notify_log ORDER BY log_id DESC LIMIT 50;`
   -> PK scan, type `index`, `rows=50`.
2. **Фільтр за статусом помилок:**
   `SELECT * FROM oc_kristal_notify_log WHERE status = 'failed' ORDER BY log_id DESC LIMIT 50;`
   -> `idx_status_attempts`.
3. **Повторна спроба відправки:**
   `UPDATE oc_kristal_notify_log SET status = 'sent', attempts = attempts + 1, updated_at = NOW() WHERE log_id = ...;`
   -> по `PRIMARY` key.

## 3. Події OpenCart (`oc_event`)
- **Тригер:** `model/checkout/order/addOrderHistory/after`
- **Дія:** `extension/kristal/notify/onOrderHistory`
- Коли статус замовлення змінюється на новий або підтверджений (за замовчуванням `order_status_id > 0`), перевіряється, чи сповіщення про цей `order_id` вже надсилалось (запобігання дублям через `oc_kristal_notify_log`).

## 4. Канали відправки
1. **Telegram:**
   - Використовує наявний `\Kristal\Telegram`.
   - Розбір кількох `chat_id` (розділювачі: кома, пробіл, новий рядок).
   - Екранування HTML через `\Kristal\Telegram::escape()`.
2. **Email:**
   - Використовує `new \Mail($this->config->get('config_mail_engine'))`.
   - Налаштування: адреса отримувача (можна кілька через кому), префікс теми.
3. **Webhook:**
   - HTTP POST на зовнішній URL із таймаутом 3–5 секунд.
   - Заголовок `X-Kristal-Signature: sha256=<hmac_sha256>`.
   - JSON-тіло містить:
     ```json
     {
       "event": "order.created",
       "timestamp": 1731234567,
       "entity_id": 123,
       "data": { ... }
     }
     ```

## 5. Безпека
- Захист від витоку токенів: токен бота в адмінці показується маскованим (якщо збережений — `123456:ABC...***`).
- Журнал не містить відкритих конфіденційних даних: поле `summary` зберігає лише загальну статистику ("Замовлення #105: 4 позиції, 1 200 ₴").
- Немає блокування вітрини: збої зовнішніх API перехоплюються, статус `failed` пишеться в БД, сесія покупця не падає.

## 6. Як відкотити
- `make migrate-down V=0015` — видаляє таблицю `oc_kristal_notify_log` та знімає подію з `oc_event`.
- Видалити створені файли модуля.
