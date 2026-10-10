# Senegal

Everything Senegal adds to Ekwo, as data: the value added tax of the Code
général des impôts, where each rate posts, the declaration it is filed on and
the sentences the Code puts on an invoice. The chart of accounts, the journals
and the two statements are the SYSCOHADA révisé shared by seventeen countries,
and they are not written here: they are copied from
[`packs/ohada/`](../ohada/README.md) by `scripts/ohada-packs.mjs`, which the CI
runs to refuse a copy that has drifted. Edit them there.

**Status: `community`.** Nobody has reviewed it against the law they apply.
The golden year proves the pack is coherent and nothing about whether it is
right. Currency XOF, the CFA franc of the BCEAO, at no decimal.

## Sources

| What | Text | Where |
|---|---|---|
| Rates, exemptions, tax point, deduction, précompte, invoices, the return | Loi n° 2012-31 du 31 décembre 2012 portant Code général des impôts | the official PDF of the Ministry of Finance, `apimfb.finances.gouv.sn` |
| The 10 % rate extended to every service of an approved tourist accommodation | Loi n° 2015-06 du 23 mars 2015, art. 34 | `vie-publique.sn` |
| Electronic invoicing (art. 447-II), the précompte of public bodies restored (art. 372) | Loi de finances pour 2025, loi n° 2025-02 du 6 janvier 2025 | `apimfb.finances.gouv.sn` |
| The 15th of the month | DGID, calendrier des déclarations | `dgid.sn` |
| Filing | SENTAX, compulsory for the large-taxpayer office from 1 September 2026 | `sentax.dgid.sn` |
| The frame of the rates | Directive n° 02/2009/CM/UEMOA, art. 29 nouveau | AIFO-UEMOA |

**No consolidated edition of the Code later than 2013 is published by the
administration.** The state of each article is rebuilt from the 2013 text and
the amending laws the ministry publishes.

## What the pack says

- **18 %** on everything taxable (art. 369, al. 1); **10 %** on the services of
  an approved tourist accommodation, restaurant included (art. 369, al. 2) —
  `supply_nature`, because a restaurant that is not such an establishment
  charges 18 %. Exports are *exempt with a right to deduct* (art. 361, 14) and
  380 a), not zero-rated, and the other exemptions of art. 361 have their own
  box, which is what the statement of exemptions of art. 449-2 is drawn from.
- **Goods and services post apart** — 4431 and 4432 on the sale side, 4451,
  4452 and 4454 on the purchase side — because the chart has the accounts. A
  service is taxed when it is performed (art. 362-3): there is no general cash
  basis in Senegal and no option for it, so no tax here is `cash_basis`.
- **The précompte** (art. 372): the buyers the article names — the State and
  public bodies, water, electricity and telephone concessions, construction
  firms of the large-taxpayer office, cement and oil distributors for transport
  — withhold the whole tax, pay the supplier the price before tax, deduct what
  they withheld and pay it over on a separate declaration. `SN-P-18-PC` is that
  purchase: 4452 in debit, 4478 in credit, the supplier owed the net.
- **The tax a foreign supplier owes** (*TVA pour compte*, art. 355-3) is owed by
  the buyer and, since the finance law for 2021, deductible only where the
  service transfers know-how (art. 383 f). Two codes, one deductible and one
  not.
- **The declaration** carries what art. 449-4 says it carries: the taxable and
  exempt operations, the tax, the deductions, the credit. Its boxes are named
  after that content, **not after the printed form**, whose model is fixed by a
  note of the director general and is not published. It is due on the 15th
  (art. 363-1, 449-1). Monthly under the *réel normal*, quarterly under the
  *réel simplifié* (art. 449-3): the cadence follows the regime, so the pack
  proposes none.
- **The invoice** carries a unique number « basé sur une séquence chronologique
  et continue » (art. 447-I-5), the reference to the article of an exemption,
  of the TVA pour compte, and — for a taxpayer under the *contribution globale
  unique* — no tax at all (art. 448-2).

