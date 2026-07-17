# Tech Context: Atıksız Mutfak

**Son Güncelleme:** Temmuz 2026 (17 Temmuz)

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
- **dio:** ^5.7.0 (HTTP client, redacted log interceptor)
- **flutter_dotenv:** ^5.2.1 (environment variables)

### Firebase
- **firebase_core:** ^3.8.1
- **firebase_auth:** ^5.3.3 (anonim oturum + admin web paneli)
- **firebase_storage:** ^12.3.6 (gönderi fotoğrafları)
- **cloud_firestore:** ^5.5.2 (tarif, post, leaderboard)
- **Firebase Spark (Ücretsiz) Plan:** 1GB depolama, 10K yazma/gün, 50K okuma/gün
  - Storage: 5GB depolama, **20KB yükleme/gün** (yoğun kullanımda yetersiz)
  - Hosting: 10GB depolama, 100MB/gün bant genişliği

### Data & Storage
- **shared_preferences:** ^2.3.3
- **path_provider:** ^2.1.4
- **cached_network_image:** ^3.4.1 (gönderi fotoğrafı thumbnail)

### UI & Content
- **flutter_markdown:** ^0.7.4+1
- **image_picker:** ^1.1.2
- **flutter_svg:** ^2.0.17

### Localization
- **flutter_localizations** + **intl**
- Desteklenen diller: Türkçe (TR) + İngilizce (EN)

### Code Generation
- **freezed:** ^2.5.7 + freezed_annotation
- **json_serializable:** ^6.8.0 + json_annotation
- **build_runner:** ^2.4.13
- **riverpod_generator:** ^2.6.3

---

## Proje Yapısı

```
zerowaste/
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   ├── network/            # NetworkService (Dio)
│   │   ├── providers/          # core_providers (DeepSeek, Auth, Storage)
│   │   ├── router/             # AppRouter (GoRouter)
│   │   ├── services/
│   │   │   ├── deep_seek_service.dart
│   │   │   ├── anonymous_auth_service.dart
│   │   │   └── post_image_storage_service.dart
│   │   ├── shell/              # MainTabShell, CustomBottomNav
│   │   ├── theme/
│   │   └── widgets/
│   │
│   ├── features/
│   │   ├── home/               # Tarif listesi + RecipesComingSoon
│   │   ├── recipe_generator/   # AI tarif üretimi
│   │   ├── chat/               # EcoChef sohbet
│   │   ├── splash/
│   │   └── points/             # Puan sistemi + gönderi upload
│   │
│   ├── l10n/
│   ├── firebase_options.dart
│   └── main.dart               # Firebase init + anonim auth startup
│
├── assets/data/recipes.json    # Referans veri (runtime'da kullanılmıyor)
├── firestore.rules
├── storage.rules
├── firebase.json
└── memory-bank/
```

---

## Önemli Dosya Listesi

### Core Services
| Dosya | Açıklama |
|-------|----------|
| `lib/core/services/anonymous_auth_service.dart` | Anonim Firebase Auth; Storage upload için oturum |
| `lib/core/services/post_image_storage_service.dart` | `posts/{postId}/photo.jpg` upload, max 2 MB |
| `lib/core/providers/core_providers.dart` | networkService, deepSeek, anonymousAuth, postImageStorage |

### Home / Recipes
| Dosya | Açıklama |
|-------|----------|
| `lib/features/home/data/models/recipe.dart` | Recipe model: title, description, ingredients[], instructions[], image_url |
| `lib/features/home/data/repositories/recipe_repository.dart` | Firestore-only; boşsa `[]` döner |
| `lib/features/home/presentation/widgets/recipes_coming_soon.dart` | Boş tarif listesi placeholder |
| `lib/features/home/presentation/widgets/recipe_detail_sheet.dart` | ingredients bullet, instructions numaralı |

### Points Feature
| Dosya | Açıklama |
|-------|----------|
| `lib/features/points/data/models/post_entry.dart` | imageUrl, localPreviewPath, çift dilli adminNote |
| `lib/features/points/data/repositories/points_repository.dart` | submitPost, approvePost, leaderboard, optOutUser |
| `lib/features/points/presentation/pages/points_page.dart` | Storage upload → Firestore submit akışı |
| `lib/features/points/presentation/widgets/post_image_thumbnail.dart` | CachedNetworkImage + local preview |

---

## Firestore Koleksiyon Yapısı

### `recipes` koleksiyonu
```
/recipes/{recipeId}
  title: string (zorunlu)
  description: string? (opsiyonel, tek paragraf)
  image_url: string? (opsiyonel)
  ingredients: string[] (zorunlu, her eleman mobilde ayrı madde)
  instructions: string[] (zorunlu, sıra = adım numarası)
```
**Rules:** read herkese açık; write sadece `admins/{uid}` olan kullanıcılar.

### `posts` koleksiyonu
```
/posts/{postId}
  nickname: string
  category: string
  points: int
  status: string (pending / approved / rejected)
  createdAt: timestamp
  leaderboardOptIn: bool
  imageUrl: string? (Firebase Storage download URL)
  imageColor: int? (placeholder rengi)
  isAdminBonus: bool
  isAdminPenalty: bool
  adminNote: string? (TR)
  adminNoteEn: string? (EN)
```
**Not:** Eski `imagePath` alanı legacy destek için `PostEntry.fromFirestore`'da okunur.

### `leaderboard/current` dokümanı
```
  entries: [{nickname: string, points: int}]
  lastUpdated: timestamp
```

### `admins/{userId}` dokümanı
```
  role: string? ("admin")
```

---

## Firebase Storage Yapısı

### Path: `posts/{postId}/photo.jpg`
- Max 2 MB, `image/jpeg` content type
- Public read; write sadece authenticated (anonim dahil)
- Rules: `storage.rules`

### Upload Akışı
```
image_picker → bytes oku → anonymousAuth.ensureSignedIn()
  → PostImageStorageService.uploadPostImage(postId)
  → download URL → PostEntry.imageUrl → Firestore submitPost()
```

---

## Firestore Index'leri
1. `posts`: `status` (Asc) + `createdAt` (Desc)
2. `posts`: `nickname` (Asc) + `createdAt` (Desc)
3. `posts`: `status` (Asc) + `leaderboardOptIn` (Asc)

---

## SharedPreferences Anahtarları

| Anahtar | Kullanım |
|---------|----------|
| `leaderboard_nickname` | Kullanıcının takma adı |
| `leaderboard_opt_in` | Leaderboard katılım izni |
| `last_known_points_{nickname}` | Son bilinen puan (animasyon tespiti) |
| `missions_date` | Günlük görev sıfırlama tarihi |
| `missions_completed` | Tamamlanan görevler |

---

## Development Setup

```bash
flutter pub get
# .env: DEEPSEEK_API_KEY=your_key
dart run build_runner build --delete-conflicting-outputs
flutter run
```

---

## Gelecek Teknik Planlar

### Admin Panel (Ayrı Web Projesi)
- `DynamicStringListField` widget: malzeme/adım dinamik liste input
- `AdminRecipeForm`: mobil Recipe şemasıyla uyumlu CRUD
- Route'lar: `/admin/recipes/new`, `/admin/recipes/:id`

### Firebase Spark Kota Yönetimi
- Storage 20KB/gün upload limiti izlenmeli
- Yoğun kullanımda Blaze geçişi veya görsel sıkıştırma stratejisi
