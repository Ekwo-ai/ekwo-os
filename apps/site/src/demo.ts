/**
 * The two transcripts the home page shows, built from a real year of books.
 *
 * Nothing in them is written out. The country is whichever pack of `packs/`
 * comes first with what this needs — a golden scenario carrying a sale invoice,
 * and a periodic return — so a pack landing before it in the directory takes
 * the demonstration over and no country is named here. The invoice is a
 * document of that pack's `golden/scenario.json`, word for word; the accounts
 * the entry lands on are the ones the tax's own postings name and the role the
 * manifest declares; and the boxes at the end are read out of
 * `golden/vat_return.json`, which is what the engine produced when the suite
 * last replayed that year.
 *
 * The one thing computed here rather than read is the tax on the line and the
 * total, from the rate the pack declares. That is the arithmetic the engine
 * does, on the same inputs, and it is the reason the figure can be shown beside
 * a box the engine itself filled: if the two disagreed, the golden test would
 * already be red.
 *
 * **Every command and every tool name is one that exists.** The command line
 * is `ekwo doc new`, `ekwo post` and `ekwo company export`; the agent calls
 * `search_contacts`, `create_document`, `post_document` and `vat_return`, which
 * are four of the tools the MCP server registers. An earlier draft of this file
 * showed `ekwo doc post` and `ekwo vat return`, and neither is a command — the
 * sort of thing that is invisible until somebody types it.
 *
 * What is staged, and says so under the widget, is the *conversation*: the
 * request in English and the agent's sentences around the calls. The calls and
 * their results are real.
 */

import { readFile } from 'node:fs/promises';
import { existsSync } from 'node:fs';
import { join } from 'node:path';
import type { Pack } from '../../../packages/cli/src/index.js';

export interface TermLine {
  /**
   * `command` is typed, `out` is returned, `dim` is a note, `ask` is a
   * question. Two more are Claude Code's: `prompt` is what the person types
   * into it, and `tool` is a call it makes — to one of its own tools, or to a
   * tool of the Ekwo MCP server, written as Claude Code writes one:
   * `ekwo - <tool> (MCP)(<arguments>)`.
   */
  kind: 'command' | 'out' | 'dim' | 'say' | 'ask' | 'answer' | 'tool' | 'prompt';
  text: string;
}

/** Claude Code's own tools the transcripts call, as its terminal names them. */
export const CLAUDE_CODE_TOOLS = ['Search', 'Read'] as const;

/** How Claude Code's terminal writes a call to a tool of the Ekwo MCP server. */
export const MCP_PREFIX = 'ekwo - ';

export interface Demo {
  /** The country the transcripts are of, as the pack names it. */
  country: string;
  slug: string;
  /** A person at a terminal. */
  cli: TermLine[];
  /** An agent with the same rights, calling the same functions. */
  agent: TermLine[];
  /**
   * Claude Code in a terminal, asked the way one asks it to bring a folder of
   * PDF invoices into the books. Null where the pack's golden year has no
   * purchase invoice to show it with.
   */
  claude: TermLine[] | null;
}

function money(value: number): string {
  return value.toFixed(2);
}

export async function buildDemo(packs: Pack[], packsRoot: string): Promise<Demo | null> {
  for (const pack of packs) {
    const demo = await demoOf(pack, packsRoot);
    if (demo !== null) return demo;
  }
  return null;
}

