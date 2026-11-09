#!/bin/bash
# ---------------------------------------------------------------------------
# Імпорт дампа бойової бази у локальне середовище + локалізація.
#
# Вирішує три реальні проблеми, на яких зазвичай усе застрягає:
#
#   1. НЕВІДОМИЙ ПРЕФІКС ТАБЛИЦЬ.
#      Ви не знаєте, oc_ там чи oc3_. Скрипт читає дамп, знаходить таблиці
#      <prefix>product / <prefix>setting / <prefix>order і сам визначає префікс,
#      після чого оновлює .env.
#
#   2. ДАМП ІЗ MySQL 8 НЕ СТАВИТЬСЯ В MariaDB.
#      phpMyAdmin на хостингу часто віддає кодування utf8mb4_0900_ai_ci, якого
#      MariaDB не знає ("Unknown collation"), і DEFINER у тригерах/в'юшках, на
#      якому імпорт падає з "Access denied for user". Скрипт це вичищає й
#      показує, що саме змінив.
#
#   3. БОЙОВІ НАЛАШТУВАННЯ В БАЗІ.
#      Після імпорту пошта, платежі й аналітика лишаються бойовими. Скрипт
#      одразу застосовує локалізацію (tools/sql/01..03).
#
# Використання:
#   tools/import-db.sh                    # найновіший дамп із dumps/
#   tools/import-db.sh dumps/shop.sql
#   tools/import-db.sh dumps/shop.sql.gz  # .gz і .zip розпаковуються самі
#   tools/import-db.sh --keep             # не видаляти наявну базу перед імпортом
#   tools/import-db.sh --no-localize      # тільки імпорт, без локалізації
# ---------------------------------------------------------------------------

. "$(dirname "$0")/lib.sh"
load_env
require_running

DUMP=""
KEEP_DB=0
LOCALIZE=1

while [ $# -gt 0 ]; do
    case "$1" in
        --keep)        KEEP_DB=1 ;;
        --no-localize) LOCALIZE=0 ;;
        -h|--help)     sed -n '2,32p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        -*)            die "Невідомий параметр: $1" ;;
        *)             DUMP="$1" ;;
    esac
    shift
done

DUMPS_DIR="$PROJECT_ROOT/dumps"
mkdir -p "$DUMPS_DIR"

# --- 1. Знайти дамп ---------------------------------------------------------
if [ -z "$DUMP" ]; then
    DUMP="$(find "$DUMPS_DIR" -maxdepth 1 -type f \
              \( -name '*.sql' -o -name '*.sql.gz' -o -name '*.zip' \) \
              -printf '%T@ %p\n' 2>/dev/null | sort -rn | head -1 | cut -d' ' -f2-)"
    [ -n "$DUMP" ] || die "У теці dumps/ немає .sql / .sql.gz / .zip.
Покладіть туди дамп із phpMyAdmin (Експорт → SQL, стиснення gzip) і повторіть."
    info "Знайдено найновіший дамп: $(basename "$DUMP")"
fi

[ -f "$DUMP" ] || die "Файл не знайдено: $DUMP"

# --- 2. Розпакувати за потреби ----------------------------------------------
WORK="$(mktemp -d)"

# Нижче ми на час імпорту зупиняємо контейнер web. Якщо скрипт упаде посеред
# роботи (наприклад, на локалізації), без цього обробника сайт лишився б
# вимкненим — і `make check` скаржився б на «web НЕ запущено» замість
# справжньої причини. Тому піднімаємо web завжди, як скрипт не завершився.
WEB_STOPPED=0
cleanup() {
    rm -rf "$WORK"
    if [ "$WEB_STOPPED" -eq 1 ]; then
        dc start web >/dev/null 2>&1 || true
    fi
}
trap cleanup EXIT

SQL_FILE="$WORK/dump.sql"

case "$DUMP" in
    *.gz)
        info "Розпаковую gzip…"
        gunzip -c "$DUMP" > "$SQL_FILE"
        ;;
    *.zip)
        info "Розпаковую zip…"
        unzip -p "$DUMP" '*.sql' > "$SQL_FILE" 2>/dev/null \
            || die "У архіві не знайдено .sql файлу"
        ;;
    *)
        cp "$DUMP" "$SQL_FILE"
        ;;
esac

SIZE_IN="$(du -h "$SQL_FILE" | cut -f1)"
info "Розмір дампа: $SIZE_IN"

[ -s "$SQL_FILE" ] || die "Дамп порожній — перевірте, чи експорт пройшов успішно"

# --- 3. Визначити префікс таблиць -------------------------------------------
# Шукаємо таблиці, які точно є в будь-якому OpenCart, і відрізаємо від них
# назву таблиці. Це надійніше, ніж «узяти все до першого підкреслення»:
# префікс може бути shop1_ або oc2_, і тоді евристика помилилася б.
step "1/5  Визначаю префікс таблиць"
DETECTED_PREFIX=""
for core in setting product order customer; do
    # \`oc_setting\`  →  oc_
    found="$(grep -oiE 'CREATE TABLE `[A-Za-z0-9_]*'"$core"'`' "$SQL_FILE" 2>/dev/null \
             | head -1 | sed -E 's/.*`([A-Za-z0-9_]*)'"$core"'`.*/\1/')"
    if [ -n "$found" ]; then
        DETECTED_PREFIX="$found"
        break
    fi
