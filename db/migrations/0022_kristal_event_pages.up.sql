-- ---------------------------------------------------------------------------
-- 0022_kristal_event_pages — UP
-- Специфікація: specs/006-pages/spec.md
--
-- 1) Комплекти для сторінок подій: buffet, catering, corporate.
-- 2) SEO URLs для нових подій:
--    - extension/kristal/kit/buffet    -> furshet
--    - extension/kristal/kit/catering  -> keiterynh
--    - extension/kristal/kit/corporate -> korporatyv
-- ---------------------------------------------------------------------------

-- 1. Комплекти для Фуршету та кава-брейку (buffet)
INSERT INTO `{{PREFIX}}kristal_kit` (`kit_id`, `code`, `event_type`, `tier`, `name`, `badge`, `discount_pct`, `features`, `sort_order`, `status`, `created_at`, `updated_at`)
VALUES
  (4, 'buffet_basic', 'buffet', 'basic', 'Фуршет Базовий', '', 0.00,
   '[{"text":"Тарілка десертна 19 см","included":true},{"text":"Виделка десертна Classic","included":true},{"text":"Келих-флюте для шампанського","included":true},{"text":"Склянка для напоїв 350 мл","included":true},{"text":"Чашка з блюдцем та ложка","included":false},{"text":"Термопот / кавоварка","included":false}]',
   1, 1, NOW(), NOW()),
  (5, 'buffet_standard', 'buffet', 'standard', 'Фуршет + Кава-брейк', 'Популярний вибір', 5.00,
   '[{"text":"Тарілка десертна 19 см","included":true},{"text":"Виделка десертна Classic","included":true},{"text":"Келих-флюте для напоїв","included":true},{"text":"Склянка 350 мл для безалкогольного","included":true},{"text":"Чашка з блюдцем 200 мл та ложка","included":true},{"text":"Сервірувальні блюда для закусок","included":true},{"text":"Триярусна етажерка для десертів","included":false}]',
   2, 1, NOW(), NOW()),
  (6, 'buffet_premium', 'buffet', 'premium', 'Фуршет Преміум', '', 10.00,
   '[{"text":"Десертні тарілки Royal із золотим обідком","included":true},{"text":"Десертні виделки золоті Royal","included":true},{"text":"Келихи-купе для шампанського","included":true},{"text":"Чашки з блюдцем Royal та кавові ложки","included":true},{"text":"Триярусні етажерки для капкейків і фруктів","included":true},{"text":"Діспенсери для лимонадів з підставками","included":true}]',
   3, 1, NOW(), NOW())
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`), `badge` = VALUES(`badge`), `features` = VALUES(`features`);

-- Позиції комплектів фуршету
INSERT IGNORE INTO `{{PREFIX}}kristal_kit_item` (`kit_id`, `product_id`, `qty_per_guest`, `qty_fixed`, `sort_order`) VALUES
  -- Базовий (50003 десертна 1, 50020 виделка десертна 1, 50035 флюте 1, 50039 склянка 1)
  (4, 50003, 1.00, 0, 1),
  (4, 50020, 1.00, 0, 2),
  (4, 50035, 1.00, 0, 3),
  (4, 50039, 1.00, 0, 4),
  -- Стандарт (плюс 50018 чашка+блюдце 1, 50024 чайна ложка 1, 50013 блюдо 0.1)
  (5, 50003, 1.00, 0, 1),
  (5, 50020, 1.00, 0, 2),
  (5, 50035, 1.00, 0, 3),
  (5, 50039, 1.00, 0, 4),
  (5, 50018, 1.00, 0, 5),
  (5, 50024, 1.00, 0, 6),
  (5, 50013, 0.10, 0, 7),
  -- Преміум (Royal 50015, 50025, 50036 купе, 50018, 50014 етажерка 0.05, 50062 діспенсер 0.02)
  (6, 50015, 1.00, 0, 1),
  (6, 50025, 1.00, 0, 2),
  (6, 50036, 1.00, 0, 3),
  (6, 50039, 1.00, 0, 4),
  (6, 50018, 1.00, 0, 5),
  (6, 50025, 1.00, 0, 6),
  (6, 50014, 0.05, 0, 7);

-- 2. Комплекти для Кейтерингу (catering)
INSERT INTO `{{PREFIX}}kristal_kit` (`kit_id`, `code`, `event_type`, `tier`, `name`, `badge`, `discount_pct`, `features`, `sort_order`, `status`, `created_at`, `updated_at`)
VALUES
  (7, 'catering_basic', 'catering', 'basic', 'Кейтеринг Лінія роздачі', '', 0.00,
   '[{"text":"Тарілка обідня біла 27 см","included":true},{"text":"Виделка столова Classic","included":true},{"text":"Ніж столовий Classic","included":true},{"text":"Склянка універсальна 350 мл","included":true},{"text":"Чафінгдіш з підігрівом","included":false},{"text":"Термобокс для перевезення","included":false}]',
   1, 1, NOW(), NOW()),
  (8, 'catering_standard', 'catering', 'standard', 'Кейтеринг Повний стіл', 'Хіт для кейтерингів', 5.00,
   '[{"text":"Тарілка обідня та закусочна","included":true},{"text":"Прибори: виделка, ніж, ложка","included":true},{"text":"Келих для вина та склянка","included":true},{"text":"Чафінгдіші 9 л для гарячих страв","included":true},{"text":"Блюда сервірувальні овальні","included":true},{"text":"Глечики скляні 1.5 л для напоїв","included":true}]',
   2, 1, NOW(), NOW())
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`), `badge` = VALUES(`badge`), `features` = VALUES(`features`);

