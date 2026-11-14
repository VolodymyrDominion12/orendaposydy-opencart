SET NAMES utf8mb4;

-- Встановити мінімальну кількість замовлення 1 шт. для всіх реальних товарів (без MOCK).
-- За замовчуванням на вітрині, в картці товару та у кошику /order має бути 1 шт.
UPDATE `{{PREFIX}}product`
   SET `minimum` = 1, `date_modified` = NOW()
 WHERE `model` <> 'MOCK' AND `minimum` <> 1;

-- Оновити SEO meta_description, де після демо-паку 2026-11-11 лишився старий мінімум (5/10/20 шт).
UPDATE `{{PREFIX}}product_description` pd
  JOIN `{{PREFIX}}product` p ON (p.`product_id` = pd.`product_id`)
   SET pd.`meta_description` = REPLACE(
         REPLACE(
           REPLACE(
             REPLACE(pd.`meta_description`, 'мінімум 20 шт', 'мінімум 1 шт'),
             'мінімум 10 шт', 'мінімум 1 шт'
           ),
           'мінімум 5 шт', 'мінімум 1 шт'
         ),
         'від 10 шт', 'від 1 шт'
       )
 WHERE p.`model` <> 'MOCK'
   AND pd.`language_id` = 2
   AND (
     pd.`meta_description` LIKE '%мінімум 20 шт%'
     OR pd.`meta_description` LIKE '%мінімум 10 шт%'
     OR pd.`meta_description` LIKE '%мінімум 5 шт%'
     OR pd.`meta_description` LIKE '%від 10 шт%'
   );

-- Оновити згадку мінімального замовлення в авто-згенерованих описах товарів.
UPDATE `{{PREFIX}}product_description` pd
  JOIN `{{PREFIX}}product` p ON (p.`product_id` = pd.`product_id`)
   SET pd.`description` = REPLACE(
         REPLACE(
           REPLACE(pd.`description`, 'мінімальне замовлення 20 шт', 'мінімальне замовлення 1 шт'),
           'мінімальне замовлення 10 шт', 'мінімальне замовлення 1 шт'
         ),
         'мінімальне замовлення 5 шт', 'мінімальне замовлення 1 шт'
       )
 WHERE p.`model` <> 'MOCK'
   AND pd.`language_id` = 2
   AND (
     pd.`description` LIKE '%мінімальне замовлення 20 шт%'
     OR pd.`description` LIKE '%мінімальне замовлення 10 шт%'
     OR pd.`description` LIKE '%мінімальне замовлення 5 шт%'
   );
