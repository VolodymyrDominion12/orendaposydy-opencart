-- ---------------------------------------------------------------------------
-- СТОП-КРАН 2026-11-09: повернути бойову базу до стану до запуску теми «Крістал».
--
-- Навіщо: домен https://orendaposudu.com/ обслуговується текою
--   /home/matusuni/orendaposudu.online/  (OpenCart 3.0.3.2, тема sauco),
-- а деплой (FTP_REMOTE_DIR=orendaposydy.com) заливає файли в ІНШУ теку
--   /home/matusuni/orendaposydy.com/     (окремий сайт orendaposydy.com).
-- База в обох спільна — matusuni_kozak, тому міграції й перемикання теми
-- вдарили по живій старій інсталяції: theme_default_directory = 'kristal',
-- а теки catalog/view/theme/kristal там немає → 500 на всіх сторінках вітрини
-- (Twig_Error_Loader: Unable to find template "common/content_top.twig").
--
-- Що робить файл (зворотний порядок до застосованого сьогодні):
--   * 0010 DOWN — таблиці пошуку, подія індексу, ЧПУ /poshuk;
--   * 0008 DOWN — повертає модулі в макет головної (oc_layout_module);
--   * 0006 DOWN — таблиця оренди, події каталогу, ліміт товарів;
--   * 0005 DOWN — події теми «Крістал»;
--   * тему повертає на sauco (значення точно як у дампі прода від 09.11 10:48).
--
-- Міграції 0002, 0003, 0004 НЕ відкочуються: вони були застосовані ще до
-- сьогоднішнього деплою (є в дампі 10:48), сайт із ними працював.
--
-- Перед виконанням: phpMyAdmin → база matusuni_kozak → Експорт (бекап).
-- Ідемпотентно: повторний запуск нічого не ламає.
-- ---------------------------------------------------------------------------

-- 1. 0010_kristal_search — DOWN
DELETE FROM `{{PREFIX}}seo_url` WHERE `store_id` = 0 AND `query` = 'extension/kristal/search' AND `keyword` = 'poshuk';
DELETE FROM `{{PREFIX}}event` WHERE `code` = 'kristal_search_index';
DROP TABLE IF EXISTS `{{PREFIX}}kristal_search_log`;
DROP TABLE IF EXISTS `{{PREFIX}}kristal_search_word`;

-- 2. 0008_kristal_home — DOWN (повертає модулі головної)
INSERT IGNORE INTO `{{PREFIX}}layout_module` (`layout_module_id`, `layout_id`, `code`, `position`, `sort_order`)
SELECT `layout_module_id`, `layout_id`, `code`, `position`, `sort_order`
  FROM `{{PREFIX}}kristal_layout_backup` WHERE `migration` = '0008_kristal_home';

DROP TABLE IF EXISTS `{{PREFIX}}kristal_layout_backup`;

DELETE FROM `{{PREFIX}}event` WHERE `code` IN ('kristal_home_meta', 'kristal_home_view');

-- 3. 0006_kristal_product_rental — DOWN
UPDATE `{{PREFIX}}setting` s
  JOIN `{{PREFIX}}kristal_setting_backup` b
    ON b.`setting_id` = s.`setting_id`
   AND b.`migration` = '0006_kristal_product_rental'
   SET s.`value` = b.`value`;

DELETE FROM `{{PREFIX}}kristal_setting_backup` WHERE `migration` = '0006_kristal_product_rental';

DELETE FROM `{{PREFIX}}event` WHERE `code` IN ('kristal_catalog_category', 'kristal_catalog_product', 'kristal_catalog_admin_form',
  'kristal_catalog_admin_save', 'kristal_catalog_admin_copy', 'kristal_catalog_admin_delete');

DROP TABLE IF EXISTS `{{PREFIX}}kristal_product_rental`;

-- 4. 0005_kristal_theme_events — DOWN
DELETE FROM `{{PREFIX}}event` WHERE `code` IN ('kristal_theme_header', 'kristal_theme_footer', 'kristal_theme_template',
  'kristal_theme_page', 'kristal_theme_skip_menu', 'kristal_theme_skip_cart', 'kristal_menu_flush');

-- 5. Тема вітрини назад на sauco (як у дампі прода 09.11 10:48)
UPDATE `{{PREFIX}}setting` SET `value` = 'default' WHERE `store_id` = 0 AND `key` = 'config_theme';
UPDATE `{{PREFIX}}setting` SET `value` = 'sauco'   WHERE `store_id` = 0 AND `key` = 'theme_default_directory';
UPDATE `{{PREFIX}}setting` SET `value` = '1'       WHERE `store_id` = 0 AND `key` = 'theme_default_status';

-- 6. Відмітки про міграції, яких на проді більше немає (щоб make migrate-status не брехав)
DELETE FROM `{{PREFIX}}kristal_migration` WHERE `version` IN ('0005', '0006', '0008', '0010');

-- ---------------------------------------------------------------------------
-- Контроль: після виконання
--   * theme_default_directory = sauco;
--   * у макеті головної знову є модулі (home_modules > 0);
--   * подій kristal_* — 0 (лишились тільки 0002–0004, яких не чіпаємо);
--   * https://orendaposudu.com/ віддає 200.
-- ---------------------------------------------------------------------------
SELECT `key`, `value` FROM `{{PREFIX}}setting`
 WHERE `store_id` = 0
   AND `key` IN ('config_theme', 'theme_default_directory', 'theme_default_status')
 ORDER BY `key`;

SELECT COUNT(*) AS home_modules
  FROM `{{PREFIX}}layout_module` lm
  JOIN `{{PREFIX}}layout_route` lr ON (lr.`layout_id` = lm.`layout_id` AND lr.`route` = 'common/home' AND lr.`store_id` = 0);

SELECT COUNT(*) AS kristal_events FROM `{{PREFIX}}event` WHERE `code` LIKE 'kristal%';
