# Congo

Everything the Republic of the Congo adds to Ekwo, as data: the value added
tax of the loi n° 12-97 du 12 mai 1997, where each rate posts, the
declaration it is filed on and the sentences the law puts on an invoice. The
chart of accounts, the journals and the two statements are the SYSCOHADA
révisé shared by seventeen countries, and they are not written here: they are
copied from [`packs/ohada/`](../ohada/README.md) by `scripts/ohada-packs.mjs`,
which the CI runs to refuse a copy that has drifted. Edit them there.

**Status: `community`.** Nobody has reviewed it against the law they apply.
The golden year proves the pack is coherent and nothing about whether it is
right. Currency XAF, the CFA franc of the BEAC, at no decimal, CEMAC zone.

## Sources

| What | Text | Where |
|---|---|---|
| Le taux normal de 18 %, les centimes additionnels de 5 %, le taux zéro à l'export | Loi n° 12-97 du 12 mai 1997 (texte d'origine), art. 17 et art. 37 | `unicongo.cg` |
| Le taux réduit de 5 % (annexe 5) et les exonérations (annexe 3), refondus | Loi de finances pour 2026, loi n° 42-2025 du 31 décembre 2025, § 18.3 | `sgg.cg` (Journal officiel) |
| La confirmation du taux facturé de 18,9 %, le précompte au taux cumulé | Loi de finances pour 2026, § 4.a et § 4.d | `sgg.cg` |
| La numérotation annuelle ininterrompue de la facture, le marquage de sécurité | Loi n° 8-2012 du 11 mai 2012 (texte d'application) | `sgg.cg` |
| Le cadre communautaire des taux et de la déductibilité des surtaxes | Directive n° 11/22-CEMAC-UEAC-010A-CM-38 du 10 novembre 2022, art. 22-1 | `sgg.cg` |
| Le Système de Facturation Électronique Certifié (SFEC) | Loi n° 77-2022 (LF 2023), loi n° 47-2024 (LF 2025), décret n° 2026-101 du 31 mars 2026 | `finances.gouv.cg`, `sfec.gouv.cg` |
| L'échéance de paiement sur la plateforme FOUTA | Lettre circulaire n° 1091/MFBPP-CAB du 24 août 2026 | `finances.gouv.cg` |
| Télédéclaration | E-TAX | `finances.gouv.cg` |

**La loi n° 12-97 de 1997 et la loi de finances rectificative pour 2012 sont
des scans sans calque texte**, relus par reconnaissance de caractères puis
vérifiés page à page sur l'image, en particulier l'article 17 (taux), l'article
37 (centimes) et l'article 29 (mentions de facture) de la première, et l'annexe
des mentions obligatoires de la seconde. **Le texte consolidé actuellement en
vigueur de la loi n° 12-97 (numérotation actuelle des articles) n'a pas été
trouvé en ligne** : le CGI publié par le ministère (`CGI Tome I`, 2016) ne
contient pas la loi TVA, qui reste une loi non codifiée. Chaque disposition de
ce pack est donc rattachée au texte d'origine de 1997 pour ce qu'il fixe
toujours (le principe des taux, l'export au taux zéro), et à la loi de
finances pour 2026 pour ce qu'elle refond explicitement (l'annexe 5 des taux
réduits, l'annexe 3 des exonérations, la confirmation du taux facturé de
18,9 % et du précompte).

## What the pack says

- **18,9 % facturés** sur les opérations au taux normal (`CG-S-189`,
  `CG-S-189-SRV`, et leurs pendants à l'achat) : 18 % (loi n° 12-97, art. 17)
  majorés de 5 % de centimes additionnels sur ce même montant, soit 0,9 point
  (art. 37, confirmé par la loi de finances pour 2026, § 4.a et § 4.d — « au
  taux cumulé de 18,9 % »). Le pack calcule la taxe **une seule fois**, à
  18,9 %, puis répartit son montant entre deux comptes par deux *postings* de
  `factor` 95,238 et 4,762 (qui totalisent 100,000) : le compte 4431 ou 4432
  pour la part principale, le compte 446 « État, autres taxes sur le chiffre
  d'affaires » pour les centimes additionnels. **446 est retenu plutôt que
  4422** « Impôts et taxes pour les collectivités publiques », que
  [`packs/td/`](../td/README.md) et [`packs/cm/`](../cm/README.md) utilisent
  pour leur propre surtaxe communale : leurs textes nomment explicitement les
  collectivités locales comme bénéficiaires (« centimes communaux et
  provinciaux », « Livre de fiscalité locale »), tandis qu'aucune source lue
  pour le Congo ne dit à qui revient le produit des centimes additionnels — la
  loi de finances pour 2026 les rattache au précompte versé au Trésor Public,
  et non à une collectivité nommée. C'est un choix documenté, pas le seul
  défendable ; un texte trouvé plus tard qui les dirait communaux ferait
  basculer ce pack sur 4422, comme ses voisins CEMAC.
- **Déductibilité des centimes additionnels à l'achat : contradiction non
  tranchée.** La directive CEMAC (art. 22-1) n'admet une surtaxe additionnelle
  à la TVA que si elle est déductible dans les mêmes conditions que la taxe
  elle-même ; ce pack suit ce principe et porte `CG-P-189`,
  `CG-P-189-SRV` et `CG-P-189-IMMO` en un seul montant déductible à 18,9 %, au
  compte 4452, 4454 ou 4451, comme le font déjà `packs/td/` et `packs/cm/`
  pour leur propre surtaxe. PwC Worldwide Tax Summaries (source secondaire,
  revue le 07/08/2026) affirme pourtant que la surtaxe congolaise est « non
  déductible (coût définitif) ». Aucun texte officiel consolidé n'a été
  trouvé pour trancher. **À faire relire par un comptable local** avant de
  sortir du statut `community`.
- **5 % (annexe 5 de la loi TVA, refondue par la loi de finances pour 2026,
  § 18.3)** sur une liste de biens de consommation courante : laits, tomate,
  riz, farine de froment, sucre, boulangerie et biscuiterie, sel. **Aucun
  centime additionnel n'est porté sur ce taux** : la loi de finances pour 2026
  ne le dit ni ne l'exclut, et le pack ne tranche pas ce qu'aucune disposition
  trouvée ne tranche.
- **Taux zéro** (loi n° 12-97, art. 17) sur les exportations visées par la
  douane et les transports internationaux.
- **Exonérations** (annexe 3, refondue par la loi de finances pour 2026,
  § 18.3), vérifiées directement sur le fac-similé du Journal officiel :
  viandes et volailles, poissons de mer (hors luxe) et poisson salé, blé et
  maïs non de semence, huile végétale, aliments pour enfants, levure, aliments
  du bétail, sel, quinine, insuline, antibiotiques et autres produits
  pharmaceutiques, engrais, insecticides, articles d'hygiène médicale, cahiers
  et livres scolaires, lunettes, fauteuils roulants, appareils et mobilier
  médicaux.
- **La déclaration est mensuelle** (loi n° 12-97, art. 32), confirmé par PwC
  et Almathe & Associés (sources secondaires).
- **La facture porte une date, un numéro de série ininterrompu par an et le
  NIU** (loi n° 12-97, art. 29 ; loi n° 8-2012, marquage de sécurité) :
  `documents.numbering` est `gapless_per_year`.
- **Le régime de la facturation électronique certifiée (SFEC)** conditionne la
  déduction de la TVA et la déductibilité à l'IS des charges à une facture
  émise par le système à compter de son déploiement, étagé par catégorie de
  contribuable (1er août 2026 pour les UGE/UME/USTPG et leurs fournisseurs,
  1er décembre 2026 pour les très petites entreprises) — ce n'est pas une
  obligation générale d'émission dématérialisée à une date unique, donc
  `einvoicing.mandatory_from` reste vide.

## What it does not say

- **L'échéance de la déclaration mensuelle de TVA elle-même.** Le texte
  d'origine de 1997 dit « dans les quinze jours du mois suivant » (art. 31) ;
  PwC (revue le 07/08/2026) dit « before the 20th day of every month ». Deux
  sources en désaccord, aucun texte consolidé lu pour trancher :
  `tax_report.json` ne porte donc pas de `deadline`.
- **Le formulaire imprimé et la numérotation de ses cases** ne sont publiés
  dans aucune source officielle trouvée ; les cases de ce pack sont nommées
  d'après ce que les articles 17, 32 et 37 de la loi TVA font déclarer, comme
  au Tchad et au Sénégal.
- **Le précompte de TVA et des centimes au taux cumulé de 18,9 % sur les
  paiements de l'État** (loi de finances pour 2026, § 4.a) — un tiers (le
  Trésor) retient la taxe due par le fournisseur sur une facture payée sur le
  budget de l'État et la reverse à sa place — est le même mécanisme à trois
  parties que `docs/international.md` documente déjà pour le précompte
  sénégalais, la TVA pour compte de tiers ivoirienne et la retenue à la source
  tchadienne (art. 245) : un tiers désigné retient et reverse la dette d'un
  autre, ce que le socle ne sait pas exprimer. Aucune taxe ne le porte ici.
- **Le timbre fiscal de 1 300 FCFA par page** sur les factures présentées à
  l'État (art. 34 bis du CGI, tome 2, livre 2, cité par la loi de finances
  pour 2026, § 4.d) n'est pas une taxe sur la valeur ajoutée et n'est porté
  nulle part dans ce pack ; sa portée hors commande publique n'a pas été
  vérifiée.
- **La centimes additionnels sur le taux réduit de 5 %** n'est confirmée par
  aucun texte lu : si elle existait, elle porterait le taux effectif à
  5,25 % ; ce pack porte 5 % net, faute de disposition trouvée qui l'établisse.
- **La déductibilité des centimes additionnels** reste une contradiction non
  tranchée entre la directive CEMAC (art. 22-1, qui l'exige) et PwC
  (secondaire, qui la nie) — voir *What the pack says* ci-dessus.
- **`einvoicing.profile`** reste vide : ni profil technique normalisé (UBL,
  schéma d'échange), ni schéma d'identifiant des parties n'ont été trouvés
  publiés par la DGID pour le SFEC à la date de ce pack.
- **Le régime forfaitaire de l'Impôt Général sur le revenu (IGF)**, libératoire
  de la TVA et des centimes pour les contribuables au chiffre d'affaires
  inférieur à 100 millions FCFA, n'est pas modélisé comme un régime distinct :
  ces contribuables ne factureraient aucune des taxes de ce pack.
