/**
 * kristal-lead.js — форми лідогенерації для теми «Крістал» (009).
 * Обробка форми «Розрахунок за 15 хв», модалки «В 1 клік» та «Зворотний дзвінок».
 * Ванільний JS, без сторонніх бібліотек.
 */
(function() {
  'use strict';

  // 1. Форматування та маска телефону (+380...)
  function initPhoneInputs(root) {
    var phones = (root || document).querySelectorAll('input[type="tel"]');
    phones.forEach(function(input) {
      if (input.dataset.kPhoneInit) return;
      input.dataset.kPhoneInit = '1';

      input.addEventListener('focus', function() {
        if (!input.value.trim()) {
          input.value = '+380';
        }
      });

      input.addEventListener('input', function(e) {
        var val = input.value;
        if (!val.startsWith('+380')) {
          val = '+380' + val.replace(/[^\d]/g, '').replace(/^380/, '').replace(/^0/, '');
        }
        input.value = val.substring(0, 13);
      });
    });
  }

  // 2. Обробка відправки форми ліда
  function handleLeadSubmit(form) {
    var btn = form.querySelector('button[type="submit"]');
    var origBtnText = btn ? btn.innerHTML : '';
    var errorBox = form.querySelector('.k-lead-error');
    if (!errorBox) {
      errorBox = document.createElement('div');
      errorBox.className = 'k-lead-error';
      errorBox.setAttribute('role', 'alert');
      form.insertBefore(errorBox, form.firstChild);
    }
    errorBox.textContent = '';
    errorBox.hidden = true;

    // Перевірка телефону
    var phoneInput = form.querySelector('input[type="tel"]');
    if (phoneInput) {
      var phone = phoneInput.value.replace(/[^\d+]/g, '');
      if (!phone.startsWith('+380') || phone.length < 13) {
        errorBox.textContent = 'Вкажіть коректний номер телефону: +380 XX XXX XX XX';
        errorBox.hidden = false;
        phoneInput.focus();
        return;
      }
    }

    // Перевірка файлу (якщо є)
    var fileInput = form.querySelector('input[type="file"]');
    if (fileInput && fileInput.files && fileInput.files.length > 0) {
      var file = fileInput.files[0];
      if (file.size > 10 * 1024 * 1024) {
        errorBox.textContent = 'Розмір файлу не повинен перевищувати 10 МБ.';
        errorBox.hidden = false;
        return;
      }
    }

    if (btn) {
      btn.disabled = true;
      btn.classList.add('is-loading');
      btn.innerHTML = '<span class="k-spinner"></span> Відправляємо...';
    }

    var formData = new FormData(form);
    var action = form.getAttribute('action') || 'index.php?route=extension/kristal/lead/submit';

    fetch(action, {
      method: 'POST',
      body: formData,
      headers: {
        'X-Requested-With': 'XMLHttpRequest'
      }
    })
    .then(function(res) {
      return res.json();
    })
    .then(function(data) {
      if (data.error) {
        errorBox.textContent = data.error;
        errorBox.hidden = false;
        if (btn) {
          btn.disabled = false;
          btn.classList.remove('is-loading');
          btn.innerHTML = origBtnText;
        }
      } else if (data.success) {
        // Успішно!
        window.dispatchEvent(new CustomEvent('kristal:lead', {
          detail: {
            lead_id: data.lead_id,
            type: formData.get('type') || 'lead'
          }
        }));

        // Показуємо стан успіху
        form.innerHTML = '<div class="k-lead-success">' +
          '<div class="k-lead-success__icon" aria-hidden="true">✓</div>' +
          '<h3 class="k-h3">Дякуємо!</h3>' +
          '<p>' + (data.message || 'Вашу заявку прийнято. Менеджер зв\'яжеться з вами протягом 15 хвилин.') + '</p>' +
        '</div>';

        // Якщо це було модальне вікно, даємо користувачу прочитати
        var modal = form.closest('.k-modal');
        if (modal) {
          setTimeout(function() {
            closeModal(modal);
          }, 3500);
        }
      }
    })
    .catch(function() {
      errorBox.textContent = 'Виникла помилка з\'єднання. Будь ласка, зателефонуйте нам або спробуйте пізніше.';
      errorBox.hidden = false;
      if (btn) {
        btn.disabled = false;
        btn.classList.remove('is-loading');
        btn.innerHTML = origBtnText;
      }
    });
  }

  // 3. Індикатор вибраного файлу
  function initFileInputs(root) {
    var files = (root || document).querySelectorAll('.k-file input[type="file"]');
    files.forEach(function(input) {
      var label = input.closest('.k-file');
      var span = label ? label.querySelector('span') : null;
      var defText = span ? span.textContent : '';

      input.addEventListener('change', function() {
        if (input.files && input.files.length > 0) {
          var name = input.files[0].name;
          if (span) span.textContent = '✓ ' + name;
          label.classList.add('has-file');
        } else {
          if (span) span.textContent = defText;
          label.classList.remove('has-file');
        }
      });
    });
  }

  // 4. Керування модальним вікном (1 клік, дзвінок)
  function openModal(modalId, options) {
    var modal = document.getElementById(modalId);
    if (!modal) return;

    options = options || {};
    var titleEl = modal.querySelector('[data-k-modal-title]');
    if (titleEl && options.title) {
      titleEl.textContent = options.title;
    }

    var typeInput = modal.querySelector('input[name="type"]');
    if (typeInput && options.type) {
      typeInput.value = options.type;
    }

    var prodIdInput = modal.querySelector('input[name="product_id"]');
    if (prodIdInput) {
      prodIdInput.value = options.productId || '';
    }

    var qtyInput = modal.querySelector('input[name="quantity"]');
    if (qtyInput) {
      qtyInput.value = options.quantity || 1;
    }

    var descEl = modal.querySelector('[data-k-modal-desc]');
    if (descEl) {
      if (options.productName) {
        descEl.textContent = options.productName + (options.quantity ? ' × ' + options.quantity + ' шт' : '');
        descEl.hidden = false;
      } else {
        descEl.textContent = '';
        descEl.hidden = true;
      }
    }

    modal.classList.add('is-open');
    modal.setAttribute('aria-hidden', 'false');
    document.body.classList.add('k-no-scroll');

    var firstInput = modal.querySelector('input[type="tel"], input[type="text"]');
    if (firstInput) {
      setTimeout(function() { firstInput.focus(); }, 100);
    }
  }

  function closeModal(modal) {
    if (!modal) return;
    modal.classList.remove('is-open');
    modal.setAttribute('aria-hidden', 'true');
    document.body.classList.remove('k-no-scroll');
  }

  // Ініціалізація
  document.addEventListener('DOMContentLoaded', function() {
    initPhoneInputs();
    initFileInputs();

    // Обробка форм з data-k-lead
    document.addEventListener('submit', function(e) {
      var form = e.target.closest('[data-k-lead]');
      if (form) {
        e.preventDefault();
        handleLeadSubmit(form);
      }
    });

    // Кнопка «Забронювати в 1 клік» на товарі
    document.addEventListener('click', function(e) {
      var btn1Click = e.target.closest('[data-k-quick-order]');
      if (btn1Click) {
        e.preventDefault();
        var prodName = btn1Click.dataset.kProdName || document.querySelector('.k-product__title, .k-h1')?.textContent?.trim() || '';
        var prodId = btn1Click.dataset.kProdId || document.querySelector('input[name="product_id"]')?.value || '';
        var qtyInput = document.getElementById('k-qty-main') || document.querySelector('input[name="quantity"]');
        var qty = qtyInput ? qtyInput.value : 1;

        openModal('k-lead-modal', {
          title: 'Швидке бронювання в 1 клік',
          type: 'quick_order',
          productName: prodName,
          productId: prodId,
          quantity: qty
        });
      }

      var btnCallback = e.target.closest('[data-k-callback]');
      if (btnCallback) {
        e.preventDefault();
        openModal('k-lead-modal', {
          title: 'Замовити зворотний дзвінок',
          type: 'callback'
        });
      }

      var closeBtn = e.target.closest('[data-k-modal-close]');
      if (closeBtn) {
        e.preventDefault();
        closeModal(closeBtn.closest('.k-modal'));
      }

      var modalBackdrop = e.target.classList.contains('k-modal');
      if (modalBackdrop) {
        closeModal(e.target);
      }
    });

    // Закриття по Esc
    document.addEventListener('keydown', function(e) {
      if (e.key === 'Escape') {
        var openModals = document.querySelectorAll('.k-modal.is-open');
        openModals.forEach(closeModal);
      }
    });
  });

})();
