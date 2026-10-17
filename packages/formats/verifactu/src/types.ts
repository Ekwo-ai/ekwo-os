/**
 * The shapes this package reads and returns.
 *
 * A record is written from one posted document as the books hold it: one row
 * of `document_header`, the rows of `document_line_items` and the rows of
 * `document_tax_summary` in [Ekwo OS](https://github.com/Ekwo-ai/ekwo-os),
 * plus what only the invoicing system knows — when the record is generated,
 * which system generates it, and which record came before it in the chain.
 *
 * The rows arrive as `Row`, a record of columns, because that is what a
 * database read returns; the three interfaces below say which columns are
 * read and what each becomes in the record. A row that carries more is
 * accepted as it is, and nothing is ever filled in for a column that is
 * absent: what the record needs and the row does not say is named in
 * `violations`.
 */

/** A row as a database read returns it: columns by name. */
export type Row = Readonly<Record<string, unknown>>;

/** A `numeric` as it is read from the database. A string keeps every digit. */
export type Numeric = string | number;

/** ISO-8601 calendar date, `YYYY-MM-DD`. */
export type IsoDate = string;

/** The columns of `document_header` a record reads. */
export interface DocumentHeaderRow {
  /** `sale_invoice` or `sale_credit_note`. Anything else is refused: a record is kept by the issuer of a sale. */
  doc_type: string;
  /** `NumSerieFactura`: the series and the number, as one text. A document without one was never issued, and is refused. */
  number: string | null;
  /** `FechaExpedicionFactura`. */
  document_date: IsoDate;
  /** `FechaOperacion`, where it differs from the date of issue. */
  tax_point_date?: IsoDate | null;
  /** `FechaOperacion`, where there is no tax point date and it differs from the date of issue. */
  delivery_date?: IsoDate | null;
  /** The records carry euros: another currency is reported, not converted. */
  currency_code: string;
  /** Read for the cap of a simplified invoice. */
  amount_untaxed: Numeric;
  /** `CuotaTotal`. */
  amount_tax: Numeric;
  /** `ImporteTotal`. */
  amount_total: Numeric;
  /** `DescripcionOperacion`, where it is given. */
  note?: string | null;

  /** `NombreRazonEmisor`, where there is no legal name. */
  seller_name: string | null;
  /** `NombreRazonEmisor`. */
  seller_legal_name?: string | null;
  /** `IDEmisorFactura`: the NIF, with or without its `ES` prefix. */
  seller_vat_number?: string | null;

  /** `IDDestinatario/NombreRazon`. */
  buyer_name: string | null;
  /** `IDDestinatario/NIF` for a Spanish buyer, `IDDestinatario/IDOtro` (NIF-IVA) for one of another Member State. */
  buyer_vat_number?: string | null;
  /** Tells a Spanish NIF without its prefix from a foreign number. */
  buyer_country?: string | null;

  /**
   * Not in the view today. `R1` to `R4`: the article a credit note rectifies
   * under (list L2 of the AEAT). The books do not record why a credit note
   * was issued, and the four keys are four legal grounds, so none is
   * assumed: a credit note to an identified buyer without it is reported.
   */
  rectification_type?: string | null;
  /**
   * Not in the view today. The invoice a credit note rectifies, for
   * `FacturasRectificadas`: its number and its date of issue, as the record
   * of that invoice wrote them. `@ekwo-ai/peppol-ubl` calls the same fact
   * `precedingInvoice`; the core reads it from `documents.reversed_document_id`.
   */
  rectified_number?: string | null;
  rectified_date?: IsoDate | null;
}

/** The columns of `document_line_items` a record reads. */
export interface DocumentLineRow {
  /** `product` lines are what was sold; a section or a note is layout and is skipped. */
  line_type?: string | null;
  /** Joined into `DescripcionOperacion` where the header carries no note. */
  item_name: string | null;
}

/** The columns of `document_tax_summary` a record reads: one `DetalleDesglose` each. */
export interface DocumentTaxRow {
  /** EN 16931 category (UNTDID 5305), from which the qualification of the operation is derived. */
  vat_category: string | null;
  /** `TipoImpositivo`. */
  tax_rate?: Numeric | null;
  /** `BaseImponibleOimporteNoSujeto`. */
  base_amount: Numeric;
  /** `CuotaRepercutida`. */
  tax_charged: Numeric;
  /** VATEX code, from which the cause of an exemption is derived. */
  exemption_code?: string | null;

  // Not in the view today: the three keys of the AEAT for this tax, where the
  // pack carries them. Each one given wins over what is derived; each one the
  // category cannot decide on its own and the row does not give is reported.

