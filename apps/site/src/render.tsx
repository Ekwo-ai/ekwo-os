/**
 * Every page of the site, as strings, without touching the disk.
 *
 * `prerender.ts` writes what this returns and `tests/site.test.ts` reads it.
 * Both get the same pages from the same call, so the test is a test of what
 * ships rather than of a second rendering written to be testable.
 *
 * The list of pages is derived, never enumerated: for each language, one page
 * per pack of `listPacks()`, one per article of the documentation, plus the
 * home page, the core, the index of the documentation, the index of countries
 * and the comparison. Adding a country adds one page and a column of the
 * comparison — never a page per pair — and adding a language adds the whole
 * tree again under its prefix, with nothing here edited.
 *
 * **Country pages live under `/countries/<cc>/`.** A two-letter segment at the
 * root cannot be both a country and a language, and a site with this ambition
 * will be translated: several of the countries a European ledger meets first
 * have a code that is also the code of a language, and that one segment would
 * have to mean the country and the translation at the same time. The prefixes
 * are kept free now, while moving a page costs nothing.
 */

import { renderToStaticMarkup } from 'react-dom/server';
import type { ReactNode } from 'react';
import type { SiteData } from './data.js';
import { LANGUAGES, fill, prefixOf, type Strings } from './strings/index.js';
import { Landing } from './pages/Landing.js';
import { Os } from './pages/Os.js';
import { Countries } from './pages/Countries.js';
import { DocsArticle, DocsIndex, descriptionOf, titleOf } from './pages/Docs.js';
import { Country } from './pages/Country.js';
import { Compare, PICKERS } from './pages/Compare.js';

export interface RenderedPage {
  /** Where the file goes, relative to the output directory. */
  file: string;
  /** The path a link points at — what `file` is served as. */
  url: string;
  /** BCP 47 of the language this page is written in. */
  lang: string;
  title: string;
  description: string;
  /** The contents of `<body>`, complete and final. */
  body: string;
}

/** One page, rendered. `url` is derived from `file` so the two cannot disagree. */
function page(
  path: string,
  lang: string,
  title: string,
  description: string,
  element: ReactNode,
): RenderedPage {
  return {
    file: path === '' ? 'index.html' : `${path}index.html`,
    url: `/${path}`,
    lang,
    title,
    description,
    body: renderToStaticMarkup(element),
  };
}

/** Every page of the site, in the order a reader would meet them. */
export function renderPages(data: SiteData): RenderedPage[] {
  return LANGUAGES.flatMap((strings) => pagesOf(data, strings));
}

/** The whole tree, in one language, under that language's prefix. */
function pagesOf(data: SiteData, strings: Strings): RenderedPage[] {
  const at = prefixOf(strings);
  const lang = strings.lang;
  const s = strings;

  const pages: RenderedPage[] = [
    page(at, lang, s.home.title, s.home.description, <Landing data={data} strings={s} />),
    page(`${at}os/`, lang, s.os.title, s.os.description, <Os data={data} strings={s} />),
    page(`${at}docs/`, lang, s.docs.title, s.docs.description, <DocsIndex data={data} strings={s} />),
    // Every article, the manifesto among them: it is published where it always
    // was, and the address comes with the article rather than being made here.
    ...data.docs.map((article) =>
      page(
        `${at}${article.url.slice(1)}`,
        lang,
        fill(s.docs.articleTitle, { article: titleOf(article, s) }),
        descriptionOf(article, s),
        <DocsArticle article={article} data={data} strings={s} />,
      ),
    ),
    page(
      `${at}countries/`,
      lang,
      s.countries.indexTitle,
      s.countries.indexDescription,
      <Countries data={data} strings={s} />,
    ),
  ];

  for (const country of data.countries) {
    pages.push(
      page(
        `${at}countries/${country.slug}/`,
        lang,
        fill(s.country.title, { country: country.name }),
        fill(s.country.description, { country: country.name }),
        <Country country={country} data={data} strings={s} />,
      ),
    );
  }

  pages.push(
    page(
      `${at}compare/`,
      lang,
      s.compare.title,
      s.compare.description,
      <Compare data={data} strings={s} />,
    ),
  );

  return pages;
}

/**
 * The only blocking script on the site, and the whole of what it does.
 *
 * It reads the two stored choices — the colour and the time of day — and stamps
 * them on the root element before the first paint, which is the only way to
 * avoid the flash of the other theme. It runs in the `<head>`, before the
 * stylesheet, and it is a few hundred bytes.
 *
 * It stamps `data-theme` **only for a reader who has chosen one**. Day and
 * night are otherwise the reader's system, live: the stylesheet answers
 * `prefers-color-scheme` on its own, so a machine that turns dark at dusk turns
 * this page with it, and a machine with scripting off gets the same thing.
 * Stamping a value here would freeze the page on whatever was true at load.
 *
 * `data-js` is what reveals the two buttons, since `data-theme` no longer
 * arrives by default: they ship hidden, because a control that cannot work is
 * worse than no control.
 */
