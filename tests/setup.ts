import { afterAll } from 'vitest';
import { stillOpen } from './helpers/db.js';

// A database a file leaves open holds its whole heap until the worker exits.
// The file fails, by name, rather than the worker growing until something
// stops it; and what it left open is closed, so the next file does not pay.
afterAll(async () => {
  const left = stillOpen();
  for (const db of left) await db.close();
  if (left.length > 0) {
    throw new Error(`${left.length} PGlite database(s) opened by this file were never closed`);
  }
});
