# Poland

Everything Poland adds to Ekwo, as data: a chart of accounts read from the
structure the accounting law prescribes, the journals, the VAT rates and
where each one posts, the boxes of the JPK_VAT z deklaracją, the bilans and
the rachunek zysków i strat of the ustawa o rachunkowości, and the sentences
the law puts on an invoice. The format is [`docs/packs.md`](../../docs/packs.md);
this file says where the content came from and which decisions it rests on,
so that a Polish accountant or doradca podatkowy reading the pack can
disagree with a specific sentence rather than with the whole of it.

**Status: `community`.** Nobody has reviewed it against the law they apply.
The figures are replayed against a year of books by `tests/golden.test.ts`,
which proves the pack is coherent and proves nothing about whether it is
right.

**Language: `pl`.** The pack's own labels are written in Polish, which is
also the language of every text in the register below; no second language
file is declared.

## Sources

Every rate, box, mention and statement line carries its own `legal_reference`
and names the entry of `certification.sources` its article is in. The
register holds fifteen texts.

| What | Text | Publisher |
|---|---|---|
| Rates, exemptions, reverse charge, split payment, invoice particulars, tax point | Ustawa z dnia 11 marca 2004 r. o podatku od towarów i usług (tekst jednolity Dz. U. 2025 poz. 775) | isap.sejm.gov.pl |
| Seuil de la franchise en base porté à 240 000 zł au 1er janvier 2026 | Ustawa z dnia 24 czerwca 2025 r. (Dz. U. 2025 poz. 896) | isap.sejm.gov.pl |
| Obligation de facturation structurée dans le KSeF | Ustawa z dnia 16 czerwca 2023 r. (Dz. U. 2023 poz. 1598), modifiée par la loi du 5 août 2025 (Dz. U. 2025 poz. 1203) | isap.sejm.gov.pl |
| Structure du JPK_VAT z deklaracją et de ses cases P_xx | Rozporządzenie du 15 octobre 2019 (Dz. U. 2019 poz. 1988, z późn. zm.) et sa brochure officielle, version (3), janvier 2026 | isap.sejm.gov.pl, podatki.gov.pl |
| Bilan et compte de résultat | Ustawa z dnia 29 września 1994 r. o rachunkowości, załącznik nr 1 (tekst jednolity Dz. U. 2026 poz. 522) | isap.sejm.gov.pl |
| Délai de paiement, intérêt de retard, indemnité de recouvrement | Ustawa z dnia 8 marca 2013 r. o przeciwdziałaniu nadmiernym opóźnieniom w transakcjach handlowych (tekst jednolity Dz. U. 2023 poz. 1790) | isap.sejm.gov.pl |
| Taux d'intérêt de retard en vigueur (second semestre 2026) | Obwieszczenie du 22 juin 2026 (M.P. 2026 poz. 642) | isap.sejm.gov.pl |
| Le KSeF lui-même : bases légales, calendrier, format FA(3) | Portails officiels du Krajowy System e-Faktur | ksef.podatki.gov.pl |
| Split payment (MPP) | Poradnik officiel du mécanisme | podatki.gov.pl |
| Codes de la facture électronique | EN 16931, UNCL5305, VATEX | European Commission (docs.peppol.eu) |

## Le plan comptable, et pourquoi celui-ci

**La Pologne ne prescrit aucun plan de comptes.** L'art. 10 ust. 1 pkt 3 lit.
a de l'ustawa o rachunkowości oblige chaque entité à documenter son propre
« zakładowy plan kont », et rien de plus. Le plan à neuf groupes (zespoły 0 à
9) que la pratique comptable polonaise enseigne largement est un usage
professionnel et non une obligation légale ; ce pack ne le reprend pas.

Ce qu'il fait à la place est suivre la structure de la loi elle-même : un
plan à quatre chiffres, écrit pour ce pack, dont le premier chiffre renvoie
directement à la lettre de la section du bilan ou du compte de résultat
(załącznik nr 1) : `1` Aktywa trwałe (A), `2` Aktywa obrotowe (B), `3` Należne
wpłaty et udziały własne (C, D), `4` Kapitał własny (A des pasywów), `5`
Rezerwy na zobowiązania (B.I), `6` Zobowiązania długoterminowe (B.II), `7`
Zobowiązania krótkoterminowe et rozliczenia międzyokresowe bierne (B.III,
B.IV), `8` et `9` les postes du rachunek zysków i strat en wariant
porównawczy. Chaque compte reçoit ainsi, par construction, le poste légal
auquel le rattache le libellé de son nom.

**Le compte de résultat est en wariant porównawczy** (par nature de charge),
l'un des deux variantes que l'annexe autorise ; le choix appartient à
l'entité et le wariant kalkulacyjny (par fonction) n'est pas modélisé ici.

