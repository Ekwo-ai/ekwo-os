# Srbija

Sve što Srbija dodaje Ekwo-u je podatak: računi Kontnog okvira (Pravilnik
89/2020), stope poreza na dodatu vrednost 20 %/10 %/0 %, poreska oslobođenja,
poreska prijava PDV u sadržini koju propisuju Zakon o porezu na dodatu
vrednost i Pravilnik o obliku i sadržini poreske prijave PDV, i Bilans stanja
sa Bilansom uspeha po Prilogu 1 i 2 Pravilnika 89/2020. Format je opisan u
[`docs/packs.md`](../../docs/packs.md); ovaj fajl kaže odakle je svaki red
uzet i na kojoj odluci stoji, tako da knjigovođa koji poznaje Srbiju može da
ospori jednu rečenicu, a ne ceo paket.

**Status: `community`.** Nijedan ovlašćeni računovođa ili revizor još nije
pregledao ovaj paket. Cifre su reprodukovane testom `tests/golden.test.ts` na
osnovu jedne godine knjiga — to dokazuje unutrašnju doslednost paketa, ne
njegovu pravnu tačnost.

**Paket je napisan na srpskom, latinicom** (`defaults.language: "sr"`), jer
svaki tekst na koji se poziva — Zakon o porezu na dodatu vrednost, Pravilnik
o Kontnom okviru, Pravilnik o obliku i sadržini poreske prijave PDV — postoji
zvanično samo na srpskom. `i18n/en.json` je **radni prevod paketa** za
čitaoca koji ne zna srpski, a ne zvanična engleska verzija bilo kog od tih
tekstova — nijedan od njih takvu verziju nema; vidi
[`i18n/README.md`](i18n/README.md).

## Izvori

Svaki porez, kutija, pravilo dokumenta i red tabele nosi sopstveni
`legal_reference` i ključ izvora iz kog je ta odredba uzeta.
`pack.json.certification.sources` nosi deset tekstova, svi provereni
26.09.2026:

| Šta | Tekst | Gde |
|---|---|---|
| Predmet, stope, oslobođenja, poreski dužnik, prijava i plaćanje PDV | Zakon o porezu na dodatu vrednost | mfin.gov.rs |
| Kontni okvir i sadržina računa | Pravilnik 89/2020 (privredna društva, zadruge i preduzetnici) | mfin.gov.rs |
| Obrasci finansijskih izveštaja (Bilans stanja, Bilans uspeha) | Pravilnik 89/2020 (obrasci) | mfin.gov.rs |
| Pozicije skraćenog (mikro) obrasca Bilansa stanja/uspeha | Izveštaj o bonitetu BON-JN | apr.gov.rs |
| Obrazac PPPDV — polja i njihovo punjenje iz Obrasca POPDV | Pravilnik o obliku i sadržini poreske prijave PDV | purs.gov.rs |
| Podnošenje poreske prijave PDV | Portal ePorezi | eporezi.purs.gov.rs |
| Obaveza elektronskog fakturisanja (SEF) | Zakon o elektronskom fakturisanju | efaktura.gov.rs |
| Sistem e-Faktura | Portal SEF | efaktura.gov.rs |
| Rok plaćanja u odsustvu ugovora | Zakon o rokovima izmirenja novčanih obaveza... | efaktura.gov.rs |
| Ispravka grešaka u poslovnim knjigama | Zakon o računovodstvu | mfin.gov.rs |

## Kontni okvir, i zašto baš ovi računi

**Pravilnik 89/2020 je obavezujući za sva pravna lica i preduzetnike koji
vode poslovne knjige po sistemu dvojnog knjigovodstva** (član 1). Ovaj paket
transkribuje osnovne (trocifrene) račune propisane Kontnim okvirom i
najčešće korišćene analitičke podračune; član 3. stav 2. Pravilnika izričito
dozvoljava raščlanjavanje propisanih trocifrenih računa na analitičke
račune, na osnovu čega ovaj paket dodaje:

- **`4999`** — pod zvaničnim računom `469` («Ostale obaveze») ovaj paket
  dodaje prelazni račun za sume čije se poreklo utvrđuje
  (`defaults.roles.suspense`): Pravilnik ne propisuje poseban «compte
  d'attente» kao francuski ili belgijski kontni plan; ovo je odluka paketa,
  označena za proveru knjigovođe.
