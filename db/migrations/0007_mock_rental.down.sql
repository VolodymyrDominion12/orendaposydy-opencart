-- ---------------------------------------------------------------------------
-- 0007_mock_rental — DOWN (МОК)
-- Повертає атрибути 505/506 мок-товарам і прибирає їхні рядки оренди.
-- ---------------------------------------------------------------------------

INSERT IGNORE INTO `{{PREFIX}}product_attribute` (`product_id`, `attribute_id`, `language_id`, `text`)
SELECT `product_id`, `attribute_id`, `language_id`, `text` FROM `{{PREFIX}}kristal_mock_attr_backup`;

DELETE r FROM `{{PREFIX}}kristal_product_rental` r
  JOIN `{{PREFIX}}product` p ON p.`product_id` = r.`product_id`
 WHERE p.`sku` LIKE 'MOCK-%';

DROP TABLE IF EXISTS `{{PREFIX}}kristal_mock_attr_backup`;
