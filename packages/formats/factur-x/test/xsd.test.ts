import { execFileSync, spawnSync } from 'node:child_process';
import { mkdtempSync, readdirSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { afterAll, describe, expect, it } from 'vitest';
import { generateCiiXml } from '../src/index.js';
import type { Invoice, Profile } from '../src/index.js';
import { domesticInvoice, exampleInvoice } from './fixtures/example-invoice.js';

/**
 * What the generator writes is held to the official schema of each profile.
 * The schemas differ by what they leave out, so an element written one
 * profile too low is only seen here.
 */
const PROFILES: readonly Profile[] = ['minimum', 'basic-wl', 'basic', 'en16931', 'extended'];
const fixtures = fileURLToPath(new URL('./fixtures/', import.meta.url));

const schemaOf = (profile: Profile) => {
  const folder = join(fixtures, 'xsd', profile);
  const entry = readdirSync(folder).find((name) => /^Factur-X_[A-Z0-9]+\.xsd$/.test(name));
  if (!entry) throw new Error(`no schema for ${profile}`);
  return join(folder, entry);
};

/** An invoice that fills every optional field the generator knows. */
const filled = (invoice: Invoice): Invoice => ({
  ...invoice,
  note: 'Thank you for your order.',
  dueDate: invoice.dueDate ?? '2026-05-31',
  contractReference: 'CT-2026-07',
  precedingInvoice: { number: 'INV-2026-0001', issueDate: '2026-01-15' },
  seller: {
    ...invoice.seller,
    contact: { name: 'Marie Dupont', phone: '+32 2 555 01 00', email: 'billing@seller.example' },
    electronicAddress: { scheme: 'EM', value: 'billing@seller.example' },
  },
  buyer: { ...invoice.buyer, electronicAddress: { scheme: 'EM', value: 'accounts@buyer.example' } },
  payment: { iban: 'BE71 0961 2345 6769', bic: 'GKCCBEBB', reference: 'RF18539007547034', terms: '30 days net' },
  lines: invoice.lines.map((line, i) => ({
    ...line,
    description: `Description of line ${i + 1}`,
    sellerItemId: `ITEM-${i + 1}`,
    note: `Note of line ${i + 1}`,
  })),
});

const hasXmllint = spawnSync('xmllint', ['--version']).error === undefined;
const directory = mkdtempSync(join(tmpdir(), 'factur-x-xsd-'));
afterAll(() => rmSync(directory, { recursive: true, force: true }));

const validate = (profile: Profile, name: string, xml: string) => {
  const file = join(directory, `${name}-${profile}.xml`);
  writeFileSync(file, xml);
  try {
    execFileSync('xmllint', ['--noout', '--schema', schemaOf(profile), file], { stdio: 'pipe' });
    return '';
  } catch (error) {
    return String((error as { stderr?: Buffer }).stderr ?? error);
  }
};

// A continuous integration run always validates; a machine without xmllint skips.
describe.skipIf(!hasXmllint && !process.env.CI)('generateCiiXml against the Factur-X schemas', () => {
  const invoices = { example: exampleInvoice, domestic: domesticInvoice, 'example-filled': filled(exampleInvoice), 'domestic-filled': filled(domesticInvoice) };

  for (const profile of PROFILES) {
    it(`writes a valid ${profile} document`, () => {
      for (const [name, invoice] of Object.entries(invoices)) {
        expect(validate(profile, name, generateCiiXml(invoice, { profile })), `${name} as ${profile}`).toBe('');
      }
    });
  }

  it('keeps the seller item identifier (BT-155) and the item description (BT-154) for EN 16931 and above', () => {
    const invoice = filled(exampleInvoice);
    for (const profile of PROFILES) {
      const xml = generateCiiXml(invoice, { profile });
      const detailed = profile === 'en16931' || profile === 'extended';
      expect(xml.includes('<ram:SellerAssignedID>'), profile).toBe(detailed);
      expect(xml.includes('Description of line 1'), profile).toBe(detailed);
    }
  });

  it('writes no line below BASIC', () => {
    expect(generateCiiXml(exampleInvoice, { profile: 'minimum' })).not.toContain('IncludedSupplyChainTradeLineItem');
    expect(generateCiiXml(exampleInvoice, { profile: 'basic-wl' })).not.toContain('IncludedSupplyChainTradeLineItem');
    expect(generateCiiXml(exampleInvoice, { profile: 'basic' })).toContain('IncludedSupplyChainTradeLineItem');
  });
});
