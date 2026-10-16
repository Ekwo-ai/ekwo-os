# Antigua and Barbuda

Everything Antigua and Barbuda adds to Ekwo, as data: a chart of accounts, the
journals, the Antigua and Barbuda Sales Tax (ABST) at 17 %, the zero rate and
the exemptions, the monthly ABST return (form AB03), and the statement of
financial position and the statement of profit or loss in the IFRS style. The
format is [`docs/packs.md`](../../docs/packs.md); this file says where the
content came from and which decisions it rests on, so that an Antiguan
accountant can disagree with a specific sentence rather than with the whole
of it.

**Status: `community`.** Nobody who files an ABST return has reviewed it. The
figures are replayed against a month of books by `tests/golden.test.ts`, which
proves the pack is coherent and nothing about whether it is right.

**Language.** English, the language of the law and of the Inland Revenue
Department. The Tax Administration and Procedure Act, 2018, s. 22(5), requires
financial statements and invoices to be in English.

## Sources

Every tax, box and statement line carries its own `legal_reference`, and beside
it the key of the text that article is in. The register in `pack.json` holds
eleven texts.

| What | Text | Where |
|---|---|---|
| The charge, the rate, zero-rating, exemption, input tax, reverse charge, returns | Antigua and Barbuda Sales Tax Act, 2006 (No. 5 of 2006) | `laws.gov.ag` |
| The return due fifteen days after the period | Antigua and Barbuda Sales Tax (Amendment) Act 2024 (No. 1 of 2024) | `laws.gov.ag` |
| The 14 % special rate of section 8(3)(b) | Antigua and Barbuda Sales Tax (Amendment) Act, 2019 | `laws.gov.ag` |
| Records kept seven years, penalties, interest | Tax Administration and Procedure Act, 2018 | `laws.gov.ag` |
| The lines of the return | Form AB03 (version of July 2022) | `ird.gov.ag` |
| Registration threshold, invoices and receipts, nil returns | Inland Revenue Department, ABST FAQ | `ird.gov.ag` |
| The rate of 17 % from 1 January 2024 | Sovos and Orbitax reports of the Department's announcement and of the 2024 Budget Statement | `sovos.com`, `orbitax.com` |
| Accounting standards of the profession | Institute of Chartered Accountants of the Eastern Caribbean Agreement Act, 2013 | `laws.gov.ag` |

The published copy of the Sales Tax Act is an image scan with no text layer. It
was read by optical character recognition, and every section quoted in the
pack was read that way: a reviewer should compare the numbers of sections and
items with the printed page.

## The rate of 17 %

The Act as published says 15 % (section 8(3)(d)). The rise to 17 % from 1
January 2024 rests on two reports of the Department's announcement of 22
December 2023 and of the 2024 Budget Statement. The Act that raises it was not
found among those published on `laws.gov.ag`, the Department's own notice (on
its social media pages) was not opened, and its FAQ and form AB03 still print
15 %. These are the weakest sources of the pack and the first thing to confirm
with the Department. The 15 % codes stay for documents dated before 2024.

## The chart of accounts

Original, four digits, 146 accounts, blocked so that each range reaches one
line of the statements. The ABST accounts are 1150 (input tax), 2100 (output
tax), 2110 and 1155 (the net settlement of a filed return, reconcilable),
2125 (ABST collected by the Comptroller of Customs on imports).

## Taxes

Fifteen codes: standard rate 17 % and 15 % (to 31 December 2023) on sales and
purchases; zero-rated exports of goods (Schedule 1) and services (Schedule 2);
zero-rated local supplies (Schedule 3); exempt supplies (Schedule 4); purchases
with the input tax refused by section 28(2) (a passenger vehicle, entertainment,
club memberships, private use); purchases from unregistered suppliers; and
imports at 17 %, zero-rated and exempt (Schedule 5).

## The return

Form AB03, monthly. Lines 200, 250, 220, 230, 240, 270, 295, 300, 310, 320, 330,
340, 395 and 400. The due date is fifteen calendar days after the period (Act
No. 1 of 2024, applicable from the period ending 31 March 2024); the Department's
FAQ still says one calendar month. A late return costs the greater of EC$500 or 5 %
of the tax, a late payment 10 %, and interest runs at 1 % a month (Tax
Administration and Procedure Act, 2018, ss. 57, 72 and 77, as the FAQ and the form
state them).

## Electronic invoicing

None. No structured electronic invoice or clearance system was found in the
texts consulted; `einvoicing.obligation` is `none`.

## What this pack does not carry

- **Accommodation and other supplies to guests** (lines 210 and 260 of the form,
  14 % on the 2022 form). The 2024 Budget Statement is reported to end the
  concessionary rates, tourism included, but no text read says what replaces
  the 14 %. Short-term accommodation and the tour operators brought into ABST in
  2026 are for the accountant.
- **Reverse charge on services from abroad** (section 18): it applies only to
  the extent of an exempt, private or entertainment use, so no purchase tax is
  declared (`not_taxed` in `pack.json`).
- **ABST-inclusive prices** (section 57): prices displayed to consumers must
  include ABST; the documents compute tax on top of a net price.
- **Time of supply**: `invoice_date` is a convention, not the Act's rule.
- **The customs value** an import is taxed on is entered by the user.
- **Apportionment of input tax** for a business with taxable and exempt
  supplies (section 29(3)): the pack claims the whole of the tax entered.
- **Lines 100, 410 to 430, 500, 510 and 600** of the form, which settle one
  period against the next, and the special rates and regulations (the list of
  zero-rated foods and goods, held in the Regulations, which were not read).
- **Other taxes**: corporate income tax, PAYE, Social Security and Medical
  Benefits, Education Levy, customs duties and the tourism levies are not
  modelled.
- **Fixed assets and corporate tax sections**: none.
- **Statutory layout of the accounts**: none was found; the statements follow
  IAS 1 and the rules that map accounts to lines are this pack's own.
- **Portal**: the Department's site lists the forms; no electronic filing
  service was verified.
