#!/bin/bash
# ---------------------------------------------------------------------------
# Генерує config.php (вітрина) і admin/config.php під ЛОКАЛЬНЕ середовище.
#
# Формат узято 1:1 з офіційного інсталятора OpenCart 3.0.3.9
# (install/controller/install/step_3.php), щоб жодне розширення не спіткнулось
# на несподіваній константі.
#
# Навіщо це окремий крок, а не «просто скопіювати конфіг із прода»:
#   * на проді config.php містить бойові доступи до БД і шляхи хостингу
#     (/home/user/domains/...). Локально вони не працюють;
#   * HTTP_SERVER на проді — https://orendaposydy.com/, і якщо лишити його,
#     локальний сайт редиректитиме на прод;
#   * config.php НІКОЛИ не має потрапляти в git і ніколи не деплоїться.
#
# Запуск (з контейнера):  make-config.sh
# Запуск (з хоста):       make config
# ---------------------------------------------------------------------------
set -euo pipefail

DOCROOT="${DOCROOT:-/var/www/html}"

DB_HOSTNAME="${DB_HOSTNAME:-db}"
DB_USERNAME="${DB_USERNAME:-opencart}"
DB_PASSWORD="${DB_PASSWORD:-opencart}"
DB_DATABASE="${DB_DATABASE:-opencart}"
DB_PORT="${DB_PORT:-3306}"
DB_PREFIX="${DB_PREFIX:-oc_}"
SITE_URL="${SITE_URL:-http://localhost:8090/}"

# OpenCart очікує URL із завершальним слешем — інакше ламаються посилання
case "$SITE_URL" in
    */) ;;
    *) SITE_URL="$SITE_URL/" ;;
esac

if [ ! -d "$DOCROOT" ]; then
    echo "Помилка: немає каталогу $DOCROOT" >&2
    exit 1
fi

DIR_OPENCART="$DOCROOT/"

# --- Куди складати копії бойових файлів --------------------------------------
# НАВМИСНО поза docroot. Усе, що лежить у /var/www/html, Apache віддає по
# HTTP: копія config.php.prod-backup-<дата> відкривалась у браузері як
# звичайний текст — разом із логіном і паролем до бойової бази (а порт
# опубліковано на 0.0.0.0, тобто це видно всій локальній мережі).
BACKUP_DIR="${BACKUP_DIR:-/backups/config}"
if ! mkdir -p "$BACKUP_DIR" 2>/dev/null || [ ! -w "$BACKUP_DIR" ]; then
    echo "  УВАГА: $BACKUP_DIR недоступний для запису — копію бойового config.php"
    echo "         зберегти не вдасться. Перевірте монтування ./backups у docker-compose.yml"
    BACKUP_DIR=""
fi

# --- Зберегти оригінал, якщо він не наш --------------------------------------
# Ситуація: ви скопіювали файли з прода і config.php там бойовий. Наш
# генератор його перезапише — тому спершу зберігаємо копію з міткою часу.
# Це важливо: саме з нього можна дізнатись реальний префікс таблиць і назву БД.
backup_if_exists() {
    local f="$1"
    [ -f "$f" ] || return 0
    if grep -q 'ЗГЕНЕРОВАНО ЛОКАЛЬНО' "$f" 2>/dev/null; then
        return 0   # це вже наш файл, бекапити нічого
    fi
    if [ -n "$BACKUP_DIR" ]; then
        local stamp dir rel bak
        stamp="$(date +%Y%m%d-%H%M%S)"
        dir="$BACKUP_DIR/$stamp"
        mkdir -p "$dir"
        # config.php і admin/config.php не мають перебити один одного
        rel="${f#$DOCROOT/}"
        bak="$dir/$(printf '%s' "$rel" | tr '/' '_').prod-backup"
        cp -p "$f" "$bak"
        # Контейнер працює від root, а backups/ — це ваша тека на хості.
        # Без цього копію не можна буде ні прочитати зручно, ні видалити
        # (файл належатиме root). Рівняємось на власника файлів сайту.
        if [ -d "$DOCROOT" ]; then
            chown -R "$(stat -c '%u:%g' "$DOCROOT")" "$dir" 2>/dev/null || true
        fi
        echo "  збережено оригінал прода: $bak"
    else
        echo "  !! УВАГА: бойовий config.php буде перезаписано БЕЗ копії"
    fi
    # Підказуємо реальні значення з прода — щоб було з чим звірити
    local prod_prefix prod_db
    prod_prefix=$(grep -oP "DB_PREFIX',\s*'\K[^']*" "$f" 2>/dev/null || true)
    prod_db=$(grep -oP "DB_DATABASE',\s*'\K[^']*" "$f" 2>/dev/null || true)
    [ -n "$prod_prefix" ] && echo "    префікс таблиць на проді: $prod_prefix"
    [ -n "$prod_db" ]     && echo "    назва БД на проді:        $prod_db"
    if [ -n "$prod_prefix" ] && [ "$prod_prefix" != "$DB_PREFIX" ]; then
        echo "    !! УВАГА: у .env DB_PREFIX=$DB_PREFIX, а на проді $prod_prefix."
        echo "       Виправте DB_PREFIX у .env, інакше локалізація БД не спрацює."
    fi
}

