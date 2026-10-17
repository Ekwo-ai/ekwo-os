import { describe, expect, it } from 'vitest';
import { AEAT_ERRORS, VERIFACTU, VerifactuError, type FiscalRecordInput, type Row } from '../src/index.js';
import { CREDIT_NOTE, INVOICE, STANDARD, SYSTEM, alta, withTax } from './fixtures.js';

const codes = (input: FiscalRecordInput): string[] => VERIFACTU.write(input).violations.map((each) => each.code);

/** The text of one element of a record, or null. */
function element(xml: string, name: string): string | null {
  const match = new RegExp(`<sf:${name}>([^<]*)</sf:${name}>`).exec(xml);
  return match ? (match[1] as string) : null;
}

describe('a chain of records', () => {
  it('starts with PrimerRegistro and an empty previous fingerprint', () => {
    const first = alta();
    const written = VERIFACTU.write(first);
    expect(written.violations).toEqual([]);
    expect(written.content).toContain('<sf:PrimerRegistro>S</sf:PrimerRegistro>');
    expect(written.content).not.toContain('RegistroAnterior');
    expect(VERIFACTU.hashInput(first)).toContain('&Huella=&');
    expect(written.filename).toBe('verifactu-alta-F2026-0001.xml');
    expect(written.mediaType).toBe('application/xml');
  });

  it('chains the second to the first by its NIF, number, date and fingerprint', () => {
    const first = alta();
    const second = alta({
      header: { ...INVOICE, number: 'F2026-0002', document_date: '2026-03-03' },
      generatedAt: '2026-03-03T09:00:00+01:00',
      previous: { taxId: 'ES89890001K', series: 'F2026-', number: '0001', issuedOn: '2026-03-02', hash: VERIFACTU.hash(first) },
    });
    const written = VERIFACTU.write(second);
    expect(written.violations).toEqual([]);
    expect(written.content).toContain(
      [
        '<sf:RegistroAnterior>',
        '      <sf:IDEmisorFactura>89890001K</sf:IDEmisorFactura>',
        '      <sf:NumSerieFactura>F2026-0001</sf:NumSerieFactura>',
        '      <sf:FechaExpedicionFactura>02-03-2026</sf:FechaExpedicionFactura>',
        `      <sf:Huella>${VERIFACTU.hash(first)}</sf:Huella>`,
        '    </sf:RegistroAnterior>',
      ].join('\n'),
    );
    expect(VERIFACTU.hashInput(second)).toContain(`&Huella=${VERIFACTU.hash(first)}&`);
    expect(VERIFACTU.hash(second)).not.toBe(VERIFACTU.hash(first));
  });

  it('cancels a record with a RegistroAnulacion chained like any other', () => {
    const first = alta();
    const cancel = alta({
      kind: 'anulacion',
      generatedAt: '2026-03-04T12:00:00+01:00',
      previous: { taxId: '89890001K', series: '', number: 'F2026-0001', issuedOn: '2026-03-02', hash: VERIFACTU.hash(first) },
    });
    const written = VERIFACTU.write(cancel);
    expect(written.violations).toEqual([]);
    expect(written.filename).toBe('verifactu-anulacion-F2026-0001.xml');
    expect(written.content).toContain('<sf:RegistroAnulacion xmlns:sf=');
    expect(element(written.content, 'IDEmisorFacturaAnulada')).toBe('89890001K');
    expect(element(written.content, 'NumSerieFacturaAnulada')).toBe('F2026-0001');
    expect(element(written.content, 'FechaExpedicionFacturaAnulada')).toBe('02-03-2026');
    expect(written.content).not.toContain('Desglose');
    expect(VERIFACTU.hashInput(cancel)).toBe(
      `IDEmisorFacturaAnulada=89890001K&NumSerieFacturaAnulada=F2026-0001&FechaExpedicionFacturaAnulada=02-03-2026&Huella=${VERIFACTU.hash(first)}&FechaHoraHusoGenRegistro=2026-03-04T12:00:00+01:00`,
    );
  });
});

