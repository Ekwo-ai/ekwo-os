# OHADA — the chart seventeen countries share

Benin, Burkina Faso, Cameroon, the Central African Republic, Chad, the
Comoros, the Congo, Côte d'Ivoire, the Democratic Republic of the Congo,
Equatorial Guinea, Gabon, Guinea, Guinea-Bissau, Mali, Niger, Senegal and Togo
keep their books on one chart of accounts: the **SYSCOHADA révisé**, annexed to
the *Acte uniforme relatif au droit comptable et à l'information financière*
(AUDCIF) adopted on 26 January 2017, in force for the accounts of an entity
since 1 January 2018 (AUDCIF, art. 113). They present them in one balance sheet
and one income statement. What differs from one to the next is the tax.

This folder is that common part, written once. **It is not a pack**:
`listPacks()` reads two-letter folders only, the compiler never opens this one,
and every member pack stays autonomous — it carries its own copy and compiles
on its own, as [`decisions.md`](../../docs/decisions.md) wants of a pack.
`scripts/ohada-packs.mjs` writes the copies, and the CI refuses a member whose
copy has drifted.

| File | Is |
|---|---|
| `accounts.csv` | the chart, classes 1 to 8, 1 358 accounts, copied as it is into `packs/<cc>/accounts.csv` |
| `statements.json` | the balance sheet and the income statement of the *Système normal*, copied into `packs/<cc>/statements.json` with the member's country in front of each statement code (`SN-SYSCOHADA-BS`), because a statement code is the key of `statement_templates` across every country |
| `manifest.json` | the seventeen members, listed ahead of their packs; the two register entries every member cites (`audcif`, `syscohada`); and the part of `pack.json` that belongs to the chart — `charts`, `journals`, `defaults.roles`, `defaults.journal_roles`, `defaults.closing_style`, `defaults.rounding_method`, `defaults.fiscal_year_default` |
| `i18n/<lang>.json` | the chart in another language, from an official version only — none yet, see *Languages* |
| `TEMPLATE/` | the model of a member's `pack.json`; not a pack, nothing compiles it |

```sh
node scripts/ohada-packs.mjs            # check — the CI's hygiene job runs it
node scripts/ohada-packs.mjs --write    # write the common part into every member
node packages/cli/dist/bin.js pack build --all   # then compile: a seed carries a checksum of its pack
```

## Adding a member — the procedure for each of the fifteen

Everything the fifteen packs still to come share is already written: their
codes are in `members` (the script reports them as *awaited* until their folder
exists), their currencies are in `supabase/seed/00_currencies.sql` and their
territories in `supabase/seed/00_territories.sql`. **A member pack touches
`packs/<cc>/` and nothing else by hand** — not this folder, not the seeds of
`00_*`, not `CHANGELOG.md`. What `pack build` regenerates outside the folder
(its own seed, the generated blocks of `README.md`, `supabase/config.toml`,
`.github/CODEOWNERS` and `docs/packs.md`) is committed as it comes out; two
branches that collide there are reconciled by running `pack build --all` again,
never by hand.

| cc | Country | `seed_sequence` | `defaults.currency` | Harmonised by |
|---|---|---|---|---|
| bj | Bénin | 22 | XOF | UEMOA |
| bf | Burkina Faso | 23 | XOF | UEMOA |
| cm | Cameroun | 24 | XAF | CEMAC |
| cf | Centrafrique | 25 | XAF | CEMAC |
| km | Comores | 26 | KMF | — (a *taxe sur la consommation*, no VAT) |
| cg | Congo | 27 | XAF | CEMAC |
| ga | Gabon | 28 | XAF | CEMAC |
| gn | Guinée | 29 | GNF | — |
| gw | Guinée-Bissau | 30 | XOF | UEMOA |
| gq | Guinée équatoriale | 31 | XAF | CEMAC |
| ml | Mali | 32 | XOF | UEMOA |
| ne | Niger | 33 | XOF | UEMOA |
| cd | RD Congo | 34 | CDF (2 decimals) | — |
| td | Tchad | 35 | XAF | CEMAC |
| tg | Togo | 36 | XOF | UEMOA |

The numbers are held: no other pack declares one of them, and a pack that
claims one it was not given is refused by `pack build` (`seed_sequence_conflict`)
the day both meet.