- **`279`/`479`** su, za razliku od 4999, **zvanični** trocifreni računi
  Kontnog okvira («Potraživanja za više plaćeni porez na dodatu vrednost» i
  «Obaveze za porez na dodatu vrednost po osnovu razlike obračunatog PDV i
  prethodnog poreza») — upravo su predviđeni da nose neto rezultat
  deklaracije, odvojeno od računa 270–278/470–476 na koje se sami porezi
  knjiže tokom perioda. Postavljeni su kao `defaults.roles.tax_receivable` /
  `tax_payable`, oba `reconcilable`.
- **`00`/`000`/`001`** («Upisani a neuplaćeni kapital», na strani aktive) i
  **`31`/`310`/`311`** (istoimena grupa na strani kapitala) su **dva
  različita, zvanična računa** Kontnog okvira, ne dupliranje istog — prvi
  je potraživanje od akcionara/članova, drugi je bruto iznos upisanog a
  još neuplaćenog dela osnovnog kapitala; oba se pojavljuju u Bilansu
  stanja kao odvojeni redovi (A na aktivi, II na pasivi).
- **`72`/`721`/`722`** — Kontni okvir smešta obračun poreza na dobitak
  perioda («Poreski rashod perioda», «Odloženi poreski rashodi i prihodi
  perioda») u grupu 72, deo Klase 7 («Otvaranje i zaključak računa stanja i
  uspeha»), a ne u Klasu 5 (Rashodi) kao većina drugih kontinentalnih
  planova; ovaj paket prati tu podelu jer je tako propisano, i koristi
  samo 721/722 od cele grupe 72 (720, 723, 724 i računi grupa 70/71/73 su
  tehnički računi ručnog zaključka glavne knjige koje Ekwo-ov
  `close_fiscal_year()` ne treba — vidi „Zatvaranje godine” niže).

**Klasa 9 (obračun troškova i učinaka) nije preneta.** Kontni okvir je
obavezan samo za osnovne (trocifrene) račune Klasa 0–7; Klasa 9 je interna
kalkulacija troškova i učinaka koju svako pravno lice organizuje po
sopstvenoj potrebi (član 3. stav 3), pa je van dometa ovog paketa.

**Nisu preneti svi analitički podračuni zvaničnog Kontnog okvira.** Sitni
podračuni (npr. obaveze prema matičnim/zavisnim pravnim licima po grupama
41-46, hartije od vrednosti kojima se trguje, poljoprivredni podračuni) nisu
dodati — nijedan dokument ovog golden scenarija ih ne zahteva; ovo nije
odluka nego još nenapisana detaljizacija.

## Zatvaranje godine

`closing_style: "result_accounts"` — rezultat godine ostaje na računima 341
(dobitak) / 351 (gubitak) do skupštine koja ga raspoređuje, umesto da se
odmah preseli u 340/350 («Neraspoređeni dobitak/gubitak ranijih godina»),
tačno kao francuski 120/129. Ovo je jedina od tri metode zatvaranja socle-a
koja odgovara Kontnom okviru: grupe 34 i 35 razdvajaju tekuću godinu od
ranijih upravo na taj način.

## Porezi

**Dve pozitivne stope, jedan član.** Član 23. stav 1. Zakona o PDV određuje
opštu stopu od 20 % od 1. oktobra 2012 (Sl. glasnik RS 93/2012); stav 2. istog
člana određuje posebnu (sniženu) stopu od 10 % za dvadeset jednu taksativno
nabrojanu kategoriju dobara i usluga (hleb i mleko, lekovi, đubriva, udžbenici,
dnevne novine, ogrevno drvo, smeštaj u ugostiteljskim objektima, prevoz
putnika, voda za piće, komunalne usluge i dr.).