  /** `Impuesto`, list L1: `01` IVA, `02` IPSI, `03` IGIC, `05` other. */
  aeat_tax?: string | null;
  /** `ClaveRegimen`, list L8A (IVA) or L8B (IGIC). */
  aeat_regime?: string | null;
  /** `CalificacionOperacion` (list L9, `S1` `S2` `N1` `N2`) or `OperacionExenta` (list L10, `E1` to `E8`). */
  aeat_qualification?: string | null;
}

/** The invoicing system that generates the record: `SistemaInformatico`. */
export interface InvoicingSystem {
  /** `NombreSistemaInformatico`, at most 30 characters. */
  name: string;
  /** `IdSistemaInformatico`: two characters, each a capital letter other than Ñ or a digit. */
  id: string;
  /** `Version`, at most 50 characters. */
  version: string;
  /** `NumeroInstalacion`: this installation, at most 100 characters. */
  installation: string;
  /** `SistemaInformatico/NombreRazon`: the producer of the system. */
  producerName: string;
  /** The producer's NIF, or the VAT number of another Member State (written as `IDOtro`, type `02`). */
  producerTaxId: string;
  /**
   * `TipoUsoPosibleSoloVerifactu`: whether the system can only work as
   * VERI*FACTU. A fact of the product, which the caller states; absent, it is
   * reported (1212) and not written.
   */
  verifactuOnly?: boolean;
  /** `TipoUsoPosibleMultiOT`: whether the system can keep the books of several taxpayers. Absent, reported (1213). */
  multipleTaxpayers?: boolean;
  /**
   * `IndicadorMultiplesOT`: whether, at the moment of the record, it does. The
   * AEAT wants it obtained by the system itself from how many taxpayers it
   * holds, so it is the caller's to count. Absent, reported (1226).
   */
  multipleTaxpayersNow?: boolean;
}

/** The record that came before, in this system: `Encadenamiento/RegistroAnterior`. */
export interface PreviousRecord {
  /** `IDEmisorFactura`: the NIF, with or without its `ES` prefix. */
  taxId: string;
  /** The series, written before `number` with nothing between: pass `''` where `number` already holds both. */
  series: string;
  number: string;
  /** `FechaExpedicionFactura`, ISO 8601. */
  issuedOn: IsoDate;
  /** `Huella` of that record: 64 hexadecimal digits in capitals. */
  hash: string;
}

/** One record to write. */
export interface FiscalRecordInput {
  header: Row;
  lines: readonly Row[];
  taxes: readonly Row[];
  /** `alta` when the invoice is issued, `anulacion` when its record is cancelled. */
  kind: 'alta' | 'anulacion';
  /** `FechaHoraHusoGenRegistro`: ISO 8601 with its offset, `2024-01-01T19:20:30+01:00`. */
  generatedAt: string;
  system: InvoicingSystem;
  /** `null` for the first record of the system: `PrimerRegistro` is `S` and the previous fingerprint is empty. */
  previous: PreviousRecord | null;
}

/** A rule of the AEAT this record breaks, or something the record needs and the row does not carry. */
export interface Violation {
  /**
   * The AEAT's own error code (`errores.properties`) where it has one —
   * `1189`, `2005` — which is what the AEAT answers with, and the only name
   * worth branching on. What the AEAT cannot see, because it is missing from
   * the books before it is missing from the record, is `input:<what>`.
   */
  code: string;
  /** What is wrong, in a sentence. */
  message: string;
  /**
   * The AEAT's category for its codes: `rejected` (the record is refused),
   * `accepted` (accepted with errors, to be corrected) — and `input` for what
   * the AEAT never sees.
   */
  severity: 'rejected' | 'accepted' | 'input';
}

/** A written record. */
export interface WrittenRecord {
  /** The XML, as text: one `RegistroAlta` or `RegistroAnulacion`, UTF-8. */
  content: string;
  filename: string;
  mediaType: string;
  /** Empty is the only state to chain and to send in. */
  violations: Violation[];
}

/** Where the QR code of the invoice points: VERI*FACTU records sent (`realtime`, `batch`) or kept (`none`). */
export type SubmissionMode = 'realtime' | 'batch' | 'none';

/** Which AEAT service the URL points to. There is a production and a test one. */
export type AeatEnvironment = 'production' | 'test';

export interface FiscalisationFormat {
  format: 'verifactu';
  brick: '@ekwo-ai/verifactu';
  specification: string;
  hashInput(input: FiscalRecordInput): string;
  hash(input: FiscalRecordInput): string;
  write(input: FiscalRecordInput): WrittenRecord;
  verificationUrl(input: FiscalRecordInput, mode: SubmissionMode, environment?: AeatEnvironment): string;
}
