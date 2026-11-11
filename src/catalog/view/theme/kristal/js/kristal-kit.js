/**
 * kristal-kit.js — ванільний JS для комплектів подій (фіча 007 kristal_kit).
 * Перемикання гостей, динамічний розрахунок та пакетне додавання в кошик.
 */
(function () {
  'use strict';

  function fmt(n) {
    return String(Math.round(n)).replace(/\B(?=(\d{3})+(?!\d))/g, ' ');
  }

  function getSelectedGuests() {
    var checked = document.querySelector('.k-guests input[type="radio"]:checked');
    if (checked) {
      return parseInt(checked.value, 10) || 100;
    }
    return 100;
  }

  function updateTotals(guests) {
    document.querySelectorAll('[data-pp]').forEach(function (el) {
      var pp = parseFloat(el.getAttribute('data-pp')) || 0;
      var total = pp * guests;
      el.textContent = fmt(total) + ' ₴ за ' + guests + ' гостей · доба';
    });
  }

  // Ініціалізація перемикача гостей
  var guestRadios = document.querySelectorAll('.k-guests input[type="radio"]');
  guestRadios.forEach(function (radio) {
    radio.addEventListener('change', function () {
      var guests = parseInt(this.value, 10) || 100;
      updateTotals(guests);

      // Синхронізація з полем форми ліда, якщо воно є на сторінці
      var leadGuests = document.querySelector('#lead input[name="guests"]');
      if (leadGuests) {
        leadGuests.value = guests;
      }
    });
  });

  // Обробка кліку на кнопку «Додати до події»
  document.querySelectorAll('[data-k-add-kit]').forEach(function (btn) {
    btn.addEventListener('click', function (e) {
      e.preventDefault();

      if (btn.classList.contains('is-loading')) {
        return;
      }

      var kitId = btn.getAttribute('data-kit-id');
      var actionUrl = btn.getAttribute('data-action') || '/?route=extension/kristal/kit/add';
      if (actionUrl.indexOf('index.php?') !== -1) {
        actionUrl = actionUrl.replace(/^.*?index\.php\?/, '/?');
      }
      var guests = getSelectedGuests();

      btn.classList.add('is-loading');
      var origText = btn.innerHTML;
      btn.innerHTML = '<span class="k-spinner"></span> Додаємо...';

      var fd = new FormData();
      fd.append('kit_id', kitId);
      fd.append('guests', guests);

      fetch(actionUrl, {
        method: 'POST',
        headers: {
          'X-Requested-With': 'XMLHttpRequest'
        },
        body: fd
      })
      .then(function (res) { return res.json(); })
      .then(function (json) {
        if (json.success) {
          // Оновлюємо лічильники в шапці
          if (json.cart_count !== undefined) {
            document.querySelectorAll('.k-header__cart .k-mono').forEach(function (el) {
              el.textContent = '(' + json.cart_count + ')';
            });
            document.querySelectorAll('.k-tabbar .k-count').forEach(function (el) {
              el.textContent = json.cart_count;
            });
          }

          // Custom event для аналітики
          window.dispatchEvent(new CustomEvent('kristal:kit:add', {
            detail: { kit_id: kitId, guests: guests }
          }));

          // Перехід у кошик
          if (json.redirect) {
            window.location.href = json.redirect;
          } else {
            btn.classList.remove('is-loading');
            btn.innerHTML = '✓ Додано!';
          }
        } else {
          btn.classList.remove('is-loading');
          btn.innerHTML = origText;
          alert(json.error || 'Помилка при додаванні комплекту');
        }
      })
      .catch(function (err) {
        btn.classList.remove('is-loading');
        btn.innerHTML = origText;
        console.error('Kit add error:', err);
      });
    });
  });

})();
