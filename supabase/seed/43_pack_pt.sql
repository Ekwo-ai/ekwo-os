-- Ekwo OS — Portugal: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/pt at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build pt`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Código do IVA, artigo 7.º — Facto gerador e exigibilidade do imposto (Autoridade Tributária e Aduaneira)
--     https://info.portaldasfinancas.gov.pt/pt/informacao_fiscal/codigos_tributarios/civa_rep/Pages/iva7.aspx
--   Código do IVA, artigo 8.º — Exigibilidade do imposto em caso de obrigação de emitir fatura (Autoridade Tributária e Aduaneira)
--     https://info.portaldasfinancas.gov.pt/pt/informacao_fiscal/codigos_tributarios/civa_rep/Pages/iva8.aspx
--   Código do IVA, artigo 9.º — Isenções nas operações internas (Autoridade Tributária e Aduaneira)
--     https://info.portaldasfinancas.gov.pt/pt/informacao_fiscal/codigos_tributarios/civa_rep/Pages/iva9.aspx
--   Código do IVA, artigo 14.º — Isenções nas exportações, operações assimiladas a exportações e transportes internacionais (Autoridade Tributária e Aduaneira)
--     https://info.portaldasfinancas.gov.pt/pt/informacao_fiscal/codigos_tributarios/civa_rep/Pages/iva14.aspx
--   Código do IVA, artigo 18.º — Taxas do imposto (Autoridade Tributária e Aduaneira)
--     https://info.portaldasfinancas.gov.pt/pt/informacao_fiscal/codigos_tributarios/civa_rep/Pages/iva18.aspx
--   Código do IVA, artigo 18.º, n.º 3 — Taxas do imposto nas Regiões Autónomas (Autoridade Tributária e Aduaneira)
--     https://info.portaldasfinancas.gov.pt/pt/informacao_fiscal/codigos_tributarios/civa_rep/ra/Pages/iva18ra_202503.aspx
--   Código do IVA, artigo 21.º — Exclusões do direito à dedução (Autoridade Tributária e Aduaneira)
--     https://info.portaldasfinancas.gov.pt/pt/informacao_fiscal/codigos_tributarios/civa_rep/Pages/iva21.aspx
--   Código do IVA, artigo 29.º — Obrigações em geral (obrigação de emitir fatura) (Autoridade Tributária e Aduaneira)
--     https://info.portaldasfinancas.gov.pt/pt/apoio_contribuinte/questoes_frequentes/pages/faqs-01010.aspx
--   Código do IVA, artigo 36.º — Prazos de emissão e formalidades das faturas (Autoridade Tributária e Aduaneira)
--     https://info.portaldasfinancas.gov.pt/pt/informacao_fiscal/codigos_tributarios/civa_rep/Pages/iva36.aspx
--   Código do IVA, artigo 41.º — Prazo de entrega da declaração periódica (Autoridade Tributária e Aduaneira)
--     https://info.portaldasfinancas.gov.pt/pt/informacao_fiscal/codigos_tributarios/civa_rep/Pages/iva41.aspx
--   RITI — Regime do IVA nas Transações Intracomunitárias, texto consolidado (Autoridade Tributária e Aduaneira)
--     https://info.portaldasfinancas.gov.pt/pt/informacao_fiscal/codigos_tributarios/Cod_download/Documents/RITI.pdf
--   Decreto-Lei n.º 49/2025, de 27 de março — uniformiza no dia 20 o prazo de entrega da declaração periódica do IVA, mensal e trimestral (Diário da República Eletrónico)
--     https://diariodarepublica.pt/dr/detalhe/decreto-lei/49-2025-912653926
--   Declaração periódica do IVA e anexo R — modelo oficial e instruções de preenchimento (Autoridade Tributária e Aduaneira)
--     https://info.portaldasfinancas.gov.pt/pt/apoio_contribuinte/modelos_formularios/iva/documents/declaracao_periodica_iva.pdf
--   Decreto Legislativo Regional n.º 15-A/2021/A — taxas do IVA na Região Autónoma dos Açores (4 %, 9 %, 16 %) (Diário da República Eletrónico)
--     https://info.portaldasfinancas.gov.pt/pt/informacao_fiscal/codigos_tributarios/civa_rep/ra/Pages/ivara18_062022.aspx
--   Lei n.º 14-A/2012, de 30 de março — taxas do IVA na Região Autónoma da Madeira (12 %, 22 %) (Diário da República Eletrónico)
--     https://diariodarepublica.pt/dr/detalhe/lei/14-a-2012-553470
--   Decreto Legislativo Regional n.º 6/2024/M, de 29 de julho, artigo 21.º — taxa reduzida do IVA na Região Autónoma da Madeira, 4 % desde 1 de outubro de 2024 (Diário da República Eletrónico)
--     https://diariodarepublica.pt/dr/detalhe/decreto-legislativo-regional/6-2024-873755644
--   Decreto-Lei n.º 62/2013, de 10 de maio — atrasos de pagamento em transações comerciais (Procuradoria-Geral Distrital de Lisboa)
--     https://www.pgdlisboa.pt/leis/lei_mostra_articulado.php?nid=1920&tabela=leis
--   Decreto-Lei n.º 28/2019, de 15 de fevereiro — regime de arquivo e processamento de faturas e outros documentos fiscalmente relevantes (Diário da República Eletrónico)
--     https://diariodarepublica.pt/dr/detalhe/decreto-lei/28-2019-119622094
--   Portaria n.º 195/2020, de 13 de agosto — ATCUD e código QR nas faturas e outros documentos fiscalmente relevantes (Diário da República Eletrónico)
--     https://diariodarepublica.pt/dr/detalhe/portaria/195-2020-140210523
--   Decreto-Lei n.º 111-B/2017, de 31 de agosto — transposição da Diretiva 2014/55/UE, faturação eletrónica nos contratos públicos (Diário da República Eletrónico)
--     https://diariodarepublica.pt/dr/detalhe/decreto-lei/111-b-2017-108030200
--   Decreto-Lei n.º 14/2013, de 28 de janeiro — número de identificação fiscal (NIF) (Diário da República Eletrónico)
--     https://diariodarepublica.pt/dr/detalhe/decreto-lei/14-2013-257001
--   Decreto-Lei n.º 158/2009, de 13 de julho — aprova o Sistema de Normalização Contabilística (SNC), texto consolidado (Diário da República Eletrónico)
--     https://diariodarepublica.pt/dr/detalhe/decreto-lei/158-2009-492428
--   Portaria n.º 1011/2009, de 9 de setembro — Código de Contas do SNC (Comissão de Normalização Contabilística)
--     https://www.cnc.gov.pt/pdf/snc/2016/normas%20com%20retifica%C3%A7%C3%A3o/CodigoContas.pdf
--   Portaria n.º 220/2015, de 24 de julho — modelos de demonstrações financeiras do SNC (Balanço e Demonstração de Resultados) (Diário da República Eletrónico)
--     https://diariodarepublica.pt/dr/detalhe/portaria/220-2015-69866634
--   EN 16931-1 — the semantic data model of the core elements of an electronic invoice, and the conformity Directive 2014/55/EU requires (European Commission)
--     https://ec.europa.eu/digital-building-blocks/sites/spaces/DIGITAL/pages/467108950/EN+16931+compliance
--   UNCL5305 — VAT category code list (BT-118 and BT-151), the subset published for EN 16931 (OpenPEPPOL — list published by the European Commission)
--     https://docs.peppol.eu/poacc/billing/3.0/codelist/UNCL5305/
--   VATEX — VAT exemption reason code list (BT-121) (OpenPEPPOL — list published by the European Commission)
--     https://docs.peppol.eu/poacc/billing/3.0/codelist/vatex/
--   Entrega da Declaração Periódica do IVA — Portal das Finanças (Autoridade Tributária e Aduaneira)
--     https://www.acesso.gov.pt/v2/loginForm?partID=IAT&path=/dashboard
--   Peppol participant identifier scheme list (EAS): 9946, Portugal VAT number (OpenPEPPOL)
--     https://docs.peppol.eu/poacc/billing/3.0/codelist/eas/
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('PT', 'Portugal', '0.1.0', date '2026-09-22', '20260921145425', 'community', null, null, '92180d9a0dad771f116c4ab209c129149e91e854d49ca9dd079d14c806a01cb4', '[{"key":"civa-art7","title":"Código do IVA, artigo 7.º — Facto gerador e exigibilidade do imposto","publisher":"Autoridade Tributária e Aduaneira","url":"https://info.portaldasfinancas.gov.pt/pt/informacao_fiscal/codigos_tributarios/civa_rep/Pages/iva7.aspx","consulted_on":"2026-09-22","kind":"law"},{"key":"civa-art8","title":"Código do IVA, artigo 8.º — Exigibilidade do imposto em caso de obrigação de emitir fatura","publisher":"Autoridade Tributária e Aduaneira","url":"https://info.portaldasfinancas.gov.pt/pt/informacao_fiscal/codigos_tributarios/civa_rep/Pages/iva8.aspx","consulted_on":"2026-09-22","kind":"law"},{"key":"civa-art9","title":"Código do IVA, artigo 9.º — Isenções nas operações internas","publisher":"Autoridade Tributária e Aduaneira","url":"https://info.portaldasfinancas.gov.pt/pt/informacao_fiscal/codigos_tributarios/civa_rep/Pages/iva9.aspx","consulted_on":"2026-09-22","kind":"law"},{"key":"civa-art14","title":"Código do IVA, artigo 14.º — Isenções nas exportações, operações assimiladas a exportações e transportes internacionais","publisher":"Autoridade Tributária e Aduaneira","url":"https://info.portaldasfinancas.gov.pt/pt/informacao_fiscal/codigos_tributarios/civa_rep/Pages/iva14.aspx","consulted_on":"2026-09-22","kind":"law"},{"key":"civa-art18","title":"Código do IVA, artigo 18.º — Taxas do imposto","publisher":"Autoridade Tributária e Aduaneira","url":"https://info.portaldasfinancas.gov.pt/pt/informacao_fiscal/codigos_tributarios/civa_rep/Pages/iva18.aspx","consulted_on":"2026-09-22","kind":"law"},{"key":"civa-art18-ra","title":"Código do IVA, artigo 18.º, n.º 3 — Taxas do imposto nas Regiões Autónomas","publisher":"Autoridade Tributária e Aduaneira","url":"https://info.portaldasfinancas.gov.pt/pt/informacao_fiscal/codigos_tributarios/civa_rep/ra/Pages/iva18ra_202503.aspx","consulted_on":"2026-09-22","kind":"law"},{"key":"civa-art21","title":"Código do IVA, artigo 21.º — Exclusões do direito à dedução","publisher":"Autoridade Tributária e Aduaneira","url":"https://info.portaldasfinancas.gov.pt/pt/informacao_fiscal/codigos_tributarios/civa_rep/Pages/iva21.aspx","consulted_on":"2026-09-22","kind":"law"},{"key":"civa-art29","title":"Código do IVA, artigo 29.º — Obrigações em geral (obrigação de emitir fatura)","publisher":"Autoridade Tributária e Aduaneira","url":"https://info.portaldasfinancas.gov.pt/pt/apoio_contribuinte/questoes_frequentes/pages/faqs-01010.aspx","consulted_on":"2026-09-22","kind":"law"},{"key":"civa-art36","title":"Código do IVA, artigo 36.º — Prazos de emissão e formalidades das faturas","publisher":"Autoridade Tributária e Aduaneira","url":"https://info.portaldasfinancas.gov.pt/pt/informacao_fiscal/codigos_tributarios/civa_rep/Pages/iva36.aspx","consulted_on":"2026-09-22","kind":"law"},{"key":"civa-art41","title":"Código do IVA, artigo 41.º — Prazo de entrega da declaração periódica","publisher":"Autoridade Tributária e Aduaneira","url":"https://info.portaldasfinancas.gov.pt/pt/informacao_fiscal/codigos_tributarios/civa_rep/Pages/iva41.aspx","consulted_on":"2026-09-22","kind":"law"},{"key":"riti","title":"RITI — Regime do IVA nas Transações Intracomunitárias, texto consolidado","publisher":"Autoridade Tributária e Aduaneira","url":"https://info.portaldasfinancas.gov.pt/pt/informacao_fiscal/codigos_tributarios/Cod_download/Documents/RITI.pdf","consulted_on":"2026-09-22","kind":"law"},{"key":"dl-49-2025","title":"Decreto-Lei n.º 49/2025, de 27 de março — uniformiza no dia 20 o prazo de entrega da declaração periódica do IVA, mensal e trimestral","publisher":"Diário da República Eletrónico","url":"https://diariodarepublica.pt/dr/detalhe/decreto-lei/49-2025-912653926","consulted_on":"2026-09-22","kind":"regulation"},{"key":"portaria-221-2017","title":"Declaração periódica do IVA e anexo R — modelo oficial e instruções de preenchimento","publisher":"Autoridade Tributária e Aduaneira","url":"https://info.portaldasfinancas.gov.pt/pt/apoio_contribuinte/modelos_formularios/iva/documents/declaracao_periodica_iva.pdf","consulted_on":"2026-09-22","kind":"form"},{"key":"dlr-15-a-2021-a","title":"Decreto Legislativo Regional n.º 15-A/2021/A — taxas do IVA na Região Autónoma dos Açores (4 %, 9 %, 16 %)","publisher":"Diário da República Eletrónico","url":"https://info.portaldasfinancas.gov.pt/pt/informacao_fiscal/codigos_tributarios/civa_rep/ra/Pages/ivara18_062022.aspx","consulted_on":"2026-09-22","kind":"regulation"},{"key":"lei-14-a-2012","title":"Lei n.º 14-A/2012, de 30 de março — taxas do IVA na Região Autónoma da Madeira (12 %, 22 %)","publisher":"Diário da República Eletrónico","url":"https://diariodarepublica.pt/dr/detalhe/lei/14-a-2012-553470","consulted_on":"2026-09-22","kind":"law"},{"key":"dlr-6-2024-m","title":"Decreto Legislativo Regional n.º 6/2024/M, de 29 de julho, artigo 21.º — taxa reduzida do IVA na Região Autónoma da Madeira, 4 % desde 1 de outubro de 2024","publisher":"Diário da República Eletrónico","url":"https://diariodarepublica.pt/dr/detalhe/decreto-legislativo-regional/6-2024-873755644","consulted_on":"2026-09-22","kind":"regulation"},{"key":"dl-62-2013","title":"Decreto-Lei n.º 62/2013, de 10 de maio — atrasos de pagamento em transações comerciais","publisher":"Procuradoria-Geral Distrital de Lisboa","url":"https://www.pgdlisboa.pt/leis/lei_mostra_articulado.php?nid=1920&tabela=leis","consulted_on":"2026-09-22","kind":"law"},{"key":"dl-28-2019","title":"Decreto-Lei n.º 28/2019, de 15 de fevereiro — regime de arquivo e processamento de faturas e outros documentos fiscalmente relevantes","publisher":"Diário da República Eletrónico","url":"https://diariodarepublica.pt/dr/detalhe/decreto-lei/28-2019-119622094","consulted_on":"2026-09-22","kind":"regulation"},{"key":"portaria-195-2020","title":"Portaria n.º 195/2020, de 13 de agosto — ATCUD e código QR nas faturas e outros documentos fiscalmente relevantes","publisher":"Diário da República Eletrónico","url":"https://diariodarepublica.pt/dr/detalhe/portaria/195-2020-140210523","consulted_on":"2026-09-22","kind":"regulation"},{"key":"dl-111-b-2017","title":"Decreto-Lei n.º 111-B/2017, de 31 de agosto — transposição da Diretiva 2014/55/UE, faturação eletrónica nos contratos públicos","publisher":"Diário da República Eletrónico","url":"https://diariodarepublica.pt/dr/detalhe/decreto-lei/111-b-2017-108030200","consulted_on":"2026-09-22","kind":"regulation"},{"key":"dl-14-2013","title":"Decreto-Lei n.º 14/2013, de 28 de janeiro — número de identificação fiscal (NIF)","publisher":"Diário da República Eletrónico","url":"https://diariodarepublica.pt/dr/detalhe/decreto-lei/14-2013-257001","consulted_on":"2026-09-22","kind":"law"},{"key":"dl-158-2009","title":"Decreto-Lei n.º 158/2009, de 13 de julho — aprova o Sistema de Normalização Contabilística (SNC), texto consolidado","publisher":"Diário da República Eletrónico","url":"https://diariodarepublica.pt/dr/detalhe/decreto-lei/158-2009-492428","consulted_on":"2026-09-22","kind":"law"},{"key":"portaria-1011-2009","title":"Portaria n.º 1011/2009, de 9 de setembro — Código de Contas do SNC","publisher":"Comissão de Normalização Contabilística","url":"https://www.cnc.gov.pt/pdf/snc/2016/normas%20com%20retifica%C3%A7%C3%A3o/CodigoContas.pdf","consulted_on":"2026-09-22","kind":"regulation"},{"key":"portaria-220-2015","title":"Portaria n.º 220/2015, de 24 de julho — modelos de demonstrações financeiras do SNC (Balanço e Demonstração de Resultados)","publisher":"Diário da República Eletrónico","url":"https://diariodarepublica.pt/dr/detalhe/portaria/220-2015-69866634","consulted_on":"2026-09-22","kind":"regulation"},{"key":"en-16931","title":"EN 16931-1 — the semantic data model of the core elements of an electronic invoice, and the conformity Directive 2014/55/EU requires","publisher":"European Commission","url":"https://ec.europa.eu/digital-building-blocks/sites/spaces/DIGITAL/pages/467108950/EN+16931+compliance","consulted_on":"2026-09-22","kind":"standard"},{"key":"uncl5305","title":"UNCL5305 — VAT category code list (BT-118 and BT-151), the subset published for EN 16931","publisher":"OpenPEPPOL — list published by the European Commission","url":"https://docs.peppol.eu/poacc/billing/3.0/codelist/UNCL5305/","consulted_on":"2026-09-22","kind":"standard"},{"key":"vatex","title":"VATEX — VAT exemption reason code list (BT-121)","publisher":"OpenPEPPOL — list published by the European Commission","url":"https://docs.peppol.eu/poacc/billing/3.0/codelist/vatex/","consulted_on":"2026-09-22","kind":"standard"},{"key":"portal-dp-iva","title":"Entrega da Declaração Periódica do IVA — Portal das Finanças","publisher":"Autoridade Tributária e Aduaneira","url":"https://www.acesso.gov.pt/v2/loginForm?partID=IAT&path=/dashboard","consulted_on":"2026-09-22","kind":"portal"},{"key":"peppol-eas","title":"Peppol participant identifier scheme list (EAS): 9946, Portugal VAT number","publisher":"OpenPEPPOL","url":"https://docs.peppol.eu/poacc/billing/3.0/codelist/eas/","consulted_on":"2026-09-22","kind":"standard"}]'::jsonb)
on conflict (country) do update set
  name                 = excluded.name,
  version              = excluded.version,
  released_at          = excluded.released_at,
  schema_min           = excluded.schema_min,
  certification_status = excluded.certification_status,
  certified_by         = excluded.certified_by,
  certified_at         = excluded.certified_at,
  checksum             = excluded.checksum,
  sources              = excluded.sources;

insert into chart_templates
  (country, code, name, name_i18n, is_default, audience, statements,
   certification_status, legal_reference, source_key)
values
  ('PT', 'default', 'SNC — Sistema de Normalização Contabilística (seleção para PME)', '{"en":"SNC — Portuguese Accounting Standards System (selection for SMEs)"}'::jsonb, true, 'companies', array['PT-SNC-BAL', 'PT-SNC-DR']::text[], null, 'Decreto-Lei n.º 158/2009, de 13 de julho, que aprova o SNC, alterado pelo Decreto-Lei n.º 98/2015, de 2 de junho; Portaria n.º 1011/2009, de 9 de setembro, que aprova o Código de Contas. Seleção de contas das classes 1 a 8 nos códigos e denominações oficiais, com as contas usadas na prática de uma sociedade comercial corrente; a lista completa é a da portaria', 'portaria-1011-2009')
on conflict (country, code) do update set
  name                 = excluded.name,
  name_i18n            = excluded.name_i18n,
  is_default           = excluded.is_default,
  audience             = excluded.audience,
  statements           = excluded.statements,
  certification_status = excluded.certification_status,
  legal_reference      = excluded.legal_reference,
  source_key           = excluded.source_key;

insert into account_templates
  (country, chart_code, code, name, name_i18n, account_type, reconcilable,
   parent_code, sequence)
values
  ('PT', 'default', '1', 'Meios financeiros líquidos', '{"en":"Cash and cash equivalents"}'::jsonb, 'asset_cash', false, null, 10),
  ('PT', 'default', '11', 'Caixa', '{"en":"Cash"}'::jsonb, 'asset_cash', false, '1', 20),
  ('PT', 'default', '111', 'Caixa - sede', '{"en":"Cash - head office"}'::jsonb, 'asset_cash', false, '11', 30),
  ('PT', 'default', '12', 'Depósitos à ordem', '{"en":"Demand deposits"}'::jsonb, 'asset_cash', false, '1', 40),
  ('PT', 'default', '121', 'Depósitos à ordem - banco principal', '{"en":"Demand deposits - main bank"}'::jsonb, 'asset_cash', true, '12', 50),
  ('PT', 'default', '13', 'Outros depósitos bancários', '{"en":"Other bank deposits"}'::jsonb, 'asset_cash', false, '1', 60),
  ('PT', 'default', '131', 'Depósitos a prazo', '{"en":"Term deposits"}'::jsonb, 'asset_cash', true, '13', 70),
  ('PT', 'default', '2', 'Contas a receber e a pagar', '{"en":"Receivables and payables"}'::jsonb, 'asset_receivable', true, null, 80),
  ('PT', 'default', '21', 'Clientes', '{"en":"Customers"}'::jsonb, 'asset_receivable', true, '2', 90),
  ('PT', 'default', '211', 'Clientes - conta corrente', '{"en":"Customers - current account"}'::jsonb, 'asset_receivable', true, '21', 100),
  ('PT', 'default', '212', 'Clientes - títulos a receber', '{"en":"Customers - bills receivable"}'::jsonb, 'asset_receivable', true, '21', 110),
  ('PT', 'default', '218', 'Clientes de cobrança duvidosa', '{"en":"Doubtful customers"}'::jsonb, 'asset_receivable', true, '21', 120),
  ('PT', 'default', '219', 'Clientes - perdas por imparidade acumuladas', '{"en":"Customers - accumulated impairment losses"}'::jsonb, 'asset_receivable', true, '21', 130),
  ('PT', 'default', '22', 'Fornecedores', '{"en":"Suppliers"}'::jsonb, 'liability_payable', true, '2', 140),
  ('PT', 'default', '221', 'Fornecedores - conta corrente', '{"en":"Suppliers - current account"}'::jsonb, 'liability_payable', true, '22', 150),
  ('PT', 'default', '222', 'Fornecedores - faturas em receção e conferência', '{"en":"Suppliers - invoices received and under verification"}'::jsonb, 'liability_payable', true, '22', 160),
  ('PT', 'default', '228', 'Fornecedores de cobrança duvidosa', '{"en":"Doubtful suppliers"}'::jsonb, 'liability_payable', true, '22', 170),
  ('PT', 'default', '23', 'Pessoal', '{"en":"Staff"}'::jsonb, 'liability_current', false, '2', 180),
  ('PT', 'default', '231', 'Remunerações a pagar', '{"en":"Payroll payable"}'::jsonb, 'liability_current', true, '23', 190),
  ('PT', 'default', '232', 'Adiantamentos por conta de retribuições', '{"en":"Advances on remuneration"}'::jsonb, 'asset_current', false, '23', 200),
  ('PT', 'default', '24', 'Estado e outros entes públicos', '{"en":"State and other public entities"}'::jsonb, 'liability_current', false, '2', 210),
  ('PT', 'default', '241', 'Imposto sobre o rendimento', '{"en":"Income tax"}'::jsonb, 'liability_current', true, '24', 220),
  ('PT', 'default', '243', 'Imposto sobre o Valor Acrescentado', '{"en":"Value added tax"}'::jsonb, 'liability_current', false, '24', 230),
  ('PT', 'default', '2432', 'IVA - Dedutível', '{"en":"VAT - Deductible"}'::jsonb, 'asset_current', false, '243', 240),
  ('PT', 'default', '2433', 'IVA - Liquidado', '{"en":"VAT - Charged"}'::jsonb, 'liability_current', false, '243', 250),
  ('PT', 'default', '2434', 'IVA - Regularizações', '{"en":"VAT - Adjustments"}'::jsonb, 'liability_current', false, '243', 260),
  ('PT', 'default', '2436', 'IVA - A pagar', '{"en":"VAT - Payable"}'::jsonb, 'liability_current', true, '243', 270),
  ('PT', 'default', '2437', 'IVA - A recuperar', '{"en":"VAT - Recoverable"}'::jsonb, 'asset_current', true, '243', 280),
  ('PT', 'default', '244', 'Contribuições para a Segurança Social', '{"en":"Social security contributions"}'::jsonb, 'liability_current', true, '24', 290),
  ('PT', 'default', '25', 'Financiamentos obtidos', '{"en":"Borrowings"}'::jsonb, 'liability_non_current', false, '2', 300),
  ('PT', 'default', '251', 'Instituições de crédito - empréstimos a médio e longo prazo', '{"en":"Credit institutions - medium and long-term loans"}'::jsonb, 'liability_non_current', true, '25', 310),
  ('PT', 'default', '258', 'Instituições de crédito - descobertos bancários', '{"en":"Credit institutions - bank overdrafts"}'::jsonb, 'liability_current', true, '25', 320),
  ('PT', 'default', '26', 'Acionistas (sócios)', '{"en":"Shareholders"}'::jsonb, 'liability_current', false, '2', 330),
  ('PT', 'default', '263', 'Empréstimos concedidos', '{"en":"Loans granted"}'::jsonb, 'liability_current', false, '26', 340),
  ('PT', 'default', '264', 'Suprimentos e outros mútuos', '{"en":"Shareholder loans and other loans"}'::jsonb, 'liability_current', false, '26', 350),
  ('PT', 'default', '268', 'Outras operações', '{"en":"Other transactions"}'::jsonb, 'liability_current', false, '26', 355),
  ('PT', 'default', '27', 'Outras contas a receber e a pagar', '{"en":"Other receivables and payables"}'::jsonb, 'asset_current', false, '2', 360),
  ('PT', 'default', '271', 'Devedores por acréscimos de rendimentos', '{"en":"Accrued income"}'::jsonb, 'asset_current', false, '27', 370),
  ('PT', 'default', '272', 'Credores por acréscimos de gastos', '{"en":"Accrued expenses"}'::jsonb, 'liability_current', false, '27', 380),
  ('PT', 'default', '273', 'Devedores por diferimentos', '{"en":"Deferred expenses"}'::jsonb, 'asset_prepayments', false, '27', 390),
  ('PT', 'default', '274', 'Credores por diferimentos', '{"en":"Deferred income"}'::jsonb, 'liability_current', false, '27', 400),
  ('PT', 'default', '278', 'Outros devedores e credores', '{"en":"Other debtors and creditors"}'::jsonb, 'asset_current', true, '27', 410),
  ('PT', 'default', '279', 'Perdas por imparidade acumuladas', '{"en":"Accumulated impairment losses"}'::jsonb, 'asset_current', false, '27', 420),
  ('PT', 'default', '3', 'Inventários e ativos biológicos', '{"en":"Inventories and biological assets"}'::jsonb, 'asset_current', false, null, 430),
  ('PT', 'default', '32', 'Mercadorias', '{"en":"Goods for resale"}'::jsonb, 'asset_current', false, '3', 440),
  ('PT', 'default', '39', 'Perdas por imparidade em inventários (acumuladas)', '{"en":"Accumulated impairment losses on inventories"}'::jsonb, 'asset_current', false, '3', 450),
  ('PT', 'default', '4', 'Investimentos', '{"en":"Investments"}'::jsonb, 'asset_non_current', false, null, 460),
  ('PT', 'default', '41', 'Investimentos financeiros', '{"en":"Financial investments"}'::jsonb, 'asset_non_current', false, '4', 470),
  ('PT', 'default', '419', 'Investimentos financeiros - perdas por imparidade acumuladas', '{"en":"Financial investments - accumulated impairment losses"}'::jsonb, 'asset_non_current', false, '41', 480),
  ('PT', 'default', '42', 'Propriedades de investimento', '{"en":"Investment property"}'::jsonb, 'asset_non_current', false, '4', 490),
  ('PT', 'default', '429', 'Propriedades de investimento - perdas por imparidade acumuladas', '{"en":"Investment property - accumulated impairment losses"}'::jsonb, 'asset_non_current', false, '42', 500),
  ('PT', 'default', '43', 'Ativos fixos tangíveis', '{"en":"Tangible fixed assets"}'::jsonb, 'asset_fixed', false, '4', 510),
  ('PT', 'default', '431', 'Terrenos e recursos naturais', '{"en":"Land and natural resources"}'::jsonb, 'asset_fixed', false, '43', 520),
  ('PT', 'default', '432', 'Edifícios e outras construções', '{"en":"Buildings and other constructions"}'::jsonb, 'asset_fixed', false, '43', 530),
  ('PT', 'default', '433', 'Equipamento básico', '{"en":"Basic equipment"}'::jsonb, 'asset_fixed', false, '43', 540),
  ('PT', 'default', '434', 'Equipamento de transporte', '{"en":"Transport equipment"}'::jsonb, 'asset_fixed', false, '43', 550),
  ('PT', 'default', '435', 'Equipamento administrativo', '{"en":"Administrative equipment"}'::jsonb, 'asset_fixed', false, '43', 560),
  ('PT', 'default', '436', 'Outros ativos fixos tangíveis', '{"en":"Other tangible fixed assets"}'::jsonb, 'asset_fixed', false, '43', 570),
  ('PT', 'default', '438', 'Ativos fixos tangíveis - depreciações acumuladas', '{"en":"Tangible fixed assets - accumulated depreciation"}'::jsonb, 'asset_fixed', false, '43', 580),
  ('PT', 'default', '439', 'Ativos fixos tangíveis - perdas por imparidade acumuladas', '{"en":"Tangible fixed assets - accumulated impairment losses"}'::jsonb, 'asset_fixed', false, '43', 590),
  ('PT', 'default', '44', 'Ativos intangíveis', '{"en":"Intangible assets"}'::jsonb, 'asset_non_current', false, '4', 600),
  ('PT', 'default', '441', 'Goodwill', '{"en":"Goodwill"}'::jsonb, 'asset_non_current', false, '44', 610),
  ('PT', 'default', '443', 'Programas de computador', '{"en":"Computer software"}'::jsonb, 'asset_non_current', false, '44', 620),
  ('PT', 'default', '448', 'Ativos intangíveis - amortizações acumuladas', '{"en":"Intangible assets - accumulated amortisation"}'::jsonb, 'asset_non_current', false, '44', 630),
  ('PT', 'default', '449', 'Ativos intangíveis - perdas por imparidade acumuladas', '{"en":"Intangible assets - accumulated impairment losses"}'::jsonb, 'asset_non_current', false, '44', 640),
  ('PT', 'default', '45', 'Investimentos em curso', '{"en":"Investments in progress"}'::jsonb, 'asset_fixed', false, '4', 650),
  ('PT', 'default', '46', 'Ativos não correntes detidos para venda', '{"en":"Non-current assets held for sale"}'::jsonb, 'asset_current', false, '4', 660),
  ('PT', 'default', '5', 'Capital, reservas e resultados transitados', '{"en":"Capital, reserves and retained earnings"}'::jsonb, 'equity', false, null, 670),
  ('PT', 'default', '51', 'Capital', '{"en":"Capital"}'::jsonb, 'equity', false, '5', 680),
  ('PT', 'default', '511', 'Capital subscrito', '{"en":"Subscribed capital"}'::jsonb, 'equity', false, '51', 690),
  ('PT', 'default', '54', 'Prémios de emissão de instrumentos de capital próprio', '{"en":"Share premium"}'::jsonb, 'equity', false, '5', 700),
  ('PT', 'default', '55', 'Reservas', '{"en":"Reserves"}'::jsonb, 'equity', false, '5', 710),
  ('PT', 'default', '551', 'Reservas legais', '{"en":"Legal reserves"}'::jsonb, 'equity', false, '55', 720),
  ('PT', 'default', '552', 'Outras reservas', '{"en":"Other reserves"}'::jsonb, 'equity', false, '55', 730),
  ('PT', 'default', '56', 'Resultados transitados', '{"en":"Retained earnings"}'::jsonb, 'equity_retained', false, '5', 740),
  ('PT', 'default', '59', 'Outras variações no capital próprio', '{"en":"Other changes in equity"}'::jsonb, 'equity', false, '5', 750),
  ('PT', 'default', '6', 'Gastos', '{"en":"Expenses"}'::jsonb, 'expense', false, null, 760),
  ('PT', 'default', '61', 'Custo das mercadorias vendidas e das matérias consumidas', '{"en":"Cost of goods sold and materials consumed"}'::jsonb, 'expense_direct_cost', false, '6', 770),
  ('PT', 'default', '612', 'Custo das mercadorias vendidas', '{"en":"Cost of goods sold"}'::jsonb, 'expense_direct_cost', false, '61', 780),
  ('PT', 'default', '62', 'Fornecimentos e serviços externos', '{"en":"External supplies and services"}'::jsonb, 'expense', false, '6', 790),
  ('PT', 'default', '621', 'Subcontratos', '{"en":"Subcontracts"}'::jsonb, 'expense', false, '62', 800),
  ('PT', 'default', '622', 'Serviços especializados', '{"en":"Specialised services"}'::jsonb, 'expense', false, '62', 810),
  ('PT', 'default', '623', 'Materiais', '{"en":"Materials"}'::jsonb, 'expense', false, '62', 820),
  ('PT', 'default', '624', 'Energia e fluidos', '{"en":"Energy and fluids"}'::jsonb, 'expense', false, '62', 830),
  ('PT', 'default', '625', 'Deslocações, estadas e transportes', '{"en":"Travel and subsistence"}'::jsonb, 'expense', false, '62', 840),
  ('PT', 'default', '626', 'Rendas e alugueres', '{"en":"Rent"}'::jsonb, 'expense', false, '62', 850),
  ('PT', 'default', '627', 'Comunicação', '{"en":"Communication"}'::jsonb, 'expense', false, '62', 860),
  ('PT', 'default', '628', 'Seguros', '{"en":"Insurance"}'::jsonb, 'expense', false, '62', 870),
  ('PT', 'default', '629', 'Outros serviços', '{"en":"Other services"}'::jsonb, 'expense', false, '62', 880),
  ('PT', 'default', '63', 'Gastos com o pessoal', '{"en":"Staff costs"}'::jsonb, 'expense', false, '6', 890),
  ('PT', 'default', '631', 'Remunerações dos órgãos sociais', '{"en":"Remuneration of governing bodies"}'::jsonb, 'expense', false, '63', 900),
  ('PT', 'default', '632', 'Remunerações do pessoal', '{"en":"Employee remuneration"}'::jsonb, 'expense', false, '63', 910),
  ('PT', 'default', '635', 'Encargos sobre remunerações', '{"en":"Employer social charges"}'::jsonb, 'expense', false, '63', 920),
  ('PT', 'default', '638', 'Outros gastos com o pessoal', '{"en":"Other staff costs"}'::jsonb, 'expense', false, '63', 930),
  ('PT', 'default', '64', 'Gastos de depreciação e de amortização', '{"en":"Depreciation and amortisation expense"}'::jsonb, 'expense_depreciation', false, '6', 940),
  ('PT', 'default', '641', 'Ativos fixos tangíveis', '{"en":"Tangible fixed assets"}'::jsonb, 'expense_depreciation', false, '64', 950),
  ('PT', 'default', '643', 'Ativos intangíveis', '{"en":"Intangible assets"}'::jsonb, 'expense_depreciation', false, '64', 960),
  ('PT', 'default', '65', 'Perdas por imparidade', '{"en":"Impairment losses"}'::jsonb, 'expense', false, '6', 970),
  ('PT', 'default', '67', 'Provisões do período', '{"en":"Provisions for the period"}'::jsonb, 'expense', false, '6', 980),
  ('PT', 'default', '68', 'Outros gastos e perdas', '{"en":"Other expenses and losses"}'::jsonb, 'expense', false, '6', 990),
  ('PT', 'default', '686', 'Diferenças de câmbio desfavoráveis', '{"en":"Unfavourable exchange differences"}'::jsonb, 'expense', false, '68', 1000),
  ('PT', 'default', '688', 'Outros gastos e perdas - outros', '{"en":"Other expenses and losses - other"}'::jsonb, 'expense', false, '68', 1010),
  ('PT', 'default', '69', 'Gastos e perdas de financiamento', '{"en":"Financing expenses and losses"}'::jsonb, 'expense', false, '6', 1020),
  ('PT', 'default', '691', 'Juros suportados', '{"en":"Interest expense"}'::jsonb, 'expense', false, '69', 1030),
  ('PT', 'default', '698', 'Gastos e perdas de financiamento - outros', '{"en":"Financing expenses and losses - other"}'::jsonb, 'expense', false, '69', 1040),
  ('PT', 'default', '7', 'Rendimentos', '{"en":"Income"}'::jsonb, 'income', false, null, 1050),
  ('PT', 'default', '71', 'Vendas', '{"en":"Sales"}'::jsonb, 'income', false, '7', 1060),
  ('PT', 'default', '711', 'Vendas - mercadorias', '{"en":"Sales - goods for resale"}'::jsonb, 'income', false, '71', 1070),
  ('PT', 'default', '72', 'Prestações de serviços', '{"en":"Services rendered"}'::jsonb, 'income', false, '7', 1080),
  ('PT', 'default', '75', 'Subsídios à exploração', '{"en":"Operating subsidies"}'::jsonb, 'income_other', false, '7', 1090),
  ('PT', 'default', '76', 'Reversões', '{"en":"Reversals"}'::jsonb, 'income_other', false, '7', 1100),
  ('PT', 'default', '78', 'Outros rendimentos e ganhos', '{"en":"Other income and gains"}'::jsonb, 'income_other', false, '7', 1110),
  ('PT', 'default', '786', 'Diferenças de câmbio favoráveis', '{"en":"Favourable exchange differences"}'::jsonb, 'income_other', false, '78', 1120),
  ('PT', 'default', '788', 'Outros rendimentos e ganhos - outros', '{"en":"Other income and gains - other"}'::jsonb, 'income_other', false, '78', 1130),
  ('PT', 'default', '79', 'Juros, dividendos e outros rendimentos similares', '{"en":"Interest, dividends and similar income"}'::jsonb, 'income_other', false, '7', 1140),
  ('PT', 'default', '791', 'Juros obtidos', '{"en":"Interest income"}'::jsonb, 'income_other', false, '79', 1150),
  ('PT', 'default', '8', 'Resultados', '{"en":"Results"}'::jsonb, 'equity', false, null, 1160),
  ('PT', 'default', '81', 'Resultado líquido do período', '{"en":"Net profit or loss for the period"}'::jsonb, 'equity', false, '8', 1170),
  ('PT', 'default', '82', 'Imposto sobre o rendimento do período', '{"en":"Income tax for the period"}'::jsonb, 'expense', false, '8', 1180)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('PT', 'ABE', 'Diário de abertura', '{"en":"Opening journal"}'::jsonb, 'opening', 60),
  ('PT', 'BAN', 'Diário de bancos', '{"en":"Bank journal"}'::jsonb, 'bank', 30),
  ('PT', 'CAI', 'Diário de caixa', '{"en":"Cash journal"}'::jsonb, 'cash', 40),
  ('PT', 'COM', 'Diário de compras', '{"en":"Purchase journal"}'::jsonb, 'purchase', 20),
  ('PT', 'DIV', 'Diário de operações diversas', '{"en":"Miscellaneous operations journal"}'::jsonb, 'general', 50),
  ('PT', 'VEN', 'Diário de vendas', '{"en":"Sales journal"}'::jsonb, 'sales', 10)
on conflict (country, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  journal_type = excluded.journal_type,
  sequence     = excluded.sequence;

insert into tax_templates
  (country, code, name, name_i18n, description, amount_type, amount, applies_to, treatment,
   valid_from, valid_to, legal_reference, vat_category, exemption_code, sequence,
   tax_kind, recoverable, conditions, jurisdiction, price_include, cash_basis,
   cash_basis_transition_account_code, source_key,
   applies_seller_territory, applies_buyer_territory, applies_supply_territory,
   applies_supply_vs_seller)
values
  ('PT', 'PT-P-AFT-23', 'Compra de ativos fixos tangíveis à taxa normal (23 %), dedutível', '{"en":"Purchase of tangible fixed assets at the standard rate (23 %), deductible"}'::jsonb, null, 'percent', 23, 'purchase', 'domestic', date '2011-01-01', null, 'Código do IVA, arts. 19.º a 25.º. Declaração periódica, quadro 06, campo 20 — IVA dedutível de ativos não correntes, sem desdobramento por taxa', 'S', null, 200, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'civa-art18', null, null, null, null),
  ('PT', 'PT-P-BENS-13', 'Compra de mercadorias à taxa intermédia (13 %), dedutível', '{"en":"Purchase of goods for resale at the intermediate rate (13 %), deductible"}'::jsonb, null, 'percent', 13, 'purchase', 'domestic', date '2011-01-01', null, 'Código do IVA, arts. 19.º a 25.º. Declaração periódica, quadro 06, campo 22 — IVA dedutível de existências à taxa intermédia', 'S', null, 170, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'civa-art18', null, null, null, null),
  ('PT', 'PT-P-BENS-23', 'Compra de mercadorias à taxa normal (23 %), dedutível', '{"en":"Purchase of goods for resale at the standard rate (23 %), deductible"}'::jsonb, null, 'percent', 23, 'purchase', 'domestic', date '2011-01-01', null, 'Código do IVA, arts. 19.º a 25.º — direito à dedução. Declaração periódica, quadro 06, campo 23 — IVA dedutível de existências à taxa normal', 'S', null, 160, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'civa-art18', null, null, null, null),
  ('PT', 'PT-P-BENS-6', 'Compra de mercadorias à taxa reduzida (6 %), dedutível', '{"en":"Purchase of goods for resale at the reduced rate (6 %), deductible"}'::jsonb, null, 'percent', 6, 'purchase', 'domestic', date '2011-01-01', null, 'Código do IVA, arts. 19.º a 25.º. Declaração periódica, quadro 06, campo 21 — IVA dedutível de existências à taxa reduzida', 'S', null, 180, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'civa-art18', null, null, null, null),
  ('PT', 'PT-P-EXC-23', 'Despesa excluída do direito à dedução, à taxa normal (23 %)', '{"en":"Expense excluded from the right to deduct, at the standard rate (23 %)"}'::jsonb, 'Despesas de viaturas de turismo, de combustível, de deslocações e de representação, entre outras, excluídas do direito à dedução pelo art. 21.º do CIVA: o imposto suportado não é deduzido nem declarado, e acresce ao custo do bem ou serviço.', 'percent', 23, 'purchase', 'domestic', date '2011-01-01', null, 'Código do IVA, art. 21.º, n.º 1 — exclui do direito à dedução o imposto respeitante a despesas de aquisição, fabrico ou importação, locação, utilização, transformação e reparação de viaturas de turismo, de combustíveis (salvo as exceções do n.º 2), de transportes e viagens de negócios do sujeito passivo e do seu pessoal, e despesas de representação. Não figura na declaração periódica', null, null, 250, 'vat', false, '{}'::tax_condition[], null, false, false, null, 'civa-art21', null, null, null, null),
  ('PT', 'PT-P-EXT-23', 'Serviço adquirido a prestador não estabelecido na União, à taxa normal (23 %)', '{"en":"Service received from a supplier not established in the Union, at the standard rate (23 %)"}'::jsonb, null, 'percent', 23, 'purchase', 'foreign_services_received', date '2011-01-01', null, 'Código do IVA, art. 6.º, n.º 6, alínea a), e art. 2.º, n.º 1, alínea e) — o adquirente sujeito passivo estabelecido em território nacional autoliquida o imposto devido por um prestador não estabelecido na União. Declaração periódica: liquidação no campo 16/17, dedução no campo 24', null, null, 230, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'civa-art18', null, null, null, null),
  ('PT', 'PT-P-ICG-23', 'Aquisição intracomunitária de bens à taxa normal (23 %)', '{"en":"Intra-Community acquisition of goods at the standard rate (23 %)"}'::jsonb, null, 'percent', 23, 'purchase', 'intracom_acquisition_goods', date '2011-01-01', null, 'RITI, arts. 4.º a 8.º — sujeição a imposto e sujeito passivo o adquirente; art. 19.º e seguintes do CIVA quanto à dedução. Declaração periódica: base e imposto liquidado no campo 12/13, dedução no campo 24, sem desdobramento por taxa; declarada na declaração recapitulativa do fornecedor comunitário', 'K', 'VATEX-EU-IC', 210, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'riti', null, null, null, null),
  ('PT', 'PT-P-IMP-23', 'Importação à taxa normal (23 %), liquidada pela alfândega', '{"en":"Import at the standard rate (23 %), assessed by customs"}'::jsonb, null, 'percent', 23, 'purchase', 'import', date '2011-01-01', null, 'Código do IVA, arts. 5.º e 17.º — sujeição das importações; art. 27.º — liquidação e cobrança pelos serviços aduaneiros; art. 19.º, n.º 1, alínea b) — o documento de importação justifica a dedução. Declaração periódica: campo 18/19', null, null, 240, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'civa-art18', null, null, null, null),
  ('PT', 'PT-P-ISP-23', 'Compra interna com inversão do sujeito passivo, à taxa normal (23 %)', '{"en":"Domestic purchase under the reverse charge, at the standard rate (23 %)"}'::jsonb, null, 'percent', 23, 'purchase', 'domestic_reverse_charge', date '2007-04-01', null, 'Código do IVA, art. 2.º, n.º 1, alíneas i), j) e l) — o adquirente é sujeito passivo e autoliquida o imposto que, sendo dedutível, também deduz na mesma declaração. Declaração periódica: liquidação na mesma linha da taxa normal, campo 3/4, dedução no campo 24', 'AE', 'VATEX-EU-AE', 220, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'civa-art18', null, null, null, null),
  ('PT', 'PT-P-SERV-23', 'Compra de outros bens e serviços à taxa normal (23 %), dedutível', '{"en":"Purchase of other goods and services at the standard rate (23 %), deductible"}'::jsonb, null, 'percent', 23, 'purchase', 'domestic', date '2011-01-01', null, 'Código do IVA, arts. 19.º a 25.º. Declaração periódica, quadro 06, campo 24 — IVA dedutível de outros bens e serviços, sem desdobramento por taxa', 'S', null, 190, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'civa-art18', null, null, null, null),
  ('PT', 'PT-S-13', 'Vendas e serviços à taxa intermédia (13 %)', '{"en":"Sales and services at the intermediate rate (13 %)"}'::jsonb, null, 'percent', 13, 'sale', 'domestic', date '2011-01-01', null, 'Código do IVA, art. 18.º, n.º 1, alínea b) — taxa intermédia de 13 %, na redação da Lei n.º 55-A/2010. Declaração periódica, quadro 06, campo 5 (base) e campo 6 (imposto)', 'S', null, 20, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'civa-art18', null, null, null, null),
  ('PT', 'PT-S-23', 'Vendas e serviços à taxa normal (23 %)', '{"en":"Sales and services at the standard rate (23 %)"}'::jsonb, null, 'percent', 23, 'sale', 'domestic', date '2011-01-01', null, 'Código do IVA, art. 18.º, n.º 1, alínea c) — taxa normal de 23 %, na redação da Lei n.º 55-A/2010, de 31 de dezembro (Orçamento do Estado para 2011), com efeitos desde 1 de janeiro de 2011. Declaração periódica, quadro 06, campo 3 (base) e campo 4 (imposto)', 'S', null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'civa-art18', null, null, null, null),
  ('PT', 'PT-S-6', 'Vendas e serviços à taxa reduzida (6 %)', '{"en":"Sales and services at the reduced rate (6 %)"}'::jsonb, null, 'percent', 6, 'sale', 'domestic', date '2011-01-01', null, 'Código do IVA, art. 18.º, n.º 1, alínea a) — taxa reduzida de 6 %, na redação da Lei n.º 55-A/2010. Declaração periódica, quadro 06, campo 1 (base) e campo 2 (imposto)', 'S', null, 30, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'civa-art18', null, null, null, null),
  ('PT', 'PT-S-AC-16', 'Vendas e serviços na Região Autónoma dos Açores, taxa normal (16 %)', '{"en":"Sales and services in the Azores, standard rate (16 %)"}'::jsonb, null, 'percent', 16, 'sale', 'domestic', date '2021-07-01', null, 'Código do IVA, art. 18.º, n.º 3; Decreto Legislativo Regional n.º 15-A/2021/A — taxa normal de 16 % aplicável às operações localizadas na Região Autónoma dos Açores, desde 1 de julho de 2021. Mesma linha do quadro 06 que a taxa normal do continente, campo 3 (base) e campo 4 (imposto): o formulário nacional não distingue a região do sujeito passivo', 'S', null, 40, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'dlr-15-a-2021-a', null, null, 'PT-20', null),
  ('PT', 'PT-S-AC-4', 'Vendas e serviços na Região Autónoma dos Açores, taxa reduzida (4 %)', '{"en":"Sales and services in the Azores, reduced rate (4 %)"}'::jsonb, null, 'percent', 4, 'sale', 'domestic', date '2021-07-01', null, 'Código do IVA, art. 18.º, n.º 3; Decreto Legislativo Regional n.º 15-A/2021/A — taxa reduzida de 4 %, desde 1 de julho de 2021. Campo 1 (base) e campo 2 (imposto)', 'S', null, 60, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'dlr-15-a-2021-a', null, null, 'PT-20', null),
  ('PT', 'PT-S-AC-9', 'Vendas e serviços na Região Autónoma dos Açores, taxa intermédia (9 %)', '{"en":"Sales and services in the Azores, intermediate rate (9 %)"}'::jsonb, null, 'percent', 9, 'sale', 'domestic', date '2021-07-01', null, 'Código do IVA, art. 18.º, n.º 3; Decreto Legislativo Regional n.º 15-A/2021/A — taxa intermédia de 9 %, desde 1 de julho de 2021. Campo 5 (base) e campo 6 (imposto)', 'S', null, 50, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'dlr-15-a-2021-a', null, null, 'PT-20', null),
  ('PT', 'PT-S-EXE', 'Operação interna isenta', '{"en":"Exempt domestic supply"}'::jsonb, null, 'percent', 0, 'sale', 'exempt', date '1993-01-01', null, 'Código do IVA, art. 9.º — isenções nas operações internas, sem direito à dedução. Declaração periódica, quadro 06, campo 9', 'E', 'VATEX-EU-132', 150, 'vat', true, array['supply_nature']::tax_condition[], null, false, false, null, 'civa-art9', null, null, null, null),
  ('PT', 'PT-S-EXP', 'Exportação isenta', '{"en":"Exempt export"}'::jsonb, null, 'percent', 0, 'sale', 'export', date '1993-01-01', null, 'Código do IVA, art. 14.º — isenções nas exportações, operações assimiladas a exportações e transportes internacionais. Declaração periódica, quadro 06, campo 8', 'G', 'VATEX-EU-G', 130, 'vat', true, array['transport_evidence']::tax_condition[], null, false, false, null, 'civa-art14', null, null, null, null),
  ('PT', 'PT-S-ICG', 'Transmissão intracomunitária de bens isenta', '{"en":"Exempt intra-Community supply of goods"}'::jsonb, null, 'percent', 0, 'sale', 'intracom_goods', date '1993-01-01', null, 'RITI, art. 14.º — isenção das transmissões de bens expedidos ou transportados para outro Estado-membro, com destino a um sujeito passivo aí registado para efeitos de IVA. Declaração periódica, quadro 06, campo 7; declarada na declaração recapitulativa com o código E', 'K', 'VATEX-EU-IC', 110, 'vat', true, array['transport_evidence', 'buyer_status']::tax_condition[], null, false, false, null, 'riti', null, null, null, null),
  ('PT', 'PT-S-ICS', 'Prestação intracomunitária de serviços (autoliquidação pelo adquirente)', '{"en":"Intra-Community supply of services (reverse-charged to the customer)"}'::jsonb, null, 'percent', 0, 'sale', 'intracom_services', date '2010-01-01', null, 'Código do IVA, art. 6.º, n.º 6, alínea a) — localização no Estado-membro do adquirente sujeito passivo, que aí se autoliquida. Declaração periódica, quadro 06, campo 7; declarada na declaração recapitulativa com o código S', 'K', 'VATEX-EU-IC', 120, 'vat', true, array['buyer_status']::tax_condition[], null, false, false, null, 'civa-art36', null, null, null, null),
  ('PT', 'PT-S-ISP', 'Operação interna com inversão do sujeito passivo', '{"en":"Domestic supply under the reverse charge"}'::jsonb, null, 'percent', 0, 'sale', 'domestic_reverse_charge', date '2007-04-01', null, 'Código do IVA, art. 2.º, n.º 1, alíneas i), j) e l) — é sujeito passivo o adquirente, sendo este uma pessoa singular ou coletiva referida na alínea a), em operações de desperdícios, resíduos e sucatas recicláveis, de serviços de construção civil e de determinados bens e serviços indicados no Anexo I ao Código. Declaração periódica, quadro 06, campo 8 — o valor destas operações é inscrito no campo 8 pelo transmitente, que não liquida imposto', 'AE', 'VATEX-EU-AE', 140, 'vat', true, array['supply_nature', 'buyer_status']::tax_condition[], null, false, false, null, 'civa-art18', null, null, null, null),
  ('PT', 'PT-S-MA-12', 'Vendas e serviços na Região Autónoma da Madeira, taxa intermédia (12 %)', '{"en":"Sales and services in Madeira, intermediate rate (12 %)"}'::jsonb, null, 'percent', 12, 'sale', 'domestic', date '2012-04-01', null, 'Código do IVA, art. 18.º, n.º 3; Lei n.º 14-A/2012 — taxa intermédia de 12 %, desde 1 de abril de 2012. Campo 5 (base) e campo 6 (imposto)', 'S', null, 80, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'lei-14-a-2012', null, null, 'PT-30', null),
  ('PT', 'PT-S-MA-22', 'Vendas e serviços na Região Autónoma da Madeira, taxa normal (22 %)', '{"en":"Sales and services in Madeira, standard rate (22 %)"}'::jsonb, null, 'percent', 22, 'sale', 'domestic', date '2012-04-01', null, 'Código do IVA, art. 18.º, n.º 3; Lei n.º 14-A/2012, de 30 de março — taxa normal de 22 % aplicável às operações localizadas na Região Autónoma da Madeira, desde 1 de abril de 2012. Campo 3 (base) e campo 4 (imposto)', 'S', null, 70, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'lei-14-a-2012', null, null, 'PT-30', null),
  ('PT', 'PT-S-MA-4', 'Vendas e serviços na Região Autónoma da Madeira, taxa reduzida (4 %, desde 01/10/2024)', '{"en":"Sales and services in Madeira, reduced rate (4 %, from 01/10/2024)"}'::jsonb, null, 'percent', 4, 'sale', 'domestic', date '2024-10-01', null, 'Código do IVA, art. 18.º, n.º 3; Decreto Legislativo Regional n.º 6/2024/M, de 29 de julho, art. 21.º — taxa reduzida de 4 % na Região Autónoma da Madeira, desde 1 de outubro de 2024. Campo 1 (base) e campo 2 (imposto)', 'S', null, 100, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'dlr-6-2024-m', null, null, 'PT-30', null),
  ('PT', 'PT-S-MA-5', 'Vendas e serviços na Região Autónoma da Madeira, taxa reduzida (5 %, até 30/09/2024)', '{"en":"Sales and services in Madeira, reduced rate (5 %, until 30/09/2024)"}'::jsonb, null, 'percent', 5, 'sale', 'domestic', date '2012-04-01', date '2024-09-30', 'Código do IVA, art. 18.º, n.º 3; Lei n.º 14-A/2012 — taxa reduzida de 5 %, de 1 de abril de 2012 a 30 de setembro de 2024, substituída pelos 4 % do Decreto Legislativo Regional n.º 6/2024/M. Campo 1 (base) e campo 2 (imposto)', 'S', null, 90, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'lei-14-a-2012', null, null, 'PT-30', null)
on conflict (country, code) do update set
  name            = excluded.name,
  name_i18n       = excluded.name_i18n,
  description     = excluded.description,
  amount_type     = excluded.amount_type,
  amount          = excluded.amount,
  applies_to      = excluded.applies_to,
  treatment       = excluded.treatment,
  valid_from      = excluded.valid_from,
  valid_to        = excluded.valid_to,
  legal_reference = excluded.legal_reference,
  vat_category    = excluded.vat_category,
  exemption_code  = excluded.exemption_code,
  sequence        = excluded.sequence,
  tax_kind        = excluded.tax_kind,
  recoverable     = excluded.recoverable,
  conditions      = excluded.conditions,
  jurisdiction    = excluded.jurisdiction,
  price_include   = excluded.price_include,
  cash_basis      = excluded.cash_basis,
  cash_basis_transition_account_code = excluded.cash_basis_transition_account_code,
  source_key      = excluded.source_key,
  applies_seller_territory = excluded.applies_seller_territory,
  applies_buyer_territory  = excluded.applies_buyer_territory,
  applies_supply_territory = excluded.applies_supply_territory,
  applies_supply_vs_seller = excluded.applies_supply_vs_seller;

insert into tax_posting_templates
  (tax_template_id, document_kind, posting_type, factor_percent, account_code,
   declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
select t.id,
       v.document_kind::tax_document_kind,
       v.posting_type::tax_posting_type,
       v.factor_percent::numeric,
       v.account_code::text,
       v.declaration_box::text,
       v.declaration_boxes::text[],
       v.box_factor_percent::numeric,
       v.report_code::text,
       v.sequence::integer
  from (values
    ('PT-P-AFT-23', 'invoice', 'tax', 100, '2432', '20', array['20']::text[], 100, 'PT-DP-IVA', 10),
    ('PT-P-AFT-23', 'credit_note', 'tax', 100, '2432', '41', array['41']::text[], -100, 'PT-DP-IVA', 10),
    ('PT-P-BENS-13', 'invoice', 'tax', 100, '2432', '22', array['22']::text[], 100, 'PT-DP-IVA', 10),
    ('PT-P-BENS-13', 'credit_note', 'tax', 100, '2432', '41', array['41']::text[], -100, 'PT-DP-IVA', 10),
    ('PT-P-BENS-23', 'invoice', 'tax', 100, '2432', '23', array['23']::text[], 100, 'PT-DP-IVA', 10),
    ('PT-P-BENS-23', 'credit_note', 'tax', 100, '2432', '41', array['41']::text[], -100, 'PT-DP-IVA', 10),
    ('PT-P-BENS-6', 'invoice', 'tax', 100, '2432', '21', array['21']::text[], 100, 'PT-DP-IVA', 10),
    ('PT-P-BENS-6', 'credit_note', 'tax', 100, '2432', '41', array['41']::text[], -100, 'PT-DP-IVA', 10),
    ('PT-P-EXC-23', 'invoice', 'tax_on_base', 100, null, null, null, 100, null, 10),
    ('PT-P-EXC-23', 'credit_note', 'tax_on_base', 100, null, null, null, 100, null, 10),
    ('PT-P-EXT-23', 'invoice', 'base', 100, null, '16', array['16']::text[], 100, 'PT-DP-IVA', 10),
    ('PT-P-EXT-23', 'invoice', 'tax', 100, '2432', '24', array['24']::text[], 100, 'PT-DP-IVA', 20),
    ('PT-P-EXT-23', 'invoice', 'tax', -100, '2433', '17', array['17']::text[], 100, 'PT-DP-IVA', 30),
    ('PT-P-EXT-23', 'credit_note', 'base', 100, null, '16', array['16']::text[], -100, 'PT-DP-IVA', 10),
    ('PT-P-EXT-23', 'credit_note', 'tax', 100, '2432', '24', array['24']::text[], -100, 'PT-DP-IVA', 20),
    ('PT-P-EXT-23', 'credit_note', 'tax', -100, '2433', '17', array['17']::text[], -100, 'PT-DP-IVA', 30),
    ('PT-P-ICG-23', 'invoice', 'base', 100, null, '12', array['12']::text[], 100, 'PT-DP-IVA', 10),
    ('PT-P-ICG-23', 'invoice', 'tax', 100, '2432', '24', array['24']::text[], 100, 'PT-DP-IVA', 20),
    ('PT-P-ICG-23', 'invoice', 'tax', -100, '2433', '13', array['13']::text[], 100, 'PT-DP-IVA', 30),
    ('PT-P-ICG-23', 'credit_note', 'base', 100, null, '12', array['12']::text[], -100, 'PT-DP-IVA', 10),
    ('PT-P-ICG-23', 'credit_note', 'tax', 100, '2432', '24', array['24']::text[], -100, 'PT-DP-IVA', 20),
    ('PT-P-ICG-23', 'credit_note', 'tax', -100, '2433', '13', array['13']::text[], -100, 'PT-DP-IVA', 30),
    ('PT-P-IMP-23', 'invoice', 'base', 100, null, '18', array['18']::text[], 100, 'PT-DP-IVA', 10),
    ('PT-P-IMP-23', 'invoice', 'tax', 100, '2432', '24', array['24']::text[], 100, 'PT-DP-IVA', 20),
    ('PT-P-IMP-23', 'invoice', 'tax', -100, '2433', '19', array['19']::text[], 100, 'PT-DP-IVA', 30),
    ('PT-P-IMP-23', 'credit_note', 'base', 100, null, '18', array['18']::text[], -100, 'PT-DP-IVA', 10),
    ('PT-P-IMP-23', 'credit_note', 'tax', 100, '2432', '24', array['24']::text[], -100, 'PT-DP-IVA', 20),
    ('PT-P-IMP-23', 'credit_note', 'tax', -100, '2433', '19', array['19']::text[], -100, 'PT-DP-IVA', 30),
    ('PT-P-ISP-23', 'invoice', 'base', 100, null, '3', array['3']::text[], 100, 'PT-DP-IVA', 10),
    ('PT-P-ISP-23', 'invoice', 'tax', 100, '2432', '24', array['24']::text[], 100, 'PT-DP-IVA', 20),
    ('PT-P-ISP-23', 'invoice', 'tax', -100, '2433', '4', array['4']::text[], 100, 'PT-DP-IVA', 30),
    ('PT-P-ISP-23', 'credit_note', 'base', 100, null, '3', array['3']::text[], -100, 'PT-DP-IVA', 10),
    ('PT-P-ISP-23', 'credit_note', 'tax', 100, '2432', '24', array['24']::text[], -100, 'PT-DP-IVA', 20),
    ('PT-P-ISP-23', 'credit_note', 'tax', -100, '2433', '4', array['4']::text[], -100, 'PT-DP-IVA', 30),
    ('PT-P-SERV-23', 'invoice', 'tax', 100, '2432', '24', array['24']::text[], 100, 'PT-DP-IVA', 10),
    ('PT-P-SERV-23', 'credit_note', 'tax', 100, '2432', '41', array['41']::text[], -100, 'PT-DP-IVA', 10),
    ('PT-S-13', 'invoice', 'base', 100, null, '5', array['5']::text[], 100, 'PT-DP-IVA', 10),
    ('PT-S-13', 'invoice', 'tax', 100, '2433', '6', array['6']::text[], 100, 'PT-DP-IVA', 20),
    ('PT-S-13', 'credit_note', 'tax', 100, '2433', '40', array['40']::text[], -100, 'PT-DP-IVA', 10),
    ('PT-S-23', 'invoice', 'base', 100, null, '3', array['3']::text[], 100, 'PT-DP-IVA', 10),
    ('PT-S-23', 'invoice', 'tax', 100, '2433', '4', array['4']::text[], 100, 'PT-DP-IVA', 20),
    ('PT-S-23', 'credit_note', 'tax', 100, '2433', '40', array['40']::text[], -100, 'PT-DP-IVA', 10),
    ('PT-S-6', 'invoice', 'base', 100, null, '1', array['1']::text[], 100, 'PT-DP-IVA', 10),
    ('PT-S-6', 'invoice', 'tax', 100, '2433', '2', array['2']::text[], 100, 'PT-DP-IVA', 20),
    ('PT-S-6', 'credit_note', 'tax', 100, '2433', '40', array['40']::text[], -100, 'PT-DP-IVA', 10),
    ('PT-S-AC-16', 'invoice', 'base', 100, null, '3', array['3']::text[], 100, 'PT-DP-IVA', 10),
    ('PT-S-AC-16', 'invoice', 'tax', 100, '2433', '4', array['4']::text[], 100, 'PT-DP-IVA', 20),
    ('PT-S-AC-16', 'credit_note', 'tax', 100, '2433', '40', array['40']::text[], -100, 'PT-DP-IVA', 10),
    ('PT-S-AC-4', 'invoice', 'base', 100, null, '1', array['1']::text[], 100, 'PT-DP-IVA', 10),
    ('PT-S-AC-4', 'invoice', 'tax', 100, '2433', '2', array['2']::text[], 100, 'PT-DP-IVA', 20),
    ('PT-S-AC-4', 'credit_note', 'tax', 100, '2433', '40', array['40']::text[], -100, 'PT-DP-IVA', 10),
    ('PT-S-AC-9', 'invoice', 'base', 100, null, '5', array['5']::text[], 100, 'PT-DP-IVA', 10),
    ('PT-S-AC-9', 'invoice', 'tax', 100, '2433', '6', array['6']::text[], 100, 'PT-DP-IVA', 20),
    ('PT-S-AC-9', 'credit_note', 'tax', 100, '2433', '40', array['40']::text[], -100, 'PT-DP-IVA', 10),
    ('PT-S-EXE', 'invoice', 'base', 100, null, '9', array['9']::text[], 100, 'PT-DP-IVA', 10),
    ('PT-S-EXE', 'credit_note', 'base', 100, null, '9', array['9']::text[], -100, 'PT-DP-IVA', 10),
    ('PT-S-EXP', 'invoice', 'base', 100, null, '8', array['8']::text[], 100, 'PT-DP-IVA', 10),
    ('PT-S-EXP', 'credit_note', 'base', 100, null, '8', array['8']::text[], -100, 'PT-DP-IVA', 10),
    ('PT-S-ICG', 'invoice', 'base', 100, null, '7', array['7']::text[], 100, 'PT-DP-IVA', 10),
    ('PT-S-ICG', 'credit_note', 'base', 100, null, '7', array['7']::text[], -100, 'PT-DP-IVA', 10),
    ('PT-S-ICS', 'invoice', 'base', 100, null, '7', array['7']::text[], 100, 'PT-DP-IVA', 10),
    ('PT-S-ICS', 'credit_note', 'base', 100, null, '7', array['7']::text[], -100, 'PT-DP-IVA', 10),
    ('PT-S-ISP', 'invoice', 'base', 100, null, '8', array['8']::text[], 100, 'PT-DP-IVA', 10),
    ('PT-S-ISP', 'credit_note', 'base', 100, null, '8', array['8']::text[], -100, 'PT-DP-IVA', 10),
    ('PT-S-MA-12', 'invoice', 'base', 100, null, '5', array['5']::text[], 100, 'PT-DP-IVA', 10),
    ('PT-S-MA-12', 'invoice', 'tax', 100, '2433', '6', array['6']::text[], 100, 'PT-DP-IVA', 20),
    ('PT-S-MA-12', 'credit_note', 'tax', 100, '2433', '40', array['40']::text[], -100, 'PT-DP-IVA', 10),
    ('PT-S-MA-22', 'invoice', 'base', 100, null, '3', array['3']::text[], 100, 'PT-DP-IVA', 10),
    ('PT-S-MA-22', 'invoice', 'tax', 100, '2433', '4', array['4']::text[], 100, 'PT-DP-IVA', 20),
    ('PT-S-MA-22', 'credit_note', 'tax', 100, '2433', '40', array['40']::text[], -100, 'PT-DP-IVA', 10),
    ('PT-S-MA-4', 'invoice', 'base', 100, null, '1', array['1']::text[], 100, 'PT-DP-IVA', 10),
    ('PT-S-MA-4', 'invoice', 'tax', 100, '2433', '2', array['2']::text[], 100, 'PT-DP-IVA', 20),
    ('PT-S-MA-4', 'credit_note', 'tax', 100, '2433', '40', array['40']::text[], -100, 'PT-DP-IVA', 10),
    ('PT-S-MA-5', 'invoice', 'base', 100, null, '1', array['1']::text[], 100, 'PT-DP-IVA', 10),
    ('PT-S-MA-5', 'invoice', 'tax', 100, '2433', '2', array['2']::text[], 100, 'PT-DP-IVA', 20),
    ('PT-S-MA-5', 'credit_note', 'tax', 100, '2433', '40', array['40']::text[], -100, 'PT-DP-IVA', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'PT' and t.code = v.tax_code
on conflict (tax_template_id, document_kind, posting_type, sequence) do update set
  factor_percent     = excluded.factor_percent,
  account_code       = excluded.account_code,
  declaration_box    = excluded.declaration_box,
  declaration_boxes  = excluded.declaration_boxes,
  box_factor_percent = excluded.box_factor_percent,
  report_code        = excluded.report_code;

insert into tax_report_templates
  (country, code, name, periods, period_default, valid_from, valid_to, legal_reference,
   is_periodic_return, deadline_rule, deadline_day, deadline_plus_days,
   deadline_reference, deadline_source_key, file_format)
values
  ('PT', 'PT-DP-IVA', 'Declaração Periódica do IVA', array['month', 'quarter']::declaration_period[], null, date '2024-09-01', null, 'Código do IVA, art. 41.º — quem realizou, no ano civil anterior, um volume de negócios igual ou superior a 650 000 euros entrega a declaração mensalmente; os restantes sujeitos passivos, trimestralmente, podendo optar pelo regime mensal. Modelo aprovado pela Portaria n.º 221/2017, de 21 de julho, com as alterações posteriores; a caixa 165/167 dos períodos de 2024 e as caixas do novo modelo da Portaria n.º 298/2026/1, de 16 de julho, aplicável às declarações a partir do período de julho de 2027 (e, para algumas caixas, já a partir de julho de 2026), não são transcritas aqui', true,null, null, null, null, null, null)
on conflict (country, code) do update set
  name                = excluded.name,
  periods             = excluded.periods,
  period_default      = excluded.period_default,
  valid_from          = excluded.valid_from,
  valid_to            = excluded.valid_to,
  legal_reference     = excluded.legal_reference,
  is_periodic_return  = excluded.is_periodic_return,
  deadline_rule       = excluded.deadline_rule,
  deadline_day        = excluded.deadline_day,
  deadline_plus_days  = excluded.deadline_plus_days,
  deadline_reference  = excluded.deadline_reference,
  deadline_source_key = excluded.deadline_source_key,
  file_format         = excluded.file_format;

insert into tax_report_box_templates
  (country, report_code, box, kind, name, name_i18n, sequence, print_sequence,
   plus_boxes, minus_boxes, rate, rate_of_box, floor_zero, hidden, xml_element,
   legal_reference, source_key)
values
  ('PT', 'PT-DP-IVA', '1', 'base', 'Continente/Açores/Madeira — base tributável à taxa reduzida', '{"en":"Mainland/Azores/Madeira — taxable amount at the reduced rate"}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Declaração periódica do IVA, quadro 06 — base tributável das operações à taxa reduzida (6 % no continente, 4 % nos Açores, 4 % ou 5 % na Madeira, conforme a data)', 'portaria-221-2017'),
  ('PT', 'PT-DP-IVA', '2', 'tax', 'Continente/Açores/Madeira — imposto liquidado à taxa reduzida', '{"en":"Mainland/Azores/Madeira — tax charged at the reduced rate"}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Declaração periódica do IVA, quadro 06, campo 2', 'portaria-221-2017'),
  ('PT', 'PT-DP-IVA', '5', 'base', 'Continente/Açores/Madeira — base tributável à taxa intermédia', '{"en":"Mainland/Azores/Madeira — taxable amount at the intermediate rate"}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Declaração periódica do IVA, quadro 06 — base tributável das operações à taxa intermédia (13 % no continente, 9 % nos Açores, 12 % na Madeira)', 'portaria-221-2017'),
  ('PT', 'PT-DP-IVA', '6', 'tax', 'Continente/Açores/Madeira — imposto liquidado à taxa intermédia', '{"en":"Mainland/Azores/Madeira — tax charged at the intermediate rate"}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Declaração periódica do IVA, quadro 06, campo 6', 'portaria-221-2017'),
  ('PT', 'PT-DP-IVA', '3', 'base', 'Continente/Açores/Madeira — base tributável à taxa normal', '{"en":"Mainland/Azores/Madeira — taxable amount at the standard rate"}'::jsonb, 50, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Declaração periódica do IVA, quadro 06 — base tributável das operações à taxa normal (23 % no continente, 16 % nos Açores, 22 % na Madeira)', 'portaria-221-2017'),
  ('PT', 'PT-DP-IVA', '4', 'tax', 'Continente/Açores/Madeira — imposto liquidado à taxa normal', '{"en":"Mainland/Azores/Madeira — tax charged at the standard rate"}'::jsonb, 60, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Declaração periódica do IVA, quadro 06, campo 4', 'portaria-221-2017'),
  ('PT', 'PT-DP-IVA', '7', 'base', 'Transmissões intracomunitárias de bens e operações assimiladas, e prestações de serviços localizadas noutro Estado-membro', '{"en":"Intra-Community supplies of goods and assimilated transactions, and services located in another Member State"}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Declaração periódica do IVA, quadro 06, campo 7 — RITI, art. 14.º, e Código do IVA, art. 6.º, n.º 6, alínea a); operações incluídas na declaração recapitulativa', 'portaria-221-2017'),
  ('PT', 'PT-DP-IVA', '8', 'base', 'Outras operações isentas ou não tributadas que conferem direito à dedução', '{"en":"Other exempt or non-taxed transactions giving the right to deduct"}'::jsonb, 80, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Declaração periódica do IVA, quadro 06, campo 8 — Código do IVA, art. 20.º, n.º 1, alínea b): exportações e operações assimiladas (art. 14.º) e operações em que ocorreu a regra de inversão do sujeito passivo (art. 2.º, n.º 1)', 'portaria-221-2017'),
  ('PT', 'PT-DP-IVA', '9', 'base', 'Operações isentas ou não tributadas sem direito à dedução', '{"en":"Exempt or non-taxed transactions with no right to deduct"}'::jsonb, 90, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Declaração periódica do IVA, quadro 06, campo 9 — Código do IVA, art. 9.º', 'portaria-221-2017'),
  ('PT', 'PT-DP-IVA', '12', 'base', 'Aquisições intracomunitárias de bens e operações assimiladas — base tributável', '{"en":"Intra-Community acquisitions of goods and assimilated transactions — taxable amount"}'::jsonb, 100, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Declaração periódica do IVA, quadro 06, campo 12 — RITI, arts. 4.º a 8.º', 'portaria-221-2017'),
  ('PT', 'PT-DP-IVA', '13', 'tax', 'Aquisições intracomunitárias de bens e operações assimiladas — imposto liquidado', '{"en":"Intra-Community acquisitions of goods and assimilated transactions — tax charged"}'::jsonb, 110, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Declaração periódica do IVA, quadro 06, campo 13', 'portaria-221-2017'),
  ('PT', 'PT-DP-IVA', '16', 'base', 'Aquisições de serviços a prestadores não estabelecidos na União Europeia — base tributável', '{"en":"Services received from suppliers not established in the European Union — taxable amount"}'::jsonb, 120, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Declaração periódica do IVA, quadro 06, campo 16 — Código do IVA, art. 6.º, n.º 6, alínea a), e art. 2.º, n.º 1, alínea e)', 'portaria-221-2017'),
  ('PT', 'PT-DP-IVA', '17', 'tax', 'Aquisições de serviços a prestadores não estabelecidos na União Europeia — imposto liquidado', '{"en":"Services received from suppliers not established in the European Union — tax charged"}'::jsonb, 130, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Declaração periódica do IVA, quadro 06, campo 17', 'portaria-221-2017'),
  ('PT', 'PT-DP-IVA', '18', 'base', 'Importações de bens — base tributável', '{"en":"Imports of goods — taxable amount"}'::jsonb, 140, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Declaração periódica do IVA, quadro 06, campo 18 — Código do IVA, art. 27.º', 'portaria-221-2017'),
  ('PT', 'PT-DP-IVA', '19', 'tax', 'Importações de bens — imposto liquidado', '{"en":"Imports of goods — tax charged"}'::jsonb, 150, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Declaração periódica do IVA, quadro 06, campo 19', 'portaria-221-2017'),
  ('PT', 'PT-DP-IVA', '91', 'total', 'Total do imposto liquidado', '{"en":"Total tax charged"}'::jsonb, 160, null, array['2', '4', '6', '13', '17', '19', '40']::text[], '{}'::text[], null, null, false, false, null, 'Código do IVA, art. 26.º — apuramento do imposto: soma de todo o imposto liquidado no período; o campo 40 já entra com o sinal da regularização a favor do sujeito passivo (negativo), pelo que somá-lo reduz o total. A numeração exata desta caixa de resultado (habitualmente entre 90 e 96 no impresso oficial) não foi confirmada campo a campo contra o formulário — ver README do pacote', 'portaria-221-2017'),
  ('PT', 'PT-DP-IVA', '20', 'tax', 'IVA dedutível de ativos não correntes', '{"en":"Deductible VAT on non-current assets"}'::jsonb, 170, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Declaração periódica do IVA, quadro 06, campo 20 — Código do IVA, arts. 19.º a 25.º', 'portaria-221-2017'),
  ('PT', 'PT-DP-IVA', '21', 'tax', 'IVA dedutível de existências à taxa reduzida', '{"en":"Deductible VAT on inventories at the reduced rate"}'::jsonb, 180, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Declaração periódica do IVA, quadro 06, campo 21', 'portaria-221-2017'),
  ('PT', 'PT-DP-IVA', '22', 'tax', 'IVA dedutível de existências à taxa intermédia', '{"en":"Deductible VAT on inventories at the intermediate rate"}'::jsonb, 190, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Declaração periódica do IVA, quadro 06, campo 22', 'portaria-221-2017'),
  ('PT', 'PT-DP-IVA', '23', 'tax', 'IVA dedutível de existências à taxa normal', '{"en":"Deductible VAT on inventories at the standard rate"}'::jsonb, 200, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Declaração periódica do IVA, quadro 06, campo 23', 'portaria-221-2017'),
  ('PT', 'PT-DP-IVA', '24', 'tax', 'IVA dedutível de outros bens e serviços', '{"en":"Deductible VAT on other goods and services"}'::jsonb, 210, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Declaração periódica do IVA, quadro 06, campo 24', 'portaria-221-2017'),
  ('PT', 'PT-DP-IVA', '92', 'total', 'Total do imposto dedutível', '{"en":"Total deductible tax"}'::jsonb, 220, null, array['20', '21', '22', '23', '24', '41']::text[], '{}'::text[], null, null, false, false, null, 'Código do IVA, art. 19.º e seguintes — soma de todo o imposto dedutível no período; o campo 41 já entra com o sinal da regularização a favor do Estado (negativo), pelo que somá-lo reduz o total. A numeração exata desta caixa de resultado não foi confirmada campo a campo contra o formulário — ver README do pacote', 'portaria-221-2017'),
  ('PT', 'PT-DP-IVA', '40', 'tax', 'Regularizações mensais/trimestrais a favor do sujeito passivo', '{"en":"Monthly/quarterly adjustments in favour of the taxable person"}'::jsonb, 230, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Declaração periódica do IVA, quadro 06, campo 40 — Código do IVA, art. 78.º: notas de crédito emitidas a clientes, que reduzem o imposto liquidado', 'portaria-221-2017'),
  ('PT', 'PT-DP-IVA', '41', 'tax', 'Regularizações mensais/trimestrais a favor do Estado', '{"en":"Monthly/quarterly adjustments in favour of the State"}'::jsonb, 240, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Declaração periódica do IVA, quadro 06, campo 41 — Código do IVA, art. 78.º: notas de crédito recebidas de fornecedores, que reduzem o imposto dedutível', 'portaria-221-2017'),
  ('PT', 'PT-DP-IVA', '93', 'total', 'Imposto a entregar ao Estado / crédito a reportar ou a recuperar', '{"en":"Tax payable to the State / credit to carry forward or reclaim"}'::jsonb, 250, null, array['91']::text[], array['92']::text[], null, null, false, false, null, 'Código do IVA, art. 27.º — quando o imposto liquidado excede o dedutível, o excesso é entregue ao Estado; no caso inverso, o crédito transita para o período seguinte (art. 22.º, n.º 4) ou é objeto de pedido de reembolso (art. 22.º, n.º 5 e seguintes). A numeração exata desta caixa não foi confirmada campo a campo contra o formulário — ver README do pacote', 'portaria-221-2017')
on conflict (country, report_code, box, kind) do update set
  name            = excluded.name,
  name_i18n       = excluded.name_i18n,
  sequence        = excluded.sequence,
  print_sequence  = excluded.print_sequence,
  plus_boxes      = excluded.plus_boxes,
  minus_boxes     = excluded.minus_boxes,
  rate            = excluded.rate,
  rate_of_box     = excluded.rate_of_box,
  floor_zero      = excluded.floor_zero,
  hidden          = excluded.hidden,
  xml_element     = excluded.xml_element,
  legal_reference = excluded.legal_reference,
  source_key      = excluded.source_key;

insert into statement_templates
  (code, country, chart_code, name, kind, framework, valid_from, valid_to, legal_reference,
   source_key)
values
  ('PT-SNC-BAL', 'PT', 'default', 'Balanço', 'balance_sheet', 'PT-SNC', date '1970-01-01', null, 'Decreto-Lei n.º 158/2009, que aprova o SNC; Portaria n.º 220/2015, de 24 de julho — modelos de demonstrações financeiras. As legendas retomam a terminologia corrente do modelo de Balanço do SNC; o mapeamento conta a conta é uma seleção feita para este pacote e não uma transcrição campo a campo da portaria, cujo texto não pôde ser extraído automaticamente — ver README', 'portaria-220-2015'),
  ('PT-SNC-DR', 'PT', 'default', 'Demonstração dos Resultados por naturezas', 'income_statement', 'PT-SNC', date '1970-01-01', null, 'Decreto-Lei n.º 158/2009, que aprova o SNC; Portaria n.º 220/2015, de 24 de julho — modelo de Demonstração dos Resultados por naturezas. As legendas retomam a terminologia corrente do modelo; o mapeamento conta a conta é uma seleção feita para este pacote — ver README', 'portaria-220-2015')
on conflict (code) do update set
  country         = excluded.country,
  chart_code      = excluded.chart_code,
  name            = excluded.name,
  kind            = excluded.kind,
  framework       = excluded.framework,
  valid_from      = excluded.valid_from,
  valid_to        = excluded.valid_to,
  legal_reference = excluded.legal_reference,
  source_key      = excluded.source_key;

insert into statement_line_templates
  (statement_code, code, parent_code, name, name_i18n, sequence, sign, is_total,
   plus_lines, minus_lines, xbrl_element, legal_reference, source_key)
values
  ('PT-SNC-BAL', 'ANC', 'ATIVO', 'ATIVO NÃO CORRENTE', '{"en":"NON-CURRENT ASSETS"}'::jsonb, 10, 1, true, array['ANC.1', 'ANC.2', 'ANC.3']::text[], '{}'::text[], null, null, null),
  ('PT-SNC-BAL', 'ANC.1', 'ANC', 'Ativos fixos tangíveis', '{"en":"Tangible fixed assets"}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PT-SNC-BAL', 'ANC.2', 'ANC', 'Ativos intangíveis', '{"en":"Intangible assets"}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PT-SNC-BAL', 'ANC.3', 'ANC', 'Investimentos financeiros e outros ativos não correntes', '{"en":"Financial investments and other non-current assets"}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PT-SNC-BAL', 'AC', 'ATIVO', 'ATIVO CORRENTE', '{"en":"CURRENT ASSETS"}'::jsonb, 50, 1, true, array['AC.1', 'AC.2', 'AC.3', 'AC.4']::text[], '{}'::text[], null, null, null),
  ('PT-SNC-BAL', 'AC.1', 'AC', 'Inventários', '{"en":"Inventories"}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PT-SNC-BAL', 'AC.2', 'AC', 'Clientes', '{"en":"Customers"}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PT-SNC-BAL', 'AC.3', 'AC', 'Estado e outras contas a receber', '{"en":"State and other receivables"}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PT-SNC-BAL', 'AC.4', 'AC', 'Caixa e depósitos bancários', '{"en":"Cash and bank deposits"}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PT-SNC-BAL', 'ATIVO', null, 'TOTAL DO ATIVO', '{"en":"TOTAL ASSETS"}'::jsonb, 100, 1, true, array['ANC', 'AC']::text[], '{}'::text[], null, null, null),
  ('PT-SNC-BAL', 'CP', 'CPP', 'CAPITAL PRÓPRIO', '{"en":"EQUITY"}'::jsonb, 110, 1, true, array['CP.1', 'CP.2', 'CP.3', 'CP.4', 'CP.5', 'CP.6']::text[], '{}'::text[], null, null, null),
  ('PT-SNC-BAL', 'CP.1', 'CP', 'Capital realizado', '{"en":"Paid-in capital"}'::jsonb, 120, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PT-SNC-BAL', 'CP.2', 'CP', 'Prémios de emissão', '{"en":"Share premium"}'::jsonb, 130, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PT-SNC-BAL', 'CP.3', 'CP', 'Reservas', '{"en":"Reserves"}'::jsonb, 140, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PT-SNC-BAL', 'CP.4', 'CP', 'Resultados transitados', '{"en":"Retained earnings"}'::jsonb, 150, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PT-SNC-BAL', 'CP.5', 'CP', 'Outras variações no capital próprio', '{"en":"Other changes in equity"}'::jsonb, 160, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PT-SNC-BAL', 'CP.6', 'CP', 'Resultado líquido do período', '{"en":"Net profit or loss for the period"}'::jsonb, 170, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PT-SNC-BAL', 'PNC', 'PT', 'PASSIVO NÃO CORRENTE', '{"en":"NON-CURRENT LIABILITIES"}'::jsonb, 180, 1, true, array['PNC.1']::text[], '{}'::text[], null, null, null),
  ('PT-SNC-BAL', 'PNC.1', 'PNC', 'Financiamentos obtidos', '{"en":"Borrowings"}'::jsonb, 190, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PT-SNC-BAL', 'PC', 'PT', 'PASSIVO CORRENTE', '{"en":"CURRENT LIABILITIES"}'::jsonb, 200, 1, true, array['PC.1', 'PC.2', 'PC.3', 'PC.4']::text[], '{}'::text[], null, null, null),
  ('PT-SNC-BAL', 'PC.1', 'PC', 'Fornecedores', '{"en":"Suppliers"}'::jsonb, 210, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PT-SNC-BAL', 'PC.2', 'PC', 'Financiamentos obtidos de curto prazo', '{"en":"Short-term borrowings"}'::jsonb, 220, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PT-SNC-BAL', 'PC.3', 'PC', 'Estado e outros entes públicos', '{"en":"State and other public entities"}'::jsonb, 230, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PT-SNC-BAL', 'PC.4', 'PC', 'Outras contas a pagar', '{"en":"Other payables"}'::jsonb, 240, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PT-SNC-BAL', 'PT', null, 'TOTAL DO PASSIVO', '{"en":"TOTAL LIABILITIES"}'::jsonb, 250, 1, true, array['PNC', 'PC']::text[], '{}'::text[], null, null, null),
  ('PT-SNC-BAL', 'CPP', null, 'TOTAL DO CAPITAL PRÓPRIO E DO PASSIVO', '{"en":"TOTAL EQUITY AND LIABILITIES"}'::jsonb, 260, 1, true, array['CP', 'PT']::text[], '{}'::text[], null, null, null),
  ('PT-SNC-DR', '1', 'A', 'Vendas e serviços prestados', '{"en":"Sales and services rendered"}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PT-SNC-DR', '2', 'A', 'Subsídios à exploração', '{"en":"Operating subsidies"}'::jsonb, 20, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PT-SNC-DR', '3', 'A', 'Custo das mercadorias vendidas e das matérias consumidas', '{"en":"Cost of goods sold and materials consumed"}'::jsonb, 30, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PT-SNC-DR', '4', 'A', 'Fornecimentos e serviços externos', '{"en":"External supplies and services"}'::jsonb, 40, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PT-SNC-DR', '5', 'A', 'Gastos com o pessoal', '{"en":"Staff costs"}'::jsonb, 50, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PT-SNC-DR', '6', 'A', 'Imparidade de inventários e de dívidas a receber', '{"en":"Impairment of inventories and receivables"}'::jsonb, 60, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PT-SNC-DR', '7', 'A', 'Provisões do período', '{"en":"Provisions for the period"}'::jsonb, 70, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PT-SNC-DR', '8', 'A', 'Outros rendimentos e ganhos', '{"en":"Other income and gains"}'::jsonb, 80, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PT-SNC-DR', '9', 'A', 'Outros gastos e perdas', '{"en":"Other expenses and losses"}'::jsonb, 90, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PT-SNC-DR', '10', 'A', 'Gastos de depreciação e de amortização', '{"en":"Depreciation and amortisation expense"}'::jsonb, 100, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PT-SNC-DR', 'A', 'C', 'Resultado antes de depreciações, gastos de financiamento e impostos', '{"en":"Earnings before depreciation, financing expenses and taxes"}'::jsonb, 110, 1, true, array['1', '2', '3', '4', '5', '6', '7', '8', '9', '10']::text[], '{}'::text[], null, null, null),
  ('PT-SNC-DR', '11', 'B', 'Juros e rendimentos similares obtidos', '{"en":"Interest and similar income"}'::jsonb, 120, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PT-SNC-DR', '12', 'B', 'Juros e gastos similares suportados', '{"en":"Interest and similar expenses"}'::jsonb, 130, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PT-SNC-DR', 'B', 'C', 'Resultado financeiro', '{"en":"Net financing result"}'::jsonb, 140, 1, true, array['11', '12']::text[], '{}'::text[], null, null, null),
  ('PT-SNC-DR', 'C', 'D', 'Resultado antes de impostos', '{"en":"Profit or loss before tax"}'::jsonb, 150, 1, true, array['A', 'B']::text[], '{}'::text[], null, null, null),
  ('PT-SNC-DR', '13', 'D', 'Imposto sobre o rendimento do período', '{"en":"Income tax for the period"}'::jsonb, 160, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PT-SNC-DR', 'D', null, 'Resultado líquido do período', '{"en":"Net profit or loss for the period"}'::jsonb, 170, 1, true, array['C', '13']::text[], '{}'::text[], null, null, null)
on conflict (statement_code, code) do update set
  parent_code     = excluded.parent_code,
  name            = excluded.name,
  name_i18n       = excluded.name_i18n,
  sequence        = excluded.sequence,
  sign            = excluded.sign,
  is_total        = excluded.is_total,
  plus_lines      = excluded.plus_lines,
  minus_lines     = excluded.minus_lines,
  xbrl_element    = excluded.xbrl_element,
  legal_reference = excluded.legal_reference,
  source_key      = excluded.source_key;

insert into statement_line_rules
  (statement_code, line_code, sequence, rule_kind, code_from, code_to,
   account_type, balance_side)
select v.statement_code, v.line_code, v.sequence, v.rule_kind, v.code_from,
       v.code_to, v.account_type::account_type, v.balance_side
  from (values
    ('PT-SNC-BAL', 'ANC.1', 10, 'code_range', '431', '439', null, 'any'),
    ('PT-SNC-BAL', 'ANC.2', 10, 'code_range', '441', '449', null, 'any'),
    ('PT-SNC-BAL', 'ANC.3', 10, 'code_range', '41', '42', null, 'any'),
    ('PT-SNC-BAL', 'ANC.3', 20, 'code_range', '45', '45', null, 'any'),
    ('PT-SNC-BAL', 'AC.1', 10, 'code_range', '32', '39', null, 'any'),
    ('PT-SNC-BAL', 'AC.2', 10, 'code_range', '21', '21', null, 'any'),
    ('PT-SNC-BAL', 'AC.3', 10, 'code_range', '232', '232', null, 'any'),
    ('PT-SNC-BAL', 'AC.3', 20, 'code_range', '2432', '2432', null, 'any'),
    ('PT-SNC-BAL', 'AC.3', 30, 'code_range', '2437', '2437', null, 'any'),
    ('PT-SNC-BAL', 'AC.3', 40, 'code_range', '263', '264', null, 'any'),
    ('PT-SNC-BAL', 'AC.3', 50, 'code_range', '271', '271', null, 'any'),
    ('PT-SNC-BAL', 'AC.3', 60, 'code_range', '273', '273', null, 'any'),
    ('PT-SNC-BAL', 'AC.3', 70, 'code_range', '278', '279', null, 'any'),
    ('PT-SNC-BAL', 'AC.3', 80, 'code_range', '46', '46', null, 'any'),
    ('PT-SNC-BAL', 'AC.4', 10, 'code_range', '1', '1', null, 'any'),
    ('PT-SNC-BAL', 'CP.1', 10, 'code_range', '51', '51', null, 'any'),
    ('PT-SNC-BAL', 'CP.2', 10, 'code_range', '54', '54', null, 'any'),
    ('PT-SNC-BAL', 'CP.3', 10, 'code_range', '55', '55', null, 'any'),
    ('PT-SNC-BAL', 'CP.4', 10, 'code_range', '56', '56', null, 'any'),
    ('PT-SNC-BAL', 'CP.5', 10, 'code_range', '59', '59', null, 'any'),
    ('PT-SNC-BAL', 'CP.6', 10, 'code_range', '81', '81', null, 'any'),
    ('PT-SNC-BAL', 'PNC.1', 10, 'code_range', '251', '251', null, 'any'),
    ('PT-SNC-BAL', 'PC.1', 10, 'code_range', '22', '22', null, 'any'),
    ('PT-SNC-BAL', 'PC.2', 10, 'code_range', '258', '258', null, 'any'),
    ('PT-SNC-BAL', 'PC.3', 10, 'code_range', '241', '241', null, 'any'),
    ('PT-SNC-BAL', 'PC.3', 20, 'code_range', '2433', '2436', null, 'any'),
    ('PT-SNC-BAL', 'PC.3', 30, 'code_range', '244', '244', null, 'any'),
    ('PT-SNC-BAL', 'PC.3', 40, 'code_range', '231', '231', null, 'any'),
    ('PT-SNC-BAL', 'PC.4', 10, 'code_range', '268', '268', null, 'any'),
    ('PT-SNC-BAL', 'PC.4', 20, 'code_range', '272', '272', null, 'any'),
    ('PT-SNC-BAL', 'PC.4', 30, 'code_range', '274', '274', null, 'any'),
    ('PT-SNC-DR', '1', 10, 'code_range', '71', '72', null, 'any'),
    ('PT-SNC-DR', '2', 10, 'code_range', '75', '75', null, 'any'),
    ('PT-SNC-DR', '3', 10, 'code_range', '61', '61', null, 'any'),
    ('PT-SNC-DR', '4', 10, 'code_range', '62', '62', null, 'any'),
    ('PT-SNC-DR', '5', 10, 'code_range', '63', '63', null, 'any'),
    ('PT-SNC-DR', '6', 10, 'code_range', '65', '65', null, 'any'),
    ('PT-SNC-DR', '7', 10, 'code_range', '67', '67', null, 'any'),
    ('PT-SNC-DR', '8', 10, 'code_range', '76', '76', null, 'any'),
    ('PT-SNC-DR', '8', 20, 'code_range', '78', '78', null, 'any'),
    ('PT-SNC-DR', '9', 10, 'code_range', '68', '68', null, 'any'),
    ('PT-SNC-DR', '10', 10, 'code_range', '64', '64', null, 'any'),
    ('PT-SNC-DR', '11', 10, 'code_range', '79', '79', null, 'any'),
    ('PT-SNC-DR', '12', 10, 'code_range', '69', '69', null, 'any'),
    ('PT-SNC-DR', '13', 10, 'code_range', '82', '82', null, 'any')
  ) as v (statement_code, line_code, sequence, rule_kind, code_from, code_to,
          account_type, balance_side)
on conflict (statement_code, line_code, sequence) do update set
  rule_kind    = excluded.rule_kind,
  code_from    = excluded.code_from,
  code_to      = excluded.code_to,
  account_type = excluded.account_type,
  balance_side = excluded.balance_side;

insert into country_defaults
  (country, name, name_i18n, languages, currency_code, receivable_code, payable_code, suspense_code,
   rounding_code, retained_earnings_code, sales_account_code, purchase_account_code,
   bank_account_code, cash_account_code, sales_journal_code, purchase_journal_code,
   misc_journal_code, language_default, closing_style, current_year_result_profit_code,
   current_year_result_loss_code, retained_earnings_loss_code, opening_journal_code,
   rounding_method, cash_rounding_unit, fx_gain_code, fx_loss_code,
   asset_disposal_gain_code, asset_disposal_loss_code,
   asset_disposal_proceeds_code, asset_disposal_value_code,
   tax_payable_code, tax_receivable_code, opening_entry_label,
   vat_period_default)
values
  ('PT', 'Portugal', '{"en":"Portugal"}'::jsonb, array['pt', 'en']::text[], 'EUR', '211', '221', '278', null, '56', '71', '61', '12', '11', 'VEN', 'COM', 'DIV', 'pt', 'result_accounts', '81', '81', null, 'ABE', 'half_up', default, '786', '686', null, null, null, null, '2436', '2437', 'Lançamento de abertura', null)
on conflict (country) do update set
  name                   = excluded.name,
  name_i18n              = excluded.name_i18n,
  languages              = excluded.languages,
  currency_code          = excluded.currency_code,
  receivable_code        = excluded.receivable_code,
  payable_code           = excluded.payable_code,
  suspense_code          = excluded.suspense_code,
  rounding_code          = excluded.rounding_code,
  retained_earnings_code = excluded.retained_earnings_code,
  sales_account_code     = excluded.sales_account_code,
  purchase_account_code  = excluded.purchase_account_code,
  bank_account_code      = excluded.bank_account_code,
  cash_account_code      = excluded.cash_account_code,
  sales_journal_code     = excluded.sales_journal_code,
  purchase_journal_code  = excluded.purchase_journal_code,
  misc_journal_code      = excluded.misc_journal_code,
  language_default       = excluded.language_default,
  closing_style          = excluded.closing_style,
  current_year_result_profit_code = excluded.current_year_result_profit_code,
  current_year_result_loss_code   = excluded.current_year_result_loss_code,
  retained_earnings_loss_code     = excluded.retained_earnings_loss_code,
  opening_journal_code            = excluded.opening_journal_code,
  rounding_method        = excluded.rounding_method,
  cash_rounding_unit     = excluded.cash_rounding_unit,
  fx_gain_code           = excluded.fx_gain_code,
  fx_loss_code           = excluded.fx_loss_code,
  asset_disposal_gain_code        = excluded.asset_disposal_gain_code,
  asset_disposal_loss_code        = excluded.asset_disposal_loss_code,
  asset_disposal_proceeds_code    = excluded.asset_disposal_proceeds_code,
  asset_disposal_value_code       = excluded.asset_disposal_value_code,
  tax_payable_code                = excluded.tax_payable_code,
  tax_receivable_code             = excluded.tax_receivable_code,
  opening_entry_label             = excluded.opening_entry_label,
  vat_period_default              = excluded.vat_period_default;

update country_defaults set
  numbering_gapless             = true,
  number_format                 = '{CODE}/{YYYY}/{NNNN}',
  legal_payment_days            = 30,
  late_payment_reference        = 'Decreto-Lei n.º 62/2013, art. 4.º, n.º 3 — a falta de acordo, trinta dias a contar da receção da fatura ou dos bens/serviços; taxa de juro de mora: taxa de refinanciamento principal do BCE mais oito pontos percentuais (alteração ao art. 102.º do Código Comercial); art. 7.º — indemnização forfetária mínima de 40 euros pelos custos de cobrança, sem interpelação nem prova',
  numbering_legal_reference     = 'Decreto-Lei n.º 28/2019, de 15 de fevereiro — as séries de faturação são comunicadas previamente à Autoridade Tributária e a numeração é sequencial dentro de cada série; a prática corrente reinicia a série a cada ano civil',
  numbering_source_key          = 'dl-28-2019',
  payment_terms_legal_reference = 'Decreto-Lei n.º 62/2013, art. 4.º, n.º 3 — na falta de estipulação do prazo de pagamento no contrato, este é de trinta dias após a receção da fatura ou dos bens ou serviços',
  payment_terms_source_key      = 'dl-62-2013',
  tax_point_rule                = 'invoice_if_issued',
  tax_point_legal_reference     = 'Código do IVA, art. 7.º, n.º 1 — o imposto é devido e exigível no momento em que os bens são postos à disposição do adquirente ou em que os serviços são realizados; art. 8.º, n.º 1 — quando exista obrigação de emitir fatura (art. 29.º), a exigibilidade ocorre no momento da sua emissão, se respeitado o prazo legal, ou no termo desse prazo se não for respeitado, ou no momento do recebimento se o pagamento for anterior. A emissão de fatura é a regra geral de quase toda operação sujeita, o que faz de art. 8.º a derrogação que na prática rege a maioria das operações',
  tax_point_source_key          = 'civa-art8',
  posted_edit_policy            = 'reversal_only',
  posted_edit_policy_legal_reference = 'Decreto-Lei n.º 28/2019 — a série de faturação comunicada é sequencial e sem falhas; uma fatura processada por um programa certificado (Portaria n.º 195/2020, ATCUD incluído) não pode ser anulada, apenas corrigida por nota de crédito',
  posted_edit_policy_source_key = 'dl-28-2019',
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_obligation           = 'none',
  einvoice_legal_reference      = 'A 22 de setembro de 2026 não existe, em Portugal, uma obrigação legal de troca de faturas eletrónicas estruturadas entre empresas: o mecanismo nacional passa pelo programa de faturação certificado (Decreto-Lei n.º 28/2019), pelo ATCUD e pelo código QR em toda fatura (Portaria n.º 195/2020) e pela submissão mensal do ficheiro SAF-T (PT) — três obrigações de certificação e de comunicação ao Estado, não um formato de fatura estruturada trocado entre as partes; ver o README do pacote. A faturação eletrónica é obrigatória apenas na contratação pública (Decreto-Lei n.º 111-B/2017, que transpõe a Diretiva 2014/55/UE): desde abril de 2019 para as entidades adjudicantes, desde janeiro de 2021 para as grandes empresas, e até 31 de dezembro de 2026 para as micro, pequenas e médias empresas e para as restantes entidades adjudicantes (Lei n.º 73-A/2025, Orçamento do Estado para 2026), gerida pela ESPAP. O esquema 9946 (NIF português) identifica a empresa e o número de IVA, que em Portugal são o mesmo número',
  einvoice_source_key           = 'dl-111-b-2017',
  party_scheme                  = '9946',
  vat_scheme                    = '9946',
  bank_statement_formats        = array['camt.053']::text[],
  payment_formats               = array['pain.001']::text[],
  fiscal_year_default           = 'calendar'
 where country = 'PT';

insert into legal_mention_templates
  (country, code, applies_when, text, text_i18n, sequence, valid_from, valid_to, legal_reference)
values
  ('PT', 'reverse_charge', 'reverse_charge', 'IVA - autoliquidação', '{"en":"VAT - reverse charge"}'::jsonb, 10, date '1970-01-01', null, 'Código do IVA, art. 36.º, n.º 13, alínea j) — a fatura deve conter o motivo justificativo da não aplicação do imposto, sempre que for caso disso'),
  ('PT', 'intra_eu_goods', 'intra_eu_goods', 'IVA - isento artigo 14.º do RITI', '{"en":"VAT - exempt under article 14 of the RITI"}'::jsonb, 20, date '1970-01-01', null, 'RITI, art. 14.º — isenção das transmissões intracomunitárias de bens; Código do IVA, art. 36.º, n.º 13, alínea j)'),
  ('PT', 'intra_eu_services', 'intra_eu_services', 'IVA - autoliquidação', '{"en":"VAT - reverse charge"}'::jsonb, 30, date '1970-01-01', null, 'Código do IVA, art. 6.º, n.º 6, alínea a) — localização no Estado-membro do adquirente sujeito passivo; art. 36.º, n.º 13, alínea j)'),
  ('PT', 'export', 'export', 'IVA - isento artigo 14.º do CIVA', '{"en":"VAT - exempt under article 14 of the CIVA"}'::jsonb, 40, date '1970-01-01', null, 'Código do IVA, art. 14.º — isenções nas exportações; art. 36.º, n.º 13, alínea j)'),
  ('PT', 'exempt', 'exempt', 'IVA - isento artigo 9.º do CIVA', '{"en":"VAT - exempt under article 9 of the CIVA"}'::jsonb, 50, date '1970-01-01', null, 'Código do IVA, art. 9.º — isenções nas operações internas; art. 36.º, n.º 13, alínea j)')
on conflict (country, code) do update set
  applies_when    = excluded.applies_when,
  text            = excluded.text,
  text_i18n       = excluded.text_i18n,
  sequence        = excluded.sequence,
  valid_from      = excluded.valid_from,
  valid_to        = excluded.valid_to,
  legal_reference = excluded.legal_reference;
