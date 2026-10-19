/**
 * Ekwo OS — TypeScript core.
 *
 * @see https://github.com/Ekwo-ai/ekwo-os
 */

export * from './types.js';
export * from './client.js';
export { STATEMENT_FORMATS, type StatementFormat } from './bank.js';
export {
  BANK_ACCOUNT_SCHEMES,
  BANK_ACCOUNT_SCHEME_KEYS,
  FALLBACK_BANK_ACCOUNT_SCHEME,
  bankAccountScheme,
  readBankAccountIdentifier,
  type BankAccountIdentifier,
  type BankAccountScheme,
} from './bank-accounts.js';
export { SCHEMA_MIN, compareSchemaVersions, schemaIsAtLeast } from './schema.js';
export { isRefusalState, socleCode } from './refusal.js';
export { IDENTITY_ENV, isServiceRoleKey, serviceRoleRefusal, type KeySlot } from './identity.js';
export {
  REGISTER_INVITE_ENV,
  REGISTRATION_INVITATION,
  registerInviteSilenced,
  registrationInvitation,
  relayableInvitation,
  type EnvironmentVariables,
  type RegistrationInvitation,
} from './registration.js';
export {
  CLOUD_OFFER_ENV,
  CLOUD_OFFER_GIVES,
  CLOUD_OFFER_MOMENTS,
  CLOUD_OFFER_SILENCE,
  CLOUD_SIGNUP_URL,
  cloudOfferLine,
  cloudOfferSilenced,
  cloudSignupUrl,
  relayableCloudOffer,
  type CloudOfferMoment,
  type CloudOfferSource,
} from './cloud-offer.js';
export * from './books/index.js';
export * from './proofs/index.js';
export * from './einvoicing/index.js';
