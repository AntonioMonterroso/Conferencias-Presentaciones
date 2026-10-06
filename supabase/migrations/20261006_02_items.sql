-- =====================================================================
-- FASE 2 de 6 · CONTENIDO: páginas del libro y diapositivas (mdpp_items)
-- y su historial de versiones. Requiere la FASE 1.
-- Campos editables: title, minutes, css_class, nochrome, html, notes, meta, published
-- =====================================================================
begin;

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

commit;
