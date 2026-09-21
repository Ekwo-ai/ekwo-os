/**
 * The command line itself: parse and dispatch. What a command answers and
 * which exit code it ends on is `output.ts`, for every command at once.
 */

import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { UsageError, boolFlag, parseArgs, type ParsedArgs } from './args.js';
import { companyCommand } from './commands/company.js';
import { contactCommand } from './commands/contact.js';
import { demoCommand } from './commands/demo.js';
import { cancelCommand, docCommand, postCommand } from './commands/document.js';
import { reverseCommand } from './commands/entry.js';
import { doctorCommand } from './commands/doctor.js';
import { initCommand, type InitDeps } from './commands/init.js';
import { loginCommand, logoutCommand, type LoginDeps } from './commands/login.js';
import { migrateCommand } from './commands/migrate.js';
import { moduleCommand } from './commands/module.js';
import { packCommand } from './commands/pack.js';
import { matchCommand, paymentCommand } from './commands/payment.js';
import { registerCommand, unregisterCommand } from './commands/register.js';
import { statusCommand } from './commands/status.js';
import { useCommand, whoamiCommand } from './commands/whoami.js';
import type { BooksDeps } from './books.js';
import { askedForJson, commandLabel, execute, reportFailure, setResult } from './output.js';
import { bold, cyan, dim, line } from './ui.js';

export function version(): string {
  try {
    const path = fileURLToPath(new URL('../package.json', import.meta.url));
    const parsed = JSON.parse(readFileSync(path, 'utf8')) as { version?: string };
    return parsed.version ?? '0.0.0';
  } catch {
    return '0.0.0';
  }
}

export const COMMANDS = [
  'init',
  'migrate',
  'status',
  'doctor',
  'module',
  'pack',
  'company',
  'register',
  'unregister',
  'demo',
  'login',
  'logout',
  'use',
  'whoami',
  'contact',
  'doc',
  'post',
  'cancel',
  'reverse',
  'payment',
  'match',
  // An alias, last: `invoice` is what `doc` used to be called.
  'invoice',
] as const;

/** What a test may hand a command instead of the network, the disk and the environment. */
export type RunDeps = InitDeps & LoginDeps & BooksDeps;

