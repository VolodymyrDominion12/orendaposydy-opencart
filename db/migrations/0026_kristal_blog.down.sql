-- 0026_kristal_blog.down.sql
-- Відкат фічі 013: Блог та експертні статті (kristal_blog)

DROP TABLE IF EXISTS `oc_kristal_blog_post_related_product`;
DROP TABLE IF EXISTS `oc_kristal_blog_post_to_category`;
DROP TABLE IF EXISTS `oc_kristal_blog_post`;
DROP TABLE IF EXISTS `oc_kristal_blog_category`;

DELETE FROM `oc_seo_url` WHERE `query` IN (
  'extension/kristal/blog',
  'post_id=1',
  'post_id=2',
  'post_id=3'
);
