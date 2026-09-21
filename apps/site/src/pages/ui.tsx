/**
 * The small pieces every page is built from.
 *
 * Nothing here knows about a country. `NotYet` matters most: a pack that does
 * not declare a deadline, a country with no e-invoicing obligation and a bank
 * format nobody reads are the ordinary state of this project, and each is shown
 * rather than left out. A page that printed only what works would be a
 * brochure, and a reader deciding whether to install this needs the gaps more
 * than the wins.
 */

import type { ReactNode } from 'react';
import type { Repository } from '../data.js';
import type { Strings } from '../strings/index.js';
import { Glyph } from './icons.js';
import { Logo } from './Logo.js';

/**
 * How wide a page is. `reading` is the measure prose is set at, about 65
 * characters; `page` is what a table of a dozen rows needs. The masthead and
 * the footer take it too, so the rule above the navigation starts where the
 * text does.
 */
export type Measure = 'reading' | 'page';

export function measureClass(measure: Measure): string {
  return measure === 'reading' ? 'max-w-reading' : 'max-w-page';
}

/** An answer the project does not have yet, said in words rather than omitted. */
export function NotYet({ children }: { children?: ReactNode }): ReactNode {
  return (
    <span className="inline-flex items-center rounded-pill bg-brand-fill px-2 py-0.5 text-[0.8125rem] leading-snug text-ink-soft">
      {children ?? 'not yet'}
    </span>
  );
}

/** A short piece of pack data: an account code, a format, a profile. */
export function Mono({ children }: { children: ReactNode }): ReactNode {
  return <code className="font-mono text-[0.9em] text-ink">{children}</code>;
}

/**
 * A pack's certification, as a pill rather than a grey word.
 *
 * The three words are the pack's own — `community`, `maintained`, `reviewed` —
 * and none of them is a grade this site awards. They are drawn the same as one
 * another on purpose: a `reviewed` pack has a named professional behind it and
 * says so in words beside this, which is stronger than a colour.
 */
export function StatusPill({ status }: { status: string }): ReactNode {
  return (
    <span className="inline-flex items-center rounded-pill bg-brand-fill px-2.5 py-0.5 text-[0.8125rem] text-ink-soft">
      {status}
    </span>
  );
}

/**
 * A field that narrows the list around it, hidden until the inline script can
 * make it work.
 *
 * It sits inside a `data-filter-scope`; every entry of the list is a
 * `data-filter-item` carrying its words in `data-search`, lowercase, and the
 * script hides the entries that do not carry every word typed and the
 * `data-filter-group` left with none. It costs no request, and without
 * scripting there is no field that does nothing: the whole list is there to
 * read, and the browser's own find searches it.
 */
export function Filter({ label }: { label: string }): ReactNode {
  return (
    <label data-filter hidden className="relative block">
      <span className="sr-only">{label}</span>
      <span className="pointer-events-none absolute top-1/2 left-3 -translate-y-1/2 text-ink-faint">
        <Glyph name="search" className="h-4 w-4" />
      </span>
      <input
        type="search"
        placeholder={label}
        autoComplete="off"
        className="w-full rounded-sm border border-line bg-paper py-2 pr-3 pl-9 text-sm text-ink placeholder:text-ink-faint focus:border-brand-soft focus:outline-none"
      />
    </label>
  );
}

/** A label above a value. */
export function Field({ label, children }: { label: string; children: ReactNode }): ReactNode {
  return (
    <div>
      <dt className="text-[0.6875rem] uppercase tracking-[0.12em] text-ink-faint">{label}</dt>
      <dd className="mt-1 text-ink">{children}</dd>
    </div>
  );
}

/** A link that leaves the site. */
export function Out({ href, children, className }: { href: string; children: ReactNode; className?: string }): ReactNode {
  return (
    <a href={href} rel="noreferrer" className={className}>
      {children}
    </a>
  );
}

/** The small capitals that head a section. */
export function Eyebrow({ children }: { children: ReactNode }): ReactNode {
  return (
    <p className="text-[0.6875rem] uppercase tracking-[0.16em] text-ink-faint">{children}</p>
  );
}

/** A card: paper, one hairline, one long shadow. */
export function Card({ children, className }: { children: ReactNode; className?: string }): ReactNode {
  return (
    <div
      className={`rounded-lg border border-line bg-paper shadow-lift ${className ?? ''}`}
    >
      {children}
    </div>
  );
}

/** The one strong button of a page. */
export function Action({ href, children }: { href: string; children: ReactNode }): ReactNode {
  return (
    <a
      href={href}
      className="inline-flex items-center gap-2 rounded-pill bg-brand-solid px-5 py-2.5 font-medium text-brand-on no-underline transition-colors duration-150 hover:bg-brand-muted"
    >
      {children}
    </a>
  );
}

