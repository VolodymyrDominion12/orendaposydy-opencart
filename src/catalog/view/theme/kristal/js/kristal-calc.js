/**
 * Скрипт калькулятора події («Крістал: калькулятор», 008).
 * Vanilla JavaScript (ES6+), без сторонніх залежностей.
 */
(function () {
  'use strict';

  var calc = document.querySelector('[data-calc]');
  if (!calc) return;

  var form = calc.querySelector('form');
  var rows = calc.querySelector('[data-rows]');
  var outGuests = calc.querySelector('[data-out]');
  var totalEl = calc.querySelector('[data-total]');
  var ppEl = calc.querySelector('[data-pp]');
  var addAllBtn = calc.querySelector('[data-add-all]');
  var sendLeadBtn = calc.querySelector('[data-send-lead]');
  var toastEl = calc.querySelector('[data-calc-toast]');

  var addUrl = calc.dataset.addUrl || 'index.php?route=extension/kristal/calculator/add';
  var cartUrl = calc.dataset.cartUrl || 'index.php?route=checkout/order';

  // Посилання на поля лід-форми
  var leadGuestsInput = document.querySelector('[data-lead-guests]');
  var leadNoteInput = document.querySelector('[data-calc-note]');

  // Завантаження клієнтських норм з JSON
  var rawDataEl = document.getElementById('k-calc-data');
  var norms = [];
  if (rawDataEl) {
    try {
      norms = JSON.parse(rawDataEl.textContent) || [];
    } catch (e) {
      norms = [];
    }
  }

  var groupTitles = {
    plates: 'Посуд',
    cutlery: 'Столові прибори',
    glass: 'Скло та келихи'
  };

  function formatMoney(num) {
    var rounded = Math.round(num);
    return rounded.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ' ') + ' ₴';
  }

  function showToast(message, isSuccess) {
    if (!toastEl) return;
    toastEl.style.display = 'block';
    toastEl.innerHTML = '<div class="k-calc__toast" style="color:' + (isSuccess ? 'var(--gold-text)' : 'var(--red, #e53e3e)') + '">' +
      (isSuccess ? '✓ ' : '⚠ ') + message + '</div>';
    setTimeout(function () {
      toastEl.style.display = 'none';
    }, 4000);
  }

  function updateCartCounters(count) {
    if (typeof count === 'undefined') return;
    document.querySelectorAll('.k-header__cart .k-mono').forEach(function (el) {
      el.textContent = '(' + count + ')';
    });
    document.querySelectorAll('.k-tabbar .k-count').forEach(function (el) {
      el.textContent = count;
    });
  }

  function recalculate() {
    form.querySelectorAll('.k-seg label').forEach(function (lbl) {
      var inp = lbl.querySelector('input');
      if (inp) {
        if (inp.checked) lbl.classList.add('is-checked');
        else lbl.classList.remove('is-checked');
      }
    });

    var guestsInput = form.querySelector('[data-guests]');
    var guests = parseInt(guestsInput ? guestsInput.value : 100, 10) || 100;
    if (guests < 10) guests = 10;
    if (guests > 300) guests = 300;

    if (outGuests) {
      outGuests.textContent = guests;
    }

    var fmt = form.elements['fmt'] ? form.elements['fmt'].value : 'banquet';
    var dishes = form.elements['dishes'] ? parseInt(form.elements['dishes'].value, 10) : 3;
    var wine = form.elements['wine'] ? form.elements['wine'].checked : false;
    var champ = form.elements['champ'] ? form.elements['champ'].checked : false;
    var strong = form.elements['strong'] ? form.elements['strong'].checked : false;
    var series = form.elements['series'] ? parseInt(form.elements['series'].value, 10) : 1;

    var total = 0;
    var groupedHtml = {
      plates: '',
      cutlery: '',
      glass: ''
    };

    norms.forEach(function (norm) {
      // Фільтр напоїв
      if (norm.drink_filter === 'wine' && !wine) return;
      if (norm.drink_filter === 'champ' && !champ) return;
      if (norm.drink_filter === 'strong' && !strong) return;

      // Норма на гостя
      var per = 0.0;
      if (fmt === 'banquet') {
        per = norm.norm_banquet;
      } else if (fmt === 'buffet') {
        per = norm.norm_buffet;
      } else if (fmt === 'coffee') {
        per = norm.norm_coffee;
      }

      if (per <= 0) return;

      // Правила для страв
      if (norm.dish_rule === 'extra_if_4_dishes' && dishes >= 4) {
        per += 1.0;
      } else if (norm.dish_rule === 'skip_if_2_dishes_non_banquet' && dishes <= 2 && fmt !== 'banquet') {
        return;
      }

      var packSize = norm.pack_size || 10;
      var raw = guests * per * 1.1;
      var qty = Math.ceil(raw / packSize) * packSize;
      if (qty <= 0) return;

      var productId = 0;
      var name = norm.name;
      var price = 0;
      var min = 0;

      if (series === 2 && norm.product_id_royal > 0) {
        productId = norm.product_id_royal;
        name = norm.name_royal || norm.name;
        price = norm.price_royal;
        min = norm.min_royal || 0;
      } else {
        productId = norm.product_id_classic;
        name = norm.name_classic || norm.name;
        price = norm.price_classic;
        min = norm.min_classic || 0;
      }

      if (min > 0 && qty < min) {
        qty = min;
      }

      var lineTotal = qty * price;
      total += lineTotal;

      var linkHtml = productId > 0
        ? '<a href="index.php?route=product/product&product_id=' + productId + '">' + norm.name + '</a>'
        : norm.name;

      var rowHtml = '<tr>' +
        '<td>' + linkHtml + '</td>' +
        '<td class="n">' + qty + '</td>' +
        '<td class="n hide-m">' + formatMoney(price) + '</td>' +
        '<td class="n">' + formatMoney(lineTotal) + '</td>' +
        '</tr>';

      if (groupedHtml[norm.category] !== undefined) {
        groupedHtml[norm.category] += rowHtml;
      }
    });

    var fullHtml = '';
    ['plates', 'cutlery', 'glass'].forEach(function (cat) {
      if (groupedHtml[cat]) {
        fullHtml += '<tr class="grp"><td colspan="4">' + groupTitles[cat] + '</td></tr>' + groupedHtml[cat];
      }
    });

    if (rows) {
      rows.innerHTML = fullHtml;
    }

    if (totalEl) {
      totalEl.textContent = formatMoney(total);
    }

    if (ppEl) {
      var perGuest = guests > 0 ? total / guests : 0;
      ppEl.textContent = '≈ ' + formatMoney(perGuest) + ' за гостя · з запасом 10%';
    }

    // Синхронізація з лід-формою
    if (leadGuestsInput) {
      leadGuestsInput.value = guests;
    }

    if (leadNoteInput) {
      var fmtTitle = fmt === 'banquet' ? 'Банкет' : (fmt === 'buffet' ? 'Фуршет' : 'Кава-брейк');
      var seriesTitle = series === 2 ? 'Royal' : 'Classic';
      leadNoteInput.value = 'Розрахунок з калькулятора: ' + fmtTitle + ', ' + guests + ' гостей, ' + dishes + ' страв, серія ' + seriesTitle + ', орієнтовно ' + formatMoney(total) + '/доба';
    }
  }

  // Обробники змін у формі
  form.addEventListener('input', recalculate);
  form.addEventListener('change', recalculate);

  // Клік «Все в кошик»
  if (addAllBtn) {
    addAllBtn.addEventListener('click', function () {
      var guestsInput = form.querySelector('[data-guests]');
      var guests = parseInt(guestsInput ? guestsInput.value : 100, 10) || 100;
      var fmt = form.elements['fmt'] ? form.elements['fmt'].value : 'banquet';
      var dishes = form.elements['dishes'] ? parseInt(form.elements['dishes'].value, 10) : 3;
      var wine = form.elements['wine'] && form.elements['wine'].checked ? 1 : 0;
      var champ = form.elements['champ'] && form.elements['champ'].checked ? 1 : 0;
      var strong = form.elements['strong'] && form.elements['strong'].checked ? 1 : 0;
      var series = form.elements['series'] ? parseInt(form.elements['series'].value, 10) : 1;

      var formData = new FormData();
      formData.append('guests', guests);
      formData.append('fmt', fmt);
      formData.append('dishes', dishes);
      if (wine) formData.append('wine', '1');
      if (champ) formData.append('champ', '1');
      if (strong) formData.append('strong', '1');
      formData.append('series', series);

      var originalText = addAllBtn.innerHTML;
      addAllBtn.disabled = true;
      addAllBtn.innerHTML = '<span class="k-spinner"></span> Додаємо...';

      fetch(addUrl, {
        method: 'POST',
        body: formData
      })
        .then(function (res) { return res.json(); })
        .then(function (data) {
          addAllBtn.disabled = false;
          addAllBtn.innerHTML = originalText;

          if (data && data.success) {
            updateCartCounters(data.cart_count);
            showToast(data.message || 'Посуд додано до кошика', true);
            if (data.redirect) {
              setTimeout(function () {
                window.location.href = data.redirect;
              }, 400);
            }
          } else {
            showToast((data && data.error) ? data.error : 'Помилка додавання до кошика', false);
          }
        })
        .catch(function () {
          addAllBtn.disabled = false;
          addAllBtn.innerHTML = originalText;
          showToast('Помилка з\'єднання. Спробуйте ще раз.', false);
        });
    });
  }

  // Клік «Надіслати менеджеру»
  if (sendLeadBtn) {
    sendLeadBtn.addEventListener('click', function (e) {
      e.preventDefault();
      var target = document.getElementById('lead');
      if (target) {
        target.scrollIntoView({ behavior: 'smooth' });
        var dateField = target.querySelector('input[name="event_date"]');
        if (dateField) {
          setTimeout(function () { dateField.focus(); }, 400);
        }
      }
    });
  }

  // Початковий запуск для синхронізації
  recalculate();
})();
