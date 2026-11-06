# 018 — звіт оновлення ядра 3.0.3.2 → 3.0.4.1

Згенеровано `make core-report` 2026-11-06 20:36. Не редагувати вручну.

| Що | Кількість |
|---|---|
| Файлів ядра 3.0.4.1 | 2256 |
| Спільних із src/ | 1327 |
| Нових у 3.0.4.1 | 929 |
| **Не копіюються** (core-keep.txt) | 64 |
| Буде скопійовано з ядра | 2192 |
| Файлів src/, яких немає в 3.0.4.1 | 1467 |
| — залишаються (KEEP) | 509 |
| — до видалення (REMOVE) | 952 |
| — вирішити вручну (REVIEW) | 6 |

## 1. Ручні правки ядра (src/ ≠ оригінальний 3.0.3.2)

Ці файли **за замовчуванням лишаються старими** (`core-keep.txt`): тема `sauco` бере з них дані.
Їх замінить тема `kristal` (003). Рядок у `core-keep.txt` можна прибрати, якщо правка не потрібна.

- `admin/controller/catalog/product.php` — 16 рядків різниці
- `admin/controller/common/column_left.php` — 910 рядків різниці
- `admin/controller/common/dashboard.php` — 32 рядків різниці
- `admin/controller/common/footer.php` — 2 рядків різниці
- `admin/controller/common/header.php` — 2 рядків різниці
- `admin/controller/extension/dashboard/recent.php` — 2 рядків різниці
- `admin/controller/sale/order.php` — 32 рядків різниці
- `admin/controller/setting/setting.php` — 38 рядків різниці
- `admin/index.php` — 3 рядків різниці
- `admin/model/catalog/product.php` — 18 рядків різниці
- `admin/view/stylesheet/stylesheet.css` — 6 рядків різниці
- `admin/view/template/catalog/product_form.twig` — 2085 рядків різниці
- `admin/view/template/common/header.twig` — 9 рядків різниці
- `admin/view/template/extension/payment/cod.twig` — 2 рядків різниці
- `admin/view/template/extension/shipping/flat.twig` — 4 рядків різниці
- `admin/view/template/extension/shipping/free.twig` — 2 рядків різниці
- `admin/view/template/extension/shipping/pickup.twig` — 2 рядків різниці
- `admin/view/template/sale/order_history.twig` — 2 рядків різниці
- `admin/view/template/sale/order_info.twig` — 210 рядків різниці
- `admin/view/template/sale/order_invoice.twig` — 26 рядків різниці
- `admin/view/template/sale/order_list.twig` — 11 рядків різниці
- `admin/view/template/setting/setting.twig` — 173 рядків різниці
- `catalog/controller/checkout/cart.php` — 4 рядків різниці
- `catalog/controller/common/cart.php` — 4 рядків різниці
- `catalog/controller/common/footer.php` — 140 рядків різниці
- `catalog/controller/common/header.php` — 226 рядків різниці
- `catalog/controller/common/home.php` — 2 рядків різниці
- `catalog/controller/extension/module/banner.php` — 14 рядків різниці
- `catalog/controller/extension/module/category.php` — 34 рядків різниці
- `catalog/controller/extension/module/featured.php` — 6 рядків різниці
- `catalog/controller/product/category.php` — 81 рядків різниці
- `catalog/controller/product/product.php` — 11 рядків різниці
- `catalog/controller/startup/seo_url.php` — 48 рядків різниці
- `catalog/model/catalog/product.php` — 2 рядків різниці
- `catalog/model/extension/payment/cod.php` — 10 рядків різниці
- `catalog/model/extension/shipping/flat.php` — 54 рядків різниці
- `catalog/model/extension/shipping/free.php` — 68 рядків різниці
- `catalog/model/extension/shipping/pickup.php` — 48 рядків різниці
- `catalog/model/extension/total/shipping.php` — 12 рядків різниці
- `catalog/view/javascript/common.js` — 10 рядків різниці
- `system/config/install.php` — 4 рядків різниці

## 1a. Навмисно вимкнені файли ядра (не повертаються)

- `catalog/controller/checkout/checkout.php`
- `catalog/controller/checkout/confirm.php`
- `catalog/controller/checkout/failure.php`
- `catalog/controller/checkout/guest.php`
- `catalog/controller/checkout/guest_shipping.php`
- `catalog/controller/checkout/login.php`
- `catalog/controller/checkout/payment_address.php`
- `catalog/controller/checkout/payment_method.php`
- `catalog/controller/checkout/register.php`
- `catalog/controller/checkout/shipping_address.php`
- `catalog/controller/checkout/shipping_method.php`
- `catalog/controller/common/column_left.php`
- `catalog/controller/common/column_right.php`
- `catalog/controller/common/currency.php`
- `catalog/controller/common/language.php`
- `catalog/controller/common/maintenance.php`
- `catalog/controller/common/search.php`
- `catalog/controller/information/contact.php`
- `catalog/controller/information/sitemap.php`
- `catalog/controller/product/compare.php`
- `catalog/controller/product/manufacturer.php`
- `catalog/controller/product/search.php`
- `catalog/controller/product/special.php`

## 2. Шаблони й код, несумісні з Twig 3

Не знайдено.

## 3. Вирішити вручну (REVIEW)

- `admin/language/uk-ua/extension/extension.php` — мовний файл без відповідника в ядрі, але маршрут 'extension/extension' використовується в ядрі 3.0.4.1 або в нашому коді
- `admin/language/uk-ua/extension/extension/promotion.php` — мовний файл без відповідника в ядрі, але маршрут 'extension/extension/promotion' використовується в ядрі 3.0.4.1 або в нашому коді
- `admin/language/uk-ua/mail/affiliate.php` — мовний файл без відповідника в ядрі, але маршрут 'mail/affiliate' використовується в ядрі 3.0.4.1 або в нашому коді
- `admin/view/image/payment/1.png` — не ядро 3.0.3.2 і не відомий модуль — вирішити вручну
- `catalog/language/uk-ua/information/tracking.php` — мовний файл без відповідника в ядрі, але маршрут 'information/tracking' використовується в ядрі 3.0.4.1 або в нашому коді
- `catalog/language/uk-ua/mail/order.php` — мовний файл без відповідника в ядрі, але маршрут 'mail/order' використовується в ядрі 3.0.4.1 або в нашому коді

## 4. До видалення (REMOVE) — за причинами

- OCMOD tweak (рішення 2026-11-06) — 2
- Twig 1.x з 3.0.3.2 (у 3.0.4.1 — Twig 3 у storage/vendor) — 186
- ru-ru: мова не встановлена (в oc_language лише uk-ua) — 286
- вимкнена копія (тека з «_» на початку) — 86
- вимкнена копія (файл з «_» на початку) — 27
- залишок видаленого стороннього модуля — 3
- мовний файл видаленого модуля (маршрут ніде не використовується) — 262
- службове сміття / резервні копії — 26
- файл ядра 3.0.3.2, видалений у 3.0.4.1 — 74

Повний список: `core-remove.txt` (переглянути; рядок можна видалити, щоб залишити файл).

## 5. Залишаються (KEEP) — за причинами

- Fondy (офіційний модуль провайдера) — 8
- Telegram-сповіщення (до 023) — 5
- мовний пакет uk-ua — 4
- оформлення замовлення теми sauco (до 010) — 3
- переклад файлу ядра — 360
- службове хостингу (переглянути в 017) — 1
- тема sauco (до 003) — 119
- файл сайту/хостингу — 9
