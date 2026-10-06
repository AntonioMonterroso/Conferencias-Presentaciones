/* Contenido: cómo se inscribe un partido político (dónde y cómo). Sección II. Fuente: LEPP arts. 16, 19, 24, 49 a 76; Reglamento de la LEPP arts. 11 a 19. */
(function () {
  const S = window.SLIDES, { head, law, vf, ul, card, note, tbl } = window.H;
  const add = o => S.push(o);

  add({ sec: 1, t: 'Dónde se inscribe un partido: tres puertas', m: 2,
    html: `${head('Sección II · Inscripción de un partido', 'Dónde nace un partido: <em>tres puertas</em>')}
      <div class="cols c3" style="gap:28px">
        <div class="card hot" data-s="1" style="min-height:520px"><h4>1 · Notario</h4><p>Todo parte de una <b>escritura pública</b>: primero la del comité y luego la del partido.</p><p class="small" style="margin-top:18px">Se otorga ante notario, con comparecencia personal y DPI.</p></div>
        <div class="card blue" data-s="2" style="min-height:520px"><h4>2 · Registro de Ciudadanos del TSE</h4><p>Inscribe al comité, al partido, a sus órganos permanentes y autoriza hojas de adhesión y libros de actas. Trabaja por medio de su <b>Departamento de Organizaciones Políticas</b>.</p></div>
        <div class="card green" data-s="3" style="min-height:520px"><h4>3 · SAT</h4><p>Le da existencia tributaria: <b>RTU y NIT</b>, habilitación de libros contables y recibos autorizados.</p><p class="small" style="margin-top:18px">${vf('verificar trámite vigente')}</p></div>
      </div>
      <p class="small mt" data-s="4">El edicto de inscripción se publica de oficio y gratis en el Diario Oficial. Las finanzas ya las vigila la Unidad Especializada desde que existe el comité.</p>`,
    notes: `<p>La pregunta del taller: <b>¿dónde se inscribe un partido y cómo?</b> Hay tres puertas distintas con tres efectos distintos.</p><ul><li><b>Notario:</b> la escritura pública del comité (art. 52) y la del partido (art. 63).</li><li><b>Registro de Ciudadanos del TSE:</b> inscribe el comité, el partido y sus órganos permanentes (arts. 54, 67, 74). El Departamento de Organizaciones Políticas dictamina y ejecuta las inscripciones.</li><li><b>SAT:</b> existencia tributaria (RTU y NIT). Es un trámite aparte; los detalles vigentes para organizaciones políticas deben confirmarse en la SAT.</li></ul><p>Recuerde: ser partido (existencia legal) y ser contribuyente (existencia tributaria) no son lo mismo.</p>` });

  add({ sec: 1, t: 'La ruta completa de la inscripción', m: 2.5, cls: 'hs',
    html: `${head('Sección II · Inscripción de un partido', 'La ruta, de principio a fin')}
      <div class="flow" style="height:230px">
        <div class="st a"><b>1 · Grupo promotor</b>Acta notarial y Junta Directiva Provisional</div>
        <div class="st" data-s="1"><b>2 · Comité</b>Escritura e inscripción</div>
        <div class="st" data-s="2"><b>3 · Adhesiones</b>Afiliados y organización mínima</div>
        <div class="st" data-s="3"><b>4 · Partido</b>Escritura, solicitud y publicación</div>
        <div class="st" data-s="4"><b>5 · Inscrito</b>Primera Asamblea Nacional</div>
      </div>
      <div class="cols c2 mt" style="gap:28px">
        <div class="card" data-s="5"><h4>Reloj del comité</h4><p>El comité inscrito tiene <b>2 años improrrogables</b> para llegar a la inscripción definitiva ${law('art. 58')}</p></div>
        <div class="card green" data-s="6"><h4>Al quedar inscrito</h4><p>Nacen sus obligaciones contables y tributarias: contador, balance de apertura, libros, cuentas y SAT.</p></div>
      </div>`,
    notes: `<p>Recorra los cinco hitos. Idea fuerza: <b>dos escrituras públicas y dos inscripciones</b> (comité y partido) en el Registro de Ciudadanos, con un plazo máximo de dos años desde la inscripción del comité.</p><p>Cada hito se detalla en las siguientes láminas con su artículo y sus plazos.</p>` });

  add({ sec: 1, t: 'Paso 1: grupo promotor y Junta Directiva Provisional', m: 2, cls: 'hs',
    html: `${head('Inscripción · Paso 1 ' + law('LEPP art. 51 · Reglamento art. 11'), 'El <em>grupo promotor</em>')}
      <div class="cols c2" style="gap:50px;align-items:start">
        <div>${ul([
          'Grupo de ciudadanos que <b>saben leer y escribir</b> y reúnen <b>más del 2 %</b> del número mínimo de afiliados que exige un partido',
          'Eligen una <b>Junta Directiva Provisional</b> de al menos <b>9</b> personas',
          'La elección consta en <b>acta notarial</b> con el CUI del DPI y el número de empadronamiento',
          'Se presenta solicitud al Registro de Ciudadanos'], 1, 'sm')}</div>
        <div class="stack">
          <div class="card hot" data-s="5"><h4>Ejemplo ilustrativo</h4><p>Con un padrón de 10,200,000 ciudadanos, el mínimo de un partido es 0.30 % = <b class="num"><span class="cnt" data-to="30600">0</span></b> afiliados; el grupo promotor necesita más del 2 %: <b>más de 612</b>.</p></div>
          <div class="card blue" data-s="6"><h4>Trámite en el Registro</h4><p>El Departamento de Organizaciones Políticas depura la solicitud en <b>15 días hábiles</b> y el Director resuelve.</p></div>
        </div>
      </div>`,
    notes: `<p>Art. 51 de la LEPP: cualquier grupo que reúna a más del 2 % del número mínimo de ciudadanos requerido para constituir un partido, que sepan leer y escribir, puede organizarse como comité. Primer paso: Junta Directiva Provisional de al menos nueve personas, con acta notarial presentada al Registro.</p><p>El Reglamento (art. 11) exige consignar el CUI del DPI y el número de empadronamiento para la depuración. El incumplimiento lleva al rechazo de la solicitud, impugnable por los recursos de la ley, y luego al archivo.</p><p><b>Cifra ilustrativa:</b> el padrón de 10.2 millones es el mismo supuesto usado para el techo de campaña; el mínimo real depende del padrón de las últimas elecciones generales.</p>` });

  add({ sec: 1, t: 'Paso 2: escritura del comité y su inscripción', m: 2.5, cls: 'hs',
    html: `${head('Inscripción · Paso 2 ' + law('LEPP arts. 52 a 56'), 'La <em>escritura</em> del comité')}
      <div class="cols c2" style="gap:44px;align-items:start">
        <div>${ul([
          'Comparecencia de la mayoría del grupo promotor, con DPI',
          'Nombre, emblema o símbolo del partido por constituirse',
          'Declaración de principios y proyecto de estatutos',
          'Integración de la Junta Directiva y representante legal especial',
          'Manifestación expresa de que se propone constituir un partido y sede provisional'], 1, 'sm')}
          <p class="small mt" data-s="6">Antes de otorgarla, se presenta la minuta al Director del Registro ${law('Reglamento art. 12')}</p></div>
        <div class="stack">
          <div class="card" data-s="2"><h4>Plazo para otorgarla</h4><p><b>3 meses</b> desde que se inscribió la Junta Directiva Provisional; si no, se cancela el trámite.</p></div>
          <div class="card" data-s="4"><h4>Solicitar la inscripción</h4><p><b>30 días</b> desde la escritura, con el testimonio. El Director resuelve en <b>8 días</b>.</p></div>
          <div class="card red" data-s="5"><h4>Si la deniegan</h4><p><b>30 días</b> para subsanar con una nueva escritura; hay apelación.</p></div>
        </div>
      </div>`,
    notes: `<p>El artículo 52 enumera lo que contiene la escritura de formalización del comité: comparecencia personal de la mayoría del grupo promotor; nombre y emblema; declaración de principios (con el compromiso de respetar las leyes, la filosofía, el juramento de actuar por vías pacíficas y democráticas y el de respetar la democracia interna); proyecto de estatutos; integración de la junta directiva; manifestación de querer constituir un partido; representante legal especial para el trámite; y sede provisional.</p><p>Plazos: escritura dentro de tres meses desde la inscripción de la junta provisional (art. 51); solicitud de inscripción del comité dentro de treinta días con el testimonio (art. 54); resolución del Director en ocho días (art. 55); si hay defectos, treinta días para subsanar (art. 56).</p>` });

  add({ sec: 1, t: 'Paso 3: el comité inscrito', m: 1.5, cls: 'vc',
    html: `${head('Inscripción · Paso 3 ' + law('LEPP arts. 57, 58 y 66'), 'Comité inscrito: <em>reloj</em> en marcha')}
      <div class="cols c3 mt" style="gap:28px">
        <div class="card hot" data-s="1"><div class="hero m num"><span class="cnt" data-to="2">0</span> años</div><p>Vigencia de la inscripción, <b>improrrogables</b>.</p></div>
        <div class="card" data-s="2"><h4>Personalidad limitada</h4><p>Solo para llegar a ser partido. No puede identificarse como partido ni tiene sus derechos.</p></div>
        <div class="card green" data-s="3"><h4>Prelación del nombre</h4><p>La inscripción da derecho preferente al nombre, emblema o símbolo. Prohibido el quetzal, la bandera y el escudo.</p></div>
      </div>
      <div class="mt2">${note('Se pierde la vigencia por', 'Pasar los 2 años sin escritura del partido · incumplir leyes electorales · bajar del mínimo de miembros del grupo promotor · quedar inscrito como partido.', 'warn', 4)}</div>`,
    notes: `<p>Efectos de la inscripción del comité (arts. 57 y 58 y Reglamento art. 14): personalidad jurídica con el único propósito de llegar a ser partido; no puede hacer propaganda, usar nombre o emblema en campañas ni realizar actividades del artículo 20.</p><p>Vigencia de dos años improrrogables, que cesa por vencimiento, por incumplimiento de leyes electorales, por reducción del grupo promotor por debajo del mínimo o al quedar inscrito el partido.</p>` });

  add({ sec: 1, t: 'Paso 4: hojas de adhesión y afiliados mínimos', m: 2.5, cls: 'hs',
    html: `${head('Inscripción · Paso 4 ' + law('LEPP arts. 19, 59 a 62'), 'Las <em>hojas de adhesión</em>')}
      <div class="cols c2" style="gap:44px;align-items:start">
        <div class="card hot a"><h4>Afiliados mínimos ${law('art. 19 a')}</h4><div class="hero m num"><span class="cnt" data-pre="" data-to="0.30" data-dec="2" data-suf=" %">0</span></div><p>del total de ciudadanos del padrón de las últimas elecciones generales. <b>Al menos la mitad</b> debe saber leer y escribir.</p><p class="small" style="margin-top:10px" data-s="1">Ejemplo ilustrativo: padrón de 10,200,000 → <b>30,600</b> afiliados.</p></div>
        <div>${ul([
          'El Registro entrega hojas <b>numeradas y autorizadas</b>',
          'Individuales o colectivas, <b>máximo 10 firmas</b>',
          'Cada hoja lleva la declaración jurada de su responsable, con <b>firma legalizada</b>',
          'Nombre, DPI, inscripción como ciudadano y firma o huella',
          'El Registro las depura en <b>15 días</b>; si hay datos falsos, pasa al Inspector General'], 2, 'sm')}</div>
      </div>
      <p class="small mt" data-s="7">Las hojas están exentas de timbres fiscales y notariales. Cuando el total depurado llega al mínimo, el Registro avisa al comité.</p>`,
    notes: `<p>El mínimo de afiliados es el 0.30 % del padrón de las últimas elecciones generales (art. 19 a), y al menos la mitad debe saber leer y escribir. Los partidos deben volver a cumplirlo cuando se publica un nuevo padrón, en un plazo que termina noventa días antes de la convocatoria a elecciones.</p><p>Hojas de adhesión (arts. 59 y 60): numeradas y autorizadas, hasta diez firmas, con declaración jurada del responsable y firma legalizada por notario. El comité puede entregarlas por partes; el Registro devuelve una copia sellada y las depura en quince días. El Registro provee el programa informático de depuración (Reglamento art. 18).</p><p>Art. 62: cuando el total depurado de adherentes alfabetos alcanza el mínimo, el Registro lo comunica al comité y le requiere presentar la documentación final antes de que venza el plazo de dos años.</p>` });

  add({ sec: 1, t: 'Paso 5: organización partidaria mínima', m: 2, cls: 'vc',
    html: `${head('Inscripción · Paso 5 ' + law('LEPP art. 49'), 'La organización mínima <em>vigente</em>')}
      <div class="n3 mt2">
        <div class="it" data-s="1"><div class="cap">Municipio</div><div class="hero"><span class="cnt" data-to="40">0</span></div><p>afiliados vecinos y su <b>Asamblea Municipal</b>, que elige el Comité Ejecutivo Municipal.</p></div>
        <div class="it" data-s="2"><div class="cap">Departamento</div><div class="hero"><span class="cnt" data-to="4">0</span></div><p>municipios con organización y su <b>Asamblea Departamental</b> con su Comité Ejecutivo.</p></div>
        <div class="it" data-s="3"><div class="cap">Nacional</div><div class="hero"><span class="cnt" data-to="50">0</span> / <span class="cnt" data-to="12">0</span></div><p><b>50 municipios</b> en al menos <b>12 departamentos</b> y la Asamblea Nacional con su Comité Ejecutivo.</p></div>
      </div>
      <p class="small mt2" data-s="4">Estas asambleas se celebran antes de la inscripción; sus comités se vuelven <b>permanentes</b> al quedar inscrito el partido ${law('art. 67 c')}</p>`,
    notes: `<p>Organización partidaria vigente (art. 49): en el municipio, cuarenta afiliados vecinos y Comité Ejecutivo Municipal electo en Asamblea Municipal; en el departamento, organización en al menos cuatro municipios y Comité Ejecutivo Departamental; a nivel nacional, organización en al menos cincuenta municipios y doce departamentos y Comité Ejecutivo Nacional electo en Asamblea Nacional.</p><p>Para inscribir el partido se prueba con las actas de las primeras asambleas municipales y departamentales, celebradas en cualquier momento antes de la inscripción (art. 67 c).</p><p>Contablemente esto importa: cada órgano permanente podrá tener su cuenta bancaria y recibir parte del financiamiento público (50 % a territorio).</p>` });

  add({ sec: 1, t: 'Paso 6: escritura del partido y estatutos', m: 2.5, cls: 'hs',
    html: `${head('Inscripción · Paso 6 ' + law('LEPP arts. 63, 65 y 66'), 'La <em>escritura</em> del partido')}
      <div class="cols c2" style="gap:40px;align-items:start">
        <div><div class="cap a">La escritura contiene</div>${ul([
          'Comparecencia de toda la Junta Directiva Provisional',
          'Datos de la inscripción del comité y ratificación de principios',
          '<b>Declaración jurada</b> de afiliados y organización requeridos',
          'Nombre, emblema, estatutos y sede',
          'Comité Ejecutivo Nacional Provisional en posesión de sus cargos',
          'Procedimiento de liquidación y destino de los bienes'], 1, 'sm')}</div>
        <div><div class="cap a">Los estatutos incluyen, entre otros</div>${ul([
          'Órganos del partido y su integración',
          '<b>Órgano de fiscalización financiera</b> y <b>tribunal de honor</b>',
          'Cuotas y contribuciones de los afiliados',
          'Formalidades de actas y manejo de libros autorizados',
          'Democracia interna y fechas de las asambleas'], 7, 'sm')}</div>
      </div>`,
    notes: `<p>Art. 63: la escritura de constitución del partido contiene la comparecencia de todos los integrantes de la junta directiva provisional, los datos del comité inscrito, ratificación de principios, declaración jurada de que cuenta con los afiliados y la organización exigidos, nombre y emblema, estatutos, integración del CEN provisional, sede y procedimiento de liquidación con destino de bienes.</p><p>Art. 65: los estatutos deben incluir, además de los órganos del artículo 24, un <b>órgano colegiado de fiscalización financiera</b> y un <b>tribunal de honor</b>; la forma de fijar cuotas y contribuciones; y las formalidades de las actas y las responsabilidades por el manejo de libros autorizados.</p><p>Conexión con la contabilidad: el órgano de fiscalización financiera es el que revisa los informes que se presentan al TSE.</p>` });

  add({ sec: 1, t: 'Paso 7: solicitud, publicación y oposición', m: 2.5, cls: 'hs',
    html: `${head('Inscripción · Paso 7 ' + law('LEPP arts. 67 a 73'), 'De la solicitud al <em>edicto</em>')}
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
      </div>`,
    notes: `<p>Arts. 67 a 75. Se solicita la inscripción del partido antes del vencimiento del plazo de dos años; se acompaña testimonio de la escritura con duplicado, nómina del CEN provisional y resoluciones de inscripción de las primeras asambleas, comités y delegados.</p><p>El Registro emite resolución en ocho días y, si procede, ordena publicar un edicto con resumen de la escritura y la nómina de órganos permanentes. Otro partido o comité puede presentar oposición dentro de ocho días de la publicación; se da audiencia de quince días al partido y el Director resuelve en ocho días. Procede apelación ante el TSE.</p><p>Firme la resolución, el expediente va al Departamento de Organizaciones Políticas para la inscripción y se publica el aviso.</p>` });

  add({ sec: 1, t: 'Partido inscrito: primera Asamblea Nacional', m: 2, cls: 'hs',
    html: `${head('Inscripción · Paso 8 ' + law('LEPP arts. 24 y 76'), 'La primera <em>Asamblea Nacional</em>')}
      <div class="flow" style="height:170px">
        <div class="st a"><b>≤ 3 meses</b>Convoca el CEN provisional</div>
        <div class="st" data-s="1"><b>≤ 2 meses</b>Se celebra tras la convocatoria</div>
      </div>
      <div class="cols c2 mt" style="gap:36px;align-items:start">
        <div><div class="cap a">Debe</div>${ul(['Ratificar la declaración de principios', 'Aprobar o modificar los estatutos', 'Conocer el informe del CEN provisional', 'Elegir el primer <b>Comité Ejecutivo Nacional</b>'], 2, 'sm')}</div>
        <div class="card" data-s="6"><h4>Órganos mínimos ${law('art. 24')}</h4><p><b>Nacionales:</b> Asamblea Nacional, CEN, <b>Órgano de Fiscalización Financiera</b> y Tribunal de Honor. <b>Departamentales y municipales:</b> asamblea y comité ejecutivo.</p></div>
      </div>
      ${note('Si no se cumple', 'El partido queda en suspenso hasta corregir las omisiones.', 'warn', 7)}`,
    notes: `<p>Art. 76: el CEN provisional convoca la primera Asamblea Nacional dentro de los tres meses siguientes a la inscripción; se celebra dentro de los dos meses siguientes a la convocatoria. Debe ratificar principios, aprobar o modificar estatutos, conocer el informe del CEN provisional y elegir el primer CEN. Si no se celebra o no resuelve esos puntos, el partido queda en suspenso hasta corregirlo.</p><p>Art. 24: el órgano de fiscalización financiera y el tribunal de honor se eligen en Asamblea Nacional junto con el CEN. Son los órganos a los que luego se refieren los informes financieros.</p>` });

  add({ sec: 1, t: 'Después de inscrito: SAT y primeras obligaciones contables', m: 3, cls: 'hs',
    html: `${head('Inscripción · Paso 9', 'Después de inscrito: <em>SAT</em> y contabilidad')}
      <div class="cols c12" style="gap:44px;align-items:start">
        <div class="tl sm">
          <div class="ev key" data-s="1"><div class="yr">Día 0</div><div class="tx">Se inscriben los órganos permanentes en el Registro de Ciudadanos.</div></div>
          <div class="ev" data-s="2"><div class="yr">15 días</div><div class="tx"><b>Nombra contador general</b> ${law('Reglamento fisc. art. 12')}</div></div>
          <div class="ev" data-s="3"><div class="yr">10 días</div><div class="tx">Notifica (hábiles) a la Unidad con copia del <b>RTU</b> del contador.</div></div>
          <div class="ev" data-s="4"><div class="yr">1 mes</div><div class="tx"><b>Balance de apertura</b> certificado y aprobado.</div></div>
          <div class="ev" data-s="5"><div class="yr">Luego</div><div class="tx">Cuentas bancarias (aviso en 5 días hábiles) y libros habilitados.</div></div>
        </div>
        <div class="card blue" data-s="6"><h4>Ante la SAT</h4>
          ${ul(['Inscripción en el <b>RTU</b> y obtención del <b>NIT</b>', 'Habilitación de libros contables', 'Autorización de recibos de ingreso', 'Solvencia fiscal para sus donantes'], 6, 'sm')}
          <p class="small" style="margin-top:14px">Habitualmente se pide DPI y nombramiento del representante legal, testimonio de la escritura o resolución de inscripción y comprobante de domicilio fiscal. ${vf('confirmar con la SAT')}</p></div>
      </div>`,
    notes: `<p>Cierra el ciclo de inscripción y conecta con la contabilidad: al inscribirse los órganos permanentes en el Departamento de Organizaciones Políticas, el partido tiene <b>15 días para nombrar contador general</b> (Reglamento de fiscalización, art. 12) y 10 días hábiles para notificarlo a la Unidad Especializada con copia del RTU actualizado donde conste la inscripción del contador. El <b>balance de apertura</b> se presenta dentro del mes siguiente a la inscripción (Instructivo).</p><p>Ante la SAT: inscripción en el Registro Tributario Unificado y NIT (Decreto 25-71), habilitación de libros y autorización de recibos. <b>Los documentos exactos para organizaciones políticas deben confirmarse con la SAT</b>: el listado habitual para personas jurídicas incluye DPI y nombramiento del representante legal, testimonio de la escritura o resolución de inscripción y comprobante de domicilio fiscal (Agencia Virtual u oficina).</p>` });

  add({ sec: 1, t: 'Las finanzas desde antes de ser partido', m: 1.5, cls: 'vc',
    html: `${head('Inscripción · Finanzas', 'La contabilidad <em>no empieza</em> al ser partido')}
      <div class="cols c2" style="gap:36px">
        ${card('Comité para constituir un partido', 'Informe de ingresos y egresos <b>semestral</b> (INF-COMITÉ), dentro del mes posterior al semestre.', { s: 1, cls: 'blue' })}
        ${card('Qué no puede hacer', 'Propaganda, usar nombre o emblema en campañas ni actividades del artículo 20 de la LEPP.', { s: 2, cls: 'red' })}
      </div>
      <div class="mt2">${note('Para el contador', 'Los aportes que financian la formación del partido ya se registran, con recibo, sin anonimato y con los límites de la ley. Todo lo visto en la sección III aplica desde el primer día.', '', 3)}</div>`,
    notes: `<p>Los comités para la constitución de un partido son organizaciones políticas para efectos del Reglamento de fiscalización: presentan el informe INF-COMITÉ de forma semestral, dentro del mes posterior a concluido el semestre (art. 13).</p><p>El Reglamento de la LEPP (art. 14) prohíbe a un comité inscrito identificarse como partido o hacer propaganda y usar nombre, símbolo o emblema en campañas.</p>` });
})();
