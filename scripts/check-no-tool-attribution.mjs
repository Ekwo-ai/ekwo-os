#!/usr/bin/env node
/**
 * Refuses a commit message that credits the tool it was written with.
 *
 * Commits are made in the name of the project. A coding assistant tends to
 * sign its work — a co-author trailer, a session link, a "generated with"
 * line — and those lines say nothing about the change: they name a tool, and
 * once a commit is published they stay in the history for good. Six of them
 * reached `main` on 14 October 2026 and were released in v0.13.0.
 *
 * Run with `npm run check:no-tool-attribution`; the CI's *hygiene* job runs it
 * on every push and every pull request.
 *
 * **Every commit reachable from HEAD is read**, not only the new ones: the
 * hygiene job checks out the full history, and a range computed from the
 * event (the base of a pull request, the commit before a push) is one more
 * thing that can be wrong. The history is a few thousand messages and reads
 * in well under a second.
 *
 * **The commits published before the rule are listed below, frozen.** A
 * released commit is never rewritten: it is in clones and tags this
 * repository does not control. The list only ever shrinks to nothing; it
 * never grows.
 */

import { execFile } from 'node:child_process';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { promisify } from 'node:util';

const run = promisify(execFile);
const root = join(dirname(fileURLToPath(import.meta.url)), '..');

/** Commits on `main` before the rule, released in v0.13.0. */
const PUBLISHED_BEFORE_THE_RULE = new Set([
  'e5c80d77f007fbe12c1cd68b64ebebc79d5f80e3',
  '79201e82f8d329f57049a4059517c66721811182',
  'dd9e69fc378c142238b8628d45b0b0115062070f',
  'ed65cc836b09ad5f29c787c19e13a897fb01747b',
  'd78ecba0191d0ca619683bb47a00147c0e750742',
  '244328fe9539f0fded7390a48df2e358a662485c',
]);

/** What a tool's signature looks like, and how it is told back. */
const SIGNATURES = [
  { pattern: /^co-authored-by:.*\b(claude|anthropic|copilot|cursor|codex|gemini|devin)\b/im, what: 'a co-author trailer naming a tool' },
  { pattern: /^claude-session:/im, what: 'a session trailer' },
  { pattern: /generated with \[?claude code/i, what: 'a "generated with" line' },
  { pattern: /claude\.ai\/code\/session_/i, what: 'a link to a coding session' },
];

const RECORD = '\x1e';
const FIELD = '\x00';

const { stdout } = await run('git', ['log', '--format=%H%x00%s%x00%B%x1e', 'HEAD'], {
  cwd: root,
  maxBuffer: 256 * 1024 * 1024,
});

const found = [];

for (const record of stdout.split(RECORD)) {
  const [hash, subject, body] = record.replace(/^\n/, '').split(FIELD);
  if (!hash || PUBLISHED_BEFORE_THE_RULE.has(hash)) continue;
  for (const { pattern, what } of SIGNATURES) {
    if (pattern.test(body ?? '')) found.push(`${hash.slice(0, 10)}  ${subject} — ${what}`);
  }
}

if (found.length > 0) {
  console.error('Commit messages that credit a tool:\n');
  for (const hit of found) console.error(`  ${hit}`);
  console.error(
    `\n${found.length} finding(s). Commits are made in the name of the project:\n` +
      '  reword the commit (git commit --amend, or git rebase for an older one)\n' +
      '  and drop the line before the branch is merged.',
  );
  process.exit(1);
}

console.log('No commit message credits a tool.');
