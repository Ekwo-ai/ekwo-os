-- Ekwo OS — a deadline that depends on the taxpayer, said rather than left out.
--
-- `20260917170000` gave `filing_deadline_rule` two shapes and wrote down what
-- it could not say: a schedule that depends on *who* files rather than on
-- *what period*. A pack in that situation declared no deadline at all, and a
-- null that means "the law gives no single date" read exactly like a null that
-- means "nobody has read the law yet". The public page of every country prints
-- both the same way.
--
-- This is the third value, and it carries no date: the pack states that the
-- day is assigned per taxpayer and cites the text that assigns it.
-- `filing_deadline()` still answers null for it — the core does not know which
-- slice of the schedule a company falls in — but the silence is now an answer
-- the pack gave.
--
-- Its own file: a new enum value cannot be used in the transaction that added
-- it, and the next migration rewrites the constraint that reads it. The comment
-- on the type travels with the value, which it describes and does not use.

alter type filing_deadline_rule add value if not exists 'depends_on_taxpayer' after 'last_day_of_month_after_period';

comment on type filing_deadline_rule is
  'How a filing date is worked out from the end of a period. Three values, closed: a fixed day of the month that follows, the last day of it, or a day the administration assigns per taxpayer — which carries no date, only the text that assigns it. A fourth needs a migration.';
