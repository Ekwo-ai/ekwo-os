-- Ekwo — the `einvoicing` module, version 1.2.0: clearance, the invoice the
-- tax authority validates before it is issued.
--
-- Version 1.1.0 gave the module two regimes of fiscalisation: a record
-- chained by a hash for every invoice, and the documents' data reported to
-- the authority. A third shape is spreading: the invoice is **submitted to
-- the authority before it is issued**, the authority checks it and answers,
-- and without its validation the invoice is not an invoice. The model below
-- was confronted with three of them before a line of it was written.
--
--   * **Malaysia, MyInvois (LHDNM).** A submission is answered with a
--     reference for the submission and, per document, a verdict: Valid with
--     the document's unique identifier (UIN), the moment it was validated and
--     a link to the authority's validation page, which the invoice carries as
--     a QR code; or Invalid, with the errors found. The issuer may cancel a
--     validated invoice within 72 hours of its validation, giving a reason;
--     within the same 72 hours the buyer may reject it, giving a reason, and
--     the issuer then cancels it or keeps it. Past that window, a correction
--     is a credit note.
--   * **Poland, KSeF.** An invoice sent is answered with a reference for the
--     sending, then with the KSeF number the system gives the invoice and the
--     moment it was received; or a refusal with its code and description.
--     The link of its QR code is built by the issuer from the invoice itself,
--     not returned. Nothing is cancelled and the buyer rejects nothing in the
--     system: a correction is a correcting invoice.
--   * **Italy, SdI.** A file sent is given the system's own identifier on
--     receipt, then either a receipt of delivery, with its moment, or a
--     rejection notice with the errors; a rejected file is corrected and
--     sent again. The invoice carries no verification link. A delivered
--     invoice is not cancelled; a public buyer may refuse one within a
--     period the law sets, a private one cannot.
--
-- What the three share is what this file keeps, and nothing named after any
-- of them:
--
--   * **a clearance** is one submission of one posted sale to the authority,
--     numbered per document — attempt 1, 2 … — in a state of four words:
--     `submitted` (it left, nobody has answered), `validated` (the authority
--     gave it its identifier and the moment of validation, and the link the
--     invoice carries where the regime has one), `rejected` (by the
--     authority, with its reason — or, after a validation and within the
--     window the pack declares, by the buyer, with theirs) and `cancelled`
--     (by the issuer, after a validation and within the window the pack
--     declares). A rejection by the authority closes an attempt and a
--     corrected submission is the next one; a cancellation closes the
--     document's clearance for good — the invoice is void at the authority,
--     and the books undo it with `cancel_document()`.
--   * **every answer, word for word**, is appended to `einvoicing.fiscal_events`
--     — the module's journal of what happens beside the invoices — under the
--     regime's format, as `clearance_submitted`, `clearance_validated`,
--     `clearance_rejected`, `clearance_cancelled`, with what the authority
--     said in `detail.answer`.
--
-- **The transport is not here.** The module calls no authority: it records a
-- submission somebody made and an answer somebody received, and refuses what
-- cannot have happened — an answer to nothing submitted, a validation without
-- its identifier, a state that goes back, a cancellation the regime does not
-- allow or that comes after its window. The host that talks to the authority
-- calls the two functions below; Ekwo Cloud will be one such host.
--
-- **The pack says the regime.** `einvoicing.fiscalisation.clearance` in the
-- pack of the company's fiscal country, compiled by the socle into
-- `country_defaults.einvoice_fiscalisation` with `kind` = `clearance`: where
-- the verification link comes from (`returned`, `computed`, `none`) and the
-- two windows, as ISO 8601 durations (`PT72H`), each left out where the law
-- grants none. The socle's shape check of that column already accepts the
-- block; no socle migration is needed.
--
-- **Nothing is submitted by a trigger.** A posted sale of a company under a
-- clearance regime that has no validation is named by `fiscalisationStatus()`
-- in `@ekwo-ai/core`; the submission is somebody's gesture.

