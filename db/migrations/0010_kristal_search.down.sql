-- ---------------------------------------------------------------------------
-- 0010_kristal_search — DOWN
-- Прибирає таблиці індексу й журналу, події адмінки і ЧПУ /poshuk.
-- Налаштування module_kristal_search_* (модуль в адмінці) не чіпаються — видаліть модуль в адмінці.
-- ---------------------------------------------------------------------------

DELETE FROM `{{PREFIX}}seo_url` WHERE `store_id` = 0 AND `query` = 'extension/kristal/search' AND `keyword` = 'poshuk';

DELETE FROM `{{PREFIX}}event` WHERE `code` = 'kristal_search_index';

DROP TABLE IF EXISTS `{{PREFIX}}kristal_search_log`;

DROP TABLE IF EXISTS `{{PREFIX}}kristal_search_word`;
