#!/usr/bin/env node
/**
 * Plays the published Schematron against the committed files, and records what
 * it said in `test/fixtures/verdicts.json`.
 *
 * This is the half of the proof that the test suite cannot run. The rules of
 * EN 16931 and of Peppol BIS Billing 3.0 are Schematron with an XSLT 2.0 query
 * binding; running them takes an XSLT 2.0 processor, and the only one that
 * runs on Node is SaxonJS — a dependency this repository does not take for a
 * test, and one whose licence is not an open-source one. So the Schematron is
 * played by hand, from outside the repository, and its verdicts are committed:
 * `test/verdicts.test.ts` then holds the package to them on every run.
 *
 * What it needs, none of which is installed by this repository:
 *
 *   mkdir /tmp/schematron-tools && cd /tmp/schematron-tools
 *   npm init -y && npm install saxon-js xslt3
 *
 *   node scripts/play-schematron.mjs --tools /tmp/schematron-tools
 *
 * What it downloads, each checked against the SHA-256 written below:
 *
 *   - the two Schematron files of Peppol BIS Billing 3.0, at the tag of the
 *     release, from github.com/OpenPEPPOL/peppol-bis-invoice-3;
 *   - SchXslt 1.10.1, the Schematron-to-XSLT compiler, from Maven Central.
 *
 * It fails rather than record anything if a file that was played is not the
 * file the generator writes today.
 */
