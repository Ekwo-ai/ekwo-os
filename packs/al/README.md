# Shqipëria (Albania)

Çdo gjë që Shqipëria shton në Ekwo është e dhënë: llogaritë e planit kontabël,
shkallët e tatimit mbi vlerën e shtuar (20%, 6%, 0%), furnizimet e
përjashtuara, deklarata e TVSH-së në përmbajtjen që kërkon Ligji Nr. 92/2014
dhe Bilanci me Pasqyrën e të ardhurave dhe shpenzimeve sipas Standardit
Kombëtar të Kontabilitetit Nr. 2 (SKK 2). Formati përshkruhet në
[`docs/packs.md`](../../docs/packs.md); ky skedar thotë nga vjen çdo rresht
dhe mbi çfarë vendimi qëndron.

**Statusi: `community`.** Asnjë kontabilist apo auditor i praktikuar ende nuk
e ka lexuar këtë paketim. Shifrat e riprodhuara nga `tests/golden.test.ts`
mbi një vit librash provojnë koherencën e brendshme të paketimit, jo
saktësinë e tij ligjore.

**Paketimi është shkruar në shqip** (`defaults.language: "sq"`), sepse çdo
tekst mbi të cilin mbështetet — Ligji Nr. 92/2014, Ligji Nr. 25/2018,
SKK 2 — është zyrtarisht në gjuhën shqipe. `i18n/en.json` është një
**përkthim pune i vetë paketimit**, jo versioni zyrtar anglisht i ndonjërit
prej këtyre teksteve: asnjëri prej tyre nuk ka një version të tillë. Shih
[`i18n/README.md`](i18n/README.md).

## Burimet

Çdo tatim, kuti (box), pikë e nenit dhe rresht tabele mban `legal_reference`
dhe çelësin e burimit nga i cili është marrë (`pack.json.certification.sources`):

| Çfarë | Teksti | Ku |
|---|---|---|
| Objekti, shkallët, përjashtimet, deklarimi dhe pagesa e TVSH-së | Ligji Nr. 92/2014, datë 24.7.2014 | tatime.gov.al |
| Shkallët aktuale (20%, 6%, 10%, 0%) dhe listat e furnizimeve përkatëse | Buletini Fiskal 2024, Ministria e Financave | financa.gov.al |
| Kufiri minimal i regjistrimit për TVSH (10 000 000 lekë) | VKM Nr. 576, datë 22.7.2020 | qbz.gov.al |
| Detyrimi i kontabilitetit dhe i pasqyrave financiare | Ligji Nr. 25/2018, datë 10.5.2018 | kkk.gov.al (botuar) |
| Formati i bilancit dhe i pasqyrës së të ardhurave e shpenzimeve | SKK 2, Këshilli Kombëtar i Kontabilitetit | kkk.gov.al |
| Fiskalizimi (faturimi elektronik i detyrueshëm) | Ligji Nr. 87/2019, datë 18.12.2019 | tatime.gov.al |
| Kategoritë e Librit të Shitjes dhe Librit të Blerjes që ushqejnë deklaratën | Njoftim i Drejtorisë së Përgjithshme të Tatimeve | tatime.gov.al |
| Paraqitja e deklaratës | e-Filing | efiling.tatime.gov.al |

## Plani kontabël, dhe pse pikërisht këto llogari

**Asnjë tekst zyrtar shqiptar nuk boton një plan kontabël me kode numerike
fikse.** Ligji Nr. 25/2018 detyron mbajtjen e kontabilitetit sipas SKK-ve, por
SKK-të përcaktojnë njohjen, matjen dhe paraqitjen e zërave — jo numërtimin e
llogarive. `accounts.csv` transkripton numërtimin kontinental me shtatë klasa
(1 kapitalet, 2 aktivet afatgjata, 3 inventari, 4 të tretët, 5 thesari,
6 shpenzimet, 7 të ardhurat) që praktika kontabël shqiptare e përdor prej
reformës së 1993-shit dhe që literatura e IEKA-s e mëson ende sot. **Kjo është
një konvencion i këtij paketimi, jo një detyrim ligjor i numrave të saktë**;
rishikuesi duhet ta konfirmojë kundrejt praktikës që njeh vetë.

