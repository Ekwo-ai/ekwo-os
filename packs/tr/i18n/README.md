# Bu pack'in dili nereden geliyor

Pack'in kendisi Türkçe yazılmıştır, yani `defaults.language`. Bu bir
çeviri değildir: dayandığı her metin — 3065 sayılı Katma Değer Vergisi
Kanunu, Katma Değer Vergisi Genel Uygulama Tebliği, 1 Sıra No'lu Muhasebe
Sistemi Uygulama Genel Tebliği (Tekdüzen Hesap Planı) — zaten resmî
Türkçedir. Diğer paketlerin (`sa`, `ae`) karşılaştığı durum — referans
plan ya da kanunun yerel dilde resmî bir sürümünün olmaması, ve bu yüzden
İngilizce etiketlere başvurma — burada söz konusu değildir: Tekdüzen Hesap
Planı'nın kendisi bir Türkçe devlet tebliğidir, ve bu pack'in her hesap
adı, vergi adı ve kutu adı doğrudan o tebliğden ya da kanundan gelir.

`pack.json` bu yüzden `"languages": []` bildirir.

## Bu sürümde neden başka bir dil dosyası yok

Bir `i18n/en.json`, ne bir kanunun ne de Tekdüzen Hesap Planı'nın resmî bir
İngilizce sürümü olduğu için, bu pack'in kendi çevirisi olurdu — okuyucuya
resmî bir kaynağın kendi sözüymüş gibi sunulan, kaynaksız bir iddia.
`docs/packs.md`'nin aynı gerekçeyle `sa` ve `ae` paketlerinde bir `ar.json`
taşımaması gibi, bu pack de İngilizce dâhil hiçbir çeviriyi icat etmez.

## Bir dil eklemek

Format tek bir dosya ister, `i18n/<lang>.json`, ve bir dilin tüm sözü orada
yaşar. `pack.json`'ın `languages` listesine girmeyen bir dosya eksik
olabilir; girmiş bir dosyanın her anahtarı karşılaması gerekir, ve `ekwo
pack check` neyin eksik olduğunu adlandırır. Bir `en.json` ekleyecek kişi,
Tekdüzen Hesap Planı'nın ve 3065 sayılı Kanun'un resmî bir çevirisini
bulmadıkça, kendi `source` alanında hangi metne dayandığını söylemelidir —
tıpkı bu pack'in her `legal_reference`'ının Türkçe metne dayandığı gibi.
