-- =====================================================================
-- MIGRACIÓN COMPLETA · fases 01 a 06 en una sola transacción (todo o nada)
-- Contabilidad de un Partido Político · libro + presentación editables
-- Idempotente. Para reiniciar de cero: ejecute antes 99_reset_DESTRUCTIVO.sql
-- Pegue este archivo completo en Supabase > SQL Editor y ejecútelo.
-- =====================================================================
begin;

-- >>>>>>>>>> 20261006_01_base.sql
-- =====================================================================
-- FASE 1 de 6 · BASE: funciones auxiliares, decks y secciones
-- Proyecto: Contabilidad de un Partido Político (libro + presentación)
-- Idempotente: se puede ejecutar varias veces sin duplicar nada.
-- =====================================================================

create extension if not exists pgcrypto;

-- Mantiene updated_at al día en cada UPDATE
create or replace function public.mdpp_set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at := now();
  return new;
end $$;

-- Un "deck" es una publicación: el libro o la presentación
create table if not exists public.mdpp_decks (
  id          uuid primary key default gen_random_uuid(),
  slug        text not null unique,
  kind        text not null check (kind in ('libro', 'presentacion')),
  title       text not null,
  description text,
  published   boolean not null default true,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

-- Secciones (I a IX, etc.) de cada deck
create table if not exists public.mdpp_sections (
  id         uuid primary key default gen_random_uuid(),
  deck_id    uuid not null references public.mdpp_decks (id) on delete cascade,
  pos        int  not null,
  roman      text not null default '',
  name       text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (deck_id, pos)
);
create index if not exists mdpp_sections_deck_idx on public.mdpp_sections (deck_id, pos);

drop trigger if exists mdpp_decks_updated on public.mdpp_decks;
create trigger mdpp_decks_updated before update on public.mdpp_decks
  for each row execute function public.mdpp_set_updated_at();

drop trigger if exists mdpp_sections_updated on public.mdpp_sections;
create trigger mdpp_sections_updated before update on public.mdpp_sections
  for each row execute function public.mdpp_set_updated_at();


-- >>>>>>>>>> 20261006_02_items.sql
-- =====================================================================
-- FASE 2 de 6 · CONTENIDO: páginas del libro y diapositivas (mdpp_items)
-- y su historial de versiones. Requiere la FASE 1.
-- Campos editables: title, minutes, css_class, nochrome, html, notes, meta, published
-- =====================================================================

create table if not exists public.mdpp_items (
  id         uuid primary key default gen_random_uuid(),
  deck_id    uuid not null references public.mdpp_decks (id) on delete cascade,
  section_id uuid references public.mdpp_sections (id) on delete set null,
  pos        int  not null,                       -- orden dentro del deck
  slug       text not null,                       -- clave estable (no cambiar)
  title      text not null,                       -- título (barra del presentador / índice)
  minutes    numeric(5,2) not null default 1,     -- tiempo sugerido (presentación)
  css_class  text not null default '',            -- clases extra de la página/diapositiva
  nochrome   boolean not null default false,      -- oculta pie y logo (portadas y divisores)
  html       text not null default '',            -- contenido HTML editable
  notes      text,                                -- notas del presentador (presentación)
  meta       jsonb not null default '{}'::jsonb,  -- libro: {"sec": "...", "secStart": "..."}
  locked     boolean not null default false,      -- true = el HTML lo gobierna el código (calculadoras)
  published  boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  updated_by uuid,
  unique (deck_id, slug)
);
create index if not exists mdpp_items_deck_pos_idx on public.mdpp_items (deck_id, pos);
create index if not exists mdpp_items_section_idx  on public.mdpp_items (section_id);

-- Historial: guarda la versión anterior cuando cambia el contenido
create table if not exists public.mdpp_item_versions (
  id       bigint generated always as identity primary key,
  item_id  uuid not null references public.mdpp_items (id) on delete cascade,
  title    text,
  minutes  numeric(5,2),
  html     text,
  notes    text,
  saved_at timestamptz not null default now(),
  saved_by uuid
);
create index if not exists mdpp_item_versions_item_idx on public.mdpp_item_versions (item_id, saved_at desc);

create or replace function public.mdpp_snapshot_item()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if (old.html is distinct from new.html) or (old.notes is distinct from new.notes)
     or (old.title is distinct from new.title) or (old.minutes is distinct from new.minutes) then
    insert into public.mdpp_item_versions (item_id, title, minutes, html, notes, saved_by)
    values (old.id, old.title, old.minutes, old.html, old.notes, auth.uid());
  end if;
  new.updated_at := now();
  new.updated_by := auth.uid();
  return new;
end $$;

drop trigger if exists mdpp_items_snapshot on public.mdpp_items;
create trigger mdpp_items_snapshot before update on public.mdpp_items
  for each row execute function public.mdpp_snapshot_item();


-- >>>>>>>>>> 20261006_03_security.sql
-- =====================================================================
-- FASE 3 de 6 · SEGURIDAD: editores, RLS y permisos. Requiere FASES 1 y 2.
-- Lectura pública solo de lo publicado; escritura solo para editores.
-- =====================================================================

create table if not exists public.mdpp_editors (
  user_id    uuid primary key references auth.users (id) on delete cascade,
  email      text,
  role       text not null default 'editor' check (role in ('admin', 'editor')),
  created_at timestamptz not null default now()
);

create or replace function public.mdpp_is_editor()
returns boolean language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.mdpp_editors e where e.user_id = auth.uid());
$$;

create or replace function public.mdpp_is_admin()
returns boolean language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.mdpp_editors e where e.user_id = auth.uid() and e.role = 'admin');
$$;

alter table public.mdpp_decks         enable row level security;
alter table public.mdpp_sections      enable row level security;
alter table public.mdpp_items         enable row level security;
alter table public.mdpp_item_versions enable row level security;
alter table public.mdpp_editors       enable row level security;

-- Lectura pública (anon y authenticated): solo lo publicado
drop policy if exists mdpp_decks_read on public.mdpp_decks;
create policy mdpp_decks_read on public.mdpp_decks
  for select to anon, authenticated using (published or public.mdpp_is_editor());

drop policy if exists mdpp_sections_read on public.mdpp_sections;
create policy mdpp_sections_read on public.mdpp_sections
  for select to anon, authenticated
  using (exists (select 1 from public.mdpp_decks d where d.id = deck_id and (d.published or public.mdpp_is_editor())));

drop policy if exists mdpp_items_read on public.mdpp_items;
create policy mdpp_items_read on public.mdpp_items
  for select to anon, authenticated
  using (public.mdpp_is_editor()
         or (published and exists (select 1 from public.mdpp_decks d where d.id = deck_id and d.published)));

-- Escritura: solo editores
drop policy if exists mdpp_decks_write on public.mdpp_decks;
create policy mdpp_decks_write on public.mdpp_decks
  for all to authenticated using (public.mdpp_is_editor()) with check (public.mdpp_is_editor());

drop policy if exists mdpp_sections_write on public.mdpp_sections;
create policy mdpp_sections_write on public.mdpp_sections
  for all to authenticated using (public.mdpp_is_editor()) with check (public.mdpp_is_editor());

drop policy if exists mdpp_items_write on public.mdpp_items;
create policy mdpp_items_write on public.mdpp_items
  for all to authenticated using (public.mdpp_is_editor()) with check (public.mdpp_is_editor());

-- Historial: solo editores (lectura y restauración)
drop policy if exists mdpp_versions_read on public.mdpp_item_versions;
create policy mdpp_versions_read on public.mdpp_item_versions
  for select to authenticated using (public.mdpp_is_editor());

-- Editores: cada quien ve su fila; solo admins administran
drop policy if exists mdpp_editors_self on public.mdpp_editors;
create policy mdpp_editors_self on public.mdpp_editors
  for select to authenticated using (user_id = auth.uid() or public.mdpp_is_admin());

drop policy if exists mdpp_editors_admin on public.mdpp_editors;
create policy mdpp_editors_admin on public.mdpp_editors
  for all to authenticated using (public.mdpp_is_admin()) with check (public.mdpp_is_admin());

-- Permisos de tabla (RLS decide las filas)
grant usage on schema public to anon, authenticated;
grant select on public.mdpp_decks, public.mdpp_sections, public.mdpp_items to anon, authenticated;
grant insert, update, delete on public.mdpp_decks, public.mdpp_sections, public.mdpp_items to authenticated;
grant select on public.mdpp_item_versions to authenticated;
grant select, insert, update, delete on public.mdpp_editors to authenticated;
revoke all on public.mdpp_editors from anon;
revoke all on public.mdpp_item_versions from anon;


-- ---------------------------------------------------------------------
-- DESPUÉS de crear su usuario en Authentication > Users, ejecute UNA vez
-- (cambie el correo) para volverse administrador:
--
--   insert into public.mdpp_editors (user_id, email, role)
--   select id, email, 'admin' from auth.users where email = 'TU_CORREO@DOMINIO.COM'
--   on conflict (user_id) do update set role = 'admin';
-- ---------------------------------------------------------------------

-- >>>>>>>>>> 20261006_04_seed_libro.sql
-- =====================================================================
-- FASE 4 de 6 · SEMILLA DEL LIBRO (48 páginas, 10 secciones). Requiere FASES 1 a 3.
-- Generado por tools/build-seed.js
-- =====================================================================

insert into public.mdpp_decks (slug, kind, title, description)
values ($q$libro-partidos$q$, $q$libro$q$, $q$Contabilidad de un Partido Político · Libro$q$, $q$Libro interactivo. Firma de Auditoría Monterroso, Auditores & Consultores.$q$)
on conflict (slug) do nothing;

insert into public.mdpp_sections (deck_id, pos, roman, name)
select d.id, v.pos, v.roman, v.name
from public.mdpp_decks d,
(values
  (1, $q$I$q$, $q$Antecedentes$q$),
  (2, $q$II$q$, $q$Marco legal$q$),
  (3, $q$III$q$, $q$Financiamiento$q$),
  (4, $q$IV$q$, $q$Cuentas bancarias$q$),
  (5, $q$V$q$, $q$Libros$q$),
  (6, $q$VI$q$, $q$Plan de cuentas$q$),
  (7, $q$VII$q$, $q$Estados financieros$q$),
  (8, $q$VIII$q$, $q$Caso práctico$q$),
  (9, $q$IX$q$, $q$Obligaciones y SAT$q$),
  (10, $q$$q$, $q$Glosario y fuentes$q$)
) as v(pos, roman, name)
where d.slug = $q$libro-partidos$q$
on conflict (deck_id, pos) do nothing;

-- 48 filas. "do nothing" conserva lo que usted ya haya editado si se vuelve a ejecutar.
insert into public.mdpp_items (deck_id, section_id, pos, slug, title, minutes, css_class, nochrome, html, notes, meta, locked)
select d.id,
       (select s.id from public.mdpp_sections s where s.deck_id = d.id and s.pos = v.sec_pos),
       v.pos, v.slug, v.title, v.minutes, v.css, v.nochrome, v.html, v.notes, v.meta::jsonb, v.locked
