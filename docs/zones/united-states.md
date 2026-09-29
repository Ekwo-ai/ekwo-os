# The United States

The United States is not a zone anybody else belongs to, and it is the first
country of the repository with **no value added tax**. Its rules are those of
one pack, `packs/us/`, and this page reads what that pack does. It is a
description of the data, not tax advice; the pack's status is `community`:
nobody who files an American return has reviewed it.

There is no VAT here, so there is nothing an input credit or a
recapitulative statement could be about, and none of the
[European Union](european-union.md) machinery applies. A company that sells to
a customer abroad does so under the pack's sales-tax codes, which are exempt or
out of scope for such a sale.

## What the pack does

**Sales and use tax, by state.** The tax is levied by the states and by
districts under them, and the buyer never gets it back. The pack carries three
states as an example of the shape: California (combined state and local rates,
resale, food, government and shipped-out-of-state exemptions), New York City,
and Oregon, which has no sales tax. A tax names the state whose law it is
(`US-CA`, `US-NY`, `US-OR`).

**Use tax.** A purchase from a seller that did not charge the tax is taxed on
the buyer by their own state under its own law (`US-CA-P-USE-725`). It is
self-assessed: no exempt supply stands behind it, and nothing is recoverable at
the other end.

**One state return**, the California sales and use tax return (`CDTFA-401-A`),
thirty-nine lines, computed by `vat_return()` from the posted ledger. There is
no national return and none is invented.

**Books.** The United States prescribes no chart of accounts; the pack's chart
is a convention. The balance sheet and income statement follow Regulation S-X
(17 CFR part 210), and a `retained_earnings` closing style.

**Invoices.** Numbering is free: no federal rule imposes a sequence and the law
puts no mandatory sentence on an invoice, which the pack states rather than
leaves silent. No e-invoicing profile is declared and the obligation is `none`.

**Banking.** An American account is identified by an **ABA routing number and
an account number**, declared as `bank.account_scheme: aba-routing-account`.
`ekwo init` asks for those two, checks the routing number's check digit, and
never asks for an IBAN. Statement formats `bai2`, `ofx`, `csv` and `camt.053`;
payment formats `ach` and `csv`.

## What it does not do

It covers three states out of fifty and does not decide where a seller has
nexus: economic nexus, since *South Dakota v. Wayfair*, is a threshold a seller
crossed, and the pack cannot know it. It files nothing with any tax
administration. See [`packs/us/README.md`](../../packs/us/README.md) for the
sources and decisions, and [`docs/filing.md`](../filing.md) for what a
declaration is and who sends it.
