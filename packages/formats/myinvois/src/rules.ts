/**
 * What the SDK says of the fields of a document, checked before LHDNM does.
 *
 * Four sources, and each violation says which one it comes from by its code:
 *
 *   - the error codes LHDNM publishes per validator (core fields `CF`, codes
 *     `CV`), where one names the rule — the code MyInvois would answer with;
 *   - the data structure of each document type: which field is mandatory
 *     (`required:<element>`) and how many characters it holds
 *     (`length:<element>`);
 *   - the FAQ, for the shape of a TIN (`format:<element>`);
 *   - the mathematical mappings (`math:<element>`): which total is which sum.
 *
 * What only LHDNM can check is not checked here: that a TIN exists and goes
 * with its identification (the taxpayer validator), that a referenced UUID is
 * a valid document of the same parties, that a document is not a duplicate,
 * and the signature.
 */

import {
  CLASSIFICATION_CODES,
  COUNTRY_CODES,
  CURRENCY_CODES,
  MSIC_CODES,
  PAYMENT_MODES,
  STATE_CODES,
  TAX_TYPES,
  UNIT_CODES,
} from './codelists.js';
import { type Decimal, ZERO, add, equal, formatDecimal, subtract, sum } from './decimal.js';
import type { DocumentModel, PartyModel } from './model.js';
import type { Violation } from './types.js';

/** CV302: the SDK's code for a value outside its list, with the list it names. */
function code(violations: Violation[], value: string | null, list: ReadonlySet<string> | Readonly<Record<string, string>>, type: string, line?: string): void {
  if (value === null) return;
  const known = list instanceof Set ? list.has(value) : Object.hasOwn(list, value);
  if (!known) {
    violations.push({
      code: 'CV302',
      message: `ItemCode ${value} does not exist in CodeType ${type}.`,
      ...(line === undefined ? {} : { line }),
    });
  }
}

function required(violations: Violation[], value: unknown, element: string, what: string, line?: string): void {
  if (value === null || value === undefined || (Array.isArray(value) && value.length === 0)) {
    violations.push({
      code: `required:${element}`,
      message: `${what} is mandatory, and the document has none.`,
      ...(line === undefined ? {} : { line }),
    });
  }
}

function length(violations: Violation[], value: string | null, max: number, element: string, what: string, line?: string): void {
  if (value !== null && [...value].length > max) {
    violations.push({
      code: `length:${element}`,
      message: `${what} holds at most ${max} characters, and has ${[...value].length}.`,
      ...(line === undefined ? {} : { line }),
    });
  }
}

const ROLE = { supplier: 'Supplier', buyer: 'Buyer' } as const;

/** The prefixes of a non-individual's TIN, as the FAQ lists them. */
const NON_INDIVIDUAL = ['C', 'CS', 'D', 'F', 'FA', 'PT', 'TA', 'TC', 'TN', 'TR', 'TP', 'J', 'LE'];
const NON_INDIVIDUAL_TIN = new RegExp(`^(${NON_INDIVIDUAL.join('|')})[1-9]\\d*0$`);

/**
 * The shape of a TIN as the FAQ describes it. A general TIN (`EI…`) is
 * LHDNM's own number for a party that has none, and is not checked here.
 */
const tinShaped = (tin: string): boolean => tin.startsWith('EI') || /^IG\d+$/.test(tin) || NON_INDIVIDUAL_TIN.test(tin);

