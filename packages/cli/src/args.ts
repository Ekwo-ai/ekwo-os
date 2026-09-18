/**
 * Argument parsing, by hand.
 *
 * The whole surface is `--flag value`, `--flag=value` and boolean switches.
 * A parser for that is forty lines; a dependency for it is a supply chain.
 * This CLI is handed a service_role key and a database password, so every
 * package it pulls in is a package that could read them. It has exactly one
 * runtime dependency from outside this repository, the Postgres driver, and
 * that is the point.
 *
 * Unknown flags are refused rather than ignored: `--fiscal-yr 2026` silently
 * doing nothing is worse than stopping.
 */

export interface ParsedArgs {
  command: string | undefined;
  flags: Map<string, string | boolean>;
  positional: string[];
  /**
   * Every flag as it was written, in order, repeats included.
   *
   * `flags` is a map and a map keeps the last value, which is right for
   * everything that is answered once — a currency, a language. A flag that
   * names one of several things is answered once per thing:
   * `--filing-period A=month --filing-period B=quarter` is two answers and not
   * a correction of the first. `stringFlags` reads them from here.
   */
  occurrences: { name: string; value: string | boolean }[];
}

export class UsageError extends Error {}

/** Splits argv into a command, its flags and whatever is left. */
export function parseArgs(argv: string[]): ParsedArgs {
  const flags = new Map<string, string | boolean>();
  const occurrences: { name: string; value: string | boolean }[] = [];
  const positional: string[] = [];
  let command: string | undefined;
  const seen = (name: string, value: string | boolean): void => {
    flags.set(name, value);
    occurrences.push({ name, value });
  };

  for (let index = 0; index < argv.length; index += 1) {
    const token = argv[index] as string;

    if (token === '--') {
      positional.push(...argv.slice(index + 1));
      break;
    }

    if (token.startsWith('--')) {
      const body = token.slice(2);
      const equals = body.indexOf('=');
      if (equals !== -1) {
        seen(body.slice(0, equals), body.slice(equals + 1));
        continue;
      }
      const next = argv[index + 1];
      if (next !== undefined && !next.startsWith('-')) {
        seen(body, next);
        index += 1;
      } else {
        seen(body, true);
      }
      continue;
    }

    if (token.startsWith('-') && token.length > 1) {
      const short = SHORT_FLAGS[token];
      if (short === undefined) throw new UsageError(`unknown option: ${token}`);
      seen(short, true);
      continue;
    }

    if (command === undefined) command = token;
    else positional.push(token);
  }

  return { command, flags, positional, occurrences };
}

const SHORT_FLAGS: Record<string, string> = {
  '-h': 'help',
  '-v': 'version',
  '-y': 'yes',
};

/** A flag's value as a string, or `undefined` when it was not given. */
export function stringFlag(args: ParsedArgs, name: string): string | undefined {
  const value = args.flags.get(name);
  if (value === undefined) return undefined;
  if (value === true) throw new UsageError(`--${name} needs a value`);
  if (value === false) return undefined;
  return value;
}

/**
 * Every value a repeatable flag was given, in the order they were written.
 *
 * Empty when the flag was not given at all; a refusal when it was given with
 * no value, which is the same mistake `stringFlag` refuses for the same
 * reason — a flag that names something and names nothing is a typo.
 */
export function stringFlags(args: ParsedArgs, name: string): string[] {
  const found = args.occurrences.filter((flag) => flag.name === name);
  return found.map((flag) => {
    if (flag.value === true) throw new UsageError(`--${name} needs a value`);
    if (flag.value === false) throw new UsageError(`--${name} needs a value`);
    return flag.value;
  });
}

export function boolFlag(args: ParsedArgs, name: string): boolean {
  const value = args.flags.get(name);
  if (value === undefined) return false;
  if (typeof value === 'string') {
    if (value === 'true' || value === 'yes') return true;
    if (value === 'false' || value === 'no') return false;
    throw new UsageError(`--${name} is a switch, not a value (got "${value}")`);
  }
  return value;
}

export function numberFlag(args: ParsedArgs, name: string): number | undefined {
  const raw = stringFlag(args, name);
  if (raw === undefined) return undefined;
  const value = Number(raw);
  if (!Number.isInteger(value)) throw new UsageError(`--${name} must be a whole number`);
  return value;
}

/**
 * Stops on a flag nobody defined, rather than letting a typo pass.
 *
 * `--json` is accepted here and not in each command's list, for the reason
 * `--help` is: it is a property of the command line and not of a command, and
 * a command added next year answers in JSON without anybody remembering to
 * say so.
 */
export function rejectUnknownFlags(args: ParsedArgs, known: readonly string[]): void {
  const allowed = new Set([...known, 'help', 'version', 'json']);
  const unknown = [...args.flags.keys()].filter((name) => !allowed.has(name));
  if (unknown.length > 0) {
    throw new UsageError(
      `unknown option(s): ${unknown.map((n) => `--${n}`).join(', ')}\n` +
        `This command accepts: ${[...known, 'json'].map((n) => `--${n}`).join(', ')}`,
    );
  }
}
