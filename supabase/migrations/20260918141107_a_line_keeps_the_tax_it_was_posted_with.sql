-- Ekwo OS — a line keeps the category and the rate it was posted with.
--
-- `document_lines.vat_category` and `.vat_rate` have been there since the
-- table was, and three migrations have cited them as the precedent for a
-- snapshot: `20260915191200` for the language of a document, `20260915195000`
-- for a price that holds its tax, `20260915181000` for a territory. Nothing
-- ever wrote them. Every line of every golden year has them null, the view
-- publishes them as BT-151 and BT-152 all the same, and the first reader that
-- needed them — the brick that writes a Peppol invoice — found nothing and
-- went round by `tax_id`. `tests/vat_category.test.ts` had found it earlier
-- and said so in a comment: "Nothing in the core writes it."
--
-- The two ways out were to fill the columns or to take them out of the view.
-- They are filled, and the reason is the one those three migrations gave
-- while believing it already true: **what is posted does not move.** A tax
-- belongs to a company and a pack upgrade rewrites it in place — `amount`,
-- `vat_category` and the rest, in one `update taxes` — so a view that reads
-- the category and the rate of a sent invoice through `tax_id` reads what the
-- pack says today. A rate that changes on 1 January would restate every
-- invoice of December the first time anybody rendered one.
--
-- Four decisions.
--
-- **Derived, never keyed.** The category and the rate are facts about the tax
-- and not choices of the line, which is what `unit_price_includes_tax` is
-- already: a caller that writes them is overwritten while the document is a
-- draft. `vat_rate` is a percentage, so a tax that is a fixed amount leaves it
-- null — BT-152 has no room for an amount, and `post_document()` refuses such
-- a tax anyway.
--
-- **A draft follows its tax; a posted line refuses to move.** The same shape
-- as `documents_guard_language`: the line trigger reads the tax on every write
-- of a draft, a tax that changes reaches the drafts that carry it, and from
-- the moment the document is no longer a draft a change to either column is
-- refused by name, `document_line_tax_frozen`. Refused rather than quietly
-- ignored, because the one caller with a reason to write these columns is an
-- application that used to do the core's job, and it should learn that it no
-- longer has to.
--
-- **The breakdown reads the line, not the tax.** `document_tax_summary` is
-- BT-118 and BT-119, and it is also where `documents_refresh_totals()` and
-- `post_document()` take their figures. Reading the category and the rate
-- from the tax there while the lines carry a snapshot would have made the two
-- halves of one invoice disagree the day a rate moves — and would have kept
-- the older hazard, which is that touching a line of a posted document
-- recomputes its totals at today's rate. The view now groups on what the lines
-- carry. For a draft that is the tax, by construction; for a posted document
-- it is the tax as it stood. Same columns, same order, same types.
--
-- **The lines already here take the tax of today, once.** Nobody knows what
-- rate a tax had on the day an old invoice was posted: the ledger kept the
-- amounts and not the percentage. The tax as it stands is the only evidence
-- the installation holds, it is what every read of these documents has
-- answered until now, and it is what the totals were last computed from — so
-- the backfill changes no figure. It is a guess for the same reason the
-- backfill of `documents.language` was, and from here on nothing is guessed.
-- A line somebody's application had already stamped keeps its stamp.
--
-- What this does not close, and says so: the *share* of a tax that reaches the
-- other party (`tax_charged`) is still read from `tax_postings` as they stand,
-- and the exemption code and the legal reference of a tax are still read from
-- the tax. None of the three changes a base or a rate; all three are a pack
-- correcting itself under a document already sent. And no trigger refuses a
-- change of `quantity`, `unit_price` or `tax_id` on a posted line: the ledger
-- is immutable and the document that produced it is only partly so. That is
-- older than this file and wider than it.

