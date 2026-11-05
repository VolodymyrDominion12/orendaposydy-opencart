<?php
// Feature 019: "Kristal: core" — contacts (NAP), messengers, Telegram, anti-spam
// Heading
$_['heading_title']        = 'Kristal: core';

// Text
$_['text_extension']       = 'Extensions';
$_['text_success']         = 'Settings saved.';
$_['text_edit']            = 'Contacts and shared site settings';
$_['text_prefilled']       = 'The module has not been saved yet: fields are prefilled from the store settings. Check them and click Save.';
$_['text_phone_hint']      = 'Any format: 067 123 45 67, +38 (067) 123-45-67. Stored as +380671234567. The first one is primary.';
$_['text_core_sync']       = 'On save, the primary phone, address and email are copied to the store settings (OpenCart emails and invoices).';
$_['text_hours_hint']      = 'For Google (openingHoursSpecification). Empty rows are ignored.';
$_['text_social_hint']     = 'A https://… link or a nickname (@kristal).';
$_['text_tg_hint']         = 'Developer test bot and chat. The client bot and multiple chats come in feature 023.';
$_['text_tg_token_saved']  = 'Saved: %s. Leave empty to keep it.';
$_['text_tg_sending']      = 'Sending…';
$_['text_tg_sent']         = 'Sent. Check the chat.';
$_['text_tg_test_message'] = "✅ <b>Test from %s admin</b>\n%s\nIf you see this, leads will be delivered.";
$_['text_spam_hint']       = 'Applies to all site forms (leads, callback, event cart).';
$_['text_preview_hint']    = 'LocalBusiness markup from the saved contacts. Paste into validator.schema.org. Output on the site comes in feature 011.';
$_['text_preview_empty']   = 'Save the settings first.';
$_['text_copy']            = 'Copy';
$_['text_copied']          = 'Copied';

// Tabs
$_['tab_contacts']         = 'Contacts';
$_['tab_social']           = 'Messengers & social';
$_['tab_telegram']         = 'Telegram';
$_['tab_spam']             = 'Anti-spam';
$_['tab_preview']          = 'Check';

// Entry
$_['entry_status']         = 'Status';
$_['entry_name']           = 'Company name';
$_['entry_legal_name']     = 'Legal name';
$_['entry_address']        = 'Address (street, building)';
$_['entry_city']           = 'City';
$_['entry_postcode']       = 'Postcode';
$_['entry_email']          = 'Email';
$_['entry_geo']            = 'Coordinates (latitude, longitude)';
$_['entry_geo_lat']        = 'Latitude, e.g. 49.8397';
$_['entry_geo_lng']        = 'Longitude, e.g. 24.0297';
$_['entry_phones']         = 'Phones';
$_['entry_phone']          = 'Number';
$_['entry_phone_label']    = 'Label (Manager, Warehouse…)';
$_['entry_hours']          = 'Opening hours';
$_['entry_hours_from']     = 'from';
$_['entry_hours_to']       = 'to';
$_['entry_hours_note']     = 'Opening hours note';
$_['entry_telegram_username'] = 'Telegram (channel or account)';
$_['entry_instagram']      = 'Instagram';
$_['entry_facebook']       = 'Facebook';
$_['entry_tiktok']         = 'TikTok';
$_['entry_youtube']        = 'YouTube';
$_['entry_tg_token']       = 'Bot token';
$_['entry_tg_token_clear'] = 'Delete the saved token';
$_['entry_tg_chat_id']     = 'chat_id';
$_['entry_spam_min_seconds'] = 'Minimum seconds to fill a form';
$_['entry_spam_rate_limit']  = 'Submissions per IP per window';
$_['entry_spam_rate_window'] = 'Window, seconds (3600 = hour)';

// Messengers
$_['text_viber']           = 'Viber';
$_['text_telegram']        = 'Telegram';
$_['text_whatsapp']        = 'WhatsApp';

// Days
$_['text_day_Mo']          = 'Mon';
$_['text_day_Tu']          = 'Tue';
$_['text_day_We']          = 'Wed';
$_['text_day_Th']          = 'Thu';
$_['text_day_Fr']          = 'Fri';
$_['text_day_Sa']          = 'Sat';
$_['text_day_Su']          = 'Sun';

// Button
$_['button_tg_test']       = 'Send a test message';

// Error
$_['error_permission']     = 'Warning: you do not have permission to modify "Kristal: core".';
$_['error_form']           = 'Check the highlighted fields.';
$_['error_phone']          = 'Invalid number. A Ukrainian number is required: +380XXXXXXXXX.';
$_['error_email']          = 'Invalid email.';
$_['error_geo']            = 'Enter both coordinates as numbers (latitude −90…90, longitude −180…180) or leave both empty.';
$_['error_hours']          = 'Choose days and a "from" time earlier than "to" (format 09:00).';
$_['error_social']         = 'A https://… link or a nickname of Latin letters, digits, ".", "_", "-" is required.';
$_['error_tg_token']       = 'The token looks like 123456789:AA… (issued by @BotFather).';
$_['error_tg_chat_id']     = 'chat_id is a number (negative -100… for groups) or @channel_name.';
$_['error_spam_min_seconds'] = 'From 0 to 60.';
$_['error_spam_rate_limit']  = 'From 1 to 1000.';
$_['error_spam_rate_window'] = 'From 60 to 86400.';
$_['error_tg_config']      = 'Enter a valid bot token and chat_id.';
$_['error_tg_network']     = 'Could not reach Telegram: %s';
$_['error_tg_api']         = 'Telegram replied: %s';
