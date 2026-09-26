# República Dominicana

Todo lo que República Dominicana añade a Ekwo, como datos: un catálogo de
cuentas construido para calzar con los anexos de la Declaración Jurada del
Impuesto sobre la Renta, los diarios, el Impuesto sobre Transferencias de
Bienes Industrializados y Servicios (ITBIS) a sus tarifas general y reducida,
una tasa cero a la exportación y una exención local, los campos del
Formulario IT-1, un balance general y un estado de resultados mínimos, y las
menciones que una factura necesita. El formato es
[`docs/packs.md`](../../docs/packs.md); este archivo dice de dónde viene el
contenido y sobre qué decisiones descansa, para que un contador dominicano
que lea el paquete pueda discrepar de una frase concreta y no del conjunto.

**Estado: `community`.** Nadie que declare el ITBIS lo ha revisado. Las
cifras se reproducen contra un año de libros mediante `tests/golden.test.ts`,
lo que prueba que el paquete es coherente y no prueba que sea correcto.

**Idioma.** Las etiquetas propias del paquete están escritas en español
(`defaults.language: "es"`), y `languages` está vacío: no se declara todavía
una segunda redacción. Los textos oficiales sobre los que este paquete
construye sus estados — el Código Tributario y el instructivo del Formulario
IR-2 — no tienen traducción oficial al inglés, así que una etiqueta en
inglés, el día que alguien la aporte, sería una traducción que hace Ekwo y
no una redacción que la ley misma lleva.

## Ekwo no emite el comprobante fiscal electrónico dominicano

**Un comprobante fiscal dominicano es un e-CF, y sólo ampara la operación una
vez que la Dirección General de Impuestos Internos (DGII) lo ha validado.**
La Ley No. 32-23, de Facturación Electrónica (16 de mayo de 2023), crea ese
régimen y lo hace obligatorio de forma escalonada según el tamaño del
contribuyente: doce meses desde su entrada en vigor para los Grandes
Contribuyentes Nacionales, veinticuatro para los Grandes Contribuyentes
Locales y Medianos, y treinta y seis para los Pequeños, Micro y no
Clasificados. Es un régimen de validación previa (clearance), como el CFDI
mexicano o la factura electrónica colombiana, y no un intercambio par a par
construido sobre el modelo semántico de EN 16931. La DGII ajusta las fechas
exactas de cada categoría mediante avisos sucesivos — la ley fija los plazos
en meses desde su entrada en vigor, y es la propia Dirección la que publica
el calendario final por categoría, sujeto a prórrogas.

Ekwo no genera el XML del e-CF, no calcula su sello ni dialoga con la DGII o
con un proveedor tecnológico autorizado. Por eso:

- `einvoicing` no nombra **ni perfil ni fecha**, aunque la obligación exista
  y avance por etapas. `profile` nombra un perfil construido sobre EN 16931
  (`peppol-bis-3`, `factur-x-en16931`, `xrechnung`, un PINT), y el e-CF
  dominicano no es ninguno de ellos; el formato tampoco tiene una palabra
  para «válido sólo tras la validación previa de un tercero» ni para una
  obligación que depende del tamaño del contribuyente. Su referencia legal
  dice lo que exige la ley y dice, en mayúsculas, que Ekwo no genera, no
  calcula el sello y no transmite un e-CF.
- Todo documento lleva la mención `ecf_not_assigned`: *este documento no es
  un e-CF; sólo el comprobante validado por la DGII ampara la operación para
  efectos tributarios.*
- El número que un documento recibe en Ekwo es el consecutivo de la pieza
  contable, y no el sello de validación, que sólo una validación asigna.
- El Registro Nacional de Contribuyentes (RNC) no tiene un esquema ISO 6523
  registrado, así que `party_scheme` y `vat_scheme` quedan vacíos, por la
  misma razón que en los paquetes de México y Colombia.

