# Перевірка сайту orendaposudu.com — 2026-11-11 12:20

## Мобільна версія — ОК

Playwright, 360×640 (Android), 390×844 (iPhone), 768×1024 (планшет), емуляція touch.

| Показник | 360 | 390 | 768 |
|---|---|---|---|
| Горизонтальний скрол | 0 | 0 | 0 |
| Текст < 12 px | 0 | 0 | 0 |
| Битих зображень | 0 | 0 | 0 |
| Помилок JS / запитів | 0 | 0 | 0 |
| Нижня панель | 4×90×60 | 4×98×60 | 4×192×60 |
| Меню (шторка) | відкривається, скрол блокується, Esc закриває | те саме | те саме |
| Фільтри | шторка відкривається, скрол блокується | те саме | те саме |

Сторінки: `/`, `/posud/tarilky`, картка товару, `/mebli`, `/order`, `/vesillya`,
`/dostavka-ta-oplata`, `/kontakty` — усі 200. На 1280/1440 нижньої панелі немає,
горизонтального скролу немає, один `h1`.

Дрібні зауваження: інлайн-посилання (email, «Детальні умови», політика
конфіденційності, телефон у контактах) мають висоту 21–38 px — менше 44 px.
Це не кнопки, але на телефоні краще збільшити відступ.

## Посилання

- Обхід 220 сторінок із головної: **0 помилок HTTP** (усі 200/301).
- 24 унікальні ресурси (CSS/JS/шрифти/логотип) з урахуванням `<base href>`: **0 битих**.
- `/robots.txt` — 200; `/sitemap.xml` — 200, валідний XML (136 `<loc>`, разом з image:loc).
- 404: `/neisnuyucha-storinka-123` → 404, тема, `noindex, follow`, один `h1`.
- Пошук `/poshuk?q=тарілка` — 200, 4 картки; підказки `suggest` — JSON, 4 items.
- Старі адреси категорій: `/salati` → 301 `/stolovi-prybory`, `/orenda-dekoru` → 301 `/dekor`,
  `/orenda-prokat-mebliv` → 301 `/mebli`.

### Проблеми з посиланнями

1. **Старі короткі адреси категорій — 404** (були в старому sitemap, можуть бути в Google):
   `/bilij-posud`, `/stakani`, `/supnici`, `/salatnici`, `/videlka`, `/lozhki`,
   `/ditichnij-kompleksu`, `/derev-yani-doshki`, `/inventar-ta-posud-z-plastiku`,
   `/m-yasni-stravi`, `/ovochevi-salati`. Повні старі шляхи (`/salati/bilij-posud`) — 301, а короткі — ні.
   Лікування: додати 301 у `oc_kristal_redirect` (SQL).
2. **`canonical` підкатегорій без батьківського шляху**: `/posud/tarilky` → canonical `/tarilky`,
   `/stolovi-prybory/vydelky` → `/vydelky` тощо (20+ сторінок). Ядро `product/category.php`
   будує canonical за останнім `category_id`. Треба виправити в темі/OCMOD.

## Критично: кошик і форма не працюють на проді

POST на `index.php?route=checkout/cart/add` і `index.php?route=extension/kristal/lead/submit`
віддає **301** на `/?route=...`; браузер іде GET-ом, тіло POST губиться.
Наслідки: кнопка **«До події»** не додає товар, форма **«Отримати розрахунок»**
не надсилає заявку. Локально (Apache) POST працює; на проді (LiteSpeed) — ні.

Перевірено:
- `POST /index.php?route=checkout/cart/add` → 301; `POST /?route=checkout/cart/add` → 200, товар у кошику.
- `POST /index.php?route=extension/kristal/lead/submit` → 301; `POST /?route=...` → 200 JSON.
- Локально обидва POST на `index.php?route=` — 200.

Лікування (файли теми, після деплою):
- `catalog/view/theme/kristal/js/kristal.js`: `fetch('index.php?route=checkout/cart/add')` → `fetch('/?route=checkout/cart/add')`.
- `catalog/view/theme/kristal/js/kristal-lead.js`: нормалізувати action `index.php?route=...` → `/?route=...`.
- (або додати SEO-адреси для цих маршрутів і будувати URL через `url->link`).

## Критично: інформаційні сторінки показують головну

`/pro-nas`, `/dostavka-ta-oplata`, `/politika-konfidencijnosti`, `/dlia-biznesu`,
`/faq`, `/nashi-partneri` віддають 200, але це **головна сторінка** (той самий `h1`,
`title` «Оренда посуду у Львові…», canonical `/`). Тому посилання у футері
«Про нас», «Доставка», «Політика», «Для бізнесу», «FAQ», «Наші партнери» ведуть на головну.

Причина — `catalog/controller/startup/seo_url.php`, гілка:
```php
} elseif (isset($this->request->get['information_id'])) {
    $this->request->get['information_id'] = $url[1];   // не виставляє route
}
```
Треба `$this->request->get['route'] = 'information/information';`.
Перевірено локально: після правки всі сторінки відкриваються з правильними `title`/`h1`.

## SEO / інше

- `sitemap.xml` містить інформаційні сторінки, які зараз віддають головну (дублі).
- Дочірні категорії в sitemap відсутні (лише 11 верхніх).
- На проді `.htaccess` старіший за репозиторій: немає блоку 016 (gzip/Expires) і
  `sitemap.xml` іде на `extension/feed/google_sitemap`, а не на `extension/kristal/seo/sitemap`.
- 5 категорій без товарів (Кухонне, Барне, Меблі, Текстиль, Шатри) — навмисно.
- Ціни/цифри/FAQ — заглушки, клієнт має замінити.

## Що виправляти першим

1. Кошик + форма (JS, 2 файли) — без цього сайт не приймає замовлення.
2. Інформаційні сторінки (`seo_url.php`, 1 рядок) — футерні посилання.
3. 301 зі старих коротких адрес (SQL).
4. canonical підкатегорій і sitemap (тема/OCMOD) — окремим кроком.
