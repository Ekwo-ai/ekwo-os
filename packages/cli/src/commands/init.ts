/**
 * `ekwo init` — a Supabase project you own, turned into a set of books.
 *
 * Six things happen, in this order:
 *
 *   1. the migrations are applied, and recorded the way `supabase db push`
 *      records them;
 *   2. the reference seeds are applied — currencies, the charts of accounts,
 *      the VAT codes;
 *   3. the first administrator is created in *your* Supabase Auth, because a
 *      superuser connection cannot be a signed-in user (see `../auth.ts`);
 *   4. the installation sequence runs: instance, administrator, company,
 *      ownership, country template, first financial year;
 *   5. `ekwo.json` is written, with nothing secret in it;
 *   6. registering with Ekwo is offered, and the default answer is no.
 *
 * Every step is safe to run twice. Running `ekwo init` again on a set-up
 * project reports what was already there and creates nothing a second time.
 */

import {
  boolFlag,
  numberFlag,
  rejectUnknownFlags,
  stringFlag,
  stringFlags,
  UsageError,
  type ParsedArgs,
} from '../args.js';
import { createAuthUser, type CreateAuthUser } from '../auth.js';
import { bootstrap, claimInstance, countryFilingForms, countryPack, installedPacks } from '../bootstrap.js';
import { printOperatorChecklist } from '../checklist.js';
import {
  chooseChart,
  chooseCountry,
  chooseCurrency,
  chooseFiscalYearStart,
  chooseLanguage,
  required,
} from '../company-choices.js';
import { describeCertification, needsWarning } from '../pack/certification.js';
import { DEMO_SEED, migrationsDir, seedDir } from '../bundle.js';
import { writeConfig } from '../config.js';
import { CONNECTION_FLAGS, openDatabase, type CommandDeps } from '../context.js';
import { setResult } from '../output.js';
import { listMigrations } from '../migrations.js';
import { applyMigrations } from '../migrations.js';
import { listModules } from '../module/read.js';
import { applyModuleMigrations } from './module.js';
import { ask as askText, askRequired, askSecret, choose, confirm, isInteractive } from '../prompt.js';
import { register, registryUrl } from '../registry.js';
import { applyDemoSeed, applySeeds } from '../seeds.js';
import { asUser, scalar } from '../sql.js';
import { syncSchemaVersion } from '../status.js';
import { bold, cyan, dim, heading, line, note, pairs, skipped, step, warn } from '../ui.js';

export const INIT_FLAGS = [
  ...CONNECTION_FLAGS,
  'country',
  'chart',
  'org',
  'company',
  'admin-email',
  'admin-password',
  'admin-user-id',
  'fiscal-year',
  'fiscal-year-start',
  'currency',
  'language',
  'vat-period',
  'filing-period',
  'iban',
  'bic',
  'bank-name',
  'demo',
  'register',
  'register-email',
  'registry-url',
  'no-modules',
  'no-company',
  'yes',
] as const;

/**
 * What `--no-company` has nothing to apply to. Each of them describes the
 * first company, and an installation made without one would take them in
 * silence and do nothing with them — which reads, a month later, as a company
 * set up in a currency nobody finds.
 */
const COMPANY_ONLY_FLAGS = [
  'country',
  'chart',
  'company',
  'fiscal-year',
  'fiscal-year-start',
  'currency',
  'language',
  'vat-period',
  'filing-period',
  'iban',
  'bic',
  'bank-name',
] as const;

export interface InitDeps extends CommandDeps {
  createAuthUser?: CreateAuthUser;
  fetchImpl?: typeof globalThis.fetch;
  /** Where `ekwo.json` is written. The working directory, unless a test says otherwise. */
  cwd?: string;
}

