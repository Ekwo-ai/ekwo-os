-- Ekwo OS — territories. The common system of VAT, and where it applies.
--
-- Reference data of the framework, like the currencies beside it, and read by
-- `ec_sales_list()` through `territory_of()`, `is_eu_member()`,
-- `eu_vat_scope_of()` and `vat_prefix_of()`. The table, the four functions and
-- the whole argument for why this is data and not code are in the migration
-- `20260915181000_territories.sql`; this file is the rows.
--
-- **It upserts, where the currencies do nothing.** A currency nobody corrects
-- can be inserted once and left alone. This list changes — a State accedes, a
-- State leaves, a territory moves from one paragraph of article 6 to another —
-- and re-applying this file has to be how that correction reaches an
-- installation that already exists, which is the rule the seed README states
-- for every country pack. So every column is written again on conflict.
--
-- Sources, in full, in the migration. In short: Council Directive 2006/112/EC,
-- articles 5, 6 and 7; the Withdrawal Agreement and the Protocol on
-- Ireland/Northern Ireland; the VIES register for the prefixes; the accession
-- treaties for the dates, cited on each row.

-- ---------------------------------------------------------------------------
-- The rows — the Member States
--
-- One row per State, with the day it became bound by the common system, which
-- is the day of its accession. The six founding States are dated 1 January
-- 1958, the day the Treaty of Rome entered into force: the common system
-- itself is younger — the first directives are of 1967 and the sixth of 1977 —
-- and dating them from 1958 says the same thing every reader of this column
-- needs, which is that nothing in a ledger this software will ever read falls
-- before the date.
-- ---------------------------------------------------------------------------

insert into territories (code, code_source, name, parent_code, eu_vat_scope, eu_vat_from, eu_vat_to, vat_prefix, legal_reference) values
  ('BE', 'iso_3166_1', 'Belgium',        null, 'full', date '1958-01-01', null, null, 'Treaty establishing the European Economic Community, Rome, 25 March 1957, in force 1 January 1958'),
  ('DE', 'iso_3166_1', 'Germany',        null, 'full', date '1958-01-01', null, null, 'Treaty establishing the European Economic Community, Rome, 25 March 1957, in force 1 January 1958'),
  ('FR', 'iso_3166_1', 'France',         null, 'full', date '1958-01-01', null, null, 'Treaty establishing the European Economic Community, Rome, 25 March 1957, in force 1 January 1958'),
  ('IT', 'iso_3166_1', 'Italy',          null, 'full', date '1958-01-01', null, null, 'Treaty establishing the European Economic Community, Rome, 25 March 1957, in force 1 January 1958'),
  ('LU', 'iso_3166_1', 'Luxembourg',     null, 'full', date '1958-01-01', null, null, 'Treaty establishing the European Economic Community, Rome, 25 March 1957, in force 1 January 1958'),
  ('NL', 'iso_3166_1', 'Netherlands',    null, 'full', date '1958-01-01', null, null, 'Treaty establishing the European Economic Community, Rome, 25 March 1957, in force 1 January 1958'),
  ('DK', 'iso_3166_1', 'Denmark',        null, 'full', date '1973-01-01', null, null, 'Treaty of Accession 1972, in force 1 January 1973'),
  ('IE', 'iso_3166_1', 'Ireland',        null, 'full', date '1973-01-01', null, null, 'Treaty of Accession 1972, in force 1 January 1973'),
  ('GR', 'iso_3166_1', 'Greece',         null, 'full', date '1981-01-01', null, 'EL', 'Treaty of Accession 1979, in force 1 January 1981; the prefix EL is the one the VIES register publishes for Greek VAT identification numbers'),
  ('ES', 'iso_3166_1', 'Spain',          null, 'full', date '1986-01-01', null, null, 'Treaty of Accession 1985, in force 1 January 1986'),
  ('PT', 'iso_3166_1', 'Portugal',       null, 'full', date '1986-01-01', null, null, 'Treaty of Accession 1985, in force 1 January 1986'),
  ('AT', 'iso_3166_1', 'Austria',        null, 'full', date '1995-01-01', null, null, 'Treaty of Accession 1994, in force 1 January 1995'),
  ('FI', 'iso_3166_1', 'Finland',        null, 'full', date '1995-01-01', null, null, 'Treaty of Accession 1994, in force 1 January 1995'),
  ('SE', 'iso_3166_1', 'Sweden',         null, 'full', date '1995-01-01', null, null, 'Treaty of Accession 1994, in force 1 January 1995'),
  ('CY', 'iso_3166_1', 'Cyprus',         null, 'full', date '2004-05-01', null, null, 'Treaty of Accession 2003, in force 1 May 2004'),
  ('CZ', 'iso_3166_1', 'Czechia',        null, 'full', date '2004-05-01', null, null, 'Treaty of Accession 2003, in force 1 May 2004'),
  ('EE', 'iso_3166_1', 'Estonia',        null, 'full', date '2004-05-01', null, null, 'Treaty of Accession 2003, in force 1 May 2004'),
  ('HU', 'iso_3166_1', 'Hungary',        null, 'full', date '2004-05-01', null, null, 'Treaty of Accession 2003, in force 1 May 2004'),
  ('LT', 'iso_3166_1', 'Lithuania',      null, 'full', date '2004-05-01', null, null, 'Treaty of Accession 2003, in force 1 May 2004'),
  ('LV', 'iso_3166_1', 'Latvia',         null, 'full', date '2004-05-01', null, null, 'Treaty of Accession 2003, in force 1 May 2004'),
  ('MT', 'iso_3166_1', 'Malta',          null, 'full', date '2004-05-01', null, null, 'Treaty of Accession 2003, in force 1 May 2004'),
  ('PL', 'iso_3166_1', 'Poland',         null, 'full', date '2004-05-01', null, null, 'Treaty of Accession 2003, in force 1 May 2004'),
  ('SI', 'iso_3166_1', 'Slovenia',       null, 'full', date '2004-05-01', null, null, 'Treaty of Accession 2003, in force 1 May 2004'),
  ('SK', 'iso_3166_1', 'Slovakia',       null, 'full', date '2004-05-01', null, null, 'Treaty of Accession 2003, in force 1 May 2004'),
  ('BG', 'iso_3166_1', 'Bulgaria',       null, 'full', date '2007-01-01', null, null, 'Treaty of Accession 2005, in force 1 January 2007'),
  ('RO', 'iso_3166_1', 'Romania',        null, 'full', date '2007-01-01', null, null, 'Treaty of Accession 2005, in force 1 January 2007'),
  ('HR', 'iso_3166_1', 'Croatia',        null, 'full', date '2013-07-01', null, null, 'Treaty of Accession 2011, in force 1 July 2013')