describe('a record de alta', () => {
  it('carries the invoice as the books hold it', () => {
    const { content } = VERIFACTU.write(alta());
    expect(element(content, 'IDVersion')).toBe('1.0');
    expect(element(content, 'IDEmisorFactura')).toBe('89890001K');
    expect(element(content, 'NombreRazonEmisor')).toBe('Empresa Ejemplo SL');
    expect(element(content, 'TipoFactura')).toBe('F1');
    expect(element(content, 'DescripcionOperacion')).toBe('Consulting, March');
    expect(element(content, 'NIF')).toBe('B12345678');
    expect(element(content, 'CuotaTotal')).toBe('210.00');
    expect(element(content, 'ImporteTotal')).toBe('1210.00');
    expect(element(content, 'FechaHoraHusoGenRegistro')).toBe('2026-03-02T10:15:00+01:00');
    expect(content).not.toContain('FechaOperacion');
  });

  it('takes the header note as the description where there is one', () => {
    const { content } = VERIFACTU.write(alta({ header: { ...INVOICE, note: 'Consultoría de marzo' } }));
    expect(element(content, 'DescripcionOperacion')).toBe('Consultoría de marzo');
  });

  it('writes the date of the operation only where it differs from the date of issue', () => {
    const earlier = VERIFACTU.write(alta({ header: { ...INVOICE, tax_point_date: '2026-02-27' } }));
    expect(element(earlier.content, 'FechaOperacion')).toBe('27-02-2026');
    expect(earlier.violations).toEqual([]);
    const same = VERIFACTU.write(alta({ header: { ...INVOICE, delivery_date: '2026-03-02' } }));
    expect(same.content).not.toContain('FechaOperacion');
  });

  it('is simplified, F2, where the buyer is not identified', () => {
    const written = VERIFACTU.write(alta({ header: { ...INVOICE, buyer_vat_number: null, buyer_name: 'Walk-in customer' } }));
    expect(element(written.content, 'TipoFactura')).toBe('F2');
    expect(written.content).not.toContain('Destinatarios');
    expect(written.violations).toEqual([]);
  });

  it('identifies a buyer of another Member State by its VAT number', () => {
    const header = { ...INVOICE, buyer_vat_number: 'FR40303265045', buyer_country: 'FR' };
    const { content } = VERIFACTU.write(alta({ header }));
    expect(content).toContain('<sf:IDType>02</sf:IDType>\n        <sf:ID>FR40303265045</sf:ID>');
  });

  it('marks the invoices of a hundred million euros and more', () => {
    const tax = { ...STANDARD, base_amount: '90000000.00', tax_charged: '18900000.00' };
    const { content, violations } = VERIFACTU.write(withTax(tax));
    expect(element(content, 'Macrodato')).toBe('S');
    expect(violations).toEqual([]);
  });
});

describe('the tax breakdown', () => {
  const detail = (tax: Row): Record<string, string | null> => {
    const { content } = VERIFACTU.write(withTax(tax));
    const fields = ['Impuesto', 'ClaveRegimen', 'CalificacionOperacion', 'OperacionExenta', 'TipoImpositivo', 'BaseImponibleOimporteNoSujeto', 'CuotaRepercutida'];
    return Object.fromEntries(fields.map((name) => [name, element(content, name)]));
  };

  it('writes a standard rate as S1 under the general regime', () => {
    expect(detail(STANDARD)).toEqual({
      Impuesto: '01',
      ClaveRegimen: '01',
      CalificacionOperacion: 'S1',
      OperacionExenta: null,
      TipoImpositivo: '21',
      BaseImponibleOimporteNoSujeto: '1000.00',
      CuotaRepercutida: '210.00',
    });
  });

  it('writes a zero rate as S1 at 0', () => {
    const zero = { tax_code: 'ES-S-00-ALIM', vat_category: 'Z', tax_rate: '0', base_amount: '100.00', tax_charged: '0.00' };
    expect(detail(zero)).toMatchObject({ CalificacionOperacion: 'S1', TipoImpositivo: '0', CuotaRepercutida: '0.00' });
  });

  it('writes a domestic reverse charge as S2, with a rate and a tax of zero', () => {
    const reverse = { tax_code: 'ES-S-ISP', vat_category: 'AE', tax_rate: '0', base_amount: '100.00', tax_charged: '0.00', exemption_code: 'VATEX-EU-AE' };
    expect(detail(reverse)).toMatchObject({ ClaveRegimen: '01', CalificacionOperacion: 'S2', TipoImpositivo: '0', CuotaRepercutida: '0.00' });
  });

  it('writes an exemption of article 20 as E1, without rate or tax', () => {
    const exempt = { tax_code: 'ES-S-EXE', vat_category: 'E', tax_rate: '0', base_amount: '100.00', tax_charged: '0.00', exemption_code: 'VATEX-EU-132' };
    expect(detail(exempt)).toMatchObject({ ClaveRegimen: '01', OperacionExenta: 'E1', CalificacionOperacion: null, TipoImpositivo: null, CuotaRepercutida: null });
  });

  it('writes an export under regime 02, exempt by article 21', () => {
    const exported = { tax_code: 'ES-S-EXP', vat_category: 'G', tax_rate: '0', base_amount: '100.00', tax_charged: '0.00', exemption_code: 'VATEX-EU-G' };
    expect(detail(exported)).toMatchObject({ ClaveRegimen: '02', OperacionExenta: 'E2', TipoImpositivo: null });
  });

  it('asks the row which of E5 and N2 a supply to another Member State is', () => {
    const intra = { tax_code: 'ES-S-ICS', vat_category: 'K', tax_rate: '0', base_amount: '100.00', tax_charged: '0.00', exemption_code: 'VATEX-EU-IC' };
    expect(codes(withTax(intra))).toEqual(['input:aeat_qualification']);
    expect(detail({ ...intra, aeat_qualification: 'N2' })).toMatchObject({ ClaveRegimen: '01', CalificacionOperacion: 'N2', TipoImpositivo: null });
    expect(detail({ ...intra, aeat_qualification: 'E5' })).toMatchObject({ OperacionExenta: 'E5' });
  });

  it('asks the row which of N1 and N2 an operation outside the scope is', () => {
    const outside = { tax_code: 'ES-S-NS', vat_category: 'O', base_amount: '100.00', tax_charged: '0.00', exemption_code: 'VATEX-EU-O' };
    expect(codes(withTax(outside))).toEqual(['input:aeat_qualification']);
    expect(codes(withTax({ ...outside, aeat_qualification: 'N2' }))).toEqual([]);
  });

  it('takes the regime and the tax the row carries', () => {
    expect(detail({ ...STANDARD, aeat_regime: '07' })).toMatchObject({ ClaveRegimen: '07' });
    expect(detail({ ...STANDARD, aeat_tax: '03', tax_rate: '7', tax_charged: '70.00' })).toMatchObject({ Impuesto: '03', TipoImpositivo: '7' });
  });
});

