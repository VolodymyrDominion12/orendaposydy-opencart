#!/bin/bash
# ---------------------------------------------------------------------------
# Деплой змін на прод (orendaposydy.com) з бекапом і попереднім переглядом.
#
# ФІЛОСОФІЯ
#   За замовчуванням скрипт НІЧОГО НЕ ЗМІНЮЄ. Він лише показує, які файли
#   поїдуть на сервер. Щоб справді залити — треба явно додати --apply.
#   Це головна відмінність від «залив через FileZilla і сподіваюсь».
#
#   Перед перезаписом кожен файл СКАЧУЄТЬСЯ з прода в backups/<дата>/.
#   Якщо щось пішло не так — ви можете повернути файли назад тим самим скриптом
#   (--rollback).
#
# ЩО НІКОЛИ НЕ ДЕПЛОЇТЬСЯ (навіть якщо ви попросите)
#   config.php, admin/config.php  — на проді там бойові доступи до БД;
#                                   локальна версія вказує на localhost і
#                                   ПОВНІСТЮ ЗЛАМАЄ САЙТ.
#   system/storage/               — кеш, логи, сесії, завантаження, і головне
#                                   згенеровані OCMOD-модифікації.
#   image/cache/                  — прев'ю зображень, генеруються на місці.
#   .htaccess                     — правила хостингу (є окремий прапорець).
#
# ВИКОРИСТАННЯ
#   tools/deploy.sh                          # показати, що поїде (dry-run)
#   tools/deploy.sh --apply                  # залити
#   tools/deploy.sh --files catalog/a.php,catalog/b.twig
#   tools/deploy.sh --since v1.2             # усе, що змінилось від тегу v1.2
#   tools/deploy.sh --sql tools/sql/fix.sql  # підготувати SQL для phpMyAdmin
#   tools/deploy.sh --clear-cache --apply    # залити + очистити кеш на проді
#   tools/deploy.sh --rollback backups/2026-10-05-1200
# ---------------------------------------------------------------------------

. "$(dirname "$0")/lib.sh"
load_env

SRC="$PROJECT_ROOT/src"

APPLY=0
ROLLBACK_DIR=""
SQL_FILE=""
SINCE=""
FILES_ARG=""
CLEAR_CACHE=0
INCLUDE_HTACCESS=0

while [ $# -gt 0 ]; do
    case "$1" in
        --apply)            APPLY=1 ;;
        --rollback)         ROLLBACK_DIR="$2"; shift ;;
        --sql)              SQL_FILE="$2"; shift ;;
        --since)            SINCE="$2"; shift ;;
        --files)            FILES_ARG="$2"; shift ;;
        --clear-cache)      CLEAR_CACHE=1 ;;
        --include-htaccess) INCLUDE_HTACCESS=1 ;;
        -h|--help)          sed -n '2,38p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *)                  die "Невідомий параметр: $1" ;;
    esac
    shift
done

# ---------------------------------------------------------------------------
# Захисний список (is_protected / protect_reason) живе в tools/lib.sh —
# він спільний для deploy.sh і package-release.sh, щоб правила не розійшлися.
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Відкат
# ---------------------------------------------------------------------------
if [ -n "$ROLLBACK_DIR" ]; then
    [ -d "$ROLLBACK_DIR" ] || die "Немає теки $ROLLBACK_DIR"
    command -v curl >/dev/null || die "Потрібен curl"

    step "Відкат із $ROLLBACK_DIR"
    warn "Файли з бекапу будуть залиті на прод, перезаписавши поточні версії."
    [ "$APPLY" -eq 1 ] || { info "Це dry-run. Додайте --apply, щоб виконати."; }

    COUNT=0
    while IFS= read -r f; do
        rel="${f#"$ROLLBACK_DIR"/}"
        is_protected "$rel" && { warn "пропускаю захищений шлях: $rel"; continue; }
        printf '  ← %s\n' "$rel"
        if [ "$APPLY" -eq 1 ]; then
            "$(dirname "$0")/ftp-put.sh" "$f" "$rel" || die "не вдалося залити $rel"
        fi
        COUNT=$((COUNT+1))
    done < <(find "$ROLLBACK_DIR" -type f | sort)

    ok "файлів до відкату: $COUNT"
    exit 0
fi

