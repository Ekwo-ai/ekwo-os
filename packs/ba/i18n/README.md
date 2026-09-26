# Odakle dolazi jezik ovog paketa

Sâm paket je napisan na bosanskom (`defaults.language: "bs"`), jer je
Zakon o porezu na dodanu vrijednost — kao i oba pravilnika Federalnog
ministarstva finansija na kojima se zasniva kontni okvir i obrasci
finansijskih izvještaja — objavljen na bosanskom/hrvatskom/srpskom jeziku.
Uprava za indirektno oporezivanje (UIO) objavljuje i zvaničan engleski
prijevod samog Zakona o PDV-u (naveden u `pack.json.certification.sources`
pod ključem `vat-law`); nijedan od preostalih izvora (pravilnici o kontnom
okviru i o formi finansijskih izvještaja, Obrazac P PDV) nema zvaničnu
englesku verziju.

## Zašto postoji `i18n/en.json`

`i18n/en.json` je **radni prijevod ovog paketa**, sačinjen od strane
njegovog autora — a ne zvanična engleska verzija bilo kojeg od pravilnika
ili obrasca koje ovaj paket transkribuje, jer takva verzija za njih ne
postoji. Svako polje `legal_reference` u cijelom paketu ostaje na
bosanskom i poziva se na bosanski član zakona ili pravilnika; prijevod se
odnosi samo na nazive računa, dnevnika, poreza, kutija prijave i redova
finansijskih izvještaja.

## Dodavanje jezika

Format zahtijeva jednu datoteku, `i18n/<lang>.json`, u kojoj živi cijeli
prijevod jednog jezika. Datoteka koja nije navedena u `languages` unutar
`pack.json` može biti djelomična; ona koja jeste navedena mora pokriti
svaki ključ, a `ekwo pack check` imenuje ono što nedostaje.
