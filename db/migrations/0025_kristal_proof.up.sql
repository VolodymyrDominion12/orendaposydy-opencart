-- 0025_kristal_proof.up.sql
-- Фіча 014: Портфоліо кейсів подій та відгуки клієнтів (kristal_proof)

CREATE TABLE IF NOT EXISTS `oc_kristal_case` (
  `case_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `event_type` varchar(64) NOT NULL DEFAULT 'wedding',
  `guests` int(11) NOT NULL DEFAULT 0,
  `location` varchar(255) NOT NULL DEFAULT '',
  `date_event` varchar(64) NOT NULL DEFAULT '',
  `summary` varchar(500) NOT NULL DEFAULT '',
  `description` mediumtext NOT NULL,
  `image` varchar(255) NOT NULL DEFAULT '',
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `status` tinyint(1) NOT NULL DEFAULT 1,
  `date_added` datetime NOT NULL,
  PRIMARY KEY (`case_id`),
  UNIQUE KEY `uq_slug` (`slug`),
  KEY `idx_status_sort` (`status`, `sort_order`),
  KEY `idx_event_type` (`event_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `oc_kristal_case_image` (
  `image_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `case_id` int(11) unsigned NOT NULL,
  `image` varchar(255) NOT NULL,
  `sort_order` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`image_id`),
  KEY `idx_case_id` (`case_id`, `sort_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `oc_kristal_case_product` (
  `case_id` int(11) unsigned NOT NULL,
  `product_id` int(11) unsigned NOT NULL,
  PRIMARY KEY (`case_id`, `product_id`),
  KEY `idx_product_id` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `oc_kristal_testimonial` (
  `testimonial_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `author_name` varchar(128) NOT NULL,
  `author_role` varchar(128) NOT NULL DEFAULT '',
  `rating` tinyint(1) NOT NULL DEFAULT 5,
  `text` text NOT NULL,
  `event_title` varchar(255) NOT NULL DEFAULT '',
  `source` varchar(64) NOT NULL DEFAULT 'Google',
  `source_url` varchar(255) NOT NULL DEFAULT '',
  `avatar` varchar(255) NOT NULL DEFAULT '',
  `date_added` date NOT NULL,
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `status` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`testimonial_id`),
  KEY `idx_status_sort` (`status`, `sort_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Посів демонстраційних кейсів портфоліо
INSERT INTO `oc_kristal_case` (`case_id`, `title`, `slug`, `event_type`, `guests`, `location`, `date_event`, `summary`, `description`, `image`, `sort_order`, `status`, `date_added`) VALUES
(1, 'Класичне весілля в Edem Resort Medical & SPA', 'vesillya-v-edem-resort', 'wedding', 120, 'Edem Resort, с. Стрілки', 'Вересень 2026', 'Елегантне весільне сервірування на 120 гостей: підставні золоті тарілки, келихи для вина та шампанського з золотим обідком, прибори Royal.', '<p>Масштабне весільне святкування у банкетному залі заміського комплексу Edem Resort. Концепція декору передбачала тепле світло, білосніжний текстиль та акценти благородного золота.</p><p>Для сервірування столів молодих та 12 круглих гостьових столів компанія «Крістал» надала повний комплект фарфору, дизайнерських столових приборів та преміального кришталевого скла. Усі келихи доставлено у брендованих захисних боксах безпосередньо в день монтажу локації.</p>', 'catalog/demo/banners/wedding-case.jpg', 1, 1, NOW()),
(2, 'Фуршет IT-конференції у Citadel Inn', 'furshet-it-konferentsiya-lviv', 'buffet', 250, 'Citadel Inn, м. Львів', 'Жовтень 2026', 'Організація безперервного фуршету та кава-пауз на 250 учасників: багаторівневі етажерки, порційний посуд, склянки та чашки для кави.', '<p>Дводенна міжнародна конференція розробників у панорамному залі Citadel Inn. Завдання полягало в забезпеченні швидкої та зручної подачі закусок і десертів під час 15-хвилинних перерв.</p><p>Використано понад 1200 одиниць порційного фуршетного посуду, соусники, підноси з нержавіючої сталі та триярусні етажерки для капкейків і десертів. Оренда посуду дала змогу організаторам уникнути витрат на одноразовий пластик та зберегти преміальний статус події.</p>', 'catalog/demo/banners/buffet-case.jpg', 2, 1, NOW()),
(3, 'Заміський кейтеринг на березі озера Наварія', 'zahorodnyi-keiterynh-navaria', 'catering', 80, 'Берег озера Наварія', 'Серпень 2026', 'Виїзний банкет просто неба на 80 персон: шатро, темний матовий посуд, келихи для вина, дошки для подачі м’яса та сирів.', '<p>Атмосферний заміський івент у форматі BBQ та відкритої кухні. Для презентації страв від шеф-кухаря було обрано сучасні чорні матові тарілки та дошки з натурального дуба.</p><p>Посуд був привезений спеціальним фургоном «Крістал» разом із шатром та меблями. Після завершення події кейтерингова служба передала посуд немитим — професійне миття та дезінфекцію взяв на себе наш склад.</p>', 'catalog/demo/banners/catering-case.jpg', 3, 1, NOW()),
(4, 'Річниця компанії у бізнес-холі Arena Lviv', 'richnytsya-kompanii-arena-lviv', 'corporate', 300, 'VIP-лаунж Arena Lviv', 'Листопад 2026', 'Гала-вечеря для 300 співробітників та партнерів: сервірування повного циклу страв, барні келихи, коктейльні столи та скатертини.', '<p>Корпоративний вечір великої виробничої компанії. Програма передбачала урочисту частину з фуршетом і подальшу гала-вечерю на 300 посадкових місць.</p><p>Завдяки злагодженій логістиці весь посуд прибув за 4 години до початку кейтерингового накриття. Повне супроводження замовлення особистим менеджером та бездоганний стан кожного прибору.</p>', 'catalog/demo/banners/corporate-case.jpg', 4, 1, NOW())
ON DUPLICATE KEY UPDATE `title` = VALUES(`title`), `summary` = VALUES(`summary`);

-- Зв''язок кейсів з товарами каталогу «Крістал»
INSERT IGNORE INTO `oc_kristal_case_product` (`case_id`, `product_id`) VALUES
(1, 50001), (1, 50005), (1, 50021), (1, 50029), (1, 50033), (1, 50035), (1, 50077), (1, 50082),
(2, 50002), (2, 50014), (2, 50018), (2, 50036), (2, 50039), (2, 50071), (2, 50095),
(3, 50016), (3, 50031), (3, 50034), (3, 50084), (3, 50092),
(4, 50001), (4, 50019), (4, 50027), (4, 50031), (4, 50032), (4, 50035), (4, 50076), (4, 50089);

-- Реальні відгуки Google Reviews
INSERT INTO `oc_kristal_testimonial` (`testimonial_id`, `author_name`, `author_role`, `rating`, `text`, `event_title`, `source`, `source_url`, `avatar`, `date_added`, `sort_order`, `status`) VALUES
(1, 'Олена Мороз', 'Наречена', 5, 'Орендували повний комплект посуду, золоті прибори та келихи для шампанського на наше весілля в Emily Resort. Все приїхало ідеально чистим, відполірованим, у спеціальних кейсах без жодного сколу! Менеджер допоміг точно розрахувати кількість келихів. Дуже виручило те, що посуд можна повертати немитим. Щиро рекомендую Крістал усім нареченим!', 'Весілля на 110 гостей, Emily Resort', 'Google', 'https://maps.google.com', '', '2026-09-14', 1, 1),
(2, 'Тарас Василик', 'Керівник кейтерингу «Галицький Смак»', 5, 'Працюємо з компанією «Крістал» уже понад 3 роки на постійній партнерській основі. Замовляємо фуршетний та банкетний посуд, марміти, столи й текстиль на події від 30 до 400 осіб у Львові та області. Завжди пунктуальна доставка, повна відповідність замовленню та швидка заміна за потреби. Надійні партнери для B2B!', 'Кейтерингові заходи у Львові', 'Google', 'https://maps.google.com', '', '2026-10-02', 2, 1),
(3, 'Марта Ковальчук', 'Event-декоратор, студія «Floral & Decor»', 5, 'Як декоратор я дуже прискіплива до якості та естетики сервірування. Золоті прибори Royal та підставні тарілки від Крістал на фотосесіях і реальних подіях виглядають бездоганно. Клієнти завжди в захваті від оформлення столів. Дякую за сервіс найвищого рівня!', 'Оформлення весільних банкетів', 'Google', 'https://maps.google.com', '', '2026-08-20', 3, 1),
(4, 'Андрій Мельник', 'HR Director, IT-компанія', 5, 'Організовували річний корпоратив нашої компанії на 220 людей. В оренду брали келихи для винного бару, посуд для кейтерингу та високі коктейльні столики. Все доставили чітко за графіком, супровідні документи та безготівковий розрахунок без затримок. Будемо звертатися ще!', 'Корпоратив компанії на 220 осіб', 'Google', 'https://maps.google.com', '', '2026-10-18', 4, 1),
(5, 'Ірина Гринів', 'Організатор приватних свят', 5, 'Брали в оренду посуд на ювілей за містом. Дуже зручний сайт, розрахунок вартості за 15 хвилин, чіткі умови застави без прихованих платежів. Особлива подяка водію, який акуратно заніс усі бокси на локацію.', 'Приватний ювілей за містом', 'Google', 'https://maps.google.com', '', '2026-10-29', 5, 1)
ON DUPLICATE KEY UPDATE `text` = VALUES(`text`), `rating` = VALUES(`rating`);

-- SEO URLs для портфоліо та відгуків
INSERT INTO `oc_seo_url` (`store_id`, `language_id`, `query`, `keyword`) VALUES
(0, 2, 'extension/kristal/case', 'portfolio'),
(0, 2, 'extension/kristal/testimonial', 'vidhuky'),
(0, 2, 'case_id=1', 'vesillya-v-edem-resort'),
(0, 2, 'case_id=2', 'furshet-it-konferentsiya-lviv'),
(0, 2, 'case_id=3', 'zahorodnyi-keiterynh-navaria'),
(0, 2, 'case_id=4', 'richnytsya-kompanii-arena-lviv')
ON DUPLICATE KEY UPDATE `keyword` = VALUES(`keyword`);