describe('a credit note', () => {
  const credit = (header: Row = CREDIT_NOTE): FiscalRecordInput =>
    alta({ header, taxes: [{ ...STANDARD, base_amount: '200.00', tax_charged: '42.00' }], generatedAt: '2026-03-20T16:00:00+01:00' });

  it('is a rectification by difference, its figures negative, with the invoice it rectifies', () => {
    const written = VERIFACTU.write(credit());
    expect(written.violations).toEqual([]);
    expect(element(written.content, 'TipoFactura')).toBe('R1');
    expect(element(written.content, 'TipoRectificativa')).toBe('I');
    expect(written.content).toContain(
      [
        '<sf:FacturasRectificadas>',
        '    <sf:IDFacturaRectificada>',
        '      <sf:IDEmisorFactura>89890001K</sf:IDEmisorFactura>',
        '      <sf:NumSerieFactura>F2026-0001</sf:NumSerieFactura>',
        '      <sf:FechaExpedicionFactura>02-03-2026</sf:FechaExpedicionFactura>',
        '    </sf:IDFacturaRectificada>',
        '  </sf:FacturasRectificadas>',
      ].join('\n'),
    );
    expect(element(written.content, 'BaseImponibleOimporteNoSujeto')).toBe('-200.00');
    expect(element(written.content, 'CuotaRepercutida')).toBe('-42.00');
    expect(element(written.content, 'CuotaTotal')).toBe('-42.00');
    expect(element(written.content, 'ImporteTotal')).toBe('-242.00');
  });

  it('is R5 where it rectifies a simplified invoice, to a buyer not identified', () => {
    const header = { ...CREDIT_NOTE, rectification_type: null, buyer_vat_number: null };
    const written = VERIFACTU.write(credit(header));
    expect(element(written.content, 'TipoFactura')).toBe('R5');
    expect(written.violations).toEqual([]);
  });

  it('names the article it rectifies under as missing, rather than choose one', () => {
    const written = VERIFACTU.write(credit({ ...CREDIT_NOTE, rectification_type: null }));
    expect(written.violations.map((each) => each.code)).toEqual(['input:rectification_type']);
    expect(written.content).not.toContain('TipoFactura');
  });
});

describe('what makes a record absurd is thrown', () => {
  it.each([
    ['no document', { header: undefined }],
    ['a purchase', { header: { ...INVOICE, doc_type: 'purchase_invoice' } }],
    ['a document never numbered', { header: { ...INVOICE, number: null } }],
    ['a date that is not one', { header: { ...INVOICE, document_date: '2026-02-30' } }],
    ['an amount that is not one', { header: { ...INVOICE, amount_total: '1.210,00' } }],
    ['a kind of record that does not exist', { kind: 'modificacion' }],
  ])('%s', (_, overrides) => {
    expect(() => VERIFACTU.write(alta(overrides as Partial<FiscalRecordInput>))).toThrow(VerifactuError);
  });
});

