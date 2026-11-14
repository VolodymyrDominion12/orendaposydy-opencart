-- ===========================================================================
-- Контент-пак для показу клієнту: категорії, SEO, ціни, оренда, головна.
-- Дата: 2026-11-11. Підготовлено агентом для orendaposudu.com.
--
-- ЩО РОБИТЬ:
--   1. Структура каталогу як у макетах design/ — 11 верхніх категорій
--      (Посуд, Столові прибори, Скло та келихи, Кухонне обладнання,
--      Кавове обладнання, Барне обладнання, Меблі, Текстиль, Шатри та
--      накриття, Декор, Екопосуд) + підкатегорії.
--   2. SEO title / meta description / текст для кожної категорії.
--   3. Товари розкладено по категоріях, ціни-заглушки за добу,
--      мінімальна кількість, застава, відшкодування, знижки за обсяг, «Хіт».
--   4. Фільтри «Матеріал» і «Колір» для карток категорій.
--   5. ЧПУ для 7 товарів без адреси.
--   6. Тексти головної (hero, цифри, FAQ, SEO-текст, title/description)
--      і контакти (телефон, Viber, адреса, графік, email) у шапці/футері.
--
-- ВАЖЛИВО:
--   * Ціни, «з 2013», «5000+», «600+» і тексти — ТИМЧАСОВІ.
--     Клієнт має замінити їх реальними (див. docs/demo-content-2026-11-11.md).
--   * Скрипт ідемпотентний: повторний запуск дає той самий стан.
--   * Таблиці каталогу — MyISAM (без транзакцій): ПЕРЕД ЗАПУСКОМ зробіть
--     повний експорт бази в phpMyAdmin (Експорт → Go).
--   * Після запуску: Адмінка → шестерня «Оновити» (скидання кешу),
--     або зачекайте ~1 годину (кеш kristal.* живе 1 год).
--   * Відкат: імпорт зробленого експорту бази.
-- ===========================================================================
SET NAMES utf8mb4;

-- Ідемпотентно: повторний запуск дає той самий стан.
-- ПЕРЕД ЗАПУСКОМ: бекап бази (make backup-pull / phpMyAdmin export).

UPDATE `{{PREFIX}}category` SET `status` = '0' WHERE `category_id` = 87;

INSERT INTO `{{PREFIX}}category` (`category_id`,`image`,`parent_id`,`top`,`column`,`sort_order`,`status`,`date_added`,`date_modified`) VALUES (86,'',0,1,1,1,1,NOW(),NOW()) ON DUPLICATE KEY UPDATE `image`=VALUES(`image`),`parent_id`=VALUES(`parent_id`),`top`=VALUES(`top`),`column`=VALUES(`column`),`sort_order`=VALUES(`sort_order`),`status`=VALUES(`status`),`date_modified`=NOW();
INSERT INTO `{{PREFIX}}category` (`category_id`,`image`,`parent_id`,`top`,`column`,`sort_order`,`status`,`date_added`,`date_modified`) VALUES (88,'',0,1,1,2,1,NOW(),NOW()) ON DUPLICATE KEY UPDATE `image`=VALUES(`image`),`parent_id`=VALUES(`parent_id`),`top`=VALUES(`top`),`column`=VALUES(`column`),`sort_order`=VALUES(`sort_order`),`status`=VALUES(`status`),`date_modified`=NOW();
INSERT INTO `{{PREFIX}}category` (`category_id`,`image`,`parent_id`,`top`,`column`,`sort_order`,`status`,`date_added`,`date_modified`) VALUES (126,'',0,1,1,3,1,NOW(),NOW()) ON DUPLICATE KEY UPDATE `image`=VALUES(`image`),`parent_id`=VALUES(`parent_id`),`top`=VALUES(`top`),`column`=VALUES(`column`),`sort_order`=VALUES(`sort_order`),`status`=VALUES(`status`),`date_modified`=NOW();
INSERT INTO `{{PREFIX}}category` (`category_id`,`image`,`parent_id`,`top`,`column`,`sort_order`,`status`,`date_added`,`date_modified`) VALUES (137,'',0,1,1,4,1,NOW(),NOW()) ON DUPLICATE KEY UPDATE `image`=VALUES(`image`),`parent_id`=VALUES(`parent_id`),`top`=VALUES(`top`),`column`=VALUES(`column`),`sort_order`=VALUES(`sort_order`),`status`=VALUES(`status`),`date_modified`=NOW();
INSERT INTO `{{PREFIX}}category` (`category_id`,`image`,`parent_id`,`top`,`column`,`sort_order`,`status`,`date_added`,`date_modified`) VALUES (135,'',0,1,1,5,1,NOW(),NOW()) ON DUPLICATE KEY UPDATE `image`=VALUES(`image`),`parent_id`=VALUES(`parent_id`),`top`=VALUES(`top`),`column`=VALUES(`column`),`sort_order`=VALUES(`sort_order`),`status`=VALUES(`status`),`date_modified`=NOW();
INSERT INTO `{{PREFIX}}category` (`category_id`,`image`,`parent_id`,`top`,`column`,`sort_order`,`status`,`date_added`,`date_modified`) VALUES (138,'',0,1,1,6,1,NOW(),NOW()) ON DUPLICATE KEY UPDATE `image`=VALUES(`image`),`parent_id`=VALUES(`parent_id`),`top`=VALUES(`top`),`column`=VALUES(`column`),`sort_order`=VALUES(`sort_order`),`status`=VALUES(`status`),`date_modified`=NOW();
INSERT INTO `{{PREFIX}}category` (`category_id`,`image`,`parent_id`,`top`,`column`,`sort_order`,`status`,`date_added`,`date_modified`) VALUES (140,'',0,1,1,7,1,NOW(),NOW()) ON DUPLICATE KEY UPDATE `image`=VALUES(`image`),`parent_id`=VALUES(`parent_id`),`top`=VALUES(`top`),`column`=VALUES(`column`),`sort_order`=VALUES(`sort_order`),`status`=VALUES(`status`),`date_modified`=NOW();
INSERT INTO `{{PREFIX}}category` (`category_id`,`image`,`parent_id`,`top`,`column`,`sort_order`,`status`,`date_added`,`date_modified`) VALUES (5112,'',0,1,1,8,1,NOW(),NOW()) ON DUPLICATE KEY UPDATE `image`=VALUES(`image`),`parent_id`=VALUES(`parent_id`),`top`=VALUES(`top`),`column`=VALUES(`column`),`sort_order`=VALUES(`sort_order`),`status`=VALUES(`status`),`date_modified`=NOW();
INSERT INTO `{{PREFIX}}category` (`category_id`,`image`,`parent_id`,`top`,`column`,`sort_order`,`status`,`date_added`,`date_modified`) VALUES (141,'',0,1,1,9,1,NOW(),NOW()) ON DUPLICATE KEY UPDATE `image`=VALUES(`image`),`parent_id`=VALUES(`parent_id`),`top`=VALUES(`top`),`column`=VALUES(`column`),`sort_order`=VALUES(`sort_order`),`status`=VALUES(`status`),`date_modified`=NOW();
INSERT INTO `{{PREFIX}}category` (`category_id`,`image`,`parent_id`,`top`,`column`,`sort_order`,`status`,`date_added`,`date_modified`) VALUES (142,'',0,1,1,10,1,NOW(),NOW()) ON DUPLICATE KEY UPDATE `image`=VALUES(`image`),`parent_id`=VALUES(`parent_id`),`top`=VALUES(`top`),`column`=VALUES(`column`),`sort_order`=VALUES(`sort_order`),`status`=VALUES(`status`),`date_modified`=NOW();
INSERT INTO `{{PREFIX}}category` (`category_id`,`image`,`parent_id`,`top`,`column`,`sort_order`,`status`,`date_added`,`date_modified`) VALUES (136,'',0,1,1,11,1,NOW(),NOW()) ON DUPLICATE KEY UPDATE `image`=VALUES(`image`),`parent_id`=VALUES(`parent_id`),`top`=VALUES(`top`),`column`=VALUES(`column`),`sort_order`=VALUES(`sort_order`),`status`=VALUES(`status`),`date_modified`=NOW();
INSERT INTO `{{PREFIX}}category` (`category_id`,`image`,`parent_id`,`top`,`column`,`sort_order`,`status`,`date_added`,`date_modified`) VALUES (145,'',86,0,1,1,1,NOW(),NOW()) ON DUPLICATE KEY UPDATE `image`=VALUES(`image`),`parent_id`=VALUES(`parent_id`),`top`=VALUES(`top`),`column`=VALUES(`column`),`sort_order`=VALUES(`sort_order`),`status`=VALUES(`status`),`date_modified`=NOW();
INSERT INTO `{{PREFIX}}category` (`category_id`,`image`,`parent_id`,`top`,`column`,`sort_order`,`status`,`date_added`,`date_modified`) VALUES (147,'',86,0,1,2,1,NOW(),NOW()) ON DUPLICATE KEY UPDATE `image`=VALUES(`image`),`parent_id`=VALUES(`parent_id`),`top`=VALUES(`top`),`column`=VALUES(`column`),`sort_order`=VALUES(`sort_order`),`status`=VALUES(`status`),`date_modified`=NOW();
INSERT INTO `{{PREFIX}}category` (`category_id`,`image`,`parent_id`,`top`,`column`,`sort_order`,`status`,`date_added`,`date_modified`) VALUES (146,'',86,0,1,3,1,NOW(),NOW()) ON DUPLICATE KEY UPDATE `image`=VALUES(`image`),`parent_id`=VALUES(`parent_id`),`top`=VALUES(`top`),`column`=VALUES(`column`),`sort_order`=VALUES(`sort_order`),`status`=VALUES(`status`),`date_modified`=NOW();
INSERT INTO `{{PREFIX}}category` (`category_id`,`image`,`parent_id`,`top`,`column`,`sort_order`,`status`,`date_added`,`date_modified`) VALUES (5101,'',86,0,1,4,1,NOW(),NOW()) ON DUPLICATE KEY UPDATE `image`=VALUES(`image`),`parent_id`=VALUES(`parent_id`),`top`=VALUES(`top`),`column`=VALUES(`column`),`sort_order`=VALUES(`sort_order`),`status`=VALUES(`status`),`date_modified`=NOW();
INSERT INTO `{{PREFIX}}category` (`category_id`,`image`,`parent_id`,`top`,`column`,`sort_order`,`status`,`date_added`,`date_modified`) VALUES (143,'',86,0,1,5,1,NOW(),NOW()) ON DUPLICATE KEY UPDATE `image`=VALUES(`image`),`parent_id`=VALUES(`parent_id`),`top`=VALUES(`top`),`column`=VALUES(`column`),`sort_order`=VALUES(`sort_order`),`status`=VALUES(`status`),`date_modified`=NOW();
INSERT INTO `{{PREFIX}}category` (`category_id`,`image`,`parent_id`,`top`,`column`,`sort_order`,`status`,`date_added`,`date_modified`) VALUES (149,'',88,0,1,1,1,NOW(),NOW()) ON DUPLICATE KEY UPDATE `image`=VALUES(`image`),`parent_id`=VALUES(`parent_id`),`top`=VALUES(`top`),`column`=VALUES(`column`),`sort_order`=VALUES(`sort_order`),`status`=VALUES(`status`),`date_modified`=NOW();
INSERT INTO `{{PREFIX}}category` (`category_id`,`image`,`parent_id`,`top`,`column`,`sort_order`,`status`,`date_added`,`date_modified`) VALUES (150,'',88,0,1,2,1,NOW(),NOW()) ON DUPLICATE KEY UPDATE `image`=VALUES(`image`),`parent_id`=VALUES(`parent_id`),`top`=VALUES(`top`),`column`=VALUES(`column`),`sort_order`=VALUES(`sort_order`),`status`=VALUES(`status`),`date_modified`=NOW();
INSERT INTO `{{PREFIX}}category` (`category_id`,`image`,`parent_id`,`top`,`column`,`sort_order`,`status`,`date_added`,`date_modified`) VALUES (148,'',88,0,1,3,1,NOW(),NOW()) ON DUPLICATE KEY UPDATE `image`=VALUES(`image`),`parent_id`=VALUES(`parent_id`),`top`=VALUES(`top`),`column`=VALUES(`column`),`sort_order`=VALUES(`sort_order`),`status`=VALUES(`status`),`date_modified`=NOW();
INSERT INTO `{{PREFIX}}category` (`category_id`,`image`,`parent_id`,`top`,`column`,`sort_order`,`status`,`date_added`,`date_modified`) VALUES (151,'',126,0,1,1,1,NOW(),NOW()) ON DUPLICATE KEY UPDATE `image`=VALUES(`image`),`parent_id`=VALUES(`parent_id`),`top`=VALUES(`top`),`column`=VALUES(`column`),`sort_order`=VALUES(`sort_order`),`status`=VALUES(`status`),`date_modified`=NOW();
INSERT INTO `{{PREFIX}}category` (`category_id`,`image`,`parent_id`,`top`,`column`,`sort_order`,`status`,`date_added`,`date_modified`) VALUES (5102,'',126,0,1,2,1,NOW(),NOW()) ON DUPLICATE KEY UPDATE `image`=VALUES(`image`),`parent_id`=VALUES(`parent_id`),`top`=VALUES(`top`),`column`=VALUES(`column`),`sort_order`=VALUES(`sort_order`),`status`=VALUES(`status`),`date_modified`=NOW();
INSERT INTO `{{PREFIX}}category` (`category_id`,`image`,`parent_id`,`top`,`column`,`sort_order`,`status`,`date_added`,`date_modified`) VALUES (5103,'',126,0,1,3,1,NOW(),NOW()) ON DUPLICATE KEY UPDATE `image`=VALUES(`image`),`parent_id`=VALUES(`parent_id`),`top`=VALUES(`top`),`column`=VALUES(`column`),`sort_order`=VALUES(`sort_order`),`status`=VALUES(`status`),`date_modified`=NOW();
INSERT INTO `{{PREFIX}}category` (`category_id`,`image`,`parent_id`,`top`,`column`,`sort_order`,`status`,`date_added`,`date_modified`) VALUES (5104,'',137,0,1,1,1,NOW(),NOW()) ON DUPLICATE KEY UPDATE `image`=VALUES(`image`),`parent_id`=VALUES(`parent_id`),`top`=VALUES(`top`),`column`=VALUES(`column`),`sort_order`=VALUES(`sort_order`),`status`=VALUES(`status`),`date_modified`=NOW();
INSERT INTO `{{PREFIX}}category` (`category_id`,`image`,`parent_id`,`top`,`column`,`sort_order`,`status`,`date_added`,`date_modified`) VALUES (5105,'',137,0,1,2,1,NOW(),NOW()) ON DUPLICATE KEY UPDATE `image`=VALUES(`image`),`parent_id`=VALUES(`parent_id`),`top`=VALUES(`top`),`column`=VALUES(`column`),`sort_order`=VALUES(`sort_order`),`status`=VALUES(`status`),`date_modified`=NOW();
INSERT INTO `{{PREFIX}}category` (`category_id`,`image`,`parent_id`,`top`,`column`,`sort_order`,`status`,`date_added`,`date_modified`) VALUES (139,'',138,0,1,1,1,NOW(),NOW()) ON DUPLICATE KEY UPDATE `image`=VALUES(`image`),`parent_id`=VALUES(`parent_id`),`top`=VALUES(`top`),`column`=VALUES(`column`),`sort_order`=VALUES(`sort_order`),`status`=VALUES(`status`),`date_modified`=NOW();
INSERT INTO `{{PREFIX}}category` (`category_id`,`image`,`parent_id`,`top`,`column`,`sort_order`,`status`,`date_added`,`date_modified`) VALUES (5106,'',138,0,1,2,1,NOW(),NOW()) ON DUPLICATE KEY UPDATE `image`=VALUES(`image`),`parent_id`=VALUES(`parent_id`),`top`=VALUES(`top`),`column`=VALUES(`column`),`sort_order`=VALUES(`sort_order`),`status`=VALUES(`status`),`date_modified`=NOW();
INSERT INTO `{{PREFIX}}category` (`category_id`,`image`,`parent_id`,`top`,`column`,`sort_order`,`status`,`date_added`,`date_modified`) VALUES (5107,'',140,0,1,1,1,NOW(),NOW()) ON DUPLICATE KEY UPDATE `image`=VALUES(`image`),`parent_id`=VALUES(`parent_id`),`top`=VALUES(`top`),`column`=VALUES(`column`),`sort_order`=VALUES(`sort_order`),`status`=VALUES(`status`),`date_modified`=NOW();
INSERT INTO `{{PREFIX}}category` (`category_id`,`image`,`parent_id`,`top`,`column`,`sort_order`,`status`,`date_added`,`date_modified`) VALUES (5108,'',140,0,1,2,1,NOW(),NOW()) ON DUPLICATE KEY UPDATE `image`=VALUES(`image`),`parent_id`=VALUES(`parent_id`),`top`=VALUES(`top`),`column`=VALUES(`column`),`sort_order`=VALUES(`sort_order`),`status`=VALUES(`status`),`date_modified`=NOW();
INSERT INTO `{{PREFIX}}category` (`category_id`,`image`,`parent_id`,`top`,`column`,`sort_order`,`status`,`date_added`,`date_modified`) VALUES (5109,'',140,0,1,3,1,NOW(),NOW()) ON DUPLICATE KEY UPDATE `image`=VALUES(`image`),`parent_id`=VALUES(`parent_id`),`top`=VALUES(`top`),`column`=VALUES(`column`),`sort_order`=VALUES(`sort_order`),`status`=VALUES(`status`),`date_modified`=NOW();
INSERT INTO `{{PREFIX}}category` (`category_id`,`image`,`parent_id`,`top`,`column`,`sort_order`,`status`,`date_added`,`date_modified`) VALUES (5110,'',5112,0,1,1,1,NOW(),NOW()) ON DUPLICATE KEY UPDATE `image`=VALUES(`image`),`parent_id`=VALUES(`parent_id`),`top`=VALUES(`top`),`column`=VALUES(`column`),`sort_order`=VALUES(`sort_order`),`status`=VALUES(`status`),`date_modified`=NOW();
INSERT INTO `{{PREFIX}}category` (`category_id`,`image`,`parent_id`,`top`,`column`,`sort_order`,`status`,`date_added`,`date_modified`) VALUES (5111,'',5112,0,1,2,1,NOW(),NOW()) ON DUPLICATE KEY UPDATE `image`=VALUES(`image`),`parent_id`=VALUES(`parent_id`),`top`=VALUES(`top`),`column`=VALUES(`column`),`sort_order`=VALUES(`sort_order`),`status`=VALUES(`status`),`date_modified`=NOW();
INSERT INTO `{{PREFIX}}category` (`category_id`,`image`,`parent_id`,`top`,`column`,`sort_order`,`status`,`date_added`,`date_modified`) VALUES (144,'',136,0,1,1,1,NOW(),NOW()) ON DUPLICATE KEY UPDATE `image`=VALUES(`image`),`parent_id`=VALUES(`parent_id`),`top`=VALUES(`top`),`column`=VALUES(`column`),`sort_order`=VALUES(`sort_order`),`status`=VALUES(`status`),`date_modified`=NOW();
INSERT INTO `{{PREFIX}}category` (`category_id`,`image`,`parent_id`,`top`,`column`,`sort_order`,`status`,`date_added`,`date_modified`) VALUES (152,'',136,0,1,2,1,NOW(),NOW()) ON DUPLICATE KEY UPDATE `image`=VALUES(`image`),`parent_id`=VALUES(`parent_id`),`top`=VALUES(`top`),`column`=VALUES(`column`),`sort_order`=VALUES(`sort_order`),`status`=VALUES(`status`),`date_modified`=NOW();

