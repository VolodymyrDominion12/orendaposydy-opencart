# 011 — План реалізації

Специфікація: `spec.md`.

## Архітектурний підхід
1. **Спільна бібліотека `Kristal\Seo` (`system/library/kristal/seo.php`)**:
   - `renderTemplate($template, $data)`: заміна змінних `{name}`, `{min_price}`, `{city}`, `{category}`, `{store_name}`.
   - `preloadUrls($db, $store_id, $language_id, $cache)`: кешування карти `query <=> keyword` з `oc_seo_url` у кеш `kristal.seo_url.<store>.<lang>`.
   - `buildSitemap($db, $store_id, $language_id, $url_helper)`: збір URL категорій, товарів, SEO-фільтрів (021), інформаційних сторінок з тегами `<loc>`, `<lastmod>`, `<changefreq>`, `<priority>`.
   - `jsonLdBreadcrumbs($breadcrumbs)`: генерація Schema.org `BreadcrumbList`.
   - `jsonLdProduct($product, $rental)`: генерація Schema.org `Product` + `Offer`.
   - Тести: `tests/lib/seo_test.php`.

2. **Таблиця бази даних `oc_kristal_seo_meta`**:
   - Зберігає кастомні H1 та SEO-тексти для сутностей: `category`, `product`, `information`.
   - Первинний ключ: `(entity_type, entity_id, language_id)`.
   - Міграція: `db/migrations/0020_kristal_seo.up.sql` та `.down.sql`.

3. **Кеш `oc_seo_url`**:
   - У `catalog/controller/startup/seo_url.php` додаємо використання кешу `Kristal\Seo::getUrlMap()`: замість запиту в БД на кожен виклик `rewrite()` використовується попередньо завантажена або кешована карта.
   - Скидання кешу — при додаванні/редагуванні/видаленні товару, категорії чи налаштувань.

4. **Вітрина (`catalog`)**:
   - Контролер `extension/kristal/seo`:
     - `sitemap()` — віддає валідний XML з `header('Content-Type: application/xml; charset=utf-8')`.
   - Події:
     - `catalog/controller/common/header/before` (`ControllerExtensionKristalSeo::headerBefore`): встановлення динамічного title/description (якщо не задано або за шаблоном), додавання `rel="canonical"`, тегу `<meta name="robots" content="noindex, follow">` для службових сторінок, розмітки JSON-LD Breadcrumbs/LocalBusiness.
     - `catalog/view/product/category/before` (`ControllerExtensionKristalSeo::categoryView`): підміна H1 та передача `k_seo_text` у шаблон.
     - `catalog/view/product/product/before` (`ControllerExtensionKristalSeo::productView`): підміна H1 та JSON-LD Product.
   - Шаблон `catalog/view/theme/kristal/template/product/category.twig`:
     - Вивід блоку `{% if k_seo_text %}<div class="k-seo-text k-card">{{ k_seo_text }}</div>{% endif %}` унизу сторінки під товарами.
     - Заголовок сторінки `<h1>{{ k_h1 ? k_h1 : heading_title }}</h1>`.

5. **Адмінка (`admin`)**:
   - Модуль «Крістал: SEO» (`extension/module/kristal_seo`):
     - Налаштування шаблонів title та description для категорій та товарів.
     - Кнопка скидання кешу SEO та sitemap.
     - Статус і посилання на `/sitemap.xml`.
   - Редагування категорій і товарів:
     - Модель `admin/model/extension/kristal/seo.php` для збереження H1 та `seo_text`.
     - Події для збереження H1 та SEO-тексту при додаванні/редагуванні товару та категорії.

## Файли
| Файл | Статус | Призначення |
|---|---|---|
| `src/system/library/kristal/seo.php` | Новий | Бібліотека: шаблони meta, генератор sitemap, кеш ЧПУ, JSON-LD |
| `tests/lib/seo_test.php` | Новий | Unit-тести бібліотеки SEO |
| `src/catalog/controller/extension/kristal/seo.php` | Новий | Вітрина: sitemap, обробники подій header/category/product |
| `src/catalog/model/extension/kristal/seo.php` | Новий | Модель вітрини: вибірка seo_meta, даних для sitemap |
| `src/admin/controller/extension/module/kristal_seo.php` | Новий | Модуль адмінки: налаштування шаблонів, sitemap |
| `src/admin/model/extension/kristal/seo.php` | Новий | Модель адмінки: збереження meta, скидання кешу |
| `src/admin/view/template/extension/module/kristal_seo.twig` | Новий | Шаблон модуля в адмінці |
| `src/admin/language/uk-ua/extension/module/kristal_seo.php` | Новий | Мовний файл адмінки |
| `src/catalog/controller/startup/seo_url.php` | Зміна | Кешування запитів `rewrite()` через карту `Kristal\Seo` |
| `src/catalog/view/theme/kristal/template/common/header.twig` | Зміна | Вставка JSON-LD, meta robots (noindex), canonical |
| `src/catalog/view/theme/kristal/template/product/category.twig` | Зміна | H1 та нижній SEO-текст |
| `db/migrations/0020_kristal_seo.up.sql` | Новий | Таблиця `oc_kristal_seo_meta`, реєстрація подій, SEO URL для sitemap.xml |
| `db/migrations/0020_kristal_seo.down.sql` | Новий | Відкат міграції |
| `tests/smoke/urls.txt` | Зміна | Додавання `/sitemap.xml` |

## База даних та індекси
```sql
CREATE TABLE IF NOT EXISTS `{{PREFIX}}kristal_seo_meta` (
  `entity_type` VARCHAR(16) NOT NULL,
  `entity_id` INT(11) NOT NULL,
  `language_id` INT(11) NOT NULL,
  `h1` VARCHAR(255) NOT NULL DEFAULT '',
  `seo_text` MEDIUMTEXT,
  PRIMARY KEY (`entity_type`, `entity_id`, `language_id`),
  KEY `idx_entity` (`entity_type`, `entity_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
```