export async function initCommand(args: ParsedArgs, deps: InitDeps = {}): Promise<number> {
  rejectUnknownFlags(args, INIT_FLAGS);
  const noCompany = boolFlag(args, 'no-company');
  if (noCompany) refuseCompanyFlags(args);

  const yes = boolFlag(args, 'yes');
  const interactive = !yes && isInteractive();
  const makeUser = deps.createAuthUser ?? createAuthUser;

  const { db, connection } = await openDatabase(args, { interactive, connect: deps.connect });

  try {
    heading('Schema');
    const migrations = await listMigrations(migrationsDir());
    const result = await applyMigrations(db, migrations, (migration) => {
      step(migration.file);
    });
    if (result.applied.length === 0) {
      skipped(`${result.alreadyApplied} migration(s) already applied, nothing to do`);
    } else {
      note(dim(`${result.applied.length} applied, ${result.alreadyApplied} were already there`));
    }

    heading('Reference data');
    await applySeeds(db, seedDir(), (seed) => {
      step(seed.file);
    });
    skipped(`${DEMO_SEED} is sample data and is not applied here`);

    // The modules, as `ekwo migrate` installs them and for the same reason: a
    // module is a schema whose tables stay empty until a company enables it.
    // Left out here, a fresh installation was one `ekwo status` reported as
    // sixteen migrations behind, with exit code 1, on the very next command —
    // which is what the first run against a real project, on 19 September
    // 2026, found. After the reference seeds, because a module's own seeds
    // are per country and name the packs those seeds load.
    if (!boolFlag(args, 'no-modules')) {
      await applyModuleMigrations(db, await listModules(), { heading: true });
    }

    if (noCompany) {
      return await installWithoutCompany(db, args, { interactive, connection, makeUser, migrations: result, deps });
    }

    // ---- What this installation is -----------------------------------------
    //
    // Every question below is asked the way `ekwo company new` asks it, from
    // `../company-choices.ts`: nothing is preselected on the three whose wrong
    // answer is expensive — the country, the chart and the language — and a
    // choice with nobody to make it is a refusal naming the flag.
    const country = await chooseCountry(db, args, interactive);

    const organization = await chooseOrganization(args, interactive);

    const company =
      stringFlag(args, 'company') ??
      (interactive ? await askRequired('Name of the first company?', organization) : organization);

    const fiscalYear = numberFlag(args, 'fiscal-year') ?? new Date().getUTCFullYear();
    const fiscalYearStart = await chooseFiscalYearStart(db, args, country, fiscalYear, interactive);
    const currencyCode = await chooseCurrency(db, args, country, interactive);
    const { chartCode, charts } = await chooseChart(db, args, country, interactive);
    const language = await chooseLanguage(db, args, country, interactive);

    // How often the company files each declaration it is subject to. The third
    // question of the same family as the currency and the language, and the one
    // with the sharpest consequence when it is wrong: a quarterly filer handed
    // a monthly return misses a deadline.
    //
    // It is asked **once per form**, because a company is subject to several
    // declarations and the cadence of one says nothing about the cadence of
    // another. Where a form offers one cadence there is nothing to ask. Where
    // it offers several, the pack proposes one only if the law of that country
    // gives one answer to everybody — `period_default` on the form — and where
    // it does not, the question is asked with nothing preselected and "later"
    // among the answers: a company that has not decided is recorded as not
    // having decided rather than as filing monthly.
    const forms = await countryFilingForms(db, country);
    const periodicReturn = forms.find((form) => form.isPeriodicReturn);
    const askedPeriods = new Map<string, string>();
    for (const pair of stringFlags(args, 'filing-period')) {
      const equals = pair.indexOf('=');
      if (equals <= 0 || equals === pair.length - 1) {
        throw new UsageError(
          `--filing-period takes <report_code>=<cadence>, one per declaration (got "${pair}")`,
        );
      }
      askedPeriods.set(pair.slice(0, equals), pair.slice(equals + 1).toLowerCase());
    }
    const askedVatPeriod = stringFlag(args, 'vat-period')?.toLowerCase();
    if (askedVatPeriod !== undefined) {
      if (periodicReturn === undefined) {
        throw new UsageError(
          `no_periodic_return: this installation carries no periodic return for ${country}, ` +
            'so there is no declaration --vat-period could be about.',
        );
      }
      askedPeriods.set(periodicReturn.code, askedVatPeriod);
    }
    for (const code of askedPeriods.keys()) {
      if (forms.some((form) => form.code === code)) continue;
      throw new UsageError(
        `unknown_tax_report: ${code} is not a declaration form of ${country} in this ` +
          `installation (${forms.map((form) => form.code).join(', ') || 'it carries none'}).`,
      );
    }

    const filingPeriods: Record<string, string> = {};
    for (const form of forms) {
      const flagged = askedPeriods.get(form.code);
      if (flagged !== undefined && form.periods.length > 0 && !form.periods.includes(flagged)) {
        throw new UsageError(
          `unknown_vat_period: ${form.code} is filed ${form.periods.join(' or ')}, not ${flagged}.`,
        );
      }
      const chosen =
        flagged ??
        (form.periods.length === 1
          ? form.periods[0]
          : form.periods.length > 1 && interactive
            ? await choose(`How often does this company file ${form.name}?`, [
                ...form.periods.map((code) => ({
                  value: code,
                  label:
                    code === form.periodDefault
                      ? `every ${code} — what the law of this country gives everybody`
                      : `every ${code}`,
                })),
                { value: 'later', label: 'not decided yet; ekwo status will say so' },
              ])
            : form.periodDefault);
      if (chosen === undefined && form.periods.length > 1) {
        // Outside an interactive session there is nobody to ask and nothing
        // lawful to assume: the cadence of this form is a fact about the
        // company, and the pack said so by proposing none.
        throw new UsageError(
          `no_filing_period: ${form.code} is filed ${form.periods.join(' or ')} and the ` +
            `${country} pack proposes none, because the law makes it depend on the company. ` +
            `Pass --filing-period ${form.code}=<cadence>` +
            (form.isPeriodicReturn ? ', or --vat-period <cadence>' : '') +
            '.',
        );
      }
      if (chosen !== undefined && chosen !== 'later') filingPeriods[form.code] = chosen;
    }

    // What the operator is about to install, and how much anyone has read it.
    const pack = await countryPack(db, country);
    if (pack === undefined) {
      warn(`no country pack is recorded for ${country}; the seeds of this release declare one.`);
    } else {
      const said = `${pack.name} pack ${pack.version}: ${describeCertification({
        status: pack.certificationStatus,
        by: pack.certifiedBy,
        on: pack.certifiedAt,
      })}.`;
      if (needsWarning(pack.certificationStatus)) {
        warn(`${said} Check the boxes against your own situation before you file anything.`);
      } else {
        note(dim(said));
      }
    }

    // The main bank account. Optional everywhere: a company can be installed
    // and book sales without one, and `ekwo doctor` is what notices later.
    const iban =
      stringFlag(args, 'iban') ??
      (interactive
        ? emptyToUndefined(await askText('IBAN of the main bank account? (optional, Enter to skip)'))
        : undefined);
    const bankAccount =
      iban === undefined || iban.length === 0
        ? undefined
        : {
            iban,
            bic:
              stringFlag(args, 'bic') ??
              (interactive ? emptyToUndefined(await askText('BIC? (optional)')) : undefined),
            bankName:
              stringFlag(args, 'bank-name') ??
              (interactive ? emptyToUndefined(await askText('Name of the bank? (optional)')) : undefined),
          };

    // ---- The first administrator -------------------------------------------
    heading('First administrator');
    const adminUserId = await resolveAdminUser(db, args, {
      interactive,
      connection,
      makeUser,
    });

    // ---- The installation sequence -----------------------------------------
    heading('Installation');
    const outcome = await bootstrap(db, {
      organization,
      country,
      company,
      fiscalYear,
      ...(fiscalYearStart === undefined ? {} : { fiscalYearStart }),
      adminUserId,
      currencyCode,
      language,
      ...(chartCode === undefined ? {} : { chartCode }),
      filingPeriods,
      bankAccount,
    });
    for (const s of outcome.steps) {
      const text = s.detail === undefined ? s.name : `${s.name} — ${s.detail}`;
      if (s.outcome === 'created') step(text);
      else skipped(`${text} (already there)`);
    }

    const schemaVersion = await syncSchemaVersion(db);

    // ---- The demo company, only when asked ---------------------------------
    if (boolFlag(args, 'demo')) {
      heading('Demo company');
      await asUser(db, adminUserId, () => applyDemoSeed(db, seedDir()));
      step('Exemple Conseil SRL, its contacts, invoices, a payment and a statement');
      warn('Fictional data, including a fictional administrator. Do not leave it on real books.');
    }

    // ---- ekwo.json ----------------------------------------------------------
    const configFile = await writeInstallationConfig(connection, schemaVersion, deps);

    setResult({
      organization,
      instanceId: outcome.instanceId,
      adminUserId,
      company: {
        id: outcome.companyId,
        name: company,
        country,
        currency: outcome.currencyCode,
        language: outcome.language,
        chart: outcome.chartCode ?? null,
        packVersion: outcome.packVersion ?? null,
      },
      fiscalYear: {
        name: outcome.fiscalYearName,
        start: outcome.fiscalYearStart,
        end: outcome.fiscalYearEnd,
      },
      filingPeriods: outcome.filingPeriods,
      bankAccountId: outcome.bankAccountId ?? null,
      migrations: { applied: result.applied.map((m) => m.file), alreadyApplied: result.alreadyApplied },
      steps: outcome.steps,
      schemaVersion: schemaVersion ?? null,
      demo: boolFlag(args, 'demo'),
      configFile,
    });

    // ---- Registration, offered, never required ------------------------------
    await offerRegistration(db, args, { interactive, adminUserId, deps });

    heading('Done');
    pairs([
      ['organisation', organization],
      ['company', `${company} (${country}, ${outcome.currencyCode}, ${outcome.language})`],
      [
        'chart of accounts',
        `${outcome.chartCode ?? 'unknown'}${
          charts.find((c) => c.code === outcome.chartCode)?.name === undefined
            ? ''
            : ` — ${charts.find((c) => c.code === outcome.chartCode)?.name}`
        }`,
      ],
      ...forms.map((form): [string, string] => [
        `files ${form.name}`,
        outcome.filingPeriods[form.code] === undefined
          ? 'not recorded'
          : `every ${outcome.filingPeriods[form.code] as string}`,
      ]),
      [
        'country pack',
        pack === undefined
          ? 'none recorded'
          : `${pack.version} — ${describeCertification({ status: pack.certificationStatus, by: pack.certifiedBy, on: pack.certifiedAt })}`,
      ],
      ['financial year', `${outcome.fiscalYearName} — ${outcome.fiscalYearStart} to ${outcome.fiscalYearEnd}`],
      ['bank account', bankAccount === undefined ? 'none — ekwo doctor will say so' : bankAccount.iban],
      ['schema version', schemaVersion ?? 'unknown'],
      ['config', configFile],
    ]);
    line();
    line(`  ${bold('Next:')} sign in to your Supabase project as the administrator you just created,`);
    line(`  then ${cyan('ekwo status')} to see what is there and ${cyan('ekwo doctor')} to check it.`);

    // The last thing on the screen, because it is the part nobody can do for
    // the operator: three settings of their own project and one piece of
    // reading. `packages/cli/README.md` carries the same four, and a test
    // reads both so the two cannot drift.
    printOperatorChecklist();
    line();
    return 0;
  } finally {
    await db.close();
  }
}

