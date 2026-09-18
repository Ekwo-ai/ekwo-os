import { StatementFileError } from './errors.js';

/**
 * A strict, small XML reader, written here because a statement comes from
 * outside and this package depends on nothing.
 *
 * It reads the XML a bank writes and refuses the XML an attacker writes:
 *
 * - **no DOCTYPE at all**, so no internal subset, no entity declaration, no
 *   external entity, no parameter entity — the billion-laughs family and the
 *   XXE family both start with `<!DOCTYPE` and both stop there;
 * - the five predefined entities and numeric character references, and any
 *   other `&name;` is an error rather than an empty string;
 * - a size limit applied before anything is read, a depth limit and an element
 *   limit applied while reading, and no recursion: nesting costs heap the
 *   limits bound, never stack;
 * - UTF-8 only, decoded fatally: a byte that is not UTF-8 is an error and not a
 *   replacement character in somebody's name;
 * - namespaces resolved, because a bank may write `<Document xmlns="…">` or
 *   `<ns2:Document xmlns:ns2="…">` and both are the same statement.
 *
 * It is not a general XML parser and says so: element and attribute names are
 * ASCII (every ISO 20022 name is), and nothing is validated against a schema.
 */

export interface XmlElement {
  /** Local name, without prefix. */
  name: string;
  /** Namespace URI, `''` when the element is in none. */
  namespace: string;
  /** Attributes by the name they were written under; `xmlns` ones left out. */
  attributes: Record<string, string>;
  children: XmlElement[];
  /** The element's own character data, concatenated; children's is theirs. */
  text: string;
}

export interface XmlLimits {
  maxBytes: number;
  maxDepth: number;
  maxElements: number;
}

const NAME = /[A-Za-z_][A-Za-z0-9_.-]*(?::[A-Za-z_][A-Za-z0-9_.-]*)?/y;
const ATTRIBUTE =
  /\s+([A-Za-z_][A-Za-z0-9_.-]*(?::[A-Za-z_][A-Za-z0-9_.-]*)?)\s*=\s*(?:"([^<"]*)"|'([^<']*)')/y;
const DECLARATION =
  /^<\?xml\s+version\s*=\s*(?:"1\.[0-9]+"|'1\.[0-9]+')(?:\s+encoding\s*=\s*(?:"([A-Za-z][A-Za-z0-9._-]*)"|'([A-Za-z][A-Za-z0-9._-]*)'))?(?:\s+standalone\s*=\s*(?:"(?:yes|no)"|'(?:yes|no)'))?\s*\?>/;
