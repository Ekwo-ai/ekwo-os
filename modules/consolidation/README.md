# `consolidation` — a group of companies, and who is in it

One Postgres schema, `consolidation`. A group belongs to the company that
consolidates it — the parent, which enables the module — and names the other
companies of the same installation it holds, each for a period, by a method and
at a percentage of interest. The module **writes nothing in a member company**
and **not one line to the ledger**: it reads the members' books, under their
own row level security, and keeps its own rows in its own schema.

This version is the ground: groups, members and the perimeter of a date, and
what the companies of a group invoiced each other, paired side by side. The
eliminations themselves, the translation of currencies and the consolidated
statements read it and come next.

| Object | What it is |
|---|---|
| `consolidation.groups` | A group, owned by its parent: a code of the caller's, a name, the currency the group presents its figures in. |
| `consolidation.members` | One company in one group for one period — `entered_on` to `left_on` included, null while it stays — with its method, its percentage of interest (`ownership_rate`) and the share of its figures the group takes in line by line (`integration_rate`, derived). |

| Method | `integration_rate` |
|---|---|
| `full` | 100: every figure, the share of other holders shown apart |
| `proportional` | the percentage of interest |
| `equity` | 0: no line of its own, the group carries its share of the member's equity |

| Function | What it does |
|---|---|
| `consolidation.create_group(company, code, name, currency, notes)` | Creates a group in the currency given, or the parent's own. A code the company already has returns that group. |
| `consolidation.add_member(company, group, member, method, ownership_rate, entered_on, left_on, notes)` | Puts a company in the group for a period. The same call twice returns the first row. |
| `consolidation.end_membership(company, member_row, left_on)` | Closes a period; `left_on` is the last day in the perimeter. |
| `consolidation.perimeter(company, group, on)` | The companies in the group on a date: the parent first at 100 %, then every member whose period holds the date, and whether the caller can read its books. |
| `consolidation.require_readable(company, group, from, to)` | Refuses, naming the company, when the caller cannot read the books of the parent or of a member in the perimeter at any time between the two dates. |
| `consolidation.intragroup_parties(company, group, from, to)` | The contacts of each company of the group that are another company of it — by VAT number, or by registration number in the same country — and which number said so. |
| `consolidation.intragroup_documents(company, group, from, to)` | Every posted sale of one company of the group to another, paired with the purchase that carries its number in the buyer's books, and every side without a pair, each with its status. |

```sql
select enable_module(:parent, 'consolidation');

select id from consolidation.create_group(:parent, 'main', 'Main group');               -- :group
select consolidation.add_member(:parent, :group, :subsidiary, 'full', 80, date '2026-01-01');
select consolidation.add_member(:parent, :group, :joint_venture, 'proportional', 50, date '2026-01-01');

-- The interest in the subsidiary goes from 80 % to 100 % on 1 July.
select consolidation.end_membership(:parent, :subsidiary_row, date '2026-06-30');
select consolidation.add_member(:parent, :group, :subsidiary, 'full', 100, date '2026-07-01');

select * from consolidation.perimeter(:parent, :group, date '2026-12-31');
```

## What the companies of a group invoiced each other

```sql
select * from consolidation.intragroup_parties(:parent, :group, date '2026-01-01', date '2026-12-31');
select * from consolidation.intragroup_documents(:parent, :group, date '2026-01-01', date '2026-12-31');
```

A contact of one company is another company of the group when its **VAT
number** is that company's, or its **registration number** in the same
country, compared as `party_identifier()` compares two numbers — never by its
name. A **sale and a purchase are one operation** when the buyer's
`supplier_reference` is the seller's `number`, compared the same way; an
invoice with an invoice, a credit note with a credit note. A document counts
when both companies are in the group on its date.

| `status` | What it says |
|---|---|
| `matched` | Both sides, in the same currency, for the same untaxed and total amounts, both in the period. |
| `amount_differs` | Both sides, and the currency or an amount differs. |
| `period_differs` | Both sides agree, and one of them is booked outside the period. |
| `purchase_missing` | A sale whose number no purchase of the buyer carries. |
| `sale_missing` | A purchase whose reference no sale of the seller carries. |

The function lists and writes nothing: a difference is corrected by a person,
in the books of the company that is wrong. Amounts are in the currency of each
document, as booked.

## The rules it keeps

- **The parent is always in, at 100 %**, and is never a row of `members`:
  `consolidation_member_is_the_parent`.
- **Two periods of one company in one group never overlap**:
  `consolidation_member_overlap`. A change of interest or of method closes a
  period and opens the next, so the perimeter of any past date stays what it
  was.
- **Whoever puts a company in a group must be able to read its books**
  (`entries.read` in that company, as a member or through a key):
  `consolidation_member_unreadable`. A trigger holds it, for psql and PostgREST
  as for the functions.
- **Whoever reads a group is held to the same.** A member the caller cannot
  read comes out of `perimeter()` with `readable = false`, and
  `require_readable()` refuses by name — what every consolidated figure will
  call first, so that none comes out quietly short of a company.

Every refusal is `consolidation_<code>: <sentence>`.

## Rights

| Capability | Preset | What it allows |
|---|---|---|
| `consolidation.read` | viewer, client, accountant, owner | Read the groups of the parent and who is in each. |
| `consolidation.write` | accountant, owner | Create groups, put companies in them, close their periods. |

Both are held in the parent. Neither reaches into a member: its books are read
with what the caller holds there, and the module grants nothing on them.

## What leaves with a company

An archive of the parent carries its groups. It does not carry their members,
which name other companies of this installation by their id: the perimeter is
declared again where the archive arrives, once the companies it holds are there
too.

## What an accountant should check

- The method of each member, and its percentage of interest, against the
  group's own analysis of control: the module records them and does not judge
  them.
- The dates of entry and exit against the acts that changed the interest.
- That every company of the perimeter is in the same installation — a company
  kept elsewhere cannot be a member yet.
- That every company of the group is known to the others by its VAT or
  registration number: `intragroup_parties()` shows who was recognised, and a
  company missing from it has its operations missing from the pairs too.

The decisions behind this shape are
[0095](../../docs/decisions/0095-a-group-is-owned-by-its-parent.md), a group
is owned by its parent, and
[0096](../../docs/decisions/0096-an-intragroup-operation-is-paired-by-identifiers.md),
an operation between its companies is paired by their identifiers and its
number.
