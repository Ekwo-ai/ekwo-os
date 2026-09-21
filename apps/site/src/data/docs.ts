/**
 * The documentation, as a list of files of this repository.
 *
 * Nothing here is an article. Every entry names a Markdown file the repository
 * already carries — a README, a page of `docs/`, the manifesto — and the site
 * renders it at build time, the way it renders `MANIFESTO.md`. The file is the
 * text and the page is a view of it: a copy made here would be a second
 * version, and the one that drifted would be the one nobody edits. A test
 * checks that every `source` exists.
 *
 * `section` cuts one file into two articles where it is really two: the
 * command line's README is the installation guide down to its table of
 * commands and the reference of the commands after it. It names the headings
 * the slice starts at and stops before, as they are written in the file, so a
 * heading renamed there is a build that fails rather than an article that
 * quietly swallows the rest of the file.
 *
 * The format libraries are not listed: `data.ts` gives each directory of
 * `packages/formats/` an article of its own, so a format added there is
 * documented here with nothing edited. The decision records are not listed
 * either, for the same reason: each numbered file of `docs/decisions/` is an
 * article under the index of that directory.
 *
 * Titles and the sentences that group the articles are the language's, in
 * `src/strings/`. What is listed, in which order and from which file, is here.
 */

/** The groups the documentation reads in, in the order they are shown. */
export const TOPICS = ['start', 'use', 'countries', 'books', 'reference', 'contribute', 'about'] as const;
export type Topic = (typeof TOPICS)[number];

export interface DocSource {
  /** The key of the article: its address under `/docs/`, and its title in the strings. */
  slug: string;
  topic: Topic;
  /** A Markdown file, from the root of the repository. */
  source: string;
  /** Only part of the file: from one `##` heading, up to another, or to the end. */
  section?: { from: string; until?: string };
  /**
   * Where it is published, when that is not `/docs/<slug>/`. The manifesto
   * keeps the address it has had since the first day of the site, and the
   * disclaimer has one of its own, one click from the foot of every page.
   */
  url?: string;
}

/** The format libraries' topic, and the directory each of their articles is read from. */
export const FORMATS_TOPIC: Topic = 'use';
export const FORMATS_DIR = 'packages/formats';

/** The directory of the decision records: one numbered file each, under its index. */
export const DECISIONS_DIR = 'docs/decisions';

export const DOCS: DocSource[] = [
  { slug: 'overview', topic: 'start', source: 'README.md' },
  { slug: 'agents', topic: 'start', source: 'AGENTS.md' },
  {
    slug: 'install',
    topic: 'start',
    source: 'packages/cli/README.md',
    section: { from: 'From a free Supabase account to a first invoice', until: 'Commands' },
  },

  {
    slug: 'cli',
    topic: 'use',
    source: 'packages/cli/README.md',
    section: { from: 'Commands' },
  },
  { slug: 'mcp', topic: 'use', source: 'packages/mcp/README.md' },
  { slug: 'core', topic: 'use', source: 'packages/core/README.md' },
  { slug: 'formats', topic: 'use', source: 'packages/formats/README.md' },

  { slug: 'packs', topic: 'countries', source: 'docs/packs.md' },
  { slug: 'languages', topic: 'countries', source: 'docs/languages.md' },
  { slug: 'international', topic: 'countries', source: 'docs/international.md' },

  { slug: 'filing', topic: 'books', source: 'docs/filing.md' },
  { slug: 'firms', topic: 'books', source: 'docs/firms.md' },
  { slug: 'sharing', topic: 'books', source: 'docs/sharing.md' },
  { slug: 'company-archive', topic: 'books', source: 'docs/company-archive.md' },
  { slug: 'modules', topic: 'books', source: 'modules/README.md' },

  { slug: 'schema', topic: 'reference', source: 'docs/schema.md' },
  { slug: 'mapping', topic: 'reference', source: 'docs/mapping.md' },
  { slug: 'decisions', topic: 'reference', source: 'docs/decisions/README.md' },

  { slug: 'contributing', topic: 'contribute', source: 'CONTRIBUTING.md' },
  { slug: 'writing-a-module', topic: 'contribute', source: 'docs/modules.md' },
  { slug: 'load', topic: 'contribute', source: 'docs/load.md' },
  { slug: 'releasing', topic: 'contribute', source: 'docs/releasing.md' },

  { slug: 'manifesto', topic: 'about', source: 'MANIFESTO.md', url: '/manifesto/' },
  { slug: 'disclaimer', topic: 'about', source: 'DISCLAIMER.md', url: '/disclaimer/' },
  { slug: 'security', topic: 'about', source: 'SECURITY.md' },
];

/**
 * The articles `llms-full.txt` carries whole, in this order, before the guide
 * of every country: what an assistant needs to set Ekwo up for somebody and
 * keep their books. The reference — the schema, the decisions — stays in
 * `llms.txt` as links, where a model that needs it can fetch it; in full it
 * would bury the rest. A test checks that every slug is an article.
 */
export const LLMS_FULL: readonly string[] = ['agents', 'overview', 'install', 'cli', 'mcp', 'filing', 'firms', 'disclaimer'];

/**
 * Articles `llms.txt` does not list: the mapping lines the schema up against
 * other software by name, which is for an integrator reading the repository
 * and not for an assistant setting Ekwo up.
 */
export const LLMS_LEFT_OUT: readonly string[] = ['mapping'];

/** The topics `llms.txt` files under "Optional": what a model may skip. */
export const LLMS_OPTIONAL: readonly Topic[] = ['reference', 'contribute'];
