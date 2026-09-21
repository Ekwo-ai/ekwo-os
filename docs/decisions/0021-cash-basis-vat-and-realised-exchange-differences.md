# Cash-basis VAT waits; exchange differences are realised

> Status: accepted

## Context

Two rules a country decides meet at the moment a document is settled. French
VAT on services falls due when the price is collected (CGI art. 269-2-c);
goods on delivery. A pack offering one sale tax per rate gives every service
business the goods answer, declaring VAT early every month. Separately, a
document in a foreign currency must be booked in the company's currency, or no
exchange difference can ever exist.

## Decision

### Cash basis

**A tax that waits is booked on a transition account and on no box.**
`post_document` puts a cash-basis tax on the transition account the pack names
and writes no box. Matching moves the settled share to the final account and
box, dated on the day the settlement completes, as an entry of its own.
`vat_return()` needs no change: it sums lines that name a box.

**The base travels with its tax.** A cash-basis return reports the base
*collected*, so the base line of such a document also waits and the transfer
carries it as a line with a box, an amount to report, and no debit or credit.
Revenue is still earned when invoiced; only the declaration waits. Cash
accounting as a ledger is out of scope; a cash-basis report is derived from
matched payments.

**The share is cumulative and the last payment carries the remainder.**
`settle_cash_basis_tax()` computes what should have been transferred at the
current settlement ratio, subtracts what earlier matchings sent, and books the
difference. A tax of 200,00 settled in three thirds comes to 66,67, 66,66,
66,67. Undoing a matching is the same call with a negative difference.

**One tax posting per document kind for a cash-basis tax.** A self-assessed
tax has no cash to wait for; `post_document` and `ekwo pack check` refuse the
combination, a cash-basis tax without a transition account, and one with a
non-deductible share.

**The option for the debits is the tax that already exists.** The French pack
adds `…-ENC` taxes for services sold and bought (deduction arises at the
supplier's due date, CGI art. 271-I-2) on 4458-family accounts; a company that
opted for the debits keeps the ordinary tax. No general cash-basis option is
invented for a country whose law has none.

### Currency

**The ledger is in the company's currency, with the document's beside it.**
`post_document` and `post_payment` book `debit`/`credit` in the company's
currency and `amount_currency` in the document's, at `documents.exchange_rate`
or `payments.exchange_rate` (units of foreign currency per unit of the
company's). There is no rate feed; the rate is an input.

**Every amount is worked out in the document's currency and divided once.** At
a rate of 1 the division is the identity, and every existing figure is
unchanged.

**A matching between two lines in the same foreign currency is worked out in
that currency**, each side converted back at its own rate; the difference is
realised on the country model's `fx_gain_code` / `fx_loss_code`, against the
third-party account, so a customer who paid in full owes nothing. A missing
role is refused the day a difference arises, not before.

**Transfers and differences go on the miscellaneous journal**, not the bank
(neither is a movement of money), dated when the settlement completes;
`post_entry` asserts the period and the tax lock are open.

**What a matching caused is part of what it returns.** `reconciliations` gains
`fx_entry_id` and `tax_transfer_entry_id`; `unreconcile` uses them to post the
mirror.

## Consequences

- Out of scope: revaluation of open items at a closing date (unrealised
  differences), and multi-currency periodic revaluation.

## See also

- `tests/cash_basis_fx.test.ts`
- [0033 What a country requires on a document is data](0033-what-a-country-requires-on-a-document-is-data.md) (tax point)
