/**
 * Keeping the books, once, for every surface.
 *
 * The MCP server and the command line call these functions and bring their
 * own `Backend`. No accounting rule is in here — the schema holds them — and
 * what is here is what both surfaces would otherwise each write: codes turned
 * into ids, a product filling in a line, which open items a payment is
 * offered to.
 */

export * from './backend.js';
export * as columns from './columns.js';
export * from './format.js';
export { roundCurrency } from './rounding.js';
export * from './shared.js';
export * from './contacts.js';
export * from './documents.js';
export * from './payments.js';
