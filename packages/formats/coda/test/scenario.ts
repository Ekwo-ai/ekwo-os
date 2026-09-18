import { belgianReference, iban, type StatementSpec } from './build.js';

/**
 * One invented day on one invented account, with one of everything this
 * reader has to tell apart. Every name, account and reference is made up; the
 * IBANs carry real check digits on bank codes no bank has.
 */
export const CUSTOMER = iban('BE', '999000000202');
export const SUPPLIER = iban('FR', '9999900000000000000000199');
export const INVOICE_REFERENCE = belgianReference('2026000107');

export const golden: StatementSpec = {
  opening: 1_000_000n,
  fileReference: 'FILE000042',
  movements: [
    {
      sequence: 1,
      reference: 'REF0000000000000001',
      amount: 1_210_000n,
      valueDate: '050326',
      code: '00150000',
      structured: { type: '101', text: INVOICE_REFERENCE },
      customerReference: 'E2E-CLIENT-0001',
      counterpartyBic: 'ZZZZBEB2',
      counterpartyAccount: CUSTOMER,
      counterpartyCurrency: 'EUR',
      counterpartyName: 'CLIENT EXEMPLE UN',
      information: [
        {
          structured: {
            type: '001',
            text: 'CLIENT EXEMPLE UN SRL'.padEnd(70) + 'RUE INVENTEE 1'.padEnd(35) + '1000 VILLE EXEMPLE'.padEnd(35),
          },
        },
      ],
    },
    {
      sequence: 2,
      reference: 'REF0000000000000002',
      amount: -450_500n,
      valueDate: '040326',
      code: '00101000',
      free: 'FACTURE 2026-0042 DU 28 FEVRIER, MERCI DE VOTRE CONFIANCE ET A BIENTOT POUR LA SUITE DES TRAVAUX CONVENUS',
      counterpartyAccount: SUPPLIER,
      counterpartyName: 'FOURNISSEUR EXEMPLE',
      information: [{ free: 'ORDRE DONNE PAR LE CANAL EN LIGNE' }],
    },
    // A file of payments the customer sent, debited in one amount, and its details.
    {
      sequence: 3,
      reference: 'REF0000000000000003',
      amount: -920_000n,
      valueDate: '050326',
      code: '10101000',
      customerReference: 'LOT-SALAIRES-03',
      globalisation: '1',
    },
    {
      sequence: 3,
      detail: 1,
      reference: 'REF0000000000000003',
      amount: -500_000n,
      valueDate: '050326',
      code: '50101000',
      free: 'SALAIRE MARS',
      customerReference: 'E2E-SAL-0001',
      counterpartyAccount: iban('BE', '999000000303'),
      counterpartyName: 'PERSONNE EXEMPLE A',
    },
    {
      sequence: 3,
      detail: 2,
      reference: 'REF0000000000000003',
      amount: -420_000n,
      valueDate: '050326',
      code: '50101000',
      free: 'SALAIRE MARS',
      customerReference: 'E2E-SAL-0002',
      counterpartyAccount: iban('BE', '999000000404'),
      counterpartyName: 'PERSONNE EXEMPLE B',
      globalisation: '1',
    },
    // Charges: a simple amount with its detail, commission and tax.
    { sequence: 4, reference: 'REF0000000000000004', amount: -12_400n, valueDate: '050326', code: '33537000', free: 'FRAIS DE TENUE DE COMPTE' },
    { sequence: 4, detail: 1, reference: 'REF0000000000000004', amount: -10_250n, valueDate: '050326', code: '83537006', free: 'COMMISSION' },
    { sequence: 4, detail: 2, reference: 'REF0000000000000004', amount: -2_150n, valueDate: '050326', code: '83537011', free: 'TVA' },
    // A SEPA direct debit, in the structured communication the standard gives it.
    {
      sequence: 5,
      reference: 'REF0000000000000005',
      amount: -75_250n,
      valueDate: '050326',
      code: '00501000',
      structured: {
        type: '127',
        text:
          '050326' + '1' + '1' + '0' +
          'BE99ZZZ0999000123'.padEnd(35) +
          'MANDAT-EXEMPLE-0007'.padEnd(35) +
          'ABONNEMENT MARS'.padEnd(62) +
          '0' + '    ',
      },
      counterpartyName: 'CREANCIER EXEMPLE',
    },
    // A total made by the bank, a detail, and a detail that has details of its own.
    { sequence: 6, reference: 'REF0000000000000006', amount: 260_000n, valueDate: '050326', code: '20150000' },
    { sequence: 6, detail: 1, reference: 'REF000000000000006A', amount: 100_000n, valueDate: '050326', code: '60150000', free: 'ACOMPTE', counterpartyName: 'CLIENT EXEMPLE DEUX' },
    { sequence: 6, detail: 2, reference: 'REF000000000000006B', amount: 160_000n, valueDate: '050326', code: '70150000' },
    { sequence: 6, detail: 3, reference: 'REF000000000000006C', amount: 120_000n, valueDate: '050326', code: '90150000', free: 'SOLDE A', counterpartyName: 'CLIENT EXEMPLE TROIS' },
    { sequence: 6, detail: 4, reference: 'REF000000000000006D', amount: 40_000n, valueDate: '050326', code: '90150000', free: 'SOLDE B', counterpartyName: 'CLIENT EXEMPLE QUATRE' },
    // An ISO 11649 creditor reference.
    {
      sequence: 7,
      reference: 'REF0000000000000007',
      amount: 500_000n,
      code: '00150000',
      structured: { type: '100', text: 'RF18539007547034' },
      counterpartyName: 'CLIENT EXEMPLE CINQ',
    },
  ],
  free: ['VOTRE AGENCE SERA FERMEE LE LUNDI DE PAQUES'],
};

export const next: StatementSpec = {
  created: '070326',
  paperSequence: 43,
  codedSequence: 43,
  opening: 1_511_850n,
  openingDate: '050326',
  closingDate: '060326',
  movements: [
    { sequence: 1, reference: 'REF0000000000000101', amount: -11_850n, valueDate: '060326', entryDate: '060326', free: 'ACHAT PAR CARTE' },
  ],
};
