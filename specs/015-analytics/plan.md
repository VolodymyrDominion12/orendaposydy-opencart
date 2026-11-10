# 015 — План реалізації kristal_analytics

## Архітектура
1. **Налаштування в `oc_setting`**:
   - `module_kristal_analytics_status`: 0 або 1
   - `module_kristal_analytics_gtm_id`: код контейнера (напр. GTM-XXXXXXX)
   - `module_kristal_analytics_ga4_id`: ID потоку даних (напр. G-XXXXXXXXXX)
   - `module_kristal_analytics_consent`: 0 або 1 (увімкнення банера згоди)
2. **Адмінка**:
   - `src/admin/controller/extension/module/kristal_analytics.php`
   - `src/admin/view/template/extension/module/kristal_analytics.twig`
   - `src/admin/language/uk-ua/extension/module/kristal_analytics.php`
3. **Вітрина**:
   - Подія `catalog/view/common/header/before` або хук у `header.twig`:
     - Ініціалізація `window.dataLayer = window.dataLayer || [];`
     - Встановлення базових параметрів Consent Mode v2:
       `gtag('consent', 'default', { 'ad_storage': 'denied', 'analytics_storage': 'denied', ... })`
     - Підключення GTM з легким асинхронним завантаженням.
   - Скрипт `src/catalog/view/theme/kristal/js/kristal-analytics.js`:
     - Перехоплення кліків на `tel:`, `viber://`, `https://t.me/` -> подія `contact_click`.
     - Слухач подій додавання в кошик та надсилання лід-форм (`kristal:lead_success`, `kristal:kit_added`).
     - Cookie banner з кнопками «Прийняти всі» та «Тільки необхідні».
4. **Міграція `0024_kristal_analytics`**:
   - Початкові налаштування в `oc_setting`.
5. **Тестування**:
   - Smoke-тести, лінтування, перевірка відсутності помилок JS.
