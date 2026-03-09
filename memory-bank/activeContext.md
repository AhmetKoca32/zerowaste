# Active Context: Sıfır Atık Mutfak

**Son Güncelleme:** Mart 2025  
**Aktif Çalışma:** UI/UX polish ve tarif filtreleme sistemi tamamlandı

---

## Şu Anki Odak

### Son Yapılan Büyük Değişiklikler (Mart 2025)

#### 1. Renk Paleti Değişimi
- Eski yeşil tonları (sage, mint, fern, moss, forest) tamamen kaldırıldı
- Yeni brand renkleri uygulandı: brandOrange, brandCream, brandOrange70
- app_colors.dart'tan "Pastel Greens" bölümü silindi
- app_theme.dart: seedColor, primary, tertiary, button, input border güncellendi
- 15+ dosyada renk referansları güncellendi

#### 2. Navigation Bar Yeniden Tasarımı
- Pill-shaped yatay navbar
- BackdropFilter ile frosted glass/blur efekti
- Custom PNG ikonlar (tarifler_icon, chat_icon, puan_icon, olustur_icon)
- Aktif: turuncu pill + beyaz ikon + Manrope Bold 12 text
- İkonlar dikey olarak ortalanmış (_circleSize: 54, _iconVerticalPadding: 15)

#### 3. Navbar Arka Plan Sorunu Çözümü
- İç sayfalar (RecipeGeneratorPage, ChatPage, PointsPage) inTabs: true iken inner Scaffold bypass eder
- SafeArea kaldırıldı, alt padding 100-120px eklendi
- İçerik navbar arkasından scroll ediyor, blur efekti çalışıyor

#### 4. Tarifler Sayfası Yeniden Tasarımı
- Arama çubuğu: beyaz, inner shadow efektli, search_icon.png, Manrope font
- Tarif kartları: beyaz arka plan, 16px padding ile yuvarlak köşeli resim (220px), turuncu kenarlıklı malzeme chip'leri
- "Tarifi İncele" butonu: turuncu, ortalanmış yazı
- Custom malzeme ikonu: alisveris_icon.png
- Tüm fontlar Manrope

#### 5. Malzeme Bazlı Tarif Filtreleme
- Arama çubuğu altında yatay kaydırılabilir chip bar
- Tüm tariflerden benzersiz malzemeler otomatik çıkarılır
- Multi-select: birden fazla malzeme seçilebilir
- Akıllı sıralama: seçilen malzemelerle en çok eşleşen tarif üstte
- Eşleşme göstergesi: "X/Y malzeme elinizde" her kartta
- "Tümü" chip'i ile seçim temizleme

#### 6. Tarif Detay Sheet Yeniden Tasarımı
- Beyaz arka plan (paper yerine), yumuşak siyah gölge (turuncu yerine)
- Başlık: Manrope Bold 20, koyu renk (turuncu değil)
- Malzemeler: chip formatında (bullet point yerine), turuncu kenarlı
- Malzemeler başlığı: alisveris_icon.png
- Yapılış numaraları: brandOrange daireler (brandCream yerine)
- Placeholder: yemek.png (boş kutu yerine)
- initialChildSize: 0.85 (0.6 yerine)
- Tüm fontlar Manrope

#### 7. Provider Optimizasyonu
- recipeListProvider: @Riverpod(keepAlive: true) ile sadece ilk açılışta fetch
- build_runner ile generated dosya yeniden oluşturuldu

#### 8. Diğer
- App adı: 'Sıfır Atık Mutfak' (ZeroWaste Mutfak yerine)
- Chat sayfasına mock data eklendi
- yemek.png placeholder görseli eklendi
- EmptyPlaceholder widget'a Manrope font eklendi

---

## Çözülen Sorunlar (Mart 2025 - Son)

### Siyah Ekran / Firestore PERMISSION_DENIED - ÇÖZÜLDÜ
- Firestore Security Rules güncellendi (`firestore.rules` dosyası oluşturuldu)
  - `recipes`: herkes okuyabilir, sadece admin yazabilir
  - `admins`: giriş yapmış kullanıcı kendi kaydını okuyabilir
- RecipeRepository'ye fallback eklendi: Firestore boşsa veya hata verirse yerel JSON tarifleri (`assets/data/recipes.json`) gösterilir
- SHA-1 debug parmak izi Firebase Console'a eklendi
- Google Play Services emülatör uyarıları (DEVELOPER_ERROR) normal; Firestore'u engellemiyor

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
- Her yeni UI bileşeninde fontFamily: 'Manrope' eklenmeli

### Renkler: Brand Orange Palette
- Ana renk: brandOrange (#ED6826) - butonlar, aktif durumlar, vurgular
- Arka plan: Colors.white (kartlar, sheet'ler), AppColors.cream (sayfa arka planı)
- Chip kenarlıkları: brandOrange
- Metin: AppColors.ink (koyu), AppColors.inkLight (açık)
- ESKİ yeşil tonları KULLANILMAMALI (sage, mint, fern, moss, forest artık yok)

### Custom İkonlar
- Material ikonları yerine PNG ikonlar tercih ediliyor
- Yeni ikon eklendiğinde: assets/images/icons/ klasörüne koy, pubspec.yaml'da path ekli

### Navbar Pattern
- extendBody: true + alt padding ile içerik navbar arkasından scroll eder
- İç sayfalar inTabs: true iken inner Scaffold bypass eder
- Chat sayfası: input bar bottom padding 120 ile navbar üzerinde

---

## Son Değişiklikler Özeti (Kronolojik)

1. Navbar pill-shaped tasarımı + blur efekti
2. Navbar boyut/ikon ayarlamaları
3. İç sayfa navbar arka plan sorunu çözümü
4. Chat input bar konumlandırma
5. Chat mock data
6. Navbar text: Manrope Bold 12
7. Navbar custom PNG ikonlar
8. Tarifler sayfası yeniden tasarımı (kartlar, arama)
9. Renk paleti değişimi (yeşil → turuncu)
10. yemek.png placeholder eklendi
11. Tarif kartı: beyaz arka plan, padded yuvarlak resim, turuncu chip'ler
12. Arama çubuğu: beyaz, inner shadow, search_icon.png
13. Tüm fontlar Manrope
14. Malzeme bazlı tarif filtreleme chip bar
15. Tarif detay sheet yeniden tasarımı
16. recipeListProvider keepAlive: true
