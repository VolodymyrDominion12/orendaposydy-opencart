# Завдання: 008 kristal_calculator

## Етапи виконання

- [x] **T1. База даних та міграції**
  - [x] Створити `db/migrations/0019_kristal_calculator.up.sql` (таблиця `oc_kristal_calc_norm`, базові норми посуду, приборів і скла, SEO URL `kalkulyator`, подія меню адмінки).
  - [x] Створити `db/migrations/0019_kristal_calculator.down.sql`.
  - [x] Застосувати міграцію, протестувати rollback та повторне застосування.
  - [x] Оновити знімок схеми БД (`make db-schema-snapshot`).

- [x] **T2. Каталог: модель, контролер, мовні файли**
  - [x] Створити `src/catalog/language/uk-ua/extension/kristal/calculator.php`.
  - [x] Створити `src/catalog/model/extension/kristal/calculator.php` (вибірка норм, розрахунок кількості з урахуванням 10% запасу та розміру упаковки, зв'язок з цінами товарів).
  - [x] Створити `src/catalog/controller/extension/kristal/calculator.php` (сторінка `index`, AJAX `calculate`, AJAX `add` для кошика).

- [x] **T3. Вітрина: шаблон, скрипти, стилі**
  - [x] Створити `src/catalog/view/theme/kristal/template/extension/kristal/calculator.twig` за макетом `06-calculator.html`.
  - [x] Створити `src/catalog/view/theme/kristal/js/kristal-calc.js` (реактивний розрахунок, обробка «Все в кошик», скрол та передача параметрів у лід-форму).
  - [x] Додати необхідні стилі калькулятора у `src/catalog/view/theme/kristal/stylesheet/kristal.css` з дотриманням тач-таргетів >= 44×44px.

- [x] **T4. Адмінпанель: керування нормами**
  - [x] Створити `src/admin/language/uk-ua/extension/kristal/calculator.php`.
  - [x] Створити `src/admin/model/extension/kristal/calculator.php` (CRUD для `oc_kristal_calc_norm`).
  - [x] Створити `src/admin/controller/extension/kristal/calculator.php` (список норм, додавання/редагування, обробник події `menu`).
  - [x] Створити шаблони `src/admin/view/template/extension/kristal/calculator_list.twig` та `calculator_form.twig`.

- [x] **T5. Тестування та перевірка якості**
  - [x] Додати `/kalkulyator` у `tests/smoke/urls.txt` та `tests/mobile/pages.txt`.
  - [x] Запустити `make lint` та перевірити відсутність помилок синтаксису (PHP 7.3 + 8.3 OK).
  - [x] Запустити `make test-lib` (109 OK).
  - [x] Запустити `make test-smoke` та `make test-mobile` (13 сторінок, 0 overflow, 0 tap_small).
  - [x] Запустити `make db-profile URL=/kalkulyator` (HTTP 200 за 0.14 с, 98 запитів ≤ 100, сумарно 12.4 мс ≤ 50 мс).
  - [x] Запустити `make verify` (повністю зелений).

- [x] **T6. Документація та фіксація**
  - [x] Оновити `specs/BACKLOG.md` (позначити статус фічі 008 як Done).
  - [x] Закомітити зміни з префіксом `008:`.
