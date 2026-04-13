# Active Context: Sıfır Atık Mutfak

**Son Güncelleme:** Mart 2025  
**Aktif Çalışma:** Oluştur sayfası yeniden tasarımı, tarif detay zenginleştirme, malzeme filtre sistemi

---

## Şu Anki Odak

### Son Yapılan Değişiklikler (Mart 2025 - Güncel Oturum)

#### 1. Firestore Security Rules & Fallback - ÇÖZÜLDÜ
- `firestore.rules` dosyası oluşturuldu (recipes: herkes okur, admin yazar; admins: kendi kaydını okur)
- RecipeRepository: Firestore boşsa veya hata verirse yerel JSON fallback
- SHA-1 debug parmak izi Firebase Console'a eklendi
- Google Play Services emülatör uyarıları (DEVELOPER_ERROR) Firestore'u engellemiyor

#### 2. Oluştur Sayfası (RecipeGeneratorPage) Yeniden Tasarımı
- **Başlık:** Siyah Manrope Bold 20 + altında info ikonu ile gri açıklama metni (fontSize: 12)
- **Input alanı:** Inner shadow efektli pill-shape beyaz text field + sağında turuncu daire "+" butonu. Eski "Ekle" butonu kaldırıldı
- **Eklenen malzemeler:** Turuncu dolgulu chip'ler (beyaz yazı, x ile sil)
- **Son eklenenler:** Daha önce tarif oluştururken kullanılmış malzemeler (SharedPreferences ile kalıcı, max 10). Turuncu kenarlıklı beyaz chip'ler. Dokunulunca aktif listeye eklenir. Zaten aktif listede olanlar gizlenir. Tarif oluşturulunca malzemeler kaydedilir ve aktif liste temizlenir.
- **Mutfak dropdown:** Başlık dışarıda ("Mutfak (isteğe bağlı)"), altında pill-shape beyaz dropdown. Inner shadow efekti. arrow_icon.png ile ok. Seçili değer gösterilir, tıklayınca animasyonlu açılır liste. Seçim yapılınca kapanır.
- **Kaydettiğim Tarifler:** Max 5 tarif yatay listede + "Tümünü gör (N)" kartı + başlıkta "Tümünü gör" yazısı. Tümünü gör'e tıklayınca aranabilir bottom sheet (saved_recipes_sheet.dart).
- **Tarif detay (oluştur sayfası):** showPlaceholderImage: false - fotoğraf eklenmemişse yemek.png gösterilmez, sadece "Fotoğraf ekle" butonu
- **Yemek isimleri:** Siyah (AppColors.ink), regular (w400)

#### 3. Tarif İçerikleri Genişletildi
- recipes.json: 3 tariften 7 tarife çıktı
- Her tarife description (açıklama/hikaye) eklendi
- Malzemeler detaylandırıldı (miktarlar, ölçüler, alternatifler)
- Yapılış adımları detaylandırıldı (süreler, sıcaklıklar, ipuçları)
- Yeni tarifler: Bayat Ekmek Köftesi, Meyve Kabuğu Sirkesi, Kabuk ve Sap Cipsi, Sıfır Atık Smoothie

#### 4. Tarif Detay Sheet Zenginleştirildi
- **Özet istatistik barı:** Resimden sonra krem arka planlı kutu, malzeme sayısı + adım sayısı ikon ile
- **Malzemeler bölümü:** Kenarlıklı beyaz kart, başlıkta "N adet", turuncu nokta ile madde işaretli liste (chip yerine)
- **Yapılış bölümü:** Kenarlıklı beyaz kart, başlıkta "N adım", numaralı adımlar arası ince ayraç çizgisi
- **showPlaceholderImage parametresi:** Oluştur sayfasından açılan detaylarda yemek.png gösterilmez

#### 5. Tarif Kartı (RecipeBlogCard) Güncellendi
- Başlık altına "N malzeme · N adım" özet satırı eklendi

#### 6. Malzeme Filtre Sistemi Yeniden Tasarlandı
- Eski yatay chip bar kaldırıldı
- Arama çubuğunun sağına filtre butonu eklendi (tune ikonu, turuncu badge ile seçili sayı)
- Filtre butonu tıklayınca bottom sheet açılır (ingredient_filter_sheet.dart):
  - Arama çubuğu (inner shadow, search_icon.png)
  - Seçili malzemeler üstte turuncu chip'ler (x ile kaldır)
  - Tüm malzemeler wrap layout (seçili: turuncu dolgu, değil: outline)
  - Alt barda "Temizle" + "Uygula (N)" butonları
- Ana sayfada seçili malzemeler yatay chip bar'da gösterilir + sonunda "Temizle" chip'i
- Seçili malzeme yoksa chip bar gizli

#### 7. RecentIngredients Provider
- SharedPreferences ile kalıcı depolama
- @Riverpod(keepAlive: true)
- Max 10 malzeme saklanır
- Tarif oluşturulduğunda malzemeler kaydedilir
- IngredientList.removeAt bug fix: `[...state]..removeAt(index)` (referans kopyası)

---

## Çözülen Sorunlar

- **Siyah ekran / PERMISSION_DENIED:** Firestore rules + fallback ile çözüldü
- **Boş tarif listesi:** Firestore boşsa yerel JSON fallback
- **RangeError (IngredientList.removeAt):** Cascade operator bug düzeltildi
- **info_icon.png bulunamadı:** Dosya silinmişti, kodda Material ikon kullanılıyor, flutter clean ile çözüldü

---

## Yapılacaklar

### Kısa Vadeli
- Pagination (tarif listesi büyüdükçe)
- Cache mekanizması
- Kullanıcı authentication (mobil uygulama)
- Cloud Storage entegrasyonu (fotoğraf upload)

### Orta Vadeli
- Puan sistemi backend
- Admin panelinde puanlama özelliği
- Push notifications
- Kullanıcı profilleri

---

## Önemli Tasarım Kararları

### Font: Manrope
- Tüm UI bileşenlerinde Manrope kullanılıyor
- Ağırlıklar: Light (300), Regular (400), Medium (500), Bold (700)

### Renkler: Brand Orange Palette
- Ana renk: brandOrange (#ED6826)
- Arka plan: Colors.white (kartlar, sheet'ler), AppColors.cream (sayfa arka planı)
- Metin: AppColors.ink (koyu), AppColors.inkLight (açık)
- ESKİ yeşil tonları KULLANILMAMALI

### Inner Shadow Pattern
- Arama çubukları ve dropdown'lar: LinearGradient ile içe doğru gölge efekti
- Colors.black.withOpacity(0.05) üst, 0.02 alt, stops: [0.0, 0.15, 0.85, 1.0]

### Custom İkonlar
- assets/images/icons/ klasöründe PNG ikonlar
- arrow_icon.png (dropdown ok), search_icon.png, alisveris_icon.png vb.
- Material ikonları da kullanılıyor (Icons.tune, Icons.info_outline vb.)

### Bottom Sheet Pattern
- DraggableScrollableSheet kullanımı (initialChildSize: 0.75-0.85)
- Üstte drag handle (40x4, stone renk)
- Beyaz arka plan, üst köşeler 24px radius
