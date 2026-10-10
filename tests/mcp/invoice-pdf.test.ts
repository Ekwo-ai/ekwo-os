/**
 * `render_invoice_pdf`: the PDF of a posted sale, through a real MCP client.
 *
 * The rendering itself is `packages/formats/invoice-pdf`'s to test. What is
 * asked here is the path: the four views read as the person signed in, the
 * logo fetched by the server — and only from a public address — the PDF
 * coming back as a resource a client can save, and `factur_x` embedding the
 * CII the e-invoicing adapter writes from the same books, which the Factur-X
 * reader reads back.
 */

import { Client } from '@modelcontextprotocol/sdk/client/index.js';
import { InMemoryTransport } from '@modelcontextprotocol/sdk/inMemory.js';
import type { PGlite } from '@electric-sql/pglite';
import { readFacturX } from '@ekwo-ai/factur-x/pdf';
import { PDFDocument, PDFName, PDFRawStream } from 'pdf-lib';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { buildServer } from '../../packages/mcp/src/index.js';
import type { LogoFetch } from '../../packages/core/src/index.js';
import { pngLogo } from '../../packages/formats/invoice-pdf/test/fixtures.js';
import { packIssuing, sale, seller, type Seller } from '../../modules/einvoicing/tests/helpers.js';
import { freshDatabase, one } from '../helpers/db.js';

type Content = { type: string; text?: string; resource?: { uri: string; mimeType?: string; blob?: string } };

let db: PGlite;
let s: Seller;
let client: Client;
const asked: string[] = [];

const logoFetch: LogoFetch = async (url) => {
  asked.push(url);
  const bytes = pngLogo();
  return { ok: true, status: 200, arrayBuffer: async () => bytes.slice().buffer };
};

async function render(args: Record<string, unknown>): Promise<{ isError: boolean; content: Content[] }> {
  const result = await client.callTool({ name: 'render_invoice_pdf', arguments: args });
  return { isError: result.isError === true, content: result.content as Content[] };
}

function pdfOf(content: Content[]): Uint8Array {
  const resource = content.find((c) => c.type === 'resource')?.resource;
  expect(resource?.mimeType).toBe('application/pdf');
  return new Uint8Array(Buffer.from(resource?.blob ?? '', 'base64'));
}

async function images(file: Uint8Array): Promise<number> {
  const doc = await PDFDocument.load(file);
  let n = 0;
  for (const [, object] of doc.context.enumerateIndirectObjects()) {
    if (object instanceof PDFRawStream && object.dict.get(PDFName.of('Subtype')) === PDFName.of('Image')) n++;
  }
  return n;
}

beforeAll(async () => {
  db = await freshDatabase();
  s = await seller(db, packIssuing('factur-x-en16931'), 'Rendering Seller', { enable: false });
  await db.query(`update companies set logo_url = 'https://logo.example.test/logo.png' where id = $1`, [s.companyId]);
  const server = buildServer(s.backend, { logoFetch });
  const [clientTransport, serverTransport] = InMemoryTransport.createLinkedPair();
  client = new Client({ name: 'test-client', version: '0.0.0' });
  await Promise.all([client.connect(clientTransport), server.connect(serverTransport)]);
}, 300_000);

afterAll(async () => {
  await client.close();
  await db.close();
});

describe('render_invoice_pdf', () => {
  it('returns the PDF of a posted sale as a resource, with its logo, and a summary beside it', async () => {
    const documentId = await sale(db, s);
    const { number } = await one<{ number: string }>(db, `select number from documents where id = $1`, [documentId]);
    const answer = await render({ document_id: documentId });
    expect(answer.isError).toBe(false);
    const summary = JSON.parse(answer.content[0]?.text ?? '{}') as Record<string, unknown>;
    expect(summary).toMatchObject({
      document_id: documentId,
      doc_type: 'sale_invoice',
      number,
      media_type: 'application/pdf',
      page_count: 1,
      logo: 'embedded',
      factur_x: null,
    });
    expect(asked).toContain('https://logo.example.test/logo.png');

    const file = pdfOf(answer.content);
    expect(file.byteLength).toBe(summary['byte_size']);
    const doc = await PDFDocument.load(file);
    expect(doc.getPageCount()).toBe(1);
    expect(doc.getTitle()).toContain(number);
    expect(await images(file)).toBe(1);
  });

  it('embeds the CII the books write, and the Factur-X reader reads the same invoice back', async () => {
    const documentId = await sale(db, s);
    const header = await one<{ number: string; amount_total: string }>(
      db,
      `select number, amount_total::text from documents where id = $1`,
      [documentId],
    );
    const answer = await render({ document_id: documentId, factur_x: true });
    expect(answer.isError).toBe(false);
    const summary = JSON.parse(answer.content[0]?.text ?? '{}') as { factur_x: { profile: string; violations: unknown[] } };
    expect(summary.factur_x.profile).toBe('en16931');
    expect(Array.isArray(summary.factur_x.violations)).toBe(true);

    const back = await readFacturX(pdfOf(answer.content));
    expect(back.profile).toBe('en16931');
    expect(back.invoice.number).toBe(header.number);
    expect(Number(back.invoice.totals.payable)).toBe(Number(header.amount_total));
  });

  it('renders a draft as a draft, and refuses to make a Factur-X invoice of it', async () => {
    const draft = await sale(db, s, { post: false });
    const plain = await render({ document_id: draft });
    expect(plain.isError).toBe(false);
    expect(JSON.parse(plain.content[0]?.text ?? '{}')).toMatchObject({ title: 'Draft invoice', filename: 'draft-invoice.pdf' });

    const refused = await render({ document_id: draft, factur_x: true });
    expect(refused.isError).toBe(true);
    expect(refused.content[0]?.text).toMatch(/^document_not_posted: /);
  });

  it('never fetches a logo from a local or private address, and renders without it', async () => {
    await db.query(`update companies set logo_url = 'http://127.0.0.1:8080/logo.png' where id = $1`, [s.companyId]);
    const before = asked.length;
    const answer = await render({ document_id: await sale(db, s) });
    expect(answer.isError).toBe(false);
    expect(asked.length).toBe(before);
    expect(JSON.parse(answer.content[0]?.text ?? '{}')['logo']).toMatch(/not fetched: 127\.0\.0\.1 is a private or local address/);
    expect(await images(pdfOf(answer.content))).toBe(0);
  });
});
