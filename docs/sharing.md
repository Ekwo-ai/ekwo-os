# Sharing a document

You send an invoice and give your customer a link to it. They open it and see
what it says, what is still owed on it, and the legal mentions at its foot.
Your data stays behind row level security, and your customer reads that one
document without becoming a member of your company.

A **share** is a row that says *this document may be read by whoever presents
this secret*, and one function that takes the secret and returns the document.
The token in the link is the whole secret: your customer opens it with one
click, with no account, password or second factor.

The core provides the data and the three functions. The page the customer looks
at is the application's, and it lives outside this repository.

**A share gives one document, and only that.** The customer who opens a link
holds nothing in the installation. The person whose company it is — the client
of the firm that keeps the books here — gets a seat instead: a member of that
one company on the `client` preset, who reads everything of it, hands pieces
over with `documents.deposit`, and writes nothing else. `documents.share` is
left out of that preset: publishing a company's invoice stays with whoever
issues it.

## The three functions

| Function | Who may call it | What it does |
|---|---|---|
| `share_document(document_id, expires_at)` | a member holding `documents.share` | creates a link and returns the token **once** |
| `revoke_share(share_id)` | a member holding `documents.share` | stops the link working, for good |
| `shared_document(token)` | **`anon`** and `authenticated` | returns one document as jsonb, or null |

`document_shares` is the table under them. Members of the company read it —
`documents.read`, which every preset holds — and nobody writes it through the
API: the two functions above are the only way in. Listing the links of a
company is a plain `select` on it.

## Creating a link

```sql
select * from share_document('…document id…');
-- share_id | token                                       | url
-- 3f2a…    | kZ3m…_Q                                     | https://books.example/shared/kZ3m…_Q
```

The token is 32 bytes rendered base64url, 43 characters. It is returned by this
call and by nothing else, ever: the table holds a sha256 of it and no column
anywhere holds the token itself. A lost link is withdrawn and made again.

`url` is `instance.public_base_url` plus **`/shared/<token>`**. That path is the
contract between the core and whatever serves the page: an operator putting a
reverse proxy in front of their installation has to route it to the
application. `instance.public_base_url` is nullable and has no default — a
self-hosted installation answers at the address its operator chose, and a core
that guessed would hand out links to somebody else's host. Where it is empty,
`share_document` returns the token with a null `url` and the caller builds the
link itself.

`expires_at` is optional. Null means the link answers until it is withdrawn,
which is the ordinary case: an invoice is looked at years later.

**A share is never edited.** There is no update policy and no `change_share()`.
You can rely on the expiry you set, and a revoked link stops working for good.
To change anything about a link, revoke it and make another.

## What may be shared

Sales documents only — an invoice, a credit note, a quote — that are not
cancelled and carry a number. Each refusal is named:

| Refusal | When |
|---|---|
| `share_not_a_sale` | a purchase document: somebody else's own document, their prices, their bank details, their mentions |
| `share_cancelled_document` | the document was cancelled |
| `share_draft_document` | an invoice or a credit note that has not been posted |
| `share_unnumbered_document` | anything else without a number |
| `share_expires_in_the_past` | an expiry that is already behind us |

The same four rules are re-read by `shared_document` on every visit, so
cancelling an invoice closes every link onto it without anybody having to
remember to revoke them.

## Reading a link

```sql
select shared_document('kZ3m…_Q');
```

It takes the token and nothing else, so a link opens exactly one document. It
answers with one jsonb object:

```jsonc
{
  "document":  { "type", "number", "document_date", "due_date", "delivery_date",
                 "currency", "language", "payment_terms", "payment_reference",
                 "buyer_reference", "order_reference", "note" },
  "seller":    { "name", "legal_name", "legal_form", "vat_number",
                 "registration_number", "address_line1", "address_line2",
                 "postal_code", "city", "country", "email", "phone", "website",
                 "logo_url", "iban", "bic" },
  "buyer":     { "name", "vat_number", "registration_number", "address_line1",
                 "address_line2", "postal_code", "city", "country" },
  "lines":     [ { "sequence", "type", "name", "description", "quantity",
                   "unit_code", "unit_price", "unit_price_includes_tax",
                   "discount_percent", "amount_untaxed", "amount_incl_tax",
                   "tax_category", "tax_rate", "tax_exemption_code" } ],
  "tax_summary": [ { "name", "category", "rate", "base_amount", "tax_amount" } ],
  "totals":    { "amount_untaxed", "amount_tax", "amount_total" },
  "payment":   { "state", "amount_paid", "amount_residual", "last_payment_date" },
  "legal_mentions": [ { "code", "text" } ]
}
```

Five things about that shape are deliberate.

**Every amount is a decimal string**, so the total your customer sees is
exact. A JSON number is a double by the time it reaches a browser, and would
arrive as `1210.0000000000002`.

**No identifier of anything is in it** — of the document, the company, the
contact, a tax or an account. A link is one document, and what it carries
leads to that document alone.

**`payment` is the one thing that moves after the document was sent**, which is
what makes a link worth keeping: a customer who paid last week opens the same
link and sees that it is settled. `tax_amount` in the breakdown is what the
other party actually pays — zero where the tax self-assesses — so the breakdown
adds up to `totals.amount_tax`.

**A line says which price it is showing.** `unit_price` is the price as it was
keyed — gross on a line whose tax is included in the price, net otherwise —
and `unit_price_includes_tax` says which. `amount_incl_tax` is the gross the
line was quoted at, `null` everywhere else, so a renderer reads each figure
as it stands.

**The legal mentions come out in the document's own language**, frozen when
the document was posted. They are the sentences `document_legal_mentions`
produces for a printed invoice, so a link and a PDF always agree.

## The same answer for every kind of no

Unknown token, withdrawn link, expired link, a document that may no longer be
shared: all four return **null**, the same null in the same shape. Somebody
guessing tokens learns nothing about which of them was ever a real link.

## What is counted, and what is not

`document_shares.view_count` and `last_viewed_at` tell you that the link was
opened, which is the question a sender asks. The core keeps no IP address and
no user agent: who opened a link and from where is a log of the people a
company invoices, which is personal data with a retention policy, a lawful
basis and a subject-access request behind it. An application that is prepared
to answer for such a log keeps its own.

## Through the MCP server

`share_document`, `revoke_share` and `list_shares` are tools, with the same
contract and the same refusals.

`shared_document` is **not** a tool, by decision: it is the public door, for
the customer. Your agents read documents with your rights only, so a token
somebody hands an agent opens nothing through the MCP server.

## Why there is no access code

The token is the secret, so your customer opens an invoice in one click. A
second factor — a code read out over the phone, a one-time password by e-mail —
would turn every link into a conversation, and most invoices are sent to
somebody who is expected to open them. It can be added to a share as an option
the sender chooses, without changing the shape above.
