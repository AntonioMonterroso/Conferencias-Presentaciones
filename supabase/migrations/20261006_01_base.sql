-- =====================================================================
-- FASE 1 de 6 · BASE: funciones auxiliares, decks y secciones
-- Proyecto: Contabilidad de un Partido Político (libro + presentación)
-- Idempotente: se puede ejecutar varias veces sin duplicar nada.
-- =====================================================================
begin;

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

commit;
