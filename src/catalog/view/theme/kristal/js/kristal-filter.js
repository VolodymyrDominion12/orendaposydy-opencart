/* Фільтри категорії (фіча 021). Підключається лише на категоріях із фільтрами.
   ≥ 1024 px: відмітка → fetch форми (сервер 302 на канонічну адресу, r.url) → заміна [data-k-swap], лічильники, pushState.
   < 1024 px: шторка; відмітка → ?kf=json → «Показати N товарів»; «Показати» — звичайна відправка форми.
   Без JS: значення — посилання, форма з кнопкою «Показати», шторка через :target (#filters). */
(function () {
  'use strict';
  var doc = document, root = doc.documentElement;
  var panel = doc.querySelector('[data-k-fpanel]'), form = panel && panel.querySelector('[data-k-filter]');
  if (!panel || !form || !window.fetch || !window.DOMParser) return;

  var mq = window.matchMedia('(min-width: 1024px)');
  var opener = null, seq = 0;
  var FOCUSABLE = 'a[href], button:not([disabled]), input:not([disabled]), summary';

  function live() { return mq.matches; }
  function setLive() { if (live()) panel.setAttribute('data-k-live', ''); else panel.removeAttribute('data-k-live'); }

  function query(extra) {
    var params = new URLSearchParams(new FormData(form));
    ['pmin', 'pmax'].forEach(function (n) { if (params.get(n) === '') params.delete(n); });
    if (!params.has('fv[]') && !params.has('pmin') && !params.has('pmax')) params.set('pmin', '');
    if (extra) params.set('kf', extra);
    return form.action + (form.action.indexOf('?') < 0 ? '?' : '&') + params.toString();
  }

  // ---------- Шторка (мобільний) ----------
  function open(btn) {
    if (live() || panel.classList.contains('is-open')) return;
    opener = btn || doc.activeElement;
    panel.classList.add('is-open');
    root.classList.add('k-lock');
    setExpanded(true);
    if (history.pushState) history.pushState({ kf: 1 }, '');
    var first = panel.querySelector('[data-k-fclose]:not(.k-sheet__bg)');
    if (first) first.focus();
  }

  function shut() {
    if (!panel.classList.contains('is-open')) return;
    panel.classList.remove('is-open');
    root.classList.remove('k-lock');
    setExpanded(false);
    if (opener && opener.focus) opener.focus();
    opener = null;
  }

  function close() {
    if (history.state && history.state.kf) history.back(); else shut();
  }

  function setExpanded(v) {
    doc.querySelectorAll('[data-k-fopen]').forEach(function (b) { b.setAttribute('aria-expanded', v ? 'true' : 'false'); });
  }

  doc.addEventListener('click', function (e) {
    var t = e.target.closest ? e.target : null;
    if (!t) return;
    var btn = t.closest('[data-k-fopen]');
    if (btn) { e.preventDefault(); open(btn); return; }
    if (t.closest('[data-k-fclose]')) { e.preventDefault(); close(); return; }
    // Назва значення — посилання (без JS); з JS — перемикає відмітку
    var a = t.closest('.k-check a');
    if (a && panel.contains(a)) {
      e.preventDefault();
      var box = a.parentNode.querySelector('input');
      if (box && !box.disabled) { box.checked = !box.checked; changed(); }
    }
  });

  panel.addEventListener('keydown', function (e) {
    if (e.key === 'Escape' && panel.classList.contains('is-open')) { close(); return; }
    if (e.key !== 'Tab' || !panel.classList.contains('is-open')) return;
    var items = Array.prototype.filter.call(panel.querySelectorAll(FOCUSABLE), function (el) { return el.offsetParent !== null; });
    if (!items.length) return;
    var first = items[0], last = items[items.length - 1];
    if (e.shiftKey && doc.activeElement === first) { e.preventDefault(); last.focus(); }
    else if (!e.shiftKey && doc.activeElement === last) { e.preventDefault(); first.focus(); }
  });

  window.addEventListener('popstate', function () {
    if (panel.classList.contains('is-open')) { shut(); return; }
    if (live()) load(location.href, false);
  });

  // ---------- Зміни ----------
  var timer = null;
  function changed() {
    clearTimeout(timer);
    timer = setTimeout(function () { if (live()) load(query(''), true); else count(); }, 150);
  }

  form.addEventListener('change', function (e) {
    if (e.target.name === 'pmin' || e.target.name === 'pmax' || e.target.type === 'checkbox') changed();
  });

  form.addEventListener('submit', function (e) {
    if (!live()) return; // мобільний: звичайний перехід (302 на канонічну адресу)
    e.preventDefault();
    load(query(''), true);
  });

  function count() {
    var n = ++seq, btn = form.querySelector('[data-k-fshow]');
    fetch(query('json'), { credentials: 'same-origin' }).then(function (r) { return r.json(); }).then(function (json) {
      if (n === seq && btn) btn.textContent = json.text;
    }).catch(function () {});
  }

  function load(url, push) {
    var n = ++seq, results = doc.querySelector('[data-k-results]');
    if (results) results.setAttribute('aria-busy', 'true');
    fetch(url, { credentials: 'same-origin' }).then(function (r) {
      return r.text().then(function (html) { return { url: r.url, html: html }; });
    }).then(function (res) {
      if (n !== seq) return;
      var page = new DOMParser().parseFromString(res.html, 'text/html');
      var olds = doc.querySelectorAll('[data-k-swap]'), news = page.querySelectorAll('[data-k-swap]');
      if (olds.length !== news.length) { location.href = res.url; return; }
      olds.forEach(function (el, i) { el.innerHTML = news[i].innerHTML; });
      sync(page);
      if (page.title) doc.title = page.title;
      if (push && history.pushState) history.pushState(null, '', res.url);
      doc.dispatchEvent(new CustomEvent('k:results'));
    }).catch(function () { location.href = url; }).then(function () {
      var r = doc.querySelector('[data-k-results]');
      if (r) r.removeAttribute('aria-busy');
    });
  }

  // Колонка оновлюється на місці (фокус лишається на відмітці); інший набір значень — заміна тіла
  function sync(page) {
    var body = form.querySelector('[data-k-fbody]'), next = page.querySelector('[data-k-fbody]');
    if (!body || !next) return;
    var a = body.querySelectorAll('.k-check input'), b = next.querySelectorAll('.k-check input');
    var same = a.length === b.length && Array.prototype.every.call(a, function (el, i) { return el.value === b[i].value; });
    if (!same) { body.innerHTML = next.innerHTML; return; }
    var labels = body.querySelectorAll('.k-check'), nlabels = next.querySelectorAll('.k-check');
    labels.forEach(function (label, i) {
      var nl = nlabels[i], input = label.querySelector('input'), ninput = nl.querySelector('input');
      input.checked = ninput.checked;
      input.disabled = ninput.disabled;
      label.className = nl.className;
      label.querySelector('small').textContent = nl.querySelector('small').textContent;
      var link = label.querySelector('a, span'), nlink = nl.querySelector('a, span');
      if (link.tagName !== nlink.tagName) label.replaceChild(doc.importNode(nlink, true), link);
      else if (nlink.tagName === 'A') { link.href = nlink.href; if (nlink.rel) link.rel = nlink.rel; else link.removeAttribute('rel'); }
    });
    ['pmin', 'pmax'].forEach(function (n) {
      var el = form.querySelector('[name="' + n + '"]'), ne = next.querySelector('[name="' + n + '"]');
      if (el && ne) { if (doc.activeElement !== el) el.value = ne.value; el.placeholder = ne.placeholder; }
    });
    var show = form.querySelector('[data-k-fshow]'), nshow = page.querySelector('[data-k-fshow]');
    if (show && nshow) show.textContent = nshow.textContent;
  }

  setLive();
  var onMq = function () { setLive(); if (live()) shut(); };
  if (mq.addEventListener) mq.addEventListener('change', onMq); else if (mq.addListener) mq.addListener(onMq);
  // Відкрито посиланням #filters до завантаження JS → керований режим
  if (location.hash === '#filters' && !live()) {
    if (history.replaceState) history.replaceState(null, '', location.pathname + location.search);
    open(null);
  }
})();
