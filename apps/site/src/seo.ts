/**
 * What a page says about itself to a machine: a search engine, or a model
 * asked which open source accounting software exists for a country.
 *
 * Two things live here. The **sentences** a page is summed up by — the meta
 * description of a country and the sentence its page opens with — which are
 * the facts of its pack put into words, so a reader who sees only that line
 * still learns what the pack carries. And the **structured data**, the
 * schema.org graph each page carries as JSON-LD: who publishes Ekwo, what the
 * software is, what a country pack is and which texts of law it was read
 * against.
 *
 * Nothing is written by hand per country. Every value comes from
 * `describePack()`, the documentation or the repository's manifest, the same
 * way the pages do, so a pack added to `packs/` gets its description, its
 * opening sentence and its dataset with nothing edited here. And nothing is
 * claimed that the pack does not say: no promise of conformity, no rating, no
 * price in a currency the product would then seem to default to.
 */

import type { PackDescription } from '../../../packages/cli/src/index.js';
import type { DocArticle, Repository, SiteData } from './data.js';
import { LANGUAGES, fill, prefixOf, type Strings } from './strings/index.js';

/** One node of a schema.org graph. */
export type Node = Record<string, unknown>;

/** A page's structured data, once the build knows where the site is served from. */
export type Graph = (origin: string) => Node[];

/** The brand, as every page's `og:site_name` already says it. */
export const BRAND = 'Ekwo';

/**
 * The country's name in the language rendered.
 *
 * The pack names itself in its own language — which is right on its page, where
 * the name is shown in every language the pack publishes — but a reader
 * searching in English searches for the English name. So: the pack's own
 * translation where it has one, the platform's region names otherwise, and the
 * pack's name when neither knows the code.
 */
export function countryName(country: PackDescription, lang: string): string {
  return (
    country.nameI18n[lang] ??
    new Intl.DisplayNames([lang], { type: 'region' }).of(country.country) ??
    country.name
  );
}

/** "a, b and c", in the language rendered. */
function list(items: string[], lang: string): string {
  return new Intl.ListFormat(lang, { type: 'conjunction' }).format(items);
}

/**
 * What a pack carries, as a phrase: its chart, its rates, its return, its
 * e-invoicing profile. `long` adds the chart and the sizes, for the sentence a
 * page opens with; without it the phrase fits a meta description.
 */
function factsOf(country: PackDescription, strings: Strings, long: boolean): string {
  const s = strings.seo;
  const facts: string[] = [];
  const chart = country.charts.find((c) => c.isDefault) ?? country.charts[0];
  if (long && chart !== undefined) {
    facts.push(fill(s.chart, { chart: chart.name, accounts: chart.accounts }));
  }
  facts.push(fill(s.rates, { count: country.taxes.rates.length, currency: country.currency }));
  for (const declaration of country.declarations) {
    facts.push(
      fill(long ? s.declarationBoxes : s.declaration, {
        declaration: declaration.name,
        boxes: declaration.boxes,
      }),
    );
  }
  if (country.einvoicing?.profile) {
    facts.push(fill(s.einvoicing, { profile: country.einvoicing.profile }));
  }
  return list(facts, strings.lang);
}

/** The meta description of a country's page. */
export function countryDescription(country: PackDescription, strings: Strings): string {
  return fill(strings.country.description, {
    country: countryName(country, strings.lang),
    facts: factsOf(country, strings, false),
  });
}

/**
 * The sentence a country's page opens with, and the description of its
 * dataset: standalone, so that quoted on its own it still says what Ekwo is,
 * what the pack carries and how old the reading of the law is.
 */
export function countrySummary(country: PackDescription, strings: Strings): string {
  const s = strings.seo;
  const summary = fill(s.countrySummary, {
    country: countryName(country, strings.lang),
    facts: factsOf(country, strings, true),
  });
  const { lastConsultedOn, sources } = country.certification;
  if (lastConsultedOn === null || sources.length === 0) return summary;
  return `${summary} ${fill(s.checked, { date: lastConsultedOn, sources: sources.length })}`;
}

/** The software's one-line answer to "what is Ekwo". */
export function softwareDescription(data: SiteData, strings: Strings): string {
  return fill(strings.seo.software, { countries: data.countries.length });
}

/** The published page of the SPDX identifier the manifest declares. */
function licenceUrl(repository: Repository): string {
  return `https://spdx.org/licenses/${repository.spdx}.html`;
}

const id = (origin: string, name: string): string => `${origin}/#${name}`;
const ref = (origin: string, name: string): Node => ({ '@id': id(origin, name) });

/** Who publishes Ekwo, where its source and its package are. */
function organization(origin: string, data: SiteData, strings: Strings): Node {
  return {
    '@type': 'Organization',
    '@id': id(origin, 'organization'),
    name: BRAND,
    url: `${origin}/`,
    logo: `${origin}/favicon.svg`,
    description: strings.seo.organization,
    sameAs: [data.repository.url, data.repository.packageUrl],
  };
}

function website(origin: string, strings: Strings): Node {
  return {
    '@type': 'WebSite',
    '@id': id(origin, 'website'),
    url: `${origin}/`,
    name: BRAND,
    description: strings.seo.organization,
    inLanguage: LANGUAGES.map((language) => language.lang),
    publisher: ref(origin, 'organization'),
  };
}

