#!/bin/bash
# ---------------------------------------------------------------------------
# Спільне для скриптів перевірок (db-check, db-explain, db-profile ...).
# Підключається після lib.sh:  . "$(dirname "$0")/lib-quality.sh"
# ---------------------------------------------------------------------------

# Вирівняти TSV зі stdin у колонки (замість `column -t`, якого може не бути).
# $1 — відступ ліворуч (типово 4 пробіли).
fmt_tsv() {
    local indent="${1:-    }"
    awk -F'\t' -v ind="$indent" '
        { for (i = 1; i <= NF; i++) { cell[NR, i] = $i; l = length($i); if (l > w[i]) w[i] = l }
          if (NF > nf) nf = NF; rows = NR }
        END {
            for (r = 1; r <= rows; r++) {
                line = ind
                for (i = 1; i <= nf; i++) {
                    v = cell[r, i]
                    line = line v
                    if (i < nf) { pad = w[i] - length(v) + 2; while (pad-- > 0) line = line " " }
                }
                sub(/ +$/, "", line); print line
            }
        }'
}
