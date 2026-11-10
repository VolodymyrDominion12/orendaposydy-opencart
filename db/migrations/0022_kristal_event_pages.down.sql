-- ---------------------------------------------------------------------------
-- 0022_kristal_event_pages — DOWN
-- ---------------------------------------------------------------------------

DELETE FROM `{{PREFIX}}seo_url` WHERE `query` IN (
  'extension/kristal/kit/buffet',
  'extension/kristal/kit/catering',
  'extension/kristal/kit/corporate'
) OR `keyword` IN ('furshet', 'keiterynh', 'korporatyv');

DELETE FROM `{{PREFIX}}kristal_kit_item` WHERE `kit_id` IN (4, 5, 6, 7, 8, 9, 10);
DELETE FROM `{{PREFIX}}kristal_kit` WHERE `kit_id` IN (4, 5, 6, 7, 8, 9, 10);
