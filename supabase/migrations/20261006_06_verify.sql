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
