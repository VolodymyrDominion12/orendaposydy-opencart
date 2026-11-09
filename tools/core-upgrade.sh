#!/bin/bash
# ---------------------------------------------------------------------------
# Оновлення ядра OpenCart 3.0.3.2 → 3.0.4.1 (фіча 018, specs/018-platform-upgrade/).
#
# Пакети беруться з vendor-src/:
#   opencart-3.0.4.1.zip   — обов'язково (ціль)
#   opencart-3.0.3.2.zip   — бажано (знайти ручні правки ядра на сайті)
#
# Команди (без APPLY=1 НІЧОГО не змінюють):
#   tools/core-upgrade.sh report           # звіт → specs/018-platform-upgrade/core-report.md
#                                          #   + core-remove.txt (видалити) і core-keep.txt (НЕ перезаписувати:
#                                          #     ручні правки ядра під тему sauco і навмисно вимкнені файли)
#   APPLY=1 tools/core-upgrade.sh apply    # бекап src/ → ядро 3.0.4.1 у src/ → vendor →
#                                          #   видалення файлів із core-remove.txt
#   tools/core-upgrade.sh verify           # src/ проти 3.0.4.1: 0 відмінностей ядра = AC-2
#   tools/core-upgrade.sh package          # ZIP для файлового менеджера cPanel (прод)
#   tools/core-upgrade.sh prod-remove      # показати, що буде видалено на проді
#   APPLY=1 tools/core-upgrade.sh prod-remove   # видалити на проді через FTP (DELE)
#   BK=backups/core-018-….tar.gz APPLY=1 tools/core-upgrade.sh rollback
#                                          # повернути код src/ із бекапу (зображення не чіпає)
#
# Що НІКОЛИ не перезаписується: config.php, admin/config.php, .htaccess, robots.txt,
# php.ini, install/, image/catalog/, system/storage/ (крім vendor/), storage_kozak/ (крім vendor/).
# ---------------------------------------------------------------------------

. "$(dirname "$0")/lib.sh"

# sort і comm мають порівнювати байтово: з локаллю uk_UA/en_US порядок
# різний, і comm падає з "file is not in sorted order".
export LC_ALL=C

case "${1:-}" in ""|-h|--help|help) sed -n '2,23p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;; esac

CMD="$1"
SRC="$PROJECT_ROOT/src"
VENDOR_SRC="$PROJECT_ROOT/vendor-src"
CACHE="$PROJECT_ROOT/.cache/core-upgrade"
SPEC="$PROJECT_ROOT/specs/018-platform-upgrade"
REPORT="$SPEC/core-report.md"
REMOVE_LIST="$SPEC/core-remove.txt"
KEEP_LIST="$SPEC/core-keep.txt"
NEW_VER="3.0.4.1"
OLD_VER="3.0.3.2"
[ -f "$PROJECT_ROOT/.env" ] && load_env
REMOTE_STORAGE="${REMOTE_STORAGE_DIR:-storage_kozak}"

for t in unzip tar find sha1sum grep sort comm; do
    command -v "$t" >/dev/null 2>&1 || die "Потрібна утиліта: $t"
done

# --- Розпакувати пакет у .cache і повернути шлях до upload/ -----------------
pkg_dir() {
    local ver="$1" zip="$VENDOR_SRC/opencart-$1.zip" dst="$CACHE/$1"
    [ -f "$zip" ] || return 1
    if [ ! -f "$dst/.ok" ] || [ "$zip" -nt "$dst/.ok" ]; then
        rm -rf "$dst"; mkdir -p "$dst"
        unzip -q "$zip" -d "$dst" || die "Не вдалося розпакувати $zip"
        touch "$dst/.ok"
    fi
    local up
    up="$(find "$dst" -maxdepth 3 -type d -name upload | head -1)"
    [ -n "$up" ] && [ -f "$up/index.php" ] || die "У $zip немає теки upload/ з index.php"
    # Офіційний реліз 3.0.3.2 має в index.php VERSION '3.0.3.1' (дефект самого релізу OpenCart)
    local accept="$ver"; [ "$ver" = "3.0.3.2" ] && accept="3.0.3.[12]"
    grep -qE "define\('VERSION', '$accept'\)" "$up/index.php" || die "$zip: index.php не містить VERSION $ver — це не той пакет"
    printf '%s' "$up"
}