on conflict (code) do update set
  code_source     = excluded.code_source,
  name            = excluded.name,
  parent_code     = excluded.parent_code,
  eu_vat_scope    = excluded.eu_vat_scope,
  eu_vat_from     = excluded.eu_vat_from,
  eu_vat_to       = excluded.eu_vat_to,
  vat_prefix      = excluded.vat_prefix,
  legal_reference = excluded.legal_reference;

-- ---------------------------------------------------------------------------
-- The United Kingdom, and Northern Ireland
--
-- Two rows, not one, and the second is not a column on the first.
--
-- Northern Ireland is a territory of the United Kingdom, which is not a Member
-- State, and it is inside the common system of VAT for supplies of goods and
-- outside it for supplies of services. Its numbers carry `XI`, a prefix the
-- United Kingdom's own `GB` numbers do not share, and VIES validates them
-- separately. Everything a reader asks of a territory it asks of that one:
-- what its prefix is, whether a supply to it is intra-Community, which State
-- it belongs to. A boolean on the `GB` row — `vat_territory_of_eu_for_goods` —
-- would answer none of them: it would make the United Kingdom itself partly
-- inside the system, which is exactly wrong, and it would leave `XI` with
-- nothing to resolve to when it arrives in a VAT number.
--
-- So: a row, with `parent_code` saying whose territory it is, and the middle
-- value of `eu_vat_scope` saying how much of the system reaches it. The date
-- is 1 January 2021, the day after the transition ended, which is the first
-- day `XI` meant anything: before it, Northern Ireland was inside the system
-- because the whole United Kingdom was.
-- ---------------------------------------------------------------------------

insert into territories (code, code_source, name, parent_code, eu_vat_scope, eu_vat_from, eu_vat_to, vat_prefix, legal_reference) values
  ('GB', 'iso_3166_1', 'United Kingdom', null, 'full', date '1973-01-01', date '2020-12-31', null,
   'Treaty of Accession 1972, in force 1 January 1973. The United Kingdom ceased to be a Member State on 31 January 2020 and remained inside the common system of VAT until 31 December 2020, because articles 126 and 127 of the Withdrawal Agreement kept Union law applying through the transition period. This column records the VAT date.'),
  ('XI', 'eu',         'Northern Ireland', 'GB', 'goods', date '2021-01-01', null, null,
   'Protocol on Ireland/Northern Ireland to the Withdrawal Agreement, article 8 and annex 3, as amended by the Windsor Framework: the Union''s VAT rules on goods apply in Northern Ireland and its rules on services do not. The prefix XI is the one the VIES register publishes for it.')
on conflict (code) do update set
  code_source     = excluded.code_source,
  name            = excluded.name,
  parent_code     = excluded.parent_code,
  eu_vat_scope    = excluded.eu_vat_scope,
  eu_vat_from     = excluded.eu_vat_from,
  eu_vat_to       = excluded.eu_vat_to,
  vat_prefix      = excluded.vat_prefix,
  legal_reference = excluded.legal_reference;

-- ---------------------------------------------------------------------------
-- Territories article 7 puts inside the system
--
-- Two places that are not in the Union and where the Directive applies all the
-- same, because the article says a transaction with them is a transaction with
-- the State beside them. Both are worth a row for one reason: their VAT
-- numbers carry that State's prefix, so a customer recorded in Monaco is a
-- French customer to every form this software writes, and a reader that took
-- `MC` at face value would report an export.
-- ---------------------------------------------------------------------------

insert into territories (code, code_source, name, parent_code, eu_vat_scope, eu_vat_from, eu_vat_to, vat_prefix, legal_reference) values
  ('MC', 'iso_3166_1', 'Monaco',      'FR', 'full', date '1958-01-01', null,                 'FR',
   'Directive 2006/112/EC, article 7(1): transactions originating in or intended for the Principality of Monaco are treated as transactions originating in or intended for France'),
  ('IM', 'iso_3166_1', 'Isle of Man', 'GB', 'full', date '1973-01-01', date '2020-12-31', 'GB',
   'Directive 2006/112/EC, article 7(1): transactions originating in or intended for the Isle of Man were treated as transactions originating in or intended for the United Kingdom, which left the common system on 31 December 2020')
on conflict (code) do update set
  code_source     = excluded.code_source,
  name            = excluded.name,
  parent_code     = excluded.parent_code,
  eu_vat_scope    = excluded.eu_vat_scope,
  eu_vat_from     = excluded.eu_vat_from,
  eu_vat_to       = excluded.eu_vat_to,
  vat_prefix      = excluded.vat_prefix,
  legal_reference = excluded.legal_reference;

