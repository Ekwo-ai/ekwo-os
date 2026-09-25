# Tunisie

Tout ce que la Tunisie ajoute à Ekwo, en données : un plan comptable bâti sur
le squelette vérifié du système comptable des entreprises, les trois taux
positifs de la taxe sur la valeur ajoutée (19 %, 13 %, 7 %) avec l'exportation
à taux zéro et les exonérations du tableau « A », la déclaration mensuelle, et
un bilan et un état de résultat. Le format est
[`docs/packs.md`](../../docs/packs.md) ; ce fichier dit d'où vient le contenu
et sur quelles décisions il repose.

**Statut : `community`.** Personne qui dépose une déclaration tunisienne ne
l'a relu. Les chiffres sont rejoués sur une année de comptes par
`tests/golden.test.ts`, qui prouve que le pack est cohérent avec lui-même et
ne prouve rien de plus.

**Langue : français.** Le système comptable des entreprises n'a pas, à la
connaissance de cette recherche, de version officielle en arabe ou en anglais
distincte du texte français de la loi n° 96-112 et de ses normes ; ce pack
n'écrit donc que `defaults.language: "fr"` et ne déclare aucune langue
supplémentaire.

## Sources

Chaque taux, case et ligne d'état porte son propre `legal_reference`, et à
côté la clé du texte où cet article se lit. Le registre de `pack.json` tient
sept textes, consultés le 25 septembre 2026.

| Quoi | Texte | Où |
|---|---|---|
| Les taux | Code de la TVA, art. 7, dans la rédaction de la loi n° 2017-66 du 18 décembre 2017 (loi de finances pour 2018), art. 43 | `finances.gov.tn`, `jurisitetunisie.com` |
| Les exonérations | Tableau « A » annexé à l'article premier du Code de la TVA | `jurisitetunisie.com` |
| Le taux intermédiaire (13 %) et le taux réduit (7 %) | Tableaux « B bis » et « B » annexés au Code de la TVA | `jurisitetunisie.com` |
| Le fait générateur | Code de la TVA, art. 5 | `jurisitetunisie.com` |
| La déduction et ses exclusions | Code de la TVA, art. 9 et 10 | `jurisitetunisie.com` |
| La retenue à la source sur les non-résidents | Code de la TVA, art. 19 | `jurisitetunisie.com` |
| La déclaration mensuelle | Code de la TVA, art. 18 | `jurisitetunisie.com` |
| Le plan comptable | Loi n° 96-112 du 30 décembre 1996 et norme comptable générale NC 01 | `cmf.tn`, `oect.org.tn` |
| La facture électronique El Fatoora | Loi de finances pour 2016, art. 22, et décret n° 2016-1066 du 15 août 2016 | `ttn.tn` |

**Ce que cette recherche n'a pas pu ouvrir en texte exploitable.** Les PDF du
Journal officiel (Code de la TVA) et de la norme comptable générale NC 01,
consultés dans cette session, ne se laissent pas extraire en texte par les
outils utilisés ; leurs articles cités ici viennent de la retranscription de
JurisiteTunisie et de recherches ciblées, jamais d'une lecture directe du
PDF officiel page par page. Un professionnel tunisien devrait relire le texte
source avant tout usage réel — c'est le point le plus important à faire
relire de tout ce pack.

## Le plan comptable, et pourquoi celui-ci

Sept classes de comptes (1 capitaux propres et passifs non courants, 2 actifs
non courants, 3 stocks, 4 tiers, 5 comptes financiers, 6 charges, 7 produits)
et une douzaine de comptes précis — 101 (capital social, avec 1011/1012/1013/
1018), 11 (réserves), 12 (résultats reportés), 13 (résultat de l'exercice),
20/21/28 (immobilisations et leurs amortissements), 40 (fournisseurs), 41
(clients) et 436 (État, taxes sur le chiffre d'affaires, qui reçoit à la fois
la taxe collectée et la taxe à récupérer) — sont vérifiés contre plusieurs
sources indépendantes citées ci-dessus. **Au-delà de ce squelette vérifié, la
numérotation fine (les sous-comptes de 436, les comptes de charges et de
produits, par exemple) est la construction propre de ce pack**, dans le même
esprit que `packs/sa/` lorsqu'aucune nomenclature officielle exploitable n'a
pu être ouverte — à la différence près que la Tunisie a bien un plan comptable
officiel : c'est l'accès à son texte intégral en clair qui a manqué à cette
recherche, pas son existence. 116 comptes, tous imputables sauf les têtes de
regroupement.

## Les taxes

**Trois taux positifs : 19 %, 13 %, 7 %.** Relevés de 18 %, 12 % et 6 % par la
loi de finances pour 2018 (loi n° 2017-66 du 18 décembre 2017, art. 43), en
vigueur depuis le 1er janvier 2018. Le taux normal de 19 % s'applique à ce
qu'aucun tableau annexé ne classe autrement ; le tableau « B bis » (13 %)
couvre notamment les honoraires des architectes, ingénieurs-conseils, avocats,
notaires et experts, l'hôtellerie et le matériel informatique ; le tableau
« B » (7 %) couvre notamment les produits pharmaceutiques, les conserves de
tomate et de sardines et le savon ordinaire.

| | Code | Traitement |
|---|---|---|
| Vente 19 % | `TN-S-19` | domestic |
| Vente 13 % | `TN-S-13` | domestic |
| Vente 7 % | `TN-S-7` | domestic |
| Exportation | `TN-S-EXP` | export, taux zéro, droit à déduction maintenu (art. 9 et 15) |
| Opération exonérée (tableau « A ») | `TN-S-EXO` | exempt |
| Achat 19 %, 13 %, 7 %, déductible | `TN-P-19`, `TN-P-13`, `TN-P-7` | domestic |
| Achat 19 %, non déductible — voiture de tourisme | `TN-P-ND-19` | domestic, art. 10, 1° |
| Prestation d'un non-résident, retenue à la source | `TN-P-NR-19` | foreign_services_received, art. 19 |

**L'exportation n'est pas une exonération.** Le Code range les opérations
exonérées dans le tableau « A » et n'y met pas l'exportation : celle-ci reste
une opération taxable dont le taux est ramené à zéro et dont le droit à
déduction est maintenu (art. 9), avec restitution du crédit qui en provient
(art. 15). `treatment: export` et non `exempt`, en conséquence.

**`vat_category` reste vide sur toutes les taxes.** La Tunisie est hors du
système commun de TVA de l'Union (`supabase/seed/00_territories.sql`, ligne
`TN`) : la colonne BT-151 d'EN 16931 n'est exigée que si le pack déclare un
profil de facturation électronique fondé sur cette norme, ce qui n'est pas le
cas ici (voir plus bas). `exemption_code` reste vide pour la même raison :
l'article qui exonère va dans `legal_reference`.