# Файли однакові, якщо збігаються без \r і без рядка define('VERSION', …)
same_file() {
    cmp -s <(tr -d '\r' < "$1" | grep -v "^define('VERSION'") <(tr -d '\r' < "$2" | grep -v "^define('VERSION'")
}

# Копіювати файли зі списку (відносні шляхи) з $1 у $3, зберігаючи структуру тек
copy_list() {
    (cd "$1" && tar -cf - -T "$2") | (mkdir -p "$3" && cd "$3" && tar -xf -)
}

# Файли ядра, які переносимо в src/ (відносні шляхи), без того, що не чіпаємо
core_files() {
    (cd "$1" && find . -type f | sed 's|^\./||') | grep -vE \
        '^(install/|image/catalog/|system/storage/|config-dist\.php$|admin/config-dist\.php$|php\.ini$|robots\.txt$|\.htaccess\.txt$|\.htaccess$|config\.php$|admin/config\.php$)' \
        | sort
}

# Файли ядра мінус ті, що в core-keep.txt (шлях<TAB>причина; # — коментар)
core_files_to_copy() {
    if [ -f "$KEEP_LIST" ]; then
        grep -v '^\s*\(#\|$\)' "$KEEP_LIST" | cut -f1 | sort -u > "$CACHE/keep.paths"
        comm -23 "$CACHE/new.list" "$CACHE/keep.paths"
    else
        cat "$CACHE/new.list"
    fi
}

# Ручні правки ядра, для яких БЕРЕМО нове ядро (рішення 2026-11-06, specs/018 → tasks «Замітки»):
# косметика адмінки (напис-логотип, «версія теми», .d-none, меню, пробіли в дашборді), а стара шапка
# адмінки підключає jquery-2.1.1, якого в 3.0.4.1 немає.
TAKE_NEW_CORE='admin/index.php
admin/controller/common/header.php
admin/controller/common/footer.php
admin/controller/common/column_left.php
admin/controller/common/dashboard.php
admin/view/template/common/header.twig
admin/view/stylesheet/stylesheet.css'

# Записати згенерований список: якщо людина не редагувала попередній (збігається з
# останнім згенерованим у .cache) — перезаписати; інакше — поруч як .new.
write_generated() {
    local new="$1" dst="$2" last="$CACHE/$(basename "$2").generated"
    if [ -f "$dst" ] && ! cmp -s "$dst" "$new"; then
        if [ -f "$last" ] && cmp -s "$dst" "$last"; then
            mv "$new" "$dst"
        elif [ ! -f "$last" ]; then
            mv "$dst" "$dst.prev"; mv "$new" "$dst"
            warn "$(basename "$dst"): попередню версію збережено як $(basename "$dst").prev"
        else
            mv "$new" "$dst.new"
            warn "$(basename "$dst") змінено вручну — новий список записано в $(basename "$dst").new"
            return 0
        fi
    else
        mv "$new" "$dst"
    fi
    cp "$dst" "$last"
}

# Файли src/, які аналізуємо (без даних, кешу, зображень товарів)
src_files() {
    (cd "$SRC" && find . -type f | sed 's|^\./||') | grep -vE \
        '^(image/|download/|system/storage/|storage_kozak/|install/|\.git/)' | sort
}

