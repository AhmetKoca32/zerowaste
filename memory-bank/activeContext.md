# Active Context: Atıksız Mutfak

**Son Güncelleme:** Temmuz 2026 (17 Temmuz)  
**Aktif Çalışma:** Admin paneli (ayrı web projesi) tarif formu + gönderi fotoğrafı gösterimi; mobil upload stabilizasyonu test ediliyor.

---

## Son Yapılan Değişiklikler

### 1. Puan Animasyonu Düzeltildi
- **`_loadPosts(allowAnimation:)`**: Animasyon yalnızca Puan sekmesine geçildiğinde ve `total > previousPoints` iken tetiklenir
- **Erken prefs kaydı kaldırıldı**: Puan arttığında SharedPreferences, animasyon bitene kadar güncellenmez (`onAnimationComplete` / `onJourneyComplete`)
- **Arka plan yüklemesi**: Uygulama başka sekmedeyken veri çekilir ama animasyon oynatılmaz
- **`_heroAnimationNonce`**: Her animasyonda widget yeniden oluşturulur
- **`PointsHeroCard._startNormalAnimation`**: Artık `previousPoints`'tan başlar (0 veya level.min değil)

### 2. Tarif Listesi — Firestore-Only + Coming Soon
- **`RecipeRepository`**: Firestore boşsa/hata verirse `[]` döner (local JSON fallback kaldırıldı)
- **`RecipesComingSoon`**: Boş listede animasyonlu placeholder (denizati float + pulsing dots)
- **`home_providers`**: AI üretilen tarifler ana sayfadan ayrıldı (sadece Firestore admin tarifleri)

### 3. AI Dil Desteği
- **Chat (EcoChef)**: Kullanıcının yazdığı dilde yanıt (EN in → EN out, TR in → TR out)
  - İngilizce system prompt + `[LANGUAGE RULE]` etiketi
  - Basit dil algılama (`_detectMessageLanguage`)
  - Welcome öneri chip'leri `localized(localeCode)` ile gönderilir
- **Tarif Üretici (Oluştur)**: **Uygulama locale'ine** göre (TR/EN toggle)
  - Ayrı TR/EN system prompt ve format (`Başlık` vs `Title`)
  - `RecipeParser` İngilizce header desteği
  - Malzemeler Türkçe olsa bile EN modda tarif adı İngilizce olmalı

### 4. Gönderi Fotoğrafı — Firebase Storage + Anonymous Auth
- **Firebase Blaze planına geçildi** (Storage kullanımı için)
- **`AnonymousAuthService`**: Startup + upload öncesi anonim oturum (20 sn timeout)
- **`PostImageStorageService`**: `putData(bytes)` ile upload (iOS temp path sorunu giderildi), 90 sn timeout
- **`storage.rules`**: Deploy edildi (`firebase deploy --only storage`)
- **`PostEntry.imageUrl`**: Firestore'da Storage download URL
- **`PostImageThumbnail`**: CachedNetworkImage
- Upload overlay: "Fotoğraf yükleniyor…" + hata snackbar

### 5. Admin Paneli (Ayrı Web Projesi — Devam Ediyor)
- Tarif formu tasarım kararı netleştirildi (`DynamicStringListField`, `string[]` malzeme/adım)
- **Gönderi fotoğrafı**: Admin panelde henüz `imageUrl` gösterimi yapılmadı (ayrı repo)
- Mobil upload admin panelden bağımsız çalışır

### 6. iOS SceneDelegate
- **`ios/Runner/SceneDelegate.swift`**: iOS scene lifecycle desteği

---

## Bilinen Sorunlar (Öncelik Sırasına Göre)

### 🟡 YÜKSEK

- [ ] **Gönderi fotoğrafı upload testi**: Blaze + Anonymous Auth + storage rules deploy edildi; kullanıcıda "yükleniyor" ekranında takılma bildirildi → bytes upload + timeout eklendi, tekrar test gerekli
- [ ] **Admin panel gönderi fotoğrafı**: Ayrı web projesinde `imageUrl` ile `Image.network` gösterimi yapılmalı
- [ ] **Admin panel tarif CRUD**: `DynamicStringListField` + `AdminRecipeForm` implementasyonu
- [ ] **Mobil çıkış/silme → admin panel senkronizasyonu**: Opt-out/silme admin panelde yansımıyor

### 🟢 DÜŞÜK

- [ ] Progress bar hizalama (`_GradientArcPainter` / `_BackgroundRingPainter`)
- [ ] Günlük chat limit reset mekanizması kontrolü
- [ ] RecipeSyncService main()'de çağrılmadı
- [ ] Firestore `recipes` koleksiyonuna admin panelden ilk tariflerin eklenmesi

---

## Firebase Yapılandırması

- [x] Firebase **Blaze** planı (kart bağlı, düşük trafikte ~$0)
- [x] `posts`, `leaderboard/current`, `admins/{uid}` koleksiyonları
- [x] Firebase Authentication: Email/Password + **Anonymous** (enabled)
- [x] Firestore rules + Storage rules (`storage.rules` deployed)
- [x] Firestore index'leri
- [ ] Admin panelden `recipes` koleksiyonuna tarif ekleme

---

## Karar Günlüğü

| Tarih | Karar | Gerekçe |
|-------|-------|---------|
| 17 Temmuz | Firebase Blaze planına geçiş | Spark Storage 20KB/gün upload limiti pratikte kullanılamazdı |
| 17 Temmuz | Anonymous Auth (startup + upload) | Storage rules `request.auth != null`; nickname-only kullanıcıdan login istemiyoruz |
| 17 Temmuz | `putData(bytes)` ile upload | iOS geçici dosya yolu upload sırasında silinebiliyordu |
| 17 Temmuz | Chat: kullanıcı mesaj dili; Create: app locale | Chat serbest metin; Create AppBar TR/EN toggle ile kontrol edilir |
| 17 Temmuz | Puan animasyonu sadece tab visible + puan arttıysa | Arka planda animasyon tüketimi ve gereksiz 0→X sayımı önlendi |
| 17 Temmuz | Tarif listesi JSON fallback kaldırıldı | Admin panel tek kaynak; boşken Coming Soon |
| 17 Temmuz | Admin tarif formu dinamik liste | Mobil `ingredients[]` / `instructions[]` render uyumu |
| 18 Mayıs | Tab-switch listener (stream değil) | Firestore okuma kotası tasarrufu |
