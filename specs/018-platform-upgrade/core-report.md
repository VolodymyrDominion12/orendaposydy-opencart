# 018 — звіт оновлення ядра 3.0.3.2 → 3.0.4.1

Згенеровано `make core-report` 2026-11-06 12:50. Не редагувати вручну.

| Що | Кількість |
|---|---|
| Файлів ядра 3.0.4.1 | 2256 |
| Спільних із src/ (буде перезаписано) | 1327 |
| Нових у 3.0.4.1 (буде додано) | 929 |
| Файлів src/, яких немає в 3.0.4.1 | 1467 |
| — залишаються (KEEP) | 506 |
| — до видалення (REMOVE) | 863 |
| — вирішити вручну (REVIEW) | 98 |

## 1. Ручні правки ядра (src/ ≠ оригінальний 3.0.3.2)

**Не перевірено:** немає `vendor-src/opencart-3.0.3.2.zip`. Без цього перезапис може знищити ручні правки.

## 2. Шаблони й код, несумісні з Twig 3

- `catalog/controller/event/theme.php: використовує клас Twig 1.x (Twig_*)`
- `system/storage/cache/81/818b53c85742cc62f41afe40ac761a7f6de1a6e292e81644fdf963a4aeed20fd.php: використовує клас Twig 1.x (Twig_*)`
- `system/storage/cache/e3/e3172ee4e92701452dac96d55f41221b38a4b3226a03881405ce2f36fcb8b0f0.php: використовує клас Twig 1.x (Twig_*)`
- `system/storage/cache/4c/4c186a1e62c73e321bd50a1af3c947014e08de622ff36e6e7ee83bd0e6dd9da7.php: використовує клас Twig 1.x (Twig_*)`
- `system/storage/cache/7c/7cb35080f1747c7f016a4562e44fe84b72f5eb19cf7c89765b35088ed2da7f88.php: використовує клас Twig 1.x (Twig_*)`
- `system/storage/cache/7c/7cb6f8d7911f04418906801144a423abe0ddf56e51b58d83b1c9f40af808d0eb.php: використовує клас Twig 1.x (Twig_*)`
- `system/storage/cache/ea/eab41d8e8d69de0823402cd5bbedc363d7cc6b682056cdda4d77c0ab2db595de.php: використовує клас Twig 1.x (Twig_*)`
- `system/storage/cache/b5/b5b3997ec3f0382c76637e472dd67f9cc87545ccd883d8065359a69d20ab4032.php: використовує клас Twig 1.x (Twig_*)`
- `system/storage/cache/36/3647f1c27f3551ddd4f4a6bb64893c41a540b27aaf7b8b2c3cd956936f826ac4.php: використовує клас Twig 1.x (Twig_*)`
- `system/storage/cache/e7/e7a10d279486d9bcf9793fdc12d3abe431cb3e82849c0d3568373a04b5d1dd63.php: використовує клас Twig 1.x (Twig_*)`
- `system/storage/cache/32/327a887e334383fa4d59cfa711e4ce54c54e42e2cd95c269a829b0494136039f.php: використовує клас Twig 1.x (Twig_*)`
- `system/storage/cache/65/659e8603e1d05eefc54406c26126bdadbd7c3fd421d4214cf6b4423f2248bd13.php: використовує клас Twig 1.x (Twig_*)`
- `system/storage/cache/ed/ed74ef842f5ccc1db3e1ec3dbb0f56034b43d7cc637192c596da45c8354759ba.php: використовує клас Twig 1.x (Twig_*)`
- `system/storage/cache/66/66a6fadd301232c1d2b9d24c87999754eee926a8499893216f582a91982dffe5.php: використовує клас Twig 1.x (Twig_*)`
- `system/storage/cache/b7/b729ff36732831e91c6c47ac15eaa326024ca97c9249e98697c53116e125db9b.php: використовує клас Twig 1.x (Twig_*)`
- `system/storage/modification/system/library/template/twig.php: використовує клас Twig 1.x (Twig_*)`

