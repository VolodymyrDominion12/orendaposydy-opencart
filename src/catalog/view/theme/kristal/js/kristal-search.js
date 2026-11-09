/* Крістал — підказки пошуку (фіча 027). Підключає kristal.js при першому відкритті панелі пошуку.
   Поле — combobox, список — listbox з aria-activedescendant; ↑/↓ — вибір, Enter — відкрити вибране (інакше — сторінка результатів), Esc — сховати список.
   Запит — через 250 мс після останньої літери, попередній скасовується (AbortController); відповіді кешуються на сторінці.
   Дані з сервера вставляються лише як текст (textContent / текстові вузли), без innerHTML (AC-10). */
(function () {
  'use strict';

  var doc = document, form = doc.querySelector('[data-k-search-form]');
  if (!form || form.getAttribute('data-k-ready')) return;
  form.setAttribute('data-k-ready', '1');

  var input = form.querySelector('input[name="q"]');
  var list = doc.getElementById(input.getAttribute('aria-controls'));
  var status = doc.querySelector('[data-k-search-status]');
  var url = form.getAttribute('data-suggest');
  var T = { all: form.getAttribute('data-t-all'), none: form.getAttribute('data-t-none'), count: form.getAttribute('data-t-count'), cat: form.getAttribute('data-t-cat') };
  var timer = null, ctrl = null, active = -1, options = [], cache = {}, current = '';

  function fmt(s, v) { return String(s || '').replace('%s', v); }

  function words(q) {
    return q.toLowerCase().replace(/['’ʼ`]/g, '').split(/[^0-9a-zа-яіїєґ]+/i).filter(Boolean);
  }

  // Виділити в назві початки слів, що збігаються зі словами запиту (<mark>), — лише текстові вузли
  function highlight(el, text, q) {
    var ws = words(q);
    text.split(/(\s+)/).forEach(function (part) {
      var low = part.toLowerCase().replace(/['’ʼ`]/g, ''), len = 0;
      ws.forEach(function (w) { if (w.length > len && low.indexOf(w) === 0 && low.length === part.length) len = w.length; });
      if (len) {
        var m = doc.createElement('mark');
        m.textContent = part.slice(0, len);
        el.appendChild(m);
        el.appendChild(doc.createTextNode(part.slice(len)));
      } else {
        el.appendChild(doc.createTextNode(part));
      }
    });
  }

  function el(tag, cls, text) {
    var n = doc.createElement(tag);
    if (cls) n.className = cls;
    if (text) n.textContent = text;
    return n;
  }

  function option(href, cls) {
    var a = el('a', 'k-search__opt ' + cls);
    a.href = href;
    a.id = 'k-sopt-' + options.length;
    a.setAttribute('role', 'option');
    a.setAttribute('aria-selected', 'false');
    a.tabIndex = -1;
    options.push(a);
    list.appendChild(a);
    return a;
  }

  function hide() {
    list.hidden = true;
    list.textContent = '';
    options = [];
    active = -1;
    input.setAttribute('aria-expanded', 'false');
    input.removeAttribute('aria-activedescendant');
  }

  function render(d) {
    hide();
    var q = d.layout || d.q;

    d.items.forEach(function (item) {
      var a = option(item.href, 'k-search__opt--product');
      var img = el('img');
      img.src = item.img;
      if (item.srcset) img.srcset = item.srcset;
      img.width = 48; img.height = 48; img.alt = ''; img.loading = 'lazy'; img.decoding = 'async';
      a.appendChild(img);
      var name = el('span', 'k-search__name');
      highlight(name, item.name, q);
      a.appendChild(name);
      if (item.price) a.appendChild(el('span', 'k-search__price', item.price));
    });

    d.cats.forEach(function (cat) {
      var a = option(cat.href, 'k-search__opt--cat');
      a.appendChild(el('span', 'k-search__tag', T.cat));
      var name = el('span', 'k-search__name');
      highlight(name, cat.name, q);
      a.appendChild(name);
    });

    if (d.total > 0) {
      option(d.all, 'k-search__all').textContent = fmt(T.all, d.total);
    } else if (!d.cats.length) {
      list.appendChild(el('p', 'k-search__empty', T.none));
    }

    list.hidden = false;
    input.setAttribute('aria-expanded', options.length ? 'true' : 'false');
    status.textContent = (d.total || d.cats.length) ? fmt(T.count, d.total || d.cats.length) : T.none;
  }

  function select(i) {
    if (!options.length) return;
    if (active >= 0) options[active].setAttribute('aria-selected', 'false');
    active = (i + options.length) % options.length;
    var o = options[active];
    o.setAttribute('aria-selected', 'true');
    input.setAttribute('aria-activedescendant', o.id);
    o.scrollIntoView({ block: 'nearest' });
  }

  function suggest() {
    var q = input.value.replace(/\s+/g, ' ').trim().slice(0, 64);
    current = q;
    if (ctrl) { ctrl.abort(); ctrl = null; }
    if (q.replace(/[^0-9a-zа-яіїєґ]/gi, '').length < 2) { hide(); status.textContent = ''; return; }
    if (cache[q]) { render(cache[q]); return; }

    ctrl = window.AbortController ? new AbortController() : null;
    fetch(url + '&q=' + encodeURIComponent(q), { credentials: 'same-origin', signal: ctrl ? ctrl.signal : undefined })
      .then(function (r) { return r.json(); })
      .then(function (d) {
        if (d.limited) return;
        cache[q] = d;
        if (q === current) render(d);
      })
      .catch(function () { /* скасовано або мережа — список просто не оновлюється */ });
  }

  input.addEventListener('input', function () {
    clearTimeout(timer);
    timer = setTimeout(suggest, 250);
  });

  input.addEventListener('keydown', function (e) {
    if (e.key === 'ArrowDown' || e.key === 'ArrowUp') {
      if (list.hidden) { suggest(); return; }
      e.preventDefault();
      select(active + (e.key === 'ArrowDown' ? 1 : -1));
    } else if (e.key === 'Enter' && active >= 0 && options[active]) {
      e.preventDefault();
      location.href = options[active].href;
    } else if (e.key === 'Escape' && !list.hidden) {
      e.stopPropagation();
      hide();
    }
  });

  list.addEventListener('mousemove', function (e) {
    var o = e.target.closest('.k-search__opt');
    var i = o ? options.indexOf(o) : -1;
    if (i >= 0 && i !== active) select(i);
  });

  doc.addEventListener('k-search-close', function () {
    clearTimeout(timer);
    if (ctrl) ctrl.abort();
    hide();
  });

  // Скрипт підключився, коли в полі вже щось набрано
  if (input.value.trim().length >= 2 && doc.activeElement === input) suggest();
})();
