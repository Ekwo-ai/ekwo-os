import { describe, expect, it } from 'vitest';
import { readCsvStatement, type CsvStatementProfile } from '../src/index.js';

// Each profile below is an example of data: the lay-out of one kind of
// export, as a caller would keep it for an account. None of them is known to
// the reader.

/** A bank export with one signed amount column, a header, ISO dates and a full stop. */
const signedProfile: CsvStatementProfile = {
  delimiter: ',',
  dateFormat: 'YYYY-MM-DD',
  decimalSeparator: '.',
  columns: { date: 'Date', amount: 'Amount', counterparty: 'Payee', description: 'Memo' },
};

const signedCsv = [
  'Date,Payee,Memo,Amount',
  '2026-03-02,Studio North,"Invoice 2026-014, March",1250.00',
  '2026-03-05,Office Rent Ltd,Rent March,-800.00',
  '2026-03-09,,Card fee,-2.5',
].join('\n');

describe('one signed amount column', () => {
  const read = readCsvStatement(signedCsv, signedProfile, { account: 'GB82 WEST 1234 5698 7654 32', currency: 'gbp' });
  const statement = read.statements[0]!;

  it('returns one statement, the shape every statement reader returns', () => {
    expect(read.format).toBe('csv');
    expect(read.version).toBeNull();
    expect(read.namespace).toBe('csv');
    expect(read.statements).toHaveLength(1);
    expect(statement.id).toBe('2026-03-02/2026-03-09');
    expect(statement.period).toEqual({ from: '2026-03-02', to: '2026-03-09' });
    expect(statement.account).toEqual({
      identifier: { kind: 'iban', value: 'GB82WEST12345698765432' },
      currency: 'GBP',
      name: null,
      ownerName: null,
      servicerBic: null,
    });
  });

  it('reads every row as a booked line, amounts as decimal strings', () => {
    expect(statement.lines.map((line) => [line.bookingDate, line.amount, line.currency])).toEqual([
      ['2026-03-02', '1250.00', 'GBP'],
      ['2026-03-05', '-800.00', 'GBP'],
      ['2026-03-09', '-2.50', 'GBP'],
    ]);
    expect(statement.lines.every((line) => line.booked && line.status === 'BOOK')).toBe(true);
    expect(statement.lines[0]!.counterparty).toEqual({ name: 'Studio North', account: null, agentBic: null, ultimateName: null });
    expect(statement.lines[0]!.remittance).toEqual({ unstructured: ['Invoice 2026-014, March'], structured: [] });
    expect(statement.lines[2]!.counterparty).toBeNull();
    expect(statement.lines.map((line) => line.row)).toEqual([2, 3, 4]);
  });

  it('carries no balance it was not given, and says nothing was checked', () => {
    expect(statement.openingBalance).toBeNull();
    expect(statement.closingBalance).toBeNull();
    expect(statement.balances).toEqual([]);
    expect(statement.balanced).toBeNull();
    expect(read.violations).toEqual([]);
  });

  it('returns an account given as something else than an IBAN as written', () => {
    const other = readCsvStatement(signedCsv, signedProfile, { account: 'card 4242' });
    expect(other.statements[0]!.account.identifier).toEqual({ kind: 'other', value: 'card4242', scheme: null, issuer: null });
    expect(readCsvStatement(signedCsv, signedProfile).statements[0]!.account.identifier.value).toBe('');
  });
});

describe('a debit and a credit column', () => {
  const profile: CsvStatementProfile = {
    delimiter: ',',
    dateFormat: 'YYYY-MM-DD',
    decimalSeparator: '.',
    columns: { date: 1, description: 2, debit: 3, credit: 4 },
  };

  it('takes the debit out and puts the credit in, whatever sign either is written with', () => {
    const csv = ['Date,Text,Out,In', '2026-04-01,Salary,,3000.00', '2026-04-02,Groceries,54.20,', '2026-04-03,Refund,-10.00,', '2026-04-04,Both,1.00,2.00'].join('\r\n');
    const lines = readCsvStatement(csv, profile).statements[0]!.lines;
    expect(lines.map((line) => line.amount)).toEqual(['3000.00', '-54.20', '-10.00', '1.00']);
  });

  it('names a row with neither', () => {
    const read = readCsvStatement('Date,Text,Out,In\n2026-04-01,Nothing,,\n', profile);
    expect(read.violations.map((violation) => violation.code)).toEqual(['invalid_amount']);
    expect(read.statements[0]!.lines[0]!.amount).toBeNull();
  });
});

