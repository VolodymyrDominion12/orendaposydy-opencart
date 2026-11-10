#!/bin/bash
# ---------------------------------------------------------------------------
# 017: перевірки безпеки сайту (specs/017-security AC-1, 2, 4, 8–11, 15).
#
#   tools/test-security.sh                                 # локально: http://localhost:$WEB_PORT
#   BASE=https://orendaposudu.com tools/test-security.sh   # прод
#
# Локально дзеркала емулюються заголовком Host: до localhost (правила .htaccess прив'язані до
# бойових хостів), на проді — справжні адреси. Архів-«пастка» (AC-15) локально створюється в src/
# на час перевірки; на проді перевіряється адреса, якої немає (403/404 — обидва OK).
# Лише GET-запити. Код виходу 1, якщо є FAIL.
# ---------------------------------------------------------------------------

. "$(dirname "$0")/lib.sh"

case "${1:-}" in -h|--help) sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;; esac

MAIN="orendaposudu.com"
MIRRORS="www.orendaposudu.com orendaposydy.com www.orendaposydy.com"
PROBE="/posud/tarilky?k=1&utm_source=t"

if [ -f "$PROJECT_ROOT/.env" ]; then load_env; fi
if [ -z "${BASE:-}" ]; then BASE="http://localhost:${WEB_PORT:-8090}"; fi
BASE="${BASE%/}"
HOST="${BASE#*://}"; HOST="${HOST%%/*}"; HOST="${HOST%%:*}"
LOCAL=0; case "$HOST" in localhost|127.0.0.1) LOCAL=1 ;; esac
HTTPS=0; case "$BASE" in https://*) HTTPS=1 ;; esac
ADMIN_DIR="${REMOTE_ADMIN_DIR:-admin}"

PASS=0; FAIL=0
pass() { ok "$1"; PASS=$((PASS + 1)); }
fail() { err "$1"; FAIL=$((FAIL + 1)); }
HDR="$(mktemp)"; BODY="$(mktemp)"; PROBE_FILE=""
cleanup() { rm -f "$HDR" "$BODY"; [ -z "$PROBE_FILE" ] || rm -f "$PROBE_FILE"; }
trap cleanup EXIT

# GET без переходів: код, Location; заголовки → $HDR, тіло → $BODY
fetch() {   # url [Host]
    local extra=()
    [ -z "${2:-}" ] || extra=(-H "Host: $2")
    curl -s -D "$HDR" -o "$BODY" -w '%{http_code} %{redirect_url}' --max-time 30 "${extra[@]}" "$1" 2>/dev/null || echo "000 -"
}
header() { grep -i "^$1:" "$HDR" | tail -n 1 | cut -d: -f2- | tr -d '\r' | sed 's/^ *//'; }

step "Безпека: $BASE $([ "$LOCAL" -eq 1 ] && echo '(локально, дзеркала через Host:)')"

# --- AC-1, AC-2: службові файли → 404 (403 теж прийнятно: файлу немає або доступ закрито) ---------
for p in /install/ /install/index.php /install/opencart.sql /index1.php /index.svg; do
    read -r code _ <<< "$(fetch "$BASE$p")"
    case "$code" in 404|403) pass "$p → $code" ;; *) fail "$p → $code (очікувалось 404)" ;; esac
done

# --- Закриті з вебу шляхи (не 200) ------------------------------------------------------------
for p in /.env /.git/HEAD /php.ini /.user.ini /error_log /storage_kozak/ /system/storage/ /config.php.bak /backup.sql /kristal-nonexistent.zip; do
    read -r code _ <<< "$(fetch "$BASE$p")"
    case "$code" in 404|403) pass "$p → $code" ;; *) fail "$p → $code (має бути закрито: 403/404)" ;; esac
done

# --- AC-15: справжній архів у корені → 403 (лише локально: на проді файл не створюємо) ------------
if [ "$LOCAL" -eq 1 ] && [ -d "$PROJECT_ROOT/src" ]; then
    for name in kristal-sec-probe.zip kristal-sec-probe.tar.gz kristal-sec-probe.bak config.php.old; do
        PROBE_FILE="$PROJECT_ROOT/src/$name"; echo probe > "$PROBE_FILE"
        read -r code _ <<< "$(fetch "$BASE/$name")"
        rm -f "$PROBE_FILE"; PROBE_FILE=""
        [ "$code" = "403" ] && pass "/$name (існує) → 403" || fail "/$name (існує) → $code (очікувався 403)"
    done
fi

# --- AC-4: адмінка ---------------------------------------------------------------------------
if [ "$LOCAL" -eq 1 ]; then
    read -r code _ <<< "$(fetch "$BASE/admin/")"
    if [ "$code" = "200" ] && grep -q 'route=common/login' "$BODY"; then pass "/admin/ → форма входу (локально адмінка не перейменовується)"; else fail "/admin/ локально → $code"; fi
