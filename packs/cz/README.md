# Czechia

Everything Czechia adds to Ekwo, as data: a chart of accounts built on the
class-and-group structure the accounting decree prescribes, the journals, the
VAT rates and where each one posts, the boxes of the monthly VAT return, the
rozvaha and the výkaz zisku a ztráty of the accounting decree, and the
sentences the law puts on an invoice. The format is
[`docs/packs.md`](../../docs/packs.md); this file gives the sources and the
decisions, so that a Czech účetní or daňový poradce can disagree with a
specific sentence.

**Status: `community`.** Nobody has reviewed it against the law they apply.
The figures are replayed against three months of books by
`tests/golden.test.ts`, which proves the pack is coherent and proves nothing
about whether it is right.

**Language: `cs`.** The labels are in Czech, the language of every text in
the register below; no second language file is declared.

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

Les articles cités reposent sur des republications du texte officiel et sur
les informations et brochures de la Finanční správa et du Ministerstvo
financí ; le texte consolidé sur e-sbirka.gov.cz doit être vérifié.

## Le plan comptable, et pourquoi celui-ci

**La Tchéquie prescrit un plan comptable directeur, mais seulement jusqu'au
groupe.** La vyhláška č. 500/2002 Sb., příloha č. 4 (směrná účtová osnova)
fixe les účtové třídy (classe, un chiffre) et les účtové skupiny (groupe, deux
chiffres) — 21 groupes pour dix classes — et s'arrête là, sur le renvoi du
§ 4 odst. 8 de la loi comptable. Chaque entreprise construit ensuite son
propre účtový rozvrh, à trois chiffres et plus, à l'intérieur de ces groupes.

Au-delà des deux premiers chiffres, les comptes suivent la convention la plus
répandue de la pratique tchèque (311 odběratelé, 321 dodavatelé, 343 daň
z přidané hodnoty, 411 základní kapitál, 501 spotřeba materiálu…) : seuls les
deux premiers chiffres sont d'origine légale, ce que `pack.json` signale une
fois.

**Le compte 343 (Daň z přidané hodnoty) est éclaté en cinq comptes à quatre
chiffres** (3431 à 3439) : la TVA collectée par taux, la TVA déductible et les
deux comptes de règlement (`tax_payable` 3438, `tax_receivable` 3439) qu'un
`settle_filing()` doit pouvoir solder sans compenser silencieusement l'accrual
du mois suivant.

**Le résultat de l'exercice reste sur un compte unique (431, Výsledek
hospodaření ve schvalovacím řízení), profit ou perte.** `closing_style` est
`result_accounts` : le résultat attend l'assemblée qui l'affecte, et la
vyhláška ne prévoit qu'une seule ligne A.V. de la rozvaha pour les deux
signes, d'où `current_year_result_profit` et `current_year_result_loss` sur le
même compte 431.

## Les taxes

Douze codes : deux taux positifs (21 %, 12 %, en vigueur depuis le 1er janvier
2024 — zákon č. 349/2023 Sb. a fusionné les anciens taux réduits de 10 % et
15 %), trois opérations exonérées avec droit à déduction (livraison
intracommunautaire de biens, prestation de services intracommunautaire B2B,
export), une exonération sans droit à déduction (bail immobilier, § 56a), et
six codes côté achat dont quatre autoliquidés par l'acquéreur.

**L'autoliquidation, à l'achat, s'écrit en deux jambes sur les mêmes comptes
de TVA collectée et déductible que les opérations ordinaires.** Le montant
autoliquidé (řádek 3 pour une acquisition intracommunautaire, řádek 10 pour un
sous-traitant du bâtiment en régime national de l'article 92e) est
intégralement déductible : la jambe `tax` de facteur −100 crédite la TVA
collectée 3431 dans sa case, une seconde jambe, sans case, débite la TVA
déductible 3433 du même montant, comme le réclame l'article 73 odst. 1
písm. b) pour un bien ou un service affecté à une activité économique
imposable.

**Un service acheté à un prestataire étranger est autoliquidé par le
preneur, et le formulaire distingue l'origine du prestataire.** Un abonnement
logiciel, un hébergement ou une API facturé par un prestataire non établi en
République tchèque a son lieu au siège du preneur assujetti (§ 9 odst. 1), et
le preneur est redevable de la taxe (§ 108 odst. 1 písm. c)), qu'il déduit
dans la même déclaration (§ 73 odst. 1 písm. b)). `CZ-P-SLUZBY-EU`
(`intracom_acquisition_services`, article 196 de la directive 2006/112/CE)
porte le service d'un assujetti identifié dans un autre État membre au
řádek 5 ; `CZ-P-SLUZBY-3Z` (`foreign_services_received`) porte celui d'un
prestataire établi hors de l'Union au řádek 12, « ostatní zdanitelná plnění,
u kterých je povinnost přiznat daň při jejich přijetí ». Les deux s'écrivent
comme `CZ-P-VOP` : la jambe −100 crédite 3431 dans sa case, une seconde
jambe débite 3433, et le řádek 43 reporte la même taxe côté déduction. Le
plan ne porte pas de compte de fournisseurs étrangers, si bien qu'un
prestataire étranger reste sur le compte fournisseurs avec les autres.

