/**
 * Who a surface acts as — and the one key none of them accepts.
 *
 * The MCP server and the command line both sign in as a person and let row
 * level security decide from there. Both are handed keys by somebody pasting
 * from a dashboard, and both have to refuse the same paste: a `service_role`
 * key. It would work — that is the problem. Every policy in the schema would
 * be bypassed, and a tool that can read every company of an installation is
 * not the thing anybody asked for.
 *
 * This lived in the MCP server. The command line needs the same test and the
 * same sentence, so it moved here and both read it; like `refusal.ts`, this
 * file imports nothing.
 */

/** The variables a surface reads its user from. One spelling, for every surface. */
export const IDENTITY_ENV = {
  supabaseUrl: 'SUPABASE_URL',
  anonKey: 'SUPABASE_ANON_KEY',
  email: 'EKWO_EMAIL',
  password: 'EKWO_PASSWORD',
  accessToken: 'EKWO_ACCESS_TOKEN',
} as const;

/**
 * True when a key is, or claims to be, a `service_role` key.
 *
 * Both shapes Supabase has issued: the signed JWT whose payload carries
 * `"role": "service_role"`, and the newer `sb_secret_…`. Neither is a mistake
 * we should let an operator make by pasting the wrong line of the dashboard.
 */
export function isServiceRoleKey(key: string): boolean {
  if (key.startsWith('sb_secret_')) return true;
  const parts = key.split('.');
  if (parts.length !== 3 || parts[1] === undefined) return false;
  try {
    const payload = JSON.parse(Buffer.from(parts[1], 'base64url').toString('utf8')) as {
      role?: unknown;
    };
    return payload.role === 'service_role';
  } catch {
    return false;
  }
}

/** Where a key was put, which decides what the refusal has to explain. */
export type KeySlot = 'apikey' | 'authorization';

/**
 * The refusal, word for word, for whichever surface met the key.
 *
 * There are two doors and not one. The `apikey` slot is the obvious paste. The
 * `Authorization` header is the quiet one: PostgREST takes the role from that
 * header and not from `apikey`, so a service_role token put there overrides a
 * perfectly good anon key sitting next to it.
 *
 * `where` is what the operator typed — a variable, a flag — and `surface` is
 * who is speaking: `this server`, `this command line`. `signIn` is how that
 * surface gets a real session instead.
 */
export function serviceRoleRefusal(
  where: string,
  slot: KeySlot,
  surface: string,
  signIn: string,
): string {
  if (slot === 'apikey') {
    return `service_role_refused: ${where} holds a service_role key. That key bypasses every row level security policy, so ${surface} would answer for companies its user was never invited to. Use the anon (publishable) key and sign in as a user.`;
  }
  return `service_role_refused: ${where} holds a service_role key. It travels in the Authorization header, which is where PostgREST reads the role from, so it would bypass every row level security policy and ${surface} would answer for companies its user was never invited to. Use a session token for a real user — ${signIn}.`;
}
