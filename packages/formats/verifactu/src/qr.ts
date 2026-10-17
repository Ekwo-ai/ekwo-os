/**
 * The URL the QR code of an invoice carries: the AEAT's service where the
 * buyer checks the invoice (*servicio de cotejo o remisión de información*).
 *
 * From the AEAT's *Detalle de las especificaciones técnicas del código «QR»
 * de la factura y de la «URL» del servicio de cotejo o remisión de
 * información por parte del receptor de la factura*, version 0.5.0 of
 * 10 December 2025:
 *
 * - two services, by whether the system sends its records (VERI*FACTU,
 *   `ValidarQR`) or keeps them (NO VERI*FACTU, `ValidarQRNoVerifactu`), each
 *   in production and in the test environment (section 5);
 * - four parameters and only four: `nif`, `numserie`, `fecha` (`DD-MM-AAAA`)
 *   and `importe`, the total of the invoice with a point (section 6) — the
 *   optional `formato=json` is never put in the QR code itself (section 7);
 * - each value URL-encoded in UTF-8 the way the AEAT's own Java example does
 *   it, `java.net.URLEncoder.encode(value, "UTF-8")` (section 4.1): letters,
 *   digits and `.` `-` `*` `_` as they are, a space as `+`, every other byte
 *   as `%` and two hexadecimal capitals.
 *
 * The values are those of the record — the NIF, the number, the date of
 * issue and `ImporteTotal` as written — so the QR code and the record cannot
 * disagree. Drawing the code (ISO/IEC 18004, error correction level M, 30 to
 * 40 mm) belongs to whoever draws the invoice.
 */

import type { AltaModel } from './record.js';
import type { AeatEnvironment, SubmissionMode } from './types.js';

export const VERIFICATION_SERVICES = Object.freeze({
  production: {
    verifactu: 'https://www2.agenciatributaria.gob.es/wlpl/TIKE-CONT/ValidarQR',
    noVerifactu: 'https://www2.agenciatributaria.gob.es/wlpl/TIKE-CONT/ValidarQRNoVerifactu',
  },
  test: {
    verifactu: 'https://prewww2.aeat.es/wlpl/TIKE-CONT/ValidarQR',
    noVerifactu: 'https://prewww2.aeat.es/wlpl/TIKE-CONT/ValidarQRNoVerifactu',
  },
});

const UNRESERVED = /[A-Za-z0-9.\-*_]/;

/** `java.net.URLEncoder.encode(value, "UTF-8")`. */
export function javaUrlEncode(value: string): string {
  let out = '';
  for (const character of value) {
    if (UNRESERVED.test(character)) out += character;
    else if (character === ' ') out += '+';
    else {
      for (const byte of new TextEncoder().encode(character)) {
        out += `%${byte.toString(16).toUpperCase().padStart(2, '0')}`;
      }
    }
  }
  return out;
}

/**
 * The URL of the QR code. `realtime` and `batch` are two ways of sending the
 * records, and both make the system VERI*FACTU; `none` is a system that keeps
 * them, whose invoices still carry a QR code, pointing at the other service.
 * The code belongs to the invoice, so it is read from the record *de alta*,
 * whichever record is being written.
 */
export function qrUrl(model: AltaModel, mode: SubmissionMode, environment: AeatEnvironment): string {
  const services = VERIFICATION_SERVICES[environment];
  if (!services) throw new Error(`the AEAT has a production and a test environment, not ${String(environment)}`);
  if (mode !== 'realtime' && mode !== 'batch' && mode !== 'none') {
    throw new Error(`a system sends its records (realtime, batch) or keeps them (none), not ${String(mode)}`);
  }
  const base = mode === 'none' ? services.noVerifactu : services.verifactu;
  const parameters: Array<[string, string]> = [
    ['nif', model.issuer],
    ['numserie', model.number],
    ['fecha', model.issued],
    ['importe', model.total],
  ];
  return `${base}?${parameters.map(([name, value]) => `${name}=${javaUrlEncode(value)}`).join('&')}`;
}
