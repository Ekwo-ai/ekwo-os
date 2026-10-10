# República Dominicana

Todo lo que República Dominicana añade a Ekwo, como datos: un catálogo de
cuentas construido para calzar con los anexos de la Declaración Jurada del
Impuesto sobre la Renta, los diarios, el Impuesto sobre Transferencias de
Bienes Industrializados y Servicios (ITBIS) a sus tarifas general y reducida,
una tasa cero a la exportación y una exención local, los campos del
Formulario IT-1, un balance general y un estado de resultados mínimos, y las
menciones que una factura necesita. El formato es
[`docs/packs.md`](../../docs/packs.md).

**Estado: `community`.** Nadie que declare el ITBIS lo ha revisado. Las
cifras se reproducen contra un año de libros mediante `tests/golden.test.ts`,
lo que prueba que el paquete es coherente y no prueba que sea correcto.

**Idioma.** Las etiquetas están en español (`defaults.language: "es"`), y
`languages` está vacío. El Código Tributario y el instructivo del Formulario
IR-2 no tienen traducción oficial al inglés: una etiqueta en inglés sería una
traducción de Ekwo, no una redacción de la ley.

## Ekwo no emite el comprobante fiscal electrónico dominicano

**Un comprobante fiscal dominicano es un e-CF, y sólo ampara la operación una
vez que la Dirección General de Impuestos Internos (DGII) lo ha validado.**
La Ley No. 32-23, de Facturación Electrónica (16 de mayo de 2023), crea ese
régimen de validación previa (clearance) y lo hace obligatorio de forma
escalonada: doce meses desde su entrada en vigor para los Grandes
Contribuyentes Nacionales, veinticuatro para los Grandes Contribuyentes
Locales y Medianos, y treinta y seis para los Pequeños, Micro y no
Clasificados. La DGII publica el calendario final por categoría, sujeto a
prórrogas.

Ekwo no genera el XML del e-CF, no calcula su sello ni dialoga con la DGII o
con un proveedor tecnológico autorizado. Por eso:

- `einvoicing` no nombra **ni perfil ni fecha**: `profile` nombra un perfil
  construido sobre EN 16931, y el e-CF no lo es; el formato tampoco expresa
  «válido sólo tras la validación previa de un tercero» ni una obligación
  que depende del tamaño del contribuyente. Su referencia legal dice, en
  mayúsculas, que Ekwo no genera, no calcula el sello y no transmite un e-CF.
- Todo documento lleva la mención `ecf_not_assigned`: *este documento no es
  un e-CF; sólo el comprobante validado por la DGII ampara la operación para
  efectos tributarios.*
- El número de un documento en Ekwo es el consecutivo de la pieza contable,
  no el sello de validación.
- El Registro Nacional de Contribuyentes (RNC) no tiene un esquema ISO 6523
  registrado: `party_scheme` y `vat_scheme` quedan vacíos.

Lo que una empresa hace hoy: validar el comprobante a través de un proveedor
tecnológico autorizado o de la plataforma de la DGII, y registrar la
operación en Ekwo.

## Fuentes

Cada tasa, casilla, mención y estado lleva su propia `legal_reference` y la
clave del texto en que se apoya. El registro de `pack.json` lleva ocho
textos: el Título III del Código Tributario (Ley No. 11-92) que compila la
DGII; la Ley No. 253-12 que modificó sus tasas y exenciones; la ficha del
ITBIS y el Formulario IT-1 con su instructivo de llenado, de la DGII; el
instructivo de la Declaración Jurada del Impuesto sobre la Renta (IR-2) y sus
anexos A-1 y B-1; la resolución del Instituto de Contadores Públicos
Autorizados de la República Dominicana (ICPARD) que confirma la
implementación de las NIIF para PYMES; la Ley No. 32-23 de Facturación
Electrónica; y el portal de la DGII sobre el calendario de obligatoriedad del
e-CF.

## El catálogo de cuentas

**República Dominicana no impone un catálogo de cuentas único.** La Ley
General de las Sociedades Comerciales (Ley No. 479-08) no prescribe una
numeración contable, y desde que el ICPARD confirmó, mediante su Acta
22-2014, la implementación de las NIIF para PYMES a partir del 1 de enero de
2014, cada entidad define su propio catálogo bajo NIIF o NIIF para PYMES.

Este paquete usa una numeración propia — sin pretender ser oficial — cuyos
grandes grupos calzan con los renglones del Anexo A-1 (Balance General) y del
Anexo B-1 (Estado de Resultados) que la DGII exige con la IR-2 de toda
persona jurídica de manufactura, comercio o agropecuaria: el documento más
parecido a un formato oficial de estados financieros. No es una obligación
legal usar precisamente esta numeración.