-- ---------------------------------------------------------------------------
-- Vocabulary
-- ---------------------------------------------------------------------------

create type einvoicing.clearance_state as enum ('submitted', 'validated', 'rejected', 'cancelled');

comment on type einvoicing.clearance_state is
  'Where one submission of an invoice to the authority stands. submitted: it left and nobody has answered. validated: the authority gave it its identifier; the invoice is valid. rejected: by the authority, which did not validate it, or after its validation by the buyer, within the window the regime allows. cancelled: by the issuer, after its validation and within the window the regime allows; the invoice is void.';

-- ---------------------------------------------------------------------------
-- The clearances
-- ---------------------------------------------------------------------------

create table einvoicing.clearances (
  id                  uuid primary key default gen_random_uuid(),
  company_id          uuid not null references public.companies(id) on delete cascade,
  document_id         uuid not null,
  attempt             integer not null,
  -- The format of the regime when the invoice was submitted, as the pack names it.
  format              text not null,
  state               einvoicing.clearance_state not null default 'submitted',
  -- The file submitted, where this module kept it; null where the host wrote it.
  issue_id            uuid,
  -- What the authority named the submission, where it named it on receipt.
  reference           text,
  submitted_at        timestamptz not null,
  submitted_by        uuid,
  -- What the authority gave the invoice when it validated it.
  identifier          text,
  validated_at        timestamptz,
  verification_url    text,
  rejected_by         text,
  rejected_at         timestamptz,
  rejection_reason    text,
  cancelled_at        timestamptz,
  cancellation_reason text,
  updated_at          timestamptz not null default now(),
  foreign key (document_id, company_id) references public.documents (id, company_id),
  foreign key (issue_id, company_id) references einvoicing.issues (id, company_id),
  unique (document_id, attempt),
  constraint einvoicing_clearances_attempt check (attempt >= 1),
  constraint einvoicing_clearances_format check (nullif(btrim(format), '') is not null),
  constraint einvoicing_clearances_rejected_by check (rejected_by is null or rejected_by in ('authority', 'buyer')),
  constraint einvoicing_clearances_url check (verification_url is null or verification_url ~ '^https://'),
  constraint einvoicing_clearances_submitted check (
    state <> 'submitted' or (identifier is null and validated_at is null and rejected_at is null and cancelled_at is null)
  ),
  constraint einvoicing_clearances_validated check (
    (state not in ('validated', 'cancelled') and not (state = 'rejected' and rejected_by = 'buyer'))
    or (nullif(btrim(identifier), '') is not null and validated_at is not null)
  ),
  constraint einvoicing_clearances_rejected check (
    state <> 'rejected' or (rejected_by is not null and rejected_at is not null and nullif(btrim(rejection_reason), '') is not null)
  ),
  constraint einvoicing_clearances_cancelled check (
    state <> 'cancelled' or (cancelled_at is not null and nullif(btrim(cancellation_reason), '') is not null)
  )
);

comment on table einvoicing.clearances is
  'Every submission of a posted sale to the tax authority under a clearance regime, numbered per document, with the state the authority''s answers brought it to and what it gave the invoice: its identifier, the moment of validation, the verification link. Written by einvoicing.record_clearance_submission() and einvoicing.record_clearance_answer() alone; a state only moves forward and nothing is deleted. The answers themselves, verbatim, are in einvoicing.fiscal_events.';
comment on column einvoicing.clearances.attempt is
  'The submission''s number among those of its document, from 1. An attempt the authority rejected is followed by the next; a validated or cancelled one is the last.';
comment on column einvoicing.clearances.identifier is
  'The identifier the authority gave the invoice when it validated it. Unique per format: no two invoices carry one.';
comment on column einvoicing.clearances.verification_url is
  'The link to the authority''s verification of the invoice, which the invoice carries — usually as a QR code — where the regime has one: returned by the authority, or computed by the issuer from its answer, as the pack''s clearance.verification says.';
