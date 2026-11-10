-- ---------------------------------------------------------------------------
-- 0017_kristal_lead — DOWN
-- ---------------------------------------------------------------------------

DROP TABLE IF EXISTS `{{PREFIX}}kristal_lead_file`;
DROP TABLE IF EXISTS `{{PREFIX}}kristal_lead`;

DELETE FROM `{{PREFIX}}event` WHERE `code` = 'kristal_lead_menu';
