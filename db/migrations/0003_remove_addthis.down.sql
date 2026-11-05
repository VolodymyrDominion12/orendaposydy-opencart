-- ---------------------------------------------------------------------------
-- 0003_remove_addthis — DOWN
-- Повертає збережене значення config_script_after_body і прибирає службову таблицю.
-- ---------------------------------------------------------------------------

UPDATE `{{PREFIX}}setting` s
  JOIN `{{PREFIX}}kristal_setting_backup` b
    ON b.`setting_id` = s.`setting_id`
   AND b.`migration` = '0003_remove_addthis'
   SET s.`value` = b.`value`;

DROP TABLE IF EXISTS `{{PREFIX}}kristal_setting_backup`;
