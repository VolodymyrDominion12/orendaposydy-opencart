-- ---------------------------------------------------------------------------
-- 0010_kristal_search — UP
-- Специфікація: specs/027-search/plan.md → «Міграції БД», «Запити та індекси»
--
-- 1) kristal_search_word — словниковий індекс пошуку: слово назви/артикулу → товар ('p') або категорія ('c').
--      PRIMARY KEY (word, type, item_id) — пошук діапазоном word LIKE 'тарі%';
--      idx_item_type                    — DELETE слів одного товару/категорії при збереженні в адмінці.
--    word — utf8mb4_bin: слова вже нормалізовані в PHP (Kristal\Search::normalize, нижній регістр),
--    а bin не зливає «і»/«ї»/«и» і робить LIKE 'x%' точним префіксом.
--    Заповнюється з PHP (модуль «Крістал: пошук» → встановлення / «Перебудувати індекс»), не цією міграцією.
-- 2) kristal_search_log — журнал запитів без результатів (AC-8): нормалізований запит, кількість, коли востаннє. Без IP.
-- 3) Події адмінки: товар/категорія збережено або видалено → оновити індекс.
-- 4) ЧПУ /poshuk → extension/kristal/search (якщо ключ вільний).
-- Без FOREIGN KEY. Ідемпотентно.
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `{{PREFIX}}kristal_search_word` (
  `word`    VARCHAR(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `type`    CHAR(1)     CHARACTER SET ascii NOT NULL,
  `item_id` INT(11)     NOT NULL,
  PRIMARY KEY (`word`, `type`, `item_id`),
  KEY `idx_item_type` (`item_id`, `type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `{{PREFIX}}kristal_search_log` (
  `query`   VARCHAR(64) NOT NULL,
  `hits`    INT(11)     NOT NULL DEFAULT 1,
  `last_at` DATETIME    NOT NULL,
  PRIMARY KEY (`query`),
  KEY `idx_last_at` (`last_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

DELETE FROM `{{PREFIX}}event` WHERE `code` = 'kristal_search_index';

INSERT INTO `{{PREFIX}}event` (`code`, `trigger`, `action`, `status`, `sort_order`) VALUES
  ('kristal_search_index', 'admin/model/catalog/product/addProduct/after',       'extension/kristal/search/product',  1, 0),
  ('kristal_search_index', 'admin/model/catalog/product/editProduct/after',      'extension/kristal/search/product',  1, 0),
  ('kristal_search_index', 'admin/model/catalog/product/deleteProduct/after',    'extension/kristal/search/product',  1, 0),
  ('kristal_search_index', 'admin/model/catalog/category/addCategory/after',     'extension/kristal/search/category', 1, 0),
  ('kristal_search_index', 'admin/model/catalog/category/editCategory/after',    'extension/kristal/search/category', 1, 0),
  ('kristal_search_index', 'admin/model/catalog/category/deleteCategory/after',  'extension/kristal/search/category', 1, 0);

INSERT INTO `{{PREFIX}}seo_url` (`store_id`, `language_id`, `query`, `keyword`)
SELECT 0, l.`language_id`, 'extension/kristal/search', 'poshuk'
  FROM `{{PREFIX}}language` l
 WHERE NOT EXISTS (SELECT 1 FROM `{{PREFIX}}seo_url` s WHERE s.`store_id` = 0 AND s.`keyword` = 'poshuk')
   AND NOT EXISTS (SELECT 1 FROM `{{PREFIX}}seo_url` s WHERE s.`store_id` = 0 AND s.`language_id` = l.`language_id` AND s.`query` = 'extension/kristal/search');
