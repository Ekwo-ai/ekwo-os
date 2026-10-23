# A deposit is written by the core's functions, and the administration is named in the company's language

> Status: accepted

## Context

Decision [0087](0087-a-declaration-is-paid-to-a-contact-the-pack-names.md)
moved the naming of a deposit's files into `record_filing_files()` and kept
the policy `tax_filing_deposits_write`, for the company archive that loads
deposits as they were. That policy let anybody holding `filings.write` insert,
rewrite or delete the proof that a declaration went, past every rule the
functions apply. The archive never needed it: `import_company()` is a definer
function and writes as the owner of the table.

It also left two things open. Declarations whose debt was matched before the
trigger of 0087 existed stayed `accepted` with their money in the bank. And
`defaults.tax_payee` names the administration once, in the pack's language,
while in a country of several languages the administration publishes its name
in each, and a company keeping its books in one of them pays it under that
name.

## Decision

**A deposit is written by three functions and nothing else.** The policy goes,
and `insert`, `update` and `delete` on `tax_filing_deposits` are taken back
from `authenticated` and `service_role`; `select` stays under `filings.read`.
`file_filing()`, `record_filing_outcome()` and `record_filing_files()` write as
definer, each asking `filings.write` (or the installer) once the company is one
the caller may know of. The body of `record_filing_outcome()` moves unchanged
into `write_filing_outcome()`, granted to nobody, which the trigger
`tax_filings_paid_by_matching` calls: paid is the ledger's fact, and the person
whose matching pays the debt may keep the books without filing.

**What was paid before says so.** A migration records `paid`, through
`record_filing_outcome()`, on every accepted declaration whose settlement line
on the pack's account is already matched in full. It reads only accepted
declarations, so a second run does nothing.

**The name is a label like the others.** A pack's language file may carry
`tax_payee` — the name and the register entry, published by the administration
in that language, it is read in — compiled into
`country_defaults.tax_payee_name_i18n`. `tax_payee()` creates the contact under
the company's language, else under the pack's own name, and recognises an
existing contact under any of the pack's names. The translation is optional in
every language: the pack's own name is a correct answer, and a name nobody
published in that language is not.

## Consequences

- An application records a send, an outcome or the files through the
  functions; a direct write is refused with `permission denied`, and the
  backend role meets the same refusal.
- A member without `filings.write` who matches the payment of a declaration
  still makes it paid.
- A company archive round-trips as before: export reads under the select
  policy, import writes as definer.
- A pack whose administration does not publish its name in a language leaves
  that language without one, and companies in it get the pack's own name.

## See also

- [0039](0039-a-deposit-is-an-event.md) — A deposit is an event, written from the frozen figures
- [0087](0087-a-declaration-is-paid-to-a-contact-the-pack-names.md) — A declaration is paid to a contact the pack names, and is paid when its debt is matched
- `docs/filing.md`, steps 6 and 7; `docs/packs.md`, "Who a declaration is paid to"
