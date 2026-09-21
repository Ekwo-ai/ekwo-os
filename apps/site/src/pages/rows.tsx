/**
 * The status table, defined once.
 *
 * A country page prints these rows in one column and `/compare/` prints them in
 * two. They are one list because the alternative — a table per page — is how
 * two pages come to answer the same question differently, and because a row
 * added here appears in both places the day it is written.
 *
 * Every cell is a function of the description and nothing else. There is no
 * country here, no currency, no count: what a row shows is what the pack said,
 * and where the pack said nothing the row shows that.
 *
 * The labels and the words a silence is reported with come from the language,
 * not from here; the `key` of a row is what ties the two together and is the
 * one string in this file a translation does not touch.
 */

import type { ReactNode } from 'react';
import type { PackDescription } from '../../../../packages/cli/src/index.js';
import type { Repository } from '../data.js';
import type { Strings } from '../strings/index.js';
import { Mono, NotYet, Out } from './ui.js';

export interface StatusRow {
  /** Stable identifier: the anchor of the row, and what a language names it by. */
  key: string;
  label: string;
  hint: string;
  cell: (country: PackDescription, repository: Repository) => ReactNode;
}

/** A list, or a stated nothing. */
function list(values: readonly string[], empty: string): ReactNode {
  if (values.length === 0) return <NotYet>{empty}</NotYet>;
  return values.map((value, index) => (
    <span key={value}>
      {index > 0 ? ', ' : ''}
      <Mono>{value}</Mono>
    </span>
  ));
}

/** When a declaration is due, as the country's rule reads in words. */
function deadlineWords(
  deadline: NonNullable<PackDescription['declarations'][number]['deadline']>,
  n: Strings['notYet'],
): string {
  if (deadline.rule === 'depends_on_taxpayer') return n['dependsOnTaxpayer'] as string;
  const after =
    deadline.rule === 'day_of_month_after_period'
      ? `day ${deadline.day ?? '?'} of the month after the period`
      : 'the last day of the month after the period';
  return deadline.plusDays === null ? after : `${after}, plus ${deadline.plusDays} days`;
}

