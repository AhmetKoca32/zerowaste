# Active Context: Atıksız Mutfak

**Son Güncelleme:** Ağustos 2026 (2 Ağustos)  
**Aktif Çalışma:** EcoChef chat UX + lokal session + konuşma hafızası tamam; kullanıcı “şimdilik her şey tamam” dedi. Sıradaki odak admin paneli / upload testleri.

---

## Son Yapılan Değişiklikler (Ağustos 2026)

### 1. EcoChef Chat — Layout
- **Üst padding:** `reverse: true` ListView’da floating EcoChef pill için `MediaQuery.padding.top + 64` (mesaj app bar altına girmesin)
- **Alt katman kaldırıldı:** Input `Column`+`SafeArea` yerine Stack’te floating; liste full-bleed → input ile navbar arası şeffaf, sohbet görünür (`extendBody: true` ile uyumlu)

### 2. EcoChef Chat — Lokal Session
- **`ChatSessionStorage`** (`SharedPreferences`, key `ecochef_chat_session`): JSON `{ updatedAt, messages }`
- **TTL 24 saat**, soft cap **50** balon (disk)
- **`ChatMessages` keepAlive** + hydrate / save / clear
- Eski **5 dk arka plan auto-clear kaldırıldı**; resume’da `purgeIfExpired`
- Soft-delete / opt-out → `chatMessagesProvider.clear()`

### 3. EcoChef Chat — Typewriter
- Typewriter yalnız **yeni gelen** EcoChef cevabında bir kez (`_typewriterForLength`)
- Scroll ile ListView rebuild → tekrar oynatmaz; `AutomaticKeepAlive` animasyon sırasında

### 4. EcoChef Chat — API Konuşma Hafızası
- **`chatWithMascot(..., priorTurns:)`** → son **20 balon** (user+assistant) DeepSeek’e gider
- Dil kuralı yalnız **son** user mesajında
- History’deki uzun assistant metinleri ~**1200** karakterde truncate
- Günlük gönderim limiti hâlâ **20 user mesaj/gün** (`DailyMessageCount.maxMessages`)

### 5. Splash / Branding (önceki oturum notu)
- Partner logoları + Ortak Geleceğimiz; splash ~5s; launcher `App_Logo.png`

---

## Bilinen Sorunlar (Öncelik Sırasına Göre)

### 🟡 YÜKSEK

- [ ] **Gönderi fotoğrafı upload testi**: bytes + timeout fix sonrası yeniden doğrulama
- [ ] **Admin panel gönderi fotoğrafı**: `imageUrl` gösterimi (ayrı repo)
- [ ] **Admin panel tarif CRUD**: `DynamicStringListField` + form
- [ ] **Mobil çıkış/silme → admin senkronizasyonu**

### 🟢 DÜŞÜK

- [ ] Progress bar hizalama
- [ ] RecipeSyncService main()'de çağrılmadı
- [ ] Firestore `recipes` ilk içerik (admin)

---

## Firebase Yapılandırması

- [x] Firebase **Blaze**, Anonymous Auth, Storage rules
- [x] `posts`, `leaderboard/current`, `admins`, `user_profiles` (soft-delete okuma)
- [ ] Admin panelden `recipes` doldurma

---

## Karar Günlüğü

| Tarih | Karar | Gerekçe |
|-------|-------|---------|
| 2 Ağustos | Chat history: SharedPreferences + 24h TTL (Firestore yok) | Günlük 20 mesaj; cihaz-lokal; KVKK/maliyet |
| 2 Ağustos | API context: son 20 balon + assistant truncate 1200 | “Sonuncusunu yapalım” için memory; token kontrollü |
| 2 Ağustos | Chat input floating / liste full-bleed | Input–navbar arası opak Scaffold boşluğu kalksın |
| 2 Ağustos | Typewriter yalnız fresh reply | Scroll recycle typewriter’ı yeniden başlatmasın |
| 17 Temmuz | Firebase Blaze + Anonymous Auth + putData | Storage upload |
| 17 Temmuz | Chat dil = user mesaj; Create = app locale | Serbest metin vs TR/EN toggle |
| 17 Temmuz | Tarif listesi Firestore-only + Coming Soon | Admin tek kaynak |
