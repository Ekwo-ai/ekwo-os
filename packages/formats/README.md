# Format libraries

One npm package per file format, organised **by format and never by country**.
Factur-X is French and German, UBL is universal, camt.053 is European: a format
is not a country. Which formats a country uses is said by its pack, in
`einvoice_profile` and in the bank format lists — never by the shape of this
directory.

Each package here:

- is **MIT**, with its own `LICENSE` file, so it can end up inside a
  competitor, a software house or an administration;
- **imports nothing from the core** — not `@ekwo-ai/core`, not the schema, not
  another brick;
- reads the **flat row shapes** the core's `financial_statement()`,
  `vat_return()`, `ec_sales_list()`, `fec_lines()` and `document_*` views
  return, and declares them in its own types rather than importing them from
  anywhere;
- produces the bytes, the name the administration expects and what does not add
  up — `{ file, filename, violations[] }`, under whatever names the format
  gives them;
- declares no `schema_min`: the contract is the shape of the rows, and the
  end-to-end test in `tests/` is what breaks when it moves.

Three of them go the other way. `camt053`, `coda` and `cfonb120` **read** a
file — the statement a bank sends — and return rows instead of taking them:
statements and lines, in a shape each declares itself, with `violations[]` for
what does not add up and an exception for what is not a statement at all. The
rules above hold unchanged — MIT, nothing imported from the core, no database,
no country — and one is added, because a file that comes from outside is
hostile until read. For the XML one that is its own strict reader, with no
DOCTYPE, no entity beyond the five XML predefines, and a bound on size, depth
and count; for the two formats of fixed positions it is a record that is
exactly as long as the format says or a file that is refused, an encoding that
is said and never guessed, and an unknown record refused by name. What they
have to prove is also the other way round: not that their output validates, but
that the files they are tested on are what the standard says they are — so the
camt.053 fixtures are held against the published schemas, and the CODA and
CFONB 120 fixtures are written, position by position, by a builder that is a
second reading of the published lay-out.

The three return **the same fields under the same names**, and that is not a
shared abstraction: none imports another, and each declares the shape in its
own `types.ts`. It is the core saying what `import_bank_statement()` takes, and
three bricks each choosing to return it — what only one format says (a CODA
transaction code, a CFONB operation code) comes after, under its own name.

There is no shared abstraction between them and there will not be one: no
`Filing` interface, no plugin registry, no common `xml` package. Two formats
that look alike are two formats.

`tests/formats.test.ts` enforces the licence, the isolation and the
dependencies of every package in this directory, and `tests/` carries one
end-to-end test per package: a country pack's golden year of books, through the
real engine, into the file — which is the only place a pack and a brick meet,
and the only test that notices when either moves.

Four of them read the same rows, from `ec_sales_list()`, and write four
different files, which is what "by format and never by country" buys. They do
not agree on much: Belgium prints one line per customer **and per nature** with
a letter code, Estonia prints one line per customer with three amount columns,
Luxembourg wants the country and the number in two fields and France wants them
joined, three of the four write decimals and two write whole euros. Two formats
that look alike are two formats.
