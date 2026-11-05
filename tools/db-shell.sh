#!/bin/bash
# ---------------------------------------------------------------------------
# Консоль MySQL у контейнері db.
#
# Запуск:  make db-shell
#
# Зручніше, ніж Adminer, коли треба швидко щось перевірити:
#   SHOW TABLES;
#   SELECT * FROM oc_setting WHERE `key` LIKE 'config_mail%';
#
# Вийти: \q або Ctrl+D
# ---------------------------------------------------------------------------

. "$(dirname "$0")/lib.sh"
load_env

if ! dc ps --status running --services 2>/dev/null | grep -qx db; then
    die "Контейнер db не запущений. Виконайте: make up"
fi

printf '%sКонсоль MySQL%s — база %s, користувач %s. Вихід: \\q або Ctrl+D\n\n' \
    "$C_BOLD" "$C_RESET" "$DB_NAME" "$DB_USER"

# -it дає інтерактивний термінал; без нього mysql не покаже запрошення.
dc exec -e MYSQL_PWD="$DB_PASSWORD" db \
    mysql -u"$DB_USER" --default-character-set=utf8mb4 "$DB_NAME"
