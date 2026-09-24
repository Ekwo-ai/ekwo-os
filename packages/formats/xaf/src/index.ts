/**
 * The XML Audit File Financial — the *XML Auditfile Financieel*, XAF — read
 * back: the file an accounting package hands over when an auditor or a tax
 * authority asks for the books of a year, in the XML the published schema
 * defines. Versions 3.2 and 4.0 are read, each recognised by its namespace;
 * any other is refused by name.
 *
 * What is taken from it, and where it sits in the file:
 *
 * - the **currency** of the books, `header/curCode`;
 * - the **accounts**, `company/generalLedger/ledgerAccount` — `accID`,
 *   `accDesc`, and `accTp` kept as written;
 * - the **parties**, `company/customersSuppliers/customerSupplier`, by their
 *   `custSupID`;
 * - the **opening balance**, `company/openingBalance/obLine`;
 * - the **entries**, `company/transactions/journal/transaction`, each with its
 *   lines, `trLine`: an account, an amount and its side (`amnt`, `amntTp`),
 *   a party, an amount in another currency.
 *
 * The file states its own totals — the number of lines, the debits and the
 * credits of the opening and of the transactions — and each is held against
 * what its lines add up to: a file that disagrees with itself comes back with
 * a violation, as written.
 *
 * It depends on nothing, reads no database and knows no chart of accounts.
 */

import { formatDecimal, parseXsdDecimal } from './decimal.js';
import { BooksFileError } from './errors.js';
import type {
  ImportedAccount,
  ImportedBooks,
  ImportedContact,
  ImportedEntry,
  ImportedLine,
  ReadOptions,
  Violation,
} from './types.js';
import { parseXml, type XmlElement } from './xml.js';

export * from './types.js';
export { BooksFileError, type BooksFileErrorCode } from './errors.js';

const DEFAULTS = { maxBytes: 256 * 1024 * 1024, maxElements: 20_000_000, maxDepth: 32 } as const;

/** The versions read, by the namespace their schema declares. */
export const XAF_NAMESPACES = {
  '3.2': 'http://www.auditfiles.nl/XAF/3.2',
  '4.0': 'http://www.odb.belastingdienst.nl/Belastingdienst/BCPP/1.1/structures/XmlauditfileXAF_4.0',
} as const;

export type XafVersion = keyof typeof XAF_NAMESPACES;

/** The books of an audit file, and the version it was written in. */
export interface XafBooks extends ImportedBooks {
  version: XafVersion;
}

/** The element children of `parent` called `name`, in its namespace. */
function all(parent: XmlElement | undefined, name: string): XmlElement[] {
  return parent === undefined ? [] : parent.children.filter((child) => child.name === name && child.namespace === parent.namespace);
}

function one(parent: XmlElement | undefined, name: string): XmlElement | undefined {
  return all(parent, name)[0];
}

/** The trimmed text of the child `name`, or '' where there is none. */
function text(parent: XmlElement | undefined, name: string): string {
  return one(parent, name)?.text.trim() ?? '';
}

function required(parent: XmlElement, name: string, where: string): string {
  const value = text(parent, name);
  if (value === '') throw new BooksFileError('missing_element', `${where} has no ${name}, which the schema requires`);
  return value;
}

/** An `xsd:date`, its time zone set aside, checked against the calendar. */
function isoDate(value: string, where: string): string {
  const match = /^(\d{4})-(\d{2})-(\d{2})(?:Z|[+-]\d{2}:\d{2})?$/.exec(value);
  if (match === null) throw new BooksFileError('invalid_value', `${where}: "${value}" is not an xsd:date, YYYY-MM-DD`);
  const iso = `${match[1]}-${match[2]}-${match[3]}`;
  const parsed = new Date(`${iso}T00:00:00Z`);
  if (Number.isNaN(parsed.getTime()) || parsed.toISOString().slice(0, 10) !== iso) {
    throw new BooksFileError('invalid_value', `${where}: ${value} is not a day of the calendar`);
  }
  return iso;
}

function amountOf(value: string, where: string): bigint {
  const parsed = parseXsdDecimal(value);
  if (parsed === null) throw new BooksFileError('invalid_value', `${where}: "${value}" is not an amount`);
  return parsed;
}

/**
 * The debit and the credit of an amount and its side. A negative amount — the
 * schema's decimal allows a sign — is the other side, as it is everywhere
 * else in this repository.
 */
function sides(element: XmlElement, where: string): { debit: bigint; credit: bigint } {
  const amount = amountOf(required(element, 'amnt', where), where);
  const side = required(element, 'amntTp', where);
  if (side !== 'D' && side !== 'C') throw new BooksFileError('invalid_value', `${where}: amntTp is "${side}", and the schema allows D or C`);
  const signed = side === 'D' ? amount : -amount;
  return signed >= 0n ? { debit: signed, credit: 0n } : { debit: 0n, credit: -signed };
}

