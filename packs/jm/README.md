# Jamaica

Everything Jamaica adds to Ekwo, as data: a chart of accounts, the journals,
the General Consumption Tax (GCT) rates and where each one posts, the lines of
the GCT return, a statement of financial position and an income statement, and
the way a document is numbered. The format is [`docs/packs.md`](../../docs/packs.md);
this file says where the content came from and which decisions it rests on.

**Status: `community`.** Nobody who files a Jamaican GCT return has reviewed it
against the law they apply. The figures are replayed against two months of books
by `tests/golden.test.ts`, which proves the pack is coherent and proves nothing
about whether it is right.

## Sources

Every rate, box and statement carries its own `legal_reference` and the key of
the text it rests on. The register in `pack.json` holds eight texts, published
by Tax Administration Jamaica (TAJ) except where said, all opened on
18 October 2026. **The General Consumption Tax Act itself was not opened**: its
page on the law library needs a rendering browser, so every rule here rests on
TAJ's own guidance and forms, which cite the Act.

| What | Text |
|---|---|
| The lines of the standard return and its instructions (rounding to whole dollars) | Form 4A, revision of 3 June 2025 (`jm-form-4a`) |
| Rates for telephone (25 %) and tourism (10 %), the threshold, credit and refund, the tax invoice | TAJ's GCT page (`jm-tax-gct-page`) |
| The standard rate of 15 % since 1 April 2020 | TAJ's Advanced GCT document (`jm-gct-advanced`) |
| Which form for which activity, the return period, the due date | TAJ's GCT forms page (`jm-gct-forms`) |
| Last working day of the month | Jamaica Information Service (`jm-jis-due-date`) |
| Threshold of $15,000,000 | Jamaica Information Service (`jm-jis-threshold`) |
| The portal | TAJ Portal (`jm-taj-portal`) |
| Presentation of the statements | IFRS for SMEs, IASB (`iasb-ifrs-sme`) |

## What the pack carries

- **Ten tax codes.** Sales: `JM-S-15` standard, `JM-S-15-INC` the same with the
  GCT already in the price, `JM-S-25` telephone services and instruments, `JM-S-0`
  export, `JM-S-Z` zero-rated at home, `JM-S-EX` exempt. Purchases: `JM-P-15`,
  `JM-P-25`, `JM-P-15-IMP`, `JM-P-EX`.
- **The return, `JM-GCT-RETURN`**: Form 4A, the boxes are its line numbers
  (7 to 11, 14, 15, 18, 19, 24 to 30, 37, 38, 43), monthly, due on the last day of
  the month after the period, in whole dollars.
- **A chart of 118 accounts**, four digits, IFRS for SMEs in spirit; the return
  is settled on `2100` (payable) or `1172` (refundable), apart from the accounts
  the tax posts to. Not a legal chart: none was found.
- **A statement of financial position and an income statement** in the manner of
  IFRS for SMEs.
- **Language**: English, the official language. No `i18n`.
- **Currency**: the Jamaican dollar (`JMD`, two decimals).

## What the pack does not say yet

- **The General Consumption Tax Act, its schedules and regulations were not
  read.** Which supplies are zero-rated or exempt is the user's, with their
  accountant; the pack carries one code for each case and does not reproduce the
  schedules. The time of supply, the particulars of a tax invoice beyond TAJ's
  summary, and the credit disallowed by category are not modelled.
- **Two rates, one source in doubt.** TAJ's GCT page still says 16.5 % in one
  paragraph and lists 15 % in its rate history; the Advanced GCT document states
  15 % from 1 April 2020. The pack uses 15 %. A reviewer should confirm it
  against the current rate schedule.
- **Other forms are not carried.** Tourism activities (10 %, Form 4D), general
  insurance (Form 4E), special consumption tax on fuel, tobacco and alcohol
  (Form 4C), miscellaneous activities and imported services of a non-registered
  person (Form 4G) and approved groups (Form 4H) each have their own return. A
  business with one of these activities files that form outside the pack.
- **Reduced rates not coded.** The residential electricity rate of 7 %
  (Section C2 of Form 4A), the 2 % on books and the 5 % Advanced GCT collected
  from commercial importers are not coded. Advanced GCT is a credit the importer
  carries, not a rate on a sale.
- **Form 4A lines not filled**: supplies to Tax Withholding Entities (12, 13, 16,
  17) and tax withheld by them (34), imported services (20, 21, 35), GCT deferred
  (22, 31), adjustments (23, 36), capital goods (33), the balance brought
  forward (39) and the payment (41, 42). The pack does not split local purchases
  from local expenses (line 27).
- **Apportionment.** When exempt supplies exceed 5 % of total supplies the form
  asks for Section D1; the pack treats all the tax on a business purchase as
  creditable.
- **The registration threshold** ($15,000,000 of taxable supplies over twelve
  months from 1 April 2025) is the user's to apply: the pack does not check it.
- **Services bought from abroad.** Taxed on the amount paid and credited by the
  recipient (lines 20, 21, 35); recorded in `not_taxed` as a gap, not as an
  exemption.
- **Due date.** TAJ moved the date to the last working day of the month in 2014
  and extends it by announcement in some cases; the rule gives the last day of
  the month only.
- **Penalties and interest** on a late return or payment are not modelled.
- **E-invoicing**: no obligation found (`obligation: none`).
- **Other levies**: income tax, National Insurance Scheme, National Housing
  Trust, Education Tax, HEART/NSTA Trust, customs duty and stamp duty are ordinary
  payable and expense accounts. No code, no return.
