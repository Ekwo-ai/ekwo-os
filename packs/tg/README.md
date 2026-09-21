# Togo

Everything Togo adds to Ekwo, as data: the value added tax of the Code général
des impôts et Livre des procédures fiscales (CGI/LPF), where each rate posts,
the declaration it is filed on (Mod TVA 2016) and the sentences the LPF puts on
an invoice. The chart of accounts, the journals and the two statements are the
SYSCOHADA révisé shared by seventeen countries, and they are not written here:
they are copied from [`packs/ohada/`](../ohada/README.md) by
`scripts/ohada-packs.mjs`, which the CI runs to refuse a copy that has
drifted. Edit them there.

**Status: `community`.** Nobody has reviewed it against the law they apply.
The golden year proves the pack is coherent and nothing about whether it is
right. Currency XOF, the CFA franc of the BCEAO, at no decimal.

## Sources

| What | Text | Where |
|---|---|---|
| Rates, exemptions, deduction, exclusions, fait générateur, exigibilité, invoices | Code général des impôts et Livre des procédures fiscales, mis à jour 2025 | `otr.tg`, PDF officiel de l'OTR |
| The declaration and its 27 cases | Déclaration de TVA, Mod TVA 2016, réf. OTR/PrF-Dpl/Bdr/001 | `otr.tg` |
| The frame of the rate | Directive n° 02/2009/CM/UEMOA, art. 29 nouveau | AIFO-UEMOA |
| The filing portal | e-SERVICES, `e-services.otr.tg` | OTR |

`e-services.otr.tg` a répondu HTTP 500 le 21/09/2026 ; son existence en tant
que portail de télédéclaration est attestée par la page de l'OTR sur la
procédure de déclaration en ligne, aucune autre adresse n'a été trouvée.

The CGI/LPF PDF is a scan with a text layer (361 pages, `pdftotext -layout`
reads it cleanly); every article cited below was read in it, not guessed from
the research fiche's summary. Reading it also settled two points the fiche
had left open: the fait générateur and l'exigibilité (art. 189 to 191) and the
exclusions du droit à déduction (art. 197), neither visible in the fiche's
secondary sources.

## What the pack says

- **18 %**, un taux unique (art. 195), sur tout ce qui n'est pas exonéré par
  l'art. 180. Le taux réduit de 10 % qui a existé pour l'hébergement
  touristique agréé a été entièrement abrogé — l'art. 195 du CGI 2025 porte la
  mention « Abrogé » à l'endroit où il se lisait, et aucun autre pourcentage
  n'apparaît dans tout le chapitre TVA du code lu ici. **Togo n'a donc qu'un
  seul taux positif en 2026**, à la différence du Sénégal (18 %/10 %) et de la
  Côte d'Ivoire (18 %/9 %) : voir plus bas la conséquence sur le test
  générique du dépôt.
- **Biens et services postent séparément** — 4431 pour les biens, 4432 pour
  les services — mais dans la **même case** du bordereau (case 7/13, puis case
  8/14 pour les marchés publics) : le formulaire togolais ne distingue pas
  biens et services comme le fait le sénégalais.
- **Le fait générateur et l'exigibilité ne coïncident pas pour les services**
  (art. 189 à 191) : pour un bien, les deux sont la délivrance ; pour une
  prestation de service ou des travaux immobiliers, le fait générateur est
  l'exécution mais l'exigibilité est l'encaissement de l'acompte, du prix ou
  de la rémunération — sauf option pour les débits, accordée par le
  Commissaire des impôts et qui ne peut reporter le paiement après
  l'encaissement. `TG-S-18-SRV` est `cash_basis` : facturée, la taxe attend
  au compte 4432 ; encaissée, elle passe au 4431 et entre dans la case 7/13
  du mois de l'encaissement. Le golden encaisse une prestation en entier un
  mois après la facture, et une autre pour moitié deux mois après : les deux
  cas de figure de l'art. 191-2.
