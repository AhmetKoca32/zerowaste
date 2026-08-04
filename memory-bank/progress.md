# Progress: Atıksız Mutfak

**Son Güncelleme:** Ağustos 2026 (4 Ağustos)

---

## Tamamlanan Özellikler

### Core Infrastructure
- Flutter Clean Architecture, Riverpod, GoRouter
- Manrope font, turuncu marka paleti, TR/EN lokalizasyon
- Firebase Blaze (`zerowaste-46d54`)
- **Plan B:** `user_stats` + incremental leaderboard; mobil bounded reads

### Splash Screen
- ~5s staggered animasyon; AB/EU + partner logoları

### Tarif Listesi (Home)
- Firestore-only; boşsa Coming Soon
- **TR+EN curated** (`isBilingualComplete`); UI `localized*`
- Malzeme filtre + arama (iki dil); `RecipeDetailSheet`
- Admin TR+EN zorunlu CRUD (ayrı web)

### AI Tarif Üretimi (DeepSeek)
- Malzeme + mutfak stili; locale dili; kaydet max 5

### AI Sohbet (EcoChef)
- 20 mesaj/gün; kullanıcı dilinde yanıt; typewriter; markdown
- Lokal session 24h TTL; API history 20 balon
- Floating input + EcoChef app bar

### Puan Sistemi (Gamification)
- 7 seviye; `points_levels.dart`; hero ℹ️ sheet; leaderboard + rol
- Level-up/down stepper; puan silindi / red / approve overlay
- Plan B: `user_stats.totalPoints`; posts limit 12
- leaveContest wipe; nickname opt-in zorunlu; nick hero’da post sonrası

### Gönderi Fotoğrafı
- Anonymous Auth + Storage `imageUrl`; E2E checklist kapsamında doğrulandı

### Admin (ayrı web)
- Plan B onay/red/kesinti; tarif TR+EN; wipe ban

---

## Bilinen Sorunlar (çözülmüş — seçilmiş)

- [x] Chat layout / 24h persist / typewriter / history
- [x] Plan B + wipe + claimedByUid
- [x] Level stepper / puan düşüş diyaloğu
- [x] Tarif TR+EN mobil + admin
- [x] Plan B E2E

---

## Açık işler

### 🔴 App Store
- [ ] Bundle ID (`com.example.zerowaste` → production)
- [ ] Privacy Policy URL + App Privacy formu
- [ ] Version `1.0.0`, IPA, TestFlight, Submit
- [ ] Screenshots / listing
- [ ] Blaze bütçe uyarısı
- [ ] Yeterli bilingual tarif içeriği
- Detay: [`app-store-checklist.md`](app-store-checklist.md)

### 🟢 Düşük
- [ ] Progress bar hizalama
- [ ] Admin post `imageUrl` UI
- [ ] Dashboard totalUsers aggregate (admin)
- [ ] RecipeSyncService → main (gerekirse)
- [ ] Google Play (iOS sonrası)