-- Позиції кейтерингу
INSERT IGNORE INTO `{{PREFIX}}kristal_kit_item` (`kit_id`, `product_id`, `qty_per_guest`, `qty_fixed`, `sort_order`) VALUES
  (7, 50001, 1.00, 0, 1),
  (7, 50019, 1.00, 0, 2),
  (7, 50027, 1.00, 0, 3),
  (7, 50039, 1.00, 0, 4),
  -- Стандарт
  (8, 50001, 1.00, 0, 1),
  (8, 50002, 1.00, 0, 2),
  (8, 50019, 1.00, 0, 3),
  (8, 50027, 1.00, 0, 4),
  (8, 50031, 1.00, 0, 5),
  (8, 50039, 1.00, 0, 6),
  (8, 50043, 0.03, 0, 7),
  (8, 50011, 0.10, 0, 8),
  (8, 50042, 0.05, 0, 9);

-- 3. Комплекти для Корпоративу (corporate)
INSERT INTO `{{PREFIX}}kristal_kit` (`kit_id`, `code`, `event_type`, `tier`, `name`, `badge`, `discount_pct`, `features`, `sort_order`, `status`, `created_at`, `updated_at`)
VALUES
  (9, 'corporate_standard', 'corporate', 'standard', 'Корпоратив Стандарт', 'Оптимальний', 0.00,
   '[{"text":"Тарілка обідня біла 27 см","included":true},{"text":"Тарілка закусочна біла 21 см","included":true},{"text":"Столові виделка та ніж Classic","included":true},{"text":"Келих для вина та келих для шампанського","included":true},{"text":"Склянка для віскі / води","included":true},{"text":"Салатниці та спільні блюда для подачі","included":true}]',
   1, 1, NOW(), NOW()),
  (10, 'corporate_premium', 'corporate', 'corporate_vip', 'Корпоратив VIP', 'Преміум сервірування', 5.00,
   '[{"text":"Посуд із золотим обідком Royal","included":true},{"text":"Золоті прибори Royal","included":true},{"text":"Келихи Royal 400 мл та купе","included":true},{"text":"Склянки для міцних напоїв","included":true},{"text":"Підставні тарілки ротанг або золото","included":true},{"text":"Скатертини круглі білі","included":true}]',
   2, 1, NOW(), NOW())
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`), `badge` = VALUES(`badge`), `features` = VALUES(`features`);

INSERT IGNORE INTO `{{PREFIX}}kristal_kit_item` (`kit_id`, `product_id`, `qty_per_guest`, `qty_fixed`, `sort_order`) VALUES
  (9, 50001, 1.00, 0, 1),
  (9, 50002, 1.00, 0, 2),
  (9, 50019, 1.00, 0, 3),
  (9, 50027, 1.00, 0, 4),
  (9, 50031, 1.00, 0, 5),
  (9, 50035, 1.00, 0, 6),
  (9, 50040, 1.00, 0, 7),
  (9, 50008, 0.15, 0, 8),
  -- VIP
  (10, 50015, 1.00, 0, 1),
  (10, 50002, 1.00, 0, 2),
  (10, 50021, 1.00, 0, 3),
  (10, 50029, 1.00, 0, 4),
  (10, 50033, 1.00, 0, 5),
  (10, 50036, 1.00, 0, 6),
  (10, 50040, 1.00, 0, 7),
  (10, 50005, 1.00, 0, 8),
  (10, 50077, 0.10, 0, 9);

-- 4. SEO URLs для нових сторінок подій
DELETE FROM `{{PREFIX}}seo_url` WHERE `query` IN (
  'extension/kristal/kit/buffet',
  'extension/kristal/kit/catering',
  'extension/kristal/kit/corporate'
) OR `keyword` IN ('furshet', 'keiterynh', 'korporatyv');

INSERT INTO `{{PREFIX}}seo_url` (`store_id`, `language_id`, `query`, `keyword`) VALUES
  (0, 2, 'extension/kristal/kit/buffet', 'furshet'),
  (0, 2, 'extension/kristal/kit/catering', 'keiterynh'),
  (0, 2, 'extension/kristal/kit/corporate', 'korporatyv');