Seleccionadas: caja y bancos, clientes, las cuentas de control del ITBIS
separadas entre cobrado y pagado y por tarifa, inventarios, los activos fijos
usuales y su depreciación acumulada, proveedores, retenciones de ISR y de la
Tesorería de la Seguridad Social (TSS) por pagar, capital y reservas,
resultados acumulados aparte del resultado del ejercicio, ingresos por clase,
el costo de venta y las compras de una empresa comercializadora, y los gastos
generales que necesita.

Cuatro decisiones:

- **Las cuentas de ITBIS separan lo cobrado de lo pagado, y por tarifa.**
  `2104` *Impuestos por Pagar* es el encabezado; `210401` y `210402` reciben
  el ITBIS de una venta, a la tarifa general y a la reducida; `210403`,
  `210404` y `210405` el ITBIS deducible de una compra de bienes, de
  servicios o de importación — la separación de las casillas 22, 23 y 24 del
  Formulario IT-1. Ninguna de las cinco es la cuenta de liquidación.
- **La declaración liquida a `210406`** *ITBIS por Pagar* (pasivo) **o a
  `120302`** *ITBIS Saldo a Favor* (activo). Ambas son conciliables
  (`reconcilable`), como clientes (`1201`) y proveedores (`2102`) — véase la
  nota sobre `reconcilable` en [`docs/packs.md`](../../docs/packs.md).
- **La cuenta de espera es `2106`** *Cuentas de Orden por Clasificar*: no
  existe una cuenta oficial para dinero recibido por cuenta de un tercero.
- **`4203`** *Ajuste por Redondeo*, bajo *Ingresos Financieros*, es la cuenta
  de redondeo: ningún texto dominicano la nombra.

## Los estados financieros

`DO-IR2-A1` (Balance General) y `DO-IR2-B1` (Estado de Resultados) no son la
presentación completa bajo NIIF para PYMES, cuyas notas y desagregación
pertenecen a un profesional. Leen los grandes grupos del catálogo en la forma
abreviada de los Anexos A-1 y B-1 de la IR-2: una línea por grupo, unos
pocos subtotales, y un solo resultado. `xbrl` queda vacío en todas partes:
no existe una taxonomía dominicana mapeada.

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

**La tarifa general es del 18 %, aunque el artículo 341 diga 16 %.** El
artículo 345 (modificado por la Ley No. 253-12) fija la tasa en 18 % para
2013 y 2014, y en 16 % a partir de 2015, condicionado a alcanzar la meta de
presión tributaria de la Estrategia Nacional de Desarrollo (párrafo I). La
ficha oficial del ITBIS de la DGII dice que la tasa «a partir del 2016 será
del 18 %»: la reducción condicionada nunca se activó, y el paquete declara la
tasa que la administración aplica hoy.

**La tarifa reducida del 16 % es otra cosa.** El párrafo II del artículo 345
fija, para una lista cerrada de bienes (lácteos, café, grasas y aceites
vegetales, azúcares, cacao y chocolate), una tabla de tasas que llegó al 16 %
en 2016 y se ha mantenido. El ejemplo del paquete es el azúcar (partida
arancelaria 17.01).

**Exento no es tasa cero.** Un bien exportado (art. 342) se declara
`export`, `vat_category: G`: tasa cero con derecho pleno a deducir y, si
procede, al reembolso del ITBIS adelantado. Un bien exento del artículo 343
(el ejemplo es el arroz, partida arancelaria 10.06) se declara `exempt`,
`vat_category: E`: no causa el impuesto y **no** da derecho a deducir lo
pagado en su producción o adquisición (art. 346, y la casilla 45 del
Formulario IT-1, ITBIS no deducible de productores de bienes o servicios
exentos).

**República Dominicana está fuera del sistema común de IVA de la Unión
Europea.** `supabase/seed/00_territories.sql` lleva una fila para `DO` con
`eu_vat_scope: none`. Por eso `exemption_code` queda vacío (el artículo va en
`legal_reference`), los tratamientos `intracom_*` nunca se usan, y
`vat_category` se declara sólo para quien lea el paquete.

**Bienes y servicios se separan del lado de la compra.** El Formulario IT-1
pide la base de una venta en una sola casilla por tarifa (11 o 12), pero
separa el ITBIS deducible de una compra local entre bienes (22) y servicios
(23), y las importaciones (24). Por eso hay tres códigos de compra al 18 %:
una tasa lleva una sola casilla.

**El Formulario IT-1 no tiene casilla de base de compra**, sólo el ITBIS
deducible por categoría (casillas 22 a 24). Los postings `base` de las tasas
de compra no llevan casilla; siguen siendo necesarios para calcular el
impuesto.

