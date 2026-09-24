# What Ekwo is, and what it is not

Ekwo OS is open source data infrastructure: a database schema, rules written
as data, format libraries and tools, for businesses and for the accountants
who work with them. It is software. It is not an accounting firm, not a tax
adviser and not a financial, legal or investment adviser, and installing it,
using it or reading this site does not make Ekwo, or anyone who contributed to
it, your accountant or your adviser.

*Version 2.0 — 21 September 2026. This page applies to Ekwo OS, the software
of this repository, and to the site at ekwo.ai. The managed edition is
governed by its own terms.*

## 1. What the project is

Ekwo OS gives a business a place to hold its accounting and tax data — a
PostgreSQL schema it installs on a database it controls — together with:

- **schemas** for ledgers, documents, taxes, declarations and financial
  statements;
- **country packs**: a reading of a country's charts of accounts, taxes,
  declaration boxes and statements, written as files with their sources;
- **format libraries** that write and read published file formats;
- **tools** — a command line, a TypeScript client and an MCP server — through
  which a person, a script or an AI agent works on that data.

Ekwo's mission is to provide that infrastructure, openly, in every country. It
is not to replace the accountant. The tools are built to be used by
businesses **and by their accountants**, and to be read and checked by them.

## 2. What Ekwo does not provide

Ekwo and its contributors do not provide, through the software, the
documentation, the country pages or any exchange on an issue, a forum or a
chat:

- accounting, bookkeeping or statutory audit services;
- tax advice, tax preparation or tax representation;
- financial, investment, legal or regulatory advice;
- any certification, attestation or opinion on anyone's accounts or returns.

Nothing on this site or in this repository is a recommendation for a
particular situation. No professional relationship, engagement or duty of
care arises from using the software, reading its documentation or
contributing to it.

## 3. Your books, your filings, your deadlines

You — the business, or the professional you engage — remain solely
responsible for:

- the accuracy and completeness of your books and of the entries they hold;
- every return, declaration, filing, payment and deposit, its content and its
  date, in every country where you have an obligation;
- the choice of chart of accounts, tax treatments, rates, regimes and
  elections that apply to you;
- checking what the software computes before you rely on it.

Ekwo does not keep your books, does not file anything with any authority on
its own initiative, and does not monitor your deadlines on your behalf. Ekwo
transmits no return to any tax administration. A
figure the software computes — a VAT box, a balance sheet line, a tax
estimate, a due date — is only as right as the entries behind it and the
rules it was given. A deadline the software shows is an aid, not a notice; it
does not replace the calendar of the administration concerned.

## 4. Country packs, and what their status means

A country pack is a reading of a country's rules at the date of its version.
Rules change, and a pack can be wrong, incomplete, out of date or not
applicable to your situation. Every rule cites its legal source, with the day
it was read where the pack records one, so that you, or your accountant, can
check it. The golden test of a pack proves that it is consistent with itself,
not that it is consistent with the law.

- **community**: contributed by someone; nobody has reviewed it. It has not
  been read by an accounting or tax professional.
- **maintained**: written by Ekwo, which updates it when it can; no update is
  promised; not reviewed by an accounting or tax professional.
- **reviewed**: read by a named professional, on the date shown, against the
  rules they apply in practice.

A review is a good-faith reading given to the community for free. It is not
an engagement letter, an audit, an opinion or a guarantee. Neither the
reviewer nor Ekwo assumes liability for what you file on the strength of it.
If you need someone to answer for your filings, engage them.

## 5. Estimates, and what an AI proposes

Some functions produce estimates by design — a tax estimate during the year,
a cash-basis view, a carbon footprint. They say so. An estimate is not a
declaration.

An AI agent connected through the MCP server acts with your rights and on
your instruction. What it reads from a document, proposes or drafts is the
output of a model you chose, which Ekwo neither supplies nor controls. Check it
before it is posted or filed.

## 6. Software you can change

Ekwo OS is free software. You may modify the schema, the rules, the packs and
the tools, and you may install versions, forks or modules that Ekwo has never
seen. Ekwo cannot know how the software is configured, extended or used in any
installation, and is not responsible for the result of a modification, a
configuration, a third-party module or a pack that did not come from this
repository.

A self-hosted installation runs on infrastructure that you choose and control.
Ekwo has no access to it and does not see, receive or process the data in it.

## 7. No warranty, no liability

