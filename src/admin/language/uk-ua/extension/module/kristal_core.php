<?php
// Фіча 019: «Крістал: основне» — контакти (NAP), месенджери, Telegram, антиспам
// Heading
$_['heading_title']        = 'Крістал: основне';

// Text
$_['text_extension']       = 'Розширення';
$_['text_success']         = 'Налаштування збережено.';
$_['text_edit']            = 'Контакти й спільні налаштування сайту';
$_['text_prefilled']       = 'Модуль ще не зберігався: поля заповнено з налаштувань магазину. Перевірте й натисніть «Зберегти».';
$_['text_phone_hint']      = 'Будь-який формат: 067 123 45 67, +38 (067) 123-45-67. Зберігається як +380671234567. Перший — основний.';
$_['text_core_sync']       = 'Основний телефон, адреса й email при збереженні копіюються в налаштування магазину (листи й рахунки OpenCart).';
$_['text_hours_hint']      = 'Для Google (openingHoursSpecification). Порожні рядки ігноруються.';
$_['text_social_hint']     = 'Посилання https://… або нік (@kristal).';
$_['text_tg_hint']         = 'Тестовий бот і чат розробника. Бот клієнта і кілька чатів — у фічі 023.';
$_['text_tg_token_saved']  = 'Збережено: %s. Залиште поле порожнім, щоб не змінювати.';
$_['text_tg_sending']      = 'Надсилаю…';
$_['text_tg_sent']         = 'Надіслано. Перевірте чат.';
$_['text_tg_test_message'] = "✅ <b>Тест з адмінки %s</b>\n%s\nЯкщо ви це бачите — заявки дійдуть.";
$_['text_spam_hint']       = 'Діє на всі форми сайту (заявки, дзвінок, кошик події).';
$_['text_preview_hint']    = 'Мікророзмітка LocalBusiness зі збережених контактів. Скопіюйте в validator.schema.org. На сайт виводиться у фічі 011.';
$_['text_preview_empty']   = 'Спершу збережіть налаштування.';
$_['text_copy']            = 'Копіювати';
$_['text_copied']          = 'Скопійовано';

// Tabs
$_['tab_contacts']         = 'Контакти';
$_['tab_social']           = 'Месенджери й соцмережі';
$_['tab_telegram']         = 'Telegram';
$_['tab_spam']             = 'Антиспам';
$_['tab_preview']          = 'Перевірка';

// Entry
$_['entry_status']         = 'Статус';
$_['entry_name']           = 'Назва компанії';
$_['entry_legal_name']     = 'Юридична назва';
$_['entry_address']        = 'Адреса (вулиця, будинок)';
$_['entry_city']           = 'Місто';
$_['entry_postcode']       = 'Поштовий індекс';
$_['entry_email']          = 'Email';
$_['entry_geo']            = 'Координати (широта, довгота)';
$_['entry_geo_lat']        = 'Широта, напр. 49.8397';
$_['entry_geo_lng']        = 'Довгота, напр. 24.0297';
$_['entry_phones']         = 'Телефони';
$_['entry_phone']          = 'Номер';
$_['entry_phone_label']    = 'Підпис (Менеджер, Склад…)';
$_['entry_hours']          = 'Графік роботи';
$_['entry_hours_from']     = 'з';
$_['entry_hours_to']       = 'до';
$_['entry_hours_note']     = 'Примітка до графіка';
$_['entry_telegram_username'] = 'Telegram (канал або акаунт)';
$_['entry_instagram']      = 'Instagram';
$_['entry_facebook']       = 'Facebook';
$_['entry_tiktok']         = 'TikTok';
$_['entry_youtube']        = 'YouTube';
$_['entry_tg_token']       = 'Токен бота';
$_['entry_tg_token_clear'] = 'Видалити збережений токен';
$_['entry_tg_chat_id']     = 'chat_id';
$_['entry_spam_min_seconds'] = 'Мінімум секунд на заповнення форми';
$_['entry_spam_rate_limit']  = 'Заявок з однієї IP за вікно';
$_['entry_spam_rate_window'] = 'Вікно, секунд (3600 = година)';

// Messengers
$_['text_viber']           = 'Viber';
$_['text_telegram']        = 'Telegram';
$_['text_whatsapp']        = 'WhatsApp';

// Days
$_['text_day_Mo']          = 'Пн';
$_['text_day_Tu']          = 'Вт';
$_['text_day_We']          = 'Ср';
$_['text_day_Th']          = 'Чт';
$_['text_day_Fr']          = 'Пт';
$_['text_day_Sa']          = 'Сб';
$_['text_day_Su']          = 'Нд';

// Button
$_['button_tg_test']       = 'Надіслати тестове повідомлення';

// Error
$_['error_permission']     = 'Увага: у вас немає прав змінювати модуль «Крістал: основне».';
$_['error_form']           = 'Перевірте виділені поля.';
$_['error_phone']          = 'Невірний номер. Потрібен український номер: +380XXXXXXXXX (9 цифр після +380).';
$_['error_email']          = 'Невірний email.';
$_['error_geo']            = 'Вкажіть обидві координати числами (широта −90…90, довгота −180…180) або залиште обидва поля порожніми.';
$_['error_hours']          = 'Оберіть дні й вкажіть час «з» менший за «до» (формат 09:00).';
$_['error_social']         = 'Потрібне посилання https://… або нік з латинських літер, цифр, «.», «_», «-».';
$_['error_tg_token']       = 'Токен має вигляд 123456789:AA… (видає @BotFather).';
$_['error_tg_chat_id']     = 'chat_id — число (для груп від\'ємне, -100…) або @назва_каналу.';
$_['error_spam_min_seconds'] = 'Від 0 до 60.';
$_['error_spam_rate_limit']  = 'Від 1 до 1000.';
$_['error_spam_rate_window'] = 'Від 60 до 86400.';
$_['error_tg_config']      = 'Вкажіть правильні токен бота й chat_id.';
$_['error_tg_network']     = 'Не вдалося зв\'язатися з Telegram: %s';
$_['error_tg_api']         = 'Telegram відповів: %s';
