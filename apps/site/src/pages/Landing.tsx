/**
 * The home page: what Ekwo is for, before what it does.
 *
 * The order is the argument. The ambition first, then the world it is aimed at,
 * then the six things it promises a business, then what runs without anybody
 * typing it, then the proof that any of it exists, then how to get it, then the
 * invitation. Proof supports the ambition here; it does not open the page.
 *
 * Two rules held while writing it. **Nothing is a number somebody typed** — the
 * counters are counted, the countries are the packs, the transcripts are a real
 * year of books. And **nothing claims what the repository does not do**: a
 * capability says `shipped` only where a function, a module, a brick or a
 * command exists, everything else says where it is going, and a sentence that
 * could not be checked was cut rather than softened.
 *
 * No country is named in this file, and no sentence is written in it: the words
 * are the language's, in `src/strings/`, and `tests/site.test.ts` refuses a
 * country written into any source file of `apps/site`.
 */

import type { ReactNode } from 'react';
import type { SiteData } from '../data.js';
import { fill, type Strings } from '../strings/index.js';
import { AUTOMATION, CAPABILITIES, PLANNED_MODULES, type Family } from '../data/capabilities.js';
import { FOUNDATIONS, MODELS } from '../data/ecosystem.js';
import { Demos } from './Terminal.js';
import { WorldMap } from './WorldMap.js';
import { Glyph } from './icons.js';
import {
  Action,
  Card,
  Eyebrow,
  Footer,
  Masthead,
  Out,
  Secondary,
  StatusPill,
} from './ui.js';

/**
 * What the engine already does that a one-country tool never has to.
 *
 * Each is a fact about the core, checkable in the repository, and none of them
 * names a country — which is both the site's rule and the point being made:
 * the engine does not know one. The number of languages is read.
 */
function reach(data: SiteData): string[] {
  return [
    'A country that levies no value added tax at all, with a tax that follows the territory of the parties.',
    'A country outside the common system of VAT, and one inside it, from the same engine.',
    'Several charts of accounts in one country — for companies, and for non-profits.',
    'Amounts carry the decimals of their currency rather than assuming cents, and the rounding method of their country.',
    'Exchange differences booked to the accounts the pack names.',
    `Charts and labels in ${data.languages.length} languages, translated in the packs themselves.`,
    'EN 16931 and Peppol where they apply, and nothing where they do not.',
    'No country, currency or language anywhere in the code — a check in the CI refuses one.',
  ];
}

