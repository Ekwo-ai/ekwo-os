# `apps/site` — the public site

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
two countries, which is why each pair has its own address rather than a
dropdown. One inline script exists, a few hundred bytes at the end of the body:
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
| The name of every other country | `Intl.DisplayNames`, from the ISO code — never the geometry's own label, which ships abbreviated and sometimes outdated |
| The colouring of the world map | the packs, matched on the country code |
| Every counter on the home page | counted at build: packs, `packages/formats/`, `registerTool` in the MCP server, `expected-objects.json`, `*.test.ts` |
| The transcript on the home page | a pack's `golden/scenario.json` and `golden/vat_return.json` — see `src/demo.ts` |
| Everything on a country page | `describePack()`, the same object `ekwo pack describe --json` prints |
| The country's name in other languages | `packs/<cc>/i18n/` |
| The documentation, the manifesto among it | the Markdown files `src/data/docs.ts` lists, and one README per directory of `packages/formats/` |
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

## What is shown, and what is claimed

Two files carry the claims the home page makes, and both are checked.

`src/data/capabilities.ts` is the grid and the automation tiles. Every entry
carries `proof`: a path in this repository that is the reason the tile says
what it says, and `tests/site.test.ts` fails if the path does not exist. A tile
is `shipped` only where a function, a module, a brick or a command exists
today; everything else is `planned`, and anything that is neither is absent.

`src/data/ecosystem.ts` is the two rows of names. A model is listed only where
its vendor documents that the product can connect to Model Context Protocol
servers, and the page that says so is kept in the entry rather than in a commit
message, so the next person can recheck it. Two candidates were asked for and
left out for failing that test; what they document instead is written down in
the same file. Nobody is featured: alphabetical order, one size, one weight.

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

- **The waiting list form, and any backend.** The site is files on a disk.
- **Instance registration against `api.ekwo.ai`.** Nothing here calls anything.
- **Pricing, a sign-up, and anything the hosted edition charges.** The open
  core boundary is stated per country, from `ee/README.md`, and the home page
  says the hosted edition exists and offers an address to write to. No price,
  no form, no account.
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

- **`_redirects`** has one rule. The domain of this site used to serve the
  hosted application, and people hold links to it — a document they were sent,
  a client page, a timesheet. None of those is a page here, so an address the
  site does not have is handed to the application with its path and query
  kept, instead of being answered with a 404. The rule is not forced, so it
  never shadows a page that exists; a test keeps it that way.
- **`_headers`** sets the security headers and lets the fingerprinted files
  under `/assets/` be cached for good.

