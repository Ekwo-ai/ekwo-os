/**
 * The languages this site is published in.
 *
 * One entry today. The list is what the prerender walks, and the **first entry
 * is the source**: it is published at the root — `/`, `/os/`, `/countries/…` —
 * and every other language would be published under its own prefix, `/<lang>/`,
 * with exactly the same tree beneath it.
 *
 * That is why the country pages live at `/countries/<cc>/` rather than at the
 * root. A two-letter segment there cannot be both a country and a language,
 * and the collision is not theoretical: most of the countries a European
 * ledger meets first have a code that is also the code of a language, so one
 * segment would have to mean the country and the site translated into its
 * language at the same time. The prefixes are kept free now, while moving a
 * page costs nothing.
 *
 * Adding a language is one file beside this one and one line in the list. No
 * language is written into the code anywhere else: `<html lang>` is the
 * rendered language's own `lang`, and a page's path is the language's prefix
 * unless it is the source.
 */

import { en } from './en.js';
import type { Strings } from './types.js';

export type { Strings } from './types.js';
export type { Section } from './types.js';

/**
 * Every language, source first.
 *
 * Adding one here publishes it, and the test beside it refuses a language
 * whose key set is not the source's: a half-translated site is worse than an
 * English one, because a reader cannot tell which half they are getting.
 */
export const LANGUAGES: Strings[] = [en];

/** The language a page is published in when nothing says otherwise. */
export const SOURCE: Strings = LANGUAGES[0] as Strings;

/**
 * Where a page of a language lives, relative to the site root.
 *
 * The source language has no prefix. Everything else is under its own, so a
 * translated tree mirrors the source exactly and `hreflang` is mechanical.
 */
export function prefixOf(strings: Strings): string {
  return strings === SOURCE ? '' : `${strings.lang}/`;
}

/** Fills `{name}` in a string with what the caller gives it. */
export function fill(template: string, values: Record<string, string | number>): string {
  return template.replace(/\{(\w+)\}/g, (whole, key: string) =>
    key in values ? String(values[key]) : whole,
  );
}
