# Where each language's wording comes from

**Arabic** (`defaults.language`) is the pack's own language, and every
account, journal, tax, box, statement line and mention name is written in it
directly in `accounts.csv`, `pack.json`, `taxes.json`, `tax_report.json` and
`statements.json` — Arabic is the language Legislative Decree No. (48) of
2018 and its Executive Regulations are enacted in, and the language the
National Bureau for Revenue's own portal and forms are published in first.

**English** (`en.json`) is this pack's own translation of every one of those
labels. The National Bureau for Revenue also publishes an English rendering
of the Law, the amending Law and its own VAT General Guide — the texts this
pack's `legal_reference` fields lean on throughout — so a reader who works
from those English texts can follow the chart, the taxes and the return
without reading Arabic. It is not itself an official Bahraini chart of
accounts or tax-code list: no such English original exists to translate
from, the same gap `packs/ae`, `packs/sa` and `packs/eg` record for their
own charts.

The `legal_reference` and `description` fields of this pack are written in
English throughout, in both languages' files alike: they are this pack's own
research notes on where a rule comes from, not a label the `i18n` mechanism
translates.
