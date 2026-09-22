# Italy

Everything Italy adds to Ekwo, as data: a chart of accounts built on the
statutory captions of the balance sheet and the income statement, the
journals, the VAT rates with their history and where each one posts, the
boxes of the annual VAT return, the balance sheet and income statement of
the Civil Code, and the sentences the invoicing rules put on an invoice. The
format is [`docs/packs.md`](../../docs/packs.md); this file says where the
content came from and which decisions it rests on, so that an Italian
accountant reading the pack can disagree with a specific sentence rather
than with the whole of it.

**Status: `community`.** Nobody has reviewed it against the law they apply.
The figures are replayed against a year of books by `tests/golden.test.ts`,
which proves the pack is coherent and proves nothing about whether it is
right.

## Sources

Every rate, box, mention and statement line carries its own
`legal_reference` and the key of the text it is in. The register in
`pack.json` holds the consolidated texts on Normattiva, the forms and their
instructions published by the Agenzia delle Entrate, and the standards of
electronic invoicing.

## The chart of accounts

**Italy publishes no official numbered chart of accounts.** Unlike Spain's
Plan General de Contabilidad, Belgium's PCMN or France's PCG, the Codice
civile fixes the *captions* a balance sheet and an income statement must
carry — art. 2424 and art. 2425 — and says nothing about how a company
numbers the accounts that feed them. The numbering of `accounts.csv` is
therefore this pack's own convention, built to read onto those captions
cleanly, and not a text to cite: a reviewer should read the *statement
lines* against the law and the *account codes* against nothing but internal
consistency. This is said once here rather than on every account.

Language: the pack is written in Italian (`defaults.language: it`), the
language the Codice civile and the Agenzia delle Entrate publish in. No
administration publishes an English piano dei conti to translate from, so
the English labels of `i18n/en.json` are a translation for a reader and
never a filing — see `i18n/README.md`.

## The statements

`IT-CC-BS` (stato patrimoniale) and `IT-CC-IS` (conto economico) carry the
letters and Roman numerals of art. 2424 and art. 2425 as their line codes,
and the wording is close to the article's own. Several captions the two
articles name are not reached by any account of this chart and are left out
rather than declared empty: **A) crediti verso soci** (no subscribed,
unpaid capital modelled), **B) fondi per rischi e oneri** and **C) TFR** as
a balance-sheet heading of its own — the severance provision is folded into
the payables of D, which understates the letter of art. 2424 and is flagged
below. `xbrl` is null on every line: the CNDCEC publishes a taxonomy for
XBRL filing and nobody has mapped it here.

## Taxes

A code is a rate at a date. The pack carries the four positive rates of
art. 16 D.P.R. 633/1972, each on the row the 2026 Modello IVA prestamps for
it:

| Rate | In force since | Modello IVA row |
|---|---|---|
| 22 % (ordinaria) | 1.10.2013 | VE23 / VF13 |
| 10 % (ridotta) | 1997 | VE22 / VF11 |
| 5 % (ridotta) | 1.1.2016 | VE21 |
| 4 % (minima) | 1989 | VE20 |

Beside them: exports (art. 8, box VE30 field 2), intra-Community supplies of
goods (art. 41 D.L. 331/1993, box VE30 field 3), generic services to an EU
taxable person (art. 7-ter, box VE34 — not VE30, which the form reserves
for goods), an exemption of art. 10 (healthcare, box VE33), the domestic
reverse charge of construction subcontracting and of cleaning/demolition/
installation/completion services on buildings (art. 17, comma 6, letters a)
and a-ter), boxes VE35 fields 4 and 8), the self-assessment of an intra-
Community acquisition of goods (art. 38 D.L. 331/1993, box VJ9), of a
generic service received from a supplier established in the Union or
outside it (art. 17, comma 2, box VJ3 — the Modello IVA does not separate
the two, and neither does this pack's box, though the invoice-facing
`treatment` still does), and the 20 % withholding on self-employment fees
(art. 25 D.P.R. 600/1973).

**A box identifier never carries a colon that is not the base/tax/total
qualifier the schema reserves.** Where the official form disposes several
figures of one row in separate boxes — VE30's export and intra-Community
columns, VE35's construction and cleaning columns — this pack spells them
`VE30C2`, `VE30C3`, `VE35C4`, `VE35C8`: the campo number appended to the row,
with a letter instead of a colon.

**One posting, two rows.** An intra-Community acquisition and a reverse
charge on services are declared once — as EN 16931's Estonian example in
`docs/packs.md` already shows — with a `base` posting naming both the VJ row
(the tax due) and the VF row (the tax deducted) as a list, and two `tax`
postings, one to each side. The pack's VAT control accounts (1110
receivable, 2200 payable) carry both legs, so the two amounts, being equal,
leave the cash position untouched and only the declaration shows they
happened.

**What is not here, and why:**

