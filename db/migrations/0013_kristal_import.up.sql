-- ---------------------------------------------------------------------------
-- 0013_kristal_import — UP
-- Специфікація: specs/022-import/plan.md («Схема БД»)
--
-- 1) kristal_import_log — журнал імпортів прайсу: хто, коли, файл, лічильники, статус і ЗНІМОК старих
--    значень (JSON) — з нього відновлення при збої й «Скасувати» (таблиці товарів ядра MyISAM, транзакцій немає).
--      Без вторинних індексів: імпортів — одиниці на місяць, обидва запити (список, «останній застосований»)
--      ідуть по PRIMARY у зворотному порядку (import_id зростає разом із часом), user_id лише записується.
-- 2) Подія меню адмінки: «Каталог → Прайс (імпорт)».
-- Номер 0013: 0012 — міграція 017 (0012_kristal_security) в іншій гілці. Ідемпотентно.
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `{{PREFIX}}kristal_import_log` (
  `import_id`  INT(11)      NOT NULL AUTO_INCREMENT,
  `created_at` DATETIME     NOT NULL,
  `user_id`    INT(11)      NOT NULL DEFAULT 0,
  `username`   VARCHAR(20)  NOT NULL DEFAULT '',
  `filename`   VARCHAR(255) NOT NULL DEFAULT '',
  `status`     VARCHAR(16)  NOT NULL DEFAULT 'applying',
  `rows_total` INT(11)      NOT NULL DEFAULT 0,
  `changed`    INT(11)      NOT NULL DEFAULT 0,
  `created`    INT(11)      NOT NULL DEFAULT 0,
  `errors`     INT(11)      NOT NULL DEFAULT 0,
  `snapshot`   MEDIUMTEXT   NOT NULL,
  `summary`    TEXT         NOT NULL,
  PRIMARY KEY (`import_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

DELETE FROM `{{PREFIX}}event` WHERE `code` = 'kristal_import_menu';

INSERT INTO `{{PREFIX}}event` (`code`, `trigger`, `action`, `status`, `sort_order`) VALUES
  ('kristal_import_menu', 'admin/view/common/column_left/before', 'extension/module/kristal_import/menu', 1, 0);
