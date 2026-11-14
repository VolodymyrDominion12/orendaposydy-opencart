-- Вирівняти рівні category_path до конвенції OpenCart: level 0 — корінь, останній — сама категорія.
-- У контент-паку 2026-11-11 рівні були записані навпаки (сама = 0), через що sitemap
-- будував /tarilky/posud замість /posud/tarilky. Ідемпотентно: править лише ті категорії,
-- де рядок самої категорії має level = 0, а максимальний level > 0.
UPDATE `{{PREFIX}}category_path` cp
  JOIN (SELECT category_id, MAX(level) AS mx FROM `{{PREFIX}}category_path` GROUP BY category_id) m
    ON (m.category_id = cp.category_id)
  JOIN (SELECT category_id, level AS self_level FROM `{{PREFIX}}category_path` WHERE path_id = category_id) s
    ON (s.category_id = cp.category_id)
   SET cp.level = m.mx - cp.level
 WHERE m.mx > 0 AND s.self_level = 0;
