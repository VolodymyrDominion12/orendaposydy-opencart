-- ---------------------------------------------------------------------------
-- 0012_kristal_security — UP
-- Специфікація: specs/017-security/plan.md (AC-11)
--
-- Події: перед кожним контролером вітрини й адмінки — атрибути куки сесії
-- (HttpOnly, Secure, SameSite) через \Kristal\Cookie. Обробник спрацьовує один раз за запит.
-- Схема БД не змінюється — лише рядки в {{PREFIX}}event. Ідемпотентно.
-- sort_order 0 — раніше за інші обробники: якщо якийсь із них віддасть вивід, кука вже правильна.
-- ---------------------------------------------------------------------------

DELETE FROM `{{PREFIX}}event` WHERE `code` = 'kristal_security_cookie';

INSERT INTO `{{PREFIX}}event` (`code`, `trigger`, `action`, `status`, `sort_order`) VALUES
  ('kristal_security_cookie', 'catalog/controller/*/before', 'extension/kristal/security/cookie', 1, 0),
  ('kristal_security_cookie', 'admin/controller/*/before',   'extension/kristal/security/cookie', 1, 0);
