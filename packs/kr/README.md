# South Korea

Everything South Korea adds to Ekwo, as data: a chart of accounts, the
journals, the value-added tax (부가가치세) at its standard and zero rates and
the exemptions of article 26, where each code posts, the general VAT return
(별지 제21호서식) with the boxes this pack models, a balance sheet and an
income statement following the current/non-current presentation of Korean
accounting practice, and a golden year of documents. The format is
[`docs/packs.md`](../../docs/packs.md); this file says where the content came
from and which decisions it rests on, so that a reviewer can disagree with a
specific sentence rather than with the whole of it.

**Status: `community`.** Nobody who files a Korean VAT return has reviewed
this pack. The figures are replayed against a year of books by
`tests/golden.test.ts`, which proves the pack is coherent and proves nothing
about whether it is right.

**Language.** The pack is written in Korean — accounts, journals, taxes, the
boxes of the return and the statement lines carry the wording a Korean
bookkeeper and the National Tax Service (NTS) use — and `i18n/en.json` gives
all of it in English. No official English wording of the return form or of a
chart of accounts exists; the English labels are this pack's own translation,
not a second source.

## Sources

Every tax, box and statement line carries its own `legal_reference`, and
beside it the key of the text it is read from. The register in `pack.json`
holds thirteen sources, all consulted on 22 September 2026: 부가가치세법 and
its Enforcement Decree on 국가법령정보센터 (law.go.kr); the return form itself,
별지 제21호서식 of the Enforcement Rule, read from the PDF law.go.kr publishes
under that annex; the Commercial Act and the Corporate Tax Act for the
financial-statement duty and the business year; the National Tax Service's
own pages for filing deadlines, the mandatory e-invoice issuers and their
transmission deadlines and penalties; the Korea Accounting Standards Board
(KASB) for the absence of a legal chart of accounts; and OpenPeppol's own
list of Peppol Authorities to support the claim that South Korea is not one.

## The chart of accounts, and why this one

**South Korea prescribes no chart of accounts.** 상법 제447조 requires a
stock company to prepare a balance sheet and an income statement every
financial year; it names no account. A company that does not apply K-IFRS
follows 일반기업회계기준, published by KASB, which fixes the current /
non-current split of a balance sheet and the five-step structure of an
income statement (gross profit, operating profit, profit before income tax,
net profit) — and, like Japan's 会社計算規則 and Hong Kong's SME-FRF & SME-FRS,
fixes no chart of accounts underneath those totals. This chart is original:
four digits by class, cut so that each range reaches one line of the
statements below. No published chart, official or commercial, was copied.

**Two VAT clearing accounts, kept apart from the accounts a tax posts to.**
`1250` 부가세대급금 holds the input tax a purchase carries until a return
settles it, `2150` 부가세예수금 the output tax a sale carries. Once a return is
filed, the net lands on `2155` 미지급세금 (`tax_payable`) or, where it is a
refund, on `1255` 미수금(부가세환급세액) (`tax_receivable`) — the same
mechanism Belgium's 451900 and 445670 give a European return, adapted to a
country with no legal chart to read it off.

**The result closes to retained earnings** (`closing_style:
retained_earnings`): Korean practice carries the year's result straight to
이월이익잉여금 (`3330`), and what a shareholders' meeting later does with it —
appropriation to 이익준비금 under 상법 제458조, a dividend, a voluntary
reserve — is not part of a close.

## Taxes

**Eight codes**, covering a standard-rated sale and purchase, a zero-rated
export of goods and of services, an exemption on each side, a
non-creditable purchase and an import.

- `KR-S-10` / `KR-P-10` — the standard rate of 10% (부가가치세법 제30조), on a
  tax invoice (세금계산서, 제32조). Reported on boxes `(1)` and `(10)` of the
  return.
- `KR-S-0-EXP` (재화의 수출, 제21조) and `KR-S-0-SVC` (용역의 국외공급 and
  외국항행용역, 제22조·제23조) — the zero rate. A tax invoice is not required
  for either, so both land on box `(6)` '기타' of the zero-rate section, and
  the right to deduct input tax is kept, which is what tells a zero rate from
  an exemption.
- `KR-S-EXO` / `KR-P-EXO` — the exemption of 제26조제1항, illustrated on
  unprocessed foodstuffs (1호) in the golden year; a company that also makes
  a purchase from an exempt supplier gets no input tax to deduct, because
  none was charged. An exempt supplier issues a 계산서, not a 세금계산서
  (소득세법 제163조, 법인세법 제121조); neither side of this tax reaches a box
  of the periodic return proper — the sale is reported separately, at
  `(80)`, under '면세사업 수입금액'.
- `KR-P-10-NC` — 제39조제1항제5호 (기업업무추진비 and the like): the tax is
  charged and invoiced but not creditable, so it is a cost of the line it
  taxes (`tax_on_base`) and is reported at box `(16)`.
