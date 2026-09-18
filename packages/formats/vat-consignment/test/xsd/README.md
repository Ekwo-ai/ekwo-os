# The published schemas

Fixtures of `test/schema.test.ts`, and nothing else: the package ships none of
them (`files` in `package.json` lists `dist`, the README and the licence) and
reads none of them at runtime.

They are the files the SPF Finances publishes for Intervat, unmodified,
retrieved on 18 September 2026:

| File | From |
|---|---|
| `NewTVA-in_v0_9.xsd` | <https://finances.belgium.be/sites/default/files/downloads/NewTVA-in_v0_9.zip> |
| `IntervatInputCommon_v0_9.xsd` | <https://finances.belgium.be/sites/default/files/downloads/IntervatInputCommon_v0_9-20240703.zip> |
| `IntervatIsoTypes_v0_9.xsd` | <https://finances.belgium.be/sites/default/files/downloads/IntervatIsoTypes_v0_9-20240806.zip> |
| `commontypes_v1.xsd` | <https://finances.belgium.be/sites/default/files/downloads/commontypes_v1.zip> |
| `isotypes_v1.xsd` | <https://financien.belgium.be/sites/default/files/downloads/isotypes_v1.zip> |

The page that lists them:
<https://finances.belgium.be/fr/E-services/Intervat/documentation-technique>.

When the administration publishes a new version, replace the file, run the
tests, and let them say what changed — the list of grids in `src/index.ts` is
compared with the enumeration of the schema, number for number.