# --- Класифікація файлу, якого немає в ядрі 3.0.4.1 --------------------------
# Друкує "REMOVE<TAB>причина", "KEEP<TAB>причина" або "REVIEW<TAB>причина".
#   $1 — шлях відносно src/;  $2 — "1", якщо файл є в 3.0.3.2 (ядро, видалене в новій версії)
classify() {
    local f="$1" in_old="$2" base
    base="${f##*/}"
    case "$f" in
        admin/language/ru-ru/*|catalog/language/ru-ru/*)
            echo "REMOVE	ru-ru: мова не встановлена (в oc_language лише uk-ua)"; return ;;
    esac
    case "/$f" in
        */_*/*) echo "REMOVE	вимкнена копія (тека з «_» на початку)"; return ;;
    esac
    case "$base" in
        _*) echo "REMOVE	вимкнена копія (файл з «_» на початку)"; return ;;
        desktop.ini|Thumbs.db|error_log|*.bak|*~|*.php_original|*.orig) echo "REMOVE	службове сміття / резервні копії"; return ;;
    esac
    case "$f" in
        admin/index1.php|admin/index.svg) echo "REMOVE	службове сміття / резервні копії"; return ;;
    esac
    case "/$f" in
        */nppBackup/*) echo "REMOVE	службове сміття / резервні копії"; return ;;
    esac
    case "$f" in
        system/tweak.ocmod.xml|admin/view/javascript/jquery/translit.js)
            echo "REMOVE	OCMOD tweak (рішення 2026-11-06)"; return ;;
        *sms_alert*|*/simpleregister.php|*/simpleapi.php)
            echo "REMOVE	залишок видаленого стороннього модуля"; return ;;
        system/library/template/Twig/*)
            echo "REMOVE	Twig 1.x з 3.0.3.2 (у 3.0.4.1 — Twig 3 у storage/vendor)"; return ;;
    esac
    # --- що лишається
    case "$f" in
        catalog/view/theme/sauco/*)        echo "KEEP	тема sauco (до 003)"; return ;;
        catalog/controller/checkout/order.php|catalog/model/checkout/simple_order.php|catalog/language/uk-ua/checkout/order.php)
                                           echo "KEEP	оформлення замовлення теми sauco (до 010)"; return ;;
        *oplata*)                          echo "KEEP	Fondy (офіційний модуль провайдера)"; return ;;
        *notifications_in_telegram*)       echo "KEEP	Telegram-сповіщення (до 023)"; return ;;
        *kristal*)                         echo "KEEP	наш код"; return ;;
        config.php|admin/config.php|.htaccess|.user.ini|php.ini|robots.txt|index1.php|index.svg|.gitkeep)
                                           echo "KEEP	файл сайту/хостингу"; return ;;
        config-dist.php|admin/config-dist.php|.htaccess.txt)
                                           echo "KEEP	шаблон з пакета ядра (не перезаписуємо)"; return ;;
        .well-known/*|cgi-bin/*)           echo "KEEP	службове хостингу (переглянути в 017)"; return ;;
        admin/view/image/*|catalog/view/image/*) echo "KEEP	зображення інтерфейсу (не заважає)"; return ;;
        admin/language/uk-ua/uk-ua.*|catalog/language/uk-ua/uk-ua.*)
                                           echo "KEEP	мовний пакет uk-ua"; return ;;
    esac
    case "$f" in
        admin/language/uk-ua/*|catalog/language/uk-ua/*)
            local en="${f/\/uk-ua\//\/en-gb\/}"
            if grep -qxF "$en" "$CACHE/new.list"; then
                echo "KEEP	переклад файлу ядра"; return
            fi
            local route="${f#*/language/uk-ua/}"; route="${route%.php}"
            if grep -rqF --include='*.php' "'$route'" "$NEW/admin" "$NEW/catalog" "$NEW/system" 2>/dev/null \
               || { [ -s "$CACHE/kept-php.list" ] && (cd "$SRC" && xargs -a "$CACHE/kept-php.list" grep -lqF "'$route'" 2>/dev/null); }; then
                echo "KEEP	переклад, який завантажує ядро 3.0.4.1 або збережений код (en-gb у пакеті немає)"
            else
                echo "REMOVE	мовний файл видаленого модуля (маршрут ніде не використовується)"
            fi
            return ;;
    esac
    if [ "$in_old" = "1" ]; then
        echo "REMOVE	файл ядра 3.0.3.2, видалений у 3.0.4.1"; return
    fi
    if [ -z "$OLD" ]; then
        echo "REVIEW	походження невідоме без opencart-3.0.3.2.zip"; return
    fi
    echo "REVIEW	не ядро 3.0.3.2 і не відомий модуль — вирішити вручну"
}

# --- Перевірка шаблонів на конструкції, яких немає в Twig 3 --------------------
twig_scan() {
    local pat='\{%-?[[:space:]]*(spaceless|endspaceless|filter[[:space:]]|endfilter|raw|endraw)|[[:space:]]sameas[[:space:]]|divisibleby|\{%-?[[:space:]]*for[[:space:]][^%]*[[:space:]]if[[:space:]][^%]*%\}|Twig_'
    (cd "$SRC" && grep -rnE "$pat" --include='*.twig' catalog/view/theme admin/view/template 2>/dev/null) || true
    (cd "$SRC" && grep -rln 'Twig_' --include='*.php' admin catalog system 2>/dev/null \
        | grep -vE '^system/(library/template/|storage/)' \
        | { if [ -f "$CACHE/copy.list" ]; then grep -vxFf "$CACHE/copy.list"; else cat; fi; } \
        | sed 's/$/: використовує клас Twig 1.x (Twig_*) і НЕ буде замінений ядром/') || true
}

