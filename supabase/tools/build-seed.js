#!/usr/bin/env node
/* Genera las fases 04 a 06 y la migración completa a partir del contenido REAL del libro y de la presentación.
   Uso (desde la carpeta supabase/):  node tools/build-seed.js
   Regenere los archivos cada vez que cambie el contenido en el código. */
const fs = require('fs'), path = require('path');
const ROOT = path.join(__dirname, '..', '..');
const OUT = path.join(__dirname, '..', 'migrations');
const STAMP = '20261006';

const slugOf = t => String(t || '').normalize('NFD').replace(/[̀-ͯ]/g, '').toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '').slice(0, 80); // idéntico a js/data-source.js

/* literales SQL con dollar-quoting */
const TAG = '$q$';
const lit = s => {
  if (s == null) return 'null';
  s = String(s);
  if (s.includes(TAG)) throw new Error('El contenido contiene ' + TAG);
  return TAG + s + TAG;
};
const num = n => String(Number(n));
const bool = b => (b ? 'true' : 'false');

/* ---------- presentación ---------- */
global.window = {};
for (const f of ['slides-1', 'slides-1b', 'slides-2', 'slides-3', 'slides-4']) {
  new Function('window', fs.readFileSync(path.join(ROOT, 'presentacion-partidos', 'js', f + '.js'), 'utf8'))(global.window);
}
const SL = window.SLIDES, SECS = window.SECTIONS;
const seen = new Set();
const slideRows = SL.map((s, i) => {
  const slug = slugOf(s.t);
  if (seen.has(slug)) throw new Error('Slug duplicado: ' + slug);
  seen.add(slug);
  const locked = !!s.hook || /data-k=/.test(s.html);
  return { pos: i + 1, sec: s.sec >= 0 ? s.sec + 1 : null, slug, title: s.t, minutes: s.m, css: s.cls || '', nochrome: !!s.nochrome, html: s.html, notes: s.notes || null, meta: '{}', locked };
});

