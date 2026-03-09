# Tech Context: Sıfır Atık Mutfak

**Son Güncelleme:** Mart 2025

---

## Teknoloji Stack

### Core Framework
- **Flutter:** 3.10.7+ (cross-platform mobile framework)
- **Dart:** 3.10.7+ (programming language)

### State Management
- **flutter_riverpod:** ^2.6.1
- **riverpod_annotation:** ^2.6.1
- **riverpod_generator:** ^2.6.3 (dev)

### Routing & Navigation
- **go_router:** ^14.6.2

### Network & API
- **dio:** ^5.7.0 (HTTP client)
- **flutter_dotenv:** ^5.2.1 (environment variables)

### Firebase
- **firebase_core:** ^3.8.1
- **firebase_auth:** ^5.3.3 (admin paneli)
- **cloud_firestore:** ^5.5.2 (tarif veritabanı)

### Data & Storage
- **shared_preferences:** ^2.3.3
- **path_provider:** ^2.1.4

### UI & Content
- **flutter_markdown:** ^0.7.4+1
- **image_picker:** ^1.1.2

### Code Generation
- **freezed:** ^2.5.7 + freezed_annotation
- **json_serializable:** ^6.8.0 + json_annotation
- **build_runner:** ^2.4.13

---

## Proje Yapısı

```
zerowaste/
├── lib/
│   ├── core/
│   │   ├── constants/          # AppConstants (appName: 'Sıfır Atık Mutfak')
│   │   ├── network/            # NetworkService
│   │   ├── providers/          # Global providers
│   │   ├── router/             # AppRouter
│   │   ├── services/           # DeepSeekService
│   │   ├── shell/              # MainTabShell, CustomBottomNav
│   │   ├── theme/              # AppTheme, AppColors (brand renkleri)
│   │   └── widgets/            # EmptyPlaceholder (Manrope font)
│   │
│   ├── features/
│   │   ├── home/               # Tarif listesi + malzeme filtreleme
│   │   ├── recipe_generator/   # AI tarif üretimi
│   │   ├── chat/               # Leafy sohbet (mock data)
│   │   ├── points/             # Puan sistemi
│   │   └── admin/              # Web admin paneli
│   │
│   ├── firebase_options.dart
│   └── main.dart
│
├── assets/
│   ├── data/
│   │   └── recipes.json        # Statik tarif verisi (fallback)
│   ├── fonts/
│   │   ├── Manrope-Regular.ttf
│   │   ├── Manrope-Medium.ttf
│   │   ├── Manrope-Bold.ttf
│   │   └── Manrope-Light.ttf
│   └── images/
│       ├── icons/
│       │   ├── tarifler_icon.png
│       │   ├── chat_icon.png
│       │   ├── puan_icon.png
│       │   ├── oluştur_icon.png
│       │   ├── alisveris_icon.png
│       │   └── search_icon.png
│       └── image/
│           └── yemek.png       # Tarif placeholder görseli
│
├── memory-bank/
└── docs/
```

---

## Önemli Dosya Listesi

### Core
| Dosya | Açıklama |
|-------|----------|
| `lib/core/theme/app_colors.dart` | Brand renkleri (brandOrange, brandCream), earth tones, neutrals. Eski yeşiller kaldırıldı |
| `lib/core/theme/app_theme.dart` | ColorScheme.fromSeed(brandOrange), ElevatedButton/InputDecoration temaları |
| `lib/core/shell/custom_bottom_nav.dart` | Pill-shaped frosted glass navbar, custom PNG ikonlar, Manrope Bold 12 |
| `lib/core/shell/main_tab_shell.dart` | TabBarView, extendBody: true, AppBar title Manrope Bold |
| `lib/core/constants/app_constants.dart` | appName: 'Sıfır Atık Mutfak' |
| `lib/core/widgets/empty_placeholder.dart` | Manrope font eklendi |

### Home Feature
| Dosya | Açıklama |
|-------|----------|
| `lib/features/home/presentation/pages/home_page.dart` | Arama + chip filter + akıllı sıralama + ListView |
| `lib/features/home/presentation/widgets/recipe_blog_card.dart` | Beyaz kart, yuvarlak resim, turuncu chip'ler, eşleşme göstergesi |
| `lib/features/home/presentation/widgets/recipe_detail_sheet.dart` | Beyaz bottom sheet, chip malzemeler, turuncu numaralı adımlar, Manrope |
| `lib/features/home/presentation/providers/home_providers.dart` | recipeListProvider (keepAlive: true) |
| `lib/features/home/data/models/recipe.dart` | Recipe model (Freezed, Firestore helpers) |

### Diğer Sayfalar
| Dosya | Önemli Notlar |
|-------|---------------|
| `recipe_generator_page.dart` | inTabs: true iken inner Scaffold bypass, SafeArea kaldırılmış |
| `chat_page.dart` | Input bar navbar üzerinde (bottom padding 120), mock data |
| `points_page.dart` | SafeArea kaldırılmış, scroll padding 120 |

---

## Development Setup

### Kurulum
1. `flutter pub get`
2. `.env` dosyası oluştur: `DEEPSEEK_API_KEY=your_key`
3. `dart run build_runner build --delete-conflicting-outputs`

### Build Commands
```bash
flutter build apk --release          # Android
flutter build web --release           # Admin paneli
flutter run -d chrome                 # Web geliştirme
dart run build_runner build --delete-conflicting-outputs  # Code gen
```

---

## Bilinen Teknik Notlar

### Firestore PERMISSION_DENIED
- Logda `Listen for Query... PERMISSION_DENIED` hatası görülebilir
- Firestore Security Rules production için güncellenmeli
- Emülatörde "Unknown calling package" Google Play Services hatası normal

### Code Generation
- Provider değişikliklerinden sonra `build_runner` çalıştırılmalı
- `@Riverpod(keepAlive: true)` için generated dosya yeniden oluşturulmalı

### pubspec.yaml Asset Paths
```yaml
flutter:
  assets:
    - assets/data/
    - assets/images/icons/
    - assets/images/image/
  fonts:
    - family: Manrope
      fonts:
        - asset: assets/fonts/Manrope-Regular.ttf
        - asset: assets/fonts/Manrope-Medium.ttf
          weight: 500
        - asset: assets/fonts/Manrope-Bold.ttf
          weight: 700
        - asset: assets/fonts/Manrope-Light.ttf
          weight: 300
```
