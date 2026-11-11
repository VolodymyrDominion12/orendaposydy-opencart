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

/* ---------- 005: каталог і картка товару ----------
   «−/+» з мінімумом, AJAX «До події» (checkout/cart/add ядра) і лічильники, «Показати ще», сортування,
   сума за порогами (та сама логіка, що Kristal\Rental::unitPrice і кошик ядра), галерея, липка панель. */
(function () {
  'use strict';

  var doc = document;

  function fmt(n) {
    var r = Math.round(n * 100) / 100, whole = Math.abs(r - Math.round(r)) < 0.005;
    var s = whole ? String(Math.round(r)) : r.toFixed(2).replace('.', ',');
    return s.replace(/\B(?=(\d{3})+(?!\d))/g, ' ') + ' ₴';
  }

  function minOf(form) { return Math.max(1, parseInt(form.getAttribute('data-k-min'), 10) || 1); }

  // Кількість не менша за мінімум: виправляємо й пояснюємо
  function clamp(form) {
    var input = form.querySelector('input[name="quantity"]'), hint = form.querySelector('.k-card__hint, .k-buy__hint');
    var min = minOf(form), val = parseInt(input.value, 10);
    if (!(val >= min)) {
      input.value = min;
      if (hint) hint.textContent = form.getAttribute('data-k-hint') || '';
    }
    return parseInt(input.value, 10);
  }

  // ---------- Сума й активний поріг (картка товару) ----------
  function updateSum(form) {
    if (!form.hasAttribute('data-k-buy')) return;
    var prices, qty = parseInt(form.querySelector('input[name="quantity"]').value, 10) || minOf(form);
    try { prices = JSON.parse(form.getAttribute('data-k-prices') || '[]'); } catch (e) { prices = []; }
    if (!prices.length) return;
    var price = prices[0][1], from = prices[0][0];
    prices.forEach(function (t) { if (qty >= t[0]) { price = t[1]; from = t[0]; } });
    var sum = doc.querySelector('[data-k-sum]');
    if (sum) {
      sum.innerHTML = form.getAttribute('data-k-event') === '1'
        ? qty + ' × ' + fmt(price) + ' = <b>' + fmt(qty * price) + '</b>'
        : qty + ' ' + form.getAttribute('data-k-unit') + ' × ' + fmt(price) + ' = <b>' + fmt(qty * price) + '</b> / доба';
    }
    doc.querySelectorAll('[data-k-tiers] [data-k-from]').forEach(function (cell) {
      cell.classList.toggle('is-on', parseInt(cell.getAttribute('data-k-from'), 10) === from);
    });
  }

  doc.addEventListener('click', function (e) {
    var step = e.target.closest('[data-k-step]');
    if (!step) return;
    var form = step.closest('form'), input = form.querySelector('input[name="quantity"]');
    var min = minOf(form), val = (parseInt(input.value, 10) || min) + parseInt(step.getAttribute('data-k-step'), 10);
    input.value = Math.max(min, val);
    clamp(form);
    updateSum(form);
  });

  doc.addEventListener('input', function (e) {
    if (e.target.name === 'quantity') {
      var form = e.target.closest('form'), hint = form ? form.querySelector('.k-card__hint, .k-buy__hint') : null;
      if (hint) hint.textContent = '';
      if (form) updateSum(form);
    }
  });

  doc.addEventListener('change', function (e) {
    if (e.target.name === 'quantity') {
      var form = e.target.closest('form');
      if (form) { clamp(form); updateSum(form); }
    }
    if (e.target.matches && e.target.matches('[data-k-sort]')) location.href = e.target.value;
  });

  // ---------- «До події» ----------
  var toast = doc.querySelector('[data-k-toast]'), toastTimer = null;

  function say(ok) {
    if (!toast) return;
    toast.querySelector('[data-k-toast-text]').textContent = toast.getAttribute(ok ? 'data-k-ok' : 'data-k-err');
    toast.classList.toggle('is-err', !ok);
    toast.hidden = false;
    clearTimeout(toastTimer);
    toastTimer = setTimeout(function () { toast.hidden = true; }, 5000);
  }

  function setCount(n) {
    var head = doc.querySelector('.k-header__cart'), tab = doc.querySelector('.k-tabbar a:last-child');
    if (head) {
      var m = head.querySelector('.k-mono');
      if (!m) { m = doc.createElement('span'); m.className = 'k-mono'; head.appendChild(doc.createTextNode(' ')); head.appendChild(m); }
      m.textContent = '(' + n + ')';
    }
    if (tab) {
      var c = tab.querySelector('.k-count');
      if (!c) { c = doc.createElement('span'); c.className = 'k-count'; tab.appendChild(c); }
      c.textContent = n;
    }
  }

  function add(form) {
    var qty = clamp(form);
    var body = new URLSearchParams();
    body.append('product_id', form.querySelector('input[name="product_id"]').value);
    body.append('quantity', qty);
    var btn = form.querySelector('[type="submit"]');
    if (btn) btn.disabled = true;

    fetch('/?route=checkout/cart/add', {
      method: 'POST', credentials: 'same-origin',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded', 'X-Requested-With': 'XMLHttpRequest' },
      body: body.toString()
    }).then(function (r) { return r.json(); }).then(function (json) {
      if (!json || !json.success) throw new Error('cart');
      say(true);
      return fetch('/?route=extension/kristal/catalog/count', { credentials: 'same-origin' })
        .then(function (r) { return r.json(); }).then(function (c) { setCount(c.count); });
    }).catch(function () { say(false); }).then(function () { if (btn) btn.disabled = false; });
  }

  doc.addEventListener('submit', function (e) {
    var form = e.target.closest('[data-k-add]');
    if (!form || !window.fetch) return;
    e.preventDefault();
    add(form);
  });

  // ---------- Сортування без кнопки ----------
  // (обробник change вище; без JS — посилання в <noscript>)

  // ---------- «Показати ще» ----------
  // Елементи шукаються під час кліку: фільтри (021) замінюють блок результатів без перезавантаження і кидають подію k:results
  function nextHref(root) {
    var active = root ? root.querySelector('li.active') : null, next = active ? active.nextElementSibling : null;
    var a = next ? next.querySelector('a') : null;
    return a ? a.href : '';
  }

  function initMore() {
    var more = doc.querySelector('[data-k-more]'), pager = doc.querySelector('[data-k-pager]');
    if (!more || !pager || !doc.querySelector('[data-k-grid]')) return;
    var href = nextHref(pager);
    if (href) { more.href = href; more.hidden = false; }
  }

  if (window.fetch && window.DOMParser) {
    initMore();
    doc.addEventListener('k:results', initMore);

    doc.addEventListener('click', function (e) {
      var more = e.target.closest ? e.target.closest('[data-k-more]') : null;
      var grid = doc.querySelector('[data-k-grid]'), pager = doc.querySelector('[data-k-pager]');
      if (!more || !grid || !pager) return;
      e.preventDefault();
      var url = more.href;
      more.setAttribute('aria-busy', 'true');
      fetch(url, { credentials: 'same-origin' }).then(function (r) { return r.text(); }).then(function (html) {
        var page = new DOMParser().parseFromString(html, 'text/html');
        var cards = page.querySelectorAll('[data-k-grid] > .k-card');
        var first = null;
        cards.forEach(function (card) {
          var node = doc.importNode(card, true);
          node.querySelectorAll('img').forEach(function (img) { img.setAttribute('loading', 'lazy'); });
          grid.appendChild(node);
          if (!first) first = node;
        });
        var newPager = page.querySelector('[data-k-pager]');
        if (newPager) pager.innerHTML = newPager.innerHTML;
        var next = nextHref(pager);
        if (next) { more.href = next; } else { more.hidden = true; }
        if (history.replaceState) history.replaceState(null, '', url);
        if (first) { var link = first.querySelector('.k-card__name a'); if (link) link.focus({ preventScroll: true }); }
      }).catch(function () { location.href = url; }).then(function () { more.removeAttribute('aria-busy'); });
    });
  }

  // ---------- Галерея ----------
  var gallery = doc.querySelector('[data-k-gallery]');
  if (gallery) {
    var main = gallery.querySelector('.k-gallery__main'), thumbs = gallery.querySelectorAll('[data-k-thumb]');
    var mark = function (i) { thumbs.forEach(function (t, n) { if (n === i) t.setAttribute('aria-current', 'true'); else t.removeAttribute('aria-current'); }); };
    thumbs.forEach(function (t) {
      t.addEventListener('click', function () {
        var i = parseInt(t.getAttribute('data-k-thumb'), 10);
        main.scrollTo({ left: main.clientWidth * i, behavior: 'smooth' });
        mark(i);
      });
    });
    main.addEventListener('scroll', function () { mark(Math.round(main.scrollLeft / Math.max(1, main.clientWidth))); }, { passive: true });
    main.addEventListener('keydown', function (e) {
      if (e.key !== 'ArrowRight' && e.key !== 'ArrowLeft') return;
      e.preventDefault();
      main.scrollBy({ left: (e.key === 'ArrowRight' ? 1 : -1) * main.clientWidth, behavior: 'smooth' });
    });
  }

  // ---------- Липка панель картки (мобільний) ----------
  var sticky = doc.querySelector('[data-k-sticky]'), mainAdd = doc.querySelector('[data-k-main-add]');
  if (sticky && mainAdd && 'IntersectionObserver' in window) {
    doc.body.classList.add('has-sticky');
    new IntersectionObserver(function (entries) {
      var below = !entries[0].isIntersecting && entries[0].boundingClientRect.top < 0;
      sticky.classList.toggle('is-on', below);
      sticky.setAttribute('aria-hidden', below ? 'false' : 'true');
      sticky.querySelector('button').tabIndex = below ? 0 : -1;
    }).observe(mainAdd);
    sticky.querySelector('[data-k-sticky-add]').addEventListener('click', function () {
      var form = mainAdd.closest('form');
      if (form && window.fetch) add(form); else if (form) form.submit();
    });
  }

  var buy = doc.querySelector('[data-k-buy]');
  if (buy) updateSum(buy);
})();

