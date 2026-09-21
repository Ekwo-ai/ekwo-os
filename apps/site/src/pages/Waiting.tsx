/**
 * `/countries/<cc>/` for a country with no pack: where it stands, and three
 * ways forward.
 *
 * Every grey shape of the map leads here, and so does every name in the list
 * of `/countries/`, so a reader looking for their country meets a page about
 * it rather than a guide written for a contributor. It says three things, in
 * order: there is no pack yet, what the repository does say about the country,
 * and what the reader can do — ask for it, write it, or set it up for others.
 *
 * **The status is read, never written.** `in progress` where a manifest shared
 * by several packs lists the country as a member (`familiesOf()` in
 * `data.ts`), `not started` everywhere else, and no date in either case.
 *
 * The request is the signup form of every other page, with the country's code
 * in `country`: the host keeps one list, and a request for a country nobody
 * has written is counted where every other one is. The page is not indexed and
 * is left out of the sitemap — it is two hundred near-identical pages, and a
 * search engine would read them as exactly that.
 */

import type { ReactNode } from 'react';
import { countryUrl, type SiteData, type WaitingCountry } from '../data.js';
import { fill, type Strings } from '../strings/index.js';
import { Glyph } from './icons.js';
import { SignupForm } from './SetUp.js';
import { Card, Eyebrow, Footer, Masthead, Out, StatusPill } from './ui.js';

/** Where contact goes until partners have a directory of their own. */
export const PARTNER_ADDRESS = 'contact@ekwo.ai';

export function Waiting({
  country,
  data,
  strings,
}: {
  country: WaitingCountry;
  data: SiteData;
  strings: Strings;
}): ReactNode {
  const { repository } = data;
  const s = strings.waiting;
  const named = { country: country.name };
  const subject = encodeURIComponent(fill(s.partnerSubject, named));

  return (
    <>
      <Masthead measure="page" strings={strings} data={data} current="countries" />
      <main className="mx-auto max-w-page px-5 py-14">
        <Eyebrow>{s.eyebrow}</Eyebrow>
        <h1 className="mt-4 max-w-[20ch] text-[clamp(2.25rem,1.7rem+2.6vw,3.5rem)]">
          {fill(s.heading, named)}
        </h1>
        <p className="mt-5 max-w-reading text-lg text-ink-soft">{fill(s.lead, named)}</p>

        <div className="mt-8 max-w-reading border-l-2 border-brand pl-5" data-waiting-status>
          <p className="flex flex-wrap items-center gap-3 text-sm font-medium text-ink">
            {s.statusLabel}
            <StatusPill status={country.family === null ? s.notStarted : s.inProgress} />
          </p>
          <p className="mt-2 text-ink-soft">
            {country.family === null ? (
              fill(s.notStartedBody, named)
            ) : (
              <InProgress text={fill(s.inProgressBody, named)} file={country.family.file} href={repository.file(country.family.file)} />
            )}
          </p>
        </div>

        <div className="mt-12 grid items-start gap-6 lg:grid-cols-2">
          <Card className="p-6 sm:p-8">
            <span className="text-brand-deep">
              <Glyph name="bell" className="h-6 w-6" />
            </span>
            <h2 className="mt-4 text-2xl">{s.notifyTitle}</h2>
            <p className="mt-3 text-ink-soft">{fill(s.notifyBody, named)}</p>
            <SignupForm
              country={{ code: country.code, name: country.name }}
              page={countryUrl(country.slug)}
              data={data}
              strings={strings}
            />
          </Card>

          <div className="grid gap-6">
            <Card className="p-6 sm:p-8">
              <span className="text-brand-deep">
                <Glyph name="gitPullRequest" className="h-6 w-6" />
              </span>
              <h2 className="mt-4 text-2xl">{s.contributeTitle}</h2>
              <p className="mt-3 text-ink-soft">{s.contributeBody}</p>
              <ol className="mt-5 space-y-3">
                {s.steps.map((step, index) => (
                  <li key={step.text} className="flex gap-3 text-ink-soft">
                    <span className="inline-flex h-6 w-6 shrink-0 items-center justify-center rounded-pill bg-brand-fill font-mono text-xs text-brand-deep">
                      {index + 1}
                    </span>
                    <span className="min-w-0">
                      {fill(step.text, named)}
                      {step.code === '' ? null : (
                        <code className="mt-1.5 block w-fit max-w-full overflow-x-auto rounded-sm bg-track px-2 py-1 font-mono text-sm whitespace-nowrap text-ink">
                          {fill(step.code, { cc: country.slug })}
                        </code>
                      )}
                    </span>
                  </li>
                ))}
              </ol>
              <p className="mt-5 text-sm text-ink-faint">{s.community}</p>
              <p className="mt-5 flex flex-col gap-2 text-sm">
                <Out href={`${repository.file('docs/packs.md')}#adding-a-country-in-a-day`}>{s.guide}</Out>
                <Out href={`${repository.file('CONTRIBUTING.md')}#adding-a-country`}>{s.contributing}</Out>
                <Out href={repository.newPackIssue}>{s.issue}</Out>
              </p>
            </Card>

            <Card className="p-6 sm:p-8">
              <span className="text-brand-deep">
                <Glyph name="handshake" className="h-6 w-6" />
              </span>
              <h2 className="mt-4 text-2xl">{s.partnerTitle}</h2>
              <p className="mt-3 text-ink-soft">{fill(s.partnerBody, named)}</p>
              <p className="mt-5">
                <a href={`mailto:${PARTNER_ADDRESS}?subject=${subject}`} className="font-medium">
                  {s.partnerAction}
                </a>
              </p>
            </Card>
          </div>
        </div>

        <p className="mt-12 text-sm">
          <a href="/countries/">{s.back}</a>
        </p>
      </main>
      <Footer repository={repository} measure="page" strings={strings} />
    </>
  );
}

/** The sentence with the manifest's path in it, where `{file}` stands, set as a link to the file. */
function InProgress({ text, file, href }: { text: string; file: string; href: string }): ReactNode {
  const [before, after] = text.split('{file}');
  return (
    <>
      {before}
      <Out href={href}>
        <code className="font-mono text-sm">{file}</code>
      </Out>
      {after}
    </>
  );
}
