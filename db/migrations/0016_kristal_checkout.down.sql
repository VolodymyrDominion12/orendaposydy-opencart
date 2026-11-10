-- ---------------------------------------------------------------------------
-- 0016_kristal_checkout — DOWN
-- ---------------------------------------------------------------------------

DROP TABLE IF EXISTS `{{PREFIX}}kristal_order_rental`;

DELETE FROM `{{PREFIX}}event` WHERE `code` = 'kristal_checkout';
