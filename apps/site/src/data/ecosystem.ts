/**
 * The two rows that say what Ekwo connects to, and what it stands on.
 *
 * Both rows name things Ekwo does not own, so three rules hold here.
 *
 * **Every name is checked.** A model is listed only where its vendor documents
 * that the product can connect to Model Context Protocol servers — the `source`
 * of each entry is the page that says so, and it is kept here rather than in a
 * commit message so the next person can recheck it. Two candidates were left
 * out for failing that test, and what they document instead is written down in
 * `NOT_LISTED` at the bottom.
 *
 * **Nobody is featured.** Alphabetical order, one size, one weight, no
 * "recommended". The point of the row is that Ekwo is tied to none of them:
 * showing several, equally, is the only honest way to say that.
 *
 * **The marks belong to their owners.** The logos are `simple-icons`, which is
 * CC0, rendered in `currentColor` at one size; where `simple-icons` carries no
 * icon for a brand, the entry is a word in the same pill rather than a lookalike
 * drawn here or a file taken from a vendor's site.
 */

export interface Mark {
  /** What to print. Also the accessible name. */
  name: string;
  /** Basename in `src/icons/`, or null to print the name as a word. */
  icon: string | null;
  /** The page that proves the claim the row makes. Kept for rechecking. */
  source: string;
}

/**
 * Models and assistants that can drive Ekwo over MCP.
 *
 * Several of these document the support in their command-line or code product
 * rather than in their chat application, which is why the row is titled for the
 * choice rather than for the protocol. The distinction is real and is not worth
 * a footnote per pill on a home page; it is recorded here.
 */
export const MODELS: Mark[] = [
  {
    name: 'ChatGPT',
    // simple-icons removed the OpenAI mark in 2025 at the owner's request, so
    // this one is a word. It is not a gap to be filled with a lookalike.
    icon: null,
    source: 'https://developers.openai.com/api/docs/guides/developer-mode',
  },
  {
    name: 'Claude',
    icon: 'claude',
    source:
      'https://support.claude.com/en/articles/11175166-get-started-with-custom-connectors-using-remote-mcp',
  },
  {
    name: 'DeepSeek',
    icon: 'deepseek',
    source: 'https://github.com/deepseek-ai/deepseek-harness/blob/master/packages/mcp/README.md',
  },
  {
    name: 'Gemini',
    icon: 'googlegemini',
    source: 'https://docs.cloud.google.com/gemini/docs/codeassist/gemini-cli',
  },
  {
    name: 'Kimi',
    icon: 'kimi',
    source: 'https://moonshotai.github.io/kimi-code/en/customization/mcp.html',
  },
  {
    name: 'Mistral',
    icon: 'mistralai',
    source: 'https://docs.mistral.ai/le-chat/knowledge-integrations/connectors/mcp-connectors',
  },
  {
    name: 'Qwen',
    icon: 'qwen',
    source: 'https://qwenlm.github.io/qwen-code-docs/en/users/features/mcp/',
  },
];

/**
 * Asked for and not listed, with what their vendors document instead.
 *
 * Both support tool calling, which is most of the way there, and neither vendor
 * documents the product as a client of MCP servers. A third-party client can
 * drive either of them today; that is somebody else's page to make a claim on,
 * not this one. They go in the moment their own documentation says so.
 */
export const NOT_LISTED: { name: string; documents: string; source: string }[] = [
  {
    name: 'Llama',
    documents: 'tool calling, with MCP mentioned only in passing',
    source: 'https://ai.developer.meta.com/docs/features/tool-calling',
  },
  {
    name: 'Ollama',
    documents: 'tool calling; its MCP page is a server of its own documentation, not a client',
    source: 'https://docs.ollama.com/capabilities/tool-calling',
  },
];

/**
 * What Ekwo is built on and what it speaks.
 *
 * Only things with a brick, a dependency or a migration behind them in this
 * repository. No entry here implies a partnership of any kind: Ekwo runs on
 * these, and that is the whole of the relationship.
 */
export const FOUNDATIONS: Mark[] = [
  {
    name: 'Supabase',
    icon: 'supabase',
    source: 'https://github.com/supabase/supabase',
  },
  {
    name: 'PostgreSQL',
    icon: 'postgresql',
    source: 'https://www.postgresql.org/about/licence/',
  },
  {
    name: 'Model Context Protocol',
    icon: null,
    source: 'https://modelcontextprotocol.io',
  },
  {
    name: 'Peppol · EN 16931',
    icon: null,
    source: 'https://docs.peppol.eu/poacc/billing/3.0/',
  },
  {
    name: 'ISO 20022',
    icon: null,
    source: 'https://www.iso20022.org',
  },
  {
    name: 'Factur-X',
    icon: null,
    source: 'https://fnfe-mpe.org/factur-x/',
  },
  {
    name: 'XBRL',
    icon: null,
    source: 'https://www.xbrl.org',
  },
];
