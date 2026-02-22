# Tech Context: ZeroWaste Mutfak

**Son Güncelleme:** Şubat 2025

---

## 🛠️ Teknoloji Stack

### Core Framework
- **Flutter:** 3.10.7+ (cross-platform mobile framework)
- **Dart:** 3.10.7+ (programming language)

### State Management
- **flutter_riverpod:** ^2.6.1 (state management)
- **riverpod_annotation:** ^2.6.1 (code generation)
- **riverpod_generator:** ^2.6.3 (dev dependency)

### Routing & Navigation
- **go_router:** ^14.6.2 (declarative routing)

### Network & API
- **dio:** ^5.7.0 (HTTP client)
- **flutter_dotenv:** ^5.2.1 (environment variables)

### Firebase
- **firebase_core:** ^3.8.1 (Firebase initialization)
- **firebase_auth:** ^5.3.3 (Authentication - admin paneli için)
- **cloud_firestore:** ^5.5.2 (Firestore database - tarifler için)

### Data & Storage
- **shared_preferences:** ^2.3.3 (key-value storage)
- **path_provider:** ^2.1.4 (file system paths)

### UI & Content
- **flutter_markdown:** ^0.7.4+1 (Markdown rendering)
- **image_picker:** ^1.1.2 (camera/gallery access)

### Code Generation
- **freezed:** ^2.5.7 (immutable classes)
- **freezed_annotation:** ^2.4.4
- **json_annotation:** ^4.9.0 (JSON serialization)
- **json_serializable:** ^6.8.0 (code generation)
- **build_runner:** ^2.4.13 (code generation runner)

### Development Tools
- **flutter_lints:** ^6.0.0 (linting rules)

---

## 🔌 External Services

### DeepSeek API
- **Base URL:** `https://api.deepseek.com`
- **Endpoint:** `/v1/chat/completions`
- **Model:** `deepseek-chat`
- **Authentication:** Bearer token (API key)
- **Format:** OpenAI-compatible API
- **Use Cases:**
  - AI tarif üretimi
  - Leafy mascot sohbeti

### Firebase (Aktif)
- **Firestore:** ✅ NoSQL database (tarifler için aktif, gönderiler/puanlar gelecek)
- **Cloud Storage:** ⏳ Fotoğraf depolama (Spark plan limiti nedeniyle bekliyor)
- **Authentication:** ✅ Email/Password (admin paneli için aktif)
- **Hosting:** ⏳ Web hosting (admin paneli için, Spark plan: 10 GB depolama, 360 MB/gün)
- **Plan:** Spark (ücretsiz) → Blaze (pay-as-you-go, gerekirse)

---

## 📁 Proje Yapısı

### Klasör Organizasyonu
```
zerowaste/
├── lib/
│   ├── core/                    # Paylaşılan core
│   │   ├── constants/          # AppConstants
│   │   ├── network/            # NetworkService
│   │   ├── providers/          # Global providers
│   │   ├── router/             # AppRouter
│   │   ├── services/           # DeepSeekService
│   │   ├── shell/              # MainTabShell, CustomBottomNav
│   │   ├── theme/              # AppTheme, AppColors
│   │   └── widgets/            # EmptyPlaceholder
│   │
│   ├── features/               # Feature modülleri
│   │   ├── home/               # Tarif listesi
│   │   ├── recipe_generator/   # AI tarif üretimi
│   │   ├── chat/               # Leafy sohbet
│   │   ├── points/             # Puan sistemi
│   │   └── admin/              # Web admin paneli
│   │       ├── services/       # AdminAuthService
│   │       └── presentation/
│   │           ├── pages/     # AdminLoginPage, AdminDashboardPage, AdminRecipeEditPage
│   │           ├── providers/  # Admin providers
│   │           └── widgets/   # AdminGuard, AdminSidebar, AdminRecipeForm
│   │
│   ├── firebase_options.dart   # Firebase yapılandırması (FlutterFire CLI ile oluşturuldu)
│   └── main.dart               # App entry point
│
├── assets/
│   └── data/
│       └── recipes.json        # Statik tarif verisi (fallback)
│
├── docs/
│   ├── firebase-free-plan-analysis.md
│   ├── firebase-setup-adimlar.md
│   ├── firestore-setup.md
│   ├── admin-panel-kurulum.md
│   ├── deployment-playstore-ve-web.md
│   ├── flutter-web-aciklama.md
│   └── firebase-hosting-admin-panel-kapasite.md
│
└── memory-bank/               # Proje dokümantasyonu
    ├── projectbrief.md
    ├── productContext.md
    ├── systemPatterns.md
    ├── techContext.md
    ├── activeContext.md
    └── progress.md
```

---

## 🔧 Development Setup

### Gereksinimler
- Flutter SDK 3.10.7+
- Dart SDK 3.10.7+
- Android Studio / VS Code
- Android SDK (Android development için)
- Xcode (iOS development için)
- Node.js (Firebase CLI için)
- Firebase CLI (`npm install -g firebase-tools`)
- FlutterFire CLI (`dart pub global activate flutterfire_cli`)

### Kurulum Adımları
1. Flutter SDK'yı yükle
2. Projeyi clone et
3. `flutter pub get` çalıştır
4. `.env` dosyası oluştur (opsiyonel):
   ```
   DEEPSEEK_API_KEY=your_api_key_here
   ```
5. Veya `--dart-define` ile çalıştır:
   ```bash
   flutter run --dart-define=DEEPSEEK_API_KEY=your_api_key_here
   ```