INSERT INTO `{{PREFIX}}category_description` (`category_id`,`language_id`,`name`,`description`,`meta_title`,`meta_description`,`meta_keyword`) VALUES (86,2,'Посуд','<h2>Оренда посуду у Львові</h2><p>«Крістал» здає в оренду посуд для весіль, банкетів, фуршетів і корпоративів у Львові та області. У каталозі — біла порцеляна, салатниці, супниці, блюда для подачі й ексклюзивний посуд для урочистих подій.</p><p>Ціна вказана за одну позицію на добу. Що більше берете, то нижча ціна за одиницю: знижки діють від 100 штук. Миття входить у вартість оренди — повертайте посуд без миття.</p><ul><li>тарілки обідні, закусочні та десертні;</li><li>салатниці й супниці;</li><li>блюда для подачі страв;</li><li>ексклюзивний посуд для весіль.</li></ul><p>Доставка по Львову й області, самовивіз зі складу на вул. Богдана Хмельницького, 106. Підберемо комплект під ваше меню та кількість гостей.</p>','Оренда посуду у Львові — від 10 ₴/доба | Крістал','Оренда посуду для весілля, банкетів і фуршетів у Львові: тарілки, салатниці, супниці, блюда. Ціни за добу, знижки від 100 шт, доставка.','оренда посуду, посуд львів, оренда тарілок, прокат посуду') ON DUPLICATE KEY UPDATE `name`=VALUES(`name`),`description`=VALUES(`description`),`meta_title`=VALUES(`meta_title`),`meta_description`=VALUES(`meta_description`),`meta_keyword`=VALUES(`meta_keyword`);
INSERT INTO `{{PREFIX}}category_description` (`category_id`,`language_id`,`name`,`description`,`meta_title`,`meta_description`,`meta_keyword`) VALUES (88,2,'Столові прибори','<h2>Оренда столових приборів у Львові</h2><p>Виделки, ложки та ножі з нержавіючої сталі — для банкетів, весіль і фуршетів. Прибори підбираємо під ваше меню: столові, десертні, рибні та кавові.</p><p>Ціна за добу за один прибор. Для великих замовлень діють знижки за обсяг, а миття входить у вартість оренди.</p><ul><li>виделки столові та десертні;</li><li>ложки столові, чайні й кавові;</li><li>ножі столові та рибні.</li></ul><p>Порахуємо кількість приборів на вашу кількість гостей і формат події — залиште заявку або зателефонуйте.</p>','Оренда столових приборів у Львові — від 5 ₴ | Крістал','Оренда виделок, ложок і ножів для весілля, банкету й фуршету у Львові. Ціни за добу, знижки за обсяг, доставка. Підберемо комплект під меню.','оренда приборів, виделки, ложки, ножі, столові прибори львів') ON DUPLICATE KEY UPDATE `name`=VALUES(`name`),`description`=VALUES(`description`),`meta_title`=VALUES(`meta_title`),`meta_description`=VALUES(`meta_description`),`meta_keyword`=VALUES(`meta_keyword`);
INSERT INTO `{{PREFIX}}category_description` (`category_id`,`language_id`,`name`,`description`,`meta_title`,`meta_description`,`meta_keyword`) VALUES (126,2,'Скло та келихи','<h2>Оренда скла та келихів у Львові</h2><p>Келихи для вина й шампанського, склянки та чарки для банкетів, весіль і фуршетів. Скло міцне, добре миється й виглядає охайно на столі.</p><p>Ціна вказана за одну позицію на добу. Пошкоджене скло відшкодовується за узгодженою вартістю, а миття входить у вартість оренди.</p><ul><li>келихи для вина й шампанського;</li><li>склянки для води та напоїв;</li><li>чарки для горілки й наливок.</li></ul><p>Радимо брати скло з запасом 10–15% — на бій і заміну. Доставка по Львову й області.</p>','Оренда келихів і склянок у Львові — від 7 ₴ | Крістал','Оренда келихів для вина й шампанського, склянок і чарок для подій у Львові. Ціни за добу, знижки від 100 шт, доставка й вивезення.','оренда келихів, склянки, келихи для вина, скло львів') ON DUPLICATE KEY UPDATE `name`=VALUES(`name`),`description`=VALUES(`description`),`meta_title`=VALUES(`meta_title`),`meta_description`=VALUES(`meta_description`),`meta_keyword`=VALUES(`meta_keyword`);
INSERT INTO `{{PREFIX}}category_description` (`category_id`,`language_id`,`name`,`description`,`meta_title`,`meta_description`,`meta_keyword`) VALUES (137,2,'Кухонне обладнання','<h2>Оренда кухонного обладнання у Львові</h2><p>Марміти, чафінгдіші, каструлі та гастроємності — для кейтерингу, банкетів і великих подій. Обладнання тримає температуру страв і допомагає подати все вчасно.</p><p>Ціна за добу. Миємо й перевіряємо обладнання перед видачею, доставляємо на місце події та забираємо після.</p><ul><li>марміти та чафінгдіші;</li><li>каструлі великого об’єму;</li><li>гастроємності та кришки.</li></ul><p>Підкажемо, скільки обладнання потрібно на вашу кількість гостей і формат подачі.</p>','Оренда кухонного обладнання у Львові — від 40 ₴ | Крістал','Оренда мармітів, чафінгдішів, каструль і гастроємностей для кейтерингу та подій у Львові. Ціни за добу, доставка й вивезення.','оренда мармітів, чафінгдіш, кухонне обладнання львів, кейтеринг') ON DUPLICATE KEY UPDATE `name`=VALUES(`name`),`description`=VALUES(`description`),`meta_title`=VALUES(`meta_title`),`meta_description`=VALUES(`meta_description`),`meta_keyword`=VALUES(`meta_keyword`);
INSERT INTO `{{PREFIX}}category_description` (`category_id`,`language_id`,`name`,`description`,`meta_title`,`meta_description`,`meta_keyword`) VALUES (135,2,'Кавове обладнання','<h2>Оренда кавового обладнання у Львові</h2><p>Професійні кавові апарати, кавоварки та термопоти для весіль, конференцій і кейтерингу. Допомагаємо підібрати обладнання під кількість гостей і формат подачі.</p><p>Ціна за добу. Перед видачею перевіряємо техніку, за потреби консультуємо з налаштування та догляду.</p><ul><li>професійні кавові апарати;</li><li>кавоварки та термопоти;</li><li>обладнання для кави на виїзді.</li></ul><p>Доставка по Львову й області. Для постійних клієнтів і бізнесу — окремі умови.</p>','Оренда кавового обладнання у Львові — від 80 ₴ | Крістал','Оренда кавових апаратів, кавоварок і термопотів для подій, кейтерингу та бізнесу у Львові. Ціни за добу, доставка й налаштування.','оренда кавового апарата, кавоварка в оренду, термопот львів') ON DUPLICATE KEY UPDATE `name`=VALUES(`name`),`description`=VALUES(`description`),`meta_title`=VALUES(`meta_title`),`meta_description`=VALUES(`meta_description`),`meta_keyword`=VALUES(`meta_keyword`);
INSERT INTO `{{PREFIX}}category_description` (`category_id`,`language_id`,`name`,`description`,`meta_title`,`meta_description`,`meta_keyword`) VALUES (138,2,'Барне обладнання','<h2>Оренда барного обладнання у Львові</h2><p>Барні стійки та барний інвентар для весіль, корпоративів і фуршетів. Допомагаємо організувати бар на виїзді — від стійки до дрібного інвентарю.</p><p>Ціна за добу. Доставка, монтаж і демонтаж — за домовленістю, обладнання перевіряємо перед видачею.</p><ul><li>барні стійки;</li><li>барний інвентар і аксесуари;</li><li>обладнання для напоїв.</li></ul><p>Розкажіть про формат події — підберемо комплект під кількість гостей і напої.</p>','Оренда барного обладнання у Львові — від 40 ₴ | Крістал','Оренда барних стійок і барного інвентарю для весіль, корпоративів і фуршетів у Львові. Ціни за добу, доставка й монтаж.','оренда барної стійки, барний інвентар, бар львів') ON DUPLICATE KEY UPDATE `name`=VALUES(`name`),`description`=VALUES(`description`),`meta_title`=VALUES(`meta_title`),`meta_description`=VALUES(`meta_description`),`meta_keyword`=VALUES(`meta_keyword`);
INSERT INTO `{{PREFIX}}category_description` (`category_id`,`language_id`,`name`,`description`,`meta_title`,`meta_description`,`meta_keyword`) VALUES (140,2,'Меблі','<h2>Оренда меблів у Львові</h2><p>Столи, стільці та лаунж-меблі для весіль, банкетів і корпоративів. Підбираємо комплект під кількість гостей, формат розсадки й стиль події.</p><p>Ціна за добу. Доставка, монтаж і вивезення — за домовленістю. Меблі перевіряємо перед кожним замовленням.</p><ul><li>столи банкетні та фуршетні;</li><li>стільці та крісла;</li><li>лаунж-меблі для фотозон і зон відпочинку.</li></ul><p>Порахуємо, скільки столів і стільців потрібно на вашу подію, і запропонуємо розсадку.</p>','Оренда меблів у Львові — від 60 ₴/доба | Крістал','Оренда столів, стільців і лаунж-меблів для весілля, банкету та корпоративу у Львові. Ціни за добу, доставка, монтаж і вивезення.','оренда меблів львів, столи в оренду, стільці, лаунж меблі') ON DUPLICATE KEY UPDATE `name`=VALUES(`name`),`description`=VALUES(`description`),`meta_title`=VALUES(`meta_title`),`meta_description`=VALUES(`meta_description`),`meta_keyword`=VALUES(`meta_keyword`);
INSERT INTO `{{PREFIX}}category_description` (`category_id`,`language_id`,`name`,`description`,`meta_title`,`meta_description`,`meta_keyword`) VALUES (5112,2,'Текстиль','<h2>Оренда текстилю у Львові</h2><p>Скатертини, чохли на стільці та серветки для весіль, банкетів і корпоративів. Текстиль підбираємо під колір і стиль події.</p><p>Ціна за добу. Прання й прасування входять у вартість оренди — вам не потрібно нічого прати після події.</p><ul><li>скатертини різних розмірів;</li><li>чохли на стільці;</li><li>серветки та раннери.</li></ul><p>Допоможемо підібрати розміри під ваші столи й кількість гостей.</p>','Оренда текстилю у Львові — від 15 ₴/доба | Крістал','Оренда скатертин, чохлів на стільці та серветок для подій у Львові. Ціни за добу, прання входить у вартість, доставка.','оренда скатертин, чохли на стільці, текстиль львів') ON DUPLICATE KEY UPDATE `name`=VALUES(`name`),`description`=VALUES(`description`),`meta_title`=VALUES(`meta_title`),`meta_description`=VALUES(`meta_description`),`meta_keyword`=VALUES(`meta_keyword`);
INSERT INTO `{{PREFIX}}category_description` (`category_id`,`language_id`,`name`,`description`,`meta_title`,`meta_description`,`meta_keyword`) VALUES (141,2,'Шатри та накриття','<h2>Оренда шатрів і накриттів у Львові</h2><p>Шатри, палатки та накриття для весіль, корпоративів і фестивалів просто неба. Підбираємо розмір під кількість гостей і формат події.</p><p>Монтаж і демонтаж — у вартості за домовленістю. Враховуємо погоду, ґрунт і вимоги майданчика.</p><ul><li>шатри для банкетів;</li><li>палатки для окремих зон;</li><li>накриття та тенти.</li></ul><p>Розкажіть про локацію й кількість гостей — порахуємо вартість і терміни монтажу.</p>','Оренда шатрів і накриттів у Львові — від 1 500 ₴ | Крістал','Оренда шатрів, палаток і накриттів для весіль та корпоративів у Львові й області. Монтаж і демонтаж, доставка, розрахунок на дату.','оренда шатра львів, намет в оренду, палатка для події') ON DUPLICATE KEY UPDATE `name`=VALUES(`name`),`description`=VALUES(`description`),`meta_title`=VALUES(`meta_title`),`meta_description`=VALUES(`meta_description`),`meta_keyword`=VALUES(`meta_keyword`);
INSERT INTO `{{PREFIX}}category_description` (`category_id`,`language_id`,`name`,`description`,`meta_title`,`meta_description`,`meta_keyword`) VALUES (142,2,'Декор','<h2>Оренда декору у Львові</h2><p>Декоративні пляшки, блюда, свічники й аксесуари для оформлення столів і фотозон. Дрібні деталі створюють атмосферу події.</p><p>Ціна за добу. Допомагаємо зібрати комплект в одному стилі під вашу подію.</p><ul><li>декоративні пляшки та блюда;</li><li>свічники й підсвічники;</li><li>аксесуари для фотозон.</li></ul><p>Доставка по Львову й області. За потреби підберемо декор під колірну гаму весілля.</p>','Оренда декору у Львові — від 150 ₴/доба | Крістал','Оренда декоративних пляшок, блюд, свічників та аксесуарів для фотозон і столів у Львові. Ціни за добу, доставка.','оренда декору львів, декор для весілля, фотозона') ON DUPLICATE KEY UPDATE `name`=VALUES(`name`),`description`=VALUES(`description`),`meta_title`=VALUES(`meta_title`),`meta_description`=VALUES(`meta_description`),`meta_keyword`=VALUES(`meta_keyword`);
INSERT INTO `{{PREFIX}}category_description` (`category_id`,`language_id`,`name`,`description`,`meta_title`,`meta_description`,`meta_keyword`) VALUES (136,2,'Екопосуд','<h2>Оренда екопосуду у Львові</h2><p>Дерев’яні дошки, посуд з пластику та інвентар для подачі — для кейтерингу, фуршетів і подій на природі. Практичні позиції, які легко мити й транспортувати.</p><p>Ціна за добу. Миття входить у вартість оренди, доставка по Львову й області.</p><ul><li>дерев’яні дошки для подачі;</li><li>посуд та інвентар з пластику;</li><li>позиції для фуршетів і кейтерингу.</li></ul><p>Підберемо комплект під меню та кількість гостей.</p>','Оренда екопосуду у Львові — від 18 ₴/доба | Крістал','Оренда дерев’яних дощок, посуду з пластику та екоінвентарю для подій і кейтерингу у Львові. Ціни за добу, доставка.','оренда екопосуду, дерев’яні дошки, пластиковий посуд львів') ON DUPLICATE KEY UPDATE `name`=VALUES(`name`),`description`=VALUES(`description`),`meta_title`=VALUES(`meta_title`),`meta_description`=VALUES(`meta_description`),`meta_keyword`=VALUES(`meta_keyword`);
INSERT INTO `{{PREFIX}}category_description` (`category_id`,`language_id`,`name`,`description`,`meta_title`,`meta_description`,`meta_keyword`) VALUES (145,2,'Тарілки','<h2>Оренда тарілок у Львові</h2><p>Тарілки з білої порцеляни для весіль, банкетів і фуршетів: обідні, закусочні, десертні та глибокі. Ціна за штуку на добу, знижки від 100 штук.</p><p>Радимо брати на 10–15% більше — на бій і заміну. Миття входить у вартість оренди.</p>','Оренда тарілок у Львові — від 11 ₴/доба | Крістал','Оренда тарілок для весілля, банкету й фуршету у Львові: біла порцеляна, обідні, закусочні, десертні. Від 11 ₴ за штуку на добу, знижки від 100 шт.','оренда тарілок, тарілки львів, порцеляна в оренду') ON DUPLICATE KEY UPDATE `name`=VALUES(`name`),`description`=VALUES(`description`),`meta_title`=VALUES(`meta_title`),`meta_description`=VALUES(`meta_description`),`meta_keyword`=VALUES(`meta_keyword`);
INSERT INTO `{{PREFIX}}category_description` (`category_id`,`language_id`,`name`,`description`,`meta_title`,`meta_description`,`meta_keyword`) VALUES (147,2,'Салатниці','<h2>Оренда салатниць у Львові</h2><p>Салатниці різних розмірів і форм для подачі салатів, закусок і десертів. Порцеляна добре миється й виглядає охайно на столі.</p><p>Ціна за добу, знижки за обсяг, миття входить у вартість.</p>','Оренда салатниць у Львові — від 9 ₴/доба | Крістал','Оренда салатниць для весілля, банкету й фуршету у Львові. Порцеляна різних розмірів, ціни за добу, знижки за обсяг, доставка.','оренда салатниць, салатниці львів, посуд для банкету') ON DUPLICATE KEY UPDATE `name`=VALUES(`name`),`description`=VALUES(`description`),`meta_title`=VALUES(`meta_title`),`meta_description`=VALUES(`meta_description`),`meta_keyword`=VALUES(`meta_keyword`);
INSERT INTO `{{PREFIX}}category_description` (`category_id`,`language_id`,`name`,`description`,`meta_title`,`meta_description`,`meta_keyword`) VALUES (146,2,'Супниці','<h2>Оренда супниць у Львові</h2><p>Супниці різних об’ємів для перших страв і десертів. Порцеляна тримає температуру й легко миється.</p><p>Ціна за добу, знижки за обсяг, миття входить у вартість оренди.</p>','Оренда супниць у Львові — від 10 ₴/доба | Крістал','Оренда супниць для весілля, банкету й фуршету у Львові. Порцеляна різних об’ємів, ціни за добу, знижки за обсяг, доставка.','оренда супниць, супниця львів, посуд для перших страв') ON DUPLICATE KEY UPDATE `name`=VALUES(`name`),`description`=VALUES(`description`),`meta_title`=VALUES(`meta_title`),`meta_description`=VALUES(`meta_description`),`meta_keyword`=VALUES(`meta_keyword`);
INSERT INTO `{{PREFIX}}category_description` (`category_id`,`language_id`,`name`,`description`,`meta_title`,`meta_description`,`meta_keyword`) VALUES (5101,2,'Блюда для подачі','<h2>Оренда блюд для подачі у Львові</h2><p>Блюда для подачі риби, м’яса, закусок і десертів — порцеляна та нержавіюча сталь. Підбираємо розмір під страву й формат подачі.</p><p>Ціна за добу, миття входить у вартість, доставка по Львову й області.</p>','Оренда блюд для подачі у Львові — від 25 ₴ | Крістал','Оренда блюд для подачі страв на весілля, банкет і фуршет у Львові: порцеляна та нержавіюча сталь. Ціни за добу, доставка.','оренда блюд, блюдо для подачі, посуд львів') ON DUPLICATE KEY UPDATE `name`=VALUES(`name`),`description`=VALUES(`description`),`meta_title`=VALUES(`meta_title`),`meta_description`=VALUES(`meta_description`),`meta_keyword`=VALUES(`meta_keyword`);
INSERT INTO `{{PREFIX}}category_description` (`category_id`,`language_id`,`name`,`description`,`meta_title`,`meta_description`,`meta_keyword`) VALUES (143,2,'Ексклюзивний посуд','<h2>Оренда ексклюзивного посуду у Львові</h2><p>Підставні тарілки, дизайнерський посуд і позиції для урочистих подій. Допомагаємо зібрати комплект у стилі весілля.</p><p>Ціна за добу, миття входить у вартість, доставка по Львову й області.</p>','Оренда ексклюзивного посуду у Львові — від 22 ₴ | Крістал','Оренда ексклюзивного посуду для весіль і урочистих подій у Львові: підставні тарілки, дизайнерські позиції. Ціни за добу, доставка.','ексклюзивний посуд, підставні тарілки, оренда посуду львів') ON DUPLICATE KEY UPDATE `name`=VALUES(`name`),`description`=VALUES(`description`),`meta_title`=VALUES(`meta_title`),`meta_description`=VALUES(`meta_description`),`meta_keyword`=VALUES(`meta_keyword`);
INSERT INTO `{{PREFIX}}category_description` (`category_id`,`language_id`,`name`,`description`,`meta_title`,`meta_description`,`meta_keyword`) VALUES (149,2,'Виделки','<h2>Оренда виделок у Львові</h2><p>Виделки столові, десертні та рибні з нержавіючої сталі. Підбираємо набір під меню й кількість гостей.</p><p>Ціна за добу, миття входить у вартість, доставка по Львову й області.</p>','Оренда виделок у Львові — від 6 ₴/доба | Крістал','Оренда виделок для весілля, банкету й фуршету у Львові: столові, десертні, рибні. Нержавіюча сталь, ціни за добу, доставка.','оренда виделок, виделки львів, столові прибори') ON DUPLICATE KEY UPDATE `name`=VALUES(`name`),`description`=VALUES(`description`),`meta_title`=VALUES(`meta_title`),`meta_description`=VALUES(`meta_description`),`meta_keyword`=VALUES(`meta_keyword`);
INSERT INTO `{{PREFIX}}category_description` (`category_id`,`language_id`,`name`,`description`,`meta_title`,`meta_description`,`meta_keyword`) VALUES (150,2,'Ложки','<h2>Оренда ложок у Львові</h2><p>Ложки столові, чайні та кавові з нержавіючої сталі. Підбираємо набір під меню й кількість гостей.</p><p>Ціна за добу, миття входить у вартість, доставка по Львову й області.</p>','Оренда ложок у Львові — від 5 ₴/доба | Крістал','Оренда ложок для весілля, банкету й фуршету у Львові: столові, чайні, кавові. Нержавіюча сталь, ціни за добу, доставка.','оренда ложок, ложки львів, столові прибори') ON DUPLICATE KEY UPDATE `name`=VALUES(`name`),`description`=VALUES(`description`),`meta_title`=VALUES(`meta_title`),`meta_description`=VALUES(`meta_description`),`meta_keyword`=VALUES(`meta_keyword`);
INSERT INTO `{{PREFIX}}category_description` (`category_id`,`language_id`,`name`,`description`,`meta_title`,`meta_description`,`meta_keyword`) VALUES (148,2,'Ножі','<h2>Оренда ножів у Львові</h2><p>Ножі столові та рибні з нержавіючої сталі. Підбираємо набір під меню й кількість гостей.</p><p>Ціна за добу, миття входить у вартість, доставка по Львову й області.</p>','Оренда ножів у Львові — від 7 ₴/доба | Крістал','Оренда ножів для весілля, банкету й фуршету у Львові: столові та рибні. Нержавіюча сталь, ціни за добу, доставка.','оренда ножів, ножі львів, столові прибори') ON DUPLICATE KEY UPDATE `name`=VALUES(`name`),`description`=VALUES(`description`),`meta_title`=VALUES(`meta_title`),`meta_description`=VALUES(`meta_description`),`meta_keyword`=VALUES(`meta_keyword`);
INSERT INTO `{{PREFIX}}category_description` (`category_id`,`language_id`,`name`,`description`,`meta_title`,`meta_description`,`meta_keyword`) VALUES (151,2,'Склянки та чарки','<h2>Оренда склянок і чарок у Львові</h2><p>Склянки для води й напоїв, чарки для міцного. Міцне скло, охайний вигляд на столі.</p><p>Ціна за добу, знижки за обсяг, миття входить у вартість.</p>','Оренда склянок і чарок у Львові — від 7 ₴ | Крістал','Оренда склянок для води й напоїв та чарок для міцних напоїв у Львові. Ціни за добу, знижки за обсяг, доставка й вивезення.','оренда склянок, чарки, скло для подій') ON DUPLICATE KEY UPDATE `name`=VALUES(`name`),`description`=VALUES(`description`),`meta_title`=VALUES(`meta_title`),`meta_description`=VALUES(`meta_description`),`meta_keyword`=VALUES(`meta_keyword`);
INSERT INTO `{{PREFIX}}category_description` (`category_id`,`language_id`,`name`,`description`,`meta_title`,`meta_description`,`meta_keyword`) VALUES (5102,2,'Келихи для вина','<h2>Оренда келихів для вина у Львові</h2><p>Келихи для червоного й білого вина. Підбираємо кількість під формат події та меню напоїв.</p><p>Ціна за добу, миття входить у вартість, доставка по Львову й області.</p>','Оренда келихів для вина у Львові — від 12 ₴ | Крістал','Оренда келихів для вина на весілля, банкет і фуршет у Львові. Ціни за добу, знижки за обсяг, доставка й вивезення.','оренда келихів для вина, келихи львів') ON DUPLICATE KEY UPDATE `name`=VALUES(`name`),`description`=VALUES(`description`),`meta_title`=VALUES(`meta_title`),`meta_description`=VALUES(`meta_description`),`meta_keyword`=VALUES(`meta_keyword`);
INSERT INTO `{{PREFIX}}category_description` (`category_id`,`language_id`,`name`,`description`,`meta_title`,`meta_description`,`meta_keyword`) VALUES (5103,2,'Келихи для шампанського','<h2>Оренда келихів для шампанського у Львові</h2><p>Келихи для шампанського та ігристих вин — для весіль, ювілеїв і корпоративів.</p><p>Ціна за добу, миття входить у вартість, доставка по Львову й області.</p>','Оренда келихів для шампанського — від 13 ₴ | Крістал','Оренда келихів для шампанського та ігристих вин на весілля й урочисті події у Львові. Ціни за добу, доставка.','оренда келихів для шампанського, ігристі вина') ON DUPLICATE KEY UPDATE `name`=VALUES(`name`),`description`=VALUES(`description`),`meta_title`=VALUES(`meta_title`),`meta_description`=VALUES(`meta_description`),`meta_keyword`=VALUES(`meta_keyword`);
INSERT INTO `{{PREFIX}}category_description` (`category_id`,`language_id`,`name`,`description`,`meta_title`,`meta_description`,`meta_keyword`) VALUES (5104,2,'Марміти та чафінгдіші','<h2>Оренда мармітів і чафінгдішів у Львові</h2><p>Марміти та чафінгдіші тримають страви гарячими під час подачі. Для кейтерингу, банкетів і великих подій.</p><p>Ціна за добу, перевіряємо й миємо обладнання перед видачею.</p>','Оренда мармітів і чафінгдішів у Львові — від 420 ₴','Оренда мармітів і чафінгдішів для кейтерингу, банкетів і подій у Львові. Ціни за добу, доставка й вивезення.','оренда мармітів, чафінгдіш, кейтеринг львів') ON DUPLICATE KEY UPDATE `name`=VALUES(`name`),`description`=VALUES(`description`),`meta_title`=VALUES(`meta_title`),`meta_description`=VALUES(`meta_description`),`meta_keyword`=VALUES(`meta_keyword`);
INSERT INTO `{{PREFIX}}category_description` (`category_id`,`language_id`,`name`,`description`,`meta_title`,`meta_description`,`meta_keyword`) VALUES (5105,2,'Каструлі та гастроємності','<h2>Оренда каструль і гастроємностей у Львові</h2><p>Каструлі великого об’єму та гастроємності для приготування й подачі страв на подіях.</p><p>Ціна за добу, миття входить у вартість, доставка по Львову й області.</p>','Оренда каструль і гастроємностей — від 40 ₴ | Крістал','Оренда каструль і гастроємностей для кейтерингу та подій у Львові. Ціни за добу, доставка й вивезення.','оренда каструль, гастроємності, кухонний інвентар') ON DUPLICATE KEY UPDATE `name`=VALUES(`name`),`description`=VALUES(`description`),`meta_title`=VALUES(`meta_title`),`meta_description`=VALUES(`meta_description`),`meta_keyword`=VALUES(`meta_keyword`);
INSERT INTO `{{PREFIX}}category_description` (`category_id`,`language_id`,`name`,`description`,`meta_title`,`meta_description`,`meta_keyword`) VALUES (139,2,'Барні стійки','<h2>Оренда барних стійок у Львові</h2><p>Барні стійки для організації бару на виїзді. Підбираємо розмір і конфігурацію під локацію та кількість гостей.</p><p>Ціна за добу, доставка й монтаж — за домовленістю.</p>','Оренда барних стійок у Львові — від 1 200 ₴ | Крістал','Оренда барних стійок для весіль, корпоративів і фуршетів у Львові. Ціни за добу, доставка й монтаж.','оренда барної стійки, бар на виїзді, корпоратив львів') ON DUPLICATE KEY UPDATE `name`=VALUES(`name`),`description`=VALUES(`description`),`meta_title`=VALUES(`meta_title`),`meta_description`=VALUES(`meta_description`),`meta_keyword`=VALUES(`meta_keyword`);
INSERT INTO `{{PREFIX}}category_description` (`category_id`,`language_id`,`name`,`description`,`meta_title`,`meta_description`,`meta_keyword`) VALUES (5106,2,'Барний інвентар','<h2>Оренда барного інвентарю у Львові</h2><p>Шейкери, жігери, стрейнери та інший інвентар для бару на виїзді.</p><p>Ціна за добу, доставка по Львову й області, допоможемо зібрати комплект під напої.</p>','Оренда барного інвентарю у Львові — від 40 ₴ | Крістал','Оренда барного інвентарю для весіль, корпоративів і фуршетів у Львові: шейкери, жігери, аксесуари. Ціни за добу, доставка.','барний інвентар, шейкер, оренда бару') ON DUPLICATE KEY UPDATE `name`=VALUES(`name`),`description`=VALUES(`description`),`meta_title`=VALUES(`meta_title`),`meta_description`=VALUES(`meta_description`),`meta_keyword`=VALUES(`meta_keyword`);
INSERT INTO `{{PREFIX}}category_description` (`category_id`,`language_id`,`name`,`description`,`meta_title`,`meta_description`,`meta_keyword`) VALUES (5107,2,'Столи','<h2>Оренда столів у Львові</h2><p>Столи банкетні та фуршетні для весіль, банкетів і корпоративів. Підбираємо розмір під кількість гостей і формат розсадки.</p><p>Ціна за добу, доставка й монтаж — за домовленістю.</p>','Оренда столів у Львові — від 200 ₴/доба | Крістал','Оренда столів для весілля, банкету й фуршету у Львові. Ціни за добу, доставка, монтаж і вивезення.','оренда столів, банкетні столи, столи львів') ON DUPLICATE KEY UPDATE `name`=VALUES(`name`),`description`=VALUES(`description`),`meta_title`=VALUES(`meta_title`),`meta_description`=VALUES(`meta_description`),`meta_keyword`=VALUES(`meta_keyword`);
INSERT INTO `{{PREFIX}}category_description` (`category_id`,`language_id`,`name`,`description`,`meta_title`,`meta_description`,`meta_keyword`) VALUES (5108,2,'Стільці','<h2>Оренда стільців у Львові</h2><p>Стільці та крісла для банкетів, весіль і корпоративів. Підбираємо кількість і стиль під подію.</p><p>Ціна за добу, доставка й монтаж — за домовленістю.</p>','Оренда стільців у Львові — від 60 ₴/доба | Крістал','Оренда стільців для весілля, банкету й корпоративу у Львові. Ціни за добу, доставка, монтаж і вивезення.','оренда стільців, стільці львів, банкетні стільці') ON DUPLICATE KEY UPDATE `name`=VALUES(`name`),`description`=VALUES(`description`),`meta_title`=VALUES(`meta_title`),`meta_description`=VALUES(`meta_description`),`meta_keyword`=VALUES(`meta_keyword`);
INSERT INTO `{{PREFIX}}category_description` (`category_id`,`language_id`,`name`,`description`,`meta_title`,`meta_description`,`meta_keyword`) VALUES (5109,2,'Лаунж-меблі','<h2>Оренда лаунж-меблів у Львові</h2><p>Дивани, крісла та столики для зон відпочинку й фотозон на події.</p><p>Ціна за добу, доставка й монтаж — за домовленістю.</p>','Оренда лаунж-меблів у Львові — від 250 ₴ | Крістал','Оренда лаунж-меблів для весіль, корпоративів і фотозон у Львові: дивани, крісла, столики. Ціни за добу, доставка.','лаунж меблі, оренда диванів, фотозона львів') ON DUPLICATE KEY UPDATE `name`=VALUES(`name`),`description`=VALUES(`description`),`meta_title`=VALUES(`meta_title`),`meta_description`=VALUES(`meta_description`),`meta_keyword`=VALUES(`meta_keyword`);
INSERT INTO `{{PREFIX}}category_description` (`category_id`,`language_id`,`name`,`description`,`meta_title`,`meta_description`,`meta_keyword`) VALUES (5110,2,'Скатертини','<h2>Оренда скатертин у Львові</h2><p>Скатертини різних розмірів і кольорів для банкетних і фуршетних столів. Прання й прасування входять у вартість.</p><p>Ціна за добу, доставка по Львову й області.</p>','Оренда скатертин у Львові — від 150 ₴/доба | Крістал','Оренда скатертин для весілля, банкету й корпоративу у Львові. Прання входить у вартість, ціни за добу, доставка.','оренда скатертин, скатертина львів, текстиль для подій') ON DUPLICATE KEY UPDATE `name`=VALUES(`name`),`description`=VALUES(`description`),`meta_title`=VALUES(`meta_title`),`meta_description`=VALUES(`meta_description`),`meta_keyword`=VALUES(`meta_keyword`);
INSERT INTO `{{PREFIX}}category_description` (`category_id`,`language_id`,`name`,`description`,`meta_title`,`meta_description`,`meta_keyword`) VALUES (5111,2,'Чохли та серветки','<h2>Оренда чохлів і серветок у Львові</h2><p>Чохли на стільці та серветки для оформлення столів. Підбираємо колір під стиль події.</p><p>Ціна за добу, прання входить у вартість, доставка по Львову й області.</p>','Оренда чохлів і серветок у Львові — від 15 ₴ | Крістал','Оренда чохлів на стільці та серветок для весіль, банкетів і корпоративів у Львові. Ціни за добу, прання входить у вартість.','чохли на стільці, серветки, текстиль оренда') ON DUPLICATE KEY UPDATE `name`=VALUES(`name`),`description`=VALUES(`description`),`meta_title`=VALUES(`meta_title`),`meta_description`=VALUES(`meta_description`),`meta_keyword`=VALUES(`meta_keyword`);
INSERT INTO `{{PREFIX}}category_description` (`category_id`,`language_id`,`name`,`description`,`meta_title`,`meta_description`,`meta_keyword`) VALUES (144,2,'Дерев’яні дошки','<h2>Оренда дерев’яних дощок у Львові</h2><p>Дошки для подачі нарізок, сирів, м’яса й десертів. Дерево додає тепла й стилю фуршетній подачі.</p><p>Ціна за добу, миття входить у вартість, доставка по Львову й області.</p>','Оренда дерев’яних дощок у Львові — від 35 ₴ | Крістал','Оренда дерев’яних дощок для подачі страв на весілля, банкет і фуршет у Львові. Ціни за добу, доставка й вивезення.','дерев’яні дошки, дошки для подачі, фуршет') ON DUPLICATE KEY UPDATE `name`=VALUES(`name`),`description`=VALUES(`description`),`meta_title`=VALUES(`meta_title`),`meta_description`=VALUES(`meta_description`),`meta_keyword`=VALUES(`meta_keyword`);
INSERT INTO `{{PREFIX}}category_description` (`category_id`,`language_id`,`name`,`description`,`meta_title`,`meta_description`,`meta_keyword`) VALUES (152,2,'Інвентар та посуд з пластику','<h2>Оренда посуду з пластику у Львові</h2><p>Практичний посуд та інвентар з пластику для фуршетів, кейтерингу й подій на природі.</p><p>Ціна за добу, миття входить у вартість, доставка по Львову й області.</p>','Оренда посуду з пластику у Львові — від 12 ₴ | Крістал','Оренда посуду та інвентарю з пластику для подій, кейтерингу й фуршетів у Львові. Ціни за добу, доставка й вивезення.','пластиковий посуд, інвентар з пластику, кейтеринг') ON DUPLICATE KEY UPDATE `name`=VALUES(`name`),`description`=VALUES(`description`),`meta_title`=VALUES(`meta_title`),`meta_description`=VALUES(`meta_description`),`meta_keyword`=VALUES(`meta_keyword`);

