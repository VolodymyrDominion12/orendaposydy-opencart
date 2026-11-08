-- ---------------------------------------------------------------------------
-- 0005_kristal_theme_events — UP
-- Специфікація: specs/003-theme-kristal/plan.md («Механізми»)
--
-- Події теми «Крістал». Схема БД не змінюється — лише рядки в {{PREFIX}}event.
-- Усі обробники нічого не роблять, поки в адмінці не вибрано каталог теми `kristal`.
-- Ідемпотентно: спершу прибираємо свої коди, потім вставляємо.
-- kristal_theme_template має sort_order 600: після event/theme ядра (500), до event/language (998).
-- ---------------------------------------------------------------------------

DELETE FROM `{{PREFIX}}event` WHERE `code` IN ('kristal_theme_header', 'kristal_theme_footer', 'kristal_theme_template',
  'kristal_theme_page', 'kristal_theme_skip_menu', 'kristal_theme_skip_cart', 'kristal_menu_flush');

INSERT INTO `{{PREFIX}}event` (`code`, `trigger`, `action`, `status`, `sort_order`) VALUES
  ('kristal_theme_header',    'catalog/view/common/header/before',               'extension/kristal/theme/header',   1, 0),
  ('kristal_theme_footer',    'catalog/view/common/footer/before',               'extension/kristal/theme/footer',   1, 0),
  ('kristal_theme_template',  'catalog/view/*/before',                           'extension/kristal/theme/template', 1, 600),
  ('kristal_theme_page',      'catalog/view/*/after',                            'extension/kristal/theme/page',     1, 0),
  ('kristal_theme_skip_menu', 'catalog/controller/common/menu/before',           'extension/kristal/theme/skip',     1, 0),
  ('kristal_theme_skip_cart', 'catalog/controller/common/cart/before',           'extension/kristal/theme/skip',     1, 0),
  ('kristal_menu_flush',      'admin/model/catalog/category/addCategory/after',    'extension/kristal/cache/flushMenu', 1, 0),
  ('kristal_menu_flush',      'admin/model/catalog/category/editCategory/after',   'extension/kristal/cache/flushMenu', 1, 0),
  ('kristal_menu_flush',      'admin/model/catalog/category/deleteCategory/after', 'extension/kristal/cache/flushMenu', 1, 0);
