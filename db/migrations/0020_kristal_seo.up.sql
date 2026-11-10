-- ---------------------------------------------------------------------------
-- 0020_kristal_seo — UP
-- Специфікація: specs/011-seo/plan.md
--
-- 1) kristal_seo_meta — збереження окремого H1 та SEO-тексту (нижній опис) для категорій/товарів/сторінок.
-- 2) Події:
--    kristal_seo_catalog: додавання meta/canonical/noindex/json-ld у header, підміна H1 та вивід SEO-тексту.
--    kristal_seo_flush: скидання кешу SEO при змінах товарів/категорій в адмінці.
-- 3) ЧПУ /sitemap.xml -> extension/kristal/seo/sitemap
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `{{PREFIX}}kristal_seo_meta` (
  `entity_type` VARCHAR(16) NOT NULL,
  `entity_id`   INT(11)     NOT NULL,
  `language_id` INT(11)     NOT NULL,
  `h1`          VARCHAR(255) NOT NULL DEFAULT '',
  `seo_text`    MEDIUMTEXT,
  PRIMARY KEY (`entity_type`, `entity_id`, `language_id`),
  KEY `idx_entity_id` (`entity_id`),
  KEY `idx_language_id` (`language_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

DELETE FROM `{{PREFIX}}event` WHERE `code` IN ('kristal_seo_catalog', 'kristal_seo_flush');

INSERT INTO `{{PREFIX}}event` (`code`, `trigger`, `action`, `status`, `sort_order`) VALUES
  ('kristal_seo_catalog', 'catalog/controller/common/header/before',           'extension/kristal/seo/headerBefore',  1, 10),
  ('kristal_seo_catalog', 'catalog/view/product/category/before',              'extension/kristal/seo/categoryView',  1, 10),
  ('kristal_seo_catalog', 'catalog/view/product/product/before',               'extension/kristal/seo/productView',   1, 10),
  ('kristal_seo_flush',   'admin/model/catalog/product/addProduct/after',      'extension/kristal/seo/flush',        1, 10),
  ('kristal_seo_flush',   'admin/model/catalog/product/editProduct/after',     'extension/kristal/seo/flush',        1, 10),
  ('kristal_seo_flush',   'admin/model/catalog/product/deleteProduct/after',   'extension/kristal/seo/flush',        1, 10),
  ('kristal_seo_flush',   'admin/model/catalog/category/addCategory/after',    'extension/kristal/seo/flush',        1, 10),
  ('kristal_seo_flush',   'admin/model/catalog/category/editCategory/after',   'extension/kristal/seo/flush',        1, 10),
  ('kristal_seo_flush',   'admin/model/catalog/category/deleteCategory/after', 'extension/kristal/seo/flush',        1, 10);

INSERT INTO `{{PREFIX}}seo_url` (`store_id`, `language_id`, `query`, `keyword`)
SELECT 0, l.`language_id`, 'extension/kristal/seo/sitemap', 'sitemap.xml'
  FROM `{{PREFIX}}language` l
 WHERE NOT EXISTS (SELECT 1 FROM `{{PREFIX}}seo_url` s WHERE s.`store_id` = 0 AND s.`keyword` = 'sitemap.xml')
   AND NOT EXISTS (SELECT 1 FROM `{{PREFIX}}seo_url` s WHERE s.`store_id` = 0 AND s.`language_id` = l.`language_id` AND s.`query` = 'extension/kristal/seo/sitemap');
