/**
 * The shapes this package reads and returns.
 *
 * {@link FiledBox} is the row shape of `tax_filing_boxes` in
 * [Ekwo OS](https://github.com/Ekwo-ai/ekwo-os) — the figures of a declaration
 * as they were frozen at filing — declared here so that nothing is imported
 * from it. Any book-keeping system that can produce a box, what the box holds
 * and an amount can use this package; it reads no database and knows no
 * accounting.
 */

/**
 * One figure of a periodic VAT return: the grid it goes in, what it is, and
 * how much.
 */
export interface FiledBox {
  /**
   * The grid, as the form numbers it: `00`, `03`, `54`, `71`. Written with its
   * leading zero here or not, it goes out with one.
   */
  box: string;
  /**
   * What the figure is: `base`, `tax`, or `total` for one the form computes.
   * This form gives every grid one value, so two kinds on one grid is a
   * violation rather than a choice made here.
   */
  kind?: string | null;
  /** The amount. A string keeps the cents. */
  amount: string | number;
}

/** The party filing. */
export interface Declarant {
  /**
   * The Belgian enterprise number of the declarant, ten digits and no `BE`.
   * Anything else is refused rather than cleaned up.
   */
  vatNumber: string;
  name?: string;
  street?: string;
  postCode?: string;
  city?: string;
  /** ISO 3166-1 alpha-2 of the declarant's address. */
  countryCode?: string;
  emailAddress?: string;
  /** Digits only, country code included, as an administration stores it. */
  phone?: string;
}

/**
 * The period the return covers. Exactly one of `month` or `quarter`: a return
 * is filed on one cadence or the other, and the form has one element for each.
 */
export interface ReturnPeriod {
  year: number;
  month?: number;
  quarter?: number;
}

/**
 * What the declarant asks the administration for, which is a request and not a
 * consequence of the figures. Both default to no, because asking is a decision
 * and a file that asks by itself is a file nobody meant to send.
 */
export interface Ask {
  /** A refund of the credit this period ends on. */
  restitution?: boolean;
  /** The payment forms the administration sends out. */
  payment?: boolean;
}

export interface VatConsignmentOptions {
  declarant: Declarant;
  period: ReturnPeriod;
  /** Sequence number of this return inside the consignment. Default 1. */
  sequenceNumber?: number;
  /** The declarant's own reference for this filing, at most 14 characters. */
  declarantReference?: string;
  /**
   * The Intervat reference of the declaration this one replaces, as the
   * administration gave it back — `digits-ten digits-six digits`. A corrective
   * sent without it is an original, so a malformed one is refused outright
   * rather than left out.
   */
  replacedDeclaration?: string;
  ask?: Ask;
  /**
   * Whether the annual listing of customers will be nil, which the form asks on
   * the return of the last period of the year. The schema requires the element
   * on every return, so it is always written, and it defaults to `NO` — which
   * is the absence of a claim, not a claim that there will be a listing.
   */
  clientListingNihil?: boolean;
  /** Free text the administration displays with the filing. */
  comment?: string;
}

/**
 * The party that files for others: an accounting firm, a fiduciary, anyone
 * holding a mandate. The schema makes the whole block optional and **every
 * field of it required** once it is there, so every field is required here:
 * a representative is named entirely or not at all.
 */
export interface Representative {
  /** The identifier, as the authority that issued it writes it. */
  id: string;
  /** The member state that issued the identifier: one of {@link ISSUERS}. */
  issuedBy: string;
  /** What the identifier is: a VAT number, a tax identification number, or something else. */
  identificationType: 'NVAT' | 'TIN' | 'other';
  /** What `other` is. Written only with that type. */
  otherQualifier?: string;
  name: string;
  street: string;
  postCode: string;
  city: string;
  /** ISO 3166-1 alpha-2 of the representative's address. */
  countryCode: string;
  emailAddress: string;
  /** Digits are what is written; twenty at most. */
  phone: string;
}

/** One return of a consignment that holds several. */
export interface ConsignedReturn {
  boxes: FiledBox[];
  /**
   * What {@link VatConsignmentOptions} says, for this return. A sequence
   * number left out is the position of the return in the file, from 1.
   */
  options: VatConsignmentOptions;
}

/** What belongs to the consignment and not to any one return in it. */
export interface ConsignmentOptions {
  representative?: Representative;
  /** The representative's own reference for this consignment, at most 14 characters. */
  representativeReference?: string;
}

/** Something that does not add up, said in the terms of this format. */
export interface Violation {
  /** A stable token, for a caller that branches on it. */
  code: string;
  /** What is wrong, in a sentence. */
  message: string;
  /** The grid the trouble is on, where there is one. */
  box?: string;
  /**
   * The sequence number of the return the trouble is in, when the consignment
   * holds several. Absent on a consignment of one, where it would say nothing.
   */
  declaration?: number;
}

export interface VatConsignment {
  /** The XML, as text. */
  file: string;
  /** A name for it. See the README: the administration imposes none. */
  filename: string;
  /** Everything that could not be put in the file, and why. */
  violations: Violation[];
}
