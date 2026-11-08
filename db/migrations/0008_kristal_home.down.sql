-- ---------------------------------------------------------------------------
-- 0008_kristal_home — DOWN
-- Повертає модулі в макет головної (ті самі layout_module_id), прибирає події й службову таблицю.
-- Налаштування module_kristal_home_* (якщо модуль встановлено в адмінці) не чіпаються — видаліть модуль в адмінці.
-- ---------------------------------------------------------------------------

INSERT IGNORE INTO `{{PREFIX}}layout_module` (`layout_module_id`, `layout_id`, `code`, `position`, `sort_order`)
SELECT `layout_module_id`, `layout_id`, `code`, `position`, `sort_order`
  FROM `{{PREFIX}}kristal_layout_backup` WHERE `migration` = '0008_kristal_home';

DROP TABLE IF EXISTS `{{PREFIX}}kristal_layout_backup`;

DELETE FROM `{{PREFIX}}event` WHERE `code` IN ('kristal_home_meta', 'kristal_home_view');
