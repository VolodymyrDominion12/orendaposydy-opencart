#!/usr/bin/env node
/* Генерує заглушки зображень категорій (мок, фіча 001) у фірмовому стилі
 * брендбуку: тло night, подвійна золота рамка, назва категорії.
 *   node db/seed/make_placeholders.cjs   (потрібен Playwright: make mobile-setup)
 * Результат: src/image/catalog/kristal/mock/<key>.png, 800×800. */
'use strict';
const path = require('path');
let chromium;
try { ({ chromium } = require('playwright')); }
catch (e) { ({ chromium } = require(path.join(__dirname, '../../tests/mobile/node_modules/playwright'))); }

const OUT = path.join(__dirname, '../../src/image/catalog/kristal/mock');
const ITEMS = {
  posud: 'Посуд', prybory: 'Столові прибори', sklo: 'Скло та келихи', kukhnia: 'Кухонне обладнання',
  kava: 'Кавове обладнання', bar: 'Барне обладнання', mebli: 'Меблі', tekstyl: 'Текстиль',
  shatry: 'Шатри та накриття', dekor: 'Декор', eko: 'Екопосуд',
};
const html = name => `<!doctype html><html><head><meta charset="utf-8"><style>
  html,body{margin:0;width:800px;height:800px;background:#141012}
  .f{position:absolute;inset:40px;border:2px solid #ffc22e}
  .f2{position:absolute;inset:52px;border:1px solid rgba(255,194,46,.55)}
  .c{position:absolute;inset:0;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:28px;text-align:center}
  .k{font:600 30px/1 Georgia,'Times New Roman',serif;letter-spacing:.32em;color:#ffc22e}
  .n{font:400 64px/1.1 Georgia,'Times New Roman',serif;color:#f6f0e8;max-width:600px}
  .m{font:500 22px/1.4 'DejaVu Sans',Arial,sans-serif;color:#ada3a3}
  .t{position:absolute;bottom:76px;left:0;right:0;text-align:center;font:600 18px 'DejaVu Sans Mono',monospace;color:#c41e24;letter-spacing:.2em}
</style></head><body><div class="f"></div><div class="f2"></div>
<div class="c"><div class="k">КРІСТАЛ</div><div class="n">${name}</div><div class="m">фото з'явиться пізніше</div></div>
<div class="t">MOCK</div></body></html>`;

(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage({ viewport: { width: 800, height: 800 } });
  for (const [key, name] of Object.entries(ITEMS)) {
    await page.setContent(html(name));
    await page.screenshot({ path: path.join(OUT, `${key}.png`) });
    console.log(`  ${key}.png`);
  }
  await browser.close();
})();
