#!/bin/bash
# ---------------------------------------------------------------------------
# 017: безпека проду — службові файли, адмінка, стара тека. specs/017-security
#
# ПРИНЦИП
#   За замовчуванням НІЧОГО НЕ ЗМІНЮЄ (dry-run), друкує план. --apply → підтвердження YES.
#   Нічого не видаляється: усе ПЕРЕНОСИТЬСЯ одною FTP-командою RNFR/RNTO у
#   ~/kristal-trash/<дата>/ (поза сайтом). Рекурсивне видалення по FTP — сотні команд,
#   хостинг за таке блокує IP (docs/03-deploy.md). Смітник людина видаляє в File Manager.
#   Структура смітника: <дата>/site/<ім'я> — з кореня сайту, <дата>/home/<ім'я> — з домашньої теки.
#
# КОМАНДИ
#   status                      лише читання: що лежить на проді, що відповідає по HTTP
#   cleanup        [--apply]    install/, index1.php, index.svg, архіви й копії в корені сайту → смітник
#   rename-admin   [--apply] [--name kr-xxxx]
#                               admin/ → нова тека + 3 рядки в admin/config.php; перевірка HTTP;
#                               не пройшла — автоматичний відкат. Успіх → REMOTE_ADMIN_DIR у .env
#   rename-admin --undo [--apply]
#                               повернути admin/ і бойовий конфіг із бекапу
#   retire-online  [--apply]    стара тека сайту orendaposudu.online → смітник
#   restore <шлях у смітнику> [--apply]
#                               повернути перенесене (kristal-trash/<дата>/site/install …)
#
# make sec-status | sec-cleanup APPLY=1 | sec-rename-admin APPLY=1 | sec-retire-online APPLY=1
# ---------------------------------------------------------------------------

. "$(dirname "$0")/lib.sh"
load_env

CMD="${1:-}"; shift || true
APPLY=0; UNDO=0; NAME=""; ARG=""
while [ $# -gt 0 ]; do
    case "$1" in
        --apply) APPLY=1 ;;
        --undo)  UNDO=1 ;;
        --name)  NAME="$2"; shift ;;
        -h|--help) sed -n '2,26p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *)       ARG="$1" ;;
    esac
    shift
done

case "$CMD" in
    status|cleanup|rename-admin|retire-online|restore) ;;
    ''|-h|--help) sed -n '2,26p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) die "Невідома команда: $CMD (status, cleanup, rename-admin, retire-online, restore)" ;;
esac

require_ftp

PROD="${PROD_URL:-https://orendaposudu.com}"; PROD="${PROD%/}"
SITE_DIR="${FTP_REMOTE_DIR#/}"; SITE_DIR="${SITE_DIR%/}"
OLD_SITE_DIR="${OLD_SITE_DIR:-orendaposudu.online}"
TRASH="kristal-trash"
STAMP="$(date +%Y%m%d-%H%M%S)"
ROOT="ftp://${FTP_HOST}:${FTP_PORT:-21}/"

# Архіви, дампи й копії, яким не місце в корені сайту (AC-15)
JUNK_RE='\.(zip|rar|7z|tgz|gz|tar|bak|old|orig|swp|sql|log)$|prod-backup|^index1\.php$|^index\.svg$|^desktop\.ini$'

# FTP-команди одним з'єднанням. Префікс * — ігнорувати помилку (MKD наявної теки).
ftp_q() {
    local args=() c
    for c in "$@"; do args+=(-Q "$c"); done
    # shellcheck disable=SC2046
    curl $(ftp_opts) --fail "${args[@]}" "$ROOT" -o /dev/null 2>/dev/null
}

list_names() {   # $1 — шлях від кореня FTP ("" — домашня тека)
    local p="${1#/}"
    # shellcheck disable=SC2046
    curl $(ftp_opts) --fail --list-only "ftp://${FTP_HOST}:${FTP_PORT:-21}/${p:+$p/}" 2>/dev/null \
        | tr -d '\r' | grep -vx '\.\|\.\.' || true
}

http_code() { curl -s -o /dev/null -w '%{http_code}' --max-time 20 "$1" || echo 000; }

confirm() {
    if [ "$APPLY" -ne 1 ]; then
        printf '\n'; info "Це DRY-RUN. Нічого не змінилось. Виконати: додайте --apply (make … APPLY=1)."
        exit 0
    fi
    printf '\n%s на ПРОДІ (%s). Введіть %sYES%s: ' "$1" "$FTP_HOST" "$C_BOLD" "$C_RESET"
    local answer; read -r answer
    [ "$answer" = "YES" ] || { info "Скасовано."; exit 0; }
}

