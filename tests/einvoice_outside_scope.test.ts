import { describe, expect, it } from 'vitest';
import { EINVOICE_FORMATS, type EinvoiceSource } from '@ekwo-ai/core';
import { CASES } from '../packages/formats/peppol-ubl/test/fixtures/cases.js';

/**
 * A sale outside the scope of VAT, as each format of EN 16931 writes it.
 *
 * A service supplied to a business established outside the European Union is
 * booked in category O, and the books keep the VAT numbers of both parties:
 * the printed invoice shows them. EN 16931 refuses them on the structured
 * file (BR-O-02), and a network that plays the rule refuses the file. So every
 * writer of the standard leaves them out of a document that is wholly in that
 * category, and names the seller by its registration number (BT-30), which
 * BR-CO-26 takes in their place.
 *
 * The document is one of the files the published Schematron was played
 * against (`family-o-vat-numbers`, valid), handed to the two writers as the
 * three views publish it.
 */
const given = CASES.find((each) => each.name === 'family-o-vat-numbers');
if (given === undefined) throw new Error('the case family-o-vat-numbers is gone from the fixtures of @ekwo-ai/peppol-ubl');

const source: EinvoiceSource = {
  header: given.input.header as unknown as EinvoiceSource['header'],
  lines: given.input.lines as unknown as EinvoiceSource['lines'],
  taxes: given.input.taxes as unknown as EinvoiceSource['taxes'],
  preceding: null,
};

const codes = (profile: string): string[] => (EINVOICE_FORMATS[profile]?.write(source).violations ?? []).map((each) => each.code);
const content = (profile: string): string => EINVOICE_FORMATS[profile]?.write(source).content ?? '';

describe('a sale outside the scope of VAT, on a structured invoice', () => {
  it('is handed over by the books with the VAT numbers of both parties', () => {
    expect(source.header['seller_vat_number']).toBe('BE0999999922');
    expect(source.header['buyer_vat_number']).toBe('NL999999999B01');
    expect(source.header['seller_registration_number']).toBeTruthy();
  });

  it('names nobody by a VAT number as Peppol BIS Billing 3.0', () => {
    expect(codes('peppol-bis-3')).not.toContain('BR-O-02');
    expect(codes('peppol-bis-3')).not.toContain('BR-CO-26');
    expect(content('peppol-bis-3')).not.toContain('<cac:PartyTaxScheme>');
    expect(content('peppol-bis-3')).toContain('<cac:PartyLegalEntity>');
  });

  it('names nobody by a VAT number as Factur-X, and the seller by its registration number', () => {
    const file = content('factur-x-en16931');
    expect(file).toContain('<ram:CategoryCode>O</ram:CategoryCode>');
    expect(file).not.toContain('schemeID="VA"');
    expect(file).not.toContain('<ram:SpecifiedTaxRegistration>');
    expect(file).toMatch(/<ram:SellerTradeParty>[\s\S]*<ram:SpecifiedLegalOrganization><ram:ID>[^<]+<\/ram:ID>/);
    expect(codes('factur-x-en16931')).not.toContain('BR-CO-26');
  });

  it('keeps the numbers of a document that charges VAT', () => {
    const standard = CASES.find((each) => each.name === 'invoice-standard');
    if (standard === undefined) throw new Error('the case invoice-standard is gone');
    const charged: EinvoiceSource = {
      header: standard.input.header as unknown as EinvoiceSource['header'],
      lines: standard.input.lines as unknown as EinvoiceSource['lines'],
      taxes: standard.input.taxes as unknown as EinvoiceSource['taxes'],
      preceding: null,
    };
    expect(EINVOICE_FORMATS['peppol-bis-3']?.write(charged).content).toContain('<cac:PartyTaxScheme>');
    expect(EINVOICE_FORMATS['factur-x-en16931']?.write(charged).content).toContain('schemeID="VA"');
  });
});