- **Les marchés publics payés par chèque du Trésor** ont leur propre case (8,
  taxe en case 14), au même taux de 18 % : aucun article trouvé ne fonde un
  régime différent, seule la case déclarative change parce que le bordereau
  Mod TVA 2016 l'exige. `TG-S-MP-18` le reproduit à l'identique de la vente
  ordinaire, sourcé sur le formulaire et non sur le CGI.
- **Les exportations** (art. 181-1) sont exonérées avec droit à déduction,
  comme au Sénégal et en Côte d'Ivoire, mais le bordereau les compte dans les
  *opérations taxables* (case 10, au taux de 0 %) et non dans les opérations
  non taxables : `vat_category` `G`, pas `E`.
- **L'exonération de l'art. 180** (soins médicaux, enseignement, journaux hors
  publicité, œuvres d'art vendues par leur auteur, produits agricoles,
  organismes d'utilité générale, liste de l'annexe TVA…) a sa propre case (3).
  Le golden vend des journaux et publications périodiques (art. 180-III-3°).
- **L'exclusion du droit à déduction** (art. 197) est une liste fermée, même
  quand le bien ou le service sert une opération qui ouvre droit à déduction :
  voitures de tourisme (sauf véhicules utilitaires, auto-école, transport
  public ou de la clientèle hôtelière, crédit-bail chez le crédit-bailleur),
  logement des dirigeants et du personnel, réception, restaurant, spectacles,
  déplacement, mobilier de logement, objets non indispensables à l'activité,
  cadeaux (sauf objets publicitaires de moins de 5 000 F CFA HT), services
  liés à un bien exclu, carburant des véhicules. `TG-P-18-ND` le porte ; le
  golden achète une réception de clients (art. 197-2°) et une immobilisation
  qui échappe à l'exclusion parce que c'est un véhicule **utilitaire**
  (art. 197-1°).
- **Les importations** (art. 175-1, 182-2, 194) sont taxées au cordon
  douanier lors de la mise à la consommation, et déduites sur la base de la
  déclaration douanière (art. 201) — dans la même case 18 que les achats
  intérieurs, faute de case séparée sur le bordereau.
- **Un prestataire non établi au Togo** (art. 185) : à défaut de représentant
  fiscal accrédité, la taxe est liquidée et acquittée par le destinataire de
  l'opération. `TG-P-NR-18` la porte au compte 4478, en attente de
  reversement, et déduit la part récupérable dans la case 18 comme un autre
  service — aucune case dédiée trouvée, à la différence de la `TVAPC`
  sénégalaise.
- **La facture normalisée** (LPF art. 64) porte un numéro dans une série
  ininterrompue, une vignette, le NIF, la date, l'identité et le RCCM du
  fournisseur, la nature de l'opération, le prix HT, le taux et le montant de
  la taxe, « exonéré » le cas échéant, et le total dû — sans le NIF du client,
  à la différence du Bénin. En dessous du seuil d'assujettissement (100 000 000
  F CFA, art. 177), elle porte « NE FACTURE PAS LA TVA ».
- **La déclaration** (LPF art. 60) est mensuelle, due au plus tard le 15 du
  mois suivant, même sans opération. Ses 27 cases utiles suivent le bordereau
  Mod TVA 2016 case par case ; les cadres VII, VIII et IX, des annexes
  justificatives sans case propre à la déclaration, ne sont pas repris. Le
  bordereau imprime une incohérence que la fiche avait relevée sans la
  résoudre : la case 24 est intitulée « TVA brute (ligne 15) », alors que la
  ligne 15 n'est qu'une des trois composantes de la case 12 (case 12 =
  13+14+15). Ce pack lit la case 24 comme un report de la case 12, cohérent
  avec le cadre III du même formulaire, et le dit dans `tax_report.json`
  plutôt que de reproduire l'erreur d'impression.

## Ce que le test générique du dépôt ne peut pas vérifier

