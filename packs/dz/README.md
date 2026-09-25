# Algérie

Everything Algeria adds to Ekwo, as data: the chart of accounts of the
Système comptable financier (SCF), the value added tax of the Code des
taxes sur le chiffre d'affaires (CTCA), the monthly declaration it is filed
on and the two financial statements the SCF fixes. Nothing here is copied
from another country's pack: Algeria is not a member of a regional
accounting or tax union, and its chart, unlike its Maghreb neighbours', is
not the French *plan comptable général* but its own nomenclature, close to
the IFRS it was built to converge toward in 2007–2010.

**Status: `community`.** Nobody has reviewed it against the law it applies.
The golden scenario proves the pack is internally coherent and nothing about
whether it is right. Currency DZD, the Algerian dinar, at two decimals.
Language `fr`: French is the language the CTCA, the SCF and the DGI's own
services are published in, and no official Arabic or English edition of
either text was found and verified this session — a pack in Arabic, the
country's other official language, would need one.

## Sources

| What | Text | Where |
|---|---|---|
| VAT rates (19 %, 9 %), exemptions (art. 8 to 13), deduction and its exclusions (art. 41), tax point (art. 14) | Code des taxes sur le chiffre d'affaires (CTCA) | consolidated PDF distributed by the Direction générale des douanes, `douane.gov.dz` |
| VAT in practice, for a taxpayer | La taxe sur la valeur ajoutée (TVA) | Direction générale des impôts (DGI), `mfdgi.gov.dz` |
| The 20th of the month, the G n° 50 relevé | Paiement mensuel de la taxe sur le chiffre d'affaires, TVA, TIC et TPP | DGI, calendrier fiscal, `mfdgi.gov.dz` |
| The invoice: numbering, mentions | Décret exécutif n° 05-468 du 10 décembre 2005 | Ministère du Commerce, `commerce.gov.dz` |
| Télédéclaration et télépaiement | Jibaya'tic | DGI, `jibayatic.mf.gov.dz` |
| The chart of accounts, the two statements | Loi n° 07-11 du 25 novembre 2007 portant système comptable financier ; arrêté du 26 juillet 2008 | Ministère des Finances, `mf.gov.dz` |

## What the pack says

- **19 % normal, 9 % reduced** (CTCA art. 21 and 23). The reduced rate covers
  a closed list — basic foodstuffs, pharmaceutical products, books, rail
  passenger transport, medical acts, among others — which this pack does not
  reproduce: a sale either is on the article's list or it is not, and the
  list is read at the invoice, not guessed from a description.
- **Two exemptions with different consequences.** Exports (art. 13) are
  exempt *with* a right to deduct — `DZ-S-EXP`, `vat_category` `G` — and the
  operations of articles 8 to 12 (banking, first-necessity goods, privileged
  regimes, among others) are exempt *without* it — `DZ-S-EXO`, `vat_category`
  `E`. A pack that gave both the same code would let the wrong one carry the
  right to deduct.
- **A prestation de services posts on collection.** CTCA art. 14 makes the
  fait générateur of a service the encashment of the price, not its
  delivery — the opposite of a sale of goods. `DZ-S-19-SRV` is `cash_basis`,
  parking the tax on the transition account 44572 at invoice time and moving
  it to 44571, and into the box, only when the client pays. The one-year
  regularisation the same article imposes when a service is never paid is
  not modelled: the core has no mechanism for a tax that becomes due by the
  calendar rather than by a document.
- **A purchase that is not deductible stays on the cost.** Article 41
  excludes tourism vehicles that are not the tool of the business, among
  others, from the right to deduct. `DZ-P-19-ND` posts `tax_on_base`: the tax
  adds to the account of the line instead of reaching a deductible account or
  a declaration box, which is what "the tax is an element of the cost"
  means in the ledger.
- **Import VAT is a purchase like any other, once liquidated.** Customs
  collects and liquidates the tax on importation; once the document is
  booked, `DZ-P-IMP-19` deducts it exactly as a domestic purchase would,
  under `DEDBS`. The pack does not model the customs declaration itself,
  only the deduction that follows from it.
- **The declaration is the CTCA's content, not the printed form's boxes.**
  Article 28 requires a monthly relevé of taxable and exempt operations, the
  tax due and the deductions; the DGI files it on form **série G n° 50**,
  due **between the 1st and the 20th of the month following** the operations
  (art. 76-1). No consolidated, verified edition of the printed form's own
  box numbers was found this session, so `tax_report.json` names its boxes
  after what the article requires (`CA19`, `TVA19`, `DEDBS`…) and says so at
  the manifest — a company reading its own G n° 50 will not find these
  labels printed on it.
- **The invoice** carries an uninterrupted, chronological number (décret
  n° 05-468, art. 5) — `numbering: gapless` — and no legal payment term is
  fixed by a text found this session between two businesses.
- **No general obligation of electronic invoicing between businesses** was
  found and verified: the CTCA and the décret of 2005 organise the invoice
  on ordinary support, and Jibaya'tic is a portal for filing and paying, not
  a clearance or exchange platform for invoices. `einvoicing.obligation` is
  `none`.

## What it does not say

- **The printed form's own box numbers.** Only the content article 28
  requires is reproduced; a DZIP or a G n° 50 XML brick, if the DGI ever
  publishes one, would need the official numbering, not this pack's.
- **The one-year regularisation of a service never encashed** (CTCA art.
  14): the core has no notion of a tax becoming exigible by a deadline
  rather than by a posted document.
- **A running VAT credit carried forward month to month.** The `CRED` box is
  computed period by period, as `vat_return()` computes every box in this
  engine; a company whose credit is not absorbed in the month it arises
  needs its accountant to track the carry-forward the CTCA describes, until
  the core itself keeps a balance across declarations.
- **Withholdings.** No provision comparable to a précompte or a retenue à la
  source on VAT, of the kind several sub-Saharan packs in this repository
  carry, was found in the CTCA for a domestic transaction.
- **Electronic invoicing for large accounts and public suppliers.** Some
  large taxpayers and state suppliers already exchange invoices under
  particular arrangements this pack does not model, for lack of a
  consolidated, generally applicable text.
- **The exact article numbering the assiette of import VAT rests on**, and
  the article of the CTCA that fixes the carry-forward and refund of an
  unabsorbed credit: both are described in `tax_report.json` and
  `taxes.json` with the gap named at the point it occurs, rather than a
  number invented to fill the citation.

A qualified professional established in Algeria should read this pack
before it carries a real declaration, starting with the reduced-rate list of
article 23 and the exemptions of articles 8 to 13, which this pack does not
reproduce.