**Nën-llogaritë e TVSH-së (`4423`-`4456`) janë shpikje e këtij paketimi mbi
llogarinë zyrtare `442`:** llogaria mbi të cilën "ulet" shuma e deklaratës
(`4423` për t'u paguar, `4424` për t'u rimbursuar) nuk mund të jetë e njëjta
llogari mbi të cilën postohen vetë tatimet (`4426` TVSH e zbritshme, `4427`
TVSH e mbledhur, `4456` TVSH e importit, `44281`/`44282` vetëngarkimi).

**Vetëm klientët (`411`), furnitorët (`401`) dhe llogaritë e règullimit të
TVSH-së (`4423`, `4424`) janë `reconcilable`.** As banka, as arka, as llogaria
e pritjes (`473`) nuk janë.

## Tatimet

**Tre shkallë, asnjë kod VATEX.** Ligji Nr. 92/2014, neni 48, cakton shkallën
standarde 20%; neni 49, pika 3 (shtuar me Ligjin Nr. 71/2017), dhe Buletini
Fiskal 2024 (pika II.1.1) japin shkallën e reduktuar 6%; neni 57 jep shkallën
zero për eksportet.

| | Kodi | Shkalla | Trajtimi |
|---|---|---|---|
| Standarde (shitje) | `AL-S-20` | 20% | domestic |
| Akomodim (shitje) | `AL-S-6-ACCOM` | 6% | domestic |
| Libra (shitje) | `AL-S-6-BOOKS` | 6% | domestic |
| Eksport mallrash (shitje) | `AL-S-EXPORT` | 0% | export |
| Shërbime financiare/sigurimi (shitje) | `AL-S-EXEMPT-FIN` | — | exempt |
| Qira pasurie e paluajtshme (shitje) | `AL-S-EXEMPT-RENT` | — | exempt |
| Standarde (blerje, brenda vendit) | `AL-P-20` | 20% | domestic |
| Import mallrash (blerje) | `AL-P-IMPORT-20` | 20% | import |
| Vetëngarkim shërbimesh nga jashtë (blerje) | `AL-P-REVCHG-20` | 20% | foreign_services_received |

Shqipëria është **jashtë sistemit të përbashkët të TVSH-së** të Bashkimit
Evropian (Direktiva 2006/112/KE, neni 5(2)); `supabase/seed/00_territories.sql`
mban një rresht për `AL` me `eu_vat_scope = 'none'`. `vat_category` dhe
`exemption_code` mbeten bosh në çdo tatim — asnjë profil e-faturimi mbi
EN 16931 nuk deklarohet — dhe asnjë nga trajtimet `intracom_*` nuk zbatohet.

**Shkalla e reduktuar e librave ka një datë të pasigurt.** Neni 53, shkronja
«j», i tekstit origjinal të vitit 2014 e trajtonte furnizimin e librave si të
**përjashtuar**; Buletini Fiskal 2024 e vendos sot te shkalla e reduktuar 6%.
Ligji ndryshues dhe data e hyrjes në fuqi nuk janë identifikuar;
`AL-S-6-BOOKS.valid_from` (2021-01-01) është një supozim i arsyeshëm dhe
duhet verifikuar përpara se t'i besohet një periudhe të hershme.

**Shkalla e reduktuar 10% për inputet bujqësore nuk është modeluar.** Buletini
Fiskal 2024, pika II.1.1, konfirmon një shkallë 10% për plehrat kimike,
pesticidet, farat dhe fidanët (përveç hormoneve të kodit 2937 NKM); asnjë
dokument i `golden/` nuk e kërkon.

