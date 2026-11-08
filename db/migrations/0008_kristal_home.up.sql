-- ---------------------------------------------------------------------------
-- 0008_kristal_home — UP
-- Специфікація: specs/004-home/plan.md
--
-- 1) Події головної: title/description/canonical (до збирання шапки) і дані для шаблону.
-- 2) Модулі старої теми з макета головної (2 банери-слайдери, «Рекомендовані», «Категорії») → бекап і прибрати з макета.
--    Самі модулі (oc_module) не видаляються; DOWN повертає їх у макет з тими самими id.
-- Схема: + службова таблиця kristal_layout_backup. Ідемпотентно.
-- ---------------------------------------------------------------------------

DELETE FROM `{{PREFIX}}event` WHERE `code` IN ('kristal_home_meta', 'kristal_home_view');

INSERT INTO `{{PREFIX}}event` (`code`, `trigger`, `action`, `status`, `sort_order`) VALUES
  ('kristal_home_meta', 'catalog/controller/common/header/before', 'extension/kristal/home/meta', 1, 0),
  ('kristal_home_view', 'catalog/view/common/home/before',         'extension/kristal/home/view', 1, 0);

CREATE TABLE IF NOT EXISTS `{{PREFIX}}kristal_layout_backup` (
  `layout_module_id` INT(11)      NOT NULL,
  `layout_id`        INT(11)      NOT NULL,
  `code`             VARCHAR(64)  NOT NULL,
  `position`         VARCHAR(14)  NOT NULL,
  `sort_order`       INT(3)       NOT NULL,
  `migration`        VARCHAR(64)  NOT NULL,
  PRIMARY KEY (`layout_module_id`),
  KEY `idx_migration` (`migration`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT IGNORE INTO `{{PREFIX}}kristal_layout_backup` (`layout_module_id`, `layout_id`, `code`, `position`, `sort_order`, `migration`)
SELECT lm.`layout_module_id`, lm.`layout_id`, lm.`code`, lm.`position`, lm.`sort_order`, '0008_kristal_home'
  FROM `{{PREFIX}}layout_module` lm
  JOIN `{{PREFIX}}layout_route` lr ON (lr.`layout_id` = lm.`layout_id` AND lr.`route` = 'common/home' AND lr.`store_id` = 0);

DELETE lm FROM `{{PREFIX}}layout_module` lm
  JOIN `{{PREFIX}}kristal_layout_backup` b ON (b.`layout_module_id` = lm.`layout_module_id` AND b.`migration` = '0008_kristal_home');