DELETE FROM `{{PREFIX}}category_path` WHERE `category_id` IN (86,88,126,137,135,138,140,5112,141,142,136,145,147,146,5101,143,149,150,148,151,5102,5103,5104,5105,139,5106,5107,5108,5109,5110,5111,144,152);
INSERT INTO `{{PREFIX}}category_path` (`category_id`,`path_id`,`level`) VALUES (86,86,0);
INSERT INTO `{{PREFIX}}category_path` (`category_id`,`path_id`,`level`) VALUES (88,88,0);
INSERT INTO `{{PREFIX}}category_path` (`category_id`,`path_id`,`level`) VALUES (126,126,0);
INSERT INTO `{{PREFIX}}category_path` (`category_id`,`path_id`,`level`) VALUES (137,137,0);
INSERT INTO `{{PREFIX}}category_path` (`category_id`,`path_id`,`level`) VALUES (135,135,0);
INSERT INTO `{{PREFIX}}category_path` (`category_id`,`path_id`,`level`) VALUES (138,138,0);
INSERT INTO `{{PREFIX}}category_path` (`category_id`,`path_id`,`level`) VALUES (140,140,0);
INSERT INTO `{{PREFIX}}category_path` (`category_id`,`path_id`,`level`) VALUES (5112,5112,0);
INSERT INTO `{{PREFIX}}category_path` (`category_id`,`path_id`,`level`) VALUES (141,141,0);
INSERT INTO `{{PREFIX}}category_path` (`category_id`,`path_id`,`level`) VALUES (142,142,0);
INSERT INTO `{{PREFIX}}category_path` (`category_id`,`path_id`,`level`) VALUES (136,136,0);
INSERT INTO `{{PREFIX}}category_path` (`category_id`,`path_id`,`level`) VALUES (145,145,0);
INSERT INTO `{{PREFIX}}category_path` (`category_id`,`path_id`,`level`) VALUES (145,86,1);
INSERT INTO `{{PREFIX}}category_path` (`category_id`,`path_id`,`level`) VALUES (147,147,0);
INSERT INTO `{{PREFIX}}category_path` (`category_id`,`path_id`,`level`) VALUES (147,86,1);
INSERT INTO `{{PREFIX}}category_path` (`category_id`,`path_id`,`level`) VALUES (146,146,0);
INSERT INTO `{{PREFIX}}category_path` (`category_id`,`path_id`,`level`) VALUES (146,86,1);
INSERT INTO `{{PREFIX}}category_path` (`category_id`,`path_id`,`level`) VALUES (5101,5101,0);
INSERT INTO `{{PREFIX}}category_path` (`category_id`,`path_id`,`level`) VALUES (5101,86,1);
INSERT INTO `{{PREFIX}}category_path` (`category_id`,`path_id`,`level`) VALUES (143,143,0);
INSERT INTO `{{PREFIX}}category_path` (`category_id`,`path_id`,`level`) VALUES (143,86,1);
INSERT INTO `{{PREFIX}}category_path` (`category_id`,`path_id`,`level`) VALUES (149,149,0);
INSERT INTO `{{PREFIX}}category_path` (`category_id`,`path_id`,`level`) VALUES (149,88,1);
INSERT INTO `{{PREFIX}}category_path` (`category_id`,`path_id`,`level`) VALUES (150,150,0);
INSERT INTO `{{PREFIX}}category_path` (`category_id`,`path_id`,`level`) VALUES (150,88,1);
INSERT INTO `{{PREFIX}}category_path` (`category_id`,`path_id`,`level`) VALUES (148,148,0);
INSERT INTO `{{PREFIX}}category_path` (`category_id`,`path_id`,`level`) VALUES (148,88,1);
INSERT INTO `{{PREFIX}}category_path` (`category_id`,`path_id`,`level`) VALUES (151,151,0);
INSERT INTO `{{PREFIX}}category_path` (`category_id`,`path_id`,`level`) VALUES (151,126,1);
INSERT INTO `{{PREFIX}}category_path` (`category_id`,`path_id`,`level`) VALUES (5102,5102,0);
INSERT INTO `{{PREFIX}}category_path` (`category_id`,`path_id`,`level`) VALUES (5102,126,1);
INSERT INTO `{{PREFIX}}category_path` (`category_id`,`path_id`,`level`) VALUES (5103,5103,0);
INSERT INTO `{{PREFIX}}category_path` (`category_id`,`path_id`,`level`) VALUES (5103,126,1);
INSERT INTO `{{PREFIX}}category_path` (`category_id`,`path_id`,`level`) VALUES (5104,5104,0);
INSERT INTO `{{PREFIX}}category_path` (`category_id`,`path_id`,`level`) VALUES (5104,137,1);
INSERT INTO `{{PREFIX}}category_path` (`category_id`,`path_id`,`level`) VALUES (5105,5105,0);
INSERT INTO `{{PREFIX}}category_path` (`category_id`,`path_id`,`level`) VALUES (5105,137,1);
INSERT INTO `{{PREFIX}}category_path` (`category_id`,`path_id`,`level`) VALUES (139,139,0);
INSERT INTO `{{PREFIX}}category_path` (`category_id`,`path_id`,`level`) VALUES (139,138,1);
INSERT INTO `{{PREFIX}}category_path` (`category_id`,`path_id`,`level`) VALUES (5106,5106,0);
INSERT INTO `{{PREFIX}}category_path` (`category_id`,`path_id`,`level`) VALUES (5106,138,1);
INSERT INTO `{{PREFIX}}category_path` (`category_id`,`path_id`,`level`) VALUES (5107,5107,0);
INSERT INTO `{{PREFIX}}category_path` (`category_id`,`path_id`,`level`) VALUES (5107,140,1);
INSERT INTO `{{PREFIX}}category_path` (`category_id`,`path_id`,`level`) VALUES (5108,5108,0);
INSERT INTO `{{PREFIX}}category_path` (`category_id`,`path_id`,`level`) VALUES (5108,140,1);
INSERT INTO `{{PREFIX}}category_path` (`category_id`,`path_id`,`level`) VALUES (5109,5109,0);
INSERT INTO `{{PREFIX}}category_path` (`category_id`,`path_id`,`level`) VALUES (5109,140,1);
INSERT INTO `{{PREFIX}}category_path` (`category_id`,`path_id`,`level`) VALUES (5110,5110,0);
INSERT INTO `{{PREFIX}}category_path` (`category_id`,`path_id`,`level`) VALUES (5110,5112,1);
INSERT INTO `{{PREFIX}}category_path` (`category_id`,`path_id`,`level`) VALUES (5111,5111,0);
INSERT INTO `{{PREFIX}}category_path` (`category_id`,`path_id`,`level`) VALUES (5111,5112,1);
INSERT INTO `{{PREFIX}}category_path` (`category_id`,`path_id`,`level`) VALUES (144,144,0);
INSERT INTO `{{PREFIX}}category_path` (`category_id`,`path_id`,`level`) VALUES (144,136,1);
INSERT INTO `{{PREFIX}}category_path` (`category_id`,`path_id`,`level`) VALUES (152,152,0);
INSERT INTO `{{PREFIX}}category_path` (`category_id`,`path_id`,`level`) VALUES (152,136,1);

