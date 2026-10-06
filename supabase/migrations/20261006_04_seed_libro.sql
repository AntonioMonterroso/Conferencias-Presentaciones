-- =====================================================================
-- FASE 4 de 6 · SEMILLA DEL LIBRO (48 páginas, 10 secciones). Requiere FASES 1 a 3.
-- Generado por tools/build-seed.js
-- =====================================================================
begin;

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

commit;
