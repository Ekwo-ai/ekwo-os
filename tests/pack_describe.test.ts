import { describe, expect, it } from 'vitest';
import { describePack } from '../packages/cli/src/index.js';
import { writeTools } from '../packages/mcp/src/index.js';
import { allPacks, certificationStatuses, declarationPeriods } from './helpers/packs.js';

/**
 * `describePack()` is what a reader outside this repository sees of a country.
 *
 * The command line prints it and the public site builds a page from it, so
 * every hole in it is a hole somebody reads. What is checked here is not the
 * values — those belong to the pack and change with the law — but that the
 * description is a **faithful and total** reading of the pack: every field
 * comes from the folder, every "not yet" is present as a value rather than
 * missing, and nothing was invented for a country that said nothing.
 *
 * Every expectation below is taken from the pack it describes. No country is
 * named, no count is written down: a pack that lands tomorrow is described the
 * day it lands, and this file does not move.
 */

const described = allPacks.map((pack) => ({ pack, description: describePack(pack) }));

describe('describePack', () => {
  it('describes every pack of the checkout', () => {
    expect(described.length).toBe(allPacks.length);
    expect(described.length).toBeGreaterThan(0);
  });

  it('takes its identity from the manifest and nowhere else', () => {
    for (const { pack, description } of described) {
      expect(description.slug).toBe(pack.slug);
      expect(description.country).toBe(pack.manifest.country);
      expect(description.name).toBe(pack.manifest.name);
      expect(description.version).toBe(pack.manifest.version);
      expect(description.currency).toBe(pack.manifest.defaults.currency);
      expect(description.checksum).toBe(pack.checksum);
      expect(description.languages).toEqual(pack.languages);
    }
  });

  it('counts the charts and their accounts as the pack carries them', () => {
    for (const { pack, description } of described) {
      expect(description.charts.length).toBe(pack.charts.length);
      expect(description.charts.map((chart) => chart.code)).toEqual(
        pack.charts.map((chart) => chart.code),
      );
      for (const [index, chart] of description.charts.entries()) {
        expect(chart.accounts).toBe(pack.charts[index]!.accounts.length);
      }
      // Every pack has a chart, and exactly one of them is the one a company
      // installs when it says nothing.
      expect(description.charts.filter((chart) => chart.isDefault).length).toBe(1);
    }
  });

  it('reads the taxes as a count, the distinct rates and the treatments present', () => {
    for (const { pack, description } of described) {
      expect(description.taxes.count).toBe(pack.taxes.length);
      expect(description.taxes.rates).toEqual([...description.taxes.rates].sort((a, b) => a - b));
      for (const rate of description.taxes.rates) {
        expect(pack.taxes.some((tax) => tax.rate === rate)).toBe(true);
      }
      for (const tax of pack.taxes) {
        expect(description.taxes.rates).toContain(tax.rate);
        expect(description.taxes.treatments).toContain(tax.treatment);
        expect(description.taxes.kinds).toContain(tax.kind);
      }
    }
  });

  it('describes the periodic return the pack declares, and none where it declares none', () => {
    for (const { pack, description } of described) {
      expect(description.declarations.length).toBe(pack.report === null ? 0 : 1);
      for (const declaration of description.declarations) {
        const report = pack.report!;
        expect(declaration.code).toBe(report.code);
        expect(declaration.boxes).toBe(report.boxes.length);
        expect(declaration.periods).toEqual(report.periods);
        for (const period of declaration.periods) expect(declarationPeriods).toContain(period);
      }
    }
  });

  it('carries a deadline only where the pack states the rule, and null where it does not', () => {
    for (const { pack, description } of described) {
      for (const declaration of description.declarations) {
        const rule = pack.report?.deadline ?? null;
        if (rule === null) {
          // A pack that cannot state its rule in the shape the format carries
          // says nothing, and this is the value a reader shows as "not
          // declared". It is an answer, not a missing field.
          expect(declaration.deadline).toBeNull();
          continue;
        }
        expect(declaration.deadline).not.toBeNull();
        expect(declaration.deadline!.rule).toBe(rule.rule);
        expect(declaration.deadline!.day).toBe(rule.day);
        expect(declaration.deadline!.plusDays).toBe(rule.plus_days);
        expect(declaration.deadline!.legalReference).toBe(rule.legal_reference);
      }
    }
  });

  it('names the brick that writes the deposited file, or says it is filed by hand', () => {
    for (const { pack, description } of described) {
      for (const declaration of description.declarations) {
        expect(declaration.file.brick).toBe(pack.report?.file_format ?? null);
        expect(declaration.file.byHand).toBe(declaration.file.brick === null);
      }
    }
  });

  it('describes e-invoicing where the pack names a profile or states an obligation', () => {
    for (const { pack, description } of described) {
      const profile = pack.documents.einvoice_profile;
      const obligation = pack.documents.einvoice_obligation;
      if (profile === null && obligation === null) {
        expect(description.einvoicing).toBeNull();
        continue;
      }
      expect(description.einvoicing!.profile).toBe(profile);
      expect(description.einvoicing!.mandatoryFrom).toBe(pack.documents.einvoice_mandatory_from);
      // A stated obligation is repeated as stated; an unstated one is read off
      // the date, and a null beside a null date stays the silence it is.
      expect(description.einvoicing!.obligation).toBe(
        obligation ?? (pack.documents.einvoice_mandatory_from === null ? null : 'mandatory'),
      );
    }
  });

  it('says of each role of the tax balance whether the pack names an account', () => {
    for (const { pack, description } of described) {
      const roles = pack.manifest.defaults.roles;
      for (const [role, named] of [
        ['tax_payable', description.vatBalance.payable],
        ['tax_receivable', description.vatBalance.receivable],
      ] as const) {
        const declared = roles[role];
        expect(named).toBe(typeof declared === 'string' ? declared : null);
      }
    }
  });

  it('answers read or not yet for every bank format a pack names, from one list', () => {
    for (const { pack, description } of described) {
      expect(description.bankStatementFormats.map((entry) => entry.format)).toEqual(
        pack.documents.bank_statement_formats,
      );
      for (const entry of description.bankStatementFormats) {
        // The source of truth is the core's list, which the MCP server offers
        // and this reads. A second list would be the one that drifted.
        expect(entry.read).toBe(writeTools.STATEMENT_FORMATS.includes(entry.format as never));
      }
    }
  });

  it('reports the certification the pack claims, never a grade of its own', () => {
    for (const { pack, description } of described) {
      expect(certificationStatuses).toContain(description.certification.status);
      expect(description.certification.status).toBe(
        pack.manifest.certification?.status ?? 'community',
      );
      expect(description.certification.reviewedBy).toBe(pack.manifest.certification?.by ?? null);
      // There is no status that means certified by Ekwo, and nothing here may
      // introduce one.
      expect(description.certification.status).not.toContain('certified');
    }
  });

  it('says when the pack was last checked against the law, as the newest source read', () => {
    for (const { description } of described) {
      const days = description.certification.sources
        .map((source) => source.consulted_on)
        .filter((day) => typeof day === 'string' && day !== '')
        .sort();
      expect(description.certification.lastConsultedOn).toBe(
        days.length === 0 ? null : days[days.length - 1],
      );
      for (const source of description.certification.sources) {
        expect(source.url.startsWith('https://')).toBe(true);
      }
    }
  });

  it('draws the open core boundary from what the pack declares, and only that', () => {
    for (const { description } of described) {
      const kinds = description.boundary.map((row) => row.kind);
      expect(kinds.filter((kind) => kind === 'declaration').length).toBe(
        description.declarations.length,
      );
      expect(kinds.filter((kind) => kind === 'einvoicing').length).toBe(
        description.einvoicing?.profile == null ? 0 : 1,
      );
      expect(kinds.filter((kind) => kind === 'bank_statement').length).toBe(
        description.bankStatementFormats.length,
      );
      for (const row of description.boundary) {
        // Every row says what is free. What is operated is a sentence or
        // nothing, never an empty string pretending to be one.
        expect(row.free.length).toBeGreaterThan(0);
        expect(row.operated === null || row.operated.length > 0).toBe(true);
        expect(row.subject.length).toBeGreaterThan(0);
      }
    }
  });

  it('is pure: two readings of one pack give the same object', () => {
    for (const { pack, description } of described) {
      expect(describePack(pack)).toEqual(description);
    }
  });

  it('lets a caller ask what a pack would look like against other bricks', () => {
    for (const { pack, description } of described) {
      const none = describePack(pack, { statementFormatsRead: [] });
      expect(none.bankStatementFormats.every((entry) => entry.read === false)).toBe(true);
      // And the rest of the description is untouched by the substitution.
      expect(none.charts).toEqual(description.charts);
    }
  });
});
