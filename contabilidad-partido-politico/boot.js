/* Aplica sobre las páginas del libro los campos editados en Supabase.
   Las páginas con lógica propia (locked) conservan su HTML; el resto toma el HTML de la base. */
window.MDPP_BOOT = (async function () {
  const C = window.MDPP_CONFIG || {};
  const rows = await window.MDPP.fetchItems(C.deck || 'libro-partidos');
  if (!rows) return;
  const map = new Map(rows.map(r => [r.slug, r]));
  Array.from(document.querySelectorAll('#pages > article')).forEach(el => {
    const r = map.get(el.id);
    if (!r) return;
    if (r.published === false) { el.remove(); return; }
    if (r.meta && r.meta.sec) el.setAttribute('data-sec', r.meta.sec);
    if (r.meta && r.meta.secStart) el.setAttribute('data-sec-start', r.meta.secStart);
    if (r.css_class != null) el.className = ('page ' + r.css_class).trim();
    if (!r.locked && r.html) el.innerHTML = r.html;
  });
})().catch(e => console.warn('[MDPP] boot', e));