/** The organisation, written on the instance row. Asked with or without a company. */
async function chooseOrganization(args: ParsedArgs, interactive: boolean): Promise<string> {
  return (
    stringFlag(args, 'org') ??
    (interactive ? await askRequired('Name of your organisation?') : required('--org', 'the organisation name'))
  );
}

/**
 * `--no-company` with a flag that only describes a company is a usage error,
 * refused before the database is touched. The message names where each of
 * them goes instead: `ekwo company new`, once per company.
 */
function refuseCompanyFlags(args: ParsedArgs): void {
  const given = COMPANY_ONLY_FLAGS.filter((name) => args.flags.has(name));
  if (given.length === 0) return;
  throw new UsageError(
    `company_flags_without_company: --no-company creates no company, so ${given
      .map((name) => `--${name}`)
      .join(', ')} would describe nothing. ` +
      'Install first, then pass them to `ekwo company new "<name>" --country <cc>`, once per company.',
  );
}

/**
 * `ekwo.json`: which project this installation is, and at which schema
 * version. No country — an installation holds companies of several, and each
 * one carries its own.
 */
async function writeInstallationConfig(
  connection: { supabaseUrl?: string | undefined },
  schemaVersion: string | undefined,
  deps: InitDeps,
): Promise<string> {
  return writeConfig(
    {
      ...(connection.supabaseUrl !== undefined ? { project_url: connection.supabaseUrl } : {}),
      ...(schemaVersion !== undefined ? { schema_version: schemaVersion } : {}),
    },
    deps.cwd,
  );
}

