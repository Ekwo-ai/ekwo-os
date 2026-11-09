#!/usr/bin/env node
/**
 * Which row level security policies ask who the caller is once per statement,
 * and which ask it again for every row.
 *
 * A policy such as
 *
 *     using (has_capability(company_id, 'entries.read'))
 *
 * calls the function with a column of the row as its argument, so Postgres
 * calls it for every row a scan visits: `stable` promises the same answer for
 * the same arguments, it does not make Postgres remember it, and a security
 * definer function is never inlined. The socle found it on its own tables
 * (`20260918141627_a_policy_asks_once.sql`), the `crm` module on its own
 * (`modules/crm/supabase/migrations/20261109120000_crm_reads_hold_at_volume.sql`),
 * and the defect, found twice, is checked here on every policy: the same
 * question asked the other way round,
 *
 *     using (company_id = any ((select companies_with_capability('entries.read'))::uuid[]))
 *
 * puts the call in a sub-select that depends on no column — an InitPlan, run
 * once per statement.
 *
 * The script builds the database the tests use — the socle and every module
 * of the checkout, on PGlite — and reads every policy from `pg_policy`. It
 * reads the parsed expression (`polqual`, `polwithcheck`: the tree Postgres
 * evaluates), not its text, and gives each expression one verdict:
 *
 * - `per row` — it calls a function of the database (not one of Postgres'
 *   own) whose arguments reach a column of the row, outside a sub-select; or
 *   it calls one inside a sub-select that refers to the row (a correlated
 *   sub-select is run again for every row, whatever it calls). The detail
 *   names each call: `has_capability(company_id)`, or
 *   `has_capability(…) in a sub-select on the row`.
 * - `once` — no such call. A call with no column, outside a sub-select
 *   (`is_known_caller()`), is listed in the detail as `bare: …`: Postgres
 *   calls it per row too, but it asks the same thing of every row, reads no
 *   table of a company and is not what this inventory is for.
 * - `-` — the policy has no expression of that kind (a select policy has no
 *   `with check`, an insert policy no `using`).
 *
 * `using` is what the rule of `tests/policies_ask_once.test.ts` holds: it is
 * evaluated for every row a read, an update or a delete visits. `with check`
 * is printed and not held: it is evaluated once per row *written*, which is
 * what a check is for, and both migrations above left it as it was.
 *
 *     node scripts/inventory-policies.mjs          # one line per policy
 *     node scripts/inventory-policies.mjs --json
 *
 * Needs Node 22.18 or later: it builds the database with the tests' own
 * helper, so the inventory and the test read the same database.
 */

import { fileURLToPath } from 'node:url';

/** The first oid a database object gets; below it, everything is Postgres' own. */
const FIRST_NORMAL_OBJECT_ID = 16384;

// ---------------------------------------------------------------------------
// Reading the tree Postgres stores: `nodeToString()` of src/backend/nodes/outfuncs.c.

/**
 * Splits a node tree into tokens: the four brackets, `<>` for null, quoted
 * strings, the byte arrays of a constant (skipped whole, as `[]`), and atoms.
 * A backslash makes the next character part of the atom, as outfuncs escapes
 * an identifier that holds a bracket or a space.
 */
function tokenize(text) {
  const tokens = [];
  let i = 0;
  while (i < text.length) {
    const c = text[i];
    if (c === ' ' || c === '\n' || c === '\t' || c === '\r') {
      i += 1;
    } else if (c === '{' || c === '}' || c === '(' || c === ')') {
      tokens.push(c);
      i += 1;
    } else if (c === '[') {
      const end = text.indexOf(']', i);
      if (end < 0) throw new Error('unterminated constant in a node tree');
      tokens.push('[]');
      i = end + 1;
    } else if (c === '"') {
      let j = i + 1;
      let value = '';
      while (j < text.length && text[j] !== '"') {
        if (text[j] === '\\') j += 1;
        value += text[j];
        j += 1;
      }
      tokens.push({ string: value });
      i = j + 1;
    } else {
      let value = '';
      while (i < text.length && !' \n\t\r{}()'.includes(text[i])) {
        if (text[i] === '\\') i += 1;
        value += text[i];
        i += 1;
      }
      tokens.push(value);
    }
  }
  return tokens;
}

