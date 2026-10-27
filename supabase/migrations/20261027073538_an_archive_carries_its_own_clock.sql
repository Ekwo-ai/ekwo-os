-- ---------------------------------------------------------------------------
-- An archive carries its own clock
-- ---------------------------------------------------------------------------
-- `20261015042916` gave the calls that carry a whole company a clock of their
-- own, raised by the pre-request hook from the path PostgREST names
-- (`is_archive_request()`, `archive_statement_timeout()`). On a hosted
-- project that raise does not always reach the work: the nightly copy of a
-- company of about 20 MB, taken with a key, still stops one night in two with
-- `canceling statement due to statement timeout`.
--
-- So each of those functions now says its clock itself, as a setting of the
-- function. PostgREST reads a function's `statement_timeout` and applies it to
-- the request that calls it, before the call; a request that reaches the
-- function another way (the command line, `psql`) is unchanged, since the
-- clock of a statement already running is not moved by a function it calls.
-- The value is `archive_statement_timeout()`'s, five minutes; a test holds the
-- two equal. The pre-request raise stays: it covers a PostgREST that does not
-- read function settings.
--
-- `alter function … set` keeps every body, signature and grant as it is.
-- ---------------------------------------------------------------------------

alter function export_company(uuid) set statement_timeout = '5min';
alter function export_company_manifest(uuid) set statement_timeout = '5min';
alter function export_company_tables(uuid) set statement_timeout = '5min';
alter function export_company_table(uuid, text) set statement_timeout = '5min';
alter function import_company(jsonb, uuid) set statement_timeout = '5min';
