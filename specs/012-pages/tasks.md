# 012 — Задачі реалізації

- [x] **T1. Міграція бази даних `0023_kristal_info_pages`**
  - [x] Оновити сторінки 4 («Про нас»), 5 («Умови оренди»), 6 («Доставка та оплата»).
  - [x] Додати нові сторінки 13 («Для бізнесу») та 14 («FAQ»).
  - [x] Додати SEO URLs (`pro-nas`, `umovy-orendy`, `dostavka-ta-oplata`, `dlia-biznesu`, `faq`, `kontakty`).
  - [x] Додати 301-редиректи зі старих URL в `oc_kristal_redirect`.
  - [x] Запустити `make migrate`, `make db-check`, `make db-schema-diff`.
- [x] **T2. Контролер контактів `information/contact`**
  - [x] Створити `src/catalog/controller/information/contact.php`.
  - [x] Інтегрувати антиспам `kristal_core` та сповіщення.
  - [x] Додати розмітку `LocalBusiness` JSON-LD.
- [x] **T3. Шаблони теми `kristal`**
  - [x] Оновити `src/catalog/view/theme/kristal/template/information/information.twig`.
  - [x] Створити `src/catalog/view/theme/kristal/template/information/contact.twig`.
- [x] **T4. Верифікація**
  - [x] Оновити `tests/smoke/urls.txt` та `tests/smoke/redirects.txt`.
  - [x] Запустити `make test-smoke`, `make test-lib`, `make lint ALL=1`.
