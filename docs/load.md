# Books at volume

What is known about how the schema behaves when there is something in it, how
it is known, and what is still a guess.

Everything else in `tests/` books a handful of documents; the largest golden
scenario holds fifteen. Postgres plans fifteen rows the same way whatever the
indexes are, so until `tests/load/` existed the 173 indexes of the schema had
been declared, guarded against omission by `tests/schema.test.ts`, and never
once observed being used.

## What runs, and where

| | `tests/load/load.test.ts` | `scripts/e2e-supabase.mjs` with `EKWO_E2E_LOAD_DOCUMENTS` |
|---|---|---|
| Engine | PGlite — Postgres 17 compiled to WebAssembly | a real, throwaway Supabase project |
| Runs | on every push, with the rest of `npm test` | by hand, before a release |
| Asserts | **the shape of the plans** | nothing about time; a path over budget is reported `OVER` |
| Reports | times, rows read, how each large table was reached | times as the owner over SQL and as a member over PostgREST |
| Status | running | **written, never run** — it needs a project nobody minds losing |

Both read the same two files: `scripts/load/books.mjs`, which makes the books,
and `scripts/load/hot-paths.mjs`, which defines the six reads and their
budgets. Two runs that measured two different things could not be compared.

**Why the plan and not the clock.** A time measured on a shared CI runner is
noise with a trend in it, and a build that fails on noise is a build people
learn to re-run. The shape of a plan over deterministic data is stable and it
is the thing that matters: a report that starts walking `entry_lines` from end
to end costs what the instance holds instead of what the question asks, and it
does so silently, one release at a time.

**Why "does not appear".** The assertions say *no sequential scan of a large
table*, never *this index is used*. Which of two good indexes the planner
prefers depends on statistics and cost constants, and is its business. The
load test passes unchanged on every pack it was tried on — `be`, `ee`, `gb`,
`us` — with different charts, different numbers of ledger lines and therefore
different statistics, which is the evidence that the assertions are not pinned
to one lucky plan.

## The books

An instance of several companies, each holding the same number of documents
spread over five financial years, 500 contacts, and — for the company under
test — one month of bank statement.

Several companies, because a plan is only a question when the predicate is
selective. In an instance of one company `company_id = $1` keeps every row,
and a sequential scan of `entry_lines` is then the *right* plan for a trial
balance; a test that forbade it would be forbidding the planner to be correct.

**The template is posted by the engine; the volume is the template, copied.**
Each company is installed from a pack and books that pack's golden year
through `post_document()`, `post_payment()` and `reconcile()`. Those rows are
then cloned — new identifiers, dates moved back by whole financial years, the
length of a year read from the template so that a 52-week year stays one — under
`session_replication_role = replica`, which is how a bulk load is done.

Posting every document through the engine was the other option and was
measured: about seven milliseconds a document on PGlite, so more than a minute
for 10 000 and a quarter of an hour for 100 000, before the first plan is
read. Inserting invented ledger rows was the third, and proves nothing: they
balance because the generator says so. A copy of what the engine wrote carries
the boxes, the tax point, the maturity and the matching the engine gave its
original, and inherits whatever the engine starts writing tomorrow — the list
of columns is read from the catalogue.

What the copy skips — triggers and foreign keys — is asked afterwards:
`checkCoherence()` re-checks every foreign key of the copied tables with an
anti-join and every entry for balance, and the test then books one more
document into the loaded company through `post_document()`.

**Deterministic.** The same seed over the same template gives the same names,
dates, amounts and numbers; a test builds two databases to say so. Identifiers
derive from the template's, which `gen_random_uuid()` chose, so they are stable
within a database and not across two.

**No real data, and no country.** Contact names are syllables from a seeded
generator. The pack is a parameter, `EKWO_LOAD_PACK`; left out it is the first
pack that carries a golden scenario.

**`analyze` comes first.** The load ends with it and a test checks that every
large table has statistics and that the planner's row estimate of `entry_lines`
is within a tenth of the truth. A plan read without statistics is the plan of
an assumption.

## The six paths

| Path | Call | Budget |
|---|---|---|
| General ledger of one account over a year | `general_ledger()`, the busiest account of the company | 500 ms |
| Trial balance of a year | `trial_balance()` | 1 s |
| Aged receivables at year end | `aged_balance()` | 1 s |
| Tax return of one period | `vat_return()`, the first period of the golden | 1 s |
| Entries file of a whole year | `fec_lines()` | 5 s |
| Contact suggestions over a month of statement | `suggest_contacts()` on every line | 5 s |

Each is called through the function, the way a client calls it, once as the
owner of the database and once as a signed-in member with `set role
authenticated` — row level security is part of the path for everybody who is
not the installer.

The queries that matter are inside plpgsql bodies, where `EXPLAIN` sees a
function scan and nothing else. They are read with `auto_explain` and
`log_nested_statements`, which reports the plan the executor really used for
the parameters it really got, sent to the client as notices. The collector
keeps the plans that touch a large table and counts the rest; kept whole, the
first recording under row level security ran Node out of memory, which was
itself the first finding.