export function help(): string {
  return `${bold('ekwo')} — install and operate Ekwo OS on a Supabase project you own.

${bold('Usage')}
  npx ekwo-os <command> [options]

${bold('Commands')}
  ${cyan('init')}        Apply the schema, seed the reference data, create the first
              administrator and the first company, on a project you already have.
  ${cyan('migrate')}     Apply the migrations this release adds, and show the gap first.
  ${cyan('status')}      Schema version installed against available, the instance,
              its administrators and its companies.
  ${cyan('doctor')}      Check what the schema cannot enforce on its own: row level
              security everywhere, no pending migration, no membership pointing
              at a deleted user, statements that tie to their lines.
  ${cyan('module')}      The modules beside the socle: what is installed, apply their
              migrations, and turn one on or off for a company.
  ${cyan('pack')}        Compile a country pack into its seed, check that the committed
              seed is still the exact output of the pack, and move a company
              onto the version an installation holds.
  ${cyan('company')}     One company leaves an installation with its books, as an archive
              anybody can read, and arrives in another one alive.
  ${cyan('register')}    Opt in to security advisories and release notes. Never required.
  ${cyan('unregister')}  Opt back out. Clears the address and the date.
  ${cyan('demo')}        Load the sample company. Fictional data; ask for it explicitly.

  ${cyan('login')}       Sign in to an instance as yourself and keep the session, in your
              own configuration directory and never in a repository.
  ${cyan('logout')}      End that session, here and on the instance.
  ${cyan('use')}         Pick the company the next commands run on.
  ${cyan('whoami')}      Who you are on which instance, the companies you can see, and
              what you may do on the one in use.

${bold('Connecting')} ${dim('(every command)')}
  --db-url <url>            Postgres connection string. Supabase dashboard →
                            Project Settings → Database. The reliable way.
  --project-ref <ref>       With --db-password, the host is guessed from the ref.
  --db-password <password>  Database password. Prompted, masked, if omitted.
  --db-region <region>      Use the pooler in this region, e.g. eu-central-1.
  --supabase-url <url>      https://<ref>.supabase.co — needed to create a user.
  --service-role-key <key>  Project Settings → API. Needed to create a user.

  ${cyan('contact')}     add <name> | list — the people and companies the books name.
  ${cyan('doc')}         new | line add <document> — a draft and its lines; list | show
              <document> — what exists, and what is still owed. One object: a
              sale invoice, a bill, a quote or a credit note, with --type. A
              draft books nothing. ${dim('ekwo invoice is the old name of doc, kept.')}
  ${cyan('post')}        <document> — book it, through post_document(). --dry-run shows
              the entry the database would write, and writes nothing.
  ${cyan('cancel')}      <document> — undo a posted invoice, and say how: back to draft
              where its country allows it and nothing has left, the credit
              note that names it otherwise. --credit asks for the note.
  ${cyan('reverse')}     <entry> — undo a posted entry, through reverse_entry(): its
              mirror, posted and matched against it. Its id or its number.
  ${cyan('payment')}     record — money in or out, booked and matched.
  ${cyan('match')}       <bank transaction> <document> — a statement line pays a document.

${bold('Acting as a person')} ${dim('(login … whoami, and every verb that keeps books — never a service_role key)')}
  --profile <name>          Which profile: a demo instance, production, one client
                            of a firm. Defaults to the one last signed in to.
  --company <name|id>       The company for this one command, over the one in use.
  --supabase-url <url>      ${dim('login')}  https://<ref>.supabase.co. Read from ekwo.json
                            when the working directory has one.
  --anon-key <key>          ${dim('login')}  The publishable key. Project Settings → API.
  --email <address>         ${dim('login')}  Who signs in.
  --password <password>     ${dim('login')}  Prompted, masked, if omitted. Sent to the
                            instance once and never written to disk.

${bold('Keeping books')} ${dim('(each verb is one function the MCP server calls too; no rule lives here)')}
  --ref <reference>         On what creates — contact add, doc new, payment
                            record. Your own reference: the same one a second
                            time returns what the first created, and creates
                            nothing. Pass it whenever a call might be repeated.
  --stdin                   Read one JSON document on the standard input, with
                            the fields of the MCP tool of the same meaning.
                            The form that is authoritative; flags beside it win.
  --line "k=v,k=v"          doc new, repeatable. Keys: name, price, qty,
                            account, tax, product, unit, discount, description.
                            Codes, never rates; a comma in a value is \\,.
  --dry-run                 post. Ask the database what it would write.
  --date <YYYY-MM-DD>       cancel, reverse. The day the undoing is booked on,
                            which asks cancel for a credit note. Left out: the
                            day of what is undone, while its period is open —
                            refused by name otherwise.
  --credit                  cancel. A credit note, even where the document
                            could go back to draft.
  <document>                Its id, its number, or the --ref it was created under.
  Amounts are decimal strings, in and out: 1500.00. Nothing is computed here.

${bold('Output')} ${dim('(every command)')}
  --json                    One JSON document on the standard output, and the
                            prose on the standard error. Never asks a question.
                            The shape is packages/cli/schema/output.1.json.
  --yes, -y                 Never ask a question, in either form.

  Exit codes: 0 done · 1 it failed, or a check found something · 2 the command
  was called wrong · 3 the database refused — a locked period, a capability
  you do not hold. The refusal is printed as the database wrote it.

${bold('ekwo init')}
  --country <cc>            Which pack: its chart of accounts and its VAT rules.
                            Required unless the terminal can ask, which lists
                            the packs this installation holds, by name.
  --org <name>              Your organisation. Written on the instance row.
  --company <name>          The first company. Defaults to --org.
  --admin-email <address>   The first administrator, created in your Supabase Auth.
  --admin-password <pw>     Their password. Omitted: an invite link is generated.
  --admin-user-id <uuid>    Use an account that already exists instead.
  --fiscal-year <year>      Calendar year the first financial year opens in.
                            Defaults to this year.
  --fiscal-year-start <d>   First day of it, as YYYY-MM-DD. Defaults to the
                            month the country pack opens a year on; required
                            when the pack names none.
  --language <xx>           Language of the books. Defaults to the country pack's.
  --vat-period <cadence>    How often the company files its VAT return: month,
                            bimonth, quarter, four_month, half_year or year.
                            Asked when the country's form offers several and
                            the law proposes none.
  --filing-period <c>=<p>   The same, for any declaration the country files, by
                            the code of its form. Repeatable, one per
                            declaration: a company files its return and its
                            recapitulative statement on cadences of their own.
  --demo                    Also load the sample company.
  --register                Register without being asked. --register-email sets
                            the address; otherwise --admin-email is used.
  --yes, -y                 Never ask a question. Everything must come from
                            flags or the environment.

${bold('ekwo module')}
  list                      What this release carries, and what the database holds.
  migrate [<cc>]            Apply the module migrations and their country seeds.
  enable <code> --company   Turn a module on for a company. Prints the schema to
                            add to the project's exposed schemas, which no
                            migration can do.
  disable <code> --company  Turn it off. Nothing the module wrote is deleted.

${bold('ekwo pack')} ${dim('(build, check and list need a checkout of the repository)')}
  build <cc> | --all        Compile packs/<cc> into supabase/seed/.
  check <cc> | --all        Refuse a seed that is not the output of its pack.
  list                      The packs this checkout carries.
  status                    What each company copied, against what is loaded on
                            the installation this connects to. Read-only.
  upgrade <company>         Move it to the version loaded there. An addition and
                            a closed validity are applied; everything else is
                            listed and left alone until --apply.

${bold('ekwo company')}
  export <company> --out <dir>
                            Write the archive of one company: manifest.json and
                            one data/<table>.jsonl per table. Read as a member
                            who holds company.export (--as-user, an owner by
                            default), under row level security.
  import <dir>              Take an archive in, whole or not at all. The
                            installer or an administrator of the installation
                            (--as-user); --owner names the first owner. A
                            company already here is refused.

${bold('Environment')}
  EKWO_DB_URL               Same as --db-url. SUPABASE_DB_URL also works.
  EKWO_DB_PASSWORD          Same as --db-password.
  SUPABASE_URL              Same as --supabase-url.
  SUPABASE_SERVICE_ROLE_KEY Same as --service-role-key.
  SUPABASE_ANON_KEY         Same as --anon-key.
  EKWO_EMAIL, EKWO_PASSWORD Sign in for this one command. With SUPABASE_URL and
                            SUPABASE_ANON_KEY they come before any profile, and
                            nothing is read from or written to the disk: a CI job.
  EKWO_ACCESS_TOKEN         The same, with a session token already in hand.
  EKWO_PROFILE              Same as --profile.
  EKWO_CONFIG_DIR           Where profiles and sessions are kept. Defaults to
                            $XDG_CONFIG_HOME/ekwo, else ~/.config/ekwo.
  EKWO_REGISTRY_URL         Where registrations are announced.
  NO_COLOR                  Plain output.

${bold('What this CLI does not do')}
  It does not create or pay for a Supabase project. You create one — the free
  plan is enough — and the CLI connects to it. Your data is on your account
  from the first row, and there is nothing for us to hold back.

  It never writes a password or a key to disk. The database password and the
  service_role key are read from a flag, the environment or a masked prompt,
  used, and forgotten. ${cyan('ekwo.json')} holds the project URL, the country and the
  schema version, and nothing else. The one thing kept is the session
  ${cyan('ekwo login')} obtains, in your own configuration directory, readable by you
  alone, and refused anywhere inside a repository.

  It never keeps books with a service_role key. ${cyan('init')} and ${cyan('migrate')} install,
  as the owner of the database, and say so; everything else that touches a
  ledger acts as the person signed in, under row level security.

  There is no ${cyan('eject')} command, because there is nothing to eject from. The
  schema is in your database, the migrations are in this repository under
  AGPL-3.0, and ${cyan('supabase db push')} applies them without this CLI ever running
  again — the migration history is the one the Supabase CLI writes.

${bold('Docs')}  https://github.com/Ekwo-ai/ekwo-os
`;
}

