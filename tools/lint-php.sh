#!/bin/bash
# ---------------------------------------------------------------------------
# Перевірка PHP-файлів на сумісність із продом (PHP 7.3).
#
# Локальний контейнер — PHP 7.4, тому `php -l` у ньому пропустить arrow
# functions, typed properties, `??=` тощо, які на проді дадуть Parse error.
# Тут синтаксис перевіряє справжній php:7.3-cli (Docker-образ), а ще
# шукаються функції PHP 8, які 7.3 розбере, але впаде на виконанні.
#
# Використання:
#   tools/lint-php.sh             # змінені .php у src/ (git: незакомічені + останній комміт)
#   ALL=1 tools/lint-php.sh       # усі НАШІ файли: *kristal* і тема kristal
#   FILES="a.php,b.php" ...       # конкретні файли (шляхи відносно src/)
#   LINT_PHP_IMAGE=php:7.3-cli    # інший образ
# ---------------------------------------------------------------------------

. "$(dirname "$0")/lib.sh"

case "${1:-}" in -h|--help) sed -n '2,16p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;; esac

IMAGE="${LINT_PHP_IMAGE:-php:7.3-cli}"
SRC="$PROJECT_ROOT/src"

if [ -n "${FILES:-}" ]; then
    LIST="$(printf '%s\n' "$FILES" | tr ',' '\n' | sed 's/^ *//; s/ *$//' | grep -v '^$' || true)"
elif [ "${ALL:-0}" = "1" ]; then
    LIST="$(cd "$SRC" && find . -name '*.php' \( -path '*kristal*' -o -path './catalog/view/theme/kristal/*' \) \
            -not -path './system/storage/*' -not -path './storage_kozak/*' | sed 's|^\./||' | sort || true)"
else
    LIST="$(collect_changes "" "" 2>/dev/null | grep -E '\.php$' || true)"
fi

# лише наявні файли
FOUND=()
while IFS= read -r f; do
    [ -n "$f" ] && [ -f "$SRC/$f" ] && FOUND+=("$f")
done <<< "$LIST"

if [ "${#FOUND[@]}" -eq 0 ]; then
    ok "PHP-файлів для перевірки немає"
    exit 0
fi

step "PHP 7.3 lint: ${#FOUND[@]} файл(ів), образ ${IMAGE}"
command -v docker >/dev/null || die "Потрібен docker"

FAIL=0
# 1) Синтаксис — один контейнер на всі файли
OUT="$(docker run --rm -v "$SRC:/app:ro" -w /app "$IMAGE" sh -c '
    rc=0
    for f in "$@"; do
        r="$(php -d display_errors=1 -l "$f" 2>&1)" || { echo "$r" | grep -v "^Errors parsing"; rc=1; }
    done
    exit $rc' sh "${FOUND[@]}" 2>&1)" || FAIL=1
if [ "$FAIL" -eq 1 ]; then
    err "Синтаксичні помилки під PHP 7.3:"
    printf '%s\n' "$OUT" | sed 's/^/    /' >&2
else
    ok "синтаксис OK"
fi

# 2) Функції, яких немає в PHP 7.3 (розбираються, але падають на виконанні)
PHP8_FUNCS='str_contains|str_starts_with|str_ends_with|array_is_list|get_debug_type|fdiv|get_resource_id|mb_str_split|password_algos'
HITS="$(cd "$SRC" && grep -nE "(^|[^a-zA-Z0-9_>:\$])(${PHP8_FUNCS})[[:space:]]*\(" "${FOUND[@]}" 2>/dev/null \
        | grep -vE "function[[:space:]]+(${PHP8_FUNCS})" || true)"
if [ -n "$HITS" ]; then
    err "Функції, недоступні в PHP 7.3 (на проді — Fatal error):"
    printf '%s\n' "$HITS" | sed 's/^/    /' >&2
    FAIL=1
else
    ok "функцій PHP 7.4+/8 не знайдено"
fi

exit "$FAIL"
