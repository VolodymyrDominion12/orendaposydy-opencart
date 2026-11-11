(function() {
  'use strict';

  var form = document.getElementById('k-checkout-form');
  if (!form) return;

  var dateFromInput = document.getElementById('k-date-from');
  var dateToInput = document.getElementById('k-date-to');
  var daysDisplay = document.getElementById('k-days-display');
  var addrWrapper = document.getElementById('k-addr-wrapper');
  var addrInput = document.getElementById('k-delivery-address');
  var toggleCompany = document.getElementById('k-toggle-company');
  var companyFields = document.getElementById('k-company-fields');
  var btnSubmit = document.getElementById('k-btn-order');
  var formErrors = document.getElementById('k-form-errors');

  // Summary elements
  var sumPositions = document.getElementById('k-sum-positions');
  var sumUnits = document.getElementById('k-sum-units');
  var sumDayRate = document.getElementById('k-sum-day-rate');
  var sumDaysCount = document.getElementById('k-sum-days-count');
  var sumDaysMult = document.getElementById('k-sum-days-mult');
  var sumSubtotal = document.getElementById('k-sum-subtotal');
  var sumPrepay = document.getElementById('k-sum-prepay');
  var sumPostpay = document.getElementById('k-sum-postpay');

  var currentDayTotal = 0;

  function formatMoney(amount) {
    return Math.round(amount).toString().replace(/\B(?=(\d{3})+(?!\d))/g, ' ') + ' ₴';
  }

  function getDaysCount() {
    if (!dateFromInput || !dateToInput) return 1;
    var f = new Date(dateFromInput.value);
    var t = new Date(dateToInput.value);
    if (isNaN(f.getTime()) || isNaN(t.getTime())) return 1;
    if (t < f) {
      dateToInput.value = dateFromInput.value;
      t = f;
    }
    var diffTime = Math.abs(t - f);
    var diffDays = Math.round(diffTime / (1000 * 60 * 60 * 24));
    return Math.max(1, diffDays);
  }

  function getDaysMultiplier(days) {
    if (days <= 1) return 1.0;
    return 1.0 + (days - 1) * 0.5;
  }

  function pluralDays(days) {
    if (days === 1) return '1 доба';
    if (days >= 2 && days <= 4) return days + ' доби';
    return days + ' діб';
  }

  function updateTotals() {
    var days = getDaysCount();
    var mult = getDaysMultiplier(days);

    if (daysDisplay) daysDisplay.textContent = pluralDays(days);
    if (sumDaysCount) sumDaysCount.textContent = days;
    if (sumDaysMult) sumDaysMult.textContent = '×' + mult.toFixed(1);

    // Initial total from text if not yet set
    if (!currentDayTotal && sumDayRate) {
      var raw = sumDayRate.textContent.replace(/[^\d]/g, '');
      currentDayTotal = parseFloat(raw) || 0;
    }

    var totalOrder = Math.round(currentDayTotal * mult);
    var prepay = Math.round(totalOrder * 0.5);
    var postpay = totalOrder - prepay;

    if (sumSubtotal) sumSubtotal.textContent = formatMoney(totalOrder);
    if (sumPrepay) sumPrepay.textContent = formatMoney(prepay);
    if (sumPostpay) sumPostpay.textContent = formatMoney(postpay);

    var payMethod = form.querySelector('input[name="payment_method"]:checked');
    if (btnSubmit) {
      if (payMethod && payMethod.value === 'oplata') {
        btnSubmit.textContent = 'Сплатити передоплату ' + formatMoney(prepay);
      } else {
        btnSubmit.textContent = 'Надіслати заявку';
      }
    }
  }

  // 1. Зміна дат
  if (dateFromInput && dateToInput) {
    dateFromInput.addEventListener('change', function() {
      if (dateToInput.value < dateFromInput.value) {
        dateToInput.value = dateFromInput.value;
      }
      dateToInput.min = dateFromInput.value;
      updateTotals();
    });
    dateToInput.addEventListener('change', updateTotals);
  }

  // 2. Радіо-картки доставки
  var deliveryRadios = form.querySelectorAll('input[name="delivery_type"]');
  deliveryRadios.forEach(function(r) {
    r.addEventListener('change', function() {
      deliveryRadios.forEach(function(el) {
        var p = el.closest('label');
        if (p) p.classList.toggle('is-checked', el.checked);
      });
      if (addrWrapper) {
        if (r.value === 'pickup') {
          addrWrapper.style.display = 'none';
          if (addrInput) addrInput.removeAttribute('required');
        } else {
          addrWrapper.style.display = 'block';
          if (addrInput) addrInput.setAttribute('required', 'required');
        }
      }
    });
  });

  // 3. Канали зв'язку
  var channelRadios = form.querySelectorAll('input[name="contact_channel"]');
  channelRadios.forEach(function(r) {
    r.addEventListener('change', function() {
      channelRadios.forEach(function(el) {
        var p = el.closest('label');
        if (p) p.classList.toggle('is-checked', el.checked);
      });
    });
  });

  // 4. Юрособа / ФОП
  if (toggleCompany && companyFields) {
    toggleCompany.addEventListener('change', function() {
      companyFields.style.display = toggleCompany.checked ? 'block' : 'none';
      var inputs = companyFields.querySelectorAll('input');
      inputs.forEach(function(inp) {
        if (toggleCompany.checked) {
          inp.setAttribute('required', 'required');
        } else {
          inp.removeAttribute('required');
        }
      });
    });
  }

  // 5. Способи оплати
  var payRadios = form.querySelectorAll('input[name="payment_method"]');
  payRadios.forEach(function(r) {
    r.addEventListener('change', function() {
      payRadios.forEach(function(el) {
        var p = el.closest('label');
        if (p) p.classList.toggle('is-checked', el.checked);
      });
      updateTotals();
    });
  });

  // 6. Керування кількістю (+ / -) та видалення
  var cartLines = document.getElementById('k-cart-lines');
  if (cartLines) {
    cartLines.addEventListener('click', function(e) {
      var btn = e.target.closest('button');
      if (!btn) return;

      var line = btn.closest('.k-line');
      if (!line) return;

      var cartId = line.getAttribute('data-cart-id');
      var act = btn.getAttribute('data-act');

      if (act === 'plus' || act === 'minus') {
        var input = line.querySelector('.k-qty-input');
        if (!input) return;
        var min = parseInt(input.getAttribute('min'), 10) || 1;
        var cur = parseInt(input.value, 10) || min;
        var step = (min >= 10) ? 10 : 1;

        if (act === 'plus') {
          cur += step;
        } else if (act === 'minus') {
          cur = Math.max(min, cur - step);
        }
        input.value = cur;
        updateLineQty(cartId, cur, line);
      } else if (act === 'del') {
        removeLine(cartId, line);
      }
    });

    cartLines.addEventListener('change', function(e) {
      var input = e.target.closest('.k-qty-input');
      if (!input) return;
      var line = input.closest('.k-line');
      if (!line) return;

      var cartId = line.getAttribute('data-cart-id');
      var min = parseInt(input.getAttribute('min'), 10) || 1;
      var val = parseInt(input.value, 10) || min;
      if (val < min) val = min;
      input.value = val;
      updateLineQty(cartId, val, line);
    });
  }

  function updateLineQty(cartId, quantity, line) {
    var fd = new FormData();
    fd.append('cart_id', cartId);
    fd.append('quantity', quantity);

    fetch('/?route=checkout/order/update', {
      method: 'POST',
      body: fd
    })
    .then(function(res) { return res.json(); })
    .then(function(data) {
      if (data && data.success) {
        currentDayTotal = data.total_day_raw;
        if (sumDayRate) sumDayRate.textContent = data.total_day + ' / доба';
        if (sumPositions) sumPositions.textContent = data.count_positions;
        if (sumUnits) sumUnits.textContent = data.total_units;

        // Оновити суму цього рядка
        if (data.products) {
          data.products.forEach(function(p) {
            if (p.cart_id == cartId) {
              var sumEl = line.querySelector('.k-line__sum');
              if (sumEl) sumEl.textContent = p.total;
            }
          });
        }
        updateTotals();
        updateHeaderCart(data.cart_count);
      }
    })
    .catch(function(err) {
      console.error('Update error:', err);
    });
  }

  function removeLine(cartId, line) {
    var fd = new FormData();
    fd.append('cart_id', cartId);

    fetch('/?route=checkout/order/remove', {
      method: 'POST',
      body: fd
    })
    .then(function(res) { return res.json(); })
    .then(function(data) {
      if (data && data.empty) {
        window.location.reload();
      } else if (data && data.success) {
        line.style.opacity = '0';
        line.style.transform = 'translateX(20px)';
        line.style.transition = 'all .3s ease';
        setTimeout(function() {
          if (line.parentNode) line.parentNode.removeChild(line);
        }, 300);

        currentDayTotal = data.total_day_raw;
        if (sumDayRate) sumDayRate.textContent = data.total_day + ' / доба';
        if (sumPositions) sumPositions.textContent = data.count_positions;
        if (sumUnits) sumUnits.textContent = data.total_units;
        updateTotals();
        updateHeaderCart(data.cart_count);
      }
    })
    .catch(function(err) {
      console.error('Remove error:', err);
    });
  }

  function updateHeaderCart(count) {
    var cartBadges = document.querySelectorAll('.k-header__cart .k-mono, .k-tabbar .k-count');
    cartBadges.forEach(function(b) {
      b.textContent = count > 0 ? (b.classList.contains('k-count') ? count : '(' + count + ')') : '';
    });
  }

  // 7. Відправка форми замовлення
  form.addEventListener('submit', function(e) {
    e.preventDefault();

    if (btnSubmit) {
      btnSubmit.disabled = true;
      btnSubmit.textContent = 'Оформлюємо...';
    }
    if (formErrors) {
      formErrors.style.display = 'none';
      formErrors.textContent = '';
    }

    var fd = new FormData(form);
    var saveUrl = form.action || '/?route=checkout/order/save';
    if (saveUrl.indexOf('index.php?') !== -1) {
      saveUrl = saveUrl.replace(/^.*?index\.php\?/, '/?');
    }

    fetch(saveUrl, {
      method: 'POST',
      body: fd
    })
    .then(function(res) { return res.json(); })
    .then(function(data) {
      if (data && data.success && data.redirect) {
        window.location.href = data.redirect;
      } else if (data && data.error) {
        if (btnSubmit) btnSubmit.disabled = false;
        updateTotals();

        var messages = [];
        for (var k in data.error) {
          if (data.error.hasOwnProperty(k)) {
            messages.push(data.error[k]);
          }
        }
        if (formErrors) {
          formErrors.textContent = messages.join('. ');
          formErrors.style.display = 'block';
          formErrors.scrollIntoView({ behavior: 'smooth', block: 'center' });
        }
      } else {
        if (btnSubmit) btnSubmit.disabled = false;
        updateTotals();
      }
    })
    .catch(function(err) {
      console.error('Save error:', err);
      if (btnSubmit) btnSubmit.disabled = false;
      updateTotals();
      if (formErrors) {
        formErrors.textContent = 'Помилка зв\'язку з сервером. Спробуйте ще раз.';
        formErrors.style.display = 'block';
      }
    });
  });

  // Початковий розрахунок
  updateTotals();
})();
