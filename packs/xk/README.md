# Kosova

Çka shton Kosova te Ekwo është e dhënë: normat e Tatimit mbi Vlerën e Shtuar
prej 18 %/8 %/0 %, lirimet e tij, deklarata mujore e TVSH-së siç e përcakton
Ligji Nr. 05/L-037, dhe një plan kontabël i frymëzuar nga IFRS bashkë me
Pasqyrën e Pozicionit Financiar dhe Pasqyrën e të Ardhurave Gjithëpërfshirëse
sipas IFRS for SMEs. Formati përshkruhet në
[`docs/packs.md`](../../docs/packs.md); ky skedar thotë prej nga është marrë
çdo rresht dhe mbi çfarë vendimi qëndron, në mënyrë që një kontabilist që e
njeh Kosovën të mund ta kundërshtojë një fjali, jo tërë paketën.

**Statusi: `community`.** Asnjë kontabilist apo auditor i licencuar ende nuk
e ka shqyrtuar këtë paketë. Shifrat riprodhohen nga testi
`tests/golden.test.ts` mbi bazën e një viti librash — kjo vërteton
konsistencën e brendshme të paketës, jo saktësinë e saj ligjore.

**Paketa është shkruar në shqip** (`defaults.language: "sq"`), gjuha zyrtare
në të cilën botohet çdo tekst mbi të cilin mbështetet — Ligji Nr. 05/L-037
për TVSH-në dhe Ligji Nr. 06/L-032 për Kontabilitet botohen zyrtarisht në
shqip dhe serbisht (dhe, për këto dy ligje të veçanta, edhe në një version
anglisht të Gazetës Zyrtare, që është përdorur këtu për kërkim paralelisht me
tekstin shqip). `i18n/en.json` është **përkthimi i punës i paketës** për
lexuesin që nuk njeh shqip, jo version zyrtar anglisht i ndonjë prej këtyre
teksteve — asnjëri prej tyre nuk ka një version të tillë përveç vetë Gazetës
Zyrtare; shih [`i18n/README.md`](i18n/README.md).

## Burimet

Çdo tatim, kuti, rregull dokumenti dhe rresht tabele mban `legal_reference`-n
dhe çelësin e vet të burimit prej nga është marrë ajo dispozitë.
`pack.json.certification.sources` mban gjashtë tekste, të gjitha të
verifikuara më 26.09.2026:

| Çka | Teksti | Ku |
|---|---|---|
| Objekti, normat, lirimet, personi i obliguar, deklarata dhe pagesa e TVSH-së | Ligji Nr. 05/L-037 për TVSH-në | atk-ks.org (Gazeta Zyrtare Nr. 23/2015) |
| Zbatimi i Ligjit për TVSH | Udhëzimi Administrativ MF-Nr. 03/2015 | gzk.rks-gov.net |
| Specimeni i fundit publik i formularit të deklarimit të TVSH-së | Formulari TV-E-3 (rishikuar 20.02.2008) | atk-ks.org |
| Dorëzimi elektronik i deklaratave | Platforma EDI | edi.atk-ks.org |
| Kontabiliteti, raportimi financiar dhe auditimi | Ligji Nr. 06/L-032 | cps.rks-gov.net (Gazeta Zyrtare Nr. 3/2018) |
| Standardi i raportimit për ndërmarrjet e vogla dhe të mesme | IFRS for SMEs | ifrs.org |

## Plani kontabël, dhe pse pikërisht këto llogari

