/**
 * The two transcripts, as a terminal with tabs.
 *
 * One tab is a person typing commands, the next is an agent calling the same
 * functions with the same rights. The second is the whole of "AI does the
 * bookkeeping, you stay in control", shown instead of said: the agent drafts,
 * shows the entry it would write, and **stops to ask** before anything is
 * booked. The third is Claude Code in a terminal, asked in plain words to
 * bring a folder of invoices into the books — with what Claude does
 * itself (reading a PDF) kept apart from what the Ekwo
 * server does, because only the second is this project's to claim.
 *
 * The tabs are radio buttons and labels, so they work with no scripting at all
 * — the panel of the checked radio is the one displayed, and a radio group
 * already moves under the arrow keys. Where the inline script has not run, the
 * stylesheet shows every panel one under the other, each keeping its heading,
 * so nothing is behind a control that does not exist.
 *
 * Every line of both transcripts is in the HTML. The reveal is a CSS animation
 * with a per-line delay and `both` fill; reduced motion turns the delays off
 * and the whole session is simply there.
 */

import type { ReactNode } from 'react';
import { MCP_PREFIX, type Demo, type TermLine } from '../demo.js';
import { fill, type Strings } from '../strings/index.js';

/** One line of a session, drawn by what kind of line it is. */
function Line({ line, index }: { line: TermLine; index: number }): ReactNode {
  const style = { ['--i' as string]: String(index) };
  const body = (): ReactNode => {
    switch (line.kind) {
      case 'command':
        // The prompt is the one a Mac's shell draws. It is not the dollar sign
        // on purpose: on a page about books kept in every currency, the one
        // currency symbol the eye meets first should not be somebody's prompt.
        return (
          <span>
            <span className="text-brand-deep select-none">% </span>
            <span className="text-ink">{line.text}</span>
          </span>
        );
      case 'ask':
        return (
          <span>
            <span className="text-brand-deep select-none">› </span>
            <span className="text-ink">{line.text}</span>
          </span>
        );
      case 'answer':
        return (
          <span>
            <span className="text-brand-deep select-none">› </span>
            <span className="text-ink">{line.text}</span>
          </span>
        );
      case 'say':
        return <span className="text-ink-soft">{line.text}</span>;
      case 'dim':
        return <span className="text-ink-faint">{line.text}</span>;
      default:
        return <span className="text-ink-soft">{line.text}</span>;
    }
  };
  return (
    <div className="term-line" style={style}>
      {body()}
    </div>
  );
}

function Session({ lines, title }: { lines: TermLine[]; title: string }): ReactNode {
  return (
    <div className="min-w-0 overflow-hidden rounded-lg border border-line bg-paper shadow-lift">
      <div className="flex items-center gap-2 border-b border-line px-4 py-2.5">
        <span className="h-2.5 w-2.5 rounded-pill bg-line" aria-hidden />
        <span className="h-2.5 w-2.5 rounded-pill bg-line" aria-hidden />
        <span className="h-2.5 w-2.5 rounded-pill bg-line" aria-hidden />
        <span className="ml-2 font-mono text-xs text-ink-faint">{title}</span>
      </div>
      <div className="overflow-x-auto px-4 py-4">
        <pre className="font-mono text-[0.8125rem] leading-relaxed whitespace-pre">
          {lines.map((line, index) => (
            <Line key={index} line={line} index={index} />
          ))}
          <div
            className="term-caret text-brand-deep"
            style={{ ['--i' as string]: String(lines.length) }}
            aria-hidden
          >
            ▌
          </div>
        </pre>
      </div>
    </div>
  );
}

/**
 * Claude Code's rhythm, in milliseconds. A person types a character every
 * `KEY`; the prompt is sent `SEND` after the last one; Claude works for
 * `THINK` with its indicator showing; then a line of the transcript lands
 * every `LINE`.
 */
const KEY = 45;
const LEAD = 500;
const SEND = 350;
const THINK = 1300;
const LINE = 230;

/** A tool call, split where Claude Code's terminal splits it: the name in bold, the arguments after. */
function splitCall(text: string): [string, string] {
  const at = text.startsWith(MCP_PREFIX) ? text.indexOf('(MCP)') + '(MCP)'.length : text.indexOf('(');
  return at <= 0 ? [text, ''] : [text.slice(0, at), text.slice(at)];
}

/**
 * The Claude Code session — a prompt and what Claude does with it — drawn the
 * way its terminal draws one.
 *
 * The prompt sits in the bordered input box behind `>`, and is typed: every
 * character is its own span, taking no room until its moment comes, so the
 * caret after them moves along as a person's would. Then Claude's working
 * indicator, `✻`, in the terminal's orange; then the transcript — `⏺` before
 * everything Claude says or calls, green before a call as the terminal draws a
 * call that succeeded, the tool's name in bold, and what the tool answered
 * dimmed and hung under `⎿`.
 *
 * All of it is in the HTML, and all the motion is CSS. With scripting off the
 * session plays the same; asked for less motion, every animation is off and
 * the whole session is simply there, indicator and caret removed. The prompt
 * is read once, whole, by a screen reader: the typed copy is `aria-hidden`.
 */
