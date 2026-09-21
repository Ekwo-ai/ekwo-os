/**
 * A Markdown file of the repository, as a page of the documentation.
 *
 * It reads nothing: `data.ts` hands it the text and a way to resolve a link,
 * and it hands back the HTML, the headings and the first sentence. Four things
 * are done to the file on the way, and nothing else.
 *
 * - **The file's own `#` title is taken out.** The page draws its heading
 *   itself, once, so a page has one `<h1>` whatever the file does; a second
 *   `#` further down becomes a `##`.
 * - **Every heading gets the id GitHub gives it.** A link written for the
 *   repository — `#acting-as-a-person-login-use-whoami` — lands on the same
 *   heading here, and the ids are counted over the whole file, so a slice of a
 *   file keeps the ids the whole file had.
 * - **Every link is resolved by the caller.** A link to another file that is an
 *   article goes to that article; any other relative link goes to the
 *   repository, where it works. A link written for GitHub never becomes a 404
 *   on this site.
 * - **A table scrolls inside its own box**, so a wide one never makes the page
 *   scroll sideways on a phone.
 * - **A block of code is wrapped for a copy button**: `data-code` on the box,
 *   and `COPY_SLOT` after the block where the page puts the button. The page
 *   draws it because it is a control, with the page's icons and words.
 */

import { Marked, type Token, type Tokens, type TokensList } from 'marked';

/** Where the page puts the copy button of a block of code. */
export const COPY_SLOT = '<!--copy-->';

export interface Heading {
  depth: number;
  id: string;
  /** The heading's words, with its inline code kept. */
  html: string;
  text: string;
}

export interface RenderedMarkdown {
  /** The file's `#` title as plain text, or null where it has none. */
  title: string | null;
  /** The same, with its inline code kept. */
  titleHtml: string | null;
  html: string;
  /** Every heading of the part rendered, in order. */
  headings: Heading[];
  /** The first paragraph, as plain text: what a search result or a card shows. */
  summary: string;
  /**
   * The part rendered, as the file writes it, its `#` title left out: what
   * `llms-full.txt` gives a model, which reads Markdown better than HTML.
   */
  markdown: string;
}

export interface Slice {
  /** A `##` heading, word for word as the file writes it. */
  from: string;
  /** The `##` heading it stops before. Left out, the slice runs to the end. */
  until?: string;
}

/**
 * The plain words of a run of inline tokens: code without its backticks, a
 * link as its text. What GitHub makes an anchor from, and what a search reads.
 */
export function plainText(tokens: readonly Token[] | undefined): string {
  if (tokens === undefined) return '';
  return tokens
    .map((token) => {
      if ('tokens' in token && Array.isArray(token.tokens) && token.type !== 'codespan') {
        return plainText(token.tokens);
      }
      if (token.type === 'html') return '';
      return 'text' in token && typeof token.text === 'string' ? token.text : '';
    })
    .join('');
}

/**
 * The anchor GitHub gives a heading: lower case, punctuation dropped, spaces
 * as hyphens, and `-1`, `-2` after a heading already seen.
 */
export function githubSlugger(): (text: string) => string {
  const seen = new Map<string, number>();
  return (text) => {
    const base = text
      .toLowerCase()
      .trim()
      .replace(/[^\p{L}\p{M}\p{N}\p{Pc} -]/gu, '')
      .replace(/ /g, '-');
    const count = seen.get(base) ?? 0;
    seen.set(base, count + 1);
    return count === 0 ? base : `${base}-${count}`;
  };
}

export function renderMarkdown(
  markdown: string,
  options: {
    slice?: Slice;
    /** Where a link written in the file should point on this site. */
    resolveLink: (href: string) => string;
    /** What the slice is called, for the error that says it is not in the file. */
    source: string;
  },
): RenderedMarkdown {
  const marked = new Marked();
  const all = marked.lexer(markdown);

  // The ids are the whole file's, so they are worked out before any slicing.
  const slug = githubSlugger();
  const ids = new Map<Token, string>();
  for (const token of all) {
    if (token.type === 'heading') ids.set(token, slug(plainText((token as Tokens.Heading).tokens)));
  }

  const firstTitle = all.find(
    (token): token is Tokens.Heading => token.type === 'heading' && (token as Tokens.Heading).depth === 1,
  );

  let tokens: Token[] = all;
  if (options.slice !== undefined) {
    const at = (text: string): number =>
      all.findIndex(
        (token) =>
          token.type === 'heading' &&
          (token as Tokens.Heading).depth === 2 &&
          plainText((token as Tokens.Heading).tokens) === text,
      );
    const from = at(options.slice.from);
    if (from === -1) {
      throw new Error(`${options.source} has no heading "## ${options.slice.from}" to start an article at`);
    }
    let until = all.length;
    if (options.slice.until !== undefined) {
      until = at(options.slice.until);
      if (until === -1 || until < from) {
        throw new Error(`${options.source} has no heading "## ${options.slice.until}" after "## ${options.slice.from}"`);
      }
    }
    tokens = all.slice(from, until);
  }
  // A reference-style link is resolved from the definitions of the whole file.
  const list = Object.assign(tokens.slice(), { links: all.links }) as TokensList;

  const headings: Heading[] = [];
  const renderer = {
    heading(this: { parser: { parseInline: (tokens: Token[]) => string } }, token: Tokens.Heading): string {
      const id = ids.get(token) ?? '';
      const html = this.parser.parseInline(token.tokens);
      if (token === firstTitle) return '';
      // One `<h1>` per page, and the page draws it.
      const depth = Math.max(2, token.depth);
      headings.push({ depth, id, html, text: plainText(token.tokens) });
      return `<h${depth} id="${escapeAttribute(id)}">${html}</h${depth}>\n`;
    },
    link(
      this: { parser: { parseInline: (tokens: Token[]) => string } },
      token: Tokens.Link,
    ): string {
      const text = this.parser.parseInline(token.tokens);
      const title = token.title ? ` title="${escapeAttribute(token.title)}"` : '';
      return `<a href="${escapeAttribute(options.resolveLink(token.href))}"${title}>${text}</a>`;
    },
  };
  marked.use({ renderer });

  const html = (marked.parser(list) as string)
    .replace(/<table>/g, '<div class="table-scroll"><table>')
    .replace(/<\/table>/g, '</table></div>')
    .replace(/<pre>([\s\S]*?)<\/pre>/g, `<div class="code-block" data-code><pre>$1</pre>${COPY_SLOT}</div>`);

  const paragraph = tokens.find((token): token is Tokens.Paragraph => token.type === 'paragraph');

  return {
    title: firstTitle === undefined ? null : plainText(firstTitle.tokens),
    titleHtml: firstTitle === undefined ? null : new Marked().parseInline(firstTitle.text) as string,
    html,
    headings,
    summary: paragraph === undefined ? '' : squash(plainText(paragraph.tokens)),
    markdown: tokens
      .filter((token) => token !== firstTitle)
      .map((token) => token.raw)
      .join('')
      .trim(),
  };
}

/** One line, single spaces: a paragraph wrapped at 80 columns reads as one sentence. */
function squash(text: string): string {
  return text.replace(/\s+/g, ' ').trim();
}

function escapeAttribute(text: string): string {
  return text.replace(/&/g, '&amp;').replace(/"/g, '&quot;').replace(/</g, '&lt;');
}
