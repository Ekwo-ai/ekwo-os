/**
 * What one country pack holds, as an object somebody can read.
 *
 * `filingReadiness()` next door answers five questions about a declaration.
 * This answers the same kind of question about the whole pack — the charts, the
 * taxes, the declaration and when it is due, the e-invoicing obligation, the
 * bank formats, the statements, who has read it and against which texts — and
 * it exists because two readers were about to ask it separately: `ekwo pack
 * describe` at a terminal, and the page the public site publishes per country.
 * Two readings of the same folder would have disagreed the week one of them
 * gained a field.
 *
 * Three rules hold here, and they are what makes the output worth trusting.
 *
 * **Everything is read, nothing is written down.** There is no table of
 * countries in this file and no country literal anywhere in it: a chart's
 * audience, a tax rate, the day a deadline falls, the profile of an electronic
 * invoice and the name of the person who reviewed the pack all come out of
 * `packs/<cc>/`. A pack that lands tomorrow describes itself the day it lands,
 * and nothing here or in the site changes.
 *
 * **A "no" is an answer and is printed.** A pack that declares no deadline rule
 * carries `deadline: null`, and the reader shows that rather than leaving the
 * row out. A pack that *states* a no — a deadline that depends on the
 * taxpayer, an e-invoicing profile no statute makes obligatory — carries it as
 * a value, and the reader prints it as the answer it is rather than as a gap.
 * Most packs have more nulls than values, and a description that silently
 * dropped them would be a brochure — the word is `describeFiling()`'s and the
 * rule is the same one.
 *
 * **What a pack cannot know is passed in.** Whether a bank statement format has
 * a reader is a fact about `packages/formats/`, not about a country, so
 * `STATEMENT_FORMATS` of the core is the source and it arrives as an argument.
 * A copy of that list here would be the second truth that outlives the first.
 */

import { STATEMENT_FORMATS } from '@ekwo-ai/core';
import { filingReadiness } from './filing.js';
import { sourcesOf, type EinvoiceObligation, type Pack, type PackDeadline, type PackSource } from './read.js';

/** One chart of accounts of a country, as a reader needs it. */
export interface DescribedChart {
  code: string;
  name: string;
  /** Translations of the chart's name, by language, from `i18n/`. */
  nameI18n: Record<string, string>;
  /** Who the chart is published for — `companies`, `nonprofits`. Null where unsaid. */
  audience: string | null;
  accounts: number;
  isDefault: boolean;
  /** Codes of the statements this chart reports on. Empty means the generic ones. */
  statements: string[];
}

/** The taxes of a country, counted rather than listed. */
export interface DescribedTaxes {
  count: number;
  /** The distinct rates the pack carries, ascending. A pack with none is a real case. */
  rates: number[];
  /** The treatments present, as the closed vocabulary names them, alphabetically. */
  treatments: string[];
  /** `vat`, `gst`, `sales_tax`, `withholding`, `other` — whichever the pack uses. */
  kinds: string[];
}

/** When a declaration is due, flattened to what a reader prints. */
export interface DescribedDeadline {
  rule: PackDeadline['rule'];
  day: number | null;
  plusDays: number | null;
  legalReference: string;
}

/**
 * How the file a declaration is deposited as gets written.
 *
 * `brick` names the package of `packages/formats/` the pack points at. `null`
 * is the ordinary case and it is not a gap: filing by hand on the
 * administration's portal is complete and free, which is what
 * [`docs/filing.md`](../../../docs/filing.md) says at step 4.
 */
export interface DescribedFile {
  brick: string | null;
  /** True where nobody has written the brick yet, and the form is filed by hand. */
  byHand: boolean;
}

/** One periodic declaration of a country. */
export interface DescribedDeclaration {
  code: string;
  name: string;
  /** The cadences the form is filed on, from the shortest to the longest. */
  periods: string[];
  /** The cadence proposed unless the company asks for another. Null where the law gives none. */
  periodDefault: string | null;
  boxes: number;
  /**
   * Null where the pack says nothing. A rule of `depends_on_taxpayer` is the
   * pack saying the day is assigned per filer, and carries the text that does.
   */
  deadline: DescribedDeadline | null;
  file: DescribedFile;
  legalReference: string | null;
}

/**
 * The electronic invoicing of a country: the profile its operators exchange,
 * and whether a statute makes it obligatory. Present where the pack names a
 * profile or states an obligation — a country with no profile at all and
 * `obligation: none` has said something, and a reader prints it.
 */
export interface DescribedEinvoicing {
  /** Null where the country has no profile to name, which the obligation then explains. */
  profile: string | null;
  /** The day the obligation starts, as the pack writes it. Null where the pack says none. */
  mandatoryFrom: string | null;
  /**
   * `mandatory`, `on_request`, `none`, or null where the pack says nothing.
   * `on_request` and `none` are answers — a seller issues the profile when a
   * buyer entitled to ask does, or no statute obliges anybody — and a reader
   * prints them as answers; a null beside a null date is the silence.
   */
  obligation: EinvoiceObligation | null;
  legalReference: string | null;
}

