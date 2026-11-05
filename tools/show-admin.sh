#!/bin/bash
# ---------------------------------------------------------------------------
# Показати логін адміністратора локального магазину.
#
# Запуск:  make login-admin
#
# Пароль тут показати неможливо: OpenCart зберігає лише SHA1-хеш із сіллю
# (admin/model/user/user.php), відновити з нього пароль не можна. Тому скрипт
# або показує логін (щоб ви ввели бойовий пароль), або пропонує поставити
# передбачуваний локальний.
# ---------------------------------------------------------------------------

. "$(dirname "$0")/lib.sh"
load_env
require_running

if ! table_exists "${DB_PREFIX}user"; then
    die "Немає таблиці ${DB_PREFIX}user — база не імпортована. Виконайте: make import"
fi

step "Адміністратори локального магазину"
# Простий список, а не таблиця: printf рахує БАЙТИ, а не символи, тому
# кириличні заголовки ламають вирівнювання стовпців.
sql -N -B -e "SELECT CONCAT('  #', user_id, '  ', username, '  <', email, '>  ', firstname, ' ', lastname)
              FROM ${DB_PREFIX}user ORDER BY user_id;" 2>/dev/null

FIRST="$(sql_scalar "SELECT username FROM ${DB_PREFIX}user ORDER BY user_id LIMIT 1;")"

printf '\n'
if [ -n "$FIRST" ]; then
    printf '  Логін:  %s%s%s\n' "$C_BOLD" "$FIRST" "$C_RESET"
fi

warn "Пароль лишився бойовим (з бази прода його не відновити)."
printf '  Поставити локальний пароль (%slocaladmin123%s) для user_id=1:\n' "$C_BOLD" "$C_RESET"
printf '        make localize-admin\n'
printf '\n'
printf '  Змінити пароль на свій — відредагуйте @local_password у\n'
printf '        tools/sql/04-local-admin-password.sql\n'
