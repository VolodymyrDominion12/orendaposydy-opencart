# 004 — План реалізації

Посилання: `spec.md`. Погоджено 2026-11-08 («на твій розсуд» → пропозиції агента).

## Підхід
Шаблон `common/home.twig` у темі `kristal` (compat 003 для `/` вимикається сам). Дані — подія `view/common/home/before` → `extension/kristal/home`:
налаштування `module_kristal_home_*` з `$this->config` (0 запитів), меню й мінімальні ціни категорій (кеш), хіти через моделі 005 (`is_hit` → `getProducts/getDiscounts`),
зображення через `media` (020). Title/description/canonical треба поставити до того, як контролер ядра збере шапку (`$data['header']`
рендериться раніше за сам шаблон), тому — подія `controller/common/home/before` через `$this->document`. Адмін-модуль «Крістал: головна» — `extension/module/kristal_home`
(index/save/install/uninstall, як `kristal_core` у 019).

## Файли
| Файл | Новий / зміна | Що |
|---|---|---|
| `catalog/view/theme/kristal/template/common/home.twig` | новий | hero, плитки, хіти, кроки, цифри, FAQ, SEO-текст, контакт |
| `catalog/controller/extension/kristal/home.php` | новий | `meta()` (controller/common/home/before), `view()` (view/common/home/before) |
| `catalog/model/extension/kristal/catalog.php` | зміна | `getHitIds($limit)`, `getMinPrices($category_ids)` — пакетом з кешем |
| `catalog/language/uk-ua/extension/kristal/home.php` | новий | кроки, підписи блоків |
| `admin/controller/extension/module/kristal_home.php`, `admin/view/template/extension/module/kristal_home.twig`, `admin/language/uk-ua/extension/module/kristal_home.php` | новий | форма налаштувань |
| `catalog/view/theme/kristal/stylesheet/kristal.css` | зміна | hero, плитки, кроки, цифри (з `design/` 01) |
| `catalog/controller/extension/module/banner.php` | **повернення до 3.0.4.1** | питання 2; `core-keep.txt` |
| `db/migrations/0008_kristal_home.*` | новий | події; модулі головної з макета → бекап і видалення з `layout_module`; down — повернути |
| `db/migrations/0009_mock_home.*` | новий | мок-налаштування головної (тексти, цифри, FAQ, SEO-текст) |
| `tests/mobile/pages.txt`, `tests/smoke/urls.txt` | зміна | `/` без `allow` |

## Міграції БД
| Версія | Що | down |
|---|---|---|
| `0008_kristal_home` | 2 події; `oc_layout_module` головної (layout_id 1, 4 рядки) → `kristal_layout_backup` і видалення; `oc_extension` module/kristal_home | повернути рядки, прибрати події й розширення |
| `0009_mock_home` | `module_kristal_home_*` у `oc_setting` (мок) | видалити ці налаштування |

## Запити та індекси
| Де | Запит | Індекс | EXPLAIN |
|---|---|---|---|
| хіти | `SELECT r.product_id FROM kristal_product_rental r JOIN product p … WHERE r.is_hit = 1 AND p.status = 1 … ORDER BY p.sort_order LIMIT 8` | `idx_is_hit` (005) | перевірити |
| «від N ₴» усіх верхніх категорій | один `SELECT cp.path_id, MIN(p.price) … WHERE cp.path_id IN (…) GROUP BY cp.path_id`, кеш `kristal.catalog.min.*` | як у 005 | перевірити |
| картки хітів | `getProducts/getDiscounts` 005 | PK | як у 005 |

## Кешування
`kristal.home.<store>` — ідентифікатори хітів і мінімальні ціни; скидається збереженням товару/категорії (005/003 — весь `kristal.*`) і модуля головної.

## Вплив на швидкість і мобільний бюджет
Головна втрачає jQuery, Bootstrap, swiper, Font Awesome і 2 банери (зараз JS 84 КБ, TBT до 424 мс) → очікуємо як інші сторінки теми: JS 5 КБ, TBT < 150 мс.
Плитки: 11 зображень TILE 480/960 WebP, lazy (крім перших 2). Запити: хіти + оренда + знижки + (холодний кеш) мінімальні ціни.

## Ризики і відкат
| Ризик | Ймовірність | Що робимо |
|---|---|---|
| Клієнт хоче повернути банер-слайдер | середня | down 0008 повертає модулі; у темі для них немає місця — окрема задача |
| Title/description з модуля не підхопились (порядок подій) | низька | перевірка AC-9 у smoke (title) |

Відкат: `make migrate-down V=0009 && make migrate-down V=0008`, `git revert`, `make clear-cache`.

## Відхилення від чернетки (2026-11-08)
- **Title/description/canonical** — подія `controller/common/header/before` (а не `controller/common/home/before`): контролер головної ядра сам ставить title з налаштувань магазину й перезаписав би наш.
- **Плитки категорій — з іконками** теми, як у макеті; фото категорій і розмір TILE не потрібні.
- **Хіти** — `extension/kristal/catalog/cards` (новий публічний метод 005) + кеш карток `kristal.home.hits.*`; з теплим кешем головна не робить власних запитів.
- **Модуль вимкнено** (`status = 0`) — тексти теми за замовчуванням, без цифр/FAQ/SEO-тексту й без власного title.
- **`db-check`**: у службовій `kristal_layout_backup` колонка `layout_id` без індексу — таблицю читає лише DOWN за `migration` (`idx_migration`); прийнято.
- **EXPLAIN мінімальних цін** (11 категорій одним запитом): `index` по `product_to_category` (243 рядки) + `Using temporary; filesort` для GROUP BY — допустимо, результат у кеші; перевірити на реальному обсязі (022).