comment on column einvoicing.clearances.rejected_by is
  'Who rejected it: the authority, which did not validate it, or the buyer, after its validation and within the regime''s rejection_window.';

create unique index einvoicing_clearances_id_company_idx on einvoicing.clearances (id, company_id);
create index einvoicing_clearances_company_state_idx on einvoicing.clearances (company_id, state);
create index einvoicing_clearances_document_company_idx on einvoicing.clearances (document_id, company_id);
create index einvoicing_clearances_issue_company_idx on einvoicing.clearances (issue_id, company_id);
-- One submission of a document stands at a time: waiting, valid, or rejected
-- by its buyer and not yet cancelled — the invoice is still valid at the
-- authority until it is.
create unique index einvoicing_clearances_one_standing_idx on einvoicing.clearances (document_id)
  where state in ('submitted', 'validated') or (state = 'rejected' and rejected_by = 'buyer');
create unique index einvoicing_clearances_identifier_idx on einvoicing.clearances (company_id, format, identifier)
  where identifier is not null;

-- ---------------------------------------------------------------------------
-- The guard: a state only moves forward, and what was given stays
-- ---------------------------------------------------------------------------

create or replace function einvoicing.guard_clearance()
returns trigger
language plpgsql
as $$
begin
  if tg_op = 'DELETE' then
    raise exception 'clearance_recorded: a submission to the authority is part of the history of a document and is not deleted'
      using errcode = '55006';
  end if;
  if (new.id, new.company_id, new.document_id, new.attempt, new.format, new.issue_id, new.reference, new.submitted_at, new.submitted_by)
     is distinct from
     (old.id, old.company_id, old.document_id, old.attempt, old.format, old.issue_id, old.reference, old.submitted_at, old.submitted_by) then
    raise exception 'clearance_recorded: what was submitted, when and by whom does not change once recorded; only the authority''s answers move a submission'
      using errcode = '55006';
  end if;
  if old.validated_at is not null
     and (new.identifier, new.validated_at, new.verification_url) is distinct from (old.identifier, old.validated_at, old.verification_url) then
    raise exception 'clearance_recorded: the identifier, the moment of validation and the verification link the authority gave do not change once recorded'
      using errcode = '55006';
  end if;
  if not ((old.state = 'submitted' and new.state = 'validated')
          or (old.state = 'submitted' and new.state = 'rejected' and new.rejected_by = 'authority')
          or (old.state = 'validated' and new.state = 'rejected' and new.rejected_by = 'buyer')
          or (old.state = 'validated' and new.state = 'cancelled')
          or (old.state = 'rejected' and old.rejected_by = 'buyer' and new.state = 'cancelled')) then
    raise exception 'clearance_state_backwards: a submission that is % does not become %',
      old.state || case when old.state = 'rejected' then ' by the ' || old.rejected_by else '' end,
      new.state || case when new.state = 'rejected' then ' by the ' || coalesce(new.rejected_by, 'nobody') else '' end
      using errcode = '55006';
  end if;
  if old.rejected_at is not null
     and (new.rejected_by, new.rejected_at, new.rejection_reason) is distinct from (old.rejected_by, old.rejected_at, old.rejection_reason) then
    raise exception 'clearance_recorded: a rejection, its moment and its reason do not change once recorded'
      using errcode = '55006';
  end if;
  new.updated_at := now();
  return new;
end;
$$;

comment on function einvoicing.guard_clearance() is
  'Refuses a delete of a clearance, a change of what was submitted, of what the authority gave on validation or of a rejection once recorded (clearance_recorded), and every move of state but the five forward ones: submitted to validated, submitted to rejected by the authority, validated to rejected by the buyer, validated to cancelled, rejected by the buyer to cancelled (clearance_state_backwards).';

create trigger einvoicing_clearances_guard
  before update or delete on einvoicing.clearances
  for each row execute function einvoicing.guard_clearance();

-- ---------------------------------------------------------------------------
-- What both functions read first
-- ---------------------------------------------------------------------------

