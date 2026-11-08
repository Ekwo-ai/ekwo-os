import { defineConfig } from 'vitest/config';

// A brick is published on its own and is meant to be read, and run, outside
// this repository. `npm test` in this directory runs this package's tests and
// nothing else. Without this file the root configuration is found instead,
// whose patterns are written from the repository root: from here they match
// nothing, and vitest exits non-zero having run no test at all — which is how
// `prepublishOnly` came to refuse the two packages that have one.
export default defineConfig({
  test: {
    include: ['test/**/*.test.ts'],
  },
});
