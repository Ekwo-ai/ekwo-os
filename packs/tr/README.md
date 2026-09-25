# Türkiye

Ekwo'ya Türkiye'nin eklediği her şey, veri olarak: Tekdüzen Hesap Planı'nın
resmî üç haneli ana hesapları, %20/%10/%1 oranlı Katma Değer Vergisi'yle
ihracat istisnası, BSMV kapsamındaki istisna, ithalatta gümrükte ödenen ve
yurt dışından alınan hizmetlerde sorumlu sıfatıyla ödenen KDV, 1 No'lu KDV
Beyannamesinin kanunun ve tebliğin sözünü ettiği içeriğe dayanan bir modeli,
ve Tekdüzen bilânço ile gelir tablosu. Format
[`docs/packs.md`](../../docs/packs.md)'dedir; bu dosya içeriğin nereden
geldiğini ve hangi kararlara dayandığını anlatır, böylece Türkiye'yi bilen
bir muhasebeci pack'in tamamına değil, belirli bir cümleye itiraz edebilir.

**Durum: `community`.** Bir Türk KDV beyannamesi veren kimse bu pack'i henüz
okumadı. Rakamlar `tests/golden.test.ts` tarafından bir yıllık defter
kayıtlarına karşı yeniden oynatılır — bu, pack'in kendi içinde tutarlı
olduğunu kanıtlar, doğru olduğunu değil.

**Pack tamamen Türkçe yazılmıştır** (`defaults.language: "tr"`), çünkü
kaynak aldığı her metin — 3065 sayılı Kanun, Katma Değer Vergisi Genel
Uygulama Tebliği, 1 Sıra No'lu Muhasebe Sistemi Uygulama Genel Tebliği —
zaten resmî Türkçedir. Diğer paketlerin İngilizce etiketlere başvurduğu
durum (referans planın yerel dilde resmî bir sürümü olmaması) burada söz
konusu değildir: Tekdüzen Hesap Planı'nın kendisi Türkçe bir devlet
tebliğidir. Bu yüzden bu ilk sürümde `languages: []` bırakılmıştır ve
`i18n/` altında yalnızca bir [`README.md`](i18n/README.md) vardır.

## Kaynaklar

Her vergi, kutu, ibare ve tablo satırı kendi `legal_reference`'ını taşır ve
yanında hangi metnin bu maddeyi içerdiğini gösteren anahtarı. `pack.json`
kayıt defteri yedi metin taşır, hepsi 25 Eylül 2026'da açılmıştır. En çok
dayanılan üçü:

| Ne | Metin | Nerede |
|---|---|---|
| Verginin konusu, oran, istisnalar, sorumluluk, indirim, beyan ve ödeme | 3065 sayılı Katma Değer Vergisi Kanunu | mevzuat.gov.tr |
| Oranların kendisi (%20, %10, %1) | 2007/13033 sayılı Bakanlar Kurulu Kararı, 7346 sayılı Cumhurbaşkanı Kararı ile değişik | resmigazete.gov.tr |
| Hesap çerçevesi, hesap planı, bilânço ve gelir tablosu şemaları | 1 Sıra No'lu Muhasebe Sistemi Uygulama Genel Tebliği | resmigazete.gov.tr |

## Hesap planı, ve neden bu hesaplar

**Tekdüzen Hesap Planı, Saudi Arabia ya da UAE paketlerinin aksine, isteğe
bağlı bir seçim değil, kanuni bir zorunluluktur.** Bilânço esasına göre
defter tutan her gerçek ve tüzel kişi, 1 Sıra No'lu Muhasebe Sistemi
Uygulama Genel Tebliği'nin belirlediği üç haneli ana hesapları 1/1/1994'ten
beri aynen kullanmak zorundadır — bir işletme dördüncü haneden itibaren
serbesttir, ama üç haneli çerçevenin kendisini değiştiremez. Bu pack'in
`accounts.csv`'si bu yüzden **orijinal bir tasarım değil, Tebliğ'in
kendisinin transkripsiyonudur**: 180 hesabın tamamı Tebliğ'de aynı numara ve
aynı adla yer alır, iki istisna dışında —