**Kosova nuk ka një plan kontabël të miratuar me ligj apo me akt të Këshillit
Kosovar për Raportim Financiar (KKRF), ndryshe nga Serbia (Pravilnik
89/2020) apo Bosnja-Hercegovina fqinje.** Ligji Nr. 06/L-032 për Kontabilitet,
Raportim Financiar dhe Auditim, neni 7 dhe neni 8, përcakton se cilin standard
raportimi (IFRS-të e plota, ose IFRS for SMEs) duhet ta zbatojë një subjekt
sipas madhësisë (neni 5), dhe i jep KKRF-së kompetencën për t'i miratuar këto
standarde dhe për të rregulluar raportimin e mikro-ndërmarrjeve (neni 9) — por
asnjëri prej këtyre teksteve nuk përcakton kode zyrtare llogarish. Kërkimi për
këtë paketë nuk gjeti ndonjë plan kontabël të publikuar nga KKRF me kode
specifike. Ky paket ofron prandaj **planin e vet**, të organizuar sipas
terminologjisë ndërkombëtare të IFRS (klasa 0 aktive afatgjata, 1 aktive
afatshkurtra, 2 detyrime, 3 kapital, 4 të hyra, 5 kosto direkte, 6–7
shpenzime, 9 llogari jashtë bilancit), jo një plan të miratuar me ligj — i
njëjti vendim si te paketa e Gjeorgjisë (`packs/ge`), për të njëjtën arsye.

**Llogaritë e TVSH-së ndahen mes llogarive të postimit dhe llogarisë së
shlyerjes**, sipas mësimit të nxjerrë nga paketa e Sllovakisë: `1458`
(tepricë e arkëtueshme) dhe `2108` (detyrim për pagesë) janë llogaritë e
`defaults.roles.tax_receivable`/`tax_payable`, të vetmet lettrueshme
(`reconcilable`) të TVSH-së, të ndara nga llogaritë ku vetë normat postohen
(`1450`/`1452`/`1454`/`1456` në anën e blerjeve, `2100`/`2102`/`2104` në anën
e shitjeve).

## Tatimi mbi Vlerën e Shtuar

**Dy norma pozitive, një nen.** Neni 26, paragrafi 1 i Ligjit Nr. 05/L-037
përcakton normën standarde prej 18 % që nga 1 shtatori 2015 (data e hyrjes në
fuqi të ligjit); paragrafi 2 i të njëjtit nen përcakton normën e reduktuar
prej 8 % për trembëdhjetë kategori të renditura taksativisht (ujë përveç atij
të ambalazhuar, energji elektrike dhe ngrohje qendrore, drithëra dhe
prodhime buke, vajra gatimi, qumësht, kripë, vezë, libra shkollorë dhe
botime, pajisje të teknologjisë së informacionit, barna, pajisje mjekësore
dhe për personat me aftësi të kufizuara).

| | Kodi | Norma | Kuti e deklaratës |
|---|---|---|---|
| Norma standarde (shitje) | `XK-S-18` | 18 % | 03/03T |
| Norma e reduktuar (shitje) | `XK-S-8` | 8 % | 04/04T |
| Eksport mallrash, i liruar me të drejtë zbritjeje | `XK-S-EXPORT` | 0 % | 02 |
| Shërbime arsimore, të liruara pa të drejtë zbritjeje | `XK-S-EXEMPT-EDU` | e liruar | 01 |
| Norma standarde (blerje), e zbritshme | `XK-P-18` | 18 % | 09/09T |
| Norma e reduktuar (blerje), e zbritshme | `XK-P-8` | 8 % | 10/10T |
| Blerje pa TVSH — furnitori kryen veprimtari të liruar | `XK-P-EXEMPT` | — | 07 |
| Import mallrash, TVSH e paguar në doganë, e zbritshme | `XK-P-IMPORT` | 18 % | 08/08T |
| Shërbim i pranuar nga furnizues jorezident — vetëngarkim | `XK-P-RC-FOREIGN` | 18 % | 05/05T, 11/11T |

**Jashtë sistemit të përbashkët të TVSH-së të Bashkimit Evropian.** Kosova
nuk është shtet anëtar i Bashkimit Evropian; sipas Direktivës 2006/112/KE,
neni 5, paragrafi 2, sistemi i përbashkët i TVSH-së nuk shtrihet jashtë
territorit të Komunitetit (shih rreshtin e ri në
`supabase/seed/00_territories.sql`). `exemption_code` mbetet prandaj bosh te
çdo tatim i kësaj paketa; neni i ligjit nën të cilin bie lirimi është
shkruar te `legal_reference`, ashtu siç kanë bërë paketat `rs`, `ba` dhe `tr`.

