# Odakle dolazi jezik ovog paketa

Sam paket je napisan na crnogorskom jeziku, latinicom (`defaults.language:
"sr"` — Ekwo OS-ov registar jezika još ne nosi poseban kôd za crnogorski, pa
je upisan pod `sr`, kôdom najbližim po pisanoj formi; vidjeti napomenu u
README.md). Ovo nije prevod: svaki tekst na koji se paket poziva — Zakon o
porezu na dodatu vrijednost, Pravilnik o kontnom okviru, Zakon o
računovodstvu, Obrazac PR PDV-2 — već je zvanično na ovom jeziku.

## Zašto postoji `i18n/en.json`

`i18n/en.json` je **radni prevod ovog paketa**, koji je sačinio njegov autor,
a ne zvanična engleska verzija Zakona o porezu na dodatu vrijednost, Pravilnika
o kontnom okviru ili obrasca PR PDV-2: nijedan od ovih tekstova nema takvu
verziju. Svako polje `legal_reference` cijelog paketa ostaje na crnogorskom i
poziva se na crnogorski član zakona; prevod se odnosi samo na nazive konta,
dnevnika, poreza, redova prijave, redova finansijskih iskaza i napomena na
računu.

## Dodavanje jezika

Format zahtijeva jedan fajl, `i18n/<lang>.json`, u kojem živi cio jezik. Fajl
koji nije naveden pod `languages` u `pack.json` može biti djelimičan; onaj koji
jeste, mora pokriti svaki ključ, a `ekwo pack check` imenuje šta nedostaje.
