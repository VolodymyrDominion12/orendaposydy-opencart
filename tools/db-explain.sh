#!/bin/bash
# ---------------------------------------------------------------------------
# EXPLAIN для запитів із підсвіткою проблем.
#
# Використання:
#   tools/db-explain.sh "SELECT ... FROM {{PREFIX}}product WHERE ..."
#   SQL="SELECT ..." tools/db-explain.sh          # make db-explain SQL="..."
#   FILE=specs/005-x/queries.sql tools/db-explain.sh   # кілька запитів через ';'
#   ROWS_LIMIT=1000 — поріг «великої» таблиці (типово 1000 рядків)
#
# {{PREFIX}} замінюється на DB_PREFIX. Підтримуються SELECT / UPDATE / DELETE
# (MariaDB вміє EXPLAIN для всіх трьох; дані НЕ змінюються).
#
# Що вважається:
#   ПОМИЛКА      type=ALL (повний перегляд) на таблиці з rows > ROWS_LIMIT
#   ПОПЕРЕДЖЕННЯ key=NULL при rows > ROWS_LIMIT, Using filesort, Using temporary
# exit 1, якщо є хоч одна ПОМИЛКА.
# ---------------------------------------------------------------------------

. "$(dirname "$0")/lib.sh"
. "$(dirname "$0")/lib-quality.sh"
load_env
require_running

ROWS_LIMIT="${ROWS_LIMIT:-1000}"
INPUT=""
if [ $# -gt 0 ] && [ "$1" != "-h" ] && [ "$1" != "--help" ]; then
    INPUT="$*"
elif [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    sed -n '2,19p' "$0" | sed 's/^# \{0,1\}//'; exit 0
elif [ -n "${FILE:-}" ]; then
    [ -f "$FILE" ] || [ -f "$PROJECT_ROOT/$FILE" ] || die "Немає файлу $FILE"
    [ -f "$FILE" ] || FILE="$PROJECT_ROOT/$FILE"
    INPUT="$(cat "$FILE")"
elif [ -n "${SQL:-}" ]; then
    INPUT="$SQL"
else
    die "Передайте запит: make db-explain SQL=\"SELECT ...\"  або  FILE=шлях.sql"
fi

INPUT="${INPUT//\{\{PREFIX\}\}/$DB_PREFIX}"

ERRORS=0; WARNS=0; N=0
# Розбиваємо на окремі запити по ';' (рядкові літерали з ';' не підтримуються).
while IFS= read -r -d ';' stmt || [ -n "$stmt" ]; do
    # прибрати коментарі «-- ...» і зайві пробіли
    stmt="$(printf '%s\n' "$stmt" | sed -E 's/--.*$//' | tr '\n' ' ' | sed -E 's/[[:space:]]+/ /g; s/^ //; s/ $//')"
    [ -n "$stmt" ] || continue
    case "$(printf '%s' "$stmt" | tr '[:lower:]' '[:upper:]')" in
        SELECT*|UPDATE*|DELETE*|WITH*) ;;
        *) info "пропускаю (не SELECT/UPDATE/DELETE): ${stmt:0:60}…"; continue ;;
    esac
    N=$((N + 1))
    step "[$N] ${stmt:0:150}$([ ${#stmt} -gt 150 ] && echo …)"

    OUT="$(sql -B -e "EXPLAIN $stmt" 2>&1 | tr -d '\r')" || { err "$OUT"; ERRORS=$((ERRORS + 1)); continue; }
    printf '%s\n' "$OUT" | fmt_tsv

    # Аналіз: знаходимо колонки за назвами в заголовку
    RES="$(printf '%s\n' "$OUT" | awk -F'\t' -v lim="$ROWS_LIMIT" '
        NR == 1 { for (i = 1; i <= NF; i++) col[$i] = i; next }
        {
            t = $(col["table"]); ty = $(col["type"]); k = $(col["key"]);
            r = $(col["rows"]) + 0; ex = $(col["Extra"]);
            if (ty == "ALL" && r > lim)       print "E\t" t ": повний перегляд (type=ALL), rows≈" r " — потрібен індекс";
            else if (k == "NULL" && r > lim)  print "W\t" t ": індекс не використано (key=NULL), rows≈" r;
            if (ex ~ /Using filesort/)        print "W\t" t ": Using filesort — сортування без індексу";
            if (ex ~ /Using temporary/)       print "W\t" t ": Using temporary — тимчасова таблиця (GROUP BY/DISTINCT)";
        }')"
    if [ -z "$RES" ]; then
        ok "план без зауважень"
    else
        while IFS=$'\t' read -r lvl msg; do
            if [ "$lvl" = "E" ]; then err "$msg"; ERRORS=$((ERRORS + 1)); else warn "$msg"; WARNS=$((WARNS + 1)); fi
        done <<< "$RES"
    fi
done <<< "$INPUT"

printf '\n'
[ "$N" -gt 0 ] || die "Не знайдено жодного SELECT/UPDATE/DELETE"
if [ "$ERRORS" -gt 0 ]; then
    err "Запитів: $N, помилок: $ERRORS, попереджень: $WARNS"
    exit 1
fi
ok "Запитів: $N, помилок: 0, попереджень: $WARNS (кожне попередження — пояснити в plan.md або виправити)"