## Running it

```sh
npm test -- tests/load                      # 5 companies × 10 000 documents, as the CI does
EKWO_LOAD_PACK=us npm test -- tests/load    # another pack
EKWO_LOAD_DOCUMENTS=100000 EKWO_LOAD_COMPANIES=2 \
  EKWO_LOAD_REPORT=load-report.json npm test -- tests/load
```

The default takes about fifteen seconds on a laptop. 100 000 documents in each
of two companies — 717 000 ledger lines — takes about two minutes and stays
inside PGlite's address space; five such companies do not, and that volume
belongs on a real Postgres.

## The report

Printed at the end of the run, one line per path and caller, and written as
JSON to `EKWO_LOAD_REPORT` when that names a file.

```jsonc
{
  "format": "ekwo-load-report/1",
  "engine": "PostgreSQL 17.5 on … emcc …",   // version() of what ran it
  "pack": "be",
  "documents_per_company": 10000,
  "companies": 5,
  "years": 5,
  "seed": 41,
  "rows": { "entry_lines": 179344, "entries": 66732, "…": 0 },  // whole instance
  "generation_ms": { "template_ms": 121, "multiply_ms": 5873, "analyze_ms": 567,
                     "post_one_document_ms": 11 },
  "total_ms": 12540,
  "paths": [
    {
      "key": "trial_balance",
      "name": "Trial balance of a financial year",
      "as": "member",                 // "owner" bypasses row level security
      "rows_returned": 355,
      "ms": 18,                       // median of three, without the recording
      "budget_ms": 1000,
      "within_budget": true,          // reported; no test reads it
      "large_table_rows_read": 49206, // rows kept plus rows thrown away, all scans
      "capability_checks": 5,         // evaluations of has_capability()
      "access": ["entries: Bitmap Heap Scan on entries_company_date_idx", "…"]
    }
  ]
}
```

`large_table_rows_read` is an approximation — Postgres reports rows per loop
as a rounded average — and is there for orders of magnitude: a path that
answers about a quarter and reads five years shows up in that column and
nowhere in the shape of its plan.

A field is added to the format without a new number; a field that changes
meaning gets `/2`.

## What it found

Measured on PGlite, a laptop, five companies of 10 000 documents unless said
otherwise. `docs/decisions.md` has the reasoning under 18 September 2026.

**No hot path walks a large table.** All six, as the owner and as a member,
reach `entry_lines`, `entries`, `documents` and `reconciliations` through an
index. The composite indexes the schema declared are the ones the planner
picks.

**Row level security was the cost, not the plans — fixed.** The plans were the
same for the owner and for a member, and the member waited nine to forty-five
times longer: `has_capability(company_id, …)` in a policy is called once per
row visited, 359 000 times for one trial balance. `stable` does not mean
"evaluated once". The policies now compare `company_id` against a sub-select
Postgres evaluates once per statement (`20260918141627`), and a trial balance
as a member went from 3 266 ms to 18 ms. The test bounds the number of
evaluations per path; `tests/rls.test.ts` refuses a new policy of the old
shape.

**`suggest_contacts()` was linear in the contacts of the company — fixed.** A
month of statement against 500 contacts took 3.5 s, all of it in function calls
on contacts whose name shared no word with the line. They are now set aside by
an array operator on a stored column (`20260918143352`): 0.24 s, same answers.

**`vat_return()` reads the history of the company to answer about a period —
confirmed, not fixed.** Its filter is `coalesce(l.tax_point_date, e.entry_date)
between …`, which no index can serve, so it reaches every declaration line the
company ever wrote through `entry_lines_box_idx` and discards those outside
the period: 86 000 rows read for the ten boxes of one quarter. It is not a
sequential scan and it is 37 ms today; it grows with every year kept. The same
filter now stands in four functions, which is why the fix — a stored
declaration date on the ledger line — is its own piece of work.

## What is still not known

- **Every time in this file is a PGlite time.** Single process, no parallel
  query, no shared buffers worth the name, WebAssembly. The ratios are
  informative; the absolute figures are not what a hosted project will show.
- **The pooler, PostgREST and JSON** are in nobody's measure yet. An entries
  file of 7 000 lines is 200 ms in the database and an unknown time as an HTTP
  response.
- **Writes.** One `post_document()` into the loaded company is timed: 11 ms at
  10 000 documents, 138 ms at 100 000. Its 171 nested statements were recorded
  at 60 000 documents and none scans a large table or takes more than two
  milliseconds, so the difference is not a plan; it was not pursued. Sustained
  posting, imports and the close of a large year are not measured at all.
- **Many companies rather than large ones.** Five companies is not an
  accounting firm's four hundred. `companies_with_capability()` is linear in
  the companies of the *caller*, and the portfolio functions were measured at
  forty.
