# A late payment mention is the company's choice, on an invoice to a business

> Status: accepted

## Context

A pack declares its `late_payment` mention as data: the sentence that tells
a customer the interest and the recovery costs the law gives a seller paid
late. `document_legal_mentions` printed it on every sale invoice and every
sale credit note of the country, and no company could leave it out. Between
two businesses the rules on late payment in commercial transactions apply
whether the invoice states them or not: the sentence recalls a right, it
does not create one. It says nothing on a credit note, which gives money
back, and the right it recalls is not a consumer's.

## Decision

**A company setting, on by default.** `companies.invoice_late_payment_mention`,
a boolean, true unless the company says false. It is read by the view, so
every renderer of the documents — the PDF, a shared link, an e-invoice that
carries the notes — follows it with no code of its own. It holds for every
pack that declares a `late_payment` mention; the sentence, its law and its
wording stay the pack's.

**Where the right is.** The view selects the mention on a `sale_invoice`
only, never a `sale_credit_note`, and only when the document's contact is a
business, `contacts.is_company`. A sale invoice that names no contact yet
prints nothing about late payment, because nothing says who the buyer is.

**Read at rendering.** As the colour and the typeface of the company, the
setting is read when a document is rendered: switching it off shows on the
next PDF of every invoice.

## Consequences

- Every company that exists keeps the sentence on its invoices to a business
  and loses it on its credit notes and its invoices to a consumer.
- A country whose law asks a sentence of every invoice, consumer or not,
  declares it under `always`, which this setting does not touch.
- The MCP tool `update_company_profile` sets it; a screen that shows the
  appearance of the invoice offers it beside the colour and the typeface.

## See also

- `supabase/migrations/20261021080000_a_late_payment_mention_is_the_companys_choice.sql`
- `tests/document_rules.test.ts`
