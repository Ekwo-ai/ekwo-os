-- Ekwo OS — currencies. ISO 4217 list one, the currencies the packs keep their
-- books in.
--
-- Generated from packs/*/reference.json, do not edit. A country declares its
-- currency in its own folder and runs `ekwo pack build`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of the packs, and the CI runs it.
-- Who declares which row is written in packages/cli/src/pack/reference.ts.
--
-- A currency nobody corrects is inserted once and left alone: on conflict, the
-- row an installation already has is kept.

-- The code and the decimals are those of ISO 4217 list one, as SIX
-- Financial Information publishes it on behalf of the maintenance agency
-- (https://www.six-group.com/dam/download/financial-information/data-center/iso-currrency/lists/list-one.xml,
-- edition of 17 September 2026). Both CFA francs, the Comorian franc and the
-- Guinean franc have no minor unit there; the Congolese franc has two.

insert into currencies (code, name, symbol, decimal_places) values
  -- packs/generic/reference.json
  ('EUR', 'Euro', '€', 2),
  ('XOF', 'CFA franc BCEAO', 'F CFA', 0),
  ('XAF', 'CFA franc BEAC', 'F CFA', 0),
  ('XCD', 'East Caribbean dollar', 'EC$', 2),
  -- packs/ae/reference.json
  ('AED', 'UAE dirham', 'د.إ', 2),
  -- packs/al/reference.json
  ('ALL', 'Albanian lek', 'L', 2),
  -- packs/am/reference.json
  ('AMD', 'Armenian dram', '֏', 2),
  -- packs/ao/reference.json
  ('AOA', 'Angolan kwanza', 'Kz', 2),
  -- packs/ar/reference.json
  ('ARS', 'Argentine peso', '$', 2),
  -- packs/au/reference.json
  ('AUD', 'Australian dollar', '$', 2),
  -- packs/az/reference.json
  ('AZN', 'Azerbaijani manat', '₼', 2),
  -- packs/ba/reference.json
  ('BAM', 'Convertible mark', 'KM', 2),
  -- packs/bb/reference.json
  ('BBD', 'Barbadian dollar', 'Bds$', 2),
  -- packs/bd/reference.json
  ('BDT', 'Bangladeshi taka', '৳', 2),
  -- packs/bh/reference.json
  ('BHD', 'Bahraini dinar', '.د.ب', 3),
  -- packs/bi/reference.json
  -- Burundi franc, no minor unit in use (ISO 4217 lists zero decimals), packs/bi/.
  ('BIF', 'Burundi franc', 'FBu', 0),
  -- packs/bm/reference.json
  ('BMD', 'Bermudian dollar', '$', 2),
  -- packs/bn/reference.json
  ('BND', 'Brunei dollar', 'B$', 2),
  -- packs/bo/reference.json
  ('BOB', 'Bolivian boliviano', 'Bs', 2),
  -- packs/br/reference.json
  -- Brazilian real, ISO 4217 list one, two decimals (packs/br/).
  ('BRL', 'Brazilian real', 'R$', 2),
  -- packs/bs/reference.json
  ('BSD', 'Bahamian dollar', 'B$', 2),
  -- packs/bt/reference.json
  -- Bhutanese ngultrum, ISO 4217 list one, two decimals (packs/bt/).
  ('BTN', 'Bhutanese ngultrum', 'Nu.', 2),
  -- packs/bw/reference.json
  ('BWP', 'Botswana pula', 'P', 2),
  -- packs/ca/reference.json
  ('CAD', 'Canadian dollar', '$', 2),
  -- packs/cd/reference.json
  ('CDF', 'Congolese franc', 'FC', 2),
  -- packs/ch/reference.json
  ('CHF', 'Swiss franc', 'CHF', 2),
  -- packs/cl/reference.json
  ('CLP', 'Chilean peso', '$', 0),
  -- packs/cn/reference.json
  ('CNY', 'Chinese yuan', '¥', 2),
  -- packs/co/reference.json
  ('COP', 'Colombian peso', '$', 2),
  -- packs/cr/reference.json
  ('CRC', 'Costa Rican colón', '₡', 2),
  -- packs/cv/reference.json
  -- Cape Verdean escudo, packs/cv/.
  ('CVE', 'Cape Verdean escudo', 'Esc', 2),
  -- packs/cz/reference.json
  ('CZK', 'Czech koruna', 'Kč', 2),
  -- packs/dj/reference.json
  -- Djibouti franc, no minor unit in use (ISO 4217 lists zero decimals), packs/dj/.
  ('DJF', 'Djibouti franc', 'Fdj', 0),
  -- packs/dk/reference.json
  ('DKK', 'Danish krone', 'kr', 2),
  -- packs/do/reference.json
  ('DOP', 'Dominican peso', 'RD$', 2),
  -- packs/dz/reference.json
  ('DZD', 'Algerian dinar', 'د.ج', 2),
  -- packs/eg/reference.json
  ('EGP', 'Egyptian pound', 'ج.م', 2),
  -- packs/et/reference.json
  ('ETB', 'Ethiopian birr', 'Br', 2),
  -- packs/fj/reference.json
  -- Fijian dollar, ISO 4217 list one, two decimals (packs/fj/).
  ('FJD', 'Fijian dollar', 'FJ$', 2),
  -- packs/gb/reference.json
  ('GBP', 'Pound sterling', '£', 2),
  -- packs/ge/reference.json
  ('GEL', 'Georgian lari', '₾', 2),
  -- packs/gh/reference.json
  ('GHS', 'Ghanaian cedi', 'GH₵', 2),
  -- packs/gm/reference.json
  ('GMD', 'Gambian dalasi', 'D', 2),
  -- packs/gn/reference.json
  ('GNF', 'Guinean franc', 'FG', 0),
  -- packs/gt/reference.json
  ('GTQ', 'Guatemalan quetzal', 'Q', 2),
  -- packs/gy/reference.json
  ('GYD', 'Guyanese dollar', 'G$', 2),
  -- packs/hk/reference.json
  ('HKD', 'Hong Kong dollar', 'HK$', 2),
  -- packs/hn/reference.json
  ('HNL', 'Honduran lempira', 'L', 2),
  -- packs/hu/reference.json
  ('HUF', 'Hungarian forint', 'Ft', 2),
  -- packs/id/reference.json
  ('IDR', 'Indonesian rupiah', 'Rp', 0),
  -- packs/il/reference.json
  ('ILS', 'Israeli new shekel', '₪', 2),
  -- packs/in/reference.json
  ('INR', 'Indian rupee', '₹', 2),
  -- packs/is/reference.json
  ('ISK', 'Icelandic krona', 'kr', 0),
  -- packs/jm/reference.json
  ('JMD', 'Jamaican dollar', 'J$', 2),
  -- packs/jo/reference.json
  -- Jordanian dinar, three decimals (the fils), packs/jo/.
  ('JOD', 'Jordanian dinar', 'JD', 3),
  -- packs/jp/reference.json
  ('JPY', 'Japanese yen', '¥', 0),
  -- packs/ke/reference.json
  ('KES', 'Kenyan shilling', 'KSh', 2),
  -- packs/kg/reference.json
  ('KGS', 'Kyrgyzstani som', 'сом', 2),
  -- packs/kh/reference.json
  -- Cambodian riel, ISO 4217 list one, no minor unit (packs/kh/).
  ('KHR', 'Cambodian riel', '៛', 0),
  -- packs/km/reference.json
  ('KMF', 'Comorian franc', 'CF', 0),
  -- packs/kr/reference.json
  ('KRW', 'South Korean won', '₩', 0),
  -- packs/kw/reference.json
  ('KWD', 'Kuwaiti dinar', 'د.ك', 3),
  -- packs/ky/reference.json
  ('KYD', 'Cayman Islands dollar', 'CI$', 2),
  -- packs/kz/reference.json
  ('KZT', 'Kazakhstani tenge', '₸', 2),
  -- packs/la/reference.json
  -- Lao kip, no minor unit in use (as the dong and the won), packs/la/.
  ('LAK', 'Lao kip', '₭', 0),
  -- packs/lk/reference.json
  ('LKR', 'Sri Lankan rupee', 'Rs', 2),
  -- packs/ls/reference.json
  ('LSL', 'Lesotho loti', 'L', 2),
  -- packs/ma/reference.json
  ('MAD', 'Moroccan dirham', 'د.م.', 2),
  -- packs/md/reference.json
  ('MDL', 'Moldovan leu', 'L', 2),
  -- packs/mg/reference.json
  -- Malagasy ariary, ISO 4217 list one, two decimals (packs/mg/).
  ('MGA', 'Malagasy ariary', 'Ar', 2),
  -- packs/mk/reference.json
  ('MKD', 'Macedonian denar', 'ден.', 2),
  -- packs/mn/reference.json
  -- Mongolian tugrik, ISO 4217 list one, two decimals (packs/mn/).
  ('MNT', 'Mongolian tugrik', '₮', 2),
  -- packs/mo/reference.json
  ('MOP', 'Macanese pataca', 'MOP$', 2),
  -- packs/mr/reference.json
  -- Mauritanian ouguiya (MRU, since 2018, one tenth of the former MRO), ISO 4217 list one, two decimals (packs/mr/).
  ('MRU', 'Mauritanian ouguiya', 'UM', 2),
  -- packs/mu/reference.json
  ('MUR', 'Mauritian rupee', 'Rs', 2),
  -- packs/mw/reference.json
  -- Malawian kwacha, two decimals, packs/mw/.
  ('MWK', 'Malawian kwacha', 'MK', 2),
  -- packs/mx/reference.json
  ('MXN', 'Mexican peso', '$', 2),
  -- packs/my/reference.json
  ('MYR', 'Malaysian ringgit', 'RM', 2),
  -- packs/mz/reference.json
  ('MZN', 'Mozambican metical', 'MT', 2),
  -- packs/na/reference.json
  ('NAD', 'Namibia dollar', 'N$', 2),
  -- packs/ng/reference.json
  ('NGN', 'Nigerian naira', '₦', 2),
  -- packs/ni/reference.json
  ('NIO', 'Nicaraguan córdoba', 'C$', 2),
  -- packs/no/reference.json
  ('NOK', 'Norwegian krone', 'kr', 2),
  -- packs/np/reference.json
  -- Nepalese rupee, ISO 4217 list one, two decimals (packs/np/).
  ('NPR', 'Nepalese rupee', 'Rs', 2),
  -- packs/nz/reference.json
  ('NZD', 'New Zealand dollar', '$', 2),
  -- packs/om/reference.json
  ('OMR', 'Omani rial', 'ر.ع.', 3),
  -- packs/pe/reference.json
  ('PEN', 'Peruvian sol', 'S/', 2),
  -- packs/pg/reference.json
  -- Papua New Guinean kina, ISO 4217 list one, two decimals (packs/pg/).
  ('PGK', 'Papua New Guinean kina', 'K', 2),
  -- packs/ph/reference.json
  ('PHP', 'Philippine peso', '₱', 2),
  -- packs/pk/reference.json
  ('PKR', 'Pakistani rupee', '₨', 2),
  -- packs/pl/reference.json
  ('PLN', 'Polish zloty', 'zł', 2),
  -- packs/py/reference.json
  ('PYG', 'Paraguayan guaraní', '₲', 0),
  -- packs/qa/reference.json
  ('QAR', 'Qatari riyal', 'QR', 2),
  -- packs/ro/reference.json
  ('RON', 'Romanian leu', 'lei', 2),
  -- packs/rs/reference.json
  ('RSD', 'Serbian dinar', 'дин.', 2),
  -- packs/rw/reference.json
  ('RWF', 'Rwandan franc', 'FRw', 0),
  -- packs/sa/reference.json
  ('SAR', 'Saudi riyal', 'ر.س', 2),
  -- packs/sb/reference.json
  -- Solomon Islands dollar, ISO 4217 list one, two decimals (packs/sb/).
  ('SBD', 'Solomon Islands dollar', 'SI$', 2),
  -- packs/sc/reference.json
  -- Seychelles rupee, ISO 4217 list one, two decimals (packs/sc/).
  ('SCR', 'Seychelles rupee', 'SR', 2),
  -- packs/se/reference.json
  ('SEK', 'Swedish krona', 'kr', 2),
  -- packs/sg/reference.json
  ('SGD', 'Singapore dollar', '$', 2),
  -- packs/sl/reference.json
  ('SLE', 'Sierra Leonean leone', 'Le', 2),
  -- packs/sr/reference.json
  ('SRD', 'Surinamese dollar', 'Sr$', 2),
  -- packs/sz/reference.json
  ('SZL', 'Swazi lilangeni', 'E', 2),
  -- packs/th/reference.json
  ('THB', 'Thai baht', '฿', 2),
  -- packs/tj/reference.json
  -- Tajikistani somoni, ISO 4217 list one, two decimals (packs/tj/).
  ('TJS', 'Tajikistani somoni', 'сомонӣ', 2),
  -- packs/tm/reference.json
  -- Turkmen manat, ISO 4217 list one, two decimals (packs/tm/).
  ('TMT', 'Turkmen manat', 'm', 2),
  -- packs/tn/reference.json
  ('TND', 'Tunisian dinar', 'د.ت', 3),
  -- packs/to/reference.json
  -- Tongan paʻanga, ISO 4217 list one, two decimals (packs/to/).
  ('TOP', 'Tongan paʻanga', 'T$', 2),
  -- packs/tr/reference.json
  ('TRY', 'Turkish lira', '₺', 2),
  -- packs/tt/reference.json
  ('TTD', 'Trinidad and Tobago dollar', 'TT$', 2),
  -- packs/tw/reference.json
  ('TWD', 'New Taiwan dollar', 'NT$', 2),
  -- packs/tz/reference.json
  ('TZS', 'Tanzanian shilling', 'TSh', 2),
  -- packs/ua/reference.json
  ('UAH', 'Ukrainian hryvnia', '₴', 2),
  -- packs/ug/reference.json
  ('UGX', 'Uganda shilling', 'USh', 0),
  -- packs/us/reference.json
  ('USD', 'US dollar', '$', 2),
  -- packs/uy/reference.json
  ('UYU', 'Uruguayan peso', '$U', 2),
  -- packs/uz/reference.json
  -- Uzbekistani som, ISO 4217 list one, two decimals (packs/uz/).
  ('UZS', 'Uzbekistani som', 'so''m', 2),
  -- packs/vn/reference.json
  ('VND', 'Vietnamese dong', '₫', 0),
  -- packs/vu/reference.json
  -- Vanuatu vatu, ISO 4217 list one, no decimals (packs/vu/).
  ('VUV', 'Vanuatu vatu', 'VT', 0),
  -- packs/ws/reference.json
  -- Samoan tala, ISO 4217 list one, two decimals (packs/ws/).
  ('WST', 'Samoan tala', 'WS$', 2),
  -- packs/za/reference.json
  ('ZAR', 'South African rand', 'R', 2),
  -- packs/zm/reference.json
  ('ZMW', 'Zambian kwacha', 'K', 2),
  -- packs/zw/reference.json
  ('ZWG', 'Zimbabwe Gold', 'ZiG', 2)
on conflict (code) do nothing;
