-- ---------------------------------------------------------------------------
-- 0023_kristal_info_pages — DOWN
-- ---------------------------------------------------------------------------

DELETE FROM `{{PREFIX}}seo_url` WHERE `query` IN (
  'information_id=4',
  'information_id=5',
  'information_id=6',
  'information_id=13',
  'information_id=14',
  'information/contact'
) OR `keyword` IN (
  'pro-nas',
  'umovy-orendy',
  'dostavka-ta-oplata',
  'dlia-biznesu',
  'faq',
  'kontakty'
);

DELETE FROM `{{PREFIX}}information_to_layout` WHERE `information_id` IN (13, 14);
DELETE FROM `{{PREFIX}}information_to_store` WHERE `information_id` IN (13, 14);
DELETE FROM `{{PREFIX}}information_description` WHERE `information_id` IN (13, 14);
DELETE FROM `{{PREFIX}}information` WHERE `information_id` IN (13, 14);

DELETE FROM `{{PREFIX}}kristal_redirect` WHERE `old_path` IN (
  '/oplata',
  '/dostavka',
  '/perevagi-kateringu',
  '/nashi-partneri',
  '/o-nas'
);
