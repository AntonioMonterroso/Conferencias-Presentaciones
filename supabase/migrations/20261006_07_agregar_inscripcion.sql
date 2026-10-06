-- =====================================================================
-- FASE 7 (incremental) · INSCRIPCIÓN DE UN PARTIDO: 12 diapositivas y 2 páginas del libro
-- Úsela SOLO si ya ejecutó las fases 1 a 6 antes de agregar este contenido.
-- Si reinicia de cero con 99_reset + 00_completa, NO la necesita (ya está incluido).
-- Idempotente: no duplica ni pisa lo que usted haya editado.
-- =====================================================================
begin;
-- Las actualizaciones de texto y minutos de filas NO editadas no deben contar como ediciones ni crear historial
alter table public.mdpp_items disable trigger mdpp_items_snapshot;

-- ===== presentacion-partidos: 12 filas nuevas =====
do $$
declare d uuid;
begin
  select id into d from public.mdpp_decks where slug = $q$presentacion-partidos$q$;
  if d is null then raise exception 'No existe el deck presentacion-partidos. Ejecute antes las fases 1 a 6.'; end if;
  -- Hace espacio en el orden solo la primera vez (si la fila nueva ya existe, no mueve nada)
  if not exists (select 1 from public.mdpp_items where deck_id = d and slug = $q$donde-se-inscribe-un-partido-tres-puertas$q$) then
    update public.mdpp_items set pos = pos + 12 where deck_id = d and pos >= 14;
  end if;
end $$;

insert into public.mdpp_items (deck_id, section_id, pos, slug, title, minutes, css_class, nochrome, html, notes, meta, locked)
select d.id,
       (select s.id from public.mdpp_sections s where s.deck_id = d.id and s.pos = v.sec_pos),
       v.pos, v.slug, v.title, v.minutes, v.css, v.nochrome, v.html, v.notes, v.meta::jsonb, v.locked
