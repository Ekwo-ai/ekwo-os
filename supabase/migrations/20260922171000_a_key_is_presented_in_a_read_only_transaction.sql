-- Ekwo OS — presenting a key must not need a transaction that can write.
--
-- Found against a real project, which is the only place it could be found:
-- PostgREST runs a GET, and an RPC whose function is not volatile, inside a
-- **read-only transaction**. `use_api_key()` ends by stamping
-- `api_keys.last_used_at` through `touch_api_key()`, and an UPDATE there is
-- refused:
--
--     cannot execute UPDATE in a read-only transaction   (SQLSTATE 25006)
--
-- The refusal happens inside `ekwo_pre_request()`, so it fails the whole
-- request — with a 405 and a message about an UPDATE nobody asked for, on a
-- plain `GET /rest/v1/companies`. Every read a machine key makes is that
-- request, which is most of what a machine key is for: a backup, a report, a
-- dashboard. PGlite never said so, because a test opens the transaction it
-- wants and none of ours asked for a read-only one.
--
-- **The stamp is worth less than the request.** `last_used_at` answers "has
-- this key been used lately", which is what an operator withdraws keys on. It
-- is a convenience, and the work the key was presented for is not. So the use
-- is recorded when the transaction can record it, and skipped when it cannot,
-- rather than the other way round.
--
-- This is not an error being swallowed. Nothing is caught here and nothing
-- raises: the function asks whether the transaction it is in may write, and
-- the answer is a fact about the transaction, known before anything is
-- attempted. A key presented on a connection — the command line, the MCP
-- server, `ekwo` itself — opens a read-write transaction and is stamped
-- exactly as before. A key presented on a read request is not, and
-- `last_used_at` then means "last used in a way that could write it down",
-- which the column comment now says.
--
-- The alternative was an autonomous transaction, which in PostgreSQL means an
-- extension — dblink or pg_background — and this schema requires none and is
-- not going to start over a timestamp.

create or replace function use_api_key(p_secret text)
returns api_keys
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_row api_keys%rowtype;
begin
  select * into v_row
    from api_keys
   where key_hash = encode(sha256(convert_to(coalesce(p_secret, ''), 'UTF8')), 'hex');

  if v_row.id is null then
    raise exception 'unknown_api_key: that is not a key of this installation'
      using errcode = '42501';
  end if;
  if v_row.revoked_at is not null then
    raise exception 'api_key_revoked: that key was withdrawn on %', v_row.revoked_at
      using errcode = '42501';
  end if;
  if v_row.expires_at is not null and v_row.expires_at <= now() then
    raise exception 'api_key_expired: that key expired on %', v_row.expires_at
      using errcode = '42501';
  end if;

  -- Transaction-local: the key is presented for the work at hand and not for
  -- the life of a connection somebody else may inherit from a pool.
  perform set_config('ekwo.api_key', v_row.key_hash, true);

  -- Recorded where it can be. A read request runs in a read-only transaction
  -- and an UPDATE in one is refused, which would fail the request the key was
  -- presented for.
  if not current_setting('transaction_read_only')::boolean then
    perform touch_api_key(v_row.id);
  end if;

  return v_row;
end;
$$;

comment on function use_api_key(text) is
  'Presents a machine key for the current transaction: has_capability() answers for it until the transaction ends. Refuses a key that is unknown, withdrawn or expired. Records the use when the transaction may write — a read request runs in a read-only transaction, where the stamp is worth less than the request.';

comment on column api_keys.last_used_at is
  'When this key was last presented in a transaction that could write it down. A read over the API runs read-only and is not stamped, so this is a floor and never a ceiling: a key with an old date may still be in daily use for reading.';
