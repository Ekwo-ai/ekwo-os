/**
 * What a pack can say about filing a declaration, read off the pack itself.
 *
 * Five questions, and a pack answers each of them by carrying something or by
 * carrying nothing:
 *
 *   1. does it declare a periodic return at all, and with how many boxes;
 *   2. on what cadence;
 *   3. does it say **when** the return is due (a rule of the country: four
 *      packs do, one deliberately does not, one has not read the text);
 *   4. does it name the **file** the return is deposited as;
 *   5. does it name the **account** what the return owes lands on.
 *
 * This is a reading and never a judgement. It does not say whether a brick
 * exists for the format the pack names — that is what the end-to-end test
 * checks, by writing the file — and it holds no list of formats, because a
 * list here would be the second place a country model lives.
 *
 * It exists once so that `ekwo pack list` and the test that proves the whole
 * chain read the same five answers.
 */

import type { Pack } from './read.js';

export interface FilingReadiness {
  /** Number of periodic returns this pack declares. Zero, one, or more. */
  forms: number;
  /** The form's code, where there is exactly one. */
  code: string | null;
  /** How many boxes it carries. */
  boxes: number;
  /** The cadence the country proposes, or null where it depends on the company. */
  cadence: string | null;
  /**
   * True when the pack says when the return is due — as a rule that produces a
   * date, or as the statement that the day depends on the taxpayer.
   */
  deadline: boolean;
  /** The rule the pack states, or null where it states none. */
  deadlineRule: string | null;
  /** The format the return is deposited as, by the name of the brick. */
  fileFormat: string | null;
  /** The account role what a filed return owes lands on, where the pack names one. */
  taxPayable: string | null;
}

export function filingReadiness(pack: Pack): FilingReadiness {
  const report = pack.report;
  const roles = pack.manifest.defaults.roles;
  const payable = roles['tax_payable'];
  return {
    forms: report === null ? 0 : 1,
    code: report?.code ?? null,
    boxes: report?.boxes.length ?? 0,
    cadence: report?.period_default ?? null,
    deadline: report?.deadline != null,
    deadlineRule: report?.deadline?.rule ?? null,
    fileFormat: report?.file_format ?? null,
    taxPayable: typeof payable === 'string' ? payable : null,
  };
}

/**
 * The same five answers as one line, for a listing a person reads.
 *
 * Every "no" is printed rather than left out: a form with no deadline rule and
 * no file is the ordinary state of most packs, and a listing that showed only
 * what works would be a brochure.
 */
export function describeFiling(pack: Pack): string {
  const f = filingReadiness(pack);
  if (f.forms === 0) return 'filing — no periodic return declared';
  const parts = [
    `${f.code} (${f.boxes} boxes)`,
    f.cadence === null ? 'cadence: the company decides' : `cadence: ${f.cadence}`,
    !f.deadline
      ? 'deadline: not declared'
      : f.deadlineRule === 'depends_on_taxpayer'
        ? 'deadline: depends on the taxpayer'
        : 'deadline: in the pack',
    f.fileFormat === null ? 'file: none, filed on the portal' : `file: ${f.fileFormat}`,
    f.taxPayable === null ? 'settles to: no account named' : `settles to: ${f.taxPayable}`,
  ];
  return `filing — ${parts.join(' · ')}`;
}