DELETE FROM `{{PREFIX}}category_to_store` WHERE `category_id` IN (86,88,126,137,135,138,140,5112,141,142,136,145,147,146,5101,143,149,150,148,151,5102,5103,5104,5105,139,5106,5107,5108,5109,5110,5111,144,152);
INSERT INTO `{{PREFIX}}category_to_store` (`category_id`,`store_id`) VALUES (86,0);
INSERT INTO `{{PREFIX}}category_to_store` (`category_id`,`store_id`) VALUES (88,0);
INSERT INTO `{{PREFIX}}category_to_store` (`category_id`,`store_id`) VALUES (126,0);
INSERT INTO `{{PREFIX}}category_to_store` (`category_id`,`store_id`) VALUES (137,0);
INSERT INTO `{{PREFIX}}category_to_store` (`category_id`,`store_id`) VALUES (135,0);
INSERT INTO `{{PREFIX}}category_to_store` (`category_id`,`store_id`) VALUES (138,0);
INSERT INTO `{{PREFIX}}category_to_store` (`category_id`,`store_id`) VALUES (140,0);
INSERT INTO `{{PREFIX}}category_to_store` (`category_id`,`store_id`) VALUES (5112,0);
INSERT INTO `{{PREFIX}}category_to_store` (`category_id`,`store_id`) VALUES (141,0);
INSERT INTO `{{PREFIX}}category_to_store` (`category_id`,`store_id`) VALUES (142,0);
INSERT INTO `{{PREFIX}}category_to_store` (`category_id`,`store_id`) VALUES (136,0);
INSERT INTO `{{PREFIX}}category_to_store` (`category_id`,`store_id`) VALUES (145,0);
INSERT INTO `{{PREFIX}}category_to_store` (`category_id`,`store_id`) VALUES (147,0);
INSERT INTO `{{PREFIX}}category_to_store` (`category_id`,`store_id`) VALUES (146,0);
INSERT INTO `{{PREFIX}}category_to_store` (`category_id`,`store_id`) VALUES (5101,0);
INSERT INTO `{{PREFIX}}category_to_store` (`category_id`,`store_id`) VALUES (143,0);
INSERT INTO `{{PREFIX}}category_to_store` (`category_id`,`store_id`) VALUES (149,0);
INSERT INTO `{{PREFIX}}category_to_store` (`category_id`,`store_id`) VALUES (150,0);
INSERT INTO `{{PREFIX}}category_to_store` (`category_id`,`store_id`) VALUES (148,0);
INSERT INTO `{{PREFIX}}category_to_store` (`category_id`,`store_id`) VALUES (151,0);
INSERT INTO `{{PREFIX}}category_to_store` (`category_id`,`store_id`) VALUES (5102,0);
INSERT INTO `{{PREFIX}}category_to_store` (`category_id`,`store_id`) VALUES (5103,0);
INSERT INTO `{{PREFIX}}category_to_store` (`category_id`,`store_id`) VALUES (5104,0);
INSERT INTO `{{PREFIX}}category_to_store` (`category_id`,`store_id`) VALUES (5105,0);
INSERT INTO `{{PREFIX}}category_to_store` (`category_id`,`store_id`) VALUES (139,0);
INSERT INTO `{{PREFIX}}category_to_store` (`category_id`,`store_id`) VALUES (5106,0);
INSERT INTO `{{PREFIX}}category_to_store` (`category_id`,`store_id`) VALUES (5107,0);
INSERT INTO `{{PREFIX}}category_to_store` (`category_id`,`store_id`) VALUES (5108,0);
INSERT INTO `{{PREFIX}}category_to_store` (`category_id`,`store_id`) VALUES (5109,0);
INSERT INTO `{{PREFIX}}category_to_store` (`category_id`,`store_id`) VALUES (5110,0);
INSERT INTO `{{PREFIX}}category_to_store` (`category_id`,`store_id`) VALUES (5111,0);
INSERT INTO `{{PREFIX}}category_to_store` (`category_id`,`store_id`) VALUES (144,0);
INSERT INTO `{{PREFIX}}category_to_store` (`category_id`,`store_id`) VALUES (152,0);

DELETE FROM `{{PREFIX}}seo_url` WHERE `store_id`=0 AND `query` IN ('category_id=86','category_id=88','category_id=126','category_id=137','category_id=135','category_id=138','category_id=140','category_id=5112','category_id=141','category_id=142','category_id=136','category_id=145','category_id=147','category_id=146','category_id=5101','category_id=143','category_id=149','category_id=150','category_id=148','category_id=151','category_id=5102','category_id=5103','category_id=5104','category_id=5105','category_id=139','category_id=5106','category_id=5107','category_id=5108','category_id=5109','category_id=5110','category_id=5111','category_id=144','category_id=152');
INSERT INTO `{{PREFIX}}seo_url` (`store_id`,`language_id`,`query`,`keyword`) VALUES (0,2,'category_id=86','posud');
INSERT INTO `{{PREFIX}}seo_url` (`store_id`,`language_id`,`query`,`keyword`) VALUES (0,2,'category_id=88','stolovi-prybory');
INSERT INTO `{{PREFIX}}seo_url` (`store_id`,`language_id`,`query`,`keyword`) VALUES (0,2,'category_id=126','sklo-ta-kelykhy');
INSERT INTO `{{PREFIX}}seo_url` (`store_id`,`language_id`,`query`,`keyword`) VALUES (0,2,'category_id=137','kukhonne-obladnannia');
INSERT INTO `{{PREFIX}}seo_url` (`store_id`,`language_id`,`query`,`keyword`) VALUES (0,2,'category_id=135','kavove-obladnannia');
INSERT INTO `{{PREFIX}}seo_url` (`store_id`,`language_id`,`query`,`keyword`) VALUES (0,2,'category_id=138','barne-obladnannia');
INSERT INTO `{{PREFIX}}seo_url` (`store_id`,`language_id`,`query`,`keyword`) VALUES (0,2,'category_id=140','mebli');
INSERT INTO `{{PREFIX}}seo_url` (`store_id`,`language_id`,`query`,`keyword`) VALUES (0,2,'category_id=5112','tekstyl');
INSERT INTO `{{PREFIX}}seo_url` (`store_id`,`language_id`,`query`,`keyword`) VALUES (0,2,'category_id=141','shatry');
INSERT INTO `{{PREFIX}}seo_url` (`store_id`,`language_id`,`query`,`keyword`) VALUES (0,2,'category_id=142','dekor');
INSERT INTO `{{PREFIX}}seo_url` (`store_id`,`language_id`,`query`,`keyword`) VALUES (0,2,'category_id=136','ekoposud');
INSERT INTO `{{PREFIX}}seo_url` (`store_id`,`language_id`,`query`,`keyword`) VALUES (0,2,'category_id=145','tarilky');
INSERT INTO `{{PREFIX}}seo_url` (`store_id`,`language_id`,`query`,`keyword`) VALUES (0,2,'category_id=147','salatnytsi');
INSERT INTO `{{PREFIX}}seo_url` (`store_id`,`language_id`,`query`,`keyword`) VALUES (0,2,'category_id=146','supnytsi');
INSERT INTO `{{PREFIX}}seo_url` (`store_id`,`language_id`,`query`,`keyword`) VALUES (0,2,'category_id=5101','blyuda');
INSERT INTO `{{PREFIX}}seo_url` (`store_id`,`language_id`,`query`,`keyword`) VALUES (0,2,'category_id=143','ekskliuzyvnyi-posud');
INSERT INTO `{{PREFIX}}seo_url` (`store_id`,`language_id`,`query`,`keyword`) VALUES (0,2,'category_id=149','vydelky');
INSERT INTO `{{PREFIX}}seo_url` (`store_id`,`language_id`,`query`,`keyword`) VALUES (0,2,'category_id=150','lozhky');
INSERT INTO `{{PREFIX}}seo_url` (`store_id`,`language_id`,`query`,`keyword`) VALUES (0,2,'category_id=148','nozhi');
INSERT INTO `{{PREFIX}}seo_url` (`store_id`,`language_id`,`query`,`keyword`) VALUES (0,2,'category_id=151','sklianky');
INSERT INTO `{{PREFIX}}seo_url` (`store_id`,`language_id`,`query`,`keyword`) VALUES (0,2,'category_id=5102','kelykhy-dlia-vyna');
INSERT INTO `{{PREFIX}}seo_url` (`store_id`,`language_id`,`query`,`keyword`) VALUES (0,2,'category_id=5103','kelykhy-dlia-shampanskoho');
INSERT INTO `{{PREFIX}}seo_url` (`store_id`,`language_id`,`query`,`keyword`) VALUES (0,2,'category_id=5104','marmity');
INSERT INTO `{{PREFIX}}seo_url` (`store_id`,`language_id`,`query`,`keyword`) VALUES (0,2,'category_id=5105','kastruli');
INSERT INTO `{{PREFIX}}seo_url` (`store_id`,`language_id`,`query`,`keyword`) VALUES (0,2,'category_id=139','barni-stiiky');
INSERT INTO `{{PREFIX}}seo_url` (`store_id`,`language_id`,`query`,`keyword`) VALUES (0,2,'category_id=5106','barnyi-inventar');
INSERT INTO `{{PREFIX}}seo_url` (`store_id`,`language_id`,`query`,`keyword`) VALUES (0,2,'category_id=5107','stoly');
INSERT INTO `{{PREFIX}}seo_url` (`store_id`,`language_id`,`query`,`keyword`) VALUES (0,2,'category_id=5108','stiltsi');
INSERT INTO `{{PREFIX}}seo_url` (`store_id`,`language_id`,`query`,`keyword`) VALUES (0,2,'category_id=5109','launzh-mebli');
INSERT INTO `{{PREFIX}}seo_url` (`store_id`,`language_id`,`query`,`keyword`) VALUES (0,2,'category_id=5110','skatertyny');
INSERT INTO `{{PREFIX}}seo_url` (`store_id`,`language_id`,`query`,`keyword`) VALUES (0,2,'category_id=5111','chokhly');
INSERT INTO `{{PREFIX}}seo_url` (`store_id`,`language_id`,`query`,`keyword`) VALUES (0,2,'category_id=144','dereviani-doshky');
INSERT INTO `{{PREFIX}}seo_url` (`store_id`,`language_id`,`query`,`keyword`) VALUES (0,2,'category_id=152','inventar-z-plastyku');



DELETE FROM `{{PREFIX}}product_to_category` WHERE `product_id` IN (989,990,991,992,993,1032,1036,1039,995,996,1031,997,998,999,1000,1030,1001,1003,1004,1012,1013,1027,1002,1005,1006,1011,1028,1035,1007,1008,1009,1010,1029,1014,1015,1016,1017,1020,1021,1023,994,1022,1024,1025,1026,1033,1034,1037,1038);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (989,144);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (989,136);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (990,144);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (990,136);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (991,144);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (991,136);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (992,144);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (992,136);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (993,144);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (993,136);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1032,144);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1032,136);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1036,144);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1036,136);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1039,144);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1039,136);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (995,135);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (996,135);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1031,135);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (997,5101);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (997,86);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (998,5101);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (998,86);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (999,5101);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (999,86);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1000,5101);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1000,86);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1030,5101);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1030,86);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1001,145);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1001,86);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1003,145);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1003,86);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1004,145);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1004,86);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1012,145);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1012,86);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1013,145);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1013,86);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1027,145);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1027,86);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1002,146);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1002,86);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1005,146);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1005,86);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1006,146);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1006,86);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1011,146);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1011,86);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1028,146);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1028,86);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1035,146);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1035,86);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1007,147);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1007,86);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1008,147);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1008,86);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1009,147);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1009,86);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1010,147);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1010,86);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1029,147);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1029,86);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1014,148);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1014,88);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1015,148);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1015,88);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1016,149);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1016,88);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1017,149);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1017,88);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1020,149);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1020,88);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1021,149);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1021,88);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1023,149);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1023,88);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (994,149);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (994,88);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1022,150);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1022,88);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1024,150);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1024,88);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1025,142);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1026,142);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1033,151);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1033,126);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1034,151);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1034,126);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1037,152);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1037,136);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1038,152);
INSERT INTO `{{PREFIX}}product_to_category` (`product_id`,`category_id`) VALUES (1038,136);