# ============================================================================
case "$CMD" in
# ----------------------------------------------------------------------------
report)
    NEW="$(pkg_dir "$NEW_VER")" || die "Немає vendor-src/opencart-$NEW_VER.zip"
    OLD=""
    if [ -f "$VENDOR_SRC/opencart-$OLD_VER.zip" ]; then
        OLD="$(pkg_dir "$OLD_VER")" || die "vendor-src/opencart-$OLD_VER.zip є, але не підходить (див. помилку вище)"
    fi
    mkdir -p "$CACHE" "$SPEC"
    core_files "$NEW" > "$CACHE/new.list"
    src_files > "$CACHE/src.list"
    : > "$CACHE/old.list"
    [ -n "$OLD" ] && core_files "$OLD" > "$CACHE/old.list"

    step "Звіт: src/ проти OpenCart $NEW_VER${OLD:+ (і $OLD_VER)}"
    comm -23 "$CACHE/src.list" "$CACHE/new.list" > "$CACHE/extra.list"
    comm -13 "$CACHE/src.list" "$CACHE/new.list" > "$CACHE/added.list"
    comm -12 "$CACHE/src.list" "$CACHE/new.list" > "$CACHE/common.list"

    # Ручні правки ядра: файл є в 3.0.3.2, у src/ відрізняється від оригіналу
    : > "$CACHE/hacks.list"
    if [ -n "$OLD" ]; then
        while IFS= read -r f; do
            [ -f "$SRC/$f" ] || continue
            same_file "$SRC/$f" "$OLD/$f" || echo "$f" >> "$CACHE/hacks.list"
        done < "$CACHE/old.list"
    fi

    # Файли src/, що лишаються після оновлення (для перевірки посилань на мовні файли)
    grep -E '^(catalog/controller/checkout/order\.php|catalog/model/checkout/simple_order\.php)$|oplata|notifications_in_telegram|kristal' \
        "$CACHE/src.list" | grep '\.php$' > "$CACHE/kept-php.list" || true

    # core-keep: (а) ручні правки ядра — лишаємо старий файл до заміни теми (003);
    #            (б) навмисно вимкнені файли ядра: є _x.php, немає x.php — не повертаємо.
    {
        echo "# Файли ядра 3.0.4.1, які apply НЕ копіює в src/. Формат: шлях<TAB>причина."
        echo "# Рядок можна видалити (тоді файл ядра перезапише поточний) або додати свій."
        if [ -s "$CACHE/hacks.list" ]; then
            { grep -xFf "$CACHE/new.list" "$CACHE/hacks.list" || true; } \
                | { grep -vxF "$TAKE_NEW_CORE" || true; } \
                | sed 's/$/\tручна правка ядра 3.0.3.2 (ймовірно під тему sauco) — до 003/'
        fi
        while IFS= read -r f; do
            d="$(dirname "$f")"; b="$(basename "$f")"
            [ -f "$SRC/$f" ] && continue
            [ -f "$SRC/$d/_$b" ] && printf '%s\tнавмисно вимкнено на сайті (є _%s) — не повертаємо\n' "$f" "$b"
        done < "$CACHE/new.list"
    } > "$CACHE/keep.tmp"
    write_generated "$CACHE/keep.tmp" "$KEEP_LIST"
    # старі файли ядра, що лишаються, теж можуть завантажувати мовні файли
    { grep -v '^\s*\(#\|$\)' "$KEEP_LIST" | cut -f1 | grep '\.php$' || true; } >> "$CACHE/kept-php.list"
    core_files_to_copy > "$CACHE/copy.list"

    : > "$CACHE/class.tsv"
    while IFS= read -r f; do
        in_old=0; [ -n "$OLD" ] && grep -qxF "$f" "$CACHE/old.list" && in_old=1
        printf '%s\t%s\n' "$f" "$(classify "$f" "$in_old")" >> "$CACHE/class.tsv"
    done < "$CACHE/extra.list"

    awk -F'\t' '$2=="REMOVE"{print $1}' "$CACHE/class.tsv" > "$CACHE/remove.tmp"
    TW="$(twig_scan)"
    n() { wc -l < "$1" | tr -d ' '; }

    {
        echo "# 018 — звіт оновлення ядра $OLD_VER → $NEW_VER"
        echo
        echo "Згенеровано \`make core-report\` $(date '+%Y-%m-%d %H:%M'). Не редагувати вручну."
        echo
        echo "| Що | Кількість |"
        echo "|---|---|"
        echo "| Файлів ядра $NEW_VER | $(n "$CACHE/new.list") |"
        echo "| Спільних із src/ | $(n "$CACHE/common.list") |"
        echo "| Нових у $NEW_VER | $(n "$CACHE/added.list") |"
        echo "| **Не копіюються** (core-keep.txt) | $(grep -cv '^\s*\(#\|$\)' "$KEEP_LIST") |"
        echo "| Буде скопійовано з ядра | $(n "$CACHE/copy.list") |"
        echo "| Файлів src/, яких немає в $NEW_VER | $(n "$CACHE/extra.list") |"
        echo "| — залишаються (KEEP) | $(grep -c $'\tKEEP\t' "$CACHE/class.tsv") |"
        echo "| — до видалення (REMOVE) | $(grep -c $'\tREMOVE\t' "$CACHE/class.tsv") |"
        echo "| — вирішити вручну (REVIEW) | $(grep -c $'\tREVIEW\t' "$CACHE/class.tsv") |"
        echo
        echo "## 1. Ручні правки ядра (src/ ≠ оригінальний $OLD_VER)"
        echo
        if [ -z "$OLD" ]; then
            echo "**Не перевірено:** немає \`vendor-src/opencart-$OLD_VER.zip\`. Без цього перезапис може знищити ручні правки."
        elif [ ! -s "$CACHE/hacks.list" ]; then
            echo "Немає — ядро на сайті збігається з оригіналом $OLD_VER."
        else
            echo "Ці файли **за замовчуванням лишаються старими** (\`core-keep.txt\`): тема \`sauco\` бере з них дані."
            echo "Їх замінить тема \`kristal\` (003). Рядок у \`core-keep.txt\` можна прибрати, якщо правка не потрібна."
            echo
            { grep -vxF "$TAKE_NEW_CORE" "$CACHE/hacks.list" || true; } > "$CACHE/hacks.keep"
            while IFS= read -r f; do
                lines="$( { diff <(tr -d '\r' < "$OLD/$f") <(tr -d '\r' < "$SRC/$f") 2>/dev/null || true; } | grep -c '^[<>]' || true)"
                printf -- '- `%s` — %s рядків різниці\n' "$f" "$lines"
            done < "$CACHE/hacks.keep"
        fi
        echo
        echo "### Ручні правки, для яких беремо нове ядро 3.0.4.1"
        echo
        echo "Косметика адмінки; стара шапка адмінки підключає jquery-2.1.1, якого в 3.0.4.1 немає:"
        echo
        printf '%s\n' "$TAKE_NEW_CORE" | { grep -xFf - "$CACHE/hacks.list" || true; } | sed 's/^/- `/; s/$/`/'
        echo
        echo "## 1a. Навмисно вимкнені файли ядра (не повертаються)"
        echo
        if grep -q $'\tнавмисно' "$KEEP_LIST"; then grep $'\tнавмисно' "$KEEP_LIST" | cut -f1 | sed 's/^/- `/; s/$/`/'; else echo "Немає."; fi
        echo
        echo "## 2. Шаблони й код, несумісні з Twig 3"
        echo
        if [ -z "$TW" ]; then echo "Не знайдено."; else printf '%s\n' "$TW" | sed 's/^/- `/; s/$/`/'; fi
        echo
        echo "## 3. Вирішити вручну (REVIEW)"
        echo
        if grep -q $'\tREVIEW\t' "$CACHE/class.tsv"; then
            awk -F'\t' '$2=="REVIEW"{printf "- `%s` — %s\n",$1,$3}' "$CACHE/class.tsv"
        else echo "Немає."; fi
        echo
        echo "## 4. До видалення (REMOVE) — за причинами"
        echo
        awk -F'\t' '$2=="REMOVE"{c[$3]++} END{for(k in c) printf "- %s — %d\n",k,c[k]}' "$CACHE/class.tsv" | sort
        echo
        echo "Повний список: \`core-remove.txt\` (переглянути; рядок можна видалити, щоб залишити файл)."
        echo
        echo "## 5. Залишаються (KEEP) — за причинами"
        echo
        awk -F'\t' '$2=="KEEP"{c[$3]++} END{for(k in c) printf "- %s — %d\n",k,c[k]}' "$CACHE/class.tsv" | sort
    } > "$REPORT"

    write_generated "$CACHE/remove.tmp" "$REMOVE_LIST"
    ok "Звіт: ${REPORT#"$PROJECT_ROOT"/}"
    ok "Список до видалення: ${REMOVE_LIST#"$PROJECT_ROOT"/} ($(n "$REMOVE_LIST") файлів)"
    [ -s "$CACHE/hacks.list" ] && warn "Знайдено ручних правок ядра: $(n "$CACHE/hacks.list") — див. розділ 1 звіту"
    [ -z "$OLD" ] && warn "Немає opencart-$OLD_VER.zip — ручні правки ядра НЕ перевірено"
    exit 0 ;;

