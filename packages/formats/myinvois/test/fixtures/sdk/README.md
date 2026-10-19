# LHDNM's samples

The samples the MyInvois SDK publishes beside each document type, downloaded
on 19 October 2026 from `https://sdk.myinvois.hasil.gov.my/files/sdksamples/<file>`
and kept unmodified. LHDNM says of them that they "provide guidance on UBL
2.1" and that taxpayers "should not rely on the example provided": their
figures do not add up and every optional field is filled. `test/sdk.test.ts`
compares the shape of what this package writes with them, not the values.

| File | Page | SHA-256 |
|---|---|---|
| `1.0-Invoice-Sample.json` | `documents/invoice-v1-0/` | `b2188342d5e955598b9b602566488512eaf67ce60e73f51eaf35949712cdc5f9` |
| `1.1-Invoice-Sample.json` | `documents/invoice-v1-1/` | `60cc77c5a4efcd482ffae09c8c447c7195b52380076dcce4fc2c77fb90b31395` |
| `1.1-Invoice-Sample.xml` | `documents/invoice-v1-1/` | `ca703b482e5daf8012000c1354773dcf6cadd75b4a3b0db3f6ebcee35c1bd44c` |
| `1.1-Credit-Note-Sample.json` | `documents/credit-v1-1/` | `df47e44dc8a60e3e85c738da98c7c16a26f3b2226dc4a6e31b123f11e02de0f8` |
| `1.1-Debit-Note-Sample.json` | `documents/debit-v1-1/` | `356f863681f00a235d835c4a02521f7836bc55a377db1ccf62445182a39157e1` |
| `1.1-Refund-Note-Sample.json` | `documents/refund-v1-1/` | `da6c268504d0ee23a4cce54fadbd82f573de4bb24b2f81ae0dac708f703c383d` |
| `1.1-Self-Billed-Invoice-Sample.json` | `documents/self-billed-invoice-v1-1/` | `d54fd101dbd2d52c5facc75fbef92413690b0ddf569fe78198a414986dee1add` |
| `1.1-Self-Billed-Credit-Sample.json` | `documents/self-billed-credit-v1-1/` | `8d1c7d5a32cfac6fbbf8cf3f9abc502c0d46e842f2a955180ec8cd6395712dee` |

The 1.1 samples carry LHDNM's example signature (`UBLExtensions`,
`Signature`), which this package does not write; the paths it does write are
all paths these samples hold.
