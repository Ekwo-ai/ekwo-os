# A shared instance keeps its tenants apart

> Status: accepted

## Context

[0001](0001-one-installation-is-one-customer.md) says one installation belongs
to one customer, and every instance-level rule of the schema follows from it.
The first signed-in user may claim an installation that nobody administers. A
company with no member is claimed by whoever inserts the first membership. A
few definer helpers answer about any company whose id they are given:
`module_is_enabled()`, `module_settings()`, `preferred_languages()`,
`company_has_no_member()`. And a handful of definer functions that take the id
of a row say *unknown* when the row does not exist and *not allowed* when it
belongs to a company the caller may not act on. On an installation that is one
customer's, each of these is a convenience or a harmless difference in wording.

An operator may also run one installation for several people who do not know
each other: a trial, where each person keeps a company of their own on an
instance the operator hosts, and moves it to a project of their own later with
`export_company()` and `import_company()` ([0043](0043-a-company-leaves-with-its-books.md)).
Row level security already keeps one company's rows from another's members.
What it does not do is keep a person from learning that another company exists,
or from creating companies at all: creating a company is an instance-level act,
so a person on such an instance could not create their own.

## Decision

**An installation may be shared.** Two columns of `instance`, `shared` and
`companies_per_person`, are off and empty by default, so nothing changes for an
installation that is one customer's. `share_instance(n)` turns sharing on and
`unshare_instance()` turns it off. Both are the installer's or an instance
administrator's, and both are written on the trail. `instance_sharing()` tells
anybody signed in whether the installation is shared, and nothing else.

**On a shared installation a person creates a company of their own.**
`create_company()` lets a signed-in person, in their own session, create up to
`companies_per_person` companies, counted under a lock on the person. The
company is owned by that person and by nobody else they could name. A machine
key never may: ownership is a membership, and a key does not choose it
([0064](0064-a-key-writes-as-its-issuer.md)). The function becomes
`security definer`, because neither the insert policy on `companies` nor the one
on `company_members` lets a person create a company they are not yet a member
of. Its guard is the whole rule, and for an administrator and the installer it
is exactly the rule it was.

**On a shared installation, nobody learns of a company they may not know of.**
`may_know_of_company()` answers true on an installation that is not shared. On
a shared one it answers true for the company's members, a key of the company,
an instance administrator and the installer, and false for anybody else.
`company_has_no_member()`, `module_is_enabled()`, `module_settings()` and
`preferred_languages()` answer anybody else as they answer about a company that
does not exist. `company_has_no_member()` answering false also closes the third
branch of the insert policy on `company_members`, so a company with no member is
claimed only by the installer or an administrator. The definer functions that
take the id of a row — `share_document()`, `revoke_share()`, `revoke_api_key()`,
`revoke_invitation()`, `unpost_document()`, `pack_upgrade()`,
`next_entry_number()`, `catch_up_journal_sequence()` — answer *unknown* for a
row of such a company, as for a row that does not exist.

**Nothing a person reads counts another company's work.** `audit_log.id` is
the installation's counter: the gap between two ids of one company is the
number of changes every other company made in between. It is not granted to a
signed-in user. The trail is read in the order of `occurred_at` and
`sequence`, the order of a change among those its transaction made to the same
company, which counts nothing the reader may not read already. An archive does
not carry the id; it was drawn again on arrival anyway.

**A row names rows of its own company, by one key.** Every reference from a
table that carries a company to another such table is a composite foreign key
with `company_id`, in the socle and in every module. A single-column key
accepted an id of another company, and so said that it exists, and let a
reference planted that way keep the other company from deleting its row;
beside a composite key it failed under another name than for an id of nobody.
Every unique key of those tables that holds such a reference holds the company
too, or a row naming another company's row collides with it before any foreign
key is asked. `scope_references_to_company()` does both from the catalogue,
for the socle and for each module's schema. The definer guards that read the
row a new value names — of a posted document, its lines, a posted entry and
its lines — look for it in the row's own company, and step aside for a row
headed for a company the caller may not know of, which row level security
then refuses. A preferred company the caller may not know of is refused as
one that does not exist.

