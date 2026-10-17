# `@ekwo-ai/verifactu`

Spain's **VERI\*FACTU invoicing record** — the *registro de facturación* an
invoicing system keeps for every invoice it issues — in TypeScript, with no
dependencies: the XML of the AEAT's schema, the SHA-256 fingerprint that
chains each record to the one before, and the URL the QR code of the invoice
carries.

Give it a posted document as the books hold it, the system that generates the
record and the record before it, and it gives you the record, its fingerprint,
and every rule of the AEAT the record breaks — named by the AEAT's own error
code.

```ts
import { VERIFACTU } from '@ekwo-ai/verifactu';

const input = { header, lines, taxes, kind: 'alta', generatedAt, system, previous };

const { content, filename, violations } = VERIFACTU.write(input);
const huella = VERIFACTU.hash(input);                        // 64 hexadecimal capitals
const qr = VERIFACTU.verificationUrl(input, 'realtime');      // what the QR code encodes
```

`header`, `lines` and `taxes` are one row of `document_header`, the rows of
`document_line_items` and the rows of `document_tax_summary` in
[Ekwo OS](https://github.com/Ekwo-ai/ekwo-os). They are declared in this
package's own types, so any invoicing system that can produce the same rows
can use it.

Writing the record is all it does. **It keeps no chain**: which record came
before is the caller's to say, in `previous`, and the caller stores the
fingerprint this package returns. **It sends nothing**: the envelope
(`RegFactuSistemaFacturacion` and its `Cabecera`), the SOAP call, the
certificate, the AEAT's flow control and the answers belong to a transport.
The same split as `@ekwo-ai/peppol-ubl`, which writes the UBL and leaves the
access point to the host.

## The interface

```ts
interface FiscalRecordInput {
  header: Row; lines: Row[]; taxes: Row[];
  kind: 'alta' | 'anulacion';
  generatedAt: string;            // ISO 8601 with its offset: 2026-03-02T10:15:00+01:00
  system: { name; id; version; installation; producerName; producerTaxId;
            verifactuOnly?; multipleTaxpayers?; multipleTaxpayersNow? };
  previous: { taxId; series; number; issuedOn; hash } | null;   // null: the first record
}

interface FiscalisationFormat {
  format: 'verifactu'; brick: '@ekwo-ai/verifactu'; specification: string;
  hashInput(input): string;       // the exact text the AEAT hashes
  hash(input): string;            // its SHA-256, hexadecimal, capitals
  write(input): { content; filename; mediaType; violations };
  verificationUrl(input, mode: 'realtime' | 'batch' | 'none', environment = 'production'): string;
}
```

- **`kind: 'alta'`** writes a `RegistroAlta`: the invoice or credit note as
  issued. **`kind: 'anulacion'`** writes a `RegistroAnulacion` of the same
  document — the header is the document whose record is cancelled.
- **`hashInput`** is the concatenation the AEAT specifies, and **`hash`** its
  fingerprint. `write` puts that fingerprint in `Huella`, so a record always
  carries the fingerprint of what it says.
- **`verificationUrl`** is the URL of the QR code of the invoice:
  `ValidarQR` where the system sends its records (`realtime` and `batch` are
  two ways of sending, and both are VERI\*FACTU), `ValidarQRNoVerifactu` where
  it keeps them (`none`). Every invoice carries a QR code, in either mode. It is
  always the URL of the invoice, whichever record is being written.
- **`system.verifactuOnly`, `multipleTaxpayers`, `multipleTaxpayersNow`** are
  `TipoUsoPosibleSoloVerifactu`, `TipoUsoPosibleMultiOT` and
  `IndicadorMultiplesOT`, which the schema requires and which are facts of the
  product and of the installation; they are optional in the type so that the
  interface keeps its shape, and reported (1212, 1213, 1226) when absent.

A method throws a `VerifactuError` for what makes a record absurd: no
document, a document that is not a sale, never numbered or dated, an amount
that is not a number. Everything else comes back from `write` in `violations`,
beside a record that says what it was given.

## The figures are the books' figures

Nothing is recomputed. Bases, taxes and totals are written as they were
posted, with two decimals, and where they do not add up the AEAT's rule is
named rather than the figure corrected — with the AEAT's own tolerance of
10.00 where it publishes one (1142, 2005, 2006). No figure passes through a
`number`: amounts arrive as the text Postgres prints a `numeric` as, are
compared as exact decimals on `bigint`, and leave as the same digits.

One transformation is made, because the AEAT asks for it: **a credit note is
a rectification by difference** (`TipoRectificativa` `I`), and its figures are
written negative — the books hold them positive, on a document whose type says
it is a credit. The AEAT's own example is a rectification "por diferencias"
with a tax of `-110` (FAQ for developers, question 27).

## Violations

Each violation is `{ code, message, severity }`:

- `code` is **the AEAT's error code** from `errores.properties` — `1189`,
  `2005` — where the AEAT has a rule for it; the message starts with the
  AEAT's own sentence, followed by what this record holds. `severity` is the
  AEAT's category: `rejected` (the record is refused) or `accepted` (accepted
  with errors, to be corrected).
