/**
 * The bank statement formats a reader exists for.
 *
 * A pack names the formats the banks of its country send — `coda` and
 * `camt.053` in one, `mt940` and `ofx` in another — and naming one is a
 * statement about the country, never about this repository. Whether a file of
 * that format can be *read* is the other question, and it has exactly one
 * answer: the bricks of `packages/formats/` that parse a statement.
 *
 * It lives in the core because three callers ask it and none of them owns it.
 * `@ekwo-ai/mcp` offers `import_bank_statement` for these and refuses the
 * rest; `tests/bank_statement_formats.test.ts` holds the ledger of what is
 * named and not yet read; and `describePack()` of the command line answers, per
 * format a pack names, read or not yet. A second list would be a second truth,
 * and the one that drifted would be the one nobody ran.
 *
 * A format is added here the day a brick reads it, not the day a pack mentions
 * it — the test above is what keeps the two from being confused.
 */

/** The statement formats a brick of this repository can read. */
export const STATEMENT_FORMATS = ['camt.053', 'coda', 'cfonb120'] as const;

/** One of the formats above. */
export type StatementFormat = (typeof STATEMENT_FORMATS)[number];
