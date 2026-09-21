# Chad

Everything Chad adds to Ekwo, as data: the value added tax of the Code
général des impôts, where each rate posts, the declaration it is filed on and
the sentences the Code puts on an invoice. The chart of accounts, the
journals and the two statements are the SYSCOHADA révisé shared by seventeen
countries, and they are not written here: they are copied from
[`packs/ohada/`](../ohada/README.md) by `scripts/ohada-packs.mjs`, which the
CI runs to refuse a copy that has drifted. Edit them there.

**Status: `community`.** Nobody has reviewed it against the law they apply.
The golden year proves the pack is coherent and nothing about whether it is
right. Currency XAF, the CFA franc of the BEAC, at no decimal, CEMAC zone.

## Sources

| What | Text | Where |
|---|---|---|
| The 17,5 % rate, the 9 % reduced list, the zero rate | Loi de finances pour 2026, loi n° 008/AN/SENAT/2025, art. 32, modifiant l'art. 238 du Code général des impôts | `mesrsfp.gouv.td` |
| The 19,25 % facturé (centimes communaux et provinciaux) | Loi de finances pour 2024, loi n° 031/PT/2023, art. 16, modifiant l'art. 1017, et art. 26, modifiant l'art. 238 à 17,5 % | `cabri-sbo.org` |
| Les exonérations de l'art. 230 | Loi de finances pour 2026, art. 31 | `mesrsfp.gouv.td` |
| L'autoliquidation de l'art. 229-V | Loi de finances pour 2026, art. 30 | `mesrsfp.gouv.td` |
| La non-déductibilité d'une facture non-FEN, art. 246-II | Loi de finances pour 2026, art. 33 | `mesrsfp.gouv.td` |
| Le régime de la FEN, les contribuables tenus de l'émettre, la dépense publique | Loi de finances pour 2023, art. 17 ; loi de finances pour 2024, art. 43 ; loi de finances pour 2026, art. 46 et 71 | `fen.finances.gouv.td` |
| Le cadre communautaire des taux | Directive n° 11/22-CEMAC-UEAC-010A-CM-38 du 10 novembre 2022 | `sgg.cg` |
| Télédéclaration | e-Tax | `sigi.finances.gouv.td` |

**La loi de finances pour 2024 a un calque texte natif ; la loi de finances
pour 2026 est un scan sans calque texte** (ScanSnap), relu par
reconnaissance de caractères puis vérifié page à page sur l'image, en
particulier la table de l'article 230 (page 45-46) et les articles 229, 238,
246. Aucune des deux lois n'a pu être ouverte par un simple lecteur de flux :
la première se lit en texte, la seconde a été rendue en images avant lecture.

## What the pack says

