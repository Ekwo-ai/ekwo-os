# The install demo

`install.gif` (in the root README) and `install.mp4` are one recording: an
empty Supabase project, `npx ekwo-os init`, `ekwo status`, a company, a sale
invoice posted, and the periodic return of that company prepared — for two
countries at once, the United Kingdom on the left and Estonia on the right.
Two countries because no country is the default one: the same commands, two
charts of accounts, two tax codes, two forms.

The GIF is the same recording at two and a half times the speed.

## What is on screen, and what is not

Everything typed is what ran, against the published `ekwo-os` and
`@ekwo-ai/mcp` 0.5.0 on npm. Three things are arranged off camera, in
`shell.sh`:

- the connection string, the keys and the administrator's password come from
  the environment and are never typed;
- every `npx` runs through `sed`, which replaces the project reference and
  the working directory before they reach the frame (`render.sh` fetches
  the release on npm once beforehand, so the two halves find it cached);
- the prompt is the name of the country and a `$`.

The companies, the customers and the address are invented. The projects the
published files were recorded on were throwaway ones, deleted afterwards.

## One thing the recording shows as it is

**The return is not an `ekwo` command.** The command line has no verb for it
yet. The return is `vat_return()`, a function of the schema, and
`vat-return.mjs` asks for it through the MCP server, as the signed-in person,
the way an assistant would. It prints what came back and computes nothing.

## Rendering it again

You need [vhs](https://github.com/charmbracelet/vhs), ffmpeg, Node 20 and two
**empty** Supabase projects nobody minds losing — each tape installs into its
own, creates an administrator and a company, and posts. Two projects, so the
halves are recorded at the same time and do the same work at the same moment.

Write one file per project:

```sh
# left.env — the same shape for right.env
export EKWO_DB_URL='postgresql://postgres.<ref>:<password>@aws-1-<region>.pooler.supabase.com:5432/postgres'
export SUPABASE_URL='https://<ref>.supabase.co'
export SUPABASE_ANON_KEY='<anon key>'
export SUPABASE_SERVICE_ROLE_KEY='<service_role key>'   # used once, by init
export EKWO_PASSWORD='<a password for the administrator the tape creates>'
```

```sh
docs/demo/render.sh left.env right.env
```

Keep both files out of the repository, and delete the projects afterwards.

## The walkthrough of Start with Claude

[`start-with-claude/`](start-with-claude/) is not a recording: it is
[`docs/start-with-claude.md`](../start-with-claude.md) run for real.
`walkthrough.mjs` installs into an empty project, starts the published MCP
server with the four variables the guide puts in Claude's configuration, and
calls the tools Claude calls for the guide's sentences — for an Estonian and a
British company, each taking over the invented trial balance beside it. It
prints one line per step and exits non-zero if one fails.

```sh
source left.env    # the variables above, with EKWO_EMAIL added
node docs/demo/start-with-claude/walkthrough.mjs
```

`--no-company` takes the guide's other road on a second empty project:
`ekwo init --no-company`, then `ekwo company new` for each company.

Delete the project afterwards.
