-- Ekwo OS — a country that chains its invoices.
--
-- Many countries require the invoicing software itself to leave, for every
-- invoice it issues, a record that cannot be changed, chained to the previous
-- one by a hash, sometimes shown on the invoice as a QR code and a sentence,
-- and sent to the tax authority at once or later. A pack says so in
-- `einvoicing.fiscalisation`: the format of the record and the brick that
-- writes it, the fields the hash covers, the size of the QR code and the
-- sentence beside it, how the records are sent, how often an event summary
-- is kept, and the texts that say all of it.
--
-- One column, beside the e-invoicing profile it completes. A jsonb rather
-- than a dozen columns, because the block is read whole — by the
-- `einvoicing` module when it chains a record, by the PDF of an invoice, by
-- `describe_pack` — and its sub-objects differ from one regime to the next
-- in ways a column per field would have to guess. No country is named here
-- and none is in the shape: the pack schema (`packs/schema/pack.1.json`,
-- `$defs/fiscalisation`) is the published contract, and `ekwo pack check`
-- holds every block to it before a seed is written.
--
-- Null is a country with no such regime, which is every country until a pack
-- says otherwise. No default: there is nothing for the schema to decide.

alter table country_defaults
  add column if not exists einvoice_fiscalisation jsonb;

alter table country_defaults
  drop constraint if exists country_defaults_einvoice_fiscalisation_shape;

alter table country_defaults
  add constraint country_defaults_einvoice_fiscalisation_shape check (
    einvoice_fiscalisation is null
    or (jsonb_typeof(einvoice_fiscalisation) = 'object'
        and jsonb_typeof(einvoice_fiscalisation -> 'format') = 'string'
        and jsonb_typeof(einvoice_fiscalisation -> 'hash') = 'object'
        and jsonb_typeof(einvoice_fiscalisation -> 'submission') = 'object'
        and jsonb_typeof(einvoice_fiscalisation -> 'legal_reference') = 'string')
  );

comment on column country_defaults.einvoice_fiscalisation is
  'The fiscalisation regime of the country, as its pack declares it in einvoicing.fiscalisation and `ekwo pack build` normalises it: format (the brick that writes the record), mandatory_from (always a list of {who, from}), hash (algorithm, fields by kind of record), qr, mention, submission, events, tax_attributes, legal_reference, source. Null where the country has no such regime. Read by the einvoicing module, which keeps the chain.';
