# `docs/filing.md` — the life of a declaration

A VAT return is not a report. A report is asked for and answers; a declaration
**leaves the building**, an administration keeps a copy, money follows it, and
six months later somebody asks what was sent. This page is the whole cycle in
one place: what each step does, which function does it, and — for every step —
what is free and what is operated.

The short version: **everything up to the transmission is open core, and
everything that comes back is too.** What Ekwo sells in the middle is holding
the credentials, the certificate and the responsibility of sending on time.

---

## The eight steps

| # | Step | The function | Free | Operated |
|---|---|---|---|---|
| 1 | Compute | `vat_return()` | ✅ | |
| 2 | Freeze | `prepare_filing()` | ✅ | |
| 3 | Produce the file | a brick of `packages/formats/` | ✅ | |
| 4 | Send | — | ✅ by hand on the portal | the credentials and the deadline |
| 5 | Record what came back | `file_filing()`, `record_filing_outcome()` | ✅ | |
| 6 | Archive | `attachments`, `tax_filing_deposits` | ✅ | |
| 7 | Settle and pay | `settle_filing()`, `auto_settle()` | ✅ | the bank connection |
| 8 | Correct | `reopen_filing()`, `supersede_filing()` | ✅ | |

### 1. Compute

`vat_return(company, from, to, report_code)` reads the ledger and answers box by
box. Which boxes there are, what each of them sums and which are computed from
others is **pack data** (`tax_report.json`); the function contains no country
rule. A figure belongs to the period its tax fell due in — `tax_point_of()` —
and not to the date of the entry, where a country says the two differ.

Nothing is stored. Asked twice, it answers twice, and after an entry lands in
the period it answers differently. That is right for preparing and wrong for
having filed, which is the reason for step 2.

### 2. Freeze

`prepare_filing(company, from, to)` computes the return and **keeps the
answer**, one row per box in `tax_filing_boxes`, identified by the box *and* by
what the box holds — a form is free to print a base and a tax on the same line.

From the moment the declaration leaves `draft`, a trigger refuses any change to
those figures. Called again on a draft, it refreshes; called on a declaration
that has gone, it refuses and names what is needed instead: a corrective.

`filing_deadline()` says when the return is due, where the pack carries the
rule; `upcoming_filings()` lists what is due between two dates. A pack that
declares no rule answers null rather than a date that would be wrong.

### 3. Produce the file

A brick of [`packages/formats/`](../packages/formats/) turns the **frozen**
figures into the file one administration takes. `@ekwo-ai/vat-consignment`
writes the XML Intervat accepts; the form says which brick writes it, in
`tax_report_templates.file_format`, named after the format and never after the
country.

Most forms have no brick, and that is not a blocker: **filing by hand on a
portal is complete and free**, and `file_format` stays null until somebody
writes one.

### 4. Send

This is the only operated step, and it is operated for a reason that has
nothing to do with features: sending needs credentials, often a certificate,
usually a session on a portal, and somebody answerable when a return is late.

A company that files by itself downloads the file and uploads it — that path is
complete, and the two steps around it record what happened either way.

### 5. Record what came back

`file_filing(filing, reference, at, channel, service)` records the send as a row
of `tax_filing_deposits`: the channel (`portal` or `service`), the service's
name where there was one, and the deposit number the administration gave back.

`record_filing_outcome(filing, state, reference, message)` writes what came
back — `accepted`, `rejected` or `paid` — **on the send it answers**, with the
administration's own words. A declaration sent three times keeps its three
references and its refusals.

A refused declaration was never received. It is **sent again**, not corrected:
`file_filing()` accepts a rejected declaration, and each send is a new deposit.
Where the refusal is about the figures themselves, `reopen_filing()` takes the
declaration back to draft so they can be worked out again.

### 6. Archive

The file that was sent and the receipt are `attachments` of the declaration, and
the deposit names which is which (`sent_file_id`, `acknowledgement_id`). They
belong to the company: stopping a subscription takes away the sending, never the
proof of having sent.

They leave with it, too. A company that moves to another installation
([`company-archive.md`](company-archive.md)) arrives with its declarations in
the state they were in, the figures each was frozen with and the deposits that
prove it went; the two files are listed in the manifest to be carried across.

