/**
 * No accounting on this side of the database.
 *
 * The epic's first invariant is that the command line holds no rule: a figure
 * that exists in a display only is a bug. A test cannot prove the absence of
 * a rule, but it can prove the absence of the means — the commands, and the
 * file they share, never turn an amount into a number, so they cannot add,
 * compare or round one. Amounts go to the core and to the database as the
 * text the caller typed and come back as the text the database holds.
 *
 * The second half pins the other invariant: a bookkeeping verb reaches the
 * database through a function of `@ekwo-ai/core`, the one the MCP server
 * calls, and never through a query of its own.
 */

import { readFile, readdir } from 'node:fs/promises';
import { join } from 'node:path';
import { describe, expect, it } from 'vitest';
import { repoRoot } from '../helpers/db.js';

const src = join(repoRoot, 'packages', 'cli', 'src');
const BOOKKEEPING = ['contact.ts', 'document.ts', 'payment.ts'];

/** Code without its comments: the prose is allowed to say "round". */
function code(text: string): string {
  return text.replace(/\/\*[\s\S]*?\*\//g, '').replace(/^\s*\/\/.*$/gm, '');
}

const ARITHMETIC = [
  /\bparseFloat\b/,
  /\bparseInt\b/,
  /\bNumber\s*\(/,
  /\bBigInt\b/,
  /\.toFixed\s*\(/,
  /\bMath\./,
  /\broundCurrency\b/,
  // A sum, a difference, a product or a quotient of something called an amount.
  /\b\w*(amount|price|total|debit|credit|residual|balance|rate|tax)\w*\s*(\+|-|\*|\/)=?\s*[\w(]/i,
  /[\w)]\s*(\+|-|\*|\/)\s*\w*(amount|price|total|debit|credit|residual|balance)\b/i,
];

describe('packages/cli/src/commands', () => {
  it('computes no amount, in any command', async () => {
    const files = (await readdir(join(src, 'commands'))).filter((file) => file.endsWith('.ts'));
    expect(files).toEqual(expect.arrayContaining(BOOKKEEPING));
    for (const file of [...files.map((f) => join('commands', f)), 'books.ts']) {
      const text = code(await readFile(join(src, file), 'utf8'));
      for (const pattern of ARITHMETIC) {
        const hit = pattern.exec(text);
        expect(hit?.[0], `${file} matches ${String(pattern)}`).toBeUndefined();
      }
    }
  });

  it('keeps books through the core, never through a query of its own', async () => {
    for (const file of BOOKKEEPING) {
      const text = code(await readFile(join(src, 'commands', file), 'utf8'));
      expect(text, file).toContain("from '@ekwo-ai/core'");
      // No table is read or written here, and no function of the schema is
      // called by name: that is what the core's functions are for.
      for (const direct of [/backend\s*\.\s*(select|insert|update|remove|rpc|rpcVoid)\s*[(<]/, /\.rpc\s*[(<]/, /\bfetch\s*\(/]) {
        expect(direct.exec(text)?.[0], `${file} matches ${String(direct)}`).toBeUndefined();
      }
    }
  });
});
