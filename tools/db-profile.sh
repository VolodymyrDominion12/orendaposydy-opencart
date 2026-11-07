#!/bin/bash
# ---------------------------------------------------------------------------
# Профіль запитів до БД для однієї сторінки вітрини.
#
# Вмикає на час одного запиту slow log з long_query_time=0 (логуються ВСІ
# запити), відкриває сторінку, вимикає лог і показує:
#   * скільки запитів зробила сторінка і сумарний час;
#   * топ найповільніших запитів;
#   * топ найчастіших (нормалізованих) запитів — тут видно N+1;
#   * топ за Rows_examined — тут видно повні перегляди.
#
# Використання:
#   tools/db-profile.sh /mebli
#   URL=/mebli tools/db-profile.sh                # make db-profile URL=/mebli
#   BUDGET=100 MAXMS=50  — бюджет: кількість запитів і найповільніший, мс
#   COLD=1               — без «прогріву» (типово сторінку спершу відкриваємо
#                          один раз, щоб заповнити кеш OpenCart)
#   BASE=http://localhost:8090 — інша адреса вітрини
#
# Потрібен DB_ROOT_PASSWORD у .env (SET GLOBAL вимагає прав root).
# Тільки для локального середовища.
# ---------------------------------------------------------------------------

. "$(dirname "$0")/lib.sh"
load_env
require_running

case "${1:-}" in -h|--help) sed -n '2,23p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;; esac

PAGE="${1:-${URL:-}}"
[ -n "$PAGE" ] || die "Вкажіть сторінку: make db-profile URL=/mebli"
case "$PAGE" in http*) FULL="$PAGE" ;; *) FULL="${BASE:-http://localhost:${WEB_PORT}}${PAGE}" ;; esac
BUDGET="${BUDGET:-100}"
MAXMS="${MAXMS:-50}"
: "${DB_ROOT_PASSWORD:?DB_ROOT_PASSWORD не задано в .env — потрібен для SET GLOBAL}"

LOG=/var/lib/mysql/kristal-profile.log
sql_root() {
    dc exec -T -e MYSQL_PWD="$DB_ROOT_PASSWORD" db mysql -uroot -N -B -e "$1"
}

restore() {
    sql_root "SET GLOBAL slow_query_log = 0; SET GLOBAL long_query_time = 10;" >/dev/null 2>&1 || true
}
trap restore EXIT

if [ "${COLD:-0}" != "1" ]; then
    curl -s -o /dev/null --max-time 30 "$FULL" || true
fi

sql_root "SET GLOBAL slow_query_log = 0;
          SET GLOBAL slow_query_log_file = '${LOG}';
          SET GLOBAL long_query_time = 0;
          SET GLOBAL log_slow_verbosity = 'query_plan';" >/dev/null \
    || die "Не вдалося налаштувати slow log (перевірте DB_ROOT_PASSWORD)"
# Файл має належати mysql: `docker exec` за замовчуванням працює від root, і тоді
# mysqld не може відкрити журнал (ERROR 29 … Errcode: 13 Permission denied).
dc exec -T db rm -f "${LOG}"
dc exec -T -u mysql db sh -c ": > '${LOG}'"
sql_root "FLUSH SLOW LOGS; SET GLOBAL slow_query_log = 1;" >/dev/null

RESP="$(curl -s -o /dev/null -w '%{http_code} %{time_total}' --max-time 60 "$FULL" || echo '000 0')"
sleep 0.5
restore

RAW="$(mktemp)"; REC="$(mktemp)"; trap 'restore; rm -f "$RAW" "$REC"' EXIT
dc exec -T db cat "$LOG" | tr -d '\r' > "$RAW"

# Розбір slow log MariaDB → TSV: час_мс \t rows_examined \t нормалізований \t сирий
awk -v user="$DB_USER" -v sq="'" '
    function flush() {
        if (qt != "" && u == user && q != "") {
            n = q; gsub(sq "[^" sq "]*" sq, "?", n); gsub(/"[^"]*"/, "?", n)
            gsub(/[0-9]+(\.[0-9]+)?/, "N", n); gsub(/\( *(N|\?)( *, *(N|\?))* *\)/, "(…)", n)
            gsub(/[[:space:]]+/, " ", n); gsub(/[[:space:]]+/, " ", q)
            printf "%.3f\t%d\t%s\t%s\n", qt * 1000, re, n, q
        }
        qt = ""; q = ""; re = 0
    }
    /^# User@Host:/ { flush(); u = $3; sub(/\[.*/, "", u); next }
    /^# Time:/      { flush(); next }
    /^# Query_time:/ {
        for (i = 1; i <= NF; i++) { if ($i == "Query_time:") qt = $(i+1); if ($i == "Rows_examined:") re = $(i+1) }
        next
    }
    /^#/ { next }
    /^SET timestamp=/ || /^use / || /^\/usr\// || /^Tcp port:/ || /^Time[[:space:]]+Id/ { next }
    { if (qt != "") q = q " " $0 }
    END { flush() }
' "$RAW" > "$REC"

COUNT="$(wc -l < "$REC" | tr -d ' ')"
read -r CODE TTOTAL <<< "$RESP"
TOTAL_MS="$(awk -F'\t' '{s += $1} END {printf "%.1f", s}' "$REC")"
MAX_MS="$(awk -F'\t' 'BEGIN{m=0} {if ($1 > m) m = $1} END {printf "%.1f", m}' "$REC")"

# Далі лише звіт: `sort | head` дає SIGPIPE (код 141), а з pipefail це обривало скрипт
# після першого розділу.
set +o pipefail

step "Профіль: $FULL"
printf '  HTTP %s за %s с\n' "$CODE" "$TTOTAL"
printf '  Запитів до БД: %s   сумарно: %s мс   найповільніший: %s мс\n' "$COUNT" "$TOTAL_MS" "$MAX_MS"

info "Найповільніші (мс):"
sort -t$'\t' -k1,1 -g -r "$REC" | head -10 | awk -F'\t' '{printf "    %8.2f  %s\n", $1, substr($4, 1, 140)}'

info "Найчастіші (кількість × шаблон) — десятки повторів = N+1:"
cut -f3 "$REC" | sort | uniq -c | sort -rn | head -10 | awk '{c=$1; $1=""; printf "    %6d ×%s\n", c, substr($0, 1, 140)}'

info "Найбільше переглянутих рядків (Rows_examined):"
sort -t$'\t' -k2,2 -n -r "$REC" | head -5 | awk -F'\t' '{printf "    %8d  %s\n", $2, substr($4, 1, 140)}'

printf '\n'
FAIL=0
[ "$CODE" = "200" ] || { warn "Сторінка повернула HTTP $CODE"; }
if [ "$COUNT" -gt "$BUDGET" ]; then err "Запитів $COUNT > бюджету $BUDGET"; FAIL=1; fi
if awk -v a="$MAX_MS" -v b="$MAXMS" 'BEGIN{exit !(a > b)}'; then err "Найповільніший ${MAX_MS} мс > ${MAXMS} мс"; FAIL=1; fi
[ "$FAIL" -eq 0 ] && ok "У бюджеті (≤ $BUDGET запитів, ≤ $MAXMS мс). Запишіть цифри в tasks.md фічі."
exit "$FAIL"
