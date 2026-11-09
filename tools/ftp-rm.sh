#!/bin/bash
# ---------------------------------------------------------------------------
# Очистити теку на проді через FTP (рекурсивно).
#
# Використання:  tools/ftp-rm.sh system/storage/cache
#
# Навіщо: після правки .twig або CSS OpenCart тримає скомпільовані шаблони в
# system/storage/cache/. Поки вони там, ви бачите стару версію сторінки.
#
# ВАЖЛИВО, і це неочевидно:
#   НЕ спрямовуйте цей скрипт на system/storage/modification/. Там лежать
#   згенеровані файли ваших OCMOD-модифікаторів. Якщо їх видалити, модифікації
#   перестануть діяти, поки ви не натиснете
#   Адмінка → Розширення → Модифікатори → «Оновити».
#   Для кешу модифікаторів правильний інструмент — саме та кнопка.
#
# НАЙПРОСТІШИЙ СПОСІБ усе одно кращий:
#   Адмінка → Панель стану → шестерня вгорі справа → «Оновити»
#   Ця кнопка чистить і кеш, і SASS, і модифікації — одразу й коректно.
#   Цей скрипт потрібен, коли адмінка недоступна або працює надто повільно.
# ---------------------------------------------------------------------------

. "$(dirname "$0")/lib.sh"
load_env
require_ftp

REL="${1#/}"
[ -n "$REL" ] || die "Використання: ftp-rm.sh <тека-на-сайті>"

case "$REL" in
    system/storage/modification*)
        die "Відмова: це кеш OCMOD-модифікаторів.
Видалення вимкне ваші модифікації. Скористайтесь адмінкою:
Розширення → Модифікатори → «Оновити»." ;;
    config.php*|admin/config.php*)
        die "Відмова: config.php на проді містить бойові доступи до БД." ;;
esac

MAXDEPTH=6
DELETED=0
FAILED=0

# Надіслати одну FTP-команду серверу (DELE / RMD).
# curl не має прямого «видалити», тому використовуємо -Q — команда йде
# в тому ж з'єднанні.
send_cmd() {
    local cmd="$1"
    # shellcheck disable=SC2046
    curl $(ftp_opts) -Q "$cmd" "ftp://${FTP_HOST}:${FTP_PORT:-21}/" -o /dev/null 2>/dev/null
}

list_dir() {
    # shellcheck disable=SC2046
    curl $(ftp_opts) --fail "$(ftp_url "$1")/" 2>/dev/null
}

delete_recursive() {
    local rel="$1" depth="$2"
    if [ "$depth" -gt "$MAXDEPTH" ]; then
        warn "досягнуто глибину $MAXDEPTH на $rel — лишаю як є"
        return 0
    fi

    local listing
    listing="$(list_dir "$rel")" || return 0
    [ -n "$listing" ] || return 0

    local line name
    while IFS= read -r line; do
        [ -n "$line" ] || continue
        case "$line" in total*) continue ;; esac

        # Розбір рядка FTP LIST. Назва — останнє поле.
        # Застереження: імена з пробілами розберуться неправильно. Для кешу
        # OpenCart (cache.catalog.language.123, template/) це не проблема.
        name="$(printf '%s' "$line" | awk '{print $NF}')"
        [ -n "$name" ] || continue
        case "$name" in .|..) continue ;; esac

        if [ "${line:0:1}" = "d" ]; then
            delete_recursive "$rel/$name" $((depth + 1))
            if send_cmd "RMD $(ftp_abs "$rel/$name")"; then
                DELETED=$((DELETED + 1))
            else
                FAILED=$((FAILED + 1))
            fi
        else
            if send_cmd "DELE $(ftp_abs "$rel/$name")"; then
                DELETED=$((DELETED + 1))
            else
                FAILED=$((FAILED + 1))
            fi
        fi
    done <<< "$listing"
}

step "Очищення '$REL' на проді"
delete_recursive "$REL" 0

ok "видалено об'єктів: $DELETED"
[ "$FAILED" -gt 0 ] && warn "не вдалося видалити: $FAILED (частину FTP-серверів це блокує)"

printf '\n'
info "Простіша альтернатива на майбутнє:"
printf '        Адмінка → Панель стану → шестерня → «Оновити»\n'
