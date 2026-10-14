/**
 * Whether a rule of a pack takes an account — the one spelling of the test in
 * this CLI, read by the checks of the statements and of the analysis section.
 *
 * It is the comparison `statement_rule_catches()` makes in the database, and
 * the two are kept in step by the statements: a pack whose accounts the
 * checker places on one line and the database on another prints a balance
 * sheet that does not tie out, and its golden says so.
 */

/** The shape a rule has wherever a pack writes one: a statement line, an aggregate. */
export interface AccountRule {
  kind: 'code_range' | 'code_prefix' | 'account_type' | 'account_code';
  code_from: string | null;
  code_to: string | null;
  account_type: string | null;
}

/** Does this rule catch this account code? The same comparison the SQL makes. */
export function ruleCatches(rule: AccountRule, code: string): boolean {
  const from = rule.code_from ?? '';
  const to = rule.code_to ?? '';
  switch (rule.kind) {
    case 'account_code':
      return code === from;
    case 'code_prefix':
      return code.slice(0, from.length) === from;
    case 'code_range':
      return code.slice(0, from.length) >= from && code.slice(0, to.length) <= to;
    default:
      return false;
  }
}

/** Does this rule take this account, by its code or, for an `account_type` rule, by its type? */
export function ruleTakes(rule: AccountRule, account: { code: string; type: string }): boolean {
  return rule.kind === 'account_type' ? rule.account_type === account.type : ruleCatches(rule, account.code);
}
