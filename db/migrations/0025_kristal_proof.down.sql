-- 0025_kristal_proof.down.sql
-- Відкат фічі 014: Портфоліо кейсів подій та відгуки клієнтів (kristal_proof)

DROP TABLE IF EXISTS `oc_kristal_case_product`;
DROP TABLE IF EXISTS `oc_kristal_case_image`;
DROP TABLE IF EXISTS `oc_kristal_case`;
DROP TABLE IF EXISTS `oc_kristal_testimonial`;

DELETE FROM `oc_seo_url` WHERE `query` IN (
  'extension/kristal/case',
  'extension/kristal/testimonial',
  'case_id=1',
  'case_id=2',
  'case_id=3',
  'case_id=4'
);