## 3. Вирішити вручну (REVIEW)

- `admin/controller/extension/extension/_dashboard.php` — невідоме походження — вирішити вручну
- `admin/controller/extension/extension/_payment.php` — невідоме походження — вирішити вручну
- `admin/controller/extension/extension/_shipping.php` — невідоме походження — вирішити вручну
- `admin/index.svg` — невідоме походження — вирішити вручну
- `admin/index1.php` — невідоме походження — вирішити вручну
- `admin/language/en-gb/extension/module/pp_button.php` — невідоме походження — вирішити вручну
- `admin/language/uk-ua/extension/extension.php` — мовний файл без відповідника в ядрі, але маршрут 'extension/extension' згадується в коді
- `admin/language/uk-ua/extension/extension/promotion.php` — мовний файл без відповідника в ядрі, але маршрут 'extension/extension/promotion' згадується в коді
- `admin/language/uk-ua/extension/module/pp_button.php` — мовний файл без відповідника в ядрі, але маршрут 'extension/module/pp_button' згадується в коді
- `admin/language/uk-ua/extension/openbay.php` — мовний файл без відповідника в ядрі, але маршрут 'extension/openbay' згадується в коді
- `admin/language/uk-ua/extension/openbay/amazon.php` — мовний файл без відповідника в ядрі, але маршрут 'extension/openbay/amazon' згадується в коді
- `admin/language/uk-ua/extension/openbay/amazonus.php` — мовний файл без відповідника в ядрі, але маршрут 'extension/openbay/amazonus' згадується в коді
- `admin/language/uk-ua/extension/payment/pp_express.php` — мовний файл без відповідника в ядрі, але маршрут 'extension/payment/pp_express' згадується в коді
- `admin/language/uk-ua/extension/payment/pp_pro.php` — мовний файл без відповідника в ядрі, але маршрут 'extension/payment/pp_pro' згадується в коді
- `admin/language/uk-ua/extension/payment/pp_standard.php` — мовний файл без відповідника в ядрі, але маршрут 'extension/payment/pp_standard' згадується в коді
- `admin/language/uk-ua/mail/affiliate.php` — мовний файл без відповідника в ядрі, але маршрут 'mail/affiliate' згадується в коді
- `admin/view/image/payment/1.png` — невідоме походження — вирішити вручну
- `admin/view/javascript/summernote/lang/summernote-ar-AR.js` — невідоме походження — вирішити вручну
- `admin/view/javascript/summernote/lang/summernote-bg-BG.js` — невідоме походження — вирішити вручну
- `admin/view/javascript/summernote/lang/summernote-ca-ES.js` — невідоме походження — вирішити вручну
- `admin/view/javascript/summernote/lang/summernote-cs-CZ.js` — невідоме походження — вирішити вручну
- `admin/view/javascript/summernote/lang/summernote-da-DK.js` — невідоме походження — вирішити вручну
- `admin/view/javascript/summernote/lang/summernote-de-DE.js` — невідоме походження — вирішити вручну
- `admin/view/javascript/summernote/lang/summernote-es-ES.js` — невідоме походження — вирішити вручну
- `admin/view/javascript/summernote/lang/summernote-es-EU.js` — невідоме походження — вирішити вручну
- `admin/view/javascript/summernote/lang/summernote-fa-IR.js` — невідоме походження — вирішити вручну
- `admin/view/javascript/summernote/lang/summernote-fi-FI.js` — невідоме походження — вирішити вручну
- `admin/view/javascript/summernote/lang/summernote-fr-FR.js` — невідоме походження — вирішити вручну
- `admin/view/javascript/summernote/lang/summernote-gl-ES.js` — невідоме походження — вирішити вручну
- `admin/view/javascript/summernote/lang/summernote-he-IL.js` — невідоме походження — вирішити вручну
- `admin/view/javascript/summernote/lang/summernote-hr-HR.js` — невідоме походження — вирішити вручну
- `admin/view/javascript/summernote/lang/summernote-hu-HU.js` — невідоме походження — вирішити вручну
- `admin/view/javascript/summernote/lang/summernote-id-ID.js` — невідоме походження — вирішити вручну
- `admin/view/javascript/summernote/lang/summernote-it-IT.js` — невідоме походження — вирішити вручну
- `admin/view/javascript/summernote/lang/summernote-ja-JP.js` — невідоме походження — вирішити вручну
- `admin/view/javascript/summernote/lang/summernote-ko-KR.js` — невідоме походження — вирішити вручну
- `admin/view/javascript/summernote/lang/summernote-lt-LT.js` — невідоме походження — вирішити вручну
- `admin/view/javascript/summernote/lang/summernote-lt-LV.js` — невідоме походження — вирішити вручну
- `admin/view/javascript/summernote/lang/summernote-nb-NO.js` — невідоме походження — вирішити вручну
- `admin/view/javascript/summernote/lang/summernote-nl-NL.js` — невідоме походження — вирішити вручну
- `admin/view/javascript/summernote/lang/summernote-pl-PL.js` — невідоме походження — вирішити вручну
- `admin/view/javascript/summernote/lang/summernote-pt-BR.js` — невідоме походження — вирішити вручну
- `admin/view/javascript/summernote/lang/summernote-ro-RO.js` — невідоме походження — вирішити вручну
- `admin/view/javascript/summernote/lang/summernote-ru-RU.js` — невідоме походження — вирішити вручну
- `admin/view/javascript/summernote/lang/summernote-sk-SK.js` — невідоме походження — вирішити вручну
- `admin/view/javascript/summernote/lang/summernote-sr-RS-Latin.js` — невідоме походження — вирішити вручну
- `admin/view/javascript/summernote/lang/summernote-sr-RS.js` — невідоме походження — вирішити вручну
- `admin/view/javascript/summernote/lang/summernote-sv-SE.js` — невідоме походження — вирішити вручну
- `admin/view/javascript/summernote/lang/summernote-th-TH.js` — невідоме походження — вирішити вручну
- `admin/view/javascript/summernote/lang/summernote-tr-TR.js` — невідоме походження — вирішити вручну
- `admin/view/javascript/summernote/lang/summernote-uk-UA.js` — невідоме походження — вирішити вручну
- `admin/view/javascript/summernote/lang/summernote-vi-VN.js` — невідоме походження — вирішити вручну
- `admin/view/javascript/summernote/lang/summernote-zh-CN.js` — невідоме походження — вирішити вручну
- `admin/view/javascript/summernote/lang/summernote-zh-TW.js` — невідоме походження — вирішити вручну
- `catalog/controller/checkout/_checkout.php` — невідоме походження — вирішити вручну
- `catalog/controller/checkout/_confirm.php` — невідоме походження — вирішити вручну
- `catalog/controller/checkout/_failure.php` — невідоме походження — вирішити вручну
- `catalog/controller/checkout/_guest.php` — невідоме походження — вирішити вручну
- `catalog/controller/checkout/_guest_shipping.php` — невідоме походження — вирішити вручну
- `catalog/controller/checkout/_login.php` — невідоме походження — вирішити вручну
- `catalog/controller/checkout/_payment_address.php` — невідоме походження — вирішити вручну
- `catalog/controller/checkout/_payment_method.php` — невідоме походження — вирішити вручну
- `catalog/controller/checkout/_register.php` — невідоме походження — вирішити вручну
- `catalog/controller/checkout/_shipping_address.php` — невідоме походження — вирішити вручну
- `catalog/controller/checkout/_shipping_method.php` — невідоме походження — вирішити вручну
- `catalog/controller/checkout/order.php` — невідоме походження — вирішити вручну
- `catalog/controller/common/_column_left.php` — невідоме походження — вирішити вручну
- `catalog/controller/common/_column_right.php` — невідоме походження — вирішити вручну
- `catalog/controller/common/_currency.php` — невідоме походження — вирішити вручну
- `catalog/controller/common/_language.php` — невідоме походження — вирішити вручну
- `catalog/controller/common/_maintenance.php` — невідоме походження — вирішити вручну
- `catalog/controller/common/_search.php` — невідоме походження — вирішити вручну
- `catalog/controller/information/_contact.php` — невідоме походження — вирішити вручну
- `catalog/controller/information/_sitemap.php` — невідоме походження — вирішити вручну
- `catalog/controller/information/_tracking.php` — невідоме походження — вирішити вручну
- `catalog/controller/product/_compare.php` — невідоме походження — вирішити вручну
- `catalog/controller/product/_manufacturer.php` — невідоме походження — вирішити вручну
- `catalog/controller/product/_search.php` — невідоме походження — вирішити вручну
- `catalog/controller/product/_special.php` — невідоме походження — вирішити вручну
- `catalog/controller/startup/seo_url.php_original` — невідоме походження — вирішити вручну
- `catalog/language/en-gb/information/tracking.php` — невідоме походження — вирішити вручну
- `catalog/language/uk-ua/checkout/order.php` — мовний файл без відповідника в ядрі, але маршрут 'checkout/order' згадується в коді
- `catalog/language/uk-ua/extension/payment/pp_express.php` — мовний файл без відповідника в ядрі, але маршрут 'extension/payment/pp_express' згадується в коді
- `catalog/language/uk-ua/extension/payment/pp_pro.php` — мовний файл без відповідника в ядрі, але маршрут 'extension/payment/pp_pro' згадується в коді
- `catalog/language/uk-ua/extension/payment/pp_standard.php` — мовний файл без відповідника в ядрі, але маршрут 'extension/payment/pp_standard' згадується в коді
- `catalog/language/uk-ua/extension/recurring/pp_express.php` — мовний файл без відповідника в ядрі, але маршрут 'extension/recurring/pp_express' згадується в коді
- `catalog/language/uk-ua/information/tracking.php` — мовний файл без відповідника в ядрі, але маршрут 'information/tracking' згадується в коді
- `catalog/language/uk-ua/mail/order.php` — мовний файл без відповідника в ядрі, але маршрут 'mail/order' згадується в коді
- `system/library/db/mpdo.php` — невідоме походження — вирішити вручну
- `system/library/db/mssql.php` — невідоме походження — вирішити вручну
- `system/library/db/mysql.php` — невідоме походження — вирішити вручну
- `system/library/db/postgre.php` — невідоме походження — вирішити вручну
- `system/library/openbay.php` — невідоме походження — вирішити вручну
- `system/library/openbay/amazon.php` — невідоме походження — вирішити вручну
- `system/library/openbay/amazonus.php` — невідоме походження — вирішити вручну
- `system/library/openbay/ebay.php` — невідоме походження — вирішити вручну
- `system/library/openbay/etsy.php` — невідоме походження — вирішити вручну
- `system/library/openbay/fba.php` — невідоме походження — вирішити вручну

## 4. До видалення (REMOVE) — за причинами

- OCMOD tweak (рішення 2026-11-06) — 2
- Twig 1.x з 3.0.3.2 (у 3.0.4.1 — Twig 3 у storage/vendor) — 186
- ru-ru: мова не встановлена (в oc_language лише uk-ua) — 286
- вимкнена копія (тека з «_» на початку) — 86
- залишок видаленого стороннього модуля — 4
- мовний файл видаленого модуля (маршрут ніде не використовується) — 251
- службове сміття ОС/редакторів — 23
- файл ядра 3.0.3.2, видалений у 3.0.4.1 — 25

Повний список: `core-remove.txt` (переглянути; рядок можна видалити, щоб залишити файл).

## 5. Залишаються (KEEP) — за причинами

- Fondy (офіційний модуль провайдера) — 8
- Telegram-сповіщення (до 023) — 5
- мовний пакет uk-ua — 4
- переклад файлу ядра — 360
- службове хостингу (переглянути в 017) — 1
- тема sauco (до 003) — 119
- файл сайту/хостингу — 9
