# Progress: Atıksız Mutfak

**Son Güncelleme:** Temmuz 2026 (17 Temmuz)

---

## Tamamlanan Özellikler

### Core Infrastructure
- Flutter Clean Architecture, Riverpod, GoRouter
- Manrope font, turuncu marka paleti, TR/EN lokalizasyon
- Firebase Blaze planı

### Splash Screen
- 5 saniyelik staggered animasyon, AB/EU logoları

### Tarif Listesi (Home)
- Firestore-only (`RecipeRepository`, boşsa `[]`)
- **RecipesComingSoon** placeholder (animasyonlu)
- Malzeme filtreleme + arama
- `RecipeDetailSheet`: bullet ingredients, numaralı instructions

### AI Tarif Üretimi (DeepSeek)
- Malzeme + mutfak stili, EcoChef loading overlay
- **Locale bazlı dil** (TR/EN app toggle)
- `RecipeParser` TR + EN format desteği
- Kaydedilen tarifler (max 5)

### AI Sohbet (EcoChef)
- 20 mesaj/gün, 34 öneri havuzu
- **Kullanıcı mesaj dilinde yanıt** (EN/TR algılama + sert prompt)
- Typewriter, Markdown, 5 dk auto-clear

### Puan Sistemi (Gamification)
- PointsHeroCard: progress + level-up journey
- 5 seviye, leaderboard top 3, nickname, günlük görevler
- Opt-out, admin bonus/kesinti (TR/EN notlar)
- **Puan animasyonu düzeltildi**: tab geçişinde, sadece puan arttığında, önceki puandan başlar

### Gönderi Fotoğrafı (Firebase Storage)
- ✅ Anonymous Auth (startup + upload öncesi)
- ✅ `PostImageStorageService` — `posts/{postId}/photo.jpg`, max 2 MB, `putData(bytes)`
- ✅ `storage.rules` deployed
- ✅ `PostEntry.imageUrl` + `PostImageThumbnail` (CachedNetworkImage)
- ✅ Upload overlay + hata snackbar + timeout (90s upload, 20s auth)
- ⏳ Kullanıcı testi devam ediyor (upload takılma bildirimi → bytes fix uygulandı)

### Admin Paneli (Ayrı Web Projesi)
- ✅ Mobil admin kodu tamamen kaldırıldı
- ✅ Tarif formu veri yapısı kararı (dinamik malzeme/adım listesi)
- ⏳ Tarif CRUD + gönderi `imageUrl` gösterimi bekliyor

---

## Bilinen Sorunlar (Çözülmüş)

- [x] Puan animasyonu arka planda tüketilmesi / her açılışta 0'dan sayma
- [x] Chat İngilizce yazınca Türkçe cevap vermesi
- [x] Create sayfasında locale'e göre tarif dili
- [x] Tarif listesi mock JSON fallback
- [x] Gönderi fotoğrafları sadece local path'te
- [x] Ticker dispose, chat keyboard, günlük görev mock, hesap silindi yanlış pozitif

---

## 🔴 Bilinen Sorunlar (Devam Eden)

### 1. Gönderi Fotoğrafı Upload Testi (YÜKSEK)
- Blaze + Anonymous Auth + rules deploy tamam
- "Fotoğraf yükleniyor" ekranında takılma bildirildi → bytes + timeout fix uygulandı, yeniden test gerekli
- Admin panel upload'u etkilemez

### 2. Admin Panel — Gönderi Fotoğrafı Gösterimi (YÜKSEK)
- Ayrı web projesinde `posts.imageUrl` → `Image.network` entegrasyonu yapılmalı

### 3. Admin Panel Tarif CRUD (YÜKSEK)
- `AdminRecipeForm` + `DynamicStringListField`
- Firestore `recipes` boş → mobilde Coming Soon

### 4. Mobil Çıkış → Admin Senkronizasyonu (YÜKSEK)
- Opt-out/silme admin panelde yansımıyor

### 5. Progress Bar Hizalama (DÜŞÜK)
- HeroCard gradient arc / background ring örtüşmesi

---

## Yapılacaklar

### 🟡 Yüksek Öncelik
- [ ] Gönderi fotoğrafı upload end-to-end test (mobil → Storage → Firestore → admin)
- [ ] Admin panel: `imageUrl` ile gönderi fotoğrafı gösterimi
- [ ] Admin panel: tarif CRUD (`DynamicStringListField`)
- [ ] İlk tariflerin admin panelden eklenmesi
- [ ] Mobil opt-out/silme → admin panel senkronizasyonu

### 🟢 Düşük Öncelik
- [ ] Progress bar hizalama testi
- [ ] Günlük chat limit reset kontrolü
- [ ] RecipeSyncService main()'e ekleme
