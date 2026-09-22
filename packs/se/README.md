# Sverige

Allt Sverige lägger till i Ekwo, som data: en kontoplan, journalerna,
momssatserna och var var och en av dem bokförs, rutorna i momsdeklarationen,
och de meningar lagen kräver på en faktura. Formatet är
[`docs/packs.md`](../../docs/packs.md); den här filen säger varifrån
innehållet kommer och vilka beslut det vilar på, så att en svensk redovisningskonsult
eller revisor som läser paketet kan invända mot en enskild mening i stället för
mot alltihop.

**Status: `community`.** Ingen har läst det mot lagen i sin yrkesroll.
Siffrorna spelas upp mot ett kvartals bokföring av `tests/golden.test.ts`, vilket
visar att paketet hänger ihop och visar ingenting om huruvida det är rätt.

Paketets egna texter är skrivna på svenska (`defaults.language: "sv"`), utan
någon engelsk översättning ännu (`languages: []`). Referenskontoplanen har
inga engelska namn i BAS eller något annat regelverk att luta sig mot: svenska
är det enda officiella språket för svensk bokföring och beskattning, så
engelska etiketter vore Ekwos egen översättning och inte en källas.

## Källor

Varje sats, ruta, mening och kontonummer bär sin egen `legal_reference` och
namnger vilken post i `certification.sources` artikeln finns i. Registret
håller fjorton texter, alla öppnade den dag som står bredvid dem:

| Vad | Text | Utgivare |
|---|---|---|
| Skattesatser, undantag, omvänd skattskyldighet, fakturans innehåll, beskattningsgrundande händelse, avdragsrätt | Mervärdesskattelag (2023:200) | riksdagen.se |
| Rutorna i momsdeklarationen, block A till H | SKV 409 (broschyr) | skatteverket.se |
| Momssatser och undantag, fakturering, deklarationsperioder | Skatteverkets vägledningssidor | skatteverket.se |
| Dröjsmålsränta | Räntelag (1975:635) | riksdagen.se |
| Förseningsersättning 450 kronor | Lag (1981:739) om ersättning för inkassokostnader m.m. | riksdagen.se |
| Verifikationers oföränderlighet | Bokföringslag (1999:1078) | riksdagen.se |
| Balansräkningens uppställningsform, Årets resultat som egen post | Årsredovisningslag (1995:1554) | riksdagen.se |
| E-fakturering vid offentlig upphandling | Lag (2018:1277) | riksdagen.se |
| Peppol-ID, EAS-koder | Upphandlingsmyndigheten / DIGG | upphandlingsmyndigheten.se |
| EN 16931, UNCL5305, VATEX, EAS | European Commission / OpenPEPPOL | docs.peppol.eu |

## Kontoplanen, och varför den ser ut så här

**Sverige föreskriver ingen kontoplan i lag.** Bokföringslagen kräver att
bokföringen är systematisk (5 kap. 1 §) men namnger inga kontonummer. Det
vidast spridda referensverket i svensk praxis är BAS-kontoplanen, utgiven av
Bas-intressenternas Förening, vars fullständiga kontolista och kontonummer
inte publiceras under en öppen licens. Precis som det tyska paketet inte
återger DATEVs SKR, återger detta paket inte BAS-kontoplanens kontolista.

Vad den gör i stället är att följa den kontoklassindelning som är svensk
allmän praxis och som beskrivs i lärobok efter lärobok, utan att vara någons
upphovsrättsligt skyddade verk:

| Första siffran | Är |
|---|---|
| `1` | Tillgångar |
| `2` | Eget kapital och skulder |
| `3` | Rörelsens intäkter |
| `4` | Material och varor (kostnad sålda varor) |
| `5`–`6` | Övriga externa kostnader |
| `7` | Personalkostnader och avskrivningar |
| `8` | Finansiella och andra inkomster och utgifter |

166 konton, platt struktur utan rubrikkonton: varje konto är postningsbart och
når exakt en rad i den generiska ramen `packs/generic/` via sin
`account_type`, eftersom detta paket inte deklarerar någon egen
`statements.json` (se nedan).

**Skattekontot, inte två konton.** Skatteförfarandelagen (2011:1244) samlar
ett företags alla skatter och avgifter — moms, arbetsgivaravgifter,
inkomstskatt — på ett enda skattekonto som kan vara antingen en fordran eller
en skuld. Därför namnger paketet bara `tax_payable` (konto 1630,
Skattekontot) och inget särskilt `tax_receivable`: ett tillgodohavande på
skattekontot är i sak en fordran på Skatteverket, men det är samma konto som
när det är en skuld.

## Momssatserna