- `KR-P-IMP-10` — 제50조: the tax customs collects on an imported good, which
  is fully creditable once the 수입세금계산서 is issued (제35조), and whose
  counter-posting is a liability to customs (`2135`) rather than to the
  foreign supplier, exactly as Japan's own import code does with its own
  authority.

**Not carried, deliberately.** 간이과세자 (the simplified regime of
제61조 and following, for a business under 104,000,000 원 of annual supplies
since 1 July 2024) computes the tax as a rate of turnover rather than an
invoice-by-invoice credit mechanism, files annually and is a different
scheme end to end — like Japan's 簡易課税, it is a form this pack does not
declare. 대리납부 (제52조, a domestic buyer paying the VAT of a foreign
digital-service supplier on that supplier's behalf) is not modelled either;
it is the closest thing this pack could have carried to a reverse charge and
is left for a future pack to add with its own golden coverage.

## The return

`KR-VAT-21` is 별지 제21호서식, the general-method 부가가치세 return, twelve
boxes: the ones the eight tax codes above actually reach, plus the totals a
reviewer needs to see the payable or refundable figure come out —
`(1)`, `(6)`, `(9)`, `(10)`, `(15)`, `(16)`, `(17)`, the un-numbered `㉰`
declared `hidden`, `(27)`, `(80)` and `(83)`. The real form carries far more:
credit-card and cash-receipt sales `(3)`–`(4)`, bad-debt relief `(8)`, fixed
asset purchases `(11)`, the eighteen credits and reductions of `(18)`–`(25)`,
every one of the penalty lines of `(26)` — none of it is declared, because
none of it is reached by a tax this pack carries, and `ekwo pack check`
refuses a box a tax cannot post to and does not ask for a box nothing needs.

- **Filed quarterly.** 제48조 (예정신고) obliges a corporate taxpayer to file
  for each of the first three months of a half-year taxable period, by the
  25th of the following month; 제49조 (확정신고) obliges a return for the
  second three months of that period, again by the 25th, net of what the
  preliminary return already declared — so a company's return is, in
  substance, quarterly, which is what `period` and `period_default` say.
- **예정고지 is not a filing.** Most individual general taxpayers do not file
  a preliminary return at all: the NTS assesses and collects half of the
  prior period's tax by notice (제48조제3항) instead. That is a payment on
  account, not a declaration, and this pack — whose chart targets a company —
  does not model it; a note is kept in
  [`docs/international.md`](../../docs/international.md).

## The e-tax invoice, and why `einvoicing` is empty

전자세금계산서 is mandatory for every corporation since 2011 and, since
1 July 2024, for an individual business whose prior-year supplies reached
80,000,000 원 (부가가치세법 제32조, 시행령 제68조); it must be transmitted to
the NTS by the day after issuance, with a penalty of 0.3% for a late
transmission and 0.5% for none at all. None of that makes it an `einvoicing`
profile this format can name: South Korea has not joined OpenPeppol and runs
no Peppol Authority, so there is no PINT-KR or equivalent built on EN 16931;
the electronic tax invoice is the NTS's own XML, submitted to its own
Hometax portal, and no brick of `packages/formats/` writes it or talks to
Hometax. `profile`, `mandatory_from`, `party_scheme`, `vat_scheme` and
`obligation` are therefore all left out, exactly as Mexico's CFDI clearance
left them out: declaring a profile here would claim a brick of this
repository produces a valid Korean tax invoice, which none does. The gap is
recorded in full in [`docs/international.md`](../../docs/international.md).

## The golden year

한강무역주식회사, a general trading company, calendar year 2026, filing
quarterly: fourteen documents and three payments. A domestic standard-rated
sale and purchase recur every quarter; a goods export (`S2`), a cross-border
consulting service to a Japanese client (`S4`), a sale credit note (`CN1`),
an exempt resale of unprocessed rice (`S5`), a non-creditable business
promotion expense (`P2`), an exempt purchase from a farming cooperative
(`P4`) and an import cleared through customs (`P5`) each appear once. Three
payments: one inbound and one outbound settling a document exactly, and one
inbound payment matching nothing, an advance the golden test needs to prove
an unmatched settlement still balances.

## For a reviewer, in this order

1. The quarterly reading of 제48조/제49조 against the NTS's own filing
   calendar, and the choice to leave 예정고지 out rather than mis-model it as
   a filing.
2. The eight tax codes against 부가가치세법 제21조, 22조, 23조, 26조, 30조,
   39조, 50조 — in particular whether 제26조제1항 1호 (unprocessed food) is the
   right illustration of the exemption, since this pack did not verify every
   item of that list against the primary text.
3. The chart of accounts and the two statements: original, not a transcription
   of a KASB table this pack could fetch in full — the detailed line-by-line
   presentation of 일반기업회계기준 was not independently verified past its
   current/non-current principle, and a Korean accountant should confirm the
   statement lines against a filed 재무제표.
4. The `einvoicing` gap and its reasoning against Mexico's own CFDI section
   of `docs/international.md`.
5. The rounding rule (`down`, at the won, citing 국고금 관리법 제47조) against
   how a Korean accounting package actually truncates a VAT computation.
