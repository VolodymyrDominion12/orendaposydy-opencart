#!/bin/bash
# ---------------------------------------------------------------------------
# Залити один файл на прод через FTP.
#
# Використання:  tools/ftp-put.sh <локальний-файл> <шлях-на-сайті>
# Приклад:       tools/ftp-put.sh src/manifest.json manifest.json
#
# Не викликайте напряму для config.php чи system/storage — deploy.sh
# такі шляхи блокує, а тут захисту немає.
# ---------------------------------------------------------------------------

. "$(dirname "$0")/lib.sh"
load_env
require_ftp

LOCAL="$1"
REL="$2"

[ -n "$LOCAL" ] && [ -n "$REL" ] || die "Використання: ftp-put.sh <локальний-файл> <шлях-на-сайті>"
[ -f "$LOCAL" ] || die "Немає файлу: $LOCAL"

# shellcheck disable=SC2046
curl $(ftp_opts) --ftp-create-dirs --fail \
     -T "$LOCAL" "$(ftp_url "$REL")" \
    || die "Не вдалося залити $REL
Перевірте FTP_HOST / FTP_USER / FTP_PASSWORD / FTP_REMOTE_DIR у .env
і що FTP_REMOTE_DIR справді існує на сервері."

exit 0
