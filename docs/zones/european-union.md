# The European Union

A zone is a set of countries that share rules the others do not. The European
Union is one of them, and the rules that exist only inside it are described
here rather than in the core, which knows nothing of any zone. A pack says it
belongs to this one with `"zones": ["european-union"]` in its `pack.json`; a
country outside it — the [United Kingdom](united-kingdom.md), the
[United States](united-states.md), and every pack that does not declare the
zone — is never asked any of what follows.

The core is the same everywhere. What this page lists is data that Member
State packs carry, and readers that only find something to read when a pack
has put it there.

## What belongs to the zone

**Intra-community VAT.** Between two Member States, a supply of goods to a
business in another Member State is relieved in the seller's country and
taxed in the buyer's, by the buyer, under Directive 2006/112/EC. A pack of the
zone declares the taxes for it with the treatments `intracom_goods`,
`intracom_services`, `intracom_acquisition_goods` and
`intracom_acquisition_services`, and `intracom_triangular` where a country
uses the triangular arrangement of articles 141 and 197. The vocabulary of
treatments is in [`docs/packs.md`](../packs.md). Membership of the zone is
declared by the pack; the treatments describe how a tax behaves, and a pack
outside the zone that sells into it may use them for its own reasons.

**The recapitulative statement.** `ec_sales_list()` sums, from the posted
ledger, what a company supplied to identified businesses in other Member
States, per customer VAT number and per nature — goods, services. Which
countries count as inside the common system on a given day is a row of the
`territories` reference table (`eu_vat_scope`), asked as at the date of the
supply, not a list in code. The file formats a Member State asks for are bricks
under [`packages/formats/`](../../packages/formats/), organised by format and
not by country.

**VIES.** The customer's VAT number carries the prefix of the State that
issued it, and `territories` records that prefix; Greece is `EL`, and Northern
Ireland is `XI` for goods. Ekwo reads the prefix to place a customer. It does
not query the VIES service to confirm a number: a number is valid because
somebody checked it, and that check is the company's to make.

**The One-Stop Shop.** Not implemented. The scheme asks in which Member State
tax had to be charged, at what rate, for consumers; it needs a rate per State
of consumption, and a rate is a tax and lives in a pack. The reasoning is
written up in [`docs/international.md`](../international.md), so that whoever
builds it starts from the shape and not from nothing.

**EN 16931 and Peppol.** The European standard for the semantic model of an
electronic invoice, and the profile most Member State packs name in
`einvoicing`. Its fields (BT-…), its categories (`K` for an intra-community
supply, `AE` for a domestic reverse charge) and its exemption reason codes
(`VATEX-EU-IC` and the others) are normative identifiers and are kept as the
standard writes them. Which Member State makes the format obligatory, and from
when, is each pack's `einvoicing.obligation` and `mandatory_from`, cited to its
own law. The Peppol invoice reader and writer are in
[`packages/formats/peppol-ubl`](../../packages/formats/peppol-ubl/).

## What is not in the zone

Nothing here is a rule of every country. A company outside the European Union
that sells to a customer inside it is not making an intra-community supply; it
is exporting, and its own country's pack says how. A pack that needs a
distinction between "inside the zone" and "outside" for one of its own taxes
expresses it as a condition on the territory of the parties
([decision 0024](../decisions/0024-a-tax-follows-the-territory-of-the-parties.md)),
not as a check on a zone name.

## Which packs

`ekwo pack describe <cc>` prints the zones of a pack. `ekwo pack check` refuses a pack that declares a zone
with no page in this folder.
