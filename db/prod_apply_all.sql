-- ==========================================
-- FILE: db/restore_admin_permissions.sql
-- ==========================================
UPDATE `oc_user_group` SET `permission` = '{"access": ["catalog\\/attribute", "catalog\\/attribute_group", "catalog\\/category", "catalog\\/download", "catalog\\/filter", "catalog\\/information", "catalog\\/manufacturer", "catalog\\/option", "catalog\\/product", "catalog\\/recurring", "catalog\\/review", "common\\/column_left", "common\\/developer", "common\\/filemanager", "common\\/profile", "common\\/security", "customer\\/custom_field", "customer\\/customer", "customer\\/customer_approval", "customer\\/customer_group", "design\\/banner", "design\\/layout", "design\\/theme", "design\\/translation", "design\\/seo_url", "event\\/statistics", "event\\/theme", "extension\\/advertise\\/google", "extension\\/analytics\\/google", "extension\\/captcha\\/basic", "extension\\/captcha\\/google", "extension\\/dashboard\\/activity", "extension\\/dashboard\\/chart", "extension\\/dashboard\\/customer", "extension\\/dashboard\\/map", "extension\\/dashboard\\/online", "extension\\/dashboard\\/order", "extension\\/dashboard\\/recent", "extension\\/dashboard\\/sale", "extension\\/extension\\/advertise", "extension\\/extension\\/analytics", "extension\\/extension\\/captcha", "extension\\/extension\\/dashboard", "extension\\/extension\\/feed", "extension\\/extension\\/fraud", "extension\\/extension\\/menu", "extension\\/extension\\/module", "extension\\/extension\\/payment", "extension\\/extension\\/report", "extension\\/extension\\/shipping", "extension\\/extension\\/theme", "extension\\/extension\\/total", "extension\\/feed\\/google_base", "extension\\/feed\\/google_sitemap", "extension\\/feed\\/openbaypro", "extension\\/fraud\\/fraudlabspro", "extension\\/fraud\\/ip", "extension\\/fraud\\/maxmind", "extension\\/marketing\\/remarketing", "extension\\/module\\/account", "extension\\/module\\/amazon_login", "extension\\/module\\/amazon_pay", "extension\\/module\\/banner", "extension\\/module\\/bestseller", "extension\\/module\\/carousel", "extension\\/module\\/category", "extension\\/module\\/divido_calculator", "extension\\/module\\/ebay_listing", "extension\\/module\\/featured", "extension\\/module\\/filter", "extension\\/module\\/google_hangouts", "extension\\/module\\/html", "extension\\/module\\/information", "extension\\/module\\/klarna_checkout_module", "extension\\/module\\/latest", "extension\\/module\\/laybuy_layout", "extension\\/module\\/pilibaba_button", "extension\\/module\\/pp_button", "extension\\/module\\/pp_login", "extension\\/module\\/sagepay_direct_cards", "extension\\/module\\/sagepay_server_cards", "extension\\/module\\/slideshow", "extension\\/module\\/special", "extension\\/module\\/store", "extension\\/openbay\\/amazon", "extension\\/openbay\\/amazon_listing", "extension\\/openbay\\/amazon_product", "extension\\/openbay\\/amazonus", "extension\\/openbay\\/amazonus_listing", "extension\\/openbay\\/amazonus_product", "extension\\/openbay\\/ebay", "extension\\/openbay\\/ebay_profile", "extension\\/openbay\\/ebay_template", "extension\\/openbay\\/etsy", "extension\\/openbay\\/etsy_product", "extension\\/openbay\\/etsy_shipping", "extension\\/openbay\\/etsy_shop", "extension\\/openbay\\/fba", "extension\\/payment\\/amazon_login_pay", "extension\\/payment\\/authorizenet_aim", "extension\\/payment\\/authorizenet_sim", "extension\\/payment\\/bank_transfer", "extension\\/payment\\/bluepay_hosted", "extension\\/payment\\/bluepay_redirect", "extension\\/payment\\/cardconnect", "extension\\/payment\\/cardinity", "extension\\/payment\\/cheque", "extension\\/payment\\/cod", "extension\\/payment\\/divido", "extension\\/payment\\/eway", "extension\\/payment\\/firstdata", "extension\\/payment\\/firstdata_remote", "extension\\/payment\\/free_checkout", "extension\\/payment\\/g2apay", "extension\\/payment\\/globalpay", "extension\\/payment\\/globalpay_remote", "extension\\/payment\\/klarna_account", "extension\\/payment\\/klarna_checkout", "extension\\/payment\\/klarna_invoice", "extension\\/payment\\/laybuy", "extension\\/payment\\/liqpay", "extension\\/payment\\/nochex", "extension\\/payment\\/paymate", "extension\\/payment\\/paypoint", "extension\\/payment\\/payza", "extension\\/payment\\/perpetual_payments", "extension\\/payment\\/pilibaba", "extension\\/payment\\/pp_express", "extension\\/payment\\/pp_payflow", "extension\\/payment\\/pp_payflow_iframe", "extension\\/payment\\/pp_pro", "extension\\/payment\\/pp_pro_iframe", "extension\\/payment\\/pp_standard", "extension\\/payment\\/realex", "extension\\/payment\\/realex_remote", "extension\\/payment\\/sagepay_direct", "extension\\/payment\\/sagepay_server", "extension\\/payment\\/sagepay_us", "extension\\/payment\\/securetrading_pp", "extension\\/payment\\/securetrading_ws", "extension\\/payment\\/skrill", "extension\\/payment\\/twocheckout", "extension\\/payment\\/web_payment_software", "extension\\/payment\\/worldpay", "extension\\/module\\/pp_braintree_button", "extension\\/payment\\/pp_braintree", "extension\\/report\\/customer_activity", "extension\\/report\\/customer_order", "extension\\/report\\/customer_reward", "extension\\/report\\/customer_search", "extension\\/report\\/customer_transaction", "extension\\/report\\/marketing", "extension\\/report\\/product_purchased", "extension\\/report\\/product_viewed", "extension\\/report\\/sale_coupon", "extension\\/report\\/sale_order", "extension\\/report\\/sale_return", "extension\\/report\\/sale_shipping", "extension\\/report\\/sale_tax", "extension\\/shipping\\/auspost", "extension\\/shipping\\/ec_ship", "extension\\/shipping\\/fedex", "extension\\/shipping\\/flat", "extension\\/shipping\\/free", "extension\\/shipping\\/item", "extension\\/shipping\\/parcelforce_48", "extension\\/shipping\\/pickup", "extension\\/shipping\\/royal_mail", "extension\\/shipping\\/ups", "extension\\/shipping\\/usps", "extension\\/shipping\\/weight", "extension\\/theme\\/default", "extension\\/total\\/coupon", "extension\\/total\\/credit", "extension\\/total\\/handling", "extension\\/total\\/klarna_fee", "extension\\/total\\/low_order_fee", "extension\\/total\\/reward", "extension\\/total\\/shipping", "extension\\/total\\/sub_total", "extension\\/total\\/tax", "extension\\/total\\/total", "extension\\/total\\/voucher", "localisation\\/country", "localisation\\/currency", "localisation\\/geo_zone", "localisation\\/language", "localisation\\/length_class", "localisation\\/location", "localisation\\/order_status", "localisation\\/return_action", "localisation\\/return_reason", "localisation\\/return_status", "localisation\\/stock_status", "localisation\\/tax_class", "localisation\\/tax_rate", "localisation\\/weight_class", "localisation\\/zone", "mail\\/affiliate", "mail\\/customer", "mail\\/forgotten", "mail\\/return", "mail\\/reward", "mail\\/transaction", "marketing\\/contact", "marketing\\/coupon", "marketing\\/marketing", "marketplace\\/api", "marketplace\\/event", "marketplace\\/extension", "marketplace\\/install", "marketplace\\/installer", "marketplace\\/marketplace", "marketplace\\/modification", "marketplace\\/openbay", "report\\/online", "report\\/report", "report\\/statistics", "sale\\/order", "sale\\/recurring", "sale\\/return", "sale\\/voucher", "sale\\/voucher_theme", "setting\\/setting", "setting\\/store", "startup\\/error", "startup\\/event", "startup\\/login", "startup\\/permission", "startup\\/router", "startup\\/sass", "startup\\/startup", "tool\\/backup", "tool\\/log", "tool\\/upload", "user\\/api", "user\\/user", "user\\/user_permission", "extension\\/module\\/html", "extension\\/module\\/banner", "extension\\/module\\/carousel", "extension\\/module\\/category", "extension\\/module\\/featured", "extension\\/module\\/slideshow", "extension\\/module\\/sms_alert", "extension\\/shipping\\/pickup", "extension\\/payment\\/oplata", "extension\\/shipping\\/free", "extension\\/shipping\\/flat", "extension\\/shipping\\/free", "extension\\/module\\/notifications_in_telegram", "extension\\/feed\\/google_base", "extension\\/feed\\/google_sitemap", "extension\\/module\\/kristal_search", "extension\\/module\\/kristal_import", "extension\\/module\\/kristal_filter", "extension\\/kristal\\/lead", "extension\\/kristal\\/kit", "extension\\/kristal\\/calculator", "extension/module/kristal_core", "extension/module/kristal_search", "extension/module/kristal_import", "extension/module/kristal_filter", "extension/module/kristal_home", "extension/module/kristal_seo", "extension/module/kristal_redirect", "extension/module/kristal_analytics", "extension/module/kristal_proof", "extension/module/kristal_blog", "extension/kristal/lead", "extension/kristal/kit", "extension/kristal/calculator", "extension/kristal/checkout"], "modify": ["catalog\\/attribute", "catalog\\/attribute_group", "catalog\\/category", "catalog\\/download", "catalog\\/filter", "catalog\\/information", "catalog\\/manufacturer", "catalog\\/option", "catalog\\/product", "catalog\\/recurring", "catalog\\/review", "common\\/column_left", "common\\/developer", "common\\/filemanager", "common\\/profile", "common\\/security", "customer\\/custom_field", "customer\\/customer", "customer\\/customer_approval", "customer\\/customer_group", "design\\/banner", "design\\/layout", "design\\/theme", "design\\/translation", "design\\/seo_url", "event\\/statistics", "event\\/theme", "extension\\/advertise\\/google", "extension\\/analytics\\/google", "extension\\/captcha\\/basic", "extension\\/captcha\\/google", "extension\\/dashboard\\/activity", "extension\\/dashboard\\/chart", "extension\\/dashboard\\/customer", "extension\\/dashboard\\/map", "extension\\/dashboard\\/online", "extension\\/dashboard\\/order", "extension\\/dashboard\\/recent", "extension\\/dashboard\\/sale", "extension\\/extension\\/advertise", "extension\\/extension\\/analytics", "extension\\/extension\\/captcha", "extension\\/extension\\/dashboard", "extension\\/extension\\/feed", "extension\\/extension\\/fraud", "extension\\/extension\\/menu", "extension\\/extension\\/module", "extension\\/extension\\/payment", "extension\\/extension\\/report", "extension\\/extension\\/shipping", "extension\\/extension\\/theme", "extension\\/extension\\/total", "extension\\/feed\\/google_base", "extension\\/feed\\/google_sitemap", "extension\\/feed\\/openbaypro", "extension\\/fraud\\/fraudlabspro", "extension\\/fraud\\/ip", "extension\\/fraud\\/maxmind", "extension\\/marketing\\/remarketing", "extension\\/module\\/account", "extension\\/module\\/amazon_login", "extension\\/module\\/amazon_pay", "extension\\/module\\/banner", "extension\\/module\\/bestseller", "extension\\/module\\/carousel", "extension\\/module\\/category", "extension\\/module\\/divido_calculator", "extension\\/module\\/ebay_listing", "extension\\/module\\/featured", "extension\\/module\\/filter", "extension\\/module\\/google_hangouts", "extension\\/module\\/html", "extension\\/module\\/information", "extension\\/module\\/klarna_checkout_module", "extension\\/module\\/latest", "extension\\/module\\/laybuy_layout", "extension\\/module\\/pilibaba_button", "extension\\/module\\/pp_button", "extension\\/module\\/pp_login", "extension\\/module\\/sagepay_direct_cards", "extension\\/module\\/sagepay_server_cards", "extension\\/module\\/slideshow", "extension\\/module\\/special", "extension\\/module\\/store", "extension\\/openbay\\/amazon", "extension\\/openbay\\/amazon_listing", "extension\\/openbay\\/amazon_product", "extension\\/openbay\\/amazonus", "extension\\/openbay\\/amazonus_listing", "extension\\/openbay\\/amazonus_product", "extension\\/openbay\\/ebay", "extension\\/openbay\\/ebay_profile", "extension\\/openbay\\/ebay_template", "extension\\/openbay\\/etsy", "extension\\/openbay\\/etsy_product", "extension\\/openbay\\/etsy_shipping", "extension\\/openbay\\/etsy_shop", "extension\\/openbay\\/fba", "extension\\/payment\\/amazon_login_pay", "extension\\/payment\\/authorizenet_aim", "extension\\/payment\\/authorizenet_sim", "extension\\/payment\\/bank_transfer", "extension\\/payment\\/bluepay_hosted", "extension\\/payment\\/bluepay_redirect", "extension\\/payment\\/cardconnect", "extension\\/payment\\/cardinity", "extension\\/payment\\/cheque", "extension\\/payment\\/cod", "extension\\/payment\\/divido", "extension\\/payment\\/eway", "extension\\/payment\\/firstdata", "extension\\/payment\\/firstdata_remote", "extension\\/payment\\/free_checkout", "extension\\/payment\\/g2apay", "extension\\/payment\\/globalpay", "extension\\/payment\\/globalpay_remote", "extension\\/payment\\/klarna_account", "extension\\/payment\\/klarna_checkout", "extension\\/payment\\/klarna_invoice", "extension\\/payment\\/laybuy", "extension\\/payment\\/liqpay", "extension\\/payment\\/nochex", "extension\\/payment\\/paymate", "extension\\/payment\\/paypoint", "extension\\/payment\\/payza", "extension\\/payment\\/perpetual_payments", "extension\\/payment\\/pilibaba", "extension\\/payment\\/pp_express", "extension\\/payment\\/pp_payflow", "extension\\/payment\\/pp_payflow_iframe", "extension\\/payment\\/pp_pro", "extension\\/payment\\/pp_pro_iframe", "extension\\/payment\\/pp_standard", "extension\\/payment\\/realex", "extension\\/payment\\/realex_remote", "extension\\/payment\\/sagepay_direct", "extension\\/payment\\/sagepay_server", "extension\\/payment\\/sagepay_us", "extension\\/payment\\/securetrading_pp", "extension\\/payment\\/securetrading_ws", "extension\\/payment\\/skrill", "extension\\/payment\\/twocheckout", "extension\\/payment\\/web_payment_software", "extension\\/payment\\/worldpay", "extension\\/module\\/pp_braintree_button", "extension\\/payment\\/pp_braintree", "extension\\/report\\/customer_activity", "extension\\/report\\/customer_order", "extension\\/report\\/customer_reward", "extension\\/report\\/customer_search", "extension\\/report\\/customer_transaction", "extension\\/report\\/marketing", "extension\\/report\\/product_purchased", "extension\\/report\\/product_viewed", "extension\\/report\\/sale_coupon", "extension\\/report\\/sale_order", "extension\\/report\\/sale_return", "extension\\/report\\/sale_shipping", "extension\\/report\\/sale_tax", "extension\\/shipping\\/auspost", "extension\\/shipping\\/ec_ship", "extension\\/shipping\\/fedex", "extension\\/shipping\\/flat", "extension\\/shipping\\/free", "extension\\/shipping\\/item", "extension\\/shipping\\/parcelforce_48", "extension\\/shipping\\/pickup", "extension\\/shipping\\/royal_mail", "extension\\/shipping\\/ups", "extension\\/shipping\\/usps", "extension\\/shipping\\/weight", "extension\\/theme\\/default", "extension\\/total\\/coupon", "extension\\/total\\/credit", "extension\\/total\\/handling", "extension\\/total\\/klarna_fee", "extension\\/total\\/low_order_fee", "extension\\/total\\/reward", "extension\\/total\\/shipping", "extension\\/total\\/sub_total", "extension\\/total\\/tax", "extension\\/total\\/total", "extension\\/total\\/voucher", "localisation\\/country", "localisation\\/currency", "localisation\\/geo_zone", "localisation\\/language", "localisation\\/length_class", "localisation\\/location", "localisation\\/order_status", "localisation\\/return_action", "localisation\\/return_reason", "localisation\\/return_status", "localisation\\/stock_status", "localisation\\/tax_class", "localisation\\/tax_rate", "localisation\\/weight_class", "localisation\\/zone", "mail\\/affiliate", "mail\\/customer", "mail\\/forgotten", "mail\\/return", "mail\\/reward", "mail\\/transaction", "marketing\\/contact", "marketing\\/coupon", "marketing\\/marketing", "marketplace\\/event", "marketplace\\/api", "marketplace\\/extension", "marketplace\\/install", "marketplace\\/installer", "marketplace\\/marketplace", "marketplace\\/modification", "marketplace\\/openbay", "report\\/online", "report\\/report", "report\\/statistics", "sale\\/order", "sale\\/recurring", "sale\\/return", "sale\\/voucher", "sale\\/voucher_theme", "setting\\/setting", "setting\\/store", "startup\\/error", "startup\\/event", "startup\\/login", "startup\\/permission", "startup\\/router", "startup\\/sass", "startup\\/startup", "tool\\/backup", "tool\\/log", "tool\\/upload", "user\\/api", "user\\/user", "user\\/user_permission", "extension\\/module\\/html", "extension\\/module\\/banner", "extension\\/module\\/carousel", "extension\\/module\\/category", "extension\\/module\\/featured", "extension\\/module\\/slideshow", "extension\\/module\\/sms_alert", "extension\\/shipping\\/pickup", "extension\\/payment\\/oplata", "extension\\/shipping\\/free", "extension\\/shipping\\/flat", "extension\\/shipping\\/free", "extension\\/module\\/notifications_in_telegram", "extension\\/feed\\/google_base", "extension\\/feed\\/google_sitemap", "extension\\/module\\/kristal_search", "extension\\/module\\/kristal_import", "extension\\/module\\/kristal_filter", "extension\\/kristal\\/lead", "extension\\/kristal\\/kit", "extension\\/kristal\\/calculator", "extension/module/kristal_core", "extension/module/kristal_search", "extension/module/kristal_import", "extension/module/kristal_filter", "extension/module/kristal_home", "extension/module/kristal_seo", "extension/module/kristal_redirect", "extension/module/kristal_analytics", "extension/module/kristal_proof", "extension/module/kristal_blog", "extension/kristal/lead", "extension/kristal/kit", "extension/kristal/calculator", "extension/kristal/checkout"]}' WHERE `user_group_id` = 1;