# ---------------------------------------------------------------------------
# SQL для phpMyAdmin
# ---------------------------------------------------------------------------
if [ -n "$SQL_FILE" ]; then
    [ -f "$SQL_FILE" ] || die "Немає файлу $SQL_FILE"
    OUT="$PROJECT_ROOT/backups/for-phpmyadmin-$(basename "${SQL_FILE%.sql}")-$(date +%Y%m%d-%H%M%S).sql"
    mkdir -p "$PROJECT_ROOT/backups"
    sed "s/{{PREFIX}}/${DB_PREFIX}/g" "$SQL_FILE" > "$OUT"

    step "SQL підготовлено"
    ok "файл: $OUT"
    printf '\n'
    printf '%sВАЖЛИВО перед виконанням:%s\n' "$C_BOLD" "$C_RESET"
    printf '  1. Спершу зробіть бекап бойової бази:\n'
    printf '     phpMyAdmin на хостингу → ваша база → Експорт → Go\n'
    printf '  2. Перевірте, що префікс таблиць у файлі — %s\n' "$DB_PREFIX"
    printf '  3. phpMyAdmin → база → SQL → вставити вміст файлу → Go\n'
    printf '\n  Префікс у файлі вже підставлено автоматично (%s).\n' "$DB_PREFIX"
    exit 0
fi

# ---------------------------------------------------------------------------
# Визначити список файлів
# ---------------------------------------------------------------------------
step "1/4  Визначаю, що деплоїти"

LIST_FILE="$(mktemp)"
trap 'rm -f "$LIST_FILE"' EXIT

if [ -n "$FILES_ARG" ]; then
    info "список задано вручну (--files)"
elif [ -n "$SINCE" ]; then
    info "файли, змінені від '$SINCE'"
elif git -C "$PROJECT_ROOT" rev-parse --git-dir >/dev/null 2>&1; then
    info "файли зі змінами в git (незакомічені + останній коміт)"
else
    info "git не знайдено"
fi

if ! collect_changes "$SINCE" "$FILES_ARG" > "$LIST_FILE"; then
    die "Не вдалося визначити список файлів.

Причини:
  • немає git-репозиторію, і не задано --files чи --since;
  • заданий --since '$SINCE' не існує в цьому репозиторії.

Варіанти:
  tools/deploy.sh --files catalog/view/theme/sauco/stylesheet/custom.css
  tools/deploy.sh --since v1.0
Або почніть вести історію:
  cd $PROJECT_ROOT && git init && git add -A && git commit -m 'Початковий стан'"
fi

# Прибираємо захищені шляхи; про кожен голосно повідомляємо.
FILTERED="$(mktemp)"
PROTECTED_HITS=0
while IFS= read -r rel; do
    [ -n "$rel" ] || continue
    if is_protected "$rel"; then
        warn "ПРОПУЩЕНО: $rel  — $(protect_reason "$rel")"
        PROTECTED_HITS=$((PROTECTED_HITS+1))
        continue
    fi
    printf '%s\n' "$rel" >> "$FILTERED"
done < "$LIST_FILE"

sort -u -o "$FILTERED" "$FILTERED"

# ---------------------------------------------------------------------------
# Показати план
# ---------------------------------------------------------------------------
TOTAL=0
MISSING=0
PLAN="$(mktemp)"
while IFS= read -r rel; do
    [ -n "$rel" ] || continue
    if [ -f "$SRC/$rel" ]; then
        size="$(du -h "$SRC/$rel" | cut -f1)"
        printf '  + %-72s %s\n' "$rel" "$size" >> "$PLAN"
        TOTAL=$((TOTAL+1))
    else
        printf '  - %-72s (видалено локально — на проді НЕ видаляється автоматично)\n' "$rel" >> "$PLAN"
        MISSING=$((MISSING+1))
    fi
done < "$FILTERED"

if [ "$TOTAL" -eq 0 ]; then
    printf '\n'
    if [ "$PROTECTED_HITS" -gt 0 ]; then
        warn "Немає що деплоїти: усі зміни — у захищених шляхах (див. вище)."
    elif [ "$MISSING" -gt 0 ]; then
        warn "Усі зміни — це ВИДАЛЕНІ локально файли."
        warn "Цей скрипт ніколи не видаляє файли на проді автоматично."
        printf '        Видаліть їх вручну через файловий менеджер панелі.\n'
    else
        info "Немає змін для деплою. Усе вже синхронізовано."
    fi
    exit 0
fi