**Un servicio comprado a un proveedor del exterior no lleva ITBIS, y este
paquete no tiene código para él — por la ley, no por omisión.** El Código
Tributario, art. 335, grava la transferencia y la importación de bienes
industrializados y la prestación y locación de servicios; la importación que
grava es la de bienes, y ningún artículo hace contribuyente al comprador
dominicano de un servicio prestado desde el exterior por un no residente — una
suscripción de software, un alojamiento en la nube. La DGII lo responde así en
su portal de ayuda, citando los arts. 335 y 336. `pack.json` lo dice en
`not_taxed`. Lo que sí alcanza al pago es la retención del Impuesto Sobre la
Renta a los pagos al exterior (art. 305), con su comprobante de pagos al
exterior, fuera de este paquete. El Decreto 30-25, que obligaba a los
proveedores extranjeros de servicios digitales a percibir el ITBIS, fue
derogado en marzo de 2025 antes de entrar en vigor; en mayo de 2026 la DGII
anunció una nueva propuesta, que al 10 de octubre de 2026 este paquete no ha
encontrado publicada. La compra se registra sin código de impuesto.

**No aquí:** las retenciones — ReteISR sobre honorarios y alquileres
(Norma General 02-05), la retención del 2 % del ITBIS en pagos con tarjeta
de crédito o débito (Norma General 08-04), la retención del 100 % del ITBIS
que practican las entidades del Estado, y la retención del ISR sobre
dividendos, alquileres y honorarios de personas físicas — y las tarifas del
sector turístico de todo incluido de la Ley No. 690-16 (casillas 13, 14, 18
y 19 del Formulario IT-1, al 9 % y al 8 %), un régimen sectorial ajeno a una
comercializadora ordinaria. Una empresa sujeta a ellas necesita un
profesional.

## La declaración

`DO-ITBIS-IT1` es el Formulario IT-1, que se presenta y se paga
mensualmente — el Código Tributario no ofrece otra cadencia —, así que el
paquete declara `period_default: "month"` y las quince casillas que sus tasas
alcanzan. No se modelan el resumen de comprobantes por tipo de NCF del Anexo
A, las operaciones de constructoras y comisionistas, las retenciones
computables ni el saldo a favor del período anterior: la empresa los añade a
mano al declarar.

- **Plazo.** `day_of_month_after_period`, día 20: la ficha del ITBIS de la
  DGII fija la presentación y el pago dentro de los primeros veinte días del
  mes siguiente.
- **Redondeo.** Ningún texto citado exige redondear las casillas a una unidad
  más gruesa que el centavo; el paquete no declara `rounding` en
  `tax_report.json`.

## El año dorado (golden)

Una comercializadora dominicana, declarante mensual, enero y febrero de
2026: diez documentos y cinco pagos. Vende mercancía general al 18 %, azúcar
a la tarifa reducida del 16 %, exporta azúcar con tasa cero, y vende arroz
exento; compra mercancía general y un servicio de transporte a la tarifa
general, y arroz exento para su reventa; acredita parte de la venta del
18 %. En el segundo mes las compras superan las ventas, para ejercer un saldo
a favor (casilla 27) además de un saldo a pagar (casilla 26).

## Lo que el núcleo no pudo decir

Véase también
[`docs/international.md`](../../docs/international.md#what-the-packs-do-not-say-yet).

1. **Clearance.** `einvoicing` no puede decir «válido sólo tras la validación
   previa de un tercero» ni «obligatorio según el tamaño del contribuyente».
2. **Anexo A.** La casilla 1 del Formulario IT-1 proviene de la casilla 11
   del Anexo A, un resumen de comprobantes por tipo de NCF (crédito fiscal,
   consumo, nota de débito, nota de crédito, gubernamental, de exportación)
   que este repositorio no lleva.
3. **Retenciones.** Las de las Normas 08-04 y 02-05 y las del Estado se
   computan y acreditan por formularios separados que no se modelan.
4. **Régimen sectorial.** Las tarifas del 9 % y del 8 % de la Ley No. 690-16
   dependen de la clasificación del contribuyente, no de la operación, algo
   que el vocabulario cerrado de `treatment` no nombra.

## Para un revisor

Lo primero que revisar contra la práctica: la distinción entre un bien
exportado (art. 342, tasa cero con derecho a deducción) y un bien exento
(art. 343, sin ese derecho), y si `export`/`exempt` es el par correcto; la
elección de `2106` para la cuenta de espera y de `4203` para la de redondeo,
que ningún catálogo oficial nombra; la separación de las tasas de compra
entre bienes, servicios e importación frente a las casillas 22, 23 y 24; y si
los estados abreviados del Anexo A-1/B-1 deberían ceder ante una
presentación completa bajo NIIF para PYMES elaborada por un profesional.