-- ==========================================
-- FILE: db/migrations/0020_kristal_seo.up.sql
-- ==========================================
-- ---------------------------------------------------------------------------
-- 0020_kristal_seo — UP
-- Специфікація: specs/011-seo/plan.md
--
-- 1) kristal_seo_meta — збереження окремого H1 та SEO-тексту (нижній опис) для категорій/товарів/сторінок.
-- 2) Події:
--    kristal_seo_catalog: додавання meta/canonical/noindex/json-ld у header, підміна H1 та вивід SEO-тексту.
--    kristal_seo_flush: скидання кешу SEO при змінах товарів/категорій в адмінці.
-- 3) ЧПУ /sitemap.xml -> extension/kristal/seo/sitemap
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `oc_kristal_seo_meta` (
  `entity_type` VARCHAR(16) NOT NULL,
  `entity_id`   INT(11)     NOT NULL,
  `language_id` INT(11)     NOT NULL,
  `h1`          VARCHAR(255) NOT NULL DEFAULT '',
  `seo_text`    MEDIUMTEXT,
  PRIMARY KEY (`entity_type`, `entity_id`, `language_id`),
  KEY `idx_entity_id` (`entity_id`),
  KEY `idx_language_id` (`language_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

DELETE FROM `oc_event` WHERE `code` IN ('kristal_seo_catalog', 'kristal_seo_flush');

INSERT INTO `oc_event` (`code`, `trigger`, `action`, `status`, `sort_order`) VALUES
  ('kristal_seo_catalog', 'catalog/controller/common/header/before',           'extension/kristal/seo/headerBefore',  1, 10),
  ('kristal_seo_catalog', 'catalog/view/product/category/before',              'extension/kristal/seo/categoryView',  1, 10),
  ('kristal_seo_catalog', 'catalog/view/product/product/before',               'extension/kristal/seo/productView',   1, 10),
  ('kristal_seo_flush',   'admin/model/catalog/product/addProduct/after',      'extension/kristal/seo/flush',        1, 10),
  ('kristal_seo_flush',   'admin/model/catalog/product/editProduct/after',     'extension/kristal/seo/flush',        1, 10),
  ('kristal_seo_flush',   'admin/model/catalog/product/deleteProduct/after',   'extension/kristal/seo/flush',        1, 10),
  ('kristal_seo_flush',   'admin/model/catalog/category/addCategory/after',    'extension/kristal/seo/flush',        1, 10),
  ('kristal_seo_flush',   'admin/model/catalog/category/editCategory/after',   'extension/kristal/seo/flush',        1, 10),
  ('kristal_seo_flush',   'admin/model/catalog/category/deleteCategory/after', 'extension/kristal/seo/flush',        1, 10);

INSERT INTO `oc_seo_url` (`store_id`, `language_id`, `query`, `keyword`)
SELECT 0, l.`language_id`, 'extension/kristal/seo/sitemap', 'sitemap.xml'
  FROM `oc_language` l
 WHERE NOT EXISTS (SELECT 1 FROM `oc_seo_url` s WHERE s.`store_id` = 0 AND s.`keyword` = 'sitemap.xml')
   AND NOT EXISTS (SELECT 1 FROM `oc_seo_url` s WHERE s.`store_id` = 0 AND s.`language_id` = l.`language_id` AND s.`query` = 'extension/kristal/seo/sitemap');


-- ==========================================
-- FILE: db/migrations/0021_kristal_redirect.up.sql
-- ==========================================
-- ---------------------------------------------------------------------------
-- 0021_kristal_redirect — UP
-- Специфікація: specs/002-redirect/plan.md
--
-- 1) kristal_redirect — таблиця 301/302-редиректів зі старих URL.
-- 2) kristal_404_log — журнал неіснуючих сторінок для пошуку битих посилань.
-- 3) Подія kristal_redirect_check на catalog/controller/error/not_found/before.
-- 4) Початкові 301-редиректи зі старої структури (розділ «URL і 301-редиректи»).
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `oc_kristal_redirect` (
  `redirect_id` INT(11)      NOT NULL AUTO_INCREMENT,
  `old_path`    VARCHAR(255) NOT NULL,
  `new_path`    VARCHAR(255) NOT NULL,
  `code`        SMALLINT(4)  NOT NULL DEFAULT 301,
  `status`      TINYINT(1)   NOT NULL DEFAULT 1,
  `hits`        INT(11)      NOT NULL DEFAULT 0,
  `last_hit_at` DATETIME     DEFAULT NULL,
  PRIMARY KEY (`redirect_id`),
  UNIQUE KEY `uq_old_path` (`old_path`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `oc_kristal_404_log` (
  `path`        VARCHAR(255) NOT NULL,
  `hits`        INT(11)      NOT NULL DEFAULT 1,
  `referer`     VARCHAR(255) NOT NULL DEFAULT '',
  `last_at`     DATETIME     NOT NULL,
  PRIMARY KEY (`path`),
  KEY `idx_hits` (`hits`),
  KEY `idx_last_at` (`last_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

DELETE FROM `oc_event` WHERE `code` = 'kristal_redirect_check';

INSERT INTO `oc_event` (`code`, `trigger`, `action`, `status`, `sort_order`) VALUES
  ('kristal_redirect_check', 'catalog/controller/error/not_found/before', 'extension/kristal/redirect/check', 1, 0);

-- Базові 301-редиректи зі старої структури сайту
INSERT IGNORE INTO `oc_kristal_redirect` (`old_path`, `new_path`, `code`, `status`) VALUES
  ('/salati/bilij-posud',                                       '/posud/tarilky',               301, 1),
  ('/salati/m-yasni-stravi',                                   '/posud/tarilky',               301, 1),
  ('/salati/salatnici',                                        '/posud/salatnytsi',            301, 1),
  ('/salati/supnici',                                          '/posud/supnytsi',              301, 1),
  ('/salati/ditichnij-kompleksu',                              '/sklo-ta-kelykhy',             301, 1),
  ('/salati/stakani',                                          '/sklo-ta-kelykhy',             301, 1),
  ('/salati',                                                  '/stolovi-prybory',             301, 1),
  ('/salati/videlka',                                          '/stolovi-prybory/vydelky',     301, 1),
  ('/salati/lozhki',                                           '/stolovi-prybory',             301, 1),
  ('/salati/nozhi',                                            '/stolovi-prybory',             301, 1),
  ('/salati/ovochevi-salati',                                  '/stolovi-prybory',             301, 1),
  ('/orenda-prokat-eksklyuzivnogo-posudu',                     '/posud/ekskliuzyvnyi-posud',   301, 1),
  ('/orenda-prokat-marmitiv-chafindish-kastrul-skovoridok',     '/kukhonne-obladnannia/marmity', 301, 1),
  ('/orenda-kavovih-aparativ-termopotiv-termosiv-prizhimnih-griliv', '/kavove-obladnannia',    301, 1),
  ('/orenda-prokat-barni-stijki',                              '/barne-obladnannia/barni-stiiky', 301, 1),
  ('/orenda-prokat-barnih-stijok-ta-barnogo-inventarya',       '/barne-obladnannia/barni-stiiky', 301, 1),
  ('/orenda-prokat-mebliv',                                    '/mebli',                       301, 1),
  ('/orenda-prokat-shatriv-palatok-shalashiv-nakrittiv',        '/shatry',                      301, 1),
  ('/orenda-dekoru',                                           '/dekor',                       301, 1),
  ('/orenda-prokat-ekoposudu-ta-inventarya',                   '/ekoposud',                    301, 1);


-- ==========================================
-- FILE: db/migrations/0022_kristal_event_pages.up.sql
-- ==========================================
-- ---------------------------------------------------------------------------
-- 0022_kristal_event_pages — UP
-- Специфікація: specs/006-pages/spec.md
--
-- 1) Комплекти для сторінок подій: buffet, catering, corporate.
-- 2) SEO URLs для нових подій:
--    - extension/kristal/kit/buffet    -> furshet
--    - extension/kristal/kit/catering  -> keiterynh
--    - extension/kristal/kit/corporate -> korporatyv
-- ---------------------------------------------------------------------------

