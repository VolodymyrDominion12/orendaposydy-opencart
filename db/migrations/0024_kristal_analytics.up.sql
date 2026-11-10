-- ---------------------------------------------------------------------------
-- 0024_kristal_analytics — UP
-- Специфікація: specs/015-analytics/spec.md
-- ---------------------------------------------------------------------------

DELETE FROM `{{PREFIX}}setting` WHERE `code` = 'module_kristal_analytics';

INSERT INTO `{{PREFIX}}setting` (`store_id`, `code`, `key`, `value`, `serialized`) VALUES
  (0, 'module_kristal_analytics', 'module_kristal_analytics_status', '1', 0),
  (0, 'module_kristal_analytics', 'module_kristal_analytics_gtm_id', '', 0),
  (0, 'module_kristal_analytics', 'module_kristal_analytics_ga4_id', '', 0),
  (0, 'module_kristal_analytics', 'module_kristal_analytics_consent', '1', 0);
