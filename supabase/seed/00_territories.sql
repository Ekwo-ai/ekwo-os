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

insert into territories (code, code_source, name, parent_code, eu_vat_scope, eu_vat_from, eu_vat_to, vat_prefix, legal_reference) values
  ('CH', 'iso_3166_1', 'Switzerland', null, 'none', null, null, null,
   'Directive 2006/112/EC, article 5(2): a State outside the territory of the Community as defined by the Treaties is a third country for every rule the Directive carries, and Switzerland has never acceded to the Union or to its common system of VAT. It levies its own federal value added tax under the Bundesgesetz uber die Mehrwertsteuer (MWSTG) of 12 June 2009 (SR 641.20), administered by the Eidgenossische Steuerverwaltung (ESTV) and unrelated to the Directive; vat_prefix is null because a Swiss UID/MWST number (CHE-xxx.xxx.xxx) is never validated against VIES, which is a register of the common system Switzerland is not part of.')
on conflict (code) do update set
  code_source     = excluded.code_source,
  name            = excluded.name,
  parent_code     = excluded.parent_code,
  eu_vat_scope    = excluded.eu_vat_scope,
  eu_vat_from     = excluded.eu_vat_from,
  eu_vat_to       = excluded.eu_vat_to,
  vat_prefix      = excluded.vat_prefix,
  legal_reference = excluded.legal_reference;

insert into territories (code, code_source, name, parent_code, eu_vat_scope, eu_vat_from, eu_vat_to, vat_prefix, legal_reference) values
  ('IS', 'iso_3166_1', 'Iceland', null, 'none', null, null, null,
   'Directive 2006/112/EC, article 5(2): a State outside the territory of the Community as defined by the Treaties is a third country for every rule the Directive carries. Iceland is a member of the European Free Trade Association and of the European Economic Area (Agreement on the European Economic Area, Porto, 2 May 1992, in force 1 January 1994), which extends the internal market''s four freedoms and, through it, the Union''s accounting directives, but Annex IX of the EEA Agreement does not carry the common system of VAT: Iceland has never acceded to the Union and levies its own virðisaukaskattur (VSK) under lög um virðisaukaskatt nr. 50/1988, administered by Skatturinn (Ríkisskattstjóri) and unrelated to Directive 2006/112/EC. vat_prefix is null because an Icelandic VSK number is never validated against VIES, which is a register of the common system Iceland is not part of.')
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

-- Portugal's two autonomous regions are not a case of the common system
-- stopping short, the way Ceuta or the Canary Islands are: Directive
-- 2006/112/EC reaches the Azores and Madeira exactly as it reaches the
-- mainland (eu_vat_scope 'full', no outside_parent_tax), and both file under
-- the same tax as the mainland does, IVA. The row exists because the CIVA
-- itself carries a rate the mainland one does not: article 18(3) lets the
-- legislative assembly of each region set reduced rates of its own, under the
-- Lei das Finanças das Regiões Autónomas, and packs/pt/ conditions those rates
-- on a supply located here. A country the common system does not reach adds a
-- row because a pack of it names a state; this pair is added for the same
-- reason a Californian pack would be, one level below the country instead of
-- outside it.
insert into territories (code, code_source, name, parent_code, eu_vat_scope, eu_vat_from, eu_vat_to, vat_prefix, legal_reference) values
  ('PT-20', 'iso_3166_2', 'Azores', 'PT', 'full', date '1986-01-01', null, null,
   'Directive 2006/112/EC, article 5, reaches the Azores exactly as it reaches the rest of Portugal — no row of this table, and no provision of the Directive, excludes it. Lei Constitucional n.º 1/2004, art. 5.º(4) and the Estatuto Político-Administrativo da Região Autónoma dos Açores name the region; the Código do IVA, art. 18.º, n.º 3, and the Lei das Finanças das Regiões Autónomas (Lei Orgânica n.º 2/2013, de 2 de setembro) let its legislative assembly set rates of its own, which is the only reason this row exists.'),
  ('PT-30', 'iso_3166_2', 'Madeira', 'PT', 'full', date '1986-01-01', null, null,
   'Directive 2006/112/EC, article 5, reaches Madeira exactly as it reaches the rest of Portugal — no row of this table, and no provision of the Directive, excludes it. Lei Constitucional n.º 1/2004, art. 5.º(4) and the Estatuto Político-Administrativo da Região Autónoma da Madeira name the region; the Código do IVA, art. 18.º, n.º 3, and the Lei das Finanças das Regiões Autónomas (Lei Orgânica n.º 2/2013, de 2 de setembro) let its legislative assembly set rates of its own, which is the only reason this row exists.')
on conflict (code) do update set
  code_source     = excluded.code_source,
  name            = excluded.name,
  parent_code     = excluded.parent_code,
  eu_vat_scope    = excluded.eu_vat_scope,
  eu_vat_from     = excluded.eu_vat_from,
  eu_vat_to       = excluded.eu_vat_to,
  vat_prefix      = excluded.vat_prefix,
  legal_reference = excluded.legal_reference;

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
   'Directive 2006/112/EC, article 5(2): the common system of VAT applies in the territory of the Community as defined by the Treaties, and a State outside it is a third country for every rule the Directive carries. Mexico levies a value added tax of its own under the Ley del Impuesto al Valor Agregado, whose article 1o. sets the general rate.'),
  ('CL', 'iso_3166_1', 'Chile', null, 'none', null, null, null,
   'Directive 2006/112/EC, article 5(2): the common system of VAT applies in the territory of the Community as defined by the Treaties, and a State outside it is a third country for every rule the Directive carries. Chile levies a value added tax of its own under Decreto Ley N° 825, de 1974, whose article 14 sets the general rate at 19 %.')
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
-- The rows — South Korea
--
-- Outside the common system, like Japan above: South Korea levies a
-- value-added tax of its own under its own 부가가치세법 (Value-Added Tax Act),
-- whose article 30 sets the rate at 10%, unrelated to Directive 2006/112/EC.
-- ---------------------------------------------------------------------------

insert into territories (code, code_source, name, parent_code, eu_vat_scope, eu_vat_from, eu_vat_to, vat_prefix, legal_reference) values
  ('KR', 'iso_3166_1', 'South Korea', null, 'none', null, null, null,
   'Directive 2006/112/EC, article 5(2): the common system of VAT applies in the territory of the Community as defined by the Treaties, and a State outside it is a third country for every rule the Directive carries. South Korea levies a value-added tax of its own under 부가가치세법 (the Value-Added Tax Act), whose article 30 sets the rate at 10%.')
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


-- ---------------------------------------------------------------------------
-- The rows — Hong Kong
--
-- Not a State outside the common system of VAT the way Australia or the
-- United States are: Hong Kong Special Administrative Region of the People's
-- Republic of China levies no value added tax, no goods and services tax and
-- no general sales tax of its own either, at any level of government, and
-- never has. `vat_prefix` is null for the reason it is null on the United
-- States row: there is no VAT identification number to prefix. A business is
-- addressed, where it is addressed at all, by its Business Registration
-- Number under the Business Registration Ordinance (Cap. 310), which is not a
-- VAT number and carries no country prefix of this table's kind.
-- ---------------------------------------------------------------------------

insert into territories (code, code_source, name, parent_code, eu_vat_scope, eu_vat_from, eu_vat_to, vat_prefix, legal_reference) values
  ('HK', 'iso_3166_1', 'Hong Kong', null, 'none', null, null, null,
   'Directive 2006/112/EC, article 5(2): the common system of VAT applies in the territory of the Community as defined by the Treaties, and a State outside it is a third country for every rule the Directive carries. Hong Kong Special Administrative Region has never levied a value added tax, a goods and services tax or a general sales tax: Inland Revenue Department guidance on Hong Kong''s tax system and the 2006 public consultation on a proposed goods and services tax, which was withdrawn, both record the absence rather than a rate. What Hong Kong charges instead is profits tax on the territorial basis of the Inland Revenue Ordinance (Cap. 112), section 14 — a tax on a year''s net profit, and not on a transaction.')
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
-- Taiwan
--
-- Not a Member State and not a third country of the Directive's own kind
-- either, the way Japan, Singapore and Hong Kong are already rows here for:
-- the common system of VAT reaches a defined territory of the European
-- Union and nowhere else, so a jurisdiction outside it is `none` regardless
-- of what recognition question its own status raises. Taiwan levies a
-- value-added business tax of its own under the 加值型及非加值型營業稅法
-- (Value-Added and Non-Value-Added Business Tax Act), whose article 10 sets
-- the rate.
-- ---------------------------------------------------------------------------

insert into territories (code, code_source, name, parent_code, eu_vat_scope, eu_vat_from, eu_vat_to, vat_prefix, legal_reference) values
  ('TW', 'iso_3166_1', 'Taiwan', null, 'none', null, null, null,
   'Directive 2006/112/EC, article 5(2): the common system of VAT applies in the territory of the Community as defined by the Treaties, and a jurisdiction outside it is held to `none` for every rule the Directive carries, whatever else its status raises. Taiwan levies a value-added business tax of its own under 加值型及非加值型營業稅法 (the Value-Added and Non-Value-Added Business Tax Act), article 10.')
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
-- The rows — United Arab Emirates
--
-- A State outside the common system of VAT the way Australia or Singapore
-- are: the United Arab Emirates levies a value added tax of its own under
-- Federal Decree-Law No. 8 of 2017, article 3, at 5 % of the value of a
-- taxable supply since the Decree-Law commenced on 1 January 2018 — no
-- Union instrument reaches it. `vat_prefix` is null: a UAE Tax Registration
-- Number carries no country prefix of this table's kind, and the identifier
-- a party is addressed by on the electronic invoicing network is its Tax
-- Identification Number under ICD 0235, which packs/ae/pack.json's
-- `einvoicing` block carries and this table has no column for.
-- ---------------------------------------------------------------------------