/** The software, and the source code it is built from. */
function software(origin: string, data: SiteData, strings: Strings): Node[] {
  const { repository } = data;
  const description = softwareDescription(data, strings);
  return [
    {
      '@type': 'SoftwareApplication',
      '@id': id(origin, 'software'),
      name: strings.seo.softwareName,
      alternateName: BRAND,
      description,
      url: `${origin}/${prefixOf(strings)}os/`,
      applicationCategory: 'BusinessApplication',
      applicationSubCategory: strings.seo.category,
      operatingSystem: strings.seo.operatingSystem,
      license: licenceUrl(repository),
      isAccessibleForFree: true,
      downloadUrl: repository.packageUrl,
      installUrl: `${origin}/${prefixOf(strings)}docs/install/`,
      softwareHelp: { '@type': 'CreativeWork', url: `${origin}/${prefixOf(strings)}docs/` },
      featureList: strings.seo.features.map((feature) =>
        fill(feature, { countries: data.countries.length }),
      ),
      keywords: strings.seo.keywords.join(', '),
      publisher: ref(origin, 'organization'),
      author: ref(origin, 'organization'),
    },
    {
      '@type': 'SoftwareSourceCode',
      '@id': id(origin, 'source'),
      name: strings.seo.softwareName,
      description,
      codeRepository: repository.url,
      license: licenceUrl(repository),
      programmingLanguage: ['TypeScript', 'SQL'],
      runtimePlatform: ['Node.js', 'PostgreSQL'],
      targetProduct: ref(origin, 'software'),
      author: ref(origin, 'organization'),
    },
  ];
}

/** A country pack: a dataset of rules, sourced to the law and dated. */
function dataset(origin: string, url: string, country: PackDescription, data: SiteData, strings: Strings): Node {
  const name = countryName(country, strings.lang);
  const { certification } = country;
  return {
    '@type': 'Dataset',
    '@id': `${origin}${url}#dataset`,
    name: fill(strings.seo.packName, { country: name }),
    description: countrySummary(country, strings),
    url: `${origin}${url}`,
    sameAs: data.repository.dir(`packs/${country.slug}`),
    license: licenceUrl(data.repository),
    isAccessibleForFree: true,
    version: country.version,
    ...(certification.lastConsultedOn === null ? {} : { dateModified: certification.lastConsultedOn }),
    inLanguage: country.languages,
    spatialCoverage: { '@type': 'Country', name, identifier: country.country },
    keywords: [
      name,
      country.currency,
      ...country.charts.map((chart) => chart.name),
      ...country.declarations.map((declaration) => declaration.name),
      ...(country.einvoicing?.profile ? [country.einvoicing.profile] : []),
    ],
    citation: certification.sources.map((source) => ({
      '@type': 'CreativeWork',
      name: source.title,
      url: source.url,
      publisher: { '@type': 'Organization', name: source.publisher },
    })),
    creator: ref(origin, 'organization'),
  };
}

/** One step of a breadcrumb: a name and the path it is at, prefix included. */
export interface Crumb {
  name: string;
  path: string;
}

/** What a page is, for its structured data. */
export type About =
  | { kind: 'home' }
  | { kind: 'software' }
  | { kind: 'country'; country: PackDescription }
  | { kind: 'article'; article: DocArticle }
  | { kind: 'page' };

/**
 * The graph of one page: the page itself, where it sits, and what it is about.
 *
 * The organization and the website are on every page, because a page is quoted
 * alone; the software is on the home page and the core's page, which are the
 * two answers to "what is Ekwo"; a country page adds its pack as a dataset, an
 * article of the documentation is a technical article.
 */
export function graphOf(
  page: { url: string; title: string; description: string; lang: string },
  about: About,
  crumbs: readonly Crumb[],
  data: SiteData,
  strings: Strings,
): Graph {
  return (origin) => {
    const url = `${origin}${page.url}`;
    const nodes: Node[] = [organization(origin, data, strings), website(origin, strings)];
    const webpage: Node = {
      '@type': about.kind === 'home' ? ['WebPage', 'AboutPage'] : 'WebPage',
      '@id': `${url}#webpage`,
      url,
      name: page.title,
      description: page.description,
      inLanguage: page.lang,
      isPartOf: ref(origin, 'website'),
    };
    nodes.push(webpage);

    if (crumbs.length > 0) {
      const trail = [{ name: strings.seo.home, path: `/${prefixOf(strings)}` }, ...crumbs];
      webpage['breadcrumb'] = { '@id': `${url}#breadcrumb` };
      nodes.push({
        '@type': 'BreadcrumbList',
        '@id': `${url}#breadcrumb`,
        itemListElement: trail.map((crumb, index) => ({
          '@type': 'ListItem',
          position: index + 1,
          name: crumb.name,
          item: `${origin}${crumb.path}`,
        })),
      });
    }

    if (about.kind === 'home' || about.kind === 'software') {
      nodes.push(...software(origin, data, strings));
      webpage['about'] = ref(origin, 'software');
    } else if (about.kind === 'country') {
      nodes.push(dataset(origin, page.url, about.country, data, strings));
      webpage['mainEntity'] = { '@id': `${url}#dataset` };
    } else if (about.kind === 'article') {
      nodes.push({
        '@type': 'TechArticle',
        '@id': `${url}#article`,
        headline: page.title,
        description: page.description,
        url,
        inLanguage: page.lang,
        mainEntityOfPage: { '@id': `${url}#webpage` },
        isBasedOn: data.repository.file(about.article.source),
        author: ref(origin, 'organization'),
        publisher: ref(origin, 'organization'),
      });
    }
    return nodes;
  };
}

/**
 * The graph as a `<script>` a crawler reads and a browser ignores.
 *
 * `<` is written as its escape so no string of the data — a title quoting a
 * tag, a `</script>` in a legal reference — can close the element early.
 */
export function jsonLd(nodes: Node[]): string {
  const json = JSON.stringify({ '@context': 'https://schema.org', '@graph': nodes });
  return `<script type="application/ld+json">${json.replace(/</g, '\\u003c')}</script>`;
}
