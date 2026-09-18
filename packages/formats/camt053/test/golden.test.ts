import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { describe, expect, it } from 'vitest';
import { VERIFIED_VERSIONS, isValidIban, readCamt053 } from '../src/index.js';

const here = dirname(fileURLToPath(import.meta.url));
const fixture = (name: string): string => readFileSync(join(here, 'fixtures', name), 'utf8');
const golden = (version: string): string => fixture(`golden.camt.053.001.${version}.xml`);

describe('the golden statement', () => {
  const file = readCamt053(golden('08'));
  const statement = file.statements[0]!;

  it('says which version it read', () => {
    expect(file.namespace).toBe('urn:iso:std:iso:20022:tech:xsd:camt.053.001.08');
    expect(file.version).toBe('08');
    expect(file.versionVerified).toBe(true);
    expect(file.messageId).toBe('MSG-2026-03-0001');
  });

  it('reads the statement, its account and its two balances', () => {
    expect(statement).toMatchObject({
      id: 'STMT-2026-003',
      electronicSequenceNumber: '3',
      legalSequenceNumber: '3',
      period: { from: '2026-03-01', to: '2026-03-31' },
      account: {
        identifier: { kind: 'iban', value: 'BE96999000000101' },
        currency: 'EUR',
        ownerName: 'Atelier Exemple',
        servicerBic: 'ZZZZBEB1',
      },
      openingBalance: { type: 'OPBD', amount: '1000.00', currency: 'EUR', date: '2026-03-01' },
      closingBalance: { type: 'CLBD', amount: '1562.36', currency: 'EUR', date: '2026-03-31' },
      balanced: true,
    });
    expect(file.violations).toEqual([]);
  });

  it('signs every amount from the holder\'s side, as a string', () => {
    expect(statement.lines.map((line) => line.amount)).toEqual([
      '1210.00',
      '-450.50',
      '450.50',
      '-12.40',
      '-920.00',
      '100.00',
      '120.00',
      '80.00',
      '-75.25',
      '0.01',
      '500.00',
      '60.00',
    ]);
    for (const line of statement.lines) expect(typeof line.amount).toBe('string');
  });

  it('keeps a structured communication and a free one apart', () => {
    expect(statement.lines[0]?.remittance).toEqual({
      unstructured: [],
      structured: [{ reference: 'RF73INV20260042', type: 'SCOR', issuer: 'ISO' }],
    });
    expect(statement.lines[1]?.remittance).toEqual({
      unstructured: ['Invoice 2026-0107', 'thank you'],
      structured: [],
    });
    // Both at once: neither is folded into the other.
    expect(statement.lines[11]?.remittance).toEqual({
      unstructured: ['contribution'],
      structured: [{ reference: '202600004236', type: 'SCOR', issuer: 'BBA' }],
    });
  });

  it('names the other side: the debtor of money in, the creditor of money out', () => {
    expect(statement.lines[0]?.counterparty).toEqual({
      name: 'Client Exemple & Fils',
      account: { kind: 'iban', value: 'FR499999900000000000010199' },
      agentBic: 'ZZZZFRP1',
      ultimateName: 'Groupe Exemple',
    });
    expect(statement.lines[1]?.counterparty?.name).toBe('Fournisseur Fictif');
  });

  it('reads a returned transfer as money in from the party it was sent to', () => {
    expect(statement.lines[2]).toMatchObject({
      amount: '450.50',
      reversal: true,
      returnReason: 'AC04',
      counterparty: {
        name: 'Fournisseur Fictif',
        account: { kind: 'iban', value: 'NL68ZZZZ0000000606' },
      },
    });
  });

  it('reads bank charges as a line with a code and nobody on the other side', () => {
    expect(statement.lines[3]).toMatchObject({
      amount: '-12.40',
      counterparty: null,
      bankTransactionCode: { domain: 'ACMT', family: 'MDOP', subFamily: 'CHRG' },
      additionalInformation: 'Account fees, first quarter',
    });
  });

  it('reports what was ordered in another currency, and converts nothing', () => {
    expect(statement.lines[4]).toMatchObject({
      amount: '-920.00',
      currency: 'EUR',
      instructedAmount: { amount: '1000.00', currency: 'USD' },
      exchangeRate: '0.92',
      counterparty: {
        name: 'Example Supplies Inc',
        account: { kind: 'other', value: '999999992 0000123456', scheme: 'ROUTING ACCOUNT', issuer: null },
      },
    });
  });

  it('splits a batch into its transactions, each with its own reference', () => {
    const parts = statement.lines.filter((line) => line.entry === 6);
    expect(parts.map((line) => [line.detail, line.detailCount, line.amount, line.entryAmount])).toEqual([
      [1, 3, '100.00', '300.00'],
      [2, 3, '120.00', '300.00'],
      [3, 3, '80.00', '300.00'],
    ]);
    expect(parts.map((line) => line.bankReference)).toEqual([
      'ZZ26031700006-1',
      'ZZ26031700006-2',
      'ZZ26031700006-3',
    ]);
    expect(parts.map((line) => line.counterparty?.name)).toEqual([
      'Premier Payeur',
      'Second Payeur',
      'Troisième Payeur',
    ]);
    expect(new Set(parts.map((line) => line.entryReference))).toEqual(new Set(['6']));
  });

  it('carries a mandate, and the end-to-end identifier as the bank wrote it', () => {
    expect(statement.lines[8]).toMatchObject({ mandateId: 'MANDATE-0009', endToEndId: 'E2E-DD-0009' });
    expect(statement.lines[1]?.endToEndId).toBe('NOTPROVIDED');
  });

  it('returns a pending entry, marks it, and leaves it out of the balance', () => {
    expect(statement.lines[10]).toMatchObject({
      status: 'PDNG',
      booked: false,
      amount: '500.00',
      bookingDate: null,
      valueDate: '2026-04-02',
    });
    expect(statement.balanced).toBe(true);
  });

  it('takes the day of a date-time as the bank wrote it, not as UTC sees it', () => {
    // 23:30 at +02:00 is 21:30 UTC the same day here, and would be the next
    // day for a bank west of Greenwich. The day written is the day booked.
    expect(statement.lines[11]?.bookingDate).toBe('2026-03-31');
    expect(statement.lines[11]?.bankTransactionCode).toEqual({
      domain: null,
      family: null,
      subFamily: null,
      proprietary: '0150',
      proprietaryIssuer: 'ZZZZ',
    });
  });

  it('uses only invented accounts whose check digits hold', () => {
    const ibans = golden('08').match(/<IBAN>([^<]+)<\/IBAN>/g) ?? [];
    expect(ibans.length).toBeGreaterThan(5);
    for (const iban of ibans) expect(isValidIban(iban.replace(/<\/?IBAN>/g, ''))).toBe(true);
  });
});