**Les postes détaillés par nature de contrepartie** (jednostki powiązane,
jednostki w których jednostka posiada zaangażowanie w kapitale) que
l'annexe 1 prévoit pour les créances et les dettes ne sont pas repris comme
comptes séparés : ce pack retient un seul compte par nature de poste, celui
d'une société sans lien de participation avec ses clients ou fournisseurs,
qui est le cas courant d'une PME. Un groupe qui a besoin de la ventilation
complète ajoute les comptes et les lignes de statement correspondantes.

L'amortissement est porté directement en réduction de la valeur brute de
l'immobilisation (pas de compte d'amortissement cumulé distinct), à l'image
de la pratique déjà retenue par d'autres packs de ce dépôt pour un pays sans
plan de comptes prescrit.

## Les taxes

Dix-huit codes. Le taux normal est de 23 % et le taux réduit principal de
8 % depuis le 1er janvier 2011 — **mais ce ne sont pas les taux nominaux de
l'art. 41** (22 % et 7 %) : l'art. 146ef les porte à 23 % et 8 % tant que les
dépenses de défense dépassent 3 % du PIB, une période ouverte depuis le
1er janvier 2024 et prorogée chaque année par obwieszczenie du ministre. Le
taux de 5 % (art. 41 ust. 2a, załącznik nr 10) n'est pas concerné par cette
surcharge.

Le taux zéro couvre l'export (`PL-S-EXPORT`) et la livraison
intracommunautaire (`PL-S-WDT`) ; une prestation de services à un assujetti
d'un autre État membre sous la règle générale B2B (`PL-S-USLUGI-UE`) n'est
pas une opération taxée à 0 % mais une opération hors du champ territorial
polonais, déclarée en P_11/P_12. Une exonération domestique est illustrée par
la location d'un local à usage d'habitation (`PL-S-ZW-NAJEM`, art. 43 ust. 1
pkt 36).

Côté achat, sept codes couvrent les mécanismes d'autoliquidation que compte
la loi polonaise aujourd'hui : l'acquisition intracommunautaire de biens
(WNT), l'import de services d'un prestataire établi dans l'Union (art. 28b)
et d'un prestataire qui ne l'est pas, l'import de biens sous la procédure
simplifiée de l'art. 33a, et la livraison domestique par un fournisseur sans
établissement en Pologne (art. 17 ust. 1 pkt 5). Chacun poste sa base une
seule fois, répétée dans la case de la taxe due et dans le panier de
déduction (`P_42`), suivant exactement le mécanisme que
[`docs/packs.md`](../../docs/packs.md) décrit pour l'acquisition
intracommunautaire estonienne. `PL-P-23-POJAZD` illustre la déduction
partielle à 50 % de l'art. 86a sur les frais de véhicule à usage mixte, sur
le modèle de la taxe belge sur les véhicules déjà écrite dans le format.
L'ancienne autoliquidation domestique généralisée (biens de l'annexe 11) a
été abrogée et remplacée par le split payment obligatoire ; elle n'est donc
pas reprise ici.

## La déclaration

`PL-JPK-V7` transcrit la partie « Deklaracja — Pozycje szczegółowe » du
JPK_VAT z deklaracją, dans sa version (3) en vigueur depuis les périodes de
février 2026 — d'où `valid_from: 2026-02-01`, et pourquoi le scénario golden
commence en février plutôt qu'en janvier. Chaque case P_xx porte le libellé
exact de la brochure officielle du ministère des Finances. `P_38` et `P_51`
sont les deux cases obligatoires que la brochure signale explicitement
(valeur « 0 » à défaut). L'échéance est le 25 du mois suivant la période
(art. 99 ust. 1 pour la déclaration, art. 103 ust. 1 pour le paiement) ;
`period_default` propose le mois, qui est la règle générale — le trimestre
(art. 99 ust. 2-3) reste une option pour le petit contribuable ayant opté
pour la méthode de caisse ou dont le chiffre d'affaires ne dépasse pas
l'équivalent de 2 000 000 EUR, une qualité que le pack ne devine pas.

## Ce que le socle ne sait pas faire

**Le KSeF est une clearance en temps réel, pas un échange décentralisé.**
Une faktura ustrukturyzowana est réputée émise au moment de son envoi au
Krajowy System e-Faktur (art. 106na ust. 1) et reçue seulement lorsque **le
système lui-même** lui attribue un numéro KSeF (art. 106na ust. 3) — un
numéro que le vendeur ne choisit pas et qui n'existe qu'après validation par
l'administration. `einvoicing.profile` du format suppose un échange entre
pairs conforme au modèle sémantique EN 16931 (Peppol, Factur-X, XRechnung,
un PINT) ; il ne prévoit ni ce mécanisme de clearance, ni la numérotation
attribuée par le système plutôt que par l'émetteur, ni les quatre modes
dégradés de la loi (awaria, awaria totale, offline24, indisponibilité) qui
changent le marqueur porté dans le JPK. `packs/pl/pack.json` documente ce
choix dans le `legal_reference` du bloc `einvoicing`, et ce README le
consigne aussi ici : le socle n'offre aujourd'hui aucun champ pour porter un
numéro attribué par l'administration plutôt que par l'émetteur.

