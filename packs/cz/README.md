# Czechia

Everything Czechia adds to Ekwo, as data: a chart of accounts built on the
class-and-group structure the accounting decree prescribes, the journals, the
VAT rates and where each one posts, the boxes of the monthly VAT return, the
rozvaha and the výkaz zisku a ztráty of the accounting decree, and the
sentences the law puts on an invoice. The format is
[`docs/packs.md`](../../docs/packs.md); this file says where the content came
from and which decisions it rests on, so that a Czech účetní or daňový poradce
reading the pack can disagree with a specific sentence rather than with the
whole of it.

**Status: `community`.** Nobody has reviewed it against the law they apply.
The figures are replayed against three months of books by
`tests/golden.test.ts`, which proves the pack is coherent and proves nothing
about whether it is right.

**Language: `cs`.** The pack's own labels are written in Czech, which is also
the language of every text in the register below and of the accounting
decree's own directive chart of accounts; no second language file is
declared.

## Sources

Every rate, box, mention and statement line carries its own `legal_reference`
and names the entry of `certification.sources` its article is in. The
register holds twenty-one texts.

| What | Text | Publisher |
|---|---|---|
| Rates, exemptions, reverse charge, tax point, invoice particulars, the declaration and its deadline | Zákon č. 235/2004 Sb., o dani z přidané hodnoty (konsolidované znění) | e-Sbírka (Ministerstvo vnitra ČR) |
| Sazba TVA à 21 %/12 % depuis le 1er janvier 2024 | Zákon č. 349/2023 Sb. (konsolidační balíček) | e-Sbírka |
| Seuils d'assujettissement et de l'option trimestrielle depuis le 1er janvier 2025 | Informations de la Finanční správa (transposition de la directive UE 2020/285) | financnisprava.gov.cz |
| Formulaire de la déclaration | Přiznání k DPH, tiskopis 25 5401 MFin 5401, vzor č. 25 | financnisprava.gov.cz |
| Kontrolní hlášení, souhrnné hlášení | Pages dédiées et formulaire 25 5525 | financnisprava.gov.cz |
| Comptabilité, plan comptable directeur, bilan, compte de résultat | Zákon č. 563/1991 Sb. et vyhláška č. 500/2002 Sb. | e-Sbírka |
| Délai de paiement supplétif et intérêt de retard | Zákon č. 89/2012 Sb. (§ 1963, § 1970) et nařízení vlády č. 351/2013 Sb. | e-Sbírka, Česká národní banka |
| Arrondi des paiements en espèces | Zákon č. 634/1992 Sb., § 3 odst. 1 písm. c) | e-Sbírka, Ministerstvo financí ČR |
| Facturation électronique dans les marchés publics | Zákon č. 134/2016 Sb., § 221 et § 279 | e-Sbírka, Ministerstvo financí ČR, Ministerstvo vnitra ČR (ISDOC) |
| Codes de la facture électronique | EN 16931, UNCL5305, VATEX | European Commission (docs.peppol.eu) |

**Le rendu automatisé n'a pas pu ouvrir e-sbirka.gov.cz** (portail applicatif
rendu en JavaScript, comme `RIS` pour `packs/at/`) ; les articles ont donc été
lus par recoupement de plusieurs miroirs qui republient le texte officiel
paragraphe par paragraphe (kurzy.cz, businesscenter.podnikatel.cz), croisés
avec les informations et brochures officielles de la Finanční správa et du
Ministerstvo financí, et vérifiés par des recherches ciblées sur le libellé
exact de chaque disposition citée. Un relecteur qui ouvre les URL de
`certification.sources` dans un navigateur fait le contrôle que cette
automatisation n'a pas pu faire elle-même.

## Le plan comptable, et pourquoi celui-ci

**La Tchéquie prescrit un plan comptable directeur, mais seulement jusqu'au
groupe.** Contrairement à l'Autriche, à l'Allemagne ou à l'Italie, voisines de
ce pack, qui ne prescrivent aucun plan, et contrairement à la Belgique ou à la
France, qui prescrivent un plan jusqu'au compte lui-même, la vyhláška
č. 500/2002 Sb., příloha č. 4 (směrná účtová osnova) fixe par la loi les
účtové třídy (classe, un chiffre) et les účtové skupiny (groupe, deux
chiffres) — 21 groupes pour dix classes — et s'arrête là : § 4 odst. 8 de la
loi comptable renvoie ce pouvoir réglementaire à la vyhláška, qui l'exerce à
ce niveau précis. Chaque entreprise construit ensuite son propre účtový
rozvrh, ses comptes synthétiques à trois chiffres et plus, à l'intérieur de
ces groupes.

Les comptes de ce fichier suivent donc, au-delà des deux premiers chiffres,
la convention la plus répandue de la pratique comptable tchèque — celle
enseignée et celle des logiciels du marché (311 odběratelé, 321 dodavatelé,
343 daň z přidané hodnoty, 411 základní kapitál, 501 spotřeba materiálu…) —
et non un texte à citer un par un : seuls les deux premiers chiffres de
chaque code sont d'origine légale, un fait signalé une fois dans
`pack.json` plutôt que sur chaque ligne d'`accounts.csv`.

