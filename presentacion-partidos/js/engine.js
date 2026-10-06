/* Motor de la presentación: escenario 1920x1080, pasos, sincronización de dos ventanas. */
(window.MDPP_BOOT || Promise.resolve()).then(function () {
  'use strict';
  const $ = (s, r = document) => r.querySelector(s);
  const $$ = (s, r = document) => Array.from(r.querySelectorAll(s));
  const SL = window.SLIDES, SECS = window.SECTIONS;
  const ROLE = document.body.dataset.role || 'audience';
  const KEY = 'mdpp-deck-state', KT = 'mdpp-deck-timer';
  const REDUCED = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  const store = {
    get(k) { try { return localStorage.getItem(k); } catch (e) { return null; } },
    set(k, v) { try { localStorage.setItem(k, v); } catch (e) { /* sin almacenamiento */ } },
    del(k) { try { localStorage.removeItem(k); } catch (e) { /* sin almacenamiento */ } }
  };

  /* pasos máximos por diapositiva */
  SL.forEach(s => {
    const m = [...s.html.matchAll(/data-s="(\d+)"/g)].map(x => +x[1]);
    const g = [...s.html.matchAll(/data-go="(\d+)"/g)].map(x => +x[1]);
    s.steps = Math.max(0, s.steps || 0, ...m, ...g);
    s.m = s.m == null ? 1 : s.m;
  });
  const T = SL.length;
  const TOTAL_MIN = SL.reduce((a, s) => a + s.m, 0);
  const plannedBefore = i => SL.slice(0, i).reduce((a, s) => a + s.m, 0);

  /* ---------- contadores ---------- */
  const easeOut = t => 1 - Math.pow(1 - t, 4);
  function fmtNum(v, dec) { return v.toLocaleString('en-US', { minimumFractionDigits: dec, maximumFractionDigits: dec }); }
  function countTo(node, to, opt) {
    opt = opt || {};
    const pre = opt.pre != null ? opt.pre : (node.dataset.pre || ''), suf = opt.suf != null ? opt.suf : (node.dataset.suf || '');
    const dec = opt.dec != null ? opt.dec : +(node.dataset.dec || 0);
    const from = node._v || 0; node._v = to;
    cancelAnimationFrame(node._raf);
    if (opt.instant || REDUCED) { node.textContent = pre + fmtNum(to, dec) + suf; return; }
    const dur = opt.dur || 1500, t0 = performance.now();
    const tick = now => {
      const k = Math.min(1, (now - t0) / dur);
      node.textContent = pre + fmtNum(from + (to - from) * easeOut(k), dec) + suf;
      if (k < 1) node._raf = requestAnimationFrame(tick);
    };
    node._raf = requestAnimationFrame(tick);
  }
  function runCounters(root, instant) {
    const list = root.matches && root.matches('.cnt') ? [root] : [];
    $$('.cnt', root).forEach(n => list.push(n));
    list.forEach(n => countTo(n, +n.dataset.to, { instant }));
  }

  /* ---------- construcción de diapositivas ---------- */
  function splitWords(el) {
    let n = 0;
    const walk = node => {
      Array.from(node.childNodes).forEach(ch => {
        if (ch.nodeType === 3) {
          const frag = document.createDocumentFragment();
          ch.textContent.split(/(\s+)/).forEach(tok => {
            if (!tok) return;
            if (/^\s+$/.test(tok)) { frag.appendChild(document.createTextNode(' ')); return; }
            const w = document.createElement('span'); w.className = 'w';
            const inner = document.createElement('span'); inner.textContent = tok; inner.style.setProperty('--wi', n++);
            w.appendChild(inner); frag.appendChild(w);
          });
          node.replaceChild(frag, ch);
        } else if (ch.nodeType === 1) walk(ch);
      });
    };
    walk(el);
  }
  function build(idx, step, mode) {
    const s = SL[idx];
    const el = document.createElement('div');
    el.className = 'slide' + (s.cls ? ' ' + s.cls : '') + (mode === 'static' ? ' static' : '');
    el.dataset.idx = idx;
    el.innerHTML = s.html;
    $$('.a,.a-l,.a-r,.a-z', el).forEach((n, i) => n.style.setProperty('--i', i));
    $$('.split', el).forEach(splitWords);
    applyStep(el, step, false, mode === 'static');
    return el;
  }
  function applyStep(el, step, animate, instant) {
    const idx = +el.dataset.idx, s = SL[idx];
    const first = !el._init; el._init = true;
    $$('[data-s]', el).forEach(n => {
      const hide = +n.dataset.s > step, was = n.classList.contains('hid');
      n.classList.toggle('hid', hide);
      if (!hide && was && animate) runCounters(n, false);
      if (!hide && first) runCounters(n, instant);
      if (hide && !n._cz) { $$('.cnt', n).forEach(c => { c._v = 0; c.textContent = (c.dataset.pre || '') + fmtNum(0, +(c.dataset.dec || 0)) + (c.dataset.suf || ''); }); }
    });
    $$('[data-go]', el).forEach(n => n.classList.toggle('go', step >= +n.dataset.go));
    if (first) $$('.cnt', el).forEach(n => { if (!n.closest('[data-s]')) countTo(n, +n.dataset.to, { instant }); });
    if (s.hook) s.hook(el, step, { animate: animate && !instant, instant, countTo });
  }

  /* ---------- escenario (marco escalable) ---------- */
  function makeFrame(container, opt) {
    opt = opt || {};
    const frame = document.createElement('div'); frame.className = 'frame';
    const stage = document.createElement('div'); stage.className = 'stage' + (opt.nochrome ? ' nochrome' : '');
    stage.innerHTML = '<div class="bg"></div><img class="wm" src="assets/monograma-m.png" alt=""><div class="layer"></div>' +
      '<div class="chrome"><div class="bar"></div><img src="assets/logo-monterroso-blanco.png" alt=""><span class="sec"></span><span class="pg"></span></div>';
    frame.appendChild(stage); container.appendChild(frame);
    const fit = () => { const k = Math.min(frame.clientWidth / 1920, frame.clientHeight / 1080); stage.style.transform = 'scale(' + k + ')'; stage.style.left = ((frame.clientWidth - 1920 * k) / 2) + 'px'; stage.style.top = ((frame.clientHeight - 1080 * k) / 2) + 'px'; };
    new ResizeObserver(fit).observe(frame); fit();
    return { frame, stage, layer: $('.layer', stage) };
  }
  function setChrome(f, i) {
    const s = SL[i], sec = s.sec >= 0 ? SECS[s.sec] : null;
    $('.sec', f.stage).textContent = sec ? sec.k + ' · ' + sec.name : '';
    $('.pg', f.stage).textContent = (i + 1) + ' / ' + T;
    $('.bar', f.stage).style.width = (i / (T - 1) * 100) + '%';
    f.stage.classList.toggle('nochrome', !!s.nochrome);
  }

  /* ---------- estado y sincronización ---------- */
  let state = { i: 0, step: 0, black: false, ts: 0 };
  const saved = (() => { try { return JSON.parse(store.get(KEY) || 'null'); } catch (e) { return null; } })();
  if (saved && typeof saved.i === 'number') state = saved;
  const CH = ('BroadcastChannel' in window) ? new BroadcastChannel('mdpp-deck-v1') : null;
  let winAud = null, lastSeen = 0, live = false;

  function publish() {
    state.ts = Date.now() + Math.random();
    store.set(KEY, JSON.stringify(state));
    if (CH) CH.postMessage({ t: 'state', s: state });
    if (winAud && !winAud.closed) { try { winAud.postMessage({ t: 'state', s: state }, '*'); } catch (e) { /* ventana cerrada */ } }
    if (window.opener && ROLE === 'audience') { /* el visualizador no emite estado propio salvo teclado */ try { window.opener.postMessage({ t: 'state', s: state }, '*'); } catch (e) { /* sin opener */ } }
  }
  function remote(s) {
    if (!s) return;
    if (s.ts && s.ts <= state.ts) { noteLive(); return; }
    state = s; render(); noteLive();
  }
  function noteLive() { live = true; lastSeen = Date.now(); const st = $('#status'); if (st) { st.textContent = 'Visualizador conectado'; st.classList.add('live'); } }
  if (CH) CH.onmessage = e => {
    const d = e.data;
    if (d.t === 'state') remote(d.s);
    else if (d.t === 'hello' && ROLE === 'presenter') { CH.postMessage({ t: 'state', s: state }); noteLive(); }
  };
  window.addEventListener('storage', e => { if (e.key === KEY && e.newValue) { try { remote(JSON.parse(e.newValue)); } catch (er) { /* json inválido */ } } });
  window.addEventListener('message', e => {
    const d = e.data || {};
    if (d.t === 'state') remote(d.s);
    else if (d.t === 'hello' && ROLE === 'presenter') { try { e.source.postMessage({ t: 'state', s: state }, '*'); } catch (er) { /* sin origen */ } noteLive(); }
  });

  /* ---------- navegación ---------- */
  function go(i, step, silent) {
    i = Math.max(0, Math.min(T - 1, i));
    step = Math.max(0, Math.min(SL[i].steps, step == null ? 0 : step));
    state.i = i; state.step = step;
    if (ROLE === 'presenter' && !silent) startTimer();
    render(); publish();
  }
  const next = () => { const s = SL[state.i]; if (state.step < s.steps) go(state.i, state.step + 1); else if (state.i < T - 1) go(state.i + 1, 0); };
  const prev = () => { if (state.step > 0) go(state.i, state.step - 1); else if (state.i > 0) go(state.i - 1, SL[state.i - 1].steps); };

  /* ---------- render ---------- */
  let main, shown = -1;
  function render() {
    const f = main;
    if (state.i !== shown) {
      const dir = state.i >= shown ? 'fwd' : 'back';
      const old = $('.slide:not(.leave)', f.layer);
      const el = build(state.i, state.step, 'live');
      if (shown >= 0) el.classList.add('enter-' + dir); else el.classList.add('enter-fwd');
      f.layer.appendChild(el);
      if (old) { old.classList.add('leave'); setTimeout(() => old.remove(), 900); }
      shown = state.i; setChrome(f, state.i);
    } else {
      const el = $('.slide:not(.leave)', f.layer);
      if (el) applyStep(el, state.step, true);
    }
    const bl = $('#black'); if (bl) bl.classList.toggle('on', !!state.black);
    if (ROLE === 'presenter') renderPresenter();
    document.title = (ROLE === 'presenter' ? 'Presentador · ' : '') + 'Contabilidad de un Partido Político';
  }

  /* ---------- vista del presentador ---------- */
  let nextF, gridBuilt = false;
  function fmtT(sec) { const s = Math.abs(Math.round(sec)); const h = Math.floor(s / 3600), m = Math.floor(s % 3600 / 60), r = s % 60; return (h ? h + ':' + String(m).padStart(2, '0') : String(m)) + ':' + String(r).padStart(2, '0'); }
  let t0 = null, paused = false, accum = 0;
  (function loadTimer() { try { const o = JSON.parse(store.get(KT) || 'null'); if (o) { t0 = o.t0; accum = o.accum || 0; paused = !!o.paused; } } catch (e) { /* sin temporizador */ } })();
  function saveTimer() { store.set(KT, JSON.stringify({ t0, accum, paused })); }
  function startTimer() { if (t0 == null && !paused) { t0 = Date.now(); saveTimer(); } }
  const elapsed = () => accum + (t0 != null && !paused ? (Date.now() - t0) / 1000 : 0);
  function toggleTimer() {
    if (t0 == null && !paused) { t0 = Date.now(); }
    else if (paused) { t0 = Date.now(); paused = false; }
    else { accum = elapsed(); t0 = null; paused = true; }
    saveTimer(); tickClock();
  }
  function resetTimer() { t0 = null; accum = 0; paused = false; saveTimer(); tickClock(); }
  function tickClock() {
    if (ROLE !== 'presenter') return;
    const e = elapsed(), planned = plannedBefore(state.i) * 60;
    $('#tElapsed').textContent = fmtT(e);
    $('#tLeft').textContent = (e > TOTAL_MIN * 60 ? '-' : '') + fmtT(TOTAL_MIN * 60 - e);
    $('#tClock').textContent = new Date().toLocaleTimeString('es-GT', { hour: '2-digit', minute: '2-digit' });
    const box = $('#tPace'), d = e - planned, started = e > 5;
    box.classList.remove('ok', 'late', 'early');
    if (!started) { $('#tPaceV').textContent = '—'; } else if (d > 60) { box.classList.add('late'); $('#tPaceV').textContent = '+' + fmtT(d); } else if (d < -60) { box.classList.add('early'); $('#tPaceV').textContent = '-' + fmtT(d); } else { box.classList.add('ok'); $('#tPaceV').textContent = 'a tiempo'; }
    $('#btnTimer').textContent = paused ? 'Reanudar' : (t0 == null ? 'Iniciar reloj' : 'Pausar reloj');
  }
  function renderPresenter() {
    const s = SL[state.i];
    $('#nTitle').textContent = s.t || '';
    $('#nBody').innerHTML = s.notes || '<p>Sin notas.</p>';
    $('#nMeta').textContent = 'Tiempo sugerido: ' + (s.m < 1 ? Math.round(s.m * 60) + ' s' : s.m + ' min') + ' · acumulado previsto ' + Math.round(plannedBefore(state.i)) + ' min de ' + Math.round(TOTAL_MIN);
    $('#cnt').innerHTML = '<b>' + (state.i + 1) + '</b> / ' + T + (s.steps ? ' · paso <b>' + state.step + '</b> / ' + s.steps : '');
    $('#steps').innerHTML = s.steps ? Array.from({ length: s.steps + 1 }, (_, k) => '<i class="' + (k <= state.step ? 'on ' : '') + (k === state.step ? 'cur' : '') + '"></i>').join('') + '<span>&nbsp;pasos</span>' : '<span>Sin pasos: una sola pantalla</span>';
    $$('#secbar button').forEach(b => b.classList.toggle('on', +b.dataset.sec === s.sec));
    // siguiente
    const last = state.i === T - 1 && state.step === s.steps;
    let ni = state.i, ns = state.step, lab = 'Siguiente paso';
    if (state.step < s.steps) ns = state.step + 1; else if (state.i < T - 1) { ni = state.i + 1; ns = 0; lab = 'Siguiente diapositiva'; }
    $('#nextLab').firstChild.textContent = last ? 'Fin de la presentación' : lab;
    $('#nextTtl').textContent = last ? '' : (SL[ni].t || '');
    nextF.layer.replaceChildren();
    if (!last) { nextF.layer.appendChild(build(ni, ns, 'static')); setChrome(nextF, ni); }
    $('#btnBlack').classList.toggle('on', !!state.black);
    tickClock();
  }
  function buildGrid() {
    const g = $('#grid .gg'); g.replaceChildren();
    SL.forEach((s, i) => {
      const b = document.createElement('button'); b.className = 'gi'; b.type = 'button'; b.dataset.i = i;
      const holder = document.createElement('div'); b.appendChild(holder);
      const f = makeFrame(holder); f.layer.appendChild(build(i, s.steps, 'static')); setChrome(f, i);
      const sp = document.createElement('span'); sp.textContent = (i + 1) + '. ' + (s.t || ''); b.appendChild(sp);
      b.addEventListener('click', () => { go(i, 0); toggleGrid(false); });
      g.appendChild(b);
    });
    gridBuilt = true;
  }
  function toggleGrid(on) {
    const gr = $('#grid'); on = on == null ? !gr.classList.contains('on') : on;
    if (on && !gridBuilt) buildGrid();
    gr.classList.toggle('on', on);
    $$('#grid .gi').forEach(b => b.classList.toggle('cur', +b.dataset.i === state.i));
  }

  /* ---------- teclado y arranque ---------- */
  function toggleFS() {
    if (!document.fullscreenElement) (document.documentElement.requestFullscreen || (() => { })).call(document.documentElement); else document.exitFullscreen();
  }
  document.addEventListener('keydown', ev => {
    if (ev.metaKey || ev.ctrlKey || ev.altKey) return;
    const k = ev.key;
    if (['ArrowRight', 'ArrowDown', 'PageDown', ' ', 'Enter'].includes(k)) { ev.preventDefault(); if (ROLE === 'presenter' && k === 'Enter' && $('#grid').classList.contains('on')) return; next(); }
    else if (['ArrowLeft', 'ArrowUp', 'PageUp', 'Backspace'].includes(k)) { ev.preventDefault(); prev(); }
    else if (k === 'Home') go(0, 0);
    else if (k === 'End') go(T - 1, SL[T - 1].steps);
    else if (k === 'b' || k === 'B' || k === '.') { state.black = !state.black; render(); publish(); }
    else if (k === 'f' || k === 'F') toggleFS();
    else if (ROLE === 'presenter' && (k === 'g' || k === 'G')) toggleGrid();
    else if (ROLE === 'presenter' && k === 'Escape') toggleGrid(false);
    else if (ROLE === 'presenter' && (k === '+' || k === '=')) setNfs(2);
    else if (ROLE === 'presenter' && k === '-') setNfs(-2);
    else if (ROLE === 'presenter' && (k === 't' || k === 'T')) toggleTimer();
  });
  let nfs = +(store.get('mdpp-nfs') || 19);
  function setNfs(d) { nfs = Math.max(14, Math.min(34, nfs + d)); store.set('mdpp-nfs', String(nfs)); document.documentElement.style.setProperty('--nfs', nfs + 'px'); }

  function init() {
    if (ROLE === 'audience') {
      main = makeFrame($('#viewport'));
      const hint = $('#hint');
      setTimeout(() => hint && hint.classList.add('gone'), 7000);
      let idle; document.addEventListener('mousemove', () => { document.body.classList.remove('cursorless'); clearTimeout(idle); idle = setTimeout(() => document.body.classList.add('cursorless'), 2200); });
      document.addEventListener('dblclick', toggleFS);
      render();
      setInterval(() => { if (CH) CH.postMessage({ t: 'hello' }); if (window.opener) { try { window.opener.postMessage({ t: 'hello' }, '*'); } catch (e) { /* sin opener */ } } }, 4000);
      if (CH) CH.postMessage({ t: 'hello' });
      if (window.opener) try { window.opener.postMessage({ t: 'hello' }, '*'); } catch (e) { /* sin opener */ }
    } else {
      main = makeFrame($('#curHolder'));
      nextF = makeFrame($('#nextHolder'));
      $('#secbar').innerHTML = SECS.map((s, k) => '<button type="button" data-sec="' + k + '">' + s.k + ' · ' + s.name + '</button>').join('');
      $$('#secbar button').forEach(b => b.addEventListener('click', () => { const i = SL.findIndex(x => x.sec === +b.dataset.sec); go(i, 0); }));
      $('#btnNext').addEventListener('click', next); $('#btnPrev').addEventListener('click', prev);
      $('#btnBlack').addEventListener('click', () => { state.black = !state.black; render(); publish(); });
      $('#btnGrid').addEventListener('click', () => toggleGrid());
      $('#gridClose').addEventListener('click', () => toggleGrid(false));
      $('#btnTimer').addEventListener('click', toggleTimer);
      $('#btnReset').addEventListener('click', resetTimer);
      $('#nPlus').addEventListener('click', () => setNfs(2)); $('#nMinus').addEventListener('click', () => setNfs(-2));
      $('#btnOpen').addEventListener('click', () => { winAud = window.open('index.html', 'mdpp-audience', 'popup,width=1280,height=720'); setTimeout(() => { if (winAud) publish(); }, 900); });
      setNfs(0);
      render(); setInterval(tickClock, 1000);
      setInterval(() => { if (live && Date.now() - lastSeen > 12000) { live = false; const st = $('#status'); if (st) { st.textContent = 'Visualizador sin conectar'; st.classList.remove('live'); } } }, 3000);
    }
    document.fonts && document.fonts.ready.then(() => { });
  }
  window.Deck = { go, next, prev, state: () => state, count: countTo, T };
  init();
});
