-- ---------------------------------------------------------------------------
-- 0016_kristal_checkout — UP
-- Специфікація: specs/010-checkout/plan.md
--
-- 1) kristal_order_rental — параметри оренди для замовлення:
--      order_id         — первинний ключ (відповідає oc_order.order_id);
--      date_from, date_to — дати початку та завершення оренди;
--      rental_days      — тривалість оренди у добах;
--      delivery_type    — 'delivery' (доставка) або 'pickup' (самовивіз);
--      delivery_address — адреса події (якщо доставка);
--      contact_channel  — бажаний канал зв'язку (viber, telegram, phone, email);
--      is_company       — прапорець юрособи / ФОП (1/0);
--      company_name     — назва організації / ФОП;
--      edrpou           — код ЄДРПОУ / ІПН;
--      created_at       — дата створення;
--      updated_at       — дата оновлення.
-- 2) Подія адмінки:
--      admin/view/sale/order_info/after -> extension/kristal/checkout/orderInfo
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `{{PREFIX}}kristal_order_rental` (
  `order_id`         INT(11) UNSIGNED NOT NULL,
  `date_from`        DATE             NOT NULL,
  `date_to`          DATE             NOT NULL,
  `rental_days`      INT(11) UNSIGNED NOT NULL DEFAULT 1,
  `delivery_type`    VARCHAR(16)      NOT NULL DEFAULT 'delivery',
  `delivery_address` VARCHAR(255)     NOT NULL DEFAULT '',
  `contact_channel`  VARCHAR(32)      NOT NULL DEFAULT 'viber',
  `is_company`       TINYINT(1)       NOT NULL DEFAULT 0,
  `company_name`     VARCHAR(255)     NOT NULL DEFAULT '',
  `edrpou`           VARCHAR(32)      NOT NULL DEFAULT '',
  `created_at`       DATETIME         NOT NULL,
  `updated_at`       DATETIME         NOT NULL,
  PRIMARY KEY (`order_id`),
  KEY `idx_dates` (`date_from`, `date_to`),
  KEY `idx_created` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

DELETE FROM `{{PREFIX}}event` WHERE `code` = 'kristal_checkout';

INSERT INTO `{{PREFIX}}event` (`code`, `trigger`, `action`, `status`, `sort_order`) VALUES
  ('kristal_checkout', 'admin/view/sale/order_info/after', 'extension/kristal/checkout/orderInfo', 1, 0);
