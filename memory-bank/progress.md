# Progress: Sıfır Atık Mutfak

**Son Güncelleme:** Nisan 2026

---

## Tamamlanan Özellikler

### Core Infrastructure
- Flutter proje yapısı (Clean Architecture, feature-based)
- Riverpod state management + code generation
- GoRouter navigation
- Theme ve color system (brand turuncu paleti)
- Core providers (NetworkService, DeepSeekService)
- Manrope font ailesi entegrasyonu

### Tarif Yönetimi
- Recipe model (Freezed, Firestore helpers, description alanı)
- RecipeRepository (Firestore + local JSON fallback — Firestore boş veya hata verirse yerel JSON)
- recipeListProvider (keepAlive: true - sadece ilk açılışta fetch)
- Firestore Security Rules (firestore.rules dosyası): recipes herkes okur, admin yazar
- 7 detaylı tarif (recipes.json): açıklamalar, miktarlı malzemeler, detaylı adımlar
- SHA-1 debug parmak izi Firebase'e eklendi

### Tarifler Sayfası (HomePage)
- Arama çubuğu: inner shadow efekti, search_icon.png, Manrope font
- Filtre butonu: arama çubuğunun sağında, tune ikonu, seçili malzeme badge'i
- Malzeme filtre bottom sheet (ingredient_filter_sheet.dart): arama + wrap layout + uygula/temizle
- Seçili malzemeler: yatay chip bar (turuncu dolgulu) + "Temizle" chip'i (seçim yoksa gizli)
- Akıllı sıralama (en çok eşleşen tarif üstte) + eşleşme göstergesi kartlarda
- RecipeBlogCard: beyaz kart, yuvarlak resim, turuncu chip'ler, "N malzeme · N adım" özeti
- Tarif detay sheet: özet istatistik barı, kenarlıklı kart malzeme/yapılış bölümleri, showPlaceholderImage parametresi

### Oluştur Sayfası (RecipeGeneratorPage) - Yeniden Tasarlandı
- Başlık: siyah Manrope Bold 20 + info ikonu ile gri açıklama (fontSize: 12)
- Input: inner shadow pill-shape text field + turuncu daire "+" butonu
- Eklenen malzemeler: turuncu dolgulu chip'ler (x ile sil)
- Son eklenenler: SharedPreferences ile kalıcı (max 10), turuncu kenarlı beyaz chip'ler, dokunulunca ekle
- RecentIngredients provider (@Riverpod keepAlive, SharedPreferences)
- Mutfak dropdown: başlık dışarıda, pill-shape dropdown, inner shadow, arrow_icon.png, animasyonlu açılır liste
- Kaydettiğim Tarifler: max 5 yatay + "Tümünü gör" kartı/yazısı
- Tüm tarifler sheet (saved_recipes_sheet.dart): arama + dikey liste + silme/fotoğraf ekleme
- Tarif detay: showPlaceholderImage: false (fotoğraf yoksa placeholder gösterilmez)
- Yemek isimleri: siyah, regular weight
- Tarif oluşturulduktan sonra: malzemeler recent'a kaydedilir, aktif liste temizlenir

### Navigation Bar
- Pill-shaped frosted glass navbar (BackdropFilter blur)
- Custom PNG ikonlar (tarifler, oluştur, chat, puan)
- Aktif: turuncu pill + beyaz ikon + Manrope Bold 12
- Pasif: beyaz daire + turuncu outline ikon

### AI Tarif Üretimi
- DeepSeek API entegrasyonu
- RecipeGeneratorPage (malzeme girişi, mutfak seçimi)
- RecipeParser (Markdown → Recipe)
- ChefLoadingOverlay
- Saved recipes (local storage) + fotoğraf ekleme

### AI Sohbet (EcoChef)
- ChatPage (Liquid glass tam ekran tasarımı, Stack mimarisi, sınırsız navbar scrollu)
- Kapsül UI tasarımlı mesaj barı (içgömülü buton, ekstra yumuşak kenarlar, odak çizgisi iptali)
- Dynamic Scroll Padding uyarlaması ile sayfa altı floating bar çakışmaları sıfırlandı
- ChatBubble, EcoChefTypingIndicator, EcoChefWelcome arayüzü güncellendi
- DeepSeek mascot chat entegrasyonu ve testi

