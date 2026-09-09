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
  - **Durum (Ağustos–Eylül 2026):** Üyelik satın alınmış (16/05/2026) ancak **29/07/2026 Notice of Termination** (fraud / §3.2(f)); Developer app “This account is not active”. Support appeal gönderildi — cevap bekleniyor. Yeni Apple ID ile ban aşma önerilmez.
- [x] Bundle ID sabit ve unique (Xcode `PRODUCT_BUNDLE_IDENTIFIER`)
  - **Final:** `com.ahmetkoca.zerowaste` (Runner Debug/Release/Profile)
  - RunnerTests: `com.ahmetkoca.zerowaste.RunnerTests`
- [x] **Firebase:** `com.ahmetkoca.zerowaste` iOS+Android app kaydı + `flutterfire configure` tamam
- [x] Display name lokalize: launcher **Atıksız Mutfak** (tr) / **Zerowaste Kitchen** (en) — `InfoPlist.strings` + Android strings
- [ ] Version: `pubspec` `0.1.0` → release için örn. `1.0.0` + build number
- [x] `GoogleService-Info.plist` / `firebase_options.dart` yeni Bundle ID ile (`zerowaste-46d54`)
- [ ] Release build: `flutter build ipa` (veya Xcode Archive) hatasız — **Apple hesabı Active olunca**
- [ ] Camera / Photo Library strings mevcut (`Info.plist` TR metinler OK; EN store için dil isteğe bağlı)
- [ ] App Tracking Transparency gerekmiyorsa IDFA kullanma; gerekirse ATT + purpose string
- [ ] Privacy Manifest (`PrivacyInfo.xcprivacy`) — Flutter/plugin gereklerine göre
- [ ] Bitcode / encryption: **ITSAppUsesNonExemptEncryption** = false (yalnızca exempt crypto) veya doğru beyan
- [ ] Minimum iOS sürümü kararlaştır (örn. 13+)

## C. Teknik hazırlık (Android — paralel / sonra)

- [x] Application ID unique → `com.ahmetkoca.zerowaste` (`applicationId` + `namespace`)
- [x] `google-services.json` production (`com.ahmetkoca.zerowaste` client; flutterfire)
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

## Bundle ID — netleştirme

**Karar:** `com.ahmetkoca.zerowaste` (Xcode + Android + Firebase yazıldı)

### 1) Projede (yapıldı)
- iOS Runner: `PRODUCT_BUNDLE_IDENTIFIER = com.ahmetkoca.zerowaste`
- Android: `applicationId` / `namespace` / `MainActivity` package aynı
- macOS AppInfo + test target’lar hizalandı
- FlutterFire: iOS `…:ios:8965fdaa91668ef99b83ab` · Android `…:android:5c74e2bd9a4d79ab9b83ab`

### 2) Firebase (yapıldı)
- `flutterfire configure --project=zerowaste-46d54` (iOS+Android)
- Eski `com.example.zerowaste` Firebase app’leri Console’da kalabilir (zararsız); istenirse sonra silinir

### 3) Apple Developer / App Store Connect — **BLOKE**
**Önemli:** Personal Team (`JSB75H8F6R`) ile **App Store / TestFlight yüklenemez**.

**Hesap durumu:** `akoca@zerotech.company` — Program aboneliği 16/05/2026 alınmış; **29/07/2026 Notice of Termination** (fraudulent conduct / ADP §3.2(f)); Developer app “This account is not active”; Enroll disabled; `/account` → contact form. Support appeal gönderildi. Yeni Apple ID ile yeniden enroll **önerilmez**.

Hesap Active olunca:
1. developer.apple.com → Identifiers → Explicit `com.ahmetkoca.zerowaste`
2. appstoreconnect.apple.com → New App → aynı Bundle ID
3. Xcode Signing → ücretli Team (Personal Team değil)

### 4) Doğrulama
```bash
rg PRODUCT_BUNDLE_IDENTIFIER ios/Runner.xcodeproj/project.pbxproj
rg iosBundleId lib/firebase_options.dart
```

---

## Hızlı sıra (pratik)

0. **Apple hesabı Active** (appeal) + Bundle ID ASC kaydı  
1. Tarif içeriği doldur  
2. Privacy Policy sayfası yayınla  
3. Version bump + `flutter build ipa`  
4. App Store Connect listing + screenshots  
5. App Privacy formu  
6. TestFlight smoke  
7. Submit  
