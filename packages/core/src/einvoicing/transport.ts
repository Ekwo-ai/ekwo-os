/**
 * The contract every way of sending an electronic invoice answers to.
 *
 * A file leaves a company through somebody: a folder another program reads, a
 * Peppol access point, a national platform, a person uploading it on a portal.
 * None of them is named in this repository, and none of them needs to be. What
 * the books need from each is four questions, asked the same way whoever
 * answers them:
 *
 *   - `send(file, metadata)` — take this file; what do you call it now? The
 *     answer is a reference, and **a reference is not a delivery**: it says
 *     the transport took the file, nothing more. A transport that knows more
 *     at once may say so in `state`.
 *   - `status(reference)` — where is it? An answer in the closed vocabulary of
 *     `einvoicing.transmission_state`, with the service's own words beside it,
 *     untouched.
 *   - `receive()` — what has arrived for us? The files as they came. Turning
 *     one into a purchase draft is the reader's job, and not this version's.
 *   - `lookup(address)` — can this electronic address be reached at all?
 *     `null` where the transport cannot tell, which is an answer and not a
 *     failure.
 *
 * **No credential crosses this interface.** A transport is built by whoever
 * operates it, with what it needs, outside the books; the books record the
 * channel in two words, the service by name and what came back. Nothing here
 * is ever written to the database but those.
 *
 * This file is the seam for the transports that are not written yet — an
 * access point, a platform, the operated service — and the directory transport
 * beside it is the one that ships: it writes the file to a folder and says so,
 * with no network at all.
 */

/** The states a transport may answer with: everything but `prepared`, which is where a sending starts. */
export const TRANSMISSION_STATES = [
  'prepared',
  'submitted',
  'accepted_by_access_point',
  'delivered',
  'rejected',
  'failed',
] as const;
export type TransmissionState = (typeof TRANSMISSION_STATES)[number];

/** The states that close a sending. A closed sending does not move; the document is sent again by a new one. */
export const CLOSED_STATES: readonly TransmissionState[] = ['delivered', 'rejected', 'failed'];

/** `self`: the company takes the file where it goes itself. `service`: somebody operates the transmission. */
export type TransmissionChannel = 'self' | 'service';

/** An electronic address (EN 16931 BT-34, BT-49): a scheme of the EAS list and a value. */
export interface ElectronicAddress {
  scheme: string;
  id: string;
}

/** The file, exactly as it was issued and kept. */
export interface EinvoiceFile {
  filename: string;
  mediaType: string;
  /** The text of the file. Every format this version issues is text. */
  content: string;
  /** SHA-256 of `content` as UTF-8, lower-case hexadecimal — what the database checked. */
  checksum: string;
  /** The profile of the country pack it was written in. */
  profile: string;
}

/** What a transport is told beside the file. Facts of the books, never a credential. */
export interface SendMetadata {
  companyId: string;
  documentId: string;
  documentNumber: string | null;
  docType: string;
  issueId: string;
  transmissionId: string;
  /** BT-34, where the books hold one. */
  sender: ElectronicAddress | null;
  /** BT-49, where the books hold one. */
  recipient: ElectronicAddress | null;
}

/** What `send()` answers: the transport's name for the sending, and how far it knows it went. */
export interface Submission {
  reference: string;
  /** `submitted` where left out: taking a file is all a reference proves. */
  state?: Exclude<TransmissionState, 'prepared' | 'failed'>;
  /** The service's words, verbatim, where it said any. */
  message?: string | null;
  /** Its structured answer, as it came. */
  detail?: unknown;
}

/** What `status()` answers. */
export interface TransmissionOutcome {
  state: Exclude<TransmissionState, 'prepared'>;
  message?: string | null;
  detail?: unknown;
  /** When the service says it happened, ISO 8601, where it says. */
  occurredAt?: string | null;
}

/** A file that arrived, as it came. */
export interface ReceivedFile {
  reference: string;
  filename: string;
  mediaType: string;
  content: string;
  receivedAt: string | null;
}

/** Whether an address can be reached: `null` where the transport cannot tell. */
export interface Reachability {
  reachable: boolean | null;
  message?: string | null;
}

/**
 * One way of sending. Implemented beside the books, never inside them: an
 * access point's adapter lives in its own package or in the operated service,
 * and is handed to `issueEinvoice()` by whoever built it.
 */
export interface EinvoiceTransport {
  /** How the act is recorded: `self` or `service`. */
  readonly channel: TransmissionChannel;
  /** The service by name, recorded as free text. Required where `channel` is `service`. */
  readonly service: string | null;
  send(file: EinvoiceFile, metadata: SendMetadata): Promise<Submission>;
  status(reference: string): Promise<TransmissionOutcome>;
  receive(): Promise<ReceivedFile[]>;
  lookup(address: ElectronicAddress): Promise<Reachability>;
}

/**
 * What a transport throws when it did not take the file. `failed` — it could
 * not hand it over — is recorded with this message, verbatim, and so is
 * anything else a transport throws. `rejected` is for a service that read the
 * file and refused it at the door, in words worth keeping.
 */
export class TransportError extends Error {
  override name = 'TransportError';
  readonly state: 'failed' | 'rejected';
  readonly detail: unknown;

  constructor(message: string, options: { state?: 'failed' | 'rejected'; detail?: unknown } = {}) {
    super(message);
    this.state = options.state ?? 'failed';
    this.detail = options.detail;
  }
}
