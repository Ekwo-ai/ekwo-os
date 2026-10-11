import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';
import {
  checkTrustedPublishing,
  githubOidcExchange,
  readPublished,
  // @ts-expect-error — a plain script of the repository, with no types of its own
} from '../scripts/check-trusted-publishing.mjs';

/**
 * The release check reads npm through `npm view`; here npm is replaced by the
 * answers it gives, so the tests never reach the registry.
 */

const attested = (version: string) =>
  JSON.stringify({
    version,
    'dist.attestations': {
      url: `https://registry.npmjs.org/-/npm/v1/attestations/x@${version}`,
      provenance: { predicateType: 'https://slsa.dev/provenance/v1' },
    },
  });

const notFound = () => {
  const error = new Error('Command failed: npm view') as Error & { stderr: string };
  error.stderr = 'npm error code E404\nnpm error 404 Not Found - GET https://registry.npmjs.org/@ekwo-ai%2fnew';
  throw error;
};

/** A fake `npm view`: the answer for each package name, or a thrower. */
function npm(answers: Record<string, string | (() => never)>) {
  return (args: string[]) => {
    const answer = answers[args[0] as string];
    if (answer === undefined) throw new Error(`unexpected npm view ${args.join(' ')}`);
    return typeof answer === 'function' ? answer() : answer;
  };
}

describe('what npm says of a package', () => {
  it('reads the latest version and its provenance attestation', () => {
    expect(readPublished('@ekwo-ai/core', npm({ '@ekwo-ai/core': attested('0.12.1') }))).toEqual({
      version: '0.12.1',
      attested: true,
    });
  });

  it('reads a version published without an attestation, which npm answers as a bare value', () => {
    expect(readPublished('@ekwo-ai/invoice-pdf', npm({ '@ekwo-ai/invoice-pdf': '"0.12.1"\n' }))).toEqual({
      version: '0.12.1',
      attested: false,
    });
  });

  it('says a package npm has never heard of was never published', () => {
    expect(readPublished('@ekwo-ai/new', npm({ '@ekwo-ai/new': notFound }))).toBeNull();
  });

  it('does not mistake npm being unreachable for a package never published', () => {
    const offline = () => {
      throw Object.assign(new Error('Command failed'), { stderr: 'npm error code ENOTFOUND' });
    };
    expect(() => readPublished('@ekwo-ai/core', npm({ '@ekwo-ai/core': offline }))).toThrow(
      /npm could not be asked about @ekwo-ai\/core: .*ENOTFOUND/,
    );
  });
});

describe('the release check', () => {
  it('passes when the latest version of every package carries an attestation', async () => {
    const { refused, lines } = await checkTrustedPublishing(['@ekwo-ai/core', 'ekwo-os'], {
      view: npm({ '@ekwo-ai/core': attested('0.12.1'), 'ekwo-os': attested('0.12.1') }),
    });
    expect(refused).toEqual([]);
    expect(lines).toEqual([
      '✓ @ekwo-ai/core@0.12.1 carries a provenance attestation',
      '✓ ekwo-os@0.12.1 carries a provenance attestation',
    ]);
  });

  it('names a package published without an attestation, and says where to add its trusted publisher', async () => {
    const { refused, lines } = await checkTrustedPublishing(['@ekwo-ai/core', '@ekwo-ai/invoice-pdf'], {
      view: npm({ '@ekwo-ai/core': attested('0.12.1'), '@ekwo-ai/invoice-pdf': '"0.12.1"' }),
    });
    expect(refused).toEqual(['@ekwo-ai/invoice-pdf']);
    expect(lines[1]).toMatch(/^✗ @ekwo-ai\/invoice-pdf@0\.12\.1, its latest version on npm, carries no provenance/);
    expect(lines[1]).toContain('https://www.npmjs.com/package/@ekwo-ai/invoice-pdf/access');
    expect(lines[1]).toContain('GitHub Actions, repository Ekwo-ai/ekwo-os, workflow release.yml, no environment');
  });

  it('names a package never published, and says to publish it once by hand first', async () => {
    const { refused, lines } = await checkTrustedPublishing(['@ekwo-ai/new'], {
      view: npm({ '@ekwo-ai/new': notFound }),
    });
    expect(refused).toEqual(['@ekwo-ai/new']);
    expect(lines[0]).toMatch(/^✗ @ekwo-ai\/new has never been published: publish it once by hand/);
    expect(lines[0]).toContain('https://www.npmjs.com/package/@ekwo-ai/new/access');
  });

  it('inside the workflow, lets a package through when npm grants the run a publish credential for it', async () => {
    const asked: string[] = [];
    const { refused, lines } = await checkTrustedPublishing(['@ekwo-ai/core', '@ekwo-ai/invoice-pdf'], {
      view: npm({ '@ekwo-ai/core': attested('0.12.1'), '@ekwo-ai/invoice-pdf': '"0.12.1"' }),
      exchange: async (name: string) => (asked.push(name), true),
    });
    expect(refused).toEqual([]);
    // Only the package without an attestation is asked about.
    expect(asked).toEqual(['@ekwo-ai/invoice-pdf']);
    expect(lines[1]).toMatch(/grants this workflow a publish credential/);
  });

  it('inside the workflow, still refuses a package npm refuses the run a credential for', async () => {
    const { refused, lines } = await checkTrustedPublishing(['@ekwo-ai/invoice-pdf'], {
      view: npm({ '@ekwo-ai/invoice-pdf': '"0.12.1"' }),
      exchange: async () => false,
    });
    expect(refused).toEqual(['@ekwo-ai/invoice-pdf']);
    expect(lines[0]).toMatch(/npm refuses this workflow a publish credential for it/);
  });

  it('never lets a package never published through, workflow or not', async () => {
    const { refused } = await checkTrustedPublishing(['@ekwo-ai/new'], {
      view: npm({ '@ekwo-ai/new': notFound }),
      exchange: async () => true,
    });
    expect(refused).toEqual(['@ekwo-ai/new']);
  });
});

