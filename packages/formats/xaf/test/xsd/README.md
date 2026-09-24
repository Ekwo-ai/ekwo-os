# The published schemas

Fixtures of `test/schema.test.ts`, and nothing else: the package ships none of
them (`files` in `package.json` lists `dist`, the README and the licence) and
reads none of them at runtime.

They are the schemas of the *XML Auditfile Financieel* the Dutch tax
administration publishes through its developer portal, *Ondersteuning Digitaal
Berichtenverkeer* (<https://odb.belastingdienst.nl/auditfiles/>), where the
download packages sit behind a free registration. The copies here were
retrieved on 24 September 2026 from where those packages are republished in
the open, and are not modified:

| File | Namespace | Retrieved from | SHA-256 |
|---|---|---|---|
| `XmlAuditfileFinancieel3.2.xsd` | `http://www.auditfiles.nl/XAF/3.2` | <https://github.com/BananaAccounting/Netherlands/blob/master/Auditfile_v3.2/XmlAuditfileFinancieel3.2.xsd> | `6127b3f19db2c5bcff89385b5e35e5095e984d4ddaa1e5000f4e99494a8d0fff` |
| `XmlAuditfileFinancieel4.0.xsd` | `http://www.odb.belastingdienst.nl/Belastingdienst/BCPP/1.1/structures/XmlauditfileXAF_4.0` | <https://github.com/samhoven16/boekhouding-engine/blob/main/docs/xaf/XmlAuditfileFinancieel4.0.xsd>, the file of the package *XMLAuditfile Financieel (XAF) v 4.0.3*; the test message of the same package validates against it | `f1b30dd82b22e049996f3e9b515b5f75db34268656113411f22be8a9a453607c` |

The pages of the portal that describe them, readable without an account:
[Auditfile Financieel (XAF) v 3.2.1](https://odb.belastingdienst.nl/auditfiles/auditfile-financieel-xaf-v-3-2-1/),
[XMLAuditfile Financieel (XAF) v 4.0.3](https://odb.belastingdienst.nl/auditfiles/xmlauditfile-financieel-xaf-v-4-0-3/) and
[Achtergrond informatie XAF4.0](https://odb.belastingdienst.nl/auditfiles/achtergrond-informatie-xaf4-0/).

When a version is published under a new namespace, add its schema here, add
the namespace to `XAF_NAMESPACES`, write a fixture in it, and let the tests say
what changed.
