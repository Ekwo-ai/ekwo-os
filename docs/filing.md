# `docs/filing.md` — the life of a declaration

A tax return is not a report. A report is asked for and answers; a declaration
**leaves the building**, an administration keeps a copy, money follows it, and
months later somebody asks what was sent. This page is the whole cycle: what
each step does, which function does it, and what is free and what is operated.

The short version: **everything up to the transmission is open core, and
everything that comes back is too.** What Ekwo sells in the middle is holding
the credentials, the certificate and the responsibility of sending on time —
one of the optional services of [`cloud-services.md`](cloud-services.md), and
the only one this cycle needs.

---

## The eight steps

| # | Step | The function | Free | Operated |
|---|---|---|---|---|
| 1 | Compute | `vat_return()` | ✅ | |
| 2 | Freeze | `prepare_filing()` | ✅ | |
| 3 | Produce the file | a brick of `packages/formats/` | ✅ | |
| 4 | Send | — | ✅ by hand on the portal | the credentials and the deadline |
| 5 | Record what came back | `file_filing()`, `record_filing_outcome()` | ✅ | |
| 6 | Archive, and prove | `attachments`, `record_filing_files()`, `ekwo proof stamp` | ✅ | |
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
figures into the file one administration takes. The form says which brick
writes it, in `tax_report_templates.file_format`, named after the format and
never after the country. Bricks exist today for a periodic VAT return
(`vat-consignment`) and for recapitulative statements of supplies within the
European Union (`intra-consignment`, `des`, `ecdf`, `vd`), fed by
`ec_sales_list()`.

Most forms have no brick, and that is not a blocker: **filing by hand on a
portal is complete and free**, and `file_format` stays null until somebody
writes one.

### 4. Send

This is the only operated step, and it is operated for a reason that has
nothing to do with features: sending needs credentials, often a certificate,
usually a session on a portal, and a channel somebody keeps running. Operating
the channel is not filing on anyone's behalf: the content of the return, its
date and the decision to send it stay with the business and its accountant.

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
the deposit names which is which (`sent_file_id`, `acknowledgement_id`).
`record_filing_files(filing, sent, acknowledgement)` names them on the last
send, under the right that records the send, and refuses by name a declaration
that was not sent, one a corrective replaced, and a file kept on anything but
this declaration. Nothing else writes a deposit: `file_filing()`,
`record_filing_outcome()` and `record_filing_files()` are the only way in, each
asking `filings.write`, and the table is read under `filings.read`. They
belong to the company: stopping a subscription takes away the sending, never the
proof of having sent.

They leave with it, too. A company that moves to another installation
([`company-archive.md`](company-archive.md)) arrives with its declarations in
the state they were in, the figures each was frozen with and the deposits that
prove it went.

A company may also **prove** a filed file existed on a given day:
`ekwo proof stamp <file> --filing` commits its SHA-256 to a public timestamp
ledger, and anybody holding the file can check it later without an account.
Only the hash leaves. [`filing-proofs.md`](filing-proofs.md) is the detail.

### 7. Settle and pay

`settle_filing(filing, credit, reference, contact, date)` clears the tax
accounts the declared period moved **on that form** and carries the net to the
account **the pack names** — `tax_payable`, or `tax_receivable` where the period
ends in a credit and the chart keeps the two apart. One entry per declaration,
through `post_entry()`, and a unique index so replaying is refused by the
database. The debt matures on the filing's `due_date`, which `prepare_filing()`
writes from the pack's deadline rule.

What "on that form" means is `filing_tax_movements()`: a tax line whose box is
on the form, or a tax line with no box whose tax prints its base in a box of
the form — the form that computes the tax from the base. A tax the pack books
on a liability no box of the form carries — the buyer's self-assessed tax on a
service from abroad, a withholding, a second return of another authority —
stays on its account, for its own return or an entry the company writes; so
does a tax due on collection that still waits on its transition account. A
period in which nothing else moved has nothing to settle, and says so.

A credit is not settled until the company says what happens to it: carried to
the next declaration, or claimed back. Both are ordinary, and the choice is not
the schema's.

The debt is then an open item like any other, and it names the administration.
The pack says who that is (`defaults.tax_payee`); `tax_payee(company)` finds
the company's contact for it — the one contact that books to the account the
pack names — or creates it under the pack's name, and `settle_filing()` names
it when its caller names nobody. Give the entry the reference the payment will
quote, and `auto_settle()` matches the payment against it — by reference, like
any other payment.