const THEME_SCRIPT = `
(function () {
  try {
    var d = document.documentElement;
    d.setAttribute('data-js', '');
    var p = localStorage.getItem('ekwo.palette');
    var t = localStorage.getItem('ekwo.theme');
    d.setAttribute('data-palette', p === 'gold' ? 'gold' : 'cobalt');
    if (t === 'night' || t === 'day') d.setAttribute('data-theme', t);
  } catch (e) {}
})();
`.trim();

/**
 * The deferred half: what the two buttons do, the buttons that copy a
 * command or a block of code, the search field of a list — the documentation,
 * the countries — which hides the entries that do not carry every word typed,
 * and the two pickers of the comparison, which it sets from the address and
 * writes back into it. None of it is needed to read anything, so all of it
 * waits until the end of the body.
 */
const ENHANCEMENT = `
(function () {
  var d = document.documentElement;
  var dark = matchMedia('(prefers-color-scheme: dark)');
  var save = function (k, v) { try { localStorage.setItem(k, v); } catch (e) {} };
  /* What the page is actually drawn in: the stamped choice, or the system. */
  var isNight = function () {
    var t = d.getAttribute('data-theme');
    return t === 'night' || (t === null && dark.matches);
  };
  var paint = function () {
    var night = isNight();
    var gold = d.getAttribute('data-palette') === 'gold';
    for (const b of document.querySelectorAll('[data-theme-toggle]')) {
      b.setAttribute('aria-pressed', String(night));
      b.querySelector('[data-theme-day]').hidden = night;
      b.querySelector('[data-theme-night]').hidden = !night;
    }
    for (const b of document.querySelectorAll('[data-palette-toggle]'))
      b.setAttribute('aria-pressed', String(gold));
  };
  /* Still following the system: repaint the sun and the moon when it turns. */
  dark.addEventListener('change', paint);
  for (const b of document.querySelectorAll('[data-theme-toggle]'))
    b.addEventListener('click', function () {
      var next = isNight() ? 'day' : 'night';
      d.setAttribute('data-theme', next); save('ekwo.theme', next); paint();
    });
  for (const b of document.querySelectorAll('[data-palette-toggle]'))
    b.addEventListener('click', function () {
      var next = d.getAttribute('data-palette') === 'gold' ? 'cobalt' : 'gold';
      d.setAttribute('data-palette', next); save('ekwo.palette', next); paint();
    });
  paint();
  for (const b of document.querySelectorAll('button[data-copy], button[data-copy-code]')) {
    if (!navigator.clipboard) continue;
    b.hidden = false;
    b.addEventListener('click', async function () {
      var text = b.dataset.copy;
      if (text === undefined) {
        var pre = b.closest('[data-code]').querySelector('pre');
        text = pre.textContent.replace(/\\n$/, '');
      }
      try { await navigator.clipboard.writeText(text); } catch (e) { return; }
      var idle = b.querySelector('[data-copy-idle]'), done = b.querySelector('[data-copy-done]');
      idle.hidden = true; done.hidden = false;
      setTimeout(function () { idle.hidden = false; done.hidden = true; }, 1400);
    });
  }
  for (const scope of document.querySelectorAll('[data-filter-scope]')) {
    var box = scope.querySelector('[data-filter]');
    if (!box) continue;
    box.hidden = false;
    let input = box.querySelector('input'), empty = scope.querySelector('[data-filter-empty]');
    input.addEventListener('input', function () {
      var words = input.value.toLowerCase().split(/\\s+/).filter(Boolean);
      var items = scope.querySelectorAll('[data-filter-item]');
      for (const item of items) {
        var text = item.getAttribute('data-search') || '';
        item.hidden = !words.every(function (w) { return text.indexOf(w) !== -1; });
      }
      for (const item of items) {
        if (item.hidden) continue;
        for (var up = item.parentElement.closest('[data-filter-item]'); up; up = up.parentElement.closest('[data-filter-item]')) up.hidden = false;
      }
      var any = false;
      for (const group of scope.querySelectorAll('[data-filter-group]')) {
        group.hidden = !group.querySelector('[data-filter-item]:not([hidden])');
        any = any || !group.hidden;
      }
      if (empty) empty.hidden = any;
    });
  }
  /* The comparison: ?a=&b=, or ?pair=a-b from an old pair address. */
  var a = document.getElementById('${PICKERS[0]}'), b = document.getElementById('${PICKERS[1]}');
  if (a && b) {
    var q = new URLSearchParams(location.search), pair = (q.get('pair') || '').split('-');
    var set = function (select, value) {
      for (const option of select.options) if (option.value === value) { select.value = value; return; }
    };
    set(a, q.get('a') || pair[0]); set(b, q.get('b') || pair[1]);
    if (a.value === b.value)
      for (const option of b.options) if (option.value !== a.value) { b.value = option.value; break; }
    var keep = function () {
      history.replaceState(null, '', location.pathname + '?a=' + a.value + '&b=' + b.value + location.hash);
    };
    a.addEventListener('change', keep); b.addEventListener('change', keep);
  }
})();
`.trim();

