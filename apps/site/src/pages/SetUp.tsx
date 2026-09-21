/**
 * Setting Ekwo up: the button, the two ways in, the form and its thanks.
 *
 * Every country page carries one strong button, at its head and at its foot,
 * named after the country: it leads to `/countries/<cc>/set-up/`, where the
 * two ways in sit side by side. The first is the command, with the country
 * already on it — `--country` is the installer's own flag, and it takes the
 * code the pack declares. The second is a form, for somebody who would rather
 * be helped. `/signup/` is the same page where no country is known yet, and
 * there the country is a field of the form rather than a given.
 *
 * **The form needs no script and no server of ours.** It is a plain HTML form
 * the host reads when the site is deployed (Netlify Forms: `data-netlify` and
 * a `name`), so it is in the prerendered page for the host to find, and it
 * posts to `/thanks/`, which is a page like any other. The trap for robots is
 * a field nobody sees and the host is told the name of
 * (`data-netlify-honeypot`); a submission that fills it is dropped. Every
 * variant of the form — one per country and the one on `/signup/` — carries
 * the same fields under the same names, because the host keeps one list of
 * fields per form name.
 *
 * It asks for the one thing needed to answer — an address — and makes the
 * rest optional, and it says under itself what it collects and why. No price,
 * no promise of a delay, nobody named.
 */

import type { ReactNode } from 'react';
import type { PackDescription } from '../../../../packages/cli/src/index.js';
import type { SiteData } from '../data.js';
import { fill, type Strings } from '../strings/index.js';
import { Glyph } from './icons.js';
import { regionName } from './Regions.js';
import { Action, Card, Command, Eyebrow, Footer, Masthead } from './ui.js';

/** The name the host files submissions under. One form, whatever page it is on. */
export const SIGNUP_FORM = 'signup';
/** The field only a robot fills. */
export const HONEYPOT = 'bot-field';
/** Where a sent form lands. Not indexed: it says nothing to somebody who did not send one. */
export const THANKS = '/thanks/';
/** Setting up where no country is known yet. */
export const SIGNUP = '/signup/';

/** The page a country's button leads to. */
export function setUpUrl(country: PackDescription): string {
  return `/countries/${country.slug}/set-up/`;
}

/** The command, with the country on it: `--country` takes the code the pack declares. */
export function setUpCommand(installCommand: string, country: PackDescription | null): string {
  return country === null ? installCommand : `${installCommand} --country ${country.country}`;
}

/** Who is writing, as the form offers it. The keys are the values submitted. */
export const PROFILES = ['company', 'firm', 'partner'] as const;

/**
 * The strong button of a country page.
 *
 * At the head of the page it stands alone; at the foot it comes with the line
 * that says what is behind it, on a band, because that is where somebody who
 * read the whole page decides.
 */
export function SetUpButton({
  country,
  strings,
  band = false,
}: {
  country: PackDescription;
  strings: Strings;
  band?: boolean;
}): ReactNode {
  const s = strings.setup;
  const button = (
    <Action href={setUpUrl(country)}>
      <Glyph name="rocket" className="h-[18px] w-[18px]" />
      {fill(s.action, { country: country.name })}
    </Action>
  );
  if (!band) return button;
  return (
    <section className="mt-20 rounded-lg bg-band px-6 py-10 text-band-ink sm:px-10">
      <h2 className="max-w-[22ch] text-[clamp(1.5rem,1.1rem+1.8vw,2.25rem)] text-band-ink">
        {fill(s.actionHeading, { country: country.name })}
      </h2>
      <p className="mt-3 max-w-reading text-band-muted">{s.actionLead}</p>
      <div className="mt-7">{button}</div>
    </section>
  );
}

/**
 * The two ways in, for one country or for none.
 *
 * `/countries/<cc>/set-up/` and `/signup/` are this one component: with a
 * country the command carries it and the form sends it without asking; without
 * one the command is the bare installer and the form asks.
 */
export function SetUp({
  country,
  data,
  strings,
}: {
  country: PackDescription | null;
  data: SiteData;
  strings: Strings;
}): ReactNode {
  const { repository } = data;
  const s = strings.setup;
  const named = country === null ? null : { country: country.name };

  return (
    <>
      <Masthead measure="page" strings={strings} data={data} current={country === null ? undefined : 'countries'} />
      <main className="mx-auto max-w-page px-5 py-14">
        <Eyebrow>{s.eyebrow}</Eyebrow>
        <h1 className="mt-4 max-w-[20ch] text-[clamp(2.25rem,1.7rem+2.6vw,3.5rem)]">
          {named === null ? s.anyHeading : fill(s.heading, named)}
        </h1>
        <p className="mt-5 max-w-reading text-lg text-ink-soft">
          {named === null ? s.anyLead : fill(s.lead, named)}
        </p>

        <div className="mt-12 grid items-start gap-6 lg:grid-cols-2">
          <Card className="p-6 sm:p-8">
            <span className="text-brand-deep">
              <Glyph name="terminal" className="h-6 w-6" />
            </span>
            <h2 className="mt-4 text-2xl">{s.ownTitle}</h2>
            <p className="mt-3 text-ink-soft">{named === null ? s.ownBodyAny : fill(s.ownBody, named)}</p>
            <div className="mt-6">
              <Command>{setUpCommand(repository.installCommand, country)}</Command>
            </div>
            <p className="mt-4 text-sm text-ink-faint">{s.ownAsks}</p>
            <p className="mt-6">
              <a href="/docs/install/" className="font-medium">
                {s.ownGuide}
              </a>
            </p>
          </Card>

          <Card className="p-6 sm:p-8">
            <span className="text-brand-deep">
              <Glyph name="send" className="h-6 w-6" />
            </span>
            <h2 className="mt-4 text-2xl">{s.withUsTitle}</h2>
            <p className="mt-3 text-ink-soft">{s.withUsBody}</p>
            <SignupForm
              country={country === null ? null : { code: country.country, name: country.name }}
              page={country === null ? SIGNUP : setUpUrl(country)}
              data={data}
              strings={strings}
            />
          </Card>
        </div>
      </main>
      <Footer repository={repository} measure="page" strings={strings} />
    </>
  );
}