insert into territories (code, code_source, name, parent_code, eu_vat_scope, eu_vat_from, eu_vat_to, vat_prefix, legal_reference) values
  ('AE', 'iso_3166_1', 'United Arab Emirates', null, 'none', null, null, null,
   'Directive 2006/112/EC, article 5(2): the common system of VAT applies in the territory of the Community as defined by the Treaties, and a State outside it is a third country for every rule the Directive carries. The United Arab Emirates levies a value added tax of its own under Federal Decree-Law No. 8 of 2017, article 3, at 5 % since 1 January 2018 (Ministry of Finance / Federal Tax Authority, consolidated text).')
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
-- Thailand is outside the common system of VAT: Directive 2006/112/EC binds
-- the Member States of the European Union and nobody else, so a third
-- country's own value added tax — Thailand's, charged under Title IV Chapter
-- 4 of the Revenue Code (sections 77 to 90/4) — is never a supply the common
-- system reaches, whatever its own mechanics resemble. `vat_prefix` is null:
-- a Thai VAT registrant is identified by a thirteen-digit taxpayer
-- identification number, which carries no ISO country prefix comparable to
-- an EU VAT number and was not verified this session against a register.
-- ---------------------------------------------------------------------------

insert into territories (code, code_source, name, parent_code, eu_vat_scope, eu_vat_from, eu_vat_to, vat_prefix, legal_reference) values
  ('TH', 'iso_3166_1', 'Thailand', null, 'none', null, null, null,
   'Directive 2006/112/EC, article 5(2): the common system of VAT applies in the territory of the Community as defined by the Treaties, and a State outside it is a third country for every rule the Directive carries. Thailand levies its own value added tax under the Revenue Code, Title IV Chapter 4, sections 77 to 90/4 (Revenue Department of Thailand, https://www.rd.go.th/english/37732.html, read directly 22 September 2026), unrelated to the Union''s common system.')
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
-- The rows — Vietnam
--
-- A value added tax of its own (thuế giá trị gia tăng), charged by the
-- supplier and deducted by a registered buyer under the phương pháp khấu
-- trừ, declared on one return, under no Union instrument. `vat_prefix` is
-- null: a Vietnamese enterprise is addressed by its mã số thuế (tax
-- identification number), which carries no country prefix of this table's
-- kind.
-- ---------------------------------------------------------------------------

insert into territories (code, code_source, name, parent_code, eu_vat_scope, eu_vat_from, eu_vat_to, vat_prefix, legal_reference) values
  ('VN', 'iso_3166_1', 'Vietnam', null, 'none', null, null, null,
   'Directive 2006/112/EC, article 5(2): the common system of VAT applies in the territory of the Community as defined by the Treaties, and a State outside it is a third country for every rule the Directive carries. Vietnam levies a value added tax of its own under Luật Thuế giá trị gia tăng số 48/2024/QH15 (in force 1 July 2025), whose Điều 9 sets the rates.')
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
-- The rows — Indonesia
--
-- A value added tax of its own (Pajak Pertambahan Nilai), charged by a
-- Pengusaha Kena Pajak and deducted by a registered buyer, declared on one
-- monthly return, under no Union instrument. `vat_prefix` is null: an
-- Indonesian taxpayer is addressed by its Nomor Pokok Wajib Pajak (NPWP),
-- which carries no country prefix of this table's kind.
-- ---------------------------------------------------------------------------

insert into territories (code, code_source, name, parent_code, eu_vat_scope, eu_vat_from, eu_vat_to, vat_prefix, legal_reference) values
  ('ID', 'iso_3166_1', 'Indonesia', null, 'none', null, null, null,
   'Directive 2006/112/EC, article 5(2): the common system of VAT applies in the territory of the Community as defined by the Treaties, and a State outside it is a third country for every rule the Directive carries. Indonesia levies a value added tax of its own (Pajak Pertambahan Nilai) under Undang-Undang Nomor 42 Tahun 2009, whose Pasal 7 sets the rates, as amended by Undang-Undang Nomor 7 Tahun 2021, unrelated to the Union''s common system.')
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
-- The row — Saudi Arabia
--
-- A State outside the common system of VAT the way the United Arab Emirates
-- or Singapore are: the Kingdom levies a value added tax of its own under the
-- VAT Law of Royal Decree No. M/113, whose article 2(2) sets the basic rate at
-- 15 % of the value of a supply or an import since Royal Order No. A/638
-- amended it, and no Union instrument reaches it. The Common VAT Agreement of
-- the States of the Gulf Cooperation Council is a framework treaty and not a
-- second common system: its intra-GCC mechanism is not in force, article 79(6)
-- of the Kingdom's Implementing Regulations treating every other Member State
-- as a country outside Council Territory until an Electronic Services System
-- is announced. `vat_prefix` is null: a Saudi VAT registration number is
-- fifteen digits beginning and ending with 3 and carries no country prefix of
-- this table's kind.
-- ---------------------------------------------------------------------------

insert into territories (code, code_source, name, parent_code, eu_vat_scope, eu_vat_from, eu_vat_to, vat_prefix, legal_reference) values
  ('NO', 'iso_3166_1', 'Norway', null, 'none', null, null, null,
   'Directive 2006/112/EC, article 5(2): the common system of VAT applies in the territory of the Community as defined by the Treaties, and a State outside it is a third country for every rule the Directive carries. Norway is a member of the European Economic Area (EEA/EØS) under the EEA Agreement of 2 May 1992, which gives it access to the internal market, but value added tax is a matter the EEA Agreement does not cover (it is outside annexes I to XXII listing the Union acquis extended to the EEA): Norway levies its own merverdiavgift under the Lov om merverdiavgift (LOV-2009-06-19-58), unrelated to the Directive and administered by Skatteetaten, with no intra-Community acquisition or supply of any kind between Norway and a Member State.')
on conflict (code) do update set
  code_source     = excluded.code_source,
  name            = excluded.name,
  parent_code     = excluded.parent_code,
  eu_vat_scope    = excluded.eu_vat_scope,
  eu_vat_from     = excluded.eu_vat_from,
  eu_vat_to       = excluded.eu_vat_to,
  vat_prefix      = excluded.vat_prefix,
  legal_reference = excluded.legal_reference;

insert into territories (code, code_source, name, parent_code, eu_vat_scope, eu_vat_from, eu_vat_to, vat_prefix, legal_reference) values
  ('SA', 'iso_3166_1', 'Saudi Arabia', null, 'none', null, null, null,
   'Directive 2006/112/EC, article 5(2): the common system of VAT applies in the territory of the Community as defined by the Treaties, and a State outside it is a third country for every rule the Directive carries. Saudi Arabia levies a value added tax of its own under the Value Added Tax Law (Royal Decree No. M/113 dated 2 Dhul Qa''dah 1438H), article 2(2), at a basic rate of 15 % since Royal Order No. A/638 dated 15 Shawwal 1441H amended it, the rate having been 5 % from 1 January 2018 (Zakat, Tax and Customs Authority, consolidated Arabic text).')
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
-- The row — Turkey
--
-- A State outside the common system of VAT, and outside the European Union's
-- customs union for VAT purposes too: Türkiye levies a value added tax of its
-- own (Katma Değer Vergisi) under Law No. 3065 of 25 October 1984, whose
-- article 28 sets the standard rate at 10 %, a rate the President may raise
-- up to four times over or reduce to 1 %, and has raised to 20 % since
-- Presidential Decision No. 7346 of 6 July 2023 (Ministry of Treasury and
-- Finance / Revenue Administration, consolidated text). `vat_prefix` is null:
-- a Turkish taxpayer is addressed by a ten- or eleven-digit Tax Identification
-- Number (Vergi Kimlik Numarası) that carries no country prefix of this
-- table's kind.
-- ---------------------------------------------------------------------------

insert into territories (code, code_source, name, parent_code, eu_vat_scope, eu_vat_from, eu_vat_to, vat_prefix, legal_reference) values
  ('TR', 'iso_3166_1', 'Turkey', null, 'none', null, null, null,
   'Directive 2006/112/EC, article 5(2): the common system of VAT applies in the territory of the Community as defined by the Treaties, and a State outside it is a third country for every rule the Directive carries. Turkey levies a value added tax of its own, Katma Değer Vergisi, under Law No. 3065 of 25 October 1984, article 28, at a standard rate of 20 % since Presidential Decision No. 7346 of 6 July 2023 (Revenue Administration, consolidated text).')
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
-- Egypt is outside the common system of VAT: Directive 2006/112/EC binds the
-- Member States of the European Union and nobody else, so a third country's
-- own value added tax — Egypt's, charged under Value Added Tax Law No. 67 of
-- 2016, article 3, at a standard rate of 14 % since 1 July 2017 (Egyptian Tax
-- Authority, consolidated English text) — is never a supply the common system
-- reaches, whatever its own mechanics resemble. `vat_prefix` is null: an
-- Egyptian Tax Registration Number carries no ISO country prefix comparable
-- to an EU VAT number, and this pack's research did not verify a format for
-- it against a citable register.
-- ---------------------------------------------------------------------------

