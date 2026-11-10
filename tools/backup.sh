#!/bin/bash
# ---------------------------------------------------------------------------
# 017: резервні копії на хостингу — встановлення, стан, завантаження. specs/017-security
# Сам бекап робить tools/server/kristal-backup.sh (cron cPanel) у ~/kristal-backup/ поза сайтом.
#
#   tools/backup.sh install        залити скрипт у ~/kristal-backup/ і показати рядок cron
#   tools/backup.sh status         що лежить у ~/kristal-backup/ + кінець журналу
#   tools/backup.sh pull [--files] найновіший дамп бази → dumps/ (далі make import);
#                                  --files — ще й найновіший архів файлів → backups/
# make backup-install | backup-status | backup-pull [FILES=1]
# Інструкція відновлення: docs/04-backup-restore.md
# ---------------------------------------------------------------------------

. "$(dirname "$0")/lib.sh"
load_env
require_ftp

CMD="${1:-}"; shift || true
WITH_FILES=0
[ "${1:-}" = "--files" ] && WITH_FILES=1

KB="kristal-backup"

list() {   # імена в ~/kristal-backup/<тека>, найновіші знизу (імена містять дату)
    # shellcheck disable=SC2046
    curl $(ftp_opts) --fail --list-only "$(ftp_root_url "$KB/$1/")" 2>/dev/null | tr -d '\r' \
        | grep -E "$2" | sort || true
}

get() {   # $1 — шлях від кореня FTP, $2 — куди
    mkdir -p "$(dirname "$2")"
    # shellcheck disable=SC2046
    curl $(ftp_opts) --fail -o "$2" "$(ftp_root_url "$1")" 2>/dev/null
}

case "$CMD" in
install)
    step "Заливаю серверний скрипт у ~/${KB}/"
    # shellcheck disable=SC2046
    curl $(ftp_opts) --fail --ftp-create-dirs -T "$PROJECT_ROOT/tools/server/kristal-backup.sh" \
        "$(ftp_root_url "$KB/kristal-backup.sh")" 2>/dev/null || die "не вдалося залити"
    ok "~/${KB}/kristal-backup.sh"
    printf '\n  cPanel → Cron Jobs → Add New Cron Job:\n'
    printf '    Common Settings: Once Per Day; хвилина 17, година 3\n'
    printf '    Command:  %s/bin/bash $HOME/%s/kristal-backup.sh%s\n' "$C_BOLD" "$KB" "$C_RESET"
    printf '  Email у Cron Jobs → «Cron Email» — туди прийде лист, лише якщо бекап упав.\n'
    printf '  Перший запуск, щоб не чекати ночі: та сама команда з хвилиною «*/5» на 5 хвилин → потім повернути.\n'
    printf '  Перевірка: make backup-status\n'
    ;;
status)
    step "~/${KB}/ на хостингу"
    DBS="$(list db '^db-[0-9-]+\.sql\.gz$')"; FS="$(list files '^files-[0-9-]+\.tar\.gz$')"
    printf '  дампів бази: %s, останній: %s\n' "$(printf '%s' "$DBS" | grep -c . || true)" "$(printf '%s\n' "$DBS" | tail -n 1)"
    printf '  архівів файлів: %s, останній: %s\n' "$(printf '%s' "$FS" | grep -c . || true)" "$(printf '%s\n' "$FS" | tail -n 1)"
    T="$(mktemp)"; trap 'rm -f "$T"' EXIT
    if get "$KB/backup.log" "$T"; then
        printf '\n  Журнал (останні рядки):\n'; tail -n 8 "$T" | sed 's/^/    /'
        grep -q 'ПОМИЛКА' <(tail -n 3 "$T") && { err "останній запуск з помилкою"; exit 1; }
    else
        warn "журналу ще немає — cron не запускався (make backup-install)"
    fi
    LAST="$(printf '%s\n' "$DBS" | tail -n 1 | sed -E 's/^db-([0-9]{8}).*/\1/')"
    if [ -n "$LAST" ] && [ "$LAST" -lt "$(date -d '2 days ago' +%Y%m%d)" ]; then
        err "останньому дампу бази більше 2 днів — cron не працює?"; exit 1
    fi
    ;;
pull)
    NAME="$(list db '^db-[0-9-]+\.sql\.gz$' | tail -n 1)"
    [ -n "$NAME" ] || die "На хостингу немає дампів у ~/${KB}/db/ (make backup-status)"
    step "Завантажую ${NAME} → dumps/"
    get "$KB/db/$NAME" "$PROJECT_ROOT/dumps/prod-$NAME" || die "не вдалося завантажити"
    gzip -t "$PROJECT_ROOT/dumps/prod-$NAME" || die "архів пошкоджений"
    ok "dumps/prod-$NAME ($(du -h "$PROJECT_ROOT/dumps/prod-$NAME" | cut -f1))"
    if [ "$WITH_FILES" -eq 1 ]; then
        FNAME="$(list files '^files-[0-9-]+\.tar\.gz$' | tail -n 1)"
        [ -n "$FNAME" ] || die "Немає архівів файлів"
        info "архів файлів ${FNAME} (сотні МБ, кілька хвилин)…"
        get "$KB/files/$FNAME" "$PROJECT_ROOT/backups/prod-files/$FNAME" || die "не вдалося завантажити"
        ok "backups/prod-files/$FNAME — розпакування: docs/04-backup-restore.md"
    fi
    printf '\n  Відновити локально: make import   (бере найновіший файл із dumps/)\n'
    ;;
*)
    sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'; exit 1 ;;
esac