describe('a decimal comma, a day before its month, a semicolon', () => {
  const profile: CsvStatementProfile = {
    delimiter: ';',
    dateFormat: 'DD/MM/YYYY',
    decimalSeparator: ',',
    thousandsSeparator: ' ',
    columns: { date: 'Date opération', valueDate: 'Date valeur', amount: 'Montant', description: ['Libellé', 'Détail'] },
  };
  const csv = [
    'Date opération;Date valeur;Libellé;Détail;Montant',
    '01/03/2026;02/03/2026;VIR SEPA;Facture 12;1 234,56',
    '5/3/2026;5/3/2026;PRLV;;-45,1',
  ].join('\n');

  it('reads the dates and the amounts the way the profile says they are written', () => {
    const lines = readCsvStatement(csv, profile).statements[0]!.lines;
    expect(lines.map((line) => [line.bookingDate, line.valueDate, line.amount])).toEqual([
      ['2026-03-01', '2026-03-02', '1234.56'],
      ['2026-03-05', '2026-03-05', '-45.10'],
    ]);
    expect(lines[0]!.remittance.unstructured).toEqual(['VIR SEPA', 'Facture 12']);
    expect(lines[1]!.remittance.unstructured).toEqual(['PRLV']);
  });

  it('reports a date or an amount that is not written that way, and does not guess it', () => {
    const read = readCsvStatement(
      ['Date opération;Date valeur;Libellé;Détail;Montant', '2026-03-01;;X;;1,00', '31/02/2026;;Y;;1.234,00'].join('\n'),
      profile,
    );
    expect(read.violations.map((violation) => [violation.code, violation.row])).toEqual([
      ['invalid_date', 2],
      ['invalid_amount', 3],
      ['invalid_date', 3],
      ['booking_date_missing', 2],
      ['booking_date_missing', 3],
    ]);
  });

  it('reads other date lay-outs, two-digit years and a time after the date', () => {
    const at = (dateFormat: string, cell: string): string | null =>
      readCsvStatement(`D;A\n${cell};1,00`, { ...profile, dateFormat, columns: { date: 'D', amount: 'A' } }).statements[0]!.lines[0]!.bookingDate;
    expect(at('MM/DD/YYYY', '03/14/2026')).toBe('2026-03-14');
    expect(at('DD.MM.YY', '14.03.26')).toBe('2026-03-14');
    expect(at('DD.MM.YY', '14.03.99')).toBe('1999-03-14');
    expect(at('YYYYMMDD', '20260314')).toBe('2026-03-14');
    expect(at('YYYY-MM-DD', '2026-03-14 10:22:05')).toBe('2026-03-14');
    expect(at('YYYY-MM-DD', '2026-03-14T10:22:05Z')).toBe('2026-03-14');
    expect(at('DD/MM/YYYY', '29/02/2028')).toBe('2028-02-29');
  });
});

describe('balances the caller declares', () => {
  const options = { currency: 'EUR', account: 'ACC-1' };

  it('are checked: opening plus the movements is the closing', () => {
    const read = readCsvStatement(signedCsv, signedProfile, { ...options, openingBalance: '100.00', closingBalance: '547.50' });
    const statement = read.statements[0]!;
    expect(statement.openingBalance).toEqual({ type: 'OPBD', amount: '100.00', currency: 'EUR', date: null });
    expect(statement.closingBalance).toEqual({ type: 'CLBD', amount: '547.50', currency: 'EUR', date: '2026-03-09' });
    expect(statement.balanced).toBe(true);
    expect(read.violations).toEqual([]);
  });

  it('are returned as declared when they do not add up, with the difference named', () => {
    const read = readCsvStatement(signedCsv, signedProfile, { ...options, openingBalance: '100.00', closingBalance: '547.49' });
    expect(read.statements[0]!.balanced).toBe(false);
    expect(read.statements[0]!.closingBalance?.amount).toBe('547.49');
    expect(read.violations).toEqual([
      {
        code: 'balance_mismatch',
        statement: 1,
        message: 'opening balance 100.00 plus movements 447.50 is 547.50, and the statement closes at 547.49: a difference of -0.01 EUR',
      },
    ]);
  });

  it('may be one of the two, which proves nothing yet', () => {
    const statement = readCsvStatement(signedCsv, signedProfile, { ...options, openingBalance: '100.00' }).statements[0]!;
    expect(statement.openingBalance?.amount).toBe('100.00');
    expect(statement.closingBalance).toBeNull();
    expect(statement.balanced).toBeNull();
  });
});