insert into territories (code, code_source, name, parent_code, eu_vat_scope, eu_vat_from, eu_vat_to, vat_prefix, legal_reference) values
  ('EG', 'iso_3166_1', 'Egypt', null, 'none', null, null, null,
   'Directive 2006/112/EC, article 5(2): the common system of VAT applies in the territory of the Community as defined by the Treaties, and a State outside it is a third country for every rule the Directive carries. Egypt levies a value added tax of its own under Value Added Tax Law No. 67 of 2016, article 3, at a standard rate of 14 % since 1 July 2017 (Egyptian Tax Authority, consolidated English text), unrelated to the Union''s common system.')
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
-- The row — Tunisia
--
-- A State outside the common system of VAT the way Saudi Arabia or Thailand
-- are: Tunisia levies a value added tax of its own under the Code de la TVA,
-- promulgated by the loi n° 88-61 du 2 juin 1988, whose article 7 sets three
-- positive rates — 19 %, 13 % and 7 % since the loi de finances pour 2018
-- (loi n° 2017-66 du 18 décembre 2017), article 43 — and no Union instrument
-- reaches it. `vat_prefix` is null: a Tunisian taxpayer is identified by a
-- matricule fiscal that carries no ISO country prefix of this table's kind.
-- ---------------------------------------------------------------------------

insert into territories (code, code_source, name, parent_code, eu_vat_scope, eu_vat_from, eu_vat_to, vat_prefix, legal_reference) values
  ('TN', 'iso_3166_1', 'Tunisia', null, 'none', null, null, null,
   'Directive 2006/112/EC, article 5(2): the common system of VAT applies in the territory of the Community as defined by the Treaties, and a State outside it is a third country for every rule the Directive carries. Tunisia levies a value added tax of its own under the Code de la TVA, loi n° 88-61 du 2 juin 1988, article 7 fixing rates of 19 %, 13 % and 7 % since the loi n° 2017-66 du 18 décembre 2017, article 43 (Ministère des Finances, Direction Générale des Études et de la Législation Fiscales, consolidated French text).')
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
-- The row — Algeria
--
-- A State outside the common system of VAT the way Saudi Arabia or the United
-- Arab Emirates are: Algeria levies a value added tax of its own under the
-- code des taxes sur le chiffre d'affaires (CTCA), unrelated to Directive
-- 2006/112/EC. `vat_prefix` is null: an Algerian numéro d'identification
-- fiscale (NIF) carries no country prefix of this table's kind and is never
-- validated against VIES, a register of the common system Algeria is not
-- part of.
-- ---------------------------------------------------------------------------

insert into territories (code, code_source, name, parent_code, eu_vat_scope, eu_vat_from, eu_vat_to, vat_prefix, legal_reference) values
  ('DZ', 'iso_3166_1', 'Algeria', null, 'none', null, null, null,
   'Directive 2006/112/EC, article 5(2): the common system of VAT applies in the territory of the Community as defined by the Treaties, and a State outside it is a third country for every rule the Directive carries. Algeria levies a value added tax of its own under the code des taxes sur le chiffre d''affaires, whose article 21 sets the normal rate at 19 % and article 23 the reduced rate at 9 % (Direction générale des impôts, consolidated text distributed by the Direction générale des douanes).')
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
-- The row — Morocco
--
-- A State outside the common system of VAT the way Saudi Arabia or the United
-- Arab Emirates are: the Kingdom of Morocco levies a value added tax of its
-- own under the Code général des impôts, article 1er, at a standard rate of
-- 20 % (article 99-A) since the 2024-2026 convergence calendar (finance laws
-- n° 55-23, 60-24 and 50-25) folded the former 7 % and 14 % rates into it or
-- into the 10 % reduced rate, and no Union instrument reaches it.
-- `vat_prefix` is null: a Moroccan identifiant fiscal carries no country
-- prefix of this table's kind.
-- ---------------------------------------------------------------------------

insert into territories (code, code_source, name, parent_code, eu_vat_scope, eu_vat_from, eu_vat_to, vat_prefix, legal_reference) values
  ('MA', 'iso_3166_1', 'Morocco', null, 'none', null, null, null,
   'Directive 2006/112/EC, article 5(2): the common system of VAT applies in the territory of the Community as defined by the Treaties, and a State outside it is a third country for every rule the Directive carries. Morocco levies a value added tax of its own under the Code général des impôts, articles 1er and 89 to 125, at a standard rate of 20 % (article 99-A, édition 2026, Direction générale des Impôts).')
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
-- The row — South Africa
--
-- A State outside the common system of VAT the way Australia or New Zealand
-- are: the Republic levies a value-added tax of its own under the
-- Value-Added Tax Act 89 of 1991, section 7(1), currently at 15 % since
-- 1 April 2018, and no Union instrument reaches it.
-- ---------------------------------------------------------------------------

insert into territories (code, code_source, name, parent_code, eu_vat_scope, eu_vat_from, eu_vat_to, vat_prefix, legal_reference) values
  ('ZA', 'iso_3166_1', 'South Africa', null, 'none', null, null, null,
   'Directive 2006/112/EC, article 5(2): the common system of VAT applies in the territory of the Community as defined by the Treaties, and a State outside it is a third country for every rule the Directive carries. South Africa levies a value-added tax of its own under the Value-Added Tax Act 89 of 1991, section 7(1), at a standard rate of 15 % since 1 April 2018.')
on conflict (code) do update set
  code_source     = excluded.code_source,
  name            = excluded.name,
  parent_code     = excluded.parent_code,
  eu_vat_scope    = excluded.eu_vat_scope,
  eu_vat_from     = excluded.eu_vat_from,
  eu_vat_to       = excluded.eu_vat_to,
  vat_prefix      = excluded.vat_prefix,
  legal_reference = excluded.legal_reference;

--
-- A State outside the common system of VAT the way the United Arab Emirates,
-- Singapore or Saudi Arabia are: Kenya levies a value added tax of its own
-- under the Value Added Tax Act (Cap. 476), whose section 5(2)(b) sets the
-- rate at sixteen per cent, and no Union instrument reaches it. Kenya belongs
-- to the East African Community, whose Customs Management Act, 2004
-- harmonises the customs union alone; VAT itself is not one of the taxes the
-- Community's own instruments harmonise, so there is no regional VAT regime
-- to test a supply against either, only the Kenyan Act.
-- ---------------------------------------------------------------------------

insert into territories (code, code_source, name, parent_code, eu_vat_scope, eu_vat_from, eu_vat_to, vat_prefix, legal_reference) values
  ('KE', 'iso_3166_1', 'Kenya', null, 'none', null, null, null,
   'Directive 2006/112/EC, article 5(2): the common system of VAT applies in the territory of the Community as defined by the Treaties, and a State outside it is a third country for every rule the Directive carries. Kenya levies a value added tax of its own under the Value Added Tax Act (Cap. 476), section 5(2)(b), at sixteen per cent of the taxable value since the Act commenced on 2 September 2013.')
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
-- The row — Malaysia
--
-- Malaysia levies no value added tax at all, in either direction: it charges
-- a Sales Tax (Sales Tax Act 2018, Act 806) at the point of manufacture or
-- import of taxable goods, and a Service Tax (Service Tax Act 2018, Act 807)
-- on taxable services, each a single-stage tax with no mechanism anywhere in
-- either Act for a registered buyer to deduct the tax a supplier charged
-- them — the whole difference between this and the common system of VAT, and
-- the reason both are modelled in `packs/my/` as `kind: sales_tax`,
-- `recoverable: false`. `vat_prefix` is null: the Sales Tax and Service Tax
-- registration numbers the Royal Malaysian Customs Department issues carry
-- no ISO country prefix comparable to an EU VAT number.
-- ---------------------------------------------------------------------------

insert into territories (code, code_source, name, parent_code, eu_vat_scope, eu_vat_from, eu_vat_to, vat_prefix, legal_reference) values
  ('MY', 'iso_3166_1', 'Malaysia', null, 'none', null, null, null,
   'Directive 2006/112/EC, article 5(2): the common system of VAT applies in the territory of the Community as defined by the Treaties, and a State outside it is a third country for every rule the Directive carries. Malaysia levies its own Sales Tax under the Sales Tax Act 2018 (Act 806), section 8 (manufacture) and section 9 (importation), and its own Service Tax under the Service Tax Act 2018 (Act 807), section 7, both administered by the Royal Malaysian Customs Department (Jabatan Kastam Diraja Malaysia) and unrelated to the Union''s common system.')
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
-- The row — Israel
--
-- A State outside the common system of VAT the way the United Arab Emirates
-- and Saudi Arabia are: Israel levies a value added tax of its own under the
-- Value Added Tax Law, 5736-1975, section 2, at 18 % of the value of a
-- transaction or an import of goods since the Value Added Tax Order (Rate of
-- Tax on a Transaction and on Import of Goods) (Amendment), 5784-2024 raised
-- it from 17 % with effect from 1 January 2025, and no Union instrument
-- reaches it. `vat_prefix` is null: an Israeli dealer file number carries no
-- country prefix of this table's kind.
-- ---------------------------------------------------------------------------