Lo que una empresa hace hoy: validar el comprobante a través de un proveedor
tecnológico autorizado o de la plataforma de la DGII, y registrar la
operación en Ekwo. Véase *Lo que el núcleo no pudo decir*, más abajo.

## Fuentes

Cada tasa, casilla, mención y estado lleva su propia `legal_reference` y la
clave del texto en que se apoya. El registro de `pack.json` lleva ocho
textos, todos consultados el 26 de septiembre de 2026: el Título III del
Código Tributario (Ley No. 11-92) que compila la propia DGII; la Ley No.
253-12 que modificó sus tasas y exenciones; la ficha del ITBIS y el
Formulario IT-1 con su instructivo de llenado, ambos de la DGII; el
instructivo de la Declaración Jurada del Impuesto sobre la Renta (IR-2) y sus
anexos A-1 y B-1; la resolución del Instituto de Contadores Públicos
Autorizados de la República Dominicana (ICPARD) que confirma la
implementación de las NIIF para PYMES; la Ley No. 32-23 de Facturación
Electrónica; y el portal de la DGII sobre el calendario de obligatoriedad del
e-CF.

## El catálogo de cuentas

**República Dominicana no impone un catálogo de cuentas único.** No existe
un Plan Único de Cuentas dominicano comparable al colombiano: la Ley General
de las Sociedades Comerciales (Ley No. 479-08) no prescribe una numeración
contable, y desde que el Instituto de Contadores Públicos Autorizados de la
República Dominicana confirmó, mediante su Acta 22-2014, la implementación
de las Normas Internacionales de Información Financiera para Pequeñas y
Medianas Entidades (NIIF para PYMES) a partir del 1 de enero de 2014, cada
entidad define su propio catálogo bajo NIIF o NIIF para PYMES.

Este paquete usa, como catálogo propio, una numeración construida para este
proyecto — sin pretender ser oficial — organizada para que sus grandes
grupos calcen con los renglones del Anexo A-1 (Balance General) y del Anexo
B-1 (Estado de Resultados) que la DGII exige como anexos de la Declaración
Jurada del Impuesto sobre la Renta (IR-2) de toda persona jurídica de los
sectores manufactura, comercio o agropecuaria — el documento más parecido a
un formato de estados financieros oficial que la administración dominicana
publica. La identidad de agrupación es la asociación, no una obligación
legal de usar precisamente esta numeración, de la misma manera que el
paquete de México usa el código agrupador del SAT y el de Colombia usa una
selección del Plan Único de Cuentas tras la convergencia a NIIF.

Seleccionadas: caja y bancos, clientes, las cuentas de control del ITBIS
separadas entre cobrado y pagado y por tarifa, inventarios, los activos fijos
usuales y su depreciación acumulada, proveedores, retenciones de ISR y de la
Tesorería de la Seguridad Social (TSS) por pagar, capital y reservas,
resultados acumulados aparte del resultado del ejercicio, ingresos por clase,
el costo de venta y las compras de una empresa comercializadora, y los gastos
generales que necesita.

Cuatro decisiones:

- **Las cuentas de ITBIS separan lo cobrado de lo pagado, y por tarifa.**
  `2104` *Impuestos por Pagar* es el encabezado; `210401` y `210402` son
  donde se postea el ITBIS de una venta, a la tarifa general y a la tarifa
  reducida; `210403`, `210404` y `210405` son donde se postea el ITBIS
  deducible de una compra, según sea de bienes, de servicios o de
  importación — la misma separación que exige el Formulario IT-1 entre sus
  casillas 22, 23 y 24. Ninguna de las cinco es la cuenta de liquidación.
