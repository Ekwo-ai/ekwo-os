# Romania

Everything Romania adds to Ekwo, as data: a functional subset of the official
chart of accounts, the journals, the VAT rates with their history and where
each one posts, the boxes of the monthly VAT return, the abridged balance
sheet and profit-and-loss account, and the sentences the invoicing rules put
on an invoice. The format is [`docs/packs.md`](../../docs/packs.md); this file
says where the content came from and which decisions it rests on, so that a
Romanian accountant reading the pack can disagree with a specific sentence
rather than with the whole of it.

**Status: `community`.** Nobody has reviewed it against the law they apply.
The figures are replayed against a year of books by `tests/golden.test.ts`,
which proves the pack is coherent and proves nothing about whether it is
right.

**Language: `ro`.** The pack's own labels are written in Romanian, which is
also the language of every text in the register below; no second language
file is declared.

## Sources

Every rate, box, mention and statement line carries its own `legal_reference`
and names the entry of `certification.sources` its article is in. The
register holds eleven texts: the consolidated Codul fiscal (Legea nr.
227/2015) and Legea nr. 141/2025, which raised the rates on 1 August 2025;
the ANAF order approving the current formularul 300 and the form itself; the
e-Factura ordinance and its CIUS-RO technical specification; the SAF-T order;
the late-payment law; the accounting regulations of OMFP nr. 1.802/2014; and
the three standards of electronic invoicing (EN 16931, UNCL5305, VATEX).

## The chart of accounts

**Romania publishes an official numbered chart of accounts**, unlike Italy or
Poland: OMFP nr. 1.802/2014, pct. 14 and its annex, the Planul de conturi
general, fixes nine classes (1-9) of synthetic accounts. This pack transcribes
a functional subset of classes 1-7 — capital, fixed assets, inventory, third
parties, treasury, expenses, income — using the official synthetic account
codes exactly as the order gives them. Classes 8 (special, off-balance-sheet
accounts) and 9 (internal management accounting) are left out: neither is read
by the VAT return or by the abridged financial statements this pack carries,
and a company that needs them adds its own.

A handful of second-level analytic codes the order leaves to each entity's own
convention — `6588` (used here as the rounding account) foremost among them —
are this pack's own choice, not a subdivision OMFP 1802/2014 prescribes.
Accumulated depreciation (`280`, `281`) and impairment (`291`) sit under the
same `asset_fixed` type as the assets they offset, so that a balance-sheet
line summing both nets to book value the way `docs/packs.md`'s French example
already does for `201`/`2801`.

## The taxes

Thirteen codes. The standard rate is 21% and the reduced rate 11%, both since
1 August 2025 (Legea nr. 141/2025, art. II pct. 42, amending Codul fiscal art.
291) — a single reduced rate replacing the former pair of 9% and 5%, and the
standard rate raised from 19%. A transitional 9% rate for a single dwelling
bought under strict conditions before 1 August 2025 (art. III of the same law)
is not modelled: it depends on facts about the buyer and the sale this pack's
scenario has no reason to carry, in the spirit of the conditions the format
already refuses to encode as a threshold or a certificate number.

Zero rate covers export (`RO-S-EXPORT`, art. 294 alin. (1)) and the
intra-Community supply of goods (`RO-S-ICG`, art. 294 alin. (2) lit. a));
a service under the general B2B place-of-supply rule to an EU customer
(`RO-S-ICS`, art. 278 alin. (2)) is not a zero-rated supply but an operation
outside Romania's territorial scope, reported at rd. 3 of the return. An
exemption without credit is illustrated by interest on a loan granted
(`RO-S-EXE`, art. 292 alin. (2) lit. a) pct. 1) — `VATEX-EU-135` is a generic
placeholder for the article and should be confirmed by an accountant if the
VATEX list later publishes a narrower code. `RO-S-RC-331` illustrates the
domestic reverse charge of art. 331 alin. (2) on a supply of cereals, one of
the goods the formularul 300 itself asks about by name in its Da/Nu boxes.

