/**
 * The six reads a set of books is judged on, and what each may cost.
 *
 * One definition, read by `tests/load/` — which checks the shape of the plan
 * on PGlite and breaks the build — and by `scripts/e2e-supabase.mjs`, which
 * times them on a real Postgres and breaks nothing. The budget is a column of
 * the report, never an assertion: a time measured on a shared CI runner is
 * noise, and a build that fails on noise is a build people learn to re-run.
 *
 * Every path is called the way a client calls it — through the function, not
 * through a copy of its body — so what is planned is what ships. `sql` is the
 * call over a database connection; `rpc` is the same call as PostgREST takes
 * it, for the run against a hosted project.
 */

/**
 * The tables that grow with the books. A sequential scan of one of these
 * inside a hot path is the failure `tests/load/` exists to catch: the path
 * reads one account, one period or one statement, and a plan that walks the
 * whole table to find it costs what the instance holds rather than what the
 * question asks.
 */
export const LARGE_TABLES = [
  'entry_lines',
  'entries',
  'documents',
  'document_lines',
  'payments',
  'reconciliations',
  'bank_transactions',
];

/**
 * @param scope companyId · yearFrom · yearTo (the latest financial year) ·
 *              periodFrom · periodTo (one declaration period inside it) ·
 *              accountId (the ledger asked for) · statementId
 */
export function hotPaths(scope) {
  return [
    {
      key: 'general_ledger',
      name: 'General ledger of one account over a financial year',
      budgetMs: 500,
      sql: `select count(*)::int as rows from general_ledger($1, $2::date, $3::date, array[$4::uuid])`,
      params: [scope.companyId, scope.yearFrom, scope.yearTo, scope.accountId],
      rpc: { fn: 'general_ledger', args: { p_company_id: scope.companyId, p_from: scope.yearFrom, p_to: scope.yearTo, p_account_ids: [scope.accountId] } },
    },
    {
      key: 'trial_balance',
      name: 'Trial balance of a financial year',
      budgetMs: 1000,
      sql: `select count(*)::int as rows from trial_balance($1, $2::date, $3::date)`,
      params: [scope.companyId, scope.yearFrom, scope.yearTo],
      rpc: { fn: 'trial_balance', args: { p_company_id: scope.companyId, p_from: scope.yearFrom, p_to: scope.yearTo } },
    },
    {
      key: 'aged_balance',
      name: 'Aged receivables at the end of the year',
      budgetMs: 1000,
      sql: `select count(*)::int as rows from aged_balance($1, $2::date, 'receivable')`,
      params: [scope.companyId, scope.yearTo],
      rpc: { fn: 'aged_balance', args: { p_company_id: scope.companyId, p_at: scope.yearTo, p_group: 'receivable' } },
    },
    {
      key: 'vat_return',
      name: 'Tax return of one declaration period',
      budgetMs: 1000,
      sql: `select count(*)::int as rows from vat_return($1, $2::date, $3::date)`,
      params: [scope.companyId, scope.periodFrom, scope.periodTo],
      rpc: { fn: 'vat_return', args: { p_company_id: scope.companyId, p_from: scope.periodFrom, p_to: scope.periodTo } },
    },
    {
      key: 'fec_lines',
      name: 'Entries file (FEC) of a whole financial year',
      budgetMs: 5000,
      sql: `select count(*)::int as rows from fec_lines($1, $2::date, $3::date)`,
      params: [scope.companyId, scope.yearFrom, scope.yearTo],
      rpc: { fn: 'fec_lines', args: { p_company_id: scope.companyId, p_from: scope.yearFrom, p_to: scope.yearTo } },
    },
    {
      key: 'suggest_contacts',
      name: 'suggest_contacts() over one month of bank statement',
      budgetMs: 5000,
      sql: `select count(*)::int as rows
              from bank_transactions t
              cross join lateral suggest_contacts(t.id) s
             where t.statement_id = $1`,
      params: [scope.statementId],
      // Over an API a client asks line by line, so that is what is timed there.
      rpc: { fn: 'suggest_contacts', perTransactionOf: scope.statementId },
      // One line is enough to read the plan, and all the recording can bear:
      // the function works out the words of every contact, each of them a
      // nested statement `auto_explain` reports.
      planSql: `select count(*)::int as rows
                  from suggest_contacts((select t.id from bank_transactions t
                                          where t.statement_id = $1
                                          order by t.sequence limit 1))`,
    },
  ];
}