from public.mdpp_decks d,
(values
  (14, 2, $q$donde-se-inscribe-un-partido-tres-puertas$q$, $q$Dónde se inscribe un partido: tres puertas$q$, 1.3, $q$$q$, false, $q$<div class="kick a">Sección II · Inscripción de un partido</div><h2 class="split">Dónde nace un partido: <em>tres puertas</em></h2>
      <div class="cols c3" style="gap:28px">
        <div class="card hot" data-s="1" style="min-height:520px"><h4>1 · Notario</h4><p>Todo parte de una <b>escritura pública</b>: primero la del comité y luego la del partido.</p><p class="small" style="margin-top:18px">Se otorga ante notario, con comparecencia personal y DPI.</p></div>
        <div class="card blue" data-s="2" style="min-height:520px"><h4>2 · Registro de Ciudadanos del TSE</h4><p>Inscribe al comité, al partido, a sus órganos permanentes y autoriza hojas de adhesión y libros de actas. Trabaja por medio de su <b>Departamento de Organizaciones Políticas</b>.</p></div>
        <div class="card green" data-s="3" style="min-height:520px"><h4>3 · SAT</h4><p>Le da existencia tributaria: <b>RTU y NIT</b>, habilitación de libros contables y recibos autorizados.</p><p class="small" style="margin-top:18px"><span class="verify">verificar trámite vigente</span></p></div>
      </div>
      <p class="small mt" data-s="4">El edicto de inscripción se publica de oficio y gratis en el Diario Oficial. Las finanzas ya las vigila la Unidad Especializada desde que existe el comité.</p>$q$, $q$<p>La pregunta del taller: <b>¿dónde se inscribe un partido y cómo?</b> Hay tres puertas distintas con tres efectos distintos.</p><ul><li><b>Notario:</b> la escritura pública del comité (art. 52) y la del partido (art. 63).</li><li><b>Registro de Ciudadanos del TSE:</b> inscribe el comité, el partido y sus órganos permanentes (arts. 54, 67, 74). El Departamento de Organizaciones Políticas dictamina y ejecuta las inscripciones.</li><li><b>SAT:</b> existencia tributaria (RTU y NIT). Es un trámite aparte; los detalles vigentes para organizaciones políticas deben confirmarse en la SAT.</li></ul><p>Recuerde: ser partido (existencia legal) y ser contribuyente (existencia tributaria) no son lo mismo.</p>$q$, $q${}$q$, false),
  (15, 2, $q$la-ruta-completa-de-la-inscripcion$q$, $q$La ruta completa de la inscripción$q$, 1.7, $q$hs$q$, false, $q$<div class="kick a">Sección II · Inscripción de un partido</div><h2 class="split">La ruta, de principio a fin</h2>
      <div class="flow" style="height:230px">
        <div class="st a"><b>1 · Grupo promotor</b>Acta notarial y Junta Directiva Provisional</div>
        <div class="st" data-s="1"><b>2 · Comité</b>Escritura e inscripción</div>
        <div class="st" data-s="2"><b>3 · Adhesiones</b>Afiliados y organización mínima</div>
        <div class="st" data-s="3"><b>4 · Partido</b>Escritura, solicitud y publicación</div>
        <div class="st" data-s="4"><b>5 · Inscrito</b>Primera Asamblea Nacional</div>
      </div>
      <div class="cols c2 mt" style="gap:28px">
        <div class="card" data-s="5"><h4>Reloj del comité</h4><p>El comité inscrito tiene <b>2 años improrrogables</b> para llegar a la inscripción definitiva <span class="law">art. 58</span></p></div>
        <div class="card green" data-s="6"><h4>Al quedar inscrito</h4><p>Nacen sus obligaciones contables y tributarias: contador, balance de apertura, libros, cuentas y SAT.</p></div>
      </div>$q$, $q$<p>Recorra los cinco hitos. Idea fuerza: <b>dos escrituras públicas y dos inscripciones</b> (comité y partido) en el Registro de Ciudadanos, con un plazo máximo de dos años desde la inscripción del comité.</p><p>Cada hito se detalla en las siguientes láminas con su artículo y sus plazos.</p>$q$, $q${}$q$, false),
  (16, 2, $q$paso-1-grupo-promotor-y-junta-directiva-provisional$q$, $q$Paso 1: grupo promotor y Junta Directiva Provisional$q$, 1.3, $q$hs$q$, false, $q$<div class="kick a">Inscripción · Paso 1 <span class="law">LEPP art. 51 · Reglamento art. 11</span></div><h2 class="split">El <em>grupo promotor</em></h2>
      <div class="cols c2" style="gap:50px;align-items:start">
        <div><ul class="gl sm"><li data-s="1">Grupo de ciudadanos que <b>saben leer y escribir</b> y reúnen <b>más del 2 %</b> del número mínimo de afiliados que exige un partido</li><li data-s="2">Eligen una <b>Junta Directiva Provisional</b> de al menos <b>9</b> personas</li><li data-s="3">La elección consta en <b>acta notarial</b> con el CUI del DPI y el número de empadronamiento</li><li data-s="4">Se presenta solicitud al Registro de Ciudadanos</li></ul></div>
        <div class="stack">
          <div class="card hot" data-s="5"><h4>Ejemplo ilustrativo</h4><p>Con un padrón de 10,200,000 ciudadanos, el mínimo de un partido es 0.30 % = <b class="num"><span class="cnt" data-to="30600">0</span></b> afiliados; el grupo promotor necesita más del 2 %: <b>más de 612</b>.</p></div>
          <div class="card blue" data-s="6"><h4>Trámite en el Registro</h4><p>El Departamento de Organizaciones Políticas depura la solicitud en <b>15 días hábiles</b> y el Director resuelve.</p></div>
        </div>
      </div>$q$, $q$<p>Art. 51 de la LEPP: cualquier grupo que reúna a más del 2 % del número mínimo de ciudadanos requerido para constituir un partido, que sepan leer y escribir, puede organizarse como comité. Primer paso: Junta Directiva Provisional de al menos nueve personas, con acta notarial presentada al Registro.</p><p>El Reglamento (art. 11) exige consignar el CUI del DPI y el número de empadronamiento para la depuración. El incumplimiento lleva al rechazo de la solicitud, impugnable por los recursos de la ley, y luego al archivo.</p><p><b>Cifra ilustrativa:</b> el padrón de 10.2 millones es el mismo supuesto usado para el techo de campaña; el mínimo real depende del padrón de las últimas elecciones generales.</p>$q$, $q${}$q$, false),
  (17, 2, $q$paso-2-escritura-del-comite-y-su-inscripcion$q$, $q$Paso 2: escritura del comité y su inscripción$q$, 1.7, $q$hs$q$, false, $q$<div class="kick a">Inscripción · Paso 2 <span class="law">LEPP arts. 52 a 56</span></div><h2 class="split">La <em>escritura</em> del comité</h2>
      <div class="cols c2" style="gap:44px;align-items:start">
        <div><ul class="gl sm"><li data-s="1">Comparecencia de la mayoría del grupo promotor, con DPI</li><li data-s="2">Nombre, emblema o símbolo del partido por constituirse</li><li data-s="3">Declaración de principios y proyecto de estatutos</li><li data-s="4">Integración de la Junta Directiva y representante legal especial</li><li data-s="5">Manifestación expresa de que se propone constituir un partido y sede provisional</li></ul>
          <p class="small mt" data-s="6">Antes de otorgarla, se presenta la minuta al Director del Registro <span class="law">Reglamento art. 12</span></p></div>
        <div class="stack">
          <div class="card" data-s="2"><h4>Plazo para otorgarla</h4><p><b>3 meses</b> desde que se inscribió la Junta Directiva Provisional; si no, se cancela el trámite.</p></div>
          <div class="card" data-s="4"><h4>Solicitar la inscripción</h4><p><b>30 días</b> desde la escritura, con el testimonio. El Director resuelve en <b>8 días</b>.</p></div>
          <div class="card red" data-s="5"><h4>Si la deniegan</h4><p><b>30 días</b> para subsanar con una nueva escritura; hay apelación.</p></div>
        </div>
      </div>$q$, $q$<p>El artículo 52 enumera lo que contiene la escritura de formalización del comité: comparecencia personal de la mayoría del grupo promotor; nombre y emblema; declaración de principios (con el compromiso de respetar las leyes, la filosofía, el juramento de actuar por vías pacíficas y democráticas y el de respetar la democracia interna); proyecto de estatutos; integración de la junta directiva; manifestación de querer constituir un partido; representante legal especial para el trámite; y sede provisional.</p><p>Plazos: escritura dentro de tres meses desde la inscripción de la junta provisional (art. 51); solicitud de inscripción del comité dentro de treinta días con el testimonio (art. 54); resolución del Director en ocho días (art. 55); si hay defectos, treinta días para subsanar (art. 56).</p>$q$, $q${}$q$, false),
  (18, 2, $q$paso-3-el-comite-inscrito$q$, $q$Paso 3: el comité inscrito$q$, 1, $q$vc$q$, false, $q$<div class="kick a">Inscripción · Paso 3 <span class="law">LEPP arts. 57, 58 y 66</span></div><h2 class="split">Comité inscrito: <em>reloj</em> en marcha</h2>
      <div class="cols c3 mt" style="gap:28px">
        <div class="card hot" data-s="1"><div class="hero m num"><span class="cnt" data-to="2">0</span> años</div><p>Vigencia de la inscripción, <b>improrrogables</b>.</p></div>
        <div class="card" data-s="2"><h4>Personalidad limitada</h4><p>Solo para llegar a ser partido. No puede identificarse como partido ni tiene sus derechos.</p></div>
        <div class="card green" data-s="3"><h4>Prelación del nombre</h4><p>La inscripción da derecho preferente al nombre, emblema o símbolo. Prohibido el quetzal, la bandera y el escudo.</p></div>
      </div>
      <div class="mt2"><div class="note warn " data-s="4"><b>Se pierde la vigencia por</b>Pasar los 2 años sin escritura del partido · incumplir leyes electorales · bajar del mínimo de miembros del grupo promotor · quedar inscrito como partido.</div></div>$q$, $q$<p>Efectos de la inscripción del comité (arts. 57 y 58 y Reglamento art. 14): personalidad jurídica con el único propósito de llegar a ser partido; no puede hacer propaganda, usar nombre o emblema en campañas ni realizar actividades del artículo 20.</p><p>Vigencia de dos años improrrogables, que cesa por vencimiento, por incumplimiento de leyes electorales, por reducción del grupo promotor por debajo del mínimo o al quedar inscrito el partido.</p>$q$, $q${}$q$, false),
  (19, 2, $q$paso-4-hojas-de-adhesion-y-afiliados-minimos$q$, $q$Paso 4: hojas de adhesión y afiliados mínimos$q$, 1.7, $q$hs$q$, false, $q$<div class="kick a">Inscripción · Paso 4 <span class="law">LEPP arts. 19, 59 a 62</span></div><h2 class="split">Las <em>hojas de adhesión</em></h2>
      <div class="cols c2" style="gap:44px;align-items:start">
        <div class="card hot a"><h4>Afiliados mínimos <span class="law">art. 19 a</span></h4><div class="hero m num"><span class="cnt" data-pre="" data-to="0.30" data-dec="2" data-suf=" %">0</span></div><p>del total de ciudadanos del padrón de las últimas elecciones generales. <b>Al menos la mitad</b> debe saber leer y escribir.</p><p class="small" style="margin-top:10px" data-s="1">Ejemplo ilustrativo: padrón de 10,200,000 → <b>30,600</b> afiliados.</p></div>
        <div><ul class="gl sm"><li data-s="2">El Registro entrega hojas <b>numeradas y autorizadas</b></li><li data-s="3">Individuales o colectivas, <b>máximo 10 firmas</b></li><li data-s="4">Cada hoja lleva la declaración jurada de su responsable, con <b>firma legalizada</b></li><li data-s="5">Nombre, DPI, inscripción como ciudadano y firma o huella</li><li data-s="6">El Registro las depura en <b>15 días</b>; si hay datos falsos, pasa al Inspector General</li></ul></div>
      </div>
      <p class="small mt" data-s="7">Las hojas están exentas de timbres fiscales y notariales. Cuando el total depurado llega al mínimo, el Registro avisa al comité.</p>$q$, $q$<p>El mínimo de afiliados es el 0.30 % del padrón de las últimas elecciones generales (art. 19 a), y al menos la mitad debe saber leer y escribir. Los partidos deben volver a cumplirlo cuando se publica un nuevo padrón, en un plazo que termina noventa días antes de la convocatoria a elecciones.</p><p>Hojas de adhesión (arts. 59 y 60): numeradas y autorizadas, hasta diez firmas, con declaración jurada del responsable y firma legalizada por notario. El comité puede entregarlas por partes; el Registro devuelve una copia sellada y las depura en quince días. El Registro provee el programa informático de depuración (Reglamento art. 18).</p><p>Art. 62: cuando el total depurado de adherentes alfabetos alcanza el mínimo, el Registro lo comunica al comité y le requiere presentar la documentación final antes de que venza el plazo de dos años.</p>$q$, $q${}$q$, false),
  (20, 2, $q$paso-5-organizacion-partidaria-minima$q$, $q$Paso 5: organización partidaria mínima$q$, 1.3, $q$vc$q$, false, $q$<div class="kick a">Inscripción · Paso 5 <span class="law">LEPP art. 49</span></div><h2 class="split">La organización mínima <em>vigente</em></h2>
      <div class="n3 mt2">
        <div class="it" data-s="1"><div class="cap">Municipio</div><div class="hero"><span class="cnt" data-to="40">0</span></div><p>afiliados vecinos y su <b>Asamblea Municipal</b>, que elige el Comité Ejecutivo Municipal.</p></div>
        <div class="it" data-s="2"><div class="cap">Departamento</div><div class="hero"><span class="cnt" data-to="4">0</span></div><p>municipios con organización y su <b>Asamblea Departamental</b> con su Comité Ejecutivo.</p></div>
        <div class="it" data-s="3"><div class="cap">Nacional</div><div class="hero"><span class="cnt" data-to="50">0</span> / <span class="cnt" data-to="12">0</span></div><p><b>50 municipios</b> en al menos <b>12 departamentos</b> y la Asamblea Nacional con su Comité Ejecutivo.</p></div>
      </div>
      <p class="small mt2" data-s="4">Estas asambleas se celebran antes de la inscripción; sus comités se vuelven <b>permanentes</b> al quedar inscrito el partido <span class="law">art. 67 c</span></p>$q$, $q$<p>Organización partidaria vigente (art. 49): en el municipio, cuarenta afiliados vecinos y Comité Ejecutivo Municipal electo en Asamblea Municipal; en el departamento, organización en al menos cuatro municipios y Comité Ejecutivo Departamental; a nivel nacional, organización en al menos cincuenta municipios y doce departamentos y Comité Ejecutivo Nacional electo en Asamblea Nacional.</p><p>Para inscribir el partido se prueba con las actas de las primeras asambleas municipales y departamentales, celebradas en cualquier momento antes de la inscripción (art. 67 c).</p><p>Contablemente esto importa: cada órgano permanente podrá tener su cuenta bancaria y recibir parte del financiamiento público (50 % a territorio).</p>$q$, $q${}$q$, false),
  (21, 2, $q$paso-6-escritura-del-partido-y-estatutos$q$, $q$Paso 6: escritura del partido y estatutos$q$, 1.7, $q$hs$q$, false, $q$<div class="kick a">Inscripción · Paso 6 <span class="law">LEPP arts. 63, 65 y 66</span></div><h2 class="split">La <em>escritura</em> del partido</h2>
      <div class="cols c2" style="gap:40px;align-items:start">
        <div><div class="cap a">La escritura contiene</div><ul class="gl sm"><li data-s="1">Comparecencia de toda la Junta Directiva Provisional</li><li data-s="2">Datos de la inscripción del comité y ratificación de principios</li><li data-s="3"><b>Declaración jurada</b> de afiliados y organización requeridos</li><li data-s="4">Nombre, emblema, estatutos y sede</li><li data-s="5">Comité Ejecutivo Nacional Provisional en posesión de sus cargos</li><li data-s="6">Procedimiento de liquidación y destino de los bienes</li></ul></div>
        <div><div class="cap a">Los estatutos incluyen, entre otros</div><ul class="gl sm"><li data-s="7">Órganos del partido y su integración</li><li data-s="8"><b>Órgano de fiscalización financiera</b> y <b>tribunal de honor</b></li><li data-s="9">Cuotas y contribuciones de los afiliados</li><li data-s="10">Formalidades de actas y manejo de libros autorizados</li><li data-s="11">Democracia interna y fechas de las asambleas</li></ul></div>
      </div>$q$, $q$<p>Art. 63: la escritura de constitución del partido contiene la comparecencia de todos los integrantes de la junta directiva provisional, los datos del comité inscrito, ratificación de principios, declaración jurada de que cuenta con los afiliados y la organización exigidos, nombre y emblema, estatutos, integración del CEN provisional, sede y procedimiento de liquidación con destino de bienes.</p><p>Art. 65: los estatutos deben incluir, además de los órganos del artículo 24, un <b>órgano colegiado de fiscalización financiera</b> y un <b>tribunal de honor</b>; la forma de fijar cuotas y contribuciones; y las formalidades de las actas y las responsabilidades por el manejo de libros autorizados.</p><p>Conexión con la contabilidad: el órgano de fiscalización financiera es el que revisa los informes que se presentan al TSE.</p>$q$, $q${}$q$, false),
  (22, 2, $q$paso-7-solicitud-publicacion-y-oposicion$q$, $q$Paso 7: solicitud, publicación y oposición$q$, 1.7, $q$hs$q$, false, $q$<div class="kick a">Inscripción · Paso 7 <span class="law">LEPP arts. 67 a 73</span></div><h2 class="split">De la solicitud al <em>edicto</em></h2>
      <p class="lead a">Se pide la inscripción al Registro <b>antes de que venzan los 2 años</b> del comité, con el testimonio de la escritura, la nómina del Comité Ejecutivo Nacional provisional y las resoluciones de las primeras asambleas.</p>
      <div class="flow mt" style="height:200px">
        <div class="st a"><b>8 días</b>Examen y resolución</div>
        <div class="st" data-s="1"><b>Diario Oficial</b>Edicto, gratis</div>
        <div class="st" data-s="2"><b>8 días</b>Oposición posible</div>
        <div class="st" data-s="3"><b>15 días</b>Audiencia al partido</div>
        <div class="st" data-s="4"><b>8 días</b>Resolución final</div>
      </div>
      <div class="cols c2 mt" style="gap:28px">
        <div class="card" data-s="5"><h4>Apelación</h4><p>Ante el Tribunal Supremo Electoral. Si prospera la oposición, el partido tiene <b>60 días</b> para subsanar.</p></div>
        <div class="card green" data-s="6"><h4>Inscripción</h4><p>Firme la resolución, el Departamento de Organizaciones Políticas inscribe y el Registro publica un aviso en el Diario Oficial.</p></div>
      </div>$q$, $q$<p>Arts. 67 a 75. Se solicita la inscripción del partido antes del vencimiento del plazo de dos años; se acompaña testimonio de la escritura con duplicado, nómina del CEN provisional y resoluciones de inscripción de las primeras asambleas, comités y delegados.</p><p>El Registro emite resolución en ocho días y, si procede, ordena publicar un edicto con resumen de la escritura y la nómina de órganos permanentes. Otro partido o comité puede presentar oposición dentro de ocho días de la publicación; se da audiencia de quince días al partido y el Director resuelve en ocho días. Procede apelación ante el TSE.</p><p>Firme la resolución, el expediente va al Departamento de Organizaciones Políticas para la inscripción y se publica el aviso.</p>$q$, $q${}$q$, false),
  (23, 2, $q$partido-inscrito-primera-asamblea-nacional$q$, $q$Partido inscrito: primera Asamblea Nacional$q$, 1.3, $q$hs$q$, false, $q$<div class="kick a">Inscripción · Paso 8 <span class="law">LEPP arts. 24 y 76</span></div><h2 class="split">La primera <em>Asamblea Nacional</em></h2>
      <div class="flow" style="height:170px">
        <div class="st a"><b>≤ 3 meses</b>Convoca el CEN provisional</div>
        <div class="st" data-s="1"><b>≤ 2 meses</b>Se celebra tras la convocatoria</div>
      </div>
      <div class="cols c2 mt" style="gap:36px;align-items:start">
        <div><div class="cap a">Debe</div><ul class="gl sm"><li data-s="2">Ratificar la declaración de principios</li><li data-s="3">Aprobar o modificar los estatutos</li><li data-s="4">Conocer el informe del CEN provisional</li><li data-s="5">Elegir el primer <b>Comité Ejecutivo Nacional</b></li></ul></div>
        <div class="card" data-s="6"><h4>Órganos mínimos <span class="law">art. 24</span></h4><p><b>Nacionales:</b> Asamblea Nacional, CEN, <b>Órgano de Fiscalización Financiera</b> y Tribunal de Honor. <b>Departamentales y municipales:</b> asamblea y comité ejecutivo.</p></div>
      </div>
      <div class="note warn " data-s="7"><b>Si no se cumple</b>El partido queda en suspenso hasta corregir las omisiones.</div>$q$, $q$<p>Art. 76: el CEN provisional convoca la primera Asamblea Nacional dentro de los tres meses siguientes a la inscripción; se celebra dentro de los dos meses siguientes a la convocatoria. Debe ratificar principios, aprobar o modificar estatutos, conocer el informe del CEN provisional y elegir el primer CEN. Si no se celebra o no resuelve esos puntos, el partido queda en suspenso hasta corregirlo.</p><p>Art. 24: el órgano de fiscalización financiera y el tribunal de honor se eligen en Asamblea Nacional junto con el CEN. Son los órganos a los que luego se refieren los informes financieros.</p>$q$, $q${}$q$, false),
  (24, 2, $q$despues-de-inscrito-sat-y-primeras-obligaciones-contables$q$, $q$Después de inscrito: SAT y primeras obligaciones contables$q$, 2, $q$hs$q$, false, $q$<div class="kick a">Inscripción · Paso 9</div><h2 class="split">Después de inscrito: <em>SAT</em> y contabilidad</h2>
      <div class="cols c12" style="gap:44px;align-items:start">
        <div class="tl sm">
          <div class="ev key" data-s="1"><div class="yr">Día 0</div><div class="tx">Se inscriben los órganos permanentes en el Registro de Ciudadanos.</div></div>
          <div class="ev" data-s="2"><div class="yr">15 días</div><div class="tx"><b>Nombra contador general</b> <span class="law">Reglamento fisc. art. 12</span></div></div>
          <div class="ev" data-s="3"><div class="yr">10 días</div><div class="tx">Notifica (hábiles) a la Unidad con copia del <b>RTU</b> del contador.</div></div>
          <div class="ev" data-s="4"><div class="yr">1 mes</div><div class="tx"><b>Balance de apertura</b> certificado y aprobado.</div></div>
          <div class="ev" data-s="5"><div class="yr">Luego</div><div class="tx">Cuentas bancarias (aviso en 5 días hábiles) y libros habilitados.</div></div>
        </div>
        <div class="card blue" data-s="6"><h4>Ante la SAT</h4>
          <ul class="gl sm"><li data-s="6">Inscripción en el <b>RTU</b> y obtención del <b>NIT</b></li><li data-s="7">Habilitación de libros contables</li><li data-s="8">Autorización de recibos de ingreso</li><li data-s="9">Solvencia fiscal para sus donantes</li></ul>
          <p class="small" style="margin-top:14px">Habitualmente se pide DPI y nombramiento del representante legal, testimonio de la escritura o resolución de inscripción y comprobante de domicilio fiscal. <span class="verify">confirmar con la SAT</span></p></div>
      </div>$q$, $q$<p>Cierra el ciclo de inscripción y conecta con la contabilidad: al inscribirse los órganos permanentes en el Departamento de Organizaciones Políticas, el partido tiene <b>15 días para nombrar contador general</b> (Reglamento de fiscalización, art. 12) y 10 días hábiles para notificarlo a la Unidad Especializada con copia del RTU actualizado donde conste la inscripción del contador. El <b>balance de apertura</b> se presenta dentro del mes siguiente a la inscripción (Instructivo).</p><p>Ante la SAT: inscripción en el Registro Tributario Unificado y NIT (Decreto 25-71), habilitación de libros y autorización de recibos. <b>Los documentos exactos para organizaciones políticas deben confirmarse con la SAT</b>: el listado habitual para personas jurídicas incluye DPI y nombramiento del representante legal, testimonio de la escritura o resolución de inscripción y comprobante de domicilio fiscal (Agencia Virtual u oficina).</p>$q$, $q${}$q$, false),
  (25, 2, $q$las-finanzas-desde-antes-de-ser-partido$q$, $q$Las finanzas desde antes de ser partido$q$, 1, $q$vc$q$, false, $q$<div class="kick a">Inscripción · Finanzas</div><h2 class="split">La contabilidad <em>no empieza</em> al ser partido</h2>
      <div class="cols c2" style="gap:36px">
        <div class="card blue " data-s="1"><h4>Comité para constituir un partido</h4><p>Informe de ingresos y egresos <b>semestral</b> (INF-COMITÉ), dentro del mes posterior al semestre.</p></div>
        <div class="card red " data-s="2"><h4>Qué no puede hacer</h4><p>Propaganda, usar nombre o emblema en campañas ni actividades del artículo 20 de la LEPP.</p></div>
      </div>
      <div class="mt2"><div class="note  " data-s="3"><b>Para el contador</b>Los aportes que financian la formación del partido ya se registran, con recibo, sin anonimato y con los límites de la ley. Todo lo visto en la sección III aplica desde el primer día.</div></div>$q$, $q$<p>Los comités para la constitución de un partido son organizaciones políticas para efectos del Reglamento de fiscalización: presentan el informe INF-COMITÉ de forma semestral, dentro del mes posterior a concluido el semestre (art. 13).</p><p>El Reglamento de la LEPP (art. 14) prohíbe a un comité inscrito identificarse como partido o hacer propaganda y usar nombre, símbolo o emblema en campañas.</p>$q$, $q${}$q$, false)
) as v(pos, sec_pos, slug, title, minutes, css, nochrome, html, notes, meta, locked)
where d.slug = $q$presentacion-partidos$q$
on conflict (deck_id, slug) do nothing;

