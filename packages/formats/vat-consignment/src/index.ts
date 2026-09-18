/**
 * The Belgian periodic VAT return, as Intervat takes it.
 *
 * One XML document, `VATConsignment`, described by the schema the SPF Finances
 * publishes as `NewTVA-in_v0_9.xsd`. Give it the figures a declaration was
 * filed with — a grid, what the grid holds, an amount — and it writes the
 * file, a name for it, and the list of what could not be put in it.
 *
 * The input is deliberately the **frozen** figures and not a computation: what
 * is deposited has to be what the declaration says, and a file that recomputes
 * can diverge from the filing it is supposed to carry.
 *
 * Sources are in the README. This package depends on nothing, reads no
 * database and knows no accounting.
 */

import type {
  ConsignedReturn,
  ConsignmentOptions,
  FiledBox,
  Representative,
  ReturnPeriod,
  VatConsignment,
  VatConsignmentOptions,
  Violation,
} from './types.js';

export type {
  Ask,
  ConsignedReturn,
  ConsignmentOptions,
  Declarant,
  FiledBox,
  Representative,
  ReturnPeriod,
  VatConsignment,
  VatConsignmentOptions,
  Violation,
} from './types.js';

const NS_RETURN = 'http://www.minfin.fgov.be/VATConsignment';
const NS_COMMON = 'http://www.minfin.fgov.be/InputCommon';

/** The schema's own pattern for the declarant's enterprise number. */
const DECLARANT_NUMBER = /^[0-1][0-9][0-9]{8}$/;

/**
 * The grids of the form, which the schema closes: `GridNumberCode` is an
 * enumeration, and a number that is not in it is refused by the validator
 * however plausible it looks. Read from `NewTVA-in_v0_9.xsd`; a test compares
 * this list with the schema file itself, so it cannot drift from it.
 */
export const GRIDS: readonly string[] = Object.freeze([
  '00', '01', '02', '03', '44', '45', '46', '47', '48', '49',
  '54', '55', '56', '57', '59', '61', '62', '63', '64',
  '71', '72', '81', '82', '83', '84', '85', '86', '87', '88',
]);

/**
 * The states that can have issued a representative's identifier:
 * `MSCountryCode`, which the schema closes too. It is the schema's list and
 * not ISO's — Greece is `EL` in it, and `XI` and `XU` are there — and a test
 * compares it with the schema file, code for code.
 */
export const ISSUERS: readonly string[] = Object.freeze([
  'AT', 'BG', 'CY', 'CZ', 'DK', 'EE', 'FI', 'FR', 'DE', 'EL', 'HU', 'IE', 'IT', 'LV', 'LT',
  'LU', 'MT', 'NL', 'PL', 'PT', 'RO', 'SK', 'SI', 'ES', 'SE', 'GB', 'MC', 'HR', 'XI', 'XU',
  'BE',
]);

/** `RepresentativeIDType_Type`. */
const IDENTIFICATION_TYPES: readonly string[] = ['NVAT', 'TIN', 'other'];

/** `EMail_Type`, as the schema writes it. */
const EMAIL = /^[^@]+@[^.]+\..+$/;

/** `PositiveAmount_Type`: the largest figure a grid can hold. */
const MAX_AMOUNT = 99_999_999_999.99;

/** `DeclarantReference_Type`: a token of at most fourteen characters. */
const MAX_REFERENCE = 14;

/** `IntervatDeclarationReference_Type`, for the declaration a corrective replaces. */
const DECLARATION_REFERENCE = /^[0-9]+-[0-9]{10}-[0-9]{6}$/;

/** `PhoneNumber_Type` allows twenty characters; digits are what is written. */
const MAX_PHONE = 20;

/**
 * The grid a nil return is written on. The schema requires `Data` and at least
 * one `Amount` in it, and does not say which: so a return where nothing
 * happened says the one thing it has to say — that nothing is owed — on the
 * grid that carries what is owed. A choice of this package, forced by the
 * schema and not specified by it.
 */
export const NIL_GRID = '71';

export class VatConsignmentError extends Error {
  override name = 'VatConsignmentError';
}

