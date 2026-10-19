/**
 * One UBL document, two syntaxes.
 *
 * MyInvois takes the same UBL 2.1 document as XML or as JSON, and the JSON is
 * not a translation of the XML but the same tree written another way: every
 * element is a list, every value is `{"_": value}` with its attributes beside
 * it, and the three namespaces are declared once at the root as `_D`, `_A`
 * and `_B`, as LHDNM's samples write them. So the document is built once, as
 * a tree, in the order of the OASIS schema, and printed by either printer
 * below. What the XML says, the JSON says.
 *
 * Nothing is written empty: an absent value is an absent element.
 */

export const NAMESPACES = {
  Invoice: 'urn:oasis:names:specification:ubl:schema:xsd:Invoice-2',
  cac: 'urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2',
  cbc: 'urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2',
} as const;

/** A value of a basic component: text, a decimal written as its digits, or an indicator. */
export type Value = { text: string } | { decimal: string } | { indicator: boolean };

export interface UblElement {
  prefix: 'cac' | 'cbc';
  name: string;
  value?: Value;
  attributes?: Readonly<Record<string, string>>;
  children?: readonly UblElement[];
}

type Maybe = UblElement | null;

/** `cbc:<name>`, or nothing where there is no value. */
export function leaf(name: string, value: Value | null, attributes: Record<string, string | null> = {}): Maybe {
  if (value === null) return null;
  if ('text' in value && value.text === '') return null;
  const present = Object.fromEntries(
    Object.entries(attributes).filter((entry): entry is [string, string] => entry[1] !== null && entry[1] !== ''),
  );
  return { prefix: 'cbc', name, value, ...(Object.keys(present).length > 0 ? { attributes: present } : {}) };
}

export const textOf = (value: string | null): Value | null => (value === null ? null : { text: value });

/** `cac:<name>`, or nothing where none of its children is there. */
export function group(name: string, children: readonly Maybe[]): Maybe {
  const present = children.filter((child): child is UblElement => child !== null);
  return present.length === 0 ? null : { prefix: 'cac', name, children: present };
}

// --- XML --------------------------------------------------------------------

function escapeXml(value: string): string {
  return value.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
}

function scalar(value: Value): string {
  if ('text' in value) return value.text;
  if ('decimal' in value) return value.decimal;
  return value.indicator ? 'true' : 'false';
}

function xmlOf(element: UblElement, indent: string): string {
  const tag = `${element.prefix}:${element.name}`;
  const attrs = Object.entries(element.attributes ?? {})
    .map(([key, value]) => ` ${key}="${escapeXml(value)}"`)
    .join('');
  if (element.value !== undefined) return `${indent}<${tag}${attrs}>${escapeXml(scalar(element.value))}</${tag}>`;
  const body = (element.children ?? []).map((child) => xmlOf(child, `${indent}  `)).join('\n');
  return `${indent}<${tag}${attrs}>\n${body}\n${indent}</${tag}>`;
}

/** The document as UBL 2.1 XML: `<Invoice>`, whatever kind of document it is, as MyInvois has it. */
export function toXml(children: readonly UblElement[]): string {
  const root = `<Invoice xmlns="${NAMESPACES.Invoice}" xmlns:cac="${NAMESPACES.cac}" xmlns:cbc="${NAMESPACES.cbc}">`;
  return `<?xml version="1.0" encoding="UTF-8"?>\n${root}\n${children.map((child) => xmlOf(child, '  ')).join('\n')}\n</Invoice>\n`;
}

// --- JSON -------------------------------------------------------------------

/**
 * Siblings of one name become one list, in the order the first of them
 * appears: JSON keys a list by its name, where XML repeats the element.
 */
function jsonOf(elements: readonly UblElement[], indent: string): string {
  const byName = new Map<string, UblElement[]>();
  for (const element of elements) byName.set(element.name, [...(byName.get(element.name) ?? []), element]);
  const inner = `${indent}  `;
  const entries = [...byName].map(([name, all]) => {
    const items = all.map((element) => `${inner}  ${itemOf(element, `${inner}  `)}`).join(',\n');
    return `${inner}${JSON.stringify(name)}: [\n${items}\n${inner}]`;
  });
  return `{\n${entries.join(',\n')}\n${indent}}`;
}

function itemOf(element: UblElement, indent: string): string {
  if (element.children !== undefined) return jsonOf(element.children, indent);
  const value = element.value as Value;
  // A decimal is written as its own digits, unquoted: a JSON number is a
  // decimal number in text, and nothing passes through a binary float.
  const written =
    'text' in value ? JSON.stringify(value.text) : 'decimal' in value ? value.decimal : String(value.indicator);
  const attrs = Object.entries(element.attributes ?? {}).map(
    ([key, attribute]) => `, ${JSON.stringify(key)}: ${JSON.stringify(attribute)}`,
  );
  return `{ "_": ${written}${attrs.join('')} }`;
}

/** The document as UBL 2.1 JSON, the namespaces declared at the root as LHDNM's samples declare them. */
export function toJson(children: readonly UblElement[]): string {
  const namespaces = [
    `  "_D": ${JSON.stringify(NAMESPACES.Invoice)}`,
    `  "_A": ${JSON.stringify(NAMESPACES.cac)}`,
    `  "_B": ${JSON.stringify(NAMESPACES.cbc)}`,
  ];
  return `{\n${namespaces.join(',\n')},\n  "Invoice": [\n    ${jsonOf(children, '    ')}\n  ]\n}\n`;
}
