-- Ekwo OS — Brasil: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/br at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build br`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Lei Complementar nº 123, de 14 de dezembro de 2006 — Estatuto Nacional da Microempresa e da Empresa de Pequeno Porte, texto compilado, com a redação dada pela Lei Complementar nº 155, de 2016 (arts. 3º, 18, 18-A, 21 e 27; Anexos I a V, vigência 1º de janeiro de 2018) (Presidência da República — Casa Civil, Subchefia para Assuntos Jurídicos)
--     https://www.planalto.gov.br/ccivil_03/leis/lcp/lcp123.htm
--   Perguntas e Respostas — Simples Nacional, atualizado parcialmente em 9 de outubro de 2026 (perguntas 5.3, 5.4.1, 6.4 e 6.8, com a base normativa dos arts. 22 e 40 da Resolução CGSN nº 140, de 2018) (Secretaria-Executiva do Comitê Gestor do Simples Nacional — Receita Federal do Brasil)
--     https://www8.receita.fazenda.gov.br/SimplesNacional/Arquivos/manual/PerguntaoSN.pdf
--   Portal do Simples Nacional — PGDAS-D 2018 (cálculo e declaração mensal) e geração do Documento de Arrecadação do Simples Nacional (DAS) (Comitê Gestor do Simples Nacional — Receita Federal do Brasil)
--     https://www8.receita.fazenda.gov.br/SimplesNacional/
--   Lei nº 10.406, de 10 de janeiro de 2002 — Código Civil, texto compilado (arts. 1.179 a 1.189, da escrituração) (Presidência da República — Casa Civil, Subchefia para Assuntos Jurídicos)
--     https://www.planalto.gov.br/ccivil_03/leis/2002/l10406compilada.htm
--   Lei nº 6.404, de 15 de dezembro de 1976 — Lei das Sociedades por Ações, texto compilado (arts. 178, 179 e 187: grupos do balanço patrimonial e discriminação da demonstração do resultado do exercício) (Presidência da República — Casa Civil, Subchefia para Assuntos Jurídicos)
--     https://www.planalto.gov.br/ccivil_03/leis/l6404consol.htm
--   Lei Complementar nº 214, de 16 de janeiro de 2025 — institui o IBS, a CBS e o Imposto Seletivo (art. 62: documentos fiscais eletrônicos recebidos, validados e autorizados; Nota Fiscal de Serviços Eletrônica de padrão nacional a partir de 1º de janeiro de 2026) (Presidência da República — Casa Civil, Subchefia para Assuntos Jurídicos)
--     https://www.planalto.gov.br/ccivil_03/leis/lcp/lcp214.htm
--   NF-e exige código completo do Mercosul-NCM a partir de 01/08/14 — Ajuste SINIEF 22/13: oito dígitos do código NCM, «00» admitido para itens de serviço ou sem produto (Governo de Goiás — Secretaria de Estado da Economia)
--     https://goias.gov.br/economia/nf-e-exige-codigo-completo-do-mercosul-ncm-a-partir-de-01-08-14/
--   Nota Fiscal de Serviço Eletrônica — padrão nacional: Emissor Nacional, Ambiente de Dados Nacional e legislação aplicável ao MEI (Receita Federal do Brasil — Sistema Nacional NFS-e)
--     https://www.gov.br/nfse/pt-br
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('BR', 'Brasil', '0.1.0', date '2026-10-20', '20261020090000', 'community', null, null, 'aa4aaa127d6cfa227f540a88087323d7c9c331908c8858bdba9afdc786b90be8', '[{"key":"lc-123","title":"Lei Complementar nº 123, de 14 de dezembro de 2006 — Estatuto Nacional da Microempresa e da Empresa de Pequeno Porte, texto compilado, com a redação dada pela Lei Complementar nº 155, de 2016 (arts. 3º, 18, 18-A, 21 e 27; Anexos I a V, vigência 1º de janeiro de 2018)","publisher":"Presidência da República — Casa Civil, Subchefia para Assuntos Jurídicos","url":"https://www.planalto.gov.br/ccivil_03/leis/lcp/lcp123.htm","consulted_on":"2026-10-20","kind":"law"},{"key":"cgsn-perguntas","title":"Perguntas e Respostas — Simples Nacional, atualizado parcialmente em 9 de outubro de 2026 (perguntas 5.3, 5.4.1, 6.4 e 6.8, com a base normativa dos arts. 22 e 40 da Resolução CGSN nº 140, de 2018)","publisher":"Secretaria-Executiva do Comitê Gestor do Simples Nacional — Receita Federal do Brasil","url":"https://www8.receita.fazenda.gov.br/SimplesNacional/Arquivos/manual/PerguntaoSN.pdf","consulted_on":"2026-10-20","kind":"guidance"},{"key":"portal-simples","title":"Portal do Simples Nacional — PGDAS-D 2018 (cálculo e declaração mensal) e geração do Documento de Arrecadação do Simples Nacional (DAS)","publisher":"Comitê Gestor do Simples Nacional — Receita Federal do Brasil","url":"https://www8.receita.fazenda.gov.br/SimplesNacional/","consulted_on":"2026-10-20","kind":"portal"},{"key":"codigo-civil","title":"Lei nº 10.406, de 10 de janeiro de 2002 — Código Civil, texto compilado (arts. 1.179 a 1.189, da escrituração)","publisher":"Presidência da República — Casa Civil, Subchefia para Assuntos Jurídicos","url":"https://www.planalto.gov.br/ccivil_03/leis/2002/l10406compilada.htm","consulted_on":"2026-10-20","kind":"law"},{"key":"lei-6404","title":"Lei nº 6.404, de 15 de dezembro de 1976 — Lei das Sociedades por Ações, texto compilado (arts. 178, 179 e 187: grupos do balanço patrimonial e discriminação da demonstração do resultado do exercício)","publisher":"Presidência da República — Casa Civil, Subchefia para Assuntos Jurídicos","url":"https://www.planalto.gov.br/ccivil_03/leis/l6404consol.htm","consulted_on":"2026-10-20","kind":"law"},{"key":"lc-214","title":"Lei Complementar nº 214, de 16 de janeiro de 2025 — institui o IBS, a CBS e o Imposto Seletivo (art. 62: documentos fiscais eletrônicos recebidos, validados e autorizados; Nota Fiscal de Serviços Eletrônica de padrão nacional a partir de 1º de janeiro de 2026)","publisher":"Presidência da República — Casa Civil, Subchefia para Assuntos Jurídicos","url":"https://www.planalto.gov.br/ccivil_03/leis/lcp/lcp214.htm","consulted_on":"2026-10-20","kind":"law"},{"key":"sefaz-go-ncm","title":"NF-e exige código completo do Mercosul-NCM a partir de 01/08/14 — Ajuste SINIEF 22/13: oito dígitos do código NCM, «00» admitido para itens de serviço ou sem produto","publisher":"Governo de Goiás — Secretaria de Estado da Economia","url":"https://goias.gov.br/economia/nf-e-exige-codigo-completo-do-mercosul-ncm-a-partir-de-01-08-14/","consulted_on":"2026-10-20","kind":"guidance"},{"key":"nfse-nacional","title":"Nota Fiscal de Serviço Eletrônica — padrão nacional: Emissor Nacional, Ambiente de Dados Nacional e legislação aplicável ao MEI","publisher":"Receita Federal do Brasil — Sistema Nacional NFS-e","url":"https://www.gov.br/nfse/pt-br","consulted_on":"2026-10-20","kind":"portal"}]'::jsonb)
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
  ('BR', 'default', 'Plano de contas de referência para microempresas e empresas de pequeno porte', '{"en":"Reference chart of accounts for micro and small companies"}'::jsonb, true, 'companies', array['BR-BP', 'BR-DRE']::text[], null, 'O Brasil não impõe um plano de contas numerado às microempresas e empresas de pequeno porte: o Código Civil, art. 1.179, obriga o empresário e a sociedade empresária a seguir um sistema de contabilidade com escrituração uniforme e a levantar anualmente o balanço patrimonial e o de resultado econômico, deixando o número e a espécie de livros a critério dos interessados (§ 1º); o art. 1.183, parágrafo único, admite um código de números próprio. A Lei Complementar nº 123, de 2006, art. 27, permite à empresa optante pelo Simples Nacional adotar contabilidade simplificada, e as Normas Brasileiras de Contabilidade do Conselho Federal de Contabilidade para microentidades e pequenas empresas fixam o conteúdo das demonstrações, não uma numeração. Este plano é original: quatro níveis separados por pontos, e cada grupo corresponde a uma linha do balanço patrimonial ou da demonstração do resultado na ordem dos arts. 178 e 187 da Lei nº 6.404, de 1976 — veja o README', 'codigo-civil')
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
  ('BR', 'default', '1', 'Ativo', '{"en":"Assets"}'::jsonb, 'asset_current', false, null, 10),
  ('BR', 'default', '1.1', 'Ativo circulante', '{"en":"Current assets"}'::jsonb, 'asset_current', false, '1', 20),
  ('BR', 'default', '1.1.1', 'Disponível', '{"en":"Cash and cash equivalents"}'::jsonb, 'asset_cash', false, '1.1', 30),
  ('BR', 'default', '1.1.1.01', 'Caixa', '{"en":"Cash on hand"}'::jsonb, 'asset_cash', false, '1.1.1', 40),
  ('BR', 'default', '1.1.1.02', 'Bancos conta movimento', '{"en":"Bank current accounts"}'::jsonb, 'asset_cash', false, '1.1.1', 50),
  ('BR', 'default', '1.1.1.03', 'Aplicações financeiras de liquidez imediata', '{"en":"Short-term investments readily convertible to cash"}'::jsonb, 'asset_cash', false, '1.1.1', 60),
  ('BR', 'default', '1.1.1.04', 'Conta de pagamento em instituição de pagamento', '{"en":"Payment account at a payment institution"}'::jsonb, 'asset_cash', false, '1.1.1', 70),
  ('BR', 'default', '1.1.2', 'Clientes', '{"en":"Trade receivables"}'::jsonb, 'asset_current', false, '1.1', 80),
  ('BR', 'default', '1.1.2.01', 'Clientes no país', '{"en":"Domestic customers"}'::jsonb, 'asset_receivable', true, '1.1.2', 90),
  ('BR', 'default', '1.1.2.02', 'Clientes no exterior', '{"en":"Foreign customers"}'::jsonb, 'asset_receivable', true, '1.1.2', 100),
  ('BR', 'default', '1.1.2.03', 'Duplicatas a receber', '{"en":"Trade bills receivable"}'::jsonb, 'asset_receivable', true, '1.1.2', 110),
  ('BR', 'default', '1.1.2.04', 'Recebíveis de cartões de crédito e débito', '{"en":"Card receivables"}'::jsonb, 'asset_current', false, '1.1.2', 120),
  ('BR', 'default', '1.1.2.09', '(-) Perdas estimadas com créditos de liquidação duvidosa', '{"en":"(-) Allowance for doubtful receivables"}'::jsonb, 'asset_current', false, '1.1.2', 130),
  ('BR', 'default', '1.1.3', 'Outros créditos', '{"en":"Other receivables"}'::jsonb, 'asset_current', false, '1.1', 140),
  ('BR', 'default', '1.1.3.01', 'Adiantamentos a fornecedores', '{"en":"Advances to suppliers"}'::jsonb, 'asset_current', false, '1.1.3', 150),
  ('BR', 'default', '1.1.3.02', 'Adiantamentos a empregados', '{"en":"Advances to employees"}'::jsonb, 'asset_current', false, '1.1.3', 160),
  ('BR', 'default', '1.1.3.03', 'Tributos a recuperar ou compensar', '{"en":"Taxes recoverable or to be offset"}'::jsonb, 'asset_current', true, '1.1.3', 170),
  ('BR', 'default', '1.1.3.04', 'Créditos com sócios', '{"en":"Receivables from partners"}'::jsonb, 'asset_current', false, '1.1.3', 180),
  ('BR', 'default', '1.1.3.05', 'Outros créditos a receber', '{"en":"Other amounts receivable"}'::jsonb, 'asset_current', false, '1.1.3', 190),
  ('BR', 'default', '1.1.4', 'Estoques', '{"en":"Inventories"}'::jsonb, 'asset_current', false, '1.1', 200),
  ('BR', 'default', '1.1.4.01', 'Mercadorias para revenda', '{"en":"Goods for resale"}'::jsonb, 'asset_current', false, '1.1.4', 210),
  ('BR', 'default', '1.1.4.02', 'Matérias-primas', '{"en":"Raw materials"}'::jsonb, 'asset_current', false, '1.1.4', 220),
  ('BR', 'default', '1.1.4.03', 'Produtos em elaboração', '{"en":"Work in progress"}'::jsonb, 'asset_current', false, '1.1.4', 230),
  ('BR', 'default', '1.1.4.04', 'Produtos acabados', '{"en":"Finished goods"}'::jsonb, 'asset_current', false, '1.1.4', 240),
  ('BR', 'default', '1.1.4.05', 'Materiais de consumo', '{"en":"Consumable supplies"}'::jsonb, 'asset_current', false, '1.1.4', 250),
  ('BR', 'default', '1.1.5', 'Despesas do exercício seguinte', '{"en":"Prepaid expenses"}'::jsonb, 'asset_prepayments', false, '1.1', 260),
  ('BR', 'default', '1.1.5.01', 'Seguros a apropriar', '{"en":"Prepaid insurance"}'::jsonb, 'asset_prepayments', false, '1.1.5', 270),
  ('BR', 'default', '1.1.5.02', 'Assinaturas e anuidades a apropriar', '{"en":"Prepaid subscriptions and annual fees"}'::jsonb, 'asset_prepayments', false, '1.1.5', 280),
  ('BR', 'default', '1.1.5.03', 'Outras despesas antecipadas', '{"en":"Other prepaid expenses"}'::jsonb, 'asset_prepayments', false, '1.1.5', 290),
  ('BR', 'default', '1.1.9', 'Contas transitórias', '{"en":"Clearing accounts"}'::jsonb, 'asset_current', false, '1.1', 300),
  ('BR', 'default', '1.1.9.01', 'Conta de espera', '{"en":"Suspense account"}'::jsonb, 'asset_current', false, '1.1.9', 310),
  ('BR', 'default', '1.1.9.02', 'Numerário em trânsito', '{"en":"Cash in transit"}'::jsonb, 'asset_current', false, '1.1.9', 320),
  ('BR', 'default', '1.2', 'Ativo não circulante', '{"en":"Non-current assets"}'::jsonb, 'asset_non_current', false, '1', 330),
  ('BR', 'default', '1.2.1', 'Realizável a longo prazo', '{"en":"Long-term receivables"}'::jsonb, 'asset_non_current', false, '1.2', 340),
  ('BR', 'default', '1.2.1.01', 'Créditos com sócios a longo prazo', '{"en":"Long-term receivables from partners"}'::jsonb, 'asset_non_current', false, '1.2.1', 350),
  ('BR', 'default', '1.2.1.02', 'Depósitos judiciais', '{"en":"Judicial deposits"}'::jsonb, 'asset_non_current', false, '1.2.1', 360),
  ('BR', 'default', '1.2.1.03', 'Depósitos e cauções', '{"en":"Deposits and guarantees paid"}'::jsonb, 'asset_non_current', false, '1.2.1', 370),
  ('BR', 'default', '1.2.1.04', 'Outros créditos a longo prazo', '{"en":"Other long-term receivables"}'::jsonb, 'asset_non_current', false, '1.2.1', 380),
  ('BR', 'default', '1.2.2', 'Investimentos', '{"en":"Investments"}'::jsonb, 'asset_non_current', false, '1.2', 390),
  ('BR', 'default', '1.2.2.01', 'Participações em outras sociedades', '{"en":"Interests in other companies"}'::jsonb, 'asset_non_current', false, '1.2.2', 400),
  ('BR', 'default', '1.2.2.02', 'Quotas de cooperativas de crédito', '{"en":"Shares in credit cooperatives"}'::jsonb, 'asset_non_current', false, '1.2.2', 410),
  ('BR', 'default', '1.2.2.03', 'Outros investimentos', '{"en":"Other investments"}'::jsonb, 'asset_non_current', false, '1.2.2', 420),
  ('BR', 'default', '1.2.3', 'Imobilizado', '{"en":"Property, plant and equipment"}'::jsonb, 'asset_fixed', false, '1.2', 430),
  ('BR', 'default', '1.2.3.01', 'Terrenos', '{"en":"Land"}'::jsonb, 'asset_fixed', false, '1.2.3', 440),
  ('BR', 'default', '1.2.3.02', 'Edificações', '{"en":"Buildings"}'::jsonb, 'asset_fixed', false, '1.2.3', 450),
  ('BR', 'default', '1.2.3.03', 'Máquinas e equipamentos', '{"en":"Machinery and equipment"}'::jsonb, 'asset_fixed', false, '1.2.3', 460),
  ('BR', 'default', '1.2.3.04', 'Móveis e utensílios', '{"en":"Furniture and fixtures"}'::jsonb, 'asset_fixed', false, '1.2.3', 470),
  ('BR', 'default', '1.2.3.05', 'Veículos', '{"en":"Vehicles"}'::jsonb, 'asset_fixed', false, '1.2.3', 480),
  ('BR', 'default', '1.2.3.06', 'Computadores e periféricos', '{"en":"Computers and peripherals"}'::jsonb, 'asset_fixed', false, '1.2.3', 490),
  ('BR', 'default', '1.2.3.07', 'Benfeitorias em imóveis de terceiros', '{"en":"Leasehold improvements"}'::jsonb, 'asset_fixed', false, '1.2.3', 500),
  ('BR', 'default', '1.2.3.08', 'Imobilizado em andamento', '{"en":"Assets under construction"}'::jsonb, 'asset_fixed', false, '1.2.3', 510),
  ('BR', 'default', '1.2.3.09', '(-) Depreciação acumulada', '{"en":"(-) Accumulated depreciation"}'::jsonb, 'asset_fixed', false, '1.2.3', 520),
  ('BR', 'default', '1.2.4', 'Intangível', '{"en":"Intangible assets"}'::jsonb, 'asset_non_current', false, '1.2', 530),
  ('BR', 'default', '1.2.4.01', 'Softwares', '{"en":"Software"}'::jsonb, 'asset_non_current', false, '1.2.4', 540),
  ('BR', 'default', '1.2.4.02', 'Marcas e patentes', '{"en":"Trademarks and patents"}'::jsonb, 'asset_non_current', false, '1.2.4', 550),
  ('BR', 'default', '1.2.4.03', 'Fundo de comércio adquirido', '{"en":"Acquired goodwill"}'::jsonb, 'asset_non_current', false, '1.2.4', 560),
  ('BR', 'default', '1.2.4.09', '(-) Amortização acumulada', '{"en":"(-) Accumulated amortisation"}'::jsonb, 'asset_non_current', false, '1.2.4', 570),
  ('BR', 'default', '2', 'Passivo', '{"en":"Liabilities"}'::jsonb, 'liability_current', false, null, 580),
  ('BR', 'default', '2.1', 'Passivo circulante', '{"en":"Current liabilities"}'::jsonb, 'liability_current', false, '2', 590),
  ('BR', 'default', '2.1.1', 'Fornecedores', '{"en":"Trade payables"}'::jsonb, 'liability_current', false, '2.1', 600),
  ('BR', 'default', '2.1.1.01', 'Fornecedores no país', '{"en":"Domestic suppliers"}'::jsonb, 'liability_payable', true, '2.1.1', 610),
  ('BR', 'default', '2.1.1.02', 'Fornecedores no exterior', '{"en":"Foreign suppliers"}'::jsonb, 'liability_payable', true, '2.1.1', 620),
  ('BR', 'default', '2.1.2', 'Obrigações trabalhistas', '{"en":"Payroll liabilities"}'::jsonb, 'liability_current', false, '2.1', 630),
  ('BR', 'default', '2.1.2.01', 'Salários a pagar', '{"en":"Wages payable"}'::jsonb, 'liability_current', false, '2.1.2', 640),
  ('BR', 'default', '2.1.2.02', 'Pró-labore a pagar', '{"en":"Partners'' remuneration payable"}'::jsonb, 'liability_current', false, '2.1.2', 650),
  ('BR', 'default', '2.1.2.03', 'Férias a pagar', '{"en":"Holiday pay payable"}'::jsonb, 'liability_current', false, '2.1.2', 660),
  ('BR', 'default', '2.1.2.04', 'Décimo terceiro salário a pagar', '{"en":"Thirteenth-month salary payable"}'::jsonb, 'liability_current', false, '2.1.2', 670),
  ('BR', 'default', '2.1.2.05', 'Rescisões a pagar', '{"en":"Termination payments payable"}'::jsonb, 'liability_current', false, '2.1.2', 680),
  ('BR', 'default', '2.1.3', 'Obrigações sociais', '{"en":"Social security liabilities"}'::jsonb, 'liability_current', false, '2.1', 690),
  ('BR', 'default', '2.1.3.01', 'INSS a recolher', '{"en":"Social security (INSS) payable"}'::jsonb, 'liability_current', false, '2.1.3', 700),
  ('BR', 'default', '2.1.3.02', 'FGTS a recolher', '{"en":"Severance fund (FGTS) payable"}'::jsonb, 'liability_current', false, '2.1.3', 710),
  ('BR', 'default', '2.1.4', 'Obrigações tributárias', '{"en":"Tax liabilities"}'::jsonb, 'liability_current', false, '2.1', 720),
  ('BR', 'default', '2.1.4.01', 'Simples Nacional a recolher', '{"en":"Simples Nacional payable"}'::jsonb, 'liability_current', true, '2.1.4', 730),
  ('BR', 'default', '2.1.4.02', 'ISS retido a recolher', '{"en":"Withheld municipal service tax (ISS) payable"}'::jsonb, 'liability_current', false, '2.1.4', 740),
  ('BR', 'default', '2.1.4.03', 'IRRF a recolher', '{"en":"Income tax withheld at source (IRRF) payable"}'::jsonb, 'liability_current', false, '2.1.4', 750),
  ('BR', 'default', '2.1.4.04', 'Parcelamentos tributários', '{"en":"Tax instalment arrangements"}'::jsonb, 'liability_current', false, '2.1.4', 760),
  ('BR', 'default', '2.1.4.05', 'Outros tributos a recolher', '{"en":"Other taxes payable"}'::jsonb, 'liability_current', false, '2.1.4', 770),
  ('BR', 'default', '2.1.5', 'Empréstimos e financiamentos', '{"en":"Loans and borrowings"}'::jsonb, 'liability_current', false, '2.1', 780),
  ('BR', 'default', '2.1.5.01', 'Empréstimos bancários', '{"en":"Bank loans"}'::jsonb, 'liability_current', false, '2.1.5', 790),
  ('BR', 'default', '2.1.5.02', 'Financiamentos', '{"en":"Financing"}'::jsonb, 'liability_current', false, '2.1.5', 800),
  ('BR', 'default', '2.1.5.03', 'Cartão de crédito empresarial', '{"en":"Company credit card"}'::jsonb, 'liability_credit_card', false, '2.1.5', 810),
  ('BR', 'default', '2.1.6', 'Outras obrigações', '{"en":"Other current liabilities"}'::jsonb, 'liability_current', false, '2.1', 820),
  ('BR', 'default', '2.1.6.01', 'Adiantamentos de clientes', '{"en":"Advances from customers"}'::jsonb, 'liability_current', false, '2.1.6', 830),
  ('BR', 'default', '2.1.6.02', 'Lucros a distribuir', '{"en":"Profits to be distributed"}'::jsonb, 'liability_current', false, '2.1.6', 840),
  ('BR', 'default', '2.1.6.03', 'Aluguéis a pagar', '{"en":"Rent payable"}'::jsonb, 'liability_current', false, '2.1.6', 850),
  ('BR', 'default', '2.1.6.04', 'Contas a pagar', '{"en":"Other accounts payable"}'::jsonb, 'liability_current', false, '2.1.6', 860),
  ('BR', 'default', '2.2', 'Passivo não circulante', '{"en":"Non-current liabilities"}'::jsonb, 'liability_non_current', false, '2', 870),
  ('BR', 'default', '2.2.1', 'Empréstimos e financiamentos a longo prazo', '{"en":"Long-term loans and borrowings"}'::jsonb, 'liability_non_current', false, '2.2', 880),
  ('BR', 'default', '2.2.1.01', 'Empréstimos bancários a longo prazo', '{"en":"Long-term bank loans"}'::jsonb, 'liability_non_current', false, '2.2.1', 890),
  ('BR', 'default', '2.2.1.02', 'Financiamentos a longo prazo', '{"en":"Long-term financing"}'::jsonb, 'liability_non_current', false, '2.2.1', 900),
  ('BR', 'default', '2.2.2', 'Mútuos de sócios', '{"en":"Loans from partners"}'::jsonb, 'liability_non_current', false, '2.2', 910),
  ('BR', 'default', '2.2.2.01', 'Mútuos de sócios a pagar', '{"en":"Loans from partners payable"}'::jsonb, 'liability_non_current', false, '2.2.2', 920),
  ('BR', 'default', '2.2.3', 'Parcelamentos tributários a longo prazo', '{"en":"Long-term tax instalment arrangements"}'::jsonb, 'liability_non_current', false, '2.2', 930),
  ('BR', 'default', '2.2.3.01', 'Parcelamento do Simples Nacional', '{"en":"Simples Nacional instalment arrangement"}'::jsonb, 'liability_non_current', false, '2.2.3', 940),
  ('BR', 'default', '2.2.9', 'Outras obrigações a longo prazo', '{"en":"Other long-term liabilities"}'::jsonb, 'liability_non_current', false, '2.2', 950),
  ('BR', 'default', '2.2.9.01', 'Outras contas a pagar a longo prazo', '{"en":"Other long-term accounts payable"}'::jsonb, 'liability_non_current', false, '2.2.9', 960),
  ('BR', 'default', '3', 'Patrimônio líquido', '{"en":"Equity"}'::jsonb, 'equity', false, null, 970),
  ('BR', 'default', '3.1', 'Capital social', '{"en":"Share capital"}'::jsonb, 'equity', false, '3', 980),
  ('BR', 'default', '3.1.1', 'Capital subscrito', '{"en":"Subscribed capital"}'::jsonb, 'equity', false, '3.1', 990),
  ('BR', 'default', '3.1.2', '(-) Capital a integralizar', '{"en":"(-) Capital not yet paid in"}'::jsonb, 'equity', false, '3.1', 1000),
  ('BR', 'default', '3.2', 'Reservas de capital', '{"en":"Capital reserves"}'::jsonb, 'equity', false, '3', 1010),
  ('BR', 'default', '3.2.1', 'Reservas de capital', '{"en":"Capital reserves"}'::jsonb, 'equity', false, '3.2', 1020),
  ('BR', 'default', '3.3', 'Reservas de lucros', '{"en":"Profit reserves"}'::jsonb, 'equity', false, '3', 1030),
  ('BR', 'default', '3.3.1', 'Reserva legal', '{"en":"Legal reserve"}'::jsonb, 'equity', false, '3.3', 1040),
  ('BR', 'default', '3.3.2', 'Outras reservas de lucros', '{"en":"Other profit reserves"}'::jsonb, 'equity', false, '3.3', 1050),
  ('BR', 'default', '3.4', 'Lucros ou prejuízos acumulados', '{"en":"Retained earnings or accumulated losses"}'::jsonb, 'equity_retained', false, '3', 1060),
  ('BR', 'default', '3.4.1', 'Lucros acumulados', '{"en":"Retained earnings"}'::jsonb, 'equity_retained', false, '3.4', 1070),
  ('BR', 'default', '3.4.2', '(-) Prejuízos acumulados', '{"en":"(-) Accumulated losses"}'::jsonb, 'equity_retained', false, '3.4', 1080),
  ('BR', 'default', '3.5', 'Resultado do exercício', '{"en":"Result for the year"}'::jsonb, 'equity', false, '3', 1090),
  ('BR', 'default', '3.5.1', 'Lucro do exercício', '{"en":"Profit for the year"}'::jsonb, 'equity', false, '3.5', 1100),
  ('BR', 'default', '3.5.2', '(-) Prejuízo do exercício', '{"en":"(-) Loss for the year"}'::jsonb, 'equity', false, '3.5', 1110),
  ('BR', 'default', '4', 'Receitas', '{"en":"Income"}'::jsonb, 'income', false, null, 1120),
  ('BR', 'default', '4.1', 'Receita bruta', '{"en":"Gross revenue"}'::jsonb, 'income', false, '4', 1130),
  ('BR', 'default', '4.1.1', 'Venda de mercadorias', '{"en":"Sales of goods for resale"}'::jsonb, 'income', false, '4.1', 1140),
  ('BR', 'default', '4.1.2', 'Venda de produtos industrializados', '{"en":"Sales of manufactured goods"}'::jsonb, 'income', false, '4.1', 1150),
  ('BR', 'default', '4.1.3', 'Prestação de serviços', '{"en":"Services rendered"}'::jsonb, 'income', false, '4.1', 1160),
  ('BR', 'default', '4.1.4', 'Locação de bens móveis', '{"en":"Rental of movable property"}'::jsonb, 'income', false, '4.1', 1170),
  ('BR', 'default', '4.1.5', 'Exportação de mercadorias', '{"en":"Exports of goods"}'::jsonb, 'income', false, '4.1', 1180),
  ('BR', 'default', '4.1.6', 'Exportação de serviços', '{"en":"Exports of services"}'::jsonb, 'income', false, '4.1', 1190),
  ('BR', 'default', '4.2', 'Deduções da receita bruta', '{"en":"Deductions from gross revenue"}'::jsonb, 'income', false, '4', 1200),
  ('BR', 'default', '4.2.1', '(-) Devoluções de vendas', '{"en":"(-) Sales returns"}'::jsonb, 'income', false, '4.2', 1210),
  ('BR', 'default', '4.2.2', '(-) Cancelamentos de serviços', '{"en":"(-) Cancelled services"}'::jsonb, 'income', false, '4.2', 1220),
  ('BR', 'default', '4.2.3', '(-) Descontos incondicionais concedidos', '{"en":"(-) Unconditional discounts granted"}'::jsonb, 'income', false, '4.2', 1230),
  ('BR', 'default', '4.3', 'Receitas financeiras', '{"en":"Finance income"}'::jsonb, 'income_other', false, '4', 1240),
  ('BR', 'default', '4.3.1', 'Rendimentos de aplicações financeiras', '{"en":"Investment income"}'::jsonb, 'income_other', false, '4.3', 1250),
  ('BR', 'default', '4.3.2', 'Juros ativos', '{"en":"Interest received"}'::jsonb, 'income_other', false, '4.3', 1260),
  ('BR', 'default', '4.3.3', 'Descontos obtidos', '{"en":"Discounts received"}'::jsonb, 'income_other', false, '4.3', 1270),
  ('BR', 'default', '4.3.4', 'Variação cambial ativa', '{"en":"Foreign exchange gains"}'::jsonb, 'income_other', false, '4.3', 1280),
  ('BR', 'default', '4.4', 'Outras receitas', '{"en":"Other income"}'::jsonb, 'income_other', false, '4', 1290),
  ('BR', 'default', '4.4.1', 'Ganho na alienação de bens do ativo não circulante', '{"en":"Gain on disposal of non-current assets"}'::jsonb, 'income_other', false, '4.4', 1300),
  ('BR', 'default', '4.4.2', 'Recuperação de despesas', '{"en":"Recovery of expenses"}'::jsonb, 'income_other', false, '4.4', 1310),
  ('BR', 'default', '4.4.9', 'Outras receitas diversas', '{"en":"Sundry other income"}'::jsonb, 'income_other', false, '4.4', 1320),
  ('BR', 'default', '5', 'Custos', '{"en":"Costs"}'::jsonb, 'expense_direct_cost', false, null, 1330),
  ('BR', 'default', '5.1', 'Custo das vendas e dos serviços', '{"en":"Cost of sales and services"}'::jsonb, 'expense_direct_cost', false, '5', 1340),
  ('BR', 'default', '5.1.1', 'Custo das mercadorias vendidas', '{"en":"Cost of goods sold"}'::jsonb, 'expense_direct_cost', false, '5.1', 1350),
  ('BR', 'default', '5.1.2', 'Custo dos produtos vendidos', '{"en":"Cost of manufactured goods sold"}'::jsonb, 'expense_direct_cost', false, '5.1', 1360),
  ('BR', 'default', '5.1.3', 'Custo dos serviços prestados', '{"en":"Cost of services rendered"}'::jsonb, 'expense_direct_cost', false, '5.1', 1370),
  ('BR', 'default', '5.1.4', 'Serviços de terceiros aplicados', '{"en":"Subcontracted services"}'::jsonb, 'expense_direct_cost', false, '5.1', 1380),
  ('BR', 'default', '5.1.5', 'Fretes e seguros sobre compras', '{"en":"Freight and insurance on purchases"}'::jsonb, 'expense_direct_cost', false, '5.1', 1390),
  ('BR', 'default', '6', 'Despesas', '{"en":"Expenses"}'::jsonb, 'expense', false, null, 1400),
  ('BR', 'default', '6.1', 'Tributos sobre a receita', '{"en":"Taxes on revenue"}'::jsonb, 'expense', false, '6', 1410),
  ('BR', 'default', '6.1.1', 'Simples Nacional (DAS)', '{"en":"Simples Nacional (DAS)"}'::jsonb, 'expense', false, '6.1', 1420),
  ('BR', 'default', '6.2', 'Despesas com pessoal', '{"en":"Staff costs"}'::jsonb, 'expense', false, '6', 1430),
  ('BR', 'default', '6.2.1', 'Salários', '{"en":"Wages and salaries"}'::jsonb, 'expense', false, '6.2', 1440),
  ('BR', 'default', '6.2.2', 'Pró-labore', '{"en":"Partners'' remuneration"}'::jsonb, 'expense', false, '6.2', 1450),
  ('BR', 'default', '6.2.3', 'Férias', '{"en":"Holiday pay"}'::jsonb, 'expense', false, '6.2', 1460),
  ('BR', 'default', '6.2.4', 'Décimo terceiro salário', '{"en":"Thirteenth-month salary"}'::jsonb, 'expense', false, '6.2', 1470),
  ('BR', 'default', '6.2.5', 'INSS patronal', '{"en":"Employer social security (INSS)"}'::jsonb, 'expense', false, '6.2', 1480),
  ('BR', 'default', '6.2.6', 'FGTS', '{"en":"Severance fund (FGTS)"}'::jsonb, 'expense', false, '6.2', 1490),
  ('BR', 'default', '6.2.7', 'Vale-transporte', '{"en":"Transport allowance"}'::jsonb, 'expense', false, '6.2', 1500),
  ('BR', 'default', '6.2.8', 'Vale-refeição e alimentação', '{"en":"Meal allowance"}'::jsonb, 'expense', false, '6.2', 1510),
  ('BR', 'default', '6.2.9', 'Assistência médica e outros benefícios', '{"en":"Health plan and other benefits"}'::jsonb, 'expense', false, '6.2', 1520),
  ('BR', 'default', '6.3', 'Despesas administrativas', '{"en":"Administrative expenses"}'::jsonb, 'expense', false, '6', 1530),
  ('BR', 'default', '6.3.1', 'Aluguéis', '{"en":"Rent"}'::jsonb, 'expense', false, '6.3', 1540),
  ('BR', 'default', '6.3.2', 'Condomínio', '{"en":"Building service charges"}'::jsonb, 'expense', false, '6.3', 1550),
  ('BR', 'default', '6.3.3', 'Energia elétrica', '{"en":"Electricity"}'::jsonb, 'expense', false, '6.3', 1560),
  ('BR', 'default', '6.3.4', 'Água e esgoto', '{"en":"Water and sewerage"}'::jsonb, 'expense', false, '6.3', 1570),
  ('BR', 'default', '6.3.5', 'Telefone e internet', '{"en":"Telephone and internet"}'::jsonb, 'expense', false, '6.3', 1580),
  ('BR', 'default', '6.3.6', 'Material de escritório', '{"en":"Office supplies"}'::jsonb, 'expense', false, '6.3', 1590),
  ('BR', 'default', '6.3.7', 'Serviços contábeis', '{"en":"Accounting services"}'::jsonb, 'expense', false, '6.3', 1600),
  ('BR', 'default', '6.3.8', 'Serviços advocatícios e de consultoria', '{"en":"Legal and consulting services"}'::jsonb, 'expense', false, '6.3', 1610),
  ('BR', 'default', '6.3.9', 'Softwares e assinaturas', '{"en":"Software and subscriptions"}'::jsonb, 'expense', false, '6.3', 1620),
  ('BR', 'default', '6.4', 'Outras despesas administrativas', '{"en":"Other administrative expenses"}'::jsonb, 'expense', false, '6', 1630),
  ('BR', 'default', '6.4.1', 'Seguros', '{"en":"Insurance"}'::jsonb, 'expense', false, '6.4', 1640),
  ('BR', 'default', '6.4.2', 'Manutenção e reparos', '{"en":"Maintenance and repairs"}'::jsonb, 'expense', false, '6.4', 1650),
  ('BR', 'default', '6.4.3', 'Viagens e estadias', '{"en":"Travel and accommodation"}'::jsonb, 'expense', false, '6.4', 1660),
  ('BR', 'default', '6.4.4', 'Taxas, licenças e alvarás', '{"en":"Fees, licences and permits"}'::jsonb, 'expense', false, '6.4', 1670),
  ('BR', 'default', '6.4.5', 'IPTU e IPVA', '{"en":"Property and vehicle taxes (IPTU, IPVA)"}'::jsonb, 'expense', false, '6.4', 1680),
  ('BR', 'default', '6.4.6', 'Outros tributos e contribuições fora do Simples Nacional', '{"en":"Other taxes and contributions outside Simples Nacional"}'::jsonb, 'expense', false, '6.4', 1690),
  ('BR', 'default', '6.4.7', 'Depreciação', '{"en":"Depreciation"}'::jsonb, 'expense_depreciation', false, '6.4', 1700),
  ('BR', 'default', '6.4.8', 'Amortização', '{"en":"Amortisation"}'::jsonb, 'expense_depreciation', false, '6.4', 1710),
  ('BR', 'default', '6.4.9', 'Despesas diversas', '{"en":"Sundry expenses"}'::jsonb, 'expense', false, '6.4', 1720),
  ('BR', 'default', '6.5', 'Despesas comerciais', '{"en":"Selling expenses"}'::jsonb, 'expense', false, '6', 1730),
  ('BR', 'default', '6.5.1', 'Propaganda e publicidade', '{"en":"Advertising"}'::jsonb, 'expense', false, '6.5', 1740),
  ('BR', 'default', '6.5.2', 'Comissões sobre vendas', '{"en":"Sales commissions"}'::jsonb, 'expense', false, '6.5', 1750),
  ('BR', 'default', '6.5.3', 'Fretes sobre vendas', '{"en":"Freight on sales"}'::jsonb, 'expense', false, '6.5', 1760),
  ('BR', 'default', '6.5.4', 'Tarifas de cartões e de plataformas de venda', '{"en":"Card and marketplace fees"}'::jsonb, 'expense', false, '6.5', 1770),
  ('BR', 'default', '6.5.5', 'Perdas com créditos incobráveis', '{"en":"Bad debts"}'::jsonb, 'expense', false, '6.5', 1780),
  ('BR', 'default', '6.6', 'Despesas financeiras', '{"en":"Finance costs"}'::jsonb, 'expense', false, '6', 1790),
  ('BR', 'default', '6.6.1', 'Juros passivos', '{"en":"Interest paid"}'::jsonb, 'expense', false, '6.6', 1800),
  ('BR', 'default', '6.6.2', 'Tarifas bancárias', '{"en":"Bank charges"}'::jsonb, 'expense', false, '6.6', 1810),
  ('BR', 'default', '6.6.3', 'Multas e juros sobre tributos', '{"en":"Penalties and interest on taxes"}'::jsonb, 'expense', false, '6.6', 1820),
  ('BR', 'default', '6.6.4', 'IOF', '{"en":"Tax on financial transactions (IOF)"}'::jsonb, 'expense', false, '6.6', 1830),
  ('BR', 'default', '6.6.5', 'Descontos concedidos', '{"en":"Discounts allowed"}'::jsonb, 'expense', false, '6.6', 1840),
  ('BR', 'default', '6.6.6', 'Variação cambial passiva', '{"en":"Foreign exchange losses"}'::jsonb, 'expense', false, '6.6', 1850),
  ('BR', 'default', '6.7', 'Outras despesas', '{"en":"Other expenses"}'::jsonb, 'expense', false, '6', 1860),
  ('BR', 'default', '6.7.1', 'Perda na alienação de bens do ativo não circulante', '{"en":"Loss on disposal of non-current assets"}'::jsonb, 'expense', false, '6.7', 1870),
  ('BR', 'default', '6.7.2', 'Diferenças de arredondamento', '{"en":"Rounding differences"}'::jsonb, 'expense', false, '6.7', 1880),
  ('BR', 'default', '6.7.9', 'Outras despesas diversas', '{"en":"Sundry other expenses"}'::jsonb, 'expense', false, '6.7', 1890)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('BR', 'ABE', 'Lançamento de abertura', '{"en":"Opening entry"}'::jsonb, 'opening', 60),
  ('BR', 'BCO', 'Bancos', '{"en":"Banks"}'::jsonb, 'bank', 30),
  ('BR', 'COM', 'Compras', '{"en":"Purchases"}'::jsonb, 'purchase', 20),
  ('BR', 'CX', 'Caixa', '{"en":"Cash"}'::jsonb, 'cash', 40),
  ('BR', 'DIA', 'Diário geral', '{"en":"General journal"}'::jsonb, 'general', 50),
  ('BR', 'VEN', 'Vendas', '{"en":"Sales"}'::jsonb, 'sales', 10)
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
  ('BR', 'BR-SN-COMPRA', 'Compra de optante pelo Simples Nacional — sem crédito de tributos', '{"en":"Purchase by a Simples Nacional company — no tax credit"}'::jsonb, 'Toda compra de uma optante pelo Simples Nacional, no país ou do exterior: nenhum tributo a recuperar na linha', 'percent', 0, 'purchase', 'not_subject', date '2018-01-01', null, 'O lado das compras de BR-SN-VENDA: uma optante pelo Simples Nacional não se apropria de crédito dos tributos que o fornecedor recolheu, porque os seus próprios tributos incidem sobre a receita bruta e não sobre o valor agregado (Lei Complementar nº 123, de 2006, art. 23, caput: as optantes não farão jus à apropriação nem transferirão créditos relativos a impostos ou contribuições abrangidos pelo Simples Nacional). O valor pago ao fornecedor, tributos incluídos, é custo ou despesa. Os tributos sobre a importação de serviços, que ficam fora do DAS, não têm código neste pacote — veja o README', 'O', null, 20, 'other', true, '{}'::tax_condition[], null, false, false, null, 'lc-123', null, null, null, null),
  ('BR', 'BR-SN-VENDA', 'Venda de optante pelo Simples Nacional — tributos no DAS', '{"en":"Sale by a Simples Nacional company — taxes in the DAS"}'::jsonb, 'Toda venda de mercadorias ou prestação de serviços de uma optante pelo Simples Nacional, no país ou para o exterior: nenhum tributo na linha, o DAS do mês o substitui', 'percent', 0, 'sale', 'not_subject', date '2018-01-01', null, 'Lei Complementar nº 123, de 2006, art. 13 — a optante pelo Simples Nacional recolhe mensalmente, num único documento de arrecadação (o DAS), o IRPJ, o IPI, a CSLL, a Cofins, o PIS/Pasep, a CPP, o ICMS e o ISS, calculados sobre a receita bruta do mês pela alíquota efetiva do art. 18 — veja turnover_tax.json. Nenhum desses tributos é destacado, calculado ou recuperado linha a linha: este código existe para que cada linha de venda carregue um código que o motor contabiliza sem imposto, e diz que o imposto da operação está no DAS do mês, não na nota. Não é uma isenção nem uma não incidência dos tributos substituídos. Os casos em que um tributo fica fora do DAS (ICMS por substituição tributária, diferencial de alíquotas, ISS fixo, tributos acima do sublimite) não têm código neste pacote — veja o README', 'O', null, 10, 'other', true, '{}'::tax_condition[], null, false, false, null, 'lc-123', null, null, null, null)
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
    ('BR-SN-COMPRA', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('BR-SN-COMPRA', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('BR-SN-VENDA', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('BR-SN-VENDA', 'credit_note', 'base', 100, null, null, null, 100, null, 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'BR' and t.code = v.tax_code
on conflict (tax_template_id, document_kind, posting_type, sequence) do update set
  factor_percent     = excluded.factor_percent,
  account_code       = excluded.account_code,
  declaration_box    = excluded.declaration_box,
  declaration_boxes  = excluded.declaration_boxes,
  box_factor_percent = excluded.box_factor_percent,
  report_code        = excluded.report_code;

delete from classification_schemes where country = 'BR' and attribute <> all (array['ncm']::text[]);

insert into classification_schemes (country, attribute, name, pattern, legal_reference, source_key, sequence) values
  ('BR', 'ncm', 'Nomenclatura Comum do Mercosul (NCM)', '^([0-9]{8}|00)$', 'Ajuste SINIEF 22/13, celebrado no âmbito do Conselho Nacional de Política Fazendária e aplicável em todas as unidades federadas: desde 1º de agosto de 2014 a Nota Fiscal Eletrônica (modelo 55) informa, em cada item, o código completo da Nomenclatura Comum do Mercosul, com oito dígitos — os seis do Sistema Harmonizado e dois do Mercosul —, e um código de dois dígitos (o capítulo) é rejeitado; o código «00» continua admitido para itens de serviço ou sem produto. O padrão confere a forma do código, nunca a sua existência na tabela vigente: a classificação é do emitente', 'sefaz-go-ncm', 10)
on conflict (country, attribute) do update set
  name            = excluded.name,
  pattern         = excluded.pattern,
  legal_reference = excluded.legal_reference,
  source_key      = excluded.source_key,
  sequence        = excluded.sequence;

-- The regimes where a tax on turnover replaces VAT (turnover_tax.json, decision 0080).
delete from turnover_tax_regimes where country = 'BR' and code <> all (array['BR-SN-I', 'BR-SN-II', 'BR-SN-III', 'BR-SN-IV', 'BR-SN-V']);
delete from turnover_tax_brackets where country = 'BR';

insert into tax_report_templates
  (country, code, name, periods, period_default, valid_from, legal_reference, is_periodic_return,
   deadline_rule, deadline_day, deadline_reference, deadline_source_key)
values
  ('BR', 'BR-PGDAS-D', 'PGDAS-D — Programa Gerador do Documento de Arrecadação do Simples Nacional, Declaratório', array['month']::declaration_period[], 'month'::declaration_period, date '2018-01-01', 'Lei Complementar nº 123, de 2006, art. 18, § 15-A, II; Perguntas e Respostas do Simples Nacional, pergunta 6.4 — a apuração é feita e transmitida mensalmente no PGDAS-D 2018 (períodos de apuração a partir de janeiro de 2018), ainda que sem receita no mês, e o DAS só é gerado depois de transmitida a apuração (pergunta 6.7)', false, 'day_of_month_after_period'::filing_deadline_rule, 20, 'Resolução CGSN nº 140, de 2018, art. 40, segundo a pergunta 6.8 do Perguntas e Respostas do Simples Nacional — o prazo para recolher os tributos apurados termina no dia 20 do mês subsequente àquele em que a receita bruta foi auferida; quando não há expediente bancário no dia 20, o prazo é prorrogado para o primeiro dia útil seguinte. A pergunta 6.4 fixa no mesmo dia a transmissão do PGDAS-D', 'cgsn-perguntas')
on conflict (country, code) do update set
  name                = excluded.name,
  periods             = excluded.periods,
  period_default      = excluded.period_default,
  valid_from          = excluded.valid_from,
  legal_reference     = excluded.legal_reference,
  is_periodic_return  = excluded.is_periodic_return,
  deadline_rule       = excluded.deadline_rule,
  deadline_day        = excluded.deadline_day,
  deadline_reference  = excluded.deadline_reference,
  deadline_source_key = excluded.deadline_source_key;

insert into turnover_tax_regimes
  (country, code, name, replaces, report_code, window_months, window_includes_period, short_window,
   expense_account_code, legal_reference, source_key, sequence)
values
  ('BR', 'BR-SN-I', 'Simples Nacional — Anexo I (Comércio)', array['vat', 'sales_tax']::tax_kind[], 'BR-PGDAS-D', 12, false, 'annualise', '6.1.1', 'Lei Complementar nº 123, de 2006, art. 18, caput e §§ 1º e 1º-A, redação da Lei Complementar nº 155, de 2016 — o valor devido mensalmente é a receita bruta do mês vezes a alíquota efetiva (RBT12 × Aliq − PD) / RBT12, sendo RBT12 a receita bruta acumulada nos doze meses anteriores ao período de apuração, Aliq a alíquota nominal e PD a parcela a deduzir do Anexo I, que se aplica à revenda de mercadorias (art. 18, § 4º, I). O DAS reúne num único recolhimento IRPJ, CSLL, Cofins, PIS/Pasep, CPP, IPI, ICMS e ISS (art. 13), e por isso nenhuma linha de documento de uma optante carrega um imposto sobre o consumo. No ano de início de atividade, a RBT12 é proporcionalizada: no primeiro mês, a receita do próprio mês vezes doze; nos onze meses seguintes, a média aritmética dos meses anteriores vezes doze (pergunta 5.4.1 do Perguntas e Respostas do Simples Nacional, «regra até 2026») — o que `short: annualise` faz', 'lc-123', 10)
on conflict (country, code) do update set
  name                   = excluded.name,
  replaces               = excluded.replaces,
  report_code            = excluded.report_code,
  window_months          = excluded.window_months,
  window_includes_period = excluded.window_includes_period,
  short_window           = excluded.short_window,
  expense_account_code   = excluded.expense_account_code,
  legal_reference        = excluded.legal_reference,
  source_key             = excluded.source_key,
  sequence               = excluded.sequence;

insert into turnover_tax_brackets
  (country, regime_code, valid_from, valid_to, sequence, up_to, nominal_rate, deduction, legal_reference, source_key)
values
  ('BR', 'BR-SN-I', date '2018-01-01', null, 10, 180000.00, 4, 0, 'Lei Complementar nº 123, de 2006, Anexo I, redação da Lei Complementar nº 155, de 2016 (vigência 1º de janeiro de 2018), 1ª faixa: receita bruta em 12 meses até 180.000,00, alíquota nominal 4 %, valor a deduzir nenhum', 'lc-123'),
  ('BR', 'BR-SN-I', date '2018-01-01', null, 20, 360000.00, 7.3, 5940.00, 'Lei Complementar nº 123, de 2006, Anexo I, redação da Lei Complementar nº 155, de 2016 (vigência 1º de janeiro de 2018), 2ª faixa: receita bruta em 12 meses de 180.000,01 a 360.000,00, alíquota nominal 7,3 %, valor a deduzir 5.940,00', 'lc-123'),
  ('BR', 'BR-SN-I', date '2018-01-01', null, 30, 720000.00, 9.5, 13860.00, 'Lei Complementar nº 123, de 2006, Anexo I, redação da Lei Complementar nº 155, de 2016 (vigência 1º de janeiro de 2018), 3ª faixa: receita bruta em 12 meses de 360.000,01 a 720.000,00, alíquota nominal 9,5 %, valor a deduzir 13.860,00', 'lc-123'),
  ('BR', 'BR-SN-I', date '2018-01-01', null, 40, 1800000.00, 10.7, 22500.00, 'Lei Complementar nº 123, de 2006, Anexo I, redação da Lei Complementar nº 155, de 2016 (vigência 1º de janeiro de 2018), 4ª faixa: receita bruta em 12 meses de 720.000,01 a 1.800.000,00, alíquota nominal 10,7 %, valor a deduzir 22.500,00', 'lc-123'),
  ('BR', 'BR-SN-I', date '2018-01-01', null, 50, 3600000.00, 14.3, 87300.00, 'Lei Complementar nº 123, de 2006, Anexo I, redação da Lei Complementar nº 155, de 2016 (vigência 1º de janeiro de 2018), 5ª faixa: receita bruta em 12 meses de 1.800.000,01 a 3.600.000,00, alíquota nominal 14,3 %, valor a deduzir 87.300,00', 'lc-123'),
  ('BR', 'BR-SN-I', date '2018-01-01', null, 60, null, 19, 378000.00, 'Lei Complementar nº 123, de 2006, Anexo I, redação da Lei Complementar nº 155, de 2016 (vigência 1º de janeiro de 2018), 6ª faixa: receita bruta em 12 meses de 3.600.000,01 a 4.800.000,00, alíquota nominal 19 %, valor a deduzir 378.000,00. A tabela termina em 4.800.000,00, o limite da empresa de pequeno porte (art. 3º, II); a faixa fica aberta porque o formato de Ekwo exige uma última faixa sem limite, e a exclusão do regime acima desse limite não é modelada — veja o README', 'lc-123');

insert into tax_report_templates
  (country, code, name, periods, period_default, valid_from, legal_reference, is_periodic_return,
   deadline_rule, deadline_day, deadline_reference, deadline_source_key)
values
  ('BR', 'BR-PGDAS-D', 'PGDAS-D — Programa Gerador do Documento de Arrecadação do Simples Nacional, Declaratório', array['month']::declaration_period[], 'month'::declaration_period, date '2018-01-01', 'Lei Complementar nº 123, de 2006, art. 18, § 15-A, II; Perguntas e Respostas do Simples Nacional, pergunta 6.4 — a apuração é feita e transmitida mensalmente no PGDAS-D 2018 (períodos de apuração a partir de janeiro de 2018), ainda que sem receita no mês, e o DAS só é gerado depois de transmitida a apuração (pergunta 6.7)', false, 'day_of_month_after_period'::filing_deadline_rule, 20, 'Resolução CGSN nº 140, de 2018, art. 40, segundo a pergunta 6.8 do Perguntas e Respostas do Simples Nacional — o prazo para recolher os tributos apurados termina no dia 20 do mês subsequente àquele em que a receita bruta foi auferida; quando não há expediente bancário no dia 20, o prazo é prorrogado para o primeiro dia útil seguinte. A pergunta 6.4 fixa no mesmo dia a transmissão do PGDAS-D', 'cgsn-perguntas')
on conflict (country, code) do update set
  name                = excluded.name,
  periods             = excluded.periods,
  period_default      = excluded.period_default,
  valid_from          = excluded.valid_from,
  legal_reference     = excluded.legal_reference,
  is_periodic_return  = excluded.is_periodic_return,
  deadline_rule       = excluded.deadline_rule,
  deadline_day        = excluded.deadline_day,
  deadline_reference  = excluded.deadline_reference,
  deadline_source_key = excluded.deadline_source_key;

insert into turnover_tax_regimes
  (country, code, name, replaces, report_code, window_months, window_includes_period, short_window,
   expense_account_code, legal_reference, source_key, sequence)
values
  ('BR', 'BR-SN-II', 'Simples Nacional — Anexo II (Indústria)', array['vat', 'sales_tax']::tax_kind[], 'BR-PGDAS-D', 12, false, 'annualise', '6.1.1', 'Lei Complementar nº 123, de 2006, art. 18, caput e §§ 1º e 1º-A, redação da Lei Complementar nº 155, de 2016 — o valor devido mensalmente é a receita bruta do mês vezes a alíquota efetiva (RBT12 × Aliq − PD) / RBT12, sendo RBT12 a receita bruta acumulada nos doze meses anteriores ao período de apuração, Aliq a alíquota nominal e PD a parcela a deduzir do Anexo II, que se aplica à venda de mercadorias industrializadas pelo contribuinte (art. 18, § 4º, II). O DAS reúne num único recolhimento IRPJ, CSLL, Cofins, PIS/Pasep, CPP, IPI, ICMS e ISS (art. 13), e por isso nenhuma linha de documento de uma optante carrega um imposto sobre o consumo. No ano de início de atividade, a RBT12 é proporcionalizada: no primeiro mês, a receita do próprio mês vezes doze; nos onze meses seguintes, a média aritmética dos meses anteriores vezes doze (pergunta 5.4.1 do Perguntas e Respostas do Simples Nacional, «regra até 2026») — o que `short: annualise` faz', 'lc-123', 20)
on conflict (country, code) do update set
  name                   = excluded.name,
  replaces               = excluded.replaces,
  report_code            = excluded.report_code,
  window_months          = excluded.window_months,
  window_includes_period = excluded.window_includes_period,
  short_window           = excluded.short_window,
  expense_account_code   = excluded.expense_account_code,
  legal_reference        = excluded.legal_reference,
  source_key             = excluded.source_key,
  sequence               = excluded.sequence;

insert into turnover_tax_brackets
  (country, regime_code, valid_from, valid_to, sequence, up_to, nominal_rate, deduction, legal_reference, source_key)
values
  ('BR', 'BR-SN-II', date '2018-01-01', null, 10, 180000.00, 4.5, 0, 'Lei Complementar nº 123, de 2006, Anexo II, redação da Lei Complementar nº 155, de 2016 (vigência 1º de janeiro de 2018), 1ª faixa: receita bruta em 12 meses até 180.000,00, alíquota nominal 4,5 %, valor a deduzir nenhum', 'lc-123'),
  ('BR', 'BR-SN-II', date '2018-01-01', null, 20, 360000.00, 7.8, 5940.00, 'Lei Complementar nº 123, de 2006, Anexo II, redação da Lei Complementar nº 155, de 2016 (vigência 1º de janeiro de 2018), 2ª faixa: receita bruta em 12 meses de 180.000,01 a 360.000,00, alíquota nominal 7,8 %, valor a deduzir 5.940,00', 'lc-123'),
  ('BR', 'BR-SN-II', date '2018-01-01', null, 30, 720000.00, 10, 13860.00, 'Lei Complementar nº 123, de 2006, Anexo II, redação da Lei Complementar nº 155, de 2016 (vigência 1º de janeiro de 2018), 3ª faixa: receita bruta em 12 meses de 360.000,01 a 720.000,00, alíquota nominal 10 %, valor a deduzir 13.860,00', 'lc-123'),
  ('BR', 'BR-SN-II', date '2018-01-01', null, 40, 1800000.00, 11.2, 22500.00, 'Lei Complementar nº 123, de 2006, Anexo II, redação da Lei Complementar nº 155, de 2016 (vigência 1º de janeiro de 2018), 4ª faixa: receita bruta em 12 meses de 720.000,01 a 1.800.000,00, alíquota nominal 11,2 %, valor a deduzir 22.500,00', 'lc-123'),
  ('BR', 'BR-SN-II', date '2018-01-01', null, 50, 3600000.00, 14.7, 85500.00, 'Lei Complementar nº 123, de 2006, Anexo II, redação da Lei Complementar nº 155, de 2016 (vigência 1º de janeiro de 2018), 5ª faixa: receita bruta em 12 meses de 1.800.000,01 a 3.600.000,00, alíquota nominal 14,7 %, valor a deduzir 85.500,00', 'lc-123'),
  ('BR', 'BR-SN-II', date '2018-01-01', null, 60, null, 30, 720000.00, 'Lei Complementar nº 123, de 2006, Anexo II, redação da Lei Complementar nº 155, de 2016 (vigência 1º de janeiro de 2018), 6ª faixa: receita bruta em 12 meses de 3.600.000,01 a 4.800.000,00, alíquota nominal 30 %, valor a deduzir 720.000,00. A tabela termina em 4.800.000,00, o limite da empresa de pequeno porte (art. 3º, II); a faixa fica aberta porque o formato de Ekwo exige uma última faixa sem limite, e a exclusão do regime acima desse limite não é modelada — veja o README', 'lc-123');

insert into tax_report_templates
  (country, code, name, periods, period_default, valid_from, legal_reference, is_periodic_return,
   deadline_rule, deadline_day, deadline_reference, deadline_source_key)
values
  ('BR', 'BR-PGDAS-D', 'PGDAS-D — Programa Gerador do Documento de Arrecadação do Simples Nacional, Declaratório', array['month']::declaration_period[], 'month'::declaration_period, date '2018-01-01', 'Lei Complementar nº 123, de 2006, art. 18, § 15-A, II; Perguntas e Respostas do Simples Nacional, pergunta 6.4 — a apuração é feita e transmitida mensalmente no PGDAS-D 2018 (períodos de apuração a partir de janeiro de 2018), ainda que sem receita no mês, e o DAS só é gerado depois de transmitida a apuração (pergunta 6.7)', false, 'day_of_month_after_period'::filing_deadline_rule, 20, 'Resolução CGSN nº 140, de 2018, art. 40, segundo a pergunta 6.8 do Perguntas e Respostas do Simples Nacional — o prazo para recolher os tributos apurados termina no dia 20 do mês subsequente àquele em que a receita bruta foi auferida; quando não há expediente bancário no dia 20, o prazo é prorrogado para o primeiro dia útil seguinte. A pergunta 6.4 fixa no mesmo dia a transmissão do PGDAS-D', 'cgsn-perguntas')
on conflict (country, code) do update set
  name                = excluded.name,
  periods             = excluded.periods,
  period_default      = excluded.period_default,
  valid_from          = excluded.valid_from,
  legal_reference     = excluded.legal_reference,
  is_periodic_return  = excluded.is_periodic_return,
  deadline_rule       = excluded.deadline_rule,
  deadline_day        = excluded.deadline_day,
  deadline_reference  = excluded.deadline_reference,
  deadline_source_key = excluded.deadline_source_key;

insert into turnover_tax_regimes
  (country, code, name, replaces, report_code, window_months, window_includes_period, short_window,
   expense_account_code, legal_reference, source_key, sequence)
values
  ('BR', 'BR-SN-III', 'Simples Nacional — Anexo III (Serviços e locação de bens móveis)', array['vat', 'sales_tax']::tax_kind[], 'BR-PGDAS-D', 12, false, 'annualise', '6.1.1', 'Lei Complementar nº 123, de 2006, art. 18, caput e §§ 1º e 1º-A, redação da Lei Complementar nº 155, de 2016 — o valor devido mensalmente é a receita bruta do mês vezes a alíquota efetiva (RBT12 × Aliq − PD) / RBT12, sendo RBT12 a receita bruta acumulada nos doze meses anteriores ao período de apuração, Aliq a alíquota nominal e PD a parcela a deduzir do Anexo III, que se aplica à locação de bens móveis e prestação dos serviços não relacionados no § 5º-C do art. 18, e as atividades do § 5º-I quando o fator «r» é igual ou superior a 28 % (art. 18, § 5º-J). O DAS reúne num único recolhimento IRPJ, CSLL, Cofins, PIS/Pasep, CPP, IPI, ICMS e ISS (art. 13), e por isso nenhuma linha de documento de uma optante carrega um imposto sobre o consumo. No ano de início de atividade, a RBT12 é proporcionalizada: no primeiro mês, a receita do próprio mês vezes doze; nos onze meses seguintes, a média aritmética dos meses anteriores vezes doze (pergunta 5.4.1 do Perguntas e Respostas do Simples Nacional, «regra até 2026») — o que `short: annualise` faz', 'lc-123', 30)
on conflict (country, code) do update set
  name                   = excluded.name,
  replaces               = excluded.replaces,
  report_code            = excluded.report_code,
  window_months          = excluded.window_months,
  window_includes_period = excluded.window_includes_period,
  short_window           = excluded.short_window,
  expense_account_code   = excluded.expense_account_code,
  legal_reference        = excluded.legal_reference,
  source_key             = excluded.source_key,
  sequence               = excluded.sequence;

insert into turnover_tax_brackets
  (country, regime_code, valid_from, valid_to, sequence, up_to, nominal_rate, deduction, legal_reference, source_key)
values
  ('BR', 'BR-SN-III', date '2018-01-01', null, 10, 180000.00, 6, 0, 'Lei Complementar nº 123, de 2006, Anexo III, redação da Lei Complementar nº 155, de 2016 (vigência 1º de janeiro de 2018), 1ª faixa: receita bruta em 12 meses até 180.000,00, alíquota nominal 6 %, valor a deduzir nenhum', 'lc-123'),
  ('BR', 'BR-SN-III', date '2018-01-01', null, 20, 360000.00, 11.2, 9360.00, 'Lei Complementar nº 123, de 2006, Anexo III, redação da Lei Complementar nº 155, de 2016 (vigência 1º de janeiro de 2018), 2ª faixa: receita bruta em 12 meses de 180.000,01 a 360.000,00, alíquota nominal 11,2 %, valor a deduzir 9.360,00', 'lc-123'),
  ('BR', 'BR-SN-III', date '2018-01-01', null, 30, 720000.00, 13.5, 17640.00, 'Lei Complementar nº 123, de 2006, Anexo III, redação da Lei Complementar nº 155, de 2016 (vigência 1º de janeiro de 2018), 3ª faixa: receita bruta em 12 meses de 360.000,01 a 720.000,00, alíquota nominal 13,5 %, valor a deduzir 17.640,00', 'lc-123'),
  ('BR', 'BR-SN-III', date '2018-01-01', null, 40, 1800000.00, 16, 35640.00, 'Lei Complementar nº 123, de 2006, Anexo III, redação da Lei Complementar nº 155, de 2016 (vigência 1º de janeiro de 2018), 4ª faixa: receita bruta em 12 meses de 720.000,01 a 1.800.000,00, alíquota nominal 16 %, valor a deduzir 35.640,00', 'lc-123'),
  ('BR', 'BR-SN-III', date '2018-01-01', null, 50, 3600000.00, 21, 125640.00, 'Lei Complementar nº 123, de 2006, Anexo III, redação da Lei Complementar nº 155, de 2016 (vigência 1º de janeiro de 2018), 5ª faixa: receita bruta em 12 meses de 1.800.000,01 a 3.600.000,00, alíquota nominal 21 %, valor a deduzir 125.640,00', 'lc-123'),
  ('BR', 'BR-SN-III', date '2018-01-01', null, 60, null, 33, 648000.00, 'Lei Complementar nº 123, de 2006, Anexo III, redação da Lei Complementar nº 155, de 2016 (vigência 1º de janeiro de 2018), 6ª faixa: receita bruta em 12 meses de 3.600.000,01 a 4.800.000,00, alíquota nominal 33 %, valor a deduzir 648.000,00. A tabela termina em 4.800.000,00, o limite da empresa de pequeno porte (art. 3º, II); a faixa fica aberta porque o formato de Ekwo exige uma última faixa sem limite, e a exclusão do regime acima desse limite não é modelada — veja o README', 'lc-123');

insert into tax_report_templates
  (country, code, name, periods, period_default, valid_from, legal_reference, is_periodic_return,
   deadline_rule, deadline_day, deadline_reference, deadline_source_key)
values
  ('BR', 'BR-PGDAS-D', 'PGDAS-D — Programa Gerador do Documento de Arrecadação do Simples Nacional, Declaratório', array['month']::declaration_period[], 'month'::declaration_period, date '2018-01-01', 'Lei Complementar nº 123, de 2006, art. 18, § 15-A, II; Perguntas e Respostas do Simples Nacional, pergunta 6.4 — a apuração é feita e transmitida mensalmente no PGDAS-D 2018 (períodos de apuração a partir de janeiro de 2018), ainda que sem receita no mês, e o DAS só é gerado depois de transmitida a apuração (pergunta 6.7)', false, 'day_of_month_after_period'::filing_deadline_rule, 20, 'Resolução CGSN nº 140, de 2018, art. 40, segundo a pergunta 6.8 do Perguntas e Respostas do Simples Nacional — o prazo para recolher os tributos apurados termina no dia 20 do mês subsequente àquele em que a receita bruta foi auferida; quando não há expediente bancário no dia 20, o prazo é prorrogado para o primeiro dia útil seguinte. A pergunta 6.4 fixa no mesmo dia a transmissão do PGDAS-D', 'cgsn-perguntas')
on conflict (country, code) do update set
  name                = excluded.name,
  periods             = excluded.periods,
  period_default      = excluded.period_default,
  valid_from          = excluded.valid_from,
  legal_reference     = excluded.legal_reference,
  is_periodic_return  = excluded.is_periodic_return,
  deadline_rule       = excluded.deadline_rule,
  deadline_day        = excluded.deadline_day,
  deadline_reference  = excluded.deadline_reference,
  deadline_source_key = excluded.deadline_source_key;

insert into turnover_tax_regimes
  (country, code, name, replaces, report_code, window_months, window_includes_period, short_window,
   expense_account_code, legal_reference, source_key, sequence)
values
  ('BR', 'BR-SN-IV', 'Simples Nacional — Anexo IV (Serviços do § 5º-C)', array['vat', 'sales_tax']::tax_kind[], 'BR-PGDAS-D', 12, false, 'annualise', '6.1.1', 'Lei Complementar nº 123, de 2006, art. 18, caput e §§ 1º e 1º-A, redação da Lei Complementar nº 155, de 2016 — o valor devido mensalmente é a receita bruta do mês vezes a alíquota efetiva (RBT12 × Aliq − PD) / RBT12, sendo RBT12 a receita bruta acumulada nos doze meses anteriores ao período de apuração, Aliq a alíquota nominal e PD a parcela a deduzir do Anexo IV, que se aplica à prestação dos serviços relacionados no § 5º-C do art. 18 — a contribuição patronal previdenciária é recolhida fora do DAS. O DAS reúne num único recolhimento IRPJ, CSLL, Cofins, PIS/Pasep, CPP, IPI, ICMS e ISS (art. 13), e por isso nenhuma linha de documento de uma optante carrega um imposto sobre o consumo. No ano de início de atividade, a RBT12 é proporcionalizada: no primeiro mês, a receita do próprio mês vezes doze; nos onze meses seguintes, a média aritmética dos meses anteriores vezes doze (pergunta 5.4.1 do Perguntas e Respostas do Simples Nacional, «regra até 2026») — o que `short: annualise` faz', 'lc-123', 40)
on conflict (country, code) do update set
  name                   = excluded.name,
  replaces               = excluded.replaces,
  report_code            = excluded.report_code,
  window_months          = excluded.window_months,
  window_includes_period = excluded.window_includes_period,
  short_window           = excluded.short_window,
  expense_account_code   = excluded.expense_account_code,
  legal_reference        = excluded.legal_reference,
  source_key             = excluded.source_key,
  sequence               = excluded.sequence;

insert into turnover_tax_brackets
  (country, regime_code, valid_from, valid_to, sequence, up_to, nominal_rate, deduction, legal_reference, source_key)
values
  ('BR', 'BR-SN-IV', date '2018-01-01', null, 10, 180000.00, 4.5, 0, 'Lei Complementar nº 123, de 2006, Anexo IV, redação da Lei Complementar nº 155, de 2016 (vigência 1º de janeiro de 2018), 1ª faixa: receita bruta em 12 meses até 180.000,00, alíquota nominal 4,5 %, valor a deduzir nenhum', 'lc-123'),
  ('BR', 'BR-SN-IV', date '2018-01-01', null, 20, 360000.00, 9, 8100.00, 'Lei Complementar nº 123, de 2006, Anexo IV, redação da Lei Complementar nº 155, de 2016 (vigência 1º de janeiro de 2018), 2ª faixa: receita bruta em 12 meses de 180.000,01 a 360.000,00, alíquota nominal 9 %, valor a deduzir 8.100,00', 'lc-123'),
  ('BR', 'BR-SN-IV', date '2018-01-01', null, 30, 720000.00, 10.2, 12420.00, 'Lei Complementar nº 123, de 2006, Anexo IV, redação da Lei Complementar nº 155, de 2016 (vigência 1º de janeiro de 2018), 3ª faixa: receita bruta em 12 meses de 360.000,01 a 720.000,00, alíquota nominal 10,2 %, valor a deduzir 12.420,00', 'lc-123'),
  ('BR', 'BR-SN-IV', date '2018-01-01', null, 40, 1800000.00, 14, 39780.00, 'Lei Complementar nº 123, de 2006, Anexo IV, redação da Lei Complementar nº 155, de 2016 (vigência 1º de janeiro de 2018), 4ª faixa: receita bruta em 12 meses de 720.000,01 a 1.800.000,00, alíquota nominal 14 %, valor a deduzir 39.780,00', 'lc-123'),
  ('BR', 'BR-SN-IV', date '2018-01-01', null, 50, 3600000.00, 22, 183780.00, 'Lei Complementar nº 123, de 2006, Anexo IV, redação da Lei Complementar nº 155, de 2016 (vigência 1º de janeiro de 2018), 5ª faixa: receita bruta em 12 meses de 1.800.000,01 a 3.600.000,00, alíquota nominal 22 %, valor a deduzir 183.780,00', 'lc-123'),
  ('BR', 'BR-SN-IV', date '2018-01-01', null, 60, null, 33, 828000.00, 'Lei Complementar nº 123, de 2006, Anexo IV, redação da Lei Complementar nº 155, de 2016 (vigência 1º de janeiro de 2018), 6ª faixa: receita bruta em 12 meses de 3.600.000,01 a 4.800.000,00, alíquota nominal 33 %, valor a deduzir 828.000,00. A tabela termina em 4.800.000,00, o limite da empresa de pequeno porte (art. 3º, II); a faixa fica aberta porque o formato de Ekwo exige uma última faixa sem limite, e a exclusão do regime acima desse limite não é modelada — veja o README', 'lc-123');

insert into tax_report_templates
  (country, code, name, periods, period_default, valid_from, legal_reference, is_periodic_return,
   deadline_rule, deadline_day, deadline_reference, deadline_source_key)
values
  ('BR', 'BR-PGDAS-D', 'PGDAS-D — Programa Gerador do Documento de Arrecadação do Simples Nacional, Declaratório', array['month']::declaration_period[], 'month'::declaration_period, date '2018-01-01', 'Lei Complementar nº 123, de 2006, art. 18, § 15-A, II; Perguntas e Respostas do Simples Nacional, pergunta 6.4 — a apuração é feita e transmitida mensalmente no PGDAS-D 2018 (períodos de apuração a partir de janeiro de 2018), ainda que sem receita no mês, e o DAS só é gerado depois de transmitida a apuração (pergunta 6.7)', false, 'day_of_month_after_period'::filing_deadline_rule, 20, 'Resolução CGSN nº 140, de 2018, art. 40, segundo a pergunta 6.8 do Perguntas e Respostas do Simples Nacional — o prazo para recolher os tributos apurados termina no dia 20 do mês subsequente àquele em que a receita bruta foi auferida; quando não há expediente bancário no dia 20, o prazo é prorrogado para o primeiro dia útil seguinte. A pergunta 6.4 fixa no mesmo dia a transmissão do PGDAS-D', 'cgsn-perguntas')
on conflict (country, code) do update set
  name                = excluded.name,
  periods             = excluded.periods,
  period_default      = excluded.period_default,
  valid_from          = excluded.valid_from,
  legal_reference     = excluded.legal_reference,
  is_periodic_return  = excluded.is_periodic_return,
  deadline_rule       = excluded.deadline_rule,
  deadline_day        = excluded.deadline_day,
  deadline_reference  = excluded.deadline_reference,
  deadline_source_key = excluded.deadline_source_key;

insert into turnover_tax_regimes
  (country, code, name, replaces, report_code, window_months, window_includes_period, short_window,
   expense_account_code, legal_reference, source_key, sequence)
values
  ('BR', 'BR-SN-V', 'Simples Nacional — Anexo V (Serviços do § 5º-I)', array['vat', 'sales_tax']::tax_kind[], 'BR-PGDAS-D', 12, false, 'annualise', '6.1.1', 'Lei Complementar nº 123, de 2006, art. 18, caput e §§ 1º e 1º-A, redação da Lei Complementar nº 155, de 2016 — o valor devido mensalmente é a receita bruta do mês vezes a alíquota efetiva (RBT12 × Aliq − PD) / RBT12, sendo RBT12 a receita bruta acumulada nos doze meses anteriores ao período de apuração, Aliq a alíquota nominal e PD a parcela a deduzir do Anexo V, que se aplica à prestação dos serviços relacionados no § 5º-I do art. 18 quando o fator «r» é inferior a 28 % (art. 18, § 5º-M). O DAS reúne num único recolhimento IRPJ, CSLL, Cofins, PIS/Pasep, CPP, IPI, ICMS e ISS (art. 13), e por isso nenhuma linha de documento de uma optante carrega um imposto sobre o consumo. No ano de início de atividade, a RBT12 é proporcionalizada: no primeiro mês, a receita do próprio mês vezes doze; nos onze meses seguintes, a média aritmética dos meses anteriores vezes doze (pergunta 5.4.1 do Perguntas e Respostas do Simples Nacional, «regra até 2026») — o que `short: annualise` faz', 'lc-123', 50)
on conflict (country, code) do update set
  name                   = excluded.name,
  replaces               = excluded.replaces,
  report_code            = excluded.report_code,
  window_months          = excluded.window_months,
  window_includes_period = excluded.window_includes_period,
  short_window           = excluded.short_window,
  expense_account_code   = excluded.expense_account_code,
  legal_reference        = excluded.legal_reference,
  source_key             = excluded.source_key,
  sequence               = excluded.sequence;

insert into turnover_tax_brackets
  (country, regime_code, valid_from, valid_to, sequence, up_to, nominal_rate, deduction, legal_reference, source_key)
values
  ('BR', 'BR-SN-V', date '2018-01-01', null, 10, 180000.00, 15.5, 0, 'Lei Complementar nº 123, de 2006, Anexo V, redação da Lei Complementar nº 155, de 2016 (vigência 1º de janeiro de 2018), 1ª faixa: receita bruta em 12 meses até 180.000,00, alíquota nominal 15,5 %, valor a deduzir nenhum', 'lc-123'),
  ('BR', 'BR-SN-V', date '2018-01-01', null, 20, 360000.00, 18, 4500.00, 'Lei Complementar nº 123, de 2006, Anexo V, redação da Lei Complementar nº 155, de 2016 (vigência 1º de janeiro de 2018), 2ª faixa: receita bruta em 12 meses de 180.000,01 a 360.000,00, alíquota nominal 18 %, valor a deduzir 4.500,00', 'lc-123'),
  ('BR', 'BR-SN-V', date '2018-01-01', null, 30, 720000.00, 19.5, 9900.00, 'Lei Complementar nº 123, de 2006, Anexo V, redação da Lei Complementar nº 155, de 2016 (vigência 1º de janeiro de 2018), 3ª faixa: receita bruta em 12 meses de 360.000,01 a 720.000,00, alíquota nominal 19,5 %, valor a deduzir 9.900,00', 'lc-123'),
  ('BR', 'BR-SN-V', date '2018-01-01', null, 40, 1800000.00, 20.5, 17100.00, 'Lei Complementar nº 123, de 2006, Anexo V, redação da Lei Complementar nº 155, de 2016 (vigência 1º de janeiro de 2018), 4ª faixa: receita bruta em 12 meses de 720.000,01 a 1.800.000,00, alíquota nominal 20,5 %, valor a deduzir 17.100,00', 'lc-123'),
  ('BR', 'BR-SN-V', date '2018-01-01', null, 50, 3600000.00, 23, 62100.00, 'Lei Complementar nº 123, de 2006, Anexo V, redação da Lei Complementar nº 155, de 2016 (vigência 1º de janeiro de 2018), 5ª faixa: receita bruta em 12 meses de 1.800.000,01 a 3.600.000,00, alíquota nominal 23 %, valor a deduzir 62.100,00', 'lc-123'),
  ('BR', 'BR-SN-V', date '2018-01-01', null, 60, null, 30.5, 540000.00, 'Lei Complementar nº 123, de 2006, Anexo V, redação da Lei Complementar nº 155, de 2016 (vigência 1º de janeiro de 2018), 6ª faixa: receita bruta em 12 meses de 3.600.000,01 a 4.800.000,00, alíquota nominal 30,5 %, valor a deduzir 540.000,00. A tabela termina em 4.800.000,00, o limite da empresa de pequeno porte (art. 3º, II); a faixa fica aberta porque o formato de Ekwo exige uma última faixa sem limite, e a exclusão do regime acima desse limite não é modelada — veja o README', 'lc-123');

insert into statement_templates
  (code, country, chart_code, name, kind, framework, valid_from, valid_to, legal_reference,
   source_key, result_in_progress, result_in_progress_name, result_in_progress_name_i18n)
values
  ('BR-BP', 'BR', 'default', 'Balanço Patrimonial', 'balance_sheet', 'BR-ME-EPP', date '1970-01-01', null, 'Código Civil, art. 1.179 — o empresário e a sociedade empresária levantam anualmente o balanço patrimonial, que exprime com fidelidade e clareza a situação real da empresa e indica distintamente o ativo e o passivo (art. 1.188). Os grupos seguem a Lei nº 6.404, de 1976, art. 178: ativo circulante e não circulante (realizável a longo prazo, investimentos, imobilizado e intangível), passivo circulante e não circulante, e patrimônio líquido. Uma optante pelo Simples Nacional pode adotar contabilidade simplificada (Lei Complementar nº 123, de 2006, art. 27), e as normas do Conselho Federal de Contabilidade para microentidades e pequenas empresas preveem esses mesmos grupos', 'codigo-civil', 'alone', null, '{}'::jsonb),
  ('BR-DRE', 'BR', 'default', 'Demonstração do Resultado do Exercício', 'income_statement', 'BR-ME-EPP', date '1970-01-01', null, 'Código Civil, art. 1.189 — o balanço de resultado econômico acompanha o balanço patrimonial, na forma da lei especial. As linhas seguem a discriminação da Lei nº 6.404, de 1976, art. 187: receita bruta, deduções e impostos, receita líquida, custo das mercadorias e serviços vendidos, lucro bruto, despesas com vendas, financeiras, gerais e administrativas e outras despesas operacionais, outras receitas e despesas, e o resultado do exercício. Para uma optante pelo Simples Nacional, o IRPJ e a CSLL estão no DAS (Lei Complementar nº 123, de 2006, art. 13) e não há linha de provisão para o imposto de renda', 'codigo-civil', null, null, '{}'::jsonb)
on conflict (code) do update set
  country         = excluded.country,
  chart_code      = excluded.chart_code,
  name            = excluded.name,
  kind            = excluded.kind,
  framework       = excluded.framework,
  valid_from      = excluded.valid_from,
  valid_to        = excluded.valid_to,
  legal_reference = excluded.legal_reference,
  source_key      = excluded.source_key,
  result_in_progress           = excluded.result_in_progress,
  result_in_progress_name      = excluded.result_in_progress_name,
  result_in_progress_name_i18n = excluded.result_in_progress_name_i18n;

insert into statement_line_templates
  (statement_code, code, parent_code, name, name_i18n, sequence, sign, is_total,
   plus_lines, minus_lines, xbrl_element, legal_reference, source_key)
values
  ('BR-BP', 'ATIVO', null, 'Ativo', '{"en":"Assets"}'::jsonb, 10, 1, true, array['AC', 'ANC']::text[], '{}'::text[], null, null, null),
  ('BR-BP', 'AC', 'ATIVO', 'Ativo circulante', '{"en":"Current assets"}'::jsonb, 20, 1, true, array['1.1.1', '1.1.2', '1.1.3', '1.1.4', '1.1.5', '1.1.9']::text[], '{}'::text[], null, null, null),
  ('BR-BP', '1.1.1', 'AC', 'Disponível', '{"en":"Cash and cash equivalents"}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, 'Contas do plano de referência deste pacote, agrupadas na ordem dos arts. 178 e 179 da Lei nº 6.404, de 1976; o Código Civil não prescreve um plano de contas — veja o README', 'lei-6404'),
  ('BR-BP', '1.1.2', 'AC', 'Clientes', '{"en":"Trade receivables"}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, 'Contas do plano de referência deste pacote, agrupadas na ordem dos arts. 178 e 179 da Lei nº 6.404, de 1976; o Código Civil não prescreve um plano de contas — veja o README', 'lei-6404'),
  ('BR-BP', '1.1.3', 'AC', 'Outros créditos', '{"en":"Other receivables"}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, 'Contas do plano de referência deste pacote, agrupadas na ordem dos arts. 178 e 179 da Lei nº 6.404, de 1976; o Código Civil não prescreve um plano de contas — veja o README', 'lei-6404'),
  ('BR-BP', '1.1.4', 'AC', 'Estoques', '{"en":"Inventories"}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, 'Contas do plano de referência deste pacote, agrupadas na ordem dos arts. 178 e 179 da Lei nº 6.404, de 1976; o Código Civil não prescreve um plano de contas — veja o README', 'lei-6404'),
  ('BR-BP', '1.1.5', 'AC', 'Despesas do exercício seguinte', '{"en":"Prepaid expenses"}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, 'Contas do plano de referência deste pacote, agrupadas na ordem dos arts. 178 e 179 da Lei nº 6.404, de 1976; o Código Civil não prescreve um plano de contas — veja o README', 'lei-6404'),
  ('BR-BP', '1.1.9', 'AC', 'Contas transitórias', '{"en":"Clearing accounts"}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, 'Contas do plano de referência deste pacote, agrupadas na ordem dos arts. 178 e 179 da Lei nº 6.404, de 1976; o Código Civil não prescreve um plano de contas — veja o README', 'lei-6404'),
  ('BR-BP', 'ANC', 'ATIVO', 'Ativo não circulante', '{"en":"Non-current assets"}'::jsonb, 90, 1, true, array['1.2.1', '1.2.2', '1.2.3', '1.2.4']::text[], '{}'::text[], null, null, null),
  ('BR-BP', '1.2.1', 'ANC', 'Realizável a longo prazo', '{"en":"Long-term receivables"}'::jsonb, 100, 1, false, '{}'::text[], '{}'::text[], null, 'Contas do plano de referência deste pacote, agrupadas na ordem dos arts. 178 e 179 da Lei nº 6.404, de 1976; o Código Civil não prescreve um plano de contas — veja o README', 'lei-6404'),
  ('BR-BP', '1.2.2', 'ANC', 'Investimentos', '{"en":"Investments"}'::jsonb, 110, 1, false, '{}'::text[], '{}'::text[], null, 'Contas do plano de referência deste pacote, agrupadas na ordem dos arts. 178 e 179 da Lei nº 6.404, de 1976; o Código Civil não prescreve um plano de contas — veja o README', 'lei-6404'),
  ('BR-BP', '1.2.3', 'ANC', 'Imobilizado', '{"en":"Property, plant and equipment"}'::jsonb, 120, 1, false, '{}'::text[], '{}'::text[], null, 'Contas do plano de referência deste pacote, agrupadas na ordem dos arts. 178 e 179 da Lei nº 6.404, de 1976; o Código Civil não prescreve um plano de contas — veja o README', 'lei-6404'),
  ('BR-BP', '1.2.4', 'ANC', 'Intangível', '{"en":"Intangible assets"}'::jsonb, 130, 1, false, '{}'::text[], '{}'::text[], null, 'Contas do plano de referência deste pacote, agrupadas na ordem dos arts. 178 e 179 da Lei nº 6.404, de 1976; o Código Civil não prescreve um plano de contas — veja o README', 'lei-6404'),
  ('BR-BP', 'PASPL', null, 'Passivo e patrimônio líquido', '{"en":"Liabilities and equity"}'::jsonb, 140, 1, true, array['PASSIVO', 'PL']::text[], '{}'::text[], null, null, null),
  ('BR-BP', 'PASSIVO', 'PASPL', 'Passivo', '{"en":"Liabilities"}'::jsonb, 150, 1, true, array['PC', 'PNC']::text[], '{}'::text[], null, null, null),
  ('BR-BP', 'PC', 'PASSIVO', 'Passivo circulante', '{"en":"Current liabilities"}'::jsonb, 160, 1, true, array['2.1.1', '2.1.2', '2.1.3', '2.1.4', '2.1.5', '2.1.6']::text[], '{}'::text[], null, null, null),
  ('BR-BP', '2.1.1', 'PC', 'Fornecedores', '{"en":"Trade payables"}'::jsonb, 170, -1, false, '{}'::text[], '{}'::text[], null, 'Contas do plano de referência deste pacote, agrupadas na ordem dos arts. 178 e 179 da Lei nº 6.404, de 1976; o Código Civil não prescreve um plano de contas — veja o README', 'lei-6404'),
  ('BR-BP', '2.1.2', 'PC', 'Obrigações trabalhistas', '{"en":"Payroll liabilities"}'::jsonb, 180, -1, false, '{}'::text[], '{}'::text[], null, 'Contas do plano de referência deste pacote, agrupadas na ordem dos arts. 178 e 179 da Lei nº 6.404, de 1976; o Código Civil não prescreve um plano de contas — veja o README', 'lei-6404'),
  ('BR-BP', '2.1.3', 'PC', 'Obrigações sociais', '{"en":"Social security liabilities"}'::jsonb, 190, -1, false, '{}'::text[], '{}'::text[], null, 'Contas do plano de referência deste pacote, agrupadas na ordem dos arts. 178 e 179 da Lei nº 6.404, de 1976; o Código Civil não prescreve um plano de contas — veja o README', 'lei-6404'),
  ('BR-BP', '2.1.4', 'PC', 'Obrigações tributárias', '{"en":"Tax liabilities"}'::jsonb, 200, -1, false, '{}'::text[], '{}'::text[], null, 'Contas do plano de referência deste pacote, agrupadas na ordem dos arts. 178 e 179 da Lei nº 6.404, de 1976; o Código Civil não prescreve um plano de contas — veja o README', 'lei-6404'),
  ('BR-BP', '2.1.5', 'PC', 'Empréstimos e financiamentos', '{"en":"Loans and borrowings"}'::jsonb, 210, -1, false, '{}'::text[], '{}'::text[], null, 'Contas do plano de referência deste pacote, agrupadas na ordem dos arts. 178 e 179 da Lei nº 6.404, de 1976; o Código Civil não prescreve um plano de contas — veja o README', 'lei-6404'),
  ('BR-BP', '2.1.6', 'PC', 'Outras obrigações', '{"en":"Other current liabilities"}'::jsonb, 220, -1, false, '{}'::text[], '{}'::text[], null, 'Contas do plano de referência deste pacote, agrupadas na ordem dos arts. 178 e 179 da Lei nº 6.404, de 1976; o Código Civil não prescreve um plano de contas — veja o README', 'lei-6404'),
  ('BR-BP', 'PNC', 'PASSIVO', 'Passivo não circulante', '{"en":"Non-current liabilities"}'::jsonb, 230, 1, true, array['2.2.1', '2.2.2', '2.2.3', '2.2.9']::text[], '{}'::text[], null, null, null),
  ('BR-BP', '2.2.1', 'PNC', 'Empréstimos e financiamentos a longo prazo', '{"en":"Long-term loans and borrowings"}'::jsonb, 240, -1, false, '{}'::text[], '{}'::text[], null, 'Contas do plano de referência deste pacote, agrupadas na ordem dos arts. 178 e 179 da Lei nº 6.404, de 1976; o Código Civil não prescreve um plano de contas — veja o README', 'lei-6404'),
  ('BR-BP', '2.2.2', 'PNC', 'Mútuos de sócios', '{"en":"Loans from partners"}'::jsonb, 250, -1, false, '{}'::text[], '{}'::text[], null, 'Contas do plano de referência deste pacote, agrupadas na ordem dos arts. 178 e 179 da Lei nº 6.404, de 1976; o Código Civil não prescreve um plano de contas — veja o README', 'lei-6404'),
  ('BR-BP', '2.2.3', 'PNC', 'Parcelamentos tributários a longo prazo', '{"en":"Long-term tax instalment arrangements"}'::jsonb, 260, -1, false, '{}'::text[], '{}'::text[], null, 'Contas do plano de referência deste pacote, agrupadas na ordem dos arts. 178 e 179 da Lei nº 6.404, de 1976; o Código Civil não prescreve um plano de contas — veja o README', 'lei-6404'),
  ('BR-BP', '2.2.9', 'PNC', 'Outras obrigações a longo prazo', '{"en":"Other long-term liabilities"}'::jsonb, 270, -1, false, '{}'::text[], '{}'::text[], null, 'Contas do plano de referência deste pacote, agrupadas na ordem dos arts. 178 e 179 da Lei nº 6.404, de 1976; o Código Civil não prescreve um plano de contas — veja o README', 'lei-6404'),
  ('BR-BP', 'PL', 'PASPL', 'Patrimônio líquido', '{"en":"Equity"}'::jsonb, 280, 1, true, array['3.1', '3.2', '3.3', '3.4', '3.5']::text[], '{}'::text[], null, null, null),
  ('BR-BP', '3.1', 'PL', 'Capital social', '{"en":"Share capital"}'::jsonb, 290, -1, false, '{}'::text[], '{}'::text[], null, 'Contas do plano de referência deste pacote, agrupadas na ordem dos arts. 178 e 179 da Lei nº 6.404, de 1976; o Código Civil não prescreve um plano de contas — veja o README', 'lei-6404'),
  ('BR-BP', '3.2', 'PL', 'Reservas de capital', '{"en":"Capital reserves"}'::jsonb, 300, -1, false, '{}'::text[], '{}'::text[], null, 'Contas do plano de referência deste pacote, agrupadas na ordem dos arts. 178 e 179 da Lei nº 6.404, de 1976; o Código Civil não prescreve um plano de contas — veja o README', 'lei-6404'),
  ('BR-BP', '3.3', 'PL', 'Reservas de lucros', '{"en":"Profit reserves"}'::jsonb, 310, -1, false, '{}'::text[], '{}'::text[], null, 'Contas do plano de referência deste pacote, agrupadas na ordem dos arts. 178 e 179 da Lei nº 6.404, de 1976; o Código Civil não prescreve um plano de contas — veja o README', 'lei-6404'),
  ('BR-BP', '3.4', 'PL', 'Lucros ou prejuízos acumulados', '{"en":"Retained earnings or accumulated losses"}'::jsonb, 320, -1, false, '{}'::text[], '{}'::text[], null, 'Contas do plano de referência deste pacote, agrupadas na ordem dos arts. 178 e 179 da Lei nº 6.404, de 1976; o Código Civil não prescreve um plano de contas — veja o README', 'lei-6404'),
  ('BR-BP', '3.5', 'PL', 'Resultado do exercício', '{"en":"Result for the year"}'::jsonb, 330, -1, false, '{}'::text[], '{}'::text[], null, 'Contas do plano de referência deste pacote, agrupadas na ordem dos arts. 178 e 179 da Lei nº 6.404, de 1976; o Código Civil não prescreve um plano de contas — veja o README', 'lei-6404'),
  ('BR-DRE', '4.1', null, 'Receita bruta de vendas e serviços', '{"en":"Gross revenue from sales and services"}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, 'Contas do plano de referência deste pacote, na discriminação do art. 187 da Lei nº 6.404, de 1976', 'lei-6404'),
  ('BR-DRE', '4.2', null, '(-) Devoluções, cancelamentos e descontos incondicionais', '{"en":"(-) Returns, cancellations and unconditional discounts"}'::jsonb, 20, -1, false, '{}'::text[], '{}'::text[], null, 'Contas do plano de referência deste pacote, na discriminação do art. 187 da Lei nº 6.404, de 1976', 'lei-6404'),
  ('BR-DRE', '6.1', null, '(-) Tributos sobre a receita (Simples Nacional)', '{"en":"(-) Taxes on revenue (Simples Nacional)"}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, 'Lei nº 6.404, de 1976, art. 187, I — os impostos são deduzidos da receita bruta; o DAS do Simples Nacional, calculado sobre a receita bruta do mês, é lançado na conta 6.1.1', 'lei-6404'),
  ('BR-DRE', 'RL', null, 'Receita líquida', '{"en":"Net revenue"}'::jsonb, 40, 1, true, array['4.1', '4.2']::text[], array['6.1']::text[], null, null, null),
  ('BR-DRE', '5.1', null, '(-) Custo das mercadorias e dos serviços vendidos', '{"en":"(-) Cost of goods and services sold"}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, 'Contas do plano de referência deste pacote, na discriminação do art. 187 da Lei nº 6.404, de 1976', 'lei-6404'),
  ('BR-DRE', 'LB', null, 'Lucro bruto', '{"en":"Gross profit"}'::jsonb, 60, 1, true, array['RL']::text[], array['5.1']::text[], null, null, null),
  ('BR-DRE', '6.5', null, '(-) Despesas com vendas', '{"en":"(-) Selling expenses"}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, 'Contas do plano de referência deste pacote, na discriminação do art. 187 da Lei nº 6.404, de 1976', 'lei-6404'),
  ('BR-DRE', '6.2', null, '(-) Despesas com pessoal', '{"en":"(-) Staff costs"}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, 'Contas do plano de referência deste pacote, na discriminação do art. 187 da Lei nº 6.404, de 1976', 'lei-6404'),
  ('BR-DRE', '6.3', null, '(-) Despesas gerais e administrativas', '{"en":"(-) General and administrative expenses"}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, 'Contas do plano de referência deste pacote, na discriminação do art. 187 da Lei nº 6.404, de 1976', 'lei-6404'),
  ('BR-DRE', '6.4', null, '(-) Outras despesas operacionais', '{"en":"(-) Other operating expenses"}'::jsonb, 100, 1, false, '{}'::text[], '{}'::text[], null, 'Contas do plano de referência deste pacote, na discriminação do art. 187 da Lei nº 6.404, de 1976', 'lei-6404'),
  ('BR-DRE', '4.3', null, 'Receitas financeiras', '{"en":"Finance income"}'::jsonb, 110, -1, false, '{}'::text[], '{}'::text[], null, 'Contas do plano de referência deste pacote, na discriminação do art. 187 da Lei nº 6.404, de 1976', 'lei-6404'),
  ('BR-DRE', '6.6', null, '(-) Despesas financeiras', '{"en":"(-) Finance costs"}'::jsonb, 120, 1, false, '{}'::text[], '{}'::text[], null, 'Contas do plano de referência deste pacote, na discriminação do art. 187 da Lei nº 6.404, de 1976', 'lei-6404'),
  ('BR-DRE', 'LO', null, 'Lucro ou prejuízo operacional', '{"en":"Operating profit or loss"}'::jsonb, 130, 1, true, array['LB', '4.3']::text[], array['6.5', '6.2', '6.3', '6.4', '6.6']::text[], null, null, null),
  ('BR-DRE', '4.4', null, 'Outras receitas', '{"en":"Other income"}'::jsonb, 140, -1, false, '{}'::text[], '{}'::text[], null, 'Contas do plano de referência deste pacote, na discriminação do art. 187 da Lei nº 6.404, de 1976', 'lei-6404'),
  ('BR-DRE', '6.7', null, '(-) Outras despesas', '{"en":"(-) Other expenses"}'::jsonb, 150, 1, false, '{}'::text[], '{}'::text[], null, 'Contas do plano de referência deste pacote, na discriminação do art. 187 da Lei nº 6.404, de 1976', 'lei-6404'),
  ('BR-DRE', 'LL', null, 'Lucro ou prejuízo líquido do exercício', '{"en":"Net profit or loss for the year"}'::jsonb, 160, 1, true, array['LO', '4.4']::text[], array['6.7']::text[], null, null, null)
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

delete from statement_line_rules r
 where r.statement_code in ('BR-BP', 'BR-DRE')
   and (r.statement_code, r.line_code, r.sequence) not in (
     values ('BR-BP', '1.1.1', 10),
            ('BR-BP', '1.1.2', 10),
            ('BR-BP', '1.1.3', 10),
            ('BR-BP', '1.1.4', 10),
            ('BR-BP', '1.1.5', 10),
            ('BR-BP', '1.1.9', 10),
            ('BR-BP', '1.2.1', 10),
            ('BR-BP', '1.2.2', 10),
            ('BR-BP', '1.2.3', 10),
            ('BR-BP', '1.2.4', 10),
            ('BR-BP', '2.1.1', 10),
            ('BR-BP', '2.1.2', 10),
            ('BR-BP', '2.1.3', 10),
            ('BR-BP', '2.1.4', 10),
            ('BR-BP', '2.1.5', 10),
            ('BR-BP', '2.1.6', 10),
            ('BR-BP', '2.2.1', 10),
            ('BR-BP', '2.2.2', 10),
            ('BR-BP', '2.2.3', 10),
            ('BR-BP', '2.2.9', 10),
            ('BR-BP', '3.1', 10),
            ('BR-BP', '3.2', 10),
            ('BR-BP', '3.3', 10),
            ('BR-BP', '3.4', 10),
            ('BR-BP', '3.5', 10),
            ('BR-DRE', '4.1', 10),
            ('BR-DRE', '4.2', 10),
            ('BR-DRE', '6.1', 10),
            ('BR-DRE', '5.1', 10),
            ('BR-DRE', '6.5', 10),
            ('BR-DRE', '6.2', 10),
            ('BR-DRE', '6.3', 10),
            ('BR-DRE', '6.4', 10),
            ('BR-DRE', '4.3', 10),
            ('BR-DRE', '6.6', 10),
            ('BR-DRE', '4.4', 10),
            ('BR-DRE', '6.7', 10)
   );

insert into statement_line_rules
  (statement_code, line_code, sequence, rule_kind, code_from, code_to,
   account_type, balance_side)
select v.statement_code, v.line_code, v.sequence, v.rule_kind, v.code_from,
       v.code_to, v.account_type::account_type, v.balance_side
  from (values
    ('BR-BP', '1.1.1', 10, 'code_prefix', '1.1.1', null, null, 'any'),
    ('BR-BP', '1.1.2', 10, 'code_prefix', '1.1.2', null, null, 'any'),
    ('BR-BP', '1.1.3', 10, 'code_prefix', '1.1.3', null, null, 'any'),
    ('BR-BP', '1.1.4', 10, 'code_prefix', '1.1.4', null, null, 'any'),
    ('BR-BP', '1.1.5', 10, 'code_prefix', '1.1.5', null, null, 'any'),
    ('BR-BP', '1.1.9', 10, 'code_prefix', '1.1.9', null, null, 'any'),
    ('BR-BP', '1.2.1', 10, 'code_prefix', '1.2.1', null, null, 'any'),
    ('BR-BP', '1.2.2', 10, 'code_prefix', '1.2.2', null, null, 'any'),
    ('BR-BP', '1.2.3', 10, 'code_prefix', '1.2.3', null, null, 'any'),
    ('BR-BP', '1.2.4', 10, 'code_prefix', '1.2.4', null, null, 'any'),
    ('BR-BP', '2.1.1', 10, 'code_prefix', '2.1.1', null, null, 'any'),
    ('BR-BP', '2.1.2', 10, 'code_prefix', '2.1.2', null, null, 'any'),
    ('BR-BP', '2.1.3', 10, 'code_prefix', '2.1.3', null, null, 'any'),
    ('BR-BP', '2.1.4', 10, 'code_prefix', '2.1.4', null, null, 'any'),
    ('BR-BP', '2.1.5', 10, 'code_prefix', '2.1.5', null, null, 'any'),
    ('BR-BP', '2.1.6', 10, 'code_prefix', '2.1.6', null, null, 'any'),
    ('BR-BP', '2.2.1', 10, 'code_prefix', '2.2.1', null, null, 'any'),
    ('BR-BP', '2.2.2', 10, 'code_prefix', '2.2.2', null, null, 'any'),
    ('BR-BP', '2.2.3', 10, 'code_prefix', '2.2.3', null, null, 'any'),
    ('BR-BP', '2.2.9', 10, 'code_prefix', '2.2.9', null, null, 'any'),
    ('BR-BP', '3.1', 10, 'code_prefix', '3.1', null, null, 'any'),
    ('BR-BP', '3.2', 10, 'code_prefix', '3.2', null, null, 'any'),
    ('BR-BP', '3.3', 10, 'code_prefix', '3.3', null, null, 'any'),
    ('BR-BP', '3.4', 10, 'code_prefix', '3.4', null, null, 'any'),
    ('BR-BP', '3.5', 10, 'code_prefix', '3.5', null, null, 'any'),
    ('BR-DRE', '4.1', 10, 'code_prefix', '4.1', null, null, 'any'),
    ('BR-DRE', '4.2', 10, 'code_prefix', '4.2', null, null, 'any'),
    ('BR-DRE', '6.1', 10, 'code_prefix', '6.1', null, null, 'any'),
    ('BR-DRE', '5.1', 10, 'code_prefix', '5.1', null, null, 'any'),
    ('BR-DRE', '6.5', 10, 'code_prefix', '6.5', null, null, 'any'),
    ('BR-DRE', '6.2', 10, 'code_prefix', '6.2', null, null, 'any'),
    ('BR-DRE', '6.3', 10, 'code_prefix', '6.3', null, null, 'any'),
    ('BR-DRE', '6.4', 10, 'code_prefix', '6.4', null, null, 'any'),
    ('BR-DRE', '4.3', 10, 'code_prefix', '4.3', null, null, 'any'),
    ('BR-DRE', '6.6', 10, 'code_prefix', '6.6', null, null, 'any'),
    ('BR-DRE', '4.4', 10, 'code_prefix', '4.4', null, null, 'any'),
    ('BR-DRE', '6.7', 10, 'code_prefix', '6.7', null, null, 'any')
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
  ('BR', 'Brasil', '{"en":"Brazil"}'::jsonb, array['pt', 'en']::text[], 'BRL', '1.1.2.01', '2.1.1.01', '1.1.9.01', '6.7.2', '3.4.1', '4.1.1', '5.1.1', '1.1.1.02', '1.1.1.01', 'VEN', 'COM', 'DIA', 'pt', 'result_accounts', '3.5.1', '3.5.2', '3.4.2', 'ABE', 'half_up', default, '4.3.4', '6.6.6', '4.4.1', '6.7.1', null, null, '2.1.4.01', '1.1.3.03', 'Lançamento de abertura', null)
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
  numbering_gapless             = false,
  number_format                 = '{CODE}-{YYYY}-{NNNNNN}',
  legal_payment_days            = null,
  late_payment_reference        = null,
  numbering_legal_reference     = 'O número que a lei controla é o do documento fiscal eletrônico — a NF-e de mercadorias, a NFS-e de serviços —, gerado pelo sistema emissor e válido somente depois de recebido, validado e autorizado pela administração tributária (Lei Complementar nº 214, de 2025, art. 62, II). Ekwo não emite esse documento: o número que este pacote declara é o da peça contábil, uma referência interna ao lançamento que remete ao documento fiscal autorizado, e por isso livre — veja «O documento fiscal eletrônico» no README',
  numbering_source_key          = 'lc-214',
  payment_terms_legal_reference = null,
  payment_terms_source_key      = null,
  tax_point_rule                = 'invoice_date',
  tax_point_legal_reference     = 'Lei Complementar nº 123, de 2006, art. 18, § 3º — sobre a receita bruta auferida no mês incide a alíquota efetiva; a receita entra no período de apuração do mês da operação, que é o da data do documento. A opção irretratável, para todo o ano-calendário, de tributar a receita recebida no mês (regime de caixa) não é modelada — veja o README',
  tax_point_source_key          = 'lc-123',
  posted_edit_policy            = 'reversal_only',
  posted_edit_policy_legal_reference = 'Código Civil, art. 1.183 — a escrituração é feita por ordem cronológica, sem intervalos em branco, nem entrelinhas, borrões, rasuras, emendas ou transportes para as margens. Um documento contabilizado é anulado por um documento de devolução ou cancelamento que o nomeia, nunca devolvido a rascunho',
  posted_edit_policy_source_key = 'codigo-civil',
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_legal_reference      = 'Toda venda de mercadorias é acobertada por uma Nota Fiscal Eletrônica (NF-e, modelo 55) e toda prestação de serviços sujeita ao ISS por uma Nota Fiscal de Serviços Eletrônica (NFS-e), que os Municípios e o Distrito Federal devem, a partir de 1º de janeiro de 2026, autorizar no padrão nacional (Lei Complementar nº 214, de 2025, art. 62, § 1º). O documento só existe depois de recebido, validado e autorizado pelo sistema autorizador da administração tributária (art. 62, II): um regime de validação prévia (clearance), e não uma troca direta entre as partes. A empresa optante pelo Simples Nacional está sujeita aos mesmos documentos. Ekwo não gera, não assina e não transmite o XML de uma NF-e ou de uma NFS-e: nenhuma peça de packages/formats fala com uma Secretaria da Fazenda nem com o Ambiente de Dados Nacional, e o bloco `fiscalisation.clearance` exige um `format` que uma peça escreva, o que não existe para o Brasil. Por isso profile, mandatory_from e fiscalisation ficam vazios, embora a obrigação exista nos fatos — veja o README. O CNPJ identifica emitente e destinatário e não tem um código ISO 6523 próprio: party_scheme e vat_scheme ficam vazios, como nos pacotes do México e da Guatemala',
  einvoice_source_key           = 'lc-214',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_account_scheme           = 'account-number',
  bank_statement_formats        = null,
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'BR';

insert into legal_mention_templates
  (country, code, applies_when, text, text_i18n, sequence, valid_from, valid_to, legal_reference)
values
  ('BR', 'dfe_not_issued', 'always', 'Este documento não é um documento fiscal eletrônico (NF-e ou NFS-e): não foi autorizado pela administração tributária. Somente o documento fiscal autorizado ampara a operação para fins fiscais.', '{"en":"This document is not an electronic tax document (NF-e or NFS-e): it has not been authorised by the tax administration. Only the authorised tax document supports the transaction for tax purposes."}'::jsonb, 10, date '1970-01-01', null, 'Lei Complementar nº 214, de 2025, art. 62, II — os documentos fiscais eletrônicos existem após a recepção, a validação e a autorização pelo sistema autorizador; Ekwo não gera, não assina e não transmite NF-e nem NFS-e')
on conflict (country, code) do update set
  applies_when    = excluded.applies_when,
  text            = excluded.text,
  text_i18n       = excluded.text_i18n,
  sequence        = excluded.sequence,
  valid_from      = excluded.valid_from,
  valid_to        = excluded.valid_to,
  legal_reference = excluded.legal_reference;