export async function run(argv: string[], deps: RunDeps = {}): Promise<number> {
  let args: ParsedArgs;
  try {
    args = parseArgs(argv);
  } catch (error) {
    return reportFailure('ekwo', askedForJson(argv), error);
  }

  let json: boolean;
  try {
    json = boolFlag(args, 'json');
  } catch (error) {
    return reportFailure(commandLabel(args), false, error);
  }

  return execute(args, json, async () => {
    if (args.flags.get('version') === true && args.command === undefined) {
      setResult({ version: version() });
      line(version());
      return 0;
    }

    if (args.command === undefined || args.command === 'help' || args.flags.get('help') === true) {
      if (args.command !== undefined && args.command !== 'help' && !isKnown(args.command)) {
        throw new UsageError(`unknown command: ${args.command}`);
      }
      setResult({ version: version(), commands: [...COMMANDS] });
      line(help().trimEnd());
      return 0;
    }

    switch (args.command) {
      case 'init':
        return await initCommand(args, deps);
      case 'migrate':
        return await migrateCommand(args, deps);
      case 'status':
        return await statusCommand(args, deps);
      case 'doctor':
        return await doctorCommand(args, deps);
      case 'module':
        return await moduleCommand(args, deps);
      case 'pack':
        return await packCommand(args, deps);
      case 'company':
        return await companyCommand(args, deps);
      case 'register':
        return await registerCommand(args, deps);
      case 'unregister':
        return await unregisterCommand(args, deps);
      case 'demo':
        return await demoCommand(args, deps);
      case 'login':
        return await loginCommand(args, deps);
      case 'logout':
        return await logoutCommand(args, deps);
      case 'use':
        return await useCommand(args, deps);
      case 'whoami':
        return await whoamiCommand(args, deps);
      case 'contact':
        return await contactCommand(args, deps);
      case 'invoice':
      case 'doc':
        return await docCommand(args, deps);
      case 'post':
        return await postCommand(args, deps);
      case 'cancel':
        return await cancelCommand(args, deps);
      case 'reverse':
        return await reverseCommand(args, deps);
      case 'payment':
        return await paymentCommand(args, deps);
      case 'match':
        return await matchCommand(args, deps);
      default:
        throw new UsageError(`unknown command: ${args.command}\nRun \`ekwo --help\` for the list.`);
    }
  });
}

function isKnown(command: string): boolean {
  return (COMMANDS as readonly string[]).includes(command);
}