-- Minutos sugeridos recalculados (solo filas que usted no ha editado)
update public.mdpp_items i set minutes = v.m
from public.mdpp_decks d,
(values
  ($q$portada$q$, 0.7),
  ($q$por-que-importa$q$, 1.3),
  ($q$agenda-del-taller$q$, 1),
  ($q$seccion-i-antecedentes$q$, 0.2),
  ($q$linea-de-tiempo-1985-2015$q$, 1),
  ($q$linea-de-tiempo-2016-2027$q$, 1),
  ($q$que-creo-el-decreto-26-2016$q$, 1.3),
  ($q$seccion-ii-marco-legal-y-entidad-rectora$q$, 0.2),
  ($q$las-normas-de-mayor-a-menor$q$, 1),
  ($q$que-regula-cada-norma$q$, 1.3),
  ($q$correccion-el-acuerdo-306-2016$q$, 1),
  ($q$la-unidad-especializada-uecffpp$q$, 1.3),
  ($q$como-es-una-fiscalizacion$q$, 1),
  ($q$donde-se-inscribe-un-partido-tres-puertas$q$, 1.3),
  ($q$la-ruta-completa-de-la-inscripcion$q$, 1.7),
  ($q$paso-1-grupo-promotor-y-junta-directiva-provisional$q$, 1.3),
  ($q$paso-2-escritura-del-comite-y-su-inscripcion$q$, 1.7),
  ($q$paso-3-el-comite-inscrito$q$, 1),
  ($q$paso-4-hojas-de-adhesion-y-afiliados-minimos$q$, 1.7),
  ($q$paso-5-organizacion-partidaria-minima$q$, 1.3),
  ($q$paso-6-escritura-del-partido-y-estatutos$q$, 1.7),
  ($q$paso-7-solicitud-publicacion-y-oposicion$q$, 1.7),
  ($q$partido-inscrito-primera-asamblea-nacional$q$, 1.3),
  ($q$despues-de-inscrito-sat-y-primeras-obligaciones-contables$q$, 2),
  ($q$las-finanzas-desde-antes-de-ser-partido$q$, 1),
  ($q$seccion-iii-naturaleza-y-financiamiento$q$, 0.2),
  ($q$naturaleza-juridica$q$, 0.8),
  ($q$cuatro-tipos-de-organizacion-politica$q$, 0.8),
  ($q$que-implica-para-la-contabilidad$q$, 0.8),
  ($q$mapa-de-las-fuentes$q$, 1),
  ($q$financiamiento-publico-us-2-por-voto$q$, 1),
  ($q$como-se-paga-el-financiamiento-publico$q$, 0.8),
  ($q$calculadora-financiamiento-publico$q$, 1.7),
  ($q$distribucion-obligatoria-30-20-50$q$, 1.7),
  ($q$financiamiento-privado-tipos$q$, 1),
  ($q$aportes-en-especie-y-justiprecio$q$, 1),
  ($q$financiamiento-prohibido$q$, 1.3),
  ($q$otras-prohibiciones-y-consecuencias$q$, 1),
  ($q$techo-de-gastos-de-campana$q$, 1.3),
  ($q$que-cuenta-como-gasto-de-campana$q$, 0.8),
  ($q$limite-del-10-por-aportante$q$, 1.7),
  ($q$umbrales-que-activan-obligaciones$q$, 1),
  ($q$ejemplo-formal-financiamiento-de-futuro-retalteco$q$, 1.7),
  ($q$techo-2027-y-conclusion$q$, 1),
  ($q$seccion-iv-sistema-de-cuentas-bancarias$q$, 0.2),
  ($q$cuentas-bancarias-obligatorias$q$, 1.3),
  ($q$reglas-comunes-de-las-cuentas$q$, 1),
  ($q$el-recibo-de-ingreso$q$, 1.3),
  ($q$respaldo-de-los-gastos$q$, 1),
  ($q$seccion-v-libros-obligatorios$q$, 0.2),
  ($q$libros-contables-sat$q$, 1.3),
  ($q$libros-de-contribuciones-tse$q$, 1.3),
  ($q$como-se-complementan-los-libros$q$, 0.8),
  ($q$seccion-vi-plan-de-cuentas$q$, 0.2),
  ($q$como-se-codifica-una-cuenta$q$, 1),
  ($q$grupo-1-activo$q$, 1),
  ($q$grupos-2-y-3-pasivo-y-patrimonio$q$, 1.3),
  ($q$grupo-4-ingresos$q$, 1),
  ($q$grupo-5-egresos-permanentes$q$, 1),
  ($q$grupo-5-campana-y-cuentas-de-control$q$, 1),
  ($q$asientos-tipo-del-instructivo$q$, 1.3),
  ($q$seccion-vii-estados-financieros-al-tse$q$, 0.2),
  ($q$que-se-presenta$q$, 1.3),
  ($q$calendario-de-informes$q$, 1.3),
  ($q$las-notas-a-los-estados-financieros$q$, 1),
  ($q$seccion-viii-caso-practico-futuro-retalteco$q$, 0.2),
  ($q$los-datos-del-caso$q$, 1.3),
  ($q$el-inicio-de-actividades$q$, 1.7),
  ($q$libro-diario-1$q$, 1.3),
  ($q$libro-diario-2$q$, 1.7),
  ($q$libro-diario-3$q$, 1.3),
  ($q$libro-diario-4$q$, 1.3),
  ($q$libro-mayor-cuentas-t$q$, 1.7),
  ($q$balanza-de-comprobacion$q$, 1),
  ($q$balance-de-situacion-general$q$, 1.3),
  ($q$estado-de-ingresos-y-egresos$q$, 1.3),
  ($q$verificacion-final-del-caso$q$, 1.3),
  ($q$seccion-ix-obligaciones-sat-y-cumplimiento$q$, 0.2),
  ($q$quien-responde-por-que$q$, 1.3),
  ($q$obligaciones-permanentes-del-partido$q$, 1),
  ($q$sanciones-por-incumplir$q$, 1.3),
  ($q$que-se-considera-infraccion$q$, 0.8),
  ($q$sat-ante-quien-se-inscribe-un-partido$q$, 1.3),
  ($q$sat-que-debe-hacer$q$, 1),
  ($q$impuestos-que-pueden-afectar$q$, 1.7),
  ($q$resumen-de-cumplimiento-clave$q$, 2),
  ($q$glosario$q$, 1),
  ($q$fuentes-y-advertencias$q$, 1),
  ($q$cierre$q$, 1.3)
) as v(slug, m)
where d.id = i.deck_id and d.slug = $q$presentacion-partidos$q$ and i.slug = v.slug and i.updated_at = i.created_at;


