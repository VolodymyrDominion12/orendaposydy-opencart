# 007 — План реалізації («Крістал: комплекти», `kristal_kit`)

## 1. Схема БД та міграція
- Створити `db/migrations/0018_kristal_kit.up.sql` та `.down.sql`:
  - Таблиця `oc_kristal_kit` (поля: `kit_id`, `code`, `event_type`, `tier`, `name`, `badge`, `discount_pct`, `features`, `sort_order`, `status`, `created_at`).
  - Таблиця `oc_kristal_kit_item` (поля: `kit_id`, `product_id`, `qty_per_guest`, `qty_fixed`, `sort_order`).
  - Початкові дані (3 комплекти для весілля: `wedding_basic`, `wedding_standard`, `wedding_premium`) з прив'язкою до товарів каталогу `50001`...`50082`.
  - Запис SEO URL `vesillya` -> `extension/kristal/kit/event&event=wedding` у `oc_seo_url`.
  - Подія меню адмінки `kristal_kit_menu` -> `extension/kristal/kit/menu`.
- Застосувати міграцію, перевірити відкат, зняти знімок `db/schema.sql`.

## 2. Моделі та контролери каталогу
- Модель `src/catalog/model/extension/kristal/kit.php`:
  - `getKits($event_type)`: завантажує активні комплекти, товари зі складу та обчислює ціну за гостя.
  - `getKit($kit_id)`: повертає дані одного комплекту та його позиції.
  - `calculateKitItems($kit_id, $guests)`: повертає масив `array('product_id' => ..., 'quantity' => ...)` для додавання в кошик.
- Контролер `src/catalog/controller/extension/kristal/kit.php`:
  - `event()`: сторінка події (за макетом `04-event.html`), рендеринг сторінки `extension/kristal/event`.
  - `add()`: AJAX-додавання комплекту на N гостей у кошик.
  - `block()`: вбудовуваний віджет блоку комплектів для повторного використання на будь-якій іншій сторінці.
- Мовний файл `src/catalog/language/uk-ua/extension/kristal/kit.php`.

## 3. Шаблони та скрипти вітрини
- Шаблон `src/catalog/view/theme/kristal/template/extension/kristal/event.twig`:
  - Hero весілля, секція `#sets` (комплекти з перемикачем 50/100/200 гостей), блок додаткових послуг («Все, крім гостей»), галерея, відгуки, FAQ, блок форми `#lead`.
- Скрипт `src/catalog/view/theme/kristal/js/kristal-kit.js`:
  - Перемикання радіокнопок кількості гостей із миттєвим перерахунком цін на картках.
  - AJAX-відправка форми додавання комплекту в кошик (`extension/kristal/kit/add`).
  - Оновлення лічильника кошика та показ індикації.
- Стилі у `src/catalog/view/theme/kristal/stylesheet/kristal.css` (якщо чогось не вистачає з макету: `.k-ehero`, `.k-sets`, `.k-set`, `.k-set--best`, `.k-guests`, `.k-addons`, `.k-addon`, `.k-gallery-strip`, `.k-faq`).

## 4. Адмінка «Крістал: комплекти»
- Модель `src/admin/model/extension/kristal/kit.php`:
  - CRUD для комплектів та їх елементів.
- Контролер `src/admin/controller/extension/kristal/kit.php`:
  - Список `index()`, форма редагування `form()`, збереження `save()`, видалення `delete()`, меню `menu()`.
  - Права доступу `access`/`modify` на `extension/kristal/kit`.
- Шаблони `src/admin/view/template/extension/kristal/kit_list.twig` та `kit_form.twig`.
- Мовний файл `src/admin/language/uk-ua/extension/kristal/kit.php`.

## 5. Тестування та перевірки якості
- Перевірка перерахунку цін на 50, 100, 200 гостей на `/vesillya`.
- Пакетне додавання комплекту в кошик та перевірка коректності позицій у `/order`.
- Відправка ліда з форми сторінки весілля.
- `make lint`, `make test-lib`, `make test-smoke`, `make test-mobile`, `make verify`.
