#!/bin/bash
# ---------------------------------------------------------------------------
# Спільні функції для скриптів у tools/.
# Підключається так:  . "$(dirname "$0")/lib.sh"
# ---------------------------------------------------------------------------
set -euo pipefail

# Корінь проєкту = тека на рівень вище tools/
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export PROJECT_ROOT

# --- Кольори (вимикаються, якщо вивід не в термінал) -------------------------
if [ -t 1 ]; then
    C_RESET=$'\033[0m'; C_RED=$'\033[31m'; C_GREEN=$'\033[32m'
    C_YELLOW=$'\033[33m'; C_BLUE=$'\033[36m'; C_BOLD=$'\033[1m'
else
    C_RESET=''; C_RED=''; C_GREEN=''; C_YELLOW=''; C_BLUE=''; C_BOLD=''
fi

info()  { printf '%s==>%s %s\n' "$C_BLUE" "$C_RESET" "$*"; }
ok()    { printf '%s  OK%s %s\n' "$C_GREEN" "$C_RESET" "$*"; }
warn()  { printf '%s  УВАГА%s %s\n' "$C_YELLOW" "$C_RESET" "$*" >&2; }
err()   { printf '%s  ПОМИЛКА%s %s\n' "$C_RED" "$C_RESET" "$*" >&2; }
die()   { err "$*"; exit 1; }
step()  { printf '\n%s%s%s\n' "$C_BOLD" "$*" "$C_RESET"; }

# --- Завантаження .env -------------------------------------------------------
load_env() {
    local env_file="${PROJECT_ROOT}/.env"
    if [ ! -f "$env_file" ]; then
        die "Немає файлу .env. Створіть його: cp .env.example .env"
    fi
    # shellcheck disable=SC1090
    set -a; . "$env_file"; set +a
    : "${DB_NAME:?DB_NAME не задано в .env}"
    : "${DB_USER:?DB_USER не задано в .env}"
    : "${DB_PASSWORD:?DB_PASSWORD не задано в .env}"
    DB_PREFIX="${DB_PREFIX:-oc_}"
    WEB_PORT="${WEB_PORT:-8090}"
    export DB_NAME DB_USER DB_PASSWORD DB_PREFIX WEB_PORT
}

# --- docker compose з потрібної теки ----------------------------------------
dc() {
    ( cd "$PROJECT_ROOT" && docker compose "$@" )
}

# --- Перевірка, що стек запущений -------------------------------------------
require_running() {
    if ! dc ps --status running --services 2>/dev/null | grep -q '^db$'; then
        die "Контейнер db не запущений. Виконайте: make up"
    fi
}

# --- SQL-хелпери -------------------------------------------------------------
# Пароль передаємо через MYSQL_PWD, а не через -p на командному рядку:
# по-перше, mysql не сипле попередженням "Using a password on the command line
# interface can be insecure", по-друге, пароль не видно в списку процесів.

# Виконати SQL-рядок у контейнері db.
# Прапорець -N прибирає заголовки, -B робить вивід табличним (зручно для скриптів).
sql() {
    dc exec -T -e MYSQL_PWD="$DB_PASSWORD" db \
        mysql -u"$DB_USER" --default-character-set=utf8mb4 "$DB_NAME" "$@"
}

sql_scalar() {
    dc exec -T -e MYSQL_PWD="$DB_PASSWORD" db \
        mysql -N -B -u"$DB_USER" --default-character-set=utf8mb4 "$DB_NAME" -e "$1" 2>/dev/null | tr -d '\r'
}

# Виконати .sql файл, підставивши реальний префікс таблиць замість {{PREFIX}}.
# Саме так локальні скрипти працюють із будь-яким префіксом (oc_, oc3_, shop_).
sql_file() {
    local file="$1"
    [ -f "$file" ] || die "Немає файлу $file"
    sed "s/{{PREFIX}}/${DB_PREFIX}/g" "$file" \
        | dc exec -T -e MYSQL_PWD="$DB_PASSWORD" db \
            mysql -u"$DB_USER" --default-character-set=utf8mb4 "$DB_NAME"
}

# Перевірити, що таблиця $1 існує
table_exists() {
    local t
    t="$(sql_scalar "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='${DB_NAME}' AND table_name='$1';")"
    [ "$t" = "1" ]
}

# --- Показати, куди дивитись ------------------------------------------------
show_urls() {
    local base="http://localhost:${WEB_PORT}/"
    printf '\n%sГотово. Куди дивитись:%s\n' "$C_BOLD" "$C_RESET"
    printf '  Вітрина:   %s\n' "$base"
    printf '  Адмінка:   %sadmin/\n' "$base"
    printf '  База:      http://localhost:%s/  (сервер db)\n' "${ADMINER_PORT:-8081}"
    printf '  Пошта:     http://localhost:%s/\n' "${MAILPIT_UI_PORT:-8025}"
}

