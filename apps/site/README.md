# `apps/site` — the public site

## Status of this branch

`site-multi-country` — built on `site-compare-scale` (the comparison on one
page, countries by region), and adds `/multi-country/`: several countries, one
set of books.

- **Done.** The page speaks to three readers — a group with a company per
  country, an accounting firm with clients abroad, a company opening a new
  country — then lists what works today, each line linked to the file that
  makes it true, and what does not yet. Its claims are
  `src/data/multicountry.ts`, its words `strings.multi`; the three numbers
  under the lead are counted from the packs. It is linked from the home page,
  from `/countries/` and from the foot of every page; in the header it sits
  under Countries.
- **Claimed as working**, with its proof: companies of several countries in
  one installation (`docs/firms.md`), a company created on its country's pack
  (`packages/mcp/src/tools/write.ts`), a currency per company with rates and
  realised differences (`20260912112132_cash_basis_vat_and_fx.sql`), a role per
  person per company (`20260911120000_core_companies.sql`), the deadlines of
  every company one keeps (`20260918130000_every_company_somebody_keeps.sql`),
  the command line and the MCP server across companies
  (`packages/mcp/src/server.ts`), `ekwo company export | import`
  (`docs/company-archive.md`) and `ekwo pack describe`
  (`packages/cli/src/commands/pack.ts`).
- **Said as not there yet.** Consolidation is `planned` (`docs/international.md`,
  phase 2). Intercompany matching, revaluation of open foreign-currency items
  and teams of collaborators are `not yet`, with no date.

One page per country, built from the packs of this repository. It is a private
workspace: it is never published to npm, and nothing else in the repository
depends on it.

```sh
npm ci
npm run build --workspace @ekwo-ai/site     # writes apps/site/dist
npm run preview --workspace @ekwo-ai/site   # serves it at http://localhost:4173
```

