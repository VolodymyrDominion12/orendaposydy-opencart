#!/bin/bash
# ---------------------------------------------------------------------------
# Знімок схеми БД у db/schema.sql і порівняння з ним.
#
# Навіщо: будь-яка зміна схеми має бути видна в git-дифі. Якщо `diff` показує
# зміни, яких немає в міграціях — хтось змінив базу руками (або модуль із
# адмінки створив таблицю). Це треба помітити до деплою.
#
# Використання:
#   tools/db-schema.sh snapshot   # записати поточну схему в db/schema.sql
#   tools/db-schema.sh diff       # показати різницю; exit 1, якщо вона є
# ---------------------------------------------------------------------------

. "$(dirname "$0")/lib.sh"
load_env
require_running

MODE="${1:-diff}"
SNAP="$PROJECT_ROOT/db/schema.sql"

dump_schema() {
    # mariadb-dump у нових образах, mysqldump — у старих
    dc exec -T -e MYSQL_PWD="$DB_PASSWORD" db sh -c '
        BIN="$(command -v mariadb-dump || command -v mysqldump)"
        "$BIN" --no-data --skip-comments --skip-dump-date --skip-triggers \
               --skip-add-drop-table --single-transaction \
               --default-character-set=utf8mb4 -u"$0" "$1"' "$DB_USER" "$DB_NAME" \
    | tr -d '\r' \
    | sed -E 's/ AUTO_INCREMENT=[0-9]+//' \
    | grep -v '^/\*!40' | grep -v '^SET ' | grep -v '^$' || true
}

case "$MODE" in
    snapshot)
        mkdir -p "$(dirname "$SNAP")"
        dump_schema > "$SNAP.tmp"
        [ -s "$SNAP.tmp" ] || { rm -f "$SNAP.tmp"; die "Порожній дамп схеми — дивіться помилку вище"; }
        mv "$SNAP.tmp" "$SNAP"
        ok "Схему записано: db/schema.sql ($(grep -c '^CREATE TABLE' "$SNAP") таблиць). Закомітьте разом із міграцією."
        ;;
    diff)
        if [ ! -f "$SNAP" ]; then
            warn "Знімка схеми ще немає. Створіть його:  make db-schema-snapshot"
            exit 0
        fi
        TMP="$(mktemp)"; trap 'rm -f "$TMP"' EXIT
        dump_schema > "$TMP"
        if diff -u --label "db/schema.sql (знімок)" --label "поточна база" "$SNAP" "$TMP"; then
            ok "Схема збігається зі знімком db/schema.sql"
        else
            printf '\n'
            err "Схема відрізняється від знімка."
            printf '  Якщо зміни з вашої міграції: пройдіть docs/agents/db-schema-checklist.md,\n  потім make db-schema-snapshot і закомітьте db/schema.sql.\n  Якщо зміни невідомого походження — з'"'"'ясуйте, звідки вони, до деплою.\n' >&2
            exit 1
        fi
        ;;
    -h|--help) sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//' ;;
    *) die "Невідомий режим: $MODE (snapshot | diff)" ;;
esac
