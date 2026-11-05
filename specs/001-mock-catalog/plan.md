# 001 — План реалізації

## Підхід
Одна міграція `db/migrations/0001_mock_catalog.up.sql` / `.down.sql`. Мок живе в зарезервованих діапазонах id,
тому `down` видаляє рівно своє і не чіпає реальні дані. Старі категорії не видаляємо, а ховаємо (`status=0`, `top=0`),
їхній попередній стан зберігаємо в службовій таблиці, щоб `down` повернув його точно.
Альтернатива «оновити наявні категорії на місці» відкинута: змішує мок із реальними даними й ламає відкат.

## Діапазони id (резерв під мок)
| Сутність | Діапазон |
|---|---|
| `category_id` | 5000–5099 |
| `product_id` | 50000–50999 |
| `attribute_group_id` | 500–509 |
| `attribute_id` | 500–549 |
| `product_discount_id` | 500000–509999 |
| `seo_url` | за `query` (`category_id=50xx`, `product_id=50xxx`) |

## Файли
| Файл | Новий / зміна | Що |
|---|---|---|
| `db/seed/mock_catalog_data.py` | новий | усі мок-дані (категорії, товари, ціни, атрибути, знижки) — редагувати тут |
| `db/seed/generate_mock_catalog.py` | новий | генерує обидва SQL-файли міграції з даних |
| `db/migrations/0001_mock_catalog.up.sql` | новий, згенерований | категорії, `category_path`, `*_to_store`, `*_to_layout`, товари, описи, атрибути, знижки, SEO-URL, перевірка конфліктів ЧПУ, прихування старих категорій, статуси наявності українською |
| `db/migrations/0001_mock_catalog.down.sql` | новий, згенерований | видалення діапазонів, відновлення з бекапу, видалення службової таблиці |
| `db/seed/make_placeholders.cjs` | новий | генератор заглушок (Playwright) |
| `src/image/catalog/kristal/mock/*.png` | нові | 11 заглушок по верхніх категоріях |
| `.gitignore` | зміна | `src/image/catalog/*` + виняток `!src/image/catalog/kristal/` |
| `tools/lib.sh` | зміна | `image/catalog/kristal/mock/*` у захищених від деплою |
| `tests/smoke/urls.txt`, `tests/mobile/pages.txt` | зміна | нові категорії й товари; старі категорії → 404 до 002 |

## Міграції БД
| Версія | Що | down |
|---|---|---|
| 0001_mock_catalog | +1 службова таблиця `{{PREFIX}}kristal_mock_backup(entity, entity_id, field, value)`, дані в ядрових таблицях | DROP службової таблиці, DELETE за діапазонами, UPDATE старих категорій з backup |

Нових індексів не потрібно — усі запити йдуть ядровими моделями по ключах, що вже є (`PRIMARY`, `category_id`, `query`, `keyword`). Чек-лист `docs/agents/db-schema-checklist.md` — відмітити в `tasks.md`.

## Запити та індекси
| Де | Запит | Індекс | Очікувано |
|---|---|---|---|
| Вітрина, ЧПУ | `seo_url WHERE keyword = ?` | `keyword` | `ref` |
| Категорія | `product_to_category WHERE category_id = ?` | `category_id` | `ref` |
| Міграція, перевірка конфліктів | `seo_url WHERE keyword IN (...)` | `keyword` | `range` |

## Кешування
Після `up`/`down` — `make clear-cache` (кеш категорій меню OpenCart).

## Вплив на швидкість
Сторінка категорії з 20 товарами — як зараз; фіксуємо базу `make db-profile URL=/posud/tarilky` після `up`.

## Ризики і відкат
| Ризик | Ймовірність | Що робимо |
|---|---|---|
| Колізія SEO-ключа з наявним | низька | міграція перевіряє й падає з повідомленням до вставки |
| Таблиці MyISAM без транзакцій — часткове `up` при помилці | середня | `up` ідемпотентний: повторний запуск дописує; `down` видаляє за діапазонами |
| Тема `sauco` очікує додаткові поля (`description_excerpt`, `description_add`) | висока | заповнюємо їх у вставках |

Відкат: `make migrate-down V=0001 && make clear-cache`.
