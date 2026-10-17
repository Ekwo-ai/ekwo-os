/**
 * The AEAT's own vocabulary: the namespace and version of the schema, the
 * lists of values of the *Diseño de registros* that this package writes, and
 * the error codes it reports, with the AEAT's own sentence for each.
 *
 * Every value here is copied from a published document, named beside it; the
 * README gives the URLs and the dates they were read.
 */

/** Target namespace of `SuministroInformacion.xsd`, which declares `RegistroAlta` and `RegistroAnulacion`. */
export const NAMESPACE =
  'https://www2.agenciatributaria.gob.es/static_files/common/internet/dep/aplicaciones/es/aeat/tike/cont/ws/SuministroInformacion.xsd';

/** `IDVersion`, list L15: the version of the record design, 1.0 since the Orden HAC/1177/2024. */
export const ID_VERSION = '1.0';

/** `TipoHuella`, list L12: `01` is SHA-256, the only algorithm allowed. */
export const TIPO_HUELLA = '01';

/** What `specification` names: the record design and the order that publishes it. */
export const SPECIFICATION = `VERI*FACTU registro de facturación ${ID_VERSION} (Orden HAC/1177/2024; SuministroInformacion.xsd)`;

/** List L1, `Impuesto`. */
export const IMPUESTO = ['01', '02', '03', '05'] as const;

/** List L2, `TipoFactura`: the rectifying ones. */
export const RECTIFYING_TYPES = ['R1', 'R2', 'R3', 'R4', 'R5'] as const;

