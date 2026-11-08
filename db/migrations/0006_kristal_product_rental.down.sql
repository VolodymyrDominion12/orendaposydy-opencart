-- ---------------------------------------------------------------------------
-- 0006_kristal_product_rental — DOWN
-- Повертає ліміт товарів, прибирає події й таблицю оренди (умови оренди товарів буде втрачено).
-- kristal_setting_backup не видаляється — нею користується 0003.
-- ---------------------------------------------------------------------------

UPDATE `{{PREFIX}}setting` s
  JOIN `{{PREFIX}}kristal_setting_backup` b
    ON b.`setting_id` = s.`setting_id`
   AND b.`migration` = '0006_kristal_product_rental'
   SET s.`value` = b.`value`;

DELETE FROM `{{PREFIX}}kristal_setting_backup` WHERE `migration` = '0006_kristal_product_rental';

DELETE FROM `{{PREFIX}}event` WHERE `code` IN ('kristal_catalog_category', 'kristal_catalog_product', 'kristal_catalog_admin_form',
  'kristal_catalog_admin_save', 'kristal_catalog_admin_copy', 'kristal_catalog_admin_delete');

DROP TABLE IF EXISTS `{{PREFIX}}kristal_product_rental`;
