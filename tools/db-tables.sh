#!/bin/bash
# ---------------------------------------------------------------------------
# Показати, які таблиці є в локальній базі, і вгадати префікс OpenCart.
#
# Запуск:  make db-tables
#
# Потрібно, коли незрозуміло, чи база імпортована і чи правильний DB_PREFIX
# у .env. Найчастіша причина «сайт білий після імпорту» — саме невірний префікс.
# ---------------------------------------------------------------------------

. "$(dirname "$0")/lib.sh"
load_env
require_running

COUNT="$(sql_scalar "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='${DB_NAME}';" || echo 0)"
step "База '${DB_NAME}': таблиць ${COUNT}"

if [ "${COUNT:-0}" = "0" ]; then
    warn "База порожня."
    printf '\n  Залити дамп із прода:  покладіть файл у dumps/ і виконайте make import\n'
    exit 0
fi

info "Перші 25 таблиць:"
sql -e "SHOW TABLES;" 2>/dev/null | head -26 | sed 's/^/    /'

# --- Визначити префікс -------------------------------------------------------
DETECTED="$(sql_scalar "SELECT table_name FROM information_schema.tables
    WHERE table_schema='${DB_NAME}' AND table_name LIKE '%\_setting' LIMIT 1;" || true)"

if [ -n "$DETECTED" ]; then
    GUESS="${DETECTED%setting}"
    printf '\n'
    ok "Схоже, префікс таблиць: '${GUESS}'"
    if [ "$GUESS" != "$DB_PREFIX" ]; then
        problem_msg="У .env зараз DB_PREFIX='${DB_PREFIX}', а в базі '${GUESS}'."
        err "$problem_msg"
        printf '        Виправте .env і перезапустіть:\n'
        printf '          sed -i "s/^DB_PREFIX=.*/DB_PREFIX=%s/" .env\n' "$GUESS"
        printf '          make restart && make check\n'
    else
        ok "збігається з DB_PREFIX у .env"
    fi
else
    printf '\n'
    warn "Не знайдено таблиці '*_setting' — це може бути не база OpenCart."
fi

# --- Розмір ------------------------------------------------------------------
SIZE="$(sql_scalar "SELECT ROUND(SUM(data_length + index_length)/1024/1024, 1)
    FROM information_schema.tables WHERE table_schema='${DB_NAME}';" || echo '?')"
printf '\n  Розмір бази: %s МБ\n' "$SIZE"
