SET NAMES utf8mb4;

-- Встановити мінімальне замовлення 10 шт. для всіх товарів у категоріях «Посуд» та «Столові прибори»
-- (включно з підкатегоріями через category_path).
UPDATE `{{PREFIX}}product` p
  JOIN `{{PREFIX}}product_to_category` p2c ON (p2c.`product_id` = p.`product_id`)
  JOIN `{{PREFIX}}category_path` cp ON (cp.`category_id` = p2c.`category_id`)
  JOIN `{{PREFIX}}category_description` cd ON (cd.`category_id` = cp.`path_id` AND cd.`language_id` = 2)
   SET p.`minimum` = 10, p.`date_modified` = NOW()
 WHERE cd.`name` IN ('Посуд', 'Столові прибори')
   AND p.`minimum` <> 10;

-- Оновити згадку мінімального замовлення в SEO meta_description товарів цих категорій.
UPDATE `{{PREFIX}}product_description` pd
  JOIN `{{PREFIX}}product_to_category` p2c ON (p2c.`product_id` = pd.`product_id`)
  JOIN `{{PREFIX}}category_path` cp ON (cp.`category_id` = p2c.`category_id`)
  JOIN `{{PREFIX}}category_description` cd ON (cd.`category_id` = cp.`path_id` AND cd.`language_id` = 2)
   SET pd.`meta_description` = REPLACE(
         REPLACE(pd.`meta_description`, 'мінімум 1 шт', 'мінімум 10 шт'),
         'від 1 шт', 'від 10 шт'
       )
 WHERE cd.`name` IN ('Посуд', 'Столові прибори')
   AND pd.`language_id` = 2
   AND (
     pd.`meta_description` LIKE '%мінімум 1 шт%'
     OR pd.`meta_description` LIKE '%від 1 шт%'
   );

-- Оновити згадку мінімального замовлення в описах товарів цих категорій.
UPDATE `{{PREFIX}}product_description` pd
  JOIN `{{PREFIX}}product_to_category` p2c ON (p2c.`product_id` = pd.`product_id`)
  JOIN `{{PREFIX}}category_path` cp ON (cp.`category_id` = p2c.`category_id`)
  JOIN `{{PREFIX}}category_description` cd ON (cd.`category_id` = cp.`path_id` AND cd.`language_id` = 2)
   SET pd.`description` = REPLACE(pd.`description`, 'мінімальне замовлення 1 шт', 'мінімальне замовлення 10 шт')
 WHERE cd.`name` IN ('Посуд', 'Столові прибори')
   AND pd.`language_id` = 2
   AND pd.`description` LIKE '%мінімальне замовлення 1 шт%';
