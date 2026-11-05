#!/bin/bash
# ---------------------------------------------------------------------------
# Застосувати локалізацію до вже імпортованої бази.
#
# Потрібно, якщо ви:
#   * імпортували дамп із --no-localize;
#   * залили дамп вручну через Adminer;
#   * хочете повернути безпечні налаштування після експериментів.
#
# Використання:
#   tools/localize-db.sh            # URL/SSL, пошта, вимкнення бойових сервісів
#   tools/localize-db.sh --admin    # ще й локальний пароль адміністратора
# ---------------------------------------------------------------------------

. "$(dirname "$0")/lib.sh"
load_env
require_running

SET_ADMIN=0
while [ $# -gt 0 ]; do
    case "$1" in
        --admin)   SET_ADMIN=1 ;;
        -h|--help) sed -n '2,16p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *)         die "Невідомий параметр: $1" ;;
    esac
    shift
done

# Перевіряємо, що в базі взагалі є OpenCart із таким префіксом. Інакше скрипти
# мовчки нічого не зроблять, і ви шукатимете причину.
if ! table_exists "${DB_PREFIX}setting"; then
    die "У базі '${DB_NAME}' немає таблиці ${DB_PREFIX}setting.
Або база ще не імпортована, або в .env неправильний DB_PREFIX (зараз: ${DB_PREFIX}).
Подивитись реальні таблиці:  make db-tables"
fi

step "Локалізація бази '${DB_NAME}' (префікс ${DB_PREFIX})"

# Таблиця сесій є не в кожній базі: типово OpenCart 3 тримає сесії у файлах
# (адаптер 'native' у system/library/session.php). Файл 01 враховує це сам,
# але краще сказати вголос — інакше «чому в базі немає oc_session» знову
# виглядатиме як поломка.
if table_exists "${DB_PREFIX}session"; then
    info "таблиця ${DB_PREFIX}session існує — скину її вміст"
else
    info "таблиці ${DB_PREFIX}session немає — це нормально, сесії файлові"
fi

sql_file "$PROJECT_ROOT/tools/sql/01-urls-and-store.sql" \
    || die "Крок 01 (URL/SSL/сесії) упав — дивіться помилку SQL вище"
ok "HTTPS-примус вимкнено, режим обслуговування вимкнено, аналітика обнулена, сесії скинуті"

sql_file "$PROJECT_ROOT/tools/sql/02-mail-to-mailpit.sql" \
    || die "Крок 02 (пошта) упав — дивіться помилку SQL вище"
ok "пошта → Mailpit на mailpit:1025 (листи нікуди не підуть)"

sql_file "$PROJECT_ROOT/tools/sql/03-disable-live-services.sql" >/dev/null \
    || die "Крок 03 (вимкнення бойових сервісів) упав — дивіться помилку SQL вище"
ok "платежі, доставка, captcha, аналітика, фід — вимкнено"

# --- Перевірка, що справді застосувалось ------------------------------------
step "Перевірка"
ENGINE="$(sql_scalar "SELECT value FROM ${DB_PREFIX}setting WHERE \`key\`='config_mail_engine';")"
HOST="$(sql_scalar "SELECT value FROM ${DB_PREFIX}setting WHERE \`key\`='config_mail_smtp_hostname';")"
PORT="$(sql_scalar "SELECT value FROM ${DB_PREFIX}setting WHERE \`key\`='config_mail_smtp_port';")"
SECURE="$(sql_scalar "SELECT value FROM ${DB_PREFIX}setting WHERE \`key\`='config_secure';")"

[ "$ENGINE" = "smtp" ] && [ "$HOST" = "mailpit" ] \
    && ok "пошта: ${ENGINE}://${HOST}:${PORT}" \
    || warn "пошта налаштована не так: engine='${ENGINE}' host='${HOST}' port='${PORT}'"

[ "$SECURE" = "0" ] \
    && ok "примусовий HTTPS вимкнено" \
    || warn "config_secure='${SECURE}' — сайт може редиректити на прод"

STILL_ON="$(sql_scalar "SELECT COUNT(*) FROM ${DB_PREFIX}setting
    WHERE \`key\` LIKE 'payment\_%\_status' AND value='1';")"
[ "$STILL_ON" = "0" ] \
    && ok "усі платіжні модулі вимкнено" \
    || warn "увімкнених платіжних модулів: ${STILL_ON}"

# --- Пароль адміністратора ---------------------------------------------------
if [ "$SET_ADMIN" -eq 1 ]; then
    step "Ставлю локальний пароль адміністратора"
    sql_file "$PROJECT_ROOT/tools/sql/04-local-admin-password.sql" \
        || die "Крок 04 (пароль адміністратора) упав — дивіться помилку SQL вище"
    ok "пароль змінено на локальний (див. tools/sql/04-local-admin-password.sql)"
fi

printf '\n'
ok "Локалізацію застосовано."
if [ "$SET_ADMIN" -eq 0 ]; then
    printf '  Пароль адміністратора лишився бойовим. Локальний: make localize-admin\n'
fi
