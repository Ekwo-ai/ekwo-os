# Indonesia

Everything Indonesia adds to Ekwo, as data: an original chart of accounts for
a country whose accounting standards prescribe no numbered chart, the
journals, Pajak Pertambahan Nilai (PPN) at its 2025 rates — the 12 % nominal
rate applied to a reduced "nilai lain" base that nets to an effective 11 %
for most goods and services, and the full 12 % on barang mewah tertentu — the
0 % export rate, the PP 49/2022 exemption, the SPT Masa PPN return (Formulir
1111), and the balance sheet and income statement a company reports. The
format is [`docs/packs.md`](../../docs/packs.md); this file says where the
content came from and which decisions it rests on, so that an Indonesian
accountant reading the pack can disagree with a specific sentence rather than
with the whole of it.

**Status: `community`.** Nobody who files an Indonesian VAT return has
reviewed it. The figures are replayed against a quarter of books by
`tests/golden.test.ts`, which proves the pack is internally coherent and
proves nothing about whether it is right.

**Language: `id`.** Every name, mention and `legal_reference` is written in
Indonesian, the language the law itself is written in. No English translation
(`i18n/en.json`) is published with this first version, so `languages` is
empty. The chart of accounts and the two financial statements carry no
official rendering in any language to fall back on either, in Indonesian or
in English: Indonesia prescribes no numbered chart of accounts by statute (see
"The chart of accounts" below), so there is no official wording to transcribe
in the first place.

**Read [`docs/international.md`](../../docs/international.md), section
"Indonesia", before relying on this pack.** It lists what the core cannot say
that this README only names.

## Sources

Every tax, box, mention and statement line carries its own `legal_reference`,
and beside it the key of the text that article is in. The register in
`pack.json` holds eleven texts, opened on 25 September 2026.

| What | Text | Where |
|---|---|---|
| The tax itself — the base law, its 2021 amendment, the rates, the export rate, exemptions | Undang-Undang Nomor 42 Tahun 2009 (base numbering) as amended by Undang-Undang Nomor 7 Tahun 2021 (UU HPP) | `peraturan.bpk.go.id` |
| The 12 %/11 % "nilai lain" mechanism, and the full 12 % on barang mewah tertentu | Peraturan Menteri Keuangan Nomor 131 Tahun 2024, in force 1 January 2025 (barang mewah: 1 February 2025) | `jdih.kemenkeu.go.id` |
| The PP 49/2022 exemption | Peraturan Pemerintah Nomor 49 Tahun 2022 | `peraturan.bpk.go.id` |
| The small-business VAT registration threshold (Rp 4.8 billion) | Peraturan Menteri Keuangan Nomor 197/PMK.03/2013 | `peraturan.bpk.go.id` |
| Filing periods and the general filing deadline | Undang-Undang Nomor 6 Tahun 1983 (UU KUP) as amended, Pasal 3 ayat (3) huruf b | `peraturan.bpk.go.id` |
| Coretax, the e-Faktur clearance mechanism, and the payment deadline (15th) | Peraturan Menteri Keuangan Nomor 81 Tahun 2024 and Peraturan Direktur Jenderal Pajak Nomor PER-11/PJ/2025 | `jdih.kemenkeu.go.id`, `pajak.go.id` |
| The return itself, Formulir 1111 | Peraturan Direktur Jenderal Pajak Nomor PER-29/PJ/2015 | `pajak.go.id` |
| The financial reporting framework | Kerangka Standar Pelaporan Keuangan Indonesia, PSAK 201 (formerly PSAK 1), SAK EMKM | `web.iaiglobal.or.id` |

**Three gaps in the sources above are deliberate rather than silent, and are
the first things for a reviewer to check.**

- **The consolidated text of UU KUP Pasal 3 ayat (3) huruf b**, after its
  amendment by UU HPP, was not read directly from an official PDF this
  session. The rule this pack states — a monthly VAT return is due on the
  last day of the month following the tax period, distinct from the 20-day
  general rule and from the 15th-of-the-month payment deadline of PMK
  81/2024 — comes from two independent secondary sources that agree with
  each other and with long-standing professional practice, not from the
  statute's own words.
- **The exact screen layout of the SPT Masa PPN inside Coretax** was not
  read this session: Coretax DJP renders through client-side script that the
  tools available here could not execute. `tax_report.json` transcribes the
  box structure of Formulir 1111 (PER-29/PJ/2015), which PMK 81/2024 and
  PER-11/PJ/2025 carry forward in substance into Coretax without renumbering
  the underlying calculation (Pajak Keluaran, Pajak Masukan, kurang/lebih
  bayar) — but the pack's box identifiers (`A1`, `1`, `4`, `5`...) have not
  been checked field-by-field against a live Coretax filing.
- **The exact list of "barang mewah tertentu" taxed at the full 12 %** under
  PMK 131/2024 Pasal 5, and the exact list of goods and services under PP
  49/2022, were not traced line by line against their own annexes this
  session; both taxes that depend on them (`ID-S-12-LUX`, `ID-S-EXEMPT`)
  carry `conditions: ["supply_nature"]` rather than that list.

## Decisions this pack takes

