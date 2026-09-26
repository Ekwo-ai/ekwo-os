# Bosna i Hercegovina

Sve što Bosna i Hercegovina dodaje Ekwu jest podatak: kontni okvir Federacije
BiH (Pravilnik o kontnom okviru i sadržaju konta za privredna društva),
jedinstvena stopa poreza na dodanu vrijednost od 17 % (Zakon o porezu na
dodanu vrijednost), nulta stopa na izvoz, oslobođenja iz čl. 24 i 25,
mjesečna prijava PDV-a (Obrazac P PDV) i Bilans stanja s Bilansom uspjeha.
Format je opisan u [`docs/packs.md`](../../docs/packs.md); ovaj fajl kaže
odakle dolazi svaki red i na kojoj odluci počiva, tako da računovođa koji
poznaje Bosnu i Hercegovinu može osporiti pojedinačnu rečenicu, a ne cijeli
paket.

**Status: `community`.** Nijedan praktikujući računovođa ni revizor još nije
pregledao ovaj paket. Brojevi u `golden/` su repliciarani tačno alatom
`tests/golden.test.ts` za jednu godinu knjiga — to dokazuje unutrašnju
dosljednost paketa, a ne njegovu pravnu ispravnost.

**Paket je napisan na bosanskom** (`defaults.language: "bs"`), jer je svaki
tekst na koji se poziva — Zakon o porezu na dodanu vrijednost, oba pravilnika
Federalnog ministarstva finansija — na tom jeziku objavljen (u zajedničkom
"bosanski/hrvatski/srpski" izdanju Službenog glasnika BiH). `i18n/en.json` je
**radni prijevod ovog paketa** za čitaoca koji ne poznaje jezik, a ne
zvanična engleska verzija pravilnika o kontnom okviru ili obrazaca
finansijskih izvještaja — nijedan od njih takvu verziju nema; vidjeti
[`i18n/README.md`](i18n/README.md). Zakon o PDV-u jedini ima zvaničan
engleski prijevod koji objavljuje sama Uprava za indirektno oporezivanje
(UIO), naveden kao izvor `vat-law`.

## Izvori

Svaki porez, kutija, red izvještaja i klauzula na fakturi nosi vlastiti
`legal_reference` i ključ izvora iz kojeg je preuzet.
`pack.json.certification.sources` drži sedam tekstova, svi provjereni
26.09.2026:

| Šta | Tekst | Gdje |
|---|---|---|
| Predmet, stope, oslobođenja, prijava i plaćanje PDV-a | Zakon o porezu na dodanu vrijednost ("Službeni glasnik BiH", br. 9/05, 35/05, 100/08, 33/17 i 46/23), zvaničan engleski prijevod | uino.gov.ba |
| Prag za registraciju povećan na 100.000 KM | Zakon o izmjeni Zakona o PDV-u, "Službeni glasnik BiH", broj 80/23 | uino.gov.ba |
| Obrazac prijave PDV-a | Obrazac P PDV | uino.gov.ba |
| Elektronsko podnošenje prijave | e-Porezi / e-VAT | uino.gov.ba |
| Kontni okvir (na snazi) | Pravilnik o kontnom okviru i sadržaju konta za privredna društva, "Sl. novine FBiH" 81/21 | privrednastampa.ba |
| Kontni okvir (prethodnik, pun tekst pročitan) | Pravilnik o kontnom okviru..., "Sl. novine FBiH" 82/10, Prilog | finpol.gov.ba |
| Bilans stanja i Bilans uspjeha | Pravilnik o sadržaju i formi obrazaca finansijskih izvještaja, "Sl. novine FBiH" 82/10, Prilog 1 i 2 | finpol.gov.ba |

## Kontni okvir, i zašto baš ovi računi

**Ovaj paket transkribuje kontni okvir Federacije BiH**, jednog od dva
bosanskohercegovačka entiteta — Republika Srpska ima vlastiti, strukturno
sličan, ali zasebno propisan pravilnik koji ovaj paket ne transkribuje (vidi
"Čega ovaj paket nema" niže). `accounts.csv` sadrži 214 računa: sve grupe
konta (dvocifrene) i njihove najčešće trocifrene analitičke račune iz
Priloga važećeg Pravilnika ("Sl. novine FBiH" 81/21, na snazi od
01.01.2022.). Puni strojno čitljiv tekst tog Pravilnika ovo istraživanje nije
uspjelo pribaviti; sadržaj je transkribovan iz Priloga njegovog prethodnika
("Sl. novine FBiH" 82/10), čiji je puni tekst pročitan u cijelosti — sama
struktura klasa (0-9) i grupa (dvocifreni kodovi) potvrđena je nepromijenjenom
i u sekundarnim opisima Pravilnika 81/21. Provjera brojeva pojedinačnih
trocifrenih konta protiv službenog teksta 81/21 je jedna od tačaka koje bi
trebalo da provjeri bosanskohercegovački računovođa — vidjeti "Provjera ovog
paketa" niže.

