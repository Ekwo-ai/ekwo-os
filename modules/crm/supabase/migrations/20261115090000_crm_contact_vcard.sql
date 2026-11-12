-- Ekwo — the `crm` module: one contact as a vCard.
--
-- An address book takes a contact as a `.vcf` file. Each screen that offered
-- "add to my contacts" built that file itself, from what it had read; the
-- contact lives here, so the file is built here, once, and every screen, agent
-- or terminal asks for it.
--
-- `crm.contact_vcard()` gives the text of a vCard 3.0 (RFC 2426): the name,
-- the organisation, the job title of the card, the e-mail, the telephone, the
-- address, the profile URL of the card and the note — whatever of it the books
-- hold, and nothing else. It is `security invoker` like the rest of the
-- module: the policies of `public.contacts` and `crm.cards` decide what it
-- reads, and `crm.require()` answers by name first.
--
-- **One name, never split.** The books keep a contact's name as one text. Where
-- a given name ends and a family name begins is a custom of each language, so
-- the whole name goes into the family-name component of `N`, and into `FN`.
-- An address book shows it as written.
--
-- **An organisation is shown as one.** `ORG` carries its name and
-- `X-ABShowAs:COMPANY` asks the address books that know the extension to list
-- it under that name; `N` stays empty.
--
-- **A person takes their organisation's.** `ORG` is the organisation the person
-- belongs to (`parent_id`), and when the person has no address of their own,
-- the organisation's is theirs — the address they are reached at.
--
-- **The country is its code.** `contacts.country` is an ISO code, written as
-- such: a name of a country is a word of a language, which the module does not
-- choose.

-- ---------------------------------------------------------------------------
-- One value, escaped
-- ---------------------------------------------------------------------------

