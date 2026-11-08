-- ---------------------------------------------------------------------------
-- 0005_kristal_theme_events — DOWN
-- Прибирає події теми «Крістал». Перед відкатом поверніть у адмінці тему `sauco`.
-- ---------------------------------------------------------------------------

DELETE FROM `{{PREFIX}}event` WHERE `code` IN ('kristal_theme_header', 'kristal_theme_footer', 'kristal_theme_template',
  'kristal_theme_page', 'kristal_theme_skip_menu', 'kristal_theme_skip_cart', 'kristal_menu_flush');
