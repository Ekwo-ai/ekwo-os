# Books at volume

How the schema behaves when there is something in it, how that is checked, and
what is still to be measured.

Most of `tests/` books a handful of documents, and Postgres plans a handful of
rows the same way whatever the indexes are. `tests/load/` fills an instance
with several companies and years of books, and checks that the reads people
rely on stay fast as the books grow.

## What runs, and where

| | `tests/load/load.test.ts` | `scripts/e2e-supabase.mjs` with `EKWO_E2E_LOAD_DOCUMENTS` |
|---|---|---|
| Engine | PGlite — Postgres 17 compiled to WebAssembly | a real, throwaway Supabase project |
| Runs | on every push, with the rest of `npm test` | by hand, before a release |
| Asserts | **the shape of the query plans** | nothing about time; a path over budget is reported `OVER` |

Both read the same definitions: `scripts/load/books.mjs` makes the books and
`scripts/load/hot-paths.mjs` defines the reads and their budgets.

**The plan is the assertion, the clock is a report.** A time measured on a
shared CI runner is noise, and a build that fails on noise is a build people
learn to re-run. The shape of a plan over deterministic data is stable, and it
is what matters: a report that starts reading a whole table costs what the
instance holds instead of what the question asks. The tests therefore say *no
sequential scan of a large table*, never *this exact index is used*, and they
pass unchanged across packs with very different charts.
[Decision 0060](decisions/0060-the-plan-is-the-assertion-the-clock-is-a-report.md)
has the reasoning.

## The books

Several companies, each with the same number of documents spread over five
financial years, 500 contacts, and a month of bank statement for the company
under test. The template year is posted by the engine itself from a country
pack's golden scenario, then copied to reach the volume, and the copy is
checked afterwards for balance and referential integrity. The data is
deterministic and contains no real names; the pack is a parameter,
`EKWO_LOAD_PACK`.

## The six paths

| Path | Call | Budget |
|---|---|---|
| General ledger of one account over a year | `general_ledger()` | 500 ms |
| Trial balance of a year | `trial_balance()` | 1 s |
| Aged receivables at year end | `aged_balance()` | 1 s |
| Tax return of one period | `vat_return()` | 1 s |
| Entries file of a whole year | `fec_lines()` | 5 s |
| Contact suggestions over a month of statement | `suggest_contacts()` | 5 s |

Each is called the way a client calls it, once as the database owner and once
as a signed-in member, so row level security is part of what is measured.

## Running it

```sh
npm test -- tests/load                      # 5 companies × 10 000 documents, as the CI does
EKWO_LOAD_PACK=us npm test -- tests/load    # another pack
EKWO_LOAD_DOCUMENTS=100000 EKWO_LOAD_COMPANIES=2 \
  EKWO_LOAD_REPORT=load-report.json npm test -- tests/load
```

The default takes about fifteen seconds on a laptop. The run prints one line
per path and caller, and writes a JSON report (`ekwo-load-report/1`) to
`EKWO_LOAD_REPORT` when that names a file: rows read, time, budget, and how
each large table was reached.

## Where it stands

All six paths reach the large tables through an index, as the owner and as a
member, and row level security costs a bounded number of capability checks per
statement rather than one per row. Each of these is asserted, so a regression
fails the build.

Still to be measured:

- **Times on a real Postgres.** Every time above comes from PGlite: the ratios
  are informative, the absolute figures are not what a hosted project shows.
- **The API layer** — the pooler, PostgREST and JSON serialisation.
- **Sustained writes**: bulk posting, imports and the close of a large year.
- **Many companies rather than large ones**, at the scale of a firm with
  hundreds of clients.
