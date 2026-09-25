# Where the wording of `packs/gr` comes from

The pack's own files are written in `el`, the language its `defaults.language`
declares — the language the Greek VAT Code, the Φ2 form and the AADE
circulars this pack transcribes are themselves published in.

## `en.json`

Nothing official is being translated: the Hellenic Republic publishes the VAT
Code, the Φ2 form and its instructions in Greek only, and AADE's own English
pages (`aade.gr/en`) are a reader's aid, not a second authentic text. Every
English label here is therefore this pack's own rendering, chosen for
somebody reading the chart or the return without Greek, and never a wording
to file anything with. Where English accounting usage already has a settled
term for a Greek mechanism, that term is used rather than a literal
translation — "reverse charge" for *αντίστροφη επιβάρυνση*, "output VAT" /
"input VAT" for *ΦΠΑ εκροών* / *ΦΠΑ εισροών*, "intra-Community supply" for
*ενδοκοινοτική παράδοση*.

The account names follow the two-digit subgroups of the ΕΓΛΣ (see
`../README.md`), so their English rendering follows the ΕΓΛΣ wording rather
than the (different) captions of the IFRS for SMEs framework this pack's
chart falls back to for its statements.

## Adding a language

A file that `pack.json`'s `languages` array does not declare — any language
besides `el` and `en` — may be partial: a key it does not carry falls back to
the pack's own Greek label. `el.json` is not needed and would not compile: the
pack's own files already speak Greek, and `ekwo pack check` refuses a
declared language that is the pack's own `defaults.language`.