# --- Спільні блоки -----------------------------------------------------------
db_block() {
    cat <<EOF
// DB
define('DB_DRIVER', 'mysqli');
define('DB_HOSTNAME', '${DB_HOSTNAME}');
define('DB_USERNAME', '${DB_USERNAME}');
define('DB_PASSWORD', '${DB_PASSWORD}');
define('DB_DATABASE', '${DB_DATABASE}');
define('DB_PORT', '${DB_PORT}');
define('DB_PREFIX', '${DB_PREFIX}');
EOF
}

dir_block() {
    # DIR_STORAGE навмисно відносний до DIR_SYSTEM — саме так робить
    # офіційний інсталятор, і частина коду покладається на це.
    cat <<EOF
// DIR
define('DIR_APPLICATION', '${DIR_OPENCART}${1}/');
define('DIR_SYSTEM', '${DIR_OPENCART}system/');
define('DIR_IMAGE', '${DIR_OPENCART}image/');
define('DIR_STORAGE', DIR_SYSTEM . 'storage/');
EOF
    if [ "$1" = "admin" ]; then
        echo "define('DIR_CATALOG', '${DIR_OPENCART}catalog/');"
    fi
    cat <<EOF
define('DIR_LANGUAGE', DIR_APPLICATION . 'language/');
define('DIR_TEMPLATE', DIR_APPLICATION . '${2}/');
define('DIR_CONFIG', DIR_SYSTEM . 'config/');
define('DIR_CACHE', DIR_STORAGE . 'cache/');
define('DIR_DOWNLOAD', DIR_STORAGE . 'download/');
define('DIR_LOGS', DIR_STORAGE . 'logs/');
define('DIR_MODIFICATION', DIR_STORAGE . 'modification/');
define('DIR_SESSION', DIR_STORAGE . 'session/');
define('DIR_UPLOAD', DIR_STORAGE . 'upload/');
EOF
}

header_block() {
    cat <<EOF
<?php
// ---------------------------------------------------------------------------
// ЗГЕНЕРОВАНО ЛОКАЛЬНО — $(date '+%Y-%m-%d %H:%M:%S')
// Файл у .gitignore і ніколи не деплоїться на прод (див. tools/deploy.sh).
// Перегенерувати: make config
// ---------------------------------------------------------------------------

EOF
}

write_catalog_config() {
    local f="$DOCROOT/config.php"
    backup_if_exists "$f"
    {
        header_block
        echo "// HTTP"
        echo "define('HTTP_SERVER', '${SITE_URL}');"
        echo
        echo "// HTTPS"
        echo "define('HTTPS_SERVER', '${SITE_URL}');"
        echo
        dir_block "catalog" "view/theme"
        echo
        db_block
    } > "$f"
    echo "  створено config.php (вітрина)"
}

write_admin_config() {
    local f="$DOCROOT/admin/config.php"
    backup_if_exists "$f"
    {
        header_block
        echo "// HTTP"
        echo "define('HTTP_SERVER', '${SITE_URL}admin/');"
        echo "define('HTTP_CATALOG', '${SITE_URL}');"
        echo
        echo "// HTTPS"
        echo "define('HTTPS_SERVER', '${SITE_URL}admin/');"
        echo "define('HTTPS_CATALOG', '${SITE_URL}');"
        echo
        dir_block "admin" "view/template"
        echo
        db_block
        echo
        echo "// OpenCart API"
        echo "define('OPENCART_SERVER', 'https://www.opencart.com/');"
    } > "$f"
    echo "  створено admin/config.php (адмінка)"
}

echo "Генерую локальні config.php"
echo "  сайт: $SITE_URL"
echo "  БД:   ${DB_USERNAME}@${DB_HOSTNAME}:${DB_PORT}/${DB_DATABASE} (префікс ${DB_PREFIX})"
write_catalog_config
write_admin_config

# Перевірка синтаксису — дешевше зловити помилку тут, ніж білою сторінкою
for f in "$DOCROOT/config.php" "$DOCROOT/admin/config.php"; do
    if ! php -l "$f" >/dev/null 2>&1; then
        echo "ПОМИЛКА: невалідний PHP у $f" >&2
        php -l "$f" >&2 || true
        exit 1
    fi
done

# config.php має бути доступним для запису — OpenCart інколи його переписує
chmod 644 "$DOCROOT/config.php" "$DOCROOT/admin/config.php" 2>/dev/null || true

if [ -d "$DOCROOT/system/storage" ]; then
    chown -R www-data:www-data "$DOCROOT/system/storage" 2>/dev/null || true
fi

echo "Готово."
