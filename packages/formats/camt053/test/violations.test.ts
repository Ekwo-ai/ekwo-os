import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { describe, expect, it } from 'vitest';
import { readCamt053, type Violation } from '../src/index.js';

const here = dirname(fileURLToPath(import.meta.url));
const golden = readFileSync(join(here, 'fixtures', 'golden.camt.053.001.08.xml'), 'utf8');

function change(from: string, to: string): string {
  const out = golden.replace(from, to);
  expect(out, `"${from}" is not in the golden file`).not.toBe(golden);
  return out;
}

const codes = (violations: Violation[]): string[] => violations.map((violation) => violation.code);

describe('a statement that does not add up', () => {
  it('is returned as written, reported to the cent, and never corrected', () => {
    const file = readCamt053(change('<Amt Ccy="EUR">1562.36</Amt>', '<Amt Ccy="EUR">1562.35</Amt>'));
    const statement = file.statements[0]!;
    expect(statement.balanced).toBe(false);
    expect(statement.closingBalance?.amount).toBe('1562.35');
    expect(statement.lines).toHaveLength(12);
    expect(file.violations).toEqual([
      {
        code: 'balance_mismatch',
        statement: 1,
        message:
          'opening 1000.00 plus booked entries 562.36 is 1562.36, and the statement closes at 1562.35: a difference of -0.01 EUR',
      },
    ]);
  });

  it('is caught when a line is missing, which is what a truncated export looks like', () => {
    const start = golden.indexOf('<Ntry>\n        <NtryRef>4</NtryRef>');
    const end = golden.indexOf('<Ntry>\n        <NtryRef>5</NtryRef>');
    const file = readCamt053(golden.slice(0, start) + golden.slice(end));
    expect(codes(file.violations)).toEqual(['balance_mismatch']);
    expect(file.violations[0]?.message).toContain('a difference of -12.40 EUR');
  });

  it('adds without a float: ten thousand lines of 0.10 are exactly 1000.00', () => {
    const entry = `<Ntry><Amt Ccy="EUR">0.10</Amt><CdtDbtInd>CRDT</CdtDbtInd><Sts><Cd>BOOK</Cd></Sts><BookgDt><Dt>2026-03-01</Dt></BookgDt><BkTxCd/></Ntry>`;
    const start = golden.indexOf('<Ntry>');
    const end = golden.lastIndexOf('</Ntry>') + '</Ntry>'.length;
    const file = readCamt053(
      (golden.slice(0, start) + entry.repeat(10_000) + golden.slice(end)).replace('1562.36', '2000.00'),
    );
    expect(file.statements[0]?.lines).toHaveLength(10_000);
    expect(file.statements[0]?.balanced).toBe(true);
    // The same sum in binary floating point is not 1000.
    expect(Array.from({ length: 10_000 }, () => 0.1).reduce((sum, value) => sum + value, 0)).not.toBe(1000);
  });

  it('counts five decimals, which the schema allows', () => {
    const file = readCamt053(
      change('<Amt Ccy="EUR">0.01</Amt>', '<Amt Ccy="EUR">0.01001</Amt>'),
    );
    expect(file.violations[0]?.message).toContain('a difference of -0.00001 EUR');
  });
});

