# Why we are building Ekwo

Every business on earth keeps books. The books say whether it is alive,
whether it can pay its people next month, whether it can afford to try
something. For most small businesses, that knowledge lives in software they
rent, behind a price list they do not control, in a format they cannot take
with them. Leaving means starting again.

We think that is backwards. **The ledger belongs to the business.** The rules
that fill it — a chart of accounts, a VAT return, a year-end — belong to
everyone who has to follow them.

And two things are changing at once. The work of keeping books, which used to
need a person at a keyboard, is being done by machines — which is either the
moment a business finally understands its own numbers, or the moment it hands
them to someone else's model and stops looking. And *what* has to be booked is
changing too: invoices that travel as structured data between administrations
rather than as paper, assets that exist only on a chain, payments that settle
in seconds, a tonne of carbon that will have to be accounted for as strictly as
a euro. An accounting system built on the assumption of one country, one
currency, one kind of asset and one person typing is not going to survive that.

So Ekwo is five commitments.

## 1. Financial autonomy for every business

A company should be able to keep its own books, understand them, and act on
them, with software it owns and an assistant it controls. Not a subscription
that reads its data; a ledger in a database it holds the keys to, with an open
API and an AI that works *for* it. Every installation stands on its own, with
us or without us, for as long as its owner wants it to. That is the test every
feature passes before it lands, and it is the whole point.

Autonomy is also knowledge. A trial balance that balances, a VAT return
computed from the ledger rather than typed in, a year-end close that a small
business can run itself: these are not features, they are the difference
between a business that knows where it stands and one that hopes.

## 2. An AI at the keyboard — and arithmetic that never depends on it

Ekwo is designed to be operated by a machine. The data sits in Postgres, the
REST API and its OpenAPI description come with it, and an MCP server sits on
top: any AI assistant can read the ledger, raise an invoice, post it, match a
payment, pull the VAT return — as *you*, under your own row level security,
without the data leaving your account. The agent is a user of the books, with
the same rights and the same limits as the human beside it, and it can be
replaced by another one tomorrow.

The other half of that sentence matters more. **Nothing in the core calls a
model.** A posting, a tax, a declaration box, a reconciliation rule is
deterministic, reproducible and reviewable: the same inputs give the same
figure, on your machine and on an auditor's, this year and in seven years when
someone asks why. A model that guesses at a number nobody can reproduce is not
an accounting system, whatever it costs. So the intelligence goes where it
belongs — reading a document, proposing a match, explaining a variance,
drafting the answer to the administration — and the arithmetic stays in code
anybody can read. The machine proposes; the rules decide; a human can always
ask why, and get an article of law rather than a probability.

## 3. A ledger for the finance that is coming

The next ten years of finance are already written into other people's
regulations: structured electronic invoicing becoming the norm and then the law
across the Union, filings that are read by machines before they are read by
people, instant settlement, crypto-assets that a business holds and now has to
report on — MiCA, and the reporting obligations that start to bite in 2026 —
and, close behind, the emissions that will sit in a report next to the
revenue.

An accounting core either has room for that in its shape, or it does not. Ours
is built for it: amounts carry their currency and their rounding rather than
assuming cents; formats live in independent libraries, organised by format and
never by country, so a new one is a package and not a fork; and anything that
is not double-entry bookkeeping — fixed assets, budgets, and next carbon,
stocks, crypto-assets — lives in its own Postgres schema, with its own
migrations and its own tests, reaching the ledger through one function and
never writing an entry behind its back.

Crypto is the honest example of what this buys. A token is not a currency and
not a stock: it needs its own inventory, its own cost basis, its own
revaluation, and a reporting obligation nobody had two years ago. That is a
module, written against a schema that was made ready for it — not a rewrite of
the general ledger. The carbon module is the same bet from the
other end: a tonne of CO₂ posted against the transaction that caused it, in the
same books, with the same audit trail. Nobody does that inside open source
accounting today. It is where the name points.

## 4. Accounting as a commons

Accounting is not a product. It is a set of rules that a society agreed on so
that businesses could trust each other: the same chart of accounts, the same
declaration, the same year-end, for everyone in a country. Those rules should
not be locked inside proprietary software, one vendor per market.

In Ekwo a country is **data**: a pack of files an accountant can read, a
contributor can propose, and a test can prove. Belgium, France, Luxembourg,
Estonia, the United Kingdom and the United States ship today — the last of them
a country with no value added tax at all, which is how you find out what a
format quietly assumed. Ireland, Canada and Québec, the Netherlands and Germany
come next. Then anyone's country, added by the people who know it best.

The core is free software under the AGPL, so that what is built on it stays
open. The format libraries are MIT, so that they can go anywhere, including
into the tools of people who will never use Ekwo. What we sell — a managed
edition, the connections a small business cannot obtain alone, the agents we
operate — pays for the rest, and never gates it.

## 5. A network, not a vendor

No company can know the accounting rules of the world. A network can. Ekwo is
built by:

- **accountants** who review the pack for their country and put their name on
  it, so that others can trust it;
- **developers** who write a format library, a bank parser, a connector, or the
  module their clients need;
- **translators** who make a chart of accounts readable in their language;
- **the businesses that run it**, whose questions and bug reports are the
  roadmap.

A pack is *reviewed* when a named professional has read it, not when we say so.
A module lives in its own schema so that the people who need it can build it
without asking us. The roadmap is public. The decisions are written down, with
their reasons, in this repository — including the ones we got wrong and had to
take back.

If you keep books, if you write software, if you know your country's rules and
are tired of seeing them re-implemented badly behind a paywall: this is the
place to put that knowledge where it cannot be taken away. Start with
[CONTRIBUTING.md](CONTRIBUTING.md), or open an issue and say where you are
from.

---

*Ekwo is maintained by Ekwo, a company founded in Belgium in 2026. The name is
the promise: an accounting core that is open, that the business owns, that a
machine can keep and a human can still check — and that leaves a lighter
footprint, on the books and, in time, on the world.*