/** The quiet one beside it. */
export function Secondary({ href, children }: { href: string; children: ReactNode }): ReactNode {
  return (
    <a
      href={href}
      className="inline-flex items-center gap-2 rounded-pill border border-line bg-paper px-5 py-2.5 font-medium text-ink no-underline transition-colors duration-150 hover:border-brand hover:text-brand-deep"
    >
      {children}
    </a>
  );
}

/**
 * Addresses this site links to and does not build: the host hands them to the
 * hosted application (`public/_redirects`). A test checks that none of them is
 * a page here, and that the rule which hands them over is still in place.
 */
export const HANDED_TO_THE_APPLICATION = { login: '/login' } as const;

/**
 * Where the two marks beside "Log in" go.
 *
 * GitHub is the repository — read from the command line's manifest, like every
 * other link to it. Supabase is the article that installs Ekwo on a Supabase
 * project: somebody who clicks the mark wants Ekwo on it, and supabase.com
 * would leave them on somebody else's home page. Supabase has no button that
 * creates a project with a repository's migrations in it yet; when it does, or
 * when Ekwo is listed in its directory, this is the one line that changes.
 */
export const SUPABASE_HREF = '/docs/install/';

/** The part of the site a page belongs to, so its tab reads as the current one. */
export type SiteSection = 'os' | 'countries' | 'docs';

/**
 * The head of every page.
 *
 * Sticky and translucent, so the page moves under it rather than away from it.
 * `Ekwo` is the product; `Open source` is the core somebody installs; `Docs` is
 * the roof of everything written about it, the manifesto included. The two
 * marks say where the code is and what it runs on.
 */
export function Masthead({
  measure,
  strings,
  data,
  current,
}: {
  measure: Measure;
  strings: Strings;
  /** Where the repository is, and the brand marks by basename. */
  data: { repository: Repository; icons: Record<string, string> };
  current?: SiteSection;
}): ReactNode {
  const nav = strings.nav;
  const icons = data.icons;
  const tab = (section: SiteSection, href: string, label: string): ReactNode => (
    <a
      href={href}
      aria-current={current === section ? 'page' : undefined}
      className={`no-underline hover:text-brand-deep ${current === section ? 'text-ink' : 'text-ink-soft'}`}
    >
      {label}
    </a>
  );
  const mark = (href: string, icon: string, label: string, withWord: boolean): ReactNode => {
    const path = icons[icon];
    return (
      <Out
        href={href}
        className="inline-flex items-center gap-2.5 text-ink-soft no-underline hover:text-brand-deep"
      >
        {path === undefined ? null : (
          <svg viewBox="0 0 24 24" className="h-[18px] w-[18px] fill-current" aria-hidden>
            <path d={path} />
          </svg>
        )}
        <span className={withWord ? '' : 'sr-only'}>{label}</span>
      </Out>
    );
  };
  const links = (wide: boolean): ReactNode => (
    <>
      {tab('os', '/os/', nav.os)}
      {tab('countries', '/countries/', nav.countries)}
      {tab('docs', '/docs/', nav.docs)}
      {mark(data.repository.url, 'github', nav.github, !wide)}
      {mark(SUPABASE_HREF, 'supabase', nav.supabase, !wide)}
      <a href="/signup/" className="text-ink-soft no-underline hover:text-brand-deep">
        {nav.start}
      </a>
      {/*
        The way in for somebody who already keeps their books on the hosted
        edition. `/login` is not a page of this site: `public/_redirects` hands
        every address the site does not have to the application, so the
        application's address is written in that one file and nowhere else.
      */}
      <a
        href={HANDED_TO_THE_APPLICATION.login}
        rel="nofollow"
        className="rounded-pill border border-line bg-paper px-3.5 py-1.5 text-center font-medium text-ink no-underline transition-colors duration-150 hover:border-brand-soft hover:text-brand-deep"
      >
        {nav.login}
      </a>
    </>
  );

  return (
    <header className="sticky top-0 z-30 border-b border-line bg-bg/80 backdrop-blur-md">
      <nav
        aria-label={nav.label}
        className={`mx-auto flex ${measureClass(measure)} items-center gap-3 px-5 py-3 text-sm`}
      >
        <Logo />
        <span className="flex-1" />

        {/* Wide enough for the links: they sit in the bar, the marks as marks. */}
        <span className="hidden items-center gap-5 sm:flex">{links(true)}</span>

        {/*
          Narrow: the same links behind a disclosure, each mark with its name
          beside it. A `<details>` opens with no scripting at all, which is the
          whole reason for choosing it over a button that needs a listener —
          the header has to work before the one inline script runs, and on a
          page where it never does.
        */}
        <details className="group relative sm:hidden">
          <summary
            className="inline-flex h-[38px] w-[38px] list-none items-center justify-center rounded-sm border border-line bg-paper text-ink-soft transition-colors duration-150 hover:border-brand-soft hover:text-brand-deep"
            aria-label={nav.label}
          >
            <Glyph name="menu" className="h-[18px] w-[18px]" />
          </summary>
          <span className="absolute right-0 z-40 mt-2 flex w-56 flex-col gap-3 rounded border border-line bg-paper p-4 shadow-lift">
            {links(false)}
          </span>
        </details>

        <Controls strings={strings} />
      </nav>
    </header>
  );
}