-- ---------------------------------------------------------------------------
-- Territories article 6 takes out of the system
--
-- The Directive does not apply to them, whether or not they are inside the
-- customs territory of the Union, and the distinction between its two
-- paragraphs is a customs one that changes nothing here — which is why the
-- column records the outcome and the `legal_reference` records the paragraph.
-- Campione d'Italia and the Italian waters of Lake Lugano moved from the
-- second paragraph to the first on 1 January 2020 and were outside the VAT
-- territory before and after, so the row carries both citations and no date.
--
-- None of them issues a VAT identification number, so `vat_prefix` is null on
-- every one: a business established in the Canary Islands that has to identify
-- for Union VAT does so in Spain, with a Spanish number.
--
-- `outside_parent_tax` is a second question about the same rows, and the
-- answer is not the same for all of them. Being outside the Union's common
-- system says nothing about the parent's own tax: French VAT still applies in
-- Guadeloupe, Martinique and Réunion, and Finnish VAT in Åland. It is true only
-- where the parent's own statute takes the territory out of its tax, and the
-- row then cites that statute beside the Directive — the Canary Islands, Ceuta
-- and Melilla for Spain, Büsingen and Heligoland for Germany, Livigno, Campione
-- d'Italia and the Italian waters of Lake Lugano for Italy. Mount Athos, French
-- Guiana, Mayotte and the Channel Islands stay false until somebody writes the
-- national text down here: a flag nobody sourced is a rule nobody can review.
--
-- The national texts, each read on the official publication on 21 September
-- 2026:
--
--   Ley 37/1992, del Impuesto sobre el Valor Añadido, texto consolidado —
--     Agencia Estatal Boletín Oficial del Estado,
--     https://www.boe.es/buscar/act.php?id=BOE-A-1992-28740 (artículo 3)
--   Umsatzsteuergesetz — Bundesministerium der Justiz, Gesetze im Internet,
--     https://www.gesetze-im-internet.de/ustg_1980/__1.html (§ 1 Absatz 2)
--   Decreto legislativo 19 gennaio 2026, n. 10, Testo unico IVA — Normattiva,
--     https://www.normattiva.it/uri-res/N2Ls?urn:nir:stato:decreto.legislativo:2026-01-19;10
--     (allegato, articolo 2, comma 1, lettera a)). Article 7 of DPR 633/1972,
--     which said the same, is shown as repealed by this decree.
-- ---------------------------------------------------------------------------

insert into territories (code, code_source, name, parent_code, eu_vat_scope, eu_vat_from, eu_vat_to, vat_prefix, outside_parent_tax, legal_reference) values
  ('GR-69',         'iso_3166_2', 'Mount Athos',                    'GR', 'none', null, null, null, false, 'Directive 2006/112/EC, article 6(1)(a)'),
  ('ES-CN',         'iso_3166_2', 'Canary Islands',                 'ES', 'none', null, null, null, true, 'Directive 2006/112/EC, article 6(1)(b); for the national tax, Ley 37/1992, del Impuesto sobre el Valor Añadido, artículo 3, apartados Uno y Dos: Canarias is excluded from the territory where Spanish VAT applies, and levies IGIC instead'),
  ('GP',            'iso_3166_1', 'Guadeloupe',                     'FR', 'none', null, null, null, false, 'Directive 2006/112/EC, article 6(1)(c), which names the French territories referred to in articles 349 and 355(1) of the Treaty on the Functioning of the European Union'),
  ('GF',            'iso_3166_1', 'French Guiana',                  'FR', 'none', null, null, null, false, 'Directive 2006/112/EC, article 6(1)(c)'),
  ('MQ',            'iso_3166_1', 'Martinique',                     'FR', 'none', null, null, null, false, 'Directive 2006/112/EC, article 6(1)(c)'),
  ('RE',            'iso_3166_1', 'Réunion',                        'FR', 'none', null, null, null, false, 'Directive 2006/112/EC, article 6(1)(c)'),
  ('YT',            'iso_3166_1', 'Mayotte',                        'FR', 'none', null, null, null, false, 'Directive 2006/112/EC, article 6(1)(c)'),
  ('MF',            'iso_3166_1', 'Saint-Martin (French part)',     'FR', 'none', null, null, null, false, 'Directive 2006/112/EC, article 6(1)(c)'),
  ('AX',            'iso_3166_1', 'Åland Islands',                  'FI', 'none', null, null, null, false, 'Directive 2006/112/EC, article 6(1)(d); Act of Accession 1994, protocol no 2 on the Åland Islands'),
  ('GG',            'iso_3166_1', 'Guernsey',                       'GB', 'none', null, null, null, false, 'Directive 2006/112/EC, article 6(1)(e), which names the Channel Islands'),
  ('JE',            'iso_3166_1', 'Jersey',                         'GB', 'none', null, null, null, false, 'Directive 2006/112/EC, article 6(1)(e), which names the Channel Islands'),
  ('IT-CAMPIONE',   'named',      'Campione d''Italia',             'IT', 'none', null, null, null, true, 'Directive 2006/112/EC, article 6(1)(f) since 1 January 2020 and article 6(2)(f) before it, the municipality having entered the customs territory of the Union under Directive (EU) 2019/475 without entering its VAT territory; for the national tax, Testo unico delle disposizioni legislative in materia di imposta sul valore aggiunto (decreto legislativo 19 gennaio 2026, n. 10), allegato, articolo 2, comma 1, lettera a), in force since 31 January 2026 and carrying over article 7, comma 1, lettera a) of DPR 26 ottobre 1972, n. 633, which it repealed: the territory of the State for Italian VAT excludes the municipality of Campione d''Italia'),
  ('IT-LUGANO',     'named',      'Italian waters of Lake Lugano',  'IT', 'none', null, null, null, true, 'Directive 2006/112/EC, article 6(1)(g) since 1 January 2020 and article 6(2)(g) before it, under Directive (EU) 2019/475; for the national tax, Testo unico delle disposizioni legislative in materia di imposta sul valore aggiunto (decreto legislativo 19 gennaio 2026, n. 10), allegato, articolo 2, comma 1, lettera a), in force since 31 January 2026 and carrying over article 7, comma 1, lettera a) of DPR 26 ottobre 1972, n. 633, which it repealed: the territory of the State for Italian VAT excludes the national waters of Lake Lugano'),
  ('DE-HELIGOLAND', 'named',      'Island of Heligoland',           'DE', 'none', null, null, null, true, 'Directive 2006/112/EC, article 6(2)(a); for the national tax, Umsatzsteuergesetz, § 1 Absatz 2 Satz 1: the Inland of German VAT is the territory of the Federal Republic except the island of Heligoland'),
  ('DE-BUSINGEN',   'named',      'Territory of Büsingen',          'DE', 'none', null, null, null, true, 'Directive 2006/112/EC, article 6(2)(b); for the national tax, Umsatzsteuergesetz, § 1 Absatz 2 Satz 1: the Inland of German VAT is the territory of the Federal Republic except the territory of Büsingen'),
  ('ES-CE',         'iso_3166_2', 'Ceuta',                          'ES', 'none', null, null, null, true, 'Directive 2006/112/EC, article 6(2)(c); for the national tax, Ley 37/1992, del Impuesto sobre el Valor Añadido, artículo 3, apartados Uno y Dos: Ceuta is excluded from the territory where Spanish VAT applies, and levies IPSI instead'),
  ('ES-ML',         'iso_3166_2', 'Melilla',                        'ES', 'none', null, null, null, true, 'Directive 2006/112/EC, article 6(2)(d); for the national tax, Ley 37/1992, del Impuesto sobre el Valor Añadido, artículo 3, apartados Uno y Dos: Melilla is excluded from the territory where Spanish VAT applies, and levies IPSI instead'),
  ('IT-LIVIGNO',    'named',      'Livigno',                        'IT', 'none', null, null, null, true, 'Directive 2006/112/EC, article 6(2)(e); for the national tax, Testo unico delle disposizioni legislative in materia di imposta sul valore aggiunto (decreto legislativo 19 gennaio 2026, n. 10), allegato, articolo 2, comma 1, lettera a), in force since 31 January 2026 and carrying over article 7, comma 1, lettera a) of DPR 26 ottobre 1972, n. 633, which it repealed: the territory of the State for Italian VAT excludes the municipality of Livigno')
