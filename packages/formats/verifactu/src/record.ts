/**
 * From the rows of the books to the record, every value as the text the XML
 * will carry.
 *
 * The model is built once and read twice: by the writer, which prints it, and
 * by the fingerprint, which concatenates some of its fields. The two read the
 * same text, so the `Huella` of a record is always the fingerprint of what the
 * record says.
 *
 * Nothing is recomputed and nothing is guessed. A figure is written as it was
 * posted — negated for a credit note, which the AEAT wants by difference — and
 * where it does not add up, the AEAT's own rule is reported beside it. A value
 * the record needs and the books do not hold is absent from the record, and
 * named.
 */

import {
  AEAT_ERRORS,
  CALIFICACION,
  CLAVE_REGIMEN_IGIC,
  CLAVE_REGIMEN_IPSI,
  CLAVE_REGIMEN_IVA,
  IMPUESTO,
  NIF_IVA_PREFIXES,
  OPERACION_EXENTA,
  OPERACION_EXENTA_IGIC,
  RECTIFYING_TYPES,
  type AeatErrorCode,
} from './codes.js';
import { type Decimal, abs, compare, formatDecimal, isZero, multiply, parseDecimal, subtract, sum } from './decimal.js';
import type { FiscalRecordInput, InvoicingSystem, Row, Violation } from './types.js';

/** What makes a record absurd rather than wrong: there is nothing to hang a violation on. */
export class VerifactuError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'VerifactuError';
  }
}

/** A party identified by a Spanish NIF, or by `IDOtro`. */
export type Identifier = { nif: string } | { country: string | null; type: string; id: string };

export interface DetailModel {
  tax: string;
  regime: string | null;
  /** `CalificacionOperacion`, or null where the operation is exempt or unknown. */
  qualification: string | null;
  /** `OperacionExenta`, or null. */
  exemption: string | null;
  rate: string | null;
  base: string;
  quota: string | null;
}

export interface SystemModel {
  producerName: string;
  producer: Identifier;
  name: string;
  id: string;
  version: string;
  installation: string;
  verifactuOnly: string | null;
  multipleTaxpayers: string | null;
  multipleTaxpayersNow: string | null;
}

export interface ChainModel {
  /** Null for the first record: `PrimerRegistro` is `S`. */
  previous: { issuer: string; number: string; issued: string; hash: string } | null;
}

interface CommonModel {
  /** `IDEmisorFactura` (or `…Anulada`): the NIF. */
  issuer: string;
  /** `NumSerieFactura` (or `…Anulada`). */
  number: string;
  /** `FechaExpedicionFactura` (or `…Anulada`), `DD-MM-YYYY`. */
  issued: string;
  chain: ChainModel;
  system: SystemModel;
  /** `FechaHoraHusoGenRegistro`, as given. */
  generatedAt: string;
}

export interface AltaModel extends CommonModel {
  kind: 'alta';
  issuerName: string;
  /** `TipoFactura`, or null where the books do not say which. */
  invoiceType: string | null;
  /** `TipoRectificativa`: `I`, by difference, for every credit note. */
  rectificationKind: string | null;
  rectified: { issuer: string; number: string; issued: string } | null;
  operationDate: string | null;
  description: string;
  macrodato: boolean;
  recipient: { name: string; identifier: Identifier } | null;
  details: DetailModel[];
  totalTax: string;
  total: string;
}

export interface AnulacionModel extends CommonModel {
  kind: 'anulacion';
}

export type RecordModel = AltaModel | AnulacionModel;

// --- reading a row -----------------------------------------------------------

function text(row: Row, column: string): string | null {
  const value = row[column];
  if (value === null || value === undefined) return null;
  const out = String(value).trim();
  return out === '' ? null : out;
}

function decimal(row: Row, column: string, what: string): Decimal {
  const value = row[column];
  const parsed = parseDecimal(typeof value === 'string' || typeof value === 'number' ? value : null);
  if (parsed === null) throw new VerifactuError(`${what} is not a decimal: ${String(value)}`);
  return parsed;
}

function optionalDecimal(row: Row, column: string, what: string): Decimal | null {
  return row[column] === null || row[column] === undefined ? null : decimal(row, column, what);
}

const ISO_DATE = /^(\d{4})-(\d{2})-(\d{2})$/;

