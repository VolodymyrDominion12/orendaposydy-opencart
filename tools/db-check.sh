#!/bin/bash
# ---------------------------------------------------------------------------
# Аудит схеми БД: індекси, первинні ключі, рушії, кодування.
#
# Що шукає (лише таблиці з префіксом DB_PREFIX):
#   no_pk            таблиця без PRIMARY KEY
#   id_not_indexed   колонка *_id, яка не стоїть першою в жодному індексі
#                    (кандидат на JOIN/WHERE без індексу; частина — норма,
#                    напр. language_id другим у складеному PK)
#   redundant_index  неунікальний індекс, що є лівим префіксом іншого (або дублем)
#   not_innodb       рушій не InnoDB (ядро OpenCart 3 часто MyISAM)
#   not_utf8mb4      кодування таблиці не utf8mb4
#
# Базовий рівень (baseline): db/db-check.baseline.tsv — те, що вже є і прийнято.
# Скрипт падає (exit 1), лише якщо з'явилося НОВЕ зауваження. Так перевірка
# працює на старій базі з десятками історичних проблем.
#
# Використання:
#   tools/db-check.sh                 # перевірити проти baseline
#   tools/db-check.sh --update        # прийняти поточний стан як baseline
#   UPDATE=1 tools/db-check.sh        # те саме (для make db-check UPDATE=1)
# ---------------------------------------------------------------------------

. "$(dirname "$0")/lib.sh"
. "$(dirname "$0")/lib-quality.sh"
load_env
require_running

UPDATE_BASELINE="${UPDATE:-0}"
while [ $# -gt 0 ]; do
    case "$1" in
        --update)  UPDATE_BASELINE=1 ;;
        -h|--help) sed -n '2,23p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *)         die "Невідомий параметр: $1" ;;
    esac
    shift
done

BASELINE="$PROJECT_ROOT/db/db-check.baseline.tsv"
P="$DB_PREFIX"
L="${#DB_PREFIX}"

# Підзапит «колонки кожного індексу через кому» — використовується двічі.
IDX="SELECT table_name, index_name, MAX(non_unique) AS nu,
            GROUP_CONCAT(column_name ORDER BY seq_in_index SEPARATOR ',') AS cols
       FROM information_schema.statistics
      WHERE table_schema = DATABASE() AND LEFT(table_name, ${L}) = '${P}'
      GROUP BY table_name, index_name"

QUERY="
SELECT 'no_pk', t.table_name, '-'
  FROM information_schema.tables t
 WHERE t.table_schema = DATABASE() AND t.table_type = 'BASE TABLE'
   AND LEFT(t.table_name, ${L}) = '${P}'
   AND NOT EXISTS (SELECT 1 FROM information_schema.statistics s
                    WHERE s.table_schema = t.table_schema AND s.table_name = t.table_name
                      AND s.index_name = 'PRIMARY')
UNION ALL
SELECT 'id_not_indexed', c.table_name, c.column_name
  FROM information_schema.columns c
  JOIN information_schema.tables t
    ON t.table_schema = c.table_schema AND t.table_name = c.table_name AND t.table_type = 'BASE TABLE'
 WHERE c.table_schema = DATABASE() AND LEFT(c.table_name, ${L}) = '${P}'
   AND RIGHT(c.column_name, 3) = '_id'
   AND NOT EXISTS (SELECT 1 FROM information_schema.statistics s
                    WHERE s.table_schema = c.table_schema AND s.table_name = c.table_name
                      AND s.column_name = c.column_name AND s.seq_in_index = 1)
UNION ALL
SELECT 'redundant_index', a.table_name,
       CONCAT(a.index_name, '(', a.cols, ') covered by ', b.index_name, '(', b.cols, ')')
  FROM (${IDX}) a
  JOIN (${IDX}) b
    ON a.table_name = b.table_name AND a.index_name <> b.index_name
   AND LEFT(CONCAT(b.cols, ','), LENGTH(a.cols) + 1) = CONCAT(a.cols, ',')
 WHERE a.index_name <> 'PRIMARY' AND a.nu = 1
UNION ALL
SELECT 'not_innodb', table_name, IFNULL(engine, '-')
  FROM information_schema.tables
 WHERE table_schema = DATABASE() AND table_type = 'BASE TABLE'
   AND LEFT(table_name, ${L}) = '${P}' AND IFNULL(engine, '') <> 'InnoDB'
UNION ALL
SELECT 'not_utf8mb4', table_name, IFNULL(table_collation, '-')
  FROM information_schema.tables
 WHERE table_schema = DATABASE() AND table_type = 'BASE TABLE'
   AND LEFT(table_name, ${L}) = '${P}' AND IFNULL(table_collation, '') NOT LIKE 'utf8mb4%'
"

TMP="$(mktemp)"; trap 'rm -f "$TMP" "$TMP.new"' EXIT

step "Аудит схеми '${DB_NAME}' (префікс ${DB_PREFIX})"
sql -N -B -e "$QUERY" | tr -d '\r' | LC_ALL=C sort -u > "$TMP" \
    || die "Запит аудиту впав — дивіться помилку SQL вище"

# --- Зведення ---------------------------------------------------------------
for kind in no_pk id_not_indexed redundant_index not_innodb not_utf8mb4; do
    n="$(grep -c "^${kind}	" "$TMP" || true)"
    printf '  %-16s %s\n' "$kind" "$n"
done

info "Найбільші таблиці (дані + індекси):"
sql -B -e "SELECT table_name AS 'таблиця', table_rows AS 'рядків (≈)',
                  ROUND(data_length/1024/1024, 2) AS 'дані, МБ',
                  ROUND(index_length/1024/1024, 2) AS 'індекси, МБ', engine
             FROM information_schema.tables
            WHERE table_schema = DATABASE() AND LEFT(table_name, ${L}) = '${P}'
            ORDER BY data_length + index_length DESC LIMIT 10;" | tr -d '\r' | fmt_tsv

# --- Baseline ---------------------------------------------------------------
if [ "$UPDATE_BASELINE" = "1" ]; then
    mkdir -p "$(dirname "$BASELINE")"
    cp "$TMP" "$BASELINE"
    ok "Baseline оновлено: db/db-check.baseline.tsv ($(wc -l < "$BASELINE") рядків). Закомітьте його."
    exit 0
fi

if [ ! -f "$BASELINE" ]; then
    warn "Baseline ще немає. Перегляньте зауваження нижче й прийміть поточний стан:  make db-check UPDATE=1"
    fmt_tsv < "$TMP"
    exit 0
fi

LC_ALL=C comm -13 "$BASELINE" "$TMP" > "$TMP.new"
GONE="$(LC_ALL=C comm -23 "$BASELINE" "$TMP" | wc -l)"

if [ -s "$TMP.new" ]; then
    err "НОВІ зауваження порівняно з baseline ($(wc -l < "$TMP.new")):"
    fmt_tsv < "$TMP.new" >&2
    printf '\n  Виправте міграцією (індекс/PK) або, якщо це свідомо, поясніть у plan.md\n  і прийміть:  make db-check UPDATE=1\n' >&2
    exit 1
fi

ok "Нових зауважень немає"
[ "$GONE" -gt 0 ] && info "Зникло зауважень: ${GONE} — оновіть baseline: make db-check UPDATE=1"
exit 0