**E drejta e zbritjes ndahet qartë mes lirimeve.** Neni 36, paragrafi 3,
nën-paragrafi 3.2 e ruan të drejtën e zbritjes për transaksionet e liruara
sipas Kapitujve X, XI dhe XII (eksporti, transporti ndërkombëtar, dhe
transaksionet e trajtuara si eksporte) — prandaj `XK-S-EXPORT` mban
`recoverable: true`. Kapitulli VIII (lirimet me interes publik, ku bën pjesë
arsimi) dhe Kapitulli IX (lirimet e tjera, ku bën pjesë sigurimi) titullohen
shprehimisht „Lirimet pa të drejtën e zbritjes” dhe nuk përfshihen në atë
listë — prandaj `XK-S-EXEMPT-EDU` dhe `XK-P-EXEMPT` nuk mbajnë të drejtë
zbritjeje.

**Vetëngarkimi mbi shërbimet e jorezidentëve (neni 52.1.2) është modeluar në
të dyja anët e njëkohshme, në kuti të veçanta nga furnizimi i zakonshëm
vendas.** Ndryshe nga POPDV/PPPDV serbe, ku baza e vetëngarkimit ndahet
detyrimisht me kutinë e shitjes/blerjes së zakonshme me normën standarde,
kutitë e këtij paketi janë organizimi i vet paketit (shih „Deklarata e
TVSH-së” më poshtë), kështu që vetëngarkimi merr kutitë e veta (05/05T në
daljen, 11/11T në hyrjen) pa u përzier me shitjet apo blerjet e vërteta të
normës 18 %.

**Autoliquidacioni i punës ndërtimore (neni 52.1.4.1) NUK është modeluar.**
Ndryshe nga dispozita përkatëse serbe (neni 10 i ligjit serb, e vendosur
drejtpërdrejt në ligj) dhe ajo boshnjake, dispozita kosovare është **e
kushtëzuar**: neni 52, paragrafi 1, nën-paragrafi 1.4 thotë „Ministri i
Financave **mund** të nxjerr akt nënligjor” që ta bëjë pranuesin person të
obliguar për punën ndërtimore, mbeturinat, dhe disa raste të tjera. Ky
kërkim nuk gjeti dhe nuk verifikoi një akt të tillë nënligjor në fuqi; sipas
rregullit „asnjëherë mos shpik një rregull tatimor”, kjo paketë nuk mban
asnjë tatim nën këtë trajtim. Nëse një akt i tillë ekziston, kjo është pika
e parë për t'u verifikuar nga një kontabilist vendor — shih „Çka nuk mbulon
kjo paketë” më poshtë.

## Deklarata e TVSH-së

**Periudha tatimore është gjithmonë muaji kalendarik, pa përjashtim sipas
qarkullimit** (neni 53, paragrafi 1) — ndryshe nga Serbia fqinje, ku
periudha varet nga qarkullimi i tatimpaguesit. `tax_report.json` deklaron
prandaj `"period": ["month"]` dhe `period_default: "month"`.

**Afati për dorëzim dhe pagesë është data 20 e muajit që pason** (neni 54,
paragrafi 1), për çdo periudhë.

**Kutitë e `tax_report.json` janë organizimi i vet paketit i përmbajtjes që
neni 54, paragrafi 1 e bën të detyrueshme** (shuma e furnizimeve të
tatueshme dhe të liruara, e eksporteve; shuma e blerjeve dhe importeve;
shuma e blerjeve me TVSH të vetëngarkuar; shuma neto për pagesë ose
tepricë) — **jo transkriptim i numrave zyrtarë të ekranit të sistemit
elektronik EDI**. Specimeni i fundit publik i një formulari letre (TV-E-3,
rishikuar 20.02.2008) i paraprin reformës së dy normave pozitive (18 %/8 %,
2015) dhe vetë sistemit EDI, dhe struktura e tij (rreshti 9 „Exempt
Supplies”, rreshti 11 „Exports … 0% Rated Supplies”, rreshti 12 „Taxable
Supplies at Normal Rate” me një normë të vetme prej 15 %) nuk përputhet më
me ligjin në fuqi. Kjo paketë e ndërton skemën e kutive nga vetë neni 54 dhe
nga struktura e librit të shitjeve/blerjeve që ATK-ja ende e referon
(kolonat për vlerë të liruar, të eksportuar dhe të tatueshme), por **nuk e
ka verifikuar numërimin ekzakt të fushave siç shfaqen sot në EDI** — kjo
është pika e dytë për verifikim nga një kontabilist vendor.