**Le split payment (MPP) est une règle de paiement, pas une règle de
facturation.** L'obligation (art. 108a ust. 1a) se déclenche par la
combinaison d'un total TTC supérieur à 15 000 zł **et** de la présence d'au
moins un bien ou service du załącznik nr 15 (150 postes classés par PKWiU) —
une condition qu'aucune valeur du vocabulaire fermé `applies_when` des
mentions légales ne peut exprimer (`always`, `reverse_charge`,
`intra_eu_goods`, `intra_eu_services`, `export`, `exempt`, `late_payment`,
`cash_basis`, `small_business`). Ce pack ne patche pas le socle avec une
valeur inventée : la mention obligatoire « mécanisme podzielonej płatności »
n'est donc pas générée automatiquement. Le compte `2321` (rachunek VAT) est
néanmoins prévu dans le plan de comptes pour qu'une entité puisse y tracer
manuellement les paiements soumis au mécanisme.

**La correction pour créances impayées (ulga na złe długi, art. 89a/89b)
n'est pas modélisée.** C'est une correction statutaire déclenchée par
l'écoulement de 90 jours après l'échéance de paiement, indépendante de toute
décision du vendeur, et réversible si la créance est finalement payée — ce
n'est ni une note de crédit ni un document que le socle connaît. Les cases
`P_46`, `P_47`, `P_68` et `P_69` sont déclarées dans `tax_report.json` et
jamais postées.

**Le report d'un solde d'une déclaration à l'autre n'est pas modélisé.**
`P_39` (excédent déductible reporté de la période précédente) et `P_62`
(excédent à reporter sur la période suivante) sont des cases à somme
formelle dans le formulaire, mais leur valeur dépend de la déclaration
précédente et du choix du contribuable quant au sort de l'excédent
(remboursement total, partiel, ou report) — un choix que `P_53`, `P_54` et
`P_60` expriment et que ce pack, comme `P_39`/`P_62`, laisse à zéro plutôt
que de le deviner.

**Non modélisés, faute d'un cas dans le scénario ou d'une portée
raisonnable pour un pack `community` :** la méthode de caisse du petit
contribuable (art. 21, mention « metoda kasowa ») ; le régime de la marge
(agences de voyage art. 119, biens d'occasion art. 120) ; l'or
d'investissement (art. 122) ; la transaction triangulaire simplifiée
(art. 136) ; le rabais de l'art. 108d pour paiement anticipé depuis le
rachunek VAT ; le spis z natury de cessation d'activité (art. 14 ust. 5) ; le
crédit sur achat de caisses enregistreuses (art. 111 ust. 6) ; la consigne
sur emballages de boissons (P_360, art. 17b) ; la déclaration récapitulative
VAT-UE (`ec_sales_list()` existe dans le socle mais n'est pas câblée à ce
pack) ; l'impôt sur les sociétés (CIT), hors du périmètre de ce pack qui ne
couvre que la TVA et la comptabilité.

## Avant que ce pack soit `reviewed`

Un relecteur devrait d'abord regarder :

1. **Le plan de comptes.** S'il est réellement utilisable par un comptable
   polonais qui pense plutôt en zespoły, et quels comptes manquent à une
   petite société.
2. **La liste des taux et des exonérations.** Dix-huit codes ne couvrent
   qu'un sous-ensemble des załączniki 3, 10 et 15 et de l'art. 43 ust. 1 (qui
   compte plus de quarante points) ; c'est le premier endroit où le pack
   devra grandir.
3. **Le rachat de la période de janvier 2026.** Le formulaire JPK_V7(3) ne
   vaut qu'à compter de février 2026 ; une entreprise qui clôture un exercice
   à cheval sur cette date file la version (2) puis la version (3), ce que ce
   pack, à une seule version du formulaire, ne représente pas encore.
4. **`PL-P-23-POJAZD`.** La déduction à 50 % est la règle par défaut ; un
   véhicule dont le registre de kilométrage prouve un usage exclusivement
   professionnel (art. 86a ust. 3-4) donne droit à 100 %, un cas que ce pack
   ne code pas séparément.
5. **`legal_payment_days` laissé vide.** Voir `documents.references.payment_terms`
   dans `pack.json` : la loi polonaise plafonne à 60 jours le délai que les
   parties peuvent convenir entre elles, ce qui n'est pas le même fait qu'un
   délai supplétif en l'absence d'accord.