const REFERENCE = /&(?:#x([0-9a-fA-F]+)|#([0-9]+)|([A-Za-z_][A-Za-z0-9_.-]*));/g;

const PREDEFINED: Record<string, string> = {
  lt: '<',
  gt: '>',
  amp: '&',
  quot: '"',
  apos: "'",
};

const XML_NAMESPACE = 'http://www.w3.org/XML/1998/namespace';

function malformed(what: string, at: number): StatementFileError {
  return new StatementFileError('malformed_xml', `${what} (at character ${at})`);
}

/** XML 1.0 `Char`, by code point. */
function isXmlChar(code: number): boolean {
  return (
    code === 0x9 ||
    code === 0xa ||
    code === 0xd ||
    (code >= 0x20 && code <= 0xd7ff) ||
    (code >= 0xe000 && code <= 0xfffd) ||
    (code >= 0x10000 && code <= 0x10ffff)
  );
}

/** The first code unit XML does not allow in a document, or -1. */
function firstForbiddenCharacter(source: string): number {
  for (let index = 0; index < source.length; index += 1) {
    const code = source.charCodeAt(index);
    if (code >= 0x20 && code < 0xfffe) continue;
    if (code === 0x9 || code === 0xa || code === 0xd) continue;
    return index;
  }
  return -1;
}

function decodeReferences(raw: string, at: number): string {
  if (!raw.includes('&')) return raw;
  let out = '';
  let last = 0;
  for (const match of raw.matchAll(REFERENCE)) {
    const index = match.index;
    const between = raw.slice(last, index);
    if (between.includes('&')) throw malformed('a bare "&"', at + last + between.indexOf('&'));
    out += between;
    if (match[3] !== undefined) {
      const value = PREDEFINED[match[3]];
      if (value === undefined) {
        throw new StatementFileError(
          'undefined_entity',
          `entity &${match[3]}; is not one of the five XML predefines, and this reader declares no other (at character ${at + index})`,
        );
      }
      out += value;
    } else {
      const code =
        match[1] !== undefined ? parseInt(match[1], 16) : parseInt(match[2] as string, 10);
      if (!isXmlChar(code)) {
        throw malformed(`character reference ${match[0]} is not an XML character`, at + index);
      }
      out += String.fromCodePoint(code);
    }
    last = index + match[0].length;
  }
  const rest = raw.slice(last);
  if (rest.includes('&')) throw malformed('a bare "&"', at + last + rest.indexOf('&'));
  return out + rest;
}

function decode(input: string | Uint8Array, limits: XmlLimits): string {
  if (typeof input === 'string') {
    // A string has no bytes to count; its length is the closest honest bound,
    // and UTF-8 never encodes a code unit in less than one byte.
    if (input.length > limits.maxBytes) {
      throw new StatementFileError(
        'too_large',
        `the file is ${input.length} characters, over the limit of ${limits.maxBytes}`,
      );
    }
    return input.charCodeAt(0) === 0xfeff ? input.slice(1) : input;
  }
  if (input.byteLength > limits.maxBytes) {
    throw new StatementFileError(
      'too_large',
      `the file is ${input.byteLength} bytes, over the limit of ${limits.maxBytes}`,
    );
  }
  const first = input[0];
  const second = input[1];
  if ((first === 0xfe && second === 0xff) || (first === 0xff && second === 0xfe)) {
    throw new StatementFileError(
      'unsupported_encoding',
      'the file is UTF-16; this reader takes UTF-8',
    );
  }
  let text: string;
  try {
    text = new TextDecoder('utf-8', { fatal: true }).decode(input);
  } catch {
    throw new StatementFileError(
      'unsupported_encoding',
      'the file is not valid UTF-8; decode it first and pass the string',
    );
  }
  const declaration = DECLARATION.exec(text);
  const encoding = declaration?.[1] ?? declaration?.[2];
  if (encoding !== undefined && !/^utf-?8$/i.test(encoding)) {
    throw new StatementFileError(
      'unsupported_encoding',
      `the file declares encoding ${encoding}; this reader takes UTF-8 — decode it first and pass the string`,
    );
  }
  return text;
}

interface Open {
  element: XmlElement;
  qualifiedName: string;
  scope: Map<string, string>;
  text: string[];
}

function isSpace(character: string | undefined): boolean {
  return character === ' ' || character === '\n' || character === '\t';
}

export function parseXml(input: string | Uint8Array, limits: XmlLimits): XmlElement {
  const source = decode(input, limits).replace(/\r\n?/g, '\n');
  const forbidden = firstForbiddenCharacter(source);
  if (forbidden !== -1) throw malformed('a control character XML does not allow', forbidden);

  let at = 0;
  const declaration = DECLARATION.exec(source);
  if (declaration) at = declaration[0].length;

  const rootScope = new Map<string, string>([['xml', XML_NAMESPACE]]);
  const stack: Open[] = [];
  let root: XmlElement | undefined;
  let elements = 0;

  const addText = (raw: string, where: number, literal: boolean): void => {
    const top = stack[stack.length - 1];
    if (top === undefined) {
      if (raw.trim() !== '') throw malformed('text outside the document element', where);
      return;
    }
    top.text.push(literal ? raw : decodeReferences(raw, where));
  };

  while (at < source.length) {
    const lt = source.indexOf('<', at);
    if (lt === -1) {
      addText(source.slice(at), at, false);
      at = source.length;
      break;
    }
    if (lt > at) addText(source.slice(at, lt), at, false);
    at = lt;

    if (source.startsWith('<!--', at)) {
      const end = source.indexOf('-->', at + 4);
      if (end === -1) throw malformed('a comment that never ends', at);
      at = end + 3;
      continue;
    }
    if (source.startsWith('<![CDATA[', at)) {
      if (stack.length === 0) throw malformed('a CDATA section outside the document element', at);
      const end = source.indexOf(']]>', at + 9);
      if (end === -1) throw malformed('a CDATA section that never ends', at);
      addText(source.slice(at + 9, end), at, true);
      at = end + 3;
      continue;
    }
    if (source.startsWith('<!DOCTYPE', at)) {
      throw new StatementFileError(
        'doctype_forbidden',
        'the file carries a DOCTYPE; a statement needs none, and entity declarations are refused unread',
      );
    }
    if (source.startsWith('<!', at)) throw malformed('a markup declaration', at);
    if (source.startsWith('<?', at)) {
      const end = source.indexOf('?>', at + 2);
      if (end === -1) throw malformed('a processing instruction that never ends', at);
      if (/^<\?xml[\s?]/i.test(source.slice(at, at + 6))) {
        throw malformed('an XML declaration anywhere but the first character', at);
      }
      at = end + 2;
      continue;
    }

    if (source.startsWith('</', at)) {
      NAME.lastIndex = at + 2;
      const name = NAME.exec(source);
      if (!name) throw malformed('a closing tag without a name', at);
      let end = NAME.lastIndex;
      while (isSpace(source[end])) end += 1;
      if (source[end] !== '>') throw malformed('a closing tag that never ends', at);
      const open = stack.pop();
      if (open === undefined || open.qualifiedName !== name[0]) {
        throw malformed(
          `</${name[0]}> closes ${open ? `<${open.qualifiedName}>` : 'nothing'}`,
          at,
        );
      }
      open.element.text = open.text.join('');
      at = end + 1;
      continue;
    }

    // An opening tag.
    NAME.lastIndex = at + 1;
    const name = NAME.exec(source);
    if (!name) throw malformed('a "<" that opens nothing', at);
    if (root !== undefined && stack.length === 0) {
      throw malformed('a second document element', at);
    }
    elements += 1;
    if (elements > limits.maxElements) {
      throw new StatementFileError(
        'too_many_elements',
        `the file holds more than ${limits.maxElements} elements`,
      );
    }
    if (stack.length >= limits.maxDepth) {
      throw new StatementFileError(
        'too_deep',
        `elements are nested deeper than ${limits.maxDepth}`,
      );
    }

    let cursor = NAME.lastIndex;
    const written: Array<[string, string]> = [];
    for (;;) {
      ATTRIBUTE.lastIndex = cursor;
      const attribute = ATTRIBUTE.exec(source);
      if (!attribute) break;
      const raw = (attribute[2] ?? attribute[3]) as string;
      written.push([
        attribute[1] as string,
        decodeReferences(raw, cursor).replace(/[\t\n]/g, ' '),
      ]);
      cursor = ATTRIBUTE.lastIndex;
    }
    while (isSpace(source[cursor])) cursor += 1;
    const selfClosing = source[cursor] === '/';
    if (selfClosing) cursor += 1;
    if (source[cursor] !== '>') throw malformed(`<${name[0]}> is not a well-formed tag`, at);

    const parentScope = stack[stack.length - 1]?.scope ?? rootScope;
    let scope = parentScope;
    const attributes: Record<string, string> = {};
    const seen = new Set<string>();
    for (const [key, value] of written) {
      if (seen.has(key)) throw malformed(`attribute ${key} is written twice on <${name[0]}>`, at);
      seen.add(key);
      if (key === 'xmlns' || key.startsWith('xmlns:')) {
        if (scope === parentScope) scope = new Map(parentScope);
        const prefix = key === 'xmlns' ? '' : key.slice(6);
        if (prefix === 'xml' || prefix === 'xmlns') {
          throw malformed(`prefix ${prefix} cannot be declared`, at);
        }
        if (prefix !== '' && value === '') throw malformed(`prefix ${prefix} is bound to nothing`, at);
        scope.set(prefix, value);
      } else {
        attributes[key] = value;
      }
    }

    const colon = name[0].indexOf(':');
    const prefix = colon === -1 ? '' : name[0].slice(0, colon);
    const namespace = scope.get(prefix);
    if (namespace === undefined && prefix !== '') {
      throw malformed(`prefix ${prefix} is bound to no namespace`, at);
    }
    const element: XmlElement = {
      name: colon === -1 ? name[0] : name[0].slice(colon + 1),
      namespace: namespace ?? '',
      attributes,
      children: [],
      text: '',
    };
    const parent = stack[stack.length - 1];
    if (parent) parent.element.children.push(element);
    else root = element;
    if (!selfClosing) stack.push({ element, qualifiedName: name[0], scope, text: [] });
    at = cursor + 1;
  }

  const unclosed = stack[stack.length - 1];
  if (unclosed) throw malformed(`<${unclosed.qualifiedName}> is never closed`, source.length);
  if (root === undefined) throw malformed('no document element', 0);
  return root;
}
