/**
 * The decision records of `docs/decisions/` say what holds, not when it came
 * to hold.
 *
 * Each record is a rule, written so that a contributor can argue with its
 * reason. The history of how a rule was reached — the day it was written, what
 * a run turned up on the way — belongs to the changelog and to git, and a
 * record that starts collecting it becomes a diary nobody can cite. So this
 * reads every record and refuses a date in a heading, a word that only a
 * narrative needs, and a record missing a part of the template. It also holds
 * the index to the files: every record listed once, every number used once.
 */

import { readdirSync, readFileSync } from 'node:fs';
import { join } from 'node:path';
import { describe, expect, it } from 'vitest';
import { repoRoot } from './helpers/db.js';

const DIR = join(repoRoot, 'docs', 'decisions');
const RECORD = /^(\d{4})-[a-z0-9-]+\.md$/;

const MONTHS =
  'January|February|March|April|May|June|July|August|September|October|November|December';
/** "12 September 2026", "September 2026", or "2026-09-12". */
const DATE = new RegExp(`\\b(\\d{1,2} )?(${MONTHS}) \\d{4}\\b|\\b\\d{4}-\\d{2}-\\d{2}\\b`);
/** Words a rule never needs and a story always does. */
const NARRATIVE = /\bincidents?\b|private repo/i;

const records = readdirSync(DIR)
  .filter((name) => RECORD.test(name))
  .sort();
const text = (name: string) => readFileSync(join(DIR, name), 'utf8');

describe('the decision records', () => {
  it('exist, numbered from 0001 with no gap and no repeat', () => {
    expect(records.length).toBeGreaterThan(0);
    const numbers = records.map((name) => Number(RECORD.exec(name)?.[1]));
    expect(numbers).toEqual(numbers.map((_, i) => i + 1));
  });

  it.each(records)('%s carries no date in a heading', (name) => {
    const dated = text(name)
      .split('\n')
      .filter((line) => line.startsWith('#') && DATE.test(line));
    expect(dated).toEqual([]);
  });

  it.each(records)('%s tells no story', (name) => {
    const lines = text(name)
      .split('\n')
      .filter((line) => NARRATIVE.test(line));
    expect(lines).toEqual([]);
  });

  it.each(records)('%s follows the template', (name) => {
    const body = text(name);
    expect(body.split('\n')[0]).toMatch(/^# \S/);
    expect(body).toMatch(/^> Status: (accepted|superseded by \d{4})$/m);
    for (const part of ['## Context', '## Decision', '## Consequences', '## See also']) {
      expect(body, `${name} has no "${part}"`).toContain(`\n${part}\n`);
    }
  });

  it('are each listed once in the index, and the index lists nothing else', () => {
    const index = readFileSync(join(DIR, 'README.md'), 'utf8');
    const linked = [...index.matchAll(/\]\((\d{4}-[a-z0-9-]+\.md)\)/g)].map((match) => match[1]);
    expect([...linked].sort()).toEqual(records);
  });
});