const INPUT =
  'mt-1.5 block w-full rounded-sm border border-line bg-bg px-3 py-2.5 text-ink placeholder:text-ink-faint focus:border-brand-soft focus:outline-none';
const LABEL = 'block text-sm font-medium text-ink';

/**
 * The form, as the host reads it at deploy.
 *
 * It is also the vote of a country with no pack: its page carries this same
 * form with the country's code in `country`, so the host keeps one list and a
 * request for a country nobody has written is counted where every other one is.
 *
 * `form-name` is written out although the host adds it to a form it detects:
 * it costs one hidden field and makes the post correct on its own. The page
 * the form was sent from travels with it, so a reply can start from the
 * country somebody was reading about.
 */
export function SignupForm({
  country,
  page,
  data,
  strings,
}: {
  /** The country the page is about, sent without asking; null to ask. */
  country: { code: string; name: string } | null;
  /** The address of the page it is on, sent with it. */
  page: string;
  data: SiteData;
  strings: Strings;
}): ReactNode {
  const f = strings.setup.form;
  const optional = <span className="font-normal text-ink-faint"> ({f.optional})</span>;
  return (
    <form
      name={SIGNUP_FORM}
      method="POST"
      action={THANKS}
      data-netlify="true"
      data-netlify-honeypot={HONEYPOT}
      className="mt-6 space-y-5"
    >
      <input type="hidden" name="form-name" value={SIGNUP_FORM} />
      <input type="hidden" name="page" value={page} />
      <p hidden>
        <label>
          {f.honeypot} <input name={HONEYPOT} tabIndex={-1} autoComplete="off" />
        </label>
      </p>

      <label className={LABEL}>
        {f.email}
        <input type="email" name="email" required autoComplete="email" className={INPUT} />
      </label>

      <label className={LABEL}>
        {f.company}
        {optional}
        <input type="text" name="company" autoComplete="organization" className={INPUT} />
      </label>

      {country === null ? (
        <label className={LABEL}>
          {f.country}
          <select name="country" required defaultValue="" className={INPUT}>
            <option value="" disabled>
              {f.countryChoose}
            </option>
            {data.regions.map((region) => (
              <optgroup key={region.code} label={regionName(region, strings)}>
                {region.countries.map((pack) => (
                  <option key={pack.slug} value={pack.country}>
                    {pack.name}
                  </option>
                ))}
              </optgroup>
            ))}
            <option value="other">{f.countryOther}</option>
          </select>
        </label>
      ) : (
        <div>
          <input type="hidden" name="country" value={country.code} />
          <p className="text-sm font-medium text-ink">{f.country}</p>
          <p className="mt-1.5 flex flex-wrap items-baseline gap-x-3 text-ink">
            {country.name}
            <a href={SIGNUP} className="text-sm">
              {f.countryChange}
            </a>
          </p>
        </div>
      )}

      <fieldset>
        <legend className={LABEL}>{f.profile}</legend>
        <div className="mt-2 space-y-2">
          {PROFILES.map((profile, index) => (
            <label key={profile} className="flex items-center gap-3 text-ink-soft">
              <input
                type="radio"
                name="profile"
                value={profile}
                required={index === 0}
                className="h-4 w-4 accent-brand"
              />
              {f.profiles[profile]}
            </label>
          ))}
        </div>
      </fieldset>

      <label className={LABEL}>
        {f.message}
        {optional}
        <textarea name="message" rows={4} className={INPUT} />
      </label>

      <label className="flex items-start gap-3 text-sm text-ink-soft">
        <input type="checkbox" name="consent" value="yes" required className="mt-0.5 h-4 w-4 shrink-0 accent-brand" />
        {f.consent}
      </label>

      <button
        type="submit"
        className="inline-flex cursor-pointer items-center gap-2 rounded-pill bg-brand-solid px-5 py-2.5 font-medium text-brand-on transition-colors duration-150 hover:bg-brand-muted"
      >
        {f.submit}
      </button>

      <p className="border-t border-line pt-5 text-xs leading-relaxed text-ink-faint">
        {strings.setup.privacy}
      </p>
    </form>
  );
}

/** Where a sent form lands. */
export function Thanks({ data, strings }: { data: SiteData; strings: Strings }): ReactNode {
  const s = strings.setup;
  return (
    <>
      <Masthead measure="reading" strings={strings} data={data} />
      <main className="mx-auto max-w-reading px-5 pt-16 pb-4 sm:pt-24">
        <span className="inline-flex h-11 w-11 items-center justify-center rounded bg-brand-fill text-brand-deep">
          <Glyph name="check" className="h-5 w-5" />
        </span>
        <h1 className="mt-6 text-[clamp(2rem,1.5rem+2.4vw,3rem)]">{s.thanksHeading}</h1>
        <p className="mt-5 text-lg text-ink-soft">{s.thanksBody}</p>
        <div className="mt-9 flex flex-wrap gap-3">
          <Action href="/docs/install/">{s.thanksDocs}</Action>
          <a href="/" className="inline-flex items-center px-2 py-2.5">
            {s.thanksHome}
          </a>
        </div>
      </main>
      <Footer repository={data.repository} measure="reading" strings={strings} />
    </>
  );
}
