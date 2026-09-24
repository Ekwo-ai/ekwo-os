/**
 * The same server over HTTP: the Streamable HTTP transport of MCP, stateless.
 *
 * `bin.ts` is a process a client starts on its own machine, and it reads who
 * it acts as from its environment. A server somebody reaches by URL is the
 * other shape: one process answers many people, so **who a request acts as
 * is decided per request**, by whatever put the server on the network — its
 * own sign-in, its own tokens — and handed in here as a connection. This
 * file knows nothing about how that host authenticates anybody. It takes a
 * request and the connection that request is allowed to use, and answers.
 *
 * ## Stateless, in JSON
 *
 * Each request builds a server, answers, and closes it. Nothing is kept
 * between two requests — no session id, no stream, no cache of whose books
 * were open — so a host can run it on a function platform, behind a load
 * balancer, or on one machine, and two people never share a thing. The
 * answers are plain JSON (`enableJsonResponse`): every tool of this server
 * answers once, and an open event stream would hold a connection for nothing.
 * A `GET` — the stream a client may open for messages the server sends on its
 * own — is answered `405`, which the protocol allows and which is the truth:
 * this server never speaks first.
 *
 * ## What a connection may be
 *
 *   - **A person's session on the instance**: the project address, its
 *     publishable key and an access token. Row level security decides, as it
 *     does for that person in a browser.
 *   - **A key of Ekwo OS**: the same two, and a key `create_api_key()` issued.
 *     It travels in `X-Ekwo-Api-Key`, the core's pre-request hook presents it
 *     (decision 0062), and the caller is on the key's one company with the
 *     key's capabilities.
 *   - **A backend already built**, for a host that reaches the database some
 *     other way — and for the tests, which run the real schema in PGlite.
 *
 * A `service_role` key is refused in every slot it could arrive in, as it is
 * on stdio: this server has no privilege of its own, over any transport.
 */

import type { IncomingMessage, ServerResponse } from 'node:http';
import { WebStandardStreamableHTTPServerTransport } from '@modelcontextprotocol/sdk/server/webStandardStreamableHttp.js';
import { isServiceRoleKey, serviceRoleRefusal } from '@ekwo-ai/core';
import { EkwoMcpError, type Backend } from './backend.js';
import { postgrestBackend } from './postgrest.js';
import { assertSchemaSupported } from './schema.js';
import { buildServer } from './server.js';
import { installedModules } from './tools/modules.js';

/** Who one request acts as, over PostgREST. Exactly one of the two credentials. */
export interface HttpConnection {
  /** The project, `https://<ref>.supabase.co`. */
  supabaseUrl: string;
  /** Its publishable (anon) key. Never the `service_role` key. */
  anonKey: string;
  /** A person's access token on that project. */
  accessToken?: string | undefined;
  /** A key of Ekwo OS, issued on one company of that project. */
  apiKey?: string | undefined;
}

export interface HttpHandlerOptions {
  /**
   * The modules whose tools are offered. Left out, the database is asked on
   * every request that needs to know — a host that knows already, or caches
   * the answer, passes it and saves the round trip.
   */
  modules?: readonly string[] | undefined;
  /** The `fetch` the PostgREST backend uses. A host or a test may hand its own. */
  fetch?: typeof globalThis.fetch | undefined;
}

const SURFACE = 'this server';
const SIGN_IN = 'connect it with a person\'s session or with a key of Ekwo OS';

/** A JSON-RPC error on the wire, for the refusals that come before the protocol. */
function rpcError(status: number, code: number, message: string, id: unknown = null): Response {
  return new Response(JSON.stringify({ jsonrpc: '2.0', error: { code, message }, id }), {
    status,
    headers: { 'Content-Type': 'application/json' },
  });
}

/**
 * Checks a connection and says what is wrong with it, without a network.
 *
 * The three refusals of `readConfig`, for a connection that did not come from
 * an environment: nothing to act as, two things to act as, and a
 * `service_role` key in any of the three slots.
 */
export function checkConnection(connection: HttpConnection): void {
  const { supabaseUrl, anonKey, accessToken, apiKey } = connection;
  if (supabaseUrl.trim().length === 0 || anonKey.trim().length === 0) {
    throw new EkwoMcpError('missing_configuration: a connection needs the project address and its publishable key.');
  }
  if (isServiceRoleKey(anonKey)) {
    throw new EkwoMcpError(serviceRoleRefusal('the publishable key of the connection', 'apikey', SURFACE, SIGN_IN));
  }
  const hasToken = accessToken !== undefined && accessToken.length > 0;
  const hasKey = apiKey !== undefined && apiKey.length > 0;
  if (hasToken && isServiceRoleKey(accessToken)) {
    throw new EkwoMcpError(serviceRoleRefusal('the access token of the connection', 'authorization', SURFACE, SIGN_IN));
  }
  if (hasKey && isServiceRoleKey(apiKey)) {
    throw new EkwoMcpError(serviceRoleRefusal('the key of the connection', 'apikey', SURFACE, SIGN_IN));
  }
  if (hasToken === hasKey) {
    throw new EkwoMcpError(
      hasToken
        ? 'two_credentials: a connection acts as a person or as a key of Ekwo OS, never as both at once.'
        : 'missing_credentials: a connection needs a person\'s access token or a key of Ekwo OS. This server has no identity of its own.',
    );
  }
}