function ClaudeSession({ lines, title }: { lines: TermLine[]; title: string }): ReactNode {
  const prompt = lines.find((line) => line.kind === 'prompt')?.text ?? '';
  const typed = LEAD + prompt.length * KEY;
  const sent = typed + SEND;
  const working = sent + THINK;
  const at = (ms: number) => ({ ['--t' as string]: `${ms}ms` });
  const bullet = (className: string): ReactNode => (
    <span className={`select-none ${className}`} aria-hidden>
      {'\u23FA\uFE0E'}
    </span>
  );

  let previous: TermLine['kind'] | null = null;
  const body = lines
    .filter((line) => line.kind !== 'prompt')
    .map((line, index) => {
      const after = previous;
      previous = line.kind;
      const style = at(working + index * LINE);
      switch (line.kind) {
        case 'tool': {
          const [name, args] = splitCall(line.text);
          return (
            <div key={index} className="cc-line cc-in mt-3" style={style}>
              {bullet('text-ok')}
              <span>
                <span className="font-semibold text-ink">{name}</span>
                <span className="text-ink-soft">{args}</span>
              </span>
            </div>
          );
        }
        case 'out':
        case 'dim': {
          // The first line of an answer hangs under `⎿`; the ones after it line up with it.
          const first = after !== 'out' && after !== 'dim';
          return (
            <div key={index} className="cc-line cc-in" style={style}>
              <span />
              <span className="cc-result text-ink-faint">
                <span className="select-none" aria-hidden>
                  {first ? '⎿' : ''}
                </span>
                <span>{line.text}</span>
              </span>
            </div>
          );
        }
        default:
          // What Claude says, the question it ends on among it.
          return (
            <div key={index} className="cc-line cc-in mt-3" style={style}>
              {bullet('text-ink')}
              <span className="text-ink">{line.text}</span>
            </div>
          );
      }
    });

  return (
    <div className="min-w-0 overflow-hidden rounded-lg border border-line bg-paper shadow-lift">
      <div className="flex items-center gap-2 border-b border-line px-4 py-2.5">
        <span className="h-2.5 w-2.5 rounded-pill bg-line" aria-hidden />
        <span className="h-2.5 w-2.5 rounded-pill bg-line" aria-hidden />
        <span className="h-2.5 w-2.5 rounded-pill bg-line" aria-hidden />
        <span className="ml-2 font-mono text-xs text-ink-faint">{title}</span>
      </div>
      <div className="px-4 py-4 font-mono text-[0.8125rem] leading-relaxed">
        <div className="cc-line rounded-sm border border-line px-3 py-2">
          <span className="select-none text-ink-faint" aria-hidden>
            {'>'}
          </span>
          <span className="text-ink">
            <span className="sr-only">{prompt}</span>
            <span aria-hidden>
              {[...prompt].map((character, index) => (
                <span key={index} className="cc-char" style={at(LEAD + index * KEY)}>
                  {character}
                </span>
              ))}
              <span className="cc-caret text-ink-soft" style={at(sent)}>
                ▌
              </span>
            </span>
          </span>
        </div>
        <div className="cc-line cc-thinking mt-3 text-claude" style={at(sent)} aria-hidden>
          <span>✻</span>
          <span>Thinking…</span>
        </div>
        {body}
      </div>
    </div>
  );
}

export function Demos({
  demo,
  strings,
  icons,
}: {
  demo: Demo;
  strings: Strings;
  icons: Record<string, string>;
}): ReactNode {
  const a = strings.home.automation;

  const mark = icons['claude'];
  return (
    <figure className="m-0 min-w-0">
      <div className="tabs min-w-0">
        <div className="flex gap-6 border-b border-line text-sm">
          <input type="radio" name="demo" id="demo-cli" defaultChecked />
          <label htmlFor="demo-cli" className="tab-label pb-2.5">
            {a.tabs.cli}
          </label>
          <input type="radio" name="demo" id="demo-agent" />
          <label htmlFor="demo-agent" className="tab-label pb-2.5">
            {a.tabs.agent}
          </label>
          {demo.claude === null ? null : (
            <>
              <input type="radio" name="demo" id="demo-claude" />
              <label htmlFor="demo-claude" className="tab-label inline-flex items-center gap-2 pb-2.5">
                {mark === undefined ? null : (
                  <svg viewBox="0 0 24 24" className="h-3.5 w-3.5 fill-current" aria-hidden>
                    <path d={mark} />
                  </svg>
                )}
                {a.tabs.claude}
              </label>
            </>
          )}
        </div>

        <div className="mt-5 grid min-w-0 gap-6">
          <div data-panel="cli" className="min-w-0">
            <Session lines={demo.cli} title={`${a.tabs.cli.toLowerCase()} — ekwo`} />
            <p className="mt-3 text-sm text-ink-faint">
              {fill(a.cliCaption, { country: demo.country })}
            </p>
          </div>
          <div data-panel="agent" className="min-w-0">
            <Session lines={demo.agent} title={`${a.tabs.agent.toLowerCase()} — ekwo`} />
            <p className="mt-3 text-sm text-ink-faint">
              {fill(a.agentCaption, { country: demo.country })}
            </p>
          </div>
          {demo.claude === null ? null : (
            <div data-panel="claude" className="min-w-0">
              <ClaudeSession lines={demo.claude} title={`${a.tabs.claude.toLowerCase()} — ekwo`} />
              <p className="mt-3 text-sm text-ink-faint">
                {fill(a.claudeCaption, { country: demo.country })}
              </p>
            </div>
          )}
        </div>
      </div>
      <figcaption className="mt-4 text-sm text-ink-faint">{a.demoNote}</figcaption>
    </figure>
  );
}
