# 015 — Задачі реалізації

- [x] **T1. Міграція `0024_kristal_analytics`**
  - [x] Створити `db/migrations/0024_kristal_analytics.up.sql` та `down.sql`.
  - [x] Запустити `make migrate`.
- [x] **T2. Адмінка модуля kristal_analytics**
  - [x] Створити `src/admin/controller/extension/module/kristal_analytics.php`.
  - [x] Створити `src/admin/view/template/extension/module/kristal_analytics.twig`.
  - [x] Створити `src/admin/language/uk-ua/extension/module/kristal_analytics.php`.
- [x] **T3. Вітрина та клієнтський JS**
  - [x] Створити `src/catalog/view/theme/kristal/js/kristal-analytics.js`.
  - [x] Інтегрувати ініціалізацію GTM/Consent Mode у `src/catalog/view/theme/kristal/template/common/header.twig`.
  - [x] Додати скрипт банера згоди у `src/catalog/view/theme/kristal/template/common/footer.twig`.
- [x] **T4. Верифікація**
  - [x] Запустити `make test-smoke`, `make test-lib`, `make lint ALL=1`.