**Kategoria e deklarimit tremujor për tatimpagues me qarkullim 2-5 milionë
lekë nuk është modeluar.** Një dokument administrativ i DPT-së e lidh me
pragun e vjetër të regjistrimit (2 milionë lekë, para VKM 576/2020); pragu
aktual (10 milionë lekë) e ka lënë pa objekt shumicën e rasteve, por nëse
kategoria mbetet ende në fuqi duhet verifikuar. `tax_report.json.period` mban
vetëm `month`.

**Vetëngarkimi i TVSH-së mbi shërbimet nga jashtë (`AL-P-REVCHG-20`) përdor
dy postime tatimi mbi dy nën-llogari të veçanta (`44281`/`44282`),** sipas
nenit 86, pika 2.

## Deklarata

`tax_report.json` transkripton **përmbajtjen** që kërkon Ligji Nr. 92/2014
(neni 106) — vlerën e tatueshme dhe TVSH-në sipas shkallës, shitjet e
përjashtuara, eksportet, blerjet e zbritshme brenda vendit e në import,
vetëngarkimin, dhe totalet e TVSH-së për t'u paguar/për t'u bartur — dhe jo
numra kutish të një ekrani. Kutitë mbështeten te kategoritë me emra të Librit
të Shitjes dhe Librit të Blerjes (burimi «deklarata-tvsh-librat»), të cilat
Formulari i Deklarimit dhe Pagesës (FDP) i mbledh; vetë ekrani FDP duhet
krahasuar.

**Një periudhë e vetme raportimi — muaji kalendarik**, dhe një afat i vetëm —
14 ditë pas mbylljes së periudhës (neni 107, pika 1 dhe 2; neni 89 e lidh
pagesën me të njëjtën datë).

**Teprica e TVSH-së mbartet, rimbursimi kërkohet veçmas.** Neni 76, pikat 2-3,
e mban tepricën e zbritshme si kredi për periudhën pasardhëse; neni 77 e lejon
rimbursimin vetëm pas 3 muajsh radhazi me tepricë dhe kur shuma tejkalon
400 000 lekë (me kushte të veçanta për eksportuesit dhe disa financime të
huaja). `TVSH-PER-BARTJE` mban vetëm mekanizmin e mbartjes; procedura e
rimbursimit nuk është një kuti e formularit dhe nuk modelohet.

## Fiskalizimi — çfarë rrënja (socle) nuk di të bëjë