on conflict (code) do update set
  code_source     = excluded.code_source,
  name            = excluded.name,
  parent_code     = excluded.parent_code,
  eu_vat_scope    = excluded.eu_vat_scope,
  eu_vat_from     = excluded.eu_vat_from,
  eu_vat_to       = excluded.eu_vat_to,
  vat_prefix      = excluded.vat_prefix,
  outside_parent_tax = excluded.outside_parent_tax,
  legal_reference = excluded.legal_reference;

-- ---------------------------------------------------------------------------
-- Third countries a pack of this repository keeps books in
--
-- A country outside the common system of VAT has to be *in* this table, and
-- saying nothing about it is not the same as saying no. `eu_vat_scope_of()`
-- answers `none` for a code it does not carry, which is the right answer to
-- the question the recapitulative statement asks — a supply to a place the
-- Union has never heard of is not an intra-Community one. It is the wrong
-- answer to the question `ekwo pack check` asks, which is whether the VATEX
-- code list of EN 16931 reaches a pack at all: there, a missing row is read as
-- "unknown" and the pack is held to the Union's table, so a pack for a country
-- with no row would be refused for leaving `exemption_code` empty on an exempt
-- line, and told to write a code that names an article of a Directive its
-- seller is not bound by. `tests/territories.test.ts` already refuses a pack
-- whose country this table does not carry, for the same reason from the other
-- side.
--
-- So a country a pack books in gets a row here, whether or not the Union's law
-- has anything to say about it. The scope is `none` and the window is empty,
-- which the `territories_scope_matches_window` constraint requires of each
-- other: the common system has never reached it and there is no date on which
-- it started or stopped. `vat_prefix` is null because there is no VAT
-- identification number to prefix — the United States levies no value added
-- tax at any level of government.
-- ---------------------------------------------------------------------------

insert into territories (code, code_source, name, parent_code, eu_vat_scope, eu_vat_from, eu_vat_to, vat_prefix, legal_reference) values
  ('US', 'iso_3166_1', 'United States of America', null, 'none', null, null, null,
   'Directive 2006/112/EC, article 5(2): the common system of VAT applies in the territory of the Community as defined by the Treaties, and a State outside it is a third country for every rule the Directive carries. The United States has never been inside the system and levies no value added tax of its own at any level of government: what its states levy is a retail sales tax and a compensating use tax, which no Union instrument reaches.')
on conflict (code) do update set
  code_source     = excluded.code_source,
  name            = excluded.name,
  parent_code     = excluded.parent_code,
  eu_vat_scope    = excluded.eu_vat_scope,
  eu_vat_from     = excluded.eu_vat_from,
  eu_vat_to       = excluded.eu_vat_to,
  vat_prefix      = excluded.vat_prefix,
  legal_reference = excluded.legal_reference;

