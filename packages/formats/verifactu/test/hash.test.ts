import { createHash } from 'node:crypto';
import { describe, expect, it } from 'vitest';
import { VERIFACTU, type FiscalRecordInput } from '../src/index.js';
import { sha256 } from '../src/hash.js';
import { SELLER, SYSTEM } from './fixtures.js';

/**
 * The three examples of the AEAT's *Detalle de las especificaciones técnicas
 * para generación de la huella o hash de los registros de facturación*,
 * version 0.1.2 of 27 August 2024, section 6 — the data of each record, the
 * text the fingerprint is computed on, and the fingerprint the AEAT says it
 * must give. Each is built here from a document as the books hold it, so the
 * vector tests the whole path: from the rows to the record, and from the
 * record to its `Huella`.
 */

const sale = (number: string): FiscalRecordInput['header'] => ({
  ...SELLER,
  doc_type: 'sale_invoice',
  number,
  document_date: '2024-01-01',
  currency_code: 'EUR',
  amount_untaxed: '111.10',
  amount_tax: '12.35',
  amount_total: '123.45',
  buyer_name: 'Cliente',
  buyer_vat_number: 'B12345678',
  buyer_country: 'ES',
});

const record = (header: FiscalRecordInput['header'], kind: FiscalRecordInput['kind'], generatedAt: string, previous: FiscalRecordInput['previous']): FiscalRecordInput => ({
  header,
  lines: [],
  taxes: [],
  kind,
  generatedAt,
  system: SYSTEM,
  previous,
});

const CASE_1 = record(sale('12345678/G33'), 'alta', '2024-01-01T19:20:30+01:00', null);
const HASH_1 = '3C464DAF61ACB827C65FDA19F352A4E3BDC2C640E9E9FC4CC058073F38F12F60';

const CASE_2 = record(sale('12345679/G34'), 'alta', '2024-01-01T19:20:35+01:00', {
  taxId: '89890001K',
  series: '',
  number: '12345678/G33',
  issuedOn: '2024-01-01',
  hash: HASH_1,
});
const HASH_2 = 'F7B94CFD8924EDFF273501B01EE5153E4CE8F259766F88CF6ACB8935802A2B97';

const CASE_3 = record(sale('12345679/G34'), 'anulacion', '2024-01-01T19:20:40+01:00', {
  taxId: '89890001K',
  series: '',
  number: '12345679/G34',
  issuedOn: '2024-01-01',
  hash: HASH_2,
});
const HASH_3 = '177547C0D57AC74748561D054A9CEC14B4C4EA23D1BEFD6F2E69E3A388F90C68';

describe('the fingerprint, against the examples of the AEAT', () => {
  it('case 1: the first record of a system, de alta', () => {
    expect(VERIFACTU.hashInput(CASE_1)).toBe(
      'IDEmisorFactura=89890001K&NumSerieFactura=12345678/G33&FechaExpedicionFactura=01-01-2024&TipoFactura=F1&CuotaTotal=12.35&ImporteTotal=123.45&Huella=&FechaHoraHusoGenRegistro=2024-01-01T19:20:30+01:00',
    );
    expect(VERIFACTU.hash(CASE_1)).toBe(HASH_1);
  });

  it('case 2: a record de alta chained to the first', () => {
    expect(VERIFACTU.hashInput(CASE_2)).toBe(
      `IDEmisorFactura=89890001K&NumSerieFactura=12345679/G34&FechaExpedicionFactura=01-01-2024&TipoFactura=F1&CuotaTotal=12.35&ImporteTotal=123.45&Huella=${HASH_1}&FechaHoraHusoGenRegistro=2024-01-01T19:20:35+01:00`,
    );
    expect(VERIFACTU.hash(CASE_2)).toBe(HASH_2);
  });

  it('case 3: a record de anulación chained to the second', () => {
    expect(VERIFACTU.hashInput(CASE_3)).toBe(
      `IDEmisorFacturaAnulada=89890001K&NumSerieFacturaAnulada=12345679/G34&FechaExpedicionFacturaAnulada=01-01-2024&Huella=${HASH_2}&FechaHoraHusoGenRegistro=2024-01-01T19:20:40+01:00`,
    );
    expect(VERIFACTU.hash(CASE_3)).toBe(HASH_3);
  });

  it('writes in the record the fingerprint it computes, and the one before in its chain', () => {
    const { content } = VERIFACTU.write(CASE_2);
    expect(content).toContain(`<sf:Huella>${HASH_2}</sf:Huella>`);
    expect(content).toContain(`<sf:RegistroAnterior>`);
    expect(content).toContain(`<sf:Huella>${HASH_1}</sf:Huella>`);
    expect(content).toContain('<sf:TipoHuella>01</sf:TipoHuella>');
  });
});

describe('the concatenation', () => {
  it('trims every value the way Java trims it, and only around it', () => {
    const padded = record({ ...sale(' \t12345678 / G33\n'), seller_vat_number: ' ES89890001K ' }, 'alta', '2024-01-01T19:20:30+01:00', null);
    expect(VERIFACTU.hashInput(padded)).toContain('&NumSerieFactura=12345678 / G33&');
  });

  it('writes two decimals, which the AEAT holds equal to one', () => {
    const header = { ...sale('A-1'), amount_tax: '12.3', amount_total: '123.4' };
    expect(VERIFACTU.hashInput(record(header, 'alta', '2024-01-01T19:20:30+01:00', null))).toContain(
      '&CuotaTotal=12.30&ImporteTotal=123.40&',
    );
  });

  it('writes a field the record lacks as its name and = alone', () => {
    // A credit note to an identified buyer whose article the books do not
    // record has no TipoFactura: the record leaves it out, and so does the
    // fingerprint, the way the AEAT writes the empty Huella of a first record.
    const header = { ...sale('AB-1'), doc_type: 'sale_credit_note' };
    expect(VERIFACTU.hashInput(record(header, 'alta', '2024-01-01T19:20:30+01:00', null))).toContain(
      '&TipoFactura=&CuotaTotal=-12.35&ImporteTotal=-123.45&',
    );
  });
});

describe('SHA-256, written out', () => {
  it('agrees with Node on every length around a block', () => {
    for (let length = 0; length < 200; length += 1) {
      const bytes = new Uint8Array(length).map((_, i) => (i * 31 + length) & 0xff);
      expect(Buffer.from(sha256(bytes)).toString('hex')).toBe(createHash('sha256').update(bytes).digest('hex'));
    }
  });

  it('hashes the UTF-8 of the text', () => {
    const input = record({ ...sale('Ñ-1'), seller_legal_name: 'Ñandú' }, 'alta', '2024-01-01T19:20:30+01:00', null);
    expect(VERIFACTU.hash(input)).toBe(
      createHash('sha256').update(VERIFACTU.hashInput(input), 'utf8').digest('hex').toUpperCase(),
    );
  });
});
