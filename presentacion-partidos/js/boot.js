/* Aplica sobre window.SLIDES los campos editados en Supabase. Las diapositivas con lógica propia (locked) solo cambian título, notas y tiempo. */
window.MDPP_BOOT = (async function () {
  const C = window.MDPP_CONFIG || {};
  const rows = await window.MDPP.fetchItems(C.deck || 'presentacion-partidos');
  if (!rows) return;
  const map = new Map(rows.map(r => [r.slug, r]));
  const SL = window.SLIDES, out = [];
  SL.forEach(s => {
    const r = map.get(window.MDPP.slugOf(s.t));
    if (!r) { out.push(s); return; }
    if (r.published === false) return;
    if (r.title) s.t = r.title;
    if (r.minutes != null) s.m = Number(r.minutes);
    if (r.notes != null) s.notes = r.notes;
    if (r.css_class != null) s.cls = r.css_class;
    if (r.nochrome != null) s.nochrome = r.nochrome;
    if (!r.locked && !s.hook && r.html) s.html = r.html;
    out.push(s);
  });
  SL.splice(0, SL.length, ...out);
})().catch(e => console.warn('[MDPP] boot', e));
