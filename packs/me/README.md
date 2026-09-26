# Crna Gora

Sve što Crna Gora dodaje Ekwo-u jesu podaci: konta Kontnog okvira za
privredna društva i druga pravna lica, stope poreza na dodatu vrijednost
21%/15%/7%/0%, oslobođenja od plaćanja PDV, mjesečna prijava PDV (Obrazac PR
PDV-2) sa sadržajem koji propisuju Zakon o porezu na dodatu vrijednost i
Uprava prihoda i carina, i Iskaz o finansijskoj poziciji sa Iskazom o
ukupnom rezultatu po obrascima usklađenim sa Zakonom o računovodstvu i
Direktivom 2013/34/EU. Format je opisan u
[`docs/packs.md`](../../docs/packs.md); ovaj fajl kaže odakle dolazi svaki
red i na kojoj odluci on stoji, tako da računovođa koji poznaje Crnu Goru
može osporiti pojedinačnu rečenicu, a ne cio paket.

**Status: `community`.** Nijedan praktikujući računovođa ili revizor još nije
pregledao ovaj paket. Brojevi koje reprodukuje `tests/golden.test.ts` za jednu
godinu knjiga dokazuju unutrašnju usklađenost paketa, a ne njegovu pravnu
tačnost.

**Paket je napisan na crnogorskom jeziku** (`defaults.language: "sr"` — vidjeti
napomenu ispod), jer je svaki tekst na koji se poziva — Zakon o porezu na
dodatu vrijednost, Pravilnik o kontnom okviru, Zakon o računovodstvu, Obrazac
PR PDV-2 — već zvanično na tom jeziku. `i18n/en.json` je **radni prevod**
ovog paketa za čitaoca koji ne poznaje crnogorski, a ne zvanična engleska
verzija bilo kog od ovih tekstova; vidjeti [`i18n/README.md`](i18n/README.md).

**Napomena o jezičkom kôdu.** Registar jezika ovog izdanja Ekwo OS-a
(`packs/schema/pack.1.json`, `$defs/language`) još ne nosi poseban ISO 639
kôd za crnogorski jezik kao takav; ovaj paket koristi `sr` (srpski), kôd
najbliži po pisanoj formi (crnogorska ijekavica, latinica), umjesto da
izmišlja kôd koji format ne priznaje. Ovo je ograničenje socle-a, ne izbor
ovog paketa; vidjeti docs/international.md, odjeljak «From Montenegro».

## Izvori

Svaki porez, red prijave, član zakona i red finansijskog iskaza nosi svoj
`legal_reference` i ključ izvora iz kog je taj tekst uzet.
`pack.json.certification.sources` nosi osam tekstova, svi provjereni
26.09.2026: prečišćeni tekst Zakona o porezu na dodatu vrijednost objavljen
na sajtu Uprave prihoda i carina, koji uključuje izmjenu iz "Sl. list CG", br.
094/24 od 30.09.2024 (u primjeni od 01.01.2025, kojom je uvedena treća stopa
od 15%); Obrazac PR PDV-2 sa uputstvom; portal ePorezi za podnošenje prijava;
Zakon o računovodstvu ("Sl. list CG", br. 052/16); Pravilnik o kontnom
okviru; primjer popunjenog Iskaza o finansijskoj poziciji i Iskaza o
ukupnom rezultatu koji pokazuje sve redne brojeve (AOP) oba obrasca; Zakon o
fiskalizaciji u prometu proizvoda i usluga; i portal Elektronske
fiskalizacije.

## Tri stope, i zašto baš ove stope

Zakon o porezu na dodatu vrijednost propisuje četiri stope na dan izdavanja
ovog paketa:

- **21%** — opšta stopa (član 24), za sve što nije posebno navedeno niže.
- **15%** — snižena stopa (član 24a stav 2), uvedena Zakonom o izmjenama i
  dopuni od 30.09.2024 ("Sl. list CG", br. 094/24), u primjeni od 01.01.2025:
  usluge smještaja u ugostiteljskim objektima za smještaj (tačka 2), usluge
  pripremanja i usluživanja hrane, pića i napitaka u ugostiteljskim
  objektima, osim alkoholnih pića, gaziranih i negaziranih pića sa dodatkom
  šećera i kafe koji ostaju na 21% (tačka 3), knjige i publikacije (tačka 1),
  i još sedam kategorija (autorska prava iz obrazovanja/nauke/umjetnosti,
  ulaznice za kulturne i sportske priredbe, sportski objekti u neprofitne
  svrhe, usluge u marinama, solarni paneli, frizerske usluge) koje ovaj paket
  ne transkribuje posebnim poreskim kôdom jer golden scenario ne prolazi kroz
  njih — isti kôd `ME-S-15`/`ME-P-15` pokriva sve njih po istoj stopi.
  **Prije 01.01.2025. usluge smještaja bile su oporezovane po stopi od 7%** —
  paket ne nosi istorijski poreski kôd za period prije te izmjene.
