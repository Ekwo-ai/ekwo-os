# Data Processing Agreement — Ekwo Cloud

*Draft for legal review — not in force. Version 1.0 — <date>.*

This agreement governs what Ekwo does with the personal data contained in
your books when you link an instance to Ekwo Cloud. It is part of what you
accept on the screen that links an instance, and it applies for as long as at
least one of your instances is linked. It does not apply to Ekwo OS used
without an account: in that case Ekwo receives nothing, as `PRIVACY.md` §1
explains.

## 1. The parties and their roles

- **You**, the person or organisation that links an instance to Ekwo Cloud,
  are the **controller** of the personal data in your books.
- **Ekwo (Karuna Co OÜ)**, a private limited company registered in Estonia
  under registry code 14510673, is your **processor** for that data, within
  the meaning of Article 28 of Regulation (EU) 2016/679 (GDPR).

What Ekwo holds about *you* as a user of the service — your email address,
your answers, what the service records about your instance — is not covered
here: Ekwo is the controller of that data, as `PRIVACY.md` describes.

## 2. What Ekwo does with your data, and nothing else

Ekwo processes the personal data in your books only to provide the service you
asked for on the linking screen, and only on your documented instructions.
Those instructions are the choices on that screen and in the settings of the
instance, as recorded by the service:

1. **Updates** — applying new versions of Ekwo to the database of the linked
   project, which involves executing statements on that database with the
   authorisation your Supabase organisation gave, limited to that project.
2. **Copies** — exporting the companies of the linked instance, keeping the
   export, and restoring it into an installation when you ask.
3. **Access you grant to agents** — acting as you through `mcp.ekwo.ai`, with
   the rights your instance gives you, after you approved it in your browser.

Annex 1 describes the processing in detail.

**Ekwo does not process that data for any purpose of its own** — not for
statistics, not for product research, not to train a model, not for
marketing, and not in pseudonymised or anonymised form. Figures about how Ekwo
is used, if you choose to send them, are computed by your own instance and
contain no personal data from your books; they are described separately and
are not processing under this agreement.

If Ekwo considers that one of your instructions infringes the GDPR or another
provision of Union or Member State law, it tells you immediately.

## 3. Confidentiality

Ekwo ensures that anyone authorised to operate the service is bound by
confidentiality and has access to your data only as far as operating the
service requires. The service is built so that no part of it opens the content
of a copy to look inside; an export is read only to restore it.

## 4. Security

Ekwo implements the technical and organisational measures listed in Annex 2,
appropriate to the risk of processing accounting records, in accordance with
Article 32 GDPR. Ekwo may improve those measures over time, but never lower the
overall level of protection they give.

## 5. Sub-processors

You give Ekwo a general authorisation to use the sub-processors listed in
Annex 3. Ekwo:

- binds each of them by a written contract imposing obligations equivalent to
  those of this agreement;
- informs you of any intended addition or replacement at least **thirty days**
  in advance, by email and on the page listing them, so you can object;
- if you object on reasonable grounds and no solution is found, lets you unlink
  the instance, which ends the processing and deletes the copies.

Ekwo remains responsible to you for the performance of its sub-processors.

## 6. Transfers outside the European Economic Area

The copies of your books are stored in the European Union. Where a
sub-processor may access personal data from outside the European Economic
Area, the transfer relies on an adequacy decision of the European Commission
or on the standard contractual clauses adopted by it, as stated for each
sub-processor in Annex 3.

## 7. Helping you meet your obligations

Taking into account the nature of the processing, Ekwo helps you:

- **answer requests from the people in your books** (access, correction,
  erasure, restriction, portability, objection). Your books remain on your
  own database, where you can act on them directly; Ekwo forwards to you
  without delay any request it receives and does not answer it itself;
- **with security, breach notification, impact assessments and prior
  consultation** (Articles 32 to 36 GDPR), by providing the information it
  holds about the processing.

## 8. Personal data breaches

Ekwo notifies you **without undue delay, and within 48 hours at the latest**,
after becoming aware of a personal data breach affecting data processed under
this agreement. The notification describes what is known at the time — the
nature of the breach, the categories and approximate number of data subjects
and records, its likely consequences and the measures taken or proposed — and
is completed as more becomes known.

