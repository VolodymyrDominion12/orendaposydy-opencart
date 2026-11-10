# 012 — План реалізації сервісних та інформаційних сторінок

## Архітектура
1. **База даних та міграція `0023_kristal_info_pages`**:
   - Оновлення існуючих сторінок в `oc_information_description`:
     - `information_id=4`: назва «Про нас», опис, meta title/description.
     - `information_id=5`: назва «Умови оренди», розгорнутий опис правил, застави, бою, миття.
     - `information_id=6`: назва «Доставка та оплата», зони, тарифи, варіанти оплат.
   - Створення нових сторінок:
     - `information_id=13`: «Для бізнесу та кейтерингу (B2B)»
     - `information_id=14`: «Часті питання (FAQ)»
   - Реєстрація ЧПУ в `oc_seo_url`:
     - `information_id=4` -> `pro-nas`
     - `information_id=5` -> `umovy-orendy`
     - `information_id=6` -> `dostavka-ta-oplata`
     - `information_id=13` -> `dlia-biznesu`
     - `information_id=14` -> `faq`
     - `information/contact` -> `kontakty`
   - 301-редиректи в `oc_kristal_redirect`:
     - `/oplata` -> `/dostavka-ta-oplata`
     - `/dostavka` -> `/dostavka-ta-oplata`
2. **Контролер `information/contact`**:
   - `src/catalog/controller/information/contact.php`:
     - Відновлення чистого OpenCart 3 контролера з підтримкою полів імені, телефону/email, повідомлення.
     - Інтеграція антиспаму `kristal_core` (токен + honeypot).
     - Підтримка збереження заявки як ліда в `kristal_lead` та надсилання в Telegram `kristal_notify`.
     - Генерація Schema.org `LocalBusiness` JSON-LD.
3. **Шаблони теми `kristal`**:
   - `src/catalog/view/theme/kristal/template/information/information.twig`:
     - Сучасна верстка інформаційної статті: бейджі, блоки-виноски, списки з іконками, акордеони, блок зворотного зв'язку або кнопки дзвінка/розрахунку в кінці.
   - `src/catalog/view/theme/kristal/template/information/contact.twig`:
     - Картка контактів: адреса (Львів, Б. Хмельницького, 106), телефон `+38 (067) 827-70-07`, Viber, Telegram, графік щодня 9:00–20:00, інтерактивна карта, форма звернення.
4. **Тестування**:
   - Smoke-тести на всі інформаційні сторінки та контакти.
   - Валідація лінтером (`make lint ALL=1`).
   - Перевірка відсутності битих посилань та 301.