- **7%** — snižena stopa (član 24a stav 1), za osnovne proizvode za ljudsku
  ishranu, lijekove, udžbenike, vodu za piće, dnevnu štampu, javni prevoz,
  higijenske i pogrebne usluge, hranu za životinje, menstrualne proizvode i
  pelene za bebe — dvanaest tačaka, od kojih paket transkribuje samo prvu
  (osnovni proizvodi za ishranu) posebnim kôdom u golden scenariju; ostalih
  jedanaest dijeli isti kôd `ME-S-7`/`ME-P-7`.
- **0%** — nulta stopa (član 25), prije svega izvoz proizvoda; paket
  transkribuje samo tačku 1 (izvoz proizvoda koji prodavac ili neko za
  njegov račun iznosi iz Crne Gore) — ostalih trideset sedam tačaka člana 25
  i 28 (diplomatska predstavništva, brodovi, NATO snage, slobodne zone…) nije
  transkribovano, jer nijedan dokument golden scenarija ne prolazi kroz njih;
  vidjeti README dio "Čega ovaj paket ne nosi" niže.

Prag registracije za PDV je 30.000 eura prometa u posljednjih dvanaest
mjeseci (član 42) — socle ovog izdanja nema polje za prag registracije po
državi, pa ovaj podatak postoji samo ovdje, u README-u, a ne u
`pack.json`-u.

## Oslobođenja, i zašto bez VATEX kôda

Zakon poznaje oslobođenja od javnog interesa (član 26: poštanske,
zdravstvene, socijalne, obrazovne, kulturne, sportske, vjerske usluge) i
ostala oslobođenja (član 27: osiguranje i reosiguranje, promet nepokretnosti
osim prvog prenosa, dugoročni zakup stambenog prostora preko 60 dana,
bankarske i finansijske usluge, poštanske marke, plemeniti metali, igre na
sreću). Golden scenario transkribuje samo dugoročni zakup stambenog prostora
(član 27 stav 1 tačka 3, kôd `ME-S-EXEMPT-LEASE`).