**Nuk ekziston teprica e bartur nga periudha paraprake si kuti më vete**,
njësoj si te paketa serbe: kutia „13” (shuma neto) llogaritet vetëm nga
obligimi dhe zbritja e periudhës korrente, jo nga një gjendje kredie e
bartur — motori i Ekwo-s nuk mban gjendje ndër-periudhash si kuti e
deklaratës.

## Faturimi

**Numërimi `sequential`, pa detyrim ligjor për varg pa boshllëqe.** Neni 45,
paragrafi 1, nën-paragrafi 1.2 kërkon vetëm „një numër rendor që mundëson
identifikimin e faturës”, jo shprehimisht varg pa boshllëqe;
`{CODE}-{YYYY}-{NNNN}` këtu është një shembull renditjeje, jo forma e vetme
e lejuar.

**Momenti i ngarkueshmërisë: parimi është dorëzimi, me dy përjashtime, njëri
prej të cilëve fjalori ynë e mban.** Neni 22, paragrafi 1 — parimi është
dorëzimi i mallit/shërbimit. Paragrafi 3, nën-paragrafi 3.2 — kur fatura
lëshohet para dorëzimit, TVSH-ja bëhet e ngarkueshme në lëshim të faturës
(kjo është `invoice_if_issued`). Nën-paragrafi 3.1 i të njëjtit paragraf —
kur pagesa bëhet para dorëzimit, TVSH-ja bëhet e ngarkueshme në pagesë; ky
është një **përjashtim i tretë** që fjalori `invoice_if_issued` nuk e mban
veçmas (ai mban vetëm çiftin parim/faturë). Ky paket zgjedh
`invoice_if_issued` si vlerën më të afërt të ligjit dhe e dokumenton
boshllëkun këtu — të njëjtën zgjidhje ka bërë paketa e Bosnjë-Hercegovinës
(`packs/ba`) për një strukturë analoge neni-nga-neni.

**`posted_edit_policy: reversal_only`.** Neni 2, paragrafët 1.33–1.34 —
korrigjimi i shumës pas lëshimit të faturës bëhet me notë krediti ose notë
debiti, kurrë duke fshirë faturën origjinale.

## Faturimi elektronik dhe Pajisja Elektronike Fiskale — ajo që socle-ja nuk e mban

**Nuk u gjet asnjë ligj apo akt nënligjor që të detyrojë shkëmbimin e
faturave elektronike të strukturuara mes subjekteve private në Kosovë**, as
një platformë shtetërore vërtetimi (clearance) si SEF-i serb apo
e-Faktura shqiptare. Neni 44, paragrafi 1 i Ligjit për TVSH lejon që fatura
t'i dërgohet blerësit me mjete elektronike, me kusht që blerësi të pajtohet
dhe autenticiteti/integriteti të garantohen — kjo është leje, jo detyrim mbi
një profil të ndërtuar mbi modelin semantik të EN 16931 (Peppol BIS,
Factur-X, XRechnung, PINT). `pack.json.einvoicing.profile` mbetet prandaj
bosh dhe `obligation: "none"`.

**Në vend të kësaj, ligji parasheh Pajisjen Elektronike Fiskale (PEF)** —
arka fiskale të licencuara nga Ministria e Financave (neni 2, paragrafi
1.17) — për regjistrimin dhe lëshimin e kuponëve fiskal të shitjeve me
pakicë, veçanërisht ndaj konsumatorit fundor. Ky është mekanizëm tjetër (kupon
arke, jo faturë e strukturuar e shkëmbyer ndërmjet palëve) që asnjë format i
`packages/formats/` nuk e mban sot. Shih docs/international.md, seksioni
«From Kosovo».

