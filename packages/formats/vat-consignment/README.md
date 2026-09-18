# `@ekwo-ai/vat-consignment`

The Belgian **periodic VAT return** — the XML Intervat takes for the monthly
or quarterly declaration — in TypeScript, with no dependencies.

Give it the figures a declaration was filed with and it gives you the file, a
name for it, and the list of what could not be put in it.

```ts
import { generateVatConsignment } from '@ekwo-ai/vat-consignment';

const { file, filename, violations } = generateVatConsignment(boxes, {
  declarant: { vatNumber: '0999999999', name: 'Demo', countryCode: 'BE' },
  period: { year: 2026, quarter: 4 },
});
```

`boxes` is a grid, what the grid holds, and an amount:

```ts
[
  { box: '03', kind: 'base', amount: '10000.00' },
  { box: '54', kind: 'tax', amount: '2100.00' },
  { box: '71', kind: 'total', amount: '2100.00' },
]
```

which is the row shape of `tax_filing_boxes` in
[Ekwo OS](https://github.com/Ekwo-ai/ekwo-os) — the figures **as they were
frozen at filing**. That is the input on purpose: what is deposited has to be
what the declaration says, and a file that recomputes from the ledger can
diverge from the filing it is meant to carry.

## What it does

- Writes one `VATConsignment` holding one `VATDeclaration`
  (`generateVatConsignment`) or as many as it is given
  (`generateVatConsignments`), **valid against the schema the administration
  publishes** — checked in this package's own tests, instance by instance.
- Writes the **representative** who files for the declarants, when there is
  one. The schema repeats `VATDeclaration` and counts them in
  `VATDeclarationsNbr`: it was drawn so that a firm deposits the returns of all
  its clients in one file, in its own name. The block is optional and **every
  field inside it is required**, so a representative is named entirely or
  refused by exception — neither completed nor dropped, because a file that
  silently loses its representative is sent under another authority than the
  one that was meant. The state that issued its identifier is one of `ISSUERS`,
  the schema's own list and not ISO's: Greece is `EL` there.
- Numbers the returns of a consignment by position unless told otherwise,
  refuses two under one number, and says on each violation which return it is
  in.
- Numbers every grid with two digits: `3` and `03` are the same grid, and the
  form writes the second.
- Leaves out a grid at zero. An absent grid reads as a zero, and a return that
  writes out its thirty empty boxes is one nobody can read.
- Writes a **nil return as a return**. The schema requires `Data` and at least
  one `Amount` in it, and does not say which; so a period where nothing happened
  says the one thing it has to say — that nothing is owed — on grid 71, which is
  the grid that carries what is owed. A choice of this package, forced by the
  schema and not specified by it (`NIL_GRID`).
- Always writes `ClientListingNihil`, because the schema requires it on every
  return, and defaults it to `NO` — the absence of a claim, not a claim that
  there will be a listing.
- Names the declaration it replaces, in `ReplacedVATDeclaration`, when it is a
  corrective: pass `replacedDeclaration` the reference Intervat gave the first
  one.
- Writes amounts with two decimals and a point. The French-language pages of
  the administration show examples with a comma; the schema does not, and the
  validator refuses one.
- Writes nothing for a field that was not given. A telephone number invented to
  satisfy a validator travels to an administration as a telephone number — and
  the schema, as it turns out, does not ask for one.

## What comes back as a violation

The rest of the file stays valid, because a return that refuses to exist over
one unreadable figure helps nobody. Each of these is something the schema would
have refused — the tests put each one back in the file and watch validation
fail — which is what makes them violations of this format and not opinions of
this package.

| code | when |
|---|---|
| `unknown_grid` | the box is not one of the twenty-nine grids the schema lists (`GRIDS`) |
| `grid_twice` | the same grid was given twice, as a base and as a tax |
| `negative_amount` | the amount is below zero: every grid is a `PositiveAmount_Type` |
| `amount_out_of_range` | the amount is more than the schema can hold |
| `invalid_amount` | the amount is not a number |
| `reference_too_long` | the declarant's reference is over fourteen characters — left out |
| `invalid_phone` | the telephone number does not fit twenty digits — left out |

`grid_twice` is the one thing this format cannot hold: it gives every grid a
single value. A form that prints a base and a tax on the same line — the French
CA3 does, on line 08 — has no representation here, and that is a fact about
this file and not a defect of the figures.

`negative_amount` is worth a sentence too. This form never lets a grid go below
zero: what reduces a figure has a grid of its own — 48 and 49 for credit notes
issued, 61 and 62 for regularisations. A negative figure reaching this package
means the books netted something the form wants shown apart.

Three things are refused by exception instead, because they make the whole file
meaningless: a period that is neither a month nor a quarter, a declarant number
the schema cannot hold, and a corrective that names what it replaces in any
shape but the one Intervat uses.

## What it does not do

- **It does not deposit anything.** Uploading the file needs a certificate, an
  authenticated session and somebody on call; that is the operated side of this
  project and not a library.
- **It does not decide what to ask for.** `Restitution` and `Payment` are
  requests made to the administration, not consequences of the figures, so both
  default to no and the caller says otherwise.
- **It does not claim anything about the annual customer listing.** The element
  is required, so it is written; `NO` unless the caller says otherwise.
- **It does not know whether the representative holds a mandate** for each
  declarant. That is a fact of the administration's records, not of the file;
  a consignment without one is refused there, not here.
- **It computes nothing.** No total is derived, no grid is filled from another:
  the figures come in frozen and go out unchanged.

## Sources

- [Intervat](https://finances.belgium.be/fr/E-services/intervat) — the service
  the file is deposited on, SPF Finances, and where its technical documentation
  and XSD schemas are published.
- Schema `NewTVA-in_v0_9.xsd`, namespaces
  `http://www.minfin.fgov.be/VATConsignment` and
  `http://www.minfin.fgov.be/InputCommon`.
- Arrêté royal n° 1 du 29 décembre 1992 relatif aux mesures tendant à assurer
  le paiement de la taxe sur la valeur ajoutée, **art. 18** — the form and its
  frames; **art. 18, § 1er** — filed by the twentieth day of the month that
  follows.
- Code de la TVA, **art. 53, § 1er, alinéa 1er, 2°** — the obligation to file.

## What is verified, and what is not

**Verified**: every shape of file this package writes — a full return, a minimal
one, a nil one, a corrective, one carrying every grid at once, one under a
representative and one holding the returns of several declarants — validates
against `NewTVA-in_v0_9.xsd` and the four schemas it imports, in
`test/schema.test.ts`, with no network and no system tool. The list of grids in
the source is compared with the enumeration of the schema, number for number,
so it cannot drift from it; so is the list of states that issue a
representative's identifier. A representative missing any one field is shown to
be what the schema refuses. The schemas are kept unmodified under `test/xsd/`,
with where each came from; the package ships none of them.

The first version of this brick was written from a production filing and said
here that the schema had not been read. Reading it found four defects the same
day: `Data` and `ClientListingNihil` are required, every amount is a positive
one, and the grids are a closed list.

**Not verified**: what Intervat checks *beyond* the schema. The portal applies
business controls of its own — arithmetic between grids, warnings to justify
before signing — and those are rules of the form, not of the file. A return
that is valid here can still be questioned there. `Justification` and
`FileAttachment`, which the schema allows for exactly that, are not written by
this package yet.

## Licence

MIT. See [`LICENSE`](./LICENSE).
