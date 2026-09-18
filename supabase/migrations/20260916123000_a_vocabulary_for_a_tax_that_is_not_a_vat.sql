-- Ekwo OS — the words a country with no value added tax needed.
--
-- The first pack of a country outside the common system of VAT — sales tax
-- and use tax, `kind` `sales_tax`, nothing recoverable at any stage — asked
-- the vocabulary three questions it could not answer. Two of them are here;
-- the third is a rule of `ekwo pack check` and touches no table.
--
-- ## A tax the buyer assesses on themselves, which is not a reverse charge
--
-- `tax_treatment` had `domestic_reverse_charge` for the case where national
-- law moves the liability for **the value added tax** from a supplier
-- established in the buyer's country to the buyer, and
-- `foreign_services_received` for the general business-to-business rule of
-- articles 44 and 196 of Directive 2006/112/EC. Both are operations of a
-- system in which the buyer, having charged themselves, deducts the same
-- amount at the other end; both sit behind an invoice a supplier issued and
-- was relieved on.
--
-- California's use tax is none of that. Section 6201 of the Revenue and
-- Taxation Code imposes an excise tax on the storage, use or other consumption
-- in the State of tangible personal property purchased from any retailer, and
-- section 6202(a) makes the person storing, using or consuming it liable for
-- it. There is no exempt supply behind it, no supplier who was relieved of
-- anything, no recapitulative statement, and nothing at all is recovered: the
-- tax is a cost, which is why the same document carries a `tax_on_base`
-- posting. `packs/us/` said `domestic_reverse_charge` because that was the
-- only word for a liability sitting with the buyer, and wrote into its own
-- `legal_reference` that it was not one — a pack contradicting itself in
-- prose, which `docs/international.md` recorded as a gap the day the pack
-- landed.
--
-- `self_assessed` is that word: **a tax a buyer owes directly to an
-- administration under that administration's own law, and computes and
-- declares themselves.** It says nothing about a supplier, because there may
-- be no supplier the levying State can reach, and nothing about recovery,
-- because that is what the postings say.
--
-- It is not refused inside the common system, and the restraint is
-- deliberate: a Member State levying a duty of its own that a buyer
-- self-assesses would be describing this and not article 194. What tells the
-- two apart is the law each tax cites, which every tax already carries.
--
-- The value is placed beside `domestic_reverse_charge` so that the two
-- mechanisms in which a buyer charges themselves read together, in the enum,
-- in `TAX_TREATMENTS` and in the pack schema — the one ordering
-- `tests/vat_codes.test.ts` holds across the three — and so that the four
-- intra-Community supplies stay contiguous after it.
--
-- Nothing in the ledger branches on a treatment, here or anywhere. What a tax
-- *does* is said by its postings. What this value changes is what a pack is
-- allowed to say about the tax's EN 16931 category — a buyer assessing a tax
-- on themselves under a State's own law holds no invoice the standard
-- governs, so there is no category of a supplier's to record.
--
-- ## What an exemption depends on
--
-- A sale for resale is untaxed because the seller holds a resale certificate:
-- section 6091 presumes every receipt taxable until they take one from the
-- purchaser, and Regulation 1668 says what it has to contain. A seller must
-- collect in a State where they have economic nexus, which since *South
-- Dakota v. Wayfair* is a running total of sales into it. A sale of food is
-- untaxed under section 6359 unless it is hot, or carbonated, or alcoholic, or
-- eaten where admission was charged.
--
-- Three exemptions, three answers that are not in the books, and one column of
-- `tax_templates` that carried none of it: a pack could state the code a
-- bookkeeper reaches for **once the answer is known** and could not say what
-- the question was. A reader of the chart saw three zero-rated codes and one
-- long sentence each.
--
-- `conditions` is the smallest thing that says it: **what the exemption turns
-- on, and never how to evaluate it.** A closed vocabulary of five words, no
-- value beside any of them — no threshold amount, no certificate number, no
-- operator and no expression — because a pack that could carry the test would
-- be a pack that executes, which is the one thing this format exists not to
-- be. The amount of a threshold and the contents of a certificate are in the
-- article the tax already cites; what is recorded here is that there **is** a
-- certificate, and that there **is** a threshold, so that an application can
-- put the question to a human being instead of pretending to answer it.
--
--   `buyer_certificate`  the buyer hands the seller a document the seller has
--                        to hold and be able to produce.
--   `buyer_status`       a quality of the buyer the statute names — a
--                        government, a body the law exempts as such.
--   `transport_evidence` proof that what was sold went where the exemption
--                        requires it to have gone.
--   `seller_threshold`   a running total the seller crossed, or has not.
--   `supply_nature`      what is supplied, classified more finely than any
--                        ledger holds it.
--
-- It stops at `tax_templates` and does not reach `taxes`, exactly as
-- `source_key` does and for the same reason: this is the pack's transcription
-- of a country's rule, not a property of the tax a company went on to edit.
-- A company's `taxes` row carries `country` and `code`, which is the join, and
-- nothing in the ledger reads either column.
--
-- Two halves of the American note are **not** closed by this and are written
-- up in `docs/international.md`: there is still no place on a contact for a
-- certificate and its validity, and no place anywhere for a rolling total per
-- territory. Both are larger than the pack format — one is document
-- management and the other is reporting — and neither is invented here.
--
-- ## Which entry of a register is the list BT-121 comes from
--
-- The third change is one line of a comment. `vatRegime()` used to take the
-- **first** entry of `certification.sources` whose `kind` was `standard` and
-- treat its title as the published list an exemption reason code outside the
-- Union may be taken from. `standard` means "a technical norm or code list",
-- which the FASB Accounting Standards Codification and FRS 102 both are, so
-- naming an accounting standard silently authorised a reason code on any tax
-- of the pack. No pack carries one and nothing wrong was ever emitted; the
-- mechanism was a trap all the same. An entry now says so of itself, with
-- `reason_codes`, and `ekwo pack check` refuses a second one and refuses the
-- flag on an entry that is not a `standard`. The register is a jsonb column,
-- so the shape it documents is the only thing here that moves.
--
-- A value added to an enum cannot be used in the transaction that adds it.
-- Nothing below uses `self_assessed`; the seeds that do are applied after.

