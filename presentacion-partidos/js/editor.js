/* Editor de contenido (Supabase Auth + REST). Sin dependencias.
   Solo usa la clave anon; las políticas RLS decidan quién puede escribir (tabla mdpp_editors). */
(function () {
  'use strict';
  const $ = (s, r = document) => r.querySelector(s);
  const C = window.MDPP_CONFIG || {};
  const BASE = (C.url || '').replace(/\/$/, '');
  const SKEY = 'mdpp-ed-session';
  const sess = {
    get() { try { return JSON.parse(sessionStorage.getItem(SKEY) || 'null'); } catch (e) { return null; } },
    set(v) { try { sessionStorage.setItem(SKEY, JSON.stringify(v)); } catch (e) { /* sin almacenamiento */ } },
    del() { try { sessionStorage.removeItem(SKEY); } catch (e) { /* sin almacenamiento */ } }
  };
  let session = sess.get();
  let items = [], cur = null, deck = $('#deckSel').value, filter = '';

  /* ---------- utilidades ---------- */
  function toast(msg, err) {
    const t = $('#toast'); t.textContent = msg; t.classList.toggle('err', !!err); t.classList.add('on');
    clearTimeout(toast._t); toast._t = setTimeout(() => t.classList.remove('on'), err ? 5000 : 2200);
  }
  const sameNum = (a, b) => Number(a) === Number(b);

  /* ---------- API ---------- */
  async function refresh() {
    if (!session || !session.refresh) throw new Error('Sesión vencida');
    const r = await fetch(BASE + '/auth/v1/token?grant_type=refresh_token', { method: 'POST', headers: { apikey: C.anonKey, 'Content-Type': 'application/json' }, body: JSON.stringify({ refresh_token: session.refresh }) });
    if (!r.ok) throw new Error('Sesión vencida');
    const d = await r.json();
    session = { access: d.access_token, refresh: d.refresh_token, exp: Date.now() + (d.expires_in || 3600) * 1000, uid: d.user ? d.user.id : session.uid, email: d.user ? d.user.email : session.email };
    sess.set(session);
  }
  async function api(path, opt) {
    opt = opt || {};
    if (session && session.exp - Date.now() < 60000) { try { await refresh(); } catch (e) { logout('Su sesión venció. Entre de nuevo.'); throw e; } }
    const headers = Object.assign({ apikey: C.anonKey, Authorization: 'Bearer ' + (session ? session.access : C.anonKey), 'Content-Type': 'application/json' }, opt.headers || {});
    const res = await fetch(BASE + path, Object.assign({}, opt, { headers }));
    if (!res.ok) {
      let m = 'Error ' + res.status;
      try { const j = await res.json(); m = j.message || j.msg || j.error_description || m; } catch (e) { /* sin cuerpo */ }
      const err = new Error(m); err.status = res.status; throw err;
    }
    const txt = await res.text();
    return txt ? JSON.parse(txt) : null;
  }

  /* ---------- sesión ---------- */
  function showLogin(msg) {
    $('#app').hidden = true; $('#login').hidden = false;
    $('#loginMsg').textContent = msg || '';
    $('#password').value = '';
    setTimeout(() => $('#email').focus(), 50);
  }
  function logout(msg) { session = null; sess.del(); cur = null; items = []; showLogin(msg); }
  async function login(email, password) {
    const r = await fetch(BASE + '/auth/v1/token?grant_type=password', { method: 'POST', headers: { apikey: C.anonKey, 'Content-Type': 'application/json' }, body: JSON.stringify({ email, password }) });
    const d = await r.json().catch(() => ({}));
    if (!r.ok) {
      const code = d.error_code || d.error || '';
      throw new Error(/invalid|credentials/i.test(code + (d.msg || '')) ? 'Correo o contraseña incorrectos.' : (d.msg || d.error_description || 'No se pudo iniciar sesión.'));
    }
    session = { access: d.access_token, refresh: d.refresh_token, exp: Date.now() + (d.expires_in || 3600) * 1000, uid: d.user.id, email: d.user.email };
    sess.set(session);
  }
  async function checkEditor() {
    const rows = await api('/rest/v1/mdpp_editors?select=role&user_id=eq.' + encodeURIComponent(session.uid));
    return rows && rows[0] ? rows[0].role : null;
  }
  async function enter() {
    let role = null;
    try { role = await checkEditor(); } catch (e) { role = null; }
    if (!role) { logout('Esta cuenta no está autorizada como editora. Pida que la agreguen a mdpp_editors.'); return; }
    $('#login').hidden = true; $('#app').hidden = false;
    $('#who').textContent = session.email + ' · ' + (role === 'admin' ? 'administrador' : 'editor');
    await loadDeck();
  }

  /* ---------- lista ---------- */
  async function loadDeck() {
    deck = $('#deckSel').value;
    cur = null; $('#form').hidden = true; $('#empty').hidden = false;
    $('#items').replaceChildren(); $('#count').textContent = 'Cargando…';
    try {
      items = await api('/rest/v1/mdpp_items?select=id,pos,slug,title,minutes,css_class,nochrome,html,notes,locked,published,meta,updated_at,mdpp_decks!inner(slug)&mdpp_decks.slug=eq.' + encodeURIComponent(deck) + '&order=pos');
    } catch (e) { toast('No se pudo cargar: ' + e.message, true); items = []; }
    renderList();
    const book = deck.indexOf('libro') === 0;
    $('#notesLabel').hidden = book; $('#f_notes').hidden = book; $('#f_minutes').parentElement.hidden = book;
  }
  function renderList() {
    const ul = $('#items'); ul.replaceChildren();
    const q = filter.trim().toLowerCase();
    const shown = items.filter(i => !q || (i.title + ' ' + i.slug).toLowerCase().includes(q));
    $('#count').textContent = shown.length + ' de ' + items.length + ' ' + (deck.indexOf('libro') === 0 ? 'páginas' : 'diapositivas');
    shown.forEach(i => {
      const li = document.createElement('li'), b = document.createElement('button'); b.type = 'button';
      if (cur && cur.id === i.id) b.className = 'cur';
      const n = document.createElement('span'); n.className = 'n'; n.textContent = i.pos;
      const t = document.createElement('span'); t.className = 't'; t.textContent = i.title;
      if (!i.published) { const g = document.createElement('span'); g.className = 'tag'; g.textContent = 'oculta'; t.appendChild(g); }
      if (i.locked) { const g = document.createElement('span'); g.className = 'tag lock'; g.textContent = 'código'; t.appendChild(g); }
      b.append(n, t); b.addEventListener('click', () => select(i.id)); li.appendChild(b); ul.appendChild(li);
    });
  }

  /* ---------- formulario ---------- */
  const F = { title: $('#f_title'), minutes: $('#f_minutes'), css: $('#f_css'), pub: $('#f_pub'), nochrome: $('#f_nochrome'), notes: $('#f_notes'), html: $('#f_html') };
  function fill(i) {
    F.title.value = i.title || ''; F.minutes.value = i.minutes == null ? '' : i.minutes; F.css.value = i.css_class || '';
    F.pub.checked = !!i.published; F.nochrome.checked = !!i.nochrome; F.notes.value = i.notes || ''; F.html.value = i.html || '';
    F.html.readOnly = !!i.locked; $('#lockedNote').hidden = !i.locked;
    $('#slug').textContent = deck + ' · ' + i.slug + ' · #' + i.pos;
    $('#flags').textContent = 'Última edición: ' + (i.updated_at ? new Date(i.updated_at).toLocaleString('es-GT') : '—');
  }
  function patchFromForm() {
    const p = {};
    if (F.title.value.trim() !== cur.title) p.title = F.title.value.trim();
    if (F.minutes.value !== '' && !sameNum(F.minutes.value, cur.minutes)) p.minutes = Number(F.minutes.value);
    if (F.css.value.trim() !== (cur.css_class || '')) p.css_class = F.css.value.trim();
    if (F.pub.checked !== !!cur.published) p.published = F.pub.checked;
    if (F.nochrome.checked !== !!cur.nochrome) p.nochrome = F.nochrome.checked;
    if (deck.indexOf('libro') !== 0 && F.notes.value !== (cur.notes || '')) p.notes = F.notes.value;
    if (!cur.locked && F.html.value !== (cur.html || '')) p.html = F.html.value;
    return p;
  }
  function updateDirty() {
    if (!cur) return;
    const n = Object.keys(patchFromForm()).length;
    $('#dirty').textContent = n ? '● Cambios sin guardar' : '';
    $('#save').disabled = !n; $('#revert').disabled = !n;
    preview();
  }
  function confirmLeave() { return !cur || !Object.keys(patchFromForm()).length || confirm('Hay cambios sin guardar. ¿Descartarlos?'); }
  async function select(id) {
    if (cur && cur.id !== id && !confirmLeave()) return;
    cur = items.find(i => i.id === id); if (!cur) return;
    $('#empty').hidden = true; $('#form').hidden = false;
    fill(cur); updateDirty(); renderList(); loadVersions();
  }
  async function save(ev) {
    if (ev) ev.preventDefault();
    if (!cur) return;
    const p = patchFromForm();
    if (!Object.keys(p).length) return;
    if (p.title === '') { toast('El título no puede quedar vacío.', true); return; }
    $('#save').disabled = true;
    try {
      const rows = await api('/rest/v1/mdpp_items?id=eq.' + encodeURIComponent(cur.id), { method: 'PATCH', headers: { Prefer: 'return=representation' }, body: JSON.stringify(p) });
      if (!rows || !rows.length) throw new Error('No se guardó: esta cuenta no tiene permiso de escritura.');
      const idx = items.findIndex(i => i.id === cur.id);
      items[idx] = Object.assign({}, items[idx], rows[0]); cur = items[idx];
      fill(cur); updateDirty(); renderList(); loadVersions();
      toast('Guardado');
    } catch (e) { toast(e.message, true); updateDirty(); }
  }

  /* ---------- historial ---------- */
  async function loadVersions() {
    const ul = $('#versions'); ul.replaceChildren();
    if (!cur) return;
    try {
      const rows = await api('/rest/v1/mdpp_item_versions?select=id,title,minutes,html,notes,saved_at&item_id=eq.' + encodeURIComponent(cur.id) + '&order=saved_at.desc&limit=15');
      if (!rows.length) { const li = document.createElement('li'); li.textContent = 'Aún no hay versiones anteriores.'; ul.appendChild(li); return; }
      rows.forEach(v => {
        const li = document.createElement('li'), d = document.createElement('span');
        d.textContent = new Date(v.saved_at).toLocaleString('es-GT') + ' · ' + (v.title || '');
        const b = document.createElement('button'); b.type = 'button'; b.className = 'btn'; b.textContent = 'Cargar en el formulario';
        b.addEventListener('click', () => {
          F.title.value = v.title || F.title.value; if (v.minutes != null) F.minutes.value = v.minutes; F.notes.value = v.notes || '';
          if (!cur.locked) F.html.value = v.html || ''; updateDirty(); toast('Versión cargada. Pulse Guardar para aplicarla.');
        });
        li.append(d, b); ul.appendChild(li);
      });
    } catch (e) { const li = document.createElement('li'); li.textContent = 'No se pudo leer el historial: ' + e.message; ul.appendChild(li); }
  }

  /* ---------- vista previa (iframe aislado, sin scripts) ---------- */
  function preview() {
    if (!cur) return;
    const book = deck.indexOf('libro') === 0;
    const base = new URL('./', location.href).href;
    const cls = F.css.value.trim();
    const w = book ? 560 : 1920, h = book ? 780 : 1080;
    const html = F.html.value;
    const doc = book
      ? `<!doctype html><html><head><meta charset="utf-8"><base href="${base}"><link rel="stylesheet" href="../contabilidad-partido-politico/styles.css"><style>html,body{margin:0;height:auto;overflow:hidden;background:#2a241b}#pages{display:block}</style></head><body><article class="page ${cls.replace(/"/g, '')}" style="width:560px;height:780px">${html}</article></body></html>`
      : `<!doctype html><html><head><meta charset="utf-8"><base href="${base}"><link rel="stylesheet" href="deck.css"><style>html,body{margin:0;overflow:hidden;background:#000}</style></head><body><div class="stage ${F.nochrome.checked ? 'nochrome' : ''}" style="position:relative"><div class="bg"></div><div class="layer"><div class="slide static ${cls.replace(/"/g, '')}">${html}</div></div></div></body></html>`;
    const fr = $('#prev'), box = $('#prevFrame');
    fr.style.width = w + 'px'; fr.style.height = h + 'px';
    const k = box.clientWidth / w; fr.style.transform = 'scale(' + k + ')'; box.style.height = (h * k) + 'px';
    fr.srcdoc = doc;
    $('#prevHint').textContent = book ? 'página 560×780' : 'diapositiva 16:9, todos los pasos visibles';
    $('#notesPrev').srcdoc = '<!doctype html><meta charset="utf-8"><style>body{margin:0;font:15px/1.5 Georgia,serif;color:#f4ecd6;background:#17120a}p{margin:0 0 8px}b{color:#f1d089}</style><body>' + (F.notes.value || '<span style="color:#7d7152">Sin notas.</span>') + '</body>';
  }

  /* ---------- eventos ---------- */
  $('#loginForm').addEventListener('submit', async ev => {
    ev.preventDefault();
    const btn = $('#loginBtn'); btn.disabled = true; $('#loginMsg').textContent = '';
    if (!BASE || !C.anonKey) { $('#loginMsg').textContent = 'Falta la URL o la clave en config.js.'; btn.disabled = false; return; }
    try { await login($('#email').value.trim(), $('#password').value); await enter(); }
    catch (e) { $('#loginMsg').textContent = e.message; }
    finally { btn.disabled = false; $('#password').value = ''; }
  });
  $('#logoutBtn').addEventListener('click', () => { if (confirmLeave()) logout(''); });
  $('#deckSel').addEventListener('change', () => { if (!confirmLeave()) { $('#deckSel').value = deck; return; } loadDeck(); });
  $('#search').addEventListener('input', ev => { filter = ev.target.value; renderList(); });
  $('#form').addEventListener('submit', save);
  $('#revert').addEventListener('click', () => { fill(cur); updateDirty(); });
  Object.values(F).forEach(el => el.addEventListener('input', updateDirty));
  Object.values(F).forEach(el => el.addEventListener('change', updateDirty));
  document.addEventListener('keydown', ev => { if ((ev.metaKey || ev.ctrlKey) && ev.key.toLowerCase() === 's') { ev.preventDefault(); save(); } });
  window.addEventListener('beforeunload', ev => { if (cur && Object.keys(patchFromForm()).length) { ev.preventDefault(); ev.returnValue = ''; } });
  window.addEventListener('resize', () => { if (cur) preview(); });

  /* arranque */
  if (!BASE || !C.anonKey) showLogin('Falta la URL o la clave de Supabase en config.js.');
  else if (session && session.access) enter().catch(() => showLogin(''));
  else showLogin('');
})();
