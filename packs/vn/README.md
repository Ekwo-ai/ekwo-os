# Việt Nam

Everything Vietnam adds to Ekwo, as data: a chart of accounts blocked onto the
account classes of the Vietnamese Accounting System, the journals, the value
added tax with its 0 %, 5 % and 10 % rates and the temporary 8 % reduction of
Resolution No. 204/2025/QH15, the VAT return Mẫu số 01/GTGT, the balance sheet
and income statement of Circular 99/2025/TT-BTC, and the sentences the law
puts on an invoice. The format is [`docs/packs.md`](../../docs/packs.md); this
file says where the content came from and which decisions it rests on, so that
a Vietnamese accountant reading the pack can disagree with a specific sentence
rather than with the whole of it.

**Status: `community`.** Nobody who files a Vietnamese VAT return has
reviewed it. The figures are replayed against a quarter of books by
`tests/golden.test.ts`, which proves the pack is internally coherent and
proves nothing about whether it is right.

**Language: `vi`.** Every name, mention and `legal_reference` is written in
Vietnamese, the language the law itself is written in; no English translation
(`i18n/en.json`) is published with this first version, so `languages` is
empty. The chart of accounts and the two financial statements carry no
official English rendering to fall back on either — Circular 99/2025/TT-BTC,
like the Circular it replaces, exists only in Vietnamese.

**Read [`docs/international.md`](../../docs/international.md), section
"Vietnam", before relying on this pack.** It lists what the core cannot say
that this README only names.

## Sources

Every tax, box, mention and statement line carries its own `legal_reference`,
and beside it the key of the text that article is in. The register in
`pack.json` holds thirteen texts, opened on 22 September 2026.

| What | Text | Where |
|---|---|---|
| The tax itself — rates, exemptions, the 0 % export rate, the two calculation methods, the tax point | Luật Thuế giá trị gia tăng số 48/2024/QH15 (in force 1 July 2025), as amended by Luật số 149/2025/QH15 (1 January 2026) and Luật số 09/2026/QH16 (2026) | `datafiles.chinhphu.vn` |
| The temporary 2-point reduction (10 % → 8 %) | Nghị quyết số 204/2025/QH15 and Nghị định số 174/2025/NĐ-CP, 1 July 2025 to 31 December 2026 | `xaydungchinhsach.chinhphu.vn`, `datafiles.chinhphu.vn` |
| Electronic invoicing, the tax authority's verification code, the invoice lottery | Nghị định số 123/2020/NĐ-CP, as amended by Nghị định số 70/2025/NĐ-CP (1 June 2025) | `datafiles.chinhphu.vn`, mirror at `hethongphapluat.com` |
| Filing periods and deadlines | Luật Quản lý thuế số 38/2019/QH14, Điều 44, and Nghị định số 126/2020/NĐ-CP, Điều 9 | mirror at `hethongphapluat.com` |
| The VAT return itself, Mẫu số 01/GTGT | Thông tư 80/2021/TT-BTC (Phụ lục II) and, from 1 July 2026, Thông tư 89/2026/TT-BTC (Phụ lục I) | `thuvienphapluat.vn` |
| The chart of accounts and the two statements | Thông tư số 99/2025/TT-BTC (1 January 2026), replacing Thông tư 200/2014/TT-BTC | `congbao.chinhphu.vn` |

**Two of the six rows above rest on a text this pack could not read in full,
and the gap is deliberate rather than silent — both are the first thing for a
reviewer to check.**

- **Nghị định số 123/2020/NĐ-CP** (the base e-invoicing decree, before its
  2025 amendment) was read from a mirror
  (`hethongphapluat.com`) rather than from a signed PDF on `chinhphu.vn`: the
  government's own document server refused every guessed URL for this
  particular text during this pack's research. Điều 8, 9 and 10 (the kinds of
  invoice, the time of issue, the mandatory particulars) were read there in
  full; whether Nghị định 70/2025/NĐ-CP amended those three articles
  specifically could not be confirmed and is not assumed here.