set_env_admin() {   # записати REMOTE_ADMIN_DIR у .env (рядок замінюється або додається)
    local env_file="$PROJECT_ROOT/.env" v="$1"
    if grep -q '^REMOTE_ADMIN_DIR=' "$env_file"; then
        sed -i "s|^REMOTE_ADMIN_DIR=.*|REMOTE_ADMIN_DIR=${v}|" "$env_file"
    else
        printf '\n# 017: тека адмінки на проді (не публікувати; локально — src/admin/)\nREMOTE_ADMIN_DIR=%s\n' "$v" >> "$env_file"
    fi
}

# Перенести список імен у смітник. $1 — site|home, далі імена.
move_to_trash() {
    local where="$1"; shift
    local base="/${SITE_DIR}"; [ "$where" = "home" ] && base=""
    local dest="/${TRASH}/${STAMP}/${where}"
    local cmds=("*MKD /${TRASH}" "*MKD /${TRASH}/${STAMP}" "*MKD ${dest}") n
    for n in "$@"; do cmds+=("RNFR ${base}/${n}" "RNTO ${dest}/${n}"); done
    ftp_q "${cmds[@]}"
}

# ===========================================================================
if [ "$CMD" = "status" ]; then
    step "Прод: корінь сайту (${SITE_DIR}/)"
    NAMES="$(list_names "$SITE_DIR")"
    [ -n "$NAMES" ] || die "Не вдалося прочитати ${SITE_DIR}/ по FTP"
    if printf '%s\n' "$NAMES" | grep -qx install; then err "install/ є — make sec-cleanup APPLY=1"; else ok "install/ немає"; fi
    JUNK="$(printf '%s\n' "$NAMES" | grep -E "$JUNK_RE" || true)"
    if [ -n "$JUNK" ]; then err "сміття/архіви в корені: $(printf '%s' "$JUNK" | tr '\n' ' ')"; else ok "архівів і копій у корені немає"; fi
    ADMIN_REMOTE="$(remote_rel admin)"
    printf '%s\n' "$NAMES" | grep -qx "$ADMIN_REMOTE" && ok "тека адмінки: ${ADMIN_REMOTE}/ (REMOTE_ADMIN_DIR)" || err "теки адмінки ${ADMIN_REMOTE}/ немає — перевірте REMOTE_ADMIN_DIR"
    if [ "$ADMIN_REMOTE" = "admin" ]; then warn "адмінка за стандартною адресою /admin/ — make sec-rename-admin APPLY=1"; fi
    MAKETS="$(printf '%s\n' "$NAMES" | grep '^maket-' || true)"
    [ -z "$MAKETS" ] || info "превʼю макетів (design-preview, навмисно): $(printf '%s' "$MAKETS" | tr '\n' ' ')"

    step "Прод: домашня тека"
    HOME_NAMES="$(list_names "")"
    printf '%s\n' "$HOME_NAMES" | grep -qx "$OLD_SITE_DIR" && warn "стара тека ${OLD_SITE_DIR}/ є — make sec-retire-online APPLY=1" || ok "старої теки ${OLD_SITE_DIR}/ немає"
    printf '%s\n' "$HOME_NAMES" | grep -qx "$TRASH" && info "смітник ~/${TRASH}/: $(list_names "$TRASH" | tr '\n' ' ') — видаліть у File Manager, коли все перевірено" || true
    printf '%s\n' "$HOME_NAMES" | grep -qx kristal-backup && ok "~/kristal-backup/ є (make backup-status)" || warn "~/kristal-backup/ немає — make backup-install"

    step "HTTP: ${PROD}"
    PATHS=(/install/ /index1.php /admin/); [ "$ADMIN_REMOTE" = "admin" ] || PATHS+=("/${ADMIN_REMOTE}/")
    for p in "${PATHS[@]}"; do
        printf '  %-28s %s\n' "$p" "$(http_code "$PROD$p")"
    done
    info "Повна перевірка: make test-security BASE=${PROD}"
    exit 0
fi

# ===========================================================================
if [ "$CMD" = "cleanup" ]; then
    step "Прибирання кореня сайту (${SITE_DIR}/) → ~/${TRASH}/${STAMP}/site/"
    NAMES="$(list_names "$SITE_DIR")"
    [ -n "$NAMES" ] || die "Не вдалося прочитати ${SITE_DIR}/ по FTP"
    MOVE=()
    printf '%s\n' "$NAMES" | grep -qx install && MOVE+=(install)
    while IFS= read -r n; do [ -n "$n" ] && MOVE+=("$n"); done < <(printf '%s\n' "$NAMES" | grep -E "$JUNK_RE" || true)
    [ "${#MOVE[@]}" -gt 0 ] || { ok "переносити нічого"; exit 0; }
    for n in "${MOVE[@]}"; do printf '  → %s\n' "$n"; done
    warn "error_log і php.ini не чіпаємо: їх веде хостинг (і вони закриті 403)." 
    confirm "Перенести ${#MOVE[@]} об'єкт(и) у смітник"
    move_to_trash site "${MOVE[@]}" || die "FTP-перенесення не вдалося (частина могла перенестись — make sec-status)"
    ok "перенесено в ~/${TRASH}/${STAMP}/site/"
    printf '  /install/   → %s\n' "$(http_code "$PROD/install/")"
    printf '  /           → %s\n' "$(http_code "$PROD/")"
    exit 0