## La déclaration mensuelle

**Un formulaire fondu dans un plus grand.** L'article 18-IV du Code de la TVA
impose une déclaration mensuelle unique, mais celle-ci porte aussi d'autres
impôts que ce pack ne modélise pas (retenues à la source sur salaires et
honoraires, taxe sur les établissements à caractère industriel, commercial ou
professionnel, FOPROLOS…). `tax_report.json` ne porte que le volet TVA, et ses
cases (`CA19`, `TVA19`…) sont la construction propre de ce pack : cette
recherche n'a pas pu ouvrir le modèle chiffré de l'imprimé officiel en texte
clair — c'est un écran du portail de télédéclaration de la DGI plutôt qu'un
texte publié.

**L'échéance dépend de la forme du déclarant.** Quinze premiers jours du mois
pour une personne physique, vingt-huit premiers jours pour une personne
morale (art. 18-IV) : `deadline.rule` est `depends_on_taxpayer`, faute d'un
jour unique que la loi donnerait à tout le monde.

**La retenue à la source de l'article 19** sur les prestations d'un
non-résident sans établissement en Tunisie est portée par `TN-P-NR-19` et
la case `TVANR`, qui nette à zéro dans la déclaration comme le fait le champ 9
saoudien : la taxe due est immédiatement déductible. Cette recherche n'a pas
pu vérifier si son reversement emprunte la déclaration mensuelle elle-même ou
un imprimé séparé — voir la note de `TN-P-NR-19` dans `taxes.json`.

## La facturation électronique, et ce qu'Ekwo n'y fait pas

**Le système « El Fatoora » existe depuis 2016** (loi de finances pour 2016,
art. 22, et décret n° 2016-1066 du 15 août 2016), et Tunisie TradeNet (TTN) en
est l'opérateur technique. À la date de ce pack, l'obligation ne couvre pas
toutes les entreprises : les opérations avec les marchés publics et les
grandes entreprises rattachées à la Direction des Grandes Entreprises sont
concernées, sans que cette recherche ait pu ouvrir un texte daté fixant le
périmètre exact et son calendrier d'extension. `pack.json` laisse donc
`einvoicing.obligation` vide plutôt que d'écrire `mandatory` pour tout le
pack.

**`profile`, `mandatory_from`, `party_scheme` et `vat_scheme` restent vides**
pour la raison que `packs/sa/`, `packs/mx/` et `packs/vn/` donnent pour leur
propre régime : El Fatoora est un système de contrôle à la transmission
(« clearance »), la facture est un XML au format TEIF transmis à TTN puis à
l'administration, et aucune brique de `packages/formats/` n'écrit ce XML, ne
le signe, ni ne dialogue avec TTN. Un document émis par Ekwo n'est donc pas
une facture électronique El Fatoora.

## Ce que ce pack ne porte pas

- **Les autres volets de la déclaration mensuelle** : retenues à la source sur
  salaires et honoraires, taxe sur les établissements à caractère industriel,
  commercial ou professionnel, FOPROLOS.
- **Le régime de l'encaissement des entreprises de travaux publics et de
  bâtiment travaillant pour l'État** (Code de la TVA, art. 5) : aucune taxe de
  ce pack ne porte `cash_basis`, faute d'avoir vérifié un compte de
  transition.
- **Les seuils et conditions du régime forfaitaire** (art. 16-17) : les
  contribuables de ce régime ne déposent pas la déclaration mensuelle et n'ont
  pas de compte dans ce pack.
- **La taxe de formation professionnelle, la taxe sur les établissements
  à caractère industriel, commercial ou professionnel et les autres impôts
  locaux** : hors du champ de la TVA que ce pack transcrit.
- **Le détail des sous-comptes au-delà du squelette vérifié** — voir « Le plan
  comptable » ci-dessus.