describe('the credential exchange', () => {
  it('is not available outside a GitHub Actions job holding an OIDC identity', () => {
    expect(githubOidcExchange({})).toBeUndefined();
  });

  it('trades the run identity for a token scoped to the package, as npm publish does', async () => {
    const calls: { url: string; init: RequestInit | undefined }[] = [];
    const request = async (url: string, init?: RequestInit) => {
      calls.push({ url, init });
      if (url.startsWith('https://token.actions.example/')) {
        return new Response(JSON.stringify({ value: 'oidc-id-token' }));
      }
      return new Response(JSON.stringify({ token: 'short-lived' }));
    };
    const exchange = githubOidcExchange(
      { ACTIONS_ID_TOKEN_REQUEST_URL: 'https://token.actions.example/id?x=1', ACTIONS_ID_TOKEN_REQUEST_TOKEN: 'run' },
      request,
    );
    expect(await exchange('@ekwo-ai/invoice-pdf')).toBe(true);
    expect(calls[0]?.url).toBe('https://token.actions.example/id?x=1&audience=npm%3Aregistry.npmjs.org');
    expect(calls[1]?.url).toBe(
      'https://registry.npmjs.org/-/npm/v1/oidc/token/exchange/package/@ekwo-ai%2finvoice-pdf',
    );
    expect(calls[1]?.init?.method).toBe('POST');
    expect((calls[1]?.init?.headers as Record<string, string>).Authorization).toBe('Bearer oidc-id-token');
  });

  it('answers no when npm refuses the exchange', async () => {
    const request = async (url: string) =>
      url.includes('oidc/token/exchange')
        ? new Response('{"message":"no trusted publisher"}', { status: 404 })
        : new Response(JSON.stringify({ value: 'oidc-id-token' }));
    const exchange = githubOidcExchange(
      { ACTIONS_ID_TOKEN_REQUEST_URL: 'https://token.actions.example/id', ACTIONS_ID_TOKEN_REQUEST_TOKEN: 'run' },
      request,
    );
    expect(await exchange('@ekwo-ai/invoice-pdf')).toBe(false);
  });
});

describe('where the check runs', () => {
  it('runs in the Release workflow before anything is built or published', () => {
    const workflow = readFileSync(new URL('../.github/workflows/release.yml', import.meta.url), 'utf8');
    const check = workflow.indexOf('npm run release:check');
    expect(check).toBeGreaterThan(-1);
    expect(check).toBeLessThan(workflow.indexOf('npm run build'));
    expect(check).toBeLessThan(workflow.indexOf('npm run release:publish'));
  });

  it('is a step of docs/releasing.md', () => {
    const doc = readFileSync(new URL('../docs/releasing.md', import.meta.url), 'utf8');
    expect(doc).toContain('npm run release:check');
  });
});