/** The totals a part of the file states, held against what its lines add up to. */
function checkTotals(
  part: XmlElement,
  what: string,
  counted: { lines: number; debit: bigint; credit: bigint },
  violations: Violation[],
): void {
  const lines = text(part, 'linesCount');
  const debit = text(part, 'totalDebit');
  const credit = text(part, 'totalCredit');
  if (lines !== '' && lines !== String(counted.lines)) {
    violations.push({ rule: 'lines_count', message: `the ${what} say they hold ${lines} lines, and ${counted.lines} are in the file`, row: null });
  }
  if (debit !== '' && amountOf(debit, `the ${what}' totalDebit`) !== counted.debit) {
    violations.push({ rule: 'total_debit', message: `the ${what} state a total debit of ${debit}, and their lines add up to ${formatDecimal(counted.debit)}`, row: null });
  }
  if (credit !== '' && amountOf(credit, `the ${what}' totalCredit`) !== counted.credit) {
    violations.push({ rule: 'total_credit', message: `the ${what} state a total credit of ${credit}, and their lines add up to ${formatDecimal(counted.credit)}`, row: null });
  }
}

const EMPTY_LINE = { contact: null, label: null, currency: null, amountCurrency: null, dueDate: null, matching: null } as const;

/**
 * Reads an audit file, as a string or as the bytes of the file. Entries are
 * the `transaction` elements of each `journal`; the opening balance is the
 * `obLine` elements, which carry no date of their own — the version 3.2 gives
 * one, `opBalDate`, which `openingDate` returns, and the version 4.0 opens on
 * `header/startDate`.
 */