Tre satser: 25 procent (9 kap. 2 § ML, normalregel), 12 procent (9 kap. 3–7 §§,
här illustrerad med restaurang- och cateringtjänster) och 6 procent (9 kap.
8–19 §§, här illustrerad med böcker och tidningar). **Livsmedel är inte
kodifierat i detta paket.** Livsmedel beskattas normalt med 12 procent men
tillfälligt med 6 procent från den 1 april 2026 till den 31 december 2027
(Prop. 2025/26:55) — en tidsbegränsad regeländring med ett `valid_from` och
`valid_to` som denna körning inte har verifierat tillräckligt noga för att
kodifiera; en granskare bör lägga till `SE-S-12-LIVSMEDEL` (giltig till och
med 2026-03-31) och `SE-S-06-LIVSMEDEL` (giltig från och med 2026-04-01) efter
att ha läst propositionen och dess ikraftträdandebestämmelser.

Nollskattesats för export (10 kap. 64 §) och för unionsintern varuförsäljning
(10 kap. 42–48 §§, kategori `K`) samt ett undantag för finansieringstjänster
(10 kap. 33 §, kategori `E`) är kodifierade och ingår i golden-scenariot.

## Omvänd skattskyldighet

Två inhemska fall, båda sidor: byggsektorn (16 kap. 13 §) och avfall och
skrot av vissa metaller (16 kap. 14 §), kategori `AE`. Tre unionsinterna och
utomeuropeiska fall på köparsidan: förvärv av varor (ruta 20), tjänster
enligt huvudregeln från ett annat EU-land (ruta 21) och från ett land
utanför EU (ruta 22), samt import (ruta 50, sedan en momsregistrerad
importör själv redovisar importmomsen i deklarationen i stället för hos
Tullverket).

## Momsdeklarationen

`SE-MOMS` är blankett SKV 4700, ruta för ruta, läst ur broschyren SKV 409.
Rutorna 06, 07, 08 (uttag, vinstmarginalbeskattning, frivillig uthyrning), 23
och 37–38 (trepartshandel), 40 (övriga tjänster utanför Sverige) samt 61 och
62 (import till 12 och 6 procent) är deklarerade för att blanketten ska vara
komplett men bär ingen skattekod i detta paket — se avsnittet om luckor nedan.

**Ingen `deadline` är deklarerad**, och det är ett medvetet val, inte en
glömska: se avsnittet "From Sweden" i
[`docs/international.md`](../../docs/international.md) för varför formatets
tre regler för `deadline` inte kan uttrycka den svenska förfallodagen.

**Ingen `period_default` är deklarerad** av samma skäl som `deadline`: vilken
period ett företag redovisar på beror på dess egen omsättning och val, inte
på en regel lagen ger alla.

## Luckor — inte kodifierat i detta paket

Inget av detta är ett fel i formatet; det är arbete som återstår.

- **Den tillfälliga sänkningen av momsen på livsmedel** (se ovan under
  "Momssatserna").
- **Vinstmarginalbeskattning** (9 kap. 20 kap. — begagnade varor, konstverk,
  samlarföremål, resetjänster; ruta 07).
- **Förenklad trepartshandel** (ruta 37 och 38).
- **Momsbefrielse för verksamheter med liten omsättning** (18 kap. ML,
  gränsen 120 000 kronor) — paragrafen är inte verifierad tillräckligt noga
  för att kodifieras här.
- **Frivillig skattskyldighet för uthyrning av verksamhetslokal** (ruta 08).

## Innan detta paket blir `reviewed`

En granskare bör titta på detta först:

1. **Livsmedelssatsen**, som ovan — den mest brådskande luckan, eftersom
   6 procent för livsmedel redan gäller vid publiceringsdagen.
2. **Kontoplanens täckning** för ett mindre aktiebolag: om 166 konton räcker,
   eller om branschspecifika konton (till exempel lager i en butik,
   pågående arbete i ett byggföretag) saknas.
3. **`SE-P-DRC-25` och `SE-S-DRC`** — om avfall och skrot av vissa metaller
   (16 kap. 14 §) förtjänar en egen kod skild från byggsektorn (16 kap. 13 §),
   eftersom de har olika materiell omfattning även om båda ger kategori `AE`.
4. **`numbering: gapless_per_year`** — om Skatteverkets läsning av 17 kap.
   24 § verkligen kräver en obruten nummerserie, eller om `sequential`
   (ett unikt nummer, inte nödvändigtvis obrutet) är en riktigare läsning.
5. **E-fakturering.** `obligation: "none"` är den korrekta läsningen för
   fakturering mellan näringsidkare; lag (2018:1277) gäller bara fakturor som
   utfärdas till följd av en offentlig upphandling, vilket detta paket inte
   modellerar som en egen väg.
