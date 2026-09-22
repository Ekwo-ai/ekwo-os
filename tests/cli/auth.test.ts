/**
 * Creating the first administrator through Supabase Auth.
 *
 * `fetch` is injected, so every branch is exercised without a project: the
 * account created with a password, the address that already has an account,
 * the invite link when no password is given, and the refusal.
 */

import { describe, expect, it } from 'vitest';
import { adminHeaders, createAuthUser, findAuthUserByEmail } from '../../packages/cli/src/index.js';
import { fakeFetch } from './helpers.js';

const supabaseUrl = 'https://abcdefghijklmnopqrst.supabase.co';
const serviceRoleKey = 'service-role-key-for-the-test';
const id = '11111111-2222-3333-4444-555555555555';

describe('createAuthUser', () => {
  it('creates a confirmed account when a password is given', async () => {
    const { fetchImpl, calls } = fakeFetch((url) =>
      url.endsWith('/auth/v1/admin/users')
        ? { status: 200, body: { id, email: 'first@example.test' } }
        : undefined,
    );

    const user = await createAuthUser({
      supabaseUrl,
      serviceRoleKey,
      email: 'first@example.test',
      password: 'a-long-enough-password',
      fetchImpl,
    });

    expect(user).toEqual({ id, email: 'first@example.test', created: true });
    expect(calls[0]?.url).toBe(`${supabaseUrl}/auth/v1/admin/users`);
    expect(calls[0]?.body).toEqual({
      email: 'first@example.test',
      password: 'a-long-enough-password',
      // Created confirmed, so the administrator can sign in at once.
      email_confirm: true,
    });
  });

  it('falls back to a lookup when the address already has an account', async () => {
    const { fetchImpl } = fakeFetch((url) => {
      if (url.endsWith('/admin/users')) {
        return { status: 422, body: { error_code: 'email_exists', msg: 'Email already exists' } };
      }
      if (url.includes('/admin/users?')) {
        return { status: 200, body: { users: [{ id, email: 'first@example.test' }] } };
      }
      return undefined;
    });

    const user = await createAuthUser({
      supabaseUrl,
      serviceRoleKey,
      email: 'first@example.test',
      password: 'a-long-enough-password',
      fetchImpl,
    });

    // Not an error: this is what makes `ekwo init` safe to run twice.
    expect(user).toEqual({ id, email: 'first@example.test', created: false });
  });

  it('generates an invite link when no password is given', async () => {
    const { fetchImpl, calls } = fakeFetch((url) =>
      url.endsWith('/admin/generate_link')
        ? {
            status: 200,
            body: {
              user_id: id,
              action_link: 'https://abcdefghijklmnopqrst.supabase.co/auth/v1/verify?token=abc',
            },
          }
        : undefined,
    );

    const user = await createAuthUser({
      supabaseUrl,
      serviceRoleKey,
      email: 'first@example.test',
      fetchImpl,
    });

    expect(user.id).toBe(id);
    expect(user.actionLink).toContain('/auth/v1/verify?token=');
    expect(calls[0]?.body).toEqual({ type: 'invite', email: 'first@example.test' });
  });

  it('raises with what Supabase said when it refuses', async () => {
    const { fetchImpl } = fakeFetch(() => ({
      status: 401,
      body: { message: 'Invalid API key' },
    }));

    await expect(
      createAuthUser({
        supabaseUrl,
        serviceRoleKey: 'wrong',
        email: 'first@example.test',
        password: 'a-long-enough-password',
        fetchImpl,
      }),
    ).rejects.toThrow(/auth_create_failed: Invalid API key/);
  });
});

describe('findAuthUserByEmail', () => {
  it('matches regardless of case and returns nothing when absent', async () => {
    const { fetchImpl } = fakeFetch(() => ({
      status: 200,
      body: { users: [{ id, email: 'First@Example.test' }] },
    }));

    await expect(
      findAuthUserByEmail({ supabaseUrl, serviceRoleKey, email: 'first@example.test', fetchImpl }),
    ).resolves.toMatchObject({ id });

    const { fetchImpl: empty } = fakeFetch(() => ({ status: 200, body: { users: [] } }));
    await expect(
      findAuthUserByEmail({
        supabaseUrl,
        serviceRoleKey,
        email: 'first@example.test',
        fetchImpl: empty,
      }),
    ).resolves.toBeUndefined();
  });
});

describe('the two forms of the secret key', () => {
  /** A GoTrue that answers like the gateway: the key on `apikey`, and a Bearer only if it is a JWT. */
  function gateway(): {
    fetchImpl: (url: string, init?: RequestInit) => Promise<Response>;
    seen: Record<string, string>[];
  } {
    const seen: Record<string, string>[] = [];
    const fetchImpl = async (_url: string, init?: RequestInit): Promise<Response> => {
      const headers = { ...(init?.headers as Record<string, string>) };
      seen.push(headers);
      const bearer = headers['Authorization']?.replace(/^Bearer /, '');
      // What the platform does with a key of the newer form presented as a JWT.
      if (bearer !== undefined && !bearer.startsWith('eyJ')) {
        return new Response(JSON.stringify({ msg: 'invalid JWT: unable to parse or verify signature' }), { status: 401 });
      }
      return new Response(JSON.stringify({ id, email: 'first@example.test' }), { status: 200 });
    };
    return { fetchImpl, seen };
  }

  // Built at run time so that no string in this file has the shape of a real key.
  const FAKE_SECRET_KEY = `sb_secret_${'a'.repeat(22)}_${'b'.repeat(8)}`;

  it('sends a secret key of the newer form on apikey alone, never as a Bearer', async () => {
    const { fetchImpl, seen } = gateway();
    const user = await createAuthUser({
      supabaseUrl,
      serviceRoleKey: FAKE_SECRET_KEY,
      email: 'first@example.test',
      password: 'a-long-enough-password',
      fetchImpl,
    });
    expect(user.id).toBe(id);
    expect(seen[0]?.['apikey']).toBe(FAKE_SECRET_KEY);
    expect(seen[0]?.['Authorization']).toBeUndefined();
  });

  it('keeps sending a legacy service_role JWT both ways', async () => {
    const { fetchImpl, seen } = gateway();
    const legacy = 'eyJhbGciOiJIUzI1NiJ9.eyJyb2xlIjoic2VydmljZV9yb2xlIn0.signature';
    const user = await createAuthUser({
      supabaseUrl,
      serviceRoleKey: legacy,
      email: 'first@example.test',
      password: 'a-long-enough-password',
      fetchImpl,
    });
    expect(user.id).toBe(id);
    expect(seen[0]).toMatchObject({ apikey: legacy, Authorization: `Bearer ${legacy}` });
  });

  it('uses the same headers to look an account up', async () => {
    const { fetchImpl, seen } = gateway();
    await findAuthUserByEmail({ supabaseUrl, serviceRoleKey: 'sb_secret_x', email: 'first@example.test', fetchImpl });
    expect(seen[0]?.['Authorization']).toBeUndefined();
    expect(adminHeaders('sb_secret_x')).toEqual({ apikey: 'sb_secret_x', 'Content-Type': 'application/json' });
  });
});
