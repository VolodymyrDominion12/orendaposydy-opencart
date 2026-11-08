-- ---------------------------------------------------------------------------
-- 0006_kristal_product_rental — UP
-- Специфікація: specs/005-kristal-catalog/plan.md
--
-- 1) Умови оренди товару: одиниця, застава, відшкодування при битті/втраті, миття, «Хіт».
--    Один рядок на товар (PK product_id); товар без рядка = значення за замовчуванням (шт, без застави).
-- 2) Події kristal_catalog_*: дані оренди на вітрині, вкладки в адмінці, збереження.
-- 3) Товарів на сторінці категорії: 100 → 24 (старе значення — у kristal_setting_backup для DOWN).
-- Ідемпотентно.
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `{{PREFIX}}kristal_product_rental` (
  `product_id`       INT(11)       NOT NULL,
  `unit`             VARCHAR(16)   NOT NULL DEFAULT 'pcs',
  `deposit`          DECIMAL(15,4) NOT NULL DEFAULT '0.0000',
  `breakage_price`   DECIMAL(15,4) NOT NULL DEFAULT '0.0000',
  `washing_included` TINYINT(1)    NOT NULL DEFAULT 0,
  `is_hit`           TINYINT(1)    NOT NULL DEFAULT 0,
  PRIMARY KEY (`product_id`),
  KEY `idx_is_hit` (`is_hit`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

DELETE FROM `{{PREFIX}}event` WHERE `code` IN ('kristal_catalog_category', 'kristal_catalog_product', 'kristal_catalog_admin_form',
  'kristal_catalog_admin_save', 'kristal_catalog_admin_copy', 'kristal_catalog_admin_delete');

INSERT INTO `{{PREFIX}}event` (`code`, `trigger`, `action`, `status`, `sort_order`) VALUES
  ('kristal_catalog_category',     'catalog/view/product/category/before',            'extension/kristal/catalog/category', 1, 0),
  ('kristal_catalog_product',      'catalog/view/product/product/before',             'extension/kristal/catalog/product',  1, 0),
  ('kristal_catalog_admin_form',   'admin/view/catalog/product_form/after',           'extension/kristal/catalog/form',     1, 0),
  ('kristal_catalog_admin_save',   'admin/model/catalog/product/addProduct/after',    'extension/kristal/catalog/save',     1, 0),
  ('kristal_catalog_admin_save',   'admin/model/catalog/product/editProduct/after',   'extension/kristal/catalog/save',     1, 0),
  ('kristal_catalog_admin_copy',   'admin/model/catalog/product/copyProduct/after',   'extension/kristal/catalog/copy',     1, 0),
  ('kristal_catalog_admin_delete', 'admin/model/catalog/product/deleteProduct/after', 'extension/kristal/catalog/delete',   1, 0);

-- Ліміт товарів на сторінці: бекап (лише перший раз) і нове значення
CREATE TABLE IF NOT EXISTS `{{PREFIX}}kristal_setting_backup` (
  `setting_id`   INT(11)      NOT NULL,
  `store_id`     INT(11)      NOT NULL,
  `code`         VARCHAR(128) NOT NULL,
  `key`          VARCHAR(128) NOT NULL,
  `value`        MEDIUMTEXT   NOT NULL,
  `serialized`   TINYINT(1)   NOT NULL,
  `migration`    VARCHAR(64)  NOT NULL,
  `backed_up_at` DATETIME     NOT NULL,
  PRIMARY KEY (`setting_id`, `migration`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT IGNORE INTO `{{PREFIX}}kristal_setting_backup`
       (`setting_id`, `store_id`, `code`, `key`, `value`, `serialized`, `migration`, `backed_up_at`)
SELECT `setting_id`, `store_id`, `code`, `key`, `value`, `serialized`, '0006_kristal_product_rental', NOW()
  FROM `{{PREFIX}}setting`
 WHERE `key` = 'theme_default_product_limit';

UPDATE `{{PREFIX}}setting` SET `value` = '24' WHERE `key` = 'theme_default_product_limit';
