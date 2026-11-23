# Upgrades

*Who upgrades an installation of Ekwo OS, what an upgrade does to the data
step by step, how to pause it, and what happens to an installation nobody
upgrades. For somebody who runs an installation, or has linked one to Ekwo
Cloud.*

An upgrade brings a database from the schema version it holds to the one a
newer release carries. There are two ways it happens, and which one applies
follows from who operates the database:

| | Who upgrades | When |
|---|---|---|
| **Ekwo OS on your own project, not linked to Ekwo Cloud** | You, with `ekwo migrate` | When you decide |
| **Your own project, linked to Ekwo Cloud** | You — or Ekwo Cloud, only if you chose it | When you decide, or in the nightly wave |
| **A project Ekwo hosts for you**, and the shared instance a company starts on | Ekwo Cloud | In the nightly wave, at every release |

## The policy

Four rules hold for every edition.

- **Forward only.** A release adds migrations; a published migration is never
  edited, and there is no "down" migration. Going back is restoring a copy
  ([decision 0059](decisions/0059-releases-and-schema-versions.md)).
- **Posted figures do not change.** A migration never rewrites a posted
  amount. This is promise 4 of [`road-to-1.0.md`](road-to-1.0.md), and the
  automatic upgrade below measures it on every company before it commits.
- **A country pack reaches a company only when somebody asks.** An upgrade
  refreshes the reference data a release carries. The chart of accounts and
  the taxes a company copied from its pack change only with
  `ekwo pack upgrade`, which lists what it would change first
  ([decision 0028](decisions/0028-a-pack-upgrade-is-never-silent.md)).
