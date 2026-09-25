# Where each language of the Peruvian pack comes from

The pack itself is written in Spanish, which is `defaults.language`. The
account names in `accounts.csv` are the official names of the Plan Contable
General Empresarial modificado 2019, approved by Resolución N.° 002-2019-EF/30
of the Consejo Normativo de Contabilidad, unchanged where the pack keeps the
official code and shortened only where a name repeats its parent's word for
word. The statement lines are named by this pack; the boxes of the
declaration keep the exact wording of the SUNAT's *Ayuda para el registro del
Formulario Virtual N.° 621 — IGV Renta Mensual*.

## `en.json`

English is declared in `pack.json`, so it covers every label of the pack and
`ekwo pack check` fails if it stops doing so.

**None of it is official.** Peru publishes no English version of the Plan
Contable General Empresarial, of the Ley del IGV or of the Formulario Virtual
N.° 621. Every English label here is a translation for a reader and never for
a filing. Peruvian terms that have no natural English equivalent keep their
own name beside the translation where it helps: IGV, ESSALUD, ONP, CTS.

## Not carried

No other language. A contributor may add one file per language, one section
at a time, without declaring it in `pack.json` until it is complete.
