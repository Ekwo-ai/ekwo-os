# A tax follows the territory of the parties

> Status: accepted

## Context

A country is not always the unit of tax. Northern Ireland taxes goods under
different rules from Great Britain; American sales tax is levied by states and
follows the place of delivery, so the buyer's territory matters as much as the
seller's. `fiscal_country || '-' || region` reaches `US-CA` and never `XI`,
which has no parent in ISO 3166-2.

## Decision

### Where a party's territory comes from

**A territory is a column of its own, a key of `territories`.**
`companies.territory_code`, `contacts.territory_code`,
`documents.supply_territory_code` and `taxes.applies_*` all reference
`territories(code)`, whose `parent_code` draws the tree (`XI` under `GB`,
`ES-CE` under `ES`).

**Null is the ordinary case and resolves along a ladder of recorded facts.**
Seller and buyer are the company and the contact, decided by the document kind.
Each resolves to its `territory_code`, else its country
(`companies.fiscal_country`, `contacts.country`). The supply resolves to
`documents.supply_territory_code`, else `documents.delivery_country` (BG-15),
else the buyer's territory. When the ladder runs out and a tax asks,
`post_document()` raises `no_party_territory` naming the party, the tax and the
column that would answer.

### What a tax may say

**`applies_when` is a closed vocabulary of keys, each an equality, all of which
must hold:** `seller_in`, `buyer_in`, `supply_in`, and `supply_vs_seller`
(`same` | `other`). No operator, negation, disjunction or nesting. A list of
conditions was refused as the beginning of an expression language.

**A condition is met by the territory named and every territory inside it** —
for tax purposes. `territories.outside_parent_tax` (set by the seed, with the
national text in `legal_reference`, never by a pack) stops the walk: Spanish
VAT does not follow into the Canary Islands, Ceuta and Melilla, German VAT
stops at Büsingen and Heligoland. `territory_within_for_tax()` implements this;
`territory_within()` stays geographic, and `eu_vat_scope` stays a separate
fact.

**"Shipped out of the state" is a relation, not a negation.** `supply_vs_seller`
compares the place of supply with the seller's own territory at the seller's
level; a seller whose territory is a whole country has no level to compare at
and the document is refused. `ekwo pack check` refuses the key for a country
with no territory inside it.

**`jurisdiction` is kept separate.** It says who levies the tax (for the
invoice and reports); `applies_when` says when the tax can be reached. `ekwo
pack check` requires a given `jurisdiction` to name a known territory.

### What the engine does

**It refuses, it does not choose.** `post_document()` resolves the three
territories on every document, writes them on it (`seller_territory_code`,
`buyer_territory_code`, `supply_territory_resolved` — text, not foreign keys,
since the last rung may be a country no pack books in; frozen at posting,
cleared on unpost), and refuses a tax the document contradicts:
`tax_territory_mismatch`, naming the tax, the condition and the territory
found. A rule table that *suggests* taxes is out of scope: the core chooses no
tax for anyone.

**The EN 16931 exemption list is checked against the tax's territory.** A tax
applying in `XI` is inside the common system for goods only, which is the
Northern Ireland arrangement expressed as a check.

## Consequences

- Nexus thresholds and resale certificates are not modelled: a territory
  condition says which taxes exist for a party, not which one is right.
- A pack with one declaration form cannot yet declare taxes of another
  territory; forms per territory are a known gap.

## See also

- `tests/tax_territory.test.ts`, `tests/territories.test.ts`,
  `tests/tax_conditions.test.ts`
- [`international.md`](../international.md)
