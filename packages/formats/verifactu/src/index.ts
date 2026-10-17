/**
 * Spain's VERI*FACTU: the invoicing record (*registro de facturación*) an
 * invoicing system keeps for every invoice it issues — *de alta* when the
 * invoice is issued, *de anulación* when its record is cancelled — with the
 * SHA-256 fingerprint that chains it to the record before, and the URL the QR
 * code of the invoice carries.
 *
 * Give it a posted document as the books hold it, the system that generates
 * the record and the record before it, and it writes the XML of the AEAT
 * schema, its fingerprint, and every rule of the AEAT the record breaks, by
 * the AEAT's own error code.
 *
 * It keeps no chain, reads no database and sends nothing: which record came
 * before is the caller's to say, and the sending — a certificate, a SOAP
 * envelope, the AEAT's flow control — is the host's. Sources are in the
 * README. It depends on nothing.
 */

export {};