describe('what is wrong on one line stays on that line', () => {
  it('an amount that is not one: the line comes back without it, and the balance is not judged', () => {
    const file = readCamt053(change('<Amt Ccy="EUR">12.40</Amt>', '<Amt Ccy="EUR">12,40</Amt>'));
    expect(file.violations).toMatchObject([{ code: 'invalid_amount', statement: 1, line: 4 }]);
    expect(file.statements[0]?.lines[3]).toMatchObject({ amount: null, bookingDate: '2026-03-10' });
    expect(file.statements[0]?.lines).toHaveLength(12);
    expect(file.statements[0]?.balanced).toBeNull();
  });

  it.each(['-12.40', '1e3', '12.123456', '1234567890123456789', ''])('refuses "%s" as an amount', (amount) => {
    const file = readCamt053(change('<Amt Ccy="EUR">12.40</Amt>', `<Amt Ccy="EUR">${amount}</Amt>`));
    expect(codes(file.violations)).toEqual(['invalid_amount']);
  });

  it('a direction that is neither', () => {
    const file = readCamt053(
      change('<CdtDbtInd>DBIT</CdtDbtInd>\n        <Sts><Cd>BOOK</Cd></Sts>\n        <BookgDt><Dt>2026-03-10', '<CdtDbtInd>OUT</CdtDbtInd>\n        <Sts><Cd>BOOK</Cd></Sts>\n        <BookgDt><Dt>2026-03-10'),
    );
    expect(file.violations).toMatchObject([{ code: 'invalid_direction', line: 4 }]);
  });

  it('a date that does not exist', () => {
    const file = readCamt053(change('<BookgDt><Dt>2026-03-10</Dt>', '<BookgDt><Dt>2026-02-30</Dt>'));
    expect(file.violations).toMatchObject([{ code: 'invalid_date', line: 4 }]);
    expect(file.statements[0]?.lines[3]?.bookingDate).toBeNull();
    expect(file.statements[0]?.balanced).toBe(true);
  });

  it('an entry in another currency than the account: reported, not converted, and the balance is not judged', () => {
    const file = readCamt053(change('<Amt Ccy="EUR">12.40</Amt>', '<Amt Ccy="CHF">12.40</Amt>'));
    expect(file.violations).toMatchObject([{ code: 'foreign_currency_entry', line: 4 }]);
    expect(file.statements[0]?.lines[3]).toMatchObject({ amount: '-12.40', currency: 'CHF' });
    expect(file.statements[0]?.balanced).toBeNull();
  });

  it('a counterparty IBAN that fails its check digits', () => {
    const file = readCamt053(change('<IBAN>FR499999900000000000010199</IBAN>', '<IBAN>FR489999900000000000010199</IBAN>'));
    expect(file.violations).toMatchObject([{ code: 'invalid_iban', line: 1 }]);
    expect(file.statements[0]?.lines[0]?.counterparty?.account).toEqual({
      kind: 'iban',
      value: 'FR489999900000000000010199',
    });
  });

  it('two entries under one bank reference, or one entry reference', () => {
    const file = readCamt053(
      change('<AcctSvcrRef>ZZ26030500002</AcctSvcrRef>', '<AcctSvcrRef>ZZ26030300001</AcctSvcrRef>').replace(
        '<NtryRef>2</NtryRef>',
        '<NtryRef>1</NtryRef>',
      ),
    );
    expect(file.violations).toMatchObject([
      { code: 'duplicate_bank_reference', line: 2 },
      { code: 'duplicate_entry_reference', line: 2 },
    ]);
  });
});

describe('a batch', () => {
  it('is kept whole when its transactions do not add up to it', () => {
    const file = readCamt053(change('<Amt Ccy="EUR">80.00</Amt>', '<Amt Ccy="EUR">79.00</Amt>'));
    expect(file.violations).toMatchObject([{ code: 'batch_not_split', line: 6 }]);
    expect(file.violations[0]?.message).toContain('add up to 299.00 and the entry is 300.00');
    const line = file.statements[0]!.lines[5]!;
    expect(line).toMatchObject({
      amount: '300.00',
      detail: null,
      detailCount: null,
      bankReference: 'ZZ26031700006',
      counterparty: null,
    });
    expect(file.statements[0]?.lines).toHaveLength(10);
    // The entry is what moved on the account, so the statement still balances.
    expect(file.statements[0]?.balanced).toBe(true);
  });

  it('is kept whole when a transaction is in another currency', () => {
    const file = readCamt053(change('<Amt Ccy="EUR">80.00</Amt>', '<Amt Ccy="USD">80.00</Amt>'));
    expect(codes(file.violations)).toEqual(['batch_not_split']);
  });

  it('says when it announces a count it does not detail', () => {
    const file = readCamt053(change('<NbOfTxs>3</NbOfTxs>', '<NbOfTxs>4</NbOfTxs>'));
    expect(file.violations).toMatchObject([{ code: 'batch_count_mismatch', line: 6 }]);
    expect(file.statements[0]?.lines).toHaveLength(12);
  });

  it('is one line when the bank gives the total and no detail', () => {
    const start = golden.indexOf('<TxDtls>\n            <Refs><AcctSvcrRef>ZZ26031700006-1');
    const end = golden.indexOf('</NtryDtls>', start);
    const file = readCamt053(golden.slice(0, start) + golden.slice(end));
    expect(file.violations).toEqual([]);
    expect(file.statements[0]?.lines[5]).toMatchObject({ amount: '300.00', detail: null });
  });
});

describe('a version nobody has checked', () => {
  it('is read, and said not to be verified', () => {
    const file = readCamt053(golden.replaceAll('camt.053.001.08', 'camt.053.001.27'));
    expect(file.version).toBe('27');
    expect(file.versionVerified).toBe(false);
    expect(file.violations).toMatchObject([{ code: 'version_not_verified', statement: 1 }]);
    expect(file.statements[0]?.balanced).toBe(true);
  });
});