/** The rows, in the language given. */
export function statusRows(s: Strings): StatusRow[] {
  const n = s.notYet;
  const row = (key: string, cell: StatusRow['cell']): StatusRow => {
    const words = s.rows[key];
    if (words === undefined) throw new Error(`the language ${s.lang} names no row ${key}`);
    return { key, label: words.label, hint: words.hint, cell };
  };

  return [
    row('charts', (country) => (
      <ul className="space-y-1">
        {country.charts.map((chart) => (
          <li key={chart.code}>
            <Mono>{chart.code}</Mono>
            {chart.isDefault ? (
              <span className="text-ink-faint"> ({n['defaultChart']})</span>
            ) : null}
            <span className="text-ink-faint">
              {' '}
              — {chart.accounts} {n['accounts']}
              {chart.audience === null ? '' : `, ${n['forAudience']} ${chart.audience}`}
            </span>
          </li>
        ))}
      </ul>
    )),

    row('taxes', (country) => (
      <div className="space-y-1">
        <div>
          {country.taxes.count} taxes
          {country.taxes.rates.length === 0 ? null : (
            <span className="text-ink-faint">
              {' '}
              {n['taxesAt']} {country.taxes.rates.join(', ')}
            </span>
          )}
        </div>
        <div className="text-ink-faint">{list(country.taxes.treatments, n['noTreatment'] as string)}</div>
      </div>
    )),

    row('declaration', (country) =>
      country.declarations.length === 0 ? (
        <NotYet>{n['noDeclaration']}</NotYet>
      ) : (
        <ul className="space-y-1">
          {country.declarations.map((declaration) => (
            <li key={declaration.code}>
              <Mono>{declaration.code}</Mono>
              <span className="text-ink-faint">
                {' '}
                — {declaration.boxes} {n['boxes']}, {n['filed']} {declaration.periods.join(' or ')}
              </span>
            </li>
          ))}
        </ul>
      ),
    ),

    row('deadline', (country) => {
      if (country.declarations.length === 0) return <NotYet>{n['nothingDue']}</NotYet>;
      return (
        <ul className="space-y-1">
          {country.declarations.map((declaration) => (
            <li key={declaration.code}>
              {declaration.deadline === null ? (
                <NotYet>{n['deadlineUndeclared']}</NotYet>
              ) : (
                <span>{deadlineWords(declaration.deadline, n)}</span>
              )}
            </li>
          ))}
        </ul>
      );
    }),

    row('file', (country, repository) => {
      if (country.declarations.length === 0) return <NotYet>{n['nothingToDeposit']}</NotYet>;
      return (
        <ul className="space-y-1">
          {country.declarations.map((declaration) => (
            <li key={declaration.code}>
              {declaration.file.byHand ? (
                <NotYet>{n['byHand']}</NotYet>
              ) : (
                <Out href={repository.dir(`packages/formats/${declaration.file.brick as string}`)}>
                  <Mono>{declaration.file.brick}</Mono>
                </Out>
              )}
            </li>
          ))}
        </ul>
      );
    }),

    row('einvoicing', (country) =>
      country.einvoicing === null ? (
        <NotYet>{n['noProfile']}</NotYet>
      ) : (
        <div className="space-y-1">
          <div>
            {country.einvoicing.profile === null ? (
              <span>{n['noProfileNamed']}</span>
            ) : (
              <Mono>{country.einvoicing.profile}</Mono>
            )}
            {country.einvoicing.mandatoryFrom === null ? (
              <span className="text-ink-faint">
                {' '}
                {country.einvoicing.obligation === 'none' ? (
                  <>— {n['noObligation']}</>
                ) : country.einvoicing.obligation === 'on_request' ? (
                  <>— {n['onRequest']}</>
                ) : (
                  <NotYet>{n['noObligationDate']}</NotYet>
                )}
              </span>
            ) : (
              <span className="text-ink-faint">
                {' '}
                — {n['mandatoryFrom']} {country.einvoicing.mandatoryFrom}
              </span>
            )}
          </div>
          {country.einvoicing.legalReference === null ? (
            <div>
              <NotYet>{n['noLegalReference']}</NotYet>
            </div>
          ) : (
            <p className="text-sm text-ink-faint">{country.einvoicing.legalReference}</p>
          )}
        </div>
      ),
    ),

    row('balance', (country) => (
      <ul className="space-y-1">
        <li>
          <span className="text-ink-faint">{n['payable']} </span>
          {country.vatBalance.payable === null ? (
            <NotYet>{n['noAccount']}</NotYet>
          ) : (
            <Mono>{country.vatBalance.payable}</Mono>
          )}
        </li>
        <li>
          <span className="text-ink-faint">{n['receivable']} </span>
          {country.vatBalance.receivable === null ? (
            <NotYet>{n['noAccount']}</NotYet>
          ) : (
            <Mono>{country.vatBalance.receivable}</Mono>
          )}
        </li>
      </ul>
    )),

    row('bank', (country) =>
      country.bankStatementFormats.length === 0 ? (
        <NotYet>{n['noFormat']}</NotYet>
      ) : (
        <ul className="space-y-1">
          {country.bankStatementFormats.map((format) => (
            <li key={format.format}>
              <Mono>{format.format}</Mono>{' '}
              {format.read ? (
                <span className="text-ink-faint">— {n['read']}</span>
              ) : (
                <NotYet>{n['noReader']}</NotYet>
              )}
            </li>
          ))}
        </ul>
      ),
    ),

    row('payments', (country) => list(country.paymentFormats, n['noFormat'] as string)),

    row('statements', (country) =>
      country.statements.length === 0 ? (
        <NotYet>{n['genericStatements']}</NotYet>
      ) : (
        <ul className="space-y-1">
          {country.statements.map((statement) => (
            <li key={statement.code}>
              <Mono>{statement.code}</Mono>
              <span className="text-ink-faint">
                {' '}
                — {statement.lines} {n['lines']}
              </span>
              {statement.taxonomy === null ? null : (
                <span className="text-ink-faint">, {statement.taxonomy}</span>
              )}
            </li>
          ))}
        </ul>
      ),
    ),

    row('certification', (country) => (
      <div className="space-y-1">
        <div>
          <Mono>{country.certification.status}</Mono>
          {country.certification.reviewedBy === null ? (
            <span className="text-ink-faint">
              {' '}
              <NotYet>{n['noReviewer']}</NotYet>
            </span>
          ) : (
            <span className="text-ink-faint">
              {' '}
              — {country.certification.reviewedBy}
              {country.certification.reviewedOn === null
                ? ''
                : ` · ${country.certification.reviewedOn}`}
            </span>
          )}
        </div>
        <div className="text-ink-faint">
          {country.certification.sources.length} {n['sourcesCited']}
        </div>
      </div>
    )),

    row('checked', (country) =>
      country.certification.lastConsultedOn === null ? (
        <NotYet>{n['noSourceDay']}</NotYet>
      ) : (
        <span>{country.certification.lastConsultedOn}</span>
      ),
    ),

    row('version', (country) => (
      <div className="space-y-1">
        <div>
          <Mono>{country.version}</Mono>
          {country.releasedAt === null ? (
            <span className="text-ink-faint">
              {' '}
              <NotYet>{n['noReleaseDate']}</NotYet>
            </span>
          ) : (
            <span className="text-ink-faint">
              {' '}
              — {n['published']} {country.releasedAt}
            </span>
          )}
        </div>
        <div className="text-ink-faint">{list(country.languages, n['noLanguage'] as string)}</div>
      </div>
    )),
  ];
}
