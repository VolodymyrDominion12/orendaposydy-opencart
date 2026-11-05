#!/usr/bin/env python3
"""Збирає макети design/pages/*.html із design/src/ (сторінки + спільні частини).

Запуск із кореня репозиторію:  python3 design/build.py
Редагувати: design/src/pages/*.html (тіло сторінки) і design/src/partials/*.html
(шапка, футер, форма заявки, іконки). Готові файли в design/pages/ не правити руками.

Перший рядок сторінки — метадані:
<!--meta title="…" nav="catalog|events|calc|cart|home" desc="…" body="has-sticky"-->
У тілі можна вставити частину: {{> lead}}
"""
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent
SRC, OUT = ROOT / "src", ROOT / "pages"
PARTS = {p.stem: p.read_text(encoding="utf-8") for p in (SRC / "partials").glob("*.html")}
NAV_KEYS = ["catalog", "events", "calc", "cart", "tab_catalog"]

PAGE = """<!doctype html>
<html lang="uk">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{title}</title>
<meta name="description" content="{desc}">
<meta name="robots" content="noindex">
<link rel="stylesheet" href="../../docs/brandbook/tokens.css">
<link rel="stylesheet" href="../assets/k-design.css">
</head>
<body class="{body}">
{icons}
{header}
<main id="main">
{content}
</main>
{footer}
<script src="../assets/k-design.js" defer></script>
</body>
</html>
"""


def render(path: Path) -> str:
    raw = path.read_text(encoding="utf-8")
    m = re.match(r"<!--meta(.*?)-->\s*", raw, re.S)
    meta = dict(re.findall(r'(\w+)="(.*?)"', m.group(1))) if m else {}
    body = raw[m.end():] if m else raw
    body = re.sub(r"\{\{>\s*(\w+)\s*\}\}", lambda x: PARTS[x.group(1)], body)
    nav = meta.get("nav", "")
    header, footer = PARTS["header"], PARTS["footer"]
    for k in NAV_KEYS:
        on = ' aria-current="page"' if k == nav or (k == "tab_catalog" and nav == "catalog") else ""
        header = header.replace("{{ac_%s}}" % k, on)
        footer = footer.replace("{{ac_%s}}" % k, on)
    return PAGE.format(
        title=meta.get("title", "Крістал"), desc=meta.get("desc", ""), body=meta.get("body", ""),
        icons=PARTS["icons"], header=header, footer=footer, content=body,
    )


if __name__ == "__main__":
    OUT.mkdir(exist_ok=True)
    for src in sorted((SRC / "pages").glob("*.html")):
        (OUT / src.name).write_text(render(src), encoding="utf-8")
        print("✓", src.name)
