#!/bin/bash
# ---------------------------------------------------------------------------
# Міграції БД: db/migrations/NNNN_slug.up.sql + NNNN_slug.down.sql
#
# Застосовані версії записуються в {{PREFIX}}kristal_migration (version,
# name, checksum, applied_at). Плейсхолдер {{PREFIX}} у файлах замінюється
# на DB_PREFIX.
#
# Команди:
#   tools/migrate.sh status            # що застосовано, що очікує, змінені файли
#   tools/migrate.sh up                # застосувати всі очікувані по черзі
#   tools/migrate.sh up NNNN           # застосувати очікувані до NNNN включно
#   tools/migrate.sh down NNNN         # відкотити NNNN (лише останню; FORCE=1 — будь-яку)
#   tools/migrate.sh print NNNN        # SQL для phpMyAdmin на прод (у stdout)
#   tools/migrate.sh new slug          # створити пару файлів із шаблону
#
# Мок-міграції (у назві є "mock") `print` відмовляється друкувати без
# ALLOW_MOCK=1 — мок-дані не повинні потрапити на прод.
# ---------------------------------------------------------------------------

. "$(dirname "$0")/lib.sh"

DIR="$PROJECT_ROOT/db/migrations"
CMD="${1:-status}"
ARG="${2:-${V:-}}"

case "$CMD" in -h|--help|help) sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;; esac

# Два файли з одним номером — гарантована плутанина (напр. дві гілки
# створили 0003 паралельно). Зупиняємось до будь-яких дій.
if [ -d "$DIR" ]; then
    DUP="$(find "$DIR" -maxdepth 1 -name '[0-9][0-9][0-9][0-9]_*.up.sql' -printf '%f\n' 2>/dev/null \
           | cut -c1-4 | sort | uniq -d | tr '\n' ' ')"
    [ -z "$DUP" ] || die "Кілька міграцій з однаковим номером: ${DUP}— перенумеруйте (ще не застосовану)"
fi

checksum() { (sha1sum "$1" 2>/dev/null || shasum "$1") | cut -d' ' -f1; }

# Список версій у теці: "NNNN<TAB>slug"
list_files() {
    [ -d "$DIR" ] || return 0
    find "$DIR" -maxdepth 1 -name '[0-9][0-9][0-9][0-9]_*.up.sql' -printf '%f\n' 2>/dev/null \
        | sed -E 's/^([0-9]{4})_(.*)\.up\.sql$/\1\t\2/' | sort
}
file_up()   { echo "$DIR/$1_$2.up.sql"; }
file_down() { echo "$DIR/$1_$2.down.sql"; }
slug_of()   { list_files | awk -F'\t' -v v="$1" '$1 == v {print $2}'; }