- **On your own project, nothing is upgraded without your choice.** The
  software does not call home and does not update itself
  ([`PRIVACY.md` §1](../PRIVACY.md#1-the-software-on-your-own-project)).

## Upgrading it yourself: `ekwo migrate`

```sh
npx -y ekwo-os@latest migrate
```

In order, as the command runs it:

1. **It shows the gap**: how many migrations are applied and which are
   pending. A database holding migrations the release does not know — it was
   installed by a newer version — is left untouched, and the command says to
   upgrade the command line first.
2. **It recommends a snapshot, and does not take one.** The copy is yours to
   make before you go on: the backups of your Supabase project, or `pg_dump`.
3. **It applies each pending migration in its own transaction**, the file and
   its row in the migration history together, in order. A file that fails
   leaves the database at the migration before it.
4. **It applies the migrations of the modules** the release carries, unless
   `--no-modules` is given ([`modules.md`](modules.md)).
5. **It re-applies the reference seeds**, which are written to be run again,
   unless `--skip-seeds` is given.
6. **It writes the new schema version** on the instance row.

`ekwo status` shows the gap without closing it, and `ekwo doctor` checks the
result; both are described in the
[installation guide](../packages/cli/README.md). `ekwo migrate` does not
compare your figures before and after: that check belongs to the automatic
upgrade below, and `ekwo doctor` is the one to run after a manual one.

## The automatic upgrade of Ekwo Cloud

Ekwo Cloud brings the instances it operates up to the release of Ekwo OS it
carries. Its own terms for this are the maintenance terms published at
<https://cloud.ekwo.ai/updates>; this section describes the same mechanism
for a reader of this repository.

### Which instances it touches

- **A project Ekwo hosts**, and the shared instance: always. Ekwo is the
  operator of the database, and there is nothing to switch on or off.
- **Your own Supabase project, linked to Ekwo Cloud**: only when you said yes
  to *Let Ekwo update this project*, under the maintenance terms in force,
  and gave the permission Supabase asks for on its own screen. The default is
  no, and a choice is never inferred. A yes given under earlier terms does
  not carry over to new ones: you are asked again.
- **An installation that is not linked**: never. Ekwo Cloud has no way into
  it.

While no maintenance terms are in force, no instance is upgraded at all, and
the choice is not offered.

### When it runs

- **Every night at 03:30 UTC**, in a wave (below).
- **When you sign in** and open your projects: a project of yours that is
  behind, and that may be upgraded, is upgraded then — at most once per
  release.
- **When you press the button.** On a project of your own that is not
  upgraded automatically, its card offers *Rehearse*, and *Update now* once
  the rehearsal has passed. The press is your consent for that one attempt.
- **After a new release of Ekwo Cloud is put online**, for Ekwo's own
  instance and the shared instance only. Every other project waits for the
  night.

### A wave

A wave takes the instances that are behind the release, one Supabase project
at a time:

1. **Ekwo's own instance goes first.** If the release fails there, nothing
   else is tried, and the owners' projects wait until it has come through.
2. **Then the projects Ekwo hosts**, every one of them on every run.
3. **Then the owners' projects** that may be upgraded, the oldest link first.
   Once twenty instances or more are linked, a run takes a tenth of those
   that are due, and the next run takes the next tenth.

A project that holds several companies — the shared instance does — is
upgraded once, for all of them. **The first failure stops the wave**: the
release itself may be at fault, and the instances after it wait. A refusal
that concerns one project alone, such as a paused project, is passed over and
the wave goes on.

### What one upgrade does, step by step

Each step either passes or ends the attempt. An attempt that ends before
step 8 has applied nothing of the release; what it leaves behind is the copy
of step 5 and the line an export writes on each company's audit trail.

1. **The ground is checked**: Ekwo hosts the project, or you said yes under
   the terms in force.
2. **The project is checked.** Every command names the Supabase project the
   instance was linked as, and is refused if the address on record no longer
   agrees with it. A project Supabase reports as paused or not ready is
   skipped, and tried again on a later run.
3. **What would run is read from your migration history**, by the code of
   `ekwo migrate` itself: the same files, in the same order. Nothing pending
   ends the attempt as *current*. A history newer than the release ends it
   untouched. Rows another product sharing the database wrote in that history
   are left alone.
4. **The archive is checked for completeness.** The instance is asked whether
   any table of a company is outside the company archive
   (`company_archive_unclassified()`); if one is, a complete copy cannot be
   taken and the upgrade does not start.
5. **A copy of every company is taken**: the company archive of
   [`company-archive.md`](company-archive.md), the same copy as the nightly
   backup, kept with your backups and labelled *before update to* followed by
   the release. A company the copy cannot reach ends the attempt.
6. **A dry run.** Every pending migration runs in one transaction that is
   rolled back, with the measurements of step 7 around it. Nothing is kept
   from it. An error, or a figure that moved, ends the attempt.
7. **Your choice is read again**, just before anything is written. A choice
   withdrawn in the meantime ends the attempt.
8. **The migrations run in one transaction.** Inside it, before the
   migrations and after them, these are measured for every company:
   - the trial balance, account by account — debits, credits and number of
     lines — read from the entry lines themselves;
   - the entries in each state, with their totals;
   - the number of rows the company holds in each table its archive carries,
     and their sum;
   - the number of companies.

   The two sets are compared before the transaction commits. **A single
   difference raises an error, and Postgres undoes the whole upgrade.** The
   measurements are written to a temporary table that is dropped with the
   transaction. The new schema version is written on the instance row in the
   same transaction.
9. **The reference data follows**, in batches, each in its own transaction
   with the same measurements around it. A batch that fails leaves the schema
   upgraded; the next run refreshes the reference data.
10. **The schemas the Data API serves are adjusted** when the release needs
    it: the core's own schema, `ekwo`, is added last in the list when the
    project has it and does not serve it yet — before the migrations of
    step 8, and again after them — and a module schema a migration renamed
    keeps being served under its new name. No other schema is added.
11. **The health checks of `ekwo doctor` run**, as they did before step 5. A
    problem that was not there before is reported as one, and stops the wave.

### What it reads and what it writes

**Read from your database**: the migration history, the schema version, the
list of companies, the measurements of step 8, the health checks — and, for
the copy of step 5, the company archive of each company.

**Written to your database**: what the migrations of the release define, their
rows in the migration history, the schema version on the instance row, and
the reference data of the release. A project Ekwo Cloud installed also keeps
a ledger of the release files it holds, written alongside, and the copy of
step 5 leaves its line on each company's audit trail. **No row of a company
is added or removed by the migrations, and no posted figure moves**: the
measurements of step 8 are what holds that, and an upgrade that would do
either is undone.

**Outside your database**: the copy of step 5 is company data kept by Ekwo
Cloud, exactly as a nightly backup is. What that means, when Ekwo reads it
and how long it is kept are in
[`PRIVACY.md` §3](../PRIVACY.md#3-ekwo-cloud-the-hosted-service), under
[*The backups hold your company data*](../PRIVACY.md#the-backups-hold-your-company-data).
The card of the project says what the last attempt came to, and when.

The files attached to documents stay in your project's storage, which an
upgrade does not touch.

### A rehearsal on its own

A rehearsal is steps 1 to 4 and step 6, without steps 5 and 7 to 11: the
pending migrations in a transaction that is rolled back, the figures
compared. Nothing is copied,
because nothing is kept. It is what *Rehearse* runs from the card of a
project of your own.

### Going back

There is no "down" migration, so going back is restoring. The copy of step 5
is with your backups, labelled, and `import_company()` takes it back into an
installation of Ekwo OS as the company was. What an archive carries, and what
belongs to the installation rather than to a company and is therefore not in
it — members, keys, invitations, the sign-in accounts — is listed in
[`company-archive.md`](company-archive.md#what-does-not-and-why); those are
protected by the single transaction of step 8 and by the backups of your
Supabase project itself.

## Pausing, and opting out

- **On your own project, linked**: turn *Let Ekwo update this project* off on
  the projects page of your Ekwo account. The next run leaves the project
  alone, and a run that is already preparing reads your choice again before
  it writes anything (step 7). Turn it back on whenever you like.
- **Never opting in** is the default: a linked project you did not say yes
  for is never upgraded by Ekwo Cloud. You upgrade it with `ekwo migrate`,
  or from its card.
- **A project Ekwo hosts** has no switch. To decide its upgrades yourself,
  move it to your own Supabase account; from then on it is a project of your
  own, and the default is no again.
- **Not linking at all** is always possible: nothing in this repository needs
  Ekwo Cloud ([`cloud-services.md`](cloud-services.md)).

A Supabase project that is paused is skipped by every run until it is
restored.

## An installation that is not upgraded

**Nothing happens to it.** It keeps its books, computes its statements and
exports everything at the version it holds, for as long as its database runs.
No release reaches into it, and its data stays readable with any PostgreSQL
client, whatever the version.

**A newer client still reads it**, down to a floor. Each published package
declares the oldest schema it reads (`SCHEMA_MIN`, in
[`packages/core/src/schema.ts`](../packages/core/src/schema.ts)); `ekwo
status` prints it beside the version installed. The floor is not the release
number: it rises only for a migration that is breaking for an older database
— a table or a column renamed or dropped, a function whose contract changed —
and a release that only adds leaves it where it is
([`releasing.md`](releasing.md), step 3).

- **Between the floor and the latest release**, the command line, the MCP
  server and Ekwo Cloud open the installation in full. What a newer release
  added is simply absent: a column is left out of the read, the older route
  is taken, or the one call that needs it is refused by name
  (`schema_too_old_for`), saying which version brings it. Ekwo Cloud adds a
  line saying an update is available.
- **Below the floor**, a newer client refuses rather than half-work: the MCP
  server answers `schema_too_old` with the command to run, and Ekwo Cloud
  shows the update screen instead of the books until the project is
  upgraded. The command line does not refuse: it prints the floor and warns.
  The data is untouched, and any PostgreSQL client still reads it.
  `npx -y ekwo-os@latest migrate` is the way back above the floor.

A project Ekwo hosts does not wait there: every wave takes it.

## See also

- [`releasing.md`](releasing.md) — how a release is cut, and the rule of the
  schema floor.
- [`company-archive.md`](company-archive.md) — the copy taken before an
  upgrade.
- [`cloud-services.md`](cloud-services.md) — where upgrades sit among what
  Ekwo operates.
- [`PRIVACY.md`](../PRIVACY.md) — what Ekwo holds, and when it reads it.
