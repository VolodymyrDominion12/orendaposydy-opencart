-- ---------------------------------------------------------------------------
-- 0019_kristal_calculator — UP
-- Специфікація: specs/008-calculator/plan.md
--
-- 1) kristal_calc_norm — норми розрахунку посуду для калькулятора події:
--      norm_id            — первинний ключ;
--      category_type      — група позицій ('plates', 'cutlery', 'glass');
--      name               — назва позиції у розрахунку;
--      product_id_classic — ID товару в oc_product для серії Classic;
--      product_id_royal   — ID товару в oc_product для серії Royal;
--      norm_banquet       — норма на 1 гостя для банкету;
--      norm_buffet        — норма на 1 гостя для фуршету;
--      norm_coffee        — норма на 1 гостя для кава-брейку;
--      dish_rule          — особливе правило для кількості страв (NULL, 'extra_if_4_dishes', 'skip_if_2_dishes_non_banquet');
--      drink_filter       — фільтр за напоями (NULL, 'wine', 'champ', 'strong');
--      pack_size          — крок кратності/упаковки (за замовчуванням 10);
--      sort_order         — порядок сортування;
--      status             — увімкнено (1) / вимкнено (0).
-- 2) SEO URL:
--      extension/kristal/calculator -> kalkulyator
-- 3) Подія меню адмінки:
--      admin/view/common/column_left/before -> extension/kristal/calculator/menu
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `{{PREFIX}}kristal_calc_norm` (
  `norm_id`            INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `category_type`      VARCHAR(32)      NOT NULL DEFAULT 'plates',
  `name`               VARCHAR(128)     NOT NULL DEFAULT '',
  `product_id_classic` INT(11) UNSIGNED NOT NULL DEFAULT 0,
  `product_id_royal`   INT(11) UNSIGNED NOT NULL DEFAULT 0,
  `norm_banquet`       DECIMAL(5,2)     NOT NULL DEFAULT 0.00,
  `norm_buffet`        DECIMAL(5,2)     NOT NULL DEFAULT 0.00,
  `norm_coffee`        DECIMAL(5,2)     NOT NULL DEFAULT 0.00,
  `dish_rule`          VARCHAR(32)      NULL DEFAULT NULL,
  `drink_filter`       VARCHAR(32)      NULL DEFAULT NULL,
  `pack_size`          INT(11) UNSIGNED NOT NULL DEFAULT 10,
  `sort_order`         INT(11)          NOT NULL DEFAULT 0,
  `status`             TINYINT(1)       NOT NULL DEFAULT 1,
  PRIMARY KEY (`norm_id`),
  KEY `idx_cat_sort` (`category_type`, `sort_order`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Початкові норми калькулятора (відповідають ресторанній практиці та дизайн-макету 06-calculator.html)
INSERT INTO `{{PREFIX}}kristal_calc_norm`
  (`norm_id`, `category_type`, `name`, `product_id_classic`, `product_id_royal`, `norm_banquet`, `norm_buffet`, `norm_coffee`, `dish_rule`, `drink_filter`, `pack_size`, `sort_order`, `status`)
VALUES
  -- Посуд (plates)
  (1, 'plates', 'Тарілка підставна 33 см', 50005, 50005, 1.00, 0.00, 0.00, NULL, NULL, 10, 10, 1),
  (2, 'plates', 'Тарілка закусочна 21 см', 50002, 50002, 1.00, 2.00, 1.00, 'extra_if_4_dishes', NULL, 10, 20, 1),
  (3, 'plates', 'Тарілка обідня 27 см', 50001, 50015, 1.00, 0.00, 0.00, 'skip_if_2_dishes_non_banquet', NULL, 10, 30, 1),
  (4, 'plates', 'Тарілка десертна 19 см', 50003, 50003, 1.00, 1.00, 1.00, NULL, NULL, 10, 40, 1),

  -- Столові прибори (cutlery)
  (5, 'cutlery', 'Виделка столова', 50019, 50021, 1.00, 1.00, 0.00, NULL, NULL, 10, 50, 1),
  (6, 'cutlery', 'Ніж столовий', 50027, 50029, 1.00, 0.00, 0.00, NULL, NULL, 10, 60, 1),
  (7, 'cutlery', 'Виделка десертна', 50020, 50021, 1.00, 1.00, 1.00, NULL, NULL, 10, 70, 1),
  (8, 'cutlery', 'Ложка чайна', 50024, 50025, 1.00, 1.00, 1.00, NULL, NULL, 10, 80, 1),

  -- Скло та келихи (glass)
  (9, 'glass', 'Келих для вина', 50031, 50033, 1.00, 1.00, 0.00, NULL, 'wine', 10, 90, 1),
  (10, 'glass', 'Келих для шампанського', 50035, 50037, 1.00, 1.00, 0.00, NULL, 'champ', 10, 100, 1),
  (11, 'glass', 'Чарка 50 мл', 50041, 50041, 1.00, 1.00, 0.00, NULL, 'strong', 10, 110, 1),
  (12, 'glass', 'Склянка для води', 50039, 50034, 1.00, 1.00, 1.00, NULL, NULL, 10, 120, 1),
  (13, 'glass', 'Чашка з блюдцем', 50018, 50018, 0.00, 0.00, 1.00, NULL, NULL, 10, 130, 1);

-- SEO URL: kalkulyator -> extension/kristal/calculator
DELETE FROM `{{PREFIX}}seo_url` WHERE `query` = 'extension/kristal/calculator' OR `keyword` = 'kalkulyator';

INSERT INTO `{{PREFIX}}seo_url` (`store_id`, `language_id`, `query`, `keyword`) VALUES
  (0, 2, 'extension/kristal/calculator', 'kalkulyator');

-- Подія меню адмінки
DELETE FROM `{{PREFIX}}event` WHERE `code` = 'kristal_calculator_menu';

INSERT INTO `{{PREFIX}}event` (`code`, `trigger`, `action`, `status`, `sort_order`) VALUES
  ('kristal_calculator_menu', 'admin/view/common/column_left/before', 'extension/kristal/calculator/menu', 1, 0);

-- Права адміністратора на модуль калькулятора
UPDATE `{{PREFIX}}user_group`
SET `permission` = JSON_ARRAY_APPEND(
  JSON_ARRAY_APPEND(`permission`, '$.access', 'extension/kristal/calculator'),
  '$.modify', 'extension/kristal/calculator'
)
WHERE `user_group_id` = 1
  AND `permission` NOT LIKE '%extension/kristal/calculator%';
