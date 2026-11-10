# 002 — План реалізації

Специфікація: `spec.md`.

## Архітектурний підхід
1. **Спільна бібліотека `Kristal\Redirect` (`src/system/library/kristal/redirect.php`)**:
   - `normalize($path)`: приводить шлях до нормалізованого вигляду (початковий `/`, без зайвих слешів, нижній регістр).
   - `getRules($db, $cache)`: повертає масив активних правил `['/old-path' => ['new_path' => '/new-path', 'code' => 301, 'id' => 1]]` з кешу `kristal.redirects`.
   - `recordHit($db, $redirect_id)`: оновлює лічильник переходів.
   - `log404($db, $path, $referer)`: оновлює або вставляє запис у `kristal_404_log`.
   - Тести: `tests/lib/redirect_test.php`.

2. **Точка перехоплення запитів**:
   - Подія `controller/error/not_found/before` (або `catalog/controller/error/not_found/before`):
     Коли OpenCart визначає, що сторінку не знайдено (404), викликається `extension/kristal/redirect/check`.
     Якщо нормалізований шлях є в правилах редиректів:
     - збільшується лічильник хітів,
     - надсилається заголовок `Location: $new_url` та HTTP $code (301 або 302),
     - завершується робота скрипту `exit()`.
     Якщо правила немає:
     - запит логується в `kristal_404_log` (якщо це не системний файл або розширення типу `.png`, `.map`).

3. **База даних**:
   - `db/migrations/0021_kristal_redirect.up.sql` та `.down.sql`:
     - таблиці `oc_kristal_redirect` та `oc_kristal_404_log`.
     - подія `kristal_redirect_check` на `catalog/controller/error/not_found/before`.
     - початкові 301-правила зі старої структури сайту (концепція § "URL і 301-редиректи").

4. **Адмінка**:
   - Модуль `extension/module/kristal_redirect`:
     - Список правил редиректів, додавання нового, видалення.
     - Перегляд журналу 404 помилок, можливість створення 301 в один клік, очищення журналу.

## Файли
| Файл | Статус | Призначення |
|---|---|---|
| `src/system/library/kristal/redirect.php` | Новий | Бібліотека нормалізації, пошуку та логування 404 |
| `tests/lib/redirect_test.php` | Новий | Юніт-тести бібліотеки |
| `src/catalog/controller/extension/kristal/redirect.php` | Новий | Контролер перехоплення 404 та виконання редиректу |
| `src/admin/controller/extension/module/kristal_redirect.php` | Новий | Адмінка: керування 301 та перегляд 404 |
| `src/admin/model/extension/kristal/redirect.php` | Новий | Модель адмінки для CRUD правил та 404 |
| `src/admin/view/template/extension/module/kristal_redirect.twig` | Новий | Шаблон інтерфейсу в адмінці |
| `src/admin/language/uk-ua/extension/module/kristal_redirect.php` | Новий | Мовний файл адмінки |
| `db/migrations/0021_kristal_redirect.up.sql` | Новий | Таблиці, подія, базові 301 |
| `db/migrations/0021_kristal_redirect.down.sql` | Новий | Відкат |
| `tests/smoke/redirects.txt` | Зміна | Додавання 301 старих категорій |
| `tests/smoke/urls.txt` | Зміна | Оновлення очікувань 404 на 301 |
