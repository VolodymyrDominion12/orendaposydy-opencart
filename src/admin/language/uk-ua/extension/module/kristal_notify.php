<?php
// Heading
$_['heading_title']       = 'Крістал: сповіщення';

// Text
$_['text_extension']      = 'Розширення';
$_['text_success']        = 'Успішно: налаштування сповіщень збережено!';
$_['text_edit']           = 'Налаштування каналів сповіщень (Telegram, Email, Webhook)';
$_['text_telegram']       = 'Telegram';
$_['text_email']          = 'Email';
$_['text_webhook']        = 'CRM Webhook';
$_['text_log']            = 'Журнал відправок';
$_['text_test_sent']      = 'Тестове повідомлення успішно надіслано!';
$_['text_retry_success']  = 'Повторну спробу успішно виконано!';
$_['text_imported']       = 'Налаштування успішно перенесено зі старого модуля notifications_in_telegram!';
$_['text_import_confirm'] = 'Перенести токен бота і chat_id зі старого модуля notifications_in_telegram та вимкнути його?';
$_['text_all']            = 'Усі';
$_['text_status_sent']    = 'Надіслано';
$_['text_status_failed']  = 'Помилка';

// Стан модуля та попередження (2026-11-18)
$_['text_module_state']       = 'Стан модуля';
$_['text_state_master']       = 'Головний статус';
$_['text_state_event']        = 'Подія замовлення';
$_['text_state_last_order']   = 'Останнє сповіщення про замовлення';
$_['text_state_no_orders']    = 'Ще немає жодного сповіщення про замовлення';
$_['text_state_yes']          = 'Увімкнено';
$_['text_state_no']           = 'Вимкнено';
$_['text_state_event_ok']     = 'Зареєстровано';
$_['text_state_event_missing'] = 'НЕ зареєстровано';
$_['text_warn_master_off']    = 'Увага: головний статус модуля вимкнено — сповіщення з сайту не надсилатимуться. Увімкніть його на вкладці «Загальні» і натисніть «Зберегти».';
$_['text_warn_event_missing'] = 'Увага: подію замовлення не зареєстровано — сповіщення з сайту не надходитимуть. Натисніть «Зберегти», модуль зареєструє її автоматично.';
$_['text_warn_channel_off']   = 'Увага: канал %s вимкнено — з сайту повідомлення не надсилатимуться.';
$_['text_warn_unsaved']       = 'Тест використано з полів форми. Щоб сайт надсилав сповіщення, натисніть «Зберегти».';

// Entry
$_['entry_status']        = 'Головний статус модуля';
$_['entry_tg_status']     = 'Увімкнути Telegram';
$_['entry_tg_token']      = 'Bot Token';
$_['entry_tg_chats']      = 'Chat ID отримувачів';
$_['entry_email_status']  = 'Увімкнути Email';
$_['entry_email_to']      = 'Email отримувачів';
$_['entry_email_prefix']  = 'Префікс теми листа';
$_['entry_hook_status']   = 'Увімкнути Webhook';
$_['entry_hook_url']      = 'URL вебхука';
$_['entry_hook_secret']   = 'Секретний ключ (HMAC SHA-256)';

// Help
$_['help_tg_token']       = 'Токен від @BotFather (наприклад, 123456789:ABCdef...).';
$_['help_tg_chats']       = 'Один або кілька ID чатів чи груп через кому або з нового рядка. Для супергруп чи каналів ID починається з мінуса (наприклад, -100123456789).';
$_['help_email_to']       = 'Один або кілька email через кому або з нового рядка. Якщо порожньо — надсилається на основний email магазину.';
$_['help_email_prefix']   = 'Текст на початку теми, наприклад: [Крістал Оренда].';
$_['help_hook_url']       = 'Адреса зовнішньої CRM чи сервісу, куди надсилатиметься HTTP POST із JSON-даними замовлення чи ліда.';
$_['help_hook_secret']    = 'Ключ для перевірки підпису у заголовку X-Kristal-Signature.';

// Button
$_['button_test']         = 'Надіслати тест';
$_['button_retry']        = 'Повторити';
$_['button_import']       = 'Імпортувати зі старого модуля';
$_['button_filter']       = 'Фільтрувати';

// Column
$_['column_date']         = 'Дата і час';
$_['column_channel']      = 'Канал';
$_['column_event']        = 'Подія';
$_['column_recipient']    = 'Адресат';
$_['column_summary']      = 'Опис';
$_['column_status']       = 'Статус';
$_['column_attempts']     = 'Спроби';
$_['column_error']        = 'Помилка';
$_['column_action']       = 'Дія';

// Error
$_['error_permission']    = 'Увага: у вас немає прав для зміни модуля «Крістал: сповіщення»!';
$_['error_tg_token']      = 'Невірний формат токена Telegram бота!';
$_['error_tg_chats']      = 'Вкажіть хоча б один коректний chat_id для Telegram!';
$_['error_email_to']      = 'Вкажіть коректні email-адреси!';
$_['error_hook_url']      = 'Вкажіть коректний URL вебхука (https://...)!';
$_['error_no_log']        = 'Запис журналу не знайдено!';
