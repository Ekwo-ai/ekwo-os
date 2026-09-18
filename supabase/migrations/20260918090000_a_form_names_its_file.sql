-- Ekwo OS — a form names the file it is deposited as.
--
-- Seven bricks write legal files today and not one of them writes a periodic
-- VAT return: `intra-consignment`, `des`, `vd` and `ecdf` carry recapitulative
-- statements, `xbrl-cbso` the annual accounts, `fec` and `factur-x` are
-- neither. The declaration a company actually files every month — the one D1
-- freezes and D4 settles — existed here as figures and never as a file.
--
-- `@ekwo-ai/vat-consignment` is the first, for the XML Intervat takes. This
-- column is what says a form has one, and it is a **name of a format** and not
-- of a country: the day two countries deposit the same shape of file, they
-- name the same brick, and the day one country changes form it names another.
--
-- Null is the ordinary answer, for now and on purpose. A form nobody can write
-- is still a form a company files by hand on a portal, and a column that had
-- to be filled would be filled with something invented.
--
-- What is not here: **the guard that refuses a pack naming a format nobody can
-- write.** It belongs with the one owed to `bank_statement_formats` and
-- `payment_formats`, which are declared with no reader for the same reason,
-- and it is one guard over the three of them rather than three.

alter table tax_report_templates
  add column if not exists file_format text;

comment on column tax_report_templates.file_format is
  'The file this form is deposited as, by the name of the brick that writes it — vat-consignment for the Belgian XML Intervat takes. Named after the format and never after the country. Null where no brick writes the form, which is most of them: filing by hand on a portal is how it is done until one exists.';
