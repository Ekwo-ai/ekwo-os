# Mali

Everything Mali adds to Ekwo, as data: the value added tax of the Code
général des impôts, where each rate posts, the declaration it is filed on and
the sentences the Code puts on an invoice. The chart of accounts, the journals
and the two statements are the SYSCOHADA révisé shared by seventeen countries,
and they are not written here: they are copied from
[`packs/ohada/`](../ohada/README.md) by `scripts/ohada-packs.mjs`, which the CI
runs to refuse a copy that has drifted. Edit them there.

**Status: `community`.** Nobody has reviewed it against the law they apply.
The golden year proves the pack is coherent and nothing about whether it is
right. Currency XOF, the CFA franc of the BCEAO, at no decimal.

**Confidence: medium.** The register below is a single consolidated CGI
served by the DGI, dated 2 August 2017, plus one annexe fiscale (LF 2022) and
one loi de finances (2024) read in full; the CGI's own consolidation is eight
years old and the annexes fiscales of 2023, 2024, 2025 and 2026 were not read
article by article. Every rate, box and mention below cites the article it
comes from; where no article was found, the pack says so instead of guessing.

## Sources

| What | Text | Where |
|---|---|---|
| Rates, exemptions, invoice mentions (Livre de procédures fiscales) | Code général des impôts, mis à jour au 02/08/2017 | `dgi.gouv.ml/CGI/` |
| 5 % extended to matériel agricole (art. 195 IV D) and to l'hébergement, la restauration et les circuits touristiques agréés (art. 195 E nouveau) | Annexe fiscale à la loi n° 2021-071 du 23 décembre 2021 (loi de finances 2022) | `dgi.gouv.ml`, PDF scanné |
| 40 % retenue de TVA — modèle de certificat | Modèle de certificat de retenue de la taxe sur la valeur ajoutée | `dgi.gouv.ml` |
| Introduction annoncée de la facture normalisée, TVA sur les plateformes de commerce électronique | Loi de finances pour l'année 2024 | `finances.ml` |
| Facture normalisée à sticker | Décret n° 2022-0733/PT-RM du 25 novembre 2022 | annoncé par `dgi.gouv.ml` |
| Filing | e-Impôt | `e-impot.dgi.gouv.ml` (portail applicatif, contenu non lisible en l'état) |
| Le cadre des taux | Directive n° 02/2009/CM/UEMOA, art. 29 nouveau | AIFO-UEMOA |

**Aucune édition consolidée du CGI postérieure à 2017 n'est publiée par
l'administration.** Les annexes fiscales des lois de finances 2023, 2024, 2025
et 2026 n'ont pas été lues article par article ; seule la loi de finances 2024
a été ouverte, pour sa note de présentation. Le rapport d'activité annuel 2025
de la DGI (PDF scanné de 90 pages, `dgi.gouv.ml`) pourrait renseigner la
facture normalisée et e-Impôt : il a été téléchargé mais non exploité.

## What the pack says

- **18 %** sur tout ce qui est taxable (art. 229) ; **5 %** sur trois listes
  distinctes de l'art. 195 IV D et de l'art. 195 E (nouveau) : matériel
  informatique et de production d'énergie solaire (positions tarifaires,
  antérieur à 2018), matériel agricole (positions 82.01, 84.24.81.10/90,
  84.32.10 à 84.32.80, ajouté par l'annexe fiscale 2022, exercice 2022), et
  hébergement, restauration et circuits touristiques des établissements
  **agréés** (même annexe, exercice 2022 également). Un établissement
  d'hébergement non agréé facture 18 %, comme au Sénégal. Faute d'un
  formulaire officiel trouvé, les trois entrent dans une seule case `CA5`/
  `TVA5` de `tax_report.json` : la loi ne semble pas exiger de les distinguer,
  seul le compte comptable (4431 pour les biens, 4432 pour les services)
  change.
- **Biens et services postent à part** — 4431 côté ventes, 4432 pour les
  prestations, 4451/4452/4454 côté achats — parce que le plan a les comptes,
  suivant la même convention que `packs/sn` et `packs/ci`.
- **`invoice_if_issued`** est déclaré comme fait générateur général, faute
  d'article malien identifié qui le fixe explicitement (livraison, encaissement
  des services) : c'est le principe le plus répandu dans la zone UEMOA
  (`packs/sn`, `packs/ci`), pas une lecture du CGI malien. Aucune taxe de ce
  pack n'est `cash_basis`, pour la même raison : aucun article trouvé ne le
  prescrit ni ne l'exclut pour les prestations de services.
- **Les exportations** (art. 195) sont exonérées, sans que le texte consulté
  ne détaille, comme au Sénégal, si le droit à déduction est conservé ; ce
  pack ne l'affirme pas (`vat_category` `G`, comme un export ordinaire, sans
  poser `recoverable`).
