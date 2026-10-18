-- Ekwo OS — a country that reports its invoices without chaining them.
--
-- `20261018014537` gave `country_defaults.einvoice_fiscalisation` a shape
-- check written for a regime that chains its records: a `hash` object was
-- required. Some countries require no chain, no QR code and no sentence on
-- the invoice, only that the data of the documents reach the authority —
-- a reporting regime. The pack says so by leaving `hash` out; `ekwo pack
-- build` normalises it to a null `hash` and `kind` = `reporting`.
--
-- The same check, with `hash` an object or null, and the two optional
-- members a reporting regime brings typed where they are given:
-- `announced_from` (a day only announced, with no text in force; then
-- `mandatory_from` is empty) and `kind`. The pack schema
-- (`packs/schema/pack.1.json`, `$defs/fiscalisation`) stays the contract,
-- and `ekwo pack check` holds every block to it before a seed is written.
-- No country is named here.

alter table country_defaults
  drop constraint if exists country_defaults_einvoice_fiscalisation_shape;

alter table country_defaults
  add constraint country_defaults_einvoice_fiscalisation_shape check (
    einvoice_fiscalisation is null
    or (jsonb_typeof(einvoice_fiscalisation) = 'object'
        and jsonb_typeof(einvoice_fiscalisation -> 'format') = 'string'
        and coalesce(jsonb_typeof(einvoice_fiscalisation -> 'hash'), 'null') in ('object', 'null')
        and coalesce(jsonb_typeof(einvoice_fiscalisation -> 'announced_from'), 'null') in ('string', 'null')
        and coalesce(jsonb_typeof(einvoice_fiscalisation -> 'kind'), 'null') in ('string', 'null')
        and jsonb_typeof(einvoice_fiscalisation -> 'submission') = 'object'
        and jsonb_typeof(einvoice_fiscalisation -> 'legal_reference') = 'string')
  );

comment on column country_defaults.einvoice_fiscalisation is
  'The fiscalisation regime of the country, as its pack declares it in einvoicing.fiscalisation and `ekwo pack build` normalises it: kind (chained: a record per invoice, chained by its hash; reporting: the documents'' data reported, nothing chained, hash null), format (the brick that writes the record or the report), mandatory_from (always a list of {who, from}, empty while the obligation is only announced), announced_from, announced_by, announced_on, hash, qr, mention, submission (with channel and cadence), events, reported, tax_attributes, legal_reference, source. Null where the country has no such regime. Read by the einvoicing module, which keeps the chain of a chained regime.';
