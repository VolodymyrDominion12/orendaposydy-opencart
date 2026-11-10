# 010 — План реалізації (`kristal_checkout`)

Посилання на [spec.md](file:///home/volodymyr/PycharmProjects/orendaposydy-opencart/specs/010-checkout/spec.md).

## Підхід
1. **Єдина сторінка «Кошик події»** за адресою `/order` (маршрут `checkout/order` з наявним ЧПУ `order`):
   - Замінюємо застарілий контролер теми `sauco` (`catalog/controller/checkout/order.php`) на чистий, легкий контролер без сторонніх залежностей.
   - Створюємо новий шаблон `catalog/view/theme/kristal/template/checkout/order.twig` на основі макету `design/pages/05-cart.html`.
   - Жодного jQuery чи Bootstrap: чистий ванільний JS `catalog/view/theme/kristal/js/kristal-checkout.js`.
2. **Ліквідація 404 та редиректи:**
   - Створюємо контролер `checkout/checkout.php`, який виконує 302-редирект на `checkout/order` (вирішує пункт беклогу #60).
   - Контролер `checkout/cart.php` перенаправляє або повертає вміст `checkout/order`.
   - У `extension/kristal/theme.php` посилання кошика `k_cart_href` веде на `checkout/order`.
3. **Орендна специфіка в замовленні:**
   - Таблиця `oc_kristal_order_rental` фіксує дати оренди (`date_from`, `date_to`), тривалість (`rental_days`), спосіб отримання (`delivery_type`, `delivery_address`), канал зв'язку (`contact_channel`) та реквізити юрособи (`company_name`, `edrpou`).
   - Під час оформлення замовлення стандартно створюється запис у `oc_order` через `model_checkout_order->addOrder()`, а орендні атрибути зберігаються у `oc_kristal_order_rental`.
4. **Способи оформлення:**
   - «Заявка без оплати» (основний сценарій): створення замовлення зі статусом 1 («Нове замовлення»), очищення кошика, відправка сповіщення через `023 kristal_notify`, редирект на `/success`.
   - «Оплата карткою Fondy»: перехід на захищену сторінку Fondy (`oplata`).
5. **Адмінка:**
   - Подія `admin/view/sale/order_info/after` (`extension/kristal/checkout/orderInfo`) додає блок «Параметри оренди» на сторінці перегляду замовлення в адмінці без редагування ядра.

---

## Файли

| Файл | Новий / зміна | Що |
|---|---|---|
| `db/migrations/0016_kristal_checkout.up.sql` | Новий | Створення таблиці `oc_kristal_order_rental` + реєстрація події адмінки |
| `db/migrations/0016_kristal_checkout.down.sql` | Новий | Відкат таблиці та події |
| `src/catalog/controller/checkout/order.php` | Зміна (заміна) | Контролер кошика події: перегляд, AJAX-оновлення кількості, видалення, збереження замовлення |
| `src/catalog/controller/checkout/checkout.php` | Новий | 302-редирект на `checkout/order` (ліквідація 404) |
| `src/catalog/model/extension/kristal/checkout.php` | Новий | Робота з таблицею `oc_kristal_order_rental` (збереження та вибірка) |
| `src/catalog/view/theme/kristal/template/checkout/order.twig` | Новий | Шаблон сторінки «Кошик події» за макетом `05-cart.html` |
| `src/catalog/view/theme/kristal/js/kristal-checkout.js` | Новий | Ванільний JS: AJAX зміни кількості, перерахунок діб/сум, валідація форми, маска телефону |
| `src/catalog/language/uk-ua/checkout/order.php` | Зміна | Оновлені тексти для української локалізації кошика події |
| `src/catalog/controller/extension/kristal/theme.php` | Зміна | `k_cart_href` вказує на `checkout/order` |
| `src/admin/controller/extension/kristal/checkout.php` | Новий | Обробник події `order_info/after`: блок параметрів оренди в адмінці |
| `src/admin/model/extension/kristal/checkout.php` | Новий | Вибірка орендних даних замовлення в адмінці |
| `src/admin/language/uk-ua/extension/kristal/checkout.php` | Новий | Тексти блоку оренди для адмінки |

### Події `oc_event`
| Механізм | Тригер | Дія | Навіщо |
|---|---|---|---|
| Подія | `admin/view/sale/order_info/after` | `extension/kristal/checkout/orderInfo` | Відображення блоку «Параметри оренди» в картці замовлення адмінки |

---

## Міграції БД

| Версія | Що | down |
|---|---|---|
| 0016 | Таблиця `{{PREFIX}}kristal_order_rental` + подія `admin/view/sale/order_info/after` | Видалення таблиці та події |

### Схема таблиці `oc_kristal_order_rental`
```sql
CREATE TABLE IF NOT EXISTS `{{PREFIX}}kristal_order_rental` (
  `order_id` INT(11) NOT NULL PRIMARY KEY,
  `date_from` DATE NOT NULL,
  `date_to` DATE NOT NULL,
  `rental_days` INT(11) NOT NULL DEFAULT 1,
  `delivery_type` VARCHAR(16) NOT NULL DEFAULT 'delivery',
  `delivery_address` VARCHAR(255) NOT NULL DEFAULT '',
  `contact_channel` VARCHAR(32) NOT NULL DEFAULT 'viber',
  `is_company` TINYINT(1) NOT NULL DEFAULT 0,
  `company_name` VARCHAR(255) NOT NULL DEFAULT '',
  `edrpou` VARCHAR(32) NOT NULL DEFAULT '',
  `created_at` DATETIME NOT NULL,
  `updated_at` DATETIME NOT NULL,
  INDEX `idx_dates` (`date_from`, `date_to`),
  INDEX `idx_created` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
```

### Чек-лист схеми БД (`docs/agents/db-schema-checklist.md`)
- [x] Лише міграція `0016_kristal_checkout.up.sql` + `.down.sql`.
- [x] Ідемпотентна (`CREATE TABLE IF NOT EXISTS`, `DROP TABLE IF EXISTS`).
- [x] `ENGINE=InnoDB`, `utf8mb4_general_ci`, PK обов'язковий (`order_id`).
- [x] Поля пошуку та дат мають індекси.
- [x] Ядрові таблиці не модифікуються.

---

## Запити та індекси

| Де викликається | Запит (скорочено) | Індекс | EXPLAIN type / rows |
|---|---|---|---|
| Оформлення замовлення | `INSERT INTO oc_kristal_order_rental VALUES (...)` | `PRIMARY` | — |
| Перегляд замовлення в адмінці | `SELECT * FROM oc_kristal_order_rental WHERE order_id = ?` | `PRIMARY` | `const`, 1 row |
| Хіти для порожнього кошика | `SELECT ... FROM oc_product p JOIN oc_kristal_product_rental r ... WHERE r.is_hit = 1 LIMIT 4` | `idx_is_hit` / PK | `ref`, ~4 rows |

---

## Вплив на швидкість і мобільний бюджет
- **Мобільний бюджет:**
  - Шаблон сторінки `/order` повністю переходить на токени теми `kristal`.
  - Відмовляємось від старих скриптів `sauco` (jQuery, Bootstrap js/css, Simple js).
  - Скрипт `kristal-checkout.js` — ванільний JS вагою < 8 КБ (Gzip ~2.5 КБ).
  - Усі тач-зони кнопок кількості, радіо-карток та полів введення ≥ 44×44px.
  - Поля вводу мають належні `type="tel"`, `autocomplete`, `inputmode`.
  - Відсутність горизонтального скролу на ширині 360px.
- **Бюджет запитів БД:**
  - Відображення кошика: ≤ 15 запитів (дані товарів, знижки, контакти НАП з кешу).
  - Створення замовлення: ≤ 20 запитів (стандартний OpenCart order insert + rental row + notify log).

---

## Ризики і відкат
| Ризик | Ймовірність | Що робимо |
|---|---|---|
| Замовлення з датами в минулому або некоректний розрахунок діб | Низька | Сувора валідація на клієнті (min=сьогодні, max) + валідація на сервері в `checkout/order/save` |
| Помилка надсилання сповіщення блокує завершення замовлення | Низька | `kristal_notify` працює асинхронно/ізольовано та перехоплює винятки |
| Користувач переходить за старими URL кошика (`/index.php?route=checkout/checkout`) | Середня | Створено контролер `checkout/checkout.php` з 302-редиректом на `/order` |

**Як відкотити:**
- `make migrate-down V=0016`
- Повернення попередньої версії контролера `checkout/order.php`
- `make clear-cache`
