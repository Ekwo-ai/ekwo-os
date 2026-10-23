-- Ekwo OS — a declaration whose debt was matched before matching said so is paid.
--
-- `20261023124650` made a declaration paid when the line its settlement
-- carried the net on is matched in full — by the trigger
-- `tax_filings_paid_by_matching`, which fires when `matched_amount` moves. A
-- debt matched before that migration ran never moved again, so its
-- declaration stayed `accepted` with its money in the bank.
--
-- This finds them and records `paid` through `record_filing_outcome()`, the
-- function the trigger calls, so the declaration and its last deposit carry
-- the outcome exactly as if the payment had been matched today. The line is
-- the one the trigger reads: in the settlement entry, on the account the pack
-- names for the side the period ended on — `tax_payable_code`, or for a
-- credit `tax_receivable_code` where the pack names one — with something to
-- pay and nothing left open. A debt paid in part stays accepted, as it would
-- by the trigger.
--
-- It only ever reads `accepted` declarations and writes them `paid`, so a
-- second run finds nothing to do.

do $$
declare
  r record;
begin
  for r in
    select f.id
      from tax_filings f
      join companies c on c.id = f.company_id
      join country_defaults d on d.country = c.fiscal_country
     where f.state = 'accepted'
       and f.settlement_entry_id is not null
       and exists (
         select 1 from entry_lines l
          where l.entry_id = f.settlement_entry_id
            and l.account_id = account_id_by_code(f.company_id,
                  case when f.credit_treatment is null then d.tax_payable_code
                       else coalesce(d.tax_receivable_code, d.tax_payable_code) end)
            and abs(l.debit - l.credit) > 0
            and abs(l.debit - l.credit) - l.matched_amount = 0)
     order by f.company_id, f.period_start, f.id
  loop
    perform record_filing_outcome(r.id, 'paid');
  end loop;
end;
$$;
