#!/bin/bash
# ---------------------------------------------------------------------------
# Локалізація src/.htaccess: прибрати бойові правила, які ламають localhost.
#
# НАВІЩО:
#   Разом із файлами сайту з прода приїжджає і .htaccess хостингу. У ньому
#   майже завжди є таке (це правило ставить панель хостингу для HTTPS):
#
#       RewriteEngine On
#       RewriteCond %{HTTPS} !on
#       RewriteRule (.*) https://%{HTTP_HOST}%{REQUEST_URI} [R=301,L]
#
#   Локально це дає 301 на https://localhost:8080/, де нічого не слухає:
#   браузер показує помилку з'єднання, хоча сам OpenCart цілком робочий.
#   `make check` у такому стані пише «вітрина редиректить (301)».
#
# ЩО РОБИТЬ:
#   Коментує (додає "# [local] ") лише ті рядки, які:
#     * є умовою RewriteCond із %{HTTPS} — разом із наступним RewriteRule,
#       якщо той веде на https://;
#     * є RewriteRule з абсолютною адресою на ЧУЖИЙ хост (прод), тобто
#       не на той хост, що в SITE_URL.
#   Решта правил (SEO-URL, sitemap, захист файлів) не чіпається — вони
#   потрібні локально так само, як на проді.
#
# БЕЗПЕКА:
#   Оригінал зберігається в backups/htaccess/<дата>/.htaccess — навмисно НЕ
#   поруч із src/, бо src/ віддається Apache, і копія бойового .htaccess
#   була б доступна по http://localhost:8080/.htaccess.prod-backup-...
#   (там видно шляхи й правила хостингу).
#
#   .htaccess ніколи не деплоїться назад: tools/lib.sh відносить його до
#   захищених шляхів (потрібен явний --include-htaccess).
#
# Запуск:  make config   або   make localize-htaccess
# ---------------------------------------------------------------------------

. "$(dirname "$0")/lib.sh"
load_env

# Хост, на який має вести локальний сайт (без схеми та порту).
# SITE_URL=http://localhost:8080/  →  localhost
LOCAL_HOST="${SITE_URL#*://}"
LOCAL_HOST="${LOCAL_HOST%%/*}"
LOCAL_HOST="${LOCAL_HOST%%:*}"
LOCAL_HOST="${LOCAL_HOST:-localhost}"

step "Локалізація .htaccess (локальний хост: ${LOCAL_HOST})"

# Обробляє один файл. Повертає 0, якщо щось змінив.
localize_one() {
    local file="$1"
    local tmp
    tmp="$(mktemp)"

    awk -v local_host="$LOCAL_HOST" '
        function is_rule(l) { return tolower(l) ~ /^[ \t]*rewriterule/ }
        function is_cond(l) { return tolower(l) ~ /^[ \t]*rewritecond/ }
        {
            raw = $0
            low = tolower(raw)

            # 1) Умова «зєднання не по HTTPS» — це бойове правило хостингу.
            if (is_cond(raw) && low ~ /%\{https\}/) {
                https_cond = 1
                print "# [local] " raw
                next
            }

            # 2) Правило, що стоїть під цією умовою, — теж бойове, якщо веде на https.
            if (https_cond) {
                if (is_rule(raw)) {
                    https_cond = 0
                    if (low ~ /https:\/\//) {
                        print "# [local] " raw
                        next
                    }
                } else if (!is_cond(raw)) {
                    https_cond = 0
                }
            }

            # 3) Будь-яке правило з абсолютною адресою на чужий хост (прод).
            if (is_rule(raw)) {
                n = split(raw, parts, /[ \t]+/)
                for (i = 1; i <= n; i++) {
                    if (parts[i] ~ /^https?:\/\//) {
                        host = parts[i]
                        sub(/^https?:\/\//, "", host)
                        sub(/[\/?].*$/, "", host)
                        sub(/:[0-9]+$/, "", host)
                        if (host != local_host) {
                            print "# [local] " raw
                            next
                        }
                    }
                }
            }

            # 4) Показ помилок і шлях error_log. На проді це off (відвідувач не
            #    має бачити стектрейси), локально — коментуємо, щоб працював
            #    docker/php-dev.ini з display_errors = On. Деталі: docs/06-моніторинг.md
            if (low ~ /^[ \t]*php_(flag|value)[ \t]+(display_errors|display_startup_errors|html_errors|error_log|log_errors)/) {
                print "# [local] " raw
                next
            }

            print raw
        }
    ' "$file" > "$tmp"

    if cmp -s "$file" "$tmp"; then
        rm -f "$tmp"
        return 1
    fi

    local stamp dir
    stamp="$(date +%Y-%m-%d-%H%M%S)"
    dir="$PROJECT_ROOT/backups/htaccess/$stamp"
    mkdir -p "$dir"
    cp -p "$file" "$dir/$(basename "$(dirname "$file")")-htaccess.prod-backup"

    cat "$tmp" > "$file"
    rm -f "$tmp"

    info "  $file — бойові правила закоментовано (позначка «# [local] »)"
    info "  оригінал: $dir/"
    return 0
}

# Додає локальний блок, який закриває службові файли від читання по HTTP.
# Повертає 0, якщо блок додано.
DENY_MARKER='OpenCart local: захист службових файлів'
ensure_deny_block() {
    local file="$1"
    grep -qF "$DENY_MARKER" "$file" && return 1

    cat >> "$file" <<'EOF'

# [local] ---------------------------------------------------------------------
# [local] OpenCart local: захист службових файлів від читання по HTTP.
# [local] Усе, що лежить у docroot, Apache віддає як звичайний текст, якщо
# [local] для нього немає правила. Так відкривалась копія бойового
# [local] config.php.prod-backup-<дата> — разом із паролем до БД. Самі копії
# [local] тепер лежать у backups/ (поза docroot), а це правило страхує від
# [local] нових: дампів, логів, .env, покладених у src/ випадково.
# [local] ---------------------------------------------------------------------
<FilesMatch "(?i)(prod-backup|\.sql$|\.sql\.gz$|\.log$|\.env$)">
 Require all denied
</FilesMatch>
EOF
    return 0
}

CHANGED=0
for file in "$PROJECT_ROOT/src/.htaccess" "$PROJECT_ROOT/src/admin/.htaccess"; do
    [ -f "$file" ] || continue
    where="$(basename "$(dirname "$file")")/.htaccess"

    if localize_one "$file"; then
        CHANGED=$((CHANGED + 1))
    else
        ok "$where — бойових правил немає"
    fi

    if ensure_deny_block "$file"; then
        CHANGED=$((CHANGED + 1))
        ok "$where — додано захист службових файлів (копії конфігів, дампи, логи)"
    fi
done

if [ ! -f "$PROJECT_ROOT/src/.htaccess" ]; then
    warn "немає src/.htaccess — SEO-URL і захист файлів працювати не будуть"
    printf '        Файл беруть із прода (він лишається невидимим для FTP-клієнтів у деяких панелях).\n'
fi

if [ "$CHANGED" -gt 0 ]; then
    printf '\n'
    ok "Змінено файлів: ${CHANGED}. Відкотити: скопіюйте назад із backups/htaccess/"
else
    ok "нічого змінювати не потрібно"
fi
