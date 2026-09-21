# Where each language of the Spanish pack comes from

The pack itself is written in Spanish (castellano), which is
`defaults.language`. The account names in `accounts.csv` are the official
wording of the PGC's *cuadro de cuentas* (Real Decreto 1514/2007, fourth part),
with one change: the subgroup headings the BOE prints in capitals are written
in sentence case, and the missing space of *DONACIONESY LEGADOS* (subgroup 74)
is restored. The statement lines are the wording of the abridged models of the
third part; the box names are those printed on form 303 (Orden HAC/27/2026,
annex III).

## `en.json`

English is declared in `pack.json`, so it covers every label of the pack and
`ekwo pack check` fails if it stops doing so.

**None of it is official.** Spain publishes no English version of the PGC, of
the VAT Act or of form 303, and the Agencia Tributaria's English pages are
information, not the form. Every English label here is a translation for a
reader and never for a filing; where an English term of art exists (*reverse
charge*, *equivalence surcharge*, *intra-Community acquisition*) it is used.

## Not carried

Catalan, Galician and Basque are co-official in their communities. They are
out of scope for this pack, and no wording in them was looked for; a
contributor may add `ca.json`, `gl.json` or `eu.json` one section at a time
without declaring them.