**What the script gives you**, into `packs/<cc>/`: `accounts.csv`,
`statements.json` (codes `<CC>-SYSCOHADA-BS` and `<CC>-SYSCOHADA-IS`), and in
`pack.json` the `charts`, the `journals` (VT, AC, BQ, CA, OD, AN), the roles
(`defaults.roles`, `defaults.journal_roles`), `closing_style`,
`rounding_method`, `fiscal_year_default` and the two register entries `audcif`
and `syscohada`, first in `certification.sources`. And, once a translation of
the chart is here, its sections in `i18n/<lang>.json` (below).

**What you write**, in this order:

1. **`packs/<cc>/pack.json`**, from [`TEMPLATE/pack.json`](TEMPLATE/pack.json):
   `country` in capitals, `name`, `seed_sequence` from the table, `released_at`,
   `defaults.currency` from the table, `defaults.language` `fr` (the chart is
   written in French, and a pack is written in one language), the register of
   your own texts in `certification.sources`, `documents` and `einvoicing`.
   Leave `journals` and `charts` empty. The TEMPLATE folder is a model, not a
   pack: nothing compiles it.
2. **`node scripts/ohada-packs.mjs --write`** — the common part lands in your
   folder.
3. **`taxes.json` and `tax_report.json`**, from your country's code and the
   official texts of your country (listed in `certification.sources`). Every tax account is one of the chart:
   4431 to 4435 for the tax invoiced, 4451 to 4456 for the tax recoverable,
   4441 and 4449 for the balance (the `tax_payable` and `tax_receivable` roles),
   447x for what the buyer withholds. A surtax on the tax — the additional
   centimes of Cameroon, Chad and the Congo — is a tax of its own, because the
   return and the communes keep it apart. `packs/sn/` (a withholding by the
   buyer) and `packs/ci/` (a tax due on collection) are the worked examples.
4. **`golden/scenario.json`**, ten documents or more, `chart` `default`,
   `statements` `["<CC>-SYSCOHADA-BS", "<CC>-SYSCOHADA-IS"]`.
5. **`README.md`** of the pack, on the model of `packs/sn/README.md`: the
   sources, what the pack says, what it does not say.
6. **`i18n/<lang>.json`** only if your country's tax is written in another
   language (see *Languages*).
7. `npm run build`, `node packages/cli/dist/bin.js pack build <cc>`,
   `pack check <cc>`, `UPDATE_GOLDEN=1 npm test -- tests/golden.test.ts` and
   read what it wrote, then the whole suite and `npm run check:ohada`.

A pack that cites the OHADA register entries without being a member is refused
by the check: a country copied from another member by hand would stop
following the chart the first time it is corrected.

## Languages

