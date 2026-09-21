# The sources of a pack are a register, not a bibliography

> Status: accepted

## Context

`legal_reference` on a rule says what is claimed — an article — and leaves the
reviewer to find the text. A list of bare titles in a manifest is half an
answer.

## Decision

**A register, and a key on the rule.** Each text is declared once: a key, a
title, the official publisher, an absolute `https` URL and the day somebody
opened it. Every rule names the key of the text its article is in. A URL on
each rule would repeat one link across dozens of boxes and turn a publisher's
site reorganisation into a sweep across files. The article belongs with the
claim; the link belongs with the text.

**The publisher is a field.** A link says where something is served, not who
stands behind it; a mirror or a commentary also resolves. A reviewer checks
the publisher first.

**Six kinds, closed:** `law`, `regulation`, `form`, `standard`, `portal`,
`guidance`. The useful split is `law` against `form`: a rate comes from a
statute and a box from a form, often published by different administrations.
A portal is included although it is not a legal source, because whoever
installs a pack needs to know where the return is filed.

**Nothing is copied.** No pack holds a sentence of the law it transcribes; a
quotation ages unnoticed and would make a pack an unversioned edition of a
statute.

**The register is required by status.** `reviewed` requires a source on every
tax and every box; `maintained` warns; `community` asks nothing.

**Following the links is not a CI check.** `ekwo pack check --links` reports a
reading and a maintainer decides. Official sites refuse non-browser clients,
serve the same page for a text and a typo, and move forms before deadlines; a
gate on that would fail a contributor's pull request for something nobody in
it did, and the cheapest fix would be to delete the link.

## Consequences

- A reviewer can open every source a rule relies on from the pack itself.
- A broken link is a finding for a maintainer, never a failed build.

## See also

- [0026 Certification names a reviewer](0026-certification-names-a-reviewer.md)
- [`packs.md`](../packs.md)
