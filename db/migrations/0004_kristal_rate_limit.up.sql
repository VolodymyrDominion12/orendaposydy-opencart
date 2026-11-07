-- ---------------------------------------------------------------------------
-- 0004_kristal_rate_limit — UP
-- Специфікація: specs/019-kristal-core/plan.md → «Міграції БД», «Запити та індекси»
--
-- Лічильник спроб для Kristal\Rate_limit (антиспам форм, AC-7).
-- IP у чистому вигляді не зберігається: key_hash = sha1(salt|action|ip).
--   PRIMARY KEY (key_hash) — гарячі INSERT … ON DUPLICATE KEY UPDATE і SELECT за ключем;
--   idx_window_start      — рідкісне очищення DELETE … WHERE window_start < NOW() - INTERVAL 1 DAY.
-- Без FOREIGN KEY. Ідемпотентно.
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `{{PREFIX}}kristal_rate_limit` (
  `key_hash`     CHAR(40)    CHARACTER SET ascii NOT NULL,
  `action`       VARCHAR(32) NOT NULL,
  `hits`         INT(11)     NOT NULL DEFAULT 0,
  `window_start` DATETIME    NOT NULL,
  PRIMARY KEY (`key_hash`),
  KEY `idx_window_start` (`window_start`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