## 9. End of the processing

When you unlink an instance, or when your account is closed, Ekwo:

- stops updates and copies for that instance at once;
- **deletes every copy of its books within thirty days**, unless you asked
  beforehand for a last copy to be handed to you;
- deletes the authorisation of your Supabase organisation when no linked
  instance needs it any more.

Keeping your books for the period the law of your country requires is done on
your own database; Ekwo is not a depository of your accounting records.

## 10. Information and audits

Ekwo makes available to you the information necessary to demonstrate
compliance with Article 28 GDPR, and allows for and contributes to audits,
including inspections, conducted by you or an auditor you mandate, on
reasonable notice and no more than once a year unless a breach or a supervisory
authority requires otherwise. The source code of the software that performs
updates and copies is public, in the Ekwo repositories, and can be read at any
time.

## 11. Order of precedence and changes

In case of conflict between this agreement and any other terms of Ekwo Cloud,
this agreement prevails as regards the protection of personal data. Changes to
this agreement are published in the public repository with a new version and
date, and announced to you at least thirty days before they apply, unless the
law requires otherwise.

## 12. Law and jurisdiction

This agreement is governed by the law of Estonia. It does not limit any right
that the people in your books, or you, hold under the GDPR, including the right
to lodge a complaint with a supervisory authority.

---

## Annex 1 — Description of the processing

| | |
|---|---|
| **Subject matter** | Operating the instances you linked to Ekwo Cloud: updates, copies, agent access |
| **Duration** | For as long as the instance is linked, then thirty days for deletion (§9) |
| **Nature** | Executing schema updates on the linked database; exporting, storing, restoring and deleting copies; acting as you on your instance for agents you approved |
| **Purpose** | Providing the service you chose on the linking screen, and nothing else (§2) |
| **Categories of data subjects** | People and organisations that appear in your books: customers, suppliers, staff and directors, and other counterparties |
| **Categories of personal data** | What your books contain: names, postal and email addresses, company and tax identifiers, bank account identifiers, amounts invoiced, paid and received, remuneration where payroll entries are kept, and the free text of descriptions |
| **Special categories** | Not sought. Free-text descriptions may incidentally reveal them (for example a payment to a health professional); they are handled with the same measures and never read |
| **Retention of copies** | Free plan: twelve monthly copies. Paid plan: thirty daily and twelve monthly copies. Plus a copy before each update. All deleted when the instance is unlinked |

## Annex 2 — Technical and organisational measures

- **Scope of access.** The authorisation of your Supabase organisation is used
  only on the linked project, whose reference is checked before every
  management call. The key your instance issued Ekwo carries only the
  capabilities a copy requires, and stops working when you, or the person who
  issued it, lose them.
- **Encryption.** Authorisations and keys are stored encrypted, never in plain
  text. Copies travel over TLS and are stored with their checksum.
- **No inspection of content.** No part of the service opens a copy except to
  restore it; the MCP server logs that a call happened and which tool was
  called, never the content of your books.
- **Integrity of updates.** Every update is first run and rolled back, then
  run again with the trial balance checked to the cent inside the same
  transaction, and committed only if nothing moved. A copy is taken before.
- **Tested restores.** Restoring a copy into an installation that never saw the
  company is exercised against a real project before every release, and the
  trial balance compared to the cent.
- **Least privilege and confidentiality** of the people who operate the
  service (§3).
- **Supervision.** Failed updates and failed copies raise an alert to the
  operators and are shown on the instance.

## Annex 3 — Sub-processors

| Sub-processor | What it does for the service | Location of the data | Transfer basis |
|---|---|---|---|
| Supabase, Inc. | Hosts the control plane database and the storage where copies are kept | European Union (Frankfurt, eu-central-1) | Data stored in the EU; standard contractual clauses for any access from outside the EEA <to confirm against Supabase's DPA> |
| Netlify, Inc. | Serves the application and runs the functions that perform updates and copies: the content of your books passes through these functions in transit, and is not stored there | <to confirm: region of the functions — by default outside the EU> | EU–US Data Privacy Framework and/or standard contractual clauses <to confirm against Netlify's DPA> |
| Mailjet SAS | Sends the sign-in codes — receives your email address only, no data from your books | European Union | Not applicable <to confirm> |