- **`1369` (Geçici Hesap)**, `136 Diğer Çeşitli Alacaklar`'ın altına bu
  pack'in eklediği dört haneli bir alt hesaptır: askıya alınan işlemler
  için bir hesap (`defaults.roles.suspense`), asla banka, kasa ya da bir
  lettrable vergi hesabı olmayan.
- **`3600` (Ödenecek Katma Değer Vergisi)**, `360 Ödenecek Vergi ve
  Fonlar`'ın altına eklenen bir alt hesaptır: beyannamenin sonucunun
  yattığı, `391`/`191`'den ayrı ve lettrable (`defaults.roles.tax_payable`)
  bir hesap — SK pack'inin öğrettiği kural, KDV'nin hesaplandığı hesapla
  beyannamenin sonucunun yattığı hesap aynı olamaz.

Tebliğ'in ayrıntılı alt gruplarının tamamı bu ilk sürümde yoktur — menkul
kıymetler, mali duran varlıklar, sermaye yedekleri, yıllara yaygın inşaat
hesapları gibi bu golden'ın hiç ihtiyaç duymadığı gruplar eklenmemiştir; bu
bir tasarım kararı değil, henüz yazılmamış bir eksikliktir.

## Vergiler

**Üç oran, tek bir madde.** 3065 sayılı Kanun'un 28'inci maddesi KDV
oranını %10 olarak belirler ve Cumhurbaşkanı'na bu oranı dört katına kadar
artırma, %1'e kadar indirme yetkisi verir. Bu yetkiye dayanan 2007/13033
sayılı Bakanlar Kurulu Kararı üç oran belirlemişti: (I) sayılı listedeki
işlemler için %1, (II) sayılı listedekiler için %8, geri kalan her şey için
%18. 7346 sayılı Cumhurbaşkanı Kararı, 10 Temmuz 2023'ten itibaren genel
oranı %20'ye, (II) sayılı listedeki oranı %10'a yükseltmiş, %1'lik oranda
bir değişiklik yapmamıştır.

| | Kod | Kutu | Kategori |
|---|---|---|---|
| Genel oran, %20 | `TR-S-SR` | m20/t20 | S |
| İndirimli oran, %10 — (II) sayılı liste | `TR-S-RR10` | m10/t10 | S |
| İndirimli oran, %1 — (I) sayılı liste | `TR-S-RR1` | m1/t1 | S |
| İhracat istisnası (tam istisna), madde 11/1-a | `TR-S-ZR-EXP` | mihr | G |
| BSMV kapsamındaki işlemler, madde 17/4-e | `TR-S-EX-FIN` | mist | E |
| Verginin konusuna girmeyen işlem | `TR-S-OS` | yok | O |

**(I) ve (II) sayılı listelerin kendisi bu pack'te madde madde yoktur.**
Hangi malın ya da hizmetin hangi listede olduğu 2007/13033 sayılı Kararın
ekinde okunmalıdır; bu pack yalnızca oranın kendisini ve hangi maddenin onu
belirlediğini taşır.

**İthalat, Körfez paketlerinin (`ae`, `sa`) aksine bir sorumluluk
(reverse charge) değildir.** Madde 46/2 açıktır: "İthalde alınan katma
değer vergisi, gümrük vergisi ile birlikte ve aynı zamanda ödenir." Gümrük
vergisine tabi olmayan ithalatta ise gümrük beyannamesinin tescili anında
ödenir (madde 10/ı, madde 40/2). Matrah madde 21'e göre malın gümrük
vergisi tarhına esas kıymeti (bulunmadığında CİF değeri) artı ithalat
sırasında ödenen her türlü vergi, resim, harç ve paydır. `TR-P-IMP` bu
yüzden bir kendi kendine beyan (self-assessment) hilesi kullanmaz: KDV
doğrudan `191`'e (indirilecek KDV) yazılır, aynı `sa`/`ae` paketlerinde
`box g2` üzerinden yapılan ters çevirme burada yoktur.

