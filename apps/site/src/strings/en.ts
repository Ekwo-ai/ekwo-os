/**
 * English — the language the site is written in, and the source every
 * translation is measured against.
 *
 * Two rules held while writing every sentence here. **A vision is asserted and
 * a fact is not invented**: what ships is said to ship, what is coming is said
 * to be coming, and nothing that could not be checked against the repository
 * survived the draft. And **a sentence a reader has to read twice was cut** —
 * no paradox, no metaphor, no phrase that sounds clever and says nothing.
 */

import type { Strings } from './types.js';

export const en: Strings = {
  lang: 'en',
  languageName: 'English',

  nav: {
    label: 'Site',
    os: 'Open source',
    countries: 'Countries',
    docs: 'Docs',
    login: 'Log in',
    github: 'Ekwo OS on GitHub',
    supabase: 'Install Ekwo on Supabase',
  },

  controls: {
    palette: 'Colour: cobalt or gold',
    theme: 'Day or night',
  },

  footer: {
    label: 'About this project',
    tagline: 'Open source accounting, finance and sustainability',
    licence: 'Licence',
    disclaimer: 'Disclaimer',
    security: 'Security',
    source: 'Source',
    npm: 'npm',
  },

  home: {
    title: 'Ekwo — open source accounting, finance and sustainability',
    description:
      'Open source accounting, finance and sustainability, for every country. The data ' +
      'belongs to the business: it lives in a database you own, under rules anyone can read, ' +
      'and an AI keeps the books without ever becoming the only one who understands them.',
    hero: {
      eyebrow: 'Open source accounting, finance and sustainability',
      title: 'Accounting, set free.',
      // The first word turns. The first of these is the stable one: it is what
      // the heading says to a screen reader, to a search engine and to anybody
      // whose system asks for less motion.
      titleWords: ['Accounting', 'Finance', 'Tax', 'Sustainability', 'Your ERP'],
      titleTail: 'set free.',
      titleAccessible: 'Accounting, finance, tax, sustainability and your ERP, set free.',
      lead:
        'Every business on earth keeps books. Ekwo is building the open source system that ' +
        'keeps them — in a database you own, under rules anyone can read.',
      ai: 'AI does the bookkeeping. You stay in control.',
      install: 'Install Ekwo OS',
      manifesto: 'Read the manifesto',
    },
    world: {
      eyebrow: 'Everywhere',
      title: 'Free and independent accounting, in every country of the world.',
      lead: '',
      body:
        'No business, anywhere, should have to rent the right to keep its own books. Ekwo is ' +
        'written country by country, by the people who know the rules of each one — ' +
        'accountants, tax advisers, developers — and given back to everyone. {countries} ' +
        'countries today. The rest of the world is open, and it is yours to write.',
      written: 'countries written',
      open: 'open — yours to write',
      signature: 'A business is data, in every country.',
      howItWorks: 'How it works',
      how:
        'the rules of a country are files, not code — a chart of accounts, its taxes, the ' +
        'boxes of its return, its financial statements, the sentences its law puts on an ' +
        'invoice. An accountant can read them, a contributor can propose them, a test can ' +
        'prove them. Adding a country touches no engine.',
      guide: 'Write the pack for your country',
    },
    promises: {
      eyebrow: 'What you get',
      title: 'Six things a business should never have to rent.',
      lead: '',
      items: [
        {
          title: 'Freedom',
          body:
            'Free and open source. Read it, run it, change it, and take it with you. The core ' +
            'is AGPL-3.0 and the format libraries are MIT, so what is built on it stays open.',
        },
        {
          title: 'No lock-in',
          body:
            'It installs on a database you own — an ordinary Postgres — and your books leave ' +
            'whole, as an open archive, whenever you want them to. It keeps working whoever ' +
            'disappears.',
        },
        {
          title: 'Your data stays yours',
          body:
            'The books live in your own database, not on somebody else’s servers. You hold ' +
            'the keys, and you decide who reads them.',
        },
        {
          title: 'Compliance, in the open',
          body:
            'The rules of each country are published, sourced to the law and dated — charts ' +
            'of accounts, taxes, the boxes of the return, statutory statements and electronic ' +
            'invoicing. Every country page says when it was last checked.',
        },
        {
          title: 'Security',
          body:
            'Access is enforced by the database itself, on every row of every table. A posted ' +
            'entry cannot be altered. Every change leaves an audit trail.',
        },
        {
          title: 'Privacy',
          body:
            'Your numbers are in your database and nowhere else. This site sets no cookie, ' +
            'loads nothing from anyone and serves its own typefaces. The hosted edition is ' +
            'your own instance.',
        },
      ],
    },
    automation: {
      eyebrow: 'Automation',
      title: 'The work that no longer needs typing.',
      lead:
        'An agent or a script calls the same functions a person does, with the same rights ' +
        'and under the same rules. Nothing has a private way in.',
      demoNote: 'Example session. Commands and results are real output from this release.',
      tabs: { cli: 'Command line', agent: 'Agent', claude: 'Claude Code' },
      cliCaption: 'Replayed from the {country} pack’s golden year.',
      agentCaption:
        'The agent stops and asks before anything is booked. The figures are the {country} ' +
        'pack’s golden year, to the cent.',
      claudeCaption:
        'Claude Code with the Ekwo MCP server. Claude reads the PDF; Ekwo extracts nothing ' +
        'from a file and stores no file from here — it keeps the draft and the rules. The ' +
        'invoice is from the {country} pack’s golden year.',
    },
    models: {
      title: 'Works with the model you choose',
      body:
        'Ekwo embeds no model and imposes none. It exposes its tools over the open Model ' +
        'Context Protocol and a command line a program can read, so an assistant keeps the ' +
        'books with the rights of the person it acts for — never with a key of its own — and ' +
        'you can change your mind about which one.',
      openWeight: 'open-weight and local models, through any MCP client',
      any: 'any MCP client',
      foundationsTitle: 'Built on open foundations',
      foundationsBody:
        'Ekwo installs on your own Supabase project: your database, your keys, your bill. The ' +
        'schema is ordinary PostgreSQL, and the files it writes and reads are published ' +
        'standards rather than formats of its own.',
      ownership:
        'Names and logos belong to their owners. Ekwo is not affiliated with any of them; ' +
        'compatibility is through the open Model Context Protocol and published standards.',
    },
    scale: {
      eyebrow: 'Where it stands',
      title: 'Everything a business needs, all free.',
      lead: '',
      freeLine:
        'Free software under AGPL-3.0.',
      direction:
        'Accounting is where Ekwo starts. Everything else a business runs on comes as a ' +
        'module on the same books — each one free, each one in the open.',
      modulesLink: 'How a module works',
      families: {
        accounting: 'Accounting',
        finance: 'Finance',
        sustainability: 'Sustainability',
        digital: 'Digital assets',
        documents: 'Documents & signature',
      },
    },
    ways: {
      eyebrow: 'Two ways to run it',
      title: 'Own it, or have it operated.',
      ownTitle: 'On your own',
      ownBody:
        'Free, for ever. One command points it at your own Supabase project and it applies ' +
        'the schema, seeds the country rules and creates the first company. Nothing is gated.',
      ownAction: 'Install Ekwo OS',
      hostedTitle: 'Operated for you',
      hostedBody:
        'The hosted edition: your own instance, run and watched for you. What is sold is the ' +
        'operating — bank connections, sending and receiving over Peppol, filing to the ' +
        'administrations, the agents — and somebody answerable when a return is late. It ' +
        'never gates the core, and what comes back from a filing is yours.',
      hostedAction: 'Talk to us',
    },
    network: {
      eyebrow: 'A network, not a vendor',
      title: 'Bring your expertise.',
      lead: '',
      body:
        'No company can know the accounting rules of the world. A network can. Accountants ' +
        'and tax advisers review the pack for their country and put their name on it; ' +
        'developers write a format library, a bank parser or the module their clients need; ' +
        'translators make a chart of accounts readable in their language. A pack is reviewed ' +
        'when a named professional has read it against the law they apply — not when anybody ' +
        'says so.',
      write: 'Write a country pack',
      review: 'Propose or review one',
      countriesToday: 'Countries today',
      openInvite: 'Every other country on the map is open.',
      guide: 'Here is the pack to write.',
    },
    closing: {
      quote: 'The data belongs to the business.',
      link: 'Read the manifesto',
    },
  },

  os: {
    title: 'Ekwo OS — the open source core',
    description:
      'Install the accounting core on your own Supabase project: the schema, the country ' +
      'rules and the first company, in one command.',
    eyebrow: 'The open source core',
    countries: 'Countries',
    missing: 'Your country is missing?',
    guide: 'Here is the pack to write.',
    source: 'Source on GitHub',
    npm: 'On npm',
    compare: 'Compare two countries',
    tested:
      'Every release runs its suite on three versions of Node: the accounting rules, each ' +
      'country pack replayed against a year of books, and the installer, against real ' +
      'Postgres.',
  },

  docs: {
    title: 'Docs — Ekwo',
    description:
      'How to install Ekwo OS on your own Supabase project, keep books with the command line ' +
      'or an assistant, write a country pack, and why any of it exists — read from the ' +
      'repository itself.',
    eyebrow: 'Docs',
    heading: 'Documentation',
    lead:
      'Every page here is a file of the repository, rendered when the site is built, so it ' +
      'says what the code in the same release does. What is not written yet says so.',
    label: 'Documentation',
    search: 'Search the docs',
    noMatch: 'No article matches.',
    copy: 'Copy',
    browse: 'Browse the docs',
    onThisPage: 'On this page',
    previous: 'Previous',
    next: 'Next',
    renderedFrom: 'Rendered from {path}, in the repository, when the site was built.',
    viewSource: 'Read or change it on GitHub',
    articleTitle: '{article} — Ekwo docs',
    topics: {
      start: {
        title: 'Start here',
        lead: 'What Ekwo OS is, and one command from a free Supabase project to a first invoice.',
      },
      use: {
        title: 'Keep the books',
        lead: 'The command line, the MCP server an assistant connects to, the TypeScript client and the format libraries.',
      },
      countries: {
        title: 'Countries',
        lead: 'A country is a pack of files, not code. How one is written, translated and checked.',
      },
      books: {
        title: 'Running a business on it',
        lead: 'Filing a declaration, a firm and its clients, sharing a document, moving a company, and the modules.',
      },
      reference: {
        title: 'Reference',
        lead: 'Every table and function, the mapping to the standards, and every design decision with its reason.',
      },
      contribute: {
        title: 'Contributing',
        lead: 'How a pull request gets in, how a module is written, how the books are tested at volume, how a release is cut.',
      },
      about: {
        title: 'About Ekwo',
        lead: 'Why it is being built, what it does not promise, and where to report a flaw.',
      },
    },
    articles: {
      overview: { label: 'Ekwo OS, in one page', title: 'Ekwo OS, in one page' },
      install: { label: 'Install', title: 'Install Ekwo OS on your own Supabase project' },
      cli: { label: 'The command line', title: 'The command line: ekwo' },
      mcp: { label: 'The MCP server', title: 'The MCP server: an assistant at the books' },
      core: { label: 'The TypeScript client', title: 'The TypeScript client: @ekwo-ai/core' },
      formats: { label: 'Format libraries', title: 'Format libraries' },
      packs: { label: 'Country packs', title: 'Country packs' },
      languages: { label: 'Languages', title: 'Languages' },
      international: { label: 'Beyond the first countries', title: 'Beyond the first countries' },
      filing: { label: 'Filing a declaration', title: 'The life of a declaration' },
      firms: { label: 'A firm and its clients', title: 'An accounting firm and its clients' },
      sharing: { label: 'Sharing a document', title: 'Sharing a document' },
      'company-archive': { label: 'Moving a company', title: 'The archive of one company' },
      modules: { label: 'Modules', title: 'Modules' },
      schema: { label: 'Schema', title: 'Schema' },
      mapping: { label: 'Mapping to the standards', title: 'Mapping: Ekwo, Odoo, EN 16931 and the FEC' },
      decisions: { label: 'Decisions', title: 'Decisions, and the reason for each' },
      contributing: { label: 'How to contribute', title: 'Contributing to Ekwo OS' },
      'writing-a-module': { label: 'Writing a module', title: 'Writing a module' },
      load: { label: 'Books at volume', title: 'Books at volume' },
      releasing: { label: 'Cutting a release', title: 'How a release is cut' },
      manifesto: { label: 'Manifesto', title: 'Why we are building Ekwo' },
      disclaimer: { label: 'What Ekwo is not', title: 'What Ekwo is, and what it is not' },
      security: { label: 'Security', title: 'Reporting a flaw' },
    },
    notes: {
      install:
        'There is no web interface yet. Once installed, the books are kept through the ' +
        'command line, the MCP server, the REST API Supabase generates from the schema, or ' +
        '@ekwo-ai/core.',
      cli:
        'Every command below exists in this release. One thing it points at does not: the ' +
        'registry `ekwo register` announces an installation to. The command keeps the record ' +
        'locally and says the announcement did not go through.',
      mcp:
        'The server reads and writes the books; it reads no PDF and stores no file. An ' +
        'assistant that reads an invoice does so with its own tools, and drafts what it read.',
      international:
        'A plan. Phase 0, the country-agnostic core, is done, and so are the packs the site ' +
        'lists. The phases after it are intentions with a quarter attached, not software.',
      modules:
        'Two modules ship today: assets and budgets. The two under “Planned modules” are ' +
        'decided and not written.',
    },
    summaries: {
      install:
        'From a free Supabase account to a first invoice: one command applies the schema, ' +
        'seeds the country rules and creates the first company — then the four settings no ' +
        'installer can reach.',
      cli:
        'Every command of ekwo: what it answers, its exit codes, signing in as yourself, ' +
        'keeping books, modules, moving a company, the doctor, and the flags.',
    },
  },

  countries: {
    indexTitle: 'Countries — Ekwo',
    indexDescription:
      'Every country Ekwo has a pack for: what it carries, what it does not yet, and when it ' +
      'was last checked against the law.',
    eyebrow: 'Every country',
    title: 'The countries written so far.',
    lead:
      'Each one is a folder of files an accountant can read. Open one to see what it carries, ' +
      'where it stops, and the texts it was built from.',
  },

  country: {
    title: '{country} — Ekwo',
    description:
      'What the {country} pack carries: its charts of accounts, its taxes, its periodic ' +
      'declaration, and what is not written yet.',
    eyebrow: 'Country pack',
    code: 'Country code',
    currency: 'Currency',
    version: 'Pack version',
    lastChecked: 'Last checked',
    noDay: 'no day',
    carries: 'What the pack carries',
    boundaryEyebrow: 'Free, and operated',
    boundaryTitle: 'Where the open core stops.',
    boundaryLead:
      'The line is operational, not functional. Everything that keeps working on its own is ' +
      'open core; what needs credentials, a certificate or somebody answerable is the hosted ' +
      'edition.',
    free: 'Free, for ever',
    operated: 'Operated',
    nothingOperated: 'nothing to operate',
    sourcesEyebrow: 'What it was built from',
    sourcesSummary: '{count} sources — the law this pack was read against',
    noSources: 'this pack cites no text that can be opened',
    packFiles: 'The pack, file by file',
    writeYours: 'Write the pack for your country',
    compare: 'Compare it with another country',
  },

  compare: {
    title: 'Compare two countries — Ekwo',
    description: 'The same table in two columns, for any two of the country packs that ship here.',
    heading: 'Compare two countries',
    lead:
      'The same table, in two columns. Every pair has its own page, so the comparison works ' +
      'with scripting turned off and can be linked to.',
    caption:
      'Each cell links to the comparison of the country of its row with the country of its ' +
      'column.',
    everyPair: 'Every pair',
    onlyOne: 'There is one country here so far, so there is nothing to compare it with.',
    carries: 'What the pack carries',
    pairTitle: '{a} and {b} — Ekwo',
    pairDescription: 'What the {a} and {b} packs carry, side by side.',
  },

  rows: {
    charts: {
      label: 'Charts of accounts',
      hint: 'What a company installs, and who each chart is published for.',
    },
    taxes: {
      label: 'Taxes',
      hint: 'How many the pack carries, at which distinct rates, and which treatments it can express.',
    },
    declaration: {
      label: 'Periodic declaration',
      hint: 'The form the ledger is read into, the cadences it is filed on, and how many boxes it has.',
    },
    deadline: {
      label: 'When it is due',
      hint: 'A rule of the country, not a date. A pack that cannot state its rule states nothing.',
    },
    file: {
      label: 'The file it is deposited as',
      hint: 'The brick of packages/formats that writes it, where one exists.',
    },
    einvoicing: {
      label: 'Electronic invoicing',
      hint: 'The profile the country imposes, the day it starts, and the text that imposes it.',
    },
    balance: {
      label: 'Where the tax balance lands',
      hint: 'The accounts a filed declaration settles to, by role.',
    },
    bank: {
      label: 'Bank statements',
      hint: 'The formats this country’s banks send, and whether anything here reads them.',
    },
    payments: {
      label: 'Payment files',
      hint: 'The formats the country’s banks accept for an outgoing payment.',
    },
    statements: {
      label: 'Financial statements',
      hint: 'The schemes the chart reports on, and the taxonomy their keys are written against.',
    },
    certification: {
      label: 'Who has read it',
      hint: 'A pack is reviewed when a named professional has read it against the law, and never before.',
    },
    checked: {
      label: 'Last checked against the law',
      hint: 'The most recent day somebody opened one of the texts the pack was built from.',
    },
    version: {
      label: 'Pack version',
      hint: 'What this pack calls itself, the day it says its transcription is true, and the languages it publishes.',
    },
  },

  notYet: {
    default: 'not yet',
    noTreatment: 'no treatment declared',
    noDeclaration: 'no periodic return declared',
    nothingDue: 'no declaration to be due',
    deadlineUndeclared: 'not declared in the pack',
    nothingToDeposit: 'no declaration to deposit',
    byHand: 'filed by hand on the administration’s portal',
    noProfile: 'no profile declared',
    noProfileNamed: 'no profile',
    noObligationDate: 'no date of obligation',
    noObligation: 'no obligation in law',
    onRequest: 'owed when the buyer asks for one — no general obligation',
    dependsOnTaxpayer: 'a day assigned per taxpayer',
    noLegalReference: 'no legal reference',
    noAccount: 'no account named',
    noFormat: 'no format named',
    noReader: 'no reader yet',
    genericStatements: 'generic statements only',
    noReviewer: 'no named reviewer',
    noSourceDay: 'no source carries a day',
    noReleaseDate: 'no release date',
    noLanguage: 'no language declared',
    read: 'read',
    sourcesCited: 'sources cited',
    accounts: 'accounts',
    forAudience: 'for',
    defaultChart: 'default',
    boxes: 'boxes',
    filed: 'filed',
    lines: 'lines',
    published: 'published',
    mandatoryFrom: 'mandatory from',
    payable: 'payable',
    receivable: 'receivable',
    taxesAt: 'at',
  },

  status: {
    planned: 'planned',
  },
};