# ----------------------------------------------------------------------------
apply)
    NEW="$(pkg_dir "$NEW_VER")" || die "Немає vendor-src/opencart-$NEW_VER.zip"
    [ -f "$VENDOR_SRC/opencart-$OLD_VER.zip" ] || die "Потрібен vendor-src/opencart-$OLD_VER.zip: без нього невідомо, які файли ядра змінено під тему, і перезапис їх знищить"
    [ -f "$REPORT" ] && [ -f "$REMOVE_LIST" ] && [ -f "$KEEP_LIST" ] || die "Спершу: make core-report (і переглянути звіт)"
    grep -q 'Не перевірено' "$REPORT" && die "core-report.md зібрано без $OLD_VER — перезапустіть make core-report"
    core_files "$NEW" > "$CACHE/new.list"
    core_files_to_copy > "$CACHE/copy.list"

    step "Застосування ядра $NEW_VER до src/"
    printf '  Буде перезаписано/додано файлів ядра: %s\n' "$(wc -l < "$CACHE/copy.list")"
    printf '  Лишаються як є (core-keep.txt): %s\n' "$(grep -cv '^\s*\(#\|$\)' "$KEEP_LIST")"
    printf '  Буде видалено файлів (core-remove.txt): %s\n' "$(grep -cv '^\s*\(#\|$\)' "$REMOVE_LIST")"
    printf '  vendor/ ядра → src/system/storage/vendor/ і src/%s/vendor/\n' "$REMOTE_STORAGE"
    if [ "${APPLY:-0}" != "1" ]; then
        info "DRY-RUN. Щоб застосувати: make core-apply APPLY=1"; exit 0
    fi

    TS="$(date +%Y%m%d-%H%M%S)"
    BK="$PROJECT_ROOT/backups/core-018-$TS.tar.gz"
    mkdir -p "$PROJECT_ROOT/backups"
    info "Бекап src/ (без image/catalog і кешу) → ${BK#"$PROJECT_ROOT"/}"
    tar -czf "$BK" -C "$PROJECT_ROOT" \
        --exclude='src/image/catalog' --exclude='src/image/cache' \
        --exclude='src/system/storage/cache' --exclude='src/system/storage/logs' --exclude='src/system/storage/session' \
        --exclude="src/$REMOTE_STORAGE/cache" --exclude="src/$REMOTE_STORAGE/logs" --exclude="src/$REMOTE_STORAGE/session" \
        src || die "Бекап не вдався — нічого не змінено"
    ok "бекап готовий"

    info "Копіюю ядро…"
    copy_list "$NEW" "$CACHE/copy.list" "$SRC" || die "копіювання ядра впало. Відкат: make core-rollback BK=${BK#"$PROJECT_ROOT"/} APPLY=1"
    ok "ядро скопійовано"

    info "Копіюю vendor/…"
    for d in "$SRC/system/storage/vendor" "$SRC/$REMOTE_STORAGE/vendor"; do
        mkdir -p "$d"
        cp -a "$NEW/system/storage/vendor/." "$d/" || die "копіювання vendor → $d впало"
    done
    ok "vendor/ скопійовано"

    info "Видаляю файли з core-remove.txt…"
    DEL=0
    while IFS= read -r f; do
        case "$f" in ""|\#*) continue ;; esac
        case "$f" in /*|*..*) warn "пропущено небезпечний шлях: $f"; continue ;; esac
        if [ -f "$SRC/$f" ]; then rm -f "$SRC/$f" && DEL=$((DEL+1)); fi
    done < "$REMOVE_LIST"
    find "$SRC/admin" "$SRC/catalog" "$SRC/system/library" -type d -empty -delete 2>/dev/null || true
    ok "видалено файлів: $DEL"

    step "Далі"
    printf '  make migrate && make clear-cache-all && make refresh-mods\n'
    printf '  make core-verify && make test-smoke\n'
    printf '  Відкат:  make core-rollback BK=%s APPLY=1\n' "${BK#"$PROJECT_ROOT"/}"
    exit 0 ;;

# ----------------------------------------------------------------------------
verify)
    NEW="$(pkg_dir "$NEW_VER")" || die "Немає vendor-src/opencart-$NEW_VER.zip"
    core_files "$NEW" > "$CACHE/new.list"
    core_files_to_copy > "$CACHE/copy.list"
    step "src/ проти ядра $NEW_VER (без $(grep -cv '^\s*\(#\|$\)' "$KEEP_LIST" 2>/dev/null || echo 0) файлів із core-keep.txt)"
    BAD=0
    while IFS= read -r f; do
        if [ ! -f "$SRC/$f" ]; then echo "  відсутній: $f"; BAD=$((BAD+1))
        elif [ "$(sha1sum < "$SRC/$f")" != "$(sha1sum < "$NEW/$f")" ]; then echo "  відрізняється: $f"; BAD=$((BAD+1)); fi
    done < "$CACHE/copy.list"
    grep -q "define('VERSION', '$NEW_VER')" "$SRC/index.php" || { err "src/index.php: VERSION не $NEW_VER"; BAD=$((BAD+1)); }
    [ -f "$SRC/system/storage/vendor/autoload.php" ] || { err "немає src/system/storage/vendor/autoload.php"; BAD=$((BAD+1)); }
    [ -f "$SRC/$REMOTE_STORAGE/vendor/autoload.php" ] || { err "немає src/$REMOTE_STORAGE/vendor/autoload.php"; BAD=$((BAD+1)); }
    if [ "$BAD" -eq 0 ]; then ok "ядро = $NEW_VER, vendor на місці"; else err "відмінностей: $BAD"; exit 1; fi
    exit 0 ;;

# ----------------------------------------------------------------------------
package)
    NEW="$(pkg_dir "$NEW_VER")" || die "Немає vendor-src/opencart-$NEW_VER.zip"
    command -v zip >/dev/null 2>&1 || die "Потрібен zip (sudo apt install zip)"
    [ -f "$KEEP_LIST" ] || die "Спершу: make core-report"
    core_files "$NEW" > "$CACHE/new.list"
    core_files_to_copy > "$CACHE/copy.list"
    STAGE="$CACHE/package"; rm -rf "$STAGE"; mkdir -p "$STAGE/$REMOTE_STORAGE"
    copy_list "$NEW" "$CACHE/copy.list" "$STAGE" || die "копіювання в пакет впало"
    cp -a "$NEW/system/storage/vendor" "$STAGE/$REMOTE_STORAGE/" || die "копіювання vendor у пакет впало"
    OUT="$PROJECT_ROOT/backups/018-core-$NEW_VER.zip"
    rm -f "$OUT"; (cd "$STAGE" && zip -qr "$OUT" .) || die "zip впав"
    ok "Пакет: ${OUT#"$PROJECT_ROOT"/} ($(du -h "$OUT" | cut -f1)); vendor усередині — у $REMOTE_STORAGE/vendor/"
    printf '  Розпакувати в теці сайту (cPanel → File Manager → %s/ → Extract), перезаписуючи файли.\n' "${FTP_REMOTE_DIR:-orendaposydy.com}"
    printf '  config.php, admin/config.php, .htaccess, install/ у пакеті відсутні — їх не зачепить.\n'
    exit 0 ;;

# ----------------------------------------------------------------------------
prod-remove)
    [ -f "$REMOVE_LIST" ] || die "Немає ${REMOVE_LIST#"$PROJECT_ROOT"/} — спершу make core-report"
    COUNT="$(grep -cv '^\s*\(#\|$\)' "$REMOVE_LIST")"
    step "Видалення на проді: $COUNT файл(ів) зі списку ${REMOVE_LIST#"$PROJECT_ROOT"/}"
    if [ "${APPLY:-0}" != "1" ]; then
        grep -v '^\s*\(#\|$\)' "$REMOVE_LIST" | head -20 | sed 's/^/  - /'
        [ "$COUNT" -gt 20 ] && printf '  … ще %s\n' "$((COUNT-20))"
        info "DRY-RUN. Щоб видалити: make core-prod-remove APPLY=1"; exit 0
    fi
    [ -f "$PROJECT_ROOT/.env" ] || die "Немає .env з FTP-доступами"
    require_ftp
    printf 'Видалити %s файл(ів) на ПРОДІ %s? Введіть YES: ' "$COUNT" "$FTP_HOST"
    read -r confirm; [ "$confirm" = "YES" ] || { info "Скасовано."; exit 0; }
    DEL=0; MISS=0
    # shellcheck disable=SC2046
    while IFS= read -r f; do
        case "$f" in ""|\#*) continue ;; esac
        case "$f" in /*|*..*|config.php|admin/config.php|"$REMOTE_STORAGE"/*) warn "пропущено: $f"; continue ;; esac
        if curl $(ftp_opts) "$(ftp_url "")" -Q "DELE $(ftp_abs "$f")" -o /dev/null 2>/dev/null; then
            DEL=$((DEL+1))
        else
            MISS=$((MISS+1))
        fi
    done < "$REMOVE_LIST"
    ok "видалено: $DEL; не знайдено/помилка: $MISS (файлу могло не бути на проді)"
    exit 0 ;;

# ----------------------------------------------------------------------------
rollback)
    B="${BK:-}"; [ -n "$B" ] || die "Вкажіть бекап: make core-rollback BK=backups/core-018-<дата>.tar.gz APPLY=1"
    case "$B" in /*) ;; *) B="$PROJECT_ROOT/$B" ;; esac
    [ -f "$B" ] || die "Немає файлу $B"
    step "Відкат src/ із ${B#"$PROJECT_ROOT"/}"
    printf '  Буде замінено: src/admin, src/catalog, src/system (крім storage/cache|logs|session),\n'
    printf '  src/%s/vendor і файли в корені src/. Зображення (image/) не чіпаються.\n' "$REMOTE_STORAGE"
    if [ "${APPLY:-0}" != "1" ]; then info "DRY-RUN. Щоб відкотити: додайте APPLY=1"; exit 0; fi
    tar -tzf "$B" >/dev/null 2>&1 || die "Бекап пошкоджений — нічого не змінено"
    TRASH="$CACHE/rollback-$(date +%Y%m%d-%H%M%S)"; mkdir -p "$TRASH"
    for d in admin catalog; do [ -d "$SRC/$d" ] && mv "$SRC/$d" "$TRASH/"; done
    mkdir -p "$TRASH/system"
    for d in "$SRC"/system/*; do
        [ -e "$d" ] || continue
        [ "$(basename "$d")" = "storage" ] && continue
        mv "$d" "$TRASH/system/"
    done
    for v in "$SRC/system/storage/vendor" "$SRC/$REMOTE_STORAGE/vendor"; do
        [ -d "$v" ] && mkdir -p "$TRASH/vendor-$(basename "$(dirname "$v")")" && mv "$v" "$TRASH/vendor-$(basename "$(dirname "$v")")/"
    done
    tar -xzf "$B" -C "$PROJECT_ROOT" || die "Розпакування впало. Поточні файли збережено в ${TRASH#"$PROJECT_ROOT"/}"
    ok "код повернуто; замінені файли — у ${TRASH#"$PROJECT_ROOT"/} (можна видалити після перевірки)"
    printf '  Далі: make migrate-down V=0002 && make clear-cache-all && make refresh-mods\n'
    exit 0 ;;

*) die "Невідома команда: $CMD (див. tools/core-upgrade.sh --help)" ;;
esac
