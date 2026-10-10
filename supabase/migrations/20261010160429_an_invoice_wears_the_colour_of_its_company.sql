-- Ekwo OS — an invoice wears the colour of the company that sends it.
--
-- `@ekwo-ai/invoice-pdf` prints every invoice in one layout and takes a small
-- theme: an accent colour and the side of the logo. Until now only the caller
-- could hand it one, so the PDF of `ekwo doc pdf`, of the MCP tool
-- `render_invoice_pdf` and of any other client came out in the brick's default
-- whoever had sent it. Which colour a company prints in is a fact about that
-- company, the same for every surface that renders its invoices; it belongs
-- beside its logo, on `companies`.
--
-- **Two columns, both nullable.** Null is the brick's default, which is the
-- answer for every company that exists today and needs no backfill. The
-- typeface of the theme stays out: it is a file, and the core keeps none.
--
-- **The same constraints the brick applies.** A colour is `#rrggbb` and a side
-- is `left` or `right`; anything else would be stored here and refused at the
-- first rendering, so it is refused at the write instead.
--
-- **Who may write it** is who may write the company: `companies_update`
-- judges the row, `company.write`. No grant changes — the table is already
-- granted, and a column added to it is covered by that grant.

alter table companies
  add column if not exists invoice_accent_color  text,
  add column if not exists invoice_logo_position text;

alter table companies
  add constraint companies_invoice_accent_color_hex
  check (invoice_accent_color ~ '^#[0-9A-Fa-f]{6}$');

alter table companies
  add constraint companies_invoice_logo_position_side
  check (invoice_logo_position in ('left', 'right'));

comment on column companies.invoice_accent_color is
  'The accent colour of this company''s invoice PDF, written #rrggbb: the title, the rules and the bands of the layout. Null is the default of @ekwo-ai/invoice-pdf.';
comment on column companies.invoice_logo_position is
  'The side of this company''s invoice PDF its logo is printed on: left or right. Null is the default of @ekwo-ai/invoice-pdf (left).';