create or replace function einvoicing.clearance_document(p_document_id uuid, p_what text)
returns public.documents
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare
  v_doc    public.documents%rowtype;
  v_what   text;
  v_regime jsonb;
begin
  select * into v_doc from public.documents d where d.id = p_document_id;
  if not found or not public.may_know_of_company(v_doc.company_id) then
    raise exception 'unknown_document: document % does not exist', p_document_id
      using errcode = 'P0002';
  end if;
  perform einvoicing.require(v_doc.company_id, 'einvoicing.send', p_what);
  if not public.is_installer() and not public.has_capability(v_doc.company_id, 'documents.read') then
    raise exception 'not_allowed: % needs documents.read', p_what
      using errcode = '42501';
  end if;

  v_what := v_doc.doc_type || ' ' || coalesce(v_doc.number, v_doc.id::text);
  if v_doc.doc_type not in ('sale_invoice', 'sale_credit_note') then
    raise exception 'document_not_a_sale: % is not a sale invoice or a sale credit note, and only a sale is submitted by its seller for validation',
      v_what;
  end if;
  if v_doc.state = 'draft' then
    raise exception 'document_not_posted: % is a draft, and only a posted document is submitted: post it first, and the authority validates what the books say',
      v_what;
  end if;

  v_regime := einvoicing.fiscal_regime(v_doc.company_id);
  if v_regime is null then
    raise exception 'no_fiscalisation_regime: the country pack of this company declares no fiscalisation regime, so % is submitted to no authority for validation',
      v_what;
  end if;
  if v_regime ->> 'kind' is distinct from 'clearance' then
    raise exception 'fiscal_regime_not_clearance: the country pack of this company declares a % regime, %, in which the authority validates no invoice before it is issued; % is not submitted for validation',
      coalesce(v_regime ->> 'kind', 'chained'), v_regime ->> 'format', v_what;
  end if;
  return v_doc;
end;
$$;

comment on function einvoicing.clearance_document(uuid, text) is
  'The document a clearance is recorded for, after every check the two clearance functions share: the document exists and the caller may know of it (unknown_document), einvoicing.send and documents.read (not_allowed), a sale (document_not_a_sale) that was posted (document_not_posted), a regime (no_fiscalisation_regime) of kind clearance (fiscal_regime_not_clearance).';

-- ---------------------------------------------------------------------------
-- record_clearance_submission: the invoice left for the authority
-- ---------------------------------------------------------------------------

create or replace function einvoicing.record_clearance_submission(
  p_document_id  uuid,
  p_reference    text default null,
  p_issue_id     uuid default null,
  p_submitted_at timestamptz default null,
  p_answer       jsonb default null
)
returns einvoicing.clearances
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_doc     public.documents%rowtype;
  v_regime  jsonb;
  v_company uuid;
  v_what    text;
  v_issue   einvoicing.issues%rowtype;
  v_last    einvoicing.clearances%rowtype;
  v_row     einvoicing.clearances%rowtype;