function escapeXml(value: string): string {
  return value
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

/**
 * Two decimals with a point. The French-language pages of the administration
 * write their examples with a comma; the schema does not, and a comma is
 * refused by the validator.
 */
export function formatAmount(value: string | number): string {
  const n = typeof value === 'number' ? value : Number(value);
  if (!Number.isFinite(n)) throw new VatConsignmentError(`invalid amount: ${String(value)}`);
  return n.toFixed(2);
}

/** Letters and digits, upper case: what an administration compares. */
function normalise(value: string): string {
  return value.replace(/[^A-Za-z0-9]/g, '').toUpperCase();
}

/** `3` and `03` are the same grid; the form writes the second. */
export function formatGrid(box: string): string {
  return box.trim().padStart(2, '0');
}

function periodElement(period: ReturnPeriod): string {
  const lines: string[] = [];
  if (period.month !== undefined) {
    lines.push(`      <ns2:Month>${String(period.month).padStart(2, '0')}</ns2:Month>`);
  }
  if (period.quarter !== undefined) lines.push(`      <ns2:Quarter>${period.quarter}</ns2:Quarter>`);
  lines.push(`      <ns2:Year>${period.year}</ns2:Year>`);
  return lines.join('\n');
}

/**
 * The declarant block. Its children live in the `InputCommon` namespace and
 * not in the return's own, because the schema that declares them is a
 * different one — a detail the validator is strict about and no example makes
 * obvious.
 *
 * Nothing is filled in for an absent field. A telephone number invented to
 * satisfy a validator travels to an administration as a telephone number.
 */
function declarantElement(options: VatConsignmentOptions, vatNumber: string): string {
  const d = options.declarant;
  const optional: [string, string | undefined][] = [
    ['Name', d.name],
    ['Street', d.street],
    ['PostCode', d.postCode],
    ['City', d.city],
    ['CountryCode', d.countryCode],
    ['EmailAddress', d.emailAddress],
    ['Phone', phoneOf(d.phone)],
  ];
  const lines = [`      <VATNumber>${vatNumber}</VATNumber>`];
  for (const [tag, value] of optional) {
    if (value !== undefined && value !== '') {
      lines.push(`      <${tag}>${escapeXml(value)}</${tag}>`);
    }
  }
  return lines.join('\n');
}

/** Digits only, and nothing at all where they would not fit the schema. */
function phoneOf(phone: string | undefined): string | undefined {
  if (phone === undefined) return undefined;
  const digits = phone.replace(/[^0-9]/g, '');
  return digits.length === 0 || digits.length > MAX_PHONE ? undefined : digits;
}

interface Grid {
  grid: string;
  amount: string;
}

/**
 * The grids of the file, from the figures the declaration was filed with.
 *
 * Five things are refused here rather than written out, and each of them
 * comes back as a violation so that the rest of the return is still a return:
 *
 * - a grid the schema does not list — a box of another country's form, or a
 *   number that merely looks like one of this form's;
 * - **the same grid twice**, which is the one thing this format cannot hold:
 *   it gives every grid a single value, and a form that prints a base and a
 *   tax on one line — the French CA3 does — has no representation here;
 * - an amount that is not a number;
 * - **a negative amount**: every grid is a `PositiveAmount_Type`, because this
 *   form keeps what reduces a figure on a grid of its own (48, 49, 61, 62)
 *   rather than letting any grid go below zero;
 * - an amount beyond what the schema can hold.
 *
 * A grid at zero is left out. The administration reads an absent grid as a
 * zero, and a return that writes out its thirty empty boxes is a return
 * nobody can read.
 */
function gridsOf(boxes: FiledBox[]): { grids: Grid[]; violations: Violation[] } {
  const violations: Violation[] = [];
  const seen = new Map<string, string>();
  const grids: Grid[] = [];

  for (const box of boxes) {
    const grid = formatGrid(String(box.box ?? ''));
    if (!GRIDS.includes(grid)) {
      violations.push({
        code: 'unknown_grid',
        message: `${String(box.box)} is not a grid of this form: the schema lists the ones there are, and this is not among them`,
        box: String(box.box),
      });
      continue;
    }

    const amount = Number(box.amount);
    if (!Number.isFinite(amount)) {
      violations.push({
        code: 'invalid_amount',
        message: `grid ${grid} carries ${String(box.amount)}, which is not an amount`,
        box: grid,
      });
      continue;
    }

    if (amount < 0) {
      violations.push({
        code: 'negative_amount',
        message: `grid ${grid} carries ${formatAmount(amount)}: no grid of this form goes below zero, and what reduces a figure has a grid of its own`,
        box: grid,
      });
      continue;
    }
    if (amount > MAX_AMOUNT) {
      violations.push({
        code: 'amount_out_of_range',
        message: `grid ${grid} carries ${formatAmount(amount)}, which is more than the schema can hold`,
        box: grid,
      });
      continue;
    }

    const kind = box.kind ?? 'tax';
    const already = seen.get(grid);
    if (already !== undefined) {
      violations.push({
        code: 'grid_twice',
        message: `grid ${grid} was given twice, as ${already} and as ${kind}: this form holds one figure per grid`,
        box: grid,
      });
      continue;
    }
    seen.set(grid, kind);

    if (Math.abs(amount) < 0.005) continue;
    grids.push({ grid, amount: formatAmount(amount) });
  }

  grids.sort((a, b) => Number(a.grid) - Number(b.grid));
  return { grids, violations };
}

/**
 * A name for the file.
 *
 * The administration imposes none: Intervat takes the file that is uploaded
 * and names the deposit itself. So this is a name of ours, stable and
 * readable, and a caller is free to choose another.
 */
export function vatConsignmentFileName(declarantVatNumber: string, period: ReturnPeriod): string {
  const number = normalise(declarantVatNumber).replace(/^BE/, '');
  const suffix =
    period.month !== undefined
      ? `M${String(period.month).padStart(2, '0')}`
      : period.quarter !== undefined
        ? `Q${period.quarter}`
        : 'Y';
  return `VATConsignment-${number}-${period.year}${suffix}.xml`;
}

/**
 * The representative block: the party that files for the declarants of the
 * consignment, in its own name.
 *
 * The schema makes the block optional and every field in it required. So a
 * representative that lacks one is refused by exception, and is neither
 * completed nor left out: a field made up travels to an administration as a
 * fact, and a consignment that silently drops its representative is a file
 * sent under another authority than the one that was meant.
 */
function representativeElement(r: Representative): string {
  const missing = (
    ['id', 'issuedBy', 'identificationType', 'name', 'street', 'postCode', 'city', 'countryCode', 'emailAddress', 'phone'] as const
  ).filter((field) => typeof r[field] !== 'string' || r[field].trim() === '');
  if (missing.length > 0) {
    throw new VatConsignmentError(
      `a representative is named entirely or not at all, and this one lacks: ${missing.join(', ')}`,
    );
  }
  if (!ISSUERS.includes(r.issuedBy)) {
    throw new VatConsignmentError(
      `the representative's identifier is issued by a state the schema lists, and ${r.issuedBy} is not one (Greece is EL there)`,
    );
  }
  if (!IDENTIFICATION_TYPES.includes(r.identificationType)) {
    throw new VatConsignmentError(
      `the representative's identifier is NVAT, TIN or other: ${String(r.identificationType)}`,
    );
  }
  if (!EMAIL.test(r.emailAddress.trim())) {
    throw new VatConsignmentError(
      `the representative's e-mail address is not one the schema takes: ${r.emailAddress}`,
    );
  }
  const phone = phoneOf(r.phone);
  if (phone === undefined) {
    throw new VatConsignmentError(
      `the representative's telephone number does not fit the ${MAX_PHONE} digits the schema allows: ${r.phone}`,
    );
  }

  const qualifier =
    r.identificationType === 'other' && r.otherQualifier !== undefined && r.otherQualifier !== ''
      ? ` otherQlf="${escapeXml(r.otherQualifier)}"`
      : '';
  return [
    '  <ns2:Representative>',
    `    <RepresentativeID issuedBy="${r.issuedBy}" identificationType="${r.identificationType}"${qualifier}>${escapeXml(r.id.trim())}</RepresentativeID>`,
    `    <Name>${escapeXml(r.name)}</Name>`,
    `    <Street>${escapeXml(r.street)}</Street>`,
    `    <PostCode>${escapeXml(r.postCode)}</PostCode>`,
    `    <City>${escapeXml(r.city)}</City>`,
    `    <CountryCode>${escapeXml(r.countryCode)}</CountryCode>`,
    `    <EmailAddress>${escapeXml(r.emailAddress.trim())}</EmailAddress>`,
    `    <Phone>${phone}</Phone>`,
    '  </ns2:Representative>',
  ].join('\n');
}

/** What would make one return meaningless: refused by exception, and its number cleaned. */
function declarantNumberOf(options: VatConsignmentOptions): string {
  const { period } = options;
  const named = [period.month !== undefined, period.quarter !== undefined].filter(Boolean).length;
  if (named !== 1) {
    throw new VatConsignmentError(
      'the period of a return is one month or one quarter: name exactly one of them',
    );
  }
  if (period.month !== undefined && (period.month < 1 || period.month > 12)) {
    throw new VatConsignmentError(`month out of range: ${period.month}`);
  }
  if (period.quarter !== undefined && (period.quarter < 1 || period.quarter > 4)) {
    throw new VatConsignmentError(`quarter out of range: ${period.quarter}`);
  }
  if (!Number.isInteger(period.year) || period.year < 2000) {
    throw new VatConsignmentError(`year out of range: ${period.year}`);
  }

  const declarantNumber = normalise(options.declarant.vatNumber).replace(/^BE/, '');
  if (!DECLARANT_NUMBER.test(declarantNumber)) {
    throw new VatConsignmentError(
      `the declarant's number is ten digits without its country prefix: ${options.declarant.vatNumber}`,
    );
  }

  if (
    options.replacedDeclaration !== undefined &&
    !DECLARATION_REFERENCE.test(options.replacedDeclaration)
  ) {
    throw new VatConsignmentError(
      `the declaration being replaced is named by the reference Intervat gave it, digits-ten digits-six digits: ${options.replacedDeclaration}`,
    );
  }
  return declarantNumber;
}

/** One `VATDeclaration`, and what could not be put in it. */
function declarationElement(
  boxes: FiledBox[],
  options: VatConsignmentOptions,
  declarantNumber: string,
  sequence: number,
): { lines: string[]; violations: Violation[] } {
  const { period } = options;
  const { grids, violations } = gridsOf(boxes);
  const ask = options.ask ?? {};

  let declarantReference = options.declarantReference;
  if (declarantReference !== undefined && declarantReference.length > MAX_REFERENCE) {
    violations.push({
      code: 'reference_too_long',
      message: `the declarant's reference holds ${MAX_REFERENCE} characters at most, and ${declarantReference} is ${declarantReference.length}: left out`,
    });
    declarantReference = undefined;
  }
  if (options.declarant.phone !== undefined && phoneOf(options.declarant.phone) === undefined) {
    violations.push({
      code: 'invalid_phone',
      message: `the telephone number does not fit the ${MAX_PHONE} digits the schema allows: left out`,
    });
  }

  const parts: string[] = [];
  const reference =
    declarantReference === undefined || declarantReference === ''
      ? ''
      : ` DeclarantReference="${escapeXml(declarantReference)}"`;
  parts.push(`  <ns2:VATDeclaration SequenceNumber="${sequence}"${reference}>`);
  if (options.replacedDeclaration !== undefined) {
    parts.push(
      `    <ns2:ReplacedVATDeclaration>${options.replacedDeclaration}</ns2:ReplacedVATDeclaration>`,
    );
  }
  parts.push('    <ns2:Declarant>');
  parts.push(declarantElement(options, declarantNumber));
  parts.push('    </ns2:Declarant>');
  parts.push('    <ns2:Period>');
  parts.push(periodElement(period));
  parts.push('    </ns2:Period>');
  // `Data` is required and so is one `Amount` inside it: a nil return is still
  // a return, and it says that nothing is owed.
  const written = grids.length > 0 ? grids : [{ grid: NIL_GRID, amount: formatAmount(0) }];
  parts.push('    <ns2:Data>');
  for (const { grid, amount } of written) {
    parts.push(`      <ns2:Amount GridNumber="${grid}">${amount}</ns2:Amount>`);
  }
  parts.push('    </ns2:Data>');
  // Required on every return. `NO` is the absence of a claim.
  parts.push(
    `    <ns2:ClientListingNihil>${options.clientListingNihil === true ? 'YES' : 'NO'}</ns2:ClientListingNihil>`,
  );
  parts.push(
    `    <ns2:Ask Restitution="${ask.restitution ? 'YES' : 'NO'}" Payment="${ask.payment ? 'YES' : 'NO'}"/>`,
  );
  if (options.comment !== undefined && options.comment !== '') {
    parts.push(`    <ns2:Comment>${escapeXml(options.comment)}</ns2:Comment>`);
  }
  parts.push('  </ns2:VATDeclaration>');
  return { lines: parts, violations };
}

/**
 * A name for a consignment of several returns: whose it is, the period when
 * every return shares one, and how many it holds.
 */
function consignmentFileName(owner: string, periods: ReturnPeriod[], count: number): string {
  const first = periods[0] as ReturnPeriod;
  const shared = periods.every(
    (p) => p.year === first.year && p.month === first.month && p.quarter === first.quarter,
  );
  const stem = shared
    ? vatConsignmentFileName(owner, first).replace(/\.xml$/, '')
    : `VATConsignment-${normalise(owner).replace(/^BE/, '')}`;
  return `${stem}-x${count}.xml`;
}

/**
 * Writes a consignment: one file, as many returns as it is given, and the
 * representative who files them when there is one.
 *
 * This is the shape the schema was drawn for — `VATDeclaration` repeats and
 * `VATDeclarationsNbr` counts them — and it is how a firm deposits the returns
 * of all its clients at once, in its own name.
 *
 * Refuses, by exception, what would make the file meaningless: no return at
 * all, a return whose period or declarant cannot be written, a representative
 * named by halves, two returns under one sequence number — the number is the
 * only thing that tells them apart in one file. Everything that is wrong with
 * one figure comes back in `violations`, carrying the sequence number of the
 * return it is in, and leaves the rest of the file valid.
 *
 * **Not checked**: that the representative holds a mandate for each declarant.
 * That is a fact of the administration's records and not of this file.
 */
export function generateVatConsignments(
  returns: ConsignedReturn[],
  consignment: ConsignmentOptions = {},
): VatConsignment {
  if (returns.length === 0) {
    throw new VatConsignmentError('a consignment holds at least one return');
  }

  const several = returns.length > 1;
  const violations: Violation[] = [];
  const body: string[] = [];
  const numbers: string[] = [];
  const sequences = new Set<number>();

  returns.forEach(({ boxes, options }, index) => {
    const sequence = options.sequenceNumber ?? index + 1;
    if (!Number.isInteger(sequence) || sequence < 1) {
      throw new VatConsignmentError(`a sequence number is a positive integer: ${sequence}`);
    }
    if (sequences.has(sequence)) {
      throw new VatConsignmentError(
        `two returns of one consignment carry the sequence number ${sequence}, which is the only thing that tells them apart`,
      );
    }
    sequences.add(sequence);

    const declarantNumber = declarantNumberOf(options);
    numbers.push(declarantNumber);
    const written = declarationElement(boxes, options, declarantNumber, sequence);
    body.push(...written.lines);
    for (const violation of written.violations) {
      violations.push(several ? { ...violation, declaration: sequence } : violation);
    }
  });

  let representativeReference = consignment.representativeReference;
  if (representativeReference !== undefined && representativeReference.length > MAX_REFERENCE) {
    violations.push({
      code: 'reference_too_long',
      message: `the representative's reference holds ${MAX_REFERENCE} characters at most, and ${representativeReference} is ${representativeReference.length}: left out`,
    });
    representativeReference = undefined;
  }

  const parts: string[] = [];
  parts.push('<?xml version="1.0" encoding="UTF-8"?>');
  parts.push(
    `<ns2:VATConsignment xmlns:ns2="${NS_RETURN}" xmlns="${NS_COMMON}" VATDeclarationsNbr="${returns.length}">`,
  );
  if (consignment.representative !== undefined) {
    parts.push(representativeElement(consignment.representative));
  }
  if (representativeReference !== undefined && representativeReference !== '') {
    parts.push(
      `  <ns2:RepresentativeReference>${escapeXml(representativeReference)}</ns2:RepresentativeReference>`,
    );
  }
  parts.push(...body);
  parts.push('</ns2:VATConsignment>');

  const periods = returns.map(({ options }) => options.period);
  return {
    file: `${parts.join('\n')}\n`,
    filename: several
      ? consignmentFileName(consignment.representative?.id ?? (numbers[0] as string), periods, returns.length)
      : vatConsignmentFileName(numbers[0] as string, periods[0] as ReturnPeriod),
    violations,
  };
}

/**
 * Writes one return, filed by the declarant itself: a consignment of one.
 *
 * Refuses, by exception, what would make the whole file meaningless: a period
 * that is neither a month nor a quarter, or a declarant number the schema
 * cannot hold. Everything that is wrong with one figure comes back in
 * `violations` and leaves the rest of the file valid — a return that refuses
 * to exist over one unreadable grid helps nobody.
 */
export function generateVatConsignment(
  boxes: FiledBox[],
  options: VatConsignmentOptions,
): VatConsignment {
  return generateVatConsignments([{ boxes, options }]);
}