async function demoOf(pack: Pack, packsRoot: string): Promise<Demo | null> {
  const golden = pack.golden;
  const report = pack.report;
  if (golden === null || report === null) return null;

  const invoice = golden.documents.find((document) => document.type === 'sale_invoice');
  const line = invoice?.lines[0];
  if (invoice === undefined || line === undefined || line.tax === null) return null;

  const contact = golden.contacts.find((entry) => entry.ref === invoice.contact);
  const tax = pack.taxes.find((entry) => entry.code === line.tax);
  if (contact === undefined || tax === undefined || tax.amount_type !== 'percent') return null;

  const receivable = pack.manifest.defaults.roles['receivable'];
  if (typeof receivable !== 'string') return null;

  const base = line.quantity * line.unit_price * (1 - line.discount_percent / 100);
  const taxDue = (base * tax.rate) / 100;
  const total = base + taxDue;
  const currency = pack.manifest.defaults.currency;

  const taxPosting = tax.postings.invoice.find((posting) => posting.type === 'tax');
  const basePosting = tax.postings.invoice.find((posting) => posting.type === 'base');
  if (taxPosting?.account == null) return null;

  const period = await firstPeriod(pack.slug, packsRoot);
  if (period === null) return null;

  const boxOf = (code: string | null, kind: string): { code: string; value: string } | null => {
    if (code === null) return null;
    const value = period.boxes[`${code}:${kind}`];
    return value === undefined ? null : { code, value };
  };
  const baseBox = boxOf(basePosting?.box ?? null, 'base');
  const taxBox = boxOf(taxPosting.box, 'tax');

  const newInvoice =
    `ekwo doc new --contact "${contact.name}" --date ${invoice.date} \\\n` +
    `  --line "name=${line.name},quantity=${line.quantity},` +
    `price=${money(line.unit_price)},account=${line.account},tax=${tax.code}"`;

  const entry: TermLine[] = [
    { kind: 'dim', text: '  account   debit      credit' },
    { kind: 'out', text: `  ${receivable}    ${money(total).padStart(9)}` },
    { kind: 'out', text: `  ${line.account}               ${money(base).padStart(9)}` },
    { kind: 'out', text: `  ${taxPosting.account}               ${money(taxDue).padStart(9)}` },
  ];

  const cli: TermLine[] = [
    { kind: 'command', text: newInvoice },
    { kind: 'out', text: `${invoice.ref}  draft  ${money(total)} ${currency}` },
    { kind: 'command', text: `ekwo post ${invoice.ref} --dry-run` },
    ...entry,
    { kind: 'dim', text: '  balanced — nothing posted, --dry-run' },
    { kind: 'command', text: 'ekwo company export' },
    { kind: 'dim', text: '  manifest.json + data/*.jsonl — your books, yours to take' },
  ];

  const agent: TermLine[] = [
    {
      kind: 'ask',
      text: `Invoice ${contact.name} for ${line.quantity} × ${line.name}, and tell me what it does to this quarter's VAT.`,
    },
    { kind: 'say', text: 'Finding the customer.' },
    { kind: 'command', text: `search_contacts  { "query": "${contact.name}" }` },
    { kind: 'out', text: `  ${contact.name} · ${contact.type} · ${contact.country}` },
    { kind: 'say', text: 'Drafting the invoice. Nothing is booked by a draft.' },
    {
      kind: 'command',
      text:
        `create_document  { "doc_type": "sale_invoice", "document_date": "${invoice.date}",\n` +
        `                   "lines": [{ "name": "${line.name}", "quantity": ${line.quantity},\n` +
        `                               "unit_price": "${money(line.unit_price)}",\n` +
        `                               "account_code": "${line.account}", "tax_code": "${tax.code}" }] }`,
    },
    { kind: 'out', text: `  ${invoice.ref}  draft  ${money(total)} ${currency}` },
    { kind: 'say', text: 'This is the entry it would write:' },
    ...entry,
    {
      kind: 'ask',
      text: 'This books the invoice and cannot be undone. Post it?',
    },
    { kind: 'answer', text: 'y' },
    { kind: 'command', text: `post_document  { "document_id": "${invoice.ref}" }` },
    { kind: 'out', text: `  posted · entry balanced · period open` },
    { kind: 'say', text: `And the declaration for ${period.code}:` },
    { kind: 'command', text: `vat_return  { "period": "${period.code}" }` },
  ];

  if (baseBox !== null) {
    agent.push({ kind: 'out', text: `  box ${baseBox.code}   ${baseBox.value.padStart(12)}` });
  }
  if (taxBox !== null) {
    agent.push({ kind: 'out', text: `  box ${taxBox.code}   ${taxBox.value.padStart(12)}` });
  }
  agent.push({
    kind: 'say',
    text:
      `Booked ${money(total)} ${currency} to ${receivable}` +
      (taxBox === null ? '.' : `, and box ${taxBox.code} of ${period.code} now reads ${taxBox.value}.`),
  });

  return {
    country: pack.manifest.name,
    slug: pack.slug,
    cli,
    agent,
    claude: importSession(pack),
  };
}

