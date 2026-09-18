# The published schemas

Fixtures of `test/schema.test.ts`, and nothing else: the package ships none of
them (`files` in `package.json` lists `dist`, the README and the licence) and
reads none of them at runtime.

They are the schemas ISO 20022 publishes for the *Bank To Customer Statement*
message, `camt.053.001.02` to `camt.053.001.14`, unmodified, retrieved on
18 September 2026 from

    https://www.iso20022.org/sites/default/files/documents/messages/camt/schemas/camt.053.001.NN.xsd

with `NN` from `02` to `14`. The catalogue that lists them, with the message
definition reports they belong to:
<https://www.iso20022.org/iso-20022-message-definitions?business-domain=1> and
<https://www.iso20022.org/catalogue-messages/iso-20022-messages-archive>.

Version `01` (2007) is served at the same address and is not here, because it
is not read: it names the message `BkToCstmrStmtV01`, types a balance and an
account another way, and predates the shape every later version shares. The
reader refuses it by name (`unsupported_version`) rather than half reading it.

What these are **not**: the usage guidelines a banking community writes on top
of the message — EPC, CGI-MP, a national federation's implementation guide, a
bank's own. Those restrict the schema (which elements a bank fills, with what)
and none of them is tested here.

When ISO publishes version `15`, add the file, add `'15'` to
`VERIFIED_VERSIONS`, add it to `scripts/write-fixtures.mjs`, and let the tests
say what changed.