### Firebase Setup (Tamamlandı)
1. ✅ Firebase Console'da proje oluşturuldu (`zerowaste-46d54`)
2. ✅ `flutterfire configure` çalıştırıldı
3. ✅ `firebase_options.dart` dosyası oluşturuldu (Android, iOS, Web, macOS, Windows)
4. ✅ `firebase_core`, `firebase_auth`, `cloud_firestore` paketleri eklendi
5. ✅ `main.dart` içinde Firebase initialize edildi
6. ✅ Firestore Database aktif
7. ✅ Firebase Authentication aktif (Email/Password)
8. ⏳ Cloud Storage bekliyor (Spark plan limiti)

### Code Generation
```bash
# Freezed ve JSON serialization için
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (development için)
flutter pub run build_runner watch --delete-conflicting-outputs
```

### Build Commands
```bash
# Android APK
flutter build apk --release

# Android App Bundle (Play Store için)
flutter build appbundle --release

# iOS (macOS gerekli)
flutter build ios --release

# Web (admin paneli için)
flutter build web --release

# Web'de çalıştırma (development)
flutter run -d chrome
```

---

## 🔐 Environment Variables

### .env Dosyası
```env
DEEPSEEK_API_KEY=your_deepseek_api_key_here
```

### Dart Define (Alternatif)
```bash
flutter run --dart-define=DEEPSEEK_API_KEY=your_key
```

### Kodda Kullanım
```dart
// AppConstants.dart
static String get deepSeekApiKey =>
    dotenv.env['DEEPSEEK_API_KEY']?.trim() ??
    String.fromEnvironment('DEEPSEEK_API_KEY', defaultValue: '');
```

---

## 📦 Dependency Management

### pubspec.yaml Yapısı
- **dependencies:** Runtime dependencies
- **dev_dependencies:** Development-only dependencies
- **flutter.assets:** Asset dosyaları (JSON, images)

### Önemli Paketler ve Amaçları

| Paket | Amaç |
|-------|------|
| flutter_riverpod | State management |
| go_router | Navigation |
| dio | HTTP client |
| firebase_core | Firebase initialization |
| firebase_auth | Authentication (admin paneli) |
| cloud_firestore | Firestore database |
| freezed | Immutable models |
| image_picker | Camera/gallery |
| flutter_dotenv | Environment variables |

---

## 🧪 Testing (Gelecek)

### Test Klasör Yapısı
```
test/
├── unit/
│   ├── services/
│   ├── repositories/
│   └── providers/
├── widget/
│   └── features/
└── integration/
    └── flows/
```

### Test Komutları
```bash
# Tüm testler
flutter test

# Belirli bir test dosyası
flutter test test/unit/services/deep_seek_service_test.dart

# Coverage
flutter test --coverage
```

---

## 🚀 Deployment

### Android
1. `android/app/build.gradle.kts` içinde version code/name ayarla
2. `flutter build apk --release` veya `flutter build appbundle --release`
3. Google Play Console'a yükle

### iOS
1. `ios/Runner.xcodeproj` içinde version ayarla
2. `flutter build ios --release`
3. Xcode ile archive ve App Store'a yükle

### Web (Admin Paneli)
1. `flutter build web --release`
2. **Firebase Hosting:**
   ```bash
   firebase init hosting
   firebase deploy --only hosting
   ```
3. **Netlify/Vercel:** `build/web/` klasörünü yükle

---

## 🔍 Code Quality

### Linting
- **flutter_lints:** ^6.0.0
- **analysis_options.yaml:** Lint kuralları

### Formatting
```bash
# Kod formatla
dart format lib/

# Flutter format
flutter format lib/
```

### Best Practices
- const constructors kullan
- Gereksiz rebuild'lerden kaçın
- Dispose pattern'i takip et
- Error handling ekle
- Null safety kullan

---

## 📊 Performance Considerations

### Optimizasyonlar
- **ListView.builder:** Sadece görünen item'lar render edilir
- **const Widgets:** Gereksiz rebuild'ler önlenir
- **Image Caching:** Gelecekte cached_network_image kullanılabilir
- **Provider Optimization:** `select()` ile spesifik field'ları watch et
- **KeepAlive:** Admin providers için session boyunca aktif kalır

### Memory Management
- Controllers dispose edilmeli
- Focus nodes dispose edilmeli
- Image cache temizlenmeli (gerekirse)
- Stream subscriptions kapatılmalı

---

## 🔄 Version Control

### Git Workflow
- **Main Branch:** Production-ready code
- **Feature Branches:** Yeni özellikler için
- **Commit Messages:** Conventional commits (gelecek)

### .gitignore
- `build/` klasörü
- `.dart_tool/` klasörü
- `.env` dosyası (API keys)
- Generated files (`*.g.dart`, `*.freezed.dart`)

---

## 🐛 Debugging

### Debug Tools
- **Flutter DevTools:** Performance profiling
- **VS Code Debugger:** Breakpoints, step-through
- **Android Studio:** Full debugging suite

### Logging
- **Dio LogInterceptor:** Network istekleri loglanır
- **print():** Basit debug mesajları (production'da kaldırılmalı)
- **Gelecek:** Logger paketi (log levels ile)

---

## 📚 Resources & Documentation

### Flutter Docs
- [Flutter Documentation](https://docs.flutter.dev/)
- [Riverpod Documentation](https://riverpod.dev/)
- [GoRouter Documentation](https://pub.dev/packages/go_router)

### API Docs
- [DeepSeek API](https://api-docs.deepseek.com/)
- [Firebase Documentation](https://firebase.google.com/docs)

### Community
- Flutter Discord
- Stack Overflow
- GitHub Issues

---

## 🔗 İlgili Dokümanlar

- [Project Brief](projectbrief.md)
- [System Patterns](systemPatterns.md)
- [Firebase Analysis](../docs/firebase-free-plan-analysis.md)