from public.mdpp_decks d,
(values
  (1, null, $q$portada$q$, $q$Portada$q$, 1, $q$cover$q$, false, $q$  <img class="logo" src="assets/logo-monterroso-blanco.png" alt="Firma de Auditoría Monterroso, Auditores &amp; Consultores">
  <div class="ornament"></div>
  <div class="ct">Guía completa · Guatemala · Edición 2026</div>
  <h1>Contabilidad de un <em>Partido Político</em></h1>
  <p class="sub">Del marco legal a los estados financieros: cómo se registra, se controla y se rinde cuentas ante el Tribunal Supremo Electoral y la SAT.</p>
  <button class="hint" id="cover-open" type="button">Abrir el libro →</button>
  <div class="edition">Material educativo · Actualizado a octubre de 2026</div>$q$, null, $q${"sec":"Portada","secStart":null}$q$, false),
  (2, null, $q$presentacion$q$, $q$Qué encontrará en este libro$q$, 1, $q$$q$, false, $q$  <span class="kicker">Bienvenida</span>
  <h2>Qué encontrará en este libro</h2>
  <p class="lead dropcap">Un partido político en Guatemala es una institución de derecho público, pero maneja dinero público y privado. Por eso su contabilidad no es solo un asunto técnico: es la prueba de que cada quetzal tiene origen conocido, límite respetado y destino justificado.</p>
  <p>Esta guía recorre el tema completo, en orden: la historia de la regulación, las leyes aplicables, cómo se financia un partido, cuánto puede recibir y gastar, qué cuentas bancarias y libros debe llevar, qué plan de cuentas usar y qué estados financieros presentar al TSE. Cierra con un caso práctico completo y con lo que debe hacerse ante la SAT.</p>
  <div class="cols2">
    <div class="card"><h4>Cómo se usa</h4><p>Pase página con las flechas ← →, haciendo clic en los bordes o deslizando el dedo.</p></div>
    <div class="card"><h4>Interactivo</h4><p>Hay calculadoras, partidas desplegables y una lista de cumplimiento que guarda su avance.</p></div>
  </div>
  <div class="note warn"><b>Aviso importante</b>Material educativo, preparado con los textos oficiales vigentes a octubre de 2026. No sustituye asesoría legal ni contable. Las cifras del caso práctico son ficticias. Lo que no pudo confirmarse en texto oficial está marcado <span class="verify">verificar</span>.</div>
  <p class="small">Fuentes principales: Ley Electoral y de Partidos Políticos (LEPP) y sus reglamentos, edición TSE 2026; Instructivo para la Rendición de Cuentas de las Organizaciones Políticas; Ley de Actualización Tributaria; Ley del IVA.</p>$q$, null, $q${"sec":"Presentación","secStart":null}$q$, false),
  (3, null, $q$indice$q$, $q$Índice$q$, 1, $q$$q$, false, $q$  <span class="kicker">Tabla de contenido</span>
  <h2>Índice</h2>
  <ol class="toc">
    <li><a href="#" data-goto="antecedentes"><span><span class="tt">Antecedentes históricos</span><span class="ds">De 1985 a las reformas de 2026</span></span><span class="pg"></span></a></li>
    <li><a href="#" data-goto="piramide"><span><span class="tt">Marco legal y entidad rectora</span><span class="ds">Leyes, reglamentos y la UECFFPP</span></span><span class="pg"></span></a></li>
    <li><a href="#" data-goto="naturaleza"><span><span class="tt">Naturaleza y financiamiento</span><span class="ds">Fuentes, prohibiciones, techos y distribución</span></span><span class="pg"></span></a></li>
    <li><a href="#" data-goto="cuentas-bancarias"><span><span class="tt">Sistema de cuentas bancarias</span><span class="ds">Qué cuentas, para qué y con qué firmas</span></span><span class="pg"></span></a></li>
    <li><a href="#" data-goto="libros-sat"><span><span class="tt">Libros obligatorios</span><span class="ds">Contables y de contribuciones</span></span><span class="pg"></span></a></li>
    <li><a href="#" data-goto="nomenclatura"><span><span class="tt">Plan de cuentas</span><span class="ds">Nomenclatura según el Instructivo del TSE</span></span><span class="pg"></span></a></li>
    <li><a href="#" data-goto="estados"><span><span class="tt">Estados financieros al TSE</span><span class="ds">Contenido, plazos y calendario</span></span><span class="pg"></span></a></li>
    <li><a href="#" data-goto="caso-datos"><span><span class="tt">Caso práctico: Futuro Retalteco</span><span class="ds">Diario, mayor, balance y estados</span></span><span class="pg"></span></a></li>
    <li><a href="#" data-goto="obligaciones"><span><span class="tt">Obligaciones, SAT y cumplimiento</span><span class="ds">Responsables, sanciones, impuestos y lista final</span></span><span class="pg"></span></a></li>
    <li><a href="#" data-goto="glosario"><span><span class="tt">Glosario y fuentes</span><span class="ds">Términos clave y referencias</span></span><span class="pg"></span></a></li>
  </ol>$q$, null, $q${"sec":"Índice","secStart":null}$q$, true),
  (4, 1, $q$antecedentes$q$, $q$Cómo llegamos hasta aquí (1)$q$, 1, $q$$q$, false, $q$  <span class="kicker">Sección I · Antecedentes</span>
  <h2>Cómo llegamos hasta aquí (1)</h2>
  <p>La regulación del dinero de los partidos no nació de golpe. Se construyó por capas, casi siempre después de una crisis de confianza.</p>
  <div class="tl">
    <div class="ev key"><div class="yr">1985</div><p><b>Ley Electoral y de Partidos Políticos, Decreto 1-85</b>, de la Asamblea Nacional Constituyente (aprobada el 3 de diciembre). Es la base legal que sigue vigente, con muchas reformas.</p></div>
    <div class="ev"><div class="yr">1987 y 1989</div><p>Reformas (Decretos 74-87 y 10-89) que ajustan los derechos de los partidos políticos en el artículo 20.</p></div>
    <div class="ev key"><div class="yr">2004</div><p><b>Decreto 10-04.</b> Reforma varios artículos de la ley, entre ellos el 21, que trata el control y la fiscalización del financiamiento.</p></div>
    <div class="ev"><div class="yr">2006</div><p><b>Decreto 35-2006.</b> Vuelve a reformar el artículo 21 y otros relacionados con el financiamiento.</p></div>
    <div class="ev"><div class="yr">2015</div><p>La CICIG publica el informe <i>El financiamiento de la política en Guatemala</i>, que documenta riesgos de dinero opaco e ilícito en las campañas.</p></div>
  </div>$q$, null, $q${"sec":"I · Antecedentes","secStart":"Antecedentes"}$q$, false),
  (5, 1, $q$antecedentes2$q$, $q$Cómo llegamos hasta aquí (2)$q$, 1, $q$$q$, false, $q$  <span class="kicker">Sección I · Antecedentes</span>
  <h2>Cómo llegamos hasta aquí (2)</h2>
  <div class="tl">
    <div class="ev key"><div class="yr">2016</div><p><b>Decreto 26-2016</b> (25 de mayo). La reforma más profunda al financiamiento: crea el financiamiento público ordinario (art. 21 Bis), el techo de campaña, el límite del 10 % por aportante, las listas de prohibiciones, los libros de contribuciones y la <b>Unidad Especializada de Control y Fiscalización</b>.</p></div>
    <div class="ev"><div class="yr">2016</div><p>El TSE emite el Acuerdo 306-2016, Reglamento de Control y Fiscalización de las Finanzas. El Instructivo para la Rendición de Cuentas se elabora con base en él.</p></div>
    <div class="ev key"><div class="yr">2023</div><p><b>Acuerdo 602-2022</b> (emitido el 5 de enero de 2023) deroga el 306-2016 y moderniza el reglamento. El Acuerdo 22-2023 lo reforma el mismo día. El módulo INFOCAM del sistema Cuentas Claras se vuelve obligatorio para el informe de campaña.</p></div>
    <div class="ev key"><div class="yr">2026</div><p><b>26 de febrero.</b> El TSE (Octava Magistratura, 2026-2032) aprueba los Acuerdos 58, 59, 60 y 61-2026. El <b>Acuerdo 60-2026</b> reforma el Reglamento de Control y Fiscalización. Después se coordina el intercambio de información con la Contraloría, la SAT y las Superintendencias.</p></div>
    <div class="ev"><div class="yr">2027</div><p>Elecciones generales. Primer ciclo completo con el reglamento reformado en 2026.</p></div>
  </div>
  <div class="note"><b>La lección</b>Cada reforma agregó una pieza: primero el control, luego los límites, después la tecnología. Hoy la contabilidad del partido es el centro de todo el sistema.</div>$q$, null, $q${"sec":"I · Antecedentes","secStart":null}$q$, false),
  (6, 2, $q$piramide$q$, $q$Las normas, de mayor a menor$q$, 1, $q$$q$, false, $q$  <span class="kicker">Sección II · Marco legal</span>
  <h2>Las normas, de mayor a menor</h2>
  <p>Cuando dos normas parecen chocar, manda la de mayor jerarquía. Así se ordenan las que rigen la contabilidad de un partido:</p>
  <div class="pyr">
    <div class="lv" style="width:46%;background:#e9d08a"><b>Constitución Política</b>Libertad de organización política</div>
    <div class="lv" style="width:62%;background:#efdca3"><b>LEPP, Decreto 1-85</b>arts. 18, 19 Bis, 21 a 21 Quinquies, 22, 88</div>
    <div class="lv" style="width:78%;background:#f3e6bd"><b>Decreto 26-2016</b>La reforma que creó el sistema de financiamiento</div>
    <div class="lv" style="width:92%;background:#f6edd0"><b>Reglamento de Control y Fiscalización</b>Acuerdo 602-2022, reformado por 22-2023 y 60-2026</div>
    <div class="lv" style="width:100%;background:#faf4e2;border:1px solid var(--rule)"><b>Instructivo de Rendición de Cuentas · formatos GR-PRI, INF-FINPU, INFOCAM</b>Nomenclatura, estados y plazos operativos</div>
  </div>
  <div class="note"><b>Y siempre, en paralelo</b>Las leyes fiscales (Código de Comercio, Ley de Actualización Tributaria, Ley del IVA). El Reglamento lo dice expresamente: cumplirlo no releva al partido de sus obligaciones tributarias (art. 29).</div>
  <p class="small">Contabilidad base: Normas Internacionales de Contabilidad y de Información Financiera adoptadas en Guatemala, según el Instructivo.</p>$q$, null, $q${"sec":"II · Marco legal","secStart":"Marco legal"}$q$, false),
  (7, 2, $q$normas-tabla$q$, $q$Qué regula cada norma$q$, 1, $q$$q$, false, $q$  <span class="kicker">Sección II · Marco legal</span>
  <h2>Qué regula cada norma</h2>
  <table class="t">
    <thead><tr><th>Norma</th><th>Qué aporta a la contabilidad</th></tr></thead>
    <tbody>
      <tr><td><b>LEPP</b> art. 21</td><td>El TSE controla y fiscaliza fondos públicos y privados. Cuenta bancaria separada por origen. Acceso permanente del TSE a los libros.</td></tr>
      <tr><td><b>LEPP</b> art. 21 Bis</td><td>Financiamiento público: US$2 por voto. Distribución 30 / 20 / 50.</td></tr>
      <tr><td><b>LEPP</b> art. 21 Ter</td><td>Prohibiciones, recibos SAT, libros de contribuciones, techo de campaña, límite del 10 %, sanciones.</td></tr>
      <tr><td><b>LEPP</b> art. 21 Quáter y Quinquies</td><td>Definiciones (financista, unidad de vinculación) y publicidad 30 días antes de la elección.</td></tr>
      <tr><td><b>LEPP</b> art. 88</td><td>Sanciones: de amonestación a cancelación del partido.</td></tr>
      <tr><td><b>Reglamento</b> Ac. 602-2022</td><td>Contador, informes, cuentas bancarias, recibos, declaración jurada, comprobación de egresos.</td></tr>
      <tr><td><b>Ac. 60-2026</b></td><td>Reforma a los arts. 11, 13, 15, 16, 18, 19 y 20 del Reglamento.</td></tr>
      <tr><td><b>Instructivo</b></td><td>Estados financieros, nomenclatura contable, formatos e informes.</td></tr>
    </tbody>
  </table>
  <div class="note warn"><b>Una corrección que conviene hacer</b>El Acuerdo 306-2016 <b>ya no está vigente</b>: el artículo 33 del Acuerdo 602-2022 lo derogó. El reglamento aplicable hoy es el 602-2022 con sus reformas. El Instructivo publicado todavía cita el 306-2016; úselo para formatos y nomenclatura, pero aplique los artículos y plazos del reglamento vigente.</div>
  <p class="small">En el reglamento vigente, la conservación de registros contables es de cinco años (art. 11); el Instructivo, redactado antes, menciona quince.</p>$q$, null, $q${"sec":"II · Marco legal","secStart":null}$q$, false),
  (8, 2, $q$uecffpp$q$, $q$La Unidad Especializada de Control y Fiscalización$q$, 1, $q$$q$, false, $q$  <span class="kicker">Sección II · Entidad rectora</span>
  <h2>La Unidad Especializada de Control y Fiscalización</h2>
  <p>La <b>UECFFPP</b> es la dependencia del TSE responsable de controlar y fiscalizar las finanzas de las organizaciones políticas. La ley transitoria del Decreto 26-2016 (art. 66) ordenó crearla en un plazo de seis meses.</p>
  <h3>Qué puede hacer <span class="law">Reglamento art. 2</span></h3>
  <ul>
    <li>Fiscalizar en cualquier momento los recursos públicos y privados.</li>
    <li>Practicar auditorías ordinarias y extraordinarias.</li>
    <li>Revisar sedes departamentales y municipales.</li>
    <li>Pedir información a los financistas que figuren en los registros.</li>
  </ul>
  <p class="small">Puede requerir información, bajo reserva de confidencialidad, a la Contraloría General de Cuentas, la SAT y las Superintendencias de Bancos y de Telecomunicaciones (LEPP art. 21).</p>
  <h3>Cómo se desarrolla una fiscalización</h3>
  <div class="flow">
    <div class="st"><b>1</b>Informe preliminar</div>
    <div class="st"><b>2</b>20 días para aclarar (+10)</div>
    <div class="st"><b>3</b>Informe final al Pleno</div>
    <div class="st"><b>4</b>Audiencia de 15 días</div>
    <div class="st"><b>5</b>Resolución</div>
  </div>
  <div class="note"><b>Lo que debe saber el contador</b>Antes de recibir una sanción hay oportunidad de aclarar y de defenderse. Pero los plazos corren: guardar respaldos ordenados es la mejor defensa.</div>
  <p class="small">Plazos según Reglamento arts. 15 y 16. Las sanciones se gradúan por proporcionalidad y razonabilidad.</p>$q$, null, $q${"sec":"II · Marco legal","secStart":null}$q$, false),
  (9, 3, $q$naturaleza$q$, $q$Naturaleza jurídica del partido$q$, 1, $q$$q$, false, $q$  <span class="kicker">Sección III · Naturaleza y financiamiento</span>
  <h2>Naturaleza jurídica del partido</h2>
  <p class="lead">Los partidos políticos son <b>instituciones de derecho público, con personalidad jurídica y duración indefinida</b>, y configuran el carácter democrático del régimen político <span class="law">LEPP art. 18</span>.</p>
  <h3>Cuatro tipos de organización política <span class="law">LEPP art. 16</span></h3>
  <div class="cols2">
    <div class="card"><h4>Partidos políticos</h4><p>Permanentes. Reciben financiamiento público si cumplen el requisito de votos o diputaciones.</p></div>
    <div class="card"><h4>Comités para constituir un partido</h4><p>Informe semestral de ingresos y egresos (INF-COMITÉ).</p></div>
    <div class="card"><h4>Comités cívicos electorales</h4><p>Temporales. Solo financiamiento privado. Informe mensual (INF-COMIT).</p></div>
    <div class="card"><h4>Asociaciones con fines políticos</h4><p>Formación política. No postulan candidatos. Informe semestral.</p></div>
  </div>
  <h3>Qué implica para la contabilidad</h3>
  <ul>
    <li>Su patrimonio se registra <b>íntegramente</b> en la contabilidad: sin títulos al portador ni cuentas anónimas <span class="law">art. 21 Ter d</span>.</li>
    <li>Sus registros contables son <b>públicos</b> <span class="law">art. 21 Ter c</span>.</li>
    <li>Sus dirigentes responden personalmente por el manejo de los fondos <span class="law">art. 19 Bis</span>.</li>
  </ul>$q$, null, $q${"sec":"III · Financiamiento","secStart":"Financiamiento"}$q$, false),
  (10, 3, $q$mapa-fuentes$q$, $q$Mapa de las fuentes$q$, 1, $q$$q$, false, $q$  <span class="kicker">Sección III · Fuentes de financiamiento</span>
  <h2>Mapa de las fuentes</h2>
  <p>Todo ingreso de un partido cae en una de tres categorías. Saber en cuál está decide cómo se registra, dónde se deposita y cuánto se admite.</p>
  <div class="cols2" style="grid-template-columns:1fr">
    <div class="card dark"><h4>Públicas · el Estado</h4><p>Aporte de US$2 por voto legalmente emitido, a partidos con al menos 5 % de votos válidos o una diputación. Se destina por mandato legal (30 / 20 / 50).</p></div>
    <div class="card"><h4>Privadas · personas, afiliados y actividades</h4><p>Cuotas de afiliados, aportes de simpatizantes, autofinanciamiento, productos financieros y aportes en especie. Con recibo SAT, sin anonimato y con límite del 10 % del techo de campaña por aportante.</p></div>
    <div class="card red"><h4>Prohibidas · nunca se aceptan</h4><p>Estados y personas extranjeras; condenados por delitos contra la administración pública o lavado; personas con extinción de dominio; fundaciones apolíticas; aportes anónimos.</p></div>
  </div>
  <div class="note"><b>Regla de oro</b>Cada ingreso se identifica: quién, cuánto, cuándo, en qué forma y de dónde viene. Si no consta en los libros del financista seis meses antes, no se considera procedente <span class="law">art. 21 Ter b</span>.</div>$q$, null, $q${"sec":"III · Financiamiento","secStart":null}$q$, false),
  (11, 3, $q$fin-publico$q$, $q$El aporte del Estado$q$, 1, $q$$q$, false, $q$  <span class="kicker">Financiamiento público</span>
  <h2>El aporte del Estado</h2>
  <p class="lead">El Estado contribuye con el equivalente en quetzales de <b>US$2.00 por voto legalmente emitido</b> a favor del partido <span class="law">art. 21 Bis</span>.</p>
  <h3>Quién tiene derecho</h3>
  <ul>
    <li>Partidos con al menos el <b>5 %</b> de los votos válidos en elecciones generales.</li>
    <li>También los que obtengan <b>al menos una diputación</b> al Congreso, aunque no lleguen al 5 %.</li>
  </ul>
  <p class="small">El cálculo toma la mayor cantidad de votos válidos recibidos: la de presidente y vicepresidente o la del Listado Nacional.</p>
  <h3>Cómo se paga</h3>
  <table class="t">
    <tbody>
      <tr><td>Período</td><td>El período presidencial correspondiente</td></tr>
      <tr><td>Cuotas</td><td>Cuatro cuotas anuales e iguales</td></tr>
      <tr><td>Cuándo</td><td>En julio de cada año</td></tr>
      <tr><td>Año electoral</td><td>Si el partido destina la cuota a campaña, se entrega en <b>enero</b></td></tr>
      <tr><td>Requisito previo</td><td>Certificación del acta del CEN que acredite cómo se distribuyó</td></tr>
      <tr><td>Coalición</td><td>Se reparte según el convenio de coalición</td></tr>
    </tbody>
  </table>
  <div class="note"><b>Ejemplo rápido</b>150,000 votos × US$2 = US$300,000 en cuatro años. Cada año: US$75,000. A Q7.62 por dólar (supuesto): Q571,500 anuales. La calculadora de la página 15 lo hace por usted.</div>$q$, null, $q${"sec":"III · Financiamiento","secStart":null}$q$, false),
  (12, 3, $q$fin-privado$q$, $q$Tipos de aporte y qué significa cada uno$q$, 1, $q$$q$, false, $q$  <span class="kicker">Financiamiento privado</span>
  <h2>Tipos de aporte y qué significa cada uno</h2>
  <table class="t">
    <tbody>
      <tr><td><b>Aportes de afiliados</b></td><td>Cuotas ordinarias o extraordinarias, en dinero o en especie.</td></tr>
      <tr><td><b>Aportes de simpatizantes</b></td><td>De personas no afiliadas, a título propio.</td></tr>
      <tr><td><b>Autofinanciamiento</b></td><td>Cenas, conferencias, espectáculos, sorteos, juegos y otros eventos de recaudación. Debe existir antes un egreso con recursos propios o un aporte en especie.</td></tr>
      <tr><td><b>Productos financieros</b></td><td>Intereses de inversiones hechas con financiamiento privado.</td></tr>
      <tr><td><b>Aporte en dinero</b></td><td>Se canaliza por la organización y se deposita en la cuenta correspondiente.</td></tr>
      <tr><td><b>Aporte en especie</b></td><td>Bien o servicio sin transferencia de dinero. Se acepta por recibo y se <b>justiprecia</b> a valor de mercado.</td></tr>
    </tbody>
  </table>
  <h3>Formas del aporte en especie</h3>
  <div class="cols2">
    <div class="card"><h4>Donación</h4><p>La persona transfiere gratuitamente bienes o derechos.</p></div>
    <div class="card"><h4>Cesión de derechos</h4><p>Se cede la titularidad jurídica de una cosa.</p></div>
  </div>
  <div class="card" style="margin-top:8px"><h4>Comodato o préstamo</h4><p>Uso temporal de un bien, con derecho del dueño a pedirlo de vuelta. Se registra como ingreso y gasto por el valor de alquiler de mercado.</p></div>
  <p class="small" style="margin-top:8px">Los préstamos bancarios o de terceros no son ingreso: son <b>pasivo</b> (Instructivo TSE). Si un acreedor perdona la deuda, se trata como donación y cuenta para el techo.</p>$q$, null, $q${"sec":"III · Financiamiento","secStart":null}$q$, false),
  (13, 3, $q$prohibidas$q$, $q$Lo que un partido nunca debe recibir$q$, 1, $q$$q$, false, $q$  <span class="kicker">Financiamiento prohibido</span>
  <h2>Lo que un partido nunca debe recibir</h2>
  <p>El artículo 21 Ter, literal a, prohíbe recibir contribuciones <b>de cualquier índole</b> provenientes de:</p>
  <ol>
    <li><b>Estados y personas individuales o jurídicas extranjeras.</b> Cierra la puerta a injerencia de otros países.</li>
    <li><b>Condenados por delitos contra la administración pública, lavado de dinero u otros activos</b> y delitos relacionados. Frena la corrupción y el lavado.</li>
    <li><b>Personas con procesos de extinción de dominio</b>, o vinculadas a ellas.</li>
    <li><b>Fundaciones o asociaciones civiles apolíticas y no partidarias.</b> Excepción: aportes de entidades académicas o fundaciones para formación, reportados al TSE dentro de 30 días.</li>
  </ol>
  <h3>Otras prohibiciones</h3>
  <table class="t">
    <tbody>
      <tr><td>Aportes anónimos</td><td>Terminantemente prohibidos <span class="law">Reglamento art. 23</span></td></tr>
      <tr><td>Estado y municipalidades</td><td>Ningún aporte fuera de lo que la ley establece <span class="law">art. 21</span></td></tr>
      <tr><td>Donar al candidato</td><td>Todo se canaliza por la organización política</td></tr>
      <tr><td>Propaganda de una empresa</td><td>Puede costar la cancelación de su personalidad jurídica <span class="law">art. 21 Ter i</span></td></tr>
      <tr><td>Más del 10 %</td><td>Ningún aportante o unidad de vinculación sobre el límite</td></tr>
    </tbody>
  </table>
  <div class="note warn"><b>Consecuencia</b>Quien aporta contraviniendo la ley también queda sujeto al Código Penal <span class="law">art. 88</span>. El contador debe consultar el listado de exclusión de financistas antes de aceptar aportes grandes <span class="law">Reglamento art. 10</span>.</div>$q$, null, $q${"sec":"III · Financiamiento","secStart":null}$q$, false),
  (14, 3, $q$techo$q$, $q$Techo de gastos de campaña$q$, 1, $q$$q$, false, $q$  <span class="kicker">Techos y límites · 1</span>
  <h2>Techo de gastos de campaña</h2>
  <p>Cada organización política puede gastar en campaña, como máximo, el equivalente en quetzales a <b>US$0.50 por ciudadano empadronado</b> al 31 de diciembre del año anterior a las elecciones <span class="law">art. 21 Ter e</span>. En coalición, el límite total no puede superar el monto individual. El TSE puede fijarlo más bajo.</p>
  <div class="calc" data-calc="techo">
    <div class="ct">Calculadora del techo</div>
    <div class="row2">
      <div><label for="te">Ciudadanos empadronados</label><input id="te" class="in-elec" type="number" value="10200000" min="0"></div>
      <div><label for="tt">Quetzales por dólar</label><input id="tt" class="in-tc" type="number" step="0.01" value="7.62" min="0"></div>
    </div>
    <div class="out">
      <div class="lbl">Techo de campaña por organización</div>
      <div class="big o-q">—</div>
      <div class="ln"><span>En dólares</span><span class="o-usd"></span></div>
      <div class="ln"><span>Por ciudadano empadronado</span><span class="o-pc"></span></div>
      <div class="ln"><span>Máximo por aportante (10 %)</span><span class="o-10"></span></div>
    </div>
    <label for="tm">Comité cívico: empadronados del municipio (US$0.10 por ciudadano)</label>
    <input id="tm" class="in-mun" type="number" value="25000" min="0">
    <div class="out" style="margin-top:6px"><div class="ln"><span>Límite del comité cívico</span><span class="o-com"></span></div></div>
  </div>
  <p class="small">Los datos son supuestos. El TSE publica el padrón y fija el techo oficial. La prensa estimó unos Q38.9 millones para 2027 (Q34.9 millones en 2023).</p>
  <p class="small">Lo que cuenta como gasto: propaganda, impresos, encuestas, alquileres temporales, viajes y caravanas, y también los aportes en especie justipreciados <span class="law">Reglamento art. 3 i</span>.</p>$q$, null, $q${"sec":"III · Financiamiento","secStart":null}$q$, true),
  (15, 3, $q$limite-aportante$q$, $q$Límite por aportante y umbrales$q$, 1, $q$$q$, false, $q$  <span class="kicker">Techos y límites · 2</span>
  <h2>Límite por aportante y umbrales</h2>
  <p>Las personas relacionadas o vinculadas, o una sola <b>unidad de vinculación</b>, no pueden aportar en conjunto más del <b>10 %</b> del techo de campaña <span class="law">art. 21 Ter g</span>. Se suman los aportes de empresas del mismo grupo o familia de control.</p>
  <div class="calc" data-calc="aportante">
    <div class="ct">¿Puedo aceptar este aporte?</div>
    <div class="row2">
      <div><label for="at">Techo de campaña (Q)</label><input id="at" class="in-techo" type="number" value="38862000"></div>
      <div><label for="aa">Aporte de esta persona (Q)</label><input id="aa" class="in-aporte" type="number" value="400000"></div>
    </div>
    <label for="av">Aportes de personas vinculadas a ella (Q)</label>
    <input id="av" class="in-vinc" type="number" value="3600000">
    <div class="out">
      <div class="ln"><span>Límite del 10 %</span><span class="o-lim"></span></div>
      <div class="ln"><span>Total de la unidad de vinculación</span><span class="o-tot"></span></div>
      <div class="ln"><span>Uso del límite</span><span class="o-pct"></span></div>
      <div class="o-flags"></div>
    </div>
    <div class="verdict"></div>
  </div>
  <table class="t">
    <thead><tr><th>Umbral</th><th>Qué activa</th></tr></thead>
    <tbody>
      <tr><td>≥ Q30,000 por período fiscal</td><td>El financista debe habilitar sus libros de contribuciones <span class="law">Reglamento art. 20</span></td></tr>
      <tr><td>&gt; Q50,000</td><td>Declaración jurada en acta notarial y pago por banco <span class="law">art. 22</span></td></tr>
      <tr><td>10 % del techo</td><td>Tope por unidad de vinculación <span class="law">art. 21</span></td></tr>
    </tbody>
  </table>
  <p class="small">Los aportes múltiples de una misma persona en el período se consideran una sola transacción.</p>$q$, null, $q${"sec":"III · Financiamiento","secStart":null}$q$, true),
  (16, 3, $q$distribucion$q$, $q$Cómo debe repartirse el aporte público$q$, 1, $q$$q$, false, $q$  <span class="kicker">Distribución obligatoria</span>
  <h2>Cómo debe repartirse el aporte público</h2>
  <div class="calc" data-calc="publico">
    <div class="ct">Calculadora del financiamiento público</div>
    <div class="row2">
      <div><label for="pv">Votos válidos del partido (el mayor)</label><input id="pv" class="in-votos" type="number" value="150000"></div>
      <div><label for="pt">Total de votos válidos</label><input id="pt" class="in-valid" type="number" value="5000000"></div>
    </div>
    <div class="row2">
      <div><label for="pd">Diputaciones obtenidas</label><input id="pd" class="in-dip" type="number" value="1"></div>
      <div><label for="pc">Quetzales por dólar</label><input id="pc" class="in-tc" type="number" step="0.01" value="7.62"></div>
    </div>
    <label class="small" style="display:flex;gap:6px;align-items:center;margin-top:6px"><input class="in-electoral" type="checkbox"> Año electoral: destinar toda la cuota a campaña</label>
    <div class="verdict o-derecho"></div>
    <div class="out">
      <div class="ln"><span>Total en el período (4 años)</span><span class="o-usd4"></span></div>
      <div class="ln"><span>Cuota anual en dólares</span><span class="o-usd1"></span></div>
      <div class="lbl" style="margin-top:4px">Cuota anual en quetzales</div>
      <div class="big o-q1">—</div>
      <div class="o-dist"></div>
    </div>
    <div class="bar"><span style="flex:30;background:#e9d08a">30 %</span><span style="flex:20;background:#b9cde0">20 %</span><span style="flex:50;background:#c9dcb5">50 %</span></div>
  </div>
  <p class="small"><b>30 %</b> formación y capacitación de afiliados · <b>20 %</b> actividades nacionales y sede nacional · <b>50 %</b> funcionamiento en departamentos y municipios, un tercio a los departamentales y dos tercios a los municipales, según el número de empadronados de cada circunscripción <span class="law">art. 21 Bis</span>.</p>
  <div class="note"><b>Cuidado con el Instructivo</b>Un cuadro del Instructivo ilustra la distribución con las etiquetas de 20 y 30 % intercambiadas. Aplique el orden que fija la ley: 30 % formación, 20 % sede nacional.</div>$q$, null, $q${"sec":"III · Financiamiento","secStart":null}$q$, true),
  (17, 3, $q$ejemplo-formal$q$, $q$Un caso completo de financiamiento$q$, 1, $q$$q$, false, $q$  <span class="kicker">Ejemplo formal estructurado</span>
  <h2>Un caso completo de financiamiento</h2>
  <p><b>Futuro Retalteco</b> (partido ficticio) obtuvo 150,000 votos y una diputación en 2023. Veamos qué le toca y qué puede aceptar en 2027. Cifras ilustrativas.</p>
  <table class="t">
    <thead><tr><th>Paso</th><th>Cálculo</th><th class="r">Resultado</th></tr></thead>
    <tbody>
      <tr><td>1. Derecho</td><td>Una diputación (excepción al 5 %)</td><td class="r">Sí</td></tr>
      <tr><td>2. Total del período</td><td>150,000 × US$2</td><td class="r">US$300,000</td></tr>
      <tr><td>3. Cuota anual</td><td>US$300,000 ÷ 4</td><td class="r">US$75,000</td></tr>
      <tr><td>4. En quetzales</td><td>US$75,000 × 7.62</td><td class="r">Q571,500</td></tr>
      <tr><td>5. Formación 30 %</td><td>Q571,500 × 0.30</td><td class="r">Q171,450</td></tr>
      <tr><td>6. Sede nacional 20 %</td><td>Q571,500 × 0.20</td><td class="r">Q114,300</td></tr>
      <tr><td>7. Departamentos y municipios 50 %</td><td>Q571,500 × 0.50</td><td class="r">Q285,750</td></tr>
      <tr><td>&nbsp;&nbsp;↳ Departamentos 1/3</td><td>Q285,750 ÷ 3</td><td class="r">Q95,250</td></tr>
      <tr><td>&nbsp;&nbsp;↳ Municipios 2/3</td><td>Q285,750 × 2 ÷ 3</td><td class="r">Q190,500</td></tr>
    </tbody>
  </table>
  <h3>Y el techo de 2027</h3>
  <table class="t">
    <tbody>
      <tr><td>Techo (10.2 millones × US$0.50 × 7.62)</td><td class="r">Q38,862,000</td></tr>
      <tr><td>Máximo por aportante o unidad (10 %)</td><td class="r">Q3,886,200</td></tr>
      <tr><td>Si la cuota 2027 se usa toda en campaña</td><td class="r">Q571,500 cuentan contra el techo</td></tr>
    </tbody>
  </table>$q$, null, $q${"sec":"III · Financiamiento","secStart":null}$q$, false),
  (18, 4, $q$cuentas-bancarias$q$, $q$Cuentas bancarias: obligatorias y separadas$q$, 1, $q$$q$, false, $q$  <span class="kicker">Sección IV · Sistema bancario</span>
  <h2>Cuentas bancarias: obligatorias y separadas</h2>
  <p>Todo el dinero pasa por el sistema bancario. La ley exige contabilizar el ingreso centralizado en cuentas <b>separadas por origen</b> <span class="law">art. 21 a</span>.</p>
  <div class="banks">
    <div class="bank pub"><b>Cuenta de financiamiento público</b>Mínimo una a nivel nacional. Recibe la cuota del Estado.</div>
    <div class="bank pri"><b>Cuenta de financiamiento privado</b>Una a nivel nacional. Cuotas, donaciones y autofinanciamiento.</div>
    <div class="bank cam"><b>Cuenta de campaña electoral</b>Se abre en el último cuatrimestre del año previo y debe estar activa al iniciar el año electoral.</div>
    <div class="bank loc"><b>Cuentas departamentales y municipales</b>Una por organización partidaria vigente, a nombre de su secretario.</div>
  </div>
  <h3>Reglas comunes <span class="law">Reglamento arts. 18 y 19</span></h3>
  <ul>
    <li>A nombre del partido, en cualquier banco del sistema, con <b>firmas mancomunadas</b>.</li>
    <li>Aviso escrito a la Unidad Especializada dentro de <b>5 días hábiles</b> de cada apertura.</li>
    <li>La cuenta de campaña se cancela dentro de <b>3 meses</b> de concluido el proceso. Con obligaciones pendientes puede mantenerse hasta 6 meses.</li>
    <li>En año electoral, la cuota pública destinada a campaña se maneja en la cuenta de campaña.</li>
    <li>Cada secretario liquida los fondos <b>trimestralmente</b>, bajo juramento y con facturas.</li>
  </ul>
  <div class="note"><b>Para qué sirve</b>Un depósito bancario deja huella: fecha, monto y origen. Es la forma más simple de demostrar que el dinero existió y de dónde vino.</div>$q$, null, $q${"sec":"IV · Cuentas bancarias","secStart":"Bancos"}$q$, false),
  (19, 4, $q$recibos$q$, $q$Recibos de ingreso y respaldo de gastos$q$, 1, $q$$q$, false, $q$  <span class="kicker">Sección IV · Comprobantes</span>
  <h2>Recibos de ingreso y respaldo de gastos</h2>
  <p>Todo ingreso, en dinero o en especie, se acredita con <b>recibo autorizado por la SAT</b>, impreso por el partido <span class="law">art. 21 Ter b · Reglamento art. 19</span>. Debe incluir como mínimo:</p>
  <div class="cols2">
    <ul class="small" style="margin:0">
      <li>Nombre o razón social</li>
      <li>Afiliado o simpatizante</li>
      <li>NIT y CUI (DPI)</li>
      <li>Dirección</li>
      <li>Descripción y monto</li>
      <li>Declaración de procedencia lícita</li>
    </ul>
    <ul class="small" style="margin:0">
      <li>Valor estimado (justiprecio)</li>
      <li>Fecha del aporte</li>
      <li>Firma y sello del receptor</li>
      <li>Firma del secretario que acepta</li>
    </ul>
  </div>
  <div class="note ok"><b>Justiprecio</b>Si el aporte es en especie y no se justiprecia, la Unidad Especializada pide hacerlo en 5 días; si no es razonable, lo estima con el IPC del INE o precios de mercado.</div>
  <h3>Qué respalda un gasto <span class="law">Reglamento art. 24</span></h3>
  <table class="t">
    <tbody>
      <tr><td>Factura autorizada por la SAT</td><td>Compras y servicios</td></tr>
      <tr><td>Recibos de caja o notas de débito</td><td>De entidades vigiladas por la Superintendencia de Bancos</td></tr>
      <tr><td>Planillas IGSS, libros de salarios</td><td>Sueldos y prestaciones</td></tr>
      <tr><td>Otros que autorice la SAT</td><td></td></tr>
    </tbody>
  </table>
  <p class="small">Todo emitido <b>a nombre de la organización política</b>. Un gasto sin documento legal es un hallazgo seguro.</p>$q$, null, $q${"sec":"IV · Cuentas bancarias","secStart":null}$q$, false),
  (20, 5, $q$libros-sat$q$, $q$Libros contables, habilitados por la SAT$q$, 1, $q$$q$, false, $q$  <span class="kicker">Sección V · Libros obligatorios (1)</span>
  <h2>Libros contables, habilitados por la SAT</h2>
  <p>Los partidos llevan <b>contabilidad centralizada, por partida doble</b>, con registros físicos y electrónicos, respaldados con documentos de soporte. Los libros se habilitan ante la SAT <span class="law">Reglamento art. 11</span>.</p>
  <table class="t">
    <thead><tr><th>Libro</th><th>Qué registra</th><th>Para qué sirve</th></tr></thead>
    <tbody>
      <tr><td><b>Diario</b></td><td>Cada operación, en orden de fecha, con su partida (debe y haber).</td><td>Deja la historia completa y cronológica.</td></tr>
      <tr><td><b>Mayor</b></td><td>Los movimientos agrupados por cuenta.</td><td>Muestra el saldo de cada cuenta.</td></tr>
      <tr><td><b>Inventarios</b></td><td>Bienes y derechos del partido.</td><td>Respalda el patrimonio y el activo fijo.</td></tr>
      <tr><td><b>Estados financieros</b></td><td>Balance, estado de ingresos y egresos, notas.</td><td>Informa la situación a una fecha y el resultado del año.</td></tr>
    </tbody>
  </table>
  <div class="cols2">
    <div class="card"><h4>Libros al día</h4><p>Todas las operaciones asentadas dentro de los dos meses calendario siguientes (Instructivo).</p></div>
    <div class="card"><h4>Conservación</h4><p>Cinco años, ordenados, para la fiscalización (Reglamento art. 11).</p></div>
  </div>
  <div class="note"><b>Contador externo</b>Si el partido contrata contabilidad externa, debe informarlo a la Unidad Especializada en 10 días hábiles. Eso no lo exime de tener toda la documentación disponible.</div>
  <p class="small">Los libros permanecen en la sede central y el TSE tiene acceso permanente a ellos <span class="law">LEPP art. 21 c</span>. La documentación del interior del país debe llegar a la sede central para registrarla centralizada.</p>$q$, null, $q${"sec":"V · Libros","secStart":"Libros"}$q$, false),
  (21, 5, $q$libros-tse$q$, $q$Libros de contribuciones, habilitados por el TSE$q$, 1, $q$$q$, false, $q$  <span class="kicker">Sección V · Libros obligatorios (2)</span>
  <h2>Libros de contribuciones, habilitados por el TSE</h2>
  <p>Además de la contabilidad, la ley exige libros especiales para vigilar <b>quién aporta</b> <span class="law">art. 21 Ter c</span>. Los habilita la Unidad Especializada y se guardan en la sede central.</p>
  <table class="t">
    <thead><tr><th>Libro</th><th>Finalidad</th></tr></thead>
    <tbody>
      <tr><td><b>Contribuciones en efectivo</b></td><td>Anota todo aporte en dinero al partido y lo que un financista da en beneficio de un candidato o aspirante.</td></tr>
      <tr><td><b>Contribuciones en especie</b></td><td>Registra a valor de mercado cada aporte no dinerario, con el criterio de un tercero independiente.</td></tr>
      <tr><td><b>Formación política por entidades extranjeras</b></td><td>Detalla ingresos y gastos de formación financiados desde el exterior.</td></tr>
      <tr><td><b>Formación política por entidades nacionales</b></td><td>Mismo detalle para entidades del país (según el Instructivo).</td></tr>
    </tbody>
  </table>
  <div class="note"><b>Los financistas también llevan libros</b>El aportante que dé Q30,000 o más en un período fiscal debe habilitar los suyos. Con ellos el TSE verifica que el dinero existía seis meses antes.</div>
  <h3>Cómo se complementan</h3>
  <div class="flow">
    <div class="st"><b>Recibo</b>Prueba del aporte</div>
    <div class="st"><b>Libro de contribuciones</b>Quién y cuánto</div>
    <div class="st"><b>Diario y Mayor</b>Registro contable</div>
    <div class="st"><b>Informes</b>Rendición al TSE</div>
  </div>
  <p class="small">Los registros contables de los partidos son públicos. Los informes de financiamiento se publican en el portal del TSE.</p>$q$, null, $q${"sec":"V · Libros","secStart":null}$q$, false),
  (22, 6, $q$nomenclatura$q$, $q$Nomenclatura contable: cómo se codifica$q$, 1, $q$$q$, false, $q$  <span class="kicker">Sección VI · Plan de cuentas (1)</span>
  <h2>Nomenclatura contable: cómo se codifica</h2>
  <p>El Instructivo del TSE ordena las cuentas en <b>cinco niveles</b>. El primer dígito es el grupo; cada dígito adicional afina el detalle.</p>
  <table class="t">
    <thead><tr><th>Dígitos</th><th>Nivel</th><th>Ejemplo</th></tr></thead>
    <tbody>
      <tr><td class="num">1</td><td>Grupo</td><td>1 · Activo</td></tr>
      <tr><td class="num">2</td><td>Subgrupo</td><td>1-1 · Activo corriente</td></tr>
      <tr><td class="num">3</td><td>Cuenta</td><td>1-1-2 · Bancos</td></tr>
      <tr><td class="num">4</td><td>Cuenta principal</td><td>1-1-2-202 · Banco financiamiento privado</td></tr>
      <tr><td class="num">5</td><td>Cuenta auxiliar</td><td>4-2-1-102-01 · Cuotas ordinarias de afiliados</td></tr>
    </tbody>
  </table>
  <h3>Grupo 1 · Activo</h3>
  <table class="t" style="font-size:11.8px">
    <tbody>
      <tr><td class="num">1-1-1</td><td>Efectivo: 101 Caja, 102 Caja chica</td></tr>
      <tr><td class="num">1-1-2</td><td>Bancos: 201 financiamiento público · 202 privado · 203 departamentos · 204 municipios · 205 campaña electoral</td></tr>
      <tr><td class="num">1-1-3</td><td>Cuentas por cobrar: 301 financiamiento público · 302 afiliados · 303 otras</td></tr>
      <tr><td class="num">1-1-4</td><td>Inventarios: materiales electorales, artículos promocionales</td></tr>
      <tr><td class="num">1-1-5</td><td>Gastos pagados por anticipado: seguros, alquileres, proveedores</td></tr>
      <tr><td class="num">1-2-1</td><td>Propiedad, planta y equipo: terrenos, edificios, maquinaria, mobiliario (104), cómputo (105), vehículos (106), herramientas y depreciaciones acumuladas (108 a 113)</td></tr>
      <tr><td class="num">1-2-2</td><td>Intangibles: gastos de organización y su amortización</td></tr>
    </tbody>
  </table>$q$, null, $q${"sec":"VI · Plan de cuentas","secStart":"Plan de cuentas"}$q$, false),
  (23, 6, $q$nom-pasivo$q$, $q$Grupos 2 y 3: Pasivo y Patrimonio$q$, 1, $q$$q$, false, $q$  <span class="kicker">Sección VI · Plan de cuentas (2)</span>
  <h2>Grupos 2 y 3: Pasivo y Patrimonio</h2>
  <h3>Grupo 2 · Pasivo</h3>
  <table class="t" style="font-size:11.8px">
    <tbody>
      <tr><td class="num">2-1 · corriente</td><td>2-1-1 Documentos por pagar · 2-1-2 Cuentas por pagar (proveedores locales 201, del exterior 202) · 2-1-3 Pasivo laboral acumulado (prestaciones 301)</td></tr>
      <tr><td class="num">2-2 · no corriente</td><td>2-2-1 Documentos por pagar a largo plazo · 2-2-2 Cuentas por pagar a largo plazo (201), préstamos bancarios (202) y de terceros (203)</td></tr>
    </tbody>
  </table>
  <p class="small">Un pasivo debe poder exigirse por contrato, letra, pagaré, factura cambiaria u otro documento legal. Se cancela por el sistema bancario, a nombre del proveedor.</p>
  <h3>Grupo 3 · Patrimonio</h3>
  <table class="t" style="font-size:11.8px">
    <tbody>
      <tr><td class="num">3-1-1</td><td>Patrimonio partidario: el activo neto de la organización</td></tr>
      <tr><td class="num">3-2-1</td><td>Resultados acumulados: 101 de ejercicios anteriores · 102 del presente ejercicio</td></tr>
    </tbody>
  </table>
  <div class="note"><b>La ecuación que debe cuadrar siempre</b><span class="num" style="font-size:15px">Activo = Pasivo + Patrimonio</span>. En el Balance de Situación General, el resultado del ejercicio se suma al patrimonio.</div>
  <div class="note ok"><b>Si necesita otra cuenta</b>El Instructivo permite agregarla en el rubro que corresponda, de forma correlativa. No se cambia la codificación de las ya existentes.</div>$q$, null, $q${"sec":"VI · Plan de cuentas","secStart":null}$q$, false),
  (24, 6, $q$nom-ingresos$q$, $q$Grupo 4 · Ingresos$q$, 1, $q$$q$, false, $q$  <span class="kicker">Sección VI · Plan de cuentas (3)</span>
  <h2>Grupo 4 · Ingresos</h2>
  <table class="t" style="font-size:11.8px">
    <tbody>
      <tr><td class="num">4-1</td><td><b>Financiamiento público</b>: 4-1-1-101 Cuota política del año</td></tr>
      <tr><td class="num">4-2</td><td><b>Financiamiento privado</b>: 101 Simpatizantes · 102 Afiliados (01 cuotas ordinarias, 02 extraordinarias) · 103 y 104 Formación nacional y extranjera · 105 Aportes de candidatos</td></tr>
      <tr><td class="num">4-3</td><td><b>Autofinanciamiento</b>: conferencias, espectáculos, sorteos, eventos culturales, desayunos/almuerzos/cenas (105), juegos, otros</td></tr>
      <tr><td class="num">4-4</td><td><b>Otros ingresos</b>: 4-4-1-101 Productos financieros</td></tr>
      <tr><td class="num">4-5</td><td><b>Ingresos no dinerarios · cuentas de control</b></td></tr>
      <tr><td class="num">&nbsp;&nbsp;4-5-1</td><td>Cesión de derechos (de autor, otros)</td></tr>
      <tr><td class="num">&nbsp;&nbsp;4-5-2</td><td>Donación de bienes y servicios: 201 servicios personales · 202 playeras y gorras · 204 material de propaganda · 205 atención de simpatizantes · 207 alimentos · 208 combustibles · 209 transporte · 210 hospedaje · 211 otros</td></tr>
      <tr><td class="num">&nbsp;&nbsp;4-5-3</td><td>Préstamo o comodato: 301 vehículos terrestres · 302 aéreos · 303 marítimos · 304 equipo de audio · 305 bienes muebles o inmuebles · 306 otros</td></tr>
    </tbody>
  </table>
  <div class="note"><b>Cuentas de control</b>Las cuentas 4-5 y 5-3 no mueven bancos. Reflejan el aporte en especie justipreciado, una vez como ingreso y otra como gasto, para vigilar el techo de campaña.</div>$q$, null, $q${"sec":"VI · Plan de cuentas","secStart":null}$q$, false),
  (25, 6, $q$nom-egresos$q$, $q$Grupo 5 · Egresos permanentes$q$, 1, $q$$q$, false, $q$  <span class="kicker">Sección VI · Plan de cuentas (4)</span>
  <h2>Grupo 5 · Egresos permanentes</h2>
  <table class="t" style="font-size:11.6px">
    <tbody>
      <tr><td class="num">5-1-1</td><td><b>Funcionamiento</b>: 101 sueldos y honorarios · 102 a 104 alquiler de sedes (central, departamental, municipal) · 105 agua, luz y teléfono · 106 materiales · 107 mantenimiento · 108 depreciaciones · 109 otros</td></tr>
      <tr><td class="num">5-1-2</td><td><b>Asambleas de ley</b>: 201 a 203 gastos de organización nacionales, departamentales y municipales · 204 medios de comunicación</td></tr>
      <tr><td class="num">5-1-3</td><td><b>Campañas de afiliación</b>: proselitismo nacional (301), departamental (302), municipal (303) · medios (304) · alimentación y hospedaje (305)</td></tr>
      <tr><td class="num">5-1-4</td><td><b>Formación política por entidades extranjeras</b>: organización, material didáctico, capacitadores, alimentación, viáticos</td></tr>
      <tr><td class="num">5-1-5</td><td><b>Formación política por entidades nacionales</b>: 501 organización · 502 material didáctico · 503 capacitadores · 504 alimentación · 505 viáticos</td></tr>
    </tbody>
  </table>
  <p class="small">Los gastos permanentes financian el proselitismo y el funcionamiento en cualquier época, no solo en campaña <span class="law">Reglamento art. 3 h</span>.</p>
  <div class="note"><b>Cómo elegir la cuenta</b>Pregúntese para qué se hizo el gasto, no quién lo cobró. Una cena de recaudación va a campañas de afiliación; los talleres para fiscales, a formación política.</div>$q$, null, $q${"sec":"VI · Plan de cuentas","secStart":null}$q$, false),
  (26, 6, $q$nom-campana$q$, $q$Grupo 5 · Campaña y cuentas de control$q$, 1, $q$$q$, false, $q$  <span class="kicker">Sección VI · Plan de cuentas (5)</span>
  <h2>Grupo 5 · Campaña y cuentas de control</h2>
  <table class="t" style="font-size:11.6px">
    <tbody>
      <tr><td class="num">5-2-1</td><td><b>Propaganda electoral</b>: edición de propaganda, encuestas, alquiler temporal, viajes y hospedaje, caravanas</td></tr>
      <tr><td class="num">5-2-2</td><td><b>Materiales y suministros</b>: mantas, pinturas, plásticos, productos promocionales</td></tr>
      <tr><td class="num">5-2-3</td><td><b>Movilización</b>: transporte en giras y mítines, viáticos, protocolo</td></tr>
      <tr><td class="num">5-2-4</td><td><b>Alquileres</b>: inmuebles, vehículos, mobiliario y equipo</td></tr>
      <tr><td class="num">5-2-5</td><td><b>Honorarios</b>: profesionales, servicios personales, asesores, cursos para candidatos</td></tr>
      <tr><td class="num">5-2-6</td><td><b>Día de votaciones</b>: pago de fiscales, transporte, alimentación, combustibles</td></tr>
      <tr><td class="num">5-3</td><td><b>Egresos no dinerarios · control</b>: espejo de 4-5 (cesión de derechos, donaciones de bienes y servicios, comodatos)</td></tr>
    </tbody>
  </table>
  <div class="note warn"><b>Todo cuenta contra el techo</b>Los gastos 5-2 y los aportes en especie de campaña suman para el límite de US$0.50 por empadronado. Controle el acumulado cada mes.</div>
  <p class="small">Cuando se usa la cuota pública para campaña, esos gastos se consideran también para el techo <span class="law">art. 21 Bis d</span>.</p>$q$, null, $q${"sec":"VI · Plan de cuentas","secStart":null}$q$, false),
  (27, 6, $q$reglas-uso$q$, $q$Reglas de uso y asientos tipo$q$, 1, $q$$q$, false, $q$  <span class="kicker">Sección VI · Plan de cuentas (6)</span>
  <h2>Reglas de uso y asientos tipo</h2>
  <ul>
    <li>Partida doble: todo asiento tiene el mismo total en el debe y en el haber.</li>
    <li>Un aporte en especie se registra por su <b>valor justipreciado</b>, en ingreso y gasto, al recibirlo y usarlo.</li>
    <li>El autofinanciamiento exige un egreso o aporte previo.</li>
  </ul>
  <h3>Cena de recaudación con donación del servicio</h3>
  <details class="partida" open><summary><span>Donación del hotel (100 cenas)</span><span class="num">10,000</span></summary>
    <table><tr><td class="c">5-3-2-206</td><td>Egreso: atención para protocolos</td><td class="d">10,000</td><td class="hh"></td></tr><tr><td class="c">4-5-2-206</td><td class="h">Ingreso: atención para protocolos</td><td class="d"></td><td class="hh">10,000</td></tr></table>
    <div class="gl">Cuentas de control. Respaldo: recibo de donación no dineraria y factura a nombre del partido.</div></details>
  <details class="partida" open><summary><span>Dinero recaudado en la cena</span><span class="num">100,000</span></summary>
    <table><tr><td class="c">1-1-2-202</td><td>Banco financiamiento privado</td><td class="d">100,000</td><td class="hh"></td></tr><tr><td class="c">4-3-1-105</td><td class="h">Desayunos, almuerzos y cenas</td><td class="d"></td><td class="hh">100,000</td></tr></table>
    <div class="gl">Un recibo por cada participante, según su aportación.</div></details>
  <h3>Vehículo prestado en comodato para un acto</h3>
  <details class="partida" open><summary><span>Uso a valor de alquiler de mercado</span><span class="num">8,000</span></summary>
    <table><tr><td class="c">5-3-3-301</td><td>Egreso: vehículos terrestres</td><td class="d">8,000</td><td class="hh"></td></tr><tr><td class="c">4-5-3-301</td><td class="h">Ingreso: vehículos terrestres</td><td class="d"></td><td class="hh">8,000</td></tr></table>
    <div class="gl">Debe llevarse un registro con la integración y especificaciones del bien prestado.</div></details>
  <p class="small">Ejemplos tomados del Instructivo del TSE, con montos ilustrativos.</p>$q$, null, $q${"sec":"VI · Plan de cuentas","secStart":null}$q$, false),
  (28, 7, $q$estados$q$, $q$Qué se presenta y cuándo$q$, 1, $q$$q$, false, $q$  <span class="kicker">Sección VII · Estados financieros al TSE (1)</span>
  <h2>Qué se presenta y cuándo</h2>
  <p>Los partidos presentan estados financieros por el período contable <b>del 1 de enero al 31 de diciembre</b>, dentro de <b>tres meses</b> del cierre <span class="law">Reglamento art. 13</span>.</p>
  <div class="cols2" style="grid-template-columns:1fr 1fr 1fr">
    <div class="card"><h4>Balance de situación general</h4><p>Activo, pasivo y patrimonio a una fecha.</p></div>
    <div class="card"><h4>Estado de ingresos y egresos</h4><p>Financiamiento público y privado, gastos permanentes y de campaña, resultado.</p></div>
    <div class="card"><h4>Notas</h4><p>Descripciones y análisis de las cuentas.</p></div>
  </div>
  <h3>Qué se adjunta</h3>
  <ul>
    <li>Copia digital de los libros <b>Diario y Mayor General</b> y de los libros de contribuciones.</li>
    <li>Certificación del contador general y el secretario de finanzas.</li>
    <li>Revisión del órgano de fiscalización financiera y autorización del representante legal.</li>
    <li>Firma y sello de un contador público y auditor, con su número de colegiado activo.</li>
    <li><b>Dictamen de un contador público y auditor externo</b>, costeado por el partido.</li>
  </ul>
  <div class="note"><b>Balance de apertura</b>La organización inscrita nueva presenta su balance de apertura dentro del mes siguiente a su inscripción, con la misma estructura del balance de situación (Instructivo).</div>
  <p class="small">Los estados se elaboran con NIC y NIIF. Cada documento lleva cinco firmas, según el Instructivo.</p>$q$, null, $q${"sec":"VII · Estados financieros","secStart":"Estados"}$q$, false),
  (29, 7, $q$calendario$q$, $q$Calendario de informes de un partido$q$, 1, $q$$q$, false, $q$  <span class="kicker">Sección VII · Estados financieros al TSE (2)</span>
  <h2>Calendario de informes de un partido</h2>
  <table class="t">
    <thead><tr><th>Informe</th><th>Cuándo</th></tr></thead>
    <tbody>
      <tr><td><b>Estados financieros</b> + libros Diario, Mayor y de contribuciones</td><td>Dentro de 3 meses del cierre (hasta el 31 de marzo)</td></tr>
      <tr><td><b>GR-PRI</b> · financiamiento privado por origen y gastos</td><td>Trimestral, dentro del mes posterior al trimestre. Aprobado por el secretario general</td></tr>
      <tr><td><b>INF-FINPU</b> · uso del financiamiento público</td><td>Semestral, dentro del mes posterior</td></tr>
      <tr><td><b>INFOCAM</b> · financiero de campaña</td><td>Dentro de 3 meses de concluido el proceso electoral</td></tr>
      <tr><td><b>Publicidad</b> · aportes de 2 años, aportes de campaña y balance del último año</td><td>30 días antes de la elección <span class="law">art. 21 Quinquies</span></td></tr>
    </tbody>
  </table>
  <h3>Otras organizaciones</h3>
  <ul class="small">
    <li>Comités cívicos: informe mensual (INF-COMIT).</li>
    <li>Asociaciones con fines políticos y comités para constituir partido: semestral.</li>
  </ul>
  <div class="note ok"><b>Si hay un error</b>GR-PRI, INF-FINPU e INFOCAM pueden rectificarse en el sistema dentro de 30 días de vencido el plazo, pidiendo antes la habilitación a la Unidad Especializada. No se puede si ya inició una auditoría.</div>
  <p class="small">Plataforma: Sistema Cuentas Claras Guatemala, de uso obligatorio para rendir la información <span class="law">Reglamento art. 30</span>. Todos los informes deben certificarse por el contador general y el secretario de finanzas.</p>$q$, null, $q${"sec":"VII · Estados financieros","secStart":null}$q$, false),
  (30, 7, $q$notas$q$, $q$Las notas a los estados financieros$q$, 1, $q$$q$, false, $q$  <span class="kicker">Sección VII · Estados financieros al TSE (3)</span>
  <h2>Las notas a los estados financieros</h2>
  <p>Las elabora el contador. Explican lo que las cifras no dicen. El Instructivo enumera, a manera de guía:</p>
  <table class="t" style="font-size:11.8px">
    <tbody>
      <tr><td class="num">1</td><td><b>Antecedentes</b>: objeto, marco legal, constitución, NIT, fecha y número de inscripción</td></tr>
      <tr><td class="num">2</td><td><b>Principios y prácticas</b>: base de medición, justiprecio, situación tributaria y exenciones</td></tr>
      <tr><td class="num">3</td><td><b>Caja y bancos</b>, con las sedes y restricciones</td></tr>
      <tr><td class="num">4</td><td><b>Cuentas por cobrar</b></td></tr>
      <tr><td class="num">5</td><td><b>Inventarios</b>: a costo de adquisición</td></tr>
      <tr><td class="num">6</td><td><b>Propiedad, planta y equipo</b>: al costo o al precio de mercado si es donación</td></tr>
      <tr><td class="num">7</td><td><b>Documentos y cuentas por pagar</b></td></tr>
      <tr><td class="num">8</td><td><b>Pasivo laboral acumulado</b></td></tr>
      <tr><td class="num">9</td><td><b>Cuentas por pagar a largo plazo</b></td></tr>
      <tr><td class="num">10</td><td><b>Patrimonio</b> y resultados acumulados</td></tr>
      <tr><td class="num">11</td><td><b>Ingresos</b> de afiliados, simpatizantes y autofinanciamiento</td></tr>
      <tr><td class="num">12</td><td><b>Otros ingresos</b>: productos financieros</td></tr>
      <tr><td class="num">13</td><td><b>Egresos</b>: permanentes y de campaña</td></tr>
    </tbody>
  </table>
  <div class="note"><b>Nota 2, el detalle que más se olvida</b>Debe revelar el régimen de impuestos del partido y las exenciones que invoca. Conecta la contabilidad con lo que se verá ante la SAT en la página 42.</div>$q$, null, $q${"sec":"VII · Estados financieros","secStart":null}$q$, false),
  (31, 8, $q$caso-datos$q$, $q$Futuro Retalteco: los datos del caso$q$, 1, $q$$q$, false, $q$  <span class="kicker">Sección VIII · Caso práctico (1)</span>
  <h2>Futuro Retalteco: los datos del caso</h2>
  <p><b>Futuro Retalteco</b> es un partido ficticio con sede nacional en la ciudad de Guatemala y organización vigente en departamentos y municipios, con base en Retalhuleu. Todo lo que sigue aplica la ley y el reglamento vigentes; las cifras son inventadas.</p>
  <table class="t">
    <tbody>
      <tr><td>Inscripción</td><td>Partido inscrito en el Registro de Ciudadanos desde 2022</td></tr>
      <tr><td>Resultado en 2023</td><td>150,000 votos · 1 diputación (derecho a financiamiento público)</td></tr>
      <tr><td>Renovación de órganos</td><td>Asamblea nacional inscrita el 5 de enero de 2026</td></tr>
      <tr><td>Ejercicio que registramos</td><td>1 de enero al 31 de diciembre de 2026</td></tr>
      <tr><td>Tipo de cambio supuesto</td><td>Q7.62 por US$1</td></tr>
      <tr><td>Año siguiente</td><td>2027, elecciones generales (cuenta de campaña por abrir)</td></tr>
    </tbody>
  </table>
  <h3>Qué haremos con el caso</h3>
  <ol>
    <li>Preparar el inicio de actividades del ejercicio.</li>
    <li>Registrar 13 partidas en el <b>Libro Diario</b>.</li>
    <li>Pasarlas al <b>Libro Mayor</b> y sacar la balanza.</li>
    <li>Armar el <b>Balance de Situación General</b> y el <b>Estado de Ingresos y Egresos</b>.</li>
    <li>Verificar límites, distribución y informes por presentar.</li>
  </ol>
  <div class="note"><b>Nota</b>Los asientos del Diario, el Mayor, la balanza y los estados salen de una misma base de datos en este libro, así que siempre cuadran entre sí.</div>$q$, null, $q${"sec":"VIII · Caso práctico","secStart":"Caso práctico"}$q$, false),
  (32, 8, $q$caso-inicio$q$, $q$El inicio de actividades$q$, 1, $q$$q$, false, $q$  <span class="kicker">Sección VIII · Caso práctico (2)</span>
  <h2>El inicio de actividades</h2>
  <p>Antes del primer asiento, el partido cumple las obligaciones de arranque:</p>
  <div class="tl">
    <div class="ev key"><div class="yr">5 ene</div><p>Se inscriben en el Registro de Ciudadanos los órganos permanentes renovados.</p></div>
    <div class="ev"><div class="yr">≤ 20 ene</div><p><b>Nombra contador general</b> dentro de 15 días de la inscripción de los órganos <span class="law">Reglamento art. 12</span>.</p></div>
    <div class="ev"><div class="yr">≤ 10 días hábiles</div><p>Notifica el nombramiento a la Unidad Especializada, con copia del <b>RTU actualizado</b> del contador.</p></div>
    <div class="ev"><div class="yr">Enero</div><p>Habilita ante la SAT los libros contables y ante la UECFFPP los libros de contribuciones.</p></div>
    <div class="ev"><div class="yr">Enero</div><p>Verifica sus cuentas (pública, privada, departamentales y municipales) y avisa cualquier apertura en 5 días hábiles.</p></div>
    <div class="ev key"><div class="yr">1 ene</div><p>Registra el <b>balance de apertura</b> del ejercicio, certificado por contador y secretario de finanzas.</p></div>
  </div>
  <h3>Balance de apertura (Q)</h3>
  <table class="t">
    <tbody>
      <tr><td>Banco financiamiento privado</td><td class="r">50,000</td><td>Patrimonio partidario</td><td class="r">80,000</td></tr>
      <tr><td>Mobiliario y equipo</td><td class="r">30,000</td><td>Pasivo</td><td class="r">0</td></tr>
      <tr class="tot"><td>Activo</td><td class="r">80,000</td><td>Pasivo + patrimonio</td><td class="r">80,000</td></tr>
    </tbody>
  </table>
  <p class="small">Para 2027, la cuenta de campaña debe abrirse entre septiembre y diciembre de 2026 <span class="law">Reglamento art. 19</span>.</p>$q$, null, $q${"sec":"VIII · Caso práctico","secStart":null}$q$, false),
  (33, 8, $q$diario1$q$, $q$Partidas 1 a 5$q$, 1, $q$$q$, false, $q$  <span class="kicker">Libro Diario · 1 de 3</span>
  <h2>Partidas 1 a 5</h2>
  <p class="small">Cifras en quetzales. Toque cada partida para abrir o cerrar la explicación.</p>
  <div data-gen="diario" data-from="1" data-to="5"></div>$q$, null, $q${"sec":"VIII · Caso práctico","secStart":null}$q$, true),
  (34, 8, $q$diario2$q$, $q$Partidas 6 a 9$q$, 1, $q$$q$, false, $q$  <span class="kicker">Libro Diario · 2 de 3</span>
  <h2>Partidas 6 a 9</h2>
  <p class="small">Aquí entra el financiamiento público y se reparte según el artículo 21 Bis.</p>
  <div data-gen="diario" data-from="6" data-to="9"></div>$q$, null, $q${"sec":"VIII · Caso práctico","secStart":null}$q$, true),
  (35, 8, $q$diario3$q$, $q$Partidas 10 a 13$q$, 1, $q$$q$, false, $q$  <span class="kicker">Libro Diario · 3 de 3</span>
  <h2>Partidas 10 a 13</h2>
  <p class="small">Liquidación del 50 % por departamentos y municipios, aporte en especie y cierre.</p>
  <div data-gen="diario" data-from="10" data-to="13"></div>$q$, null, $q${"sec":"VIII · Caso práctico","secStart":null}$q$, true),
  (36, 8, $q$mayor$q$, $q$Cuentas T del ejercicio$q$, 1, $q$$q$, false, $q$  <span class="kicker">Libro Mayor</span>
  <h2>Cuentas T del ejercicio</h2>
  <p>El Mayor toma cada línea del Diario y la acomoda por cuenta: el debe a la izquierda, el haber a la derecha. <i>P4</i> significa «partida 4».</p>
  <div data-gen="mayor"></div>
  <h3>Las cuentas de dinero</h3>
  <div data-gen="mayorfijo"></div>
  <p class="small">Los fondos públicos entran a su cuenta (partida 7), salen a los secretarios (8) y a gastos (9 y 10): terminan en cero. Los departamentales y municipales también se cancelan al liquidar (11).</p>$q$, null, $q${"sec":"VIII · Caso práctico","secStart":null}$q$, true),
  (37, 8, $q$balanza$q$, $q$Sumas iguales$q$, 1, $q$$q$, false, $q$  <span class="kicker">Balanza de comprobación</span>
  <h2>Sumas iguales</h2>
  <p class="small">Antes de armar los estados se verifica que el debe y el haber sumen igual, y que los saldos deudores igualen a los acreedores.</p>
  <div data-gen="balanza"></div>$q$, null, $q${"sec":"VIII · Caso práctico","secStart":null}$q$, true),
  (38, 8, $q$balance$q$, $q$Balance de Situación General$q$, 1, $q$$q$, false, $q$  <span class="kicker">Estado financiero 1 de 2</span>
  <h2>Balance de Situación General</h2>
  <div data-gen="balance"></div>
  <div class="note ok"><b>Cuadra</b>El activo (Q113,000) es igual a pasivo más patrimonio. El patrimonio creció Q33,000, que es el resultado del ejercicio.</div>
  <p class="small">En el Balance conviven bancos, mobiliario y patrimonio. Los fondos públicos y los de departamentos y municipios cerraron en cero porque se gastaron y se liquidaron.</p>$q$, null, $q${"sec":"VIII · Caso práctico","secStart":null}$q$, true),
  (39, 8, $q$estado-ie$q$, $q$Estado de Ingresos y Egresos$q$, 1, $q$$q$, false, $q$  <span class="kicker">Estado financiero 2 de 2</span>
  <h2>Estado de Ingresos y Egresos</h2>
  <div data-gen="estado"></div>
  <p class="small">Los aportes no dinerarios aparecen en ingresos y en egresos por el mismo valor. El resultado es el dinero privado que sobró: Q57,000 de aportes y cena, menos alquiler, costo de la cena y depreciación.</p>$q$, null, $q${"sec":"VIII · Caso práctico","secStart":null}$q$, true),
  (40, 8, $q$caso-verif$q$, $q$¿Cumple Futuro Retalteco?$q$, 1, $q$$q$, false, $q$  <span class="kicker">Verificación final del caso</span>
  <h2>¿Cumple Futuro Retalteco?</h2>
  <div data-gen="kpis"></div>
  <table class="t">
    <thead><tr><th>Control</th><th>Resultado</th></tr></thead>
    <tbody>
      <tr><td>Aporte de Q15,000 frente al límite del 10 % (Q3,886,200)</td><td>Dentro del límite</td></tr>
      <tr><td>Umbrales de Q30,000 y Q50,000</td><td>No se activan</td></tr>
      <tr><td>Recibos SAT para cuotas, donación y cena</td><td>Sí</td></tr>
      <tr><td>Gastos con factura a nombre del partido</td><td>Sí</td></tr>
      <tr><td>Aporte en especie justipreciado</td><td>Sí, Q5,000</td></tr>
      <tr><td>Libros al día (dos meses)</td><td>Sí</td></tr>
    </tbody>
  </table>
  <h3>Informes que debe presentar por 2026</h3>
  <ul class="small">
    <li><b>GR-PRI</b>: abril, julio, octubre y enero.</li>
    <li><b>INF-FINPU</b>: julio y enero.</li>
    <li><b>Estados financieros</b> con Diario, Mayor, libros de contribuciones y dictamen externo: hasta el 31 de marzo de 2027.</li>
  </ul>$q$, null, $q${"sec":"VIII · Caso práctico","secStart":null}$q$, true),
  (41, 9, $q$obligaciones$q$, $q$Quién responde por qué$q$, 1, $q$$q$, false, $q$  <span class="kicker">Sección IX · Obligaciones y responsabilidades</span>
  <h2>Quién responde por qué</h2>
  <p>La información financiera tiene responsables con nombre y firma <span class="law">Reglamento art. 14</span>:</p>
  <table class="t">
    <thead><tr><th>Quién</th><th>Responsabilidad</th></tr></thead>
    <tbody>
      <tr><td><b>Contador general</b></td><td>Llevar la contabilidad y certificar los informes. Nombrado en 15 días; notificado en 10 días hábiles.</td></tr>
      <tr><td><b>Secretario de finanzas</b></td><td>Certifica los informes y entrega los fondos junto con el secretario general.</td></tr>
      <tr><td><b>Órgano de fiscalización financiera</b></td><td>Revisa los informes y reporta anomalías al CEN, que avisa a la Unidad en 5 días.</td></tr>
      <tr><td><b>Secretario general</b></td><td>Aprueba y autoriza; responde personalmente por los fondos públicos <span class="law">art. 21 Bis</span>.</td></tr>
      <tr><td><b>Secretarios departamentales y municipales</b></td><td>Administran y liquidan los fondos que reciben <span class="law">arts. 19 Bis, 21 Ter b</span>.</td></tr>
    </tbody>
  </table>
  <h3>Obligaciones permanentes del partido <span class="law">LEPP art. 22</span></h3>
  <ul class="small">
    <li>Someter libros y documentos a revisión del TSE en cualquier tiempo.</li>
    <li>Abstenerse de ayuda económica o trato preferente del Estado no permitido por la ley.</li>
    <li>Entregar actas de asamblea y cambios de estatutos al Registro de Ciudadanos en 15 días.</li>
    <li>Mantener un registro depurado de afiliados.</li>
  </ul>$q$, null, $q${"sec":"IX · Obligaciones y SAT","secStart":"Obligaciones y SAT"}$q$, false),
  (42, 9, $q$sanciones$q$, $q$Sanciones por incumplir$q$, 1, $q$$q$, false, $q$  <span class="kicker">Sección IX · Consecuencias</span>
  <h2>Sanciones por incumplir</h2>
  <p>El TSE puede imponer, según la gravedad y sin orden fijo, estas sanciones a organizaciones políticas, afiliados y candidatos <span class="law">art. 88</span>:</p>
  <ol>
    <li>Amonestación pública o privada.</li>
    <li>Multa.</li>
    <li>Suspensión temporal.</li>
    <li><b>Suspensión de la facultad de recibir financiamiento público o privado</b>, por contravenir las normas de financiamiento y fiscalización.</li>
    <li><b>Cancelación del partido.</b></li>
  </ol>
  <div class="note warn"><b>Responsabilidad penal</b>Si la infracción constituye posible delito, el TSE certifica lo conducente al Ministerio Público. Quienes aportan contraviniendo la ley también quedan sujetos al Código Penal.</div>
  <h3>Qué se considera infracción en las cuentas</h3>
  <ul>
    <li>No presentar informes en plazo, o presentarlos con anomalías o incongruencias <span class="law">Reglamento art. 14</span>.</li>
    <li>No notificar al contador o contratar contabilidad externa sin avisar.</li>
    <li>Aceptar aportes anónimos, prohibidos o sobre el límite.</li>
    <li>Gastar sin documento legal a nombre del partido.</li>
  </ul>
  <p class="small">El incumplimiento de las normas de financiamiento puede llevar a la cancelación de la personalidad jurídica, incluso de oficio y sin suspensión previa <span class="law">art. 21 Ter k</span>. En la práctica las sanciones se aplican gradualmente, con proporcionalidad y razonabilidad.</p>$q$, null, $q${"sec":"IX · Obligaciones y SAT","secStart":null}$q$, false),
  (43, 9, $q$sat$q$, $q$¿Ante quién se inscribe un partido y qué hace ante la SAT?$q$, 1, $q$$q$, false, $q$  <span class="kicker">Sección IX · Obligaciones ante la SAT (1)</span>
  <h2>¿Ante quién se inscribe un partido y qué hace ante la SAT?</h2>
  <div class="cols2">
    <div class="card dark"><h4>Existencia legal</h4><p>El partido se constituye en escritura pública y se inscribe en el <b>Registro de Ciudadanos del TSE</b>. Ahí obtiene su personalidad jurídica <span class="law">LEPP arts. 18 y 19</span>.</p></div>
    <div class="card"><h4>Existencia tributaria</h4><p>Ante la <b>SAT</b> se inscribe en el Registro Tributario Unificado (RTU) y obtiene su NIT. <span class="verify">verificar trámite vigente</span></p></div>
  </div>
  <h3>Qué debe hacer el partido ante la SAT</h3>
  <ul>
    <li><b>Inscribirse y mantener actualizado el RTU.</b> El NIT va en recibos, facturas y notas a los estados.</li>
    <li><b>Habilitar los libros contables</b> (Diario, Mayor, Inventarios, Estados financieros) <span class="law">Reglamento art. 11</span>.</li>
    <li><b>Hacer autorizar los recibos de ingreso</b> que entregan a cada aportante <span class="law">art. 21 Ter b</span>.</li>
    <li><b>Exigir facturas a su nombre</b> en todo gasto y comprobante legal en toda planilla.</li>
    <li><b>Tramitar la solvencia fiscal</b>, que sus donantes necesitan para deducir sus aportes. <span class="law">LAT art. 23 s</span></li>
    <li>Retener cuando corresponda, porque los partidos son agentes de retención del ISR.</li>
  </ul>
  <div class="note warn"><b>Qué falta confirmar</b>Los detalles del trámite de inscripción, la constancia de exención y los formularios vigentes deben verificarse en el portal de la SAT o con un asesor tributario.</div>$q$, null, $q${"sec":"IX · Obligaciones y SAT","secStart":null}$q$, false),
  (44, 9, $q$sat-impuestos$q$, $q$Impuestos que pueden afectar al partido$q$, 1, $q$$q$, false, $q$  <span class="kicker">Sección IX · Obligaciones ante la SAT (2)</span>
  <h2>Impuestos que pueden afectar al partido</h2>
  <table class="t" style="font-size:11.6px">
    <thead><tr><th>Concepto</th><th>Tratamiento</th><th>Base</th></tr></thead>
    <tbody>
      <tr><td><b>ISR sobre donaciones y cuotas</b></td><td>Renta <b>exenta</b> para partidos y comités cívicos, si el destino es no lucrativo y no distribuyen utilidades.</td><td><span class="law">LAT art. 11 num. 1</span></td></tr>
      <tr><td><b>ISR sobre actividades lucrativas</b></td><td>Las rentas de actividades mercantiles, financieras o de servicios están <b>gravadas</b>; deben declararse. Ejemplo posible: eventos con fin de lucro. <span class="verify">verificar caso por caso</span></td><td><span class="law">LAT art. 11 num. 1</span></td></tr>
      <tr><td><b>Retenciones del ISR</b></td><td>Los partidos son <b>agentes de retención</b>: retienen el 7 % en el régimen opcional simplificado y entregan constancia a los 5 días.</td><td><span class="law">LAT arts. 47, 48, 86</span></td></tr>
      <tr><td><b>IVA sobre cuotas</b></td><td>Los pagos de membresía y cuotas periódicas a partidos políticos están <b>exentos</b>.</td><td><span class="law">Ley del IVA art. 7 num. 10</span></td></tr>
      <tr><td><b>IVA sobre autofinanciamiento</b></td><td>Ventas de entradas, rifas o espectáculos pueden estar afectas. <span class="verify">confirmar con SAT</span></td><td>Ley del IVA</td></tr>
      <tr><td><b>Deducción del donante</b></td><td>No deduce quien dona a un partido sin solvencia fiscal vigente.</td><td><span class="law">LAT art. 23 s</span></td></tr>
      <tr><td><b>Cuotas IGSS</b></td><td>Si hay planilla, se presenta al IGSS y es respaldo del gasto.</td><td><span class="law">Reglamento art. 24 c</span></td></tr>
    </tbody>
  </table>
  <div class="note"><b>Regla práctica</b>Lo que se recibe como aporte, cuota o donación es el corazón de la exención. Lo que se vende como negocio se trata distinto. Registre las dos cosas en cuentas separadas.</div>
  <p class="small">El Reglamento aclara que cumplirlo no releva al partido de las leyes fiscales (art. 29).</p>$q$, null, $q${"sec":"IX · Obligaciones y SAT","secStart":null}$q$, false),
  (45, 9, $q$resumen$q$, $q$Su lista de verificación$q$, 1, $q$$q$, false, $q$  <span class="kicker">Resumen de cumplimiento clave</span>
  <h2>Su lista de verificación</h2>
  <div data-check>
    <ul class="check">
      <li><label><input type="checkbox" data-k="1"><span>Contador general nombrado y notificado a la UECFFPP con RTU</span></label></li>
      <li><label><input type="checkbox" data-k="2"><span>Cuentas separadas: pública, privada, campaña y departamentales/municipales</span></label></li>
      <li><label><input type="checkbox" data-k="3"><span>Firmas mancomunadas y aviso de apertura en 5 días hábiles</span></label></li>
      <li><label><input type="checkbox" data-k="4"><span>Libros contables habilitados por la SAT, al día en dos meses</span></label></li>
      <li><label><input type="checkbox" data-k="5"><span>Libros de contribuciones habilitados por la UECFFPP</span></label></li>
      <li><label><input type="checkbox" data-k="6"><span>Recibo autorizado por la SAT para cada aporte, con los 13 datos</span></label></li>
      <li><label><input type="checkbox" data-k="7"><span>Ningún aporte anónimo, prohibido ni mayor al 10 % del techo</span></label></li>
      <li><label><input type="checkbox" data-k="8"><span>Aportes en especie justipreciados y declaración jurada si superan Q50,000</span></label></li>
      <li><label><input type="checkbox" data-k="9"><span>Financiamiento público distribuido 30 / 20 / 50 con acta certificada del CEN</span></label></li>
      <li><label><input type="checkbox" data-k="10"><span>Fondos departamentales y municipales liquidados cada trimestre</span></label></li>
      <li><label><input type="checkbox" data-k="11"><span>Todo gasto con factura o documento legal a nombre del partido</span></label></li>
      <li><label><input type="checkbox" data-k="12"><span>GR-PRI trimestral e INF-FINPU semestral entregados en plazo</span></label></li>
      <li><label><input type="checkbox" data-k="13"><span>Estados financieros con dictamen externo antes del 31 de marzo</span></label></li>
      <li><label><input type="checkbox" data-k="14"><span>Obligaciones SAT al día: RTU, retenciones y solvencia fiscal</span></label></li>
    </ul>
    <div class="meter"><i></i></div>
    <div class="small"><span class="mlabel"></span> · <button class="reset" type="button" style="background:none;border:0;color:var(--gold);text-decoration:underline;padding:0">reiniciar</button></div>
  </div>$q$, null, $q${"sec":"IX · Obligaciones y SAT","secStart":null}$q$, true),
  (46, 10, $q$glosario$q$, $q$Términos que conviene dominar$q$, 1, $q$$q$, false, $q$  <span class="kicker">Glosario</span>
  <h2>Términos que conviene dominar</h2>
  <table class="t" style="font-size:11.8px">
    <tbody>
      <tr><td><b>CEN</b></td><td>Comité Ejecutivo Nacional del partido.</td></tr>
      <tr><td><b>Financista político</b></td><td>Persona nacional que aporta en dinero o especie, o por contratación fuera de mercado.</td></tr>
      <tr><td><b>Unidad de vinculación</b></td><td>Conjunto de personas con propiedad, administración o control común. Se suma su aporte.</td></tr>
      <tr><td><b>Justiprecio</b></td><td>Valor de mercado asignado a un aporte en especie.</td></tr>
      <tr><td><b>Comodato</b></td><td>Préstamo de uso de un bien.</td></tr>
      <tr><td><b>Autofinanciamiento</b></td><td>Ingresos por actividades propias de recaudación.</td></tr>
      <tr><td><b>Techo de campaña</b></td><td>Límite de gasto electoral: US$0.50 por ciudadano empadronado.</td></tr>
      <tr><td><b>GR-PRI</b></td><td>Informe trimestral del financiamiento privado.</td></tr>
      <tr><td><b>INF-FINPU</b></td><td>Informe semestral del uso del financiamiento público.</td></tr>
      <tr><td><b>INFOCAM</b></td><td>Informe financiero de campaña, del sistema Cuentas Claras.</td></tr>
      <tr><td><b>UECFFPP</b></td><td>Unidad Especializada de Control y Fiscalización de las Finanzas de los Partidos Políticos.</td></tr>
      <tr><td><b>RTU / NIT</b></td><td>Registro Tributario Unificado y número de identificación tributaria de la SAT.</td></tr>
      <tr><td><b>LAT</b></td><td>Ley de Actualización Tributaria, Decreto 10-2012.</td></tr>
    </tbody>
  </table>$q$, null, $q${"sec":"Glosario y fuentes","secStart":"Glosario"}$q$, false),
  (47, 10, $q$fuentes$q$, $q$De dónde sale cada dato$q$, 1, $q$$q$, false, $q$  <span class="kicker">Fuentes y advertencias</span>
  <h2>De dónde sale cada dato</h2>
  <ul class="small">
    <li>TSE de Guatemala. <i>Ley Electoral y de Partidos Políticos y sus Reglamentos, actualización 2026</i> (incluye el Reglamento de Control y Fiscalización, Acuerdo 602-2022, reformado por los Acuerdos 22-2023 y 60-2026). tse.org.gt/images/LEPP2026.pdf</li>
    <li>Congreso de la República. Decreto 26-2016, reformas a la LEPP. tse.org.gt/images/descargas/decreto262016.pdf</li>
    <li>TSE. <i>Instructivo para la Rendición de Cuentas de las Organizaciones Políticas</i>. tse.org.gt/images/UECFFPP/instructivos/rendicion.pdf</li>
    <li>Congreso de la República. Decreto 10-2012, Ley de Actualización Tributaria: arts. 11, 23, 47, 48 y 86.</li>
    <li>Congreso de la República. Decreto 27-92, Ley del IVA: art. 7, numeral 10 (tse.org.gt/images/UECFFPP/leyes).</li>
    <li>CICIG (2015). <i>El financiamiento de la política en Guatemala</i>.</li>
    <li>Prensa Libre y Soy502: estimaciones del techo de campaña 2023 y 2027; La Hora: módulo INFOCAM (Acuerdo 1351-2023).</li>
  </ul>
  <div class="note warn"><b>Antes de aplicar</b>Este libro es didáctico y refleja los textos a octubre de 2026. Las leyes cambian y los acuerdos del TSE también. Confirme siempre el texto vigente y los formularios más recientes con la Unidad Especializada y la SAT.</div>
  <p class="small">Pendiente de confirmar con texto oficial: trámite exacto de inscripción en el RTU, constancia de exención, IVA en autofinanciamiento y texto íntegro de los Acuerdos 58, 59 y 61-2026 (este libro verificó el 60-2026, que reforma la fiscalización).</p>$q$, null, $q${"sec":"Glosario y fuentes","secStart":null}$q$, false),
  (48, null, $q$contraportada$q$, $q$Contraportada$q$, 1, $q$back$q$, false, $q$  <img src="assets/logo-monterroso-blanco.png" alt="Firma de Auditoría Monterroso, Auditores &amp; Consultores">
  <p>Contabilidad, auditoría y consultoría para organizaciones que rinden cuentas.</p>
  <p class="small">Guía educativa · Octubre de 2026</p>$q$, null, $q${"sec":"Contraportada","secStart":null}$q$, false)
) as v(pos, sec_pos, slug, title, minutes, css, nochrome, html, notes, meta, locked)
where d.slug = $q$libro-partidos$q$
on conflict (deck_id, slug) do nothing;


