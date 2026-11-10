-- ---------------------------------------------------------------------------
-- 0015_kristal_notify — UP
-- Специфікація: specs/023-notify/plan.md
--
-- 1) kristal_notify_log — журнал відправок сповіщень (Telegram, Email, Webhook)
--      idx_status_attempts — вибірка помилок і повторних спроб;
--      idx_created         — сортування в адмінці за часом;
--      idx_entity          — перевірка, чи відправлено сповіщення про замовлення/лід (запобігання дублям).
-- 2) Подія ядра OpenCart:
--      catalog/model/checkout/order/addOrderHistory/after -> extension/kristal/notify/onOrderHistory
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `{{PREFIX}}kristal_notify_log` (
  `log_id`      INT(11) UNSIGNED    NOT NULL AUTO_INCREMENT,
  `channel`     VARCHAR(16)         NOT NULL COMMENT 'telegram, email, webhook',
  `event_type`  VARCHAR(32)         NOT NULL COMMENT 'order, lead, test',
  `entity_id`   INT(11) UNSIGNED    NOT NULL DEFAULT 0,
  `recipient`   VARCHAR(191)        NOT NULL DEFAULT '',
  `status`      VARCHAR(16)         NOT NULL DEFAULT 'sent' COMMENT 'sent, failed',
  `attempts`    TINYINT(3) UNSIGNED NOT NULL DEFAULT 1,
  `error`       VARCHAR(255)        NULL,
  `summary`     VARCHAR(255)        NULL,
  `created_at`  DATETIME            NOT NULL,
  `updated_at`  DATETIME            NOT NULL,
  PRIMARY KEY (`log_id`),
  KEY `idx_status_attempts` (`status`, `attempts`),
  KEY `idx_created` (`created_at`),
  KEY `idx_entity` (`entity_id`, `event_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

DELETE FROM `{{PREFIX}}event` WHERE `code` = 'kristal_notify';

INSERT INTO `{{PREFIX}}event` (`code`, `trigger`, `action`, `status`, `sort_order`) VALUES
  ('kristal_notify', 'catalog/model/checkout/order/addOrderHistory/after', 'extension/kristal/notify/onOrderHistory', 1, 0),
  ('kristal_notify', 'catalog/model/checkout/order/addOrder/after',        'extension/kristal/notify/onOrder',        1, 0),
  ('kristal_notify', 'catalog/model/checkout/simple_order/addOrder/after', 'extension/kristal/notify/onOrder',        1, 0);
