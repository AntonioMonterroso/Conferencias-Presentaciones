/* Contenido, parte 3: secciones IV a VII */
(function () {
  const S = window.SLIDES, { head, law, vf, ul, card, note, tbl, divider } = window.H;
  const add = o => S.push(o);

  /* ===== IV · cuentas bancarias ===== */
  divider(3, 'Sistema de cuentas bancarias', 'Todo el dinero pasa por el banco: qué cuentas, para qué y con qué firmas, y cómo se comprueba cada ingreso y cada gasto.',
    `<p>Un depósito bancario deja huella: fecha, monto y origen. Por eso la ley exige cuentas separadas por origen.</p>`);

  add({ sec: 3, t: 'Cuentas bancarias obligatorias', m: 2,
    html: `${head('Sección IV · Sistema bancario ' + law('art. 21 a'), 'Cuentas <em>separadas</em> por origen')}
      <div class="bank4">
        <div class="card blue" data-s="1" style="min-height:230px"><h4>Financiamiento público</h4><p>Mínimo una a nivel nacional. Recibe la cuota del Estado.</p></div>
        <div class="card hot" data-s="2" style="min-height:230px"><h4>Financiamiento privado</h4><p>Una a nivel nacional. Cuotas, donaciones y autofinanciamiento.</p></div>
        <div class="card red" data-s="3" style="min-height:230px"><h4>Campaña electoral</h4><p>Se abre en el último cuatrimestre del año previo; activa al iniciar el año electoral.</p></div>
        <div class="card green" data-s="4" style="min-height:230px"><h4>Departamentales y municipales</h4><p>Una por organización partidaria vigente, a nombre de su secretario.</p></div>
      </div>`,
    notes: `<p>Reglamento arts. 18 y 19. Una cuenta para financiamiento público, una para privado, una específica de campaña (se abre en el último cuatrimestre del año anterior y debe estar abierta al inicio del año electoral) y cuentas por cada sede departamental o municipal con organización vigente.</p><p>El Instructivo, redactado antes, habla de abrir la cuenta de campaña en noviembre; el reglamento vigente fija el último cuatrimestre.</p>` });

  add({ sec: 3, t: 'Reglas comunes de las cuentas', m: 1.5,
    html: `${head('Sección IV · Sistema bancario', 'Reglas comunes ' + law('Reglamento arts. 18 y 19'))}
      ${ul([
        'A nombre del partido, en cualquier banco, con <b>firmas mancomunadas</b>',
        'Aviso escrito a la Unidad Especializada en <b>5 días hábiles</b> de cada apertura',
        'La cuenta de campaña se cancela dentro de <b>3 meses</b> de concluido el proceso; con obligaciones pendientes, hasta 6 meses',
        'En año electoral, la cuota pública para campaña se maneja en la cuenta de campaña',
        'Cada secretario liquida los fondos <b>trimestralmente</b>, bajo juramento y con facturas'], 1)}`,
    notes: `<p>El partido registra en una «cuenta por liquidar» los fondos entregados a cada secretario departamental o municipal, quienes envían informes trimestrales bajo juramento a la secretaría de finanzas.</p><p>Si un secretario no acepta los fondos, el secretario general con el de finanzas pueden pagar directamente servicios o bienes a favor de ese departamento o municipio, con control interno.</p>` });

  add({ sec: 3, t: 'El recibo de ingreso', m: 2, cls: 'hs',
    html: `${head('Sección IV · Comprobantes', 'Recibo autorizado por la SAT ' + law('Reglamento art. 19'))}
      <p class="lead a">Todo ingreso, en dinero o en especie, se acredita con un recibo que imprime el partido. Debe contener como mínimo:</p>
      <div class="recs a">
        <div><i>1</i>Nombre o razón social</div><div><i>2</i>Afiliado o simpatizante</div><div><i>3</i>NIT</div><div><i>4</i>CUI (DPI)</div>
        <div><i>5</i>Dirección</div><div><i>6</i>Descripción del aporte</div><div><i>7</i>Monto</div><div><i>8</i>Declaración de procedencia lícita</div>
        <div><i>9</i>Valor estimado (justiprecio)</div><div><i>10</i>Fecha del aporte</div><div><i>11</i>Firma y sello del receptor</div><div><i>12-13</i>Firma del secretario que acepta</div>
      </div>
      <div class="mt">${note('Control', 'El partido lleva control de los recibos usados en cada sede y los reporta en sus informes trimestrales.', '', 1)}</div>`,
    notes: `<p>Son trece datos mínimos: nombres o razón social; afiliado o simpatizante; NIT; CUI; dirección; descripción; monto; declaración de procedencia (que no está en prohibiciones); valor estimado y justiprecio; fecha; firma y sello del receptor; firma del secretario general, departamental o municipal que acepta; y, para comités cívicos, la firma de su presidente.</p>` });

  add({ sec: 3, t: 'Respaldo de los gastos', m: 1.5,
    html: `${head('Sección IV · Comprobantes', 'Qué respalda un gasto ' + law('Reglamento art. 24'))}
      ${tbl(null, [
        ['<b>Factura autorizada por la SAT</b>', 'Compras y servicios'],
        ['<b>Recibos de caja o notas de débito</b>', 'De entidades vigiladas por la Superintendencia de Bancos'],
        ['<b>Planillas IGSS y libros de salarios</b>', 'Sueldos, salarios y prestaciones'],
        ['<b>Otros que autorice la SAT</b>', 'Documentos de legítimo abono']
      ], { s0: 1 })}
      <div class="mt2">${note('Siempre a nombre de la organización política', 'Un gasto sin documento legal es un hallazgo seguro.', 'warn', 5)}</div>`,
    notes: `<p>Todo gasto, sin excepción, debe tener documentación legal emitida a nombre de la organización política. Esto incluye los gastos de los secretarios departamentales y municipales al liquidar el financiamiento público (art. 18 e).</p>` });

  /* ===== V · libros ===== */
  divider(4, 'Libros obligatorios', 'La contabilidad se lleva en libros habilitados por la SAT; la vigilancia de contribuciones, en libros habilitados por el TSE.',
    `<p>Dos juegos de libros con finalidades distintas: los contables y los de contribuciones.</p>`);

  add({ sec: 4, t: 'Libros contables (SAT)', m: 2,
    html: `${head('Sección V · Libros contables ' + law('Reglamento art. 11'), 'Habilitados por la <em>SAT</em>')}
      ${tbl(['Libro', 'Qué registra', 'Para qué sirve'], [
        ['<b>Diario</b>', 'Cada operación en orden de fecha, con su partida', 'Deja la historia cronológica'],
        ['<b>Mayor</b>', 'Movimientos agrupados por cuenta', 'Muestra el saldo de cada cuenta'],
        ['<b>Inventarios</b>', 'Bienes y derechos del partido', 'Respalda patrimonio y activo fijo'],
        ['<b>Estados financieros</b>', 'Balance, ingresos y egresos, notas', 'Informa la situación y el resultado']
      ], { cls: 'sm', s0: 1 })}
      <div class="cols c3 mt" style="gap:22px">
        ${card('Al día', 'Operaciones asentadas dentro de 2 meses calendario.', { s: 5 })}
        ${card('Conservación', 'Cinco años, ordenados, para la fiscalización.', { s: 6 })}
        ${card('Contador externo', 'Se informa a la Unidad en 10 días hábiles.', { s: 7, cls: 'green' })}
      </div>`,
    notes: `<p>Contabilidad centralizada, por partida doble, con registros físicos y electrónicos y documentos de soporte (art. 11). Los libros permanecen en la sede central y el TSE tiene acceso permanente.</p><p>La documentación del interior del país debe llegar a la sede central para el registro centralizado. Contratar contabilidad externa no exime de tener toda la documentación disponible.</p>` });

  add({ sec: 4, t: 'Libros de contribuciones (TSE)', m: 2,
    html: `${head('Sección V · Libros de contribuciones ' + law('art. 21 Ter c'), 'Habilitados por la <em>Unidad Especializada</em>')}
      <div class="cols c2" style="gap:26px">
        ${card('Contribuciones en efectivo', 'Todo aporte en dinero al partido y lo que un financista da en beneficio de un candidato.', { s: 1 })}
        ${card('Contribuciones en especie', 'Cada aporte no dinerario a valor de mercado, con el criterio de un tercero independiente.', { s: 2 })}
        ${card('Formación por entidades extranjeras', 'Ingresos y gastos de formación financiados desde el exterior.', { s: 3, cls: 'blue' })}
        ${card('Formación por entidades nacionales', 'Mismo detalle, para entidades del país (Instructivo).', { s: 4, cls: 'green' })}
      </div>
      <div class="mt">${note('Los financistas también llevan libros', 'Quien aporta Q30,000 o más en un período fiscal habilita los suyos. Con ellos el TSE verifica que el dinero existía seis meses antes.', '', 5)}</div>`,
    notes: `<p>Estos libros no sustituyen a la contabilidad; la complementan. Vigilan <b>quién aporta</b>. Los registros contables de los partidos son públicos.</p>` });

  add({ sec: 4, t: 'Cómo se complementan los libros', m: 1.2, cls: 'vc',
    html: `${head('Sección V · Libros', 'Del recibo al informe')}
      <div class="flow mt2" style="height:280px">
        <div class="st a"><b>Recibo</b>Prueba del aporte</div>
        <div class="st" data-s="1"><b>Libro de contribuciones</b>Quién y cuánto</div>
        <div class="st" data-s="2"><b>Diario y Mayor</b>Registro contable</div>
        <div class="st" data-s="3"><b>Informes</b>Rendición al TSE</div>
      </div>
      <p class="lead mt2" data-s="4">Cada dato nace en un documento y termina en un informe. Si un eslabón falta, la cadena se rompe.</p>`,
    notes: `<p>Resuma la sección: recibo, libro de contribuciones, contabilidad y rendición de cuentas. Los informes se publican en el portal del TSE.</p>` });

  /* ===== VI · plan de cuentas ===== */
  divider(5, 'Plan de cuentas', 'La nomenclatura contable del Instructivo del TSE: cinco niveles, cinco grupos y un código para cada concepto.',
    `<p>La nomenclatura es la columna vertebral del registro. El Instructivo la fija y el partido puede agregar cuentas correlativas.</p>`);

  const code = (a, b, c, d, e) => `<div class="code a"><span class="${a}">4</span><span style="color:#5a4c2c">-</span><span class="${b}">2</span><span style="color:#5a4c2c">-</span><span class="${c}">1</span><span style="color:#5a4c2c">-</span><span class="${d}">102</span><span style="color:#5a4c2c">-</span><span class="${e}">01</span></div>`;
  add({ sec: 5, t: 'Cómo se codifica una cuenta', m: 1.5,
    html: `${head('Sección VI · Plan de cuentas', 'Cinco niveles, <em>un</em> código')}
      <div class="mt">${code('on', 'off', 'off', 'off', 'off')}</div>
      <div class="lvls">
        <div class="lv on a"><b>1 dígito</b>Grupo<br>4 · Ingresos</div>
        <div class="lv" data-s="1"><b>2 dígitos</b>Subgrupo<br>4-2 · Financiamiento privado</div>
        <div class="lv" data-s="2"><b>3 dígitos</b>Cuenta<br>4-2-1 · Financiamiento privado</div>
        <div class="lv" data-s="3"><b>4 dígitos</b>Cuenta principal<br>4-2-1-102 · Afiliados</div>
        <div class="lv" data-s="4"><b>5 dígitos</b>Cuenta auxiliar<br>4-2-1-102-01 · Cuotas ordinarias</div>
      </div>
      <p class="small mt2 center" data-s="5">«Si la organización utiliza otras cuentas, pueden agregarse en el rubro que corresponda, correlativamente».</p>`,
    notes: `<p>Ejemplo: <b>4-2-1-102-01</b> es «Afiliados: cuotas ordinarias». El primer dígito es el grupo; los dos primeros, el subgrupo; los tres primeros, la cuenta; los cuatro primeros, la cuenta principal; los cinco, la auxiliar.</p><p>No se cambia la codificación de las cuentas existentes; solo se agregan nuevas en el rubro correspondiente.</p>`,
    hook(el, step) {
      const cls = ['on', 'on', 'on', 'on', 'on'];
      const spans = el.querySelectorAll('.code span:not([style])');
      spans.forEach((s, i) => { s.className = i <= step ? 'on' : 'off'; });
    } });

  add({ sec: 5, t: 'Grupo 1: Activo', m: 1.5,
    html: `${head('Sección VI · Plan de cuentas', 'Grupo 1 · <em>Activo</em>')}
      ${tbl(null, [
        ['<b>1-1-1</b>', 'Efectivo: 101 Caja · 102 Caja chica'],
        ['<b>1-1-2</b>', 'Bancos: 201 público · 202 privado · 203 departamentos · 204 municipios · 205 campaña'],
        ['<b>1-1-3</b>', 'Cuentas por cobrar: financiamiento público, afiliados, otras'],
        ['<b>1-1-4</b>', 'Inventarios: materiales electorales, artículos promocionales'],
        ['<b>1-1-5</b>', 'Pagados por anticipado: seguros, alquileres, proveedores'],
        ['<b>1-2-1</b>', 'Propiedad, planta y equipo: mobiliario (104), cómputo (105), vehículos (106) y sus depreciaciones'],
        ['<b>1-2-2</b>', 'Intangibles: gastos de organización y su amortización']
      ], { cls: 'sm', s0: 1 })}`,
    notes: `<p>El activo corriente se espera realizar en el período contable o es efectivo sin restricciones. El no corriente se realiza en más de un período o tiene menor liquidez (maquinaria, vehículos, mobiliario y equipo, intangibles).</p>` });

  add({ sec: 5, t: 'Grupos 2 y 3: Pasivo y Patrimonio', m: 2,
    html: `${head('Sección VI · Plan de cuentas', 'Grupos 2 y 3 · Pasivo y <em>Patrimonio</em>')}
      <div class="cols c2" style="gap:30px">
        <div class="card" data-s="1"><h4>2 · Pasivo corriente</h4><p>2-1-1 Documentos por pagar · 2-1-2 Cuentas por pagar (proveedores locales y del exterior) · 2-1-3 Pasivo laboral</p></div>
        <div class="card" data-s="2"><h4>2 · Pasivo no corriente</h4><p>2-2-1 Documentos a largo plazo · 2-2-2 Cuentas por pagar, préstamos bancarios y de terceros</p></div>
        <div class="card green" data-s="3"><h4>3 · Patrimonio partidario</h4><p>3-1-1 Activo neto de la organización</p></div>
        <div class="card green" data-s="4"><h4>3 · Resultados acumulados</h4><p>3-2-1: ejercicios anteriores y presente ejercicio</p></div>
      </div>
      <div class="eq mt2" data-s="5">Activo <em>=</em> Pasivo <em>+</em> Patrimonio</div>`,
    notes: `<p>Un pasivo debe poder exigirse por contrato, letra, pagaré, factura cambiaria u otro documento legal y se cancela por el sistema bancario, a nombre del proveedor. La condonación de una deuda se trata como donación.</p><p>En el Balance de Situación, el resultado del ejercicio se suma al patrimonio.</p>` });

  add({ sec: 5, t: 'Grupo 4: Ingresos', m: 1.5, cls: 'hs',
    html: `${head('Sección VI · Plan de cuentas', 'Grupo 4 · <em>Ingresos</em>')}
      ${tbl(null, [
        ['<b>4-1</b>', 'Financiamiento público: 4-1-1-101 Cuota política del año'],
        ['<b>4-2</b>', 'Privado: 101 Simpatizantes · 102 Afiliados (01 ordinarias, 02 extraordinarias) · 103-104 Formación · 105 Candidatos'],
        ['<b>4-3</b>', 'Autofinanciamiento: conferencias, espectáculos, sorteos, eventos, cenas (105), juegos'],
        ['<b>4-4</b>', 'Otros ingresos: 4-4-1-101 Productos financieros'],
        ['<b>4-5</b>', '<b>Ingresos no dinerarios (cuentas de control):</b> cesión de derechos (4-5-1), donación de bienes y servicios (4-5-2), préstamo o comodato (4-5-3)']
      ], { cls: 'sm', s0: 1 })}
      <div class="mt">${note('Cuentas de control', 'Las cuentas 4-5 y 5-3 no mueven bancos: reflejan el aporte en especie justipreciado, una vez como ingreso y otra como gasto, para vigilar el techo.', '', 6)}</div>`,
    notes: `<p>4-5-2 incluye servicios personales, playeras y gorras, material de propaganda, atención de simpatizantes, alimentos, combustibles, transporte, hospedaje y otros servicios. 4-5-3 incluye vehículos terrestres, aéreos y marítimos, equipo de audio, bienes muebles e inmuebles y otros bienes.</p>` });

  add({ sec: 5, t: 'Grupo 5: Egresos permanentes', m: 1.5, cls: 'hs',
    html: `${head('Sección VI · Plan de cuentas', 'Grupo 5 · Egresos <em>permanentes</em>')}
      ${tbl(null, [
        ['<b>5-1-1</b>', 'Funcionamiento: sueldos (101), alquiler de sedes (102-104), agua, luz y teléfono (105), materiales, mantenimiento, depreciaciones (108)'],
        ['<b>5-1-2</b>', 'Asambleas de ley: organización nacional, departamental y municipal; medios de comunicación'],
        ['<b>5-1-3</b>', 'Campañas de afiliación: proselitismo nacional, departamental y municipal; alimentación y hospedaje (305)'],
        ['<b>5-1-4</b>', 'Formación política por entidades extranjeras'],
        ['<b>5-1-5</b>', 'Formación política nacional: organización, material didáctico, capacitadores, alimentación, viáticos']
      ], { cls: 'sm', s0: 1 })}
      <div class="mt">${note('Cómo elegir la cuenta', 'Pregúntese para qué se hizo el gasto, no quién lo cobró. Una cena de recaudación va a campañas de afiliación; un taller para fiscales, a formación política.', '', 6)}</div>`,
    notes: `<p>Los gastos permanentes financian proselitismo y funcionamiento en cualquier época (Reglamento art. 3 h).</p>` });

  add({ sec: 5, t: 'Grupo 5: Campaña y cuentas de control', m: 1.5, cls: 'hs',
    html: `${head('Sección VI · Plan de cuentas', 'Grupo 5 · <em>Campaña</em> y control')}
      ${tbl(null, [
        ['<b>5-2-1</b>', 'Propaganda: edición, encuestas, alquiler temporal, viajes, caravanas'],
        ['<b>5-2-2</b>', 'Materiales y suministros: mantas, pinturas, productos promocionales'],
        ['<b>5-2-3</b>', 'Movilización: transporte en giras, viáticos, protocolo'],
        ['<b>5-2-4</b>', 'Alquileres: inmuebles, vehículos, mobiliario y equipo'],
        ['<b>5-2-5</b>', 'Honorarios: profesionales, servicios personales, asesores, cursos'],
        ['<b>5-2-6</b>', 'Día de votaciones: fiscales, transporte, alimentación, combustibles'],
        ['<b>5-3</b>', '<b>Egresos no dinerarios (control):</b> espejo de 4-5']
      ], { cls: 'sm', s0: 1 })}
      <div class="mt">${note('Todo cuenta contra el techo', 'Los gastos 5-2 y los aportes en especie de campaña suman para el límite de US$0.50 por empadronado. Controle el acumulado cada mes.', 'warn', 8)}</div>`,
    notes: `<p>Cuando se usa la cuota pública para campaña, esos gastos también cuentan para el techo (art. 21 Bis d).</p>` });

  add({ sec: 5, t: 'Asientos tipo del Instructivo', m: 2, cls: 'hs',
    html: `${head('Sección VI · Plan de cuentas', 'Dos asientos que <em>conviene</em> dominar')}
      <div class="pgrid">
        <div class="a">
          <div class="partida"><div class="ph"><span>Cena con servicio donado por un hotel</span><span class="num">10,000</span></div><table>
            <tr><td class="c">5-3-2-206</td><td>Egreso: atención para protocolos</td><td class="d">10,000</td><td class="hh"></td></tr>
            <tr><td class="c">4-5-2-206</td><td class="h">Ingreso: atención para protocolos</td><td class="d"></td><td class="hh">10,000</td></tr></table>
            <div class="gl2">Cuentas de control. Respaldo: recibo de donación no dineraria y factura a nombre del partido.</div></div>
          <div class="partida" data-s="1"><div class="ph"><span>Dinero recaudado en la cena</span><span class="num">100,000</span></div><table>
            <tr><td class="c">1-1-2-202</td><td>Banco financiamiento privado</td><td class="d">100,000</td><td class="hh"></td></tr>
            <tr><td class="c">4-3-1-105</td><td class="h">Desayunos, almuerzos y cenas</td><td class="d"></td><td class="hh">100,000</td></tr></table>
            <div class="gl2">Un recibo por cada participante, según su aportación.</div></div>
        </div>
        <div data-s="2">
          <div class="partida"><div class="ph"><span>Vehículo prestado en comodato</span><span class="num">8,000</span></div><table>
            <tr><td class="c">5-3-3-301</td><td>Egreso: vehículos terrestres</td><td class="d">8,000</td><td class="hh"></td></tr>
            <tr><td class="c">4-5-3-301</td><td class="h">Ingreso: vehículos terrestres</td><td class="d"></td><td class="hh">8,000</td></tr></table>
            <div class="gl2">A valor de alquiler de mercado. Se lleva un registro con la integración y especificaciones del bien prestado.</div></div>
          <div class="note" data-s="3"><b>Regla</b>Un aporte en especie se registra por su valor justipreciado, tanto en ingreso como en egreso.</div>
        </div>
      </div>`,
    notes: `<p>Ejemplos tomados del Instructivo del TSE con montos ilustrativos. Primero la donación del servicio (cuentas de control), luego el efectivo recaudado. En el comodato, el inmueble o vehículo se registra como arrendamiento justipreciado.</p>` });

  /* ===== VII · estados ===== */
  divider(6, 'Estados financieros al TSE', 'Qué se presenta, cuándo, con qué firmas y por qué plataforma.',
    `<p>Tres estados, cinco firmas y un calendario de informes. Esta sección es la lista de verificación del contador.</p>`);

  add({ sec: 6, t: 'Qué se presenta', m: 2,
    html: `${head('Sección VII · Estados financieros ' + law('Reglamento art. 13'), 'Del 1 de enero al 31 de diciembre')}
      <div class="cols c3" style="gap:26px">
        ${card('Balance de situación general', 'Activo, pasivo y patrimonio a una fecha.', { s: 1 })}
        ${card('Estado de ingresos y egresos', 'Financiamiento público y privado, gastos permanentes y de campaña, resultado.', { s: 2 })}
        ${card('Notas', 'Descripciones y análisis de las cuentas.', { s: 3, cls: 'green' })}
      </div>
      <div class="mt"><div class="cap a" style="--d:400ms">Dentro de 3 meses del cierre · se adjunta</div></div>
      ${ul(['Libros <b>Diario y Mayor</b> (copia digital) y libros de contribuciones',
        'Certificación del contador general y del secretario de finanzas',
        'Revisión del órgano de fiscalización financiera y autorización del representante legal',
        'Firma y sello de un contador público y auditor con colegiado activo, y <b>dictamen externo</b> costeado por el partido'], 4, 'sm')}`,
    notes: `<p>Los estados se elaboran con NIC y NIIF. Cada documento lleva cinco firmas, según el Instructivo.</p><p>La organización inscrita nueva presenta su <b>balance de apertura</b> dentro del mes siguiente a su inscripción.</p>` });

  add({ sec: 6, t: 'Calendario de informes', m: 2, cls: 'hs',
    html: `${head('Sección VII · Estados financieros', 'Calendario de informes de un partido')}
      ${tbl(['Informe', 'Cuándo'], [
        ['<b>Estados financieros</b> + Diario, Mayor y contribuciones', 'Dentro de 3 meses del cierre (31 de marzo)'],
        ['<b>GR-PRI</b> · financiamiento privado por origen y gastos', 'Trimestral, dentro del mes posterior; aprobado por el secretario general'],
        ['<b>INF-FINPU</b> · uso del financiamiento público', 'Semestral, dentro del mes posterior'],
        ['<b>INFOCAM</b> · financiero de campaña', 'Dentro de 3 meses de concluido el proceso'],
        ['<b>Publicidad</b> · aportes de 2 años, de campaña y balance', '30 días antes de la elección ' + law('art. 21 Quinquies')]
      ], { cls: 'sm', s0: 1 })}
      <div class="mt">${note('Si hay un error', 'GR-PRI, INF-FINPU e INFOCAM pueden rectificarse en 30 días de vencido el plazo, tras pedir la habilitación. No se puede si ya inició una auditoría. Plataforma: Sistema Cuentas Claras Guatemala ' + law('art. 30'), 'ok', 6)}</div>`,
    notes: `<p>Comités cívicos: informe mensual (INF-COMIT). Asociaciones con fines políticos y comités para constituir partido: semestral.</p><p>Todos los informes deben estar certificados por el contador general y el secretario de finanzas, revisados por el órgano de fiscalización financiera y autorizados por el representante legal.</p>` });

  add({ sec: 6, t: 'Las notas a los estados financieros', m: 1.5, cls: 'hs',
    html: `${head('Sección VII · Estados financieros', 'Trece <em>notas</em> a revelar')}
      <div class="recs a" style="font-size:25px">
        <div><i>1</i>Antecedentes</div><div><i>2</i>Principios y prácticas</div><div><i>3</i>Caja y bancos</div><div><i>4</i>Cuentas por cobrar</div>
        <div><i>5</i>Inventarios</div><div><i>6</i>Propiedad, planta y equipo</div><div><i>7</i>Documentos y cuentas por pagar</div><div><i>8</i>Pasivo laboral</div>
        <div><i>9</i>Cuentas por pagar a largo plazo</div><div><i>10</i>Patrimonio</div><div><i>11</i>Ingresos</div><div><i>12</i>Otros ingresos</div><div><i>13</i>Egresos</div>
      </div>
      <div class="mt">${note('Nota 2, el detalle que más se olvida', 'Debe revelar el régimen de impuestos y las exenciones que invoca. Conecta la contabilidad con lo que se hace ante la SAT.', '', 1)}</div>`,
    notes: `<p>La lista es enunciativa, no limitativa. Nota 1: antecedentes (objeto, marco legal, constitución, NIT, fecha y número de inscripción). Nota 2: principios, base de medición, justiprecio y situación tributaria. Las demás detallan cada rubro.</p>` });
})();
