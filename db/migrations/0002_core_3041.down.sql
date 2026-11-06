-- ---------------------------------------------------------------------------
-- 0002_core_3041 — DOWN
-- Повертає стан до UP: sort_order без DEFAULT (як у 3.0.3.2) і подію sms_alert
-- з тими самими значеннями, що були в дампі (id — новий, щоб не зіткнутися з
-- подіями, доданими після UP). Ідемпотентно.
-- ---------------------------------------------------------------------------

ALTER TABLE `{{PREFIX}}event` MODIFY `sort_order` INT(3) NOT NULL;

INSERT INTO `{{PREFIX}}event` (`code`, `trigger`, `action`, `status`, `sort_order`)
SELECT 'sms_alert', 'catalog/model/checkout/order/addOrderHistory/after', 'extension/module/sms_alert', 1, 0
  FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM `{{PREFIX}}event` WHERE `code` = 'sms_alert');