-- 1. Комплекти для Фуршету та кава-брейку (buffet)
INSERT INTO `oc_kristal_kit` (`kit_id`, `code`, `event_type`, `tier`, `name`, `badge`, `discount_pct`, `features`, `sort_order`, `status`, `created_at`, `updated_at`)
VALUES
  (4, 'buffet_basic', 'buffet', 'basic', 'Фуршет Базовий', '', 0.00,
   '[{"text":"Тарілка десертна 19 см","included":true},{"text":"Виделка десертна Classic","included":true},{"text":"Келих-флюте для шампанського","included":true},{"text":"Склянка для напоїв 350 мл","included":true},{"text":"Чашка з блюдцем та ложка","included":false},{"text":"Термопот / кавоварка","included":false}]',
   1, 1, NOW(), NOW()),
  (5, 'buffet_standard', 'buffet', 'standard', 'Фуршет + Кава-брейк', 'Популярний вибір', 5.00,
   '[{"text":"Тарілка десертна 19 см","included":true},{"text":"Виделка десертна Classic","included":true},{"text":"Келих-флюте для напоїв","included":true},{"text":"Склянка 350 мл для безалкогольного","included":true},{"text":"Чашка з блюдцем 200 мл та ложка","included":true},{"text":"Сервірувальні блюда для закусок","included":true},{"text":"Триярусна етажерка для десертів","included":false}]',
   2, 1, NOW(), NOW()),
  (6, 'buffet_premium', 'buffet', 'premium', 'Фуршет Преміум', '', 10.00,
   '[{"text":"Десертні тарілки Royal із золотим обідком","included":true},{"text":"Десертні виделки золоті Royal","included":true},{"text":"Келихи-купе для шампанського","included":true},{"text":"Чашки з блюдцем Royal та кавові ложки","included":true},{"text":"Триярусні етажерки для капкейків і фруктів","included":true},{"text":"Діспенсери для лимонадів з підставками","included":true}]',
   3, 1, NOW(), NOW())
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`), `badge` = VALUES(`badge`), `features` = VALUES(`features`);

-- Позиції комплектів фуршету
INSERT IGNORE INTO `oc_kristal_kit_item` (`kit_id`, `product_id`, `qty_per_guest`, `qty_fixed`, `sort_order`) VALUES
  -- Базовий (50003 десертна 1, 50020 виделка десертна 1, 50035 флюте 1, 50039 склянка 1)
  (4, 50003, 1.00, 0, 1),
  (4, 50020, 1.00, 0, 2),
  (4, 50035, 1.00, 0, 3),
  (4, 50039, 1.00, 0, 4),
  -- Стандарт (плюс 50018 чашка+блюдце 1, 50024 чайна ложка 1, 50013 блюдо 0.1)
  (5, 50003, 1.00, 0, 1),
  (5, 50020, 1.00, 0, 2),
  (5, 50035, 1.00, 0, 3),
  (5, 50039, 1.00, 0, 4),
  (5, 50018, 1.00, 0, 5),
  (5, 50024, 1.00, 0, 6),
  (5, 50013, 0.10, 0, 7),
  -- Преміум (Royal 50015, 50025, 50036 купе, 50018, 50014 етажерка 0.05, 50062 діспенсер 0.02)
  (6, 50015, 1.00, 0, 1),
  (6, 50025, 1.00, 0, 2),
  (6, 50036, 1.00, 0, 3),
  (6, 50039, 1.00, 0, 4),
  (6, 50018, 1.00, 0, 5),
  (6, 50025, 1.00, 0, 6),
  (6, 50014, 0.05, 0, 7);

-- 2. Комплекти для Кейтерингу (catering)
INSERT INTO `oc_kristal_kit` (`kit_id`, `code`, `event_type`, `tier`, `name`, `badge`, `discount_pct`, `features`, `sort_order`, `status`, `created_at`, `updated_at`)
VALUES
  (7, 'catering_basic', 'catering', 'basic', 'Кейтеринг Лінія роздачі', '', 0.00,
   '[{"text":"Тарілка обідня біла 27 см","included":true},{"text":"Виделка столова Classic","included":true},{"text":"Ніж столовий Classic","included":true},{"text":"Склянка універсальна 350 мл","included":true},{"text":"Чафінгдіш з підігрівом","included":false},{"text":"Термобокс для перевезення","included":false}]',
   1, 1, NOW(), NOW()),
  (8, 'catering_standard', 'catering', 'standard', 'Кейтеринг Повний стіл', 'Хіт для кейтерингів', 5.00,
   '[{"text":"Тарілка обідня та закусочна","included":true},{"text":"Прибори: виделка, ніж, ложка","included":true},{"text":"Келих для вина та склянка","included":true},{"text":"Чафінгдіші 9 л для гарячих страв","included":true},{"text":"Блюда сервірувальні овальні","included":true},{"text":"Глечики скляні 1.5 л для напоїв","included":true}]',
   2, 1, NOW(), NOW())
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`), `badge` = VALUES(`badge`), `features` = VALUES(`features`);

