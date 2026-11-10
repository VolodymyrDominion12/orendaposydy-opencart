# 006 — План реалізації посадкових сторінок подій

## Архітектура
1. **Контролер `ControllerExtensionKristalKit`**:
   - Розширити метод `event()` підтримкою параметрів:
     - `wedding` (Весілля) -> `/vesillya`
     - `buffet` (Фуршет і кава-брейк) -> `/furshet`
     - `catering` (Кейтеринг) -> `/keiterynh`
     - `corporate` (Корпоратив) -> `/korporatyv`
   - Методи-аліаси:
     - `wedding()`
     - `buffet()`
     - `catering()`
     - `corporate()`
   - Локалізація та контент для кожного типу:
     - Заголовки, мета-описи, бейджи, факти hero.
     - Тематичні додаткові послуги/товари (столи, стільці, марміти, кавомашини, термопоти, шатри).
     - Блок тематичного FAQ з генеруванням `FAQPage` JSON-LD.
2. **База даних та комплекти**:
   - Міграція `0022_kristal_event_pages.up.sql`:
     - Створення комплектів для `buffet`, `catering`, `corporate` в `oc_kristal_kit` та `oc_kristal_kit_item`.
     - Додавання записів ЧПУ в `oc_seo_url`:
       - `extension/kristal/kit/wedding` -> `vesillya`
       - `extension/kristal/kit/buffet` -> `furshet`
       - `extension/kristal/kit/catering` -> `keiterynh`
       - `extension/kristal/kit/corporate` -> `korporatyv`
3. **Шаблони та стилі**:
   - `src/catalog/view/theme/kristal/template/extension/kristal/event.twig`:
     - Підтримка FAQ акордеону та Schema.org розмітки.
4. **Тестування**:
   - Smoke-тести для всіх 4 URL (`/vesillya`, `/furshet`, `/keiterynh`, `/korporatyv`).
   - Перевірка пакетного додавання в кошик.
   - `make lint ALL=1`, `make test-smoke`, `make test-lib`.
