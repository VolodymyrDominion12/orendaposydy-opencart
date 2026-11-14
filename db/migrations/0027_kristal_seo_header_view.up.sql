-- ---------------------------------------------------------------------------
-- 0027_kristal_seo_header_view — UP
-- Специфікація: specs/011-seo (canonical підкатегорій)
--
-- Подія view/common/header/before: замінює canonical ядра для сторінки категорії
-- на повний шлях (path=86_145). Ядро product/category.php бере останній category_id,
-- тому /posud/tarilky отримував canonical /tarilky.
-- Для фільтрів canonical дає extension/kristal/filter (подія kristal_filter).
-- Схема БД не змінюється. Ідемпотентно.
-- ---------------------------------------------------------------------------

DELETE FROM `{{PREFIX}}event`
 WHERE `code` = 'kristal_seo_catalog'
   AND `trigger` = 'catalog/view/common/header/before'
   AND `action` = 'extension/kristal/seo/headerView';

INSERT INTO `{{PREFIX}}event` (`code`, `trigger`, `action`, `status`, `sort_order`) VALUES
  ('kristal_seo_catalog', 'catalog/view/common/header/before', 'extension/kristal/seo/headerView', 1, 20);