import { execFileSync } from 'node:child_process';
import { createHash } from 'node:crypto';
import { existsSync, mkdirSync, readFileSync, readdirSync, writeFileSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = join(dirname(fileURLToPath(import.meta.url)), '..');
const FIXTURES = join(ROOT, 'test', 'fixtures');

const RELEASE = 'v3.0.20';
const BASE = `https://raw.githubusercontent.com/OpenPEPPOL/peppol-bis-invoice-3/${RELEASE}/rules/sch`;
const SOURCES = [
  {
    name: 'CEN-EN16931-UBL.sch',
    url: `${BASE}/CEN-EN16931-UBL.sch`,
    sha256: 'bdcbb7b702cce55c7f8c789bef0cb9bebf6d376140c1776e683bd6d9bc0ad331',
  },
  {
    name: 'PEPPOL-EN16931-UBL.sch',
    url: `${BASE}/PEPPOL-EN16931-UBL.sch`,
    sha256: '5ddf3a2f6633147b20b7805df9902d825af1a984f10014fcee186d4170364b1d',
  },
];
const SCHXSLT = {
  name: 'schxslt-1.10.1.jar',
  url: 'https://repo1.maven.org/maven2/name/dmaus/schxslt/schxslt/1.10.1/schxslt-1.10.1.jar',
  sha256: null, // filled in on first use; see below
};

function arg(name) {
  const i = process.argv.indexOf(`--${name}`);
  return i >= 0 ? process.argv[i + 1] : undefined;
}

const tools = arg('tools');
if (!tools || !existsSync(join(tools, 'node_modules', 'xslt3'))) {
  console.error('Pass --tools <dir>, a directory where `npm install saxon-js xslt3` was run. See the header of this file.');
  process.exit(2);
}
const work = resolve(tools, 'peppol-ubl-work');
mkdirSync(work, { recursive: true });

const sha256 = (buffer) => createHash('sha256').update(buffer).digest('hex');

async function fetchChecked({ name, url, sha256: expected }) {
  const path = join(work, name);
  if (!existsSync(path)) {
    const response = await fetch(url);
    if (!response.ok) throw new Error(`${url}: ${response.status}`);
    writeFileSync(path, Buffer.from(await response.arrayBuffer()));
  }
  const actual = sha256(readFileSync(path));
  if (expected && actual !== expected) throw new Error(`${name}: SHA-256 is ${actual}, expected ${expected}`);
  return { path, sha256: actual };
}

const xslt3 = (args) =>
  execFileSync(process.execPath, [join(tools, 'node_modules', 'xslt3', 'xslt3.js'), ...args], {
    cwd: work,
    maxBuffer: 256 * 1024 * 1024,
    encoding: 'utf8',
  });

// The vendored copy of the CEN Schematron is the one that is played.
const vendored = sha256(readFileSync(join(ROOT, 'test', 'codelist', 'CEN-EN16931-UBL.sch')));
if (vendored !== SOURCES[0].sha256) {
  throw new Error('test/codelist/CEN-EN16931-UBL.sch is not the file of the release this script plays.');
}

const compiler = await fetchChecked(SCHXSLT);
const pipeline = join(work, 'schxslt', 'xslt', '2.0', 'pipeline-for-svrl.xsl');
if (!existsSync(pipeline)) execFileSync('unzip', ['-q', '-o', compiler.path, '-d', join(work, 'schxslt')]);

const compiled = [];
for (const source of SOURCES) {
  const { path } = await fetchChecked(source);
  const stylesheet = path.replace(/\.sch$/, '.xsl');
  if (!existsSync(stylesheet)) xslt3([`-xsl:${pipeline}`, `-s:${path}`, `-o:${stylesheet}`]);
  // Compiled once more, to the form SaxonJS executes: parsing a megabyte of
  // XSLT for every file is most of the time this script would otherwise take.
  const executable = path.replace(/\.sch$/, '.sef.json');
  if (!existsSync(executable)) xslt3([`-xsl:${stylesheet}`, `-export:${executable}`, '-nogo']);
  compiled.push(executable);
}

// Two code lists are carried by both Schematrons, and they are not copies of
// each other. Where they differ, one code is refused by one rule set and not
// the other, and `src/rules.ts` has to know which: the differences are
// recorded, and `test/verdicts.test.ts` holds the package to them.
const peppol = readFileSync(join(work, 'PEPPOL-EN16931-UBL.sch'), 'utf8');
const cen = readFileSync(join(work, 'CEN-EN16931-UBL.sch'), 'utf8');
const tokens = (text) => new Set(text.split(/\s+/).filter(Boolean));
const peppolList = (name) => tokens(new RegExp(`<let name="${name}"\\s+value="tokenize\\('([^']*)'`).exec(peppol)[1]);
const cenList = (rule) => tokens(new RegExp(`<assert id="${rule}"[^>]*test="[^"]*?contains\\(\\s*'([^']*)'`).exec(cen)[1]);
const difference = (a, b) => [...a].filter((code) => !b.has(code)).sort();
const lists = {
  // Electronic address schemes: what EN 16931 lists and Peppol does not, and
  // the other way round. `SCHEMES_NOT_ON_PEPPOL` in src/rules.ts is the first.
  eas_in_en16931_not_in_peppol: difference(cenList('BR-CL-25'), peppolList('eaid')),
  eas_in_peppol_not_in_en16931: difference(peppolList('eaid'), cenList('BR-CL-25')),
  currencies_in_en16931_not_in_peppol: difference(cenList('BR-CL-04'), peppolList('ISO4217')),
  currencies_in_peppol_not_in_en16931: difference(peppolList('ISO4217'), cenList('BR-CL-04')),
};

// The files that are played must be the files the generator writes. The test
// suite pins the two together; this refuses to record a verdict on anything
// the suite would refuse.
execFileSync('npx', ['vitest', 'run', 'test/fixtures.test.ts'], { cwd: ROOT, stdio: 'inherit' });

const verdicts = {};
for (const file of readdirSync(FIXTURES).filter((name) => name.endsWith('.xml')).sort()) {
  const fired = { fatal: new Set(), warning: new Set() };
  let rulesFired = 0;
  for (const stylesheet of compiled) {
    const svrl = xslt3([`-xsl:${stylesheet}`, `-s:${join(FIXTURES, file)}`]);
    rulesFired += (svrl.match(/<svrl:fired-rule\b/g) ?? []).length;
    for (const match of svrl.matchAll(/<svrl:failed-assert\b([^>]*)>/g)) {
      const id = /\bid="([^"]+)"/.exec(match[1])?.[1];
      const flag = /\bflag="([^"]+)"/.exec(match[1])?.[1] ?? 'fatal';
      if (id) (flag === 'warning' ? fired.warning : fired.fatal).add(id);
    }
  }
  if (rulesFired === 0) throw new Error(`${file}: no rule fired at all, so nothing was validated`);
  verdicts[file.replace(/\.xml$/, '')] = { fatal: [...fired.fatal].sort(), warning: [...fired.warning].sort() };
  console.log(`${file}: ${[...fired.fatal].sort().join(' ') || 'valid'}`);
}

writeFileSync(
  join(FIXTURES, 'verdicts.json'),
  `${JSON.stringify(
    {
      $comment:
        'Written by scripts/play-schematron.mjs: what the published Schematron said of each file beside this one. Not edited by hand.',
      played_on: new Date().toISOString().slice(0, 10),
      release: `Peppol BIS Billing 3.0, ${RELEASE}`,
      sources: Object.fromEntries(SOURCES.map((source) => [source.name, source.sha256])),
      compiler: { name: SCHXSLT.name, sha256: compiler.sha256 },
      processor: JSON.parse(readFileSync(join(tools, 'node_modules', 'saxon-js', 'package.json'), 'utf8')).version,
      lists,
      verdicts,
    },
    null,
    2,
  )}\n`,
);
console.log('Wrote test/fixtures/verdicts.json');
