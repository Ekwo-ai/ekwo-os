/**
 * The model, printed as the AEAT's XML: one `RegistroAlta` or one
 * `RegistroAnulacion`, the two global elements of `SuministroInformacion.xsd`,
 * in its namespace.
 *
 * The order of the elements is the order of the schema, which is a sequence
 * and refuses anything else; `test/schema.test.ts` validates the records
 * against the published schema. A value the model does not have is an
 * element left out, never an element written empty: the schema then says
 * what is missing, and so does the violation beside it.
 *
 * The record is what the system keeps and what it sends. The envelope it is
 * sent in — `RegFactuSistemaFacturacion`, its `Cabecera`, the SOAP body and
 * the certificate — is the sender's, and is not written here. Neither is the
 * signature, which the AEAT requires of a record kept by a system that does
 * not send (NO VERI*FACTU) and not of one sent.
 */

import { ID_VERSION, NAMESPACE, TIPO_HUELLA } from './codes.js';
import type { AltaModel, AnulacionModel, DetailModel, Identifier, RecordModel, SystemModel } from './record.js';

function escapeXml(value: string): string {
  return value.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
}

type Node = string | null;

/** `<sf:name>text</sf:name>`, or nothing where there is no text. */
function leaf(name: string, value: string | null): Node {
  if (value === null || value === '') return null;
  return `<sf:${name}>${escapeXml(value)}</sf:${name}>`;
}

/** `<sf:name>children</sf:name>`, indented, or nothing where there are no children. */
function group(name: string, children: Node[]): Node {
  const present = children.filter((child): child is string => child !== null);
  if (present.length === 0) return null;
  const body = present.map((child) => child.replace(/^/gm, '  ')).join('\n');
  return `<sf:${name}>\n${body}\n</sf:${name}>`;
}

function identifier(value: Identifier): Node[] {
  if ('nif' in value) return [leaf('NIF', value.nif)];
  return [group('IDOtro', [leaf('CodigoPais', value.country), leaf('IDType', value.type), leaf('ID', value.id)])];
}

function chain(model: RecordModel): Node {
  const previous = model.chain.previous;
  if (previous === null) return group('Encadenamiento', [leaf('PrimerRegistro', 'S')]);
  return group('Encadenamiento', [
    group('RegistroAnterior', [
      leaf('IDEmisorFactura', previous.issuer),
      leaf('NumSerieFactura', previous.number),
      leaf('FechaExpedicionFactura', previous.issued),
      leaf('Huella', previous.hash),
    ]),
  ]);
}

function system(model: SystemModel): Node {
  return group('SistemaInformatico', [
    leaf('NombreRazon', model.producerName),
    ...identifier(model.producer),
    leaf('NombreSistemaInformatico', model.name),
    leaf('IdSistemaInformatico', model.id),
    leaf('Version', model.version),
    leaf('NumeroInstalacion', model.installation),
    leaf('TipoUsoPosibleSoloVerifactu', model.verifactuOnly),
    leaf('TipoUsoPosibleMultiOT', model.multipleTaxpayers),
    leaf('IndicadorMultiplesOT', model.multipleTaxpayersNow),
  ]);
}

function detail(model: DetailModel): Node {
  return group('DetalleDesglose', [
    leaf('Impuesto', model.tax),
    leaf('ClaveRegimen', model.regime),
    leaf('CalificacionOperacion', model.qualification),
    leaf('OperacionExenta', model.exemption),
    leaf('TipoImpositivo', model.rate),
    leaf('BaseImponibleOimporteNoSujeto', model.base),
    leaf('CuotaRepercutida', model.quota),
  ]);
}

function alta(model: AltaModel, hash: string): Node {
  return group('RegistroAlta', [
    leaf('IDVersion', ID_VERSION),
    group('IDFactura', [
      leaf('IDEmisorFactura', model.issuer),
      leaf('NumSerieFactura', model.number),
      leaf('FechaExpedicionFactura', model.issued),
    ]),
    leaf('NombreRazonEmisor', model.issuerName),
    leaf('TipoFactura', model.invoiceType),
    leaf('TipoRectificativa', model.rectificationKind),
    model.rectified === null
      ? null
      : group('FacturasRectificadas', [
          group('IDFacturaRectificada', [
            leaf('IDEmisorFactura', model.rectified.issuer),
            leaf('NumSerieFactura', model.rectified.number),
            leaf('FechaExpedicionFactura', model.rectified.issued),
          ]),
        ]),
    leaf('FechaOperacion', model.operationDate),
    leaf('DescripcionOperacion', model.description),
    leaf('Macrodato', model.macrodato ? 'S' : null),
    model.recipient === null
      ? null
      : group('Destinatarios', [
          group('IDDestinatario', [leaf('NombreRazon', model.recipient.name), ...identifier(model.recipient.identifier)]),
        ]),
    group('Desglose', model.details.map(detail)),
    leaf('CuotaTotal', model.totalTax),
    leaf('ImporteTotal', model.total),
    chain(model),
    system(model.system),
    leaf('FechaHoraHusoGenRegistro', model.generatedAt),
    leaf('TipoHuella', TIPO_HUELLA),
    leaf('Huella', hash),
  ]);
}

function anulacion(model: AnulacionModel, hash: string): Node {
  return group('RegistroAnulacion', [
    leaf('IDVersion', ID_VERSION),
    group('IDFactura', [
      leaf('IDEmisorFacturaAnulada', model.issuer),
      leaf('NumSerieFacturaAnulada', model.number),
      leaf('FechaExpedicionFacturaAnulada', model.issued),
    ]),
    chain(model),
    system(model.system),
    leaf('FechaHoraHusoGenRegistro', model.generatedAt),
    leaf('TipoHuella', TIPO_HUELLA),
    leaf('Huella', hash),
  ]);
}

/** The record as XML, UTF-8, its namespace declared on the root. */
export function writeRecord(model: RecordModel, hash: string): string {
  const body = (model.kind === 'alta' ? alta(model, hash) : anulacion(model, hash)) as string;
  const root = model.kind === 'alta' ? 'RegistroAlta' : 'RegistroAnulacion';
  return `<?xml version="1.0" encoding="UTF-8"?>\n${body.replace(`<sf:${root}>`, `<sf:${root} xmlns:sf="${NAMESPACE}">`)}\n`;
}
