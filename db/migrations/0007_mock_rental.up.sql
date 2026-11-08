-- ---------------------------------------------------------------------------
-- 0007_mock_rental — UP   (МОК: на прод не йде — migrate-print відмовляє через «mock» у назві)
-- Специфікація: specs/005-kristal-catalog (AC-11, розділ «Мок-дані»)
--
-- Умови оренди для 95 мок-товарів 001 (sku MOCK-%):
--   одиниця      — з атрибута 506 «Одиниця оренди» («шт. / доба» → pcs, «подія…» → event);
--   відшкодування — число з атрибута 505 «Відшкодування при бутті або втраті» («120 грн / шт.» → 120);
--   застава       — 2 × ціна (вигадано);
--   миття включено — для посуду, приборів і скла (категорії 5001–5003);
--   «Хіт»         — 8 товарів (вигадано).
-- Атрибути 505/506 мок-товарів переносяться в бекап і прибираються з характеристик.
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `{{PREFIX}}kristal_mock_attr_backup` (
  `product_id`   INT(11)  NOT NULL,
  `attribute_id` INT(11)  NOT NULL,
  `language_id`  INT(11)  NOT NULL,
  `text`         TEXT     NOT NULL,
  PRIMARY KEY (`product_id`, `attribute_id`, `language_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT IGNORE INTO `{{PREFIX}}kristal_mock_attr_backup` (`product_id`, `attribute_id`, `language_id`, `text`)
SELECT pa.`product_id`, pa.`attribute_id`, pa.`language_id`, pa.`text`
  FROM `{{PREFIX}}product_attribute` pa
  JOIN `{{PREFIX}}product` p ON p.`product_id` = pa.`product_id`
 WHERE p.`sku` LIKE 'MOCK-%' AND pa.`attribute_id` IN (505, 506);

INSERT INTO `{{PREFIX}}kristal_product_rental` (`product_id`, `unit`, `deposit`, `breakage_price`, `washing_included`, `is_hit`)
SELECT p.`product_id`,
       IF(u.`text` LIKE 'подія%', 'event', 'pcs'),
       ROUND(p.`price` * 2),
       IFNULL(CAST(REPLACE(REGEXP_SUBSTR(REPLACE(REPLACE(d.`text`, ' ', ''), UNHEX('C2A0'), ''), '[0-9]+([.,][0-9]+)?'), ',', '.') AS DECIMAL(15,4)), 0),
       IF(EXISTS (SELECT 1 FROM `{{PREFIX}}product_to_category` p2c
                   WHERE p2c.`product_id` = p.`product_id` AND p2c.`category_id` IN (5001, 5002, 5003)), 1, 0),
       IF(p.`product_id` IN (50001, 50005, 50012, 50020, 50031, 50045, 50058, 50070), 1, 0)
  FROM `{{PREFIX}}product` p
  LEFT JOIN `{{PREFIX}}kristal_mock_attr_backup` u ON u.`product_id` = p.`product_id` AND u.`attribute_id` = 506 AND u.`language_id` = 2
  LEFT JOIN `{{PREFIX}}kristal_mock_attr_backup` d ON d.`product_id` = p.`product_id` AND d.`attribute_id` = 505 AND d.`language_id` = 2
 WHERE p.`sku` LIKE 'MOCK-%'
ON DUPLICATE KEY UPDATE `unit` = VALUES(`unit`), `deposit` = VALUES(`deposit`), `breakage_price` = VALUES(`breakage_price`),
       `washing_included` = VALUES(`washing_included`), `is_hit` = VALUES(`is_hit`);

DELETE pa FROM `{{PREFIX}}product_attribute` pa
  JOIN `{{PREFIX}}kristal_mock_attr_backup` b
    ON b.`product_id` = pa.`product_id` AND b.`attribute_id` = pa.`attribute_id` AND b.`language_id` = pa.`language_id`;
