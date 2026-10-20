-- Ekwo OS — the second typeface of an invoice is called `elegant`.
--
-- `20261020161000` named the pair Inter and Fraunces `gustave`, after the
-- design work it came from. A name a company picks in its settings says what
-- it looks like: `elegant`. The migration has already run on databases, so it
-- is not edited; this one renames the value where a company chose it and
-- moves the check to the new word, in one transaction.

alter table companies drop constraint if exists companies_invoice_typeface_known;

update companies set invoice_typeface = 'elegant' where invoice_typeface = 'gustave';

alter table companies
  add constraint companies_invoice_typeface_known
  check (invoice_typeface in ('classic', 'elegant'));

comment on column companies.invoice_typeface is
  'The pair of typefaces of this company''s invoice PDF, by the name @ekwo-ai/invoice-pdf embeds it under: classic (Noto Sans) or elegant (Inter, with Fraunces for the title, the names and the headings). Null is the default, classic.';