-- ---------------------------------------------------------------------------
-- The territories a pack conditions a tax on
--
-- The rule above is the common system of VAT: the Member States, the United
-- Kingdom, Northern Ireland, the territories articles 6 and 7 take out or put
-- in, and a third country a pack books in. A tax that names a territory is a
-- second reason for a row, and so is a territory a document says a supply took
-- place in. Both are a different reason from the first — `US-CA` has nothing to
-- do with Directive 2006/112/EC and never will.
--
-- It is the same table all the same, and it is the same table for the reason
-- the first rule gives: a territory code is only useful if a reader can look
-- it up, and `taxes.applies_*_territory` is a foreign key precisely so that no
-- pack can invent a place. `jurisdiction` has been a free string since the day
-- it was added and nothing has ever read it; that is what this fixes.
--
-- So the rule the table holds is now two rules, and every row says which of
-- them put it there:
--
--   1. **The common system of VAT** — where it applies and where it does not.
--      The rows above, and the third countries a pack books in.
--   2. **A territory a pack conditions a tax on, or delivers to.** The rows
--      below — `documents.supply_territory_code` is a foreign key too, so a
--      destination a scenario names is a row like any other. They carry
--      `eu_vat_scope = 'none'` and no window, which is what the constraint
--      requires of a place the Union's law has never reached, and their
--      `parent_code` is the State they belong to, which is what lets a
--      condition naming that State reach them.
--
-- The list therefore grows with the packs, and it grows by a handful of rows
-- and not by fifty: `packs/us/` declares three states because three states is
-- what its codes cover. `docs/international.md` already records that a pack of
-- a third country adds a row here before anything else; this is the same
-- sentence with a second clause.
--
-- The dividing line is worth stating, because it is the one somebody will be
-- tempted to cross. This table says **where a body of tax law applies**. It
-- says nothing about what that law charges, which is a pack's business: no
-- rate, no threshold, no registration, and no district. The City of Oakland
-- levies a combined 10.75 per cent and has no row here — `US-CA-S-1075` is a
-- Californian tax at a Californian place of supply, and which city inside
-- California is a question this table has never answered for any country.
-- ---------------------------------------------------------------------------

insert into territories (code, code_source, name, parent_code, eu_vat_scope, eu_vat_from, eu_vat_to, vat_prefix, legal_reference) values
  ('US-CA', 'iso_3166_2', 'California', 'US', 'none', null, null, null,
   'ISO 3166-2:US for the code. California Revenue and Taxation Code, sections 6051 and 6201, which impose the sales tax on a retailer''s gross receipts and the use tax on the storage, use or other consumption of tangible personal property in this State — the two statutes that make California a taxing territory of its own inside a country that levies no tax at all at federal level. Outside the common system of VAT with its parent, under Directive 2006/112/EC, article 5(2).'),
  ('US-NY', 'iso_3166_2', 'New York',   'US', 'none', null, null, null,
   'ISO 3166-2:US for the code. New York Tax Law, article 28, section 1105, which imposes the sales tax on receipts from every retail sale of tangible personal property, and section 1210, under which a city or county may impose a tax of its own on the same receipts. Outside the common system of VAT with its parent, under Directive 2006/112/EC, article 5(2).'),
  ('US-AZ', 'iso_3166_2', 'Arizona',    'US', 'none', null, null, null,
   'ISO 3166-2:US for the code. Arizona Revised Statutes, title 42, chapter 5, article 1, which levies the transaction privilege tax on the gross proceeds of a retail business, and section 42-5155, which levies the use tax on tangible personal property purchased from a retailer for storage, use or consumption in this State. No tax of this repository is levied here: the row exists because a Californian sale shipped to Phoenix has to be able to say where the goods went. Outside the common system of VAT with its parent, under Directive 2006/112/EC, article 5(2).'),
  ('US-OR', 'iso_3166_2', 'Oregon',     'US', 'none', null, null, null,
   'ISO 3166-2:US for the code. Oregon imposes no general sales or use tax: no chapter of the Oregon Revised Statutes levies one, and article IX, section 1a of the Oregon Constitution, with the six rejections of a sales tax put to the electorate since 1933, is why. A territory with no tax is a territory all the same — it is what says that a delivery there carries none. Outside the common system of VAT with its parent, under Directive 2006/112/EC, article 5(2).')
on conflict (code) do update set
  code_source     = excluded.code_source,
  name            = excluded.name,
  parent_code     = excluded.parent_code,
  eu_vat_scope    = excluded.eu_vat_scope,
  eu_vat_from     = excluded.eu_vat_from,
  eu_vat_to       = excluded.eu_vat_to,
  vat_prefix      = excluded.vat_prefix,
  legal_reference = excluded.legal_reference;


-- ---------------------------------------------------------------------------
-- The rows — the member States of OHADA
--
-- Seventeen States keep their books on one chart of accounts, the SYSCOHADA
-- révisé, and each levies a tax of its own under its own code — harmonised,
-- for eight of them, by a directive of the West African Economic and Monetary
-- Union (UEMOA) and, for six, by one of the Central African Economic and
-- Monetary Community (CEMAC), two common systems different from the Union's
-- and ones this table has no column for. Guinea, the Comoros and the
-- Democratic Republic of the Congo belong to neither. What this table says of
-- them is only what it says of the United States: the common system of VAT of
-- Directive 2006/112/EC does not reach them.
--
-- All seventeen are here, ahead of their packs, so that a member pack is its
-- own folder and nothing else. The article each row cites is the one that sets
-- the country's rates; the pack itself, and not this row, is where the rates
-- are.
-- ---------------------------------------------------------------------------