/**
 * Where the balance of a declared period lands.
 *
 * Two roles, each present or not. A chart that keeps what is owed and what is
 * owed back on one account names only the first, and `settle_filing()` carries
 * the net there either way.
 */
export interface DescribedVatBalance {
  payable: string | null;
  receivable: string | null;
}

/** One bank format a pack names, and whether anything in this repository reads it. */
export interface DescribedBankFormat {
  format: string;
  read: boolean;
}

/** One financial statement of a country. */
export interface DescribedStatement {
  code: string;
  name: string;
  kind: string;
  framework: string | null;
  /** `name:version` of the taxonomy the `xbrl` keys are written against. */
  taxonomy: string | null;
  lines: number;
}

/**
 * Who stands behind a pack, and against what.
 *
 * `status` is the pack's own word — `community`, `maintained` or `reviewed` —
 * and `reviewedBy` is a named professional or nobody. There is no status that
 * means certified by Ekwo, and writing a pack is not reviewing it: that is
 * invariant 6 of [`CONTRIBUTING.md`](../../../CONTRIBUTING.md), and this reader
 * repeats what the manifest says rather than grading it.
 *
 * `lastConsultedOn` is the most recent day somebody opened one of the texts the
 * pack was built from. It is the honest answer to "when was this last checked
 * against the law", and it is a maximum over the register rather than a field:
 * a register where one text was reread yesterday and the rest two years ago
 * says the pack was looked at yesterday, which is true, and the per-text days
 * are in `sources` for a reader who wants the rest.
 */
export interface DescribedCertification {
  status: string;
  reviewedBy: string | null;
  reviewedOn: string | null;
  sources: PackSource[];
  lastConsultedOn: string | null;
}

/**
 * One line of the open core boundary, for this country.
 *
 * The line is operational and not functional: the test is whether the thing
 * keeps working on its own, with Ekwo or without it
 * ([`ee/README.md`](../../../ee/README.md)). Writing a file and validating it
 * needs nobody; handing it to an administration, a Peppol access point or a
 * bank needs credentials, often a certificate, and somebody answerable when a
 * return is late — which is the only step of the eight in
 * [`docs/filing.md`](../../../docs/filing.md) that is operated.
 *
 * Every row here is derived from something the pack declares. A country that
 * declares no e-invoicing profile has no e-invoicing row, rather than a row
 * saying no.
 */
export interface DescribedBoundary {
  /** `declaration`, `einvoicing` or `bank_statement`. */
  kind: 'declaration' | 'einvoicing' | 'bank_statement';
  /** What the row is about, named by the pack's own data. */
  subject: string;
  /** What the open core does, for nothing, for as long as the installation exists. */
  free: string;
  /** What has to be operated for it to leave the building. Null where nothing does. */
  operated: string | null;
}

/** Everything one country pack says about itself. */
export interface PackDescription {
  /** Directory name under `packs/`. */
  slug: string;
  /** ISO 3166-1 alpha-2, as the manifest declares it and the database stores it. */
  country: string;
  /** The country's name in the pack's own language. */
  name: string;
  /** That name in every language the pack publishes it in. */
  nameI18n: Record<string, string>;
  version: string;
  /** The day the pack says its transcription of the law is true. Null where it names none. */
  releasedAt: string | null;
  /** The pack's own language first, then the ones it declares. */
  languages: string[];
  /** The currency a company installing this country gets unless it says otherwise. */
  currency: string;
  charts: DescribedChart[];
  taxes: DescribedTaxes;
  /** Zero or one today; a list because a country that files two is not a new shape. */
  declarations: DescribedDeclaration[];
  einvoicing: DescribedEinvoicing | null;
  vatBalance: DescribedVatBalance;
  bankStatementFormats: DescribedBankFormat[];
  paymentFormats: string[];
  statements: DescribedStatement[];
  certification: DescribedCertification;
  boundary: DescribedBoundary[];
  /** sha256 of every file of the pack, so a change is visible without a diff. */
  checksum: string;
}

/** What a reader may substitute for the facts a pack cannot know about itself. */
export interface DescribeOptions {
  /**
   * The statement formats a brick of this repository reads. Defaults to the
   * core's list, which is the only one; an argument exists so a test can ask
   * what a pack would look like against a different set of bricks.
   */
  statementFormatsRead?: readonly string[];
}

