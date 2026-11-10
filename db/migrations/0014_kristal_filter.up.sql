-- ---------------------------------------------------------------------------
-- 0014_kristal_filter — UP
-- Специфікація: specs/021-filter/plan.md → «Міграції БД», «Події», «Запити та індекси»
--
-- 1) kristal_filter_page — SEO-сторінки фільтрів (білий список): категорія + 1–2 значення фільтра ядра → своя адреса, h1, title, текст.
--      uq_category_keyword  — пошук сторінки за адресою /категорія/keyword; лівий префікс category_id — список сторінок категорії;
--      uq_category_filters  — одна комбінація — одна сторінка.
--    Групи, значення й призначення товарам — таблиці ядра (oc_filter*, oc_product_filter).
-- 2) Події вітрини kristal_filter і скидання кешу kristal_filter_flush в адмінці.
-- Номер 0014: 0012 — гілка 017, 0013 — гілка 022. Без FOREIGN KEY. Ідемпотентно.
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `{{PREFIX}}kristal_filter_page` (
  `filter_page_id` INT(11)      NOT NULL AUTO_INCREMENT,
  `category_id`    INT(11)      NOT NULL,
  `filter_ids`     VARCHAR(64)  CHARACTER SET ascii NOT NULL,
  `keyword`        VARCHAR(64)  CHARACTER SET ascii NOT NULL,
  `h1`             VARCHAR(255) NOT NULL DEFAULT '',
  `title`          VARCHAR(255) NOT NULL DEFAULT '',
  `description`    VARCHAR(255) NOT NULL DEFAULT '',
  `text`           MEDIUMTEXT   NOT NULL,
  `status`         TINYINT(1)   NOT NULL DEFAULT 1,
  `date_modified`  DATETIME     NOT NULL,
  PRIMARY KEY (`filter_page_id`),
  UNIQUE KEY `uq_category_keyword` (`category_id`, `keyword`),
  UNIQUE KEY `uq_category_filters` (`category_id`, `filter_ids`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

DELETE FROM `{{PREFIX}}event` WHERE `code` IN ('kristal_filter', 'kristal_filter_flush');

INSERT INTO `{{PREFIX}}event` (`code`, `trigger`, `action`, `status`, `sort_order`) VALUES
  ('kristal_filter',       'catalog/controller/product/category/before',            'extension/kristal/filter/before',   1, 0),
  ('kristal_filter',       'catalog/controller/error/not_found/before',             'extension/kristal/filter/page',     1, 0),
  ('kristal_filter',       'catalog/model/catalog/product/getProducts/before',      'extension/kristal/filter/products', 1, 0),
  ('kristal_filter',       'catalog/model/catalog/product/getTotalProducts/before', 'extension/kristal/filter/total',    1, 0),
  ('kristal_filter',       'catalog/view/product/category/before',                  'extension/kristal/filter/view',     1, 0),
  ('kristal_filter',       'catalog/view/common/header/before',                     'extension/kristal/filter/header',   1, 0),
  ('kristal_filter_flush', 'admin/model/catalog/product/addProduct/after',          'extension/kristal/cache/flushMenu', 1, 0),
  ('kristal_filter_flush', 'admin/model/catalog/product/editProduct/after',         'extension/kristal/cache/flushMenu', 1, 0),
  ('kristal_filter_flush', 'admin/model/catalog/product/deleteProduct/after',       'extension/kristal/cache/flushMenu', 1, 0),
  ('kristal_filter_flush', 'admin/model/catalog/filter/addFilter/after',            'extension/kristal/cache/flushMenu', 1, 0),
  ('kristal_filter_flush', 'admin/model/catalog/filter/editFilter/after',           'extension/kristal/cache/flushMenu', 1, 0),
  ('kristal_filter_flush', 'admin/model/catalog/filter/deleteFilter/after',         'extension/kristal/cache/flushMenu', 1, 0);
