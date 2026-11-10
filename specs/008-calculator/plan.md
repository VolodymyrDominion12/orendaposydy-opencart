# План реалізації: 008 kristal_calculator

## Стек та архітектурні рішення
1. **База даних:**
   - Міграція `0019_kristal_calculator.up.sql` / `.down.sql`.
   - Таблиця `oc_kristal_calc_norm` для збереження норм на гостя, правил і зв'язку з товарами каталогу.
   - Запис SEO URL `extension/kristal/calculator` -> `kalkulyator`.
   - Подія меню адмінки `kristal_calc_menu` (`admin/view/common/column_left/before` -> `extension/kristal/calculator/menu`).
2. **Каталог (вітрина):**
   - Модель `catalog/model/extension/kristal/calculator.php`:
     - Отримання активних норм з БД із прив'язкою до цін з `oc_product`.
     - Метод `calculate($guests, $format, $dishes, $drinks, $series)` для серверного обчислення або верифікації.
     - Метод пакетного додавання в кошик `cart`.
   - Контролер `catalog/controller/extension/kristal/calculator.php`:
     - `index()`: рендеринг сторінки, передача вихідних даних для норм та початкового стану.
     - `calculate()`: AJAX JSON ендпоінт для динамічного перерахунку.
     - `add()`: AJAX POST ендпоінт для додавання всього розрахованого комплекту до кошика `cart`.
   - Шаблон `catalog/view/theme/kristal/template/extension/kristal/calculator.twig`:
     - Точна відповідність макету `design/pages/06-calculator.html`.
     - Повзунок гостей, сегменти формату та страв, напої, серія.
     - Таблиця розрахунку та панель з кнопками «Все в кошик» і «Надіслати менеджеру».
     - Інтегрований блок лід-форми `kristal_lead` з автозаповненням.
   - JS `catalog/view/theme/kristal/js/kristal-calc.js`:
     - Реактивний розрахунок на подіях `input` / `change` без затримок.
     - Обробка кліку «Все в кошик» (AJAX POST, спінер/стан кнопки, оновлення лічильника кошика в шапці/таббарі, перехід до кошика або сповіщення).
     - Обробка кліку «Надіслати менеджеру» (скрол до форми ліда, заповнення гостей та суми/складу у приховані/текстові поля форми).
   - Стилі в `catalog/view/theme/kristal/stylesheet/kristal.css`:
     - Класи `.k-calc`, `.k-slider`, `.k-calc__table`, `.k-calc__total`.
     - Габарити інтерактивних елементів >= 44×44px для проходження мобільного аудиту.
3. **Адмінка:**
   - Модель `admin/model/extension/kristal/calculator.php`:
     - `getNorms()`, `getNorm($norm_id)`, `addNorm($data)`, `editNorm($norm_id, $data)`, `deleteNorm($norm_id)`.
   - Контролер `admin/controller/extension/kristal/calculator.php`:
     - Перегляд списку норм, фільтрація.
     - Додавання та редагування норми.
     - Меню в лівій колонці «Каталог → Норми калькулятора».
   - Мовний файл `admin/language/uk-ua/extension/kristal/calculator.php`.
   - Шаблони `admin/view/template/extension/kristal/calculator_list.twig` та `calculator_form.twig`.
4. **Якість та верифікація:**
   - Додавання `/kalkulyator` у `tests/smoke/urls.txt` та `tests/mobile/pages.txt`.
   - `make lint` — відсутність синтаксичних та PHP/Twig помилок.
   - `make test-lib` — перевірка бібліотек.
   - `make test-smoke` — перевірка HTTP 200 для `/kalkulyator`.
   - `make test-mobile` — 0 overflow, 0 tap_small на 360px.
   - `make db-profile URL=/kalkulyator` — дотримання бюджету запитів.
   - `make verify` — повний цикл автоматичних перевірок.
