-- =====================================================================
-- FASE 3 de 6 · SEGURIDAD: editores, RLS y permisos. Requiere FASES 1 y 2.
-- Lectura pública solo de lo publicado; escritura solo para editores.
-- =====================================================================
begin;

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

commit;

-- ---------------------------------------------------------------------
-- DESPUÉS de crear su usuario en Authentication > Users, ejecute UNA vez
-- (cambie el correo) para volverse administrador:
--
--   insert into public.mdpp_editors (user_id, email, role)
--   select id, email, 'admin' from auth.users where email = 'TU_CORREO@DOMINIO.COM'
--   on conflict (user_id) do update set role = 'admin';
-- ---------------------------------------------------------------------
