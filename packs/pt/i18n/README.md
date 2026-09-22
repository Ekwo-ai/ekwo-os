# Where each language of the Portuguese pack comes from

The pack itself is written in Portuguese, which is `defaults.language`. The
account names in `accounts.csv` follow the terminology of the SNC's Código de
Contas (Portaria n.º 1011/2009, de 9 de setembro), transcribed at the level of
detail this pack carries — see the pack's own `README.md` for what that
selection is and is not. The declaration boxes follow the wording of the
Declaração Periódica do IVA (Portaria n.º 221/2017).

## `en.json`

English is declared in `pack.json`, so it covers every label of the pack and
`ekwo pack check` fails if it stops doing so.

**None of it is official.** Portugal publishes no English version of the SNC,
of the Código do IVA or of the Declaração Periódica do IVA. Every English
label here is a translation for a reader and never for a filing; where an
English term of art exists (*reverse charge*, *intra-Community acquisition*,
*self-billing*) it is used.

## Not carried

No other language was looked for. A contributor may add one, one section at a
time, without declaring it in `pack.json` until it covers the whole pack.
