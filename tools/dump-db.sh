#!/bin/bash
# ---------------------------------------------------------------------------
# Зняти дамп ЛОКАЛЬНОЇ бази.
#
# Навіщо: зберегти стан перед ризикованим експериментом (масове редагування
# опцій товарів, міграція, оновлення) — і мати куди відкотитись за секунду.
#
# Використання:
#   tools/dump-db.sh                 # у dumps/local-<дата>.sql.gz
#   tools/dump-db.sh --plain         # без стиснення (зручно гріпати)
#   tools/dump-db.sh --no-data       # лише структура
# ---------------------------------------------------------------------------

. "$(dirname "$0")/lib.sh"
load_env
require_running

PLAIN=0
NO_DATA=0
while [ $# -gt 0 ]; do
    case "$1" in
        --plain)   PLAIN=1 ;;
        --no-data) NO_DATA=1 ;;
        -h|--help) sed -n '2,14p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *)         die "Невідомий параметр: $1" ;;
    esac
    shift
done

if ! table_exists "${DB_PREFIX}setting"; then
    die "У базі '${DB_NAME}' немає таблиці ${DB_PREFIX}setting — нічого дампити."
fi

DUMPS_DIR="$PROJECT_ROOT/dumps"
mkdir -p "$DUMPS_DIR"
STAMP="$(date +%Y%m%d-%H%M%S)"
BASE="local-${STAMP}"

ARGS=(
    --single-transaction      # не блокувати таблиці під час дампу
    --quick                   # не тягнути весь результат у пам'ять
    --default-character-set=utf8mb4
    --no-tablespaces          # інакше потрібні права PROCESS, яких у нас немає
    --routines --triggers --events
)
# Застереження: --set-gtid-purged тут НЕ використовуємо. Це опція mysqldump із
# MySQL; mariadb-dump її не знає і падає з "unknown variable". MariaDB і так не
# додає GTID-інструкцій, якщо не передати --gtid.
[ "$NO_DATA" -eq 1 ] && ARGS+=(--no-data)

step "Дамп локальної бази '${DB_NAME}'"
if [ "$PLAIN" -eq 1 ]; then
    OUT="$DUMPS_DIR/${BASE}.sql"
    dc exec -T -e MYSQL_PWD="$DB_PASSWORD" db \
        mariadb-dump -u"$DB_USER" "${ARGS[@]}" "$DB_NAME" > "$OUT"
else
    OUT="$DUMPS_DIR/${BASE}.sql.gz"
    dc exec -T -e MYSQL_PWD="$DB_PASSWORD" db \
        mariadb-dump -u"$DB_USER" "${ARGS[@]}" "$DB_NAME" | gzip -1 > "$OUT"
fi

SIZE="$(du -h "$OUT" | cut -f1)"
ok "збережено: ${OUT}  (${SIZE})"
printf '\n'
info "Відкат до цього стану:"
printf '        tools/import-db.sh %s\n' "${OUT#"$PROJECT_ROOT"/}"
