-- ---------------------------------------------------------------------------
-- 0021_kristal_redirect — DOWN
-- ---------------------------------------------------------------------------

DROP TABLE IF EXISTS `{{PREFIX}}kristal_redirect`;
DROP TABLE IF EXISTS `{{PREFIX}}kristal_404_log`;

DELETE FROM `{{PREFIX}}event` WHERE `code` = 'kristal_redirect_check';