### 7. Settle and pay

`settle_filing(filing, credit, reference, contact, date)` clears the tax
accounts the declared period moved and carries the net to the account **the pack
names** — `tax_payable`, or `tax_receivable` where the period ends in a credit
and the chart keeps the two apart. One entry per declaration, through
`post_entry()`, and a unique index so replaying is refused by the database.

A credit is not settled until the company says what happens to it: carried to
the next declaration, or claimed back. Both are ordinary, and the choice is not
the schema's.

The debt is then an open item like any other. Name the administration as the
contact of the settlement, give the entry the reference the payment will quote,
and `auto_settle()` matches the payment against it — by reference, like any
other payment.

### 8. Correct

Two different things, and calling them by the same name is how books go wrong:

- **A refusal** — the administration never accepted it. Send again, or
  `reopen_filing()` and redo the figures.
- **A corrective** — the administration accepted it and the books have moved
  since. `supersede_filing()` opens a new declaration pointing at the old one,
  which becomes `superseded`. Nothing is overwritten: what was sent stays as it
  was sent, and the corrective's settlement carries **the difference** and not
  the period all over again.

`filings_touched_since()` is what makes step 8 start on time: it lists the
declarations whose period the ledger moved after they were filed. A late entry
is not refused — a supplier invoice arrives when it arrives — but it is never
silent. A company that wants the period shut says so with `lock_filed_period()`,
which moves the tax lock forward only, and refuses while there are still tax
accounts to clear.

---

## Several companies at once

Everything above takes a company. Whoever keeps several — a firm and its
clients in one installation, which is the normal case — asks the two questions
that matter across all of them:

| | One company | Every company you may read |
|---|---|---|
| What falls due | `upcoming_filings(company, from, to)` | `portfolio_upcoming_filings(from, to)` |
| What moved after it went | `filings_touched_since(company, from, to)` | `portfolio_filings_touched_since(from, to)` |

"Portfolio" is the word of the profession — a firm's client portfolio — and
[`firms.md`](firms.md#what-portfolio-means-here) defines it. It is not a list anybody maintains: it is the companies on which the
caller holds `filings.read`. An accountant of forty companies gets forty, the
person who runs one of them gets that one, and the administrator of the
instance — who creates companies and keeps no books — gets none.

Two things differ from the per-company readings. **The window is on the day a
return is due**, not on the period. And **every company is in the answer**: a
row with no date carries a `reason` — `no_deadline_rule` where the pack names
no day for the form, `nothing_due`, `no_form` — because a company missing from
the list a firm plans its fortnight on is worse than a company listed without a
date.

---

## What each pack can do today

`ekwo pack list` prints one line per pack:

```
filing — BE-VAT-PERIODIC (31 boxes) · cadence: month · deadline: in the pack ·
         file: vat-consignment · settles to: 451900
```

Every "no" is printed rather than left out. A return filed by hand on the
administration's portal, with no file written for it, is the ordinary state of
most of them; a deadline a pack has not declared is printed `not declared`. A
listing that showed only what works would be a brochure.

The same five answers are asserted end to end, pack by pack, in
`tests/filing_golden.test.ts`: the golden year is replayed, the return is
computed and frozen, the file is written and **read back to the cent** where a
brick exists, and the settlement is posted where the pack names an account. How
far each pack got is the assertion, and the suite refuses a repository where
nobody can do each of the three — and, since Belgium does, one where no country
walks the whole chain.

---

## What is deliberately not modelled

- **What a country does with a correction** — a replacement return, an
  adjustment carried on the next period, a threshold below which nothing is
  filed. Three mechanisms, none universal, and the texts have not been read.
- **Rounding the debt to the whole unit**, which some administrations do. A rule
  of a country, and no pack carries it.
- **A working-day shift on a deadline**, which needs a calendar of public
  holidays: national, sometimes regional, amended by law.
- **The guard that refuses a pack naming a file format nobody can write.** Owed
  here and to `bank_statement_formats` alike — one guard over the three.

Each of those is a gap that is written down. A gap nobody wrote down is the one
that gets discovered by an administration.
