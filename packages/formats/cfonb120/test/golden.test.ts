import { existsSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { describe, expect, it } from 'vitest';
import { ibanOf, isValidIban, readCfonb120, ribKey } from '../src/index.js';
import { ACCOUNT, BANK, BRANCH, file, statementRecords } from './build.js';
import { CUSTOMER, SUPPLIER, golden, next } from './scenario.js';

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
    expect(fixture('golden.cfonb120.txt', file(golden))).toBe(file(golden));
    expect(fixture('two-statements.cfonb120.txt', file(golden, next))).toBe(file(golden, next));
  });
});

describe('the golden statement', () => {
  const read = readCfonb120(fixture('golden.cfonb120.txt', file(golden)));
  const statement = read.statements[0]!;

  it('says what it read', () => {
    expect(read).toMatchObject({ format: 'cfonb120', version: null, namespace: 'cfonb120' });
    expect(read.statements).toHaveLength(1);
    expect(read.violations).toEqual([]);
  });

  it('reads the statement, its account and its two balances', () => {
    expect(statement).toMatchObject({
      id: '2026-02-28/2026-03-31',
      electronicSequenceNumber: null,
      legalSequenceNumber: null,
      account: {
        identifier: { kind: 'other', value: `${BANK}${BRANCH}${ACCOUNT}`, scheme: null, issuer: null },
        currency: 'EUR',
        bankCode: BANK,
        branchCode: BRANCH,
        accountNumber: ACCOUNT,
        decimals: 2,
      },
      openingBalance: { type: 'OPBD', amount: '1000.00', currency: 'EUR', date: '2026-02-28' },
      closingBalance: { type: 'CLBD', amount: '2111.85', currency: 'EUR', date: '2026-03-31' },
      balanced: true,
    });
  });

  it('reads the sign written over the last digit, and returns strings', () => {
    expect(statement.lines.map((line) => line.amount)).toEqual([
      '1210.00',
      '-450.50',
      '-12.40',
      '-75.25',
      '-60.00',
      '500.00',
    ]);
    for (const line of statement.lines) expect(typeof line.amount).toBe('string');
  });

  it('reads what a SEPA transfer brings in its complements', () => {
    expect(statement.lines[0]).toMatchObject({
      bookingDate: '2026-03-05',
      valueDate: '2026-03-05',
      additionalInformation: 'VIR SEPA CLIENT EXEMPLE UN',
      internalOperationCode: 'V001',
      interbankOperationCode: '05',
      bankTransactionCode: { proprietary: '05', proprietaryIssuer: 'CFONB', domain: null },
      counterparty: { name: 'CLIENT EXEMPLE UN SARL', account: null, agentBic: null, ultimateName: 'GROUPE EXEMPLE' },
      counterpartyIdentifier: { value: 'ZZZZFRP1', type: 'BICOrBEI' },
      endToEndId: 'E2E-CLIENT-0001',
      purpose: 'SUPP',
      paymentInformationId: 'REMISE-0042',
      instructionId: 'TRANSACTION-0007',
      bankReference: null,
      reversal: false,
    });
  });

  it('puts the two lines of a remittance back into the one text they were cut from', () => {
    expect(statement.lines[0]!.remittance).toEqual({
      unstructured: ['FACTURE 2026-0107 DU 28 FEVRIER 2026 - CHANTIER RUE INVENTEE - MERCI POUR VOTRE CONFIANCE'],
      structured: [],
    });
  });

  it('keeps a structured remittance and a free one apart, and names the beneficiary of money going out', () => {
    expect(statement.lines[1]).toMatchObject({
      valueDate: '2026-03-05',
      bookingDate: '2026-03-06',
      remittance: {
        unstructured: ['REGLEMENT FACTURE F-0042'],
        structured: [{ reference: 'RF18539007547034', type: null, issuer: null }],
      },
      counterparty: { name: 'FOURNISSEUR EXEMPLE SAS', account: { kind: 'iban', value: SUPPLIER } },
    });
    expect(isValidIban(SUPPLIER)).toBe(true);
  });

  it('reads a cheque number, and takes zeros for no number', () => {
    expect(statement.lines.map((line) => line.entryNumber)).toEqual([null, null, '0000123', null, null, null]);
  });

  it('reads the mandate of a direct debit', () => {
    expect(statement.lines[3]).toMatchObject({
      mandateId: 'MANDAT-EXEMPLE-0007',
      sequenceType: 'RCUR',
      counterparty: { name: 'CREANCIER EXEMPLE' },
      counterpartyIdentifier: { value: 'FR99ZZZ999999', type: 'SEPA' },
      remittance: { unstructured: ['ABONNEMENT MARS'] },
    });
  });

  it('names the party a rejected operation comes back from', () => {
    expect(statement.lines[4]).toMatchObject({
      reversal: true,
      returnReason: '04',
      counterparty: { name: 'CLIENT EXEMPLE DEUX', account: { kind: 'iban', value: CUSTOMER } },
    });
  });

  it('returns what was ordered in another currency beside what moved, and converts nothing', () => {
    expect(statement.lines[5]).toMatchObject({
      amount: '500.00',
      currency: 'EUR',
      instructedAmount: { amount: '543.21', currency: 'USD' },
      exchangeRate: '1.0864',
      unavailable: true,
      booked: true,
    });
  });

  it('keeps every complement as written, the bank\'s own qualifiers included', () => {
    expect(statement.lines[5]!.complements).toEqual([
      { qualifier: 'MMO', text: 'USD2000000000543210400000010864' },
      { qualifier: 'ZZ1', text: 'UN QUALIFIANT PROPRE A LA BANQUE' },
    ]);
  });
});