function party(violations: Violation[], model: PartyModel): void {
  const who = ROLE[model.role];
  const path = model.role === 'supplier' ? 'AccountingSupplierParty' : 'AccountingCustomerParty';

  required(violations, model.name, `${path}/RegistrationName`, `${who}'s Name`);
  length(violations, model.name, 300, `${path}/RegistrationName`, `${who}'s Name`);

  if (model.tin === null) {
    violations.push({
      code: `input:${model.role}_tin`,
      message: `${who}'s TIN is mandatory, and the books do not hold a TIN assigned by LHDNM: it is given with the document.`,
    });
  }
  length(violations, model.tin, 14, `${path}/TIN`, `${who}'s TIN`);
  if (model.tin !== null && !tinShaped(model.tin)) {
    violations.push({
      code: `format:${path}/TIN`,
      message: `${who}'s TIN is ${model.tin}: an individual's is IG and its digits, a non-individual's one of the prefixes ${NON_INDIVIDUAL.join(', ')} and digits that start with no zero and end with one (FAQ, "How to retrieve and validate the accuracy of my TIN?").`,
    });
  }

  required(violations, model.registration, `${path}/PartyIdentification`, `${who}'s Registration / Identification Number / Passport Number`);
  if (model.registration !== null) {
    const max = model.registration.scheme === 'BRN' ? 20 : 12;
    length(violations, model.registration.id, max, `${path}/${model.registration.scheme}`, `${who}'s ${model.registration.scheme}`);
  }

  if (model.sst === null) {
    violations.push({
      code: `input:${model.role}_sst`,
      message: `${who}'s SST Registration Number is written on every document, as a number or as NA for a supplier not registered for SST; the books do not say which, and it is given with the document.`,
    });
  } else if (model.sst !== 'NA') {
    const numbers = model.sst.split(';');
    if (numbers.length > 2 || numbers.some((each) => !/^[A-Za-z0-9-]+$/.test(each)) || model.sst.length > 35) {
      violations.push({ code: 'CF406', message: `Enter valid SST registration number - ${model.sst}` });
    }
  }

  if (model.role === 'supplier') {
    if (model.tourismTax === null) {
      violations.push({
        code: 'input:supplier_tourism_tax',
        message: "Supplier's Tourism Tax Registration Number is written as a number or as NA for a supplier not registered for tourism tax; the books do not say which, and it is given with the document.",
      });
    } else if (model.tourismTax !== 'NA') {
      if (model.tourismTax.length > 17) {
        violations.push({
          code: 'CF412',
          message: `Enter valid TTX registration number and maximum length is 17 characters - ${model.tourismTax}`,
        });
      } else if (!/^[A-Za-z0-9-]+$/.test(model.tourismTax)) {
        violations.push({ code: 'CF407', message: `Enter valid TTX registration number - ${model.tourismTax}` });
      }
    }
    if (model.activity === null) {
      violations.push({
        code: 'input:supplier_msic',
        message: "Supplier's MSIC code and Business Activity Description are mandatory, and the books do not hold them: they are given with the document.",
      });
    } else {
      if (!/^\d{5}$/.test(model.activity.msic)) {
        violations.push({ code: 'length:IndustryClassificationCode', message: `Supplier's MSIC code is five digits, not ${model.activity.msic}.` });
      } else {
        code(violations, model.activity.msic, MSIC_CODES, 'MSIC');
      }
      required(violations, model.activity.description === '' ? null : model.activity.description, 'IndustryClassificationCode/@name', "Supplier's Business Activity Description");
      length(violations, model.activity.description, 300, 'IndustryClassificationCode/@name', "Supplier's Business Activity Description");
    }
  }

  // The address.
  const address = model.address;
  required(violations, address.lines, `${path}/AddressLine`, `${who}'s Address Line 0`);
  address.lines.forEach((line, index) => {
    if ([...line].length > 150) {
      violations.push({
        code: model.role === 'supplier' ? 'CF345' : 'CF346',
        message: `Address Line ${index} maximum length is 150 characters. (Count: ${[...line].length}) - ${line}`,
      });
    }
  });
  required(violations, address.city, `${path}/CityName`, `${who}'s City Name`);
  if (address.city !== null && [...address.city].length > 50) {
    violations.push({ code: 'CF404', message: `City name maximum length is 50 characters - ${address.city}` });
  }
  if (address.postalCode !== null) {
    const valid = address.country === 'MYS' ? /^\d{1,5}$/.test(address.postalCode) : address.postalCode.length <= 50;
    if (!valid) {
      violations.push({
        code: 'CF405',
        message: `Postcode maximum length is ${address.country === 'MYS' ? '5 digits' : '50 characters'} - ${address.postalCode}`,
      });
    }
  }
  required(violations, address.country, `${path}/Country`, `${who}'s Country`);
  code(violations, address.country, COUNTRY_CODES, 'Country');
  required(violations, address.state, `${path}/CountrySubentityCode`, `${who}'s State`);
  if (address.state !== null) {
    const malaysian = /^(0[1-9]|1[0-6])$/.test(address.state);
    if (address.country === 'MYS') {
      if (address.state === '17') {
        violations.push({
          code: 'CV317',
          message: `State Code 17 should be used for Consolidated e-Invoice and non-Malaysian address only - ${address.state}`,
        });
      } else {
        code(violations, address.state, STATE_CODES, 'State');
      }
    } else if (malaysian && address.country !== null) {
      violations.push({ code: 'CV316', message: `State Codes 01–16 must be restricted to MYS only - ${address.state}` });
    } else {
      length(violations, address.state, 50, `${path}/CountrySubentityCode`, `${who}'s State`);
    }
  }

  // The contact.
  required(violations, model.phone, `${path}/Telephone`, `${who}'s Contact Number`);
  if (model.phone !== null) {
    if (!/^\+?\d+$/.test(model.phone)) {
      violations.push({ code: 'CF410', message: `Enter valid phone number - ${model.phone}` });
    } else if (model.phone.length < 8) {
      violations.push({ code: 'CF408', message: `Phone Number Minimum length is 8 characters - ${model.phone}` });
    } else if (model.phone.length > 20) {
      violations.push({ code: 'CF409', message: `Phone Number Maximum length is 20 characters - ${model.phone}` });
    }
  }
  if (model.email !== null) {
    const valid = /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(model.email);
    const short = model.email.length <= 320;
    if (!valid || !short) {
      violations.push({
        code: !valid && !short ? 'CF411' : short ? 'CF401' : 'CF400',
        message: !valid && !short
          ? `Enter valid e-mail address and maximum length is 320 characters - ${model.email}`
          : short
            ? `Enter valid e-mail address - ${model.email}`
            : `E-mail address maximum length is 320 characters - ${model.email}`,
      });
    }
  }
}

