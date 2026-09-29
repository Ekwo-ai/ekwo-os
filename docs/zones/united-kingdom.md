# The United Kingdom

The United Kingdom is not a zone anybody else belongs to: it stands alone, and
its rules are those of one pack, `packs/gb/`. This page reads what that pack
does. It is a description of the data, not tax advice, and the pack's status is
`community`: nobody who files a British return has reviewed it.

Since 1 January 2021 the United Kingdom is outside the
[European Union](european-union.md). Nothing in the pack refers to
intra-community supplies, the recapitulative statement or VIES. A supply to a
customer in a European Union Member State is an export of goods (`GB-S-EXPORT`)
or a supply outside the scope of British VAT (`GB-S-OUTSIDE`), like a supply to
anywhere else.

## What the pack does

**VAT, as the Value Added Tax Act 1994 gives it.** Twenty-five taxes: the
standard rate at each of the four periods it has had (17.5 %, 15 %, 17.5 %
again, 20 %), the reduced rate of 5 %, the temporary hospitality rates,
zero-rated and exempt supplies as two codes because only a zero-rated supply
carries a right to deduct, and a retail code for a price that already holds the
tax.

**Four ways a British buyer taxes themselves.** The construction reverse charge
(`GB-P-20-DRC-CIS`, `GB-P-05-DRC-CIS`), postponed VAT accounting on an import
(`GB-P-20-PVA`), and a service received from a supplier established abroad
(`GB-P-20-RCS`), which lands in boxes 4, 6 and 7 at once, plus business
entertainment (`GB-P-20-ENT`), which is a block and not a self-charge.

**The nine-box VAT Return**, `GB-VAT-RETURN`, quarterly by default, computed by
`vat_return()` from the posted ledger. Boxes 2, 8 and 9 — acquisitions from
Northern Ireland and supplies of goods to it — stay declared and empty: one
British registration covers Great Britain and Northern Ireland, and the pack is
keyed on a country, not on what is below it.

**Books.** A chart of 190 accounts that follows the four-digit convention
British practice shares (the United Kingdom prescribes no chart), the balance
sheet and profit and loss account of the small companies regime (Companies Act
2006, S.I. 2008/409), and a `retained_earnings` closing style.

**Invoices.** Sequential numbering (regulation 14 of the VAT Regulations 1995
requires a sequence, not a gapless one), a legal payment term of 30 days from
the Late Payment of Commercial Debts (Interest) Act 1998, and the sentences the
law puts on an invoice: the reverse charge, the export, the exemption, the
right to statutory interest.

**E-invoicing.** The profile is Peppol BIS 3 and the obligation is `none`: no
statute requires an electronic invoice today, and `mandatory_from` is empty
rather than a date the pack invented.

**Banking.** A British account is identified by a **sort code and an account
number**, declared as `bank.account_scheme: sort-code-account`. `ekwo init`
asks for those two, not for an IBAN. Statement formats `camt.053`, `ofx`,
`mt940` and `csv`; payment formats `bacs`, `pain.001` and `csv`.

## What it does not do

It files nothing with HMRC. It carries no partial exemption calculation, no
Making Tax Digital submission and no cash accounting scheme as a ledger. See
[`packs/gb/README.md`](../../packs/gb/README.md) for the sources and the
decisions behind each rate and box, and [`docs/filing.md`](../filing.md) for
what a declaration is and who sends it.