describe('a running balance column', () => {
  const profile: CsvStatementProfile = {
    ...signedProfile,
    columns: { ...signedProfile.columns, balance: 'Balance' },
  };
  const csv = [
    'Date,Payee,Memo,Amount,Balance',
    '2026-03-02,Studio North,Invoice,1250.00,1350.00',
    '2026-03-05,Office Rent Ltd,Rent,-800.00,550.00',
    '2026-03-09,,Fee,-2.50,547.50',
  ].join('\n');

  it('gives the opening and the closing balance, and every row is checked against the one before', () => {
    const read = readCsvStatement(csv, profile);
    const statement = read.statements[0]!;
    expect(statement.openingBalance?.amount).toBe('100.00');
    expect(statement.closingBalance?.amount).toBe('547.50');
    expect(statement.lines.map((line) => line.rowBalance)).toEqual(['1350.00', '550.00', '547.50']);
    expect(statement.balanced).toBe(true);
    expect(read.violations).toEqual([]);
  });

  it('names the row whose balance does not follow, and corrects nothing', () => {
    const read = readCsvStatement(csv.replace('550.00', '551.00'), profile);
    expect(read.statements[0]!.balanced).toBe(false);
    expect(read.violations.map((violation) => [violation.code, violation.row])).toEqual([
      ['balance_mismatch', 3],
      ['balance_mismatch', 4],
    ]);
  });

  it('reads a file listed newest first, and returns its lines oldest first', () => {
    const [head, ...rows] = csv.split('\n');
    const read = readCsvStatement([head, ...rows.reverse()].join('\n'), { ...profile, newestFirst: true });
    const statement = read.statements[0]!;
    expect(statement.lines.map((line) => line.amount)).toEqual(['1250.00', '-800.00', '-2.50']);
    expect(statement.lines.map((line) => line.index)).toEqual([1, 2, 3]);
    expect(statement.openingBalance?.amount).toBe('100.00');
    expect(statement.closingBalance?.amount).toBe('547.50');
    expect(read.violations).toEqual([]);
  });

  it('is checked against a balance the caller declares', () => {
    const read = readCsvStatement(csv, profile, { openingBalance: '99.00' });
    expect(read.violations.map((violation) => violation.code)).toContain('balance_mismatch');
    expect(read.statements[0]!.openingBalance?.amount).toBe('99.00');
  });
});

describe('a payment service export: gross, fee, net, several currencies', () => {
  // The lay-out of a payment service's activity download: a gross amount, the
  // fee taken on it and the net in columns of their own, a transaction id, a
  // currency per row and a balance per currency.
  const profile: CsvStatementProfile = {
    delimiter: ',',
    dateFormat: 'DD/MM/YYYY',
    decimalSeparator: '.',
    thousandsSeparator: ',',
    columns: {
      date: 'Date',
      counterparty: 'Name',
      description: 'Type',
      currency: 'Currency',
      amount: 'Gross',
      fee: 'Fee',
      reference: 'Transaction ID',
      balance: 'Balance',
    },
  };
  const csv = [
    '"Date","Time","Time Zone","Name","Type","Status","Currency","Gross","Fee","Net","Balance","Transaction ID"',
    '"01/03/2026","09:12:44","CET","Ada Client","Express Checkout Payment","Completed","EUR","1,200.00","-35.10","1,164.90","1,164.90","7AB12345CD678901E"',
    '"02/03/2026","10:01:00","CET","Bo Buyer","Express Checkout Payment","Completed","USD","50.00","-2.25","47.75","47.75","8CD23456EF789012G"',
    '"03/03/2026","11:30:00","CET","","General Withdrawal","Completed","EUR","-1,000.00","0.00","-1,000.00","164.90","9EF34567GH890123I"',
  ].join('\n');

  it('makes two lines of a row with a fee: the gross amount, then the fee', () => {
    const read = readCsvStatement(csv, profile, { currency: 'EUR', account: 'merchant@example.com', openingBalance: '0.00' });
    const statement = read.statements[0]!;
    expect(statement.lines.map((line) => [line.entry, line.detail, line.detailCount, line.amount, line.additionalInformation])).toEqual([
      [1, 1, 2, '1200.00', null],
      [1, 2, 2, '-35.10', 'Fee'],
      [2, null, null, '-1000.00', null],
    ]);
    expect(statement.lines[0]!.bankReference).toBe('7AB12345CD678901E');
    expect(statement.lines[1]!.bankReference).toBe('7AB12345CD678901E');
    expect(statement.lines[1]!.counterparty?.name).toBe('Ada Client');
  });

  it('leaves the rows of another currency out, as another balance, and says which', () => {
    const read = readCsvStatement(csv, profile, { currency: 'EUR', openingBalance: '0.00' });
    expect(read.violations).toEqual([
      { code: 'other_currency', statement: 1, row: 3, message: 'row 3 is in USD, and the account in EUR: another balance, left out' },
    ]);
    const statement = read.statements[0]!;
    expect(statement.account.currency).toBe('EUR');
    expect(statement.closingBalance?.amount).toBe('164.90');
    expect(statement.balanced).toBe(true);
  });

  it('keeps every row, and says the currencies are mixed, when the account’s is not named', () => {
    const read = readCsvStatement(csv, profile);
    expect(read.violations.map((violation) => violation.code)).toContain('mixed_currencies');
    expect(read.statements[0]!.account.currency).toBeNull();
  });

  it('reads the net column instead, as one line, when the profile names it as the amount', () => {
    const net = readCsvStatement(csv, { ...profile, columns: { ...profile.columns, amount: 'Net', fee: undefined } }, { currency: 'EUR' });
    expect(net.statements[0]!.lines.map((line) => line.amount)).toEqual(['1164.90', '-1000.00']);
  });
});