begin
  v_doc := einvoicing.clearance_document(p_document_id, 'recording a submission to the authority');
  v_company := v_doc.company_id;
  v_regime := einvoicing.fiscal_regime(v_company);
  v_what := v_doc.doc_type || ' ' || coalesce(v_doc.number, v_doc.id::text);
  if v_doc.state <> 'posted' then
    raise exception 'document_not_posted: % is %, and only a posted document is submitted', v_what, v_doc.state;
  end if;
  if p_answer is not null and jsonb_typeof(p_answer) <> 'object' then
    raise exception 'bad_clearance_answer: what the authority answered is kept as an object, as it said it';
  end if;
  if p_reference is not null and nullif(btrim(p_reference), '') is null then
    raise exception 'bad_clearance_answer: a reference, where the authority gave one, is not blank';
  end if;

  if p_issue_id is not null then
    select * into v_issue from einvoicing.issues i
     where i.id = p_issue_id and i.document_id = p_document_id and i.artefact = 'einvoice';
    if not found then
      raise exception 'unknown_einvoice: no electronic invoice % was issued for %', p_issue_id, v_what
        using errcode = 'P0002';
    end if;
    if not v_issue.sendable then
      raise exception 'einvoice_not_sendable: the file % breaks % rule(s) of %, and a file that breaks one is not submitted. Complete the books it is written from and issue it again.',
        v_issue.filename, jsonb_array_length(v_issue.violations), v_issue.profile;
    end if;
  end if;

  perform pg_advisory_xact_lock(hashtextextended('einvoicing:clearance:' || p_document_id::text, 0));

  select * into v_last from einvoicing.clearances c
   where c.document_id = p_document_id order by c.attempt desc limit 1;
  if found then
    if v_last.state = 'submitted' then
      raise exception 'clearance_pending: % was submitted on % (attempt %) and the authority has not answered; record its answer before submitting it again',
        v_what, v_last.submitted_at, v_last.attempt;
    elsif v_last.state = 'validated' or (v_last.state = 'rejected' and v_last.rejected_by = 'buyer') then
      raise exception 'clearance_already_validated: % was validated by the authority as % on %, and a validated invoice is not submitted again',
        v_what, v_last.identifier, v_last.validated_at;
    elsif v_last.state = 'cancelled' then
      raise exception 'clearance_cancelled: % was cancelled at the authority on %, and a cancelled invoice is not submitted again. It is undone in the books with cancel_document, and what was meant is a new invoice.',
        v_what, v_last.cancelled_at;
    end if;
  end if;

  insert into einvoicing.clearances
    (company_id, document_id, attempt, format, issue_id, reference, submitted_at, submitted_by)
  values
    (v_company, p_document_id, coalesce(v_last.attempt, 0) + 1, v_regime ->> 'format', p_issue_id,
     p_reference, coalesce(p_submitted_at, now()), public.acting_user())
  returning * into v_row;

  perform einvoicing.log_fiscal_event(v_company, v_row.format, 'clearance_submitted', jsonb_build_object(
    'document_id', p_document_id, 'clearance_id', v_row.id, 'attempt', v_row.attempt,
    'reference', p_reference, 'answer', coalesce(p_answer, '{}'::jsonb)));
  return v_row;
end;
$$;

comment on function einvoicing.record_clearance_submission(uuid, text, uuid, timestamptz, jsonb) is
  'Records that a posted sale was submitted to the authority under its company''s clearance regime: the next attempt of the document, the reference the authority gave on receipt where it gave one, the file submitted where this module kept it (an einvoice issue that breaks no rule), the moment, and the answer verbatim in fiscal_events. Calls nobody. Refuses a submission while one waits for its answer (clearance_pending), after a validation (clearance_already_validated) or a cancellation (clearance_cancelled), and everything clearance_document() refuses. Needs einvoicing.send and documents.read.';

-- ---------------------------------------------------------------------------
-- record_clearance_answer: what the authority said
-- ---------------------------------------------------------------------------

create or replace function einvoicing.record_clearance_answer(
  p_document_id      uuid,
  p_state            einvoicing.clearance_state,
  p_identifier       text default null,
  p_validated_at     timestamptz default null,
  p_verification_url text default null,
  p_reason           text default null,
  p_by               text default null,
  p_at               timestamptz default null,
  p_answer           jsonb default null
)
returns einvoicing.clearances
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_doc       public.documents%rowtype;
  v_clearance jsonb;
  v_company   uuid;
  v_what      text;
  v_last      einvoicing.clearances%rowtype;
  v_row       einvoicing.clearances%rowtype;
  v_at        timestamptz := coalesce(p_at, now());
  v_by        text;
  v_window    interval;
  v_reason    text := nullif(btrim(p_reason), '');