-- ===== libro-partidos: 2 filas nuevas =====
do $$
declare d uuid;
begin
  select id into d from public.mdpp_decks where slug = $q$libro-partidos$q$;
  if d is null then raise exception 'No existe el deck libro-partidos. Ejecute antes las fases 1 a 6.'; end if;
  -- Hace espacio en el orden solo la primera vez (si la fila nueva ya existe, no mueve nada)
  if not exists (select 1 from public.mdpp_items where deck_id = d and slug = $q$inscripcion1$q$) then
    update public.mdpp_items set pos = pos + 2 where deck_id = d and pos >= 9;
  end if;
end $$;

insert into public.mdpp_items (deck_id, section_id, pos, slug, title, minutes, css_class, nochrome, html, notes, meta, locked)
select d.id,
       (select s.id from public.mdpp_sections s where s.deck_id = d.id and s.pos = v.sec_pos),
       v.pos, v.slug, v.title, v.minutes, v.css, v.nochrome, v.html, v.notes, v.meta::jsonb, v.locked
from public.mdpp_decks d,
(values
  (9, 2, $q$inscripcion1$q$, $q$Dónde y cómo se inscribe un partido$q$, 1, $q$$q$, false, $q$  <span class="kicker">Sección II · Inscripción de un partido (1)</span>
  <h2>Dónde y cómo se inscribe un partido</h2>
  <p>Ser partido y ser contribuyente son dos existencias distintas. Hay <b>tres puertas</b>:</p>
  <table class="t">
    <tbody>
      <tr><td><b>Notario</b></td><td>Escritura pública del comité y, luego, la del partido.</td></tr>
      <tr><td><b>Registro de Ciudadanos del TSE</b></td><td>Inscribe el comité, el partido y sus órganos permanentes, por medio del Departamento de Organizaciones Políticas. Edicto gratis en el Diario Oficial.</td></tr>
      <tr><td><b>SAT</b></td><td>Existencia tributaria: RTU y NIT, libros contables y recibos autorizados. <span class="verify">verificar</span></td></tr>
    </tbody>
  </table>
  <h3>La ruta en nueve pasos <span class="law">LEPP arts. 51 a 76</span></h3>
  <div class="tl">
    <div class="ev key"><div class="yr">1</div><p><b>Grupo promotor</b> (más del 2 % del mínimo de afiliados, alfabetos): acta notarial y Junta Directiva Provisional de 9 o más.</p></div>
    <div class="ev"><div class="yr">2</div><p><b>Escritura del comité</b> en 3 meses; solicitud de inscripción en 30 días; el Director resuelve en 8.</p></div>
    <div class="ev"><div class="yr">3</div><p><b>Comité inscrito</b>: personalidad limitada y vigencia de <b>2 años improrrogables</b>.</p></div>
    <div class="ev"><div class="yr">4</div><p><b>Hojas de adhesión</b> numeradas y autorizadas; depuración en 15 días.</p></div>
    <div class="ev"><div class="yr">5</div><p><b>Organización mínima</b> con asambleas municipales y departamentales.</p></div>
    <div class="ev"><div class="yr">6</div><p><b>Escritura del partido</b> con declaración jurada de afiliados y organización, estatutos, CEN provisional y destino de bienes <span class="law">arts. 63 y 65</span></p></div>
  </div>$q$, null, $q${"sec":"II · Marco legal","secStart":null}$q$, false),
  (10, 2, $q$inscripcion2$q$, $q$Requisitos, plazos y primeras obligaciones$q$, 1, $q$$q$, false, $q$  <span class="kicker">Sección II · Inscripción de un partido (2)</span>
  <h2>Requisitos, plazos y primeras obligaciones</h2>
  <div class="tl">
    <div class="ev"><div class="yr">7</div><p><b>Solicitud</b> antes de vencer los 2 años; examen en 8 días; edicto; oposición en 8 días; audiencia de 15; resolución en 8; apelación ante el TSE; 60 días para subsanar.</p></div>
    <div class="ev key"><div class="yr">8</div><p><b>Primera Asamblea Nacional</b>: convocada en 3 meses y celebrada en 2 más. Elige el primer CEN.</p></div>
    <div class="ev"><div class="yr">9</div><p><b>SAT y contabilidad</b>: contador general en 15 días, balance de apertura en 1 mes.</p></div>
  </div>
  <h3>Requisitos mínimos</h3>
  <table class="t">
    <tbody>
      <tr><td><b>Afiliados</b> <span class="law">art. 19 a</span></td><td>0.30 % del padrón de las últimas elecciones generales; al menos la mitad sabe leer y escribir. Ejemplo: padrón de 10,200,000 → 30,600.</td></tr>
      <tr><td><b>Municipio</b> <span class="law">art. 49</span></td><td>40 afiliados vecinos y su Comité Ejecutivo Municipal</td></tr>
      <tr><td><b>Departamento</b></td><td>Organización en 4 municipios y su Comité Ejecutivo</td></tr>
      <tr><td><b>Nacional</b></td><td>50 municipios en al menos 12 departamentos y el CEN</td></tr>
      <tr><td><b>Estatutos</b> <span class="law">art. 65</span></td><td>Órgano de fiscalización financiera y tribunal de honor</td></tr>
    </tbody>
  </table>
  <div class="note warn"><b>Falta confirmar</b>Los documentos exactos de la inscripción tributaria en la SAT para organizaciones políticas. Habitualmente: DPI y nombramiento del representante legal, escritura o resolución de inscripción y domicilio fiscal.</div>$q$, null, $q${"sec":"II · Marco legal","secStart":null}$q$, false)
) as v(pos, sec_pos, slug, title, minutes, css, nochrome, html, notes, meta, locked)
where d.slug = $q$libro-partidos$q$
on conflict (deck_id, slug) do nothing;

