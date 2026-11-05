#!/usr/bin/env node
/* ---------------------------------------------------------------------------
 * Мобільний аудит сторінок вітрини (Playwright + Chromium).
 *
 * Емуляція як у Lighthouse mobile: 360×640, DPR 3, тач, повільний 4G
 * (RTT 150 мс, 1.6 Мбіт/с), CPU ×4 повільніше.
 *
 * Для кожної сторінки з tests/mobile/pages.txt міряє і порівнює з
 * tests/mobile/budgets.json:
 *   lcp_ms, cls, tbt_ms           — Core Web Vitals (TBT — замінник INP у лабораторії)
 *   total_kb, js_kb, css_kb, img_kb, font_kb, requests — вага сторінки (передано по мережі)
 *   overflow                      — елементи, що виходять за ширину 360px (горизонтальний скрол)
 *   tap_small                     — кнопки/посилання/поля менші за 44×44
 *   small_text                    — текст дрібніший за 12px
 *   img_no_dims                   — <img> без width/height (стрибки макета)
 *   img_not_lazy                  — картинки нижче першого екрана без loading="lazy"
 *   img_oversized                 — картинка в 2+ рази більша, ніж потрібно екрану
 *   img_legacy                    — JPEG/PNG там, де мав бути WebP/AVIF
 *   viewport_bad                  — немає width=device-width або заборонено масштабування
 *   tel_inputs                    — поле телефону не type="tel"
 *
 * Запуск:  node tests/mobile/mobile-audit.cjs [BASE]   (або make test-mobile)
 * Змінні:  BASE, URL (одна сторінка), SCREENSHOTS=0 (вимкнути знімки)
 * Знімки екрана: tests/mobile/out/*.png
 * ------------------------------------------------------------------------- */
'use strict';
const fs = require('fs');
const path = require('path');
const { chromium, devices } = require('playwright');

const DIR = __dirname;
const BASE = (process.argv[2] || process.env.BASE || 'http://localhost:8090').replace(/\/$/, '');
const budgets = JSON.parse(fs.readFileSync(path.join(DIR, 'budgets.json'), 'utf8'));
const OUT = path.join(DIR, 'out');
const SHOTS = process.env.SCREENSHOTS !== '0';

const C = process.stdout.isTTY
  ? { r: '\x1b[31m', g: '\x1b[32m', y: '\x1b[33m', b: '\x1b[1m', x: '\x1b[0m' }
  : { r: '', g: '', y: '', b: '', x: '' };