begin
  v_doc := einvoicing.clearance_document(p_document_id, 'recording what the authority answered');
  v_company := v_doc.company_id;
  v_what := v_doc.doc_type || ' ' || coalesce(v_doc.number, v_doc.id::text);
  v_clearance := coalesce(einvoicing.fiscal_regime(v_company) -> 'clearance', '{}'::jsonb);

  if p_state is null or p_state = 'submitted' then
    raise exception 'not_an_answer: submitted is where a clearance starts, recorded by record_clearance_submission(), not something the authority answers';
  end if;
  if p_answer is not null and jsonb_typeof(p_answer) <> 'object' then
    raise exception 'bad_clearance_answer: what the authority answered is kept as an object, as it said it';
  end if;
  v_by := case when p_state = 'rejected' then coalesce(p_by, 'authority') else p_by end;
  if v_by is not null and (p_state <> 'rejected' or v_by not in ('authority', 'buyer')) then
    raise exception 'bad_clearance_answer: by names who rejected an invoice, the authority or the buyer, and only a rejection; got % for %', v_by, p_state;
  end if;

  perform pg_advisory_xact_lock(hashtextextended('einvoicing:clearance:' || p_document_id::text, 0));
  select * into v_last from einvoicing.clearances c
   where c.document_id = p_document_id order by c.attempt desc limit 1;
  if not found then
    raise exception 'clearance_not_submitted: % was never submitted to the authority, so it has no answer to record', v_what;
  end if;

  -- The same answer twice records nothing.
  if v_last.state = p_state
     and (p_state <> 'rejected' or v_last.rejected_by = v_by)
     and (p_identifier is null or p_identifier = v_last.identifier) then
    return v_last;
  end if;

  if p_state = 'validated' then
    if v_last.state = 'validated' then
      raise exception 'clearance_identifier_differs: % was validated by the authority as %, and an identifier once given does not change (got %)',
        v_what, v_last.identifier, p_identifier;
    end if;
    if v_last.state <> 'submitted' then
      raise exception 'clearance_state_backwards: attempt % of % is %, and only a submission waiting for its answer is validated',
        v_last.attempt, v_what, v_last.state;
    end if;
    if nullif(btrim(p_identifier), '') is null or p_validated_at is null then
      raise exception 'bad_clearance_answer: a validation names the identifier the authority gave % and the moment it validated it', v_what;
    end if;
    if coalesce(v_clearance ->> 'verification', 'none') <> 'none' and nullif(btrim(p_verification_url), '') is null then
      raise exception 'clearance_verification_missing: under this company''s regime an invoice carries the link to its verification at the authority (%), and a validation of % is recorded with it',
        v_clearance ->> 'verification', v_what;
    end if;
    if p_verification_url is not null and p_verification_url !~ '^https://' then
      raise exception 'bad_clearance_answer: the verification link is an https:// address; got %', p_verification_url;
    end if;
    if exists (select 1 from einvoicing.clearances c
                where c.company_id = v_company and c.format = v_last.format and c.identifier = p_identifier) then
      raise exception 'clearance_identifier_taken: the authority''s identifier % is another invoice''s of this company already; one identifier is one invoice', p_identifier;
    end if;
    update einvoicing.clearances c
       set state = 'validated', identifier = p_identifier, validated_at = p_validated_at,
           verification_url = nullif(btrim(p_verification_url), '')
     where c.id = v_last.id
    returning * into v_row;

  elsif p_state = 'rejected' then
    if v_reason is null then
      raise exception 'bad_clearance_answer: a rejection says why, as whoever rejected % said it', v_what;
    end if;
    if v_by = 'authority' then
      if v_last.state <> 'submitted' then
        raise exception 'clearance_state_backwards: attempt % of % is %, and the authority rejects only a submission waiting for its answer',
          v_last.attempt, v_what, v_last.state;
      end if;
    else
      if v_last.state <> 'validated' then
        raise exception 'clearance_state_backwards: attempt % of % is %, and the buyer rejects only a validated invoice',
          v_last.attempt, v_what, v_last.state;
      end if;
      if v_clearance ->> 'rejection_window' is null then
        raise exception 'clearance_buyer_cannot_reject: under this company''s regime the buyer rejects no invoice at the authority; % is answered with a credit note, or settled with the buyer', v_what;
      end if;
      v_window := (v_clearance ->> 'rejection_window')::interval;
      if v_at > v_last.validated_at + v_window then
        raise exception 'clearance_window_closed: the buyer may reject an invoice within % of its validation, and % was validated on %; on % that window had closed',
          v_clearance ->> 'rejection_window', v_what, v_last.validated_at, v_at;
      end if;
    end if;
    update einvoicing.clearances c
       set state = 'rejected', rejected_by = v_by, rejected_at = v_at, rejection_reason = v_reason
     where c.id = v_last.id
    returning * into v_row;

  else -- cancelled
    if not (v_last.state = 'validated' or (v_last.state = 'rejected' and v_last.rejected_by = 'buyer')) then
      raise exception 'clearance_state_backwards: attempt % of % is %, and only a validated invoice is cancelled at the authority',
        v_last.attempt, v_what, v_last.state || case when v_last.state = 'rejected' then ' by the ' || v_last.rejected_by else '' end;
    end if;
    if v_reason is null then
      raise exception 'bad_clearance_answer: a cancellation says why, as the issuer told the authority';
    end if;
    if v_clearance ->> 'cancellation_window' is null then
      raise exception 'clearance_not_cancellable: under this company''s regime a validated invoice is never cancelled at the authority; % is corrected by a credit note', v_what;
    end if;
    v_window := (v_clearance ->> 'cancellation_window')::interval;
    if v_at > v_last.validated_at + v_window then
      raise exception 'clearance_window_closed: the issuer may cancel an invoice within % of its validation, and % was validated on %; on % that window had closed, and it is corrected by a credit note',
        v_clearance ->> 'cancellation_window', v_what, v_last.validated_at, v_at;
    end if;
    update einvoicing.clearances c
       set state = 'cancelled', cancelled_at = v_at, cancellation_reason = v_reason
     where c.id = v_last.id
    returning * into v_row;
  end if;

  perform einvoicing.log_fiscal_event(v_company, v_row.format, 'clearance_' || p_state::text, jsonb_build_object(
    'document_id', p_document_id, 'clearance_id', v_row.id, 'attempt', v_row.attempt,
    'identifier', p_identifier, 'validated_at', p_validated_at, 'verification_url', p_verification_url,
    'by', v_by, 'reason', v_reason, 'at', v_at, 'answer', coalesce(p_answer, '{}'::jsonb)));
  return v_row;
