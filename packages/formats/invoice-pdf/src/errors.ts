/** Why a document could not be rendered. Each code is a refusal, never a guess. */
export type InvoicePdfErrorCode =
  /** Not a sale invoice or a sale credit note. */
  | 'not_a_sale_document'
  /** A field without which nothing honest can be printed: the currency, the date, an amount. */
  | 'missing_field'
  /** An amount or a rate that is not a decimal. */
  | 'invalid_value'
  /** A language tag `Intl` does not accept. */
  | 'invalid_language'
  /** A character no embedded font and no font of `options.fonts` has. */
  | 'glyph_not_covered'
  /** Hebrew, Arabic and the other scripts written right to left: refused rather than drawn reversed. */
  | 'right_to_left_text'
  /** A logo that is neither PNG nor JPEG, or that cannot be read as one. */
  | 'unsupported_logo'
  /** A font of `options.fonts` that cannot be read. */
  | 'unsupported_font';

export class InvoicePdfError extends Error {
  readonly code: InvoicePdfErrorCode;
  constructor(code: InvoicePdfErrorCode, message: string) {
    super(`${code}: ${message}`);
    this.name = 'InvoicePdfError';
    this.code = code;
  }
}