Purchase-side, seven codes cover the self-assessment mechanisms the law
provides today: the intra-Community acquisition of goods (`RO-P-ICG-21`) and
of services under the general rule (`RO-P-ICS-21`), a service received from a
supplier established outside the Union (`RO-P-EXT-21`, sharing rd. 7/22 with
the intra-Community one exactly as Italy's VJ3 shares a row between EU and
non-EU services), an ordinary import (`RO-P-IMPORT-21`), and domestic
purchases at both rates (`RO-P-21`, `RO-P-11`). Each self-assessed tax posts
one `base` reused across the two rows the return prints it in, and two `tax`
postings that net to zero on the ledger and leave only the return to show what
happened — the same shape `docs/packs.md` describes for Estonia's KMD.

## The declaration

`RO-D300` transcribes the formularul 300 in the version approved by Ordinul
președintelui ANAF nr. 174/2026, in force for periods from January 2026. Only
the rows this pack's taxes reach are declared, together with the totals that
close the form (rd. 19, 30, 31, 35, 36, 37, 44, 45); the memo rows (3.1, 5.1,
7.1, 12.1, 12.2, 20.1, 22.1, 26.1, 26.2, 29.1), the regularisation rows (2, 4,
6, 8, 16, 18, 21, 23, 28, 33, 34) and the carry-forward rows (38, 39, 41, 42)
are not — see "What the socle cannot do" below. The general rule is the
monthly period (Codul fiscal art. 322 alin. (1)); the quarterly option, for a
taxpayer whose turnover the year before did not cross the equivalent of
100,000 EUR and who made no intra-Community acquisition, is a fact about the
company this pack does not guess at, so `period_default` proposes the month.
The deadline is the 25th of the month following the period (art. 323 alin.
(1)).

## Invoices

- **Numbering**: `sequential`. Codul fiscal art. 319 alin. (20) lit. a) asks
  only for a number that identifies the invoice uniquely, in one or more
  series — not for a gapless sequence or an annual reset, the same reading
  `packs/pl/` gives its own, nearly identically worded, art. 106e ust. 1 pkt
  2. An annual series is very common practice and may well be required by the
  Normele metodologice (Hotărârea Guvernului nr. 1/2016), a text this pack's
  research could not verify separately; `number_format` proposes one
  (`{CODE}-{YYYY}-{NNNN}`) as a convention, not a citation.
- **Tax point**: `invoice_if_issued` — delivery is the rule (art. 281 alin.
  (1)), displaced by an earlier invoice (art. 282 alin. (2) lit. a)). An
  advance payment collected before delivery also moves the tax point (art.
  282 alin. (2) lit. b)), a second derogation this field cannot carry beside
  the first — see "What the socle cannot do" below.
- **Payment terms**: 30 days by default (Legea nr. 72/2013, art. 3), interest
  at the BNR reference rate plus 8 points (Ordonanța Guvernului nr. 13/2011,
  art. 3, as referenced by Legea nr. 72/2013, art. 4).
- **Mentions**: *taxare inversă* for the reverse charge, and the exempt/export
  wording for the other treatments (Codul fiscal art. 319 alin. (20)).

### E-invoicing

RO e-Factura has been mandatory in B2B relations between taxable persons
established in Romania since 1 July 2024 (tolerance without penalty until 31
December 2024, penalties from 1 July 2025 — OUG nr. 120/2021), with a
five-business-day transmission deadline. The invoice is written in UBL 2.1
under the CIUS-RO technical specification (Ordinul ministrului finanțelor nr.
1.366/2021, modified by nr. 4.092/2022) — a profile genuinely built on the
semantic model of EN 16931, unlike Italy's FatturaPA or Poland's FA(3). But
`einvoicing.profile` stays null all the same, for a narrower reason than
Italy's or Poland's: OUG 120/2021, art. 4 alin. (4)-(6) makes the buyer's copy
the one **the system itself seals** — "the original of the electronic invoice
is the XML file accompanied by the electronic seal of the Ministry of
Finance" — not the file the seller sent. A buyer receives a state-sealed copy,
never the seller's invoice directly: the same clearance shape as SdI or KSeF,
built this time on an EN-16931-conformant syntax. No brick of
`packages/formats/` writes, validates or transmits a CIUS-RO invoice today
(the `BR-RO-*` Schematron rules are not implemented anywhere in this
repository), so declaring a profile would claim an interoperability this
repository does not offer. `vat_scheme` and `party_scheme` stay null as well:
RO e-Factura addresses parties by their CIF, not by a verified ISO 6523
scheme, and this pack's research found no official Romanian source confirming
a Peppol EAS code for cross-border use. See "From Romania" in
`docs/international.md`.

