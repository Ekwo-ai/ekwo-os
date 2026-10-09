import { createHash } from 'node:crypto';
import { describe, expect, it } from 'vitest';
import {
  CHECKED_SCHEMES,
  ELECTRONIC_ADDRESS_SCHEMES,
  ParticipantIdError,
  SCHEMES_NOT_ON_PEPPOL,
  SML_ZONES,
  SYMBOLIC_SCHEMES,
  smlHostname,
  validateParticipantId,
} from '../src/index.js';
import { base32, md5, sha256 } from '../src/sml.js';

/**
 * Participant identifiers, and the DNS name a participant is looked up under.
 *
 * The values whose check digits pass were computed for these tests from bodies
 * of nines or from the reserved ranges the fixtures use — they are arithmetic,
 * not anybody's number looked up in a register.
 */

const codes = (input: string): string[] => validateParticipantId(input).problems.map((each) => each.code);

describe('a participant identifier', () => {
  it('reads the numeric form, with or without the identifier scheme in front, and returns it lower-cased beside', () => {
    for (const input of ['0208:0999999922', 'iso6523-actorid-upis::0208:0999999922', ' ISO6523-ACTORID-UPIS::0208:0999999922 ']) {
      expect(validateParticipantId(input)).toEqual({
        valid: true,
        scheme: '0208',
        value: '0999999922',
        identifier: '0208:0999999922',
        canonical: '0208:0999999922',
        problems: [],
      });
    }
    expect(validateParticipantId('9944:NL999999999B01')).toMatchObject({ valid: true, identifier: '9944:NL999999999B01', canonical: '9944:nl999999999b01' });
  });

  it('reads a symbolic scheme as the code it stands for', () => {
    expect(validateParticipantId('BE:EN:0999999922')).toMatchObject({ valid: true, scheme: '0208', identifier: '0208:0999999922' });
    expect(validateParticipantId('gln:0200000000011')).toMatchObject({ valid: true, scheme: '0088', identifier: '0088:0200000000011' });
    expect(validateParticipantId('NL:VAT:NL999999999B01')).toMatchObject({ valid: true, scheme: '9944' });
  });

  it('refuses what is not scheme:value, a scheme of no list, and another identifier scheme', () => {
    expect(codes('0999999922')).toEqual(['malformed']);
    expect(codes('0208:')).toEqual(['malformed']);
    expect(codes('urn:other::0208:0999999922')).toEqual(['malformed']);
    expect(codes('1234:0999999922')).toEqual(['unknown_scheme']);
    expect(codes('XX:YY:0999999922')).toEqual(['unknown_scheme']);
  });

  it('refuses a scheme of EN 16931 that Peppol does not deliver to', () => {
    expect(codes('EM:ap@buyer.example.test')).toEqual(['scheme_not_on_peppol']);
  });

  it.each([
    ['0208', '0999999922', '0999999923', '999999922'],
    ['0088', '0200000000011', '0200000000012', '020000000001'],
    ['0002', '999999998', '999999999', '99999999'],
    ['0007', '9999999999', '9999999998', '999999999'],
    ['0192', '999999999', '999999998', '99999999'],
    ['0151', '99999999060', '99999999061', '9999999906'],
    ['0199', 'ZZZZ00EKWOTEST000059', 'ZZZZ00EKWOTEST000058', 'ZZZZ00EKWOTEST0000'],
  ])('checks the digits of scheme %s', (scheme, right, wrongDigits, wrongFormat) => {
    expect(codes(`${scheme}:${right}`)).toEqual([]);
    expect(codes(`${scheme}:${wrongDigits}`)).toEqual(['invalid_check_digits']);
    expect(codes(`${scheme}:${wrongFormat}`)).toEqual(['invalid_format']);
  });

  it('refuses a Norwegian number whose check digit would be ten, which is never issued', () => {
    // 3·1 + 2·0 + … weights give 1 modulo 11 here, so the check digit would be 10.
    const body = '10000000';
    const total = [3, 2, 7, 6, 5, 4, 3, 2].reduce((sum, weight, i) => sum + weight * Number(body[i]), 0);
    expect(11 - (total % 11)).toBe(8);
    const ten = ['00000001', '00000010', '00000100', '00001000'].find((each) => {
      const t = [3, 2, 7, 6, 5, 4, 3, 2].reduce((sum, weight, i) => sum + weight * Number(each[i]), 0);
      return 11 - (t % 11) === 10;
    });
    if (ten !== undefined) {
      for (let digit = 0; digit < 10; digit += 1) expect(codes(`0192:${ten}${digit}`)).toEqual(['invalid_check_digits']);
    }
  });

  it('checks only schemes it has a published rule for, and leaves the others alone', () => {
    expect(codes('0009:99999999999999')).toEqual([]);
    expect(codes('9925:BE0999999922')).toEqual([]);
    expect(CHECKED_SCHEMES).not.toContain('0009');
  });

  it('names only codes of the electronic address scheme list Peppol delivers to', () => {
    for (const [name, code] of Object.entries(SYMBOLIC_SCHEMES)) {
      expect(ELECTRONIC_ADDRESS_SCHEMES.has(code), name).toBe(true);
      expect(SCHEMES_NOT_ON_PEPPOL, name).not.toContain(code);
    }
    expect(new Set(Object.values(SYMBOLIC_SCHEMES)).size).toBe(Object.keys(SYMBOLIC_SCHEMES).length);
    for (const code of CHECKED_SCHEMES) expect(ELECTRONIC_ADDRESS_SCHEMES.has(code), code).toBe(true);
  });
});

