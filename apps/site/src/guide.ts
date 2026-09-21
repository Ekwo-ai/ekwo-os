/**
 * Setting up a company in one country, step by step, as Markdown.
 *
 * One text for three readers. The set-up page of a country renders it under
 * the two ways in; the build writes it beside that page as
 * `/countries/<cc>/set-up.md`; and `llms-full.txt` carries it for every
 * country. An assistant asked to "install Ekwo for my Irish company" and a
 * person reading the page therefore follow the same commands, and neither can
 * drift from the other.
 *
 * Nothing is chosen here. The command carries the code the pack declares; the
 * charts, the languages, the cadences, the sales account and the taxes are
 * `describePack()`'s, the object `ekwo pack describe --json` prints; the
 * sentences are the language's, in `strings/`. A tax is listed, never picked:
 * which one a sale carries is the seller's question, and the page says so.
 */

import type { PackDescription } from '../../../packages/cli/src/index.js';
import type { Repository } from './data.js';
import { fill, type Strings } from './strings/index.js';

/** Where the Markdown of a country's guide is served. */
export function guideMarkdownUrl(country: PackDescription): string {
  return `/countries/${country.slug}/set-up.md`;
}

/**
 * The guide of one country.
 *
 * `base` is put in front of every link of the site: empty on the page, where
 * a path is enough, and the origin in a file a model reads out of context.
 * `withTitle` is false on the page, which draws its own heading.
 */
