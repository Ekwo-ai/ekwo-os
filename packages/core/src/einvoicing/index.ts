/**
 * Electronic invoicing: the file of a posted sale, kept, and sent through a
 * transport the caller brings. The schema is the `einvoicing` module's; the
 * formats are the bricks of `packages/formats/`; the transports are the
 * contract in `transport.ts`, and one of them — a folder — ships.
 */

export * from './transport.js';
export * from './directory.js';
export * from './formats.js';
export * from './issue.js';
