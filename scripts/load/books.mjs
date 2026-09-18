/**
 * Books at volume, made from a year the engine really posted.
 *
 * Every test of this repository books a handful of documents, and the largest
 * golden scenario holds fifteen. A plan chosen over fifteen rows says nothing
 * about the plan chosen over half a million, so `tests/load/` needs a company
 * with ten thousand documents in it — and a hundred thousand, by hand, against
 * a real Postgres.
 *
 * ---------------------------------------------------------------------------
 * Where the rows come from, and why not from `post_document()` each time.
 *
 * `post_document()` takes about seven milliseconds a document on PGlite. Ten
 * thousand of them is more than a minute before the first plan is read, and a
 * hundred thousand is a quarter of an hour; a test nobody can afford to run is
 * a test nobody runs. Inserting invented ledger rows directly is fast and
 * proves nothing: rows written by a generator balance because the generator
 * says so, carry the declaration boxes the generator thought of, and drift
 * from the engine the day the engine learns something.
 *
 * So the two are combined, and the line between them is exact:
 *
 *   - **the template is posted by the engine.** The caller books one year
 *     through `post_document()`, `post_payment()` and `reconcile()` — in the
 *     tests, the golden scenario of a pack — and every ledger row of that
 *     year is one the real functions wrote;
 *   - **the volume is that year, copied.** `multiplyBooks()` clones the
 *     documents, their lines, the entries, the ledger lines, the payments and
 *     the matchings of the template, as many times as it takes, with new
 *     identifiers and the dates moved back by whole financial years. A copy
 *     is balanced because its original was, carries the boxes, the tax point
 *     and the maturity the engine gave its original, and inherits whatever
 *     the engine starts writing tomorrow — the column list is read from the
 *     catalogue, not written here.
 *
 * Nothing in this file knows a country, a chart or a tax: the pack is whatever
 * the template was booked with.
 *
 * What a copy does **not** go through is the triggers and the foreign keys:
 * the copy runs under `session_replication_role = replica`, which is how a
 * bulk load is done and the reason it is fast. `checkCoherence()` is the other
 * half of that bargain — every foreign key between the copied tables is
 * re-checked by an anti-join once the load is over, and every entry is checked
 * to balance.
 *
 * ---------------------------------------------------------------------------
 * Deterministic: the same seed over the same template gives the same books —
 * the same names, dates, amounts and numbers. Identifiers are derived from
 * the template's own, which `gen_random_uuid()` chose, so they are stable
 * within a database and not across two.
 *
 * No real data: the contact names are syllables drawn by a seeded generator,
 * and the amounts are the template's.
 */

/** The tables a year of bookkeeping writes, in the order they are copied. */
export const COPIED_TABLES = [
  'fiscal_years',
  'contacts',
  'documents',
  'document_lines',
  'entries',
  'entry_lines',
  'payments',
  'reconciliations',
];

/**
 * Tables the engine writes while booking that a copy deliberately leaves
 * alone: counters, which the copies do not draw from, and the audit trail,
 * which records acts and no act took place. `tests/load/` fails when a replay
 * writes to a table that is in neither list, which is the day this generator
 * has to learn about it.
 */
export const NOT_COPIED_TABLES = ['audit_log', 'journal_sequences', 'matching_sequences'];

/** Which copy index a table is keyed by: its own, its year's, or its contact set's. */
const COPY_KEY = { fiscal_years: 'year', contacts: 'contacts' };