**Yurt dışından alınan hizmet ayrı bir mekanizmadır.** Türkiye'de ikametgâhı,
işyeri, kanuni ve iş merkezi bulunmayan bir satıcıdan alınan ve Türkiye'de
faydalanılan bir hizmette, hizmeti alan KDV'yi madde 9 uyarınca sorumlu
sıfatıyla kendisi hesaplar ve **ayrı bir beyanname olan 2 No'lu KDV
Beyannamesi** ile beyan edip öder. `TR-P-RC-SVC` bu ikiliği yansıtır: kendi
kendine hesaplanan KDV borcu (`392` hesabı) hiçbir kutuya yazılmaz — çünkü
o beyanname bu pack'in `tax_report.json`'ının dışındadır — ama aynı madde 29
uyarınca aynı dönemde 1 No'lu beyannamede indirim konusu yapılan pay
(`191` hesabı) `trc` kutusuna yazılır. **2 No'lu KDV Beyannamesinin kendisi
bu pack'te modellenmemiştir.**

## Beyanname

`tax_report.json`, GİB'in canlı e-Beyanname ekranının kutu numaralarını
değil — bu araştırma sırasında böyle bir metne tek başına erişilebilir bir
biçimde ulaşılamamıştır — 3065 sayılı Kanun'un ve Katma Değer Vergisi Genel
Uygulama Tebliği'nin beyannameden istediği **içeriği** taşır: oran bazında
matrah ve hesaplanan KDV, istisna kapsamındaki bedeller, indirilecek KDV'nin
üç kaynağı (yurtiçi alış, ithalat, sorumlu sıfatıyla indirilen pay) ve
sonucun kendisi. **Ekranın box numaralarını bilen bir kişi bunu ilk kontrol
etmelidir.**

**Aylık, tek bir cadence.** Madde 39 vergilendirme dönemini takvim yılının
birer aylık dönemleri olarak belirler; başka bir cadence yoktur.

**Kanuni gün 24, fiilen uygulanan gün 28'dir.** Madde 41/1 beyannamenin ve
madde 46/1 ödemenin, izleyen ayın 24'üncü günü akşamına kadar yapılmasını
ister. 149 Sıra No'lu Vergi Usul Kanunu Sirküleri, 1 Aralık 2022'den
itibaren verilecek KDV beyannamelerinin verilme ve ödeme süresini, yeni bir
belirleme yapılıncaya kadar, izleyen ayın 28'inci gününe uzatmıştır — bu
pack fiilen uygulanan günü (28) taşır.

**Sorumlu sıfatıyla verilen 2 No'lu KDV Beyannamesinin kendi süresi
farklıdır** (izleyen ayın 21'inci günü, 164 No'lu Sirküler ile 25'inci güne
uzatılmıştır) ve bu pack'in `deadline` alanı bunu taşımaz: `tax_report.json`
yalnızca 1 No'lu KDV Beyannamesini modeller.

## Hesap durumu

`tax_payable` `3600`, `tax_receivable` `192`'dir. İkisi de `391`
(Hesaplanan KDV) ve `191`/`190` (İndirilecek/Devreden KDV) hesaplarından
ayrıdır ve lettrable'dır: bir beyannamenin sonucu bu hesaplarda tahsil
edilir ya da ödenir.

## Bilânço ve gelir tablosu