export function countryGuide(
  country: PackDescription,
  repository: Repository,
  strings: Strings,
  options: { base?: string; withTitle?: boolean } = {},
): string {
  const g = strings.setup.guide;
  const base = options.base ?? '';
  const named = { country: country.name };
  const out: string[] = [];
  const para = (text: string): void => {
    out.push(text, '');
  };
  const code = (lines: string[]): void => {
    out.push('```sh', ...lines, '```', '');
  };

  if (options.withTitle !== false) para(`# ${fill(g.title, named)}`);
  para(fill(g.intro, { ...named, version: country.version }));

  const { status, reviewedBy, reviewedOn } = country.certification;
  const statusLine = g.statuses[status as keyof typeof g.statuses];
  if (statusLine !== undefined) {
    para(fill(statusLine, { ...named, by: reviewedBy ?? '', on: reviewedOn ?? '' }));
  }
  para(`> ${fill(g.professional, { ...named, disclaimer: `${base}/disclaimer/` })}`);

  para(`## ${g.needHeading}`);
  para([g.needProject, g.needValues, g.needNode].map((item) => `- ${item}`).join('\n'));

  para(`## ${g.installHeading}`);
  para(g.installLead);
  code([`${repository.installCommand} --country ${country.country}`]);

  const facts: string[] = [];
  const defaultChart = country.charts.find((chart) => chart.isDefault) ?? country.charts[0];
  if (country.charts.length > 1) {
    facts.push(
      fill(g.severalCharts, {
        charts: country.charts.map((chart) => `\`${chart.code}\` (${chart.name})`).join(', '),
      }),
    );
  } else if (defaultChart !== undefined) {
    facts.push(fill(g.oneChart, { chart: defaultChart.name, accounts: defaultChart.accounts }));
  }
  const language = country.languages[0];
  if (country.languages.length > 1) {
    facts.push(fill(g.severalLanguages, { languages: country.languages.map((l) => `\`${l}\``).join(', ') }));
  } else if (language !== undefined) {
    facts.push(fill(g.oneLanguage, { language }));
  }
  for (const declaration of country.declarations) {
    if (declaration.periods.length < 2) continue;
    facts.push(
      fill(g.periodChoice, {
        declaration: declaration.name,
        periods: declaration.periods.map((p) => `\`${p}\``).join(', '),
        default: declaration.periodDefault === null ? '' : `The default is \`${declaration.periodDefault}\`. `,
      }),
    );
  }
  facts.push(country.fiscalYearDefault === null ? g.fiscalYearAsk : g.fiscalYearCalendar);
  para(facts.map((fact) => `- ${fact}`).join('\n'));

  const p = g.placeholders;
  const scripted = [
    `${repository.installCommand} \\`,
    `  --country ${country.country} \\`,
    ...(country.charts.length > 1 && defaultChart !== undefined ? [`  --chart ${defaultChart.code} \\`] : []),
    ...(country.languages.length > 1 && language !== undefined ? [`  --language ${language} \\`] : []),
    ...(country.fiscalYearDefault === null ? ['  --fiscal-year-start YYYY-MM-DD \\'] : []),
    ...country.declarations
      .filter((declaration) => declaration.periods.length > 1 && declaration.periodDefault === null)
      .map((declaration) => `  --vat-period <${declaration.periods.join('|')}> \\`),
    '  --db-url "postgresql://postgres.<ref>:<password>@<pooler host>:5432/postgres" \\',
    '  --supabase-url "https://<ref>.supabase.co" \\',
    '  --service-role-key "$SUPABASE_SERVICE_ROLE_KEY" \\',
    `  --org "${p.org}" --company "${p.company}" \\`,
    `  --admin-email "${p.email}" \\`,
    '  --yes',
  ];
  para(g.scripted);
  code(scripted);

  para(`## ${g.liveHeading}`);
  para(fill(g.live, { install: `${base}/docs/install/#before-you-go-live-four-things-on-your-project` }));

  para(`## ${g.invoiceHeading}`);
  para(g.invoiceLead);
  const { salesAccount, saleTaxes } = country.invoicing;
  const account = salesAccount ?? '<account>';
  const tax = saleTaxes[0];
  const lineSpec = [`name=${p.line}`, `price=${p.price}`, `account=${account}`, ...(tax === undefined ? [] : [`tax=${tax.code}`])];
  code([
    `ekwo login --supabase-url https://<ref>.supabase.co --anon-key <publishable key> --email ${p.email}`,
    `ekwo use "${p.company}"`,
    `ekwo contact add "${p.customer}" --country ${country.country} --ref customer-1`,
    `ekwo doc new --contact "${p.customer}" --ref invoice-1 --line "${lineSpec.join(',')}"`,
    'ekwo post invoice-1 --dry-run',
    'ekwo post invoice-1',
  ]);
  para(salesAccount === null ? g.invoiceNoAccount : fill(g.invoiceCodes, { account: salesAccount }));
  para(g.invoiceProfile);
  if (saleTaxes.length === 0) {
    para(g.noTaxes);
  } else {
    para(g.taxChoice);
    const [h1, h2, h3] = g.taxTableHeader;
    para(
      [
        `| ${h1} | ${h2} | ${h3} |`,
        '|---|---|---|',
        ...saleTaxes.map((t) => `| \`${t.code}\` | ${t.name}${t.jurisdiction === null ? '' : ` (${t.jurisdiction})`} | ${t.rate} % |`),
      ].join('\n'),
    );
  }

  para(`## ${g.assistantHeading}`);
  para(fill(g.assistant, { mcp: `${base}/docs/mcp/`, agents: `${base}/docs/agents/` }));

  para(`## ${fill(g.carriesHeading, named)}`);
  const carries: string[] = [
    fill(g.carriesCharts, {
      charts: country.charts.map((chart) => `${chart.name} (${chart.accounts})`).join(', '),
    }),
    fill(g.carriesTaxes, {
      count: country.taxes.count,
      rates: country.taxes.rates.map((rate) => `${rate} %`).join(', '),
    }),
    ...country.declarations.map((declaration) =>
      fill(g.carriesDeclaration, {
        name: declaration.name,
        code: declaration.code,
        boxes: declaration.boxes,
        periods: declaration.periods.join(', '),
      }),
    ),
    ...(country.einvoicing?.profile == null ? [] : [fill(g.carriesEinvoicing, { profile: country.einvoicing.profile })]),
    ...(country.statements.length === 0
      ? []
      : [fill(g.carriesStatements, { statements: country.statements.map((s) => s.name).join(', ') })]),
  ];
  para(carries.map((item) => `- ${item}`).join('\n'));

  para(`## ${g.notYetHeading}`);
  const notYet: string[] = [
    ...country.declarations
      .filter((declaration) => declaration.file.byHand)
      .map((declaration) => fill(g.notYetByHand, { code: declaration.code })),
    ...country.bankStatementFormats
      .filter((format) => !format.read)
      .map((format) => fill(g.notYetBank, { format: format.format })),
    g.notYetSend,
    fill(g.notYetReadme, { readme: repository.dir(`packs/${country.slug}`) }),
  ];
  para(notYet.map((item) => `- ${item}`).join('\n'));

  return `${out.join('\n').trim()}\n`;
}