insert into territories (code, code_source, name, parent_code, eu_vat_scope, eu_vat_from, eu_vat_to, vat_prefix, legal_reference) values
  ('IL', 'iso_3166_1', 'Israel', null, 'none', null, null, null,
   'Directive 2006/112/EC, article 5(2): the common system of VAT applies in the territory of the Community as defined by the Treaties, and a State outside it is a third country for every rule the Directive carries. Israel levies a value added tax of its own under the Value Added Tax Law, 5736-1975, section 2, at 18 % since the Value Added Tax Order (Rate of Tax on a Transaction and on Import of Goods) (Amendment), 5784-2024 (published in Reshumot on 28 February 2024) raised it from 17 % with effect from 1 January 2025 (Israel Tax Authority, consolidated text of the Order).')
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
-- The row — the Philippines
--
-- A value added tax of its own under Title IV of the National Internal
-- Revenue Code of 1997 (sections 105 to 115, as amended by the TRAIN Law,
-- Republic Act No. 10963, and the Ease of Paying Taxes Act, Republic Act
-- No. 11976), unrelated to the Union's common system. `vat_prefix` is null:
-- a Philippine VAT-registered taxpayer is identified by a twelve-digit
-- Taxpayer Identification Number, the last three digits of which are the
-- branch code, and which carries no ISO country prefix of this table's kind.
-- ---------------------------------------------------------------------------

insert into territories (code, code_source, name, parent_code, eu_vat_scope, eu_vat_from, eu_vat_to, vat_prefix, legal_reference) values
  ('PH', 'iso_3166_1', 'Philippines', null, 'none', null, null, null,
   'Directive 2006/112/EC, article 5(2): the common system of VAT applies in the territory of the Community as defined by the Treaties, and a State outside it is a third country for every rule the Directive carries. The Philippines levies a value added tax of its own under the National Internal Revenue Code of 1997, Title IV, sections 105 to 115, as amended by Republic Act No. 10963 (TRAIN Law) and Republic Act No. 11976 (Ease of Paying Taxes Act) (Supreme Court of the Philippines, E-Library, https://elibrary.judiciary.gov.ph/thebookshelf/showdocs/2/96948, read directly 25 September 2026), unrelated to the Union''s common system.')
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
-- The row — Argentina
--
-- A State outside the common system of VAT the way Mexico or Côte d'Ivoire
-- are: the Republic levies a value added tax of its own under the Ley de
-- Impuesto al Valor Agregado, texto ordenado in 1997 (Decreto 280/1997) and
-- its amendments, whose article 28 sets a general rate of 21 %, an increased
-- rate of 27 % on metered gas, electricity and water sold outside a dwelling
-- to a registered taxpayer, and a reduced rate of 10.5 % on the goods and
-- services the same article lists, and no Union instrument reaches it.
-- `vat_prefix` is null: the C.U.I.T. (Clave Única de Identificación
-- Tributaria) is an eleven-digit number issued by the Agencia de Recaudación
-- y Control Aduanero (ARCA, formerly AFIP) and carries no country prefix of
-- this table's kind.
-- ---------------------------------------------------------------------------

insert into territories (code, code_source, name, parent_code, eu_vat_scope, eu_vat_from, eu_vat_to, vat_prefix, legal_reference) values
  ('AR', 'iso_3166_1', 'Argentina', null, 'none', null, null, null,
   'Directive 2006/112/EC, article 5(2): the common system of VAT applies in the territory of the Community as defined by the Treaties, and a State outside it is a third country for every rule the Directive carries. Argentina levies a value added tax of its own under the Ley de Impuesto al Valor Agregado, texto ordenado en 1997 (Decreto 280/1997) y sus modificaciones, article 28, at a general rate of 21 %.')
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
-- The row — Nigeria
--
-- A State outside the common system of VAT the way Saudi Arabia or the United
-- Arab Emirates are: Nigeria levies a value added tax of its own, first under
-- the Value Added Tax Act, Cap. V1, LFN 2004, and from 1 January 2026 under
-- Chapter Six of the Nigeria Tax Act 2025, whose section 147 sets the rate at
-- 7.5 %, and no Union instrument reaches it. `vat_prefix` is null: a Nigerian
-- taxable person is identified by the Tax Identification Number the Nigeria
-- Revenue Service issues under Nigeria Tax Administration Act 2025, s. 7,
-- which carries no ISO country prefix comparable to an EU VAT number.
-- ---------------------------------------------------------------------------

insert into territories (code, code_source, name, parent_code, eu_vat_scope, eu_vat_from, eu_vat_to, vat_prefix, legal_reference) values
  ('NG', 'iso_3166_1', 'Nigeria', null, 'none', null, null, null,
   'Directive 2006/112/EC, article 5(2): the common system of VAT applies in the territory of the Community as defined by the Treaties, and a State outside it is a third country for every rule the Directive carries. Nigeria levies a value added tax of its own, most recently under the Nigeria Tax Act 2025, s. 147, which sets the rate at 7.5 % with effect from 1 January 2026 (Federal Republic of Nigeria Official Gazette No. 117, Vol. 112, 26 June 2025), unrelated to the Union''s common system.')
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
-- The row — Colombia
--
-- A State of the Americas outside the common system of VAT the way Mexico is:
-- Colombia levies an impuesto sobre las ventas (IVA) of its own under Book
-- Three of the Estatuto Tributario Nacional (Decreto 624 de 1989), whose
-- article 468 sets the general rate. `vat_prefix` is null: a Colombian
-- registration is the Número de Identificación Tributaria (NIT) recorded in
-- the Registro Único Tributario, which carries no country prefix of this
-- table's kind.
-- ---------------------------------------------------------------------------

insert into territories (code, code_source, name, parent_code, eu_vat_scope, eu_vat_from, eu_vat_to, vat_prefix, legal_reference) values
  ('CO', 'iso_3166_1', 'Colombia', null, 'none', null, null, null,
   'Directive 2006/112/EC, article 5(2): the common system of VAT applies in the territory of the Community as defined by the Treaties, and a State outside it is a third country for every rule the Directive carries. Colombia levies an impuesto sobre las ventas (IVA) of its own under the Estatuto Tributario Nacional, whose article 468 sets the general rate.')
on conflict (code) do update set
  code_source     = excluded.code_source,
  name            = excluded.name,
  parent_code     = excluded.parent_code,
  eu_vat_scope    = excluded.eu_vat_scope,
  eu_vat_from     = excluded.eu_vat_from,
  eu_vat_to       = excluded.eu_vat_to,
  vat_prefix      = excluded.vat_prefix,
  legal_reference = excluded.legal_reference;


insert into territories (code, code_source, name, parent_code, eu_vat_scope, eu_vat_from, eu_vat_to, vat_prefix, legal_reference) values
  ('PE', 'iso_3166_1', 'Peru', null, 'none', null, null, null,
   'Directive 2006/112/EC, article 5(2): the common system of VAT applies in the territory of the Community as defined by the Treaties, and a State outside it is a third country for every rule the Directive carries. Peru levies a value added tax of its own, the Impuesto General a las Ventas, under the Texto Único Ordenado approved by Decreto Supremo N.° 055-99-EF, whose article 17 sets its rate.')
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
-- The rows — Canada, and the thirteen provinces and territories its pack taxes
--
-- Two reasons at once, and the file already names both. Canada is a State
-- outside the common system of VAT: Part IX of the Excise Tax Act levies a
-- goods and services tax of its own, and a Canadian seller is bound by no
-- Directive. And Canadian tax follows the province the supply is made in —
-- 5 per cent where the federal tax stands alone, 13, 14 or 15 in a
-- participating province under subsection 165(2), and a provincial sales tax
-- of the province's own beside the federal one in British Columbia,
-- Saskatchewan, Manitoba and Québec — so `packs/ca/` conditions every one of
-- its standard-rate codes on `supply_in`, and each of those codes needs a row
-- to point at.
--
-- Thirteen rows and not a district: this table says where a body of tax law
-- applies and never what it charges. A Québec municipality levies nothing of
-- this kind, and the province is as far down as the question goes.
--
-- `vat_prefix` is null on all fourteen: a Canadian registration is a business
-- number with an RT programme account, and a Québec one a NEQ-based QST
-- number, and neither carries a country prefix of this table's kind.
-- ---------------------------------------------------------------------------

