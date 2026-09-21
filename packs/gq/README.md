# Equatorial Guinea

Everything Equatorial Guinea adds to Ekwo, as data: the value added tax
(*Impuesto sobre el Valor Añadido*, IVA) of the Ley General Tributaria, where
each rate posts, the declaration it is filed on and the sentences the law
puts on an invoice. The chart of accounts, the journals and the two
statements are the SYSCOHADA révisé shared by seventeen countries, and they
are not written here: they are copied from
[`packs/ohada/`](../ohada/README.md) by `scripts/ohada-packs.mjs`, which the
CI runs to refuse a copy that has drifted. Edit them there.

**Status: `community`.** Nobody has reviewed it against the law they apply.
The golden year proves the pack is coherent and nothing about whether it is
right. Currency XAF, the CFA franc of the BEAC, at no decimal, CEMAC zone.
The law itself, and the printed return, are written in Spanish; this pack,
like every OHADA member, is written in French — no partial Spanish wording is
carried, see *Languages* below for why.

## Sources

| What | Text | Where |
|---|---|---|
| Rates (art. 155), exemptions (art. 140-142), invoice mentions (art. 24), the monthly declaration and its deadline (art. 167), the credit and refund (art. 170), the self-assessment for non-residents (art. 146, 167-7), electronic invoicing (art. 24-4, 1-40) | Ley n° 1/2024, de fecha 19 de noviembre, General Tributaria | fac-similé du BOE, scan OCR, hébergé par Hay Derecho en Guinea |
| L'obligation de faire figurer la TVA sur toute facture de vente | Orden Ministerial n° 04/2025, du 5 septembre 2025 | reprise par Guinea Ecuatorial Press |
| Le cadre communautaire des taux | Directive n° 11/22-CEMAC-UEAC-010A-CM-38 du 10 novembre 2022 | `sgg.cg` |
| Le site du Ministerio de Hacienda et sa page de formulaires fiscaux | Ministerio de Hacienda, Planificación y Desarrollo Económico | `minhacienda-gob.com/formularios-de-declaraciones-fiscales` |
| L'imprimé de la déclaration de TVA lui-même (cases 01 à 030) | Autoliquidación, I.V.A., Régimen Real (cod. impuesto 1220) | PDF téléchargé depuis `minhacienda-gob.com`, lu au format texte (pdftotext) |

**Le texte de la Ley 1/2024 n'a pu être lu que par un scan OCR** (268 pages,
hébergé sur Google Drive par un cabinet, pas par le BOE lui-même, injoignable
en direct) ; les articles 1, 22 à 25, 80, 94-95, 134 à 170, 176 et les
dispositions finales ont été relus, l'un contre l'autre, page par page.
**Aucune loi de finances 2025 ou 2026 n'a été trouvée** : rien ne dit si l'une
d'elles modifie la TVA depuis la Ley 1/2024. La Ley 4/2004 qu'elle remplace
(15 % et 6 %) n'a pas pu être relue au-delà de ce que la Ley 1/2024 et la
presse en disent — son propre exposé des motifs cite la Ley 1/2024.

## What the pack says

- **Trois taux, plancher CEMAC.** 15 % général (art. 155-2) ; 5 % réduit
  (art. 155-3, `GQ-S-5` pour les biens, `GQ-S-5-SRV` pour la seule prestation
  de service de la liste, la fourniture d'eau, de gaz et d'électricité à
  usage domestique), remplaçant les 6 % de la Ley 4/2004 — l'exposé des
  motifs dit « actualizar el tipo reducido del 6 % al 5 % » ; taux zéro
  (art. 155-4), scindé ici entre l'exportation et le transport international
  (`GQ-S-0-EXP`, catégorie EN 16931 `G`) et six autres opérations —
  antipaludiques, masques et réactifs médicaux, livres scolaires,
  chimiothérapie, dialyse, intrants agropastoraux, produits du sous-sol
  vendus par leur producteur au consommateur final hors hydrocarbures et
  mines (`GQ-S-0`, catégorie `Z`) — parce qu'un taux zéro reste un taux de la
  taxe qui ouvre droit à déduction, à la différence d'une exonération.
  **Aucun taux majoré** : un taux de 30 % qui circule pour la Guinée
  équatoriale n'est pas un taux d'IVA — ce sont les droits d'accises
  (*impuestos especiales*, art. 176, boissons et tabac) ou le taux maximal du
  tarif extérieur commun douanier ; ni l'un ni l'autre ne figure ici.
- **La liste des biens au taux réduit dépasse très largement la liste
  fermée de la directive CEMAC** (art. 22, 2°, c) — laits, boulangerie-
  pâtisserie, riz, farine, engrais, pesticides) : ciment, fer à béton, tôles
  de zinc, outillage, matelas, allumettes et la fourniture domestique d'eau,
  de gaz et d'électricité y figurent aussi. Ce pack enregistre l'écart, il
  ne le corrige pas.
