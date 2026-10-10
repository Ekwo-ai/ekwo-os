// Runs veraPDF on PDF files and prints, for each, the rules of a PDF/A
// profile it passes and fails — the figures the README records.
//
//   npm run verapdf                          # the examples, PDF/A-3b
//   npm run verapdf -- --flavour 2b a.pdf    # other files, another profile
//
// veraPDF (https://verapdf.org, Java) is not a dependency of this package and
// runs in no test: install it, then put its launcher on the PATH or name it in
// VERAPDF. The exit code is 1 when a file fails a rule.

import { execFileSync } from 'node:child_process';
import { readdirSync } from 'node:fs';
import { fileURLToPath } from 'node:url';

const args = process.argv.slice(2);
let flavour = '3b';
const at = args.indexOf('--flavour');
if (at !== -1) {
  flavour = args[at + 1] ?? flavour;
  args.splice(at, 2);
}
const examples = fileURLToPath(new URL('../examples/', import.meta.url));
const files = args.length > 0 ? args : readdirSync(examples).filter((f) => f.endsWith('.pdf')).sort().map((f) => examples + f);
const verapdf = process.env.VERAPDF ?? 'verapdf';

let failed = false;
for (const file of files) {
  let report;
  try {
    report = execFileSync(verapdf, ['--flavour', flavour, '--format', 'xml', file], { encoding: 'utf8', maxBuffer: 64 * 1024 * 1024 });
  } catch (error) {
    // veraPDF exits non-zero for a file that is not compliant; its report is still on stdout.
    if (typeof error?.stdout === 'string' && error.stdout.includes('<details')) report = error.stdout;
    else {
      console.error(`${verapdf}: ${error instanceof Error ? error.message : String(error)}`);
      console.error('Install veraPDF and set VERAPDF to its launcher.');
      process.exit(2);
    }
  }
  const details = /<details passedRules="(\d+)" failedRules="(\d+)" passedChecks="(\d+)" failedChecks="(\d+)"/.exec(report);
  if (details === null) {
    console.error(`${file}: no validation report`);
    process.exit(2);
  }
  const [, passedRules, failedRules, passedChecks, failedChecks] = details;
  const name = file.slice(file.lastIndexOf('/') + 1);
  console.log(`${name}: PDF/A-${flavour}, ${passedRules} rules passed, ${failedRules} failed (${passedChecks} checks passed, ${failedChecks} failed)`);
  for (const rule of report.matchAll(/<rule [^>]*clause="([^"]+)" testNumber="(\d+)" status="failed"[^>]*>\s*<description>([^<]*)/g)) {
    console.log(`  ${rule[1]}-${rule[2]}: ${rule[3]}`);
  }
  if (failedRules !== '0') failed = true;
}
process.exit(failed ? 1 : 0);