function isoDate(value: string | null, what: string): string | null {
  if (value === null) return null;
  const day = value.slice(0, 10);
  const match = ISO_DATE.exec(day);
  if (!match) throw new VerifactuError(`${what} is not a date: ${value}`);
  const date = new Date(`${day}T00:00:00Z`);
  if (Number.isNaN(date.getTime()) || date.toISOString().slice(0, 10) !== day) {
    throw new VerifactuError(`${what} is not a date: ${value}`);
  }
  return day;
}

/** `YYYY-MM-DD` as the records write a date: `DD-MM-YYYY`. */
export function aeatDate(iso: string): string {
  return `${iso.slice(8, 10)}-${iso.slice(5, 7)}-${iso.slice(0, 4)}`;
}

const negate = (a: Decimal): Decimal => ({ units: -a.units, scale: a.scale });
const constant = (value: string): Decimal => parseDecimal(value) as Decimal;
const TEN = constant('10');

// --- the checks ----------------------------------------------------------------

class Findings {
  readonly list: Violation[] = [];

  aeat(code: AeatErrorCode, detail: string): void {
    const [severity, sentence] = AEAT_ERRORS[code];
    this.list.push({ code, message: `${sentence} ${detail}`, severity });
  }

  input(what: string, message: string): void {
    this.list.push({ code: `input:${what}`, message, severity: 'input' });
  }
}

/**
 * The NIF of a Spanish party: nine characters, with the `ES` of its VAT number
 * removed where it has one. The check character is not verified here: the
 * AEAT checks the NIF against its census (1109, 4107), which is the only test
 * that matters.
 */
function spanishNif(value: string): string | null {
  const compact = value.toUpperCase();
  if (/^ES[0-9A-Z]{9}$/.test(compact)) return compact.slice(2);
  if (/^[0-9A-Z]{9}$/.test(compact)) return compact;
  return null;
}

/** A taxpayer of another Member State, by the prefix of its VAT number. */
function nifIva(value: string): string | null {
  const compact = value.toUpperCase();
  const prefix = compact.slice(0, 2);
  return (NIF_IVA_PREFIXES as readonly string[]).includes(prefix) && compact.length > 2 ? compact : null;
}