else
    read -r code _ <<< "$(fetch "$BASE/admin/")"
    [ "$code" = "404" ] && pass "/admin/ → 404" || fail "/admin/ → $code (очікувався 404 — make sec-rename-admin)"
    if [ "$ADMIN_DIR" = "admin" ]; then
        fail "REMOTE_ADMIN_DIR не задано — адмінка не перейменована"
    else
        read -r code _ <<< "$(fetch "$BASE/$ADMIN_DIR/")"
        if [ "$code" = "200" ] && grep -q 'route=common/login' "$BODY"; then pass "/<REMOTE_ADMIN_DIR>/ → форма входу"; else fail "/<REMOTE_ADMIN_DIR>/ → $code"; fi
    fi
fi

# --- AC-8, AC-9: один домен, 301 без ланцюжків ----------------------------------------------------
TARGET="https://$MAIN$PROBE"
check_redirect() {   # label url [Host]
    local code loc
    read -r code loc <<< "$(fetch "$2" "${3:-}")"
    if [ "$code" = "301" ] && [ "$loc" = "$TARGET" ]; then pass "$1 → 301 $TARGET"; else fail "$1 → $code ${loc:-—} (очікувався 301 → $TARGET)"; fi
}
if [ "$LOCAL" -eq 1 ]; then
    for h in $MIRRORS $MAIN; do check_redirect "http://$h$PROBE (Host:)" "$BASE$PROBE" "$h"; done
    read -r code loc <<< "$(fetch "$BASE/.well-known/acme-challenge/kristal" "www.$MAIN")"
    [ "$code" != "301" ] && pass "/.well-known/ на дзеркалі без редиректу ($code)" || fail "/.well-known/ на дзеркалі → 301 $loc"
    read -r code _ <<< "$(fetch "$BASE/")"
    [ "$code" = "200" ] && pass "localhost без редиректу" || fail "localhost → $code"
else
    for h in $MIRRORS; do
        check_redirect "https://$h" "https://$h$PROBE"
        check_redirect "http://$h" "http://$h$PROBE"
    done
    check_redirect "http://$MAIN" "http://$MAIN$PROBE"
    # Кінцева адреса не редиректить далі (шлях-зонд може й не існувати на проді — 404 теж OK)
    read -r code loc <<< "$(fetch "$TARGET")"
    case "$code" in 3*) fail "$TARGET → $code ${loc:-} (ланцюжок редиректів)" ;; 000) fail "$TARGET недоступна" ;; *) pass "$TARGET → $code (кінцева, без ланцюжка)" ;; esac
    read -r code loc <<< "$(fetch "https://www.$MAIN/.well-known/acme-challenge/kristal")"
    [ "$code" != "301" ] && pass "/.well-known/ на дзеркалі без редиректу ($code)" || fail "/.well-known/ на дзеркалі → 301 $loc"
fi

# --- AC-10: заголовки ---------------------------------------------------------------------------
for p in / /kristal-sec-404; do
    fetch "$BASE$p" > /dev/null
    missing=""
    [ "$(header X-Content-Type-Options)" = "nosniff" ] || missing+=" X-Content-Type-Options"
    [ "$(header X-Frame-Options)" = "SAMEORIGIN" ] || missing+=" X-Frame-Options"
    [ "$(header Referrer-Policy)" = "strict-origin-when-cross-origin" ] || missing+=" Referrer-Policy"
    case "$(header Strict-Transport-Security)" in max-age=*) ;; *) missing+=" Strict-Transport-Security" ;; esac
    [ -z "$(header X-Powered-By)" ] || missing+=" (є X-Powered-By: $(header X-Powered-By))"
    [ -z "$missing" ] && pass "$p — заголовки безпеки" || fail "$p — немає:$missing"
done

# --- AC-11: кука сесії ---------------------------------------------------------------------------
check_cookie() {   # label url
    fetch "$2" > /dev/null
    local lines n c
    lines="$(grep -i '^set-cookie: *OCSESSID=' "$HDR" | tr -d '\r')"
    n="$(printf '%s' "$lines" | grep -c . || true)"
    c="$(printf '%s' "$lines" | tr 'A-Z' 'a-z')"
    local bad=""
    [ "$n" = "1" ] || bad+=" Set-Cookie OCSESSID: $n шт.;"
    [[ "$c" == *"; httponly"* ]] || bad+=" немає HttpOnly;"
    if [ "$HTTPS" -eq 1 ]; then
        [[ "$c" == *"; secure"* ]] || bad+=" немає Secure;"
        [[ "$c" == *"samesite=none"* ]] || bad+=" не SameSite=None;"
    else
        [[ "$c" == *"samesite=lax"* ]] || bad+=" не SameSite=Lax;"
    fi
    [ -z "$bad" ] && pass "$1 — OCSESSID: $(printf '%s' "$lines" | sed 's/^[^;]*; //')" || fail "$1 —$bad"
}
check_cookie "/ (вітрина)" "$BASE/"
if [ "$LOCAL" -eq 1 ]; then check_cookie "/admin/ (адмінка)" "$BASE/admin/";
elif [ "$ADMIN_DIR" != "admin" ]; then check_cookie "адмінка" "$BASE/$ADMIN_DIR/"; fi

printf '\n'
if [ "$FAIL" -gt 0 ]; then err "Пройшло: $PASS, впало: $FAIL"; exit 1; fi
ok "Пройшло: $PASS, впало: 0"
