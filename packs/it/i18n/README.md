# Where each language of the Italian pack comes from

The pack itself is written in Italian, which is `defaults.language`. The
statement line names are close to the wording of art. 2424 and art. 2425 of
the Codice civile; the tax report box names are those printed on the
Modello IVA 2026 (Agenzia delle Entrate). The account names are this pack's
own choice, since Italy publishes no official piano dei conti to transcribe
— see the README.

## `en.json`

English is declared in `pack.json`, so it covers every label of the pack
and `ekwo pack check` fails if it stops doing so.

**None of it is official.** Italy publishes no English version of the Codice
civile, of D.P.R. 633/1972 or of the Modello IVA. Every English label here
is a translation for a reader and never for a filing; where an English term
of art exists (*reverse charge*, *intra-Community acquisition*, *severance
provision*) it is used rather than a literal rendering of the Italian.

## Adding a language

A file not declared in `pack.json` may be partial: a key it does not carry
falls back to the pack's own Italian label, which is how a language is
contributed one section at a time — an account, a tax, a box, a statement
line, a mention — without translating the whole pack in one pull request.