When that debt is matched in full, by whatever path, the declaration is
**paid**: the outcome is written on it and on the send it answers, as
`record_filing_outcome(…, 'paid')` writes it, whoever matched the payment —
somebody who keeps the books without filing included. Undoing the matching
takes it back to accepted. A declaration whose debt was matched before this
existed was recorded paid by `20261023160000`.

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

## Schemes and instalments

Which declarations a company files at all is decided by its **VAT scheme**,
and most countries have more than one. A normal scheme files a periodic
return every month or quarter. A simplified scheme files one return a year
and pays part of the tax on account during it. A small business exemption
charges no VAT and files no periodic return. The scheme is a fact about the
company, and the core never chooses it.

**What a pack says.** `packs/<cc>/vat_schemes.json` lists the schemes of the
country ([`packs.md`](packs.md#vat-schemes-vat_schemesjson)): for each, the
forms filed and on which cadences, whether VAT is charged, the ceilings up to
which a company may be on it — an amount, a currency and the article that
sets it, never a figure without its text — and the instalments it asks for. A
pack without the file has no scheme, and its companies file as they always
did.

**What a company says.** A row of `company_vat_schemes`: this scheme, from the
first day of this financial year. There is no default. A company that has
recorded nothing keeps exactly the behaviour it had before schemes existed:
its periodic return, its cadences, no instalments.

**What the scheme governs.** Recording a scheme writes the cadences it implies
into `company_filing_periods` — the scheme's default for each form, or the
only cadence it allows — and removes the cadences of the forms it does not
file. The table remains the one place a cadence is written; the scheme checks
it, and a cadence it does not allow is refused (`wrong_declaration_period`).
`vat_return()` and `prepare_filing()` refuse, by name, a form the scheme does
not file (`form_not_in_vat_scheme`), and with no form named they take the one
the scheme files — or say that it files none (`vat_scheme_files_no_return`).

| | Normal scheme | Simplified scheme | Exemption |
|---|---|---|---|
| Forms | the periodic return | the annual return | none |
| VAT on sales | charged | charged | refused at posting (`vat_charged_under_exemption`) |
| Invoice mention | — | — | the pack's `small_business` mention |
| During the year | — | instalments | — |

**An annual return restates the periodic one.** The taxes of a pack post for
its periodic return. An annual form does not get a second set of postings: it
names the form whose postings it reads (`reads_postings_of`), and each of its
boxes lists the boxes of that form it adds up. Line 5A of the French CA12 is
what line 08 of the CA3 would have received over the year, and the two forms
can never disagree about a posting.

**Instalments.** A scheme that asks for payments on account declares them as a
schedule: in which months, which percentage, of which box of the previous
period's return, and the base under which nothing is due.

1. `instalment_plan(company, from, to)` says what is due on account of the
   declaration of a period: the month (and the day, where the law gives one
   day to everybody), the base read on the previous period's return as
   `prepare_filing()` froze it — or as the books compute it where nothing was
   frozen — the amount due, what was paid and what is outstanding.
2. `declaration_instalments` records what was paid: the instalment, the day,
   the amount, and the entry that carried it where there is one.
3. The annual return deducts them in the box that reads them —
   `instalments_paid`, or `instalments_due` for a form that deducts what was
   due whether paid or not — and its totals carry the balance.
4. `upcoming_filings()` lists every instalment beside the returns, one row each,
   with `instalment` set to its number and the month it falls due in as its
   period. `portfolio_upcoming_filings()` does the same across companies,
   `ekwo status` prints the scheme and the next instalments, and the MCP tool
   `instalment_plan` reads the plan.

**A ceiling is an alert.** `vat_scheme_ceilings_crossed(company, from, to)`
compares the turnover of the books with the ceilings of the scheme the company
is on. Nothing changes a scheme by itself: leaving one is a decision the
company records, from the first day of a financial year.

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

Every "no" is printed rather than left out: a return filed by hand on the
portal, with no file written for it, is the ordinary state of most packs, and a
deadline a pack has not declared is printed `not declared`. The same answers
are asserted end to end, pack by pack, by the test suite: the golden year is
replayed, the return computed and frozen, the file written and read back to the
cent where a brick exists, and the settlement posted where the pack names an
account.

---

## Not modelled yet

- **What a country does with a correction** — a replacement return, an
  adjustment carried on the next period, a threshold below which nothing is
  filed. None of these is universal.
- **Rounding the debt to the whole unit**, which some administrations do.
- **A working-day shift on a deadline**, which needs a calendar of public
  holidays.
- **A deadline counted in months after the period**, which an annual return
  often has; such a form is listed without a date until the closed vocabulary
  of deadline rules carries it.
- **Recording an instalment from a payment.** A payment on account is recorded
  in `declaration_instalments`, by the caller; nothing matches a bank line to
  an instalment yet.
