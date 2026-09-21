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
| `manifest.json` | the members; the two register entries every member cites (`audcif`, `syscohada`); and the part of `pack.json` that belongs to the chart — `charts`, `journals`, `defaults.roles`, `defaults.journal_roles`, `defaults.closing_style`, `defaults.rounding_method`, `defaults.fiscal_year_default` |

```sh
node scripts/ohada-packs.mjs            # check — the CI's hygiene job runs it
node scripts/ohada-packs.mjs --write    # write the common part into every member
node packages/cli/dist/bin.js pack build --all   # then compile: a seed carries a checksum of its pack
```

## Adding the third country, or the seventeenth

A new member is its tax and nothing else. For Mali, say:

1. **`packs/ml/pack.json`** with only what is Malian: `country`, `name`,
   `version` `0.1.0`, `schema_min`, `seed_sequence` (22 to 36 are held for the
   fifteen members still to come), `released_at`, `certification` (`community`,
   and the register of the Malian texts — the two OHADA entries are added for
   you), `defaults.currency` (`XOF` in the West African Economic and Monetary
   Union, `XAF` in the Central African one — add the row to
   `supabase/seed/00_currencies.sql` the first time it is needed, at 0
   decimals, and `KMF`, `GNF`, `CDF` likewise), `defaults.language`,
   `documents`, `einvoicing`. Leave `journals` and `charts` as empty lists:
   they are written for you.
2. **Add `ml` to `members`** in `packs/ohada/manifest.json`, and run
   `node scripts/ohada-packs.mjs --write`. It writes `accounts.csv`,
   `statements.json`, the charts, the journals, the roles and the two OHADA
   register entries into `packs/ml/`.
3. **`taxes.json` and `tax_report.json`**, from the Malian code. Every tax
   account is one of the chart: 4431 to 4435 for the tax invoiced, 4451 to 4456
   for the tax recoverable, 4441 and 4449 for the balance (they are the
   `tax_payable` and `tax_receivable` roles of every member), 447x for what the
   buyer withholds. `packs/sn/` and `packs/ci/` are the two worked examples: one
   with a withholding by the buyer, one with a tax due on collection.
4. **`golden/scenario.json`**, ten documents or more; its `statements` are
   `ML-SYSCOHADA-BS` and `ML-SYSCOHADA-IS`.
5. **A row in `supabase/seed/00_territories.sql`** (`eu_vat_scope` `none`), the
   seed in `supabase/config.toml` and in the README, a line in
   `.github/CODEOWNERS`, then `pack build`, `UPDATE_GOLDEN=1 npm test --
   tests/golden.test.ts`, and read what it wrote.

A pack that cites the OHADA register entries without being a member is refused
by the check: a country copied from another member by hand would stop
following the chart the first time it is corrected.

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