describe('a file of several statements', () => {
  it('returns every one of them, and the second opens where the first closed', () => {
    const read = readCfonb120(fixture('two-statements.cfonb120.txt', file(golden, next)));
    expect(read.statements.map((statement) => statement.id)).toEqual([
      '2026-02-28/2026-03-31',
      '2026-03-31/2026-04-30',
    ]);
    expect(read.statements[1]!.openingBalance?.amount).toBe(read.statements[0]!.closingBalance?.amount);
    expect(read.statements[1]).toMatchObject({ balanced: true, closingBalance: { amount: '2000.00' } });
    expect(read.violations).toEqual([]);
  });

  it('reads a month without movement: an old balance and a new one', () => {
    const read = readCfonb120(file({ opening: -5_000n }));
    expect(read.statements[0]).toMatchObject({
      lines: [],
      balanced: true,
      openingBalance: { amount: '-50.00' },
      closingBalance: { amount: '-50.00' },
    });
  });
});

describe('what the file is delivered as', () => {
  const expected = readCfonb120(file(golden));

  it('reads bytes as it reads a string', () => {
    expect(readCfonb120(new TextEncoder().encode(file(golden)))).toEqual(expected);
  });

  it('reads LF, CR LF, and no line break at all', () => {
    const records = statementRecords(golden);
    expect(readCfonb120(records.join('\n'))).toEqual(expected);
    expect(readCfonb120(records.join(''))).toEqual(expected);
  });
});

describe('the number of decimals is read from the record', () => {
  it('reads a currency without decimals', () => {
    const read = readCfonb120(file({ currency: 'JPY', decimals: 0, opening: 150_000n, movements: [{ amount: -20_001n }] }));
    expect(read.statements[0]).toMatchObject({
      openingBalance: { amount: '150000', currency: 'JPY' },
      closingBalance: { amount: '129999' },
      balanced: true,
    });
    expect(read.statements[0]!.lines[0]!.amount).toBe('-20001');
  });

  it('reads a currency with three, and rounds nothing', () => {
    const read = readCfonb120(file({ currency: 'TND', decimals: 3, opening: 1_005n, movements: [{ amount: -1_001n }] }));
    expect(read.statements[0]!.lines[0]!.amount).toBe('-1.001');
    expect(read.statements[0]!.closingBalance?.amount).toBe('0.004');
  });

  it('reads every one of the twenty characters that carry a digit and a sign', () => {
    const credit = '{ABCDEFGHI';
    const debit = '}JKLMNOPQR';
    for (let digit = 0; digit < 10; digit += 1) {
      for (const [characters, sign] of [[credit, 1n], [debit, -1n]] as const) {
        const record = statementRecords({ opening: 0n })[0]!;
        const written = `${record.slice(0, 90)}0000000001234${characters[digit]}${record.slice(104)}`;
        const read = readCfonb120([written, statementRecords({ opening: 0n, closing: sign * BigInt(12340 + digit) })[1]].join('\n'));
        expect(read.statements[0]!.openingBalance?.amount).toBe(
          `${sign < 0n && 12340 + digit > 0 ? '-' : ''}123.4${digit}`,
        );
      }
    }
  });
});

describe('the account, and the country nobody wrote', () => {
  it('returns an IBAN when the caller names the country, and only then', () => {
    const read = readCfonb120(file(golden), { ibanCountry: 'fr' });
    const identifier = read.statements[0]!.account.identifier;
    expect(identifier.kind).toBe('iban');
    expect(isValidIban(identifier.value)).toBe(true);
    expect(identifier.value).toBe(ibanOf('FR', BANK, BRANCH, ACCOUNT));
    expect(identifier.value.slice(4, 25)).toBe(`${BANK}${BRANCH}${ACCOUNT}`);
    expect(readCfonb120(file(golden), { ibanCountry: 'MC' }).statements[0]!.account.identifier.value).toMatch(/^MC/);
  });

  it('computes the key of a relevé d\'identité bancaire, letters included', () => {
    // 89 × 99999 + 15 × 1 + 3 × 1011 (A counts as 1) = 8902959; 97 − (8902959 mod 97).
    expect(ribKey(BANK, BRANCH, ACCOUNT)).toBe(String(97 - (8902959 % 97)).padStart(2, '0'));
    expect(ribKey('9999', BRANCH, ACCOUNT)).toBeNull();
  });

  it('says so when the parts do not make an IBAN, and returns the account as written', () => {
    const read = readCfonb120(file({ opening: 0n, accountNumber: '00000-0101A' }), { ibanCountry: 'FR' });
    expect(read.statements[0]!.account.identifier.kind).toBe('other');
    expect(read.violations.map((violation) => violation.code)).toEqual(['invalid_iban']);
  });
});