Hors périmètre, chacun faute de modélisation :

- **les autres reverse charges nationaux** (§ 92b déchets et métaux usagés,
  § 92c émissions de gaz à effet de serre, § 92d téléphones et circuits
  intégrés, § 92f gaz et électricité) — seul le § 92e (construction et
  montage) est modélisé ; leur portée précise reste à vérifier ;
- **le krácený odpočet** (déduction proportionnelle de l'article 76) — les
  řádky 51 à 53 et 60 ne sont pas dans `tax_report.json`, chaque taxe d'achat
  est intégralement déductible ;
- **l'importation (řádky 7 et 8), le moyen de transport neuf (řádek 9), les
  corrections pour insolvabilité (řádky 33 et 34) et le remboursement de
  l'article 84 (řádek 61).**

## La déclaration

`CZ-DPH-PRIZNANI` transcrit une partie du tiskopis 25 5401 : les řádky 1 à 3,
10, 20 à 22, 40, 41, 43, 46, 50 et 62 à 65, avec les libellés du formulaire.
Le řádek 43 (« Zdanitelná plnění řádků 3-13 — základní sazba ») est un total
au sens du format : il reporte, côté déduction, la taxe déjà déclarée aux
řádky 3 et 10, jamais une seconde écriture.

**L'échéance** est le vingt-cinquième jour suivant la fin de la période
(§ 101 odst. 1), non prorogeable ; `period_default` propose le mois (article
99), l'option trimestrielle de l'article 99a restant ouverte sous condition de
chiffre d'affaires (15 000 000 Kč depuis le 1er janvier 2025).

## Ce que le socle ne sait pas faire

**Le kontrolní hlášení (§ 101c à § 101i) n'a aucune forme dans ce format.**
Au-delà de 10 000 Kč TTC, chaque document fiscal s'y déclare
individuellement (DIČ du partenaire, référence, date de fait générateur), en
section A (ventes) et B (achats) : un relevé document par document qu'aucune
`box` ne peut porter (voir
[`docs/international.md`](../../docs/international.md#what-the-packs-do-not-say-yet)).
Les sanctions du défaut de dépôt (§ 101h, de 1 000 à 500 000 Kč) sont
réelles : l'entreprise doit le déposer par un autre moyen.

**Le souhrnné hlášení (§ 102)** est produit par `ec_sales_list()` à partir de
`CZ-S-VOP` et `CZ-S-SLUZBY-EU` ; sa périodicité mensuelle, même pour un
déclarant TVA trimestriel, est couverte par `company_filing_periods`.

**L'arrondi en espèces** (zákon č. 634/1992 Sb., § 3 odst. 1 písm. c),
`defaults.cash_rounding_unit: 1`) — arrondir un paiement en espèces, jamais un
paiement sans espèces, à la couronne entière la plus proche — est déclaré mais
non lu : le socle n'a aucun chemin de paiement en espèces.

**La facturation électronique reste volontaire.** `einvoicing.obligation` est
`none` : aucun texte n'impose une facture électronique structurée entre
entreprises à `released_at`, en B2B comme en B2G général. Zákon č. 134/2016
Sb., § 221 et § 279 odst. 5 písm. a) obligent seulement, depuis le 1er avril
2019, les principaux pouvoirs adjudicateurs à accepter une facture conforme à
EN 16931 pour un marché public. Le format national ISDOC (licence du
Ministerstvo vnitra depuis le 5 mai 2021) y est recommandé sans être imposé.
Le paquet ViDA (adopté le 11 mars 2025) prévoit une obligation pour les
opérations intracommunautaires B2B à partir du 1er juillet 2030 ; aucun projet
de transposition tchèque n'existe à `released_at`.

## Avant que ce pack ne soit `reviewed`

1. **Les articles cités**, un par un, dans le texte consolidé sur
   e-sbirka.gov.cz.
2. **La structure fine du formulaire 25 5401** (řádky 4 à 9, 11 à 13, 23 à 26,
   30 à 34, 42, 44, 45, 47, 51 à 53, 60, 61, 66), à confronter aux « Pokyny k
   vyplnění » officiels.
3. **Le choix de la prestation exonérée réduite (12 %) et de l'exonération
   sans droit à déduction du golden** — l'hébergement et le bail immobilier,
   à vérifier contre un texte listant les codes de la nomenclature couverts
   par l'annexe n° 2.
4. **Le plan comptable au-delà du groupe légal** — une convention, pas un
   texte : un comptable tchèque dira si elle se lit naturellement.
5. **Les cinq reverse charges nationaux non modélisés** (§ 92b, 92c, 92d,
   92f) et le krácený odpočet de l'article 76.
