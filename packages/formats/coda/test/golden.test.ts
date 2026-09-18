import { existsSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { describe, expect, it } from 'vitest';
import {
  formatBelgianReference,
  isValidBelgianReference,
  isValidCreditorReference,
  isValidIban,
  readCoda,
} from '../src/index.js';
import { ACCOUNT, file, statementRecords } from './build.js';
import { CUSTOMER, INVOICE_REFERENCE, SUPPLIER, golden, next } from './scenario.js';

const here = dirname(fileURLToPath(import.meta.url));
const fixtures = join(here, 'fixtures');

/**
 * The fixtures are committed so that they can be read, and written by
 * `test/build.ts` so that every position of them is accounted for. This is
 * what keeps the two from drifting: `UPDATE_FIXTURES=1 npx vitest run` writes
 * them again, and any other run compares.
 */
function fixture(name: string, content: string): string {
  const path = join(fixtures, name);
  if (process.env['UPDATE_FIXTURES'] === '1' || !existsSync(path)) {
    mkdirSync(fixtures, { recursive: true });
    writeFileSync(path, content);
  }
  return readFileSync(path, 'utf8');
}

describe('the fixtures', () => {
  it('are what the builder writes, position by position', () => {
    expect(fixture('golden.cod', file(golden))).toBe(file(golden));
    expect(fixture('two-statements.cod', file(golden, next))).toBe(file(golden, next));
  });
});

describe('the golden statement', () => {
  const read = readCoda(fixture('golden.cod', file(golden)));
  const statement = read.statements[0]!;

  it('says what it read', () => {
    expect(read).toMatchObject({ format: 'coda', version: '2', namespace: 'coda.2' });
    expect(read.statements).toHaveLength(1);
    expect(read.violations).toEqual([]);
  });

  it('reads the statement, its account and its two balances', () => {
    expect(statement).toMatchObject({
      id: '2026-042',
      electronicSequenceNumber: '42',
      legalSequenceNumber: null,
      paperSequenceNumber: '042',
      createdAt: '2026-03-06',
      account: {
        identifier: { kind: 'iban', value: ACCOUNT },
        currency: 'EUR',
        name: 'COMPTE A VUE',
        ownerName: 'ATELIER EXEMPLE',
        servicerBic: 'ZZZZBEB1',
      },
      openingBalance: { type: 'OPBD', amount: '1000.00', currency: 'EUR', date: '2026-03-04' },
      closingBalance: { type: 'CLBD', amount: '1511.85', currency: 'EUR', date: '2026-03-05' },
      balanced: true,
      duplicate: false,
      fileReference: 'FILE000042',
      separateApplication: '00000',
      freeCommunications: ['VOTRE AGENCE SERA FERMEE LE LUNDI DE PAQUES'],
    });
  });

  it('signs every amount from the holder\'s side, as a string', () => {
    expect(statement.lines.map((line) => line.amount)).toEqual([
      '1210.00',
      '-450.50',
      '-500.00',
      '-420.00',
      '-10.25',
      '-2.15',
      '-75.25',
      '100.00',
      '120.00',
      '40.00',
      '500.00',
    ]);
    for (const line of statement.lines) expect(typeof line.amount).toBe('string');
  });

  it('returns a Belgian structured communication as the twelve digits a camt.053 carries, checked', () => {
    const line = statement.lines[0]!;
    expect(line.remittance).toEqual({
      unstructured: [],
      structured: [{ reference: INVOICE_REFERENCE, type: 'SCOR', issuer: 'BBA' }],
    });
    expect(isValidBelgianReference(INVOICE_REFERENCE)).toBe(true);
    expect(formatBelgianReference(INVOICE_REFERENCE)).toBe('+++202/6000/10704+++');
    expect(line.structuredCommunication).toEqual({ type: '101', text: INVOICE_REFERENCE });
  });

  it('reads the counterparty, its account, its bank, and the references', () => {
    expect(statement.lines[0]).toMatchObject({
      bookingDate: '2026-03-05',
      valueDate: '2026-03-05',
      bankReference: 'REF0000000000000001',
      endToEndId: 'E2E-CLIENT-0001',
      paymentInformationId: null,
      counterparty: {
        name: 'CLIENT EXEMPLE UN',
        account: { kind: 'iban', value: CUSTOMER },
        agentBic: 'ZZZZBEB2',
        ultimateName: null,
      },
      bankTransactionCode: { proprietary: '00150000', proprietaryIssuer: 'CODA', domain: null },
      transactionCode: { type: '0', family: '01', transaction: '50', category: '000' },
      sequenceNumber: '0001',
      detailNumber: '0000',
    });
    expect(statement.lines[0]!.information).toEqual([
      { type: '001', text: expect.stringMatching(/^CLIENT EXEMPLE UN SRL {49}RUE INVENTEE 1 {21}1000 VILLE EXEMPLE$/) },
    ]);
  });

  it('puts a free communication back together from records 2.1, 2.2 and 2.3', () => {
    const line = statement.lines[1]!;
    expect(line.remittance.unstructured).toEqual([
      'FACTURE 2026-0042 DU 28 FEVRIER, MERCI DE VOTRE CONFIANCE ET A BIENTOT POUR LA SUITE DES TRAVAUX CONVENUS',
    ]);
    expect(line.counterparty?.account).toEqual({ kind: 'iban', value: SUPPLIER });
    expect(line.additionalInformation).toBe('ORDRE DONNE PAR LE CANAL EN LIGNE');
    expect(line.valueDate).toBe('2026-03-04');
  });

  it('splits a total into its details when they add up to it, and never counts both', () => {
    const batch = statement.lines.filter((line) => line.entry === 3);
    expect(batch.map((line) => [line.detail, line.detailCount, line.amount, line.entryAmount])).toEqual([
      [1, 2, '-500.00', '-920.00'],
      [2, 2, '-420.00', '-920.00'],
    ]);
    expect(batch.map((line) => line.endToEndId)).toEqual(['E2E-SAL-0001', 'E2E-SAL-0002']);
    expect(batch.map((line) => line.counterparty?.name)).toEqual(['PERSONNE EXEMPLE A', 'PERSONNE EXEMPLE B']);
    expect(batch.map((line) => line.globalisationCode)).toEqual(['0', '1']);
    // The lines of the statement add up to what moved on the account.
    const moved = statement.lines.reduce((sum, line) => sum + BigInt(line.amount!.replace('.', '')), 0n);
    expect(moved).toBe(51185n);
  });

  it('splits charges into commission and tax', () => {
    const charges = statement.lines.filter((line) => line.entry === 4);
    expect(charges.map((line) => [line.amount, line.remittance.unstructured[0], line.transactionCode?.category])).toEqual([
      ['-10.25', 'COMMISSION', '006'],
      ['-2.15', 'TVA', '011'],
    ]);
  });

  it('follows a detail into its own details', () => {
    const total = statement.lines.filter((line) => line.entry === 6);
    expect(total.map((line) => [line.detail, line.detailCount, line.amount, line.bankReference, line.detailNumber])).toEqual([
      [1, 3, '100.00', 'REF000000000000006A', '0001'],
      [2, 3, '120.00', 'REF000000000000006C', '0003'],
      [3, 3, '40.00', 'REF000000000000006D', '0004'],
    ]);
  });

  it('reads a SEPA direct debit out of its structured communication', () => {
    const line = statement.lines.find((candidate) => candidate.entry === 5)!;
    expect(line).toMatchObject({
      mandateId: 'MANDAT-EXEMPLE-0007',
      remittance: { unstructured: ['ABONNEMENT MARS'], structured: [] },
      returnReason: null,
      counterparty: { name: 'CREANCIER EXEMPLE', account: null },
    });
    expect(line.structuredCommunication?.type).toBe('127');
  });

  it('returns an ISO 11649 reference, checked', () => {
    const line = statement.lines.find((candidate) => candidate.entry === 7)!;
    expect(line.remittance.structured).toEqual([{ reference: 'RF18539007547034', type: 'SCOR', issuer: 'ISO' }]);
    expect(isValidCreditorReference('RF18539007547034')).toBe(true);
    expect(line.valueDate).toBeNull();
  });

  it('marks every line booked: a coded statement carries nothing else', () => {
    expect(statement.lines.every((line) => line.booked && line.status === 'BOOK')).toBe(true);
    expect(statement.lines.map((line) => line.index)).toEqual([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]);
  });
});

describe('a file of several statements', () => {
  it('returns every one of them, and the second opens where the first closed', () => {
    const read = readCoda(fixture('two-statements.cod', file(golden, next)));
    expect(read.statements.map((statement) => statement.id)).toEqual(['2026-042', '2026-043']);
    expect(read.statements[1]!.openingBalance?.amount).toBe(read.statements[0]!.closingBalance?.amount);
    expect(read.statements[1]).toMatchObject({ balanced: true, closingBalance: { amount: '1500.00' } });
    expect(read.violations).toEqual([]);
  });
});

describe('what the file is delivered as', () => {
  const expected = readCoda(file(golden));

  it('reads bytes as it reads a string', () => {
    expect(readCoda(new TextEncoder().encode(file(golden)))).toEqual(expected);
  });

  it('reads LF, CR LF, and no line break at all', () => {
    const records = statementRecords(golden);
    expect(readCoda(records.join('\n'))).toEqual(expected);
    expect(readCoda(records.join(''))).toEqual(expected);
  });

  it('reads ISO-8859-1 when told, and never guesses it', () => {
    const accented = file({ ...golden, holder: 'ATELIER EXEMPLÉ' });
    const bytes = Uint8Array.from([...accented].map((character) => character.charCodeAt(0)));
    expect(readCoda(bytes, { encoding: 'iso-8859-1' }).statements[0]!.account.ownerName).toBe('ATELIER EXEMPLÉ');
    expect(() => readCoda(bytes)).toThrowError(/not UTF-8/);
  });
});

describe('the other account structures', () => {
  it('reads a domestic number as what it is, with its currency', () => {
    const read = readCoda(file({ opening: 0n, structure: '0', account: '999000000101', currency: 'EUR', empty: false }));
    expect(read.statements[0]!.account).toMatchObject({
      identifier: { kind: 'other', value: '999000000101', scheme: 'BBAN', issuer: null },
      currency: 'EUR',
    });
  });

  it('reads a foreign IBAN and a currency that is not the euro', () => {
    const account = 'GB' + '00' + 'ZZZZ99900000000101';
    const read = readCoda(file({ opening: 5_000n, structure: '3', account, currency: 'GBP' }));
    expect(read.statements[0]!.openingBalance).toMatchObject({ amount: '5.00', currency: 'GBP' });
    expect(read.violations.map((violation) => violation.code)).toEqual(['invalid_iban']);
    expect(isValidIban(account)).toBe(false);
  });

  it('keeps a third decimal the file wrote, and rounds nothing', () => {
    const read = readCoda(
      file({ opening: 1_005n, currency: 'TND', movements: [{ sequence: 1, amount: -1_001n }] }),
    );
    expect(read.statements[0]).toMatchObject({
      openingBalance: { amount: '1.005' },
      closingBalance: { amount: '0.004' },
      balanced: true,
    });
    expect(read.statements[0]!.lines[0]!.amount).toBe('-1.001');
  });
});