- **Split payment (scissione dei pagamenti, art. 17-ter).** A sale to a
  public administration is invoiced with VAT shown, and the administration
  pays the price to the seller and the VAT directly to the Treasury. This is
  the exact three-party shape `docs/international.md` already names for
  Senegal's *précompte*, Côte d'Ivoire's *TVA pour compte de tiers* and
  Chad's art. 245 and 229-V: a debt that stays the seller's while a third
  party remits it, which no posting of this core expresses for the party
  who never touches the remittance. No tax code of this pack claims to
  model it; see `docs/international.md`.
- **Real-time clearance through the Sistema di Interscambio.** See
  "E-invoicing" below.
- **The regime forfettario** (flat-rate scheme for small businesses, legge
  190/2014, art. 1, commi 54-89): a substitute income tax with no VAT
  charged on sales, a property of the taxpayer this pack's single chart does
  not model.
- **VAT groups** (art. 70-bis to 70-duodecies) and the annual pro rata for a
  company with significant exempt turnover (art. 19, comma 5, and the
  sections 3-A and 3-B of quadro VF).
- **Esterometro.** Abolished from 1 July 2022 (D.L. 73/2022): cross-border
  operations are reported through the ordinary electronic invoice and the
  self-invoicing document types (TD17, TD18, TD19), not a separate filing.
  Nothing in this pack needed to change for that.

## The annual VAT return

`IT-DICH-IVA` transcribes quadri VE (sales), VF (purchases and the
deduction), VJ (self-assessed operations) and VL/VX (the settlement), as
numbered on the Modello IVA 2026 (period 2025). It does not transcribe the
agricultural flat-rate compensation rows (VE1-VE11, VF1-VF10, VF12, the
whole of sezione 3-B), the pro rata of exempt operations (sezione 3-A), VAT
groups, prior-year credits or refund requests (VL5-VL31), or the *imponibile*
column of VE24 and VF25, which no box downstream of this pack reads.

**No `deadline` is declared.** The return is due between 1 February and 30
April of the following year (D.P.R. 322/1998, art. 8, comma 1) — the last
day of the *second* month after the period, not the first, which is all the
three deadline rules of the format can express. A constant number of days
added to "the last day of the following month" drifts by one day across a
leap year's February, so no approximation was written down that could land
after the legal date in some years and not others. See "From Italy" in
`docs/international.md`.

## Invoices

- **Numbering**: `gapless_per_year`, one series per calendar year with the
  year in the number. Since legge 228/2012, art. 1, comma 325, the law
  itself only requires a progressive, unique number (art. 21, comma 2,
  lettera b) — the yearly series is this pack's proposal, not a requirement.
- **Tax point**: `invoice_if_issued` — delivery for goods and payment for
  services (art. 6, commi 1 and 3), displaced by an earlier invoice (art. 6,
  comma 4).
- **Payment terms**: 30 days by default, up to 60 if agreed in writing and
  not gravely unfair to the creditor (D.Lgs. 231/2002, artt. 4 and 7).
- **Mentions**: *inversione contabile* for the reverse charge, and the
  non-taxable/non-subject/exempt wording for exports, intra-Community
  operations and art. 10 exemptions (art. 21, commi 6 and 6-bis).

### E-invoicing

B2B and B2C electronic invoicing through the Sistema di Interscambio (SdI)
has been mandatory since 1 January 2019 (legge 205/2017, art. 1, commi
909-910, amending D.Lgs. 127/2015) — unlike Spain, where the equivalent
obligation this pack's neighbour describes has not yet come into force. But
`einvoicing.profile` and `mandatory_from` are left null all the same,
because the two packs are empty for different reasons. The SdI does not
exchange an EN 16931 profile between two parties in the sense the format
asks about: it is the state's own **clearance** step — the invoice (in the
FatturaPA format) is validated, sealed and delivered by the Agenzia delle
Entrate, or rejected, and no brick of `packages/formats/` generates,
validates or transmits one today. Declaring a profile would say the
opposite of that. This is the same shape `docs/international.md` already
names for Mexico's CFDI: "Italy's SdI, India's IRN and most of Latin America
are the same shape." `vat_scheme` is `0211` (AGID's Peppol Italia scheme for
the partita IVA); `party_scheme` is null because the domestic Codice
Destinatario is a seven-character SdI address, not an ISO 6523 identifier.

## What a reviewer should look at first

1. **The chart of accounts is this pack's own numbering**, not a published
   plan — every account code, as opposed to every statement line, needs an
   accountant's eye rather than a citation.
2. **The exemption reason code of `IT-S-EXE`** (`VATEX-EU-D`): one of four
   codes the VATEX list pairs with category `E`, chosen as a placeholder and
   not verified against art. 10, comma 1, n. 18 specifically.
3. **`VJ3` shared by EU and non-EU services**: the Modello IVA gives the two
   one row; whether a reader expects them split anyway is worth asking a
   preparer.
4. **The severance provision (TFR, fondo trattamento di fine rapporto)**
   sits among the payables of the balance sheet rather than under its own
   letter C, which art. 2424 gives it.
5. **Numbering `gapless_per_year`**: common practice, not a requirement
   since the 2013 reform of art. 21.
6. **No deadline on the annual return**: deliberate, see above — not an
   unresearched gap.
