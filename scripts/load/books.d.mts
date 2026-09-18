/** Types for the load generator, so `tests/load/` can import it. */
export interface LoadClient {
  exec(sql: string): Promise<void>;
  query<T = Record<string, unknown>>(sql: string, params?: unknown[]): Promise<T[]>;
  transaction<T>(fn: (tx: LoadClient) => Promise<T>): Promise<T>;
}
export declare const COPIED_TABLES: string[];
export declare const NOT_COPIED_TABLES: string[];
export declare function generator(seed: number): () => number;
export declare function inventedNames(count: number, seed: number): string[];
export declare function multiplyBooks(
  db: LoadClient,
  options: { companyId: string; documents: number; years: number; contacts: number; seed: number },
): Promise<{ copies: number; contactSets: number; years: number; yearStart: string; yearDays: number }>;
export declare function bankStatementMonth(
  db: LoadClient,
  options: { companyId: string; lines: number; seed: number },
): Promise<{ statementId: string; bankAccountId: string; lines: number }>;
export declare function checkCoherence(db: LoadClient, companyId: string): Promise<string[]>;
export declare function fingerprint(db: LoadClient, companyId: string): Promise<string>;
