#!/bin/bash
# ---------------------------------------------------------------------------
# Мобільний аудит вітрини (tests/mobile/mobile-audit.cjs, Playwright).
#
# Використання:
#   tools/test-mobile.sh                    # сторінки з tests/mobile/pages.txt
#   URL=/mebli tools/test-mobile.sh         # одна сторінка
#   BASE=https://orendaposydy.com tools/test-mobile.sh
#   tools/test-mobile.sh --setup            # встановити Playwright + Chromium (один раз)
# ---------------------------------------------------------------------------

. "$(dirname "$0")/lib.sh"

DIR="$PROJECT_ROOT/tests/mobile"

case "${1:-}" in
    -h|--help) sed -n '2,10p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    --setup)
        command -v npm >/dev/null || die "Потрібен Node.js 18+ (npm). Ubuntu: sudo apt install nodejs npm, або nvm."
        step "Встановлюю Playwright у tests/mobile/"
        npm --prefix "$DIR" install --no-audit --no-fund
        ( cd "$DIR" && npx playwright install chromium )
        ok "Готово. Запуск: make test-mobile"
        exit 0 ;;
esac

command -v node >/dev/null || die "Потрібен Node.js 18+. Потім: make mobile-setup"
[ -d "$DIR/node_modules/playwright" ] || die "Playwright не встановлено. Один раз:  make mobile-setup"

if [ -z "${BASE:-}" ]; then
    load_env
    BASE="http://localhost:${WEB_PORT}"
fi
export BASE
node "$DIR/mobile-audit.cjs" "$BASE"