**The 12 %/11 % mechanism is modelled as a single effective rate, not as a
two-step multiplication.** Undang-Undang Nomor 42 Tahun 2009 sets the nominal
rate at 12 % (Pasal 7 ayat (1)); PMK 131/2024 then sets the tax base for most
goods and services at "nilai lain" of 11/12 of the selling price (Pasal 2-3),
so that 12 % × (11/12 × harga jual) = 11 % × harga jual. Ekwo's tax format has
one `rate` multiplied by one base with no second fraction, so `ID-S-11` and
`ID-P-11` carry the rate `11` directly. The ledger and the return come to the
same figures a business filing under the real mechanism would report; what is
not reproduced is the "nilai lain" step itself as a separate figure on the
document. `ID-S-12-LUX` carries the nominal `12` because PMK 131/2024 Pasal 5
does not reduce the base for barang mewah tertentu sold to a final consumer.

**No `einvoicing.profile` is declared**, the same choice `packs/vn` and
`packs/mx` made for their own clearance systems. A Faktur Pajak is created
and validated in real time by Coretax DJP before it reaches the buyer — the
tax authority issues the document's own serial number at validation — and
none of Ekwo's profiles (`peppol-bis-3`, `factur-x-en16931`, `pint-*`)
describe that. Declaring one anyway would make `describePack()` tell an
installer that Ekwo writes and transmits a valid Faktur Pajak, which it does
not.

**The chart of accounts is original**, the same choice `packs/th` made.
Indonesia has no statute prescribing a numbered chart: Undang-Undang Nomor 40
Tahun 2007 (Perseroan Terbatas) and Undang-Undang Nomor 8 Tahun 1997
(Dokumen Perusahaan) require bookkeeping and record-keeping, and PSAK 201
(formerly PSAK 1, Ikatan Akuntan Indonesia) fixes the structure and minimum
content of a set of financial statements — current/non-current, the line
items a balance sheet and an income statement must show — never a code. This
pack's `accounts.csv` is therefore four digits by class (1 aset, 2
liabilitas, 3 ekuitas, 4 pendapatan, 5 beban pokok penjualan, 6 beban usaha,
7 pendapatan/beban lain-lain, 8 beban pajak penghasilan), and `ID-LK-BS` /
`ID-LK-LR` group those classes into the current/non-current structure PSAK
201 asks for, rather than transcribing a numbered line item of an official
scheme the way the Vietnamese or the Belgian chart does. PSAK 201's own full
paragraph-by-paragraph minimum line list, and SAK EMKM as the simplified
framework a micro or small entity may use instead, were not read line by line
this session.

**PPN JLN (pemanfaatan Jasa Kena Pajak dari luar Daerah Pabean) is booked and
credited on the same document**, the same simplification `packs/th` makes for
its own section 83/6 tax (`TH-P-RC`). Undang-Undang Nomor 42 Tahun 2009,
Pasal 3A ayat (3) requires the buyer to collect, remit and report the tax
themselves; in practice the remittance and the credit are not always
instantaneous. `ID-P-RC` overstates how quickly the credit is available
compared to the administrative timing, which is named here rather than
modelled.

**Import VAT is carried on the invoice value, not the customs value.**
`ID-P-IMP-11` computes 11 % of the supplier's invoice amount; the actual
Nilai Impor a business self-assesses at customs adds import duty and other
levies the invoice does not carry, so a real import's tax base is larger than
what this code computes on the document alone — the same simplification
`packs/vn` names for `VN-P-IMP-10`.

**The government VAT-withholding mechanism (Pemungut PPN, Pasal 16A) and
"tidak dipungut" facilities (bonded zones and special economic zones) are not
modelled.** Boxes I.A.3 and I.A.4 of Formulir 1111 exist in `tax_report.json`
only implicitly, folded into the `IA` total; no tax code of this pack posts
to them. A company that sells to a government treasury or ships into a
bonded zone needs a professional to check how that changes its return.

**Barang mewah subject to Pajak Penjualan atas Barang Mewah (PPnBM) itself is
not modelled.** `ID-S-12-LUX` carries only the Pajak Pertambahan Nilai on a
luxury sale; the separate luxury sales tax (Bagian V of Formulir 1111) that
some of the same goods also carry is a distinct tax this pack does not
compute.

## The golden scenario

One quarter (January-March 2026) of a general trading company: a domestic
sale at the general effective 11 % rate, a sale of a luxury motor vehicle
taxed at the full 12 %, an export sale at 0 %, a sale of a staple good
exempted under PP 49/2022, a sale credit note, a domestic purchase of trading
goods, an imported production machine with import VAT self-paid to customs,
a foreign software subscription self-assessed under Pasal 3A ayat (3), a
purchase from a non-PKP supplier who charges no VAT at all, and a purchase
credit note. Ten documents and three payments, chosen so that every box of
the declaration this pack carries is reached at least once, and so that a
matched and an unmatched payment both survive into the return.

## For an Indonesian accountant to check first

1. The box structure of `tax_report.json` against a live Coretax filing of
   the SPT Masa PPN, not only against the pre-Coretax Formulir 1111 PDF —
   see "Sources" above.
2. The exact list of barang mewah tertentu taxed at the full 12 % (PMK
   131/2024 Pasal 5) and of goods/services covered by the PP 49/2022
   exemption, against `ID-S-12-LUX` and `ID-S-EXEMPT`.
3. Whether the deadline this pack states for the SPT Masa PPN — the last day
   of the month following the tax period — still reads correctly against the
   consolidated text of UU KUP Pasal 3 ayat (3) huruf b.
4. The account names of `accounts.csv` against PSAK 201 and, for a small
   business, SAK EMKM, since neither was read line by line when this pack
   was written.
5. Whether the Pemungut PPN mechanism (Pasal 16A) or a bonded-zone facility
   applies to the company's own customers or supply chain, neither of which
   this pack computes.
