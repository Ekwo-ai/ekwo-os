# Slovakia

Everything Slovakia adds to Ekwo, as data: a chart of accounts read from the
binding rámcová účtová osnova, the journals, the VAT rates and where each one
posts, the boxes of the daňové priznanie DPH, the Súvaha and the Výkaz ziskov
a strát of the accounting law, and the sentences the law puts on an invoice.
The format is [`docs/packs.md`](../../docs/packs.md); this file says where
the content came from and which decisions it rests on, so that a Slovak
accountant or daňový poradca reading the pack can disagree with a specific
sentence rather than with the whole of it.

**Status: `community`.** Nobody has reviewed it against the law they apply.
The figures are replayed against two months of books by `tests/golden.test.ts`,
which proves the pack is coherent and proves nothing about whether it is
right.

**Language: `sk`.** The pack's own labels are written in Slovak, which is
also the language of every text in the register below; no second language
file is declared.

## Sources

Every rate, box, mention and statement line carries its own `legal_reference`
and names the entry of `certification.sources` its article is in. The
register holds thirteen texts.

| What | Text | Publisher |
|---|---|---|
| Rates, exemptions, reverse charge, intra-Union acquisition, import, deduction, invoice content, VAT return, kontrolný výkaz | Zákon č. 222/2004 Z. z. o dani z pridanej hodnoty, úplné znenie k 1.1.2025 | financnasprava.sk |
| Réforme des taux 2025 (23 %/19 %/5 %) | Zákon č. 278/2024 Z. z. | slov-lex.sk |
| Seuils d'enregistrement 2025, § 84a (samozdanenie pri dovoze) | Zákon č. 102/2024 Z. z. | slov-lex.sk |
| Structure exacte du formulaire de déclaration (DPHv25) | Poučenie k tlačivu MF/007833/2025-731 | financnasprava.sk (republié sur podnikajte.sk) |
| E-facturation (IS EFA), calendrier | 9/DPH/2025/IM — FAQ eFaktúra | financnasprava.sk |
| Plan comptable-cadre | Opatrenie MF SR č. 23054/2002-92 | mfsr.sk |
| Loi comptable, seuils micro/malá/veľká | Zákon č. 431/2002 Z. z. o účtovníctve | slov-lex.sk |
| Súvaha Úč POD 1-01 | Tlačivo UZPODv14, opatrenie MF/18009/2014-74 | financnasprava.sk |
| Výkaz ziskov a strát Úč POD 2-01 | Tlačivo UZPODv14, opatrenie MF/18009/2014-74 | financnasprava.sk |
| Délai de paiement, plafond contractuel | Obchodný zákonník (zákon č. 513/1991 Zb.), § 340a, § 369, § 369c | slov-lex.sk |
| Taux d'intérêt de retard, indemnité forfaitaire | Nariadenie vlády SR č. 21/2013 Z. z. | slov-lex.sk |
| Codes de la facture électronique | EN 16931, UNCL5305, VATEX | European Commission (docs.peppol.eu) |

## Le plan comptable, et pourquoi celui-ci

