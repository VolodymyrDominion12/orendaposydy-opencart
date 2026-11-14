-- 0027_kristal_seo_header_view — DOWN
DELETE FROM `{{PREFIX}}event`
 WHERE `code` = 'kristal_seo_catalog'
   AND `trigger` = 'catalog/view/common/header/before'
   AND `action` = 'extension/kristal/seo/headerView';