insert into territories (code, code_source, name, parent_code, eu_vat_scope, eu_vat_from, eu_vat_to, vat_prefix, legal_reference) values
  ('CI', 'iso_3166_1', 'Côte d''Ivoire', null, 'none', null, null, null,
   'Directive 2006/112/EC, article 5(2): the common system of VAT applies in the territory of the Community as defined by the Treaties, and a State outside it is a third country for every rule the Directive carries. Côte d''Ivoire levies a value added tax of its own under its Code général des impôts, whose article 359 sets its rates, harmonised within the West African Economic and Monetary Union by Directive n° 02/98/CM/UEMOA as amended by Directive n° 02/2009/CM/UEMOA.'),
  ('SN', 'iso_3166_1', 'Senegal',       null, 'none', null, null, null,
   'Directive 2006/112/EC, article 5(2): the common system of VAT applies in the territory of the Community as defined by the Treaties, and a State outside it is a third country for every rule the Directive carries. Senegal levies a value added tax of its own under its Code général des impôts (loi n° 2012-31 du 31 décembre 2012), whose article 369 sets its rates, harmonised within the West African Economic and Monetary Union by Directive n° 02/98/CM/UEMOA as amended by Directive n° 02/2009/CM/UEMOA.'),
  ('BJ', 'iso_3166_1', 'Benin',         null, 'none', null, null, null,
   'Directive 2006/112/EC, article 5(2): the common system of VAT applies in the territory of the Community as defined by the Treaties, and a State outside it is a third country for every rule the Directive carries. Benin levies a value added tax of its own under its Code général des impôts (loi n° 2021-15 du 23 décembre 2021), whose article 241 sets its rate, harmonised within the West African Economic and Monetary Union by Directive n° 02/98/CM/UEMOA as amended by Directive n° 02/2009/CM/UEMOA.'),
  ('BF', 'iso_3166_1', 'Burkina Faso',  null, 'none', null, null, null,
   'Directive 2006/112/EC, article 5(2): the common system of VAT applies in the territory of the Community as defined by the Treaties, and a State outside it is a third country for every rule the Directive carries. Burkina Faso levies a value added tax of its own under its Code général des impôts (loi n° 058-2017/AN du 20 décembre 2017), whose article 317 sets its rates, harmonised within the West African Economic and Monetary Union by Directive n° 02/98/CM/UEMOA as amended by Directive n° 02/2009/CM/UEMOA.'),
  ('CM', 'iso_3166_1', 'Cameroon',      null, 'none', null, null, null,
   'Directive 2006/112/EC, article 5(2): the common system of VAT applies in the territory of the Community as defined by the Treaties, and a State outside it is a third country for every rule the Directive carries. Cameroon levies a value added tax of its own under its Code général des impôts, whose article 142 sets its rates (the communal additional centimes of articles C 82 and C 83 of its book on local taxation are levied on top of them), harmonised within the Central African Economic and Monetary Community by Directive n° 11/22-CEMAC-UEAC-010A-CM-38 of 10 November 2022.'),
  ('CF', 'iso_3166_1', 'Central African Republic', null, 'none', null, null, null,
   'Directive 2006/112/EC, article 5(2): the common system of VAT applies in the territory of the Community as defined by the Treaties, and a State outside it is a third country for every rule the Directive carries. The Central African Republic levies a value added tax of its own under its Code général des impôts, whose article 257 sets its rates, harmonised within the Central African Economic and Monetary Community by Directive n° 11/22-CEMAC-UEAC-010A-CM-38 of 10 November 2022.'),
  ('KM', 'iso_3166_1', 'Comoros',       null, 'none', null, null, null,
   'Directive 2006/112/EC, article 5(2): the common system of VAT applies in the territory of the Community as defined by the Treaties, and a State outside it is a third country for every rule the Directive carries. The Comoros levy no value added tax: their Code général des impôts levies a taxe sur la consommation, defined at article 139, whose article 152 sets its rates. They belong to neither West African nor Central African monetary union.'),
  ('CG', 'iso_3166_1', 'Congo',         null, 'none', null, null, null,
   'Directive 2006/112/EC, article 5(2): the common system of VAT applies in the territory of the Community as defined by the Treaties, and a State outside it is a third country for every rule the Directive carries. The Congo levies a value added tax of its own under loi n° 12-97 du 12 mai 1997, outside its Code général des impôts, whose article 17 sets its rate (article 37 keeps additional centimes on top of it), harmonised within the Central African Economic and Monetary Community by Directive n° 11/22-CEMAC-UEAC-010A-CM-38 of 10 November 2022.'),
  ('CD', 'iso_3166_1', 'Democratic Republic of the Congo', null, 'none', null, null, null,
   'Directive 2006/112/EC, article 5(2): the common system of VAT applies in the territory of the Community as defined by the Treaties, and a State outside it is a third country for every rule the Directive carries. The Democratic Republic of the Congo levies a value added tax of its own under ordonnance-loi n° 10/001 du 20 août 2010, whose article 35 sets its rates. It belongs to neither West African nor Central African monetary union.'),
  ('GQ', 'iso_3166_1', 'Equatorial Guinea', null, 'none', null, null, null,
   'Directive 2006/112/EC, article 5(2): the common system of VAT applies in the territory of the Community as defined by the Treaties, and a State outside it is a third country for every rule the Directive carries. Equatorial Guinea levies a value added tax of its own (impuesto sobre el valor añadido) under Ley 1/2024 General Tributaria, whose article 155 sets its rates, harmonised within the Central African Economic and Monetary Community by Directive n° 11/22-CEMAC-UEAC-010A-CM-38 of 10 November 2022.'),
  ('GA', 'iso_3166_1', 'Gabon',         null, 'none', null, null, null,
   'Directive 2006/112/EC, article 5(2): the common system of VAT applies in the territory of the Community as defined by the Treaties, and a State outside it is a third country for every rule the Directive carries. Gabon levies a value added tax of its own under its Code général des impôts, whose article 221 sets its rates, harmonised within the Central African Economic and Monetary Community by Directive n° 11/22-CEMAC-UEAC-010A-CM-38 of 10 November 2022.'),
  ('GN', 'iso_3166_1', 'Guinea',        null, 'none', null, null, null,
   'Directive 2006/112/EC, article 5(2): the common system of VAT applies in the territory of the Community as defined by the Treaties, and a State outside it is a third country for every rule the Directive carries. Guinea levies a value added tax of its own under its Code général des impôts (loi L/2021/032/AN du 4 juillet 2021), whose article 373 sets its rates. It belongs to neither West African nor Central African monetary union.'),
  ('GW', 'iso_3166_1', 'Guinea-Bissau', null, 'none', null, null, null,
   'Directive 2006/112/EC, article 5(2): the common system of VAT applies in the territory of the Community as defined by the Treaties, and a State outside it is a third country for every rule the Directive carries. Guinea-Bissau levies a value added tax of its own (imposto sobre o valor acrescentado) under its Código do IVA (Lei n.º 4/2022), whose article 18 sets its rates, harmonised within the West African Economic and Monetary Union by Directive n° 02/98/CM/UEMOA as amended by Directive n° 02/2009/CM/UEMOA.'),
  ('ML', 'iso_3166_1', 'Mali',          null, 'none', null, null, null,
   'Directive 2006/112/EC, article 5(2): the common system of VAT applies in the territory of the Community as defined by the Treaties, and a State outside it is a third country for every rule the Directive carries. Mali levies a value added tax of its own under its Code général des impôts (loi n° 11-078), whose article 229 sets its rates, harmonised within the West African Economic and Monetary Union by Directive n° 02/98/CM/UEMOA as amended by Directive n° 02/2009/CM/UEMOA.'),
  ('NE', 'iso_3166_1', 'Niger',         null, 'none', null, null, null,
   'Directive 2006/112/EC, article 5(2): the common system of VAT applies in the territory of the Community as defined by the Treaties, and a State outside it is a third country for every rule the Directive carries. Niger levies a value added tax of its own under its Code général des impôts (ordonnance n° 2025-22 du 14 juillet 2025, in force since 1 January 2026, succeeding the code of 2012 whose article 226 set the rates), harmonised within the West African Economic and Monetary Union by Directive n° 02/98/CM/UEMOA as amended by Directive n° 02/2009/CM/UEMOA.'),
  ('TD', 'iso_3166_1', 'Chad',          null, 'none', null, null, null,
   'Directive 2006/112/EC, article 5(2): the common system of VAT applies in the territory of the Community as defined by the Treaties, and a State outside it is a third country for every rule the Directive carries. Chad levies a value added tax of its own under its Code général des impôts, whose article 238 sets its rates (provincial and communal additional centimes are levied on top of them), harmonised within the Central African Economic and Monetary Community by Directive n° 11/22-CEMAC-UEAC-010A-CM-38 of 10 November 2022.'),
  ('TG', 'iso_3166_1', 'Togo',          null, 'none', null, null, null,
   'Directive 2006/112/EC, article 5(2): the common system of VAT applies in the territory of the Community as defined by the Treaties, and a State outside it is a third country for every rule the Directive carries. Togo levies a value added tax of its own under its Code général des impôts (loi n° 2018-024 du 20 novembre 2018), whose article 195 sets its rate, harmonised within the West African Economic and Monetary Union by Directive n° 02/98/CM/UEMOA as amended by Directive n° 02/2009/CM/UEMOA.')
