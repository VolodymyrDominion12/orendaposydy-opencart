-- ---------------------------------------------------------------------------
-- 0019_kristal_calculator — DOWN
-- ---------------------------------------------------------------------------

DROP TABLE IF EXISTS `{{PREFIX}}kristal_calc_norm`;

DELETE FROM `{{PREFIX}}seo_url` WHERE `query` = 'extension/kristal/calculator' OR `keyword` = 'kalkulyator';

DELETE FROM `{{PREFIX}}event` WHERE `code` = 'kristal_calculator_menu';