-- >>>>>>>>>> 20261006_05_seed_presentacion.sql
-- =====================================================================
-- FASE 5 de 6 · SEMILLA DE LA PRESENTACIÓN (77 diapositivas, 9 secciones). Requiere FASES 1 a 3.
-- Generado por tools/build-seed.js
-- =====================================================================

insert into public.mdpp_decks (slug, kind, title, description)
values ($q$presentacion-partidos$q$, $q$presentacion$q$, $q$Contabilidad de un Partido Político · Presentación$q$, $q$Presentación para cañonera con vista de visualizador y de presentador.$q$)
on conflict (slug) do nothing;

insert into public.mdpp_sections (deck_id, pos, roman, name)
select d.id, v.pos, v.roman, v.name
from public.mdpp_decks d,
(values
  (1, $q$I$q$, $q$Antecedentes$q$),
  (2, $q$II$q$, $q$Marco legal$q$),
  (3, $q$III$q$, $q$Financiamiento$q$),
  (4, $q$IV$q$, $q$Cuentas bancarias$q$),
  (5, $q$V$q$, $q$Libros$q$),
  (6, $q$VI$q$, $q$Plan de cuentas$q$),
  (7, $q$VII$q$, $q$Estados financieros$q$),
  (8, $q$VIII$q$, $q$Caso práctico$q$),
  (9, $q$IX$q$, $q$Obligaciones y SAT$q$)
) as v(pos, roman, name)
where d.slug = $q$presentacion-partidos$q$
on conflict (deck_id, pos) do nothing;

