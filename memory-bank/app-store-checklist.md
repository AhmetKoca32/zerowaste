# App Store / Play Store yayın checklist — Atıksız Mutfak (Zerowaste Kitchen)

**Proje:** `zerowaste` · Firebase `zerowaste-46d54` · `pubspec` version `0.1.0`  
**Hedef:** iOS App Store (öncelik) + isteğe bağlı Google Play

---

## A. Ürün / içerik (store öncesi zorunlu)

- [ ] En az **3–5 bilingual tarif** Firestore’da (`title`+`titleEn`, malzemeler/adımlar TR+EN)
- [ ] Cold start sonrası Home’da Coming Soon yok; TR/EN toggle metni değiştiriyor
- [ ] Splash / marka: **Zerowaste Kitchen** (EN store) / **Atıksız Mutfak** (TR UI) tutarlı
- [ ] Nickname + leaderboard opt-in metinleri KVKK/GDPR uyumlu (zaten var; son bir okuma)
- [ ] Opt-out / wipe akışı kullanıcıya net (E2E geçtiyse OK)

---

## B. Teknik hazırlık (iOS)

- [ ] Apple Developer hesabı + App ID + provisioning
- [ ] Bundle ID sabit ve unique (Xcode `PRODUCT_BUNDLE_IDENTIFIER`)
  - **Şu an:** `com.example.zerowaste` → store için **değiştirilmeli** (örn. `com.zerowastekitchen.app`)
- [ ] Display name: **Zerowaste Kitchen** (`Info.plist` zaten bu)
- [ ] Version: `pubspec` `0.1.0` → release için örn. `1.0.0` + build number
- [ ] `GoogleService-Info.plist` production Firebase’e bağlı (`zerowaste-46d54`)
- [ ] Release build: `flutter build ipa` (veya Xcode Archive) hatasız
- [ ] Camera / Photo Library strings mevcut (`Info.plist` TR metinler OK; EN store için dil isteğe bağlı)
- [ ] App Tracking Transparency gerekmiyorsa IDFA kullanma; gerekirse ATT + purpose string
- [ ] Privacy Manifest (`PrivacyInfo.xcprivacy`) — Flutter/plugin gereklerine göre
- [ ] Bitcode / encryption: **ITSAppUsesNonExemptEncryption** = false (yalnızca exempt crypto) veya doğru beyan
- [ ] Minimum iOS sürümü kararlaştır (örn. 13+)

## C. Teknik hazırlık (Android — paralel / sonra)

- [ ] Application ID unique
- [ ] `google-services.json` production
- [ ] Camera / storage permission metinleri
- [ ] `flutter build appbundle` (Play)
- [ ] Play Console signing (Play App Signing)

---

## D. App Store Connect listing

- [ ] App adı, subtitle, category (ör. Food & Drink / Lifestyle)
- [ ] Açıklama TR ve/veya EN (store primary language seç)
- [ ] Keywords
- [ ] Support URL + Marketing URL (varsa)
- [ ] **Privacy Policy URL** (zorunlu — nickname, anon auth, foto, AI chat)
- [ ] Age rating anketi
- [ ] Screenshot’lar: 6.7" + 6.1" (ve istenirse iPad)
  - Öneri kareler: Splash/Home tarif · AI üretici · EcoChef · Puan/leaderboard · Gönderi
- [ ] App Preview video (opsiyonel)
- [ ] App icon 1024×1024 (şu an launcher icon var; store asset ayrı kontrol)

---

## E. Gizlilik & veri beyanı (App Privacy)

Beyan edilmesi gerekenler (bu app’e göre):

- [ ] **Contact / User ID:** nickname (opt-in leaderboard)
- [ ] **Photos:** kullanıcı gönderi fotoğrafları (Firebase Storage)
- [ ] **User Content:** gönderi metni / kategori, chat mesajları (lokal + DeepSeek API)
- [ ] **Identifiers:** Firebase Auth anonymous UID
- [ ] **Product interaction / diagnostics:** Firebase Analytics/Crashlytics varsa işaretle
- [ ] **Notifications (local only):** günlük 09:00 / 18:00 hatırlatma; FCM token yok; kullanıcı iOS/Android ayarlarından kapatabilir
- [ ] “Data used to track you” — tracking yoksa **No**
- [ ] DeepSeek / üçüncü taraf AI: privacy policy’de açıkça yaz

---

## F. Firebase / maliyet (yayın öncesi)

- [ ] Console → Usage and billing: Blaze bütçe uyarısı (örn. düşük eşik)
- [ ] Storage rules production’da sıkı
- [ ] Firestore rules live ile uyumlu (`user_stats` / leaderboard / recipes read)
- [ ] DeepSeek API key `.env` / CI secret; App Store binary’ye hardcode yok
- [ ] Anonymous Auth açık; abuse için rate limit (chat 20/gün zaten var)

---

## G. Son test (release candidate)

- [ ] Gerçek cihaz: tarif listesi, dil toggle, AI tarif, chat limiti
- [ ] Puan: claim → foto → onay animasyonu; kesinti diyaloğu; leaveContest wipe
- [ ] Offline / zayıf ağ: hata mesajları çökme yok
- [ ] İlk açılış → splash → ana sekmeler
- [ ] Günlük bildirim: izin → 09:00 / 18:00 (debug: `scheduleTestNotification`); tap → Puan sekmesi
- [ ] TestFlight internal (en az 1 build) smoke test

---

## H. Gönderim

- [ ] TestFlight → External (opsiyonel) veya doğrudan App Review
- [ ] Review notes: demo nick yoksa “anonymous + nickname claim” anlat; admin panel review’a gerekmez; 2 yerel günlük hatırlatma (opt-out = sistem ayarları)
- [ ] Export compliance / advertising ID soruları cevaplandı
- [ ] Submit for Review

---

## I. Gönderim sonrası

- [ ] Review reddi varsa: foto privacy string / AI disclosure / account deletion (wipe = leaveContest) netleştir
- [ ] “Hesap silme”: App Store 2024+ — in-app veya web ile hesap/nick silme yolu (`leaveContest` / wipe) listing + policy’de belirt
- [ ] Soft launch: Usage 48–72s izle

---

## Hızlı sıra (pratik)

1. Tarif içeriği doldur  
2. Privacy Policy sayfası yayınla  
3. Version bump + `flutter build ipa`  
4. App Store Connect listing + screenshots  
5. App Privacy formu  
6. TestFlight smoke  
7. Submit  
