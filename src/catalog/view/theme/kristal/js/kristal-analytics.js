/**
 * kristal-analytics.js — Наскрізна аналітика та Consent Mode v2 для сайту «Крістал».
 * Фіча 015. Без сторонніх залежностей, < 3 КБ.
 */
(function() {
  'use strict';

  window.dataLayer = window.dataLayer || [];
  function gtag() {
    window.dataLayer.push(arguments);
  }

  // 1. Consent Mode v2: початковий стан
  var savedConsent = null;
  try {
    savedConsent = localStorage.getItem('kristal_consent');
  } catch (e) {}

  if (savedConsent === 'granted') {
    gtag('consent', 'default', {
      'analytics_storage': 'granted',
      'ad_storage': 'granted',
      'ad_user_data': 'granted',
      'ad_personalization': 'granted'
    });
  } else {
    gtag('consent', 'default', {
      'analytics_storage': 'denied',
      'ad_storage': 'denied',
      'ad_user_data': 'denied',
      'ad_personalization': 'denied'
    });
  }

  // 2. Відстеження кліків на контактні канали
  document.addEventListener('click', function(e) {
    var target = e.target.closest('a');
    if (!target) return;

    var href = target.getAttribute('href') || '';
    var channel = null;

    if (href.indexOf('tel:') === 0) {
      channel = 'phone';
    } else if (href.indexOf('viber:') === 0 || href.indexOf('viber.click') !== -1) {
      channel = 'viber';
    } else if (href.indexOf('t.me') !== -1 || href.indexOf('telegram') !== -1) {
      channel = 'telegram';
    }

    if (channel) {
      window.dataLayer.push({
        'event': 'contact_click',
        'channel': channel,
        'link_url': href
      });
    }
  }, { passive: true });

  // 3. Слухачі подій лідів та кошика
  window.addEventListener('kristal:lead_success', function(e) {
    var detail = e.detail || {};
    window.dataLayer.push({
      'event': 'generate_lead',
      'lead_type': detail.type || 'calc_15m',
      'source_url': detail.source_url || window.location.pathname
    });
  });

  window.addEventListener('kristal:cart_add', function(e) {
    var item = e.detail || {};
    window.dataLayer.push({
      'event': 'add_to_cart',
      'ecommerce': {
        'items': [item]
      }
    });
  });

  // 4. Банер згоди на Cookie (Consent Mode v2)
  document.addEventListener('DOMContentLoaded', function() {
    if (savedConsent) return;

    var banner = document.createElement('div');
    banner.id = 'k-consent-banner';
    banner.className = 'k-consent-banner';
    banner.setAttribute('role', 'region');
    banner.setAttribute('aria-label', 'Згода на використання файлів cookie');
    banner.innerHTML = [
      '<div class="k-consent-wrap">',
      '  <p class="k-consent-text">Ми використовуємо файли cookie для правильної роботи кошика та аналітики сайту. Ви можете обрати прийнятні для вас параметри.</p>',
      '  <div class="k-consent-btns">',
      '    <button type="button" id="k-consent-all" class="k-btn k-btn--primary k-btn--sm">Прийняти всі</button>',
      '    <button type="button" id="k-consent-essential" class="k-btn k-btn--ghost k-btn--sm">Тільки обов\'язкові</button>',
      '  </div>',
      '</div>'
    ].join('');

    document.body.appendChild(banner);

    function setConsent(status) {
      try {
        localStorage.setItem('kristal_consent', status);
      } catch (e) {}

      gtag('consent', 'update', {
        'analytics_storage': status,
        'ad_storage': status,
        'ad_user_data': status,
        'ad_personalization': status
      });

      if (banner && banner.parentNode) {
        banner.parentNode.removeChild(banner);
      }
    }

    var btnAll = document.getElementById('k-consent-all');
    if (btnAll) {
      btnAll.addEventListener('click', function() {
        setConsent('granted');
      });
    }

    var btnEssential = document.getElementById('k-consent-essential');
    if (btnEssential) {
      btnEssential.addEventListener('click', function() {
        setConsent('denied');
      });
    }
  });
})();
