#!/bin/bash
# ---------------------------------------------------------------------------
# 017: резервні копії сайту «Крістал» на хостингу (запускає cron cPanel). specs/017-security AC-12
#
# Лежить у ~/kristal-backup/ (поза сайтом, з вебу недоступний). Заливає: make backup-install.
# Cron (cPanel → Cron Jobs, щодня вночі):
#   17 3 * * *  /bin/bash $HOME/kristal-backup/kristal-backup.sh
#
# Що робить:
#   * база — щодня: mysqldump | gzip → db/db-<дата>.sql.gz, лишає останні KB_KEEP_DB (14);
#   * файли — раз на тиждень (якщо архіву новішого за 6 днів немає): tar.gz теки сайту без
#     кешу, сесій, логів і прев'ю → files/files-<дата>.tar.gz, лишає останні KB_KEEP_FILES (4);
#   * журнал — backup.log (розміри, вільне місце). Пароль БД береться з config.php сайту,
#     ніде не дублюється і в журнал не пишеться.
# Виводить щось лише при помилці (тоді cron надішле лист, якщо в cPanel вказано email) і
# завершується кодом 1.
#
# Змінні (для перевірки локально): KB_SITE_DIR, KB_DIR, KB_KEEP_DB, KB_KEEP_FILES, KB_FORCE_FILES=1
# Залежності: bash, mysqldump, gzip, tar (є на будь-якому cPanel).
# ---------------------------------------------------------------------------
set -u
umask 077

SITE_DIR="${KB_SITE_DIR:-$HOME/orendaposydy.com}"
KB_DIR="${KB_DIR:-$HOME/kristal-backup}"
KEEP_DB="${KB_KEEP_DB:-14}"
KEEP_FILES="${KB_KEEP_FILES:-4}"
STAMP="$(date +%Y%m%d-%H%M%S)"
LOG="$KB_DIR/backup.log"

mkdir -p "$KB_DIR/db" "$KB_DIR/files" || { echo "kristal-backup: не можу створити $KB_DIR" >&2; exit 1; }

log() { printf '%s %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >> "$LOG"; }
fail() { log "ПОМИЛКА: $*"; echo "kristal-backup ($STAMP): $*" >&2; exit 1; }

# Один запуск за раз
if command -v flock >/dev/null 2>&1; then
    exec 9>"$KB_DIR/.lock"
    flock -n 9 || fail "попередній запуск ще працює"
fi

# --- Доступ до БД з config.php сайту ---------------------------------------
CONF="$SITE_DIR/config.php"
[ -r "$CONF" ] || fail "немає $CONF"
conf() {   # define('DB_X', 'значення'); — значення без лапок, \' → '
    sed -n "s/^[[:space:]]*define('$1',[[:space:]]*'\(.*\)');.*$/\1/p" "$CONF" | head -n 1 | sed "s/\\\\'/'/g"
}
DB_HOST="$(conf DB_HOSTNAME)"; DB_USER="$(conf DB_USERNAME)"; DB_PASS="$(conf DB_PASSWORD)"
DB_NAME="$(conf DB_DATABASE)"; DB_PORT="$(conf DB_PORT)"
[ -n "$DB_NAME" ] && [ -n "$DB_USER" ] || fail "не вдалося прочитати DB_DATABASE/DB_USERNAME з config.php"

# --- База: щодня ---------------------------------------------------------------
command -v mysqldump >/dev/null 2>&1 || fail "немає mysqldump"
OPTS=(--single-transaction --quick --default-character-set=utf8mb4 --skip-lock-tables)
mysqldump --help 2>/dev/null | grep -q -- '--no-tablespaces' && OPTS+=(--no-tablespaces)
[ -n "$DB_PORT" ] && OPTS+=(-P "$DB_PORT")
DB_OUT="$KB_DIR/db/db-$STAMP.sql.gz"
TMP="$DB_OUT.part"

MYSQL_PWD="$DB_PASS" mysqldump "${OPTS[@]}" -h "${DB_HOST:-localhost}" -u "$DB_USER" "$DB_NAME" \
    2>>"$LOG" | gzip -6 > "$TMP"
STATUS=("${PIPESTATUS[@]}")
if [ "${STATUS[0]}" != "0" ] || [ "${STATUS[1]}" != "0" ]; then
    rm -f "$TMP"; fail "mysqldump/gzip завершились з кодом ${STATUS[*]}"
fi
gzip -t "$TMP" 2>/dev/null || { rm -f "$TMP"; fail "дамп пошкоджений (gzip -t)"; }
gzip -dc "$TMP" | tail -n 1 | grep -q 'Dump completed' || { rm -f "$TMP"; fail "дамп обірваний (немає «Dump completed»)"; }
mv "$TMP" "$DB_OUT"
log "база: $(basename "$DB_OUT") $(du -h "$DB_OUT" | cut -f1)"

# --- Файли: раз на тиждень ------------------------------------------------------
RECENT="$(find "$KB_DIR/files" -maxdepth 1 -name 'files-*.tar.gz' -mtime -6 2>/dev/null | head -n 1)"
if [ -z "$RECENT" ] || [ "${KB_FORCE_FILES:-0}" = "1" ]; then
    F_OUT="$KB_DIR/files/files-$STAMP.tar.gz"
    PARENT="$(dirname "$SITE_DIR")"; BASE="$(basename "$SITE_DIR")"
    tar -czf "$F_OUT.part" -C "$PARENT" \
        --exclude="$BASE/image/cache" \
        --exclude="$BASE/storage_kozak/cache" --exclude="$BASE/storage_kozak/session" --exclude="$BASE/storage_kozak/logs" \
        --exclude="$BASE/system/storage/cache" --exclude="$BASE/system/storage/session" --exclude="$BASE/system/storage/logs" \
        --exclude="$BASE/error_log" --exclude="$BASE/maket-*" \
        "$BASE" 2>>"$LOG"
    rc=$?
    # 1 = «файл змінився під час читання» (кеш, сесії) — архів придатний
    [ "$rc" -le 1 ] || { rm -f "$F_OUT.part"; fail "tar завершився з кодом $rc"; }
    mv "$F_OUT.part" "$F_OUT"
    log "файли: $(basename "$F_OUT") $(du -h "$F_OUT" | cut -f1)"
fi

# --- Ротація ---------------------------------------------------------------------
rotate() {   # тека, префікс, суфікс, скільки лишити
    ls -1t "$1" 2>/dev/null | grep -E "^$2-[0-9-]+$3\$" | tail -n +"$(( $4 + 1 ))" | while IFS= read -r old; do
        rm -f "$1/$old" && log "видалено старе: $old"
    done
}
rotate "$KB_DIR/db" db '\.sql\.gz' "$KEEP_DB"
rotate "$KB_DIR/files" files '\.tar\.gz' "$KEEP_FILES"

log "разом: $(du -sh "$KB_DIR" | cut -f1); вільно: $(df -h "$KB_DIR" 2>/dev/null | awk 'NR==2 {print $4}')"
exit 0