- **La declaración liquida a `210406`** *ITBIS por Pagar* **o a `120302`**
  *ITBIS Saldo a Favor* — la primera un pasivo, la segunda un activo, como en
  el paquete de Colombia. Ambas son distintas de las cinco cuentas donde se
  postea el impuesto y ambas son conciliables (`reconcilable`), al igual que
  las otras dos cuentas conciliables del paquete, clientes (`1201`) y
  proveedores (`2102`) — véase la nota sobre `reconcilable` en
  [`docs/packs.md`](../../docs/packs.md).
- **La cuenta de espera es `2106`** *Cuentas de Orden por Clasificar*: no
  existe una cuenta oficial dominicana para dinero recibido por cuenta de
  un tercero, y ésta es la más cercana en este catálogo propio.
- **`4203`** *Ajuste por Redondeo*, bajo *Ingresos Financieros*, es la cuenta
  de redondeo: ningún texto dominicano la nombra, así que se sitúa donde el
  paquete de Colombia sitúa la suya.

## Los estados financieros

`DO-IR2-A1` (Balance General) y `DO-IR2-B1` (Estado de Resultados) no son una
transcripción de la presentación completa bajo NIIF para PYMES, cuyas notas
de revelación y desagregación pertenecen a un profesional que las prepara.
Leen los grandes grupos del catálogo propio de este paquete en la forma
abreviada que la propia DGII exige a través de los Anexos A-1 y B-1 de la
Declaración Jurada del Impuesto sobre la Renta (IR-2): una línea por grupo,
unos pocos subtotales, y un solo resultado. Una empresa que necesite la
presentación completa bajo NIIF para PYMES tiene un catálogo y una cifra de
la que partir, no una declaración terminada. `xbrl` queda vacío en todas
partes: no existe una taxonomía dominicana mapeada.

## Impuestos

| Código | Tasa | Tratamiento | Casillas de la declaración |
|---|---|---|---|
| `DO-S-18` | 18 % | venta doméstica | 11 / 16 |
| `DO-S-16` | 16 % | venta doméstica, tarifa reducida (art. 345, párr. II) | 12 / 17 |
| `DO-S-EXP` | 0 % | exportación (art. 342) | 2 |
| `DO-S-EXE` | — | venta local exenta (art. 343) | 4 |
| `DO-P-18-BIENES` | 18 % | compra doméstica de bienes | 22 |
| `DO-P-18-SERVICIOS` | 18 % | compra doméstica de servicios | 23 |
| `DO-P-18-IMPORTACION` | 18 % | importación de bienes | 24 |
| `DO-P-EXE` | — | compra de bienes exentos | — |

**La tarifa general es del 18 %, no del 16 %, aunque el artículo 341 diga
16 %.** El artículo 341 fue superado por el artículo 345 (modificado por la
Ley No. 253-12), que fija la tasa en 18 % para 2013 y 2014, y en 16 % a
partir de 2015 — condicionado a que ello permita alcanzar la meta de presión
tributaria de la Estrategia Nacional de Desarrollo (párrafo I). La propia
DGII publica en su ficha oficial del ITBIS que la tasa a aplicar «a partir
del 2016 será del 18 %»: la reducción condicionada nunca se activó, y este
paquete declara la tasa que la administración aplica hoy y no la que un
párrafo condicional habría permitido.

**La tarifa reducida del 16 % es distinta y no debe confundirse con la del
párrafo I.** El párrafo II del mismo artículo 345 fija, para una lista
cerrada de bienes (lácteos, café, grasas y aceites vegetales, azúcares, cacao
y chocolate), una tabla de tasas por año que llegó al 16 % en 2016 y se ha
mantenido desde entonces. Este paquete usa el azúcar (partida arancelaria
17.01) como ejemplo.