on conflict (code) do update set
  code_source     = excluded.code_source,
  name            = excluded.name,
  parent_code     = excluded.parent_code,
  eu_vat_scope    = excluded.eu_vat_scope,
  eu_vat_from     = excluded.eu_vat_from,
  eu_vat_to       = excluded.eu_vat_to,
  vat_prefix      = excluded.vat_prefix,
  legal_reference = excluded.legal_reference;


-- ---------------------------------------------------------------------------
-- The rows — Latin America
--
-- A State of the Americas levies a value added tax of its own, and the common
-- system of VAT of Directive 2006/112/EC does not reach it: what this table
-- says of it is what it says of the United States. A row per State, added
-- with its pack.
-- ---------------------------------------------------------------------------

insert into territories (code, code_source, name, parent_code, eu_vat_scope, eu_vat_from, eu_vat_to, vat_prefix, legal_reference) values
  ('MX', 'iso_3166_1', 'Mexico', null, 'none', null, null, null,
   'Directive 2006/112/EC, article 5(2): the common system of VAT applies in the territory of the Community as defined by the Treaties, and a State outside it is a third country for every rule the Directive carries. Mexico levies a value added tax of its own under the Ley del Impuesto al Valor Agregado, whose article 1o. sets the general rate.')
on conflict (code) do update set
  code_source     = excluded.code_source,
  name            = excluded.name,
  parent_code     = excluded.parent_code,
  eu_vat_scope    = excluded.eu_vat_scope,
  eu_vat_from     = excluded.eu_vat_from,
  eu_vat_to       = excluded.eu_vat_to,
  vat_prefix      = excluded.vat_prefix,
  legal_reference = excluded.legal_reference;


