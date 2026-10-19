/**
 * The offer of a free Ekwo Cloud account, as the command line gives it.
 *
 * One line after `init` and after a first `company export`, each at most once
 * for a person, remembered in their configuration directory and nowhere else.
 * Never under `--json`, never outside a terminal, never in CI, and never again
 * once `EKWO_NO_CLOUD_OFFER` is set or `settings.json` says no.
 */

import { mkdir, mkdtemp, readFile, rm, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { afterEach, beforeEach, describe, expect, it } from 'vitest';
import {
  CLOUD_OFFER_ENV,
  CLOUD_OFFER_GIVES,
  CLOUD_SIGNUP_URL,
  cloudOfferLine,
  cloudOfferSilenced,
  cloudSignupUrl,
  relayableCloudOffer,
} from '../../packages/core/src/index.js';
import { offerCloud, SETTINGS_FILE } from '../../packages/cli/src/cloud-offer.js';
import { setJsonMode } from '../../packages/cli/src/ui.js';

async function capture(fn: () => Promise<boolean>): Promise<{ shown: boolean; stdout: string; stderr: string }> {
  const out = process.stdout.write.bind(process.stdout);
  const err = process.stderr.write.bind(process.stderr);
  let stdout = '';
  let stderr = '';
  process.stdout.write = ((chunk: string | Uint8Array) => {
    stdout += String(chunk);
    return true;
  }) as typeof process.stdout.write;
  process.stderr.write = ((chunk: string | Uint8Array) => {
    stderr += String(chunk);
    return true;
  }) as typeof process.stderr.write;
  try {
    return { shown: await fn(), stdout, stderr };
  } finally {
    process.stdout.write = out;
    process.stderr.write = err;
  }
}

describe('the words, in one place', () => {
  it('link to the sign-up with where they were read', () => {
    expect(cloudSignupUrl('cli')).toBe(`${CLOUD_SIGNUP_URL}?src=cli`);
    expect(cloudSignupUrl('mcp')).toBe(`${CLOUD_SIGNUP_URL}?src=mcp`);
    expect(CLOUD_SIGNUP_URL).toBe('https://cloud.ekwo.ai/signup');
  });

  it('are one line, free, with every thing the plan gives', () => {
    for (const moment of ['install', 'backup'] as const) {
      const text = cloudOfferLine(moment, 'cli');
      expect(text).not.toContain('\n');
      expect(text).toContain('free Ekwo Cloud account');
      for (const given of CLOUD_OFFER_GIVES) expect(text).toContain(given);
      expect(text.endsWith(cloudSignupUrl('cli'))).toBe(true);
    }
    expect(cloudOfferLine('backup', 'cli')).toMatch(/^Rather not do this by hand\?/);
  });

  it('are relayed by an agent once, with how to end them', () => {
    const relayed = relayableCloudOffer();
    expect(relayed).toContain(cloudSignupUrl('mcp'));
    expect(relayed).not.toContain(cloudSignupUrl('cli'));
    expect(relayed).toContain('once');
    expect(relayed).toContain(`${CLOUD_OFFER_ENV}=1`);
  });

  it('are silenced by the variable, and in CI', () => {
    expect(cloudOfferSilenced({})).toBe(false);
    expect(cloudOfferSilenced({ [CLOUD_OFFER_ENV]: '1' })).toBe(true);
    expect(cloudOfferSilenced({ [CLOUD_OFFER_ENV]: 'yes' })).toBe(true);
    expect(cloudOfferSilenced({ [CLOUD_OFFER_ENV]: '0' })).toBe(false);
    expect(cloudOfferSilenced({ [CLOUD_OFFER_ENV]: 'false' })).toBe(false);
    expect(cloudOfferSilenced({ CI: 'true' })).toBe(true);
    expect(cloudOfferSilenced({ CI: '' })).toBe(false);
  });
});

describe('on a terminal', () => {
  let dir: string;
  const env: NodeJS.ProcessEnv = {};
  const offer = (moment: 'install' | 'backup', extra: { env?: NodeJS.ProcessEnv; interactive?: boolean } = {}) =>
    capture(() => offerCloud(moment, { env: extra.env ?? env, interactive: extra.interactive ?? true, dir }));

  beforeEach(async () => {
    dir = await mkdtemp(join(tmpdir(), 'ekwo-cloud-offer-'));
    setJsonMode(false);
  });

  afterEach(async () => {
    setJsonMode(false);
    await rm(dir, { recursive: true, force: true });
  });

  it('is shown once per moment, and remembered in the configuration directory', async () => {
    const first = await offer('install');
    expect(first.shown).toBe(true);
    expect(first.stdout).toContain(cloudSignupUrl('cli'));
    expect(first.stdout.trim().split('\n')).toHaveLength(1);

    const again = await offer('install');
    expect(again.shown).toBe(false);
    expect(again.stdout).toBe('');

    // Another moment is its own.
    const backup = await offer('backup');
    expect(backup.shown).toBe(true);
    expect(backup.stdout).toContain('Rather not do this by hand?');
    expect((await offer('backup')).shown).toBe(false);

    const settings = JSON.parse(await readFile(join(dir, SETTINGS_FILE), 'utf8')) as {
      cloud_offer_shown: Record<string, string>;
    };
    expect(Object.keys(settings.cloud_offer_shown).sort()).toEqual(['backup', 'install']);
  });

  it('keeps what else the settings file says', async () => {
    await writeFile(join(dir, SETTINGS_FILE), JSON.stringify({ other: 'kept' }), 'utf8');
    expect((await offer('install')).shown).toBe(true);
    const settings = JSON.parse(await readFile(join(dir, SETTINGS_FILE), 'utf8')) as Record<string, unknown>;
    expect(settings['other']).toBe('kept');
  });

  it('is never shown when the variable is set', async () => {
    const result = await offer('install', { env: { [CLOUD_OFFER_ENV]: '1' } });
    expect(result).toEqual({ shown: false, stdout: '', stderr: '' });
  });

  it('is never shown once the settings file says no', async () => {
    await writeFile(join(dir, SETTINGS_FILE), JSON.stringify({ cloud_offer: false }), 'utf8');
    expect((await offer('install')).shown).toBe(false);
    expect((await offer('backup')).shown).toBe(false);
  });

  it('is silent under --json, outside a terminal and in CI, and remembers nothing then', async () => {
    setJsonMode(true);
    expect(await offer('install')).toEqual({ shown: false, stdout: '', stderr: '' });
    setJsonMode(false);

    expect(await offer('install', { interactive: false })).toEqual({ shown: false, stdout: '', stderr: '' });
    expect(await offer('install', { env: { CI: 'true' } })).toEqual({ shown: false, stdout: '', stderr: '' });

    // Nothing was written, so the first time a person reads, they see it.
    await expect(readFile(join(dir, SETTINGS_FILE), 'utf8')).rejects.toThrow();
    expect((await offer('install')).shown).toBe(true);
  });

  it('says nothing when it could not remember having said it', async () => {
    // A configuration directory inside a repository is refused for writing.
    const repository = join(dir, 'repo');
    await mkdir(join(repository, '.git'), { recursive: true });
    const result = await capture(() => offerCloud('install', { env, interactive: true, dir: join(repository, 'conf') }));
    expect(result).toEqual({ shown: false, stdout: '', stderr: '' });
  });
});
