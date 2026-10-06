/* Contenido, parte 1: ayudas, apertura, secciones I y II */
(function () {
  const ROM = ['I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX'];
  window.SECTIONS = [
    { k: 'I', name: 'Antecedentes' }, { k: 'II', name: 'Marco legal' }, { k: 'III', name: 'Financiamiento' },
    { k: 'IV', name: 'Cuentas bancarias' }, { k: 'V', name: 'Libros' }, { k: 'VI', name: 'Plan de cuentas' },
    { k: 'VII', name: 'Estados financieros' }, { k: 'VIII', name: 'Caso práctico' }, { k: 'IX', name: 'Obligaciones y SAT' }
  ];
  const S = window.SLIDES = [];
  const H = window.H = {
    head: (k, t, l) => `<div class="kick a">${k}</div><h2 class="split">${t}</h2>${l ? `<p class="lead a">${l}</p>` : ''}`,
    law: t => `<span class="law">${t}</span>`,
    vf: t => `<span class="verify">${t || 'verificar'}</span>`,
    ul: (items, s0, cls) => `<ul class="gl ${cls || ''}">` + items.map((x, i) => `<li ${s0 == null ? 'class="a"' : `data-s="${s0 + i}"`}>${x}</li>`).join('') + '</ul>',
    card: (h, p, o) => { o = o || {}; return `<div class="card ${o.cls || ''} ${o.s == null ? 'a' : ''}" ${o.s != null ? `data-s="${o.s}"` : ''}><h4>${h}</h4><p>${p}</p></div>`; },
    note: (t, b, cls, s) => `<div class="note ${cls || ''} ${s == null ? 'a' : ''}" ${s != null ? `data-s="${s}"` : ''}><b>${t}</b>${b}</div>`,
    tbl: (hd, rows, o) => {
      o = o || {};
      const r = o.r || [];
      return `<table class="t ${o.cls || ''}">` + (hd ? `<thead><tr>${hd.map((h, i) => `<th class="${r.includes(i) ? 'r' : ''}">${h}</th>`).join('')}</tr></thead>` : '') +
        '<tbody>' + rows.map((row, k) => {
          const cells = row.c || row;
          return `<tr ${o.s0 != null ? `data-s="${o.s0 + k}"` : ''} class="${row.tot ? 'tot' : ''}">` + cells.map((c, i) => `<td class="${r.includes(i) ? 'r' : ''}">${c}</td>`).join('') + '</tr>';
        }).join('') + '</tbody></table>';
    },
    divider: (k, title, sub, notes) => S.push({
      sec: k, t: 'Sección ' + ROM[k] + ' · ' + title, m: 0.3, cls: 'vc', nochrome: true,
      html: `<div class="divider"><div class="rn a-z">${ROM[k]}</div><div><div class="kick a">Sección ${ROM[k]} de IX</div><h2 class="split">${title}</h2><p class="lead a">${sub}</p><div class="secs a">${window.SECTIONS.map((s, i) => `<i class="${i === k ? 'on' : ''}">${s.name}</i>`).join('')}</div></div></div>`,
      notes: notes || ''
    })
  };
  const { head, law, vf, ul, card, note, tbl, divider } = H;
  const add = o => S.push(o);

  /* 0 · portada */
  add({ sec: -1, t: 'Portada', m: 1, cls: 'cover', nochrome: true,
    html: `<img class="logo a-z" src="assets/logo-monterroso-blanco.png" alt="Firma de Auditoría Monterroso, Auditores y Consultores"><div class="rule"></div>
      <div class="kick a" style="--d:600ms">Guía completa · Guatemala · Octubre de 2026</div>
      <h2 class="split">Contabilidad de un <em>Partido Político</em></h2>
      <p class="lead a" style="--d:900ms">Del marco legal a los estados financieros: cómo se registra, se controla y se rinde cuentas ante el Tribunal Supremo Electoral y la SAT.</p>`,
    notes: `<p>Dé la bienvenida y presente la <b>Firma de Auditoría Monterroso, Auditores y Consultores</b>.</p><p>Objetivo del taller: que al terminar, cada asistente pueda explicar de dónde sale el dinero de un partido, cuánto puede recibir y gastar, qué libros y cuentas debe llevar y qué informes presenta al TSE y a la SAT.</p><p><b>Aviso:</b> material educativo con textos oficiales a octubre de 2026; no sustituye asesoría legal.</p>` });

  /* 1 · por qué importa */
  add({ sec: -1, t: 'Por qué importa', m: 2, cls: 'vc',
    html: `<div class="kick a">Para empezar</div><h2 class="split">Tres preguntas que la contabilidad debe responder</h2>
      <div class="cols c3 mt2">
        <div class="card" data-s="1"><h4>1 · Origen</h4><p class="q" style="font-size:54px;color:var(--ink)">¿De dónde viene cada quetzal?</p></div>
        <div class="card" data-s="2"><h4>2 · Límite</h4><p class="q" style="font-size:54px;color:var(--ink)">¿Cuánto se recibió y cuánto se podía?</p></div>
        <div class="card" data-s="3"><h4>3 · Destino</h4><p class="q" style="font-size:54px;color:var(--ink)">¿En qué se gastó y quién responde?</p></div>
      </div>
      <p class="lead a mt2" style="--d:600ms">Un partido es una institución de derecho público, pero maneja dinero público y privado. Su contabilidad es la prueba de que cada quetzal tiene origen conocido, límite respetado y destino justificado.</p>`,
    notes: `<p>Plantee las tres preguntas una por una y pida a la sala que anticipe respuestas.</p><ul><li><b>Origen:</b> recibos, cuentas bancarias, libros de contribuciones.</li><li><b>Límite:</b> techo de campaña y tope del 10 % por aportante.</li><li><b>Destino:</b> facturas a nombre del partido, distribución 30/20/50, informes al TSE.</li></ul><p>Idea fuerza: la contabilidad del partido no es solo técnica; es la prueba de que cada quetzal tiene origen conocido, límite respetado y destino justificado.</p>` });

  /* 2 · agenda */
  add({ sec: -1, t: 'Agenda del taller', m: 1.5,
    html: `${head('Ruta', 'Nueve estaciones, un solo hilo')}
      <div class="cols c3" style="gap:22px;margin-top:10px">${window.SECTIONS.map((s, i) => `<div class="card a" style="padding:22px 28px"><div class="hero s" style="font-size:72px">${s.k}</div><p style="font-size:34px;color:var(--ink);margin-top:4px">${s.name}</p></div>`).join('')}</div>`,
    notes: `<p>Recorra la agenda: historia y marco legal (I–II), financiamiento y límites (III), cuentas y libros (IV–V), plan de cuentas y estados (VI–VII), caso práctico completo de <b>Futuro Retalteco</b> (VIII) y obligaciones, SAT y lista de cumplimiento (IX).</p><p>Anuncie que hay calculadoras en vivo (financiamiento público, techo de campaña, límite del 10 %) y que el caso práctico se arma partida por partida.</p><p>Duración total prevista: 90 minutos con espacio para preguntas al final de las secciones III, VI y VIII.</p>` });

  /* ===== SECCIÓN I ===== */
  divider(0, 'Antecedentes', 'Cómo llegamos hasta aquí: la regulación se construyó por capas, casi siempre después de una crisis de confianza.',
    `<p>Explique que el control del dinero político en Guatemala no nació de golpe: se construyó con reformas sucesivas. Entender la historia ayuda a comprender por qué hoy hay tantas reglas.</p>`);

  add({ sec: 0, t: 'Línea de tiempo 1985–2015', m: 1.5,
    html: `${head('Sección I · Antecedentes', 'De 1985 a 2015')}
      <div class="tl">
        <div class="ev key" data-s="1"><div class="yr">1985</div><div class="tx"><b>Ley Electoral y de Partidos Políticos, Decreto 1-85.</b> Base legal que sigue vigente, con muchas reformas.</div></div>
        <div class="ev" data-s="2"><div class="yr">1987-89</div><div class="tx">Decretos 74-87 y 10-89: ajustan los derechos de los partidos en el artículo 20.</div></div>
        <div class="ev key" data-s="3"><div class="yr">2004</div><div class="tx"><b>Decreto 10-04.</b> Reforma varios artículos, entre ellos el 21: control y fiscalización del financiamiento.</div></div>
        <div class="ev" data-s="4"><div class="yr">2006</div><div class="tx"><b>Decreto 35-2006.</b> Vuelve a reformar el artículo 21 y otros relacionados con el financiamiento.</div></div>
        <div class="ev" data-s="5"><div class="yr">2015</div><div class="tx">La CICIG publica <i>El financiamiento de la política en Guatemala</i>: documenta riesgos de dinero opaco e ilícito en campañas.</div></div>
      </div>`,
    notes: `<p>La LEPP fue aprobada por la Asamblea Nacional Constituyente el 3 de diciembre de 1985.</p><ul><li>1987 y 1989: reformas (Decretos 74-87 y 10-89) a derechos de los partidos.</li><li>2004 (Decreto 10-04) y 2006 (Decreto 35-2006): reforman el artículo 21 y relacionados.</li><li>2015: el informe de la CICIG evidencia los riesgos del financiamiento opaco y empuja la reforma de 2016.</li></ul>` });

  add({ sec: 0, t: 'Línea de tiempo 2016–2027', m: 1.5,
    html: `${head('Sección I · Antecedentes', 'De 2016 a las elecciones de 2027')}
      <div class="tl sm">
        <div class="ev key" data-s="1"><div class="yr">2016</div><div class="tx"><b>Decreto 26-2016</b> (25 de mayo): la reforma más profunda al financiamiento. Crea la Unidad Especializada de Control y Fiscalización.</div></div>
        <div class="ev" data-s="2"><div class="yr">2016</div><div class="tx">El TSE emite el <b>Acuerdo 306-2016</b>, primer reglamento de fiscalización. El Instructivo de Rendición de Cuentas se elabora con base en él.</div></div>
        <div class="ev key" data-s="3"><div class="yr">2023</div><div class="tx"><b>Acuerdo 602-2022</b>, emitido el 5 de enero de 2023, deroga el 306-2016. Ese día también se emite el Acuerdo 22-2023. El módulo <b>INFOCAM</b> (Cuentas Claras) pasa a ser obligatorio.</div></div>
        <div class="ev key" data-s="4"><div class="yr">2026</div><div class="tx"><b>26 de febrero:</b> Acuerdos 58, 59, 60 y 61-2026. El <b>60-2026</b> reforma el reglamento de fiscalización. Luego, coordinación con Contraloría, SAT y Superintendencias.</div></div>
        <div class="ev" data-s="5"><div class="yr">2027</div><div class="tx">Elecciones generales: primer ciclo completo con el reglamento reformado en 2026.</div></div>
      </div>
      ${note('La lección', 'Cada reforma agregó una pieza: primero el control, luego los límites, después la tecnología. Hoy la contabilidad del partido es el centro del sistema.', '', 6)}`,
    notes: `<p>El Decreto 26-2016 fue el gran cambio. Después vino la reglamentación del TSE.</p><ul><li>El <b>Acuerdo 602-2022</b> se emitió el 5 de enero de 2023 y derogó al 306-2016 (art. 33).</li><li>El 26 de febrero de 2026 la Octava Magistratura (2026-2032) aprobó los Acuerdos 58 (reglamento de la LEPP), 59 (voto en el extranjero), 60 (<b>fiscalización de finanzas</b>) y 61 (medios y estudios de opinión).</li><li>El TSE coordina intercambio de información con la Contraloría General de Cuentas, la SAT y las Superintendencias.</li></ul>` });

  add({ sec: 0, t: 'Qué creó el Decreto 26-2016', m: 2,
    html: `${head('Sección I · Antecedentes', 'Seis piezas que creó el Decreto 26-2016')}
      <div class="cols c3" style="gap:26px">
        ${card('Financiamiento público', 'US$2 por voto, con distribución obligatoria ' + law('art. 21 Bis'), { s: 1 })}
        ${card('Techo de campaña', 'US$0.50 por ciudadano empadronado ' + law('art. 21 Ter e'), { s: 2 })}
        ${card('Límite por aportante', '10 % del techo por persona o unidad de vinculación ' + law('art. 21 Ter g'), { s: 3 })}
        ${card('Listas de prohibición', 'Extranjeros, condenados, extinción de dominio ' + law('art. 21 Ter a'), { s: 4, cls: 'red' })}
        ${card('Libros de contribuciones', 'Efectivo, especie y formación política ' + law('art. 21 Ter c'), { s: 5 })}
        ${card('Unidad Especializada', 'Control y fiscalización, creada dentro de seis meses ' + law('art. 66 transitorio'), { s: 6, cls: 'green' })}
      </div>`,
    notes: `<p>Estas seis piezas son el esqueleto del sistema actual. Haga una pausa en cada tarjeta: las retomaremos en las secciones III, V y IX.</p><p>El artículo 66 transitorio del Decreto 26-2016 ordenó crear la Unidad Especializada de control y fiscalización de las finanzas de los partidos y la de medios y estudios de opinión en seis meses.</p>` });

  /* ===== SECCIÓN II ===== */
  divider(1, 'Marco legal y entidad rectora', 'Qué normas rigen la contabilidad de un partido, en qué orden mandan y quién vigila su cumplimiento.',
    `<p>Esta sección responde dos preguntas: ¿qué normas aplican? y ¿quién fiscaliza?</p>`);

  add({ sec: 1, t: 'Las normas, de mayor a menor', m: 1.5,
    html: `${head('Sección II · Marco legal', 'Las normas, de mayor a menor')}
      <div class="pyr mt">
        <div class="lv a" style="width:42%;background:#e9c97a"><b>Constitución Política</b>Libertad de organización política</div>
        <div class="lv" data-s="1" style="width:58%;background:#edd391"><b>LEPP · Decreto 1-85</b>arts. 18, 19 Bis, 21 a 21 Quinquies, 22, 88</div>
        <div class="lv" data-s="2" style="width:72%;background:#f0dba7"><b>Decreto 26-2016</b>La reforma que creó el sistema de financiamiento</div>
        <div class="lv" data-s="3" style="width:86%;background:#f3e3bf"><b>Reglamento de Control y Fiscalización</b>Acuerdo 602-2022, reformado por 22-2023 y 60-2026</div>
        <div class="lv" data-s="4" style="width:100%;background:#f6ecd4"><b>Instructivo de Rendición de Cuentas</b>Nomenclatura, estados, formatos GR-PRI, INF-FINPU, INFOCAM</div>
      </div>
      ${note('En paralelo', 'Las leyes fiscales: Código de Comercio, Ley de Actualización Tributaria y Ley del IVA. Cumplir el Reglamento no releva al partido de ellas ' + law('art. 29'), '', 5)}`,
    notes: `<p>Cuando dos normas parecen chocar, manda la de mayor jerarquía. Construya la pirámide de arriba hacia abajo.</p><p>La contabilidad se lleva con las Normas Internacionales de Contabilidad y de Información Financiera adoptadas en Guatemala, según el Instructivo.</p><p>El artículo 29 del Reglamento es clave para el contador: las leyes fiscales siguen aplicando.</p>` });

  add({ sec: 1, t: 'Qué regula cada norma', m: 2,
    html: `${head('Sección II · Marco legal', 'Qué regula cada norma')}
      ${tbl(['Norma', 'Qué aporta a la contabilidad'], [
        ['<b>LEPP art. 21</b>', 'El TSE controla fondos públicos y privados. Cuenta bancaria separada por origen. Acceso permanente a los libros.'],
        ['<b>LEPP art. 21 Bis</b>', 'Financiamiento público: US$2 por voto. Distribución 30 / 20 / 50.'],
        ['<b>LEPP art. 21 Ter</b>', 'Prohibiciones, recibos SAT, libros de contribuciones, techo, límite del 10 %, sanciones.'],
        ['<b>LEPP 21 Quáter y Quinquies</b>', 'Definiciones (financista, unidad de vinculación) y publicidad 30 días antes de la elección.'],
        ['<b>LEPP art. 88</b>', 'Sanciones: de amonestación a cancelación del partido.'],
        ['<b>Reglamento (Ac. 602-2022)</b>', 'Contador, informes, cuentas, recibos, declaración jurada, comprobación de egresos.'],
        ['<b>Ac. 60-2026</b>', 'Reforma los artículos 11, 13, 15, 16, 18, 19 y 20 del Reglamento.'],
        ['<b>Instructivo</b>', 'Estados financieros, nomenclatura contable, formatos e informes.']
      ], { cls: 'sm', s0: 1 })}`,
    notes: `<p>Use esta tabla como mapa de referencia. El contador debe tener a mano estos artículos.</p><p>Resalte el Acuerdo 60-2026: cambia justo los artículos que más usa el contador (11 contabilidad, 13 informes, 15 rectificación, 16 auditoría, 18-19 cuentas, 20 libros de financistas).</p>` });

  add({ sec: 1, t: 'Corrección: el Acuerdo 306-2016', m: 1.5, cls: 'vc',
    html: `<div class="kick a">Una corrección que conviene hacer</div>
      <div class="cols c2" style="align-items:center;gap:60px">
        <div class="center"><div class="bigcode a-z cross" data-go="1">Acuerdo 306-2016</div>
          <div class="mt2" data-s="1"><span class="stamp">DEROGADO</span></div></div>
        <div data-s="2"><div class="cap">Vigente</div><div class="bigcode gold" style="font-size:150px;color:var(--gold2)">Acuerdo 602-2022</div>
          <p class="lead" style="margin-top:14px">Reformado por los Acuerdos <b>22-2023</b> y <b>60-2026</b>. El art. 33 deroga al 306-2016.</p></div>
      </div>
      <div class="mt2">${note('Para recordar', 'El Instructivo publicado todavía cita el 306-2016. Úselo para formatos y nomenclatura, pero aplique los artículos y plazos del reglamento vigente. El Acuerdo 58-2026 reforma el reglamento de la LEPP, no el de fiscalización.', 'warn', 3)}</div>`,
    notes: `<p>Aclare un error frecuente: muchos documentos todavía hablan del Acuerdo 306-2016. <b>Ya no está vigente</b>.</p><p>Diferencia clave en plazos: el Reglamento vigente exige conservar registros contables por <b>cinco años</b> (art. 11); el Instructivo, redactado antes, menciona quince. Aplique cinco años.</p>` });

  add({ sec: 1, t: 'La Unidad Especializada (UECFFPP)', m: 2,
    html: `<div class="cols c12" style="gap:60px;align-items:start">
      <div>${head('Sección II · Entidad rectora', 'La <em>Unidad</em> Especializada')}
        <p class="a">Dependencia del TSE responsable del control y fiscalización de las finanzas de las organizaciones políticas ${law('Reglamento art. 2')}.</p>
        <p class="small a">Por mandato del Decreto 26-2016 (art. 66), se creó dentro de seis meses de su vigencia.</p></div>
      <div class="stack" style="padding-top:60px">
        ${card('Fiscalizar', 'En cualquier momento, recursos públicos y privados.', { s: 1 })}
        ${card('Auditar', 'Auditorías ordinarias y extraordinarias y revisiones especiales.', { s: 2 })}
        ${card('Visitar sedes', 'Revisiones en órganos departamentales y municipales.', { s: 3 })}
        ${card('Pedir información', 'A financistas y, bajo reserva, a Contraloría, SAT y Superintendencias.', { s: 4, cls: 'green' })}
      </div></div>`,
    notes: `<p>Sigla: UECFFPP, Unidad Especializada de Control y Fiscalización de las Finanzas de los Partidos Políticos.</p><p>El artículo 21 de la LEPP obliga a la Contraloría General de Cuentas, la SAT, la Superintendencia de Bancos y la de Telecomunicaciones, además de funcionarios públicos, a entregar la información que el TSE les pida, bajo reserva de confidencialidad.</p><p>El jefe de la Unidad se nombra por concurso público de oposición y no puede estar afiliado a ningún partido (art. 5 y 6 del Reglamento).</p>` });

  add({ sec: 1, t: 'Cómo es una fiscalización', m: 1.5,
    html: `${head('Sección II · Entidad rectora', 'Cómo avanza una fiscalización')}
      <div class="flow mt2" style="height:260px">
        <div class="st a"><b>1</b>Informe preliminar</div>
        <div class="st" data-s="1"><b>2</b>20 días para aclarar (+10)</div>
        <div class="st" data-s="2"><b>3</b>Informe final al Pleno</div>
        <div class="st" data-s="3"><b>4</b>Audiencia de 15 días</div>
        <div class="st" data-s="4"><b>5</b>Resolución</div>
      </div>
      <div class="mt2">${note('Lo que debe saber el contador', 'Antes de una sanción hay oportunidad de aclarar y de defenderse. Pero los plazos corren: los respaldos ordenados son la mejor defensa. Las sanciones se gradúan con proporcionalidad y razonabilidad ' + law('Reglamento arts. 15 y 16'), '', 5)}</div>`,
    notes: `<p>Etapas: informe preliminar; veinte días (ampliables diez, por única vez) para evacuar y aportar documentos; informe final al Pleno de Magistrados; audiencia de quince días (prorrogable) otorgada por el Registro de Ciudadanos; resolución.</p><p>Los informes GR-PRI, INF-FINPU e INFOCAM pueden rectificarse en 30 días tras su vencimiento, pero no después de iniciada una auditoría.</p>` });
})();