Crna Gora je van zajedničkog sistema PDV Evropske unije — kandidat je za
pristupanje, ali pristupanje nije isto što i članstvo (Direktiva
2006/112/EZ, član 5 stav 2, veže samo države članice). Prema tabeli u
[`docs/packs.md`](../../docs/packs.md#što-jedan-porez-kaže-na-računu-tretman-kategorija-i-razlog),
zemlja van zajedničkog sistema ne pripisuje `exemption_code` (VATEX kôd):
članak koji obrazlaže oslobođenje ide u `legal_reference`, gdje je i inače
bio; nijedan od pet tretmana `intracom_*` se ne koristi jer Crna Gora nema
unutarunijsku isporuku; `vat_category` ostaje prazna jer paket ne prijavljuje
profil e-fakturisanja izgrađen na EN 16931 (vidjeti niže).

## Samooporezivanje usluga inostranih lica

Obrazac PR PDV-2 ima redni broj 21, "PDV na usluge inostranih lica", koji
Zakon vezuje za član 12 stav 1 tačka 2: kada poreski obveznik koji nema
sjedište u Crnoj Gori ne imenuje poreskog zastupnika, PDV plaća primalac
proizvoda, odnosno usluga. Isti iznos ulazi istovremeno u izlazni PDV (redni
broj 24) i u ulazni PDV (redni broj 25) obrasca — ne postoji poseban red
osnovice za ovu stavku. Paket to modeluje jednim poreskim kôdom
(`ME-P-FOREIGN`) sa dva porska knjiženja istog iznosa suprotnog predznaka
(konto 276, potraživanje po osnovu ulaznog PDV, i konto 470, obaveza po
osnovu izlaznog PDV), oba vezana za isti red 21 preko jednog knjiženja koje
nosi taj red; drugo knjiženje ne nosi red jer bi ga udvostručilo. Paket
pretpostavlja opštu stopu od 21% za samooporezovanu uslugu; kad bi
osnovna usluga, da je izvršio rezident, nosila sniženu stopu, treba
provjeriti sa računovođom.

## Plan konta, i podračuni koje je dodao ovaj paket

`accounts.csv` transkribuje klase 0 do 6 Kontnog okvira (preko 200 konta):
stalna imovina, zalihe, kratkoročna potraživanja i gotovina, kapital,
dugoročna rezervisanja i obaveze, rashodi i prihodi. Klase 7 (otvaranje i
zaključak računa), 8 (vanbilansna evidencija) i 9 (obračun troškova i
učinaka po mjestima troškova) nijesu transkribovane: zatvaranje poslovne
godine obavlja `close_fiscal_year()` preko `defaults.roles`
(`retained_earnings`/`retained_earnings_loss`), a vanbilansna evidencija i
obračun po mjestima troškova nijesu dio ovog izdanja Ekwo OS-a.

Uputstvo o primjeni Pravilnika o kontnom okviru izričito dozvoljava pravnim
licima da uvedu podračune višeg reda uz zadržavanje brojčane oznake konta iz
Kontnog okvira. Na toj osnovi ovaj paket dodaje:

- **`2715`/`2717`** — ulazni PDV po stopama od 15% i 7%. Kontni okvir iz
  2011/2020. razlikuje samo "opštu" (konto 270) i "sniženu" (konto 271)
  stopu, jer je u trenutku njegovog donošenja postojala samo jedna snižena
  stopa; od 01.01.2025. postoje dvije.
- **`4711`/`4717`** — odgovarajuća obaveza za PDV po izdatim fakturama, iz
  istog razloga.
- **`4698`** — razlike po osnovu zaokruživanja (uloga `rounding`), konto koji
  Kontni okvir ne imenuje posebno.

## Uloge konta (`defaults.roles`)

`tax_payable` (479) i `tax_receivable` (279) su konta razlike obračunatog i
prethodnog poreza — odvojena od konta na koja se knjiže pojedinačne stope PDV
(270-276, 470-476), kako zahtijeva pravilo naučeno na SK paketu (vidjeti brif
pripremljen za ovaj rad): red obrasca se mora moći saldirati na jedan konto.
`retained_earnings` pokazuje na `341` (neraspoređeni dobitak tekuće godine),
a ne na `340` (ranijih godina), jer je "tekuća godina" konto na koji
`close_fiscal_year()` direktno knjiži rezultat perioda pod stilom zatvaranja
`retained_earnings`; razvrstavanje u "ranije godine" na sljedećoj skupštini
ostaje ručna knjigovodstvena radnja van domašaja ovog izdanja.

## Iskaz o finansijskoj poziciji i Iskaz o ukupnom rezultatu

Oba obrasca (`ME-FS-BS`, `ME-FS-IS`) nose redne brojeve (AOP) — bilans stanja
od 001 do 144, bilans uspjeha od 201 do 265. Ovaj paket transkribuje jedanaest,
odnosno trinaest zbirnih redova na nivou klase/grupe konta Kontnog okvira,
umjesto svakog pojedinačnog reda obrasca (koji dalje razlaže prihode, rashode,
potraživanja i obaveze po povezanim/nepovezanim licima, valuti, i sl.) —
svaki konto ovog paketa dostiže tačno jedan zbirni red, što `ekwo pack check`
provjerava. Redovi 249-265 bilansa uspjeha (bruto rezultat drugih stavki
rezultata povezanih sa kapitalom — nerealizovani dobici/gubici po osnovu
revalorizacije, hedžinga i sl.) nijesu transkribovani jer ih nijedan konto
ovog paketa ne dostiže.

## Fiskalizacija — ono što ovo izdanje ne zna

Zakon o fiskalizaciji u prometu proizvoda i usluga ("Sl. list CG", br.
046/19, 073/19, 080/20, 008/21) nameće poreskom obvezniku koji promet
naplaćuje gotovinom ili platnim karticama da podatke o prometu i fiskalne
račune u realnom vremenu dostavlja Poreskoj upravi preko fiskalne službe
(obavezno od 01.06.2021). To je izvještavanje državnog servera o
pojedinačnom računu u trenutku izdavanja (clearance), potpuno drugačiji
mehanizam od strukturisane e-fakture između dvije strane izgrađene na
semantičkom modelu EN 16931 (Peppol BIS, Factur-X, XRechnung, PINT) —
`einvoicing.profile` ovog paketa je zato `null` i `obligation` je `none`, a
ne opis fiskalizacije. Ovo izdanje Ekwo OS-a nema modul koji bi račun u
trenutku izdavanja prijavio državnom serveru u realnom vremenu; poslovanje
preko fiskalne kase ili POS uređaja ostaje van dometa ovog paketa. Vidjeti
docs/international.md, odjeljak «From Montenegro».

## Čega ovaj paket ne nosi

- **Uvoz proizvoda** (redni broj 20 obrasca PR PDV-2, i članovi 22-23 Zakona)
  — ovo izdanje nema modul carinske deklaracije.
- **Paušalna nadoknada poljoprivredniku po stopi od 8%** (redni broj 22,
  član 42a) — posebna šema van obima ovog paketa.
- **Promet prirodnog gasa, električne energije i energije za grijanje ili
  hlađenje sa prenosom poreske obaveze** (redni brojevi 15 i 23) — uska
  energetska šema koju golden scenario ne pokriva.
- **Srazmjerni odbitak ulaznog PDV** (član 38, redni brojevi 26-27) — paket
  pretpostavlja puno pravo na odbitak; obveznik koji dijelom obavlja
  oslobođeni promet treba računovođu da izračuna srazmjerni dio.
- **Rok plaćanja poreza na dobit i mjesečnih akontacija** — ovaj paket nosi
  samo PDV; porez na dobit pravnih lica nije transkribovan.
- **Registar poreskih faktura ili slično** — Crna Gora, za razliku od
  Ukrajine, ne vodi poseban državni registar računa; svaki račun ostaje kod
  izdavaoca i primaoca, uz obavezu fiskalizacije opisanu iznad.

## Provjera ovog paketa

```sh
node packages/cli/dist/bin.js pack build me
node packages/cli/dist/bin.js pack check me
```

Nijedna od ovih komandi ne dodiruje bazu: obje čitaju samo `packs/me/` i
upoređuju izlaz sa `supabase/seed/116_pack_me.sql`.
