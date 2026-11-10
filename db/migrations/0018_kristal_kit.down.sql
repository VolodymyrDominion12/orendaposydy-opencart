-- ---------------------------------------------------------------------------
-- 0018_kristal_kit — DOWN
-- ---------------------------------------------------------------------------

DELETE FROM `{{PREFIX}}event` WHERE `code` = 'kristal_kit_menu';

DELETE FROM `{{PREFIX}}seo_url` WHERE `query` = 'extension/kristal/kit/wedding' OR `keyword` = 'vesillya';

DROP TABLE IF EXISTS `{{PREFIX}}kristal_kit_item`;
DROP TABLE IF EXISTS `{{PREFIX}}kristal_kit`;