insert into territories (code, code_source, name, parent_code, eu_vat_scope, eu_vat_from, eu_vat_to, vat_prefix, legal_reference) values
  ('CA', 'iso_3166_1', 'Canada', null, 'none', null, null, null,
   'Directive 2006/112/EC, article 5(2): the common system of VAT applies in the territory of the Community as defined by the Treaties, and a State outside it is a third country for every rule the Directive carries. Canada levies a goods and services tax of its own under Part IX of the Excise Tax Act (R.S.C. 1985, c. E-15), whose subsection 165(1) sets the rate at 5 per cent and whose subsection 165(2) adds the provincial part of the harmonized sales tax on a supply made in a participating province.'),
  ('CA-AB', 'iso_3166_2', 'Alberta',                   'CA', 'none', null, null, null,
   'ISO 3166-2:CA for the code. Alberta is not a participating province within the meaning of subsection 123(1) of the Excise Tax Act and levies no general sales tax of its own, so the tax on a supply made there is the 5 per cent of subsection 165(1) and nothing more. A territory with no provincial tax is a territory all the same: it is what says that a delivery there carries none.'),
  ('CA-BC', 'iso_3166_2', 'British Columbia',          'CA', 'none', null, null, null,
   'ISO 3166-2:CA for the code. British Columbia is not a participating province and levies a provincial sales tax of its own: section 37 of the Provincial Sales Tax Act (S.B.C. 2012, c. 35) imposes the tax on a purchaser of tangible personal property and subsection 34(1) sets it at 7 per cent of the purchase price, beside the 5 per cent of subsection 165(1) of the Excise Tax Act.'),
  ('CA-MB', 'iso_3166_2', 'Manitoba',                  'CA', 'none', null, null, null,
   'ISO 3166-2:CA for the code. Manitoba is not a participating province and levies a retail sales tax of its own: subsection 2(1) of The Retail Sales Tax Act (C.C.S.M. c. R130) makes every purchaser of tangible personal property or a taxable service pay tax at the general sales tax rate, which subsection 1(1) sets at 7 per cent for tax payable after 30 June 2019.'),
  ('CA-NB', 'iso_3166_2', 'New Brunswick',             'CA', 'none', null, null, null,
   'ISO 3166-2:CA for the code. New Brunswick is a participating province within the meaning of subsection 123(1) of the Excise Tax Act: subsection 165(2) adds the provincial part to the 5 per cent of subsection 165(1), and the Canada Revenue Agency publishes the combined harmonized sales tax rate at 15 per cent.'),
  ('CA-NL', 'iso_3166_2', 'Newfoundland and Labrador', 'CA', 'none', null, null, null,
   'ISO 3166-2:CA for the code. Newfoundland and Labrador is a participating province within the meaning of subsection 123(1) of the Excise Tax Act: subsection 165(2) adds the provincial part to the 5 per cent of subsection 165(1), and the Canada Revenue Agency publishes the combined harmonized sales tax rate at 15 per cent.'),
  ('CA-NS', 'iso_3166_2', 'Nova Scotia',               'CA', 'none', null, null, null,
   'ISO 3166-2:CA for the code. Nova Scotia is a participating province within the meaning of subsection 123(1) of the Excise Tax Act. Its provincial part fell from 10 points to 9 on 1 April 2025, so the Canada Revenue Agency publishes the combined harmonized sales tax rate at 14 per cent and no longer at 15.'),
  ('CA-NT', 'iso_3166_2', 'Northwest Territories',     'CA', 'none', null, null, null,
   'ISO 3166-2:CA for the code. The Northwest Territories are not a participating province and levy no general sales tax, so the tax on a supply made there is the 5 per cent of subsection 165(1) of the Excise Tax Act and nothing more.'),
  ('CA-NU', 'iso_3166_2', 'Nunavut',                   'CA', 'none', null, null, null,
   'ISO 3166-2:CA for the code. Nunavut is not a participating province and levies no general sales tax, so the tax on a supply made there is the 5 per cent of subsection 165(1) of the Excise Tax Act and nothing more.'),
  ('CA-ON', 'iso_3166_2', 'Ontario',                   'CA', 'none', null, null, null,
   'ISO 3166-2:CA for the code. Ontario is a participating province within the meaning of subsection 123(1) of the Excise Tax Act: subsection 165(2) adds the provincial part to the 5 per cent of subsection 165(1), and the Canada Revenue Agency publishes the combined harmonized sales tax rate at 13 per cent.'),
  ('CA-PE', 'iso_3166_2', 'Prince Edward Island',      'CA', 'none', null, null, null,
   'ISO 3166-2:CA for the code. Prince Edward Island is a participating province within the meaning of subsection 123(1) of the Excise Tax Act: subsection 165(2) adds the provincial part to the 5 per cent of subsection 165(1), and the Canada Revenue Agency publishes the combined harmonized sales tax rate at 15 per cent.'),
  ('CA-QC', 'iso_3166_2', 'Québec',                    'CA', 'none', null, null, null,
   'ISO 3166-2:CA for the code. Québec is not a participating province and levies a value added tax of its own, administered by its own administration: section 16 of the Act respecting the Québec sales tax (CQLR c. T-0.1) imposes the Québec sales tax at 9.975 per cent on the value of the consideration for a taxable supply made in Québec, beside the 5 per cent of subsection 165(1) of the Excise Tax Act and not on top of it.'),
  ('CA-SK', 'iso_3166_2', 'Saskatchewan',              'CA', 'none', null, null, null,
   'ISO 3166-2:CA for the code. Saskatchewan is not a participating province and levies a provincial sales tax of its own: subsection 5(1) of The Provincial Sales Tax Act (R.S.S. 1978, c. P-34.1) makes every consumer of tangible personal property purchased at a retail sale in Saskatchewan pay a tax computed at 6 per cent of the value of the property, beside the 5 per cent of subsection 165(1) of the Excise Tax Act.'),
  ('CA-YT', 'iso_3166_2', 'Yukon',                     'CA', 'none', null, null, null,
   'ISO 3166-2:CA for the code. Yukon is not a participating province and levies no general sales tax, so the tax on a supply made there is the 5 per cent of subsection 165(1) of the Excise Tax Act and nothing more.')
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
-- The row — Ukraine
--
-- A candidate country outside the common system of VAT the way Turkey is:
-- accession negotiations opened in 2024, but Directive 2006/112/EC, article
-- 5(2), reaches only the territory of the Community as the Treaties define
-- it, and candidacy is not accession. Ukraine levies a value added tax of its
-- own, податок на додану вартість, under the Tax Code of Ukraine (Податковий
-- кодекс України, Law No. 2755-VI of 2 December 2010), Section V, articles
-- 193 to 195, unrelated to the Union's common system. `vat_prefix` is null: a
-- Ukrainian VAT payer is identified by the taxpayer's registration number
-- (індивідуальний податковий номер) the State Tax Service assigns under
-- article 183 of the same Section, which carries no ISO country prefix
-- comparable to an EU VAT number.
-- ---------------------------------------------------------------------------

insert into territories (code, code_source, name, parent_code, eu_vat_scope, eu_vat_from, eu_vat_to, vat_prefix, legal_reference) values
  ('UA', 'iso_3166_1', 'Ukraine', null, 'none', null, null, null,
   'Directive 2006/112/EC, article 5(2): the common system of VAT applies in the territory of the Community as defined by the Treaties, and a State outside it is a third country for every rule the Directive carries, candidate for accession or not. Ukraine levies a value added tax of its own, under the Tax Code of Ukraine (Law No. 2755-VI of 2 December 2010), Section V, articles 193-195, which sets the rates.')
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
-- The row — Uruguay
--
-- A State of the Americas levies a value added tax of its own, and the
-- common system of VAT of Directive 2006/112/EC does not reach it: what this
-- table says of it is what it says of Chile and Peru. Uruguay levies the
-- Impuesto al Valor Agregado under Título 10 of the Texto Ordenado 2023
-- (Decreto N° 101/024, de 4 de abril de 2024), whose art. 34 sets the rates
-- at 22 % and 10 %.
-- ---------------------------------------------------------------------------

insert into territories (code, code_source, name, parent_code, eu_vat_scope, eu_vat_from, eu_vat_to, vat_prefix, legal_reference) values
  ('UY', 'iso_3166_1', 'Uruguay', null, 'none', null, null, null,
   'Directive 2006/112/EC, article 5(2): the common system of VAT applies in the territory of the Community as defined by the Treaties, and a State outside it is a third country for every rule the Directive carries. Uruguay levies a value added tax of its own under Título 10 of the Texto Ordenado 2023 (Decreto N° 101/024, de 4 de abril de 2024), whose art. 34 sets the basic rate at 22 % and the minimum rate at 10 %.')
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
-- The row — Bolivia
--
-- Outside the common system of VAT the way Peru and Argentina are: Directive
-- 2006/112/EC, article 5(2), reaches only the territory of the Community as
-- the Treaties define it. Bolivia levies an Impuesto al Valor Agregado of its
-- own under Ley N.° 843 (Ley de Reforma Tributaria de 20 de mayo de 1986),
-- Título I, articles 1° to 18°, unrelated to the Union's common system.
-- `vat_prefix` is null: a Bolivian taxpayer is identified by the Número de
-- Identificación Tributaria (NIT), which carries no ISO 6523 code comparable
-- to an EU VAT number.
-- ---------------------------------------------------------------------------

insert into territories (code, code_source, name, parent_code, eu_vat_scope, eu_vat_from, eu_vat_to, vat_prefix, legal_reference) values
  ('BO', 'iso_3166_1', 'Bolivia', null, 'none', null, null, null,
   'Directive 2006/112/EC, article 5(2): the common system of VAT applies in the territory of the Community as defined by the Treaties, and a State outside it is a third country for every rule the Directive carries. Bolivia levies a value added tax of its own, the Impuesto al Valor Agregado, under Ley N.° 843 (Ley de Reforma Tributaria de 20 de mayo de 1986), Título I, articles 1°-18°, which sets the rate.')
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
-- The row — Paraguay
--
-- A South American country, no candidate to any accession to the European
-- Union and no party to any agreement extending Directive 2006/112/EC to its
-- territory: article 5(2) of the Directive confines the common system of VAT
-- to the territory of the Community as the Treaties define it, and Paraguay
-- lies outside it. Paraguay levies its own Impuesto al Valor Agregado (IVA)
-- under Ley N.° 6.380/2019, De Modernización y Simplificación del Sistema
-- Tributario Nacional, Libro III, unrelated to the Union's common system.
-- `vat_prefix` is null: a taxpayer is identified by the Registro Único del
-- Contribuyente (RUC), which carries no ISO country prefix comparable to an
-- EU VAT number.
-- ---------------------------------------------------------------------------