/** List L8A, `ClaveRegimen` where the tax is IVA. */
export const CLAVE_REGIMEN_IVA = ['01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '14', '15', '17', '18', '19', '20'] as const;

/**
 * List L8B, `ClaveRegimen` where the tax is IGIC, with `20` and `21` the
 * document of validations adds (15.6, 15.6.11).
 */
export const CLAVE_REGIMEN_IGIC = ['01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '14', '15', '17', '18', '19', '20', '21'] as const;

/** The keys of the validations, 15.6, for IPSI. */
export const CLAVE_REGIMEN_IPSI = ['01', '08', '11', '18', '19', '20'] as const;

/** List L9, `CalificacionOperacion`. */
export const CALIFICACION = ['S1', 'S2', 'N1', 'N2'] as const;

/** List L10, `OperacionExenta`, with `E7` and `E8` the validations add for IGIC (15.5). */
export const OPERACION_EXENTA = ['E1', 'E2', 'E3', 'E4', 'E5', 'E6'] as const;
export const OPERACION_EXENTA_IGIC = ['E1', 'E2', 'E3', 'E4', 'E5', 'E6', 'E7', 'E8'] as const;

/**
 * The prefixes of a VAT number of another Member State, from the table
 * *Estructura NIF-IVA* of the validations (note 1): such a buyer is written
 * as `IDOtro` with `IDType` `02`. Greece is `EL`; Northern Ireland is `XI`,
 * `GB` being refused for an operation from 1 February 2021 (1255).
 */
export const NIF_IVA_PREFIXES = [
  'AT', 'BE', 'BG', 'CY', 'CZ', 'DE', 'DK', 'EE', 'EL', 'FI', 'FR', 'HR', 'HU', 'IE', 'IT', 'LT', 'LU', 'LV',
  'MT', 'NL', 'PL', 'PT', 'RO', 'SE', 'SI', 'SK', 'XI',
] as const;

/**
 * The error codes this package reports, with the sentence of
 * `errores.properties`, and the AEAT's category: `rejected` for the codes
 * that refuse the record (or the whole message), `accepted` for those under
 * which it is accepted with errors and must be corrected.
 */
export const AEAT_ERRORS = {
  '1100': ['rejected', 'Valor o tipo incorrecto del campo.'],
  '1102': ['rejected', 'El valor del campo IDType es incorrecto.'],
  '1104': ['rejected', 'El valor del campo NumSerieFactura es incorrecto.'],
  '1112': ['rejected', 'El campo FechaExpedicionFactura es superior a la fecha actual.'],
  '1124': ['rejected', 'El valor del campo TipoImpositivo no está incluido en la lista de valores permitidos.'],
  '1130': ['rejected', 'El campo NumSerieFactura contiene caracteres no permitidos.'],
  '1132': ['rejected', 'El valor del campo TipoImpositivo es incorrecto, el valor informado solo es permitido para FechaOperacion o FechaExpedicionFactura inferior o igual al año 2012.'],
  '1142': ['rejected', 'El campo CuotaRepercutida tiene un valor incorrecto para el valor de los campos BaseImponibleOimporteNoSujeto y TipoImpositivo suministrados.'],
  '1143': ['rejected', 'Los campos CuotaRepercutida y BaseImponibleOimporteNoSujeto deben tener el mismo signo.'],
  '1146': ['rejected', 'Sólo se permite que la fecha de expedicion de la factura sea anterior a la fecha operación si los detalles del desglose son ClaveRegimen 14 o 15 e Impuesto 01, 03 o vacío.'],
  '1150': ['rejected', 'Cuando TipoFactura sea F2 y no este informado NumRegistroAcuerdoFacturacion o FacturaSinIdentifDestinatarioArt61d no sea S el sumatorio de BaseImponibleOimporteNoSujeto y CuotaRepercutida de todas las líneas de detalle no podrá ser superior a 3.000.'],
  '1152': ['rejected', 'La fecha de expedición no puede ser inferior al 28 de octubre de 2024.'],
  '1173': ['rejected', 'Sólo se permite que la fecha de operación sea superior a la fecha actual si los detalles del desglose son ClaveRegimen 14 o 15 e Impuesto IVA(01) o IGIC(03) o vacío.'],
  '1174': ['rejected', 'El valor del campo FechaExpedicionFactura del bloque RegistroAnteriores incorrecto.'],
  '1175': ['rejected', 'El valor del campo NumSerieFactura del bloque RegistroAnterior es incorrecto.'],
  '1176': ['rejected', 'El valor de campo NIF del bloque SistemaInformatico es incorrecto.'],
  '1177': ['rejected', 'El valor de campo IdSistemaInformatico del bloque SistemaInformatico es incorrecto.'],
  '1179': ['rejected', 'Error en el bloque de SistemaInformatico.'],
  '1181': ['rejected', 'El valor del campo CalificacionOperacion es incorrecto.'],
  '1182': ['rejected', 'El valor del campo OperacionExenta es incorrecto.'],
  '1189': ['rejected', 'Si TipoFactura es F1 o F3 o R1 o R2 o R3 o R4 el bloque Destinatarios tiene que estar cumplimentado.'],
  '1190': ['rejected', 'Si TipoFactura es F2 o R5 el bloque Destinatarios no puede estar cumplimentado.'],
  '1194': ['rejected', 'El valor del campo TipoImpositivo es incorrecto, el valor informado solo es permitido para FechaOperacion o FechaExpedicionFactura posterior o igual a 1 de julio de 2022 e inferior o igual a 30 de septiembre de 2024.'],
  '1198': ['rejected', 'Si CalificacionOperacion tiene valor Operación Sujeta y No exenta - Con inversión del sujeto pasivo (S2) TipoImpositivo y CuotaRepercutida deberan tener valor 0.'],
  '1199': ['rejected', "Si Impuesto es '01' (IVA), '03' (IGIC) o no se cumplimenta y ClaveRegimen es 01 no pueden marcarse la OperacionExenta E2, E3."],
  '1207': ['rejected', 'La CuotaRepercutida solo podrá ser distinta de 0 si CalificacionOperacion es Operación Sujeta y No exenta - Sin inversión del sujeto pasivo (S1).'],
  '1208': ['rejected', 'Si CalificacionOperacion es Operación Sujeta y No exenta - Sin inversión del sujeto pasivo (S1) y BaseImponibleACoste no está cumplimentada, TipoImpositivo y CuotaRepercutida son obligatorios.'],
  '1212': ['rejected', 'El campo TipoUsoPosibleSoloVerifactu solo acepta valores N o S.'],
  '1213': ['rejected', 'El campo TipoUsoPosibleMultiOT solo acepta valores N o S.'],
  '1218': ['rejected', 'El valor del campo Impuesto es incorrecto.'],
  '1219': ['rejected', 'El valor del campo IDEmisorFactura es incorrecto.'],
  '1220': ['rejected', 'El valor del campo NombreSistemaInformatico es incorrecto.'],
  '1226': ['rejected', 'El campo IndicadorMultiplesOT solo acepta valores N o S.'],
  '1235': ['rejected', 'El valor del campo TipoImpositivo es incorrecto, el valor informado solo es permitido para FechaOperacion o FechaExpedicionFactura posterior o igual a 1 de octubre de 2024 e inferior o igual a 31 de diciembre de 2024.'],
  '1237': ['rejected', 'El valor del campo CalificacionOperacion está informado como Operación No sujeta (N1 o N2) y el impuesto es IVA. No se puede informar de los campos TipoImpositivo, CuotaRepercutida, TipoRecargoEquivalencia y CuotaRecargoEquivalencia.'],
  '1238': ['rejected', 'Si la operacion es exenta no se puede informar ninguno de los campos TipoImpositivo, CuotaRepercutida, TipoRecargoEquivalencia y CuotaRecargoEquivalencia.'],
  '1244': ['rejected', 'El campo FechaHoraHusoGenRegistro tiene un formato incorrecto.'],
  '1246': ['rejected', 'El valor del campo ClaveRegimen es incorrecto.'],
  '1252': ['rejected', 'Si ClaveRegimen es 08 el campo CalificacionOperacion tiene que tener el valor Operación No sujeta por reglas de localización (N2) e ir siempre informado.'],
  '1266': ['rejected', 'La longitud del campo cuota total no cumple con las especificaciones.'],
  '1267': ['rejected', 'La longitud del campo importe total no cumple con las especificaciones.'],
  '1269': ['rejected', 'El bloque Registro Anterior no esta informado correctamente.'],
  '1286': ['rejected', 'Si el impuesto es IVA(01), IGIC(03) o vacio, si ClaveRegimen es 02 solo se podrá informar OperacionExenta.'],
  '1291': ['rejected', 'El HASH del Registro anterior no es alfanumérico.'],
  '2002': ['accepted', 'La longitud de huella del registro anterior no cumple con las especificaciones.'],
  '2003': ['accepted', 'El contenido de la huella del registro anterior no cumple con las especificaciones.'],
  '2005': ['accepted', 'El campo ImporteTotal tiene un valor incorrecto para el valor de los campos BaseImponibleOimporteNoSujeto, CuotaRepercutida y CuotaRecargoEquivalencia suministrados.'],
  '2006': ['accepted', 'El campo CuotaTotal tiene un valor incorrecto para el valor de los campos CuotaRepercutida y CuotaRecargoEquivalencia suministrados.'],
  '4102': ['rejected', 'El XML no cumple el esquema. Falta informar campo obligatorio.'],
  '4113': ['rejected', 'El XML no cumple con el esquema: se ha superado el límite permitido de registros para el bloque.'],
} as const satisfies Record<string, readonly ['rejected' | 'accepted', string]>;

export type AeatErrorCode = keyof typeof AEAT_ERRORS;