## What it does not say

- **The printed return.** Nothing public gives its boxes; SENTAX and the
  taxpayer's space are where they can be read.
- **The précompte on the supplier's side.** The supplier's tax falls due when
  it is paid (art. 362-5 b) and is paid by the buyer, not by them; how the
  supplier's books clear it is written in no text found, and the pack does not
  guess it.
- **The declaration of précompte and the TVA pour compte** are filed apart from
  the return, and a pack carries one form. The TVA
  pour compte has a box here, said to be a transcription; the précompte waits
  on 4478 with none.
- **Electronic invoicing**: the Code has required it since 2025 (art. 447-II),
  and no order has fixed its format, its platform or its date.
- **The BRS** (art. 200), 5 % of a service invoice withheld from a supplier who
  is not on the real regime, is an income tax, withheld on the payment rather
  than charged on the invoice; the core has no withholding on a payment.
- **Late-payment terms between businesses**: no Senegalese or UEMOA text found.

## Corporate income tax: what `corporate_tax.json` leaves out

The section carries the Code général des impôts as enacted by loi n° 2012-31 (arts.
8, 9, 16, 21, 25, 36, 37, 213 to 215) and the Ministry's « Voies et moyens »
note of the 2025 supplementary finance law, which restates the 30 % rate, the
two instalments and the minimum tax. It starts from line `XI` (net result) of
`SN-SYSCOHADA-IS`, which prints no result before tax, and adds back class 89.
The Code is amended often. A rule that is missing makes an estimate too high
or too low by something a reader can name; these are the ones to name.

| Not carried | Why |
|---|---|
| The minimum flat-rate tax, IMF (CGI arts. 38 to 40): 0,5 % of the previous year's turnover excluding tax, capped at 5 000 000 F, due when the company is in deficit or its tax is lower | A minimum tax is not in the vocabulary: the section computes the tax on the profit and nothing replaces it by a floor. The estimate is therefore too low for a loss-making company, or one whose tax is below the minimum. The charge booked on `895` is added back like any tax on income. The 500 000 F floor of the 2012 text is no longer applied; this rests on the Ministry's note, which states the cap alone; the amending law (loi n° 2019-17) itself should be checked. |
| Rounding of the taxable base down to the thousand franc (art. 36) | No rounding rule exists for a base. The estimate keeps the franc, so it can exceed the tax by up to 299 F. |
| Deferred depreciation (arts. 10 and 16): depreciation booked in a loss year is added back and carried forward with no time limit, and is used after the ordinary deficits | The loss limit is one number of years. A company that carries deferred depreciation as a loss would see it lapse after three years; the estimate does not add it back in a deficit year either. |
| The other ceilings of art. 9: interest paid to partners (rate of the central bank plus three points, capital ceiling), gifts (0,5 % of turnover), head-office costs (20 % of profit), insurance premiums, the 20 % phasing of retirement premiums | Each ceiling depends on a turnover, a profit, a rate or the capital, and a rule moves a fixed share or a stated amount. No rule is written for them. |
| The ceiling of the parent–subsidiary deduction (art. 21: the 5 % share of costs cannot exceed the costs of the period) | Not computed; `parent-subsidiary-dividends` deducts 95 % of what the company declares. The conditions of art. 22 are the company's word. |
| Payments to a foreign legal entity made without the formalities of art. 642 bis, not deductible (art. 9, 11, added by loi n° 2025-02) | The register holds the bill, not the enacted law, which should be checked. |
| The tax-credit carry of art. 37 (three years, then refund on claim) | `withholding-tax-credit` exists and is not refundable; the company declares each year's credit. |
| Prepayments: the first instalment may not be lower than the IMF, the amounts are rounded down to the hundred franc, a year of another length is scaled to twelve months, the second may be waived by letter (arts. 214, 215, 217) | The vocabulary has two shares of a reference tax and nothing else. The third of the tax is written `33,3333`. Nothing reads the schedule yet. |
| Regimes of exemption and reduced rates (investment code, mining and petroleum codes, free zones, new small businesses, the contribution globale unique) | Each depends on an approval or a regime the books do not show. No rate is carried but the 30 % of art. 36. |
| Insurance companies' tax on excess technical provisions (arts. 41 to 46) | A tax of its own, 0,33 % per month; not an income tax rate. |

