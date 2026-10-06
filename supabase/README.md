# Supabase · libro y presentación editables

Tablas (todas con prefijo `mdpp_`): `mdpp_decks`, `mdpp_sections`, `mdpp_items`, `mdpp_item_versions`, `mdpp_editors`.
Campos editables de cada página/diapositiva (`mdpp_items`): `title`, `minutes`, `css_class`, `nochrome`, `html`, `notes`, `meta`, `published`.
Cada cambio de contenido guarda la versión anterior en `mdpp_item_versions`.

## Opción A · una sola ejecución (recomendada para el protocolo)
1. Si va a reiniciar de cero: ejecute `migrations/99_reset_DESTRUCTIVO.sql` (borra todo lo de `mdpp_`).
2. Pegue `migrations/20261006_00_completa.sql` en **SQL Editor** y ejecute. Es una sola transacción: o queda todo, o nada.
   Al final muestra `MIGRACIÓN CORRECTA` y un resumen.

## Opción B · por fases (ejecutar en orden, cada una es idempotente)
| Fase | Archivo | Qué hace |
|---|---|---|
| 1 | `20261006_01_base.sql` | Funciones, `mdpp_decks`, `mdpp_sections` |
| 2 | `20261006_02_items.sql` | `mdpp_items`, historial y trigger de versiones |
| 3 | `20261006_03_security.sql` | Editores, RLS, políticas y permisos |
| 4 | `20261006_04_seed_libro.sql` | 48 páginas del libro |
| 5 | `20261006_05_seed_presentacion.sql` | 77 diapositivas |
| 6 | `20261006_06_verify.sql` | Verifica conteos y RLS; falla con mensaje claro |

Las semillas usan `on conflict do nothing`: volver a ejecutarlas **no pisa sus ediciones**.

## Después de migrar
1. **Authentication > Users**: cree su usuario. Luego ejecute (con su correo):
   `insert into public.mdpp_editors (user_id, email, role) select id, email, 'admin' from auth.users where email = 'TU_CORREO@DOMINIO.COM' on conflict (user_id) do update set role = 'admin';`
2. Edite el contenido en **Table Editor > mdpp_items** (o por SQL).
3. En `config.js` de cada carpeta (libro y presentación): `enabled: true`, `url` y `anonKey` (clave anon/publishable).
   **Nunca** use la `service_role` en estos archivos.
4. Para la cañonera: abra una vez la presentación con internet; queda una copia en el navegador y, si luego no hay red, se usa esa copia o el contenido incluido.

## Qué se puede editar y qué no
- `locked = true` (calculadoras y páginas interactivas: 4 diapositivas y 13 páginas del libro): se editan título, notas y tiempo; el HTML lo gobierna el código.
- `published = false` oculta la página o diapositiva sin borrarla.
- El **orden** y la clave `slug` los define el código; no cambie los `slug`.
- Si cambia el contenido en el código, regenere las migraciones: `node tools/build-seed.js`.

## Aviso
Las migraciones no se probaron contra una instancia real de Postgres/Supabase (no había una disponible aquí); la sintaxis de las semillas se validó y la integración de lectura se probó con un servidor simulado. Pruebe primero en un proyecto de desarrollo.
