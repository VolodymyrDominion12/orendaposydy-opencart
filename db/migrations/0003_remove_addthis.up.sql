-- ---------------------------------------------------------------------------
-- 0003_remove_addthis — UP
-- Специфікація: specs/018-platform-upgrade (AC-4, AC-7)
--
-- У налаштуваннях магазину `config_script_after_body` лежить цілий HTML-документ
-- («<title>My Great Website</title> … Site Content …») з віджетом AddThis.
-- Він виводиться на кожній сторінці після <body> → smoke падає на «заглушці шаблону».
-- AddThis вимкнено Oracle 31.05.2023 — скрипт мертвий; це сторонній код.
--
-- Значення зберігаємо в службовій таблиці, щоб DOWN повернув його точно.
-- Ідемпотентно: повторний запуск не перезаписує бекап і нічого не ламає.
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `{{PREFIX}}kristal_setting_backup` (
  `setting_id`   INT(11)      NOT NULL,
  `store_id`     INT(11)      NOT NULL,
  `code`         VARCHAR(128) NOT NULL,
  `key`          VARCHAR(128) NOT NULL,
  `value`        MEDIUMTEXT   NOT NULL,
  `serialized`   TINYINT(1)   NOT NULL,
  `migration`    VARCHAR(64)  NOT NULL,
  `backed_up_at` DATETIME     NOT NULL,
  PRIMARY KEY (`setting_id`, `migration`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT IGNORE INTO `{{PREFIX}}kristal_setting_backup`
       (`setting_id`, `store_id`, `code`, `key`, `value`, `serialized`, `migration`, `backed_up_at`)
SELECT `setting_id`, `store_id`, `code`, `key`, `value`, `serialized`, '0003_remove_addthis', NOW()
  FROM `{{PREFIX}}setting`
 WHERE `code` = 'config'
   AND `key` = 'config_script_after_body'
   AND `value` LIKE '%addthis%';

UPDATE `{{PREFIX}}setting`
   SET `value` = ''
 WHERE `code` = 'config'
   AND `key` = 'config_script_after_body'
   AND `value` LIKE '%addthis%';
