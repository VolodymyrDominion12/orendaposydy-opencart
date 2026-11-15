# 028 — План реалізації (`kristal_catering`)

Посилання: [`spec.md`](spec.md).

## Підхід
1. Створюємо окремий модуль `kristal_catering` (адмін-контролер `extension/module/kristal_catering`, моделі адмінки й каталогу `extension/kristal/catering`, контролер вітрини `extension/kristal/catering`, шаблони `catering_hub.twig` та `catering.twig`), не змішуючи кулінарію з орендою посуду в `kristal_kit` (`oc_kristal_kit`).
2. Зберігаємо 4 посадкові сторінки та їхні готові комплекси у двох нормалізованих таблицях `oc_kristal_catering_page` та `oc_kristal_catering_kit` (InnoDB, `utf8mb4_general_ci`), кешуємо дані навігації й сторінок ключами `kristal.catering.*`.
3. Вітрина перевикористовує наявні класи `kristal.css` (`.k-ehero`, `.k-sets`, `.k-set`, `.k-addons`, `.k-faq`, `.k-leadbox`) і мінімальні стилі для випадаючого меню та блоку страв, без жодного нового JS-фреймворку.
4. Інтеграція з `kristal_lead`: додаємо легку підтримку `[data-k-catering-select]` у `kristal-lead.js`, щоб при виборі комплексу відкривалося `#k-lead-modal` із заздалегідь підставленим контекстом формату та комплексу в коментарі.

## Файли
| Файл | Новий / зміна | Що |
|---|---|---|
| `db/migrations/0028_kristal_catering.up.sql` | Новий | Таблиці `kristal_catering_page`, `kristal_catering_kit`, стартові дані, SEO URL, подія адмін-меню, реєстрація модуля |
| `db/migrations/0028_kristal_catering.down.sql` | Новий | Повний відкат таблиць, SEO URL, події, налаштувань і запису модуля |
| `src/catalog/model/extension/kristal/catering.php` | Новий | Кешоване читання сторінок, комплексів та навігації |
| `src/catalog/controller/extension/kristal/catering.php` | Новий | Контролер `/gotuemo` (`index`) та 4 міні-лендінгів (`buffet`, `banquet`, `coffeebreak`, `wedding`) |
| `src/catalog/language/uk-ua/extension/kristal/catering.php` | Новий | Мовні рядки вітрини |
| `src/catalog/view/theme/kristal/template/extension/kristal/catering_hub.twig` | Новий | Оглядова сторінка `/gotuemo` |
| `src/catalog/view/theme/kristal/template/extension/kristal/catering.twig` | Новий | Шаблон міні-лендінгу формату кейтерингу |
| `src/admin/model/extension/kristal/catering.php` | Новий | CRUD сторінок і комплексів в адмінці |
| `src/admin/controller/extension/module/kristal_catering.php` | Новий | Налаштування модуля, редактор сторінок/комплексів, пункт меню адмінки |
| `src/admin/language/uk-ua/extension/module/kristal_catering.php` | Новий | Мовні рядки адмінки |
| `src/admin/view/template/extension/module/kristal_catering.twig` | Новий | Інтерфейс адмінки з вкладками для 4 сторінок та комплексів |
| `src/catalog/controller/extension/kristal/theme.php` | Зміна | Передача `k_catering_*` з кешу у спільні дані шапки/футера |
| `src/catalog/controller/extension/kristal/home.php` | Зміна | Передача `kh_catering` для секції на головній |
| `src/catalog/controller/extension/kristal/kit.php` | Зміна | Крос-посилання на відповідний кейтеринг-розділ у `event.twig` |
| `src/catalog/controller/extension/kristal/seo.php` | Зміна | Додавання сторінок `kristal_catering` до `/sitemap.xml` |
| `src/catalog/model/extension/kristal/seo.php` | Зміна | Вибірка активних сторінок кейтерингу для sitemap |
| `src/catalog/language/uk-ua/extension/kristal/theme.php` | Зміна | Тексти нового пункту меню і футера |
| `src/catalog/language/uk-ua/extension/kristal/home.php` | Зміна | Заголовки блоку кейтерингу на головній |
| `src/catalog/view/theme/kristal/template/common/header.twig` | Зміна | Випадаюче меню в `.k-nav` та розділ у мобільній шторці `#menu` + іконка `#i-chef` у спрайті |
| `src/catalog/view/theme/kristal/template/common/home.twig` | Зміна | Секція «Ми можемо для Вас приготувати» на головній |
| `src/catalog/view/theme/kristal/template/common/footer.twig` | Зміна | Посилання в футері |
| `src/catalog/view/theme/kristal/template/extension/kristal/event.twig` | Зміна | Крос-банер на напрямок кейтерингу |
| `src/catalog/view/theme/kristal/stylesheet/kristal.css` | Зміна | Стилі для `.k-mega--catering`, `.k-catering-nav`, `.k-catering-dishes`, карток комплексів |
| `src/catalog/view/theme/kristal/js/kristal-lead.js` | Зміна | Підтримка `[data-k-catering-select]` для відкриття `#k-lead-modal` із коментарем |
| `tests/smoke/urls.txt` | Зміна | Smoke-перевірки для 5 нових URL |

