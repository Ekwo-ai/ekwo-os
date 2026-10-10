-- Ekwo OS — the file of a declaration is read as a declaration.
--
-- `filings.read` was granted apart from `documents.read` on purpose: what a
-- company declared is not the same secret as what it books
-- (`20260917150000`), and the deposits that record each send ask it
-- (`20260918110000`). The two files of a deposit — what was sent, and the
-- receipt that came back — are rows of `attachments`, and every row of
-- `attachments` was read through `documents.read` and written through
-- `documents.write` (`20260913083216`). So a member whose `filings.read` was
-- withdrawn and who kept `documents.read` saw no deposit, and still read the
-- declaration that went and the acknowledgement of the administration.
-- Decision 0039 left it as an open item; this closes it.
--
-- **Which files.** Two kinds, and either is enough:
--
--   - an attachment **of a declaration** (`entity_type = 'tax_filing'`), which
--     is where the two files of a deposit are kept, from the moment they are
--     uploaded and before the deposit names them;
--   - an attachment **a deposit names**, as `sent_file_id` or
--     `acknowledgement_id`, wherever it was pinned: the trigger of
--     `20261007113412` keeps it in the declaration's company and does not
--     ask its `entity_type`.
--
-- Such a file is read with `filings.read` and written — uploaded, changed,
-- moved, deleted — with `filings.write`, the capability that writes deposits.
-- Every other attachment keeps `documents.read` and `documents.write`. The
-- two policies of a client handing a piece over (`attachments_deposit`,
-- `attachments_select_own_deposit`, `20260918113807`) are untouched: they
-- only ever reach a piece on the company itself, or one the caller filed.
--
-- **Why a definer function asks about the deposit.** A policy reads other
-- tables under the caller's own policies, and the deposits ask
-- `filings.read`: an `exists` written in the policy would find no deposit for
-- precisely the member this is about, and let the file through as an
-- ordinary one. `attachment_is_filing_deposit_file()` looks past the
-- policies of `tax_filing_deposits`, answers about one attachment and nothing
-- else, and is two probes of the indexes `20260918110000` put on the two
-- columns. On a shared installation it answers only about a company the
-- caller may know of (`may_know_of_company()`, decision 0065): an id of
-- another tenant's file gets the answer an id of nobody gets. The capabilities are compared the way `20260918141627` compares
-- them — a sub-select run once per statement — and `attachments` is a table
-- read file by file, never walked by a report.

create or replace function attachment_is_filing_deposit_file(p_attachment_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select exists (select 1 from tax_filing_deposits d join tax_filings f on f.id = d.filing_id
                  where d.sent_file_id = p_attachment_id and may_know_of_company(f.company_id))
      or exists (select 1 from tax_filing_deposits d join tax_filings f on f.id = d.filing_id
                  where d.acknowledgement_id = p_attachment_id and may_know_of_company(f.company_id));
$$;

comment on function attachment_is_filing_deposit_file(uuid) is
  'Whether a deposit of a declaration names this attachment as the file that was sent or as the receipt. Definer, because the policy of attachments asks it for callers who may not read the deposits — which is the case it exists for; it answers about one id and nothing else, and about a company the caller may not know of as about nobody (decision 0065).';

revoke execute on function attachment_is_filing_deposit_file(uuid) from public, anon;
grant execute on function attachment_is_filing_deposit_file(uuid) to authenticated, service_role;

drop policy attachments_select on attachments;
create policy attachments_select on attachments
  for select using (
    case
      when entity_type = 'tax_filing' or attachment_is_filing_deposit_file(id)
        then company_id = any ((select companies_with_capability('filings.read'))::uuid[])
      else company_id = any ((select companies_with_capability('documents.read'))::uuid[])
    end
  );

comment on policy attachments_select on attachments is
  'documents.read, except for the files of a declaration — attached to a tax_filing, or named by a deposit as what was sent or the receipt — which are proof of filing and read with filings.read, like the deposits themselves.';

drop policy attachments_write on attachments;
create policy attachments_write on attachments
  for all using (
    case
      when entity_type = 'tax_filing' or attachment_is_filing_deposit_file(id)
        then company_id = any ((select companies_with_capability('filings.write'))::uuid[])
      else company_id = any ((select companies_with_capability('documents.write'))::uuid[])
    end
  )
  -- A check is asked once per row written, as `20260918141627` leaves it.
  with check (
    case
      when entity_type = 'tax_filing' or attachment_is_filing_deposit_file(id)
        then has_capability(company_id, 'filings.write')
      else has_capability(company_id, 'documents.write')
    end
  );

comment on policy attachments_write on attachments is
  'documents.write, except for the files of a declaration — attached to a tax_filing, or named by a deposit — which are written with filings.write, the capability that records a deposit. Moving a file onto a declaration needs both: the old row is asked documents.write, the new one filings.write.';