/**
 * `ekwo init --no-company`: the schema, every pack, the modules, the first
 * administrator and the instance row, and nothing else.
 *
 * For an installation that keeps the books of companies in several countries,
 * where "the country of the installation" is a question with no answer. Each
 * company is then created by `ekwo company new`, in its own country, on the
 * same questions and the same refusals the first company of `init` meets.
 */
async function installWithoutCompany(
  db: Awaited<ReturnType<typeof openDatabase>>['db'],
  args: ParsedArgs,
  options: {
    interactive: boolean;
    connection: { supabaseUrl?: string | undefined; serviceRoleKey?: string | undefined };
    makeUser: CreateAuthUser;
    migrations: { applied: { file: string }[]; alreadyApplied: number };
    deps: InitDeps;
  },
): Promise<number> {
  const { interactive, deps } = options;
  const packs = await installedPacks(db);
  const organization = await chooseOrganization(args, interactive);

  heading('First administrator');
  const adminUserId = await resolveAdminUser(db, args, {
    interactive,
    connection: options.connection,
    makeUser: options.makeUser,
  });

  heading('Installation');
  const claimed = await claimInstance(db, { organization, adminUserId });
  for (const s of claimed.steps) {
    const text = s.detail === undefined ? s.name : `${s.name} — ${s.detail}`;
    if (s.outcome === 'created') step(text);
    else skipped(`${text} (already there)`);
  }
  skipped('no company — --no-company');

  const schemaVersion = await syncSchemaVersion(db);

  if (boolFlag(args, 'demo')) {
    heading('Demo company');
    await asUser(db, adminUserId, () => applyDemoSeed(db, seedDir()));
    step('Exemple Conseil SRL, its contacts, invoices, a payment and a statement');
    warn('Fictional data, including a fictional administrator. Do not leave it on real books.');
  }

  const configFile = await writeInstallationConfig(options.connection, schemaVersion, deps);

  setResult({
    organization,
    instanceId: claimed.instanceId,
    adminUserId,
    company: null,
    fiscalYear: null,
    filingPeriods: {},
    bankAccountId: null,
    migrations: {
      applied: options.migrations.applied.map((m) => m.file),
      alreadyApplied: options.migrations.alreadyApplied,
    },
    steps: claimed.steps,
    schemaVersion: schemaVersion ?? null,
    demo: boolFlag(args, 'demo'),
    configFile,
  });

  await offerRegistration(db, args, { interactive, adminUserId, deps });

  heading('Done');
  pairs([
    ['organisation', organization],
    ['companies', 'none yet'],
    ['country packs', packs.map((p) => `${p.country} (${p.name})`).join(', ') || 'none'],
    ['schema version', schemaVersion ?? 'unknown'],
    ['config', configFile],
  ]);
  line();
  line(`  ${bold('Next:')} create each company in its own country, as this administrator:`);
  line(`  ${cyan('ekwo company new "<name>" --country <cc>')}, then ${cyan('ekwo company list')}.`);

  printOperatorChecklist();
  line();
  return 0;
}

