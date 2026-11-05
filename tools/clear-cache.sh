#!/bin/bash
# ---------------------------------------------------------------------------
# Скидання кешів OpenCart.
#
# Де що лежить (перевірено на OpenCart 3.0.3.9):
#   system/storage/cache/          — кеш даних і Twig-шаблонів
#                                    (twig.php: 'cache' => DIR_CACHE . 'template/')
#   image/cache/                   — згенеровані прев'ю зображень
#   system/storage/modification/   — ТУТ ЛЕЖАТЬ ВАШІ OCMOD-МОДИФІКАЦІЇ
#   system/storage/vendor/         — composer-бібліотеки (twig, scssphp). НЕ ЧІПАТИ.
#
# ГОЛОВНЕ ЗАСТЕРЕЖЕННЯ:
#   system/storage/modification/ — це НЕ кеш у звичному розумінні. Саме там
#   лежать файли, згенеровані вашими .ocmod.xml. Якщо їх видалити, модифікації
#   ПЕРЕСТАНУТЬ застосовуватись, поки ви не натиснете
#   Адмінка → Розширення → Модифікатори → «Оновити» (Refresh).
#   Тому за замовчуванням ми його не чіпаємо. Якщо все ж треба — є --modifications,
#   але після нього обов'язково виконайте  make refresh-mods
#   (це той самий Refresh, що й кнопка в адмінці, лише з командного рядка).
#
# Використання:
#   tools/clear-cache.sh                  # кеш даних + Twig + прев'ю
#   tools/clear-cache.sh --modifications  # ще й кеш OCMOD (див. застереження)
#   tools/clear-cache.sh --logs           # ще й логи
# ---------------------------------------------------------------------------

. "$(dirname "$0")/lib.sh"

CLEAR_MODS=0
CLEAR_LOGS=0

while [ $# -gt 0 ]; do
    case "$1" in
        --modifications) CLEAR_MODS=1 ;;
        --logs)          CLEAR_LOGS=1 ;;
        -h|--help)       sed -n '2,26p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *)               die "Невідомий параметр: $1" ;;
    esac
    shift
done

# Кеш чистимо через контейнер: там гарантовано ті самі права, що в www-data,
# і не залежить від того, з якого користувача ви запускаєте скрипт.
TARGETS=(
    "system/storage/cache"
    "image/cache"
)
[ "$CLEAR_MODS" -eq 1 ] && TARGETS+=("system/storage/modification")
[ "$CLEAR_LOGS" -eq 1 ] && TARGETS+=("system/storage/logs")

step "Скидання кешу"
for t in "${TARGETS[@]}"; do
    # Видаляємо вміст, але зберігаємо самі каталоги та index.html —
    # OpenCart і веб-сервер очікують, що вони існують.
    if dc exec -T web bash -c "
            if [ -d '$t' ]; then
                find '$t' -mindepth 1 -not -name 'index.html' -delete 2>/dev/null
                echo '  очищено: $t'
            fi" 2>/dev/null | grep -q .; then
        ok "$t"
    else
        warn "$t — немає або недоступний (це нормально для чистого встановлення)"
    fi
done

if [ "$CLEAR_MODS" -eq 1 ]; then
    printf '\n'
    warn "Кеш OCMOD-модифікаторів очищено."
    warn "ВАШІ МОДИФІКАЦІЇ ЗАРАЗ НЕ ДІЮТЬ — сайт втратить стилі, товари й категорії."
    printf '        Повернути на місце:  make refresh-mods\n'
fi

printf '\n'
ok "Готово."
