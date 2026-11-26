/**
 * The euro foreign exchange reference rates of the European Central Bank.
 *
 * Published at https://www.ecb.europa.eu/stats/policy_and_exchange_rates/euro_reference_exchange_rates/html/index.en.html
 * — "usually updated at around 16:00 CET every working day, except on TARGET
 * closing days", as units of each currency for one euro. Three files carry
 * the same XML: the latest day, the last 90 days, and every day since 1999.
 *
 * Terms: the ECB states that the reference rates "are published for
 * information purposes only" and that "using the rates for transaction
 * purposes is strongly discouraged"; information from its website may be
 * reproduced provided "it must appear accurately and the ECB must be cited as
 * the source" (https://www.ecb.europa.eu/home/disclaimer/html/index.en.html).
 * Every row this source writes says `ecb` in `currency_rates.source`.
 *
 * The format, as the files are served:
 *
 *   <gesmes:Envelope …><Cube>
 *     <Cube time='2026-11-26'>
 *       <Cube currency='USD' rate='1.0975'/> …
 *     </Cube> …
 *   </Cube></gesmes:Envelope>
 *
 * The daily file quotes its attributes with single quotes, the two others
 * with double quotes; both are read. The euro itself is never listed: it is
 * the base.
 */

import type { PublishedRates, RateSource } from './sources.js';

const FEED = 'https://www.ecb.europa.eu/stats/eurofxref';
export const ECB_DAILY = `${FEED}/eurofxref-daily.xml`;
export const ECB_90_DAYS = `${FEED}/eurofxref-hist-90d.xml`;
export const ECB_HISTORY = `${FEED}/eurofxref-hist.xml`;

/** Every day of a file, newest first as the ECB writes them. */
export function parseEcbXml(xml: string): PublishedRates[] {
  const days: PublishedRates[] = [];
  const day = /<Cube\s+time=["'](\d{4}-\d{2}-\d{2})["']\s*>([\s\S]*?)<\/Cube>/g;
  const quote = /<Cube\s+currency=["']([A-Z]{3})["']\s+rate=["'](\d+(?:\.\d+)?)["']\s*\/>/g;
  for (const match of xml.matchAll(day)) {
    const rates: Record<string, string> = {};
    for (const one of (match[2] ?? '').matchAll(quote)) rates[one[1] as string] = one[2] as string;
    days.push({ date: match[1] as string, rates });
  }
  if (days.length === 0) {
    throw new Error('rates_source_unreadable: the ECB file holds no day of rates; its format may have changed.');
  }
  return days;
}

async function read(url: string, fetchImpl: typeof globalThis.fetch): Promise<PublishedRates[]> {
  const response = await fetchImpl(url);
  if (!response.ok) {
    throw new Error(`rates_source_unreachable: ${url} answered ${response.status}.`);
  }
  return parseEcbXml(await response.text());
}

export const ecb: RateSource = {
  name: 'ecb',
  publisher: 'European Central Bank, euro foreign exchange reference rates',
  base: 'EUR',
  terms: 'https://www.ecb.europa.eu/home/disclaimer/html/index.en.html',
  async fetch(date, fetchImpl) {
    if (date === undefined) {
      const [latest] = await read(ECB_DAILY, fetchImpl);
      return latest as PublishedRates;
    }
    // The 90-day file first: a few dozen kilobytes against several megabytes.
    // A day older than its oldest is looked up in the whole history.
    let days = await read(ECB_90_DAYS, fetchImpl);
    const oldest = days[days.length - 1] as PublishedRates;
    if (date < oldest.date) days = await read(ECB_HISTORY, fetchImpl);
    return days.find((one) => one.date === date) ?? { date, rates: {} };
  },
};