/** An unanswered optional question is not an empty string. */
function emptyToUndefined(value: string): string | undefined {
  return value.length === 0 ? undefined : value;
}

/**
 * The id that will be written into `instance_admins` and `company_members`.
 *
 * Either an account already exists and its id was given, or one is created
 * through the Supabase Auth admin API. There is no third way: the id has to
 * be one that `auth.uid()` will return for a real signed-in user, and only
 * GoTrue can mint that.
 */
async function resolveAdminUser(
  db: Awaited<ReturnType<typeof openDatabase>>['db'],
  args: ParsedArgs,
  options: {
    interactive: boolean;
    connection: { supabaseUrl?: string | undefined; serviceRoleKey?: string | undefined };
    makeUser: CreateAuthUser;
  },
): Promise<string> {
  const given = stringFlag(args, 'admin-user-id');
  if (given !== undefined) {
    const exists = await scalar<boolean>(
      db,
      'select exists (select 1 from auth.users where id = $1)',
      [given],
    );
    if (exists !== true) {
      throw new UsageError(
        `unknown_user: ${given} is not a user of this Supabase project. ` +
          'Create the account first, or drop --admin-user-id and let the CLI create one.',
      );
    }
    skipped(`using the existing account ${given}`);
    return given;
  }

  const email =
    stringFlag(args, 'admin-email') ??
    (options.interactive
      ? await askRequired('E-mail address of the first administrator?')
      : required('--admin-email', "the administrator's address"));

  const { supabaseUrl, serviceRoleKey } = options.connection;
  if (supabaseUrl === undefined) {
    throw new UsageError(
      'missing_supabase_url: creating the first user needs the project URL. ' +
        'Pass --supabase-url, or set SUPABASE_URL.',
    );
  }
  const key =
    serviceRoleKey ??
    (options.interactive
      ? await askSecret('service_role key (Project Settings → API). It is never written to disk:')
      : required('--service-role-key', 'the service_role key'));

  const password =
    stringFlag(args, 'admin-password') ??
    (options.interactive
      ? await askSecret('Password for that administrator (blank to send an invite link instead):')
      : undefined);

  const user = await options.makeUser({
    supabaseUrl,
    serviceRoleKey: key,
    email,
    password: password !== undefined && password.length > 0 ? password : undefined,
  });

  if (user.created) step(`created ${email} in your Supabase Auth`);
  else skipped(`${email} already had an account here`);
  if (user.actionLink !== undefined) {
    note(dim('No password was set. Send them this link to choose one:'));
    note(user.actionLink);
  }

  // The foreign key on instance_admins will refuse an id GoTrue has not
  // written yet; say so here rather than three steps later.
  const visible = await scalar<boolean>(
    db,
    'select exists (select 1 from auth.users where id = $1)',
    [user.id],
  );
  if (visible !== true) {
    throw new Error(
      `auth_user_not_visible: Supabase Auth reported user ${user.id}, but the database does not ` +
        'see it. Check that --db-url and --supabase-url point at the same project.',
    );
  }

  return user.id;
}