/**
 * Parses a node tree into plain objects: a node is `{ node: 'FUNCEXPR',
 * funcid: '…', args: [...] }`, a list an array, anything else a string, and
 * `<>` is null.
 */
export function parseNodeTree(text) {
  const tokens = tokenize(text);
  let at = 0;
  function value() {
    const t = tokens[at++];
    if (t === '{') {
      const node = { node: tokens[at++] };
      while (tokens[at] !== '}') {
        const field = tokens[at++];
        if (typeof field !== 'string' || !field.startsWith(':')) throw new Error(`a field was expected in a node tree, found ${JSON.stringify(field)}`);
        // A field with no value is followed directly by the next field or the end of the node.
        node[field.slice(1)] = typeof tokens[at] === 'string' && (tokens[at].startsWith(':') || tokens[at] === '}') ? null : value();
        // A constant is written as its length and then its bytes: `:constvalue 4 [ 1 0 0 0 ]`.
        if (tokens[at] === '[]') at += 1;
      }
      at += 1;
      return node;
    }
    if (t === '(') {
      const list = [];
      while (tokens[at] !== ')') list.push(value());
      at += 1;
      return list;
    }
    if (t === '<>') return null;
    if (typeof t === 'object') return t.string;
    return t;
  }
  const tree = value();
  if (at !== tokens.length) throw new Error('a node tree was not read to its end');
  return tree;
}

function children(node) {
  if (Array.isArray(node)) return node;
  if (node === null || typeof node !== 'object') return [];
  return Object.values(node);
}

/**
 * Whether `node`, read at `depth` sub-queries below the policy, reaches a
 * column of the row the policy guards: a `VAR` whose `varlevelsup` climbs
 * back exactly to the policy's level.
 */
function reachesRow(node, depth) {
  if (Array.isArray(node)) return node.some((child) => reachesRow(child, depth));
  if (node === null || typeof node !== 'object') return false;
  if (node.node === 'VAR') return Number(node.varlevelsup) === depth;
  const inner = node.node === 'QUERY' ? depth + 1 : depth;
  return children(node).some((child) => reachesRow(child, inner));
}

/** The function a node calls, if it is a function of the database rather than one of Postgres'. */
function calledFunction(node) {
  const oid = node.node === 'FUNCEXPR' ? node.funcid : node.node === 'OPEXPR' ? node.opfuncid : null;
  return oid !== null && oid !== undefined && Number(oid) >= FIRST_NORMAL_OBJECT_ID ? Number(oid) : null;
}

/** Every function of the database called anywhere below `node`. */
function everyCall(node, out = []) {
  if (node !== null && typeof node === 'object' && !Array.isArray(node)) {
    const oid = calledFunction(node);
    if (oid !== null) out.push(oid);
  }
  for (const child of children(node)) everyCall(child, out);
  return out;
}

/**
 * The verdict on one expression of a policy: `{ verdict, perRow, bare }`,
 * where `perRow` and `bare` are the calls found, named by `nameOf(oid)`.
 */
export function classifyExpression(tree, nameOf) {
  if (tree === null || tree === undefined) return { verdict: '-', perRow: [], bare: [] };
  const perRow = [];
  const bare = [];
  (function walk(node) {
    if (Array.isArray(node)) {
      node.forEach(walk);
      return;
    }
    if (node === null || typeof node !== 'object') return;
    if (node.node === 'SUBLINK') {
      // A sub-select that refers to the row is a SubPlan, run again for every
      // row; one that does not is an InitPlan, run once per statement.
      if (reachesRow(node.subselect, 0)) {
        for (const oid of everyCall(node.subselect)) perRow.push(`${nameOf(oid)}(…) in a sub-select on the row`);
      }
      walk(node.testexpr);
      return;
    }
    const oid = calledFunction(node);
    if (oid !== null) {
      const args = node.args ?? [];
      if (reachesRow(args, 0)) {
        // The columns passed as they are; a column inside an expression shows as `…`.
        perRow.push(`${nameOf(oid)}(${columnNames(args).join(', ') || '…'})`);
      } else if (!containsSublink(args)) {
        bare.push(`${nameOf(oid)}()`);
      }
    }
    children(node).forEach(walk);
  })(tree);
  return { verdict: perRow.length > 0 ? 'per row' : 'once', perRow: [...new Set(perRow)], bare: [...new Set(bare)] };

  function columnNames(args) {
    return args.flatMap((a) => (a?.node === 'VAR' && Number(a.varlevelsup) === 0 ? [nameOfColumn(a)] : []));
  }
  function nameOfColumn(v) {
    return nameOf.column ? nameOf.column(Number(v.varattno)) : `#${v.varattno}`;
  }
}