- **19,25 % facturés** sur les opérations au taux normal (`TD-S-1925`,
  `TD-S-1925-SRV`, et leurs pendants à l'achat) : 17,5 % (CGI art. 238-I-1°)
  majorés de 10 % de centimes communaux et provinciaux sur ce même montant,
  soit 1,75 point — l'art. 1017 dit explicitement « au taux de 19,25 % pour
  tenir compte des Centimes Communaux et Provinciaux ». Le pack calcule la
  taxe **une seule fois**, à 19,25 %, puis répartit son montant entre deux
  comptes par deux *postings* de `factor` 90,909 et 9,091 (qui totalisent
  100,000) : le compte 4431 ou 4432 pour la part de 90,909 % (l'équivalent des
  17,5 points), le compte 4422 « Impôts et taxes pour les collectivités
  publiques » pour la part de 9,091 % (l'équivalent des centimes). Calculer
  17,5 % puis 10 % du résultat comme deux taux indépendants produirait deux
  arrondis, qui peuvent s'écarter d'une unité monétaire de l'arrondi unique
  que porte la facture — le moteur garantit ici que les deux parts
  s'additionnent toujours exactement au montant facturé, le second *posting*
  absorbant l'écart d'arrondi du premier. 4422 est retenu plutôt que 446
  « Autres taxes sur le chiffre d'affaires » parce que son intitulé même,
  « pour les collectivités publiques », correspond au texte ; c'est un choix
  documenté, pas le seul défendable. Côté achat, la part communale et la part
  étatique de la taxe déductible ne sont pas distinguées : le plan SYSCOHADA
  n'a pas de compte récupérable séparé pour cela, et la directive CEMAC
  (art. 22-1) n'exige que la déductibilité, pas la traçabilité de la
  provenance.
- **9 %** (CGI art. 238-I-2°, loi de finances pour 2026, art. 32) sur une
  liste fermée : sucre, huile, lait, yaourt, beurre, fromage, viande, savon,
  textile, fer à béton, produits et sous-produits de l'agroalimentaire local
  hors alcool, matériel d'artisanat et de pêche, hébergement et restauration.
  **Aucun centime additionnel n'est porté sur ce taux** : le texte ne le dit
  ni ne l'exclut, et le pack ne tranche pas ce qu'aucune disposition ne
  tranche.
- **Taux zéro** (CGI art. 238-I-3°) sur les exportations, le transport aérien
  international, l'avitaillement en carburant Jet A1 des aéronefs à
  destination de l'étranger, l'entretien et la réparation d'aéronefs.
- **Exonérations** (CGI art. 230, loi de finances pour 2026, art. 31), dont le
  15° par position tarifaire — médicaments, viandes (02), laits (0401-0402),
  pain, farine, livres scolaires, semences, engrais, matériel agricole,
  matériel photovoltaïque (8541.42) — vérifiée directement sur le fac-similé
  de la loi.
- **L'autoliquidation** (CGI art. 229-V, loi de finances pour 2026, art. 30)
  n'est pas un cas général de « le fournisseur ne facture pas la taxe » :
  elle joue précisément lorsqu'un vendeur qui ne relève pas de l'Impôt
  Général Libératoire (IGL), ou qui en relève mais a dépassé au cours de
  l'opération le seuil de 50 millions de FCFA, vend à une personne assujettie.
  L'acheteur auto-liquide la taxe, la collecte et la reverse « dans les
  conditions de droit commun relatives à la TVA retenue à la source » — donc,
  par renvoi, celles de l'art. 245 — et la déduit dans les conditions du
  droit commun. `TD-S-AUTOLIQ` et `TD-P-AUTOLIQ` portent la condition
  `seller_threshold`, parce que c'est un fait du régime du vendeur que le
  document ne porte pas lui-même.
- **La déduction suppose une facture électronique normalisée** depuis le
  1er janvier 2026 (CGI art. 246-II, loi de finances pour 2026, art. 33), sauf
  facture d'un fournisseur étranger.
- **La déclaration est mensuelle pour tout contribuable au régime du réel
  normal ou au régime simplifié d'imposition** (CGI art. 229-III, disposition
  inchangée par la loi de finances pour 2026), la déclaration néant est
  obligatoire (art. 886-IV), accompagnée du paiement (art. 886-III), et
  télétransmise par e-Tax (art. 996).
- **Les mentions de la facture** (loi de finances pour 2023, art. 17-II ; CGI
  art. 246) : numéro et date, raison sociale, adresse, NIF et RCCM du
  fournisseur, nom, adresse et NIF du client, désignation, quantité, prix
  unitaire et hors taxe, taux et montant de la taxe ou la mention
  d'exonération, total, numéro de la machine certifiée.

## What it does not say

- **L'échéance du 15 du mois pour la déclaration mensuelle de TVA elle-même**
  n'a été trouvée dans aucun des deux textes lus. Le « 15 du mois suivant »
  qu'ils portent est celui de la **retenue à la source** de l'art. 245 (loi
  de finances pour 2024, art. 35) et, par renvoi de l'art. 229-V, celui de la
  taxe auto-liquidée — pas celui de la déclaration mensuelle ordinaire de
  l'art. 229-III, qui ne fixe aucun jour. `tax_report.json` ne porte donc pas
  de `deadline`.
- **Le formulaire imprimé et la numérotation de ses cases** ne sont publiés
  dans aucune source officielle trouvée ; les cases de ce pack sont nommées
  d'après ce que l'article 229 fait déclarer, comme au Sénégal.
- **La retenue de TVA à la source de l'art. 245** — un tiers désigné par une
  liste de la DGI retient la taxe due par une entreprise absente de cette
  liste et la reverse à sa place — est un mécanisme à trois parties que le
  socle ne sait pas exprimer, comme le précompte sénégalais. Aucune taxe ne
  le porte ici.
- **Le taux réduit du ciment**, « dans la fourchette communautaire » selon la
  fiche de départ de ce pack, n'a été chiffré dans aucune des deux lois lues.
- **La FEN comme spécification technique** : ni profil normalisé (EN 16931,
  UBL ou autre), ni schéma d'identifiant des parties, ni format d'échange
  n'ont été trouvés publiés par la DGI. `einvoicing.profile` reste vide.
- **La langue arabe** de la fiche de départ n'a pas été confirmée par une
  source officielle ; le pack est écrit en français, comme le veut
  `packs/ohada/`.
- **Le formulaire de la retenue à la source et celui de l'autoliquidation**,
  distincts de la déclaration de TVA d'après le renvoi de l'art. 229-V : le
  pack ne porte qu'une déclaration, `TD-TVA`.
