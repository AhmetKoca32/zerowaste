# Progress: Sıfır Atık Mutfak

**Son Güncelleme:** Mart 2025

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
- Recipe model (Freezed, Firestore helpers)
- RecipeRepository (Firestore + local JSON fallback)
- recipeListProvider (keepAlive: true - sadece ilk açılışta fetch)
- HomePage: arama + malzeme filtreleme + akıllı sıralama
- RecipeBlogCard: beyaz kart, yuvarlak resim, turuncu chip'ler, eşleşme göstergesi
- RecipeDetailSheet: beyaz bottom sheet, chip malzemeler, numaralı adımlar, Manrope
- Varsayılan placeholder: yemek.png
- Custom ikonlar: alisveris_icon.png, search_icon.png

### Malzeme Bazlı Filtreleme Sistemi
- Yatay kaydırılabilir malzeme chip bar
- Multi-select (seçili: turuncu dolgu, seçili değil: turuncu outline)
- "Tümü" chip'i ile seçim temizleme
- Akıllı sıralama (en çok eşleşen tarif üstte)
- Eşleşme göstergesi kartlarda ("X/Y malzeme elinizde")
- Arama ve filtreleme birlikte çalışıyor

### Navigation Bar
- Pill-shaped frosted glass navbar (BackdropFilter blur)
- Custom PNG ikonlar (tarifler, oluştur, chat, puan)
- Aktif: turuncu pill + beyaz ikon + Manrope Bold 12
- Pasif: beyaz daire + turuncu outline ikon
- İkonlar dikey ortalanmış

### Sayfa Uyumluluğu (Navbar ile)
- Tüm sayfalar extendBody: true ile navbar arkasından scroll ediyor
- RecipeGeneratorPage: inTabs iken inner Scaffold bypass, SafeArea kaldırılmış
- ChatPage: input bar navbar üzerinde (bottom padding 120), mock data
- PointsPage: SafeArea kaldırılmış, scroll padding ayarlı

### Renk Paleti (Güncel)
- Brand: brandOrange (#ED6826), brandCream (#FFFFCC), + opacity varyantları
- Extended: 21 renk paleti
- Earth tones: sand, stone, terracotta, clay, bark
- Neutrals: cream, paper, ink, inkLight
- ESKİ yeşiller (sage, mint, fern, moss, forest) kaldırıldı
- 15+ dosyada renk referansları güncellendi

### AI Tarif Üretimi
- DeepSeek API entegrasyonu
- RecipeGeneratorPage (malzeme girişi, mutfak seçimi)
- RecipeParser (Markdown → Recipe)
- ChefLoadingOverlay
- Saved recipes (local storage) + fotoğraf ekleme

### AI Sohbet (Leafy)
- ChatPage (sohbet arayüzü)
- ChatBubble, LeafyTypingIndicator
- DeepSeek mascot chat
- Mock data ile test edilmiş

### Puan Sistemi
- PointsPage UI tasarımı
- Puan kartı, 3 kategori kartı
- "Gönderi ekle" butonu (placeholder)

### Backend
- Firebase projesi (zerowaste-46d54)
- Firestore Database (tarifler)
- Firebase Authentication (Email/Password - admin)
- RecipeRepository Firestore entegrasyonu + fallback

### Admin Paneli (Web)
- Flutter Web, desktop-friendly sidebar
- Firebase Auth + Firestore admin kontrolü
- Tarif CRUD (ekleme, düzenleme, silme)
- Route guard (AdminGuard)

### UI/UX Genel
- App adı: "Sıfır Atık Mutfak"
- Tüm fontlar Manrope
- Custom PNG ikonlar
- Loading states, error handling, empty states
- Slide transitions

---

## Bilinen Sorunlar

### Çözüldü
- **~~Siyah ekran sorunu:~~** Firestore Security Rules güncellendi, RecipeRepository'ye Firestore boşsa yerel JSON fallback eklendi. SHA-1 Firebase'e eklendi.

### Küçük
- Chat history: sadece in-memory, uygulama kapanınca kaybolur
- Saved recipes: sadece local storage
- Pagination yok (tarif sayısı arttıkça gerekli olacak)

---

## Yapılacaklar

### Kısa Vadeli
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