insert into territories (code, code_source, name, parent_code, eu_vat_scope, eu_vat_from, eu_vat_to, vat_prefix, legal_reference) values
  ('PY', 'iso_3166_1', 'Paraguay', null, 'none', null, null, null,
   'Directive 2006/112/EC, article 5(2): the common system of VAT applies in the territory of the Community as defined by the Treaties, and Paraguay is a third country for every rule the Directive carries. Paraguay levies a value added tax of its own, the Impuesto al Valor Agregado, under Ley N.° 6.380/2019, Libro III, arts. 80 a 103.')
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
-- The row — Ecuador
--
-- A State of the Americas outside the common system of VAT the way Colombia
-- and Peru are: Directive 2006/112/EC, article 5(2), applies the common
-- system only in the territory of the Community as the Treaties define it.
-- Ecuador levies an impuesto al valor agregado (IVA) of its own under the Ley
-- de Régimen Tributario Interno (Codificación No. 2004-026), whose article 65
-- sets the general rate — 15 per cent since 1 April 2024, by Decreto
-- Ejecutivo No. 198 of 15 March 2024, within the 13-to-15 per cent range the
-- article itself fixes. `vat_prefix` is null: an Ecuadorian taxpayer is
-- identified by the Registro Único de Contribuyentes (RUC), which carries no
-- ISO country prefix comparable to an EU VAT number.
-- ---------------------------------------------------------------------------

insert into territories (code, code_source, name, parent_code, eu_vat_scope, eu_vat_from, eu_vat_to, vat_prefix, legal_reference) values
  ('EC', 'iso_3166_1', 'Ecuador', null, 'none', null, null, null,
   'Directive 2006/112/EC, article 5(2): the common system of VAT applies in the territory of the Community as defined by the Treaties, and a State outside it is a third country for every rule the Directive carries. Ecuador levies an impuesto al valor agregado (IVA) of its own under the Ley de Régimen Tributario Interno, whose article 65 sets the general rate, currently 15 per cent by Decreto Ejecutivo No. 198 of 15 March 2024.')
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
-- The row — China
--
-- A State of East Asia levies a value added tax of its own, and the common
-- system of VAT of Directive 2006/112/EC does not reach it: what this table
-- says of it is what it says of Japan and Korea. China levies 增值税 under
-- the Value-Added Tax Law of the People's Republic of China, adopted on
-- 25 December 2024 and in force since 1 January 2026, whose article 10 sets
-- the rates at 13 %, 9 % and 6 %, and zero on exports.
-- ---------------------------------------------------------------------------

insert into territories (code, code_source, name, parent_code, eu_vat_scope, eu_vat_from, eu_vat_to, vat_prefix, legal_reference) values
  ('CN', 'iso_3166_1', 'China', null, 'none', null, null, null,
   'Directive 2006/112/EC, article 5(2): the common system of VAT applies in the territory of the Community as defined by the Treaties, and a State outside it is a third country for every rule the Directive carries. China levies a value added tax of its own under the Value-Added Tax Law of the People''s Republic of China (中华人民共和国增值税法, in force since 1 January 2026), whose article 10 sets the rates at 13 %, 9 % and 6 %, and zero on exports.')
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
-- The row — the Dominican Republic
--
-- Outside the common system of VAT the way every State of the Americas is:
-- Directive 2006/112/EC, article 5(2), reaches only the territory of the
-- Community as the Treaties define it. The Dominican Republic levies its own
-- Impuesto sobre Transferencias de Bienes Industrializados y Servicios
-- (ITBIS), under the Código Tributario (Ley No. 11-92 of 16 May 1992),
-- Título III, articles 335 to 353, unrelated to the Union's common system.
-- `vat_prefix` is null: a Dominican taxpayer is identified by the Registro
-- Nacional de Contribuyentes (RNC), which carries no ISO 6523 scheme
-- registered and no prefix comparable to an EU VAT number.
-- ---------------------------------------------------------------------------

insert into territories (code, code_source, name, parent_code, eu_vat_scope, eu_vat_from, eu_vat_to, vat_prefix, legal_reference) values
  ('DO', 'iso_3166_1', 'Dominican Republic', null, 'none', null, null, null,
   'Directive 2006/112/EC, article 5(2): the common system of VAT applies in the territory of the Community as defined by the Treaties, and a State outside it is a third country for every rule the Directive carries. The Dominican Republic levies a value added tax of its own, the Impuesto sobre Transferencias de Bienes Industrializados y Servicios (ITBIS), under the Código Tributario (Ley No. 11-92 of 16 May 1992), Título III, articles 335-353, which sets the rates.')
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
-- The rows — India, and its twenty-eight States and eight Union territories
--
-- India is outside the common system of VAT and levies a goods and services
-- tax of its own, in two layers that follow the place of supply: on a supply
-- inside one State the Centre levies the central tax and the State (or the
-- Union territory) the State tax, each at half the rate; on a supply between
-- two States, and on imports, the Centre levies the integrated tax alone —
-- sections 7 and 8 of the Integrated Goods and Services Tax Act. `packs/in/`
-- therefore conditions every intra-State code on `supply_vs_seller: same` and
-- every inter-State code on `other`, and those need a row per State to compare
-- a seller and a place of supply at. Codes are those of ISO 3166-2:IN as
-- revised in November 2023 (IN-CG, IN-OD, IN-TS, IN-UK). The State codes of
-- a GSTIN (29 for Karnataka, 27 for Maharashtra…) are the administration's own
-- numbering and are not this table's key.
--
-- `vat_prefix` is null on all thirty-seven: a GSTIN carries no country prefix.
-- ---------------------------------------------------------------------------

