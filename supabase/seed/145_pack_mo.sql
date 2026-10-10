-- Ekwo OS — 澳門: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/mo at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build mo`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Lei n.º 24/2024 — Código Fiscal (Fiscal Code) (Direcção dos Serviços de Assuntos de Justiça — Boletim Oficial da RAEM)
--     https://bo.dsaj.gov.mo/bo/i/2024/53/lei24.asp
--   The Fiscal Code has fully entered into force (7 January 2026) (Macao SAR Government Information Bureau)
--     https://www.gov.mo/pt/noticias/809035/
--   Lei n.º 13/2025 — Budget Law of the Macao SAR for 2026 (Direcção dos Serviços de Assuntos de Justiça — Boletim Oficial da RAEM)
--     https://bo.dsaj.gov.mo/bo/i/2025/52/lei13.asp
--   Decreto-Lei n.º 40/99/M — Código Comercial (Commercial Code) (Direcção dos Serviços de Assuntos de Justiça — Boletim Oficial da RAEM)
--     https://bo.dsaj.gov.mo/bo/i/99/31/codcompt/codcom0001.asp
--   Lei n.º 4/99/M — Regulamento do Imposto de Consumo (Consumption Tax Regulation) (Direcção dos Serviços de Assuntos de Justiça — Boletim Oficial da RAEM)
--     https://bo.dsaj.gov.mo/bo/i/99/50/lei04.asp
--   Regulamento Administrativo n.º 25/2005 — Normas de Contabilidade (Accounting Standards) (Direcção dos Serviços de Assuntos de Justiça — Boletim Oficial da RAEM)
--     https://bo.dsaj.gov.mo/bo/i/2005/52/regadm25.asp
--   Regulamento Administrativo n.º 42/2020 — Comissão Profissional dos Contabilistas (Direcção dos Serviços de Assuntos de Justiça — Boletim Oficial da RAEM)
--     https://bo.dsaj.gov.mo/bo/i/2020/48/regadm42.asp
--   Guia para a Aplicação das Normas Sucintas de Relato Financeiro (Aviso n.º 2/2024/CPC) (Comissão Profissional dos Contabilistas)
--     https://www.cpc.gov.mo/uploads/dsf/20241217/Guia%20Para%20a%20Aplica%C3%A7%C3%A3o%20das%20Normas%20Sucintas%20de%20Relato%20Financeiro.pdf
--   會計師專業委員會 2024 年度工作簡報 (Professional Accountants Committee 2024 work report) (Comissão Profissional dos Contabilistas)
--     https://www.cpc.gov.mo/uploads/dsf/20250210/004WEB2025_anexoC.pdf
--   Profits Tax (Complementary Tax) — Group A (Direcção dos Serviços de Finanças (Financial Services Bureau))
--     https://www.dsf.gov.mo/en/tax/tax_introduction/profits_tax_a
--   DSF electronic services (login) (Direcção dos Serviços de Finanças (Financial Services Bureau))
--     https://tax.fi.dsf.gov.mo/
--   Peppol Authorities (OpenPeppol)
--     https://peppol.org/about/peppol-authorities/
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('MO', '澳門', '0.1.0', date '2026-10-10', '20260917170000', 'community', null, null, '13d43070a021c70951974c4dff71ddc158f4950592231de9aebe84043edf9c1f', '[{"key":"cod-fiscal","title":"Lei n.º 24/2024 — Código Fiscal (Fiscal Code)","publisher":"Direcção dos Serviços de Assuntos de Justiça — Boletim Oficial da RAEM","url":"https://bo.dsaj.gov.mo/bo/i/2024/53/lei24.asp","consulted_on":"2026-10-10","kind":"law"},{"key":"cod-fiscal-news","title":"The Fiscal Code has fully entered into force (7 January 2026)","publisher":"Macao SAR Government Information Bureau","url":"https://www.gov.mo/pt/noticias/809035/","consulted_on":"2026-10-10","kind":"guidance"},{"key":"orcamento-2026","title":"Lei n.º 13/2025 — Budget Law of the Macao SAR for 2026","publisher":"Direcção dos Serviços de Assuntos de Justiça — Boletim Oficial da RAEM","url":"https://bo.dsaj.gov.mo/bo/i/2025/52/lei13.asp","consulted_on":"2026-10-10","kind":"law"},{"key":"cod-comercial","title":"Decreto-Lei n.º 40/99/M — Código Comercial (Commercial Code)","publisher":"Direcção dos Serviços de Assuntos de Justiça — Boletim Oficial da RAEM","url":"https://bo.dsaj.gov.mo/bo/i/99/31/codcompt/codcom0001.asp","consulted_on":"2026-10-10","kind":"law"},{"key":"imposto-consumo","title":"Lei n.º 4/99/M — Regulamento do Imposto de Consumo (Consumption Tax Regulation)","publisher":"Direcção dos Serviços de Assuntos de Justiça — Boletim Oficial da RAEM","url":"https://bo.dsaj.gov.mo/bo/i/99/50/lei04.asp","consulted_on":"2026-10-10","kind":"law"},{"key":"ra-25-2005","title":"Regulamento Administrativo n.º 25/2005 — Normas de Contabilidade (Accounting Standards)","publisher":"Direcção dos Serviços de Assuntos de Justiça — Boletim Oficial da RAEM","url":"https://bo.dsaj.gov.mo/bo/i/2005/52/regadm25.asp","consulted_on":"2026-10-10","kind":"regulation"},{"key":"ra-42-2020","title":"Regulamento Administrativo n.º 42/2020 — Comissão Profissional dos Contabilistas","publisher":"Direcção dos Serviços de Assuntos de Justiça — Boletim Oficial da RAEM","url":"https://bo.dsaj.gov.mo/bo/i/2020/48/regadm42.asp","consulted_on":"2026-10-10","kind":"regulation"},{"key":"cpc-nsrf-guide","title":"Guia para a Aplicação das Normas Sucintas de Relato Financeiro (Aviso n.º 2/2024/CPC)","publisher":"Comissão Profissional dos Contabilistas","url":"https://www.cpc.gov.mo/uploads/dsf/20241217/Guia%20Para%20a%20Aplica%C3%A7%C3%A3o%20das%20Normas%20Sucintas%20de%20Relato%20Financeiro.pdf","consulted_on":"2026-10-10","kind":"standard"},{"key":"cpc-report-2024","title":"會計師專業委員會 2024 年度工作簡報 (Professional Accountants Committee 2024 work report)","publisher":"Comissão Profissional dos Contabilistas","url":"https://www.cpc.gov.mo/uploads/dsf/20250210/004WEB2025_anexoC.pdf","consulted_on":"2026-10-10","kind":"guidance"},{"key":"dsf-profits-tax","title":"Profits Tax (Complementary Tax) — Group A","publisher":"Direcção dos Serviços de Finanças (Financial Services Bureau)","url":"https://www.dsf.gov.mo/en/tax/tax_introduction/profits_tax_a","consulted_on":"2026-10-10","kind":"guidance"},{"key":"dsf-eservices","title":"DSF electronic services (login)","publisher":"Direcção dos Serviços de Finanças (Financial Services Bureau)","url":"https://tax.fi.dsf.gov.mo/","consulted_on":"2026-10-10","kind":"portal"},{"key":"peppol-authorities","title":"Peppol Authorities","publisher":"OpenPeppol","url":"https://peppol.org/about/peppol-authorities/","consulted_on":"2026-10-10","kind":"guidance"}]'::jsonb)
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
  ('MO', 'default', '澳門參考會計科目表', '{"en":"Macao reference chart of accounts","pt":"Plano de contas de referência de Macau"}'::jsonb, true, 'companies', array['MO-NSRF-BS', 'MO-NSRF-IS']::text[], null, 'Macao prescribes no chart of accounts. The Código Comercial, article 38, obliges every commercial entrepreneur to keep mercantile accounts made in accordance with the law and adequate to its business, and article 46(2) lets them be kept in a language other than the official ones where there is serious interest, with values in any currency provided they are also stated in patacas; neither prescribes a chart. For tax, Regulamento Administrativo n.º 25/2005, article 7, defines ''properly organised accounts'' (contabilidade devidamente organizada) as accounts organised in accordance with the Accounting Standards — the Financial Reporting Standards or the General Financial Reporting Standards — and the Código Fiscal, article 97(2), presumes the declarations and the accounts of a taxpayer true when they are organised according to the accounting standards. This chart is original: four digits, blocked so that each range reaches one line of the balance sheet and the income statement of the General Financial Reporting Standards'' model financial statements, and it ties into the same statements for an entity reporting under the IFRS-based Financial Reporting Standards. It carries no tax-clearing account of any kind, because no tax is collected or paid on an invoice — see ''From Macao'' in docs/international.md.', 'cod-comercial')
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
  ('MO', 'default', '1000', '庫存現金', '{"en":"Cash on hand","pt":"Caixa"}'::jsonb, 'asset_cash', false, null, 10),
  ('MO', 'default', '1010', '銀行活期存款', '{"en":"Bank current account","pt":"Depósitos bancários à ordem"}'::jsonb, 'asset_cash', false, null, 20),
  ('MO', 'default', '1020', '銀行儲蓄存款', '{"en":"Bank savings account","pt":"Depósitos bancários de poupança"}'::jsonb, 'asset_cash', false, null, 30),
  ('MO', 'default', '1030', '外幣銀行存款', '{"en":"Foreign currency bank account","pt":"Depósitos bancários em moeda estrangeira"}'::jsonb, 'asset_cash', false, null, 40),
  ('MO', 'default', '1040', '支付平台及信用卡結算', '{"en":"Payment gateway and card clearing account","pt":"Plataforma de pagamentos e liquidação de cartões"}'::jsonb, 'asset_cash', false, null, 50),
  ('MO', 'default', '1050', '三個月內定期存款', '{"en":"Fixed deposits of three months or less","pt":"Depósitos a prazo até três meses"}'::jsonb, 'asset_cash', false, null, 60),
  ('MO', 'default', '1060', '在途現金', '{"en":"Cash in transit","pt":"Numerário em trânsito"}'::jsonb, 'asset_cash', false, null, 70),
  ('MO', 'default', '1100', '應收賬款', '{"en":"Trade debtors","pt":"Clientes"}'::jsonb, 'asset_receivable', true, null, 80),
  ('MO', 'default', '1105', '預期信用損失準備', '{"en":"Allowance for expected credit losses","pt":"Perdas esperadas de crédito"}'::jsonb, 'asset_current', false, null, 90),
  ('MO', 'default', '1110', '應收關聯公司款項', '{"en":"Amounts due from related companies","pt":"Valores a receber de empresas relacionadas"}'::jsonb, 'asset_current', false, null, 100),
  ('MO', 'default', '1120', '其他應收款', '{"en":"Other debtors","pt":"Outros devedores"}'::jsonb, 'asset_current', false, null, 110),
  ('MO', 'default', '1130', '應計收入', '{"en":"Accrued income","pt":"Rendimentos a receber"}'::jsonb, 'asset_current', false, null, 120),
  ('MO', 'default', '1140', '員工墊款及貸款', '{"en":"Staff advances and loans to employees","pt":"Adiantamentos e empréstimos ao pessoal"}'::jsonb, 'asset_current', false, null, 130),
  ('MO', 'default', '1150', '預繳稅款及印花稅', '{"en":"Prepaid taxes and stamp duty","pt":"Impostos e imposto do selo pagos antecipadamente"}'::jsonb, 'asset_current', false, null, 140),
  ('MO', 'default', '1160', '應收退還稅款', '{"en":"Taxes recoverable","pt":"Impostos a recuperar"}'::jsonb, 'asset_current', false, null, 150),
  ('MO', 'default', '1200', '存貨 — 原材料及消耗品', '{"en":"Inventory — raw materials and consumables","pt":"Inventários — matérias-primas e consumíveis"}'::jsonb, 'asset_current', false, null, 160),
  ('MO', 'default', '1210', '存貨 — 在製品', '{"en":"Inventory — work in progress","pt":"Inventários — produtos em curso"}'::jsonb, 'asset_current', false, null, 170),
  ('MO', 'default', '1220', '存貨 — 製成品及商品', '{"en":"Inventory — finished goods and goods for resale","pt":"Inventários — produtos acabados e mercadorias"}'::jsonb, 'asset_current', false, null, 180),
  ('MO', 'default', '1230', '在途貨物', '{"en":"Goods in transit","pt":"Mercadorias em trânsito"}'::jsonb, 'asset_current', false, null, 190),
  ('MO', 'default', '1300', '三個月以上定期存款', '{"en":"Fixed deposits of more than three months","pt":"Depósitos a prazo superiores a três meses"}'::jsonb, 'asset_current', false, null, 200),
  ('MO', 'default', '1310', '持作買賣的上市投資', '{"en":"Listed investments held for trading","pt":"Investimentos cotados detidos para negociação"}'::jsonb, 'asset_current', false, null, 210),
  ('MO', 'default', '1320', '應收關聯公司款項 — 非貿易', '{"en":"Amounts due from related companies — non-trade","pt":"Valores a receber de empresas relacionadas — não comerciais"}'::jsonb, 'asset_current', false, null, 220),
  ('MO', 'default', '1400', '預付費用', '{"en":"Prepaid expenses","pt":"Gastos diferidos"}'::jsonb, 'asset_prepayments', false, null, 230),
  ('MO', 'default', '1410', '已付租金及公用事業按金', '{"en":"Rental and utility deposits paid","pt":"Cauções de rendas e serviços públicos pagas"}'::jsonb, 'asset_prepayments', false, null, 240),
  ('MO', 'default', '1420', '已付供應商按金', '{"en":"Deposits paid to suppliers","pt":"Adiantamentos a fornecedores"}'::jsonb, 'asset_prepayments', false, null, 250),
  ('MO', 'default', '1600', '租賃土地及樓宇', '{"en":"Leasehold land and buildings","pt":"Terrenos e edifícios em regime de concessão ou arrendamento"}'::jsonb, 'asset_fixed', false, null, 260),
  ('MO', 'default', '1610', '租賃物業裝修', '{"en":"Leasehold improvements","pt":"Obras em edifícios arrendados"}'::jsonb, 'asset_fixed', false, null, 270),
  ('MO', 'default', '1620', '傢俬及固定裝置', '{"en":"Furniture and fixtures","pt":"Mobiliário e instalações"}'::jsonb, 'asset_fixed', false, null, 280),
  ('MO', 'default', '1630', '辦公設備', '{"en":"Office equipment","pt":"Equipamento de escritório"}'::jsonb, 'asset_fixed', false, null, 290),
  ('MO', 'default', '1640', '電腦設備及軟件', '{"en":"Computer equipment and software","pt":"Equipamento informático e programas"}'::jsonb, 'asset_fixed', false, null, 300),
  ('MO', 'default', '1650', '汽車', '{"en":"Motor vehicles","pt":"Viaturas"}'::jsonb, 'asset_fixed', false, null, 310),
  ('MO', 'default', '1660', '廠房及機器', '{"en":"Plant and machinery","pt":"Instalações e máquinas"}'::jsonb, 'asset_fixed', false, null, 320),
  ('MO', 'default', '1670', '使用權資產', '{"en":"Right-of-use assets","pt":"Activos sob direito de uso"}'::jsonb, 'asset_fixed', false, null, 330),
  ('MO', 'default', '1690', '累計折舊 — 物業、廠房及設備', '{"en":"Accumulated depreciation — property, plant and equipment","pt":"Depreciações acumuladas — activos fixos tangíveis"}'::jsonb, 'asset_fixed', false, null, 340),
  ('MO', 'default', '1695', '累計折舊 — 使用權資產', '{"en":"Accumulated depreciation — right-of-use assets","pt":"Depreciações acumuladas — activos sob direito de uso"}'::jsonb, 'asset_fixed', false, null, 350),
  ('MO', 'default', '1800', '商譽', '{"en":"Goodwill","pt":"Goodwill"}'::jsonb, 'asset_non_current', false, null, 360),
  ('MO', 'default', '1810', '其他無形資產', '{"en":"Other intangible assets","pt":"Outros activos intangíveis"}'::jsonb, 'asset_non_current', false, null, 370),
  ('MO', 'default', '1820', '累計攤銷 — 無形資產', '{"en":"Accumulated amortisation — intangible assets","pt":"Amortizações acumuladas — activos intangíveis"}'::jsonb, 'asset_non_current', false, null, 380),
  ('MO', 'default', '1900', '附屬公司投資', '{"en":"Investments in subsidiaries","pt":"Investimentos em subsidiárias"}'::jsonb, 'asset_non_current', false, null, 390),
  ('MO', 'default', '1910', '聯營公司投資', '{"en":"Investments in associates","pt":"Investimentos em associadas"}'::jsonb, 'asset_non_current', false, null, 400),
  ('MO', 'default', '1920', '其他長期投資', '{"en":"Other long-term investments","pt":"Outros investimentos de longo prazo"}'::jsonb, 'asset_non_current', false, null, 410),
  ('MO', 'default', '1930', '租金及公用事業按金 — 非流動', '{"en":"Rental and utility deposits — non-current","pt":"Cauções de rendas e serviços públicos — não correntes"}'::jsonb, 'asset_non_current', false, null, 420),
  ('MO', 'default', '1990', '遞延稅項資產', '{"en":"Deferred tax assets","pt":"Activos por impostos diferidos"}'::jsonb, 'asset_non_current', false, null, 430),
  ('MO', 'default', '2000', '應付賬款', '{"en":"Trade creditors","pt":"Fornecedores"}'::jsonb, 'liability_payable', true, null, 440),
  ('MO', 'default', '2010', '應付關聯公司款項', '{"en":"Amounts due to related companies","pt":"Valores a pagar a empresas relacionadas"}'::jsonb, 'liability_current', false, null, 450),
  ('MO', 'default', '2020', '應計費用', '{"en":"Accruals","pt":"Gastos a pagar"}'::jsonb, 'liability_current', false, null, 460),
  ('MO', 'default', '2030', '客戶按金及預收款項', '{"en":"Customer deposits and advances received","pt":"Adiantamentos de clientes"}'::jsonb, 'liability_current', false, null, 470),
  ('MO', 'default', '2040', '應付薪金及工資', '{"en":"Salaries and wages payable","pt":"Remunerações a pagar"}'::jsonb, 'liability_current', false, null, 480),
  ('MO', 'default', '2050', '應付社會保障供款', '{"en":"Social security contributions payable","pt":"Contribuições para a segurança social a pagar"}'::jsonb, 'liability_current', false, null, 490),
  ('MO', 'default', '2060', '所得補充稅準備', '{"en":"Provision for complementary tax","pt":"Provisão para imposto complementar de rendimentos"}'::jsonb, 'liability_current', false, null, 500),
  ('MO', 'default', '2070', '其他應付稅款及政府費用', '{"en":"Other taxes and government charges payable","pt":"Outros impostos e encargos públicos a pagar"}'::jsonb, 'liability_current', false, null, 510),
  ('MO', 'default', '2080', '租賃負債 — 流動部分', '{"en":"Lease liabilities — current portion","pt":"Passivos de locação — parte corrente"}'::jsonb, 'liability_current', false, null, 520),
  ('MO', 'default', '2090', '暫記賬戶', '{"en":"Suspense account","pt":"Conta transitória"}'::jsonb, 'liability_current', false, null, 530),
  ('MO', 'default', '2100', '銀行透支及短期借款', '{"en":"Bank overdrafts and short-term borrowings","pt":"Descobertos bancários e empréstimos de curto prazo"}'::jsonb, 'liability_current', false, null, 540),
  ('MO', 'default', '2200', '應付公司信用卡', '{"en":"Corporate credit card payable","pt":"Cartão de crédito da empresa a pagar"}'::jsonb, 'liability_credit_card', false, null, 550),
  ('MO', 'default', '2300', '銀行借款 — 非流動', '{"en":"Bank borrowings — non-current","pt":"Empréstimos bancários — não correntes"}'::jsonb, 'liability_non_current', false, null, 560),
  ('MO', 'default', '2310', '租賃負債 — 非流動', '{"en":"Lease liabilities — non-current","pt":"Passivos de locação — não correntes"}'::jsonb, 'liability_non_current', false, null, 570),
  ('MO', 'default', '2320', '應付股東款項 — 非流動', '{"en":"Amounts due to shareholders — non-current","pt":"Valores a pagar a accionistas ou sócios — não correntes"}'::jsonb, 'liability_non_current', false, null, 580),
  ('MO', 'default', '2390', '遞延稅項負債', '{"en":"Deferred tax liabilities","pt":"Passivos por impostos diferidos"}'::jsonb, 'liability_non_current', false, null, 590),
  ('MO', 'default', '3000', '已發行股本', '{"en":"Issued share capital","pt":"Capital social"}'::jsonb, 'equity', false, null, 600),
  ('MO', 'default', '3100', '股份溢價', '{"en":"Share premium","pt":"Prémios de emissão"}'::jsonb, 'equity', false, null, 610),
  ('MO', 'default', '3110', '法定公積金', '{"en":"Legal reserve","pt":"Reserva legal"}'::jsonb, 'equity', false, null, 620),
  ('MO', 'default', '3120', '其他儲備', '{"en":"Other reserves","pt":"Outras reservas"}'::jsonb, 'equity', false, null, 630),
  ('MO', 'default', '3200', '保留溢利', '{"en":"Retained profits","pt":"Resultados transitados"}'::jsonb, 'equity_retained', false, null, 640),
  ('MO', 'default', '4000', '銷售貨品', '{"en":"Sale of goods","pt":"Vendas de mercadorias e produtos"}'::jsonb, 'income', false, null, 650),
  ('MO', 'default', '4010', '提供服務', '{"en":"Rendering of services","pt":"Prestações de serviços"}'::jsonb, 'income', false, null, 660),
  ('MO', 'default', '4700', '已實現匯兌收益', '{"en":"Realised exchange gains","pt":"Ganhos cambiais realizados"}'::jsonb, 'income_other', false, null, 670),
  ('MO', 'default', '4710', '未實現匯兌收益', '{"en":"Unrealised exchange gains","pt":"Ganhos cambiais não realizados"}'::jsonb, 'income_other', false, null, 680),
  ('MO', 'default', '4720', '利息收入', '{"en":"Interest income","pt":"Juros obtidos"}'::jsonb, 'income_other', false, null, 690),
  ('MO', 'default', '4730', '雜項收入', '{"en":"Sundry income","pt":"Rendimentos diversos"}'::jsonb, 'income_other', false, null, 700),
  ('MO', 'default', '4740', '政府資助及補貼', '{"en":"Government grants and subsidies","pt":"Subsídios e apoios públicos"}'::jsonb, 'income_other', false, null, 710),
  ('MO', 'default', '4750', '出售固定資產收益', '{"en":"Gain on disposal of fixed assets","pt":"Ganhos na alienação de activos fixos"}'::jsonb, 'income_other', false, null, 720),
  ('MO', 'default', '5000', '銷售成本', '{"en":"Cost of goods sold","pt":"Custo das mercadorias vendidas"}'::jsonb, 'expense_direct_cost', false, null, 730),
  ('MO', 'default', '5010', '採購', '{"en":"Purchases","pt":"Compras"}'::jsonb, 'expense_direct_cost', false, null, 740),
  ('MO', 'default', '5020', '進貨運費', '{"en":"Freight inwards","pt":"Fretes de compras"}'::jsonb, 'expense_direct_cost', false, null, 750),
  ('MO', 'default', '5030', '直接人工', '{"en":"Direct labour","pt":"Mão-de-obra directa"}'::jsonb, 'expense_direct_cost', false, null, 760),
  ('MO', 'default', '6000', '董事酬金', '{"en":"Directors'' remuneration","pt":"Remunerações dos administradores e gerentes"}'::jsonb, 'expense', false, null, 770),
  ('MO', 'default', '6010', '員工薪金及工資', '{"en":"Staff salaries and wages","pt":"Remunerações do pessoal"}'::jsonb, 'expense', false, null, 780),
  ('MO', 'default', '6020', '社會保障供款', '{"en":"Social security contributions","pt":"Contribuições para a segurança social"}'::jsonb, 'expense', false, null, 790),
  ('MO', 'default', '6030', '員工福利', '{"en":"Staff welfare and benefits","pt":"Benefícios do pessoal"}'::jsonb, 'expense', false, null, 800),
  ('MO', 'default', '6100', '租金及差餉', '{"en":"Rent and rates","pt":"Rendas e alugueres"}'::jsonb, 'expense', false, null, 810),
  ('MO', 'default', '6110', '管理費及樓宇支出', '{"en":"Management fees and building outgoings","pt":"Condomínio e encargos do edifício"}'::jsonb, 'expense', false, null, 820),
  ('MO', 'default', '6115', '房屋稅', '{"en":"Urban property tax","pt":"Contribuição predial urbana"}'::jsonb, 'expense', false, null, 830),
  ('MO', 'default', '6120', '水電費', '{"en":"Utilities","pt":"Água, electricidade e outros serviços"}'::jsonb, 'expense', false, null, 840),
  ('MO', 'default', '6200', '商業登記及牌照費', '{"en":"Business registration and licence fees","pt":"Registo comercial e licenças"}'::jsonb, 'expense', false, null, 850),
  ('MO', 'default', '6205', '營業稅及印花稅', '{"en":"Business tax and stamp duty","pt":"Contribuição industrial e imposto do selo"}'::jsonb, 'expense', false, null, 860),
  ('MO', 'default', '6210', '核數師酬金', '{"en":"Auditor''s remuneration","pt":"Honorários de auditoria"}'::jsonb, 'expense', false, null, 870),
  ('MO', 'default', '6220', '會計及公司秘書費', '{"en":"Accounting and company secretarial fees","pt":"Honorários de contabilidade e secretariado societário"}'::jsonb, 'expense', false, null, 880),
  ('MO', 'default', '6230', '法律及專業費用', '{"en":"Legal and professional fees","pt":"Honorários jurídicos e profissionais"}'::jsonb, 'expense', false, null, 890),
  ('MO', 'default', '6300', '維修及保養', '{"en":"Repairs and maintenance","pt":"Reparações e manutenção"}'::jsonb, 'expense', false, null, 900),
  ('MO', 'default', '6310', '保險費', '{"en":"Insurance","pt":"Seguros"}'::jsonb, 'expense', false, null, 910),
  ('MO', 'default', '6320', '汽車費用', '{"en":"Motor vehicle expenses","pt":"Gastos com viaturas"}'::jsonb, 'expense', false, null, 920),
  ('MO', 'default', '6330', '差旅費', '{"en":"Travelling expenses","pt":"Deslocações e estadas"}'::jsonb, 'expense', false, null, 930),
  ('MO', 'default', '6340', '交際費', '{"en":"Entertainment expenses","pt":"Despesas de representação"}'::jsonb, 'expense', false, null, 940),
  ('MO', 'default', '6350', '廣告及宣傳費', '{"en":"Advertising and promotion","pt":"Publicidade e propaganda"}'::jsonb, 'expense', false, null, 950),
  ('MO', 'default', '6360', '印刷、文具及郵費', '{"en":"Printing, stationery and postage","pt":"Impressos, material de escritório e correio"}'::jsonb, 'expense', false, null, 960),
  ('MO', 'default', '6370', '電訊費', '{"en":"Telecommunications","pt":"Comunicações"}'::jsonb, 'expense', false, null, 970),
  ('MO', 'default', '6380', '銀行手續費', '{"en":"Bank charges","pt":"Encargos bancários"}'::jsonb, 'expense', false, null, 980),
  ('MO', 'default', '6390', '雜項辦公費用', '{"en":"Sundry office expenses","pt":"Gastos gerais de escritório"}'::jsonb, 'expense', false, null, 990),
  ('MO', 'default', '6400', '預期信用損失準備支出', '{"en":"Allowance for expected credit losses charged","pt":"Perdas esperadas de crédito do período"}'::jsonb, 'expense', false, null, 1000),
  ('MO', 'default', '6410', '銀行借款利息支出', '{"en":"Interest expense on bank borrowings","pt":"Juros de empréstimos bancários"}'::jsonb, 'expense', false, null, 1010),
  ('MO', 'default', '6420', '租賃負債利息支出', '{"en":"Interest expense on lease liabilities","pt":"Juros de passivos de locação"}'::jsonb, 'expense', false, null, 1020),
  ('MO', 'default', '6450', '已實現匯兌虧損', '{"en":"Realised exchange losses","pt":"Perdas cambiais realizadas"}'::jsonb, 'expense', false, null, 1030),
  ('MO', 'default', '6455', '未實現匯兌虧損', '{"en":"Unrealised exchange losses","pt":"Perdas cambiais não realizadas"}'::jsonb, 'expense', false, null, 1040),
  ('MO', 'default', '6460', '出售固定資產虧損', '{"en":"Loss on disposal of fixed assets","pt":"Perdas na alienação de activos fixos"}'::jsonb, 'expense', false, null, 1050),
  ('MO', 'default', '6470', '所得補充稅支出', '{"en":"Complementary tax charge","pt":"Gasto com imposto complementar de rendimentos"}'::jsonb, 'expense', false, null, 1060),
  ('MO', 'default', '6480', '遞延稅項支出', '{"en":"Deferred tax charge","pt":"Gasto com impostos diferidos"}'::jsonb, 'expense', false, null, 1070),
  ('MO', 'default', '6490', '湊整差額', '{"en":"Rounding differences","pt":"Diferenças de arredondamento"}'::jsonb, 'expense', false, null, 1080),
  ('MO', 'default', '6800', '折舊及攤銷', '{"en":"Depreciation and amortisation","pt":"Depreciações e amortizações"}'::jsonb, 'expense_depreciation', false, null, 1090)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('MO', 'BNK', '銀行', '{"en":"Bank","pt":"Banco"}'::jsonb, 'bank', 30),
  ('MO', 'CSH', '備用現金', '{"en":"Petty cash","pt":"Caixa"}'::jsonb, 'cash', 40),
  ('MO', 'GEN', '普通日記賬', '{"en":"General journal","pt":"Diário geral"}'::jsonb, 'general', 50),
  ('MO', 'OPN', '期初餘額', '{"en":"Opening balances","pt":"Abertura"}'::jsonb, 'opening', 60),
  ('MO', 'PUR', '採購日記賬', '{"en":"Purchases journal","pt":"Diário de compras"}'::jsonb, 'purchase', 20),
  ('MO', 'SAL', '銷售日記賬', '{"en":"Sales journal","pt":"Diário de vendas"}'::jsonb, 'sales', 10)
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
  ('MO', 'MO-P-NA', '購貨，不課徵任何營業額稅', '{"en":"Purchase, not subject to any tax on turnover","pt":"Compra, não sujeita a qualquer imposto sobre o volume de negócios"}'::jsonb, '澳門企業的所有購貨 — 本地採購、進口，以及自境外運往境外的採購', 'percent', 0, 'purchase', 'not_subject', date '1999-12-20', null, 'The purchase side of MO-S-NA: nothing a Macao business buys carries a value added tax, goods and services tax or general sales tax to recover, because none is charged on the sale that supplies it, whether the seller is in Macao or abroad. The only indirect levy on goods is the consumption tax of Lei n.º 4/99/M, charged on the products of its table when they are produced in or enter the territory — spirits of 30 % alcohol or more (10 % ad valorem on the CIF value plus MOP 20 per litre) and tobacco (specific amounts per unit or kilogram), as the table stands after Lei n.º 8/2008, Lei n.º 7/2009, Lei n.º 11/2011 and Lei n.º 9/2015. It is a duty on those specific goods that the importer or producer pays, not a general tax any invoice line can carry a code for, and this pack does not model it. Customs duties are not modelled either (secondary sources describe Macao as a free port that levies none on imports; the primary text was not opened). See ''From Macao'' in docs/international.md.', 'O', null, 20, 'other', true, '{}'::tax_condition[], null, false, false, null, 'imposto-consumo', null, null, null, null),
  ('MO', 'MO-S-NA', '銷售，不課徵任何營業額稅', '{"en":"Sale, not subject to any tax on turnover","pt":"Venda, não sujeita a qualquer imposto sobre o volume de negócios"}'::jsonb, '澳門企業的所有銷售 — 本地銷售、出口，以及自境外運往境外的銷售', 'percent', 0, 'sale', 'not_subject', date '1999-12-20', null, 'Macao levies no value added tax, goods and services tax or general sales tax, and this was re-checked on 10 October 2026. The Código Fiscal (Lei n.º 24/2024, published in Boletim Oficial n.º 53/2024 and in force since 1 January 2026, per its article on entry into force and the Government''s announcement of 7 January 2026) brings together the territory''s tax laws, and the taxes it lists as related legislation are the industrial contribution (Lei n.º 15/77/M), professional tax (Lei n.º 2/78/M), urban property contribution (Lei n.º 19/78/M), complementary income tax (Lei n.º 21/78/M), stamp tax (Lei n.º 17/88/M), property transfer and inheritance taxes, tourism tax (Lei n.º 19/96/M), consumption tax (Lei n.º 4/99/M) and motor vehicle tax — none of them a tax on turnover. What a Macao business pays on its trading is, instead, complementary income tax (called Profits Tax on the Financial Services Bureau''s English pages) on a year''s net profit, assessed once for the whole business — not a tax any invoice carries, collects on the seller''s behalf or is credited against on the buyer''s. The consumption tax is selective and falls on the product at import or production, not on the sale: its table, as amended, reaches only spirits of 30 % alcohol or more and tobacco (the beer and wine group and the fuel group have no product subject to it). There is accordingly no rate for this code to state and no box for its base: the code exists so that every sale line still carries a tax code the engine can post, and states plainly that this jurisdiction has none. 20 December 1999 is the establishment of the Special Administrative Region and is a convenience for `valid_from`, not a claim about when the absence of a turnover tax began. See ''From Macao'' in docs/international.md.', 'O', null, 10, 'other', true, '{}'::tax_condition[], null, false, false, null, 'cod-fiscal', null, null, null, null)
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
    ('MO-P-NA', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('MO-P-NA', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('MO-S-NA', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('MO-S-NA', 'credit_note', 'base', 100, null, null, null, 100, null, 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'MO' and t.code = v.tax_code
on conflict (tax_template_id, document_kind, posting_type, sequence) do update set
  factor_percent     = excluded.factor_percent,
  account_code       = excluded.account_code,
  declaration_box    = excluded.declaration_box,
  declaration_boxes  = excluded.declaration_boxes,
  box_factor_percent = excluded.box_factor_percent,
  report_code        = excluded.report_code;

insert into statement_templates
  (code, country, chart_code, name, kind, framework, valid_from, valid_to, legal_reference,
   source_key)
values
  ('MO-NSRF-BS', 'MO', 'default', '資產負債表', 'balance_sheet', 'NSRF', date '1970-01-01', null, 'Regulamento Administrativo n.º 25/2005, article 1(4) and article 2(4), approves the Accounting Standards (Normas de Contabilidade) with, as their accounting statements, the balance sheet and the income statement (balanço, demonstração de resultados) — the two statements this file carries. The General Financial Reporting Standards (一般財務報告準則, Normas Sucintas de Relato Financeiro, NSRF) are the framework of every entity the Financial Reporting Standards (IFRS) do not reach: article 4(1) of the same regulation lists the entities that must apply the IFRS-based Financial Reporting Standards (concessionaires, insurers, institutions under the financial-system regime, offshore institutions, public limited companies and partnerships limited by shares), and article 4(2) lets an entity that is bound by special law to keep properly organised accounts choose, for each whole financial year, between the two. Regulamento Administrativo n.º 42/2020, article 25, revoked that regulation but keeps it applicable until the Professional Accountants Committee approves new Accounting Standards (article 25(2)). The Committee republished the NSRF unchanged by Aviso n.º 2/2024/CPC (adopted 18 December 2024; the Financial Reporting Standards move to the 2021 IFRS suite, optional from 1 January 2026 and mandatory from 1 January 2028, per the Committee''s 2024 work report). The line structure below follows the model financial statements of the Committee''s ''Guia para a Aplicação das Normas Sucintas de Relato Financeiro'': non-current assets (tangible, intangible, long-term investments), current assets (inventories, trade and other receivables, prepayments, cash), equity (capital, legal reserves, other reserves, retained results) and non-current and current liabilities (bank borrowings, lease obligations, trade and other payables, amounts due to shareholders and related parties, income tax, short-term borrowings and overdrafts). One deviation: the model shows the current year''s result inside retained results, whereas this pack keeps it on its own line until it is allocated. The ranges each line reads are original to this pack: Macao publishes no chart of accounts, so there is no legal code to group by. An entity under the IFRS-based Financial Reporting Standards presents more (a statement of comprehensive income, a cash-flow statement, extensive notes) than these two statements: see README.md.', null),
  ('MO-NSRF-IS', 'MO', 'default', '損益表', 'income_statement', 'NSRF', date '1970-01-01', null, 'Regulamento Administrativo n.º 25/2005, article 2(4): the accounting statements are the balance sheet and the income statement (demonstração de resultados). The line structure follows the model income statement of the Professional Accountants Committee''s ''Guia para a Aplicação das Normas Sucintas de Relato Financeiro'' (Aviso n.º 2/2024/CPC): revenue, cost of sales, gross profit, other operating income, personnel expenses, depreciation and amortisation, other operating expenses, operating profit, finance costs, investment income, other income, profit before tax, income tax, profit for the period. Foreign-exchange gains are read as other income and foreign-exchange losses as finance costs, the usual reading of the model''s lines for a business with no separate exchange line; a Macao accountant should confirm it. The numbering is this pack''s own.', null)
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
  ('MO-NSRF-BS', 'A-NC-FIX', 'A-NC', '固定資產', '{"en":"Property, plant and equipment","pt":"Activos fixos tangíveis"}'::jsonb, 10, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MO-NSRF-BS', 'A-NC-INT', 'A-NC', '無形資產', '{"en":"Intangible assets","pt":"Activos intangíveis"}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MO-NSRF-BS', 'A-NC-INV', 'A-NC', '長期投資及其他非流動資產', '{"en":"Long-term investments and other non-current assets","pt":"Investimentos de longo prazo e outros activos não correntes"}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MO-NSRF-BS', 'A-NC', null, '非流動資產', '{"en":"Non-current assets","pt":"Activos não correntes"}'::jsonb, 40, 1, true, array['A-NC-FIX', 'A-NC-INT', 'A-NC-INV']::text[], '{}'::text[], null, null, null),
  ('MO-NSRF-BS', 'A-C-INV', 'A-C', '存貨', '{"en":"Inventories","pt":"Inventários"}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MO-NSRF-BS', 'A-C-REC', 'A-C', '應收賬款及其他應收款', '{"en":"Trade and other receivables","pt":"Dívidas a receber comerciais e outras"}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MO-NSRF-BS', 'A-C-PRE', 'A-C', '預付款項', '{"en":"Prepayments","pt":"Pré-pagamentos"}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MO-NSRF-BS', 'A-C-CASH', 'A-C', '現金及現金等價物', '{"en":"Cash and cash equivalents","pt":"Caixa e equivalentes de caixa"}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MO-NSRF-BS', 'A-C', null, '流動資產', '{"en":"Current assets","pt":"Activos correntes"}'::jsonb, 90, 1, true, array['A-C-INV', 'A-C-REC', 'A-C-PRE', 'A-C-CASH']::text[], '{}'::text[], null, null, null),
  ('MO-NSRF-BS', 'A-TOT', null, '資產總額', '{"en":"Total assets","pt":"Total dos activos"}'::jsonb, 100, 1, true, array['A-NC', 'A-C']::text[], '{}'::text[], null, null, null),
  ('MO-NSRF-BS', 'E-CAP', 'E-TOT', '股本', '{"en":"Share capital","pt":"Capital"}'::jsonb, 110, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MO-NSRF-BS', 'E-LEG', 'E-TOT', '法定公積金', '{"en":"Legal reserve","pt":"Reservas legais"}'::jsonb, 120, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MO-NSRF-BS', 'E-OTH', 'E-TOT', '其他儲備', '{"en":"Other reserves","pt":"Outras reservas"}'::jsonb, 130, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MO-NSRF-BS', 'E-RET', 'E-TOT', '保留溢利', '{"en":"Retained profits","pt":"Resultados acumulados transitados"}'::jsonb, 140, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MO-NSRF-BS', 'E-RESULT', 'E-TOT', '本年度溢利或虧損（尚未分配）', '{"en":"Profit or loss for the year, not yet allocated","pt":"Resultado do período, ainda não afectado"}'::jsonb, 150, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MO-NSRF-BS', 'E-TOT', null, '權益總額', '{"en":"Total equity","pt":"Total dos capitais próprios"}'::jsonb, 160, 1, true, array['E-CAP', 'E-LEG', 'E-OTH', 'E-RET', 'E-RESULT']::text[], '{}'::text[], null, null, null),
  ('MO-NSRF-BS', 'L-NC-BANK', 'L-NC', '銀行借款', '{"en":"Bank borrowings","pt":"Empréstimos bancários"}'::jsonb, 170, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MO-NSRF-BS', 'L-NC-LEASE', 'L-NC', '租賃負債', '{"en":"Lease liabilities","pt":"Obrigações de locações"}'::jsonb, 180, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MO-NSRF-BS', 'L-NC-OTH', 'L-NC', '其他非流動負債', '{"en":"Other non-current liabilities","pt":"Outros passivos não correntes"}'::jsonb, 190, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MO-NSRF-BS', 'L-NC', null, '非流動負債', '{"en":"Non-current liabilities","pt":"Passivos não correntes"}'::jsonb, 200, 1, true, array['L-NC-BANK', 'L-NC-LEASE', 'L-NC-OTH']::text[], '{}'::text[], null, null, null),
  ('MO-NSRF-BS', 'L-C-PAY', 'L-C', '應付賬款及其他應付款', '{"en":"Trade and other payables","pt":"Dívidas a pagar comerciais e outras"}'::jsonb, 210, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MO-NSRF-BS', 'L-C-REL', 'L-C', '應付股東及關聯方款項', '{"en":"Amounts due to shareholders and related parties","pt":"Dívidas a accionistas e a partes relacionadas"}'::jsonb, 220, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MO-NSRF-BS', 'L-C-TAX', 'L-C', '所得稅', '{"en":"Income tax","pt":"Imposto sobre o rendimento"}'::jsonb, 230, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MO-NSRF-BS', 'L-C-BORR', 'L-C', '短期借款及銀行透支', '{"en":"Short-term borrowings and bank overdrafts","pt":"Empréstimos de curto prazo e descobertos bancários"}'::jsonb, 240, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MO-NSRF-BS', 'L-C-LEASE', 'L-C', '租賃負債', '{"en":"Lease liabilities","pt":"Obrigações de locações"}'::jsonb, 250, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MO-NSRF-BS', 'L-C-OTH', 'L-C', '其他流動負債', '{"en":"Other current liabilities","pt":"Outros passivos correntes"}'::jsonb, 260, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MO-NSRF-BS', 'L-C', null, '流動負債', '{"en":"Current liabilities","pt":"Passivos correntes"}'::jsonb, 270, 1, true, array['L-C-PAY', 'L-C-REL', 'L-C-TAX', 'L-C-BORR', 'L-C-LEASE', 'L-C-OTH']::text[], '{}'::text[], null, null, null),
  ('MO-NSRF-BS', 'L-TOT', null, '負債總額', '{"en":"Total liabilities","pt":"Total dos passivos"}'::jsonb, 280, 1, true, array['L-NC', 'L-C']::text[], '{}'::text[], null, null, null),
  ('MO-NSRF-BS', 'EL-TOT', null, '權益及負債總額', '{"en":"Total equity and liabilities","pt":"Total dos capitais próprios e passivos"}'::jsonb, 290, 1, true, array['E-TOT', 'L-TOT']::text[], '{}'::text[], null, null, null),
  ('MO-NSRF-IS', 'REV', null, '收益', '{"en":"Revenue","pt":"Réditos"}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MO-NSRF-IS', 'COST', null, '銷售成本', '{"en":"Cost of sales","pt":"Custo de vendas"}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MO-NSRF-IS', 'GROSS', null, '毛利', '{"en":"Gross profit","pt":"Lucro bruto"}'::jsonb, 30, 1, true, array['REV']::text[], array['COST']::text[], null, null, null),
  ('MO-NSRF-IS', 'OTH-OPI', null, '其他營運收入', '{"en":"Other operating income","pt":"Outros proveitos operacionais"}'::jsonb, 40, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MO-NSRF-IS', 'PERS', null, '員工費用', '{"en":"Personnel expenses","pt":"Gastos com o pessoal"}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MO-NSRF-IS', 'DEPR', null, '折舊及攤銷', '{"en":"Depreciation and amortisation","pt":"Gastos de depreciação e amortização"}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MO-NSRF-IS', 'OTH-OPX', null, '其他營運費用', '{"en":"Other operating expenses","pt":"Outros gastos operacionais"}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MO-NSRF-IS', 'OP', null, '營運溢利', '{"en":"Operating profit","pt":"Lucro operacional"}'::jsonb, 80, 1, true, array['GROSS', 'OTH-OPI']::text[], array['PERS', 'DEPR', 'OTH-OPX']::text[], null, null, null),
  ('MO-NSRF-IS', 'FIN-EXP', null, '融資成本', '{"en":"Finance costs","pt":"Gastos financeiros"}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MO-NSRF-IS', 'INV-INC', null, '投資收入', '{"en":"Investment income","pt":"Rendimento de investimento"}'::jsonb, 100, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MO-NSRF-IS', 'OTH-INC', null, '其他收入', '{"en":"Other income","pt":"Outros rendimentos"}'::jsonb, 110, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MO-NSRF-IS', 'PBT', null, '除稅前溢利', '{"en":"Profit before tax","pt":"Resultado antes de impostos"}'::jsonb, 120, 1, true, array['OP', 'INV-INC', 'OTH-INC']::text[], array['FIN-EXP']::text[], null, null, null),
  ('MO-NSRF-IS', 'TAX', null, '所得稅', '{"en":"Income tax","pt":"Imposto sobre rendimentos"}'::jsonb, 130, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MO-NSRF-IS', 'PROFIT', null, '本年度溢利（虧損）', '{"en":"Profit (loss) for the year","pt":"Resultado do período"}'::jsonb, 140, 1, true, array['PBT']::text[], array['TAX']::text[], null, null, null)
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
    ('MO-NSRF-BS', 'A-NC-FIX', 10, 'code_range', '1600', '1799', null, 'any'),
    ('MO-NSRF-BS', 'A-NC-INT', 10, 'code_range', '1800', '1899', null, 'any'),
    ('MO-NSRF-BS', 'A-NC-INV', 10, 'code_range', '1900', '1999', null, 'any'),
    ('MO-NSRF-BS', 'A-C-INV', 10, 'code_range', '1200', '1299', null, 'any'),
    ('MO-NSRF-BS', 'A-C-REC', 10, 'code_range', '1100', '1199', null, 'any'),
    ('MO-NSRF-BS', 'A-C-REC', 20, 'code_range', '1300', '1399', null, 'any'),
    ('MO-NSRF-BS', 'A-C-PRE', 10, 'code_range', '1400', '1499', null, 'any'),
    ('MO-NSRF-BS', 'A-C-CASH', 10, 'code_range', '1000', '1099', null, 'any'),
    ('MO-NSRF-BS', 'E-CAP', 10, 'code_range', '3000', '3099', null, 'any'),
    ('MO-NSRF-BS', 'E-LEG', 10, 'code_range', '3110', '3119', null, 'any'),
    ('MO-NSRF-BS', 'E-OTH', 10, 'code_range', '3100', '3109', null, 'any'),
    ('MO-NSRF-BS', 'E-OTH', 20, 'code_range', '3120', '3199', null, 'any'),
    ('MO-NSRF-BS', 'E-RET', 10, 'code_range', '3200', '3299', null, 'any'),
    ('MO-NSRF-BS', 'E-RESULT', 10, 'code_range', '4000', '4799', null, 'any'),
    ('MO-NSRF-BS', 'E-RESULT', 20, 'code_range', '5000', '5099', null, 'any'),
    ('MO-NSRF-BS', 'E-RESULT', 30, 'code_range', '6000', '6899', null, 'any'),
    ('MO-NSRF-BS', 'L-NC-BANK', 10, 'code_range', '2300', '2309', null, 'any'),
    ('MO-NSRF-BS', 'L-NC-LEASE', 10, 'code_range', '2310', '2319', null, 'any'),
    ('MO-NSRF-BS', 'L-NC-OTH', 10, 'code_range', '2320', '2399', null, 'any'),
    ('MO-NSRF-BS', 'L-C-PAY', 10, 'code_range', '2000', '2009', null, 'any'),
    ('MO-NSRF-BS', 'L-C-PAY', 20, 'code_range', '2020', '2059', null, 'any'),
    ('MO-NSRF-BS', 'L-C-REL', 10, 'code_range', '2010', '2019', null, 'any'),
    ('MO-NSRF-BS', 'L-C-TAX', 10, 'code_range', '2060', '2069', null, 'any'),
    ('MO-NSRF-BS', 'L-C-BORR', 10, 'code_range', '2100', '2199', null, 'any'),
    ('MO-NSRF-BS', 'L-C-LEASE', 10, 'code_range', '2080', '2089', null, 'any'),
    ('MO-NSRF-BS', 'L-C-OTH', 10, 'code_range', '2070', '2079', null, 'any'),
    ('MO-NSRF-BS', 'L-C-OTH', 20, 'code_range', '2090', '2099', null, 'any'),
    ('MO-NSRF-BS', 'L-C-OTH', 30, 'code_range', '2200', '2299', null, 'any'),
    ('MO-NSRF-IS', 'REV', 10, 'code_range', '4000', '4699', null, 'any'),
    ('MO-NSRF-IS', 'COST', 10, 'code_range', '5000', '5099', null, 'any'),
    ('MO-NSRF-IS', 'OTH-OPI', 10, 'code_range', '4730', '4799', null, 'any'),
    ('MO-NSRF-IS', 'PERS', 10, 'code_range', '6000', '6099', null, 'any'),
    ('MO-NSRF-IS', 'DEPR', 10, 'code_range', '6800', '6899', null, 'any'),
    ('MO-NSRF-IS', 'OTH-OPX', 10, 'code_range', '6100', '6409', null, 'any'),
    ('MO-NSRF-IS', 'OTH-OPX', 20, 'code_range', '6460', '6469', null, 'any'),
    ('MO-NSRF-IS', 'OTH-OPX', 30, 'code_range', '6490', '6499', null, 'any'),
    ('MO-NSRF-IS', 'FIN-EXP', 10, 'code_range', '6410', '6459', null, 'any'),
    ('MO-NSRF-IS', 'INV-INC', 10, 'code_range', '4720', '4729', null, 'any'),
    ('MO-NSRF-IS', 'OTH-INC', 10, 'code_range', '4700', '4719', null, 'any'),
    ('MO-NSRF-IS', 'TAX', 10, 'code_range', '6470', '6489', null, 'any')
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
  ('MO', '澳門', '{"en":"Macao","pt":"Macau"}'::jsonb, array['zh', 'pt', 'en']::text[], 'MOP', '1100', '2000', '2090', '6490', '3200', '4000', '5010', '1010', '1000', 'SAL', 'PUR', 'GEN', 'zh', 'retained_earnings', null, null, null, 'OPN', 'half_up', default, '4700', '6450', '4750', '6460', null, null, null, null, null, null)
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
  number_format                 = '{CODE}-{YYYY}-{NNNN}',
  legal_payment_days            = null,
  late_payment_reference        = null,
  numbering_legal_reference     = 'Macao has no value added tax, goods and services tax or general sales tax (see MO-S-NA), so no tax statute conditions the deductibility of anything on an invoice carrying a sequential number, and no text consulted for this pack prescribes how a commercial invoice is numbered. What the law does require is a bookkeeping: the commercial entrepreneur must keep mercantile accounts, made in accordance with the law and adequate to the business, that allow all its operations and its financial position and performance to be known (Código Comercial, article 38), every ledger being kept clearly, in chronological order, without blanks, interpolations or erasures (article 46(1)); and the Código Fiscal lists among the accessory obligations of a taxpayer the holding, writing up and keeping of the books of account and of other tax-relevant books and documents, including financial statements, contracts and invoices (article 36(2)(2)). `numbering` is therefore `free`, not a gap left for someone else to fill: `number_format` is a convention this pack proposes. No text about invoice content (a taxpayer number, a mandatory mention) was found in the sources opened; if one exists, it is a gap of this pack, see ''From Macao'' in docs/international.md.',
  numbering_source_key          = 'cod-comercial',
  payment_terms_legal_reference = 'No text consulted for this pack sets a payment term between two businesses in the absence of an agreement, or a rate of interest on a commercial debt paid late: the Código Comercial and the Código Fiscal were searched for the bookkeeping and tax provisions this pack needs, and the general rules of Macao''s civil and commercial law on default interest were not read. `legal_payment_days` and `late_payment_reference` are therefore empty — a gap of research, not a statement that none exists — and a seller''s own terms are a matter of contract, stated on the document. See ''From Macao'' in docs/international.md.',
  payment_terms_source_key      = 'cod-comercial',
  tax_point_rule                = 'invoice_date',
  tax_point_legal_reference     = 'This field has nothing to describe in Macao: it names the day a country''s general rule makes its own turnover tax chargeable, and Macao charges none (see MO-S-NA). `invoice_date` is declared as the closest general commercial convention — revenue is ordinarily invoiced at or shortly after the point the accounting standards recognise it — and not as a rule read from a text; see ''From Macao'' in docs/international.md, which sets this out as a gap in what the field can honestly say of a territory with no transaction tax at all.',
  tax_point_source_key          = 'cpc-nsrf-guide',
  posted_edit_policy            = null,
  posted_edit_policy_legal_reference = null,
  posted_edit_policy_source_key = null,
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_obligation           = 'none',
  einvoice_legal_reference      = 'No text consulted for this pack obliges a business in Macao to issue or accept an electronic invoice — the Código Fiscal''s accessory obligations (article 36(2)) speak of invoices without prescribing a format, and no mandate was found — and no Peppol Authority is listed for Macao: OpenPeppol''s list of Peppol Authorities (consulted 10 October 2026) names, in the Asia-Pacific region, Australia, Japan, Malaysia, New Zealand, Singapore and Taiwan, and not Macao. `profile`, `party_scheme` and `vat_scheme` are therefore null: there is no domestic profile to name, and no VAT identifier for a scheme to carry since Macao levies no value added tax.',
  einvoice_source_key           = 'peppol-authorities',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = null,
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'MO';