done

if [ -z "$DETECTED_PREFIX" ]; then
    warn "Не вдалося визначити префікс — у дампі немає звичних таблиць OpenCart."
    warn "Перевірте, що це справді дамп OpenCart, а не бекап іншого сайту."
    DETECTED_PREFIX="$DB_PREFIX"
elif [ "$DETECTED_PREFIX" != "$DB_PREFIX" ]; then
    warn "У .env префікс '${DB_PREFIX}', а в дампі — '${DETECTED_PREFIX}'."
    info "Оновлюю DB_PREFIX у .env, інакше локалізація пішла б по чужих таблицях."
    sed -i "s/^DB_PREFIX=.*/DB_PREFIX=${DETECTED_PREFIX}/" "$PROJECT_ROOT/.env"
    DB_PREFIX="$DETECTED_PREFIX"
    export DB_PREFIX
else
    ok "префікс таблиць: ${DB_PREFIX}"
fi

TABLES_COUNT="$(grep -ciE '^CREATE TABLE' "$SQL_FILE" || true)"
info "Таблиць у дампі: ${TABLES_COUNT}"

# --- 4. Вичистити несумісності MySQL 8 → MariaDB ----------------------------
step "2/5  Перевіряю сумісність із MariaDB"
FIXED="$WORK/dump.fixed.sql"
cp "$SQL_FILE" "$FIXED"
CHANGES=0

# 4.1. Кодування utf8mb4_0900_* існує лише в MySQL 8. MariaDB його не знає
#      і зупиняє імпорт на першій же таблиці.
if grep -qE 'utf8mb4_0900|utf8mb4_zh_0900|utf8mb4_ja_0900' "$FIXED"; then
    COUNT="$(grep -cE 'utf8mb4(_zh|_ja)?_0900' "$FIXED" || true)"
    info "  • кодування MySQL 8 (utf8mb4_0900_*) → utf8mb4_general_ci  [$COUNT рядків]"
    sed -i -E 's/utf8mb4(_zh|_ja)?_0900_[a-z_]+/utf8mb4_general_ci/g' "$FIXED"
    CHANGES=$((CHANGES+1))
fi

# 4.2. DEFINER=`user`@`host` — на локальному сервері такого користувача немає,
#      тому CREATE TRIGGER/VIEW/PROCEDURE падає з "Access denied".
if grep -q 'DEFINER=' "$FIXED"; then
    COUNT="$(grep -c 'DEFINER=' "$FIXED" || true)"
    info "  • DEFINER=\`user\`@\`host\` → прибрано  [$COUNT входжень]"
    # Локальний користувач OpenCart не має прав CREATE ROUTINE/TRIGGER із
    # чужим DEFINER. Прибираємо конструкцію повністю.
    sed -i -E 's/DEFINER=`[^`]*`@`[^`]*`//g; s/DEFINER=[^ ]*//g' "$FIXED"
    CHANGES=$((CHANGES+1))
fi

# 4.3. Змінні сесії MySQL 8, яких немає в MariaDB — імпорт на них спотикається.
if grep -qE 'SQL_LOG_BIN|GTID_PURGED|@@GLOBAL\.gtid' "$FIXED"; then
    info "  • прибираю SET SQL_LOG_BIN / GTID_PURGED (немає в MariaDB)"
    sed -i -E '/SET @@SESSION\.SQL_LOG_BIN/d; /SET @@GLOBAL\.GTID_PURGED/d' "$FIXED"
    CHANGES=$((CHANGES+1))
fi

# 4.4. Кодування utf8mb3 (старе ім'я utf8) — MariaDB 10.6 його не приймає
#      там, де очікує повне ім'я.
if grep -q 'utf8mb3' "$FIXED"; then
    info "  • utf8mb3 → utf8mb4"
    sed -i 's/utf8mb3/utf8mb4/g' "$FIXED"
    CHANGES=$((CHANGES+1))
fi

if [ "$CHANGES" -eq 0 ]; then
    ok "дамп сумісний як є, правок не потрібно"
else
    warn "внесено правок: $CHANGES (це нормально для дампів із MySQL 8)"
fi

# --- 5. Імпорт ---------------------------------------------------------------
step "3/5  Імпортую в базу '${DB_NAME}'"
info "Зупиняю веб-контейнер, щоб він не писав у базу під час імпорту…"
dc stop web >/dev/null 2>&1 || true
WEB_STOPPED=1

if [ "$KEEP_DB" -eq 1 ]; then
    info "Режим --keep: наявні таблиці не видаляю"