## Pasqyrat financiare

`statements.json` mban Pasqyrën e Pozicionit Financiar dhe Pasqyrën e të
Ardhurave Gjithëpërfshirëse sipas zërave minimalë të seksioneve 4 dhe 5 të
IFRS for SMEs (Ligji Nr. 06/L-032, neni 8, për organizatat e vogla dhe të
mesme; neni 7, IFRS-të e plota, për organizatat e mëdha). Rregullat janë
diapazone të kodeve të llogarive të vetë këtij paketi (si te `packs/ge`), jo
kode të një formulari zyrtar — sepse asnjë formular i tillë nuk ekziston me
rreshta të miratuara me ligj.

**Rregjimi i mikro-ndërmarrjeve (neni 5, paragrafi 2: bilanc ≤ 350.000 €,
qarkullim ≤ 700.000 €, ≤ 10 punonjës) nuk është modeluar veçmas.** Neni 9 ia
lë KKRF-së rregullimin e raportimit të tyre me akt nënligjor; ky kërkim nuk
gjeti një akt të tillë të publikuar me zëra pasqyre specifikë për
mikro-ndërmarrjet. Shumica e shoqërive tregtare të vogla e të mesme, që
zbatojnë IFRS for SMEs sipas nenit 8, mbeten të mbuluara nga skema aktuale.

## Çka nuk mbulon kjo paketë

- **Autoliquidacioni i punës ndërtimore** (neni 52.1.4.1) — kushtëzuar nga
  një akt nënligjor i pa verifikuar; shih „Tatimi mbi Vlerën e Shtuar” më
  lart.
- **Numërimi ekzakt i kutive të ekranit aktual EDI** — kutitë e kësaj
  pakete janë organizimi i vet paketit i përmbajtjes së nenit 54; shih
  „Deklarata e TVSH-së” më lart.
- **Rregjimi i mikro-ndërmarrjeve** i KKRF-së (neni 9) — asnjë akt i
  publikuar nuk u gjet me zëra pasqyre specifikë.
- **Pajisja Elektronike Fiskale (PEF)** dhe kuponi fiskal i shitjeve me
  pakicë — shih „Faturimi elektronik” më lart.
- **Aktive themelore.** `assets.json` nuk ekziston; normat e amortizimit
  për qëllime tatimore dhe kontabël janë jashtë këtij kërkimi.
- **Formatet bankare.** Asnjë format i deklaratave bankare kosovare nuk
  është verifikuar nga ky kërkim; seksioni `bank` te `pack.json` nuk
  ekziston.
- **Pragu i regjistrimit për TVSH** — vendim regjistrimi që socle-ja nuk e
  modelon (asnjë paket nuk zgjedh statusin tatimor të shoqërisë).

## Shqyrtimi i kësaj pakete

Hapni detyrën «Review: Kosovo». Çka është dhe çka nuk është shqyrtim — te
[`docs/packs.md`](../../docs/packs.md), seksioni „Certification, and who may
say what”. Pikat që një kontabilist i licencuar duhet t'i lexojë të parat,
nga më pak i sigurti:

1. **A ekziston akti nënligjor që e aktivizon autoliquidacionin e punës
   ndërtimore** (neni 52.1.4.1) — kjo paketë nuk mban asnjë tatim nën këtë
   trajtim, duke supozuar se nuk ekziston.
2. **Numërimi i kutive të ekranit aktual EDI**, krahasuar me organizimin e
   vet paketit të bazuar mbi nenin 54.
3. **Llogaria e pritjes `2300`** dhe llogaritë e nën-ndara të TVSH-së —
   shtesa jashtë çdo teksti zyrtar, sepse asnjë plan kontabël zyrtar nuk
   ekziston për t'u krahasuar.
4. **Mungesa e rregjimit të mikro-ndërmarrjeve** dhe e aktiveve themelore.