- **The exact box table of Mẫu số 01/GTGT** — the annex itself, not the
  articles that create it — could not be read from an official source for
  either Thông tư 80/2021/TT-BTC or the Thông tư 89/2026/TT-BTC that replaced
  it on 1 July 2026. `tax_report.json` transcribes the skeleton (chỉ tiêu
  [22]-[43]) that has been stable across Vietnamese VAT practice for a decade,
  cross-checked against two independent research passes on 22 September 2026,
  and **not** against the annex's own PDF. A local accountant should confirm
  the box numbers and labels against a current HTKK export or the Phụ lục I
  of Thông tư 89/2026/TT-BTC before this pack is used to prepare a real
  filing.

## Decisions this pack takes

**The temporary 8 % rate shares the same declaration boxes as the 10 % rate**
(`VN-S-8-NQ204` / `VN-P-8-NQ204` post to chỉ tiêu [31]/[32], the same as
`VN-S-10` / `VN-P-10`). Resolution 204/2025/QH15 reduces the rate on eligible
goods and services without moving them to a different line of the return; the
alternative — a rate-specific box — was not found in either the Resolution or
Decree 174/2025/NĐ-CP and is not invented here. What is genuinely not carried
is the exclusion list itself: Decree 174/2025/NĐ-CP's Phụ lục I and Phụ lục
II give the reduction's exceptions by HS code and by sector (telecoms,
finance, insurance, real estate, metal products, extractive products other
than coal, goods subject to special consumption tax other than petrol), and
`VN-S-8-NQ204` / `VN-P-8-NQ204` carry `conditions: ["supply_nature"]` rather
than that list: whether a given line qualifies for the reduced rate is a
question about what is sold, which the ledger does not answer on its own.

**No `einvoicing.profile` is declared**, the same choice `packs/mx` and
`packs/ci` made for their own clearance systems. Vietnam's hóa đơn điện tử có
mã của cơ quan thuế is a real-time clearance mechanism — the tax authority
issues a verification code before the invoice reaches the buyer — and none of
Ekwo's profiles (`peppol-bis-3`, `factur-x-en16931`, `pint-*`) describe that.
Declaring one anyway would make `describePack()` tell an installer that Ekwo
writes and transmits a compliant Vietnamese e-invoice, which it does not.

**The foreign contractor withholding (thuế nhà thầu nước ngoài) is not
modelled.** Thông tư 103/2014/TT-BTC, the text that has governed it for over
a decade, appears from several convergent professional sources to lose effect
on 1 July 2026, superseded by a text this pack's research could not identify
with certainty — two different circular numbers were found in secondary
sources, neither confirmed on an official page. Rather than code a withholding
tax against a citation that might be wrong on 22 September 2026, the pack
carries none, and the gap is recorded in `docs/international.md`.

**Import VAT is carried for the standard rate only** (`VN-P-IMP-10`). A
complete pack would want one code per rate, the way `packs/jp` does for its
own import tax, and codes for the 5 % and 0 % rates on imported goods are not
included here — a narrower scope than a `maintained` pack would want, named
rather than hidden.

## The golden scenario

One quarter (Q2 2026) of a limited-liability company on the deduction method
(phương pháp khấu trừ): domestic sales at 10 %, at the temporary 8 %, and at
5 %; an export at 0 %; an exempt sale (tuition, Điều 5 khoản 13); a sale
credit note; domestic purchases at 10 %, 8 % and 5 %; a purchase from a
VAT-exempt supplier (a bank); an imported machine with import VAT paid to
customs; and a purchase credit note. Twelve documents and three payments,
chosen so that every box of the declaration this pack carries is reached at
least once.

## For a Vietnamese accountant to check first

1. The box table of Mẫu số 01/GTGT against the Phụ lục I of Thông tư
   89/2026/TT-BTC — see "Sources" above.
2. Whether reduced-rate sales/purchases under Resolution 204/2025/QH15 are
   in practice reported on the same line as the 10 % rate, or on a line of
   their own that this pack has not found.
3. The account codes and names of Circular 99/2025/TT-BTC against this
   pack's `accounts.csv`, transcribed from the well-established Thông tư
   200/2014/TT-BTC numbering on the strength of a partial reading of
   Circular 99/2025/TT-BTC confirming that numbering is largely carried
   forward — not checked account by account.
4. Whether the successor to Thông tư 103/2014/TT-BTC (foreign contractor
   withholding) is now in force, and its rates.