describe('a card statement', () => {
  // A card issuer lists purchases as positive amounts — what the holder owes —
  // the newest first, with a transaction date and a posting date.
  const profile: CsvStatementProfile = {
    delimiter: ',',
    dateFormat: 'MM/DD/YYYY',
    decimalSeparator: '.',
    sign: 'inverted',
    newestFirst: true,
    columns: { date: 'Post Date', valueDate: 'Transaction Date', description: 'Description', amount: 'Amount' },
  };
  const csv = [
    'Transaction Date,Post Date,Description,Category,Amount',
    '03/28/2026,03/29/2026,PAYMENT THANK YOU,Payment,-500.00',
    '03/14/2026,03/15/2026,HOTEL CENTRAL,Travel,312.40',
    '03/02/2026,03/03/2026,AIRLINE TICKET,Travel,187.60',
  ].join('\n');

  it('turns a purchase into money out and a payment to the card into money in, oldest first', () => {
    const read = readCsvStatement(csv, profile, { account: 'card-0042', currency: 'USD', openingBalance: '-100.00', closingBalance: '-100.00' });
    const statement = read.statements[0]!;
    expect(statement.lines.map((line) => [line.bookingDate, line.valueDate, line.amount])).toEqual([
      ['2026-03-03', '2026-03-02', '-187.60'],
      ['2026-03-15', '2026-03-14', '-312.40'],
      ['2026-03-29', '2026-03-28', '500.00'],
    ]);
    expect(statement.balanced).toBe(true);
    expect(read.violations).toEqual([]);
  });
});

describe('the lines around the table', () => {
  it('skips the title lines above, the totals below, and reads a file without a header by position', () => {
    const csv = ['Account statement', 'Account: 12345', '2026-05-01|Deposit|100.00', '2026-05-02|Coffee|-3.20', 'Total||96.80'].join('\n');
    const read = readCsvStatement(csv, {
      delimiter: '|',
      header: false,
      skipRows: 2,
      skipFooterRows: 1,
      dateFormat: 'YYYY-MM-DD',
      decimalSeparator: '.',
      columns: { date: 1, description: 2, amount: 3 },
    });
    expect(read.statements[0]!.lines.map((line) => [line.row, line.amount])).toEqual([
      [3, '100.00'],
      [4, '-3.20'],
    ]);
    expect(read.violations).toEqual([]);
  });

  it('reads Latin-1 and Windows-1252 bytes when the profile names them', () => {
    const latin1 = Uint8Array.from([...'Date;Libell', 0xe9, ...';Montant\n2026-01-02;Caf', 0xe9, ...';-2,00\n'].map((c) => (typeof c === 'string' ? c.charCodeAt(0) : c)));
    const profile: CsvStatementProfile = {
      delimiter: ';',
      encoding: 'iso-8859-1',
      dateFormat: 'YYYY-MM-DD',
      decimalSeparator: ',',
      columns: { date: 'Date', description: 'Libellé', amount: 'Montant' },
    };
    expect(readCsvStatement(latin1, profile).statements[0]!.lines[0]!.remittance.unstructured).toEqual(['Café']);
    expect(readCsvStatement(latin1, { ...profile, encoding: 'windows-1252' }).statements[0]!.lines[0]!.amount).toBe('-2.00');
  });

  it('reads the same file to the same statement, every time', () => {
    expect(readCsvStatement(signedCsv, signedProfile)).toEqual(readCsvStatement(signedCsv, signedProfile));
  });
});