Le dépôt fait passer à chaque pack le même test : le golden doit exercer plus
d'un taux positif (`tests/golden.test.ts`, *exercises both directions, more
than one rate, and a credit note*), sans condition — à la différence des
autres tests de ce fichier, écrits « là où le pack l'a ». Or la Côte d'Ivoire
et le Sénégal, les deux modèles suivis ici, ont chacun deux taux positifs, et
le Togo n'en a qu'un (18 %) depuis l'abrogation du taux réduit. Ce pack
**laisse ce test rouge** plutôt que d'inventer un second taux qui n'existe
plus dans la loi 2026, ou de dater le golden d'avant l'abrogation pour le
faire passer : les deux auraient été plus faux que le test qui échoue. Tous
les autres tests du dépôt (`pack check`, les sept autres tests du golden, la
suite complète) passent.

## Ce que ce pack ne dit pas encore, et pourquoi

- **La livraison à soi-même (L.A.S.M.)**, case 9/15 du bordereau (art. 175-2,
  190, 191-4), taxée à la première utilisation. Les quatre types de document
  d'un golden — `sale_invoice`, `sale_credit_note`, `purchase_invoice`,
  `purchase_credit_note` — portent tous un `contact`, qu'une livraison à
  soi-même n'a pas : ni le cœur, ni ce pack, ne la représentent. Les cases 9
  et 15 existent dans `tax_report.json`, sans taxe pour les alimenter.
- **Les cases 2, 4 et 5** (opérations non taxables, non imposées sur
  attestation d'exonération, exportations de produits non taxables) : le
  bordereau les distingue de la case 3 (exonérées) et de la case 10
  (exportations taxables à 0 %), mais aucun article du CGI/LPF lu ici ne dit
  ce qui, au juste, sépare une opération « non taxable » d'une opération
  « exonérée », ni une exportation « non taxable » (case 5) d'une exportation
  « assimilée » taxée à 0 % (case 10). Le pack ne modélise que les cases 3, 7,
  8 et 10, dont l'article est clair, et laisse 2, 4, 5, 9 sans taxe plutôt que
  de deviner la distinction.
- **La déduction différée au paiement, côté achat.** L'art. 199, dernier
  alinéa, ouvre le droit à déduction d'une prestation de service dans le mois
  du *paiement*, pas dans celui de la facture — le miroir de l'encaissement
  côté vente, que `cash_basis` porte pour une taxe de vente avec un compte de
  transition. Aucun champ équivalent n'existe pour une taxe d'achat :
  `TG-P-18-SRV` déduit à la facturation et le dit dans son
  `legal_reference`, comme `CI-P-18-SRV` le fait déjà pour la même raison,
  art. 361-2° ivoirien à l'appui.
- **Le crédit de TVA reporté** (case 17) et les régularisations (cases 20 et
  21) : des montants que le redevable reporte lui-même d'une déclaration à
  l'autre ou justifie sur pièces. `settle_filing()` ne les recalcule pas et le
  golden ne les exerce pas.
- **L'arrondi à la dizaine de francs** (art. 194) : la taxe togolaise se
  liquide sur des sommes « préalablement arrondies à la dizaine de francs la
  plus proche », un arrondi de grandeur et non de décimale.
  `defaults.rounding_method` ne connaît que l'arrondi à l'unité de la
  devise. Le golden choisit des montants déjà multiples de 10 pour ne pas
  poser la question.
- **La facture électronique certifiée (FEC).** La loi de finances 2026
  l'aurait introduite (nouvel art. 62 du LPF, arrêté n° 029/MFB/CAB/UPF du
  19/02/2026), mais seules des sources secondaires (patronat, presse
  économique) en parlent ; ni la loi, ni l'arrêté, ni la nouvelle rédaction de
  l'art. 62 n'ont été lus, et le cahier fiscal 2026 officiel de l'OTR ne la
  cite pas dans sa table des matières. `einvoicing` reste vide.
- **Les caisses automatiques** (LPF art. 62) et la conservation des pièces dix
  ans (art. 63) sont des obligations que le schéma d'un pack ne porte pas.
- **Le sous-traitant du BTP** (art. 192) qui récupère la taxe retenue par
  l'entrepreneur principal sur ses propres paiements : un mécanisme de
  précompte entre redevables que ni `packs/sn/` ni `packs/ci/` ne portent non
  plus, pour la même raison — une deuxième déclaration que le schéma ne sait
  pas dupliquer (voir `docs/international.md`, *A pack carries one form*).
