#!/bin/bash
# ---------------------------------------------------------------------------
# Показати макети з design/ замовнику: залити їх окремою текою на сайт через FTP.
#
# Використання:
#   tools/design-preview.sh                    # dry-run: що і куди поїде
#   tools/design-preview.sh --apply            # залити
#   tools/design-preview.sh --apply maket-x7k2 # залити в конкретну теку
#
# Результат: https://<домен>/<тека>/  (домен = FTP_REMOTE_DIR або PROD_URL з .env)  (за замовчуванням тека maket-<випадкові символи>,
# назва запам'ятовується в backups/design-preview-dir, щоб наступна заливка
# оновила ту саму адресу).
#
# Що робить:
#   1. збирає design/pages/ (python3 design/build.py);
#   2. складає самодостатню копію: tokens.css кладе поруч, виправляє посилання;
#   3. додає .htaccess теки: noindex для пошуковиків і заборона перегляду списку файлів;
#   4. заливає файли по одному через tools/ftp-put.sh (~20 файлів, FTP не блокує).
#
# Сайт OpenCart не зачіпається: файли лягають лише в окрему теку в корені сайту.
# Прибрати після показу: tools/ftp-rm.sh <тека> (і видалити порожню теку у File Manager).
# ---------------------------------------------------------------------------

. "$(dirname "$0")/lib.sh"

APPLY=0
DIR=""
for a in "$@"; do
    case "$a" in
        --apply) APPLY=1 ;;
        -h|--help) sed -n '2,22p' "$0"; exit 0 ;;
        *) DIR="$a" ;;
    esac
done

STATE="$PROJECT_ROOT/backups/design-preview-dir"
if [ -z "$DIR" ] && [ -f "$STATE" ]; then DIR="$(cat "$STATE")"; fi
if [ -z "$DIR" ]; then DIR="maket-$(od -An -N4 -tx4 /dev/urandom | tr -d ' \n')"; fi
case "$DIR" in
    *[!a-zA-Z0-9_-]*|"") die "Назва теки — лише латиниця, цифри, - і _: $DIR" ;;
    admin*|catalog*|system*|image*|install*|storage*|vqmod*) die "Відмова: «$DIR» збігається з текою OpenCart." ;;
esac
mkdir -p "$PROJECT_ROOT/backups"; printf '%s\n' "$DIR" > "$STATE"   # та сама тека в dry-run і --apply

step "1. Збираю макети"
python3 "$PROJECT_ROOT/design/build.py" >/dev/null || die "Не вдалося зібрати design/ (python3 design/build.py)"
ok "design/pages/ оновлено"

step "2. Готую самодостатню копію"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
mkdir -p "$TMP/pages" "$TMP/assets"
cp "$PROJECT_ROOT"/design/index.html "$TMP/"
cp "$PROJECT_ROOT"/design/pages/*.html "$TMP/pages/"
cp "$PROJECT_ROOT"/design/assets/* "$TMP/assets/"
cp "$PROJECT_ROOT"/docs/brandbook/tokens.css "$TMP/assets/tokens.css"
# посилання на брендбук → локальна копія токенів
sed -i 's#\.\./docs/brandbook/tokens\.css#assets/tokens.css#' "$TMP/index.html"
sed -i 's#\.\./\.\./docs/brandbook/tokens\.css#../assets/tokens.css#' "$TMP"/pages/*.html
grep -rq 'brandbook/tokens.css"' "$TMP" && die "Лишилися посилання на docs/brandbook — перевірте шаблон сторінок."
cat > "$TMP/.htaccess" <<'HT'
# Макети для замовника — не індексувати, не показувати список файлів.
Options -Indexes
DirectoryIndex index.html
<IfModule mod_headers.c>
  Header set X-Robots-Tag "noindex, nofollow"
</IfModule>
HT
FILES="$(cd "$TMP" && find . -type f | sed 's#^\./##' | sort)"
COUNT="$(printf '%s\n' "$FILES" | wc -l | tr -d ' ')"
ok "$COUNT файлів"

load_env
require_ftp
SITE="${PROD_URL:-https://${FTP_REMOTE_DIR}}"   # SITE_URL у .env — локальний, тому беремо домен із FTP_REMOTE_DIR

step "3. Куди"
printf '  FTP:   %s/%s/\n' "${FTP_REMOTE_DIR}" "$DIR"
printf '  URL:   %s/%s/\n' "${SITE%/}" "$DIR"
printf '%s\n' "$FILES" | sed 's/^/    /'

if [ "$APPLY" -ne 1 ]; then
    printf '\n%sDry-run: нічого не залито.%s Залити: tools/design-preview.sh --apply\n' "$C_YELLOW" "$C_RESET"
    exit 0
fi

printf '\nЗалити %s файлів у теку «%s» на прод? [y/N] ' "$COUNT" "$DIR"
read -r ans
[ "$ans" = "y" ] || [ "$ans" = "Y" ] || die "Скасовано."

step "4. Заливаю"
while IFS= read -r f; do
    bash "$PROJECT_ROOT/tools/ftp-put.sh" "$TMP/$f" "$DIR/$f" || die "Зупинено на $f"
    ok "$f"
done <<< "$FILES"

step "Готово"
printf '  Посилання для замовника: %s%s/%s/%s\n' "$C_BOLD" "${SITE%/}" "$DIR" "$C_RESET"
printf '  Прибрати після показу:   tools/ftp-rm.sh %s\n' "$DIR"
