#!/bin/bash
# ---------------------------------------------------------------------------
# Усі перевірки перед «готово» (AGENTS.md §6):
#   lint (PHP 7.3 + 8.3 наперед) → test-lib → db-check → db-schema diff → migrate status → smoke → мобільний
# Кроки виконуються всі, навіть якщо один упав; exit 1, якщо впав хоч один.
# ---------------------------------------------------------------------------

. "$(dirname "$0")/lib.sh"
load_env
require_running

T="$PROJECT_ROOT/tools"
declare -a NAMES=() RESULTS=()

run() {
    local name="$1"; shift
    printf '\n%s━━ %s ━━%s\n' "$C_BOLD" "$name" "$C_RESET"
    if "$@"; then RESULTS+=("OK"); else RESULTS+=("FAIL"); fi
    NAMES+=("$name")
}

run "PHP lint 7.3 + 8.3"   bash "$T/lint-php.sh"
run "Тести бібліотеки"     bash "$T/test-lib.sh"
run "Аудит схеми"         bash "$T/db-check.sh"
run "Схема vs знімок"     bash "$T/db-schema.sh" diff
run "Статус міграцій"     bash "$T/migrate.sh" status
run "Smoke вітрини"       bash "$T/test-smoke.sh"
run "Мобільний аудит"     bash "$T/test-mobile.sh"

step "Підсумок"
FAIL=0
for i in "${!NAMES[@]}"; do
    if [ "${RESULTS[$i]}" = "OK" ]; then ok "${NAMES[$i]}"; else err "${NAMES[$i]}"; FAIL=1; fi
done
[ "$FAIL" -eq 0 ] && printf '\n  Додайте профіль зачеплених сторінок: make db-profile URL=/...\n'
exit "$FAIL"