**Exento no es lo mismo que tasa cero, y el formato distingue los dos por el
tratamiento.** Un bien exportado (art. 342) se declara `export`,
`vat_category: G`: tasa cero con derecho pleno a deducir y, si procede, a
que se reembolse el ITBIS adelantado en su producción. Un bien exento del
artículo 343 (el ejemplo de este paquete es el arroz, partida arancelaria
10.06) se declara `exempt`, `vat_category: E`: no causa el impuesto y **no**
da derecho a deducir nada de lo pagado en su producción o adquisición (art.
346, y la casilla 45 del Formulario IT-1, que reúne el ITBIS no deducible de
las operaciones de productores de bienes o servicios exentos). Confundir los
dos habría sido el error más fácil que este paquete podía cometer, y por eso
queda escrito aquí para quien lo revise después.

**República Dominicana está fuera del sistema común de IVA de la Unión
Europea.** `supabase/seed/00_territories.sql` lleva una fila para `DO` con
`eu_vat_scope: none`. En consecuencia, `exemption_code` queda vacío en todas
las tasas — la lista VATEX pertenece a un sistema del que República
Dominicana no forma parte — y el artículo va en `legal_reference` en su
lugar; los cinco tratamientos `intracom_*` nunca se usan; y `vat_category` se
declara aunque ninguna columna del formato lo exija (el paquete no declara
`einvoicing.profile`), únicamente para quien lea el paquete, como hace el
paquete de México.

**Bienes y servicios se separan del lado de la compra, no del lado de la
venta.** El Formulario IT-1 pide la base imponible de una venta en una sola
casilla por tarifa (11 o 12), sin importar qué se vendió, pero separa el
ITBIS deducible de una compra local entre bienes (casilla 22) y servicios
(casilla 23) — y las importaciones en una tercera (casilla 24). Por eso
`DO-P-18-BIENES`, `DO-P-18-SERVICIOS` y `DO-P-18-IMPORTACION` son tres
códigos a la misma tarifa del 18 % en vez de uno: la casilla que alcanza una
compra depende de qué se compró, no de su tarifa, y una tasa lleva una sola
casilla.

**Ninguna casilla de base de compra existe en el Formulario IT-1.** A
diferencia de Colombia, que pide la base de cada compra en sus casillas 50 a
54, el Formulario IT-1 sólo pide el ITBIS deducible por categoría (casillas
22 a 24), y nunca la base imponible de la compra. Por eso los postings de
tipo `base` de las tasas de compra de este paquete no llevan ninguna casilla:
el `base` sigue siendo necesario para que el motor calcule el impuesto, pero
no hay ninguna casilla del formulario en la que deba aparecer — el mismo
razonamiento que ya usan, por ejemplo, la tasa `US-P-0` de Estados Unidos o
la tasa `SK-P-DOVOZ-23` de Eslovaquia.

**No aquí:** las retenciones — ReteISR sobre honorarios y alquileres
(Norma General 02-05), la retención del 2 % del ITBIS facturado en pagos con
tarjeta de crédito o débito (Norma General 08-04), la retención del 100 %
del ITBIS que las entidades del Estado practican a sus proveedores, y la
retención del Impuesto Sobre la Renta sobre dividendos, alquileres y
honorarios de personas físicas — y las tarifas especiales del sector
turístico de todo incluido introducidas por la Ley No. 690-16 (casillas 13,
14, 18 y 19 del Formulario IT-1, al 9 % y al 8 %), que este paquete no
modela por depender de un régimen sectorial ajeno a una comercializadora
ordinaria. Una empresa sujeta a cualquiera de ellas necesita la ayuda de un
profesional hasta que una versión posterior de este paquete, o un paquete de
retenciones dedicado, las lleve. Véase *Lo que el núcleo no pudo decir*.

## La declaración

`DO-ITBIS-IT1` es el Formulario IT-1, que se presenta y se paga mensualmente
— el Código Tributario no ofrece más que una cadencia a ningún declarante de
ITBIS, así que el paquete declara `period_default: "month"`. El paquete
declara las quince casillas del formulario que sus tasas efectivamente
alcanzan; el resumen de comprobantes por tipo de NCF del Anexo A, las
operaciones de constructoras y comisionistas, las retenciones computables y
el saldo a favor del período anterior no se modelan — dependen de hechos
fuera de un solo período del libro mayor, un anexo que Ekwo no lleva, o un
régimen sectorial — y quedan para que la empresa los añada a mano al
declarar, exactamente como en cualquier otro paquete de este repositorio.

