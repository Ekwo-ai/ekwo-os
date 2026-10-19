/**
 * The offer of a free Ekwo Cloud account, as this command line prints it.
 *
 * The words and the link are `@ekwo-ai/core`'s, where the MCP server reads
 * them too. This file decides when a terminal sees them: one line, after an
 * `init` that succeeded and after a first `company export`, each at most once
 * for this person, never followed by a question.
 *
 * Silent under `--json`, when the standard output is not a terminal, in
 * continuous integration (`CI`), when `EKWO_NO_CLOUD_OFFER` is set, and for
 * good once `settings.json` in the configuration directory says
 * `"cloud_offer": false`. That file is where the moments already shown are
 * remembered — a person's file, beside their profiles, not `ekwo.json`, which
 * describes an installation and is meant to be committed. Nothing is sent
 * anywhere to show the offer or to remember it.
 *
 * The moment is written down before the line is printed: a configuration
 * directory that cannot be written means no offer, rather than the same offer
 * at every run.
 */

import { join } from 'node:path';
import { cloudOfferLine, cloudOfferSilenced, type CloudOfferMoment } from '@ekwo-ai/core';
import { configDir, readJson, writePrivate } from './profiles.js';
import { isJsonMode, line, note } from './ui.js';

export const SETTINGS_FILE = 'settings.json';

const SETTINGS_COMMENT =
  'Preferences of the ekwo command line for this person. "cloud_offer": false never shows the Ekwo Cloud offer again.';

export interface CloudOfferContext {
  env?: NodeJS.ProcessEnv;
  /** Whether a person is reading. Left out, whether the standard output is a terminal. */
  interactive?: boolean;
  /** Left out, the configuration directory the environment names. */
  dir?: string;
  now?: Date;
}

function record(value: unknown): Record<string, unknown> {
  return typeof value === 'object' && value !== null && !Array.isArray(value) ? (value as Record<string, unknown>) : {};
}

/** Prints the offer for this moment when it is due; true when it was printed. */
export async function offerCloud(moment: CloudOfferMoment, context: CloudOfferContext = {}): Promise<boolean> {
  const env = context.env ?? process.env;
  if (isJsonMode()) return false;
  if (!(context.interactive ?? process.stdout.isTTY === true)) return false;
  if (cloudOfferSilenced(env)) return false;

  try {
    const dir = context.dir ?? configDir(env);
    const settings = record(await readJson(join(dir, SETTINGS_FILE)));
    if (settings['cloud_offer'] === false) return false;
    const shown = record(settings['cloud_offer_shown']);
    if (shown[moment] !== undefined) return false;
    await writePrivate(dir, SETTINGS_FILE, {
      ...settings,
      $comment: SETTINGS_COMMENT,
      cloud_offer_shown: { ...shown, [moment]: (context.now ?? new Date()).toISOString() },
    });
  } catch {
    // A courtesy never fails a command.
    return false;
  }

  line();
  note(cloudOfferLine(moment, 'cli'));
  return true;
}