/** Every rule this package reports, each broken once, by the smallest change that breaks it. */
const HASH = 'A'.repeat(64);
const PREVIOUS = { taxId: '89890001K', series: '', number: 'F2026-0000', issuedOn: '2026-03-01', hash: HASH };
const FIRST_2024 = { ...INVOICE, document_date: '2024-11-04' };

const BROKEN: Array<[string, Partial<FiscalRecordInput>]> = [
  ['1100', { header: { ...INVOICE, seller_legal_name: 'x'.repeat(121) } }],
  ['1102', { header: { ...INVOICE, buyer_vat_number: 'US123456789', buyer_country: 'US' } }],
  ['1104', { header: { ...INVOICE, number: 'F'.repeat(61) } }],
  ['1112', { header: { ...INVOICE, document_date: '2026-03-03' } }],
  ['1124', { taxes: [{ ...STANDARD, tax_rate: '15', tax_charged: '150.00' }], header: { ...INVOICE, amount_tax: '150.00', amount_total: '1150.00' } }],
  ['1130', { header: { ...INVOICE, number: 'F<1>' } }],
  ['1132', { taxes: [{ ...STANDARD, tax_rate: '18', tax_charged: '180.00' }], header: { ...INVOICE, amount_tax: '180.00', amount_total: '1180.00' } }],
  ['1142', { taxes: [{ ...STANDARD, tax_charged: '230.00' }], header: { ...INVOICE, amount_tax: '230.00', amount_total: '1230.00' } }],
  ['1143', { taxes: [{ ...STANDARD, base_amount: '-5.00', tax_charged: '1.05' }], header: { ...INVOICE, amount_tax: '1.05', amount_total: '-3.95' } }],
  ['1146', { header: { ...INVOICE, tax_point_date: '2026-03-10' }, generatedAt: '2026-03-12T10:00:00+01:00' }],
  ['1150', { header: { ...INVOICE, buyer_vat_number: null, amount_untaxed: '3000.00', amount_tax: '630.00', amount_total: '3630.00' }, taxes: [{ ...STANDARD, base_amount: '3000.00', tax_charged: '630.00' }] }],
  ['1152', { header: { ...INVOICE, document_date: '2024-10-27' } }],
  ['1173', { header: { ...INVOICE, tax_point_date: '2026-03-05' } }],
  ['1174', { previous: { ...PREVIOUS, issuedOn: 'yesterday' } }],
  ['1175', { previous: { ...PREVIOUS, number: '' } }],
  ['1176', { system: { ...SYSTEM, producerTaxId: 'US-123' } }],
  ['1177', { system: { ...SYSTEM, id: 'ek' } }],
  ['1179', { system: { ...SYSTEM, version: '' } }],
  ['1181', { taxes: [{ ...STANDARD, aeat_qualification: 'S9' }] }],
  ['1182', { taxes: [{ ...STANDARD, aeat_qualification: 'E9' }] }],
  ['1189', { header: { ...CREDIT_NOTE, buyer_vat_number: null }, generatedAt: '2026-03-20T16:00:00+01:00', taxes: [{ ...STANDARD, base_amount: '200.00', tax_charged: '42.00' }] }],
  ['1190', { header: { ...CREDIT_NOTE, rectification_type: 'R5' }, generatedAt: '2026-03-20T16:00:00+01:00', taxes: [{ ...STANDARD, base_amount: '200.00', tax_charged: '42.00' }] }],
  ['1194', { taxes: [{ ...STANDARD, tax_rate: '5', tax_charged: '50.00' }], header: { ...INVOICE, amount_tax: '50.00', amount_total: '1050.00' } }],
  ['1198', { taxes: [{ ...STANDARD, vat_category: 'AE', tax_rate: '0', tax_charged: '210.00' }] }],
  ['1199', { taxes: [{ ...STANDARD, vat_category: 'E', exemption_code: 'VATEX-EU-132', aeat_qualification: 'E2', tax_rate: '0', tax_charged: '0.00' }], header: { ...INVOICE, amount_tax: '0.00', amount_total: '1000.00' } }],
  ['1207', { taxes: [{ ...STANDARD, vat_category: 'K', exemption_code: 'VATEX-EU-IC', tax_rate: '0' }] }],
  ['1208', { taxes: [{ ...STANDARD, tax_rate: null }] }],
  ['1212', { system: { ...SYSTEM, verifactuOnly: undefined } }],
  ['1213', { system: { ...SYSTEM, multipleTaxpayers: undefined } }],
  ['1218', { taxes: [{ ...STANDARD, aeat_tax: '04' }] }],
  ['1219', { header: { ...INVOICE, seller_vat_number: 'FR40303265045' } }],
  ['1220', { system: { ...SYSTEM, name: 'A system whose name is longer than thirty characters' } }],
  ['1226', { system: { ...SYSTEM, multipleTaxpayersNow: undefined } }],
  ['1235', { taxes: [{ ...STANDARD, tax_rate: '2', tax_charged: '20.00' }], header: { ...INVOICE, amount_tax: '20.00', amount_total: '1020.00' } }],
  ['1237', { taxes: [{ ...STANDARD, vat_category: 'O', aeat_qualification: 'N2' }] }],
  ['1238', { taxes: [{ ...STANDARD, vat_category: 'E', exemption_code: 'VATEX-EU-132' }] }],
  ['1244', { generatedAt: '2026-03-02T09:15:00Z' }],
  ['1246', { taxes: [{ ...STANDARD, aeat_regime: '99' }] }],
  ['1252', { taxes: [{ ...STANDARD, aeat_regime: '08' }] }],
  ['1266', { header: { ...INVOICE, amount_tax: '1000000000000.00' } }],
  ['1267', { header: { ...INVOICE, amount_total: '1000000000000.00' } }],
  ['1269', { previous: { ...PREVIOUS, taxId: 'nobody' } }],
  ['1286', { taxes: [{ ...STANDARD, aeat_regime: '02' }] }],
  ['1291', { previous: { ...PREVIOUS, hash: 'a'.repeat(64) } }],
  ['2002', { previous: { ...PREVIOUS, hash: 'ABC' } }],
  ['2003', { previous: { ...PREVIOUS, hash: 'G'.repeat(64) } }],
  ['2005', { header: { ...INVOICE, amount_total: '1250.00' } }],
  ['2006', { header: { ...INVOICE, amount_tax: '250.00' } }],
  ['4102', { header: { ...INVOICE, seller_name: null, seller_legal_name: null } }],
  ['4113', { taxes: [STANDARD, ...Array.from({ length: 12 }, (): Row => ({ ...STANDARD, base_amount: '0.00', tax_charged: '0.00' }))] }],
  ['input:currency', { header: { ...INVOICE, currency_code: 'USD' } }],
  ['input:aeat_qualification', { taxes: [{ ...STANDARD, vat_category: 'K', exemption_code: 'VATEX-EU-IC', tax_rate: '0', tax_charged: '0.00' }], header: { ...INVOICE, amount_tax: '0.00', amount_total: '1000.00' } }],
  ['input:rectification_type', { header: { ...CREDIT_NOTE, rectification_type: null }, generatedAt: '2026-03-20T16:00:00+01:00', taxes: [{ ...STANDARD, base_amount: '200.00', tax_charged: '42.00' }] }],
];