function readPages() {
  if (process.env.URL) return [{ path: process.env.URL, allow: [] }];
  return fs.readFileSync(path.join(DIR, 'pages.txt'), 'utf8')
    .split('\n')
    .map(l => l.replace(/#.*/, '').trim())
    .filter(Boolean)
    .map(l => {
      const [p, opt] = l.split(/\s+/);
      const allow = opt && opt.startsWith('allow=') ? opt.slice(6).split(',') : [];
      return { path: p, allow };
    });
}

/* Метрики, які збираються всередині сторінки з першого байта */
const INIT = () => {
  window.__k = { lcp: 0, cls: 0, tbt: 0 };
  try {
    new PerformanceObserver(l => { for (const e of l.getEntries()) window.__k.lcp = e.renderTime || e.loadTime || e.startTime; })
      .observe({ type: 'largest-contentful-paint', buffered: true });
    new PerformanceObserver(l => { for (const e of l.getEntries()) if (!e.hadRecentInput) window.__k.cls += e.value; })
      .observe({ type: 'layout-shift', buffered: true });
    new PerformanceObserver(l => { for (const e of l.getEntries()) window.__k.tbt += Math.max(0, e.duration - 50); })
      .observe({ type: 'longtask', buffered: true });
  } catch (e) { /* старий браузер */ }
};

/* Перевірки макета на готовій сторінці */
const LAYOUT = () => {
  const W = window.innerWidth, H = window.innerHeight, dpr = window.devicePixelRatio || 1;
  const visible = el => {
    const s = getComputedStyle(el);
    if (s.display === 'none' || s.visibility === 'hidden' || +s.opacity === 0) return false;
    const r = el.getBoundingClientRect();
    return r.width > 0 && r.height > 0;
  };
  const sel = el => {
    let s = el.tagName.toLowerCase();
    if (el.id) s += '#' + el.id;
    else if (el.className && typeof el.className === 'string') s += '.' + el.className.trim().split(/\s+/).slice(0, 2).join('.');
    return s;
  };
  const res = { overflow: [], tap_small: [], small_text: 0, img_no_dims: [], img_not_lazy: [], img_oversized: [], tel_inputs: [], viewport_bad: 0 };

  // горизонтальний скрол
  if (document.documentElement.scrollWidth > W + 1) {
    for (const el of document.body.querySelectorAll('*')) {
      if (!visible(el)) continue;
      const r = el.getBoundingClientRect();
      if (r.right > W + 1 && getComputedStyle(el).position !== 'fixed') {
        res.overflow.push(`${sel(el)} (права межа ${Math.round(r.right)}px)`);
        if (res.overflow.length >= 8) break;
      }
    }
    if (!res.overflow.length) res.overflow.push(`документ ширший за екран: ${document.documentElement.scrollWidth}px`);
  }

  // мета viewport
  const vp = document.querySelector('meta[name="viewport"]');
  const vc = vp ? vp.content.replace(/\s/g, '') : '';
  if (!/width=device-width/.test(vc) || /user-scalable=(no|0)/.test(vc) || /maximum-scale=1(\.0)?(,|$)/.test(vc)) res.viewport_bad = 1;

  // клікабельні зони (посилання всередині тексту абзацу не рахуємо)
  for (const el of document.querySelectorAll('a[href], button, input:not([type=hidden]), select, textarea, [role=button]')) {
    if (!visible(el)) continue;
    if (el.tagName === 'A' && el.closest('p, li p, td')) continue;
    const r = el.getBoundingClientRect();
    if (r.width < 44 || r.height < 44) res.tap_small.push(`${sel(el)} ${Math.round(r.width)}×${Math.round(r.height)}`);
  }

  // дрібний текст
  const walker = document.createTreeWalker(document.body, NodeFilter.SHOW_TEXT);
  const seen = new Set();
  while (walker.nextNode()) {
    const n = walker.currentNode;
    if (!n.textContent.trim() || !n.parentElement || seen.has(n.parentElement)) continue;
    seen.add(n.parentElement);
    if (!visible(n.parentElement)) continue;
    if (parseFloat(getComputedStyle(n.parentElement).fontSize) < 12) res.small_text++;
  }

  // зображення
  for (const img of document.images) {
    if (!visible(img)) continue;
    const r = img.getBoundingClientRect();
    const name = (img.currentSrc || img.src || '').split('/').pop().slice(0, 60);
    if (!img.getAttribute('width') || !img.getAttribute('height')) res.img_no_dims.push(name);
    if (r.top > H * 1.2 && img.getAttribute('loading') !== 'lazy') res.img_not_lazy.push(name);
    if (img.naturalWidth > 400 && img.naturalWidth > r.width * dpr * 2) res.img_oversized.push(`${name} ${img.naturalWidth}px для ${Math.round(r.width)}px`);
  }

  // телефон у формах
  for (const i of document.querySelectorAll('input[name*="phone" i], input[name*="telephone" i], input[name*="tel" i]')) {
    if (i.type !== 'tel') res.tel_inputs.push(i.name);
  }
  return res;
};

async function auditPage(browser, page) {
  const ctx = await browser.newContext({ ...devices['Moto G4'], locale: 'uk-UA' });
  const tab = await ctx.newPage();
  const cdp = await ctx.newCDPSession(tab);
  await cdp.send('Network.enable');
  await cdp.send('Network.emulateNetworkConditions', {
    offline: false, latency: 150, downloadThroughput: 1.6 * 1000 * 1000 / 8, uploadThroughput: 750 * 1000 / 8,
  });
  await cdp.send('Emulation.setCPUThrottlingRate', { rate: 4 });

  const types = {}, bytes = { total: 0, js: 0, css: 0, img: 0, font: 0 };
  const legacy = [];
  let requests = 0;
  cdp.on('Network.responseReceived', e => {
    types[e.requestId] = { type: e.type, mime: e.response.mimeType, url: e.response.url };
  });
  cdp.on('Network.loadingFinished', e => {
    const t = types[e.requestId]; if (!t) return;
    requests++;
    const n = e.encodedDataLength || 0;
    bytes.total += n;
    if (t.type === 'Script') bytes.js += n;
    else if (t.type === 'Stylesheet') bytes.css += n;
    else if (t.type === 'Image') { bytes.img += n; if (/image\/(jpeg|png)/.test(t.mime) && n > 20 * 1024) legacy.push(t.url.split('/').pop().slice(0, 60)); }
    else if (t.type === 'Font') bytes.font += n;
  });

  await tab.addInitScript(INIT);
  const url = BASE + page.path;
  let status = 0;
  try {
    const resp = await tab.goto(url, { waitUntil: 'load', timeout: 90000 });
    status = resp ? resp.status() : 0;
    await tab.waitForTimeout(1500);
  } catch (e) {
    await ctx.close();
    return { page, status: 0, error: e.message.split('\n')[0] };
  }
  // прокрутка вниз-вгору, щоб спрацювали lazy-картинки і зсуви макета
  await tab.evaluate(async () => { window.scrollTo(0, document.body.scrollHeight); await new Promise(r => setTimeout(r, 400)); window.scrollTo(0, 0); });
  await tab.waitForTimeout(500);

  const vitals = await tab.evaluate(() => window.__k);
  const layout = await tab.evaluate(LAYOUT);
  if (SHOTS) {
    fs.mkdirSync(OUT, { recursive: true });
    const slug = page.path.replace(/[^a-z0-9]+/gi, '_').replace(/^_|_$/g, '') || 'home';
    await tab.screenshot({ path: path.join(OUT, `${slug}.png`), fullPage: false });
  }
  await ctx.close();
  const kb = n => Math.round(n / 1024);
  return {
    page, status,
    metrics: {
      lcp_ms: Math.round(vitals.lcp), cls: Math.round(vitals.cls * 1000) / 1000, tbt_ms: Math.round(vitals.tbt),
      total_kb: kb(bytes.total), js_kb: kb(bytes.js), css_kb: kb(bytes.css), img_kb: kb(bytes.img), font_kb: kb(bytes.font), requests,
      overflow: layout.overflow.length, tap_small: layout.tap_small.length, small_text: layout.small_text,
      img_no_dims: layout.img_no_dims.length, img_not_lazy: layout.img_not_lazy.length,
      img_oversized: layout.img_oversized.length, img_legacy: legacy.length,
      viewport_bad: layout.viewport_bad, tel_inputs: layout.tel_inputs.length,
    },
    details: {
      overflow: layout.overflow, tap_small: layout.tap_small, img_no_dims: layout.img_no_dims,
      img_not_lazy: layout.img_not_lazy, img_oversized: layout.img_oversized, img_legacy: legacy, tel_inputs: layout.tel_inputs,
    },
  };
}

(async () => {
  const pages = readPages();
  const browser = await chromium.launch();
  let failed = 0, warned = 0;
  console.log(`${C.b}Мобільний аудит: ${BASE}${C.x}  (360×640, DPR 3, slow 4G, CPU ×4)`);
  for (const page of pages) {
    const r = await auditPage(browser, page);
    console.log(`\n${C.b}${page.path}${C.x}  HTTP ${r.status}`);
    if (r.error) { console.log(`  ${C.r}ПОМИЛКА${C.x} ${r.error}`); failed++; continue; }
    let pageFail = false;
    for (const [key, val] of Object.entries(r.metrics)) {
      const lim = budgets[key];
      if (lim === undefined) continue;
      const over = val > lim;
      const allowed = page.allow.includes(key) || page.allow.includes('all');
      const mark = !over ? `${C.g}ok${C.x}` : allowed ? `${C.y}дозволено${C.x}` : `${C.r}ПОНАД БЮДЖЕТ${C.x}`;
      console.log(`  ${key.padEnd(14)} ${String(val).padStart(7)}  ≤ ${String(lim).padEnd(6)} ${mark}`);
      if (over && !allowed) pageFail = true;
      if (over && allowed) warned++;
      const d = r.details[key];
      if (over && d && d.length) for (const item of d.slice(0, 5)) console.log(`      · ${item}`);
    }
    if (pageFail) failed++;
  }
  await browser.close();
  console.log('');
  if (failed) { console.log(`${C.r}  ПОМИЛКА${C.x} сторінок понад бюджет: ${failed} з ${pages.length}`); process.exit(1); }
  console.log(`${C.g}  OK${C.x} усі ${pages.length} сторінок у мобільному бюджеті${warned ? ` (дозволених перевищень: ${warned})` : ''}. Знімки: tests/mobile/out/`);
})().catch(e => { console.error(e); process.exit(2); });
