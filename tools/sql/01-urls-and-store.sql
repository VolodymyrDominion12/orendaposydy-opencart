-- ---------------------------------------------------------------------------
-- 01. Базові налаштування магазину для локального середовища
--
-- ВАЖЛИВО про URL (це найпоширеніша помилка в інструкціях):
--   У OpenCart 2.x адреса магазину лежала в БД: oc_setting.config_url.
--   У OpenCart 3 це НЕ ТАК. Адреса береться з констант HTTP_SERVER /
--   HTTPS_SERVER у config.php (див. catalog/controller/startup/startup.php,
--   рядки 32-33: $this->config->set('config_url', HTTP_SERVER)).
--   Тому міняти URL треба у config.php, а не тут — це робить `make config`.
--   Якщо ви скопіювали інструкцію для OC2 і виконали UPDATE oc_setting
--   SET value=... WHERE key='config_url', ви не зміните нічого.
--
-- Плейсхолдер {{PREFIX}} замінюється на реальний префікс таблиць
-- скриптом tools/localize-db.sh.
-- ---------------------------------------------------------------------------

-- 1.1. Вимкнути примусовий HTTPS.
-- На проді config_secure=1 змушує OpenCart робити 301 на https://orendaposydy.com.
-- Локально це означало б нескінченний редирект на прод або цикл:
--   localhost:8080 → https://localhost:8080 (якого немає) → помилка.
UPDATE `{{PREFIX}}setting` SET `value` = '0' WHERE `key` = 'config_secure';

-- 1.2. Вимкнути режим обслуговування.
-- Якщо на проді він був увімкнений (або ви його вмикали), локально сайт
-- показував би лише заглушку, і ви б шукали причину у верстці.
UPDATE `{{PREFIX}}setting` SET `value` = '0' WHERE `key` = 'config_maintenance';

-- 1.3. Прибрати ідентифікатор Google Analytics.
-- Навіть якщо сам модуль вимкнено, краще не мати бойового ID у локальній базі:
-- один випадковий клік у адмінці — і локальні візити поїхали б у реальну
-- статистику клієнта.
UPDATE `{{PREFIX}}setting` SET `value` = '' WHERE `key` = 'config_google_analytics';

-- 1.4. Скинути сесії.
-- У дампі з прода лежать активні сесії адміністраторів і покупців. Вони
-- марні локально й інколи дають дивну поведінку кошика.
--
-- ВАЖЛИВО: таблиці {{PREFIX}}session на проді може НЕ БУТИ, і це нормально.
-- system/framework.php створює сесію як new Session(), а конструктор
-- (system/library/session.php, рядок 6) типово бере адаптер 'native' —
-- тобто звичайні файлові сесії PHP. Варіант із таблицею
-- (system/library/session/db.php) лише згадує CREATE TABLE у комментарі,
-- тому таблиця з'являється тільки там, де її створили руками.
-- Безумовний TRUNCATE на такій базі валить локалізацію помилкою
-- «ERROR 1146: Table 'opencart.oc_session' doesn't exist».
--
-- Тому спершу питаємо information_schema, а TRUNCATE виконуємо лише тоді,
-- коли таблиця справді існує. Інакше — порожня команда DO 0.

SET @tbl := '{{PREFIX}}session';
SET @stmt := IF(
    (SELECT COUNT(*) FROM information_schema.tables
      WHERE table_schema = DATABASE() AND table_name = @tbl) > 0,
    CONCAT('TRUNCATE TABLE `', @tbl, '`'),
    'DO 0');
PREPARE s FROM @stmt;
EXECUTE s;
DEALLOCATE PREPARE s;

-- Те саме для {{PREFIX}}customer_online: у більшості збірок OpenCart 3 вона є,
-- але якщо її колись видалили — локалізація не має через це падати.
SET @tbl := '{{PREFIX}}customer_online';
SET @stmt := IF(
    (SELECT COUNT(*) FROM information_schema.tables
      WHERE table_schema = DATABASE() AND table_name = @tbl) > 0,
    CONCAT('TRUNCATE TABLE `', @tbl, '`'),
    'DO 0');
PREPARE s FROM @stmt;
EXECUTE s;
DEALLOCATE PREPARE s;