-- ---------------------------------------------------------------------------
-- The rows — Australia
--
-- The first territory of Oceania. Australia levies a goods and services tax,
-- which is a value added tax under another name: charged by the supplier,
-- credited to a registered buyer, declared on one form. No Union instrument
-- reaches it, so what this table says of it is what it says of the United
-- States. `vat_prefix` is null because an Australian registration is an
-- Australian Business Number, which carries no country prefix.
-- ---------------------------------------------------------------------------

insert into territories (code, code_source, name, parent_code, eu_vat_scope, eu_vat_from, eu_vat_to, vat_prefix, legal_reference) values
  ('AU', 'iso_3166_1', 'Australia', null, 'none', null, null, null,
   'Directive 2006/112/EC, article 5(2): the common system of VAT applies in the territory of the Community as defined by the Treaties, and a State outside it is a third country for every rule the Directive carries. Australia levies a goods and services tax of its own under the A New Tax System (Goods and Services Tax) Act 1999, whose section 9-70 sets it at 10 % of the value of a taxable supply.')
on conflict (code) do update set
  code_source     = excluded.code_source,
  name            = excluded.name,
  parent_code     = excluded.parent_code,
  eu_vat_scope    = excluded.eu_vat_scope,
  eu_vat_from     = excluded.eu_vat_from,
  eu_vat_to       = excluded.eu_vat_to,
  vat_prefix      = excluded.vat_prefix,
  legal_reference = excluded.legal_reference;


-- ---------------------------------------------------------------------------
-- The rows — Singapore
--
-- The first territory of Asia. Singapore levies a goods and services tax,
-- which is a value added tax under another name: charged by the supplier,
-- credited to a registered buyer, declared on one form, GST F5. No Union
-- instrument reaches it. `vat_prefix` is null because a Singapore GST
-- registration number is the entity's UEN or an M-prefixed number, neither of
-- which carries a country prefix.
-- ---------------------------------------------------------------------------

insert into territories (code, code_source, name, parent_code, eu_vat_scope, eu_vat_from, eu_vat_to, vat_prefix, legal_reference) values
  ('SG', 'iso_3166_1', 'Singapore', null, 'none', null, null, null,
   'Directive 2006/112/EC, article 5(2): the common system of VAT applies in the territory of the Community as defined by the Treaties, and a State outside it is a third country for every rule the Directive carries. Singapore levies a goods and services tax of its own under the Goods and Services Tax Act 1993, whose section 16 sets the rate at 9 % from 1 January 2024.')


-- ---------------------------------------------------------------------------
-- The rows — Japan
--
-- Japan levies a consumption tax, which is a value added tax under another
-- name: charged by the supplier, deducted by a taxable buyer who holds a
-- qualified invoice, declared on one return. No Union instrument reaches it,
-- so what this table says of it is what it says of the United States.
-- `vat_prefix` is null because a Japanese registration number is T and
-- thirteen digits, with no country prefix.
-- ---------------------------------------------------------------------------

insert into territories (code, code_source, name, parent_code, eu_vat_scope, eu_vat_from, eu_vat_to, vat_prefix, legal_reference) values
  ('JP', 'iso_3166_1', 'Japan', null, 'none', null, null, null,
   'Directive 2006/112/EC, article 5(2): the common system of VAT applies in the territory of the Community as defined by the Treaties, and a State outside it is a third country for every rule the Directive carries. Japan levies a consumption tax of its own under the 消費税法 (Act No. 108 of 1988), whose article 29 sets the national rate, and a local consumption tax under article 72-83 of the 地方税法.')
on conflict (code) do update set
  code_source     = excluded.code_source,
  name            = excluded.name,
  parent_code     = excluded.parent_code,
  eu_vat_scope    = excluded.eu_vat_scope,
  eu_vat_from     = excluded.eu_vat_from,
  eu_vat_to       = excluded.eu_vat_to,
  vat_prefix      = excluded.vat_prefix,
  legal_reference = excluded.legal_reference;


-- ---------------------------------------------------------------------------
-- The rows — New Zealand
--
-- The second territory of Oceania, read beside Australia's row above: a goods
-- and services tax of its own, charged by the supplier, credited to a
-- registered buyer, declared on one form, under no Union instrument. NZBN, the
-- registration a New Zealand business is addressed by, carries no country
-- prefix, so `vat_prefix` is null here too.
-- ---------------------------------------------------------------------------

insert into territories (code, code_source, name, parent_code, eu_vat_scope, eu_vat_from, eu_vat_to, vat_prefix, legal_reference) values
  ('NZ', 'iso_3166_1', 'New Zealand', null, 'none', null, null, null,
   'Directive 2006/112/EC, article 5(2): the common system of VAT applies in the territory of the Community as defined by the Treaties, and a State outside it is a third country for every rule the Directive carries. New Zealand levies a goods and services tax of its own under the Goods and Services Tax Act 1985, whose section 8(1) charges it, currently at 15 % of the value of a taxable supply since 1 October 2010 (Inland Revenue, GST guide IR375). The exact subsection that fixes the rate figure itself was not read against the operative text of the Act in this session — legislation.govt.nz refused every automated request made of it — so packs/nz/README.md carries the fuller caveat; this row states only what packs/nz/pack.json also states with that caveat attached.')
on conflict (code) do update set
  code_source     = excluded.code_source,
  name            = excluded.name,
  parent_code     = excluded.parent_code,
  eu_vat_scope    = excluded.eu_vat_scope,
  eu_vat_from     = excluded.eu_vat_from,
  eu_vat_to       = excluded.eu_vat_to,
  vat_prefix      = excluded.vat_prefix,
  legal_reference = excluded.legal_reference;
