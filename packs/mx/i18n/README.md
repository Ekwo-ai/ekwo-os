# Where each language of the Mexican pack comes from

The pack itself is written in Spanish, which is `defaults.language`. The
account names in `accounts.csv` are the wording of the *código agrupador de
cuentas del SAT* as published in Anexo 24 of the Resolución Miscelánea Fiscal
para 2026 (DOF, 13 January 2026), unchanged. The statement lines are the names
of the same code's major accounts, with totals named by this pack. The field
names of the declaration are those of the SAT's filling guide for the monthly
*IVA personas morales* declaration (March 2024).

## `en.json`

English is declared in `pack.json`, so it covers every label of the pack and
`ekwo pack check` fails if it stops doing so.

**None of it is official.** Mexico publishes no English version of the
grouping code, of the Value Added Tax Act or of the declaration. Every English
label here is a translation for a reader and never for a filing. The Mexican
terms that have no English equivalent keep their name beside the translation
where it helps: *aguinaldo*, IMSS, INFONAVIT, SAR, PTU.

## Not carried

No other language. A contributor may add one file per language, one section
at a time, without declaring it in `pack.json` until it is complete.