**Le compte 343 (Daň z přidané hodnoty) est éclaté en cinq comptes à quatre
chiffres** (3431 à 3439) : la loi ne prescrit rien au-delà du groupe 34, et ce
pack a besoin de distinguer, dans les mêmes deux chiffres légaux, la TVA
collectée par taux, la TVA déductible et les deux comptes de règlement
(`tax_payable` 3438, `tax_receivable` 3439) qu'un `settle_filing()` doit
pouvoir solder sans compenser silencieusement l'accrual du mois suivant.

**Le résultat de l'exercice reste sur un compte unique (431, Výsledek
hospodaření ve schvalovacím řízení), profit ou perte.** `closing_style` est
donc `result_accounts` : le résultat n'entre pas directement dans les
réserves comme au Royaume-Uni ou aux États-Unis, il attend l'assemblée qui
l'affecte, mais — à la différence de la France (120 et 129) ou de la Belgique
(693/793 à 140/141) — la vyhláška ne prévoit qu'une seule ligne A.V. de la
rozvaha pour les deux signes, d'où `current_year_result_profit` et
`current_year_result_loss` pointant vers le même compte 431.

## Les taxes

Dix codes : deux taux positifs (21 %, 12 %, en vigueur depuis le 1er janvier
2024 — zákon č. 349/2023 Sb. a fusionné les deux anciens taux réduits de 10 %
et 15 % en un seul), trois opérations exonérées avec droit à déduction
(livraison intracommunautaire de biens, prestation de services
intracommunautaire B2B, export), une exonération sans droit à déduction (bail
immobilier, § 56a), et quatre codes côté achat dont deux autoliquidés par
l'acquéreur.

**L'autoliquidation, à l'achat, s'écrit en deux jambes sur le même compte de
TVA collectée et le même compte de TVA déductible que les opérations
ordinaires**, plutôt que sur des comptes dédiés — à la différence du modèle
estonien que `docs/packs.md` prend pour exemple (`EE-P-ICG-24`, qui utilise
deux comptes séparés). Le montant autoliquidé (řádek 3 pour une acquisition
intracommunautaire, řádek 10 pour un sous-traitant du bâtiment en régime
national de l'article 92e) est intégralement déductible dans ce pack : une
seconde jambe `tax` de facteur −100, sans case, solde le compte de TVA
déductible 3433 pour le même montant, exactement comme le réclame l'article
73 odst. 1 písm. b) pour un bien ou un service affecté à une activité
économique imposable.

**Un seul reverse charge national est modélisé : les travaux de construction
et de montage de l'article 92e.** La loi en porte d'autres (§ 92b déchets et
métaux usagés, § 92c émissions de gaz à effet de serre, § 92d téléphones et
circuits intégrés, § 92f livraisons de gaz et d'électricité) : aucun n'est ici,
faute d'avoir vérifié leur portée précise pendant l'écriture de ce pack — un
relecteur qui en ajoute un devrait lire l'article correspondant directement.

**Le krácený odpočet (déduction proportionnelle de l'article 76, pour un
assujetti dont l'activité n'est pas intégralement imposable) n'est pas
modélisé.** Les řádky 51 à 53 et 60 du formulaire, qui portent le coefficient
et son ajustement, ne sont donc pas dans `tax_report.json` ; chaque taxe
d'achat de ce pack est écrite comme intégralement déductible.

**L'importation (řádky 7 et 8), l'acquisition d'un moyen de transport neuf
(řádek 9), les corrections liées à l'insolvabilité du débiteur ou du créancier
(řádky 33 et 34) et le remboursement de l'article 84 (řádek 61) ne sont pas
modélisés non plus.**

## La déclaration

`CZ-DPH-PRIZNANI` transcrit une partie du tiskopis 25 5401 : les řádky 1 à 3,
10, 20 à 22, 40, 41, 43, 46, 50 et 62 à 65, chacun avec le libellé du
formulaire officiel. Le řádek 43 (« Zdanitelná plnění řádků 3-13 — základní
sazba ») est un total au sens du format — il reporte, côté déduction, la
même taxe déjà déclarée côté autoliquidation aux řádky 3 et 10, jamais une
seconde écriture — exactement le mécanisme que la Luxembourg's eCDF et
l'Estonian KMD illustrent déjà dans `docs/packs.md`.

**L'échéance** est le vingt-cinquième jour suivant la fin de la période
(§ 101 odst. 1), non prorogeable ; `period_default` propose le mois, qui est
la règle de l'article 99, l'option trimestrielle de l'article 99a restant
ouverte sous condition de chiffre d'affaires (15 000 000 Kč depuis le 1er
janvier 2025) que ce pack ne devine pas.

## Ce que le socle ne sait pas faire

