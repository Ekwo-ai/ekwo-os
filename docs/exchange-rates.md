# Exchange rates from a published series

`ekwo rates fetch` writes the exchange rates a public series published for a
day into the installation's rates, the rows of `currency_rates` that name no
company. One row per currency and day, its `source` saying which series it
came from. It holds no schedule: the operator runs it once a day, from cron, a
CI job or a hosted service.

```sh
# The first time: name the currency the installation's rates are against.
npx -y ekwo-os@latest rates fetch --reference-currency <code> --db-url "$DB_URL"

# Every day after that.
npx -y ekwo-os@latest rates fetch --db-url "$DB_URL"

# A given day, from the same series.
npx -y ekwo-os@latest rates fetch --date 2026-03-02 --db-url "$DB_URL"
```

Like `ekwo migrate`, it connects as the owner of the database: the
installation's rates are written by nobody through the API.

## The convention

An instance-wide row is **units of the currency for one unit of the instance
reference currency**, `instance.reference_currency`. Until this command, no
column named that currency. It is null on every installation and nothing
guesses it — not from the country of the first company, not from a pack. The
first run names it with `--reference-currency`; it is recorded together with
the first rates written, and a later run that names another one is refused
(`instance_reference_currency_differs`), since the rows already there would be
read in the wrong base.

A series quotes against its own base. Each quote is divided by the series'
quote of the reference currency, in Postgres `numeric`, and rounded to the
eight decimals `currency_rates.rate` keeps; when the reference is the base of
the series, the published figures are written as they are. A reference the
series does not quote for that day is refused by name
(`reference_currency_not_quoted`) and nothing is written: no other currency
stands in for it. A currency the installation does not know (`currencies`) is
left out and listed.

A row that names a company is that company's own rate, against its own
currency — the rate it closes a year at, set with `ekwo close rate`. The
command never reads or writes those rows.

## Running it again, and what is already there

- **A day already fetched** changes nothing: every rate is reported as
  `unchanged`.
- **A rate already recorded for that currency and day** — typed by hand, or
  from another series — is kept, and reported under `kept` with the quote
  beside it. `--overwrite` replaces it, and `audit_log` keeps the value it
  replaced (`old_values`).
- **A day the series did not publish** — a weekend, a holiday, a day not yet
  published — writes nothing and says so (`published: false`). No earlier
  rate is carried forward into the table.

## Who reads these rows

Today, nothing computes a figure from the instance-wide rows. A document
stores the rate it was booked at (`documents.exchange_rate`) and keeps it: no
fetch changes a booked document. A close reads the company's own row of the
last day, exactly (decision 0100). No reader takes "the last rate on or before
a day" from this table yet; proposing the fetched rate to a new document, or
as a company's closing rate, is a reader still to write.

## The sources

`--source` takes the name of one; the first is the default.

| Name | Series | Base | Files |
|---|---|---|---|
| `ecb` | [Euro foreign exchange reference rates](https://www.ecb.europa.eu/stats/policy_and_exchange_rates/euro_reference_exchange_rates/html/index.en.html) of the European Central Bank | the euro | [latest day](https://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml), [last 90 days](https://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist-90d.xml), [since 1999](https://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist.xml) |

The ECB publishes its reference rates "at around 16:00 CET every working day,
except on TARGET closing days". It states that they "are published for
information purposes only" and that "using the rates for transaction purposes
is strongly discouraged"; information from its website may be reproduced if
"it must appear accurately and the ECB must be cited as the source"
([terms](https://www.ecb.europa.eu/home/disclaimer/html/index.en.html)). Every
row it gives says `ecb`. Without `--date` the command reads the latest day;
with one, the 90-day file, and the whole history for an older day.

A source is one module of `packages/cli/src/rates/` behind one interface — a
name, a base, and `fetch(date)` returning the day's quotes — and one line in
`RATE_SOURCES`. A national central bank or a commercial provider is added the
same way, and the command does not change.