/** mulberry32: small, seedable, and the same on every engine. */
export function generator(seed) {
  let state = seed >>> 0;
  return () => {
    state = (state + 0x6d2b79f5) >>> 0;
    let t = state;
    t = Math.imul(t ^ (t >>> 15), t | 1);
    t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

const ONSETS = ['b', 'br', 'd', 'dr', 'f', 'g', 'k', 'l', 'm', 'n', 'p', 'pr', 'r', 's', 'st', 't', 'tr', 'v', 'z'];
const VOWELS = ['a', 'e', 'i', 'o', 'u', 'ia', 'eo', 'ou'];
const CODAS = ['', '', 'l', 'n', 'r', 's', 'x', 'nd', 'rt'];
/**
 * Words several contacts share, on purpose. `suggest_contacts()` counts how
 * many contacts a piece of evidence reaches, and books in which no two names
 * had a word in common would never exercise that count.
 */
const SHARED = ['holding', 'services', 'trading', 'group', 'works', 'partners', 'supply', 'studio'];

function word(random) {
  const syllables = 2 + Math.floor(random() * 2);
  let out = '';
  for (let i = 0; i < syllables; i += 1) {
    out += ONSETS[Math.floor(random() * ONSETS.length)];
    out += VOWELS[Math.floor(random() * VOWELS.length)];
    out += CODAS[Math.floor(random() * CODAS.length)];
  }
  return out;
}

/** `count` invented names: two made-up words, and a shared one for a third of them. */
export function inventedNames(count, seed) {
  const random = generator(seed);
  const names = [];
  for (let i = 0; i < count; i += 1) {
    const parts = [word(random), word(random)];
    if (random() < 0.34) parts.push(SHARED[Math.floor(random() * SHARED.length)]);
    names.push(parts.map((p) => p.charAt(0).toUpperCase() + p.slice(1)).join(' '));
  }
  return names;
}

async function columnsOf(db, table) {
  return db.query(
    `select a.attname as name, format_type(a.atttypid, a.atttypmod) as type
       from pg_attribute a
      where a.attrelid = ('public.' || $1)::regclass
        and a.attnum > 0 and not a.attisdropped and a.attgenerated = ''
      order by a.attnum`,
    [table],
  );
}

/** Columns of `table` that point at the `id` of another copied table. */
async function referencesOf(db, table) {
  const found = await db.query(
    `select att.attname as name, target.relname as target
       from pg_constraint c
       join pg_class target on target.oid = c.confrelid
       cross join lateral unnest(c.conkey, c.confkey) as k(col, ref)
       join pg_attribute att on att.attrelid = c.conrelid and att.attnum = k.col
       join pg_attribute ref on ref.attrelid = c.confrelid and ref.attnum = k.ref
      where c.contype = 'f'
        and c.conrelid = ('public.' || $1)::regclass
        and ref.attname = 'id'
        and target.relname = any ($2::text[])`,
    [table, COPIED_TABLES],
  );
  return new Map(found.map((row) => [row.name, row.target]));
}

/** Text columns under a unique index: a copy has to differ there or be refused. */
async function uniqueTextColumnsOf(db, table) {
  const found = await db.query(
    `select distinct att.attname as name
       from pg_index i
       cross join lateral unnest(i.indkey::int2[]) as k(col)
       join pg_attribute att on att.attrelid = i.indrelid and att.attnum = k.col
      where i.indrelid = ('public.' || $1)::regclass
        and i.indisunique
        and att.atttypid = 'text'::regtype`,
    [table],
  );
  return new Set(found.map((row) => row.name));
}

/**
 * Multiplies the posted books of one company.
 *
 * @param db       the CLI's `SqlClient`, or anything with its `query`, `exec`
 *                 and `transaction`
 * @param options  companyId · documents (target, template included) · years
 *                 (how many financial years the copies spread over, the
 *                 template's being the latest) · contacts (target) · seed
 */
export async function multiplyBooks(db, options) {
  const { companyId, documents, years, contacts, seed } = options;

  const [template] = await db.query(
    `select (select count(*)::int from documents where company_id = $1) as documents,
            (select count(*)::int from contacts where company_id = $1) as contacts,
            (select count(*)::int from fiscal_years where company_id = $1) as years,
            (select min(start_date)::text from fiscal_years where company_id = $1) as year_start,
            (select (max(end_date) - min(start_date) + 1)::int
               from fiscal_years where company_id = $1) as year_days`,
    [companyId],
  );
  if (template.documents === 0) {
    throw new Error('this company holds no document: book a year through the engine first, then multiply it');
  }
  if (template.years !== 1) {
    throw new Error(`the template is one financial year, and this company has ${template.years}`);
  }

  // Copy 0 is the template itself. A copy belongs to year `k % years` —
  // year 0 being the template's — and draws its contacts from set
  // `k % contactSets`, set 0 being the template's own contacts.
  const copies = Math.max(0, Math.ceil(documents / template.documents) - 1);
  const contactSets = Math.max(1, Math.ceil(contacts / template.contacts));
  const names = inventedNames((contactSets - 1) * template.contacts, seed);

  const keyOf = (table) => {
    const key = COPY_KEY[table];
    if (key === 'year') return `(k.k % ${years})`;
    if (key === 'contacts') return `(k.k % ${contactSets})`;
    return 'k.k';
  };
  // Key 0 is the original row; any other key is a new identifier derived from
  // the seed, the table the row lives in, the key and the original.
  const remap = (column, table) =>
    `case when ${column} is null or ${keyOf(table)} = 0 then ${column}
          else md5('${seed}:${table}:' || ${keyOf(table)} || ':' || ${column}::text)::uuid end`;

  // `set local`, inside one transaction: the setting ends with the load
  // whatever happens to it, and it holds through a pooler that hands every
  // statement outside a transaction to a different session.
  await db.transaction(async (tx) => {
    await tx.exec(`set local session_replication_role = replica;`);
    for (const table of COPIED_TABLES) {
      const columns = await columnsOf(tx, table);
      const references = await referencesOf(tx, table);
      const unique = await uniqueTextColumnsOf(tx, table);

      const expressions = columns.map(({ name, type }) => {
        const column = `t.${name}`;
        if (name === 'id') return remap(column, table);
        if (references.has(name)) return remap(column, references.get(name));
        if (table === 'contacts' && name === 'name') return `n.name`;
        if (type === 'date') return `(${column} - (k.k % ${years}) * ${template.year_days})`;
        // A matching letter is shared by the lines it matches and by nobody
        // else, so a copy gets its own — like a number under a unique index.
        if (unique.has(name) || name === 'matching_number') {
          return `${column} || '~' || ${keyOf(table)}`;
        }
        return column;
      });

      // How many times this table is copied: once per year, once per set of
      // contacts, or once per copy of the books.
      const key = COPY_KEY[table];
      const series =
        key === 'year' ? Math.min(years - 1, copies) : key === 'contacts' ? contactSets - 1 : copies;
      if (series === 0) continue;

      const namesJoin =
        table === 'contacts'
          ? `join (select o.id, row_number() over (order by o.name, o.contact_type) as position
                     from contacts o where o.company_id = $1) p on p.id = t.id
             join unnest($2::text[]) with ordinality as n(name, position)
               on n.position = (k.k - 1) * ${template.contacts} + p.position`
          : '';

      await tx.query(
        `insert into ${table} (${columns.map((c) => c.name).join(', ')})
         select ${expressions.join(',\n                ')}
           from ${table} t
           cross join generate_series(1, ${series}) as k(k)
           ${namesJoin}
          where t.company_id = $1`,
        table === 'contacts' ? [companyId, names] : [companyId],
      );
    }
  });

  return {
    copies,
    contactSets,
    years,
    yearStart: template.year_start,
    yearDays: template.year_days,
  };
}

/**
 * One month of bank statement, for `suggest_contacts()` to read.
 *
 * Each line carries the name of a contact the way a bank prints it — upper
 * case, a word dropped or a reference glued on — so the suggestion has
 * something to work out. The amounts are drawn, not read from the ledger:
 * what is measured here is who the line could be, not what it pays.
 */
export async function bankStatementMonth(db, options) {
  const { companyId, lines, seed } = options;
  const random = generator(seed ^ 0x5bd1e995);

  const contacts = await db.query(
    `select name from contacts where company_id = $1 and active order by name, id`,
    [companyId],
  );
  const [company] = await db.query(
    `select c.currency_code,
            (select max(f.start_date)::text from fiscal_years f
              where f.company_id = c.id) as month_start
       from companies c where c.id = $1`,
    [companyId],
  );

  const [account] = await db.query(
    `insert into bank_accounts (company_id, name, currency_code)
     values ($1, 'Generated current account', $2) returning id`,
    [companyId, company.currency_code],
  );
  const [statement] = await db.query(
    `insert into bank_statements (company_id, bank_account_id, name, statement_date)
     values ($1, $2, 'Generated statement', ($3::date + interval '1 month' - interval '1 day')::date)
     returning id`,
    [companyId, account.id, company.month_start],
  );

  const counterparts = [];
  const amounts = [];
  const days = [];
  for (let i = 0; i < lines; i += 1) {
    const name = contacts[Math.floor(random() * contacts.length)].name;
    const words = name.split(' ');
    const shape = random();
    let printed = name.toUpperCase();
    if (shape < 0.3 && words.length > 1) printed = words.slice(0, -1).join(' ').toUpperCase();
    else if (shape < 0.5) printed = `${name.toUpperCase()} REF ${Math.floor(random() * 1e6)}`;
    counterparts.push(printed);
    amounts.push((Math.round((random() * 4000 - 2000) * 100) / 100 || 1).toFixed(2));
    days.push(Math.floor(random() * 28));
  }

  await db.query(
    `insert into bank_transactions (company_id, statement_id, bank_account_id, sequence,
                                    transaction_date, amount, currency_code, counterpart_name,
                                    description)
     select $1, $2, $3, (x.position * 10)::int, $4::date + x.day, x.amount, $5, x.counterpart,
            'Transfer ' || x.counterpart
       from unnest($6::text[], $7::numeric[], $8::int[]) with ordinality
            as x(counterpart, amount, day, position)`,
    [companyId, statement.id, account.id, company.month_start, company.currency_code,
     counterparts, amounts, days],
  );

  return { statementId: statement.id, bankAccountId: account.id, lines };
}

/**
 * What the triggers and the foreign keys would have said, asked afterwards.
 *
 * Returns the list of what is wrong, empty when nothing is. Every foreign key
 * that leaves a copied table is re-checked — all of its columns, so a copy
 * that landed in the wrong company is caught too — and every entry balances.
 */
export async function checkCoherence(db, companyId) {
  const problems = [];
  const keys = await db.query(
    `select c.conname as name, source.relname as source, target.relname as target,
            (select string_agg(format('s.%I = t.%I', sa.attname, ta.attname), ' and ')
               from unnest(c.conkey, c.confkey) as k(col, ref)
               join pg_attribute sa on sa.attrelid = c.conrelid and sa.attnum = k.col
               join pg_attribute ta on ta.attrelid = c.confrelid and ta.attnum = k.ref) as condition,
            (select string_agg(format('s.%I is not null', sa.attname), ' and ')
               from unnest(c.conkey) as k(col)
               join pg_attribute sa on sa.attrelid = c.conrelid and sa.attnum = k.col) as present
       from pg_constraint c
       join pg_class source on source.oid = c.conrelid
       join pg_class target on target.oid = c.confrelid
      where c.contype = 'f' and source.relname = any ($1::text[])
      order by source.relname, c.conname`,
    [COPIED_TABLES],
  );
  for (const key of keys) {
    const [orphans] = await db.query(
      `select count(*)::int as n from ${key.source} s
        where s.company_id = $1 and ${key.present}
          and not exists (select 1 from ${key.target} t where ${key.condition})`,
      [companyId],
    );
    if (orphans.n > 0) problems.push(`${key.source}.${key.name}: ${orphans.n} rows point at nothing`);
  }

  const [unbalanced] = await db.query(
    `select count(*)::int as n from (
       select l.entry_id from entry_lines l where l.company_id = $1
        group by l.entry_id having sum(l.debit) <> sum(l.credit)) x`,
    [companyId],
  );
  if (unbalanced.n > 0) problems.push(`${unbalanced.n} entries do not balance`);

  const [totals] = await db.query(
    `select count(*)::int as n
       from entries e
       left join (select l.entry_id, sum(l.debit) as debit, sum(l.credit) as credit
                    from entry_lines l where l.company_id = $1 group by l.entry_id) s
         on s.entry_id = e.id
      where e.company_id = $1
        and (e.total_debit <> coalesce(s.debit, 0) or e.total_credit <> coalesce(s.credit, 0))`,
    [companyId],
  );
  if (totals.n > 0) problems.push(`${totals.n} entries carry totals their lines do not add up to`);

  return problems;
}

/**
 * A figure of the books that does not depend on any identifier: two databases
 * loaded from the same template with the same seed give the same one.
 */
export async function fingerprint(db, companyId) {
  const [row] = await db.query(
    `select md5(string_agg(x.line, '|' order by x.line)) as fingerprint
       from (
         select concat_ws(';', e.entry_date, e.number, a.code, l.sequence, l.debit, l.credit,
                          l.declaration_box, l.date_maturity, c.name) as line
           from entry_lines l
           join entries e on e.id = l.entry_id
           join accounts a on a.id = l.account_id
           left join contacts c on c.id = l.contact_id
          where l.company_id = $1) x`,
    [companyId],
  );
  return row.fingerprint;
}
