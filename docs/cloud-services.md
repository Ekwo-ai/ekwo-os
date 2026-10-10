# The optional paid services

*Everything in this repository is AGPL-3.0 and always will be. This page is
about what is **not** in it, so that you know before you buy — and so that you
know what you never have to buy.*

Ekwo Cloud is a set of optional services operated by **Ekwo**. They are not part of this repository, they carry no licence of this
repository, and **nothing here needs them.** An installation that never hears
of Ekwo Cloud keeps its books, computes its statements, prepares its returns
and exports everything, for as long as its database runs.

## Where the line falls

The line is **operational, not functional**. It is not about which features are
good enough to charge for. It is about what requires somebody to operate
something continuously on your behalf.

The test, applied without exception:

> **Does it keep working on its own, with us or without us?**

If yes, it is in this repository, under AGPL, and no licence key gates it. A
trial balance computed by Postgres, a VAT return read off the ledger, an
invoice rendered to a PDF, a chart of accounts — none of these needs anything
of ours to be running.

If no, it is a service, because something has to be kept alive for it to work:

| Service | What has to be kept alive |
|---|---|
| Bank connections | a PSD2 aggregator contract |
| Peppol sending and receiving | an access point and its certificate — the open `einvoicing` module writes and checks the file, and records every sending |
| Transmission to tax administrations and business registers | transmission credentials and a channel kept running — the return itself stays the business's |
| The AI agents that book, match and check | models trained, run and supervised |
| A portfolio across installations, for an accounting firm | a control plane above installations that do not see each other |
| Operating instances: monitoring, upgrades, backups | a fleet watched over time |

## What comes back is yours

This matters as much as the list above. **What comes back from a filing is open
core.** The deposit number, the acknowledgement, the words the administration
used and the file that was sent are rows and attachments of your own database —
`tax_filing_deposits`, under the same policies as the rest of your books.

A company that stops paying for the transmission keeps every proof that it
filed. The channel is recorded as two words, `portal` or `service`, and the
name of a service as free text: the core records what was used and holds no
list of what may be.

## What will never be sold

- **Removing the attribution in the footer.** That is an attribution, not a
  toll. Charging to hide it would make it a fine.
- **Any part of the accounting core**: the schema, the posting rules, the
  reports, the charts of accounts, the tax rules, the export formats.
- **Exporting your own data.** `pg_dump` works, and it is the same schema on
  both sides. That is the whole argument for installing this at all.

## Why there is no "enterprise edition" folder

None of the services above is a feature that could sit in this repository
behind a flag: each is a contract, a certificate, a credential or a machine
somebody keeps running. **What you get from this repository is the whole of
it**, and the services live where they are operated.