alter type tax_treatment add value 'self_assessed' after 'domestic_reverse_charge';

-- What an exemption or a rate turns on, where the answer is not in the books.
-- A closed vocabulary and never a test: no value, no operator, no expression.
create type tax_condition as enum (
  'buyer_certificate',
  'buyer_status',
  'transport_evidence',
  'seller_threshold',
  'supply_nature'
);

alter table tax_templates
  add column if not exists conditions tax_condition[] not null default '{}'::tax_condition[];

comment on column tax_templates.conditions is
  'What this tax turns on that the ledger cannot see, from a closed vocabulary: buyer_certificate, buyer_status, transport_evidence, seller_threshold, supply_nature. It says what the question is, never how to answer it — there is no value, no operator and no expression here, and the article that sets a threshold or prescribes a certificate is in legal_reference. Written by the generated seed; read by nothing in the ledger.';

comment on column country_packs.sources is
  'Register of the texts this pack was built from, in the pack''s own order: [{key, title, publisher, url, consulted_on, kind, reason_codes}]. `kind` is one of law, regulation, form, standard, portal, guidance. `reason_codes` is true on the one entry — at most one, and a `standard` — that publishes the list an exemption reason code of this country comes from; absent everywhere else. Written by the generated seed; never a copy of the text itself.';

-- No table, view or function is created. A type is reachable by whoever can
-- already read the column that uses it, and a column added to a table is
-- reachable by whoever could already select that table, under the policies it
-- already has. So there is nothing to grant and nothing to revoke.
