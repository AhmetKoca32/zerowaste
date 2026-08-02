# Progress: Atıksız Mutfak

**Son Güncelleme:** Ağustos 2026 (2 Ağustos)

---

## Tamamlanan Özellikler

### Core Infrastructure
- Flutter Clean Architecture, Riverpod, GoRouter
- Manrope font, turuncu marka paleti, TR/EN lokalizasyon
- Firebase Blaze planı

### Splash Screen
- ~5s staggered animasyon; AB/EU + partner logoları (HRYO, Our Common Future, Academy Culture, Ortak Geleceğimiz)

### Tarif Listesi (Home)
- Firestore-only (`RecipeRepository`, boşsa `[]`)
- **RecipesComingSoon** placeholder
- Malzeme filtreleme + arama
- `RecipeDetailSheet`

### AI Tarif Üretimi (DeepSeek)
- Malzeme + mutfak stili, EcoChef loading overlay
- Locale bazlı dil (TR/EN)
- Kaydedilen tarifler (max 5)

### AI Sohbet (EcoChef) — güncel
- 20 user mesaj/gün (`DailyMessageCount.maxMessages`)
- Kullanıcı mesaj dilinde yanıt
- Typewriter (yalnız yeni cevap, bir kez)
- Markdown bubbles
- **Lokal session:** SharedPreferences, 24h TTL, max 50 balon disk
- **API memory:** son 20 balon priorTurns; assistant history truncate ~1200
- Floating input; liste navbar/input altında görünür
- Floating EcoChef app bar + doğru üst inset
- Soft-delete/opt-out chat session temizler

### Puan Sistemi (Gamification)
- PointsHeroCard, seviyeler, leaderboard, nickname, günlük görevler
- Opt-out, soft-delete dialog, reject overlay, approve overlay
- Puan animasyonu: tab görünür + artışta

### Gönderi Fotoğrafı (Firebase Storage)
- Anonymous Auth + `putData(bytes)` + rules
- ⏳ End-to-end kullanıcı doğrulaması

### Admin Paneli (Ayrı Web)
- Mobil admin kaldırıldı
- ⏳ Tarif CRUD + `imageUrl` gösterimi

---

## Bilinen Sorunlar (Çözülmüş — son oturum)

- [x] Chat mesajı floating app bar altında kesilmesi
- [x] Input–navbar arası opak katman
- [x] Chat geçmişinin sadece memory’de kaybolması (24h local persist)
- [x] Typewriter scroll’da tekrar oynama
- [x] Model’in önceki cevapları bilmemesi (20 balon history)
- [x] 5 dk arka plan chat silme (kaldırıldı → 24h TTL)

---

## 🔴 Bilinen Sorunlar (Devam Eden)

### 1. Gönderi Fotoğrafı Upload Testi (YÜKSEK)
### 2. Admin Panel — Gönderi Fotoğrafı (YÜKSEK)
### 3. Admin Panel Tarif CRUD (YÜKSEK)
### 4. Mobil Çıkış → Admin Senkronizasyonu (YÜKSEK)
### 5. Progress Bar Hizalama (DÜŞÜK)

---

## Yapılacaklar

### 🟡 Yüksek Öncelik
- [ ] Gönderi fotoğrafı E2E test
- [ ] Admin: `imageUrl` gösterimi
- [ ] Admin: tarif CRUD
- [ ] İlk tariflerin eklenmesi
- [ ] Opt-out/silme → admin sync

### 🟢 Düşük Öncelik
- [ ] Progress bar hizalama
- [ ] RecipeSyncService → main