else
    info "Перестворюю базу (чистий імпорт, без залишків попереднього)…"
    dc exec -T db mysql -uroot -p"${DB_ROOT_PASSWORD:-root}" -e "
        DROP DATABASE IF EXISTS \`${DB_NAME}\`;
        CREATE DATABASE \`${DB_NAME}\`
            CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
        GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
        FLUSH PRIVILEGES;" 2>/dev/null \
        || die "Не вдалося перестворити базу. Перевірте DB_ROOT_PASSWORD у .env"
fi

info "Заливаю дамп (це може зайняти кілька хвилин)…"
# --force не використовуємо: краще побачити помилку, ніж отримати напів-базу.
if ! dc exec -T db mysql -u"$DB_USER" -p"$DB_PASSWORD" \
        --default-character-set=utf8mb4 \
        --init-command="SET SESSION sql_mode='NO_ENGINE_SUBSTITUTION'" \
        "$DB_NAME" < "$FIXED"; then
    die "Імпорт упав. Дивіться помилку вище.
Якщо це 'Unknown collation' або 'Access denied' — надішліть мені текст помилки,
додам правило у розділ 4 цього скрипта."
fi
ok "дамп залито"

# --- 6. Локалізація ----------------------------------------------------------
# Кожен крок локалізації підписуємо: якщо SQL упаде, з виводу mysql не видно,
# до якого саме файлу він належить, і доводиться вгадувати.
run_localize() {
    local file="$1" label="$2"
    if ! sql_file "$PROJECT_ROOT/tools/sql/$file"; then
        die "Локалізація впала на кроці «${label}» (tools/sql/${file}).
Помилку SQL дивіться вище. База вже імпортована, веб-контейнер піднято назад.
Виправте SQL і повторіть лише локалізацію:  make localize"
    fi
    ok "$label"
}

if [ "$LOCALIZE" -eq 1 ]; then
    step "4/5  Локалізую під localhost"
    run_localize 01-urls-and-store.sql    "URL, SSL, режим обслуговування, аналітика, сесії"
    run_localize 02-mail-to-mailpit.sql   "пошта → Mailpit (локальні листи не підуть клієнтам)"
    sql_file "$PROJECT_ROOT/tools/sql/03-disable-live-services.sql" >/dev/null \
        || die "Локалізація впала на кроці «вимкнення бойових сервісів» (tools/sql/03-disable-live-services.sql).
Помилку SQL дивіться вище. Повторити локалізацію:  make localize"
    ok "платежі, доставка, captcha, аналітика — вимкнено"
else
    step "4/5  Локалізацію пропущено (--no-localize)"
    warn "НЕ оформлюйте замовлення й не тестуйте пошту, поки не виконаєте: make localize"
fi

# --- 7. Кеш і конфіг ---------------------------------------------------------
step "5/5  Скидаю кеш і перезапускаю"
# Спершу піднімаємо web: make-config.sh і clear-cache.sh працюють через
# `docker compose exec web`, а ми його зупиняли на час імпорту. Якщо цей
# порядок переплутати, конфіг після імпорту не перегенерується (тихо, бо
# помилка глушиться), і сайт лишиться зі старим префіксом таблиць.
dc start web >/dev/null 2>&1 || true
WEB_STOPPED=0
sleep 3

"$(dirname "$0")/make-config.sh" >/dev/null 2>&1 || true
"$(dirname "$0")/clear-cache.sh" >/dev/null 2>&1 || true
# .htaccess із прода зазвичай примусово кидає на https — локально це 301
# у нікуди. Крок ідемпотентний: якщо правил немає, нічого не зміниться.
"$(dirname "$0")/localize-htaccess.sh" >/dev/null 2>&1 || true

# --- Підсумок ---------------------------------------------------------------
step "Імпорт завершено"
info "База:  ${DB_NAME}  (префікс ${DB_PREFIX}, таблиць ${TABLES_COUNT})"

ADMIN_ROWS="$(sql_scalar "SELECT CONCAT(username, ' <', email, '>') FROM ${DB_PREFIX}user ORDER BY user_id LIMIT 3;" || true)"
[ -n "$ADMIN_ROWS" ] && printf '  Адміністратори: %s\n' "$(echo "$ADMIN_ROWS" | tr '\n' ' ')"

PRODUCTS="$(sql_scalar "SELECT COUNT(*) FROM ${DB_PREFIX}product;" || echo '?')"
ORDERS="$(sql_scalar "SELECT COUNT(*) FROM ${DB_PREFIX}order;" || echo '?')"
CUSTOMERS="$(sql_scalar "SELECT COUNT(*) FROM ${DB_PREFIX}customer;" || echo '?')"
printf '  Товарів: %s | Замовлень: %s | Покупців: %s\n' "$PRODUCTS" "$ORDERS" "$CUSTOMERS"

warn "Пароль адміністратора лишився бойовим. Щоб поставити локальний:"
printf '        make localize-admin\n'

show_urls