-- ---------------------------------------------------------------------------
-- 1. What the lines already here carry
--
-- Before the guard exists, because it would refuse exactly this. The row
-- triggers fire, as they did for the backfill of `documents.language`: the
-- totals they recompute are read from the same tax the snapshot is being
-- taken from, so they come back unchanged.
-- ---------------------------------------------------------------------------

update document_lines l
   set vat_category = t.vat_category,
       vat_rate     = case when t.amount_type = 'percent' then t.amount end
  from taxes t, documents d
 where t.id = l.tax_id
   and d.id = l.document_id
   and l.line_type = 'product'
   and (d.state = 'draft' or (l.vat_category is null and l.vat_rate is null))
   and (l.vat_category is distinct from t.vat_category
        or l.vat_rate is distinct from case when t.amount_type = 'percent' then t.amount end);

-- ---------------------------------------------------------------------------
-- 2. Writing it, and refusing to rewrite it
-- ---------------------------------------------------------------------------

create or replace function document_lines_snapshot_tax()
returns trigger
language plpgsql
as $$
declare
  v_state  doc_state;
  v_number text;
begin
  select d.state, d.number into v_state, v_number
    from documents d where d.id = new.document_id;

  if tg_op = 'UPDATE' and v_state <> 'draft' then
    if new.vat_category is distinct from old.vat_category
       or new.vat_rate is distinct from old.vat_rate then
      raise exception 'document_line_tax_frozen: line % of % was posted under category % at % per cent, and keeps both. A document already issued is not rewritten because its tax changed; credit it and issue another.',
        new.sequence, coalesce(v_number, new.document_id::text),
        coalesce(old.vat_category, 'none'), coalesce(old.vat_rate::text, 'no')
        using errcode = '55006';
    end if;
    return new;
  end if;

  if new.line_type <> 'product' or new.tax_id is null then
    new.vat_category := null;
    new.vat_rate     := null;
    return new;
  end if;

  select t.vat_category,
         case when t.amount_type = 'percent' then t.amount end
    into new.vat_category, new.vat_rate
    from taxes t where t.id = new.tax_id;
  return new;
end;
$$;

comment on function document_lines_snapshot_tax() is
  'Writes BT-151 and BT-152 on a line from its tax for as long as the document is a draft, and refuses document_line_tax_frozen on a change to either once it is not.';

create trigger document_lines_snapshot_tax
  before insert or update on document_lines
  for each row execute function document_lines_snapshot_tax();

-- A trigger body is invoked by its table, never called.
revoke execute on function document_lines_snapshot_tax() from public, anon, authenticated, service_role;

comment on column document_lines.vat_category is
  'EN 16931 BT-151 as the line carries it. Derived from the tax while the document is a draft and frozen when it is posted, so a pack upgrade that recategorises a tax cannot rewrite an invoice that has been sent. Never keyed.';

comment on column document_lines.vat_rate is
  'EN 16931 BT-152 as the line carries it: the percentage of the tax, derived while the document is a draft and frozen when it is posted, so a later change of rate cannot rewrite an invoice that has been sent. Null where the tax is not a percentage. Never keyed.';

-- ---------------------------------------------------------------------------
-- 3. A tax that changes, and the drafts that carry it
--
-- The other half of "a draft follows its tax": a draft nobody touches again
-- would keep an answer that is no longer the tax's. Bounded to the draft lines
-- of that one tax — `document_lines_tax_idx` is the index it reads — and the
-- write goes through the line's own triggers, so the totals of those drafts
-- follow the new rate too, which until now they did not until somebody edited
-- a line.
--
-- `price_include` is deliberately not among the columns that fire it. The
-- lines are rewritten one at a time, and a group caught half way between a
-- price with its tax and a price without is what `mixed_price_include`
-- refuses: the flag would make the correction of a tax fail on the first
-- draft with two lines. That snapshot keeps the rule it was published with.
--
-- `security definer`, for the reason `contacts_language_reaches_drafts` gives:
-- whoever may correct a tax is not thereby allowed to write a document, and
-- should not be refused because a draft sits behind a policy they do not
-- satisfy. What is written is derived data on rows nothing has issued yet.
-- ---------------------------------------------------------------------------

