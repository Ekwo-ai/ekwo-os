-- Ekwo OS — an invoice wears the typeface of its company.
--
-- `companies.invoice_accent_color` and `.invoice_logo_position` gave a
-- company its colour and the side of its logo (`20261010160429`). The
-- typeface stayed out because a typeface is a file, and the core keeps none.
-- `@ekwo-ai/invoice-pdf` now embeds a second pair of its own and names it:
-- `gustave`, Inter for the text and the figures and Fraunces for the title,
-- the names and the headings, beside `classic`, Noto Sans everywhere. A name
-- is a fact about the company, the same for every surface that renders its
-- invoices; it goes beside the colour.
--
-- **One column, nullable.** Null is the brick's default, `classic`, for every
-- company that exists today. A name the brick does not embed is refused at
-- the write rather than at the first rendering.
--
-- **Who may write it** is who may write the company: `companies_update`,
-- `company.write`. No grant changes.

alter table companies
  add column if not exists invoice_typeface text;

alter table companies
  add constraint companies_invoice_typeface_known
  check (invoice_typeface in ('classic', 'gustave'));

comment on column companies.invoice_typeface is
  'The pair of typefaces of this company''s invoice PDF, by the name @ekwo-ai/invoice-pdf embeds it under: classic (Noto Sans) or gustave (Inter, with Fraunces for the title, the names and the headings). Null is the default, classic.';
