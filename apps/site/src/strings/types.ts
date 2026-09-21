/**
 * Every word the site says in its own voice, as one shape.
 *
 * The site is published in English today and will be published in more. The
 * reason this file exists before a second language does is that retrofitting
 * one means finding every string in every component, and the strings that get
 * missed are always the small ones — a button label, an empty state, the
 * sentence under a table.
 *
 * Two kinds of text are deliberately **not** here.
 *
 * The **packs** carry their own translations, in `packs/<cc>/i18n/`: the name
 * of a country, of a chart of accounts, of a tax, of a box of a declaration.
 * Those belong to the country and are versioned with it, and mixing them into
 * the site's own words would give one label two owners.
 *
 * And the **manifesto** is a document, not an interface. It is rendered from
 * `MANIFESTO.md`; a translation of it would be a `MANIFESTO.<lang>.md` beside
 * it, and until somebody writes one there is nothing to choose between.
 *
 * A language is complete or it is not published: every field below is
 * required, so a missing one is a type error, and a test compares the key sets
 * of every language against the source.
 */

/** A heading with the line that introduces it. */
export interface Section {
  eyebrow: string;
  title: string;
  lead: string;
}

export interface Strings {
  /** BCP 47, and what goes in `<html lang>`. */
  lang: string;
  /** The language's own name, for a switcher that does not exist yet. */
  languageName: string;

  nav: {
    label: string;
    os: string;
    countries: string;
    /** The roof of the documentation, the manifesto among it. */
    docs: string;
    /** The way in to the hosted application, for somebody who already has an account. */
    login: string;
    /** The accessible names of the two marks beside it. */
    github: string;
    supabase: string;
    /** The way to set Ekwo up, from any page: `/signup/`. */
    start: string;
  };

  controls: {
    palette: string;
    theme: string;
  };

  footer: {
    label: string;
    tagline: string;
    licence: string;
    disclaimer: string;
    security: string;
    source: string;
    npm: string;
    /** The page for a business in several countries. */
    multi: string;
    /** The timeline. */
    changes: string;
  };

  home: {
    title: string;
    description: string;
    hero: {
      eyebrow: string;
      /** The stable form: `<title>`, the metadata, and reduced motion. */
      title: string;
      /** The word that turns. The first is the stable one. */
      titleWords: string[];
      /** What follows it, and never moves. */
      titleTail: string;
      /** The whole ambition in one sentence, for a screen reader. */
      titleAccessible: string;
      lead: string;
      ai: string;
      /** The main button: the form, `/signup/`. */
      start: string;
      install: string;
      manifesto: string;
      /** The row of models under the buttons, and its small print. */
      models: {
        label: string;
        any: string;
        ownership: string;
      };
    };
    world: Section & {
      /** `{countries}` is replaced by the number of packs. */
      body: string;
      written: string;
      open: string;
      /** The line the whole section turns on. */
      signature: string;
      howItWorks: string;
      how: string;
      guide: string;
    };
    promises: Section & {
      items: { title: string; body: string }[];
    };
    automation: Section & {
      demoNote: string;
      tabs: { cli: string; agent: string; claude: string };
      cliCaption: string;
      agentCaption: string;
      /** What is true of the Claude Code session, and whose words are whose. */
      claudeCaption: string;
    };
    models: {
      title: string;
      body: string;
      foundationsTitle: string;
      foundationsBody: string;
      ownership: string;
    };
    scale: {
      eyebrow: string;
      title: string;
      lead: string;
      freeLine: string;
      direction: string;
      modulesLink: string;
      families: {
        accounting: string;
        finance: string;
        sustainability: string;
        digital: string;
        documents: string;
      };
    };
    ways: {
      eyebrow: string;
      title: string;
      ownTitle: string;
      ownBody: string;
      ownAction: string;
      hostedTitle: string;
      hostedBody: string;
      hostedAction: string;
    };
    network: Section & {
      body: string;
      write: string;
      review: string;
      countriesToday: string;
      openInvite: string;
      guide: string;
    };
    closing: {
      quote: string;
      link: string;
    };
  };

  os: {
    title: string;
    description: string;
    eyebrow: string;
    countries: string;
    missing: string;
    guide: string;
    source: string;
    npm: string;
    compare: string;
    tested: string;
  };

  docs: {
    title: string;
    description: string;
    eyebrow: string;
    heading: string;
    lead: string;
    /** The label of the list of articles, for a screen reader. */
    label: string;
    search: string;
    noMatch: string;
    /** The button in the corner of a block of code. */
    copy: string;
    /** The narrow disclosure that holds the list. */
    browse: string;
    onThisPage: string;
    previous: string;
    next: string;
    /** `{path}` is the file an article is rendered from. */
    renderedFrom: string;
    viewSource: string;
    /** `{article}` is the article's title. */
    articleTitle: string;
    topics: Record<'start' | 'use' | 'countries' | 'books' | 'reference' | 'contribute' | 'about', { title: string; lead: string }>;
    /**
     * Every listed article by its key in `data/docs.ts`: the short word the
     * list shows, and the heading of the page. A format library has no entry:
     * it is titled by its own README.
     */
    articles: Record<string, { label: string; title: string }>;
    /**
     * A sentence at the top of an article about what it describes and what does
     * not exist yet. Only where the file leaves a reader to work that out.
     */
    notes: Record<string, string>;
    /**
     * The sentence a card and a link preview show, for an article cut out of a
     * file: its first paragraph there is the middle of somebody else's page.
     */
    summaries: Record<string, string>;
  };

