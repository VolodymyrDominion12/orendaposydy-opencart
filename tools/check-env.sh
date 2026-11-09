#!/bin/bash
# ---------------------------------------------------------------------------
# Діагностика локального середовища.
#
# Запуск:  make check
#
# Перевіряє все, що зазвичай ламається, і каже, ЩО САМЕ робити, а не просто
# «щось не так».
# ---------------------------------------------------------------------------

. "$(dirname "$0")/lib.sh"
load_env

PROBLEMS=0
problem() { err "$*"; PROBLEMS=$((PROBLEMS + 1)); }

step "1. Контейнери"
RUNNING="$(dc ps --status running --services 2>/dev/null || true)"
for svc in web db adminer mailpit; do
    if printf '%s\n' "$RUNNING" | grep -qx "$svc"; then
        ok "$svc запущено"
    else
        problem "$svc НЕ запущено  →  make up"
    fi
done

if ! printf '%s\n' "$RUNNING" | grep -qx web; then
    printf '\n'
    err "Без контейнера web перевіряти нічого. Виконайте: make up"
    printf '        Якщо ви щойно робили make import і він упав — це наслідок:\n'
    printf '        імпорт на час заливки зупиняє web. Підніміть його:  make up\n'
    exit 1
fi

step "2. PHP і розширення"
PHPV="$(dc exec -T web php -r 'echo PHP_VERSION;' 2>/dev/null | tr -d '\r')"
ok "PHP ${PHPV}"

MISSING=""
for e in mysqli pdo_mysql gd zip curl mbstring xml dom intl soap xsl; do
    dc exec -T web php -m 2>/dev/null | grep -qix "$e" || MISSING="$MISSING $e"
done
if [ -n "$MISSING" ]; then
    problem "немає розширень PHP:$MISSING  →  make build"
else
    ok "усі розширення OpenCart на місці"
fi

IV="$(dc exec -T web php -r 'echo ini_get("max_input_vars");' 2>/dev/null | tr -d '\r')"
if [ "${IV:-0}" -ge 3000 ] 2>/dev/null; then
    ok "max_input_vars = ${IV} (достатньо для товарів із багатьма опціями)"
else
    warn "max_input_vars = ${IV} — замало для товарів із великою кількістю опцій"
fi

# ionCube — не «ще одне розширення», а вимога цього магазину: частина файлів
# Simple/FilterIt зашифрована, і без завантажувача вони друкують помилку
# замість роботи (при цьому код відповіді 200 — див. крок 7).
if dc exec -T web php -m 2>/dev/null | grep -qi 'ioncube'; then
    ok "ionCube Loader підключено (потрібен для Simple / FilterIt)"
else
    problem "немає ionCube Loader — зашифровані файли Simple / FilterIt не запустяться  →  make build"
fi

step "3. Apache"
if dc exec -T web apache2ctl -M 2>/dev/null | grep -q rewrite_module; then
    ok "mod_rewrite увімкнено (потрібно для SEO-URL)"
else
    problem "mod_rewrite вимкнено  →  make build"
fi
if dc exec -T web grep -q 'AllowOverride All' /etc/apache2/apache2.conf 2>/dev/null; then
    ok "AllowOverride All (працює .htaccess)"
else
    problem "AllowOverride не All — .htaccess ігнорується  →  make build"
fi

step "4. Файли OpenCart"
if dc exec -T web test -f /var/www/html/index.php 2>/dev/null; then
    ok "index.php на місці"
else
    problem "у src/ немає index.php — скопіюйте файли сайту (docs/01)"
fi
if dc exec -T web test -f /var/www/html/config.php 2>/dev/null; then
    ok "config.php існує"

    # Перевіряємо не «мітку генератора», а те, що справді має значення:
    # чи збігається адреса сайту в config.php з тією, за якою ви відкриваєте
    # localhost. Саме розбіжність тут і дає редирект на прод.
    CFG_URL="$(dc exec -T web php -r "include '/var/www/html/config.php'; echo HTTP_SERVER;" 2>/dev/null | tr -d '\r')"
    EXPECT="http://localhost:${WEB_PORT}/"

    if [ "$CFG_URL" = "$EXPECT" ]; then
        ok "HTTP_SERVER = ${CFG_URL} — збігається"
    else
        problem "у config.php HTTP_SERVER='${CFG_URL}', а очікується '${EXPECT}'"
        printf '        Це дасть редирект на прод. Виправлення:  make config\n'
    fi
else
    problem "немає config.php  →  make config"
fi

for d in system/storage system/storage/cache system/storage/modification image/cache; do
    if dc exec -T web test -w "/var/www/html/$d" 2>/dev/null; then
        ok "$d доступний для запису"
    else
        problem "$d недоступний для запису  →  make restart"
    fi
done

step "5. База даних"
if table_exists "${DB_PREFIX}setting"; then
    ok "таблиця ${DB_PREFIX}setting існує (префікс правильний)"
    PROD="$(sql_scalar "SELECT COUNT(*) FROM ${DB_PREFIX}product;")"
    ORD="$(sql_scalar "SELECT COUNT(*) FROM ${DB_PREFIX}order;")"
    ok "товарів: ${PROD}, замовлень: ${ORD}"
else
    problem "немає таблиці ${DB_PREFIX}setting — база не імпортована або префікс інший"
    printf '        Переглянути таблиці:  make db-tables\n'
    printf '        Імпортувати дамп:     make import\n'
