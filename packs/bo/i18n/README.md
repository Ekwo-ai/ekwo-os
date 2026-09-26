# Where each language of the Bolivian pack comes from

The pack itself is written in Spanish, which is `defaults.language`. Bolivia
prescribes no official chart of accounts (see the README), so the account
names in `accounts.csv` are this pack's own wording, not a transcription of a
government text; the statement lines are named by this pack as well. The
boxes of the declaration keep the exact wording of the Servicio de Impuestos
Nacionales' *Formulario 200 v.5 Extendido*, where the pack declares an
official casilla, and say plainly when a box is this pack's own bookkeeping
device rather than one of the form's.

## `en.json`

English is declared in `pack.json`, so it covers every label of the pack and
`ekwo pack check` fails if it stops doing so.

**None of it is official.** Bolivia publishes no English version of the
Ley N.° 843, of the Formulario 200 or of any chart of accounts — there being
no official chart to translate in the first place. Every English label here
is a translation for a reader and never for a filing. Bolivian terms that
have no natural English equivalent keep their own name beside the
translation where it helps: IVA, IUE, NIT, RC-IVA.

## Not carried

No other language. A contributor may add one file per language, one section
at a time, without declaring it in `pack.json` until it is complete.