-- Páginas existentes cuyo texto cambió (solo si usted no las ha editado)
update public.mdpp_items i set html = $q$  <span class="kicker">Bienvenida</span>
  <h2>Qué encontrará en este libro</h2>
  <p class="lead dropcap">Un partido político en Guatemala es una institución de derecho público, pero maneja dinero público y privado. Por eso su contabilidad no es solo un asunto técnico: es la prueba de que cada quetzal tiene origen conocido, límite respetado y destino justificado.</p>
  <p>Esta guía recorre el tema completo, en orden: la historia de la regulación, las leyes aplicables, cómo se inscribe un partido, cómo se financia un partido, cuánto puede recibir y gastar, qué cuentas bancarias y libros debe llevar, qué plan de cuentas usar y qué estados financieros presentar al TSE. Cierra con un caso práctico completo y con lo que debe hacerse ante la SAT.</p>
  <div class="cols2">
    <div class="card"><h4>Cómo se usa</h4><p>Pase página con las flechas ← →, haciendo clic en los bordes o deslizando el dedo.</p></div>
    <div class="card"><h4>Interactivo</h4><p>Hay calculadoras, partidas desplegables y una lista de cumplimiento que guarda su avance.</p></div>
  </div>
  <div class="note warn"><b>Aviso importante</b>Material educativo, preparado con los textos oficiales vigentes a octubre de 2026. No sustituye asesoría legal ni contable. Las cifras del caso práctico son ficticias. Lo que no pudo confirmarse en texto oficial está marcado <span class="verify">verificar</span>.</div>
  <p class="small">Fuentes principales: Ley Electoral y de Partidos Políticos (LEPP) y sus reglamentos, edición TSE 2026; Instructivo para la Rendición de Cuentas de las Organizaciones Políticas; Ley de Actualización Tributaria; Ley del IVA.</p>$q$ from public.mdpp_decks d where d.id = i.deck_id and d.slug = $q$libro-partidos$q$ and i.slug = $q$presentacion$q$ and i.updated_at = i.created_at;
