/**
 * `/multi-country/` — several countries, one set of books.
 *
 * Three readers, one answer. A group with a company in each country, an
 * accounting firm whose clients are abroad, a company opening its next
 * country: each of them needs a company per country, each on its own country's
 * rules, kept side by side by the same people with the same tools. That is
 * the ordinary shape of this schema rather than an edition of it, so the page
 * says so first and proves it after.
 *
 * The order is the home page's: the ambition, then who it is for, then what
 * works today — every line linked to the file that makes it true — then what
 * does not, said as plainly. Every claim is in `data/multicountry.ts` with its
 * proof and every word in the strings; the three numbers are counted from the
 * packs. No country is named here, no client, no price and no form: the way to
 * talk is an address to write to.
 */

import type { ReactNode } from 'react';
import type { SiteData } from '../data.js';
import { AUDIENCES, LATER, SHIPPED } from '../data/multicountry.js';
import { fill, type Strings } from '../strings/index.js';
import { Glyph } from './icons.js';
import { Card, Footer, Masthead, NotYet, Out, Secondary, StatusPill } from './ui.js';

/** The address the page offers, the same one the home page does. */
const CONTACT = 'mailto:contact@ekwo.ai';

/** The three numbers under the lead: packs, their currencies, their languages. */
export function multiCounts(data: SiteData): { countries: number; currencies: number; languages: number } {
  return {
    countries: data.countries.length,
    currencies: new Set(data.countries.map((country) => country.currency)).size,
    languages: data.languages.length,
  };
}

export function MultiCountry({ data, strings }: { data: SiteData; strings: Strings }): ReactNode {
  const { repository } = data;
  const s = strings.multi;
  const words = <T,>(table: Record<string, T>, key: string): T => {
    const found = table[key];
    if (found === undefined) throw new Error(`the language ${strings.lang} has no words for ${key}`);
    return found;
  };

  return (
    <>
      <Masthead measure="page" strings={strings} data={data} current="countries" />

      {/* The ambition. */}
      <section className="relative overflow-hidden">
        <div className="hero-ground pointer-events-none absolute inset-0" aria-hidden />
        <div className="relative mx-auto max-w-page px-5 pt-20 pb-16 sm:pt-28">
          <p className="text-[0.6875rem] uppercase tracking-[0.16em] text-brand-deep">{s.eyebrow}</p>
          <h1 className="mt-5 max-w-[16ch] text-[clamp(2.5rem,1.6rem+4vw,4.5rem)] leading-[1.05]">
            {s.heading}
          </h1>
          <p className="mt-7 max-w-[58ch] text-xl leading-relaxed text-ink-soft">{s.lead}</p>
          <p className="mt-6 text-ink-faint">{fill(s.today, multiCounts(data))}</p>
          <div className="mt-9 flex flex-wrap gap-3">
            <Secondary href="/countries/">{strings.regions.all}</Secondary>
            <Secondary href="/compare/">{strings.os.compare}</Secondary>
          </div>
        </div>
      </section>

      {/* Who it is for. */}
      <section className="mx-auto max-w-page px-5 py-16">
        <h2 className="max-w-[22ch] text-[clamp(1.75rem,1.2rem+2.4vw,2.75rem)]">{s.audiencesTitle}</h2>
        <div className="mt-10 grid gap-x-10 gap-y-12 lg:grid-cols-3">
          {AUDIENCES.map((audience) => {
            const w = words(s.audiences, audience.key);
            return (
              <div key={audience.key}>
                <span className="inline-flex h-11 w-11 items-center justify-center rounded bg-brand-fill text-brand-deep">
                  <Glyph name={audience.icon} className="h-5 w-5" />
                </span>
                <h3 className="mt-5 text-xl">{w.title}</h3>
                <p className="mt-2.5 text-ink-soft">{w.body}</p>
              </div>
            );
          })}
        </div>
      </section>

      {/* What works today, each with the file that makes it true. */}
      <section className="mx-auto max-w-page px-5 py-16">
        <h2 className="max-w-[22ch] text-[clamp(1.75rem,1.2rem+2.4vw,2.75rem)]">{s.shippedTitle}</h2>
        <p className="mt-4 max-w-reading text-ink-soft">{s.shippedLead}</p>
        <div className="mt-10 grid gap-4 sm:grid-cols-2">
          {SHIPPED.map((claim) => {
            const w = words(s.shipped, claim.key);
            return (
              <Card key={claim.key} className="flex flex-col p-6">
                <span className="text-brand-deep">
                  <Glyph name={claim.icon} className="h-5 w-5" />
                </span>
                <h3 className="mt-4 text-lg">{w.title}</h3>
                <p className="mt-2 flex-1 text-sm text-ink-soft">{w.body}</p>
                <p className="mt-4 text-sm">
                  <Out href={repository.file(claim.proof)}>
                    {s.proof}: <span className="font-mono text-[0.8125rem] break-all">{claim.proof}</span>
                  </Out>
                </p>
              </Card>
            );
          })}
        </div>
      </section>

      {/* What is not there yet. */}
      <section className="mx-auto max-w-page px-5 py-16">
        <h2 className="max-w-[22ch] text-[clamp(1.75rem,1.2rem+2.4vw,2.75rem)]">{s.laterTitle}</h2>
        <p className="mt-4 max-w-reading text-ink-soft">{s.laterLead}</p>
        <ul className="mt-8 divide-y divide-line border-y border-line">
          {LATER.map((claim) => {
            const w = words(s.later, claim.key);
            return (
              <li key={claim.key} className="grid gap-2 py-5 sm:grid-cols-[1fr_2fr] sm:gap-8">
                <div className="flex flex-wrap items-center gap-3">
                  <h3 className="text-lg">{w.title}</h3>
                  {claim.status === 'planned' ? <StatusPill status={s.planned} /> : <NotYet>{s.notYet}</NotYet>}
                </div>
                <p className="text-ink-soft">
                  {w.body}
                  {claim.proof === null ? null : (
                    <>
                      {' '}
                      <Out href={repository.file(claim.proof)} className="text-sm">
                        {s.proof}
                      </Out>
                    </>
                  )}
                </p>
              </li>
            );
          })}
        </ul>
      </section>

      {/* The way to talk: an address, no form. */}
      <section className="mt-8 bg-band py-16 text-band-ink">
        <div className="mx-auto max-w-page px-5">
          <p className="text-[0.6875rem] uppercase tracking-[0.16em] text-band-muted">{s.eyebrow}</p>
          <h2 className="mt-4 max-w-[20ch] text-[clamp(1.75rem,1.2rem+2.4vw,2.75rem)] text-band-ink">
            {s.contactTitle}
          </h2>
          <p className="mt-4 max-w-reading text-band-muted">{s.contactBody}</p>
          <a
            href={CONTACT}
            className="mt-8 inline-flex items-center gap-2 rounded-pill bg-brand-solid px-5 py-2.5 font-medium text-brand-on no-underline transition-colors duration-150 hover:bg-brand-muted"
          >
            {s.contactAction}
          </a>
        </div>
      </section>

      <Footer repository={repository} measure="page" strings={strings} />
    </>
  );
}
