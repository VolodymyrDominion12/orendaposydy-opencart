#!/usr/bin/env bash
# make images-warm — прогрів кешу зображень вітрини (фіча 020). Див. tools/images-warm.php.
set -euo pipefail
source "$(dirname "$0")/lib.sh"
load_env
require_running
TMP=/tmp/kristal-images-warm.php
dc cp "$PROJECT_ROOT/tools/images-warm.php" "web:$TMP" >/dev/null
printf '\nПрогрів кешу зображень (image/cache/kristal)\n'
dc exec -T -u www-data web php "$TMP"
dc exec -T web rm -f "$TMP" >/dev/null 2>&1 || true