update public.mdpp_items i set html = $q$  <span class="kicker">Tabla de contenido</span>
  <h2>Índice</h2>
  <ol class="toc">
    <li><a href="#" data-goto="antecedentes"><span><span class="tt">Antecedentes históricos</span><span class="ds">De 1985 a las reformas de 2026</span></span><span class="pg"></span></a></li>
    <li><a href="#" data-goto="piramide"><span><span class="tt">Marco legal y entidad rectora</span><span class="ds">Leyes, la UECFFPP y la inscripción de un partido</span></span><span class="pg"></span></a></li>
    <li><a href="#" data-goto="naturaleza"><span><span class="tt">Naturaleza y financiamiento</span><span class="ds">Fuentes, prohibiciones, techos y distribución</span></span><span class="pg"></span></a></li>
    <li><a href="#" data-goto="cuentas-bancarias"><span><span class="tt">Sistema de cuentas bancarias</span><span class="ds">Qué cuentas, para qué y con qué firmas</span></span><span class="pg"></span></a></li>
    <li><a href="#" data-goto="libros-sat"><span><span class="tt">Libros obligatorios</span><span class="ds">Contables y de contribuciones</span></span><span class="pg"></span></a></li>
    <li><a href="#" data-goto="nomenclatura"><span><span class="tt">Plan de cuentas</span><span class="ds">Nomenclatura según el Instructivo del TSE</span></span><span class="pg"></span></a></li>
    <li><a href="#" data-goto="estados"><span><span class="tt">Estados financieros al TSE</span><span class="ds">Contenido, plazos y calendario</span></span><span class="pg"></span></a></li>
    <li><a href="#" data-goto="caso-datos"><span><span class="tt">Caso práctico: Futuro Retalteco</span><span class="ds">Diario, mayor, balance y estados</span></span><span class="pg"></span></a></li>
    <li><a href="#" data-goto="obligaciones"><span><span class="tt">Obligaciones, SAT y cumplimiento</span><span class="ds">Responsables, sanciones, impuestos y lista final</span></span><span class="pg"></span></a></li>
    <li><a href="#" data-goto="glosario"><span><span class="tt">Glosario y fuentes</span><span class="ds">Términos clave y referencias</span></span><span class="pg"></span></a></li>
  </ol>$q$ from public.mdpp_decks d where d.id = i.deck_id and d.slug = $q$libro-partidos$q$ and i.slug = $q$indice$q$ and i.updated_at = i.created_at;
