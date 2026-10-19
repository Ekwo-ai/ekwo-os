# tests/shared_instance.test.ts — échec intermittent `contact_merged`

## Cause

Le défaut est dans le test, le moteur fait son travail.

- Depuis `1b35019b` (19/10, 03:27, `merge_contacts()`), `furnish()`
  (`tests/helpers/company-archive.ts:201-215`) ajoute à chaque société meublée un
  contact « Twin <TAG> » et le fusionne dans le premier contact par nom
  (« Al Barsha Fleet Leasing LLC » pour le pack `ae`). Le jumeau reste en base, retiré
  (`merged_into` renseigné).
- Le `beforeAll` de `tests/shared_instance.test.ts:151` choisit le contact d'une cession
  d'immobilisation par `order by id limit 1`. Les `id` sont des `gen_random_uuid()` :
  quand l'UUID du jumeau est le plus petit, l'insertion nomme un contact fusionné et le
  garde-fou `refuse_merged_contact()` (migration `20261019090000`) la refuse à juste
  titre. L'erreur survient dans le hook global, d'où les 52 tests « skipped ».
- Probabilité : 12 contacts par société (11 du golden `ae` + le jumeau), deux sociétés,
  soit environ 1 − (11/12)² ≈ 16 % par exécution. Une sonde sur 12 sociétés meublées
  place le jumeau à des rangs uniformes de 0 à 11, au rang 0 pour Alice comme pour Bob.
- Le travail sur la pondération des noms (`suggest_duplicate_contacts()`, migration
  `20261019140000`) et l'ordre des fichiers dans le worker n'y sont pour rien : le
  fichier échoue seul.

## Correction

`tests/shared_instance.test.ts` : les quatre choix de contact par `order by id`
(l. 151 dans le `beforeAll`, l. 1031, 1100 et 1429 dans des tests sur les livres de Bob)
excluent désormais les contacts fusionnés (`merged_into is null`). Aucun autre fichier
qui utilise `furnish()` ne choisit un contact par `id`.

Pas de migration : le schéma refuse à bon droit ; aucun code produit modifié.

## Preuves

- Avant correction, fichier seul : 6 échecs sur 12 (`contact_merged: Twin ALICE`).
- Après correction, fichier seul : 20/20 au vert (52 tests).
- Après correction, shard 7/16 de la CI
  (`npm test -- --maxWorkers=2 --shard=7/16 --exclude tests/golden.test.ts --passWithNoTests`,
  15 fichiers, 1574 tests) : 11/11 au vert ; le rapport JSON de la 11ᵉ confirme que `tests/shared_instance.test.ts` en fait partie (avec `company_archive`, `filing_deposits`, `mcp/members`…).

## Commit

Un commit, non poussé, sur `fix/shared-instance-contact-merged`.