- **La déclaration** est mensuelle pour le régime du réel normal, due dans les
  quinze premiers jours du mois suivant (Livre de procédures fiscales,
  art. 110-2), même sans opération. Ses cases suivent le contenu que l'article
  impose et non un formulaire, dont le modèle exact n'a pas été trouvé.
- **La facture** porte, selon l'art. 115 du Livre de procédures fiscales, le
  prix hors taxe, le taux, le montant de la TVA, le prix net, le régime
  d'imposition du fournisseur et le NIF du vendeur et de l'acheteur ; une
  entreprise à l'impôt synthétique ne peut y faire figurer de TVA.

## What it does not say

- **Le régime du réel simplifié** (Livre de procédures fiscales, art. 110-3) :
  une déclaration annuelle unique, due au plus tard le 15 mai de l'année
  suivante. `tax_report.json` ne porte que la cadence mensuelle du réel
  normal : une échéance annuelle décalée de plusieurs mois après la clôture
  ne s'exprime pas dans la forme `day_of_month_after_period` /
  `last_day_of_month_after_period` que le schéma offre — c'est un manque du
  socle (plusieurs formulaires pour un même impôt), pas un choix de ce pack.
- **La retenue de TVA à 40 %** (modèle de certificat de retenue, DGI, en
  application de la lettre-circulaire n° 1277/MEF-SG du 12 avril 2023) : le
  CGI 2017 prévoit une retenue de TVA sur les fournitures payées par le Trésor
  public, mais sans article identifié dans le texte consulté, et le champ
  exact des redevables tenus de retenir (seulement le Trésor ? les grandes
  entreprises aussi ?) n'est précisé par aucune des sources ouvertes. Une
  retenue par le client est en outre une retenue **au paiement** de la
  facture, que le socle ne modélise pas (voir `docs/international.md`). Ni
  taux, ni compte, ni condition ne sont inventés ici : aucun code de taxe ne
  la porte.
- **Le précompte IBIC/IS** (CGI, art. 98-A à 98-F) : 5 % sur les ventes à des
  acheteurs sans NIF, 1,5 % sur les fournitures payées par le Trésor, mention
  distincte obligatoire sur la facture (art. 227-N). C'est un acompte d'impôt
  sur les bénéfices assis sur une vente, pas une TVA, et sa mécanique de
  collecte (qui le prélève, sur quelle base exacte — « prix TTC hors TVA » —
  et sur quel compte du plan il attend) n'a pas pu être confirmée par un texte
  lu article par article. Il n'est pas modélisé ici, faute de pouvoir
  le vérifier sans inventer un compte ou un sens de flux.
- **La facture normalisée** (décret n° 2022-0733/PT-RM du 25 novembre 2022) :
  la loi de finances 2024 parle encore d'en « introduire » le dispositif, ce
  qui indique qu'il n'était pas en service fin 2023 ; aucun arrêté
  d'application, aucun format technique et aucune date d'obligation effective
  n'ont été trouvés.
- **La numérotation de la facture** : aucun article imposant une séquence
  n'a été identifié (contrairement à l'art. 447-I-5 du Sénégal). Le socle
  n'émet aucun document sans `documents.number_format` ; ce pack déclare donc
  `gapless_per_year` et `{CODE}/{YYYY}/{NNNN}` comme un choix opérationnel,
  et le dit dans `documents.references.numbering` — ce n'est pas une règle
  malienne confirmée.
- **Le formulaire de déclaration** : ni son nom, ni la numérotation de ses
  cases n'ont été trouvés ; e-Impôt (`e-impot.dgi.gouv.ml`) est une
  application JavaScript dont le contenu n'a pas pu être lu, et l'obligation
  de télédéclaration n'est pas confirmée.
- **Les exclusions du droit à déduction** (comme les véhicules de tourisme au
  Sénégal, art. 383) : aucun article équivalent n'a été identifié pour le
  Mali ; ce pack ne porte donc aucune taxe d'achat non déductible.
- **La TVA à l'importation** : le CGI malien la prévoit certainement, comme
  tout régime de TVA, mais aucun article fixant son fait générateur ou son
  exigibilité n'a été lu ; aucun code `import` n'est déclaré ici.
- **Le report du crédit de TVA** : aucune limite dans le temps (comme les deux
  ans du Sénégal) n'a été trouvée ; `CRED` le porte donc sans plafond.

## Points à faire relire par un comptable local

- La date d'entrée en vigueur du taux de 18 % et du taux de 5 % informatique
  et solaire (antérieurs à 2018, sans date précise trouvée).
- Le champ exact des redevables tenus de retenir 40 % de la TVA, et l'article
  du CGI qui institue cette retenue au-delà des fournitures payées par le
  Trésor.
- L'existence, l'assiette exacte et le compte comptable du précompte IBIC/IS.
- Le fait générateur de la TVA sur les prestations de services (encaissement
  ou livraison) et sur les importations.
- Le nom, les cases et l'obligation de télédéclaration du formulaire de TVA.
