import { execFile } from 'node:child_process';
import { mkdtemp, rm } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { promisify } from 'node:util';

/**
 * Builds the schema once for the whole run, before any worker starts.
 *
 * Nearly every test file asks `freshDatabase()` for the same database. The
 * image of it is built here, in a directory of this run that every worker
 * inherits through `EKWO_TEST_SCHEMA_DIR`, so the workers load it instead of
 * racing to build it. The rarer variants — no seeds, no modules, migrations
 * left out — are built by the first file that asks, into the same directory.
 *
 * The build runs in a child process of its own, never in this one. This
 * process is vitest's, and it lives as long as the run: a PGlite built here
 * took it to 1.2 to 1.4 GB, and it never went back under 500 MB before the
 * last file ended, because PGlite keeps its compiled WebAssembly module, and
 * the machine code Node compiled for it, in a variable of its own module.
 * Built in a child, the same image leaves this process at about 200 MB: the
 * child takes the memory with it when it exits (issue #28). The child reads
 * `tests/helpers/db.ts` as Node strips its types, so that file keeps to the
 * syntax Node can strip: no `enum`, no `namespace`, no parameter property.
 */
export default async function setup(): Promise<() => Promise<void>> {
  const dir = await mkdtemp(join(tmpdir(), 'ekwo-test-schema-'));
  process.env.EKWO_TEST_SCHEMA_DIR = dir;
  const helper = new URL('./helpers/db.ts', import.meta.url).href;
  await promisify(execFile)(process.execPath, [
    '--experimental-strip-types',
    '--disable-warning=ExperimentalWarning',
    '--input-type=module',
    '--eval',
    `const { schemaImage } = await import(${JSON.stringify(helper)}); await schemaImage();`,
  ]);
  return async () => {
    await rm(dir, { recursive: true, force: true });
  };
}