fi

step "6. Безпека локального середовища"
ENGINE="$(sql_scalar "SELECT value FROM ${DB_PREFIX}setting WHERE \`key\`='config_mail_engine';" 2>/dev/null)"
HOSTN="$(sql_scalar "SELECT value FROM ${DB_PREFIX}setting WHERE \`key\`='config_mail_smtp_hostname';" 2>/dev/null)"
if [ "$HOSTN" = "mailpit" ]; then
    ok "пошта йде в Mailpit — листи не підуть реальним клієнтам"
else
    problem "ПОШТА НЕ ПЕРЕНАПРАВЛЕНА (engine='${ENGINE}' host='${HOSTN}')"
    printf '        НЕ оформлюйте замовлення, поки не виправите:  make localize\n'
fi

PAY="$(sql_scalar "SELECT COUNT(*) FROM ${DB_PREFIX}setting WHERE \`key\` LIKE 'payment\_%\_status' AND value='1';" 2>/dev/null)"
if [ "${PAY:-0}" = "0" ]; then
    ok "платіжні модулі вимкнено"
else
    problem "увімкнених платіжних модулів: ${PAY} — можуть піти на бойовий API"
    printf '        Виправлення:  make localize\n'
fi

SEC="$(sql_scalar "SELECT value FROM ${DB_PREFIX}setting WHERE \`key\`='config_secure';" 2>/dev/null)"
if [ "$SEC" = "0" ]; then
    ok "примусовий HTTPS вимкнено"
else
    problem "config_secure='${SEC}' — сайт може редиректити на прод  →  make localize"
fi

step "7. HTTP"
# Код відповіді сам по собі бреше: OpenCart і ionCube віддають сторінку помилки
# з кодом 200. Тому дивимось і на тіло — інакше «вітрина віддає HTTP 200»
# показувало б зелений статус для сайту, який у браузері не відкривається.
BODY_FILE="$(mktemp)"
CODE="$(curl -s -o "$BODY_FILE" -m 15 -w '%{http_code}' "http://localhost:${WEB_PORT}/" 2>/dev/null || echo 000)"
if [ "$CODE" = "200" ]; then
    if grep -qi 'ionCube PHP Loader needs to be installed' "$BODY_FILE"; then
        problem "вітрина віддає заглушку ionCube (HTTP 200, але це не магазин)"
        printf '        У src/ є зашифровані файли (Simple / FilterIt), а в образі немає\n'
        printf '        завантажувача ionCube. Саме тому код відповіді 200 — це легко проґавити.\n'
        printf '        Виправлення:  make build\n'
    elif grep -qE '(Fatal error|Parse error|Uncaught [A-Za-z]+Error)' "$BODY_FILE"; then
        problem "вітрина віддає PHP-помилку замість сторінки"
        grep -m1 -oE '(Fatal error|Parse error|Uncaught [A-Za-z]+Error)[^<]{0,140}' "$BODY_FILE" \
            | sed 's/^/        /'
        printf '        Логи з подробицями:  make logs-php\n'
    else
        ok "вітрина віддає HTTP 200 і справжню сторінку"
    fi
elif [ "$CODE" = "302" ] || [ "$CODE" = "301" ]; then
    LOC="$(curl -s -o /dev/null -m 15 -w '%{redirect_url}' "http://localhost:${WEB_PORT}/" 2>/dev/null)"
    problem "вітрина редиректить ($CODE → $LOC)"

    # Найчастіша причина — не config.php, а бойовий .htaccess із прода:
    #   RewriteCond %{HTTPS} !on
    #   RewriteRule (.*) https://%{HTTP_HOST}%{REQUEST_URI} [R=301,L]
    # Локально https-порт ніхто не слухає, тому браузер показує помилку.
    if [ -f "$PROJECT_ROOT/src/.htaccess" ] \
       && grep -qE '^[[:space:]]*RewriteCond[[:space:]]+%\{HTTPS\}' "$PROJECT_ROOT/src/.htaccess"; then
        printf '        Причина: у src/.htaccess лишилось бойове правило хостингу,\n'
        printf '        яке примусово перекидає на https (локально https не слухає нічого).\n'
        printf '        Виправлення:  make localize-htaccess\n'
    else
        printf '        Схоже, config.php або config_secure указують на прод.  make config && make localize\n'
    fi
else
    problem "вітрина не відповідає (HTTP $CODE)"
    printf '        Дивіться логи:  make logs-php\n'
fi
rm -f "$BODY_FILE"

ADMIN_BODY="$(mktemp)"
ACODE="$(curl -s -o "$ADMIN_BODY" -m 15 -w '%{http_code}' "http://localhost:${WEB_PORT}/admin/" 2>/dev/null || echo 000)"
if [ "$ACODE" != "200" ]; then
    problem "адмінка не відповідає (HTTP $ACODE)"
elif grep -qi 'ionCube PHP Loader needs to be installed' "$ADMIN_BODY"; then
    problem "адмінка віддає заглушку ionCube  →  make build"
else
    ok "адмінка віддає HTTP 200"
fi
rm -f "$ADMIN_BODY"

# --- Підсумок ---------------------------------------------------------------
printf '\n'
if [ "$PROBLEMS" -eq 0 ]; then
    ok "Усі перевірки пройдено."
    show_urls
else
    err "Знайдено проблем: ${PROBLEMS}. Дивіться підказки вище."
    exit 1
fi
