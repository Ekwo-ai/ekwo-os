# Why we are building Ekwo

Every business on earth keeps accounts. They tell you whether your company is
alive, whether you can pay your people next month, whether you can afford to
try something new. Today most small businesses keep that knowledge in software
they rent, at a price they do not set, in a format they cannot take with them.

Ekwo gives it back. **Your company data belongs to you.** The rules that turn
it into accounts — a chart of accounts, a VAT return, a year-end — belong to
everyone who has to follow them.

Two things are changing at once. Machines now do the work of keeping accounts
that used to need a person at a keyboard: this is the moment a business can
finally understand its own numbers, on its own terms. And *what* you record is
changing too: invoices that travel as structured data between administrations,
assets that exist only on a chain, payments that settle in seconds, a tonne of
carbon that you will account for as strictly as a euro. Ekwo is built for
every country, every currency, every kind of asset, and for agents working
beside people.

Ekwo makes five commitments.

## 1. Your company data, in your hands.

You keep your own accounts, understand them and act on them, with software
you own and an agent you control. Your company data lives in a database you
hold the keys to, with an open API and an AI that works *for* you. Every
installation stands on its own, with us or without us, for as long as you
want it to. Every feature passes that test before it lands.

Autonomy is also knowledge. A trial balance that balances, a VAT return
computed from the transactions, a year-end close a small business runs
itself: this is how you know where your business stands.

## 2. AI at the keyboard. You stay in control.

Ekwo is designed for a machine to operate. The data sits in Postgres, the REST
API and its OpenAPI description come with it, and an MCP server sits on top:
an agent built on the model you choose reads the accounts, raises an invoice,
records it, matches a payment, pulls the VAT return — as *you*, under your own
row level security, with the data staying in your account. The agent is a user
of the company data, with the same rights and the same limits as the human
beside it, and you can replace it with another one tomorrow.

The figures stay exact. **The core computes every figure in code, without
calling a model.** A transaction, a tax, a declaration box, a reconciliation
rule is deterministic, reproducible and reviewable: the same inputs give the
same figure, on your machine and on an auditor's, this year and in seven years
when someone asks why. The intelligence goes where it helps you most — reading
a document, proposing a match, explaining a variance, drafting the answer to
the administration — and the arithmetic stays in code anybody can read. The
machine proposes, the rules decide, and when you ask why, you get the article
of law behind the figure.

## 3. Ready for the finance that is coming.

The next ten years of finance are already written into regulations:
structured electronic invoicing becoming the norm and then the law across the
European Union, filings that machines read before people do, instant
settlement, crypto-assets that a business holds and now reports on — MiCA, and
the reporting obligations that start to bite in 2026 — and, close behind, the
emissions that will sit in a report next to the revenue.

Ekwo has room for all of it in its shape. Amounts carry their own currency and
their own rounding. Formats live in independent libraries, organised by format
and never by country, so a new format is a new package. Everything beyond
double-entry bookkeeping — fixed assets, budgets, and next carbon, stocks,
crypto-assets — lives in its own Postgres schema, with its own migrations and
its own tests, and reaches the accounts through one function, in full view.

Crypto shows what this gives you. A token needs its own inventory, its own cost
basis, its own revaluation, and a reporting obligation that is two years old.
In Ekwo that is a module, written against a schema made ready for it, and the
accounts stay as they are. The carbon module makes the same bet from the other
end: a tonne of CO₂ recorded against the transaction that caused it, in the
same company data, with the same audit trail. Ekwo is the first to bring this
into open source accounting. It is where the name points.

## 4. Free and independent data infrastructure, in every country.

Accounting is a set of rules a society agreed on so that businesses can trust
each other: the same chart of accounts, the same declaration, the same
year-end, for everyone in a country. Those rules belong in the open, for every
business and every market.

Ekwo works with your accountant. It gives businesses and the accountants who
work with them the same open ground: schemas, the rules of each country as
data, and the tools to work on them.

In Ekwo a country is **data**: a pack of files an accountant can read, a
contributor can propose, and a test can prove. Countries on three continents
ship today — among them the United States, a country with no value added tax
at all, which shows what a format quietly assumed, and Senegal and Côte
d'Ivoire, on the one chart of accounts seventeen OHADA States share — and more
land every week. The rest of the world is open, and it is yours to write.

The core is open source, under a licence that keeps everything built on it
open. The format libraries are MIT-licensed, so they go anywhere, including
into the tools of people who will never use Ekwo. What we sell — the hosted
edition, operated for you, with the connections a small business cannot obtain
alone and the agents you configure, acting on your instructions — pays for the
rest, and everything else stays free.

## 5. A network of people who know the rules.

Together, a network knows the accounting rules of the world. Ekwo is built by:

- **accountants** who review the pack for their country and put their name on
  it, so that others can trust it;
- **developers** who write a format library, a bank parser, a connector, or the
  module their clients need;
- **translators** who make a chart of accounts readable in their language;
- **the businesses that run it**, whose questions and bug reports are the
  roadmap.

A pack is *reviewed* when a named professional has read it. A module lives in
its own schema, so the people who need it build it on their own. The roadmap
is public. The decisions are written down, with their reasons, in this
repository — including the ones we got wrong and took back.

Bring your expertise. If you keep accounts, write software, or know your
country's rules, this is the place to put that knowledge where it stays open
for good. Start with [CONTRIBUTING.md](CONTRIBUTING.md), or open an issue and
say where you are from.

---

*Ekwo is maintained by Ekwo (EKWO OÜ). The name is the promise: the world
model of your company, open, owned by the business, operated by a machine and
checked by a human — and leaving a lighter footprint, on the accounts and, in
time, on the world.*