end;
$$;

comment on function einvoicing.record_clearance_answer(uuid, einvoicing.clearance_state, text, timestamptz, text, text, text, timestamptz, jsonb) is
  'Records what the authority answered about the latest submission of a document, and keeps the answer verbatim in fiscal_events: validated, with the identifier it gave, the moment it validated and the verification link where the regime has one (bad_clearance_answer, clearance_verification_missing, clearance_identifier_taken); rejected, with its reason, by the authority (from submitted) or by the buyer (from validated, within the pack''s rejection_window: clearance_buyer_cannot_reject, clearance_window_closed); cancelled by the issuer, with its reason, from validated or rejected by the buyer, within the pack''s cancellation_window (clearance_not_cancellable, clearance_window_closed). The same answer twice records nothing; any other move is clearance_state_backwards. Calls nobody. Needs einvoicing.send and documents.read.';

-- ---------------------------------------------------------------------------
-- The conventions the socle looks a module up by
-- ---------------------------------------------------------------------------

create or replace function einvoicing.can_disable(p_company_id uuid)
returns text
language sql
stable
as $$
  select case
           when exists (
                select 1 from einvoicing.transmissions t
                 where t.company_id = p_company_id
                   and t.state in ('prepared', 'submitted', 'accepted_by_access_point'))
             then 'an electronic invoice or a fiscal record is on its way, and what comes back would have nowhere to be recorded. Follow it to delivered or rejected first.'
           when exists (
                select 1 from einvoicing.fiscal_chain c
                 where c.company_id = p_company_id
                   and c.mode <> 'none'
                   and not exists (
                         select 1 from einvoicing.transmissions t
                          where t.issue_id = c.issue_id
                            and t.state in ('accepted_by_access_point', 'delivered')))
             then 'a fiscal record of this company has not reached the tax authority, and the law asks for it to be sent. Send it first; turning the module off would leave it behind.'
           when exists (
                select 1 from einvoicing.clearances c
                 where c.company_id = p_company_id
                   and c.state = 'submitted')
             then 'an invoice of this company is waiting for the authority''s validation, and its answer would have nowhere to be recorded. Record the answer first.'
         end;