The chart is written in French, and so is every member's `pack.json`. The
translations of the chart belong here, one file per language,
`packs/ohada/i18n/<lang>.json`, holding the sections that are the chart's —
`charts`, `accounts`, `journals`, `statement_lines` (keyed
`SYSCOHADA-BS:<line>`, the script puts the member's country in front). The
script writes those sections into `packs/<cc>/i18n/<lang>.json` of **every**
member, and leaves the member's own sections — `pack_name`, `taxes`,
`tax_report_boxes`, `legal_mentions` — as the member wrote them. The file stays
a partial translation, which the schema allows, until the member covers the rest
and lists the language in `languages`.

**None is here yet, on purpose.** The three that matter are English
(Cameroon), Spanish (Equatorial Guinea) and Portuguese (Guinea-Bissau), and on
21 September 2026 no official version of the revised chart could be read in
any of them:

- **English.** The OHADA's official English translation of the uniform acts,
  published online in 2016 (biblio.ohada.org, `explnum_id=3975`, text layer),
  carries only the accounting act of 2000, without the list of accounts. The
  official compilation of 22 November 2019 exists on paper only in the OHADA
  library (ERSUMA, Porto-Novo), with no file.
- **Spanish and Portuguese.** `ohada.com` lists `AUDCIF-2017_es.pdf` and
  `AUDCIF-2017_pt.pdf` behind an account; nothing says whether they carry the
  chart or are official. The OHADA library holds no Spanish or Portuguese
  edition of the 2017 act.
- The versions circulating on document-sharing sites are unofficial.

A chart of 1 358 accounts translated here would be a second rule dressed as the
first, so the three packs are written in French with the note in their README.
Their **own** sections can be in their language already: Guinea-Bissau's
Código do IVA and Equatorial Guinea's Ley 1/2024 are official texts in
Portuguese and Spanish, so `packs/gw/i18n/pt.json` and `packs/gq/i18n/es.json`
may carry `pack_name`, the taxes, the boxes and the mentions in the wording of
the law, undeclared, and the accounts fall back to French. Cameroon likewise
in English, if its Code général des impôts is published in English by the
administration. When an official translation of the chart is found, it is
transcribed into `packs/ohada/i18n/<lang>.json` with its `source`, and
`--write` puts it in every member at once.

## Where the chart comes from

The *Journal officiel de l'OHADA*, numéro spécial du 15 février 2017, Titre VII,
chapitre 2, section 3 « Liste des comptes » (printed pages 216 to 269), in the
signed complete version the OHADA digital library serves. That edition is a
scan with no text layer; the list was transcribed page by page from the images
and read back against them.

- **Classes 1 to 8 are here, class 9 is not.** The engagements off the balance
  sheet and the analytical accounts of class 9 are optional (Titre VII,
  chapitre 2, section 1: the codification is imperative « à l'exception de la
  classe 9 qui est d'application facultative »).
- **The wording is the text's**, capitals included: a heading printed in
  capitals is in capitals here, and a sub-account printed « dans la Région »
  under 701 says exactly that, its parent giving the rest. The footnote calls
  are dropped. Nine spelling slips of the print are corrected, and only
  spelling: 27 IMMOB*L*ISATIONS, 49 ET*␣*PROVISIONS, 130 INS*T*ANCE, 158
  RÉGLEMENT*É*S, 165 RE*Ç*US, 393 APP*R*OVISIONNEMENTS, 412 EFFETS (printed
  « ÉFFETS »), 656 COMMERCIALE*S*, 3352 r*é*cupérables, and the closing
  parenthesis of 6089, hidden under the signature.
- **One account of the print is left out**: the line « 412 Organismes
  Internationaux, Effets à recevoir » repeats the code of its own heading among
  4121 to 4124. It is almost certainly 4125, and a code nobody printed is not
  a code this file may invent.
- **The types** (`account_type`) are this file's reading of each class, since
  the text classifies by class and not by the eighteen types of Ekwo: a
  customer account in debit is `asset_receivable`, 409 and 419 go the other way,
  the tax invoiced is a liability and the tax recoverable an asset, 49 and 59
  are the contra accounts of their class. They decide the generic statements
  and the ageing, never the two statements below.

## The two statements

Titre IX, chapitre 3 (the balance sheet) and chapitre 4 (the income
statement), with the correspondence of chapitre 7 (printed pages 1068 and
1069), for the *Système normal*. Every line keeps its official reference —
`AD` to `BZ`, `CA` to `DZ`, `TA` to `XI`.

- **The asset side follows the correspondence table.** Where it marks an
  account « p » — shared between two lines according to what it carries — the
  account is attached whole to one of them, and the line says which: 2818,
  2918 and 2919 to AH, 2939 to AL, 2949 to AM. Accounts the table does not cite
  are attached where their heading puts them: 2394, 2395 and 2398 to AL, 585
  and 588 to BS and DR.
- **The liability side is read, not copied.** The correspondence table gives
  no account for CA to DZ, and no page of chapitre 3 does either. Each line
  takes the accounts its own title names in the list of accounts — capital
  101 to 104, the uncalled capital 109, premiums 105, revaluation 106, reserves
  111 to 113 unavailable and 118 free, 12, 13, 14, 15, 16 and 18, 17, 19, 481
  to 484, 419, 40 but 409, the credit balances of 42 to 47, 499 and 599, 564 and
  565, 561, 566 and the credit balances of the treasury accounts — and says so
  in its `legal_reference`.
- **A balance splits by side** where the table says « soldes débiteurs »: 185,
  42 to 46 and 470 to 477 are *Autres créances* in debit and debts in credit;
  52 to 55, 57 and 58 are treasury on either side.
- **The income statement** reads charges as positive figures and subtracts them
  in the intermediate balances, where the model prints them with a « - ». The
  balances are the model's own: XA, XB, XC, XD, XE, XF, XG, XH and XI.

**The *Système minimal de trésorerie* is not here.** It is a cash book of
receipts and payments, kept by bank and by cash box, with an inventory taken
outside the books at the year end (Titre X, chapitre 1); its model names no
account (Titre X, chapitre 2). A double-entry chart could imitate it only by
inventing accounts the text does not have. `docs/international.md` keeps the
point.
