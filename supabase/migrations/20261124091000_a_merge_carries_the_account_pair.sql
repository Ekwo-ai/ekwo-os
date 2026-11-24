-- Ekwo OS — a merge carries the account of a contact as a scheme and a value.
--
-- `20261123203500_an_account_is_a_scheme_and_a_value` gave a contact its
-- account and its bank as two pairs, `account_scheme` / `account_identifier`
-- and `bank_scheme` / `bank_identifier`, with `iban` and `bic` kept as their
-- mirror. `merge_contacts()` still asked the old columns alone: it looked at
-- `iban` to decide whether the kept contact had an account, and copied
-- `iban` and `bic` from the absorbed one. A contact paid from an ABA routing
-- number and an account, a BSB or an IFSC has no IBAN, so its account was
-- lost when it was absorbed by a contact that had none.
--
-- The rule is the one the function already had, read on the pair: the kept
-- contact keeps its account when it has one, in any scheme; when it has none,
-- it takes the absorbed contact's account and bank together — the one without
-- the other is somebody else's. Both pairs and both old columns are written in
-- one statement, as they stand on the absorbed contact, which the mirror holds
-- in step; `filled` names the pairs beside `iban` and `bic`.
--
-- Rewritten from the catalogue, the way `20261123203500` rewrote four
-- functions, so nothing else of the latest definition moves. Additive.

set search_path = ekwo, pg_temp;

do $$
declare
  v_oid oid := 'ekwo.merge_contacts(uuid, uuid)'::regprocedure;
  v_def text := pg_get_functiondef(v_oid);
  v_new text;
begin
  v_new := replace(v_def,
    $old$  if coalesce(btrim(v_new.iban), '') = '' and coalesce(btrim(v_absorb.iban), '') <> '' then
    v_new.iban := v_absorb.iban;
    v_new.bic  := v_absorb.bic;
    v_filled := v_filled || array['iban', 'bic'];
  end if;$old$,
    $new$  -- The account is the pair, in any scheme; iban is its mirror for an IBAN.
  if coalesce(btrim(coalesce(v_new.account_identifier, v_new.iban)), '') = ''
     and coalesce(btrim(coalesce(v_absorb.account_identifier, v_absorb.iban)), '') <> '' then
    v_new.account_scheme     := v_absorb.account_scheme;
    v_new.account_identifier := v_absorb.account_identifier;
    v_new.bank_scheme        := v_absorb.bank_scheme;
    v_new.bank_identifier    := v_absorb.bank_identifier;
    v_new.iban := v_absorb.iban;
    v_new.bic  := v_absorb.bic;
    v_filled := v_filled || array['account_scheme', 'account_identifier', 'bank_scheme', 'bank_identifier', 'iban', 'bic'];
  end if;$new$);
  v_new := replace(v_new,
    $old$         iban                  = v_new.iban,
         bic                   = v_new.bic,$old$,
    $new$         iban                  = v_new.iban,
         bic                   = v_new.bic,
         account_scheme        = v_new.account_scheme,
         account_identifier    = v_new.account_identifier,
         bank_scheme           = v_new.bank_scheme,
         bank_identifier       = v_new.bank_identifier,$new$);
  if position('v_new.account_identifier := v_absorb.account_identifier' in v_new) = 0
     or position('account_identifier    = v_new.account_identifier' in v_new) = 0 then
    raise exception 'a_merge_carries_the_account_pair: merge_contacts no longer copies the account it was written against.';
  end if;
  execute v_new;
end;
$$;
