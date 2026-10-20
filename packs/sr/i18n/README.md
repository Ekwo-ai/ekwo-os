# `packs/sr/i18n/` — the Surinamese pack in English

`pack.json` declares `"languages": ["en"]`, and `ekwo pack check` holds the file
to that promise: every account, journal, tax, box of the return, line of the two
statements and sentence of an invoice has an English label. The pack's own
files are written in Dutch, which is what `defaults.language` says, because
Dutch is the language of every text they transcribe and the law asks the
administration to be kept in it (Wet BTW, article 30).

## Where the wording comes from

**Everything was translated for this pack and has no official standing.** The
Surinamese texts exist in Dutch only: the Belastingdienst publishes the model
return (S.B. 2023 no. 31), its notes and its brochure in Dutch, and no text
prescribes an English wording for an account, a journal, a tax code or a
rubric. The rubrics keep their numbers (1a to 4j), which are the form's.

An invoice issued under Surinamese law carries the Dutch sentence: the exempt
mention in `en.json` says the same in English and is not what the invoice
prints.
