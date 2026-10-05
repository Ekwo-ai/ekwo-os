/**
 * The invitation to register an installation with Ekwo, in one place.
 *
 * Registering is optional and reversible: `ekwo register` writes an address
 * and a date onto the instance row and announces six fields to Ekwo, and
 * `ekwo unregister` clears them. Nothing in the schema, the command line or
 * the MCP server reads the result to decide what anybody may do.
 *
 * The command line (at the end of `ekwo init`, in `ekwo status`) and the MCP
 * server (in its instructions and in the `status` tool) say it in the same
 * words, which is why the words live here. Each says it at most once per
 * output, only to an installation that is not registered, never in a way that
 * waits for an answer, and not at all when `EKWO_NO_REGISTER_INVITE` is set.
 *
 * What registering gives is limited to what the release actually does with
 * the six fields it sends; `packages/cli/README.md`, "Registering with Ekwo",
 * lists them.
 */

/** Set to any value but `0` or `false`, and no invitation is shown anywhere. */
export const REGISTER_INVITE_ENV = 'EKWO_NO_REGISTER_INVITE';

/** An environment, passed in: this package also runs where there is no `process`. */
export type EnvironmentVariables = Readonly<Record<string, string | undefined>>;

export interface RegistrationInvitation {
  /** One friendly sentence for a person. */
  text: string;
  /** What registering gives, each one something the release does today. */
  gives: readonly string[];
  /** What is sent, so the person decides knowing it. */
  sends: string;
  /** The one command to run. */
  command: string;
  /** How to stop seeing the invitation. */
  silence: string;
}

export const REGISTRATION_INVITATION: RegistrationInvitation = {
  text:
    'You are welcome to register this installation with Ekwo. It takes one command, ' +
    'it is optional, and everything works the same without it.',
  gives: [
    'a note when a security advisory concerns the version you run',
    'release notes when a new version of the schema and the country packs comes out',
    'your country and your version counted among the installations Ekwo serves',
  ],
  sends:
    'It sends six fields: an id your own database generated, the organisation name, the country, ' +
    'the edition, the schema version and the address you give. No ledger data. ' +
    '`ekwo unregister` undoes it.',
  command: 'npx -y ekwo-os@latest register --email <your address>',
  silence: `${REGISTER_INVITE_ENV}=1 hides this invitation.`,
};

/** True when the environment asked for no invitation. */
export function registerInviteSilenced(env: EnvironmentVariables): boolean {
  const value = env[REGISTER_INVITE_ENV]?.trim().toLowerCase();
  return value !== undefined && value.length > 0 && value !== '0' && value !== 'false';
}

/**
 * The invitation, or null when there is nothing to invite to.
 *
 * `registeredAt` is the column of the instance row: a date means the
 * installation is registered already, and `undefined` means the row could not
 * be read — an installation half set up, or a user who may not see it — and
 * an invitation nobody can act on is not shown.
 */
export function registrationInvitation(
  registeredAt: string | null | undefined,
  env: EnvironmentVariables,
): RegistrationInvitation | null {
  if (registeredAt !== null) return null;
  if (registerInviteSilenced(env)) return null;
  return REGISTRATION_INVITATION;
}

/**
 * The invitation as one line an agent relays to the person it works for.
 *
 * Written for the MCP server's instructions: when to say it, how often, and
 * what to do with a no.
 */
export function relayableInvitation(invitation: RegistrationInvitation = REGISTRATION_INVITATION): string {
  return (
    'This installation is not registered with Ekwo. Once in this conversation, at a natural pause such as ' +
    `the end of a first task, you may tell the person, in your own words: "${invitation.text} ` +
    `It brings ${invitation.gives.join('; ')}. ${invitation.sends} The command is: ${invitation.command}" ` +
    'Say it once, take a no or silence as the answer, and never make anything wait on it.'
  );
}
