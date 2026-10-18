/**
 * Ledger lines that name nobody: who they could be, and naming one.
 *
 * Books brought in line by line arrive with open items on the receivable and
 * payable accounts that name no contact. `suggest_line_contacts()` scores
 * them the way a statement line is scored and `set_line_contact()` names one,
 * once, and learns from it (decision 0070). The candidates, the scores and the
 * refusals are the schema's; this file asks for them and puts each line's
 * candidates under it.
 */

import type { Backend, Row } from './backend.js';
import { money, moneyFields } from './format.js';
import { only } from './shared.js';

export interface SuggestLineContactsArgs {
  company_id: string;
  /** The lines to ask about. Left out: every open third-party line of the company that names nobody. */
  line_ids?: string[] | undefined;
}

export interface SetLineContactArgs {
  line_id: string;
  contact_id: string;
}

/** One candidate for one line, as `suggest_line_contacts()` answers it. */
export interface LineContactCandidate {
  contact_id: string;
  name: string;
  score: number;
  method: string;
  because: string;
  alternatives: number;
}

/**
 * The candidates of each line, best first, with the label, the amount and the
 * account of the line beside them so a person can judge. A line nothing points
 * at is not listed.
 */
export async function suggestLineContacts(backend: Backend, args: SuggestLineContactsArgs): Promise<unknown> {
  const found = await backend.rpc<Row>('suggest_line_contacts', {
    p_company_id: args.company_id,
    ...(args.line_ids === undefined ? {} : { p_line_ids: args.line_ids }),
  });

  const byLine = new Map<string, LineContactCandidate[]>();
  for (const row of found) {
    const id = String(row['line_id']);
    const candidates = byLine.get(id) ?? [];
    candidates.push({
      contact_id: String(row['contact_id']),
      name: String(row['name']),
      score: Number(row['score']),
      method: String(row['method']),
      because: String(row['because']),
      alternatives: Number(row['alternatives']),
    });
    byLine.set(id, candidates);
  }

  const ids = [...byLine.keys()];
  const facts =
    ids.length === 0
      ? []
      : await backend.select<Row>({
          table: 'entry_lines',
          columns: ['id', 'name', 'debit', 'credit', 'account_id', 'entry_id'],
          where: [{ column: 'id', op: 'in', value: ids }],
        });
  const factOf = new Map(facts.map((fact) => [String(fact['id']), fact]));

  const lines = ids.map((id) => {
    const fact = factOf.get(id) ?? {};
    const side = Number(fact['debit'] ?? 0) > 0 ? 'debit' : 'credit';
    return {
      line_id: id,
      label: fact['name'] ?? null,
      side,
      amount: money(fact[side]),
      account_id: fact['account_id'] ?? null,
      entry_id: fact['entry_id'] ?? null,
      candidates: byLine.get(id) ?? [],
    };
  });
  return {
    lines,
    count: lines.length,
    note: 'Nothing is named by a suggestion. A candidate whose alternatives is more than 1 shares its evidence with other contacts and is a question, not an answer. set_line_contact names a line once, after the user has chosen.',
  };
}

/** Names the line through `set_line_contact()`, which refuses by name and learns from it. */
export async function setLineContact(backend: Backend, args: SetLineContactArgs): Promise<unknown> {
  const line = only(
    moneyFields(
      await backend.rpc<Row>('set_line_contact', { p_line_id: args.line_id, p_contact_id: args.contact_id }),
      ['debit', 'credit', 'balance', 'matched_amount', 'amount_currency', 'box_amount'],
    ),
    `line ${args.line_id} was not named`,
  );
  return {
    entry_line: line,
    note: 'The line names its contact now, and keeps it: a posted counterparty is corrected by reversing the entry. The label was learned as a motif of the contact, and the act is in the audit trail.',
  };
}
