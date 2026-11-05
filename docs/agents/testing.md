# Тестування

## Рівні

### 1. Синтаксис під PHP 7.3 — `make lint`
Перевіряє змінені `.php` у `src/` (відносно `git` HEAD + незакомічені) реальним `php:7.3-cli` у Docker.
`make lint ALL=1` — усі наші файли (`*kristal*` та тема `kristal`).
Ловить синтаксис 7.4+/8.x, якого прод не виконає.

### 2. Аудит БД — `make db-check`, `make db-schema-diff`
Див. `db-schema-checklist.md`.

### 3. Запити — `make db-explain`, `make db-profile`
Див. `query-performance.md`.

### 4. Smoke вітрини — `make test-smoke`
Файли:
- `tests/smoke/urls.txt` — `шлях очікуваний_код` (по рядку). Для кожної сторінки з кодом 200 перевіряється:
  рівно один `<h1`, є `<title>`, немає `Notice:`/`Warning:`/`Fatal error`/`Stack trace`,
  немає заглушок шаблону (`My Great Website`, `Site Content`), є `rel="canonical"` (попередження, не помилка).
- `tests/smoke/redirects.txt` — `старий_шлях новий_шлях` — очікується `301` і `Location`, що закінчується на новий шлях.

За замовчуванням бʼє в `http://localhost:$WEB_PORT`; інший сайт: `make test-smoke BASE=https://orendaposydy.com`.

### 4a. Мобільний аудит — `make test-mobile`
Один раз: `make mobile-setup` (Node.js 18+, ставить Playwright і Chromium у `tests/mobile/`).
Сторінки — `tests/mobile/pages.txt`, бюджети — `tests/mobile/budgets.json`, знімки екрана — `tests/mobile/out/`.
Деталі й чек-лист: `mobile.md`.

### 5. Приймання за специфікацією
Кожен критерій із `spec.md` має рядок у `tasks.md` розділі «Приймання» з тим, як перевірено:
smoke-URL, SQL-запит з очікуваним результатом, або ручний крок (екран, 375px, дія → результат).

### 6. E2E (пізніше)
Коли з'являться калькулятор і оформлення заявки — сценарії на Playwright у `tests/e2e/` (окрема специфікація).

## `make verify`
Запускає `lint` → `db-check` → `db-schema-diff` → `migrate-status` → `test-smoke` → `test-mobile`. Падіння будь-якого кроку = не готово.

## Звіт
Наприкінці фічі в `tasks.md` (і у відповіді агента):
```
Перевірено:
- make lint — OK (12 файлів)
- make db-check — без нових зауважень
- make db-profile URL=/mebli — 74 запити, макс 12 мс (бюджет 100 / 50)
- make test-smoke — 18/18 OK
- Ручне: 375px, кошик → заявка → лист у Mailpit — OK
```