- **Les exonérations de l'art. 141** — opérations financières et
  d'assurance, ventes d'immeubles jusqu'à la 3e transmission et locations
  d'habitation de particuliers, importations en franchise, presse hors
  publicité, soins médicaux, médicaments vendus par un centre médical
  public, frais de scolarité agréés, avitaillement international, organismes
  sans but lucratif — sont fermées par l'art. 140, qui exclut toute
  exonération hors la loi, y compris au titre d'une convention
  d'investissement particulière.
- **L'autoliquidation pour un fournisseur non-résident** (art. 146, 167-7,
  `GQ-P-NR-15`) : l'acheteur assujetti autoliquide la taxe qu'un fournisseur
  établi hors de Guinée équatoriale ne facture pas, sur le modèle du
  `treatment: foreign_services_received` déjà utilisé par d'autres packs. Ces
  deux articles ont été relus dans leur intégralité, mais la fiche de
  recherche de ce pack n'en a pas conservé la citation littérale — voir *What
  it does not say*.
- **La déclaration est mensuelle**, due « a más tardar el quince (15) del
  mes siguiente a la de facturación » (art. 167-1), une déclaration
  « nula y/o negativa » étant obligatoire même sans opération (art. 167-2).
  Le crédit de TVA se reporte sans limite ; un remboursement existe sous
  3 mois pour les exportateurs, les crédits structurels dus au taux réduit,
  les missions diplomatiques et les investissements de plus de 100 millions
  de FCFA (art. 170), mécanisme que ce pack ne modélise pas.
- **La facture** porte, sous peine de nullité (art. 24-2) : côté fournisseur,
  raison sociale, numéro séquentiel et date, domicile fiscal, NIF, téléphone,
  courriel, signature et cachet, montant hors taxes, taux, montant de la
  taxe, total TTC ; côté client, raison sociale, domicile fiscal, NIF,
  téléphone et courriel — plus que le RCCM et le régime d'imposition que la
  directive CEMAC (art. 31) demande, et sans eux. L'Orden Ministerial
  n° 04/2025 impose en outre de faire figurer la TVA sur toute facture de
  vente, en application des art. 24.2 et 138.1.
- **Aucune obligation de facture électronique** n'a été trouvée : le
  « Sistema de Facturación Electrónico » de l'art. 24-4 est un dispositif
  facultatif, agréé et certifié par l'administration, pas une obligation à
  une date donnée — `einvoicing.profile` et `.mandatory_from` restent nuls,
  comme dans `packs/td/` et `packs/ga/`.