fi

# ===========================================================================
if [ "$CMD" = "retire-online" ]; then
    step "Стара тека ${OLD_SITE_DIR}/ → ~/${TRASH}/${STAMP}/home/"
    list_names "" | grep -qx "$OLD_SITE_DIR" || { ok "теки ${OLD_SITE_DIR}/ немає"; exit 0; }
    # Захист: бойовий сайт не має посилатись на стару теку (DIR_*, storage)
    T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
    for f in config.php "$(remote_rel admin)/config.php"; do
        # shellcheck disable=SC2046
        curl $(ftp_opts) --fail -o "$T/c.php" "$(ftp_url_raw "$f")" 2>/dev/null || die "не вдалося прочитати $f"
        if grep -q "$OLD_SITE_DIR" "$T/c.php"; then die "$f бойового сайту посилається на ${OLD_SITE_DIR} — переносити не можна"; fi
    done
    ok "бойові config.php і конфіг адмінки на ${OLD_SITE_DIR} не посилаються"
    confirm "Перенести ${OLD_SITE_DIR}/ у смітник"
    move_to_trash home "$OLD_SITE_DIR" || die "FTP-перенесення не вдалося"
    ok "перенесено. Повернути: tools/prod-security.sh restore ${TRASH}/${STAMP}/home/${OLD_SITE_DIR} --apply"
    printf '  %s/ → %s\n' "$PROD" "$(http_code "$PROD/")"
    exit 0
fi

# ===========================================================================
if [ "$CMD" = "restore" ]; then
    SRC_PATH="${ARG#/}"; SRC_PATH="${SRC_PATH%/}"
    [[ "$SRC_PATH" =~ ^${TRASH}/[0-9-]+(-[a-z]+)?/(site|home)/([^/]+)$ ]] || die "Шлях виду ${TRASH}/<дата>/site/<ім'я> або …/home/<ім'я>"
    where="${BASH_REMATCH[2]}"; name="${BASH_REMATCH[3]}"
    dest="/${name}"; [ "$where" = "site" ] && dest="/${SITE_DIR}/${name}"
    step "Повернути /${SRC_PATH} → ${dest}"
    confirm "Повернути"
    ftp_q "RNFR /${SRC_PATH}" "RNTO ${dest}" || die "не вдалося (можливо, ${dest} уже існує)"
    ok "повернуто"
    exit 0
fi

# ===========================================================================
# rename-admin
# ===========================================================================
CUR="$(remote_rel admin)"
BK_ROOT="$PROJECT_ROOT/backups/admin-rename"
NAMES="$(list_names "$SITE_DIR")"
[ -n "$NAMES" ] || die "Не вдалося прочитати ${SITE_DIR}/ по FTP"

# Перевірка HTTP: форма входу адмінки за адресою $1
admin_ok() { curl -s --max-time 20 "$PROD/$1/" | grep -q 'route=common/login'; }

if [ "$UNDO" -eq 1 ]; then
    [ "$CUR" != "admin" ] || die "REMOTE_ADMIN_DIR уже admin — повертати нічого"
    ORIG="$(ls -1t "$BK_ROOT"/*/config.php.orig 2>/dev/null | head -1)"
    [ -n "$ORIG" ] || die "Немає бекапу конфігу в backups/admin-rename/"
    printf '%s\n' "$NAMES" | grep -qx "$CUR" || die "На проді немає теки $CUR/"
    printf '%s\n' "$NAMES" | grep -qx admin && die "На проді вже є admin/ — розберіться вручну"
    step "Повернути ${CUR}/ → admin/ і конфіг ${ORIG#"$PROJECT_ROOT"/}"
    confirm "Повернути адмінку"
    ftp_q "RNFR /${SITE_DIR}/${CUR}" "RNTO /${SITE_DIR}/admin" || die "не вдалося перейменувати"
    # shellcheck disable=SC2046
    curl $(ftp_opts) --fail -T "$ORIG" "$(ftp_url_raw admin/config.php)" 2>/dev/null || die "не вдалося залити конфіг — залийте ${ORIG} у admin/config.php вручну"
    set_env_admin admin
    admin_ok admin && ok "адмінка знову на /admin/" || err "/admin/ не показує форму входу — перевірте вручну"
    exit 0
fi

