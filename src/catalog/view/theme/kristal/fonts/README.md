# Шрифти теми kristal

| Файл | Родина | Накреслення | Ліцензія |
|---|---|---|---|
| `forum.woff2` | Forum (Denis Masharov) | 400 | SIL Open Font License 1.1 |
| `manrope.woff2` | Manrope (Mikhail Sharanda) | змінний 400–700 | SIL Open Font License 1.1 |
| `jetbrains-mono.woff2` | JetBrains Mono (JetBrains) | змінний 500–600 | SIL Open Font License 1.1 |

Джерело — Google Fonts (`fonts.googleapis.com/css2?…&text=…`), підмножина символів: ASCII, українська абетка (+ ё ы э ъ),
`₴ × – — · • № « » ‘ ’ “ ” „ … ° ½ © ® ™ → ← ↑ ↓` і нерозривний пробіл. Разом 94 КБ (бюджет шрифтів — 120 КБ).

У Forum і JetBrains Mono немає гліфа «₴» — у `kristal.css` стеки `--font-display` і `--font-mono` мають Manrope наступним, браузер бере «₴» з нього.
Потрібні нові символи (напр. польська абетка) — перезавантажити з ширшим `text=` і перевірити вагу (`make test-mobile`).
Текст ліцензії OFL: https://openfontlicense.org
