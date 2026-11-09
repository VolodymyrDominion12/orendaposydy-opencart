#!/bin/bash
# ---------------------------------------------------------------------------
# Точка входу контейнера web.
#
# Що робить:
#   1. створює текучі каталоги OpenCart (system/storage/*, image/cache) —
#      без них OpenCart віддає "500" або білу сторінку;
#   2. виставляє права на них для www-data;
#   3. якщо config.php ще немає, а в оточенні є дані БД — генерує його;
#   4. передає керування Apache.
#
# Скрипт ідемпотентний: можна перезапускати контейнер скільки завгодно.
# ---------------------------------------------------------------------------
set -euo pipefail

DOCROOT=/var/www/html
RUN_USER=www-data
RUN_GROUP=www-data

log() { printf '\033[36m[entrypoint]\033[0m %s\n' "$*"; }
warn() { printf '\033[33m[entrypoint][УВАГА]\033[0m %s\n' "$*"; }

# --- 1. Каталоги, у які OpenCart пише ---------------------------------------
STORAGE_DIRS=(
    system/storage
    system/storage/cache
    system/storage/download
    system/storage/logs
    system/storage/modification
    system/storage/session
    system/storage/upload
    system/storage/backup
    image/cache
    image/catalog
    download
)

if [ -f "$DOCROOT/index.php" ]; then
    for d in "${STORAGE_DIRS[@]}"; do
        mkdir -p "$DOCROOT/$d"
    done

    # chown лише на текучі каталоги: повний chown дерева OpenCart щоразу
    # помітно сповільнює старт, а решта файлів — лише читання.
    chown -R "$RUN_USER:$RUN_GROUP" \
        "$DOCROOT/system/storage" \
        "$DOCROOT/image/cache" \
        "$DOCROOT/download" 2>/dev/null || warn "не вдалось змінити власника частини каталогів"

    chmod -R u+rwX,g+rwX "$DOCROOT/system/storage" "$DOCROOT/image/cache" 2>/dev/null || true
else
    warn "у $DOCROOT немає index.php — файли OpenCart ще не скопійовані."
    warn "Дивіться docs/01-export-from-panel.md (як забрати сайт із хостингу)."
fi

# --- 2. config.php за потреби ------------------------------------------------
# Генеруємо ЛИШЕ якщо файлу немає. Інакше ніколи не чіпаємо — щоб не затерти
# те, що ви або інсталятор OpenCart уже створили.
if [ -f "$DOCROOT/index.php" ] && [ ! -f "$DOCROOT/config.php" ] && [ -n "${DB_DATABASE:-}" ]; then
    log "config.php відсутній — генерую зі змінних оточення"
    /usr/local/bin/make-config.sh || warn "не вдалось згенерувати config.php"
fi

# --- 3. Apache ---------------------------------------------------------------
log "документ-рут: $DOCROOT"
log "PHP $(php -r 'echo PHP_VERSION;') | www-data: $(id -u "$RUN_USER"):$(id -g "$RUN_USER")"

if [ -f "$DOCROOT/index.php" ] && [ ! -w "$DOCROOT/image/cache" ]; then
    warn "image/cache недоступний для запису — OpenCart не зможе створювати прев'ю зображень"
fi

exec "$@"
