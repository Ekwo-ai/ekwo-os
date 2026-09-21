# Ekwo maintains a pack; only an accountant reviews one

> Status: accepted

## Context

A golden test proves a pack is internally coherent. Neither writing a pack nor
testing it is an accountant reading it against the law, so "certified by
Ekwo" is a claim the project cannot make.

## Decision

**The scale is `community`, `maintained`, `reviewed`.**

- `community` — contributed, not read by an accountant.
- `maintained` — kept current by the maintainers, not yet reviewed by an
  accountant.
- `reviewed` — a named professional read it; the manifest carries who and
  when. Nothing else counts.

There is no value meaning "certified by Ekwo". A deprecated enum value that
once meant so remains in the enum (a published column never loses a value),
nothing writes it, the pack schema refuses it, and rows holding it were
migrated.

**One sentence describes a pack**, written once in the CLI and printed by
`ekwo init`, `ekwo status` and every generated seed header: "maintained by
Ekwo — not yet reviewed by an accountant", "reviewed by X on Y", "community
pack — not reviewed".

**A pack that is not reviewed says where a reviewer should start.** Its README
lists the points where the text allows more than one reading. A list of known
soft spots is worth more than a status that overstates the work.

**`legal_reference` is required on every tax and every box**, and a `"TODO"`
is not a source. `.github/CODEOWNERS` names who is asked about each pack —
not who has signed it.

**A whole chart, at the depth the law prescribes.** Where a country publishes
a chart, the pack transcribes it whole rather than ship a subset, which would
be this repository's opinion of which accounts matter; where the State
publishes the mapping from accounts to statement lines, the pack uses it
account by account rather than compressing it into ranges.

**A country written from published sources alone tests the format.** A pack
written by somebody reading a foreign statute with no permission to change the
core is the honest test that a country is data.

## Consequences

- No status in the product claims more review than happened.
- Moving a pack to `reviewed` is a manifest change signed by a named person.

## See also

- [0027 The sources of a pack are a register](0027-the-sources-of-a-pack-are-a-register.md)
- [0035 The chart stays whole; the working list is derived](0035-the-chart-stays-whole.md)
- [`packs.md`](../packs.md), [`DISCLAIMER.md`](../../DISCLAIMER.md)
