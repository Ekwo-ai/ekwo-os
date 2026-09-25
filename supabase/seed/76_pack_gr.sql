-- Ekwo OS — Ελλάδα: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/gr at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build gr`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Νόμος 5144/2024 — Κώδικας Φόρου Προστιθέμενης Αξίας, κωδικοποίηση σε ενιαίο κείμενο (έως 31.12.2024) (Ανεξάρτητη Αρχή Δημοσίων Εσόδων (ΑΑΔΕ))
--     https://www.aade.gr/sites/default/files/2025-05/kodikas_fpa_n.5144_2024%20kodikopoiisi_eniaio_keimeno%20@%20eos%2031.12.2024_0.pdf
--   Νόμος 5144/2024 — Κώδικας Φόρου Προστιθέμενης Αξίας, κείμενο όπως ψηφίστηκε (ΦΕΚ Α' 162/11.10.2024· αντικατέστησε τον Ν.2859/2000) (Ανεξάρτητη Αρχή Δημοσίων Εσόδων (ΑΑΔΕ))
--     https://www.aade.gr/sites/default/files/2024-10/kodikas_fpa.pdf
--   Παράρτημα ΙΙΙ του Κώδικα ΦΠΑ (Ν.5144/2024) — αγαθά και υπηρεσίες υποκείμενα στον μειωμένο και υπερμειωμένο συντελεστή, έκδοση 13 (Ανεξάρτητη Αρχή Δημοσίων Εσόδων (ΑΑΔΕ))
--     https://www.aade.gr/sites/default/files/2025-12/parartima-III-ekdosi13.pdf
--   Εγκύκλιος Ε.2113/31.12.2025 — εφαρμογή του μειωμένου κατά 30% συντελεστή ΦΠΑ (άρθρο 26 του Κώδικα ΦΠΑ, όπως τροποποιήθηκε με τον Ν.5246/2025) σε νησιά του Ανατολικού και Βόρειου Αιγαίου (Ανεξάρτητη Αρχή Δημοσίων Εσόδων (ΑΑΔΕ))
--     https://www.aade.gr/egkyklioi-kai-apofaseis/e-2113-31-12-2025
--   Εγκύκλιος Ε.2071/26.08.2025 — Οδηγίες συμπλήρωσης της δήλωσης ΦΠΑ (έντυπο 050 Φ.Π.Α., έκδοση 2025 — Φ2 TAXISnet), για πράξεις από 1.7.2025 (Ανεξάρτητη Αρχή Δημοσίων Εσόδων (ΑΑΔΕ))
--     https://www.aade.gr/egkyklioi-kai-apofaseis/e-2071-26-08-2025
--   Δήλωση Φ.Π.Α. — περιγραφή διαδικασίας, περιοδικότητα και προθεσμία υποβολής (Εθνικό Μητρώο Διοικητικών Διαδικασιών "Μίτος" — Υπουργείο Ψηφιακής Διακυβέρνησης)
--     https://mitos.gov.gr/index.php/%CE%94%CE%94:%CE%94%CE%AE%CE%BB%CF%89%CF%83%CE%B7_%CE%A6%CE%A0%CE%91
--   Απόφαση Διοικητή ΑΑΔΕ Α.1138/12.06.2020 (ΦΕΚ Β' 2470/22.06.2020) — πλαίσιο, χρόνος και διαδικασία διαβίβασης δεδομένων στην ΑΑΔΕ, ψηφιακά βιβλία myDATA, κατ' εφαρμογή του άρθρου 15Α του Ν.4174/2013 (Ανεξάρτητη Αρχή Δημοσίων Εσόδων (ΑΑΔΕ))
--     https://www.aade.gr/egkyklioi-kai-apofaseis/mydata-diataxeis/1138-12-06-2020
--   myDATA — Ψηφιακά Βιβλία ΑΑΔΕ (Ανεξάρτητη Αρχή Δημοσίων Εσόδων (ΑΑΔΕ))
--     https://mydata.aade.gr
--   Council Implementing Decision (EU) 2025/502 of 5 March 2025 authorising Greece to introduce a special measure derogating from Articles 218 and 232 of Directive 2006/112/EC — mandatory electronic invoicing, from 1 July 2025 (Publications Office of the European Union — Official Journal (EUR-Lex))
--     https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=OJ:L_202500502
--   Νόμος 5222/2025 (ΦΕΚ Α' 134/28.07.2025), άρθρο 239 — προσθήκη παρ. 6 στο άρθρο 14 του Ν.4308/2014: υποχρέωση έκδοσης ηλεκτρονικού τιμολογίου (Ανεξάρτητη Αρχή Δημοσίων Εσόδων (ΑΑΔΕ) / Εθνικό Τυπογραφείο)
--     https://www.aade.gr/sites/default/files/2025-09/a1128_2025fek.pdf
--   Απόφαση Διοικητή ΑΑΔΕ Α.1128/2025 (ΦΕΚ Β' 4937/16.09.2025) — πλαίσιο, χρόνος και διαδικασία υποχρεωτικής έκδοσης ηλεκτρονικού τιμολογίου κατ' εφαρμογή της παρ. 6 του άρθρου 14 του Ν.4308/2014, όπως προστέθηκε με το άρθρο 239 του Ν.5222/2025 (Ανεξάρτητη Αρχή Δημοσίων Εσόδων (ΑΑΔΕ))
--     https://www.aade.gr/sites/default/files/2025-09/a1128_2025fek.pdf
--   Τιμολόγιο — εφαρμογή έκδοσης ηλεκτρονικών παραστατικών της ΑΑΔΕ, μέσω myDATA ή παρόχου ηλεκτρονικής τιμολόγησης (Ανεξάρτητη Αρχή Δημοσίων Εσόδων (ΑΑΔΕ))
--     https://www.aade.gr/timologio
--   Νόμος 4152/2013, Υποπαράγραφος Ζ — Προσαρμογή της ελληνικής νομοθεσίας στην Οδηγία 2011/7/ΕΕ για την καταπολέμηση των καθυστερήσεων πληρωμών στις εμπορικές συναλλαγές (κωδικοποιημένο κείμενο) (Ανεξάρτητη Αρχή Δημοσίων Εσόδων (ΑΑΔΕ))
--     https://www.aade.gr/sites/default/files/2020-02/%CE%9D4152_13_%CE%9A%CE%A9%CE%94%CE%99%CE%9A%CE%9F%CE%A0%CE%9F%CE%99%CE%97%CE%9C%CE%95%CE%9D%CE%9F%CE%A3.pdf
--   Νόμος 4308/2014 — Ελληνικά Λογιστικά Πρότυπα (ΕΛΠ), συναφείς ρυθμίσεις και άλλες διατάξεις, με τα Παραρτήματα Α (ορισμοί), Β (υποδείγματα χρηματοοικονομικών καταστάσεων) και Γ (σχέδιο λογαριασμών) (Υπουργείο Εθνικής Οικονομίας και Οικονομικών)
--     https://minfin.gov.gr/wp-content/uploads/2024/02/%CE%9D-4308-2014.pdf
--   ΣΛΟΤ, αριθμ. πρωτ. 2334 ΕΞ/13.9.2022 — Υποχρεωτικότητα χρήσης του σχεδίου λογαριασμών του Ν.4308/2014: η αρίθμηση δεν είναι υποχρεωτική, μόνον η ονοματολογία, ο βαθμός ανάλυσης και το περιεχόμενο του Παραρτήματος Γ (Επιτροπή Λογιστικής Τυποποίησης και Ελέγχων (ΕΛΤΕ) — Συμβούλιο Λογιστικής Τυποποίησης (ΣΛΟΤ))
--     https://elte.org.gr/2022/09/22/slot-arithm-prot-2334-ex-13-9-2022/
--   EN 16931-1 — the semantic data model of the core elements of an electronic invoice, and the conformity Directive 2014/55/EU requires (European Commission)
--     https://ec.europa.eu/digital-building-blocks/sites/spaces/DIGITAL/pages/467108950/EN+16931+compliance
--   UNCL5305 — VAT category code list (BT-118 and BT-151), the subset published for EN 16931 (OpenPEPPOL — list published by the European Commission)
--     https://docs.peppol.eu/poacc/billing/3.0/codelist/UNCL5305/
--   VATEX — VAT exemption reason code list (BT-121) (OpenPEPPOL — list published by the European Commission)
--     https://docs.peppol.eu/poacc/billing/3.0/codelist/vatex/
--   myAADE — ηλεκτρονικές υπηρεσίες της Ανεξάρτητης Αρχής Δημοσίων Εσόδων, κατάθεση δηλώσεων ΦΠΑ (TAXISnet) (Ανεξάρτητη Αρχή Δημοσίων Εσόδων (ΑΑΔΕ))
--     https://www.aade.gr
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('GR', 'Ελλάδα', '0.1.0', date '2026-09-25', '20260921145425', 'community', null, null, 'af10966f1e387e5ce67df2b58415b4a001759a47a75656b4be33979f64125161', '[{"key":"n5144-2024","title":"Νόμος 5144/2024 — Κώδικας Φόρου Προστιθέμενης Αξίας, κωδικοποίηση σε ενιαίο κείμενο (έως 31.12.2024)","publisher":"Ανεξάρτητη Αρχή Δημοσίων Εσόδων (ΑΑΔΕ)","url":"https://www.aade.gr/sites/default/files/2025-05/kodikas_fpa_n.5144_2024%20kodikopoiisi_eniaio_keimeno%20@%20eos%2031.12.2024_0.pdf","consulted_on":"2026-09-25","kind":"law"},{"key":"n5144-2024-fek","title":"Νόμος 5144/2024 — Κώδικας Φόρου Προστιθέμενης Αξίας, κείμενο όπως ψηφίστηκε (ΦΕΚ Α'' 162/11.10.2024· αντικατέστησε τον Ν.2859/2000)","publisher":"Ανεξάρτητη Αρχή Δημοσίων Εσόδων (ΑΑΔΕ)","url":"https://www.aade.gr/sites/default/files/2024-10/kodikas_fpa.pdf","consulted_on":"2026-09-25","kind":"law"},{"key":"n5144-2024-parartima-iii","title":"Παράρτημα ΙΙΙ του Κώδικα ΦΠΑ (Ν.5144/2024) — αγαθά και υπηρεσίες υποκείμενα στον μειωμένο και υπερμειωμένο συντελεστή, έκδοση 13","publisher":"Ανεξάρτητη Αρχή Δημοσίων Εσόδων (ΑΑΔΕ)","url":"https://www.aade.gr/sites/default/files/2025-12/parartima-III-ekdosi13.pdf","consulted_on":"2026-09-25","kind":"law"},{"key":"e2113-2025","title":"Εγκύκλιος Ε.2113/31.12.2025 — εφαρμογή του μειωμένου κατά 30% συντελεστή ΦΠΑ (άρθρο 26 του Κώδικα ΦΠΑ, όπως τροποποιήθηκε με τον Ν.5246/2025) σε νησιά του Ανατολικού και Βόρειου Αιγαίου","publisher":"Ανεξάρτητη Αρχή Δημοσίων Εσόδων (ΑΑΔΕ)","url":"https://www.aade.gr/egkyklioi-kai-apofaseis/e-2113-31-12-2025","consulted_on":"2026-09-25","kind":"guidance"},{"key":"e2071-2025","title":"Εγκύκλιος Ε.2071/26.08.2025 — Οδηγίες συμπλήρωσης της δήλωσης ΦΠΑ (έντυπο 050 Φ.Π.Α., έκδοση 2025 — Φ2 TAXISnet), για πράξεις από 1.7.2025","publisher":"Ανεξάρτητη Αρχή Δημοσίων Εσόδων (ΑΑΔΕ)","url":"https://www.aade.gr/egkyklioi-kai-apofaseis/e-2071-26-08-2025","consulted_on":"2026-09-25","kind":"form"},{"key":"mitos-dilosi-fpa","title":"Δήλωση Φ.Π.Α. — περιγραφή διαδικασίας, περιοδικότητα και προθεσμία υποβολής","publisher":"Εθνικό Μητρώο Διοικητικών Διαδικασιών \"Μίτος\" — Υπουργείο Ψηφιακής Διακυβέρνησης","url":"https://mitos.gov.gr/index.php/%CE%94%CE%94:%CE%94%CE%AE%CE%BB%CF%89%CF%83%CE%B7_%CE%A6%CE%A0%CE%91","consulted_on":"2026-09-25","kind":"guidance"},{"key":"mydata-a1138-2020","title":"Απόφαση Διοικητή ΑΑΔΕ Α.1138/12.06.2020 (ΦΕΚ Β'' 2470/22.06.2020) — πλαίσιο, χρόνος και διαδικασία διαβίβασης δεδομένων στην ΑΑΔΕ, ψηφιακά βιβλία myDATA, κατ'' εφαρμογή του άρθρου 15Α του Ν.4174/2013","publisher":"Ανεξάρτητη Αρχή Δημοσίων Εσόδων (ΑΑΔΕ)","url":"https://www.aade.gr/egkyklioi-kai-apofaseis/mydata-diataxeis/1138-12-06-2020","consulted_on":"2026-09-25","kind":"regulation"},{"key":"mydata-portal","title":"myDATA — Ψηφιακά Βιβλία ΑΑΔΕ","publisher":"Ανεξάρτητη Αρχή Δημοσίων Εσόδων (ΑΑΔΕ)","url":"https://mydata.aade.gr","consulted_on":"2026-09-25","kind":"portal"},{"key":"b2b-einvoicing-derogation","title":"Council Implementing Decision (EU) 2025/502 of 5 March 2025 authorising Greece to introduce a special measure derogating from Articles 218 and 232 of Directive 2006/112/EC — mandatory electronic invoicing, from 1 July 2025","publisher":"Publications Office of the European Union — Official Journal (EUR-Lex)","url":"https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=OJ:L_202500502","consulted_on":"2026-09-25","kind":"law"},{"key":"n5222-2025","title":"Νόμος 5222/2025 (ΦΕΚ Α'' 134/28.07.2025), άρθρο 239 — προσθήκη παρ. 6 στο άρθρο 14 του Ν.4308/2014: υποχρέωση έκδοσης ηλεκτρονικού τιμολογίου","publisher":"Ανεξάρτητη Αρχή Δημοσίων Εσόδων (ΑΑΔΕ) / Εθνικό Τυπογραφείο","url":"https://www.aade.gr/sites/default/files/2025-09/a1128_2025fek.pdf","consulted_on":"2026-09-25","kind":"law"},{"key":"a1128-2025","title":"Απόφαση Διοικητή ΑΑΔΕ Α.1128/2025 (ΦΕΚ Β'' 4937/16.09.2025) — πλαίσιο, χρόνος και διαδικασία υποχρεωτικής έκδοσης ηλεκτρονικού τιμολογίου κατ'' εφαρμογή της παρ. 6 του άρθρου 14 του Ν.4308/2014, όπως προστέθηκε με το άρθρο 239 του Ν.5222/2025","publisher":"Ανεξάρτητη Αρχή Δημοσίων Εσόδων (ΑΑΔΕ)","url":"https://www.aade.gr/sites/default/files/2025-09/a1128_2025fek.pdf","consulted_on":"2026-09-25","kind":"regulation"},{"key":"timologio-portal","title":"Τιμολόγιο — εφαρμογή έκδοσης ηλεκτρονικών παραστατικών της ΑΑΔΕ, μέσω myDATA ή παρόχου ηλεκτρονικής τιμολόγησης","publisher":"Ανεξάρτητη Αρχή Δημοσίων Εσόδων (ΑΑΔΕ)","url":"https://www.aade.gr/timologio","consulted_on":"2026-09-25","kind":"portal"},{"key":"n4152-2013","title":"Νόμος 4152/2013, Υποπαράγραφος Ζ — Προσαρμογή της ελληνικής νομοθεσίας στην Οδηγία 2011/7/ΕΕ για την καταπολέμηση των καθυστερήσεων πληρωμών στις εμπορικές συναλλαγές (κωδικοποιημένο κείμενο)","publisher":"Ανεξάρτητη Αρχή Δημοσίων Εσόδων (ΑΑΔΕ)","url":"https://www.aade.gr/sites/default/files/2020-02/%CE%9D4152_13_%CE%9A%CE%A9%CE%94%CE%99%CE%9A%CE%9F%CE%A0%CE%9F%CE%99%CE%97%CE%9C%CE%95%CE%9D%CE%9F%CE%A3.pdf","consulted_on":"2026-09-25","kind":"law"},{"key":"n4308-2014","title":"Νόμος 4308/2014 — Ελληνικά Λογιστικά Πρότυπα (ΕΛΠ), συναφείς ρυθμίσεις και άλλες διατάξεις, με τα Παραρτήματα Α (ορισμοί), Β (υποδείγματα χρηματοοικονομικών καταστάσεων) και Γ (σχέδιο λογαριασμών)","publisher":"Υπουργείο Εθνικής Οικονομίας και Οικονομικών","url":"https://minfin.gov.gr/wp-content/uploads/2024/02/%CE%9D-4308-2014.pdf","consulted_on":"2026-09-25","kind":"law"},{"key":"slot-2334-2022","title":"ΣΛΟΤ, αριθμ. πρωτ. 2334 ΕΞ/13.9.2022 — Υποχρεωτικότητα χρήσης του σχεδίου λογαριασμών του Ν.4308/2014: η αρίθμηση δεν είναι υποχρεωτική, μόνον η ονοματολογία, ο βαθμός ανάλυσης και το περιεχόμενο του Παραρτήματος Γ","publisher":"Επιτροπή Λογιστικής Τυποποίησης και Ελέγχων (ΕΛΤΕ) — Συμβούλιο Λογιστικής Τυποποίησης (ΣΛΟΤ)","url":"https://elte.org.gr/2022/09/22/slot-arithm-prot-2334-ex-13-9-2022/","consulted_on":"2026-09-25","kind":"guidance"},{"key":"en-16931","title":"EN 16931-1 — the semantic data model of the core elements of an electronic invoice, and the conformity Directive 2014/55/EU requires","publisher":"European Commission","url":"https://ec.europa.eu/digital-building-blocks/sites/spaces/DIGITAL/pages/467108950/EN+16931+compliance","consulted_on":"2026-09-25","kind":"standard"},{"key":"uncl5305","title":"UNCL5305 — VAT category code list (BT-118 and BT-151), the subset published for EN 16931","publisher":"OpenPEPPOL — list published by the European Commission","url":"https://docs.peppol.eu/poacc/billing/3.0/codelist/UNCL5305/","consulted_on":"2026-09-25","kind":"standard"},{"key":"vatex","title":"VATEX — VAT exemption reason code list (BT-121)","publisher":"OpenPEPPOL — list published by the European Commission","url":"https://docs.peppol.eu/poacc/billing/3.0/codelist/vatex/","consulted_on":"2026-09-25","kind":"standard"},{"key":"aade-portal","title":"myAADE — ηλεκτρονικές υπηρεσίες της Ανεξάρτητης Αρχής Δημοσίων Εσόδων, κατάθεση δηλώσεων ΦΠΑ (TAXISnet)","publisher":"Ανεξάρτητη Αρχή Δημοσίων Εσόδων (ΑΑΔΕ)","url":"https://www.aade.gr","consulted_on":"2026-09-25","kind":"portal"}]'::jsonb)
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
  ('GR', 'default', 'ΕΓΛΣ — Ελληνικό Γενικό Λογιστικό Σχέδιο (επιλογή λογαριασμών)', '{"en":"ΕΓΛΣ — Hellenic General Chart of Accounts (selection)"}'::jsonb, true, 'companies', '{}'::text[], null, 'Ο Ν.4308/2014 (ΕΛΠ), άρθρο 3 και Παράρτημα Γ, ορίζει ως υποχρεωτικά μόνον την ονοματολογία, τον βαθμό ανάλυσης/συγκέντρωσης και το περιεχόμενο ενός σχεδίου λογαριασμών — όχι μία συγκεκριμένη αρίθμηση. Το Π.Δ. 1123/1980 (ΕΓΛΣ), που είχε καθιερώσει την αρίθμηση εδώ ακολουθούμενη (ομάδες 1-8, δύο ψηφία ανά υποομάδα), έχει καταργηθεί για χρήσεις μετά την 31.12.2014· η γνωμοδότηση ΣΛΟΤ 2334 ΕΞ/13.9.2022 επιβεβαιώνει ότι η χρήση της αρίθμησης αυτής παραμένει προαιρετική, αν και είναι η σχεδόν καθολική πρακτική σύμβαση στην ελληνική αγορά λογισμικού. Τα δύο πρώτα ψηφία κάθε κωδικού είναι συνεπώς η επίσημη υποομάδα του ΕΓΛΣ όπως τη γνωρίζει η πρακτική· τα υπόλοιπα ψηφία (αναλυτική διάκριση εσωτερικού/ενδοκοινοτικού/τρίτων χωρών, κ.λπ.) είναι σύμβαση αυτού του πακέτου και χρειάζονται έλεγχο από λογιστή πριν από παραγωγική χρήση — βλ. README', 'n4308-2014')
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
  ('GR', 'default', '1000', 'Γήπεδα - Οικόπεδα', '{"en":"Land"}'::jsonb, 'asset_fixed', false, null, 10),
  ('GR', 'default', '1010', 'Ορυχεία - Λατομεία - Δασικές εκτάσεις', '{"en":"Mines, quarries and forest land"}'::jsonb, 'asset_fixed', false, null, 20),
  ('GR', 'default', '1100', 'Κτίρια και τεχνικά έργα', '{"en":"Buildings and technical works"}'::jsonb, 'asset_fixed', false, null, 30),
  ('GR', 'default', '1110', 'Εγκαταστάσεις κτιρίων σε ακίνητα τρίτων', '{"en":"Installations on third-party property"}'::jsonb, 'asset_fixed', false, null, 40),
  ('GR', 'default', '1200', 'Μηχανήματα', '{"en":"Machinery"}'::jsonb, 'asset_fixed', false, null, 50),
  ('GR', 'default', '1210', 'Τεχνικές εγκαταστάσεις', '{"en":"Technical installations"}'::jsonb, 'asset_fixed', false, null, 60),
  ('GR', 'default', '1220', 'Φορητά μηχανήματα και εργαλεία', '{"en":"Portable machinery and tools"}'::jsonb, 'asset_fixed', false, null, 70),
  ('GR', 'default', '1300', 'Μεταφορικά μέσα ξηράς', '{"en":"Land transport equipment"}'::jsonb, 'asset_fixed', false, null, 80),
  ('GR', 'default', '1310', 'Μεταφορικά μέσα θαλάσσης και αέρος', '{"en":"Sea and air transport equipment"}'::jsonb, 'asset_fixed', false, null, 90),
  ('GR', 'default', '1400', 'Έπιπλα', '{"en":"Furniture"}'::jsonb, 'asset_fixed', false, null, 100),
  ('GR', 'default', '1410', 'Σκεύη', '{"en":"Fittings"}'::jsonb, 'asset_fixed', false, null, 110),
  ('GR', 'default', '1420', 'Μηχανές γραφείων', '{"en":"Office machines"}'::jsonb, 'asset_fixed', false, null, 120),
  ('GR', 'default', '1430', 'Ηλεκτρονικοί υπολογιστές και λογισμικό', '{"en":"Computer hardware and software"}'::jsonb, 'asset_fixed', false, null, 130),
  ('GR', 'default', '1500', 'Ακινητοποιήσεις υπό εκτέλεση', '{"en":"Assets under construction"}'::jsonb, 'asset_fixed', false, null, 140),
  ('GR', 'default', '1510', 'Προκαταβολές για κτήσεις πάγιων στοιχείων', '{"en":"Advances for the acquisition of fixed assets"}'::jsonb, 'asset_fixed', false, null, 150),
  ('GR', 'default', '1600', 'Έξοδα ίδρυσης και πρώτης εγκατάστασης', '{"en":"Formation and start-up expenses"}'::jsonb, 'asset_fixed', false, null, 160),
  ('GR', 'default', '1610', 'Έξοδα ερευνών και ανάπτυξης', '{"en":"Research and development expenses"}'::jsonb, 'asset_fixed', false, null, 170),
  ('GR', 'default', '1620', 'Παραχωρήσεις και δικαιώματα βιομηχανικής ιδιοκτησίας', '{"en":"Concessions and industrial property rights"}'::jsonb, 'asset_fixed', false, null, 180),
  ('GR', 'default', '1630', 'Δικαιώματα χρήσης άυλων παγίων και λογισμικού', '{"en":"Rights of use of intangible assets and software"}'::jsonb, 'asset_fixed', false, null, 190),
  ('GR', 'default', '1700', 'Συμμετοχές σε συνδεδεμένες επιχειρήσεις', '{"en":"Investments in affiliated undertakings"}'::jsonb, 'asset_non_current', false, null, 200),
  ('GR', 'default', '1710', 'Συμμετοχές σε συγγενείς επιχειρήσεις', '{"en":"Investments in associated undertakings"}'::jsonb, 'asset_non_current', false, null, 210),
  ('GR', 'default', '1800', 'Συμμετοχές σε λοιπές επιχειρήσεις', '{"en":"Investments in other undertakings"}'::jsonb, 'asset_non_current', false, null, 220),
  ('GR', 'default', '1810', 'Λοιποί τίτλοι πάγιας επένδυσης', '{"en":"Other long-term securities"}'::jsonb, 'asset_non_current', false, null, 230),
  ('GR', 'default', '1820', 'Μακροπρόθεσμες απαιτήσεις κατά συνδεδεμένων επιχειρήσεων', '{"en":"Long-term receivables from affiliated undertakings"}'::jsonb, 'asset_non_current', false, null, 240),
  ('GR', 'default', '1900', 'Αποσβεσμένα άυλα πάγια στοιχεία', '{"en":"Accumulated depreciation of intangible fixed assets"}'::jsonb, 'asset_fixed', false, null, 250),
  ('GR', 'default', '1910', 'Αποσβεσμένα ενσώματα πάγια στοιχεία', '{"en":"Accumulated depreciation of tangible fixed assets"}'::jsonb, 'asset_fixed', false, null, 260),
  ('GR', 'default', '2000', 'Εμπορεύματα', '{"en":"Merchandise"}'::jsonb, 'asset_current', false, null, 270),
  ('GR', 'default', '2002', 'Αγορές εμπορευμάτων χρήσεως', '{"en":"Purchases of merchandise for the period"}'::jsonb, 'asset_current', false, null, 280),
  ('GR', 'default', '2100', 'Προϊόντα έτοιμα', '{"en":"Finished products"}'::jsonb, 'asset_current', false, null, 290),
  ('GR', 'default', '2110', 'Προϊόντα ημιτελή', '{"en":"Semi-finished products"}'::jsonb, 'asset_current', false, null, 300),
  ('GR', 'default', '2200', 'Υποπροϊόντα και υπολείμματα', '{"en":"By-products and residues"}'::jsonb, 'asset_current', false, null, 310),
  ('GR', 'default', '2300', 'Παραγωγή σε εξέλιξη', '{"en":"Work in progress"}'::jsonb, 'asset_current', false, null, 320),
  ('GR', 'default', '2400', 'Πρώτες και βοηθητικές ύλες', '{"en":"Raw and auxiliary materials"}'::jsonb, 'asset_current', false, null, 330),
  ('GR', 'default', '2410', 'Υλικά συσκευασίας', '{"en":"Packaging materials"}'::jsonb, 'asset_current', false, null, 340),
  ('GR', 'default', '2500', 'Αναλώσιμα υλικά', '{"en":"Consumables"}'::jsonb, 'asset_current', false, null, 350),
  ('GR', 'default', '2510', 'Ανταλλακτικά παγίων', '{"en":"Spare parts for fixed assets"}'::jsonb, 'asset_current', false, null, 360),
  ('GR', 'default', '2520', 'Είδη συσκευασίας', '{"en":"Packaging items"}'::jsonb, 'asset_current', false, null, 370),
  ('GR', 'default', '2800', 'Προκαταβολές για αγορές αποθεμάτων', '{"en":"Advances for the purchase of inventory"}'::jsonb, 'asset_current', false, null, 380),
  ('GR', 'default', '3000', 'Πελάτες εσωτερικού', '{"en":"Trade receivables — domestic"}'::jsonb, 'asset_receivable', true, null, 390),
  ('GR', 'default', '3001', 'Πελάτες ενδοκοινοτικοί', '{"en":"Trade receivables — European Union"}'::jsonb, 'asset_receivable', true, null, 400),
  ('GR', 'default', '3002', 'Πελάτες τρίτων χωρών', '{"en":"Trade receivables — third countries"}'::jsonb, 'asset_receivable', true, null, 410),
  ('GR', 'default', '3003', 'Επισφαλείς πελάτες', '{"en":"Doubtful trade receivables"}'::jsonb, 'asset_receivable', true, null, 420),
  ('GR', 'default', '3100', 'Γραμμάτια εισπρακτέα στο χαρτοφυλάκιο', '{"en":"Notes receivable held"}'::jsonb, 'asset_receivable', true, null, 430),
  ('GR', 'default', '3110', 'Γραμμάτια εισπρακτέα σε καθυστέρηση', '{"en":"Overdue notes receivable"}'::jsonb, 'asset_receivable', true, null, 440),
  ('GR', 'default', '3200', 'Λοιπές μακροπρόθεσμες απαιτήσεις', '{"en":"Other long-term receivables"}'::jsonb, 'asset_non_current', false, null, 450),
  ('GR', 'default', '3300', 'Χρεώστες διάφοροι', '{"en":"Other debtors"}'::jsonb, 'asset_current', false, null, 460),
  ('GR', 'default', '3301', 'Ελληνικό Δημόσιο - ΦΠΑ προς επιστροφή ή συμψηφισμό', '{"en":"Hellenic State — VAT to be refunded or set off"}'::jsonb, 'asset_current', true, null, 470),
  ('GR', 'default', '3310', 'Προκαταβολές σε προμηθευτές', '{"en":"Advances to suppliers"}'::jsonb, 'asset_current', false, null, 480),
  ('GR', 'default', '3320', 'Βραχυπρόθεσμες απαιτήσεις κατά συνδεδεμένων επιχειρήσεων', '{"en":"Short-term receivables from affiliated undertakings"}'::jsonb, 'asset_current', false, null, 490),
  ('GR', 'default', '3400', 'Μετοχές', '{"en":"Shares"}'::jsonb, 'asset_current', false, null, 500),
  ('GR', 'default', '3410', 'Ομολογίες', '{"en":"Bonds"}'::jsonb, 'asset_current', false, null, 510),
  ('GR', 'default', '3600', 'Έξοδα επόμενων χρήσεων', '{"en":"Prepaid expenses"}'::jsonb, 'asset_prepayments', false, null, 520),
  ('GR', 'default', '3610', 'Έξοδα υπό τακτοποίηση', '{"en":"Expenses under settlement"}'::jsonb, 'asset_prepayments', false, null, 530),
  ('GR', 'default', '3620', 'Έσοδα χρήσεως εισπρακτέα', '{"en":"Accrued income"}'::jsonb, 'asset_prepayments', false, null, 540),
  ('GR', 'default', '3800', 'Ταμείο', '{"en":"Cash"}'::jsonb, 'asset_cash', false, null, 550),
  ('GR', 'default', '3803', 'Καταθέσεις όψεως σε ευρώ', '{"en":"Sight deposits in euro"}'::jsonb, 'asset_cash', false, null, 560),
  ('GR', 'default', '3804', 'Καταθέσεις όψεως σε ξένο νόμισμα', '{"en":"Sight deposits in foreign currency"}'::jsonb, 'asset_cash', false, null, 570),
  ('GR', 'default', '3805', 'Καταθέσεις προθεσμίας', '{"en":"Term deposits"}'::jsonb, 'asset_cash', false, null, 580),
  ('GR', 'default', '4000', 'Κεφάλαιο εταίρων ή μετόχων', '{"en":"Share capital"}'::jsonb, 'equity', false, null, 590),
  ('GR', 'default', '4100', 'Τακτικό αποθεματικό', '{"en":"Statutory reserve"}'::jsonb, 'equity', false, null, 600),
  ('GR', 'default', '4110', 'Αποθεματικά καταστατικού', '{"en":"Reserves under the articles"}'::jsonb, 'equity', false, null, 610),
  ('GR', 'default', '4120', 'Έκτακτα αποθεματικά', '{"en":"Extraordinary reserves"}'::jsonb, 'equity', false, null, 620),
  ('GR', 'default', '4130', 'Αφορολόγητα αποθεματικά ειδικών διατάξεων νόμων', '{"en":"Tax-exempt reserves under special provisions"}'::jsonb, 'equity', false, null, 630),
  ('GR', 'default', '4200', 'Κέρδη (ζημίες) εις νέο', '{"en":"Retained earnings (losses)"}'::jsonb, 'equity_retained', false, null, 640),
  ('GR', 'default', '4400', 'Επιχορηγήσεις παγίων επενδύσεων', '{"en":"Investment grants"}'::jsonb, 'liability_non_current', false, null, 650),
  ('GR', 'default', '4500', 'Προβλέψεις για αποζημίωση προσωπικού λόγω εξόδου από την υπηρεσία', '{"en":"Provision for staff termination indemnities"}'::jsonb, 'liability_non_current', false, null, 660),
  ('GR', 'default', '4510', 'Λοιπές προβλέψεις', '{"en":"Other provisions"}'::jsonb, 'liability_non_current', false, null, 670),
  ('GR', 'default', '4700', 'Μακροπρόθεσμες υποχρεώσεις σε τράπεζες', '{"en":"Long-term bank borrowings"}'::jsonb, 'liability_non_current', false, null, 680),
  ('GR', 'default', '4710', 'Ομολογιακά δάνεια', '{"en":"Bonds issued"}'::jsonb, 'liability_non_current', false, null, 690),
  ('GR', 'default', '4750', 'Λοιπές μακροπρόθεσμες υποχρεώσεις', '{"en":"Other long-term liabilities"}'::jsonb, 'liability_non_current', false, null, 700),
  ('GR', 'default', '5000', 'Προμηθευτές εσωτερικού', '{"en":"Trade payables — domestic"}'::jsonb, 'liability_payable', true, null, 710),
  ('GR', 'default', '5001', 'Προμηθευτές ενδοκοινοτικοί', '{"en":"Trade payables — European Union"}'::jsonb, 'liability_payable', true, null, 720),
  ('GR', 'default', '5002', 'Προμηθευτές τρίτων χωρών', '{"en":"Trade payables — third countries"}'::jsonb, 'liability_payable', true, null, 730),
  ('GR', 'default', '5010', 'Επιταγές πληρωτέες μεταχρονολογημένες', '{"en":"Post-dated cheques payable"}'::jsonb, 'liability_payable', true, null, 740),
  ('GR', 'default', '5100', 'Γραμμάτια πληρωτέα', '{"en":"Notes payable"}'::jsonb, 'liability_payable', true, null, 750),
  ('GR', 'default', '5200', 'Τράπεζες - Λογαριασμοί βραχυπρόθεσμων υποχρεώσεων', '{"en":"Banks — current account borrowings"}'::jsonb, 'liability_current', false, null, 760),
  ('GR', 'default', '5210', 'Μακροπρόθεσμες υποχρεώσεις πληρωτέες στην επόμενη χρήση', '{"en":"Long-term liabilities payable within the next year"}'::jsonb, 'liability_current', false, null, 770),
  ('GR', 'default', '5300', 'Πιστωτές διάφοροι', '{"en":"Other creditors"}'::jsonb, 'liability_current', false, null, 780),
  ('GR', 'default', '5310', 'Προκαταβολές πελατών', '{"en":"Advances from customers"}'::jsonb, 'liability_current', false, null, 790),
  ('GR', 'default', '5400', 'ΦΠΑ εκροών (φόρος επί πωλήσεων και παροχής υπηρεσιών)', '{"en":"Output VAT"}'::jsonb, 'liability_current', false, null, 800),
  ('GR', 'default', '5401', 'ΦΠΑ εισροών εκπιπτόμενος (φόρος επί αγορών και δαπανών)', '{"en":"Deductible input VAT"}'::jsonb, 'asset_current', false, null, 810),
  ('GR', 'default', '5402', 'ΦΠΑ εκκαθάρισης - αποδοτέο στο Ελληνικό Δημόσιο', '{"en":"VAT settlement — payable to the Hellenic State"}'::jsonb, 'liability_current', true, null, 820),
  ('GR', 'default', '5403', 'Ελληνικό Δημόσιο - Προκαταβλητέος και παρακρατούμενος φόρος εισοδήματος', '{"en":"Hellenic State — income tax prepaid and withheld"}'::jsonb, 'liability_current', false, null, 830),
  ('GR', 'default', '5404', 'Φόρος μισθωτών υπηρεσιών παρακρατούμενος', '{"en":"Payroll income tax withheld"}'::jsonb, 'liability_current', false, null, 840),
  ('GR', 'default', '5500', 'Ασφαλιστικοί οργανισμοί (ΕΦΚΑ)', '{"en":"Social security bodies (EFKA)"}'::jsonb, 'liability_current', false, null, 850),
  ('GR', 'default', '5510', 'Λοιποί ασφαλιστικοί οργανισμοί', '{"en":"Other social security bodies"}'::jsonb, 'liability_current', false, null, 860),
  ('GR', 'default', '5600', 'Έξοδα χρήσεως δουλευμένα', '{"en":"Accrued expenses"}'::jsonb, 'liability_current', false, null, 870),
  ('GR', 'default', '5620', 'Έσοδα επόμενων χρήσεων', '{"en":"Deferred income"}'::jsonb, 'liability_current', false, null, 880),
  ('GR', 'default', '5800', 'Λογαριασμοί συνδέσεως και λοιπές εκκρεμείς μεταφορές (ενδιάμεσος λογαριασμός)', '{"en":"Suspense and clearing account"}'::jsonb, 'liability_current', false, null, 890),
  ('GR', 'default', '6000', 'Αμοιβές έμμισθου προσωπικού', '{"en":"Salaried staff remuneration"}'::jsonb, 'expense', false, null, 900),
  ('GR', 'default', '6010', 'Αμοιβές ημερομίσθιου προσωπικού', '{"en":"Waged staff remuneration"}'::jsonb, 'expense', false, null, 910),
  ('GR', 'default', '6020', 'Εργοδοτικές εισφορές', '{"en":"Employer social security contributions"}'::jsonb, 'expense', false, null, 920),
  ('GR', 'default', '6100', 'Αμοιβές ελεύθερων επαγγελματιών', '{"en":"Fees of self-employed professionals"}'::jsonb, 'expense', false, null, 930),
  ('GR', 'default', '6110', 'Αμοιβές τρίτων εμπορικών επιχειρήσεων', '{"en":"Fees of third-party commercial undertakings"}'::jsonb, 'expense', false, null, 940),
  ('GR', 'default', '6200', 'Ηλεκτρικό ρεύμα παραγωγικής διαδικασίας', '{"en":"Electricity of the production process"}'::jsonb, 'expense', false, null, 950),
  ('GR', 'default', '6210', 'Ενοίκια', '{"en":"Rent"}'::jsonb, 'expense', false, null, 960),
  ('GR', 'default', '6220', 'Ασφάλιστρα', '{"en":"Insurance premiums"}'::jsonb, 'expense', false, null, 970),
  ('GR', 'default', '6230', 'Επισκευές και συντηρήσεις', '{"en":"Repairs and maintenance"}'::jsonb, 'expense', false, null, 980),
  ('GR', 'default', '6240', 'Τηλεπικοινωνίες', '{"en":"Telecommunications"}'::jsonb, 'expense', false, null, 990),
  ('GR', 'default', '6300', 'Φόροι - τέλη (πλην φόρου εισοδήματος)', '{"en":"Taxes and duties (other than income tax)"}'::jsonb, 'expense', false, null, 1000),
  ('GR', 'default', '6310', 'Δημοτικοί φόροι - τέλη', '{"en":"Municipal taxes and duties"}'::jsonb, 'expense', false, null, 1010),
  ('GR', 'default', '6400', 'Έξοδα μεταφορών', '{"en":"Transport expenses"}'::jsonb, 'expense', false, null, 1020),
  ('GR', 'default', '6410', 'Έξοδα προβολής και διαφήμισης', '{"en":"Advertising and promotion expenses"}'::jsonb, 'expense', false, null, 1030),
  ('GR', 'default', '6420', 'Έξοδα ταξιδιών', '{"en":"Travel expenses"}'::jsonb, 'expense', false, null, 1040),
  ('GR', 'default', '6430', 'Διάφορα έξοδα', '{"en":"Various expenses"}'::jsonb, 'expense', false, null, 1050),
  ('GR', 'default', '6500', 'Τόκοι και έξοδα τραπεζών', '{"en":"Bank interest and charges"}'::jsonb, 'expense', false, null, 1060),
  ('GR', 'default', '6600', 'Αποσβέσεις ενσώματων παγίων στοιχείων', '{"en":"Depreciation of tangible fixed assets"}'::jsonb, 'expense_depreciation', false, null, 1070),
  ('GR', 'default', '6610', 'Αποσβέσεις άυλων παγίων στοιχείων', '{"en":"Depreciation of intangible fixed assets"}'::jsonb, 'expense_depreciation', false, null, 1080),
  ('GR', 'default', '6800', 'Προβλέψεις εκμεταλλεύσεως', '{"en":"Operating provisions"}'::jsonb, 'expense', false, null, 1090),
  ('GR', 'default', '7000', 'Πωλήσεις εμπορευμάτων εσωτερικού', '{"en":"Sales of merchandise — domestic"}'::jsonb, 'income', false, null, 1100),
  ('GR', 'default', '7001', 'Πωλήσεις εμπορευμάτων ενδοκοινοτικές', '{"en":"Sales of merchandise — intra-Community"}'::jsonb, 'income', false, null, 1110),
  ('GR', 'default', '7002', 'Πωλήσεις εμπορευμάτων εξαγωγές (εκτός Ε.Ε.)', '{"en":"Sales of merchandise — exports"}'::jsonb, 'income', false, null, 1120),
  ('GR', 'default', '7100', 'Πωλήσεις προϊόντων έτοιμων', '{"en":"Sales of finished products"}'::jsonb, 'income', false, null, 1130),
  ('GR', 'default', '7110', 'Πωλήσεις προϊόντων ημιτελών', '{"en":"Sales of semi-finished products"}'::jsonb, 'income', false, null, 1140),
  ('GR', 'default', '7300', 'Πωλήσεις υπηρεσιών εσωτερικού', '{"en":"Sales of services — domestic"}'::jsonb, 'income', false, null, 1150),
  ('GR', 'default', '7301', 'Πωλήσεις υπηρεσιών σε λήπτες άλλου κράτους μέλους', '{"en":"Sales of services to a taxable person of another Member State"}'::jsonb, 'income', false, null, 1160),
  ('GR', 'default', '7302', 'Πωλήσεις υπηρεσιών εκτός Ε.Ε.', '{"en":"Sales of services outside the European Union"}'::jsonb, 'income', false, null, 1170),
  ('GR', 'default', '7400', 'Επιχορηγήσεις πωλήσεων', '{"en":"Sales grants"}'::jsonb, 'income_other', false, null, 1180),
  ('GR', 'default', '7410', 'Διάφορα έσοδα πωλήσεων', '{"en":"Other sales-related income"}'::jsonb, 'income_other', false, null, 1190),
  ('GR', 'default', '7600', 'Έσοδα συμμετοχών', '{"en":"Income from participations"}'::jsonb, 'income_other', false, null, 1200),
  ('GR', 'default', '7610', 'Έσοδα χρεογράφων', '{"en":"Income from securities"}'::jsonb, 'income_other', false, null, 1210),
  ('GR', 'default', '7620', 'Πιστωτικοί τόκοι', '{"en":"Interest income"}'::jsonb, 'income_other', false, null, 1220),
  ('GR', 'default', '7800', 'Έκτακτα και ανόργανα έσοδα', '{"en":"Extraordinary and non-operating income"}'::jsonb, 'income_other', false, null, 1230),
  ('GR', 'default', '7810', 'Έσοδα προηγούμενων χρήσεων', '{"en":"Income of prior periods"}'::jsonb, 'income_other', false, null, 1240),
  ('GR', 'default', '8000', 'Λογαριασμός γενικής εκμεταλλεύσεως', '{"en":"General trading account"}'::jsonb, 'equity', false, null, 1250),
  ('GR', 'default', '8100', 'Έκτακτα και ανόργανα αποτελέσματα', '{"en":"Extraordinary and non-operating results"}'::jsonb, 'equity', false, null, 1260),
  ('GR', 'default', '8200', 'Αποτελέσματα προηγούμενων χρήσεων', '{"en":"Results of prior periods"}'::jsonb, 'equity', false, null, 1270),
  ('GR', 'default', '8600', 'Αποτελέσματα (κέρδη ή ζημίες) χρήσεως προς διάθεση', '{"en":"Result of the period (profit or loss) for appropriation"}'::jsonb, 'equity', false, null, 1280)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('GR', 'BNK', 'Ημερολόγιο τραπέζης', '{"en":"Bank journal"}'::jsonb, 'bank', 30),
  ('GR', 'CSH', 'Ημερολόγιο ταμείου', '{"en":"Cash journal"}'::jsonb, 'cash', 40),
  ('GR', 'DIV', 'Ημερολόγιο διαφόρων πράξεων', '{"en":"Miscellaneous transactions journal"}'::jsonb, 'general', 50),
  ('GR', 'OPN', 'Ημερολόγιο ανοίγματος', '{"en":"Opening journal"}'::jsonb, 'opening', 60),
  ('GR', 'PUR', 'Ημερολόγιο αγορών', '{"en":"Purchase journal"}'::jsonb, 'purchase', 20),
  ('GR', 'SAL', 'Ημερολόγιο πωλήσεων', '{"en":"Sales journal"}'::jsonb, 'sales', 10)
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
  ('GR', 'GR-P-13', 'Αγορά με τον μειωμένο συντελεστή 13%', '{"en":"Purchase — reduced rate 13%"}'::jsonb, null, 'percent', 13, 'purchase', 'domestic', date '2024-10-11', null, 'Ν.5144/2024, άρθρο 21, παρ. 2, και άρθρο 34 — έκπτωση του φόρου που επιβάρυνε αγορές και δαπάνες υποκείμενες στον μειωμένο συντελεστή', null, null, 110, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'n5144-2024', null, null, null, null),
  ('GR', 'GR-P-24', 'Αγορά με τον κανονικό συντελεστή 24%', '{"en":"Purchase — standard rate 24%"}'::jsonb, null, 'percent', 24, 'purchase', 'domestic', date '2024-10-11', null, 'Ν.5144/2024, άρθρο 21, παρ. 1, και άρθρο 34 — έκπτωση του φόρου που επιβάρυνε τα αγαθά και τις υπηρεσίες που αποκτήθηκαν στο εσωτερικό της χώρας για τις ανάγκες φορολογητέων πράξεων', null, null, 100, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'n5144-2024', null, null, null, null),
  ('GR', 'GR-P-6', 'Αγορά με τον υπερμειωμένο συντελεστή 6%', '{"en":"Purchase — super-reduced rate 6%"}'::jsonb, null, 'percent', 6, 'purchase', 'domestic', date '2024-10-11', null, 'Ν.5144/2024, άρθρο 21, παρ. 3, και άρθρο 34 — έκπτωση του φόρου που επιβάρυνε αγορές και δαπάνες υποκείμενες στον υπερμειωμένο συντελεστή', null, null, 120, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'n5144-2024', null, null, null, null),
  ('GR', 'GR-P-ICG-24', 'Ενδοκοινοτική απόκτηση αγαθών — αναγωγή στο 24%', '{"en":"Intra-Community acquisition of goods — self-assessed at 24%"}'::jsonb, null, 'percent', 24, 'purchase', 'intracom_acquisition_goods', date '2024-10-11', null, 'Ν.5144/2024, άρθρο 10 — η ενδοκοινοτική απόκτηση αγαθών υπόκειται σε ΦΠΑ· άρθρο 39, παρ. 1, περ. β) — υπόχρεος για την καταβολή είναι το πρόσωπο που πραγματοποιεί την ενδοκοινοτική απόκτηση, το οποίο επιβαρύνει την αξία με τον φόρο και τον εκπίπτει ταυτόχρονα κατ'' άρθρο 34· η δήλωση Φ2 εμφανίζει το ποσό ταυτόχρονα στο πεδίο 303/333 της κατηγορίας εκροών (μαζί με τις πωλήσεις εσωτερικού στον ίδιο συντελεστή) και στο πεδίο 364/384 της κατηγορίας εισροών, μία μόνη posting βάσης αναγραφόμενη και στις δύο, όπως στο ενδοκοινοτικό παράδειγμα της Εσθονίας στο docs/packs.md', 'K', 'VATEX-EU-IC', 130, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'n5144-2024', null, null, null, null),
  ('GR', 'GR-P-IMPORT', 'Εισαγωγή αγαθών εκτός Ευρωπαϊκής Ένωσης', '{"en":"Import of goods from outside the European Union"}'::jsonb, null, 'percent', 24, 'purchase', 'import', date '2024-10-11', null, 'Ν.5144/2024, άρθρο 5, παρ. 1, περ. γ) και άρθρο 34 — η εισαγωγή αγαθών από τρίτη χώρα υπόκειται σε ΦΠΑ κατά τον εκτελωνισμό, με βάση τη δασμολογητέα αξία· ο εισαγωγέας εκπίπτει τον φόρο που κατέβαλε ή βεβαιώθηκε από την τελωνειακή αρχή', null, null, 140, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'n5144-2024', null, null, null, null),
  ('GR', 'GR-S-13', 'Πώληση με τον μειωμένο συντελεστή 13%', '{"en":"Sale — reduced rate 13%"}'::jsonb, null, 'percent', 13, 'sale', 'domestic', date '2024-10-11', null, 'Ν.5144/2024, άρθρο 21, παρ. 2 και Παράρτημα ΙΙΙ, μέρος Α'' — μειωμένος συντελεστής 13% για τα αγαθά και τις υπηρεσίες του Παραρτήματος ΙΙΙ, μεταξύ άλλων τα είδη διατροφής, τα μη αλκοολούχα ποτά, τα ξενοδοχειακά καταλύματα', 'S', null, 20, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'n5144-2024-parartima-iii', null, null, null, null),
  ('GR', 'GR-S-24', 'Πώληση με τον κανονικό συντελεστή 24%', '{"en":"Sale — standard rate 24%"}'::jsonb, null, 'percent', 24, 'sale', 'domestic', date '2024-10-11', null, 'Ν.5144/2024, άρθρο 21, παρ. 1 — κανονικός συντελεστής 24% επί της φορολογητέας αξίας, για κάθε παράδοση αγαθών και παροχή υπηρεσιών στο εσωτερικό της χώρας για την οποία δεν προβλέπεται μειωμένος, υπερμειωμένος ή μηδενικός συντελεστής, ούτε απαλλαγή', 'S', null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'n5144-2024', null, null, null, null),
  ('GR', 'GR-S-6', 'Πώληση με τον υπερμειωμένο συντελεστή 6%', '{"en":"Sale — super-reduced rate 6%"}'::jsonb, null, 'percent', 6, 'sale', 'domestic', date '2024-10-11', null, 'Ν.5144/2024, άρθρο 21, παρ. 3 και Παράρτημα ΙΙΙ, μέρος Β'' — υπερμειωμένος συντελεστής 6% για αγαθά μεγάλης κοινωνικής σημασίας: φάρμακα και εμβόλια, βιβλία, εφημερίδες και περιοδικά, ηλεκτρικό ρεύμα και φυσικό αέριο, μεταξύ άλλων', 'S', null, 30, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'n5144-2024-parartima-iii', null, null, null, null),
  ('GR', 'GR-S-EXE', 'Απαλλασσόμενη πώληση — υπηρεσίες νοσοκομειακής και ιατρικής περίθαλψης', '{"en":"Exempt sale — hospital and medical care services"}'::jsonb, null, 'percent', 0, 'sale', 'exempt', date '2024-10-11', null, 'Ν.5144/2024, άρθρο 27, παρ. 1, περ. δ) και ε) — απαλλάσσονται η παροχή υπηρεσιών νοσοκομειακής και ιατρικής περίθαλψης και διάγνωσης και οι στενά συνδεόμενες με αυτές παραδόσεις αγαθών, καθώς και οι παροχές ιατρικής περίθαλψης στο πλαίσιο άσκησης ιατρικών επαγγελμάτων· άρθρο 132, παρ. 1, στοιχεία β) και γ) της Οδηγίας 2006/112/ΕΚ', 'E', 'VATEX-EU-132', 40, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'n5144-2024', null, null, null, null),
  ('GR', 'GR-S-EXP', 'Πώληση εξαγωγή εκτός Ευρωπαϊκής Ένωσης', '{"en":"Sale — export outside the European Union"}'::jsonb, null, 'percent', 0, 'sale', 'export', date '2024-10-11', null, 'Ν.5144/2024, άρθρο 29, παρ. 1, περ. α) — απαλλάσσεται η παράδοση αγαθών που αποστέλλονται ή μεταφέρονται εκτός της Ευρωπαϊκής Ένωσης από τον πωλητή ή για λογαριασμό του', 'G', 'VATEX-EU-G', 50, 'vat', true, array['transport_evidence']::tax_condition[], null, false, false, null, 'n5144-2024', null, null, null, null),
  ('GR', 'GR-S-ICG', 'Ενδοκοινοτική παράδοση αγαθών — απαλλάσσεται', '{"en":"Intra-Community supply of goods — exempt"}'::jsonb, null, 'percent', 0, 'sale', 'intracom_goods', date '2024-10-11', null, 'Ν.5144/2024, άρθρο 33 — απαλλάσσεται η παράδοση αγαθών που αποστέλλονται ή μεταφέρονται σε άλλο κράτος μέλος προς υποκείμενο στον φόρο ή προς μη υποκείμενο νομικό πρόσωπο εγγεγραμμένο στο σύστημα ΦΠΑ εκεί, ο οποίος έχει γνωστοποιήσει τον αριθμό φορολογικού μητρώου του στον προμηθευτή· άρθρο 138 της Οδηγίας 2006/112/ΕΚ', 'K', 'VATEX-EU-IC', 60, 'vat', true, array['transport_evidence', 'buyer_status']::tax_condition[], null, false, false, null, 'n5144-2024', null, null, null, null),
  ('GR', 'GR-S-ICS', 'Παροχή υπηρεσιών σε υποκείμενο στον φόρο άλλου κράτους μέλους — αντίστροφη επιβάρυνση', '{"en":"Supply of services to a taxable person of another Member State — reverse charge"}'::jsonb, null, 'percent', 0, 'sale', 'intracom_services', date '2024-10-11', null, 'Ν.5144/2024, άρθρο 14, παρ. 2 — ο τόπος παροχής γενικής υπηρεσίας προς υποκείμενο στον φόρο εγκατεστημένο σε άλλο κράτος μέλος είναι ο τόπος εγκατάστασης του λήπτη, με τον λήπτη υπόχρεο για την καταβολή του φόρου κατ'' άρθρο 39γ· άρθρα 44 και 196 της Οδηγίας 2006/112/ΕΚ', 'K', 'VATEX-EU-IC', 70, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'n5144-2024', null, null, null, null)
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
    ('GR-P-13', 'invoice', 'base', 100, null, '361', array['361']::text[], 100, 'GR-F2', 10),
    ('GR-P-13', 'invoice', 'tax', 100, '5401', '381', array['381']::text[], 100, 'GR-F2', 20),
    ('GR-P-13', 'credit_note', 'base', 100, null, '361', array['361']::text[], -100, 'GR-F2', 10),
    ('GR-P-13', 'credit_note', 'tax', 100, '5401', '381', array['381']::text[], -100, 'GR-F2', 20),
    ('GR-P-24', 'invoice', 'base', 100, null, '361', array['361']::text[], 100, 'GR-F2', 10),
    ('GR-P-24', 'invoice', 'tax', 100, '5401', '381', array['381']::text[], 100, 'GR-F2', 20),
    ('GR-P-24', 'credit_note', 'base', 100, null, '361', array['361']::text[], -100, 'GR-F2', 10),
    ('GR-P-24', 'credit_note', 'tax', 100, '5401', '381', array['381']::text[], -100, 'GR-F2', 20),
    ('GR-P-6', 'invoice', 'base', 100, null, '361', array['361']::text[], 100, 'GR-F2', 10),
    ('GR-P-6', 'invoice', 'tax', 100, '5401', '381', array['381']::text[], 100, 'GR-F2', 20),
    ('GR-P-6', 'credit_note', 'base', 100, null, '361', array['361']::text[], -100, 'GR-F2', 10),
    ('GR-P-6', 'credit_note', 'tax', 100, '5401', '381', array['381']::text[], -100, 'GR-F2', 20),
    ('GR-P-ICG-24', 'invoice', 'base', 100, null, '303', array['303', '364']::text[], 100, 'GR-F2', 10),
    ('GR-P-ICG-24', 'invoice', 'tax', 100, '5401', '384', array['384']::text[], 100, 'GR-F2', 20),
    ('GR-P-ICG-24', 'invoice', 'tax', -100, '5400', '333', array['333']::text[], 100, 'GR-F2', 30),
    ('GR-P-ICG-24', 'credit_note', 'base', 100, null, '303', array['303', '364']::text[], -100, 'GR-F2', 10),
    ('GR-P-ICG-24', 'credit_note', 'tax', 100, '5401', '384', array['384']::text[], -100, 'GR-F2', 20),
    ('GR-P-ICG-24', 'credit_note', 'tax', -100, '5400', '333', array['333']::text[], -100, 'GR-F2', 30),
    ('GR-P-IMPORT', 'invoice', 'base', 100, null, '363', array['363']::text[], 100, 'GR-F2', 10),
    ('GR-P-IMPORT', 'invoice', 'tax', 100, '5401', '383', array['383']::text[], 100, 'GR-F2', 20),
    ('GR-P-IMPORT', 'credit_note', 'base', 100, null, '363', array['363']::text[], -100, 'GR-F2', 10),
    ('GR-P-IMPORT', 'credit_note', 'tax', 100, '5401', '383', array['383']::text[], -100, 'GR-F2', 20),
    ('GR-S-13', 'invoice', 'base', 100, null, '301', array['301']::text[], 100, 'GR-F2', 10),
    ('GR-S-13', 'invoice', 'tax', 100, '5400', '331', array['331']::text[], 100, 'GR-F2', 20),
    ('GR-S-13', 'credit_note', 'base', 100, null, '301', array['301']::text[], -100, 'GR-F2', 10),
    ('GR-S-13', 'credit_note', 'tax', 100, '5400', '331', array['331']::text[], -100, 'GR-F2', 20),
    ('GR-S-24', 'invoice', 'base', 100, null, '303', array['303']::text[], 100, 'GR-F2', 10),
    ('GR-S-24', 'invoice', 'tax', 100, '5400', '333', array['333']::text[], 100, 'GR-F2', 20),
    ('GR-S-24', 'credit_note', 'base', 100, null, '303', array['303']::text[], -100, 'GR-F2', 10),
    ('GR-S-24', 'credit_note', 'tax', 100, '5400', '333', array['333']::text[], -100, 'GR-F2', 20),
    ('GR-S-6', 'invoice', 'base', 100, null, '302', array['302']::text[], 100, 'GR-F2', 10),
    ('GR-S-6', 'invoice', 'tax', 100, '5400', '332', array['332']::text[], 100, 'GR-F2', 20),
    ('GR-S-6', 'credit_note', 'base', 100, null, '302', array['302']::text[], -100, 'GR-F2', 10),
    ('GR-S-6', 'credit_note', 'tax', 100, '5400', '332', array['332']::text[], -100, 'GR-F2', 20),
    ('GR-S-EXE', 'invoice', 'base', 100, null, '310', array['310']::text[], 100, 'GR-F2', 10),
    ('GR-S-EXE', 'credit_note', 'base', 100, null, '310', array['310']::text[], -100, 'GR-F2', 10),
    ('GR-S-EXP', 'invoice', 'base', 100, null, '348', array['348']::text[], 100, 'GR-F2', 10),
    ('GR-S-EXP', 'credit_note', 'base', 100, null, '348', array['348']::text[], -100, 'GR-F2', 10),
    ('GR-S-ICG', 'invoice', 'base', 100, null, '342', array['342']::text[], 100, 'GR-F2', 10),
    ('GR-S-ICG', 'credit_note', 'base', 100, null, '342', array['342']::text[], -100, 'GR-F2', 10),
    ('GR-S-ICS', 'invoice', 'base', 100, null, '345', array['345']::text[], 100, 'GR-F2', 10),
    ('GR-S-ICS', 'credit_note', 'base', 100, null, '345', array['345']::text[], -100, 'GR-F2', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'GR' and t.code = v.tax_code
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
  ('GR', 'GR-F2', 'Δήλωση Φ.Π.Α. — Φ2 (έντυπο 050 Φ.Π.Α.)', array['month', 'quarter']::declaration_period[], null, date '1970-01-01', null, 'Ν.5144/2024, άρθρο 59 — υποχρέωση υποβολής περιοδικής δήλωσης ΦΠΑ. Η περιοδικότητα εξαρτάται από την κατηγορία βιβλίων του υποκειμένου (μηνιαία για όσους τηρούν διπλογραφικά βιβλία, καθώς και για κάθε νέα έναρξη επιτηδεύματος τα πρώτα 24 μηνολόγια από 1.4.2025· τριμηνιαία για τους τηρούντες απλογραφικά βιβλία που είχαν ξεκινήσει δραστηριότητα πριν από την 31.12.2023), οπότε δεν δηλώνεται `period_default` — δεν υπάρχει μία απάντηση που να ισχύει για κάθε υποκείμενο. Εγκύκλιος Ε.2071/26.08.2025, για πράξεις που πραγματοποιούνται από 1.7.2025. `deadline` δεν δηλώνεται: η προθεσμία είναι η τελευταία εργάσιμη ημέρα του μήνα που ακολουθεί τη φορολογική περίοδο (Εθνικό Μητρώο Διοικητικών Διαδικασιών «Μίτος», διαδικασία «Δήλωση ΦΠΑ»· βλ. και το ΦΕΚ της απόφασης Α.1128/2025 για τις συναφείς προθεσμίες του Φ2 δεδομένης της ηλεκτρονικής τιμολόγησης) — η «τελευταία εργάσιμη ημέρα» δεν είναι πάντοτε η «τελευταία ημερολογιακή ημέρα» που εκφράζει το `last_day_of_month_after_period`, όποτε η τελευταία ημέρα του μήνα πέφτει Σάββατο, Κυριακή ή αργία, ούτε το πάγιο κλειστό λεξιλόγιο του `day_of_month_after_period` εκφράζει «τελευταία» χωρίς αριθμό. Βλ. την ενότητα «From Greece» του docs/international.md', true,null, null, null, null, null, null)
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
  ('GR', 'GR-F2', '301', 'base', 'Εκροές, Κατηγορία Ι (λοιπή Ελλάδα) — φορολογητέα αξία με συντελεστή 13%', '{"en":"Outputs, Category I (rest of Greece) — taxable amount at 13%"}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Έντυπο 050 Φ.Π.Α. (έκδοση 2025), πίνακας Β, στήλη α, κωδικός 301 — φορολογητέες εκροές στον μειωμένο συντελεστή 13%', 'e2071-2025'),
  ('GR', 'GR-F2', '331', 'tax', 'Εκροές, Κατηγορία Ι — ΦΠΑ αναλογούν στο 13%', '{"en":"Outputs, Category I — VAT on the 13% amount"}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Έντυπο 050 Φ.Π.Α. (έκδοση 2025), πίνακας Β, στήλη α, κωδικός 331', 'e2071-2025'),
  ('GR', 'GR-F2', '302', 'base', 'Εκροές, Κατηγορία Ι — φορολογητέα αξία με συντελεστή 6%', '{"en":"Outputs, Category I — taxable amount at 6%"}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Έντυπο 050 Φ.Π.Α. (έκδοση 2025), πίνακας Β, στήλη α, κωδικός 302 — φορολογητέες εκροές στον υπερμειωμένο συντελεστή 6%', 'e2071-2025'),
  ('GR', 'GR-F2', '332', 'tax', 'Εκροές, Κατηγορία Ι — ΦΠΑ αναλογούν στο 6%', '{"en":"Outputs, Category I — VAT on the 6% amount"}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Έντυπο 050 Φ.Π.Α. (έκδοση 2025), πίνακας Β, στήλη α, κωδικός 332', 'e2071-2025'),
  ('GR', 'GR-F2', '303', 'base', 'Εκροές, Κατηγορία Ι — φορολογητέα αξία με συντελεστή 24%', '{"en":"Outputs, Category I — taxable amount at 24%"}'::jsonb, 50, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Έντυπο 050 Φ.Π.Α. (έκδοση 2025), πίνακας Β, στήλη α, κωδικός 303 — φορολογητέες εκροές στον κανονικό συντελεστή 24%, περιλαμβανομένων και των ενδοκοινοτικών αποκτήσεων αγαθών στον ίδιο συντελεστή, ως πράξεων λήπτη', 'e2071-2025'),
  ('GR', 'GR-F2', '333', 'tax', 'Εκροές, Κατηγορία Ι — ΦΠΑ αναλογούν στο 24%', '{"en":"Outputs, Category I — VAT on the 24% amount"}'::jsonb, 60, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Έντυπο 050 Φ.Π.Α. (έκδοση 2025), πίνακας Β, στήλη α, κωδικός 333', 'e2071-2025'),
  ('GR', 'GR-F2', '307', 'total', 'Σύνολο φορολογητέων εκροών (Κατηγορία Ι)', '{"en":"Total taxable outputs (Category I)"}'::jsonb, 70, null, array['301', '302', '303']::text[], '{}'::text[], null, null, false, false, null, 'Έντυπο 050 Φ.Π.Α. (έκδοση 2025), πίνακας Β, κωδικός 307. Το πακέτο αυτό δεν διαμορφώνει ακόμη φορολογικούς κωδικούς για τους μειωμένους κατά 30% συντελεστές της Κατηγορίας ΙΙ (νησιά του Αιγαίου, κωδικοί 304-306, 309 του εντύπου) — βλ. README και ενότητα «From Greece» του docs/international.md· το άθροισμα εδώ αφορά συνεπώς μόνον την Κατηγορία Ι', 'e2071-2025'),
  ('GR', 'GR-F2', '337', 'total', 'Σύνολο ΦΠΑ εκροών (Κατηγορία Ι)', '{"en":"Total output VAT (Category I)"}'::jsonb, 80, null, array['331', '332', '333']::text[], '{}'::text[], null, null, false, false, null, 'Έντυπο 050 Φ.Π.Α. (έκδοση 2025), πίνακας Β, κωδικός 337', 'e2071-2025'),
  ('GR', 'GR-F2', '310', 'base', 'Εκροές απαλλασσόμενες ή εκτός πεδίου, χωρίς δικαίωμα έκπτωσης', '{"en":"Exempt or out-of-scope outputs, without the right to deduct"}'::jsonb, 90, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Έντυπο 050 Φ.Π.Α. (έκδοση 2025), πίνακας Β, κωδικός 310 — παραδόσεις αγαθών και παροχές υπηρεσιών απαλλασσόμενες κατ'' άρθρο 27 του Κώδικα ΦΠΑ', 'e2071-2025'),
  ('GR', 'GR-F2', '342', 'base', 'Ενδοκοινοτικές παραδόσεις αγαθών', '{"en":"Intra-Community supplies of goods"}'::jsonb, 100, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Έντυπο 050 Φ.Π.Α. (έκδοση 2025), πίνακας Β, κωδικός 342 — παραδόσεις αγαθών απαλλασσόμενες κατ'' άρθρο 33 του Κώδικα ΦΠΑ', 'e2071-2025'),
  ('GR', 'GR-F2', '345', 'base', 'Ενδοκοινοτικές παροχές υπηρεσιών με αντίστροφη επιβάρυνση του λήπτη', '{"en":"Intra-Community supplies of services, reverse-charged to the customer"}'::jsonb, 110, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Έντυπο 050 Φ.Π.Α. (έκδοση 2025), πίνακας Β, κωδικός 345 — παροχές υπηρεσιών προς υποκείμενο στον φόρο άλλου κράτους μέλους, φορολογούμενες στον τόπο εγκατάστασης του λήπτη κατ'' άρθρο 14, παρ. 2 του Κώδικα ΦΠΑ', 'e2071-2025'),
  ('GR', 'GR-F2', '348', 'base', 'Εξαγωγές και εξομοιούμενες πράξεις', '{"en":"Exports and assimilated transactions"}'::jsonb, 120, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Έντυπο 050 Φ.Π.Α. (έκδοση 2025), πίνακας Β, κωδικός 348 — παραδόσεις απαλλασσόμενες κατ'' άρθρο 29 του Κώδικα ΦΠΑ', 'e2071-2025'),
  ('GR', 'GR-F2', '311', 'total', 'Σύνολο εκροών (κύκλος εργασιών)', '{"en":"Total outputs (turnover)"}'::jsonb, 130, null, array['307', '310', '342', '345', '348']::text[], '{}'::text[], null, null, false, false, null, 'Έντυπο 050 Φ.Π.Α. (έκδοση 2025), πίνακας Β, κωδικός 311. Δεν αφαιρούνται εδώ οι κωδικοί 313-315 (πράξεις εξαιρούμενες από τον κύκλο εργασιών ΦΠΑ, κωδικός 312 του εντύπου), τους οποίους το πακέτο αυτό δεν διαμορφώνει ακόμη', 'e2071-2025'),
  ('GR', 'GR-F2', '361', 'base', 'Αγορές και δαπάνες στο εσωτερικό της χώρας, με δικαίωμα έκπτωσης', '{"en":"Domestic purchases and expenses, with the right to deduct"}'::jsonb, 140, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Έντυπο 050 Φ.Π.Α. (έκδοση 2025), πίνακας Β, στήλη β, κωδικός 361. Το πακέτο αυτό δεν διακρίνει ακόμη τις αγορές παγίων (κωδικός 362 του εντύπου) από τις λοιπές αγορές και δαπάνες: όλες οι αγορές στο εσωτερικό της χώρας αναγράφονται εδώ', 'e2071-2025'),
  ('GR', 'GR-F2', '381', 'tax', 'ΦΠΑ εκπιπτόμενο επί αγορών και δαπανών εσωτερικού', '{"en":"Deductible VAT on domestic purchases and expenses"}'::jsonb, 150, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Έντυπο 050 Φ.Π.Α. (έκδοση 2025), πίνακας Β, στήλη β, κωδικός 381', 'e2071-2025'),
  ('GR', 'GR-F2', '363', 'base', 'Εισαγωγές αγαθών από τρίτες χώρες, εκτός παγίων', '{"en":"Imports of goods from third countries"}'::jsonb, 160, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Έντυπο 050 Φ.Π.Α. (έκδοση 2025), πίνακας Β, στήλη β, κωδικός 363', 'e2071-2025'),
  ('GR', 'GR-F2', '383', 'tax', 'ΦΠΑ εκπιπτόμενο επί εισαγωγών', '{"en":"Deductible VAT on imports"}'::jsonb, 170, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Έντυπο 050 Φ.Π.Α. (έκδοση 2025), πίνακας Β, στήλη β, κωδικός 383', 'e2071-2025'),
  ('GR', 'GR-F2', '364', 'base', 'Ενδοκοινοτικές αποκτήσεις αγαθών', '{"en":"Intra-Community acquisitions of goods"}'::jsonb, 180, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Έντυπο 050 Φ.Π.Α. (έκδοση 2025), πίνακας Β, στήλη β, κωδικός 364', 'e2071-2025'),
  ('GR', 'GR-F2', '384', 'tax', 'ΦΠΑ εκπιπτόμενο επί ενδοκοινοτικών αποκτήσεων αγαθών', '{"en":"Deductible VAT on intra-Community acquisitions of goods"}'::jsonb, 190, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Έντυπο 050 Φ.Π.Α. (έκδοση 2025), πίνακας Β, στήλη β, κωδικός 384', 'e2071-2025'),
  ('GR', 'GR-F2', '367', 'total', 'Σύνολο φορολογητέων εισροών', '{"en":"Total taxable inputs"}'::jsonb, 200, null, array['361', '363', '364']::text[], '{}'::text[], null, null, false, false, null, 'Έντυπο 050 Φ.Π.Α. (έκδοση 2025), πίνακας Β, κωδικός 367. Δεν περιλαμβάνονται εδώ οι κωδικοί 362 (αγορές παγίων, βλ. κωδικό 361), 365 (ενδοκοινοτικές λήψεις υπηρεσιών) και 366 (λοιπές πράξεις λήπτη), τους οποίους το πακέτο αυτό δεν διαμορφώνει ακόμη', 'e2071-2025'),
  ('GR', 'GR-F2', '387', 'total', 'Σύνολο εκπιπτόμενου ΦΠΑ εισροών', '{"en":"Total deductible input VAT"}'::jsonb, 210, null, array['381', '383', '384']::text[], '{}'::text[], null, null, false, false, null, 'Έντυπο 050 Φ.Π.Α. (έκδοση 2025), πίνακας Β, κωδικός 387', 'e2071-2025'),
  ('GR', 'GR-F2', '480', 'total', 'Χρεωστικό υπόλοιπο — ΦΠΑ πληρωτέο', '{"en":"Debit balance — VAT payable"}'::jsonb, 220, null, array['337']::text[], array['387']::text[], null, null, true, false, null, 'Έντυπο 050 Φ.Π.Α. (έκδοση 2025), πίνακας Γ, κωδικός 480 — εκκαθάριση, χρεωστικό υπόλοιπο όταν το σύνολο ΦΠΑ εκροών υπερβαίνει το σύνολο εκπιπτόμενου ΦΠΑ εισροών. Δεν λαμβάνονται υπόψη οι κωδικοί 401/403/404 (πιστωτικό υπόλοιπο προηγούμενης περιόδου) ούτε ο συμψηφισμός των κωδικών 402/407/411/422/423, τους οποίους το πακέτο αυτό δεν διαμορφώνει ακόμη', 'e2071-2025'),
  ('GR', 'GR-F2', '470', 'total', 'Πιστωτικό υπόλοιπο προς μεταφορά ή επιστροφή', '{"en":"Credit balance to carry forward or claim back"}'::jsonb, 230, null, array['387']::text[], array['337']::text[], null, null, true, false, null, 'Έντυπο 050 Φ.Π.Α. (έκδοση 2025), πίνακας Γ, κωδικός 470 — εκκαθάριση, πιστωτικό υπόλοιπο όταν το σύνολο εκπιπτόμενου ΦΠΑ εισροών υπερβαίνει το σύνολο ΦΠΑ εκροών', 'e2071-2025')
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
  ('GR', 'Ελλάδα', '{"en":"Greece"}'::jsonb, array['el', 'en']::text[], 'EUR', '3000', '5000', '5800', null, '4200', '7000', '2002', '3803', '3800', 'SAL', 'PUR', 'DIV', 'el', 'result_accounts', '8600', '8600', null, 'OPN', 'half_up', default, '7600', '6500', null, null, null, null, '5402', '3301', 'Άνοιγμα λογαριασμών', null)
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
  late_payment_reference        = 'Ν.4152/2013, υποπαράγραφος Ζ.3 — ελλείψει συμφωνίας, τριάντα ημέρες από την παραλαβή του τιμολογίου ή ισοδύναμης αίτησης πληρωμής· τόκος υπερημερίας ίσος με το επιτόκιο αναφοράς της Ευρωπαϊκής Κεντρικής Τράπεζας για τις πλέον πρόσφατες πράξεις αναχρηματοδότησης προσαυξημένο κατά οκτώ ποσοστιαίες μονάδες, χωρίς όχληση· υποπαράγραφος Ζ.7 — κατ'' αποκοπή αποζημίωση σαράντα (40) ευρώ για τα έξοδα είσπραξης, οφειλόμενη χωρίς όχληση ή απόδειξη',
  numbering_legal_reference     = 'Ν.4308/2014, άρθρο 8 — το τιμολόγιο εκδίδεται με μοναδική και συνεχόμενη αρίθμηση, ανά σειρά εάν τηρούνται περισσότερες της μίας. Η ετήσια επανεκκίνηση της αρίθμησης ανά σειρά δεν επιβάλλεται ρητά από τον νόμο αλλά είναι η καθιερωμένη πρακτική σύμβαση, ιδίως λόγω της ετήσιας δομής χαρακτηρισμού των παραστατικών στο myDATA',
  numbering_source_key          = 'n4308-2014',
  payment_terms_legal_reference = 'Ν.4152/2013, υποπαράγραφος Ζ.3 — ελλείψει συμβατικού όρου, η προθεσμία πληρωμής είναι τριάντα ημέρες από την παραλαβή του τιμολογίου ή των αγαθών/υπηρεσιών, όποιο είναι μεταγενέστερο',
  payment_terms_source_key      = 'n4152-2013',
  tax_point_rule                = 'invoice_if_issued',
  tax_point_legal_reference     = 'Ν.5144/2024, άρθρο 21, παρ. 1 — η φορολογική υποχρέωση γεννάται και ο φόρος καθίσταται απαιτητός κατά τον χρόνο πραγματοποίησης της παράδοσης των αγαθών ή της παροχής των υπηρεσιών· παρ. 2, περ. α) — όταν εκδίδεται τιμολόγιο πριν από τον χρόνο αυτόν, ο φόρος καθίσταται απαιτητός κατά τον χρόνο έκδοσης του τιμολογίου, μέχρι το ποσό που αναγράφεται σε αυτό. Ο γενικός κανόνας είναι συνεπώς η παράδοση ή η ολοκλήρωση της υπηρεσίας, με το τιμολόγιο που εκδίδεται νωρίτερα να μετατοπίζει το απαιτητό στη δική του ημερομηνία',
  tax_point_source_key          = 'n5144-2024',
  posted_edit_policy            = 'reversal_only',
  posted_edit_policy_legal_reference = 'Απόφαση Α.1138/2020, άρθρο 4 — ένα παραστατικό που έχει διαβιβαστεί στο myDATA δεν αναιρείται· διορθώνεται μόνο με παραστατικό αντίστροφης λογικής (πιστωτικό τιμολόγιο) που το επικαλείται. Ν.4308/2014, άρθρο 3, παρ. 3 — τα λογιστικά αρχεία πρέπει να τηρούνται με τρόπο που να διασφαλίζει την ακεραιότητα και τη μονιμότητα των καταχωρίσεων',
  posted_edit_policy_source_key = 'mydata-a1138-2020',
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_legal_reference      = 'Κατά την 25η Σεπτεμβρίου 2026, η ηλεκτρονική τιμολόγηση B2B στην Ελλάδα βρίσκεται σε σταδιακή εφαρμογή. Η Council Implementing Decision (EU) 2025/502 (5.3.2025) επιτρέπει στην Ελλάδα να καταστήσει υποχρεωτική την ηλεκτρονική τιμολόγηση κατά παρέκκλιση των άρθρων 218 και 232 της Οδηγίας 2006/112/ΕΚ, από 1.7.2025. Ο εθνικός νόμος που θεσπίζει την υποχρέωση είναι το άρθρο 239 του Ν.5222/2025 (ΦΕΚ Α'' 134/28.07.2025), που προσέθεσε την παρ. 6 στο άρθρο 14 του Ν.4308/2014 (ΕΛΠ). Η απόφαση εφαρμογής Α.1128/2025 (ΦΕΚ Β'' 4937/16.09.2025) επιβάλλει τη μορφή EN 16931, διαβιβαζόμενη μέσω της εφαρμογής «Τιμολόγιο» της ΑΑΔΕ ή μέσω πιστοποιημένου παρόχου ηλεκτρονικής τιμολόγησης — ένα μοντέλο παρόχων, όχι κεντρικής θεώρησης (clearance) όπως στην Ιταλία — και ορίζει το χρονοδιάγραμμα σε δύο φάσεις: για τις οντότητες με ακαθάριστα έσοδα άνω του 1.000.000 ευρώ το 2023, αποκλειστική ηλεκτρονική έκδοση από 2.2.2026 (ανοχή διπλής έκδοσης έως 31.3.2026)· για όλες τις υπόλοιπες οντότητες, από 1.10.2026 (ανοχή έως 31.12.2026). Οι ημερομηνίες αυτές προέρχονται από το κείμενο της ίδιας της απόφασης και πρέπει πάντως να επιβεβαιωθούν στο aade.gr πριν χρησιμοποιηθούν, καθώς έχουν ήδη μετατεθεί μία φορά σε σχέση με προηγούμενες ανακοινώσεις. Κανένα τμήμα του packages/formats δεν γράφει, επικυρώνει ή διαβιβάζει σήμερα ένα παραστατικό στη μορφή που η ΑΑΔΕ ή ένας πάροχος απαιτεί (ούτε είναι βεβαιωμένο ότι το δίκτυο Peppol χρησιμοποιείται για τη διαβίβαση αυτή)· η δήλωση profile θα ισχυριζόταν το αντίθετο. Ξεχωριστά, και ανεξάρτητα από την ίδια την ηλεκτρονική τιμολόγηση, το myDATA (απόφαση Α.1138/2020, άρθρο 15Α του Ν.4174/2013) επιβάλλει από το 2021 τη διαβίβαση σχεδόν σε πραγματικό χρόνο της σύνοψης κάθε παραστατικού σε όλες τις επιχειρήσεις — μία υποχρέωση αναφοράς δεδομένων προς το κράτος, όχι ανταλλαγή δομημένου τιμολογίου μεταξύ των μερών, οπότε δεν αντιστοιχεί σε κανένα πεδίο αυτής της ενότητας. Βλ. το README του πακέτου και την ενότητα «From Greece» του docs/international.md',
  einvoice_source_key           = 'a1128-2025',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = array['camt.053']::text[],
  payment_formats               = array['pain.001']::text[],
  fiscal_year_default           = 'calendar'
 where country = 'GR';

insert into legal_mention_templates
  (country, code, applies_when, text, text_i18n, sequence, valid_from, valid_to, legal_reference)
values
  ('GR', 'reverse_charge', 'reverse_charge', 'Αντίστροφη επιβάρυνση — υπόχρεος για την καταβολή του φόρου είναι ο λήπτης.', '{"en":"Reverse charge — the customer is liable for the tax."}'::jsonb, 10, date '1970-01-01', null, 'Ν.5144/2024, άρθρο 39γ και άρθρο 63 — υποχρέωση αναγραφής της ένδειξης στα παραστατικά που εκδίδονται χωρίς χρέωση φόρου λόγω αντιστροφής της υποχρέωσης'),
  ('GR', 'intracom_goods', 'intra_eu_goods', 'Απαλλάσσεται από τον ΦΠΑ — ενδοκοινοτική παράδοση αγαθών, άρθρο 33 του Κώδικα ΦΠΑ.', '{"en":"VAT exempt — intra-Community supply of goods, article 33 of the VAT Code."}'::jsonb, 20, date '1970-01-01', null, 'Ν.5144/2024, άρθρο 33 — απαλλαγή της παράδοσης αγαθών που αποστέλλονται ή μεταφέρονται σε άλλο κράτος μέλος προς υποκείμενο στον φόρο εκεί εγγεγραμμένο· άρθρο 138 της Οδηγίας 2006/112/ΕΚ'),
  ('GR', 'intracom_services', 'intra_eu_services', 'Αντίστροφη επιβάρυνση — άρθρα 14 και 39γ του Κώδικα ΦΠΑ, άρθρα 44 και 196 της Οδηγίας 2006/112/ΕΚ.', '{"en":"Reverse charge — articles 14 and 39c of the VAT Code, articles 44 and 196 of Directive 2006/112/EC."}'::jsonb, 30, date '1970-01-01', null, 'Ν.5144/2024, άρθρο 14, παρ. 2 — ο τόπος παροχής γενικής υπηρεσίας προς υποκείμενο στον φόρο είναι ο τόπος εγκατάστασής του, με τον λήπτη υπόχρεο για τον φόρο κατ'' άρθρο 39γ'),
  ('GR', 'export', 'export', 'Απαλλάσσεται από τον ΦΠΑ — εξαγωγή εκτός Ευρωπαϊκής Ένωσης, άρθρο 29 του Κώδικα ΦΠΑ.', '{"en":"VAT exempt — export outside the European Union, article 29 of the VAT Code."}'::jsonb, 40, date '1970-01-01', null, 'Ν.5144/2024, άρθρο 29 — απαλλαγές στην παράδοση αγαθών κατά την εξαγωγή εκτός της Ευρωπαϊκής Ένωσης και τις εξομοιούμενες προς αυτές πράξεις'),
  ('GR', 'exempt', 'exempt', 'Απαλλάσσεται από τον ΦΠΑ, άρθρο 27 του Κώδικα ΦΠΑ.', '{"en":"VAT exempt, article 27 of the VAT Code."}'::jsonb, 50, date '1970-01-01', null, 'Ν.5144/2024, άρθρο 27 — απαλλαγές στο εσωτερικό της χώρας')
on conflict (country, code) do update set
  applies_when    = excluded.applies_when,
  text            = excluded.text,
  text_i18n       = excluded.text_i18n,
  sequence        = excluded.sequence,
  valid_from      = excluded.valid_from,
  valid_to        = excluded.valid_to,
  legal_reference = excluded.legal_reference;
