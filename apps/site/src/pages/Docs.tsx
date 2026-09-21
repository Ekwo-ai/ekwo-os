/**
 * `/docs/` and every article under it — the manifesto among them, at the
 * address it has always had.
 *
 * The shape is a help centre's: a list of topics, each a handful of articles;
 * a sidebar that stays beside the article on a wide screen and folds into a
 * disclosure on a narrow one; the topic above the heading, so a reader knows
 * where they are; the previous and the next article at the foot, so the
 * documentation can be read in order.
 *
 * Nothing here is written for the site. An article is a Markdown file of the
 * repository rendered at build time (`data.ts`), and the page says which file
 * and links to it, so a correction goes where the text lives. The one sentence
 * the site adds is a note, from the strings, where the file leaves a reader to
 * work out on their own what does not exist yet.
 *
 * Search is an enhancement and costs no request: every entry of the list
 * carries its title, its first sentence and its headings in an attribute, and
 * the inline script at the end of the page hides what does not match. The box
 * ships `hidden`, so without scripting there is no field that does nothing —
 * and the whole list is there to read.
 */

import type { ReactNode } from 'react';
import { renderToStaticMarkup } from 'react-dom/server';
import type { DocArticle, SiteData } from '../data.js';
import { COPY_SLOT } from '../markdown.js';
import { TOPICS, type Topic } from '../data/docs.js';
import { fill, type Strings } from '../strings/index.js';
import { Glyph } from './icons.js';
import { Card, Eyebrow, Filter, Footer, Masthead, Out } from './ui.js';

