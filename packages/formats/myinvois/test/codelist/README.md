# The code tables

The JSON files here are the ones LHDNM publishes with the MyInvois SDK, one
beside each page of <https://sdk.myinvois.hasil.gov.my/codes/>, downloaded on
19 October 2026 from `https://sdk.myinvois.hasil.gov.my/files/<file>` and kept
unmodified. `scripts/build-codelists.mjs` compiles them into
`src/codelists.ts`; `test/codelists.test.ts` reads them again and compares.

| File | Page | SHA-256 |
|---|---|---|
| `EInvoiceTypes.json` | `codes/e-invoice-types/` | `bb8a2017a428774f24938b16c06c997c4b57fdc3f96bdb238eb36debe77d744b` |
| `TaxTypes.json` | `codes/tax-types/` | `11f0d04503c92f80d58481ea1a370289268032ab77c25016d087e23aa8bd3ecb` |
| `ClassificationCodes.json` | `codes/classification-codes/` | `c4b84d4bf0f6a114d1fd0e796b2ea5cc1b232cdccc9dd2d73efdd197c61ef0c0` |
| `MSICSubCategoryCodes.json` | `codes/msic-codes/` | `f4eb6c83d0e20a5763c85c13e07253f78532fe841dcaff5b58eccc88a99e8f1e` |
| `StateCodes.json` | `codes/state-codes/` | `894b18efc92267504b337f361687b1c84f97e3e9b6a81881bfad24e9637de039` |
| `CountryCodes.json` | `codes/countries/` | `bd8127c58cbbd649ce5e7944ef65112364da394533ce01564285ab27eaca7857` |
| `CurrencyCodes.json` | `codes/currencies/` | `7bf277a9cad98216516e420387da690ffdeb2a8bf1e0ef53510f3e5439f90ff5` |
| `UnitTypes.json` | `codes/unit-types/` | `c8698d02a4f5a100a582ba2adb036e1873956b286b7d4d3b659b6a45ae03c6ca` |
| `PaymentMethods.json` | `codes/payment-methods/` | `bf557413b1cdd2747856ca4ec98cc1db72bcd30f3d7fca1a30cf3a98aed7f16c` |

`m49-iso-alpha.csv` is not LHDNM's. It is the columns "ISO-alpha2 Code",
"ISO-alpha3 Code" and "Country or Area" of the table `downloadTableEN` of the
UN Statistics Division's page *Standard country or area codes for statistical
use (M49)*, <https://unstats.un.org/unsd/methodology/m49/overview/>, read on
19 October 2026: every row with a two-letter code, sorted by it. The page is
an HTML table and not a file, so this extract is what is kept.