| | Kod | Stopa | Kutija prijave |
|---|---|---|---|
| Opšta stopa (prodaja) | `RS-S-20` | 20 % | 003/103 |
| Posebna stopa (prodaja) | `RS-S-10` | 10 % | 004/104 |
| Izvoz dobara (prodaja) | `RS-S-EXPORT` | 0 %, sa pravom na odbitak | 001 |
| Usluge obrazovanja, čl. 25. st. 2. tač. 13) (prodaja) | `RS-S-EXEMPT-EDU` | oslobođeno, bez prava na odbitak | 002 |
| Građevinski radovi > 500.000 RSD, čl. 10. st. 2. tač. 3) (prodaja) | `RS-S-RC-CONSTR` | 0 %, PDV plaća primalac | 003 |
| Opšta stopa (nabavka, odbitna) | `RS-P-20` | 20 % | 008/108 |
| Posebna stopa (nabavka, odbitna) | `RS-P-10` | 10 % | 008/108 |
| Nabavka bez PDV kod oslobođenog dobavljača | `RS-P-EXEMPT` | — | — |
| Uvoz dobara, PDV plaćen na carini | `RS-P-IMPORT` | 20 %, odbitni | 006/106 |
| Građevinski radovi primljeni > 500.000 RSD | `RS-P-RC-CONSTR` | 20 %, samoobračunati | 003/008, 103/108 |
| Usluga stranog lica koje nije obveznik PDV u Republici | `RS-P-RC-FOREIGN` | 20 %, samoobračunati | 003/008, 103/108 |

**Van zajedničkog sistema PDV Evropske unije, dakle bez VATEX kodova.**
Srbija je zemlja kandidat, ne država članica; prema Direktivi 2006/112/EZ,
član 5(2), zajednički sistem PDV se ne prostire na kandidate (vidi novi red
`supabase/seed/00_territories.sql`). `exemption_code` je zato ostavljen
prazan na svakom porezu, a član zakona pod koji potpada oslobođenje je
zapisan u `legal_reference` — kao što je uradio paket `tr` i `ae`.

**Autoliquidacija u građevinarstvu (član 10. stav 2. tačka 3)) je
modelovana na obe strane, sa jednom nesigurnošću koju treba proveriti sa
knjigovođom.** Obrazac PPPDV, prema članu 13. Pravilnika, nema posebnu
kutiju za promet za koji je primalac poreski dužnik — kutija 003/103 je
opisana samo kao „promet po opštoj stopi”. Ovaj paket pretpostavlja da se
samoobračunati promet (i na strani prodavca, informativno bez PDV, i na
strani primaoca, sa PDV-om) prijavljuje u istoj kutiji kao redovna prodaja
po toj stopi, jer obrazac POPDV — čiji zbir PPPDV kutija 003/103 preuzima —
nije nezavisno proveren do nivoa pojedinačnih polja unutar te kutije.
Isto važi za `RS-P-RC-FOREIGN` (usluga stranog lica koje nije evidentirani
obveznik PDV u Republici, član 10. stav 1. tačka 3)).

**Paušalna nadoknada PDV poljoprivrednicima (kutija 007/107, član 34. Zakona)
nije modelovana.** Kutija postoji u `tax_report.json`, ali nijedan porez ovog
paketa je ne dostiže — poseban paušalni režim za poljoprivrednike zahteva
sopstvenu poresku stopu (8 %) i sopstvena pravila koja ovaj paket ne nosi.

## Poreska prijava

`tax_report.json` transkribuje **sadržinu** Obrasca PPPDV kako je propisuje
Pravilnik o obliku i sadržini poreske prijave PDV, član 13: promet oslobođen
sa pravom na odbitak (001), promet oslobođen bez prava na odbitak (002),
promet po opštoj i posebnoj stopi sa zbirovima (003–105), prethodni porez po
uvozu, po poljoprivrednoj nadoknadi i ostali, sa zbirovima (006–109), i konačan
iznos za uplatu ili povraćaj (110).

**Poreski period zavisi od prometa obveznika, ne od jedinstvenog pravila.**
Član 48. Zakona: kalendarski mesec za obveznika čiji je ukupan promet u
prethodnih 12 meseci veći od 50.000.000 dinara, kalendarsko tromesečje za
obveznika ispod tog praga. Ovaj paket zato ne deklariše `period_default` —
odgovor zavisi od činjenice o preduzeću koju paket ne poznaje — nego samo
listu dozvoljenih perioda `["month", "quarter"]`.

