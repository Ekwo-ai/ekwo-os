-- Ekwo OS — an invoice is elegant unless its company says classic.
--
-- `@ekwo-ai/invoice-pdf` now prints in its `elegant` pair when a theme names
-- no typeface, so a company whose `invoice_typeface` is null prints in Inter,
-- with Fraunces for the title, the names and the headings. Nothing in the
-- rows changes: null still means "the package's default", and only the
-- comment that names that default moves.

comment on column companies.invoice_typeface is
  'The pair of typefaces of this company''s invoice PDF, by the name @ekwo-ai/invoice-pdf embeds it under: elegant (Inter, with Fraunces for the title, the names and the headings) or classic (Noto Sans). Null is the default, elegant.';

-- What every migration of this directory ends with: a function never comes
-- out of one with the built-in default, which Supabase would publish as an
-- anonymous RPC endpoint.
revoke execute on all functions in schema public from public;