async function offerRegistration(
  db: Awaited<ReturnType<typeof openDatabase>>['db'],
  args: ParsedArgs,
  options: { interactive: boolean; adminUserId: string; deps: InitDeps },
): Promise<void> {
  const asked = boolFlag(args, 'register');
  const wanted = asked
    ? true
    : options.interactive
      ? await ask(
          'Register this installation with Ekwo to receive security advisories and release notes?',
        )
      : false;

  if (!wanted) {
    heading('Registration');
    skipped('not registered — Community works unregistered, forever');
    note(dim('Change your mind later with `ekwo register --email you@example.com`.'));
    return;
  }

  const email =
    stringFlag(args, 'register-email') ??
    stringFlag(args, 'admin-email') ??
    (options.interactive ? await askRequired('Contact address?') : undefined);
  if (email === undefined) {
    warn('--register needs an address: pass --register-email or --admin-email. Skipped.');
    return;
  }

  heading('Registration');
  const url = stringFlag(args, 'registry-url') ?? registryUrl();
  const result = await register(db, {
    adminUserId: options.adminUserId,
    email,
    url,
    ...(options.deps.fetchImpl !== undefined ? { fetchImpl: options.deps.fetchImpl } : {}),
  });
  step(`recorded on the instance row: ${email}`);
  if (result.announced) {
    step(`announced to ${url}`);
  } else {
    warn(`could not reach ${url} (${result.reason ?? 'unknown'}).`);
    note(dim('The local registration stands. `ekwo register` will try again.'));
  }
  note(dim(`Sent: ${JSON.stringify(result.payload)}`));
}

/** Yes/no with no as the default, kept separate so the wording stays fixed. */
async function ask(question: string): Promise<boolean> {
  return confirm(question, false);
}