step "2/4  План деплою"
cat "$PLAN"
printf '\n  Файлів до заливки: %s\n' "$TOTAL"
[ "$MISSING" -gt 0 ] && printf '  Відсутніх локально (не чіпаємо): %s\n' "$MISSING"

if [ "$APPLY" -eq 0 ]; then
    printf '\n'
    info "Це DRY-RUN. Нічого не змінилось."
    printf '  Щоб залити:  tools/deploy.sh --apply\n'
    if [ "$DEPLOY_METHOD" = "zip" ]; then
        printf '  Або зібрати архів:  tools/package-release.sh\n'
    fi
    exit 0
fi

# ---------------------------------------------------------------------------
# Підтвердження
# ---------------------------------------------------------------------------
step "3/4  Підтвердження"
printf 'Залити %s файл(ів) на ПРОД %s?\n' "$TOTAL" "${FTP_HOST:-?}"
printf 'Спершу буде зроблено бекап поточних версій із прода.\n'
printf 'Введіть %sYES%s для продовження: ' "$C_BOLD" "$C_RESET"
read -r confirm
[ "$confirm" = "YES" ] || { info "Скасовано."; exit 0; }

case "$DEPLOY_METHOD" in
    ftp) ;;
    zip)
        info "DEPLOY_METHOD=zip — заливка не виконується."
        printf '  Зберіть архів і завантажте через файловий менеджер панелі:\n'
        printf '        tools/package-release.sh\n'
        exit 0 ;;
    *)   die "DEPLOY_METHOD='${DEPLOY_METHOD}' не підтримується (ftp або zip)" ;;
esac

[ -n "$FTP_HOST" ] || die "FTP_HOST не задано в .env"
[ -n "$FTP_USER" ] || die "FTP_USER не задано в .env"

# ---------------------------------------------------------------------------
# Бекап + заливка
# ---------------------------------------------------------------------------
BACKUP_DIR="$PROJECT_ROOT/backups/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

step "4/4  Бекап і заливка"
info "Бекап поточних версій із прода → ${BACKUP_DIR#"$PROJECT_ROOT"/}"

BACKED=0
while IFS= read -r rel; do
    [ -f "$SRC/$rel" ] || continue
    if "$(dirname "$0")/ftp-get.sh" "$rel" "$BACKUP_DIR/$rel" 2>/dev/null; then
        BACKED=$((BACKED+1))
    else
        # Файлу на проді ще немає (новий файл) — це нормально.
        printf '    (нового файлу %s на проді немає)\n' "$rel"
    fi
done < "$FILTERED"
ok "з прода забрано файлів: $BACKED"

info "Заливаю…"
PUSHED=0
while IFS= read -r rel; do
    [ -f "$SRC/$rel" ] || continue
    "$(dirname "$0")/ftp-put.sh" "$SRC/$rel" "$rel" || die "не вдалося залити $rel"
    PUSHED=$((PUSHED+1))
done < "$FILTERED"
ok "залито файлів: $PUSHED"

# --- Очистити кеш на проді ---------------------------------------------------
# На цьому сайті DIR_STORAGE = storage_kozak/ (не стандартний system/storage),
# тому шлях беремо з .env: REMOTE_STORAGE_DIR.
if [ "$CLEAR_CACHE" -eq 1 ]; then
    STORAGE="${REMOTE_STORAGE_DIR:-system/storage}"
    info "Очищаю кеш OpenCart на проді (${STORAGE}/cache)…"
    "$(dirname "$0")/ftp-rm.sh" "${STORAGE}/cache" || warn "не вдалося очистити кеш — зробіть це в адмінці"
fi

# ---------------------------------------------------------------------------
# Що зробити далі
# ---------------------------------------------------------------------------
step "Залито. Не забудьте:"
printf '  • Twig/CSS зміни: Адмінка → Панель стану → шестерня → «Оновити»\n'
printf '    (або: tools/deploy.sh --clear-cache --apply)\n'
printf '  • Якщо додали .ocmod.xml: він НЕ заливається через FTP.\n'
printf '    Адмінка → Розширення → Встановлення розширень → завантажити файл,\n'
printf '    потім Розширення → Модифікатори → «Оновити».\n'
printf '  • Перевірте сайт: https://orendaposydy.com/\n'
printf '\n  Відкат, якщо щось зламалось:\n'
printf '        tools/deploy.sh --rollback %s --apply\n' "${BACKUP_DIR#"$PROJECT_ROOT"/}"
