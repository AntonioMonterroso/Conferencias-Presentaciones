-- =====================================================================
-- REINICIO TOTAL · DESTRUCTIVO · borra TODO el contenido y las ediciones
-- Úselo solo para el protocolo de reinicio. Después ejecute
-- 20261006_00_completa.sql (o las fases 01 a 06 en orden).
-- Las tablas son exclusivas de este proyecto (prefijo mdpp_).
-- =====================================================================
begin;
drop table if exists public.mdpp_item_versions cascade;
drop table if exists public.mdpp_items         cascade;
drop table if exists public.mdpp_sections      cascade;
drop table if exists public.mdpp_decks         cascade;
drop table if exists public.mdpp_editors       cascade;
drop function if exists public.mdpp_snapshot_item();
drop function if exists public.mdpp_is_editor();
drop function if exists public.mdpp_is_admin();
drop function if exists public.mdpp_set_updated_at();
commit;