**La Slovaquie prescrit un plan comptable-cadre obligatoire**, à la
différence de la Pologne ou de l'Autriche déjà écrites dans ce dépôt.
L'opatrenie MF SR č. 23054/2002-92, § 1 ods. 3 et son annexe 1, établit la
rámcová účtová osnova : une liste de comptes synthétiques à trois chiffres,
dont le numéro **et** le libellé sont contraignants (« záväzný číselný a
slovný označenie », selon la doctrine professionnelle citée dans le
`legal_reference` de `charts[0]` — la lecture verbatim de l'article exact de
l'opatrenie qui pose ce caractère contraignant n'a pas pu être obtenue lors de
la préparation de ce paquet, voir plus bas). Chaque entité construit ensuite
son propre « účtový rozvrh » en y ajoutant des comptes analytiques (§ 3 de
l'opatrenie), mais les comptes synthétiques eux-mêmes — `311` Odberatelia,
`321` Dodávatelia, `343` Daň z pridanej hodnoty, `411` Základné imanie —
sont ceux de ce pack, pas un numérotage inventé pour lui.

Ce pack reprend les classes 0 à 6 de la rámcová účtová osnova, dans
l'étendue qui couvre l'agenda courant d'une PME. Les classes 7 (comptes de
clôture et hors-bilan) et 8/9 (comptabilité analytique interne, § 6 ods. 1 de
l'opatrenie : contenu laissé libre à chaque entité) ne sont pas reprises : le
socle ne lit pas les comptes de clôture directement, et l'analytique interne
n'a pas de structure imposée qu'il serait utile de transcrire.

**La Slovaquie utilise des comptes d'amortissements cumulés séparés**
(groupes `07`/`08`, « oprávky »), et non une réduction directe de la valeur
brute comme les packs autrichien ou polonais de ce dépôt : la Súvaha
présente d'ailleurs trois colonnes — Brutto, Korekcia, Netto — ce qui
confirme structurellement cet usage. Une immobilisation et son compte
d'oprávky sont rattachés à la même ligne de Súvaha, pour que le solde net
s'y lise correctement.

**Le résultat de l'exercice reste sur le compte `431`** (« Výsledok
hospodárenia v schvaľovacom konaní », résultat en instance d'affectation)
jusqu'à son approbation, ce qui correspond exactement au mécanisme que le
format appelle `closing_style: result_accounts` : `current_year_result_profit`
et `current_year_result_loss` pointent tous deux vers `431`, un seul compte
portant les deux signes plutôt qu'une paire comme en France (`120`/`129`).

## Les taxes

Seize codes. Le taux normal est de 23 %, le premier taux réduit de 19 %
(§ 27 ods. 2, annexe 7 point 1 et annexe 7a point 1) et le second taux
réduit de 5 % (§ 27 ods. 3, annexe 7 points 2 et 3, annexe 7a point 2) —
**tous trois en vigueur depuis le 1er janvier 2025** (loi n° 278/2024 Z. z.,
paquet de consolidation budgétaire), remplaçant les anciens taux 20 % et
10 %. Les annexes 7 et 7a ont été modifiées à nouveau au 1er juillet 2025 et
au 1er janvier 2026 (extension du taux 5 %, reclassement de certains
produits sucrés/salés vers le taux normal) ; ce pack transcrit les articles
et annexes tels que lus dans la version consolidée au 1.1.2025, et ces
évolutions ultérieures **n'ont été vérifiées que par des sources
secondaires concordantes**, pas par lecture directe d'un texte consolidé
plus récent — voir « Avant que ce pack soit `reviewed` ».

Le taux zéro couvre l'export (`SK-S-EXPORT`, § 47) et la livraison
intracommunautaire (`SK-S-IC`, § 43). Une exonération domestique sans droit
à déduction est illustrée par le nájom de locaux commerciaux
(`SK-S-EXEMPT-NAJOM`, § 38 ods. 3) et, côté achat, par une prime
d'assurance (`SK-P-OSLOBODENE`, § 37).

Côté autoliquidation, trois mécanismes sont couverts : l'acquisition
intracommunautaire de biens (`SK-P-IC-23`, § 11 et § 69 ods. 6), les
travaux de construction relevant de la section F, aussi bien du côté du
prestataire (`SK-S-RC-STAVBY`) que du preneur (`SK-P-RC-STAVBY-23`, § 69
ods. 12 písm. j) et ods. 16 — la mention « prenesenie daňovej povinnosti »
est une condition du transfert, pas une simple formalité), et le service
reçu d'un prestataire étranger sous la règle générale B2B (`SK-P-SLUZBA-EU-23`
pour un prestataire de l'Union, `SK-P-SLUZBA-MIMO-EU-23` pour un pays tiers
— § 69 ods. 3 ne distingue pas les deux cas, et le formulaire non plus,
donc les deux codes visent les mêmes riadky 09b/10b/19).

`SK-P-POHOSTENIE` illustre une exclusion totale du droit à déduction
(§ 49 ods. 7 písm. a), pohostenie a zábava — hébergement et divertissement),
sans plafond partiel : une recherche ciblée sur une limitation forfaitaire
propre aux véhicules de tourisme à usage mixte (comme en France, en
Belgique ou en Pologne) n'a trouvé aucune disposition de ce type dans le
corps de la loi TVA ; seule existe la proratisation générale d'usage mixte
de l'§ 49 ods. 5, qui est un choix de l'assujetti et non une règle imposée,
et qui n'est pas modélisée ici.

`SK-P-DOVOZ-23` modélise le cas ordinaire d'importation (TVA payée à la
douane puis déduite au riadok 23) — pas le mécanisme de samozdanenie de
l'§ 84a, réservé aux assujettis titulaires du statut d'opérateur économique
agréé (voir plus bas).

## La déclaration

`SK-DPH` transcrit une partie du formulaire DPHv25 (MF/007833/2025-731),
dans sa version en vigueur depuis le 1er juillet 2025. La numérotation des
riadky vient de la lecture directe du poučenie officiel ; c'est une
**sous-partie volontairement réduite** du formulaire réel, qui compte une
trentaine de riadky au total. Sont couverts : les trois taux en vente
(riadky 01/01a/03 et 02/02a/04), l'acquisition intracommunautaire
(07/08), l'autoliquidation « le preneur paie la taxe » toutes causes
confondues (09b/10b), les exonérations et leurs deux pense-bêtes export/LIC
(13/14/15), la déduction générale par taux (18/18a/19), la déduction de la
TVA payée à la douane (22/22a/23), et les deux totaux en miroir (32/33).

L'échéance est le 25e jour suivant la période (§ 78 ods. 1 et 2, pour la
déclaration et pour le paiement) ; `period_default` propose le mois, qui
est la règle générale — le trimestre reste une option pour un assujetti
enregistré depuis plus de douze mois dont le chiffre d'affaires des douze
derniers mois n'a pas dépassé 100 000 € (§ 77 ods. 2, seuil relevé au
1.1.2025).

## Ce que le socle ne sait pas faire