/**
 * The two choices a reader gets: the colour, and the time of day.
 *
 * Both are square, both are 38px, and both are hidden until the inline script
 * has stamped `data-js` on the root — a control that cannot work is worse than
 * no control, and without scripting the page still follows
 * `prefers-color-scheme` through the same tokens.
 *
 * The first shows the accent as a dot, because the thing it changes is a
 * colour and a word for it would be a word to translate. The second shows the
 * sun or the moon, both drawn, with the one that is not current hidden.
 */
function Controls({ strings }: { strings: Strings }): ReactNode {
  const c = strings.controls;
  return (
    <span data-controls className="ml-1 items-center gap-2">
      <button
        type="button"
        data-palette-toggle
        aria-pressed="false"
        title={c.palette}
        className="inline-flex h-[38px] w-[38px] items-center justify-center rounded-sm border border-line bg-paper text-ink-soft transition-colors duration-150 hover:border-brand-soft hover:text-brand-deep"
      >
        <span className="h-[13px] w-[13px] rounded-pill bg-brand" aria-hidden />
        <span className="sr-only">{c.palette}</span>
      </button>
      <button
        type="button"
        data-theme-toggle
        aria-pressed="false"
        title={c.theme}
        className="inline-flex h-[38px] w-[38px] items-center justify-center rounded-sm border border-line bg-paper text-ink-soft transition-colors duration-150 hover:border-brand-soft hover:text-brand-deep"
      >
        <span data-theme-day aria-hidden>
          <Glyph name="sun" className="h-[18px] w-[18px]" />
        </span>
        <span data-theme-night hidden aria-hidden>
          <Glyph name="moon" className="h-[18px] w-[18px]" />
        </span>
        <span className="sr-only">{c.theme}</span>
      </button>
    </span>
  );
}

/**
 * The foot of every page: what this is licensed under, what it does not
 * promise, where to report something, and where the code and the package are.
 */
export function Footer({
  repository,
  measure,
  strings,
}: {
  repository: Repository;
  measure: Measure;
  strings: Strings;
}): ReactNode {
  const f = strings.footer;
  return (
    <footer className="mt-24 border-t border-line">
      <div
        className={`mx-auto ${measureClass(measure)} px-5 py-9`}
      >
        <Logo size={18} />
        <p className="mt-1 text-sm text-ink-faint">{f.tagline}</p>
        <nav
          aria-label={f.label}
          className="mt-5 flex flex-wrap items-center gap-x-6 gap-y-2 text-sm text-ink-faint"
        >
          <span>{repository.license}</span>
          <a href="/multi-country/">{f.multi}</a>
          <a href="/changes/">{f.changes}</a>
          <Out href={repository.file('LICENSE')}>{f.licence}</Out>
          <a href="/disclaimer/">{f.disclaimer}</a>
          <Out href={repository.file('SECURITY.md')}>{f.security}</Out>
          <Out href={repository.url}>{f.source}</Out>
          <Out href={repository.packageUrl}>{f.npm}</Out>
        </nav>
        <p className="mt-4 text-xs text-ink-faint">{f.legal}</p>
      </div>
    </footer>
  );
}

/**
 * The command, with a button that copies it.
 *
 * The button is an enhancement and is marked `hidden` until the one inline
 * script on the site un-hides it: with scripting off there is no button that
 * does nothing, and the command is selected by a single click either way.
 */
export function Command({ children }: { children: string }): ReactNode {
  return (
    <div className="group relative overflow-hidden rounded border border-line bg-paper">
      <pre className="overflow-x-auto px-4 py-3.5 pr-14">
        <code className="select-all font-mono text-sm text-ink">{children}</code>
      </pre>
      <button
        type="button"
        data-copy={children}
        hidden
        className="absolute top-2 right-2 rounded-sm border border-line bg-bg p-2 text-ink-faint transition-colors duration-150 hover:border-brand hover:text-brand-deep"
      >
        <span data-copy-idle>
          <Glyph name="copy" className="h-4 w-4" />
        </span>
        <span data-copy-done hidden>
          <Glyph name="check" className="h-4 w-4" />
        </span>
        <span className="sr-only">Copy the command</span>
      </button>
    </div>
  );
}
