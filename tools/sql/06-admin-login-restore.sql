-- ---------------------------------------------------------------------------
-- Відновлення доступу до адмінки (2026-11-09).
--
-- Коли потрібно:
--   * «Неправильна токен-сесія. Авторизуйтесь знову» — у сесії лишився
--     user_token від старого адміна (сесії живуть у спільній БД, тому старий
--     OCSESSID «протікає» в нову адмінку). Замість SQL можна просто стерти
--     кукі для домену — цей файл на випадок, якщо не допомогло;
--   * забули пароль користувача kristal_admin;
--   * після 5 невдалих спроб вхід блокується на годину (український переклад
--     цього повідомлення в мовному файлі відсутній — побачите сирий ключ
--     «error_attempts»);
--   * треба впевнитись, що користувач активний і має групу адміністраторів.
--
-- ЩО ЗРОБИТИ ПЕРЕД ЗАПУСКОМ: замініть пароль у рядку SET @plain нижче.
-- Після входу змініть його в адмінці: Система → Користувачі → kristal_admin.
--
-- Ідемпотентно: можна запускати повторно, нічого не дублюється.
-- ---------------------------------------------------------------------------

SET @username = 'kristal_admin';
SET @plain    = 'ЗАМІНІТЬ-ЦЕЙ-ПАРОЛЬ';
SET @salt     = SUBSTRING(MD5(RAND()), 1, 9);

-- 1. Зняти блокування після невдалих спроб входу
DELETE FROM `{{PREFIX}}customer_login` WHERE `email` = LOWER(@username);

-- 2. Оновити пароль наявного користувача
UPDATE `{{PREFIX}}user`
   SET `password`      = SHA1(CONCAT(@salt, SHA1(CONCAT(@salt, SHA1(@plain))))),
       `salt`          = @salt,
       `code`          = '',
       `status`        = 1,
       `user_group_id` = 1
 WHERE `username` = @username;

-- 3. Якщо такого користувача немає — створити (група 1 = адміністратор)
INSERT INTO `{{PREFIX}}user` (`user_group_id`, `username`, `password`, `salt`, `firstname`, `lastname`,
                              `email`, `image`, `code`, `ip`, `status`, `date_added`)
SELECT 1, @username,
       SHA1(CONCAT(@salt, SHA1(CONCAT(@salt, SHA1(@plain))))),
       @salt, 'Крістал', 'Адмін', '', '', '', '', 1, NOW()
 WHERE NOT EXISTS (SELECT 1 FROM (SELECT `user_id` FROM `{{PREFIX}}user` WHERE `username` = @username) t);

-- 4. Контроль: має бути рівно один рядок, status=1, hash_ok=1
SELECT `user_id`, `username`, `status`, `user_group_id`,
       (`password` = SHA1(CONCAT(`salt`, SHA1(CONCAT(`salt`, SHA1(@plain)))))) AS hash_ok
  FROM `{{PREFIX}}user`
 WHERE `username` = @username;

-- 5. Контроль: черга блокувань порожня
SELECT COUNT(*) AS login_attempts_left FROM `{{PREFIX}}customer_login` WHERE `email` = LOWER(@username);