- **Plazo.** `day_of_month_after_period`, día 20: la propia ficha del ITBIS
  de la DGII dice que el formulario se presenta y se paga dentro de los
  primeros veinte días del mes siguiente al período declarado.
- **Redondeo.** Ningún texto consultado exige redondear las casillas del
  Formulario IT-1 a una unidad más gruesa que el centavo del peso dominicano;
  el paquete no declara `rounding` en `tax_report.json`.

## El año dorado (golden)

Una comercializadora dominicana, declarante mensual, enero y febrero de
2026: diez documentos y cinco pagos. Vende mercancía general a la tarifa del
18 %, azúcar a la tarifa reducida del 16 %, exporta azúcar con tasa cero, y
vende arroz exento; compra mercancía general y un servicio de transporte a
la tarifa general, y arroz exento para su reventa; acredita parte de la
venta del 18 %. El segundo mes se construye a propósito para que sus compras
superen sus ventas, y ejercer así un saldo a favor (casilla 27) en vez de
sólo un saldo a pagar (casilla 26).

Cada cifra de `golden/vat_return.json`, `golden/statements.json` y
`golden/trial_balance.json` fue verificada a mano contra el escenario antes
de confirmar este paquete — no sólo reproducida por `tests/golden.test.ts`.

## Lo que el núcleo no pudo decir

La sección de República Dominicana de
[`docs/international.md`](../../docs/international.md) expone cada uno de
estos puntos como un cambio al núcleo. En resumen:

1. **Clearance.** `einvoicing` sólo puede decir «obligatorio» de un perfil
   construido sobre EN 16931, y no tiene manera de decir «válido sólo tras
   la validación previa de un tercero» ni «obligatorio en una fecha que
   depende del tamaño del contribuyente»; el paquete deja los campos vacíos
   y dice por qué en la referencia, igual que hacen los paquetes de México y
   Colombia para el CFDI y la factura electrónica.
2. **Un anexo que agrupa comprobantes por tipo de NCF.** La casilla 1 del
   Formulario IT-1 proviene, en el sistema real, de la casilla 11 del Anexo A
   — un resumen de comprobantes por tipo (crédito fiscal, consumo, nota de
   débito, nota de crédito, gubernamental, de exportación) que este
   repositorio no lleva.
3. **Retenciones sobre un formulario distinto.** El ITBIS retenido por
   tarjetas de crédito o débito (Norma 08-04), por el Estado, o el Impuesto
   Sobre la Renta retenido sobre honorarios y alquileres (Norma 02-05), se
   computan y se acreditan a través de mecanismos y formularios separados
   que este repositorio no modela.
4. **Un régimen sectorial que el núcleo no distingue.** Las tarifas del 9 %
   y del 8 % del sector hotelero de todo incluido (Ley No. 690-16) dependen
   de la clasificación del contribuyente y no de la naturaleza de la
   operación, algo que el vocabulario cerrado de `treatment` no nombra.

## Para un revisor

Lo primero que revisar contra la práctica: la distinción entre un bien
exportado (art. 342, tasa cero con derecho a deducción) y un bien exento
(art. 343, sin ese derecho), y si `export`/`exempt` es el par correcto para
ella; la elección de `2106` para la cuenta de espera y de `4203` para la de
redondeo, donde ningún catálogo oficial dominicano nombra ninguna de las
dos; la separación de las tasas de compra entre bienes, servicios e
importación frente a las casillas 22, 23 y 24; y si los estados abreviados
del Anexo A-1/B-1 deberían ceder ante una presentación completa bajo NIIF
para PYMES elaborada por un profesional.