create or replace function taxes_reach_draft_lines()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  update document_lines l
     set vat_category = new.vat_category
    from documents d
   where l.tax_id = new.id
     and d.id = l.document_id
     and d.state = 'draft';
  return null;
end;
$$;

comment on function taxes_reach_draft_lines() is
  'A tax whose category, rate or kind of amount changes rewrites the snapshot of the draft lines that carry it, and nothing else: a posted line keeps what it was posted with.';

create trigger taxes_reach_draft_lines
  after update of vat_category, amount, amount_type on taxes
  for each row
  when (new.vat_category is distinct from old.vat_category
        or new.amount is distinct from old.amount
        or new.amount_type is distinct from old.amount_type)
  execute function taxes_reach_draft_lines();

revoke execute on function taxes_reach_draft_lines() from public, anon, authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 4. The breakdown groups on what the lines carry
--
-- `20260915195000` unchanged but for where the category and the rate come
-- from. `tax_rate` keeps the type it had — a view column cannot change type
-- under `create or replace` — and the arithmetic reads the same figure it
-- publishes. `security_invoker`, the comment and the grants are those of the
-- object it replaces; the grants are restated because saying so again is
-- cheaper than trusting it.
-- ---------------------------------------------------------------------------

create or replace view document_tax_summary
  with (security_invoker = true) as
  select l.document_id,
         l.company_id,
         d.doc_type,
         l.tax_id,
         t.code    as tax_code,
         t.name    as tax_name,
         l.vat_category,
         l.vat_rate::numeric(12, 4) as tax_rate,
         sum(l.amount_untaxed) as base_amount,
         -- Gross tax: what the VAT return reports.
         round_amount(
           case when bool_and(l.unit_price_includes_tax)
                then sum(l.amount_incl_tax)
                     - sum(l.amount_incl_tax) / (1 + coalesce(l.vat_rate, 0) / 100)
                else sum(l.amount_untaxed) * coalesce(l.vat_rate, 0) / 100
           end,
           rounding_of(l.company_id, d.currency_code)) as tax_amount,
         -- Charged tax: what the other party actually pays. Zero when the tax
         -- postings net out, which is exactly what self-assessment means.
         round_amount(
           case when bool_and(l.unit_price_includes_tax)
                then sum(l.amount_incl_tax)
                     - sum(l.amount_incl_tax) / (1 + coalesce(l.vat_rate, 0) / 100)
                else sum(l.amount_untaxed) * coalesce(l.vat_rate, 0) / 100
           end
           * coalesce((
               select sum(tp.factor_percent)
                 from tax_postings tp
                where tp.tax_id = t.id
                  and tp.posting_type in ('tax', 'tax_on_base')
                  and tp.document_kind = case
                        when d.doc_type in ('sale_credit_note', 'purchase_credit_note')
                          then 'credit_note'::tax_document_kind
                        else 'invoice'::tax_document_kind
                      end
             ), 100) / 100,
           rounding_of(l.company_id, d.currency_code)) as tax_charged
    from document_lines l
    join documents d on d.id = l.document_id
    left join taxes t on t.id = l.tax_id
   where l.line_type = 'product'
   group by l.document_id, l.company_id, d.doc_type, d.currency_code, l.tax_id,
            t.id, t.code, t.name, l.vat_category, l.vat_rate;

comment on view document_tax_summary is
  'VAT breakdown of a document, one row per tax, rounded once on the group (EN 16931 BR-CO-14) — on the group''s base, or on the gross it was quoted at where the price includes the tax. The category and the rate are the ones the lines carry: the tax of today for a draft, the tax as it stood for a document that was posted.';

grant select on table document_tax_summary to authenticated, service_role;
