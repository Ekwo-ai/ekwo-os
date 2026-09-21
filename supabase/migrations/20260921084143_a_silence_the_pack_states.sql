-- Ekwo OS — a silence the pack states.
--
-- Building a page per country made every null of a pack public, and two of
-- them were not gaps at all: they were answers the format had no word for.
--
-- **A deadline that depends on the taxpayer.** France assigns the day of its
-- periodic return from the place a company files, its legal form and its
-- registration number, between the fifteenth and the twenty-fourth of the
-- month. `depends_on_taxpayer`, added by the previous file, says so; this one
-- teaches the shape constraint of `20260917170000` the third value. It carries
-- the text that assigns the day and nothing else — no day, no extension —
-- and `filing_deadline()` answers null for it, as it did before.
--
-- **An e-invoicing profile with no obligation behind it.** A pack names the
-- profile a country's operators exchange whether or not a law requires it,
-- and `einvoice_mandatory_from` null used to say both "no obligation" and "the
-- date was not read". `einvoice_obligation` tells them apart, in a closed
-- vocabulary of three words:
--
--   * `mandatory` — a statute obliges companies to issue or receive the
--     profile, from `einvoice_mandatory_from`;
--   * `on_request` — no statute obliges every company, but a seller has to
--     issue an electronic invoice when a buyer the law entitles to ask for one
--     does (Estonia since 1 July 2025). There is no day from which it binds
--     everybody, so `einvoice_mandatory_from` stays null, and the day the right
--     began is in the legal reference;
--   * `none` — at the day the pack was released, no statute obliges companies
--     to exchange electronic invoices between themselves.
--
-- An obligation that reaches only invoices addressed to the public sector, or
-- one announced and not legislated, is said in the legal reference and does
-- not change the word.
--
-- Null is a pack that says nothing, which is what every pack said until today.
-- The column has no default for that reason: there is nothing for the schema
-- to decide.

alter table tax_report_templates
  drop constraint if exists tax_report_templates_deadline_shape;

alter table tax_report_templates
  add constraint tax_report_templates_deadline_shape check (
    case deadline_rule
      when 'day_of_month_after_period'      then deadline_day between 1 and 31
      when 'last_day_of_month_after_period' then deadline_day is null
      when 'depends_on_taxpayer'            then deadline_day is null
                                                 and deadline_plus_days is null
                                                 and deadline_reference is not null
      else deadline_day is null and deadline_plus_days is null
           and deadline_reference is null and deadline_source_key is null
    end
  );

comment on column tax_report_templates.deadline_rule is
  'How the filing date follows the end of the period. depends_on_taxpayer where the law assigns the day per filer and the pack cites the text; null where the pack says nothing.';

alter table country_defaults
  add column if not exists einvoice_obligation text;

alter table country_defaults
  add constraint country_defaults_einvoice_obligation_known
    check (einvoice_obligation is null
           or einvoice_obligation in ('mandatory', 'on_request', 'none'));

alter table country_defaults
  add constraint country_defaults_einvoice_obligation_dated
    check (
      case einvoice_obligation
        when 'mandatory'  then einvoice_mandatory_from is not null
        when 'on_request' then einvoice_mandatory_from is null
        when 'none'       then einvoice_mandatory_from is null
        else true
      end
    );

comment on column country_defaults.einvoice_obligation is
  'Whether a statute obliges companies of this country to exchange electronic invoices between themselves: mandatory (from einvoice_mandatory_from), on_request (a seller has to issue one when a buyer the law entitles to ask does; no date binds everybody) or none (no such statute at the day the pack was released). An obligation towards the public sector alone is said in einvoice_legal_reference. Null where the pack says nothing.';

comment on function filing_deadline(uuid, text, date) is
  'When a period closed on this date has to be declared, under the rule the pack carries. Null where the pack declares none, and null where it declares depends_on_taxpayer — a country whose schedule depends on the filer, not a country without deadlines.';