**A shared installation keeps its administrator.** It is shared only when it
has one, nobody claims it while it is shared, and its last administrator does
not leave: an installation with none is claimed by the first person to sign
in, and an administrator reaches every company.

**The allowance counts what a person created.** `companies.created_by` records
who created a company, once; it cannot be rewritten, and `create_company()`
counts it. Handing a company to a second account does not give the allowance
back. A company that existed before the column is counted against its first
owner, as the allowance counted it until then.

**The test asks the catalogue.** `tests/shared_instance.test.ts` puts two people
on one shared installation and has the second probe the first's company. It
reads every table and view that carries a company. It calls every function a
signed-in user may call, once per uuid argument in any position, with each of
the first person's ids and with an id nobody holds. Then it compares the two
answers, ids scrubbed. It does this both as a session and through a machine key. It walks every
schema that holds a company's rows, modules included. It writes: for every
table with a company the person may write, a row of their own is updated and
copied with every uuid its foreign keys read pointing at a row of the first
person's, then at a row of nobody's, and the answers have to match — which is
how a guard that quotes a number or a key that answers by another name shows
itself. It hands the first person's ids inside the objects and lists that the
functions read them from, the functions found from the catalogue and their
shapes written down beside the test, which refuses one that is not. And it
reads everything the second person may read with the first person idle and
with her busy, and requires the two to be the same.
`tests/mcp/shared_instance.test.ts` does the same through every tool of the MCP
server, in a company of nobody's and in the person's own. A table, a function
or a tool added later is probed without anybody listing it. The last four
functions above were found that way.

**What sharing does not change.** What a member may do in their company, what a
key may do, and what an instance administrator may do. On a shared
installation the administrator is the operator, who already reaches every
company through the database. The installation claims its first administrator
when it is installed, before any person signs in, and an operator hosting
people never makes a person an administrator of the shared installation. Every
company member still reads the `instance` row and the ids of its
administrators, which on a shared installation are the operator's.

## Consequences

- An operator can host many small companies on one installation, one company
  per person, without anybody seeing or learning of anybody else's company. A
  company leaves for an installation of its own with the archive of 0043,
  unchanged.
- On a shared installation a person who is not a member of a company and holds
  a link to one of its documents sees that document's labels in the
  document's own language, without the company's fallback languages.
- An installation that is not shared is unchanged in every answer, which
  `tests/shared_instance.test.ts` checks before it shares one.
- A definer function written later that looks a row up by id before checking
  the caller fails the sweep on a shared installation until it asks
  `may_know_of_company()` first.
- A signed-in client reads `audit_log` by naming its columns: `select *` is
  refused, because it names `id`. A tool that sorted the trail by `id` sorts
  it by `occurred_at` and `sequence`.
- A reference between two rows of one company that named a row of another
  is refused, by the composite key, and a reference to nothing is refused by
  that key's name. A unique key that holds a reference holds the company.
- A person who already holds the id of a row of another company can still
  learn that the id is taken, by inserting a row of their own that carries it:
  the primary key answers before anything else does. The ids are random, so it
  takes the id itself, which nothing above gives away.

## See also

- `supabase/migrations/20261007060225_a_shared_instance_keeps_its_tenants_apart.sql`
- `supabase/migrations/20261007113412_a_tenant_measures_nothing_of_another.sql`,
  and `20261007113413`, `20261007113414` and `20261007113415` in the
  `budgets`, `fixed-assets` and `corporate-tax` modules
- `tests/shared_instance.test.ts`, `tests/mcp/shared_instance.test.ts`
- [0001 One installation belongs to one customer](0001-one-installation-is-one-customer.md)
- [0043 A company leaves with its books](0043-a-company-leaves-with-its-books.md)
- [0064 A key writes as the person who issued it](0064-a-key-writes-as-its-issuer.md)
