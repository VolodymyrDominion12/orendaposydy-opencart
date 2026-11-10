# 009 — План реалізації («Крістал: ліди», `kristal_lead`)

Посилання на [spec.md](file:///home/volodymyr/PycharmProjects/orendaposydy-opencart/specs/009-lead/spec.md).

## Підхід
Модуль `kristal_lead` забезпечує збір заявок із форм «Розрахунок за 15 хв», «Швидке замовлення в 1 клік» на картці товару та «Зворотний дзвінок».
Запити надходять асинхронно через єдиний endpoint `extension/kristal/lead/submit` (або `checkout/lead/save`).
Дані валідуються на стороні сервера: honeypot-антиспам (`\Kristal\Antispam`), rate limiting (`\Kristal\RateLimit`), перевірка телефону.
Прикріплені файли меню/кошторису проходять валідацію розширення й mime-типу та зберігаються в `DIR_STORAGE . 'upload/'` із захищеним випадковим іменем, у БД зберігається зв'язок у таблиці `oc_kristal_lead_file`.
При успішному створенні ліда викликається `model_extension_kristal_notify->sendLead()`, що надсилає сповіщення в Telegram та Email.
В адмінці створюється повноцінний контролер та представлення `extension/kristal/lead` зі списком, фільтрами, переглядом, зміною статусів та експортом у CSV.

## Файли
| Файл | Новий / зміна | Що |
|---|---|---|
| `db/migrations/0017_kristal_lead.up.sql` | Новий | Створення таблиць `oc_kristal_lead`, `oc_kristal_lead_file`, реєстрація в меню адмінки |
| `db/migrations/0017_kristal_lead.down.sql` | Новий | Видалення таблиць лідів та налаштувань |
| `src/catalog/controller/extension/kristal/lead.php` | Новий | Публічний контролер прийому лідів (валідація, антиспам, upload файлу, збереження, виклик notify, JSON-відповідь) |
| `src/catalog/model/extension/kristal/lead.php` | Новий | Модель збереження ліда, файлу та читання |
| `src/catalog/language/uk-ua/extension/kristal/lead.php` | Новий | Мовні константи та повідомлення про помилки/успіх |
| `src/catalog/view/theme/kristal/js/kristal-lead.js` | Новий | Ванільний JS для обробки форми 15 хв, модалки 1 кліку та дзвінка |
| `src/catalog/view/theme/kristal/stylesheet/kristal.css` | Зміна | Стилі форми лідогенерації, інпуту файлу та модального вікна 1 кліку / дзвінка |
| `src/catalog/view/theme/kristal/template/common/home.twig` | Зміна | Інтеграція інтерактивної форми «Розрахунок за 15 хв» замість статичного тексту |
| `src/catalog/view/theme/kristal/template/product/product.twig` | Зміна | Додавання кнопки «Забронювати в 1 клік» та розмітки модального вікна швидкого замовлення |
| `src/catalog/view/theme/kristal/template/common/footer.twig` | Зміна | Кнопка «Замовити дзвінок» / модальне вікно |
| `src/admin/controller/extension/kristal/lead.php` | Новий | Адмінка: перегляд списку лідів, фільтри, перегляд деталей, зміна статусу, завантаження файлу, експорт CSV |
| `src/admin/model/extension/kristal/lead.php` | Новий | Адмін-модель для вибірки, фільтрації, оновлення статусів та видалення лідів |
| `src/admin/view/template/extension/kristal/lead_list.twig` | Новий | Шаблон списку лідів в адмінці |
| `src/admin/view/template/extension/kristal/lead_info.twig` | Новий | Шаблон перегляду деталей ліда |
| `src/admin/language/uk-ua/extension/kristal/lead.php` | Новий | Локалізація адмінки |
| `tests/smoke/urls.txt` | Зміна | Додавання тестових перевірок лідів |

## Міграції БД
| Версія | Що | down |
|---|---|---|
| 0017 | `oc_kristal_lead`, `oc_kristal_lead_file` | DROP TABLE IF EXISTS |

### Чек-лист: `docs/agents/db-schema-checklist.md`
- [x] У `plan.md` описано: таблиці `oc_kristal_lead`, `oc_kristal_lead_file`, призначення та індекси.
- [x] Перевірено наявність у ядрі OpenCart: ядра лідів немає (OpenCart оперує лише замовленнями `oc_order`).
- [x] Для ядрових таблиць змін не робиться.
- [x] Назва `0017_kristal_lead.up.sql` + `0017_kristal_lead.down.sql`.
- [x] Префікс `{{PREFIX}}`.
- [x] Ідемпотентність: `CREATE TABLE IF NOT EXISTS`, `DROP TABLE IF EXISTS`.
- [x] `ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci`, `PRIMARY KEY`.
- [x] Типи: `lead_id INT(11) AUTO_INCREMENT`, дати `DATETIME`/`DATE`, прапорці/статуси `VARCHAR(32)`.
- [x] `down` повністю відкочує зміни.
- [x] Без зовнішніх ключів `FOREIGN KEY` (цілісність через транзакцію та код).

## Запити та індекси
| Де викликається | Запит (скорочено) | Індекс, який використає | EXPLAIN type / rows |
|---|---|---|---|
| `catalog: saveLead` | `INSERT INTO oc_kristal_lead ...` | PK (`lead_id`) | - |
| `catalog: saveFile` | `INSERT INTO oc_kristal_lead_file ...` | PK (`file_id`), `idx_lead_id` | - |
| `admin: getLeads` | `SELECT * FROM oc_kristal_lead WHERE status = ? ORDER BY created_at DESC LIMIT 20` | `idx_status_created` (`status`, `created_at`) | `ref` / швидкий пошук |
| `admin: getLeads` | `SELECT * FROM oc_kristal_lead ORDER BY created_at DESC LIMIT 20` | `idx_created` (`created_at`) | `index` / сортування без filesort |
| `admin: getFiles` | `SELECT * FROM oc_kristal_lead_file WHERE lead_id = ?` | `idx_lead_id` (`lead_id`) | `ref` / 1 рядок |

## Кешування
Ліди — це динамічні дані подій. Кешування не використовується для списків заявок, щоб менеджер одразу бачив актуальні статуси.

## Вплив на швидкість і мобільний бюджет
- Сторінки: головна `/`, картка товару `/tarilka-...`, каталог `/posud`.
- Кількість запитів до БД при завантаженні сторінки не збільшується (форми рендеряться з поточними даними сторінки або підключаються як клієнтські скрипти).
- Додається скрипт `kristal-lead.js` (до 4 КБ), завантажується асинхронно `defer`.
- Мобільний бюджет: форми повністю оптимізовані під 360px, тач-зони інпутів та кнопок ≥ 44px, жодного горизонтального overflow.

## Ризики і відкат
| Ризик | Ймовірність | Що робимо |
|---|---|---|
| Спам-боти | Середня | Застосовуємо комбінацію honeypot-пастки, перевірки часу заповнення форми та обмеження частоти запитів по IP |
| Завантаження шкідливих файлів | Низька | Суворий білий список розширень, перевірка mime-type, ізоляція файлів у `storage/upload/` без збереження виконуваного імені, віддача лише через адмінський контролер |

Як відкотити: `make migrate-down V=0017`.