UPDATE `{{PREFIX}}product` SET `price`=40,`minimum`=1,`date_modified`=NOW() WHERE `product_id`=989;
UPDATE `{{PREFIX}}product` SET `price`=55,`minimum`=1,`date_modified`=NOW() WHERE `product_id`=990;
UPDATE `{{PREFIX}}product` SET `price`=70,`minimum`=1,`date_modified`=NOW() WHERE `product_id`=991;
UPDATE `{{PREFIX}}product` SET `price`=45,`minimum`=1,`date_modified`=NOW() WHERE `product_id`=992;
UPDATE `{{PREFIX}}product` SET `price`=35,`minimum`=1,`date_modified`=NOW() WHERE `product_id`=993;
UPDATE `{{PREFIX}}product` SET `price`=60,`minimum`=1,`date_modified`=NOW() WHERE `product_id`=1032;
UPDATE `{{PREFIX}}product` SET `price`=80,`minimum`=1,`date_modified`=NOW() WHERE `product_id`=1036;
UPDATE `{{PREFIX}}product` SET `price`=40,`minimum`=1,`date_modified`=NOW() WHERE `product_id`=1039;
UPDATE `{{PREFIX}}product` SET `price`=1000,`minimum`=1,`date_modified`=NOW() WHERE `product_id`=995;
UPDATE `{{PREFIX}}product` SET `price`=500,`minimum`=1,`date_modified`=NOW() WHERE `product_id`=996;
UPDATE `{{PREFIX}}product` SET `price`=1500,`minimum`=1,`date_modified`=NOW() WHERE `product_id`=1031;
UPDATE `{{PREFIX}}product` SET `price`=45,`minimum`=1,`date_modified`=NOW() WHERE `product_id`=997;
UPDATE `{{PREFIX}}product` SET `price`=65,`minimum`=1,`date_modified`=NOW() WHERE `product_id`=998;
UPDATE `{{PREFIX}}product` SET `price`=75,`minimum`=1,`date_modified`=NOW() WHERE `product_id`=999;
UPDATE `{{PREFIX}}product` SET `price`=45,`minimum`=1,`date_modified`=NOW() WHERE `product_id`=1000;
UPDATE `{{PREFIX}}product` SET `price`=28,`minimum`=1,`date_modified`=NOW() WHERE `product_id`=1030;
UPDATE `{{PREFIX}}product` SET `price`=25,`minimum`=1,`date_modified`=NOW() WHERE `product_id`=1001;
UPDATE `{{PREFIX}}product` SET `price`=14,`minimum`=1,`date_modified`=NOW() WHERE `product_id`=1003;
UPDATE `{{PREFIX}}product` SET `price`=14,`minimum`=1,`date_modified`=NOW() WHERE `product_id`=1004;
UPDATE `{{PREFIX}}product` SET `price`=35,`minimum`=1,`date_modified`=NOW() WHERE `product_id`=1012;
UPDATE `{{PREFIX}}product` SET `price`=14,`minimum`=1,`date_modified`=NOW() WHERE `product_id`=1013;
UPDATE `{{PREFIX}}product` SET `price`=12,`minimum`=1,`date_modified`=NOW() WHERE `product_id`=1027;
UPDATE `{{PREFIX}}product` SET `price`=18,`minimum`=1,`date_modified`=NOW() WHERE `product_id`=1002;
UPDATE `{{PREFIX}}product` SET `price`=12,`minimum`=1,`date_modified`=NOW() WHERE `product_id`=1005;
UPDATE `{{PREFIX}}product` SET `price`=10,`minimum`=1,`date_modified`=NOW() WHERE `product_id`=1006;
UPDATE `{{PREFIX}}product` SET `price`=18,`minimum`=1,`date_modified`=NOW() WHERE `product_id`=1011;
UPDATE `{{PREFIX}}product` SET `price`=18,`minimum`=1,`date_modified`=NOW() WHERE `product_id`=1028;
UPDATE `{{PREFIX}}product` SET `price`=12,`minimum`=1,`date_modified`=NOW() WHERE `product_id`=1035;
UPDATE `{{PREFIX}}product` SET `price`=12,`minimum`=1,`date_modified`=NOW() WHERE `product_id`=1007;
UPDATE `{{PREFIX}}product` SET `price`=10,`minimum`=1,`date_modified`=NOW() WHERE `product_id`=1008;
UPDATE `{{PREFIX}}product` SET `price`=11,`minimum`=1,`date_modified`=NOW() WHERE `product_id`=1009;
UPDATE `{{PREFIX}}product` SET `price`=9,`minimum`=1,`date_modified`=NOW() WHERE `product_id`=1010;
UPDATE `{{PREFIX}}product` SET `price`=16,`minimum`=1,`date_modified`=NOW() WHERE `product_id`=1029;
UPDATE `{{PREFIX}}product` SET `price`=12,`minimum`=1,`date_modified`=NOW() WHERE `product_id`=1014;
UPDATE `{{PREFIX}}product` SET `price`=12,`minimum`=1,`date_modified`=NOW() WHERE `product_id`=1015;
UPDATE `{{PREFIX}}product` SET `price`=10,`minimum`=1,`date_modified`=NOW() WHERE `product_id`=1016;
UPDATE `{{PREFIX}}product` SET `price`=10,`minimum`=1,`date_modified`=NOW() WHERE `product_id`=1017;
UPDATE `{{PREFIX}}product` SET `price`=8,`minimum`=1,`date_modified`=NOW() WHERE `product_id`=1020;
UPDATE `{{PREFIX}}product` SET `price`=9,`minimum`=1,`date_modified`=NOW() WHERE `product_id`=1021;
UPDATE `{{PREFIX}}product` SET `price`=10,`minimum`=1,`date_modified`=NOW() WHERE `product_id`=1023;
UPDATE `{{PREFIX}}product` SET `price`=20,`minimum`=1,`date_modified`=NOW() WHERE `product_id`=994;
UPDATE `{{PREFIX}}product` SET `price`=6,`minimum`=1,`date_modified`=NOW() WHERE `product_id`=1022;
UPDATE `{{PREFIX}}product` SET `price`=5,`minimum`=1,`date_modified`=NOW() WHERE `product_id`=1024;
UPDATE `{{PREFIX}}product` SET `price`=150,`minimum`=1,`date_modified`=NOW() WHERE `product_id`=1025;
UPDATE `{{PREFIX}}product` SET `price`=120,`minimum`=1,`date_modified`=NOW() WHERE `product_id`=1026;
UPDATE `{{PREFIX}}product` SET `price`=9,`minimum`=1,`date_modified`=NOW() WHERE `product_id`=1033;
UPDATE `{{PREFIX}}product` SET `price`=9,`minimum`=1,`date_modified`=NOW() WHERE `product_id`=1034;
UPDATE `{{PREFIX}}product` SET `price`=18,`minimum`=1,`date_modified`=NOW() WHERE `product_id`=1037;
UPDATE `{{PREFIX}}product` SET `price`=18,`minimum`=1,`date_modified`=NOW() WHERE `product_id`=1038;

DELETE FROM `{{PREFIX}}kristal_product_rental` WHERE `product_id` IN (989,990,991,992,993,1032,1036,1039,995,996,1031,997,998,999,1000,1030,1001,1003,1004,1012,1013,1027,1002,1005,1006,1011,1028,1035,1007,1008,1009,1010,1029,1014,1015,1016,1017,1020,1021,1023,994,1022,1024,1025,1026,1033,1034,1037,1038);
INSERT INTO `{{PREFIX}}kristal_product_rental` (`product_id`,`unit`,`deposit`,`breakage_price`,`washing_included`,`is_hit`) VALUES (989,'pcs',80,200,1,1);
INSERT INTO `{{PREFIX}}kristal_product_rental` (`product_id`,`unit`,`deposit`,`breakage_price`,`washing_included`,`is_hit`) VALUES (990,'pcs',110,275,1,0);
INSERT INTO `{{PREFIX}}kristal_product_rental` (`product_id`,`unit`,`deposit`,`breakage_price`,`washing_included`,`is_hit`) VALUES (991,'pcs',140,350,1,0);
INSERT INTO `{{PREFIX}}kristal_product_rental` (`product_id`,`unit`,`deposit`,`breakage_price`,`washing_included`,`is_hit`) VALUES (992,'pcs',90,225,1,0);
INSERT INTO `{{PREFIX}}kristal_product_rental` (`product_id`,`unit`,`deposit`,`breakage_price`,`washing_included`,`is_hit`) VALUES (993,'pcs',70,175,1,0);
INSERT INTO `{{PREFIX}}kristal_product_rental` (`product_id`,`unit`,`deposit`,`breakage_price`,`washing_included`,`is_hit`) VALUES (1032,'pcs',120,300,1,1);
INSERT INTO `{{PREFIX}}kristal_product_rental` (`product_id`,`unit`,`deposit`,`breakage_price`,`washing_included`,`is_hit`) VALUES (1036,'pcs',160,400,1,0);
INSERT INTO `{{PREFIX}}kristal_product_rental` (`product_id`,`unit`,`deposit`,`breakage_price`,`washing_included`,`is_hit`) VALUES (1039,'pcs',80,200,1,0);
INSERT INTO `{{PREFIX}}kristal_product_rental` (`product_id`,`unit`,`deposit`,`breakage_price`,`washing_included`,`is_hit`) VALUES (995,'pcs',2000,5000,1,1);
INSERT INTO `{{PREFIX}}kristal_product_rental` (`product_id`,`unit`,`deposit`,`breakage_price`,`washing_included`,`is_hit`) VALUES (996,'pcs',1000,2500,1,0);
INSERT INTO `{{PREFIX}}kristal_product_rental` (`product_id`,`unit`,`deposit`,`breakage_price`,`washing_included`,`is_hit`) VALUES (1031,'pcs',3000,7500,1,0);
INSERT INTO `{{PREFIX}}kristal_product_rental` (`product_id`,`unit`,`deposit`,`breakage_price`,`washing_included`,`is_hit`) VALUES (997,'pcs',90,225,1,0);
INSERT INTO `{{PREFIX}}kristal_product_rental` (`product_id`,`unit`,`deposit`,`breakage_price`,`washing_included`,`is_hit`) VALUES (998,'pcs',130,325,1,0);
INSERT INTO `{{PREFIX}}kristal_product_rental` (`product_id`,`unit`,`deposit`,`breakage_price`,`washing_included`,`is_hit`) VALUES (999,'pcs',150,375,1,0);
INSERT INTO `{{PREFIX}}kristal_product_rental` (`product_id`,`unit`,`deposit`,`breakage_price`,`washing_included`,`is_hit`) VALUES (1000,'pcs',90,225,1,0);
INSERT INTO `{{PREFIX}}kristal_product_rental` (`product_id`,`unit`,`deposit`,`breakage_price`,`washing_included`,`is_hit`) VALUES (1030,'pcs',56,140,1,1);
INSERT INTO `{{PREFIX}}kristal_product_rental` (`product_id`,`unit`,`deposit`,`breakage_price`,`washing_included`,`is_hit`) VALUES (1001,'pcs',50,125,1,1);
INSERT INTO `{{PREFIX}}kristal_product_rental` (`product_id`,`unit`,`deposit`,`breakage_price`,`washing_included`,`is_hit`) VALUES (1003,'pcs',28,70,1,1);
INSERT INTO `{{PREFIX}}kristal_product_rental` (`product_id`,`unit`,`deposit`,`breakage_price`,`washing_included`,`is_hit`) VALUES (1004,'pcs',28,70,1,0);
INSERT INTO `{{PREFIX}}kristal_product_rental` (`product_id`,`unit`,`deposit`,`breakage_price`,`washing_included`,`is_hit`) VALUES (1012,'pcs',70,175,1,0);
INSERT INTO `{{PREFIX}}kristal_product_rental` (`product_id`,`unit`,`deposit`,`breakage_price`,`washing_included`,`is_hit`) VALUES (1013,'pcs',28,70,1,0);
INSERT INTO `{{PREFIX}}kristal_product_rental` (`product_id`,`unit`,`deposit`,`breakage_price`,`washing_included`,`is_hit`) VALUES (1027,'pcs',24,60,1,0);
INSERT INTO `{{PREFIX}}kristal_product_rental` (`product_id`,`unit`,`deposit`,`breakage_price`,`washing_included`,`is_hit`) VALUES (1002,'pcs',36,90,1,0);
INSERT INTO `{{PREFIX}}kristal_product_rental` (`product_id`,`unit`,`deposit`,`breakage_price`,`washing_included`,`is_hit`) VALUES (1005,'pcs',24,60,1,0);
INSERT INTO `{{PREFIX}}kristal_product_rental` (`product_id`,`unit`,`deposit`,`breakage_price`,`washing_included`,`is_hit`) VALUES (1006,'pcs',20,50,1,0);
INSERT INTO `{{PREFIX}}kristal_product_rental` (`product_id`,`unit`,`deposit`,`breakage_price`,`washing_included`,`is_hit`) VALUES (1011,'pcs',36,90,1,0);
INSERT INTO `{{PREFIX}}kristal_product_rental` (`product_id`,`unit`,`deposit`,`breakage_price`,`washing_included`,`is_hit`) VALUES (1028,'pcs',36,90,1,0);
INSERT INTO `{{PREFIX}}kristal_product_rental` (`product_id`,`unit`,`deposit`,`breakage_price`,`washing_included`,`is_hit`) VALUES (1035,'pcs',24,60,1,0);
INSERT INTO `{{PREFIX}}kristal_product_rental` (`product_id`,`unit`,`deposit`,`breakage_price`,`washing_included`,`is_hit`) VALUES (1007,'pcs',24,60,1,0);
INSERT INTO `{{PREFIX}}kristal_product_rental` (`product_id`,`unit`,`deposit`,`breakage_price`,`washing_included`,`is_hit`) VALUES (1008,'pcs',20,50,1,0);
INSERT INTO `{{PREFIX}}kristal_product_rental` (`product_id`,`unit`,`deposit`,`breakage_price`,`washing_included`,`is_hit`) VALUES (1009,'pcs',22,55,1,0);
INSERT INTO `{{PREFIX}}kristal_product_rental` (`product_id`,`unit`,`deposit`,`breakage_price`,`washing_included`,`is_hit`) VALUES (1010,'pcs',18,45,1,0);
INSERT INTO `{{PREFIX}}kristal_product_rental` (`product_id`,`unit`,`deposit`,`breakage_price`,`washing_included`,`is_hit`) VALUES (1029,'pcs',32,80,1,0);
INSERT INTO `{{PREFIX}}kristal_product_rental` (`product_id`,`unit`,`deposit`,`breakage_price`,`washing_included`,`is_hit`) VALUES (1014,'pcs',24,60,1,0);
INSERT INTO `{{PREFIX}}kristal_product_rental` (`product_id`,`unit`,`deposit`,`breakage_price`,`washing_included`,`is_hit`) VALUES (1015,'pcs',24,60,1,0);
INSERT INTO `{{PREFIX}}kristal_product_rental` (`product_id`,`unit`,`deposit`,`breakage_price`,`washing_included`,`is_hit`) VALUES (1016,'pcs',20,50,1,1);
INSERT INTO `{{PREFIX}}kristal_product_rental` (`product_id`,`unit`,`deposit`,`breakage_price`,`washing_included`,`is_hit`) VALUES (1017,'pcs',20,50,1,0);
INSERT INTO `{{PREFIX}}kristal_product_rental` (`product_id`,`unit`,`deposit`,`breakage_price`,`washing_included`,`is_hit`) VALUES (1020,'pcs',16,40,1,0);
INSERT INTO `{{PREFIX}}kristal_product_rental` (`product_id`,`unit`,`deposit`,`breakage_price`,`washing_included`,`is_hit`) VALUES (1021,'pcs',18,45,1,0);
INSERT INTO `{{PREFIX}}kristal_product_rental` (`product_id`,`unit`,`deposit`,`breakage_price`,`washing_included`,`is_hit`) VALUES (1023,'pcs',20,50,1,0);
INSERT INTO `{{PREFIX}}kristal_product_rental` (`product_id`,`unit`,`deposit`,`breakage_price`,`washing_included`,`is_hit`) VALUES (994,'pcs',40,100,1,0);
INSERT INTO `{{PREFIX}}kristal_product_rental` (`product_id`,`unit`,`deposit`,`breakage_price`,`washing_included`,`is_hit`) VALUES (1022,'pcs',12,30,1,0);
INSERT INTO `{{PREFIX}}kristal_product_rental` (`product_id`,`unit`,`deposit`,`breakage_price`,`washing_included`,`is_hit`) VALUES (1024,'pcs',10,25,1,0);
INSERT INTO `{{PREFIX}}kristal_product_rental` (`product_id`,`unit`,`deposit`,`breakage_price`,`washing_included`,`is_hit`) VALUES (1025,'pcs',300,750,1,0);
INSERT INTO `{{PREFIX}}kristal_product_rental` (`product_id`,`unit`,`deposit`,`breakage_price`,`washing_included`,`is_hit`) VALUES (1026,'pcs',240,600,1,0);
INSERT INTO `{{PREFIX}}kristal_product_rental` (`product_id`,`unit`,`deposit`,`breakage_price`,`washing_included`,`is_hit`) VALUES (1033,'pcs',18,45,1,1);
INSERT INTO `{{PREFIX}}kristal_product_rental` (`product_id`,`unit`,`deposit`,`breakage_price`,`washing_included`,`is_hit`) VALUES (1034,'pcs',18,45,1,1);
INSERT INTO `{{PREFIX}}kristal_product_rental` (`product_id`,`unit`,`deposit`,`breakage_price`,`washing_included`,`is_hit`) VALUES (1037,'pcs',36,90,1,0);
INSERT INTO `{{PREFIX}}kristal_product_rental` (`product_id`,`unit`,`deposit`,`breakage_price`,`washing_included`,`is_hit`) VALUES (1038,'pcs',36,90,1,0);

