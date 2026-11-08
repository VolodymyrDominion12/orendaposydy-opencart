/* Крістал — поведінка теми (фіча 003). Ванільний JS без залежностей, підключається з defer.
   1) Шторка меню: відкриття/закриття, фокус усередині, Esc, блок прокрутки фону, повернення фокусу.
   2) Мегаменю «Каталог»: натискання (дотикові екрани ≥1024), Esc, aria-expanded.
   3) Карта у футері: iframe Google Maps вставляється лише після натискання. */
(function () {
  'use strict';

  var doc = document, root = doc.documentElement;
  var FOCUSABLE = 'a[href], button:not([disabled]), input:not([disabled]), select, textarea, summary, [tabindex]:not([tabindex="-1"])';

  // ---------- 1. Шторка ----------
  var drawer = doc.getElementById('menu');
  var opener = null;

  function openDrawer(trigger) {
    if (!drawer || drawer.classList.contains('is-open')) return;
    opener = trigger || doc.activeElement;
    drawer.classList.add('is-open');
    drawer.removeAttribute('hidden');
    root.classList.add('k-lock');
    setExpanded(true);
    var first = drawer.querySelector('[data-k-close]') || drawer.querySelector(FOCUSABLE);
    if (first) first.focus();
  }

  function closeDrawer() {
    if (!drawer || !drawer.classList.contains('is-open')) return;
    drawer.classList.remove('is-open');
    root.classList.remove('k-lock');
    setExpanded(false);
    if (location.hash === '#menu' && history.replaceState) history.replaceState(null, '', location.pathname + location.search);
    if (opener && opener.focus) opener.focus();
    opener = null;
  }

  function setExpanded(state) {
    doc.querySelectorAll('[data-k-open="menu"]').forEach(function (el) { el.setAttribute('aria-expanded', state ? 'true' : 'false'); });
  }

  if (drawer) {
    doc.querySelectorAll('[data-k-open="menu"]').forEach(function (el) {
      el.addEventListener('click', function (e) { e.preventDefault(); openDrawer(el); });
    });

    drawer.addEventListener('click', function (e) {
      var t = e.target.closest('a, [data-k-close]');
      if (!t) return;
      // Закрити: кнопка «×» або перехід за якорем на цій сторінці (#contacts)
      if (t.hasAttribute('data-k-close') || (t.getAttribute('href') || '').charAt(0) === '#') {
        if (t.hasAttribute('data-k-close')) e.preventDefault();
        closeDrawer();
      }
    });

    drawer.addEventListener('keydown', function (e) {
      if (e.key !== 'Tab' || !drawer.classList.contains('is-open')) return;
      var items = Array.prototype.filter.call(drawer.querySelectorAll(FOCUSABLE), function (el) { return el.offsetParent !== null; });
      if (!items.length) return;
      var first = items[0], last = items[items.length - 1];
      if (e.shiftKey && doc.activeElement === first) { e.preventDefault(); last.focus(); }
      else if (!e.shiftKey && doc.activeElement === last) { e.preventDefault(); first.focus(); }
    });

    // Без JS шторка відкривається через :target (#menu); з JS — переводимо в керований режим
    if (location.hash === '#menu') openDrawer(null);

    // Розширили вікно до десктопа — шторка не потрібна
    if (window.matchMedia) {
      var mq = window.matchMedia('(min-width: 1024px)');
      var onMq = function () { if (mq.matches) closeDrawer(); };
      if (mq.addEventListener) mq.addEventListener('change', onMq); else if (mq.addListener) mq.addListener(onMq);
    }
  }

  // ---------- 2. Мегаменю ----------
  var megaItems = doc.querySelectorAll('[data-k-mega]');

  function closeMega(except) {
    megaItems.forEach(function (li) {
      if (li === except) return;
      li.classList.remove('is-open');
      var b = li.querySelector('.k-nav__btn');
      if (b) b.setAttribute('aria-expanded', 'false');
    });
  }

  megaItems.forEach(function (li) {
    var btn = li.querySelector('.k-nav__btn');
    if (!btn) return;
    btn.addEventListener('click', function () {
      var open = !li.classList.contains('is-open');
      closeMega(li);
      li.classList.toggle('is-open', open);
      btn.setAttribute('aria-expanded', open ? 'true' : 'false');
    });
    li.addEventListener('focusout', function (e) {
      if (!li.contains(e.relatedTarget)) { li.classList.remove('is-open'); btn.setAttribute('aria-expanded', 'false'); }
    });
  });

  doc.addEventListener('click', function (e) {
    if (!e.target.closest('[data-k-mega]')) closeMega(null);
  });

  // ---------- Esc ----------
  doc.addEventListener('keydown', function (e) {
    if (e.key !== 'Escape') return;
    if (drawer && drawer.classList.contains('is-open')) { closeDrawer(); return; }
    var open = doc.querySelector('[data-k-mega].is-open');
    if (open) {
      closeMega(null);
      var b = open.querySelector('.k-nav__btn');
      if (b) b.focus();
    }
  });

  // ---------- 3. Карта за кліком ----------
  doc.querySelectorAll('[data-k-map]').forEach(function (btn) {
    btn.addEventListener('click', function () {
      var box = btn.closest('.k-footer__map');
      if (!box) return;
      var frame = doc.createElement('iframe');
      frame.src = btn.getAttribute('data-k-map');
      frame.title = btn.getAttribute('data-k-title') || '';
      frame.loading = 'lazy';
      frame.referrerPolicy = 'no-referrer-when-downgrade';
      box.appendChild(frame);
      btn.remove();
    });
  });
})();
