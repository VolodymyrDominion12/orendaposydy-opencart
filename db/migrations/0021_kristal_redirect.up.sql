-- ---------------------------------------------------------------------------
-- 0021_kristal_redirect — UP
-- Специфікація: specs/002-redirect/plan.md
--
-- 1) kristal_redirect — таблиця 301/302-редиректів зі старих URL.
-- 2) kristal_404_log — журнал неіснуючих сторінок для пошуку битих посилань.
-- 3) Подія kristal_redirect_check на catalog/controller/error/not_found/before.
-- 4) Початкові 301-редиректи зі старої структури (розділ «URL і 301-редиректи»).
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `{{PREFIX}}kristal_redirect` (
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

CREATE TABLE IF NOT EXISTS `{{PREFIX}}kristal_404_log` (
  `path`        VARCHAR(255) NOT NULL,
  `hits`        INT(11)      NOT NULL DEFAULT 1,
  `referer`     VARCHAR(255) NOT NULL DEFAULT '',
  `last_at`     DATETIME     NOT NULL,
  PRIMARY KEY (`path`),
  KEY `idx_hits` (`hits`),
  KEY `idx_last_at` (`last_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

DELETE FROM `{{PREFIX}}event` WHERE `code` = 'kristal_redirect_check';

INSERT INTO `{{PREFIX}}event` (`code`, `trigger`, `action`, `status`, `sort_order`) VALUES
  ('kristal_redirect_check', 'catalog/controller/error/not_found/before', 'extension/kristal/redirect/check', 1, 0);

-- Базові 301-редиректи зі старої структури сайту
INSERT IGNORE INTO `{{PREFIX}}kristal_redirect` (`old_path`, `new_path`, `code`, `status`) VALUES
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
