# Where each language's wording comes from

The pack's own files are written in German (`defaults.language: "de"`), the
language this pack's research read the law in most closely. `pack.json`
declares one more, `fr`, which this directory carries complete — a declared
language is a promise `ekwo pack check` holds the pack to keeping, covering
every account, journal, tax, box, chart and statement line, so `fr.json` is
either complete or not committed.

**The taxes and the boxes of the return** are transcribed, not translated:
ESTV itself publishes both in French, and the wording here is the word it
prints beside the same box number or the same article. Two documents this
pack's own register already cites: the French text of the
Mehrwertsteuergesetz (the "Loi sur la TVA (LTVA)", the same law, same article
numbers, a different official language of it —
`fedlex.admin.ch/eli/cc/2009/615/fr`) and the French specimen of form
No. 4470 (`mwst-form-abr-muster-2024-4470-eff-fr.pdf`, the same PDF
`tax_report.json` reads its box numbers from, in its French edition).

**The chart, the journals and the two statements' lines** have no official
French wording to transcribe: Art. 959/959b OR names only the lettered items
of its own minimal structure, not a chart of accounts, and this pack's chart
is original — see the main [`README.md`](../README.md). Their French labels
are this pack's own translation of its German ones, in the vocabulary of
Swiss commercial French (a "compte" of "produits nets des ventes", not a
Parisian PCG term where the two differ).

**Italian is not shipped.** A declared language with a missing key is
refused by `ekwo pack check`, so a `de`-only pack with an incomplete
`it.json` committed alongside it would fail to build; better an honest gap
than a file that looks like a translation and is not one throughout. The
standard Italian terms of the Legge federale concernente l'imposta sul
valore aggiunto (LIVA) — the law's third official text — are the place to
start a complete `it.json`: aliquota normale, aliquota ridotta, aliquota
speciale per il settore alberghiero, imposta sull'acquisto, imposta
sull'importazione.
