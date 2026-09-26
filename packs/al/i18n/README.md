# Nga vjen gjuha e këtij paketimi

Vetë paketimi është shkruar në shqip (`defaults.language`). Kjo nuk është një
përkthim: çdo tekst mbi të cilin mbështetet — Ligji Nr. 92/2014, Ligji Nr.
25/2018, SKK 2 — është tashmë zyrtarisht në gjuhën shqipe.

## Pse ekziston `i18n/en.json`

Briefi i këtij paketimi kërkon shprehimisht një përkthim anglisht për një
lexues që nuk lexon shqip. `i18n/en.json` është **një përkthim pune i vetë
këtij paketimi**, bërë nga autori i tij, jo versioni zyrtar anglisht i Ligjit
Nr. 92/2014, i Ligjit Nr. 25/2018 apo i SKK 2: asnjëri prej këtyre teksteve
nuk ka një version të tillë. Çdo fushë `legal_reference` e gjithë paketimit
mbetet në shqip dhe i referohet nenit shqiptar; përkthimi prek vetëm emrat e
llogarive, journaleve, tatimeve, kutive të deklaratës, rreshtave të
pasqyrave financiare dhe shënimeve mbi faturë.

## Shtimi i një gjuhe

Formati kërkon një skedar të vetëm, `i18n/<lang>.json`, dhe çdo gjuhë jeton
atje. Një skedar që nuk është shtuar te `languages` i `pack.json` mund të
jetë i pjesshëm; ai që shtohet duhet të mbulojë çdo çelës, dhe `ekwo pack
check` thotë çfarë mungon.
