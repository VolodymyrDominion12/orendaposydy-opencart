# 006 — Задачі реалізації

- [x] **T1. Контролер та мовні файли для 4 типів подій**
  - [x] Оновити `src/catalog/language/uk-ua/extension/kristal/kit.php` текстами для `buffet`, `catering`, `corporate`.
  - [x] Оновити `src/catalog/controller/extension/kristal/kit.php` методами `buffet()`, `catering()`, `corporate()`.
  - [x] Додати генерацію FAQ та Schema.org `FAQPage` JSON-LD у контролері.
- [x] **T2. Міграція бази даних `0022_kristal_event_pages`**
  - [x] Додати SEO URL для нових подій (`furshet`, `keiterynh`, `korporatyv`).
  - [x] Засіяти комплекти для нових типів подій.
  - [x] Запустити `make migrate`, `make db-check`, `make db-schema-diff`.
- [x] **T3. Шаблон `event.twig`**
  - [x] Додати вивід FAQ-блоку у `src/catalog/view/theme/kristal/template/extension/kristal/event.twig`.
- [x] **T4. Верифікація**
  - [x] Додати URL у `tests/smoke/urls.txt`.
  - [x] Запустити `make test-smoke`, `make test-lib`, `make lint ALL=1`.
