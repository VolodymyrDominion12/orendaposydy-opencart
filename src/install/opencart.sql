-- phpMyAdmin SQL Dump
-- version 4.9.0.1
-- https://www.phpmyadmin.net/
--
-- Хост: 127.0.0.1:3306
-- Время создания: Апр 17 2020 г., 17:03
-- Версия сервера: 10.3.13-MariaDB-log
-- Версия PHP: 7.2.22

SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- База данных: `mafia_opencart`
--

-- --------------------------------------------------------

--
-- Структура таблицы `oc_address`
--

CREATE TABLE `oc_address` (
  `address_id` int(11) NOT NULL,
  `customer_id` int(11) NOT NULL,
  `firstname` varchar(32) NOT NULL,
  `lastname` varchar(32) NOT NULL,
  `company` varchar(40) NOT NULL,
  `address_1` varchar(128) NOT NULL,
  `address_2` varchar(128) NOT NULL,
  `city` varchar(128) NOT NULL,
  `postcode` varchar(10) NOT NULL,
  `country_id` int(11) NOT NULL DEFAULT 0,
  `zone_id` int(11) NOT NULL DEFAULT 0,
  `custom_field` text NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `oc_api`
--

CREATE TABLE `oc_api` (
  `api_id` int(11) NOT NULL,
  `username` varchar(64) NOT NULL,
  `key` text NOT NULL,
  `status` tinyint(1) NOT NULL,
  `date_added` datetime NOT NULL,
  `date_modified` datetime NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_api`
--

INSERT INTO `oc_api` (`api_id`, `username`, `key`, `status`, `date_added`, `date_modified`) VALUES
(1, 'Default', 'WOyfmknhoz8jDPQDqEZClNJJDNHuIRWlhVOcJNZAoN7cmPDmmKXHBQJbcKqlc5HKr04jkso7R5A3r4drcxksbufkIvqqMTSDMngEwRRpHb5BxMqWgSRnMkXqeChVTa3XotD3HuKjZ0rV59w5gumemmvCRntDaZ48BMbFBt7QKs5401SefQe2RR1pZUE7ZpVZatEPuriTHhiKHvRbZm33a452thj8jrEOzktC7tb8fCgbDFjWY152EF7IZrSb576b', 1, '2020-03-30 11:09:10', '2020-03-30 11:09:10');

-- --------------------------------------------------------

--
-- Структура таблицы `oc_api_ip`
--

CREATE TABLE `oc_api_ip` (
  `api_ip_id` int(11) NOT NULL,
  `api_id` int(11) NOT NULL,
  `ip` varchar(40) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_api_ip`
--

INSERT INTO `oc_api_ip` (`api_ip_id`, `api_id`, `ip`) VALUES
(1, 1, '185.102.186.4'),
(2, 1, '127.0.0.1');

-- --------------------------------------------------------

--
-- Структура таблицы `oc_api_session`
--

CREATE TABLE `oc_api_session` (
  `api_session_id` int(11) NOT NULL,
  `api_id` int(11) NOT NULL,
  `session_id` varchar(32) NOT NULL,
  `ip` varchar(40) NOT NULL,
  `date_added` datetime NOT NULL,
  `date_modified` datetime NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_api_session`
--

INSERT INTO `oc_api_session` (`api_session_id`, `api_id`, `session_id`, `ip`, `date_added`, `date_modified`) VALUES
(161, 1, 'bd96ae59ec9c602a48c138ba11', '127.0.0.1', '2020-04-17 14:27:40', '2020-04-17 14:27:40'),
(160, 1, '46c3c6c11137810b17dfb9cc61', '127.0.0.1', '2020-04-17 14:27:30', '2020-04-17 14:27:40');

-- --------------------------------------------------------

--
-- Структура таблицы `oc_attribute`
--

CREATE TABLE `oc_attribute` (
  `attribute_id` int(11) NOT NULL,
  `attribute_group_id` int(11) NOT NULL,
  `sort_order` int(3) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_attribute`
--

INSERT INTO `oc_attribute` (`attribute_id`, `attribute_group_id`, `sort_order`) VALUES
(1, 6, 1),
(2, 6, 5),
(3, 6, 3),
(4, 3, 1),
(5, 3, 2),
(6, 3, 3),
(7, 3, 4),
(8, 3, 5),
(9, 3, 6),
(10, 3, 7),
(11, 3, 8);

-- --------------------------------------------------------

--
-- Структура таблицы `oc_attribute_description`
--

CREATE TABLE `oc_attribute_description` (
  `attribute_id` int(11) NOT NULL,
  `language_id` int(11) NOT NULL,
  `name` varchar(64) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_attribute_description`
--

INSERT INTO `oc_attribute_description` (`attribute_id`, `language_id`, `name`) VALUES
(1, 1, 'Description'),
(2, 1, 'No. of Cores'),
(4, 1, 'test 1'),
(5, 1, 'test 2'),
(6, 1, 'test 3'),
(7, 1, 'test 4'),
(8, 1, 'test 5'),
(9, 1, 'test 6'),
(10, 1, 'test 7'),
(11, 1, 'test 8'),
(3, 1, 'Clockspeed'),
(1, 2, 'Description'),
(2, 2, 'No. of Cores'),
(4, 2, 'test 1'),
(5, 2, 'test 2'),
(6, 2, 'test 3'),
(7, 2, 'test 4'),
(8, 2, 'test 5'),
(9, 2, 'test 6'),
(10, 2, 'test 7'),
(11, 2, 'test 8'),
(3, 2, 'Clockspeed');

-- --------------------------------------------------------

--
-- Структура таблицы `oc_attribute_group`
--

CREATE TABLE `oc_attribute_group` (
  `attribute_group_id` int(11) NOT NULL,
  `sort_order` int(3) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_attribute_group`
--

INSERT INTO `oc_attribute_group` (`attribute_group_id`, `sort_order`) VALUES
(3, 2),
(4, 1),
(5, 3),
(6, 4);

-- --------------------------------------------------------

--
-- Структура таблицы `oc_attribute_group_description`
--

CREATE TABLE `oc_attribute_group_description` (
  `attribute_group_id` int(11) NOT NULL,
  `language_id` int(11) NOT NULL,
  `name` varchar(64) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_attribute_group_description`
--

INSERT INTO `oc_attribute_group_description` (`attribute_group_id`, `language_id`, `name`) VALUES
(3, 1, 'Memory'),
(4, 1, 'Technical'),
(5, 1, 'Motherboard'),
(6, 1, 'Processor'),
(3, 2, 'Memory'),
(4, 2, 'Technical'),
(5, 2, 'Motherboard'),
(6, 2, 'Processor');

-- --------------------------------------------------------

--
-- Структура таблицы `oc_banner`
--

CREATE TABLE `oc_banner` (
  `banner_id` int(11) NOT NULL,
  `name` varchar(64) NOT NULL,
  `status` tinyint(1) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_banner`
--

INSERT INTO `oc_banner` (`banner_id`, `name`, `status`) VALUES
(9, 'Головна комп\'ютерна версія', 1),
(10, 'Головна мобільна версія', 1);

-- --------------------------------------------------------

--
-- Структура таблицы `oc_banner_image`
--

CREATE TABLE `oc_banner_image` (
  `banner_image_id` int(11) NOT NULL,
  `banner_id` int(11) NOT NULL,
  `language_id` int(11) NOT NULL,
  `title` varchar(64) NOT NULL,
  `link` varchar(255) NOT NULL,
  `image` varchar(255) NOT NULL,
  `sort_order` int(3) NOT NULL DEFAULT 0
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_banner_image`
--

INSERT INTO `oc_banner_image` (`banner_image_id`, `banner_id`, `language_id`, `title`, `link`, `image`, `sort_order`) VALUES
(124, 10, 2, 'Торт', '#', 'catalog/demodata/2.jpg', 0),
(123, 10, 2, 'Торт', '#', 'catalog/demodata/2.jpg', 0),
(122, 9, 2, 'Доставка Десктоп', '#', 'catalog/demodata/3460320.jpg', 2),
(121, 9, 2, 'Доставка Десктоп', '#', 'catalog/demodata/3460320.jpg', 0);

-- --------------------------------------------------------

--
-- Структура таблицы `oc_cart`
--

CREATE TABLE `oc_cart` (
  `cart_id` int(11) UNSIGNED NOT NULL,
  `api_id` int(11) NOT NULL,
  `customer_id` int(11) NOT NULL,
  `session_id` varchar(32) NOT NULL,
  `product_id` int(11) NOT NULL,
  `recurring_id` int(11) NOT NULL,
  `option` text NOT NULL,
  `quantity` int(5) NOT NULL,
  `date_added` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `oc_category`
--

CREATE TABLE `oc_category` (
  `category_id` int(11) NOT NULL,
  `image` varchar(255) DEFAULT NULL,
  `parent_id` int(11) NOT NULL DEFAULT 0,
  `top` tinyint(1) NOT NULL,
  `column` int(3) NOT NULL,
  `sort_order` int(3) NOT NULL DEFAULT 0,
  `status` tinyint(1) NOT NULL,
  `date_added` datetime NOT NULL,
  `date_modified` datetime NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_category`
--

INSERT INTO `oc_category` (`category_id`, `image`, `parent_id`, `top`, `column`, `sort_order`, `status`, `date_added`, `date_modified`) VALUES
(62, 'catalog/Categori/99513-170-340-category_item_big_1_4.png', 0, 1, 1, 0, 1, '2020-03-30 12:27:27', '2020-03-30 13:00:11'),
(63, 'catalog/Categori/99515-170-340-category_item_big_1_3(1).png', 0, 0, 1, 0, 1, '2020-03-30 12:30:02', '2020-03-30 12:59:42'),
(64, '', 60, 0, 1, 0, 1, '2020-03-30 12:39:15', '2020-03-30 12:39:15'),
(65, '', 60, 0, 1, 0, 1, '2020-03-30 12:44:50', '2020-03-30 12:44:50'),
(67, '', 60, 1, 1, 0, 1, '2020-03-30 13:01:35', '2020-03-30 13:03:15'),
(68, '', 60, 0, 1, 0, 1, '2020-03-30 13:01:56', '2020-03-30 13:03:22'),
(69, '', 60, 0, 1, 0, 1, '2020-03-30 13:02:32', '2020-03-30 13:03:31'),
(70, '', 60, 0, 1, 0, 1, '2020-03-30 13:02:59', '2020-03-30 13:02:59'),
(71, '', 60, 0, 1, 0, 1, '2020-03-30 13:03:56', '2020-03-30 13:03:56'),
(78, 'catalog/Categori/Coca-Cola(0.5)-800x800.png', 0, 1, 1, 5, 1, '2020-03-30 15:10:10', '2020-03-30 15:10:20'),
(76, '', 60, 0, 1, 0, 1, '2020-03-30 13:05:19', '2020-03-30 13:05:19'),
(77, '', 60, 0, 1, 0, 1, '2020-03-30 13:05:31', '2020-03-30 13:05:31'),
(59, 'catalog/Categori/99508-170-340-category_item_big_1_1.png', 0, 1, 1, 0, 1, '2020-03-30 11:59:28', '2020-03-30 12:59:59'),
(60, 'catalog/Categori/99510-170-340-category_item_big_1_2.png', 0, 1, 1, 0, 1, '2020-03-30 12:04:01', '2020-03-30 13:00:05'),
(61, 'catalog/Categori/99511-170-340-category_item_big_1_6.png', 0, 1, 1, 1, 1, '2020-03-30 12:08:06', '2020-03-30 12:59:35');

-- --------------------------------------------------------

--
-- Структура таблицы `oc_category_description`
--

CREATE TABLE `oc_category_description` (
  `category_id` int(11) NOT NULL,
  `language_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `meta_title` varchar(255) NOT NULL,
  `meta_description` varchar(255) NOT NULL,
  `meta_keyword` varchar(255) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_category_description`
--

INSERT INTO `oc_category_description` (`category_id`, `language_id`, `name`, `description`, `meta_title`, `meta_description`, `meta_keyword`) VALUES
(78, 2, 'Супутні товари', '', 'Супутні товари', '', ''),
(76, 2, 'Тестова категорія 10', '', 'Тестова категорія 10', '', ''),
(77, 2, 'Тестова категорія 11', '', 'Тестова категорія 11', '', ''),
(63, 2, 'Лапша і рис', '&lt;p&gt;Вкусная еда — одна из замечательных вещей, поднимающих настроение. Но далеко не вся вкусная еда полезна. То ли дело лапша и рис — аппетитный дуэт, сохраняющий стройную фигуру. Жители Одессы могут насладиться этими блюдами, не выходя из дома. Достаточно сделать заказ через Eda.ua.&lt;/p&gt;&lt;p&gt;Польза азиатской кухни&lt;/p&gt;&lt;p&gt;Азиатская кухня любима людьми, благодаря своеобразному кисло-сладкому вкусу и низкому содержанию калорий в продуктах.&lt;/p&gt;&lt;p&gt;Рис — некалорийный и неприхотливый злак. Из него готовят такие замечательные блюда, как плов, ризотто и карри. При этом они диетические и имеют ряд полезных свойств (характерных для риса):&lt;/p&gt;', 'Лапша і рис', 'Лапша і рис', ''),
(62, 2, 'Шашлик', '&lt;p&gt;Родословная этого блюда восходит к бытовавшей у многих народов традиции жарить на вертеле массивные куски мяса или даже целые туши животных. Однако далеко не каждый регион располагает таким количеством древесины, чтобы зажарить, например, вепря. Жители степных и пустынных местностей Евразии нашли простой выход из этого положения: для экономии древесины резать мясо на кусочки помельче, чтобы жарилось оно быстрее и требовало меньшего количества топлива. Так благодаря особенностям древней энергетики появился шашлык. Поскольку блюдо это популярно у многих народов, то доставка шашлыка в Одессе – портовом многонациональном городе, населенном людьми из самых разных частей света – является востребованной услугой. Шашлык на дом или в офис – заказать шашлык в Одессе можно в любую точку города. Благодаря&lt;br&gt;&lt;/p&gt;', 'Шашлик', '', ''),
(64, 2, 'Сир Філаделфія', '', 'Сир Філаделфія', '', ''),
(65, 2, 'Сашимі', '', 'Сашимі', '', ''),
(67, 2, 'Тестова категорія 1', '', 'Тестова категорія 1', '', ''),
(68, 2, 'Тестова категорія 2', '', 'Тестова категорія 2', '', ''),
(69, 2, 'Тестова категорія 3', '', 'Тестова категорія 3', '', ''),
(70, 2, 'Тестова категорія 4', '', 'Тестова категорія 4', '', ''),
(71, 2, 'Тестова категорія 5', '', 'Тестова категорія 5', '', ''),
(59, 2, 'Піца', '&lt;p&gt;Любите ли вы пиццу? Нет, любите ли вы пиццу так, как любим ее мы? Это все равно, что спросить человека, любит ли он есть. Пиццу нельзя не любить. Её можно обожать, ею можно восхищаться, её можно есть всегда и всюду – дома, в офисе, в компании, на вечеринке, на корпоративном торжестве или на семейном празднике.&lt;/p&gt;&lt;p&gt;Знаете, что такое лучшая пицца в Киеве? Это тоненький слой теста, который раскатывается не менее тридцати минут, а затем слегка, но не чересчур – поджаривается снизу. А сверху – все, что ваша душа пожелает: баранина, курица, свинина, говядина, салями, грибы, креветки, мидии, соленые огурчики, оливки, помидоры… Ну и, конечно, толстый слой сыра. Какого? Опять же, дело вкуса: нейтральный эмменталь, выдержанный пармезан или пряная горгонзола – у каждого заведения, которое предлагает заказать пиццу в Киеве, свои фирменные рецепты.&lt;/p&gt;&lt;p&gt;Это демократичное блюдо на все времена и для любой компании. Кто бы ни собрался за столом – от аппетитного кусочка свежеиспеченной пиццы не откажется никто.&lt;/p&gt;&lt;p&gt;Круглосуточная доставка пиццы – хорошее решение как для взрослых, так и для детей, которые просто без ума от этого блюда итальянской кухни.&lt;/p&gt;&lt;p&gt;Надоели шумные сборища? Пицца на дом, семейный уют, хорошая книга, новый фильм – что еще нужно, чтобы приятно скоротать вечер?&lt;/p&gt;', 'Замовлення піци з доставкою в Києві - Ресторан Sauco', 'Замовлення піци з доставкою в Києві - Ресторан Sauco', ''),
(60, 2, 'Суші', '&lt;p&gt;Если вы попробовали японскую кухню, вы уже раскусили, чем она отличается от других кулинарий мира. В них прекрасно все – изящество оформления, красота сервировки, дозировка ингредиентов, вкус отдельных продуктов и букет ощущений, который пробуждают во вкусовых рецепторах многочисленные приправы. На сайте eda.ua вы действительно сможете круглосуточно заказать роллы, сашими, сеты и суши на дом или в офис. Вы найдете целый перечень заведений с изящным восточным меню. Список ресторанов с японским меню постоянно увеличивается. Вы можете заказать суши в Киеве и забрать их самостоятельно, по пути домой или в офис. Еще что удобно на сайте – фильтрация ресторанов, которые предлагают скидки, купоны, проводят различные акции. Доставка суши в Киеве&amp;nbsp;будет выполнена быстро и недорого. Обратите внимание,&lt;br&gt;&lt;/p&gt;', 'Суші', 'Суші', ''),
(61, 2, 'Бургери', '&lt;p&gt;Жемчужина у моря под названием Киев найдет, чем вас порадовать, кем бы вы ни были: серьезным бизнесменом или простым туристом. В Одессе есть все, что нужно для жизни: это важный деловой центр, масса культурных заведений, огромное множество развлекательных мероприятий. Вам тут точно не будет скучно, особенно если вы приехали сюда летом — море, пляжи и ночные клубы смогут ярко разнообразить ваш досуг.&lt;/p&gt;&lt;p&gt;Украинская кухня&amp;nbsp; — две большие разницы. В последней присутствует огромное разнообразие блюд из морепродуктов, что вызвано близостью к морю. В этом приморском городе существуют блюда, которые вы не встретите больше нигде в Украине:&lt;br&gt;&lt;/p&gt;&lt;p&gt;&lt;br&gt;&lt;/p&gt;', 'Бургери', 'Бургери', '');

-- --------------------------------------------------------

--
-- Структура таблицы `oc_category_filter`
--

CREATE TABLE `oc_category_filter` (
  `category_id` int(11) NOT NULL,
  `filter_id` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `oc_category_path`
--

CREATE TABLE `oc_category_path` (
  `category_id` int(11) NOT NULL,
  `path_id` int(11) NOT NULL,
  `level` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_category_path`
--

INSERT INTO `oc_category_path` (`category_id`, `path_id`, `level`) VALUES
(77, 77, 1),
(77, 60, 0),
(76, 76, 1),
(76, 60, 0),
(78, 78, 0),
(71, 71, 1),
(71, 60, 0),
(67, 67, 1),
(68, 60, 0),
(68, 68, 1),
(69, 60, 0),
(69, 69, 1),
(70, 60, 0),
(62, 62, 0),
(70, 70, 1),
(67, 60, 0),
(65, 65, 1),
(65, 60, 0),
(64, 64, 1),
(63, 63, 0),
(64, 60, 0),
(59, 59, 0),
(60, 60, 0),
(61, 61, 0);

-- --------------------------------------------------------

--
-- Структура таблицы `oc_category_to_layout`
--

CREATE TABLE `oc_category_to_layout` (
  `category_id` int(11) NOT NULL,
  `store_id` int(11) NOT NULL,
  `layout_id` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_category_to_layout`
--

INSERT INTO `oc_category_to_layout` (`category_id`, `store_id`, `layout_id`) VALUES
(59, 0, 0),
(60, 0, 0),
(61, 0, 0),
(62, 0, 0),
(63, 0, 0),
(64, 0, 0),
(65, 0, 0),
(67, 0, 0),
(68, 0, 0),
(69, 0, 0),
(70, 0, 0),
(71, 0, 0),
(78, 0, 0),
(76, 0, 0),
(77, 0, 0);

-- --------------------------------------------------------

--
-- Структура таблицы `oc_category_to_store`
--

CREATE TABLE `oc_category_to_store` (
  `category_id` int(11) NOT NULL,
  `store_id` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_category_to_store`
--

INSERT INTO `oc_category_to_store` (`category_id`, `store_id`) VALUES
(59, 0),
(60, 0),
(61, 0),
(62, 0),
(63, 0),
(64, 0),
(65, 0),
(67, 0),
(68, 0),
(69, 0),
(70, 0),
(71, 0),
(76, 0),
(77, 0),
(78, 0);

-- --------------------------------------------------------

--
-- Структура таблицы `oc_country`
--

CREATE TABLE `oc_country` (
  `country_id` int(11) NOT NULL,
  `name` varchar(128) NOT NULL,
  `iso_code_2` varchar(2) NOT NULL,
  `iso_code_3` varchar(3) NOT NULL,
  `address_format` text NOT NULL,
  `postcode_required` tinyint(1) NOT NULL,
  `status` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_country`
--

INSERT INTO `oc_country` (`country_id`, `name`, `iso_code_2`, `iso_code_3`, `address_format`, `postcode_required`, `status`) VALUES
(220, 'Украина', 'UA', 'UKR', '', 0, 1);

-- --------------------------------------------------------

--
-- Структура таблицы `oc_coupon`
--

CREATE TABLE `oc_coupon` (
  `coupon_id` int(11) NOT NULL,
  `name` varchar(128) NOT NULL,
  `code` varchar(20) NOT NULL,
  `type` char(1) NOT NULL,
  `discount` decimal(15,4) NOT NULL,
  `logged` tinyint(1) NOT NULL,
  `shipping` tinyint(1) NOT NULL,
  `total` decimal(15,4) NOT NULL,
  `date_start` date NOT NULL DEFAULT '0000-00-00',
  `date_end` date NOT NULL DEFAULT '0000-00-00',
  `uses_total` int(11) NOT NULL,
  `uses_customer` varchar(11) NOT NULL,
  `status` tinyint(1) NOT NULL,
  `date_added` datetime NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_coupon`
--

INSERT INTO `oc_coupon` (`coupon_id`, `name`, `code`, `type`, `discount`, `logged`, `shipping`, `total`, `date_start`, `date_end`, `uses_total`, `uses_customer`, `status`, `date_added`) VALUES
(4, '-10% Discount', '2222', 'P', '10.0000', 0, 0, '0.0000', '2014-01-01', '2020-01-01', 10, '10', 0, '2009-01-27 13:55:03'),
(5, 'Free Shipping', '3333', 'P', '0.0000', 0, 1, '100.0000', '2014-01-01', '2014-02-01', 10, '10', 0, '2009-03-14 21:13:53'),
(6, '-10.00 Discount', '1111', 'F', '10.0000', 0, 0, '10.0000', '2014-01-01', '2020-01-01', 100000, '10000', 0, '2009-03-14 21:15:18');

-- --------------------------------------------------------

--
-- Структура таблицы `oc_coupon_category`
--

CREATE TABLE `oc_coupon_category` (
  `coupon_id` int(11) NOT NULL,
  `category_id` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `oc_coupon_history`
--

CREATE TABLE `oc_coupon_history` (
  `coupon_history_id` int(11) NOT NULL,
  `coupon_id` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  `customer_id` int(11) NOT NULL,
  `amount` decimal(15,4) NOT NULL,
  `date_added` datetime NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `oc_coupon_product`
--

CREATE TABLE `oc_coupon_product` (
  `coupon_product_id` int(11) NOT NULL,
  `coupon_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `oc_currency`
--

CREATE TABLE `oc_currency` (
  `currency_id` int(11) NOT NULL,
  `title` varchar(32) NOT NULL,
  `code` varchar(3) NOT NULL,
  `symbol_left` varchar(12) NOT NULL,
  `symbol_right` varchar(12) NOT NULL,
  `decimal_place` char(1) NOT NULL,
  `value` double(15,8) NOT NULL,
  `status` tinyint(1) NOT NULL,
  `date_modified` datetime NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_currency`
--

INSERT INTO `oc_currency` (`currency_id`, `title`, `code`, `symbol_left`, `symbol_right`, `decimal_place`, `value`, `status`, `date_modified`) VALUES
(2, 'Гривна', 'UAH', '', ' грн', '0', 1.00000000, 1, '2020-04-17 14:02:48');

-- --------------------------------------------------------

--
-- Структура таблицы `oc_customer`
--

CREATE TABLE `oc_customer` (
  `customer_id` int(11) NOT NULL,
  `customer_group_id` int(11) NOT NULL,
  `store_id` int(11) NOT NULL DEFAULT 0,
  `language_id` int(11) NOT NULL,
  `firstname` varchar(32) NOT NULL,
  `lastname` varchar(32) NOT NULL,
  `email` varchar(96) NOT NULL,
  `telephone` varchar(32) NOT NULL,
  `fax` varchar(32) NOT NULL,
  `password` varchar(40) NOT NULL,
  `salt` varchar(9) NOT NULL,
  `cart` text DEFAULT NULL,
  `wishlist` text DEFAULT NULL,
  `newsletter` tinyint(1) NOT NULL DEFAULT 0,
  `address_id` int(11) NOT NULL DEFAULT 0,
  `custom_field` text NOT NULL,
  `ip` varchar(40) NOT NULL,
  `status` tinyint(1) NOT NULL,
  `safe` tinyint(1) NOT NULL,
  `token` text NOT NULL,
  `code` varchar(40) NOT NULL,
  `date_added` datetime NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `oc_customer_activity`
--

CREATE TABLE `oc_customer_activity` (
  `customer_activity_id` int(11) NOT NULL,
  `customer_id` int(11) NOT NULL,
  `key` varchar(64) NOT NULL,
  `data` text NOT NULL,
  `ip` varchar(40) NOT NULL,
  `date_added` datetime NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `oc_customer_affiliate`
--

CREATE TABLE `oc_customer_affiliate` (
  `customer_id` int(11) NOT NULL,
  `company` varchar(40) NOT NULL,
  `website` varchar(255) NOT NULL,
  `tracking` varchar(64) NOT NULL,
  `commission` decimal(4,2) NOT NULL DEFAULT 0.00,
  `tax` varchar(64) NOT NULL,
  `payment` varchar(6) NOT NULL,
  `cheque` varchar(100) NOT NULL,
  `paypal` varchar(64) NOT NULL,
  `bank_name` varchar(64) NOT NULL,
  `bank_branch_number` varchar(64) NOT NULL,
  `bank_swift_code` varchar(64) NOT NULL,
  `bank_account_name` varchar(64) NOT NULL,
  `bank_account_number` varchar(64) NOT NULL,
  `custom_field` text NOT NULL,
  `status` tinyint(1) NOT NULL,
  `date_added` datetime NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `oc_customer_approval`
--

CREATE TABLE `oc_customer_approval` (
  `customer_approval_id` int(11) NOT NULL,
  `customer_id` int(11) NOT NULL,
  `type` varchar(9) NOT NULL,
  `date_added` datetime NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `oc_customer_group`
--

CREATE TABLE `oc_customer_group` (
  `customer_group_id` int(11) NOT NULL,
  `approval` int(1) NOT NULL,
  `sort_order` int(3) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_customer_group`
--

INSERT INTO `oc_customer_group` (`customer_group_id`, `approval`, `sort_order`) VALUES
(1, 0, 1);

-- --------------------------------------------------------

--
-- Структура таблицы `oc_customer_group_description`
--

CREATE TABLE `oc_customer_group_description` (
  `customer_group_id` int(11) NOT NULL,
  `language_id` int(11) NOT NULL,
  `name` varchar(32) NOT NULL,
  `description` text NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_customer_group_description`
--

INSERT INTO `oc_customer_group_description` (`customer_group_id`, `language_id`, `name`, `description`) VALUES
(1, 1, 'Default', 'test'),
(1, 2, 'Default', 'test');

-- --------------------------------------------------------

--
-- Структура таблицы `oc_customer_history`
--

CREATE TABLE `oc_customer_history` (
  `customer_history_id` int(11) NOT NULL,
  `customer_id` int(11) NOT NULL,
  `comment` text NOT NULL,
  `date_added` datetime NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `oc_customer_ip`
--

CREATE TABLE `oc_customer_ip` (
  `customer_ip_id` int(11) NOT NULL,
  `customer_id` int(11) NOT NULL,
  `ip` varchar(40) NOT NULL,
  `date_added` datetime NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `oc_customer_login`
--

CREATE TABLE `oc_customer_login` (
  `customer_login_id` int(11) NOT NULL,
  `email` varchar(96) NOT NULL,
  `ip` varchar(40) NOT NULL,
  `total` int(4) NOT NULL,
  `date_added` datetime NOT NULL,
  `date_modified` datetime NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `oc_customer_online`
--

CREATE TABLE `oc_customer_online` (
  `ip` varchar(40) NOT NULL,
  `customer_id` int(11) NOT NULL,
  `url` text NOT NULL,
  `referer` text NOT NULL,
  `date_added` datetime NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `oc_customer_reward`
--

CREATE TABLE `oc_customer_reward` (
  `customer_reward_id` int(11) NOT NULL,
  `customer_id` int(11) NOT NULL DEFAULT 0,
  `order_id` int(11) NOT NULL DEFAULT 0,
  `description` text NOT NULL,
  `points` int(8) NOT NULL DEFAULT 0,
  `date_added` datetime NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `oc_customer_search`
--

CREATE TABLE `oc_customer_search` (
  `customer_search_id` int(11) NOT NULL,
  `store_id` int(11) NOT NULL,
  `language_id` int(11) NOT NULL,
  `customer_id` int(11) NOT NULL,
  `keyword` varchar(255) NOT NULL,
  `category_id` int(11) DEFAULT NULL,
  `sub_category` tinyint(1) NOT NULL,
  `description` tinyint(1) NOT NULL,
  `products` int(11) NOT NULL,
  `ip` varchar(40) NOT NULL,
  `date_added` datetime NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `oc_customer_transaction`
--

CREATE TABLE `oc_customer_transaction` (
  `customer_transaction_id` int(11) NOT NULL,
  `customer_id` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  `description` text NOT NULL,
  `amount` decimal(15,4) NOT NULL,
  `date_added` datetime NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `oc_customer_wishlist`
--

CREATE TABLE `oc_customer_wishlist` (
  `customer_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `date_added` datetime NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `oc_custom_field`
--

CREATE TABLE `oc_custom_field` (
  `custom_field_id` int(11) NOT NULL,
  `type` varchar(32) NOT NULL,
  `value` text NOT NULL,
  `validation` varchar(255) NOT NULL,
  `location` varchar(10) NOT NULL,
  `status` tinyint(1) NOT NULL,
  `sort_order` int(3) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `oc_custom_field_customer_group`
--

CREATE TABLE `oc_custom_field_customer_group` (
  `custom_field_id` int(11) NOT NULL,
  `customer_group_id` int(11) NOT NULL,
  `required` tinyint(1) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `oc_custom_field_description`
--

CREATE TABLE `oc_custom_field_description` (
  `custom_field_id` int(11) NOT NULL,
  `language_id` int(11) NOT NULL,
  `name` varchar(128) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `oc_custom_field_value`
--

CREATE TABLE `oc_custom_field_value` (
  `custom_field_value_id` int(11) NOT NULL,
  `custom_field_id` int(11) NOT NULL,
  `sort_order` int(3) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `oc_custom_field_value_description`
--

CREATE TABLE `oc_custom_field_value_description` (
  `custom_field_value_id` int(11) NOT NULL,
  `language_id` int(11) NOT NULL,
  `custom_field_id` int(11) NOT NULL,
  `name` varchar(128) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `oc_download`
--

CREATE TABLE `oc_download` (
  `download_id` int(11) NOT NULL,
  `filename` varchar(160) NOT NULL,
  `mask` varchar(128) NOT NULL,
  `date_added` datetime NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `oc_download_description`
--

CREATE TABLE `oc_download_description` (
  `download_id` int(11) NOT NULL,
  `language_id` int(11) NOT NULL,
  `name` varchar(64) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `oc_event`
--

CREATE TABLE `oc_event` (
  `event_id` int(11) NOT NULL,
  `code` varchar(64) NOT NULL,
  `trigger` text NOT NULL,
  `action` text NOT NULL,
  `status` tinyint(1) NOT NULL,
  `sort_order` int(3) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_event`
--

INSERT INTO `oc_event` (`event_id`, `code`, `trigger`, `action`, `status`, `sort_order`) VALUES
(1, 'activity_customer_add', 'catalog/model/account/customer/addCustomer/after', 'event/activity/addCustomer', 1, 0),
(2, 'activity_customer_edit', 'catalog/model/account/customer/editCustomer/after', 'event/activity/editCustomer', 1, 0),
(3, 'activity_customer_password', 'catalog/model/account/customer/editPassword/after', 'event/activity/editPassword', 1, 0),
(4, 'activity_customer_forgotten', 'catalog/model/account/customer/editCode/after', 'event/activity/forgotten', 1, 0),
(5, 'activity_transaction', 'catalog/model/account/customer/addTransaction/after', 'event/activity/addTransaction', 1, 0),
(6, 'activity_customer_login', 'catalog/model/account/customer/deleteLoginAttempts/after', 'event/activity/login', 1, 0),
(7, 'activity_address_add', 'catalog/model/account/address/addAddress/after', 'event/activity/addAddress', 1, 0),
(8, 'activity_address_edit', 'catalog/model/account/address/editAddress/after', 'event/activity/editAddress', 1, 0),
(9, 'activity_address_delete', 'catalog/model/account/address/deleteAddress/after', 'event/activity/deleteAddress', 1, 0),
(10, 'activity_affiliate_add', 'catalog/model/account/customer/addAffiliate/after', 'event/activity/addAffiliate', 1, 0),
(11, 'activity_affiliate_edit', 'catalog/model/account/customer/editAffiliate/after', 'event/activity/editAffiliate', 1, 0),
(12, 'activity_order_add', 'catalog/model/checkout/order/addOrderHistory/before', 'event/activity/addOrderHistory', 1, 0),
(13, 'activity_return_add', 'catalog/model/account/return/addReturn/after', 'event/activity/addReturn', 1, 0),
(14, 'mail_transaction', 'catalog/model/account/customer/addTransaction/after', 'mail/transaction', 1, 0),
(15, 'mail_forgotten', 'catalog/model/account/customer/editCode/after', 'mail/forgotten', 1, 0),
(16, 'mail_customer_add', 'catalog/model/account/customer/addCustomer/after', 'mail/register', 1, 0),
(17, 'mail_customer_alert', 'catalog/model/account/customer/addCustomer/after', 'mail/register/alert', 1, 0),
(18, 'mail_affiliate_add', 'catalog/model/account/customer/addAffiliate/after', 'mail/affiliate', 1, 0),
(19, 'mail_affiliate_alert', 'catalog/model/account/customer/addAffiliate/after', 'mail/affiliate/alert', 1, 0),
(20, 'mail_voucher', 'catalog/model/checkout/order/addOrderHistory/after', 'extension/total/voucher/send', 1, 0),
(21, 'mail_order_add', 'catalog/model/checkout/order/addOrderHistory/before', 'mail/order', 1, 0),
(22, 'mail_order_alert', 'catalog/model/checkout/order/addOrderHistory/before', 'mail/order/alert', 1, 0),
(23, 'statistics_review_add', 'catalog/model/catalog/review/addReview/after', 'event/statistics/addReview', 1, 0),
(24, 'statistics_return_add', 'catalog/model/account/return/addReturn/after', 'event/statistics/addReturn', 1, 0),
(25, 'statistics_order_history', 'catalog/model/checkout/order/addOrderHistory/after', 'event/statistics/addOrderHistory', 1, 0),
(26, 'admin_mail_affiliate_approve', 'admin/model/customer/customer_approval/approveAffiliate/after', 'mail/affiliate/approve', 1, 0),
(27, 'admin_mail_affiliate_deny', 'admin/model/customer/customer_approval/denyAffiliate/after', 'mail/affiliate/deny', 1, 0),
(28, 'admin_mail_customer_approve', 'admin/model/customer/customer_approval/approveCustomer/after', 'mail/customer/approve', 1, 0),
(29, 'admin_mail_customer_deny', 'admin/model/customer/customer_approval/denyCustomer/after', 'mail/customer/deny', 1, 0),
(30, 'admin_mail_reward', 'admin/model/customer/customer/addReward/after', 'mail/reward', 1, 0),
(31, 'admin_mail_transaction', 'admin/model/customer/customer/addTransaction/after', 'mail/transaction', 1, 0),
(32, 'admin_mail_return', 'admin/model/sale/return/addReturn/after', 'mail/return', 1, 0),
(33, 'admin_mail_forgotten', 'admin/model/user/user/editCode/after', 'mail/forgotten', 1, 0),
(34, 'advertise_google', 'admin/model/catalog/product/deleteProduct/after', 'extension/advertise/google/deleteProduct', 1, 0),
(35, 'advertise_google', 'admin/model/catalog/product/copyProduct/after', 'extension/advertise/google/copyProduct', 1, 0),
(36, 'advertise_google', 'admin/view/common/column_left/before', 'extension/advertise/google/admin_link', 1, 0),
(37, 'advertise_google', 'admin/model/catalog/product/addProduct/after', 'extension/advertise/google/addProduct', 1, 0),
(38, 'advertise_google', 'catalog/controller/checkout/success/before', 'extension/advertise/google/before_checkout_success', 1, 0),
(39, 'advertise_google', 'catalog/view/common/header/after', 'extension/advertise/google/google_global_site_tag', 1, 0),
(40, 'advertise_google', 'catalog/view/common/success/after', 'extension/advertise/google/google_dynamic_remarketing_purchase', 1, 0),
(41, 'advertise_google', 'catalog/view/product/product/after', 'extension/advertise/google/google_dynamic_remarketing_product', 1, 0),
(42, 'advertise_google', 'catalog/view/product/search/after', 'extension/advertise/google/google_dynamic_remarketing_searchresults', 1, 0),
(43, 'advertise_google', 'catalog/view/product/category/after', 'extension/advertise/google/google_dynamic_remarketing_category', 1, 0),
(44, 'advertise_google', 'catalog/view/common/home/after', 'extension/advertise/google/google_dynamic_remarketing_home', 1, 0),
(45, 'advertise_google', 'catalog/view/checkout/cart/after', 'extension/advertise/google/google_dynamic_remarketing_cart', 1, 0),
(46, 'sms_alert', 'catalog/model/checkout/order/addOrderHistory/after', 'extension/module/sms_alert', 1, 0);

-- --------------------------------------------------------

--
-- Структура таблицы `oc_extension`
--

CREATE TABLE `oc_extension` (
  `extension_id` int(11) NOT NULL,
  `type` varchar(32) NOT NULL,
  `code` varchar(32) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_extension`
--

INSERT INTO `oc_extension` (`extension_id`, `type`, `code`) VALUES
(1, 'payment', 'cod'),
(2, 'total', 'shipping'),
(3, 'total', 'sub_total'),
(4, 'total', 'tax'),
(5, 'total', 'total'),
(8, 'total', 'credit'),
(9, 'shipping', 'flat'),
(10, 'total', 'handling'),
(11, 'total', 'low_order_fee'),
(12, 'total', 'coupon'),
(47, 'module', 'featured'),
(15, 'total', 'reward'),
(16, 'total', 'voucher'),
(17, 'payment', 'free_checkout'),
(46, 'module', 'category'),
(44, 'module', 'banner'),
(20, 'theme', 'default'),
(21, 'dashboard', 'activity'),
(22, 'dashboard', 'sale'),
(23, 'dashboard', 'recent'),
(24, 'dashboard', 'order'),
(25, 'dashboard', 'online'),
(26, 'dashboard', 'map'),
(27, 'dashboard', 'customer'),
(28, 'dashboard', 'chart'),
(29, 'report', 'sale_coupon'),
(31, 'report', 'customer_search'),
(32, 'report', 'customer_transaction'),
(33, 'report', 'product_purchased'),
(34, 'report', 'product_viewed'),
(35, 'report', 'sale_return'),
(36, 'report', 'sale_order'),
(37, 'report', 'sale_shipping'),
(38, 'report', 'sale_tax'),
(39, 'report', 'customer_activity'),
(40, 'report', 'customer_order'),
(41, 'report', 'customer_reward');

-- --------------------------------------------------------

--
-- Структура таблицы `oc_extension_install`
--

CREATE TABLE `oc_extension_install` (
  `extension_install_id` int(11) NOT NULL,
  `extension_download_id` int(11) NOT NULL,
  `filename` varchar(255) NOT NULL,
  `date_added` datetime NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_extension_install`
--

INSERT INTO `oc_extension_install` (`extension_install_id`, `extension_download_id`, `filename`, `date_added`) VALUES
(1, 0, 'ukrainian-ocstore_opencart-3.0.x.ocmod.zip', '2020-03-30 11:13:52');

-- --------------------------------------------------------

--
-- Структура таблицы `oc_extension_path`
--

CREATE TABLE `oc_extension_path` (
  `extension_path_id` int(11) NOT NULL,
  `extension_install_id` int(11) NOT NULL,
  `path` varchar(255) NOT NULL,
  `date_added` datetime NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_extension_path`
--

INSERT INTO `oc_extension_path` (`extension_path_id`, `extension_install_id`, `path`, `date_added`) VALUES
(1, 1, 'admin/language/uk-ua', '2020-03-30 11:13:54'),
(2, 1, 'catalog/language/uk-ua', '2020-03-30 11:13:54'),
(3, 1, 'admin/language/uk-ua/blog', '2020-03-30 11:13:54'),
(4, 1, 'admin/language/uk-ua/catalog', '2020-03-30 11:13:54'),
(5, 1, 'admin/language/uk-ua/common', '2020-03-30 11:13:54'),
(6, 1, 'admin/language/uk-ua/customer', '2020-03-30 11:13:54'),
(7, 1, 'admin/language/uk-ua/cyberstore', '2020-03-30 11:13:54'),
(8, 1, 'admin/language/uk-ua/design', '2020-03-30 11:13:54'),
(9, 1, 'admin/language/uk-ua/error', '2020-03-30 11:13:54'),
(10, 1, 'admin/language/uk-ua/extension', '2020-03-30 11:13:54'),
(11, 1, 'admin/language/uk-ua/howto', '2020-03-30 11:13:54'),
(12, 1, 'admin/language/uk-ua/localisation', '2020-03-30 11:13:54'),
(13, 1, 'admin/language/uk-ua/mail', '2020-03-30 11:13:54'),
(14, 1, 'admin/language/uk-ua/marketing', '2020-03-30 11:13:54'),
(15, 1, 'admin/language/uk-ua/marketplace', '2020-03-30 11:13:54'),
(16, 1, 'admin/language/uk-ua/report', '2020-03-30 11:13:54'),
(17, 1, 'admin/language/uk-ua/sale', '2020-03-30 11:13:54'),
(18, 1, 'admin/language/uk-ua/search', '2020-03-30 11:13:54'),
(19, 1, 'admin/language/uk-ua/setting', '2020-03-30 11:13:54'),
(20, 1, 'admin/language/uk-ua/tool', '2020-03-30 11:13:54'),
(21, 1, 'admin/language/uk-ua/uk-ua.php', '2020-03-30 11:13:54'),
(22, 1, 'admin/language/uk-ua/uk-ua.png', '2020-03-30 11:13:54'),
(23, 1, 'admin/language/uk-ua/unishop', '2020-03-30 11:13:54'),
(24, 1, 'admin/language/uk-ua/user', '2020-03-30 11:13:54'),
(25, 1, 'catalog/language/uk-ua/account', '2020-03-30 11:13:54'),
(26, 1, 'catalog/language/uk-ua/affiliate', '2020-03-30 11:13:54'),
(27, 1, 'catalog/language/uk-ua/api', '2020-03-30 11:13:54'),
(28, 1, 'catalog/language/uk-ua/blog', '2020-03-30 11:13:54'),
(29, 1, 'catalog/language/uk-ua/checkout', '2020-03-30 11:13:54'),
(30, 1, 'catalog/language/uk-ua/common', '2020-03-30 11:13:54'),
(31, 1, 'catalog/language/uk-ua/cyberstore', '2020-03-30 11:13:54'),
(32, 1, 'catalog/language/uk-ua/error', '2020-03-30 11:13:54'),
(33, 1, 'catalog/language/uk-ua/extension', '2020-03-30 11:13:54'),
(34, 1, 'catalog/language/uk-ua/information', '2020-03-30 11:13:54'),
(35, 1, 'catalog/language/uk-ua/mail', '2020-03-30 11:13:54'),
(36, 1, 'catalog/language/uk-ua/module', '2020-03-30 11:13:54'),
(37, 1, 'catalog/language/uk-ua/product', '2020-03-30 11:13:54'),
(38, 1, 'catalog/language/uk-ua/tool', '2020-03-30 11:13:54'),
(39, 1, 'catalog/language/uk-ua/uk-ua.php', '2020-03-30 11:13:54'),
(40, 1, 'catalog/language/uk-ua/uk-ua.png', '2020-03-30 11:13:54'),
(41, 1, 'catalog/language/uk-ua/unishop', '2020-03-30 11:13:54'),
(42, 1, 'admin/language/uk-ua/blog/article.php', '2020-03-30 11:13:54'),
(43, 1, 'admin/language/uk-ua/blog/category.php', '2020-03-30 11:13:54'),
(44, 1, 'admin/language/uk-ua/blog/review.php', '2020-03-30 11:13:54'),
(45, 1, 'admin/language/uk-ua/blog/setting.php', '2020-03-30 11:13:54'),
(46, 1, 'admin/language/uk-ua/catalog/attribute.php', '2020-03-30 11:13:54'),
(47, 1, 'admin/language/uk-ua/catalog/attribute_group.php', '2020-03-30 11:13:54'),
(48, 1, 'admin/language/uk-ua/catalog/category.php', '2020-03-30 11:13:54'),
(49, 1, 'admin/language/uk-ua/catalog/download.php', '2020-03-30 11:13:54'),
(50, 1, 'admin/language/uk-ua/catalog/filter.php', '2020-03-30 11:13:54'),
(51, 1, 'admin/language/uk-ua/catalog/information.php', '2020-03-30 11:13:54'),
(52, 1, 'admin/language/uk-ua/catalog/manufacturer.php', '2020-03-30 11:13:54'),
(53, 1, 'admin/language/uk-ua/catalog/ocfilter.php', '2020-03-30 11:13:54'),
(54, 1, 'admin/language/uk-ua/catalog/ocfilter_page.php', '2020-03-30 11:13:54'),
(55, 1, 'admin/language/uk-ua/catalog/option.php', '2020-03-30 11:13:54'),
(56, 1, 'admin/language/uk-ua/catalog/product.php', '2020-03-30 11:13:54'),
(57, 1, 'admin/language/uk-ua/catalog/product_tabs.php', '2020-03-30 11:13:54'),
(58, 1, 'admin/language/uk-ua/catalog/recurring.php', '2020-03-30 11:13:54'),
(59, 1, 'admin/language/uk-ua/catalog/review.php', '2020-03-30 11:13:54'),
(60, 1, 'admin/language/uk-ua/catalog/reviews_store.php', '2020-03-30 11:13:54'),
(61, 1, 'admin/language/uk-ua/common/column_left.php', '2020-03-30 11:13:54'),
(62, 1, 'admin/language/uk-ua/common/dashboard.php', '2020-03-30 11:13:54'),
(63, 1, 'admin/language/uk-ua/common/developer.php', '2020-03-30 11:13:54'),
(64, 1, 'admin/language/uk-ua/common/filemanager.php', '2020-03-30 11:13:54'),
(65, 1, 'admin/language/uk-ua/common/footer.php', '2020-03-30 11:13:54'),
(66, 1, 'admin/language/uk-ua/common/forgotten.php', '2020-03-30 11:13:54'),
(67, 1, 'admin/language/uk-ua/common/header.php', '2020-03-30 11:13:54'),
(68, 1, 'admin/language/uk-ua/common/login.php', '2020-03-30 11:13:54'),
(69, 1, 'admin/language/uk-ua/common/profile.php', '2020-03-30 11:13:54'),
(70, 1, 'admin/language/uk-ua/common/reset.php', '2020-03-30 11:13:54'),
(71, 1, 'admin/language/uk-ua/common/security.php', '2020-03-30 11:13:54'),
(72, 1, 'admin/language/uk-ua/common/stats.php', '2020-03-30 11:13:54'),
(73, 1, 'admin/language/uk-ua/customer/custom_field.php', '2020-03-30 11:13:54'),
(74, 1, 'admin/language/uk-ua/customer/customer.php', '2020-03-30 11:13:54'),
(75, 1, 'admin/language/uk-ua/customer/customer_approval.php', '2020-03-30 11:13:54'),
(76, 1, 'admin/language/uk-ua/customer/customer_group.php', '2020-03-30 11:13:54'),
(77, 1, 'admin/language/uk-ua/customer/gdpr.php', '2020-03-30 11:13:54'),
(78, 1, 'admin/language/uk-ua/cyberstore/cyberstoredemo.php', '2020-03-30 11:13:54'),
(79, 1, 'admin/language/uk-ua/design/banner.php', '2020-03-30 11:13:54'),
(80, 1, 'admin/language/uk-ua/design/benefit.php', '2020-03-30 11:13:54'),
(81, 1, 'admin/language/uk-ua/design/custommenu.php', '2020-03-30 11:13:54'),
(82, 1, 'admin/language/uk-ua/design/language.php', '2020-03-30 11:13:54'),
(83, 1, 'admin/language/uk-ua/design/layout.php', '2020-03-30 11:13:54'),
(84, 1, 'admin/language/uk-ua/design/menu.php', '2020-03-30 11:13:54'),
(85, 1, 'admin/language/uk-ua/design/seo_regex.php', '2020-03-30 11:13:54'),
(86, 1, 'admin/language/uk-ua/design/seo_url.php', '2020-03-30 11:13:54'),
(87, 1, 'admin/language/uk-ua/design/sticker.php', '2020-03-30 11:13:54'),
(88, 1, 'admin/language/uk-ua/design/theme.php', '2020-03-30 11:13:54'),
(89, 1, 'admin/language/uk-ua/design/translation.php', '2020-03-30 11:13:54'),
(90, 1, 'admin/language/uk-ua/error/not_found.php', '2020-03-30 11:13:54'),
(91, 1, 'admin/language/uk-ua/error/permission.php', '2020-03-30 11:13:54'),
(92, 1, 'admin/language/uk-ua/extension/advertise', '2020-03-30 11:13:54'),
(93, 1, 'admin/language/uk-ua/extension/analytics', '2020-03-30 11:13:54'),
(94, 1, 'admin/language/uk-ua/extension/captcha', '2020-03-30 11:13:54'),
(95, 1, 'admin/language/uk-ua/extension/currency', '2020-03-30 11:13:54'),
(96, 1, 'admin/language/uk-ua/extension/dashboard', '2020-03-30 11:13:54'),
(97, 1, 'admin/language/uk-ua/extension/event.php', '2020-03-30 11:13:54'),
(98, 1, 'admin/language/uk-ua/extension/extension', '2020-03-30 11:13:54'),
(99, 1, 'admin/language/uk-ua/extension/extension.php', '2020-03-30 11:13:54'),
(100, 1, 'admin/language/uk-ua/extension/feed', '2020-03-30 11:13:54'),
(101, 1, 'admin/language/uk-ua/extension/fraud', '2020-03-30 11:13:54'),
(102, 1, 'admin/language/uk-ua/extension/installer.php', '2020-03-30 11:13:54'),
(103, 1, 'admin/language/uk-ua/extension/menu', '2020-03-30 11:13:54'),
(104, 1, 'admin/language/uk-ua/extension/modification.php', '2020-03-30 11:13:54'),
(105, 1, 'admin/language/uk-ua/extension/module', '2020-03-30 11:13:54'),
(106, 1, 'admin/language/uk-ua/extension/openbay', '2020-03-30 11:13:54'),
(107, 1, 'admin/language/uk-ua/extension/openbay.php', '2020-03-30 11:13:54'),
(108, 1, 'admin/language/uk-ua/extension/payment', '2020-03-30 11:13:54'),
(109, 1, 'admin/language/uk-ua/extension/report', '2020-03-30 11:13:54'),
(110, 1, 'admin/language/uk-ua/extension/shipping', '2020-03-30 11:13:54'),
(111, 1, 'admin/language/uk-ua/extension/store.php', '2020-03-30 11:13:54'),
(112, 1, 'admin/language/uk-ua/extension/theme', '2020-03-30 11:13:54'),
(113, 1, 'admin/language/uk-ua/extension/total', '2020-03-30 11:13:54'),
(114, 1, 'admin/language/uk-ua/howto/blogun.php', '2020-03-30 11:13:54'),
(115, 1, 'admin/language/uk-ua/howto/gogettop.php', '2020-03-30 11:13:54'),
(116, 1, 'admin/language/uk-ua/howto/howtosms.php', '2020-03-30 11:13:54'),
(117, 1, 'admin/language/uk-ua/howto/seopult.php', '2020-03-30 11:13:54'),
(118, 1, 'admin/language/uk-ua/localisation/country.php', '2020-03-30 11:13:54'),
(119, 1, 'admin/language/uk-ua/localisation/currency.php', '2020-03-30 11:13:54'),
(120, 1, 'admin/language/uk-ua/localisation/geo_zone.php', '2020-03-30 11:13:54'),
(121, 1, 'admin/language/uk-ua/localisation/language.php', '2020-03-30 11:13:54'),
(122, 1, 'admin/language/uk-ua/localisation/length_class.php', '2020-03-30 11:13:54'),
(123, 1, 'admin/language/uk-ua/localisation/location.php', '2020-03-30 11:13:54'),
(124, 1, 'admin/language/uk-ua/localisation/order_status.php', '2020-03-30 11:13:54'),
(125, 1, 'admin/language/uk-ua/localisation/return_action.php', '2020-03-30 11:13:54'),
(126, 1, 'admin/language/uk-ua/localisation/return_reason.php', '2020-03-30 11:13:54'),
(127, 1, 'admin/language/uk-ua/localisation/return_status.php', '2020-03-30 11:13:54'),
(128, 1, 'admin/language/uk-ua/localisation/stock_status.php', '2020-03-30 11:13:54'),
(129, 1, 'admin/language/uk-ua/localisation/tax_class.php', '2020-03-30 11:13:54'),
(130, 1, 'admin/language/uk-ua/localisation/tax_rate.php', '2020-03-30 11:13:54'),
(131, 1, 'admin/language/uk-ua/localisation/weight_class.php', '2020-03-30 11:13:54'),
(132, 1, 'admin/language/uk-ua/localisation/zone.php', '2020-03-30 11:13:54'),
(133, 1, 'admin/language/uk-ua/mail/affiliate.php', '2020-03-30 11:13:54'),
(134, 1, 'admin/language/uk-ua/mail/affiliate_approve.php', '2020-03-30 11:13:54'),
(135, 1, 'admin/language/uk-ua/mail/affiliate_deny.php', '2020-03-30 11:13:54'),
(136, 1, 'admin/language/uk-ua/mail/customer.php', '2020-03-30 11:13:54'),
(137, 1, 'admin/language/uk-ua/mail/customer_approve.php', '2020-03-30 11:13:54'),
(138, 1, 'admin/language/uk-ua/mail/customer_deny.php', '2020-03-30 11:13:54'),
(139, 1, 'admin/language/uk-ua/mail/forgotten.php', '2020-03-30 11:13:54'),
(140, 1, 'admin/language/uk-ua/mail/gdpr_approve.php', '2020-03-30 11:13:54'),
(141, 1, 'admin/language/uk-ua/mail/gdpr_delete.php', '2020-03-30 11:13:54'),
(142, 1, 'admin/language/uk-ua/mail/gdpr_deny.php', '2020-03-30 11:13:54'),
(143, 1, 'admin/language/uk-ua/mail/gdpr_export.php', '2020-03-30 11:13:54'),
(144, 1, 'admin/language/uk-ua/mail/return.php', '2020-03-30 11:13:54'),
(145, 1, 'admin/language/uk-ua/mail/reward.php', '2020-03-30 11:13:54'),
(146, 1, 'admin/language/uk-ua/mail/transaction.php', '2020-03-30 11:13:54'),
(147, 1, 'admin/language/uk-ua/mail/voucher.php', '2020-03-30 11:13:54'),
(148, 1, 'admin/language/uk-ua/marketing/affiliate.php', '2020-03-30 11:13:54'),
(149, 1, 'admin/language/uk-ua/marketing/contact.php', '2020-03-30 11:13:54'),
(150, 1, 'admin/language/uk-ua/marketing/coupon.php', '2020-03-30 11:13:54'),
(151, 1, 'admin/language/uk-ua/marketing/marketing.php', '2020-03-30 11:13:54'),
(152, 1, 'admin/language/uk-ua/marketing/newsletter.php', '2020-03-30 11:13:54'),
(153, 1, 'admin/language/uk-ua/marketplace/api.php', '2020-03-30 11:13:54'),
(154, 1, 'admin/language/uk-ua/marketplace/cron.php', '2020-03-30 11:13:54'),
(155, 1, 'admin/language/uk-ua/marketplace/event.php', '2020-03-30 11:13:54'),
(156, 1, 'admin/language/uk-ua/marketplace/extension.php', '2020-03-30 11:13:54'),
(157, 1, 'admin/language/uk-ua/marketplace/install.php', '2020-03-30 11:13:54'),
(158, 1, 'admin/language/uk-ua/marketplace/installer.php', '2020-03-30 11:13:54'),
(159, 1, 'admin/language/uk-ua/marketplace/marketplace.php', '2020-03-30 11:13:54'),
(160, 1, 'admin/language/uk-ua/marketplace/modification.php', '2020-03-30 11:13:54'),
(161, 1, 'admin/language/uk-ua/marketplace/openbay.php', '2020-03-30 11:13:54'),
(162, 1, 'admin/language/uk-ua/marketplace/opencartforum.php', '2020-03-30 11:13:54'),
(163, 1, 'admin/language/uk-ua/report/online.php', '2020-03-30 11:13:54'),
(164, 1, 'admin/language/uk-ua/report/report.php', '2020-03-30 11:13:54'),
(165, 1, 'admin/language/uk-ua/report/statistics.php', '2020-03-30 11:13:54'),
(166, 1, 'admin/language/uk-ua/sale/callback.php', '2020-03-30 11:13:54'),
(167, 1, 'admin/language/uk-ua/sale/newfastorder.php', '2020-03-30 11:13:54'),
(168, 1, 'admin/language/uk-ua/sale/order.php', '2020-03-30 11:13:54'),
(169, 1, 'admin/language/uk-ua/sale/recurring.php', '2020-03-30 11:13:54'),
(170, 1, 'admin/language/uk-ua/sale/return.php', '2020-03-30 11:13:54'),
(171, 1, 'admin/language/uk-ua/sale/voucher.php', '2020-03-30 11:13:54'),
(172, 1, 'admin/language/uk-ua/sale/voucher_theme.php', '2020-03-30 11:13:54'),
(173, 1, 'admin/language/uk-ua/search/search.php', '2020-03-30 11:13:54'),
(174, 1, 'admin/language/uk-ua/setting/setting.php', '2020-03-30 11:13:54'),
(175, 1, 'admin/language/uk-ua/setting/store.php', '2020-03-30 11:13:54'),
(176, 1, 'admin/language/uk-ua/tool/backup.php', '2020-03-30 11:13:54'),
(177, 1, 'admin/language/uk-ua/tool/log.php', '2020-03-30 11:13:54'),
(178, 1, 'admin/language/uk-ua/tool/seomanager.php', '2020-03-30 11:13:54'),
(179, 1, 'admin/language/uk-ua/tool/upgrade.php', '2020-03-30 11:13:54'),
(180, 1, 'admin/language/uk-ua/tool/upload.php', '2020-03-30 11:13:54'),
(181, 1, 'admin/language/uk-ua/unishop/request.php', '2020-03-30 11:13:54'),
(182, 1, 'admin/language/uk-ua/user/api.php', '2020-03-30 11:13:54'),
(183, 1, 'admin/language/uk-ua/user/user.php', '2020-03-30 11:13:54'),
(184, 1, 'admin/language/uk-ua/user/user_group.php', '2020-03-30 11:13:54'),
(185, 1, 'catalog/language/uk-ua/account/account.php', '2020-03-30 11:13:54'),
(186, 1, 'catalog/language/uk-ua/account/address.php', '2020-03-30 11:13:54'),
(187, 1, 'catalog/language/uk-ua/account/affiliate.php', '2020-03-30 11:13:54'),
(188, 1, 'catalog/language/uk-ua/account/download.php', '2020-03-30 11:13:54'),
(189, 1, 'catalog/language/uk-ua/account/edit.php', '2020-03-30 11:13:54'),
(190, 1, 'catalog/language/uk-ua/account/forgotten.php', '2020-03-30 11:13:54'),
(191, 1, 'catalog/language/uk-ua/account/login.php', '2020-03-30 11:13:54'),
(192, 1, 'catalog/language/uk-ua/account/logout.php', '2020-03-30 11:13:54'),
(193, 1, 'catalog/language/uk-ua/account/newsletter.php', '2020-03-30 11:13:54'),
(194, 1, 'catalog/language/uk-ua/account/order.php', '2020-03-30 11:13:54'),
(195, 1, 'catalog/language/uk-ua/account/password.php', '2020-03-30 11:13:54'),
(196, 1, 'catalog/language/uk-ua/account/recurring.php', '2020-03-30 11:13:54'),
(197, 1, 'catalog/language/uk-ua/account/register.php', '2020-03-30 11:13:54'),
(198, 1, 'catalog/language/uk-ua/account/reset.php', '2020-03-30 11:13:54'),
(199, 1, 'catalog/language/uk-ua/account/return.php', '2020-03-30 11:13:54'),
(200, 1, 'catalog/language/uk-ua/account/reward.php', '2020-03-30 11:13:54'),
(201, 1, 'catalog/language/uk-ua/account/simpleregister.php', '2020-03-30 11:13:54'),
(202, 1, 'catalog/language/uk-ua/account/success.php', '2020-03-30 11:13:54'),
(203, 1, 'catalog/language/uk-ua/account/tracking.php', '2020-03-30 11:13:54'),
(204, 1, 'catalog/language/uk-ua/account/transaction.php', '2020-03-30 11:13:54'),
(205, 1, 'catalog/language/uk-ua/account/voucher.php', '2020-03-30 11:13:54'),
(206, 1, 'catalog/language/uk-ua/account/wishlist.php', '2020-03-30 11:13:54'),
(207, 1, 'catalog/language/uk-ua/affiliate/account.php', '2020-03-30 11:13:54'),
(208, 1, 'catalog/language/uk-ua/affiliate/edit.php', '2020-03-30 11:13:54'),
(209, 1, 'catalog/language/uk-ua/affiliate/forgotten.php', '2020-03-30 11:13:54'),
(210, 1, 'catalog/language/uk-ua/affiliate/login.php', '2020-03-30 11:13:54'),
(211, 1, 'catalog/language/uk-ua/affiliate/logout.php', '2020-03-30 11:13:54'),
(212, 1, 'catalog/language/uk-ua/affiliate/password.php', '2020-03-30 11:13:54'),
(213, 1, 'catalog/language/uk-ua/affiliate/payment.php', '2020-03-30 11:13:54'),
(214, 1, 'catalog/language/uk-ua/affiliate/register.php', '2020-03-30 11:13:54'),
(215, 1, 'catalog/language/uk-ua/affiliate/success.php', '2020-03-30 11:13:54'),
(216, 1, 'catalog/language/uk-ua/affiliate/tracking.php', '2020-03-30 11:13:54'),
(217, 1, 'catalog/language/uk-ua/affiliate/transaction.php', '2020-03-30 11:13:54'),
(218, 1, 'catalog/language/uk-ua/api/cart.php', '2020-03-30 11:13:54'),
(219, 1, 'catalog/language/uk-ua/api/coupon.php', '2020-03-30 11:13:54'),
(220, 1, 'catalog/language/uk-ua/api/currency.php', '2020-03-30 11:13:54'),
(221, 1, 'catalog/language/uk-ua/api/customer.php', '2020-03-30 11:13:54'),
(222, 1, 'catalog/language/uk-ua/api/login.php', '2020-03-30 11:13:54'),
(223, 1, 'catalog/language/uk-ua/api/order.php', '2020-03-30 11:13:54'),
(224, 1, 'catalog/language/uk-ua/api/payment.php', '2020-03-30 11:13:54'),
(225, 1, 'catalog/language/uk-ua/api/reward.php', '2020-03-30 11:13:54'),
(226, 1, 'catalog/language/uk-ua/api/shipping.php', '2020-03-30 11:13:54'),
(227, 1, 'catalog/language/uk-ua/api/voucher.php', '2020-03-30 11:13:54'),
(228, 1, 'catalog/language/uk-ua/blog/article.php', '2020-03-30 11:13:54'),
(229, 1, 'catalog/language/uk-ua/blog/category.php', '2020-03-30 11:13:54'),
(230, 1, 'catalog/language/uk-ua/blog/latest.php', '2020-03-30 11:13:54'),
(231, 1, 'catalog/language/uk-ua/blog/mail', '2020-03-30 11:13:54'),
(232, 1, 'catalog/language/uk-ua/blog/menu.php', '2020-03-30 11:13:54'),
(233, 1, 'catalog/language/uk-ua/checkout/cart.php', '2020-03-30 11:13:54'),
(234, 1, 'catalog/language/uk-ua/checkout/checkout.php', '2020-03-30 11:13:54'),
(235, 1, 'catalog/language/uk-ua/checkout/failure.php', '2020-03-30 11:13:54'),
(236, 1, 'catalog/language/uk-ua/checkout/simplecheckout.php', '2020-03-30 11:13:54'),
(237, 1, 'catalog/language/uk-ua/checkout/success.php', '2020-03-30 11:13:54'),
(238, 1, 'catalog/language/uk-ua/common/cart.php', '2020-03-30 11:13:54'),
(239, 1, 'catalog/language/uk-ua/common/cookie.php', '2020-03-30 11:13:54'),
(240, 1, 'catalog/language/uk-ua/common/currency.php', '2020-03-30 11:13:54'),
(241, 1, 'catalog/language/uk-ua/common/filemanagernew.php', '2020-03-30 11:13:54'),
(242, 1, 'catalog/language/uk-ua/common/footer.php', '2020-03-30 11:13:54'),
(243, 1, 'catalog/language/uk-ua/common/header.php', '2020-03-30 11:13:54'),
(244, 1, 'catalog/language/uk-ua/common/language.php', '2020-03-30 11:13:54'),
(245, 1, 'catalog/language/uk-ua/common/maintenance.php', '2020-03-30 11:13:54'),
(246, 1, 'catalog/language/uk-ua/common/menu.php', '2020-03-30 11:13:54'),
(247, 1, 'catalog/language/uk-ua/common/search.php', '2020-03-30 11:13:54'),
(248, 1, 'catalog/language/uk-ua/cyberstore/lang.php', '2020-03-30 11:13:54'),
(249, 1, 'catalog/language/uk-ua/error/not_found.php', '2020-03-30 11:13:54'),
(250, 1, 'catalog/language/uk-ua/extension/advertise', '2020-03-30 11:13:54'),
(251, 1, 'catalog/language/uk-ua/extension/captcha', '2020-03-30 11:13:54'),
(252, 1, 'catalog/language/uk-ua/extension/credit_card', '2020-03-30 11:13:54'),
(253, 1, 'catalog/language/uk-ua/extension/module', '2020-03-30 11:13:54'),
(254, 1, 'catalog/language/uk-ua/extension/openbay', '2020-03-30 11:13:54'),
(255, 1, 'catalog/language/uk-ua/extension/payment', '2020-03-30 11:13:54'),
(256, 1, 'catalog/language/uk-ua/extension/recurring', '2020-03-30 11:13:54'),
(257, 1, 'catalog/language/uk-ua/extension/shipping', '2020-03-30 11:13:54'),
(258, 1, 'catalog/language/uk-ua/extension/total', '2020-03-30 11:13:54'),
(259, 1, 'catalog/language/uk-ua/information/contact.php', '2020-03-30 11:13:54'),
(260, 1, 'catalog/language/uk-ua/information/information.php', '2020-03-30 11:13:54'),
(261, 1, 'catalog/language/uk-ua/information/sitemap.php', '2020-03-30 11:13:54'),
(262, 1, 'catalog/language/uk-ua/information/tracking.php', '2020-03-30 11:13:54'),
(263, 1, 'catalog/language/uk-ua/information/uni_news.php', '2020-03-30 11:13:54'),
(264, 1, 'catalog/language/uk-ua/mail/affiliate.php', '2020-03-30 11:13:54'),
(265, 1, 'catalog/language/uk-ua/mail/customer.php', '2020-03-30 11:13:54'),
(266, 1, 'catalog/language/uk-ua/mail/forgotten.php', '2020-03-30 11:13:54'),
(267, 1, 'catalog/language/uk-ua/mail/order.php', '2020-03-30 11:13:54'),
(268, 1, 'catalog/language/uk-ua/mail/order_add.php', '2020-03-30 11:13:54'),
(269, 1, 'catalog/language/uk-ua/mail/order_alert.php', '2020-03-30 11:13:54'),
(270, 1, 'catalog/language/uk-ua/mail/order_edit.php', '2020-03-30 11:13:54'),
(271, 1, 'catalog/language/uk-ua/mail/register.php', '2020-03-30 11:13:54'),
(272, 1, 'catalog/language/uk-ua/mail/review.php', '2020-03-30 11:13:54'),
(273, 1, 'catalog/language/uk-ua/mail/transaction.php', '2020-03-30 11:13:54'),
(274, 1, 'catalog/language/uk-ua/mail/voucher.php', '2020-03-30 11:13:54'),
(275, 1, 'catalog/language/uk-ua/module/amazon_login.php', '2020-03-30 11:13:54'),
(276, 1, 'catalog/language/uk-ua/module/amazon_pay.php', '2020-03-30 11:13:54'),
(277, 1, 'catalog/language/uk-ua/module/groupeditor', '2020-03-30 11:13:54'),
(278, 1, 'catalog/language/uk-ua/product/bestseller.php', '2020-03-30 11:13:54'),
(279, 1, 'catalog/language/uk-ua/product/category.php', '2020-03-30 11:13:54'),
(280, 1, 'catalog/language/uk-ua/product/compare.php', '2020-03-30 11:13:54'),
(281, 1, 'catalog/language/uk-ua/product/cyber_latestpage.php', '2020-03-30 11:13:54'),
(282, 1, 'catalog/language/uk-ua/product/cyber_reviews_store.php', '2020-03-30 11:13:54'),
(283, 1, 'catalog/language/uk-ua/product/latest.php', '2020-03-30 11:13:54'),
(284, 1, 'catalog/language/uk-ua/product/manufacturer.php', '2020-03-30 11:13:54'),
(285, 1, 'catalog/language/uk-ua/product/mostviewed.php', '2020-03-30 11:13:54'),
(286, 1, 'catalog/language/uk-ua/product/product.php', '2020-03-30 11:13:54'),
(287, 1, 'catalog/language/uk-ua/product/product_quick.php', '2020-03-30 11:13:54'),
(288, 1, 'catalog/language/uk-ua/product/search.php', '2020-03-30 11:13:54'),
(289, 1, 'catalog/language/uk-ua/product/special.php', '2020-03-30 11:13:54'),
(290, 1, 'catalog/language/uk-ua/product/uni_reviews.php', '2020-03-30 11:13:54'),
(291, 1, 'catalog/language/uk-ua/tool/simpleapi.php', '2020-03-30 11:13:54'),
(292, 1, 'catalog/language/uk-ua/tool/upload.php', '2020-03-30 11:13:54'),
(293, 1, 'catalog/language/uk-ua/unishop/request.php', '2020-03-30 11:13:54'),
(294, 1, 'catalog/language/uk-ua/unishop/unishop.php', '2020-03-30 11:13:54'),
(295, 1, 'admin/language/uk-ua/extension/advertise/google.php', '2020-03-30 11:13:54'),
(296, 1, 'admin/language/uk-ua/extension/analytics/google.php', '2020-03-30 11:13:54'),
(297, 1, 'admin/language/uk-ua/extension/analytics/google_analytics.php', '2020-03-30 11:13:54'),
(298, 1, 'admin/language/uk-ua/extension/captcha/basic.php', '2020-03-30 11:13:54'),
(299, 1, 'admin/language/uk-ua/extension/captcha/basic_captcha.php', '2020-03-30 11:13:54'),
(300, 1, 'admin/language/uk-ua/extension/captcha/google.php', '2020-03-30 11:13:54'),
(301, 1, 'admin/language/uk-ua/extension/captcha/google_captcha.php', '2020-03-30 11:13:54'),
(302, 1, 'admin/language/uk-ua/extension/currency/ecb.php', '2020-03-30 11:13:54'),
(303, 1, 'admin/language/uk-ua/extension/currency/fixer.php', '2020-03-30 11:13:54'),
(304, 1, 'admin/language/uk-ua/extension/dashboard/activity.php', '2020-03-30 11:13:54'),
(305, 1, 'admin/language/uk-ua/extension/dashboard/chart.php', '2020-03-30 11:13:54'),
(306, 1, 'admin/language/uk-ua/extension/dashboard/customer.php', '2020-03-30 11:13:54'),
(307, 1, 'admin/language/uk-ua/extension/dashboard/map.php', '2020-03-30 11:13:54'),
(308, 1, 'admin/language/uk-ua/extension/dashboard/online.php', '2020-03-30 11:13:54'),
(309, 1, 'admin/language/uk-ua/extension/dashboard/order.php', '2020-03-30 11:13:54'),
(310, 1, 'admin/language/uk-ua/extension/dashboard/recent.php', '2020-03-30 11:13:54'),
(311, 1, 'admin/language/uk-ua/extension/dashboard/sale.php', '2020-03-30 11:13:54'),
(312, 1, 'admin/language/uk-ua/extension/extension/advertise.php', '2020-03-30 11:13:54'),
(313, 1, 'admin/language/uk-ua/extension/extension/analytics.php', '2020-03-30 11:13:54'),
(314, 1, 'admin/language/uk-ua/extension/extension/captcha.php', '2020-03-30 11:13:54'),
(315, 1, 'admin/language/uk-ua/extension/extension/currency.php', '2020-03-30 11:13:54'),
(316, 1, 'admin/language/uk-ua/extension/extension/dashboard.php', '2020-03-30 11:13:54'),
(317, 1, 'admin/language/uk-ua/extension/extension/feed.php', '2020-03-30 11:13:54'),
(318, 1, 'admin/language/uk-ua/extension/extension/fraud.php', '2020-03-30 11:13:54'),
(319, 1, 'admin/language/uk-ua/extension/extension/marketing.php', '2020-03-30 11:13:54'),
(320, 1, 'admin/language/uk-ua/extension/extension/menu.php', '2020-03-30 11:13:54'),
(321, 1, 'admin/language/uk-ua/extension/extension/module.php', '2020-03-30 11:13:54'),
(322, 1, 'admin/language/uk-ua/extension/extension/openbay.php', '2020-03-30 11:13:54'),
(323, 1, 'admin/language/uk-ua/extension/extension/other.php', '2020-03-30 11:13:54'),
(324, 1, 'admin/language/uk-ua/extension/extension/payment.php', '2020-03-30 11:13:54'),
(325, 1, 'admin/language/uk-ua/extension/extension/promotion.php', '2020-03-30 11:13:54'),
(326, 1, 'admin/language/uk-ua/extension/extension/report.php', '2020-03-30 11:13:54'),
(327, 1, 'admin/language/uk-ua/extension/extension/shipping.php', '2020-03-30 11:13:54'),
(328, 1, 'admin/language/uk-ua/extension/extension/theme.php', '2020-03-30 11:13:54'),
(329, 1, 'admin/language/uk-ua/extension/extension/total.php', '2020-03-30 11:13:54'),
(330, 1, 'admin/language/uk-ua/extension/feed/google_base.php', '2020-03-30 11:13:54'),
(331, 1, 'admin/language/uk-ua/extension/feed/google_sitemap.php', '2020-03-30 11:13:54'),
(332, 1, 'admin/language/uk-ua/extension/feed/openbaypro.php', '2020-03-30 11:13:54'),
(333, 1, 'admin/language/uk-ua/extension/feed/unisender.php', '2020-03-30 11:13:54'),
(334, 1, 'admin/language/uk-ua/extension/feed/yandex_market.php', '2020-03-30 11:13:54'),
(335, 1, 'admin/language/uk-ua/extension/feed/yandex_turbo.php', '2020-03-30 11:13:54'),
(336, 1, 'admin/language/uk-ua/extension/fraud/fraudlabspro.php', '2020-03-30 11:13:54'),
(337, 1, 'admin/language/uk-ua/extension/fraud/ip.php', '2020-03-30 11:13:54'),
(338, 1, 'admin/language/uk-ua/extension/fraud/maxmind.php', '2020-03-30 11:13:54'),
(339, 1, 'admin/language/uk-ua/extension/menu/default.php', '2020-03-30 11:13:54'),
(340, 1, 'admin/language/uk-ua/extension/module/account.php', '2020-03-30 11:13:54'),
(341, 1, 'admin/language/uk-ua/extension/module/affiliate.php', '2020-03-30 11:13:54'),
(342, 1, 'admin/language/uk-ua/extension/module/amazon_login.php', '2020-03-30 11:13:54'),
(343, 1, 'admin/language/uk-ua/extension/module/amazon_pay.php', '2020-03-30 11:13:54'),
(344, 1, 'admin/language/uk-ua/extension/module/banner.php', '2020-03-30 11:13:54'),
(345, 1, 'admin/language/uk-ua/extension/module/bestseller.php', '2020-03-30 11:13:54'),
(346, 1, 'admin/language/uk-ua/extension/module/blog_category.php', '2020-03-30 11:13:54'),
(347, 1, 'admin/language/uk-ua/extension/module/blog_featured.php', '2020-03-30 11:13:54'),
(348, 1, 'admin/language/uk-ua/extension/module/blog_latest.php', '2020-03-30 11:13:54'),
(349, 1, 'admin/language/uk-ua/extension/module/carousel.php', '2020-03-30 11:13:54'),
(350, 1, 'admin/language/uk-ua/extension/module/category.php', '2020-03-30 11:13:54'),
(351, 1, 'admin/language/uk-ua/extension/module/category4level.php', '2020-03-30 11:13:54'),
(352, 1, 'admin/language/uk-ua/extension/module/cyber_agree_popup.php', '2020-03-30 11:13:54'),
(353, 1, 'admin/language/uk-ua/extension/module/cyber_alltabs.php', '2020-03-30 11:13:54'),
(354, 1, 'admin/language/uk-ua/extension/module/cyber_autosearch.php', '2020-03-30 11:13:54'),
(355, 1, 'admin/language/uk-ua/extension/module/cyber_banner_blocks.php', '2020-03-30 11:13:54'),
(356, 1, 'admin/language/uk-ua/extension/module/cyber_editproduct.php', '2020-03-30 11:13:54'),
(357, 1, 'admin/language/uk-ua/extension/module/cyber_found_cheaper_product.php', '2020-03-30 11:13:54'),
(358, 1, 'admin/language/uk-ua/extension/module/cyber_latest_grid.php', '2020-03-30 11:13:54'),
(359, 1, 'admin/language/uk-ua/extension/module/cyber_megamenuvh.php', '2020-03-30 11:13:54'),
(360, 1, 'admin/language/uk-ua/extension/module/cyber_megasliderpro.php', '2020-03-30 11:13:54'),
(361, 1, 'admin/language/uk-ua/extension/module/cyber_myonepagecheckout.php', '2020-03-30 11:13:54'),
(362, 1, 'admin/language/uk-ua/extension/module/cyber_pro_sticker.php', '2020-03-30 11:13:54'),
(363, 1, 'admin/language/uk-ua/extension/module/cyber_product_categorytabs.php', '2020-03-30 11:13:54'),
(364, 1, 'admin/language/uk-ua/extension/module/cyber_product_tabs.php', '2020-03-30 11:13:54'),
(365, 1, 'admin/language/uk-ua/extension/module/cyber_productany.php', '2020-03-30 11:13:54'),
(366, 1, 'admin/language/uk-ua/extension/module/cyber_productviewed.php', '2020-03-30 11:13:54'),
(367, 1, 'admin/language/uk-ua/extension/module/cyber_question_answer.php', '2020-03-30 11:13:54'),
(368, 1, 'admin/language/uk-ua/extension/module/cyber_quickviewpro.php', '2020-03-30 11:13:54'),
(369, 1, 'admin/language/uk-ua/extension/module/cyber_reviews_store.php', '2020-03-30 11:13:54'),
(370, 1, 'admin/language/uk-ua/extension/module/cyber_reviewscustomer.php', '2020-03-30 11:13:54'),
(371, 1, 'admin/language/uk-ua/extension/module/cyber_setting_theme.php', '2020-03-30 11:13:54'),
(372, 1, 'admin/language/uk-ua/extension/module/cyber_slidedeals.php', '2020-03-30 11:13:54'),
(373, 1, 'admin/language/uk-ua/extension/module/cyber_slideshowcategory.php', '2020-03-30 11:13:54'),
(374, 1, 'admin/language/uk-ua/extension/module/cyber_ut5setting.php', '2020-03-30 11:13:54'),
(375, 1, 'admin/language/uk-ua/extension/module/cyber_wallbrand.php', '2020-03-30 11:13:54'),
(376, 1, 'admin/language/uk-ua/extension/module/cyber_wallcategory.php', '2020-03-30 11:13:54'),
(377, 1, 'admin/language/uk-ua/extension/module/divido_calculator.php', '2020-03-30 11:13:54'),
(378, 1, 'admin/language/uk-ua/extension/module/dream_filter.php', '2020-03-30 11:13:54'),
(379, 1, 'admin/language/uk-ua/extension/module/ebay_listing.php', '2020-03-30 11:13:54'),
(380, 1, 'admin/language/uk-ua/extension/module/featured.php', '2020-03-30 11:13:54'),
(381, 1, 'admin/language/uk-ua/extension/module/featured_article.php', '2020-03-30 11:13:54'),
(382, 1, 'admin/language/uk-ua/extension/module/featured_product.php', '2020-03-30 11:13:54'),
(383, 1, 'admin/language/uk-ua/extension/module/filter.php', '2020-03-30 11:13:54'),
(384, 1, 'admin/language/uk-ua/extension/module/gdpr.php', '2020-03-30 11:13:54'),
(385, 1, 'admin/language/uk-ua/extension/module/google_hangouts.php', '2020-03-30 11:13:54'),
(386, 1, 'admin/language/uk-ua/extension/module/html.php', '2020-03-30 11:13:54'),
(387, 1, 'admin/language/uk-ua/extension/module/imgcategory.php', '2020-03-30 11:13:54'),
(388, 1, 'admin/language/uk-ua/extension/module/information.php', '2020-03-30 11:13:54'),
(389, 1, 'admin/language/uk-ua/extension/module/klarna_checkout_module.php', '2020-03-30 11:13:54'),
(390, 1, 'admin/language/uk-ua/extension/module/latest.php', '2020-03-30 11:13:54'),
(391, 1, 'admin/language/uk-ua/extension/module/laybuy_layout.php', '2020-03-30 11:13:54'),
(392, 1, 'admin/language/uk-ua/extension/module/manufacturer.php', '2020-03-30 11:13:54'),
(393, 1, 'admin/language/uk-ua/extension/module/ocfilter.php', '2020-03-30 11:13:54'),
(394, 1, 'admin/language/uk-ua/extension/module/pilibaba_button.php', '2020-03-30 11:13:54'),
(395, 1, 'admin/language/uk-ua/extension/module/popular.php', '2020-03-30 11:13:54'),
(396, 1, 'admin/language/uk-ua/extension/module/pp_braintree_button.php', '2020-03-30 11:13:54'),
(397, 1, 'admin/language/uk-ua/extension/module/pp_button.php', '2020-03-30 11:13:54'),
(398, 1, 'admin/language/uk-ua/extension/module/pp_login.php', '2020-03-30 11:13:54'),
(399, 1, 'admin/language/uk-ua/extension/module/product_tab.php', '2020-03-30 11:13:54'),
(400, 1, 'admin/language/uk-ua/extension/module/progroman_city_manager.php', '2020-03-30 11:13:54'),
(401, 1, 'admin/language/uk-ua/extension/module/sagepay_direct_cards.php', '2020-03-30 11:13:54'),
(402, 1, 'admin/language/uk-ua/extension/module/sagepay_server_cards.php', '2020-03-30 11:13:54'),
(403, 1, 'admin/language/uk-ua/extension/module/simple.php', '2020-03-30 11:13:54'),
(404, 1, 'admin/language/uk-ua/extension/module/slideshow.php', '2020-03-30 11:13:54'),
(405, 1, 'admin/language/uk-ua/extension/module/special.php', '2020-03-30 11:13:54'),
(406, 1, 'admin/language/uk-ua/extension/module/store.php', '2020-03-30 11:13:54'),
(407, 1, 'admin/language/uk-ua/extension/module/uni_banner_in_category.php', '2020-03-30 11:13:54'),
(408, 1, 'admin/language/uk-ua/extension/module/uni_custom_menu.php', '2020-03-30 11:13:54'),
(409, 1, 'admin/language/uk-ua/extension/module/uni_gallery.php', '2020-03-30 11:13:54'),
(410, 1, 'admin/language/uk-ua/extension/module/uni_manufacturer.php', '2020-03-30 11:13:54'),
(411, 1, 'admin/language/uk-ua/extension/module/uni_news.php', '2020-03-30 11:13:54'),
(412, 1, 'admin/language/uk-ua/extension/module/uni_reviews.php', '2020-03-30 11:13:54'),
(413, 1, 'admin/language/uk-ua/extension/module/uni_settings.php', '2020-03-30 11:13:54'),
(414, 1, 'admin/language/uk-ua/extension/module/uni_tabs.php', '2020-03-30 11:13:54'),
(415, 1, 'admin/language/uk-ua/extension/module/uni_viewed.php', '2020-03-30 11:13:54'),
(416, 1, 'admin/language/uk-ua/extension/openbay/amazon.php', '2020-03-30 11:13:54'),
(417, 1, 'admin/language/uk-ua/extension/openbay/amazon_bulk_linking.php', '2020-03-30 11:13:54'),
(418, 1, 'admin/language/uk-ua/extension/openbay/amazon_bulk_listing.php', '2020-03-30 11:13:54'),
(419, 1, 'admin/language/uk-ua/extension/openbay/amazon_links.php', '2020-03-30 11:13:54'),
(420, 1, 'admin/language/uk-ua/extension/openbay/amazon_listing.php', '2020-03-30 11:13:54'),
(421, 1, 'admin/language/uk-ua/extension/openbay/amazon_listingsaved.php', '2020-03-30 11:13:54'),
(422, 1, 'admin/language/uk-ua/extension/openbay/amazon_settings.php', '2020-03-30 11:13:54'),
(423, 1, 'admin/language/uk-ua/extension/openbay/amazon_stockupdates.php', '2020-03-30 11:13:54'),
(424, 1, 'admin/language/uk-ua/extension/openbay/amazon_subscription.php', '2020-03-30 11:13:54'),
(425, 1, 'admin/language/uk-ua/extension/openbay/amazonus.php', '2020-03-30 11:13:54'),
(426, 1, 'admin/language/uk-ua/extension/openbay/amazonus_bulk_linking.php', '2020-03-30 11:13:54'),
(427, 1, 'admin/language/uk-ua/extension/openbay/amazonus_bulk_listing.php', '2020-03-30 11:13:54'),
(428, 1, 'admin/language/uk-ua/extension/openbay/amazonus_links.php', '2020-03-30 11:13:54'),
(429, 1, 'admin/language/uk-ua/extension/openbay/amazonus_listing.php', '2020-03-30 11:13:54'),
(430, 1, 'admin/language/uk-ua/extension/openbay/amazonus_listingsaved.php', '2020-03-30 11:13:54'),
(431, 1, 'admin/language/uk-ua/extension/openbay/amazonus_settings.php', '2020-03-30 11:13:54'),
(432, 1, 'admin/language/uk-ua/extension/openbay/amazonus_stockupdates.php', '2020-03-30 11:13:54'),
(433, 1, 'admin/language/uk-ua/extension/openbay/amazonus_subscription.php', '2020-03-30 11:13:54'),
(434, 1, 'admin/language/uk-ua/extension/openbay/ebay.php', '2020-03-30 11:13:54'),
(435, 1, 'admin/language/uk-ua/extension/openbay/ebay_edit.php', '2020-03-30 11:13:54'),
(436, 1, 'admin/language/uk-ua/extension/openbay/ebay_import.php', '2020-03-30 11:13:54'),
(437, 1, 'admin/language/uk-ua/extension/openbay/ebay_links.php', '2020-03-30 11:13:54'),
(438, 1, 'admin/language/uk-ua/extension/openbay/ebay_new.php', '2020-03-30 11:13:54'),
(439, 1, 'admin/language/uk-ua/extension/openbay/ebay_newbulk.php', '2020-03-30 11:13:54'),
(440, 1, 'admin/language/uk-ua/extension/openbay/ebay_orders.php', '2020-03-30 11:13:54'),
(441, 1, 'admin/language/uk-ua/extension/openbay/ebay_profile.php', '2020-03-30 11:13:54'),
(442, 1, 'admin/language/uk-ua/extension/openbay/ebay_settings.php', '2020-03-30 11:13:54'),
(443, 1, 'admin/language/uk-ua/extension/openbay/ebay_subscription.php', '2020-03-30 11:13:54'),
(444, 1, 'admin/language/uk-ua/extension/openbay/ebay_summary.php', '2020-03-30 11:13:54'),
(445, 1, 'admin/language/uk-ua/extension/openbay/ebay_syncronise.php', '2020-03-30 11:13:54'),
(446, 1, 'admin/language/uk-ua/extension/openbay/ebay_template.php', '2020-03-30 11:13:54'),
(447, 1, 'admin/language/uk-ua/extension/openbay/ebay_usage.php', '2020-03-30 11:13:54'),
(448, 1, 'admin/language/uk-ua/extension/openbay/etsy.php', '2020-03-30 11:13:54'),
(449, 1, 'admin/language/uk-ua/extension/openbay/etsy_create.php', '2020-03-30 11:13:54'),
(450, 1, 'admin/language/uk-ua/extension/openbay/etsy_edit.php', '2020-03-30 11:13:54'),
(451, 1, 'admin/language/uk-ua/extension/openbay/etsy_links.php', '2020-03-30 11:13:54'),
(452, 1, 'admin/language/uk-ua/extension/openbay/etsy_listings.php', '2020-03-30 11:13:54'),
(453, 1, 'admin/language/uk-ua/extension/openbay/etsy_settings.php', '2020-03-30 11:13:54'),
(454, 1, 'admin/language/uk-ua/extension/openbay/fba.php', '2020-03-30 11:13:54'),
(455, 1, 'admin/language/uk-ua/extension/openbay/fba_fulfillment.php', '2020-03-30 11:13:54'),
(456, 1, 'admin/language/uk-ua/extension/openbay/fba_fulfillment_list.php', '2020-03-30 11:13:54'),
(457, 1, 'admin/language/uk-ua/extension/openbay/fba_order.php', '2020-03-30 11:13:54'),
(458, 1, 'admin/language/uk-ua/extension/openbay/fba_settings.php', '2020-03-30 11:13:54'),
(459, 1, 'admin/language/uk-ua/extension/openbay/openbay_itemlist.php', '2020-03-30 11:13:54'),
(460, 1, 'admin/language/uk-ua/extension/openbay/openbay_menu.php', '2020-03-30 11:13:54'),
(461, 1, 'admin/language/uk-ua/extension/openbay/openbay_order.php', '2020-03-30 11:13:54'),
(462, 1, 'admin/language/uk-ua/extension/payment/amazon_login_pay.php', '2020-03-30 11:13:54'),
(463, 1, 'admin/language/uk-ua/extension/payment/authorizenet_aim.php', '2020-03-30 11:13:54'),
(464, 1, 'admin/language/uk-ua/extension/payment/authorizenet_sim.php', '2020-03-30 11:13:54'),
(465, 1, 'admin/language/uk-ua/extension/payment/bank_transfer.php', '2020-03-30 11:13:54'),
(466, 1, 'admin/language/uk-ua/extension/payment/bluepay_hosted.php', '2020-03-30 11:13:54'),
(467, 1, 'admin/language/uk-ua/extension/payment/bluepay_redirect.php', '2020-03-30 11:13:54'),
(468, 1, 'admin/language/uk-ua/extension/payment/cardconnect.php', '2020-03-30 11:13:54'),
(469, 1, 'admin/language/uk-ua/extension/payment/cardinity.php', '2020-03-30 11:13:54'),
(470, 1, 'admin/language/uk-ua/extension/payment/cheque.php', '2020-03-30 11:13:54'),
(471, 1, 'admin/language/uk-ua/extension/payment/cod.php', '2020-03-30 11:13:54'),
(472, 1, 'admin/language/uk-ua/extension/payment/divido.php', '2020-03-30 11:13:54'),
(473, 1, 'admin/language/uk-ua/extension/payment/eway.php', '2020-03-30 11:13:54'),
(474, 1, 'admin/language/uk-ua/extension/payment/firstdata.php', '2020-03-30 11:13:54'),
(475, 1, 'admin/language/uk-ua/extension/payment/firstdata_remote.php', '2020-03-30 11:13:54'),
(476, 1, 'admin/language/uk-ua/extension/payment/free_checkout.php', '2020-03-30 11:13:54'),
(477, 1, 'admin/language/uk-ua/extension/payment/g2apay.php', '2020-03-30 11:13:54'),
(478, 1, 'admin/language/uk-ua/extension/payment/globalpay.php', '2020-03-30 11:13:54'),
(479, 1, 'admin/language/uk-ua/extension/payment/globalpay_remote.php', '2020-03-30 11:13:54'),
(480, 1, 'admin/language/uk-ua/extension/payment/klarna_account.php', '2020-03-30 11:13:54'),
(481, 1, 'admin/language/uk-ua/extension/payment/klarna_checkout.php', '2020-03-30 11:13:54'),
(482, 1, 'admin/language/uk-ua/extension/payment/klarna_invoice.php', '2020-03-30 11:13:54'),
(483, 1, 'admin/language/uk-ua/extension/payment/laybuy.php', '2020-03-30 11:13:54'),
(484, 1, 'admin/language/uk-ua/extension/payment/liqpay.php', '2020-03-30 11:13:54'),
(485, 1, 'admin/language/uk-ua/extension/payment/nochex.php', '2020-03-30 11:13:54'),
(486, 1, 'admin/language/uk-ua/extension/payment/ocstore_w1.php', '2020-03-30 11:13:54'),
(487, 1, 'admin/language/uk-ua/extension/payment/paymate.php', '2020-03-30 11:13:54'),
(488, 1, 'admin/language/uk-ua/extension/payment/paypoint.php', '2020-03-30 11:13:54'),
(489, 1, 'admin/language/uk-ua/extension/payment/payza.php', '2020-03-30 11:13:54'),
(490, 1, 'admin/language/uk-ua/extension/payment/perpetual_payments.php', '2020-03-30 11:13:54'),
(491, 1, 'admin/language/uk-ua/extension/payment/pilibaba.php', '2020-03-30 11:13:54'),
(492, 1, 'admin/language/uk-ua/extension/payment/pp_express.php', '2020-03-30 11:13:54'),
(493, 1, 'admin/language/uk-ua/extension/payment/pp_express_order.php', '2020-03-30 11:13:54'),
(494, 1, 'admin/language/uk-ua/extension/payment/pp_express_refund.php', '2020-03-30 11:13:54'),
(495, 1, 'admin/language/uk-ua/extension/payment/pp_express_search.php', '2020-03-30 11:13:54'),
(496, 1, 'admin/language/uk-ua/extension/payment/pp_express_view.php', '2020-03-30 11:13:54'),
(497, 1, 'admin/language/uk-ua/extension/payment/pp_payflow.php', '2020-03-30 11:13:54'),
(498, 1, 'admin/language/uk-ua/extension/payment/pp_payflow_iframe.php', '2020-03-30 11:13:54'),
(499, 1, 'admin/language/uk-ua/extension/payment/pp_pro.php', '2020-03-30 11:13:54'),
(500, 1, 'admin/language/uk-ua/extension/payment/pp_pro_iframe.php', '2020-03-30 11:13:54'),
(501, 1, 'admin/language/uk-ua/extension/payment/pp_standard.php', '2020-03-30 11:13:54'),
(502, 1, 'admin/language/uk-ua/extension/payment/realex.php', '2020-03-30 11:13:54'),
(503, 1, 'admin/language/uk-ua/extension/payment/realex_remote.php', '2020-03-30 11:13:54'),
(504, 1, 'admin/language/uk-ua/extension/payment/sagepay_direct.php', '2020-03-30 11:13:54'),
(505, 1, 'admin/language/uk-ua/extension/payment/sagepay_server.php', '2020-03-30 11:13:54'),
(506, 1, 'admin/language/uk-ua/extension/payment/sagepay_us.php', '2020-03-30 11:13:54'),
(507, 1, 'admin/language/uk-ua/extension/payment/securetrading_pp.php', '2020-03-30 11:13:54'),
(508, 1, 'admin/language/uk-ua/extension/payment/securetrading_ws.php', '2020-03-30 11:13:54'),
(509, 1, 'admin/language/uk-ua/extension/payment/skrill.php', '2020-03-30 11:13:54'),
(510, 1, 'admin/language/uk-ua/extension/payment/twocheckout.php', '2020-03-30 11:13:54'),
(511, 1, 'admin/language/uk-ua/extension/payment/web_payment_software.php', '2020-03-30 11:13:54'),
(512, 1, 'admin/language/uk-ua/extension/payment/webmoney_wmb.php', '2020-03-30 11:13:54'),
(513, 1, 'admin/language/uk-ua/extension/payment/webmoney_wme.php', '2020-03-30 11:13:54'),
(514, 1, 'admin/language/uk-ua/extension/payment/webmoney_wmk.php', '2020-03-30 11:13:54'),
(515, 1, 'admin/language/uk-ua/extension/payment/webmoney_wmr.php', '2020-03-30 11:13:54'),
(516, 1, 'admin/language/uk-ua/extension/payment/webmoney_wmu.php', '2020-03-30 11:13:54'),
(517, 1, 'admin/language/uk-ua/extension/payment/webmoney_wmv.php', '2020-03-30 11:13:54'),
(518, 1, 'admin/language/uk-ua/extension/payment/webmoney_wmz.php', '2020-03-30 11:13:54'),
(519, 1, 'admin/language/uk-ua/extension/payment/worldpay.php', '2020-03-30 11:13:54'),
(520, 1, 'admin/language/uk-ua/extension/report/customer_activity.php', '2020-03-30 11:13:54'),
(521, 1, 'admin/language/uk-ua/extension/report/customer_order.php', '2020-03-30 11:13:54'),
(522, 1, 'admin/language/uk-ua/extension/report/customer_reward.php', '2020-03-30 11:13:54'),
(523, 1, 'admin/language/uk-ua/extension/report/customer_search.php', '2020-03-30 11:13:54'),
(524, 1, 'admin/language/uk-ua/extension/report/customer_transaction.php', '2020-03-30 11:13:54'),
(525, 1, 'admin/language/uk-ua/extension/report/marketing.php', '2020-03-30 11:13:54'),
(526, 1, 'admin/language/uk-ua/extension/report/product_purchased.php', '2020-03-30 11:13:54'),
(527, 1, 'admin/language/uk-ua/extension/report/product_viewed.php', '2020-03-30 11:13:54'),
(528, 1, 'admin/language/uk-ua/extension/report/sale_coupon.php', '2020-03-30 11:13:54'),
(529, 1, 'admin/language/uk-ua/extension/report/sale_order.php', '2020-03-30 11:13:54'),
(530, 1, 'admin/language/uk-ua/extension/report/sale_return.php', '2020-03-30 11:13:54'),
(531, 1, 'admin/language/uk-ua/extension/report/sale_shipping.php', '2020-03-30 11:13:54'),
(532, 1, 'admin/language/uk-ua/extension/report/sale_tax.php', '2020-03-30 11:13:54'),
(533, 1, 'admin/language/uk-ua/extension/shipping/auspost.php', '2020-03-30 11:13:54'),
(534, 1, 'admin/language/uk-ua/extension/shipping/citylink.php', '2020-03-30 11:13:54'),
(535, 1, 'admin/language/uk-ua/extension/shipping/ec_ship.php', '2020-03-30 11:13:54'),
(536, 1, 'admin/language/uk-ua/extension/shipping/fedex.php', '2020-03-30 11:13:54'),
(537, 1, 'admin/language/uk-ua/extension/shipping/flat.php', '2020-03-30 11:13:54'),
(538, 1, 'admin/language/uk-ua/extension/shipping/free.php', '2020-03-30 11:13:54'),
(539, 1, 'admin/language/uk-ua/extension/shipping/item.php', '2020-03-30 11:13:54'),
(540, 1, 'admin/language/uk-ua/extension/shipping/parcelforce_48.php', '2020-03-30 11:13:54'),
(541, 1, 'admin/language/uk-ua/extension/shipping/pickup.php', '2020-03-30 11:13:54'),
(542, 1, 'admin/language/uk-ua/extension/shipping/royal_mail.php', '2020-03-30 11:13:54'),
(543, 1, 'admin/language/uk-ua/extension/shipping/ups.php', '2020-03-30 11:13:54'),
(544, 1, 'admin/language/uk-ua/extension/shipping/usps.php', '2020-03-30 11:13:54'),
(545, 1, 'admin/language/uk-ua/extension/shipping/weight.php', '2020-03-30 11:13:54'),
(546, 1, 'admin/language/uk-ua/extension/shipping/xshipping.php', '2020-03-30 11:13:54'),
(547, 1, 'admin/language/uk-ua/extension/theme/cyberstore.php', '2020-03-30 11:13:54'),
(548, 1, 'admin/language/uk-ua/extension/theme/default.php', '2020-03-30 11:13:54'),
(549, 1, 'admin/language/uk-ua/extension/theme/theme_default.php', '2020-03-30 11:13:54'),
(550, 1, 'admin/language/uk-ua/extension/theme/unishop.php', '2020-03-30 11:13:54'),
(551, 1, 'admin/language/uk-ua/extension/total/coupon.php', '2020-03-30 11:13:54'),
(552, 1, 'admin/language/uk-ua/extension/total/credit.php', '2020-03-30 11:13:54'),
(553, 1, 'admin/language/uk-ua/extension/total/handling.php', '2020-03-30 11:13:54'),
(554, 1, 'admin/language/uk-ua/extension/total/klarna_fee.php', '2020-03-30 11:13:54'),
(555, 1, 'admin/language/uk-ua/extension/total/low_order_fee.php', '2020-03-30 11:13:54'),
(556, 1, 'admin/language/uk-ua/extension/total/reward.php', '2020-03-30 11:13:54'),
(557, 1, 'admin/language/uk-ua/extension/total/shipping.php', '2020-03-30 11:13:54'),
(558, 1, 'admin/language/uk-ua/extension/total/sub_total.php', '2020-03-30 11:13:54'),
(559, 1, 'admin/language/uk-ua/extension/total/tax.php', '2020-03-30 11:13:54'),
(560, 1, 'admin/language/uk-ua/extension/total/total.php', '2020-03-30 11:13:54'),
(561, 1, 'admin/language/uk-ua/extension/total/voucher.php', '2020-03-30 11:13:54'),
(562, 1, 'catalog/language/uk-ua/blog/mail/review.php', '2020-03-30 11:13:54'),
(563, 1, 'catalog/language/uk-ua/extension/advertise/google.php', '2020-03-30 11:13:54'),
(564, 1, 'catalog/language/uk-ua/extension/captcha/basic.php', '2020-03-30 11:13:54'),
(565, 1, 'catalog/language/uk-ua/extension/captcha/basic_captcha.php', '2020-03-30 11:13:54'),
(566, 1, 'catalog/language/uk-ua/extension/captcha/google.php', '2020-03-30 11:13:54'),
(567, 1, 'catalog/language/uk-ua/extension/captcha/google_captcha.php', '2020-03-30 11:13:54'),
(568, 1, 'catalog/language/uk-ua/extension/credit_card/sagepay_direct.php', '2020-03-30 11:13:54'),
(569, 1, 'catalog/language/uk-ua/extension/credit_card/sagepay_server.php', '2020-03-30 11:13:54'),
(570, 1, 'catalog/language/uk-ua/extension/credit_card/squareup.php', '2020-03-30 11:13:54'),
(571, 1, 'catalog/language/uk-ua/extension/module/account.php', '2020-03-30 11:13:54'),
(572, 1, 'catalog/language/uk-ua/extension/module/affiliate.php', '2020-03-30 11:13:54'),
(573, 1, 'catalog/language/uk-ua/extension/module/bestseller.php', '2020-03-30 11:13:54'),
(574, 1, 'catalog/language/uk-ua/extension/module/blog_category.php', '2020-03-30 11:13:54'),
(575, 1, 'catalog/language/uk-ua/extension/module/blog_featured.php', '2020-03-30 11:13:54'),
(576, 1, 'catalog/language/uk-ua/extension/module/blog_latest.php', '2020-03-30 11:13:54'),
(577, 1, 'catalog/language/uk-ua/extension/module/category.php', '2020-03-30 11:13:54'),
(578, 1, 'catalog/language/uk-ua/extension/module/cyber_alltabs.php', '2020-03-30 11:13:54'),
(579, 1, 'catalog/language/uk-ua/extension/module/cyber_callback.php', '2020-03-30 11:13:54'),
(580, 1, 'catalog/language/uk-ua/extension/module/cyber_found_cheaper_product.php', '2020-03-30 11:13:54'),
(581, 1, 'catalog/language/uk-ua/extension/module/cyber_latest_grid.php', '2020-03-30 11:13:54'),
(582, 1, 'catalog/language/uk-ua/extension/module/cyber_newfastorder.php', '2020-03-30 11:13:54'),
(583, 1, 'catalog/language/uk-ua/extension/module/cyber_product_categorytabs.php', '2020-03-30 11:13:54'),
(584, 1, 'catalog/language/uk-ua/extension/module/cyber_productany.php', '2020-03-30 11:13:54'),
(585, 1, 'catalog/language/uk-ua/extension/module/cyber_productviewed.php', '2020-03-30 11:13:54'),
(586, 1, 'catalog/language/uk-ua/extension/module/cyber_question_answer.php', '2020-03-30 11:13:54'),
(587, 1, 'catalog/language/uk-ua/extension/module/cyber_quickviewpro.php', '2020-03-30 11:13:54'),
(588, 1, 'catalog/language/uk-ua/extension/module/cyber_reviewscustomer.php', '2020-03-30 11:13:54'),
(589, 1, 'catalog/language/uk-ua/extension/module/divido_calculator.php', '2020-03-30 11:13:54'),
(590, 1, 'catalog/language/uk-ua/extension/module/dream_filter.php', '2020-03-30 11:13:54'),
(591, 1, 'catalog/language/uk-ua/extension/module/ebay_listing.php', '2020-03-30 11:13:54'),
(592, 1, 'catalog/language/uk-ua/extension/module/featured.php', '2020-03-30 11:13:54'),
(593, 1, 'catalog/language/uk-ua/extension/module/featured_article.php', '2020-03-30 11:13:54'),
(594, 1, 'catalog/language/uk-ua/extension/module/featured_product.php', '2020-03-30 11:13:54'),
(595, 1, 'catalog/language/uk-ua/extension/module/filter.php', '2020-03-30 11:13:54'),
(596, 1, 'catalog/language/uk-ua/extension/module/google_hangouts.php', '2020-03-30 11:13:54'),
(597, 1, 'catalog/language/uk-ua/extension/module/information.php', '2020-03-30 11:13:54'),
(598, 1, 'catalog/language/uk-ua/extension/module/latest.php', '2020-03-30 11:13:54'),
(599, 1, 'catalog/language/uk-ua/extension/module/laybuy_layout.php', '2020-03-30 11:13:54'),
(600, 1, 'catalog/language/uk-ua/extension/module/manufacturer.php', '2020-03-30 11:13:54'),
(601, 1, 'catalog/language/uk-ua/extension/module/nppBackup', '2020-03-30 11:13:54'),
(602, 1, 'catalog/language/uk-ua/extension/module/ocfilter.php', '2020-03-30 11:13:54'),
(603, 1, 'catalog/language/uk-ua/extension/module/popular.php', '2020-03-30 11:13:54'),
(604, 1, 'catalog/language/uk-ua/extension/module/progroman', '2020-03-30 11:13:54'),
(605, 1, 'catalog/language/uk-ua/extension/module/special.php', '2020-03-30 11:13:54'),
(606, 1, 'catalog/language/uk-ua/extension/module/store.php', '2020-03-30 11:13:54'),
(607, 1, 'catalog/language/uk-ua/extension/module/uni_gallery.php', '2020-03-30 11:13:54');
INSERT INTO `oc_extension_path` (`extension_path_id`, `extension_install_id`, `path`, `date_added`) VALUES
(608, 1, 'catalog/language/uk-ua/extension/module/uni_manufacturer.php', '2020-03-30 11:13:54'),
(609, 1, 'catalog/language/uk-ua/extension/module/uni_news.php', '2020-03-30 11:13:54'),
(610, 1, 'catalog/language/uk-ua/extension/module/uni_reviews.php', '2020-03-30 11:13:54'),
(611, 1, 'catalog/language/uk-ua/extension/module/uni_subscribe.php', '2020-03-30 11:13:54'),
(612, 1, 'catalog/language/uk-ua/extension/module/uni_viewed.php', '2020-03-30 11:13:54'),
(613, 1, 'catalog/language/uk-ua/extension/openbay/amazon_order.php', '2020-03-30 11:13:54'),
(614, 1, 'catalog/language/uk-ua/extension/openbay/amazonus_order.php', '2020-03-30 11:13:54'),
(615, 1, 'catalog/language/uk-ua/extension/openbay/ebay_order.php', '2020-03-30 11:13:54'),
(616, 1, 'catalog/language/uk-ua/extension/openbay/etsy_order.php', '2020-03-30 11:13:54'),
(617, 1, 'catalog/language/uk-ua/extension/payment/amazon_login_pay.php', '2020-03-30 11:13:54'),
(618, 1, 'catalog/language/uk-ua/extension/payment/authorizenet_aim.php', '2020-03-30 11:13:54'),
(619, 1, 'catalog/language/uk-ua/extension/payment/authorizenet_sim.php', '2020-03-30 11:13:54'),
(620, 1, 'catalog/language/uk-ua/extension/payment/bank_transfer.php', '2020-03-30 11:13:54'),
(621, 1, 'catalog/language/uk-ua/extension/payment/bluepay_hosted.php', '2020-03-30 11:13:54'),
(622, 1, 'catalog/language/uk-ua/extension/payment/bluepay_redirect.php', '2020-03-30 11:13:54'),
(623, 1, 'catalog/language/uk-ua/extension/payment/cardconnect.php', '2020-03-30 11:13:54'),
(624, 1, 'catalog/language/uk-ua/extension/payment/cardinity.php', '2020-03-30 11:13:54'),
(625, 1, 'catalog/language/uk-ua/extension/payment/cheque.php', '2020-03-30 11:13:54'),
(626, 1, 'catalog/language/uk-ua/extension/payment/cod.php', '2020-03-30 11:13:54'),
(627, 1, 'catalog/language/uk-ua/extension/payment/divido.php', '2020-03-30 11:13:54'),
(628, 1, 'catalog/language/uk-ua/extension/payment/eway.php', '2020-03-30 11:13:54'),
(629, 1, 'catalog/language/uk-ua/extension/payment/firstdata.php', '2020-03-30 11:13:54'),
(630, 1, 'catalog/language/uk-ua/extension/payment/firstdata_remote.php', '2020-03-30 11:13:54'),
(631, 1, 'catalog/language/uk-ua/extension/payment/free_checkout.php', '2020-03-30 11:13:54'),
(632, 1, 'catalog/language/uk-ua/extension/payment/g2apay.php', '2020-03-30 11:13:54'),
(633, 1, 'catalog/language/uk-ua/extension/payment/globalpay.php', '2020-03-30 11:13:54'),
(634, 1, 'catalog/language/uk-ua/extension/payment/globalpay_remote.php', '2020-03-30 11:13:54'),
(635, 1, 'catalog/language/uk-ua/extension/payment/klarna_account.php', '2020-03-30 11:13:54'),
(636, 1, 'catalog/language/uk-ua/extension/payment/klarna_checkout.php', '2020-03-30 11:13:54'),
(637, 1, 'catalog/language/uk-ua/extension/payment/klarna_invoice.php', '2020-03-30 11:13:54'),
(638, 1, 'catalog/language/uk-ua/extension/payment/laybuy.php', '2020-03-30 11:13:54'),
(639, 1, 'catalog/language/uk-ua/extension/payment/liqpay.php', '2020-03-30 11:13:54'),
(640, 1, 'catalog/language/uk-ua/extension/payment/nochex.php', '2020-03-30 11:13:54'),
(641, 1, 'catalog/language/uk-ua/extension/payment/ocstore_w1.php', '2020-03-30 11:13:54'),
(642, 1, 'catalog/language/uk-ua/extension/payment/paymate.php', '2020-03-30 11:13:54'),
(643, 1, 'catalog/language/uk-ua/extension/payment/paypoint.php', '2020-03-30 11:13:54'),
(644, 1, 'catalog/language/uk-ua/extension/payment/payza.php', '2020-03-30 11:13:54'),
(645, 1, 'catalog/language/uk-ua/extension/payment/perpetual_payments.php', '2020-03-30 11:13:54'),
(646, 1, 'catalog/language/uk-ua/extension/payment/pilibaba.php', '2020-03-30 11:13:54'),
(647, 1, 'catalog/language/uk-ua/extension/payment/pp_express.php', '2020-03-30 11:13:54'),
(648, 1, 'catalog/language/uk-ua/extension/payment/pp_payflow.php', '2020-03-30 11:13:54'),
(649, 1, 'catalog/language/uk-ua/extension/payment/pp_payflow_iframe.php', '2020-03-30 11:13:54'),
(650, 1, 'catalog/language/uk-ua/extension/payment/pp_pro.php', '2020-03-30 11:13:54'),
(651, 1, 'catalog/language/uk-ua/extension/payment/pp_pro_iframe.php', '2020-03-30 11:13:54'),
(652, 1, 'catalog/language/uk-ua/extension/payment/pp_standard.php', '2020-03-30 11:13:54'),
(653, 1, 'catalog/language/uk-ua/extension/payment/realex.php', '2020-03-30 11:13:54'),
(654, 1, 'catalog/language/uk-ua/extension/payment/realex_remote.php', '2020-03-30 11:13:54'),
(655, 1, 'catalog/language/uk-ua/extension/payment/sagepay_direct.php', '2020-03-30 11:13:54'),
(656, 1, 'catalog/language/uk-ua/extension/payment/sagepay_server.php', '2020-03-30 11:13:54'),
(657, 1, 'catalog/language/uk-ua/extension/payment/sagepay_us.php', '2020-03-30 11:13:54'),
(658, 1, 'catalog/language/uk-ua/extension/payment/securetrading_pp.php', '2020-03-30 11:13:54'),
(659, 1, 'catalog/language/uk-ua/extension/payment/securetrading_ws.php', '2020-03-30 11:13:54'),
(660, 1, 'catalog/language/uk-ua/extension/payment/skrill.php', '2020-03-30 11:13:54'),
(661, 1, 'catalog/language/uk-ua/extension/payment/twocheckout.php', '2020-03-30 11:13:54'),
(662, 1, 'catalog/language/uk-ua/extension/payment/web_payment_software.php', '2020-03-30 11:13:54'),
(663, 1, 'catalog/language/uk-ua/extension/payment/webmoney_wmb.php', '2020-03-30 11:13:54'),
(664, 1, 'catalog/language/uk-ua/extension/payment/webmoney_wme.php', '2020-03-30 11:13:54'),
(665, 1, 'catalog/language/uk-ua/extension/payment/webmoney_wmk.php', '2020-03-30 11:13:54'),
(666, 1, 'catalog/language/uk-ua/extension/payment/webmoney_wmr.php', '2020-03-30 11:13:54'),
(667, 1, 'catalog/language/uk-ua/extension/payment/webmoney_wmu.php', '2020-03-30 11:13:54'),
(668, 1, 'catalog/language/uk-ua/extension/payment/webmoney_wmv.php', '2020-03-30 11:13:54'),
(669, 1, 'catalog/language/uk-ua/extension/payment/webmoney_wmz.php', '2020-03-30 11:13:54'),
(670, 1, 'catalog/language/uk-ua/extension/payment/worldpay.php', '2020-03-30 11:13:54'),
(671, 1, 'catalog/language/uk-ua/extension/recurring/pp_express.php', '2020-03-30 11:13:54'),
(672, 1, 'catalog/language/uk-ua/extension/recurring/squareup.php', '2020-03-30 11:13:54'),
(673, 1, 'catalog/language/uk-ua/extension/shipping/auspost.php', '2020-03-30 11:13:54'),
(674, 1, 'catalog/language/uk-ua/extension/shipping/citylink.php', '2020-03-30 11:13:54'),
(675, 1, 'catalog/language/uk-ua/extension/shipping/ec_ship.php', '2020-03-30 11:13:54'),
(676, 1, 'catalog/language/uk-ua/extension/shipping/fedex.php', '2020-03-30 11:13:54'),
(677, 1, 'catalog/language/uk-ua/extension/shipping/flat.php', '2020-03-30 11:13:54'),
(678, 1, 'catalog/language/uk-ua/extension/shipping/free.php', '2020-03-30 11:13:54'),
(679, 1, 'catalog/language/uk-ua/extension/shipping/item.php', '2020-03-30 11:13:54'),
(680, 1, 'catalog/language/uk-ua/extension/shipping/parcelforce_48.php', '2020-03-30 11:13:54'),
(681, 1, 'catalog/language/uk-ua/extension/shipping/pickup.php', '2020-03-30 11:13:54'),
(682, 1, 'catalog/language/uk-ua/extension/shipping/pilibaba.php', '2020-03-30 11:13:54'),
(683, 1, 'catalog/language/uk-ua/extension/shipping/royal_mail.php', '2020-03-30 11:13:54'),
(684, 1, 'catalog/language/uk-ua/extension/shipping/ups.php', '2020-03-30 11:13:54'),
(685, 1, 'catalog/language/uk-ua/extension/shipping/usps.php', '2020-03-30 11:13:54'),
(686, 1, 'catalog/language/uk-ua/extension/shipping/weight.php', '2020-03-30 11:13:54'),
(687, 1, 'catalog/language/uk-ua/extension/shipping/xshipping.php', '2020-03-30 11:13:54'),
(688, 1, 'catalog/language/uk-ua/extension/total/coupon.php', '2020-03-30 11:13:54'),
(689, 1, 'catalog/language/uk-ua/extension/total/credit.php', '2020-03-30 11:13:54'),
(690, 1, 'catalog/language/uk-ua/extension/total/handling.php', '2020-03-30 11:13:54'),
(691, 1, 'catalog/language/uk-ua/extension/total/klarna_fee.php', '2020-03-30 11:13:54'),
(692, 1, 'catalog/language/uk-ua/extension/total/low_order_fee.php', '2020-03-30 11:13:54'),
(693, 1, 'catalog/language/uk-ua/extension/total/reward.php', '2020-03-30 11:13:54'),
(694, 1, 'catalog/language/uk-ua/extension/total/shipping.php', '2020-03-30 11:13:54'),
(695, 1, 'catalog/language/uk-ua/extension/total/sub_total.php', '2020-03-30 11:13:54'),
(696, 1, 'catalog/language/uk-ua/extension/total/total.php', '2020-03-30 11:13:54'),
(697, 1, 'catalog/language/uk-ua/extension/total/voucher.php', '2020-03-30 11:13:54'),
(698, 1, 'catalog/language/uk-ua/module/groupeditor/btngroupeditor.php', '2020-03-30 11:13:54'),
(699, 1, 'catalog/language/uk-ua/module/groupeditor/productgroupeditor.php', '2020-03-30 11:13:54'),
(700, 1, 'catalog/language/uk-ua/extension/module/nppBackup/uni_gallery.php.2020-02-08_102803.bak', '2020-03-30 11:13:54'),
(701, 1, 'catalog/language/uk-ua/extension/module/progroman/city_manager.php', '2020-03-30 11:13:54');

-- --------------------------------------------------------

--
-- Структура таблицы `oc_filter`
--

CREATE TABLE `oc_filter` (
  `filter_id` int(11) NOT NULL,
  `filter_group_id` int(11) NOT NULL,
  `sort_order` int(3) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `oc_filter_description`
--

CREATE TABLE `oc_filter_description` (
  `filter_id` int(11) NOT NULL,
  `language_id` int(11) NOT NULL,
  `filter_group_id` int(11) NOT NULL,
  `name` varchar(64) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `oc_filter_group`
--

CREATE TABLE `oc_filter_group` (
  `filter_group_id` int(11) NOT NULL,
  `sort_order` int(3) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `oc_filter_group_description`
--

CREATE TABLE `oc_filter_group_description` (
  `filter_group_id` int(11) NOT NULL,
  `language_id` int(11) NOT NULL,
  `name` varchar(64) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `oc_geo_zone`
--

CREATE TABLE `oc_geo_zone` (
  `geo_zone_id` int(11) NOT NULL,
  `name` varchar(32) NOT NULL,
  `description` varchar(255) NOT NULL,
  `date_added` datetime NOT NULL,
  `date_modified` datetime NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_geo_zone`
--

INSERT INTO `oc_geo_zone` (`geo_zone_id`, `name`, `description`, `date_added`, `date_modified`) VALUES
(3, 'Зона НДС', 'Облагаемые НДС', '2014-05-21 22:30:20', '2020-03-30 13:39:41');

-- --------------------------------------------------------

--
-- Структура таблицы `oc_googleshopping_category`
--

CREATE TABLE `oc_googleshopping_category` (
  `google_product_category` varchar(10) NOT NULL,
  `store_id` int(11) NOT NULL DEFAULT 0,
  `category_id` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `oc_googleshopping_product`
--

CREATE TABLE `oc_googleshopping_product` (
  `product_advertise_google_id` int(11) UNSIGNED NOT NULL,
  `product_id` int(11) DEFAULT NULL,
  `store_id` int(11) NOT NULL DEFAULT 0,
  `has_issues` tinyint(1) DEFAULT NULL,
  `destination_status` enum('pending','approved','disapproved') NOT NULL DEFAULT 'pending',
  `impressions` int(11) NOT NULL DEFAULT 0,
  `clicks` int(11) NOT NULL DEFAULT 0,
  `conversions` int(11) NOT NULL DEFAULT 0,
  `cost` decimal(15,4) NOT NULL DEFAULT 0.0000,
  `conversion_value` decimal(15,4) NOT NULL DEFAULT 0.0000,
  `google_product_category` varchar(10) DEFAULT NULL,
  `condition` enum('new','refurbished','used') DEFAULT NULL,
  `adult` tinyint(1) DEFAULT NULL,
  `multipack` int(11) DEFAULT NULL,
  `is_bundle` tinyint(1) DEFAULT NULL,
  `age_group` enum('newborn','infant','toddler','kids','adult') DEFAULT NULL,
  `color` int(11) DEFAULT NULL,
  `gender` enum('male','female','unisex') DEFAULT NULL,
  `size_type` enum('regular','petite','plus','big and tall','maternity') DEFAULT NULL,
  `size_system` enum('AU','BR','CN','DE','EU','FR','IT','JP','MEX','UK','US') DEFAULT NULL,
  `size` int(11) DEFAULT NULL,
  `is_modified` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_googleshopping_product`
--

INSERT INTO `oc_googleshopping_product` (`product_advertise_google_id`, `product_id`, `store_id`, `has_issues`, `destination_status`, `impressions`, `clicks`, `conversions`, `cost`, `conversion_value`, `google_product_category`, `condition`, `adult`, `multipack`, `is_bundle`, `age_group`, `color`, `gender`, `size_type`, `size_system`, `size`, `is_modified`) VALUES
(1, 50, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(269, 318, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(270, 319, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(271, 320, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(129, 178, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(274, 323, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(273, 322, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(272, 321, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(124, 173, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(285, 334, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(283, 332, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(282, 331, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(281, 330, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(280, 329, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(279, 328, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(246, 295, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(245, 294, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(244, 293, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(22, 71, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(284, 333, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(97, 146, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(235, 284, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(247, 296, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(256, 305, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(257, 306, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(258, 307, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(259, 308, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(260, 309, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(211, 260, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(212, 261, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(213, 262, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(214, 263, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(215, 264, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(216, 265, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(217, 266, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(218, 267, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(219, 268, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(220, 269, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(221, 270, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(222, 271, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(223, 272, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(224, 273, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(225, 274, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(226, 275, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(227, 276, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(228, 277, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(229, 278, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(230, 279, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(231, 280, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(232, 281, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(233, 282, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(234, 283, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(206, 255, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(207, 256, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(208, 257, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(209, 258, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(210, 259, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(134, 183, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(278, 327, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(277, 326, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(276, 325, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(275, 324, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(268, 317, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(267, 316, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(266, 315, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(265, 314, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(264, 313, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(263, 312, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(262, 311, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(261, 310, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(255, 304, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(254, 303, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(253, 302, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(252, 301, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(251, 300, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(250, 299, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(249, 298, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(248, 297, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(243, 292, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(242, 291, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(241, 290, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(240, 289, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(239, 288, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(238, 287, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(237, 286, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(236, 285, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(205, 254, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(204, 253, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(203, 252, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(202, 251, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(201, 250, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(200, 249, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(199, 248, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(198, 247, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(197, 246, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(195, 244, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(196, 245, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(286, 335, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(287, 336, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(288, 337, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(289, 338, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(290, 339, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(291, 340, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(292, 341, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(293, 342, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(294, 343, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(295, 344, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(296, 345, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(297, 346, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(298, 347, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(299, 348, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(300, 349, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(301, 350, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(302, 351, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(303, 352, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(304, 353, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(314, 363, 0, NULL, 'pending', 0, 0, 0, '0.0000', '0.0000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0);

-- --------------------------------------------------------

--
-- Структура таблицы `oc_googleshopping_product_status`
--

CREATE TABLE `oc_googleshopping_product_status` (
  `product_id` int(11) NOT NULL DEFAULT 0,
  `store_id` int(11) NOT NULL DEFAULT 0,
  `product_variation_id` varchar(64) NOT NULL DEFAULT '',
  `destination_statuses` text NOT NULL,
  `data_quality_issues` text NOT NULL,
  `item_level_issues` text NOT NULL,
  `google_expiration_date` int(11) NOT NULL DEFAULT 0
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `oc_googleshopping_product_target`
--

CREATE TABLE `oc_googleshopping_product_target` (
  `product_id` int(11) NOT NULL,
  `store_id` int(11) NOT NULL DEFAULT 0,
  `advertise_google_target_id` int(11) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `oc_googleshopping_target`
--

CREATE TABLE `oc_googleshopping_target` (
  `advertise_google_target_id` int(11) UNSIGNED NOT NULL,
  `store_id` int(11) NOT NULL DEFAULT 0,
  `campaign_name` varchar(255) NOT NULL DEFAULT '',
  `country` varchar(2) NOT NULL DEFAULT '',
  `budget` decimal(15,4) NOT NULL DEFAULT 0.0000,
  `feeds` text NOT NULL,
  `status` enum('paused','active') NOT NULL DEFAULT 'paused',
  `date_added` date DEFAULT NULL,
  `roas` int(11) NOT NULL DEFAULT 0
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `oc_information`
--

CREATE TABLE `oc_information` (
  `information_id` int(11) NOT NULL,
  `bottom` int(1) NOT NULL DEFAULT 0,
  `sort_order` int(3) NOT NULL DEFAULT 0,
  `status` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_information`
--

INSERT INTO `oc_information` (`information_id`, `bottom`, `sort_order`, `status`) VALUES
(3, 0, 3, 1),
(4, 1, 1, 1),
(5, 0, 4, 1),
(6, 1, 2, 1);

-- --------------------------------------------------------

--
-- Структура таблицы `oc_information_description`
--

CREATE TABLE `oc_information_description` (
  `information_id` int(11) NOT NULL,
  `language_id` int(11) NOT NULL,
  `title` varchar(64) NOT NULL,
  `description` mediumtext NOT NULL,
  `meta_title` varchar(255) NOT NULL,
  `meta_description` varchar(255) NOT NULL,
  `meta_keyword` varchar(255) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_information_description`
--

INSERT INTO `oc_information_description` (`information_id`, `language_id`, `title`, `description`, `meta_title`, `meta_description`, `meta_keyword`) VALUES
(5, 2, 'Условия соглашения', '&lt;p&gt;\r\n	Terms &amp;amp; Conditions&lt;/p&gt;', 'Условия соглашения', '', ''),
(3, 2, 'Политика Безопасности', '&lt;p&gt;\r\n	Privacy Policy&lt;/p&gt;', 'Политика Безопасности', '', ''),
(4, 2, 'О нас', '&lt;p&gt;Сайт рыбатекст поможет дизайнеру, верстальщику, вебмастеру сгенерировать несколько абзацев более менее осмысленного текста рыбы на русском языке, а начинающему оратору отточить навык публичных выступлений в домашних условиях. При создании генератора мы использовали небезизвестный универсальный код речей. Текст генерируется абзацами случайным образом от двух до десяти предложений в абзаце, что позволяет сделать текст более привлекательным и живым для визуально-слухового восприятия.&lt;/p&gt;&lt;p&gt;По своей сути рыбатекст является альтернативой традиционному lorem ipsum, который вызывает у некторых людей недоумение при попытках прочитать рыбу текст. В отличии от lorem ipsum, текст рыба на русском языке наполнит любой макет непонятным смыслом и придаст неповторимый колорит советских времен.&lt;/p&gt;&lt;p&gt;Сайт рыбатекст поможет дизайнеру, верстальщику, вебмастеру сгенерировать несколько абзацев более менее осмысленного текста рыбы на русском языке, а начинающему оратору отточить навык публичных выступлений в домашних условиях. При создании генератора мы использовали небезизвестный универсальный код речей. Текст генерируется абзацами случайным образом от двух до десяти предложений в абзаце, что позволяет сделать текст более привлекательным и живым для визуально-слухового восприятия.&lt;/p&gt;&lt;p&gt;По своей сути рыбатекст является альтернативой традиционному lorem ipsum, который вызывает у некторых людей недоумение при попытках прочитать рыбу текст. В отличии от lorem ipsum, текст рыба на русском языке наполнит любой макет непонятным смыслом и придаст неповторимый колорит советских времен.&lt;/p&gt;&lt;p&gt;Сайт рыбатекст поможет дизайнеру, верстальщику, вебмастеру сгенерировать несколько абзацев более менее осмысленного текста рыбы на русском языке, а начинающему оратору отточить навык публичных выступлений в домашних условиях. При создании генератора мы использовали небезизвестный универсальный код речей. Текст генерируется абзацами случайным образом от двух до десяти предложений в абзаце, что позволяет сделать текст более привлекательным и живым для визуально-слухового восприятия.&lt;/p&gt;&lt;p&gt;По своей сути рыбатекст является альтернативой традиционному lorem ipsum, который вызывает у некторых людей недоумение при попытках прочитать рыбу текст. В отличии от lorem ipsum, текст рыба на русском языке наполнит любой макет непонятным смыслом и придаст неповторимый колорит советских времен.&lt;/p&gt;&lt;p&gt;Сайт рыбатекст поможет дизайнеру, верстальщику, вебмастеру сгенерировать несколько абзацев более менее осмысленного текста рыбы на русском языке, а начинающему оратору отточить навык публичных выступлений в домашних условиях. При создании генератора мы использовали небезизвестный универсальный код речей. Текст генерируется абзацами случайным образом от двух до десяти предложений в абзаце, что позволяет сделать текст более привлекательным и живым для визуально-слухового восприятия.&lt;/p&gt;&lt;p&gt;По своей сути рыбатекст является альтернативой традиционному lorem ipsum, который вызывает у некторых людей недоумение при попытках прочитать рыбу текст. В отличии от lorem ipsum, текст рыба на русском языке наполнит любой макет непонятным смыслом и придаст неповторимый колорит советских времен.&lt;/p&gt;&lt;p&gt;Сайт рыбатекст поможет дизайнеру, верстальщику, вебмастеру сгенерировать несколько абзацев более менее осмысленного текста рыбы на русском языке, а начинающему оратору отточить навык публичных выступлений в домашних условиях. При создании генератора мы использовали небезизвестный универсальный код речей. Текст генерируется абзацами случайным образом от двух до десяти предложений в абзаце, что позволяет сделать текст более привлекательным и живым для визуально-слухового восприятия.&lt;/p&gt;&lt;p&gt;По своей сути рыбатекст является альтернативой традиционному lorem ipsum, который вызывает у некторых людей недоумение при попытках прочитать рыбу текст. В отличии от lorem ipsum, текст рыба на русском языке наполнит любой макет непонятным смыслом и придаст неповторимый колорит советских времен.&lt;/p&gt;', 'О нас', '', ''),
(6, 2, 'Доставка', '&lt;p&gt;Сайт рыбатекст поможет дизайнеру, верстальщику, вебмастеру сгенерировать несколько абзацев более менее осмысленного текста рыбы на русском языке, а начинающему оратору отточить навык публичных выступлений в домашних условиях. При создании генератора мы использовали небезизвестный универсальный код речей. Текст генерируется абзацами случайным образом от двух до десяти предложений в абзаце, что позволяет сделать текст более привлекательным и живым для визуально-слухового восприятия.&lt;/p&gt;&lt;p&gt;По своей сути рыбатекст является альтернативой традиционному lorem ipsum, который вызывает у некторых людей недоумение при попытках прочитать рыбу текст. В отличии от lorem ipsum, текст рыба на русском языке наполнит любой макет непонятным смыслом и придаст неповторимый колорит советских времен.&lt;/p&gt;&lt;p&gt;Сайт рыбатекст поможет дизайнеру, верстальщику, вебмастеру сгенерировать несколько абзацев более менее осмысленного текста рыбы на русском языке, а начинающему оратору отточить навык публичных выступлений в домашних условиях. При создании генератора мы использовали небезизвестный универсальный код речей. Текст генерируется абзацами случайным образом от двух до десяти предложений в абзаце, что позволяет сделать текст более привлекательным и живым для визуально-слухового восприятия.&lt;/p&gt;&lt;p&gt;По своей сути рыбатекст является альтернативой традиционному lorem ipsum, который вызывает у некторых людей недоумение при попытках прочитать рыбу текст. В отличии от lorem ipsum, текст рыба на русском языке наполнит любой макет непонятным смыслом и придаст неповторимый колорит советских времен.&lt;/p&gt;&lt;p&gt;Сайт рыбатекст поможет дизайнеру, верстальщику, вебмастеру сгенерировать несколько абзацев более менее осмысленного текста рыбы на русском языке, а начинающему оратору отточить навык публичных выступлений в домашних условиях. При создании генератора мы использовали небезизвестный универсальный код речей. Текст генерируется абзацами случайным образом от двух до десяти предложений в абзаце, что позволяет сделать текст более привлекательным и живым для визуально-слухового восприятия.&lt;/p&gt;&lt;p&gt;По своей сути рыбатекст является альтернативой традиционному lorem ipsum, который вызывает у некторых людей недоумение при попытках прочитать рыбу текст. В отличии от lorem ipsum, текст рыба на русском языке наполнит любой макет непонятным смыслом и придаст неповторимый колорит советских времен.&lt;/p&gt;&lt;p&gt;Сайт рыбатекст поможет дизайнеру, верстальщику, вебмастеру сгенерировать несколько абзацев более менее осмысленного текста рыбы на русском языке, а начинающему оратору отточить навык публичных выступлений в домашних условиях. При создании генератора мы использовали небезизвестный универсальный код речей. Текст генерируется абзацами случайным образом от двух до десяти предложений в абзаце, что позволяет сделать текст более привлекательным и живым для визуально-слухового восприятия.&lt;/p&gt;&lt;p&gt;По своей сути рыбатекст является альтернативой традиционному lorem ipsum, который вызывает у некторых людей недоумение при попытках прочитать рыбу текст. В отличии от lorem ipsum, текст рыба на русском языке наполнит любой макет непонятным смыслом и придаст неповторимый колорит советских времен.&lt;/p&gt;&lt;p&gt;Сайт рыбатекст поможет дизайнеру, верстальщику, вебмастеру сгенерировать несколько абзацев более менее осмысленного текста рыбы на русском языке, а начинающему оратору отточить навык публичных выступлений в домашних условиях. При создании генератора мы использовали небезизвестный универсальный код речей. Текст генерируется абзацами случайным образом от двух до десяти предложений в абзаце, что позволяет сделать текст более привлекательным и живым для визуально-слухового восприятия.&lt;/p&gt;&lt;p&gt;По своей сути рыбатекст является альтернативой традиционному lorem ipsum, который вызывает у некторых людей недоумение при попытках прочитать рыбу текст. В отличии от lorem ipsum, текст рыба на русском языке наполнит любой макет непонятным смыслом и придаст неповторимый колорит советских времен.&lt;/p&gt;', 'Доставка', '', '');

-- --------------------------------------------------------

--
-- Структура таблицы `oc_information_to_layout`
--

CREATE TABLE `oc_information_to_layout` (
  `information_id` int(11) NOT NULL,
  `store_id` int(11) NOT NULL,
  `layout_id` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_information_to_layout`
--

INSERT INTO `oc_information_to_layout` (`information_id`, `store_id`, `layout_id`) VALUES
(6, 0, 0),
(4, 0, 0),
(3, 0, 0),
(5, 0, 0);

-- --------------------------------------------------------

--
-- Структура таблицы `oc_information_to_store`
--

CREATE TABLE `oc_information_to_store` (
  `information_id` int(11) NOT NULL,
  `store_id` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_information_to_store`
--

INSERT INTO `oc_information_to_store` (`information_id`, `store_id`) VALUES
(3, 0),
(4, 0),
(5, 0),
(6, 0);

-- --------------------------------------------------------

--
-- Структура таблицы `oc_language`
--

CREATE TABLE `oc_language` (
  `language_id` int(11) NOT NULL,
  `name` varchar(32) NOT NULL,
  `code` varchar(5) NOT NULL,
  `locale` varchar(255) NOT NULL,
  `image` varchar(64) NOT NULL,
  `directory` varchar(32) NOT NULL,
  `sort_order` int(3) NOT NULL DEFAULT 0,
  `status` tinyint(1) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_language`
--

INSERT INTO `oc_language` (`language_id`, `name`, `code`, `locale`, `image`, `directory`, `sort_order`, `status`) VALUES
(2, 'Українська', 'uk-ua', 'ua_UA.UTF-8,ua_UA,ua_UA,ua', '', '', 1, 1);

-- --------------------------------------------------------

--
-- Структура таблицы `oc_layout`
--

CREATE TABLE `oc_layout` (
  `layout_id` int(11) NOT NULL,
  `name` varchar(64) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_layout`
--

INSERT INTO `oc_layout` (`layout_id`, `name`) VALUES
(1, 'Home'),
(2, 'Product'),
(3, 'Category'),
(4, 'Default'),
(11, 'Information');

-- --------------------------------------------------------

--
-- Структура таблицы `oc_layout_module`
--

CREATE TABLE `oc_layout_module` (
  `layout_module_id` int(11) NOT NULL,
  `layout_id` int(11) NOT NULL,
  `code` varchar(64) NOT NULL,
  `position` varchar(14) NOT NULL,
  `sort_order` int(3) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_layout_module`
--

INSERT INTO `oc_layout_module` (`layout_module_id`, `layout_id`, `code`, `position`, `sort_order`) VALUES
(2, 4, '0', 'content_top', 0),
(3, 4, '0', 'content_top', 1),
(88, 1, 'category', 'content_top', 4),
(87, 1, 'featured.34', 'content_top', 3),
(86, 1, 'banner.35', 'content_top', 1),
(85, 1, 'banner.33', 'content_top', 0);

-- --------------------------------------------------------

--
-- Структура таблицы `oc_layout_route`
--

CREATE TABLE `oc_layout_route` (
  `layout_route_id` int(11) NOT NULL,
  `layout_id` int(11) NOT NULL,
  `store_id` int(11) NOT NULL,
  `route` varchar(64) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_layout_route`
--

INSERT INTO `oc_layout_route` (`layout_route_id`, `layout_id`, `store_id`, `route`) VALUES
(44, 3, 0, 'product/category'),
(57, 1, 0, 'common/home'),
(20, 2, 0, 'product/product'),
(24, 11, 0, 'information/information'),
(34, 4, 0, '');

-- --------------------------------------------------------

--
-- Структура таблицы `oc_length_class`
--

CREATE TABLE `oc_length_class` (
  `length_class_id` int(11) NOT NULL,
  `value` decimal(15,8) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_length_class`
--

INSERT INTO `oc_length_class` (`length_class_id`, `value`) VALUES
(1, '1.00000000'),
(2, '10.00000000'),
(3, '0.39370000');

-- --------------------------------------------------------

--
-- Структура таблицы `oc_length_class_description`
--

CREATE TABLE `oc_length_class_description` (
  `length_class_id` int(11) NOT NULL,
  `language_id` int(11) NOT NULL,
  `title` varchar(32) NOT NULL,
  `unit` varchar(4) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_length_class_description`
--

INSERT INTO `oc_length_class_description` (`length_class_id`, `language_id`, `title`, `unit`) VALUES
(1, 1, 'Сантиметр', 'см'),
(2, 1, 'Миллиметр', 'мм'),
(1, 2, 'Сантиметр', 'см'),
(2, 2, 'Миллиметр', 'мм');

-- --------------------------------------------------------

--
-- Структура таблицы `oc_location`
--

CREATE TABLE `oc_location` (
  `location_id` int(11) NOT NULL,
  `name` varchar(32) NOT NULL,
  `address` text NOT NULL,
  `telephone` varchar(32) NOT NULL,
  `fax` varchar(32) NOT NULL,
  `geocode` varchar(32) NOT NULL,
  `image` varchar(255) DEFAULT NULL,
  `open` text NOT NULL,
  `comment` text NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `oc_manufacturer`
--

CREATE TABLE `oc_manufacturer` (
  `manufacturer_id` int(11) NOT NULL,
  `name` varchar(64) NOT NULL,
  `image` varchar(255) DEFAULT NULL,
  `sort_order` int(3) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_manufacturer`
--

INSERT INTO `oc_manufacturer` (`manufacturer_id`, `name`, `image`, `sort_order`) VALUES
(5, 'HTC', 'catalog/demo/htc_logo.jpg', 0),
(6, 'Palm', 'catalog/demo/palm_logo.jpg', 0),
(7, 'Hewlett-Packard', 'catalog/demo/hp_logo.jpg', 0),
(8, 'Apple', 'catalog/demo/apple_logo.jpg', 0),
(9, 'Canon', 'catalog/demo/canon_logo.jpg', 0),
(10, 'Sony', 'catalog/demo/sony_logo.jpg', 0);

-- --------------------------------------------------------

--
-- Структура таблицы `oc_manufacturer_to_store`
--

CREATE TABLE `oc_manufacturer_to_store` (
  `manufacturer_id` int(11) NOT NULL,
  `store_id` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_manufacturer_to_store`
--

INSERT INTO `oc_manufacturer_to_store` (`manufacturer_id`, `store_id`) VALUES
(5, 0),
(6, 0),
(7, 0),
(8, 0),
(9, 0),
(10, 0);

-- --------------------------------------------------------

--
-- Структура таблицы `oc_marketing`
--

CREATE TABLE `oc_marketing` (
  `marketing_id` int(11) NOT NULL,
  `name` varchar(32) NOT NULL,
  `description` text NOT NULL,
  `code` varchar(64) NOT NULL,
  `clicks` int(5) NOT NULL DEFAULT 0,
  `date_added` datetime NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `oc_modification`
--

CREATE TABLE `oc_modification` (
  `modification_id` int(11) NOT NULL,
  `extension_install_id` int(11) NOT NULL,
  `name` varchar(64) NOT NULL,
  `code` varchar(64) NOT NULL,
  `author` varchar(64) NOT NULL,
  `version` varchar(32) NOT NULL,
  `link` varchar(255) NOT NULL,
  `xml` mediumtext NOT NULL,
  `status` tinyint(1) NOT NULL,
  `date_added` datetime NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `oc_module`
--

CREATE TABLE `oc_module` (
  `module_id` int(11) NOT NULL,
  `name` varchar(64) NOT NULL,
  `code` varchar(32) NOT NULL,
  `setting` text NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_module`
--

INSERT INTO `oc_module` (`module_id`, `name`, `code`, `setting`) VALUES
(33, 'Головна комп\'ютерна версія', 'banner', '{\"name\":\"\\u0413\\u043e\\u043b\\u043e\\u0432\\u043d\\u0430 \\u043a\\u043e\\u043c\\u043f\'\\u044e\\u0442\\u0435\\u0440\\u043d\\u0430 \\u0432\\u0435\\u0440\\u0441\\u0456\\u044f\",\"banner_id\":\"9\",\"width\":\"1920\",\"height\":\"575\",\"status\":\"1\"}'),
(34, 'Рекомендовані', 'featured', '{\"name\":\"\\u0420\\u0435\\u043a\\u043e\\u043c\\u0435\\u043d\\u0434\\u043e\\u0432\\u0430\\u043d\\u0456\",\"product_name\":\"\",\"product\":[\"71\",\"50\",\"173\",\"244\",\"146\",\"325\"],\"limit\":\"10\",\"width\":\"480\",\"height\":\"300\",\"status\":\"1\"}'),
(35, 'Головна мобільна версія', 'banner', '{\"name\":\"\\u0413\\u043e\\u043b\\u043e\\u0432\\u043d\\u0430 \\u043c\\u043e\\u0431\\u0456\\u043b\\u044c\\u043d\\u0430 \\u0432\\u0435\\u0440\\u0441\\u0456\\u044f\",\"banner_id\":\"10\",\"width\":\"420\",\"height\":\"480\",\"status\":\"1\"}');

-- --------------------------------------------------------

--
-- Структура таблицы `oc_option`
--

CREATE TABLE `oc_option` (
  `option_id` int(11) NOT NULL,
  `type` varchar(32) NOT NULL,
  `sort_order` int(3) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_option`
--

INSERT INTO `oc_option` (`option_id`, `type`, `sort_order`) VALUES
(1, 'radio', 1),
(2, 'checkbox', 2),
(4, 'text', 3),
(5, 'select', 4),
(6, 'textarea', 5),
(7, 'file', 6),
(8, 'date', 7),
(9, 'time', 8),
(10, 'datetime', 9),
(11, 'select', 10),
(12, 'date', 11);

-- --------------------------------------------------------

--
-- Структура таблицы `oc_option_description`
--

CREATE TABLE `oc_option_description` (
  `option_id` int(11) NOT NULL,
  `language_id` int(11) NOT NULL,
  `name` varchar(128) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_option_description`
--

INSERT INTO `oc_option_description` (`option_id`, `language_id`, `name`) VALUES
(1, 1, 'Radio'),
(2, 1, 'Checkbox'),
(4, 1, 'Text'),
(6, 1, 'Textarea'),
(8, 1, 'Date'),
(7, 1, 'File'),
(5, 1, 'Select'),
(9, 1, 'Time'),
(10, 1, 'Date &amp; Time'),
(12, 1, 'Delivery Date'),
(11, 1, 'Size'),
(1, 2, 'Radio'),
(2, 2, 'Checkbox'),
(4, 2, 'Text'),
(6, 2, 'Textarea'),
(8, 2, 'Date'),
(7, 2, 'File'),
(5, 2, 'Select'),
(9, 2, 'Time'),
(10, 2, 'Date &amp; Time'),
(12, 2, 'Delivery Date'),
(11, 2, 'Size');

-- --------------------------------------------------------

--
-- Структура таблицы `oc_option_value`
--

CREATE TABLE `oc_option_value` (
  `option_value_id` int(11) NOT NULL,
  `option_id` int(11) NOT NULL,
  `image` varchar(255) NOT NULL,
  `sort_order` int(3) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_option_value`
--

INSERT INTO `oc_option_value` (`option_value_id`, `option_id`, `image`, `sort_order`) VALUES
(43, 1, '', 3),
(32, 1, '', 1),
(45, 2, '', 4),
(44, 2, '', 3),
(42, 5, '', 4),
(41, 5, '', 3),
(39, 5, '', 1),
(40, 5, '', 2),
(31, 1, '', 2),
(23, 2, '', 1),
(24, 2, '', 2),
(46, 11, '', 1),
(47, 11, '', 2),
(48, 11, '', 3);

-- --------------------------------------------------------

--
-- Структура таблицы `oc_option_value_description`
--

CREATE TABLE `oc_option_value_description` (
  `option_value_id` int(11) NOT NULL,
  `language_id` int(11) NOT NULL,
  `option_id` int(11) NOT NULL,
  `name` varchar(128) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_option_value_description`
--

INSERT INTO `oc_option_value_description` (`option_value_id`, `language_id`, `option_id`, `name`) VALUES
(43, 1, 1, 'Large'),
(32, 1, 1, 'Small'),
(45, 1, 2, 'Checkbox 4'),
(44, 1, 2, 'Checkbox 3'),
(31, 1, 1, 'Medium'),
(42, 1, 5, 'Yellow'),
(41, 1, 5, 'Green'),
(39, 1, 5, 'Red'),
(40, 1, 5, 'Blue'),
(23, 1, 2, 'Checkbox 1'),
(24, 1, 2, 'Checkbox 2'),
(48, 1, 11, 'Large'),
(47, 1, 11, 'Medium'),
(46, 1, 11, 'Small'),
(43, 2, 1, 'Large'),
(32, 2, 1, 'Small'),
(45, 2, 2, 'Checkbox 4'),
(44, 2, 2, 'Checkbox 3'),
(31, 2, 1, 'Medium'),
(42, 2, 5, 'Yellow'),
(41, 2, 5, 'Green'),
(39, 2, 5, 'Red'),
(40, 2, 5, 'Blue'),
(23, 2, 2, 'Checkbox 1'),
(24, 2, 2, 'Checkbox 2'),
(48, 2, 11, 'Large'),
(47, 2, 11, 'Medium'),
(46, 2, 11, 'Small');

-- --------------------------------------------------------

--
-- Структура таблицы `oc_order`
--

CREATE TABLE `oc_order` (
  `order_id` int(11) NOT NULL,
  `invoice_no` int(11) NOT NULL DEFAULT 0,
  `invoice_prefix` varchar(26) NOT NULL,
  `store_id` int(11) NOT NULL DEFAULT 0,
  `store_name` varchar(64) NOT NULL,
  `store_url` varchar(255) NOT NULL,
  `customer_id` int(11) NOT NULL DEFAULT 0,
  `customer_group_id` int(11) NOT NULL DEFAULT 0,
  `firstname` varchar(32) NOT NULL,
  `lastname` varchar(32) NOT NULL,
  `email` varchar(96) NOT NULL,
  `telephone` varchar(32) NOT NULL,
  `fax` varchar(32) NOT NULL,
  `custom_field` text NOT NULL,
  `payment_firstname` varchar(32) NOT NULL,
  `payment_lastname` varchar(32) NOT NULL,
  `payment_company` varchar(60) NOT NULL,
  `payment_address_1` varchar(128) NOT NULL,
  `payment_address_2` varchar(128) NOT NULL,
  `payment_city` varchar(128) NOT NULL,
  `payment_postcode` varchar(10) NOT NULL,
  `payment_country` varchar(128) NOT NULL,
  `payment_country_id` int(11) NOT NULL,
  `payment_zone` varchar(128) NOT NULL,
  `payment_zone_id` int(11) NOT NULL,
  `payment_address_format` text NOT NULL,
  `payment_custom_field` text NOT NULL,
  `payment_method` varchar(128) NOT NULL,
  `payment_code` varchar(128) NOT NULL,
  `shipping_firstname` varchar(32) NOT NULL,
  `shipping_lastname` varchar(32) NOT NULL,
  `shipping_company` varchar(40) NOT NULL,
  `shipping_address_1` varchar(128) NOT NULL,
  `shipping_address_2` varchar(128) NOT NULL,
  `shipping_city` varchar(128) NOT NULL,
  `shipping_postcode` varchar(10) NOT NULL,
  `shipping_country` varchar(128) NOT NULL,
  `shipping_country_id` int(11) NOT NULL,
  `shipping_zone` varchar(128) NOT NULL,
  `shipping_zone_id` int(11) NOT NULL,
  `shipping_address_format` text NOT NULL,
  `shipping_custom_field` text NOT NULL,
  `shipping_method` varchar(128) NOT NULL,
  `shipping_code` varchar(128) NOT NULL,
  `comment` text NOT NULL,
  `total` decimal(15,4) NOT NULL DEFAULT 0.0000,
  `order_status_id` int(11) NOT NULL DEFAULT 0,
  `affiliate_id` int(11) NOT NULL,
  `commission` decimal(15,4) NOT NULL,
  `marketing_id` int(11) NOT NULL,
  `tracking` varchar(64) NOT NULL,
  `language_id` int(11) NOT NULL,
  `currency_id` int(11) NOT NULL,
  `currency_code` varchar(3) NOT NULL,
  `currency_value` decimal(15,8) NOT NULL DEFAULT 1.00000000,
  `ip` varchar(40) NOT NULL,
  `forwarded_ip` varchar(40) NOT NULL,
  `user_agent` varchar(255) NOT NULL,
  `accept_language` varchar(255) NOT NULL,
  `date_added` datetime NOT NULL,
  `date_modified` datetime NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_order`
--

INSERT INTO `oc_order` (`order_id`, `invoice_no`, `invoice_prefix`, `store_id`, `store_name`, `store_url`, `customer_id`, `customer_group_id`, `firstname`, `lastname`, `email`, `telephone`, `fax`, `custom_field`, `payment_firstname`, `payment_lastname`, `payment_company`, `payment_address_1`, `payment_address_2`, `payment_city`, `payment_postcode`, `payment_country`, `payment_country_id`, `payment_zone`, `payment_zone_id`, `payment_address_format`, `payment_custom_field`, `payment_method`, `payment_code`, `shipping_firstname`, `shipping_lastname`, `shipping_company`, `shipping_address_1`, `shipping_address_2`, `shipping_city`, `shipping_postcode`, `shipping_country`, `shipping_country_id`, `shipping_zone`, `shipping_zone_id`, `shipping_address_format`, `shipping_custom_field`, `shipping_method`, `shipping_code`, `comment`, `total`, `order_status_id`, `affiliate_id`, `commission`, `marketing_id`, `tracking`, `language_id`, `currency_id`, `currency_code`, `currency_value`, `ip`, `forwarded_ip`, `user_agent`, `accept_language`, `date_added`, `date_modified`) VALUES
(11, 0, 'INV-2020-00', 0, 'Название магазина', 'http://mafia.loc/', 0, 1, 'asdasd', 'asdasd', 'noemail@noemail.noemail', '132123123123', '', '[]', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', '', '', 220, '', 0, '', '[]', '', '', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', '', '', 220, '', 0, '', '[]', '', 'flat.flat', 'asdasdasdasd', '280.0000', 0, 0, '0.0000', 0, '', 2, 2, 'UAH', '1.00000000', '127.0.0.1', '', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.149 Safari/537.36', 'ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7,uk;q=0.6', '2020-04-01 02:35:00', '2020-04-01 03:14:09'),
(12, 0, 'INV-2020-00', 0, 'Название магазина', 'http://mafia.loc/', 0, 1, 'asdasd', 'asdasd', 'noemail@noemail.noemail', '132123123123', '', '[]', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', '', '', 220, '', 0, '', '[]', '', '', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', '', '', 220, '', 0, '', '[]', '', 'flat.flat', 'asdasdasdasd', '280.0000', 0, 0, '0.0000', 0, '', 2, 2, 'UAH', '1.00000000', '127.0.0.1', '', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.149 Safari/537.36', 'ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7,uk;q=0.6', '2020-04-01 02:36:05', '2020-04-01 03:13:54'),
(13, 0, 'INV-2020-00', 0, 'Название магазина', 'http://mafia.loc/', 0, 1, 'asdasd', 'asdasd', 'noemail@noemail.noemail', '132123123123', '', '[]', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', '', '', 220, '', 0, '', '[]', '', '', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', '', '', 220, '', 0, '', '[]', '', 'flat.flat', 'asdasdasdasd', '280.0000', 0, 0, '0.0000', 0, '', 2, 2, 'UAH', '1.00000000', '127.0.0.1', '', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.149 Safari/537.36', 'ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7,uk;q=0.6', '2020-04-01 02:36:07', '2020-04-01 03:13:58'),
(14, 0, 'INV-2020-00', 0, 'Название магазина', 'http://mafia.loc/', 0, 1, 'asdasd', 'asdasd', 'noemail@noemail.noemail', '132123123123', '', '[]', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', '', '', 220, '', 0, '', '[]', '', '', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', '', '', 220, '', 0, '', '[]', '', 'flat.flat', 'asdasdasdasd', '280.0000', 0, 0, '0.0000', 0, '', 2, 2, 'UAH', '1.00000000', '127.0.0.1', '', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.149 Safari/537.36', 'ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7,uk;q=0.6', '2020-04-01 02:36:08', '2020-04-01 03:14:01'),
(15, 0, 'INV-2020-00', 0, 'Название магазина', 'http://mafia.loc/', 0, 1, 'asdasd', 'asdasd', 'noemail@noemail.noemail', '132123123123', '', '[]', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', '', '', 220, '', 0, '', '[]', '', '', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', '', '', 220, '', 0, '', '[]', '', 'flat.flat', 'asdasdasdasd', '280.0000', 0, 0, '0.0000', 0, '', 2, 2, 'UAH', '1.00000000', '127.0.0.1', '', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.149 Safari/537.36', 'ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7,uk;q=0.6', '2020-04-01 02:36:27', '2020-04-01 03:14:15'),
(16, 0, 'INV-2020-00', 0, 'Название магазина', 'http://mafia.loc/', 0, 1, 'asdasd', 'asdasd', 'noemail@noemail.noemail', '132123123123', '', '[]', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', '', '', 220, '', 0, '', '[]', '', '', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', '', '', 220, '', 0, '', '[]', '', 'flat.flat', 'asdasdasdasd', '280.0000', 0, 0, '0.0000', 0, '', 2, 2, 'UAH', '1.00000000', '127.0.0.1', '', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.149 Safari/537.36', 'ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7,uk;q=0.6', '2020-04-01 02:37:48', '2020-04-01 03:14:13'),
(17, 0, 'INV-2020-00', 0, 'Название магазина', 'http://mafia.loc/', 0, 1, 'asdasd', 'asdasd', 'noemail@noemail.noemail', '132123123123', '', '[]', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', '', '', 220, '', 0, '', '[]', '', '', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', '', '', 220, '', 0, '', '[]', '', 'flat.flat', 'asdasdasdasd', '280.0000', 0, 0, '0.0000', 0, '', 2, 2, 'UAH', '1.00000000', '127.0.0.1', '', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.149 Safari/537.36', 'ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7,uk;q=0.6', '2020-04-01 02:43:15', '2020-04-01 03:14:17'),
(18, 0, 'INV-2020-00', 0, 'Название магазина', 'http://mafia.loc/', 0, 1, 'asdasd', 'asdasd', 'noemail@noemail.noemail', '132123123123', '', '[]', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', '', '', 220, '', 0, '', '[]', '', '', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', '', '', 220, '', 0, '', '[]', '', 'flat.flat', 'asdasdasdasd', '280.0000', 0, 0, '0.0000', 0, '', 2, 2, 'UAH', '1.00000000', '127.0.0.1', '', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.149 Safari/537.36', 'ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7,uk;q=0.6', '2020-04-01 02:44:06', '2020-04-01 03:14:18'),
(19, 0, 'INV-2020-00', 0, 'Название магазина', 'http://mafia.loc/', 0, 1, 'asdasd', 'asdasd', 'noemail@noemail.noemail', '132123123123', '', '[]', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', '', '', 220, '', 0, '', '[]', '', '', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', '', '', 220, '', 0, '', '[]', '', 'flat.flat', 'asdasdasdasd', '280.0000', 0, 0, '0.0000', 0, '', 2, 2, 'UAH', '1.00000000', '127.0.0.1', '', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.149 Safari/537.36', 'ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7,uk;q=0.6', '2020-04-01 02:44:07', '2020-04-01 03:14:19'),
(20, 0, 'INV-2020-00', 0, 'Название магазина', 'http://mafia.loc/', 0, 1, 'asdasd', 'asdasd', 'noemail@noemail.noemail', '132123123123', '', '[]', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', '', '', 220, '', 0, '', '[]', '', '', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', '', '', 220, '', 0, '', '[]', '', 'flat.flat', 'asdasdasdasd', '280.0000', 0, 0, '0.0000', 0, '', 2, 2, 'UAH', '1.00000000', '127.0.0.1', '', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.149 Safari/537.36', 'ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7,uk;q=0.6', '2020-04-01 02:44:07', '2020-04-01 03:14:20'),
(21, 0, 'INV-2020-00', 0, 'Название магазина', 'http://mafia.loc/', 0, 1, 'asdasd', 'asdasd', 'noemail@noemail.noemail', '132123123123', '', '[]', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', '', '', 220, '', 0, '', '[]', '', '', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', '', '', 220, '', 0, '', '[]', '', 'flat.flat', 'asdasdasdasd', '280.0000', 0, 0, '0.0000', 0, '', 2, 2, 'UAH', '1.00000000', '127.0.0.1', '', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.149 Safari/537.36', 'ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7,uk;q=0.6', '2020-04-01 02:44:08', '2020-04-01 03:14:21'),
(22, 0, 'INV-2020-00', 0, 'Название магазина', 'http://mafia.loc/', 0, 1, 'asdasd', 'asdasd', 'noemail@noemail.noemail', '132123123123', '', '[]', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', '', '', 220, '', 0, '', '[]', '', '', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', '', '', 220, '', 0, '', '[]', '', 'flat.flat', 'asdasdasdasd', '280.0000', 0, 0, '0.0000', 0, '', 2, 2, 'UAH', '1.00000000', '127.0.0.1', '', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.149 Safari/537.36', 'ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7,uk;q=0.6', '2020-04-01 02:44:09', '2020-04-01 03:14:22'),
(23, 0, 'INV-2020-00', 0, 'Название магазина', 'http://mafia.loc/', 0, 1, 'asdasd', 'asdasd', 'noemail@noemail.noemail', '132123123123', '', '[]', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', '', '', 220, '', 0, '', '[]', '', '', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', '', '', 220, '', 0, '', '[]', '', 'flat.flat', 'asdasdasdasd', '280.0000', 0, 0, '0.0000', 0, '', 2, 2, 'UAH', '1.00000000', '127.0.0.1', '', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.149 Safari/537.36', 'ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7,uk;q=0.6', '2020-04-01 02:45:34', '2020-04-01 03:14:23'),
(24, 0, 'INV-2020-00', 0, 'Название магазина', 'http://mafia.loc/', 0, 1, 'asdasd', 'asdasd', 'noemail@noemail.noemail', '132123123123', '', '[]', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', '', '', 220, '', 0, '', '[]', '', '', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', '', '', 220, '', 0, '', '[]', '', 'flat.flat', 'asdasdasdasd', '280.0000', 0, 0, '0.0000', 0, '', 2, 2, 'UAH', '1.00000000', '127.0.0.1', '', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.149 Safari/537.36', 'ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7,uk;q=0.6', '2020-04-01 02:46:07', '2020-04-01 03:14:24'),
(25, 0, 'INV-2020-00', 0, 'Название магазина', 'http://mafia.loc/', 0, 1, 'asdasd', 'asdasd', 'noemail@noemail.noemail', '132123123123', '', '[]', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', '', '', 220, '', 0, '', '[]', '', '', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', '', '', 220, '', 0, '', '[]', '', 'flat.flat', 'asdasdasdasd', '280.0000', 0, 0, '0.0000', 0, '', 2, 2, 'UAH', '1.00000000', '127.0.0.1', '', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.149 Safari/537.36', 'ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7,uk;q=0.6', '2020-04-01 02:46:49', '2020-04-01 03:14:25'),
(26, 0, 'INV-2020-00', 0, 'Название магазина', 'http://mafia.loc/', 0, 1, 'asdasd', 'asdasd', 'noemail@noemail.noemail', '132123123123', '', '[]', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', '', '', 220, '', 0, '', '[]', '', '', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', '', '', 220, '', 0, '', '[]', '', 'flat.flat', 'asdasdasdasd', '280.0000', 0, 0, '0.0000', 0, '', 2, 2, 'UAH', '1.00000000', '127.0.0.1', '', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.149 Safari/537.36', 'ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7,uk;q=0.6', '2020-04-01 02:47:08', '2020-04-01 03:14:26'),
(27, 0, 'INV-2020-00', 0, 'Название магазина', 'http://mafia.loc/', 0, 1, 'asdasd', 'asdasd', 'noemail@noemail.noemail', '132123123123', '', '[]', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', '', '', 220, '', 0, '', '[]', '', '', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', '', '', 220, '', 0, '', '[]', '', 'flat.flat', 'asdasdasdasd', '280.0000', 0, 0, '0.0000', 0, '', 2, 2, 'UAH', '1.00000000', '127.0.0.1', '', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.149 Safari/537.36', 'ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7,uk;q=0.6', '2020-04-01 02:48:55', '2020-04-01 03:14:27'),
(28, 0, 'INV-2020-00', 0, 'Название магазина', 'http://mafia.loc/', 0, 1, 'asdasd', 'asdasd', 'noemail@noemail.noemail', '132123123123', '', '[]', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', '', '', 220, '', 0, '', '[]', '', '', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', '', '', 220, '', 0, '', '[]', '', 'flat.flat', 'asdasdasdasd', '280.0000', 0, 0, '0.0000', 0, '', 2, 2, 'UAH', '1.00000000', '127.0.0.1', '', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.149 Safari/537.36', 'ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7,uk;q=0.6', '2020-04-01 02:49:04', '2020-04-01 03:14:27'),
(30, 0, 'INV-2020-00', 0, 'Название магазина', 'http://mafia.loc/', 0, 1, 'asdasd', 'asdasd', 'noemail@noemail.noemail', '132123123123', '', '[]', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', '', '', 220, '', 0, '', '[]', '', '', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', 'asdasd', '', '', 220, '', 0, '', '[]', '', 'flat.flat', 'asdasdasdasd', '280.0000', 0, 0, '0.0000', 0, '', 2, 2, 'UAH', '1.00000000', '127.0.0.1', '', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.149 Safari/537.36', 'ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7,uk;q=0.6', '2020-04-01 02:52:37', '2020-04-01 03:14:35'),
(39, 0, 'INV-2020-00', 0, 'Название магазина', 'http://mafia.loc/', 0, 1, 'Александр', 'Александр', 'noemail@noemail.noemail', '099-123-45-67', '', '[]', 'Александр', 'Александр', 'Александр', 'Александр', 'Александр', 'Александр', '', '', 220, '', 0, '', '[]', '', '', 'Александр', 'Александр', 'Александр', 'Александр', 'Александр', 'Александр', '', '', 220, '', 0, '', '[]', '', 'flat.flat', 'пр.Перемоги 62 кв.58. Звонок не работает!', '420.0000', 1, 0, '0.0000', 0, '', 2, 2, 'UAH', '1.00000000', '127.0.0.1', '', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.149 Safari/537.36', 'ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7,uk;q=0.6', '2020-04-02 13:37:25', '2020-04-02 13:37:25'),
(40, 0, 'INV-2020-00', 0, 'Название магазина', 'http://mafia.loc/', 0, 1, 'Григорий', 'Григорий', 'noemail@noemail.noemail', '097 55 11 444', '', '[]', 'Григорий', 'Григорий', 'Григорий', 'Григорий', 'Григорий', 'Григорий', '', '', 220, '', 0, '', '[]', '', '', 'Григорий', 'Григорий', 'Григорий', 'Григорий', 'Григорий', 'Григорий', '', '', 220, '', 0, '', '[]', '', 'flat.flat', 'Вишгород вул.Паркова 33а кв 51', '640.0000', 3, 0, '0.0000', 0, '', 2, 2, 'UAH', '1.00000000', '127.0.0.1', '', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.149 Safari/537.36', 'ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7,uk;q=0.6', '2020-04-02 13:55:47', '2020-04-02 13:56:33');

-- --------------------------------------------------------

--
-- Структура таблицы `oc_order_history`
--

CREATE TABLE `oc_order_history` (
  `order_history_id` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  `order_status_id` int(11) NOT NULL,
  `notify` tinyint(1) NOT NULL DEFAULT 0,
  `comment` text NOT NULL,
  `date_added` datetime NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_order_history`
--

INSERT INTO `oc_order_history` (`order_history_id`, `order_id`, `order_status_id`, `notify`, `comment`, `date_added`) VALUES
(23, 11, 0, 0, '', '2020-04-01 03:14:09'),
(21, 14, 0, 0, '', '2020-04-01 03:14:01'),
(20, 13, 0, 0, '', '2020-04-01 03:13:58'),
(19, 12, 0, 0, '', '2020-04-01 03:13:54'),
(24, 16, 0, 0, '', '2020-04-01 03:14:13'),
(25, 15, 0, 0, '', '2020-04-01 03:14:15'),
(26, 17, 0, 0, '', '2020-04-01 03:14:17'),
(27, 18, 0, 0, '', '2020-04-01 03:14:18'),
(28, 19, 0, 0, '', '2020-04-01 03:14:19'),
(29, 20, 0, 0, '', '2020-04-01 03:14:20'),
(30, 21, 0, 0, '', '2020-04-01 03:14:21'),
(31, 22, 0, 0, '', '2020-04-01 03:14:22'),
(32, 23, 0, 0, '', '2020-04-01 03:14:23'),
(33, 24, 0, 0, '', '2020-04-01 03:14:24'),
(34, 25, 0, 0, '', '2020-04-01 03:14:25'),
(35, 26, 0, 0, '', '2020-04-01 03:14:26'),
(36, 27, 0, 0, '', '2020-04-01 03:14:27'),
(37, 28, 0, 0, '', '2020-04-01 03:14:27'),
(39, 30, 0, 0, '', '2020-04-01 03:14:35'),
(43, 40, 3, 0, '', '2020-04-02 13:56:33');

-- --------------------------------------------------------

--
-- Структура таблицы `oc_order_option`
--

CREATE TABLE `oc_order_option` (
  `order_option_id` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  `order_product_id` int(11) NOT NULL,
  `product_option_id` int(11) NOT NULL,
  `product_option_value_id` int(11) NOT NULL DEFAULT 0,
  `name` varchar(255) NOT NULL,
  `value` text NOT NULL,
  `type` varchar(32) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `oc_order_product`
--

CREATE TABLE `oc_order_product` (
  `order_product_id` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `model` varchar(64) NOT NULL,
  `quantity` int(4) NOT NULL,
  `price` decimal(15,4) NOT NULL DEFAULT 0.0000,
  `total` decimal(15,4) NOT NULL DEFAULT 0.0000,
  `tax` decimal(15,4) NOT NULL DEFAULT 0.0000,
  `reward` int(8) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_order_product`
--

INSERT INTO `oc_order_product` (`order_product_id`, `order_id`, `product_id`, `name`, `model`, `quantity`, `price`, `total`, `tax`, `reward`) VALUES
(27, 12, 173, 'Бургер «Шакил О\'Нил»', '00005', 1, '100.0000', '100.0000', '0.0000', 0),
(26, 12, 50, 'Сет «Мітчел»', '00001', 1, '100.0000', '100.0000', '0.0000', 0),
(25, 11, 71, 'Сашимі «Угорь»', '00002', 1, '80.0000', '80.0000', '0.0000', 0),
(23, 11, 50, 'Сет «Мітчел»', '00001', 1, '100.0000', '100.0000', '0.0000', 0),
(24, 11, 173, 'Бургер «Шакил О\'Нил»', '00005', 1, '100.0000', '100.0000', '0.0000', 0),
(28, 12, 71, 'Сашимі «Угорь»', '00002', 1, '80.0000', '80.0000', '0.0000', 0),
(29, 13, 50, 'Сет «Мітчел»', '00001', 1, '100.0000', '100.0000', '0.0000', 0),
(30, 13, 173, 'Бургер «Шакил О\'Нил»', '00005', 1, '100.0000', '100.0000', '0.0000', 0),
(31, 13, 71, 'Сашимі «Угорь»', '00002', 1, '80.0000', '80.0000', '0.0000', 0),
(32, 14, 50, 'Сет «Мітчел»', '00001', 1, '100.0000', '100.0000', '0.0000', 0),
(33, 14, 173, 'Бургер «Шакил О\'Нил»', '00005', 1, '100.0000', '100.0000', '0.0000', 0),
(34, 14, 71, 'Сашимі «Угорь»', '00002', 1, '80.0000', '80.0000', '0.0000', 0),
(35, 15, 50, 'Сет «Мітчел»', '00001', 1, '100.0000', '100.0000', '0.0000', 0),
(36, 15, 173, 'Бургер «Шакил О\'Нил»', '00005', 1, '100.0000', '100.0000', '0.0000', 0),
(37, 15, 71, 'Сашимі «Угорь»', '00002', 1, '80.0000', '80.0000', '0.0000', 0),
(38, 16, 50, 'Сет «Мітчел»', '00001', 1, '100.0000', '100.0000', '0.0000', 0),
(39, 16, 173, 'Бургер «Шакил О\'Нил»', '00005', 1, '100.0000', '100.0000', '0.0000', 0),
(40, 16, 71, 'Сашимі «Угорь»', '00002', 1, '80.0000', '80.0000', '0.0000', 0),
(41, 17, 50, 'Сет «Мітчел»', '00001', 1, '100.0000', '100.0000', '0.0000', 0),
(42, 17, 173, 'Бургер «Шакил О\'Нил»', '00005', 1, '100.0000', '100.0000', '0.0000', 0),
(43, 17, 71, 'Сашимі «Угорь»', '00002', 1, '80.0000', '80.0000', '0.0000', 0),
(44, 18, 50, 'Сет «Мітчел»', '00001', 1, '100.0000', '100.0000', '0.0000', 0),
(45, 18, 173, 'Бургер «Шакил О\'Нил»', '00005', 1, '100.0000', '100.0000', '0.0000', 0),
(46, 18, 71, 'Сашимі «Угорь»', '00002', 1, '80.0000', '80.0000', '0.0000', 0),
(47, 19, 50, 'Сет «Мітчел»', '00001', 1, '100.0000', '100.0000', '0.0000', 0),
(48, 19, 173, 'Бургер «Шакил О\'Нил»', '00005', 1, '100.0000', '100.0000', '0.0000', 0),
(49, 19, 71, 'Сашимі «Угорь»', '00002', 1, '80.0000', '80.0000', '0.0000', 0),
(50, 20, 50, 'Сет «Мітчел»', '00001', 1, '100.0000', '100.0000', '0.0000', 0),
(51, 20, 173, 'Бургер «Шакил О\'Нил»', '00005', 1, '100.0000', '100.0000', '0.0000', 0),
(52, 20, 71, 'Сашимі «Угорь»', '00002', 1, '80.0000', '80.0000', '0.0000', 0),
(53, 21, 50, 'Сет «Мітчел»', '00001', 1, '100.0000', '100.0000', '0.0000', 0),
(54, 21, 173, 'Бургер «Шакил О\'Нил»', '00005', 1, '100.0000', '100.0000', '0.0000', 0),
(55, 21, 71, 'Сашимі «Угорь»', '00002', 1, '80.0000', '80.0000', '0.0000', 0),
(56, 22, 50, 'Сет «Мітчел»', '00001', 1, '100.0000', '100.0000', '0.0000', 0),
(57, 22, 173, 'Бургер «Шакил О\'Нил»', '00005', 1, '100.0000', '100.0000', '0.0000', 0),
(58, 22, 71, 'Сашимі «Угорь»', '00002', 1, '80.0000', '80.0000', '0.0000', 0),
(59, 23, 50, 'Сет «Мітчел»', '00001', 1, '100.0000', '100.0000', '0.0000', 0),
(60, 23, 173, 'Бургер «Шакил О\'Нил»', '00005', 1, '100.0000', '100.0000', '0.0000', 0),
(61, 23, 71, 'Сашимі «Угорь»', '00002', 1, '80.0000', '80.0000', '0.0000', 0),
(62, 24, 50, 'Сет «Мітчел»', '00001', 1, '100.0000', '100.0000', '0.0000', 0),
(63, 24, 173, 'Бургер «Шакил О\'Нил»', '00005', 1, '100.0000', '100.0000', '0.0000', 0),
(64, 24, 71, 'Сашимі «Угорь»', '00002', 1, '80.0000', '80.0000', '0.0000', 0),
(65, 25, 50, 'Сет «Мітчел»', '00001', 1, '100.0000', '100.0000', '0.0000', 0),
(66, 25, 173, 'Бургер «Шакил О\'Нил»', '00005', 1, '100.0000', '100.0000', '0.0000', 0),
(67, 25, 71, 'Сашимі «Угорь»', '00002', 1, '80.0000', '80.0000', '0.0000', 0),
(68, 26, 50, 'Сет «Мітчел»', '00001', 1, '100.0000', '100.0000', '0.0000', 0),
(69, 26, 173, 'Бургер «Шакил О\'Нил»', '00005', 1, '100.0000', '100.0000', '0.0000', 0),
(70, 26, 71, 'Сашимі «Угорь»', '00002', 1, '80.0000', '80.0000', '0.0000', 0),
(71, 27, 50, 'Сет «Мітчел»', '00001', 1, '100.0000', '100.0000', '0.0000', 0),
(72, 27, 173, 'Бургер «Шакил О\'Нил»', '00005', 1, '100.0000', '100.0000', '0.0000', 0),
(73, 27, 71, 'Сашимі «Угорь»', '00002', 1, '80.0000', '80.0000', '0.0000', 0),
(74, 28, 50, 'Сет «Мітчел»', '00001', 1, '100.0000', '100.0000', '0.0000', 0),
(75, 28, 173, 'Бургер «Шакил О\'Нил»', '00005', 1, '100.0000', '100.0000', '0.0000', 0),
(76, 28, 71, 'Сашимі «Угорь»', '00002', 1, '80.0000', '80.0000', '0.0000', 0),
(80, 30, 50, 'Сет «Мітчел»', '00001', 1, '100.0000', '100.0000', '0.0000', 0),
(81, 30, 173, 'Бургер «Шакил О\'Нил»', '00005', 1, '100.0000', '100.0000', '0.0000', 0),
(82, 30, 71, 'Сашимі «Угорь»', '00002', 1, '80.0000', '80.0000', '0.0000', 0),
(107, 39, 244, 'Напій Coca Cola', '20003', 4, '35.0000', '140.0000', '0.0000', 0),
(108, 39, 173, 'Бургер «Шакил О\'Нил»', '00005', 1, '100.0000', '100.0000', '0.0000', 0),
(109, 39, 50, 'Сет «Мітчел»', '00001', 1, '100.0000', '100.0000', '0.0000', 0),
(110, 39, 71, 'Сашимі «Угорь»', '00002', 1, '80.0000', '80.0000', '0.0000', 0),
(111, 40, 244, 'Напій Coca Cola', '20003', 4, '35.0000', '140.0000', '0.0000', 0),
(112, 40, 344, 'Шашлык из свинины от Marinara', '00006', 10, '50.0000', '500.0000', '0.0000', 0);

-- --------------------------------------------------------

--
-- Структура таблицы `oc_order_recurring`
--

CREATE TABLE `oc_order_recurring` (
  `order_recurring_id` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  `reference` varchar(255) NOT NULL,
  `product_id` int(11) NOT NULL,
  `product_name` varchar(255) NOT NULL,
  `product_quantity` int(11) NOT NULL,
  `recurring_id` int(11) NOT NULL,
  `recurring_name` varchar(255) NOT NULL,
  `recurring_description` varchar(255) NOT NULL,
  `recurring_frequency` varchar(25) NOT NULL,
  `recurring_cycle` smallint(6) NOT NULL,
  `recurring_duration` smallint(6) NOT NULL,
  `recurring_price` decimal(10,4) NOT NULL,
  `trial` tinyint(1) NOT NULL,
  `trial_frequency` varchar(25) NOT NULL,
  `trial_cycle` smallint(6) NOT NULL,
  `trial_duration` smallint(6) NOT NULL,
  `trial_price` decimal(10,4) NOT NULL,
  `status` tinyint(4) NOT NULL,
  `date_added` datetime NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `oc_order_recurring_transaction`
--

CREATE TABLE `oc_order_recurring_transaction` (
  `order_recurring_transaction_id` int(11) NOT NULL,
  `order_recurring_id` int(11) NOT NULL,
  `reference` varchar(255) NOT NULL,
  `type` varchar(255) NOT NULL,
  `amount` decimal(10,4) NOT NULL,
  `date_added` datetime NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `oc_order_shipment`
--

CREATE TABLE `oc_order_shipment` (
  `order_shipment_id` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  `date_added` datetime NOT NULL,
  `shipping_courier_id` varchar(255) NOT NULL DEFAULT '',
  `tracking_number` varchar(255) NOT NULL DEFAULT ''
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `oc_order_status`
--

CREATE TABLE `oc_order_status` (
  `order_status_id` int(11) NOT NULL,
  `language_id` int(11) NOT NULL,
  `name` varchar(32) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_order_status`
--

INSERT INTO `oc_order_status` (`order_status_id`, `language_id`, `name`) VALUES
(1, 1, 'Ожидание'),
(2, 1, 'В обработке'),
(3, 1, 'Доставлено'),
(7, 1, 'Отменено'),
(5, 1, 'Сделка завершена'),
(8, 1, 'Возврат'),
(9, 1, 'Отмена и аннулирование'),
(10, 1, 'Неудавшийся'),
(11, 1, 'Возмещенный'),
(12, 1, 'Полностью измененный'),
(13, 1, 'Полный возврат'),
(16, 1, 'Аннулированный'),
(15, 1, 'Обработанный'),
(14, 1, 'Просроченный'),
(1, 2, 'Ожидание'),
(2, 2, 'В обработке'),
(3, 2, 'Доставлено'),
(7, 2, 'Отменено'),
(5, 2, 'Сделка завершена'),
(8, 2, 'Возврат'),
(9, 2, 'Отмена и аннулирование'),
(10, 2, 'Неудавшийся'),
(11, 2, 'Возмещенный'),
(12, 2, 'Полностью измененный'),
(13, 2, 'Полный возврат'),
(16, 2, 'Аннулированный'),
(15, 2, 'Обработанный'),
(14, 2, 'Просроченный');

-- --------------------------------------------------------

--
-- Структура таблицы `oc_order_total`
--

CREATE TABLE `oc_order_total` (
  `order_total_id` int(10) NOT NULL,
  `order_id` int(11) NOT NULL,
  `code` varchar(32) NOT NULL,
  `title` varchar(255) NOT NULL,
  `value` decimal(15,4) NOT NULL DEFAULT 0.0000,
  `sort_order` int(3) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_order_total`
--

INSERT INTO `oc_order_total` (`order_total_id`, `order_id`, `code`, `title`, `value`, `sort_order`) VALUES
(51, 39, 'sub_total', 'Разом', '420.0000', 0),
(52, 40, 'sub_total', 'Разом', '640.0000', 0);

-- --------------------------------------------------------

--
-- Структура таблицы `oc_order_voucher`
--

CREATE TABLE `oc_order_voucher` (
  `order_voucher_id` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  `voucher_id` int(11) NOT NULL,
  `description` varchar(255) NOT NULL,
  `code` varchar(10) NOT NULL,
  `from_name` varchar(64) NOT NULL,
  `from_email` varchar(96) NOT NULL,
  `to_name` varchar(64) NOT NULL,
  `to_email` varchar(96) NOT NULL,
  `voucher_theme_id` int(11) NOT NULL,
  `message` text NOT NULL,
  `amount` decimal(15,4) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `oc_product`
--

CREATE TABLE `oc_product` (
  `product_id` int(11) NOT NULL,
  `model` varchar(64) NOT NULL,
  `sku` varchar(64) NOT NULL,
  `upc` varchar(12) NOT NULL,
  `ean` varchar(14) NOT NULL,
  `jan` varchar(13) NOT NULL,
  `isbn` varchar(17) NOT NULL,
  `mpn` varchar(64) NOT NULL,
  `location` varchar(128) NOT NULL,
  `quantity` int(4) NOT NULL DEFAULT 0,
  `stock_status_id` int(11) NOT NULL,
  `image` varchar(255) DEFAULT NULL,
  `manufacturer_id` int(11) NOT NULL,
  `shipping` tinyint(1) NOT NULL DEFAULT 1,
  `price` decimal(15,4) NOT NULL DEFAULT 0.0000,
  `points` int(8) NOT NULL DEFAULT 0,
  `tax_class_id` int(11) NOT NULL,
  `date_available` date NOT NULL DEFAULT '0000-00-00',
  `weight` decimal(15,8) NOT NULL DEFAULT 0.00000000,
  `weight_class_id` int(11) NOT NULL DEFAULT 0,
  `length` decimal(15,8) NOT NULL DEFAULT 0.00000000,
  `width` decimal(15,8) NOT NULL DEFAULT 0.00000000,
  `height` decimal(15,8) NOT NULL DEFAULT 0.00000000,
  `length_class_id` int(11) NOT NULL DEFAULT 0,
  `subtract` tinyint(1) NOT NULL DEFAULT 1,
  `minimum` int(11) NOT NULL DEFAULT 1,
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `status` tinyint(1) NOT NULL DEFAULT 0,
  `viewed` int(5) NOT NULL DEFAULT 0,
  `date_added` datetime NOT NULL,
  `date_modified` datetime NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_product`
--

INSERT INTO `oc_product` (`product_id`, `model`, `sku`, `upc`, `ean`, `jan`, `isbn`, `mpn`, `location`, `quantity`, `stock_status_id`, `image`, `manufacturer_id`, `shipping`, `price`, `points`, `tax_class_id`, `date_available`, `weight`, `weight_class_id`, `length`, `width`, `height`, `length_class_id`, `subtract`, `minimum`, `sort_order`, `status`, `viewed`, `date_added`, `date_modified`) VALUES
(347, '00006', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/200596-405-336-shish_kebab_of_pork_228x228.jpg', 0, 1, '79.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:15:17', '2020-03-30 15:15:17'),
(348, '00006', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/200596-405-336-shish_kebab_of_pork_228x228.jpg', 0, 1, '79.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:15:17', '2020-03-30 15:15:17'),
(178, '00004', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/388005-405-336-firmennaya.jpg', 0, 1, '122.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 2, '2020-03-30 14:01:04', '2020-03-30 15:12:50'),
(346, '00006', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/200596-405-336-shish_kebab_of_pork_228x228.jpg', 0, 1, '79.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:15:17', '2020-03-30 15:15:17'),
(345, '00006', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/200596-405-336-shish_kebab_of_pork_228x228.jpg', 0, 1, '79.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:15:12', '2020-03-30 15:15:12'),
(344, '00006', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/200596-405-336-shish_kebab_of_pork_228x228.jpg', 0, 1, '79.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 4, '2020-03-30 15:15:12', '2020-03-30 15:15:12'),
(343, '00006', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/200596-405-336-shish_kebab_of_pork_228x228.jpg', 0, 1, '79.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:15:12', '2020-03-30 15:15:12'),
(183, '00007', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/441833-405-336-tyahan_s_kuriczej.png', 0, 1, '100.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 2, '2020-03-30 14:01:04', '2020-03-30 15:13:05'),
(342, '00006', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/200596-405-336-shish_kebab_of_pork_228x228.jpg', 0, 1, '79.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 1, '2020-03-30 15:15:12', '2020-03-30 15:15:12'),
(341, '00001', '', '', '', '', '', '', '', 1, 7, 'catalog/Product/441733-405-336-mitchel.jpg', 0, 1, '199.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 1, '2020-03-30 15:15:12', '2020-03-30 15:15:12'),
(339, '00001', '', '', '', '', '', '', '', 1, 7, 'catalog/Product/441733-405-336-mitchel.jpg', 0, 1, '199.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:15:12', '2020-03-30 15:15:12'),
(340, '00001', '', '', '', '', '', '', '', 1, 7, 'catalog/Product/441733-405-336-mitchel.jpg', 0, 1, '199.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:15:12', '2020-03-30 15:15:12'),
(50, '00001', '', '', '', '', '', '', '', 1, 7, 'catalog/Product/441733-405-336-mitchel.jpg', 0, 1, '199.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 40, '2020-03-30 12:34:28', '2020-03-30 15:13:39'),
(350, '00006', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/200596-405-336-shish_kebab_of_pork_228x228.jpg', 0, 1, '79.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:15:17', '2020-03-30 15:15:17'),
(351, '00006', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/200596-405-336-shish_kebab_of_pork_228x228.jpg', 0, 1, '79.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:15:17', '2020-03-30 15:15:17'),
(352, '00006', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/200596-405-336-shish_kebab_of_pork_228x228.jpg', 0, 1, '79.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:15:17', '2020-03-30 15:15:17'),
(173, '00005', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/473387-405-336-Shakil.jpg', 0, 1, '145.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 1, 1, 1, 1, 37, '2020-03-30 14:01:04', '2020-04-14 11:49:11'),
(311, '00006', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/200596-405-336-shish_kebab_of_pork_228x228.jpg', 0, 1, '79.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:14:53', '2020-03-30 15:14:53'),
(312, '00004', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/388005-405-336-firmennaya.jpg', 0, 1, '122.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:14:59', '2020-03-30 15:14:59'),
(71, '00002', '', '', '', '', '', '', '', 1, 7, 'catalog/Product/441477-405-336-sashimi_ugor.png', 0, 1, '99.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 7, '2020-03-30 12:46:12', '2020-03-30 15:13:19'),
(338, '00001', '', '', '', '', '', '', '', 1, 7, 'catalog/Product/441733-405-336-mitchel.jpg', 0, 1, '199.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:15:12', '2020-03-30 15:15:12'),
(328, '00002', '', '', '', '', '', '', '', 1, 7, 'catalog/Product/441477-405-336-sashimi_ugor.png', 0, 1, '99.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 8, '2020-03-30 15:15:00', '2020-03-30 15:15:00'),
(329, '00002', '', '', '', '', '', '', '', 1, 7, 'catalog/Product/441477-405-336-sashimi_ugor.png', 0, 1, '99.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:15:00', '2020-03-30 15:15:00'),
(330, '00002', '', '', '', '', '', '', '', 1, 7, 'catalog/Product/441477-405-336-sashimi_ugor.png', 0, 1, '99.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 11, '2020-03-30 15:15:00', '2020-03-30 15:15:00'),
(331, '00002', '', '', '', '', '', '', '', 1, 7, 'catalog/Product/441477-405-336-sashimi_ugor.png', 0, 1, '99.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:15:00', '2020-03-30 15:15:00'),
(332, '00002', '', '', '', '', '', '', '', 1, 7, 'catalog/Product/441477-405-336-sashimi_ugor.png', 0, 1, '99.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:15:11', '2020-03-30 15:15:11'),
(333, '00002', '', '', '', '', '', '', '', 1, 7, 'catalog/Product/441477-405-336-sashimi_ugor.png', 0, 1, '99.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:15:12', '2020-03-30 15:15:12'),
(334, '00002', '', '', '', '', '', '', '', 1, 7, 'catalog/Product/441477-405-336-sashimi_ugor.png', 0, 1, '99.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:15:12', '2020-03-30 15:15:12'),
(335, '00002', '', '', '', '', '', '', '', 1, 7, 'catalog/Product/441477-405-336-sashimi_ugor.png', 0, 1, '99.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:15:12', '2020-03-30 15:15:12'),
(336, '00001', '', '', '', '', '', '', '', 1, 7, 'catalog/Product/441733-405-336-mitchel.jpg', 0, 1, '199.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:15:12', '2020-03-30 15:15:12'),
(337, '00001', '', '', '', '', '', '', '', 1, 7, 'catalog/Product/441733-405-336-mitchel.jpg', 0, 1, '199.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 1, '2020-03-30 15:15:12', '2020-03-30 15:15:12'),
(276, '00004', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/388005-405-336-firmennaya.jpg', 0, 1, '122.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:14:25', '2020-03-30 15:14:25'),
(146, '00006', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/200596-405-336-shish_kebab_of_pork_228x228.jpg', 0, 1, '79.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 57, '2020-03-30 14:00:59', '2020-03-30 15:13:50'),
(277, '00007', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/441833-405-336-tyahan_s_kuriczej.png', 0, 1, '100.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:14:25', '2020-03-30 15:14:25'),
(278, '00002', '', '', '', '', '', '', '', 1, 7, 'catalog/Product/441477-405-336-sashimi_ugor.png', 0, 1, '99.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:14:25', '2020-03-30 15:14:25'),
(279, '00001', '', '', '', '', '', '', '', 1, 7, 'catalog/Product/441733-405-336-mitchel.jpg', 0, 1, '199.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:14:25', '2020-03-30 15:14:25'),
(280, '00006', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/200596-405-336-shish_kebab_of_pork_228x228.jpg', 0, 1, '79.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:14:25', '2020-03-30 15:14:25'),
(281, '00004', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/388005-405-336-firmennaya.jpg', 0, 1, '122.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:14:35', '2020-03-30 15:14:35'),
(282, '00004', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/388005-405-336-firmennaya.jpg', 0, 1, '122.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:14:35', '2020-03-30 15:14:35'),
(283, '00007', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/441833-405-336-tyahan_s_kuriczej.png', 0, 1, '100.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:14:35', '2020-03-30 15:14:35'),
(284, '00007', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/441833-405-336-tyahan_s_kuriczej.png', 0, 1, '100.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:14:35', '2020-03-30 15:14:35'),
(285, '00002', '', '', '', '', '', '', '', 1, 7, 'catalog/Product/441477-405-336-sashimi_ugor.png', 0, 1, '99.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 2, '2020-03-30 15:14:35', '2020-03-30 15:14:35'),
(286, '00002', '', '', '', '', '', '', '', 1, 7, 'catalog/Product/441477-405-336-sashimi_ugor.png', 0, 1, '99.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:14:35', '2020-03-30 15:14:35'),
(287, '00001', '', '', '', '', '', '', '', 1, 7, 'catalog/Product/441733-405-336-mitchel.jpg', 0, 1, '199.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:14:35', '2020-03-30 15:14:35'),
(288, '00004', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/388005-405-336-firmennaya.jpg', 0, 1, '122.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:14:44', '2020-03-30 15:14:44'),
(289, '00004', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/388005-405-336-firmennaya.jpg', 0, 1, '122.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:14:44', '2020-03-30 15:14:44'),
(290, '00004', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/388005-405-336-firmennaya.jpg', 0, 1, '122.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:14:44', '2020-03-30 15:14:44'),
(291, '00004', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/388005-405-336-firmennaya.jpg', 0, 1, '122.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:14:44', '2020-03-30 15:14:44'),
(292, '00007', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/441833-405-336-tyahan_s_kuriczej.png', 0, 1, '100.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:14:44', '2020-03-30 15:14:44'),
(293, '00007', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/441833-405-336-tyahan_s_kuriczej.png', 0, 1, '100.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:14:44', '2020-03-30 15:14:44'),
(294, '00007', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/441833-405-336-tyahan_s_kuriczej.png', 0, 1, '100.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:14:44', '2020-03-30 15:14:44'),
(295, '00004', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/388005-405-336-firmennaya.jpg', 0, 1, '122.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:14:53', '2020-03-30 15:14:53'),
(296, '00007', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/441833-405-336-tyahan_s_kuriczej.png', 0, 1, '100.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:14:53', '2020-03-30 15:14:53'),
(297, '00007', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/441833-405-336-tyahan_s_kuriczej.png', 0, 1, '100.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:14:53', '2020-03-30 15:14:53'),
(298, '00007', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/441833-405-336-tyahan_s_kuriczej.png', 0, 1, '100.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:14:53', '2020-03-30 15:14:53'),
(299, '00007', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/441833-405-336-tyahan_s_kuriczej.png', 0, 1, '100.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:14:53', '2020-03-30 15:14:53'),
(300, '00007', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/441833-405-336-tyahan_s_kuriczej.png', 0, 1, '100.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:14:53', '2020-03-30 15:14:53'),
(301, '00007', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/441833-405-336-tyahan_s_kuriczej.png', 0, 1, '100.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:14:53', '2020-03-30 15:14:53'),
(302, '00007', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/441833-405-336-tyahan_s_kuriczej.png', 0, 1, '100.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:14:53', '2020-03-30 15:14:53'),
(303, '00002', '', '', '', '', '', '', '', 1, 7, 'catalog/Product/441477-405-336-sashimi_ugor.png', 0, 1, '99.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:14:53', '2020-03-30 15:14:53'),
(304, '00002', '', '', '', '', '', '', '', 1, 7, 'catalog/Product/441477-405-336-sashimi_ugor.png', 0, 1, '99.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:14:53', '2020-03-30 15:14:53'),
(305, '00002', '', '', '', '', '', '', '', 1, 7, 'catalog/Product/441477-405-336-sashimi_ugor.png', 0, 1, '99.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:14:53', '2020-03-30 15:14:53'),
(306, '00002', '', '', '', '', '', '', '', 1, 7, 'catalog/Product/441477-405-336-sashimi_ugor.png', 0, 1, '99.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:14:53', '2020-03-30 15:14:53'),
(307, '00001', '', '', '', '', '', '', '', 1, 7, 'catalog/Product/441733-405-336-mitchel.jpg', 0, 1, '199.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:14:53', '2020-03-30 15:14:53'),
(308, '00001', '', '', '', '', '', '', '', 1, 7, 'catalog/Product/441733-405-336-mitchel.jpg', 0, 1, '199.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:14:53', '2020-03-30 15:14:53'),
(309, '00001', '', '', '', '', '', '', '', 1, 7, 'catalog/Product/441733-405-336-mitchel.jpg', 0, 1, '199.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:14:53', '2020-03-30 15:14:53'),
(256, '00005', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/473387-405-336-Shakil.jpg', 0, 1, '145.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:11:21', '2020-03-30 15:11:21'),
(257, '00005', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/473387-405-336-Shakil.jpg', 0, 1, '145.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:11:21', '2020-03-30 15:11:21'),
(258, '00005', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/473387-405-336-Shakil.jpg', 0, 1, '145.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:11:21', '2020-03-30 15:11:21'),
(259, '00005', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/473387-405-336-Shakil.jpg', 0, 1, '145.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:11:21', '2020-03-30 15:11:21'),
(260, '00005', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/473387-405-336-Shakil.jpg', 0, 1, '145.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:11:34', '2020-03-30 15:11:34'),
(261, '00005', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/473387-405-336-Shakil.jpg', 0, 1, '145.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:11:34', '2020-03-30 15:11:34'),
(262, '00005', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/473387-405-336-Shakil.jpg', 0, 1, '145.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:11:34', '2020-03-30 15:11:34'),
(263, '00005', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/473387-405-336-Shakil.jpg', 0, 1, '145.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:11:34', '2020-03-30 15:11:34'),
(264, '00005', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/473387-405-336-Shakil.jpg', 0, 1, '145.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:11:34', '2020-03-30 15:11:34'),
(265, '00005', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/473387-405-336-Shakil.jpg', 0, 1, '145.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:11:34', '2020-03-30 15:11:34'),
(266, '00005', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/473387-405-336-Shakil.jpg', 0, 1, '145.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:11:34', '2020-03-30 15:11:34'),
(267, '00005', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/473387-405-336-Shakil.jpg', 0, 1, '145.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:11:34', '2020-03-30 15:11:34'),
(268, '00005', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/473387-405-336-Shakil.jpg', 0, 1, '145.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:11:34', '2020-03-30 15:11:34'),
(269, '00005', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/473387-405-336-Shakil.jpg', 0, 1, '145.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 1, '2020-03-30 15:11:34', '2020-03-30 15:11:34'),
(270, '00005', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/473387-405-336-Shakil.jpg', 0, 1, '145.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:11:34', '2020-03-30 15:11:34'),
(271, '00005', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/473387-405-336-Shakil.jpg', 0, 1, '145.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:11:34', '2020-03-30 15:11:34'),
(272, '00005', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/473387-405-336-Shakil.jpg', 0, 1, '145.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:11:34', '2020-03-30 15:11:34'),
(273, '00005', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/473387-405-336-Shakil.jpg', 0, 1, '145.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:11:34', '2020-03-30 15:11:34'),
(274, '00005', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/473387-405-336-Shakil.jpg', 0, 1, '145.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:11:34', '2020-03-30 15:11:34'),
(275, '00005', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/473387-405-336-Shakil.jpg', 0, 1, '145.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:11:34', '2020-03-30 15:11:34'),
(313, '00004', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/388005-405-336-firmennaya.jpg', 0, 1, '122.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:14:59', '2020-03-30 15:14:59'),
(314, '00007', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/441833-405-336-tyahan_s_kuriczej.png', 0, 1, '100.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:14:59', '2020-03-30 15:14:59'),
(315, '00007', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/441833-405-336-tyahan_s_kuriczej.png', 0, 1, '100.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:14:59', '2020-03-30 15:14:59'),
(316, '00007', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/441833-405-336-tyahan_s_kuriczej.png', 0, 1, '100.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:14:59', '2020-03-30 15:14:59'),
(317, '00007', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/441833-405-336-tyahan_s_kuriczej.png', 0, 1, '100.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:14:59', '2020-03-30 15:14:59'),
(318, '00007', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/441833-405-336-tyahan_s_kuriczej.png', 0, 1, '100.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:14:59', '2020-03-30 15:14:59'),
(319, '00007', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/441833-405-336-tyahan_s_kuriczej.png', 0, 1, '100.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:14:59', '2020-03-30 15:14:59'),
(320, '00007', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/441833-405-336-tyahan_s_kuriczej.png', 0, 1, '100.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:14:59', '2020-03-30 15:14:59'),
(321, '00007', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/441833-405-336-tyahan_s_kuriczej.png', 0, 1, '100.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:14:59', '2020-03-30 15:14:59'),
(322, '00007', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/441833-405-336-tyahan_s_kuriczej.png', 0, 1, '100.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:14:59', '2020-03-30 15:14:59'),
(323, '00007', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/441833-405-336-tyahan_s_kuriczej.png', 0, 1, '100.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:14:59', '2020-03-30 15:14:59'),
(324, '00007', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/441833-405-336-tyahan_s_kuriczej.png', 0, 1, '100.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:14:59', '2020-03-30 15:14:59'),
(325, '00007', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/441833-405-336-tyahan_s_kuriczej.png', 0, 1, '100.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:14:59', '2020-03-30 15:14:59'),
(326, '00007', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/441833-405-336-tyahan_s_kuriczej.png', 0, 1, '100.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:14:59', '2020-03-30 15:14:59'),
(255, '00005', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/473387-405-336-Shakil.jpg', 0, 1, '145.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:11:21', '2020-03-30 15:11:21'),
(254, '00005', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/473387-405-336-Shakil.jpg', 0, 1, '145.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:11:21', '2020-03-30 15:11:21'),
(253, '00005', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/473387-405-336-Shakil.jpg', 0, 1, '145.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 3, '2020-03-30 15:11:21', '2020-03-30 15:11:21'),
(252, '00005', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/473387-405-336-Shakil.jpg', 0, 1, '145.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:11:21', '2020-03-30 15:11:21'),
(251, '00005', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/473387-405-336-Shakil.jpg', 0, 1, '145.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:11:11', '2020-03-30 15:11:11'),
(250, '00005', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/473387-405-336-Shakil.jpg', 0, 1, '145.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:11:11', '2020-03-30 15:11:11'),
(249, '00005', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/473387-405-336-Shakil.jpg', 0, 1, '145.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:11:11', '2020-03-30 15:11:11'),
(248, '00005', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/473387-405-336-Shakil.jpg', 0, 1, '145.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:11:11', '2020-03-30 15:11:11'),
(247, '00005', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/473387-405-336-Shakil.jpg', 0, 1, '145.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:11:05', '2020-03-30 15:11:05'),
(244, '20003', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/Coca-Cola(0.5)-800x800.png', 0, 1, '35.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 148, '2020-03-30 15:07:25', '2020-03-30 20:30:11'),
(245, '00005', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/473387-405-336-Shakil.jpg', 0, 1, '145.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 1, 1, 1, 1, 1, '2020-03-30 15:07:56', '2020-04-14 11:54:17'),
(246, '00005', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/473387-405-336-Shakil.jpg', 0, 1, '145.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:11:05', '2020-03-30 15:11:05'),
(310, '00006', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/200596-405-336-shish_kebab_of_pork_228x228.jpg', 0, 1, '79.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:14:53', '2020-03-30 15:14:53'),
(349, '00006', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/200596-405-336-shish_kebab_of_pork_228x228.jpg', 0, 1, '79.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:15:17', '2020-03-30 15:15:17'),
(327, '00007', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/441833-405-336-tyahan_s_kuriczej.png', 0, 1, '100.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:15:00', '2020-03-30 15:15:00'),
(353, '00006', '', '', '', '', '', '', '', 1, 7, 'catalog/Categori/200596-405-336-shish_kebab_of_pork_228x228.jpg', 0, 1, '79.0000', 0, 0, '2020-03-30', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 0, 1, 1, 1, 0, '2020-03-30 15:15:17', '2020-03-30 15:15:17'),
(363, '00005', '', '', '', '', '', '', '', 1, 7, '', 0, 1, '0.0000', 0, 0, '2020-03-31', '0.00000000', 1, '0.00000000', '0.00000000', '0.00000000', 1, 1, 1, 1, 1, 0, '2020-03-31 22:58:44', '2020-03-31 22:58:44');

-- --------------------------------------------------------

--
-- Структура таблицы `oc_product_attribute`
--

CREATE TABLE `oc_product_attribute` (
  `product_id` int(11) NOT NULL,
  `attribute_id` int(11) NOT NULL,
  `language_id` int(11) NOT NULL,
  `text` text NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `oc_product_description`
--

CREATE TABLE `oc_product_description` (
  `product_id` int(11) NOT NULL,
  `language_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `description_excerpt` text DEFAULT NULL,
  `description_add` varchar(128) NOT NULL,
  `tag` text NOT NULL,
  `meta_title` varchar(255) NOT NULL,
  `meta_description` varchar(255) NOT NULL,
  `meta_keyword` varchar(255) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_product_description`
--

INSERT INTO `oc_product_description` (`product_id`, `language_id`, `name`, `description`, `description_excerpt`, `description_add`, `tag`, `meta_title`, `meta_description`, `meta_keyword`) VALUES
(325, 2, 'Рис «Тяхан с курицей»', '&lt;p&gt;Лапша и рис давно уже стали простыми и в то же время экзотическими блюдами далеко за пределами Китая. Они имеют необычный потрясающий вкус и обладают высокой энергетической ценностью.&lt;/p&gt;&lt;p&gt;Хотите утолить зверский голод? Один из изысканных вариантов называется Рис «Тяхан с курицей».&lt;/p&gt;&lt;p&gt;Это блюдо с отменным набором ингредиентов| Это блюдо с ингредиентами:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;морковь;&lt;/li&gt;&lt;li&gt;зеленый лук;&lt;/li&gt;&lt;li&gt;болгарский перец;&lt;/li&gt;&lt;li&gt;репчатый лук;&lt;/li&gt;&lt;li&gt;рис;&lt;/li&gt;&lt;li&gt;кунжут;&lt;/li&gt;&lt;li&gt;соус соевый;&lt;/li&gt;&lt;li&gt;чеснок;&lt;/li&gt;&lt;li&gt;шампиньоны;&lt;/li&gt;&lt;li&gt;курица.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Такой аромат не передать словами!&lt;/p&gt;&lt;p&gt;Пригласите своих друзей посмотреть интересный фильм, сделайте заказ паназиатской еды из кафе «966» и поверьте, ваши гости будут в восторге от такого экзотического меню!&lt;/p&gt;&lt;p&gt;Вес порции — 350 г. Своевременная доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '200г/350г', '', 'Рис «Тяхан с курицей»', '', ''),
(298, 2, 'Рис «Тяхан с курицей»', '&lt;p&gt;Лапша и рис давно уже стали простыми и в то же время экзотическими блюдами далеко за пределами Китая. Они имеют необычный потрясающий вкус и обладают высокой энергетической ценностью.&lt;/p&gt;&lt;p&gt;Хотите утолить зверский голод? Один из изысканных вариантов называется Рис «Тяхан с курицей».&lt;/p&gt;&lt;p&gt;Это блюдо с отменным набором ингредиентов| Это блюдо с ингредиентами:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;морковь;&lt;/li&gt;&lt;li&gt;зеленый лук;&lt;/li&gt;&lt;li&gt;болгарский перец;&lt;/li&gt;&lt;li&gt;репчатый лук;&lt;/li&gt;&lt;li&gt;рис;&lt;/li&gt;&lt;li&gt;кунжут;&lt;/li&gt;&lt;li&gt;соус соевый;&lt;/li&gt;&lt;li&gt;чеснок;&lt;/li&gt;&lt;li&gt;шампиньоны;&lt;/li&gt;&lt;li&gt;курица.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Такой аромат не передать словами!&lt;/p&gt;&lt;p&gt;Пригласите своих друзей посмотреть интересный фильм, сделайте заказ паназиатской еды из кафе «966» и поверьте, ваши гости будут в восторге от такого экзотического меню!&lt;/p&gt;&lt;p&gt;Вес порции — 350 г. Своевременная доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '200г/350г', '', 'Рис «Тяхан с курицей»', '', ''),
(299, 2, 'Рис «Тяхан с курицей»', '&lt;p&gt;Лапша и рис давно уже стали простыми и в то же время экзотическими блюдами далеко за пределами Китая. Они имеют необычный потрясающий вкус и обладают высокой энергетической ценностью.&lt;/p&gt;&lt;p&gt;Хотите утолить зверский голод? Один из изысканных вариантов называется Рис «Тяхан с курицей».&lt;/p&gt;&lt;p&gt;Это блюдо с отменным набором ингредиентов| Это блюдо с ингредиентами:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;морковь;&lt;/li&gt;&lt;li&gt;зеленый лук;&lt;/li&gt;&lt;li&gt;болгарский перец;&lt;/li&gt;&lt;li&gt;репчатый лук;&lt;/li&gt;&lt;li&gt;рис;&lt;/li&gt;&lt;li&gt;кунжут;&lt;/li&gt;&lt;li&gt;соус соевый;&lt;/li&gt;&lt;li&gt;чеснок;&lt;/li&gt;&lt;li&gt;шампиньоны;&lt;/li&gt;&lt;li&gt;курица.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Такой аромат не передать словами!&lt;/p&gt;&lt;p&gt;Пригласите своих друзей посмотреть интересный фильм, сделайте заказ паназиатской еды из кафе «966» и поверьте, ваши гости будут в восторге от такого экзотического меню!&lt;/p&gt;&lt;p&gt;Вес порции — 350 г. Своевременная доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '200г/350г', '', 'Рис «Тяхан с курицей»', '', ''),
(300, 2, 'Рис «Тяхан с курицей»', '&lt;p&gt;Лапша и рис давно уже стали простыми и в то же время экзотическими блюдами далеко за пределами Китая. Они имеют необычный потрясающий вкус и обладают высокой энергетической ценностью.&lt;/p&gt;&lt;p&gt;Хотите утолить зверский голод? Один из изысканных вариантов называется Рис «Тяхан с курицей».&lt;/p&gt;&lt;p&gt;Это блюдо с отменным набором ингредиентов| Это блюдо с ингредиентами:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;морковь;&lt;/li&gt;&lt;li&gt;зеленый лук;&lt;/li&gt;&lt;li&gt;болгарский перец;&lt;/li&gt;&lt;li&gt;репчатый лук;&lt;/li&gt;&lt;li&gt;рис;&lt;/li&gt;&lt;li&gt;кунжут;&lt;/li&gt;&lt;li&gt;соус соевый;&lt;/li&gt;&lt;li&gt;чеснок;&lt;/li&gt;&lt;li&gt;шампиньоны;&lt;/li&gt;&lt;li&gt;курица.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Такой аромат не передать словами!&lt;/p&gt;&lt;p&gt;Пригласите своих друзей посмотреть интересный фильм, сделайте заказ паназиатской еды из кафе «966» и поверьте, ваши гости будут в восторге от такого экзотического меню!&lt;/p&gt;&lt;p&gt;Вес порции — 350 г. Своевременная доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '200г/350г', '', 'Рис «Тяхан с курицей»', '', ''),
(245, 2, 'Бургер «Шакил О\'Нил»', '&lt;p&gt;Нет возможности выйти из квартиры, чтобы поесть?&lt;/p&gt;&lt;p&gt;Покупайте Бургер «Шакил О\'Нил» из ресторана &quot;Вилки-Палки&quot;. Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;медово-горчичный соус;&lt;/li&gt;&lt;li&gt;маринованный огурец;&lt;/li&gt;&lt;li&gt;сыр чеддер;&lt;/li&gt;&lt;li&gt;булочка для бургера;&lt;/li&gt;&lt;li&gt;куриная котлета;&lt;/li&gt;&lt;li&gt;котлета из говядины;&lt;/li&gt;&lt;li&gt;свежие томаты;&lt;/li&gt;&lt;li&gt;синий лук;&lt;/li&gt;&lt;li&gt;соус BBQ.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Вес блюда — 400 г. Быстрая доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '380 г', '', 'Бургер «Шакил О\'Нил»', '', ''),
(248, 2, 'Бургер «Шакил О\'Нил»', '&lt;p&gt;Нет возможности выйти из квартиры, чтобы поесть?&lt;/p&gt;&lt;p&gt;Покупайте Бургер «Шакил О\'Нил» из ресторана &quot;Вилки-Палки&quot;. Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;медово-горчичный соус;&lt;/li&gt;&lt;li&gt;маринованный огурец;&lt;/li&gt;&lt;li&gt;сыр чеддер;&lt;/li&gt;&lt;li&gt;булочка для бургера;&lt;/li&gt;&lt;li&gt;куриная котлета;&lt;/li&gt;&lt;li&gt;котлета из говядины;&lt;/li&gt;&lt;li&gt;свежие томаты;&lt;/li&gt;&lt;li&gt;синий лук;&lt;/li&gt;&lt;li&gt;соус BBQ.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Вес блюда — 400 г. Быстрая доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '380 г', '', 'Бургер «Шакил О\'Нил»', '', ''),
(249, 2, 'Бургер «Шакил О\'Нил»', '&lt;p&gt;Нет возможности выйти из квартиры, чтобы поесть?&lt;/p&gt;&lt;p&gt;Покупайте Бургер «Шакил О\'Нил» из ресторана &quot;Вилки-Палки&quot;. Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;медово-горчичный соус;&lt;/li&gt;&lt;li&gt;маринованный огурец;&lt;/li&gt;&lt;li&gt;сыр чеддер;&lt;/li&gt;&lt;li&gt;булочка для бургера;&lt;/li&gt;&lt;li&gt;куриная котлета;&lt;/li&gt;&lt;li&gt;котлета из говядины;&lt;/li&gt;&lt;li&gt;свежие томаты;&lt;/li&gt;&lt;li&gt;синий лук;&lt;/li&gt;&lt;li&gt;соус BBQ.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Вес блюда — 400 г. Быстрая доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '380 г', '', 'Бургер «Шакил О\'Нил»', '', ''),
(250, 2, 'Бургер «Шакил О\'Нил»', '&lt;p&gt;Нет возможности выйти из квартиры, чтобы поесть?&lt;/p&gt;&lt;p&gt;Покупайте Бургер «Шакил О\'Нил» из ресторана &quot;Вилки-Палки&quot;. Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;медово-горчичный соус;&lt;/li&gt;&lt;li&gt;маринованный огурец;&lt;/li&gt;&lt;li&gt;сыр чеддер;&lt;/li&gt;&lt;li&gt;булочка для бургера;&lt;/li&gt;&lt;li&gt;куриная котлета;&lt;/li&gt;&lt;li&gt;котлета из говядины;&lt;/li&gt;&lt;li&gt;свежие томаты;&lt;/li&gt;&lt;li&gt;синий лук;&lt;/li&gt;&lt;li&gt;соус BBQ.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Вес блюда — 400 г. Быстрая доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '380 г', '', 'Бургер «Шакил О\'Нил»', '', ''),
(251, 2, 'Бургер «Шакил О\'Нил»', '&lt;p&gt;Нет возможности выйти из квартиры, чтобы поесть?&lt;/p&gt;&lt;p&gt;Покупайте Бургер «Шакил О\'Нил» из ресторана &quot;Вилки-Палки&quot;. Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;медово-горчичный соус;&lt;/li&gt;&lt;li&gt;маринованный огурец;&lt;/li&gt;&lt;li&gt;сыр чеддер;&lt;/li&gt;&lt;li&gt;булочка для бургера;&lt;/li&gt;&lt;li&gt;куриная котлета;&lt;/li&gt;&lt;li&gt;котлета из говядины;&lt;/li&gt;&lt;li&gt;свежие томаты;&lt;/li&gt;&lt;li&gt;синий лук;&lt;/li&gt;&lt;li&gt;соус BBQ.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Вес блюда — 400 г. Быстрая доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '380 г', '', 'Бургер «Шакил О\'Нил»', '', ''),
(252, 2, 'Бургер «Шакил О\'Нил»', '&lt;p&gt;Нет возможности выйти из квартиры, чтобы поесть?&lt;/p&gt;&lt;p&gt;Покупайте Бургер «Шакил О\'Нил» из ресторана &quot;Вилки-Палки&quot;. Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;медово-горчичный соус;&lt;/li&gt;&lt;li&gt;маринованный огурец;&lt;/li&gt;&lt;li&gt;сыр чеддер;&lt;/li&gt;&lt;li&gt;булочка для бургера;&lt;/li&gt;&lt;li&gt;куриная котлета;&lt;/li&gt;&lt;li&gt;котлета из говядины;&lt;/li&gt;&lt;li&gt;свежие томаты;&lt;/li&gt;&lt;li&gt;синий лук;&lt;/li&gt;&lt;li&gt;соус BBQ.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Вес блюда — 400 г. Быстрая доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '380 г', '', 'Бургер «Шакил О\'Нил»', '', ''),
(253, 2, 'Бургер «Шакил О\'Нил»', '&lt;p&gt;Нет возможности выйти из квартиры, чтобы поесть?&lt;/p&gt;&lt;p&gt;Покупайте Бургер «Шакил О\'Нил» из ресторана &quot;Вилки-Палки&quot;. Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;медово-горчичный соус;&lt;/li&gt;&lt;li&gt;маринованный огурец;&lt;/li&gt;&lt;li&gt;сыр чеддер;&lt;/li&gt;&lt;li&gt;булочка для бургера;&lt;/li&gt;&lt;li&gt;куриная котлета;&lt;/li&gt;&lt;li&gt;котлета из говядины;&lt;/li&gt;&lt;li&gt;свежие томаты;&lt;/li&gt;&lt;li&gt;синий лук;&lt;/li&gt;&lt;li&gt;соус BBQ.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Вес блюда — 400 г. Быстрая доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '380 г', '', 'Бургер «Шакил О\'Нил»', '', ''),
(254, 2, 'Бургер «Шакил О\'Нил»', '&lt;p&gt;Нет возможности выйти из квартиры, чтобы поесть?&lt;/p&gt;&lt;p&gt;Покупайте Бургер «Шакил О\'Нил» из ресторана &quot;Вилки-Палки&quot;. Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;медово-горчичный соус;&lt;/li&gt;&lt;li&gt;маринованный огурец;&lt;/li&gt;&lt;li&gt;сыр чеддер;&lt;/li&gt;&lt;li&gt;булочка для бургера;&lt;/li&gt;&lt;li&gt;куриная котлета;&lt;/li&gt;&lt;li&gt;котлета из говядины;&lt;/li&gt;&lt;li&gt;свежие томаты;&lt;/li&gt;&lt;li&gt;синий лук;&lt;/li&gt;&lt;li&gt;соус BBQ.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Вес блюда — 400 г. Быстрая доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '380 г', '', 'Бургер «Шакил О\'Нил»', '', ''),
(146, 2, 'Шашлык из свинины от Marinara', '&lt;p&gt;Весовая позиция. Цена указана за 100 г.&lt;br&gt;&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '580 г', '', 'Шашлык из свинины от Marinara', '', ''),
(276, 2, 'Пицца «Фирменная»', '&lt;p&gt;Пицца по праву считается одним из самых знаменитых блюд на всей планете, ибо ее изумительный вкус оставляет только положительные ощущения. Один из изысканных вариантов называется Пицца «Фирменная».&lt;/p&gt;&lt;p&gt;Пицца собрала в своем рецепте:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;сыр моцарелла;&lt;/li&gt;&lt;li&gt;болгарский перец;&lt;/li&gt;&lt;li&gt;бекон;&lt;/li&gt;&lt;li&gt;томатный соус;&lt;/li&gt;&lt;li&gt;ветчина;&lt;/li&gt;&lt;li&gt;курица гриль;&lt;/li&gt;&lt;li&gt;салями пепперони.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;От такого вы будете просто в восторге!&lt;/p&gt;&lt;p&gt;Необыкновенно вкусная и очень аппетитная Пицца «Фирменная» получит только положительные отзывы от тех, кто ее попробует. Сделав заказ пиццы на дом для себя или компании из кафе «Pizza.od.ua», вы никого не оставите голодным, ведь это блюдо очень сытное. Пицца «Фирменная» отлично справится со своей основной целью – накормить каждого.&lt;/p&gt;&lt;p&gt;Вес пиццы составляет 400 г. Оперативная доставка еды на дом от 60 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '950г', '', 'Пицца «Фирменная»', '', ''),
(277, 2, 'Рис «Тяхан с курицей»', '&lt;p&gt;Лапша и рис давно уже стали простыми и в то же время экзотическими блюдами далеко за пределами Китая. Они имеют необычный потрясающий вкус и обладают высокой энергетической ценностью.&lt;/p&gt;&lt;p&gt;Хотите утолить зверский голод? Один из изысканных вариантов называется Рис «Тяхан с курицей».&lt;/p&gt;&lt;p&gt;Это блюдо с отменным набором ингредиентов| Это блюдо с ингредиентами:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;морковь;&lt;/li&gt;&lt;li&gt;зеленый лук;&lt;/li&gt;&lt;li&gt;болгарский перец;&lt;/li&gt;&lt;li&gt;репчатый лук;&lt;/li&gt;&lt;li&gt;рис;&lt;/li&gt;&lt;li&gt;кунжут;&lt;/li&gt;&lt;li&gt;соус соевый;&lt;/li&gt;&lt;li&gt;чеснок;&lt;/li&gt;&lt;li&gt;шампиньоны;&lt;/li&gt;&lt;li&gt;курица.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Такой аромат не передать словами!&lt;/p&gt;&lt;p&gt;Пригласите своих друзей посмотреть интересный фильм, сделайте заказ паназиатской еды из кафе «966» и поверьте, ваши гости будут в восторге от такого экзотического меню!&lt;/p&gt;&lt;p&gt;Вес порции — 350 г. Своевременная доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '200г/350г', '', 'Рис «Тяхан с курицей»', '', ''),
(335, 2, 'Сашимі «Угорь»', '&lt;p&gt;Нет желания выйти из квартиры, чтобы подкрепиться?&lt;/p&gt;&lt;p&gt;Заказывайте Сашими «Угорь» из ресторана &quot;966&quot;. Это вкусное, сытное, а также полезное блюдо, приготовленное из свежайших ингредиентов, в состав которого входит:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;угорь;&lt;/li&gt;&lt;li&gt;огурец;&lt;/li&gt;&lt;li&gt;дайкон.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Вес блюда — 45 г. Быстрая доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '38 г', '', 'Сашимі «Угорь»', '', ''),
(324, 2, 'Рис «Тяхан с курицей»', '&lt;p&gt;Лапша и рис давно уже стали простыми и в то же время экзотическими блюдами далеко за пределами Китая. Они имеют необычный потрясающий вкус и обладают высокой энергетической ценностью.&lt;/p&gt;&lt;p&gt;Хотите утолить зверский голод? Один из изысканных вариантов называется Рис «Тяхан с курицей».&lt;/p&gt;&lt;p&gt;Это блюдо с отменным набором ингредиентов| Это блюдо с ингредиентами:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;морковь;&lt;/li&gt;&lt;li&gt;зеленый лук;&lt;/li&gt;&lt;li&gt;болгарский перец;&lt;/li&gt;&lt;li&gt;репчатый лук;&lt;/li&gt;&lt;li&gt;рис;&lt;/li&gt;&lt;li&gt;кунжут;&lt;/li&gt;&lt;li&gt;соус соевый;&lt;/li&gt;&lt;li&gt;чеснок;&lt;/li&gt;&lt;li&gt;шампиньоны;&lt;/li&gt;&lt;li&gt;курица.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Такой аромат не передать словами!&lt;/p&gt;&lt;p&gt;Пригласите своих друзей посмотреть интересный фильм, сделайте заказ паназиатской еды из кафе «966» и поверьте, ваши гости будут в восторге от такого экзотического меню!&lt;/p&gt;&lt;p&gt;Вес порции — 350 г. Своевременная доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '200г/350г', '', 'Рис «Тяхан с курицей»', '', ''),
(323, 2, 'Рис «Тяхан с курицей»', '&lt;p&gt;Лапша и рис давно уже стали простыми и в то же время экзотическими блюдами далеко за пределами Китая. Они имеют необычный потрясающий вкус и обладают высокой энергетической ценностью.&lt;/p&gt;&lt;p&gt;Хотите утолить зверский голод? Один из изысканных вариантов называется Рис «Тяхан с курицей».&lt;/p&gt;&lt;p&gt;Это блюдо с отменным набором ингредиентов| Это блюдо с ингредиентами:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;морковь;&lt;/li&gt;&lt;li&gt;зеленый лук;&lt;/li&gt;&lt;li&gt;болгарский перец;&lt;/li&gt;&lt;li&gt;репчатый лук;&lt;/li&gt;&lt;li&gt;рис;&lt;/li&gt;&lt;li&gt;кунжут;&lt;/li&gt;&lt;li&gt;соус соевый;&lt;/li&gt;&lt;li&gt;чеснок;&lt;/li&gt;&lt;li&gt;шампиньоны;&lt;/li&gt;&lt;li&gt;курица.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Такой аромат не передать словами!&lt;/p&gt;&lt;p&gt;Пригласите своих друзей посмотреть интересный фильм, сделайте заказ паназиатской еды из кафе «966» и поверьте, ваши гости будут в восторге от такого экзотического меню!&lt;/p&gt;&lt;p&gt;Вес порции — 350 г. Своевременная доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '200г/350г', '', 'Рис «Тяхан с курицей»', '', ''),
(322, 2, 'Рис «Тяхан с курицей»', '&lt;p&gt;Лапша и рис давно уже стали простыми и в то же время экзотическими блюдами далеко за пределами Китая. Они имеют необычный потрясающий вкус и обладают высокой энергетической ценностью.&lt;/p&gt;&lt;p&gt;Хотите утолить зверский голод? Один из изысканных вариантов называется Рис «Тяхан с курицей».&lt;/p&gt;&lt;p&gt;Это блюдо с отменным набором ингредиентов| Это блюдо с ингредиентами:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;морковь;&lt;/li&gt;&lt;li&gt;зеленый лук;&lt;/li&gt;&lt;li&gt;болгарский перец;&lt;/li&gt;&lt;li&gt;репчатый лук;&lt;/li&gt;&lt;li&gt;рис;&lt;/li&gt;&lt;li&gt;кунжут;&lt;/li&gt;&lt;li&gt;соус соевый;&lt;/li&gt;&lt;li&gt;чеснок;&lt;/li&gt;&lt;li&gt;шампиньоны;&lt;/li&gt;&lt;li&gt;курица.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Такой аромат не передать словами!&lt;/p&gt;&lt;p&gt;Пригласите своих друзей посмотреть интересный фильм, сделайте заказ паназиатской еды из кафе «966» и поверьте, ваши гости будут в восторге от такого экзотического меню!&lt;/p&gt;&lt;p&gt;Вес порции — 350 г. Своевременная доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '200г/350г', '', 'Рис «Тяхан с курицей»', '', ''),
(321, 2, 'Рис «Тяхан с курицей»', '&lt;p&gt;Лапша и рис давно уже стали простыми и в то же время экзотическими блюдами далеко за пределами Китая. Они имеют необычный потрясающий вкус и обладают высокой энергетической ценностью.&lt;/p&gt;&lt;p&gt;Хотите утолить зверский голод? Один из изысканных вариантов называется Рис «Тяхан с курицей».&lt;/p&gt;&lt;p&gt;Это блюдо с отменным набором ингредиентов| Это блюдо с ингредиентами:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;морковь;&lt;/li&gt;&lt;li&gt;зеленый лук;&lt;/li&gt;&lt;li&gt;болгарский перец;&lt;/li&gt;&lt;li&gt;репчатый лук;&lt;/li&gt;&lt;li&gt;рис;&lt;/li&gt;&lt;li&gt;кунжут;&lt;/li&gt;&lt;li&gt;соус соевый;&lt;/li&gt;&lt;li&gt;чеснок;&lt;/li&gt;&lt;li&gt;шампиньоны;&lt;/li&gt;&lt;li&gt;курица.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Такой аромат не передать словами!&lt;/p&gt;&lt;p&gt;Пригласите своих друзей посмотреть интересный фильм, сделайте заказ паназиатской еды из кафе «966» и поверьте, ваши гости будут в восторге от такого экзотического меню!&lt;/p&gt;&lt;p&gt;Вес порции — 350 г. Своевременная доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '200г/350г', '', 'Рис «Тяхан с курицей»', '', ''),
(313, 2, 'Пицца «Фирменная»', '&lt;p&gt;Пицца по праву считается одним из самых знаменитых блюд на всей планете, ибо ее изумительный вкус оставляет только положительные ощущения. Один из изысканных вариантов называется Пицца «Фирменная».&lt;/p&gt;&lt;p&gt;Пицца собрала в своем рецепте:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;сыр моцарелла;&lt;/li&gt;&lt;li&gt;болгарский перец;&lt;/li&gt;&lt;li&gt;бекон;&lt;/li&gt;&lt;li&gt;томатный соус;&lt;/li&gt;&lt;li&gt;ветчина;&lt;/li&gt;&lt;li&gt;курица гриль;&lt;/li&gt;&lt;li&gt;салями пепперони.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;От такого вы будете просто в восторге!&lt;/p&gt;&lt;p&gt;Необыкновенно вкусная и очень аппетитная Пицца «Фирменная» получит только положительные отзывы от тех, кто ее попробует. Сделав заказ пиццы на дом для себя или компании из кафе «Pizza.od.ua», вы никого не оставите голодным, ведь это блюдо очень сытное. Пицца «Фирменная» отлично справится со своей основной целью – накормить каждого.&lt;/p&gt;&lt;p&gt;Вес пиццы составляет 400 г. Оперативная доставка еды на дом от 60 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '950г', '', 'Пицца «Фирменная»', '', ''),
(314, 2, 'Рис «Тяхан с курицей»', '&lt;p&gt;Лапша и рис давно уже стали простыми и в то же время экзотическими блюдами далеко за пределами Китая. Они имеют необычный потрясающий вкус и обладают высокой энергетической ценностью.&lt;/p&gt;&lt;p&gt;Хотите утолить зверский голод? Один из изысканных вариантов называется Рис «Тяхан с курицей».&lt;/p&gt;&lt;p&gt;Это блюдо с отменным набором ингредиентов| Это блюдо с ингредиентами:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;морковь;&lt;/li&gt;&lt;li&gt;зеленый лук;&lt;/li&gt;&lt;li&gt;болгарский перец;&lt;/li&gt;&lt;li&gt;репчатый лук;&lt;/li&gt;&lt;li&gt;рис;&lt;/li&gt;&lt;li&gt;кунжут;&lt;/li&gt;&lt;li&gt;соус соевый;&lt;/li&gt;&lt;li&gt;чеснок;&lt;/li&gt;&lt;li&gt;шампиньоны;&lt;/li&gt;&lt;li&gt;курица.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Такой аромат не передать словами!&lt;/p&gt;&lt;p&gt;Пригласите своих друзей посмотреть интересный фильм, сделайте заказ паназиатской еды из кафе «966» и поверьте, ваши гости будут в восторге от такого экзотического меню!&lt;/p&gt;&lt;p&gt;Вес порции — 350 г. Своевременная доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '200г/350г', '', 'Рис «Тяхан с курицей»', '', ''),
(315, 2, 'Рис «Тяхан с курицей»', '&lt;p&gt;Лапша и рис давно уже стали простыми и в то же время экзотическими блюдами далеко за пределами Китая. Они имеют необычный потрясающий вкус и обладают высокой энергетической ценностью.&lt;/p&gt;&lt;p&gt;Хотите утолить зверский голод? Один из изысканных вариантов называется Рис «Тяхан с курицей».&lt;/p&gt;&lt;p&gt;Это блюдо с отменным набором ингредиентов| Это блюдо с ингредиентами:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;морковь;&lt;/li&gt;&lt;li&gt;зеленый лук;&lt;/li&gt;&lt;li&gt;болгарский перец;&lt;/li&gt;&lt;li&gt;репчатый лук;&lt;/li&gt;&lt;li&gt;рис;&lt;/li&gt;&lt;li&gt;кунжут;&lt;/li&gt;&lt;li&gt;соус соевый;&lt;/li&gt;&lt;li&gt;чеснок;&lt;/li&gt;&lt;li&gt;шампиньоны;&lt;/li&gt;&lt;li&gt;курица.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Такой аромат не передать словами!&lt;/p&gt;&lt;p&gt;Пригласите своих друзей посмотреть интересный фильм, сделайте заказ паназиатской еды из кафе «966» и поверьте, ваши гости будут в восторге от такого экзотического меню!&lt;/p&gt;&lt;p&gt;Вес порции — 350 г. Своевременная доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '200г/350г', '', 'Рис «Тяхан с курицей»', '', ''),
(316, 2, 'Рис «Тяхан с курицей»', '&lt;p&gt;Лапша и рис давно уже стали простыми и в то же время экзотическими блюдами далеко за пределами Китая. Они имеют необычный потрясающий вкус и обладают высокой энергетической ценностью.&lt;/p&gt;&lt;p&gt;Хотите утолить зверский голод? Один из изысканных вариантов называется Рис «Тяхан с курицей».&lt;/p&gt;&lt;p&gt;Это блюдо с отменным набором ингредиентов| Это блюдо с ингредиентами:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;морковь;&lt;/li&gt;&lt;li&gt;зеленый лук;&lt;/li&gt;&lt;li&gt;болгарский перец;&lt;/li&gt;&lt;li&gt;репчатый лук;&lt;/li&gt;&lt;li&gt;рис;&lt;/li&gt;&lt;li&gt;кунжут;&lt;/li&gt;&lt;li&gt;соус соевый;&lt;/li&gt;&lt;li&gt;чеснок;&lt;/li&gt;&lt;li&gt;шампиньоны;&lt;/li&gt;&lt;li&gt;курица.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Такой аромат не передать словами!&lt;/p&gt;&lt;p&gt;Пригласите своих друзей посмотреть интересный фильм, сделайте заказ паназиатской еды из кафе «966» и поверьте, ваши гости будут в восторге от такого экзотического меню!&lt;/p&gt;&lt;p&gt;Вес порции — 350 г. Своевременная доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '200г/350г', '', 'Рис «Тяхан с курицей»', '', ''),
(311, 2, 'Шашлык из свинины от Marinara', '&lt;p&gt;Весовая позиция. Цена указана за 100 г.&lt;br&gt;&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '580 г', '', 'Шашлык из свинины от Marinara', '', ''),
(312, 2, 'Пицца «Фирменная»', '&lt;p&gt;Пицца по праву считается одним из самых знаменитых блюд на всей планете, ибо ее изумительный вкус оставляет только положительные ощущения. Один из изысканных вариантов называется Пицца «Фирменная».&lt;/p&gt;&lt;p&gt;Пицца собрала в своем рецепте:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;сыр моцарелла;&lt;/li&gt;&lt;li&gt;болгарский перец;&lt;/li&gt;&lt;li&gt;бекон;&lt;/li&gt;&lt;li&gt;томатный соус;&lt;/li&gt;&lt;li&gt;ветчина;&lt;/li&gt;&lt;li&gt;курица гриль;&lt;/li&gt;&lt;li&gt;салями пепперони.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;От такого вы будете просто в восторге!&lt;/p&gt;&lt;p&gt;Необыкновенно вкусная и очень аппетитная Пицца «Фирменная» получит только положительные отзывы от тех, кто ее попробует. Сделав заказ пиццы на дом для себя или компании из кафе «Pizza.od.ua», вы никого не оставите голодным, ведь это блюдо очень сытное. Пицца «Фирменная» отлично справится со своей основной целью – накормить каждого.&lt;/p&gt;&lt;p&gt;Вес пиццы составляет 400 г. Оперативная доставка еды на дом от 60 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '950г', '', 'Пицца «Фирменная»', '', ''),
(50, 2, 'Сет «Мітчел»', '&lt;p&gt;В составе сета роллы: «Филадельфия в кунжуте», «Овощной», с водорослями чука, с огурцом; суши «Гункан с водорослями чука» (3 шт.). Всего — 33 кусочка.&lt;br&gt;&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '52 шт., 1380 г', '', 'Сет «Мітчел»', '', ''),
(278, 2, 'Сашимі «Угорь»', '&lt;p&gt;Нет желания выйти из квартиры, чтобы подкрепиться?&lt;/p&gt;&lt;p&gt;Заказывайте Сашими «Угорь» из ресторана &quot;966&quot;. Это вкусное, сытное, а также полезное блюдо, приготовленное из свежайших ингредиентов, в состав которого входит:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;угорь;&lt;/li&gt;&lt;li&gt;огурец;&lt;/li&gt;&lt;li&gt;дайкон.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Вес блюда — 45 г. Быстрая доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '38 г', '', 'Сашимі «Угорь»', '', ''),
(279, 2, 'Сет «Мітчел»', '&lt;p&gt;В составе сета роллы: «Филадельфия в кунжуте», «Овощной», с водорослями чука, с огурцом; суши «Гункан с водорослями чука» (3 шт.). Всего — 33 кусочка.&lt;br&gt;&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '52 шт., 1380 г', '', 'Сет «Мітчел»', '', ''),
(280, 2, 'Шашлык из свинины от Marinara', '&lt;p&gt;Весовая позиция. Цена указана за 100 г.&lt;br&gt;&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '580 г', '', 'Шашлык из свинины от Marinara', '', ''),
(281, 2, 'Пицца «Фирменная»', '&lt;p&gt;Пицца по праву считается одним из самых знаменитых блюд на всей планете, ибо ее изумительный вкус оставляет только положительные ощущения. Один из изысканных вариантов называется Пицца «Фирменная».&lt;/p&gt;&lt;p&gt;Пицца собрала в своем рецепте:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;сыр моцарелла;&lt;/li&gt;&lt;li&gt;болгарский перец;&lt;/li&gt;&lt;li&gt;бекон;&lt;/li&gt;&lt;li&gt;томатный соус;&lt;/li&gt;&lt;li&gt;ветчина;&lt;/li&gt;&lt;li&gt;курица гриль;&lt;/li&gt;&lt;li&gt;салями пепперони.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;От такого вы будете просто в восторге!&lt;/p&gt;&lt;p&gt;Необыкновенно вкусная и очень аппетитная Пицца «Фирменная» получит только положительные отзывы от тех, кто ее попробует. Сделав заказ пиццы на дом для себя или компании из кафе «Pizza.od.ua», вы никого не оставите голодным, ведь это блюдо очень сытное. Пицца «Фирменная» отлично справится со своей основной целью – накормить каждого.&lt;/p&gt;&lt;p&gt;Вес пиццы составляет 400 г. Оперативная доставка еды на дом от 60 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '950г', '', 'Пицца «Фирменная»', '', ''),
(282, 2, 'Пицца «Фирменная»', '&lt;p&gt;Пицца по праву считается одним из самых знаменитых блюд на всей планете, ибо ее изумительный вкус оставляет только положительные ощущения. Один из изысканных вариантов называется Пицца «Фирменная».&lt;/p&gt;&lt;p&gt;Пицца собрала в своем рецепте:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;сыр моцарелла;&lt;/li&gt;&lt;li&gt;болгарский перец;&lt;/li&gt;&lt;li&gt;бекон;&lt;/li&gt;&lt;li&gt;томатный соус;&lt;/li&gt;&lt;li&gt;ветчина;&lt;/li&gt;&lt;li&gt;курица гриль;&lt;/li&gt;&lt;li&gt;салями пепперони.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;От такого вы будете просто в восторге!&lt;/p&gt;&lt;p&gt;Необыкновенно вкусная и очень аппетитная Пицца «Фирменная» получит только положительные отзывы от тех, кто ее попробует. Сделав заказ пиццы на дом для себя или компании из кафе «Pizza.od.ua», вы никого не оставите голодным, ведь это блюдо очень сытное. Пицца «Фирменная» отлично справится со своей основной целью – накормить каждого.&lt;/p&gt;&lt;p&gt;Вес пиццы составляет 400 г. Оперативная доставка еды на дом от 60 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '950г', '', 'Пицца «Фирменная»', '', ''),
(283, 2, 'Рис «Тяхан с курицей»', '&lt;p&gt;Лапша и рис давно уже стали простыми и в то же время экзотическими блюдами далеко за пределами Китая. Они имеют необычный потрясающий вкус и обладают высокой энергетической ценностью.&lt;/p&gt;&lt;p&gt;Хотите утолить зверский голод? Один из изысканных вариантов называется Рис «Тяхан с курицей».&lt;/p&gt;&lt;p&gt;Это блюдо с отменным набором ингредиентов| Это блюдо с ингредиентами:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;морковь;&lt;/li&gt;&lt;li&gt;зеленый лук;&lt;/li&gt;&lt;li&gt;болгарский перец;&lt;/li&gt;&lt;li&gt;репчатый лук;&lt;/li&gt;&lt;li&gt;рис;&lt;/li&gt;&lt;li&gt;кунжут;&lt;/li&gt;&lt;li&gt;соус соевый;&lt;/li&gt;&lt;li&gt;чеснок;&lt;/li&gt;&lt;li&gt;шампиньоны;&lt;/li&gt;&lt;li&gt;курица.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Такой аромат не передать словами!&lt;/p&gt;&lt;p&gt;Пригласите своих друзей посмотреть интересный фильм, сделайте заказ паназиатской еды из кафе «966» и поверьте, ваши гости будут в восторге от такого экзотического меню!&lt;/p&gt;&lt;p&gt;Вес порции — 350 г. Своевременная доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '200г/350г', '', 'Рис «Тяхан с курицей»', '', ''),
(178, 2, 'Пицца «Фирменная»', '&lt;p&gt;Пицца по праву считается одним из самых знаменитых блюд на всей планете, ибо ее изумительный вкус оставляет только положительные ощущения. Один из изысканных вариантов называется Пицца «Фирменная».&lt;/p&gt;&lt;p&gt;Пицца собрала в своем рецепте:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;сыр моцарелла;&lt;/li&gt;&lt;li&gt;болгарский перец;&lt;/li&gt;&lt;li&gt;бекон;&lt;/li&gt;&lt;li&gt;томатный соус;&lt;/li&gt;&lt;li&gt;ветчина;&lt;/li&gt;&lt;li&gt;курица гриль;&lt;/li&gt;&lt;li&gt;салями пепперони.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;От такого вы будете просто в восторге!&lt;/p&gt;&lt;p&gt;Необыкновенно вкусная и очень аппетитная Пицца «Фирменная» получит только положительные отзывы от тех, кто ее попробует. Сделав заказ пиццы на дом для себя или компании из кафе «Pizza.od.ua», вы никого не оставите голодным, ведь это блюдо очень сытное. Пицца «Фирменная» отлично справится со своей основной целью – накормить каждого.&lt;/p&gt;&lt;p&gt;Вес пиццы составляет 400 г. Оперативная доставка еды на дом от 60 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '950г', '', 'Пицца «Фирменная»', '', ''),
(71, 2, 'Сашимі «Угорь»', '&lt;p&gt;Нет желания выйти из квартиры, чтобы подкрепиться?&lt;/p&gt;&lt;p&gt;Заказывайте Сашими «Угорь» из ресторана &quot;966&quot;. Это вкусное, сытное, а также полезное блюдо, приготовленное из свежайших ингредиентов, в состав которого входит:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;угорь;&lt;/li&gt;&lt;li&gt;огурец;&lt;/li&gt;&lt;li&gt;дайкон.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Вес блюда — 45 г. Быстрая доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '38 г', '', 'Сашимі «Угорь»', '', ''),
(284, 2, 'Рис «Тяхан с курицей»', '&lt;p&gt;Лапша и рис давно уже стали простыми и в то же время экзотическими блюдами далеко за пределами Китая. Они имеют необычный потрясающий вкус и обладают высокой энергетической ценностью.&lt;/p&gt;&lt;p&gt;Хотите утолить зверский голод? Один из изысканных вариантов называется Рис «Тяхан с курицей».&lt;/p&gt;&lt;p&gt;Это блюдо с отменным набором ингредиентов| Это блюдо с ингредиентами:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;морковь;&lt;/li&gt;&lt;li&gt;зеленый лук;&lt;/li&gt;&lt;li&gt;болгарский перец;&lt;/li&gt;&lt;li&gt;репчатый лук;&lt;/li&gt;&lt;li&gt;рис;&lt;/li&gt;&lt;li&gt;кунжут;&lt;/li&gt;&lt;li&gt;соус соевый;&lt;/li&gt;&lt;li&gt;чеснок;&lt;/li&gt;&lt;li&gt;шампиньоны;&lt;/li&gt;&lt;li&gt;курица.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Такой аромат не передать словами!&lt;/p&gt;&lt;p&gt;Пригласите своих друзей посмотреть интересный фильм, сделайте заказ паназиатской еды из кафе «966» и поверьте, ваши гости будут в восторге от такого экзотического меню!&lt;/p&gt;&lt;p&gt;Вес порции — 350 г. Своевременная доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '200г/350г', '', 'Рис «Тяхан с курицей»', '', ''),
(285, 2, 'Сашимі «Угорь»', '&lt;p&gt;Нет желания выйти из квартиры, чтобы подкрепиться?&lt;/p&gt;&lt;p&gt;Заказывайте Сашими «Угорь» из ресторана &quot;966&quot;. Это вкусное, сытное, а также полезное блюдо, приготовленное из свежайших ингредиентов, в состав которого входит:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;угорь;&lt;/li&gt;&lt;li&gt;огурец;&lt;/li&gt;&lt;li&gt;дайкон.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Вес блюда — 45 г. Быстрая доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '38 г', '', 'Сашимі «Угорь»', '', ''),
(286, 2, 'Сашимі «Угорь»', '&lt;p&gt;Нет желания выйти из квартиры, чтобы подкрепиться?&lt;/p&gt;&lt;p&gt;Заказывайте Сашими «Угорь» из ресторана &quot;966&quot;. Это вкусное, сытное, а также полезное блюдо, приготовленное из свежайших ингредиентов, в состав которого входит:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;угорь;&lt;/li&gt;&lt;li&gt;огурец;&lt;/li&gt;&lt;li&gt;дайкон.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Вес блюда — 45 г. Быстрая доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '38 г', '', 'Сашимі «Угорь»', '', ''),
(287, 2, 'Сет «Мітчел»', '&lt;p&gt;В составе сета роллы: «Филадельфия в кунжуте», «Овощной», с водорослями чука, с огурцом; суши «Гункан с водорослями чука» (3 шт.). Всего — 33 кусочка.&lt;br&gt;&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '52 шт., 1380 г', '', 'Сет «Мітчел»', '', ''),
(288, 2, 'Пицца «Фирменная»', '&lt;p&gt;Пицца по праву считается одним из самых знаменитых блюд на всей планете, ибо ее изумительный вкус оставляет только положительные ощущения. Один из изысканных вариантов называется Пицца «Фирменная».&lt;/p&gt;&lt;p&gt;Пицца собрала в своем рецепте:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;сыр моцарелла;&lt;/li&gt;&lt;li&gt;болгарский перец;&lt;/li&gt;&lt;li&gt;бекон;&lt;/li&gt;&lt;li&gt;томатный соус;&lt;/li&gt;&lt;li&gt;ветчина;&lt;/li&gt;&lt;li&gt;курица гриль;&lt;/li&gt;&lt;li&gt;салями пепперони.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;От такого вы будете просто в восторге!&lt;/p&gt;&lt;p&gt;Необыкновенно вкусная и очень аппетитная Пицца «Фирменная» получит только положительные отзывы от тех, кто ее попробует. Сделав заказ пиццы на дом для себя или компании из кафе «Pizza.od.ua», вы никого не оставите голодным, ведь это блюдо очень сытное. Пицца «Фирменная» отлично справится со своей основной целью – накормить каждого.&lt;/p&gt;&lt;p&gt;Вес пиццы составляет 400 г. Оперативная доставка еды на дом от 60 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '950г', '', 'Пицца «Фирменная»', '', ''),
(289, 2, 'Пицца «Фирменная»', '&lt;p&gt;Пицца по праву считается одним из самых знаменитых блюд на всей планете, ибо ее изумительный вкус оставляет только положительные ощущения. Один из изысканных вариантов называется Пицца «Фирменная».&lt;/p&gt;&lt;p&gt;Пицца собрала в своем рецепте:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;сыр моцарелла;&lt;/li&gt;&lt;li&gt;болгарский перец;&lt;/li&gt;&lt;li&gt;бекон;&lt;/li&gt;&lt;li&gt;томатный соус;&lt;/li&gt;&lt;li&gt;ветчина;&lt;/li&gt;&lt;li&gt;курица гриль;&lt;/li&gt;&lt;li&gt;салями пепперони.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;От такого вы будете просто в восторге!&lt;/p&gt;&lt;p&gt;Необыкновенно вкусная и очень аппетитная Пицца «Фирменная» получит только положительные отзывы от тех, кто ее попробует. Сделав заказ пиццы на дом для себя или компании из кафе «Pizza.od.ua», вы никого не оставите голодным, ведь это блюдо очень сытное. Пицца «Фирменная» отлично справится со своей основной целью – накормить каждого.&lt;/p&gt;&lt;p&gt;Вес пиццы составляет 400 г. Оперативная доставка еды на дом от 60 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '950г', '', 'Пицца «Фирменная»', '', ''),
(290, 2, 'Пицца «Фирменная»', '&lt;p&gt;Пицца по праву считается одним из самых знаменитых блюд на всей планете, ибо ее изумительный вкус оставляет только положительные ощущения. Один из изысканных вариантов называется Пицца «Фирменная».&lt;/p&gt;&lt;p&gt;Пицца собрала в своем рецепте:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;сыр моцарелла;&lt;/li&gt;&lt;li&gt;болгарский перец;&lt;/li&gt;&lt;li&gt;бекон;&lt;/li&gt;&lt;li&gt;томатный соус;&lt;/li&gt;&lt;li&gt;ветчина;&lt;/li&gt;&lt;li&gt;курица гриль;&lt;/li&gt;&lt;li&gt;салями пепперони.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;От такого вы будете просто в восторге!&lt;/p&gt;&lt;p&gt;Необыкновенно вкусная и очень аппетитная Пицца «Фирменная» получит только положительные отзывы от тех, кто ее попробует. Сделав заказ пиццы на дом для себя или компании из кафе «Pizza.od.ua», вы никого не оставите голодным, ведь это блюдо очень сытное. Пицца «Фирменная» отлично справится со своей основной целью – накормить каждого.&lt;/p&gt;&lt;p&gt;Вес пиццы составляет 400 г. Оперативная доставка еды на дом от 60 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '950г', '', 'Пицца «Фирменная»', '', ''),
(271, 2, 'Бургер «Шакил О\'Нил»', '&lt;p&gt;Нет возможности выйти из квартиры, чтобы поесть?&lt;/p&gt;&lt;p&gt;Покупайте Бургер «Шакил О\'Нил» из ресторана &quot;Вилки-Палки&quot;. Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;медово-горчичный соус;&lt;/li&gt;&lt;li&gt;маринованный огурец;&lt;/li&gt;&lt;li&gt;сыр чеддер;&lt;/li&gt;&lt;li&gt;булочка для бургера;&lt;/li&gt;&lt;li&gt;куриная котлета;&lt;/li&gt;&lt;li&gt;котлета из говядины;&lt;/li&gt;&lt;li&gt;свежие томаты;&lt;/li&gt;&lt;li&gt;синий лук;&lt;/li&gt;&lt;li&gt;соус BBQ.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Вес блюда — 400 г. Быстрая доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '380 г', '', 'Бургер «Шакил О\'Нил»', '', ''),
(267, 2, 'Бургер «Шакил О\'Нил»', '&lt;p&gt;Нет возможности выйти из квартиры, чтобы поесть?&lt;/p&gt;&lt;p&gt;Покупайте Бургер «Шакил О\'Нил» из ресторана &quot;Вилки-Палки&quot;. Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;медово-горчичный соус;&lt;/li&gt;&lt;li&gt;маринованный огурец;&lt;/li&gt;&lt;li&gt;сыр чеддер;&lt;/li&gt;&lt;li&gt;булочка для бургера;&lt;/li&gt;&lt;li&gt;куриная котлета;&lt;/li&gt;&lt;li&gt;котлета из говядины;&lt;/li&gt;&lt;li&gt;свежие томаты;&lt;/li&gt;&lt;li&gt;синий лук;&lt;/li&gt;&lt;li&gt;соус BBQ.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Вес блюда — 400 г. Быстрая доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '380 г', '', 'Бургер «Шакил О\'Нил»', '', ''),
(268, 2, 'Бургер «Шакил О\'Нил»', '&lt;p&gt;Нет возможности выйти из квартиры, чтобы поесть?&lt;/p&gt;&lt;p&gt;Покупайте Бургер «Шакил О\'Нил» из ресторана &quot;Вилки-Палки&quot;. Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;медово-горчичный соус;&lt;/li&gt;&lt;li&gt;маринованный огурец;&lt;/li&gt;&lt;li&gt;сыр чеддер;&lt;/li&gt;&lt;li&gt;булочка для бургера;&lt;/li&gt;&lt;li&gt;куриная котлета;&lt;/li&gt;&lt;li&gt;котлета из говядины;&lt;/li&gt;&lt;li&gt;свежие томаты;&lt;/li&gt;&lt;li&gt;синий лук;&lt;/li&gt;&lt;li&gt;соус BBQ.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Вес блюда — 400 г. Быстрая доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '380 г', '', 'Бургер «Шакил О\'Нил»', '', ''),
(269, 2, 'Бургер «Шакил О\'Нил»', '&lt;p&gt;Нет возможности выйти из квартиры, чтобы поесть?&lt;/p&gt;&lt;p&gt;Покупайте Бургер «Шакил О\'Нил» из ресторана &quot;Вилки-Палки&quot;. Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;медово-горчичный соус;&lt;/li&gt;&lt;li&gt;маринованный огурец;&lt;/li&gt;&lt;li&gt;сыр чеддер;&lt;/li&gt;&lt;li&gt;булочка для бургера;&lt;/li&gt;&lt;li&gt;куриная котлета;&lt;/li&gt;&lt;li&gt;котлета из говядины;&lt;/li&gt;&lt;li&gt;свежие томаты;&lt;/li&gt;&lt;li&gt;синий лук;&lt;/li&gt;&lt;li&gt;соус BBQ.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Вес блюда — 400 г. Быстрая доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '380 г', '', 'Бургер «Шакил О\'Нил»', '', ''),
(270, 2, 'Бургер «Шакил О\'Нил»', '&lt;p&gt;Нет возможности выйти из квартиры, чтобы поесть?&lt;/p&gt;&lt;p&gt;Покупайте Бургер «Шакил О\'Нил» из ресторана &quot;Вилки-Палки&quot;. Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;медово-горчичный соус;&lt;/li&gt;&lt;li&gt;маринованный огурец;&lt;/li&gt;&lt;li&gt;сыр чеддер;&lt;/li&gt;&lt;li&gt;булочка для бургера;&lt;/li&gt;&lt;li&gt;куриная котлета;&lt;/li&gt;&lt;li&gt;котлета из говядины;&lt;/li&gt;&lt;li&gt;свежие томаты;&lt;/li&gt;&lt;li&gt;синий лук;&lt;/li&gt;&lt;li&gt;соус BBQ.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Вес блюда — 400 г. Быстрая доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '380 г', '', 'Бургер «Шакил О\'Нил»', '', ''),
(258, 2, 'Бургер «Шакил О\'Нил»', '&lt;p&gt;Нет возможности выйти из квартиры, чтобы поесть?&lt;/p&gt;&lt;p&gt;Покупайте Бургер «Шакил О\'Нил» из ресторана &quot;Вилки-Палки&quot;. Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;медово-горчичный соус;&lt;/li&gt;&lt;li&gt;маринованный огурец;&lt;/li&gt;&lt;li&gt;сыр чеддер;&lt;/li&gt;&lt;li&gt;булочка для бургера;&lt;/li&gt;&lt;li&gt;куриная котлета;&lt;/li&gt;&lt;li&gt;котлета из говядины;&lt;/li&gt;&lt;li&gt;свежие томаты;&lt;/li&gt;&lt;li&gt;синий лук;&lt;/li&gt;&lt;li&gt;соус BBQ.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Вес блюда — 400 г. Быстрая доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '380 г', '', 'Бургер «Шакил О\'Нил»', '', ''),
(259, 2, 'Бургер «Шакил О\'Нил»', '&lt;p&gt;Нет возможности выйти из квартиры, чтобы поесть?&lt;/p&gt;&lt;p&gt;Покупайте Бургер «Шакил О\'Нил» из ресторана &quot;Вилки-Палки&quot;. Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;медово-горчичный соус;&lt;/li&gt;&lt;li&gt;маринованный огурец;&lt;/li&gt;&lt;li&gt;сыр чеддер;&lt;/li&gt;&lt;li&gt;булочка для бургера;&lt;/li&gt;&lt;li&gt;куриная котлета;&lt;/li&gt;&lt;li&gt;котлета из говядины;&lt;/li&gt;&lt;li&gt;свежие томаты;&lt;/li&gt;&lt;li&gt;синий лук;&lt;/li&gt;&lt;li&gt;соус BBQ.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Вес блюда — 400 г. Быстрая доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '380 г', '', 'Бургер «Шакил О\'Нил»', '', ''),
(260, 2, 'Бургер «Шакил О\'Нил»', '&lt;p&gt;Нет возможности выйти из квартиры, чтобы поесть?&lt;/p&gt;&lt;p&gt;Покупайте Бургер «Шакил О\'Нил» из ресторана &quot;Вилки-Палки&quot;. Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;медово-горчичный соус;&lt;/li&gt;&lt;li&gt;маринованный огурец;&lt;/li&gt;&lt;li&gt;сыр чеддер;&lt;/li&gt;&lt;li&gt;булочка для бургера;&lt;/li&gt;&lt;li&gt;куриная котлета;&lt;/li&gt;&lt;li&gt;котлета из говядины;&lt;/li&gt;&lt;li&gt;свежие томаты;&lt;/li&gt;&lt;li&gt;синий лук;&lt;/li&gt;&lt;li&gt;соус BBQ.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Вес блюда — 400 г. Быстрая доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '380 г', '', 'Бургер «Шакил О\'Нил»', '', ''),
(261, 2, 'Бургер «Шакил О\'Нил»', '&lt;p&gt;Нет возможности выйти из квартиры, чтобы поесть?&lt;/p&gt;&lt;p&gt;Покупайте Бургер «Шакил О\'Нил» из ресторана &quot;Вилки-Палки&quot;. Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;медово-горчичный соус;&lt;/li&gt;&lt;li&gt;маринованный огурец;&lt;/li&gt;&lt;li&gt;сыр чеддер;&lt;/li&gt;&lt;li&gt;булочка для бургера;&lt;/li&gt;&lt;li&gt;куриная котлета;&lt;/li&gt;&lt;li&gt;котлета из говядины;&lt;/li&gt;&lt;li&gt;свежие томаты;&lt;/li&gt;&lt;li&gt;синий лук;&lt;/li&gt;&lt;li&gt;соус BBQ.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Вес блюда — 400 г. Быстрая доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '380 г', '', 'Бургер «Шакил О\'Нил»', '', ''),
(262, 2, 'Бургер «Шакил О\'Нил»', '&lt;p&gt;Нет возможности выйти из квартиры, чтобы поесть?&lt;/p&gt;&lt;p&gt;Покупайте Бургер «Шакил О\'Нил» из ресторана &quot;Вилки-Палки&quot;. Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;медово-горчичный соус;&lt;/li&gt;&lt;li&gt;маринованный огурец;&lt;/li&gt;&lt;li&gt;сыр чеддер;&lt;/li&gt;&lt;li&gt;булочка для бургера;&lt;/li&gt;&lt;li&gt;куриная котлета;&lt;/li&gt;&lt;li&gt;котлета из говядины;&lt;/li&gt;&lt;li&gt;свежие томаты;&lt;/li&gt;&lt;li&gt;синий лук;&lt;/li&gt;&lt;li&gt;соус BBQ.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Вес блюда — 400 г. Быстрая доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '380 г', '', 'Бургер «Шакил О\'Нил»', '', '');
INSERT INTO `oc_product_description` (`product_id`, `language_id`, `name`, `description`, `description_excerpt`, `description_add`, `tag`, `meta_title`, `meta_description`, `meta_keyword`) VALUES
(263, 2, 'Бургер «Шакил О\'Нил»', '&lt;p&gt;Нет возможности выйти из квартиры, чтобы поесть?&lt;/p&gt;&lt;p&gt;Покупайте Бургер «Шакил О\'Нил» из ресторана &quot;Вилки-Палки&quot;. Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;медово-горчичный соус;&lt;/li&gt;&lt;li&gt;маринованный огурец;&lt;/li&gt;&lt;li&gt;сыр чеддер;&lt;/li&gt;&lt;li&gt;булочка для бургера;&lt;/li&gt;&lt;li&gt;куриная котлета;&lt;/li&gt;&lt;li&gt;котлета из говядины;&lt;/li&gt;&lt;li&gt;свежие томаты;&lt;/li&gt;&lt;li&gt;синий лук;&lt;/li&gt;&lt;li&gt;соус BBQ.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Вес блюда — 400 г. Быстрая доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '380 г', '', 'Бургер «Шакил О\'Нил»', '', ''),
(264, 2, 'Бургер «Шакил О\'Нил»', '&lt;p&gt;Нет возможности выйти из квартиры, чтобы поесть?&lt;/p&gt;&lt;p&gt;Покупайте Бургер «Шакил О\'Нил» из ресторана &quot;Вилки-Палки&quot;. Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;медово-горчичный соус;&lt;/li&gt;&lt;li&gt;маринованный огурец;&lt;/li&gt;&lt;li&gt;сыр чеддер;&lt;/li&gt;&lt;li&gt;булочка для бургера;&lt;/li&gt;&lt;li&gt;куриная котлета;&lt;/li&gt;&lt;li&gt;котлета из говядины;&lt;/li&gt;&lt;li&gt;свежие томаты;&lt;/li&gt;&lt;li&gt;синий лук;&lt;/li&gt;&lt;li&gt;соус BBQ.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Вес блюда — 400 г. Быстрая доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '380 г', '', 'Бургер «Шакил О\'Нил»', '', ''),
(256, 2, 'Бургер «Шакил О\'Нил»', '&lt;p&gt;Нет возможности выйти из квартиры, чтобы поесть?&lt;/p&gt;&lt;p&gt;Покупайте Бургер «Шакил О\'Нил» из ресторана &quot;Вилки-Палки&quot;. Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;медово-горчичный соус;&lt;/li&gt;&lt;li&gt;маринованный огурец;&lt;/li&gt;&lt;li&gt;сыр чеддер;&lt;/li&gt;&lt;li&gt;булочка для бургера;&lt;/li&gt;&lt;li&gt;куриная котлета;&lt;/li&gt;&lt;li&gt;котлета из говядины;&lt;/li&gt;&lt;li&gt;свежие томаты;&lt;/li&gt;&lt;li&gt;синий лук;&lt;/li&gt;&lt;li&gt;соус BBQ.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Вес блюда — 400 г. Быстрая доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '380 г', '', 'Бургер «Шакил О\'Нил»', '', ''),
(257, 2, 'Бургер «Шакил О\'Нил»', '&lt;p&gt;Нет возможности выйти из квартиры, чтобы поесть?&lt;/p&gt;&lt;p&gt;Покупайте Бургер «Шакил О\'Нил» из ресторана &quot;Вилки-Палки&quot;. Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;медово-горчичный соус;&lt;/li&gt;&lt;li&gt;маринованный огурец;&lt;/li&gt;&lt;li&gt;сыр чеддер;&lt;/li&gt;&lt;li&gt;булочка для бургера;&lt;/li&gt;&lt;li&gt;куриная котлета;&lt;/li&gt;&lt;li&gt;котлета из говядины;&lt;/li&gt;&lt;li&gt;свежие томаты;&lt;/li&gt;&lt;li&gt;синий лук;&lt;/li&gt;&lt;li&gt;соус BBQ.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Вес блюда — 400 г. Быстрая доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '380 г', '', 'Бургер «Шакил О\'Нил»', '', ''),
(183, 2, 'Рис «Тяхан с курицей»', '&lt;p&gt;Лапша и рис давно уже стали простыми и в то же время экзотическими блюдами далеко за пределами Китая. Они имеют необычный потрясающий вкус и обладают высокой энергетической ценностью.&lt;/p&gt;&lt;p&gt;Хотите утолить зверский голод? Один из изысканных вариантов называется Рис «Тяхан с курицей».&lt;/p&gt;&lt;p&gt;Это блюдо с отменным набором ингредиентов| Это блюдо с ингредиентами:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;морковь;&lt;/li&gt;&lt;li&gt;зеленый лук;&lt;/li&gt;&lt;li&gt;болгарский перец;&lt;/li&gt;&lt;li&gt;репчатый лук;&lt;/li&gt;&lt;li&gt;рис;&lt;/li&gt;&lt;li&gt;кунжут;&lt;/li&gt;&lt;li&gt;соус соевый;&lt;/li&gt;&lt;li&gt;чеснок;&lt;/li&gt;&lt;li&gt;шампиньоны;&lt;/li&gt;&lt;li&gt;курица.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Такой аромат не передать словами!&lt;/p&gt;&lt;p&gt;Пригласите своих друзей посмотреть интересный фильм, сделайте заказ паназиатской еды из кафе «966» и поверьте, ваши гости будут в восторге от такого экзотического меню!&lt;/p&gt;&lt;p&gt;Вес порции — 350 г. Своевременная доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '200г/350г', '', 'Рис «Тяхан с курицей»', '', ''),
(291, 2, 'Пицца «Фирменная»', '&lt;p&gt;Пицца по праву считается одним из самых знаменитых блюд на всей планете, ибо ее изумительный вкус оставляет только положительные ощущения. Один из изысканных вариантов называется Пицца «Фирменная».&lt;/p&gt;&lt;p&gt;Пицца собрала в своем рецепте:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;сыр моцарелла;&lt;/li&gt;&lt;li&gt;болгарский перец;&lt;/li&gt;&lt;li&gt;бекон;&lt;/li&gt;&lt;li&gt;томатный соус;&lt;/li&gt;&lt;li&gt;ветчина;&lt;/li&gt;&lt;li&gt;курица гриль;&lt;/li&gt;&lt;li&gt;салями пепперони.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;От такого вы будете просто в восторге!&lt;/p&gt;&lt;p&gt;Необыкновенно вкусная и очень аппетитная Пицца «Фирменная» получит только положительные отзывы от тех, кто ее попробует. Сделав заказ пиццы на дом для себя или компании из кафе «Pizza.od.ua», вы никого не оставите голодным, ведь это блюдо очень сытное. Пицца «Фирменная» отлично справится со своей основной целью – накормить каждого.&lt;/p&gt;&lt;p&gt;Вес пиццы составляет 400 г. Оперативная доставка еды на дом от 60 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '950г', '', 'Пицца «Фирменная»', '', ''),
(292, 2, 'Рис «Тяхан с курицей»', '&lt;p&gt;Лапша и рис давно уже стали простыми и в то же время экзотическими блюдами далеко за пределами Китая. Они имеют необычный потрясающий вкус и обладают высокой энергетической ценностью.&lt;/p&gt;&lt;p&gt;Хотите утолить зверский голод? Один из изысканных вариантов называется Рис «Тяхан с курицей».&lt;/p&gt;&lt;p&gt;Это блюдо с отменным набором ингредиентов| Это блюдо с ингредиентами:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;морковь;&lt;/li&gt;&lt;li&gt;зеленый лук;&lt;/li&gt;&lt;li&gt;болгарский перец;&lt;/li&gt;&lt;li&gt;репчатый лук;&lt;/li&gt;&lt;li&gt;рис;&lt;/li&gt;&lt;li&gt;кунжут;&lt;/li&gt;&lt;li&gt;соус соевый;&lt;/li&gt;&lt;li&gt;чеснок;&lt;/li&gt;&lt;li&gt;шампиньоны;&lt;/li&gt;&lt;li&gt;курица.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Такой аромат не передать словами!&lt;/p&gt;&lt;p&gt;Пригласите своих друзей посмотреть интересный фильм, сделайте заказ паназиатской еды из кафе «966» и поверьте, ваши гости будут в восторге от такого экзотического меню!&lt;/p&gt;&lt;p&gt;Вес порции — 350 г. Своевременная доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '200г/350г', '', 'Рис «Тяхан с курицей»', '', ''),
(293, 2, 'Рис «Тяхан с курицей»', '&lt;p&gt;Лапша и рис давно уже стали простыми и в то же время экзотическими блюдами далеко за пределами Китая. Они имеют необычный потрясающий вкус и обладают высокой энергетической ценностью.&lt;/p&gt;&lt;p&gt;Хотите утолить зверский голод? Один из изысканных вариантов называется Рис «Тяхан с курицей».&lt;/p&gt;&lt;p&gt;Это блюдо с отменным набором ингредиентов| Это блюдо с ингредиентами:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;морковь;&lt;/li&gt;&lt;li&gt;зеленый лук;&lt;/li&gt;&lt;li&gt;болгарский перец;&lt;/li&gt;&lt;li&gt;репчатый лук;&lt;/li&gt;&lt;li&gt;рис;&lt;/li&gt;&lt;li&gt;кунжут;&lt;/li&gt;&lt;li&gt;соус соевый;&lt;/li&gt;&lt;li&gt;чеснок;&lt;/li&gt;&lt;li&gt;шампиньоны;&lt;/li&gt;&lt;li&gt;курица.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Такой аромат не передать словами!&lt;/p&gt;&lt;p&gt;Пригласите своих друзей посмотреть интересный фильм, сделайте заказ паназиатской еды из кафе «966» и поверьте, ваши гости будут в восторге от такого экзотического меню!&lt;/p&gt;&lt;p&gt;Вес порции — 350 г. Своевременная доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '200г/350г', '', 'Рис «Тяхан с курицей»', '', ''),
(294, 2, 'Рис «Тяхан с курицей»', '&lt;p&gt;Лапша и рис давно уже стали простыми и в то же время экзотическими блюдами далеко за пределами Китая. Они имеют необычный потрясающий вкус и обладают высокой энергетической ценностью.&lt;/p&gt;&lt;p&gt;Хотите утолить зверский голод? Один из изысканных вариантов называется Рис «Тяхан с курицей».&lt;/p&gt;&lt;p&gt;Это блюдо с отменным набором ингредиентов| Это блюдо с ингредиентами:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;морковь;&lt;/li&gt;&lt;li&gt;зеленый лук;&lt;/li&gt;&lt;li&gt;болгарский перец;&lt;/li&gt;&lt;li&gt;репчатый лук;&lt;/li&gt;&lt;li&gt;рис;&lt;/li&gt;&lt;li&gt;кунжут;&lt;/li&gt;&lt;li&gt;соус соевый;&lt;/li&gt;&lt;li&gt;чеснок;&lt;/li&gt;&lt;li&gt;шампиньоны;&lt;/li&gt;&lt;li&gt;курица.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Такой аромат не передать словами!&lt;/p&gt;&lt;p&gt;Пригласите своих друзей посмотреть интересный фильм, сделайте заказ паназиатской еды из кафе «966» и поверьте, ваши гости будут в восторге от такого экзотического меню!&lt;/p&gt;&lt;p&gt;Вес порции — 350 г. Своевременная доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '200г/350г', '', 'Рис «Тяхан с курицей»', '', ''),
(295, 2, 'Пицца «Фирменная»', '&lt;p&gt;Пицца по праву считается одним из самых знаменитых блюд на всей планете, ибо ее изумительный вкус оставляет только положительные ощущения. Один из изысканных вариантов называется Пицца «Фирменная».&lt;/p&gt;&lt;p&gt;Пицца собрала в своем рецепте:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;сыр моцарелла;&lt;/li&gt;&lt;li&gt;болгарский перец;&lt;/li&gt;&lt;li&gt;бекон;&lt;/li&gt;&lt;li&gt;томатный соус;&lt;/li&gt;&lt;li&gt;ветчина;&lt;/li&gt;&lt;li&gt;курица гриль;&lt;/li&gt;&lt;li&gt;салями пепперони.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;От такого вы будете просто в восторге!&lt;/p&gt;&lt;p&gt;Необыкновенно вкусная и очень аппетитная Пицца «Фирменная» получит только положительные отзывы от тех, кто ее попробует. Сделав заказ пиццы на дом для себя или компании из кафе «Pizza.od.ua», вы никого не оставите голодным, ведь это блюдо очень сытное. Пицца «Фирменная» отлично справится со своей основной целью – накормить каждого.&lt;/p&gt;&lt;p&gt;Вес пиццы составляет 400 г. Оперативная доставка еды на дом от 60 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '950г', '', 'Пицца «Фирменная»', '', ''),
(296, 2, 'Рис «Тяхан с курицей»', '&lt;p&gt;Лапша и рис давно уже стали простыми и в то же время экзотическими блюдами далеко за пределами Китая. Они имеют необычный потрясающий вкус и обладают высокой энергетической ценностью.&lt;/p&gt;&lt;p&gt;Хотите утолить зверский голод? Один из изысканных вариантов называется Рис «Тяхан с курицей».&lt;/p&gt;&lt;p&gt;Это блюдо с отменным набором ингредиентов| Это блюдо с ингредиентами:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;морковь;&lt;/li&gt;&lt;li&gt;зеленый лук;&lt;/li&gt;&lt;li&gt;болгарский перец;&lt;/li&gt;&lt;li&gt;репчатый лук;&lt;/li&gt;&lt;li&gt;рис;&lt;/li&gt;&lt;li&gt;кунжут;&lt;/li&gt;&lt;li&gt;соус соевый;&lt;/li&gt;&lt;li&gt;чеснок;&lt;/li&gt;&lt;li&gt;шампиньоны;&lt;/li&gt;&lt;li&gt;курица.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Такой аромат не передать словами!&lt;/p&gt;&lt;p&gt;Пригласите своих друзей посмотреть интересный фильм, сделайте заказ паназиатской еды из кафе «966» и поверьте, ваши гости будут в восторге от такого экзотического меню!&lt;/p&gt;&lt;p&gt;Вес порции — 350 г. Своевременная доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '200г/350г', '', 'Рис «Тяхан с курицей»', '', ''),
(297, 2, 'Рис «Тяхан с курицей»', '&lt;p&gt;Лапша и рис давно уже стали простыми и в то же время экзотическими блюдами далеко за пределами Китая. Они имеют необычный потрясающий вкус и обладают высокой энергетической ценностью.&lt;/p&gt;&lt;p&gt;Хотите утолить зверский голод? Один из изысканных вариантов называется Рис «Тяхан с курицей».&lt;/p&gt;&lt;p&gt;Это блюдо с отменным набором ингредиентов| Это блюдо с ингредиентами:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;морковь;&lt;/li&gt;&lt;li&gt;зеленый лук;&lt;/li&gt;&lt;li&gt;болгарский перец;&lt;/li&gt;&lt;li&gt;репчатый лук;&lt;/li&gt;&lt;li&gt;рис;&lt;/li&gt;&lt;li&gt;кунжут;&lt;/li&gt;&lt;li&gt;соус соевый;&lt;/li&gt;&lt;li&gt;чеснок;&lt;/li&gt;&lt;li&gt;шампиньоны;&lt;/li&gt;&lt;li&gt;курица.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Такой аромат не передать словами!&lt;/p&gt;&lt;p&gt;Пригласите своих друзей посмотреть интересный фильм, сделайте заказ паназиатской еды из кафе «966» и поверьте, ваши гости будут в восторге от такого экзотического меню!&lt;/p&gt;&lt;p&gt;Вес порции — 350 г. Своевременная доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '200г/350г', '', 'Рис «Тяхан с курицей»', '', ''),
(334, 2, 'Сашимі «Угорь»', '&lt;p&gt;Нет желания выйти из квартиры, чтобы подкрепиться?&lt;/p&gt;&lt;p&gt;Заказывайте Сашими «Угорь» из ресторана &quot;966&quot;. Это вкусное, сытное, а также полезное блюдо, приготовленное из свежайших ингредиентов, в состав которого входит:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;угорь;&lt;/li&gt;&lt;li&gt;огурец;&lt;/li&gt;&lt;li&gt;дайкон.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Вес блюда — 45 г. Быстрая доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '38 г', '', 'Сашимі «Угорь»', '', ''),
(332, 2, 'Сашимі «Угорь»', '&lt;p&gt;Нет желания выйти из квартиры, чтобы подкрепиться?&lt;/p&gt;&lt;p&gt;Заказывайте Сашими «Угорь» из ресторана &quot;966&quot;. Это вкусное, сытное, а также полезное блюдо, приготовленное из свежайших ингредиентов, в состав которого входит:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;угорь;&lt;/li&gt;&lt;li&gt;огурец;&lt;/li&gt;&lt;li&gt;дайкон.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Вес блюда — 45 г. Быстрая доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '38 г', '', 'Сашимі «Угорь»', '', ''),
(333, 2, 'Сашимі «Угорь»', '&lt;p&gt;Нет желания выйти из квартиры, чтобы подкрепиться?&lt;/p&gt;&lt;p&gt;Заказывайте Сашими «Угорь» из ресторана &quot;966&quot;. Это вкусное, сытное, а также полезное блюдо, приготовленное из свежайших ингредиентов, в состав которого входит:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;угорь;&lt;/li&gt;&lt;li&gt;огурец;&lt;/li&gt;&lt;li&gt;дайкон.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Вес блюда — 45 г. Быстрая доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '38 г', '', 'Сашимі «Угорь»', '', ''),
(331, 2, 'Сашимі «Угорь»', '&lt;p&gt;Нет желания выйти из квартиры, чтобы подкрепиться?&lt;/p&gt;&lt;p&gt;Заказывайте Сашими «Угорь» из ресторана &quot;966&quot;. Это вкусное, сытное, а также полезное блюдо, приготовленное из свежайших ингредиентов, в состав которого входит:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;угорь;&lt;/li&gt;&lt;li&gt;огурец;&lt;/li&gt;&lt;li&gt;дайкон.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Вес блюда — 45 г. Быстрая доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '38 г', '', 'Сашимі «Угорь»', '', ''),
(329, 2, 'Сашимі «Угорь»', '&lt;p&gt;Нет желания выйти из квартиры, чтобы подкрепиться?&lt;/p&gt;&lt;p&gt;Заказывайте Сашими «Угорь» из ресторана &quot;966&quot;. Это вкусное, сытное, а также полезное блюдо, приготовленное из свежайших ингредиентов, в состав которого входит:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;угорь;&lt;/li&gt;&lt;li&gt;огурец;&lt;/li&gt;&lt;li&gt;дайкон.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Вес блюда — 45 г. Быстрая доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '38 г', '', 'Сашимі «Угорь»', '', ''),
(330, 2, 'Сашимі «Угорь»', '&lt;p&gt;Нет желания выйти из квартиры, чтобы подкрепиться?&lt;/p&gt;&lt;p&gt;Заказывайте Сашими «Угорь» из ресторана &quot;966&quot;. Это вкусное, сытное, а также полезное блюдо, приготовленное из свежайших ингредиентов, в состав которого входит:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;угорь;&lt;/li&gt;&lt;li&gt;огурец;&lt;/li&gt;&lt;li&gt;дайкон.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Вес блюда — 45 г. Быстрая доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '38 г', '', 'Сашимі «Угорь»', '', ''),
(328, 2, 'Сашимі «Угорь»', '&lt;p&gt;Нет желания выйти из квартиры, чтобы подкрепиться?&lt;/p&gt;&lt;p&gt;Заказывайте Сашими «Угорь» из ресторана &quot;966&quot;. Это вкусное, сытное, а также полезное блюдо, приготовленное из свежайших ингредиентов, в состав которого входит:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;угорь;&lt;/li&gt;&lt;li&gt;огурец;&lt;/li&gt;&lt;li&gt;дайкон.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Вес блюда — 45 г. Быстрая доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '38 г', '', 'Сашимі «Угорь»', '', ''),
(327, 2, 'Рис «Тяхан с курицей»', '&lt;p&gt;Лапша и рис давно уже стали простыми и в то же время экзотическими блюдами далеко за пределами Китая. Они имеют необычный потрясающий вкус и обладают высокой энергетической ценностью.&lt;/p&gt;&lt;p&gt;Хотите утолить зверский голод? Один из изысканных вариантов называется Рис «Тяхан с курицей».&lt;/p&gt;&lt;p&gt;Это блюдо с отменным набором ингредиентов| Это блюдо с ингредиентами:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;морковь;&lt;/li&gt;&lt;li&gt;зеленый лук;&lt;/li&gt;&lt;li&gt;болгарский перец;&lt;/li&gt;&lt;li&gt;репчатый лук;&lt;/li&gt;&lt;li&gt;рис;&lt;/li&gt;&lt;li&gt;кунжут;&lt;/li&gt;&lt;li&gt;соус соевый;&lt;/li&gt;&lt;li&gt;чеснок;&lt;/li&gt;&lt;li&gt;шампиньоны;&lt;/li&gt;&lt;li&gt;курица.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Такой аромат не передать словами!&lt;/p&gt;&lt;p&gt;Пригласите своих друзей посмотреть интересный фильм, сделайте заказ паназиатской еды из кафе «966» и поверьте, ваши гости будут в восторге от такого экзотического меню!&lt;/p&gt;&lt;p&gt;Вес порции — 350 г. Своевременная доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '200г/350г', '', 'Рис «Тяхан с курицей»', '', ''),
(326, 2, 'Рис «Тяхан с курицей»', '&lt;p&gt;Лапша и рис давно уже стали простыми и в то же время экзотическими блюдами далеко за пределами Китая. Они имеют необычный потрясающий вкус и обладают высокой энергетической ценностью.&lt;/p&gt;&lt;p&gt;Хотите утолить зверский голод? Один из изысканных вариантов называется Рис «Тяхан с курицей».&lt;/p&gt;&lt;p&gt;Это блюдо с отменным набором ингредиентов| Это блюдо с ингредиентами:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;морковь;&lt;/li&gt;&lt;li&gt;зеленый лук;&lt;/li&gt;&lt;li&gt;болгарский перец;&lt;/li&gt;&lt;li&gt;репчатый лук;&lt;/li&gt;&lt;li&gt;рис;&lt;/li&gt;&lt;li&gt;кунжут;&lt;/li&gt;&lt;li&gt;соус соевый;&lt;/li&gt;&lt;li&gt;чеснок;&lt;/li&gt;&lt;li&gt;шампиньоны;&lt;/li&gt;&lt;li&gt;курица.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Такой аромат не передать словами!&lt;/p&gt;&lt;p&gt;Пригласите своих друзей посмотреть интересный фильм, сделайте заказ паназиатской еды из кафе «966» и поверьте, ваши гости будут в восторге от такого экзотического меню!&lt;/p&gt;&lt;p&gt;Вес порции — 350 г. Своевременная доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '200г/350г', '', 'Рис «Тяхан с курицей»', '', ''),
(320, 2, 'Рис «Тяхан с курицей»', '&lt;p&gt;Лапша и рис давно уже стали простыми и в то же время экзотическими блюдами далеко за пределами Китая. Они имеют необычный потрясающий вкус и обладают высокой энергетической ценностью.&lt;/p&gt;&lt;p&gt;Хотите утолить зверский голод? Один из изысканных вариантов называется Рис «Тяхан с курицей».&lt;/p&gt;&lt;p&gt;Это блюдо с отменным набором ингредиентов| Это блюдо с ингредиентами:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;морковь;&lt;/li&gt;&lt;li&gt;зеленый лук;&lt;/li&gt;&lt;li&gt;болгарский перец;&lt;/li&gt;&lt;li&gt;репчатый лук;&lt;/li&gt;&lt;li&gt;рис;&lt;/li&gt;&lt;li&gt;кунжут;&lt;/li&gt;&lt;li&gt;соус соевый;&lt;/li&gt;&lt;li&gt;чеснок;&lt;/li&gt;&lt;li&gt;шампиньоны;&lt;/li&gt;&lt;li&gt;курица.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Такой аромат не передать словами!&lt;/p&gt;&lt;p&gt;Пригласите своих друзей посмотреть интересный фильм, сделайте заказ паназиатской еды из кафе «966» и поверьте, ваши гости будут в восторге от такого экзотического меню!&lt;/p&gt;&lt;p&gt;Вес порции — 350 г. Своевременная доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '200г/350г', '', 'Рис «Тяхан с курицей»', '', ''),
(319, 2, 'Рис «Тяхан с курицей»', '&lt;p&gt;Лапша и рис давно уже стали простыми и в то же время экзотическими блюдами далеко за пределами Китая. Они имеют необычный потрясающий вкус и обладают высокой энергетической ценностью.&lt;/p&gt;&lt;p&gt;Хотите утолить зверский голод? Один из изысканных вариантов называется Рис «Тяхан с курицей».&lt;/p&gt;&lt;p&gt;Это блюдо с отменным набором ингредиентов| Это блюдо с ингредиентами:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;морковь;&lt;/li&gt;&lt;li&gt;зеленый лук;&lt;/li&gt;&lt;li&gt;болгарский перец;&lt;/li&gt;&lt;li&gt;репчатый лук;&lt;/li&gt;&lt;li&gt;рис;&lt;/li&gt;&lt;li&gt;кунжут;&lt;/li&gt;&lt;li&gt;соус соевый;&lt;/li&gt;&lt;li&gt;чеснок;&lt;/li&gt;&lt;li&gt;шампиньоны;&lt;/li&gt;&lt;li&gt;курица.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Такой аромат не передать словами!&lt;/p&gt;&lt;p&gt;Пригласите своих друзей посмотреть интересный фильм, сделайте заказ паназиатской еды из кафе «966» и поверьте, ваши гости будут в восторге от такого экзотического меню!&lt;/p&gt;&lt;p&gt;Вес порции — 350 г. Своевременная доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '200г/350г', '', 'Рис «Тяхан с курицей»', '', ''),
(318, 2, 'Рис «Тяхан с курицей»', '&lt;p&gt;Лапша и рис давно уже стали простыми и в то же время экзотическими блюдами далеко за пределами Китая. Они имеют необычный потрясающий вкус и обладают высокой энергетической ценностью.&lt;/p&gt;&lt;p&gt;Хотите утолить зверский голод? Один из изысканных вариантов называется Рис «Тяхан с курицей».&lt;/p&gt;&lt;p&gt;Это блюдо с отменным набором ингредиентов| Это блюдо с ингредиентами:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;морковь;&lt;/li&gt;&lt;li&gt;зеленый лук;&lt;/li&gt;&lt;li&gt;болгарский перец;&lt;/li&gt;&lt;li&gt;репчатый лук;&lt;/li&gt;&lt;li&gt;рис;&lt;/li&gt;&lt;li&gt;кунжут;&lt;/li&gt;&lt;li&gt;соус соевый;&lt;/li&gt;&lt;li&gt;чеснок;&lt;/li&gt;&lt;li&gt;шампиньоны;&lt;/li&gt;&lt;li&gt;курица.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Такой аромат не передать словами!&lt;/p&gt;&lt;p&gt;Пригласите своих друзей посмотреть интересный фильм, сделайте заказ паназиатской еды из кафе «966» и поверьте, ваши гости будут в восторге от такого экзотического меню!&lt;/p&gt;&lt;p&gt;Вес порции — 350 г. Своевременная доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '200г/350г', '', 'Рис «Тяхан с курицей»', '', ''),
(317, 2, 'Рис «Тяхан с курицей»', '&lt;p&gt;Лапша и рис давно уже стали простыми и в то же время экзотическими блюдами далеко за пределами Китая. Они имеют необычный потрясающий вкус и обладают высокой энергетической ценностью.&lt;/p&gt;&lt;p&gt;Хотите утолить зверский голод? Один из изысканных вариантов называется Рис «Тяхан с курицей».&lt;/p&gt;&lt;p&gt;Это блюдо с отменным набором ингредиентов| Это блюдо с ингредиентами:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;морковь;&lt;/li&gt;&lt;li&gt;зеленый лук;&lt;/li&gt;&lt;li&gt;болгарский перец;&lt;/li&gt;&lt;li&gt;репчатый лук;&lt;/li&gt;&lt;li&gt;рис;&lt;/li&gt;&lt;li&gt;кунжут;&lt;/li&gt;&lt;li&gt;соус соевый;&lt;/li&gt;&lt;li&gt;чеснок;&lt;/li&gt;&lt;li&gt;шампиньоны;&lt;/li&gt;&lt;li&gt;курица.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Такой аромат не передать словами!&lt;/p&gt;&lt;p&gt;Пригласите своих друзей посмотреть интересный фильм, сделайте заказ паназиатской еды из кафе «966» и поверьте, ваши гости будут в восторге от такого экзотического меню!&lt;/p&gt;&lt;p&gt;Вес порции — 350 г. Своевременная доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '200г/350г', '', 'Рис «Тяхан с курицей»', '', ''),
(307, 2, 'Сет «Мітчел»', '&lt;p&gt;В составе сета роллы: «Филадельфия в кунжуте», «Овощной», с водорослями чука, с огурцом; суши «Гункан с водорослями чука» (3 шт.). Всего — 33 кусочка.&lt;br&gt;&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '52 шт., 1380 г', '', 'Сет «Мітчел»', '', ''),
(308, 2, 'Сет «Мітчел»', '&lt;p&gt;В составе сета роллы: «Филадельфия в кунжуте», «Овощной», с водорослями чука, с огурцом; суши «Гункан с водорослями чука» (3 шт.). Всего — 33 кусочка.&lt;br&gt;&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '52 шт., 1380 г', '', 'Сет «Мітчел»', '', ''),
(309, 2, 'Сет «Мітчел»', '&lt;p&gt;В составе сета роллы: «Филадельфия в кунжуте», «Овощной», с водорослями чука, с огурцом; суши «Гункан с водорослями чука» (3 шт.). Всего — 33 кусочка.&lt;br&gt;&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '52 шт., 1380 г', '', 'Сет «Мітчел»', '', ''),
(310, 2, 'Шашлык из свинины от Marinara', '&lt;p&gt;Весовая позиция. Цена указана за 100 г.&lt;br&gt;&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '580 г', '', 'Шашлык из свинины от Marinara', '', ''),
(305, 2, 'Сашимі «Угорь»', '&lt;p&gt;Нет желания выйти из квартиры, чтобы подкрепиться?&lt;/p&gt;&lt;p&gt;Заказывайте Сашими «Угорь» из ресторана &quot;966&quot;. Это вкусное, сытное, а также полезное блюдо, приготовленное из свежайших ингредиентов, в состав которого входит:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;угорь;&lt;/li&gt;&lt;li&gt;огурец;&lt;/li&gt;&lt;li&gt;дайкон.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Вес блюда — 45 г. Быстрая доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '38 г', '', 'Сашимі «Угорь»', '', ''),
(306, 2, 'Сашимі «Угорь»', '&lt;p&gt;Нет желания выйти из квартиры, чтобы подкрепиться?&lt;/p&gt;&lt;p&gt;Заказывайте Сашими «Угорь» из ресторана &quot;966&quot;. Это вкусное, сытное, а также полезное блюдо, приготовленное из свежайших ингредиентов, в состав которого входит:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;угорь;&lt;/li&gt;&lt;li&gt;огурец;&lt;/li&gt;&lt;li&gt;дайкон.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Вес блюда — 45 г. Быстрая доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '38 г', '', 'Сашимі «Угорь»', '', ''),
(303, 2, 'Сашимі «Угорь»', '&lt;p&gt;Нет желания выйти из квартиры, чтобы подкрепиться?&lt;/p&gt;&lt;p&gt;Заказывайте Сашими «Угорь» из ресторана &quot;966&quot;. Это вкусное, сытное, а также полезное блюдо, приготовленное из свежайших ингредиентов, в состав которого входит:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;угорь;&lt;/li&gt;&lt;li&gt;огурец;&lt;/li&gt;&lt;li&gt;дайкон.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Вес блюда — 45 г. Быстрая доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '38 г', '', 'Сашимі «Угорь»', '', ''),
(304, 2, 'Сашимі «Угорь»', '&lt;p&gt;Нет желания выйти из квартиры, чтобы подкрепиться?&lt;/p&gt;&lt;p&gt;Заказывайте Сашими «Угорь» из ресторана &quot;966&quot;. Это вкусное, сытное, а также полезное блюдо, приготовленное из свежайших ингредиентов, в состав которого входит:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;угорь;&lt;/li&gt;&lt;li&gt;огурец;&lt;/li&gt;&lt;li&gt;дайкон.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Вес блюда — 45 г. Быстрая доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '38 г', '', 'Сашимі «Угорь»', '', ''),
(302, 2, 'Рис «Тяхан с курицей»', '&lt;p&gt;Лапша и рис давно уже стали простыми и в то же время экзотическими блюдами далеко за пределами Китая. Они имеют необычный потрясающий вкус и обладают высокой энергетической ценностью.&lt;/p&gt;&lt;p&gt;Хотите утолить зверский голод? Один из изысканных вариантов называется Рис «Тяхан с курицей».&lt;/p&gt;&lt;p&gt;Это блюдо с отменным набором ингредиентов| Это блюдо с ингредиентами:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;морковь;&lt;/li&gt;&lt;li&gt;зеленый лук;&lt;/li&gt;&lt;li&gt;болгарский перец;&lt;/li&gt;&lt;li&gt;репчатый лук;&lt;/li&gt;&lt;li&gt;рис;&lt;/li&gt;&lt;li&gt;кунжут;&lt;/li&gt;&lt;li&gt;соус соевый;&lt;/li&gt;&lt;li&gt;чеснок;&lt;/li&gt;&lt;li&gt;шампиньоны;&lt;/li&gt;&lt;li&gt;курица.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Такой аромат не передать словами!&lt;/p&gt;&lt;p&gt;Пригласите своих друзей посмотреть интересный фильм, сделайте заказ паназиатской еды из кафе «966» и поверьте, ваши гости будут в восторге от такого экзотического меню!&lt;/p&gt;&lt;p&gt;Вес порции — 350 г. Своевременная доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '200г/350г', '', 'Рис «Тяхан с курицей»', '', ''),
(301, 2, 'Рис «Тяхан с курицей»', '&lt;p&gt;Лапша и рис давно уже стали простыми и в то же время экзотическими блюдами далеко за пределами Китая. Они имеют необычный потрясающий вкус и обладают высокой энергетической ценностью.&lt;/p&gt;&lt;p&gt;Хотите утолить зверский голод? Один из изысканных вариантов называется Рис «Тяхан с курицей».&lt;/p&gt;&lt;p&gt;Это блюдо с отменным набором ингредиентов| Это блюдо с ингредиентами:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;морковь;&lt;/li&gt;&lt;li&gt;зеленый лук;&lt;/li&gt;&lt;li&gt;болгарский перец;&lt;/li&gt;&lt;li&gt;репчатый лук;&lt;/li&gt;&lt;li&gt;рис;&lt;/li&gt;&lt;li&gt;кунжут;&lt;/li&gt;&lt;li&gt;соус соевый;&lt;/li&gt;&lt;li&gt;чеснок;&lt;/li&gt;&lt;li&gt;шампиньоны;&lt;/li&gt;&lt;li&gt;курица.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Такой аромат не передать словами!&lt;/p&gt;&lt;p&gt;Пригласите своих друзей посмотреть интересный фильм, сделайте заказ паназиатской еды из кафе «966» и поверьте, ваши гости будут в восторге от такого экзотического меню!&lt;/p&gt;&lt;p&gt;Вес порции — 350 г. Своевременная доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '200г/350г', '', 'Рис «Тяхан с курицей»', '', ''),
(275, 2, 'Бургер «Шакил О\'Нил»', '&lt;p&gt;Нет возможности выйти из квартиры, чтобы поесть?&lt;/p&gt;&lt;p&gt;Покупайте Бургер «Шакил О\'Нил» из ресторана &quot;Вилки-Палки&quot;. Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;медово-горчичный соус;&lt;/li&gt;&lt;li&gt;маринованный огурец;&lt;/li&gt;&lt;li&gt;сыр чеддер;&lt;/li&gt;&lt;li&gt;булочка для бургера;&lt;/li&gt;&lt;li&gt;куриная котлета;&lt;/li&gt;&lt;li&gt;котлета из говядины;&lt;/li&gt;&lt;li&gt;свежие томаты;&lt;/li&gt;&lt;li&gt;синий лук;&lt;/li&gt;&lt;li&gt;соус BBQ.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Вес блюда — 400 г. Быстрая доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '380 г', '', 'Бургер «Шакил О\'Нил»', '', ''),
(274, 2, 'Бургер «Шакил О\'Нил»', '&lt;p&gt;Нет возможности выйти из квартиры, чтобы поесть?&lt;/p&gt;&lt;p&gt;Покупайте Бургер «Шакил О\'Нил» из ресторана &quot;Вилки-Палки&quot;. Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;медово-горчичный соус;&lt;/li&gt;&lt;li&gt;маринованный огурец;&lt;/li&gt;&lt;li&gt;сыр чеддер;&lt;/li&gt;&lt;li&gt;булочка для бургера;&lt;/li&gt;&lt;li&gt;куриная котлета;&lt;/li&gt;&lt;li&gt;котлета из говядины;&lt;/li&gt;&lt;li&gt;свежие томаты;&lt;/li&gt;&lt;li&gt;синий лук;&lt;/li&gt;&lt;li&gt;соус BBQ.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Вес блюда — 400 г. Быстрая доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '380 г', '', 'Бургер «Шакил О\'Нил»', '', ''),
(273, 2, 'Бургер «Шакил О\'Нил»', '&lt;p&gt;Нет возможности выйти из квартиры, чтобы поесть?&lt;/p&gt;&lt;p&gt;Покупайте Бургер «Шакил О\'Нил» из ресторана &quot;Вилки-Палки&quot;. Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;медово-горчичный соус;&lt;/li&gt;&lt;li&gt;маринованный огурец;&lt;/li&gt;&lt;li&gt;сыр чеддер;&lt;/li&gt;&lt;li&gt;булочка для бургера;&lt;/li&gt;&lt;li&gt;куриная котлета;&lt;/li&gt;&lt;li&gt;котлета из говядины;&lt;/li&gt;&lt;li&gt;свежие томаты;&lt;/li&gt;&lt;li&gt;синий лук;&lt;/li&gt;&lt;li&gt;соус BBQ.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Вес блюда — 400 г. Быстрая доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '380 г', '', 'Бургер «Шакил О\'Нил»', '', ''),
(272, 2, 'Бургер «Шакил О\'Нил»', '&lt;p&gt;Нет возможности выйти из квартиры, чтобы поесть?&lt;/p&gt;&lt;p&gt;Покупайте Бургер «Шакил О\'Нил» из ресторана &quot;Вилки-Палки&quot;. Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;медово-горчичный соус;&lt;/li&gt;&lt;li&gt;маринованный огурец;&lt;/li&gt;&lt;li&gt;сыр чеддер;&lt;/li&gt;&lt;li&gt;булочка для бургера;&lt;/li&gt;&lt;li&gt;куриная котлета;&lt;/li&gt;&lt;li&gt;котлета из говядины;&lt;/li&gt;&lt;li&gt;свежие томаты;&lt;/li&gt;&lt;li&gt;синий лук;&lt;/li&gt;&lt;li&gt;соус BBQ.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Вес блюда — 400 г. Быстрая доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '380 г', '', 'Бургер «Шакил О\'Нил»', '', ''),
(266, 2, 'Бургер «Шакил О\'Нил»', '&lt;p&gt;Нет возможности выйти из квартиры, чтобы поесть?&lt;/p&gt;&lt;p&gt;Покупайте Бургер «Шакил О\'Нил» из ресторана &quot;Вилки-Палки&quot;. Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;медово-горчичный соус;&lt;/li&gt;&lt;li&gt;маринованный огурец;&lt;/li&gt;&lt;li&gt;сыр чеддер;&lt;/li&gt;&lt;li&gt;булочка для бургера;&lt;/li&gt;&lt;li&gt;куриная котлета;&lt;/li&gt;&lt;li&gt;котлета из говядины;&lt;/li&gt;&lt;li&gt;свежие томаты;&lt;/li&gt;&lt;li&gt;синий лук;&lt;/li&gt;&lt;li&gt;соус BBQ.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Вес блюда — 400 г. Быстрая доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '380 г', '', 'Бургер «Шакил О\'Нил»', '', ''),
(265, 2, 'Бургер «Шакил О\'Нил»', '&lt;p&gt;Нет возможности выйти из квартиры, чтобы поесть?&lt;/p&gt;&lt;p&gt;Покупайте Бургер «Шакил О\'Нил» из ресторана &quot;Вилки-Палки&quot;. Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;медово-горчичный соус;&lt;/li&gt;&lt;li&gt;маринованный огурец;&lt;/li&gt;&lt;li&gt;сыр чеддер;&lt;/li&gt;&lt;li&gt;булочка для бургера;&lt;/li&gt;&lt;li&gt;куриная котлета;&lt;/li&gt;&lt;li&gt;котлета из говядины;&lt;/li&gt;&lt;li&gt;свежие томаты;&lt;/li&gt;&lt;li&gt;синий лук;&lt;/li&gt;&lt;li&gt;соус BBQ.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Вес блюда — 400 г. Быстрая доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '380 г', '', 'Бургер «Шакил О\'Нил»', '', ''),
(255, 2, 'Бургер «Шакил О\'Нил»', '&lt;p&gt;Нет возможности выйти из квартиры, чтобы поесть?&lt;/p&gt;&lt;p&gt;Покупайте Бургер «Шакил О\'Нил» из ресторана &quot;Вилки-Палки&quot;. Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;медово-горчичный соус;&lt;/li&gt;&lt;li&gt;маринованный огурец;&lt;/li&gt;&lt;li&gt;сыр чеддер;&lt;/li&gt;&lt;li&gt;булочка для бургера;&lt;/li&gt;&lt;li&gt;куриная котлета;&lt;/li&gt;&lt;li&gt;котлета из говядины;&lt;/li&gt;&lt;li&gt;свежие томаты;&lt;/li&gt;&lt;li&gt;синий лук;&lt;/li&gt;&lt;li&gt;соус BBQ.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Вес блюда — 400 г. Быстрая доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '380 г', '', 'Бургер «Шакил О\'Нил»', '', ''),
(244, 2, 'Напій Coca Cola', '&lt;p&gt;Сладкие газированные напитки помогают освежиться в знойный летний день, скрасить обычные встречи с друзьями или создать вкусные коктейли. Продукция Кока-кола отлично справляется со всеми этими задачами.&lt;/p&gt;&lt;p&gt;Объема бутылки в 0.5 литра хватит, чтобы утолить жажду одному человеку или приготовить напитки на небольшую компанию. Как утверждают отзывы о Coca-Cola - лучше всего газировка сочетается со льдом и виски.&lt;/p&gt;&lt;p&gt;Обращаем ваше внимание на то, что следящим за своим здоровьем и весом лучше выбирать менее калорийную продукцию торговой марки.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '0,5 л', '', 'Напій Coca Cola', '', ''),
(246, 2, 'Бургер «Шакил О\'Нил»', '&lt;p&gt;Нет возможности выйти из квартиры, чтобы поесть?&lt;/p&gt;&lt;p&gt;Покупайте Бургер «Шакил О\'Нил» из ресторана &quot;Вилки-Палки&quot;. Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;медово-горчичный соус;&lt;/li&gt;&lt;li&gt;маринованный огурец;&lt;/li&gt;&lt;li&gt;сыр чеддер;&lt;/li&gt;&lt;li&gt;булочка для бургера;&lt;/li&gt;&lt;li&gt;куриная котлета;&lt;/li&gt;&lt;li&gt;котлета из говядины;&lt;/li&gt;&lt;li&gt;свежие томаты;&lt;/li&gt;&lt;li&gt;синий лук;&lt;/li&gt;&lt;li&gt;соус BBQ.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Вес блюда — 400 г. Быстрая доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '380 г', '', 'Бургер «Шакил О\'Нил»', '', ''),
(247, 2, 'Бургер «Шакил О\'Нил»', '&lt;p&gt;Нет возможности выйти из квартиры, чтобы поесть?&lt;/p&gt;&lt;p&gt;Покупайте Бургер «Шакил О\'Нил» из ресторана &quot;Вилки-Палки&quot;. Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;медово-горчичный соус;&lt;/li&gt;&lt;li&gt;маринованный огурец;&lt;/li&gt;&lt;li&gt;сыр чеддер;&lt;/li&gt;&lt;li&gt;булочка для бургера;&lt;/li&gt;&lt;li&gt;куриная котлета;&lt;/li&gt;&lt;li&gt;котлета из говядины;&lt;/li&gt;&lt;li&gt;свежие томаты;&lt;/li&gt;&lt;li&gt;синий лук;&lt;/li&gt;&lt;li&gt;соус BBQ.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Вес блюда — 400 г. Быстрая доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '380 г', '', 'Бургер «Шакил О\'Нил»', '', ''),
(336, 2, 'Сет «Мітчел»', '&lt;p&gt;В составе сета роллы: «Филадельфия в кунжуте», «Овощной», с водорослями чука, с огурцом; суши «Гункан с водорослями чука» (3 шт.). Всего — 33 кусочка.&lt;br&gt;&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '52 шт., 1380 г', '', 'Сет «Мітчел»', '', ''),
(337, 2, 'Сет «Мітчел»', '&lt;p&gt;В составе сета роллы: «Филадельфия в кунжуте», «Овощной», с водорослями чука, с огурцом; суши «Гункан с водорослями чука» (3 шт.). Всего — 33 кусочка.&lt;br&gt;&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '52 шт., 1380 г', '', 'Сет «Мітчел»', '', ''),
(338, 2, 'Сет «Мітчел»', '&lt;p&gt;В составе сета роллы: «Филадельфия в кунжуте», «Овощной», с водорослями чука, с огурцом; суши «Гункан с водорослями чука» (3 шт.). Всего — 33 кусочка.&lt;br&gt;&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '52 шт., 1380 г', '', 'Сет «Мітчел»', '', ''),
(339, 2, 'Сет «Мітчел»', '&lt;p&gt;В составе сета роллы: «Филадельфия в кунжуте», «Овощной», с водорослями чука, с огурцом; суши «Гункан с водорослями чука» (3 шт.). Всего — 33 кусочка.&lt;br&gt;&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '52 шт., 1380 г', '', 'Сет «Мітчел»', '', ''),
(340, 2, 'Сет «Мітчел»', '&lt;p&gt;В составе сета роллы: «Филадельфия в кунжуте», «Овощной», с водорослями чука, с огурцом; суши «Гункан с водорослями чука» (3 шт.). Всего — 33 кусочка.&lt;br&gt;&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '52 шт., 1380 г', '', 'Сет «Мітчел»', '', ''),
(341, 2, 'Сет «Мітчел»', '&lt;p&gt;В составе сета роллы: «Филадельфия в кунжуте», «Овощной», с водорослями чука, с огурцом; суши «Гункан с водорослями чука» (3 шт.). Всего — 33 кусочка.&lt;br&gt;&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '52 шт., 1380 г', '', 'Сет «Мітчел»', '', ''),
(342, 2, 'Шашлык из свинины от Marinara', '&lt;p&gt;Весовая позиция. Цена указана за 100 г.&lt;br&gt;&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '580 г', '', 'Шашлык из свинины от Marinara', '', ''),
(343, 2, 'Шашлык из свинины от Marinara', '&lt;p&gt;Весовая позиция. Цена указана за 100 г.&lt;br&gt;&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '580 г', '', 'Шашлык из свинины от Marinara', '', ''),
(344, 2, 'Шашлык из свинины от Marinara', '&lt;p&gt;Весовая позиция. Цена указана за 100 г.&lt;br&gt;&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '580 г', '', 'Шашлык из свинины от Marinara', '', ''),
(345, 2, 'Шашлык из свинины от Marinara', '&lt;p&gt;Весовая позиция. Цена указана за 100 г.&lt;br&gt;&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '580 г', '', 'Шашлык из свинины от Marinara', '', ''),
(346, 2, 'Шашлык из свинины от Marinara', '&lt;p&gt;Весовая позиция. Цена указана за 100 г.&lt;br&gt;&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '580 г', '', 'Шашлык из свинины от Marinara', '', ''),
(347, 2, 'Шашлык из свинины от Marinara', '&lt;p&gt;Весовая позиция. Цена указана за 100 г.&lt;br&gt;&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '580 г', '', 'Шашлык из свинины от Marinara', '', ''),
(348, 2, 'Шашлык из свинины от Marinara', '&lt;p&gt;Весовая позиция. Цена указана за 100 г.&lt;br&gt;&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '580 г', '', 'Шашлык из свинины от Marinara', '', ''),
(349, 2, 'Шашлык из свинины от Marinara', '&lt;p&gt;Весовая позиция. Цена указана за 100 г.&lt;br&gt;&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '580 г', '', 'Шашлык из свинины от Marinara', '', ''),
(350, 2, 'Шашлык из свинины от Marinara', '&lt;p&gt;Весовая позиция. Цена указана за 100 г.&lt;br&gt;&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '580 г', '', 'Шашлык из свинины от Marinara', '', ''),
(351, 2, 'Шашлык из свинины от Marinara', '&lt;p&gt;Весовая позиция. Цена указана за 100 г.&lt;br&gt;&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '580 г', '', 'Шашлык из свинины от Marinara', '', ''),
(352, 2, 'Шашлык из свинины от Marinara', '&lt;p&gt;Весовая позиция. Цена указана за 100 г.&lt;br&gt;&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '580 г', '', 'Шашлык из свинины от Marinara', '', ''),
(353, 2, 'Шашлык из свинины от Marinara', '&lt;p&gt;Весовая позиция. Цена указана за 100 г.&lt;br&gt;&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '580 г', '', 'Шашлык из свинины от Marinara', '', ''),
(363, 2, 'Тест', '', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '', '', 'Тест', '', ''),
(173, 2, 'Бургер «Шакил О\'Нил»', '&lt;p&gt;Нет возможности выйти из квартиры, чтобы поесть?&lt;/p&gt;&lt;p&gt;Покупайте Бургер «Шакил О\'Нил» из ресторана &quot;Вилки-Палки&quot;. Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;медово-горчичный соус;&lt;/li&gt;&lt;li&gt;маринованный огурец;&lt;/li&gt;&lt;li&gt;сыр чеддер;&lt;/li&gt;&lt;li&gt;булочка для бургера;&lt;/li&gt;&lt;li&gt;куриная котлета;&lt;/li&gt;&lt;li&gt;котлета из говядины;&lt;/li&gt;&lt;li&gt;свежие томаты;&lt;/li&gt;&lt;li&gt;синий лук;&lt;/li&gt;&lt;li&gt;соус BBQ.&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;Вес блюда — 400 г. Быстрая доставка еды на дом от 90 мин.&lt;/p&gt;', 'Это вкусное, сытное, а также полезное блюдо, сделанное из свежих ингредиентов, в состав которого входит', '380 г', '', 'Бургер «Шакил О\'Нил»', '', '');

-- --------------------------------------------------------

--
-- Структура таблицы `oc_product_discount`
--

CREATE TABLE `oc_product_discount` (
  `product_discount_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `customer_group_id` int(11) NOT NULL,
  `quantity` int(4) NOT NULL DEFAULT 0,
  `priority` int(5) NOT NULL DEFAULT 1,
  `price` decimal(15,4) NOT NULL DEFAULT 0.0000,
  `date_start` date NOT NULL DEFAULT '0000-00-00',
  `date_end` date NOT NULL DEFAULT '0000-00-00'
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `oc_product_filter`
--

CREATE TABLE `oc_product_filter` (
  `product_id` int(11) NOT NULL,
  `filter_id` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `oc_product_image`
--

CREATE TABLE `oc_product_image` (
  `product_image_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `image` varchar(255) DEFAULT NULL,
  `sort_order` int(3) NOT NULL DEFAULT 0
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `oc_product_option`
--

CREATE TABLE `oc_product_option` (
  `product_option_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `option_id` int(11) NOT NULL,
  `value` text NOT NULL,
  `required` tinyint(1) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `oc_product_option_value`
--

CREATE TABLE `oc_product_option_value` (
  `product_option_value_id` int(11) NOT NULL,
  `product_option_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `option_id` int(11) NOT NULL,
  `option_value_id` int(11) NOT NULL,
  `quantity` int(3) NOT NULL,
  `subtract` tinyint(1) NOT NULL,
  `price` decimal(15,4) NOT NULL,
  `price_prefix` varchar(1) NOT NULL,
  `points` int(8) NOT NULL,
  `points_prefix` varchar(1) NOT NULL,
  `weight` decimal(15,8) NOT NULL,
  `weight_prefix` varchar(1) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `oc_product_recurring`
--

CREATE TABLE `oc_product_recurring` (
  `product_id` int(11) NOT NULL,
  `recurring_id` int(11) NOT NULL,
  `customer_group_id` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `oc_product_related`
--

CREATE TABLE `oc_product_related` (
  `product_id` int(11) NOT NULL,
  `related_id` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_product_related`
--

INSERT INTO `oc_product_related` (`product_id`, `related_id`) VALUES
(50, 244),
(71, 244),
(146, 244),
(173, 244),
(178, 244),
(183, 244),
(244, 50),
(244, 71),
(244, 146),
(244, 173),
(244, 178),
(244, 183),
(244, 245),
(244, 246),
(244, 247),
(244, 248),
(244, 249),
(244, 250),
(244, 251),
(244, 252),
(244, 253),
(244, 254),
(244, 255),
(244, 256),
(244, 257),
(244, 258),
(244, 259),
(244, 260),
(244, 261),
(244, 262),
(244, 263),
(244, 264),
(244, 265),
(244, 266),
(244, 267),
(244, 268),
(244, 269),
(244, 270),
(244, 271),
(244, 272),
(244, 273),
(244, 274),
(244, 275),
(244, 276),
(244, 277),
(244, 278),
(244, 279),
(244, 280),
(244, 281),
(244, 282),
(244, 283),
(244, 284),
(244, 285),
(244, 286),
(244, 287),
(244, 288),
(244, 289),
(244, 290),
(244, 291),
(244, 292),
(244, 293),
(244, 294),
(244, 295),
(244, 296),
(244, 297),
(244, 298),
(244, 299),
(244, 300),
(244, 301),
(244, 302),
(244, 303),
(244, 304),
(244, 305),
(244, 306),
(244, 307),
(244, 308),
(244, 309),
(244, 310),
(244, 311),
(244, 312),
(244, 313),
(244, 314),
(244, 315),
(244, 316),
(244, 317),
(244, 318),
(244, 319),
(244, 320),
(244, 321),
(244, 322),
(244, 323),
(244, 324),
(244, 325),
(244, 326),
(244, 327),
(244, 328),
(244, 329),
(244, 330),
(244, 331),
(244, 332),
(244, 333),
(244, 334),
(244, 335),
(244, 336),
(244, 337),
(244, 338),
(244, 339),
(244, 340),
(244, 341),
(244, 342),
(244, 343),
(244, 344),
(244, 345),
(244, 346),
(244, 347),
(244, 348),
(244, 349),
(244, 350),
(244, 351),
(244, 352),
(244, 353),
(245, 244),
(246, 244),
(247, 244),
(248, 244),
(249, 244),
(250, 244),
(251, 244),
(252, 244),
(253, 244),
(254, 244),
(255, 244),
(256, 244),
(257, 244),
(258, 244),
(259, 244),
(260, 244),
(261, 244),
(262, 244),
(263, 244),
(264, 244),
(265, 244),
(266, 244),
(267, 244),
(268, 244),
(269, 244),
(270, 244),
(271, 244),
(272, 244),
(273, 244),
(274, 244),
(275, 244),
(276, 244),
(277, 244),
(278, 244),
(279, 244),
(280, 244),
(281, 244),
(282, 244),
(283, 244),
(284, 244),
(285, 244),
(286, 244),
(287, 244),
(288, 244),
(289, 244),
(290, 244),
(291, 244),
(292, 244),
(293, 244),
(294, 244),
(295, 244),
(296, 244),
(297, 244),
(298, 244),
(299, 244),
(300, 244),
(301, 244),
(302, 244),
(303, 244),
(304, 244),
(305, 244),
(306, 244),
(307, 244),
(308, 244),
(309, 244),
(310, 244),
(311, 244),
(312, 244),
(313, 244),
(314, 244),
(315, 244),
(316, 244),
(317, 244),
(318, 244),
(319, 244),
(320, 244),
(321, 244),
(322, 244),
(323, 244),
(324, 244),
(325, 244),
(326, 244),
(327, 244),
(328, 244),
(329, 244),
(330, 244),
(331, 244),
(332, 244),
(333, 244),
(334, 244),
(335, 244),
(336, 244),
(337, 244),
(338, 244),
(339, 244),
(340, 244),
(341, 244),
(342, 244),
(343, 244),
(344, 244),
(345, 244),
(346, 244),
(347, 244),
(348, 244),
(349, 244),
(350, 244),
(351, 244),
(352, 244),
(353, 244);

-- --------------------------------------------------------

--
-- Структура таблицы `oc_product_reward`
--

CREATE TABLE `oc_product_reward` (
  `product_reward_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL DEFAULT 0,
  `customer_group_id` int(11) NOT NULL DEFAULT 0,
  `points` int(8) NOT NULL DEFAULT 0
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `oc_product_special`
--

CREATE TABLE `oc_product_special` (
  `product_special_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `customer_group_id` int(11) NOT NULL,
  `priority` int(5) NOT NULL DEFAULT 1,
  `price` decimal(15,4) NOT NULL DEFAULT 0.0000,
  `date_start` date NOT NULL DEFAULT '0000-00-00',
  `date_end` date NOT NULL DEFAULT '0000-00-00'
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_product_special`
--

INSERT INTO `oc_product_special` (`product_special_id`, `product_id`, `customer_group_id`, `priority`, `price`, `date_start`, `date_end`) VALUES
(601, 71, 1, 0, '80.0000', '0000-00-00', '0000-00-00'),
(637, 309, 1, 0, '100.0000', '0000-00-00', '0000-00-00'),
(670, 342, 1, 0, '50.0000', '0000-00-00', '0000-00-00'),
(602, 50, 1, 0, '100.0000', '0000-00-00', '0000-00-00'),
(580, 257, 1, 0, '100.0000', '0000-00-00', '0000-00-00'),
(626, 298, 1, 0, '50.0000', '0000-00-00', '0000-00-00'),
(676, 348, 1, 0, '50.0000', '0000-00-00', '0000-00-00'),
(640, 312, 1, 0, '100.0000', '0000-00-00', '0000-00-00'),
(625, 297, 1, 0, '50.0000', '0000-00-00', '0000-00-00'),
(615, 287, 1, 0, '100.0000', '0000-00-00', '0000-00-00'),
(595, 272, 1, 0, '100.0000', '0000-00-00', '0000-00-00'),
(581, 258, 1, 0, '100.0000', '0000-00-00', '0000-00-00'),
(669, 341, 1, 0, '100.0000', '0000-00-00', '0000-00-00'),
(668, 340, 1, 0, '100.0000', '0000-00-00', '0000-00-00'),
(639, 311, 1, 0, '50.0000', '0000-00-00', '0000-00-00'),
(638, 310, 1, 0, '50.0000', '0000-00-00', '0000-00-00'),
(624, 296, 1, 0, '50.0000', '0000-00-00', '0000-00-00'),
(623, 295, 1, 0, '100.0000', '0000-00-00', '0000-00-00'),
(616, 288, 1, 0, '100.0000', '0000-00-00', '0000-00-00'),
(617, 289, 1, 0, '100.0000', '0000-00-00', '0000-00-00'),
(596, 273, 1, 0, '100.0000', '0000-00-00', '0000-00-00'),
(597, 274, 1, 0, '100.0000', '0000-00-00', '0000-00-00'),
(582, 259, 1, 0, '100.0000', '0000-00-00', '0000-00-00'),
(603, 146, 1, 0, '50.0000', '0000-00-00', '0000-00-00'),
(680, 352, 1, 0, '50.0000', '0000-00-00', '0000-00-00'),
(679, 351, 1, 0, '50.0000', '0000-00-00', '0000-00-00'),
(678, 350, 1, 0, '50.0000', '0000-00-00', '0000-00-00'),
(677, 349, 1, 0, '50.0000', '0000-00-00', '0000-00-00'),
(648, 320, 1, 0, '50.0000', '0000-00-00', '0000-00-00'),
(647, 319, 1, 0, '50.0000', '0000-00-00', '0000-00-00'),
(646, 318, 1, 0, '50.0000', '0000-00-00', '0000-00-00'),
(641, 313, 1, 0, '100.0000', '0000-00-00', '0000-00-00'),
(627, 299, 1, 0, '50.0000', '0000-00-00', '0000-00-00'),
(628, 300, 1, 0, '50.0000', '0000-00-00', '0000-00-00'),
(629, 301, 1, 0, '50.0000', '0000-00-00', '0000-00-00'),
(622, 294, 1, 0, '50.0000', '0000-00-00', '0000-00-00'),
(611, 283, 1, 0, '50.0000', '0000-00-00', '0000-00-00'),
(612, 284, 1, 0, '50.0000', '0000-00-00', '0000-00-00'),
(613, 285, 1, 0, '80.0000', '0000-00-00', '0000-00-00'),
(614, 286, 1, 0, '80.0000', '0000-00-00', '0000-00-00'),
(594, 271, 1, 0, '100.0000', '0000-00-00', '0000-00-00'),
(591, 268, 1, 0, '100.0000', '0000-00-00', '0000-00-00'),
(592, 269, 1, 0, '100.0000', '0000-00-00', '0000-00-00'),
(593, 270, 1, 0, '100.0000', '0000-00-00', '0000-00-00'),
(671, 343, 1, 0, '50.0000', '0000-00-00', '0000-00-00'),
(672, 344, 1, 0, '50.0000', '0000-00-00', '0000-00-00'),
(673, 345, 1, 0, '50.0000', '0000-00-00', '0000-00-00'),
(674, 346, 1, 0, '50.0000', '0000-00-00', '0000-00-00'),
(675, 347, 1, 0, '50.0000', '0000-00-00', '0000-00-00'),
(681, 353, 1, 0, '50.0000', '0000-00-00', '0000-00-00'),
(687, 173, 1, 0, '100.0000', '0000-00-00', '0000-00-00'),
(649, 321, 1, 0, '50.0000', '0000-00-00', '0000-00-00'),
(650, 322, 1, 0, '50.0000', '0000-00-00', '0000-00-00'),
(651, 323, 1, 0, '50.0000', '0000-00-00', '0000-00-00'),
(599, 178, 1, 0, '100.0000', '0000-00-00', '0000-00-00'),
(645, 317, 1, 0, '50.0000', '0000-00-00', '0000-00-00'),
(644, 316, 1, 0, '50.0000', '0000-00-00', '0000-00-00'),
(643, 315, 1, 0, '50.0000', '0000-00-00', '0000-00-00'),
(642, 314, 1, 0, '50.0000', '0000-00-00', '0000-00-00'),
(600, 183, 1, 0, '50.0000', '0000-00-00', '0000-00-00'),
(632, 304, 1, 0, '80.0000', '0000-00-00', '0000-00-00'),
(631, 303, 1, 0, '80.0000', '0000-00-00', '0000-00-00'),
(630, 302, 1, 0, '50.0000', '0000-00-00', '0000-00-00'),
(667, 339, 1, 0, '100.0000', '0000-00-00', '0000-00-00'),
(666, 338, 1, 0, '100.0000', '0000-00-00', '0000-00-00'),
(665, 337, 1, 0, '100.0000', '0000-00-00', '0000-00-00'),
(664, 336, 1, 0, '100.0000', '0000-00-00', '0000-00-00'),
(663, 335, 1, 0, '80.0000', '0000-00-00', '0000-00-00'),
(662, 334, 1, 0, '80.0000', '0000-00-00', '0000-00-00'),
(661, 333, 1, 0, '80.0000', '0000-00-00', '0000-00-00'),
(660, 332, 1, 0, '80.0000', '0000-00-00', '0000-00-00'),
(659, 331, 1, 0, '80.0000', '0000-00-00', '0000-00-00'),
(658, 330, 1, 0, '80.0000', '0000-00-00', '0000-00-00'),
(657, 329, 1, 0, '80.0000', '0000-00-00', '0000-00-00'),
(656, 328, 1, 0, '80.0000', '0000-00-00', '0000-00-00'),
(655, 327, 1, 0, '50.0000', '0000-00-00', '0000-00-00'),
(654, 326, 1, 0, '50.0000', '0000-00-00', '0000-00-00'),
(653, 325, 1, 0, '50.0000', '0000-00-00', '0000-00-00'),
(652, 324, 1, 0, '50.0000', '0000-00-00', '0000-00-00'),
(636, 308, 1, 0, '100.0000', '0000-00-00', '0000-00-00'),
(635, 307, 1, 0, '100.0000', '0000-00-00', '0000-00-00'),
(634, 306, 1, 0, '80.0000', '0000-00-00', '0000-00-00'),
(633, 305, 1, 0, '80.0000', '0000-00-00', '0000-00-00'),
(621, 293, 1, 0, '50.0000', '0000-00-00', '0000-00-00'),
(620, 292, 1, 0, '50.0000', '0000-00-00', '0000-00-00'),
(619, 291, 1, 0, '100.0000', '0000-00-00', '0000-00-00'),
(618, 290, 1, 0, '100.0000', '0000-00-00', '0000-00-00'),
(610, 282, 1, 0, '100.0000', '0000-00-00', '0000-00-00'),
(609, 281, 1, 0, '100.0000', '0000-00-00', '0000-00-00'),
(608, 280, 1, 0, '50.0000', '0000-00-00', '0000-00-00'),
(607, 279, 1, 0, '100.0000', '0000-00-00', '0000-00-00'),
(606, 278, 1, 0, '80.0000', '0000-00-00', '0000-00-00'),
(605, 277, 1, 0, '50.0000', '0000-00-00', '0000-00-00'),
(604, 276, 1, 0, '100.0000', '0000-00-00', '0000-00-00'),
(598, 275, 1, 0, '100.0000', '0000-00-00', '0000-00-00'),
(590, 267, 1, 0, '100.0000', '0000-00-00', '0000-00-00'),
(589, 266, 1, 0, '100.0000', '0000-00-00', '0000-00-00'),
(588, 265, 1, 0, '100.0000', '0000-00-00', '0000-00-00'),
(587, 264, 1, 0, '100.0000', '0000-00-00', '0000-00-00'),
(586, 263, 1, 0, '100.0000', '0000-00-00', '0000-00-00'),
(585, 262, 1, 0, '100.0000', '0000-00-00', '0000-00-00'),
(584, 261, 1, 0, '100.0000', '0000-00-00', '0000-00-00'),
(583, 260, 1, 0, '100.0000', '0000-00-00', '0000-00-00'),
(579, 256, 1, 0, '100.0000', '0000-00-00', '0000-00-00'),
(578, 255, 1, 0, '100.0000', '0000-00-00', '0000-00-00'),
(577, 254, 1, 0, '100.0000', '0000-00-00', '0000-00-00'),
(576, 253, 1, 0, '100.0000', '0000-00-00', '0000-00-00'),
(575, 252, 1, 0, '100.0000', '0000-00-00', '0000-00-00'),
(574, 251, 1, 0, '100.0000', '0000-00-00', '0000-00-00'),
(573, 250, 1, 0, '100.0000', '0000-00-00', '0000-00-00'),
(572, 249, 1, 0, '100.0000', '0000-00-00', '0000-00-00'),
(571, 248, 1, 0, '100.0000', '0000-00-00', '0000-00-00'),
(688, 245, 1, 0, '100.0000', '0000-00-00', '0000-00-00'),
(569, 246, 1, 0, '100.0000', '0000-00-00', '0000-00-00'),
(570, 247, 1, 0, '100.0000', '0000-00-00', '0000-00-00');

-- --------------------------------------------------------

--
-- Структура таблицы `oc_product_to_category`
--

CREATE TABLE `oc_product_to_category` (
  `product_id` int(11) NOT NULL,
  `category_id` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_product_to_category`
--

INSERT INTO `oc_product_to_category` (`product_id`, `category_id`) VALUES
(50, 60),
(50, 64),
(71, 60),
(71, 65),
(146, 62),
(173, 61),
(178, 59),
(183, 63),
(244, 78),
(245, 61),
(246, 61),
(247, 61),
(248, 61),
(249, 61),
(250, 61),
(251, 61),
(252, 61),
(253, 61),
(254, 61),
(255, 61),
(256, 61),
(257, 61),
(258, 61),
(259, 61),
(260, 61),
(261, 61),
(262, 61),
(263, 61),
(264, 61),
(265, 61),
(266, 61),
(267, 61),
(268, 61),
(269, 61),
(270, 61),
(271, 61),
(272, 61),
(273, 61),
(274, 61),
(275, 61),
(276, 59),
(277, 63),
(278, 60),
(278, 65),
(279, 60),
(279, 64),
(280, 62),
(281, 59),
(282, 59),
(283, 63),
(284, 63),
(285, 60),
(285, 65),
(286, 60),
(286, 65),
(287, 60),
(287, 64),
(288, 59),
(289, 59),
(290, 59),
(291, 59),
(292, 63),
(293, 63),
(294, 63),
(295, 59),
(296, 63),
(297, 63),
(298, 63),
(299, 63),
(300, 63),
(301, 63),
(302, 63),
(303, 60),
(303, 65),
(304, 60),
(304, 65),
(305, 60),
(305, 65),
(306, 60),
(306, 65),
(307, 60),
(307, 64),
(308, 60),
(308, 64),
(309, 60),
(309, 64),
(310, 62),
(311, 62),
(312, 59),
(313, 59),
(314, 63),
(315, 63),
(316, 63),
(317, 63),
(318, 63),
(319, 63),
(320, 63),
(321, 63),
(322, 63),
(323, 63),
(324, 63),
(325, 63),
(326, 63),
(327, 63),
(328, 60),
(328, 65),
(329, 60),
(329, 65),
(330, 60),
(330, 65),
(331, 60),
(331, 65),
(332, 60),
(332, 65),
(333, 60),
(333, 65),
(334, 60),
(334, 65),
(335, 60),
(335, 65),
(336, 60),
(336, 64),
(337, 60),
(337, 64),
(338, 60),
(338, 64),
(339, 60),
(339, 64),
(340, 60),
(340, 64),
(341, 60),
(341, 64),
(342, 62),
(343, 62),
(344, 62),
(345, 62),
(346, 62),
(347, 62),
(348, 62),
(349, 62),
(350, 62),
(351, 62),
(352, 62),
(353, 62);

-- --------------------------------------------------------

--
-- Структура таблицы `oc_product_to_download`
--

CREATE TABLE `oc_product_to_download` (
  `product_id` int(11) NOT NULL,
  `download_id` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `oc_product_to_layout`
--

CREATE TABLE `oc_product_to_layout` (
  `product_id` int(11) NOT NULL,
  `store_id` int(11) NOT NULL,
  `layout_id` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_product_to_layout`
--

INSERT INTO `oc_product_to_layout` (`product_id`, `store_id`, `layout_id`) VALUES
(50, 0, 0),
(313, 0, 0),
(314, 0, 0),
(315, 0, 0),
(316, 0, 0),
(178, 0, 0),
(322, 0, 0),
(321, 0, 0),
(320, 0, 0),
(353, 0, 0),
(173, 0, 0),
(352, 0, 0),
(346, 0, 0),
(345, 0, 0),
(344, 0, 0),
(343, 0, 0),
(342, 0, 0),
(269, 0, 0),
(268, 0, 0),
(267, 0, 0),
(270, 0, 0),
(71, 0, 0),
(351, 0, 0),
(146, 0, 0),
(258, 0, 0),
(273, 0, 0),
(272, 0, 0),
(288, 0, 0),
(287, 0, 0),
(294, 0, 0),
(295, 0, 0),
(309, 0, 0),
(310, 0, 0),
(339, 0, 0),
(340, 0, 0),
(257, 0, 0),
(271, 0, 0),
(286, 0, 0),
(296, 0, 0),
(311, 0, 0),
(347, 0, 0),
(297, 0, 0),
(325, 0, 0),
(326, 0, 0),
(327, 0, 0),
(350, 0, 0),
(328, 0, 0),
(329, 0, 0),
(330, 0, 0),
(331, 0, 0),
(332, 0, 0),
(333, 0, 0),
(334, 0, 0),
(335, 0, 0),
(308, 0, 0),
(298, 0, 0),
(312, 0, 0),
(317, 0, 0),
(318, 0, 0),
(319, 0, 0),
(348, 0, 0),
(349, 0, 0),
(341, 0, 0),
(285, 0, 0),
(284, 0, 0),
(283, 0, 0),
(282, 0, 0),
(293, 0, 0),
(300, 0, 0),
(299, 0, 0),
(256, 0, 0),
(336, 0, 0),
(337, 0, 0),
(338, 0, 0),
(301, 0, 0),
(302, 0, 0),
(303, 0, 0),
(183, 0, 0),
(324, 0, 0),
(323, 0, 0),
(307, 0, 0),
(306, 0, 0),
(305, 0, 0),
(304, 0, 0),
(292, 0, 0),
(291, 0, 0),
(290, 0, 0),
(289, 0, 0),
(281, 0, 0),
(280, 0, 0),
(279, 0, 0),
(278, 0, 0),
(277, 0, 0),
(276, 0, 0),
(275, 0, 0),
(274, 0, 0),
(266, 0, 0),
(265, 0, 0),
(264, 0, 0),
(263, 0, 0),
(262, 0, 0),
(261, 0, 0),
(260, 0, 0),
(259, 0, 0),
(255, 0, 0),
(254, 0, 0),
(253, 0, 0),
(252, 0, 0),
(251, 0, 0),
(250, 0, 0),
(249, 0, 0),
(248, 0, 0),
(247, 0, 0),
(244, 0, 0),
(245, 0, 0),
(246, 0, 0),
(363, 0, 0);

-- --------------------------------------------------------

--
-- Структура таблицы `oc_product_to_store`
--

CREATE TABLE `oc_product_to_store` (
  `product_id` int(11) NOT NULL,
  `store_id` int(11) NOT NULL DEFAULT 0
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_product_to_store`
--

INSERT INTO `oc_product_to_store` (`product_id`, `store_id`) VALUES
(50, 0),
(71, 0),
(146, 0),
(173, 0),
(178, 0),
(183, 0),
(244, 0),
(245, 0),
(246, 0),
(247, 0),
(248, 0),
(249, 0),
(250, 0),
(251, 0),
(252, 0),
(253, 0),
(254, 0),
(255, 0),
(256, 0),
(257, 0),
(258, 0),
(259, 0),
(260, 0),
(261, 0),
(262, 0),
(263, 0),
(264, 0),
(265, 0),
(266, 0),
(267, 0),
(268, 0),
(269, 0),
(270, 0),
(271, 0),
(272, 0),
(273, 0),
(274, 0),
(275, 0),
(276, 0),
(277, 0),
(278, 0),
(279, 0),
(280, 0),
(281, 0),
(282, 0),
(283, 0),
(284, 0),
(285, 0),
(286, 0),
(287, 0),
(288, 0),
(289, 0),
(290, 0),
(291, 0),
(292, 0),
(293, 0),
(294, 0),
(295, 0),
(296, 0),
(297, 0),
(298, 0),
(299, 0),
(300, 0),
(301, 0),
(302, 0),
(303, 0),
(304, 0),
(305, 0),
(306, 0),
(307, 0),
(308, 0),
(309, 0),
(310, 0),
(311, 0),
(312, 0),
(313, 0),
(314, 0),
(315, 0),
(316, 0),
(317, 0),
(318, 0),
(319, 0),
(320, 0),
(321, 0),
(322, 0),
(323, 0),
(324, 0),
(325, 0),
(326, 0),
(327, 0),
(328, 0),
(329, 0),
(330, 0),
(331, 0),
(332, 0),
(333, 0),
(334, 0),
(335, 0),
(336, 0),
(337, 0),
(338, 0),
(339, 0),
(340, 0),
(341, 0),
(342, 0),
(343, 0),
(344, 0),
(345, 0),
(346, 0),
(347, 0),
(348, 0),
(349, 0),
(350, 0),
(351, 0),
(352, 0),
(353, 0),
(363, 0);

-- --------------------------------------------------------

--
-- Структура таблицы `oc_recurring`
--

CREATE TABLE `oc_recurring` (
  `recurring_id` int(11) NOT NULL,
  `price` decimal(10,4) NOT NULL,
  `frequency` enum('day','week','semi_month','month','year') NOT NULL,
  `duration` int(10) UNSIGNED NOT NULL,
  `cycle` int(10) UNSIGNED NOT NULL,
  `trial_status` tinyint(4) NOT NULL,
  `trial_price` decimal(10,4) NOT NULL,
  `trial_frequency` enum('day','week','semi_month','month','year') NOT NULL,
  `trial_duration` int(10) UNSIGNED NOT NULL,
  `trial_cycle` int(10) UNSIGNED NOT NULL,
  `status` tinyint(4) NOT NULL,
  `sort_order` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `oc_recurring_description`
--

CREATE TABLE `oc_recurring_description` (
  `recurring_id` int(11) NOT NULL,
  `language_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `oc_return`
--

CREATE TABLE `oc_return` (
  `return_id` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `customer_id` int(11) NOT NULL,
  `firstname` varchar(32) NOT NULL,
  `lastname` varchar(32) NOT NULL,
  `email` varchar(96) NOT NULL,
  `telephone` varchar(32) NOT NULL,
  `product` varchar(255) NOT NULL,
  `model` varchar(64) NOT NULL,
  `quantity` int(4) NOT NULL,
  `opened` tinyint(1) NOT NULL,
  `return_reason_id` int(11) NOT NULL,
  `return_action_id` int(11) NOT NULL,
  `return_status_id` int(11) NOT NULL,
  `comment` text DEFAULT NULL,
  `date_ordered` date NOT NULL DEFAULT '0000-00-00',
  `date_added` datetime NOT NULL,
  `date_modified` datetime NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `oc_return_action`
--

CREATE TABLE `oc_return_action` (
  `return_action_id` int(11) NOT NULL,
  `language_id` int(11) NOT NULL DEFAULT 0,
  `name` varchar(64) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_return_action`
--

INSERT INTO `oc_return_action` (`return_action_id`, `language_id`, `name`) VALUES
(1, 1, 'Возвращены средства'),
(2, 1, 'Выдан в кредит'),
(3, 1, 'Отправлен другой товар для замены'),
(1, 2, 'Возвращены средства'),
(2, 2, 'Выдан в кредит'),
(3, 2, 'Отправлен другой товар для замены');

-- --------------------------------------------------------

--
-- Структура таблицы `oc_return_history`
--

CREATE TABLE `oc_return_history` (
  `return_history_id` int(11) NOT NULL,
  `return_id` int(11) NOT NULL,
  `return_status_id` int(11) NOT NULL,
  `notify` tinyint(1) NOT NULL,
  `comment` text NOT NULL,
  `date_added` datetime NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `oc_return_reason`
--

CREATE TABLE `oc_return_reason` (
  `return_reason_id` int(11) NOT NULL,
  `language_id` int(11) NOT NULL DEFAULT 0,
  `name` varchar(128) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_return_reason`
--

INSERT INTO `oc_return_reason` (`return_reason_id`, `language_id`, `name`) VALUES
(1, 1, 'Получен/доставлен неисправным (сломан)'),
(2, 1, 'Получен не тот (ошибочный) товар'),
(3, 1, 'Ошибочный заказ'),
(4, 1, 'Ошибка, пожалуйста укажите/приложите подробности'),
(5, 1, 'Другое (другая причина), пожалуйста укажите/приложите подробности'),
(1, 2, 'Получен/доставлен неисправным (сломан)'),
(2, 2, 'Получен не тот (ошибочный) товар'),
(3, 2, 'Ошибочный заказ'),
(4, 2, 'Ошибка, пожалуйста укажите/приложите подробности'),
(5, 2, 'Другое (другая причина), пожалуйста укажите/приложите подробности');

-- --------------------------------------------------------

--
-- Структура таблицы `oc_return_status`
--

CREATE TABLE `oc_return_status` (
  `return_status_id` int(11) NOT NULL,
  `language_id` int(11) NOT NULL DEFAULT 0,
  `name` varchar(32) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_return_status`
--

INSERT INTO `oc_return_status` (`return_status_id`, `language_id`, `name`) VALUES
(1, 1, 'Рассматриваемый'),
(3, 1, 'Готов (к отправке)'),
(2, 1, 'Заказ в ожидании'),
(1, 2, 'Рассматриваемый'),
(3, 2, 'Готов (к отправке)'),
(2, 2, 'Заказ в ожидании');

-- --------------------------------------------------------

--
-- Структура таблицы `oc_review`
--

CREATE TABLE `oc_review` (
  `review_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `customer_id` int(11) NOT NULL,
  `author` varchar(64) NOT NULL,
  `text` text NOT NULL,
  `rating` int(1) NOT NULL,
  `status` tinyint(1) NOT NULL DEFAULT 0,
  `date_added` datetime NOT NULL,
  `date_modified` datetime NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `oc_seo_url`
--

CREATE TABLE `oc_seo_url` (
  `seo_url_id` int(11) NOT NULL,
  `store_id` int(11) NOT NULL,
  `language_id` int(11) NOT NULL,
  `query` varchar(255) NOT NULL,
  `keyword` varchar(255) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_seo_url`
--

INSERT INTO `oc_seo_url` (`seo_url_id`, `store_id`, `language_id`, `query`, `keyword`) VALUES
(888, 0, 2, 'checkout/order', 'order'),
(889, 0, 2, 'checkout/success', 'success');

-- --------------------------------------------------------

--
-- Структура таблицы `oc_session`
--

CREATE TABLE `oc_session` (
  `session_id` varchar(32) NOT NULL,
  `data` text NOT NULL,
  `expire` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_session`
--

INSERT INTO `oc_session` (`session_id`, `data`, `expire`) VALUES
('003f37cf879a931b02e3273ce8', '{\"api_id\":\"1\"}', '2020-04-01 00:26:23'),
('00ee707c03e531e8fd85e152a5', '{\"language\":\"uk-ua\",\"currency\":\"UAH\"}', '2020-04-17 14:45:25'),
('03761dc4cafdc63c50fd3dfd6d', '{\"api_id\":\"1\"}', '2020-04-02 19:02:04'),
('03f481886c7634c0eec556829f', '{\"api_id\":\"1\"}', '2020-04-01 00:12:24'),
('05cc69d03e14ab086d4c3b5428', '{\"language\":\"uk-ua\",\"currency\":\"UAH\",\"user_id\":\"1\",\"user_token\":\"JZRbr5BPwC8IER4DVxl6g18TcRBW2fOD\",\"directory_file_manager\":\"Categori\",\"page_file_manager\":null}', '2020-03-30 17:34:33'),
('05ea39ab1042f32f8470c1c820', '{\"api_id\":\"1\"}', '2020-04-01 00:55:49'),
('070f4e4f301755577e8442bb29', '{\"api_id\":\"1\",\"language\":\"uk-ua\",\"currency\":\"UAH\"}', '2020-04-02 19:01:43'),
('07e15873c672e7cdbc2d5037ea', '{\"api_id\":\"1\",\"language\":\"uk-ua\",\"currency\":\"UAH\"}', '2020-04-01 01:10:41'),
('087a7ec947e15722d9122724d6', '{\"api_id\":\"1\",\"language\":\"uk-ua\",\"currency\":\"UAH\"}', '2020-03-31 19:47:01'),
('0b1487ff6023bcc2b2db199747', '{\"api_id\":\"1\",\"language\":\"uk-ua\",\"currency\":\"UAH\"}', '2020-04-01 00:24:17'),
('0c2aaaaa6422b89b3514a273fa', '{\"api_id\":\"1\"}', '2020-04-01 00:26:36'),
('0c8609e04b26a100299136d0a0', '{\"api_id\":\"1\"}', '2020-04-01 00:19:25'),
('0ed6eddf6677de7803ad862e7c', '{\"api_id\":\"1\"}', '2020-03-31 20:04:37'),
('0f714e5d20511f1d1587bbcb9b', '{\"api_id\":\"1\",\"language\":\"uk-ua\",\"currency\":\"UAH\"}', '2020-04-01 01:14:09'),
('100ccb73bbba6a7b9a49d27f42', '{\"api_id\":\"1\"}', '2020-04-01 01:14:40'),
('1020d6d16744dbc91a8a40e540', '{\"api_id\":\"1\",\"language\":\"uk-ua\",\"currency\":\"UAH\"}', '2020-04-02 19:01:27'),
('10b42a91d64db24792db458296', '{\"api_id\":\"1\",\"language\":\"uk-ua\",\"currency\":\"UAH\"}', '2020-04-01 01:13:35'),
('12c6d2c06453131e8e366a3180', '{\"api_id\":\"1\"}', '2020-03-31 19:47:31'),
('13f62a9429175d0c47363b5d0d', '{\"api_id\":\"1\"}', '2020-04-01 01:17:00'),
('14652208fb8eef337318cb49cb', '{\"api_id\":\"1\"}', '2020-03-31 19:47:03'),
('170fc1e0970e9f474620ad2faf', '{\"api_id\":\"1\"}', '2020-04-01 00:06:45'),
('19ae6c667f0069c1cf69d49cea', '{\"api_id\":\"1\"}', '2020-04-02 11:41:23'),
('1a5d7e8e8181808fd2d02c38e2', '{\"user_id\":\"1\",\"user_token\":\"p21ZU9plOl6szPu0sRawWndvauBc3v27\",\"install\":\"X0f7e793bM\",\"directory_file_manager\":\"demodata\",\"page_file_manager\":null,\"language\":\"uk-ua\",\"currency\":\"UAH\"}', '2020-03-30 14:16:00'),
('1eb16ef6432150760a4cc7254e', '{\"api_id\":\"1\"}', '2020-03-31 23:51:48'),
('2206fe33151b8f653811dbc4ee', '{\"api_id\":\"1\",\"language\":\"uk-ua\",\"currency\":\"UAH\"}', '2020-04-01 01:14:02'),
('22d87cf2370e35474cd42fc64d', '{\"api_id\":\"1\"}', '2020-03-31 20:02:04'),
('2971a46e9050a6e9eb23103b6f', '{\"api_id\":\"1\"}', '2020-04-01 01:17:13'),
('298e9523d5a55a6ef9c706699b', '{\"api_id\":\"1\",\"language\":\"uk-ua\",\"currency\":\"UAH\"}', '2020-04-02 19:01:37'),
('2b8e1313523b5e652c90a28d0a', '{\"api_id\":\"1\"}', '2020-04-01 00:03:40'),
('2bdc1a4ed5e73ea9d5de99e601', '{\"api_id\":\"1\"}', '2020-04-01 00:43:31'),
('31b13fa5b7524d85adcccd1507', '{\"api_id\":\"1\"}', '2020-04-01 00:23:37'),
('32c62a69d70a96b1dab7900721', '{\"api_id\":\"1\"}', '2020-04-02 11:53:10'),
('335c097f144f156288f97d549a', '{\"user_id\":\"1\",\"user_token\":\"r0EKd4rHIdBcfzxoAiuZL7UX7SVCHjbp\",\"language\":\"uk-ua\",\"currency\":\"UAH\",\"directory_file_manager\":\"demodata\",\"page_file_manager\":null}', '2020-04-17 15:03:12'),
('33a9e7c58008bb3791224120ad', '{\"api_id\":\"1\"}', '2020-04-02 11:50:25'),
('36388c1f171a53738221c6d000', '{\"api_id\":\"1\"}', '2020-04-01 01:17:43'),
('368c1d7385220f113714e404ee', '{\"api_id\":\"1\"}', '2020-04-02 17:27:24'),
('372f63970ef9562960282296d2', '{\"language\":\"uk-ua\",\"currency\":\"UAH\"}', '2020-04-01 12:11:25'),
('37abaf9acecd7bb4519e8932bc', '{\"api_id\":\"1\"}', '2020-04-01 00:19:28'),
('37ef4a386aa3beae00d7968d22', '{\"api_id\":\"1\",\"language\":\"uk-ua\",\"currency\":\"UAH\"}', '2020-04-01 00:18:05'),
('388947b6b9476fc62770d7bcca', '{\"api_id\":\"1\"}', '2020-04-01 00:04:45'),
('3b45b28f6c2f577545bd3e4b6f', '{\"language\":\"uk-ua\",\"currency\":\"UAH\",\"user_id\":\"2\",\"user_token\":\"fNXptw6g3ZnU9tyCtTTn8Bo7pGNKpOoA\"}', '2020-04-02 12:00:03'),
('3d7c11fb047b22262a29be8d5c', '{\"api_id\":\"1\"}', '2020-04-01 00:24:20'),
('3dfad1cae15b78c483de1e7728', '{\"api_id\":\"1\"}', '2020-04-01 00:17:10'),
('3f1d35c93d1aceb9c6eafe2deb', '{\"api_id\":\"1\"}', '2020-04-01 00:37:58'),
('3f25f2119a0a944a3f237a0014', '{\"api_id\":\"1\"}', '2020-04-01 00:28:19'),
('40b24c28200ef74d7522618495', '{\"api_id\":\"1\",\"language\":\"uk-ua\",\"currency\":\"UAH\"}', '2020-04-02 19:01:55'),
('4274b8fc0226d81cabd71d0368', '{\"api_id\":\"1\"}', '2020-04-02 11:50:02'),
('460cbd9d569390330db9cc1ece', '{\"api_id\":\"1\"}', '2020-03-31 18:50:20'),
('46c3c6c11137810b17dfb9cc61', '{\"api_id\":\"1\",\"language\":\"uk-ua\",\"currency\":\"UAH\"}', '2020-04-17 12:27:40'),
('4c817239cd6f2c0728ab5f9427', '{\"language\":\"uk-ua\",\"currency\":\"UAH\"}', '2020-04-01 12:07:44'),
('50e1ac768e3f4b7db0d061ebef', '{\"api_id\":\"1\",\"language\":\"uk-ua\",\"currency\":\"UAH\"}', '2020-03-31 19:33:36'),
('561d66004a82c5b531bdc6682e', '{\"api_id\":\"1\"}', '2020-04-01 00:56:43'),
('56b01c5c122d6e1705186a60f8', '{\"language\":\"uk-ua\",\"currency\":\"UAH\"}', '2020-04-01 14:01:40'),
('56e680bf56239dc98b3aab348d', '{\"api_id\":\"1\"}', '2020-04-02 11:42:41'),
('5aee8570284e8223c54f53c762', '{\"api_id\":\"1\"}', '2020-04-02 11:47:33'),
('5e181c59169db262adf4831201', '{\"language\":\"uk-ua\",\"currency\":\"UAH\"}', '2020-04-01 12:07:31'),
('5e38978b341cf282e9c5abdb99', '{\"api_id\":\"1\"}', '2020-04-02 11:42:40'),
('5f66cae72b1e076249551e06e2', '{\"api_id\":\"1\"}', '2020-04-01 00:18:07'),
('60218c26fcdc0db2bcfb642664', '{\"api_id\":\"1\"}', '2020-04-01 00:43:28'),
('603a717c4ef5e85931bf3664a2', '{\"api_id\":\"1\",\"language\":\"uk-ua\",\"currency\":\"UAH\"}', '2020-03-31 19:49:07'),
('63629af446107a4e806922ae17', '{\"api_id\":\"1\"}', '2020-03-31 20:04:07'),
('6412e1adf77fd898f18943e7ad', '{\"api_id\":\"1\"}', '2020-04-02 11:43:31'),
('6552301a7bcf9ecc32d445d120', '{\"api_id\":\"1\"}', '2020-04-02 11:56:40'),
('6654b72e68cdd16fec2ed97189', '{\"api_id\":\"1\"}', '2020-03-31 19:49:31'),
('6728724649f0b738bd595e93ef', '{\"api_id\":\"1\"}', '2020-03-31 23:55:28'),
('6781e5e836546c06c79bd49f88', '{\"api_id\":\"1\",\"language\":\"uk-ua\",\"currency\":\"UAH\"}', '2020-04-02 17:27:24'),
('6941e1f6c1d2fe315343269ac3', '{\"api_id\":\"1\",\"language\":\"uk-ua\",\"currency\":\"UAH\"}', '2020-04-01 01:15:23'),
('6d0a75a255e083a25a4200d322', '{\"api_id\":\"1\"}', '2020-04-01 01:10:46'),
('6d3a7037b0452214f91d3b2d58', '{\"api_id\":\"1\",\"language\":\"uk-ua\",\"currency\":\"UAH\"}', '2020-04-01 01:13:24'),
('6dd5565f5315eaa2c616ccbc43', '{\"api_id\":\"1\"}', '2020-04-02 11:40:02'),
('6e5b6529327bd32a14064fccb4', '{\"api_id\":\"1\",\"language\":\"uk-ua\",\"currency\":\"UAH\"}', '2020-04-01 01:10:52'),
('6ef8c310a59eed4c62e3688ffa', '{\"api_id\":\"1\"}', '2020-04-02 11:58:28'),
('6fbf9f3d211a200a93dc6422b8', '{\"api_id\":\"1\"}', '2020-04-02 11:47:30'),
('72fc8170bb9af9fb38c1927583', '{\"api_id\":\"1\"}', '2020-04-01 00:17:32'),
('7310b144aa04b1dde17107ec18', '{\"api_id\":\"1\"}', '2020-04-02 11:50:15'),
('7376fbdc72166b9405a0a890b7', '{\"api_id\":\"1\"}', '2020-03-31 23:52:05'),
('7915037d02e952facd0f58e64d', '{\"api_id\":\"1\"}', '2020-04-01 01:16:16'),
('7b106113c4d7967ec04cf64226', '{\"api_id\":\"1\"}', '2020-04-02 11:52:47'),
('7c3a41079eb7d27796c5af0db6', '{\"api_id\":\"1\"}', '2020-03-31 19:49:03'),
('7cae38d43880a9288a4a001ab3', '{\"api_id\":\"1\"}', '2020-03-31 23:43:46'),
('7f202a0e10debd12731ccffaa1', '{\"api_id\":\"1\"}', '2020-04-01 01:14:39'),
('7fdbc7a712fba415d41feeb708', '{\"api_id\":\"1\"}', '2020-03-31 20:04:26'),
('80052c915b9198b7cc434a419d', '{\"api_id\":\"1\"}', '2020-03-31 19:47:53'),
('80429fe205ce07942e929209d8', '{\"language\":\"uk-ua\",\"currency\":\"UAH\"}', '2020-04-01 13:49:37'),
('805385873b15394ef98634e98f', '{\"api_id\":\"1\"}', '2020-04-02 11:52:30'),
('80824d8255277d0a1647d8d792', '{\"language\":\"uk-ua\",\"currency\":\"UAH\"}', '2020-03-31 23:11:23'),
('82255786a615ea6097c0f75dc6', '{\"api_id\":\"1\"}', '2020-04-01 00:33:31'),
('82ade7df89571b04b7ba44ea1f', '{\"api_id\":\"1\"}', '2020-03-31 18:50:36'),
('83dcebd9e67fee7e674582bd78', '{\"language\":\"uk-ua\",\"currency\":\"UAH\",\"user_id\":\"1\",\"user_token\":\"7g6AbgAlqoVuDAgUx6h6d5uDiVQ096vt\"}', '2020-04-01 15:26:20'),
('83f03fb2485cbb8af712c847bc', '{\"api_id\":\"1\"}', '2020-03-31 18:50:31'),
('849a05298a520a4e99dc9f5c65', '{\"api_id\":\"1\",\"language\":\"uk-ua\",\"currency\":\"UAH\"}', '2020-04-01 01:14:38'),
('862289a4f79ba40dfc79440d22', '{\"api_id\":\"1\"}', '2020-03-31 23:43:56'),
('887fb9de701e9d5bb7354c0a2e', '{\"api_id\":\"1\",\"language\":\"uk-ua\",\"currency\":\"UAH\"}', '2020-04-02 19:01:40'),
('89d8baf1fc5abb134e619ff28f', '{\"api_id\":\"1\"}', '2020-04-01 01:16:18'),
('8a0c8d2dafc834c85644976427', '{\"api_id\":\"1\"}', '2020-03-31 19:33:49'),
('8abad5724bdbe6f94d47ae78ab', '{\"api_id\":\"1\"}', '2020-04-01 00:12:33'),
('8b6b89ca83b4fcf2bd0bb957e8', '{\"api_id\":\"1\",\"language\":\"uk-ua\",\"currency\":\"UAH\"}', '2020-04-01 01:17:41'),
('8d0e9ed73c36e604a5541c69a8', '{\"api_id\":\"1\"}', '2020-04-01 00:59:08'),
('90b3ecbdf29c0e8171101da659', '{\"api_id\":\"1\"}', '2020-04-01 00:38:08'),
('91f44497e288a79c57912c49bf', '{\"api_id\":\"1\",\"language\":\"uk-ua\",\"currency\":\"UAH\"}', '2020-04-01 01:13:48'),
('9237c8b857c821a71033df9250', '{\"api_id\":\"1\",\"language\":\"uk-ua\",\"currency\":\"UAH\"}', '2020-04-02 19:02:03'),
('938f5434c8590fd3cf275a60f0', '{\"api_id\":\"1\"}', '2020-04-02 11:44:52'),
('96d94fdfacc59f3f99f4c3d648', '{\"api_id\":\"1\"}', '2020-04-02 11:56:23'),
('97104d31cadaa698a22f8851da', '{\"api_id\":\"1\"}', '2020-03-30 10:54:13'),
('974a69b97d7642a1057d2f1244', '{\"api_id\":\"1\",\"language\":\"uk-ua\",\"currency\":\"UAH\"}', '2020-04-01 00:17:58'),
('98d43173ac85d55315f8926857', '{\"api_id\":\"1\"}', '2020-04-01 01:10:37'),
('9a284efc6d446ab70e8f178371', '{\"api_id\":\"1\"}', '2020-04-01 00:59:51'),
('9a9f6517fcfcc028f916a1cc3b', '{\"api_id\":\"1\"}', '2020-04-01 00:05:29'),
('9c9eb50e96ded813a90c3463d9', '{\"api_id\":\"1\"}', '2020-04-02 10:35:54'),
('9ccdcfaf73a40ec2e026556b50', '{\"api_id\":\"1\",\"language\":\"uk-ua\",\"currency\":\"UAH\"}', '2020-04-02 19:01:49'),
('9e3cd2a73f37d42e0abbb544b0', '{\"api_id\":\"1\",\"language\":\"uk-ua\",\"currency\":\"UAH\"}', '2020-04-02 19:02:00'),
('9e4d5b6c8406cbdde9d9f2fd29', '{\"api_id\":\"1\"}', '2020-04-01 01:17:02'),
('9f0f2e292b433352c25b400b37', '{\"api_id\":\"1\"}', '2020-04-01 00:24:19'),
('a09c1f8f628666518388af88f2', '{\"api_id\":\"1\"}', '2020-03-31 19:33:45'),
('a2fd1b2788f990049dc0fbe423', '{\"api_id\":\"1\"}', '2020-04-02 11:39:43'),
('a34edc6c6c5edbfa769b19abdd', '{\"api_id\":\"1\"}', '2020-04-01 00:59:54'),
('a3b855c7c23593d39da6d6a3a2', '{\"api_id\":\"1\"}', '2020-04-01 01:15:34'),
('a6aa2c0f5b6bc9b821fb6e2e72', '{\"api_id\":\"1\"}', '2020-04-01 00:10:43'),
('a71c768812f90d3118dee2acf4', '{\"api_id\":\"1\",\"language\":\"uk-ua\",\"currency\":\"UAH\"}', '2020-03-31 19:33:41'),
('a7ee281d42fefd1d5ecc526a22', '{\"api_id\":\"1\"}', '2020-04-02 11:50:16'),
('ad7079ae87a788fedf654b4ebd', '{\"api_id\":\"1\"}', '2020-04-02 11:50:26'),
('ad8c25e607c688c5ef86f7fec2', '{\"api_id\":\"1\",\"language\":\"uk-ua\",\"currency\":\"UAH\"}', '2020-04-02 19:01:34'),
('aedec3075496410c75be28f452', '{\"api_id\":\"1\"}', '2020-04-01 00:24:23'),
('aef8e61c233cf5eff575564b92', '{\"api_id\":\"1\"}', '2020-04-01 00:00:11'),
('b288165e93296430d975dfb055', '{\"api_id\":\"1\"}', '2020-04-01 01:12:07'),
('b438e20485f383332f67c9557e', '{\"api_id\":\"1\"}', '2020-04-01 00:04:10'),
('b492b90d529bf161b3d036c143', '{\"api_id\":\"1\"}', '2020-04-02 11:44:51'),
('b5a63c60856d1bd451c5c18915', '{\"api_id\":\"1\"}', '2020-04-01 01:14:31'),
('b607533844a309e47e99067320', '{\"api_id\":\"1\"}', '2020-04-02 11:45:01'),
('b6f259e97d34b1ef0a03cba89a', '{\"api_id\":\"1\"}', '2020-03-31 19:49:01'),
('b8e615fc37d1d3cceeecc9f2fb', '{\"api_id\":\"1\"}', '2020-04-01 00:05:43'),
('b90634a8bed38a8d7849dfcb99', '{\"language\":\"uk-ua\",\"currency\":\"UAH\"}', '2020-04-01 12:03:58'),
('b9497790554b6c48427c3ae331', '{\"api_id\":\"1\",\"language\":\"uk-ua\",\"currency\":\"UAH\"}', '2020-04-02 11:56:33'),
('bd96ae59ec9c602a48c138ba11', '{\"api_id\":\"1\"}', '2020-04-17 12:27:40'),
('be0de81c5fc675767dfbe2938f', '{\"api_id\":\"1\",\"language\":\"uk-ua\",\"currency\":\"UAH\"}', '2020-04-01 01:10:35'),
('bea152472738832d8ca78634d3', '{\"api_id\":\"1\"}', '2020-04-01 00:56:46'),
('c25e271a2c9174c7357fd1ffc9', '{\"api_id\":\"1\"}', '2020-04-02 11:39:47'),
('c283665bd9ec4fd3d39d32c7dc', '{\"api_id\":\"1\"}', '2020-04-01 01:11:57'),
('c29421374136cceca09c99e5cc', '{\"api_id\":\"1\"}', '2020-03-30 10:54:17'),
('c2ffec083472bf3f3eedf05c8c', '{\"api_id\":\"1\"}', '2020-03-31 19:33:43'),
('c3aa68955512b08e98d072bad5', '{\"api_id\":\"1\"}', '2020-04-02 11:43:32'),
('c3f1a60c596d8f25a350c567ac', '{\"api_id\":\"1\",\"language\":\"uk-ua\",\"currency\":\"UAH\"}', '2020-04-02 19:01:57'),
('c46f983ffad18f289eea5c8f8b', '{\"api_id\":\"1\"}', '2020-04-02 11:42:49'),
('c7e770fc7ed65f79d52e7d6ccb', '{\"api_id\":\"1\"}', '2020-04-01 01:17:16'),
('c7fb3eae5316d7e8b14d631db9', '{\"api_id\":\"1\",\"language\":\"uk-ua\",\"currency\":\"UAH\"}', '2020-04-02 19:01:31'),
('c8ad2810aaa7a4a786a5353266', '{\"api_id\":\"1\"}', '2020-03-31 19:49:29'),
('ca02a47c7dd709439c8308d29d', '{\"api_id\":\"1\",\"language\":\"uk-ua\",\"currency\":\"UAH\"}', '2020-04-02 17:27:19'),
('cf021400fbc62ad35f641f935c', '{\"api_id\":\"1\",\"language\":\"uk-ua\",\"currency\":\"UAH\"}', '2020-04-02 19:01:52'),
('d3070099368b09c5f5e87783e1', '{\"api_id\":\"1\",\"language\":\"uk-ua\",\"currency\":\"UAH\"}', '2020-03-31 22:07:47'),
('d6c70fb209e7d263ddde6019bb', '{\"api_id\":\"1\"}', '2020-03-31 19:47:27'),
('d6cd04a303c12cbf5a71d665cf', '{\"api_id\":\"1\"}', '2020-04-01 00:28:15'),
('da5d0dd22a7a771d0d750e3d3c', '{\"api_id\":\"1\"}', '2020-03-31 18:50:16'),
('df24da231e67046df139441bf6', '{\"api_id\":\"1\"}', '2020-04-01 00:38:04'),
('e0a86b0f4de44e9591e49303e7', '{\"api_id\":\"1\"}', '2020-04-01 00:04:20'),
('e0fe3a08d3cf0f350f636a3fbd', '{\"language\":\"uk-ua\",\"currency\":\"UAH\"}', '2020-04-01 13:56:54'),
('e36672e8bebf63033d9f2a691e', '{\"api_id\":\"1\"}', '2020-04-02 11:55:55'),
('e45a19842d9d28a97041434d37', '{\"api_id\":\"1\",\"language\":\"uk-ua\",\"currency\":\"UAH\"}', '2020-04-02 17:27:21'),
('e5e3372e169f5716a2c00fddd1', '{\"api_id\":\"1\"}', '2020-04-02 11:56:47'),
('e683c4bf46585dec3974006ecb', '{\"api_id\":\"1\"}', '2020-03-31 19:49:09'),
('e6d4aeb86e121faa871ce2bb52', '{\"api_id\":\"1\",\"language\":\"uk-ua\",\"currency\":\"UAH\"}', '2020-04-01 01:13:20'),
('e745a15804a349599ccab8b255', '{\"api_id\":\"1\"}', '2020-03-31 22:07:49'),
('e74f54ea8abf4504606d4e2398', '{\"api_id\":\"1\"}', '2020-03-31 19:02:45'),
('ea98bf355226cf15c5117f8525', '{\"api_id\":\"1\",\"language\":\"uk-ua\",\"currency\":\"UAH\"}', '2020-04-01 00:10:06'),
('ec3785f8edf3d3347098cc0aff', '{\"api_id\":\"1\"}', '2020-04-02 11:56:35'),
('ef5ee7124d4b24f08888e98ecb', '{\"api_id\":\"1\"}', '2020-04-02 11:52:10'),
('f009225ef475ec77de92ffd5f5', '{\"api_id\":\"1\"}', '2020-04-02 11:51:05'),
('f018ffb678c6546e5c217f6fb5', '{\"language\":\"uk-ua\",\"currency\":\"UAH\"}', '2020-04-01 14:07:02'),
('f11da36140fe39cf1b24be6dad', '{\"api_id\":\"1\"}', '2020-04-01 00:55:53'),
('f2908dc75cb13b7ee23029bf1a', '{\"api_id\":\"1\",\"language\":\"uk-ua\",\"currency\":\"UAH\"}', '2020-04-02 19:01:46'),
('f4ebc07c8885bfcb38ca1184e8', '{\"api_id\":\"1\"}', '2020-03-31 19:34:03'),
('f7ed6d995eb25986c298168bae', '{\"api_id\":\"1\",\"language\":\"uk-ua\",\"currency\":\"UAH\"}', '2020-04-01 01:14:32'),
('fc42b37c34a5f66b8f9afb95e0', '{\"api_id\":\"1\"}', '2020-04-02 11:56:00'),
('fe29d0581c017f29092a130dc5', '{\"api_id\":\"1\"}', '2020-03-31 23:55:37'),
('fead7015d418e3cfa25f604b1c', '{\"api_id\":\"1\",\"language\":\"uk-ua\",\"currency\":\"UAH\"}', '2020-03-31 19:33:31'),
('ff151b75391065c0bdf2fa7c06', '{\"api_id\":\"1\"}', '2020-04-02 11:44:02'),
('ffbd7750eab734ff568f9b32d9', '{\"api_id\":\"1\"}', '2020-04-01 01:15:25');

-- --------------------------------------------------------

--
-- Структура таблицы `oc_setting`
--

CREATE TABLE `oc_setting` (
  `setting_id` int(11) NOT NULL,
  `store_id` int(11) NOT NULL DEFAULT 0,
  `code` varchar(128) NOT NULL,
  `key` varchar(128) NOT NULL,
  `value` text NOT NULL,
  `serialized` tinyint(1) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_setting`
--

INSERT INTO `oc_setting` (`setting_id`, `store_id`, `code`, `key`, `value`, `serialized`) VALUES
(1418, 0, 'config', 'config_file_max_size', '300000', 0),
(1419, 0, 'config', 'config_file_ext_allowed', 'zip\r\ntxt\r\npng\r\njpe\r\njpeg\r\njpg\r\ngif\r\nbmp\r\nico\r\ntiff\r\ntif\r\nsvg\r\nsvgz\r\nzip\r\nrar\r\nmsi\r\ncab\r\nmp3\r\nqt\r\nmov\r\npdf\r\npsd\r\nai\r\neps\r\nps\r\ndoc', 0),
(596, 0, 'module_category', 'module_category_status', '1', 0),
(4, 0, 'total_voucher', 'total_voucher_sort_order', '8', 0),
(5, 0, 'total_voucher', 'total_voucher_status', '1', 0),
(1414, 0, 'config', 'config_compression', '0', 0),
(1415, 0, 'config', 'config_password', '0', 0),
(1416, 0, 'config', 'config_shared', '0', 0),
(1417, 0, 'config', 'config_encryption', '631VpCGRXlybKonAtxIoZnNb7gfvmK6rwGotmnDzIUXhRbMVhcLGEcTeUQZwFYzDjt6bi2gUqIVktMHhypUK7kk0Itg8hNNwGjZJyNlzIi2rnDIJaFxKKGOvFxP0iIphQb8dBMKTxB1sbgbFwQ41Pnis8oIKTsrjPwtmwphUtOXbpSuI0zG7z24jH34r5yVWZR4IapO8Iw64b3z5Sswa8eEKDBevuYDZM02QEKxTF8Fh7LDVqTaEkbzYAbE9FEtvK7i6iCCKgwv6S9Y5nPXEvtOCFnDVMVhrVuFBgM2N4u7K5kRNrK5nBQlS1phxBpQ9AXKDsCqCxai2UuXXYJAmV4UrP0DYS6iqKIusGqwfMmX4vcNACSPQ5LIO7O9HdQBCGozYr1NpFLTYDpKC6PqNFwefHpuF7ImpsDTJnr8soTi1r67JjZ570Uss9ilGArTqR1FdR3XCtzeeXGxw1vONosIukxlITCni0MqMWWdi8XinEyNhIj7QEJFZlUZZeX7CgL0yggrHi5YmdqqoUIHT10PExmIGDk29B3sC3dCBN9m9E4RaiuFDnQmYHZDiVgbf9QWRXLsAIu4EKN72q4Nzb0zxyvsPKRMc4ueGxz4K79jJhnWzJuJq7bQLe70KWTWB1fsIMOjfqRVYxB47cVoKRyZsO27HNyQN94M2CmCyYZvgAs4fcDdOTIaMeZp98O4hkfhRqHHkxs33TmPyHOJKXQUvMfS6dEyQuMSyBDtTr5FExSCDgLRT9UgTxdjp3nFT8JWgTBM8FEnMv86fgG7yn0ZAjZ4pEdDCnEj4aJ6r9G8cn38HAhMeo2fCDp7GxE1KP5W3Vr6aQPpEUMfqGq6gFRGPf3OL8wbmQK0T38dw7HhMG1UFZs2riIQDsW4on70vusHOQnBtoQYyvkPb8axtIZQoMUdiIRkWuXEEVmz591BYQoh5wxim9XWjdYWfr4nwYIRnLUB6JtKrd6dEFNI3OF453s9At7JURcIB2whCNGmsC3M30Qh53P2ntwBSqS75', 0),
(1413, 0, 'config', 'config_robots', 'abot\r\ndbot\r\nebot\r\nhbot\r\nkbot\r\nlbot\r\nmbot\r\nnbot\r\nobot\r\npbot\r\nrbot\r\nsbot\r\ntbot\r\nvbot\r\nybot\r\nzbot\r\nbot.\r\nbot/\r\n_bot\r\n.bot\r\n/bot\r\n-bot\r\n:bot\r\n(bot\r\ncrawl\r\nslurp\r\nspider\r\nseek\r\naccoona\r\nacoon\r\nadressendeutschland\r\nah-ha.com\r\nahoy\r\naltavista\r\nananzi\r\nanthill\r\nappie\r\narachnophilia\r\narale\r\naraneo\r\naranha\r\narchitext\r\naretha\r\narks\r\nasterias\r\natlocal\r\natn\r\natomz\r\naugurfind\r\nbackrub\r\nbannana_bot\r\nbaypup\r\nbdfetch\r\nbig brother\r\nbiglotron\r\nbjaaland\r\nblackwidow\r\nblaiz\r\nblog\r\nblo.\r\nbloodhound\r\nboitho\r\nbooch\r\nbradley\r\nbutterfly\r\ncalif\r\ncassandra\r\nccubee\r\ncfetch\r\ncharlotte\r\nchurl\r\ncienciaficcion\r\ncmc\r\ncollective\r\ncomagent\r\ncombine\r\ncomputingsite\r\ncsci\r\ncurl\r\ncusco\r\ndaumoa\r\ndeepindex\r\ndelorie\r\ndepspid\r\ndeweb\r\ndie blinde kuh\r\ndigger\r\nditto\r\ndmoz\r\ndocomo\r\ndownload express\r\ndtaagent\r\ndwcp\r\nebiness\r\nebingbong\r\ne-collector\r\nejupiter\r\nemacs-w3 search engine\r\nesther\r\nevliya celebi\r\nezresult\r\nfalcon\r\nfelix ide\r\nferret\r\nfetchrover\r\nfido\r\nfindlinks\r\nfireball\r\nfish search\r\nfouineur\r\nfunnelweb\r\ngazz\r\ngcreep\r\ngenieknows\r\ngetterroboplus\r\ngeturl\r\nglx\r\ngoforit\r\ngolem\r\ngrabber\r\ngrapnel\r\ngralon\r\ngriffon\r\ngromit\r\ngrub\r\ngulliver\r\nhamahakki\r\nharvest\r\nhavindex\r\nhelix\r\nheritrix\r\nhku www octopus\r\nhomerweb\r\nhtdig\r\nhtml index\r\nhtml_analyzer\r\nhtmlgobble\r\nhubater\r\nhyper-decontextualizer\r\nia_archiver\r\nibm_planetwide\r\nichiro\r\niconsurf\r\niltrovatore\r\nimage.kapsi.net\r\nimagelock\r\nincywincy\r\nindexer\r\ninfobee\r\ninformant\r\ningrid\r\ninktomisearch.com\r\ninspector web\r\nintelliagent\r\ninternet shinchakubin\r\nip3000\r\niron33\r\nisraeli-search\r\nivia\r\njack\r\njakarta\r\njavabee\r\njetbot\r\njumpstation\r\nkatipo\r\nkdd-explorer\r\nkilroy\r\nknowledge\r\nkototoi\r\nkretrieve\r\nlabelgrabber\r\nlachesis\r\nlarbin\r\nlegs\r\nlibwww\r\nlinkalarm\r\nlink validator\r\nlinkscan\r\nlockon\r\nlwp\r\nlycos\r\nmagpie\r\nmantraagent\r\nmapoftheinternet\r\nmarvin/\r\nmattie\r\nmediafox\r\nmediapartners\r\nmercator\r\nmerzscope\r\nmicrosoft url control\r\nminirank\r\nmiva\r\nmj12\r\nmnogosearch\r\nmoget\r\nmonster\r\nmoose\r\nmotor\r\nmultitext\r\nmuncher\r\nmuscatferret\r\nmwd.search\r\nmyweb\r\nnajdi\r\nnameprotect\r\nnationaldirectory\r\nnazilla\r\nncsa beta\r\nnec-meshexplorer\r\nnederland.zoek\r\nnetcarta webmap engine\r\nnetmechanic\r\nnetresearchserver\r\nnetscoop\r\nnewscan-online\r\nnhse\r\nnokia6682/\r\nnomad\r\nnoyona\r\nnutch\r\nnzexplorer\r\nobjectssearch\r\noccam\r\nomni\r\nopen text\r\nopenfind\r\nopenintelligencedata\r\norb search\r\nosis-project\r\npack rat\r\npageboy\r\npagebull\r\npage_verifier\r\npanscient\r\nparasite\r\npartnersite\r\npatric\r\npear.\r\npegasus\r\nperegrinator\r\npgp key agent\r\nphantom\r\nphpdig\r\npicosearch\r\npiltdownman\r\npimptrain\r\npinpoint\r\npioneer\r\npiranha\r\nplumtreewebaccessor\r\npogodak\r\npoirot\r\npompos\r\npoppelsdorf\r\npoppi\r\npopular iconoclast\r\npsycheclone\r\npublisher\r\npython\r\nrambler\r\nraven search\r\nroach\r\nroad runner\r\nroadhouse\r\nrobbie\r\nrobofox\r\nrobozilla\r\nrules\r\nsalty\r\nsbider\r\nscooter\r\nscoutjet\r\nscrubby\r\nsearch.\r\nsearchprocess\r\nsemanticdiscovery\r\nsenrigan\r\nsg-scout\r\nshai\'hulud\r\nshark\r\nshopwiki\r\nsidewinder\r\nsift\r\nsilk\r\nsimmany\r\nsite searcher\r\nsite valet\r\nsitetech-rover\r\nskymob.com\r\nsleek\r\nsmartwit\r\nsna-\r\nsnappy\r\nsnooper\r\nsohu\r\nspeedfind\r\nsphere\r\nsphider\r\nspinner\r\nspyder\r\nsteeler/\r\nsuke\r\nsuntek\r\nsupersnooper\r\nsurfnomore\r\nsven\r\nsygol\r\nszukacz\r\ntach black widow\r\ntarantula\r\ntempleton\r\n/teoma\r\nt-h-u-n-d-e-r-s-t-o-n-e\r\ntheophrastus\r\ntitan\r\ntitin\r\ntkwww\r\ntoutatis\r\nt-rex\r\ntutorgig\r\ntwiceler\r\ntwisted\r\nucsd\r\nudmsearch\r\nurl check\r\nupdated\r\nvagabondo\r\nvalkyrie\r\nverticrawl\r\nvictoria\r\nvision-search\r\nvolcano\r\nvoyager/\r\nvoyager-hc\r\nw3c_validator\r\nw3m2\r\nw3mir\r\nwalker\r\nwallpaper\r\nwanderer\r\nwauuu\r\nwavefire\r\nweb core\r\nweb hopper\r\nweb wombat\r\nwebbandit\r\nwebcatcher\r\nwebcopy\r\nwebfoot\r\nweblayers\r\nweblinker\r\nweblog monitor\r\nwebmirror\r\nwebmonkey\r\nwebquest\r\nwebreaper\r\nwebsitepulse\r\nwebsnarf\r\nwebstolperer\r\nwebvac\r\nwebwalk\r\nwebwatch\r\nwebwombat\r\nwebzinger\r\nwhizbang\r\nwhowhere\r\nwild ferret\r\nworldlight\r\nwwwc\r\nwwwster\r\nxenu\r\nxget\r\nxift\r\nxirq\r\nyandex\r\nyanga\r\nyeti\r\nyodao\r\nzao\r\nzippp\r\nzyborg', 0),
(1412, 0, 'config', 'config_maintenance', '0', 0),
(1402, 0, 'config', 'config_mail_parameter', '', 0),
(1410, 0, 'config', 'config_seo_url', '1', 0),
(1411, 0, 'config', 'config_secure', '0', 0),
(1409, 0, 'config', 'config_mail_alert_email', '', 0),
(1408, 0, 'config', 'config_mail_alert', '[\"order\"]', 1),
(1407, 0, 'config', 'config_mail_smtp_timeout', '5', 0),
(1406, 0, 'config', 'config_mail_smtp_port', '25', 0),
(1405, 0, 'config', 'config_mail_smtp_password', '', 0),
(1404, 0, 'config', 'config_mail_smtp_username', '', 0),
(1403, 0, 'config', 'config_mail_smtp_hostname', '', 0),
(1401, 0, 'config', 'config_mail_engine', 'mail', 0),
(1400, 0, 'config', 'config_icon', 'catalog/demodata/favicon.png', 0),
(1399, 0, 'config', 'config_logo', 'catalog/demodata/logo.png', 0),
(1398, 0, 'config', 'config_captcha_page', '[\"review\",\"return\",\"contact\"]', 1),
(1397, 0, 'config', 'config_captcha', '', 0),
(1396, 0, 'config', 'config_return_status_id', '2', 0),
(1395, 0, 'config', 'config_return_id', '0', 0),
(1394, 0, 'config', 'config_affiliate_id', '4', 0),
(1393, 0, 'config', 'config_affiliate_commission', '5', 0),
(1392, 0, 'config', 'config_affiliate_auto', '0', 0),
(1391, 0, 'config', 'config_affiliate_approval', '0', 0),
(1390, 0, 'config', 'config_affiliate_group_id', '1', 0),
(95, 0, 'payment_free_checkout', 'payment_free_checkout_status', '1', 0),
(96, 0, 'payment_free_checkout', 'free_checkout_order_status_id', '1', 0),
(97, 0, 'payment_free_checkout', 'payment_free_checkout_sort_order', '1', 0),
(98, 0, 'payment_cod', 'payment_cod_sort_order', '5', 0),
(99, 0, 'payment_cod', 'payment_cod_total', '0.01', 0),
(100, 0, 'payment_cod', 'payment_cod_order_status_id', '1', 0),
(101, 0, 'payment_cod', 'payment_cod_geo_zone_id', '0', 0),
(102, 0, 'payment_cod', 'payment_cod_status', '1', 0),
(103, 0, 'shipping_flat', 'shipping_flat_sort_order', '1', 0),
(104, 0, 'shipping_flat', 'shipping_flat_status', '1', 0),
(105, 0, 'shipping_flat', 'shipping_flat_geo_zone_id', '0', 0),
(106, 0, 'shipping_flat', 'shipping_flat_tax_class_id', '9', 0),
(107, 0, 'shipping_flat', 'shipping_flat_cost', '5.00', 0),
(108, 0, 'total_shipping', 'total_shipping_sort_order', '3', 0),
(109, 0, 'total_sub_total', 'sub_total_sort_order', '1', 0),
(110, 0, 'total_sub_total', 'total_sub_total_status', '1', 0),
(111, 0, 'total_tax', 'total_tax_status', '0', 0),
(112, 0, 'total_total', 'total_total_sort_order', '9', 0),
(113, 0, 'total_total', 'total_total_status', '1', 0),
(114, 0, 'total_tax', 'total_tax_sort_order', '5', 0),
(115, 0, 'total_credit', 'total_credit_sort_order', '7', 0),
(116, 0, 'total_credit', 'total_credit_status', '1', 0),
(117, 0, 'total_reward', 'total_reward_sort_order', '2', 0),
(118, 0, 'total_reward', 'total_reward_status', '1', 0),
(119, 0, 'total_shipping', 'total_shipping_status', '1', 0),
(120, 0, 'total_shipping', 'total_shipping_estimator', '1', 0),
(121, 0, 'total_coupon', 'total_coupon_sort_order', '4', 0),
(122, 0, 'total_coupon', 'total_coupon_status', '1', 0),
(805, 0, 'theme_default', 'theme_default_image_location_width', '268', 0),
(806, 0, 'theme_default', 'theme_default_image_location_height', '50', 0),
(804, 0, 'theme_default', 'theme_default_image_cart_height', '80', 0),
(801, 0, 'theme_default', 'theme_default_image_wishlist_width', '80', 0),
(802, 0, 'theme_default', 'theme_default_image_wishlist_height', '80', 0),
(803, 0, 'theme_default', 'theme_default_image_cart_width', '80', 0),
(800, 0, 'theme_default', 'theme_default_image_compare_height', '90', 0),
(799, 0, 'theme_default', 'theme_default_image_compare_width', '90', 0),
(798, 0, 'theme_default', 'theme_default_image_related_height', '200', 0),
(797, 0, 'theme_default', 'theme_default_image_related_width', '200', 0),
(795, 0, 'theme_default', 'theme_default_image_additional_width', '74', 0),
(796, 0, 'theme_default', 'theme_default_image_additional_height', '74', 0),
(794, 0, 'theme_default', 'theme_default_image_product_height', '300', 0),
(793, 0, 'theme_default', 'theme_default_image_product_width', '480', 0),
(792, 0, 'theme_default', 'theme_default_image_popup_height', '625', 0),
(791, 0, 'theme_default', 'theme_default_image_popup_width', '1000', 0),
(786, 0, 'theme_default', 'theme_default_product_description_length', '100', 0),
(787, 0, 'theme_default', 'theme_default_image_category_width', '80', 0),
(788, 0, 'theme_default', 'theme_default_image_category_height', '80', 0),
(1153, 0, 'dashboard_activity', 'dashboard_activity_sort_order', '7', 0),
(1152, 0, 'dashboard_activity', 'dashboard_activity_status', '0', 0),
(151, 0, 'dashboard_sale', 'dashboard_sale_status', '1', 0),
(152, 0, 'dashboard_sale', 'dashboard_sale_width', '3', 0),
(1187, 0, 'dashboard_chart', 'dashboard_chart_width', '6', 0),
(1188, 0, 'dashboard_chart', 'dashboard_chart_status', '1', 0),
(1159, 0, 'dashboard_customer', 'dashboard_customer_sort_order', '3', 0),
(1158, 0, 'dashboard_customer', 'dashboard_customer_status', '0', 0),
(1162, 0, 'dashboard_map', 'dashboard_map_sort_order', '5', 0),
(1161, 0, 'dashboard_map', 'dashboard_map_status', '0', 0),
(1165, 0, 'dashboard_online', 'dashboard_online_sort_order', '4', 0),
(1164, 0, 'dashboard_online', 'dashboard_online_status', '0', 0),
(1186, 0, 'dashboard_order', 'dashboard_order_sort_order', '1', 0),
(1185, 0, 'dashboard_order', 'dashboard_order_status', '1', 0),
(1184, 0, 'dashboard_order', 'dashboard_order_width', '3', 0),
(164, 0, 'dashboard_sale', 'dashboard_sale_sort_order', '2', 0),
(1157, 0, 'dashboard_customer', 'dashboard_customer_width', '3', 0),
(1163, 0, 'dashboard_online', 'dashboard_online_width', '3', 0),
(1160, 0, 'dashboard_map', 'dashboard_map_width', '6', 0),
(1193, 0, 'dashboard_recent', 'dashboard_recent_width', '12', 0),
(1194, 0, 'dashboard_recent', 'dashboard_recent_status', '1', 0),
(1151, 0, 'dashboard_activity', 'dashboard_activity_width', '4', 0),
(173, 0, 'report_customer_activity', 'report_customer_activity_status', '1', 0),
(174, 0, 'report_customer_activity', 'report_customer_activity_sort_order', '1', 0),
(175, 0, 'report_customer_order', 'report_customer_order_status', '1', 0),
(176, 0, 'report_customer_order', 'report_customer_order_sort_order', '2', 0),
(177, 0, 'report_customer_reward', 'report_customer_reward_status', '1', 0),
(178, 0, 'report_customer_reward', 'report_customer_reward_sort_order', '3', 0),
(179, 0, 'report_customer_search', 'report_customer_search_sort_order', '3', 0),
(180, 0, 'report_customer_search', 'report_customer_search_status', '1', 0),
(181, 0, 'report_customer_transaction', 'report_customer_transaction_status', '1', 0),
(182, 0, 'report_customer_transaction', 'report_customer_transaction_status_sort_order', '4', 0),
(183, 0, 'report_sale_tax', 'report_sale_tax_status', '1', 0),
(184, 0, 'report_sale_tax', 'report_sale_tax_sort_order', '5', 0),
(185, 0, 'report_sale_shipping', 'report_sale_shipping_status', '1', 0),
(186, 0, 'report_sale_shipping', 'report_sale_shipping_sort_order', '6', 0),
(187, 0, 'report_sale_return', 'report_sale_return_status', '1', 0),
(188, 0, 'report_sale_return', 'report_sale_return_sort_order', '7', 0),
(189, 0, 'report_sale_order', 'report_sale_order_status', '1', 0),
(190, 0, 'report_sale_order', 'report_sale_order_sort_order', '8', 0),
(191, 0, 'report_sale_coupon', 'report_sale_coupon_status', '1', 0),
(192, 0, 'report_sale_coupon', 'report_sale_coupon_sort_order', '9', 0),
(193, 0, 'report_product_viewed', 'report_product_viewed_status', '1', 0),
(194, 0, 'report_product_viewed', 'report_product_viewed_sort_order', '10', 0),
(195, 0, 'report_product_purchased', 'report_product_purchased_status', '1', 0),
(196, 0, 'report_product_purchased', 'report_product_purchased_sort_order', '11', 0),
(197, 0, 'report_marketing', 'report_marketing_status', '1', 0),
(198, 0, 'report_marketing', 'report_marketing_sort_order', '12', 0),
(1337, 0, 'developer', 'developer_sass', '1', 0),
(1389, 0, 'config', 'config_stock_checkout', '0', 0),
(1388, 0, 'config', 'config_stock_warning', '0', 0),
(1387, 0, 'config', 'config_stock_display', '0', 0),
(1386, 0, 'config', 'config_api_id', '1', 0),
(1385, 0, 'config', 'config_fraud_status_id', '16', 0),
(1384, 0, 'config', 'config_complete_status', '[\"3\",\"5\"]', 1),
(1383, 0, 'config', 'config_processing_status', '[\"2\",\"3\",\"1\",\"12\",\"5\"]', 1),
(1381, 0, 'config', 'config_checkout_id', '5', 0),
(1382, 0, 'config', 'config_order_status_id', '1', 0),
(1380, 0, 'config', 'config_checkout_guest', '1', 0),
(1379, 0, 'config', 'config_cart_weight', '1', 0),
(1378, 0, 'config', 'config_invoice_prefix', 'INV-2020-00', 0),
(1377, 0, 'config', 'config_account_id', '3', 0),
(1376, 0, 'config', 'config_login_attempts', '5', 0),
(1375, 0, 'config', 'config_customer_price', '0', 0),
(1374, 0, 'config', 'config_customer_group_display', '[\"1\"]', 1),
(1373, 0, 'config', 'config_customer_group_id', '1', 0),
(1372, 0, 'config', 'config_customer_search', '0', 0),
(1371, 0, 'config', 'config_customer_activity', '0', 0),
(1370, 0, 'config', 'config_customer_online', '0', 0),
(1369, 0, 'config', 'config_tax_customer', 'shipping', 0),
(1368, 0, 'config', 'config_tax_default', 'shipping', 0),
(1367, 0, 'config', 'config_tax', '0', 0),
(1366, 0, 'config', 'config_voucher_max', '1000', 0),
(1364, 0, 'config', 'config_review_guest', '1', 0),
(1365, 0, 'config', 'config_voucher_min', '1', 0),
(1363, 0, 'config', 'config_review_status', '1', 0),
(1361, 0, 'config', 'config_product_count', '0', 0),
(1362, 0, 'config', 'config_limit_admin', '20', 0),
(1360, 0, 'config', 'config_weight_class_id', '1', 0),
(1357, 0, 'config', 'config_currency', 'UAH', 0),
(1358, 0, 'config', 'config_currency_auto', '1', 0),
(1359, 0, 'config', 'config_length_class_id', '1', 0),
(1356, 0, 'config', 'config_admin_language', 'uk-ua', 0),
(1355, 0, 'config', 'config_language', 'uk-ua', 0),
(1354, 0, 'config', 'config_zone_id', '', 0),
(1353, 0, 'config', 'config_country_id', '220', 0),
(1352, 0, 'config', 'config_comment', '', 0),
(1336, 0, 'developer', 'developer_theme', '1', 0),
(790, 0, 'theme_default', 'theme_default_image_thumb_height', '280', 0),
(789, 0, 'theme_default', 'theme_default_image_thumb_width', '450', 0),
(785, 0, 'theme_default', 'theme_default_product_limit', '100', 0),
(784, 0, 'theme_default', 'theme_default_status', '1', 0),
(783, 0, 'theme_default', 'theme_default_directory', 'sauco', 0),
(1340, 0, 'config', 'config_meta_keyword', '', 0),
(1341, 0, 'config', 'config_theme', 'default', 0),
(1342, 0, 'config', 'config_layout_id', '4', 0),
(1343, 0, 'config', 'config_name', 'Название магазина', 0),
(1344, 0, 'config', 'config_owner', 'Иванов Иван', 0),
(1345, 0, 'config', 'config_address', 'Адрес магазина', 0),
(1346, 0, 'config', 'config_geocode', '', 0),
(1347, 0, 'config', 'config_email', 'admin@admin.admin', 0),
(1348, 0, 'config', 'config_telephone', '495 888-88-88\r\n495 888-88-88\r\n495 888-88-89\r\n495 888-88-88', 0),
(1349, 0, 'config', 'config_fax', '', 0),
(1350, 0, 'config', 'config_image', 'catalog/demodata/logo.png', 0),
(1351, 0, 'config', 'config_open', 'Пн - Сб: c 09:00 до 18:00 Вс.: с 09:00 до 15:00', 0),
(1189, 0, 'dashboard_chart', 'dashboard_chart_sort_order', '6', 0),
(1195, 0, 'dashboard_recent', 'dashboard_recent_sort_order', '0', 0),
(1339, 0, 'config', 'config_meta_description', 'Доставка їжі в Києві досить поширена і вже звично послуга, яку здійснюють багато ресторанів або служби доставки.\r\n\r\nДоставка їжі додому – зручний і комфортний спосіб організації легкого перекусу або ситного обіду, смачного сніданку або романтичної вечері.\r\n\r\nЗручна і комфортна послуга «Доставка їжі додому від MAFIA» – чудове рішення для сучасних, мобільних людей, які цінують свій час, а також поважають оригінальну і смачну їжу.\r\n\r\nУ нашому меню ви можете знайти різноманітні, яскраві і улюблені багатьма страви японської або італійської кухні: суші, роли, піцу, пасту, лазанью і багато іншого.\r\n\r\nЇжа додому від MAFIA прикрасить, як звичайний буденний день, так і чудовий святковий вечір. Адже ми доставляємо не просто їжу, ми доставляємо емоції!\r\n\r\nЗалиште довгі години готування на кухні! Насолоджуйтесь життям! А MAFIA подбає, щоб це було зроблено зі смаком!', 0),
(1338, 0, 'config', 'config_meta_title', 'Название магазина', 0),
(1420, 0, 'config', 'config_file_mime_allowed', 'text/plain\r\nimage/png\r\nimage/jpeg\r\nimage/gif\r\nimage/bmp\r\nimage/tiff\r\nimage/svg+xml\r\napplication/zip\r\n&quot;application/zip&quot;\r\napplication/x-zip\r\n&quot;application/x-zip&quot;\r\napplication/x-zip-compressed\r\n&quot;application/x-zip-compressed&quot;\r\napplication/rar\r\n&quot;application/rar&quot;\r\napplication/x-rar\r\n&quot;application/x-rar&quot;\r\napplication/x-rar-compressed\r\n&quot;application/x-rar-compressed&quot;\r\napplication/octet-stream\r\n&quot;application/octet-stream&quot;\r\naudio/mpeg\r\nvideo/quicktime\r\napplication/pdf', 0),
(1421, 0, 'config', 'config_error_display', '0', 0),
(1422, 0, 'config', 'config_error_log', '1', 0),
(1423, 0, 'config', 'config_error_filename', 'error.log', 0);

-- --------------------------------------------------------

--
-- Структура таблицы `oc_shipping_courier`
--

CREATE TABLE `oc_shipping_courier` (
  `shipping_courier_id` int(11) NOT NULL,
  `shipping_courier_code` varchar(255) NOT NULL DEFAULT '',
  `shipping_courier_name` varchar(255) NOT NULL DEFAULT ''
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_shipping_courier`
--

INSERT INTO `oc_shipping_courier` (`shipping_courier_id`, `shipping_courier_code`, `shipping_courier_name`) VALUES
(1, 'dhl', 'DHL'),
(2, 'fedex', 'Fedex'),
(3, 'ups', 'UPS'),
(4, 'royal-mail', 'Royal Mail'),
(5, 'usps', 'United States Postal Service'),
(6, 'auspost', 'Australia Post');

-- --------------------------------------------------------

--
-- Структура таблицы `oc_statistics`
--

CREATE TABLE `oc_statistics` (
  `statistics_id` int(11) NOT NULL,
  `code` varchar(64) NOT NULL,
  `value` decimal(15,4) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_statistics`
--

INSERT INTO `oc_statistics` (`statistics_id`, `code`, `value`) VALUES
(1, 'order_sale', '640.0000'),
(2, 'order_processing', '0.0000'),
(3, 'order_complete', '0.0000'),
(4, 'order_other', '0.0000'),
(5, 'returns', '0.0000'),
(6, 'product', '0.0000'),
(7, 'review', '0.0000');

-- --------------------------------------------------------

--
-- Структура таблицы `oc_stock_status`
--

CREATE TABLE `oc_stock_status` (
  `stock_status_id` int(11) NOT NULL,
  `language_id` int(11) NOT NULL,
  `name` varchar(32) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_stock_status`
--

INSERT INTO `oc_stock_status` (`stock_status_id`, `language_id`, `name`) VALUES
(7, 1, 'В наличии'),
(8, 1, 'Предзаказ'),
(5, 1, 'Нет в наличии'),
(6, 1, 'Ожидание 2-3 дня'),
(7, 2, 'В наличии'),
(8, 2, 'Предзаказ'),
(5, 2, 'Нет в наличии'),
(6, 2, 'Ожидание 2-3 дня');

-- --------------------------------------------------------

--
-- Структура таблицы `oc_store`
--

CREATE TABLE `oc_store` (
  `store_id` int(11) NOT NULL,
  `name` varchar(64) NOT NULL,
  `url` varchar(255) NOT NULL,
  `ssl` varchar(255) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `oc_tax_class`
--

CREATE TABLE `oc_tax_class` (
  `tax_class_id` int(11) NOT NULL,
  `title` varchar(32) NOT NULL,
  `description` varchar(255) NOT NULL,
  `date_added` datetime NOT NULL,
  `date_modified` datetime NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `oc_tax_rate`
--

CREATE TABLE `oc_tax_rate` (
  `tax_rate_id` int(11) NOT NULL,
  `geo_zone_id` int(11) NOT NULL DEFAULT 0,
  `name` varchar(32) NOT NULL,
  `rate` decimal(15,4) NOT NULL DEFAULT 0.0000,
  `type` char(1) NOT NULL,
  `date_added` datetime NOT NULL,
  `date_modified` datetime NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_tax_rate`
--

INSERT INTO `oc_tax_rate` (`tax_rate_id`, `geo_zone_id`, `name`, `rate`, `type`, `date_added`, `date_modified`) VALUES
(87, 3, 'НДС', '18.0000', 'F', '2018-09-21 21:49:23', '2018-09-09 11:49:32');

-- --------------------------------------------------------

--
-- Структура таблицы `oc_tax_rate_to_customer_group`
--

CREATE TABLE `oc_tax_rate_to_customer_group` (
  `tax_rate_id` int(11) NOT NULL,
  `customer_group_id` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_tax_rate_to_customer_group`
--

INSERT INTO `oc_tax_rate_to_customer_group` (`tax_rate_id`, `customer_group_id`) VALUES
(86, 1),
(87, 1);

-- --------------------------------------------------------

--
-- Структура таблицы `oc_tax_rule`
--

CREATE TABLE `oc_tax_rule` (
  `tax_rule_id` int(11) NOT NULL,
  `tax_class_id` int(11) NOT NULL,
  `tax_rate_id` int(11) NOT NULL,
  `based` varchar(10) NOT NULL,
  `priority` int(5) NOT NULL DEFAULT 1
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_tax_rule`
--

INSERT INTO `oc_tax_rule` (`tax_rule_id`, `tax_class_id`, `tax_rate_id`, `based`, `priority`) VALUES
(121, 10, 86, 'payment', 1),
(120, 10, 87, 'store', 0);

-- --------------------------------------------------------

--
-- Структура таблицы `oc_theme`
--

CREATE TABLE `oc_theme` (
  `theme_id` int(11) NOT NULL,
  `store_id` int(11) NOT NULL,
  `theme` varchar(64) NOT NULL,
  `route` varchar(64) NOT NULL,
  `code` mediumtext NOT NULL,
  `date_added` datetime NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `oc_translation`
--

CREATE TABLE `oc_translation` (
  `translation_id` int(11) NOT NULL,
  `store_id` int(11) NOT NULL,
  `language_id` int(11) NOT NULL,
  `route` varchar(64) NOT NULL,
  `key` varchar(64) NOT NULL,
  `value` text NOT NULL,
  `date_added` datetime NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `oc_upload`
--

CREATE TABLE `oc_upload` (
  `upload_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `filename` varchar(255) NOT NULL,
  `code` varchar(255) NOT NULL,
  `date_added` datetime NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `oc_user`
--

CREATE TABLE `oc_user` (
  `user_id` int(11) NOT NULL,
  `user_group_id` int(11) NOT NULL,
  `username` varchar(20) NOT NULL,
  `password` varchar(40) NOT NULL,
  `salt` varchar(9) NOT NULL,
  `firstname` varchar(32) NOT NULL,
  `lastname` varchar(32) NOT NULL,
  `email` varchar(96) NOT NULL,
  `image` varchar(255) NOT NULL,
  `code` varchar(40) NOT NULL,
  `ip` varchar(40) NOT NULL,
  `status` tinyint(1) NOT NULL,
  `date_added` datetime NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_user`
--

INSERT INTO `oc_user` (`user_id`, `user_group_id`, `username`, `password`, `salt`, `firstname`, `lastname`, `email`, `image`, `code`, `ip`, `status`, `date_added`) VALUES
(1, 1, 'admin', 'd1dc08a002753496fb70bf04855adbcc5ae88070', '5uHzi1QCd', 'John', 'Doe', 'admin@admin.admin', '', '', '127.0.0.1', 1, '2020-03-30 11:09:10');

-- --------------------------------------------------------

--
-- Структура таблицы `oc_user_group`
--

CREATE TABLE `oc_user_group` (
  `user_group_id` int(11) NOT NULL,
  `name` varchar(64) NOT NULL,
  `permission` text NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_user_group`
--

INSERT INTO `oc_user_group` (`user_group_id`, `name`, `permission`) VALUES
(1, 'Administrator', '{\"access\":[\"catalog\\/attribute\",\"catalog\\/attribute_group\",\"catalog\\/category\",\"catalog\\/download\",\"catalog\\/filter\",\"catalog\\/information\",\"catalog\\/manufacturer\",\"catalog\\/option\",\"catalog\\/product\",\"catalog\\/recurring\",\"catalog\\/review\",\"common\\/column_left\",\"common\\/developer\",\"common\\/filemanager\",\"common\\/profile\",\"common\\/security\",\"customer\\/custom_field\",\"customer\\/customer\",\"customer\\/customer_approval\",\"customer\\/customer_group\",\"design\\/banner\",\"design\\/layout\",\"design\\/theme\",\"design\\/translation\",\"design\\/seo_url\",\"event\\/statistics\",\"event\\/theme\",\"extension\\/advertise\\/google\",\"extension\\/analytics\\/google\",\"extension\\/captcha\\/basic\",\"extension\\/captcha\\/google\",\"extension\\/dashboard\\/activity\",\"extension\\/dashboard\\/chart\",\"extension\\/dashboard\\/customer\",\"extension\\/dashboard\\/map\",\"extension\\/dashboard\\/online\",\"extension\\/dashboard\\/order\",\"extension\\/dashboard\\/recent\",\"extension\\/dashboard\\/sale\",\"extension\\/extension\\/advertise\",\"extension\\/extension\\/analytics\",\"extension\\/extension\\/captcha\",\"extension\\/extension\\/dashboard\",\"extension\\/extension\\/feed\",\"extension\\/extension\\/fraud\",\"extension\\/extension\\/menu\",\"extension\\/extension\\/module\",\"extension\\/extension\\/payment\",\"extension\\/extension\\/report\",\"extension\\/extension\\/shipping\",\"extension\\/extension\\/theme\",\"extension\\/extension\\/total\",\"extension\\/feed\\/google_base\",\"extension\\/feed\\/google_sitemap\",\"extension\\/feed\\/openbaypro\",\"extension\\/fraud\\/fraudlabspro\",\"extension\\/fraud\\/ip\",\"extension\\/fraud\\/maxmind\",\"extension\\/marketing\\/remarketing\",\"extension\\/module\\/account\",\"extension\\/module\\/amazon_login\",\"extension\\/module\\/amazon_pay\",\"extension\\/module\\/banner\",\"extension\\/module\\/bestseller\",\"extension\\/module\\/carousel\",\"extension\\/module\\/category\",\"extension\\/module\\/divido_calculator\",\"extension\\/module\\/ebay_listing\",\"extension\\/module\\/featured\",\"extension\\/module\\/filter\",\"extension\\/module\\/google_hangouts\",\"extension\\/module\\/html\",\"extension\\/module\\/information\",\"extension\\/module\\/klarna_checkout_module\",\"extension\\/module\\/latest\",\"extension\\/module\\/laybuy_layout\",\"extension\\/module\\/pilibaba_button\",\"extension\\/module\\/pp_button\",\"extension\\/module\\/pp_login\",\"extension\\/module\\/sagepay_direct_cards\",\"extension\\/module\\/sagepay_server_cards\",\"extension\\/module\\/slideshow\",\"extension\\/module\\/special\",\"extension\\/module\\/store\",\"extension\\/openbay\\/amazon\",\"extension\\/openbay\\/amazon_listing\",\"extension\\/openbay\\/amazon_product\",\"extension\\/openbay\\/amazonus\",\"extension\\/openbay\\/amazonus_listing\",\"extension\\/openbay\\/amazonus_product\",\"extension\\/openbay\\/ebay\",\"extension\\/openbay\\/ebay_profile\",\"extension\\/openbay\\/ebay_template\",\"extension\\/openbay\\/etsy\",\"extension\\/openbay\\/etsy_product\",\"extension\\/openbay\\/etsy_shipping\",\"extension\\/openbay\\/etsy_shop\",\"extension\\/openbay\\/fba\",\"extension\\/payment\\/amazon_login_pay\",\"extension\\/payment\\/authorizenet_aim\",\"extension\\/payment\\/authorizenet_sim\",\"extension\\/payment\\/bank_transfer\",\"extension\\/payment\\/bluepay_hosted\",\"extension\\/payment\\/bluepay_redirect\",\"extension\\/payment\\/cardconnect\",\"extension\\/payment\\/cardinity\",\"extension\\/payment\\/cheque\",\"extension\\/payment\\/cod\",\"extension\\/payment\\/divido\",\"extension\\/payment\\/eway\",\"extension\\/payment\\/firstdata\",\"extension\\/payment\\/firstdata_remote\",\"extension\\/payment\\/free_checkout\",\"extension\\/payment\\/g2apay\",\"extension\\/payment\\/globalpay\",\"extension\\/payment\\/globalpay_remote\",\"extension\\/payment\\/klarna_account\",\"extension\\/payment\\/klarna_checkout\",\"extension\\/payment\\/klarna_invoice\",\"extension\\/payment\\/laybuy\",\"extension\\/payment\\/liqpay\",\"extension\\/payment\\/nochex\",\"extension\\/payment\\/paymate\",\"extension\\/payment\\/paypoint\",\"extension\\/payment\\/payza\",\"extension\\/payment\\/perpetual_payments\",\"extension\\/payment\\/pilibaba\",\"extension\\/payment\\/pp_express\",\"extension\\/payment\\/pp_payflow\",\"extension\\/payment\\/pp_payflow_iframe\",\"extension\\/payment\\/pp_pro\",\"extension\\/payment\\/pp_pro_iframe\",\"extension\\/payment\\/pp_standard\",\"extension\\/payment\\/realex\",\"extension\\/payment\\/realex_remote\",\"extension\\/payment\\/sagepay_direct\",\"extension\\/payment\\/sagepay_server\",\"extension\\/payment\\/sagepay_us\",\"extension\\/payment\\/securetrading_pp\",\"extension\\/payment\\/securetrading_ws\",\"extension\\/payment\\/skrill\",\"extension\\/payment\\/twocheckout\",\"extension\\/payment\\/web_payment_software\",\"extension\\/payment\\/worldpay\",\"extension\\/module\\/pp_braintree_button\",\"extension\\/payment\\/pp_braintree\",\"extension\\/report\\/customer_activity\",\"extension\\/report\\/customer_order\",\"extension\\/report\\/customer_reward\",\"extension\\/report\\/customer_search\",\"extension\\/report\\/customer_transaction\",\"extension\\/report\\/marketing\",\"extension\\/report\\/product_purchased\",\"extension\\/report\\/product_viewed\",\"extension\\/report\\/sale_coupon\",\"extension\\/report\\/sale_order\",\"extension\\/report\\/sale_return\",\"extension\\/report\\/sale_shipping\",\"extension\\/report\\/sale_tax\",\"extension\\/shipping\\/auspost\",\"extension\\/shipping\\/ec_ship\",\"extension\\/shipping\\/fedex\",\"extension\\/shipping\\/flat\",\"extension\\/shipping\\/free\",\"extension\\/shipping\\/item\",\"extension\\/shipping\\/parcelforce_48\",\"extension\\/shipping\\/pickup\",\"extension\\/shipping\\/royal_mail\",\"extension\\/shipping\\/ups\",\"extension\\/shipping\\/usps\",\"extension\\/shipping\\/weight\",\"extension\\/theme\\/default\",\"extension\\/total\\/coupon\",\"extension\\/total\\/credit\",\"extension\\/total\\/handling\",\"extension\\/total\\/klarna_fee\",\"extension\\/total\\/low_order_fee\",\"extension\\/total\\/reward\",\"extension\\/total\\/shipping\",\"extension\\/total\\/sub_total\",\"extension\\/total\\/tax\",\"extension\\/total\\/total\",\"extension\\/total\\/voucher\",\"localisation\\/country\",\"localisation\\/currency\",\"localisation\\/geo_zone\",\"localisation\\/language\",\"localisation\\/length_class\",\"localisation\\/location\",\"localisation\\/order_status\",\"localisation\\/return_action\",\"localisation\\/return_reason\",\"localisation\\/return_status\",\"localisation\\/stock_status\",\"localisation\\/tax_class\",\"localisation\\/tax_rate\",\"localisation\\/weight_class\",\"localisation\\/zone\",\"mail\\/affiliate\",\"mail\\/customer\",\"mail\\/forgotten\",\"mail\\/return\",\"mail\\/reward\",\"mail\\/transaction\",\"marketing\\/contact\",\"marketing\\/coupon\",\"marketing\\/marketing\",\"marketplace\\/api\",\"marketplace\\/event\",\"marketplace\\/extension\",\"marketplace\\/install\",\"marketplace\\/installer\",\"marketplace\\/marketplace\",\"marketplace\\/modification\",\"marketplace\\/openbay\",\"report\\/online\",\"report\\/report\",\"report\\/statistics\",\"sale\\/order\",\"sale\\/recurring\",\"sale\\/return\",\"sale\\/voucher\",\"sale\\/voucher_theme\",\"setting\\/setting\",\"setting\\/store\",\"startup\\/error\",\"startup\\/event\",\"startup\\/login\",\"startup\\/permission\",\"startup\\/router\",\"startup\\/sass\",\"startup\\/startup\",\"tool\\/backup\",\"tool\\/log\",\"tool\\/upload\",\"user\\/api\",\"user\\/user\",\"user\\/user_permission\",\"extension\\/module\\/html\",\"extension\\/module\\/banner\",\"extension\\/module\\/carousel\",\"extension\\/module\\/category\",\"extension\\/module\\/featured\",\"extension\\/module\\/slideshow\",\"extension\\/module\\/sms_alert\"],\"modify\":[\"catalog\\/attribute\",\"catalog\\/attribute_group\",\"catalog\\/category\",\"catalog\\/download\",\"catalog\\/filter\",\"catalog\\/information\",\"catalog\\/manufacturer\",\"catalog\\/option\",\"catalog\\/product\",\"catalog\\/recurring\",\"catalog\\/review\",\"common\\/column_left\",\"common\\/developer\",\"common\\/filemanager\",\"common\\/profile\",\"common\\/security\",\"customer\\/custom_field\",\"customer\\/customer\",\"customer\\/customer_approval\",\"customer\\/customer_group\",\"design\\/banner\",\"design\\/layout\",\"design\\/theme\",\"design\\/translation\",\"design\\/seo_url\",\"event\\/statistics\",\"event\\/theme\",\"extension\\/advertise\\/google\",\"extension\\/analytics\\/google\",\"extension\\/captcha\\/basic\",\"extension\\/captcha\\/google\",\"extension\\/dashboard\\/activity\",\"extension\\/dashboard\\/chart\",\"extension\\/dashboard\\/customer\",\"extension\\/dashboard\\/map\",\"extension\\/dashboard\\/online\",\"extension\\/dashboard\\/order\",\"extension\\/dashboard\\/recent\",\"extension\\/dashboard\\/sale\",\"extension\\/extension\\/advertise\",\"extension\\/extension\\/analytics\",\"extension\\/extension\\/captcha\",\"extension\\/extension\\/dashboard\",\"extension\\/extension\\/feed\",\"extension\\/extension\\/fraud\",\"extension\\/extension\\/menu\",\"extension\\/extension\\/module\",\"extension\\/extension\\/payment\",\"extension\\/extension\\/report\",\"extension\\/extension\\/shipping\",\"extension\\/extension\\/theme\",\"extension\\/extension\\/total\",\"extension\\/feed\\/google_base\",\"extension\\/feed\\/google_sitemap\",\"extension\\/feed\\/openbaypro\",\"extension\\/fraud\\/fraudlabspro\",\"extension\\/fraud\\/ip\",\"extension\\/fraud\\/maxmind\",\"extension\\/marketing\\/remarketing\",\"extension\\/module\\/account\",\"extension\\/module\\/amazon_login\",\"extension\\/module\\/amazon_pay\",\"extension\\/module\\/banner\",\"extension\\/module\\/bestseller\",\"extension\\/module\\/carousel\",\"extension\\/module\\/category\",\"extension\\/module\\/divido_calculator\",\"extension\\/module\\/ebay_listing\",\"extension\\/module\\/featured\",\"extension\\/module\\/filter\",\"extension\\/module\\/google_hangouts\",\"extension\\/module\\/html\",\"extension\\/module\\/information\",\"extension\\/module\\/klarna_checkout_module\",\"extension\\/module\\/latest\",\"extension\\/module\\/laybuy_layout\",\"extension\\/module\\/pilibaba_button\",\"extension\\/module\\/pp_button\",\"extension\\/module\\/pp_login\",\"extension\\/module\\/sagepay_direct_cards\",\"extension\\/module\\/sagepay_server_cards\",\"extension\\/module\\/slideshow\",\"extension\\/module\\/special\",\"extension\\/module\\/store\",\"extension\\/openbay\\/amazon\",\"extension\\/openbay\\/amazon_listing\",\"extension\\/openbay\\/amazon_product\",\"extension\\/openbay\\/amazonus\",\"extension\\/openbay\\/amazonus_listing\",\"extension\\/openbay\\/amazonus_product\",\"extension\\/openbay\\/ebay\",\"extension\\/openbay\\/ebay_profile\",\"extension\\/openbay\\/ebay_template\",\"extension\\/openbay\\/etsy\",\"extension\\/openbay\\/etsy_product\",\"extension\\/openbay\\/etsy_shipping\",\"extension\\/openbay\\/etsy_shop\",\"extension\\/openbay\\/fba\",\"extension\\/payment\\/amazon_login_pay\",\"extension\\/payment\\/authorizenet_aim\",\"extension\\/payment\\/authorizenet_sim\",\"extension\\/payment\\/bank_transfer\",\"extension\\/payment\\/bluepay_hosted\",\"extension\\/payment\\/bluepay_redirect\",\"extension\\/payment\\/cardconnect\",\"extension\\/payment\\/cardinity\",\"extension\\/payment\\/cheque\",\"extension\\/payment\\/cod\",\"extension\\/payment\\/divido\",\"extension\\/payment\\/eway\",\"extension\\/payment\\/firstdata\",\"extension\\/payment\\/firstdata_remote\",\"extension\\/payment\\/free_checkout\",\"extension\\/payment\\/g2apay\",\"extension\\/payment\\/globalpay\",\"extension\\/payment\\/globalpay_remote\",\"extension\\/payment\\/klarna_account\",\"extension\\/payment\\/klarna_checkout\",\"extension\\/payment\\/klarna_invoice\",\"extension\\/payment\\/laybuy\",\"extension\\/payment\\/liqpay\",\"extension\\/payment\\/nochex\",\"extension\\/payment\\/paymate\",\"extension\\/payment\\/paypoint\",\"extension\\/payment\\/payza\",\"extension\\/payment\\/perpetual_payments\",\"extension\\/payment\\/pilibaba\",\"extension\\/payment\\/pp_express\",\"extension\\/payment\\/pp_payflow\",\"extension\\/payment\\/pp_payflow_iframe\",\"extension\\/payment\\/pp_pro\",\"extension\\/payment\\/pp_pro_iframe\",\"extension\\/payment\\/pp_standard\",\"extension\\/payment\\/realex\",\"extension\\/payment\\/realex_remote\",\"extension\\/payment\\/sagepay_direct\",\"extension\\/payment\\/sagepay_server\",\"extension\\/payment\\/sagepay_us\",\"extension\\/payment\\/securetrading_pp\",\"extension\\/payment\\/securetrading_ws\",\"extension\\/payment\\/skrill\",\"extension\\/payment\\/twocheckout\",\"extension\\/payment\\/web_payment_software\",\"extension\\/payment\\/worldpay\",\"extension\\/module\\/pp_braintree_button\",\"extension\\/payment\\/pp_braintree\",\"extension\\/report\\/customer_activity\",\"extension\\/report\\/customer_order\",\"extension\\/report\\/customer_reward\",\"extension\\/report\\/customer_search\",\"extension\\/report\\/customer_transaction\",\"extension\\/report\\/marketing\",\"extension\\/report\\/product_purchased\",\"extension\\/report\\/product_viewed\",\"extension\\/report\\/sale_coupon\",\"extension\\/report\\/sale_order\",\"extension\\/report\\/sale_return\",\"extension\\/report\\/sale_shipping\",\"extension\\/report\\/sale_tax\",\"extension\\/shipping\\/auspost\",\"extension\\/shipping\\/ec_ship\",\"extension\\/shipping\\/fedex\",\"extension\\/shipping\\/flat\",\"extension\\/shipping\\/free\",\"extension\\/shipping\\/item\",\"extension\\/shipping\\/parcelforce_48\",\"extension\\/shipping\\/pickup\",\"extension\\/shipping\\/royal_mail\",\"extension\\/shipping\\/ups\",\"extension\\/shipping\\/usps\",\"extension\\/shipping\\/weight\",\"extension\\/theme\\/default\",\"extension\\/total\\/coupon\",\"extension\\/total\\/credit\",\"extension\\/total\\/handling\",\"extension\\/total\\/klarna_fee\",\"extension\\/total\\/low_order_fee\",\"extension\\/total\\/reward\",\"extension\\/total\\/shipping\",\"extension\\/total\\/sub_total\",\"extension\\/total\\/tax\",\"extension\\/total\\/total\",\"extension\\/total\\/voucher\",\"localisation\\/country\",\"localisation\\/currency\",\"localisation\\/geo_zone\",\"localisation\\/language\",\"localisation\\/length_class\",\"localisation\\/location\",\"localisation\\/order_status\",\"localisation\\/return_action\",\"localisation\\/return_reason\",\"localisation\\/return_status\",\"localisation\\/stock_status\",\"localisation\\/tax_class\",\"localisation\\/tax_rate\",\"localisation\\/weight_class\",\"localisation\\/zone\",\"mail\\/affiliate\",\"mail\\/customer\",\"mail\\/forgotten\",\"mail\\/return\",\"mail\\/reward\",\"mail\\/transaction\",\"marketing\\/contact\",\"marketing\\/coupon\",\"marketing\\/marketing\",\"marketplace\\/event\",\"marketplace\\/api\",\"marketplace\\/extension\",\"marketplace\\/install\",\"marketplace\\/installer\",\"marketplace\\/marketplace\",\"marketplace\\/modification\",\"marketplace\\/openbay\",\"report\\/online\",\"report\\/report\",\"report\\/statistics\",\"sale\\/order\",\"sale\\/recurring\",\"sale\\/return\",\"sale\\/voucher\",\"sale\\/voucher_theme\",\"setting\\/setting\",\"setting\\/store\",\"startup\\/error\",\"startup\\/event\",\"startup\\/login\",\"startup\\/permission\",\"startup\\/router\",\"startup\\/sass\",\"startup\\/startup\",\"tool\\/backup\",\"tool\\/log\",\"tool\\/upload\",\"user\\/api\",\"user\\/user\",\"user\\/user_permission\",\"extension\\/module\\/html\",\"extension\\/module\\/banner\",\"extension\\/module\\/carousel\",\"extension\\/module\\/category\",\"extension\\/module\\/featured\",\"extension\\/module\\/slideshow\",\"extension\\/module\\/sms_alert\"]}'),
(10, 'Demonstration', '{\"access\":[\"catalog\\/attribute\",\"catalog\\/attribute_group\",\"catalog\\/category\",\"catalog\\/download\",\"catalog\\/filter\",\"catalog\\/information\",\"catalog\\/manufacturer\",\"catalog\\/option\",\"catalog\\/product\",\"catalog\\/recurring\",\"catalog\\/review\",\"common\\/column_left\",\"common\\/developer\",\"common\\/filemanager\",\"common\\/profile\",\"common\\/security\",\"customer\\/custom_field\",\"customer\\/customer\",\"customer\\/customer_approval\",\"customer\\/customer_group\",\"design\\/banner\",\"design\\/layout\",\"design\\/seo_url\",\"design\\/theme\",\"design\\/translation\",\"event\\/language\",\"event\\/statistics\",\"event\\/theme\",\"extension\\/_module\\/_google_hangouts\",\"extension\\/_module\\/_pp_button\",\"extension\\/_module\\/_sms_alert\",\"extension\\/_module\\/account\",\"extension\\/_module\\/bestseller\",\"extension\\/_module\\/carousel\",\"extension\\/_module\\/filter\",\"extension\\/_module\\/html\",\"extension\\/_module\\/information\",\"extension\\/_module\\/latest\",\"extension\\/_module\\/slideshow\",\"extension\\/_module\\/special\",\"extension\\/_module\\/store\",\"extension\\/advertise\\/google\",\"extension\\/analytics\\/google\",\"extension\\/captcha\\/basic\",\"extension\\/captcha\\/google\",\"extension\\/dashboard\\/activity\",\"extension\\/dashboard\\/chart\",\"extension\\/dashboard\\/customer\",\"extension\\/dashboard\\/map\",\"extension\\/dashboard\\/online\",\"extension\\/dashboard\\/order\",\"extension\\/dashboard\\/recent\",\"extension\\/dashboard\\/sale\",\"extension\\/extension\\/_advertise\",\"extension\\/extension\\/_captcha\",\"extension\\/extension\\/_dashboard\",\"extension\\/extension\\/_fraud\",\"extension\\/extension\\/_menu\",\"extension\\/extension\\/_payment\",\"extension\\/extension\\/_report\",\"extension\\/extension\\/_shipping\",\"extension\\/extension\\/_total\",\"extension\\/extension\\/analytics\",\"extension\\/extension\\/feed\",\"extension\\/extension\\/module\",\"extension\\/extension\\/promotion\",\"extension\\/extension\\/theme\",\"extension\\/feed\\/google_base\",\"extension\\/feed\\/google_sitemap\",\"extension\\/fraud\\/ip\",\"extension\\/module\\/banner\",\"extension\\/module\\/category\",\"extension\\/module\\/featured\",\"extension\\/payment\\/bank_transfer\",\"extension\\/payment\\/cheque\",\"extension\\/payment\\/cod\",\"extension\\/payment\\/free_checkout\",\"extension\\/payment\\/liqpay\",\"extension\\/payment\\/pp_express\",\"extension\\/payment\\/pp_pro\",\"extension\\/payment\\/pp_standard\",\"extension\\/report\\/customer_activity\",\"extension\\/report\\/customer_order\",\"extension\\/report\\/customer_reward\",\"extension\\/report\\/customer_search\",\"extension\\/report\\/customer_transaction\",\"extension\\/report\\/marketing\",\"extension\\/report\\/product_purchased\",\"extension\\/report\\/product_viewed\",\"extension\\/report\\/sale_coupon\",\"extension\\/report\\/sale_order\",\"extension\\/report\\/sale_return\",\"extension\\/report\\/sale_shipping\",\"extension\\/report\\/sale_tax\",\"extension\\/shipping\\/flat\",\"extension\\/shipping\\/free\",\"extension\\/shipping\\/item\",\"extension\\/shipping\\/pickup\",\"extension\\/shipping\\/weight\",\"extension\\/theme\\/default\",\"extension\\/total\\/coupon\",\"extension\\/total\\/credit\",\"extension\\/total\\/handling\",\"extension\\/total\\/low_order_fee\",\"extension\\/total\\/reward\",\"extension\\/total\\/shipping\",\"extension\\/total\\/sub_total\",\"extension\\/total\\/tax\",\"extension\\/total\\/total\",\"extension\\/total\\/voucher\",\"localisation\\/country\",\"localisation\\/currency\",\"localisation\\/geo_zone\",\"localisation\\/language\",\"localisation\\/length_class\",\"localisation\\/location\",\"localisation\\/order_status\",\"localisation\\/return_action\",\"localisation\\/return_reason\",\"localisation\\/return_status\",\"localisation\\/stock_status\",\"localisation\\/tax_class\",\"localisation\\/tax_rate\",\"localisation\\/weight_class\",\"localisation\\/zone\",\"mail\\/affiliate\",\"mail\\/customer\",\"mail\\/forgotten\",\"mail\\/return\",\"mail\\/reward\",\"mail\\/transaction\",\"marketing\\/contact\",\"marketing\\/coupon\",\"marketing\\/marketing\",\"marketplace\\/api\",\"marketplace\\/event\",\"marketplace\\/extension\",\"marketplace\\/install\",\"marketplace\\/installer\",\"marketplace\\/marketplace\",\"report\\/online\",\"report\\/report\",\"report\\/statistics\",\"sale\\/order\",\"sale\\/recurring\",\"sale\\/return\",\"sale\\/voucher\",\"sale\\/voucher_theme\",\"setting\\/setting\",\"setting\\/store\",\"startup\\/error\",\"startup\\/event\",\"startup\\/login\",\"startup\\/permission\",\"startup\\/router\",\"startup\\/sass\",\"startup\\/startup\",\"tool\\/backup\",\"tool\\/log\",\"tool\\/upload\",\"user\\/api\"]}');

-- --------------------------------------------------------

--
-- Структура таблицы `oc_voucher`
--

CREATE TABLE `oc_voucher` (
  `voucher_id` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  `code` varchar(10) NOT NULL,
  `from_name` varchar(64) NOT NULL,
  `from_email` varchar(96) NOT NULL,
  `to_name` varchar(64) NOT NULL,
  `to_email` varchar(96) NOT NULL,
  `voucher_theme_id` int(11) NOT NULL,
  `message` text NOT NULL,
  `amount` decimal(15,4) NOT NULL,
  `status` tinyint(1) NOT NULL,
  `date_added` datetime NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `oc_voucher_history`
--

CREATE TABLE `oc_voucher_history` (
  `voucher_history_id` int(11) NOT NULL,
  `voucher_id` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  `amount` decimal(15,4) NOT NULL,
  `date_added` datetime NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `oc_voucher_theme`
--

CREATE TABLE `oc_voucher_theme` (
  `voucher_theme_id` int(11) NOT NULL,
  `image` varchar(255) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_voucher_theme`
--

INSERT INTO `oc_voucher_theme` (`voucher_theme_id`, `image`) VALUES
(8, 'catalog/demo/canon_eos_5d_2.jpg'),
(7, 'catalog/demo/gift-voucher-birthday.jpg'),
(6, 'catalog/demo/apple_logo.jpg');

-- --------------------------------------------------------

--
-- Структура таблицы `oc_voucher_theme_description`
--

CREATE TABLE `oc_voucher_theme_description` (
  `voucher_theme_id` int(11) NOT NULL,
  `language_id` int(11) NOT NULL,
  `name` varchar(32) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_voucher_theme_description`
--

INSERT INTO `oc_voucher_theme_description` (`voucher_theme_id`, `language_id`, `name`) VALUES
(6, 1, 'Новый год'),
(7, 1, 'День рождения'),
(8, 1, 'Другое'),
(6, 2, 'Новый год'),
(7, 2, 'День рождения'),
(8, 2, 'Другое');

-- --------------------------------------------------------

--
-- Структура таблицы `oc_weight_class`
--

CREATE TABLE `oc_weight_class` (
  `weight_class_id` int(11) NOT NULL,
  `value` decimal(15,8) NOT NULL DEFAULT 0.00000000
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_weight_class`
--

INSERT INTO `oc_weight_class` (`weight_class_id`, `value`) VALUES
(1, '1.00000000'),
(2, '1000.00000000'),
(5, '2.20460000'),
(6, '35.27400000');

-- --------------------------------------------------------

--
-- Структура таблицы `oc_weight_class_description`
--

CREATE TABLE `oc_weight_class_description` (
  `weight_class_id` int(11) NOT NULL,
  `language_id` int(11) NOT NULL,
  `title` varchar(32) NOT NULL,
  `unit` varchar(4) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_weight_class_description`
--

INSERT INTO `oc_weight_class_description` (`weight_class_id`, `language_id`, `title`, `unit`) VALUES
(1, 1, 'Килограмм', 'кг'),
(2, 1, 'Грамм', 'г'),
(1, 2, 'Килограмм', 'кг'),
(2, 2, 'Грамм', 'г');

-- --------------------------------------------------------

--
-- Структура таблицы `oc_zone`
--

CREATE TABLE `oc_zone` (
  `zone_id` int(11) NOT NULL,
  `country_id` int(11) NOT NULL,
  `name` varchar(128) NOT NULL,
  `code` varchar(32) NOT NULL,
  `status` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `oc_zone`
--

INSERT INTO `oc_zone` (`zone_id`, `country_id`, `name`, `code`, `status`) VALUES
(129, 220, 'Черкассы', 'CK', 1),
(130, 220, 'Чернигов', 'CH', 1),
(131, 220, 'Черновцы', 'CV', 1),
(132, 220, 'Днепропетровск', 'DN', 1),
(133, 220, 'Донецк', 'DO', 1),
(134, 220, 'Ивано-Франковск', 'IV', 1),
(135, 220, 'Харьков', 'KH', 1),
(136, 220, 'Хмельницкий', 'KM', 1),
(137, 220, 'Кировоград', 'KR', 1),
(138, 220, 'Киевская область', 'KV', 1),
(139, 220, 'Киев', 'KY', 1),
(140, 220, 'Луганск', 'LU', 1),
(141, 220, 'Львов', 'LV', 1),
(142, 220, 'Николаев', 'MY', 1),
(143, 220, 'Одесса', 'OD', 1),
(144, 220, 'Полтава', 'PO', 1),
(145, 220, 'Ровно', 'RI', 1),
(147, 220, 'Сумы', 'SU', 1),
(148, 220, 'Тернополь', 'TE', 1),
(149, 220, 'Винница', 'VI', 1),
(150, 220, 'Луцк', 'VO', 1),
(151, 220, 'Ужгород', 'ZK', 1),
(152, 220, 'Запорожье', 'ZA', 1),
(153, 220, 'Житомир', 'ZH', 1),
(154, 220, 'Херсон', 'KE', 1);

-- --------------------------------------------------------

--
-- Структура таблицы `oc_zone_to_geo_zone`
--

CREATE TABLE `oc_zone_to_geo_zone` (
  `zone_to_geo_zone_id` int(11) NOT NULL,
  `country_id` int(11) NOT NULL,
  `zone_id` int(11) NOT NULL DEFAULT 0,
  `geo_zone_id` int(11) NOT NULL,
  `date_added` datetime NOT NULL,
  `date_modified` datetime NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Индексы сохранённых таблиц
--

--
-- Индексы таблицы `oc_address`
--
ALTER TABLE `oc_address`
  ADD PRIMARY KEY (`address_id`),
  ADD KEY `customer_id` (`customer_id`);

--
-- Индексы таблицы `oc_api`
--
ALTER TABLE `oc_api`
  ADD PRIMARY KEY (`api_id`);

--
-- Индексы таблицы `oc_api_ip`
--
ALTER TABLE `oc_api_ip`
  ADD PRIMARY KEY (`api_ip_id`);

--
-- Индексы таблицы `oc_api_session`
--
ALTER TABLE `oc_api_session`
  ADD PRIMARY KEY (`api_session_id`);

--
-- Индексы таблицы `oc_attribute`
--
ALTER TABLE `oc_attribute`
  ADD PRIMARY KEY (`attribute_id`);

--
-- Индексы таблицы `oc_attribute_description`
--
ALTER TABLE `oc_attribute_description`
  ADD PRIMARY KEY (`attribute_id`,`language_id`);

--
-- Индексы таблицы `oc_attribute_group`
--
ALTER TABLE `oc_attribute_group`
  ADD PRIMARY KEY (`attribute_group_id`);

--
-- Индексы таблицы `oc_attribute_group_description`
--
ALTER TABLE `oc_attribute_group_description`
  ADD PRIMARY KEY (`attribute_group_id`,`language_id`);

--
-- Индексы таблицы `oc_banner`
--
ALTER TABLE `oc_banner`
  ADD PRIMARY KEY (`banner_id`);

--
-- Индексы таблицы `oc_banner_image`
--
ALTER TABLE `oc_banner_image`
  ADD PRIMARY KEY (`banner_image_id`);

--
-- Индексы таблицы `oc_cart`
--
ALTER TABLE `oc_cart`
  ADD PRIMARY KEY (`cart_id`),
  ADD KEY `cart_id` (`api_id`,`customer_id`,`session_id`,`product_id`,`recurring_id`);

--
-- Индексы таблицы `oc_category`
--
ALTER TABLE `oc_category`
  ADD PRIMARY KEY (`category_id`),
  ADD KEY `parent_id` (`parent_id`);

--
-- Индексы таблицы `oc_category_description`
--
ALTER TABLE `oc_category_description`
  ADD PRIMARY KEY (`category_id`,`language_id`),
  ADD KEY `name` (`name`);

--
-- Индексы таблицы `oc_category_filter`
--
ALTER TABLE `oc_category_filter`
  ADD PRIMARY KEY (`category_id`,`filter_id`);

--
-- Индексы таблицы `oc_category_path`
--
ALTER TABLE `oc_category_path`
  ADD PRIMARY KEY (`category_id`,`path_id`);

--
-- Индексы таблицы `oc_category_to_layout`
--
ALTER TABLE `oc_category_to_layout`
  ADD PRIMARY KEY (`category_id`,`store_id`);

--
-- Индексы таблицы `oc_category_to_store`
--
ALTER TABLE `oc_category_to_store`
  ADD PRIMARY KEY (`category_id`,`store_id`);

--
-- Индексы таблицы `oc_country`
--
ALTER TABLE `oc_country`
  ADD PRIMARY KEY (`country_id`);

--
-- Индексы таблицы `oc_coupon`
--
ALTER TABLE `oc_coupon`
  ADD PRIMARY KEY (`coupon_id`);

--
-- Индексы таблицы `oc_coupon_category`
--
ALTER TABLE `oc_coupon_category`
  ADD PRIMARY KEY (`coupon_id`,`category_id`);

--
-- Индексы таблицы `oc_coupon_history`
--
ALTER TABLE `oc_coupon_history`
  ADD PRIMARY KEY (`coupon_history_id`);

--
-- Индексы таблицы `oc_coupon_product`
--
ALTER TABLE `oc_coupon_product`
  ADD PRIMARY KEY (`coupon_product_id`);

--
-- Индексы таблицы `oc_currency`
--
ALTER TABLE `oc_currency`
  ADD PRIMARY KEY (`currency_id`);

--
-- Индексы таблицы `oc_customer`
--
ALTER TABLE `oc_customer`
  ADD PRIMARY KEY (`customer_id`);

--
-- Индексы таблицы `oc_customer_activity`
--
ALTER TABLE `oc_customer_activity`
  ADD PRIMARY KEY (`customer_activity_id`);

--
-- Индексы таблицы `oc_customer_affiliate`
--
ALTER TABLE `oc_customer_affiliate`
  ADD PRIMARY KEY (`customer_id`);

--
-- Индексы таблицы `oc_customer_approval`
--
ALTER TABLE `oc_customer_approval`
  ADD PRIMARY KEY (`customer_approval_id`);

--
-- Индексы таблицы `oc_customer_group`
--
ALTER TABLE `oc_customer_group`
  ADD PRIMARY KEY (`customer_group_id`);

--
-- Индексы таблицы `oc_customer_group_description`
--
ALTER TABLE `oc_customer_group_description`
  ADD PRIMARY KEY (`customer_group_id`,`language_id`);

--
-- Индексы таблицы `oc_customer_history`
--
ALTER TABLE `oc_customer_history`
  ADD PRIMARY KEY (`customer_history_id`);

--
-- Индексы таблицы `oc_customer_ip`
--
ALTER TABLE `oc_customer_ip`
  ADD PRIMARY KEY (`customer_ip_id`),
  ADD KEY `ip` (`ip`);

--
-- Индексы таблицы `oc_customer_login`
--
ALTER TABLE `oc_customer_login`
  ADD PRIMARY KEY (`customer_login_id`),
  ADD KEY `email` (`email`),
  ADD KEY `ip` (`ip`);

--
-- Индексы таблицы `oc_customer_online`
--
ALTER TABLE `oc_customer_online`
  ADD PRIMARY KEY (`ip`);

--
-- Индексы таблицы `oc_customer_reward`
--
ALTER TABLE `oc_customer_reward`
  ADD PRIMARY KEY (`customer_reward_id`);

--
-- Индексы таблицы `oc_customer_search`
--
ALTER TABLE `oc_customer_search`
  ADD PRIMARY KEY (`customer_search_id`);

--
-- Индексы таблицы `oc_customer_transaction`
--
ALTER TABLE `oc_customer_transaction`
  ADD PRIMARY KEY (`customer_transaction_id`);

--
-- Индексы таблицы `oc_customer_wishlist`
--
ALTER TABLE `oc_customer_wishlist`
  ADD PRIMARY KEY (`customer_id`,`product_id`);

--
-- Индексы таблицы `oc_custom_field`
--
ALTER TABLE `oc_custom_field`
  ADD PRIMARY KEY (`custom_field_id`);

--
-- Индексы таблицы `oc_custom_field_customer_group`
--
ALTER TABLE `oc_custom_field_customer_group`
  ADD PRIMARY KEY (`custom_field_id`,`customer_group_id`);

--
-- Индексы таблицы `oc_custom_field_description`
--
ALTER TABLE `oc_custom_field_description`
  ADD PRIMARY KEY (`custom_field_id`,`language_id`);

--
-- Индексы таблицы `oc_custom_field_value`
--
ALTER TABLE `oc_custom_field_value`
  ADD PRIMARY KEY (`custom_field_value_id`);

--
-- Индексы таблицы `oc_custom_field_value_description`
--
ALTER TABLE `oc_custom_field_value_description`
  ADD PRIMARY KEY (`custom_field_value_id`,`language_id`);

--
-- Индексы таблицы `oc_download`
--
ALTER TABLE `oc_download`
  ADD PRIMARY KEY (`download_id`);

--
-- Индексы таблицы `oc_download_description`
--
ALTER TABLE `oc_download_description`
  ADD PRIMARY KEY (`download_id`,`language_id`);

--
-- Индексы таблицы `oc_event`
--
ALTER TABLE `oc_event`
  ADD PRIMARY KEY (`event_id`);

--
-- Индексы таблицы `oc_extension`
--
ALTER TABLE `oc_extension`
  ADD PRIMARY KEY (`extension_id`);

--
-- Индексы таблицы `oc_extension_install`
--
ALTER TABLE `oc_extension_install`
  ADD PRIMARY KEY (`extension_install_id`);

--
-- Индексы таблицы `oc_extension_path`
--
ALTER TABLE `oc_extension_path`
  ADD PRIMARY KEY (`extension_path_id`);

--
-- Индексы таблицы `oc_filter`
--
ALTER TABLE `oc_filter`
  ADD PRIMARY KEY (`filter_id`);

--
-- Индексы таблицы `oc_filter_description`
--
ALTER TABLE `oc_filter_description`
  ADD PRIMARY KEY (`filter_id`,`language_id`);

--
-- Индексы таблицы `oc_filter_group`
--
ALTER TABLE `oc_filter_group`
  ADD PRIMARY KEY (`filter_group_id`);

--
-- Индексы таблицы `oc_filter_group_description`
--
ALTER TABLE `oc_filter_group_description`
  ADD PRIMARY KEY (`filter_group_id`,`language_id`);

--
-- Индексы таблицы `oc_geo_zone`
--
ALTER TABLE `oc_geo_zone`
  ADD PRIMARY KEY (`geo_zone_id`);

--
-- Индексы таблицы `oc_googleshopping_category`
--
ALTER TABLE `oc_googleshopping_category`
  ADD PRIMARY KEY (`google_product_category`,`store_id`),
  ADD KEY `category_id_store_id` (`category_id`,`store_id`);

--
-- Индексы таблицы `oc_googleshopping_product`
--
ALTER TABLE `oc_googleshopping_product`
  ADD PRIMARY KEY (`product_advertise_google_id`),
  ADD UNIQUE KEY `product_id_store_id` (`product_id`,`store_id`);

--
-- Индексы таблицы `oc_googleshopping_product_status`
--
ALTER TABLE `oc_googleshopping_product_status`
  ADD PRIMARY KEY (`product_id`,`store_id`,`product_variation_id`);

--
-- Индексы таблицы `oc_googleshopping_product_target`
--
ALTER TABLE `oc_googleshopping_product_target`
  ADD PRIMARY KEY (`product_id`,`advertise_google_target_id`);

--
-- Индексы таблицы `oc_googleshopping_target`
--
ALTER TABLE `oc_googleshopping_target`
  ADD PRIMARY KEY (`advertise_google_target_id`),
  ADD KEY `store_id` (`store_id`);

--
-- Индексы таблицы `oc_information`
--
ALTER TABLE `oc_information`
  ADD PRIMARY KEY (`information_id`);

--
-- Индексы таблицы `oc_information_description`
--
ALTER TABLE `oc_information_description`
  ADD PRIMARY KEY (`information_id`,`language_id`);

--
-- Индексы таблицы `oc_information_to_layout`
--
ALTER TABLE `oc_information_to_layout`
  ADD PRIMARY KEY (`information_id`,`store_id`);

--
-- Индексы таблицы `oc_information_to_store`
--
ALTER TABLE `oc_information_to_store`
  ADD PRIMARY KEY (`information_id`,`store_id`);

--
-- Индексы таблицы `oc_language`
--
ALTER TABLE `oc_language`
  ADD PRIMARY KEY (`language_id`),
  ADD KEY `name` (`name`);

--
-- Индексы таблицы `oc_layout`
--
ALTER TABLE `oc_layout`
  ADD PRIMARY KEY (`layout_id`);

--
-- Индексы таблицы `oc_layout_module`
--
ALTER TABLE `oc_layout_module`
  ADD PRIMARY KEY (`layout_module_id`);

--
-- Индексы таблицы `oc_layout_route`
--
ALTER TABLE `oc_layout_route`
  ADD PRIMARY KEY (`layout_route_id`);

--
-- Индексы таблицы `oc_length_class`
--
ALTER TABLE `oc_length_class`
  ADD PRIMARY KEY (`length_class_id`);

--
-- Индексы таблицы `oc_length_class_description`
--
ALTER TABLE `oc_length_class_description`
  ADD PRIMARY KEY (`length_class_id`,`language_id`);

--
-- Индексы таблицы `oc_location`
--
ALTER TABLE `oc_location`
  ADD PRIMARY KEY (`location_id`),
  ADD KEY `name` (`name`);

--
-- Индексы таблицы `oc_manufacturer`
--
ALTER TABLE `oc_manufacturer`
  ADD PRIMARY KEY (`manufacturer_id`);

--
-- Индексы таблицы `oc_manufacturer_to_store`
--
ALTER TABLE `oc_manufacturer_to_store`
  ADD PRIMARY KEY (`manufacturer_id`,`store_id`);

--
-- Индексы таблицы `oc_marketing`
--
ALTER TABLE `oc_marketing`
  ADD PRIMARY KEY (`marketing_id`);

--
-- Индексы таблицы `oc_modification`
--
ALTER TABLE `oc_modification`
  ADD PRIMARY KEY (`modification_id`);

--
-- Индексы таблицы `oc_module`
--
ALTER TABLE `oc_module`
  ADD PRIMARY KEY (`module_id`);

--
-- Индексы таблицы `oc_option`
--
ALTER TABLE `oc_option`
  ADD PRIMARY KEY (`option_id`);

--
-- Индексы таблицы `oc_option_description`
--
ALTER TABLE `oc_option_description`
  ADD PRIMARY KEY (`option_id`,`language_id`);

--
-- Индексы таблицы `oc_option_value`
--
ALTER TABLE `oc_option_value`
  ADD PRIMARY KEY (`option_value_id`);

--
-- Индексы таблицы `oc_option_value_description`
--
ALTER TABLE `oc_option_value_description`
  ADD PRIMARY KEY (`option_value_id`,`language_id`);

--
-- Индексы таблицы `oc_order`
--
ALTER TABLE `oc_order`
  ADD PRIMARY KEY (`order_id`);

--
-- Индексы таблицы `oc_order_history`
--
ALTER TABLE `oc_order_history`
  ADD PRIMARY KEY (`order_history_id`);

--
-- Индексы таблицы `oc_order_option`
--
ALTER TABLE `oc_order_option`
  ADD PRIMARY KEY (`order_option_id`);

--
-- Индексы таблицы `oc_order_product`
--
ALTER TABLE `oc_order_product`
  ADD PRIMARY KEY (`order_product_id`),
  ADD KEY `order_id` (`order_id`);

--
-- Индексы таблицы `oc_order_recurring`
--
ALTER TABLE `oc_order_recurring`
  ADD PRIMARY KEY (`order_recurring_id`);

--
-- Индексы таблицы `oc_order_recurring_transaction`
--
ALTER TABLE `oc_order_recurring_transaction`
  ADD PRIMARY KEY (`order_recurring_transaction_id`);

--
-- Индексы таблицы `oc_order_shipment`
--
ALTER TABLE `oc_order_shipment`
  ADD PRIMARY KEY (`order_shipment_id`);

--
-- Индексы таблицы `oc_order_status`
--
ALTER TABLE `oc_order_status`
  ADD PRIMARY KEY (`order_status_id`,`language_id`);

--
-- Индексы таблицы `oc_order_total`
--
ALTER TABLE `oc_order_total`
  ADD PRIMARY KEY (`order_total_id`),
  ADD KEY `order_id` (`order_id`);

--
-- Индексы таблицы `oc_order_voucher`
--
ALTER TABLE `oc_order_voucher`
  ADD PRIMARY KEY (`order_voucher_id`);

--
-- Индексы таблицы `oc_product`
--
ALTER TABLE `oc_product`
  ADD PRIMARY KEY (`product_id`);

--
-- Индексы таблицы `oc_product_attribute`
--
ALTER TABLE `oc_product_attribute`
  ADD PRIMARY KEY (`product_id`,`attribute_id`,`language_id`);

--
-- Индексы таблицы `oc_product_description`
--
ALTER TABLE `oc_product_description`
  ADD PRIMARY KEY (`product_id`,`language_id`),
  ADD KEY `name` (`name`);

--
-- Индексы таблицы `oc_product_discount`
--
ALTER TABLE `oc_product_discount`
  ADD PRIMARY KEY (`product_discount_id`),
  ADD KEY `product_id` (`product_id`);

--
-- Индексы таблицы `oc_product_filter`
--
ALTER TABLE `oc_product_filter`
  ADD PRIMARY KEY (`product_id`,`filter_id`);

--
-- Индексы таблицы `oc_product_image`
--
ALTER TABLE `oc_product_image`
  ADD PRIMARY KEY (`product_image_id`),
  ADD KEY `product_id` (`product_id`);

--
-- Индексы таблицы `oc_product_option`
--
ALTER TABLE `oc_product_option`
  ADD PRIMARY KEY (`product_option_id`);

--
-- Индексы таблицы `oc_product_option_value`
--
ALTER TABLE `oc_product_option_value`
  ADD PRIMARY KEY (`product_option_value_id`);

--
-- Индексы таблицы `oc_product_recurring`
--
ALTER TABLE `oc_product_recurring`
  ADD PRIMARY KEY (`product_id`,`recurring_id`,`customer_group_id`);

--
-- Индексы таблицы `oc_product_related`
--
ALTER TABLE `oc_product_related`
  ADD PRIMARY KEY (`product_id`,`related_id`);

--
-- Индексы таблицы `oc_product_reward`
--
ALTER TABLE `oc_product_reward`
  ADD PRIMARY KEY (`product_reward_id`);

--
-- Индексы таблицы `oc_product_special`
--
ALTER TABLE `oc_product_special`
  ADD PRIMARY KEY (`product_special_id`),
  ADD KEY `product_id` (`product_id`);

--
-- Индексы таблицы `oc_product_to_category`
--
ALTER TABLE `oc_product_to_category`
  ADD PRIMARY KEY (`product_id`,`category_id`),
  ADD KEY `category_id` (`category_id`);

--
-- Индексы таблицы `oc_product_to_download`
--
ALTER TABLE `oc_product_to_download`
  ADD PRIMARY KEY (`product_id`,`download_id`);

--
-- Индексы таблицы `oc_product_to_layout`
--
ALTER TABLE `oc_product_to_layout`
  ADD PRIMARY KEY (`product_id`,`store_id`);

--
-- Индексы таблицы `oc_product_to_store`
--
ALTER TABLE `oc_product_to_store`
  ADD PRIMARY KEY (`product_id`,`store_id`);

--
-- Индексы таблицы `oc_recurring`
--
ALTER TABLE `oc_recurring`
  ADD PRIMARY KEY (`recurring_id`);

--
-- Индексы таблицы `oc_recurring_description`
--
ALTER TABLE `oc_recurring_description`
  ADD PRIMARY KEY (`recurring_id`,`language_id`);

--
-- Индексы таблицы `oc_return`
--
ALTER TABLE `oc_return`
  ADD PRIMARY KEY (`return_id`);

--
-- Индексы таблицы `oc_return_action`
--
ALTER TABLE `oc_return_action`
  ADD PRIMARY KEY (`return_action_id`,`language_id`);

--
-- Индексы таблицы `oc_return_history`
--
ALTER TABLE `oc_return_history`
  ADD PRIMARY KEY (`return_history_id`);

--
-- Индексы таблицы `oc_return_reason`
--
ALTER TABLE `oc_return_reason`
  ADD PRIMARY KEY (`return_reason_id`,`language_id`);

--
-- Индексы таблицы `oc_return_status`
--
ALTER TABLE `oc_return_status`
  ADD PRIMARY KEY (`return_status_id`,`language_id`);

--
-- Индексы таблицы `oc_review`
--
ALTER TABLE `oc_review`
  ADD PRIMARY KEY (`review_id`),
  ADD KEY `product_id` (`product_id`);

--
-- Индексы таблицы `oc_seo_url`
--
ALTER TABLE `oc_seo_url`
  ADD PRIMARY KEY (`seo_url_id`),
  ADD KEY `query` (`query`),
  ADD KEY `keyword` (`keyword`);

--
-- Индексы таблицы `oc_session`
--
ALTER TABLE `oc_session`
  ADD PRIMARY KEY (`session_id`);

--
-- Индексы таблицы `oc_setting`
--
ALTER TABLE `oc_setting`
  ADD PRIMARY KEY (`setting_id`);

--
-- Индексы таблицы `oc_shipping_courier`
--
ALTER TABLE `oc_shipping_courier`
  ADD PRIMARY KEY (`shipping_courier_id`);

--
-- Индексы таблицы `oc_statistics`
--
ALTER TABLE `oc_statistics`
  ADD PRIMARY KEY (`statistics_id`);

--
-- Индексы таблицы `oc_stock_status`
--
ALTER TABLE `oc_stock_status`
  ADD PRIMARY KEY (`stock_status_id`,`language_id`);

--
-- Индексы таблицы `oc_store`
--
ALTER TABLE `oc_store`
  ADD PRIMARY KEY (`store_id`);

--
-- Индексы таблицы `oc_tax_class`
--
ALTER TABLE `oc_tax_class`
  ADD PRIMARY KEY (`tax_class_id`);

--
-- Индексы таблицы `oc_tax_rate`
--
ALTER TABLE `oc_tax_rate`
  ADD PRIMARY KEY (`tax_rate_id`);

--
-- Индексы таблицы `oc_tax_rate_to_customer_group`
--
ALTER TABLE `oc_tax_rate_to_customer_group`
  ADD PRIMARY KEY (`tax_rate_id`,`customer_group_id`);

--
-- Индексы таблицы `oc_tax_rule`
--
ALTER TABLE `oc_tax_rule`
  ADD PRIMARY KEY (`tax_rule_id`);

--
-- Индексы таблицы `oc_theme`
--
ALTER TABLE `oc_theme`
  ADD PRIMARY KEY (`theme_id`);

--
-- Индексы таблицы `oc_translation`
--
ALTER TABLE `oc_translation`
  ADD PRIMARY KEY (`translation_id`);

--
-- Индексы таблицы `oc_upload`
--
ALTER TABLE `oc_upload`
  ADD PRIMARY KEY (`upload_id`);

--
-- Индексы таблицы `oc_user`
--
ALTER TABLE `oc_user`
  ADD PRIMARY KEY (`user_id`);

--
-- Индексы таблицы `oc_user_group`
--
ALTER TABLE `oc_user_group`
  ADD PRIMARY KEY (`user_group_id`);

--
-- Индексы таблицы `oc_voucher`
--
ALTER TABLE `oc_voucher`
  ADD PRIMARY KEY (`voucher_id`);

--
-- Индексы таблицы `oc_voucher_history`
--
ALTER TABLE `oc_voucher_history`
  ADD PRIMARY KEY (`voucher_history_id`);

--
-- Индексы таблицы `oc_voucher_theme`
--
ALTER TABLE `oc_voucher_theme`
  ADD PRIMARY KEY (`voucher_theme_id`);

--
-- Индексы таблицы `oc_voucher_theme_description`
--
ALTER TABLE `oc_voucher_theme_description`
  ADD PRIMARY KEY (`voucher_theme_id`,`language_id`);

--
-- Индексы таблицы `oc_weight_class`
--
ALTER TABLE `oc_weight_class`
  ADD PRIMARY KEY (`weight_class_id`);

--
-- Индексы таблицы `oc_weight_class_description`
--
ALTER TABLE `oc_weight_class_description`
  ADD PRIMARY KEY (`weight_class_id`,`language_id`);

--
-- Индексы таблицы `oc_zone`
--
ALTER TABLE `oc_zone`
  ADD PRIMARY KEY (`zone_id`);

--
-- Индексы таблицы `oc_zone_to_geo_zone`
--
ALTER TABLE `oc_zone_to_geo_zone`
  ADD PRIMARY KEY (`zone_to_geo_zone_id`);

--
-- AUTO_INCREMENT для сохранённых таблиц
--

--
-- AUTO_INCREMENT для таблицы `oc_address`
--
ALTER TABLE `oc_address`
  MODIFY `address_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `oc_api`
--
ALTER TABLE `oc_api`
  MODIFY `api_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT для таблицы `oc_api_ip`
--
ALTER TABLE `oc_api_ip`
  MODIFY `api_ip_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT для таблицы `oc_api_session`
--
ALTER TABLE `oc_api_session`
  MODIFY `api_session_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=162;

--
-- AUTO_INCREMENT для таблицы `oc_attribute`
--
ALTER TABLE `oc_attribute`
  MODIFY `attribute_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT для таблицы `oc_attribute_group`
--
ALTER TABLE `oc_attribute_group`
  MODIFY `attribute_group_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT для таблицы `oc_banner`
--
ALTER TABLE `oc_banner`
  MODIFY `banner_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT для таблицы `oc_banner_image`
--
ALTER TABLE `oc_banner_image`
  MODIFY `banner_image_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=125;

--
-- AUTO_INCREMENT для таблицы `oc_cart`
--
ALTER TABLE `oc_cart`
  MODIFY `cart_id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=112;

--
-- AUTO_INCREMENT для таблицы `oc_category`
--
ALTER TABLE `oc_category`
  MODIFY `category_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=80;

--
-- AUTO_INCREMENT для таблицы `oc_country`
--
ALTER TABLE `oc_country`
  MODIFY `country_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=227;

--
-- AUTO_INCREMENT для таблицы `oc_coupon`
--
ALTER TABLE `oc_coupon`
  MODIFY `coupon_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT для таблицы `oc_coupon_history`
--
ALTER TABLE `oc_coupon_history`
  MODIFY `coupon_history_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `oc_coupon_product`
--
ALTER TABLE `oc_coupon_product`
  MODIFY `coupon_product_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `oc_currency`
--
ALTER TABLE `oc_currency`
  MODIFY `currency_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT для таблицы `oc_customer`
--
ALTER TABLE `oc_customer`
  MODIFY `customer_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `oc_customer_activity`
--
ALTER TABLE `oc_customer_activity`
  MODIFY `customer_activity_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `oc_customer_approval`
--
ALTER TABLE `oc_customer_approval`
  MODIFY `customer_approval_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `oc_customer_group`
--
ALTER TABLE `oc_customer_group`
  MODIFY `customer_group_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT для таблицы `oc_customer_history`
--
ALTER TABLE `oc_customer_history`
  MODIFY `customer_history_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `oc_customer_ip`
--
ALTER TABLE `oc_customer_ip`
  MODIFY `customer_ip_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `oc_customer_login`
--
ALTER TABLE `oc_customer_login`
  MODIFY `customer_login_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `oc_customer_reward`
--
ALTER TABLE `oc_customer_reward`
  MODIFY `customer_reward_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `oc_customer_search`
--
ALTER TABLE `oc_customer_search`
  MODIFY `customer_search_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `oc_customer_transaction`
--
ALTER TABLE `oc_customer_transaction`
  MODIFY `customer_transaction_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `oc_custom_field`
--
ALTER TABLE `oc_custom_field`
  MODIFY `custom_field_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `oc_custom_field_value`
--
ALTER TABLE `oc_custom_field_value`
  MODIFY `custom_field_value_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `oc_download`
--
ALTER TABLE `oc_download`
  MODIFY `download_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `oc_event`
--
ALTER TABLE `oc_event`
  MODIFY `event_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=47;

--
-- AUTO_INCREMENT для таблицы `oc_extension`
--
ALTER TABLE `oc_extension`
  MODIFY `extension_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=50;

--
-- AUTO_INCREMENT для таблицы `oc_extension_install`
--
ALTER TABLE `oc_extension_install`
  MODIFY `extension_install_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT для таблицы `oc_extension_path`
--
ALTER TABLE `oc_extension_path`
  MODIFY `extension_path_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=702;

--
-- AUTO_INCREMENT для таблицы `oc_filter`
--
ALTER TABLE `oc_filter`
  MODIFY `filter_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `oc_filter_group`
--
ALTER TABLE `oc_filter_group`
  MODIFY `filter_group_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `oc_geo_zone`
--
ALTER TABLE `oc_geo_zone`
  MODIFY `geo_zone_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT для таблицы `oc_googleshopping_product`
--
ALTER TABLE `oc_googleshopping_product`
  MODIFY `product_advertise_google_id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=315;

--
-- AUTO_INCREMENT для таблицы `oc_information`
--
ALTER TABLE `oc_information`
  MODIFY `information_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT для таблицы `oc_language`
--
ALTER TABLE `oc_language`
  MODIFY `language_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT для таблицы `oc_layout`
--
ALTER TABLE `oc_layout`
  MODIFY `layout_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT для таблицы `oc_layout_module`
--
ALTER TABLE `oc_layout_module`
  MODIFY `layout_module_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=89;

--
-- AUTO_INCREMENT для таблицы `oc_layout_route`
--
ALTER TABLE `oc_layout_route`
  MODIFY `layout_route_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=58;

--
-- AUTO_INCREMENT для таблицы `oc_length_class`
--
ALTER TABLE `oc_length_class`
  MODIFY `length_class_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT для таблицы `oc_location`
--
ALTER TABLE `oc_location`
  MODIFY `location_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `oc_manufacturer`
--
ALTER TABLE `oc_manufacturer`
  MODIFY `manufacturer_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT для таблицы `oc_marketing`
--
ALTER TABLE `oc_marketing`
  MODIFY `marketing_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `oc_modification`
--
ALTER TABLE `oc_modification`
  MODIFY `modification_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `oc_module`
--
ALTER TABLE `oc_module`
  MODIFY `module_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=36;

--
-- AUTO_INCREMENT для таблицы `oc_option`
--
ALTER TABLE `oc_option`
  MODIFY `option_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT для таблицы `oc_option_value`
--
ALTER TABLE `oc_option_value`
  MODIFY `option_value_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=49;

--
-- AUTO_INCREMENT для таблицы `oc_order`
--
ALTER TABLE `oc_order`
  MODIFY `order_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=58;

--
-- AUTO_INCREMENT для таблицы `oc_order_history`
--
ALTER TABLE `oc_order_history`
  MODIFY `order_history_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=61;

--
-- AUTO_INCREMENT для таблицы `oc_order_option`
--
ALTER TABLE `oc_order_option`
  MODIFY `order_option_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `oc_order_product`
--
ALTER TABLE `oc_order_product`
  MODIFY `order_product_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=163;

--
-- AUTO_INCREMENT для таблицы `oc_order_recurring`
--
ALTER TABLE `oc_order_recurring`
  MODIFY `order_recurring_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `oc_order_recurring_transaction`
--
ALTER TABLE `oc_order_recurring_transaction`
  MODIFY `order_recurring_transaction_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `oc_order_shipment`
--
ALTER TABLE `oc_order_shipment`
  MODIFY `order_shipment_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `oc_order_status`
--
ALTER TABLE `oc_order_status`
  MODIFY `order_status_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT для таблицы `oc_order_total`
--
ALTER TABLE `oc_order_total`
  MODIFY `order_total_id` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=70;

--
-- AUTO_INCREMENT для таблицы `oc_order_voucher`
--
ALTER TABLE `oc_order_voucher`
  MODIFY `order_voucher_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `oc_product`
--
ALTER TABLE `oc_product`
  MODIFY `product_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=364;

--
-- AUTO_INCREMENT для таблицы `oc_product_discount`
--
ALTER TABLE `oc_product_discount`
  MODIFY `product_discount_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=441;

--
-- AUTO_INCREMENT для таблицы `oc_product_image`
--
ALTER TABLE `oc_product_image`
  MODIFY `product_image_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2352;

--
-- AUTO_INCREMENT для таблицы `oc_product_option`
--
ALTER TABLE `oc_product_option`
  MODIFY `product_option_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=227;

--
-- AUTO_INCREMENT для таблицы `oc_product_option_value`
--
ALTER TABLE `oc_product_option_value`
  MODIFY `product_option_value_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT для таблицы `oc_product_reward`
--
ALTER TABLE `oc_product_reward`
  MODIFY `product_reward_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=546;

--
-- AUTO_INCREMENT для таблицы `oc_product_special`
--
ALTER TABLE `oc_product_special`
  MODIFY `product_special_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=689;

--
-- AUTO_INCREMENT для таблицы `oc_recurring`
--
ALTER TABLE `oc_recurring`
  MODIFY `recurring_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `oc_return`
--
ALTER TABLE `oc_return`
  MODIFY `return_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `oc_return_action`
--
ALTER TABLE `oc_return_action`
  MODIFY `return_action_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT для таблицы `oc_return_history`
--
ALTER TABLE `oc_return_history`
  MODIFY `return_history_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `oc_return_reason`
--
ALTER TABLE `oc_return_reason`
  MODIFY `return_reason_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT для таблицы `oc_return_status`
--
ALTER TABLE `oc_return_status`
  MODIFY `return_status_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT для таблицы `oc_review`
--
ALTER TABLE `oc_review`
  MODIFY `review_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `oc_seo_url`
--
ALTER TABLE `oc_seo_url`
  MODIFY `seo_url_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=890;

--
-- AUTO_INCREMENT для таблицы `oc_setting`
--
ALTER TABLE `oc_setting`
  MODIFY `setting_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1424;

--
-- AUTO_INCREMENT для таблицы `oc_statistics`
--
ALTER TABLE `oc_statistics`
  MODIFY `statistics_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT для таблицы `oc_stock_status`
--
ALTER TABLE `oc_stock_status`
  MODIFY `stock_status_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT для таблицы `oc_store`
--
ALTER TABLE `oc_store`
  MODIFY `store_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `oc_tax_class`
--
ALTER TABLE `oc_tax_class`
  MODIFY `tax_class_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT для таблицы `oc_tax_rate`
--
ALTER TABLE `oc_tax_rate`
  MODIFY `tax_rate_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=88;

--
-- AUTO_INCREMENT для таблицы `oc_tax_rule`
--
ALTER TABLE `oc_tax_rule`
  MODIFY `tax_rule_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=129;

--
-- AUTO_INCREMENT для таблицы `oc_theme`
--
ALTER TABLE `oc_theme`
  MODIFY `theme_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `oc_translation`
--
ALTER TABLE `oc_translation`
  MODIFY `translation_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `oc_upload`
--
ALTER TABLE `oc_upload`
  MODIFY `upload_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `oc_user`
--
ALTER TABLE `oc_user`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT для таблицы `oc_user_group`
--
ALTER TABLE `oc_user_group`
  MODIFY `user_group_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT для таблицы `oc_voucher`
--
ALTER TABLE `oc_voucher`
  MODIFY `voucher_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `oc_voucher_history`
--
ALTER TABLE `oc_voucher_history`
  MODIFY `voucher_history_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `oc_voucher_theme`
--
ALTER TABLE `oc_voucher_theme`
  MODIFY `voucher_theme_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT для таблицы `oc_weight_class`
--
ALTER TABLE `oc_weight_class`
  MODIFY `weight_class_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT для таблицы `oc_zone`
--
ALTER TABLE `oc_zone`
  MODIFY `zone_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=170;

--
-- AUTO_INCREMENT для таблицы `oc_zone_to_geo_zone`
--
ALTER TABLE `oc_zone_to_geo_zone`
  MODIFY `zone_to_geo_zone_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
