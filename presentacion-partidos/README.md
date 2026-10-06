# Presentación · Contabilidad de un Partido Político

77 diapositivas (≈ 90 min) con dos vistas sincronizadas.

## Cómo presentar (una laptop, dos ventanas)
1. Sirva la carpeta por http (no por doble clic): `node ../../.claude/static-server-presentacion.js` o cualquier servidor estático / GitHub Pages.
2. Abra `presentador.html` en la pantalla de la laptop.
3. Pulse **Abrir visualizador**; arrastre esa ventana a la cañonera y pulse **F** (o doble clic) para pantalla completa.
4. Avance desde cualquiera de las dos ventanas.

| Tecla | Acción |
|---|---|
| → · Espacio · Re Pág | Siguiente paso o diapositiva (sirve con control remoto) |
| ← · Av Pág | Anterior |
| B o . | Pantalla en negro |
| F | Pantalla completa |
| G | Vista general (solo presentador) |
| T | Iniciar/pausar reloj · A+ / A− tamaño de notas |

El presentador ve la diapositiva actual, la siguiente, notas, reloj con ritmo (adelantado/retrasado) y secciones.

## Contenido editable en Supabase
Ver `../supabase/README.md`. Con `enabled: false` en `config.js` todo funciona con el contenido incluido (sin internet).

## Editor con inicio de sesión
`editor.html` permite editar título, minutos, notas, HTML, clases y publicación de cada diapositiva y página del libro, con vista previa e historial de versiones.
Entra con un usuario de Supabase Auth que esté en `mdpp_editors` (ver `../supabase/README.md`). La sesión vive solo en la pestaña.