# --- Що можна і не можна деплоїти --------------------------------------------
# Спільне для deploy.sh і package-release.sh, щоб правила були в одному місці
# й не розійшлися.
#
# INCLUDE_HTACCESS=1 дозволяє залити .htaccess (типово заборонено: на проді
# там можуть бути правила хостингу, яких у репозиторії немає).
is_protected() {
    local p="$1"
    case "$p" in
        config.php|./config.php)               return 0 ;;
        admin/config.php|./admin/config.php)   return 0 ;;
        system/storage/*|./system/storage/*)   return 0 ;;
        image/cache/*|./image/cache/*)         return 0 ;;
        .git|.git/*|*/.git/*)                  return 0 ;;
        dumps/*|backups/*|*.sql|*.sql.gz)      return 0 ;;
        install/*|./install/*)                 return 0 ;;
        image/catalog/kristal/mock/*|./image/catalog/kristal/mock/*) return 0 ;;
    esac
    if [ "${INCLUDE_HTACCESS:-0}" -eq 0 ]; then
        case "$p" in
            .htaccess|./.htaccess) return 0 ;;
        esac
    fi
    return 1
}

protect_reason() {
    local p="$1"
    case "$p" in
        config.php|./config.php|admin/config.php|./admin/config.php)
            echo "бойові доступи до БД — локальна версія вказує на localhost і зламає сайт" ;;
        system/storage/*|./system/storage/*)
            echo "кеш, логи, сесії та згенеровані OCMOD-модифікації" ;;
        image/cache/*|./image/cache/*)
            echo "прев'ю зображень, генеруються на сервері" ;;
        .htaccess|./.htaccess)
            echo "правила хостингу (за потреби: --include-htaccess)" ;;
        *.sql|*.sql.gz)
            echo "SQL виконується через phpMyAdmin, а не заливається як файл" ;;
        install/*|./install/*)
            echo "теку install/ на проді тримати небезпечно — її треба видаляти" ;;
        image/catalog/kristal/mock/*|./image/catalog/kristal/mock/*)
            echo "мок-зображення (AGENTS.md §10) — на прод не потрапляють" ;;
        *) echo "службовий шлях" ;;
    esac
}

# Друкує список змінених файлів (шляхи відносно src/) у stdout.
#   collect_changes <git-ref-або-порожньо> <список-через-кому-або-порожньо>
collect_changes() {
    local since="$1" files_arg="$2"

    if [ -n "$files_arg" ]; then
        printf '%s\n' "$files_arg" | tr ',' '\n' | sed 's/^ *//; s/ *$//' | grep -v '^$'
        return 0
    fi

    local repo="$PROJECT_ROOT"
    git -C "$repo" rev-parse --git-dir >/dev/null 2>&1 || return 1

    if [ -n "$since" ]; then
        git -C "$repo" rev-parse --verify "$since" >/dev/null 2>&1 || return 2
        {
            git -C "$repo" diff --name-only "$since" HEAD -- src/ 2>/dev/null
            git -C "$repo" diff --name-only HEAD -- src/ 2>/dev/null
            git -C "$repo" ls-files --others --exclude-standard -- src/ 2>/dev/null
        } | sed 's|^src/||' | sort -u
    else
        {
            git -C "$repo" diff --name-only HEAD -- src/ 2>/dev/null
            git -C "$repo" diff --name-only HEAD~1 -- src/ 2>/dev/null
            git -C "$repo" ls-files --others --exclude-standard -- src/ 2>/dev/null
        } | sed 's|^src/||' | sort -u
    fi
}
# Використовуємо curl, а не lftp: curl є в системі завжди, а lftp треба
# окремо встановлювати. Для заливки окремих файлів цього цілком достатньо.
#
# Чому FTP, а не rsync:
#   у вас доступ лише через панель хостингу, SSH немає. FTP-акаунт є в будь-якій
#   панелі (cPanel → FTP Accounts, ISPmanager → FTP), і він дає прямий доступ
#   до файлів сайту.

# --- FTP-хелпери ------------------------------------------------------------
# Використовуємо curl, а не lftp: curl є в системі завжди, а lftp треба
# окремо встановлювати. Для заливки окремих файлів цього цілком достатньо.
#
# Чому FTP, а не rsync:
#   у вас доступ лише через панель хостингу, SSH немає. FTP-акаунт є в будь-якій
#   панелі (cPanel → FTP Accounts, ISPmanager → FTP), і він дає прямий доступ
#   до файлів сайту.

require_ftp() {
    [ -n "${FTP_HOST:-}" ] || die "FTP_HOST не задано в .env — див. розділ «ДЕПЛОЙ НА ПРОД»"
    [ -n "${FTP_USER:-}" ] || die "FTP_USER не задано в .env"
    [ -n "${FTP_PASSWORD:-}" ] || die "FTP_PASSWORD не задано в .env"
    command -v curl >/dev/null 2>&1 || die "Потрібен curl (встановіть: sudo apt install curl)"
}

# URL до файлу на FTP. FTP_REMOTE_DIR — тека відносно кореня FTP-акаунта.
ftp_url() {
    local rel="${1#/}"
    local base="ftp://${FTP_HOST}:${FTP_PORT:-21}"
    if [ -n "${FTP_REMOTE_DIR:-}" ]; then
        base="${base}/${FTP_REMOTE_DIR#/}"
    fi
    printf '%s/%s' "${base%/}" "$rel"
}

# Абсолютний шлях на сервері — потрібен для команд DELE / RMD / MKD,
# які curl надсилає через -Q.
ftp_abs() {
    local rel="${1#/}"
    local dir="${FTP_REMOTE_DIR:-}"
    dir="${dir#/}"; dir="${dir%/}"
    if [ -n "$dir" ]; then
        printf '/%s/%s' "$dir" "$rel"
    else
        printf '/%s' "$rel"
    fi
}

# Спільні опції curl. --ssl-reqd = явний FTPS (AUTH TLS).
# Без нього логін і пароль ідуть відкритим текстом.
ftp_opts() {
    printf -- '--silent --show-error --user %s:%s' "$FTP_USER" "$FTP_PASSWORD"
    if [ "${FTP_TLS:-no}" = "yes" ]; then
        printf -- ' --ssl-reqd'
    fi
}