insert into territories (code, code_source, name, parent_code, eu_vat_scope, eu_vat_from, eu_vat_to, vat_prefix, legal_reference) values
  ('IN', 'iso_3166_1', 'India', null, 'none', null, null, null,
   'Directive 2006/112/EC, article 5(2): the common system of VAT applies in the territory of the Community as defined by the Treaties, and a State outside it is a third country for every rule the Directive carries. India levies a goods and services tax of its own under article 246A of the Constitution: the central tax of the Central Goods and Services Tax Act, 2017 and the State or Union territory tax on an intra-State supply, the integrated tax of the Integrated Goods and Services Tax Act, 2017 on an inter-State supply and on imports.'),
  ('IN-AN', 'iso_3166_2', 'Andaman and Nicobar Islands',              'IN', 'none', null, null, null,
   'ISO 3166-2:IN for the code. A Union territory without a legislature: the Union Territory Goods and Services Tax Act, 2017 levies the Union territory tax on an intra-State supply made there, in place of a State tax and at the same half rate, beside the central tax; a supply from or to another State or Union territory is inter-State under section 7 of the Integrated Goods and Services Tax Act.'),
  ('IN-AP', 'iso_3166_2', 'Andhra Pradesh',                           'IN', 'none', null, null, null,
   'ISO 3166-2:IN for the code. A State: the State Goods and Services Tax Act it enacted in 2017 levies the State tax on an intra-State supply made there, beside the central tax of section 9 of the Central Goods and Services Tax Act, each at half the rate; a supply from or to another State is inter-State under section 7 of the Integrated Goods and Services Tax Act and bears the integrated tax instead.'),
  ('IN-AR', 'iso_3166_2', 'Arunachal Pradesh',                        'IN', 'none', null, null, null,
   'ISO 3166-2:IN for the code. A State: the State Goods and Services Tax Act it enacted in 2017 levies the State tax on an intra-State supply made there, beside the central tax of section 9 of the Central Goods and Services Tax Act, each at half the rate; a supply from or to another State is inter-State under section 7 of the Integrated Goods and Services Tax Act and bears the integrated tax instead.'),
  ('IN-AS', 'iso_3166_2', 'Assam',                                    'IN', 'none', null, null, null,
   'ISO 3166-2:IN for the code. A State: the State Goods and Services Tax Act it enacted in 2017 levies the State tax on an intra-State supply made there, beside the central tax of section 9 of the Central Goods and Services Tax Act, each at half the rate; a supply from or to another State is inter-State under section 7 of the Integrated Goods and Services Tax Act and bears the integrated tax instead.'),
  ('IN-BR', 'iso_3166_2', 'Bihar',                                    'IN', 'none', null, null, null,
   'ISO 3166-2:IN for the code. A State: the State Goods and Services Tax Act it enacted in 2017 levies the State tax on an intra-State supply made there, beside the central tax of section 9 of the Central Goods and Services Tax Act, each at half the rate; a supply from or to another State is inter-State under section 7 of the Integrated Goods and Services Tax Act and bears the integrated tax instead.'),
  ('IN-CH', 'iso_3166_2', 'Chandigarh',                               'IN', 'none', null, null, null,
   'ISO 3166-2:IN for the code. A Union territory without a legislature: the Union Territory Goods and Services Tax Act, 2017 levies the Union territory tax on an intra-State supply made there, in place of a State tax and at the same half rate, beside the central tax; a supply from or to another State or Union territory is inter-State under section 7 of the Integrated Goods and Services Tax Act.'),
  ('IN-CG', 'iso_3166_2', 'Chhattisgarh',                             'IN', 'none', null, null, null,
   'ISO 3166-2:IN for the code. A State: the State Goods and Services Tax Act it enacted in 2017 levies the State tax on an intra-State supply made there, beside the central tax of section 9 of the Central Goods and Services Tax Act, each at half the rate; a supply from or to another State is inter-State under section 7 of the Integrated Goods and Services Tax Act and bears the integrated tax instead.'),
  ('IN-DH', 'iso_3166_2', 'Dadra and Nagar Haveli and Daman and Diu', 'IN', 'none', null, null, null,
   'ISO 3166-2:IN for the code. A Union territory without a legislature: the Union Territory Goods and Services Tax Act, 2017 levies the Union territory tax on an intra-State supply made there, in place of a State tax and at the same half rate, beside the central tax; a supply from or to another State or Union territory is inter-State under section 7 of the Integrated Goods and Services Tax Act.'),
  ('IN-DL', 'iso_3166_2', 'Delhi',                                    'IN', 'none', null, null, null,
   'ISO 3166-2:IN for the code. A Union territory with a legislature: for the purposes of the Goods and Services Tax it is a State, levies the State tax under a State Goods and Services Tax Act of its own (section 2(103) of the Central Goods and Services Tax Act counts it among the States), and a supply from or to another State or Union territory is inter-State under section 7 of the Integrated Goods and Services Tax Act.'),
  ('IN-GA', 'iso_3166_2', 'Goa',                                      'IN', 'none', null, null, null,
   'ISO 3166-2:IN for the code. A State: the State Goods and Services Tax Act it enacted in 2017 levies the State tax on an intra-State supply made there, beside the central tax of section 9 of the Central Goods and Services Tax Act, each at half the rate; a supply from or to another State is inter-State under section 7 of the Integrated Goods and Services Tax Act and bears the integrated tax instead.'),
  ('IN-GJ', 'iso_3166_2', 'Gujarat',                                  'IN', 'none', null, null, null,
   'ISO 3166-2:IN for the code. A State: the State Goods and Services Tax Act it enacted in 2017 levies the State tax on an intra-State supply made there, beside the central tax of section 9 of the Central Goods and Services Tax Act, each at half the rate; a supply from or to another State is inter-State under section 7 of the Integrated Goods and Services Tax Act and bears the integrated tax instead.'),
  ('IN-HR', 'iso_3166_2', 'Haryana',                                  'IN', 'none', null, null, null,
   'ISO 3166-2:IN for the code. A State: the State Goods and Services Tax Act it enacted in 2017 levies the State tax on an intra-State supply made there, beside the central tax of section 9 of the Central Goods and Services Tax Act, each at half the rate; a supply from or to another State is inter-State under section 7 of the Integrated Goods and Services Tax Act and bears the integrated tax instead.'),
  ('IN-HP', 'iso_3166_2', 'Himachal Pradesh',                         'IN', 'none', null, null, null,
   'ISO 3166-2:IN for the code. A State: the State Goods and Services Tax Act it enacted in 2017 levies the State tax on an intra-State supply made there, beside the central tax of section 9 of the Central Goods and Services Tax Act, each at half the rate; a supply from or to another State is inter-State under section 7 of the Integrated Goods and Services Tax Act and bears the integrated tax instead.'),
  ('IN-JK', 'iso_3166_2', 'Jammu and Kashmir',                        'IN', 'none', null, null, null,
   'ISO 3166-2:IN for the code. A Union territory with a legislature: for the purposes of the Goods and Services Tax it is a State, levies the State tax under a State Goods and Services Tax Act of its own (section 2(103) of the Central Goods and Services Tax Act counts it among the States), and a supply from or to another State or Union territory is inter-State under section 7 of the Integrated Goods and Services Tax Act.'),
  ('IN-JH', 'iso_3166_2', 'Jharkhand',                                'IN', 'none', null, null, null,
   'ISO 3166-2:IN for the code. A State: the State Goods and Services Tax Act it enacted in 2017 levies the State tax on an intra-State supply made there, beside the central tax of section 9 of the Central Goods and Services Tax Act, each at half the rate; a supply from or to another State is inter-State under section 7 of the Integrated Goods and Services Tax Act and bears the integrated tax instead.'),
  ('IN-KA', 'iso_3166_2', 'Karnataka',                                'IN', 'none', null, null, null,
   'ISO 3166-2:IN for the code. A State: the State Goods and Services Tax Act it enacted in 2017 levies the State tax on an intra-State supply made there, beside the central tax of section 9 of the Central Goods and Services Tax Act, each at half the rate; a supply from or to another State is inter-State under section 7 of the Integrated Goods and Services Tax Act and bears the integrated tax instead.'),
  ('IN-KL', 'iso_3166_2', 'Kerala',                                   'IN', 'none', null, null, null,
   'ISO 3166-2:IN for the code. A State: the State Goods and Services Tax Act it enacted in 2017 levies the State tax on an intra-State supply made there, beside the central tax of section 9 of the Central Goods and Services Tax Act, each at half the rate; a supply from or to another State is inter-State under section 7 of the Integrated Goods and Services Tax Act and bears the integrated tax instead.'),
  ('IN-LA', 'iso_3166_2', 'Ladakh',                                   'IN', 'none', null, null, null,
   'ISO 3166-2:IN for the code. A Union territory without a legislature: the Union Territory Goods and Services Tax Act, 2017 levies the Union territory tax on an intra-State supply made there, in place of a State tax and at the same half rate, beside the central tax; a supply from or to another State or Union territory is inter-State under section 7 of the Integrated Goods and Services Tax Act.'),
  ('IN-LD', 'iso_3166_2', 'Lakshadweep',                              'IN', 'none', null, null, null,
   'ISO 3166-2:IN for the code. A Union territory without a legislature: the Union Territory Goods and Services Tax Act, 2017 levies the Union territory tax on an intra-State supply made there, in place of a State tax and at the same half rate, beside the central tax; a supply from or to another State or Union territory is inter-State under section 7 of the Integrated Goods and Services Tax Act.'),
  ('IN-MP', 'iso_3166_2', 'Madhya Pradesh',                           'IN', 'none', null, null, null,
   'ISO 3166-2:IN for the code. A State: the State Goods and Services Tax Act it enacted in 2017 levies the State tax on an intra-State supply made there, beside the central tax of section 9 of the Central Goods and Services Tax Act, each at half the rate; a supply from or to another State is inter-State under section 7 of the Integrated Goods and Services Tax Act and bears the integrated tax instead.'),
  ('IN-MH', 'iso_3166_2', 'Maharashtra',                              'IN', 'none', null, null, null,
   'ISO 3166-2:IN for the code. A State: the State Goods and Services Tax Act it enacted in 2017 levies the State tax on an intra-State supply made there, beside the central tax of section 9 of the Central Goods and Services Tax Act, each at half the rate; a supply from or to another State is inter-State under section 7 of the Integrated Goods and Services Tax Act and bears the integrated tax instead.'),
  ('IN-MN', 'iso_3166_2', 'Manipur',                                  'IN', 'none', null, null, null,
   'ISO 3166-2:IN for the code. A State: the State Goods and Services Tax Act it enacted in 2017 levies the State tax on an intra-State supply made there, beside the central tax of section 9 of the Central Goods and Services Tax Act, each at half the rate; a supply from or to another State is inter-State under section 7 of the Integrated Goods and Services Tax Act and bears the integrated tax instead.'),
  ('IN-ML', 'iso_3166_2', 'Meghālaya',                                'IN', 'none', null, null, null,
   'ISO 3166-2:IN for the code. A State: the State Goods and Services Tax Act it enacted in 2017 levies the State tax on an intra-State supply made there, beside the central tax of section 9 of the Central Goods and Services Tax Act, each at half the rate; a supply from or to another State is inter-State under section 7 of the Integrated Goods and Services Tax Act and bears the integrated tax instead.'),
  ('IN-MZ', 'iso_3166_2', 'Mizoram',                                  'IN', 'none', null, null, null,
   'ISO 3166-2:IN for the code. A State: the State Goods and Services Tax Act it enacted in 2017 levies the State tax on an intra-State supply made there, beside the central tax of section 9 of the Central Goods and Services Tax Act, each at half the rate; a supply from or to another State is inter-State under section 7 of the Integrated Goods and Services Tax Act and bears the integrated tax instead.'),
  ('IN-NL', 'iso_3166_2', 'Nagaland',                                 'IN', 'none', null, null, null,
   'ISO 3166-2:IN for the code. A State: the State Goods and Services Tax Act it enacted in 2017 levies the State tax on an intra-State supply made there, beside the central tax of section 9 of the Central Goods and Services Tax Act, each at half the rate; a supply from or to another State is inter-State under section 7 of the Integrated Goods and Services Tax Act and bears the integrated tax instead.'),
  ('IN-OD', 'iso_3166_2', 'Odisha',                                   'IN', 'none', null, null, null,
   'ISO 3166-2:IN for the code. A State: the State Goods and Services Tax Act it enacted in 2017 levies the State tax on an intra-State supply made there, beside the central tax of section 9 of the Central Goods and Services Tax Act, each at half the rate; a supply from or to another State is inter-State under section 7 of the Integrated Goods and Services Tax Act and bears the integrated tax instead.'),
  ('IN-PY', 'iso_3166_2', 'Puducherry',                               'IN', 'none', null, null, null,
   'ISO 3166-2:IN for the code. A Union territory with a legislature: for the purposes of the Goods and Services Tax it is a State, levies the State tax under a State Goods and Services Tax Act of its own (section 2(103) of the Central Goods and Services Tax Act counts it among the States), and a supply from or to another State or Union territory is inter-State under section 7 of the Integrated Goods and Services Tax Act.'),
  ('IN-PB', 'iso_3166_2', 'Punjab',                                   'IN', 'none', null, null, null,
   'ISO 3166-2:IN for the code. A State: the State Goods and Services Tax Act it enacted in 2017 levies the State tax on an intra-State supply made there, beside the central tax of section 9 of the Central Goods and Services Tax Act, each at half the rate; a supply from or to another State is inter-State under section 7 of the Integrated Goods and Services Tax Act and bears the integrated tax instead.'),
  ('IN-RJ', 'iso_3166_2', 'Rajasthan',                                'IN', 'none', null, null, null,
   'ISO 3166-2:IN for the code. A State: the State Goods and Services Tax Act it enacted in 2017 levies the State tax on an intra-State supply made there, beside the central tax of section 9 of the Central Goods and Services Tax Act, each at half the rate; a supply from or to another State is inter-State under section 7 of the Integrated Goods and Services Tax Act and bears the integrated tax instead.'),
  ('IN-SK', 'iso_3166_2', 'Sikkim',                                   'IN', 'none', null, null, null,
   'ISO 3166-2:IN for the code. A State: the State Goods and Services Tax Act it enacted in 2017 levies the State tax on an intra-State supply made there, beside the central tax of section 9 of the Central Goods and Services Tax Act, each at half the rate; a supply from or to another State is inter-State under section 7 of the Integrated Goods and Services Tax Act and bears the integrated tax instead.'),
  ('IN-TN', 'iso_3166_2', 'Tamil Nadu',                               'IN', 'none', null, null, null,
   'ISO 3166-2:IN for the code. A State: the State Goods and Services Tax Act it enacted in 2017 levies the State tax on an intra-State supply made there, beside the central tax of section 9 of the Central Goods and Services Tax Act, each at half the rate; a supply from or to another State is inter-State under section 7 of the Integrated Goods and Services Tax Act and bears the integrated tax instead.'),
  ('IN-TS', 'iso_3166_2', 'Telangana',                                'IN', 'none', null, null, null,
   'ISO 3166-2:IN for the code. A State: the State Goods and Services Tax Act it enacted in 2017 levies the State tax on an intra-State supply made there, beside the central tax of section 9 of the Central Goods and Services Tax Act, each at half the rate; a supply from or to another State is inter-State under section 7 of the Integrated Goods and Services Tax Act and bears the integrated tax instead.'),
  ('IN-TR', 'iso_3166_2', 'Tripura',                                  'IN', 'none', null, null, null,
   'ISO 3166-2:IN for the code. A State: the State Goods and Services Tax Act it enacted in 2017 levies the State tax on an intra-State supply made there, beside the central tax of section 9 of the Central Goods and Services Tax Act, each at half the rate; a supply from or to another State is inter-State under section 7 of the Integrated Goods and Services Tax Act and bears the integrated tax instead.'),
  ('IN-UP', 'iso_3166_2', 'Uttar Pradesh',                            'IN', 'none', null, null, null,
   'ISO 3166-2:IN for the code. A State: the State Goods and Services Tax Act it enacted in 2017 levies the State tax on an intra-State supply made there, beside the central tax of section 9 of the Central Goods and Services Tax Act, each at half the rate; a supply from or to another State is inter-State under section 7 of the Integrated Goods and Services Tax Act and bears the integrated tax instead.'),
  ('IN-UK', 'iso_3166_2', 'Uttarakhand',                              'IN', 'none', null, null, null,
   'ISO 3166-2:IN for the code. A State: the State Goods and Services Tax Act it enacted in 2017 levies the State tax on an intra-State supply made there, beside the central tax of section 9 of the Central Goods and Services Tax Act, each at half the rate; a supply from or to another State is inter-State under section 7 of the Integrated Goods and Services Tax Act and bears the integrated tax instead.'),
  ('IN-WB', 'iso_3166_2', 'West Bengal',                              'IN', 'none', null, null, null,
   'ISO 3166-2:IN for the code. A State: the State Goods and Services Tax Act it enacted in 2017 levies the State tax on an intra-State supply made there, beside the central tax of section 9 of the Central Goods and Services Tax Act, each at half the rate; a supply from or to another State is inter-State under section 7 of the Integrated Goods and Services Tax Act and bears the integrated tax instead.')
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
-- The row — Guatemala
--
-- A third country to the common system of VAT of Directive 2006/112/EC,
-- article 5(2), which applies only in the territory of the Community as the
-- Treaties define it. Guatemala levies its own Impuesto al Valor Agregado
-- under Decreto Número 27-92 of the Congreso de la República, unrelated to
-- the Union's common system. `vat_prefix` is null: a Guatemalan taxpayer is
-- identified by the Número de Identificación Tributaria (NIT), which the
-- Superintendencia de Administración Tributaria assigns and which carries no
-- ISO country prefix comparable to an EU VAT number.
-- ---------------------------------------------------------------------------

