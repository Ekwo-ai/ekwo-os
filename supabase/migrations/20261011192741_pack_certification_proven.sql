-- Ekwo OS — a pack can be proven on the real books of a company.
--
-- Between `maintained` and `reviewed` there was a step the scale could not
-- say. A pack can reproduce, to the unit they were filed in, the statements a
-- real company filed and the administration accepted, once that company's
-- books are imported. That is more than the maintainers testing that the pack
-- holds together, and it is less than a professional reading the pack against
-- the law: it proves the cases that one company uses, and no other regime of
-- the country. So the scale becomes:
--
--   community   contributed, not read by an accountant
--   maintained  maintained by Ekwo, not yet reviewed by an accountant
--   proven      maintained, and it reproduced a real company's accepted
--               filing; the manifest of the pack says, per scope, what was
--               reproduced and what was not tested
--   reviewed    read by a named professional, with `certified_by`,
--               `certified_at` and the sources they worked from
--
-- Nothing here moves a row: a pack becomes proven when its seed says so, and
-- a new enum value cannot be used in the transaction that adds it anyway.

alter type pack_certification add value if not exists 'proven' after 'maintained';

comment on type pack_certification is
  'How much a pack has been read: community (contributed, unread), maintained (by Ekwo, not yet reviewed), proven (maintained, and it reproduced the accepted filing of a real company whose books were imported; it proves the cases that company uses), reviewed (by a named professional). The value `ekwo` is deprecated and nothing writes it.';

comment on column country_packs.certification_status is
  'How much a pack has been read, printed by `ekwo init`: community (contributed, unread), maintained (by Ekwo, not yet reviewed), proven (it reproduced the accepted filing of a real company; the pack manifest carries the evidence), reviewed (by the professional named in certified_by).';
