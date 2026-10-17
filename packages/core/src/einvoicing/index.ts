/**
 * Electronic invoicing: the file of a posted sale, kept, and sent through a
 * transport the caller brings. The schema is the `einvoicing` module's; the
 * formats are the bricks of `packages/formats/`; the transports are the
 * contract in `transport.ts`, and one of them — a folder — ships. A fiscal
 * record — the chained record a country's fiscalisation regime requires — is
 * a second artefact of the same document, in `fiscalisation.ts`.
 */

export * from './transport.js';
export * from './directory.js';
export * from './formats.js';
export * from './issue.js';
export * from './fiscalisation.js';
export * from './peppol.js';
