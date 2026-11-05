#!/bin/bash
# ---------------------------------------------------------------------------
# Застосувати OCMOD-модифікації (Extensions → Modifications → Refresh).
#
# НАВІЩО ЦЕ ПОТРІБНО
#   Модифікації OpenCart — це не записи в базі, а ЗГЕНЕРОВАНІ ФАЙЛИ в
#   system/storage/modification/. Поки їх немає, сайт виглядає зламаним:
#     * тема малює catalog/view/theme//... (порожня назва теми) — немає стилів;
#     * не рендеряться товари, категорії, банери;
#     * частина сторінок віддає порожній контент із кодом 200.
#   Сама база при цьому цілком здорова — тому виглядає як «зникли товари».
#
#   system/storage/ — це кеш, він у .gitignore і НЕ деплоїться (див.
#   lib.sh:is_protected). Тому після розгортання на чистому сервері
#   модифікації треба застосувати явно. Цей скрипт робить це за вас.
#
# ЯК ЦЕ ПРАЦЮЄ
#   Скрипт іде тим самим шляхом, що й кнопка «Оновити» в адмінці: бере
#   активного адміністратора, тимчасово ставить йому випадковий пароль,
#   логіниться через HTTP на внутрішній порт (127.0.0.1, повз Caddy й basic
#   auth), викликає route=extension/modification/refresh — і одразу повертає
#   пароль назад. Пароль відновлюється навіть якщо скрипт упав (trap).
#
#   Виклик іде на http://127.0.0.1:${WEB_PORT}, тому скрипт однаково працює
#   і локально, і на дев-сервері — жодних доменів і паролів у аргументах.
#
# Використання:
#   make refresh-mods          # там, де запущено стек
#   make dev-refresh-mods      # те саме, але на дев-сервері
# ---------------------------------------------------------------------------

. "$(dirname "$0")/lib.sh"

load_env
require_running

BASE="http://127.0.0.1:${WEB_PORT}"
JAR=""
SAVED_ID=""
SAVED_SALT=""
SAVED_HASH=""
SAVED_CODE=""

