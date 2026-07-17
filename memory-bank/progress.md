# Progress: Atıksız Mutfak

**Son Güncelleme:** Temmuz 2026 (17 Temmuz)

---

## Tamamlanan Özellikler

### Core Infrastructure
- Flutter proje yapısı (Clean Architecture, feature-based)
- Riverpod state management + code generation
- GoRouter navigation (slide transitions)
- Theme ve color system (brand turuncu paleti)
- Manrope font ailesi entegrasyonu
- SıfırAtık → Atıksız Mutfak markalama
- flutter_localizations + intl ile çift dilli destek (TR/EN)

### Splash Screen
- 5 saniyelik staggered animasyon (4 aşama)
- AB logoları + EU sponsor logosu

### AI Tarif Üretimi (DeepSeek)
- Malzeme girişi + son eklenenler (SharedPreferences)
- Mutfak stili seçimi
- "EcoChef pişiriyor" loading overlay (denizati.png)
- RecipeParser ile AI çıktısı → Recipe model
- Kaydettiğim Tarifler (max 5, SharedPreferences)

### AI Sohbet (EcoChef)
- DeepSeek API, 20 mesaj/gün limiti
- 34 öneri, 5 kategoride, günlük 5 random
- Typewriter animasyonu, Markdown render
- 5 dk background timer ile otomatik temizlik

### Tarif Listesi (Home)
- Firestore'dan tarif çekme (`recipeListProvider`, keepAlive)
- Firestore boşsa `RecipesComingSoon` placeholder
- Malzeme bazlı filtreleme + arama
- `RecipeDetailSheet`: ingredients bullet list, instructions numaralı adımlar

### Puan Sistemi (Gamification)
- PointsHeroCard: 2 modlu animasyon (Normal progress + Level-up Journey)
- 5 seviye: Çaylak → Meraklı → Usta → Efsane → Efsane+
- Inline leaderboard (top 3, KVKK opt-in)
- Nickname sistemi (ilk gönderide, KVKK/GDPR uyumlu)
- Günlük Görev Kartları (SharedPreferences tabanlı)
- Gönderi paylaşımı → Firebase Storage upload → admin onayı → puan
- Yarışmadan çıkma (Opt-Out)
- Admin bonus/kesinti: Çift dilli not (TR/EN)
- Hesap silme tespiti + dialog

### Gönderi Fotoğrafı (Firebase Storage)
- ✅ `AnonymousAuthService` — startup'ta anonim oturum
- ✅ `PostImageStorageService` — `posts/{postId}/photo.jpg` upload (max 2 MB)
- ✅ `storage.rules` — auth + boyut + content type kontrolü
- ✅ `PostEntry.imageUrl` — Firestore'da Storage URL saklama
- ✅ `PostImageThumbnail` — CachedNetworkImage ile remote/local preview
- ✅ `points_page.dart` — upload → Firestore akışı

### Admin Paneli (Ayrı Web Projesi)
- ✅ Mobil uygulamadan admin kodu tamamen temizlendi
- ✅ Tarif formu veri yapısı ve UX kararı netleştirildi (dinamik malzeme/adım listesi)
- ⏳ Ayrı Flutter Web projesinde geliştirme devam ediyor

---

## Bilinen Sorunlar (Çözülmüş)

- [x] Ticker dispose hatası (PointsHeroCard)
- [x] Chat input keyboard scroll sorunu
- [x] SıfırAtık → Atıksız markalama
- [x] Firestore security rules (leaderboardOptIn, leaderboard write)
- [x] Günlük görevlerdeki mock yapı
- [x] Yeni kullanıcıda "hesap silindi" yanlış pozitif
- [x] Animasyon tetiklenmemesi sorunu (SharedPrefs karşılaştırması)
- [x] Gönderi fotoğrafları sadece local path'te (Firebase Storage ile çözüldü)

---

## 🔴 Bilinen Sorunlar (Devam Eden)

### 1. Puan Sayfası Animasyon Sorunu (KRİTİK)
- Counter her açılışta 0'dan sayıyor; önceki puandan başlamalı
- İlgili: `points_hero_card.dart`, `points_page.dart`

### 2. Progress Bar Hizalama (YÜKSEK)
- Arka plan dairesi ile gradient arc tam örtüşmüyor olabilir

### 3. Admin Panel Tarif CRUD (YÜKSEK)
- Ayrı web projesinde `AdminRecipeForm` + `DynamicStringListField` implementasyonu bekliyor
- Firestore `recipes` koleksiyonu şu an boş olabilir → mobilde Coming Soon görünür

### 4. Mobil Çıkış → Admin Panel Senkronizasyonu (YÜKSEK)
- Opt-out/silme admin panelde yansımıyor

### 5. Firebase Spark Plan Kotası (YÜKSEK — İzlenmeli)
- Storage: 20KB/gün upload limiti yoğun kullanımda yetersiz kalabilir
- Blaze geçişi değerlendirilecek

---

## Yapılacaklar

### 🔴 Kritik / Acil
- [ ] Puan animasyon sorununu çöz (counter önceki puandan başlamalı)
- [ ] Progress bar hizalama testi

### 🟡 Yüksek Öncelik
- [ ] **Admin panel tarif formu**: DynamicStringListField + Firestore CRUD
- [ ] **Firestore recipes koleksiyonuna ilk tarifleri ekle** (admin panel üzerinden)
- [ ] Mobil çıkış/silme → admin panel senkronizasyonu
- [ ] Firebase Spark plan kota stratejisi

### 🟢 Düşük Öncelik
- [ ] Günlük chat limit reset kontrolü
- [ ] RecipeSyncService main()'e ekleme
- [ ] Tarif kapak fotoğrafı upload (admin panel, image_url)