- What the AEAT never sees, because it is missing from the books before it is
  missing from the record, is **`input:<what>`**, severity `input`:
  `input:currency`, `input:aeat_qualification`, `input:rectification_type`.

A record that breaks a rule leaves out what it does not know, and the schema
refuses it too. **Empty `violations` is the only state to chain and send in.**

| Code | What is checked |
|---|---|
| 4102 | A required value the books do not hold: the seller's NIF or name, the description, the buyer's name, the breakdown |
| 4113 | More than 12 `DetalleDesglose` |
| 1100 | A text or an amount longer than the schema allows |
| 1104, 1130 | `NumSerieFactura`: at most 60 characters, printable ASCII, none of `" ' < > =` |
| 1112, 1152 | The date of issue: not after the day the record is generated, not before 28 October 2024 |
| 1146, 1173 | The date of the operation: not after the date of issue (regimes 14 and 15 are never written), not after today |
| 1219 | `IDEmisorFactura` is not a NIF |
| 1102 | A buyer whose identifier is neither a NIF nor a VAT number of another Member State |
| 1189, 1190 | `Destinatarios` required for F1 and R1–R4, forbidden for F2 and R5 |
| 1150 | A simplified invoice (F2) above 3,000.00 (+10.00) |
| 1124, 1132, 1194, 1235 | The IVA rates of `S1`, and the dates of the 5 %, 2 % and 7.5 % rates |
| 1142, 1143, 1208 | `CuotaRepercutida` against base × rate (±10.00), its sign, its presence — not checked by difference, as the AEAT says |
| 1198, 1207, 1237, 1238 | A tax charged on `S2`, `N1`/`N2` or an exemption |
| 1181, 1182, 1218, 1246, 1199, 1252, 1286 | The keys a row carries, against lists L1, L8A/L8B, L9, L10 and the rules between them |
| 2005, 2006 | `ImporteTotal` and `CuotaTotal` against the details (±10.00), except under regimes 03, 05, 06, 08, 09 |
| 1266, 1267 | `CuotaTotal`, `ImporteTotal` beyond twelve digits |
| 1244 | `FechaHoraHusoGenRegistro` is not `YYYY-MM-DDThh:mm:ss±hh:mm` |
| 1176, 1177, 1179, 1220, 1212, 1213, 1226 | `SistemaInformatico` |
| 1269, 1174, 1175, 1291, 2002, 2003 | `RegistroAnterior`, and its fingerprint: 64 hexadecimal capitals |

What only the AEAT can check is not checked here: that a NIF is in its census
(1109, 4107, 2001), that a record is not a duplicate (3000), that the first
record of a system really is the first (2007), that the fingerprint is the one
it computes (2000) — this package computes it by the specification, and its
three examples are its tests.

## From the rows to the record

### `document_header`

| Column | Becomes |
|---|---|
| `seller_vat_number` | `IDEmisorFactura`: the NIF, its `ES` prefix removed where it has one |
| `number` | `NumSerieFactura`, as one text: series and number |
| `document_date` | `FechaExpedicionFactura`, `DD-MM-YYYY` |
| `tax_point_date`, else `delivery_date` | `FechaOperacion`, only where it differs from the date of issue |
| `seller_legal_name`, else `seller_name` | `NombreRazonEmisor` |
| `note`, else the names of the `product` lines joined by `; ` | `DescripcionOperacion` |
| `buyer_name`, `buyer_vat_number`, `buyer_country` | `IDDestinatario`: `NIF` for a Spanish buyer (an `ES` prefix, or `buyer_country` `ES`), `IDOtro` with `IDType` `02` for a VAT number of another Member State |
| `amount_tax`, `amount_total` | `CuotaTotal`, `ImporteTotal`; `Macrodato` `S` from 100,000,000.00 |
| `doc_type` | `TipoFactura`: see below |
| `currency_code` | Checked: the records carry euros |

**`TipoFactura`.** An invoice with a buyer identified by a tax number is `F1`;
one without is `F2`, which the AEAT's list L2 defines as both the simplified
invoice and the invoice without the buyer's identification (art. 6.1.d of the
Real Decreto 1619/2012). A credit note to a buyer not identified is `R5`, the
rectification of a simplified invoice. A credit note to an identified buyer is
`R1`, `R2`, `R3` or `R4` by the article of the LIVA it rectifies under — four
legal grounds the books do not record — so it reads `rectification_type`, and
without it reports `input:rectification_type` and writes no `TipoFactura`. `F3`
(an invoice replacing simplified ones) is never written: the books do not hold
the invoices it would replace.