export function readXaf(input: string | Uint8Array, options: ReadOptions = {}): XafBooks & { openingDate: string | null } {
  const root = parseXml(
    input,
    { maxBytes: options.maxBytes ?? DEFAULTS.maxBytes, maxElements: options.maxElements ?? DEFAULTS.maxElements, maxDepth: DEFAULTS.maxDepth },
    options.encoding,
  );
  const version = (Object.entries(XAF_NAMESPACES) as [XafVersion, string][]).find(([, namespace]) => namespace === root.namespace)?.[0];
  if (root.name !== 'auditfile') {
    throw new BooksFileError('not_an_auditfile', `the document element is <${root.name}>, and an audit file's is <auditfile>`);
  }
  if (version === undefined) {
    throw new BooksFileError(
      /XAF/i.test(root.namespace) ? 'unsupported_version' : 'not_an_auditfile',
      `the namespace is "${root.namespace}"; this reader reads the audit file of version 3.2 (${XAF_NAMESPACES['3.2']}) and 4.0 (${XAF_NAMESPACES['4.0']})`,
    );
  }

  const header = one(root, 'header');
  if (header === undefined) throw new BooksFileError('missing_element', 'the audit file has no header');
  const currency = required(header, 'curCode', 'the header').toUpperCase();
  if (!/^[A-Z]{3}$/.test(currency)) throw new BooksFileError('invalid_value', `the header's curCode is "${currency}", and an ISO 4217 code is three letters`);
  const startDate = isoDate(required(header, 'startDate', 'the header'), 'the header startDate');

  const company = one(root, 'company');
  if (company === undefined) throw new BooksFileError('missing_element', 'the audit file has no company');

  const violations: Violation[] = [];
  const accounts = new Map<string, ImportedAccount>();
  const contacts = new Map<string, ImportedContact>();

  for (const account of all(one(company, 'generalLedger'), 'ledgerAccount')) {
    const code = required(account, 'accID', 'a ledgerAccount');
    const name = text(account, 'accDesc');
    const type = text(account, 'accTp');
    accounts.set(code, { code, name: name === '' ? null : name, type: type === '' ? null : type });
  }

  for (const party of all(one(company, 'customersSuppliers'), 'customerSupplier')) {
    const code = required(party, 'custSupID', 'a customerSupplier');
    const name = text(party, 'custSupName');
    const address = all(party, 'streetAddress').concat(all(party, 'postalAddress')).map((a) => text(a, 'country').toUpperCase()).find((c) => c !== '');
    const country = address ?? text(party, 'taxRegistrationCountry').toUpperCase();
    const vat = text(party, 'taxRegIdent');
    const registration = text(party, 'commerceNr');
    const email = text(party, 'eMail');
    contacts.set(code, {
      code,
      name: name === '' ? code : name,
      vatNumber: vat === '' ? null : vat,
      registrationNumber: registration === '' ? null : registration,
      email: email === '' ? null : email,
      country: /^[A-Z]{2}$/.test(country) ? country : null,
    });
  }

  const knowAccount = (code: string): void => {
    if (!accounts.has(code)) accounts.set(code, { code, name: null, type: null });
  };

  // The opening balance.
  const opening: ImportedLine[] = [];
  let openingDate: string | null = null;
  const openingBalance = one(company, 'openingBalance');
  if (openingBalance !== undefined) {
    const written = text(openingBalance, 'opBalDate');
    openingDate = written === '' ? startDate : isoDate(written, 'the opening balance opBalDate');
    const counted = { lines: 0, debit: 0n, credit: 0n };
    for (const obLine of all(openingBalance, 'obLine')) {
      const where = `opening balance line ${text(obLine, 'nr') || counted.lines + 1}`;
      const account = required(obLine, 'accID', where);
      const { debit, credit } = sides(obLine, where);
      knowAccount(account);
      opening.push({ ...EMPTY_LINE, account, debit: formatDecimal(debit), credit: formatDecimal(credit) });
      counted.lines += 1;
      counted.debit += debit;
      counted.credit += credit;
    }
    checkTotals(openingBalance, 'opening balance', counted, violations);
    if (counted.debit !== counted.credit) {
      violations.push({
        rule: 'opening_balance',
        message: `the opening balance has debit ${formatDecimal(counted.debit)} and credit ${formatDecimal(counted.credit)}`,
        row: null,
      });
    }
  }

  // The entries.
  const entries: ImportedEntry[] = [];
  const transactions = one(company, 'transactions');
  if (transactions !== undefined) {
    const counted = { lines: 0, debit: 0n, credit: 0n };
    for (const journal of all(transactions, 'journal')) {
      const code = required(journal, 'jrnID', 'a journal');
      const journalName = text(journal, 'desc');
      for (const transaction of all(journal, 'transaction')) {
        const number = required(transaction, 'nr', `a transaction of journal ${code}`);
        const where = `transaction ${number} of journal ${code}`;
        const date = isoDate(required(transaction, 'trDt', where), `${where}, trDt`);
        const lines: ImportedLine[] = [];
        let debits = 0n;
        let credits = 0n;
        let reference: string | null = null;
        for (const trLine of all(transaction, 'trLine')) {
          const at = `line ${text(trLine, 'nr') || lines.length + 1} of ${where}`;
          const account = required(trLine, 'accID', at);
          const { debit, credit } = sides(trLine, at);
          knowAccount(account);
          const party = text(trLine, 'custSupID');
          if (party !== '' && !contacts.has(party)) {
            contacts.set(party, { code: party, name: party, vatNumber: null, registrationNumber: null, email: null, country: null });
          }
          const foreign = one(trLine, 'currency');
          const foreignCode = text(foreign, 'curCode').toUpperCase();
          const foreignAmount = text(foreign, 'curAmnt');
          const inCurrency = foreign === undefined || foreignAmount === '' ? null : amountOf(foreignAmount, `${at}, curAmnt`);
          const docRef = text(trLine, 'docRef');
          if (reference === null && docRef !== '') reference = docRef;
          const label = text(trLine, 'desc');
          const matching = text(trLine, 'matchKeyID');
          lines.push({
            account,
            contact: party === '' ? null : party,
            label: label === '' ? null : label,
            debit: formatDecimal(debit),
            credit: formatDecimal(credit),
            currency: foreignCode === '' || inCurrency === null ? null : foreignCode,
            amountCurrency: foreignCode === '' || inCurrency === null ? null : formatDecimal(inCurrency < 0n ? -inCurrency : inCurrency),
            dueDate: null,
            matching: matching === '' ? null : matching,
          });
          debits += debit;
          credits += credit;
        }
        if (lines.length === 0) {
          violations.push({ rule: 'empty_entry', message: `${where} has no line`, row: null });
        } else if (debits !== credits) {
          violations.push({ rule: 'balance', message: `${where} has debit ${formatDecimal(debits)} and credit ${formatDecimal(credits)}`, row: null });
        }
        counted.lines += lines.length;
        counted.debit += debits;
        counted.credit += credits;
        const description = text(transaction, 'desc');
        entries.push({
          journal: code,
          journalName: journalName === '' ? null : journalName,
          number,
          date,
          reference,
          description: description !== '' ? description : (lines[0]?.label ?? null),
          lines,
          row: null,
        });
      }
    }
    checkTotals(transactions, 'transactions', counted, violations);
  }

  if (entries.length === 0 && opening.length === 0) {
    throw new BooksFileError('missing_element', 'the audit file holds no transaction and no opening balance');
  }

  return {
    format: 'xaf',
    version,
    currency,
    accounts: [...accounts.values()],
    contacts: [...contacts.values()],
    entries,
    opening,
    openingDate,
    violations,
  };
}
