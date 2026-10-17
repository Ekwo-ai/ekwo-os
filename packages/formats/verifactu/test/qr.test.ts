import { describe, expect, it } from 'vitest';
import { VERIFACTU, javaUrlEncode } from '../src/index.js';
import { INVOICE, alta } from './fixtures.js';

/**
 * The URLs of the AEAT's *Detalle de las especificaciones técnicas del código
 * «QR» de la factura*, version 0.5.0 of 10 December 2025: the example of
 * section 4, encoded by the Java of section 4.1, and the four valid URLs of
 * section 8. The document prints the amount of section 8 as `241.4` and the
 * Java example passes `241.40`; the record writes two decimals, and the QR code
 * carries `ImporteTotal` as the record writes it.
 */

const example = (number: string, date: string) =>
  alta({ header: { ...INVOICE, number, document_date: date, amount_untaxed: '199.50', amount_tax: '41.90', amount_total: '241.40' } });

describe('the URL of the QR code', () => {
  it('encodes its parameters as the AEAT example does (section 4)', () => {
    expect(VERIFACTU.verificationUrl(example('12345678&G33', '2024-01-01'), 'realtime', 'test')).toBe(
      'https://prewww2.aeat.es/wlpl/TIKE-CONT/ValidarQR?nif=89890001K&numserie=12345678%26G33&fecha=01-01-2024&importe=241.40',
    );
  });

  it.each([
    ['realtime', 'test', 'https://prewww2.aeat.es/wlpl/TIKE-CONT/ValidarQR'],
    ['batch', 'test', 'https://prewww2.aeat.es/wlpl/TIKE-CONT/ValidarQR'],
    ['none', 'test', 'https://prewww2.aeat.es/wlpl/TIKE-CONT/ValidarQRNoVerifactu'],
    ['realtime', 'production', 'https://www2.agenciatributaria.gob.es/wlpl/TIKE-CONT/ValidarQR'],
    ['batch', 'production', 'https://www2.agenciatributaria.gob.es/wlpl/TIKE-CONT/ValidarQR'],
    ['none', 'production', 'https://www2.agenciatributaria.gob.es/wlpl/TIKE-CONT/ValidarQRNoVerifactu'],
  ] as const)('sending %s, in %s, points at the service of section 8', (mode, environment, service) => {
    expect(VERIFACTU.verificationUrl(example('12345678-G33', '2024-09-01'), mode, environment)).toBe(
      `${service}?nif=89890001K&numserie=12345678-G33&fecha=01-09-2024&importe=241.40`,
    );
  });

  it('points at production unless told otherwise', () => {
    expect(VERIFACTU.verificationUrl(alta(), 'realtime')).toBe(
      'https://www2.agenciatributaria.gob.es/wlpl/TIKE-CONT/ValidarQR?nif=89890001K&numserie=F2026-0001&fecha=02-03-2026&importe=1210.00',
    );
  });

  it('is the URL of the invoice, whichever record is being written', () => {
    expect(VERIFACTU.verificationUrl(alta({ kind: 'anulacion' }), 'realtime')).toBe(VERIFACTU.verificationUrl(alta(), 'realtime'));
  });

  it('refuses a mode or an environment that does not exist', () => {
    expect(() => VERIFACTU.verificationUrl(alta(), 'sometimes' as never)).toThrow();
    expect(() => VERIFACTU.verificationUrl(alta(), 'realtime', 'staging' as never)).toThrow();
  });
});

describe('java.net.URLEncoder, in UTF-8', () => {
  it('keeps letters, digits and . - * _, writes a space as +, and the rest as bytes', () => {
    expect(javaUrlEncode('Az09.-*_')).toBe('Az09.-*_');
    expect(javaUrlEncode('A 1/2&3')).toBe('A+1%2F2%263');
    expect(javaUrlEncode('Ñ€')).toBe('%C3%91%E2%82%AC');
    expect(javaUrlEncode("~'!()")).toBe('%7E%27%21%28%29');
  });
});
