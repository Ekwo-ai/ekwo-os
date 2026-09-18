import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { describe, expect, it } from 'vitest';
import { StatementFileError, readCamt053 } from '../src/index.js';

/**
 * A statement is a file somebody else wrote. These are the files somebody
 * hostile writes, and each has to be refused by name, quickly, and without
 * having allocated what it asked for.
 */

const here = dirname(fileURLToPath(import.meta.url));
const golden = readFileSync(join(here, 'fixtures', 'golden.camt.053.001.08.xml'), 'utf8');
const NS = 'urn:iso:std:iso:20022:tech:xsd:camt.053.001.08';

function codeOf(run: () => unknown): string {
  try {
    run();
  } catch (error) {
    if (error instanceof StatementFileError) return error.code;
    throw error;
  }
  return 'read';
}

describe('entity attacks stop at the DOCTYPE', () => {
  it('refuses a billion laughs without expanding one', () => {
    const levels = Array.from(
      { length: 9 },
      (_, level) =>
        `<!ENTITY lol${level + 1} "${`&lol${level};`.repeat(10)}">`,
    ).join('\n');
    const bomb = `<?xml version="1.0"?>
<!DOCTYPE lolz [
<!ENTITY lol0 "lol">
${levels}
]>
<Document xmlns="${NS}"><BkToCstmrStmt><GrpHdr><MsgId>&lol9;</MsgId></GrpHdr></BkToCstmrStmt></Document>`;
    const started = performance.now();
    expect(codeOf(() => readCamt053(bomb))).toBe('doctype_forbidden');
    expect(performance.now() - started).toBeLessThan(1000);
  });

  it('refuses an external entity (XXE), system or public', () => {
    for (const declaration of [
      '<!DOCTYPE d [<!ENTITY xxe SYSTEM "file:///etc/passwd">]>',
      '<!DOCTYPE d [<!ENTITY xxe PUBLIC "-//x//y" "http://example.test/x">]>',
      '<!DOCTYPE d [<!ENTITY % remote SYSTEM "http://example.test/evil.dtd"> %remote;]>',
      '<!DOCTYPE d SYSTEM "http://example.test/evil.dtd">',
    ]) {
      const file = golden
        .replace('<!-- An invented', `${declaration}<!-- An invented`)
        .replace('MSG-2026-03-0001', '&xxe;');
      expect(codeOf(() => readCamt053(file)), declaration).toBe('doctype_forbidden');
    }
  });

  it('refuses an entity nobody declared, rather than reading it as nothing', () => {
    expect(codeOf(() => readCamt053(golden.replace('MSG-2026-03-0001', '&xxe;')))).toBe(
      'undefined_entity',
    );
    expect(codeOf(() => readCamt053(golden.replace('MSG-2026-03-0001', '&nbsp;')))).toBe(
      'undefined_entity',
    );
  });

  it('refuses a character reference that is not a character', () => {
    for (const reference of ['&#0;', '&#x1F;', '&#xD800;', '&#x110000;', '&#xFFFE;']) {
      expect(codeOf(() => readCamt053(golden.replace('MSG-2026-03-0001', reference))), reference).toBe(
        'malformed_xml',
      );
    }
  });
});

describe('size, depth and count are bounded before they cost anything', () => {
  it('refuses a file over the limit without reading it', () => {
    expect(codeOf(() => readCamt053(golden, { maxBytes: 1000 }))).toBe('too_large');
    expect(codeOf(() => readCamt053(new TextEncoder().encode(golden), { maxBytes: 1000 }))).toBe(
      'too_large',
    );
    const big = new Uint8Array(33 * 1024 * 1024);
    const started = performance.now();
    expect(codeOf(() => readCamt053(big))).toBe('too_large');
    expect(performance.now() - started).toBeLessThan(1000);
  });

  it('refuses nesting deeper than the limit, and a hundred thousand levels do not touch the stack', () => {
    const deep = `<Document xmlns="${NS}">${'<a>'.repeat(100_000)}${'</a>'.repeat(100_000)}</Document>`;
    expect(codeOf(() => readCamt053(deep))).toBe('too_deep');
    expect(codeOf(() => readCamt053(deep, { maxDepth: 200_000 }))).toBe('incomplete_statement');
  });

  it('refuses more elements than the limit', () => {
    const wide = `<Document xmlns="${NS}">${'<a/>'.repeat(5000)}</Document>`;
    expect(codeOf(() => readCamt053(wide, { maxElements: 1000 }))).toBe('too_many_elements');
  });
});