/* ---------- 027: панель пошуку ----------
   Лупа відкриває панель під шапкою й ставить фокус у поле; Esc / «×» / тап поза панеллю — закриває.
   Підказки (kristal-search.js) підключаються лише при першому відкритті чи фокусі поля — до того сторінка їх не вантажить.
   Без JS лупа — звичайне посилання на сторінку пошуку. */
(function () {
  'use strict';

  var doc = document, panel = doc.querySelector('[data-k-search]');
  if (!panel) return;

  var form = panel.querySelector('[data-k-search-form]'), input = form.querySelector('input[name="q"]');
  var openers = doc.querySelectorAll('[data-k-search-open]'), opener = null, loaded = false;

  function load() {
    if (loaded || !window.fetch) return;
    loaded = true;
    var s = doc.createElement('script');
    s.src = form.getAttribute('data-js');
    s.async = true;
    doc.head.appendChild(s);
  }

  function setExpanded(state) {
    openers.forEach(function (b) { b.setAttribute('aria-expanded', state ? 'true' : 'false'); });
  }

  function open(trigger) {
    opener = trigger || null;
    panel.hidden = false;
    setExpanded(true);
    load();
    input.focus();
    var v = input.value; input.value = ''; input.value = v; // курсор у кінець
  }

  function close(restore) {
    if (panel.hidden) return;
    panel.hidden = true;
    setExpanded(false);
    doc.dispatchEvent(new CustomEvent('k-search-close'));
    if (restore && opener && opener.focus) opener.focus();
  }

  openers.forEach(function (b) {
    b.addEventListener('click', function (e) {
      e.preventDefault();
      if (panel.hidden) open(b); else close(true);
    });
  });

  panel.querySelector('[data-k-search-close]').addEventListener('click', function () { close(true); });
  input.addEventListener('focus', load);

  doc.addEventListener('keydown', function (e) {
    if (e.key === 'Escape' && !panel.hidden) close(true);
  });

  doc.addEventListener('click', function (e) {
    if (!panel.hidden && !panel.contains(e.target) && !e.target.closest('[data-k-search-open]')) close(false);
  });
})();
