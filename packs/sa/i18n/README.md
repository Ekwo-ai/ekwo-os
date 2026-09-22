# Where each language of the Saudi Arabia pack comes from

The pack is written in English, which is `defaults.language`, and **the law it
transcribes is Arabic**. That is the opposite of most packs here and it is
worth saying plainly: the Value Added Tax Law and its Implementing Regulations
are enacted in Arabic, and ZATCA's own English translation of the Regulations
carries the warning on its title page — "this English document serves as an
unofficial translation of the official published Arabic version. In case of
any discrepancies between this version and the official Arabic version, the
information included in the official Arabic version supersedes." Every quoted
sentence in `taxes.json` and `tax_report.json` is that English, and a reviewer
who disagrees with one should read the Arabic article beside it.

Two places where the Arabic and the English actually part company were found
in this research pass, and both are recorded where they matter:

- **The rate.** No English text of the VAT Law could be opened at all: the
  bilingual PDF the Authority's own VAT Law page links to returns an error
  page. Article 2(2) is therefore quoted in Arabic in `SA-S-SR`, from the
  consolidated Arabic text ZATCA serves.
- **The correction threshold.** The English eighth edition of the Regulations
  (November 2021) still prints 5,000 riyals in Article 63; the Arabic tenth
  edition of April 2025 and ZATCA's filing guideline both say 15,000. Field 14
  of the return carries 15,000 and says why.

## No `ar.json` in this release, and it is not for want of a source

`pack.json` declares `"languages": []` and there is no `i18n/ar.json`. The
reason is not that the Arabic wording is unavailable — ZATCA publishes it, and
it is transcribed below — but that this format cannot hold the file that
wording would make. `docs/packs.md` says a translation file the manifest does
not declare "may be partial, which is how a language is contributed one
section at a time", and `ekwo pack check` accepts one. The compiler then writes
its labels into the seed anyway, and `tests/languages.test.ts` refuses a seed
carrying a language the manifest does not declare — "a label under a language
nobody declared is a label nobody maintains". The two rules are each defensible
and they close every door between them: a partial file is refused by the tests,
and a declared one has to cover every key, which here would mean inventing
Arabic names for 115 accounts of a chart no authority publishes, for the fields
of a return whose own labels could not be read, and for two invoice mentions
this pack wrote itself — where Article 53(5) of the Implementing Regulations
requires the details it lists to be printed **in Arabic**. An invented Arabic
mention would be this pack's translation of this pack's sentence, presented as
the wording a Saudi invoice must carry. `docs/international.md` records the
gap under "From Saudi Arabia".

## The Arabic that is sourced, for whoever fills this in

Every line below is ZATCA's own Arabic, copied from the Electronic Invoice XML
Implementation Standard v1.2, section 11.2.4, which prints the Arabic of each
VAT category and of each VATEX-SA exemption reason beside its English — except
the two real estate lines, which come from the simplified Arabic filing
guideline, where بيع العقارات and تأجير العقار السكني are distinguished. The
country's own name, المملكة العربية السعودية, is the VAT Law's, Article 1.

| Tax | ZATCA's Arabic |
|---|---|
| `SA-S-SR` | التوريدات الخاضعة للضريبة |
| `SA-S-ZR-EXP` | صادرات السلع من المملكة |
| `SA-S-ZR-SVC` | صادرات الخدمات من المملكة |
| `SA-S-ZR-TRANSPORT` | النقل الدولي للسلع والنقل الدولي للركاب |
| `SA-S-ZR-MED` | الأدوية والمعدات الطبية |
| `SA-S-ZR-METAL` | المعادن المؤهلة |
| `SA-S-EX-FIN` | الخدمات المالية |
| `SA-S-EX-RESI` | تأجير العقار السكني |
| `SA-S-EX-REALESTATE` | بيع العقارات |
| `SA-S-OS` | التوريدات الغير خاضعة للضريبة |

One of them is a join and not a quotation: `SA-S-ZR-TRANSPORT` covers the
international transport of both goods and passengers, which the standard codes
separately (VATEX-SA-34-1 and VATEX-SA-34-2) with a label each, and the line
above is those two joined by و.

Nothing here covers the accounts, the journals, the statement lines, the boxes
of the return or the legal mentions. Whoever adds `ar.json` should read the
Arabic Regulations for those and cite them in the file's own `source`, the way
this pack's English `legal_reference` fields cite the English ones.