/* ---------- libro ---------- */
const bookSrc = fs.readFileSync(path.join(ROOT, 'contabilidad-partido-politico', 'index.html'), 'utf8');
const pagesBlock = bookSrc.slice(bookSrc.indexOf('<div id="pages"'), bookSrc.lastIndexOf('<script src="book.js"'));
const re = /<article class="page([^"]*)" id="([^"]+)"([^>]*)>([\s\S]*?)<\/article>/g;
const attr = (s, n) => { const m = new RegExp(n + '="([^"]*)"').exec(s); return m ? m[1].replace(/&amp;/g, '&') : null; };
const pages = []; let m;
while ((m = re.exec(pagesBlock))) {
  const cls = m[1].trim(), id = m[2], at = m[3], inner = m[4].replace(/^\n/, '').replace(/\n$/, '');
  const sec = attr(at, 'data-sec'), secStart = attr(at, 'data-sec-start');
  const h2 = /<h2[^>]*>([\s\S]*?)<\/h2>/.exec(inner);
  const title = (h2 ? h2[1].replace(/<[^>]+>/g, '').replace(/&amp;/g, '&').trim() : (id === 'portada' ? 'Portada' : id === 'contraportada' ? 'Contraportada' : id)) || id;
  pages.push({ id, cls, sec, secStart, title, inner, locked: /data-gen=|data-calc=|data-check|data-goto=/.test(inner) });
}
if (pages.length < 40) throw new Error('No se leyeron las páginas del libro (' + pages.length + ')');
const bookSections = [];
pages.forEach(p => { if (p.secStart && !bookSections.find(s => s.sec === p.sec)) bookSections.push({ sec: p.sec, roman: (p.sec.split(' · ')[1] ? p.sec.split(' · ')[0] : ''), name: p.sec.includes(' · ') ? p.sec.split(' · ')[1] : p.sec }); });
const bookRows = pages.map((p, i) => {
  const si = bookSections.findIndex(s => s.sec === p.sec);
  return { pos: i + 1, sec: si >= 0 ? si + 1 : null, slug: p.id, title: p.title, minutes: 1, css: p.cls.replace(/\bcover\b|\bback\b/g, w => w).trim(), nochrome: false, html: p.inner, notes: null, meta: JSON.stringify({ sec: p.sec, secStart: p.secStart }), locked: p.locked };
});

/* ---------- SQL ---------- */
function seedSql(deck, sections, rows, header) {
  const sec = sections.map((s, i) => `  (${i + 1}, ${lit(s.roman)}, ${lit(s.name)})`).join(',\n');
  const vals = rows.map(r => `  (${r.pos}, ${r.sec == null ? 'null' : r.sec}, ${lit(r.slug)}, ${lit(r.title)}, ${num(r.minutes)}, ${lit(r.css)}, ${bool(r.nochrome)}, ${lit(r.html)}, ${lit(r.notes)}, ${lit(r.meta)}, ${bool(r.locked)})`).join(',\n');
  return `${header}
begin;

insert into public.mdpp_decks (slug, kind, title, description)
values (${lit(deck.slug)}, ${lit(deck.kind)}, ${lit(deck.title)}, ${lit(deck.desc)})
on conflict (slug) do nothing;

insert into public.mdpp_sections (deck_id, pos, roman, name)
select d.id, v.pos, v.roman, v.name
from public.mdpp_decks d,
(values
${sec}
) as v(pos, roman, name)
where d.slug = ${lit(deck.slug)}
on conflict (deck_id, pos) do nothing;

-- ${rows.length} filas. "do nothing" conserva lo que usted ya haya editado si se vuelve a ejecutar.
insert into public.mdpp_items (deck_id, section_id, pos, slug, title, minutes, css_class, nochrome, html, notes, meta, locked)
select d.id,
       (select s.id from public.mdpp_sections s where s.deck_id = d.id and s.pos = v.sec_pos),
       v.pos, v.slug, v.title, v.minutes, v.css, v.nochrome, v.html, v.notes, v.meta::jsonb, v.locked
from public.mdpp_decks d,
(values
${vals}
) as v(pos, sec_pos, slug, title, minutes, css, nochrome, html, notes, meta, locked)
where d.slug = ${lit(deck.slug)}
on conflict (deck_id, slug) do nothing;

commit;
`;
}

const libro = seedSql({ slug: 'libro-partidos', kind: 'libro', title: 'Contabilidad de un Partido Político · Libro', desc: 'Libro interactivo. Firma de Auditoría Monterroso, Auditores & Consultores.' }, bookSections, bookRows,
  `-- =====================================================================
-- FASE 4 de 6 · SEMILLA DEL LIBRO (${bookRows.length} páginas, ${bookSections.length} secciones). Requiere FASES 1 a 3.
-- Generado por tools/build-seed.js
-- =====================================================================`);
const pres = seedSql({ slug: 'presentacion-partidos', kind: 'presentacion', title: 'Contabilidad de un Partido Político · Presentación', desc: 'Presentación para cañonera con vista de visualizador y de presentador.' }, SECS.map(s => ({ roman: s.k, name: s.name })), slideRows,
  `-- =====================================================================
-- FASE 5 de 6 · SEMILLA DE LA PRESENTACIÓN (${slideRows.length} diapositivas, ${SECS.length} secciones). Requiere FASES 1 a 3.
-- Generado por tools/build-seed.js
-- =====================================================================`);

const verify = `-- =====================================================================
-- FASE 6 de 6 · VERIFICACIÓN. Falla con un mensaje claro si algo no quedó bien.
-- Ejecútela justo después de sembrar (si ya agregó filas propias, el control es "al menos").
-- =====================================================================
do $$
declare n int;
begin
  select count(*) into n from public.mdpp_decks where slug in ('libro-partidos', 'presentacion-partidos');
  if n <> 2 then raise exception 'Se esperaban 2 decks y hay %', n; end if;

  select count(*) into n from public.mdpp_items i join public.mdpp_decks d on d.id = i.deck_id where d.slug = 'libro-partidos';
  if n < ${bookRows.length} then raise exception 'Libro: se esperaban al menos ${bookRows.length} páginas y hay %', n; end if;

  select count(*) into n from public.mdpp_items i join public.mdpp_decks d on d.id = i.deck_id where d.slug = 'presentacion-partidos';
  if n < ${slideRows.length} then raise exception 'Presentación: se esperaban al menos ${slideRows.length} diapositivas y hay %', n; end if;

  select count(*) into n from public.mdpp_sections s join public.mdpp_decks d on d.id = s.deck_id where d.slug = 'presentacion-partidos';
  if n < ${SECS.length} then raise exception 'Presentación: se esperaban ${SECS.length} secciones y hay %', n; end if;

  select count(*) into n from pg_class c join pg_namespace ns on ns.oid = c.relnamespace
   where ns.nspname = 'public' and c.relname in ('mdpp_decks', 'mdpp_sections', 'mdpp_items', 'mdpp_item_versions', 'mdpp_editors') and c.relrowsecurity;
  if n <> 5 then raise exception 'RLS no está activa en las 5 tablas (activas: %)', n; end if;

  select count(*) into n from pg_policies where schemaname = 'public' and tablename like 'mdpp\\_%';
  if n < 8 then raise exception 'Faltan políticas RLS (hay %)', n; end if;

  raise notice 'MIGRACIÓN CORRECTA: decks=2, libro=${bookRows.length}, presentación=${slideRows.length}, RLS activa.';
end $$;

-- Resumen visible
select d.slug, d.kind, count(i.*) as filas, count(*) filter (where i.locked) as bloqueadas, count(*) filter (where not i.published) as ocultas
from public.mdpp_decks d left join public.mdpp_items i on i.deck_id = d.id
group by d.slug, d.kind order by d.slug;
`;

const files = {
  [`${STAMP}_04_seed_libro.sql`]: libro,
  [`${STAMP}_05_seed_presentacion.sql`]: pres,
  [`${STAMP}_06_verify.sql`]: verify
};
for (const [n, c] of Object.entries(files)) fs.writeFileSync(path.join(OUT, n), c);

/* migración completa: fases 01 a 06 en UNA transacción (todo o nada) */
const strip = s => s.replace(/^begin;\s*$/gm, '').replace(/^commit;\s*$/gm, '');
const phases = [`${STAMP}_01_base.sql`, `${STAMP}_02_items.sql`, `${STAMP}_03_security.sql`, `${STAMP}_04_seed_libro.sql`, `${STAMP}_05_seed_presentacion.sql`, `${STAMP}_06_verify.sql`];
const full = `-- =====================================================================
-- MIGRACIÓN COMPLETA · fases 01 a 06 en una sola transacción (todo o nada)
-- Contabilidad de un Partido Político · libro + presentación editables
-- Idempotente. Para reiniciar de cero: ejecute antes 99_reset_DESTRUCTIVO.sql
-- Pegue este archivo completo en Supabase > SQL Editor y ejecútelo.
-- =====================================================================
begin;

${phases.map(p => `-- >>>>>>>>>> ${p}\n` + strip(fs.readFileSync(path.join(OUT, p), 'utf8'))).join('\n')}

commit;
`;
fs.writeFileSync(path.join(OUT, `${STAMP}_00_completa.sql`), full);
/* ---------- migración incremental 07: inscripción de un partido ----------
   Para quien YA ejecutó las fases 1 a 6. Si reinicia de cero no la necesita (la 00 ya la incluye). */
const NEW_SLIDE_TITLES = (() => { const w = {}; new Function('window', fs.readFileSync(path.join(ROOT, 'presentacion-partidos', 'js', 'slides-1b.js'), 'utf8'))(Object.assign(w, { SLIDES: [], H: window.H })); return w.SLIDES.map(s => s.t); })();
const newSlideSlugs = new Set(NEW_SLIDE_TITLES.map(slugOf));
const newBookSlugs = new Set(['inscripcion1', 'inscripcion2']);
const CHANGED_BOOK = ['presentacion', 'indice', 'fin-publico', 'notas'];
function incremental(deckSlug, rows, newSet, changed) {
  const fresh = rows.filter(r => newSet.has(r.slug));
  if (!fresh.length) return '';
  const first = fresh[0];
  const vals = fresh.map(r => `  (${r.pos}, ${r.sec == null ? 'null' : r.sec}, ${lit(r.slug)}, ${lit(r.title)}, ${num(r.minutes)}, ${lit(r.css)}, ${bool(r.nochrome)}, ${lit(r.html)}, ${lit(r.notes)}, ${lit(r.meta)}, ${bool(r.locked)})`).join(',\n');
  const upd = rows.filter(r => changed.includes(r.slug)).map(r => `update public.mdpp_items i set html = ${lit(r.html)} from public.mdpp_decks d where d.id = i.deck_id and d.slug = ${lit(deckSlug)} and i.slug = ${lit(r.slug)} and i.updated_at = i.created_at;`).join('\n');
  const mins = rows.map(r => `  (${lit(r.slug)}, ${num(r.minutes)})`).join(',\n');
  return `
-- ===== ${deckSlug}: ${fresh.length} filas nuevas =====
do $$
declare d uuid;
begin
  select id into d from public.mdpp_decks where slug = ${lit(deckSlug)};
  if d is null then raise exception 'No existe el deck ${deckSlug}. Ejecute antes las fases 1 a 6.'; end if;
  -- Hace espacio en el orden solo la primera vez (si la fila nueva ya existe, no mueve nada)
  if not exists (select 1 from public.mdpp_items where deck_id = d and slug = ${lit(first.slug)}) then
    update public.mdpp_items set pos = pos + ${fresh.length} where deck_id = d and pos >= ${first.pos};
  end if;
end $$;

insert into public.mdpp_items (deck_id, section_id, pos, slug, title, minutes, css_class, nochrome, html, notes, meta, locked)
select d.id,
       (select s.id from public.mdpp_sections s where s.deck_id = d.id and s.pos = v.sec_pos),
       v.pos, v.slug, v.title, v.minutes, v.css, v.nochrome, v.html, v.notes, v.meta::jsonb, v.locked
from public.mdpp_decks d,
(values
${vals}
) as v(pos, sec_pos, slug, title, minutes, css, nochrome, html, notes, meta, locked)
where d.slug = ${lit(deckSlug)}
on conflict (deck_id, slug) do nothing;
${upd ? '\n-- Páginas existentes cuyo texto cambió (solo si usted no las ha editado)\n' + upd + '\n' : ''}
-- Minutos sugeridos recalculados (solo filas que usted no ha editado)
update public.mdpp_items i set minutes = v.m
from public.mdpp_decks d,
(values
${mins}
) as v(slug, m)
where d.id = i.deck_id and d.slug = ${lit(deckSlug)} and i.slug = v.slug and i.updated_at = i.created_at;
`;
}
const inc = `-- =====================================================================
-- FASE 7 (incremental) · INSCRIPCIÓN DE UN PARTIDO: ${[...newSlideSlugs].length} diapositivas y ${newBookSlugs.size} páginas del libro
-- Úsela SOLO si ya ejecutó las fases 1 a 6 antes de agregar este contenido.
-- Si reinicia de cero con 99_reset + 00_completa, NO la necesita (ya está incluido).
-- Idempotente: no duplica ni pisa lo que usted haya editado.
-- =====================================================================
begin;
-- Las actualizaciones de texto y minutos de filas NO editadas no deben contar como ediciones ni crear historial
alter table public.mdpp_items disable trigger mdpp_items_snapshot;
${incremental('presentacion-partidos', slideRows, newSlideSlugs, [])}
${incremental('libro-partidos', bookRows, newBookSlugs, CHANGED_BOOK)}
alter table public.mdpp_items enable trigger mdpp_items_snapshot;
commit;
`;
fs.writeFileSync(path.join(OUT, `${STAMP}_07_agregar_inscripcion.sql`), inc);

console.log('Libro:', bookRows.length, 'páginas ·', bookSections.length, 'secciones · bloqueadas:', bookRows.filter(r => r.locked).length);
console.log('Presentación:', slideRows.length, 'diapositivas ·', SECS.length, 'secciones · bloqueadas:', slideRows.filter(r => r.locked).length);
console.log('Archivos:', fs.readdirSync(OUT).map(f => f + ' ' + Math.round(fs.statSync(path.join(OUT, f)).size / 1024) + ' KB').join(' | '));