/** Characters `NumSerieFactura` may hold: printable ASCII, without `"`, `'`, `<`, `>` and `=` (3.1.3.1). */
const NUMBER_CHARACTERS = /^[\x20-\x7e]+$/;
const NUMBER_FORBIDDEN = /["'<>=]/;

function checkNumber(number: string, field: string, findings: Findings): void {
  if (number.length > 60) findings.aeat('1104', `${field} has ${number.length} characters, and holds at most 60.`);
  if (!NUMBER_CHARACTERS.test(number) || NUMBER_FORBIDDEN.test(number)) {
    findings.aeat('1130', `${field} "${number}" holds a character outside printable ASCII, or one of " ' < > =.`);
  }
}

/** An amount as `ImporteSgn12.2Type` writes it: at most twelve digits before the point and two after. */
function amount(value: Decimal, field: string, findings: Findings, code: AeatErrorCode = '1100'): string {
  const written = formatDecimal(value, 2);
  if (!/^-?\d{1,12}(\.\d{1,2})?$/.test(written)) {
    findings.aeat(code, `${field} is ${written}: an amount has at most twelve digits before the point and two after.`);
  }
  return written;
}

const FECHA_HORA_HUSO = /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[+-]\d{2}:\d{2}$/;

function checkGeneratedAt(value: string, findings: Findings): void {
  if (!FECHA_HORA_HUSO.test(value) || Number.isNaN(new Date(value).getTime())) {
    findings.aeat('1244', `"${value}" is not YYYY-MM-DDThh:mm:ss followed by the offset of the time zone, as 2024-01-01T19:20:30+01:00.`);
  }
}

function system(input: InvoicingSystem | undefined, findings: Findings): SystemModel {
  const given = input ?? ({} as Partial<InvoicingSystem>);
  const producerTaxId = (given.producerTaxId ?? '').trim();
  let producer: Identifier;
  const nif = spanishNif(producerTaxId);
  const foreign = nif === null ? nifIva(producerTaxId) : null;
  if (nif !== null) producer = { nif };
  else if (foreign !== null) producer = { country: null, type: '02', id: foreign };
  else {
    findings.aeat('1176', `The producer's tax identifier "${producerTaxId}" is neither a Spanish NIF nor the VAT number of another Member State.`);
    producer = { nif: producerTaxId };
  }
  const producerName = (given.producerName ?? '').trim();
  if (producerName === '' || producerName.length > 120) {
    findings.aeat('1179', 'The producer\'s name (NombreRazon) is required, and holds at most 120 characters.');
  }
  const name = (given.name ?? '').trim();
  if (name === '' || name.length > 30) {
    findings.aeat('1220', 'NombreSistemaInformatico is required, and holds at most 30 characters.');
  }
  const id = (given.id ?? '').trim();
  if (!/^[0-9A-Z]{2}$/.test(id) || id.includes('Ñ')) {
    findings.aeat('1177', `IdSistemaInformatico "${id}" must be two characters, each a capital letter other than Ñ or a digit.`);
  }
  const version = (given.version ?? '').trim();
  if (version === '' || version.length > 50) findings.aeat('1179', 'Version is required, and holds at most 50 characters.');
  const installation = (given.installation ?? '').trim();
  if (installation === '' || installation.length > 100) {
    findings.aeat('1179', 'NumeroInstalacion is required, and holds at most 100 characters.');
  }
  const flag = (value: boolean | undefined, code: AeatErrorCode, field: string): string | null => {
    if (value === true) return 'S';
    if (value === false) return 'N';
    findings.aeat(code, `${field} is a fact of the invoicing system the caller states, and none was given.`);
    return null;
  };
  return {
    producerName,
    producer,
    name,
    id,
    version,
    installation,
    verifactuOnly: flag(given.verifactuOnly, '1212', 'TipoUsoPosibleSoloVerifactu'),
    multipleTaxpayers: flag(given.multipleTaxpayers, '1213', 'TipoUsoPosibleMultiOT'),
    multipleTaxpayersNow: flag(given.multipleTaxpayersNow, '1226', 'IndicadorMultiplesOT'),
  };
}

function chain(input: FiscalRecordInput, findings: Findings): ChainModel {
  const previous = input.previous;
  if (previous === null || previous === undefined) return { previous: null };
  const issuer = spanishNif((previous.taxId ?? '').trim());
  if (issuer === null) findings.aeat('1269', `The NIF of the previous record, "${previous.taxId}", is not a NIF.`);
  const number = `${previous.series ?? ''}${previous.number ?? ''}`.trim();
  if (number === '') findings.aeat('1175', 'The previous record has no number.');
  else checkNumber(number, 'The number of the previous record', findings);
  let issued = '';
  try {
    const day = isoDate((previous.issuedOn ?? '').trim() || null, 'the date of the previous record');
    if (day === null) findings.aeat('1174', 'The previous record has no date of issue.');
    else issued = aeatDate(day);
  } catch {
    findings.aeat('1174', `The date of the previous record, "${previous.issuedOn}", is not a date.`);
  }
  const hash = (previous.hash ?? '').trim();
  if (hash.length !== 64) findings.aeat('2002', `The previous fingerprint has ${hash.length} characters, not 64.`);
  else if (!/^[0-9A-Z]+$/.test(hash)) findings.aeat('1291', 'The previous fingerprint holds a character that is neither a digit nor a capital letter.');
  else if (!/^[0-9A-F]{64}$/.test(hash)) findings.aeat('2003', 'The previous fingerprint is not 64 hexadecimal digits in capitals.');
  return { previous: { issuer: issuer ?? (previous.taxId ?? '').trim(), number, issued, hash } };
}

// --- the tax breakdown -------------------------------------------------------

/**
 * What a row of `document_tax_summary` says of the AEAT's three keys, derived
 * from its EN 16931 category and its VATEX code where they decide it alone,
 * and read from the row where it carries them.
 *
 * - `S`: subject and not exempt, without reverse charge — `S1`, regime `01`.
 * - `Z`: the same at a rate of zero, which the AEAT lists among the rates of
 *   `S1` (15.1) — the pack's `ES-S-00-ALIM`.
 * - `AE`: subject with reverse charge — `S2`, regime `01`, with a rate and a
 *   tax of zero (15.4) — the pack's `ES-S-ISP`, art. 84.Uno.2.º LIVA.
 * - `E` with `VATEX-EU-132`: exempt under article 20 of the LIVA — `E1` — the
 *   pack's `ES-S-EXE`, whose legal reference is that article.
 * - `G` with `VATEX-EU-G`: an export, exempt under article 21 — regime `02`,
 *   `E2` — the pack's `ES-S-EXP`. The validations allow nothing but an
 *   exemption under regime `02` (15.6.1), and no `E2` under regime `01` (15.5).
 *
 * Two categories do not decide: `K` with `VATEX-EU-IC` is an exempt supply of
 * goods to another Member State (`E5`, art. 25) or a service located there
 * (`N2`, not subject by the rules of place); `O` is not subject by the rules
 * of place (`N2`) or for another reason (`N1`). The row has to say which.
 */
function derived(category: string | null, exemption: string | null): { regime: string; key: string } | null {
  switch (category) {
    case 'S':
    case 'Z':
      return { regime: '01', key: 'S1' };
    case 'AE':
      return { regime: '01', key: 'S2' };
    case 'E':
      return exemption === 'VATEX-EU-132' ? { regime: '01', key: 'E1' } : null;
    case 'G':
      return exemption === 'VATEX-EU-G' || exemption === null ? { regime: '02', key: 'E2' } : null;
    default:
      return null;
  }
}

const IVA_RATES = ['0', '2', '4', '5', '7.5', '10', '21'];

/** 15.1 of the validations: the rates of IVA an `S1` detail may carry, on the date of the operation. */
function checkIvaRate(rate: Decimal, operationDay: string, findings: Findings, where: string): void {
  const written = formatDecimal(rate, 0);
  if (written === '18' || written === '8') {
    if (operationDay > '2012-12-31') findings.aeat('1132', `${where}: ${written} %.`);
    return;
  }
  if (!IVA_RATES.includes(written)) {
    findings.aeat('1124', `${where}: ${written} % is not 0, 2, 4, 5, 7.5, 10 or 21.`);
    return;
  }
  if (written === '5' && (operationDay < '2022-07-01' || operationDay > '2024-09-30')) {
    findings.aeat('1194', `${where}: 5 % on ${operationDay}.`);
  }
  if ((written === '2' || written === '7.5') && (operationDay < '2024-10-01' || operationDay > '2024-12-31')) {
    findings.aeat('1235', `${where}: ${written} % on ${operationDay}.`);
  }
}

interface Sums {
  bases: Decimal[];
  quotas: Decimal[];
}

function detail(
  row: Row,
  index: number,
  sign: (a: Decimal) => Decimal,
  context: { operationDay: string; byDifference: boolean },
  sums: Sums,
  findings: Findings,
): DetailModel {
  const where = `Tax ${index + 1} (${text(row, 'tax_code') ?? text(row, 'vat_category') ?? 'no category'})`;
  const category = text(row, 'vat_category')?.toUpperCase() ?? null;
  const exemptionCode = text(row, 'exemption_code')?.toUpperCase() ?? null;
  const base = sign(decimal(row, 'base_amount', `${where}, the base`));
  const charged = sign(decimal(row, 'tax_charged', `${where}, the tax`));
  const rate = optionalDecimal(row, 'tax_rate', `${where}, the rate`);

  const tax = text(row, 'aeat_tax') ?? '01';
  if (!(IMPUESTO as readonly string[]).includes(tax)) findings.aeat('1218', `${where}: "${tax}".`);

  const guess = derived(category, exemptionCode);
  const givenKey = text(row, 'aeat_qualification')?.toUpperCase() ?? null;
  const key = givenKey ?? guess?.key ?? null;
  // `01`, the general regime, unless the row says otherwise: a special regime
  // (the cash criterion, REBU, the equivalence surcharge…) is a fact of the
  // company the books do not record, and a pack that has one carries it.
  // `05`, another tax, has no regime key at all (15.6).
  const regime = tax === '05' ? text(row, 'aeat_regime') : (text(row, 'aeat_regime') ?? guess?.regime ?? '01');

  const exemptList: readonly string[] = tax === '03' ? OPERACION_EXENTA_IGIC : OPERACION_EXENTA;
  let qualification: string | null = null;
  let exemption: string | null = null;
  if (key === null) {
    findings.input(
      'aeat_qualification',
      `${where}: category ${category ?? 'none'}${exemptionCode ? ` with ${exemptionCode}` : ''} does not say on its own which qualification (S1, S2, N1, N2) or cause of exemption (E1 to E6) the AEAT is told; the row has to carry aeat_qualification.`,
    );
  } else if ((CALIFICACION as readonly string[]).includes(key)) {
    qualification = key;
  } else if (exemptList.includes(key)) {
    exemption = key;
  } else {
    findings.aeat(/^E/.test(key) ? '1182' : '1181', `${where}: "${key}".`);
  }

  if (tax !== '05') {
    const regimes: readonly string[] = tax === '03' ? CLAVE_REGIMEN_IGIC : tax === '02' ? CLAVE_REGIMEN_IPSI : CLAVE_REGIMEN_IVA;
    if (regime !== null && !regimes.includes(regime)) findings.aeat('1246', `${where}: "${regime}".`);
  }
  if (tax === '01' || tax === '03') {
    if (regime === '01' && (exemption === 'E2' || exemption === 'E3')) findings.aeat('1199', `${where}.`);
    if (regime === '02' && exemption === null && key !== null) findings.aeat('1286', `${where}.`);
    if (regime === '08' && qualification !== 'N2') findings.aeat('1252', `${where}.`);
  }

  let writtenRate: string | null = null;
  let quota: string | null = null;
  if (qualification === 'S1') {
    if (rate === null) findings.aeat('1208', `${where}: the row carries no rate.`);
    else {
      writtenRate = formatDecimal(rate, 0);
      if (!/^\d{1,3}(\.\d{1,2})?$/.test(writtenRate)) findings.aeat('1100', `${where}: the rate ${writtenRate} has at most three digits before the point and two after.`);
      if (tax === '01') checkIvaRate(rate, context.operationDay, findings, where);
    }
    quota = amount(charged, `${where}, CuotaRepercutida`, findings);
    if (rate !== null && !context.byDifference) {
      if (!isZero(charged) && !isZero(base) && (charged.units < 0n) !== (base.units < 0n)) findings.aeat('1143', `${where}.`);
      const expected = multiply(base, { units: rate.units, scale: rate.scale + 2 });
      if (compare(abs(subtract(charged, expected)), TEN) > 0) {
        findings.aeat('1142', `${where}: ${quota} against ${formatDecimal(base, 2)} × ${writtenRate} %, beyond the 10.00 the AEAT allows.`);
      }
    }
  } else if (qualification === 'S2') {
    writtenRate = '0';
    quota = amount(charged, `${where}, CuotaRepercutida`, findings);
    if ((rate !== null && !isZero(rate)) || !isZero(charged)) {
      findings.aeat('1198', `${where}: the rate is ${rate === null ? 'absent' : formatDecimal(rate, 0)} and the tax ${quota}.`);
    }
  } else if (!isZero(charged)) {
    findings.aeat(exemption !== null ? '1238' : qualification !== null ? '1237' : '1207', `${where}: the row charges ${formatDecimal(charged, 2)}.`);
  }

  sums.bases.push(base);
  if (quota !== null) sums.quotas.push(charged);
  return {
    tax,
    regime,
    qualification,
    exemption,
    rate: writtenRate,
    base: amount(base, `${where}, BaseImponibleOimporteNoSujeto`, findings),
    quota,
  };
}

// --- the record ----------------------------------------------------------------

function filenamePart(number: string): string {
  const safe = number.replace(/[^A-Za-z0-9._-]+/g, '-').replace(/^-+|-+$/g, '');
  return safe === '' ? 'record' : safe;
}

export function filenameOf(model: RecordModel): string {
  return `verifactu-${model.kind}-${filenamePart(model.number)}.xml`;
}

function recipient(header: Row, findings: Findings): AltaModel['recipient'] {
  const vat = text(header, 'buyer_vat_number');
  if (vat === null) return null;
  const name = text(header, 'buyer_name') ?? '';
  if (name === '') findings.aeat('4102', 'The buyer has a tax identifier and no name (IDDestinatario/NombreRazon).');
  else if (name.length > 120) findings.aeat('1100', `The buyer's name has ${name.length} characters, and holds at most 120.`);
  const country = text(header, 'buyer_country')?.toUpperCase() ?? null;
  const compact = vat.toUpperCase();
  const nif = compact.startsWith('ES') || country === 'ES' ? spanishNif(compact) : null;
  if (nif !== null) return { name, identifier: { nif } };
  const foreign = nifIva(compact);
  if (foreign !== null) return { name, identifier: { country: null, type: '02', id: foreign } };
  findings.aeat(
    '1102',
    `The buyer's identifier "${vat}" is neither a Spanish NIF nor the VAT number of another Member State, and the books do not say which document (IDType 03 to 06) it is: the record names no buyer.`,
  );
  return null;
}

function description(header: Row, lines: readonly Row[], findings: Findings): string {
  const note = text(header, 'note');
  const out =
    note ??
    lines
      .filter((line) => (text(line, 'line_type') ?? 'product') === 'product')
      .map((line) => text(line, 'item_name'))
      .filter((name): name is string => name !== null)
      .join('; ');
  if (out === '') findings.aeat('4102', 'DescripcionOperacion is required: the header carries no note and no line has a name.');
  else if (out.length > 500) findings.aeat('1100', `DescripcionOperacion has ${out.length} characters, and holds at most 500.`);
  return out;
}

function issuerNif(header: Row, findings: Findings, field: string): string {
  const vat = text(header, 'seller_vat_number');
  if (vat === null) {
    findings.aeat('4102', `${field} is required: the header carries no seller_vat_number.`);
    return '';
  }
  const nif = spanishNif(vat);
  if (nif === null) findings.aeat('1219', `"${vat}" is not a Spanish NIF, with or without its ES prefix.`);
  return nif ?? vat;
}

export function buildRecord(input: FiscalRecordInput): { model: RecordModel; violations: Violation[] } {
  if (!input || !input.header) throw new VerifactuError('no document was given');
  if (input.kind !== 'alta' && input.kind !== 'anulacion') {
    throw new VerifactuError(`a record is "alta" or "anulacion", not ${String(input.kind)}`);
  }
  const { header } = input;
  const docType = text(header, 'doc_type');
  if (docType !== 'sale_invoice' && docType !== 'sale_credit_note') {
    throw new VerifactuError(`a ${String(docType)} has no invoicing record: only a sales invoice and a sales credit note do`);
  }
  const number = text(header, 'number');
  if (number === null) throw new VerifactuError('the document has no number, and was never issued');
  const issuedDay = isoDate(text(header, 'document_date'), 'document_date');
  if (issuedDay === null) throw new VerifactuError('the document has no date of issue');

  const findings = new Findings();
  const generatedAt = String(input.generatedAt ?? '').trim();
  checkGeneratedAt(generatedAt, findings);
  const today = FECHA_HORA_HUSO.test(generatedAt) ? generatedAt.slice(0, 10) : null;

  checkNumber(number, 'NumSerieFactura', findings);
  if (issuedDay < '2024-10-28') findings.aeat('1152', `The document is dated ${issuedDay}.`);
  if (today !== null && issuedDay > today) findings.aeat('1112', `The document is dated ${issuedDay} and the record generated on ${today}.`);

  const common = {
    number,
    issued: aeatDate(issuedDay),
    chain: chain(input, findings),
    system: system(input.system, findings),
    generatedAt,
  };

  if (input.kind === 'anulacion') {
    const issuer = issuerNif(header, findings, 'IDEmisorFacturaAnulada');
    return { model: { kind: 'anulacion', issuer, ...common }, violations: findings.list };
  }

  const issuer = issuerNif(header, findings, 'IDEmisorFactura');
  const issuerName = text(header, 'seller_legal_name') ?? text(header, 'seller_name') ?? '';
  if (issuerName === '') findings.aeat('4102', 'NombreRazonEmisor is required: the header carries no seller name.');
  else if (issuerName.length > 120) findings.aeat('1100', `NombreRazonEmisor has ${issuerName.length} characters, and holds at most 120.`);

  const currency = text(header, 'currency_code');
  if (currency !== 'EUR') {
    findings.input('currency', `The document is in ${currency ?? 'no currency'}; the records carry euros and this package converts nothing.`);
  }

  const isCredit = docType === 'sale_credit_note';
  const sign = isCredit ? negate : (a: Decimal) => a;
  const buyer = recipient(header, findings);
  const buyerIdentified = text(header, 'buyer_vat_number') !== null;

  let invoiceType: string | null;
  let rectified: AltaModel['rectified'] = null;
  if (!isCredit) {
    invoiceType = buyerIdentified ? 'F1' : 'F2';
  } else {
    const given = text(header, 'rectification_type')?.toUpperCase() ?? null;
    if (given !== null) {
      invoiceType = given;
      if (!(RECTIFYING_TYPES as readonly string[]).includes(given)) {
        findings.input('rectification_type', `rectification_type "${given}" is not R1, R2, R3, R4 or R5.`);
      }
    } else if (!buyerIdentified) {
      invoiceType = 'R5';
    } else {
      invoiceType = null;
      findings.input(
        'rectification_type',
        'A credit note to an identified buyer is R1, R2, R3 or R4 by the article it rectifies under, and the books do not record which: the row has to carry rectification_type.',
      );
    }
    const rectifiedNumber = text(header, 'rectified_number');
    const rectifiedDay = isoDate(text(header, 'rectified_date'), 'rectified_date');
    if (rectifiedNumber !== null && rectifiedDay !== null) {
      checkNumber(rectifiedNumber, 'The number of the rectified invoice', findings);
      rectified = { issuer, number: rectifiedNumber, issued: aeatDate(rectifiedDay) };
    }
  }
  if (invoiceType === 'F2' || invoiceType === 'R5') {
    if (buyer !== null) findings.aeat('1190', `TipoFactura is ${invoiceType}.`);
  } else if (invoiceType !== null && buyer === null && buyerIdentified === false) {
    findings.aeat('1189', `TipoFactura is ${invoiceType}.`);
  }

  const operationSource =
    isoDate(text(header, 'tax_point_date'), 'tax_point_date') ?? isoDate(text(header, 'delivery_date'), 'delivery_date');
  const operationDay = operationSource ?? issuedDay;
  const operationDate = operationSource !== null && operationSource !== issuedDay ? aeatDate(operationSource) : null;
  if (operationSource !== null && operationSource > issuedDay) {
    findings.aeat('1146', `The operation is dated ${operationSource} and the invoice ${issuedDay}.`);
  }
  if (operationSource !== null && today !== null && operationSource > today) {
    findings.aeat('1173', `The operation is dated ${operationSource} and the record generated on ${today}.`);
  }

  const taxes = input.taxes ?? [];
  if (taxes.length === 0) findings.aeat('4102', 'Desglose is required: the document has no tax breakdown.');
  if (taxes.length > 12) findings.aeat('4113', `Desglose holds at most 12 details, and the document has ${taxes.length} taxes.`);
  const sums: Sums = { bases: [], quotas: [] };
  const details = taxes.map((row, index) =>
    detail(row, index, sign, { operationDay, byDifference: isCredit }, sums, findings),
  );

  const totalTax = sign(decimal(header, 'amount_tax', 'amount_tax'));
  const total = sign(decimal(header, 'amount_total', 'amount_total'));
  const quotas = sum(sums.quotas);
  const lines = sum([...sums.bases, ...sums.quotas]);
  // 16 and 17 of the validations, which are not applied under the regimes
  // whose tax is not the one charged on the base: 03, 05, 06, 08 and 09.
  const summed = !details.some((each) => ['03', '05', '06', '08', '09'].includes(each.regime ?? ''));
  if (summed && compare(abs(subtract(totalTax, quotas)), TEN) > 0) {
    findings.aeat('2006', `CuotaTotal is ${formatDecimal(totalTax, 2)} and the details charge ${formatDecimal(quotas, 2)}.`);
  }
  if (summed && compare(abs(subtract(total, lines)), TEN) > 0) {
    findings.aeat('2005', `ImporteTotal is ${formatDecimal(total, 2)} and the details add up to ${formatDecimal(lines, 2)}.`);
  }
  if (invoiceType === 'F2' && compare(lines, constant('3010')) > 0) {
    findings.aeat('1150', `The details add up to ${formatDecimal(lines, 2)}.`);
  }

  return {
    model: {
      kind: 'alta',
      issuer,
      issuerName,
      invoiceType,
      rectificationKind: isCredit ? 'I' : null,
      rectified,
      operationDate,
      description: description(header, input.lines ?? [], findings),
      macrodato: compare(abs(total), constant('100000000')) >= 0,
      recipient: buyer,
      details,
      totalTax: amount(totalTax, 'CuotaTotal', findings, '1266'),
      total: amount(total, 'ImporteTotal', findings, '1267'),
      ...common,
    },
    violations: findings.list,
  };
}
