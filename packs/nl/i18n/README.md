# `packs/nl/i18n/` — the Dutch pack in English

`pack.json` declares `"languages": ["en"]`, and `ekwo pack check` holds the
file to that promise: every account, journal, tax, box of the return, line of
the two statements and sentence of an invoice has an English label. The pack's
own files are written in Dutch, which is what `defaults.language` says, because
Dutch is the language of every text they transcribe.

## Where the wording comes from

**The boxes of the VAT return are the Belastingdienst's own English**, from the
*Explanatory notes to the VAT return 2026* it publishes in the same document as
the Dutch *Toelichting* — *Supplies/services subject to the high VAT rate*,
*Supplies/services where the VAT has been reversed to you*, *Input VAT*. Where
a rubric has a turnover column and a VAT column, the column is added after a
dash. 5a and 5g have no English wording in that document and were translated
here.

**Everything else was translated for this pack** and has no official standing:
the RGS publishes Dutch descriptions only (its English dataset labels the
taxonomy concepts an account maps to, not the account), the models of the
*Besluit modellen jaarrekening* exist in Dutch only, and no text prescribes an
English wording for a journal, a tax code or an invoice sentence.

That matters most for the invoice. *«btw verlegd»* is the wording article 35a,
point m, of the VAT law prescribes; *VAT reverse-charged* says the same thing
and is not what the law asks for. An invoice issued under Dutch law carries the
Dutch sentence.