TRACK_DDL="CREATE TABLE IF NOT EXISTS \`{{PREFIX}}kristal_migration\` (
  \`version\`    VARCHAR(16)  NOT NULL,
  \`name\`       VARCHAR(255) NOT NULL,
  \`checksum\`   CHAR(40)     NOT NULL,
  \`applied_at\` DATETIME     NOT NULL,
  PRIMARY KEY (\`version\`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;"

# --- new і print не потребують запущеної бази -------------------------------
if [ "$CMD" = "new" ]; then
    [ -n "$ARG" ] || die "Вкажіть назву: make migrate-new NAME=kristal_redirect_table"
    slug="$(printf '%s' "$ARG" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/_/g; s/^_|_$//g')"
    last="$(list_files | tail -1 | cut -f1)"
    next="$(printf '%04d' $((10#${last:-0} + 1)))"
    mkdir -p "$DIR"
    for kind in up down; do
        f="$DIR/${next}_${slug}.${kind}.sql"
        sed -e "s/{{VERSION}}/${next}/g" -e "s/{{SLUG}}/${slug}/g" "$DIR/_template.${kind}.sql" > "$f"
        info "створено ${f#$PROJECT_ROOT/}"
    done
    ok "Заповніть файли й пройдіть docs/agents/db-schema-checklist.md"
    exit 0
fi

load_env

if [ "$CMD" = "print" ]; then
    [ -n "$ARG" ] || die "Вкажіть версію: make migrate-print V=0002"
    slug="$(slug_of "$ARG")"; [ -n "$slug" ] || die "Немає міграції $ARG у db/migrations/"
    if [[ "$slug" == *mock* ]] && [ "${ALLOW_MOCK:-0}" != "1" ]; then
        die "Міграція ${ARG}_${slug} — мок-дані. На прод не друкую (ALLOW_MOCK=1, якщо справді треба)."
    fi
    sum="$(checksum "$(file_up "$ARG" "$slug")")"
    {
        echo "-- Міграція ${ARG}_${slug} для phpMyAdmin. Префікс: ${DB_PREFIX}"
        echo "-- Перед виконанням: бекап бази (phpMyAdmin → Експорт)."
        echo "$TRACK_DDL"
        cat "$(file_up "$ARG" "$slug")"
        echo ""
        echo "INSERT INTO \`{{PREFIX}}kristal_migration\` (\`version\`, \`name\`, \`checksum\`, \`applied_at\`)"
        echo "VALUES ('${ARG}', '${slug}', '${sum}', NOW());"
    } | sed "s/{{PREFIX}}/${DB_PREFIX}/g"
    exit 0
fi

require_running
printf '%s\n' "$TRACK_DDL" | sed "s/{{PREFIX}}/${DB_PREFIX}/g" \
    | dc exec -T -e MYSQL_PWD="$DB_PASSWORD" db mysql -u"$DB_USER" "$DB_NAME" \
    || die "Не вдалося створити таблицю ${DB_PREFIX}kristal_migration"

applied() {  # "version<TAB>checksum" застосованих
    sql -N -B -e "SELECT version, checksum FROM \`${DB_PREFIX}kristal_migration\` ORDER BY version;" | tr -d '\r'
}

case "$CMD" in
status)
    step "Міграції (${DB_PREFIX}kristal_migration)"
    APPLIED="$(applied)"
    PENDING=0
    while IFS=$'\t' read -r v slug; do
        [ -n "$v" ] || continue
        rec="$(printf '%s\n' "$APPLIED" | awk -F'\t' -v v="$v" '$1 == v {print $2}')"
        if [ -z "$rec" ]; then
            printf '  [ ] %s_%s\n' "$v" "$slug"; PENDING=$((PENDING + 1))
        elif [ "$rec" != "$(checksum "$(file_up "$v" "$slug")")" ]; then
            printf '  [x] %s_%s  %sУВАГА: файл змінено після застосування%s\n' "$v" "$slug" "$C_YELLOW" "$C_RESET"
        else
            printf '  [x] %s_%s\n' "$v" "$slug"
        fi
    done <<< "$(list_files)"
    # застосовані, файлів яких уже немає
    while IFS=$'\t' read -r v _; do
        if [ -n "$v" ] && [ -z "$(slug_of "$v")" ]; then warn "версія $v застосована, але файлу немає"; fi
    done <<< "$APPLIED"
    printf '\n  Очікують: %s\n' "$PENDING"
    ;;

up)
    APPLIED="$(applied | cut -f1)"
    DONE=0
    while IFS=$'\t' read -r v slug; do
        [ -n "$v" ] || continue
        if [ -n "$ARG" ] && [ "$((10#$v))" -gt "$((10#$ARG))" ]; then break; fi
        printf '%s\n' "$APPLIED" | grep -qx "$v" && continue
        up="$(file_up "$v" "$slug")"
        [ -f "$(file_down "$v" "$slug")" ] || die "Немає down-файлу для ${v}_${slug} — міграція без відкату заборонена"
        step "↑ ${v}_${slug}"
        sql_file "$up" || die "Міграція ${v}_${slug} впала. Таблиці MyISAM не відкочуються транзакцією —
перевірте стан, виправте файл і запустіть make migrate ще раз (міграції мають бути ідемпотентні)."
        sql -e "INSERT INTO \`${DB_PREFIX}kristal_migration\` (version, name, checksum, applied_at)
                VALUES ('${v}', '${slug}', '$(checksum "$up")', NOW());"
        ok "застосовано"
        DONE=$((DONE + 1))
    done <<< "$(list_files)"
    if [ "$DONE" -eq 0 ]; then ok "Нових міграцій немає"; exit 0; fi
    printf '\n  Далі за чек-листом:  make db-check  →  make db-schema-diff  →  make db-explain  →  make db-schema-snapshot\n'
    printf '  і скиньте кеш:  make clear-cache\n'
    ;;

down)
    [ -n "$ARG" ] || die "Вкажіть версію: make migrate-down V=0001"
    slug="$(slug_of "$ARG")"; [ -n "$slug" ] || die "Немає міграції $ARG у db/migrations/"
    APPLIED="$(applied | cut -f1)"
    printf '%s\n' "$APPLIED" | grep -qx "$ARG" || die "Версія $ARG не застосована"
    LAST="$(printf '%s\n' "$APPLIED" | grep -v '^$' | tail -1)"
    if [ "$LAST" != "$ARG" ] && [ "${FORCE:-0}" != "1" ]; then
        die "Відкочувати можна лише останню застосовану ($LAST). Свідомо інакше: FORCE=1"
    fi
    step "↓ ${ARG}_${slug}"
    sql_file "$(file_down "$ARG" "$slug")" || die "Відкат ${ARG}_${slug} впав — дивіться помилку SQL вище"
    sql -e "DELETE FROM \`${DB_PREFIX}kristal_migration\` WHERE version = '${ARG}';"
    ok "відкочено. Далі: make db-check, make db-schema-diff, make clear-cache"
    ;;

*) die "Невідома команда: $CMD (status | up | down | print | new)" ;;
esac