/** The characters that must not reach an attribute or a text node as themselves. */
function escapeHtml(text: string): string {
  return text
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

/**
 * One page, put into the template Vite wrote.
 *
 * The template carries the fingerprinted stylesheet, so the head written here
 * is the title, the description, the sober Open Graph pair and the script that
 * stamps the theme.
 *
 * `origin` is where the site is served from — `https://example.org`, no
 * trailing slash — and it is the build that says so (`SITE_URL`), never this
 * file: a fork, a preview and the published site are three addresses. With one,
 * every page names its canonical address and its `og:url`. Without one it names
 * neither, because a made-up address is worse than none.
 */
export function document(template: string, rendered: RenderedPage, origin?: string): string {
  const address = origin === undefined ? [] : [
    `<link rel="canonical" href="${escapeHtml(origin + rendered.url)}" />`,
    `<meta property="og:url" content="${escapeHtml(origin + rendered.url)}" />`,
  ];
  const head = [
    `<title>${escapeHtml(rendered.title)}</title>`,
    `<meta name="description" content="${escapeHtml(rendered.description)}" />`,
    ...address,
    `<meta property="og:type" content="website" />`,
    `<meta property="og:site_name" content="Ekwo" />`,
    `<meta property="og:title" content="${escapeHtml(rendered.title)}" />`,
    `<meta property="og:description" content="${escapeHtml(rendered.description)}" />`,
    `<script>${THEME_SCRIPT}</script>`,
  ].join('\n    ');

  const body = `${rendered.body}<script>${ENHANCEMENT}</script>`;
  const filled = fill2(fill2(template, '<!--head-->', head), '<!--body-->', body);
  // The language of the page is the language it was rendered in.
  return filled.replace('<html lang="en">', `<html lang="${rendered.lang}">`);
}

/**
 * Put `what` where `slot` is, exactly once, or say which slot went missing.
 *
 * The replacement goes through a function because `String.replace` reads `$&`
 * and `$'` in the *replacement* as instructions rather than as text, and the
 * replacement here is a whole page — a legal reference of a country whose
 * currency is the dollar is where that would first be a sentence rewriting
 * itself. And a template missing one of its slots would otherwise have filled
 * the other and returned a page with no head or no body.
 */
function fill2(template: string, slot: string, what: string): string {
  if (!template.includes(slot)) {
    throw new Error(`the template carries no ${slot}: apps/site/index.html has lost a slot`);
  }
  return template.replace(slot, () => what);
}

/**
 * The address the build was told the site is served from, or nothing.
 *
 * Accepts what people type — a trailing slash, surrounding space — and refuses
 * what is not an absolute http(s) address rather than writing it into every
 * page.
 */
export function siteOrigin(value: string | undefined): string | undefined {
  const trimmed = value?.trim().replace(/\/+$/, '');
  if (trimmed === undefined || trimmed === '') return undefined;
  if (!/^https?:\/\/[^/\s]+$/.test(trimmed)) {
    throw new Error(`SITE_URL must be an origin such as https://example.org, got "${value}"`);
  }
  return trimmed;
}

/** Every page there is, for a crawler. Only written when the site has an address. */
export function sitemap(pages: readonly RenderedPage[], origin: string): string {
  const urls = pages
    .map((page) => `  <url><loc>${escapeHtml(origin + page.url)}</loc></url>`)
    .join('\n');
  return `<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n${urls}\n</urlset>\n`;
}

/** Everything may be read; the sitemap is named when there is one. */
export function robots(origin: string | undefined): string {
  const lines = ['User-agent: *', 'Allow: /'];
  if (origin !== undefined) lines.push('', `Sitemap: ${origin}/sitemap.xml`);
  return `${lines.join('\n')}\n`;
}

