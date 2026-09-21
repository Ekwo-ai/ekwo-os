# Germany

Everything Germany adds to Ekwo, as data: a chart of accounts, the journals,
the VAT rates and where each one posts, the Kennzahlen of the
Umsatzsteuer-Voranmeldung, the balance sheet of § 266 HGB and the income
statement of § 275 HGB, and the sentences the law puts on an invoice. The
format is [`docs/packs.md`](../../docs/packs.md); this file says where the
content came from and which decisions it rests on, so that a German accountant
or Steuerberater reading the pack can disagree with a specific sentence rather
than with the whole of it.

**Status: `community`.** Nobody has reviewed it against the law they apply. The
figures are replayed against a year of books by `tests/golden.test.ts`, which
proves the pack is coherent and proves nothing about whether it is right.

## Sources

Every rate, box, mention and statement line carries its own `legal_reference`
and names the entry of `certification.sources` its article is in. The register
holds seventeen texts, every one opened on the day recorded beside it:

| What | Text | Publisher |
|---|---|---|
| Rates, exemptions, reverse charge, invoice particulars, the return and its deadline | Umsatzsteuergesetz (UStG) | gesetze-im-internet.de |
| Small invoices, invoices of small businesses, the deadline extension | Umsatzsteuer-Durchführungsverordnung (UStDV) §§ 33, 34a, 46 to 48 | gesetze-im-internet.de |
| Books, the balance sheet and the income statement | Handelsgesetzbuch §§ 238, 239, 266, 275 | gesetze-im-internet.de |
| An entry that may not be altered | Abgabenordnung § 146 Abs. 4 | gesetze-im-internet.de |
| Payment term, default interest, the 40 euro fee | BGB §§ 286, 288 | gesetze-im-internet.de |
| The Kennzahlen and the instructions for them | BMF-Schreiben of 29 December 2025, form USt 1 A 2026 and guide USt 1 E | bundesfinanzministerium.de |
| E-invoicing | BMF-Schreiben of 15 October 2025 and the BMF's questions and answers | bundesfinanzministerium.de |
| E-invoice formats | XRechnung (KoSIT), ZUGFeRD (FeRD), EN 16931 | xeinkauf.de, ferd-net.de, European Commission |
| Code lists | UNCL5305, VATEX, EAS | docs.peppol.eu |
| Where the return and the recapitulative statement are filed | ELSTER, Bundeszentralamt für Steuern | elster.de, bzst.de |
| The base rate the default interest is added to | Basiszinssatz | bundesbank.de |

The form was read from the BMF's own PDF: the Kennzahlen, the line numbers, the
three unnumbered sums and the instructions quoted in the box references are
that edition's.

## The chart of accounts, and why this one

**Germany prescribes no chart of accounts.** § 238 HGB obliges a merchant to
keep books and says nothing about their accounts. What most German bookkeeping
runs on is SKR 03 or SKR 04, the standard charts of **DATEV eG**. They are
DATEV's documents, published under DATEV's copyright and no open licence, and
whether a chart of accounts is protectable at all is a question this repository
is not the place to settle. So this pack does not copy them — neither their
numbers nor their labels — and nobody should read it as an SKR.

What it does instead is follow the law's own structure. The chart is written
for this pack, four digits, flat, and every digit means something in the HGB:

| First digit | Is |
|---|---|
| `1` | Aktiva A, Anlagevermögen — the second digit is the roman numeral (I, II, III), the third the item |
| `2` | Aktiva B, Umlaufvermögen — same reading: `2240` is B.II.4, sonstige Vermögensgegenstände |
| `3` | Aktiva C, D and E |
| `4` | Passiva A, Eigenkapital — `4400` is A.IV, `4500` A.V |
| `5` | Passiva B, Rückstellungen — the second digit is the item |
| `6` | Passiva C, Verbindlichkeiten — the second digit is the item, so `64xx` is C.4 and `68xx` C.8 |
| `7` | Passiva D and E |
| `8` | Items 1 to 8 of § 275 Abs. 2 — the second digit is the item, the third the letter (`8520` is 5 b) |
| `9` | Items 9 to 16 of § 275 Abs. 2 — the second digit is the item less eight |

That is why every account reaches exactly one statement line by the head of its
code, with four exceptions that are split by side: the bank accounts, which are
an asset in debit and a liability to the bank in credit; the VAT settlement
account `6820`; the clearing account `2249`; and the shareholder current
account `6860`.

Depreciation is booked directly on the asset, which is German practice under
the HGB, so there are no accumulated-depreciation accounts.

## The taxes

Twenty-two codes. The standard rate is 19 % since 1 January 2007 and the reduced
rate 7 %; the temporary 16 % and 5 % of the second half of 2020 (§ 28 UStG) are
carried with their validity and post to Kennzahlen 35 and 36, which is where
the 2026 guide says a correction of such a supply goes. The 0 % of § 12 Abs. 3
for photovoltaic systems has its own code and Kennzahl 87, and is a rate rather
than an exemption, so its category is `Z`.

The reverse charges are three codes on the purchase side, one per line of the
form: services from another Member State (§ 13b Abs. 1, Kennzahlen 46 and 47),
supplies by a supplier established outside the Union (§ 13b Abs. 2 Nr. 1,
Kennzahlen 84 and 85) and the domestic cases of § 13b Abs. 2 Nr. 4 to 11
(Kennzahlen 84 and 85 as well). All three deduct through Kennzahl 67.

## The return

`DE-USTVA-2026` is form USt 1 A for 2026, Kennzahl by Kennzahl. A Kennzahl is
the box code. Where the form prints a tax beside a base on the same line and
gives the tax no number of its own — lines 13, 14, 25 and 26 — the tax is the
`tax` kind of the same box (`81:tax`). The three sums the form prints without a
Kennzahl carry their line number: `Z37`, `Z45`, `Z48`. Kennzahl 83 is signed,
as the form asks: a surplus comes out negative.

Kennzahlen 62 (import VAT), 39 (the special advance payment), 50 and 37 (the
reductions for irrecoverable debts) are declared and nothing posts to them; see
`docs/international.md` for why.

## Before this pack is `reviewed`

A reviewer should look at these first:

1. **The chart.** Whether a reference chart that follows §§ 266 and 275 is
   usable by a German bookkeeper who thinks in SKR 03 or SKR 04, and which
   accounts a small GmbH will miss.
2. **The split accounts** — `6820`, `2249`, `6860` and the banks — and
   whether the debit side belongs in B.II.4.
3. **The 2020 rates.** Kennzahlen 35 and 36 for 16 % and 5 % follow the 2026
   guide; the 2020 form itself is not carried.
4. **Kennzahl 21 and 45.** An intra-Community service is `intracom_services`
   and goes to 21; a service to a business outside the Union is `not_subject`
   and goes to 45.
5. **The non-deductible code** `DE-P-19-NA`, written for § 15 Abs. 1a; mixed
   use under § 15 Abs. 4 is a share nobody can put in a pack.
6. **The e-invoicing profile.** `xrechnung` is named; ZUGFeRD in its EN 16931
   profile is equally lawful.
