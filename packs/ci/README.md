# Côte d'Ivoire

Everything Côte d'Ivoire adds to Ekwo, as data: the value added tax of the
Code général des impôts, where each rate posts, the lines of the return filed
on e-impots and the electronic invoice. The chart of accounts, the journals and
the two statements are the SYSCOHADA révisé shared by seventeen countries, and
they are not written here: they are copied from
[`packs/ohada/`](../ohada/README.md) by `scripts/ohada-packs.mjs`, which the CI
runs to refuse a copy that has drifted. Edit them there.

**Status: `community`.** Nobody has reviewed it against the law they apply.
The golden year proves the pack is coherent and nothing about whether it is
right. Currency XOF, the CFA franc of the BCEAO, at no decimal.

## Sources

| What | Text | Where |
|---|---|---|
| Rates, exemptions, tax point, deduction, invoices, the return | Code général des impôts, edition up to date at 3 January 2026, with the Livre de procédures fiscales | the online edition linked from `dgi.gouv.ci`, `cgici.com` |
| What changed in 2025 and in 2026 | Annexes fiscales to the finance laws n° 2024-1109 and n° 2025-987 | `dgi.gouv.ci` |
| The electronic invoice (FNE) | Arrêté n° 0337 du 9 mai 2025, and the API procedure of May 2025 | `fne.dgi.gouv.ci` |
| The lines of the return | Guide utilisateur e-impots, June 2019 | `e-impots.gouv.ci` |
| The frame of the rates | Directive n° 02/2009/CM/UEMOA, art. 29 nouveau | AIFO-UEMOA |

## What the pack says

- **18 %** (art. 359, al. 1) and **9 %** (art. 359, al. 2) on the list the
  article gives — milk, pasta of durum wheat, oil products, luxury rice and
  meat, and since 17 January 2026 jute and sisal, animal feed and the inputs of
  fertiliser. Exports are *exempted* with a right to deduct and to a refund
  (art. 356, 357, 382), on a line of their own; legal exemptions (art. 355) and
  conventional ones (art. 383 bis) each have theirs, as on the form and as on
  the FNE (codes TVAD and TVAC).
- **A service is taxed when it is paid for** (art. 361-2°), unless the director
  general has authorised the option for debits. `CI-S-18-SRV` is `cash_basis`:
  invoiced, the tax waits on 4432 « T.V.A. facturée sur prestations de
  services »; paid, it moves to 4431 and into line 2.4. The chart has no account
  for a tax waiting on its collection, and 4431 « sur ventes » covers the
  services sold of account 706. The golden year shows a service invoiced in
  January taxed in February, and one paid by half.
- **Deduction** (art. 362 to 385): 4451, 4452 and 4454 by what was bought, all
  into line 5.1 as the form has it; the exclusions of art. 372 as a
  non-deductible code; the gas oil of construction machinery and of farmers who
  opted, deductible at 95 % since the finance law for 2026 (art. 365).
- **The return** follows the lines 1.1 to 6.3 of the e-impots declaration, the
  dot dropped (1.1 is `11`) because a box code carries none. It is monthly for
  everybody (art. 437) and quarterly only while the monthly tax stays under
  25 000 F. Line 2.3, at the 21.31 % rate repealed in 2018, is not carried.
- **The tax a non-resident owes** (art. 442) is paid by the buyer, on a
  declaration of its own: it waits on 4478 and is deducted in line 5.1.

## What it does not say

- **The deadline.** The 10th, the 15th or the 20th of the following month,
  depending on the office a company belongs to and its sector (art. 437); the
  pack cannot know which, and names none.
- **The FNE itself.** Compulsory for every régime réel since 1 December 2025,
  numbered by the DGI's platform, stamped with a QR code — and not a profile of
  EN 16931, so no brick of this repository writes it and `einvoicing.profile`
  stays empty. Its API is referenced in the register.
- **The AIRSI**, 5 % (or 2 %, 1.5 %, 0.2 %) of the invoice *including the VAT*,
  added to the invoice of a buyer who is not on a régime réel (loi n° 90-434).
  A tax computed on another tax is a group, which the core does not carry.
- **The 2 % withheld on the services of a micro-enterprise** (art. 84 bis) and
  the other withholdings on income: withheld on the payment, which the core
  cannot express.
- **The credit carried forward** (line 5.2): the settlement of a return carries
  it to 4449, and the next return does not read it back.
- **Late-payment terms between businesses**: the competition ordinance of
  2013 requires terms to be stated and fair, and fixes none.