### Puan Sistemi
- PointsPage UI tasarımı
- Puan kartı, 3 kategori kartı
- "Gönderi ekle" butonu (placeholder)

### Backend
- Firebase projesi (zerowaste-46d54)
- Firestore Database (tarifler)
- Firebase Authentication (Email/Password - admin)
- RecipeRepository Firestore entegrasyonu + fallback
- Firestore Security Rules (firestore.rules)

### Admin Paneli (Web)
- Flutter Web, desktop-friendly sidebar
- Firebase Auth + Firestore admin kontrolü
- Tarif CRUD (ekleme, düzenleme, silme)
- Route guard (AdminGuard)

---

## Bilinen Sorunlar

### Çözüldü
- ~~Siyah ekran:~~ Firestore Security Rules + fallback
- ~~Boş tarif listesi:~~ Firestore boşsa yerel JSON
- ~~RangeError:~~ IngredientList.removeAt cascade bug
- ~~info_icon.png:~~ Dosya silinmişti, flutter clean ile çözüldü
- ~~DEVELOPER_ERROR:~~ Emülatörde normal, Firestore'u engellemez

### Küçük
- Chat history: sadece in-memory, uygulama kapanınca kaybolur
- Saved recipes: sadece local storage
- Pagination yok (tarif sayısı arttıkça gerekli olacak)

---

## Yapılacaklar

### Kısa Vadeli
- Chat arayüzü için Fade-in ve Slide-up animasyonlu mesaj girişleri
- Sohbet balonları için şık/minimal zaman damgaları (timestamps)
- Pagination (Firestore reads optimizasyonu)
- Cache mekanizması
- Cloud Storage entegrasyonu (fotoğraf upload)
- Kullanıcı authentication (mobil)

### Orta Vadeli
- Puan sistemi backend (fotoğraf upload + puanlama)
- Admin panelinde puanlama özelliği
- Kullanıcı profilleri
- Push notifications

### Uzun Vadeli
- Topluluk özellikleri (yorumlar, favoriler)
- Çoklu dil desteği
- Offline mode
- Analytics

---

## Versiyon Geçmişi

### v0.3.0 (Mart 2025 - Güncel)
- Firestore Security Rules + fallback sistemi
- Oluştur sayfası tamamen yeniden tasarlandı (input, dropdown, son eklenenler, kayıtlı tarifler)
- RecentIngredients provider (SharedPreferences, max 10)
- Kaydettiğim Tarifler: max 5 + "Tümünü gör" bottom sheet
- Tarif içerikleri genişletildi (7 tarif, detaylı malzeme/adım/açıklama)
- Tarif detay sheet zenginleştirildi (istatistik barı, kart bölümler, ayraçlar)
- RecipeBlogCard'a özet satırı eklendi
- Malzeme filtre sistemi: filtre butonu + bottom sheet (eski chip bar kaldırıldı)
- Inner shadow pattern (arama çubukları, dropdown)
- arrow_icon.png eklendi
- showPlaceholderImage parametresi (oluştur sayfası detaylarında placeholder gizleme)

### v0.2.0 (Mart 2025)
- Renk paleti değişimi (yeşil → turuncu brand)
- Navigation bar yeniden tasarımı (pill-shaped, frosted glass, custom ikonlar)
- Tarifler sayfası yeniden tasarımı (beyaz kartlar, arama, chip'ler)
- Malzeme bazlı tarif filtreleme sistemi
- Tarif detay sheet yeniden tasarımı
- recipeListProvider keepAlive optimizasyonu
- Tüm fontlar Manrope
- Custom PNG ikonlar ve placeholder görseli

### v0.1.0 (Şubat 2025)
- İlk MVP versiyonu
- AI tarif üretimi, AI sohbet
- Tarif listesi (Firestore)
- Puan sayfası UI
- Firebase backend + admin paneli