## Fixed assets

`fixed_assets.json` carries how Senegal depreciates a fixed asset and takes it
off the balance sheet. It rests on the Acte uniforme relatif au droit
comptable et à l'information financière (art. 45) and on the Code général des
impôts as published by the Ministry of Finance (art. 10). That file is the 2012
law as voted; the amending laws in the register (loi n° 2015-06, the 2025
finance bill) do not touch art. 10, but no consolidated current text is
published, so a later amendment is not excluded.

- **Disposal is `gross`.** The chart carries account 81 (book value of assets
  sold) and 82 (proceeds of assets sold), and the income statement prints both
  (lines RO and TN). The roles are `asset_disposal_value` (`812`, tangible) and
  `asset_disposal_proceeds` (`822`, tangible); a company selling an intangible
  or financial asset picks `811`/`821` or `816`/`826` on the entry. The two
  accounts and their names come from the chart.
- **The first-period prorata is practice, not text.** Art. 45 says depreciation
  starts when the asset is in working condition at its place of use, and no
  text says how to cut the first annuity. The section counts real days, in
  straight line and in declining balance, and says so in its `legal_reference`.
- **Declining balance.** CGI art. 10, 1): the straight-line rate of the normal
  useful life times 2 for five years and 2.5 above five years, for equipment of
  industrial companies other than residential buildings, building sites and
  business premises. Two categories carry it (machinery, ten years at 2.5;
  vehicles, five years at 2). The text caps no annuity, so there is no cap.
- **No duration is fixed by law.** Art. 10 admits the depreciation "generally
  accepted by the usages of each kind of industry, trade or operation" and art.
  45 leaves the useful life to the entity. Every straight-line duration is
  therefore common practice, and its `legal_reference` says so; no official
  table fixes one. A category proposes, never
  imposes.

### Fixed assets: what `fixed_assets.json` leaves out

| Not carried | Why |
|---|---|
| Goodwill and other intangibles other than software | Their duration (and any presumption when the useful life cannot be estimated) is set by the Système comptable OHADA, not transcribed here. No duration is carried. |
| Tax depreciation distinct from the book charge, and the derogatory depreciation account `151` | The module keeps one schedule per asset. The art. 10 rule that the cumulated declining depreciation may not fall below the cumulated straight line, on pain of losing the deduction of the deferred part, is not checked. |
| Deferred depreciation (amortissements réputés différés, art. 10 and 16) | A tax carry-forward of depreciation booked in a loss year; the module has no such notion. |
| Accelerated first annuity (art. 10, 1): doubled for new equipment of certain activities, duration shortened by one year) | Not in the vocabulary of a category or of a prorata. |
| Caducity depreciation of public–private partnership concessions (art. 10, 2) | Depreciation over the term of the concession or by revenue: no such method. |
| Units of production | Refused by the module. |
| Revaluation of the balance sheet | Not carried. |
| Residual value, impairment and its reversal | Not a pack rule. |
| Threshold below which an asset is expensed | No official threshold is carried, and the module has no such field. |
| Components of an asset, with their own lives | The module has one asset, one duration. |
| Assets held under finance leases (accounts `2316`, `2326`, `2416`…) and the lessor's depreciation, not deductible under art. 10 | The module does not tell the lessee's books from the lessor's. |
| A prorata in months | Practice; a company that prorates by months sets `prorata = 'months'` on the asset. |

The declining-balance categories also inherit the module's switch to the
straight line when it is the larger annuity, which art. 10 does not provide
for: the module needs it for the schedule to end.
