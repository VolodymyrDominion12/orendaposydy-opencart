# 023 — Задачі

Гілка `feature/023-notify`. **[агент]** — локально; **[людина]** — адмінка/прод.

## Кроки
- [x] **T1. [агент]** `\Kristal\Notify` (сигнатури вебхуків, HMAC, парсинг chat_id, форматування повідомлень, маскування) + юніт-тести — *перевірка:* `make test-lib T=notify` (7 OK).
- [x] **T2. [агент]** Міграція `0015_kristal_notify` (`oc_kristal_notify_log` + реєстрація подій `addOrderHistory` та `addOrder`) — *перевірка:* `make migrate`, `make migrate-down V=0015 && make migrate`, `make db-explain`, `make db-schema-snapshot`.
- [x] **T3. [агент]** Модель та контролер адмінки `extension/module/kristal_notify`:
  - Налаштування каналів (Telegram, Email, Webhook).
  - Тестова відправка в кожен канал (AJAX `testTelegram`, `testEmail`, `testWebhook`).
  - Перегляд журналу відправок (`getLogs`) та повторна відправка (`retry`).
  - Перенесення конфігурації зі старого модуля `notifications_in_telegram` (`importLegacy`).
- [x] **T4. [агент]** Шаблон адмінки `kristal_notify.twig` та мовний файл `uk-ua`:
  - Вкладки (Загальні, Telegram, Email, Webhook, Журнал).
  - Маскування токенів, статуси каналів, бейджі журналу.
- [x] **T5. [агент]** Каталог: контролер і модель подій `extension/kristal/notify`:
  - Обробник подій `onOrderHistory` та `onOrder` (відправка сповіщень при створенні/оновленні замовлення).
  - Захист від дублів відправки одного й того самого замовлення.
  - Метод `sendLead($lead_id, $lead)` для майбутньої фічі 009.
  - Форматування тексту з товарами, датами, сумами, способами доставки та оплати.
  - *перевірка:* емуляція створення замовлення/ліда в контейнері, перевірка появи запису в `oc_kristal_notify_log` та Mailpit (для email).
- [x] **T6. [агент]** Повна перевірка та документація:
  - `make lint` (PHP 7.3 + 8.3 OK).
  - `make test-lib` (81 OK, 0 FAIL).
  - `make test-smoke` (37 OK, 0 FAIL).
  - Оновлення `specs/BACKLOG.md` та `AGENTS.md`.
- [ ] **T7. [людина]** Прод: міграція `make migrate-print V=0015` → phpMyAdmin, деплой `make deploy-apply`, перевірка тестового сповіщення в адмінці, вимкнення старого модуля.

## Приймання
- [x] `make lint` — 7.3 і 8.3 OK
- [x] `make test-lib` — 81 OK, 0 FAIL (нові: `notify_test`, 7 тестів)
- [x] `make db-explain` — 3 запити з `plan.md` без зауважень
- [x] `make migrate-down V=0015 && make migrate` — без помилок
- [x] `make test-smoke` — 37 OK, 0 FAIL
- [x] AC-1…AC-10 — підтверджено локально (Telegram-тести, Email у Mailpit, Webhook HMAC, журнал відправок, захист від дублів)