/** What the list and the heading call an article. A format library is named by its README. */
export function labelOf(article: DocArticle, strings: Strings): string {
  const label = strings.docs.articles[article.slug]?.label;
  if (label !== undefined) return label;
  // Listed under its parent, a format library is its name without the scope
  // every one of them shares.
  const title = article.title ?? article.slug;
  return article.parent === null ? title : title.replace(/^@[^/]+\//, '');
}

export function titleOf(article: DocArticle, strings: Strings): string {
  return strings.docs.articles[article.slug]?.title ?? article.title ?? article.slug;
}

/** The sentence a link preview and a search result show: the file's first, cut at a word. */
export function descriptionOf(article: DocArticle, strings: Strings): string {
  const text =
    strings.docs.summaries[article.slug] ??
    (article.summary === '' ? strings.docs.topics[article.topic].lead : article.summary);
  if (text.length <= 180) return text;
  const cut = text.slice(0, 180);
  return `${cut.slice(0, cut.lastIndexOf(' '))}…`;
}

/** What the search box reads for an article: its names, its first sentence and its headings. */
function searchText(article: DocArticle, strings: Strings): string {
  return [
    labelOf(article, strings),
    titleOf(article, strings),
    article.summary,
    ...article.headings.filter((heading) => heading.depth === 2).map((heading) => heading.text),
  ]
    .join(' ')
    .toLowerCase();
}

/**
 * The button in the corner of every block of code, put where the Markdown left
 * a slot for it.
 *
 * It ships `hidden`, like the search field: the inline script reveals it where
 * the clipboard can be written, so without scripting the block is exactly the
 * file's and no button does nothing. It copies the block's text as the file
 * writes it — line breaks, a trailing `\` and all — and shows a tick for a
 * moment. It is always visible on a screen with no hover and on a phone, and
 * elsewhere when the block is hovered or the button has the focus.
 */
function copyButton(strings: Strings): string {
  return renderToStaticMarkup(
    <button
      type="button"
      data-copy-code
      hidden
      aria-label={strings.docs.copy}
      title={strings.docs.copy}
      className="code-copy rounded-sm border border-line bg-bg p-1.5 text-ink-faint transition-colors duration-150 hover:border-brand hover:text-brand-deep"
    >
      <span data-copy-idle>
        <Glyph name="copy" className="h-4 w-4" />
      </span>
      <span data-copy-done hidden>
        <Glyph name="check" className="h-4 w-4" />
      </span>
    </button>,
  );
}

function byTopic(docs: DocArticle[], topic: Topic): DocArticle[] {
  return docs.filter((article) => article.topic === topic && article.parent === null);
}

function childrenOf(docs: DocArticle[], parent: DocArticle): DocArticle[] {
  return docs.filter((article) => article.parent === parent.slug);
}

/** Every article, by topic: the sidebar of an article and the disclosure that replaces it. */
function ArticleList({
  docs,
  current,
  strings,
}: {
  docs: DocArticle[];
  current: DocArticle | null;
  strings: Strings;
}): ReactNode {
  const link = (article: DocArticle, small: boolean): ReactNode => {
    const here = current?.slug === article.slug;
    return (
      <a
        href={article.url}
        aria-current={here ? 'page' : undefined}
        className={`block rounded-sm px-2.5 py-1 no-underline transition-colors duration-150 hover:text-brand-deep ${
          here ? 'bg-brand-fill text-ink' : 'text-ink-soft'
        } ${small ? 'font-mono text-[0.8125rem]' : ''}`}
      >
        {labelOf(article, strings)}
      </a>
    );
  };
  return (
    <div data-filter-scope className="flex flex-col gap-6">
      <Filter label={strings.docs.search} />
      <nav aria-label={strings.docs.label} className="flex flex-col gap-6 text-sm">
        {TOPICS.map((topic) => {
          const articles = byTopic(docs, topic);
          if (articles.length === 0) return null;
          return (
            <div key={topic} data-filter-group>
              <p className="px-2.5 text-[0.6875rem] uppercase tracking-[0.14em] text-ink-faint">
                {strings.docs.topics[topic].title}
              </p>
              <ul className="mt-2 flex flex-col gap-0.5">
                {articles.map((article) => {
                  const children = childrenOf(docs, article);
                  return (
                    <li key={article.slug} data-filter-item data-search={searchText(article, strings)}>
                      {link(article, false)}
                      {children.length === 0 ? null : (
                        <ul className="mt-0.5 ml-2.5 flex flex-col gap-0.5 border-l border-line pl-1.5">
                          {children.map((child) => (
                            <li key={child.slug} data-filter-item data-search={searchText(child, strings)}>
                              {link(child, true)}
                            </li>
                          ))}
                        </ul>
                      )}
                    </li>
                  );
                })}
              </ul>
            </div>
          );
        })}
        <p data-filter-empty hidden className="px-2.5 text-ink-faint">
          {strings.docs.noMatch}
        </p>
      </nav>
    </div>
  );
}

export function DocsIndex({ data, strings }: { data: SiteData; strings: Strings }): ReactNode {
  const d = strings.docs;
  return (
    <>
      <Masthead measure="page" strings={strings} data={data} current="docs" />
      <main className="mx-auto max-w-page px-5 pt-16 pb-4 sm:pt-20">
        <Eyebrow>{d.eyebrow}</Eyebrow>
        <h1 className="mt-4 text-[clamp(2.5rem,1.8rem+3vw,3.75rem)]">{d.heading}</h1>
        <p className="mt-5 max-w-reading text-lg text-ink-soft">{d.lead}</p>

        <div data-filter-scope className="mt-10">
          <div className="max-w-md">
            <Filter label={strings.docs.search} />
          </div>
          {TOPICS.map((topic) => {
            const articles = byTopic(data.docs, topic);
            if (articles.length === 0) return null;
            return (
              <section key={topic} data-filter-group className="mt-14" aria-labelledby={`topic-${topic}`}>
                <h2 id={`topic-${topic}`} className="text-2xl">
                  {d.topics[topic].title}
                </h2>
                <p className="mt-2 max-w-reading text-ink-soft">{d.topics[topic].lead}</p>
                <ul className="mt-6 grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
                  {articles.map((article) => {
                    const children = childrenOf(data.docs, article);
                    return (
                      <li
                        key={article.slug}
                        data-filter-item
                        data-search={[article, ...children].map((a) => searchText(a, strings)).join(' ')}
                        className="min-w-0"
                      >
                        <Card className="flex h-full flex-col p-6">
                          <h3 className="text-lg">
                            <a href={article.url} className="text-ink no-underline hover:text-brand-deep">
                              {titleOf(article, strings)}
                            </a>
                          </h3>
                          <p className="mt-2 line-clamp-4 text-sm text-ink-soft">
                            {descriptionOf(article, strings)}
                          </p>
                          {children.length === 0 ? null : (
                            <ul className="mt-4 flex flex-wrap gap-x-3 gap-y-1.5 text-[0.8125rem]">
                              {children.map((child) => (
                                <li key={child.slug}>
                                  <a href={child.url} className="font-mono">
                                    {labelOf(child, strings)}
                                  </a>
                                </li>
                              ))}
                            </ul>
                          )}
                        </Card>
                      </li>
                    );
                  })}
                </ul>
              </section>
            );
          })}
          <p data-filter-empty hidden className="mt-10 text-ink-faint">
            {d.noMatch}
          </p>
        </div>
      </main>
      <Footer repository={data.repository} measure="page" strings={strings} />
    </>
  );
}

export function DocsArticle({
  article,
  data,
  strings,
}: {
  article: DocArticle;
  data: SiteData;
  strings: Strings;
}): ReactNode {
  const d = strings.docs;
  // The reading order is the order of the list: topic by topic, a parent before its children.
  const order = TOPICS.flatMap((topic) =>
    byTopic(data.docs, topic).flatMap((parent) => [parent, ...childrenOf(data.docs, parent)]),
  );
  const index = order.findIndex((entry) => entry.slug === article.slug);
  const previous = index > 0 ? order[index - 1] : undefined;
  const next = index >= 0 && index < order.length - 1 ? order[index + 1] : undefined;
  const note = d.notes[article.slug];
  const sections = article.headings.filter((heading) => heading.depth === 2);

  return (
    <>
      <Masthead measure="page" strings={strings} data={data} current="docs" />
      <div className="mx-auto grid max-w-page gap-10 px-5 pt-10 pb-4 lg:grid-cols-[14rem_minmax(0,1fr)] lg:gap-14 lg:pt-14 xl:grid-cols-[14rem_minmax(0,1fr)_12rem]">
        <aside className="hidden lg:block">
          <div className="sticky top-20 max-h-[calc(100vh-6rem)] overflow-y-auto pb-10">
            <ArticleList docs={data.docs} current={article} strings={strings} />
          </div>
        </aside>

        <main className="min-w-0">
          <details className="mb-8 rounded border border-line bg-paper lg:hidden">
            <summary className="flex items-center justify-between gap-3 px-4 py-3 text-sm text-ink">
              <span>{d.browse}</span>
              <Glyph name="menu" className="h-4 w-4 text-ink-faint" />
            </summary>
            <div className="border-t border-line p-4">
              <ArticleList docs={data.docs} current={article} strings={strings} />
            </div>
          </details>

          <p className="text-[0.6875rem] uppercase tracking-[0.16em] text-ink-faint">
            <a href="/docs/" className="text-ink-faint no-underline hover:text-brand-deep">
              {d.eyebrow}
            </a>
            <span aria-hidden> / </span>
            {d.topics[article.topic].title}
          </p>
          <h1 className="mt-4 max-w-[24ch] text-[clamp(2rem,1.5rem+2.4vw,3rem)]">
            {titleOf(article, strings)}
          </h1>

          {note === undefined ? null : (
            <p className="mt-6 max-w-[46rem] rounded border border-line bg-brand-fill px-4 py-3 text-sm text-ink-soft">
              {note}
            </p>
          )}

          <article
            className="prose mt-8 max-w-[46rem]"
            dangerouslySetInnerHTML={{ __html: article.html.split(COPY_SLOT).join(copyButton(strings)) }}
          />

          <nav
            aria-label={d.label}
            className="mt-16 grid max-w-[46rem] gap-3 border-t border-line pt-8 sm:grid-cols-2"
          >
            {previous === undefined ? (
              <span />
            ) : (
              <a
                href={previous.url}
                rel="prev"
                className="rounded border border-line bg-paper px-4 py-3 no-underline transition-colors duration-150 hover:border-brand-soft"
              >
                <span className="block text-xs text-ink-faint">{d.previous}</span>
                <span className="block text-sm text-ink">{labelOf(previous, strings)}</span>
              </a>
            )}
            {next === undefined ? null : (
              <a
                href={next.url}
                rel="next"
                className="rounded border border-line bg-paper px-4 py-3 text-right no-underline transition-colors duration-150 hover:border-brand-soft"
              >
                <span className="block text-xs text-ink-faint">{d.next}</span>
                <span className="block text-sm text-ink">{labelOf(next, strings)}</span>
              </a>
            )}
          </nav>

          <p className="mt-8 max-w-[46rem] text-sm text-ink-faint">
            {fill(d.renderedFrom, { path: article.source })}{' '}
            <Out href={data.repository.file(article.source)}>{d.viewSource}</Out>
          </p>
        </main>

        {sections.length < 2 ? null : (
          <aside className="hidden xl:block">
            <nav aria-label={d.onThisPage} className="sticky top-20 max-h-[calc(100vh-6rem)] overflow-y-auto pb-10 text-sm">
              <p className="text-[0.6875rem] uppercase tracking-[0.14em] text-ink-faint">{d.onThisPage}</p>
              <ul className="mt-3 flex flex-col gap-1.5 border-l border-line">
                {sections.map((heading) => (
                  <li key={heading.id}>
                    <a
                      href={`#${heading.id}`}
                      className="-ml-px block border-l border-transparent pl-3 text-ink-soft no-underline hover:border-brand hover:text-brand-deep"
                      dangerouslySetInnerHTML={{ __html: heading.html }}
                    />
                  </li>
                ))}
              </ul>
            </nav>
          </aside>
        )}
      </div>
      <Footer repository={data.repository} measure="page" strings={strings} />
    </>
  );
}