-- 77 filas. "do nothing" conserva lo que usted ya haya editado si se vuelve a ejecutar.
insert into public.mdpp_items (deck_id, section_id, pos, slug, title, minutes, css_class, nochrome, html, notes, meta, locked)
select d.id,
       (select s.id from public.mdpp_sections s where s.deck_id = d.id and s.pos = v.sec_pos),
       v.pos, v.slug, v.title, v.minutes, v.css, v.nochrome, v.html, v.notes, v.meta::jsonb, v.locked
from public.mdpp_decks d,
(values
  (1, null, $q$portada$q$, $q$Portada$q$, 0.7, $q$cover$q$, true, $q$<img class="logo a-z" src="assets/logo-monterroso-blanco.png" alt="Firma de Auditoría Monterroso, Auditores y Consultores"><div class="rule"></div>
      <div class="kick a" style="--d:600ms">Guía completa · Guatemala · Octubre de 2026</div>
      <h2 class="split">Contabilidad de un <em>Partido Político</em></h2>
      <p class="lead a" style="--d:900ms">Del marco legal a los estados financieros: cómo se registra, se controla y se rinde cuentas ante el Tribunal Supremo Electoral y la SAT.</p>$q$, $q$<p>Dé la bienvenida y presente la <b>Firma de Auditoría Monterroso, Auditores y Consultores</b>.</p><p>Objetivo del taller: que al terminar, cada asistente pueda explicar de dónde sale el dinero de un partido, cuánto puede recibir y gastar, qué libros y cuentas debe llevar y qué informes presenta al TSE y a la SAT.</p><p><b>Aviso:</b> material educativo con textos oficiales a octubre de 2026; no sustituye asesoría legal.</p>$q$, $q${}$q$, false),
  (2, null, $q$por-que-importa$q$, $q$Por qué importa$q$, 1.5, $q$vc$q$, false, $q$<div class="kick a">Para empezar</div><h2 class="split">Tres preguntas que la contabilidad debe responder</h2>
      <div class="cols c3 mt2">
        <div class="card" data-s="1"><h4>1 · Origen</h4><p class="q" style="font-size:54px;color:var(--ink)">¿De dónde viene cada quetzal?</p></div>
        <div class="card" data-s="2"><h4>2 · Límite</h4><p class="q" style="font-size:54px;color:var(--ink)">¿Cuánto se recibió y cuánto se podía?</p></div>
        <div class="card" data-s="3"><h4>3 · Destino</h4><p class="q" style="font-size:54px;color:var(--ink)">¿En qué se gastó y quién responde?</p></div>
      </div>
      <p class="lead a mt2" style="--d:600ms">Un partido es una institución de derecho público, pero maneja dinero público y privado. Su contabilidad es la prueba de que cada quetzal tiene origen conocido, límite respetado y destino justificado.</p>$q$, $q$<p>Plantee las tres preguntas una por una y pida a la sala que anticipe respuestas.</p><ul><li><b>Origen:</b> recibos, cuentas bancarias, libros de contribuciones.</li><li><b>Límite:</b> techo de campaña y tope del 10 % por aportante.</li><li><b>Destino:</b> facturas a nombre del partido, distribución 30/20/50, informes al TSE.</li></ul><p>Idea fuerza: la contabilidad del partido no es solo técnica; es la prueba de que cada quetzal tiene origen conocido, límite respetado y destino justificado.</p>$q$, $q${}$q$, false),
  (3, null, $q$agenda-del-taller$q$, $q$Agenda del taller$q$, 1.1, $q$$q$, false, $q$<div class="kick a">Ruta</div><h2 class="split">Nueve estaciones, un solo hilo</h2>
      <div class="cols c3" style="gap:22px;margin-top:10px"><div class="card a" style="padding:22px 28px"><div class="hero s" style="font-size:72px">I</div><p style="font-size:34px;color:var(--ink);margin-top:4px">Antecedentes</p></div><div class="card a" style="padding:22px 28px"><div class="hero s" style="font-size:72px">II</div><p style="font-size:34px;color:var(--ink);margin-top:4px">Marco legal</p></div><div class="card a" style="padding:22px 28px"><div class="hero s" style="font-size:72px">III</div><p style="font-size:34px;color:var(--ink);margin-top:4px">Financiamiento</p></div><div class="card a" style="padding:22px 28px"><div class="hero s" style="font-size:72px">IV</div><p style="font-size:34px;color:var(--ink);margin-top:4px">Cuentas bancarias</p></div><div class="card a" style="padding:22px 28px"><div class="hero s" style="font-size:72px">V</div><p style="font-size:34px;color:var(--ink);margin-top:4px">Libros</p></div><div class="card a" style="padding:22px 28px"><div class="hero s" style="font-size:72px">VI</div><p style="font-size:34px;color:var(--ink);margin-top:4px">Plan de cuentas</p></div><div class="card a" style="padding:22px 28px"><div class="hero s" style="font-size:72px">VII</div><p style="font-size:34px;color:var(--ink);margin-top:4px">Estados financieros</p></div><div class="card a" style="padding:22px 28px"><div class="hero s" style="font-size:72px">VIII</div><p style="font-size:34px;color:var(--ink);margin-top:4px">Caso práctico</p></div><div class="card a" style="padding:22px 28px"><div class="hero s" style="font-size:72px">IX</div><p style="font-size:34px;color:var(--ink);margin-top:4px">Obligaciones y SAT</p></div></div>$q$, $q$<p>Recorra la agenda: historia y marco legal (I–II), financiamiento y límites (III), cuentas y libros (IV–V), plan de cuentas y estados (VI–VII), caso práctico completo de <b>Futuro Retalteco</b> (VIII) y obligaciones, SAT y lista de cumplimiento (IX).</p><p>Anuncie que hay calculadoras en vivo (financiamiento público, techo de campaña, límite del 10 %) y que el caso práctico se arma partida por partida.</p><p>Duración total prevista: 90 minutos con espacio para preguntas al final de las secciones III, VI y VIII.</p>$q$, $q${}$q$, false),
  (4, 1, $q$seccion-i-antecedentes$q$, $q$Sección I · Antecedentes$q$, 0.2, $q$vc$q$, true, $q$<div class="divider"><div class="rn a-z">I</div><div><div class="kick a">Sección I de IX</div><h2 class="split">Antecedentes</h2><p class="lead a">Cómo llegamos hasta aquí: la regulación se construyó por capas, casi siempre después de una crisis de confianza.</p><div class="secs a"><i class="on">Antecedentes</i><i class="">Marco legal</i><i class="">Financiamiento</i><i class="">Cuentas bancarias</i><i class="">Libros</i><i class="">Plan de cuentas</i><i class="">Estados financieros</i><i class="">Caso práctico</i><i class="">Obligaciones y SAT</i></div></div></div>$q$, $q$<p>Explique que el control del dinero político en Guatemala no nació de golpe: se construyó con reformas sucesivas. Entender la historia ayuda a comprender por qué hoy hay tantas reglas.</p>$q$, $q${}$q$, false),
  (5, 1, $q$linea-de-tiempo-1985-2015$q$, $q$Línea de tiempo 1985–2015$q$, 1.1, $q$$q$, false, $q$<div class="kick a">Sección I · Antecedentes</div><h2 class="split">De 1985 a 2015</h2>
      <div class="tl">
        <div class="ev key" data-s="1"><div class="yr">1985</div><div class="tx"><b>Ley Electoral y de Partidos Políticos, Decreto 1-85.</b> Base legal que sigue vigente, con muchas reformas.</div></div>
        <div class="ev" data-s="2"><div class="yr">1987-89</div><div class="tx">Decretos 74-87 y 10-89: ajustan los derechos de los partidos en el artículo 20.</div></div>
        <div class="ev key" data-s="3"><div class="yr">2004</div><div class="tx"><b>Decreto 10-04.</b> Reforma varios artículos, entre ellos el 21: control y fiscalización del financiamiento.</div></div>
        <div class="ev" data-s="4"><div class="yr">2006</div><div class="tx"><b>Decreto 35-2006.</b> Vuelve a reformar el artículo 21 y otros relacionados con el financiamiento.</div></div>
        <div class="ev" data-s="5"><div class="yr">2015</div><div class="tx">La CICIG publica <i>El financiamiento de la política en Guatemala</i>: documenta riesgos de dinero opaco e ilícito en campañas.</div></div>
      </div>$q$, $q$<p>La LEPP fue aprobada por la Asamblea Nacional Constituyente el 3 de diciembre de 1985.</p><ul><li>1987 y 1989: reformas (Decretos 74-87 y 10-89) a derechos de los partidos.</li><li>2004 (Decreto 10-04) y 2006 (Decreto 35-2006): reforman el artículo 21 y relacionados.</li><li>2015: el informe de la CICIG evidencia los riesgos del financiamiento opaco y empuja la reforma de 2016.</li></ul>$q$, $q${}$q$, false),
  (6, 1, $q$linea-de-tiempo-2016-2027$q$, $q$Línea de tiempo 2016–2027$q$, 1.1, $q$$q$, false, $q$<div class="kick a">Sección I · Antecedentes</div><h2 class="split">De 2016 a las elecciones de 2027</h2>
      <div class="tl sm">
        <div class="ev key" data-s="1"><div class="yr">2016</div><div class="tx"><b>Decreto 26-2016</b> (25 de mayo): la reforma más profunda al financiamiento. Crea la Unidad Especializada de Control y Fiscalización.</div></div>
        <div class="ev" data-s="2"><div class="yr">2016</div><div class="tx">El TSE emite el <b>Acuerdo 306-2016</b>, primer reglamento de fiscalización. El Instructivo de Rendición de Cuentas se elabora con base en él.</div></div>
        <div class="ev key" data-s="3"><div class="yr">2023</div><div class="tx"><b>Acuerdo 602-2022</b>, emitido el 5 de enero de 2023, deroga el 306-2016. Ese día también se emite el Acuerdo 22-2023. El módulo <b>INFOCAM</b> (Cuentas Claras) pasa a ser obligatorio.</div></div>
        <div class="ev key" data-s="4"><div class="yr">2026</div><div class="tx"><b>26 de febrero:</b> Acuerdos 58, 59, 60 y 61-2026. El <b>60-2026</b> reforma el reglamento de fiscalización. Luego, coordinación con Contraloría, SAT y Superintendencias.</div></div>
        <div class="ev" data-s="5"><div class="yr">2027</div><div class="tx">Elecciones generales: primer ciclo completo con el reglamento reformado en 2026.</div></div>
      </div>
      <div class="note  " data-s="6"><b>La lección</b>Cada reforma agregó una pieza: primero el control, luego los límites, después la tecnología. Hoy la contabilidad del partido es el centro del sistema.</div>$q$, $q$<p>El Decreto 26-2016 fue el gran cambio. Después vino la reglamentación del TSE.</p><ul><li>El <b>Acuerdo 602-2022</b> se emitió el 5 de enero de 2023 y derogó al 306-2016 (art. 33).</li><li>El 26 de febrero de 2026 la Octava Magistratura (2026-2032) aprobó los Acuerdos 58 (reglamento de la LEPP), 59 (voto en el extranjero), 60 (<b>fiscalización de finanzas</b>) y 61 (medios y estudios de opinión).</li><li>El TSE coordina intercambio de información con la Contraloría General de Cuentas, la SAT y las Superintendencias.</li></ul>$q$, $q${}$q$, false),
  (7, 1, $q$que-creo-el-decreto-26-2016$q$, $q$Qué creó el Decreto 26-2016$q$, 1.5, $q$$q$, false, $q$<div class="kick a">Sección I · Antecedentes</div><h2 class="split">Seis piezas que creó el Decreto 26-2016</h2>
      <div class="cols c3" style="gap:26px">
        <div class="card  " data-s="1"><h4>Financiamiento público</h4><p>US$2 por voto, con distribución obligatoria <span class="law">art. 21 Bis</span></p></div>
        <div class="card  " data-s="2"><h4>Techo de campaña</h4><p>US$0.50 por ciudadano empadronado <span class="law">art. 21 Ter e</span></p></div>
        <div class="card  " data-s="3"><h4>Límite por aportante</h4><p>10 % del techo por persona o unidad de vinculación <span class="law">art. 21 Ter g</span></p></div>
        <div class="card red " data-s="4"><h4>Listas de prohibición</h4><p>Extranjeros, condenados, extinción de dominio <span class="law">art. 21 Ter a</span></p></div>
        <div class="card  " data-s="5"><h4>Libros de contribuciones</h4><p>Efectivo, especie y formación política <span class="law">art. 21 Ter c</span></p></div>
        <div class="card green " data-s="6"><h4>Unidad Especializada</h4><p>Control y fiscalización, creada dentro de seis meses <span class="law">art. 66 transitorio</span></p></div>
      </div>$q$, $q$<p>Estas seis piezas son el esqueleto del sistema actual. Haga una pausa en cada tarjeta: las retomaremos en las secciones III, V y IX.</p><p>El artículo 66 transitorio del Decreto 26-2016 ordenó crear la Unidad Especializada de control y fiscalización de las finanzas de los partidos y la de medios y estudios de opinión en seis meses.</p>$q$, $q${}$q$, false),
  (8, 2, $q$seccion-ii-marco-legal-y-entidad-rectora$q$, $q$Sección II · Marco legal y entidad rectora$q$, 0.2, $q$vc$q$, true, $q$<div class="divider"><div class="rn a-z">II</div><div><div class="kick a">Sección II de IX</div><h2 class="split">Marco legal y entidad rectora</h2><p class="lead a">Qué normas rigen la contabilidad de un partido, en qué orden mandan y quién vigila su cumplimiento.</p><div class="secs a"><i class="">Antecedentes</i><i class="on">Marco legal</i><i class="">Financiamiento</i><i class="">Cuentas bancarias</i><i class="">Libros</i><i class="">Plan de cuentas</i><i class="">Estados financieros</i><i class="">Caso práctico</i><i class="">Obligaciones y SAT</i></div></div></div>$q$, $q$<p>Esta sección responde dos preguntas: ¿qué normas aplican? y ¿quién fiscaliza?</p>$q$, $q${}$q$, false),
  (9, 2, $q$las-normas-de-mayor-a-menor$q$, $q$Las normas, de mayor a menor$q$, 1.1, $q$$q$, false, $q$<div class="kick a">Sección II · Marco legal</div><h2 class="split">Las normas, de mayor a menor</h2>
      <div class="pyr mt">
        <div class="lv a" style="width:42%;background:#e9c97a"><b>Constitución Política</b>Libertad de organización política</div>
        <div class="lv" data-s="1" style="width:58%;background:#edd391"><b>LEPP · Decreto 1-85</b>arts. 18, 19 Bis, 21 a 21 Quinquies, 22, 88</div>
        <div class="lv" data-s="2" style="width:72%;background:#f0dba7"><b>Decreto 26-2016</b>La reforma que creó el sistema de financiamiento</div>
        <div class="lv" data-s="3" style="width:86%;background:#f3e3bf"><b>Reglamento de Control y Fiscalización</b>Acuerdo 602-2022, reformado por 22-2023 y 60-2026</div>
        <div class="lv" data-s="4" style="width:100%;background:#f6ecd4"><b>Instructivo de Rendición de Cuentas</b>Nomenclatura, estados, formatos GR-PRI, INF-FINPU, INFOCAM</div>
      </div>
      <div class="note  " data-s="5"><b>En paralelo</b>Las leyes fiscales: Código de Comercio, Ley de Actualización Tributaria y Ley del IVA. Cumplir el Reglamento no releva al partido de ellas <span class="law">art. 29</span></div>$q$, $q$<p>Cuando dos normas parecen chocar, manda la de mayor jerarquía. Construya la pirámide de arriba hacia abajo.</p><p>La contabilidad se lleva con las Normas Internacionales de Contabilidad y de Información Financiera adoptadas en Guatemala, según el Instructivo.</p><p>El artículo 29 del Reglamento es clave para el contador: las leyes fiscales siguen aplicando.</p>$q$, $q${}$q$, false),
  (10, 2, $q$que-regula-cada-norma$q$, $q$Qué regula cada norma$q$, 1.5, $q$$q$, false, $q$<div class="kick a">Sección II · Marco legal</div><h2 class="split">Qué regula cada norma</h2>
      <table class="t sm"><thead><tr><th class="">Norma</th><th class="">Qué aporta a la contabilidad</th></tr></thead><tbody><tr data-s="1" class=""><td class=""><b>LEPP art. 21</b></td><td class="">El TSE controla fondos públicos y privados. Cuenta bancaria separada por origen. Acceso permanente a los libros.</td></tr><tr data-s="2" class=""><td class=""><b>LEPP art. 21 Bis</b></td><td class="">Financiamiento público: US$2 por voto. Distribución 30 / 20 / 50.</td></tr><tr data-s="3" class=""><td class=""><b>LEPP art. 21 Ter</b></td><td class="">Prohibiciones, recibos SAT, libros de contribuciones, techo, límite del 10 %, sanciones.</td></tr><tr data-s="4" class=""><td class=""><b>LEPP 21 Quáter y Quinquies</b></td><td class="">Definiciones (financista, unidad de vinculación) y publicidad 30 días antes de la elección.</td></tr><tr data-s="5" class=""><td class=""><b>LEPP art. 88</b></td><td class="">Sanciones: de amonestación a cancelación del partido.</td></tr><tr data-s="6" class=""><td class=""><b>Reglamento (Ac. 602-2022)</b></td><td class="">Contador, informes, cuentas, recibos, declaración jurada, comprobación de egresos.</td></tr><tr data-s="7" class=""><td class=""><b>Ac. 60-2026</b></td><td class="">Reforma los artículos 11, 13, 15, 16, 18, 19 y 20 del Reglamento.</td></tr><tr data-s="8" class=""><td class=""><b>Instructivo</b></td><td class="">Estados financieros, nomenclatura contable, formatos e informes.</td></tr></tbody></table>$q$, $q$<p>Use esta tabla como mapa de referencia. El contador debe tener a mano estos artículos.</p><p>Resalte el Acuerdo 60-2026: cambia justo los artículos que más usa el contador (11 contabilidad, 13 informes, 15 rectificación, 16 auditoría, 18-19 cuentas, 20 libros de financistas).</p>$q$, $q${}$q$, false),
  (11, 2, $q$correccion-el-acuerdo-306-2016$q$, $q$Corrección: el Acuerdo 306-2016$q$, 1.1, $q$vc$q$, false, $q$<div class="kick a">Una corrección que conviene hacer</div>
      <div class="cols c2" style="align-items:center;gap:60px">
        <div class="center"><div class="bigcode a-z cross" data-go="1">Acuerdo 306-2016</div>
          <div class="mt2" data-s="1"><span class="stamp">DEROGADO</span></div></div>
        <div data-s="2"><div class="cap">Vigente</div><div class="bigcode gold" style="font-size:150px;color:var(--gold2)">Acuerdo 602-2022</div>
          <p class="lead" style="margin-top:14px">Reformado por los Acuerdos <b>22-2023</b> y <b>60-2026</b>. El art. 33 deroga al 306-2016.</p></div>
      </div>
      <div class="mt2"><div class="note warn " data-s="3"><b>Para recordar</b>El Instructivo publicado todavía cita el 306-2016. Úselo para formatos y nomenclatura, pero aplique los artículos y plazos del reglamento vigente. El Acuerdo 58-2026 reforma el reglamento de la LEPP, no el de fiscalización.</div></div>$q$, $q$<p>Aclare un error frecuente: muchos documentos todavía hablan del Acuerdo 306-2016. <b>Ya no está vigente</b>.</p><p>Diferencia clave en plazos: el Reglamento vigente exige conservar registros contables por <b>cinco años</b> (art. 11); el Instructivo, redactado antes, menciona quince. Aplique cinco años.</p>$q$, $q${}$q$, false),
  (12, 2, $q$la-unidad-especializada-uecffpp$q$, $q$La Unidad Especializada (UECFFPP)$q$, 1.5, $q$$q$, false, $q$<div class="cols c12" style="gap:60px;align-items:start">
      <div><div class="kick a">Sección II · Entidad rectora</div><h2 class="split">La <em>Unidad</em> Especializada</h2>
        <p class="a">Dependencia del TSE responsable del control y fiscalización de las finanzas de las organizaciones políticas <span class="law">Reglamento art. 2</span>.</p>
        <p class="small a">Por mandato del Decreto 26-2016 (art. 66), se creó dentro de seis meses de su vigencia.</p></div>
      <div class="stack" style="padding-top:60px">
        <div class="card  " data-s="1"><h4>Fiscalizar</h4><p>En cualquier momento, recursos públicos y privados.</p></div>
        <div class="card  " data-s="2"><h4>Auditar</h4><p>Auditorías ordinarias y extraordinarias y revisiones especiales.</p></div>
        <div class="card  " data-s="3"><h4>Visitar sedes</h4><p>Revisiones en órganos departamentales y municipales.</p></div>
        <div class="card green " data-s="4"><h4>Pedir información</h4><p>A financistas y, bajo reserva, a Contraloría, SAT y Superintendencias.</p></div>
      </div></div>$q$, $q$<p>Sigla: UECFFPP, Unidad Especializada de Control y Fiscalización de las Finanzas de los Partidos Políticos.</p><p>El artículo 21 de la LEPP obliga a la Contraloría General de Cuentas, la SAT, la Superintendencia de Bancos y la de Telecomunicaciones, además de funcionarios públicos, a entregar la información que el TSE les pida, bajo reserva de confidencialidad.</p><p>El jefe de la Unidad se nombra por concurso público de oposición y no puede estar afiliado a ningún partido (art. 5 y 6 del Reglamento).</p>$q$, $q${}$q$, false),
  (13, 2, $q$como-es-una-fiscalizacion$q$, $q$Cómo es una fiscalización$q$, 1.1, $q$$q$, false, $q$<div class="kick a">Sección II · Entidad rectora</div><h2 class="split">Cómo avanza una fiscalización</h2>
      <div class="flow mt2" style="height:260px">
        <div class="st a"><b>1</b>Informe preliminar</div>
        <div class="st" data-s="1"><b>2</b>20 días para aclarar (+10)</div>
        <div class="st" data-s="2"><b>3</b>Informe final al Pleno</div>
        <div class="st" data-s="3"><b>4</b>Audiencia de 15 días</div>
        <div class="st" data-s="4"><b>5</b>Resolución</div>
      </div>
      <div class="mt2"><div class="note  " data-s="5"><b>Lo que debe saber el contador</b>Antes de una sanción hay oportunidad de aclarar y de defenderse. Pero los plazos corren: los respaldos ordenados son la mejor defensa. Las sanciones se gradúan con proporcionalidad y razonabilidad <span class="law">Reglamento arts. 15 y 16</span></div></div>$q$, $q$<p>Etapas: informe preliminar; veinte días (ampliables diez, por única vez) para evacuar y aportar documentos; informe final al Pleno de Magistrados; audiencia de quince días (prorrogable) otorgada por el Registro de Ciudadanos; resolución.</p><p>Los informes GR-PRI, INF-FINPU e INFOCAM pueden rectificarse en 30 días tras su vencimiento, pero no después de iniciada una auditoría.</p>$q$, $q${}$q$, false),
  (14, 3, $q$seccion-iii-naturaleza-y-financiamiento$q$, $q$Sección III · Naturaleza y financiamiento$q$, 0.2, $q$vc$q$, true, $q$<div class="divider"><div class="rn a-z">III</div><div><div class="kick a">Sección III de IX</div><h2 class="split">Naturaleza y financiamiento</h2><p class="lead a">Qué es un partido, de dónde puede recibir dinero, cuánto y cómo debe repartir el aporte del Estado.</p><div class="secs a"><i class="">Antecedentes</i><i class="">Marco legal</i><i class="on">Financiamiento</i><i class="">Cuentas bancarias</i><i class="">Libros</i><i class="">Plan de cuentas</i><i class="">Estados financieros</i><i class="">Caso práctico</i><i class="">Obligaciones y SAT</i></div></div></div>$q$, $q$<p>Es la sección más larga y la más importante: fuentes, prohibiciones, techos y distribución del aporte público. Habrá tres calculadoras en vivo.</p>$q$, $q${}$q$, false),
  (15, 3, $q$naturaleza-juridica$q$, $q$Naturaleza jurídica$q$, 0.9, $q$vc$q$, false, $q$<div class="kick a">Sección III · Naturaleza jurídica <span class="law">LEPP art. 18</span></div>
      <p class="q a">Los partidos políticos son <b>instituciones de derecho público</b>, con <b>personalidad jurídica</b> y <b>duración indefinida</b>.</p>
      <p class="lead a mt2" style="--d:700ms">Configuran el carácter democrático del régimen político del Estado.</p>$q$, $q$<p>El artículo 18 de la LEPP define al partido como institución de derecho público. Esto explica por qué su contabilidad es pública y está sujeta a fiscalización de la Contraloría General de Cuentas y del TSE en lo que cada uno le compete (art. 19 Bis).</p>$q$, $q${}$q$, false),
  (16, 3, $q$cuatro-tipos-de-organizacion-politica$q$, $q$Cuatro tipos de organización política$q$, 0.9, $q$$q$, false, $q$<div class="kick a">Sección III · Naturaleza jurídica</div><h2 class="split">Cuatro organizaciones políticas <span class="law">art. 16</span></h2>
      <div class="cols c2" style="gap:28px">
        <div class="card  " data-s="1"><h4>Partidos políticos</h4><p>Permanentes. Reciben financiamiento público si cumplen el requisito de votos o diputaciones.</p></div>
        <div class="card  " data-s="2"><h4>Comités para constituir un partido</h4><p>Informe semestral de ingresos y egresos (INF-COMITÉ).</p></div>
        <div class="card blue " data-s="3"><h4>Comités cívicos electorales</h4><p>Temporales. Solo financiamiento privado. Informe mensual (INF-COMIT).</p></div>
        <div class="card green " data-s="4"><h4>Asociaciones con fines políticos</h4><p>Formación política. No postulan candidatos. Informe semestral.</p></div>
      </div>$q$, $q$<p>El Instructivo del TSE se dirige a las cuatro. Destaque que los comités cívicos se financian únicamente con aportes privados y su límite de gasto es de US$0.10 por ciudadano empadronado del municipio (art. 21 Ter f).</p>$q$, $q${}$q$, false),
  (17, 3, $q$que-implica-para-la-contabilidad$q$, $q$Qué implica para la contabilidad$q$, 0.9, $q$$q$, false, $q$<div class="kick a">Sección III · Naturaleza jurídica</div><h2 class="split">Tres consecuencias contables</h2>
      <div class="stack mt">
        <div class="card" data-s="1"><h4>Patrimonio íntegro <span class="law">art. 21 Ter d</span></h4><p>Se registra completo en la contabilidad. Sin títulos al portador ni cuentas anónimas.</p></div>
        <div class="card" data-s="2"><h4>Registros públicos <span class="law">art. 21 Ter c</span></h4><p>Los registros contables de los partidos son públicos.</p></div>
        <div class="card hot" data-s="3"><h4>Responsabilidad personal <span class="law">art. 19 Bis</span></h4><p>Secretarios generales nacional, departamentales y municipales responden por los fondos que manejan.</p></div>
      </div>$q$, $q$<p>Estas tres ideas orientan todo lo que sigue. El partido no puede tener patrimonio escondido; todo es público; y los dirigentes responden con su nombre.</p>$q$, $q${}$q$, false),
  (18, 3, $q$mapa-de-las-fuentes$q$, $q$Mapa de las fuentes$q$, 1.1, $q$$q$, false, $q$<div class="kick a">Sección III · Fuentes</div><h2 class="split">Tres categorías de ingreso</h2>
      <div class="cols c3" style="gap:28px">
        <div class="card blue" data-s="1" style="min-height:470px"><h4>Públicas · el Estado</h4><div class="hero m" style="margin:12px 0">US$2</div><p>por voto legalmente emitido, a partidos con al menos 5 % de votos válidos o una diputación. Destino fijado por ley: 30 / 20 / 50.</p></div>
        <div class="card" data-s="2" style="min-height:470px"><h4>Privadas · personas</h4><p>Cuotas de afiliados, aportes de simpatizantes, autofinanciamiento, productos financieros y aportes en especie.</p><p class="small" style="margin-top:18px">Con recibo SAT, sin anonimato y con límite del 10 % del techo de campaña por aportante.</p></div>
        <div class="card red" data-s="3" style="min-height:470px"><h4>Prohibidas · nunca</h4><p>Estados y personas extranjeras; condenados por delitos contra la administración pública o lavado; extinción de dominio; fundaciones apolíticas; aportes anónimos.</p></div>
      </div>
      <div class="mt"><div class="note  " data-s="4"><b>Regla de oro</b>Cada ingreso se identifica: quién, cuánto, cuándo, en qué forma y de dónde viene. Si no consta en los libros del financista seis meses antes, no se considera procedente <span class="law">art. 21 Ter b</span></div></div>$q$, $q$<p>Todo ingreso cae en una de tres categorías. Saber en cuál está decide cómo se registra, dónde se deposita y cuánto se admite.</p><p>La regla de los seis meses es una barrera contra dinero que aparece de repente en las cuentas del financista justo antes de aportar.</p>$q$, $q${}$q$, false),
  (19, 3, $q$financiamiento-publico-us-2-por-voto$q$, $q$Financiamiento público: US$2 por voto$q$, 1.1, $q$$q$, false, $q$<div class="cols c2" style="gap:70px;align-items:center">
        <div><div class="kick a">Financiamiento público</div><h2 class="split">El aporte del <em>Estado</em> <span class="law">art. 21 Bis</span></h2>
          <p class="lead a">El Estado contribuye con el equivalente en quetzales de <b>dos dólares</b> por voto legalmente emitido a favor del partido.</p></div>
        <div class="center a-z"><div class="hero" style="font-size:300px">US$<span class="cnt" data-to="2" data-dec="0">2</span></div><div class="cap">por voto válido</div></div></div>
      <div class="cols c2 mt2" style="gap:30px">
        <div class="card  " data-s="1"><h4>Condición A</h4><p>Obtener al menos el <b>5 %</b> de los votos válidos en elecciones generales.</p></div>
        <div class="card green " data-s="2"><h4>Condición B</h4><p>O bien, obtener <b>al menos una diputación</b> al Congreso, aunque no llegue al 5 %.</p></div>
      </div>
      <p class="small mt" data-s="3">El cálculo toma la mayor cantidad de votos válidos: la de presidente y vicepresidente o la del Listado Nacional.</p>$q$, $q$<p>El derecho nace con cualquiera de las dos condiciones. El cálculo usa la mayor cantidad de votos válidos recibidos, ya sea en la fórmula presidencial o en el Listado Nacional de diputados.</p>$q$, $q${}$q$, false),
  (20, 3, $q$como-se-paga-el-financiamiento-publico$q$, $q$Cómo se paga el financiamiento público$q$, 0.9, $q$$q$, false, $q$<div class="kick a">Financiamiento público</div><h2 class="split">Cuándo y cómo se paga</h2>
      <table class="t "><tbody><tr data-s="1" class=""><td class="">Período</td><td class="">El período presidencial correspondiente</td></tr><tr data-s="2" class=""><td class="">Cuotas</td><td class="">Cuatro cuotas anuales e iguales</td></tr><tr data-s="3" class=""><td class="">Cuándo</td><td class="">Durante el mes de <b>julio</b> de cada año</td></tr><tr data-s="4" class=""><td class="">Año electoral</td><td class="">Si destina la cuota a campaña, se entrega en <b>enero</b></td></tr><tr data-s="5" class=""><td class="">Requisito previo</td><td class="">Certificación del acta del CEN que acredite cómo se distribuyó</td></tr><tr data-s="6" class=""><td class="">Coalición</td><td class="">Se reparte según el convenio de coalición</td></tr></tbody></table>$q$, $q$<p>El ejemplo del Instructivo: los votos de 2015 se dividen entre cuatro años de período. Cada año se paga una cuota igual.</p><p>Sin la certificación del acta del Comité Ejecutivo Nacional que acredite la distribución, no se entrega la cuota.</p>$q$, $q${}$q$, false),
  (21, 3, $q$calculadora-financiamiento-publico$q$, $q$Calculadora: financiamiento público$q$, 1.8, $q$$q$, false, $q$<div class="kick a">Calculadora en vivo</div><h2 class="split">Tres partidos, tres resultados</h2>
      <div class="cols c2" style="gap:50px;align-items:start">
        <div class="stack">
          <div class="card"><h4>Partido</h4><p class="num"><b data-k="n" style="font-size:50px;color:var(--gold2);font-family:var(--display)"></b></p></div>
          <div class="cols c3" style="gap:18px">
            <div class="card"><h4>Votos</h4><p class="num" style="font-size:40px;color:var(--ink)"><span data-k="v">0</span></p></div>
            <div class="card"><h4>% del total</h4><p class="num" style="font-size:40px;color:var(--ink)"><span data-k="pct">0</span></p></div>
            <div class="card"><h4>Diputaciones</h4><p class="num" style="font-size:40px;color:var(--ink)"><span data-k="d">0</span></p></div>
          </div>
          <div><span class="verdict ok" data-k="ver"></span></div>
          <p class="small">Total de votos válidos supuesto: 5,000,000 · Tipo de cambio: Q7.62</p>
        </div>
        <div class="card hot" style="padding:40px 44px">
          <div class="cap">Total del período (4 años)</div><div class="hero s num" data-k="usd4">US$ 0</div>
          <div class="cap mt">Cuota anual en dólares</div><div class="hero s num" data-k="usd1">US$ 0</div>
          <div class="cap mt">Cuota anual en quetzales</div><div class="hero m num" data-k="q1">Q 0</div>
        </div></div>$q$, $q$<p><b>Paso 0:</b> Futuro Retalteco, 150,000 votos de 5,000,000 = 3 %. No llega al 5 %, pero tiene una diputación: tiene derecho. 150,000 × US$2 = US$300,000 en cuatro años; US$75,000 al año; ×7.62 = <b>Q571,500</b>.</p><p><b>Paso 1:</b> Partido B con 300,000 votos = 6 %: tiene derecho por superar el 5 %. Cuota anual: Q1,143,000.</p><p><b>Paso 2:</b> Partido C con 200,000 votos = 4 % y ninguna diputación: <b>sin derecho</b>.</p>$q$, $q${}$q$, true),
  (22, 3, $q$distribucion-obligatoria-30-20-50$q$, $q$Distribución obligatoria 30 / 20 / 50$q$, 1.8, $q$hs$q$, false, $q$<div class="kick a">Distribución obligatoria <span class="law">art. 21 Bis</span></div><h2 class="split">Cómo debe <em>repartirse</em> el aporte público</h2>
      <div class="dist a" data-go="1"><span style="background:#e9c97a">30 %</span><span style="background:#94b9e0">20 %</span><span style="background:#94c98d">50 %</span></div>
      <div class="cols c3 mt" style="gap:28px">
        <div class="card hot a"><h4>30 % · Formación</h4><p>Formación y capacitación de afiliados, cuadros y fiscales.</p></div>
        <div class="card blue a"><h4>20 % · Sede nacional</h4><p>Actividades nacionales y funcionamiento de la sede nacional.</p></div>
        <div class="card green a"><h4>50 % · Territorio</h4><p>Funcionamiento en departamentos y municipios con organización vigente.</p></div>
      </div>
      <div class="cols c2 mt" style="gap:28px">
        <div class="card green" data-s="2"><h4>De ese 50 %</h4><p><b>Un tercio</b> a los órganos departamentales y <b>dos tercios</b> a los municipales, según los empadronados de cada circunscripción.</p></div>
        <div class="card hot" data-s="3"><h4>En año electoral</h4><p>Todo el aporte puede destinarse a campaña (se paga en enero), por la cuenta de campaña. <b>Cuenta contra el techo.</b></p></div>
      </div>
      <div class="note warn " data-s="4"><b>Cuidado con el Instructivo</b>Un cuadro ilustra la distribución con las etiquetas de 20 y 30 % intercambiadas. Aplique el orden de la ley: 30 % formación, 20 % sede nacional.</div>$q$, $q$<p>Dibuje la barra: 30 % formación, 20 % sede nacional, 50 % territorio. Los secretarios generales de los comités ejecutivos son personalmente responsables del manejo de estos fondos.</p><p>Se consideran fines de formación ideológica y política los gastos para capacitar afiliados, cuadros y fiscales electorales, y la formación y publicación de material de capacitación.</p><p>Si un departamento o municipio pierde vigencia, el CEN puede certificar una nueva distribución (art. 18 d del Reglamento).</p>$q$, $q${}$q$, false),
  (23, 3, $q$financiamiento-privado-tipos$q$, $q$Financiamiento privado: tipos$q$, 1.1, $q$$q$, false, $q$<div class="kick a">Financiamiento privado</div><h2 class="split">Tipos de aporte y qué significa cada uno</h2>
      <table class="t sm"><tbody><tr data-s="1" class=""><td class=""><b>Aportes de afiliados</b></td><td class="">Cuotas ordinarias o extraordinarias, en dinero o en especie.</td></tr><tr data-s="2" class=""><td class=""><b>Aportes de simpatizantes</b></td><td class="">De personas no afiliadas, a título propio.</td></tr><tr data-s="3" class=""><td class=""><b>Autofinanciamiento</b></td><td class="">Cenas, conferencias, espectáculos, sorteos, juegos. Antes debe existir un egreso con recursos propios o un aporte en especie.</td></tr><tr data-s="4" class=""><td class=""><b>Productos financieros</b></td><td class="">Intereses de inversiones hechas con financiamiento privado.</td></tr><tr data-s="5" class=""><td class=""><b>Aporte en dinero</b></td><td class="">Se canaliza por la organización y se deposita en su cuenta.</td></tr><tr data-s="6" class=""><td class=""><b>Aporte en especie</b></td><td class="">Bien o servicio sin transferencia de dinero; se acepta por recibo y se justiprecia.</td></tr></tbody></table>$q$, $q$<p>Definiciones del Instructivo y del artículo 3 del Reglamento. Recalque que el autofinanciamiento exige un registro previo del gasto con recursos propios o de un aporte no dinerario; luego se registra el ingreso.</p><p>Los préstamos bancarios o de terceros no son ingreso: son pasivo. Si un acreedor perdona la deuda, eso es una donación y cuenta para el techo si ocurre en época electoral.</p>$q$, $q${}$q$, false),
  (24, 3, $q$aportes-en-especie-y-justiprecio$q$, $q$Aportes en especie y justiprecio$q$, 1.1, $q$$q$, false, $q$<div class="kick a">Financiamiento privado</div><h2 class="split">El aporte en especie y su <em>justiprecio</em></h2>
      <div class="cols c3" style="gap:26px">
        <div class="card  " data-s="1"><h4>Donación</h4><p>La persona transfiere gratuitamente bienes o derechos.</p></div>
        <div class="card  " data-s="2"><h4>Cesión de derechos</h4><p>Se cede a la organización la titularidad jurídica de una cosa.</p></div>
        <div class="card blue " data-s="3"><h4>Comodato</h4><p>Uso temporal de un bien. El dueño puede pedirlo de vuelta; se registra por el valor de alquiler de mercado.</p></div>
      </div>
      <div class="mt2"><div class="note  " data-s="4"><b>Justiprecio</b>Valor de mercado asignado al aporte. Si no se justiprecia, la Unidad Especializada pide hacerlo en 5 días; si no es razonable, lo estima con el IPC del INE o precios de mercado <span class="law">Reglamento art. 19</span></div></div>$q$, $q$<p>Los aportes en especie se aceptan expresamente por recibo y se justiprecian a valor de mercado. El donante debe acreditar la propiedad de lo aportado.</p><p>En contabilidad se registran en cuentas de control: ingreso (4-5) y egreso (5-3) por el mismo valor, para vigilar el techo de campaña.</p>$q$, $q${}$q$, false),
  (25, 3, $q$financiamiento-prohibido$q$, $q$Financiamiento prohibido$q$, 1.5, $q$$q$, false, $q$<div class="kick a">Financiamiento prohibido <span class="law">art. 21 Ter a</span></div><h2 class="split">Lo que un partido nunca debe recibir</h2>
      <div class="cols c2" style="gap:26px">
        <div class="nm" data-s="1"><i>1</i><span><b>Estados y personas extranjeras</b>, individuales o jurídicas.</span></div>
        <div class="nm" data-s="2"><i>2</i><span><b>Condenados</b> por delitos contra la administración pública, lavado de dinero u otros activos.</span></div>
        <div class="nm" data-s="3"><i>3</i><span><b>Extinción de dominio:</b> personas con bienes sometidos a ese proceso, o vinculadas a ellas.</span></div>
        <div class="nm" data-s="4"><i>4</i><span><b>Fundaciones o asociaciones civiles apolíticas.</b> Excepción: aportes académicos para formación, reportados al TSE en 30 días.</span></div>
      </div>
      <div class="mt2"><div class="note warn " data-s="5"><b>Quién protege al partido</b>Antes de aceptar aportes grandes, consulte el listado de exclusión de financistas <span class="law">Reglamento art. 10</span></div></div>$q$, $q$<p>Estas cuatro categorías cierran la puerta a injerencia extranjera, a corrupción y lavado, y al dinero de origen ilícito. La prohibición cubre contribuciones «de cualquier índole».</p><p>El Reglamento (art. 10) crea el listado de exclusión de financistas; el TSE debe coordinar con las instituciones que tienen esa información.</p>$q$, $q${}$q$, false),
  (26, 3, $q$otras-prohibiciones-y-consecuencias$q$, $q$Otras prohibiciones y consecuencias$q$, 1.1, $q$$q$, false, $q$<div class="kick a">Financiamiento prohibido</div><h2 class="split">Otras reglas que no se negocian</h2>
      <table class="t "><tbody><tr data-s="1" class=""><td class="">Aportes anónimos</td><td class="">Terminantemente prohibidos <span class="law">Reglamento art. 23</span></td></tr><tr data-s="2" class=""><td class="">Estado y municipalidades</td><td class="">Ningún aporte fuera de lo que la ley establece <span class="law">art. 21</span></td></tr><tr data-s="3" class=""><td class="">Donar al candidato</td><td class="">Todo se canaliza por la organización política <span class="law">art. 21 Ter b</span></td></tr><tr data-s="4" class=""><td class="">Propaganda de una empresa</td><td class="">Puede costar la cancelación de su personalidad jurídica <span class="law">art. 21 Ter i</span></td></tr><tr data-s="5" class=""><td class="">Más del 10 %</td><td class="">Ningún aportante o unidad de vinculación sobre el límite <span class="law">art. 21 Ter g</span></td></tr></tbody></table>
      <div class="mt"><div class="note warn " data-s="6"><b>Consecuencia</b>Quien aporta contraviniendo la ley también queda sujeto al Código Penal <span class="law">art. 88</span></div></div>$q$, $q$<p>Aporte anónimo es todo el que no refleje su origen o incumpla los requisitos. Si la Unidad no encuentra soporte, pide información y, si no se comprueba el origen, lo reporta como hallazgo.</p>$q$, $q${}$q$, false),
  (27, 3, $q$techo-de-gastos-de-campana$q$, $q$Techo de gastos de campaña$q$, 1.5, $q$vc$q$, false, $q$<div class="kick a">Techos y límites · 1 <span class="law">art. 21 Ter e</span></div><h2 class="split">Techo de gastos de campaña</h2>
      <div class="cols c2" style="gap:60px;align-items:center">
        <div><p class="lead a">Cada organización puede gastar, como máximo, el equivalente en quetzales a <b>US$0.50 por ciudadano empadronado</b> al 31 de diciembre del año previo a las elecciones.</p>
          <p class="small a">En coalición, el límite total no puede superar el monto individual. El TSE puede fijarlo más bajo.</p></div>
        <div class="card hot" style="padding:40px 44px">
          <div class="cap">Empadronados (supuesto)</div><div class="hero s num"><span class="cnt" data-to="10200000">0</span></div>
          <div class="cap mt">× US$0.50 × Q7.62 =</div>
          <div class="hero m num" style="color:var(--gold)"><span class="cnt" data-pre="Q " data-to="38862000">Q 0</span></div></div></div>
      <div class="cols c3 mt" style="gap:26px">
        <div class="card" data-s="1"><h4>Por aportante (10 %)</h4><p class="num" style="font-size:46px;color:var(--gold2)"><span class="cnt" data-pre="Q " data-to="3886200">0</span></p></div>
        <div class="card blue" data-s="2"><h4>Comité cívico (US$0.10)</h4><p class="num" style="font-size:46px;color:var(--blue)"><span class="cnt" data-pre="Q " data-to="19050">0</span></p><p class="small">25,000 empadronados</p></div>
        <div class="card" data-s="3"><h4>Referencia en prensa</h4><p class="num" style="font-size:40px">≈ Q38.9 millones en 2027</p><p class="small">Q34.9 millones en 2023</p></div>
      </div>$q$, $q$<p>Calculadora: 10,200,000 empadronados × US$0.50 = US$5,100,000 × 7.62 = <b>Q38,862,000</b>. Los datos son supuestos; el TSE publica el padrón y fija el techo oficial.</p><p>El 10 % por aportante = Q3,886,200. Para un comité cívico de un municipio con 25,000 empadronados: 25,000 × US$0.10 × 7.62 = Q19,050.</p>$q$, $q${}$q$, false),
  (28, 3, $q$que-cuenta-como-gasto-de-campana$q$, $q$Qué cuenta como gasto de campaña$q$, 0.9, $q$$q$, false, $q$<div class="kick a">Techos y límites · 1</div><h2 class="split">Qué cuenta contra el techo <span class="law">Reglamento art. 3 i</span></h2>
      <div class="cols c2" style="gap:30px"><ul class="gl "><li data-s="1"><b>Propaganda electoral:</b> impresión, grabación o edición de material</li><li data-s="2"><b>Servicios</b> contratados o pagados antes, durante y después del proceso</li><li data-s="3"><b>Encuestas</b> contratadas por la organización</li></ul>
        <ul class="gl "><li data-s="4"><b>Alquileres temporales</b> de vehículos, bienes o sedes para actos</li><li data-s="5"><b>Viajes, hospedaje y alimentación</b> de dirigentes, asesores, delegados y candidatos</li><li data-s="6"><b>Aportes en especie</b> justipreciados</li></ul></div>
      <div class="mt2"><div class="note  " data-s="7"><b>Controle el acumulado</b>La cuota pública usada para campaña también cuenta como gasto del límite <span class="law">art. 21 Bis d</span></div></div>$q$, $q$<p>Todo desembolso para propaganda o campaña cuenta, aunque se pague antes o después del proceso. Los aportes en especie justipreciados cuentan una vez al recibirse y ejecutarse.</p><p>Recomendación práctica: llevar un acumulado mensual del gasto de campaña contra el techo.</p>$q$, $q${}$q$, false),
  (29, 3, $q$limite-del-10-por-aportante$q$, $q$Límite del 10 % por aportante$q$, 1.8, $q$hs$q$, false, $q$<div class="kick a">Techos y límites · 2 <span class="law">art. 21 Ter g</span></div><h2 class="split">¿Puedo aceptar este <em>aporte</em>?</h2>
      <p class="lead a">Las personas relacionadas o vinculadas, o una sola <b>unidad de vinculación</b>, no pueden aportar en conjunto más del <b>10 %</b> del techo (Q3,886,200 en el ejemplo).</p>
      <div class="card hot a" style="padding:34px 44px">
        <div class="cap" data-k="who">&nbsp;</div>
        <div class="cols c2" style="gap:40px;align-items:center;margin-top:10px"><div class="hero m num" data-k="tot">Q 0</div><div class="num" style="font-size:56px;font-family:var(--display);color:var(--ink)" data-k="pct">0 %</div></div>
        <div class="meter mt"><i data-k="bar"></i><b></b></div>
        <div class="small right" style="margin-top:6px">La marca blanca es el límite del 10 %</div>
      </div>
      <div class="mt"><span class="verdict ok" data-k="v1"></span> <span class="small" data-k="v2" style="margin-left:18px"></span> <span class="small" data-k="v3" style="margin-left:18px"></span></div>$q$, $q$<p><b>Paso 0:</b> un donante de Q400,000 está dentro del 10 % (usa 10.3 % del límite). Como supera Q30,000 debe habilitar libros y como supera Q50,000, declaración jurada notarial.</p><p><b>Paso 1:</b> una empresa de Q400,000 con vinculadas que aportan Q3,600,000: la unidad suma Q4,000,000 y <b>excede</b> el límite.</p><p><b>Paso 2:</b> tres aportes de Q20,000 de una misma persona en el período se consideran una sola transacción de Q60,000: dentro del límite, pero activa declaración jurada y libros.</p>$q$, $q${}$q$, true),
  (30, 3, $q$umbrales-que-activan-obligaciones$q$, $q$Umbrales que activan obligaciones$q$, 1.1, $q$vc$q$, false, $q$<div class="kick a">Techos y límites · 3</div><h2 class="split">Tres números que activan obligaciones</h2>
      <div class="n3 mt2">
        <div class="it" data-s="1"><div class="hero"><span class="cnt" data-pre="Q " data-to="30000">0</span></div><p>por período fiscal: el <b>financista habilita sus libros</b> de contribuciones.<br><span class="law">Reglamento art. 20</span></p></div>
        <div class="it" data-s="2"><div class="hero"><span class="cnt" data-pre="> Q " data-to="50000">0</span></div><p><b>Declaración jurada</b> en acta notarial y pago por banco.<br><span class="law">Reglamento art. 22</span></p></div>
        <div class="it" data-s="3"><div class="hero"><span class="cnt" data-to="10" data-suf=" %">0</span></div><p>del techo de campaña: <b>tope por unidad de vinculación</b>.<br><span class="law">art. 21 Ter g</span></p></div>
      </div>
      <p class="small mt2" data-s="4">Los aportes múltiples de una misma persona en el período se consideran una sola transacción.</p>$q$, $q$<p>Q30,000 y Q50,000 son umbrales por período fiscal, no por aporte. Los aportes múltiples se acumulan.</p><p>Los aportes en dinero superiores al umbral de declaración jurada solo pueden hacerse por cheque, transferencia o medio del sistema bancario.</p>$q$, $q${}$q$, false),
  (31, 3, $q$ejemplo-formal-financiamiento-de-futuro-retalteco$q$, $q$Ejemplo formal: financiamiento de Futuro Retalteco$q$, 1.8, $q$hs$q$, false, $q$<div class="kick a">Ejemplo formal estructurado</div><h2 class="split">Futuro Retalteco paso a paso</h2>
      <table class="t sm"><thead><tr><th class="">Paso</th><th class="">Cálculo</th><th class="r">Resultado</th></tr></thead><tbody><tr data-s="1" class=""><td class="">1. Derecho</td><td class="">Una diputación (excepción al 5 %)</td><td class="r">Sí</td></tr><tr data-s="2" class=""><td class="">2. Total del período</td><td class="">150,000 × US$2</td><td class="r">US$300,000</td></tr><tr data-s="3" class=""><td class="">3. Cuota anual</td><td class="">US$300,000 ÷ 4</td><td class="r">US$75,000</td></tr><tr data-s="4" class=""><td class="">4. En quetzales</td><td class="">US$75,000 × 7.62</td><td class="r">Q571,500</td></tr><tr data-s="5" class=""><td class="">5. Formación 30 %</td><td class="">Q571,500 × 0.30</td><td class="r">Q171,450</td></tr><tr data-s="6" class=""><td class="">6. Sede nacional 20 %</td><td class="">Q571,500 × 0.20</td><td class="r">Q114,300</td></tr><tr data-s="7" class=""><td class="">7. Territorio 50 %</td><td class="">Q571,500 × 0.50</td><td class="r">Q285,750</td></tr><tr data-s="8" class=""><td class="">&nbsp;&nbsp;↳ Departamentos 1/3</td><td class="">Q285,750 ÷ 3</td><td class="r">Q95,250</td></tr><tr data-s="9" class=""><td class="">&nbsp;&nbsp;↳ Municipios 2/3</td><td class="">Q285,750 × 2 ÷ 3</td><td class="r">Q190,500</td></tr></tbody></table>$q$, $q$<p>Recorra los nueve pasos. Es el cálculo que el contador debe poder defender ante la Unidad Especializada. Cifras ilustrativas con tipo de cambio supuesto de Q7.62.</p><p>Estos montos son los que se registran luego en el Diario del caso práctico.</p>$q$, $q${}$q$, false),
  (32, 3, $q$techo-2027-y-conclusion$q$, $q$Techo 2027 y conclusión$q$, 1.1, $q$$q$, false, $q$<div class="kick a">Ejemplo formal estructurado</div><h2 class="split">Y el techo para 2027</h2>
      <table class="t "><tbody><tr data-s="1" class=""><td class="">Techo (10.2 millones × US$0.50 × 7.62)</td><td class="r"><b>Q38,862,000</b></td></tr><tr data-s="2" class=""><td class="">Máximo por aportante o unidad (10 %)</td><td class="r"><b>Q3,886,200</b></td></tr><tr data-s="3" class=""><td class="">Si la cuota 2027 se usa toda en campaña</td><td class="r"><b>Q571,500</b> cuentan contra el techo</td></tr></tbody></table>
      <div class="mt2"><div class="note ok " data-s="4"><b>Para llevarse</b>Tres controles permanentes: <b>derecho</b> al aporte público, <b>distribución</b> 30/20/50 y <b>acumulado de campaña</b> contra el techo.</div></div>$q$, $q$<p>Cierre de la sección III. Abra una ronda de preguntas de 3 a 5 minutos sobre financiamiento antes de pasar a cuentas bancarias y libros.</p>$q$, $q${}$q$, false),
  (33, 4, $q$seccion-iv-sistema-de-cuentas-bancarias$q$, $q$Sección IV · Sistema de cuentas bancarias$q$, 0.2, $q$vc$q$, true, $q$<div class="divider"><div class="rn a-z">IV</div><div><div class="kick a">Sección IV de IX</div><h2 class="split">Sistema de cuentas bancarias</h2><p class="lead a">Todo el dinero pasa por el banco: qué cuentas, para qué y con qué firmas, y cómo se comprueba cada ingreso y cada gasto.</p><div class="secs a"><i class="">Antecedentes</i><i class="">Marco legal</i><i class="">Financiamiento</i><i class="on">Cuentas bancarias</i><i class="">Libros</i><i class="">Plan de cuentas</i><i class="">Estados financieros</i><i class="">Caso práctico</i><i class="">Obligaciones y SAT</i></div></div></div>$q$, $q$<p>Un depósito bancario deja huella: fecha, monto y origen. Por eso la ley exige cuentas separadas por origen.</p>$q$, $q${}$q$, false),
  (34, 4, $q$cuentas-bancarias-obligatorias$q$, $q$Cuentas bancarias obligatorias$q$, 1.5, $q$$q$, false, $q$<div class="kick a">Sección IV · Sistema bancario <span class="law">art. 21 a</span></div><h2 class="split">Cuentas <em>separadas</em> por origen</h2>
      <div class="bank4">
        <div class="card blue" data-s="1" style="min-height:230px"><h4>Financiamiento público</h4><p>Mínimo una a nivel nacional. Recibe la cuota del Estado.</p></div>
        <div class="card hot" data-s="2" style="min-height:230px"><h4>Financiamiento privado</h4><p>Una a nivel nacional. Cuotas, donaciones y autofinanciamiento.</p></div>
        <div class="card red" data-s="3" style="min-height:230px"><h4>Campaña electoral</h4><p>Se abre en el último cuatrimestre del año previo; activa al iniciar el año electoral.</p></div>
        <div class="card green" data-s="4" style="min-height:230px"><h4>Departamentales y municipales</h4><p>Una por organización partidaria vigente, a nombre de su secretario.</p></div>
      </div>$q$, $q$<p>Reglamento arts. 18 y 19. Una cuenta para financiamiento público, una para privado, una específica de campaña (se abre en el último cuatrimestre del año anterior y debe estar abierta al inicio del año electoral) y cuentas por cada sede departamental o municipal con organización vigente.</p><p>El Instructivo, redactado antes, habla de abrir la cuenta de campaña en noviembre; el reglamento vigente fija el último cuatrimestre.</p>$q$, $q${}$q$, false),
  (35, 4, $q$reglas-comunes-de-las-cuentas$q$, $q$Reglas comunes de las cuentas$q$, 1.1, $q$$q$, false, $q$<div class="kick a">Sección IV · Sistema bancario</div><h2 class="split">Reglas comunes <span class="law">Reglamento arts. 18 y 19</span></h2>
      <ul class="gl "><li data-s="1">A nombre del partido, en cualquier banco, con <b>firmas mancomunadas</b></li><li data-s="2">Aviso escrito a la Unidad Especializada en <b>5 días hábiles</b> de cada apertura</li><li data-s="3">La cuenta de campaña se cancela dentro de <b>3 meses</b> de concluido el proceso; con obligaciones pendientes, hasta 6 meses</li><li data-s="4">En año electoral, la cuota pública para campaña se maneja en la cuenta de campaña</li><li data-s="5">Cada secretario liquida los fondos <b>trimestralmente</b>, bajo juramento y con facturas</li></ul>$q$, $q$<p>El partido registra en una «cuenta por liquidar» los fondos entregados a cada secretario departamental o municipal, quienes envían informes trimestrales bajo juramento a la secretaría de finanzas.</p><p>Si un secretario no acepta los fondos, el secretario general con el de finanzas pueden pagar directamente servicios o bienes a favor de ese departamento o municipio, con control interno.</p>$q$, $q${}$q$, false),
  (36, 4, $q$el-recibo-de-ingreso$q$, $q$El recibo de ingreso$q$, 1.5, $q$hs$q$, false, $q$<div class="kick a">Sección IV · Comprobantes</div><h2 class="split">Recibo autorizado por la SAT <span class="law">Reglamento art. 19</span></h2>
      <p class="lead a">Todo ingreso, en dinero o en especie, se acredita con un recibo que imprime el partido. Debe contener como mínimo:</p>
      <div class="recs a">
        <div><i>1</i>Nombre o razón social</div><div><i>2</i>Afiliado o simpatizante</div><div><i>3</i>NIT</div><div><i>4</i>CUI (DPI)</div>
        <div><i>5</i>Dirección</div><div><i>6</i>Descripción del aporte</div><div><i>7</i>Monto</div><div><i>8</i>Declaración de procedencia lícita</div>
        <div><i>9</i>Valor estimado (justiprecio)</div><div><i>10</i>Fecha del aporte</div><div><i>11</i>Firma y sello del receptor</div><div><i>12-13</i>Firma del secretario que acepta</div>
      </div>
      <div class="mt"><div class="note  " data-s="1"><b>Control</b>El partido lleva control de los recibos usados en cada sede y los reporta en sus informes trimestrales.</div></div>$q$, $q$<p>Son trece datos mínimos: nombres o razón social; afiliado o simpatizante; NIT; CUI; dirección; descripción; monto; declaración de procedencia (que no está en prohibiciones); valor estimado y justiprecio; fecha; firma y sello del receptor; firma del secretario general, departamental o municipal que acepta; y, para comités cívicos, la firma de su presidente.</p>$q$, $q${}$q$, false),
  (37, 4, $q$respaldo-de-los-gastos$q$, $q$Respaldo de los gastos$q$, 1.1, $q$$q$, false, $q$<div class="kick a">Sección IV · Comprobantes</div><h2 class="split">Qué respalda un gasto <span class="law">Reglamento art. 24</span></h2>
      <table class="t "><tbody><tr data-s="1" class=""><td class=""><b>Factura autorizada por la SAT</b></td><td class="">Compras y servicios</td></tr><tr data-s="2" class=""><td class=""><b>Recibos de caja o notas de débito</b></td><td class="">De entidades vigiladas por la Superintendencia de Bancos</td></tr><tr data-s="3" class=""><td class=""><b>Planillas IGSS y libros de salarios</b></td><td class="">Sueldos, salarios y prestaciones</td></tr><tr data-s="4" class=""><td class=""><b>Otros que autorice la SAT</b></td><td class="">Documentos de legítimo abono</td></tr></tbody></table>
      <div class="mt2"><div class="note warn " data-s="5"><b>Siempre a nombre de la organización política</b>Un gasto sin documento legal es un hallazgo seguro.</div></div>$q$, $q$<p>Todo gasto, sin excepción, debe tener documentación legal emitida a nombre de la organización política. Esto incluye los gastos de los secretarios departamentales y municipales al liquidar el financiamiento público (art. 18 e).</p>$q$, $q${}$q$, false),
  (38, 5, $q$seccion-v-libros-obligatorios$q$, $q$Sección V · Libros obligatorios$q$, 0.2, $q$vc$q$, true, $q$<div class="divider"><div class="rn a-z">V</div><div><div class="kick a">Sección V de IX</div><h2 class="split">Libros obligatorios</h2><p class="lead a">La contabilidad se lleva en libros habilitados por la SAT; la vigilancia de contribuciones, en libros habilitados por el TSE.</p><div class="secs a"><i class="">Antecedentes</i><i class="">Marco legal</i><i class="">Financiamiento</i><i class="">Cuentas bancarias</i><i class="on">Libros</i><i class="">Plan de cuentas</i><i class="">Estados financieros</i><i class="">Caso práctico</i><i class="">Obligaciones y SAT</i></div></div></div>$q$, $q$<p>Dos juegos de libros con finalidades distintas: los contables y los de contribuciones.</p>$q$, $q${}$q$, false),
  (39, 5, $q$libros-contables-sat$q$, $q$Libros contables (SAT)$q$, 1.5, $q$$q$, false, $q$<div class="kick a">Sección V · Libros contables <span class="law">Reglamento art. 11</span></div><h2 class="split">Habilitados por la <em>SAT</em></h2>
      <table class="t sm"><thead><tr><th class="">Libro</th><th class="">Qué registra</th><th class="">Para qué sirve</th></tr></thead><tbody><tr data-s="1" class=""><td class=""><b>Diario</b></td><td class="">Cada operación en orden de fecha, con su partida</td><td class="">Deja la historia cronológica</td></tr><tr data-s="2" class=""><td class=""><b>Mayor</b></td><td class="">Movimientos agrupados por cuenta</td><td class="">Muestra el saldo de cada cuenta</td></tr><tr data-s="3" class=""><td class=""><b>Inventarios</b></td><td class="">Bienes y derechos del partido</td><td class="">Respalda patrimonio y activo fijo</td></tr><tr data-s="4" class=""><td class=""><b>Estados financieros</b></td><td class="">Balance, ingresos y egresos, notas</td><td class="">Informa la situación y el resultado</td></tr></tbody></table>
      <div class="cols c3 mt" style="gap:22px">
        <div class="card  " data-s="5"><h4>Al día</h4><p>Operaciones asentadas dentro de 2 meses calendario.</p></div>
        <div class="card  " data-s="6"><h4>Conservación</h4><p>Cinco años, ordenados, para la fiscalización.</p></div>
        <div class="card green " data-s="7"><h4>Contador externo</h4><p>Se informa a la Unidad en 10 días hábiles.</p></div>
      </div>$q$, $q$<p>Contabilidad centralizada, por partida doble, con registros físicos y electrónicos y documentos de soporte (art. 11). Los libros permanecen en la sede central y el TSE tiene acceso permanente.</p><p>La documentación del interior del país debe llegar a la sede central para el registro centralizado. Contratar contabilidad externa no exime de tener toda la documentación disponible.</p>$q$, $q${}$q$, false),
  (40, 5, $q$libros-de-contribuciones-tse$q$, $q$Libros de contribuciones (TSE)$q$, 1.5, $q$$q$, false, $q$<div class="kick a">Sección V · Libros de contribuciones <span class="law">art. 21 Ter c</span></div><h2 class="split">Habilitados por la <em>Unidad Especializada</em></h2>
      <div class="cols c2" style="gap:26px">
        <div class="card  " data-s="1"><h4>Contribuciones en efectivo</h4><p>Todo aporte en dinero al partido y lo que un financista da en beneficio de un candidato.</p></div>
        <div class="card  " data-s="2"><h4>Contribuciones en especie</h4><p>Cada aporte no dinerario a valor de mercado, con el criterio de un tercero independiente.</p></div>
        <div class="card blue " data-s="3"><h4>Formación por entidades extranjeras</h4><p>Ingresos y gastos de formación financiados desde el exterior.</p></div>
        <div class="card green " data-s="4"><h4>Formación por entidades nacionales</h4><p>Mismo detalle, para entidades del país (Instructivo).</p></div>
      </div>
      <div class="mt"><div class="note  " data-s="5"><b>Los financistas también llevan libros</b>Quien aporta Q30,000 o más en un período fiscal habilita los suyos. Con ellos el TSE verifica que el dinero existía seis meses antes.</div></div>$q$, $q$<p>Estos libros no sustituyen a la contabilidad; la complementan. Vigilan <b>quién aporta</b>. Los registros contables de los partidos son públicos.</p>$q$, $q${}$q$, false),
  (41, 5, $q$como-se-complementan-los-libros$q$, $q$Cómo se complementan los libros$q$, 0.9, $q$vc$q$, false, $q$<div class="kick a">Sección V · Libros</div><h2 class="split">Del recibo al informe</h2>
      <div class="flow mt2" style="height:280px">
        <div class="st a"><b>Recibo</b>Prueba del aporte</div>
        <div class="st" data-s="1"><b>Libro de contribuciones</b>Quién y cuánto</div>
        <div class="st" data-s="2"><b>Diario y Mayor</b>Registro contable</div>
        <div class="st" data-s="3"><b>Informes</b>Rendición al TSE</div>
      </div>
      <p class="lead mt2" data-s="4">Cada dato nace en un documento y termina en un informe. Si un eslabón falta, la cadena se rompe.</p>$q$, $q$<p>Resuma la sección: recibo, libro de contribuciones, contabilidad y rendición de cuentas. Los informes se publican en el portal del TSE.</p>$q$, $q${}$q$, false),
  (42, 6, $q$seccion-vi-plan-de-cuentas$q$, $q$Sección VI · Plan de cuentas$q$, 0.2, $q$vc$q$, true, $q$<div class="divider"><div class="rn a-z">VI</div><div><div class="kick a">Sección VI de IX</div><h2 class="split">Plan de cuentas</h2><p class="lead a">La nomenclatura contable del Instructivo del TSE: cinco niveles, cinco grupos y un código para cada concepto.</p><div class="secs a"><i class="">Antecedentes</i><i class="">Marco legal</i><i class="">Financiamiento</i><i class="">Cuentas bancarias</i><i class="">Libros</i><i class="on">Plan de cuentas</i><i class="">Estados financieros</i><i class="">Caso práctico</i><i class="">Obligaciones y SAT</i></div></div></div>$q$, $q$<p>La nomenclatura es la columna vertebral del registro. El Instructivo la fija y el partido puede agregar cuentas correlativas.</p>$q$, $q${}$q$, false),
  (43, 6, $q$como-se-codifica-una-cuenta$q$, $q$Cómo se codifica una cuenta$q$, 1.1, $q$$q$, false, $q$<div class="kick a">Sección VI · Plan de cuentas</div><h2 class="split">Cinco niveles, <em>un</em> código</h2>
      <div class="mt"><div class="code a"><span class="on">4</span><span style="color:#5a4c2c">-</span><span class="off">2</span><span style="color:#5a4c2c">-</span><span class="off">1</span><span style="color:#5a4c2c">-</span><span class="off">102</span><span style="color:#5a4c2c">-</span><span class="off">01</span></div></div>
      <div class="lvls">
        <div class="lv on a"><b>1 dígito</b>Grupo<br>4 · Ingresos</div>
        <div class="lv" data-s="1"><b>2 dígitos</b>Subgrupo<br>4-2 · Financiamiento privado</div>
        <div class="lv" data-s="2"><b>3 dígitos</b>Cuenta<br>4-2-1 · Financiamiento privado</div>
        <div class="lv" data-s="3"><b>4 dígitos</b>Cuenta principal<br>4-2-1-102 · Afiliados</div>
        <div class="lv" data-s="4"><b>5 dígitos</b>Cuenta auxiliar<br>4-2-1-102-01 · Cuotas ordinarias</div>
      </div>
      <p class="small mt2 center" data-s="5">«Si la organización utiliza otras cuentas, pueden agregarse en el rubro que corresponda, correlativamente».</p>$q$, $q$<p>Ejemplo: <b>4-2-1-102-01</b> es «Afiliados: cuotas ordinarias». El primer dígito es el grupo; los dos primeros, el subgrupo; los tres primeros, la cuenta; los cuatro primeros, la cuenta principal; los cinco, la auxiliar.</p><p>No se cambia la codificación de las cuentas existentes; solo se agregan nuevas en el rubro correspondiente.</p>$q$, $q${}$q$, true),
  (44, 6, $q$grupo-1-activo$q$, $q$Grupo 1: Activo$q$, 1.1, $q$$q$, false, $q$<div class="kick a">Sección VI · Plan de cuentas</div><h2 class="split">Grupo 1 · <em>Activo</em></h2>
      <table class="t sm"><tbody><tr data-s="1" class=""><td class=""><b>1-1-1</b></td><td class="">Efectivo: 101 Caja · 102 Caja chica</td></tr><tr data-s="2" class=""><td class=""><b>1-1-2</b></td><td class="">Bancos: 201 público · 202 privado · 203 departamentos · 204 municipios · 205 campaña</td></tr><tr data-s="3" class=""><td class=""><b>1-1-3</b></td><td class="">Cuentas por cobrar: financiamiento público, afiliados, otras</td></tr><tr data-s="4" class=""><td class=""><b>1-1-4</b></td><td class="">Inventarios: materiales electorales, artículos promocionales</td></tr><tr data-s="5" class=""><td class=""><b>1-1-5</b></td><td class="">Pagados por anticipado: seguros, alquileres, proveedores</td></tr><tr data-s="6" class=""><td class=""><b>1-2-1</b></td><td class="">Propiedad, planta y equipo: mobiliario (104), cómputo (105), vehículos (106) y sus depreciaciones</td></tr><tr data-s="7" class=""><td class=""><b>1-2-2</b></td><td class="">Intangibles: gastos de organización y su amortización</td></tr></tbody></table>$q$, $q$<p>El activo corriente se espera realizar en el período contable o es efectivo sin restricciones. El no corriente se realiza en más de un período o tiene menor liquidez (maquinaria, vehículos, mobiliario y equipo, intangibles).</p>$q$, $q${}$q$, false),
  (45, 6, $q$grupos-2-y-3-pasivo-y-patrimonio$q$, $q$Grupos 2 y 3: Pasivo y Patrimonio$q$, 1.5, $q$$q$, false, $q$<div class="kick a">Sección VI · Plan de cuentas</div><h2 class="split">Grupos 2 y 3 · Pasivo y <em>Patrimonio</em></h2>
      <div class="cols c2" style="gap:30px">
        <div class="card" data-s="1"><h4>2 · Pasivo corriente</h4><p>2-1-1 Documentos por pagar · 2-1-2 Cuentas por pagar (proveedores locales y del exterior) · 2-1-3 Pasivo laboral</p></div>
        <div class="card" data-s="2"><h4>2 · Pasivo no corriente</h4><p>2-2-1 Documentos a largo plazo · 2-2-2 Cuentas por pagar, préstamos bancarios y de terceros</p></div>
        <div class="card green" data-s="3"><h4>3 · Patrimonio partidario</h4><p>3-1-1 Activo neto de la organización</p></div>
        <div class="card green" data-s="4"><h4>3 · Resultados acumulados</h4><p>3-2-1: ejercicios anteriores y presente ejercicio</p></div>
      </div>
      <div class="eq mt2" data-s="5">Activo <em>=</em> Pasivo <em>+</em> Patrimonio</div>$q$, $q$<p>Un pasivo debe poder exigirse por contrato, letra, pagaré, factura cambiaria u otro documento legal y se cancela por el sistema bancario, a nombre del proveedor. La condonación de una deuda se trata como donación.</p><p>En el Balance de Situación, el resultado del ejercicio se suma al patrimonio.</p>$q$, $q${}$q$, false),
  (46, 6, $q$grupo-4-ingresos$q$, $q$Grupo 4: Ingresos$q$, 1.1, $q$hs$q$, false, $q$<div class="kick a">Sección VI · Plan de cuentas</div><h2 class="split">Grupo 4 · <em>Ingresos</em></h2>
      <table class="t sm"><tbody><tr data-s="1" class=""><td class=""><b>4-1</b></td><td class="">Financiamiento público: 4-1-1-101 Cuota política del año</td></tr><tr data-s="2" class=""><td class=""><b>4-2</b></td><td class="">Privado: 101 Simpatizantes · 102 Afiliados (01 ordinarias, 02 extraordinarias) · 103-104 Formación · 105 Candidatos</td></tr><tr data-s="3" class=""><td class=""><b>4-3</b></td><td class="">Autofinanciamiento: conferencias, espectáculos, sorteos, eventos, cenas (105), juegos</td></tr><tr data-s="4" class=""><td class=""><b>4-4</b></td><td class="">Otros ingresos: 4-4-1-101 Productos financieros</td></tr><tr data-s="5" class=""><td class=""><b>4-5</b></td><td class=""><b>Ingresos no dinerarios (cuentas de control):</b> cesión de derechos (4-5-1), donación de bienes y servicios (4-5-2), préstamo o comodato (4-5-3)</td></tr></tbody></table>
      <div class="mt"><div class="note  " data-s="6"><b>Cuentas de control</b>Las cuentas 4-5 y 5-3 no mueven bancos: reflejan el aporte en especie justipreciado, una vez como ingreso y otra como gasto, para vigilar el techo.</div></div>$q$, $q$<p>4-5-2 incluye servicios personales, playeras y gorras, material de propaganda, atención de simpatizantes, alimentos, combustibles, transporte, hospedaje y otros servicios. 4-5-3 incluye vehículos terrestres, aéreos y marítimos, equipo de audio, bienes muebles e inmuebles y otros bienes.</p>$q$, $q${}$q$, false),
  (47, 6, $q$grupo-5-egresos-permanentes$q$, $q$Grupo 5: Egresos permanentes$q$, 1.1, $q$hs$q$, false, $q$<div class="kick a">Sección VI · Plan de cuentas</div><h2 class="split">Grupo 5 · Egresos <em>permanentes</em></h2>
      <table class="t sm"><tbody><tr data-s="1" class=""><td class=""><b>5-1-1</b></td><td class="">Funcionamiento: sueldos (101), alquiler de sedes (102-104), agua, luz y teléfono (105), materiales, mantenimiento, depreciaciones (108)</td></tr><tr data-s="2" class=""><td class=""><b>5-1-2</b></td><td class="">Asambleas de ley: organización nacional, departamental y municipal; medios de comunicación</td></tr><tr data-s="3" class=""><td class=""><b>5-1-3</b></td><td class="">Campañas de afiliación: proselitismo nacional, departamental y municipal; alimentación y hospedaje (305)</td></tr><tr data-s="4" class=""><td class=""><b>5-1-4</b></td><td class="">Formación política por entidades extranjeras</td></tr><tr data-s="5" class=""><td class=""><b>5-1-5</b></td><td class="">Formación política nacional: organización, material didáctico, capacitadores, alimentación, viáticos</td></tr></tbody></table>
      <div class="mt"><div class="note  " data-s="6"><b>Cómo elegir la cuenta</b>Pregúntese para qué se hizo el gasto, no quién lo cobró. Una cena de recaudación va a campañas de afiliación; un taller para fiscales, a formación política.</div></div>$q$, $q$<p>Los gastos permanentes financian proselitismo y funcionamiento en cualquier época (Reglamento art. 3 h).</p>$q$, $q${}$q$, false),
  (48, 6, $q$grupo-5-campana-y-cuentas-de-control$q$, $q$Grupo 5: Campaña y cuentas de control$q$, 1.1, $q$hs$q$, false, $q$<div class="kick a">Sección VI · Plan de cuentas</div><h2 class="split">Grupo 5 · <em>Campaña</em> y control</h2>
      <table class="t sm"><tbody><tr data-s="1" class=""><td class=""><b>5-2-1</b></td><td class="">Propaganda: edición, encuestas, alquiler temporal, viajes, caravanas</td></tr><tr data-s="2" class=""><td class=""><b>5-2-2</b></td><td class="">Materiales y suministros: mantas, pinturas, productos promocionales</td></tr><tr data-s="3" class=""><td class=""><b>5-2-3</b></td><td class="">Movilización: transporte en giras, viáticos, protocolo</td></tr><tr data-s="4" class=""><td class=""><b>5-2-4</b></td><td class="">Alquileres: inmuebles, vehículos, mobiliario y equipo</td></tr><tr data-s="5" class=""><td class=""><b>5-2-5</b></td><td class="">Honorarios: profesionales, servicios personales, asesores, cursos</td></tr><tr data-s="6" class=""><td class=""><b>5-2-6</b></td><td class="">Día de votaciones: fiscales, transporte, alimentación, combustibles</td></tr><tr data-s="7" class=""><td class=""><b>5-3</b></td><td class=""><b>Egresos no dinerarios (control):</b> espejo de 4-5</td></tr></tbody></table>
      <div class="mt"><div class="note warn " data-s="8"><b>Todo cuenta contra el techo</b>Los gastos 5-2 y los aportes en especie de campaña suman para el límite de US$0.50 por empadronado. Controle el acumulado cada mes.</div></div>$q$, $q$<p>Cuando se usa la cuota pública para campaña, esos gastos también cuentan para el techo (art. 21 Bis d).</p>$q$, $q${}$q$, false),
  (49, 6, $q$asientos-tipo-del-instructivo$q$, $q$Asientos tipo del Instructivo$q$, 1.5, $q$hs$q$, false, $q$<div class="kick a">Sección VI · Plan de cuentas</div><h2 class="split">Dos asientos que <em>conviene</em> dominar</h2>
      <div class="pgrid">
        <div class="a">
          <div class="partida"><div class="ph"><span>Cena con servicio donado por un hotel</span><span class="num">10,000</span></div><table>
            <tr><td class="c">5-3-2-206</td><td>Egreso: atención para protocolos</td><td class="d">10,000</td><td class="hh"></td></tr>
            <tr><td class="c">4-5-2-206</td><td class="h">Ingreso: atención para protocolos</td><td class="d"></td><td class="hh">10,000</td></tr></table>
            <div class="gl2">Cuentas de control. Respaldo: recibo de donación no dineraria y factura a nombre del partido.</div></div>
          <div class="partida" data-s="1"><div class="ph"><span>Dinero recaudado en la cena</span><span class="num">100,000</span></div><table>
            <tr><td class="c">1-1-2-202</td><td>Banco financiamiento privado</td><td class="d">100,000</td><td class="hh"></td></tr>
            <tr><td class="c">4-3-1-105</td><td class="h">Desayunos, almuerzos y cenas</td><td class="d"></td><td class="hh">100,000</td></tr></table>
            <div class="gl2">Un recibo por cada participante, según su aportación.</div></div>
        </div>
        <div data-s="2">
          <div class="partida"><div class="ph"><span>Vehículo prestado en comodato</span><span class="num">8,000</span></div><table>
            <tr><td class="c">5-3-3-301</td><td>Egreso: vehículos terrestres</td><td class="d">8,000</td><td class="hh"></td></tr>
            <tr><td class="c">4-5-3-301</td><td class="h">Ingreso: vehículos terrestres</td><td class="d"></td><td class="hh">8,000</td></tr></table>
            <div class="gl2">A valor de alquiler de mercado. Se lleva un registro con la integración y especificaciones del bien prestado.</div></div>
          <div class="note" data-s="3"><b>Regla</b>Un aporte en especie se registra por su valor justipreciado, tanto en ingreso como en egreso.</div>
        </div>
      </div>$q$, $q$<p>Ejemplos tomados del Instructivo del TSE con montos ilustrativos. Primero la donación del servicio (cuentas de control), luego el efectivo recaudado. En el comodato, el inmueble o vehículo se registra como arrendamiento justipreciado.</p>$q$, $q${}$q$, false),
  (50, 7, $q$seccion-vii-estados-financieros-al-tse$q$, $q$Sección VII · Estados financieros al TSE$q$, 0.2, $q$vc$q$, true, $q$<div class="divider"><div class="rn a-z">VII</div><div><div class="kick a">Sección VII de IX</div><h2 class="split">Estados financieros al TSE</h2><p class="lead a">Qué se presenta, cuándo, con qué firmas y por qué plataforma.</p><div class="secs a"><i class="">Antecedentes</i><i class="">Marco legal</i><i class="">Financiamiento</i><i class="">Cuentas bancarias</i><i class="">Libros</i><i class="">Plan de cuentas</i><i class="on">Estados financieros</i><i class="">Caso práctico</i><i class="">Obligaciones y SAT</i></div></div></div>$q$, $q$<p>Tres estados, cinco firmas y un calendario de informes. Esta sección es la lista de verificación del contador.</p>$q$, $q${}$q$, false),
  (51, 7, $q$que-se-presenta$q$, $q$Qué se presenta$q$, 1.5, $q$$q$, false, $q$<div class="kick a">Sección VII · Estados financieros <span class="law">Reglamento art. 13</span></div><h2 class="split">Del 1 de enero al 31 de diciembre</h2>
      <div class="cols c3" style="gap:26px">
        <div class="card  " data-s="1"><h4>Balance de situación general</h4><p>Activo, pasivo y patrimonio a una fecha.</p></div>
        <div class="card  " data-s="2"><h4>Estado de ingresos y egresos</h4><p>Financiamiento público y privado, gastos permanentes y de campaña, resultado.</p></div>
        <div class="card green " data-s="3"><h4>Notas</h4><p>Descripciones y análisis de las cuentas.</p></div>
      </div>
      <div class="mt"><div class="cap a" style="--d:400ms">Dentro de 3 meses del cierre · se adjunta</div></div>
      <ul class="gl sm"><li data-s="4">Libros <b>Diario y Mayor</b> (copia digital) y libros de contribuciones</li><li data-s="5">Certificación del contador general y del secretario de finanzas</li><li data-s="6">Revisión del órgano de fiscalización financiera y autorización del representante legal</li><li data-s="7">Firma y sello de un contador público y auditor con colegiado activo, y <b>dictamen externo</b> costeado por el partido</li></ul>$q$, $q$<p>Los estados se elaboran con NIC y NIIF. Cada documento lleva cinco firmas, según el Instructivo.</p><p>La organización inscrita nueva presenta su <b>balance de apertura</b> dentro del mes siguiente a su inscripción.</p>$q$, $q${}$q$, false),
  (52, 7, $q$calendario-de-informes$q$, $q$Calendario de informes$q$, 1.5, $q$hs$q$, false, $q$<div class="kick a">Sección VII · Estados financieros</div><h2 class="split">Calendario de informes de un partido</h2>
      <table class="t sm"><thead><tr><th class="">Informe</th><th class="">Cuándo</th></tr></thead><tbody><tr data-s="1" class=""><td class=""><b>Estados financieros</b> + Diario, Mayor y contribuciones</td><td class="">Dentro de 3 meses del cierre (31 de marzo)</td></tr><tr data-s="2" class=""><td class=""><b>GR-PRI</b> · financiamiento privado por origen y gastos</td><td class="">Trimestral, dentro del mes posterior; aprobado por el secretario general</td></tr><tr data-s="3" class=""><td class=""><b>INF-FINPU</b> · uso del financiamiento público</td><td class="">Semestral, dentro del mes posterior</td></tr><tr data-s="4" class=""><td class=""><b>INFOCAM</b> · financiero de campaña</td><td class="">Dentro de 3 meses de concluido el proceso</td></tr><tr data-s="5" class=""><td class=""><b>Publicidad</b> · aportes de 2 años, de campaña y balance</td><td class="">30 días antes de la elección <span class="law">art. 21 Quinquies</span></td></tr></tbody></table>
      <div class="mt"><div class="note ok " data-s="6"><b>Si hay un error</b>GR-PRI, INF-FINPU e INFOCAM pueden rectificarse en 30 días de vencido el plazo, tras pedir la habilitación. No se puede si ya inició una auditoría. Plataforma: Sistema Cuentas Claras Guatemala <span class="law">art. 30</span></div></div>$q$, $q$<p>Comités cívicos: informe mensual (INF-COMIT). Asociaciones con fines políticos y comités para constituir partido: semestral.</p><p>Todos los informes deben estar certificados por el contador general y el secretario de finanzas, revisados por el órgano de fiscalización financiera y autorizados por el representante legal.</p>$q$, $q${}$q$, false),
  (53, 7, $q$las-notas-a-los-estados-financieros$q$, $q$Las notas a los estados financieros$q$, 1.1, $q$hs$q$, false, $q$<div class="kick a">Sección VII · Estados financieros</div><h2 class="split">Trece <em>notas</em> a revelar</h2>
      <div class="recs a" style="font-size:25px">
        <div><i>1</i>Antecedentes</div><div><i>2</i>Principios y prácticas</div><div><i>3</i>Caja y bancos</div><div><i>4</i>Cuentas por cobrar</div>
        <div><i>5</i>Inventarios</div><div><i>6</i>Propiedad, planta y equipo</div><div><i>7</i>Documentos y cuentas por pagar</div><div><i>8</i>Pasivo laboral</div>
        <div><i>9</i>Cuentas por pagar a largo plazo</div><div><i>10</i>Patrimonio</div><div><i>11</i>Ingresos</div><div><i>12</i>Otros ingresos</div><div><i>13</i>Egresos</div>
      </div>
      <div class="mt"><div class="note  " data-s="1"><b>Nota 2, el detalle que más se olvida</b>Debe revelar el régimen de impuestos y las exenciones que invoca. Conecta la contabilidad con lo que se hace ante la SAT.</div></div>$q$, $q$<p>La lista es enunciativa, no limitativa. Nota 1: antecedentes (objeto, marco legal, constitución, NIT, fecha y número de inscripción). Nota 2: principios, base de medición, justiprecio y situación tributaria. Las demás detallan cada rubro.</p>$q$, $q${}$q$, false),
  (54, 8, $q$seccion-viii-caso-practico-futuro-retalteco$q$, $q$Sección VIII · Caso práctico: Futuro Retalteco$q$, 0.2, $q$vc$q$, true, $q$<div class="divider"><div class="rn a-z">VIII</div><div><div class="kick a">Sección VIII de IX</div><h2 class="split">Caso práctico: Futuro Retalteco</h2><p class="lead a">Un ejercicio completo, partida por partida: del inicio de actividades al balance y los estados que se presentan al TSE.</p><div class="secs a"><i class="">Antecedentes</i><i class="">Marco legal</i><i class="">Financiamiento</i><i class="">Cuentas bancarias</i><i class="">Libros</i><i class="">Plan de cuentas</i><i class="">Estados financieros</i><i class="on">Caso práctico</i><i class="">Obligaciones y SAT</i></div></div></div>$q$, $q$<p>Es el corazón del taller. Todo se arma desde una sola base de datos, así que el Diario, el Mayor, la balanza y los estados cuadran entre sí. Cifras ficticias.</p>$q$, $q${}$q$, false),
  (55, 8, $q$los-datos-del-caso$q$, $q$Los datos del caso$q$, 1.5, $q$$q$, false, $q$<div class="kick a">Sección VIII · Caso práctico</div><h2 class="split">Conozcamos a <em>Futuro Retalteco</em></h2>
      <table class="t sm"><tbody><tr data-s="1" class=""><td class="">Inscripción</td><td class="">Partido inscrito en el Registro de Ciudadanos desde 2022</td></tr><tr data-s="2" class=""><td class="">Resultado en 2023</td><td class="">150,000 votos y 1 diputación: derecho a financiamiento público</td></tr><tr data-s="3" class=""><td class="">Renovación de órganos</td><td class="">Asamblea nacional inscrita el 5 de enero de 2026</td></tr><tr data-s="4" class=""><td class="">Ejercicio</td><td class="">1 de enero al 31 de diciembre de 2026</td></tr><tr data-s="5" class=""><td class="">Tipo de cambio supuesto</td><td class="">Q7.62 por US$1</td></tr><tr data-s="6" class=""><td class="">Año siguiente</td><td class="">2027, elecciones generales: la cuenta de campaña debe abrirse</td></tr></tbody></table>
      <p class="small mt a" style="--d:900ms">Sede nacional en la ciudad de Guatemala y organización vigente en departamentos y municipios, con base en Retalhuleu.</p>$q$, $q$<p>Presente el partido ficticio. Aclare que todo aplica la ley y el reglamento vigentes pero con cifras inventadas.</p><p>Lo que haremos: preparar el inicio de actividades, registrar 13 partidas en el Diario, pasarlas al Mayor, sacar la balanza, armar Balance y Estado de Ingresos y Egresos y verificar límites.</p>$q$, $q${}$q$, false),
  (56, 8, $q$el-inicio-de-actividades$q$, $q$El inicio de actividades$q$, 1.8, $q$hs$q$, false, $q$<div class="kick a">Sección VIII · Caso práctico</div><h2 class="split">El inicio de actividades</h2>
      <div class="cols c12" style="gap:50px;align-items:start">
        <div class="tl sm">
          <div class="ev key" data-s="1"><div class="yr">5 ene</div><div class="tx">Se inscriben en el Registro de Ciudadanos los órganos permanentes renovados.</div></div>
          <div class="ev" data-s="2"><div class="yr">≤ 15 días</div><div class="tx"><b>Nombra al contador general</b> <span class="law">Reglamento art. 12</span></div></div>
          <div class="ev" data-s="3"><div class="yr">≤ 10 h.</div><div class="tx">Notifica a la Unidad con copia del <b>RTU</b> del contador.</div></div>
          <div class="ev" data-s="4"><div class="yr">Enero</div><div class="tx">Habilita libros (SAT: contables; UECFFPP: contribuciones) y verifica sus cuentas.</div></div>
        </div>
        <div class="card hot" data-s="5"><h4>Balance de apertura (Q)</h4>
          <table class="t sm"><tbody><tr  class=""><td class="">Banco financiamiento privado</td><td class="r">50,000</td></tr><tr  class=""><td class="">Mobiliario y equipo</td><td class="r">30,000</td></tr><tr  class="tot"><td class="">Activo</td><td class="r">80,000</td></tr><tr  class=""><td class="">Pasivo</td><td class="r">0</td></tr><tr  class="tot"><td class="">Patrimonio partidario</td><td class="r">80,000</td></tr></tbody></table>
          <p class="small">Certificado por contador general y secretario de finanzas.</p></div>
      </div>
      <p class="small mt" data-s="6">Para 2027, la cuenta de campaña debe abrirse entre septiembre y diciembre de 2026 <span class="law">Reglamento art. 19</span>.</p>$q$, $q$<p>Antes del primer asiento: el contador general se nombra dentro de 15 días de la inscripción de los órganos permanentes y se notifica a la Unidad en 10 días hábiles con copia del RTU actualizado donde conste su inscripción.</p><p>El balance de apertura: banco privado Q50,000 + mobiliario Q30,000 = patrimonio partidario Q80,000. Pasivo cero.</p>$q$, $q${}$q$, false),
  (57, 8, $q$libro-diario-1$q$, $q$Libro Diario 1$q$, 1.5, $q$hs$q$, false, $q$<div class="kick a">Sección VIII · Libro Diario 1 de 4</div><h2 class="split">Partidas <em>1 a 4</em></h2><div class="pgrid"><div class="partida" data-s="1"><div class="ph"><span>P1 · 01-ene · Apertura del ejercicio</span><span class="num">80,000</span></div><table><tr><td class="c">1-1-2-202</td><td>Banco financiamiento privado</td><td class="d">50,000</td><td class="hh"></td></tr><tr><td class="c">1-2-1-104</td><td>Mobiliario y equipo</td><td class="d">30,000</td><td class="hh"></td></tr><tr><td class="c">3-1-1</td><td class="h">Patrimonio partidario</td><td class="d"></td><td class="hh">80,000</td></tr></table><div class="gl2">Saldos iniciales certificados por contador general y secretario de finanzas.</div></div><div class="partida" data-s="2"><div class="ph"><span>P2 · 15-feb · Cuotas de afiliados</span><span class="num">24,000</span></div><table><tr><td class="c">1-1-2-202</td><td>Banco financiamiento privado</td><td class="d">24,000</td><td class="hh"></td></tr><tr><td class="c">4-2-1-102-01</td><td class="h">Afiliados: cuotas ordinarias</td><td class="d"></td><td class="hh">24,000</td></tr></table><div class="gl2">Un recibo SAT por cada afiliado.</div></div><div class="partida" data-s="3"><div class="ph"><span>P3 · 10-mar · Donación en efectivo</span><span class="num">15,000</span></div><table><tr><td class="c">1-1-2-202</td><td>Banco financiamiento privado</td><td class="d">15,000</td><td class="hh"></td></tr><tr><td class="c">4-2-1-101</td><td class="h">Aportaciones de simpatizantes</td><td class="d"></td><td class="hh">15,000</td></tr></table><div class="gl2">Simpatizante persona individual; anotada en el libro de contribuciones en efectivo.</div></div><div class="partida" data-s="4"><div class="ph"><span>P4 · 30-abr · Alquiler de sede central</span><span class="num">12,000</span></div><table><tr><td class="c">5-1-1-102</td><td>Arrendamiento de sedes centrales</td><td class="d">12,000</td><td class="hh"></td></tr><tr><td class="c">1-1-2-202</td><td class="h">Banco financiamiento privado</td><td class="d"></td><td class="hh">12,000</td></tr></table><div class="gl2">Factura a nombre del partido; pago por transferencia.</div></div></div>$q$, $q$<p>Apertura, cuotas de afiliados (recibo SAT por cada uno), donación en efectivo de un simpatizante y alquiler de la sede central pagado por transferencia con factura a nombre del partido. Cada partida cuadra: debe = haber.</p>$q$, $q${}$q$, false),
  (58, 8, $q$libro-diario-2$q$, $q$Libro Diario 2$q$, 1.8, $q$hs$q$, false, $q$<div class="kick a">Sección VIII · Libro Diario 2 de 4</div><h2 class="split">Partidas <em>5 a 8</em></h2><div class="pgrid"><div class="partida" data-s="1"><div class="ph"><span>P5 · 18-jun · Costo de la cena</span><span class="num">6,000</span></div><table><tr><td class="c">5-1-3-305</td><td>Campañas de afiliación: alimentación y hospedaje</td><td class="d">6,000</td><td class="hh"></td></tr><tr><td class="c">1-1-2-202</td><td class="h">Banco financiamiento privado</td><td class="d"></td><td class="hh">6,000</td></tr></table><div class="gl2">Primero el egreso con recursos propios; luego puede haber autofinanciamiento.</div></div><div class="partida" data-s="2"><div class="ph"><span>P6 · 18-jun · Ingreso por la cena</span><span class="num">18,000</span></div><table><tr><td class="c">1-1-2-202</td><td>Banco financiamiento privado</td><td class="d">18,000</td><td class="hh"></td></tr><tr><td class="c">4-3-1-105</td><td class="h">Autofinanciamiento: desayunos, almuerzos y cenas</td><td class="d"></td><td class="hh">18,000</td></tr></table><div class="gl2">Recibos por cada participante: 60 cubiertos × Q300.</div></div><div class="partida" data-s="3"><div class="ph"><span>P7 · 03-jul · Cuota anual de financiamiento público</span><span class="num">571,500</span></div><table><tr><td class="c">1-1-2-201</td><td>Banco financiamiento público</td><td class="d">571,500</td><td class="hh"></td></tr><tr><td class="c">4-1-1-101</td><td class="h">Cuota política 2026 (financiamiento público)</td><td class="d"></td><td class="hh">571,500</td></tr></table><div class="gl2">150,000 votos × US$2 ÷ 4 años × Q7.62.</div></div><div class="partida" data-s="4"><div class="ph"><span>P8 · 10-jul · Entrega del 50 % a departamentos y municipios</span><span class="num">285,750</span></div><table><tr><td class="c">1-1-2-203</td><td>Bancos cuentas para departamentos</td><td class="d">95,250</td><td class="hh"></td></tr><tr><td class="c">1-1-2-204</td><td>Bancos cuentas para municipios</td><td class="d">190,500</td><td class="hh"></td></tr><tr><td class="c">1-1-2-201</td><td class="h">Banco financiamiento público</td><td class="d"></td><td class="hh">285,750</td></tr></table><div class="gl2">1/3 a departamentos y 2/3 a municipios, según acta certificada del CEN.</div></div></div>$q$, $q$<p>Aquí está el principio del autofinanciamiento: primero el costo de la cena (partida 5) y luego el ingreso (partida 6). Entra el financiamiento público de Q571,500 (partida 7) y se entrega el 50 % a los secretarios (partida 8): Q95,250 a departamentos y Q190,500 a municipios, que quedan por liquidar.</p>$q$, $q${}$q$, false),
  (59, 8, $q$libro-diario-3$q$, $q$Libro Diario 3$q$, 1.5, $q$hs$q$, false, $q$<div class="kick a">Sección VIII · Libro Diario 3 de 4</div><h2 class="split">Partidas <em>9 y 10</em></h2><div class="pgrid"><div class="partida" data-s="1"><div class="ph"><span>P9 · 31-ago · Formación y capacitación (30 %)</span><span class="num">171,450</span></div><table><tr><td class="c">5-1-5-501</td><td>Capacitación: gastos de organización</td><td class="d">40,000</td><td class="hh"></td></tr><tr><td class="c">5-1-5-502</td><td>Capacitación: material didáctico</td><td class="d">30,000</td><td class="hh"></td></tr><tr><td class="c">5-1-5-503</td><td>Capacitación: capacitadores</td><td class="d">60,000</td><td class="hh"></td></tr><tr><td class="c">5-1-5-504</td><td>Capacitación: alimentación</td><td class="d">41,450</td><td class="hh"></td></tr><tr><td class="c">1-1-2-201</td><td class="h">Banco financiamiento público</td><td class="d"></td><td class="hh">171,450</td></tr></table><div class="gl2">Talleres para afiliados, cuadros y fiscales; todo con factura.</div></div><div class="partida" data-s="2"><div class="ph"><span>P10 · 30-sep · Sede nacional (20 %)</span><span class="num">114,300</span></div><table><tr><td class="c">5-1-1-101</td><td>Sueldos, salarios y honorarios</td><td class="d">60,000</td><td class="hh"></td></tr><tr><td class="c">5-1-1-102</td><td>Arrendamiento de sedes centrales</td><td class="d">40,000</td><td class="hh"></td></tr><tr><td class="c">5-1-1-105</td><td>Agua, luz y teléfono</td><td class="d">14,300</td><td class="hh"></td></tr><tr><td class="c">1-1-2-201</td><td class="h">Banco financiamiento público</td><td class="d"></td><td class="hh">114,300</td></tr></table><div class="gl2">Planilla (IGSS), alquiler y servicios de la sede nacional.</div></div></div>$q$, $q$<p>Se ejecutan el 30 % (formación, Q171,450) y el 20 % (sede nacional, Q114,300) del financiamiento público. Todo con factura o planilla IGSS a nombre del partido.</p>$q$, $q${}$q$, false),
  (60, 8, $q$libro-diario-4$q$, $q$Libro Diario 4$q$, 1.5, $q$hs$q$, false, $q$<div class="kick a">Sección VIII · Libro Diario 4 de 4</div><h2 class="split">Partidas <em>11 a 13</em></h2><div class="pgrid"><div class="partida" data-s="1"><div class="ph"><span>P11 · 31-oct · Liquidación de fondos del interior</span><span class="num">285,750</span></div><table><tr><td class="c">5-1-2-202</td><td>Gastos de organización departamentales</td><td class="d">95,250</td><td class="hh"></td></tr><tr><td class="c">5-1-2-203</td><td>Gastos de organización municipales</td><td class="d">190,500</td><td class="hh"></td></tr><tr><td class="c">1-1-2-203</td><td class="h">Bancos cuentas para departamentos</td><td class="d"></td><td class="hh">95,250</td></tr><tr><td class="c">1-1-2-204</td><td class="h">Bancos cuentas para municipios</td><td class="d"></td><td class="hh">190,500</td></tr></table><div class="gl2">Informes bajo juramento con facturas; se cancela lo entregado en la partida 8.</div></div><div class="partida" data-s="2"><div class="ph"><span>P12 · 15-nov · Donación en especie (control)</span><span class="num">5,000</span></div><table><tr><td class="c">5-3-2-204</td><td>Egreso no dinerario: material de información</td><td class="d">5,000</td><td class="hh"></td></tr><tr><td class="c">4-5-2-204</td><td class="h">Ingreso no dinerario: material de información</td><td class="d"></td><td class="hh">5,000</td></tr></table><div class="gl2">Una imprenta dona material informativo; cuentas de control.</div></div><div class="partida" data-s="3"><div class="ph"><span>P13 · 31-dic · Depreciación del mobiliario</span><span class="num">6,000</span></div><table><tr><td class="c">5-1-1-108</td><td>Depreciaciones</td><td class="d">6,000</td><td class="hh"></td></tr><tr><td class="c">1-2-1-110</td><td class="h">Depreciación acumulada de mobiliario y equipo</td><td class="d"></td><td class="hh">6,000</td></tr></table><div class="gl2">20 % anual sobre Q30,000 (LAT art. 19).</div></div></div>$q$, $q$<p>Se liquidan los fondos del interior con informes bajo juramento (partida 11), se registra el aporte en especie en cuentas de control (partida 12) y se cierra con la depreciación del mobiliario al 20 % (partida 13).</p>$q$, $q${}$q$, false),
  (61, 8, $q$libro-mayor-cuentas-t$q$, $q$Libro Mayor: cuentas T$q$, 1.8, $q$hs$q$, false, $q$<div class="kick a">Sección VIII · Libro Mayor</div><h2 class="split">Las cuentas <em>de dinero</em></h2>
      <div class="tgrid"><div class="tacct" data-s="1"><div class="tt">1-1-2-201 · Banco financiamiento público</div><div class="cl"><div><span><i>P7</i>571,500</span></div><div><span><i>P8</i>285,750</span><span><i>P9</i>171,450</span><span><i>P10</i>114,300</span></div></div><div class="sal">Saldo deudor: 0</div></div><div class="tacct" data-s="2"><div class="tt">1-1-2-202 · Banco financiamiento privado</div><div class="cl"><div><span><i>P1</i>50,000</span><span><i>P2</i>24,000</span><span><i>P3</i>15,000</span><span><i>P6</i>18,000</span></div><div><span><i>P4</i>12,000</span><span><i>P5</i>6,000</span></div></div><div class="sal">Saldo deudor: 89,000</div></div><div class="tacct" data-s="3"><div class="tt">1-1-2-203 · Bancos cuentas para departamentos</div><div class="cl"><div><span><i>P8</i>95,250</span></div><div><span><i>P11</i>95,250</span></div></div><div class="sal">Saldo deudor: 0</div></div><div class="tacct" data-s="4"><div class="tt">1-1-2-204 · Bancos cuentas para municipios</div><div class="cl"><div><span><i>P8</i>190,500</span></div><div><span><i>P11</i>190,500</span></div></div><div class="sal">Saldo deudor: 0</div></div><div class="tacct" data-s="5"><div class="tt">3-1-1 · Patrimonio partidario</div><div class="cl"><div></div><div><span><i>P1</i>80,000</span></div></div><div class="sal">Saldo acreedor: 80,000</div></div><div class="tacct" data-s="6"><div class="tt">4-1-1-101 · Cuota política 2026 (financiamiento público)</div><div class="cl"><div></div><div><span><i>P7</i>571,500</span></div></div><div class="sal">Saldo acreedor: 571,500</div></div></div>
      <p class="small mt" data-s="7">El financiamiento público entra (P7), sale a los secretarios (P8) y a gastos (P9 y P10): termina en cero. Los fondos del interior también se cancelan al liquidar (P11).</p>$q$, $q$<p>El Mayor toma cada línea del Diario y la acomoda por cuenta: el debe a la izquierda, el haber a la derecha. «P4» significa partida 4.</p><p>Banco público: entra 571,500; sale 285,750 + 171,450 + 114,300 = 571,500. Saldo cero. Banco privado: saldo deudor Q89,000. Departamentos y municipios: saldo cero tras liquidar.</p>$q$, $q${}$q$, false),
  (62, 8, $q$balanza-de-comprobacion$q$, $q$Balanza de comprobación$q$, 1.1, $q$hs$q$, false, $q$<div class="kick a">Sección VIII · Balanza</div><h2 class="split">Sumas <em>iguales</em></h2>
      <table class="t xxs"><thead><tr><th class="">Código</th><th class="">Cuenta</th><th class="r">Debe</th><th class="r">Haber</th><th class="r">S. deudor</th><th class="r">S. acreedor</th></tr></thead><tbody><tr  class=""><td class="">1-1-2-201</td><td class="">Banco financiamiento público</td><td class="r">571,500</td><td class="r">571,500</td><td class="r"></td><td class="r"></td></tr><tr  class=""><td class="">1-1-2-202</td><td class="">Banco financiamiento privado</td><td class="r">107,000</td><td class="r">18,000</td><td class="r">89,000</td><td class="r"></td></tr><tr  class=""><td class="">1-1-2-203</td><td class="">Bancos cuentas para departamentos</td><td class="r">95,250</td><td class="r">95,250</td><td class="r"></td><td class="r"></td></tr><tr  class=""><td class="">1-1-2-204</td><td class="">Bancos cuentas para municipios</td><td class="r">190,500</td><td class="r">190,500</td><td class="r"></td><td class="r"></td></tr><tr  class=""><td class="">1-2-1-104</td><td class="">Mobiliario y equipo</td><td class="r">30,000</td><td class="r">0</td><td class="r">30,000</td><td class="r"></td></tr><tr  class=""><td class="">1-2-1-110</td><td class="">Depreciación acumulada de mobiliario y equipo</td><td class="r">0</td><td class="r">6,000</td><td class="r"></td><td class="r">6,000</td></tr><tr  class=""><td class="">3-1-1</td><td class="">Patrimonio partidario</td><td class="r">0</td><td class="r">80,000</td><td class="r"></td><td class="r">80,000</td></tr><tr  class=""><td class="">4-1-1-101</td><td class="">Cuota política 2026 (financiamiento público)</td><td class="r">0</td><td class="r">571,500</td><td class="r"></td><td class="r">571,500</td></tr><tr  class=""><td class="">4-2-1-101</td><td class="">Aportaciones de simpatizantes</td><td class="r">0</td><td class="r">15,000</td><td class="r"></td><td class="r">15,000</td></tr><tr  class=""><td class="">4-2-1-102-01</td><td class="">Afiliados: cuotas ordinarias</td><td class="r">0</td><td class="r">24,000</td><td class="r"></td><td class="r">24,000</td></tr><tr  class=""><td class="">4-3-1-105</td><td class="">Autofinanciamiento: desayunos, almuerzos y cenas</td><td class="r">0</td><td class="r">18,000</td><td class="r"></td><td class="r">18,000</td></tr><tr  class=""><td class="">4-5-2-204</td><td class="">Ingreso no dinerario: material de información</td><td class="r">0</td><td class="r">5,000</td><td class="r"></td><td class="r">5,000</td></tr><tr  class=""><td class="">5-1-1-101</td><td class="">Sueldos, salarios y honorarios</td><td class="r">60,000</td><td class="r">0</td><td class="r">60,000</td><td class="r"></td></tr><tr  class=""><td class="">5-1-1-102</td><td class="">Arrendamiento de sedes centrales</td><td class="r">52,000</td><td class="r">0</td><td class="r">52,000</td><td class="r"></td></tr><tr  class=""><td class="">5-1-1-105</td><td class="">Agua, luz y teléfono</td><td class="r">14,300</td><td class="r">0</td><td class="r">14,300</td><td class="r"></td></tr><tr  class=""><td class="">5-1-1-108</td><td class="">Depreciaciones</td><td class="r">6,000</td><td class="r">0</td><td class="r">6,000</td><td class="r"></td></tr><tr  class=""><td class="">5-1-2-202</td><td class="">Gastos de organización departamentales</td><td class="r">95,250</td><td class="r">0</td><td class="r">95,250</td><td class="r"></td></tr><tr  class=""><td class="">5-1-2-203</td><td class="">Gastos de organización municipales</td><td class="r">190,500</td><td class="r">0</td><td class="r">190,500</td><td class="r"></td></tr><tr  class=""><td class="">5-1-3-305</td><td class="">Campañas de afiliación: alimentación y hospedaje</td><td class="r">6,000</td><td class="r">0</td><td class="r">6,000</td><td class="r"></td></tr><tr  class=""><td class="">5-1-5-501</td><td class="">Capacitación: gastos de organización</td><td class="r">40,000</td><td class="r">0</td><td class="r">40,000</td><td class="r"></td></tr><tr  class=""><td class="">5-1-5-502</td><td class="">Capacitación: material didáctico</td><td class="r">30,000</td><td class="r">0</td><td class="r">30,000</td><td class="r"></td></tr><tr  class=""><td class="">5-1-5-503</td><td class="">Capacitación: capacitadores</td><td class="r">60,000</td><td class="r">0</td><td class="r">60,000</td><td class="r"></td></tr><tr  class=""><td class="">5-1-5-504</td><td class="">Capacitación: alimentación</td><td class="r">41,450</td><td class="r">0</td><td class="r">41,450</td><td class="r"></td></tr><tr  class=""><td class="">5-3-2-204</td><td class="">Egreso no dinerario: material de información</td><td class="r">5,000</td><td class="r">0</td><td class="r">5,000</td><td class="r"></td></tr><tr  class="tot"><td class=""></td><td class="">Sumas iguales</td><td class="r">1,594,750</td><td class="r">1,594,750</td><td class="r">719,500</td><td class="r">719,500</td></tr></tbody></table>$q$, $q$<p>Antes de armar los estados se verifica que el debe y el haber sumen igual (Q1,594,750) y que los saldos deudores igualen a los acreedores (Q719,500).</p>$q$, $q${}$q$, false),
  (63, 8, $q$balance-de-situacion-general$q$, $q$Balance de Situación General$q$, 1.5, $q$hs$q$, false, $q$<div class="kick a">Sección VIII · Estado financiero 1 de 2</div><h2 class="split">Balance de Situación General</h2>
      <div class="cols c12" style="gap:50px;align-items:start">
        <div><table class="t sm"><thead><tr><th class="">Al 31 de diciembre de 2026</th><th class="r">Q</th></tr></thead><tbody><tr data-s="1" class=""><td class=""><b>1 · ACTIVO</b></td><td class="r"></td></tr><tr data-s="2" class=""><td class="">Banco financiamiento público</td><td class="r">0</td></tr><tr data-s="3" class=""><td class="">Banco financiamiento privado</td><td class="r">89,000</td></tr><tr data-s="4" class=""><td class="">Bancos departamentos y municipios</td><td class="r">0</td></tr><tr data-s="5" class=""><td class="">Mobiliario y equipo (neto)</td><td class="r">24,000</td></tr><tr data-s="6" class="tot"><td class="">TOTAL ACTIVO</td><td class="r">113,000</td></tr><tr data-s="7" class=""><td class=""><b>2 · PASIVO</b></td><td class="r">0</td></tr><tr data-s="8" class=""><td class=""><b>3 · PATRIMONIO</b></td><td class="r"></td></tr><tr data-s="9" class=""><td class="">Patrimonio partidario</td><td class="r">80,000</td></tr><tr data-s="10" class=""><td class="">Resultado del ejercicio</td><td class="r">33,000</td></tr><tr data-s="11" class="tot"><td class="">TOTAL PASIVO + PATRIMONIO</td><td class="r">113,000</td></tr></tbody></table></div>
        <div class="card hot" data-s="12"><div class="cap">Activo total</div><div class="hero m num"><span class="cnt" data-pre="Q " data-to="113000">0</span></div>
          <div class="note ok" style="margin-top:20px"><b>Cuadra</b>Activo = Pasivo + Patrimonio. El patrimonio creció Q33,000, el resultado del ejercicio.</div></div>
      </div>$q$, $q$<p>Activo: Q89,000 en banco privado + Q24,000 de mobiliario neto (30,000 − 6,000) = <b>Q113,000</b>. Pasivo: cero. Patrimonio: Q80,000 + resultado Q33,000 = Q113,000.</p><p>Los fondos públicos y los de departamentos y municipios cerraron en cero porque se gastaron y se liquidaron.</p>$q$, $q${}$q$, false),
  (64, 8, $q$estado-de-ingresos-y-egresos$q$, $q$Estado de Ingresos y Egresos$q$, 1.5, $q$hs$q$, false, $q$<div class="kick a">Sección VIII · Estado financiero 2 de 2</div><h2 class="split">Estado de Ingresos y <em>Egresos</em></h2>
      <table class="t sm"><thead><tr><th class="">1 de enero al 31 de diciembre de 2026</th><th class="r">Q</th></tr></thead><tbody><tr data-s="1" class=""><td class=""><b>1.1 Financiamiento público</b></td><td class="r">571,500</td></tr><tr data-s="2" class=""><td class=""><b>1.2 Financiamiento privado</b> (cuotas 24,000 · simpatizantes 15,000 · cena 18,000 · especie 5,000)</td><td class="r">62,000</td></tr><tr data-s="3" class="tot"><td class="">TOTAL INGRESOS</td><td class="r">633,500</td></tr><tr data-s="4" class=""><td class=""><b>2.1 Gastos permanentes</b> (funcionamiento, asambleas, afiliación, capacitación, especie)</td><td class="r">600,500</td></tr><tr data-s="5" class=""><td class=""><b>2.2 Gastos de campaña</b></td><td class="r">0</td></tr><tr data-s="6" class="tot"><td class="">TOTAL EGRESOS</td><td class="r">600,500</td></tr><tr data-s="7" class="tot"><td class="">3 · RESULTADO DEL EJERCICIO</td><td class="r">33,000</td></tr></tbody></table>
      <p class="small mt" data-s="8">Los aportes no dinerarios aparecen en ingresos y en egresos por el mismo valor. El resultado es el dinero privado que sobró: Q57,000 de aportes y cena, menos alquiler, costo de la cena y depreciación.</p>$q$, $q$<p>Ingresos: Q571,500 públicos + Q62,000 privados = Q633,500. Egresos: Q600,500. Resultado: Q33,000.</p><p>Desglose de egresos: funcionamiento Q132,300, asambleas de ley Q285,750, campañas de afiliación Q6,000, capacitación Q171,450 y especie Q5,000.</p>$q$, $q${}$q$, false),
  (65, 8, $q$verificacion-final-del-caso$q$, $q$Verificación final del caso$q$, 1.5, $q$hs$q$, false, $q$<div class="kick a">Sección VIII · Verificación</div><h2 class="split">¿Cumple Futuro Retalteco?</h2>
      <table class="t sm"><thead><tr><th class="">Control</th><th class="r">Resultado</th></tr></thead><tbody><tr data-s="1" class=""><td class="">30 % formación: esperado Q171,450</td><td class="r"><span class="green">Q171,450 ✓</span></td></tr><tr data-s="2" class=""><td class="">20 % sede nacional: esperado Q114,300</td><td class="r"><span class="green">Q114,300 ✓</span></td></tr><tr data-s="3" class=""><td class="">50 % departamentos y municipios: esperado Q285,750</td><td class="r"><span class="green">Q285,750 ✓</span></td></tr><tr data-s="4" class=""><td class="">Aporte de Q15,000 frente al límite de Q3,886,200</td><td class="r"><span class="green">Dentro del límite</span></td></tr><tr data-s="5" class=""><td class="">Umbrales de Q30,000 y Q50,000</td><td class="r"><span class="green">No se activan</span></td></tr><tr data-s="6" class=""><td class="">Recibos SAT, facturas a nombre del partido, justiprecio, libros al día</td><td class="r"><span class="green">Sí</span></td></tr></tbody></table>
      <div class="mt"><div class="cap a" style="--d:300ms">Informes por presentar por 2026</div>
      <ul class="gl sm"><li data-s="7"><b>GR-PRI:</b> abril, julio, octubre y enero</li><li data-s="8"><b>INF-FINPU:</b> julio y enero</li><li data-s="9"><b>Estados financieros</b> con Diario, Mayor, contribuciones y dictamen externo: hasta el 31 de marzo de 2027</li></ul></div>$q$, $q$<p>Cierre del caso: todos los controles de reparto, límites y documentación se cumplen. Pregunte a la sala: ¿qué cambiaría en 2027, año electoral? (cuenta de campaña, techo, INFOCAM).</p><p>Abra ronda de preguntas de 5 minutos antes de la sección IX.</p>$q$, $q${}$q$, false),
  (66, 9, $q$seccion-ix-obligaciones-sat-y-cumplimiento$q$, $q$Sección IX · Obligaciones, SAT y cumplimiento$q$, 0.2, $q$vc$q$, true, $q$<div class="divider"><div class="rn a-z">IX</div><div><div class="kick a">Sección IX de IX</div><h2 class="split">Obligaciones, SAT y cumplimiento</h2><p class="lead a">Quién responde por qué, qué pasa si se incumple, qué se hace ante la SAT y la lista final de verificación.</p><div class="secs a"><i class="">Antecedentes</i><i class="">Marco legal</i><i class="">Financiamiento</i><i class="">Cuentas bancarias</i><i class="">Libros</i><i class="">Plan de cuentas</i><i class="">Estados financieros</i><i class="">Caso práctico</i><i class="on">Obligaciones y SAT</i></div></div></div>$q$, $q$<p>Última sección: responsabilidades, sanciones, obligaciones tributarias y lista de cumplimiento.</p>$q$, $q${}$q$, false),
  (67, 9, $q$quien-responde-por-que$q$, $q$Quién responde por qué$q$, 1.5, $q$hs$q$, false, $q$<div class="kick a">Sección IX · Responsables <span class="law">Reglamento art. 14</span></div><h2 class="split">Información financiera con nombre y firma</h2>
      <table class="t sm"><thead><tr><th class="">Quién</th><th class="">Responsabilidad</th></tr></thead><tbody><tr data-s="1" class=""><td class=""><b>Contador general</b></td><td class="">Lleva la contabilidad y certifica los informes. Nombrado en 15 días; notificado en 10 días hábiles.</td></tr><tr data-s="2" class=""><td class=""><b>Secretario de finanzas</b></td><td class="">Certifica los informes y entrega los fondos junto con el secretario general.</td></tr><tr data-s="3" class=""><td class=""><b>Órgano de fiscalización financiera</b></td><td class="">Revisa los informes y reporta anomalías al CEN, que avisa a la Unidad en 5 días.</td></tr><tr data-s="4" class=""><td class=""><b>Secretario general</b></td><td class="">Aprueba y autoriza; responde personalmente por los fondos públicos.</td></tr><tr data-s="5" class=""><td class=""><b>Secretarios departamentales y municipales</b></td><td class="">Administran y liquidan los fondos que reciben.</td></tr></tbody></table>$q$, $q$<p>Reglamento art. 14 y LEPP arts. 19 Bis, 21 Bis y 21 Ter b. La responsabilidad es personal y solidaria entre los secretarios y el secretario de finanzas, según el Instructivo.</p>$q$, $q${}$q$, false),
  (68, 9, $q$obligaciones-permanentes-del-partido$q$, $q$Obligaciones permanentes del partido$q$, 1.1, $q$$q$, false, $q$<div class="kick a">Sección IX · Obligaciones <span class="law">LEPP art. 22</span></div><h2 class="split">Lo que un partido <em>siempre</em> debe hacer</h2>
      <ul class="gl "><li data-s="1">Someter libros y documentos a revisión del TSE en cualquier tiempo</li><li data-s="2">Abstenerse de ayuda económica o trato preferente del Estado no permitido por la ley</li><li data-s="3">Entregar actas de asamblea y cambios de estatutos al Registro de Ciudadanos en 15 días</li><li data-s="4">Llevar un registro depurado de afiliados</li><li data-s="5">Pedir al Registro de Ciudadanos la autorización de los libros de actas</li></ul>$q$, $q$<p>Obligaciones del artículo 22 de la LEPP relevantes para el contador. El partido debe colaborar con el TSE y mantener su documentación en orden y accesible.</p>$q$, $q${}$q$, false),
  (69, 9, $q$sanciones-por-incumplir$q$, $q$Sanciones por incumplir$q$, 1.5, $q$hs$q$, false, $q$<div class="kick a">Sección IX · Consecuencias <span class="law">art. 88</span></div><h2 class="split">Una <em>escalera</em> de sanciones</h2>
      <div class="ladder">
        <div class="rg" data-s="1" style="background:#e9d7a8"><i>1</i>Amonestación pública o privada</div>
        <div class="rg" data-s="2" style="background:#e5c47a"><i>2</i>Multa</div>
        <div class="rg" data-s="3" style="background:#e0ac55"><i>3</i>Suspensión temporal</div>
        <div class="rg" data-s="4" style="background:#e08c55"><i>4</i>Suspensión de la facultad de recibir financiamiento público o privado</div>
        <div class="rg" data-s="5" style="background:#e5805a"><i>5</i>Cancelación del partido</div>
      </div>
      <div class="note warn " data-s="6"><b>Responsabilidad penal</b>Si hay posible delito, el TSE certifica lo conducente al Ministerio Público. Quienes aportan contraviniendo la ley quedan sujetos al Código Penal.</div>$q$, $q$<p>Sin orden de prelación: el TSE gradúa según gravedad y jurisdicción. La cancelación puede declararse de oficio y sin suspensión previa (art. 21 Ter k). En la práctica, se aplican gradualmente con proporcionalidad y razonabilidad (Reglamento art. 14).</p>$q$, $q${}$q$, false),
  (70, 9, $q$que-se-considera-infraccion$q$, $q$Qué se considera infracción$q$, 0.9, $q$$q$, false, $q$<div class="kick a">Sección IX · Consecuencias</div><h2 class="split">Infracciones frecuentes en las cuentas</h2>
      <ul class="gl "><li data-s="1">No presentar informes en plazo, o presentarlos con anomalías o incongruencias</li><li data-s="2">No notificar al contador, o contratar contabilidad externa sin avisar</li><li data-s="3">Aceptar aportes anónimos, prohibidos o sobre el límite del 10 %</li><li data-s="4">Gastar sin documento legal a nombre del partido</li></ul>$q$, $q$<p>Reglamento art. 14: la anomalía, la incongruencia o la no presentación de información financiera en el plazo son causal de sanción. El órgano de fiscalización interna debe reportar anomalías al CEN, que informa a la Unidad en cinco días.</p>$q$, $q${}$q$, false),
  (71, 9, $q$sat-ante-quien-se-inscribe-un-partido$q$, $q$SAT: ante quién se inscribe un partido$q$, 1.5, $q$hs$q$, false, $q$<div class="kick a">Sección IX · Obligaciones ante la SAT</div><h2 class="split">¿Ante quién se <em>inscribe</em> un partido?</h2>
      <div class="cols c2" style="gap:36px">
        <div class="card hot a"><h4>Existencia legal</h4><p>Se constituye en escritura pública y se inscribe en el <b>Registro de Ciudadanos del TSE</b>, donde obtiene su personalidad jurídica <span class="law">LEPP arts. 18-19</span></p></div>
        <div class="card blue a"><h4>Existencia tributaria</h4><p>Ante la <b>SAT</b>, en el Registro Tributario Unificado (RTU), obtiene su NIT. <span class="verify">verificar trámite vigente</span></p></div>
      </div>
      <ul class="gl sm"><li data-s="1">Mantener actualizado el RTU: el NIT va en recibos, facturas y notas</li><li data-s="2">Habilitar los libros contables ante la SAT</li><li data-s="3">Hacer autorizar los recibos de ingreso</li><li data-s="4">Exigir facturas a su nombre en todo gasto</li></ul>$q$, $q$<p>Una cosa es la existencia legal (TSE) y otra la tributaria (SAT). El Registro Tributario Unificado nace del Decreto 25-71.</p><p><b>Falta confirmar con la SAT</b> los detalles del trámite de inscripción como organización política, la constancia de exención y los formularios vigentes.</p>$q$, $q${}$q$, false),
  (72, 9, $q$sat-que-debe-hacer$q$, $q$SAT: qué debe hacer$q$, 1.1, $q$$q$, false, $q$<div class="kick a">Sección IX · Obligaciones ante la SAT</div><h2 class="split">Qué hace el partido <em>ante la SAT</em></h2>
      <div class="cols c2" style="gap:30px">
        <div class="card  " data-s="1"><h4>Solvencia fiscal</h4><p>Sus donantes la necesitan para deducir sus aportes <span class="law">LAT art. 23 s</span></p></div>
        <div class="card blue " data-s="2"><h4>Retenciones</h4><p>Los partidos son agentes de retención del ISR <span class="law">LAT arts. 47, 48, 86</span></p></div>
        <div class="card green " data-s="3"><h4>Planillas</h4><p>Si hay empleados, planilla al IGSS: respalda el gasto <span class="law">Reglamento art. 24 c</span></p></div>
        <div class="card  " data-s="4"><h4>Régimen en notas</h4><p>Revelar en la nota 2 el régimen tributario y las exenciones</p></div>
      </div>$q$, $q$<p>No deduce quien dona a un partido sin solvencia fiscal vigente (LAT art. 23 s). Los partidos actúan como agentes de retención (arts. 47 y 86): retienen el 7 % en el régimen simplificado y entregan constancia en cinco días (art. 48).</p>$q$, $q${}$q$, false),
  (73, 9, $q$impuestos-que-pueden-afectar$q$, $q$Impuestos que pueden afectar$q$, 1.8, $q$hs$q$, false, $q$<div class="kick a">Sección IX · Obligaciones ante la SAT</div><h2 class="split">Impuestos que pueden <em>afectar</em> al partido</h2>
      <table class="t xs"><thead><tr><th class="">Concepto</th><th class="">Tratamiento</th><th class="">Base</th></tr></thead><tbody><tr data-s="1" class=""><td class=""><b>ISR: donaciones y cuotas</b></td><td class="">Renta <b>exenta</b> si el destino es no lucrativo y no se distribuyen utilidades</td><td class="">LAT art. 11 num. 1</td></tr><tr data-s="2" class=""><td class=""><b>ISR: actividades lucrativas</b></td><td class="">Rentas mercantiles, financieras o de servicios están <b>gravadas</b> <span class="verify">caso por caso</span></td><td class="">LAT art. 11 num. 1</td></tr><tr data-s="3" class=""><td class=""><b>Retenciones ISR</b></td><td class="">Agente de retención; 7 % en régimen simplificado, constancia a los 5 días</td><td class="">LAT arts. 47, 48, 86</td></tr><tr data-s="4" class=""><td class=""><b>IVA: cuotas</b></td><td class="">Cuotas periódicas a partidos políticos: <b>exentas</b></td><td class="">IVA art. 7 num. 10</td></tr><tr data-s="5" class=""><td class=""><b>IVA: autofinanciamiento</b></td><td class="">Entradas, rifas o espectáculos pueden estar afectos <span class="verify">confirmar con SAT</span></td><td class="">Ley del IVA</td></tr><tr data-s="6" class=""><td class=""><b>Cuotas IGSS</b></td><td class="">Con planilla: se presenta y respalda el gasto</td><td class="">Reglamento art. 24 c</td></tr></tbody></table>
      <div class="mt"><div class="note  " data-s="7"><b>Regla práctica</b>Lo que se recibe como aporte, cuota o donación es el corazón de la exención. Lo que se vende como negocio se trata distinto: regístrelos en cuentas separadas.</div></div>$q$, $q$<p>Fuente: Ley de Actualización Tributaria (Decreto 10-2012) y Ley del IVA (Decreto 27-92). Las rentas de partidos y comités cívicos están exentas «únicamente por la parte que provenga de donaciones o cuotas ordinarias o extraordinarias»; las actividades lucrativas se gravan y se declaran.</p><p>Recuerde que el Reglamento (art. 29) aclara que cumplirlo no releva de las leyes fiscales.</p>$q$, $q${}$q$, false),
  (74, 9, $q$resumen-de-cumplimiento-clave$q$, $q$Resumen de cumplimiento clave$q$, 2.2, $q$hs$q$, false, $q$<div class="kick a">Resumen de cumplimiento clave</div><h2 class="split">Su lista de <em>verificación</em></h2>
      <div class="chk"><div class="hid" data-s="1">Contador general nombrado y notificado a la UECFFPP con RTU</div><div class="hid" data-s="2">Cuentas separadas: pública, privada, campaña y del interior</div><div class="hid" data-s="3">Firmas mancomunadas y aviso de apertura en 5 días hábiles</div><div class="hid" data-s="4">Libros contables habilitados por la SAT, al día en dos meses</div><div class="hid" data-s="5">Libros de contribuciones habilitados por la UECFFPP</div><div class="hid" data-s="6">Recibo SAT para cada aporte, con sus datos mínimos</div><div class="hid" data-s="7">Ningún aporte anónimo, prohibido ni mayor al 10 % del techo</div><div class="hid" data-s="8">Especie justipreciada y declaración jurada sobre Q50,000</div><div class="hid" data-s="9">Financiamiento público distribuido 30 / 20 / 50 con acta del CEN</div><div class="hid" data-s="10">Fondos del interior liquidados cada trimestre</div><div class="hid" data-s="11">Todo gasto con factura o documento legal a nombre del partido</div><div class="hid" data-s="12">GR-PRI trimestral e INF-FINPU semestral en plazo</div><div class="hid" data-s="13">Estados financieros con dictamen externo antes del 31 de marzo</div><div class="hid" data-s="14">Obligaciones SAT al día: RTU, retenciones y solvencia fiscal</div></div>$q$, $q$<p>Recorra la lista paso a paso; cada paso marca un control. Pida a los asistentes que respondan mentalmente «sí» o «no» para su organización.</p><p>Esta lista puede entregarse impresa al final como material de apoyo (versión del libro).</p>$q$, $q${}$q$, true),
  (75, 9, $q$glosario$q$, $q$Glosario$q$, 1.1, $q$hs$q$, false, $q$<div class="kick a">Glosario</div><h2 class="split">Términos que conviene <em>dominar</em></h2>
      <div class="recs a" style="font-size:25px">
        <div style="display:block"><b style="color:var(--gold2)">CEN</b><br><span style="font-size:23px">Comité Ejecutivo Nacional</span></div><div style="display:block"><b style="color:var(--gold2)">Financista político</b><br><span style="font-size:23px">Persona nacional que aporta en dinero o especie</span></div><div style="display:block"><b style="color:var(--gold2)">Unidad de vinculación</b><br><span style="font-size:23px">Personas con propiedad, administración o control común</span></div><div style="display:block"><b style="color:var(--gold2)">Justiprecio</b><br><span style="font-size:23px">Valor de mercado de un aporte en especie</span></div><div style="display:block"><b style="color:var(--gold2)">Comodato</b><br><span style="font-size:23px">Préstamo de uso de un bien</span></div><div style="display:block"><b style="color:var(--gold2)">Autofinanciamiento</b><br><span style="font-size:23px">Ingresos por actividades propias</span></div><div style="display:block"><b style="color:var(--gold2)">Techo de campaña</b><br><span style="font-size:23px">US$0.50 por empadronado</span></div><div style="display:block"><b style="color:var(--gold2)">GR-PRI</b><br><span style="font-size:23px">Informe trimestral de financiamiento privado</span></div><div style="display:block"><b style="color:var(--gold2)">INF-FINPU</b><br><span style="font-size:23px">Informe semestral del financiamiento público</span></div><div style="display:block"><b style="color:var(--gold2)">INFOCAM</b><br><span style="font-size:23px">Informe financiero de campaña</span></div><div style="display:block"><b style="color:var(--gold2)">UECFFPP</b><br><span style="font-size:23px">Unidad Especializada de Control y Fiscalización</span></div><div style="display:block"><b style="color:var(--gold2)">RTU / NIT</b><br><span style="font-size:23px">Registro y número de identificación tributaria</span></div><div style="display:block"><b style="color:var(--gold2)">LAT</b><br><span style="font-size:23px">Ley de Actualización Tributaria, Decreto 10-2012</span></div>
      </div>$q$, $q$<p>Deje esta lámina proyectada mientras responde preguntas. Sirve de apoyo para términos que salieron durante la sesión.</p>$q$, $q${}$q$, false),
  (76, 9, $q$fuentes-y-advertencias$q$, $q$Fuentes y advertencias$q$, 1.1, $q$hs$q$, false, $q$<div class="kick a">Fuentes</div><h2 class="split">De dónde sale <em>cada dato</em></h2>
      <ul class="gl sm"><li data-s="1">TSE: <i>Ley Electoral y de Partidos Políticos y sus Reglamentos, actualización 2026</i> (Reglamento Ac. 602-2022, reformado por 22-2023 y 60-2026)</li><li data-s="2">Decreto 26-2016, reformas a la LEPP</li><li data-s="3">TSE: <i>Instructivo para la Rendición de Cuentas de las Organizaciones Políticas</i></li><li data-s="4">Decreto 10-2012, Ley de Actualización Tributaria, arts. 11, 23, 47, 48 y 86</li><li data-s="5">Decreto 27-92, Ley del IVA, art. 7 numeral 10</li><li data-s="6">CICIG (2015), <i>El financiamiento de la política en Guatemala</i>; Prensa Libre y Soy502 para el techo estimado</li></ul>
      <div class="note warn " data-s="7"><b>Antes de aplicar</b>Material didáctico a octubre de 2026. Confirme siempre el texto vigente y los formularios con la Unidad Especializada y la SAT. Pendiente: trámite del RTU, constancia de exención, IVA en autofinanciamiento y texto de los Acuerdos 58, 59 y 61-2026.</div>$q$, $q$<p>Cierre con la advertencia: este es material educativo. Los puntos marcados como «verificar» deben confirmarse con la SAT o con un asesor.</p>$q$, $q${}$q$, false),
  (77, null, $q$cierre$q$, $q$Cierre$q$, 1.5, $q$cover$q$, true, $q$<img class="logo a-z" src="assets/logo-monterroso-blanco.png" alt="Firma de Auditoría Monterroso"><div class="rule"></div>
      <h2 class="split">Gracias</h2>
      <p class="lead a" style="--d:700ms">Contabilidad, auditoría y consultoría para organizaciones que rinden cuentas.</p>
      <div class="kick a" style="--d:1000ms;margin-top:30px">Preguntas y conversación</div>$q$, $q$<p>Agradezca y abra espacio de preguntas. Ofrezca entregar el libro interactivo y la lista de cumplimiento como material de seguimiento.</p>$q$, $q${}$q$, false)
) as v(pos, sec_pos, slug, title, minutes, css, nochrome, html, notes, meta, locked)
where d.slug = $q$presentacion-partidos$q$
on conflict (deck_id, slug) do nothing;