DELETE FROM `{{PREFIX}}product_discount` WHERE `product_id` IN (989,990,991,992,993,1032,1036,1039,995,996,1031,997,998,999,1000,1030,1001,1003,1004,1012,1013,1027,1002,1005,1006,1011,1028,1035,1007,1008,1009,1010,1029,1014,1015,1016,1017,1020,1021,1023,994,1022,1024,1025,1026,1033,1034,1037,1038);
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (989,1,20,1,36,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (989,1,50,1,34,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (990,1,20,1,49.5,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (990,1,50,1,46.75,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (991,1,20,1,63,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (991,1,50,1,59.5,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (992,1,20,1,40.5,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (992,1,50,1,38.25,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (993,1,20,1,31.5,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (993,1,50,1,29.75,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (1032,1,20,1,54,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (1032,1,50,1,51,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (1036,1,20,1,72,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (1036,1,50,1,68,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (1039,1,20,1,36,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (1039,1,50,1,34,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (997,1,100,1,40.5,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (997,1,300,1,38.25,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (998,1,100,1,58.5,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (998,1,300,1,55.25,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (999,1,100,1,67.5,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (999,1,300,1,63.75,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (1000,1,100,1,40.5,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (1000,1,300,1,38.25,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (1030,1,100,1,25.2,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (1030,1,300,1,23.8,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (1001,1,100,1,22.5,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (1001,1,300,1,21.25,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (1003,1,100,1,12.6,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (1003,1,300,1,11.9,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (1004,1,100,1,12.6,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (1004,1,300,1,11.9,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (1012,1,100,1,31.5,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (1012,1,300,1,29.75,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (1013,1,100,1,12.6,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (1013,1,300,1,11.9,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (1027,1,100,1,10.8,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (1027,1,300,1,10.2,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (1002,1,100,1,16.2,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (1002,1,300,1,15.3,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (1005,1,100,1,10.8,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (1005,1,300,1,10.2,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (1006,1,100,1,9,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (1006,1,300,1,8.5,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (1011,1,100,1,16.2,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (1011,1,300,1,15.3,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (1028,1,100,1,16.2,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (1028,1,300,1,15.3,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (1035,1,100,1,10.8,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (1035,1,300,1,10.2,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (1007,1,100,1,10.8,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (1007,1,300,1,10.2,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (1008,1,100,1,9,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (1008,1,300,1,8.5,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (1009,1,100,1,9.9,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (1009,1,300,1,9.35,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (1010,1,100,1,8.1,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (1010,1,300,1,7.65,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (1029,1,100,1,14.4,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (1029,1,300,1,13.6,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (1014,1,100,1,10.8,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (1014,1,300,1,10.2,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (1015,1,100,1,10.8,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (1015,1,300,1,10.2,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (1016,1,100,1,9,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (1016,1,300,1,8.5,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (1017,1,100,1,9,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (1017,1,300,1,8.5,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (1020,1,100,1,7.2,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (1020,1,300,1,6.8,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (1021,1,100,1,8.1,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (1021,1,300,1,7.65,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (1023,1,100,1,9,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (1023,1,300,1,8.5,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (994,1,100,1,18,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (994,1,300,1,17,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (1022,1,100,1,5.4,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (1022,1,300,1,5.1,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (1024,1,100,1,4.5,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (1024,1,300,1,4.25,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (1033,1,100,1,8.1,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (1033,1,300,1,7.65,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (1034,1,100,1,8.1,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (1034,1,300,1,7.65,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (1037,1,100,1,16.2,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (1037,1,300,1,15.3,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (1038,1,100,1,16.2,'0000-00-00','0000-00-00');
INSERT INTO `{{PREFIX}}product_discount` (`product_id`,`customer_group_id`,`quantity`,`priority`,`price`,`date_start`,`date_end`) VALUES (1038,1,300,1,15.3,'0000-00-00','0000-00-00');

UPDATE `{{PREFIX}}product_description` SET `meta_title`='Дерев''яна дошка 30*20 — оренда у Львові, 40 ₴/доба | Крістал',`meta_description`='Дерев''яна дошка 30*20 в оренду у Львові: 40 ₴ за добу, мінімум 1 шт. Доставка й вивезення, знижки за обсяг. Замовляйте у «Крістал».' WHERE `product_id`=989 AND `language_id`=2;
UPDATE `{{PREFIX}}product_description` SET `description`='<p>Дерев''яна дошка 30*20 — в оренду у Львові для весіль, банкетів і фуршетів. Ціна 40 ₴ за добу, мінімальне замовлення 1 шт. Миття входить у вартість, доставка по Львову й області.</p>' WHERE `product_id`=989 AND `language_id`=2 AND (`description`='' OR `description` IS NULL);
UPDATE `{{PREFIX}}product_description` SET `meta_title`='Дерев''яна дошка 40*25 — оренда у Львові, 55 ₴/доба | Крістал',`meta_description`='Дерев''яна дошка 40*25 в оренду у Львові: 55 ₴ за добу, мінімум 1 шт. Доставка й вивезення, знижки за обсяг. Замовляйте у «Крістал».' WHERE `product_id`=990 AND `language_id`=2;
UPDATE `{{PREFIX}}product_description` SET `description`='<p>Дерев''яна дошка 40*25 — в оренду у Львові для весіль, банкетів і фуршетів. Ціна 55 ₴ за добу, мінімальне замовлення 1 шт. Миття входить у вартість, доставка по Львову й області.</p>' WHERE `product_id`=990 AND `language_id`=2 AND (`description`='' OR `description` IS NULL);
UPDATE `{{PREFIX}}product_description` SET `meta_title`='Дерев''яна дошка 45*30 — оренда у Львові, 70 ₴/доба | Крістал',`meta_description`='Дерев''яна дошка 45*30 в оренду у Львові: 70 ₴ за добу, мінімум 1 шт. Доставка й вивезення, знижки за обсяг. Замовляйте у «Крістал».' WHERE `product_id`=991 AND `language_id`=2;
UPDATE `{{PREFIX}}product_description` SET `description`='<p>Дерев''яна дошка 45*30 — в оренду у Львові для весіль, банкетів і фуршетів. Ціна 70 ₴ за добу, мінімальне замовлення 1 шт. Миття входить у вартість, доставка по Львову й області.</p>' WHERE `product_id`=991 AND `language_id`=2 AND (`description`='' OR `description` IS NULL);
UPDATE `{{PREFIX}}product_description` SET `meta_title`='Дерев''яна рибниця 35*14 — оренда у Львові, 45 ₴/доба | Крістал',`meta_description`='Дерев''яна рибниця 35*14 в оренду у Львові: 45 ₴ за добу, мінімум 1 шт. Доставка й вивезення, знижки за обсяг. Замовляйте у «Крістал».' WHERE `product_id`=992 AND `language_id`=2;
UPDATE `{{PREFIX}}product_description` SET `description`='<p>Дерев''яна рибниця 35*14 — в оренду у Львові для весіль, банкетів і фуршетів. Ціна 45 ₴ за добу, мінімальне замовлення 1 шт. Миття входить у вартість, доставка по Львову й області.</p>' WHERE `product_id`=992 AND `language_id`=2 AND (`description`='' OR `description` IS NULL);
UPDATE `{{PREFIX}}product_description` SET `meta_title`='Дерев''яна рибниця 35*9 — оренда у Львові, 35 ₴/доба | Крістал',`meta_description`='Дерев''яна рибниця 35*9 в оренду у Львові: 35 ₴ за добу, мінімум 1 шт. Доставка й вивезення, знижки за обсяг. Замовляйте у «Крістал».' WHERE `product_id`=993 AND `language_id`=2;
UPDATE `{{PREFIX}}product_description` SET `description`='<p>Дерев''яна рибниця 35*9 — в оренду у Львові для весіль, банкетів і фуршетів. Ціна 35 ₴ за добу, мінімальне замовлення 1 шт. Миття входить у вартість, доставка по Львову й області.</p>' WHERE `product_id`=993 AND `language_id`=2 AND (`description`='' OR `description` IS NULL);
UPDATE `{{PREFIX}}product_description` SET `meta_title`='Дерев''яна дошка овальна 40*20 — оренда у Львові | Крістал',`meta_description`='Дерев''яна дошка овальна 40*20 в оренду у Львові: 60 ₴ за добу, мінімум 1 шт. Доставка й вивезення, знижки за обсяг. Замовляйте у «Крістал».' WHERE `product_id`=1032 AND `language_id`=2;
UPDATE `{{PREFIX}}product_description` SET `description`='<p>Дерев''яна дошка овальна 40*20 — в оренду у Львові для весіль, банкетів і фуршетів. Ціна 60 ₴ за добу, мінімальне замовлення 1 шт. Миття входить у вартість, доставка по Львову й області.</p>' WHERE `product_id`=1032 AND `language_id`=2 AND (`description`='' OR `description` IS NULL);
UPDATE `{{PREFIX}}product_description` SET `meta_title`='Дерев''яна дошка 42*28*18,5 — оренда у Львові, 80 ₴/доба | Крістал',`meta_description`='Дерев''яна дошка 42*28*18,5 в оренду у Львові: 80 ₴ за добу, мінімум 1 шт. Доставка й вивезення, знижки за обсяг. Замовляйте у «Крістал».' WHERE `product_id`=1036 AND `language_id`=2;
UPDATE `{{PREFIX}}product_description` SET `description`='<p>Дерев''яна дошка 42*28*18,5 — в оренду у Львові для весіль, банкетів і фуршетів. Ціна 80 ₴ за добу, мінімальне замовлення 1 шт. Миття входить у вартість, доставка по Львову й області.</p>' WHERE `product_id`=1036 AND `language_id`=2 AND (`description`='' OR `description` IS NULL);
UPDATE `{{PREFIX}}product_description` SET `meta_title`='Хлібниця 25*25*8 — оренда у Львові, 40 ₴/доба | Крістал',`meta_description`='Хлібниця 25*25*8 в оренду у Львові: 40 ₴ за добу, мінімум 1 шт. Доставка й вивезення, знижки за обсяг. Замовляйте у «Крістал».' WHERE `product_id`=1039 AND `language_id`=2;
UPDATE `{{PREFIX}}product_description` SET `description`='<p>Хлібниця 25*25*8 — в оренду у Львові для весіль, банкетів і фуршетів. Ціна 40 ₴ за добу, мінімальне замовлення 1 шт. Миття входить у вартість, доставка по Львову й області.</p>' WHERE `product_id`=1039 AND `language_id`=2 AND (`description`='' OR `description` IS NULL);
UPDATE `{{PREFIX}}product_description` SET `meta_title`='Кавовий апарат Saeko Liberty''s — оренда у Львові | Крістал',`meta_description`='Кавовий апарат Saeko Liberty''s в оренду у Львові: 1000 ₴ за добу, мінімум 1 шт. Доставка й вивезення, знижки за обсяг. Замовляйте у «Крістал».' WHERE `product_id`=995 AND `language_id`=2;
UPDATE `{{PREFIX}}product_description` SET `description`='<p>Кавовий апарат Saeko Liberty''s — в оренду у Львові для весіль, банкетів і фуршетів. Ціна 1000 ₴ за добу, мінімальне замовлення 1 шт. Миття входить у вартість, доставка по Львову й області.</p>' WHERE `product_id`=995 AND `language_id`=2 AND (`description`='' OR `description` IS NULL);
UPDATE `{{PREFIX}}product_description` SET `meta_title`='Термопот — оренда у Львові, 500 ₴/доба | Крістал',`meta_description`='Термопот в оренду у Львові: 500 ₴ за добу, мінімум 1 шт. Доставка й вивезення, знижки за обсяг. Замовляйте у «Крістал».' WHERE `product_id`=996 AND `language_id`=2;
UPDATE `{{PREFIX}}product_description` SET `description`='<p>Термопот — в оренду у Львові для весіль, банкетів і фуршетів. Ціна 500 ₴ за добу, мінімальне замовлення 1 шт. Миття входить у вартість, доставка по Львову й області.</p>' WHERE `product_id`=996 AND `language_id`=2 AND (`description`='' OR `description` IS NULL);
UPDATE `{{PREFIX}}product_description` SET `meta_title`='Професійний кавовий апарат WMF Presto — оренда у Львові | Крістал',`meta_description`='Професійний кавовий апарат WMF Presto в оренду у Львові: 1500 ₴ за добу, мінімум 1 шт. Доставка й вивезення, знижки за обсяг. Замовляйте у «Крістал».' WHERE `product_id`=1031 AND `language_id`=2;
UPDATE `{{PREFIX}}product_description` SET `description`='<p>Професійний кавовий апарат WMF Presto — в оренду у Львові для весіль, банкетів і фуршетів. Ціна 1500 ₴ за добу, мінімальне замовлення 1 шт. Миття входить у вартість, доставка по Львову й області.</p>' WHERE `product_id`=1031 AND `language_id`=2 AND (`description`='' OR `description` IS NULL);
UPDATE `{{PREFIX}}product_description` SET `meta_title`='Сервірувальне блюдо для риби з нержавію… — оренда у Львові | Крі…',`meta_description`='Сервірувальне блюдо для риби з нержавіючою сталі 45 см. в оренду у Львові: 45 ₴/доба, від 1 шт. Доставка, знижки за обсяг.' WHERE `product_id`=997 AND `language_id`=2;
UPDATE `{{PREFIX}}product_description` SET `description`='<p>Сервірувальне блюдо для риби з нержавіючою сталі 45 см. — в оренду у Львові для весіль, банкетів і фуршетів. Ціна 45 ₴ за добу, мінімальне замовлення 1 шт. Миття входить у вартість, доставка по Львову й області.</p>' WHERE `product_id`=997 AND `language_id`=2 AND (`description`='' OR `description` IS NULL);
UPDATE `{{PREFIX}}product_description` SET `meta_title`='Сервірувальне блюдо для риби з нержавію… — оренда у Львові | Крі…',`meta_description`='Сервірувальне блюдо для риби з нержавіючою сталі 65 см. в оренду у Львові: 65 ₴/доба, від 1 шт. Доставка, знижки за обсяг.' WHERE `product_id`=998 AND `language_id`=2;
UPDATE `{{PREFIX}}product_description` SET `description`='<p>Сервірувальне блюдо для риби з нержавіючою сталі 65 см. — в оренду у Львові для весіль, банкетів і фуршетів. Ціна 65 ₴ за добу, мінімальне замовлення 1 шт. Миття входить у вартість, доставка по Львову й області.</p>' WHERE `product_id`=998 AND `language_id`=2 AND (`description`='' OR `description` IS NULL);
UPDATE `{{PREFIX}}product_description` SET `meta_title`='Сервірувальне блюдо для риби з нержавію… — оренда у Львові | Крі…',`meta_description`='Сервірувальне блюдо для риби з нержавіючою сталі 69 см. в оренду у Львові: 75 ₴/доба, від 1 шт. Доставка, знижки за обсяг.' WHERE `product_id`=999 AND `language_id`=2;
UPDATE `{{PREFIX}}product_description` SET `description`='<p>Сервірувальне блюдо для риби з нержавіючою сталі 69 см. — в оренду у Львові для весіль, банкетів і фуршетів. Ціна 75 ₴ за добу, мінімальне замовлення 1 шт. Миття входить у вартість, доставка по Львову й області.</p>' WHERE `product_id`=999 AND `language_id`=2 AND (`description`='' OR `description` IS NULL);
UPDATE `{{PREFIX}}product_description` SET `meta_title`='Блюдо овальне 35 см — оренда у Львові, 45 ₴/доба | Крістал',`meta_description`='Блюдо овальне 35 см в оренду у Львові: 45 ₴ за добу, мінімум 1 шт. Доставка й вивезення, знижки за обсяг. Замовляйте у «Крістал».' WHERE `product_id`=1000 AND `language_id`=2;
UPDATE `{{PREFIX}}product_description` SET `description`='<p>Блюдо овальне 35 см — в оренду у Львові для весіль, банкетів і фуршетів. Ціна 45 ₴ за добу, мінімальне замовлення 1 шт. Миття входить у вартість, доставка по Львову й області.</p>' WHERE `product_id`=1000 AND `language_id`=2 AND (`description`='' OR `description` IS NULL);
UPDATE `{{PREFIX}}product_description` SET `meta_title`='Блюдо закусочне 14 * 7,5 см — оренда у Львові | Крістал',`meta_description`='Блюдо закусочне 14 * 7,5 см в оренду у Львові: 28 ₴ за добу, мінімум 1 шт. Доставка й вивезення, знижки за обсяг. Замовляйте у «Крістал».' WHERE `product_id`=1030 AND `language_id`=2;
UPDATE `{{PREFIX}}product_description` SET `description`='<p>Блюдо закусочне 14 * 7,5 см — в оренду у Львові для весіль, банкетів і фуршетів. Ціна 28 ₴ за добу, мінімальне замовлення 1 шт. Миття входить у вартість, доставка по Львову й області.</p>' WHERE `product_id`=1030 AND `language_id`=2 AND (`description`='' OR `description` IS NULL);
UPDATE `{{PREFIX}}product_description` SET `meta_title`='Тарілка 26 * 26 см — оренда у Львові, 25 ₴/доба | Крістал',`meta_description`='Тарілка 26 * 26 см в оренду у Львові: 25 ₴ за добу, мінімум 1 шт. Доставка й вивезення, знижки за обсяг. Замовляйте у «Крістал».' WHERE `product_id`=1001 AND `language_id`=2;
UPDATE `{{PREFIX}}product_description` SET `description`='<p>Тарілка 26 * 26 см — в оренду у Львові для весіль, банкетів і фуршетів. Ціна 25 ₴ за добу, мінімальне замовлення 1 шт. Миття входить у вартість, доставка по Львову й області.</p>' WHERE `product_id`=1001 AND `language_id`=2 AND (`description`='' OR `description` IS NULL);
UPDATE `{{PREFIX}}product_description` SET `meta_title`='Тарілка столова Ø 24 см. — оренда у Львові, 14 ₴/доба | Крістал',`meta_description`='Тарілка столова Ø 24 см. в оренду у Львові: 14 ₴ за добу, мінімум 1 шт. Доставка й вивезення, знижки за обсяг. Замовляйте у «Крістал».' WHERE `product_id`=1003 AND `language_id`=2;
UPDATE `{{PREFIX}}product_description` SET `description`='<p>Тарілка столова Ø 24 см. — в оренду у Львові для весіль, банкетів і фуршетів. Ціна 14 ₴ за добу, мінімальне замовлення 1 шт. Миття входить у вартість, доставка по Львову й області.</p>' WHERE `product_id`=1003 AND `language_id`=2 AND (`description`='' OR `description` IS NULL);
UPDATE `{{PREFIX}}product_description` SET `meta_title`='Тарілка столова Ø 24 см. — оренда у Львові, 14 ₴/доба | Крістал',`meta_description`='Тарілка столова Ø 24 см. в оренду у Львові: 14 ₴ за добу, мінімум 1 шт. Доставка й вивезення, знижки за обсяг. Замовляйте у «Крістал».' WHERE `product_id`=1004 AND `language_id`=2;
UPDATE `{{PREFIX}}product_description` SET `description`='<p>Тарілка столова Ø 24 см. — в оренду у Львові для весіль, банкетів і фуршетів. Ціна 14 ₴ за добу, мінімальне замовлення 1 шт. Миття входить у вартість, доставка по Львову й області.</p>' WHERE `product_id`=1004 AND `language_id`=2 AND (`description`='' OR `description` IS NULL);
UPDATE `{{PREFIX}}product_description` SET `meta_title`='Жаровня 27,5 *15 * 6 см — оренда у Львові, 35 ₴/доба | Крістал',`meta_description`='Жаровня 27,5 *15 * 6 см в оренду у Львові: 35 ₴ за добу, мінімум 1 шт. Доставка й вивезення, знижки за обсяг. Замовляйте у «Крістал».' WHERE `product_id`=1012 AND `language_id`=2;
UPDATE `{{PREFIX}}product_description` SET `description`='<p>Жаровня 27,5 *15 * 6 см — в оренду у Львові для весіль, банкетів і фуршетів. Ціна 35 ₴ за добу, мінімальне замовлення 1 шт. Миття входить у вартість, доставка по Львову й області.</p>' WHERE `product_id`=1012 AND `language_id`=2 AND (`description`='' OR `description` IS NULL);
UPDATE `{{PREFIX}}product_description` SET `meta_title`='Тарілка столова Ø 24 см. — оренда у Львові, 14 ₴/доба | Крістал',`meta_description`='Тарілка столова Ø 24 см. в оренду у Львові: 14 ₴ за добу, мінімум 1 шт. Доставка й вивезення, знижки за обсяг. Замовляйте у «Крістал».' WHERE `product_id`=1013 AND `language_id`=2;
UPDATE `{{PREFIX}}product_description` SET `description`='<p>Тарілка столова Ø 24 см. — в оренду у Львові для весіль, банкетів і фуршетів. Ціна 14 ₴ за добу, мінімальне замовлення 1 шт. Миття входить у вартість, доставка по Львову й області.</p>' WHERE `product_id`=1013 AND `language_id`=2 AND (`description`='' OR `description` IS NULL);
UPDATE `{{PREFIX}}product_description` SET `meta_title`='Тарілка Ø 19,5 см — оренда у Львові, 12 ₴/доба | Крістал',`meta_description`='Тарілка Ø 19,5 см в оренду у Львові: 12 ₴ за добу, мінімум 1 шт. Доставка й вивезення, знижки за обсяг. Замовляйте у «Крістал».' WHERE `product_id`=1027 AND `language_id`=2;
UPDATE `{{PREFIX}}product_description` SET `description`='<p>Тарілка Ø 19,5 см — в оренду у Львові для весіль, банкетів і фуршетів. Ціна 12 ₴ за добу, мінімальне замовлення 1 шт. Миття входить у вартість, доставка по Львову й області.</p>' WHERE `product_id`=1027 AND `language_id`=2 AND (`description`='' OR `description` IS NULL);
UPDATE `{{PREFIX}}product_description` SET `meta_title`='Супниця Ø 22 см. 300 мл. — оренда у Львові, 18 ₴/доба | Крістал',`meta_description`='Супниця Ø 22 см. 300 мл. в оренду у Львові: 18 ₴ за добу, мінімум 1 шт. Доставка й вивезення, знижки за обсяг. Замовляйте у «Крістал».' WHERE `product_id`=1002 AND `language_id`=2;
UPDATE `{{PREFIX}}product_description` SET `description`='<p>Супниця Ø 22 см. 300 мл. — в оренду у Львові для весіль, банкетів і фуршетів. Ціна 18 ₴ за добу, мінімальне замовлення 1 шт. Миття входить у вартість, доставка по Львову й області.</p>' WHERE `product_id`=1002 AND `language_id`=2 AND (`description`='' OR `description` IS NULL);
UPDATE `{{PREFIX}}product_description` SET `meta_title`='Супниця Ø 12 см. 300 мл. — оренда у Львові, 12 ₴/доба | Крістал',`meta_description`='Супниця Ø 12 см. 300 мл. в оренду у Львові: 12 ₴ за добу, мінімум 1 шт. Доставка й вивезення, знижки за обсяг. Замовляйте у «Крістал».' WHERE `product_id`=1005 AND `language_id`=2;
UPDATE `{{PREFIX}}product_description` SET `description`='<p>Супниця Ø 12 см. 300 мл. — в оренду у Львові для весіль, банкетів і фуршетів. Ціна 12 ₴ за добу, мінімальне замовлення 1 шт. Миття входить у вартість, доставка по Львову й області.</p>' WHERE `product_id`=1005 AND `language_id`=2 AND (`description`='' OR `description` IS NULL);
UPDATE `{{PREFIX}}product_description` SET `meta_title`='Супниця Ø 10 см. 240 мл. — оренда у Львові, 10 ₴/доба | Крістал',`meta_description`='Супниця Ø 10 см. 240 мл. в оренду у Львові: 10 ₴ за добу, мінімум 1 шт. Доставка й вивезення, знижки за обсяг. Замовляйте у «Крістал».' WHERE `product_id`=1006 AND `language_id`=2;
UPDATE `{{PREFIX}}product_description` SET `description`='<p>Супниця Ø 10 см. 240 мл. — в оренду у Львові для весіль, банкетів і фуршетів. Ціна 10 ₴ за добу, мінімальне замовлення 1 шт. Миття входить у вартість, доставка по Львову й області.</p>' WHERE `product_id`=1006 AND `language_id`=2 AND (`description`='' OR `description` IS NULL);
UPDATE `{{PREFIX}}product_description` SET `meta_title`='Супниця Ø 22 см. 300 мл. — оренда у Львові, 18 ₴/доба | Крістал',`meta_description`='Супниця Ø 22 см. 300 мл. в оренду у Львові: 18 ₴ за добу, мінімум 1 шт. Доставка й вивезення, знижки за обсяг. Замовляйте у «Крістал».' WHERE `product_id`=1011 AND `language_id`=2;
UPDATE `{{PREFIX}}product_description` SET `description`='<p>Супниця Ø 22 см. 300 мл. — в оренду у Львові для весіль, банкетів і фуршетів. Ціна 18 ₴ за добу, мінімальне замовлення 1 шт. Миття входить у вартість, доставка по Львову й області.</p>' WHERE `product_id`=1011 AND `language_id`=2 AND (`description`='' OR `description` IS NULL);
UPDATE `{{PREFIX}}product_description` SET `meta_title`='Супниця Ø 20 см. 450 мл.? — оренда у Львові, 18 ₴/доба | Крістал',`meta_description`='Супниця Ø 20 см. 450 мл.? в оренду у Львові: 18 ₴ за добу, мінімум 1 шт. Доставка й вивезення, знижки за обсяг. Замовляйте у «Крістал».' WHERE `product_id`=1028 AND `language_id`=2;
UPDATE `{{PREFIX}}product_description` SET `description`='<p>Супниця Ø 20 см. 450 мл.? — в оренду у Львові для весіль, банкетів і фуршетів. Ціна 18 ₴ за добу, мінімальне замовлення 1 шт. Миття входить у вартість, доставка по Львову й області.</p>' WHERE `product_id`=1028 AND `language_id`=2 AND (`description`='' OR `description` IS NULL);
UPDATE `{{PREFIX}}product_description` SET `meta_title`='Супниця Ø 12 см. 300 мл. — оренда у Львові, 12 ₴/доба | Крістал',`meta_description`='Супниця Ø 12 см. 300 мл. в оренду у Львові: 12 ₴ за добу, мінімум 1 шт. Доставка й вивезення, знижки за обсяг. Замовляйте у «Крістал».' WHERE `product_id`=1035 AND `language_id`=2;
UPDATE `{{PREFIX}}product_description` SET `description`='<p>Супниця Ø 12 см. 300 мл. — в оренду у Львові для весіль, банкетів і фуршетів. Ціна 12 ₴ за добу, мінімальне замовлення 1 шт. Миття входить у вартість, доставка по Львову й області.</p>' WHERE `product_id`=1035 AND `language_id`=2 AND (`description`='' OR `description` IS NULL);
UPDATE `{{PREFIX}}product_description` SET `meta_title`='Салатниця Ø 14 см. 230 грам. — оренда у Львові | Крістал',`meta_description`='Салатниця Ø 14 см. 230 грам. в оренду у Львові: 12 ₴ за добу, мінімум 1 шт. Доставка й вивезення, знижки за обсяг. Замовляйте у «Крістал».' WHERE `product_id`=1007 AND `language_id`=2;
UPDATE `{{PREFIX}}product_description` SET `description`='<p>Салатниця Ø 14 см. 230 грам. — в оренду у Львові для весіль, банкетів і фуршетів. Ціна 12 ₴ за добу, мінімальне замовлення 1 шт. Миття входить у вартість, доставка по Львову й області.</p>' WHERE `product_id`=1007 AND `language_id`=2 AND (`description`='' OR `description` IS NULL);
UPDATE `{{PREFIX}}product_description` SET `meta_title`='Салатниця Ø 12 см. 160 грам. — оренда у Львові | Крістал',`meta_description`='Салатниця Ø 12 см. 160 грам. в оренду у Львові: 10 ₴ за добу, мінімум 1 шт. Доставка й вивезення, знижки за обсяг. Замовляйте у «Крістал».' WHERE `product_id`=1008 AND `language_id`=2;
UPDATE `{{PREFIX}}product_description` SET `description`='<p>Салатниця Ø 12 см. 160 грам. — в оренду у Львові для весіль, банкетів і фуршетів. Ціна 10 ₴ за добу, мінімальне замовлення 1 шт. Миття входить у вартість, доставка по Львову й області.</p>' WHERE `product_id`=1008 AND `language_id`=2 AND (`description`='' OR `description` IS NULL);
UPDATE `{{PREFIX}}product_description` SET `meta_title`='Салатниця Ø 12 см. 180 грам. — оренда у Львові | Крістал',`meta_description`='Салатниця Ø 12 см. 180 грам. в оренду у Львові: 11 ₴ за добу, мінімум 1 шт. Доставка й вивезення, знижки за обсяг. Замовляйте у «Крістал».' WHERE `product_id`=1009 AND `language_id`=2;
UPDATE `{{PREFIX}}product_description` SET `description`='<p>Салатниця Ø 12 см. 180 грам. — в оренду у Львові для весіль, банкетів і фуршетів. Ціна 11 ₴ за добу, мінімальне замовлення 1 шт. Миття входить у вартість, доставка по Львову й області.</p>' WHERE `product_id`=1009 AND `language_id`=2 AND (`description`='' OR `description` IS NULL);
UPDATE `{{PREFIX}}product_description` SET `meta_title`='Салатниця Ø 12 см. 150 грам. — оренда у Львові | Крістал',`meta_description`='Салатниця Ø 12 см. 150 грам. в оренду у Львові: 9 ₴ за добу, мінімум 1 шт. Доставка й вивезення, знижки за обсяг. Замовляйте у «Крістал».' WHERE `product_id`=1010 AND `language_id`=2;
UPDATE `{{PREFIX}}product_description` SET `description`='<p>Салатниця Ø 12 см. 150 грам. — в оренду у Львові для весіль, банкетів і фуршетів. Ціна 9 ₴ за добу, мінімальне замовлення 1 шт. Миття входить у вартість, доставка по Львову й області.</p>' WHERE `product_id`=1010 AND `language_id`=2 AND (`description`='' OR `description` IS NULL);
UPDATE `{{PREFIX}}product_description` SET `meta_title`='Салатниця Ø 20 см. 410 грам. — оренда у Львові | Крістал',`meta_description`='Салатниця Ø 20 см. 410 грам. в оренду у Львові: 16 ₴ за добу, мінімум 1 шт. Доставка й вивезення, знижки за обсяг. Замовляйте у «Крістал».' WHERE `product_id`=1029 AND `language_id`=2;
UPDATE `{{PREFIX}}product_description` SET `description`='<p>Салатниця Ø 20 см. 410 грам. — в оренду у Львові для весіль, банкетів і фуршетів. Ціна 16 ₴ за добу, мінімальне замовлення 1 шт. Миття входить у вартість, доставка по Львову й області.</p>' WHERE `product_id`=1029 AND `language_id`=2 AND (`description`='' OR `description` IS NULL);
UPDATE `{{PREFIX}}product_description` SET `meta_title`='Ніж столовий 1 — оренда у Львові, 12 ₴/доба | Крістал',`meta_description`='Ніж столовий 1 в оренду у Львові: 12 ₴ за добу, мінімум 1 шт. Доставка й вивезення, знижки за обсяг. Замовляйте у «Крістал».' WHERE `product_id`=1014 AND `language_id`=2;
UPDATE `{{PREFIX}}product_description` SET `description`='<p>Ніж столовий 1 — в оренду у Львові для весіль, банкетів і фуршетів. Ціна 12 ₴ за добу, мінімальне замовлення 1 шт. Миття входить у вартість, доставка по Львову й області.</p>' WHERE `product_id`=1014 AND `language_id`=2 AND (`description`='' OR `description` IS NULL);
UPDATE `{{PREFIX}}product_description` SET `meta_title`='Ніж столовий 2 — оренда у Львові, 12 ₴/доба | Крістал',`meta_description`='Ніж столовий 2 в оренду у Львові: 12 ₴ за добу, мінімум 1 шт. Доставка й вивезення, знижки за обсяг. Замовляйте у «Крістал».' WHERE `product_id`=1015 AND `language_id`=2;
UPDATE `{{PREFIX}}product_description` SET `description`='<p>Ніж столовий 2 — в оренду у Львові для весіль, банкетів і фуршетів. Ціна 12 ₴ за добу, мінімальне замовлення 1 шт. Миття входить у вартість, доставка по Львову й області.</p>' WHERE `product_id`=1015 AND `language_id`=2 AND (`description`='' OR `description` IS NULL);
UPDATE `{{PREFIX}}product_description` SET `meta_title`='Виделка столова 1 — оренда у Львові, 10 ₴/доба | Крістал',`meta_description`='Виделка столова 1 в оренду у Львові: 10 ₴ за добу, мінімум 1 шт. Доставка й вивезення, знижки за обсяг. Замовляйте у «Крістал».' WHERE `product_id`=1016 AND `language_id`=2;
UPDATE `{{PREFIX}}product_description` SET `description`='<p>Виделка столова 1 — в оренду у Львові для весіль, банкетів і фуршетів. Ціна 10 ₴ за добу, мінімальне замовлення 1 шт. Миття входить у вартість, доставка по Львову й області.</p>' WHERE `product_id`=1016 AND `language_id`=2 AND (`description`='' OR `description` IS NULL);
UPDATE `{{PREFIX}}product_description` SET `meta_title`='Виделка столова 2 — оренда у Львові, 10 ₴/доба | Крістал',`meta_description`='Виделка столова 2 в оренду у Львові: 10 ₴ за добу, мінімум 1 шт. Доставка й вивезення, знижки за обсяг. Замовляйте у «Крістал».' WHERE `product_id`=1017 AND `language_id`=2;
UPDATE `{{PREFIX}}product_description` SET `description`='<p>Виделка столова 2 — в оренду у Львові для весіль, банкетів і фуршетів. Ціна 10 ₴ за добу, мінімальне замовлення 1 шт. Миття входить у вартість, доставка по Львову й області.</p>' WHERE `product_id`=1017 AND `language_id`=2 AND (`description`='' OR `description` IS NULL);
UPDATE `{{PREFIX}}product_description` SET `meta_title`='Виделка десертна 1 — оренда у Львові, 8 ₴/доба | Крістал',`meta_description`='Виделка десертна 1 в оренду у Львові: 8 ₴ за добу, мінімум 1 шт. Доставка й вивезення, знижки за обсяг. Замовляйте у «Крістал».' WHERE `product_id`=1020 AND `language_id`=2;
UPDATE `{{PREFIX}}product_description` SET `description`='<p>Виделка десертна 1 — в оренду у Львові для весіль, банкетів і фуршетів. Ціна 8 ₴ за добу, мінімальне замовлення 1 шт. Миття входить у вартість, доставка по Львову й області.</p>' WHERE `product_id`=1020 AND `language_id`=2 AND (`description`='' OR `description` IS NULL);
UPDATE `{{PREFIX}}product_description` SET `meta_title`='Виделка рибна 1 — оренда у Львові, 9 ₴/доба | Крістал',`meta_description`='Виделка рибна 1 в оренду у Львові: 9 ₴ за добу, мінімум 1 шт. Доставка й вивезення, знижки за обсяг. Замовляйте у «Крістал».' WHERE `product_id`=1021 AND `language_id`=2;
UPDATE `{{PREFIX}}product_description` SET `description`='<p>Виделка рибна 1 — в оренду у Львові для весіль, банкетів і фуршетів. Ціна 9 ₴ за добу, мінімальне замовлення 1 шт. Миття входить у вартість, доставка по Львову й області.</p>' WHERE `product_id`=1021 AND `language_id`=2 AND (`description`='' OR `description` IS NULL);
UPDATE `{{PREFIX}}product_description` SET `meta_title`='Виделка столова 3 — оренда у Львові, 10 ₴/доба | Крістал',`meta_description`='Виделка столова 3 в оренду у Львові: 10 ₴ за добу, мінімум 1 шт. Доставка й вивезення, знижки за обсяг. Замовляйте у «Крістал».' WHERE `product_id`=1023 AND `language_id`=2;
UPDATE `{{PREFIX}}product_description` SET `description`='<p>Виделка столова 3 — в оренду у Львові для весіль, банкетів і фуршетів. Ціна 10 ₴ за добу, мінімальне замовлення 1 шт. Миття входить у вартість, доставка по Львову й області.</p>' WHERE `product_id`=1023 AND `language_id`=2 AND (`description`='' OR `description` IS NULL);
UPDATE `{{PREFIX}}product_description` SET `meta_title`='Веделка столова — оренда у Львові, 20 ₴/доба | Крістал',`meta_description`='Веделка столова в оренду у Львові: 20 ₴ за добу, мінімум 1 шт. Доставка й вивезення, знижки за обсяг. Замовляйте у «Крістал».' WHERE `product_id`=994 AND `language_id`=2;
UPDATE `{{PREFIX}}product_description` SET `description`='<p>Веделка столова — в оренду у Львові для весіль, банкетів і фуршетів. Ціна 20 ₴ за добу, мінімальне замовлення 1 шт. Миття входить у вартість, доставка по Львову й області.</p>' WHERE `product_id`=994 AND `language_id`=2 AND (`description`='' OR `description` IS NULL);
UPDATE `{{PREFIX}}product_description` SET `meta_title`='Ложка до Латте — оренда у Львові, 6 ₴/доба | Крістал',`meta_description`='Ложка до Латте в оренду у Львові: 6 ₴ за добу, мінімум 1 шт. Доставка й вивезення, знижки за обсяг. Замовляйте у «Крістал».' WHERE `product_id`=1022 AND `language_id`=2;
UPDATE `{{PREFIX}}product_description` SET `description`='<p>Ложка до Латте — в оренду у Львові для весіль, банкетів і фуршетів. Ціна 6 ₴ за добу, мінімальне замовлення 1 шт. Миття входить у вартість, доставка по Львову й області.</p>' WHERE `product_id`=1022 AND `language_id`=2 AND (`description`='' OR `description` IS NULL);
UPDATE `{{PREFIX}}product_description` SET `meta_title`='Ложка кавова — оренда у Львові, 5 ₴/доба | Крістал',`meta_description`='Ложка кавова в оренду у Львові: 5 ₴ за добу, мінімум 1 шт. Доставка й вивезення, знижки за обсяг. Замовляйте у «Крістал».' WHERE `product_id`=1024 AND `language_id`=2;
UPDATE `{{PREFIX}}product_description` SET `description`='<p>Ложка кавова — в оренду у Львові для весіль, банкетів і фуршетів. Ціна 5 ₴ за добу, мінімальне замовлення 1 шт. Миття входить у вартість, доставка по Львову й області.</p>' WHERE `product_id`=1024 AND `language_id`=2 AND (`description`='' OR `description` IS NULL);
UPDATE `{{PREFIX}}product_description` SET `meta_title`='Склянна пляшка — оренда у Львові, 150 ₴/доба | Крістал',`meta_description`='Склянна пляшка в оренду у Львові: 150 ₴ за добу, мінімум 1 шт. Доставка й вивезення, знижки за обсяг. Замовляйте у «Крістал».' WHERE `product_id`=1025 AND `language_id`=2;
UPDATE `{{PREFIX}}product_description` SET `description`='<p>Склянна пляшка — в оренду у Львові для весіль, банкетів і фуршетів. Ціна 150 ₴ за добу, мінімальне замовлення 1 шт. Миття входить у вартість, доставка по Львову й області.</p>' WHERE `product_id`=1025 AND `language_id`=2 AND (`description`='' OR `description` IS NULL);
UPDATE `{{PREFIX}}product_description` SET `meta_title`='Блюдце металеве — оренда у Львові, 120 ₴/доба | Крістал',`meta_description`='Блюдце металеве в оренду у Львові: 120 ₴ за добу, мінімум 1 шт. Доставка й вивезення, знижки за обсяг. Замовляйте у «Крістал».' WHERE `product_id`=1026 AND `language_id`=2;
UPDATE `{{PREFIX}}product_description` SET `description`='<p>Блюдце металеве — в оренду у Львові для весіль, банкетів і фуршетів. Ціна 120 ₴ за добу, мінімальне замовлення 1 шт. Миття входить у вартість, доставка по Львову й області.</p>' WHERE `product_id`=1026 AND `language_id`=2 AND (`description`='' OR `description` IS NULL);
UPDATE `{{PREFIX}}product_description` SET `meta_title`='Склянка 355 мл — оренда у Львові, 9 ₴/доба | Крістал',`meta_description`='Склянка 355 мл в оренду у Львові: 9 ₴ за добу, мінімум 1 шт. Доставка й вивезення, знижки за обсяг. Замовляйте у «Крістал».' WHERE `product_id`=1033 AND `language_id`=2;
UPDATE `{{PREFIX}}product_description` SET `description`='<p>Склянка 355 мл — в оренду у Львові для весіль, банкетів і фуршетів. Ціна 9 ₴ за добу, мінімальне замовлення 1 шт. Миття входить у вартість, доставка по Львову й області.</p>' WHERE `product_id`=1033 AND `language_id`=2 AND (`description`='' OR `description` IS NULL);
UPDATE `{{PREFIX}}product_description` SET `meta_title`='Склянка 475 мл — оренда у Львові, 9 ₴/доба | Крістал',`meta_description`='Склянка 475 мл в оренду у Львові: 9 ₴ за добу, мінімум 1 шт. Доставка й вивезення, знижки за обсяг. Замовляйте у «Крістал».' WHERE `product_id`=1034 AND `language_id`=2;
UPDATE `{{PREFIX}}product_description` SET `description`='<p>Склянка 475 мл — в оренду у Львові для весіль, банкетів і фуршетів. Ціна 9 ₴ за добу, мінімальне замовлення 1 шт. Миття входить у вартість, доставка по Львову й області.</p>' WHERE `product_id`=1034 AND `language_id`=2 AND (`description`='' OR `description` IS NULL);
UPDATE `{{PREFIX}}product_description` SET `meta_title`='Блюдо пластмасове 36*17 — оренда у Львові, 18 ₴/доба | Крістал',`meta_description`='Блюдо пластмасове 36*17 в оренду у Львові: 18 ₴ за добу, мінімум 1 шт. Доставка й вивезення, знижки за обсяг. Замовляйте у «Крістал».' WHERE `product_id`=1037 AND `language_id`=2;
UPDATE `{{PREFIX}}product_description` SET `description`='<p>Блюдо пластмасове 36*17 — в оренду у Львові для весіль, банкетів і фуршетів. Ціна 18 ₴ за добу, мінімальне замовлення 1 шт. Миття входить у вартість, доставка по Львову й області.</p>' WHERE `product_id`=1037 AND `language_id`=2 AND (`description`='' OR `description` IS NULL);
UPDATE `{{PREFIX}}product_description` SET `meta_title`='Блюдо пластмасове 36*17 — оренда у Львові, 18 ₴/доба | Крістал',`meta_description`='Блюдо пластмасове 36*17 в оренду у Львові: 18 ₴ за добу, мінімум 1 шт. Доставка й вивезення, знижки за обсяг. Замовляйте у «Крістал».' WHERE `product_id`=1038 AND `language_id`=2;
UPDATE `{{PREFIX}}product_description` SET `description`='<p>Блюдо пластмасове 36*17 — в оренду у Львові для весіль, банкетів і фуршетів. Ціна 18 ₴ за добу, мінімальне замовлення 1 шт. Миття входить у вартість, доставка по Львову й області.</p>' WHERE `product_id`=1038 AND `language_id`=2 AND (`description`='' OR `description` IS NULL);



DELETE FROM `{{PREFIX}}product_filter` WHERE `product_id` BETWEEN 989 AND 1039;
DELETE FROM `{{PREFIX}}filter_description` WHERE `filter_id` BETWEEN 101 AND 105 OR `filter_id` BETWEEN 201 AND 204;
DELETE FROM `{{PREFIX}}filter` WHERE `filter_id` BETWEEN 101 AND 105 OR `filter_id` BETWEEN 201 AND 204;
DELETE FROM `{{PREFIX}}filter_group_description` WHERE `filter_group_id` IN (1,2);
DELETE FROM `{{PREFIX}}filter_group` WHERE `filter_group_id` IN (1,2);

INSERT INTO `{{PREFIX}}filter_group` (`filter_group_id`,`sort_order`) VALUES (1,1),(2,2);
INSERT INTO `{{PREFIX}}filter_group_description` (`filter_group_id`,`language_id`,`name`) VALUES
(1,2,'Матеріал'),(2,2,'Колір');

INSERT INTO `{{PREFIX}}filter` (`filter_id`,`filter_group_id`,`sort_order`) VALUES
(101,1,1),(102,1,2),(103,1,3),(104,1,4),(105,1,5),
(201,2,1),(202,2,2),(203,2,3),(204,2,4);
INSERT INTO `{{PREFIX}}filter_description` (`filter_id`,`language_id`,`filter_group_id`,`name`) VALUES
(101,2,1,'Порцеляна'),(102,2,1,'Нержавіюча сталь'),(103,2,1,'Скло'),(104,2,1,'Дерево'),(105,2,1,'Пластик'),
(201,2,2,'Білий'),(202,2,2,'Прозорий'),(203,2,2,'Металевий'),(204,2,2,'Дерев’яний');

-- Порцеляна (біла)
INSERT INTO `{{PREFIX}}product_filter` (`product_id`,`filter_id`) VALUES
(1001,101),(1001,201),(1003,101),(1003,201),(1004,101),(1004,201),(1012,101),(1012,201),(1013,101),(1013,201),(1027,101),(1027,201),
(1002,101),(1002,201),(1005,101),(1005,201),(1006,101),(1006,201),(1011,101),(1011,201),(1028,101),(1028,201),(1035,101),(1035,201),
(1007,101),(1007,201),(1008,101),(1008,201),(1009,101),(1009,201),(1010,101),(1010,201),(1029,101),(1029,201),
(1000,101),(1000,201),(1030,101),(1030,201);

-- Нержавіюча сталь / метал
INSERT INTO `{{PREFIX}}product_filter` (`product_id`,`filter_id`) VALUES
(1014,102),(1014,203),(1015,102),(1015,203),
(1016,102),(1016,203),(1017,102),(1017,203),(1020,102),(1020,203),(1021,102),(1021,203),(1023,102),(1023,203),(994,102),(994,203),
(1022,102),(1022,203),(1024,102),(1024,203),
(997,102),(997,203),(998,102),(998,203),(999,102),(999,203),
(1026,102),(1026,203),
(995,102),(995,203),(996,102),(996,203),(1031,102),(1031,203);

-- Скло
INSERT INTO `{{PREFIX}}product_filter` (`product_id`,`filter_id`) VALUES
(1033,103),(1033,202),(1034,103),(1034,202),(1025,103),(1025,202);

-- Дерево
INSERT INTO `{{PREFIX}}product_filter` (`product_id`,`filter_id`) VALUES
(989,104),(989,204),(990,104),(990,204),(991,104),(991,204),(992,104),(992,204),(993,104),(993,204),
(1032,104),(1032,204),(1036,104),(1036,204),(1039,104),(1039,204);

-- Пластик
INSERT INTO `{{PREFIX}}product_filter` (`product_id`,`filter_id`) VALUES
(1037,105),(1037,201),(1038,105),(1038,201);


DELETE FROM `{{PREFIX}}seo_url` WHERE `store_id`=0 AND `query` IN ('product_id=1004','product_id=1011','product_id=1013','product_id=1023','product_id=1024','product_id=1035','product_id=1038');

INSERT INTO `{{PREFIX}}seo_url` (`store_id`,`language_id`,`query`,`keyword`) VALUES
(0,2,'product_id=1004','tarilka-stolova-d-24-sm'),
(0,2,'product_id=1011','supnytsia-d-22-sm-300-ml'),
(0,2,'product_id=1013','tarilka-stolova-d-24-sm-2'),
(0,2,'product_id=1023','vydelka-stolova-3'),
(0,2,'product_id=1024','lozhka-kavova'),
(0,2,'product_id=1035','supnytsia-d-12-sm-300-ml'),
(0,2,'product_id=1038','bliudo-plastmasove-36x17');


DELETE FROM `{{PREFIX}}setting` WHERE `store_id`=0 AND `code`='module_kristal_core';
INSERT INTO `{{PREFIX}}setting` (`store_id`,`code`,`key`,`value`,`serialized`) VALUES
(0,'module_kristal_core','module_kristal_core_status','1',0),
(0,'module_kristal_core','module_kristal_core_name','Крістал',0),
(0,'module_kristal_core','module_kristal_core_legal_name','Крістал',0),
(0,'module_kristal_core','module_kristal_core_address','вул. Богдана Хмельницького, 106',0),
(0,'module_kristal_core','module_kristal_core_city','Львів',0),
(0,'module_kristal_core','module_kristal_core_postcode','79000',0),
(0,'module_kristal_core','module_kristal_core_email','orendaposydy@gmail.com',0),
(0,'module_kristal_core','module_kristal_core_geo_lat','',0),
(0,'module_kristal_core','module_kristal_core_geo_lng','',0),
(0,'module_kristal_core','module_kristal_core_hours_note','Пн–Нд 09:00–18:00',0),
(0,'module_kristal_core','module_kristal_core_phones','[{"number":"+380678277007","label":"Оренда посуду","viber":1,"telegram":0,"whatsapp":0}]',0),
(0,'module_kristal_core','module_kristal_core_hours','[{"days":["Mo","Tu","We","Th","Fr","Sa","Su"],"from":"09:00","to":"18:00"}]',0),
(0,'module_kristal_core','module_kristal_core_telegram_username','',0),
(0,'module_kristal_core','module_kristal_core_instagram','',0),
(0,'module_kristal_core','module_kristal_core_facebook','',0),
(0,'module_kristal_core','module_kristal_core_tiktok','',0),
(0,'module_kristal_core','module_kristal_core_youtube','',0);

DELETE FROM `{{PREFIX}}setting` WHERE `store_id`=0 AND `code`='module_kristal_home';
INSERT INTO `{{PREFIX}}setting` (`store_id`,`code`,`key`,`value`,`serialized`) VALUES
(0,'module_kristal_home','module_kristal_home_status','1',0),
(0,'module_kristal_home','module_kristal_home_h1','Оренда посуду, меблів і обладнання для подій у Львові',0),
(0,'module_kristal_home','module_kristal_home_lead','Посуд, скло, меблі, текстиль, шатри й кухонне обладнання для весіль, банкетів, фуршетів і кейтерингу. Ціни за добу на сайті, доставка й вивезення, миття входить у вартість.',0),
(0,'module_kristal_home','module_kristal_home_meta_title','Оренда посуду у Львові — від 10 ₴/доба | Крістал',0),
(0,'module_kristal_home','module_kristal_home_meta_description','Оренда посуду, меблів, текстилю й обладнання для подій у Львові. Ціни за добу на сайті, доставка й вивезення. Розрахуємо замовлення за 15 хвилин.',0),
(0,'module_kristal_home','module_kristal_home_hero_image','',0),
(0,'module_kristal_home','module_kristal_home_numbers','[{"value":"з 2013","label":"працюємо у Львові"},{"value":"5000+","label":"позицій на складі"},{"value":"600+","label":"подій на рік"}]',0),
(0,'module_kristal_home','module_kristal_home_faq','[{"q":"Чи треба мити посуд після події?","a":"Ні. Миття входить у вартість оренди — повертайте посуд без миття."},{"q":"Скільки берете за доставку?","a":"Доставка по Львову й області залежить від адреси та кількості позицій. Точну суму назвемо після розрахунку замовлення."},{"q":"Коли краще бронювати?","a":"На весільний сезон — за 1–2 місяці. У Viber, Telegram або телефоном підтвердимо наявність на вашу дату."},{"q":"Що входить у вартість оренди?","a":"Оренда на добу, миття та перевірка позицій. Заставу й вартість відшкодування за бій уточнюйте при бронюванні."},{"q":"Чи можна замовити комплект під меню?","a":"Так. Надішліть меню або кількість гостей — підберемо посуд, прибори та скло під страви й формат подачі."},{"q":"Як працює кошик події?","a":"Додайте позиції з датою і кількістю гостей, а ми підтвердимо наявність і надішлемо кошторис. Оплата — передоплата 50%."}]',0),
(0,'module_kristal_home','module_kristal_home_seo_text','<h2>Оренда посуду у Львові — «Крістал»</h2><p>Здаємо в оренду посуд, столові прибори, скло, текстиль, меблі та обладнання для подій у Львові й області. Працюємо з весіллями, банкетами, фуршетами, корпоративами та кейтерингом: допомагаємо підібрати комплект під меню, кількість гостей і бюджет.</p><p>Ціни вказані за добу за одну позицію. Для великих замовлень діють знижки за обсяг, а миття входить у вартість оренди. Доставляємо на місце події або видаємо зі складу на вул. Богдана Хмельницького, 106.</p><p>Не знаєте, скільки посуду потрібно? Напишіть у Viber або залиште заявку — менеджер порахує комплект і підтвердить наявність на вашу дату.</p>',0);

UPDATE `{{PREFIX}}setting` SET `value`='{name} — оренда у Львові, {price} ₴/доба | Крістал' WHERE `key`='module_kristal_seo_product_title' AND `value`='';
UPDATE `{{PREFIX}}setting` SET `value`='{name} в оренду у Львові: {price} ₴ за добу. Доставка й вивезення, знижки за обсяг.' WHERE `key`='module_kristal_seo_product_description' AND `value`='';


-- ---------------------------------------------------------------------------
-- 301 зі старих адрес категорій, яких немає в початковому наборі 0021.
-- Потрібні після зміни ЧПУ категорій вище (старі URL інакше віддадуть 404).
-- ---------------------------------------------------------------------------
INSERT IGNORE INTO `{{PREFIX}}kristal_redirect` (`old_path`,`new_path`,`code`,`status`) VALUES
('/orenda-kavovih-aparativ-kavovarok-termopotiv-elektrochajnikiv-prizhimnih-griliv','/kavove-obladnannia',301,1),
('/orenda-dekoru','/dekor',301,1),
('/orenda-prokat-ekoposudu-ta-inventarya/derev-yani-doshki','/ekoposud/dereviani-doshky',301,1),
('/orenda-prokat-ekoposudu-ta-inventarya/inventar-ta-posud-z-plastiku','/ekoposud/inventar-z-plastyku',301,1),
('/salati/ditichnij-kompleksu','/sklo-ta-kelykhy',301,1),
('/salati/stakani','/sklo-ta-kelykhy/sklianky',301,1);

-- ---------------------------------------------------------------------------
-- Службове: статус модуля фільтрів увімкнено (щоб адмінка показувала модуль)
-- ---------------------------------------------------------------------------
INSERT INTO `{{PREFIX}}setting` (`store_id`,`code`,`key`,`value`,`serialized`)
SELECT 0,'module_kristal_filter','module_kristal_filter_status','1',0
 WHERE NOT EXISTS (SELECT 1 FROM `{{PREFIX}}setting` WHERE `store_id`=0 AND `code`='module_kristal_filter' AND `key`='module_kristal_filter_status');

-- ---------------------------------------------------------------------------
-- Перевірка після запуску (phpMyAdmin покаже результат):
--   11 верхніх категорій, 33 увімкнені, 45 цін, 9 хітів.
-- ---------------------------------------------------------------------------
SELECT 'верхніх категорій' AS metric, COUNT(*) AS n FROM `{{PREFIX}}category` WHERE status=1 AND parent_id=0
UNION ALL SELECT 'увімкнених категорій', COUNT(*) FROM `{{PREFIX}}category` WHERE status=1
UNION ALL SELECT 'товарів з ціною', COUNT(*) FROM `{{PREFIX}}product` WHERE status=1 AND price>0
UNION ALL SELECT 'хітів', COUNT(*) FROM `{{PREFIX}}kristal_product_rental` WHERE is_hit=1
UNION ALL SELECT 'категорій з meta title', COUNT(*) FROM `{{PREFIX}}category_description` WHERE language_id=2 AND meta_title<>''
UNION ALL SELECT 'товарів з meta title', COUNT(*) FROM `{{PREFIX}}product_description` WHERE language_id=2 AND meta_title<>''
UNION ALL SELECT 'фільтрів-значень', COUNT(*) FROM `{{PREFIX}}product_filter`;