/**
 * Turns on the recording of every plan, nested statements included.
 *
 * `EXPLAIN select * from vat_return(…)` answers "Function Scan" and nothing
 * else: the queries that matter are inside a plpgsql body. `auto_explain` with
 * `log_nested_statements` reports each of them as it runs, with the plan the
 * executor really used for the parameters it really got, and
 * `client_min_messages = log` sends the report to the client as a notice.
 *
 * `log_timing` is off: a plan is read here for its shape and its row counts,
 * and per-node clocks are the expensive part of `ANALYZE`.
 */
export const RECORD_PLANS = `
  set auto_explain.log_min_duration = 0;
  set auto_explain.log_nested_statements = on;
  set auto_explain.log_analyze = on;
  set auto_explain.log_timing = off;
  set auto_explain.log_format = json;
  set client_min_messages = log;
`;

export const STOP_RECORDING = `
  set auto_explain.log_min_duration = -1;
  reset client_min_messages;
`;

/**
 * A collector for the notices `auto_explain` sends.
 *
 * It keeps what is worth reading and counts the rest, because the rest is
 * most of it: every nested statement is reported, and a function a policy
 * calls once per row is a nested statement once per row. The first recording
 * of `fec_lines()` as a member, kept whole, ran Node out of four gigabytes.
 *
 * - a plan that touches a large table is parsed and kept;
 * - an evaluation of `has_capability()` is recognised by a column only its
 *   body names, and counted — which is the measure of how often a policy asks;
 * - everything else is counted and dropped.
 */
export function planRecorder() {
  const plans = [];
  const counts = { statements: 0, capabilityChecks: 0 };
  const mentionsLargeTable = new RegExp(`"Relation Name": "(${LARGE_TABLES.join('|')})"`);
  return {
    plans,
    counts,
    onNotice(notice) {
      const message = typeof notice === 'string' ? notice : notice.message;
      if (typeof message !== 'string' || !message.startsWith('duration:')) return;
      counts.statements += 1;
      if (message.includes('capabilities_revoked')) counts.capabilityChecks += 1;
      if (!mentionsLargeTable.test(message)) return;
      const parsed = JSON.parse(message.slice(message.indexOf('plan:') + 'plan:'.length));
      plans.push({ query: parsed['Query Text'], plan: parsed['Plan'] });
    },
  };
}

/** Every node of a plan, depth first. */
export function* nodesOf(plan) {
  yield plan;
  for (const child of plan['Plans'] ?? []) yield* nodesOf(child);
}

/**
 * The sequential scans of a large table in a set of recorded plans, each with
 * the statement it happened in — so a failure names the query, not the path.
 */
export function largeSequentialScans(plans) {
  const found = [];
  for (const { query, plan } of plans) {
    for (const node of nodesOf(plan)) {
      if (node['Node Type'] === 'Seq Scan' && LARGE_TABLES.includes(node['Relation Name'])) {
        found.push({
          table: node['Relation Name'],
          rows: node['Actual Rows'],
          removed: node['Rows Removed by Filter'] ?? 0,
          filter: node['Filter'] ?? null,
          query: query.replace(/\s+/g, ' ').trim().slice(0, 160),
        });
      }
    }
  }
  return found;
}

/** How each large table was reached, for the report: `entry_lines: Index Scan on …`. */
export function accessOf(plans) {
  const seen = new Set();
  for (const { plan } of plans) {
    for (const node of nodesOf(plan)) {
      const table = node['Relation Name'];
      if (table === undefined || !LARGE_TABLES.includes(table)) continue;
      // A bitmap heap scan names the table and its children name the indexes.
      const indexes = [...nodesOf(node)].map((n) => n['Index Name']).filter((n) => n !== undefined);
      const index = indexes.length === 0 ? '' : ` on ${[...new Set(indexes)].join(' + ')}`;
      seen.add(`${table}: ${node['Node Type']}${index}`);
    }
  }
  return [...seen].sort();
}

/**
 * Rows the plans read out of the large tables, all scans added up. A path
 * that answers about a quarter and reads five years shows up here and nowhere
 * in the shape of its plan: every node of it is an index scan.
 */
export function rowsReadOf(plans) {
  let rows = 0;
  for (const { plan } of plans) {
    for (const node of nodesOf(plan)) {
      if (node['Relation Name'] === undefined || !LARGE_TABLES.includes(node['Relation Name'])) continue;
      const loops = node['Actual Loops'] ?? 1;
      rows += ((node['Actual Rows'] ?? 0) + (node['Rows Removed by Filter'] ?? 0)) * loops;
    }
  }
  return Math.round(rows);
}
