# The command line answers one document and an exit code

> Status: accepted

## Context

A caller with a shell and nothing else — a script, an agent — must be able to
tell success, a finding, a wrong call and a refusal of the books apart without
knowing which command it ran.

## Decision

**One document, one shape, whatever happened.** Under `--json` standard
output is a single JSON document — `ok`, `command`, `exitCode`, `data`,
`warnings`, `error`, and `context` (profile, instance, company or null) — on
success, finding and refusal alike; prose goes to standard error. The shape is
published as `output.1.json`.

**`--json` is accepted by the parser**, not listed per command; a test reads
the list of commands and fails on one without a case.

**Exit codes:**

- `0` — success;
- `1` — a failure (with `error`), or a finding of `doctor`, `status`,
  `pack check`, `pack status`, `pack upgrade` (with `data` and no `error`);
- `2` — a wrong call: bad arguments, nobody to act as, a `service_role` key,
  a refusal of the shared layer decided before the database was asked;
- `3` — the books declined, decided by SQLSTATE and never by wording: `P0001`,
  `P0002`, `42501`, `55006` and class `23`. A `PGRST…` code stays 1.

**What a refusal is called is read in one place**, `@ekwo-ai/core`
(`socleCode()`, `isRefusalState()`), shared by the CLI and the MCP server.

**A prompt cannot block.** `--json` counts as "nobody to ask", and prompt
functions exit 2 when reached without a terminal.

**Reports under `data` keep the spelling the database gave**; re-spelling a
function's answer is how two spellings become three.

## Consequences

- Scripts that parsed the bare reports of the first commands had to read
  `data` instead.
- A transport that loses the SQLSTATE must bring its own mapping to the same
  three kinds.

## See also

- `tests/cli/`
- [0055 The command line acts as a signed-in person](0055-the-command-line-acts-as-a-signed-in-person.md)
