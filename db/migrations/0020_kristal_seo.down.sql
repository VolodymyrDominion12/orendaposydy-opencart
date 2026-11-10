-- ---------------------------------------------------------------------------
-- 0020_kristal_seo — DOWN
-- ---------------------------------------------------------------------------

DROP TABLE IF EXISTS `{{PREFIX}}kristal_seo_meta`;

DELETE FROM `{{PREFIX}}event` WHERE `code` IN ('kristal_seo_catalog', 'kristal_seo_flush');

DELETE FROM `{{PREFIX}}seo_url` WHERE `query` = 'extension/kristal/seo/sitemap' AND `keyword` = 'sitemap.xml';
