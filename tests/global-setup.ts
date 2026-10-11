import { mkdtemp, rm } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { schemaImage } from './helpers/db.js';

/**
 * Builds the schema once for the whole run, before any worker starts.
 *
 * Nearly every test file asks `freshDatabase()` for the same database. The
 * image of it is built here, in a directory of this run that every worker
 * inherits through `EKWO_TEST_SCHEMA_DIR`, so the workers load it instead of
 * racing to build it. The rarer variants — no seeds, no modules, migrations
 * left out — are built by the first file that asks, into the same directory.
 */
export default async function setup(): Promise<() => Promise<void>> {
  const dir = await mkdtemp(join(tmpdir(), 'ekwo-test-schema-'));
  process.env.EKWO_TEST_SCHEMA_DIR = dir;
  await schemaImage();
  return async () => {
    await rm(dir, { recursive: true, force: true });
  };
}
