-- Ekwo OS — the company that sends an invoice has an address to send it from.
--
-- `contacts` has carried `peppol_scheme` and `peppol_identifier` since the
-- first day: the electronic address of the buyer, BT-49. The seller had
-- neither. BT-34 is mandatory on the network, so the first brick that wrote a
-- Peppol invoice had to be *told* the seller's address by its caller, and the
-- end-to-end test registered the company under its VAT number and said that
-- it was the test's choice. It is nobody's choice: which identifier a
-- participant is registered under is a fact of its registration with an access
-- point, and the only party that knows it is the company.
--
-- **The same two columns, under the same two names.** A scheme and a value,
-- which is the shape `docs/international.md` asks every identifier of this
-- schema to take. `peppol_` is the name `contacts` already uses and a second
-- name for the same thing would be a join somebody has to remember; the scheme
-- is a code of the Electronic Address Scheme list (EAS) that EN 16931 cites
-- for BT-34-1 and BT-49-1, whichever network delivers.
--
-- **No list of schemes.** `contacts` has none and the core gets none here: the
-- list is published by the Connecting Europe Facility, revised twice a year,
-- and differs between EN 16931 and Peppol — the brick that writes the file
-- carries both and names the rule a scheme breaks. A list here would be a
-- third copy, and the one most likely to be stale.
--
-- **One constraint `contacts` does not have: the pair is whole or absent.** A
-- scheme without an identifier addresses nobody and an identifier without a
-- scheme cannot be written at all (BR-62). The columns are new on `companies`,
-- so the check refuses nothing that exists. On `contacts` they are not, and
-- an installation may hold half a pair somebody typed in 2026; a constraint
-- added there would either refuse this migration or, `not valid`, refuse the
-- next unrelated edit of that contact. It is left for the release that can
-- look at the data first.
--
-- **Who may write it** is who may write the company: `companies_update`
-- judges the row, `company.write`, and there is nothing in an electronic
-- address that a member allowed to change the VAT number should not change.
--
-- The second half of this file corrects two comments. `party_scheme` and
-- `vat_scheme` were documented as "ISO 6523 ICD", and the packs — rightly —
-- fill them with codes of the EAS list, which contains the ICD list and more:
-- the VAT schemes of the 99xx range are not ISO 6523 identifiers at all. Read
-- as documented, `party_scheme` was taken for the scheme a registration number
-- is written in (BT-30-1) and produced BR-CL-11 for two packs out of four.

alter table companies
  add column if not exists peppol_scheme     text,
  add column if not exists peppol_identifier text;

alter table companies
  add constraint companies_electronic_address_whole
  check ((peppol_scheme is null) = (peppol_identifier is null));

comment on column companies.peppol_scheme is
  'Scheme of the electronic address this company receives and sends under (EN 16931 BT-34-1): a code of the Electronic Address Scheme list, e.g. 0088 for a GLN. A fact of the company''s registration with its access point, never derived from its VAT or registration number. Null together with peppol_identifier.';
comment on column companies.peppol_identifier is
  'The electronic address itself (EN 16931 BT-34), in the scheme peppol_scheme names.';

comment on column contacts.peppol_scheme is
  'Scheme of the electronic address this party is reached at (EN 16931 BT-49-1): a code of the Electronic Address Scheme list. A fact of the party''s registration, never derived from its VAT or registration number.';
comment on column contacts.peppol_identifier is
  'The electronic address itself (EN 16931 BT-49), in the scheme peppol_scheme names.';

comment on column country_defaults.party_scheme is
  'The Electronic Address Scheme (EAS) code under which a party of this country is usually *addressed* on the network — the scheme of an electronic address, BT-34-1 and BT-49-1. Four characters; the pack carries the value and the core never guesses one. It is a default an application may propose, not the address of anybody: that is companies.peppol_scheme and contacts.peppol_scheme. And it is not the scheme a registration number is written in (BT-30-1, BT-47-1), which has to be an ISO 6523 ICD: several EAS codes are not.';
comment on column country_defaults.vat_scheme is
  'The Electronic Address Scheme (EAS) code under which a party of this country is addressed by its VAT number, where the network allows it. Distinct from party_scheme: a company is addressed by its registration number or by its VAT number, and they are not the same identifier. Not an ISO 6523 ICD in general — the VAT schemes of the EAS list are outside that standard.';