**Le kontrolní hlášení n'a aucune forme dans ce format, et ce n'est pas
seulement la limite déjà consignée sous « From the recapitulative statement ».**
Cette note-là dit qu'un pack ne déclare qu'un seul formulaire
(`tax_report.json` est un objet, pas une liste) et propose, pour le jour où ce
sera résolu, une liste de formulaires par pack. Cela ne suffirait pas ici :
même avec plusieurs formulaires, chacun reste une liste de cases, sommées ou
calculées, depuis les écritures postées — la forme qu'une déclaration
périodique a partout dans ce dépôt. Le kontrolní hlášení (§ 101c à § 101i) est
d'une autre nature : au-delà de 10 000 Kč TTC, chaque document fiscal se
déclare individuellement, avec le DIČ (numéro de TVA) du partenaire, la
référence propre du document et sa date de fait générateur, dans une section A
(ventes) et une section B (achats) — un relevé document par document, avec
l'identité du tiers, et non une case qui somme une colonne. Aucune `box` de ce
format ne porte l'identité d'un tiers ni la référence d'un document : c'est
une forme plus proche d'un export SAF-T ou d'un FEC que d'un
`tax_report_box`. `packs/cz/` ne déclare donc pas ce formulaire, et
`docs/international.md`, section « From Czechia », consigne le manque pour le
socle plutôt que de forcer une approximation dans ce pack. Les sanctions du
défaut de dépôt (§ 101h, de 1 000 à 500 000 Kč) sont réelles : une entreprise
qui installe ce pack garde son obligation de le déposer par un autre moyen.

**Le souhrnné hlášení (§ 102) est, lui, exactement la forme que
`ec_sales_list()` sait déjà produire** — les livraisons intracommunautaires de
biens (`CZ-S-VOP`) et les prestations de services B2B intracommunautaires
(`CZ-S-SLUZBY-EU`) de ce pack portent chacune le `treatment` que la fonction
lit. Sa périodicité mensuelle, y compris pour un assujetti qui dépose sa
déclaration de TVA trimestriellement, est exactement le cas que
`company_filing_periods` (une ligne par entreprise et par formulaire) a été
construit pour couvrir ; aucun changement n'est demandé ici.

**L'arrondi en espèces** (zákon č. 634/1992 Sb., § 3 odst. 1 písm. c),
`defaults.cash_rounding_unit: 1`) est déclaré mais non lu : comme le dit
`docs/packs.md`, « le socle n'a aujourd'hui aucun chemin de paiement en
espèces sur lequel arrondir ». Ce pack transcrit la règle légale — arrondir
uniquement un paiement en espèces à la couronne entière la plus proche,
jamais un paiement sans espèces — sans qu'aucun code ne la lise encore.

**La facturation électronique reste volontaire.** `einvoicing.obligation` est
`none` : aucun texte n'impose l'échange d'une facture électronique
structurée entre entreprises tchèques à `released_at`, en B2B comme en B2G
général. Ce que la loi impose est plus étroit — zákon č. 134/2016 Sb., § 221
et § 279 odst. 5 písm. a) obligent, depuis le 1er avril 2019, les principaux
pouvoirs adjudicateurs à accepter une facture électronique conforme à EN
16931 pour un marché public, une obligation de réception pesant sur
l'acheteur public et non une obligation d'émission pesant sur l'entreprise.
Le format national ISDOC, dont le Ministerstvo vnitra détient la licence
depuis le 5 mai 2021, est recommandé aux côtés d'EN 16931 pour ces marchés
sans être imposé non plus. Le paquet ViDA de l'Union (adopté le 11 mars 2025)
prévoit une obligation pour les opérations intracommunautaires B2B à partir
du 1er juillet 2030, mais aucun projet de loi tchèque de transposition
n'existe à `released_at`.

## Avant que ce pack ne soit `reviewed`

1. **Les articles cités**, un par un, directement sur e-sbirka.gov.cz — ce
   pack a été écrit avec un outil qui ne pouvait pas rendre ce portail, contre
   des miroirs et des documents de la Finanční správa plutôt que le texte
   consolidé lui-même dans un navigateur.
2. **La structure fine du formulaire 25 5401** (řádky 4 à 9, 11 à 13, 23 à 26,
   30 à 34, 42, 44, 45, 47, 51 à 53, 60, 61, 66), reconstruite par recoupement
   plutôt que lue directement dans les « Pokyny k vyplnění » officiels.
3. **Le choix de la prestation exonérée réduite (12 %) et de l'exonération
   sans droit à déduction du golden** — l'hébergement et le bail immobilier
   sont des exemples ordinaires, mais aucun n'a été vérifié auprès d'un texte
   listant précisément les codes de la nomenclature couverts par l'annexe n° 2.
4. **Le plan comptable au-delà du groupe légal** — la construction à trois
   chiffres et plus est la convention la plus répandue, pas un texte, et un
   comptable tchèque en pratique est le mieux placé pour dire si elle se lit
   naturellement.
5. **Les cinq reverse charges nationaux non modélisés** (§ 92b, 92c, 92d,
   92f) et le krácený odpočet de l'article 76.