Ядро OpenCart не змінюється.

## Міграції БД
| Версія | Що | down |
|---|---|---|
| `0028_kristal_catering` | Таблиці `kristal_catering_page`, `kristal_catering_kit`, стартові дані, SEO URL, подія, налаштування | Видалення таблиць, SEO URL, події, налаштувань, запису модуля |

Чек-лист `docs/agents/db-schema-checklist.md`:
- [x] Таблиці мають `PRIMARY KEY`, `ENGINE=InnoDB`, `utf8mb4_general_ci`, префікс `{{PREFIX}}kristal_*`.
- [x] `page_id` у `kristal_catering_kit` стоїть першим у `idx_page_status_sort`.
- [x] Немає дубльованих індексів (лівий префікс не дублюється).
- [x] Міграція ідемпотентна (`IF NOT EXISTS`, `ON DUPLICATE KEY UPDATE`, `DELETE` перед `INSERT`), має `.down.sql`.

## Запити та індекси
| Де викликається | Запит (скорочено) | Індекс, який використає | EXPLAIN |
|---|---|---|---|
| `ModelExtensionKristalCatering::getPages()` | `SELECT ... FROM oc_kristal_catering_page WHERE status = 1 ORDER BY sort_order` | `idx_status_sort` | ref / 4 rows |
| `ModelExtensionKristalCatering::getPageByCode()` | `SELECT ... FROM oc_kristal_catering_page WHERE code = ? AND status = 1` | `uq_code` | const / 1 row |
| `ModelExtensionKristalCatering::getKitsByPageId()` | `SELECT ... FROM oc_kristal_catering_kit WHERE page_id = ? AND status = 1 ORDER BY sort_order` | `idx_page_status_sort` | ref / 3 rows |

## Кешування
- `kristal.catering.menu.<store_id>.<lang_id>` — список 4 активних сторінок для шапки, головної та футера.
- `kristal.catering.page.<code>.<lang_id>` — повні дані міні-лендінгу разом із комплексами.
- Скидається автоматично при збереженні в адмінці через `\Kristal\Cache_key::flush($this->cache)`.

## Вплив на швидкість і мобільний бюджет
- На головній (`/`): **0** додаткових запитів при теплому кеші (дані з `kristal.catering.menu.*`), вага SVG-спрайта +1 символ (~180 Б), CSS ~1.5 КБ, жодних нових JS-файлів чи зображень на першому екрані.
- На нових сторінках (`/gotuemo`, `/furshetni-stravy` тощо): ~32 запити до БД на холодному кеші, ~28–30 на теплому (аналогічно `/vesillya`), мобільний бюджет `tests/mobile/budgets.json` дотримується з запасом.

## Ризики і відкат
| Ризик | Ймовірність | Що робимо |
|---|---|---|
| Довга назва «Ми можемо для Вас приготувати» перенесе меню на 1024px | Середня | Коригуємо padding/gap у `.k-nav` на `1024px–1279px` і перевіряємо через `make test-mobile` + інспекцію |
| Конфлікт SEO URL із наявними сторінками | Низька | Використовуємо унікальні slug (`gotuemo`, `furshetni-stravy`, `banketni-stravy`, `kava-breik`, `vesilne-meniu`) |
| Відсутні права доступу адміна на `extension/module/kristal_catering` | Середня | Оновлюємо `db/restore_admin_permissions.sql` та надаємо підказку/перевіряємо на локалі |

Як відкотити: `make migrate-down V=0028`, видалити файли модуля та відкотити правки у `header.twig`/`home.twig`/`footer.twig`/`event.twig`.
