# A tax collected for the next links of the chain, on a presumed base

> Status: proposed

## Context

Under tax substitution "forward" (*substituição tributária para frente*), the
seller of certain goods collects, besides the tax on its own sale, the tax the
next links of the chain will owe when the goods are sold on to the consumer.
It cannot know the price of those later sales, so the law presumes it: the
base is the value of the seller's own operation, plus the charges the buyer
pays, raised by a margin of value added. The seller pays both taxes to the
administration; the buyer pays the second one to the seller on top of the
invoice, and owes nothing more when it resells.

The Brazilian ICMS-ST is the case this record is written for:

- the Lei Complementar n.º 87/1996, art. 6, lets the law of a state make a
  taxpayer liable for the tax of subsequent operations, and art. 8, II, sets
  the base: the value of the operation itself, insurance, freight and other
  charges paid by the buyer, and the margin of value added, profit included,
  of the subsequent operations; art. 8, § 4º, says the margin is set from the
  prices usually charged on the market, by survey, and § 6º allows a weighted
  average final consumer price instead
  ([planalto.gov.br](https://www.planalto.gov.br/ccivil_03/leis/lcp/lcp87.htm));
- the Convênio ICMS 142/2018 of CONFAZ sets the general rules of the regime
  between the states, the goods it may cover (its annexes, by CEST and NCM)
  and how a destination state fixes the margin, its cláusula vigésima
  terceira
  ([confaz.fazenda.gov.br](https://www.confaz.fazenda.gov.br/legislacao/convenios/2018/CV142_18));
- between two states the margin is adjusted so that the difference between
  the interstate rate and the internal rate of the destination is not taxed
  twice: MVA ajustada = [(1 + MVA original) × (1 − interstate rate) /
  (1 − internal rate)] − 1, as the protocols between states write it, for
  instance Protocolo ICMS 02/24
  ([confaz.fazenda.gov.br](https://confaz.fazenda.gov.br/legislacao/protocolos/2024/protocolo-icms-02-24)).

The arithmetic, on an invented sale between two states — goods at a price
of 1 000.00 that holds the seller's own tax at the interstate rate of 12 %,
computed inside its base (decision 0077) and so 120.00; a margin of 40 %; an
internal rate of 18 % at destination:

| | |
|---|---|
| margin adjusted | (1.40 × 0.88 / 0.82) − 1 = 50.2439 % |
| presumed base | 1 000.00 × 1.502439 = 1 502.44 |
| tax of the chain | 1 502.44 × 18 % = 270.44 |
| less the seller's own tax | 270.44 − 120.00 = **150.44** |
| invoice total | 1 000.00 + 150.44 = 1 150.44 |

What the core has today does not reach it. A line carries one tax, and the
reserved `group` of a pack is refused, so the tax of the chain cannot read the
own tax of the same line to deduct it. A tax computes on the line's amount,
never on a presumed one. Nothing keeps a margin. The pieces it does have are
the ones this design is made of: a tax's postings, its boxes and their factors
(decision 0019), a share booked as a cost on the accounts of the lines
(`tax_on_base`), a tax computed inside its own base (decision 0077), the
territories of the parties (decision 0024), and the classification of a line
by the scheme its country declares (decision 0078).

## Decision

The design below is proposed, and waits for one prerequisite: **several taxes
on one line**, the reserved `group`, ordered, so that one member may read
another. Nothing of it is built until that exists.

**1. The margin is pack data, keyed by what is sold and where.** A pack carries
`presumed_margins.json`: one row per margin, naming the tax it serves, the
classification scheme and the code prefix it applies to (a CEST, an NCM
heading — decision 0078), the territory of the buyer it applies in
(`applies_when.buyer_in`, decision 0024), the margin in percent, its validity
(`valid_from`, `valid_to`) and its article and source, like every rate. It
compiles into a reference table; the longest prefix that matches the line's
code wins, and a line with no matching row is refused by name
(`no_presumed_margin`) rather than taxed on a guess. A weighted average final
consumer price, where a state sets one instead of a margin, is the same row
with a price per unit in place of the percentage.

**2. The tax of the chain is a member of the group, with two closed keys.**

- `presumed_base: true` — its base is the line's operation value plus the
  charges the line carries, times one plus the margin found in step 1;
- `deducts: "<code>"` — the member of the same group whose tax it deducts,
  the seller's own; and `margin_adjusted: true` where the margin is raised
  between two states, the engine computing the adjustment from the rate of the
  deducted member (the interstate rate) and its own (the internal rate), both
  already on the line. No expression: three named keys and one table.

The amount is rounded once per group as every tax is (BR-CO-14), the base
first, at the currency, then the tax: the worked example above to the cent.

**3. How it posts.** On the seller's side the tax of the chain is not revenue:
its `tax` posting credits the account of the tax collected for others and adds
to the receivable, and its `base` posting books nothing on the ledger
(`factor` 0) and reports the presumed base in its box (`box_factor` 100), so
the declaration receives the base and the tax as the form asks. On the buyer's
side the tax is not recoverable: one `tax_on_base` posting at 100 % puts it on
the cost of the goods, as a non-deductible VAT is booked today. A credit note
reverses both with their own postings.

**4. What the declaration reads.** The boxes of a substitution return are
declaration boxes like any other (decision 0023), filled by the postings, per
form; a destination state with its own return is a second form, which waits
for a pack to carry more than one declaration form.

## Consequences

- A pack states every margin with its article; the core holds the arithmetic
  and no margin, no rate and no state.
- The prerequisite is general and serves more than Brazil: Canada's two taxes
  in Québec (the pack's README) and any tax levied on top of another are the
  same `group`.
- **Out of scope, and said so by the pack that needs them:** the refund or the
  complement owed when the real final price differs from the presumed one; the
  tax substitution "backward" (deferral) and "concomitant"; the difference of
  rates owed by a buyer outside the regime (DIFAL) and any fund added to the
  rate; a buyer or seller under a simplified regime; the inventory adjustment
  when a good enters or leaves the regime; and the transmission of a return,
  which is the user's.
- Until it is built, a Brazilian pack books the own ICMS with decision 0077
  and says in its README that the tax of the chain is not computed.

## See also

- [0077](0077-a-tax-computed-inside-its-own-base.md) — A tax computed inside its own base is one key of the tax
- [0078](0078-a-line-names-what-was-sold.md) — A line names what was sold, by the classification its country declares
- [0020](0020-one-tax-engine-several-kinds-of-tax.md) — One tax engine, several kinds of tax
- [0019](0019-tax-postings-carry-the-account-and-the-box.md) — A tax posting carries the account and the box
- [0024](0024-a-tax-follows-the-territory-of-the-parties.md) — A tax follows the territory of the parties
- [`packs/ca/README.md`](../../packs/ca/README.md) — one tax code per document line