The output is static HTML, one stylesheet, two typefaces and nothing else.
Every page is complete with scripting turned off — including the comparison of
two countries, whose two pickers are native `<select>`s read by CSS (see
[Comparing two countries](#comparing-two-countries)). One inline script exists, a few hundred bytes at the end of the body:
it reveals the button that copies a command, and the button ships `hidden` so
nobody ever sees a control that does nothing. The site fetches nothing from
another origin — not a font, not a script, not an image.

## How the build works

Two passes and a script, which is the whole of it:

1. `vite build` compiles `src/styles.css` and writes `dist/index.html`, the
   template, with the stylesheet fingerprinted into it.
2. `vite build --ssr src/prerender.ts` bundles the prerender for Node.
3. `node .prerender/prerender.js` reads that template back, renders every page
   with `renderToStaticMarkup`, and writes the files.

`src/render.tsx` decides which pages exist. `tests/site.test.ts` calls it
directly, so the test is about what ships and does not need Vite to have run.

## Where each thing on a page comes from

Nothing on this site is typed into it. `src/data.ts` is the only file that
reads the disk, and it is the whole answer:

| On the page | Read from |
|---|---|
| The countries, and their order | `listPacks()` — the directories of `packs/` |
| The region each country is listed under | `src/data/regions.json`, the UN M49 list; the region's name from `Intl.DisplayNames` |
| The name of every other country | `Intl.DisplayNames`, from the ISO code — never the geometry's own label, which ships abbreviated and sometimes outdated |
| The colouring of the world map | the packs, matched on the country code |
| Every counter on the home page | counted at build: packs, `packages/formats/`, `registerTool` in the MCP server, `expected-objects.json`, `*.test.ts` |
| The transcript on the home page | a pack's `golden/scenario.json` and `golden/vat_return.json` — see `src/demo.ts` |
| Everything on a country page | `describePack()`, the same object `ekwo pack describe --json` prints |
| The country's name in other languages | `packs/<cc>/i18n/` |
| The documentation, the manifesto among it | the Markdown files `src/data/docs.ts` lists, and one README per directory of `packages/formats/` |
| The timeline, `/changes/` and its head on the home page | `CHANGELOG.md` and `describePack()`, dated by git where the history is whole — see [Latest changes](#latest-changes-the-timeline) |
| The sentence on the home page | the first line of `README.md`, under its title |
| The command to install | the `name` of `packages/cli/package.json` |
| Every link to GitHub or npm | the `repository` of that same manifest |
| Licence in the footer | its `license` |

So a pack added to `packs/` gets a page, a row in the menu and a column in
every comparison with nothing here edited. That is not a convention — it is
what `tests/site.test.ts` checks, along with the home page containing no
country code outside the menu the data generated.

Adding a row to a country page means adding it to `STATUS_ROWS` in
`src/pages/rows.tsx`, once. The country page prints those rows in one column
and `/compare/` prints them in two, so they cannot come to disagree.

## Comparing two countries

The first version gave every unordered pair its own page, `/compare/<a>-<b>/`,
under a matrix of links. That is n(n-1)/2 pages: 15 at six countries, 1,225 at
fifty, 19,900 at two hundred, and a matrix of n² cells to reach them.

It is **one page** now. `/compare/` carries every country's column once, and
two native `<select>`s choose the two shown. A `<select>` marks its chosen
`<option>` as `:checked`, and `:has()` lets the table ask which: two CSS rules
per pack, generated with the columns (`compareRules()` in
`src/pages/Compare.tsx`), show a cell when its country is picked and place it
first or second with `order`. No script is involved in choosing.

Why this and not the alternatives:

- **A radio per country** does the same with `:has()`, and at two hundred is a
  wall of four hundred buttons. A select groups the countries by region
  (`<optgroup>`), answers to typing the first letters of a name, and is drawn
  natively on a phone.
- **A page per country**, `/compare/<cc>/`, listing the others would still
  need every other column on each page to compare without scripting: n pages
  of n columns, which is the quadratic cost again, in bytes instead of files.

Without `:has()` (browsers older than 2023) nothing is hidden: every column is
listed one under the other, each under its country's name, with a sentence
saying why. The inline script only adds what a static page cannot: it sets
the pickers from `?a=` / `?b=` (the link of a country page passes `?a=`) and
from `?pair=`, and writes the choice back to the address so it can be sent.

The weight, measured by `tests/scale.test.ts` on made-up packs (the body of
the page, before the shared template):

| Countries | Pages built | `/compare/` | `/countries/` |
|---|---|---|---|
| 6 (today) | 47 (62 before) | 49 KB, 7 KB gzipped | 14 KB |
| 50 | 91 (1,316 before) | 296 KB | 38 KB |
| 200 | 241 (20,141 before) | 1.1 MB | 113 KB |

About 5.6 KB per country before compression, and roughly one after: the
made-up packs are copies and compress better than real ones would, so the
gzipped figure at two hundred is an estimate of 100–200 KB, not a measure.
Pages and weight both grow by one column per country.

The table was measured before every country got a second page, the one that
sets it up (`/countries/<cc>/set-up/`, see below). That adds one page of about
the same size per country — 50 more at fifty, 200 more at two hundred — and
nothing per pair.

## Two hundred countries in a list

Every list of countries is grouped by the region the United Nations places
the country in (`regionsOf()` in `src/data.ts`, drawing on
`src/data/regions.json`), in two shapes from `src/pages/Regions.tsx`:
`RegionList` — the menu of `/countries/`, with a jump link per region and a
field that narrows it — and `RegionSummary`, one line of linked names per
region, under the map and on `/os/`. The field is the same one the
documentation uses (`Filter` in `src/pages/ui.tsx`): hidden until the inline
script can make it work, with the browser's own find doing the job without it.
The map colours the packs it has a shape for; the count beside it and the list
under it are the packs', so a country too small to draw at 1:110m is still
counted and named.

## What is shown, and what is claimed

Two files carry the claims the home page makes, and both are checked; a third,
`src/data/multicountry.ts`, carries those of `/multi-country/` under the same
rule — every `shipped` line has a path that must exist, and a gap is said as
`planned` only where the repository says it is coming, `not yet` otherwise.

`src/data/capabilities.ts` is the grid and the automation tiles. Every entry
carries `proof`: a path in this repository that is the reason the tile says
what it says, and `tests/site.test.ts` fails if the path does not exist. A tile
is `shipped` only where a function, a module, a brick or a command exists
today; everything else is `planned`, and anything that is neither is absent.

`src/data/ecosystem.ts` is the two rows of names: the models under the
buttons of the hero, in the faint ink and nowhere else on the page, and what
Ekwo is built on further down. A model is listed only where
its vendor documents that the product can connect to Model Context Protocol
servers, and the page that says so is kept in the entry rather than in a commit
message, so the next person can recheck it. Two candidates were asked for and
left out for failing that test; what they document instead is written down in
the same file. Nobody is featured: alphabetical order, one size, one weight.

## Setting Ekwo up: the button and the form

Every country page carries one strong button, **Set up Ekwo for <country>**,
under the card at its head and on a band at its foot, the name read from the
pack. It leads to `/countries/<cc>/set-up/`, where two ways in sit side by side
(`src/pages/SetUp.tsx`):

- **Run it yourself** — the installer's command with the country already on
  it, `npx ekwo-os init --country <CC>`. `--country` is the installer's own flag
  (`INIT_FLAGS` in `packages/cli/src/commands/init.ts`, which a test reads) and
  takes the code the pack declares; the installer asks for the rest. It links
  to `/docs/install/`, the installation guide rendered from the command line's
  README.
- **Get started with us** — a form. `/signup/` is the same page where no
  country is known yet — linked from the header of every page and from the
  home page — and there the country is a `<select>` of the packs, by region,
  with an option for a country no pack covers.

The form needs no script and no server of ours. It is a plain HTML form that
**Netlify Forms** reads when the site is deployed: `data-netlify="true"`, the
name `signup`, a trap for robots named in `data-netlify-honeypot`, and a
`POST` to `/thanks/`, a page like any other. Because the pages are prerendered,
the host finds the form in the files it publishes; nothing is declared
elsewhere. Every variant carries the same fields under the same names, because
the host keeps one list of fields per form name:

| Field | |
|---|---|
| `email` | required |
| `company` | optional |
| `country` | the code of the page's pack, hidden; chosen on `/signup/` (`other` for a country no pack covers) |
| `profile` | `company`, `firm` or `partner` |
| `message` | optional |
| `consent` | required, `yes` |
| `page` | the page it was sent from |

What it collects and why is said under it, in `strings.setup.privacy`.
`/thanks/` carries `noindex` and is left out of the sitemap.

Two things are the host's and not this repository's, and are set once in the
Netlify dashboard: **form detection** has to be on for the site (Forms), and
the **notification** that sends each submission to an address is configured
there too. Until detection is on, nothing sent is recorded.

## A country with no pack

Every country of the UN list that no pack claims has a page at
`/countries/<cc>/` too (`src/pages/Waiting.tsx`): "Ekwo in <country> — not
yet.", its name from `Intl.DisplayNames`. Each grey shape of the map leads
there, and so does the folded list under the menu of `/countries/`. One light
page per country, so the world is a fixed number of pages; a pack landing in
`packs/` takes its code's place with nothing here edited.

- **Where it stands is read.** `in progress` where a manifest shared by several
  packs — any `packs/<dir>/manifest.json` with `members` (`familiesOf()` in
  `src/data.ts`) — lists the country and it has no folder yet; `not started`
  otherwise. No date, in either case.
- **I need it** is the `signup` form of every other page, the country's code in
  its hidden `country` field and the page's address in `page`: no new form and
  no new field, so the list the host already detected is unchanged, and a
  request for a country nobody has written is counted like any other.
- **Contribute the pack** is the three steps of `CONTRIBUTING.md`, linked to
  *Adding a country in a day* and to what the `community` status means.
- **Become a partner** writes to contact@ekwo.ai until partners have a
  directory of their own.

The pages carry `noindex` and are left out of the sitemap: two hundred pages
that differ by a name would read to a search engine as exactly that.

## Latest changes: the timeline

`/changes/` lists everything that changed, newest first and grouped by day;
the home page shows the latest eight, and every page links to it from its
foot. Nothing in it is written by hand (`src/changes.ts`):

| Item | Read from | Dated by | Links to |
|---|---|---|---|
| **release** — "Ekwo OS 0.4.1 is released" | each `## [x.y.z] — <date>` of `CHANGELOG.md` | the heading | that heading of the changelog on GitHub |
| **feature** / **fix** | each entry of a release — a bullet opening on a sentence in bold, the sentence being what is shown; `Fixed` and `Security` are fixes | the release | the release's heading |
| the same, under `[Unreleased]` | the same | the day git says the entry's first line was last committed (`git blame`), and marked *not released yet* | `#unreleased` |
| **country** — "New country: …" or "… pack 1.2.0" | `describePack()`: a pack at `0.1.0` or `1.0.0` is a new country, any other version is that country's pack at it | the pack's `released_at` | the country page |
| **country** — "New country: …", for a pack past its first version | the first commit that added `packs/<cc>/pack.json` | that commit | the country page |

So a pack merged into `packs/` is on the timeline, the map and the counters of
the next build with nothing here edited.

**Git is used only where the history is whole.** `git rev-parse
--is-shallow-repository` is asked first: a shallow clone would date every line
by the one commit it has, which is a wrong date rather than none. Without the
history — a shallow clone, a tarball, no `git` — the build still passes and
the timeline is still correct, only thinner: unreleased entries are shown
first, as *not released yet* with no day, and the arrival of a country already
past its first version is not shown. How deep the host clones is the host's
to decide, and the build does not depend on it: a shallow clone is what
degrades, and nothing fails.

## Third-party material

Everything here is redistributable, and its licence ships with it.

- **Fraunces** and **Inter**, in `src/fonts/`, under the SIL Open Font Licence.
  The licence text of each sits beside it. They are self-hosted rather than
  fetched, so no font host learns who read the page.
- **Brand marks**, in `src/icons/`, from [simple-icons](https://simpleicons.org),
  which is CC0. They are rendered monochrome in `currentColor`. Where
  simple-icons carries no mark for a brand, the name is set as a word rather
  than redrawn or taken from a vendor's site. Names and logos belong to their
  owners; Ekwo is not affiliated with any of them.
- **The regions**, in `src/data/regions.json`, from the M49 list of the
  [UN Statistics Division](https://unstats.un.org/unsd/methodology/m49/overview/)
  (Standard country or area codes for statistical use), copied once. Only the
  code of each country's region is kept; its name comes from the platform. A
  country the list does not place is grouped apart rather than guessed.
- **The world map**, in `src/data/world.json`, derived from
  [Natural Earth](https://www.naturalearthdata.com), which is in the public
  domain. It was projected and simplified once, at 1:110m, with the far south
  cropped and Antarctica dropped: neither carries a country anybody keeps books
  in, and both cost a third of the height.

## Adding a language

The site is published in English. Nothing is translated yet, and the tree is
laid out so that translating it is one file rather than a refactor.

1. Copy `src/strings/en.ts` to `src/strings/<lang>.ts`, translate the values,
   and change `lang` and `languageName`.
2. Add it to `LANGUAGES` in `src/strings/index.ts`. **The first entry is the
   source**: it is published at the root, and every other language is published
   under its own prefix with exactly the same tree beneath it.

That is the whole of it. `<html lang>` is the rendered language's own tag, and
no language is written into the code anywhere else.

Two things are deliberately outside that file. The **packs** carry their own
translations, in `packs/<cc>/i18n/`: the name of a country, of a chart of
accounts, of a tax, of a box of a declaration. Those belong to the country and
are versioned with it. And the **documentation** — the manifesto
among it — is documents rather than an interface: each article is rendered from
a Markdown file of the repository, and a translation of one would be a file
beside it. Only the titles, the topics and the notes are in the strings.

**A language is published complete or it is not published.** The shape is a
type, so a missing key does not compile; a test compares the key set of every
language against the source for the case where a key is added to the source
after a translation was written. A half-translated page is worse than an
English one, because a reader cannot tell which half they are getting.

This is also why the country pages live at `/countries/<cc>/` and not at the
root: a two-letter segment there cannot be both a country and a language, and
most of the countries a European ledger meets first have a code that is also a
language's.

## Design

The brand kit is not settled, so the reader picks. **Two palettes — `cobalt`
and `gold` — crossed with two themes, `day` and `night`**: four complete sets of
the same token roles, carried on `data-palette` and `data-theme`, chosen from
two buttons in the header and remembered. Each of the four is drawn rather than
derived; the night of a palette is not its day inverted.

`src/styles.css` is the only file with a colour in it. The roles are the ones
the rest of this workspace uses: `bg` is the ground and is never pure white,
`paper` is what a card is made of, `track` is a groove in it, `ink` /
`ink-soft` / `ink-faint` are three weights of text, `line` is every border,
`brand` and its relatives are the accent, `band` is the full-width dark
section. One shadow, long and diffuse. Two typefaces, a serif for headings and
a sans for everything else.

Two rules about the accent, and both are contrast. `brand` is for fills, marks
and borders; text in the accent — every link — uses `brand-deep`, which is the
darker tone by day and the lighter one by night. The one solid button uses
`brand-solid` with `brand-on`, a pair chosen per combination, because white on
the gold of day is 3.45:1.

**Every text token against every ground it is used on passes AA in all four
combinations.** Two values are a hair darker than the palette they came from,
both `ink-faint` by day: the originals sit at 2.9:1 and 3.8:1 against paper,
and this site uses that weight for row hints and for every "not yet", which is
content.

A few lines run in the `<head>` to stamp the stored choices before the first
paint, which is the only way to avoid a flash of the other theme. That is also
what reveals the two buttons — they ship hidden, because a control that cannot
work is worse than no control — and with scripting off the media query follows
the reader's system through the same tokens.

Icons are `lucide-react` and never an emoji, which renders differently on every
machine and is read aloud by a screen reader as whatever its name happens to be.

## Not in this slice

Deliberately absent, and each of these is work of its own:

- **Any backend.** The site is files on a disk; the one form is read by the
  host (see [Setting Ekwo up](#setting-ekwo-up-the-button-and-the-form)).
- **Instance registration against `api.ekwo.ai`.** Nothing here calls anything.
- **Pricing, an account, and anything the hosted edition charges.** The open
  core boundary is stated per country, from `ee/README.md`, and the home page
  says the hosted edition exists and leads to `/signup/`. No price, no
  account.
- **A blog.** The documentation is rendered, at `/docs/`, from the repository's own
  Markdown; a link it carries to anything that is not an article goes to GitHub.
- **French and Dutch translations of the site's own text.** A country's *name*
  is translated, because the pack translates it. The prose is English only.
- **A social card.** Pages carry a title and a description for a link preview,
  and no image yet.

## Where it is served from

[`netlify.toml`](../../netlify.toml), at the root of the repository, is how the
site is built and published: one command, `npm run build --workspace
@ekwo-ai/site`, run from the root because the pages are read from the packs and
from `MANIFESTO.md`.

**The address is the build's to say, never the code's.** `SITE_URL` — an origin
such as `https://example.org` — makes every page name its canonical address and
its `og:url`, and writes `sitemap.xml`. Without it no page claims an address,
which is what a fork, a local build and a deploy preview want. The published
site sets it in `netlify.toml`, for the production context only.

Two files in `public/` are read by the host and copied as they are:

- **`_redirects`** has two rules. The first sends the old address of a pair,
  `/compare/<a>-<b>/`, to `/compare/?pair=<a>-<b>` for good (301): one rule with
  a placeholder, not a line per pair. The second is the last one. The domain
  of this site used to serve the hosted application, and people hold links to it — a document they were sent,
  a client page, a timesheet. None of those is a page here, so an address the
  site does not have is handed to the application with its path and query
  kept, instead of being answered with a 404. The rule is not forced, so it
  never shadows a page that exists; a test keeps it that way.
- **`_headers`** sets the security headers and lets the fingerprinted files
  under `/assets/` be cached for good.