-- >>>>>>>>>> 20261006_06_verify.sql
-- =====================================================================
-- FASE 6 de 6 · VERIFICACIÓN. Falla con un mensaje claro si algo no quedó bien.
-- Ejecútela justo después de sembrar (si ya agregó filas propias, el control es "al menos").
-- =====================================================================
do $$
declare n int;
begin
  select count(*) into n from public.mdpp_decks where slug in ('libro-partidos', 'presentacion-partidos');
  if n <> 2 then raise exception 'Se esperaban 2 decks y hay %', n; end if;

  select count(*) into n from public.mdpp_items i join public.mdpp_decks d on d.id = i.deck_id where d.slug = 'libro-partidos';
  if n < 48 then raise exception 'Libro: se esperaban al menos 48 páginas y hay %', n; end if;

  select count(*) into n from public.mdpp_items i join public.mdpp_decks d on d.id = i.deck_id where d.slug = 'presentacion-partidos';
  if n < 77 then raise exception 'Presentación: se esperaban al menos 77 diapositivas y hay %', n; end if;

  select count(*) into n from public.mdpp_sections s join public.mdpp_decks d on d.id = s.deck_id where d.slug = 'presentacion-partidos';
  if n < 9 then raise exception 'Presentación: se esperaban 9 secciones y hay %', n; end if;

  select count(*) into n from pg_class c join pg_namespace ns on ns.oid = c.relnamespace
   where ns.nspname = 'public' and c.relname in ('mdpp_decks', 'mdpp_sections', 'mdpp_items', 'mdpp_item_versions', 'mdpp_editors') and c.relrowsecurity;
  if n <> 5 then raise exception 'RLS no está activa en las 5 tablas (activas: %)', n; end if;

  select count(*) into n from pg_policies where schemaname = 'public' and tablename like 'mdpp\_%';
  if n < 8 then raise exception 'Faltan políticas RLS (hay %)', n; end if;

  raise notice 'MIGRACIÓN CORRECTA: decks=2, libro=48, presentación=77, RLS activa.';
end $$;

-- Resumen visible
select d.slug, d.kind, count(i.*) as filas, count(*) filter (where i.locked) as bloqueadas, count(*) filter (where not i.published) as ocultas
from public.mdpp_decks d left join public.mdpp_items i on i.deck_id = d.id
group by d.slug, d.kind order by d.slug;


commit;
