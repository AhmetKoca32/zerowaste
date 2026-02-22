# Deployment: Play Store + Web Yayınlama

**Tarih:** Şubat 2025

---

## ✅ Kısa Cevap

**Evet!** Aynı Flutter projesinden hem **Play Store** hem de **Web** için yayınlayabilirsin. İki ayrı build alırsın:

1. **Android Build** → Play Store'a yükle
2. **Web Build** → Web hosting'e yükle (Firebase Hosting, Netlify, vb.)

---

## 📱 1. Play Store Deployment

### Build Alma

```bash
# Release APK (test için)
flutter build apk --release

# App Bundle (Play Store için - önerilen)
flutter build appbundle --release
```

**Çıktı:**
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`

### Play Store'a Yükleme

1. **Google Play Console'a git:** https://play.google.com/console
2. **Yeni uygulama oluştur** veya mevcut uygulamayı seç
3. **Production** → **Create new release**
4. **AAB dosyasını yükle** (`app-release.aab`)
5. **Release notes** ekle
6. **Review** → **Start rollout**

### Gereksinimler

- **App Bundle (AAB)** formatı önerilir (APK yerine)
- **Signing key** gerekli (release build için)
- **Version code** ve **version name** artırılmalı
- **Privacy policy** URL'i (gerekirse)

---

## 🌐 2. Web Deployment

### Build Alma

```bash
# Web build
flutter build web --release
```

**Çıktı:** `build/web/` klasörü

### Hosting Seçenekleri

#### Seçenek A: Firebase Hosting (Önerilen) ✅

**Avantajlar:**
- Firebase projenle entegre
- Ücretsiz tier var
- SSL otomatik
- CDN dahil

**Adımlar:**

1. **Firebase CLI kur** (zaten kurulu):
```bash
firebase login
```

2. **Firebase Hosting'i başlat:**
```bash
firebase init hosting
```

Sorular:
- **What do you want to use as your public directory?** → `build/web`
- **Configure as a single-page app?** → `Yes`
- **Set up automatic builds and deploys with GitHub?** → `No` (isteğe bağlı)

3. **Build al ve deploy:**
```bash
flutter build web --release
firebase deploy --only hosting
```

**URL:** `https://zerowaste-46d54.web.app` (veya custom domain)

#### Seçenek B: Netlify

**Adımlar:**

1. **Build al:**
```bash
flutter build web --release
```

2. **Netlify'e yükle:**
   - Netlify.com'a git
   - `build/web` klasörünü drag & drop
   - Veya GitHub'a push edip Netlify'e bağla

**URL:** `https://zerowaste.netlify.app` (veya custom domain)

#### Seçenek C: Vercel

**Adımlar:**

1. **Build al:**
```bash
flutter build web --release
```

2. **Vercel CLI ile deploy:**
```bash
npm i -g vercel
vercel --prod build/web
```

**URL:** `https://zerowaste.vercel.app` (veya custom domain)

---

## 🔄 İki Platform İçin Aynı Proje

### Kod Yapısı

```
zerowaste/
├── lib/
│   ├── main.dart              # Hem mobil hem web için
│   ├── features/
│   │   ├── home/             # Hem mobil hem web için
│   │   ├── admin/            # Web admin paneli
│   │   └── ...
│   └── core/
│       └── router/
│           └── app_router.dart  # Route'lar
│
├── android/                   # Android build için
├── ios/                       # iOS build için (gelecek)
└── web/                       # Web build için
```

### Platform Kontrolü

Gerekirse platforma göre farklı kod çalıştırabilirsin:

```dart
import 'package:flutter/foundation.dart';

if (kIsWeb) {
  // Web için özel kod
  return WebLayout();
} else {
  // Mobil için kod
  return MobileLayout();
}
```

---

## 📋 Deployment Checklist

### Her İki Platform İçin

- [ ] **Version güncelle:**
  - `pubspec.yaml`: `version: 0.1.0+1` (0.1.0 = version name, +1 = build number)
  
- [ ] **Environment variables kontrol:**
  - `.env` dosyası (API keys)
  - Production için doğru değerler

- [ ] **Firebase yapılandırması:**
  - `firebase_options.dart` doğru mu?
  - Production Firebase projesi kullanılıyor mu?

### Android (Play Store) İçin

- [ ] **Signing key hazır:**
  - Release keystore oluşturuldu mu?
  - `android/key.properties` yapılandırıldı mı?

- [ ] **App Bundle build:**
  ```bash
  flutter build appbundle --release
  ```

- [ ] **Play Store metadata:**
  - App icon (512x512)
  - Screenshots
  - Description
  - Privacy policy URL

### Web İçin

- [ ] **Web build:**
  ```bash
  flutter build web --release
  ```

- [ ] **Hosting yapılandırması:**
  - Firebase Hosting / Netlify / Vercel
  - Custom domain (isteğe bağlı)

- [ ] **Web-specific ayarlar:**
  - `web/index.html` title ve meta tags
  - Favicon
  - PWA manifest (isteğe bağlı)

---

## 🚀 Deployment Workflow

### İlk Yayınlama

1. **Android:**
   ```bash
   flutter build appbundle --release
   # Play Store Console'a yükle
   ```

2. **Web:**
   ```bash
   flutter build web --release
   firebase deploy --only hosting
   ```

### Güncelleme Yayınlama

1. **Version artır:**
   ```yaml
   # pubspec.yaml
   version: 0.1.1+2  # Version name + build number
   ```

2. **Her iki platform için build al:**
   ```bash
   # Android
   flutter build appbundle --release
   
   # Web
   flutter build web --release
   ```

3. **Deploy et:**
   - Android: Play Store Console → New release
   - Web: `firebase deploy --only hosting`

---

## 💡 Önemli Notlar

### Version Yönetimi

**`pubspec.yaml`:**
```yaml
version: 0.1.0+1
#         ^    ^
#         |    └─ Build number (her build'de artar)
#         └────── Version name (kullanıcıya gösterilen)
```

- **Version name:** Kullanıcıya gösterilen versiyon (örn: "0.1.0")
- **Build number:** Her build'de artmalı (+1, +2, +3...)

### Farklı Environment'lar

**Development:**
- Firebase: Test project
- API keys: Development keys

**Production:**
- Firebase: Production project (`zerowaste-46d54`)
- API keys: Production keys

### Web için Özel Ayarlar

**`web/index.html` güncelle:**
```html
<title>ZeroWaste Mutfak</title>
<meta name="description" content="Sıfır atık mutfak uygulaması">
```

---

## 📊 Deployment Karşılaştırması

| Platform | Build Komutu | Çıktı | Yükleme Yeri |
|----------|--------------|-------|--------------|
| **Android** | `flutter build appbundle` | `.aab` dosyası | Google Play Console |
| **Web** | `flutter build web` | `build/web/` klasörü | Firebase Hosting / Netlify / Vercel |

---

## ✅ Sonuç

**Evet, aynı projeden hem Play Store hem Web yayınlayabilirsin!**

**Workflow:**
1. Kod yaz → Tek codebase
2. Android build al → Play Store'a yükle
3. Web build al → Web hosting'e yükle
4. Her ikisi de aynı kod tabanından gelir ✅

**Avantajlar:**
- ✅ Tek codebase yönetimi
- ✅ Aynı modeller ve logic
- ✅ Firebase entegrasyonu her ikisinde de çalışır
- ✅ Kolay güncelleme (her iki platform için aynı kod)

---

**Son Güncelleme:** Şubat 2025