- **Le formulaire imprimé existe et a été trouvé** : « AUTOLIQUIDACIÓN,
  IMPUESTO SOBRE EL VALOR AÑADIDO, I.V.A., Régimen Real » (code impôt 1220),
  publié en PDF sur le site du Ministerio de Hacienda. Les cases de
  `tax_report.json` reprennent sa propre numérotation — `01`/`03` (base et
  cuota au taux général), `04`/`06` (taux réduit), `07` (« Base Exonerada »,
  la ligne unique où l'imprimé réunit taux zéro et exonération), `022`
  (déduction sur opérations intérieures), `025` (déduction sur immobilisations),
  `021` (total dû), `028` (total déductible), `029`/`030` (net à payer ou
  crédit) — au lieu de cases inventées par ce pack, à la différence de
  `packs/td/` et `packs/sn/`, dont l'imprimé n'a pas été trouvé. Une partie
  des cases de l'imprimé n'est pas modélisée : voir *What it does not say*.

## What it does not say

- **La retenue d'IVA à la source de l'art. 167-4** — l'État, les organismes
  publics et des entreprises privées désignées retiennent 100 % de la taxe
  due par un fournisseur classé « à risque » (personne physique,
  non-résident, non-assujetti), 0 % pour une personne morale de la Unidad de
  Grandes Empresas, 40 % pour les autres — n'est modélisée par aucun code de
  ce pack. C'est une retenue à trois parties, comme le précompte sénégalais
  et la retenue de la CSS gabonaise : le taux dépend d'une classification du
  vendeur que le document ne porte pas et qu'aucune liste officielle
  trouvée ne fixe, et le core n'a pas de mécanisme de « retenue au paiement »
  pour exprimer comment les livres du vendeur constatent une taxe que
  l'acheteur retient et reverse à sa place. Le texte dit que la taxe retenue
  est déductible ou remboursable chez le fournisseur (art. 167-4), sans dire
  comment.
- **La retenue de 1,5 % (Cuota Mínima Fiscal, art. 80-3)** sur les services
  payés par l'État et les entités publiques est un impôt sur le revenu
  retenu au paiement, pas une TVA ; le core n'a pas de retenue au paiement,
  comme le BRS sénégalais qu'aucun pack ne modélise non plus.
- **Les impuestos especiales de l'art. 176** — 30 % plus un montant par
  unité sur les boissons et le tabac, 10 % sur les télécommunications et
  l'audiovisuel hors TVA, 15 FCFA par sac plastique — sont des droits
  d'accises réels mais non systématiques sur une facture ordinaire, comme
  les droits d'accises gabonais de l'art. 250 ; aucun n'est dans l'année
  témoin.
- **L'autoliquidation de la TVA à l'importation pour les biens d'équipement
  de plus de 100 millions de FCFA** (art. 169) est un mécanisme d'importation
  distinct de l'achat local que `GQ-P-15-IMMO` couvre ; ce pack ne porte pas
  de code d'importation.
- **Quatre cases de l'imprimé ne sont pas modélisées** : l'intérêt de retard
  de la case 012 (art. 412), le recargo de la case 015 (art. 410), les
  « Adquisiciones Intracomunitarias » des cases 19/020 et 024 — un vocabulaire
  calqué sur un modèle de l'Union européenne dont le rapport avec le droit
  équato-guinéen, qui n'a pas de notion d'« intracommunautaire », n'est pas
  établi — et la TVA sur importations de la case 023. La formule imprimée des
  cases 021 (total dû) et 028 (total déductible) additionne ces éléments ;
  `GQ-TVA` ne les additionne pas, et le dit dans le `legal_reference` de
  chacune des deux cases.
- **Le report du crédit d'une période à l'autre (case 027) n'est pas
  automatisé.** L'imprimé fait réapparaître le crédit de la case 030 d'un
  mois comme une ligne déductible (case 027, « Créditos de I.V.A., de
  periodos anteriores, a compensar ») du mois suivant ; ce pack calcule
  `030` mois par mois sans le réinjecter dans `028` du mois d'après.
- **L'arrondi a une contradiction interne non résolue** : l'art. 154 arrondit
  la base à l'unité de FCFA supérieure, l'art. 155-1 « a la última unidad
  inferior a la milésima » (à l'unité de mille inférieure). Ce pack déclare
  `rounding_method: half_up`, la méthode technique de l'écriture comptable,
  sans trancher laquelle des deux règles fiscales l'administration applique
  en pratique.
- **Le fait générateur et l'exigibilité** (par nature d'opération, comme au
  Tchad et au Gabon) n'ont pas été trouvés dans les articles lus : ce pack
  ne déclare pas de `tax_point`.
- **Le portugais comme troisième langue officielle**, que la fiche de
  recherche de ce pack cite sans l'avoir trouvé ni chargé, n'est pas
  modélisé — seul l'espagnol l'est, partiellement, voir *Languages*.
- **La citation exacte des art. 146 et 167-7** qui fondent `GQ-P-NR-15` n'a
  pas été conservée dans la fiche de recherche de ce pack, alors que
  l'intervalle d'articles relus (134 à 170) les couvre : un lecteur qui
  isolerait leur texte exact devrait vérifier que l'autoliquidation qu'ils
  décrivent est bien celle que ce code modélise, et sa déductibilité.

## Languages

`defaults.language` est `fr`, comme le veut [`packs/ohada/`](../ohada/README.md#languages) :
le plan comptable est écrit en français et aucune traduction officielle n'en
existe en espagnol. La Ley n° 1/2024 elle-même est un texte officiel en
espagnol (« preferentemente en idioma español », art. 22-2), et ce pack ne
porte pourtant aucun `i18n/es.json`, à la différence de ce que
`packs/ohada/README.md#languages` envisage pour lui (« may carry pack_name,
the taxes, the boxes and the mentions… undeclared »). Un tel fichier a été
écrit puis retiré : `ekwo pack check` et `npm test` compilent le contenu de
tout fichier présent dans `i18n/` dans les tables de seed (`country_defaults.
name_i18n`, `tax_templates.name_i18n`, `legal_mention_templates.text_i18n`,
…) sans regarder s'il est déclaré dans `languages`, alors que
`tests/languages.test.ts` exige l'inverse (« carries no language the
manifest does not declare ») — un désaccord entre ce que le README de
`packs/ohada/` promet et ce que compilateur et suite de tests appliquent
réellement, signalé au lead plutôt que contourné ici. Déclarer `es` dans
`languages` exigerait à l'inverse de couvrir tout le plan de 1 358 comptes,
ce qu'aucune traduction officielle ne permet (voir
`packs/ohada/README.md#languages`).