describe('encoding', () => {
  it('reads UTF-8 bytes, with or without a byte order mark', () => {
    const bytes = new TextEncoder().encode(golden);
    const marked = new Uint8Array(bytes.length + 3);
    marked.set([0xef, 0xbb, 0xbf]);
    marked.set(bytes, 3);
    expect(readCamt053(bytes).statements[0]?.lines[7]?.counterparty?.name).toBe('Troisième Payeur');
    expect(readCamt053(marked).statements[0]?.id).toBe('STMT-2026-003');
    expect(readCamt053(`${String.fromCharCode(0xfeff)}${golden}`).statements[0]?.id).toBe(
      'STMT-2026-003',
    );
  });

  it('refuses bytes that are not UTF-8 rather than replacing them', () => {
    // "Troisième" written one byte per character, as ISO-8859-1 would.
    const latin1 = Uint8Array.from(golden, (character) => character.charCodeAt(0) & 0xff);
    expect(codeOf(() => readCamt053(latin1))).toBe('unsupported_encoding');
  });

  it('refuses a declared encoding it does not read, and UTF-16', () => {
    const declared = new TextEncoder().encode(golden.replace('encoding="UTF-8"', 'encoding="ISO-8859-1"'));
    expect(codeOf(() => readCamt053(declared))).toBe('unsupported_encoding');
    expect(codeOf(() => readCamt053(Uint8Array.from([0xff, 0xfe, 0x3c, 0x00])))).toBe(
      'unsupported_encoding',
    );
  });
});

describe('what is not well-formed is not read', () => {
  const cases: Array<[string, string]> = [
    ['nothing at all', ''],
    ['not XML', 'date;amount\n2026-03-01;12.40\n'],
    ['a tag closed by another', golden.replace('</MsgId>', '</MsgID>')],
    ['a tag never closed', golden.replace('</Document>', '')],
    ['two document elements', `${golden}<Document xmlns="${NS}"/>`],
    ['text after the document', `${golden}trailing`],
    ['a bare ampersand', golden.replace('Client Exemple &amp; Fils', 'Client Exemple & Fils')],
    ['an attribute written twice', golden.replace('<Amt Ccy="EUR">1210.00', '<Amt Ccy="EUR" Ccy="USD">1210.00')],
    ['an attribute without quotes', golden.replace('<Amt Ccy="EUR">1210.00', '<Amt Ccy=EUR>1210.00')],
    ['a "<" in an attribute', golden.replace('<Amt Ccy="EUR">1210.00', '<Amt Ccy="<EUR">1210.00')],
    ['a prefix bound to nothing', golden.replace('<MsgId>', '<x:MsgId>').replace('</MsgId>', '</x:MsgId>')],
    ['a control character', golden.replace('thank you', `thank${String.fromCharCode(1)}you`)],
    ['a comment never closed', golden.replace('</Document>', '<!-- </Document>')],
    ['a CDATA section never closed', golden.replace('thank you', '<![CDATA[thank you')],
    ['a second XML declaration', golden.replace('<Document', '<?xml version="1.0"?><Document')],
    ['an ELEMENT declaration', golden.replace('<Document', '<!ELEMENT a ANY><Document')],
  ];
  it.each(cases)('%s', (_, file) => {
    expect(codeOf(() => readCamt053(file))).toBe('malformed_xml');
  });
});

describe('what is XML and not a camt.053 is refused by name', () => {
  it('another message of the family, another root, another namespace', () => {
    for (const file of [
      golden.replaceAll('camt.053.001.08', 'camt.052.001.08'),
      golden.replaceAll('camt.053.001.08', 'camt.054.001.08'),
      golden.replaceAll('camt.053.001.08', 'pain.001.001.09'),
      golden.replace(` xmlns="${NS}"`, ''),
      '<html><body>Session expired</body></html>',
      golden.replace('<Document ', '<Envelope ').replace('</Document>', '</Envelope>'),
    ]) {
      expect(codeOf(() => readCamt053(file))).toBe('not_a_statement');
    }
  });

  it('the 2007 version, which shares the name and not the shape', () => {
    expect(codeOf(() => readCamt053(golden.replaceAll('camt.053.001.08', 'camt.053.001.01')))).toBe(
      'unsupported_version',
    );
  });

  it('a statement with no statement in it, or no account', () => {
    expect(codeOf(() => readCamt053(`<Document xmlns="${NS}"><BkToCstmrStmt/></Document>`))).toBe(
      'incomplete_statement',
    );
    expect(
      codeOf(() => readCamt053(golden.replace('<Id><IBAN>BE96999000000101</IBAN></Id>\n        <Ccy>', '<Ccy>'))),
    ).toBe('incomplete_statement');
  });

  it('ignores an element of another namespace rather than reading it as the statement\'s', () => {
    const smuggled = golden.replace(
      '<Id>STMT-2026-003</Id>',
      '<Id xmlns="urn:example:other">SMUGGLED</Id><Id>STMT-2026-003</Id>',
    );
    expect(readCamt053(smuggled).statements[0]?.id).toBe('STMT-2026-003');
  });
});