**Rok za podnošenje prijave i za plaćanje je isti: 15 dana po isteku
poreskog perioda** (član 50. stav 1. Zakona), za obe kadence.

**Iznosi u prijavi su bez decimala.** Član 26. Pravilnika o obliku i
sadržini poreske prijave PDV — `tax_report.json.rounding.unit` je 1.

## Elektronsko fakturisanje (SEF) — ono što jezgro (socle) ne ume da opiše

**Elektronsko fakturisanje je obavezno od 1. januara 2023. godine za promet
između subjekata privatnog sektora** (Zakon o elektronskom fakturisanju,
član 24), sa ranijim rokovima (1. maj i 1. jul 2022) za promet prema javnom
sektoru i od javnog sektora. Sistem e-Faktura (SEF, efaktura.gov.rs) je
**državna platforma** preko koje se fakture obavezno izdaju, šalju, primaju
i čuvaju — nije reč o razmeni preko mreže vršnjaka (peer-to-peer) kao kod
Peppol-a. `pack.json.einvoicing.profile` je ostavljen prazan, a ne popunjen
uslovnim nazivom: SEF-ov XML format nije jedan od profila izgrađenih na
semantičkom modelu EN 16931 (Peppol BIS, Factur-X, XRechnung, PINT), nego
format koji propisuje Ministarstvo finansija svojim Pravilnikom o
elektronskom fakturisanju. Format `einvoicing.obligation`/`mandatory_from`
pretpostavlja tačno takav profil („a statute obliges companies to exchange
**the profile**”); pošto ovaj paket ne deklariše profil, ta dva polja ostaju
nepopunjena (kao što je uradio paket `ua` za Jedinstveni registar poreskih
faktura), a stvarni datumi i obaveza su ispisani u `legal_reference`, gore i
u README-u.

**Elektronsko evidentiranje obračuna PDV u sistemu e-Faktura (član 4. Zakona
o elektronskom fakturisanju) je odvojena obaveza od same poreske prijave
PDV**, sa istim rokom (rok za podnošenje poreske prijave). Ova evidencija —
zbirna ili pojedinačna, po transakciji — je detaljniji zapis od kutija
Obrasca PPPDV koje ovaj paket modeluje kao `tax_report.json`, i socle nema
mesto za nju: nijedno polje formata ne opisuje obavezu evidentiranja u
državnom sistemu koja je odvojena od same deklaracije. Vidi
docs/international.md, odeljak „From Serbia”.

## Bilans stanja i Bilans uspeha

`statements.json` nosi **skraćeni (mikro) obim** obrazaca Priloga 1 i 2
Pravilnika 89/2020 — pozicije označene samo slovnim oznakama i rimskim
brojevima (čl. 6. st. 2. i čl. 8. st. 2. Pravilnika), potvrđene sadržinom
Izveštaja o bonitetu BON-JN Agencije za privredne registre. Puni obrazac, sa
AOP šiframa na nivou pojedinačnog arapskog broja, nije transkribovan — vidi
„Šta ovaj paket ne nosi” niže.

**Forma razlikuje za svaki međuzbir poseban red „dobitak” i poseban red
„gubitak”** (npr. V./G. Poslovni dobitak/gubitak, E./Ž. Dobitak/gubitak iz
finansiranja, Ć./U. Neto dobitak/gubitak), od kojih se u svakom periodu
popunjava samo jedan. Ovaj paket, kao i paket za Ukrajinu, svaki takav par
svodi u jedan red sa znakom (pozitivna vrednost — dobitak, negativna —
gubitak).

**Dugoročna i kratkoročna aktivna/pasivna vremenska razgraničenja nisu
razdvojena posebnim računima** u Kontnom okviru — razdvajanje po roku
dospeća je pitanje procene, ne koda računa; redovi „V. Dugoročna AVR” i
„III. Dugoročna PVR” stoga nisu transkribovani (uvek bi bili nula). Isto
važi za „1. Kratkoročna rezervisanja” na strani pasive: Kontni okvir ima
samo dugoročna rezervisanja (grupa 40).

`xbrl` fact key-jevi su svuda prazni: da li Srbija ima XBRL taksonomiju za
ove obrasce nije predmet ovog istraživanja.

## Na računu (fakturi)

