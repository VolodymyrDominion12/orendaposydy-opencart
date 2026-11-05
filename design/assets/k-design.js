/* Крістал — поведінка макетів. Лише для демонстрації в design/; у темі — окремо, без залежностей. */
(function () {
  var fmt = function (n) { return Math.round(n).toLocaleString('uk-UA').replace(/ /g, ' ') + ' ₴'; };

  // Кнопки −/+ біля кількості
  document.querySelectorAll('.k-qty').forEach(function (q) {
    var inp = q.querySelector('input'), btns = q.querySelectorAll('button');
    var step = function (d) {
      var min = +inp.min || 1, s = +inp.step || 1;
      inp.value = Math.max(min, (+inp.value || min) + d * s);
      inp.dispatchEvent(new Event('input', { bubbles: true }));
    };
    btns[0].addEventListener('click', function () { step(-1); });
    btns[1].addEventListener('click', function () { step(1); });
  });

  // Картка товару: сума й активний поріг знижки
  var buy = document.querySelector('.k-buy');
  if (buy) {
    var tiers = [[300, 10.5], [100, 12], [20, 14]];
    var qi = buy.querySelector('.k-qty input'), sum = buy.querySelector('.k-buy__sum'), cells = buy.querySelectorAll('.k-tiers > div');
    var upd = function () {
      var n = +qi.value, idx = tiers.findIndex(function (t) { return n >= t[0]; }); if (idx < 0) idx = 2;
      var p = tiers[idx][1];
      sum.innerHTML = n + ' шт × ' + String(p).replace('.', ',') + ' ₴ = <b>' + fmt(n * p) + '</b><br>мінімум 20 шт';
      cells.forEach(function (c, i) { c.classList.toggle('is-on', i === 2 - idx); });
    };
    qi.addEventListener('input', upd); upd();
  }

  // Сторінка події: перемикач гостей
  document.querySelectorAll('.k-guests input[type=radio]').forEach(function (r) {
    r.addEventListener('change', function () {
      document.querySelectorAll('[data-pp]').forEach(function (el) {
        if (el.dataset.pp) el.textContent = fmt(el.dataset.pp * r.value) + ' за ' + r.value + ' гостей · доба';
      });
    });
  });

  // Калькулятор події (норми — мок)
  var calc = document.querySelector('[data-calc]');
  if (calc) {
    var form = calc.querySelector('form'), rows = calc.querySelector('[data-rows]');
    var items = {
      plates: [['Тарілка підставна 33 см', 35, { banquet: 1, buffet: 0, coffee: 0 }, 2],
               ['Тарілка закусочна 21 см', 12, { banquet: 1, buffet: 2, coffee: 1 }, 1],
               ['Тарілка обідня 27 см', 14, { banquet: 1, buffet: 0, coffee: 0 }, 1],
               ['Тарілка десертна 19 см', 11, { banquet: 1, buffet: 1, coffee: 1 }, 1]],
      cutlery: [['Виделка столова', 7, { banquet: 1, buffet: 1, coffee: 0 }, 1],
                ['Ніж столовий', 8, { banquet: 1, buffet: 0, coffee: 0 }, 1],
                ['Виделка десертна', 6, { banquet: 1, buffet: 1, coffee: 1 }, 1],
                ['Ложка чайна', 5, { banquet: 1, buffet: 1, coffee: 1 }, 1]],
      glass: [['Келих для вина', 12, { banquet: 1, buffet: 1, coffee: 0 }, 1, 'wine'],
              ['Келих для шампанського', 12, { banquet: 1, buffet: 1, coffee: 0 }, 1, 'champ'],
              ['Чарка 50 мл', 7, { banquet: 1, buffet: 1, coffee: 0 }, 1, 'strong'],
              ['Склянка для води', 8, { banquet: 1, buffet: 1, coffee: 1 }, 1],
              ['Чашка з блюдцем', 10, { banquet: 0, buffet: 0, coffee: 1 }, 1]]
    };
    var names = { plates: 'Посуд', cutlery: 'Прибори', glass: 'Скло' };
    var run = function () {
      var g = +form.querySelector('[data-guests]').value, f = form.fmt.value, d = +form.dishes.value;
      var k = +form.series.value, html = '', total = 0;
      calc.querySelector('[data-out]').textContent = g;
      Object.keys(items).forEach(function (grp) {
        var block = '';
        items[grp].forEach(function (it) {
          if (it[4] && !form[it[4]].checked) return;
          var per = it[2][f]; if (!per) return;
          if (grp === 'plates' && it[0].indexOf('закусочна') > -1 && d >= 4) per += 1;
          if (grp === 'plates' && it[0].indexOf('обідня') > -1 && d <= 2 && f !== 'banquet') per = 0;
          var n = Math.ceil(g * per * 1.1 / 10) * 10; if (!n) return;
          var p = it[1] * (it[3] === 2 || k === 1 ? 1 : k), s = n * p; total += s;
          block += '<tr><td>' + it[0] + '</td><td class="n">' + n + '</td><td class="n hide-m">' + p + ' ₴</td><td class="n">' + fmt(s) + '</td></tr>';
        });
        if (block) html += '<tr class="grp"><td colspan="4">' + names[grp] + '</td></tr>' + block;
      });
      rows.innerHTML = html;
      calc.querySelector('[data-total]').textContent = fmt(total);
      calc.querySelector('[data-pp]').textContent = '≈ ' + fmt(total / g) + ' за гостя · з запасом 10%';
    };
    form.addEventListener('input', run); form.addEventListener('change', run); run();
  }
})();
