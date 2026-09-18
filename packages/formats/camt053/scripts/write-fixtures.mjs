// Writes test/fixtures/golden.camt.053.001.NN.xml — one invented statement,
// said thirteen times, in each version of the message ISO publishes a schema
// for that shares this shape (02 to 14; 01 is another message in all but name).
//
// The statement is the same in every file; what changes is what the versions
// changed: `BIC` became `BICFI` in 03, a transaction got an amount of its own
// in 03, the entry status became a choice and a party moved under `Pty` in 07.
// `test/golden.test.ts` holds every file against the schema of its version and
// expects the same lines out of all thirteen.
//
// Nothing here is real: the account holder, the counterparties and the bank do
// not exist, and the IBANs carry valid check digits over bank codes nobody was
// issued. Run with `node scripts/write-fixtures.mjs`; the output is committed.

import { mkdirSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const out = join(dirname(fileURLToPath(import.meta.url)), '..', 'test', 'fixtures');
mkdirSync(out, { recursive: true });

const VERSIONS = ['02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12', '13', '14'];

function golden(version) {
  const v = Number(version);
  const bic = v >= 3 ? 'BICFI' : 'BIC';
  const booked = (code) => (v >= 7 ? `<Sts><Cd>${code}</Cd></Sts>` : `<Sts>${code}</Sts>`);
  const party = (name) => (v >= 7 ? `<Pty><Nm>${name}</Nm></Pty>` : `<Nm>${name}</Nm>`);
  // From 03 on a transaction says its own amount; in 02 it can only do so
  // under AmtDtls/TxAmt.
  const own = (amount, direction) =>
    v >= 3
      ? `<Amt Ccy="EUR">${amount}</Amt><CdtDbtInd>${direction}</CdtDbtInd>`
      : `<AmtDtls><TxAmt><Amt Ccy="EUR">${amount}</Amt></TxAmt></AmtDtls>`;
  const code = (domain, family, sub) =>
    `<BkTxCd><Domn><Cd>${domain}</Cd><Fmly><Cd>${family}</Cd><SubFmlyCd>${sub}</SubFmlyCd></Fmly></Domn></BkTxCd>`;
  const balance = (type, amount, date) => `
      <Bal>
        <Tp><CdOrPrtry><Cd>${type}</Cd></CdOrPrtry></Tp>
        <Amt Ccy="EUR">${amount}</Amt>
        <CdtDbtInd>CRDT</CdtDbtInd>
        <Dt><Dt>${date}</Dt></Dt>
      </Bal>`;

  return `<?xml version="1.0" encoding="UTF-8"?>
<!-- An invented statement. No account, party or bank in this file exists. -->
<Document xmlns="urn:iso:std:iso:20022:tech:xsd:camt.053.001.${version}">
  <BkToCstmrStmt>
    <GrpHdr>
      <MsgId>MSG-2026-03-0001</MsgId>
      <CreDtTm>2026-04-01T06:00:00+02:00</CreDtTm>
    </GrpHdr>
    <Stmt>
      <Id>STMT-2026-003</Id>
      <ElctrncSeqNb>3</ElctrncSeqNb>
      <LglSeqNb>3</LglSeqNb>
      <CreDtTm>2026-04-01T06:00:00+02:00</CreDtTm>
      <FrToDt>
        <FrDtTm>2026-03-01T00:00:00+01:00</FrDtTm>
        <ToDtTm>2026-03-31T23:59:59+02:00</ToDtTm>
      </FrToDt>
      <Acct>
        <Id><IBAN>BE96999000000101</IBAN></Id>
        <Ccy>EUR</Ccy>
        <Nm>Current account</Nm>
        <Ownr><Nm>Atelier Exemple</Nm></Ownr>
        <Svcr><FinInstnId><${bic}>ZZZZBEB1</${bic}></FinInstnId></Svcr>
      </Acct>${balance('OPBD', '1000.00', '2026-03-01')}${balance('CLBD', '1562.36', '2026-03-31')}
      <Ntry>
        <NtryRef>1</NtryRef>
        <Amt Ccy="EUR">1210.00</Amt>
        <CdtDbtInd>CRDT</CdtDbtInd>
        ${booked('BOOK')}
        <BookgDt><Dt>2026-03-03</Dt></BookgDt>
        <ValDt><Dt>2026-03-03</Dt></ValDt>
        <AcctSvcrRef>ZZ26030300001</AcctSvcrRef>
        ${code('PMNT', 'RCDT', 'ESCT')}
        <NtryDtls>
          <TxDtls>
            <Refs><AcctSvcrRef>ZZ26030300001</AcctSvcrRef><EndToEndId>E2E-CLIENT-0042</EndToEndId></Refs>
            ${own('1210.00', 'CRDT')}
            <RltdPties>
              <Dbtr>${party('Client Exemple &amp; Fils')}</Dbtr>
              <DbtrAcct><Id><IBAN>FR499999900000000000010199</IBAN></Id></DbtrAcct>
              <UltmtDbtr>${party('Groupe Exemple')}</UltmtDbtr>
              <Cdtr>${party('Atelier Exemple')}</Cdtr>
              <CdtrAcct><Id><IBAN>BE96999000000101</IBAN></Id></CdtrAcct>
            </RltdPties>
            <RltdAgts><DbtrAgt><FinInstnId><${bic}>ZZZZFRP1</${bic}></FinInstnId></DbtrAgt></RltdAgts>
            <RmtInf>
              <Strd>
                <CdtrRefInf>
                  <Tp><CdOrPrtry><Cd>SCOR</Cd></CdOrPrtry><Issr>ISO</Issr></Tp>
                  <Ref>RF73INV20260042</Ref>
                </CdtrRefInf>
              </Strd>
            </RmtInf>
          </TxDtls>
        </NtryDtls>
      </Ntry>
      <Ntry>
        <NtryRef>2</NtryRef>
        <Amt Ccy="EUR">450.50</Amt>
        <CdtDbtInd>DBIT</CdtDbtInd>
        ${booked('BOOK')}
        <BookgDt><Dt>2026-03-05</Dt></BookgDt>
        <ValDt><Dt>2026-03-04</Dt></ValDt>
        <AcctSvcrRef>ZZ26030500002</AcctSvcrRef>
        ${code('PMNT', 'ICDT', 'ESCT')}
        <NtryDtls>
          <TxDtls>
            <Refs><EndToEndId>NOTPROVIDED</EndToEndId></Refs>
            ${own('450.50', 'DBIT')}
            <RltdPties>
              <Dbtr>${party('Atelier Exemple')}</Dbtr>
              <Cdtr>${party('Fournisseur Fictif')}</Cdtr>
              <CdtrAcct><Id><IBAN>NL68ZZZZ0000000606</IBAN></Id></CdtrAcct>
            </RltdPties>
            <RmtInf><Ustrd>Invoice 2026-0107</Ustrd><Ustrd>thank you</Ustrd></RmtInf>
          </TxDtls>
        </NtryDtls>
      </Ntry>
      <Ntry>
        <NtryRef>3</NtryRef>
        <Amt Ccy="EUR">450.50</Amt>
        <CdtDbtInd>CRDT</CdtDbtInd>
        <RvslInd>true</RvslInd>
        ${booked('BOOK')}
        <BookgDt><Dt>2026-03-06</Dt></BookgDt>
        <ValDt><Dt>2026-03-06</Dt></ValDt>
        <AcctSvcrRef>ZZ26030600003</AcctSvcrRef>
        ${code('PMNT', 'ICDT', 'RRTN')}
        <NtryDtls>
          <TxDtls>
            <Refs><EndToEndId>NOTPROVIDED</EndToEndId></Refs>
            ${own('450.50', 'CRDT')}
            <RltdPties>
              <Dbtr>${party('Atelier Exemple')}</Dbtr>
              <Cdtr>${party('Fournisseur Fictif')}</Cdtr>
              <CdtrAcct><Id><IBAN>NL68ZZZZ0000000606</IBAN></Id></CdtrAcct>
            </RltdPties>
            <RmtInf><Ustrd>Invoice 2026-0107</Ustrd></RmtInf>
            <RtrInf><Rsn><Cd>AC04</Cd></Rsn><AddtlInf>Account closed</AddtlInf></RtrInf>
          </TxDtls>
        </NtryDtls>
      </Ntry>
      <Ntry>
        <NtryRef>4</NtryRef>
        <Amt Ccy="EUR">12.40</Amt>
        <CdtDbtInd>DBIT</CdtDbtInd>
        ${booked('BOOK')}
        <BookgDt><Dt>2026-03-10</Dt></BookgDt>
        <ValDt><Dt>2026-03-10</Dt></ValDt>
        <AcctSvcrRef>ZZ26031000004</AcctSvcrRef>
        ${code('ACMT', 'MDOP', 'CHRG')}
        <AddtlNtryInf>Account fees, first quarter</AddtlNtryInf>
      </Ntry>
      <Ntry>
        <NtryRef>5</NtryRef>
        <Amt Ccy="EUR">920.00</Amt>
        <CdtDbtInd>DBIT</CdtDbtInd>
        ${booked('BOOK')}
        <BookgDt><Dt>2026-03-12</Dt></BookgDt>
        <ValDt><Dt>2026-03-13</Dt></ValDt>
        <AcctSvcrRef>ZZ26031200005</AcctSvcrRef>
        ${code('PMNT', 'ICDT', 'XBCT')}
        <NtryDtls>
          <TxDtls>
            <Refs><EndToEndId>E2E-USD-0001</EndToEndId></Refs>
            ${v >= 3 ? '<Amt Ccy="EUR">920.00</Amt><CdtDbtInd>DBIT</CdtDbtInd>' : ''}
            <AmtDtls>
              <InstdAmt>
                <Amt Ccy="USD">1000.00</Amt>
                <CcyXchg><SrcCcy>EUR</SrcCcy><TrgtCcy>USD</TrgtCcy><XchgRate>0.92</XchgRate></CcyXchg>
              </InstdAmt>
            </AmtDtls>
            <RltdPties>
              <Cdtr>${party('Example Supplies Inc')}</Cdtr>
              <CdtrAcct><Id><Othr><Id>999999992 0000123456</Id><SchmeNm><Prtry>ROUTING ACCOUNT</Prtry></SchmeNm></Othr></Id></CdtrAcct>
            </RltdPties>
            <RmtInf><Ustrd>PO 7781</Ustrd></RmtInf>
          </TxDtls>
        </NtryDtls>
      </Ntry>
      <Ntry>
        <NtryRef>6</NtryRef>
        <Amt Ccy="EUR">300.00</Amt>
        <CdtDbtInd>CRDT</CdtDbtInd>
        ${booked('BOOK')}
        <BookgDt><Dt>2026-03-17</Dt></BookgDt>
        <ValDt><Dt>2026-03-17</Dt></ValDt>
        <AcctSvcrRef>ZZ26031700006</AcctSvcrRef>
        ${code('PMNT', 'RCDT', 'ESCT')}
        <NtryDtls>
          <Btch><NbOfTxs>3</NbOfTxs><TtlAmt Ccy="EUR">300.00</TtlAmt><CdtDbtInd>CRDT</CdtDbtInd></Btch>
          <TxDtls>
            <Refs><AcctSvcrRef>ZZ26031700006-1</AcctSvcrRef><EndToEndId>E2E-A</EndToEndId></Refs>
            ${own('100.00', 'CRDT')}
            <RltdPties><Dbtr>${party('Premier Payeur')}</Dbtr><DbtrAcct><Id><IBAN>LU589990000000000404</IBAN></Id></DbtrAcct></RltdPties>
            <RmtInf><Ustrd>Invoice 2026-0050</Ustrd></RmtInf>
          </TxDtls>
          <TxDtls>
            <Refs><AcctSvcrRef>ZZ26031700006-2</AcctSvcrRef><EndToEndId>E2E-B</EndToEndId></Refs>
            ${own('120.00', 'CRDT')}
            <RltdPties><Dbtr>${party('Second Payeur')}</Dbtr><DbtrAcct><Id><IBAN>EE209900000000000505</IBAN></Id></DbtrAcct></RltdPties>
            <RmtInf><Ustrd>Invoice 2026-0051</Ustrd></RmtInf>
          </TxDtls>
          <TxDtls>
            <Refs><AcctSvcrRef>ZZ26031700006-3</AcctSvcrRef><EndToEndId>E2E-C</EndToEndId></Refs>
            ${own('80.00', 'CRDT')}
            <RltdPties><Dbtr>${party('Troisième Payeur')}</Dbtr><DbtrAcct><Id><IBAN>DE43999999990000000707</IBAN></Id></DbtrAcct></RltdPties>
            <RmtInf><Ustrd>Invoice 2026-0052</Ustrd></RmtInf>
          </TxDtls>
        </NtryDtls>
      </Ntry>
      <Ntry>
        <NtryRef>7</NtryRef>
        <Amt Ccy="EUR">75.25</Amt>
        <CdtDbtInd>DBIT</CdtDbtInd>
        ${booked('BOOK')}
        <BookgDt><Dt>2026-03-20</Dt></BookgDt>
        <ValDt><Dt>2026-03-20</Dt></ValDt>
        <AcctSvcrRef>ZZ26032000007</AcctSvcrRef>
        ${code('PMNT', 'RDDT', 'ESDD')}
        <NtryDtls>
          <TxDtls>
            <Refs><EndToEndId>E2E-DD-0009</EndToEndId><MndtId>MANDATE-0009</MndtId></Refs>
            ${own('75.25', 'DBIT')}
            <RltdPties>
              <Cdtr>${party('Opérateur Fictif')}</Cdtr>
              <CdtrAcct><Id><IBAN>BE85999000000202</IBAN></Id></CdtrAcct>
            </RltdPties>
            <RmtInf><Ustrd>Subscription March</Ustrd></RmtInf>
          </TxDtls>
        </NtryDtls>
      </Ntry>
      <Ntry>
        <NtryRef>8</NtryRef>
        <Amt Ccy="EUR">0.01</Amt>
        <CdtDbtInd>CRDT</CdtDbtInd>
        ${booked('BOOK')}
        <BookgDt><Dt>2026-03-31</Dt></BookgDt>
        <ValDt><Dt>2026-03-31</Dt></ValDt>
        <AcctSvcrRef>ZZ26033100008</AcctSvcrRef>
        ${code('ACMT', 'MCOP', 'INTR')}
      </Ntry>
      <Ntry>
        <NtryRef>9</NtryRef>
        <Amt Ccy="EUR">500.00</Amt>
        <CdtDbtInd>CRDT</CdtDbtInd>
        ${booked('PDNG')}
        <ValDt><Dt>2026-04-02</Dt></ValDt>
        ${code('PMNT', 'RCDT', 'ESCT')}
        <AddtlNtryInf>Announced, not booked</AddtlNtryInf>
      </Ntry>
      <Ntry>
        <NtryRef>10</NtryRef>
        <Amt Ccy="EUR">60.00</Amt>
        <CdtDbtInd>CRDT</CdtDbtInd>
        ${booked('BOOK')}
        <BookgDt><DtTm>2026-03-31T23:30:00+02:00</DtTm></BookgDt>
        <ValDt><Dt>2026-03-31</Dt></ValDt>
        <AcctSvcrRef>ZZ26033100010</AcctSvcrRef>
        <BkTxCd><Prtry><Cd>0150</Cd><Issr>ZZZZ</Issr></Prtry></BkTxCd>
        <NtryDtls>
          <TxDtls>
            ${own('60.00', 'CRDT')}
            <RltdPties>
              <Dbtr>${party('Membre Exemple')}</Dbtr>
              <DbtrAcct><Id><IBAN>BE74999000000303</IBAN></Id></DbtrAcct>
            </RltdPties>
            <RmtInf>
              <Ustrd>contribution</Ustrd>
              <Strd>
                <CdtrRefInf>
                  <Tp><CdOrPrtry><Cd>SCOR</Cd></CdOrPrtry><Issr>BBA</Issr></Tp>
                  <Ref>202600004236</Ref>
                </CdtrRefInf>
              </Strd>
            </RmtInf>
          </TxDtls>
        </NtryDtls>
      </Ntry>
    </Stmt>
  </BkToCstmrStmt>
</Document>
`;
}

for (const version of VERSIONS) {
  writeFileSync(join(out, `golden.camt.053.001.${version}.xml`), golden(version));
}
console.log(`${VERSIONS.length} files written to ${out}`);
