-- ---------------------------------------------------------------------------
-- 02. Перевести всю пошту на локальний перехоплювач (Mailpit)
--
-- БЕЗ ЦЬОГО КРОКУ ЛОКАЛЬНЕ ТЕСТУВАННЯ ЗАМОВЛЕННЯ НАДІШЛЕ СПРАВЖНІЙ ЛИСТ.
--
-- Після імпорту бойової бази oc_setting.config_mail_* містить реальні
-- налаштування SMTP хостингу. Якщо ви оформите тестове замовлення або
-- натиснете «забули пароль» — лист піде реальному клієнту, або на пошту
-- магазину, і цього вже не відмінити.
--
-- Перевірено на OpenCart 3.0.3.9:
--   * набір ключів саме такий (system/library/mail.php вибирає адаптер за
--     config_mail_engine, значення 'mail' або 'smtp');
--   * у цій версії OpenCart SMTP-адаптер власний і БЕЗ TLS/STARTTLS
--     (system/library/mail/smtp.php) — тому простий SMTP Mailpit на порту
--     1025 підходить без жодних сертифікатів.
--
-- Куди дивитись листи:  http://localhost:8025
-- ---------------------------------------------------------------------------

UPDATE `{{PREFIX}}setting` SET `value` = 'smtp'    WHERE `key` = 'config_mail_engine';
UPDATE `{{PREFIX}}setting` SET `value` = 'mailpit' WHERE `key` = 'config_mail_smtp_hostname';
UPDATE `{{PREFIX}}setting` SET `value` = '1025'    WHERE `key` = 'config_mail_smtp_port';
UPDATE `{{PREFIX}}setting` SET `value` = '10'      WHERE `key` = 'config_mail_smtp_timeout';

-- Логін і пароль від бойового SMTP прибираємо: Mailpit їх не потребує,
-- а тримати чужі паролі в локальній базі немає сенсу.
UPDATE `{{PREFIX}}setting` SET `value` = '' WHERE `key` = 'config_mail_smtp_username';
UPDATE `{{PREFIX}}setting` SET `value` = '' WHERE `key` = 'config_mail_smtp_password';
UPDATE `{{PREFIX}}setting` SET `value` = '' WHERE `key` = 'config_mail_parameter';

-- Адреса, на яку OpenCart шле листи-сповіщення про нові замовлення.
-- Лишаємо, але тепер вона безпечна: усе осідає в Mailpit.
-- Якщо хочете взагалі без сповіщень — розкоментуйте:
-- UPDATE `{{PREFIX}}setting` SET `value` = '0' WHERE `key` = 'config_mail_alert';