Ligji Nr. 87/2019 detyron çdo tatimpagues të lëshojë fatura elektronike, të
transmetuara në kohë reale te Platforma Qendrore e Faturave (CIS) e DPT-së,
e cila u kthen një Numër Identifikues i Vlefshmërisë së Faturës (NIVF) —
një model *clearance*, jo i ndërtuar mbi modelin semantik EN 16931. Zbatimi u
bë me faza (2021-01-01 B2G, 2021-07-01 B2B, 2021-09-01 çdo transaksion me
para në dorë). Asnjë komponent i `packages/formats/` nuk e shkruan, nënshkruan
apo transmeton këtë skemë sot — shih
[`docs/international.md`](../../docs/international.md#what-the-packs-do-not-say-yet).

## Nota e kreditit dhe nota e debitit — kujdes te emërtimi i kundërt

Neni 95, shkronja «c», i Ligjit Nr. 92/2014 i jep vetë ligji shqiptar një
kuptim **të kundërt** të asaj që një lexues i Belgjikës apo i Francës do të
priste: «nota e kreditit» (i) **RRIT** detyrimin e TVSH-së, dhe «nota e
debitit» (ii) e **ZBRET**. Dokumenti `credit_note` i Ekwo-s (që zvogëlon një
shitje të postuar) korrespondon pra me «notën e debitit» të nenit 95(c)(ii),
jo me «notën e kreditit» të tij. Kjo nuk ndryshon asgjë në postimet e
`taxes.json`, por meriton vëmendjen e parë të çdo kontabilisti.

## Bilanci dhe pasqyra e të ardhurave e shpenzimeve

`statements.json` mban Formatin 1 të Shtojcës 2 të SKK 2 (pasqyra sipas
natyrës së shpenzimit), sepse përputhet drejtpërdrejt me klasat 6 dhe 7 të
planit kontabël pa ndarë koston sipas funksionit. Aktivet afatgjata materiale
paraqiten **neto** (vlerë kontabël minus amortizimi i akumuluar) në një rresht
të vetëm, në vend të kolonave të veçanta «kosto» / «amortizim» që SKK 2 i lë
në shënimet shpjeguese. Zërat e pasqyrave të konsoliduara nuk transkriptohen.
`xbrl` mbetet bosh kudo: ekzistenca e një taksonomie XBRL shqiptare për këto
forma nuk është verifikuar.

## Në faturë

**Numërimi `sequential`, pa lidhje me vitin, është shembull dhe jo forma e
vetme e lejuar.** Neni 99 kërkon vetëm që fatura të lëshohet në momentin e
furnizimit; asnjë nen i ligjit nuk detyron një format të caktuar numrash.

**Momenti i kërkueshmërisë ndjek furnizimin, me faturën e lëshuar më parë si
përjashtim** (neni 32, neni 33 pikat 3-4). `documents.tax_point` mban
`invoice_if_issued`.

**`posted_edit_policy` — `reversal_only`,** mbi bazën e nenit 95(c): një
korrigjim bëhet me një dokument që i referohet shprehimisht faturës
fillestare, jo duke fshirë apo ndryshuar atë.

**Afati ligjor i pagesës mes ndërmarrjeve nuk është konfirmuar**;
`documents.legal_payment_days` mbetet `null`.

## Çfarë nuk mban ky paketim

- **Fiskalizimi (CIS, NIVF, certifikata elektronike e AKSHI-t)** — model
  *clearance* jo-EN16931; shih «Fiskalizimi» më sipër.
- **Shkalla e reduktuar 10% për inputet bujqësore** — asnjë skenar i
  `golden/` nuk e provon.
- **Kategoria e deklarimit tremujor për qarkullim 2-5 milionë lekë**, nëse
  ende ekziston pas rritjes së pragut të regjistrimit në 2020.
- **Skema e kompensimit të fermerëve (neni 55 e mëposhtme, norma 20%)** dhe
  regjimi i biznesit të vogël (nenet 117-119) — asnjë kontakt i `golden/` nuk
  i kërkon.
- **Rimbursimi i TVSH-së** (neni 77) si procedurë — vetëm mbartja e tepricës
  (neni 76) është një kuti e formularit.
- **Aktivet afatgjata** — `fixed_assets.json` mungon.
- **Formatet bankare** — seksioni `bank` mungon në `pack.json`.

## Rishikimi i këtij paketimi

Hapni një çështje «Review: Albania». Çfarë është dhe çfarë nuk është një
rishikim — te [`docs/packs.md`](../../docs/packs.md), seksioni «Certification,
and who may say what». Pikat për t'u lexuar të parat, nga më e pasigurta:

1. **Data e saktë dhe ligji ndryshues i shkallës 6% për librat** — sot është
   një supozim, jo një citim i verifikuar drejtpërdrejt.
2. **Numërtimi i planit kontabël** (klasat 1-7) — konvencion i këtij
   paketimi, jo tekst ligjor me kode fikse.
3. **Nota e kreditit/notës e debitit e kundërt** (neni 95(c)) — mos e lexo si
   gabim, është vetë ligji.
4. **Mungesa e shkallës 10% dhe e kategorisë tremujore** të vogël — gjenden
   nga burime dytësore, jo nga vetë teksti i ligjit të konsoliduar.
5. **Vetëngarkimi me dy nën-llogari (`44281`/`44282`)** dhe formalitetet e
   nenit 75(ç) që ky paketim nuk i modelon.
6. **Thjeshtimi i bilancit dhe i pasqyrës së rezultatit** (paraqitje neto,
   pa ndarjen kosto/amortizim) — a mjafton për një paraqitje konkrete.