[ "$CUR" = "admin" ] || die "Адмінку вже перейменовано (REMOTE_ADMIN_DIR=$CUR). Відкат: --undo"
printf '%s\n' "$NAMES" | grep -qx admin || die "На проді немає теки admin/"

if [ -z "$NAME" ]; then
    # od, а не tr </dev/urandom | head: з pipefail tr отримує SIGPIPE і скрипт падає (141)
    NAME="kr-$(od -An -N6 -tx1 /dev/urandom | tr -d ' \n')"
fi
[[ "$NAME" =~ ^[a-z0-9][a-z0-9_-]{5,40}$ ]] || die "Назва теки: латиниця/цифри/-/_, 6–41 символ"
printf '%s\n' "$NAMES" | grep -qx "$NAME" && die "Тека $NAME уже є на проді"

BK="$BK_ROOT/$STAMP"; mkdir -p "$BK"; chmod 700 "$BK_ROOT" "$BK"
# У dry-run копія з паролем БД не потрібна — прибираємо на виході
[ "$APPLY" -eq 1 ] || trap 'rm -rf "$BK"; rmdir "$BK_ROOT" 2>/dev/null || true' EXIT
# shellcheck disable=SC2046
curl $(ftp_opts) --fail -o "$BK/config.php.orig" "$(ftp_url_raw admin/config.php)" 2>/dev/null || die "не вдалося забрати admin/config.php"
chmod 600 "$BK/config.php.orig"
sed -E "/define\('(HTTP_SERVER|HTTPS_SERVER|DIR_APPLICATION)'/ s#/admin/'#/${NAME}/'#" "$BK/config.php.orig" > "$BK/config.php.new"
chmod 600 "$BK/config.php.new"
CHANGED="$(diff "$BK/config.php.orig" "$BK/config.php.new" | grep -c '^>' || true)"

step "Перейменування адмінки: admin/ → ${NAME}/"
printf '  Бекап бойового конфігу: %s\n' "${BK#"$PROJECT_ROOT"/}/config.php.orig"
printf '  Зміни в admin/config.php (паролі не показуємо):\n'
diff "$BK/config.php.orig" "$BK/config.php.new" | grep '^[<>]' | grep -v -i pass | sed 's/^/    /' || true
[ "$CHANGED" = "3" ] || die "Очікувалось рівно 3 змінених рядки (HTTP_SERVER, HTTPS_SERVER, DIR_APPLICATION), а є ${CHANGED} — конфіг нестандартний, зробіть вручну"
printf '\n  Нова адреса: %s%s/%s/%s\n' "$C_BOLD" "$PROD" "$NAME" "$C_RESET"
printf '  Збережіть її в менеджері паролів. Менеджери, які зараз в адмінці, вилетять на вхід.\n'
[ "$APPLY" -eq 1 ] || { printf '  (у dry-run назва щоразу нова; задати свою: --name kr-xxxx / make sec-rename-admin NAME=…)\n'; }
confirm "Перейменувати адмінку"

rollback() {
    warn "Відкат: ${NAME}/ → admin/, конфіг із бекапу"
    ftp_q "RNFR /${SITE_DIR}/${NAME}" "RNTO /${SITE_DIR}/admin" || err "не вдалося перейменувати назад — File Manager: ${NAME} → admin"
    # shellcheck disable=SC2046
    curl $(ftp_opts) --fail -T "$BK/config.php.orig" "$(ftp_url_raw admin/config.php)" 2>/dev/null \
        || err "не вдалося повернути конфіг — залийте ${BK}/config.php.orig у admin/config.php"
}

ftp_q "RNFR /${SITE_DIR}/admin" "RNTO /${SITE_DIR}/${NAME}" || die "FTP-перейменування не вдалося — нічого не змінено"
# shellcheck disable=SC2046
if ! curl $(ftp_opts) --fail -T "$BK/config.php.new" "$(ftp_url_raw "${NAME}/config.php")" 2>/dev/null; then
    err "не вдалося залити новий конфіг"; rollback; exit 1
fi

sleep 2
NEW_OK=0; admin_ok "$NAME" && NEW_OK=1
OLD_CODE="$(http_code "$PROD/admin/")"
if [ "$NEW_OK" -ne 1 ]; then
    err "${PROD}/${NAME}/ не показує форму входу"; rollback; exit 1
fi
ok "${PROD}/${NAME}/ — форма входу"
[ "$OLD_CODE" = "404" ] && ok "/admin/ → 404" || warn "/admin/ → ${OLD_CODE} (очікувався 404)"
set_env_admin "$NAME"
ok "REMOTE_ADMIN_DIR=${NAME} записано в .env — деплой тепер заливає адмінку туди"
printf '\n  Далі: увійдіть, «Панель стану → шестерня → Оновити»; make test-security BASE=%s\n' "$PROD"
