-- Ekwo OS — a pack names the words of an invoice its law prescribes.
--
-- The words of an invoice's layout — Invoice, Bill to, Due date, Amount due —
-- are the same from one country to another, and `@ekwo-ai/invoice-pdf`
-- carries them once per language. A few are not: the law of a country names
-- them, and names them its own way. A Belgian legal person prints its
-- « numéro d'entreprise » on every invoice (Code des sociétés et des
-- associations, art. 2:20), and the French set of the layout, written once
-- for every French-speaking country, calls the same line « Numéro
-- d'immatriculation ».
--
-- A pack may now name those words in `documents.invoice_labels`, each with
-- the article that names it, and translate them in `i18n/<lang>.json` under
-- the same key. They compile into this column, by language then by key — the
-- pack's own language among the others — and a client printing a document
-- puts the pack's word for the document's language over the word of the
-- layout. A pack that names none leaves the column empty, and the layout's
-- words are printed as they were.
--
-- No function and no grant: `country_defaults` is read by every caller that
-- may read the reference data (20260922162500), and the column with it.

alter table country_defaults
  add column if not exists invoice_labels jsonb not null default '{}'::jsonb;

alter table country_defaults
  drop constraint if exists country_defaults_invoice_labels_object;

alter table country_defaults
  add constraint country_defaults_invoice_labels_object
  check (jsonb_typeof(invoice_labels) = 'object');

comment on column country_defaults.invoice_labels is
  'The words of an invoice the law of this country names (documents.invoice_labels of the pack and their translations), by language then by key of the InvoiceLabels of @ekwo-ai/invoice-pdf: {"fr": {"registrationNumber": "Numéro d''entreprise"}, "nl": {...}}. A renderer prints the word for the document''s language over the word of the layout. Empty where the pack names none.';
