/**
 * Two builds and no server.
 *
 * The first is this file's default: `index.html` is a template carrying one
 * stylesheet and no script, so Vite compiles the CSS, fingerprints it and
 * writes the template with the right link in it. The second is `--ssr`, which
 * bundles `src/prerender.ts` for Node; running it fills that template once per
 * page and writes the HTML files beside it.
 *
 * There is deliberately no client entry. A page of this site is read, not
 * operated: everything on it is known when it is built, so shipping a
 * JavaScript bundle to re-render what is already in the HTML would cost a
 * download and buy nothing. `npm run build --workspace @ekwo-ai/site` therefore
 * produces HTML, one stylesheet and nothing else, and every page is complete
 * with scripting turned off.
 */

import { fileURLToPath } from 'node:url';
import tailwindcss from '@tailwindcss/vite';
import { defineConfig } from 'vite';

export default defineConfig({
  plugins: [tailwindcss()],
  // `.tsx` is compiled with the automatic runtime, so no component file has to
  // import React to say what a page looks like.
  esbuild: { jsx: 'automatic' },
  resolve: {
    alias: {
      // The site reads the packs through the command line's reader, which
      // imports the core the way a published package does. The tests resolve
      // it the same way, and for the same reason: nothing here waits on a
      // build of another workspace.
      '@ekwo-ai/core': fileURLToPath(new URL('../../packages/core/src/index.ts', import.meta.url)),
      '@ekwo-ai/fec': fileURLToPath(
        new URL('../../packages/formats/fec/src/index.ts', import.meta.url),
      ),
    },
  },
  build: {
    outDir: 'dist',
    // The prerender writes into the same folder afterwards, so only the first
    // of the two builds is allowed to clear it.
    emptyOutDir: true,
    assetsDir: 'assets',
  },
});
