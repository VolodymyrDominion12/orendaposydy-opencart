-- 0026_kristal_blog.up.sql
-- Фіча 013: Блог та експертні статті для наречених та організаторів (kristal_blog)

CREATE TABLE IF NOT EXISTS `oc_kristal_blog_category` (
  `category_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `status` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`category_id`),
  UNIQUE KEY `uq_slug` (`slug`),
  KEY `idx_status_sort` (`status`, `sort_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `oc_kristal_blog_post` (
  `post_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `summary` varchar(500) NOT NULL DEFAULT '',
  `content` mediumtext NOT NULL,
  `image` varchar(255) NOT NULL DEFAULT '',
  `author` varchar(128) NOT NULL DEFAULT 'Команда «Крістал»',
  `viewed` int(11) NOT NULL DEFAULT 0,
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `status` tinyint(1) NOT NULL DEFAULT 1,
  `date_added` datetime NOT NULL,
  `date_modified` datetime NOT NULL,
  PRIMARY KEY (`post_id`),
  UNIQUE KEY `uq_slug` (`slug`),
  KEY `idx_status_date` (`status`, `date_added`),
  KEY `idx_sort_order` (`sort_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `oc_kristal_blog_post_to_category` (
  `post_id` int(11) unsigned NOT NULL,
  `category_id` int(11) unsigned NOT NULL,
  PRIMARY KEY (`post_id`, `category_id`),
  KEY `idx_category_id` (`category_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `oc_kristal_blog_post_related_product` (
  `post_id` int(11) unsigned NOT NULL,
  `product_id` int(11) unsigned NOT NULL,
  PRIMARY KEY (`post_id`, `product_id`),
  KEY `idx_product_id` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Рубрики блогу
INSERT INTO `oc_kristal_blog_category` (`category_id`, `title`, `slug`, `description`, `sort_order`, `status`) VALUES
(1, 'Поради щодо сервірування', 'porady-z-serviruvannya', 'Як поєднувати тарілки, келихи та прибори, підбір кольорової гами столу та текстилю.', 1, 1),
(2, 'Організація подій', 'orhanizatsiya-podii', 'Практичні поради з логістики, вибору локацій, планування фуршетів та банкетів.', 2, 1),
(3, 'Чек-листи та норми', 'chek-lysty-ta-normy', 'Готові таблиці розрахунку посуду на кількість гостей, норми келихів та приборів на людину.', 3, 1)
ON DUPLICATE KEY UPDATE `title` = VALUES(`title`);

-- Початкові експертні статті
INSERT INTO `oc_kristal_blog_post` (`post_id`, `title`, `slug`, `summary`, `content`, `image`, `author`, `sort_order`, `status`, `date_added`, `date_modified`) VALUES
(1, 'Як розрахувати кількість келихів на весілля: норми на гостя', 'yak-rozrakhuvaty-kelykhy-na-vesillya', 'Практичний посібник: скільки келихів для шампанського, червоного та білого вина, води потрібно на 50, 100 та 150 гостей з урахуванням запасу на бій.', '<h2>Норми розрахунку барного скла на весільний банкет</h2><p>Одне з найпоширеніших питань наречених та організаторів: «Скільки саме келихів потрібно замовляти в оренду, щоб гостям вистачило напоїв протягом усього свята, але не переплачувати за зайві позиції?»</p><h3>1. Welcome Drink (вітальний фуршет)</h3><p>На зону зустрічі гостей подаються переважно ігристі вина (просекко, шампанське) та безалкогольні освіжаючі напої (вода з цитрусовими, лимонади).<br><strong>Норма:</strong> 1,5 келиха-флюте або купе на кожного гостя + 1 склянка для води. На 100 гостей потрібно щонайменше 150 келихів для ігристого.</p><h3>2. Основний банкетний стіл</h3><p>Класичне банкетне сервірування передбачає наявність трьох позицій скла біля кожної персони:</p><ul><li><strong>Келих для води / безалкогольних напоїв (350–400 мл):</strong> 1 шт. на людину.</li><li><strong>Келих для білого вина (300–350 мл):</strong> 1 шт. на людину.</li><li><strong>Келих для червоного вина (400–450 мл):</strong> 1 шт. на людину.</li></ul><h3>3. Коефіцієнт запасу на бій та зміну напоїв</h3><p>На великих подіях келихи часто губляться на фотозонах, танцполі або б’ються. Професійний стандарт безпеки: <strong>+10–15%</strong> до загальної розрахункової кількості кожного виду келихів.</p><p>У сервісі «Крістал» усі келихи постачаються у спеціальних пластикових коміркових боксах, що гарантує їхню чистоту та цілісність під час доставки по Львову та області.</p>', 'catalog/demo/banners/blog-glasses.jpg', 'Ірина Гринів, експерт «Крістал»', 1, 1, '2026-11-01 10:00:00', '2026-11-05 12:00:00'),

(2, 'Чек-лист оренди посуду та інвентарю для виїзного кейтерингу', 'chek-lyst-orendy-posudu-dlya-keyterynhu', 'Повний перелік необхідного посуду для виїзного кейтерингу: від мармітів і підносів до порційних закусочних тарілок і соусників.', '<h2>Що потрібно врахувати кейтеринговій службі при оренді інвентарю</h2><p>Організація харчування на виїзній локації (у заміському комплексі, шатрі чи open-air галявині) потребує чіткого чек-листа, адже докупити чи довезти забуту тарілку під час заходу вже неможливо.</p><h3>Базовий чек-лист виїзного кейтерингу:</h3><ol><li><strong>Теплове та мармітне обладнання:</strong> марміти з пальниками для гарячих основних страв, підігрівачі супів.</li><li><strong>Фуршетна лінія подачі:</strong> триярусні етажерки для капкейків і канапе, дерев’яні дошки для сирів і м’ясних нарізок, соусники та порційні шоти.</li><li><strong>Столові прибори для подачі:</strong> щипці для салатів, роздаткові ложки, лопатки для тортів.</li><li><strong>Текстиль:</strong> водовідштовхувальні банкетні скатертини в підлогу, фуршетні спідниці, текстильні серветки.</li></ol><p><strong>Головна перевага оренди в «Крістал» для кейтерингів:</strong> ми приймаємо весь використаний посуд немитим у тих самих фірмових контейнерах, знімаючи з персоналу кухні питання миття в польових умовах.</p>', 'catalog/demo/banners/blog-catering.jpg', 'Тарас Василик, кейтеринг-шеф', 2, 1, '2026-11-03 11:30:00', '2026-11-06 09:15:00'),

(3, 'Тренди весільного сервірування 2026: золото, матовий чорний та натуральний льон', 'trendy-serviruvannya-2026-zoloto-i-matovyi-chorniy', 'Огляд актуальних стилів оформлення святкових столів: від мінімалізму з темним фарфором до урочистої неокласики з золотими акцентами.', '<h2>Естетика святкового столу: тренди нового весільного сезону</h2><p>Сучасне весільне сервірування давно вийшло за рамки стандартних білих тарілок. У 2026 році провідні декоратори та флористи Львова віддають перевагу багатошаровості, грі контрастних фактур та індивідуальному стилю.</p><h3>1. Золоті столові прибори серії Royal</h3><p>Матове або глянцеве золото у вилках, ножах та десертних ложках додає столу відчуття королівської урочистості. Вони ідеально поєднуються як з класичним білим фарфором, так і з пудровими, смарагдовими та теракотовими відтінками ранерів.</p><h3>2. Темний матовий посуд та кам’яна текстура</h3><p>Для весіль у стилі лофт, botanical або modern organic справжнім хітом стали чорні матові тарілки. Вони створюють приголомшливий візуальний контраст для кольорових ресторанних страв від шеф-кухаря.</p><h3>3. Підставні тарілки (charger plates)</h3><p>Підставна тарілка виконує декоративну функцію: вона залишається на столі до подачі гарячого, підтримуючи композиційну цілісність декору з квітами та свічками.</p>', 'catalog/demo/banners/blog-trends.jpg', 'Марта Ковальчук, декоратор', 3, 1, '2026-11-07 14:00:00', '2026-11-08 16:45:00')
ON DUPLICATE KEY UPDATE `title` = VALUES(`title`), `summary` = VALUES(`summary`);

-- Прив''язка статей до рубрик
INSERT IGNORE INTO `oc_kristal_blog_post_to_category` (`post_id`, `category_id`) VALUES
(1, 3),
(2, 2),
(3, 1);

-- Пов''язані товари до статей блогу
INSERT IGNORE INTO `oc_kristal_blog_post_related_product` (`post_id`, `product_id`) VALUES
(1, 50031), (1, 50032), (1, 50034), (1, 50035),
(2, 50002), (2, 50011), (2, 50014), (2, 50026),
(3, 50005), (3, 50016), (3, 50021), (3, 50029), (3, 50083);

-- SEO URLs для блогу та статей
INSERT INTO `oc_seo_url` (`store_id`, `language_id`, `query`, `keyword`) VALUES
(0, 2, 'extension/kristal/blog', 'blog'),
(0, 2, 'post_id=1', 'yak-rozrakhuvaty-kelykhy-na-vesillya'),
(0, 2, 'post_id=2', 'chek-lyst-orendy-posudu-dlya-keyterynhu'),
(0, 2, 'post_id=3', 'trendy-serviruvannya-2026-zoloto-i-matovyi-chorniy')
ON DUPLICATE KEY UPDATE `keyword` = VALUES(`keyword`);
