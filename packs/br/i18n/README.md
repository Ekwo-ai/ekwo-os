# Where each language of the Brazilian pack comes from

The pack itself is written in Brazilian Portuguese, which is `defaults.language`
(`pt`). The account names in `accounts.csv` use the terms of the Civil Code
(Lei nº 10.406, de 2002, arts. 1.179 to 1.189), of Law 6.404/1976 (arts. 178,
179 and 187) and of the Simples Nacional statute (Lei Complementar nº 123, de
2006); the chart itself is original — see the pack's own `README.md`.

## `en.json`

English is declared in `pack.json`, so it covers every label of the pack and
`ekwo pack check` fails if it stops doing so.

**None of it is official.** Brazil publishes no English version of these
texts. Every English label here is a translation for a reader and never for a
filing; Brazilian names with no English equivalent (Simples Nacional, DAS,
INSS, FGTS, ISS, IRRF, IOF, IPTU, IPVA, NF-e, NFS-e) are kept and explained in
brackets where a reader needs it.

## Not carried

No other language was looked for. A contributor may add one, one section at a
time, without declaring it in `pack.json` until it covers the whole pack.