function containsSublink(node) {
  if (node !== null && typeof node === 'object' && !Array.isArray(node) && node.node === 'SUBLINK') return true;
  return children(node).some(containsSublink);
}

// ---------------------------------------------------------------------------
// Reading a database.

const COMMANDS = { r: 'SELECT', a: 'INSERT', w: 'UPDATE', d: 'DELETE', '*': 'ALL' };

/**
 * One row per policy of `db`, outside the schemas Postgres and Supabase own:
 * `{ schema, table, policy, command, using, withCheck }`, each expression with
 * its verdict and the calls behind it. Sorted by schema, table and policy.
 */
export async function policyInventory(db) {
  const policies = (
    await db.query(
      `select n.nspname as schema, c.relname as table, p.polname as policy, p.polcmd as cmd,
              p.polrelid::int as relid, p.polqual::text as qual, p.polwithcheck::text as with_check
         from pg_policy p
         join pg_class c on c.oid = p.polrelid
         join pg_namespace n on n.oid = c.relnamespace
        where n.nspname not in ('pg_catalog', 'information_schema', 'auth', 'storage', 'extensions', 'realtime', 'supabase_migrations')
        order by n.nspname, c.relname, p.polname`,
    )
  ).rows;
  const functions = new Map(
    (await db.query(`select oid::int as oid, proname from pg_proc where oid >= ${FIRST_NORMAL_OBJECT_ID}`)).rows.map((r) => [r.oid, r.proname]),
  );
  const columns = new Map();
  for (const r of (await db.query(`select attrelid::int as relid, attnum, attname from pg_attribute where attnum > 0 and attrelid in (select polrelid from pg_policy)`)).rows) {
    columns.set(`${r.relid}:${r.attnum}`, r.attname);
  }
  return policies.map((p) => {
    const nameOf = (oid) => functions.get(oid) ?? `function ${oid}`;
    nameOf.column = (attnum) => columns.get(`${p.relid}:${attnum}`) ?? `column ${attnum}`;
    const read = (text) => classifyExpression(text === null ? null : parseNodeTree(text), nameOf);
    return {
      schema: p.schema,
      table: p.table,
      policy: p.policy,
      command: COMMANDS[p.cmd] ?? p.cmd,
      using: read(p.qual),
      withCheck: read(p.with_check),
    };
  });
}

/** The inventory of the checkout: the socle and every module, built as the tests build them. */
export async function inventory() {
  const { freshDatabase } = await import('../tests/helpers/db.ts');
  const db = await freshDatabase({ seed: false });
  try {
    return await policyInventory(db);
  } finally {
    await db.close();
  }
}

/** `schema.table policy`, the key a policy is listed under. */
export function policyKey(row) {
  return `${row.schema}.${row.table} ${row.policy}`;
}

function detail(row) {
  const parts = [];
  if (row.using.perRow.length) parts.push(`using: ${row.using.perRow.join(', ')}`);
  if (row.withCheck.perRow.length) parts.push(`check: ${row.withCheck.perRow.join(', ')}`);
  const bare = [...new Set([...row.using.bare, ...row.withCheck.bare])];
  if (bare.length) parts.push(`bare: ${bare.join(', ')}`);
  return parts.join('; ');
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const rows = await inventory();
  if (process.argv.includes('--json')) {
    console.log(JSON.stringify(rows, null, 2));
  } else {
    console.log('| schema | table | policy | command | using | with check | detail |');
    console.log('|---|---|---|---|---|---|---|');
    for (const row of rows) {
      console.log(`| ${row.schema} | ${row.table} | ${row.policy} | ${row.command} | ${row.using.verdict} | ${row.withCheck.verdict} | ${detail(row)} |`);
    }
    const perRow = rows.filter((row) => row.using.verdict === 'per row');
    console.log(`\n${rows.length} policies, ${perRow.length} whose using asks per row.`);
  }
}
