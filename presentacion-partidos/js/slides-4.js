/* Contenido, parte 4: secciones VIII y IX, glosario, fuentes y cierre */
(function () {
  const S = window.SLIDES, { head, law, vf, ul, card, note, tbl, divider } = window.H;
  const add = o => S.push(o);
  const f0 = n => n.toLocaleString('en-US', { maximumFractionDigits: 0 });

  /* ===== datos del caso (una sola fuente) ===== */
  const ACC = {
    '1-1-2-201': 'Banco financiamiento público', '1-1-2-202': 'Banco financiamiento privado',
    '1-1-2-203': 'Bancos cuentas para departamentos', '1-1-2-204': 'Bancos cuentas para municipios',
    '1-2-1-104': 'Mobiliario y equipo', '1-2-1-110': 'Depreciación acumulada de mobiliario y equipo', '3-1-1': 'Patrimonio partidario',
    '4-1-1-101': 'Cuota política 2026 (financiamiento público)', '4-2-1-101': 'Aportaciones de simpatizantes', '4-2-1-102-01': 'Afiliados: cuotas ordinarias',
    '4-3-1-105': 'Autofinanciamiento: desayunos, almuerzos y cenas', '4-5-2-204': 'Ingreso no dinerario: material de información',
    '5-1-1-101': 'Sueldos, salarios y honorarios', '5-1-1-102': 'Arrendamiento de sedes centrales', '5-1-1-105': 'Agua, luz y teléfono', '5-1-1-108': 'Depreciaciones',
    '5-1-2-202': 'Gastos de organización departamentales', '5-1-2-203': 'Gastos de organización municipales', '5-1-3-305': 'Campañas de afiliación: alimentación y hospedaje',
    '5-1-5-501': 'Capacitación: gastos de organización', '5-1-5-502': 'Capacitación: material didáctico', '5-1-5-503': 'Capacitación: capacitadores', '5-1-5-504': 'Capacitación: alimentación',
    '5-3-2-204': 'Egreso no dinerario: material de información'
  };
  const PART = [
    { n: 1, f: '01-ene', t: 'Apertura del ejercicio', l: [['1-1-2-202', 50000, 0], ['1-2-1-104', 30000, 0], ['3-1-1', 0, 80000]], g: 'Saldos iniciales certificados por contador general y secretario de finanzas.' },
    { n: 2, f: '15-feb', t: 'Cuotas de afiliados', l: [['1-1-2-202', 24000, 0], ['4-2-1-102-01', 0, 24000]], g: 'Un recibo SAT por cada afiliado.' },
    { n: 3, f: '10-mar', t: 'Donación en efectivo', l: [['1-1-2-202', 15000, 0], ['4-2-1-101', 0, 15000]], g: 'Simpatizante persona individual; anotada en el libro de contribuciones en efectivo.' },
    { n: 4, f: '30-abr', t: 'Alquiler de sede central', l: [['5-1-1-102', 12000, 0], ['1-1-2-202', 0, 12000]], g: 'Factura a nombre del partido; pago por transferencia.' },
    { n: 5, f: '18-jun', t: 'Costo de la cena', l: [['5-1-3-305', 6000, 0], ['1-1-2-202', 0, 6000]], g: 'Primero el egreso con recursos propios; luego puede haber autofinanciamiento.' },
    { n: 6, f: '18-jun', t: 'Ingreso por la cena', l: [['1-1-2-202', 18000, 0], ['4-3-1-105', 0, 18000]], g: 'Recibos por cada participante: 60 cubiertos × Q300.' },
    { n: 7, f: '03-jul', t: 'Cuota anual de financiamiento público', l: [['1-1-2-201', 571500, 0], ['4-1-1-101', 0, 571500]], g: '150,000 votos × US$2 ÷ 4 años × Q7.62.' },
    { n: 8, f: '10-jul', t: 'Entrega del 50 % a departamentos y municipios', l: [['1-1-2-203', 95250, 0], ['1-1-2-204', 190500, 0], ['1-1-2-201', 0, 285750]], g: '1/3 a departamentos y 2/3 a municipios, según acta certificada del CEN.' },
    { n: 9, f: '31-ago', t: 'Formación y capacitación (30 %)', l: [['5-1-5-501', 40000, 0], ['5-1-5-502', 30000, 0], ['5-1-5-503', 60000, 0], ['5-1-5-504', 41450, 0], ['1-1-2-201', 0, 171450]], g: 'Talleres para afiliados, cuadros y fiscales; todo con factura.' },
    { n: 10, f: '30-sep', t: 'Sede nacional (20 %)', l: [['5-1-1-101', 60000, 0], ['5-1-1-102', 40000, 0], ['5-1-1-105', 14300, 0], ['1-1-2-201', 0, 114300]], g: 'Planilla (IGSS), alquiler y servicios de la sede nacional.' },
    { n: 11, f: '31-oct', t: 'Liquidación de fondos del interior', l: [['5-1-2-202', 95250, 0], ['5-1-2-203', 190500, 0], ['1-1-2-203', 0, 95250], ['1-1-2-204', 0, 190500]], g: 'Informes bajo juramento con facturas; se cancela lo entregado en la partida 8.' },
    { n: 12, f: '15-nov', t: 'Donación en especie (control)', l: [['5-3-2-204', 5000, 0], ['4-5-2-204', 0, 5000]], g: 'Una imprenta dona material informativo; cuentas de control.' },
    { n: 13, f: '31-dic', t: 'Depreciación del mobiliario', l: [['5-1-1-108', 6000, 0], ['1-2-1-110', 0, 6000]], g: '20 % anual sobre Q30,000 (LAT art. 19).' }
  ];
  const bal = {};
  PART.forEach(p => p.l.forEach(([c, d, h]) => { const a = bal[c] || (bal[c] = { d: 0, h: 0, mv: [] }); a.d += d; a.h += h; a.mv.push({ n: p.n, d, h }); }));
  const codes = Object.keys(bal).sort();
  const sd = c => bal[c] ? bal[c].d - bal[c].h : 0, sc = c => bal[c] ? bal[c].h - bal[c].d : 0;
  const sumBy = (re, fn) => codes.filter(c => re.test(c)).reduce((s, c) => s + fn(c), 0);
  const T = { ingPub: sumBy(/^4-1/, sc), ingPri: sumBy(/^4-2/, sc), ingAuto: sumBy(/^4-3/, sc), ingEsp: sumBy(/^4-5/, sc), egFunc: sumBy(/^5-1-1/, sd), egAsam: sumBy(/^5-1-2/, sd), egAfil: sumBy(/^5-1-3/, sd), egCap: sumBy(/^5-1-5/, sd), egEsp: sumBy(/^5-3/, sd) };
  T.ing = T.ingPub + T.ingPri + T.ingAuto + T.ingEsp; T.eg = T.egFunc + T.egAsam + T.egAfil + T.egCap + T.egEsp; T.res = T.ing - T.eg;
  const activo = sd('1-1-2-201') + sd('1-1-2-202') + sd('1-1-2-203') + sd('1-1-2-204') + sd('1-2-1-104') + sd('1-2-1-110');
  window.__CASO = { T, activo, bal };

  const partidaHTML = (p, s) => {
    const rows = p.l.map(([c, d, h]) => h ? `<tr><td class="c">${c}</td><td class="h">${ACC[c]}</td><td class="d"></td><td class="hh">${f0(h)}</td></tr>` : `<tr><td class="c">${c}</td><td>${ACC[c]}</td><td class="d">${f0(d)}</td><td class="hh"></td></tr>`).join('');
    return `<div class="partida" data-s="${s}"><div class="ph"><span>P${p.n} · ${p.f} · ${p.t}</span><span class="num">${f0(p.l.reduce((a, r) => a + r[1], 0))}</span></div><table>${rows}</table><div class="gl2">${p.g}</div></div>`;
  };
  const diario = (k, from, to, titulo, m, notes) => add({
    sec: 7, t: 'Libro Diario ' + k, m, cls: 'hs',
    html: `${head('Sección VIII · Libro Diario ' + k + ' de 4', titulo)}<div class="pgrid">${PART.filter(p => p.n >= from && p.n <= to).map((p, i) => partidaHTML(p, i + 1)).join('')}</div>`,
    notes
  });
  const tHTML = (c, s) => {
    const a = bal[c];
    const ds = a.mv.filter(m => m.d).map(m => `<span><i>P${m.n}</i>${f0(m.d)}</span>`).join(''), hs = a.mv.filter(m => m.h).map(m => `<span><i>P${m.n}</i>${f0(m.h)}</span>`).join('');
    const sv = a.d - a.h;
    return `<div class="tacct" data-s="${s}"><div class="tt">${c} · ${ACC[c]}</div><div class="cl"><div>${ds}</div><div>${hs}</div></div><div class="sal">Saldo ${sv >= 0 ? 'deudor' : 'acreedor'}: ${f0(Math.abs(sv))}</div></div>`;
  };

  /* ===== VIII · caso práctico ===== */
  divider(7, 'Caso práctico: Futuro Retalteco', 'Un ejercicio completo, partida por partida: del inicio de actividades al balance y los estados que se presentan al TSE.',
    `<p>Es el corazón del taller. Todo se arma desde una sola base de datos, así que el Diario, el Mayor, la balanza y los estados cuadran entre sí. Cifras ficticias.</p>`);

  add({ sec: 7, t: 'Los datos del caso', m: 2,
    html: `${head('Sección VIII · Caso práctico', 'Conozcamos a <em>Futuro Retalteco</em>')}
      ${tbl(null, [
        ['Inscripción', 'Partido inscrito en el Registro de Ciudadanos desde 2022'],
        ['Resultado en 2023', '150,000 votos y 1 diputación: derecho a financiamiento público'],
        ['Renovación de órganos', 'Asamblea nacional inscrita el 5 de enero de 2026'],
        ['Ejercicio', '1 de enero al 31 de diciembre de 2026'],
        ['Tipo de cambio supuesto', 'Q7.62 por US$1'],
        ['Año siguiente', '2027, elecciones generales: la cuenta de campaña debe abrirse']
      ], { cls: 'sm', s0: 1 })}
      <p class="small mt a" style="--d:900ms">Sede nacional en la ciudad de Guatemala y organización vigente en departamentos y municipios, con base en Retalhuleu.</p>`,
    notes: `<p>Presente el partido ficticio. Aclare que todo aplica la ley y el reglamento vigentes pero con cifras inventadas.</p><p>Lo que haremos: preparar el inicio de actividades, registrar 13 partidas en el Diario, pasarlas al Mayor, sacar la balanza, armar Balance y Estado de Ingresos y Egresos y verificar límites.</p>` });

  add({ sec: 7, t: 'El inicio de actividades', m: 2.5, cls: 'hs',
    html: `${head('Sección VIII · Caso práctico', 'El inicio de actividades')}
      <div class="cols c12" style="gap:50px;align-items:start">
        <div class="tl sm">
          <div class="ev key" data-s="1"><div class="yr">5 ene</div><div class="tx">Se inscriben en el Registro de Ciudadanos los órganos permanentes renovados.</div></div>
          <div class="ev" data-s="2"><div class="yr">≤ 15 días</div><div class="tx"><b>Nombra al contador general</b> ${law('Reglamento art. 12')}</div></div>
          <div class="ev" data-s="3"><div class="yr">≤ 10 h.</div><div class="tx">Notifica a la Unidad con copia del <b>RTU</b> del contador.</div></div>
          <div class="ev" data-s="4"><div class="yr">Enero</div><div class="tx">Habilita libros (SAT: contables; UECFFPP: contribuciones) y verifica sus cuentas.</div></div>
        </div>
        <div class="card hot" data-s="5"><h4>Balance de apertura (Q)</h4>
          ${tbl(null, [['Banco financiamiento privado', f0(50000)], ['Mobiliario y equipo', f0(30000)], { c: ['Activo', f0(80000)], tot: true }, ['Pasivo', '0'], { c: ['Patrimonio partidario', f0(80000)], tot: true }], { cls: 'sm', r: [1] })}
          <p class="small">Certificado por contador general y secretario de finanzas.</p></div>
      </div>
      <p class="small mt" data-s="6">Para 2027, la cuenta de campaña debe abrirse entre septiembre y diciembre de 2026 ${law('Reglamento art. 19')}.</p>`,
    notes: `<p>Antes del primer asiento: el contador general se nombra dentro de 15 días de la inscripción de los órganos permanentes y se notifica a la Unidad en 10 días hábiles con copia del RTU actualizado donde conste su inscripción.</p><p>El balance de apertura: banco privado Q50,000 + mobiliario Q30,000 = patrimonio partidario Q80,000. Pasivo cero.</p>` });

  diario('1', 1, 4, 'Partidas <em>1 a 4</em>', 2, `<p>Apertura, cuotas de afiliados (recibo SAT por cada uno), donación en efectivo de un simpatizante y alquiler de la sede central pagado por transferencia con factura a nombre del partido. Cada partida cuadra: debe = haber.</p>`);
  diario('2', 5, 8, 'Partidas <em>5 a 8</em>', 2.5, `<p>Aquí está el principio del autofinanciamiento: primero el costo de la cena (partida 5) y luego el ingreso (partida 6). Entra el financiamiento público de Q571,500 (partida 7) y se entrega el 50 % a los secretarios (partida 8): Q95,250 a departamentos y Q190,500 a municipios, que quedan por liquidar.</p>`);
  diario('3', 9, 10, 'Partidas <em>9 y 10</em>', 2, `<p>Se ejecutan el 30 % (formación, Q171,450) y el 20 % (sede nacional, Q114,300) del financiamiento público. Todo con factura o planilla IGSS a nombre del partido.</p>`);
  diario('4', 11, 13, 'Partidas <em>11 a 13</em>', 2, `<p>Se liquidan los fondos del interior con informes bajo juramento (partida 11), se registra el aporte en especie en cuentas de control (partida 12) y se cierra con la depreciación del mobiliario al 20 % (partida 13).</p>`);

  add({ sec: 7, t: 'Libro Mayor: cuentas T', m: 2.5, cls: 'hs',
    html: `${head('Sección VIII · Libro Mayor', 'Las cuentas <em>de dinero</em>')}
      <div class="tgrid">${['1-1-2-201', '1-1-2-202', '1-1-2-203', '1-1-2-204', '3-1-1', '4-1-1-101'].map((c, i) => tHTML(c, i + 1)).join('')}</div>
      <p class="small mt" data-s="7">El financiamiento público entra (P7), sale a los secretarios (P8) y a gastos (P9 y P10): termina en cero. Los fondos del interior también se cancelan al liquidar (P11).</p>`,
    notes: `<p>El Mayor toma cada línea del Diario y la acomoda por cuenta: el debe a la izquierda, el haber a la derecha. «P4» significa partida 4.</p><p>Banco público: entra 571,500; sale 285,750 + 171,450 + 114,300 = 571,500. Saldo cero. Banco privado: saldo deudor Q89,000. Departamentos y municipios: saldo cero tras liquidar.</p>` });

  const rows = codes.map(c => { const a = bal[c], s = a.d - a.h; return [c, ACC[c], f0(a.d), f0(a.h), s > 0 ? f0(s) : '', s < 0 ? f0(-s) : '']; });
  const td = codes.reduce((s, c) => s + bal[c].d, 0), sdt = codes.reduce((s, c) => s + Math.max(0, bal[c].d - bal[c].h), 0);
  add({ sec: 7, t: 'Balanza de comprobación', m: 1.5, cls: 'hs',
    html: `${head('Sección VIII · Balanza', 'Sumas <em>iguales</em>')}
      ${tbl(['Código', 'Cuenta', 'Debe', 'Haber', 'S. deudor', 'S. acreedor'], rows.concat([{ c: ['', 'Sumas iguales', f0(td), f0(td), f0(sdt), f0(sdt)], tot: true }]), { cls: 'xxs', r: [2, 3, 4, 5] })}`,
    notes: `<p>Antes de armar los estados se verifica que el debe y el haber sumen igual (Q${f0(td)}) y que los saldos deudores igualen a los acreedores (Q${f0(sdt)}).</p>` });

  add({ sec: 7, t: 'Balance de Situación General', m: 2, cls: 'hs',
    html: `${head('Sección VIII · Estado financiero 1 de 2', 'Balance de Situación General')}
      <div class="cols c12" style="gap:50px;align-items:start">
        <div>${tbl(['Al 31 de diciembre de 2026', 'Q'], [
          { c: ['<b>1 · ACTIVO</b>', ''] },
          ['Banco financiamiento público', '0'], ['Banco financiamiento privado', f0(sd('1-1-2-202'))], ['Bancos departamentos y municipios', '0'],
          ['Mobiliario y equipo (neto)', f0(sd('1-2-1-104') + sd('1-2-1-110'))],
          { c: ['TOTAL ACTIVO', f0(activo)], tot: true },
          { c: ['<b>2 · PASIVO</b>', '0'] },
          { c: ['<b>3 · PATRIMONIO</b>', ''] }, ['Patrimonio partidario', f0(sc('3-1-1'))], ['Resultado del ejercicio', f0(T.res)],
          { c: ['TOTAL PASIVO + PATRIMONIO', f0(sc('3-1-1') + T.res)], tot: true }
        ], { cls: 'sm', r: [1], s0: 1 })}</div>
        <div class="card hot" data-s="12"><div class="cap">Activo total</div><div class="hero m num"><span class="cnt" data-pre="Q " data-to="${activo}">0</span></div>
          <div class="note ok" style="margin-top:20px"><b>Cuadra</b>Activo = Pasivo + Patrimonio. El patrimonio creció Q${f0(T.res)}, el resultado del ejercicio.</div></div>
      </div>`,
    notes: `<p>Activo: Q${f0(sd('1-1-2-202'))} en banco privado + Q${f0(sd('1-2-1-104') + sd('1-2-1-110'))} de mobiliario neto (30,000 − 6,000) = <b>Q${f0(activo)}</b>. Pasivo: cero. Patrimonio: Q80,000 + resultado Q${f0(T.res)} = Q${f0(activo)}.</p><p>Los fondos públicos y los de departamentos y municipios cerraron en cero porque se gastaron y se liquidaron.</p>` });

  add({ sec: 7, t: 'Estado de Ingresos y Egresos', m: 2, cls: 'hs',
    html: `${head('Sección VIII · Estado financiero 2 de 2', 'Estado de Ingresos y <em>Egresos</em>')}
      ${tbl(['1 de enero al 31 de diciembre de 2026', 'Q'], [
        ['<b>1.1 Financiamiento público</b>', f0(T.ingPub)],
        ['<b>1.2 Financiamiento privado</b> (cuotas 24,000 · simpatizantes 15,000 · cena 18,000 · especie 5,000)', f0(T.ingPri + T.ingAuto + T.ingEsp)],
        { c: ['TOTAL INGRESOS', f0(T.ing)], tot: true },
        ['<b>2.1 Gastos permanentes</b> (funcionamiento, asambleas, afiliación, capacitación, especie)', f0(T.eg)],
        ['<b>2.2 Gastos de campaña</b>', '0'],
        { c: ['TOTAL EGRESOS', f0(T.eg)], tot: true },
        { c: ['3 · RESULTADO DEL EJERCICIO', f0(T.res)], tot: true }
      ], { cls: 'sm', r: [1], s0: 1 })}
      <p class="small mt" data-s="8">Los aportes no dinerarios aparecen en ingresos y en egresos por el mismo valor. El resultado es el dinero privado que sobró: Q57,000 de aportes y cena, menos alquiler, costo de la cena y depreciación.</p>`,
    notes: `<p>Ingresos: Q${f0(T.ingPub)} públicos + Q${f0(T.ing - T.ingPub)} privados = Q${f0(T.ing)}. Egresos: Q${f0(T.eg)}. Resultado: Q${f0(T.res)}.</p><p>Desglose de egresos: funcionamiento Q${f0(T.egFunc)}, asambleas de ley Q${f0(T.egAsam)}, campañas de afiliación Q${f0(T.egAfil)}, capacitación Q${f0(T.egCap)} y especie Q${f0(T.egEsp)}.</p>` });

  add({ sec: 7, t: 'Verificación final del caso', m: 2, cls: 'hs',
    html: `${head('Sección VIII · Verificación', '¿Cumple Futuro Retalteco?')}
      ${tbl(['Control', 'Resultado'], [
        ['30 % formación: esperado Q171,450', '<span class="green">Q171,450 ✓</span>'],
        ['20 % sede nacional: esperado Q114,300', '<span class="green">Q114,300 ✓</span>'],
        ['50 % departamentos y municipios: esperado Q285,750', '<span class="green">Q285,750 ✓</span>'],
        ['Aporte de Q15,000 frente al límite de Q3,886,200', '<span class="green">Dentro del límite</span>'],
        ['Umbrales de Q30,000 y Q50,000', '<span class="green">No se activan</span>'],
        ['Recibos SAT, facturas a nombre del partido, justiprecio, libros al día', '<span class="green">Sí</span>']
      ], { cls: 'sm', r: [1], s0: 1 })}
      <div class="mt"><div class="cap a" style="--d:300ms">Informes por presentar por 2026</div>
      ${ul(['<b>GR-PRI:</b> abril, julio, octubre y enero', '<b>INF-FINPU:</b> julio y enero', '<b>Estados financieros</b> con Diario, Mayor, contribuciones y dictamen externo: hasta el 31 de marzo de 2027'], 7, 'sm')}</div>`,
    notes: `<p>Cierre del caso: todos los controles de reparto, límites y documentación se cumplen. Pregunte a la sala: ¿qué cambiaría en 2027, año electoral? (cuenta de campaña, techo, INFOCAM).</p><p>Abra ronda de preguntas de 5 minutos antes de la sección IX.</p>` });

  /* ===== IX · obligaciones y SAT ===== */
  divider(8, 'Obligaciones, SAT y cumplimiento', 'Quién responde por qué, qué pasa si se incumple, qué se hace ante la SAT y la lista final de verificación.',
    `<p>Última sección: responsabilidades, sanciones, obligaciones tributarias y lista de cumplimiento.</p>`);

  add({ sec: 8, t: 'Quién responde por qué', m: 2, cls: 'hs',
    html: `${head('Sección IX · Responsables ' + law('Reglamento art. 14'), 'Información financiera con nombre y firma')}
      ${tbl(['Quién', 'Responsabilidad'], [
        ['<b>Contador general</b>', 'Lleva la contabilidad y certifica los informes. Nombrado en 15 días; notificado en 10 días hábiles.'],
        ['<b>Secretario de finanzas</b>', 'Certifica los informes y entrega los fondos junto con el secretario general.'],
        ['<b>Órgano de fiscalización financiera</b>', 'Revisa los informes y reporta anomalías al CEN, que avisa a la Unidad en 5 días.'],
        ['<b>Secretario general</b>', 'Aprueba y autoriza; responde personalmente por los fondos públicos.'],
        ['<b>Secretarios departamentales y municipales</b>', 'Administran y liquidan los fondos que reciben.']
      ], { cls: 'sm', s0: 1 })}`,
    notes: `<p>Reglamento art. 14 y LEPP arts. 19 Bis, 21 Bis y 21 Ter b. La responsabilidad es personal y solidaria entre los secretarios y el secretario de finanzas, según el Instructivo.</p>` });

  add({ sec: 8, t: 'Obligaciones permanentes del partido', m: 1.5,
    html: `${head('Sección IX · Obligaciones ' + law('LEPP art. 22'), 'Lo que un partido <em>siempre</em> debe hacer')}
      ${ul(['Someter libros y documentos a revisión del TSE en cualquier tiempo',
        'Abstenerse de ayuda económica o trato preferente del Estado no permitido por la ley',
        'Entregar actas de asamblea y cambios de estatutos al Registro de Ciudadanos en 15 días',
        'Llevar un registro depurado de afiliados',
        'Pedir al Registro de Ciudadanos la autorización de los libros de actas'], 1)}`,
    notes: `<p>Obligaciones del artículo 22 de la LEPP relevantes para el contador. El partido debe colaborar con el TSE y mantener su documentación en orden y accesible.</p>` });

  add({ sec: 8, t: 'Sanciones por incumplir', m: 2, cls: 'hs',
    html: `${head('Sección IX · Consecuencias ' + law('art. 88'), 'Una <em>escalera</em> de sanciones')}
      <div class="ladder">
        <div class="rg" data-s="1" style="background:#e9d7a8"><i>1</i>Amonestación pública o privada</div>
        <div class="rg" data-s="2" style="background:#e5c47a"><i>2</i>Multa</div>
        <div class="rg" data-s="3" style="background:#e0ac55"><i>3</i>Suspensión temporal</div>
        <div class="rg" data-s="4" style="background:#e08c55"><i>4</i>Suspensión de la facultad de recibir financiamiento público o privado</div>
        <div class="rg" data-s="5" style="background:#e5805a"><i>5</i>Cancelación del partido</div>
      </div>
      ${note('Responsabilidad penal', 'Si hay posible delito, el TSE certifica lo conducente al Ministerio Público. Quienes aportan contraviniendo la ley quedan sujetos al Código Penal.', 'warn', 6)}`,
    notes: `<p>Sin orden de prelación: el TSE gradúa según gravedad y jurisdicción. La cancelación puede declararse de oficio y sin suspensión previa (art. 21 Ter k). En la práctica, se aplican gradualmente con proporcionalidad y razonabilidad (Reglamento art. 14).</p>` });

  add({ sec: 8, t: 'Qué se considera infracción', m: 1.2,
    html: `${head('Sección IX · Consecuencias', 'Infracciones frecuentes en las cuentas')}
      ${ul(['No presentar informes en plazo, o presentarlos con anomalías o incongruencias',
        'No notificar al contador, o contratar contabilidad externa sin avisar',
        'Aceptar aportes anónimos, prohibidos o sobre el límite del 10 %',
        'Gastar sin documento legal a nombre del partido'], 1)}`,
    notes: `<p>Reglamento art. 14: la anomalía, la incongruencia o la no presentación de información financiera en el plazo son causal de sanción. El órgano de fiscalización interna debe reportar anomalías al CEN, que informa a la Unidad en cinco días.</p>` });

  add({ sec: 8, t: 'SAT: ante quién se inscribe un partido', m: 2, cls: 'hs',
    html: `${head('Sección IX · Obligaciones ante la SAT', '¿Ante quién se <em>inscribe</em> un partido?')}
      <div class="cols c2" style="gap:36px">
        <div class="card hot a"><h4>Existencia legal</h4><p>Se constituye en escritura pública y se inscribe en el <b>Registro de Ciudadanos del TSE</b>, donde obtiene su personalidad jurídica ${law('LEPP arts. 18-19')}</p></div>
        <div class="card blue a"><h4>Existencia tributaria</h4><p>Ante la <b>SAT</b>, en el Registro Tributario Unificado (RTU), obtiene su NIT. ${vf('verificar trámite vigente')}</p></div>
      </div>
      ${ul(['Mantener actualizado el RTU: el NIT va en recibos, facturas y notas', 'Habilitar los libros contables ante la SAT', 'Hacer autorizar los recibos de ingreso', 'Exigir facturas a su nombre en todo gasto'], 1, 'sm')}`,
    notes: `<p>Una cosa es la existencia legal (TSE) y otra la tributaria (SAT). El Registro Tributario Unificado nace del Decreto 25-71.</p><p><b>Falta confirmar con la SAT</b> los detalles del trámite de inscripción como organización política, la constancia de exención y los formularios vigentes.</p>` });

  add({ sec: 8, t: 'SAT: qué debe hacer', m: 1.5,
    html: `${head('Sección IX · Obligaciones ante la SAT', 'Qué hace el partido <em>ante la SAT</em>')}
      <div class="cols c2" style="gap:30px">
        ${card('Solvencia fiscal', 'Sus donantes la necesitan para deducir sus aportes ' + law('LAT art. 23 s'), { s: 1 })}
        ${card('Retenciones', 'Los partidos son agentes de retención del ISR ' + law('LAT arts. 47, 48, 86'), { s: 2, cls: 'blue' })}
        ${card('Planillas', 'Si hay empleados, planilla al IGSS: respalda el gasto ' + law('Reglamento art. 24 c'), { s: 3, cls: 'green' })}
        ${card('Régimen en notas', 'Revelar en la nota 2 el régimen tributario y las exenciones', { s: 4 })}
      </div>`,
    notes: `<p>No deduce quien dona a un partido sin solvencia fiscal vigente (LAT art. 23 s). Los partidos actúan como agentes de retención (arts. 47 y 86): retienen el 7 % en el régimen simplificado y entregan constancia en cinco días (art. 48).</p>` });

  add({ sec: 8, t: 'Impuestos que pueden afectar', m: 2.5, cls: 'hs',
    html: `${head('Sección IX · Obligaciones ante la SAT', 'Impuestos que pueden <em>afectar</em> al partido')}
      ${tbl(['Concepto', 'Tratamiento', 'Base'], [
        ['<b>ISR: donaciones y cuotas</b>', 'Renta <b>exenta</b> si el destino es no lucrativo y no se distribuyen utilidades', 'LAT art. 11 num. 1'],
        ['<b>ISR: actividades lucrativas</b>', 'Rentas mercantiles, financieras o de servicios están <b>gravadas</b> ' + vf('caso por caso'), 'LAT art. 11 num. 1'],
        ['<b>Retenciones ISR</b>', 'Agente de retención; 7 % en régimen simplificado, constancia a los 5 días', 'LAT arts. 47, 48, 86'],
        ['<b>IVA: cuotas</b>', 'Cuotas periódicas a partidos políticos: <b>exentas</b>', 'IVA art. 7 num. 10'],
        ['<b>IVA: autofinanciamiento</b>', 'Entradas, rifas o espectáculos pueden estar afectos ' + vf('confirmar con SAT'), 'Ley del IVA'],
        ['<b>Cuotas IGSS</b>', 'Con planilla: se presenta y respalda el gasto', 'Reglamento art. 24 c']
      ], { cls: 'xs', s0: 1 })}
      <div class="mt">${note('Regla práctica', 'Lo que se recibe como aporte, cuota o donación es el corazón de la exención. Lo que se vende como negocio se trata distinto: regístrelos en cuentas separadas.', '', 7)}</div>`,
    notes: `<p>Fuente: Ley de Actualización Tributaria (Decreto 10-2012) y Ley del IVA (Decreto 27-92). Las rentas de partidos y comités cívicos están exentas «únicamente por la parte que provenga de donaciones o cuotas ordinarias o extraordinarias»; las actividades lucrativas se gravan y se declaran.</p><p>Recuerde que el Reglamento (art. 29) aclara que cumplirlo no releva de las leyes fiscales.</p>` });

  const CHK = ['Contador general nombrado y notificado a la UECFFPP con RTU', 'Cuentas separadas: pública, privada, campaña y del interior', 'Firmas mancomunadas y aviso de apertura en 5 días hábiles',
    'Libros contables habilitados por la SAT, al día en dos meses', 'Libros de contribuciones habilitados por la UECFFPP', 'Recibo SAT para cada aporte, con sus datos mínimos',
    'Ningún aporte anónimo, prohibido ni mayor al 10 % del techo', 'Especie justipreciada y declaración jurada sobre Q50,000', 'Financiamiento público distribuido 30 / 20 / 50 con acta del CEN',
    'Fondos del interior liquidados cada trimestre', 'Todo gasto con factura o documento legal a nombre del partido', 'GR-PRI trimestral e INF-FINPU semestral en plazo',
    'Estados financieros con dictamen externo antes del 31 de marzo', 'Obligaciones SAT al día: RTU, retenciones y solvencia fiscal'];
  add({ sec: 8, t: 'Resumen de cumplimiento clave', m: 3, cls: 'hs',
    html: `${head('Resumen de cumplimiento clave', 'Su lista de <em>verificación</em>')}
      <div class="chk">${CHK.map((c, i) => `<div class="hid" data-s="${i + 1}">${c}</div>`).join('')}</div>`,
    hook(el, step) { el.querySelectorAll('.chk div').forEach((d, i) => d.classList.toggle('hid', i + 1 > step)); },
    notes: `<p>Recorra la lista paso a paso; cada paso marca un control. Pida a los asistentes que respondan mentalmente «sí» o «no» para su organización.</p><p>Esta lista puede entregarse impresa al final como material de apoyo (versión del libro).</p>` });

  add({ sec: 8, t: 'Glosario', m: 1.5, cls: 'hs',
    html: `${head('Glosario', 'Términos que conviene <em>dominar</em>')}
      <div class="recs a" style="font-size:25px">
        ${[['CEN', 'Comité Ejecutivo Nacional'], ['Financista político', 'Persona nacional que aporta en dinero o especie'], ['Unidad de vinculación', 'Personas con propiedad, administración o control común'],
        ['Justiprecio', 'Valor de mercado de un aporte en especie'], ['Comodato', 'Préstamo de uso de un bien'], ['Autofinanciamiento', 'Ingresos por actividades propias'],
        ['Techo de campaña', 'US$0.50 por empadronado'], ['GR-PRI', 'Informe trimestral de financiamiento privado'], ['INF-FINPU', 'Informe semestral del financiamiento público'],
        ['INFOCAM', 'Informe financiero de campaña'], ['UECFFPP', 'Unidad Especializada de Control y Fiscalización'], ['RTU / NIT', 'Registro y número de identificación tributaria'],
        ['LAT', 'Ley de Actualización Tributaria, Decreto 10-2012']].map(([a, b]) => `<div style="display:block"><b style="color:var(--gold2)">${a}</b><br><span style="font-size:23px">${b}</span></div>`).join('')}
      </div>`,
    notes: `<p>Deje esta lámina proyectada mientras responde preguntas. Sirve de apoyo para términos que salieron durante la sesión.</p>` });

  add({ sec: 8, t: 'Fuentes y advertencias', m: 1.5, cls: 'hs',
    html: `${head('Fuentes', 'De dónde sale <em>cada dato</em>')}
      ${ul(['TSE: <i>Ley Electoral y de Partidos Políticos y sus Reglamentos, actualización 2026</i> (Reglamento Ac. 602-2022, reformado por 22-2023 y 60-2026)',
        'Decreto 26-2016, reformas a la LEPP',
        'TSE: <i>Instructivo para la Rendición de Cuentas de las Organizaciones Políticas</i>',
        'Decreto 10-2012, Ley de Actualización Tributaria, arts. 11, 23, 47, 48 y 86',
        'Decreto 27-92, Ley del IVA, art. 7 numeral 10',
        'CICIG (2015), <i>El financiamiento de la política en Guatemala</i>; Prensa Libre y Soy502 para el techo estimado'], 1, 'sm')}
      ${note('Antes de aplicar', 'Material didáctico a octubre de 2026. Confirme siempre el texto vigente y los formularios con la Unidad Especializada y la SAT. Pendiente: trámite del RTU, constancia de exención, IVA en autofinanciamiento y texto de los Acuerdos 58, 59 y 61-2026.', 'warn', 7)}`,
    notes: `<p>Cierre con la advertencia: este es material educativo. Los puntos marcados como «verificar» deben confirmarse con la SAT o con un asesor.</p>` });

  add({ sec: -1, t: 'Cierre', m: 2, cls: 'cover', nochrome: true,
    html: `<img class="logo a-z" src="assets/logo-monterroso-blanco.png" alt="Firma de Auditoría Monterroso"><div class="rule"></div>
      <h2 class="split">Gracias</h2>
      <p class="lead a" style="--d:700ms">Contabilidad, auditoría y consultoría para organizaciones que rinden cuentas.</p>
      <div class="kick a" style="--d:1000ms;margin-top:30px">Preguntas y conversación</div>`,
    notes: `<p>Agradezca y abra espacio de preguntas. Ofrezca entregar el libro interactivo y la lista de cumplimiento como material de seguimiento.</p>` });

  /* Ajusta los tiempos sugeridos para que la sesión sume 100 minutos, conservando el peso relativo de cada lámina. */
  const total = S.reduce((a, s) => a + (s.m == null ? 1 : s.m), 0), k = 100 / total;
  S.forEach(s => { s.m = Math.max(0.2, Math.round((s.m == null ? 1 : s.m) * k * 10) / 10); });
})();
