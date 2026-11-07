#!/bin/bash
# ---------------------------------------------------------------------------
# Тести бібліотеки Kristal\* (system/library/kristal/, фіча 019): tests/lib/*_test.php
#
#   1) у контейнері web (PHP як локально, є БД → тести Rate_limit на справжній таблиці);
#   2) у php:7.3-cli (як прод), без БД — тести з БД там пропускаються (SKIP).
#
# Використання:
#   tools/test-lib.sh                    # усі тести
#   tools/test-lib.sh phone              # лише ті, де у файлі/назві є «phone»
#   TEST_LIB_PROD_IMAGE=""               # не запускати прохід під PHP 7.3
# Тести з БД потребують застосованої міграції 0004 (make migrate).
# ---------------------------------------------------------------------------

. "$(dirname "$0")/lib.sh"

case "${1:-}" in -h|--help) sed -n '2,13p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;; esac

FILTER="${1:-${T:-}}"
PROD_IMAGE="${TEST_LIB_PROD_IMAGE-php:7.3-cli}"
TESTS="$PROJECT_ROOT/tests/lib"
TMP_IN_WEB="/tmp/kristal-test-lib"

[ -f "$TESTS/run.php" ] || die "Немає $TESTS/run.php"

load_env
require_running

FAIL=0

step "Тести бібліотеки: контейнер web (з БД)"
# tests/ не змонтована в контейнер — копіюємо в /tmp і прибираємо після
dc exec -T web rm -rf "$TMP_IN_WEB" >/dev/null 2>&1 || true
dc cp "$TESTS" "web:$TMP_IN_WEB" >/dev/null || die "Не вдалося скопіювати tests/lib у контейнер web"
if ! dc exec -T -e KRISTAL_SRC=/var/www/html web php "$TMP_IN_WEB/run.php" $FILTER; then
    FAIL=1
fi
dc exec -T web rm -rf "$TMP_IN_WEB" >/dev/null 2>&1 || true

if [ -n "$PROD_IMAGE" ]; then
    step "Тести бібліотеки: ${PROD_IMAGE} (прод), без БД"
    command -v docker >/dev/null || die "Потрібен docker"
    if ! docker run --rm \
            -v "$PROJECT_ROOT/src:/app/src:ro" \
            -v "$TESTS:/app/tests/lib:ro" \
            -e KRISTAL_SRC=/app/src \
            -w /app "$PROD_IMAGE" php tests/lib/run.php $FILTER; then
        FAIL=1
    fi
fi

if [ "$FAIL" -eq 0 ]; then ok "Тести бібліотеки зелені"; else err "Є падіння тестів бібліотеки"; fi
exit "$FAIL"
