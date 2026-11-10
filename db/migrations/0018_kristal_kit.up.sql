-- ---------------------------------------------------------------------------
-- 0018_kristal_kit — UP
-- Специфікація: specs/007-kit/plan.md
--
-- 1) kristal_kit — таблиця готових комплектів для подій:
--      kit_id        — первинний ключ;
--      code          — унікальний текстовий код (напр., 'wedding_basic');
--      event_type    — тип події ('wedding', 'buffet', 'banquet', 'corporate');
--      tier          — рівень ('basic', 'standard', 'premium');
--      name          — назва комплекту ('Базовий', 'Стандарт', 'Преміум');
--      badge         — бейдж (напр., 'Найчастіше беруть');
--      discount_pct  — знижка на комплект у відсотках;
--      features      — JSON-список переваг та пунктів зі статусом on/off;
--      sort_order    — порядок сортування;
--      status        — статус увімкнено/вимкнено;
--      created_at, updated_at.
-- 2) kristal_kit_item — склад комплекту (товари каталогу та норми на гостя):
--      kit_id        — ID комплекту;
--      product_id    — ID товару в oc_product;
--      qty_per_guest — кількість на 1 гостя;
--      qty_fixed     — фіксована кількість одиниць;
--      sort_order    — порядок сортування позиції в комплекті.
-- 3) SEO URL:
--      extension/kristal/kit/event&event=wedding -> vesillya
-- 4) Подія меню адмінки:
--      admin/view/common/column_left/before -> extension/kristal/kit/menu
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `{{PREFIX}}kristal_kit` (
  `kit_id`       INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `code`         VARCHAR(32)      NOT NULL,
  `event_type`   VARCHAR(32)      NOT NULL DEFAULT 'wedding',
  `tier`         VARCHAR(32)      NOT NULL DEFAULT 'standard',
  `name`         VARCHAR(128)     NOT NULL DEFAULT '',
  `badge`        VARCHAR(64)      NOT NULL DEFAULT '',
  `discount_pct` DECIMAL(5,2)     NOT NULL DEFAULT 0.00,
  `features`     TEXT             NULL,
  `sort_order`   INT(11)          NOT NULL DEFAULT 0,
  `status`       TINYINT(1)       NOT NULL DEFAULT 1,
  `created_at`   DATETIME         NOT NULL,
  `updated_at`   DATETIME         NOT NULL,
  PRIMARY KEY (`kit_id`),
  UNIQUE KEY `uq_code` (`code`),
  KEY `idx_event_tier` (`event_type`, `tier`),
  KEY `idx_status_sort` (`status`, `sort_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `{{PREFIX}}kristal_kit_item` (
  `kit_id`        INT(11) UNSIGNED NOT NULL,
  `product_id`    INT(11) UNSIGNED NOT NULL,
  `qty_per_guest` DECIMAL(8,2)     NOT NULL DEFAULT 1.00,
  `qty_fixed`     INT(11) UNSIGNED NOT NULL DEFAULT 0,
  `sort_order`    INT(11)          NOT NULL DEFAULT 0,
  PRIMARY KEY (`kit_id`, `product_id`),
  KEY `idx_product_id` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Початкові дані: 3 комплекти для весілля
INSERT INTO `{{PREFIX}}kristal_kit` (`kit_id`, `code`, `event_type`, `tier`, `name`, `badge`, `discount_pct`, `features`, `sort_order`, `status`, `created_at`, `updated_at`) VALUES
(1, 'wedding_basic', 'wedding', 'basic', 'Базовий', '', 0.00, '[{"text":"Тарілки: закусочна, обідня, десертна (Classic)","included":true},{"text":"Прибори: виделка, ніж, ложка","included":true},{"text":"Келих для вина, склянка","included":true},{"text":"Салатниці й блюда для подачі","included":true},{"text":"Підставні тарілки","included":false},{"text":"Текстиль","included":false}]', 10, 1, NOW(), NOW()),
(2, 'wedding_standard', 'wedding', 'standard', 'Стандарт', 'Найчастіше беруть', 0.00, '[{"text":"Усе з «Базового»","included":true},{"text":"Підставна тарілка золота 33 см","included":true},{"text":"Келих для шампанського","included":true},{"text":"Скатертини й тканинні серветки","included":true},{"text":"Марміти для гарячого","included":true},{"text":"Чохли на стільці","included":false}]', 20, 1, NOW(), NOW()),
(3, 'wedding_premium', 'wedding', 'premium', 'Преміум', '', 0.00, '[{"text":"Посуд серії Royal із золотим обідком","included":true},{"text":"Золоті прибори Royal","included":true},{"text":"4 види келихів","included":true},{"text":"Текстиль + чохли на стільці","included":true},{"text":"Етажерки для десертів","included":true},{"text":"Персональний менеджер на подію","included":true}]', 30, 1, NOW(), NOW());

-- Товари комплекту 1 (wedding_basic) ~95 ₴/гість
INSERT INTO `{{PREFIX}}kristal_kit_item` (`kit_id`, `product_id`, `qty_per_guest`, `qty_fixed`, `sort_order`) VALUES
(1, 50001, 1.00, 0, 1),  -- Тарілка обідня біла 27 см (14 ₴)
(1, 50002, 1.00, 0, 2),  -- Тарілка закусочна біла 21 см (12 ₴)
(1, 50003, 1.00, 0, 3),  -- Тарілка десертна 19 см (11 ₴)
(1, 50019, 1.00, 0, 4),  -- Виделка столова Classic (7 ₴)
(1, 50027, 1.00, 0, 5),  -- Ніж столовий Classic (8 ₴)
(1, 50023, 1.00, 0, 6),  -- Ложка столова Classic (7 ₴)
(1, 50031, 1.00, 0, 7),  -- Келих для вина 450 мл (14 ₴)
(1, 50039, 1.00, 0, 8),  -- Склянка висока 350 мл (9 ₴)
(1, 50008, 0.25, 0, 9),  -- Салатниця для подачі (25 ₴ * 0.25 = 6.25 ₴)
(1, 50011, 0.22, 0, 10); -- Блюдо овальне (30 ₴ * 0.22 = 6.6 ₴)

-- Товари комплекту 2 (wedding_standard) ~140 ₴/гість
INSERT INTO `{{PREFIX}}kristal_kit_item` (`kit_id`, `product_id`, `qty_per_guest`, `qty_fixed`, `sort_order`) VALUES
(2, 50001, 1.00, 0, 1),  -- Тарілка обідня біла 27 см (14 ₴)
(2, 50002, 1.00, 0, 2),  -- Тарілка закусочна біла 21 см (12 ₴)
(2, 50003, 1.00, 0, 3),  -- Тарілка десертна 19 см (11 ₴)
(2, 50005, 0.50, 0, 4),  -- Підставна тарілка золота 33 см (35 ₴ * 0.5 = 17.5 ₴)
(2, 50019, 1.00, 0, 5),  -- Виделка столова Classic (7 ₴)
(2, 50027, 1.00, 0, 6),  -- Ніж столовий Classic (8 ₴)
(2, 50023, 1.00, 0, 7),  -- Ложка столова Classic (7 ₴)
(2, 50031, 1.00, 0, 8),  -- Келих для вина 450 мл (14 ₴)
(2, 50035, 1.00, 0, 9),  -- Келих для шампанського 210 мл (13 ₴)
(2, 50039, 1.00, 0, 10), -- Склянка висока 350 мл (9 ₴)
(2, 50082, 1.00, 0, 11), -- Серветка текстильна 45×45 см (15 ₴)
(2, 50077, 0.05, 0, 12), -- Скатертина кругла біла (180 ₴ * 0.05 = 9 ₴)
(2, 50008, 0.10, 0, 13); -- Салатниця для подачі (25 ₴ * 0.1 = 2.5 ₴)

-- Товари комплекту 3 (wedding_premium) ~230 ₴/гість
INSERT INTO `{{PREFIX}}kristal_kit_item` (`kit_id`, `product_id`, `qty_per_guest`, `qty_fixed`, `sort_order`) VALUES
(3, 50015, 1.00, 0, 1),  -- Тарілка з золотим обідком 27 см (28 ₴)
(3, 50002, 1.00, 0, 2),  -- Тарілка закусочна біла 21 см (12 ₴)
(3, 50003, 1.00, 0, 3),  -- Тарілка десертна 19 см (11 ₴)
(3, 50005, 1.00, 0, 4),  -- Підставна тарілка золота 33 см (35 ₴)
(3, 50021, 1.00, 0, 5),  -- Виделка столова золота Royal (12 ₴)
(3, 50029, 1.00, 0, 6),  -- Ніж столовий золотий Royal (13 ₴)
(3, 50025, 1.00, 0, 7),  -- Ложка десертна золота Royal (11 ₴)
(3, 50033, 1.00, 0, 8),  -- Келих для вина з золотим обідком (22 ₴)
(3, 50037, 1.00, 0, 9),  -- Келих-флюте золотий (24 ₴)
(3, 50034, 1.00, 0, 10), -- Келих для води 400 мл (12 ₴)
(3, 50080, 0.70, 0, 11), -- Чохол на стілець білий (45 ₴ * 0.7 = 31.5 ₴)
(3, 50082, 1.00, 0, 12); -- Серветка текстильна 45×45 см (15 ₴)

-- SEO URL: vesillya -> extension/kristal/kit/wedding
DELETE FROM `{{PREFIX}}seo_url` WHERE `query` = 'extension/kristal/kit/wedding' OR `keyword` = 'vesillya';

INSERT INTO `{{PREFIX}}seo_url` (`store_id`, `language_id`, `query`, `keyword`) VALUES
  (0, 2, 'extension/kristal/kit/wedding', 'vesillya');

-- Подія меню адмінки
DELETE FROM `{{PREFIX}}event` WHERE `code` = 'kristal_kit_menu';

INSERT INTO `{{PREFIX}}event` (`code`, `trigger`, `action`, `status`, `sort_order`) VALUES
  ('kristal_kit_menu', 'admin/view/common/column_left/before', 'extension/kristal/kit/menu', 1, 0);
