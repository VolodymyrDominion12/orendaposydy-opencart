# db/

| Файл | Що |
|---|---|
| `migrations/NNNN_slug.up.sql` / `.down.sql` | міграції; застосовуються `make migrate`, відкат `make migrate-down V=NNNN` |
| `migrations/_template.*.sql` | шаблони для `make migrate-new NAME=slug` |
| `schema.sql` | знімок схеми (`make db-schema-snapshot`), оновлюється в тому ж комміті, що й міграція |
| `db-check.baseline.tsv` | прийняті історичні зауваження аудиту (`make db-check UPDATE=1`) |

Застосовані версії — у таблиці `oc_kristal_migration`.
На прод: `make migrate-print V=NNNN > /tmp/m.sql` → бекап → phpMyAdmin (`make deploy-sql SQL=/tmp/m.sql`).
Мок-міграції (`*mock*`) на прод не друкуються.

Правила — `AGENTS.md` §4 і `docs/agents/db-schema-checklist.md`.

## Перший запуск після імпорту дампа
```bash
make db-check            # подивитись історичні зауваження
make db-check UPDATE=1   # прийняти їх як baseline
make db-schema-snapshot  # перший знімок схеми
make migrate-status
make mobile-setup        # Playwright + Chromium для make test-mobile (один раз)
make test-mobile         # стартовий мобільний рівень теми sauco
git add db/ && git commit -m "000: baseline схеми та аудиту"
```