**`FacturasRectificadas`** is written from `rectified_number` and
`rectified_date` where the row carries them. The AEAT makes the group optional
(validations, 3.1.3.4), so its absence is no violation.

### `document_tax_summary`: the breakdown

One `DetalleDesglose` per row. `Impuesto` is `01` (IVA) and `ClaveRegimen` `01`
(the general regime) unless the row carries `aeat_tax` and `aeat_regime`; the
qualification is derived from the EN 16931 category and the VATEX code where
they decide it alone, and read from `aeat_qualification` where the row carries
it:

| Category | VATEX | `ClaveRegimen` | Written | Pack tax (`packs/es/taxes.json`) |
|---|---|---|---|---|
| `S` | — | 01 | `S1`, `TipoImpositivo`, `CuotaRepercutida` | `ES-S-21`, `ES-S-10`, `ES-S-04`… |
| `Z` | — | 01 | `S1` at 0 | `ES-S-00-ALIM` |
| `AE` | `VATEX-EU-AE` | 01 | `S2`, rate and tax 0 (validations 15.4) | `ES-S-ISP` (art. 84.Uno.2.º) |
| `E` | `VATEX-EU-132` | 01 | `OperacionExenta` `E1` (art. 20 LIVA) | `ES-S-EXE` |
| `G` | `VATEX-EU-G` | 02 | `OperacionExenta` `E2` (art. 21 LIVA; validations 15.6.1) | `ES-S-EXP` |
| `K` | `VATEX-EU-IC` | 01 | **asked of the row**: `E5` for goods (art. 25), `N2` for services (art. 69) | `ES-S-ICG`, `ES-S-ICS` |
| `O` | `VATEX-EU-O` | 01 | **asked of the row**: `N2` by the rules of place, `N1` otherwise | `ES-S-NS` (`N2`) |

`BaseImponibleOimporteNoSujeto` is `base_amount`, `CuotaRepercutida`
`tax_charged`, `TipoImpositivo` `tax_rate`; an exempt or not subject detail
carries neither rate nor tax, as the AEAT requires (1237, 1238).

**What the row must carry for the mapping to be complete** — none of it in the
views today; the core can pass it from the pack, as the block proposed below
does:

- `aeat_qualification` on the two Spanish taxes whose category does not decide
  (`ES-S-ICG` → `E5`, `ES-S-ICS` → `N2`), and on `ES-S-NS` (`N2`);
- `aeat_regime` for a company under a special regime — the cash criterion
  (`07`), REBU (`03`), the equivalence surcharge (`18`), agriculture (`19`)… —
  which is a fact of the company the books do not record;
- `rectification_type` (`R1`–`R4`) and `rectified_number`, `rectified_date`
  on a credit note.

## Named gaps

What this package does not do, because it could not be sourced or because it
is not a record's to do:

- **The check character of a NIF** is not verified: the AEAT verifies a NIF
  against its census, and this package has no published algorithm to cite.
  Only the shape is checked: nine characters.
- **IGIC and IPSI** are written only from the keys the row carries; their own
  rates and rules are not checked. Canary and Ceuta–Melilla taxes have no pack
  yet.
- **The equivalence surcharge** (`TipoRecargoEquivalencia`,
  `CuotaRecargoEquivalencia`) and `BaseImponibleACoste` are never written: the
  views carry no such column.
- **A buyer outside the Member States** cannot be written: its `IDType` (03
  passport, 04 identity document of the country, 05 certificate of residence,
  06 other) is the document the buyer showed, which the books do not hold. It
  is reported (1102).
- **Corrections** (`Subsanacion`, `RechazoPrevio`, `SinRegistroPrevio`), the
  **third party or buyer as issuer** (`EmitidaPorTerceroODestinatario`,
  `Tercero`, `GeneradoPor`), **coupons** (`Cupon`), billing agreements
  (`NumRegistroAcuerdoFacturacion`, `IdAcuerdoSistemaInformatico`) and
  `RefExterna` are never written.
- **The event records** (`RegistroEvento`) of a system that does not send, and
  **the XAdES signature** (`ds:Signature`) such a system's records require, are
  not written. A system that sends (VERI\*FACTU) needs neither.
- **The 2 % and 7.5 % rates outside their window** share two codes of identical
  text in `errores.properties` (1235, 1236); both are reported as 1235.
- **`FechaHoraHusoGenRegistro`** must be given with a numeric offset
  (`+01:00`), as in every example of the AEAT; `Z` is reported (1244) rather
  than rewritten.
