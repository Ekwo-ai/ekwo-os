# Schemas

Kept as they were published, byte for byte, for `test/schema.test.ts` only.
The package ships none of them.

| File | Published by | URL | Read | SHA-256 |
|---|---|---|---|---|
| `SuministroInformacion.xsd` | AEAT | <https://www2.agenciatributaria.gob.es/static_files/common/internet/dep/aplicaciones/es/aeat/tikeV1.0/cont/ws/SuministroInformacion.xsd> | 2026-10-17 | `ee4c1655175644de44c4c25055ffeb8e5f4bb4bc3834ce8254d4222ef18c8aa1` |
| `SuministroLR.xsd` | AEAT | <https://www2.agenciatributaria.gob.es/static_files/common/internet/dep/aplicaciones/es/aeat/tikeV1.0/cont/ws/SuministroLR.xsd> | 2026-10-17 | `26bacfc6229d1a314758753244219ba207b2dcc8e2a22f7ab60b8ab6bae877e1` |
| `xmldsig-core-schema.xsd` | W3C | <https://www.w3.org/TR/xmldsig-core/xmldsig-core-schema.xsd> | 2026-10-17 | `d102ad3df7664c307e0c2c776ba4a90513b1969974d8a940bae1a77f9f21e15d` |

`SuministroInformacion.xsd` imports the W3C schema by its URL. The test
points that import at the copy here, in memory, so that it runs without a
network; the files themselves are not changed. `SuministroLR.xsd` wraps the
records in the message a sender posts (`RegFactuSistemaFacturacion`), which
this package does not write; it is kept so that whoever writes the envelope
validates against the same copy.
