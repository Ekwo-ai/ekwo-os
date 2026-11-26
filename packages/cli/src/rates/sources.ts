/**
 * Where `ekwo rates fetch` reads published exchange rates.
 *
 * A source is one small module behind this interface: its name, the currency
 * it quotes against, and a function that reads the rates it published for a
 * day. The command turns those quotes into rows of `currency_rates` against
 * the instance reference currency; a source knows nothing of the database.
 * Another series — a national central bank, a commercial provider — is one
 * more module and one more line in `RATE_SOURCES`, and nothing else changes.
 */

import { ecb } from './ecb.js';

/** The rates a source published for one day. */
export interface PublishedRates {
  /** The day the rates are the rates of, `YYYY-MM-DD`. */
  date: string;
  /**
   * Units of each currency for one unit of the source's base, as the decimal
   * text the source published. Empty when the source published nothing for
   * that day — a weekend, a holiday, a day not yet published.
   */
  rates: Record<string, string>;
}

export interface RateSource {
  /** What `--source` takes, and what `currency_rates.source` says. */
  name: string;
  /** Who publishes the series, for a person reading the output. */
  publisher: string;
  /** The ISO 4217 currency every quote of the series is against. */
  base: string;
  /** Where the publisher states the terms of reuse of the series. */
  terms: string;
  /**
   * The rates of `date`, or of the latest day published when `date` is
   * undefined. Throws when the series cannot be read; answers empty `rates`
   * when it was read and has nothing for that day.
   */
  fetch(date: string | undefined, fetchImpl: typeof globalThis.fetch): Promise<PublishedRates>;
}

/** The sources by name. The first is the one `--source` defaults to. */
export const RATE_SOURCES: Record<string, RateSource> = {
  [ecb.name]: ecb,
};