/**
 * "Gather every PDF invoice in my Drive folder and load them into the books."
 *
 * One invoice, and what really happens to it. **Ekwo reads no PDF**: there is
 * no extraction in the core, the command line or the MCP server, and no tool
 * that stores a file against a document. So Claude Code reads the file with
 * its own `Read` — which is the model reading, the place the manifesto says
 * reading a document belongs — and drafts what it read with
 * `create_document`, the file name as `client_ref` so that asking twice drafts
 * once. It books nothing, says that the file stays where it is, and asks
 * before posting.
 *
 * The invoice is the golden year's first purchase invoice, word for word, and
 * the account and tax on the draft are the ones the golden year books it to.
 * The file name and the folder are the staging.
 */
function importSession(pack: Pack): TermLine[] | null {
  const golden = pack.golden;
  if (golden === null) return null;
  const document = golden.documents.find((entry) => entry.type === 'purchase_invoice');
  if (document === undefined) return null;
  const contact = golden.contacts.find((entry) => entry.ref === document.contact);
  const line = document.lines[0];
  if (contact === undefined || line === undefined) return null;

  const folder = '~/Drive/Invoices';
  const file = `${document.date} ${contact.name}.pdf`;
  const base = line.quantity * line.unit_price * (1 - line.discount_percent / 100);
  const quantity = line.quantity === 1 ? '' : `quantity: ${line.quantity}, `;
  const tax = line.tax === null ? '' : `, tax_code: "${line.tax}"`;

  return [
    { kind: 'prompt', text: 'gather every PDF invoice in my local Drive folder and load them into the books' },
    { kind: 'tool', text: `Search(pattern: "**/*.pdf", path: "${folder}")` },
    { kind: 'out', text: 'Found 1 file' },
    {
      kind: 'say',
      text: 'Ekwo reads no PDF, so I’ll read the invoice myself and draft what it says. A draft books nothing.',
    },
    { kind: 'tool', text: `Read(${folder}/${file})` },
    { kind: 'out', text: 'Read PDF' },
    { kind: 'say', text: `${contact.name}, ${document.date}: ${line.name}, ${money(base)} before tax.` },
    { kind: 'tool', text: `${MCP_PREFIX}search_contacts (MCP)(query: "${contact.name}")` },
    { kind: 'out', text: `${contact.name} · ${contact.type} · ${contact.country}` },
    {
      kind: 'tool',
      text:
        `${MCP_PREFIX}create_document (MCP)(doc_type: "purchase_invoice", document_date: "${document.date}",\n` +
        `  client_ref: "${file}",\n` +
        `  lines: [{ name: "${line.name}", ${quantity}unit_price: "${money(line.unit_price)}", ` +
        `account_code: "${line.account}"${tax} }])`,
    },
    { kind: 'out', text: 'draft · purchase_invoice · nothing booked' },
    {
      kind: 'say',
      text:
        'One draft. It carries the file name as its reference, so running this again drafts nothing twice. ' +
        'The PDF stays in your folder: this release has no tool that stores a file against a document.',
    },
    { kind: 'ask', text: 'I read it from the PDF, so check it against the file. Shall I post it?' },
  ];
}

/** The first period of a pack's golden return, with the boxes it produced. */
async function firstPeriod(
  slug: string,
  packsRoot: string,
): Promise<{ code: string; boxes: Record<string, string> } | null> {
  const path = join(packsRoot, slug, 'golden', 'vat_return.json');
  if (!existsSync(path)) return null;
  const read = JSON.parse(await readFile(path, 'utf8')) as {
    periods?: { code: string; boxes: Record<string, string> }[];
  };
  const period = read.periods?.[0];
  return period === undefined ? null : { code: period.code, boxes: period.boxes };
}
