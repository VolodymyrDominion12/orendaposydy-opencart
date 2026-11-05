#!/bin/bash
# ---------------------------------------------------------------------------
# Зібрати ZIP-архів зі змінами — для завантаження через файловий менеджер панелі.
#
# Коли це потрібно:
#   * FTP повільний або заблокований, а у вас є лише файловий менеджер cPanel;
#   * треба передати зміни колезі або зберегти реліз як артефакт;
#   * потрібен «пакет», який можна прикласти до задачі в трекері.
#
# Коли НЕ потрібно: для звичайного деплою краще tools/deploy.sh --apply —
# він робить бекап прода і не чіпає захищені файли.
#
# Використання:
#   tools/package-release.sh                 # зміни з git
#   tools/package-release.sh --since v1.0
#   tools/package-release.sh --files manifest.json,image/catalog/logo/icon-192.png
# ---------------------------------------------------------------------------

. "$(dirname "$0")/lib.sh"
load_env

SINCE=""
FILES_ARG=""

while [ $# -gt 0 ]; do
    case "$1" in
        --since)   SINCE="$2"; shift ;;
        --files)   FILES_ARG="$2"; shift ;;
        -h|--help) sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *)         die "Невідомий параметр: $1" ;;
    esac
    shift
done

SRC="$PROJECT_ROOT/src"
command -v zip >/dev/null 2>&1 || die "Потрібен zip (встановіть: sudo apt install zip)"

step "1/2  Визначаю список файлів"
LIST="$(mktemp)"
trap 'rm -f "$LIST"' EXIT

if ! collect_changes "$SINCE" "$FILES_ARG" > "$LIST"; then
    die "Не вдалося визначити список файлів.

Причини:
  • немає git-репозиторію, і не задано --files чи --since;
  • заданий --since '$SINCE' не існує в цьому репозиторії.

Приклад:
  tools/package-release.sh --files manifest.json,header-snippet.html"
fi

# Фільтруємо захищені шляхи
FILTERED="$(mktemp)"
trap 'rm -f "$LIST" "$FILTERED"' EXIT
SKIPPED=0

while IFS= read -r rel; do
    [ -n "$rel" ] || continue
    if is_protected "$rel"; then
        warn "пропущено: $rel — $(protect_reason "$rel")"
        SKIPPED=$((SKIPPED + 1))
        continue
    fi
    [ -f "$SRC/$rel" ] || { warn "немає локально: $rel"; continue; }
    printf '%s\n' "$rel" >> "$FILTERED"
done < "$LIST"

sort -u -o "$FILTERED" "$FILTERED"
COUNT="$(wc -l < "$FILTERED" | tr -d ' ')"
[ "$COUNT" -gt 0 ] || die "Немає файлів для пакування"

step "2/2  Збираю архів"
STAMP="$(date +%Y%m%d-%H%M%S)"
RELEASE_DIR="$PROJECT_ROOT/backups"
mkdir -p "$RELEASE_DIR"
OUT="$RELEASE_DIR/release-${STAMP}.zip"

# Пакуємо з тими самими відносними шляхами, як на сервері, тому архів можна
# розпакувати прямо в корінь сайту.
( cd "$SRC" && zip -q -9 "$OUT" -@ < "$FILTERED" )

# Інструкція всередину архіву — щоб через місяць не згадувати, що це за файл.
# Файл мусить мати СВОЮ назву: mktemp дає ім'я виду tmp.fLvYjQVv6z, і zip -j
# поклав би його в архів саме під ним.
WORK_INSTR="$(mktemp -d)"
INSTR="$WORK_INSTR/ІНСТРУКЦІЯ-як-залити.txt"
trap 'rm -f "$LIST" "$FILTERED"; rm -rf "$WORK_INSTR"' EXIT
cat > "$INSTR" <<EOF
Реліз orendaposydy.com (OpenCart)
Зібрано: $(date '+%Y-%m-%d %H:%M:%S')
Файлів:  $COUNT

ЯК ЗАЛИТИ
---------
1. ЗРОБІТЬ БЕКАП. Панель хостингу -> Бекапи -> створити бекап файлів і БД.
   Без цього кроку не продовжуйте.

2. Розпакуйте цей архів у КОРІНЬ сайту (там, де index.php).
   Файловий менеджер: завантажити zip -> Витягти (Extract) -> у теку сайту.

3. Якщо серед файлів є .ocmod.xml — він НЕ ставиться розпакуванням:
   Адмінка -> Розширення -> Встановлення розширень -> завантажити файл,
   потім Розширення -> Модифікатори -> кнопка «Оновити».

4. Скиньте кеш:
   Адмінка -> Панель стану -> шестерня вгорі справа -> «Оновити»

5. Перевірте сайт: https://orendaposydy.com/

ВМІСТ АРХІВУ
-----------
$(sed 's/^/  /' "$FILTERED")
EOF

( cd "$(dirname "$INSTR")" && zip -q -j "$OUT" "$INSTR" )

SIZE="$(du -h "$OUT" | cut -f1)"
printf '\n'
ok "архів: ${OUT#"$PROJECT_ROOT"/}  (${SIZE}, файлів ${COUNT})"
[ "$SKIPPED" -gt 0 ] && warn "захищених файлів пропущено: $SKIPPED"
printf '\n'
info "Далі: завантажте архів через файловий менеджер панелі та розпакуйте в корінь сайту."
