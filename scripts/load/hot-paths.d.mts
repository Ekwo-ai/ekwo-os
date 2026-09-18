/** Types for the hot paths, so `tests/load/` can import them. */
export interface HotPathScope {
  companyId: string;
  yearFrom: string;
  yearTo: string;
  periodFrom: string;
  periodTo: string;
  accountId: string;
  statementId: string;
}
export interface HotPath {
  key: string;
  name: string;
  budgetMs: number;
  sql: string;
  params: unknown[];
  /** A narrower statement to record the plan of, where the whole path is too much to record. */
  planSql?: string;
  /** The same call over PostgREST: one function, or one call per line of a statement. */
  rpc: { fn: string; args: Record<string, unknown> } | { fn: string; perTransactionOf: string };
}
export interface RecordedPlan {
  query: string;
  plan: Record<string, unknown>;
}
export interface SequentialScan {
  table: string;
  rows: number;
  removed: number;
  filter: string | null;
  query: string;
}
export declare const LARGE_TABLES: string[];
export declare const RECORD_PLANS: string;
export declare const STOP_RECORDING: string;
export declare function hotPaths(scope: HotPathScope): HotPath[];
export declare function planRecorder(): {
  plans: RecordedPlan[];
  counts: { statements: number; capabilityChecks: number };
  onNotice(notice: unknown): void;
};
export declare function nodesOf(plan: Record<string, unknown>): Generator<Record<string, unknown>>;
export declare function largeSequentialScans(plans: RecordedPlan[]): SequentialScan[];
export declare function accessOf(plans: RecordedPlan[]): string[];
export declare function rowsReadOf(plans: RecordedPlan[]): number;
