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
- **shared_preferences:** ^2.3.3 (RecentIngredients, SavedRecipes)
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
│   │   │   └── presentation/widgets/
│   │   │       ├── recipe_blog_card.dart
│   │   │       ├── recipe_detail_sheet.dart
│   │   │       └── ingredient_filter_sheet.dart  # YENİ
│   │   ├── recipe_generator/   # AI tarif üretimi
│   │   │   └── presentation/widgets/
│   │   │       ├── chef_loading_overlay.dart
│   │   │       ├── recipe_result_sheet.dart
│   │   │       └── saved_recipes_sheet.dart      # YENİ
│   │   ├── chat/               # Leafy sohbet (mock data)
│   │   ├── points/             # Puan sistemi
│   │   └── admin/              # Web admin paneli
│   │
│   ├── firebase_options.dart
│   └── main.dart
│
├── assets/
│   ├── data/
│   │   └── recipes.json        # 7 detaylı tarif (fallback)
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
│       │   ├── search_icon.png
│       │   └── arrow_icon.png      # YENİ
│       └── image/
│           └── yemek.png
│
├── firestore.rules                 # YENİ
├── memory-bank/
└── docs/
```

---

## Önemli Dosya Listesi

### Core
| Dosya | Açıklama |
|-------|----------|
| `lib/core/theme/app_colors.dart` | Brand renkleri (brandOrange, brandCream), earth tones, neutrals |
| `lib/core/theme/app_theme.dart` | ColorScheme.fromSeed(brandOrange) |
| `lib/core/shell/custom_bottom_nav.dart` | Pill-shaped frosted glass navbar |
| `lib/core/shell/main_tab_shell.dart` | TabBarView, extendBody: true |

### Home Feature
| Dosya | Açıklama |
|-------|----------|
| `home_page.dart` | Arama + filtre butonu + seçili chip'ler + tarif listesi |
| `recipe_blog_card.dart` | Beyaz kart, "N malzeme · N adım" özeti, eşleşme göstergesi |
| `recipe_detail_sheet.dart` | İstatistik barı, kenarlıklı kart bölümler, showPlaceholderImage |
| `ingredient_filter_sheet.dart` | Malzeme filtre bottom sheet (arama + wrap + uygula/temizle) |
| `home_providers.dart` | recipeListProvider (keepAlive: true) |
| `recipe.dart` | Recipe model (Freezed, description alanı, Firestore helpers) |
| `recipe_repository.dart` | Firestore + fallback (boşsa veya hata verirse yerel JSON) |

### Recipe Generator Feature
| Dosya | Açıklama |
|-------|----------|
| `recipe_generator_page.dart` | Yeniden tasarlandı: input, dropdown, son eklenenler, kayıtlı tarifler |
| `recipe_generator_providers.dart` | IngredientList, RecentIngredients, SelectedCuisine, SavedRecipes, GeneratedRecipe |
| `saved_recipes_sheet.dart` | Tüm kayıtlı tarifler bottom sheet (arama + dikey liste) |
| `cuisine_options.dart` | Mutfak seçenekleri listesi |

### Diğer
| Dosya | Açıklama |
|-------|----------|
| `firestore.rules` | Firestore Security Rules (recipes: okuma açık, yazma admin; admins: kendi kaydı) |

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
flutter clean                         # Build cache temizle
```

---

## Bilinen Teknik Notlar

### Firestore
- Security Rules: `firestore.rules` dosyası mevcut
- Emülatörde DEVELOPER_ERROR / "Unknown calling package" normal, Firestore'u engellemiyor
- Firestore boşsa veya bağlantı hata verirse otomatik yerel JSON fallback

### Code Generation
- Provider değişikliklerinden sonra `build_runner` çalıştırılmalı
- `@Riverpod(keepAlive: true)` için generated dosya yeniden oluşturulmalı

### SharedPreferences
- RecentIngredients: `recent_ingredients` key, max 10 malzeme
- SavedRecipes: local storage ile tarif kaydetme

### PowerShell Komutları
- `%USERPROFILE%` yerine `$env:USERPROFILE` kullan (SHA-1 alma vb.)
- `&&` yerine `;` veya ayrı komutlar kullan

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