**Numeracija `sequential`, bez zakonske obaveze neprekinutog niza.** Član 42.
stav 5. tačka 2) Zakona o PDV traži samo „redni broj računa”, ne izričito
niz bez praznina; `{CODE}-{YYYY}-{NNNN}` je ovde primer redosleda, a ne
jedini nametnuti oblik.

**Poreska obaveza nastaje po prvoj od dve radnje, a ne po pravilu i
izuzetku.** Član 16. stav 1. Zakona: promet dobara/usluga ili naplata pre
prometa, koje god se pre desi (a treće, uvoz, carinski dug). Nijedna od prve
dve radnje ne pretpostavlja drugu, za razliku od Belgije ili Luksemburga gde
je datum isporuke pravilo a datum računa izuzetak — otud
`earliest_of_delivery_or_payment`, a ne `invoice_date` ili `invoice_if_issued`.

**Rok plaćanja u odsustvu ugovora je 60 dana.** Zakon o rokovima izmirenja
novčanih obaveza u komercijalnim transakcijama, član 3. st. 1. i 2. —
ugovorom između privrednih subjekata ne može se predvideti rok duži od 60
dana, a ako rok nije ugovoren (ili ugovor ne postoji, ili je ugovoren duži
rok), dužnik mora platiti u roku od najviše 60 dana.

**`posted_edit_policy` — `reversal_only`.** Zakon o računovodstvu, član 9 —
ispravka greške ne sme brisati ni menjati bez traga; Zakon o PDV, član 42.
stav 10. i član 21 — ispravka osnovice i PDV se vrši sastavljanjem računa o
smanjenju/povećanju osnovice (knjižnog odobrenja/zaduženja), nikad brisanjem
izdatog računa.

## Šta ovaj paket ne nosi

- **Elektronsko evidentiranje obračuna PDV u sistemu e-Faktura**, odvojeno
  od poreske prijave PDV — vidi „Elektronsko fakturisanje” gore.
- **Puni (ne skraćeni) obrazac Bilansa stanja/uspeha**, sa AOP šiframa na
  nivou pojedinačnog reda — vidi „Bilans stanja i Bilans uspeha” gore.
- **Paušalna nadoknada PDV poljoprivrednicima** (kutija 007/107, član 34.
  Zakona) — kutija postoji, nijedan porez je ne dostiže.
- **Osnovna sredstva.** `assets.json` ne postoji; stope amortizacije za
  poreske i računovodstvene svrhe su van ovog istraživanja.
- **Bankarski formati.** Nijedan format izvoda ili naloga za plaćanje
  srpskih banaka nije proveren ovim istraživanjem; odeljak `bank` u
  `pack.json` ne postoji.
- **XML fakture SEF-a.** Nijedna komponenta `packages/formats/` ne piše,
  ne potpisuje i ne šalje taj dokument u SEF.
- **Prag za „malog obveznika”** (8.000.000 dinara u prethodnih 12 meseci,
  član 33. Zakona) — registraciona odluka koju socle ne modeluje (nijedan
  paket ne bira poreski status preduzeća).

## Pregled ovog paketa

Otvorite zadatak «Review: Serbia». Šta jeste, a šta nije pregled — u
[`docs/packs.md`](../../docs/packs.md), odeljak „Certification, and who may
say what”. Tačke koje bi ovlašćeni računovođa trebalo prvo da pročita, od
najmanje izvesne:

1. **Kutija PPPDV obrasca u koju se prijavljuje samoobračunati promet iz
   autoliquidacije** (građevinarstvo, usluge stranog lica) — ovaj paket
   pretpostavlja istu kutiju kao redovna prodaja po istoj stopi, jer
   pojedinačna polja Obrasca POPDV nisu nezavisno provere na — vidi
   „Porezi” gore.
2. **Skraćeni (mikro) obim Bilansa stanja/uspeha** — da li je dovoljan za
   konkretno pravno lice, ili treba puni obrazac.
3. **Prelazni račun 4999** — dodatak van slova Kontnog okvira, dozvoljen
   njegovim članom 3. stav 2, ali ne i njegovim izričitim tekstom.
4. **Odsustvo paušalne nadoknade poljoprivrednicima** i osnovnih sredstava.