insert into territories (code, code_source, name, parent_code, eu_vat_scope, eu_vat_from, eu_vat_to, vat_prefix, legal_reference) values
  ('GT', 'iso_3166_1', 'Guatemala', null, 'none', null, null, null,
   'Directive 2006/112/EC, article 5(2): the common system of VAT applies in the territory of the Community as defined by the Treaties, and Guatemala is a third country to it. Guatemala levies a value added tax of its own, the Impuesto al Valor Agregado, under Decreto Número 27-92 del Congreso de la República, article 10, at a single rate of twelve per cent (12 %).')
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
-- The row — Panama
--
-- Directive 2006/112/EC, article 5(2): the common system of VAT applies in
-- the territory of the Community as defined by the Treaties, and a State
-- outside it is a third country for every rule the Directive carries.
-- Panama levies a value added tax of its own, the Impuesto de Transferencia
-- de Bienes Corporales Muebles y la Prestación de Servicios (ITBMS), under
-- article 1057-V of the Código Fiscal (Ley 8 de 1956, as added by Ley 75 de
-- 1976 and since reformed), unrelated to the Union's common system.
-- `vat_prefix` is null: a Panamanian taxpayer is identified by the Registro
-- Único de Contribuyente (RUC), which carries no ISO country prefix
-- comparable to an EU VAT number.
-- ---------------------------------------------------------------------------

insert into territories (code, code_source, name, parent_code, eu_vat_scope, eu_vat_from, eu_vat_to, vat_prefix, legal_reference) values
  ('PA', 'iso_3166_1', 'Panama', null, 'none', null, null, null,
   'Directive 2006/112/EC, article 5(2): the common system of VAT applies in the territory of the Community as defined by the Treaties, and a State outside it is a third country for every rule the Directive carries. Panama levies a value added tax of its own, the Impuesto de Transferencia de Bienes Corporales Muebles y la Prestación de Servicios (ITBMS), under article 1057-V of the Código Fiscal, which sets the rates.')
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
-- The row — Costa Rica
--
-- Directive 2006/112/EC, article 5(2), reaches only the territory of the
-- Community as the Treaties define it; Costa Rica is a third country under
-- every rule the Directive carries. It levies a value added tax of its own,
-- the Impuesto sobre el Valor Agregado, under the Ley del Impuesto sobre el
-- Valor Agregado (Ley N.° 6826 of 8 November 1982, integrally reformed by
-- Ley N.° 9635 of 3 December 2018, in force from 1 July 2019), unrelated to
-- the Union's common system. `vat_prefix` is null: a Costa Rican taxpayer is
-- identified by the cédula jurídica or física the Registro Único Tributario
-- assigns, which carries no ISO country prefix comparable to an EU VAT
-- number.
-- ---------------------------------------------------------------------------

insert into territories (code, code_source, name, parent_code, eu_vat_scope, eu_vat_from, eu_vat_to, vat_prefix, legal_reference) values
  ('CR', 'iso_3166_1', 'Costa Rica', null, 'none', null, null, null,
   'Directive 2006/112/EC, article 5(2): the common system of VAT applies in the territory of the Community as defined by the Treaties, and a State outside it is a third country for every rule the Directive carries. Costa Rica levies a value added tax of its own, the Impuesto sobre el Valor Agregado, under the Ley del Impuesto sobre el Valor Agregado (Ley N.° 6826 of 8 November 1982, reformed by Ley N.° 9635 of 3 December 2018, in force from 1 July 2019), articles 10 and 11, which set its rates.')
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
-- Georgia is outside the common system of VAT: Directive 2006/112/EC binds
-- only Member States of the European Union, and Georgia is neither a Member
-- State nor part of the European Economic Area. Georgia levies a value added
-- tax of its own, დამატებული ღირებულების გადასახადი (VAT), under Part III of
-- the Tax Code of Georgia (Law of Georgia of 17 September 2010, as amended),
-- articles 156-181, at a standard rate of 18 % under article 169, first
-- paragraph, subparagraph (a) (matsne.gov.ge/en/document/view/1043717).
-- `vat_prefix` is null: a Georgian VAT payer is addressed by the taxpayer's
-- identification number, which carries no country prefix of this table's
-- kind.
-- ---------------------------------------------------------------------------

insert into territories (code, code_source, name, parent_code, eu_vat_scope, eu_vat_from, eu_vat_to, vat_prefix, legal_reference) values
  ('GE', 'iso_3166_1', 'Georgia', null, 'none', null, null, null,
   'Directive 2006/112/EC, article 5(2): the common system of VAT applies in the territory of the Community as defined by the Treaties, and a State outside it is a third country for every rule the Directive carries. Georgia levies a value added tax of its own under Part III of the Tax Code of Georgia, articles 156-181, at a standard rate of 18 % under article 169, first paragraph, subparagraph (a) (matsne.gov.ge/en/document/view/1043717, consulted 2026-09-26).')
on conflict (code) do update set
  code_source     = excluded.code_source,
  name            = excluded.name,
  parent_code     = excluded.parent_code,
  eu_vat_scope    = excluded.eu_vat_scope,
  eu_vat_from     = excluded.eu_vat_from,
  eu_vat_to       = excluded.eu_vat_to,
  vat_prefix      = excluded.vat_prefix,
  legal_reference = excluded.legal_reference;
