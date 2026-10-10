# Poland

Everything Poland adds to Ekwo, as data: a chart of accounts read from the
structure the accounting law prescribes, the journals, the VAT rates and
where each one posts, the boxes of the JPK_VAT z deklaracją, the bilans and
the rachunek zysków i strat of the ustawa o rachunkowości, and the sentences
the law puts on an invoice. The format is [`docs/packs.md`](../../docs/packs.md);
this file says where the content came from and which decisions it rests on,
so that a Polish accountant or doradca podatkowy reading the pack can
disagree with a specific sentence rather than with the whole of it.

**Status: `community`.** Nobody has reviewed it against the law they apply.
The figures are replayed against a year of books by `tests/golden.test.ts`,
which proves the pack is coherent and proves nothing about whether it is
right.

**Language: `pl`.** The pack's own labels are written in Polish, which is
also the language of every text in the register below; no second language
file is declared.

## Sources

Every rate, box, mention and statement line carries its own `legal_reference`
and names the entry of `certification.sources` its article is in. The
register holds fifteen texts.

| What | Text | Publisher |
|---|---|---|
| Rates, exemptions, reverse charge, split payment, invoice particulars, tax point | Ustawa z dnia 11 marca 2004 r. o podatku od towarów i usług (tekst jednolity Dz. U. 2025 poz. 775) | isap.sejm.gov.pl |
| Small-business exemption threshold raised to 240 000 zł from 1 January 2026 | Ustawa z dnia 24 czerwca 2025 r. (Dz. U. 2025 poz. 896) | isap.sejm.gov.pl |
| Obligation to issue structured invoices in KSeF | Ustawa z dnia 16 czerwca 2023 r. (Dz. U. 2023 poz. 1598), amended by the act of 5 August 2025 (Dz. U. 2025 poz. 1203) | isap.sejm.gov.pl |
| Structure of the JPK_VAT z deklaracją and its P_xx fields | Rozporządzenie of 15 October 2019 (Dz. U. 2019 poz. 1988, z późn. zm.) and its official brochure, version (3), January 2026 | isap.sejm.gov.pl, podatki.gov.pl |
| Balance sheet and profit and loss account | Ustawa z dnia 29 września 1994 r. o rachunkowości, załącznik nr 1 (tekst jednolity Dz. U. 2026 poz. 522) | isap.sejm.gov.pl |
| Payment term, late-payment interest, recovery compensation | Ustawa z dnia 8 marca 2013 r. o przeciwdziałaniu nadmiernym opóźnieniom w transakcjach handlowych (tekst jednolity Dz. U. 2023 poz. 1790) | isap.sejm.gov.pl |
| Late-payment interest rate in force (second half of 2026) | Obwieszczenie of 22 June 2026 (M.P. 2026 poz. 642) | isap.sejm.gov.pl |
| KSeF itself: legal bases, timetable, FA(3) format | Official portals of the Krajowy System e-Faktur | ksef.podatki.gov.pl |
| Split payment (MPP) | Official guide to the mechanism | podatki.gov.pl |
| Electronic invoice codes | EN 16931, UNCL5305, VATEX | European Commission (docs.peppol.eu) |

## The chart of accounts, and why this one

**Poland prescribes no chart of accounts.** Art. 10 ust. 1 pkt 3 lit. a of
the ustawa o rachunkowości requires each entity to document its own
"zakładowy plan kont", and nothing more. The nine-group chart (zespoły 0 to
9) widely taught in Polish practice is a professional custom, not a legal
obligation; this pack does not use it.

Instead it follows the structure of the law itself: a four-digit chart,
written for this pack, whose first digit points directly to the letter of
the section of the balance sheet or profit and loss account (załącznik nr 1):
`1` Aktywa trwałe (A), `2` Aktywa obrotowe (B), `3` Należne wpłaty and
udziały własne (C, D), `4` Kapitał własny (A of the pasywa), `5` Rezerwy na
zobowiązania (B.I), `6` Zobowiązania długoterminowe (B.II), `7` Zobowiązania
krótkoterminowe and rozliczenia międzyokresowe bierne (B.III, B.IV), `8` and
`9` the lines of the rachunek zysków i strat in the wariant porównawczy. Each
account thus reaches, by construction, the statutory line its name refers to.

**The profit and loss account is in the wariant porównawczy** (expenses by
nature), one of the two variants the annex allows; the choice belongs to the
entity, and the wariant kalkulacyjny (by function) is not modelled.

**The lines broken down by counterparty** (jednostki powiązane, jednostki w
których jednostka posiada zaangażowanie w kapitale) that annex 1 provides for
receivables and payables are not separate accounts: the pack keeps one
account per kind of line, that of a company with no shareholding link to its
customers or suppliers, the usual case of an SME. A group that needs the full
breakdown adds the matching accounts and statement lines.

Depreciation is booked directly against the gross value of the asset (no
separate accumulated-depreciation account).

## Taxes

Eighteen codes. The standard rate is 23 % and the main reduced rate 8 % since
1 January 2011 — **but these are not the nominal rates of art. 41** (22 % and
7 %): art. 146ef raises them to 23 % and 8 % while defence spending exceeds
3 % of GDP, a period open since 1 January 2024 and extended each year by the
minister's obwieszczenie. The 5 % rate (art. 41 ust. 2a, załącznik nr 10) is
not affected.

The zero rate covers exports (`PL-S-EXPORT`) and intra-Community supplies
(`PL-S-WDT`); a service to a taxable person in another Member State under the
general B2B rule (`PL-S-USLUGI-UE`) is not taxed at 0 % but falls outside
Polish territorial scope, reported in P_11/P_12. A domestic exemption is
illustrated by the letting of residential premises (`PL-S-ZW-NAJEM`, art. 43
ust. 1 pkt 36).

