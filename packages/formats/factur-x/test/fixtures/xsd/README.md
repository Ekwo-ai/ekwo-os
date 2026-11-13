# Factur-X schemas

The XML schemas of Factur-X 1.09 (ZUGFeRD 2.4), one folder per profile, as
FNFE-MPE and FeRD publish them with the specification. They are unmodified;
`test/xsd.test.ts` validates what `generateCiiXml` writes against them with
`xmllint`.

They are test fixtures: the published package holds `dist` only.