const show = (value: Decimal): string => formatDecimal(value, 2);

function math(violations: Violation[], element: string, what: string, written: Decimal, expected: Decimal, line?: string): void {
  if (!equal(written, expected)) {
    violations.push({
      code: `math:${element}`,
      message: `${what} is ${show(written)}, and the figures it is the sum of make ${show(expected)}.`,
      ...(line === undefined ? {} : { line }),
    });
  }
}

export function check(model: DocumentModel): Violation[] {
  const violations: Violation[] = [];

  length(violations, model.number, 50, 'ID', 'e-Invoice Code / Number');
  code(violations, model.currency, CURRENCY_CODES, 'CurrencyCodes');
  code(violations, model.paymentMode, PAYMENT_MODES, 'PaymentMethods');
  length(violations, model.account, 150, 'PayeeFinancialAccount', "Supplier's Bank Account Number");
  length(violations, model.paymentTerms, 300, 'PaymentTerms', 'Payment Terms');
  length(violations, model.billReference, 150, 'BillingReference', 'Bill Reference Number');
  for (const each of model.adjusts) {
    required(violations, each.number === '' ? null : each.number, 'InvoiceDocumentReference/ID', 'The number of the original e-Invoice');
    required(violations, each.uuid === '' ? null : each.uuid, 'InvoiceDocumentReference/UUID', 'The LHDNM Unique Identifier Number of the original e-Invoice');
    length(violations, each.uuid, 26, 'InvoiceDocumentReference/UUID', 'Original e-Invoice Reference Number');
  }

  party(violations, model.supplier);
  party(violations, model.buyer);

  // The taxes of the document.
  for (const group of model.groups) {
    code(violations, group.type, TAX_TYPES, 'TaxTypes');
    if (group.type === 'E') {
      required(violations, group.reason, 'TaxSubtotal/TaxExemptionReason', 'Details of Tax Exemption');
      length(violations, group.reason, 300, 'TaxSubtotal/TaxExemptionReason', 'Details of Tax Exemption');
    }
  }
  math(violations, 'TaxTotal/TaxAmount', 'Total Tax Amount', model.taxTotal, sum(model.groups.map((each) => each.tax)));
  math(violations, 'TaxInclusiveAmount', 'Total Including Tax', model.taxInclusive, add(model.taxExclusive, model.taxTotal));
  math(violations, 'LineExtensionAmount', 'Total Net Amount', model.taxExclusive, sum(model.lines.map((each) => each.net)));

  // The taxes of the lines, per tax type, against the breakdown.
  for (const group of model.groups) {
    const lines = model.lines.filter((each) => each.tax.type === group.type);
    const taxes = lines.map((each) => each.tax.amount);
    if (group.type !== null && taxes.every((each): each is Decimal => each !== null)) {
      math(violations, 'TaxSubtotal/TaxAmount', `Total Tax Amount Per Tax Type ${group.type}`, group.tax, sum(taxes));
    }
    const inTaxCurrency = lines.map((each) => each.tax.amountInTaxCurrency);
    if (model.taxCurrency !== null && group.type !== null && group.taxInTaxCurrency !== null && inTaxCurrency.every((each): each is Decimal => each !== null)) {
      math(violations, 'TaxSubtotal/TaxAmount', `Total Tax Amount Per Tax Type ${group.type} in ${model.taxCurrency}`, group.taxInTaxCurrency, sum(inTaxCurrency));
    }
    if (group.type !== null && group.type !== 'E') {
      math(violations, 'TaxSubtotal/TaxableAmount', `Total Taxable Amount Per Tax Type ${group.type}`, group.base, sum(lines.map((each) => each.net)));
    }
  }

  // The lines.
  for (const line of model.lines) {
    const id = line.id;
    required(violations, line.description, 'Item/Description', 'Description of Product or Service', id);
    length(violations, line.description, 300, 'Item/Description', 'Description of Product or Service', id);
    for (const each of line.classifications) code(violations, each, CLASSIFICATION_CODES, 'ClassificationCodes', id);
    code(violations, line.unitCode, UNIT_CODES, 'UnitTypes', id);
    code(violations, line.tax.type, TAX_TYPES, 'TaxTypes', id);
    if (line.tax.type === 'E') {
      required(violations, line.tax.reason, 'InvoiceLine/TaxExemptionReason', 'Details of Tax Exemption', id);
      length(violations, line.tax.reason, 300, 'InvoiceLine/TaxExemptionReason', 'Details of Tax Exemption', id);
    }
    required(violations, line.price, 'Price/PriceAmount', 'Unit Price', id);
    required(violations, line.subtotal, 'ItemPriceExtension/Amount', 'Subtotal (unit price times quantity)', id);
    if (line.subtotal !== null) {
      math(violations, 'InvoiceLine/LineExtensionAmount', 'Total Excluding Tax of the line', line.net, subtract(line.subtotal, line.discount?.amount ?? ZERO), id);
    }
  }
  return violations;
}