# Повернути адміністратору рідні salt/password/code.
# Пароль змінюється лише на кілька секунд, але якщо скрипт обірветься —
# адмін лишився б із випадковим паролем. Тому restore викликається і на вихід.
restore_admin() {
    [ -n "$SAVED_ID" ] || return 0
    sql -e "UPDATE \`${DB_PREFIX}user\`
               SET \`salt\` = '${SAVED_SALT}',
                   \`password\` = '${SAVED_HASH}',
                   \`code\` = '${SAVED_CODE}'
             WHERE \`user_id\` = ${SAVED_ID};" </dev/null >/dev/null 2>&1 || true
    SAVED_ID=""
}
trap 'restore_admin; [ -n "$JAR" ] && rm -f "$JAR"' EXIT

# --- 1. Хто може застосувати модифікації ------------------------------------
# Право modify на extension/modification є у групи Administrator. Серед
# адміністраторів трапляються вимкнені (status = 0) — саме так було на цьому
# сайті: user_id=1 вимкнений, а працюють user_id=7 і 8. Тому беремо лише
# активного й саме з групи Administrator.
step "1/4  Шукаю активного адміністратора"

# Кожне поле беремо окремим запитом. Спокусливо склеїти їх одним
# CONCAT(u.user_id, '\t', u.username, ...), але це крихко: розділювач
# залежить від того, як саме mysql-клієнт обробить escape-послідовність,
# і тоді «user_id» виявляється рівним усьому рядку одразу.
ADMIN_FROM="FROM \`${DB_PREFIX}user\` u
             JOIN \`${DB_PREFIX}user_group\` g ON g.user_group_id = u.user_group_id
            WHERE u.status = '1' AND g.name = 'Administrator'
            ORDER BY u.user_id
            LIMIT 1"

SAVED_ID="$(sql_scalar "SELECT u.user_id ${ADMIN_FROM};")"

if [ -z "$SAVED_ID" ]; then
    die "Немає активного адміністратора (status=1) у групі Administrator.
      Модифікації нікому застосувати. Увімкніть адміністратора в базі:
        UPDATE ${DB_PREFIX}user SET status = 1 WHERE user_id = <id>;"
fi

UNAME="$(sql_scalar "SELECT u.username ${ADMIN_FROM};")"
SAVED_SALT="$(sql_scalar "SELECT u.salt ${ADMIN_FROM};")"
SAVED_HASH="$(sql_scalar "SELECT u.password ${ADMIN_FROM};")"
SAVED_CODE="$(sql_scalar "SELECT IFNULL(u.code, '') ${ADMIN_FROM};")"

ok "адміністратор: $UNAME (user_id=$SAVED_ID)"

# --- 2. Тимчасовий пароль ---------------------------------------------------
step "2/4  Тимчасово змінюю пароль, щоб увійти"

# Формула 1:1 з admin/model/user/user.php і tools/sql/04-local-admin-password.sql:
#   password = sha1(salt . sha1(salt . sha1(plain)))
# Пароль лише з літер і цифр — щоб не залежати від екранування в SQL і shell.
TMP_PASS="mod$(date +%s)$RANDOM$RANDOM"

sql -e "SET @p = '${TMP_PASS}';
        SET @s = SUBSTRING(MD5(RAND()), 1, 9);
        UPDATE \`${DB_PREFIX}user\`
           SET \`salt\` = @s,
               \`password\` = SHA1(CONCAT(@s, SHA1(CONCAT(@s, SHA1(@p))))),
               \`code\` = ''
         WHERE \`user_id\` = ${SAVED_ID};" </dev/null >/dev/null
ok "пароль змінено (буде повернено)"

# --- 3. Логін ---------------------------------------------------------------
step "3/4  Входжу в адмінку"

JAR="$(mktemp)"

login_attempt() {
    local redirect
    redirect="$(curl -sS --max-time 60 -c "$JAR" -b "$JAR" -X POST \
        --data-urlencode "username=$UNAME" \
        --data-urlencode "password=$TMP_PASS" \
        -o /dev/null -w '%{redirect_url}' \
        "$BASE/admin/index.php?route=common/login" 2>/dev/null || true)"
    printf '%s' "$redirect" | grep -oE 'token=[A-Za-z0-9]+' | cut -d= -f2 || true
}

TOKEN="$(login_attempt)"
if [ -z "$TOKEN" ]; then
    # Адмінка могла ще не піднятись (Apache стартує кілька секунд після
    # перезапуску контейнера). Одна повторна спроба дешевша за помилку.
    sleep 3
    TOKEN="$(login_attempt)"
fi

# Повертаємо пароль одразу після логіна: сесія вже видана, далі вона не потрібна.
restore_admin
ok "пароль адміністратора повернено"

[ -n "$TOKEN" ] || die "Логін не вдався — токен не отримано.
      Перевірте, що сайт відповідає:  curl -sI ${BASE}/admin/
      і що контейнер web живий:       docker compose ps"

# --- 4. Refresh -------------------------------------------------------------
step "4/4  Застосовую модифікації"

BEFORE="$(find "$PROJECT_ROOT/src/system/storage/modification" -type f 2>/dev/null | wc -l)"

HTTP_CODE="$(curl -sS --max-time 600 -c "$JAR" -b "$JAR" -o /dev/null -w '%{http_code}' \
    "$BASE/admin/index.php?route=extension/modification/refresh&token=$TOKEN" 2>/dev/null || echo 000)"

AFTER="$(find "$PROJECT_ROOT/src/system/storage/modification" -type f 2>/dev/null | wc -l)"

if [ "$HTTP_CODE" != "200" ]; then
    die "Refresh повернув HTTP $HTTP_CODE (очікували 200).
      Подивіться логи:  make logs-php"
fi

ok "HTTP 200, згенеровано файлів: $AFTER (було $BEFORE)"

# index.html — порожня заглушка, щоб веб-сервер не показував список файлів.
# Refresh її не створює, якщо теки раніше не існувало.
if [ -d "$PROJECT_ROOT/src/system/storage/modification" ] \
   && [ ! -f "$PROJECT_ROOT/src/system/storage/modification/index.html" ]; then
    : > "$PROJECT_ROOT/src/system/storage/modification/index.html"
    ok "створено index.html (заглушка від лістингу теки)"
fi

if [ "$AFTER" -eq 0 ]; then
    warn "Файлів не згенеровано. Або в базі немає модифікацій, або вони всі вимкнені."
    warn "Перевірити:  make db-shell  →  SELECT name, status FROM ${DB_PREFIX}modification;"
fi

printf '\n'
ok "Готово. Модифікації застосовано."
printf '  Якщо сторінка все ще виглядає по-старому — скиньте кеш: make clear-cache\n'
