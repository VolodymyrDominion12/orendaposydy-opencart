#!/bin/bash
# ---------------------------------------------------------------------------
# Smoke-тести вітрини: коди відповіді, базове SEO, відсутність PHP-помилок,
# 301-редиректи.
#
# Файли:
#   tests/smoke/urls.txt       шлях  код  [allow=h1,canonical]   # коментар
#   tests/smoke/redirects.txt  старий_шлях  новий_шлях
#
# Для сторінок із кодом 200 перевіряється:
#   * рівно один <h1>                       (вимикається allow=h1)
#   * є <title>
#   * немає "Notice:", "Warning:", "Fatal error", "Stack trace", "Parse error"
#   * немає заглушок шаблону "My Great Website", "Site Content"
#   * є rel="canonical" — лише попередження (allow=canonical — тиша)
#
# Використання:
#   tools/test-smoke.sh                              # http://localhost:$WEB_PORT
#   BASE=https://orendaposydy.com tools/test-smoke.sh
# ---------------------------------------------------------------------------

. "$(dirname "$0")/lib.sh"

case "${1:-}" in -h|--help) sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;; esac

if [ -z "${BASE:-}" ]; then
    load_env
    BASE="http://localhost:${WEB_PORT}"
fi
BASE="${BASE%/}"
URLS="$PROJECT_ROOT/tests/smoke/urls.txt"
REDIRECTS="$PROJECT_ROOT/tests/smoke/redirects.txt"
BODY="$(mktemp)"; trap 'rm -f "$BODY"' EXIT

PASS=0; FAIL=0; WARN=0
fail() { err "$1"; FAIL=$((FAIL + 1)); }

step "Smoke: $BASE"

if [ -f "$URLS" ]; then
    while read -r path code opts _rest; do
        case "$path" in ''|\#*) continue ;; esac
        code="${code:-200}"
        case "$opts" in allow=*) allow="${opts#allow=}" ;; *) allow="" ;; esac

        got="$(curl -s -o "$BODY" -w '%{http_code}' --max-time 30 "$BASE$path" || echo 000)"
        if [ "$got" != "$code" ]; then
            fail "$path — HTTP $got, очікувався $code"
            continue
        fi
        problems=""
        if [ "$code" = "200" ]; then
            h1="$( (grep -oi '<h1[ >]' "$BODY" || true) | wc -l | tr -d ' ')"
            if [ "$h1" != "1" ] && [[ ",$allow," != *",h1,"* ]]; then problems+=" h1=$h1;"; fi
            grep -qi '<title>' "$BODY" || problems+=" немає <title>;"
            if grep -qE '(Notice|Warning|Fatal error|Parse error)</b>:|Notice: |Warning: |Fatal error|Stack trace' "$BODY"; then
                problems+=" PHP-помилка в HTML;"
            fi
            grep -q -e 'My Great Website' -e 'Site Content' "$BODY" && problems+=" заглушка шаблону;"
            if ! grep -qi 'rel="canonical"' "$BODY" && [[ ",$allow," != *",canonical,"* ]]; then
                warn "$path — немає rel=\"canonical\""; WARN=$((WARN + 1))
            fi
        fi
        if [ -n "$problems" ]; then fail "$path —$problems"; else ok "$path ($got)"; PASS=$((PASS + 1)); fi
    done < "$URLS"
else
    warn "Немає $URLS"
fi

if [ -f "$REDIRECTS" ]; then
    while read -r from to _rest; do
        case "$from" in ''|\#*) continue ;; esac
        read -r got loc <<< "$(curl -s -o /dev/null -w '%{http_code} %{redirect_url}' --max-time 30 "$BASE$from" || echo '000 -')"
        if [ "$got" = "301" ] && [[ "$loc" == *"$to" ]]; then
            ok "$from → $to (301)"; PASS=$((PASS + 1))
        else
            fail "$from — очікувався 301 → $to, отримано $got → ${loc:-—}"
        fi
    done < "$REDIRECTS"
fi

printf '\n'
if [ "$FAIL" -gt 0 ]; then
    err "Пройшло: $PASS, впало: $FAIL, попереджень: $WARN"
    exit 1
fi
ok "Пройшло: $PASS, впало: 0, попереджень: $WARN"