On the purchase side, seven codes cover the self-assessment mechanisms Polish
law has today: intra-Community acquisition of goods (WNT), services imported
from a supplier established in the Union (art. 28b) and from one that is
not, imports of goods under the simplified procedure of art. 33a, and a
domestic supply by a supplier with no establishment in Poland (art. 17 ust. 1
pkt 5). Each posts its base once, repeated in the box of tax due and in the
deduction basket (`P_42`). `PL-P-23-POJAZD` illustrates the 50 % partial
deduction of art. 86a on mixed-use vehicle costs. The former general
domestic reverse charge (goods of annex 11) was repealed and replaced by
mandatory split payment, so it is not carried.

## The return

`PL-JPK-V7` transcribes the "Deklaracja — Pozycje szczegółowe" part of the
JPK_VAT z deklaracją, in its version (3) in force from the February 2026
periods — hence `valid_from: 2026-02-01`, and why the golden scenario starts
in February rather than January. Each P_xx field carries the exact label of
the Ministry of Finance's official brochure. `P_38` and `P_51` are the two
mandatory fields the brochure flags explicitly (value "0" by default). The
due date is the 25th of the month after the period (art. 99 ust. 1 for the
return, art. 103 ust. 1 for payment); `period_default` proposes the month,
the general rule — the quarter (art. 99 ust. 2-3) remains an option for a
small taxpayer who opted for the cash method or whose turnover does not
exceed the equivalent of EUR 2 000 000, a status the pack does not guess.

## What the core cannot do

**KSeF is real-time clearance, not a decentralised exchange.** A faktura
ustrukturyzowana is deemed issued when sent to the Krajowy System e-Faktur
(art. 106na ust. 1) and received only when **the system itself** assigns it
a KSeF number (art. 106na ust. 3) — a number the seller does not choose and
which exists only after the administration validates it. The format's
`einvoicing.profile` assumes a peer exchange on the EN 16931 semantic model
(Peppol, Factur-X, XRechnung, a PINT); it provides neither for this clearance
mechanism, nor for numbering assigned by the system rather than the issuer,
nor for the law's four degraded modes (awaria, total awaria, offline24,
unavailability) that change the marker carried in the JPK. `pack.json`
documents this in the `legal_reference` of the `einvoicing` block.

**Split payment (MPP) is a payment rule, not an invoicing rule.** The
obligation (art. 108a ust. 1a) is triggered by a gross total above 15 000 zł
**and** at least one good or service of załącznik nr 15 (150 items classed by
PKWiU) — a condition no value of the closed `applies_when` vocabulary of
legal mentions can express (`always`, `reverse_charge`, `intra_eu_goods`,
`intra_eu_services`, `export`, `exempt`, `late_payment`, `cash_basis`,
`small_business`). The mandatory mention "mechanizm podzielonej płatności" is
therefore not generated automatically. Account `2321` (rachunek VAT) is
nevertheless in the chart so that an entity can trace payments subject to the
mechanism by hand.

**The bad-debt relief (ulga na złe długi, art. 89a/89b) is not modelled.** It
is a statutory correction triggered 90 days after the payment due date,
independent of any decision by the seller, and reversible if the debt is
finally paid — neither a credit note nor a document the core knows. Fields
`P_46`, `P_47`, `P_68` and `P_69` are declared in `tax_report.json` and never
posted.

**Carrying a balance from one return to the next is not modelled.** `P_39`
(excess deductible carried from the previous period) and `P_62` (excess to
carry to the next period) are formal sum fields on the form, but their value
depends on the previous return and on the taxpayer's choice of what to do
with the excess (full refund, partial refund, or carry-forward) — a choice
`P_53`, `P_54` and `P_60` express and that this pack, like `P_39`/`P_62`,
leaves at zero rather than guessing.

**Not modelled, for want of a case in the scenario or a reasonable scope for
a `community` pack:** the small taxpayer's cash method (art. 21, mention
"metoda kasowa"); the margin schemes (travel agents art. 119, second-hand
goods art. 120); investment gold (art. 122); simplified triangulation
(art. 136); the art. 108d discount for early payment from the rachunek VAT;
the spis z natury on cessation of business (art. 14 ust. 5); the credit for
buying cash registers (art. 111 ust. 6); the deposit on beverage packaging
(P_360, art. 17b); the VAT-UE recapitulative statement (`ec_sales_list()`
exists in the core but is not wired to this pack); corporate income tax
(CIT), outside the scope of this pack, which covers only VAT and accounting.

## Before this pack is `reviewed`

A reviewer should look first at:

1. **The chart of accounts.** Whether it is really usable by a Polish
   accountant who thinks in zespoły, and which accounts a small company
   lacks.
2. **The list of rates and exemptions.** Eighteen codes cover only a subset
   of załączniki 3, 10 and 15 and of art. 43 ust. 1 (which has more than
   forty points); this is the first place the pack will need to grow.
3. **The January 2026 period.** The JPK_V7(3) form applies only from
   February 2026; a company whose financial year straddles that date files
   version (2) then version (3), which this pack, with a single version of
   the form, does not yet represent.
4. **`PL-P-23-POJAZD`.** The 50 % deduction is the default rule; a vehicle
   whose mileage log proves exclusively business use (art. 86a ust. 3-4) is
   entitled to 100 %, a case this pack does not code separately.
5. **`legal_payment_days` left empty.** See `documents.references.payment_terms`
   in `pack.json`: Polish law caps at 60 days the term the parties may agree
   between themselves, which is not the same fact as a default term in the
   absence of agreement.
