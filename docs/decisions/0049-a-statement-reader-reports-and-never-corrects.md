# A statement reader reports and never corrects

> Status: accepted

## Context

Bank statements arrive as camt.053 (XML), CODA (128 fixed positions) or CFONB
120 (120 positions). Each reader must return what the file says, in a shape
the importer takes, and make a damaged file visible.

## Decision

**One brick per document, named after it.** `camt053`, `coda`, `cfonb120`.
Formats that look alike are two formats; camt.052 and camt.054 carry no closing
booked balance to check and are refused by name (`not_a_statement`). The
readers share no code and return the same fields under the same names, each in
its own `types.ts`.

**An account is not an IBAN.** `AccountIdentifier` is `{kind: 'iban', value}`
or `{kind: 'other', value, scheme, issuer}`, as ISO 20022 allows. IBAN check
digits are verified; a failure is a violation, returned as written.

**One line per transaction where it is provably the same money.** An entry with
several transactions is split only if each carries an amount in the entry's
currency and they add up exactly; each line then carries enough to rebuild the
batch. Otherwise the entry stays one line (`batch_not_split`). In both cases a
statement's lines sum to its movement. A total and its details are never both
counted.

**A statement that does not add up is reported, not refused and not
corrected.** The difference is named and `balanced` is false; the importer
refuses it. A reader that substituted a computed balance would erase the only
evidence of a truncated file.

**Exceptions are for files, violations for lines.** Thrown: what leaves no
statement to report on (not XML, bad encoding, over a limit, a record of the
wrong length — which shifts every later field — an unknown record). Returned:
anything about a line or a balance.

**The XML reader refuses more than it reads.** No DOCTYPE (so no entity
declarations: the entity-expansion and external-entity families are refused
outright), limits on size, depth and element count, fatal UTF-8, no recursion.

**An encoding is said, never guessed.** UTF-8 by default; ISO-8859-1 only when
the caller sets it (every byte sequence is valid ISO-8859-1, so a fallback
could never fail); EBCDIC refused.

**Dates are the day the bank wrote**, never shifted to UTC. **Amounts are
strings with the file's digits**; rounding to a currency is the importer's.

**A country is an argument, not a default.** A format that carries a
domestic account number returns an IBAN only when the caller names the
country.

**Unsupported versions are refused by name**, rather than read leniently into a
statement with no balances.

## Consequences

- Fixtures are invented (a real statement is somebody's account); which
  reference a given bank fills is unknown until real files are read. Each
  README lists what is *not verified*.
- MT940 is not read: its counterparty and remittance fields differ by bank with
  no single published layout, and a reader returning money without them would
  import lines reconciliation can never match.

## See also

- `packages/formats/camt053/`, `packages/formats/coda/`,
  `packages/formats/cfonb120/`
- `tests/camt053.test.ts`, `tests/coda_cfonb120.test.ts`
- [0047 A statement is imported once](0047-a-statement-is-imported-once.md)
