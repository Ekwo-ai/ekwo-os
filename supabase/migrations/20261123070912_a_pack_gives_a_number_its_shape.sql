-- Ekwo OS — a pack gives a document number the shape its law prescribes.
--
-- Since `20261020160000` a company numbers its documents its own way: its
-- pattern in `companies.number_format`, a prefix per journal in
-- `journals.number_prefix`. Most laws leave the shape of the number to the
-- seller, and decision 0082 left a promise for the others: where a country
-- prescribes a shape — a maximum length, the characters a number is written
-- with, a series that never restarts — the pack declares it and the company's
-- pattern is checked against it. This file is the pack's say and the reading
-- of it; the next one, the check.
--
-- **The pack's answer.** `country_defaults.number_shape`, from
-- `documents.number_shape` of the pack: `max_length`, `characters` (`letters`,
-- `digits`, or one other character allowed, named alone) and
-- `never_restarts`, each absent where the law says nothing of it. Null, the
-- column's default, is a country that leaves the shape to the seller: no
-- company there sees any change.
--
-- **One reading of it.** `number_shape_of()` is the only reader of the
-- column, beside `numbering_rules()` for the pattern. `number_shape_refusal()`
-- prints the pattern with a journal's prefix, the counter at the width of its
-- padding, and says why the number does not fit, or nothing. `ekwo pack
-- check` reads a shape the same way, so a pack's own pattern, printed with its
-- own journals, fits it before any company numbers with it.
--
-- **The moments it is asked at** are in the file that follows,
-- `20261123070913`: when a company changes its pattern, and when a journal
-- changes its prefix. They are apart from this one so that the pack seeds,
-- which write the column, also run on a schema that predates the numbering of
-- a company.

-- ---------------------------------------------------------------------------
-- 1. The pack's answer
-- ---------------------------------------------------------------------------

alter table ekwo.country_defaults
  add column if not exists number_shape jsonb;

alter table ekwo.country_defaults
  drop constraint if exists country_defaults_number_shape_is_an_object;
alter table ekwo.country_defaults
  add constraint country_defaults_number_shape_is_an_object
  check (number_shape is null or jsonb_typeof(number_shape) = 'object');

comment on column ekwo.country_defaults.number_shape is
  'What the law of this country prescribes about the shape of a document number: max_length, characters (letters, digits, or one other character allowed) and never_restarts, each absent where the law says nothing of it. From documents.number_shape of the pack, cited by numbering_legal_reference; null where the law leaves the shape to the seller.';

-- The one reader of the column, as `numbering_rules()` is of the rest of the
-- numbering: the two triggers below ask these two functions, and nothing
-- else goes near `country_defaults` for a document rule.
create or replace function ekwo.number_shape_of(p_company_id uuid)
returns jsonb
language sql
stable
set search_path = ekwo, pg_temp
as $$
  select d.number_shape
    from companies c
    join country_defaults d on d.country = coalesce(c.fiscal_country, c.country)
   where c.id = p_company_id;
$$;

comment on function ekwo.number_shape_of(uuid) is
  'The shape the country pack of a company gives a document number (country_defaults.number_shape), or null where its law leaves the shape to the seller. The only function that reads the column.';

revoke execute on function ekwo.number_shape_of(uuid) from public, anon;
grant execute on function ekwo.number_shape_of(uuid) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 2. The one reading of it
-- ---------------------------------------------------------------------------

create or replace function ekwo.number_shape_refusal(p_shape jsonb, p_format text, p_code text)
returns text
language plpgsql
immutable
set search_path = ekwo, pg_temp
as $$
declare
  v_printed    text;
  v_allowed    text[];
  v_character  text;
begin
  if p_shape is null or p_format is null then
    return null;
  end if;

  if coalesce((p_shape ->> 'never_restarts')::boolean, false)
     and p_format ~ '\{(YYYY|YY)\}' then
    return format('%s carries the year, and the series of a document number runs on from one year to the next',
                  p_format);
  end if;

  -- The counter at the width of its padding: a number that outgrows it is
  -- longer, and the shortest number the pattern prints is the one judged.
  v_printed := format_number(p_format, p_code, date '2000-01-01', 0);

  if p_shape ? 'max_length' and length(v_printed) > (p_shape ->> 'max_length')::integer then
    return format('%s is %s characters long, and a document number is at most %s',
                  v_printed, length(v_printed), p_shape ->> 'max_length');
  end if;

  if p_shape ? 'characters' then
    select array_agg(x) into v_allowed from jsonb_array_elements_text(p_shape -> 'characters') x;
    foreach v_character in array regexp_split_to_array(v_printed, '') loop
      if not ((v_character ~ '[[:alpha:]]' and 'letters' = any(v_allowed))
              or (v_character ~ '^[0-9]$' and 'digits' = any(v_allowed))
              or v_character = any(v_allowed)) then
        return format('%s is written with "%s", and a document number is written with %s only',
                      v_printed, v_character, array_to_string(v_allowed, ', '));
      end if;
    end loop;
  end if;

  return null;
end;
$$;

comment on function ekwo.number_shape_refusal(jsonb, text, text) is
  'Why the number this pattern prints for this journal prefix does not fit the shape a country gives a document number, or null when it fits or the country gives none. The counter is printed at the width of its padding. The one reading of country_defaults.number_shape; ekwo pack check reads a pack''s the same way.';

revoke execute on function ekwo.number_shape_refusal(jsonb, text, text) from public, anon;
grant execute on function ekwo.number_shape_refusal(jsonb, text, text) to authenticated, service_role;
