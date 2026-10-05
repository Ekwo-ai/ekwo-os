/**
 * The invitation to register, as this command line prints it.
 *
 * The words are `@ekwo-ai/core`'s, where the MCP server reads them too. This
 * file decides only the shape on a terminal: a short block, printed once by
 * the command that calls it, never followed by a question. Under `--json` the
 * same invitation is a field of the document (`registration.invitation`) and
 * the prose goes to the standard error like every other line.
 */

import { registrationInvitation, type RegistrationInvitation } from '@ekwo-ai/core';
import { cyan, dim, heading, line, note } from './ui.js';

/** What `--json` carries about registration, on `init` and `status`. */
export interface RegistrationField {
  registered: boolean;
  /** Null when registered, or when `EKWO_NO_REGISTER_INVITE` is set. */
  invitation: RegistrationInvitation | null;
}

/** The field, from the `registered_at` of the instance row. */
export function registrationField(
  registeredAt: string | null,
  env: NodeJS.ProcessEnv = process.env,
): RegistrationField {
  return { registered: registeredAt !== null, invitation: registrationInvitation(registeredAt, env) };
}

/** Prints the invitation, when there is one. */
export function printInvitation(invitation: RegistrationInvitation | null): void {
  if (invitation === null) return;
  heading('Registering with Ekwo (optional)');
  line(`  ${invitation.text}`);
  line(`  It brings ${invitation.gives.join('; ')}.`);
  line(`  ${cyan(invitation.command)}`);
  note(dim(invitation.sends));
  note(dim(invitation.silence));
}