update public.mdpp_items i set html = $q$  <span class="kicker">Financiamiento público</span>
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
  <div class="note"><b>Ejemplo rápido</b>150,000 votos × US$2 = US$300,000 en cuatro años. Cada año: US$75,000. A Q7.62 por dólar (supuesto): Q571,500 anuales. La calculadora de la página 15 lo hace por usted.</div>$q$ from public.mdpp_decks d where d.id = i.deck_id and d.slug = $q$libro-partidos$q$ and i.slug = $q$fin-publico$q$ and i.updated_at = i.created_at;
update public.mdpp_items i set html = $q$  <span class="kicker">Sección VII · Estados financieros al TSE (3)</span>
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
  <div class="note"><b>Nota 2, el detalle que más se olvida</b>Debe revelar el régimen de impuestos del partido y las exenciones que invoca. Conecta la contabilidad con lo que se verá ante la SAT en la página 44.</div>$q$ from public.mdpp_decks d where d.id = i.deck_id and d.slug = $q$libro-partidos$q$ and i.slug = $q$notas$q$ and i.updated_at = i.created_at;

-- Minutos sugeridos recalculados (solo filas que usted no ha editado)
update public.mdpp_items i set minutes = v.m
from public.mdpp_decks d,
(values
  ($q$portada$q$, 1),
  ($q$presentacion$q$, 1),
  ($q$indice$q$, 1),
  ($q$antecedentes$q$, 1),
  ($q$antecedentes2$q$, 1),
  ($q$piramide$q$, 1),
  ($q$normas-tabla$q$, 1),
  ($q$uecffpp$q$, 1),
  ($q$inscripcion1$q$, 1),
  ($q$inscripcion2$q$, 1),
  ($q$naturaleza$q$, 1),
  ($q$mapa-fuentes$q$, 1),
  ($q$fin-publico$q$, 1),
  ($q$fin-privado$q$, 1),
  ($q$prohibidas$q$, 1),
  ($q$techo$q$, 1),
  ($q$limite-aportante$q$, 1),
  ($q$distribucion$q$, 1),
  ($q$ejemplo-formal$q$, 1),
  ($q$cuentas-bancarias$q$, 1),
  ($q$recibos$q$, 1),
  ($q$libros-sat$q$, 1),
  ($q$libros-tse$q$, 1),
  ($q$nomenclatura$q$, 1),
  ($q$nom-pasivo$q$, 1),
  ($q$nom-ingresos$q$, 1),
  ($q$nom-egresos$q$, 1),
  ($q$nom-campana$q$, 1),
  ($q$reglas-uso$q$, 1),
  ($q$estados$q$, 1),
  ($q$calendario$q$, 1),
  ($q$notas$q$, 1),
  ($q$caso-datos$q$, 1),
  ($q$caso-inicio$q$, 1),
  ($q$diario1$q$, 1),
  ($q$diario2$q$, 1),
  ($q$diario3$q$, 1),
  ($q$mayor$q$, 1),
  ($q$balanza$q$, 1),
  ($q$balance$q$, 1),
  ($q$estado-ie$q$, 1),
  ($q$caso-verif$q$, 1),
  ($q$obligaciones$q$, 1),
  ($q$sanciones$q$, 1),
  ($q$sat$q$, 1),
  ($q$sat-impuestos$q$, 1),
  ($q$resumen$q$, 1),
  ($q$glosario$q$, 1),
  ($q$fuentes$q$, 1),
  ($q$contraportada$q$, 1)
) as v(slug, m)
where d.id = i.deck_id and d.slug = $q$libro-partidos$q$ and i.slug = v.slug and i.updated_at = i.created_at;

alter table public.mdpp_items enable trigger mdpp_items_snapshot;
commit;