describe('every rule, named by the AEAT', () => {
  it.each(BROKEN)('%s', (code, overrides) => {
    const found = VERIFACTU.write(alta(overrides)).violations;
    expect(found.map((each) => each.code)).toContain(code);
    const violation = found.find((each) => each.code === code);
    if (code in AEAT_ERRORS) {
      const [severity, sentence] = AEAT_ERRORS[code as keyof typeof AEAT_ERRORS];
      expect(violation?.severity).toBe(severity);
      expect(violation?.message.startsWith(sentence)).toBe(true);
    } else {
      expect(violation?.severity).toBe('input');
    }
  });

  it('breaks each code this package knows, and the case that breaks none is the fixture', () => {
    expect(new Set(BROKEN.map(([code]) => code))).toEqual(
      new Set([...Object.keys(AEAT_ERRORS), 'input:currency', 'input:aeat_qualification', 'input:rectification_type']),
    );
    expect(codes(alta())).toEqual([]);
    expect(codes(alta({ header: FIRST_2024, generatedAt: '2024-11-04T10:00:00+01:00' }))).toEqual([]);
  });

  it('reports a 2 % or 7.5 % rate inside its window as nothing', () => {
    const header = { ...FIRST_2024, amount_tax: '20.00', amount_total: '1020.00' };
    const input = alta({ header, generatedAt: '2024-11-04T10:00:00+01:00', taxes: [{ ...STANDARD, tax_rate: '2', tax_charged: '20.00' }] });
    expect(codes(input)).toEqual([]);
  });
});
