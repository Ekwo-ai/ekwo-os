/**
 * Everything the CLI prints.
 *
 * Colour only when the output is a terminal and `NO_COLOR` is unset, because
 * `ekwo status > report.txt` should not contain escape codes.
 *
 * Under `--json` the standard output belongs to one JSON document and nothing
 * else, so every line written here moves to the standard error: a person
 * watching still sees the steps go by, and a program reading the output never
 * has to find where the prose stops. There is no spinner and no line redrawn
 * in place anywhere in this CLI — everything is a line that ends — so there is
 * nothing to switch off when the output is a file or a pipe.
 */

let jsonMode = false;
let warnings: string[] = [];

/** Called once per run, before anything is printed. */
export function setJsonMode(on: boolean): void {
  jsonMode = on;
  warnings = [];
}

export function isJsonMode(): boolean {
  return jsonMode;
}

/** What `warn()` said during this run, for the `warnings` of the JSON document. */
export function collectedWarnings(): string[] {
  return [...warnings];
}

function target(): NodeJS.WriteStream {
  return jsonMode ? process.stderr : process.stdout;
}

/** Asked at every call: the stream a line goes to is decided per run. */
function useColour(): boolean {
  return (
    target().isTTY === true &&
    process.env['NO_COLOR'] === undefined &&
    process.env['TERM'] !== 'dumb'
  );
}

function paint(code: string, text: string): string {
  return useColour() ? `\u001b[${code}m${text}\u001b[0m` : text;
}

export const bold = (text: string): string => paint('1', text);
export const dim = (text: string): string => paint('2', text);
export const green = (text: string): string => paint('32', text);
export const yellow = (text: string): string => paint('33', text);
export const red = (text: string): string => paint('31', text);
export const cyan = (text: string): string => paint('36', text);

export function line(text = ''): void {
  target().write(`${text}\n`);
}

/** The one thing `--json` writes to the standard output. */
export function emit(value: unknown): void {
  process.stdout.write(`${JSON.stringify(value, null, 2)}\n`);
}

export function heading(text: string): void {
  line();
  line(bold(text));
}

export function step(text: string): void {
  line(`  ${green('·')} ${text}`);
}

export function skipped(text: string): void {
  line(`  ${dim('·')} ${dim(text)}`);
}

export function note(text: string): void {
  line(`  ${text}`);
}

export function warn(text: string): void {
  warnings.push(stripColour(text));
  line(`  ${yellow('!')} ${text}`);
}

export function fail(text: string): void {
  process.stderr.write(`${red('✗')} ${text}\n`);
}

/** A two-column table with the keys right-padded to the widest one. */
export function pairs(rows: [string, string][], indent = '  '): void {
  const width = rows.reduce((max, [key]) => Math.max(max, key.length), 0);
  for (const [key, value] of rows) {
    line(`${indent}${dim(key.padEnd(width))}  ${value}`);
  }
}

/**
 * A table with every column padded to its widest cell.
 *
 * Width is counted on the text and not on the escape codes around it, so a
 * coloured cell does not push the next column out. A number column is aligned
 * on the right, which is where a reader compares two of them.
 */
export function table(
  columns: { title: string; align?: 'left' | 'right' }[],
  rows: string[][],
  indent = '  ',
): void {
  const widths = columns.map((column, index) =>
    rows.reduce((max, row) => Math.max(max, stripColour(row[index] ?? '').length), column.title.length),
  );
  const cell = (text: string, index: number): string => {
    const gap = ' '.repeat(Math.max(0, (widths[index] ?? 0) - stripColour(text).length));
    return columns[index]?.align === 'right' ? `${gap}${text}` : `${text}${gap}`;
  };
  line(`${indent}${columns.map((column, index) => dim(cell(column.title, index))).join('  ')}`.trimEnd());
  for (const row of rows) {
    line(`${indent}${columns.map((_, index) => cell(row[index] ?? '', index)).join('  ')}`.trimEnd());
  }
}

export function stripColour(text: string): string {
  return text.replace(/\u001b\[[0-9;]*m/g, '');
}

/**
 * Redacts a secret for display. Never print one in full: terminal history and
 * CI logs outlive the session.
 */
export function mask(secret: string): string {
  if (secret.length <= 8) return '•'.repeat(secret.length);
  return `${secret.slice(0, 4)}${'•'.repeat(Math.min(20, secret.length - 8))}${secret.slice(-4)}`;
}

/** A connection string with its password replaced. */
export function maskUrl(url: string): string {
  return url.replace(/(postgres(?:ql)?:\/\/[^:/@]+:)[^@]*(@)/i, '$1••••••$2');
}