describe('the hash functions, against the published test vectors and against Node', () => {
  const bytes = (text: string): Uint8Array => new TextEncoder().encode(text);
  const hex = (data: Uint8Array): string => Buffer.from(data).toString('hex');

  it('MD5, RFC 1321 appendix A.5', () => {
    expect(hex(md5(bytes('')))).toBe('d41d8cd98f00b204e9800998ecf8427e');
    expect(hex(md5(bytes('abc')))).toBe('900150983cd24fb0d6963f7d28e17f72');
    expect(hex(md5(bytes('message digest')))).toBe('f96b697d7cb7938d525a2f31aaf161d0');
  });

  it('SHA-256, FIPS 180-4 examples', () => {
    expect(hex(sha256(bytes('abc')))).toBe('ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad');
    expect(hex(sha256(bytes('abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq')))).toBe(
      '248d6a61d20638b8e5c026930c3e6039a33ce45964ff2167f6ecedd419db06c1',
    );
  });

  it('base32, RFC 4648 section 10, without the padding', () => {
    const vectors: Array<[string, string]> = [
      ['', ''],
      ['f', 'MY'],
      ['fo', 'MZXQ'],
      ['foo', 'MZXW6'],
      ['foob', 'MZXW6YQ'],
      ['fooba', 'MZXW6YTB'],
      ['foobar', 'MZXW6YTBOI'],
    ];
    for (const [input, output] of vectors) expect(base32(bytes(input))).toBe(output);
  });

  it('agree with Node at every length around a block', () => {
    for (let length = 0; length < 200; length += 1) {
      const data = Uint8Array.from({ length }, (_, i) => (i * 131 + length * 7) & 0xff);
      expect(hex(md5(data)), `md5, ${length} bytes`).toBe(createHash('md5').update(data).digest('hex'));
      expect(hex(sha256(data)), `sha256, ${length} bytes`).toBe(createHash('sha256').update(data).digest('hex'));
    }
  });
});

describe('the DNS name of a participant on the SML', () => {
  /** Base32 again, written another way: as a string of bits. */
  const base32ByBits = (data: Buffer): string => {
    const bits = [...data].map((byte) => byte.toString(2).padStart(8, '0')).join('');
    const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    return (bits.match(/.{1,5}/g) ?? []).map((chunk) => alphabet[parseInt(chunk.padEnd(5, '0'), 2)]).join('');
  };

  it('is B- and the MD5 of the identifier, lower-cased, for a CNAME lookup', () => {
    const md5Hex = createHash('md5').update('9944:nl999999999b01').digest('hex');
    expect(smlHostname('iso6523-actorid-upis::9944:NL999999999B01', SML_ZONES.production, 'cname')).toBe(
      `B-${md5Hex}.iso6523-actorid-upis.edelivery.tech.ec.europa.eu`,
    );
  });

  it('is the base32 of the SHA-256 of the identifier, lower-cased, for a NAPTR lookup', () => {
    const digest = createHash('sha256').update('0208:0999999922').digest();
    const name = smlHostname('BE:EN:0999999922', SML_ZONES.test, 'naptr');
    expect(name).toBe(`${base32ByBits(digest)}.iso6523-actorid-upis.acc.edelivery.tech.ec.europa.eu`);
    expect(name.split('.')[0]).toHaveLength(52);
  });

  it('is the same name whatever the case or the spelling the identifier was given in', () => {
    const one = smlHostname('9944:nl999999999b01', SML_ZONES.production, 'naptr');
    expect(smlHostname('9944:NL999999999B01', SML_ZONES.production, 'naptr')).toBe(one);
    expect(smlHostname('NL:VAT:NL999999999B01', `${SML_ZONES.production}.`, 'naptr')).toBe(one);
  });

  it('is refused for an identifier that is not one, with the reasons, and without a zone', () => {
    expect(() => smlHostname('0208:0999999923', SML_ZONES.production, 'cname')).toThrow(ParticipantIdError);
    try {
      smlHostname('0208:0999999923', SML_ZONES.production, 'cname');
    } catch (error) {
      expect((error as ParticipantIdError).problems.map((each) => each.code)).toEqual(['invalid_check_digits']);
    }
    expect(() => smlHostname('0208:0999999922', ' ', 'cname')).toThrow(/zone/);
  });
});
