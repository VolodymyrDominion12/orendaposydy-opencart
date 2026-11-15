-- ---------------------------------------------------------------------------
-- 0028_kristal_catering — DOWN
-- Відкат фічі 028: «Ми можемо для Вас приготувати» (kristal_catering)
-- ---------------------------------------------------------------------------

DELETE FROM `{{PREFIX}}event` WHERE `code` = 'kristal_catering_admin_menu';
DELETE FROM `{{PREFIX}}setting` WHERE `store_id` = 0 AND `code` = 'module_kristal_catering';
DELETE FROM `{{PREFIX}}extension` WHERE `type` = 'module' AND `code` = 'kristal_catering';

DELETE FROM `{{PREFIX}}seo_url` WHERE `query` IN (
  'extension/kristal/catering',
  'extension/kristal/catering/buffet',
  'extension/kristal/catering/banquet',
  'extension/kristal/catering/coffeebreak',
  'extension/kristal/catering/wedding'
);

DROP TABLE IF EXISTS `{{PREFIX}}kristal_catering_kit`;
DROP TABLE IF EXISTS `{{PREFIX}}kristal_catering_page`;