**Dva dodatka izvan doslovnog Priloga, oba dozvoljena samim Pravilnikom**
(član 1, stav 3: "Trocifrena konta iz Kontnog okvira se, po potrebi,
rasčlanjuju na analitička konta u skladu s ovim pravilnikom i općim aktom
privrednog društva"):

- **`4699`** — pod službenim kontom `469` ("Ostale obaveze") ovaj paket
  dodaje prijelazni račun za iznose koji čekaju razjašnjenje
  (`defaults.roles.suspense`) — Pravilnik ne predviđa poseban "račun
  čekanja" poput francuskog ili belgijskog "compte d'attente"; ovo je
  odluka paketa, označena za provjeru računovođi.
- **`5599`** — pod službenim kontom `559` ("Ostali nematerijalni troškovi")
  ovaj paket dodaje račun za razlike od zaokruživanja
  (`defaults.roles.rounding`) — Pravilnik ne predviđa poseban račun za tu
  svrhu.

**Računi `279` i `479` — poravnanje prijave, odvojeno od knjiženja poreza.**
Naučeno na paketu SK: račun na koji "sjeda" iznos prijave ne smije biti isti
kao računi na koje se sami porezi knjiže. Ovaj kontni okvir već ima tačno
takav par konta, imenovan samim Pravilnikom:

- `270`/`271`/`272`/`273` — knjiženje ulaznog PDV-a po vrsti nabavke
  (fakture, uvoz, avansi, usluge stranih lica);
- `279` — "Potraživanja za razliku ulaznog poreza i obaveza za PDV",
  pozitivna razlika kada je ulazni porez veći — `tax_receivable`,
  `reconcilable`;
- `470`/`471`/`474` — knjiženje izlaznog PDV-a po vrsti isporuke;
- `479` — "Obaveze za razliku između obaveza za PDV i ulaznog poreza" —
  `tax_payable`, `reconcilable`.

**Lettrable (`reconcilable`) su samo računi kupaca, dobavljača i poravnanja
PDV-a.** Baza sadrži provjeru (`account_templates_third_party_reconcilable`)
koja zahtijeva da *svaki* račun tipa `asset_receivable` ili
`liability_payable` bude `reconcilable`, pa su svi računi grupa `21` (kupci)
i `43` (dobavljači) tako označeni — ne samo `211` i `432`, koji nose uloge
`receivable` i `payable`. Banka (`200`), blagajna (`206`) i prijelazni račun
(`4699`) nisu lettrable.

## Porezi

**Jedna pozitivna stopa.** Član 23 Zakona propisuje jedinstvenu stopu od
17 % na oporezivi promet dobara i usluga i na uvoz dobara — Bosna i
Hercegovina ne poznaje sniženu stopu PDV-a, za razliku od većine susjednih
zemalja Evropske unije.

| | Kod | Stopa | Kutija prijave |
|---|---|---|---|
| Standardna stopa (prodaja) | `BA-S-17` | 17 % | 11 (osnovica), 51 (porez) |
| Izvoz dobara (prodaja) | `BA-S-EXPORT` | 0 % | 12 |
| Oslobođeno — usluge obrazovanja, čl. 24(1)(4) (prodaja) | `BA-S-EXEMPT-EDU` | — | 13 |
| Standardna stopa (kupovina, odbitni ulazni porez) | `BA-P-17` | 17 % | 21 (osnovica), 41 (porez) |
| Uvoz dobara (kupovina) | `BA-P-IMPORT` | 17 % | 22 (osnovica), 42 (porez) |

**Prag za registraciju PDV-a povećan je s 50.000 na 100.000 KM od
02.12.2023.** (Zakon o izmjeni Zakona o PDV-u, "Sl. glasnik BiH" 80/23,
član 57, stav 1). Ovo je odluka koju svaka firma donosi jednom, prilikom
registracije, i format ne nosi polje za nju: `ekwo` ne bira porez umjesto
korisnika, a ovaj podatak je ovdje samo radi tačnosti prijave.

**Poza je izvan zajedničkog sistema PDV-a Europske unije, dakle bez VATEX
kodova.** Bosna i Hercegovina je kandidat za pristupanje (Odluka Europskog
vijeća od 15.12.2022.), a ne država članica; prema Direktivi 2006/112/EZ,
član 5(2), zajednički sistem PDV-a ne obuhvata kandidate (vidi novi red u
`supabase/seed/00_territories.sql`). `vat_category` i `exemption_code`
ostaju prazni na svakom porezu, a član zakona pod koji potpada oslobođenje
zapisan je u `legal_reference` — isti pristup kao paketi `tr` i `ua`.

**Poseban sistem za promet u vezi s izgradnjom nekretnina (čl. 40-43) nije
modelovan.** Zakon prenosi obavezu plaćanja PDV-a na primaoca isporuke za
građevinske radove čija ukupna vrijednost prelazi 25.000 KM — stvaran
mehanizam obrnutog terećenja unutar zemlje, koji ovaj prvi `community` paket
ne nosi — vidjeti "Čega ovaj paket nema" niže.

**Samostalni obračun PDV-a od strane primaoca usluga nerezidenta (čl. 13,
stav 1, tačka 3) nije modelovan** — isti obrazac propusta kao paket `ua` za
svoj član 208.

**Paušalna naknada za poljoprivrednike (čl. 45) nije modelovana.** Kutije 23
i 43 Obrasca P PDV su transkribovane, ali nijedan porez ovog paketa ne
postira u njih: godišnji iznos paušalne naknade određuje UIO svake godine, a
ovo istraživanje nije pronašlo važeću stopu.

## Deklaracija

`tax_report.json` transkribuje dio I (Isporuke i nabavke) i dio II
(Izlazni/Ulazni PDV) Obrasca P PDV, onoliko koliko ga porezi ovog paketa
dosežu. **Dio III (Podaci o krajnjoj potrošnji, polja 32-34) nije
transkribovan** — to su informativna polja koja raspoređuju promet fizičkim
licima koja nisu PDV obveznici po entitetima (FBiH/RS/Brčko distrikt), a
format Ekwa nema mehanizam za tu raspodjelu po entitetu kupca bez uvođenja
novog koncepta — vidjeti docs/international.md, odjeljak "From Bosnia and
Herzegovina". Polje 80 (zahtjev za povrat, štrikla na obrascu) također nije
transkribovano: to je oznaka namjere na obrascu, a ne iznos koji proračunava
knjiga.

**Jedan poreski period — kalendarski mjesec.** Član 38 Zakona ne poznaje
tromjesečnu ni drugu periodičnost; svaki obveznik prijavljuje mjesečno.

**Rok podnošenja — 10. u mjesecu.** Član 39, stav 2 Zakona daje rok do
10-og dana u mjesecu koji slijedi nakon isteka poreskog perioda za
podnošenje prijave Upravi za indirektno oporezivanje.

**Polje 71 nije ograničeno na nulu.** Član 52 Zakona daje pravo na povrat ili
zadržavanje poreskog kredita kada je ulazni porez veći od izlaznog; negativna
vrijednost polja 71 je upravo taj iznos.

## E-fakturisanje

**Nijedan od pročitanih izvora ne propisuje opću obavezu strukturirane
elektronske fakture (e-Faktura) niti državnu platformu za razmjenu ili
validaciju faktura između poslovnih subjekata.** Postoji isključivo
elektronsko podnošenje same prijave PDV-a (obavezno od januara 2019.) preko
portala e-Porezi/e-VAT. `einvoicing.profile` ostaje prazan jer nijedan profil
izgrađen na semantičkom modelu EN 16931 (Peppol BIS, Factur-X, XRechnung,
PINT) nije zakonski propisan niti poznat iz istraženih izvora.

## Bilans stanja i Bilans uspjeha

`statements.json` nosi strukturu i nazive pozicija Bilansa stanja i Bilansa
uspjeha (Prilog 1 i 2 Pravilnika o sadržaju i formi obrazaca finansijskih
izvještaja, "Sl. novine FBiH" 82/10, naslijeđenog istoimenim obrascem uz
Pravilnik 81/21 od 01.01.2022.), **ali ne i doslovne AOP oznake tog obrasca**
— transkripcija AOP oznaka reda po red iz rotirane skenirane tabele nije
mogla biti nezavisno provjerena znak po znak, pa ovaj paket koristi vlastite
kodove reda (`R00`, `R10`, `R11`, …) koji prate iste pozicije i isti
redoslijed kao službeni obrazac, ali ih nikako ne treba miješati sa
stvarnim AOP brojevima. Bilans uspjeha ovog paketa svodi svaki par pozicija
"dobit"/"gubitak" istog međuzbira na jedan red sa predznakom (pozitivna
vrijednost — dobit, negativna — gubitak) i ne uključuje porez na dobit, koji
je izvan opsega ovog istraživanja o PDV-u. Fact key (`xbrl`) ostaju prazni
svugdje.

## Na fakturi

**Poreska obaveza nastaje u trenutku koji nastupi najranije** od isporuke,
izdavanja fakture ili plaćanja prije fakture (član 17, stav 1) — tri
samostalna okidača, za razliku od Belgije ili Luksemburga gdje je datum
isporuke princip a datum fakture izuzetak. `earliest_of_delivery_or_payment`
je ovdje približna vrijednost: obuhvata isporuku i plaćanje, ali format nema
riječ za "najranije od tri", uključujući samostalno izdavanje fakture kao
treći okidač. Vidjeti docs/international.md, odjeljak "From Bosnia and
Herzegovina".

**`posted_edit_policy` — `reversal_only`.** Član 55, stav 6 Zakona predviđa
knjižno odobrenje (credit note) za povrat robe, naknadno sniženje cijene ili
naknadno dodatno plaćanje — ispravka se, dakle, uvijek vrši novim
dokumentom.

**Numerisanje `sequential`, bez propisanog oblika.** Zakon ne propisuje
jedinstven oblik broja fakture; `{CODE}-{NNNNNN}` je primjer, a ne jedina
zakonom nametnuta forma.

**Rok plaćanja između preduzeća nije modelovan.** Ovo istraživanje o PDV-u
nije obuhvatilo entitetske zakone o finansijskom poslovanju/rokovima
izmirenja novčanih obaveza; `documents.legal_payment_days` ostaje `null`.

## Čega ovaj paket nema

- **Kontni okvir Republike Srpske.** Ovaj paket transkribuje isključivo
  kontni okvir Federacije BiH; Republika Srpska ima vlastiti, zasebno
  propisan pravilnik koji ovo istraživanje nije obuhvatilo.
- **Poseban sistem za promet u vezi s izgradnjom nekretnina (čl. 40-43).**
- **Samostalni obračun PDV-a od strane primaoca usluga nerezidenta
  (čl. 13, stav 1, tačka 3).**
- **Paušalna naknada za poljoprivrednike (čl. 45).**
- **Porez na dobit** i njegov uticaj na Bilans uspjeha.
- **Rok plaćanja između preduzeća** u odsustvu ugovora.
- **Osnovna sredstva.** `assets.json` ne postoji; entitetske stope
  amortizacije su izvan opsega ovog istraživanja.
- **Bankarski formati.** Nijedan format izvoda bosanskohercegovačkih banaka
  nije potvrđen ovim istraživanjem; odjeljak `bank` u `pack.json` ne postoji.

## Provjera ovog paketa

Otvorite zadatak "Review: Bosnia and Herzegovina". Šta jeste i šta nije
provjera — u [`docs/packs.md`](../../docs/packs.md), odjeljak
"Certification, and who may say what". Tačke koje bi praktikujući
računovođa ili revizor trebao/la pročitati prvo, po redoslijedu od
najmanje sigurne:

1. **Trocifreni brojevi konta protiv službenog Priloga Pravilnika 81/21** —
   ovaj paket ih je transkribovao iz punog teksta prethodnika (82/10), čija
   je struktura klasa/grupa potvrđena nepromijenjenom, ali čije pojedinačne
   brojeve treba provjeriti protiv trenutno važećeg teksta.
2. **AOP oznake Bilansa stanja i Bilansa uspjeha** — ovaj paket nosi
   strukturu i nazive pozicija, ne doslovne AOP brojeve.
3. **Odsustvo kontnog okvira Republike Srpske.**
4. **Odsustvo posebnog sistema za izgradnju nekretnina i samostalnog
   obračuna na usluge nerezidenta.**
5. **`earliest_of_delivery_or_payment` kao aproksimacija člana 17, stav 1**
   — pravilo najranijeg od tri događaja nema tačnu riječ u ovom formatu.
