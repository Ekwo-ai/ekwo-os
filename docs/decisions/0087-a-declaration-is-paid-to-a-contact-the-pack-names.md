# A declaration is paid to a contact the pack names, and is paid when its debt is matched

> Status: accepted

## Context

`settle_filing()` carries the net of a declared period to the account the pack
names for what is owed (`roles.tax_payable`), and `settle_from_statement()`
refuses an open item that names nobody: a payment is made to somebody. The
debt of a declaration could only be matched to its payment if the settlement
named a contact, and only a contact whose third-party account is the pack's
(`contact_account_mismatch`). Nothing created that contact, and nothing in a
pack said who the administration is. An application that settled a period
either asked the user to build the right contact first or left a debt that no
payment would ever find.

Two smaller gaps sat beside it. The two files of a send
(`tax_filing_deposits.sent_file_id`, `acknowledgement_id`) were written by an
update of the deposit, which nothing checked beyond its policy. And
`record_filing_outcome(…, 'paid')` existed, while nothing called it when the
debt was paid.

## Decision

**The pack names the administration.** `defaults.tax_payee` carries its
official name in the pack's language and the key of the register entry,
published by that administration, where the name is read. It is per country,
beside `roles.tax_payable`, because the account a declaration settles to is per
country: two payees on one account could not be told apart by the ledger. It
compiles into `country_defaults.tax_payee_name` and `tax_payee_source_key`. A
pack whose register holds no entry published by the collecting administration
names none; nobody guesses one.

**The account is the link.** The company's contact for the administration is
the one active contact whose payable account is the pack's `tax_payable`
account — exactly the contact `settle_filing()` accepts. `tax_payee(company)`
returns it; where several book there, the one under the pack's name; where none
does, it creates one under the pack's name, booking its payable side to
`tax_payable` and its receivable side to `tax_receivable`. No column on the
company records the choice, so nothing has to be kept in step with the
contacts. Several contacts with none under the pack's name is refused by name
(`several_tax_payees`), never resolved by picking one. A pack that names nobody
and a company with no such contact answer null, as a deadline a pack does not
declare does.

**Settling names it.** `settle_filing()` called without a contact names
`tax_payee()` on the line that carries the net. A contact passed explicitly
still wins and is still checked against the account.

**The files are named by a function.** `record_filing_files(filing, sent,
acknowledgement)` names them on the last deposit, under `filings.write`, the
right of `file_filing()`. It refuses a declaration that was not sent, one a
corrective replaced, a file kept on something other than this declaration, and
a file of another company in the words a file of nobody gets (decision 0065).
The policy of `tax_filing_deposits` stays, for the archive that loads deposits
as they were.

**Paid is derived from the matching.** A trigger on
`entry_lines.matched_amount` records `paid` through `record_filing_outcome()`
when the line a settlement carried its net on is matched in full, and
`accepted` again when that matching is undone. It sits where matching writes,
so the bank, `auto_settle()`, `reconcile()` and an import all reach it, and no
caller has to remember to record it.

## Consequences

- A settlement of a pack that names its administration always names
  somebody, and the payment that quotes its reference settles it by itself.
- The first settlement of a company creates a contact. It is an ordinary
  contact: renamed, merged or given another account, it stays the
  administration as long as it is the one booking to `tax_payable`.
- A declaration whose debt is paid in several transfers stays `accepted` until
  the last one, and an unmatched payment takes it back.
- A company that keeps several contacts on the tax account is asked to say
  which one is the administration, by name or by `p_contact_id`.

## See also

- [0039](0039-a-deposit-is-an-event.md) — A deposit is an event, written from the frozen figures
- [0065](0065-a-shared-instance-keeps-its-tenants-apart.md) — A shared instance keeps its tenants apart
- `docs/filing.md`, steps 6 and 7
