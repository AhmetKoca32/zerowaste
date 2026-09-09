# Progress: Atıksız Mutfak

**Son Güncelleme:** Eylül 2026 (8 Eylül)

---

## Tamamlanan Özellikler

### Core Infrastructure
- Flutter Clean Architecture, Riverpod, GoRouter
- Manrope font, turuncu marka paleti, TR/EN lokalizasyon
- Firebase Blaze (`zerowaste-46d54`)
- **Plan B:** `user_stats` + incremental leaderboard; mobil bounded reads
- **Bundle / package:** `com.ahmetkoca.zerowaste` (iOS + Android); FlutterFire iOS/Android app’ler kayıtlı

### Splash Screen
- ~5s staggered animasyon; AB/EU + partner logoları
- Dil bazlı marka logo (`atıksız_mutfak_logo_1tr` / `_1en`) + EU lockup (TR asset / EN üretilmiş tek satır lockup)
- Locale: prefs yoksa cihaz dili

### Launcher / display name
- iOS `InfoPlist.strings` en/tr; Android `values` / `values-tr` → Zerowaste Kitchen / Atıksız Mutfak

### Tarif Listesi (Home)
- Firestore-only; boşsa Coming Soon
- **TR+EN curated** (`isBilingualComplete`); UI `localized*`
- Malzeme filtre + arama (iki dil); `RecipeDetailSheet`
- Admin TR+EN zorunlu CRUD (ayrı web)

### AI Tarif Üretimi (DeepSeek)
- Malzeme + mutfak stili; locale dili; kaydet max 5
- Kayıtlı tarif fotoğrafları: **local only** (`Documents/recipe_images` + SharedPreferences `local_image_path`); Firebase Storage yok

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

### Bildirimler
- Local daily 09:00 / 18:00 (`NotificationService`)
- Sabah: “Küçük bir seçim, büyük fark…” / “Small choice, big impact…”
- Akşam: “Çöpe değil, uygulamaya!…” / “Don't bin it — share it…”

### Admin (ayrı web)
- Plan B onay/red/kesinti; tarif TR+EN; wipe ban

---

## Bilinen Sorunlar (çözülmüş — seçilmiş)

- [x] Chat layout / 24h persist / typewriter / history
- [x] Plan B + wipe + claimedByUid
- [x] Level stepper / puan düşüş diyaloğu
- [x] Tarif TR+EN mobil + admin
- [x] Plan B E2E
- [x] Bundle ID `com.example.*` → `com.ahmetkoca.zerowaste` + FlutterFire

---

## Açık işler

### 🔴 App Store / Apple hesabı
- [ ] **Apple Developer Program Active değil** — Notice of Termination (29 Temmuz 2026); Support appeal bekleniyor
- [ ] App ID + ASC New App + Xcode ücretli Team (hesap açılınca)
- [ ] Privacy Policy URL + App Privacy formu
- [ ] Version `1.0.0`, IPA, TestFlight, Submit
- [ ] Screenshots / listing
- [ ] Blaze bütçe uyarısı
- [ ] Yeterli bilingual tarif içeriği
- Detay: [`app-store-checklist.md`](app-store-checklist.md)

### 🟡 Orta
- [ ] (İsteğe bağlı) Kayıtlı tarif foto → Firebase Storage sync
- [ ] Google Play (iOS bloke iken alternatif kanal)

### 🟢 Düşük
- [ ] Progress bar hizalama
- [ ] Admin post `imageUrl` UI
- [ ] Dashboard totalUsers aggregate (admin)
- [ ] RecipeSyncService → main (gerekirse)