/** The backend a connection describes. The caller closes it. */
export async function openHttpBackend(
  connection: HttpConnection,
  options: { fetch?: typeof globalThis.fetch | undefined } = {},
): Promise<Backend> {
  checkConnection(connection);
  return postgrestBackend({
    supabaseUrl: connection.supabaseUrl,
    anonKey: connection.anonKey,
    accessToken: connection.apiKey === undefined ? connection.accessToken : undefined,
    apiKey: connection.apiKey,
    fetch: options.fetch,
  });
}

/** The JSON-RPC messages of a body, whether it held one or a batch. */
function messagesOf(body: unknown): { method?: unknown; id?: unknown }[] {
  if (Array.isArray(body)) return body as { method?: unknown }[];
  if (body !== null && typeof body === 'object') return [body as { method?: unknown }];
  return [];
}

/** Methods whose answer depends on which tools this installation carries. */
const NEEDS_MODULES = new Set(['tools/list', 'tools/call']);

/**
 * Answers one HTTP request of the MCP Streamable HTTP transport.
 *
 * `connection` is who this request acts as, decided by the host before it
 * calls this. Nothing about it is remembered once the response is built.
 */
export async function handleHttpRequest(
  request: Request,
  connection: HttpConnection | Backend,
  options: HttpHandlerOptions = {},
): Promise<Response> {
  if (request.method === 'GET' || request.method === 'DELETE') {
    // No stream to open and no session to end: every answer is in the
    // response to the request that asked for it.
    return new Response(null, { status: 405, headers: { Allow: 'POST' } });
  }
  if (request.method !== 'POST') {
    return new Response(null, { status: 405, headers: { Allow: 'POST' } });
  }

  let body: unknown;
  try {
    body = await request.json();
  } catch {
    return rpcError(400, -32700, 'Parse error: the body is not JSON.');
  }
  const messages = messagesOf(body);
  const methods = new Set(messages.map((message) => message.method));
  const firstId = messages.find((message) => message.id !== undefined)?.id ?? null;

  let backend: Backend;
  const owned = !isBackend(connection);
  try {
    backend = isBackend(connection) ? connection : await openHttpBackend(connection, { fetch: options.fetch });
  } catch (error) {
    // A connection the host built wrong, or a token the instance refused.
    // The host decided this request may act; the database disagreeing is
    // still an answer, and it goes back as one.
    return rpcError(200, -32001, error instanceof Error ? error.message : String(error), firstId);
  }

  try {
    if (methods.has('initialize')) {
      // The one moment a client is told what this server is, so the moment a
      // database older than it is refused by name. On stdio this is the start
      // of the process; here there is no such thing.
      try {
        await assertSchemaSupported(backend);
      } catch (error) {
        return rpcError(200, -32002, error instanceof Error ? error.message : String(error), firstId);
      }
    }

    const needsModules = [...methods].some((method) => typeof method === 'string' && NEEDS_MODULES.has(method));
    const modules = options.modules ?? (needsModules ? await installedModules(backend) : []);

    const server = buildServer(backend, { modules });
    const transport = new WebStandardStreamableHTTPServerTransport({
      sessionIdGenerator: undefined,
      enableJsonResponse: true,
    });
    try {
      await server.connect(transport);
      return await transport.handleRequest(request, { parsedBody: body });
    } finally {
      await server.close().catch(() => {});
    }
  } finally {
    if (owned) await backend.close().catch(() => {});
  }
}

function isBackend(value: HttpConnection | Backend): value is Backend {
  return typeof (value as Backend).select === 'function';
}

// ---------------------------------------------------------------------------
// node:http, for a host that is not a function platform
// ---------------------------------------------------------------------------


/**
 * The same handler for `node:http` (and anything built on it).
 *
 * The request is read into a web `Request`, answered by `handleHttpRequest`,
 * and the `Response` written back — one path, whichever server a host runs.
 * `origin` is the address this server is reached at, which `node:http` does
 * not know: `https://mcp.example.org`.
 */
export async function handleNodeRequest(
  req: IncomingMessage,
  res: ServerResponse,
  connection: HttpConnection | Backend,
  options: HttpHandlerOptions & { origin: string },
): Promise<void> {
  const chunks: Buffer[] = [];
  for await (const chunk of req) chunks.push(typeof chunk === 'string' ? Buffer.from(chunk) : (chunk as Buffer));
  const headers = new Headers();
  for (const [name, value] of Object.entries(req.headers)) {
    if (value === undefined) continue;
    headers.set(name, Array.isArray(value) ? value.join(', ') : value);
  }
  const method = req.method ?? 'GET';
  const request = new Request(new URL(req.url ?? '/', options.origin), {
    method,
    headers,
    ...(method === 'GET' || method === 'HEAD' ? {} : { body: Buffer.concat(chunks) }),
  });
  const response = await handleHttpRequest(request, connection, options);
  res.statusCode = response.status;
  response.headers.forEach((value, name) => res.setHeader(name, value));
  res.end(Buffer.from(await response.arrayBuffer()));
}
