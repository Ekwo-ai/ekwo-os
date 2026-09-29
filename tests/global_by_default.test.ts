/**
 * The European Union is one zone among others, never the assumption.
 *
 * A company in a country that does not belong to it — here the United States,
 * which levies no VAT at all, and the United Kingdom, which left the common
 * system — is created and asked for its bank account. Nothing it is shown may
 * talk about intra-community VAT, and the identifier it is asked for is its
 * own, never an IBAN.
 *
 * Setting up may name a country; what is expected comes from the pack.
 */

import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { bankAccountScheme, readBankAccountIdentifier } from '@ekwo-ai/core';
import { describePack } from '../packages/cli/src/index.js';
import { readTools, writeTools } from '../packages/mcp/src/index.js';
import { freshDatabase, rows } from './helpers/db.js';
import { newCompany, type Fixture } from './helpers/factory.js';
import { packOfCountry } from './helpers/packs.js';
import { backendFor, record } from './mcp/helpers.js';

/** What only exists inside the European Union: none of it may reach these companies. */
const UNION_ONLY = /intra-?\s?community|intracom|european[- ]union|recapitulative|\bVIES\b|one-stop/i;

interface Case {
  pack: ReturnType<typeof packOfCountry>;
  company?: Fixture;
  /** An identifier that is valid in this country's scheme. */
  identifier: string;
  canonical: string;
}

// country-literal: two companies outside the European Union, set up to be asked what they are asked
const usa: Case = { pack: packOfCountry('US'), identifier: '021000021-123456789', canonical: '021000021 123456789' };
const uk: Case = { pack: packOfCountry('GB'), identifier: '20-00-00 55779911', canonical: '200000 55779911' };

let db: PGlite;

beforeAll(async () => {
  db = await freshDatabase();
  usa.company = await newCompany(db, { country: usa.pack.manifest.country, name: 'Example Inc' });
  uk.company = await newCompany(db, { country: uk.pack.manifest.country, name: 'Example Ltd' });
});

afterAll(async () => {
  await db.close();
});

describe.each([['a company of the first country', usa], ['a company of the second country', uk]])(
  '%s',
  (_name, given) => {
    it('belongs to no zone, so nothing of the European Union is declared for it', () => {
      expect(given.pack.zones).toEqual([]);
      const described = JSON.stringify(describePack(given.pack));
      expect(described).not.toMatch(UNION_ONLY);
    });

    it('sees no sentence, tax name or document mention about intra-community VAT', async () => {
      const country = given.pack.manifest.country;
      const texts = await rows<{ text: string }>(
        db,
        `select name as text from taxes where company_id = $1
         union all select text from legal_mention_templates where country = $2
         union all select name from accounts where company_id = $1`,
        [given.company!.companyId, country],
      );
      expect(texts.length).toBeGreaterThan(0);
      for (const { text } of texts) expect(text).not.toMatch(UNION_ONLY);
    });

    it('is asked for the identifier its own banks use, and not for an IBAN', () => {
      const declared = given.pack.documents.bank_account_scheme;
      expect(declared).not.toBeNull();
      expect(declared).not.toBe('iban');
      const scheme = bankAccountScheme(declared)!;
      expect(`${scheme.prompt} ${scheme.label} ${scheme.example}`).not.toMatch(/iban/i);
      expect(readBankAccountIdentifier(scheme.key, given.identifier)).toMatchObject({
        ok: true,
        identifier: given.canonical,
      });
      // An IBAN is not a valid answer here, and the refusal does not talk about the Union either.
      const refused = readBankAccountIdentifier(scheme.key, 'BE71 0961 2345 6769');
      expect(refused.ok).toBe(false);
      expect(refused.ok ? '' : refused.error).not.toMatch(UNION_ONLY);
    });

    it('registers a bank account through the server by that identifier, leaving iban empty', async () => {
      const owner = backendFor(db, given.company!.ownerId);
      const created = record(
        await writeTools.createBankAccount(owner, {
          company_id: given.company!.companyId,
          account_identifier: given.identifier,
        }),
      );
      const account = record(created['bank_account']);
      expect(account['account_identifier']).toBe(given.canonical);
      expect(account['account_scheme']).toBe(given.pack.documents.bank_account_scheme);
      expect(account['iban']).toBeNull();

      // The same identifier, spelled differently, is the same account.
      const again = record(
        await writeTools.createBankAccount(owner, {
          company_id: given.company!.companyId,
          account_identifier: given.canonical.replace(' ', '/'),
        }),
      );
      expect(again['created']).toBe(false);

      // An IBAN is refused for a country whose banks do not use one.
      await expect(
        writeTools.createBankAccount(owner, {
          company_id: given.company!.companyId,
          iban: 'BE71 0961 2345 6769',
        }),
      ).rejects.toThrow(/not_an_iban_country/);

      const listed = record(await readTools.listBankAccounts(owner, { company_id: given.company!.companyId }));
      expect(JSON.stringify(listed)).not.toMatch(UNION_ONLY);
    });
  },
);
