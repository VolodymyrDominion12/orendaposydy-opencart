#!/usr/bin/env python3
"""
Генерує міграцію 0001_mock_catalog (up + down) з db/seed/mock_catalog_data.py.

    python3 db/seed/generate_mock_catalog.py

Після зміни даних — перегенерувати й закомітити обидва .sql (вони в git, щоб
міграція не залежала від Python на машині, де її застосовують).

Діапазони id (резерв під мок, specs/001-mock-catalog/plan.md):
    category_id 5000–5099, product_id 50000–50999, attribute_group_id 500–509,
    attribute_id 500–549, product_discount_id 500000–509999.
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from mock_catalog_data import ATTRIBUTE_GROUP, ATTRIBUTES, TOP, EVENTS  # noqa: E402

OUT = os.path.join(HERE, "..", "migrations")
LANG = 2      # uk-ua
STORE = 0
CUSTOMER_GROUP = 1
P = "{{PREFIX}}"

CAT_RANGE = (5000, 5099)
PROD_RANGE = (50000, 50999)
AG_RANGE = (500, 509)
ATTR_RANGE = (500, 549)
DISC_RANGE = (500000, 509999)

# --- Транслітерація (офіційна, спрощена) ------------------------------------
TR = {"а": "a", "б": "b", "в": "v", "г": "h", "ґ": "g", "д": "d", "е": "e", "є": "ie", "ж": "zh", "з": "z",
      "и": "y", "і": "i", "ї": "i", "й": "i", "к": "k", "л": "l", "м": "m", "н": "n", "о": "o", "п": "p",
      "р": "r", "с": "s", "т": "t", "у": "u", "ф": "f", "х": "kh", "ц": "ts", "ч": "ch", "ш": "sh",
      "щ": "shch", "ь": "", "ю": "iu", "я": "ia", "'": "", "’": "", "ʼ": ""}
TR_START = {"є": "ye", "ї": "yi", "й": "y", "ю": "yu", "я": "ya"}


def slugify(text):
    out, prev_alpha = [], False
    for ch in text.lower():
        if ch in TR:
            out.append(TR_START.get(ch, TR[ch]) if not prev_alpha and ch in TR_START else TR[ch])
            prev_alpha = ch not in "'’ʼ"
        elif ch.isascii() and ch.isalnum():
            out.append(ch)
            prev_alpha = True
        else:
            out.append("-")
            prev_alpha = False
    s = "".join(out)
    while "--" in s:
        s = s.replace("--", "-")
    return s.strip("-")


def q(v):
    """SQL-літерал."""
    if v is None:
        return "NULL"
    if isinstance(v, (int, float)):
        return repr(round(v, 4)) if isinstance(v, float) else str(v)
    return "'" + str(v).replace("\\", "\\\\").replace("'", "''") + "'"


def ins(table, cols, rows, chunk=200):
    out = []
    for i in range(0, len(rows), chunk):
        part = rows[i:i + chunk]
        out.append(f"INSERT INTO `{P}{table}` (" + ", ".join(f"`{c}`" for c in cols) + ") VALUES\n" +
                   ",\n".join("(" + ", ".join(r) + ")" for r in part) + ";")
    return "\n".join(out)


def money(v):
    return f"{v:,.0f}".replace(",", " ") if v >= 1000 else (f"{v:.0f}" if float(v).is_integer() else f"{v:.2f}".replace(".", ","))


# --- Збір даних --------------------------------------------------------------
categories = []   # dict: id, parent, slug, name, gen, image, top, sort, products(list)
for ti, top in enumerate(TOP, 1):
    categories.append({"id": top["id"], "parent": 0, "slug": top["slug"], "name": top["name"], "gen": top["gen"],
                       "image": top["image"], "top": 1, "sort": ti, "own": top.get("products", [])})
    for si, sub in enumerate(top.get("subs", []), 1):
        categories.append({"id": sub["id"], "parent": top["id"], "slug": sub["slug"], "name": sub["name"],
                           "gen": sub["gen"], "image": top["image"], "top": 0, "sort": si, "own": sub["products"]})

products = []     # dict: id, name, price, minimum, attrs, damage, discounts, cats, image, slug, sku, cat_name
pid = PROD_RANGE[0]
for c in categories:
    for pi, (name, price, minimum, attrs, damage, discounts) in enumerate(c["own"], 1):
        pid += 1
        cats = [c["id"]] + ([c["parent"]] if c["parent"] else [])
        products.append({"id": pid, "name": name, "price": float(price), "minimum": minimum, "attrs": attrs,
                         "damage": damage, "discounts": discounts, "cats": cats, "image": c["image"],
                         "slug": slugify(name), "sku": f"MOCK-{pid - PROD_RANGE[0]:04d}", "sort": pi,
                         "cat": c})

by_id = {c["id"]: c for c in categories}


def min_price(c):
    ids = {c["id"]} | {x["id"] for x in categories if x["parent"] == c["id"]}
    ps = [p["price"] for p in products if set(p["cats"]) & ids]
    return min(ps) if ps else 0


UNIT_PHRASE = {"шт. / доба": "1 шт. на добу", "доба": "1 шт. на добу", "подія": "подію",
               "подія (з монтажем)": "подію з монтажем і демонтажем", "набір (продаж)": "набір (продаж, не оренда)"}


def unit(p):
    """Як ціна читається в тексті: «за 1 шт. на добу»."""
    u = p["attrs"].get("unit", "шт. / доба")
    return UNIT_PHRASE.get(u, u)


# --- Тексти -------------------------------------------------------------------
def cat_texts(c):
    mp = money(min_price(c))
    name_l = c["name"].lower()
    title = f"Оренда {c['gen']} у Львові — від {mp} грн | Крістал"
    meta_desc = (f"Оренда {c['gen']} для {EVENTS.split(',')[0]}, банкетів і фуршетів у Львові. "
                 f"Ціни від {mp} грн за добу, доставка і вивезення, розрахунок кількості за 15 хвилин.")[:255]
    desc = (
        f"<p>«Крістал» здає в оренду {name_l} для {EVENTS} у Львові та області. "
        f"Ціна — від {mp} грн за одиницю на добу, а для великих подій діють знижки за обсяг.</p>"
        f"<h2>Як замовити оренду {c['gen']}</h2>"
        f"<p>Надішліть дату, кількість гостей і меню — менеджер розрахує, скільки і яких позицій потрібно, "
        f"і підтвердить наявність на складі. Доставляємо, забираємо після події, посуд повертається без миття "
        f"(послуга входить у вартість — уточнюється).</p>"
        f"<h2>Що важливо знати</h2>"
        f"<ul><li>Мінімальне замовлення вказане в картці кожного товару.</li>"
        f"<li>У разі бою або втрати сплачується вартість відшкодування з картки товару.</li>"
        f"<li>Бронювання на дату — після передоплати.</li></ul>"
        f"<p><em>Тексти, ціни й умови на цій сторінці — тестові (мок-дані).</em></p>"
    )
    return title[:255], meta_desc, desc


def prod_texts(p):
    c = p["cat"]
    a = p["attrs"]
    facts = ", ".join(v for k, v in a.items() if k in ("material", "size", "volume", "color"))
    title = f"{p['name']} — оренда у Львові, {money(p['price'])} грн | Крістал"
    meta_desc = (f"{p['name']} в оренду: {money(p['price'])} грн ({unit(p)}), мінімум {p['minimum']} шт. "
                 f"Доставка по Львову, підбір кількості під вашу подію.")[:255]
    excerpt = f"{facts}." if facts else ""
    lis = "".join(f"<li>{ATTRIBUTES[k][1]}: {v}</li>" for k, v in a.items() if k in ATTRIBUTES)
    desc = (f"<p>{p['name']} — для {EVENTS}. {excerpt}</p>"
            f"<ul>{lis}</ul>"
            f"<p>Ціна {money(p['price'])} грн — за {unit(p)}. Мінімальне замовлення — {p['minimum']} шт."
            + (f" Відшкодування при бутті або втраті — {money(p['damage'])} грн за одиницю." if p["damage"] else "")
            + "</p><p><em>Тестовий товар (мок-дані).</em></p>")
    tag = ", ".join(sorted({c["name"].lower(), by_id[c["parent"]]["name"].lower() if c["parent"] else c["name"].lower(), "оренда"}))
    return title[:255], meta_desc, excerpt, desc, tag


# --- SQL: спільне очищення діапазонів ---------------------------------------
def cleanup_sql():
    pr = f"BETWEEN {PROD_RANGE[0]} AND {PROD_RANGE[1]}"
    cr = f"BETWEEN {CAT_RANGE[0]} AND {CAT_RANGE[1]}"
    lines = [f"DELETE FROM `{P}{t}` WHERE `product_id` {pr};" for t in (
        "product", "product_description", "product_to_store", "product_to_layout", "product_to_category",
        "product_attribute", "product_discount", "product_special", "product_image", "product_filter",
        "product_option", "product_option_value", "product_reward", "product_recurring", "product_to_download",
        "review", "cart")]
    lines.append(f"DELETE FROM `{P}product_related` WHERE `product_id` {pr} OR `related_id` {pr};")
    lines += [f"DELETE FROM `{P}{t}` WHERE `category_id` {cr};" for t in (
        "category", "category_description", "category_path", "category_to_store", "category_to_layout", "category_filter")]
    lines.append(f"DELETE FROM `{P}product_to_category` WHERE `category_id` {cr};")
    lines.append(f"DELETE FROM `{P}attribute` WHERE `attribute_id` BETWEEN {ATTR_RANGE[0]} AND {ATTR_RANGE[1]};")
    lines.append(f"DELETE FROM `{P}attribute_description` WHERE `attribute_id` BETWEEN {ATTR_RANGE[0]} AND {ATTR_RANGE[1]};")
    lines.append(f"DELETE FROM `{P}attribute_group` WHERE `attribute_group_id` BETWEEN {AG_RANGE[0]} AND {AG_RANGE[1]};")
    lines.append(f"DELETE FROM `{P}attribute_group_description` WHERE `attribute_group_id` BETWEEN {AG_RANGE[0]} AND {AG_RANGE[1]};")
    lines.append(
        f"DELETE FROM `{P}seo_url`\n WHERE (`query` LIKE 'category\\_id=%' AND CAST(SUBSTRING(`query`, 13) AS UNSIGNED) {cr})\n"
        f"    OR (`query` LIKE 'product\\_id=%' AND CAST(SUBSTRING(`query`, 12) AS UNSIGNED) {pr});")
    return "\n".join(lines)


HEADER = """-- ---------------------------------------------------------------------------
-- 0001_mock_catalog — {kind}
-- ЗГЕНЕРОВАНО: db/seed/generate_mock_catalog.py з db/seed/mock_catalog_data.py.
-- Не редагуйте вручну — змініть дані й перегенеруйте.
-- Специфікація: specs/001-mock-catalog/. УСІ ДАНІ ВИГАДАНІ (мок).
-- Мок НЕ ДЕПЛОЇТЬСЯ на прод (make migrate-print відмовить без ALLOW_MOCK=1).
-- ---------------------------------------------------------------------------
"""


def build_up():
    s = [HEADER.format(kind="UP"), "SET NAMES utf8mb4;", ""]
    s.append("-- 1. Службова таблиця для точного відкату змін у ядрових даних")
    s.append(f"""CREATE TABLE IF NOT EXISTS `{P}kristal_mock_backup` (
  `entity`     VARCHAR(32)  NOT NULL,
  `entity_id`  INT(11)      NOT NULL,
  `field`      VARCHAR(64)  NOT NULL,
  `value`      TEXT         NOT NULL,
  PRIMARY KEY (`entity`, `entity_id`, `field`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;""")
    s.append("\n-- 2. Прибрати попередній мок (повторний up = чистий перезапис)")
    s.append(cleanup_sql())

    # --- конфлікти SEO-ключів
    kws = [c["slug"] for c in categories] + [p["slug"] for p in products]
    assert len(kws) == len(set(kws)), "дублікати SEO-ключів у мок-даних"
    s.append("\n-- 3. Перевірка: жоден мок-ключ ЧПУ не зайнятий реальними сторінками")
    s.append(f"DROP TEMPORARY TABLE IF EXISTS `kristal_tmp_keyword`;")
    s.append(f"CREATE TEMPORARY TABLE `kristal_tmp_keyword` SELECT `keyword` FROM `{P}seo_url` LIMIT 0;")
    s.append("INSERT INTO `kristal_tmp_keyword` (`keyword`) VALUES\n" + ",\n".join(f"({q(k)})" for k in kws) + ";")
    s.append(f"""DELIMITER $$
BEGIN NOT ATOMIC
  DECLARE n INT DEFAULT 0;
  DECLARE taken TEXT DEFAULT '';
  DECLARE msg VARCHAR(128);
  SELECT COUNT(*), IFNULL(GROUP_CONCAT(s.`keyword` SEPARATOR ', '), '') INTO n, taken
    FROM `{P}seo_url` s JOIN `kristal_tmp_keyword` k ON k.`keyword` = s.`keyword`
   WHERE s.`store_id` = {STORE} AND s.`language_id` = {LANG};
  IF n > 0 THEN
    SET msg = LEFT(CONCAT('0001: SEO-ключі вже зайняті: ', taken), 128);
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg;
  END IF;
END$$
DELIMITER ;""")
    s.append("DROP TEMPORARY TABLE IF EXISTS `kristal_tmp_keyword`;")

    # --- старі категорії
    s.append(f"\n-- 4. Сховати старі категорії (стан зберігається в {P}kristal_mock_backup один раз)")
    for field in ("status", "top"):
        s.append(f"INSERT IGNORE INTO `{P}kristal_mock_backup` (`entity`, `entity_id`, `field`, `value`)\n"
                 f"SELECT 'category', `category_id`, '{field}', `{field}` FROM `{P}category`\n"
                 f" WHERE `category_id` NOT BETWEEN {CAT_RANGE[0]} AND {CAT_RANGE[1]};")
    s.append(f"UPDATE `{P}category` SET `status` = 0, `top` = 0 WHERE `category_id` NOT BETWEEN {CAT_RANGE[0]} AND {CAT_RANGE[1]};")

    # --- статуси наявності українською
    statuses = {7: "В наявності", 8: "Під замовлення", 5: "Немає в наявності", 6: "Очікування 2–3 дні"}
    s.append("\n-- 5. Статуси наявності українською (були російською)")
    s.append(f"INSERT IGNORE INTO `{P}kristal_mock_backup` (`entity`, `entity_id`, `field`, `value`)\n"
             f"SELECT 'stock_status', `stock_status_id`, 'name', `name` FROM `{P}stock_status` WHERE `language_id` = {LANG};")
    for sid, name in statuses.items():
        s.append(f"UPDATE `{P}stock_status` SET `name` = {q(name)} WHERE `stock_status_id` = {sid} AND `language_id` = {LANG};")

    # --- атрибути
    s.append("\n-- 6. Атрибути")
    gid, gname = ATTRIBUTE_GROUP
    s.append(ins("attribute_group", ["attribute_group_id", "sort_order"], [[q(gid), "0"]]))
    s.append(ins("attribute_group_description", ["attribute_group_id", "language_id", "name"], [[q(gid), q(LANG), q(gname)]]))
    s.append(ins("attribute", ["attribute_id", "attribute_group_id", "sort_order"],
                 [[q(a[0]), q(gid), q(a[2])] for a in ATTRIBUTES.values()]))
    s.append(ins("attribute_description", ["attribute_id", "language_id", "name"],
                 [[q(a[0]), q(LANG), q(a[1])] for a in ATTRIBUTES.values()]))

    # --- категорії
    s.append("\n-- 7. Категорії")
    s.append(ins("category", ["category_id", "image", "parent_id", "top", "column", "sort_order", "status", "date_added", "date_modified"],
                 [[q(c["id"]), q(f"catalog/kristal/mock/{c['image']}.png"), q(c["parent"]), q(c["top"]), "1", q(c["sort"]), "1", "NOW()", "NOW()"]
                  for c in categories]))
    rows = []
    for c in categories:
        title, md, desc = cat_texts(c)
        rows.append([q(c["id"]), q(LANG), q(c["name"]), q(desc), q(title), q(md), q("оренда, " + c["name"].lower() + ", mock")])
    s.append(ins("category_description", ["category_id", "language_id", "name", "description", "meta_title", "meta_description", "meta_keyword"], rows))
    paths = []
    for c in categories:
        if c["parent"]:
            paths += [[q(c["id"]), q(c["parent"]), "0"], [q(c["id"]), q(c["id"]), "1"]]
        else:
            paths.append([q(c["id"]), q(c["id"]), "0"])
    s.append(ins("category_path", ["category_id", "path_id", "level"], paths))
    s.append(ins("category_to_store", ["category_id", "store_id"], [[q(c["id"]), q(STORE)] for c in categories]))
    s.append(ins("category_to_layout", ["category_id", "store_id", "layout_id"], [[q(c["id"]), q(STORE), "0"] for c in categories]))

    # --- товари
    s.append(f"\n-- 8. Товари ({len(products)} шт.)")
    pcols = ["product_id", "model", "sku", "upc", "ean", "jan", "isbn", "mpn", "location", "quantity", "stock_status_id",
             "image", "manufacturer_id", "shipping", "price", "points", "tax_class_id", "date_available", "weight",
             "weight_class_id", "length", "width", "height", "length_class_id", "subtract", "minimum", "sort_order",
             "status", "viewed", "date_added", "date_modified"]
    rows = []
    for p in products:
        qty = 2000 if p["minimum"] >= 10 else (300 if p["price"] < 1000 else 10)
        rows.append([q(p["id"]), "'MOCK'", q(p["sku"]), "''", "''", "''", "''", "''", "''", q(qty), "7",
                     q(f"catalog/kristal/mock/{p['image']}.png"), "0", "1", f"{p['price']:.4f}", "0", "0", "'2026-01-01'",
                     "0", "1", "0", "0", "0", "1", "0", q(p["minimum"]), q(p["sort"]), "1", "0", "NOW()", "NOW()"])
    s.append(ins("product", pcols, rows))
    rows = []
    for p in products:
        title, md, excerpt, desc, tag = prod_texts(p)
        rows.append([q(p["id"]), q(LANG), q(p["name"]), q(desc), q(excerpt), q(f"ціна за {unit(p)}"[:128]), q(tag),
                     q(title), q(md), q("оренда, mock")])
    s.append(ins("product_description", ["product_id", "language_id", "name", "description", "description_excerpt",
                                         "description_add", "tag", "meta_title", "meta_description", "meta_keyword"], rows))
    s.append(ins("product_to_store", ["product_id", "store_id"], [[q(p["id"]), q(STORE)] for p in products]))
    s.append(ins("product_to_layout", ["product_id", "store_id", "layout_id"], [[q(p["id"]), q(STORE), "0"] for p in products]))
    s.append(ins("product_to_category", ["product_id", "category_id"], [[q(p["id"]), q(cid)] for p in products for cid in p["cats"]]))
    rows = []
    for p in products:
        attrs = dict(p["attrs"])
        attrs.setdefault("unit", "шт. / доба")
        if p["damage"]:
            attrs["damage"] = f"{money(p['damage'])} грн / шт."
        for k, v in attrs.items():
            rows.append([q(p["id"]), q(ATTRIBUTES[k][0]), q(LANG), q(v)])
    s.append(ins("product_attribute", ["product_id", "attribute_id", "language_id", "text"], rows))
    rows, did = [], DISC_RANGE[0]
    for p in products:
        for qty, price in p["discounts"]:
            did += 1
            rows.append([q(did), q(p["id"]), q(CUSTOMER_GROUP), q(qty), "1", f"{price:.4f}", "'0000-00-00'", "'0000-00-00'"])
    s.append(ins("product_discount", ["product_discount_id", "product_id", "customer_group_id", "quantity", "priority",
                                      "price", "date_start", "date_end"], rows))

    # --- ЧПУ
    s.append("\n-- 9. ЧПУ (store 0, uk-ua)")
    rows = [[q(STORE), q(LANG), q(f"category_id={c['id']}"), q(c["slug"])] for c in categories]
    rows += [[q(STORE), q(LANG), q(f"product_id={p['id']}"), q(p["slug"])] for p in products]
    s.append(ins("seo_url", ["store_id", "language_id", "query", "keyword"], rows))
    s.append("\n-- Готово. Далі: make clear-cache")
    return "\n".join(s) + "\n"


def build_down():
    s = [HEADER.format(kind="DOWN"), "SET NAMES utf8mb4;", ""]
    s.append("-- 1. Видалити мок за діапазонами id")
    s.append(cleanup_sql())
    s.append(f"""
-- 2. Повернути старим категоріям і статусам наявності попередній стан
--    (якщо службової таблиці вже немає — нічого не робимо)
CREATE TABLE IF NOT EXISTS `{P}kristal_mock_backup` (
  `entity`     VARCHAR(32)  NOT NULL,
  `entity_id`  INT(11)      NOT NULL,
  `field`      VARCHAR(64)  NOT NULL,
  `value`      TEXT         NOT NULL,
  PRIMARY KEY (`entity`, `entity_id`, `field`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
UPDATE `{P}category` c JOIN `{P}kristal_mock_backup` b
    ON b.`entity` = 'category' AND b.`entity_id` = c.`category_id` AND b.`field` = 'status'
   SET c.`status` = CAST(b.`value` AS UNSIGNED);
UPDATE `{P}category` c JOIN `{P}kristal_mock_backup` b
    ON b.`entity` = 'category' AND b.`entity_id` = c.`category_id` AND b.`field` = 'top'
   SET c.`top` = CAST(b.`value` AS UNSIGNED);
UPDATE `{P}stock_status` s JOIN `{P}kristal_mock_backup` b
    ON b.`entity` = 'stock_status' AND b.`entity_id` = s.`stock_status_id` AND b.`field` = 'name'
   SET s.`name` = b.`value`
 WHERE s.`language_id` = {LANG};

-- 3. Прибрати службову таблицю
DROP TABLE IF EXISTS `{P}kristal_mock_backup`;

-- Готово. Далі: make clear-cache""")
    return "\n".join(s) + "\n"


def main():
    os.makedirs(OUT, exist_ok=True)
    for kind, body in (("up", build_up()), ("down", build_down())):
        path = os.path.join(OUT, f"0001_mock_catalog.{kind}.sql")
        with open(path, "w", encoding="utf-8") as f:
            f.write(body)
        print(f"записано {os.path.relpath(path)} ({len(body.encode()) // 1024} КБ)")
    leaves = [c for c in categories if c["own"]]
    print(f"категорій: {len(categories)} (верхніх {sum(1 for c in categories if not c['parent'])}, з товарами {len(leaves)}), "
          f"товарів: {len(products)}, знижок: {sum(len(p['discounts']) for p in products)}")


if __name__ == "__main__":
    main()