$$;

comment on function einvoicing.can_disable(uuid) is
  'Null when the module may be turned off for a company; a sentence while a sending is still on its way, while a fiscal record that is to be sent has not reached the authority, or while an invoice waits for the authority''s validation. Turning it off deletes nothing: the files, the chain, the clearances and the history come back with it.';

create or replace function einvoicing.archive_tables()
returns table (
  table_name  text,
  disposition text,
  reason      text,
  via_column  text,
  via_table   text,
  load_order  integer
)
language sql
immutable
as $$
  values
    ('issues'::text,             'exported'::text, null::text, null::text, null::text, 1),
    ('transmissions',            'exported',       null,       null,       null,       2),
    ('transmission_events',      'exported',       null,       null,       null,       3),
    ('fiscal_chain',             'exported',       null,       null,       null,       4),
    ('fiscal_events',            'exported',       null,       null,       null,       5),
    ('clearances',               'exported',       null,       null,       null,       6);
$$;

comment on function einvoicing.archive_tables() is
  'What an archive of one company does with each table of this module: all six travel — the files as they were issued, the sendings and what came back, the chain of fiscal records and its events, and the submissions to the authority under a clearance regime. Read by `public.company_archive_tables()`.';

-- ---------------------------------------------------------------------------
-- Row level security
-- ---------------------------------------------------------------------------

alter table einvoicing.clearances enable row level security;

create policy einvoicing_clearances_select on einvoicing.clearances
  for select using (
    public.module_enabled(company_id, 'einvoicing')
    and public.has_capability(company_id, 'einvoicing.read')
  );

-- ---------------------------------------------------------------------------
-- Privileges, by name
-- ---------------------------------------------------------------------------

grant select on table einvoicing.clearances to authenticated, service_role;

revoke execute on function einvoicing.clearance_document(uuid, text) from public, anon;
revoke execute on function einvoicing.record_clearance_submission(uuid, text, uuid, timestamptz, jsonb) from public, anon;
revoke execute on function einvoicing.record_clearance_answer(uuid, einvoicing.clearance_state, text, timestamptz, text, text, text, timestamptz, jsonb) from public, anon;

grant execute on function einvoicing.clearance_document(uuid, text) to authenticated, service_role;
grant execute on function einvoicing.record_clearance_submission(uuid, text, uuid, timestamptz, jsonb) to authenticated, service_role;
grant execute on function einvoicing.record_clearance_answer(uuid, einvoicing.clearance_state, text, timestamptz, text, text, text, timestamptz, jsonb) to authenticated, service_role;

revoke execute on function einvoicing.guard_clearance() from public, anon, authenticated, service_role;

-- ---------------------------------------------------------------------------
-- The registry row
-- ---------------------------------------------------------------------------

update public.modules
   set version            = '1.2.0',
       description        = 'The electronic invoice of a posted sale in the profile its country pack declares, and the fiscal record or the clearance by the authority its pack''s fiscalisation regime requires: the exact files with the rules they break, the chain, the validations, and every sending with what came back, word for word. Knows no country, names no provider, and writes nothing to the ledger.'
 where code = 'einvoicing';
