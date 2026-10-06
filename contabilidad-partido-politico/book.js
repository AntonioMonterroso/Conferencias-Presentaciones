/* Libro interactivo — Contabilidad de un Partido Político (Guatemala)
   Firma de Auditoría Monterroso, Auditores & Consultores */
(function () {
  'use strict';
  const $ = (s, r = document) => r.querySelector(s);
  const $$ = (s, r = document) => Array.from(r.querySelectorAll(s));
  const fmt = n => n.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
  const fmt0 = n => n.toLocaleString('en-US', { maximumFractionDigits: 0 });
  const Q = n => 'Q ' + fmt(n);
  const store = {
    get(k) { try { return localStorage.getItem(k); } catch (e) { return null; } },
    set(k, v) { try { localStorage.setItem(k, v); } catch (e) { /* sin almacenamiento */ } },
    del(k) { try { localStorage.removeItem(k); } catch (e) { /* sin almacenamiento */ } }
  };

  /* =====================================================================
     CASO PRÁCTICO: una sola fuente de datos (Futuro Retalteco, ejercicio 2026)
     Códigos y nombres según la Nomenclatura Contable del Instructivo del TSE.
     ===================================================================== */
  const ACC = {
    '1-1-2-201': 'Banco financiamiento público',
    '1-1-2-202': 'Banco financiamiento privado',
    '1-1-2-203': 'Bancos cuentas para departamentos',
    '1-1-2-204': 'Bancos cuentas para municipios',
    '1-2-1-104': 'Mobiliario y equipo',
    '1-2-1-110': 'Depreciación acumulada de mobiliario y equipo',
    '3-1-1': 'Patrimonio partidario',
    '4-1-1-101': 'Cuota política año 2026 (financiamiento público)',
    '4-2-1-101': 'Aportaciones de simpatizantes',
    '4-2-1-102-01': 'Afiliados: cuotas ordinarias',
    '4-3-1-105': 'Autofinanciamiento: desayunos, almuerzos y cenas',
    '4-5-2-204': 'Ingreso no dinerario: material de información o propaganda',
    '5-1-1-101': 'Sueldos, salarios y honorarios',
    '5-1-1-102': 'Arrendamiento de sedes centrales',
    '5-1-1-105': 'Agua, luz y teléfono',
    '5-1-1-108': 'Depreciaciones',
    '5-1-2-202': 'Gastos de organización departamentales',
    '5-1-2-203': 'Gastos de organización municipales',
    '5-1-3-305': 'Campañas de afiliación: alimentación y hospedaje',
    '5-1-5-501': 'Capacitación (nacional): gastos de organización',
    '5-1-5-502': 'Capacitación (nacional): material didáctico',
    '5-1-5-503': 'Capacitación (nacional): capacitadores',
    '5-1-5-504': 'Capacitación (nacional): alimentación',
    '5-3-2-204': 'Egreso no dinerario: material de información o propaganda'
  };
  const PART = [
    { n: 1, f: '01-ene', t: 'Apertura del ejercicio', l: [['1-1-2-202', 50000, 0], ['1-2-1-104', 30000, 0], ['3-1-1', 0, 80000]],
      g: 'Saldos iniciales del ejercicio 2026, certificados por contador general y secretario de finanzas.' },
    { n: 2, f: '15-feb', t: 'Cuotas de afiliados', l: [['1-1-2-202', 24000, 0], ['4-2-1-102-01', 0, 24000]],
      g: 'Cuotas ordinarias depositadas en la cuenta privada. Un recibo autorizado por la SAT por cada afiliado.' },
    { n: 3, f: '10-mar', t: 'Donación en efectivo', l: [['1-1-2-202', 15000, 0], ['4-2-1-101', 0, 15000]],
      g: 'Simpatizante (persona individual). Recibo con NIT, CUI y declaración de procedencia. Anotada en el Libro de contribuciones en efectivo.' },
    { n: 4, f: '30-abr', t: 'Alquiler de sede central', l: [['5-1-1-102', 12000, 0], ['1-1-2-202', 0, 12000]],
      g: 'Factura a nombre del partido; pago por transferencia desde la cuenta privada.' },
    { n: 5, f: '18-jun', t: 'Costo de la cena de recaudación', l: [['5-1-3-305', 6000, 0], ['1-1-2-202', 0, 6000]],
      g: 'Para que exista autofinanciamiento, primero debe registrarse el egreso con recursos propios (Instructivo TSE).' },
    { n: 6, f: '18-jun', t: 'Ingreso por la cena', l: [['1-1-2-202', 18000, 0], ['4-3-1-105', 0, 18000]],
      g: 'Recibos por cada participante, según su aportación (60 cubiertos × Q300).' },
    { n: 7, f: '03-jul', t: 'Cuota anual de financiamiento público', l: [['1-1-2-201', 571500, 0], ['4-1-1-101', 0, 571500]],
      g: 'Cuota anual: 150,000 votos × US$2 ÷ 4 años × Q7.62 por dólar (tipo de cambio supuesto).' },
    { n: 8, f: '10-jul', t: 'Entrega 50 % a departamentos y municipios', l: [['1-1-2-203', 95250, 0], ['1-1-2-204', 190500, 0], ['1-1-2-201', 0, 285750]],
      g: 'Según acta certificada del CEN: 1/3 a departamentos y 2/3 a municipios (LEPP art. 21 Bis, literal c). Quedan por liquidar.' },
    { n: 9, f: '31-ago', t: 'Formación y capacitación (30 %)', l: [['5-1-5-501', 40000, 0], ['5-1-5-502', 30000, 0], ['5-1-5-503', 60000, 0], ['5-1-5-504', 41450, 0], ['1-1-2-201', 0, 171450]],
      g: 'Talleres de formación para afiliados, cuadros y fiscales. Todo con factura a nombre del partido.' },
    { n: 10, f: '30-sep', t: 'Sede nacional y actividades nacionales (20 %)', l: [['5-1-1-101', 60000, 0], ['5-1-1-102', 40000, 0], ['5-1-1-105', 14300, 0], ['1-1-2-201', 0, 114300]],
      g: 'Planilla (IGSS), alquiler y servicios de la sede nacional.' },
    { n: 11, f: '31-oct', t: 'Liquidación de fondos departamentales y municipales', l: [['5-1-2-202', 95250, 0], ['5-1-2-203', 190500, 0], ['1-1-2-203', 0, 95250], ['1-1-2-204', 0, 190500]],
      g: 'Informes bajo juramento de cada secretario, con facturas. Se cancela lo entregado en la partida 8.' },
    { n: 12, f: '15-nov', t: 'Donación en especie (control)', l: [['5-3-2-204', 5000, 0], ['4-5-2-204', 0, 5000]],
      g: 'Una imprenta dona material informativo. Valor justipreciado en el recibo; cuentas de control que no mueven bancos.' },
    { n: 13, f: '31-dic', t: 'Depreciación del mobiliario', l: [['5-1-1-108', 6000, 0], ['1-2-1-110', 0, 6000]],
      g: 'Mobiliario y equipo: 20 % anual sobre Q30,000 (Ley de Actualización Tributaria, art. 19).' }
  ];
  const bal = {};
  PART.forEach(p => p.l.forEach(([c, d, h]) => {
    const a = bal[c] || (bal[c] = { d: 0, h: 0, movs: [] });
    a.d += d; a.h += h; a.movs.push({ n: p.n, d, h });
  }));
  const codes = Object.keys(bal).sort();
  const sd = c => (bal[c] ? bal[c].d - bal[c].h : 0);          // saldo deudor
  const sc = c => (bal[c] ? bal[c].h - bal[c].d : 0);          // saldo acreedor
  const sumBy = (re, fn) => codes.filter(c => re.test(c)).reduce((s, c) => s + fn(c), 0);

  const TOT = {
    ingPub: sumBy(/^4-1/, sc),
    ingPriDin: sumBy(/^4-2/, sc),
    ingAuto: sumBy(/^4-3/, sc),
    ingEsp: sumBy(/^4-5/, sc),
    egFunc: sumBy(/^5-1-1/, sd),
    egAsam: sumBy(/^5-1-2/, sd),
    egAfil: sumBy(/^5-1-3/, sd),
    egCap: sumBy(/^5-1-5/, sd),
    egEsp: sumBy(/^5-3/, sd)
  };
  TOT.ingresos = TOT.ingPub + TOT.ingPriDin + TOT.ingAuto + TOT.ingEsp;
  TOT.egresos = TOT.egFunc + TOT.egAsam + TOT.egAfil + TOT.egCap + TOT.egEsp;
  TOT.resultado = TOT.ingresos - TOT.egresos;

  function partidaHTML(p, open) {
    const td = p.l.reduce((s, r) => s + r[1], 0);
    const rows = p.l.map(([c, d, h]) => h
      ? `<tr><td class="c">${c}</td><td class="h">${ACC[c]}</td><td class="d"></td><td class="hh">${fmt0(h)}</td></tr>`
      : `<tr><td class="c">${c}</td><td>${ACC[c]}</td><td class="d">${fmt0(d)}</td><td class="hh"></td></tr>`).join('');
    return `<details class="partida"${open ? ' open' : ''}><summary><span>Partida ${p.n} · ${p.f}-2026 · ${p.t}</span><span class="num">${fmt0(td)}</span></summary><table>${rows}</table><div class="gl">${p.g}</div></details>`;
  }
  function tHTML(c) {
    const a = bal[c];
    const ds = a.movs.filter(m => m.d).map(m => `<span><i>P${m.n}</i>${fmt0(m.d)}</span>`).join('');
    const hs = a.movs.filter(m => m.h).map(m => `<span><i>P${m.n}</i>${fmt0(m.h)}</span>`).join('');
    const s = a.d - a.h;
    return `<div class="tacct"><div class="tt">${c} · ${ACC[c]}</div><div class="cols"><div>${ds}</div><div>${hs}</div></div><div class="sal">Saldo ${s >= 0 ? 'deudor' : 'acreedor'}: ${fmt0(Math.abs(s))}</div></div>`;
  }
  const GEN = {
    diario(el) {
      const from = +el.dataset.from, to = +el.dataset.to;
      el.innerHTML = PART.filter(p => p.n >= from && p.n <= to).map(p => partidaHTML(p, el.dataset.open !== 'no')).join('');
    },
    mayor(el) {
      const sel = '<label for="mayor-sel" class="small" style="display:block;margin-bottom:3px;font-family:var(--sans);font-weight:600">Elija una cuenta del Libro Mayor</label><select id="mayor-sel" style="width:100%;font-family:var(--sans);font-size:13px;padding:5px 8px;border:1px solid var(--rule);border-radius:4px;background:#fff">' +
        codes.map(c => `<option value="${c}">${c} · ${ACC[c]}</option>`).join('') + '</select><div id="mayor-view" style="margin-top:8px"></div>';
      el.innerHTML = sel;
      const view = $('#mayor-view', el), s = $('#mayor-sel', el);
      const draw = () => { view.innerHTML = tHTML(s.value); };
      s.value = '1-1-2-202'; s.addEventListener('change', draw); draw();
    },
    mayorfijo(el) {
      el.innerHTML = '<div class="tgrid">' + ['1-1-2-201', '1-1-2-202', '1-1-2-203', '3-1-1'].map(tHTML).join('') + '</div>';
    },
    balanza(el) {
      let td = 0, th = 0, sdt = 0, sct = 0;
      const rows = codes.map(c => {
        const a = bal[c], s = a.d - a.h;
        td += a.d; th += a.h; if (s >= 0) sdt += s; else sct += -s;
        return `<tr><td class="num">${c}</td><td>${ACC[c]}</td><td class="r">${fmt0(a.d)}</td><td class="r">${fmt0(a.h)}</td><td class="r">${s > 0 ? fmt0(s) : ''}</td><td class="r">${s < 0 ? fmt0(-s) : ''}</td></tr>`;
      }).join('');
      el.innerHTML = `<table class="t dense" style="font-size:10.6px"><thead><tr><th>Código</th><th>Cuenta</th><th class="r">Debe</th><th class="r">Haber</th><th class="r">S. deudor</th><th class="r">S. acreedor</th></tr></thead><tbody>${rows}<tr class="tot"><td></td><td>Sumas iguales</td><td class="r">${fmt0(td)}</td><td class="r">${fmt0(th)}</td><td class="r">${fmt0(sdt)}</td><td class="r">${fmt0(sct)}</td></tr></tbody></table>`;
      el.dataset.ok = (td === th && sdt === sct) ? '1' : '0';
    },
    balance(el) {
      const bp = sd('1-1-2-201'), bpr = sd('1-1-2-202'), bd = sd('1-1-2-203'), bm = sd('1-1-2-204');
      const corr = bp + bpr + bd + bm;
      const mob = sd('1-2-1-104'), dep = -sd('1-2-1-110');
      const noc = mob - dep;
      const activo = corr + noc;
      const pat = sc('3-1-1');
      el.innerHTML = `<table class="t">
        <thead><tr><th colspan="2">Balance de Situación General al 31-dic-2026 (Q)</th></tr></thead><tbody>
        <tr><td colspan="2"><b>1 · ACTIVO</b></td></tr>
        <tr><td>1.1 Activo corriente · Efectivo y bancos</td><td class="r">${fmt0(corr)}</td></tr>
        <tr><td style="padding-left:20px">Banco financiamiento público</td><td class="r">${fmt0(bp)}</td></tr>
        <tr><td style="padding-left:20px">Banco financiamiento privado</td><td class="r">${fmt0(bpr)}</td></tr>
        <tr><td style="padding-left:20px">Bancos departamentos y municipios</td><td class="r">${fmt0(bd + bm)}</td></tr>
        <tr><td>1.2 Activo no corriente · Mobiliario y equipo (neto)</td><td class="r">${fmt0(noc)}</td></tr>
        <tr><td style="padding-left:20px">Costo ${fmt0(mob)} menos depreciación ${fmt0(dep)}</td><td class="r"></td></tr>
        <tr class="tot"><td>TOTAL ACTIVO</td><td class="r">${fmt0(activo)}</td></tr>
        <tr><td colspan="2"><b>2 · PASIVO</b></td></tr>
        <tr><td>Sin obligaciones pendientes al cierre</td><td class="r">0</td></tr>
        <tr><td colspan="2"><b>3 · PATRIMONIO</b></td></tr>
        <tr><td>3.1 Patrimonio partidario</td><td class="r">${fmt0(pat)}</td></tr>
        <tr><td>3.2 Resultado del presente ejercicio</td><td class="r">${fmt0(TOT.resultado)}</td></tr>
        <tr class="tot"><td>TOTAL PASIVO + PATRIMONIO</td><td class="r">${fmt0(pat + TOT.resultado)}</td></tr>
        </tbody></table>`;
      el.dataset.ok = (activo === pat + TOT.resultado) ? '1' : '0';
    },
    estado(el) {
      const r = (l, v, ind) => `<tr><td${ind ? ' style="padding-left:18px"' : ''}>${l}</td><td class="r">${fmt0(v)}</td></tr>`;
      el.innerHTML = `<table class="t"><thead><tr><th colspan="2">Estado de Ingresos y Egresos · 01-ene al 31-dic-2026 (Q)</th></tr></thead><tbody>
        <tr><td colspan="2"><b>1 · INGRESOS</b></td></tr>
        ${r('1.1 Financiamiento público (cuota 2026)', TOT.ingPub)}
        ${r('1.2 Financiamiento privado', TOT.ingPriDin + TOT.ingAuto + TOT.ingEsp)}
        ${r('Aportes de afiliados (cuotas ordinarias)', sc('4-2-1-102-01'), 1)}
        ${r('Aportes de simpatizantes', sc('4-2-1-101'), 1)}
        ${r('Autofinanciamiento (cena)', TOT.ingAuto, 1)}
        ${r('Ingresos no dinerarios (control)', TOT.ingEsp, 1)}
        <tr class="tot"><td>TOTAL INGRESOS</td><td class="r">${fmt0(TOT.ingresos)}</td></tr>
        <tr><td colspan="2"><b>2 · EGRESOS · gastos permanentes</b></td></tr>
        ${r('Gastos de funcionamiento', TOT.egFunc, 1)}
        ${r('Asambleas de ley (organización dptal. y municipal)', TOT.egAsam, 1)}
        ${r('Campañas de afiliación', TOT.egAfil, 1)}
        ${r('Capacitación y formación política (nacional)', TOT.egCap, 1)}
        ${r('Egresos no dinerarios (control)', TOT.egEsp, 1)}
        <tr><td colspan="2"><b>2.2 Gastos de campaña electoral</b></td></tr>
        ${r('Sin gastos de campaña en 2026', 0, 1)}
        <tr class="tot"><td>TOTAL EGRESOS</td><td class="r">${fmt0(TOT.egresos)}</td></tr>
        <tr class="tot"><td>3 · RESULTADO DEL EJERCICIO</td><td class="r">${fmt0(TOT.resultado)}</td></tr></tbody></table>`;
    },
    kpis(el) {
      const pub = TOT.ingPub;
      el.innerHTML = `<table class="t"><thead><tr><th>Control</th><th class="r">Resultado</th></tr></thead><tbody>
        <tr><td>30 % formación (esperado ${fmt0(pub * 0.3)})</td><td class="r">${fmt0(TOT.egCap)} ✓</td></tr>
        <tr><td>20 % sede nacional (esperado ${fmt0(pub * 0.2)})</td><td class="r">${fmt0(sd('5-1-1-101') + 40000 + sd('5-1-1-105') - 0)} ✓</td></tr>
        <tr><td>50 % departamentos y municipios (esperado ${fmt0(pub * 0.5)})</td><td class="r">${fmt0(TOT.egAsam)} ✓</td></tr>
        <tr><td>Banco público al cierre</td><td class="r">${fmt0(sd('1-1-2-201'))}</td></tr></tbody></table>`;
    }
  };
  $$('[data-gen]').forEach(el => GEN[el.dataset.gen] && GEN[el.dataset.gen](el));

  /* =====================================================================
     CALCULADORAS
     ===================================================================== */
  const num = (el, d = 0) => { const v = parseFloat(String(el.value).replace(/,/g, '')); return isFinite(v) ? v : d; };

  function initTecho(root) {
    const e = $('.in-elec', root), tc = $('.in-tc', root), m = $('.in-mun', root);
    const run = () => {
      const usd = num(e) * 0.5, q = usd * num(tc);
      $('.o-usd', root).textContent = 'US$ ' + fmt0(usd);
      $('.o-q', root).textContent = Q(q);
      $('.o-10', root).textContent = Q(q * 0.1);
      $('.o-pc', root).textContent = Q(0.5 * num(tc));
      $('.o-com', root).textContent = Q(num(m) * 0.1 * num(tc));
      window.__techo = q;
    };
    [e, tc, m].forEach(i => i.addEventListener('input', run)); run();
  }
  function initAportante(root) {
    const t = $('.in-techo', root), a = $('.in-aporte', root), v = $('.in-vinc', root);
    const run = () => {
      const lim = num(t) * 0.10, total = num(a) + num(v);
      const pct = lim > 0 ? total / lim * 100 : 0;
      $('.o-lim', root).textContent = Q(lim);
      $('.o-tot', root).textContent = Q(total);
      $('.o-pct', root).textContent = fmt(pct) + ' % del límite';
      const ver = $('.verdict', root);
      const ok = total <= lim;
      ver.className = 'verdict ' + (ok ? 'ok' : 'no');
      ver.textContent = ok ? 'Dentro del límite del 10 % (art. 21 Ter, g)' : 'EXCEDE el 10 %: la organización no debe aceptarlo';
      const f = [];
      f.push(total >= 30000 ? 'Libros de contribuciones del financista: obligatorios (≥ Q30,000 por período fiscal)' : 'Libros del financista: opcionales (< Q30,000)');
      f.push(total > 50000 ? 'Declaración jurada en acta notarial: obligatoria (> Q50,000) y pago por banco' : 'Declaración jurada notarial: no exigible (≤ Q50,000)');
      $('.o-flags', root).innerHTML = f.map(x => `<div class="ln"><span>${x}</span></div>`).join('');
    };
    [t, a, v].forEach(i => i.addEventListener('input', run)); run();
  }
  function initPublico(root) {
    const v = $('.in-votos', root), tv = $('.in-valid', root), dip = $('.in-dip', root), tc = $('.in-tc', root), elec = $('.in-electoral', root);
    const run = () => {
      const votos = num(v), tot = num(tv), tcv = num(tc);
      const pct = tot > 0 ? votos / tot * 100 : 0;
      const derecho = pct >= 5 || num(dip) >= 1;
      const usdTot = votos * 2, usdAn = usdTot / 4, qAn = usdAn * tcv;
      const dv = $('.o-derecho', root);
      dv.className = 'verdict o-derecho ' + (derecho ? 'ok' : 'no');
      dv.textContent = derecho
        ? `Tiene derecho: ${pct >= 5 ? 'supera el 5 % (' + fmt(pct) + ' %)' : 'obtuvo al menos una diputación (' + fmt(pct) + ' % de votos)'}`
        : `Sin derecho: ${fmt(pct)} % de votos y 0 diputaciones (art. 21 Bis)`;
      const k = derecho ? 1 : 0;
      $('.o-usd4', root).textContent = 'US$ ' + fmt0(usdTot * k);
      $('.o-usd1', root).textContent = 'US$ ' + fmt0(usdAn * k);
      $('.o-q1', root).textContent = Q(qAn * k);
      const A = qAn * k;
      const set = (c, val) => { $(c, root).textContent = Q(val); };
      if (elec.checked) {
        $('.o-dist', root).innerHTML = `<div class="ln"><span>Año electoral: cuota total para campaña (se paga en enero)</span><span>${Q(A)}</span></div><div class="ln"><span>Cuenta específica de campaña · cuenta como gasto del techo</span><span></span></div>`;
        $('.bar', root).style.display = 'none';
      } else {
        $('.bar', root).style.display = 'flex';
        $('.o-dist', root).innerHTML = `
          <div class="ln"><span>30 % Formación y capacitación de afiliados</span><span>${Q(A * .3)}</span></div>
          <div class="ln"><span>20 % Actividades nacionales y sede nacional</span><span>${Q(A * .2)}</span></div>
          <div class="ln"><span>50 % Departamentos y municipios</span><span>${Q(A * .5)}</span></div>
          <div class="ln"><span>&nbsp;&nbsp;↳ 1/3 órganos departamentales</span><span>${Q(A * .5 / 3)}</span></div>
          <div class="ln"><span>&nbsp;&nbsp;↳ 2/3 órganos municipales</span><span>${Q(A * .5 * 2 / 3)}</span></div>`;
      }
    };
    [v, tv, dip, tc].forEach(i => i.addEventListener('input', run));
    elec.addEventListener('change', run); run();
  }
  $$('[data-calc="techo"]').forEach(initTecho);
  $$('[data-calc="aportante"]').forEach(initAportante);
  $$('[data-calc="publico"]').forEach(initPublico);

  /* Checklist con progreso persistente */
  $$('[data-check]').forEach(root => {
    const items = $$('input[type=checkbox]', root), meter = $('.meter i', root), lbl = $('.mlabel', root);
    const key = 'mdpp-check';
    let saved = {}; try { saved = JSON.parse(store.get(key) || '{}'); } catch (e) { saved = {}; }
    items.forEach(i => { i.checked = !!saved[i.dataset.k]; });
    const upd = () => {
      const n = items.filter(i => i.checked).length;
      meter.style.width = (n / items.length * 100) + '%';
      lbl.textContent = `${n} de ${items.length} controles cumplidos`;
    };
    items.forEach(i => i.addEventListener('change', () => { saved[i.dataset.k] = i.checked; store.set(key, JSON.stringify(saved)); upd(); }));
    const reset = $('.reset', root);
    if (reset) reset.addEventListener('click', () => { items.forEach(i => { i.checked = false; }); saved = {}; store.del(key); upd(); });
    upd();
  });

  /* =====================================================================
     LIBRO: páginas, volteo, navegación
     ===================================================================== */
  const bookEl = $('#book'), slotL = $('#slotL'), slotR = $('#slotR'), flipper = $('#flipper');
  const faceF = $('.face.fr', flipper), faceB = $('.face.bk', flipper);
  const pages = $$('#pages > .page');
  const T = pages.length;                  // portada (0) + contenido + contraportada (T-1)
  const MAXS = T / 2;                      // último spread: contraportada sola a la izquierda
  const REDUCED = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  let single = false, s = 0, p = 0, busy = false;

  // cabeceras, folios y ribete de marcapáginas
  pages.forEach((pg, i) => {
    pg.dataset.idx = i;
    if (pg.classList.contains('cover') || pg.classList.contains('back')) return;
    const rh = document.createElement('div'); rh.className = 'runhead';
    rh.innerHTML = i % 2 ? '<span>Firma de Auditoría Monterroso</span><span>Auditores &amp; Consultores</span>' : `<span>Contabilidad de un Partido Político</span><span>${pg.dataset.sec || ''}</span>`;
    const fo = document.createElement('div'); fo.className = 'folio'; fo.textContent = i;
    const wm = document.createElement('img'); wm.className = 'mono-wm'; wm.src = 'assets/monograma-m.png'; wm.alt = ''; wm.setAttribute('aria-hidden', 'true');
    const rb = document.createElement('div'); rb.className = 'ribbon';
    pg.prepend(wm); pg.append(rh, fo, rb);
  });

  const pageById = id => pages.findIndex(x => x.id === id);
  const spreadOf = i => Math.ceil(i / 2);
  const place = (slot, pg) => { slot.replaceChildren(); if (pg) slot.appendChild(pg); };
  const clone = pg => { const c = pg.cloneNode(true); c.removeAttribute('id'); $$('[id]', c).forEach(n => n.removeAttribute('id')); return c; };

  function scale() {
    const W = single ? 560 : 1120, H = 780;
    const vw = window.innerWidth, vh = window.innerHeight;
    const k = Math.min((vw * (single ? 0.98 : 0.95)) / W, (vh - 108) / H, 1.6);
    bookEl.style.setProperty('--k', k.toFixed(4));
  }
  function shiftFor(sp) {
    if (single) return 0;
    return sp === 0 ? -280 : (sp === MAXS ? 280 : 0);
  }
  function setShift(sp) { bookEl.style.setProperty('--shift', shiftFor(sp) + 'px'); }

  function currentPages() { return single ? [p] : [s === 0 ? null : 2 * s - 1, 2 * s < T ? 2 * s : null]; }

  function updateUI() {
    const vis = single ? [p] : currentPages().filter(x => x !== null);
    const first = Math.min(...vis), last = Math.max(...vis);
    const lbl = $('#pglabel');
    lbl.textContent = first === last ? `Pág. ${first === 0 ? 'portada' : first === T - 1 ? 'contraportada' : first} de ${T - 2}` : `Págs. ${first === 0 ? 'portada' : first}–${last === T - 1 ? 'contraportada' : last} de ${T - 2}`;
    $('#progress i').style.width = (last / (T - 1) * 100) + '%';
    const ref = pages[single ? p : (s === 0 ? 0 : 2 * s - 1)];
    const sec = (pages[last] && pages[last].dataset.sec) || (ref && ref.dataset.sec) || '';
    $$('.chip').forEach(c => c.setAttribute('aria-current', c.dataset.sec === sec ? 'true' : 'false'));
    $('#prev').disabled = single ? p === 0 : s === 0;
    $('#next').disabled = single ? p === T - 1 : s === MAXS;
    const mk = +(store.get('mdpp-bm') || -1);
    pages.forEach((pg, i) => pg.classList.toggle('marked', i === mk));
    const btn = $('#bm'); btn.setAttribute('aria-pressed', vis.includes(mk) ? 'true' : 'false');
    try { history.replaceState(null, '', '#p' + first); } catch (e) { /* file:// restringido */ }
  }

  function show(i, instant) {
    if (single) {
      i = Math.max(0, Math.min(T - 1, i));
      const dir = i > p ? 1 : -1; p = i;
      place(slotR, pages[p]); setShift(0);
      if (!instant && !REDUCED) slotR.animate([{ transform: `translateX(${28 * dir}px)`, opacity: 0 }, { transform: 'none', opacity: 1 }], { duration: 300, easing: 'cubic-bezier(.23,1,.32,1)' });
    } else {
      s = Math.max(0, Math.min(MAXS, spreadOf(i)));
      place(slotL, s === 0 ? null : pages[2 * s - 1]);
      place(slotR, 2 * s < T ? pages[2 * s] : null);
      setShift(s);
      if (!instant && !REDUCED) { document.body.classList.remove('fade'); void document.body.offsetWidth; document.body.classList.add('fade'); }
    }
    updateUI();
  }

  function flip(dir) {
    if (busy) return;
    if (single) { const t = p + dir; if (t < 0 || t >= T) return; show(t); return; }
    const t = s + dir; if (t < 0 || t > MAXS) return;
    if (REDUCED) { show(2 * t, true); return; }
    busy = true;
    const back = dir < 0;
    flipper.classList.toggle('back-dir', back);
    flipper.classList.remove('go');
    if (!back) {
      const oldRight = pages[2 * s], newLeft = pages[2 * t - 1], newRight = 2 * t < T ? pages[2 * t] : null;
      faceF.replaceChildren(clone(oldRight)); faceB.replaceChildren(clone(newLeft));
      place(slotR, newRight);
      flipper.style.transition = 'none'; flipper.style.transform = 'rotateY(0deg)'; flipper.style.display = 'block';
      void flipper.offsetWidth;
      setShift(t);
      flipper.classList.add('go'); flipper.style.transition = 'transform .8s cubic-bezier(.23,1,.32,1)'; flipper.style.transform = 'rotateY(-180deg)';
      finish(() => { place(slotL, newLeft); });
    } else {
      const oldLeft = pages[2 * s - 1], newRight = pages[2 * t], newLeft = t === 0 ? null : pages[2 * t - 1];
      faceF.replaceChildren(clone(oldLeft)); faceB.replaceChildren(clone(newRight));
      place(slotL, newLeft);
      flipper.style.transition = 'none'; flipper.style.transform = 'rotateY(0deg)'; flipper.style.display = 'block';
      void flipper.offsetWidth;
      setShift(t);
      flipper.classList.add('go'); flipper.style.transition = 'transform .8s cubic-bezier(.23,1,.32,1)'; flipper.style.transform = 'rotateY(180deg)';
      finish(() => { place(slotR, newRight); });
    }
    s = t; updateUI();
    function finish(done) {
      let ended = false;
      const end = () => { if (ended) return; ended = true; flipper.removeEventListener('transitionend', end); done(); flipper.style.display = 'none'; busy = false; };
      flipper.addEventListener('transitionend', end); setTimeout(end, 950);
    }
  }

  function go(i) { if (busy) return; const wasS = s; show(i); void wasS; }
  window.__book = { go: i => show(i, true), flip, pages, T };

  /* Controles */
  $('#prev').addEventListener('click', () => flip(-1));
  $('#next').addEventListener('click', () => flip(1));
  $('.edge.l').addEventListener('click', () => flip(-1));
  $('.edge.r').addEventListener('click', () => flip(1));
  $$('[data-goto]').forEach(a => {
    const idx = pageById(a.dataset.goto);
    const pg = $('.pg', a); if (pg && idx > -1) pg.textContent = idx;
    a.addEventListener('click', ev => { ev.preventDefault(); if (idx > -1) go(idx); });
  });
  $('#toc-btn').addEventListener('click', () => go(pageById('indice')));
  $('#cover-open').addEventListener('click', () => flip(1));
  $('#progress').addEventListener('click', ev => {
    const r = ev.currentTarget.getBoundingClientRect(); go(Math.round((ev.clientX - r.left) / r.width * (T - 1)));
  });
  $('#bm').addEventListener('click', () => {
    const vis = single ? [p] : currentPages().filter(x => x !== null);
    const mk = +(store.get('mdpp-bm') || -1);
    if (vis.includes(mk)) store.del('mdpp-bm'); else store.set('mdpp-bm', String(vis[vis.length - 1]));
    updateUI();
  });
  $('#print-btn').addEventListener('click', () => window.print());

  // chips de sección
  const secs = pages.filter(x => x.dataset.secStart);
  const chips = $('#chips');
  secs.forEach(pg => {
    const b = document.createElement('button'); b.className = 'chip'; b.type = 'button';
    b.textContent = pg.dataset.secStart; b.dataset.sec = pg.dataset.sec;
    b.addEventListener('click', () => go(+pg.dataset.idx));
    chips.appendChild(b);
  });

  document.addEventListener('keydown', ev => {
    const tag = (ev.target.tagName || '').toLowerCase();
    if (['input', 'textarea', 'select'].includes(tag)) return;
    if (ev.key === 'ArrowRight' || ev.key === 'PageDown' || (ev.key === ' ' && tag !== 'button' && tag !== 'summary')) { ev.preventDefault(); flip(1); }
    else if (ev.key === 'ArrowLeft' || ev.key === 'PageUp') { ev.preventDefault(); flip(-1); }
    else if (ev.key === 'Home') { ev.preventDefault(); go(0); }
    else if (ev.key === 'End') { ev.preventDefault(); go(T - 1); }
  });

  // deslizar con el dedo o el puntero
  let sx = 0, sy = 0, tracking = false;
  const stage = $('.stage');
  stage.addEventListener('pointerdown', ev => {
    if (ev.target.closest('input,select,button,a,summary,textarea,label')) return;
    tracking = true; sx = ev.clientX; sy = ev.clientY;
  });
  window.addEventListener('pointerup', ev => {
    if (!tracking) return; tracking = false;
    const dx = ev.clientX - sx, dy = ev.clientY - sy;
    if (Math.abs(dx) > 70 && Math.abs(dy) < 60) flip(dx < 0 ? 1 : -1);
  });

  // impresión: una página por hoja
  const pr = $('#print-root');
  window.addEventListener('beforeprint', () => { pr.replaceChildren(...pages.map(clone)); });
  window.addEventListener('afterprint', () => pr.replaceChildren());

  function layout() {
    const want = window.innerWidth <= 820;
    if (want !== single) {
      const cur = single ? p : (s === 0 ? 0 : 2 * s - 1);
      single = want;
      bookEl.classList.toggle('single', single);
      scale(); show(single ? cur : cur, true);
    } else { scale(); }
  }
  window.addEventListener('resize', layout);
  single = window.innerWidth <= 820; bookEl.classList.toggle('single', single); scale();

  const h = /^#p(\d+)$/.exec(location.hash);
  const bm = +(store.get('mdpp-bm') || -1);
  show(h ? +h[1] : 0, true);
  void bm;
  bookEl.style.visibility = 'visible';
})();