## What the socle cannot do

**A national clearance system, again, and a narrower reason than the ones
already on file.** Documented above and in `docs/international.md`.

**Two derogations to one tax point, and the field carries one.** Codul fiscal
art. 282 alin. (2) has two branches: an invoice issued before delivery moves
the tax point to the invoice date (lit. a), and an advance payment collected
before delivery moves it to the date of collection (lit. b). `tax_point` is a
single word for the country's general rule, and `invoice_if_issued` already
states the first branch honestly; a tax that wanted the second could declare
`cash_basis`, but that would misstate a payment-on-account as this tax's whole
regime rather than as one operation among many. Romania is not alone in this:
`docs/packs.md` records the same limit for Estonia's own two-branch rule.

**The postponed accounting of import VAT is not on any row of the return.**
Art. 326 alin. (4)-(5) lets an authorised importer defer the VAT of an import
so that it is never paid to customs and never appears as an output-tax
self-assessment — unlike an intra-Community acquisition, which the return
declares on both sides of the same period. The instructions of the formularul
300 say plainly that rd. 24/25 excludes such an import; no other row was found
for it either. `RO-P-IMPORT-21` therefore models the ordinary, non-deferred
import only, and a company under the postponed-accounting regime has nothing
in this pack to book its imports with.

**Pro rata deduction and the carry-forward of a period's credit are both
outside a return that only sums what the ledger posted.** Rd. 31 restricts
the total deduction of rd. 30 under the pro rata of art. 300 for a partly
exempt taxpayer; rd. 38/39/41/42 carry a prior period's balance or a tax
authority's own assessment into the current one. Neither is a fact
`vat_return()` can read from a single period's postings — the same gap
`docs/international.md` already records for Poland's `P_39`/`P_62` — so `RO-D300`
passes rd. 30 through unchanged to rd. 31 and rd. 35, and leaves rd. 44/45 as a
plain copy of rd. 37/36.

**The VAT cash accounting scheme (TVA la încasare) is a property of the whole
taxpayer, not of one tax code.** An eligible taxpayer below a turnover
threshold may elect to have every sale's VAT fall due on collection rather
than on delivery — the opposite direction of the `cash_basis` flag, which
marks one *tax*, not one *company*. This pack does not model the election, in
the same spirit `packs/pl/` leaves its own "metoda kasowa" out.

**Split payment, VAT groups and the flat-rate compensation for farmers (rd.
27/28) are out of scope for the same reason as their Polish and Italian
counterparts**: each turns on a fact — a threshold crossed, a group
registration, a supplier's own regime — that no line of an invoice or a
company's chart of accounts carries by itself.

## What a reviewer should look at first

1. **The account subset.** Classes 1-7 of the official plan, with the
   analytic codes this pack invented (`6588` foremost) flagged above; a
   Romanian accountant should confirm nothing essential to a small company's
   books is missing.
2. **`RO-S-EXE`'s exemption code.** `VATEX-EU-135` is a generic placeholder
   for the whole of Directive 2006/112/CE art. 135, chosen the same way Italy
   picked `VATEX-EU-D` for its own healthcare exemption — worth a second look
   before this pack is `reviewed`.
3. **`RO-S-RC-331`'s example.** Cereals are one of several goods and services
   art. 331 alin. (2) covers; a reviewer should confirm the article number and
   letter against the current text, which this pack's research could not
   fully verify sub-letter by sub-letter.
4. **`documents.numbering: sequential`.** Whether Normele metodologice (H.G.
   nr. 1/2016) in fact requires an annual reset is a text this pack's
   research did not reach.
5. **The abridged financial statements.** `RO-OMFP-BS` and `RO-OMFP-IS` follow
   the short ("prescurtat") formats of OMFP 1802/2014 for micro and small
   entities; a company outside those thresholds files the fuller formats this
   pack does not carry.