create or replace function crm.vcard_value(p_value text)
returns text
language sql
immutable
as $$
  -- RFC 2426 §4: a backslash, a comma and a semicolon are escaped, and a line
  -- break is written \n. Null is the empty value.
  select replace(replace(replace(replace(replace(coalesce(p_value, ''),
           '\', '\\'), ',', '\,'), ';', '\;'), E'\r\n', '\n'), E'\n', '\n');
$$;

comment on function crm.vcard_value(text) is
  'A value of a vCard 3.0 property, escaped as RFC 2426 asks: backslash, comma and semicolon behind a backslash, a line break as \n. Null gives the empty value.';

-- ---------------------------------------------------------------------------
-- One contact, as a vCard
-- ---------------------------------------------------------------------------

create or replace function crm.contact_vcard(p_company_id uuid, p_contact_id uuid)
returns text
language plpgsql
stable
as $$
declare
  v_contact public.contacts%rowtype;
  v_org     public.contacts%rowtype;
  v_card    crm.cards%rowtype;
  v_where   public.contacts%rowtype;
  v_lines   text[] := array['BEGIN:VCARD', 'VERSION:3.0'];
  v_street  text;
  v_out     text := '';
  v_line    text;
  v_part    text;
  v_char    text;
  v_room    integer;
begin
  perform crm.require(p_company_id, 'crm.read', 'reading a contact');
  select * into v_contact from public.contacts c where c.id = p_contact_id and c.company_id = p_company_id;
  if not found then
    raise exception 'crm_unknown_contact: contact % is not a contact of company %', p_contact_id, p_company_id;
  end if;
  if v_contact.parent_id is not null then
    select * into v_org from public.contacts o where o.id = v_contact.parent_id and o.company_id = p_company_id;
  end if;
  select * into v_card from crm.cards k where k.contact_id = p_contact_id and k.company_id = p_company_id;

  v_lines := v_lines || ('FN:' || crm.vcard_value(v_contact.name));
  if v_contact.is_company then
    v_lines := v_lines || 'N:;;;;'::text || ('ORG:' || crm.vcard_value(v_contact.name)) || 'X-ABShowAs:COMPANY'::text;
  else
    v_lines := v_lines || ('N:' || crm.vcard_value(v_contact.name) || ';;;;');
    if v_org.id is not null then
      v_lines := v_lines || ('ORG:' || crm.vcard_value(v_org.name));
    end if;
  end if;
  if nullif(btrim(v_card.job_title), '') is not null then
    v_lines := v_lines || ('TITLE:' || crm.vcard_value(v_card.job_title));
  end if;
  if nullif(btrim(v_contact.email), '') is not null then
    v_lines := v_lines || ('EMAIL;TYPE=INTERNET:' || crm.vcard_value(btrim(v_contact.email)));
  end if;
  if nullif(btrim(v_contact.phone), '') is not null then
    v_lines := v_lines || ('TEL:' || crm.vcard_value(btrim(v_contact.phone)));
  end if;

  -- The address: the contact's own, or, for a person who has none, their
  -- organisation's.
  v_where := v_contact;
  if not v_contact.is_company and v_org.id is not null
     and coalesce(v_contact.address_line1, v_contact.address_line2, v_contact.postal_code,
                  v_contact.city, v_contact.region, v_contact.country) is null then
    v_where := v_org;
  end if;
  if coalesce(v_where.address_line1, v_where.address_line2, v_where.postal_code,
              v_where.city, v_where.region, v_where.country) is not null then
    v_street := concat_ws(E'\n', nullif(btrim(v_where.address_line1), ''), nullif(btrim(v_where.address_line2), ''));
    -- ADR: post office box; extended address; street; locality; region; postal code; country.
    v_lines := v_lines || ('ADR;TYPE=WORK:;;' || crm.vcard_value(v_street)
                           || ';' || crm.vcard_value(v_where.city)
                           || ';' || crm.vcard_value(v_where.region)
                           || ';' || crm.vcard_value(v_where.postal_code)
                           || ';' || crm.vcard_value(v_where.country));
  end if;

  if nullif(btrim(v_card.linkedin_url), '') is not null then
    v_lines := v_lines || ('URL:' || crm.vcard_value(btrim(v_card.linkedin_url)));
  end if;
  if nullif(btrim(v_contact.notes), '') is not null then
    v_lines := v_lines || ('NOTE:' || crm.vcard_value(v_contact.notes));
  end if;
  v_lines := v_lines || ('UID:urn:uuid:' || v_contact.id::text) || 'END:VCARD'::text;

  -- Every line ends in CRLF, and one longer than 75 octets is folded: the rest
  -- goes on the next line behind a space (RFC 2425 §5.8.1), never inside a
  -- character.
  foreach v_line in array v_lines loop
    v_part := '';
    v_room := 75;
    foreach v_char in array regexp_split_to_array(v_line, '') loop
      if octet_length(v_part) + octet_length(v_char) > v_room then
        v_out := v_out || v_part || E'\r\n';
        v_part := ' ';
        v_room := 75;
      end if;
      v_part := v_part || v_char;
    end loop;
    v_out := v_out || v_part || E'\r\n';
  end loop;
  return v_out;
end;
$$;

comment on function crm.contact_vcard(uuid, uuid) is
  'One contact of a company as the text of a vCard 3.0 (RFC 2426), for an address book: FN and N carry the name as the books hold it, never split; an organisation has its name in ORG and X-ABShowAs:COMPANY; a person has the organisation they belong to in ORG, its address when they have none, and the job title of their card in TITLE; then EMAIL, TEL, ADR with the country as its ISO code, the card''s profile URL, the note, and UID urn:uuid:<contact id>. Lines end in CRLF and are folded past 75 octets. A contact of another company is refused, crm_unknown_contact. Needs crm.read.';

-- ---------------------------------------------------------------------------
-- Privileges, by name
-- ---------------------------------------------------------------------------

revoke execute on function crm.vcard_value(text) from public, anon;
revoke execute on function crm.contact_vcard(uuid, uuid) from public, anon;

grant execute on function crm.vcard_value(text) to authenticated, service_role;
grant execute on function crm.contact_vcard(uuid, uuid) to authenticated, service_role;
