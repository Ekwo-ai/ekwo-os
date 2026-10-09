# Where each language's wording comes from

**English** (`defaults.language`) is the pack's own language. The Value Added
Tax Act 1998, the Value Added Tax (E-invoicing) Regulations 2023, form VAT 3
and the guidance of the Mauritius Revenue Authority are all published in
English, so every account, journal, tax, box and statement line is written in
English directly in `accounts.csv`, `pack.json`, `taxes.json`,
`tax_report.json` and `statements.json`.

**French** (`fr.json`) is this pack's own translation of every one of those
labels, declared in `pack.json` and complete. French is widely used in
Mauritian business and in the accounting profession, but no official French
edition of a chart of accounts, a tax code list or the VAT 3 return exists to
transcribe from, so the wording is the pack's own and carries no authority. The
statutory mention `VAT INVOICE` stays in English because section 20(2)(a) of the
Act prescribes those words.

The `legal_reference` and `description` fields are written in English in both
cases: they are research notes on where a rule comes from, and the texts they
cite are English.