describe('one statement, thirteen versions', () => {
  const reference = readCamt053(golden('08'));

  it.each(VERIFIED_VERSIONS)('camt.053.001.%s reads to the same statement', (version) => {
    const file = readCamt053(golden(version));
    expect(file.version).toBe(version);
    expect(file.violations).toEqual([]);
    expect(file.statements).toEqual(reference.statements);
  });
});

describe('an account that is not an IBAN, in XML as some banks write it', () => {
  const file = readCamt053(fixture('other-account.camt.053.001.08.xml'));
  const statement = file.statements[0]!;

  it('identifies the account by what the file gives, scheme and issuer included', () => {
    expect(statement.account.identifier).toEqual({
      kind: 'other',
      value: '0000123456',
      scheme: 'BBAN',
      issuer: 'Example Bank',
    });
    expect(statement.account.currency).toBe('USD');
  });

  it('reads through a prefix, a CDATA section and character references', () => {
    expect(statement.lines[0]?.counterparty).toEqual({
      name: 'Smith & Sons <Example>',
      account: { kind: 'other', value: '999999992 0000654321', scheme: 'ROUTING ACCOUNT', issuer: null },
      agentBic: null,
      ultimateName: null,
    });
    expect(statement.lines[0]?.remittance.unstructured).toEqual(['Invoice N° 12 — café']);
  });

  it('signs an overdrawn balance, keeps the digits the file wrote, and counts only what is booked', () => {
    expect(statement.openingBalance?.amount).toBe('-250.00');
    expect(statement.closingBalance?.amount).toBe('749.5');
    expect(statement.lines.map((line) => [line.amount, line.status, line.booked])).toEqual([
      ['1000', 'BOOK', true],
      ['-0.50', 'BOOKED-LATE', false],
      ['-0.50', 'BOOK', true],
    ]);
    // -250 + 1000 - 0.50 = 749.50: the proprietary status is not counted.
    expect(statement.balanced).toBe(true);
    expect(file.violations).toEqual([]);
  });
});

describe('two statements in one message', () => {
  const file = readCamt053(fixture('two-statements.camt.053.001.02.xml'));

  it('returns both, and says which one each violation is about', () => {
    expect(file.statements.map((statement) => statement.id)).toEqual(['A-2026-01', 'B-2026-01']);
    expect(file.violations.map(({ code, statement, line }) => [code, statement, line])).toEqual([
      ['invalid_iban', 2, undefined],
      ['opening_balance_missing', 2, undefined],
      ['booking_date_missing', 2, 1],
    ]);
  });

  it('opens on the previous closing balance when the bank gives that instead', () => {
    expect(file.statements[0]?.openingBalance).toMatchObject({ type: 'PRCD', amount: '10.00' });
    expect(file.statements[0]?.balanced).toBe(true);
    expect(file.statements[0]?.account.currency).toBeNull();
  });

  it('does not check a balance it has only one end of', () => {
    expect(file.statements[1]?.balanced).toBeNull();
    expect(file.statements[1]?.lines[0]).toMatchObject({ bookingDate: null, valueDate: '2026-01-20' });
  });
});