- **The previous record's number** is `series` followed by `number`, with
  nothing between: the record before wrote one text, and the caller holds it.

## Sources

Read on 17 October 2026, on the AEAT's electronic office, *IVA › Sistemas
Informáticos de Facturación y Sistemas VERI\*FACTU › Información técnica*
(<https://sede.agenciatributaria.gob.es/Sede/iva/sistemas-informaticos-facturacion-verifactu/informacion-tecnica.html>):

- **Schemas**: `SuministroInformacion.xsd`, `SuministroLR.xsd`,
  `RespuestaSuministro.xsd`, `ConsultaLR.xsd` and `SistemaFacturacion.wsdl`,
  <https://www2.agenciatributaria.gob.es/static_files/common/internet/dep/aplicaciones/es/aeat/tikeV1.0/cont/ws/>.
  The first two are kept unmodified under `test/xsd/`, with their checksums.
- ***Detalle de las especificaciones técnicas para generación de la huella o
  hash de los registros de facturación***, version 0.1.2, 27 August 2024,
  <https://www.agenciatributaria.es/static_files/AEAT_Desarrolladores/EEDD/IVA/VERI-FACTU/Veri-Factu_especificaciones_huella_hash_registros.pdf>
  — the fields, their order, the trimming, the empty previous fingerprint,
  the output in hexadecimal capitals; its three examples are
  `test/hash.test.ts`.
- ***Detalle de las especificaciones técnicas del código «QR» de la factura y
  de la «URL» del servicio de cotejo o remisión de información por parte del
  receptor de la factura***, version 0.5.0, 10 December 2025,
  <https://www.agenciatributaria.es/static_files/AEAT_Desarrolladores/EEDD/IVA/VERI-FACTU/DetalleEspecificacTecnCodigoQRfactura.pdf>
  — the services, the four parameters, the URL encoding of its Java example;
  its URLs are `test/qr.test.ts`.
- ***Validaciones. Sistemas Informáticos de Facturación y Sistemas
  VERI\*FACTU***, version 1.2.2, 8 April 2026,
  <https://www.agenciatributaria.es/static_files/AEAT_Desarrolladores/EEDD/IVA/VERI-FACTU/Validaciones_Errores_Veri-Factu.pdf>
  — the rules of section 3, the clarifications of N1/N2 and E1–E6 of section 5.
- **The list of error codes**, `errores.properties`,
  <https://www2.agenciatributaria.gob.es/static_files/common/internet/dep/aplicaciones/es/aeat/tikeV1.0/cont/ws/errores.properties>
  (ISO-8859-1) — every code and sentence of `AEAT_ERRORS`.
- ***Diseño de registros*** (`DsRegistroVeriFactu.xlsx`), version 1.0, the
  official version after the Orden HAC/1177/2024,
  <https://www.agenciatributaria.es/static_files/AEAT_Desarrolladores/EEDD/IVA/VERI-FACTU/DsRegistroVeriFactu.xlsx>
  — the meaning of every field and the lists L1 to L17 (`TipoFactura` L2,
  `ClaveRegimen` L8A/L8B, `CalificacionOperacion` L9, `OperacionExenta` L10,
  `TipoHuella` L12, `IDVersion` L15).
- ***Sistemas Informáticos de Facturación — descripción de los servicios
  web***, version 1.0.3, 28 July 2025,
  <https://www.agenciatributaria.es/static_files/AEAT_Desarrolladores/EEDD/IVA/VERI-FACTU/Veri-Factu_Descripcion_SWeb.pdf>
  — the envelope and the flow control this package leaves to the sender.
- ***Aclaraciones a dudas de los desarrolladores***, version 1.3, 4 December
  2025,
  <https://sede.agenciatributaria.gob.es/static_files/AEAT_Desarrolladores/EEDD/IVA/VERI-FACTU/FAQs-Desarrolladores.pdf>
  — question 27, a rectification by difference with negative figures.
- **The law**: Real Decreto 1007/2023, of 5 December (the regulation); Orden
  HAC/1177/2024, of 17 October, BOE-A-2024-22138 (the technical
  specifications, in force since 28 October 2024); Real Decreto-ley 15/2025,
  BOE-A-2025-24446, which postpones the obligation to 1 January 2027 for
  corporate income tax payers and to 1 July 2027 for the others (read through
  secondary sources, not in the BOE itself).
- FIPS 180-4 (SHA-256); W3C, `xmldsig-core-schema.xsd`, imported by the AEAT's
  schema.

## Licence

MIT. The files under `test/xsd/` are the AEAT's and the W3C's, kept as
published, are fixtures of the tests, and are not part of the published
package.
