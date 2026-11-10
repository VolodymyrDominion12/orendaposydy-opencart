-- ---------------------------------------------------------------------------
-- 0017_kristal_lead — UP
-- Специфікація: specs/009-lead/plan.md
--
-- 1) kristal_lead — таблиця заявок (лідів):
--      lead_id         — первинний ключ;
--      type            — тип ліда ('calc_15m', 'quick_order', 'callback', 'b2b');
--      status          — статус ('new', 'in_progress', 'completed', 'canceled');
--      name            — ім'я клієнта;
--      phone           — телефон у форматі E.164;
--      email           — email (якщо вказано);
--      event_date      — дата події (якщо вказано);
--      guests          — кількість гостей (числове);
--      product_id      — ID товару (для швидкого замовлення в 1 клік);
--      quantity        — кількість одиниць товару;
--      contact_channel — бажаний канал зв'язку (viber, telegram, phone);
--      comment         — коментар клієнта;
--      manager_note    — внутрішня примітка менеджера;
--      source_url      — сторінка, з якої надійшла заявка;
--      utm_*           — маркетингові мітки;
--      ip, user_agent  — технічні дані;
--      created_at, updated_at.
-- 2) kristal_lead_file — прикріплені файли меню/кошторису:
--      file_id         — первинний ключ;
--      lead_id         — зовнішній ID заявки;
--      filename_orig   — оригінальне ім'я файлу (для завантаження);
--      filename_stored — безпечне ім'я файлу на диску у storage/upload/;
--      filesize        — розмір у байтах;
--      mime_type       — MIME-тип.
-- 3) Подія меню адмінки:
--      admin/view/common/column_left/before -> extension/kristal/lead/menu
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `{{PREFIX}}kristal_lead` (
  `lead_id`         INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `type`            VARCHAR(32)      NOT NULL DEFAULT 'calc_15m',
  `status`          VARCHAR(32)      NOT NULL DEFAULT 'new',
  `name`            VARCHAR(255)     NOT NULL DEFAULT '',
  `phone`           VARCHAR(32)      NOT NULL DEFAULT '',
  `email`           VARCHAR(255)     NOT NULL DEFAULT '',
  `event_date`      DATE             NULL,
  `guests`          INT(11) UNSIGNED NULL,
  `product_id`      INT(11) UNSIGNED NULL,
  `quantity`        INT(11) UNSIGNED NULL,
  `contact_channel` VARCHAR(32)      NOT NULL DEFAULT 'viber',
  `comment`         TEXT             NULL,
  `manager_note`    TEXT             NULL,
  `source_url`      VARCHAR(512)     NOT NULL DEFAULT '',
  `utm_source`      VARCHAR(255)     NULL,
  `utm_medium`      VARCHAR(255)     NULL,
  `utm_campaign`    VARCHAR(255)     NULL,
  `utm_content`     VARCHAR(255)     NULL,
  `utm_term`        VARCHAR(255)     NULL,
  `ip`              VARCHAR(45)      NOT NULL DEFAULT '',
  `user_agent`      VARCHAR(255)     NOT NULL DEFAULT '',
  `created_at`      DATETIME         NOT NULL,
  `updated_at`      DATETIME         NOT NULL,
  PRIMARY KEY (`lead_id`),
  KEY `idx_status_created` (`status`, `created_at`),
  KEY `idx_type_created` (`type`, `created_at`),
  KEY `idx_created` (`created_at`),
  KEY `idx_product_id` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `{{PREFIX}}kristal_lead_file` (
  `file_id`         INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `lead_id`         INT(11) UNSIGNED NOT NULL,
  `filename_orig`   VARCHAR(255)     NOT NULL DEFAULT '',
  `filename_stored` VARCHAR(255)     NOT NULL DEFAULT '',
  `filesize`        INT(11) UNSIGNED NOT NULL DEFAULT 0,
  `mime_type`       VARCHAR(128)     NOT NULL DEFAULT '',
  `created_at`      DATETIME         NOT NULL,
  PRIMARY KEY (`file_id`),
  KEY `idx_lead_id` (`lead_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

DELETE FROM `{{PREFIX}}event` WHERE `code` = 'kristal_lead_menu';

INSERT INTO `{{PREFIX}}event` (`code`, `trigger`, `action`, `status`, `sort_order`) VALUES
  ('kristal_lead_menu', 'admin/view/common/column_left/before', 'extension/kristal/lead/menu', 1, 0);
