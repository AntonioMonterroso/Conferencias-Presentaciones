/* Contenido, parte 2: sección III, naturaleza y financiamiento */
(function () {
  const S = window.SLIDES, { head, law, vf, ul, card, note, tbl, divider } = window.H;
  const add = o => S.push(o);
  const q = (el, s) => el.querySelector(s);
  const TC = 7.62;

  divider(2, 'Naturaleza y financiamiento', 'Qué es un partido, de dónde puede recibir dinero, cuánto y cómo debe repartir el aporte del Estado.',
    `<p>Es la sección más larga y la más importante: fuentes, prohibiciones, techos y distribución del aporte público. Habrá tres calculadoras en vivo.</p>`);

  add({ sec: 2, t: 'Naturaleza jurídica', m: 1.2, cls: 'vc',
    html: `<div class="kick a">Sección III · Naturaleza jurídica ${law('LEPP art. 18')}</div>
      <p class="q a">Los partidos políticos son <b>instituciones de derecho público</b>, con <b>personalidad jurídica</b> y <b>duración indefinida</b>.</p>
      <p class="lead a mt2" style="--d:700ms">Configuran el carácter democrático del régimen político del Estado.</p>`,
    notes: `<p>El artículo 18 de la LEPP define al partido como institución de derecho público. Esto explica por qué su contabilidad es pública y está sujeta a fiscalización de la Contraloría General de Cuentas y del TSE en lo que cada uno le compete (art. 19 Bis).</p>` });

  add({ sec: 2, t: 'Cuatro tipos de organización política', m: 1.2,
    html: `${head('Sección III · Naturaleza jurídica', 'Cuatro organizaciones políticas ' + law('art. 16'))}
      <div class="cols c2" style="gap:28px">
        ${card('Partidos políticos', 'Permanentes. Reciben financiamiento público si cumplen el requisito de votos o diputaciones.', { s: 1 })}
        ${card('Comités para constituir un partido', 'Informe semestral de ingresos y egresos (INF-COMITÉ).', { s: 2 })}
        ${card('Comités cívicos electorales', 'Temporales. Solo financiamiento privado. Informe mensual (INF-COMIT).', { s: 3, cls: 'blue' })}
        ${card('Asociaciones con fines políticos', 'Formación política. No postulan candidatos. Informe semestral.', { s: 4, cls: 'green' })}
      </div>`,
    notes: `<p>El Instructivo del TSE se dirige a las cuatro. Destaque que los comités cívicos se financian únicamente con aportes privados y su límite de gasto es de US$0.10 por ciudadano empadronado del municipio (art. 21 Ter f).</p>` });

  add({ sec: 2, t: 'Qué implica para la contabilidad', m: 1.2,
    html: `${head('Sección III · Naturaleza jurídica', 'Tres consecuencias contables')}
      <div class="stack mt">
        <div class="card" data-s="1"><h4>Patrimonio íntegro ${law('art. 21 Ter d')}</h4><p>Se registra completo en la contabilidad. Sin títulos al portador ni cuentas anónimas.</p></div>
        <div class="card" data-s="2"><h4>Registros públicos ${law('art. 21 Ter c')}</h4><p>Los registros contables de los partidos son públicos.</p></div>
        <div class="card hot" data-s="3"><h4>Responsabilidad personal ${law('art. 19 Bis')}</h4><p>Secretarios generales nacional, departamentales y municipales responden por los fondos que manejan.</p></div>
      </div>`,
    notes: `<p>Estas tres ideas orientan todo lo que sigue. El partido no puede tener patrimonio escondido; todo es público; y los dirigentes responden con su nombre.</p>` });

  add({ sec: 2, t: 'Mapa de las fuentes', m: 1.5,
    html: `${head('Sección III · Fuentes', 'Tres categorías de ingreso')}
      <div class="cols c3" style="gap:28px">
        <div class="card blue" data-s="1" style="min-height:470px"><h4>Públicas · el Estado</h4><div class="hero m" style="margin:12px 0">US$2</div><p>por voto legalmente emitido, a partidos con al menos 5 % de votos válidos o una diputación. Destino fijado por ley: 30 / 20 / 50.</p></div>
        <div class="card" data-s="2" style="min-height:470px"><h4>Privadas · personas</h4><p>Cuotas de afiliados, aportes de simpatizantes, autofinanciamiento, productos financieros y aportes en especie.</p><p class="small" style="margin-top:18px">Con recibo SAT, sin anonimato y con límite del 10 % del techo de campaña por aportante.</p></div>
        <div class="card red" data-s="3" style="min-height:470px"><h4>Prohibidas · nunca</h4><p>Estados y personas extranjeras; condenados por delitos contra la administración pública o lavado; extinción de dominio; fundaciones apolíticas; aportes anónimos.</p></div>
      </div>
      <div class="mt">${note('Regla de oro', 'Cada ingreso se identifica: quién, cuánto, cuándo, en qué forma y de dónde viene. Si no consta en los libros del financista seis meses antes, no se considera procedente ' + law('art. 21 Ter b'), '', 4)}</div>`,
    notes: `<p>Todo ingreso cae en una de tres categorías. Saber en cuál está decide cómo se registra, dónde se deposita y cuánto se admite.</p><p>La regla de los seis meses es una barrera contra dinero que aparece de repente en las cuentas del financista justo antes de aportar.</p>` });

  add({ sec: 2, t: 'Financiamiento público: US$2 por voto', m: 1.5,
    html: `<div class="cols c2" style="gap:70px;align-items:center">
        <div>${head('Financiamiento público', 'El aporte del <em>Estado</em> ' + law('art. 21 Bis'))}
          <p class="lead a">El Estado contribuye con el equivalente en quetzales de <b>dos dólares</b> por voto legalmente emitido a favor del partido.</p></div>
        <div class="center a-z"><div class="hero" style="font-size:300px">US$<span class="cnt" data-to="2" data-dec="0">2</span></div><div class="cap">por voto válido</div></div></div>
      <div class="cols c2 mt2" style="gap:30px">
        ${card('Condición A', 'Obtener al menos el <b>5 %</b> de los votos válidos en elecciones generales.', { s: 1 })}
        ${card('Condición B', 'O bien, obtener <b>al menos una diputación</b> al Congreso, aunque no llegue al 5 %.', { s: 2, cls: 'green' })}
      </div>
      <p class="small mt" data-s="3">El cálculo toma la mayor cantidad de votos válidos: la de presidente y vicepresidente o la del Listado Nacional.</p>`,
    notes: `<p>El derecho nace con cualquiera de las dos condiciones. El cálculo usa la mayor cantidad de votos válidos recibidos, ya sea en la fórmula presidencial o en el Listado Nacional de diputados.</p>` });

  add({ sec: 2, t: 'Cómo se paga el financiamiento público', m: 1.2,
    html: `${head('Financiamiento público', 'Cuándo y cómo se paga')}
      ${tbl(null, [
        ['Período', 'El período presidencial correspondiente'],
        ['Cuotas', 'Cuatro cuotas anuales e iguales'],
        ['Cuándo', 'Durante el mes de <b>julio</b> de cada año'],
        ['Año electoral', 'Si destina la cuota a campaña, se entrega en <b>enero</b>'],
        ['Requisito previo', 'Certificación del acta del CEN que acredite cómo se distribuyó'],
        ['Coalición', 'Se reparte según el convenio de coalición']
      ], { s0: 1 })}`,
    notes: `<p>El ejemplo del Instructivo: los votos de 2015 se dividen entre cuatro años de período. Cada año se paga una cuota igual.</p><p>Sin la certificación del acta del Comité Ejecutivo Nacional que acredite la distribución, no se entrega la cuota.</p>` });

  /* calculadora pública */
  const PUB = [
    { n: 'Futuro Retalteco', v: 150000, t: 5000000, d: 1 },
    { n: 'Partido B', v: 300000, t: 5000000, d: 0 },
    { n: 'Partido C', v: 200000, t: 5000000, d: 0 }
  ];
  add({ sec: 2, t: 'Calculadora: financiamiento público', m: 2.5, steps: 2,
    html: `${head('Calculadora en vivo', 'Tres partidos, tres resultados')}
      <div class="cols c2" style="gap:50px;align-items:start">
        <div class="stack">
          <div class="card"><h4>Partido</h4><p class="num"><b data-k="n" style="font-size:50px;color:var(--gold2);font-family:var(--display)"></b></p></div>
          <div class="cols c3" style="gap:18px">
            <div class="card"><h4>Votos</h4><p class="num" style="font-size:40px;color:var(--ink)"><span data-k="v">0</span></p></div>
            <div class="card"><h4>% del total</h4><p class="num" style="font-size:40px;color:var(--ink)"><span data-k="pct">0</span></p></div>
            <div class="card"><h4>Diputaciones</h4><p class="num" style="font-size:40px;color:var(--ink)"><span data-k="d">0</span></p></div>
          </div>
          <div><span class="verdict ok" data-k="ver"></span></div>
          <p class="small">Total de votos válidos supuesto: 5,000,000 · Tipo de cambio: Q7.62</p>
        </div>
        <div class="card hot" style="padding:40px 44px">
          <div class="cap">Total del período (4 años)</div><div class="hero s num" data-k="usd4">US$ 0</div>
          <div class="cap mt">Cuota anual en dólares</div><div class="hero s num" data-k="usd1">US$ 0</div>
          <div class="cap mt">Cuota anual en quetzales</div><div class="hero m num" data-k="q1">Q 0</div>
        </div></div>`,
    hook(el, step, c) {
      const p = PUB[Math.min(step, 2)], pct = p.v / p.t * 100, ok = pct >= 5 || p.d >= 1;
      const usd4 = ok ? p.v * 2 : 0, usd1 = usd4 / 4, q1 = usd1 * TC, ins = { instant: c.instant };
      q(el, '[data-k=n]').textContent = p.n;
      q(el, '[data-k=pct]').textContent = pct.toFixed(2) + ' %';
      q(el, '[data-k=d]').textContent = p.d;
      const v = q(el, '[data-k=ver]'); v.className = 'verdict ' + (ok ? 'ok' : 'no');
      v.textContent = ok ? (pct >= 5 ? 'Tiene derecho: supera el 5 %' : 'Tiene derecho: obtuvo una diputación') : 'Sin derecho: menos de 5 % y sin diputaciones';
      c.countTo(q(el, '[data-k=v]'), p.v, ins);
      c.countTo(q(el, '[data-k=usd4]'), usd4, Object.assign({ pre: 'US$ ' }, ins));
      c.countTo(q(el, '[data-k=usd1]'), usd1, Object.assign({ pre: 'US$ ' }, ins));
      c.countTo(q(el, '[data-k=q1]'), q1, Object.assign({ pre: 'Q ' }, ins));
    },
    notes: `<p><b>Paso 0:</b> Futuro Retalteco, 150,000 votos de 5,000,000 = 3 %. No llega al 5 %, pero tiene una diputación: tiene derecho. 150,000 × US$2 = US$300,000 en cuatro años; US$75,000 al año; ×7.62 = <b>Q571,500</b>.</p><p><b>Paso 1:</b> Partido B con 300,000 votos = 6 %: tiene derecho por superar el 5 %. Cuota anual: Q1,143,000.</p><p><b>Paso 2:</b> Partido C con 200,000 votos = 4 % y ninguna diputación: <b>sin derecho</b>.</p>` });

  add({ sec: 2, t: 'Distribución obligatoria 30 / 20 / 50', m: 2.5, cls: 'hs',
    html: `${head('Distribución obligatoria ' + law('art. 21 Bis'), 'Cómo debe <em>repartirse</em> el aporte público')}
      <div class="dist a" data-go="1"><span style="background:#e9c97a">30 %</span><span style="background:#94b9e0">20 %</span><span style="background:#94c98d">50 %</span></div>
      <div class="cols c3 mt" style="gap:28px">
        <div class="card hot a"><h4>30 % · Formación</h4><p>Formación y capacitación de afiliados, cuadros y fiscales.</p></div>
        <div class="card blue a"><h4>20 % · Sede nacional</h4><p>Actividades nacionales y funcionamiento de la sede nacional.</p></div>
        <div class="card green a"><h4>50 % · Territorio</h4><p>Funcionamiento en departamentos y municipios con organización vigente.</p></div>
      </div>
      <div class="cols c2 mt" style="gap:28px">
        <div class="card green" data-s="2"><h4>De ese 50 %</h4><p><b>Un tercio</b> a los órganos departamentales y <b>dos tercios</b> a los municipales, según los empadronados de cada circunscripción.</p></div>
        <div class="card hot" data-s="3"><h4>En año electoral</h4><p>Todo el aporte puede destinarse a campaña (se paga en enero), por la cuenta de campaña. <b>Cuenta contra el techo.</b></p></div>
      </div>
      ${note('Cuidado con el Instructivo', 'Un cuadro ilustra la distribución con las etiquetas de 20 y 30 % intercambiadas. Aplique el orden de la ley: 30 % formación, 20 % sede nacional.', 'warn', 4)}`,
    notes: `<p>Dibuje la barra: 30 % formación, 20 % sede nacional, 50 % territorio. Los secretarios generales de los comités ejecutivos son personalmente responsables del manejo de estos fondos.</p><p>Se consideran fines de formación ideológica y política los gastos para capacitar afiliados, cuadros y fiscales electorales, y la formación y publicación de material de capacitación.</p><p>Si un departamento o municipio pierde vigencia, el CEN puede certificar una nueva distribución (art. 18 d del Reglamento).</p>` });

  add({ sec: 2, t: 'Financiamiento privado: tipos', m: 1.5,
    html: `${head('Financiamiento privado', 'Tipos de aporte y qué significa cada uno')}
      ${tbl(null, [
        ['<b>Aportes de afiliados</b>', 'Cuotas ordinarias o extraordinarias, en dinero o en especie.'],
        ['<b>Aportes de simpatizantes</b>', 'De personas no afiliadas, a título propio.'],
        ['<b>Autofinanciamiento</b>', 'Cenas, conferencias, espectáculos, sorteos, juegos. Antes debe existir un egreso con recursos propios o un aporte en especie.'],
        ['<b>Productos financieros</b>', 'Intereses de inversiones hechas con financiamiento privado.'],
        ['<b>Aporte en dinero</b>', 'Se canaliza por la organización y se deposita en su cuenta.'],
        ['<b>Aporte en especie</b>', 'Bien o servicio sin transferencia de dinero; se acepta por recibo y se justiprecia.']
      ], { cls: 'sm', s0: 1 })}`,
    notes: `<p>Definiciones del Instructivo y del artículo 3 del Reglamento. Recalque que el autofinanciamiento exige un registro previo del gasto con recursos propios o de un aporte no dinerario; luego se registra el ingreso.</p><p>Los préstamos bancarios o de terceros no son ingreso: son pasivo. Si un acreedor perdona la deuda, eso es una donación y cuenta para el techo si ocurre en época electoral.</p>` });

  add({ sec: 2, t: 'Aportes en especie y justiprecio', m: 1.5,
    html: `${head('Financiamiento privado', 'El aporte en especie y su <em>justiprecio</em>')}
      <div class="cols c3" style="gap:26px">
        ${card('Donación', 'La persona transfiere gratuitamente bienes o derechos.', { s: 1 })}
        ${card('Cesión de derechos', 'Se cede a la organización la titularidad jurídica de una cosa.', { s: 2 })}
        ${card('Comodato', 'Uso temporal de un bien. El dueño puede pedirlo de vuelta; se registra por el valor de alquiler de mercado.', { s: 3, cls: 'blue' })}
      </div>
      <div class="mt2">${note('Justiprecio', 'Valor de mercado asignado al aporte. Si no se justiprecia, la Unidad Especializada pide hacerlo en 5 días; si no es razonable, lo estima con el IPC del INE o precios de mercado ' + law('Reglamento art. 19'), '', 4)}</div>`,
    notes: `<p>Los aportes en especie se aceptan expresamente por recibo y se justiprecian a valor de mercado. El donante debe acreditar la propiedad de lo aportado.</p><p>En contabilidad se registran en cuentas de control: ingreso (4-5) y egreso (5-3) por el mismo valor, para vigilar el techo de campaña.</p>` });

  add({ sec: 2, t: 'Financiamiento prohibido', m: 2,
    html: `${head('Financiamiento prohibido ' + law('art. 21 Ter a'), 'Lo que un partido nunca debe recibir')}
      <div class="cols c2" style="gap:26px">
        <div class="nm" data-s="1"><i>1</i><span><b>Estados y personas extranjeras</b>, individuales o jurídicas.</span></div>
        <div class="nm" data-s="2"><i>2</i><span><b>Condenados</b> por delitos contra la administración pública, lavado de dinero u otros activos.</span></div>
        <div class="nm" data-s="3"><i>3</i><span><b>Extinción de dominio:</b> personas con bienes sometidos a ese proceso, o vinculadas a ellas.</span></div>
        <div class="nm" data-s="4"><i>4</i><span><b>Fundaciones o asociaciones civiles apolíticas.</b> Excepción: aportes académicos para formación, reportados al TSE en 30 días.</span></div>
      </div>
      <div class="mt2">${note('Quién protege al partido', 'Antes de aceptar aportes grandes, consulte el listado de exclusión de financistas ' + law('Reglamento art. 10'), 'warn', 5)}</div>`,
    notes: `<p>Estas cuatro categorías cierran la puerta a injerencia extranjera, a corrupción y lavado, y al dinero de origen ilícito. La prohibición cubre contribuciones «de cualquier índole».</p><p>El Reglamento (art. 10) crea el listado de exclusión de financistas; el TSE debe coordinar con las instituciones que tienen esa información.</p>` });

  add({ sec: 2, t: 'Otras prohibiciones y consecuencias', m: 1.5,
    html: `${head('Financiamiento prohibido', 'Otras reglas que no se negocian')}
      ${tbl(null, [
        ['Aportes anónimos', 'Terminantemente prohibidos ' + law('Reglamento art. 23')],
        ['Estado y municipalidades', 'Ningún aporte fuera de lo que la ley establece ' + law('art. 21')],
        ['Donar al candidato', 'Todo se canaliza por la organización política ' + law('art. 21 Ter b')],
        ['Propaganda de una empresa', 'Puede costar la cancelación de su personalidad jurídica ' + law('art. 21 Ter i')],
        ['Más del 10 %', 'Ningún aportante o unidad de vinculación sobre el límite ' + law('art. 21 Ter g')]
      ], { s0: 1 })}
      <div class="mt">${note('Consecuencia', 'Quien aporta contraviniendo la ley también queda sujeto al Código Penal ' + law('art. 88'), 'warn', 6)}</div>`,
    notes: `<p>Aporte anónimo es todo el que no refleje su origen o incumpla los requisitos. Si la Unidad no encuentra soporte, pide información y, si no se comprueba el origen, lo reporta como hallazgo.</p>` });

  add({ sec: 2, t: 'Techo de gastos de campaña', m: 2, cls: 'vc', steps: 3,
    html: `<div class="kick a">Techos y límites · 1 ${law('art. 21 Ter e')}</div><h2 class="split">Techo de gastos de campaña</h2>
      <div class="cols c2" style="gap:60px;align-items:center">
        <div><p class="lead a">Cada organización puede gastar, como máximo, el equivalente en quetzales a <b>US$0.50 por ciudadano empadronado</b> al 31 de diciembre del año previo a las elecciones.</p>
          <p class="small a">En coalición, el límite total no puede superar el monto individual. El TSE puede fijarlo más bajo.</p></div>
        <div class="card hot" style="padding:40px 44px">
          <div class="cap">Empadronados (supuesto)</div><div class="hero s num"><span class="cnt" data-to="10200000">0</span></div>
          <div class="cap mt">× US$0.50 × Q7.62 =</div>
          <div class="hero m num" style="color:var(--gold)"><span class="cnt" data-pre="Q " data-to="38862000">Q 0</span></div></div></div>
      <div class="cols c3 mt" style="gap:26px">
        <div class="card" data-s="1"><h4>Por aportante (10 %)</h4><p class="num" style="font-size:46px;color:var(--gold2)"><span class="cnt" data-pre="Q " data-to="3886200">0</span></p></div>
        <div class="card blue" data-s="2"><h4>Comité cívico (US$0.10)</h4><p class="num" style="font-size:46px;color:var(--blue)"><span class="cnt" data-pre="Q " data-to="19050">0</span></p><p class="small">25,000 empadronados</p></div>
        <div class="card" data-s="3"><h4>Referencia en prensa</h4><p class="num" style="font-size:40px">≈ Q38.9 millones en 2027</p><p class="small">Q34.9 millones en 2023</p></div>
      </div>`,
    notes: `<p>Calculadora: 10,200,000 empadronados × US$0.50 = US$5,100,000 × 7.62 = <b>Q38,862,000</b>. Los datos son supuestos; el TSE publica el padrón y fija el techo oficial.</p><p>El 10 % por aportante = Q3,886,200. Para un comité cívico de un municipio con 25,000 empadronados: 25,000 × US$0.10 × 7.62 = Q19,050.</p>` });

  add({ sec: 2, t: 'Qué cuenta como gasto de campaña', m: 1.2,
    html: `${head('Techos y límites · 1', 'Qué cuenta contra el techo ' + law('Reglamento art. 3 i'))}
      <div class="cols c2" style="gap:30px">${ul([
        '<b>Propaganda electoral:</b> impresión, grabación o edición de material',
        '<b>Servicios</b> contratados o pagados antes, durante y después del proceso',
        '<b>Encuestas</b> contratadas por la organización'], 1)}
        ${ul([
        '<b>Alquileres temporales</b> de vehículos, bienes o sedes para actos',
        '<b>Viajes, hospedaje y alimentación</b> de dirigentes, asesores, delegados y candidatos',
        '<b>Aportes en especie</b> justipreciados'], 4)}</div>
      <div class="mt2">${note('Controle el acumulado', 'La cuota pública usada para campaña también cuenta como gasto del límite ' + law('art. 21 Bis d'), '', 7)}</div>`,
    notes: `<p>Todo desembolso para propaganda o campaña cuenta, aunque se pague antes o después del proceso. Los aportes en especie justipreciados cuentan una vez al recibirse y ejecutarse.</p><p>Recomendación práctica: llevar un acumulado mensual del gasto de campaña contra el techo.</p>` });

  /* límite por aportante */
  const LIM = 3886200;
  const LIMS = [
    { who: 'Un donante, Q400,000', total: 400000, flags: ['Dentro del límite del 10 %', 'Libros del financista: obligatorios (≥ Q30,000)', 'Declaración jurada notarial: obligatoria (> Q50,000)'] },
    { who: 'Una empresa Q400,000 + vinculadas Q3,600,000', total: 4000000, flags: ['EXCEDE el 10 %: no debe aceptarse', 'Se suman las personas vinculadas', 'Es una sola unidad de vinculación'] },
    { who: 'Tres aportes de Q20,000 en el año', total: 60000, flags: ['Dentro del límite del 10 %', 'Aportes múltiples = una sola transacción', 'Supera Q50,000: declaración jurada y libros'] }
  ];
  add({ sec: 2, t: 'Límite del 10 % por aportante', m: 2.5, steps: 2, cls: 'hs',
    html: `${head('Techos y límites · 2 ' + law('art. 21 Ter g'), '¿Puedo aceptar este <em>aporte</em>?')}
      <p class="lead a">Las personas relacionadas o vinculadas, o una sola <b>unidad de vinculación</b>, no pueden aportar en conjunto más del <b>10 %</b> del techo (Q3,886,200 en el ejemplo).</p>
      <div class="card hot a" style="padding:34px 44px">
        <div class="cap" data-k="who">&nbsp;</div>
        <div class="cols c2" style="gap:40px;align-items:center;margin-top:10px"><div class="hero m num" data-k="tot">Q 0</div><div class="num" style="font-size:56px;font-family:var(--display);color:var(--ink)" data-k="pct">0 %</div></div>
        <div class="meter mt"><i data-k="bar"></i><b></b></div>
        <div class="small right" style="margin-top:6px">La marca blanca es el límite del 10 %</div>
      </div>
      <div class="mt"><span class="verdict ok" data-k="v1"></span> <span class="small" data-k="v2" style="margin-left:18px"></span> <span class="small" data-k="v3" style="margin-left:18px"></span></div>`,
    hook(el, step, c) {
      const s = LIMS[Math.min(step, 2)], pct = s.total / LIM * 100, over = s.total > LIM;
      q(el, '[data-k=who]').textContent = s.who;
      c.countTo(q(el, '[data-k=tot]'), s.total, { pre: 'Q ', instant: c.instant });
      c.countTo(q(el, '[data-k=pct]'), pct, { suf: ' % del límite', dec: 1, instant: c.instant });
      const bar = q(el, '[data-k=bar]'); bar.style.width = Math.min(120, pct) / 120 * 100 + '%'; bar.classList.toggle('over', over);
      const v1 = q(el, '[data-k=v1]'); v1.className = 'verdict ' + (over ? 'no' : 'ok'); v1.textContent = s.flags[0];
      q(el, '[data-k=v2]').textContent = '· ' + s.flags[1]; q(el, '[data-k=v3]').textContent = '· ' + s.flags[2];
    },
    notes: `<p><b>Paso 0:</b> un donante de Q400,000 está dentro del 10 % (usa 10.3 % del límite). Como supera Q30,000 debe habilitar libros y como supera Q50,000, declaración jurada notarial.</p><p><b>Paso 1:</b> una empresa de Q400,000 con vinculadas que aportan Q3,600,000: la unidad suma Q4,000,000 y <b>excede</b> el límite.</p><p><b>Paso 2:</b> tres aportes de Q20,000 de una misma persona en el período se consideran una sola transacción de Q60,000: dentro del límite, pero activa declaración jurada y libros.</p>` });

  add({ sec: 2, t: 'Umbrales que activan obligaciones', m: 1.5, cls: 'vc',
    html: `<div class="kick a">Techos y límites · 3</div><h2 class="split">Tres números que activan obligaciones</h2>
      <div class="n3 mt2">
        <div class="it" data-s="1"><div class="hero"><span class="cnt" data-pre="Q " data-to="30000">0</span></div><p>por período fiscal: el <b>financista habilita sus libros</b> de contribuciones.<br>${law('Reglamento art. 20')}</p></div>
        <div class="it" data-s="2"><div class="hero"><span class="cnt" data-pre="> Q " data-to="50000">0</span></div><p><b>Declaración jurada</b> en acta notarial y pago por banco.<br>${law('Reglamento art. 22')}</p></div>
        <div class="it" data-s="3"><div class="hero"><span class="cnt" data-to="10" data-suf=" %">0</span></div><p>del techo de campaña: <b>tope por unidad de vinculación</b>.<br>${law('art. 21 Ter g')}</p></div>
      </div>
      <p class="small mt2" data-s="4">Los aportes múltiples de una misma persona en el período se consideran una sola transacción.</p>`,
    notes: `<p>Q30,000 y Q50,000 son umbrales por período fiscal, no por aporte. Los aportes múltiples se acumulan.</p><p>Los aportes en dinero superiores al umbral de declaración jurada solo pueden hacerse por cheque, transferencia o medio del sistema bancario.</p>` });

  add({ sec: 2, t: 'Ejemplo formal: financiamiento de Futuro Retalteco', m: 2.5, cls: 'hs',
    html: `${head('Ejemplo formal estructurado', 'Futuro Retalteco paso a paso')}
      ${tbl(['Paso', 'Cálculo', 'Resultado'], [
        ['1. Derecho', 'Una diputación (excepción al 5 %)', 'Sí'],
        ['2. Total del período', '150,000 × US$2', 'US$300,000'],
        ['3. Cuota anual', 'US$300,000 ÷ 4', 'US$75,000'],
        ['4. En quetzales', 'US$75,000 × 7.62', 'Q571,500'],
        ['5. Formación 30 %', 'Q571,500 × 0.30', 'Q171,450'],
        ['6. Sede nacional 20 %', 'Q571,500 × 0.20', 'Q114,300'],
        ['7. Territorio 50 %', 'Q571,500 × 0.50', 'Q285,750'],
        ['&nbsp;&nbsp;↳ Departamentos 1/3', 'Q285,750 ÷ 3', 'Q95,250'],
        ['&nbsp;&nbsp;↳ Municipios 2/3', 'Q285,750 × 2 ÷ 3', 'Q190,500']
      ], { cls: 'sm', r: [2], s0: 1 })}`,
    notes: `<p>Recorra los nueve pasos. Es el cálculo que el contador debe poder defender ante la Unidad Especializada. Cifras ilustrativas con tipo de cambio supuesto de Q7.62.</p><p>Estos montos son los que se registran luego en el Diario del caso práctico.</p>` });

  add({ sec: 2, t: 'Techo 2027 y conclusión', m: 1.5,
    html: `${head('Ejemplo formal estructurado', 'Y el techo para 2027')}
      ${tbl(null, [
        ['Techo (10.2 millones × US$0.50 × 7.62)', '<b>Q38,862,000</b>'],
        ['Máximo por aportante o unidad (10 %)', '<b>Q3,886,200</b>'],
        ['Si la cuota 2027 se usa toda en campaña', '<b>Q571,500</b> cuentan contra el techo']
      ], { r: [1], s0: 1 })}
      <div class="mt2">${note('Para llevarse', 'Tres controles permanentes: <b>derecho</b> al aporte público, <b>distribución</b> 30/20/50 y <b>acumulado de campaña</b> contra el techo.', 'ok', 4)}</div>`,
    notes: `<p>Cierre de la sección III. Abra una ronda de preguntas de 3 a 5 minutos sobre financiamiento antes de pasar a cuentas bancarias y libros.</p>` });
})();