`statements.json`, 1 Sıra No'lu Tebliğ'in ekindeki bilânço (Aktif: I. Dönen
Varlıklar, II. Duran Varlıklar; Pasif: III. Kısa Vadeli Yabancı Kaynaklar,
IV. Uzun Vadeli Yabancı Kaynaklar, V. Özkaynaklar) ve gelir tablosu (A'dan
J'ye) şemalarını taşır. `690`, `691`, `692` hesapları bu pack'te birer
gerçek defter hesabı olarak yoktur: Tebliğ'de bunlar dönem sonunda
kapatılan, hesaplama amaçlı gelir tablosu hesaplarıdır, ve bu pack aynı
sonucu doğrudan gerçek gelir/gider hesaplarından hesaplanan bir toplam
(`GT.DKZ`, `GT.NKZ`) olarak sunar — hiçbir golden belgesi `690`/`691`/`692`'ye
kayıt yapmaz. `370` (Dönem Karı Vergi ve Diğer Yasal Yükümlülük
Karşılıkları) gerçek bir hesaptır ama bu pack'in hiçbir vergi kodu ona
kayıt yapmaz; bir şirketin kurumlar vergisi karşılığını elle kaydetmesi
için vardır. Fact key'ler (`xbrl`) her yerde null'dur: Türkiye'nin bir XBRL
taksonomisi kullanıp kullanmadığı bu araştırmada doğrulanmamıştır.

## Faturada

**Numaralandırma `gapless_per_year`'dır.** 213 sayılı Vergi Usul Kanunu'nun
230'uncu maddesi faturada düzenlenme tarihi ile seri ve sıra numarasının
bulunmasını, 231'inci maddesi bu numaraların sıra dahilinde teselsül
ettirilmesini ister. e-Fatura ve e-Arşiv Fatura'da bu numara, GİB'in teknik
kılavuzlarının belirlediği üç karakterlik seri, dört haneli yıl ve dokuz
haneli sayaçtan oluşan on altı karakterlik bir biçimde üretilir.

**Vergiyi doğuran olay iki aşamalıdır.** Madde 10(a) kural olarak malın
teslimini veya hizmetin ifasını esas alır; (b) bendi, teslim veya ifadan
önce fatura düzenlenmişse, vergiyi bu belgenin düzenlenmesi anına — belgede
gösterilen miktarla sınırlı olmak üzere — ileri çeker. Bu, Belçika'nın
madde 16/22 - 17/22bis'i ve Lüksemburg'un madde 21 - 24, par. 1'i gibi bir
kural-ve-istisna çiftidir, bu yüzden `invoice_if_issued` olarak
kodlanmıştır.

**`posted_edit_policy` `reversal_only`'dir.** 6102 sayılı Türk Ticaret
Kanunu'nun 64'üncü maddesinin üçüncü fıkrası, ticari defterlere yapılan bir
kaydın izleyen bir düzeltme kaydı düşülmeden değiştirilmesini yasaklar; 213
sayılı Kanun'un 231'inci maddesi fatura numaralarının teselsülünü ister.
İşlenmiş bir belgeyi taslağa geri döndürmek her ikisini de ihlal eder;
düzeltme bir alacak dekontu iledir.

**Ödeme vadesi ve gecikme faizi bu pack'te yoktur.** Bu araştırma, işletmeler
arası bir işlemde anlaşma yokluğunda uygulanacak kanuni bir vadeyi (6102
sayılı Türk Ticaret Kanunu'nun geç ödeme hükümleri dâhil) doğrulamadı; bu
`docs/international.md`'de Türkiye bölümünde ayrıca kaydedilmiştir.

## e-Fatura ve e-Arşiv Fatura

`einvoicing.profile` ve `party_scheme`/`vat_scheme` boş bırakılmıştır — bu
`sa`, `mx`, `vn` ve `kr` paketlerinin aynı alanları boş bırakma nedeniyle
aynıdır: e-Fatura ve e-Arşiv Fatura bir EN 16931 profili
(Peppol BIS, Factur-X, XRechnung, bir PINT) üzerinden iki tarafın kendi
erişim noktaları arasında bir değişim değil, belgenin GİB'in kendi platformu
ya da GİB onaylı bir özel entegratör üzerinden idareye iletildiği bir teyit
modelidir; `packages/formats/`'ın hiçbir bileşeni UBL-TR yazmaz ya da
GİB'e ulaştırmaz. `obligation` de bu yüzden boş bırakılmıştır: yükümlülük
gerçek ve süreklidir (509 Sıra No'lu Vergi Usul Kanunu Genel Tebliği ve
sonraki değişiklikleri, 213 sayılı Kanun'un mükerrer 257'nci maddesindeki
yetkiye dayanarak), ama tek bir tarihe değil, mükellefin bir önceki yıl
brüt satış hasılatına bağlıdır — bu araştırmanın ulaştığı en güncel eşik,
3.000.000 TL (genel), e-ticaret/gayrimenkul/motorlu taşıt ticareti için
500.000 TL'dir, ve 1 Ocak 2026'dan itibaren bilanço esasına göre defter
tutan hiçbir mükellef kâğıt fatura düzenleyemez.

## Bu pack'in taşımadıkları

- **(I) ve (II) sayılı listelerin madde madde içeriği.** Hangi malın hangi
  oranda olduğu, 2007/13033 sayılı Kararın ekinde okunmalıdır.
- **Kısmi ve tam tevkifat (domestic withholding).** Madde 9'un dayandığı
  Katma Değer Vergisi Genel Uygulama Tebliği I/C-2.1.3, onlarca hizmet ve
  teslim türü için değişen kesirlerde (2/10, 5/10, 7/10, 9/10 gibi) bir
  kısmi sorumluluk listesi taşır; bu pack yalnızca sorumlu sıfatıyla tam
  KDV'yi (yurt dışından hizmet alımı, madde 9/1) modeller, yurtiçi kısmi
  tevkifatın hiçbirini kodlamaz.
- **2 No'lu KDV Beyannamesinin kendisi.** Sorumlu sıfatıyla ödenen KDV'nin
  bu ayrı beyannamede beyan edilmesi, bu pack'in `tax_report.json`'ının
  dışındadır; yalnızca 1 No'lu beyannamedeki indirim payı taşınır.
- **e-Fatura'nın kendi XML'i.** UBL-TR'yi yazan, imzasını atan ve GİB'e ya da
  bir özel entegratöre ileten bir `packages/formats/` bileşeni yoktur.
- **Kurumlar vergisi.** `370` hesabı elle kayıt için vardır, hiçbir vergi
  kodu ona kayıt yapmaz.
- **Sabit kıymetler.** `assets.json` yoktur; VUK'un amortisman oranları ve
  faydalı ömürleri bu araştırmanın dışındadır.
- **Banka formatları.** Türk bankalarının hangi dosya biçimini
  gönderdiği bu araştırmada doğrulanmamıştır; `pack.json`'da `bank` bölümü
  hiç yoktur.
- **Ödeme vadesi ve gecikme faizi**, "Faturada" bölümünde anlatıldığı gibi.

## Bu pack'i incelemek

"Review: Turkey" başlıklı bir konu açın. Bir incelemenin ne olduğu ve ne
olmadığı [`docs/packs.md`](../../docs/packs.md)'de "Certification, and who
may say what" başlığı altındadır. Türkiye'de yeminli mali müşavirlik ya da
serbest muhasebeci mali müşavirlik yapan birinin önce okuması gereken
noktalar, yazarın en az emin olduğu sıraya göre:

1. **1 No'lu KDV Beyannamesinin kutuları**, GİB'in canlı e-Beyanname
   ekranının box numaraları değil, kanunun içeriğidir.
2. **`TR-P-IMP`'nin gümrükte doğrudan ödeme varsayımı** — Article 50'nin
   (UAE) ya da benzer bir "özel ithalat" hâlinin karşılığı burada
   modellenmemiştir.
3. **(I) ve (II) sayılı listelerin kapsamı**, bu pack'te madde madde
   verilmemiştir.
4. **Yurtiçi kısmi tevkifat listesinin tamamının eksikliği.**
5. **`invoice_if_issued` tax point'i**, madde 10'un üç bendinin (a, b, ı)
   tek bir olağan durum yaklaşımıdır.
6. **e-Fatura/e-Arşiv eşiklerinin güncelliği** — bu tebliğ sık sık
   değiştirilir, bu pack'in araştırması tek bir tarihte durur.