  countries: {
    indexTitle: string;
    indexDescription: string;
    eyebrow: string;
    title: string;
    lead: string;
  };

  country: {
    /** `{country}` is replaced by the pack's own name for itself. */
    title: string;
    description: string;
    eyebrow: string;
    code: string;
    currency: string;
    version: string;
    lastChecked: string;
    noDay: string;
    carries: string;
    boundaryEyebrow: string;
    boundaryTitle: string;
    boundaryLead: string;
    free: string;
    operated: string;
    nothingOperated: string;
    sourcesEyebrow: string;
    /** `{count}` is replaced by the number of sources. */
    sourcesSummary: string;
    noSources: string;
    packFiles: string;
    writeYours: string;
    compare: string;
  };

  compare: {
    title: string;
    description: string;
    heading: string;
    lead: string;
    /** The two pickers. */
    first: string;
    second: string;
    onlyOne: string;
    carries: string;
    /** Said only where the browser cannot hide the countries not picked. */
    everyColumn: string;
  };

  /**
   * `/multi-country/` — several countries, one set of books. The keys of
   * `audiences`, `shipped` and `later` are the keys of `data/multicountry.ts`,
   * which carries the icon and the file each claim rests on.
   */
  multi: {
    title: string;
    description: string;
    eyebrow: string;
    heading: string;
    lead: string;
    /** Under the counters: `{countries}`, `{currencies}` and `{languages}` are counted. */
    today: string;
    audiencesTitle: string;
    audiences: Record<string, { title: string; body: string }>;
    shippedTitle: string;
    shippedLead: string;
    shipped: Record<string, { title: string; body: string }>;
    laterTitle: string;
    laterLead: string;
    later: Record<string, { title: string; body: string }>;
    /** The two words a claim of the lower list is marked with. */
    planned: string;
    notYet: string;
    proof: string;
    contactTitle: string;
    contactBody: string;
    contactAction: string;
    /** Where the page is linked from. */
    homeLink: string;
    countriesLink: string;
  };

  /**
   * Setting Ekwo up: the button on every country page, the page it leads to,
   * `/signup/` where no country is known yet, the form both carry and the page
   * a sent form lands on. `{country}` is the pack's own name for itself.
   */
  setup: {
    /** The strong button of a country page, at its head and at its foot. */
    action: string;
    /** The heading and the line above it at the foot of the page. */
    actionHeading: string;
    actionLead: string;
    /** `/countries/<cc>/set-up/`. */
    title: string;
    description: string;
    eyebrow: string;
    heading: string;
    lead: string;
    /** `/signup/`, where the country is chosen in the form. */
    anyTitle: string;
    anyDescription: string;
    anyHeading: string;
    anyLead: string;
    ownTitle: string;
    /** With a country: `{country}` is named. */
    ownBody: string;
    ownBodyAny: string;
    /** Under the command: what it will still ask. */
    ownAsks: string;
    ownGuide: string;
    withUsTitle: string;
    withUsBody: string;
    form: {
      email: string;
      company: string;
      optional: string;
      country: string;
      countryChoose: string;
      /** The option for a country no pack covers yet. */
      countryOther: string;
      /** Beside the fixed country: the way to pick another one. */
      countryChange: string;
      profile: string;
      profiles: { company: string; firm: string; partner: string };
      message: string;
      consent: string;
      submit: string;
      /** The field only a robot fills, to a screen reader that finds it anyway. */
      honeypot: string;
    };
    /** What the form collects, why, and how to have it erased. */
    privacy: string;
    thanksTitle: string;
    thanksDescription: string;
    thanksHeading: string;
    thanksBody: string;
    thanksDocs: string;
    thanksHome: string;
  };

  /**
   * `/changes/` and the section of the home page that shows its head. Every
   * item is read from the repository (`src/changes.ts`); these are only the
   * words around them.
   */
  changes: {
    title: string;
    description: string;
    eyebrow: string;
    heading: string;
    lead: string;
    /** Where the items come from, under the list. */
    source: string;
    /** The section on the home page, and its link to the whole list. */
    homeTitle: string;
    homeLead: string;
    all: string;
    kinds: { country: string; feature: string; fix: string; release: string };
    /** `{country}` is the pack's own name. */
    newCountry: string;
    /** `{country}` and `{version}`. */
    countryVersion: string;
    /** `{version}`. */
    release: string;
    unreleased: string;
    undated: string;
    /** The link of an item. */
    readMore: string;
    countryPage: string;
  };

  /** The grouping of every list of countries. */
  regions: {
    /** The jump links, to a screen reader. */
    label: string;
    search: string;
    noMatch: string;
    /** The group of a country the United Nations list does not place. */
    unplaced: string;
    /** On a page that summarises, the link to the whole list. */
    all: string;
  };

  /** The rows of the status table, by the key `rows.tsx` gives each one. */
  rows: Record<string, { label: string; hint: string }>;

  /** Words a value falls back to when a pack says nothing. */
  notYet: Record<string, string>;

  status: {
    planned: string;
  };
}