The core of Ekwo OS is licensed under the GNU Affero General Public License,
version 3 (AGPL-3.0). As its sections 15 and 16 state, the program is provided
"as is", without warranty of any kind, express or implied, including the
implied warranties of merchantability and fitness for a particular purpose;
the entire risk as to its quality and performance is with you; and in no event,
unless required by applicable law or agreed to in writing, will any copyright
holder, or any other party who modifies or conveys it, be liable to you for
damages, including any general, special, incidental or consequential damages —
among them loss of data, data rendered inaccurate, and losses sustained by you
or by third parties. Section 17 asks a court to apply the local law that most
closely approximates an absolute waiver of liability.

The format libraries in `packages/formats/` are licensed under the MIT
licence, which provides them "as is", without warranty of any kind, and
excludes any liability of the authors or copyright holders for any claim,
damages or other liability arising from the software or its use.

The same applies to the documentation, the country pages and everything else
published on this site. Where the law of your country does not allow a
limitation or exclusion of liability — for example for fraud, for gross
negligence or towards a consumer — that limitation or exclusion applies to
the fullest extent that law permits, and the rest of this page still applies.
Nothing here limits liability for death or personal injury caused by
negligence, for fraud, or any liability that cannot lawfully be limited, nor
your statutory rights as a consumer.

## 8. Consult a professional in your country

Accounting, tax and audit are regulated activities in many countries, and the
titles that go with them are protected. Before relying on the software for a
filing, an election or a decision, consult a professional who is authorised to
advise you in the country concerned.

### European Union

In several Member States, keeping or certifying the accounts of others, or
giving tax advice, is reserved to members of a regulated profession — for
example the *expert-comptable* registered with the Ordre des
experts-comptables in France, the accountants and tax advisers of the
Institute for Tax Advisors and Accountants (ITAA) in Belgium, or the
*Steuerberater* in Germany. Ekwo is none of them and does not act as one.
Nothing Ekwo publishes is a certification of software under any national
scheme, unless the scheme's own register says so; in particular, Ekwo OS is
not, by itself, an accredited e-invoicing platform or a Peppol access point.

Under the General Data Protection Regulation (Regulation (EU) 2016/679), a
business that installs Ekwo OS and keeps personal data in it — its customers,
suppliers, employees — is the controller of that data. A self-hosted
installation is not accessed by Ekwo, and Ekwo is neither its controller nor
its processor. Keeping records, retention periods and the rights of the people
concerned are the business's to organise.

### United Kingdom

Statutory audit, reserved legal activities and certain protected titles are
regulated. Tax agents are expected to follow HMRC's standard for agents. Ekwo
does not act as your agent with HMRC and is not recognised software for Making
Tax Digital unless HMRC's own list says so. Engage a qualified accountant or
tax adviser for advice on your situation.

### United States

Certified Public Accountants are licensed by state boards, enrolled agents
are authorised by the IRS, and paid tax return preparers are subject to IRS
rules. Ekwo is none of these, prepares no return for anyone and represents no
one before any tax authority. Nothing Ekwo publishes is tax advice or written
advice within the meaning of Treasury Department Circular 230 (31 CFR Part 10),
and it cannot be used to avoid penalties. Sales and use tax obligations,
including whether a business has nexus in a state, depend on facts the
software does not know; check them with a professional.

### OHADA member States

The packs written on the SYSCOHADA chart follow the Uniform Act on accounting
law and financial reporting as Ekwo read it. In each member State, the
national order of chartered accountants regulates the profession, and the
annual financial statements and the statistical and tax return may have to
carry the stamp of one of its members. Ekwo is not a member of any order and
cannot give that stamp.

### Every other country

The same applies wherever you are: the law of your country decides who may
keep accounts for others, give tax advice or sign a return, and what software
must do. When in doubt, ask a professional who is authorised there.

## 9. Names and trademarks

Names and logos cited on this site and in this repository — among them AI
models and their publishers, Peppol, PostgreSQL, Supabase, GitHub and the
administrations, standards and file formats a pack refers to — belong to their
respective owners. Ekwo is not affiliated with, endorsed by or certified by
any of them. Compatibility is through open protocols and published standards.

## 10. If something here is wrong

If a pack is wrong for your country, open an issue and cite the rule. That is
how a pack gets better. This page may be updated; the version and the date at
the top say which one you are reading, and the history of the repository keeps
every earlier one.

## Legal and contact

Ekwo is a trade name of Karuna Co OÜ, Estonia, registry code 14510673 ·
contact through an Ekwo Cloud account, at https://cloud.ekwo.ai/account
