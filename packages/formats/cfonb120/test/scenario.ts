import { ibanOf } from '../src/checks.js';
import type { StatementSpec } from './build.js';

/**
 * One invented month on one invented account, with one of everything this
 * reader has to tell apart. Every name, account and reference is made up, on a
 * bank code no bank has.
 */
export const SUPPLIER = ibanOf('FR', '99999', '00001', '00000000202') as string;
export const CUSTOMER = ibanOf('FR', '99999', '00001', '00000000303') as string;

export const golden: StatementSpec = {
  opening: 100_000n,
  movements: [
    // A SEPA credit transfer received, with everything the 2010 complement restitutes.
    {
      amount: 121_000n,
      bookingDate: '050326',
      valueDate: '050326',
      label: 'VIR SEPA CLIENT EXEMPLE UN',
      interbankCode: '05',
      internalCode: 'V001',
      complements: [
        { qualifier: 'NPY', text: 'CLIENT EXEMPLE UN SARL' },
        { qualifier: 'IPY', text: 'ZZZZFRP1', second: 'BICOrBEI' },
        { qualifier: 'NPO', text: 'GROUPE EXEMPLE' },
        { qualifier: 'LCC', text: 'FACTURE 2026-0107 DU 28 FEVRIER 2026 - CHANTIER RUE INVENTEE - MERCI P' },
        { qualifier: 'LC2', text: 'OUR VOTRE CONFIANCE' },
        { qualifier: 'RCN', text: 'E2E-CLIENT-0001', second: 'SUPP' },
        { qualifier: 'REF', text: 'REMISE-0042', second: 'TRANSACTION-0007' },
      ],
    },
    // A credit transfer sent.
    {
      amount: -45_050n,
      bookingDate: '060326',
      valueDate: '050326',
      label: 'VIR SEPA FOURNISSEUR EXEMPLE',
      interbankCode: '06',
      complements: [
        { qualifier: 'NBE', text: 'FOURNISSEUR EXEMPLE SAS' },
        { qualifier: 'CBE', text: SUPPLIER },
        { qualifier: 'LCS', text: 'RF18539007547034' },
        { qualifier: 'LIB', text: 'REGLEMENT FACTURE F-0042' },
      ],
    },
    // A cheque, which has a number and nothing else.
    { amount: -1_240n, bookingDate: '100326', label: 'CHEQUE 0000123', interbankCode: '01', entryNumber: 123 },
    // A SEPA direct debit paid.
    {
      amount: -7_525n,
      bookingDate: '120326',
      label: 'PRLV SEPA CREANCIER EXEMPLE',
      interbankCode: 'B1',
      complements: [
        { qualifier: 'NBE', text: 'CREANCIER EXEMPLE' },
        { qualifier: 'IBE', text: 'FR99ZZZ999999', second: 'SEPA' },
        { qualifier: 'RUM', text: 'MANDAT-EXEMPLE-0007', second: 'RCUR' },
        { qualifier: 'LCC', text: 'ABONNEMENT MARS' },
      ],
    },
    // A direct debit the company issued, come back unpaid.
    {
      amount: -6_000n,
      bookingDate: '160326',
      label: 'IMPAYE PRLV SEPA',
      interbankCode: 'A3',
      rejectCode: '04',
      complements: [
        { qualifier: 'NPY', text: 'CLIENT EXEMPLE DEUX' },
        { qualifier: 'NBE', text: 'ATELIER EXEMPLE' },
        { qualifier: 'CPY', text: CUSTOMER },
      ],
    },
    // A transfer received in another currency: what moved is in the account's, what was ordered is beside it.
    {
      amount: 50_000n,
      bookingDate: '200326',
      label: 'VIR ETRANGER RECU',
      interbankCode: '21',
      unavailable: '1',
      complements: [
        { qualifier: 'MMO', text: 'USD' + '2' + '00000000054321' + '04' + '00000010864' },
        { qualifier: 'ZZ1', text: 'UN QUALIFIANT PROPRE A LA BANQUE' },
      ],
    },
  ],
};

export const next: StatementSpec = {
  opening: 211_185n,
  openingDate: '310326',
  closingDate: '300426',
  movements: [{ amount: -11_185n, bookingDate: '020426', label: 'CARTE X1234 01/04' }],
};