**Le kontrolný výkaz (relevé de contrôle TVA) n'est pas modélisé comme un
second `tax_report`.** Il est obligatoire (§ 78a) pour tout assujetti, dans
la même périodicité et à la même échéance que la déclaration, mais son
contenu est facture par facture — numéro de TVA du partenaire, numéro de
facture, base et taxe par taux — et non une structure de cases sommées
comme celle que `tax_report.json` sait décrire. C'est aussi là, et non sur
le formulaire principal, que serait déclarée une livraison sous
autoliquidation domestique côté fournisseur (`SK-S-RC-STAVBY` ne poste donc
aucune case du côté vendeur).

**L'e-facturation obligatoire (IS EFA) n'est pas encore en vigueur au
`released_at` de ce pack** (1er janvier 2027, après une période volontaire
depuis le 1er janvier 2026) et le numéro exact de la loi modificatrice
(candidat : loi n° 385/2025 Z. z.) n'a pas pu être confirmé par lecture
directe sur slov-lex.gov.sk lors de la préparation de ce paquet — voir
`einvoicing.legal_reference` dans `pack.json`. `party_scheme` et
`vat_scheme` restent vides : la schéma ISO 6523 précise des participants
slovaques au réseau Peppol n'a été vérifiée par aucune source utilisée ici.

**Le samozdanenie à l'importation (§ 84a) n'est pas modélisé.** Réservé aux
assujettis établis en Slovaquie titulaires du statut d'opérateur économique
agréé (en vigueur depuis le 1.7.2025, ou depuis le 1.1.2026 pour le
dédouanement centralisé), il permettrait de déclarer et déduire la TVA
d'importation directement sur la déclaration plutôt que de la payer à la
douane. `SK-P-DOVOZ-23` ne modélise que le cas ordinaire (majoritaire) ;
les riadky 11c à 12e et 23a à 23c de ce mécanisme ne sont pas déclarés.

**Les opérations triangulaires simplifiées (§ 45) ne sont pas modélisées** —
riadky 11/11a/11b et 12/12a/12b.

**Les corrections ne sont pas modélisées** : correction du prix (§ 25),
créances irrécouvrables (§ 25a), correction de la déduction (§ 53, § 53a,
§ 53b), déduction lors de l'enregistrement pour un bien acquis avant de
devenir assujetti, remboursement de la taxe aux voyageurs (§ 60), report
d'un excédent de déduction d'une période à l'autre. Les riadky
correspondants (24 à 31, 34 à 37) ne sont pas déclarés dans
`tax_report.json` ; les formules des riadky 32 et 33 de ce pack ne portent
donc que sur les cases qu'il déclare réellement — le formulaire officiel les
inclut aussi, ce que le `legal_reference` de chaque case rappelle.

**Le délai de paiement supplétif (en l'absence d'accord entre les parties)
n'est pas renseigné.** `documents.legal_payment_days` reste `null` : le
plafond contractuel de 60 jours (§ 340a ods. 1 Obchodného zákonníka) est
solidement établi, mais le nombre de jours applicable à défaut de tout
accord n'a pas pu être vérifié mot pour mot sur un texte officiel lors de la
préparation de ce paquet — voir `documents.references.payment_terms`.

**Le régime de la marge, l'or d'investissement, la méthode de caisse du
petit contribuable (§ 68d) et le régime particulier des petites entreprises
étrangères (§ 68f) ne sont pas modélisés**, hors du périmètre raisonnable
d'un pack `community`.

## Avant que ce pack soit `reviewed`

Un relecteur devrait d'abord regarder :

1. **Les taux applicables depuis le 1.7.2025 et le 1.1.2026.** Ce pack
   transcrit les annexes 7 et 7a telles que lues dans la version consolidée
   au 1.1.2025 ; les évolutions ultérieures (extension du 5 %, reclassement
   de produits sucrés/salés vers 23 %) reposent sur des sources secondaires
   concordantes et non sur la lecture directe d'un texte consolidé après ces
   dates.
2. **La numérotation complète du formulaire DPHv25.** Seize riadky sur une
   trentaine sont repris ; un relecteur devrait vérifier chacun contre le
   poučenie officiel et étendre la couverture (trojstranný obchod,
   samozdanenie à l'import, corrections) si l'usage du pack le justifie.
3. **Le plan comptable.** S'il est réellement utilisable par un comptable
   slovaque, et quels comptes manquent à une petite société — notamment les
   comptes détaillés de rémunération des organes de la société (`523`) ou
   les rubriques financières fines (groupes `65` à `68`) que ce pack ne
   reprend pas.
4. **Les états financiers.** Les lignes de détail (par exemple la ventilation
   du dlhodobý hmotný majetok en r.012 à r.020, ou des produits/charges
   financiers en r.030 à r.038 et r.046 à r.048) n'ont pas pu être vérifiées
   riadok par riadok lors de la préparation de ce paquet ; seules les lignes
   de sous-total sont reprises.
5. **`legal_payment_days` laissé vide** et le numéro exact de la loi
   introduisant l'e-facturation obligatoire — voir « Ce que le socle ne sait
   pas faire ».