-- Позиції кейтерингу
INSERT IGNORE INTO `oc_kristal_kit_item` (`kit_id`, `product_id`, `qty_per_guest`, `qty_fixed`, `sort_order`) VALUES
  (7, 50001, 1.00, 0, 1),
  (7, 50019, 1.00, 0, 2),
  (7, 50027, 1.00, 0, 3),
  (7, 50039, 1.00, 0, 4),
  -- Стандарт
  (8, 50001, 1.00, 0, 1),
  (8, 50002, 1.00, 0, 2),
  (8, 50019, 1.00, 0, 3),
  (8, 50027, 1.00, 0, 4),
  (8, 50031, 1.00, 0, 5),
  (8, 50039, 1.00, 0, 6),
  (8, 50043, 0.03, 0, 7),
  (8, 50011, 0.10, 0, 8),
  (8, 50042, 0.05, 0, 9);

-- 3. Комплекти для Корпоративу (corporate)
INSERT INTO `oc_kristal_kit` (`kit_id`, `code`, `event_type`, `tier`, `name`, `badge`, `discount_pct`, `features`, `sort_order`, `status`, `created_at`, `updated_at`)
VALUES
  (9, 'corporate_standard', 'corporate', 'standard', 'Корпоратив Стандарт', 'Оптимальний', 0.00,
   '[{"text":"Тарілка обідня біла 27 см","included":true},{"text":"Тарілка закусочна біла 21 см","included":true},{"text":"Столові виделка та ніж Classic","included":true},{"text":"Келих для вина та келих для шампанського","included":true},{"text":"Склянка для віскі / води","included":true},{"text":"Салатниці та спільні блюда для подачі","included":true}]',
   1, 1, NOW(), NOW()),
  (10, 'corporate_premium', 'corporate', 'corporate_vip', 'Корпоратив VIP', 'Преміум сервірування', 5.00,
   '[{"text":"Посуд із золотим обідком Royal","included":true},{"text":"Золоті прибори Royal","included":true},{"text":"Келихи Royal 400 мл та купе","included":true},{"text":"Склянки для міцних напоїв","included":true},{"text":"Підставні тарілки ротанг або золото","included":true},{"text":"Скатертини круглі білі","included":true}]',
   2, 1, NOW(), NOW())
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`), `badge` = VALUES(`badge`), `features` = VALUES(`features`);

INSERT IGNORE INTO `oc_kristal_kit_item` (`kit_id`, `product_id`, `qty_per_guest`, `qty_fixed`, `sort_order`) VALUES
  (9, 50001, 1.00, 0, 1),
  (9, 50002, 1.00, 0, 2),
  (9, 50019, 1.00, 0, 3),
  (9, 50027, 1.00, 0, 4),
  (9, 50031, 1.00, 0, 5),
  (9, 50035, 1.00, 0, 6),
  (9, 50040, 1.00, 0, 7),
  (9, 50008, 0.15, 0, 8),
  -- VIP
  (10, 50015, 1.00, 0, 1),
  (10, 50002, 1.00, 0, 2),
  (10, 50021, 1.00, 0, 3),
  (10, 50029, 1.00, 0, 4),
  (10, 50033, 1.00, 0, 5),
  (10, 50036, 1.00, 0, 6),
  (10, 50040, 1.00, 0, 7),
  (10, 50005, 1.00, 0, 8),
  (10, 50077, 0.10, 0, 9);

-- 4. SEO URLs для нових сторінок подій
DELETE FROM `oc_seo_url` WHERE `query` IN (
  'extension/kristal/kit/buffet',
  'extension/kristal/kit/catering',
  'extension/kristal/kit/corporate'
) OR `keyword` IN ('furshet', 'keiterynh', 'korporatyv');

INSERT INTO `oc_seo_url` (`store_id`, `language_id`, `query`, `keyword`) VALUES
  (0, 2, 'extension/kristal/kit/buffet', 'furshet'),
  (0, 2, 'extension/kristal/kit/catering', 'keiterynh'),
  (0, 2, 'extension/kristal/kit/corporate', 'korporatyv');


-- ==========================================
-- FILE: db/migrations/0023_kristal_info_pages.up.sql
-- ==========================================
-- ---------------------------------------------------------------------------
-- 0023_kristal_info_pages — UP
-- Специфікація: specs/012-pages/spec.md
--
-- 1) Оновлення сторінок 4 («Про нас»), 5 («Умови оренди»), 6 («Доставка та оплата»).
-- 2) Створення сторінок 13 («Для бізнесу») та 14 («FAQ»).
-- 3) Прив'язка до магазину та макетів.
-- 4) ЧПУ для всіх сторінок та контактів:
--    - pro-nas
--    - umovy-orendy
--    - dostavka-ta-oplata
--    - dlia-biznesu
--    - faq
--    - kontakty (information/contact)
-- 5) 301-редиректи зі старих сторінок.
-- ---------------------------------------------------------------------------

-- Сторінка 4: Про нас
UPDATE `oc_information` SET `status` = 1, `sort_order` = 1 WHERE `information_id` = 4;
INSERT INTO `oc_information_description` (`information_id`, `language_id`, `title`, `description`, `meta_title`, `meta_description`, `meta_keyword`)
VALUES (
  4, 2,
  'Про нас',
  '<h2>Компанія «Крістал» — сервіс оренди посуду, меблів та обладнання для подій у Львові</h2><p>З 2013 року ми допомагаємо створювати незабутні весілля, фуршети, фестивалі, корпоративи та сімейні свята у Львові та області. Наша місія — звільнити вас від клопотів із пошуку, миття та транспортування інвентарю.</p><h3>Чому обирають «Крістал»</h3><ul><li><strong>Власний склад у Львові:</strong> понад 5 000 найменувань у наявності на вул. Богдана Хмельницького, 106.</li><li><strong>Ідеальна чистота:</strong> триступеневе миття у професійних посудомийних машинах при 85°C та фасування у закриті пластикові бокси.</li><li><strong>Великі обсяги:</strong> забезпечуємо заходи від невеликої вечірки на 10 осіб до масштабних банкетів на 500+ гостей.</li><li><strong>Оперативність:</strong> розрахунок кошторису за 15 хвилин та можливість термінової докомплектації замовлення в день події.</li><li><strong>Власний автопарк:</strong> пунктуальна доставка, вивантаження та можливість замовлення монтажу меблів і шатрів.</li></ul>',
  'Про компанію «Крістал» — оренда посуду та обладнання у Львові',
  'Оренда посуду, меблів та текстилю у Львові від компанії «Крістал». Власний склад з 2013 року, понад 5000 одиниць у наявності. Дізнайтесь більше про нас!',
  'про нас крістал, оренда посуду львів про компанію'
) ON DUPLICATE KEY UPDATE
  `title` = VALUES(`title`),
  `description` = VALUES(`description`),
  `meta_title` = VALUES(`meta_title`),
  `meta_description` = VALUES(`meta_description`);

-- Сторінка 5: Умови оренди
UPDATE `oc_information` SET `status` = 1, `sort_order` = 2 WHERE `information_id` = 5;
INSERT INTO `oc_information_description` (`information_id`, `language_id`, `title`, `description`, `meta_title`, `meta_description`, `meta_keyword`)
VALUES (
  5, 2,
  'Умови оренди',
  '<h2>Прості та прозорі умови оренди посуду й обладнання</h2><p>Ми прагнемо, щоб оренда посуду була максимально зручною та надійною для кожного клієнта. Ознайомтеся з основними правилами співпраці:</p><h3>1. Строк оренди</h3><p>Базовий тариф розраховано на <strong>24 години (1 добу)</strong> з моменту отримання на складі або доставки кур''єром. На другу добу діє знижка 30%, на третю і наступні — знижка 50% від вартості оренди.</p><h3>2. Бронювання та передоплата</h3><p>Для резервування необхідних позицій під вашу дату укладається замовлення та вноситься передоплата 30%. Залишок сплачується під час передачі інвентарю.</p><h3>3. Застава</h3><p>Для приватних клієнтів передбачено внесення гарантійної застави, яка повертається в повному обсязі після здачі та перевірки інвентарю. Для постійних партнерів (B2B) можлива оренда без застави за договором.</p><h3>4. Миття посуду</h3><p><strong>Вам не потрібно мити посуд після заходу!</strong> Професійне миття та дезінфекція вже включені у вартість. Достатньо лише очистити тарілки від залишків їжі та скласти в наші транспортувальні бокси.</p><h3>5. Бій та пошкодження</h3><p>Ми розуміємо, що на святах трапляються випадковості. У нас немає штрафів — у разі розбиття або втрати предмета сплачується лише його фіксована заставна вартість, зазначена в акті прийому-передачі.</p>',
  'Умови оренди посуду у Львові — правила, застава, терміни | Крістал',
  'Правила оренди посуду, меблів та текстилю у Львові. Умови внесення застави, строки оренди, безкоштовне миття та прозорі умови відшкодування бою.',
  'умови оренди посуду, застава оренда посуду львів'
) ON DUPLICATE KEY UPDATE
  `title` = VALUES(`title`),
  `description` = VALUES(`description`),
  `meta_title` = VALUES(`meta_title`),
  `meta_description` = VALUES(`meta_description`);

-- Сторінка 6: Доставка та оплата
UPDATE `oc_information` SET `status` = 1, `sort_order` = 3 WHERE `information_id` = 6;
INSERT INTO `oc_information_description` (`information_id`, `language_id`, `title`, `description`, `meta_title`, `meta_description`, `meta_keyword`)
VALUES (
  6, 2,
  'Доставка та оплата',
  '<h2>Зручна доставка по Львову та області і гнучкі способи оплати</h2><h3>Варіанти отримання замовлення</h3><ul><li><strong>Самовивіз зі складу:</strong> безкоштовно. Наш склад знаходиться за адресою: м. Львів, вул. Богдана Хмельницького, 106. Працюємо щодня з 9:00 до 20:00. Наші комірники допоможуть завантажити інвентар у ваш автомобіль.</li><li><strong>Кур''єрська доставка по Львову:</strong> вартість від 250 ₴ залежно від району та об''єму вантажу. Доставка здійснюється у зручний для вас часовий проміжок. При замовленні від 5 000 ₴ — доставка безкоштовна!</li><li><strong>Доставка по Львівській області:</strong> розраховується індивідуально (базовий тариф + кілометраж від межі міста).</li><li><strong>Монтаж та розстановка:</strong> за потреби наша команда розставить столи, змонтує шатри та підготує меблі до свята.</li></ul><h3>Способи оплати</h3><ul><li><strong>Онлайн-оплата на сайті:</strong> картками Visa та Mastercard через захищену платіжну систему Fondy, а також Apple Pay та Google Pay.</li><li><strong>Безготівковий розрахунок:</strong> виставляємо рахунок для юридичних осіб та ФОП з наданням усіх бухгалтерських документів (договір, рахунок, акт виконаних робіт).</li><li><strong>Оплата при отриманні:</strong> готівкою або через POS-термінал на нашому складі чи кур''єру під час вивантаження.</li></ul>',
  'Доставка та оплата оренди посуду у Львові | Крістал',
  'Умови доставки орендованого посуду по Львову та області. Самовивіз з вул. Б. Хмельницького 106. Оплата онлайн через Fondy, безготівковий розрахунок або готівкою.',
  'доставка посуду львів, оплата оренди'
) ON DUPLICATE KEY UPDATE
  `title` = VALUES(`title`),
  `description` = VALUES(`description`),
  `meta_title` = VALUES(`meta_title`),
  `meta_description` = VALUES(`meta_description`);

-- Сторінка 13: Для бізнесу (B2B)
INSERT INTO `oc_information` (`information_id`, `bottom`, `sort_order`, `status`)
VALUES (13, 1, 4, 1)
ON DUPLICATE KEY UPDATE `bottom` = 1, `status` = 1;

INSERT INTO `oc_information_description` (`information_id`, `language_id`, `title`, `description`, `meta_title`, `meta_description`, `meta_keyword`)
VALUES (
  13, 2,
  'Для бізнесу (B2B)',
  '<h2>Спеціальні умови для кейтерингів, ресторанів та event-агенцій</h2><p>Компанія «Крістал» є надійним підрядником для професіоналів індустрії гостинності та святкових заходів. Ми беремо на себе матеріально-технічне забезпечення ваших подій, щоб ви могли сфокусуватися на смаку страв та задоволенні гостей.</p><h3>Переваги партнерства з «Крістал»</h3><ul><li><strong>Партнерські знижки:</strong> спеціальна цінова сітка зі знижками до 20% для регулярних та об''ємних замовлень.</li><li><strong>Оренда без застави:</strong> можливість роботи за рамковим річним договором з відстрочкою платежу та без внесення грошової застави.</li><li><strong>Пріоритетне бронювання:</strong> гарантоване резервування обладнання навіть у пікові дати весільного та корпоративного сезону.</li><li><strong>Повний бухгалтерський супровід:</strong> працюємо офіційно з ПДВ або без ПДВ, швидко надаємо рахунки, акти та податкові накладні, підтримуємо сервіси електронного документообігу (Вчасно).</li><li><strong>Персональний менеджер:</strong> прямий контакт 24/7 для оперативного вирішення форс-мажорів та швидкої докомплектації замовлень.</li></ul><p>Зв''яжіться з нашим корпоративним відділом за телефоном <a href="tel:+380678277007"><strong>+38 (067) 827-70-07</strong></a> або залиште заявку на сайті, і ми надішлемо вам партнерський прайс та шаблон договору протягом 30 хвилин.</p>',
  'Оренда посуду для бізнесу та кейтерингу (B2B) у Львові | Крістал',
  'Партнерська програма для кейтерингів, ресторанів, весільних координаторів та event-агенцій у Львові. Знижки до 20%, робота за договором без застави, безготівковий розрахунок.',
  'b2b оренда посуду, посуд для кейтерингу партнерство'
) ON DUPLICATE KEY UPDATE
  `title` = VALUES(`title`),
  `description` = VALUES(`description`),
  `meta_title` = VALUES(`meta_title`),
  `meta_description` = VALUES(`meta_description`);

-- Сторінка 14: FAQ
INSERT INTO `oc_information` (`information_id`, `bottom`, `sort_order`, `status`)
VALUES (14, 1, 5, 1)
ON DUPLICATE KEY UPDATE `bottom` = 1, `status` = 1;

INSERT INTO `oc_information_description` (`information_id`, `language_id`, `title`, `description`, `meta_title`, `meta_description`, `meta_keyword`)
VALUES (
  14, 2,
  'Часті питання (FAQ)',
  '<h2>Відповіді на популярні запитання про оренду посуду</h2><div class="k-faq-list"><details open><summary>Чи потрібно мити посуд перед поверненням?</summary><p>Ні, миття повністю бере на себе наша компанія! Воно вже включено у вартість оренди. Вам достатньо лише очистити тарілки від залишків їжі та злити рідину з келихів, після чого скласти все у транспортувальні бокси.</p></details><details><summary>Як розраховується доба оренди?</summary><p>Стандартний строк оренди — 24 години. Наприклад, якщо ви забираєте інвентар у п''ятницю о 14:00, повернути його потрібно у суботу до 14:00. Якщо потрібен додатковий день, на нього діє знижка до 50%.</p></details><details><summary>Що робити, якщо під час свята щось розбилося?</summary><p>Нічого страшного, ми не накладаємо штрафів! У разі бою або втрати ви сплачуєте лише фіксовану вартість предмета за собівартістю, яка зазначена в накладній.</p></details><details><summary>Як внести передоплату та заставу?</summary><p>Для бронювання дати вноситься 30% передоплати. Застава вноситься під час отримання товару готівкою, карткою або блокуванням коштів і повертається відразу після повернення інвентарю.</p></details><details><summary>Чи можна забрати замовлення самостійно?</summary><p>Так, самовивіз безкоштовний з нашого складу у Львові на вул. Богдана Хмельницького, 106. Ми працюємо щодня з 9:00 до 20:00.</p></details><details><summary>За який час потрібно замовляти посуд?</summary><p>У високий сезон (травень–жовтень) радимо бронювати за 2–4 тижні. Проте за наявності інвентарю на складі ми приймаємо замовлення навіть день у день.</p></details></div>',
  'Часті питання про оренду посуду у Львові (FAQ) | Крістал',
  'Відповіді на запитання щодо оренди посуду, меблів та текстилю у Львові: строки оренди, правила застави, бій посуду, миття, доставка та способи оплати.',
  'faq оренда посуду, часті питання прокат посуду львів'
) ON DUPLICATE KEY UPDATE
  `title` = VALUES(`title`),
  `description` = VALUES(`description`),
  `meta_title` = VALUES(`meta_title`),
  `meta_description` = VALUES(`meta_description`);

-- Прив''язка до магазину 0
INSERT IGNORE INTO `oc_information_to_store` (`information_id`, `store_id`) VALUES
  (4, 0), (5, 0), (6, 0), (13, 0), (14, 0);

-- Прив''язка до макету 0
INSERT IGNORE INTO `oc_information_to_layout` (`information_id`, `store_id`, `layout_id`) VALUES
  (4, 0, 0), (5, 0, 0), (6, 0, 0), (13, 0, 0), (14, 0, 0);

-- SEO URLs для інформаційних сторінок та контактів
DELETE FROM `oc_seo_url` WHERE `query` IN (
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

INSERT INTO `oc_seo_url` (`store_id`, `language_id`, `query`, `keyword`) VALUES
  (0, 2, 'information_id=4', 'pro-nas'),
  (0, 2, 'information_id=5', 'umovy-orendy'),
  (0, 2, 'information_id=6', 'dostavka-ta-oplata'),
  (0, 2, 'information_id=13', 'dlia-biznesu'),
  (0, 2, 'information_id=14', 'faq'),
  (0, 2, 'information/contact', 'kontakty');

-- 301-редиректи зі старих шляхів
INSERT INTO `oc_kristal_redirect` (`old_path`, `new_path`, `code`, `status`) VALUES
  ('/oplata',               '/dostavka-ta-oplata', 301, 1),
  ('/dostavka',             '/dostavka-ta-oplata', 301, 1),
  ('/perevagi-kateringu',    '/dlia-biznesu',       301, 1),
  ('/nashi-partneri',       '/dlia-biznesu',       301, 1),
  ('/o-nas',                '/pro-nas',            301, 1)
ON DUPLICATE KEY UPDATE `new_path` = VALUES(`new_path`), `status` = 1;


-- ==========================================
-- FILE: db/migrations/0024_kristal_analytics.up.sql
-- ==========================================
-- ---------------------------------------------------------------------------
-- 0024_kristal_analytics — UP
-- Специфікація: specs/015-analytics/spec.md
-- ---------------------------------------------------------------------------

DELETE FROM `oc_setting` WHERE `code` = 'module_kristal_analytics';

INSERT INTO `oc_setting` (`store_id`, `code`, `key`, `value`, `serialized`) VALUES
  (0, 'module_kristal_analytics', 'module_kristal_analytics_status', '1', 0),
  (0, 'module_kristal_analytics', 'module_kristal_analytics_gtm_id', '', 0),
  (0, 'module_kristal_analytics', 'module_kristal_analytics_ga4_id', '', 0),
  (0, 'module_kristal_analytics', 'module_kristal_analytics_consent', '1', 0);


-- ==========================================
-- FILE: db/migrations/0025_kristal_proof.up.sql
-- ==========================================
-- 0025_kristal_proof.up.sql
-- Фіча 014: Портфоліо кейсів подій та відгуки клієнтів (kristal_proof)

CREATE TABLE IF NOT EXISTS `oc_kristal_case` (
  `case_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `event_type` varchar(64) NOT NULL DEFAULT 'wedding',
  `guests` int(11) NOT NULL DEFAULT 0,
  `location` varchar(255) NOT NULL DEFAULT '',
  `date_event` varchar(64) NOT NULL DEFAULT '',
  `summary` varchar(500) NOT NULL DEFAULT '',
  `description` mediumtext NOT NULL,
  `image` varchar(255) NOT NULL DEFAULT '',
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `status` tinyint(1) NOT NULL DEFAULT 1,
  `date_added` datetime NOT NULL,
  PRIMARY KEY (`case_id`),
  UNIQUE KEY `uq_slug` (`slug`),
  KEY `idx_status_sort` (`status`, `sort_order`),
  KEY `idx_event_type` (`event_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `oc_kristal_case_image` (
  `image_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `case_id` int(11) unsigned NOT NULL,
  `image` varchar(255) NOT NULL,
  `sort_order` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`image_id`),
  KEY `idx_case_id` (`case_id`, `sort_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `oc_kristal_case_product` (
  `case_id` int(11) unsigned NOT NULL,
  `product_id` int(11) unsigned NOT NULL,
  PRIMARY KEY (`case_id`, `product_id`),
  KEY `idx_product_id` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `oc_kristal_testimonial` (
  `testimonial_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `author_name` varchar(128) NOT NULL,
  `author_role` varchar(128) NOT NULL DEFAULT '',
  `rating` tinyint(1) NOT NULL DEFAULT 5,
  `text` text NOT NULL,
  `event_title` varchar(255) NOT NULL DEFAULT '',
  `source` varchar(64) NOT NULL DEFAULT 'Google',
  `source_url` varchar(255) NOT NULL DEFAULT '',
  `avatar` varchar(255) NOT NULL DEFAULT '',
  `date_added` date NOT NULL,
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `status` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`testimonial_id`),
  KEY `idx_status_sort` (`status`, `sort_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Посів демонстраційних кейсів портфоліо
INSERT INTO `oc_kristal_case` (`case_id`, `title`, `slug`, `event_type`, `guests`, `location`, `date_event`, `summary`, `description`, `image`, `sort_order`, `status`, `date_added`) VALUES
(1, 'Класичне весілля в Edem Resort Medical & SPA', 'vesillya-v-edem-resort', 'wedding', 120, 'Edem Resort, с. Стрілки', 'Вересень 2026', 'Елегантне весільне сервірування на 120 гостей: підставні золоті тарілки, келихи для вина та шампанського з золотим обідком, прибори Royal.', '<p>Масштабне весільне святкування у банкетному залі заміського комплексу Edem Resort. Концепція декору передбачала тепле світло, білосніжний текстиль та акценти благородного золота.</p><p>Для сервірування столів молодих та 12 круглих гостьових столів компанія «Крістал» надала повний комплект фарфору, дизайнерських столових приборів та преміального кришталевого скла. Усі келихи доставлено у брендованих захисних боксах безпосередньо в день монтажу локації.</p>', 'catalog/demo/banners/wedding-case.jpg', 1, 1, NOW()),
(2, 'Фуршет IT-конференції у Citadel Inn', 'furshet-it-konferentsiya-lviv', 'buffet', 250, 'Citadel Inn, м. Львів', 'Жовтень 2026', 'Організація безперервного фуршету та кава-пауз на 250 учасників: багаторівневі етажерки, порційний посуд, склянки та чашки для кави.', '<p>Дводенна міжнародна конференція розробників у панорамному залі Citadel Inn. Завдання полягало в забезпеченні швидкої та зручної подачі закусок і десертів під час 15-хвилинних перерв.</p><p>Використано понад 1200 одиниць порційного фуршетного посуду, соусники, підноси з нержавіючої сталі та триярусні етажерки для капкейків і десертів. Оренда посуду дала змогу організаторам уникнути витрат на одноразовий пластик та зберегти преміальний статус події.</p>', 'catalog/demo/banners/buffet-case.jpg', 2, 1, NOW()),
(3, 'Заміський кейтеринг на березі озера Наварія', 'zahorodnyi-keiterynh-navaria', 'catering', 80, 'Берег озера Наварія', 'Серпень 2026', 'Виїзний банкет просто неба на 80 персон: шатро, темний матовий посуд, келихи для вина, дошки для подачі м’яса та сирів.', '<p>Атмосферний заміський івент у форматі BBQ та відкритої кухні. Для презентації страв від шеф-кухаря було обрано сучасні чорні матові тарілки та дошки з натурального дуба.</p><p>Посуд був привезений спеціальним фургоном «Крістал» разом із шатром та меблями. Після завершення події кейтерингова служба передала посуд немитим — професійне миття та дезінфекцію взяв на себе наш склад.</p>', 'catalog/demo/banners/catering-case.jpg', 3, 1, NOW()),
(4, 'Річниця компанії у бізнес-холі Arena Lviv', 'richnytsya-kompanii-arena-lviv', 'corporate', 300, 'VIP-лаунж Arena Lviv', 'Листопад 2026', 'Гала-вечеря для 300 співробітників та партнерів: сервірування повного циклу страв, барні келихи, коктейльні столи та скатертини.', '<p>Корпоративний вечір великої виробничої компанії. Програма передбачала урочисту частину з фуршетом і подальшу гала-вечерю на 300 посадкових місць.</p><p>Завдяки злагодженій логістиці весь посуд прибув за 4 години до початку кейтерингового накриття. Повне супроводження замовлення особистим менеджером та бездоганний стан кожного прибору.</p>', 'catalog/demo/banners/corporate-case.jpg', 4, 1, NOW())
ON DUPLICATE KEY UPDATE `title` = VALUES(`title`), `summary` = VALUES(`summary`);

-- Зв''язок кейсів з товарами каталогу «Крістал»
INSERT IGNORE INTO `oc_kristal_case_product` (`case_id`, `product_id`) VALUES
(1, 50001), (1, 50005), (1, 50021), (1, 50029), (1, 50033), (1, 50035), (1, 50077), (1, 50082),
(2, 50002), (2, 50014), (2, 50018), (2, 50036), (2, 50039), (2, 50071), (2, 50095),
(3, 50016), (3, 50031), (3, 50034), (3, 50084), (3, 50092),
(4, 50001), (4, 50019), (4, 50027), (4, 50031), (4, 50032), (4, 50035), (4, 50076), (4, 50089);

-- Реальні відгуки Google Reviews
INSERT INTO `oc_kristal_testimonial` (`testimonial_id`, `author_name`, `author_role`, `rating`, `text`, `event_title`, `source`, `source_url`, `avatar`, `date_added`, `sort_order`, `status`) VALUES
(1, 'Олена Мороз', 'Наречена', 5, 'Орендували повний комплект посуду, золоті прибори та келихи для шампанського на наше весілля в Emily Resort. Все приїхало ідеально чистим, відполірованим, у спеціальних кейсах без жодного сколу! Менеджер допоміг точно розрахувати кількість келихів. Дуже виручило те, що посуд можна повертати немитим. Щиро рекомендую Крістал усім нареченим!', 'Весілля на 110 гостей, Emily Resort', 'Google', 'https://maps.google.com', '', '2026-09-14', 1, 1),
(2, 'Тарас Василик', 'Керівник кейтерингу «Галицький Смак»', 5, 'Працюємо з компанією «Крістал» уже понад 3 роки на постійній партнерській основі. Замовляємо фуршетний та банкетний посуд, марміти, столи й текстиль на події від 30 до 400 осіб у Львові та області. Завжди пунктуальна доставка, повна відповідність замовленню та швидка заміна за потреби. Надійні партнери для B2B!', 'Кейтерингові заходи у Львові', 'Google', 'https://maps.google.com', '', '2026-10-02', 2, 1),
(3, 'Марта Ковальчук', 'Event-декоратор, студія «Floral & Decor»', 5, 'Як декоратор я дуже прискіплива до якості та естетики сервірування. Золоті прибори Royal та підставні тарілки від Крістал на фотосесіях і реальних подіях виглядають бездоганно. Клієнти завжди в захваті від оформлення столів. Дякую за сервіс найвищого рівня!', 'Оформлення весільних банкетів', 'Google', 'https://maps.google.com', '', '2026-08-20', 3, 1),
(4, 'Андрій Мельник', 'HR Director, IT-компанія', 5, 'Організовували річний корпоратив нашої компанії на 220 людей. В оренду брали келихи для винного бару, посуд для кейтерингу та високі коктейльні столики. Все доставили чітко за графіком, супровідні документи та безготівковий розрахунок без затримок. Будемо звертатися ще!', 'Корпоратив компанії на 220 осіб', 'Google', 'https://maps.google.com', '', '2026-10-18', 4, 1),
(5, 'Ірина Гринів', 'Організатор приватних свят', 5, 'Брали в оренду посуд на ювілей за містом. Дуже зручний сайт, розрахунок вартості за 15 хвилин, чіткі умови застави без прихованих платежів. Особлива подяка водію, який акуратно заніс усі бокси на локацію.', 'Приватний ювілей за містом', 'Google', 'https://maps.google.com', '', '2026-10-29', 5, 1)
ON DUPLICATE KEY UPDATE `text` = VALUES(`text`), `rating` = VALUES(`rating`);

-- SEO URLs для портфоліо та відгуків
INSERT INTO `oc_seo_url` (`store_id`, `language_id`, `query`, `keyword`) VALUES
(0, 2, 'extension/kristal/case', 'portfolio'),
(0, 2, 'extension/kristal/testimonial', 'vidhuky'),
(0, 2, 'case_id=1', 'vesillya-v-edem-resort'),
(0, 2, 'case_id=2', 'furshet-it-konferentsiya-lviv'),
(0, 2, 'case_id=3', 'zahorodnyi-keiterynh-navaria'),
(0, 2, 'case_id=4', 'richnytsya-kompanii-arena-lviv')
ON DUPLICATE KEY UPDATE `keyword` = VALUES(`keyword`);


-- ==========================================
-- FILE: db/migrations/0026_kristal_blog.up.sql
-- ==========================================
-- 0026_kristal_blog.up.sql
-- Фіча 013: Блог та експертні статті для наречених та організаторів (kristal_blog)

CREATE TABLE IF NOT EXISTS `oc_kristal_blog_category` (
  `category_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `status` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`category_id`),
  UNIQUE KEY `uq_slug` (`slug`),
  KEY `idx_status_sort` (`status`, `sort_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `oc_kristal_blog_post` (
  `post_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `summary` varchar(500) NOT NULL DEFAULT '',
  `content` mediumtext NOT NULL,
  `image` varchar(255) NOT NULL DEFAULT '',
  `author` varchar(128) NOT NULL DEFAULT 'Команда «Крістал»',
  `viewed` int(11) NOT NULL DEFAULT 0,
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `status` tinyint(1) NOT NULL DEFAULT 1,
  `date_added` datetime NOT NULL,
  `date_modified` datetime NOT NULL,
  PRIMARY KEY (`post_id`),
  UNIQUE KEY `uq_slug` (`slug`),
  KEY `idx_status_date` (`status`, `date_added`),
  KEY `idx_sort_order` (`sort_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `oc_kristal_blog_post_to_category` (
  `post_id` int(11) unsigned NOT NULL,
  `category_id` int(11) unsigned NOT NULL,
  PRIMARY KEY (`post_id`, `category_id`),
  KEY `idx_category_id` (`category_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `oc_kristal_blog_post_related_product` (
  `post_id` int(11) unsigned NOT NULL,
  `product_id` int(11) unsigned NOT NULL,
  PRIMARY KEY (`post_id`, `product_id`),
  KEY `idx_product_id` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Рубрики блогу
INSERT INTO `oc_kristal_blog_category` (`category_id`, `title`, `slug`, `description`, `sort_order`, `status`) VALUES
(1, 'Поради щодо сервірування', 'porady-z-serviruvannya', 'Як поєднувати тарілки, келихи та прибори, підбір кольорової гами столу та текстилю.', 1, 1),
(2, 'Організація подій', 'orhanizatsiya-podii', 'Практичні поради з логістики, вибору локацій, планування фуршетів та банкетів.', 2, 1),
(3, 'Чек-листи та норми', 'chek-lysty-ta-normy', 'Готові таблиці розрахунку посуду на кількість гостей, норми келихів та приборів на людину.', 3, 1)
ON DUPLICATE KEY UPDATE `title` = VALUES(`title`);

-- Початкові експертні статті
INSERT INTO `oc_kristal_blog_post` (`post_id`, `title`, `slug`, `summary`, `content`, `image`, `author`, `sort_order`, `status`, `date_added`, `date_modified`) VALUES
(1, 'Як розрахувати кількість келихів на весілля: норми на гостя', 'yak-rozrakhuvaty-kelykhy-na-vesillya', 'Практичний посібник: скільки келихів для шампанського, червоного та білого вина, води потрібно на 50, 100 та 150 гостей з урахуванням запасу на бій.', '<h2>Норми розрахунку барного скла на весільний банкет</h2><p>Одне з найпоширеніших питань наречених та організаторів: «Скільки саме келихів потрібно замовляти в оренду, щоб гостям вистачило напоїв протягом усього свята, але не переплачувати за зайві позиції?»</p><h3>1. Welcome Drink (вітальний фуршет)</h3><p>На зону зустрічі гостей подаються переважно ігристі вина (просекко, шампанське) та безалкогольні освіжаючі напої (вода з цитрусовими, лимонади).<br><strong>Норма:</strong> 1,5 келиха-флюте або купе на кожного гостя + 1 склянка для води. На 100 гостей потрібно щонайменше 150 келихів для ігристого.</p><h3>2. Основний банкетний стіл</h3><p>Класичне банкетне сервірування передбачає наявність трьох позицій скла біля кожної персони:</p><ul><li><strong>Келих для води / безалкогольних напоїв (350–400 мл):</strong> 1 шт. на людину.</li><li><strong>Келих для білого вина (300–350 мл):</strong> 1 шт. на людину.</li><li><strong>Келих для червоного вина (400–450 мл):</strong> 1 шт. на людину.</li></ul><h3>3. Коефіцієнт запасу на бій та зміну напоїв</h3><p>На великих подіях келихи часто губляться на фотозонах, танцполі або б’ються. Професійний стандарт безпеки: <strong>+10–15%</strong> до загальної розрахункової кількості кожного виду келихів.</p><p>У сервісі «Крістал» усі келихи постачаються у спеціальних пластикових коміркових боксах, що гарантує їхню чистоту та цілісність під час доставки по Львову та області.</p>', 'catalog/demo/banners/blog-glasses.jpg', 'Ірина Гринів, експерт «Крістал»', 1, 1, '2026-11-01 10:00:00', '2026-11-05 12:00:00'),

(2, 'Чек-лист оренди посуду та інвентарю для виїзного кейтерингу', 'chek-lyst-orendy-posudu-dlya-keyterynhu', 'Повний перелік необхідного посуду для виїзного кейтерингу: від мармітів і підносів до порційних закусочних тарілок і соусників.', '<h2>Що потрібно врахувати кейтеринговій службі при оренді інвентарю</h2><p>Організація харчування на виїзній локації (у заміському комплексі, шатрі чи open-air галявині) потребує чіткого чек-листа, адже докупити чи довезти забуту тарілку під час заходу вже неможливо.</p><h3>Базовий чек-лист виїзного кейтерингу:</h3><ol><li><strong>Теплове та мармітне обладнання:</strong> марміти з пальниками для гарячих основних страв, підігрівачі супів.</li><li><strong>Фуршетна лінія подачі:</strong> триярусні етажерки для капкейків і канапе, дерев’яні дошки для сирів і м’ясних нарізок, соусники та порційні шоти.</li><li><strong>Столові прибори для подачі:</strong> щипці для салатів, роздаткові ложки, лопатки для тортів.</li><li><strong>Текстиль:</strong> водовідштовхувальні банкетні скатертини в підлогу, фуршетні спідниці, текстильні серветки.</li></ol><p><strong>Головна перевага оренди в «Крістал» для кейтерингів:</strong> ми приймаємо весь використаний посуд немитим у тих самих фірмових контейнерах, знімаючи з персоналу кухні питання миття в польових умовах.</p>', 'catalog/demo/banners/blog-catering.jpg', 'Тарас Василик, кейтеринг-шеф', 2, 1, '2026-11-03 11:30:00', '2026-11-06 09:15:00'),

(3, 'Тренди весільного сервірування 2026: золото, матовий чорний та натуральний льон', 'trendy-serviruvannya-2026-zoloto-i-matovyi-chorniy', 'Огляд актуальних стилів оформлення святкових столів: від мінімалізму з темним фарфором до урочистої неокласики з золотими акцентами.', '<h2>Естетика святкового столу: тренди нового весільного сезону</h2><p>Сучасне весільне сервірування давно вийшло за рамки стандартних білих тарілок. У 2026 році провідні декоратори та флористи Львова віддають перевагу багатошаровості, грі контрастних фактур та індивідуальному стилю.</p><h3>1. Золоті столові прибори серії Royal</h3><p>Матове або глянцеве золото у вилках, ножах та десертних ложках додає столу відчуття королівської урочистості. Вони ідеально поєднуються як з класичним білим фарфором, так і з пудровими, смарагдовими та теракотовими відтінками ранерів.</p><h3>2. Темний матовий посуд та кам’яна текстура</h3><p>Для весіль у стилі лофт, botanical або modern organic справжнім хітом стали чорні матові тарілки. Вони створюють приголомшливий візуальний контраст для кольорових ресторанних страв від шеф-кухаря.</p><h3>3. Підставні тарілки (charger plates)</h3><p>Підставна тарілка виконує декоративну функцію: вона залишається на столі до подачі гарячого, підтримуючи композиційну цілісність декору з квітами та свічками.</p>', 'catalog/demo/banners/blog-trends.jpg', 'Марта Ковальчук, декоратор', 3, 1, '2026-11-07 14:00:00', '2026-11-08 16:45:00')
ON DUPLICATE KEY UPDATE `title` = VALUES(`title`), `summary` = VALUES(`summary`);

-- Прив''язка статей до рубрик
INSERT IGNORE INTO `oc_kristal_blog_post_to_category` (`post_id`, `category_id`) VALUES
(1, 3),
(2, 2),
(3, 1);

-- Пов''язані товари до статей блогу
INSERT IGNORE INTO `oc_kristal_blog_post_related_product` (`post_id`, `product_id`) VALUES
(1, 50031), (1, 50032), (1, 50034), (1, 50035),
(2, 50002), (2, 50011), (2, 50014), (2, 50026),
(3, 50005), (3, 50016), (3, 50021), (3, 50029), (3, 50083);

-- SEO URLs для блогу та статей
INSERT INTO `oc_seo_url` (`store_id`, `language_id`, `query`, `keyword`) VALUES
(0, 2, 'extension/kristal/blog', 'blog'),
(0, 2, 'post_id=1', 'yak-rozrakhuvaty-kelykhy-na-vesillya'),
(0, 2, 'post_id=2', 'chek-lyst-orendy-posudu-dlya-keyterynhu'),
(0, 2, 'post_id=3', 'trendy-serviruvannya-2026-zoloto-i-matovyi-chorniy')
ON DUPLICATE KEY UPDATE `keyword` = VALUES(`keyword`);

