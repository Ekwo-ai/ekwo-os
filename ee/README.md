# `ee/` — the commercial layer

This directory is empty on purpose, and it has its own [LICENSE](LICENSE).

## Where the line falls

Everything outside `ee/` is AGPL-3.0 and always will be. The line between the
two is **operational, not functional**: it is not about which features are
good enough to charge for, it is about what requires Ekwo to operate something
continuously on your behalf.

The test, applied without exception: **does it keep working on its own, with us
or without us?**

If yes, it belongs in the open core. A trial balance computed by Postgres, a
VAT return read off the ledger, an invoice rendered to a PDF, a chart of
accounts — none of these needs anything of ours to be running. They are here, under AGPL, and
no licence key gates them.

If no, it belongs in `ee/`, and you are entitled to know that before you buy:

| Belongs in `ee/` | Because |
|---|---|
| Bank connections | A PSD2 aggregator contract, held by Ekwo |
| Peppol sending and receiving | A certified access point and a certificate |
| Transmission to Intervat, Teledec, the NBB | Transmission credentials and a channel kept running — the return itself stays the business's |
| The AI agents that book, match and check | Models Ekwo trains, runs and supervises |
| The multi-instance control plane | Monitoring, upgrades, backups across a fleet |

And the counterpart, which matters as much: **what comes back from a filing is
open core.** The deposit number, the acknowledgement, the words the
administration used and the file that was sent are rows and attachments of your
own database — `tax_filing_deposits`, under the same policies as the rest of
your books. A company that stops paying for the transmission keeps every proof
that it filed. The channel is recorded as two words, `portal` or `service`, and
the name of a service as free text: the core records what was used and holds no
list of what may be.

## What will never be in `ee/`

- **Removing the attribution in the footer.** That is an attribution, not a
  toll. Charging to hide it would make it a fine.
- **Any part of the accounting core**: the schema, the posting rules, the
  reports, the charts of accounts, the tax rules, the export formats.
- **Exporting your own data.** `pg_dump` works, and it is the same schema on
  both sides. That is the whole argument for installing this at all.

## Structure

When commercial code lands here, it keeps this shape: its own `LICENSE`, its
own migrations under `ee/supabase/migrations/`, applied only to managed
instances, and never a prerequisite for anything in the core.
