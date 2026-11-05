-- ---------------------------------------------------------------------------
-- 0001_mock_catalog — DOWN
-- ЗГЕНЕРОВАНО: db/seed/generate_mock_catalog.py з db/seed/mock_catalog_data.py.
-- Не редагуйте вручну — змініть дані й перегенеруйте.
-- Специфікація: specs/001-mock-catalog/. УСІ ДАНІ ВИГАДАНІ (мок).
-- Мок НЕ ДЕПЛОЇТЬСЯ на прод (make migrate-print відмовить без ALLOW_MOCK=1).
-- ---------------------------------------------------------------------------

SET NAMES utf8mb4;

-- 1. Видалити мок за діапазонами id
DELETE FROM `{{PREFIX}}product` WHERE `product_id` BETWEEN 50000 AND 50999;
DELETE FROM `{{PREFIX}}product_description` WHERE `product_id` BETWEEN 50000 AND 50999;
DELETE FROM `{{PREFIX}}product_to_store` WHERE `product_id` BETWEEN 50000 AND 50999;
DELETE FROM `{{PREFIX}}product_to_layout` WHERE `product_id` BETWEEN 50000 AND 50999;
DELETE FROM `{{PREFIX}}product_to_category` WHERE `product_id` BETWEEN 50000 AND 50999;
DELETE FROM `{{PREFIX}}product_attribute` WHERE `product_id` BETWEEN 50000 AND 50999;
DELETE FROM `{{PREFIX}}product_discount` WHERE `product_id` BETWEEN 50000 AND 50999;
DELETE FROM `{{PREFIX}}product_special` WHERE `product_id` BETWEEN 50000 AND 50999;
DELETE FROM `{{PREFIX}}product_image` WHERE `product_id` BETWEEN 50000 AND 50999;
DELETE FROM `{{PREFIX}}product_filter` WHERE `product_id` BETWEEN 50000 AND 50999;
DELETE FROM `{{PREFIX}}product_option` WHERE `product_id` BETWEEN 50000 AND 50999;
DELETE FROM `{{PREFIX}}product_option_value` WHERE `product_id` BETWEEN 50000 AND 50999;
DELETE FROM `{{PREFIX}}product_reward` WHERE `product_id` BETWEEN 50000 AND 50999;
DELETE FROM `{{PREFIX}}product_recurring` WHERE `product_id` BETWEEN 50000 AND 50999;
DELETE FROM `{{PREFIX}}product_to_download` WHERE `product_id` BETWEEN 50000 AND 50999;
DELETE FROM `{{PREFIX}}review` WHERE `product_id` BETWEEN 50000 AND 50999;
DELETE FROM `{{PREFIX}}cart` WHERE `product_id` BETWEEN 50000 AND 50999;
DELETE FROM `{{PREFIX}}product_related` WHERE `product_id` BETWEEN 50000 AND 50999 OR `related_id` BETWEEN 50000 AND 50999;
DELETE FROM `{{PREFIX}}category` WHERE `category_id` BETWEEN 5000 AND 5099;
DELETE FROM `{{PREFIX}}category_description` WHERE `category_id` BETWEEN 5000 AND 5099;
DELETE FROM `{{PREFIX}}category_path` WHERE `category_id` BETWEEN 5000 AND 5099;
DELETE FROM `{{PREFIX}}category_to_store` WHERE `category_id` BETWEEN 5000 AND 5099;
DELETE FROM `{{PREFIX}}category_to_layout` WHERE `category_id` BETWEEN 5000 AND 5099;
DELETE FROM `{{PREFIX}}category_filter` WHERE `category_id` BETWEEN 5000 AND 5099;
DELETE FROM `{{PREFIX}}product_to_category` WHERE `category_id` BETWEEN 5000 AND 5099;
DELETE FROM `{{PREFIX}}attribute` WHERE `attribute_id` BETWEEN 500 AND 549;
DELETE FROM `{{PREFIX}}attribute_description` WHERE `attribute_id` BETWEEN 500 AND 549;
DELETE FROM `{{PREFIX}}attribute_group` WHERE `attribute_group_id` BETWEEN 500 AND 509;
DELETE FROM `{{PREFIX}}attribute_group_description` WHERE `attribute_group_id` BETWEEN 500 AND 509;
DELETE FROM `{{PREFIX}}seo_url`
 WHERE (`query` LIKE 'category\_id=%' AND CAST(SUBSTRING(`query`, 13) AS UNSIGNED) BETWEEN 5000 AND 5099)
    OR (`query` LIKE 'product\_id=%' AND CAST(SUBSTRING(`query`, 12) AS UNSIGNED) BETWEEN 50000 AND 50999);

-- 2. Повернути старим категоріям і статусам наявності попередній стан
--    (якщо службової таблиці вже немає — нічого не робимо)
CREATE TABLE IF NOT EXISTS `{{PREFIX}}kristal_mock_backup` (
  `entity`     VARCHAR(32)  NOT NULL,
  `entity_id`  INT(11)      NOT NULL,
  `field`      VARCHAR(64)  NOT NULL,
  `value`      TEXT         NOT NULL,
  PRIMARY KEY (`entity`, `entity_id`, `field`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
UPDATE `{{PREFIX}}category` c JOIN `{{PREFIX}}kristal_mock_backup` b
    ON b.`entity` = 'category' AND b.`entity_id` = c.`category_id` AND b.`field` = 'status'
   SET c.`status` = CAST(b.`value` AS UNSIGNED);
UPDATE `{{PREFIX}}category` c JOIN `{{PREFIX}}kristal_mock_backup` b
    ON b.`entity` = 'category' AND b.`entity_id` = c.`category_id` AND b.`field` = 'top'
   SET c.`top` = CAST(b.`value` AS UNSIGNED);
UPDATE `{{PREFIX}}stock_status` s JOIN `{{PREFIX}}kristal_mock_backup` b
    ON b.`entity` = 'stock_status' AND b.`entity_id` = s.`stock_status_id` AND b.`field` = 'name'
   SET s.`name` = b.`value`
 WHERE s.`language_id` = 2;

-- 3. Прибрати службову таблицю
DROP TABLE IF EXISTS `{{PREFIX}}kristal_mock_backup`;

-- Готово. Далі: make clear-cache