export function Landing({ data, strings }: { data: SiteData; strings: Strings }): ReactNode {
  const { repository } = data;
  const s = strings.home;
  const families: Family[] = [
    'accounting',
    'finance',
    'sustainability',
    'digital',
    'documents',
  ];

  return (
    <>
      <Masthead measure="page" strings={strings} data={data} />

      {/* ---------------------------------------------------------------- */}
      {/* The ambition.                                                     */}
      {/* ---------------------------------------------------------------- */}
      <section className="relative overflow-hidden">
        <div className="hero-ground pointer-events-none absolute inset-0" aria-hidden />
        <div className="hero-grid pointer-events-none absolute inset-0" aria-hidden />
        <div className="relative mx-auto max-w-page px-5 pt-20 pb-16 sm:pt-28">
          <p className="text-[0.6875rem] uppercase tracking-[0.16em] text-brand-deep">
            {s.hero.eyebrow}
          </p>
          <RotatingTitle hero={s.hero} />
          <p className="mt-7 max-w-[54ch] text-xl leading-relaxed text-ink-soft sm:text-2xl">
            {s.hero.lead}
          </p>
          <p className="mt-4 max-w-[54ch] text-lg text-ink-faint">{s.hero.ai}</p>
          <div className="mt-9 flex flex-wrap gap-3">
            <Action href="/os/">{s.hero.install}</Action>
            <Secondary href="/manifesto/">{s.hero.manifesto}</Secondary>
          </div>
        </div>
      </section>

      {/* ---------------------------------------------------------------- */}
      {/* The world it is aimed at.                                         */}
      {/* ---------------------------------------------------------------- */}
      <section className="mx-auto max-w-page px-5 py-20">
        <Eyebrow>{s.world.eyebrow}</Eyebrow>
        <h2 className="mt-4 max-w-[20ch] text-[clamp(2rem,1.3rem+3vw,3.25rem)]">{s.world.title}</h2>
        <p className="mt-6 max-w-[62ch] text-xl leading-relaxed text-ink-soft">
          {fill(s.world.body, { countries: data.countries.length })}
        </p>

        <p className="mt-10 max-w-[22ch] font-serif text-[clamp(1.5rem,1.1rem+1.8vw,2.25rem)] leading-[1.15] font-semibold text-brand-deep">
          {s.world.signature}
        </p>

        <div className="mt-10">
          <WorldMap world={data.world} repository={repository} strings={strings} />
        </div>

        {/* The mechanism, second and smaller: the ideal is the argument. */}
        <div className="mt-14 border-t border-line pt-8">
          <p className="max-w-[70ch] text-sm leading-relaxed text-ink-faint">
            <span className="font-medium text-ink-soft">{s.world.howItWorks}: </span>
            {s.world.how}{' '}
            <Out href={repository.file('docs/packs.md')}>{s.world.guide}</Out>
          </p>
          <div className="mt-8 grid gap-x-10 gap-y-3 sm:grid-cols-2">
            {reach(data).map((line) => (
              <p key={line} className="flex gap-3 text-sm text-ink-soft">
                <span className="mt-2 h-1.5 w-1.5 shrink-0 rounded-pill bg-brand" aria-hidden />
                <span>{line}</span>
              </p>
            ))}
          </div>
        </div>
      </section>

      {/* ---------------------------------------------------------------- */}
      {/* What it promises a business.                                      */}
      {/* ---------------------------------------------------------------- */}
      <section className="border-y border-line bg-paper">
        <div className="mx-auto max-w-page px-5 py-20">
          <Eyebrow>{s.promises.eyebrow}</Eyebrow>
          <h2 className="mt-4 max-w-[20ch] text-[clamp(2rem,1.3rem+3vw,3.25rem)]">
            {s.promises.title}
          </h2>
          <div className="mt-12 grid gap-x-10 gap-y-12 sm:grid-cols-2 lg:grid-cols-3">
            {s.promises.items.map((promise, index) => (
              <div key={promise.title}>
                <span className="inline-flex h-11 w-11 items-center justify-center rounded bg-brand-fill text-brand-deep">
                  <Glyph name={PROMISE_ICONS[index] ?? 'unlock'} className="h-5 w-5" />
                </span>
                <h3 className="mt-5 text-xl">{promise.title}</h3>
                <p className="mt-2.5 text-ink-soft">{promise.body}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ---------------------------------------------------------------- */}
      {/* What runs by itself, and what drives it.                          */}
      {/* ---------------------------------------------------------------- */}
      <section className="mx-auto max-w-page px-5 py-20">
        <Eyebrow>{s.automation.eyebrow}</Eyebrow>
        <h2 className="mt-4 max-w-[20ch] text-[clamp(2rem,1.3rem+3vw,3.25rem)]">
          {s.automation.title}
        </h2>
        <p className="mt-5 max-w-reading text-lg text-ink-soft">{s.automation.lead}</p>

        <div className="mt-12 grid min-w-0 gap-4 sm:grid-cols-2 lg:grid-cols-4">
          {AUTOMATION.map((item) => (
            <Card key={item.title} className="p-6">
              <div className="flex items-start justify-between gap-3">
                <span className="text-brand-deep">
                  <Glyph name={item.icon} className="h-5 w-5" />
                </span>
                {item.status === 'planned' ? (
                  <StatusPill status={strings.status.planned} />
                ) : null}
              </div>
              <h3 className="mt-4 text-lg">{item.title}</h3>
              <p className="mt-2 text-sm text-ink-soft">{item.body}</p>
            </Card>
          ))}
        </div>

        {data.demo === null ? null : (
          <div className="mt-10">
            <Demos demo={data.demo} strings={strings} icons={data.icons} />
          </div>
        )}

        {/* The models. A row that shows several, equally, is the claim. */}
        <div className="mt-20">
          <h3 className="text-xl">{s.models.title}</h3>
          <p className="mt-2.5 max-w-reading text-ink-soft">{s.models.body}</p>
          <ul className="mt-6 flex flex-wrap gap-2.5">
            {MODELS.map((mark) => (
              <Mark key={mark.name} name={mark.name} icon={mark.icon} icons={data.icons} />
            ))}
            <li className="inline-flex items-center rounded-pill border border-dashed border-line px-4 py-2 text-sm text-ink-faint">
              {s.models.openWeight}
            </li>
            <li className="inline-flex items-center rounded-pill border border-dashed border-line px-4 py-2 text-sm text-ink-faint">
              {s.models.any}
            </li>
          </ul>

          <h3 className="mt-14 text-xl">{s.models.foundationsTitle}</h3>
          <p className="mt-2.5 max-w-reading text-ink-soft">{s.models.foundationsBody}</p>
          <ul className="mt-6 flex flex-wrap gap-2.5">
            {FOUNDATIONS.map((mark) => (
              <Mark key={mark.name} name={mark.name} icon={mark.icon} icons={data.icons} />
            ))}
          </ul>
          <p className="mt-5 max-w-reading text-sm text-ink-faint">{s.models.ownership}</p>
        </div>
      </section>

      {/* ---------------------------------------------------------------- */}
      {/* That any of it exists.                                            */}
      {/* ---------------------------------------------------------------- */}
      <section className="mx-auto max-w-page px-5 py-20">
        <Eyebrow>{s.scale.eyebrow}</Eyebrow>
        <dl className="mt-8 grid grid-cols-2 gap-x-8 gap-y-10 sm:grid-cols-3 lg:grid-cols-5">
          {data.counters.map((counter) => (
            <div key={counter.label}>
              <dt className="sr-only">{counter.label}</dt>
              <dd>
                <span className="block font-serif text-[clamp(2.25rem,1.6rem+2vw,3.5rem)] leading-none font-semibold text-ink">
                  {counter.value}
                </span>
                <span className="mt-2 block text-sm text-ink-soft">{counter.label}</span>
                <span className="mt-0.5 block text-xs text-ink-faint">{counter.note}</span>
              </dd>
            </div>
          ))}
        </dl>

        <h2 className="mt-20 max-w-[20ch] text-[clamp(2rem,1.3rem+3vw,3.25rem)]">
          {s.scale.title}
        </h2>
        <p className="mt-4 max-w-reading text-ink-soft">{s.scale.freeLine}</p>

        {families.map((family) => {
          const tiles = CAPABILITIES.filter((item) => item.family === family);
          const modules = PLANNED_MODULES.filter((item) => item.family === family);
          if (tiles.length === 0 && modules.length === 0) return null;
          return (
            <div key={family} className="mt-14">
              <h3 className="text-[0.6875rem] uppercase tracking-[0.16em] text-ink-faint">
                {s.scale.families[family]}
              </h3>
              {tiles.length === 0 ? null : (
                <div className="mt-5 grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
                  {tiles.map((item) => (
                    <Card key={item.title} className="flex flex-col p-6">
                      <div className="flex items-start justify-between gap-3">
                        <span className="text-brand-deep">
                          <Glyph name={item.icon} className="h-5 w-5" />
                        </span>
                        {item.status === 'planned' ? (
                          <StatusPill status={strings.status.planned} />
                        ) : null}
                      </div>
                      <h4 className="mt-4 text-lg font-serif font-semibold">{item.title}</h4>
                      <p className="mt-2 text-sm text-ink-soft">{item.body}</p>
                    </Card>
                  ))}
                </div>
              )}
              {modules.map((item) => (
                <Card key={item.title} className="mt-5 p-8">
                  <div className="flex flex-wrap items-center gap-3">
                    <span className="inline-flex h-11 w-11 items-center justify-center rounded bg-brand-fill text-brand-deep">
                      <Glyph name={item.icon} className="h-5 w-5" />
                    </span>
                    <StatusPill status={strings.status.planned} />
                  </div>
                  <h4 className="mt-5 max-w-[24ch] font-serif text-2xl font-semibold">
                    {item.title}
                  </h4>
                  <p className="mt-3 max-w-reading text-ink-soft">{item.body}</p>
                  <p className="mt-4 text-sm">
                    <Out href={repository.file(item.proof)}>{s.scale.modulesLink}</Out>
                  </p>
                </Card>
              ))}
            </div>
          );
        })}

        <p className="mt-14 max-w-reading text-ink-soft">
          {s.scale.direction}{' '}
          <Out href={repository.file('modules/README.md')}>{s.scale.modulesLink}</Out>
        </p>
      </section>

      {/* ---------------------------------------------------------------- */}
      {/* How to get it.                                                    */}
      {/* ---------------------------------------------------------------- */}
      <section className="bg-band py-20 text-band-ink">
        <div className="mx-auto max-w-page px-5">
          <p className="text-[0.6875rem] uppercase tracking-[0.16em] text-band-muted">
            {s.ways.eyebrow}
          </p>
          <h2 className="mt-4 max-w-[18ch] text-[clamp(2rem,1.3rem+3vw,3.25rem)] text-band-ink">
            {s.ways.title}
          </h2>
          <div className="mt-12 grid gap-6 lg:grid-cols-2">
            <div className="rounded-lg border border-band-line p-8">
              <h3 className="text-2xl text-band-ink">{s.ways.ownTitle}</h3>
              <p className="mt-3 text-band-muted">{s.ways.ownBody}</p>
              <a
                href="/os/"
                className="mt-6 inline-flex items-center gap-2 rounded-pill bg-brand-solid px-5 py-2.5 font-medium text-brand-on no-underline transition-colors duration-150 hover:bg-brand-muted"
              >
                {s.ways.ownAction}
              </a>
            </div>
            <div className="rounded-lg border border-band-line p-8">
              <h3 className="text-2xl text-band-ink">{s.ways.hostedTitle}</h3>
              <p className="mt-3 text-band-muted">{s.ways.hostedBody}</p>
              <a
                href="mailto:contact@ekwo.ai"
                className="mt-6 inline-flex items-center gap-2 rounded-pill border border-band-line px-5 py-2.5 font-medium text-band-ink no-underline transition-colors duration-150 hover:border-brand"
              >
                {s.ways.hostedAction}
              </a>
            </div>
          </div>
        </div>
      </section>

      {/* ---------------------------------------------------------------- */}
      {/* The invitation.                                                   */}
      {/* ---------------------------------------------------------------- */}
      <section className="mx-auto max-w-page px-5 py-20">
        <div className="grid gap-10 lg:grid-cols-[1.2fr_1fr] lg:items-start">
          <div>
            <Eyebrow>{s.network.eyebrow}</Eyebrow>
            <h2 className="mt-4 max-w-[18ch] text-[clamp(2rem,1.3rem+3vw,3.25rem)]">
              {s.network.title}
            </h2>
            <p className="mt-5 max-w-reading text-lg text-ink-soft">{s.network.body}</p>
            <div className="mt-8 flex flex-wrap gap-3">
              <Action href={repository.file('docs/packs.md')}>{s.network.write}</Action>
              <Secondary href={repository.newPackIssue}>{s.network.review}</Secondary>
            </div>
          </div>
          <Card className="p-8">
            <h3 className="text-lg">{s.network.countriesToday}</h3>
            <ul className="mt-4 divide-y divide-line">
              {data.countries.map((country) => (
                <li key={country.slug}>
                  <a
                    href={`/countries/${country.slug}/`}
                    className="flex items-center gap-3 py-2.5 no-underline"
                  >
                    <span className="font-mono text-xs text-ink-faint">{country.slug}</span>
                    <span className="text-ink">{country.name}</span>
                    <span className="flex-1" />
                    <StatusPill status={country.certification.status} />
                  </a>
                </li>
              ))}
            </ul>
            <p className="mt-5 text-sm text-ink-faint">
              {s.network.openInvite}{' '}
              <Out href={repository.file('docs/packs.md')}>{s.network.guide}</Out>
            </p>
          </Card>
        </div>
      </section>

      {/* ---------------------------------------------------------------- */}
      {/* The closing statement, and the manifesto's own sentence: both     */}
      {/* say "data", so the page and the text it links to agree.           */}
      {/* ---------------------------------------------------------------- */}
      <section className="mx-auto max-w-page px-5 pb-8">
        <div className="border-l-2 border-brand pl-6 sm:pl-10">
          <p className="max-w-[24ch] font-serif text-[clamp(1.75rem,1.2rem+2.4vw,3rem)] leading-[1.12] font-semibold text-ink">
            {s.closing.quote}
          </p>
          <p className="mt-5 text-ink-faint">
            <a href="/manifesto/">{s.closing.link}</a>
          </p>
        </div>
      </section>

      <Footer repository={repository} measure="page" strings={strings} />
    </>
  );
}

/**
 * The heading, with its first word turning.
 *
 * One `<h1>`, and what it says never changes: the stable sentence is the only
 * thing in the accessible tree, and the words that turn are `aria-hidden`
 * decoration on top of it. There is no `aria-live` — a heading that announced
 * itself every two seconds would be unusable — and the title tag, the meta
 * description and the Open Graph pair all stay on the stable form.
 *
 * Nothing moves on the page while it turns. The words are stacked in one grid
 * cell whose width is set by an invisible copy of the longest of them — and
 * the phrase is set on two lines for that reason: on one line, the reserved
 * width left a hand's width of gap between a short word and what follows it,
 * which read as broken type. At the end of a line the same reserved width is
 * simply trailing space, and nothing shows.
 *
 * It is CSS, so it costs nothing and works with scripting off, and **it
 * stops**: two turns through the list, then it rests on the first word for
 * good. An animation that never ends at the top of a page is one readers learn
 * to look away from.
 */
function RotatingTitle({ hero }: { hero: Strings['home']['hero'] }): ReactNode {
  const words = hero.titleWords;
  return (
    <>
      <style dangerouslySetInnerHTML={{ __html: rotationKeyframes(words.length) }} />
      <h1 className="mt-5 text-[clamp(3rem,1.6rem+6vw,6rem)]">
        <span className="sr-only">{hero.titleAccessible}</span>
        <span aria-hidden className="block">
          <span className="relative inline-grid align-bottom">
            {words.map((word, index) => (
              <span
                key={word}
                className="hero-word col-start-1 row-start-1 text-brand"
                style={{
                  animationName: `hero-word-${index}`,
                  animationDuration: `${SLOT * words.length * TURNS}s`,
                }}
              >
                {word},
              </span>
            ))}
            {/*
              The widest word, drawn invisibly, is what gives the cell its
              width. Without it the grid would be as wide as whichever word
              happened to be showing, and the rest of the line would move.
            */}
            <span className="invisible col-start-1 row-start-1">{widest(words)},</span>
          </span>
        </span>
        <span aria-hidden className="block">{hero.titleTail}</span>
      </h1>
    </>
  );
}

/** How long one word holds, and how many times the list is gone through. */
const SLOT = 2.4;
const TURNS = 2;

/**
 * The keyframes, worked out for the number of words there are.
 *
 * A keyframe offset has to be a literal percentage — it cannot be a `calc()`,
 * which is how the first version of this managed to be invisible without
 * failing. So the offsets are computed here, where the count is known, and the
 * whole rule set is emitted once.
 *
 * Word `i` shows in slot `i` of each turn. Every word ends the animation
 * hidden except the first, which comes back at the end and stays: that is what
 * makes the heading come to rest on the word the metadata also uses.
 */
function rotationKeyframes(count: number): string {
  const slots = count * TURNS;
  const step = 100 / slots;
  // A twelfth of a slot to fade, which is about 200ms at the rhythm above.
  const fade = step / 12;
  const at = (value: number): string => `${Math.max(0, Math.min(100, value)).toFixed(3)}%`;

  return Array.from({ length: count }, (_, index) => {
    const stops: string[] = [];
    const show = (slot: number): void => {
      const from = slot * step;
      stops.push(
        `${at(from - fade)}{opacity:0;transform:translateY(.1em)}`,
        `${at(from)}{opacity:1;transform:none}`,
        `${at(from + step - fade)}{opacity:1;transform:none}`,
        `${at(from + step)}{opacity:0;transform:translateY(-.1em)}`,
      );
    };
    stops.push('0%{opacity:0}');
    for (let turn = 0; turn < TURNS; turn += 1) show(index + turn * count);
    // The first word returns at the end and stays there.
    if (index === 0) stops.push(`${at(100 - fade)}{opacity:0}`, '100%{opacity:1;transform:none}');
    else stops.push('100%{opacity:0}');
    return `@keyframes hero-word-${index}{${stops.join('')}}`;
  }).join('');
}

/** The longest of the words, which is the one that sets the width. */
function widest(words: string[]): string {
  return words.reduce((longest, word) => (word.length > longest.length ? word : longest), '');
}

/** The icon beside each promise, in the order the language lists them. */
const PROMISE_ICONS = ['unlock', 'unplug', 'database', 'scale', 'shieldCheck', 'eyeOff'];

/** One name in a row: its mark where `simple-icons` has one, its word otherwise. */
function Mark({
  name,
  icon,
  icons,
}: {
  name: string;
  icon: string | null;
  icons: Record<string, string>;
}): ReactNode {
  const path = icon === null ? undefined : icons[icon];
  return (
    <li className="inline-flex items-center gap-2.5 rounded-pill border border-line bg-paper px-4 py-2 text-sm text-ink-soft">
      {path === undefined ? null : (
        <svg viewBox="0 0 24 24" className="h-4 w-4 fill-current" aria-hidden>
          <path d={path} />
        </svg>
      )}
      <span>{name}</span>
    </li>
  );
}
