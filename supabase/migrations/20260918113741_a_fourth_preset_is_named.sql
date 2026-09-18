-- Ekwo OS — a fourth preset is named, and nothing else happens here.
--
-- `member_role` gains `client`: the person whose company this is, inside an
-- installation that belongs to whoever keeps their books. What the preset
-- holds is the next migration — a new enum value cannot be used in the
-- transaction that adds it, which is the reason `instance_admin` was added in
-- a file of its own on the first day, and the reason this one is.

alter type member_role add value if not exists 'client';
