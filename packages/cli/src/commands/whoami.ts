/**
 * `ekwo whoami` and `ekwo use`.
 *
 * `whoami` answers the four questions a caller has before it touches a
 * ledger: who am I here, on which instance and at which schema version, which
 * companies can I see, and what may I do on the one in use. Every part of the
 * answer is asked of the instance as the person — the companies are the rows
 * the policies let through, and the capabilities are `member_capabilities()`,
 * the function the MCP server calls for `your_capabilities`. Nothing is
 * worked out here.
 *
 * `use` records the company the next commands run on. It is checked against
 * the instance first, as the person: a company they cannot see is unknown.
 */

import { schemaIsAtLeast } from '@ekwo-ai/core';
import { UsageError, rejectUnknownFlags, stringFlag, type ParsedArgs } from '../args.js';
import { matchCompany } from '../company.js';
import { IDENTITY_FLAGS, actAsUser, refuseInstallerKey, type Acting, type UserDeps } from '../identity.js';
import { setContext, setResult } from '../output.js';
import { readProfiles, writeProfiles } from '../profiles.js';
import { SCHEMA_MIN } from '../schema.js';
import { bold, dim, heading, line, note, pairs, step, table, warn } from '../ui.js';

export const WHOAMI_FLAGS = [...IDENTITY_FLAGS] as const;
export const USE_FLAGS = ['profile'] as const;

interface CompanyRow {
  id: string;
  name: string;
  country: string;
  currency_code: string;
}

const COMPANY_COLUMNS = ['id', 'name', 'country', 'currency_code'] as const;

function visibleCompanies(acting: Acting): Promise<CompanyRow[]> {
  return acting.client.select<CompanyRow>('companies', { columns: COMPANY_COLUMNS, order: 'name.asc' });
}

/** `setof text` arrives as strings over PostgREST, and as one-column rows from some gateways. */
function capabilityCodes(rows: unknown[]): string[] {
  return rows
    .map((row) =>
      typeof row === 'string' ? row : (row as Record<string, unknown> | null)?.['member_capabilities'],
    )
    .filter((code): code is string => typeof code === 'string');
}

export async function whoamiCommand(args: ParsedArgs, deps: UserDeps = {}): Promise<number> {
  refuseInstallerKey(args);
  rejectUnknownFlags(args, WHOAMI_FLAGS);
  const acting = await actAsUser(args, deps);
  const instance = acting.client.instance.supabaseUrl;

  const user = await acting.client.user();
  const companies = await visibleCompanies(acting);

  // `--company` for this one answer, else the one in use. A company in use
  // that is no longer visible — a membership that ended — is said, not hidden.
  const asked = stringFlag(args, 'company');
  let company: CompanyRow | undefined;
  if (asked !== undefined) company = matchCompany(companies, asked);
  else if (acting.storedCompany !== undefined) {
    const stored = acting.storedCompany;
    company = companies.find((c) => c.id === stored.id);
    if (company === undefined) {
      warn(`the company in use, ${stored.name}, is no longer visible to you. \`ekwo use <company>\` picks another.`);
    }
  }
  setContext({
    profile: acting.profile ?? null,
    instance,
    company: company === undefined ? null : { id: company.id, name: company.name },
  });

  const versions = await acting.client.rpc<unknown>('ekwo_schema_version');
  const schemaVersion = typeof versions[0] === 'string' ? versions[0] : null;
  if (schemaVersion !== null && !schemaIsAtLeast(schemaVersion, SCHEMA_MIN)) {
    warn(`this instance is at schema ${schemaVersion} and this CLI is written against ${SCHEMA_MIN}. Its operator runs \`ekwo migrate\`.`);
  }

  const capabilities =
    company === undefined
      ? null
      : capabilityCodes(await acting.client.rpc<unknown>('member_capabilities', { p_company_id: company.id }));

  const profiles = acting.source === 'profile' ? Object.keys((await readProfiles(acting.configDir)).profiles).sort() : [];

  setResult({
    source: acting.source,
    profile: acting.profile ?? null,
    profiles,
    instance: { url: instance, schemaVersion },
    user: { id: user.id, email: user.email ?? null },
    company: company ?? null,
    capabilities,
    companies: companies.map((c) => ({ ...c, inUse: c.id === company?.id })),
  });

  heading('Who');
  pairs([
    ['user', `${user.email ?? dim('no address')}  ${dim(user.id)}`],
    ['instance', instance],
    ['schema', schemaVersion ?? dim('unknown')],
    ['from', acting.source === 'environment' ? 'the environment' : `the profile ${acting.profile}`],
  ]);

  heading('Companies you can see');
  if (companies.length === 0) note(dim('None. Somebody has to invite you to one.'));
  else {
    table(
      [{ title: '' }, { title: 'name' }, { title: 'country' }, { title: 'currency' }, { title: 'id' }],
      companies.map((c) => [c.id === company?.id ? '*' : '', c.name, c.country, c.currency_code, dim(c.id)]),
    );
  }

  if (company !== undefined && capabilities !== null) {
    heading(`What you may do on ${company.name}`);
    if (capabilities.length === 0) note(dim('Nothing: you are not a member of it.'));
    else for (const code of capabilities) line(`  ${code}`);
  } else {
    line();
    note(dim(`No company in use. ${bold('ekwo use <company>')} picks one; --company names one for a single command.`));
  }
  return 0;
}

export async function useCommand(args: ParsedArgs, deps: UserDeps = {}): Promise<number> {
  refuseInstallerKey(args);
  rejectUnknownFlags(args, USE_FLAGS);
  const wanted = args.positional[0];
  if (wanted === undefined || args.positional.length > 1) {
    throw new UsageError('usage: ekwo use <company> — its name, in quotes when it has a space, or its id');
  }

  const acting = await actAsUser(args, deps);
  if (acting.profile === undefined) {
    throw new UsageError(
      'no_profile: the environment says who you are, and the environment has nowhere to keep a company. Pass --company to each command instead.',
    );
  }
  const company = matchCompany(await visibleCompanies(acting), wanted);
  const ref = { id: company.id, name: company.name };

  const file = await readProfiles(acting.configDir);
  const profile = file.profiles[acting.profile];
  if (profile === undefined) throw new UsageError(`unknown_profile: there is no profile called ${acting.profile}.`);
  await writeProfiles(acting.configDir, {
    ...file,
    profiles: { ...file.profiles, [acting.profile]: { ...profile, company: ref } },
  });

  setContext({ profile: acting.profile, instance: acting.client.instance.supabaseUrl, company: ref });
  setResult({ profile: acting.profile, company });
  heading('Company in use');
  step(`${company.name} ${dim(company.id)}, for the profile ${acting.profile}`);
  return 0;
}