/** The description of one pack. Pure: it reads the object and touches nothing. */
export function describePack(pack: Pack, options: DescribeOptions = {}): PackDescription {
  const read = options.statementFormatsRead ?? STATEMENT_FORMATS;
  const filing = filingReadiness(pack);
  // `tax_payable` through `filingReadiness()`, which already reads it for the
  // listing: one role, one reader. `tax_receivable` is beside it because the
  // question here is the balance of a period and not the readiness of a form.
  const receivable = pack.manifest.defaults.roles['tax_receivable'];

  const declarations: DescribedDeclaration[] = [];
  if (pack.report !== null) {
    const report = pack.report;
    declarations.push({
      code: report.code,
      name: report.name,
      periods: report.periods,
      periodDefault: report.period_default,
      boxes: report.boxes.length,
      deadline:
        report.deadline === null
          ? null
          : {
              rule: report.deadline.rule,
              day: report.deadline.day,
              plusDays: report.deadline.plus_days,
              legalReference: report.deadline.legal_reference,
            },
      file: { brick: report.file_format, byHand: report.file_format === null },
      legalReference: report.legal_reference,
    });
  }

  const einvoicing: DescribedEinvoicing | null =
    pack.documents.einvoice_profile === null && pack.documents.einvoice_obligation === null
      ? null
      : {
          profile: pack.documents.einvoice_profile,
          mandatoryFrom: pack.documents.einvoice_mandatory_from,
          obligation:
            pack.documents.einvoice_obligation ??
            (pack.documents.einvoice_mandatory_from === null ? null : 'mandatory'),
          legalReference: pack.documents.einvoice_reference.legal_reference,
        };

  const bankStatementFormats: DescribedBankFormat[] = pack.documents.bank_statement_formats.map(
    (format) => ({ format, read: read.includes(format) }),
  );

  const sources = sourcesOf(pack.manifest.certification);
  const consulted = sources
    .map((source) => source.consulted_on)
    .filter((day) => typeof day === 'string' && day !== '')
    .sort();

  return {
    slug: pack.slug,
    country: pack.manifest.country,
    name: pack.manifest.name,
    nameI18n: pack.labels.pack_name,
    version: pack.manifest.version,
    releasedAt: pack.manifest.released_at ?? null,
    languages: pack.languages,
    currency: pack.manifest.defaults.currency,
    charts: pack.charts.map((chart) => ({
      code: chart.code,
      name: chart.name,
      nameI18n: chart.name_i18n,
      audience: chart.audience,
      accounts: chart.accounts.length,
      isDefault: chart.is_default,
      statements: chart.statements,
    })),
    taxes: {
      count: pack.taxes.length,
      rates: [...new Set(pack.taxes.map((tax) => tax.rate))].sort((a, b) => a - b),
      treatments: [...new Set(pack.taxes.map((tax) => tax.treatment))].sort(),
      kinds: [...new Set(pack.taxes.map((tax) => tax.kind))].sort(),
    },
    declarations,
    einvoicing,
    vatBalance: {
      payable: filing.taxPayable,
      receivable: typeof receivable === 'string' ? receivable : null,
    },
    bankStatementFormats,
    paymentFormats: pack.documents.payment_formats,
    statements: pack.statements.map((statement) => ({
      code: statement.code,
      name: statement.name,
      kind: statement.kind,
      framework: statement.framework,
      taxonomy: statement.taxonomy,
      lines: statement.lines.length,
    })),
    certification: {
      status: pack.manifest.certification?.status ?? 'community',
      reviewedBy: pack.manifest.certification?.by ?? null,
      reviewedOn: pack.manifest.certification?.on ?? null,
      sources,
      lastConsultedOn: consulted[consulted.length - 1] ?? null,
    },
    boundary: boundaryOf(declarations, einvoicing, bankStatementFormats, filing.taxPayable),
    checksum: pack.checksum,
  };
}

/**
 * The open core boundary of one country, row by row.
 *
 * Nothing here is a judgement about what is worth charging for. Each row names
 * a thing the pack declares, says what the core does with it, and says what has
 * to be operated for it to reach somebody else — the three rows of
 * `ee/README.md` that a country pack can actually produce: filing a
 * declaration, sending an electronic invoice, and receiving a bank statement.
 * The fourth and fifth rows of that table, the agents and the control plane,
 * are not facts about a country and are not invented here.
 */
function boundaryOf(
  declarations: DescribedDeclaration[],
  einvoicing: DescribedEinvoicing | null,
  bankFormats: DescribedBankFormat[],
  taxPayable: string | null,
): DescribedBoundary[] {
  const rows: DescribedBoundary[] = [];

  for (const declaration of declarations) {
    const written = declaration.file.byHand
      ? 'filed by hand on the administration’s portal'
      : `written as ${declaration.file.brick as string}`;
    const settled =
      taxPayable === null
        ? 'and what it owes is carried to the account a company names'
        : `and what it owes is carried to ${taxPayable}`;
    rows.push({
      kind: 'declaration',
      subject: declaration.code,
      free: `Computed from the ledger, frozen box by box, ${written}, ${settled}. The deposit number and the administration’s own words come back into your own database.`,
      operated: 'Transmission: the credentials, and somebody answerable when a return is late.',
    });
  }

  if (einvoicing !== null && einvoicing.profile !== null) {
    rows.push({
      kind: 'einvoicing',
      subject: einvoicing.profile,
      free: `An invoice is written and validated as ${einvoicing.profile} by a brick of packages/formats, and read back the same way.`,
      operated: 'Sending and receiving over Peppol: a certified access point and a certificate.',
    });
  }

  for (const format of bankFormats) {
    rows.push({
      kind: 'bank_statement',
      subject: format.format,
      free: format.read
        ? `A ${format.format} file the bank hands over is read and matched against the ledger.`
        : `Not yet: no brick of packages/formats/ reads ${format.format}.`,
      operated: 'Fetching the statement without being handed it: a PSD2 aggregator contract.',
    });
  }

  return rows;
}
