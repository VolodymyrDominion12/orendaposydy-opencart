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
  function maxOf(form) {
    var m = parseInt(form.getAttribute('data-k-max'), 10);
    return m > 0 ? m : 0;
  }

  // Кількість у межах [мінімум, залишок]: виправляємо й пояснюємо
  function clamp(form) {
    var input = form.querySelector('input[name="quantity"]'), hint = form.querySelector('.k-card__hint, .k-buy__hint');
    var min = minOf(form), max = maxOf(form), val = parseInt(input.value, 10);
    if (!(val >= min)) {
      input.value = min;
      if (hint) hint.textContent = form.getAttribute('data-k-hint') || '';
    } else if (max > 0 && val > max) {
      input.value = max;
      if (hint) hint.textContent = form.getAttribute('data-k-max-hint') || '';
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

  function applyStep(step, mult) {
    var form = step.closest('form');
    if (!form) return;
    var input = form.querySelector('input[name="quantity"]');
    if (!input) return;
    var min = minOf(form), max = maxOf(form);
    var delta = (parseInt(step.getAttribute('data-k-step'), 10) || 0) * (mult || 1);
    var val = (parseInt(input.value, 10) || min) + delta;
    var hint = form.querySelector('.k-card__hint, .k-buy__hint');
    if (val < min) {
      input.value = min;
      if (hint && delta < 0) hint.textContent = form.getAttribute('data-k-hint') || '';
    } else if (max > 0 && val > max) {
      input.value = max;
      if (hint && delta > 0) hint.textContent = form.getAttribute('data-k-max-hint') || '';
    } else {
      input.value = val;
      if (hint) hint.textContent = '';
    }
    updateSum(form);
  }

  var holdDelay = null, holdTick = null, holdBtn = null, holdStart = 0, holdRepeated = false;
  function stopHold() {
    clearTimeout(holdDelay);
    clearInterval(holdTick);
    holdDelay = null;
    holdTick = null;
    holdBtn = null;
  }

  doc.addEventListener('pointerdown', function (e) {
    var step = e.target.closest ? e.target.closest('[data-k-step]') : null;
    if (!step || (e.button && e.button !== 0)) return;
    stopHold();
    holdBtn = step;
    holdStart = Date.now();
    holdRepeated = false;
    holdDelay = setTimeout(function () {
      holdTick = setInterval(function () {
        if (!holdBtn || !doc.body.contains(holdBtn)) { stopHold(); return; }
        holdRepeated = true;
        var elapsed = Date.now() - holdStart;
        var mult = elapsed >= 4000 ? 25 : elapsed >= 2500 ? 10 : elapsed >= 1200 ? 5 : 1;
        applyStep(holdBtn, mult);
      }, 90);
    }, 380);
  });
  doc.addEventListener('pointerout', function (e) {
    if (holdBtn && (!e.relatedTarget || !holdBtn.contains(e.relatedTarget))) stopHold();
  });
  doc.addEventListener('pointerup', stopHold, true);
  doc.addEventListener('pointercancel', stopHold, true);
  window.addEventListener('blur', stopHold);

  doc.addEventListener('click', function (e) {
    var step = e.target.closest('[data-k-step]');
    if (step) {
      if (holdRepeated) { holdRepeated = false; return; }
      applyStep(step, 1);
      return;
    }
    var tier = e.target.closest('[data-k-tiers] [data-k-from]');
    if (tier) pickTier(tier);
  });

  function pickTier(cell) {
    var form = doc.querySelector('[data-k-buy]');
    if (!form) return;
    var input = form.querySelector('input[name="quantity"]');
    if (!input) return;
    var from = Math.max(minOf(form), parseInt(cell.getAttribute('data-k-from'), 10) || minOf(form));
    var max = maxOf(form);
    if (max > 0 && from > max) from = max;
    input.value = from;
    var hint = form.querySelector('.k-card__hint, .k-buy__hint');
    if (hint) hint.textContent = '';
    clamp(form);
    updateSum(form);
  }

  doc.addEventListener('keydown', function (e) {
    if (e.key !== 'Enter' && e.key !== ' ') return;
    var tier = e.target.closest ? e.target.closest('[data-k-tiers] [data-k-from]') : null;
    if (!tier) return;
    e.preventDefault();
    pickTier(tier);
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

/* ---------- Барабанний вибір кількості («як на будильнику») ----------
   Відкривається при натисканні на число всередині будь-якого .k-qty (картка товару, каталог, кошик).
   3 незалежні барабани (Сотні · Десятки · Одиниці) + швидкі чіпи + прямий ввід числа. */
(function () {
  'use strict';

  var doc = document, root = doc.documentElement;
  var ITEM_H = 44;
  var FOCUSABLE = 'button:not([disabled]), input:not([disabled]), [tabindex]:not([tabindex="-1"])';

  var modal = null, panel = null, titleEl = null, numInput = null, unitEl = null, boundsEl = null;
  var sumEl = null, presetsEl = null, confirmBtn = null, closeBtn = null;
  var drums = { h: null, t: null, o: null };
  var opts = { h: [], t: [], o: [] };

  var state = {
    input: null, opener: null, min: 1, max: 0, unit: 'шт',
    prices: null, isEvent: false, maxHundreds: 2000,
    settleTimer: null, programmaticUntil: 0, lastPointerDown: 0
  };

  function fmtMoney(n) {
    var r = Math.round(n * 100) / 100, whole = Math.abs(r - Math.round(r)) < 0.005;
    var s = whole ? String(Math.round(r)) : r.toFixed(2).replace('.', ',');
    return s.replace(/\B(?=(\d{3})+(?!\d))/g, '\u00a0') + '\u00a0₴';
  }

  function clampVal(v) {
    var n = isNaN(v) ? state.min : v;
    if (n < state.min) n = state.min;
    if (state.max > 0 && n > state.max) n = state.max;
    return n;
  }

  function pad2(n) { return n === 0 ? '00' : String(n); }

  function buildModal() {
    if (modal) return;
    modal = doc.createElement('div');
    modal.className = 'k-qpick';
    modal.hidden = true;
    modal.setAttribute('role', 'dialog');
    modal.setAttribute('aria-modal', 'true');
    modal.setAttribute('aria-labelledby', 'k-qpick-title');

    modal.innerHTML =
      '<div class="k-qpick__panel" tabindex="-1">' +
        '<div class="k-qpick__head">' +
          '<h3 class="k-qpick__title" id="k-qpick-title">Кількість</h3>' +
          '<button type="button" class="k-qpick__close" aria-label="Закрити">' +
            '<svg class="k-ico" width="24" height="24" viewBox="0 0 24 24" aria-hidden="true"><path d="M18 6L6 18M6 6l12 12"/></svg>' +
          '</button>' +
        '</div>' +
        '<div class="k-qpick__top">' +
          '<label class="k-qpick__edit">' +
            '<input type="number" class="k-qpick__num" inputmode="numeric" aria-label="Введіть кількість">' +
            '<span class="k-qpick__unit">шт</span>' +
          '</label>' +
          '<span class="k-qpick__bounds"></span>' +
        '</div>' +
        '<div class="k-qpick__sum" hidden></div>' +
        '<div class="k-qpick__presets" role="group" aria-label="Швидкий вибір"></div>' +
        '<div class="k-qpick__labels" aria-hidden="true"><span>Сотні</span><span>Десятки</span><span>Одиниці</span></div>' +
        '<div class="k-qpick__stage">' +
          '<div class="k-qpick__band" aria-hidden="true"></div>' +
          '<div class="k-qpick__drum" data-drum="h" aria-label="Сотні"></div>' +
          '<div class="k-qpick__drum" data-drum="t" aria-label="Десятки"></div>' +
          '<div class="k-qpick__drum" data-drum="o" aria-label="Одиниці"></div>' +
          '<div class="k-qpick__fade" aria-hidden="true"></div>' +
        '</div>' +
        '<button type="button" class="k-btn k-btn--primary k-btn--block" data-qpick-ok>Обрати</button>' +
      '</div>';

    doc.body.appendChild(modal);
    panel = modal.querySelector('.k-qpick__panel');
    titleEl = modal.querySelector('.k-qpick__title');
    numInput = modal.querySelector('.k-qpick__num');
    unitEl = modal.querySelector('.k-qpick__unit');
    boundsEl = modal.querySelector('.k-qpick__bounds');
    sumEl = modal.querySelector('.k-qpick__sum');
    presetsEl = modal.querySelector('.k-qpick__presets');
    confirmBtn = modal.querySelector('[data-qpick-ok]');
    closeBtn = modal.querySelector('.k-qpick__close');
    drums.h = modal.querySelector('[data-drum="h"]');
    drums.t = modal.querySelector('[data-drum="t"]');
    drums.o = modal.querySelector('[data-drum="o"]');

    closeBtn.addEventListener('click', function () { close(true); });
    modal.addEventListener('click', function (e) { if (e.target === modal) close(true); });
    confirmBtn.addEventListener('click', confirm);

    presetsEl.addEventListener('click', function (e) {
      var chip = e.target.closest('.k-qpick__chip');
      if (!chip) return;
      var v = clampVal(parseInt(chip.getAttribute('data-val'), 10));
      numInput.value = v;
      updateMeta(v, false);
      rollToValue(v, true);
    });

    numInput.addEventListener('input', function () {
      var raw = parseInt(numInput.value, 10);
      if (isNaN(raw) || raw < 0) { updateMeta(state.min, false); return; }
      if (state.max === 0 && raw > state.maxHundreds + 99 && raw <= 10000) {
        state.maxHundreds = Math.min(10000, Math.ceil(raw / 100) * 100);
        populateDrum('h', makeHundreds(state.maxHundreds));
      }
      var c = clampVal(raw);
      updateMeta(raw, raw !== c);
      rollToValue(Math.min(raw, state.maxHundreds + 99), false);
    });
    numInput.addEventListener('blur', function () {
      var c = clampVal(parseInt(numInput.value, 10));
      numInput.value = c;
      updateMeta(c, false);
      rollToValue(c, true);
    });
    numInput.addEventListener('keydown', function (e) {
      if (e.key === 'Enter') { e.preventDefault(); confirm(); }
    });

    modal.addEventListener('keydown', function (e) {
      if (e.key === 'Escape') { e.preventDefault(); close(true); return; }
      if (e.key !== 'Tab') return;
      var items = Array.prototype.filter.call(modal.querySelectorAll(FOCUSABLE), function (el) { return el.offsetParent !== null; });
      if (!items.length) return;
      var first = items[0], last = items[items.length - 1];
      if (e.shiftKey && doc.activeElement === first) { e.preventDefault(); last.focus(); }
      else if (!e.shiftKey && doc.activeElement === last) { e.preventDefault(); first.focus(); }
    });

    setupDrumEvents('h');
    setupDrumEvents('t');
    setupDrumEvents('o');
  }

  function makeHundreds(limit) {
    var arr = [];
    for (var i = 0; i <= limit; i += 100) arr.push({ v: i, label: String(i) });
    return arr;
  }

  function populateDrum(key, list) {
    var el = drums[key];
    var html = '<div class="k-qpick__pad" aria-hidden="true"></div>';
    for (var i = 0; i < list.length; i++) {
      html += '<button type="button" class="k-qpick__opt" data-idx="' + i + '" data-val="' + list[i].v + '">' + list[i].label + '</button>';
    }
    html += '<div class="k-qpick__pad" aria-hidden="true"></div>';
    el.innerHTML = html;
    opts[key] = Array.prototype.slice.call(el.querySelectorAll('.k-qpick__opt'));
  }

  function drumIdx(key) {
    var list = opts[key];
    if (!list.length) return 0;
    var idx = Math.round(drums[key].scrollTop / ITEM_H);
    return Math.max(0, Math.min(list.length - 1, idx));
  }

  function drumVal(key) {
    var list = opts[key];
    if (!list.length) return 0;
    return parseInt(list[drumIdx(key)].getAttribute('data-val'), 10) || 0;
  }

  function highlightDrum(key) {
    var idx = drumIdx(key), list = opts[key];
    for (var i = 0; i < list.length; i++) {
      list[i].classList.toggle('is-on', i === idx);
    }
  }

  var drag = null, suppressClickUntil = 0;
  function setupDrumEvents(key) {
    var el = drums[key];
    el.addEventListener('scroll', function () {
      highlightDrum(key);
      if (Date.now() < state.programmaticUntil) return;
      var raw = drumVal('h') + drumVal('t') + drumVal('o');
      var clamped = clampVal(raw);
      if (doc.activeElement !== numInput) numInput.value = raw;
      updateMeta(raw, raw !== clamped);
      clearTimeout(state.settleTimer);
      state.settleTimer = setTimeout(function () {
        if (modal.hidden || drag) return;
        var settled = drumVal('h') + drumVal('t') + drumVal('o');
        var target = clampVal(settled);
        if (settled !== target) {
          numInput.value = target;
          updateMeta(target, false);
          rollToValue(target, true);
        }
      }, 150);
    }, { passive: true });

    el.addEventListener('touchstart', function () { state.programmaticUntil = 0; }, { passive: true });
    el.addEventListener('wheel', function () { state.programmaticUntil = 0; }, { passive: true });

    el.addEventListener('pointerdown', function (e) {
      if (e.pointerType !== 'mouse' || e.button !== 0) return;
      state.programmaticUntil = 0;
      drag = { el: el, startY: e.clientY, startTop: el.scrollTop, moved: false };
    });

    el.addEventListener('click', function (e) {
      if (Date.now() < suppressClickUntil) return;
      var opt = e.target.closest('.k-qpick__opt');
      if (!opt) return;
      state.programmaticUntil = 0;
      var idx = parseInt(opt.getAttribute('data-idx'), 10) || 0;
      el.scrollTo({ top: idx * ITEM_H, behavior: 'smooth' });
    });
  }

  doc.addEventListener('pointermove', function (e) {
    if (!drag) return;
    var dy = e.clientY - drag.startY;
    if (!drag.moved && Math.abs(dy) > 5) {
      drag.moved = true;
      drag.el.style.scrollSnapType = 'none';
    }
    if (drag.moved) drag.el.scrollTop = drag.startTop - dy;
  });

  function endDrag() {
    if (!drag) return;
    if (drag.moved) {
      var el = drag.el;
      el.style.scrollSnapType = '';
      var top = Math.round(el.scrollTop / ITEM_H) * ITEM_H;
      el.scrollTo({ top: top, behavior: 'smooth' });
      suppressClickUntil = Date.now() + 140;
    }
    drag = null;
  }
  doc.addEventListener('pointerup', endDrag);
  doc.addEventListener('pointercancel', endDrag);

  function scrollDrumToVal(key, val, smooth) {
    var list = opts[key], idx = 0;
    for (var i = 0; i < list.length; i++) {
      if (parseInt(list[i].getAttribute('data-val'), 10) === val) { idx = i; break; }
    }
    var top = idx * ITEM_H;
    drums[key].scrollTo({ top: top, behavior: smooth ? 'smooth' : 'auto' });
    highlightDrum(key);
  }

  function rollToValue(v, smooth) {
    var safe = Math.max(0, Math.min(state.maxHundreds + 99, v));
    var h = Math.min(state.maxHundreds, Math.floor(safe / 100) * 100);
    var rem = safe - h;
    var t = Math.min(90, Math.floor(rem / 10) * 10);
    var o = Math.min(9, rem - t);
    state.programmaticUntil = Date.now() + (smooth ? 420 : 80);
    scrollDrumToVal('h', h, smooth);
    scrollDrumToVal('t', t, smooth);
    scrollDrumToVal('o', o, smooth);
  }

  function updateMeta(rawVal, warn) {
    var qty = clampVal(rawVal);
    var boundsText = 'мін. ' + state.min + ' ' + state.unit;
    if (state.max > 0) boundsText += ' · макс. ' + state.max + ' ' + state.unit;
    boundsEl.textContent = boundsText;
    boundsEl.classList.toggle('is-warn', Boolean(warn));
    confirmBtn.textContent = 'Обрати ' + qty + ' ' + state.unit;

    if (state.prices && state.prices.length) {
      var price = state.prices[0][1];
      for (var i = 0; i < state.prices.length; i++) {
        if (qty >= state.prices[i][0]) price = state.prices[i][1];
      }
      sumEl.hidden = false;
      sumEl.innerHTML = state.isEvent
        ? qty + ' × ' + fmtMoney(price) + ' = <b>' + fmtMoney(qty * price) + '</b>'
        : qty + ' ' + state.unit + ' × ' + fmtMoney(price) + ' = <b>' + fmtMoney(qty * price) + '</b> / доба';
    } else {
      sumEl.hidden = true;
    }

    var chips = presetsEl.querySelectorAll('.k-qpick__chip');
    for (var j = 0; j < chips.length; j++) {
      chips[j].classList.toggle('is-on', parseInt(chips[j].getAttribute('data-val'), 10) === qty);
    }
  }

  function buildPresets() {
    var set = [state.min];
    if (state.prices) {
      for (var i = 0; i < state.prices.length; i++) set.push(state.prices[i][0]);
    }
    [25, 50, 100, 150, 200, 300, 500].forEach(function (v) { set.push(v); });
    if (state.max > 0) set.push(state.max);

    var filtered = [];
    for (var k = 0; k < set.length; k++) {
      var n = parseInt(set[k], 10);
      if (!(n >= state.min)) continue;
      if (state.max > 0 && n > state.max) continue;
      if (filtered.indexOf(n) === -1) filtered.push(n);
    }
    filtered.sort(function (a, b) { return a - b; });
    filtered = filtered.slice(0, 7);

    var html = '';
    for (var m = 0; m < filtered.length; m++) {
      var val = filtered[m];
      var lbl = (val === state.min && state.min > 1) ? 'мін. ' + val : String(val);
      html += '<button type="button" class="k-qpick__chip" data-val="' + val + '">' + lbl + '</button>';
    }
    presetsEl.innerHTML = html;
    presetsEl.hidden = filtered.length < 2;
  }

  function resolveTitle(input) {
    var buy = input.closest('.k-buy');
    if (buy) {
      var h1 = buy.querySelector('.k-h1');
      if (h1) return h1.textContent.trim();
    }
    var card = input.closest('.k-card');
    if (card) {
      var cn = card.querySelector('.k-card__name');
      if (cn) return cn.textContent.trim();
    }
    var line = input.closest('.k-line');
    if (line) {
      var ln = line.querySelector('.k-line__name');
      if (ln) return ln.textContent.trim();
    }
    return 'Кількість';
  }

  function open(input, byKey) {
    buildModal();
    clearTimeout(state.settleTimer);
    state.lastPointerDown = 0;
    state.input = input;
    state.opener = byKey ? input : null;

    var form = input.closest('form[data-k-add]');
    var box = input.closest('.k-qty');
    state.min = Math.max(1, parseInt(input.getAttribute('min') || (form && form.getAttribute('data-k-min')) || (box && box.getAttribute('data-min')), 10) || 1);
    state.max = parseInt(input.getAttribute('max') || (form && form.getAttribute('data-k-max')) || (box && box.getAttribute('data-max')), 10) || 0;
    state.unit = (form && form.getAttribute('data-k-unit')) || 'шт';
    state.isEvent = Boolean(form && form.getAttribute('data-k-event') === '1');
    state.prices = null;
    if (form && form.hasAttribute('data-k-buy')) {
      try {
        var parsed = JSON.parse(form.getAttribute('data-k-prices') || '[]');
        if (parsed && parsed.length) state.prices = parsed;
      } catch (err) { state.prices = null; }
    }

    var cur = clampVal(parseInt(input.value, 10) || state.min);
    state.maxHundreds = state.max > 0
      ? Math.floor(state.max / 100) * 100
      : Math.max(2000, Math.min(10000, Math.ceil((cur + 200) / 100) * 100));

    populateDrum('h', makeHundreds(state.maxHundreds));
    var tens = [];
    for (var t = 0; t <= (state.max > 0 && state.max < 10 ? 0 : 90); t += 10) tens.push({ v: t, label: pad2(t) });
    populateDrum('t', tens);
    var ones = [];
    for (var o = 0; o <= (state.max > 0 && state.max < 10 ? state.max : 9); o++) ones.push({ v: o, label: String(o) });
    populateDrum('o', ones);

    titleEl.textContent = resolveTitle(input);
    unitEl.textContent = state.unit;
    numInput.min = state.min;
    if (state.max > 0) numInput.max = state.max; else numInput.removeAttribute('max');
    numInput.value = cur;

    buildPresets();
    updateMeta(cur, false);

    modal.hidden = false;
    root.classList.add('k-lock');
    rollToValue(cur, false);
    if (panel.focus) panel.focus({ preventScroll: true });
  }

  function close(restore) {
    if (!modal || modal.hidden) return;
    clearTimeout(state.settleTimer);
    modal.hidden = true;
    root.classList.remove('k-lock');
    if (restore && state.opener && state.opener.focus) state.opener.focus();
    state.input = null;
    state.opener = null;
  }

  function confirm() {
    if (!state.input) { close(false); return; }
    var raw = parseInt(numInput.value, 10);
    if (isNaN(raw)) raw = drumVal('h') + drumVal('t') + drumVal('o');
    var finalVal = clampVal(raw);
    var target = state.input;
    close(true);
    target.value = finalVal;
    target.dispatchEvent(new Event('input', { bubbles: true }));
    target.dispatchEvent(new Event('change', { bubbles: true }));
  }

  doc.addEventListener('pointerdown', function (e) {
    if (e.target && e.target.closest && e.target.closest('.k-qty input')) {
      state.lastPointerDown = Date.now();
    }
  }, true);

  doc.addEventListener('focusin', function (e) {
    var inp = e.target && e.target.closest ? e.target.closest('.k-qty input') : null;
    if (inp && Date.now() - state.lastPointerDown < 500) {
      inp.blur();
    }
  }, true);

  doc.addEventListener('click', function (e) {
    var inp = e.target && e.target.closest ? e.target.closest('.k-qty input') : null;
    if (!inp || inp.disabled || inp.readOnly) return;
    e.preventDefault();
    open(inp, e.detail === 0);
  });
})();

